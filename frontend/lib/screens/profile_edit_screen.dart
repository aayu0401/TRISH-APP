import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../constants/app_constants.dart';
import '../utils/app_snackbar.dart';
import '../services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _userService = UserService();
  String _selectedGender = 'Male';
  String _interestedIn = 'Female';
  List<String> _selectedInterests = [];
  double _minAge = 18, _maxAge = 35, _maxDist = 50;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      _nameCtrl.text = user.name;
      _bioCtrl.text = user.bio ?? '';
      _cityCtrl.text = user.city ?? '';
      _selectedGender = user.gender ?? 'Male';
      _interestedIn = user.interestedInGender ?? 'Female';
      _selectedInterests = List.from(user.interests);
      _minAge = (user.minAge ?? 18).toDouble();
      _maxAge = (user.maxAge ?? 35).toDouble();
      _maxDist = (user.maxDistance ?? 50).toDouble();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _bioCtrl.dispose(); _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updates = {
        'name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'gender': _selectedGender,
        'interestedInGender': _interestedIn,
        'interests': _selectedInterests,
        'minAge': _minAge.toInt(),
        'maxAge': _maxAge.toInt(),
        'maxDistance': _maxDist.toInt(),
      };
      final ok = await context.read<UserProvider>().updateProfile(updates);
      if (mounted) {
        if (ok) { AppSnackBar.success(context, 'Profile updated!'); Navigator.pop(context); }
        else AppSnackBar.error(context, 'Update failed');
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error: $e');
    }
    setState(() => _saving = false);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 80);
    if (img == null) return;
    try {
      await _userService.uploadPhoto(File(img.path));
      if (mounted) { AppSnackBar.success(context, 'Photo uploaded!'); context.read<UserProvider>().loadProfile(); }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.chevron_left, color: AppTheme.textPrimary))),
          const SizedBox(width: 16),
          const Expanded(child: Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
          _saving
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPink))
            : GestureDetector(onTap: _save,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        ])),
        Expanded(child: Form(key: _formKey, child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Photo
            FadeInDown(child: GestureDetector(onTap: _pickPhoto,
              child: Container(width: double.infinity, height: 120, decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2), width: 2, style: BorderStyle.solid)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryPink.withOpacity(0.6), size: 32),
                  const SizedBox(height: 8),
                  Text('Add Photos', style: TextStyle(color: AppTheme.primaryPink.withOpacity(0.7), fontWeight: FontWeight.w600)),
                ])))),
            const SizedBox(height: 24),
            _sectionLabel('BASIC INFO'),
            const SizedBox(height: 12),
            _field('Name', _nameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            _field('Bio', _bioCtrl, maxLines: 3, hint: 'Tell about yourself...'),
            const SizedBox(height: 14),
            _field('City', _cityCtrl, hint: 'Your city'),
            const SizedBox(height: 14),
            _dropdownField('Gender', _selectedGender, ['Male', 'Female', 'Non-binary', 'Other'],
              (v) => setState(() => _selectedGender = v!)),
            const SizedBox(height: 14),
            _dropdownField('Interested In', _interestedIn, ['Male', 'Female', 'Everyone'],
              (v) => setState(() => _interestedIn = v!)),
            const SizedBox(height: 28),
            _sectionLabel('INTERESTS'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: AppConstants.commonInterests.map((i) {
              final sel = _selectedInterests.contains(i);
              return GestureDetector(
                onTap: () => setState(() { sel ? _selectedInterests.remove(i) : _selectedInterests.add(i); }),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primaryPink.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppTheme.primaryPink : const Color(0xFFE5E7EB))),
                  child: Text(i, style: TextStyle(color: sel ? AppTheme.primaryPink : AppTheme.textSecondary, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 14))),
              );
            }).toList()),
            const SizedBox(height: 28),
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 16),
            _rangeSliderTile('Age Range', '${_minAge.toInt()} - ${_maxAge.toInt()}',
              RangeValues(_minAge, _maxAge), 18, 60,
              (v) => setState(() { _minAge = v.start; _maxAge = v.end; })),
            const SizedBox(height: 16),
            _sliderTile('Max Distance', '${_maxDist.toInt()} km', _maxDist, 1, 100,
              (v) => setState(() => _maxDist = v)),
            const SizedBox(height: 40),
          ])))),
      ])),
    );
  }

  Widget _sectionLabel(String t) => Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppTheme.textTertiary.withOpacity(0.6)));

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, String? hint, String? Function(String?)? validator}) =>
    TextFormField(controller: ctrl, maxLines: maxLines, validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint));

  Widget _dropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) =>
    DropdownButtonFormField<String>(value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged, decoration: InputDecoration(labelText: label));

  Widget _rangeSliderTile(String label, String display, RangeValues values, double min, double max, ValueChanged<RangeValues> onChanged) =>
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
          Text(display, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryPink)),
        ]),
        RangeSlider(values: values, min: min, max: max, divisions: (max - min).toInt(),
          activeColor: AppTheme.primaryPink, inactiveColor: AppTheme.primaryPink.withOpacity(0.1),
          onChanged: onChanged),
      ]));

  Widget _sliderTile(String label, String display, double value, double min, double max, ValueChanged<double> onChanged) =>
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
          Text(display, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryPink)),
        ]),
        Slider(value: value, min: min, max: max, divisions: (max - min).toInt(),
          activeColor: AppTheme.primaryPink, inactiveColor: AppTheme.primaryPink.withOpacity(0.1),
          onChanged: onChanged),
      ]));
}
