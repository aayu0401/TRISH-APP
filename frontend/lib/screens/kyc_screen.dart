import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/kyc_service.dart';
import '../models/kyc.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  final KYCService _kycService = KYCService();
  final ImagePicker _picker = ImagePicker();
  
  KYCStatus _currentStatus = KYCStatus.notStarted;
  KYCType _selectedDocType = KYCType.aadhar;
  
  File? _frontImage;
  File? _backImage;
  File? _selfieImage;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final status = await _kycService.getKYCStatus();
    if (mounted) {
      setState(() {
        _currentStatus = status?.status ?? KYCStatus.notStarted;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File) onPick) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        onPick(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _submitKYC() async {
    if (_frontImage == null || _selfieImage == null) {
      _showErrorSnackBar('Please upload at least Front ID and Selfie');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    List<File> docImages = [_frontImage!];
    if (_backImage != null) docImages.add(_backImage!);

    final success = await _kycService.submitKYC(
      type: _selectedDocType,
      documentData: {'type': _selectedDocType.toString()}, // Add any entered ID numbers here if needed
      documentImages: docImages,
      selfieImage: _selfieImage,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _showSuccessDialog();
        _checkStatus();
      } else {
        _showErrorSnackBar('Verification submission failed. Please try again.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Submission Successful',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your documents have been submitted for verification. This usually takes 24-48 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground, // Using dark bg as base layer
      body: Stack(
        children: [
          // Background
           Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1600', // Abstract secure/tech background
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Colors.white.withOpacity(0.95),
                     Colors.white.withOpacity(0.8),
                   ],
                 ),
               ),
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
                      : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Identity Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentStatus == KYCStatus.verified) {
      return _buildStatusCard(
        icon: Icons.verified_user_rounded,
        color: AppTheme.successGreen,
        title: 'You are Verified!',
        message: 'Your identity has been confirmed. You now have full access to all premium features and the verified badge.',
      );
    } else if (_currentStatus == KYCStatus.pending || _currentStatus == KYCStatus.inProgress) {
      return _buildStatusCard(
        icon: Icons.hourglass_top_rounded,
        color: AppTheme.warningYellow,
        title: 'Verification In Progress',
        message: 'We are currently reviewing your documents. You will be notified once the process is complete.',
      );
    } else if (_currentStatus == KYCStatus.rejected) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusCard(
              icon: Icons.error_outline_rounded,
              color: AppTheme.errorRed,
              title: 'Verification Failed',
              message: 'Your previous submission was rejected. Please ensure your photos are clear and try again.',
            ),
            const SizedBox(height: 20),
            _buildForm(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildForm(),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoMessage(),
          const SizedBox(height: 32),
          
          const Text(
            'Select Document Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildDocTypeSelector(),
          
          const SizedBox(height: 32),
          const Text(
            'Upload Documents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildImageUploadBox(
                  label: 'Front Side',
                  file: _frontImage,
                  onTap: () => _pickImage(ImageSource.gallery, (f) => setState(() => _frontImage = f)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageUploadBox(
                  label: 'Back Side',
                  file: _backImage,
                  onTap: () => _pickImage(ImageSource.gallery, (f) => setState(() => _backImage = f)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'Selfie Verification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Center(
            child: _buildSelfieUploadBox(),
          ),

          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitKYC,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppTheme.primaryPink.withOpacity(0.4),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Verification',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.privacy_tip_rounded, color: AppTheme.accentBlue),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Your data is securely encrypted and never shared. We only use this for verification.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<KYCType>(
          value: _selectedDocType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryPink),
          items: KYCType.values.map((type) {
            String label = type.toString().split('.').last.toUpperCase();
            if (type == KYCType.drivingLicense) label = 'DRIVING LICENSE';
            return DropdownMenuItem(
              value: type,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedDocType = val);
          },
        ),
      ),
    );
  }

  Widget _buildImageUploadBox({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? AppTheme.primaryPink : Colors.grey.withOpacity(0.3),
            width: file != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(file, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryPink),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSelfieUploadBox() {
    return InkWell(
      onTap: () => _pickImage(ImageSource.camera, (f) => setState(() => _selfieImage = f)),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selfieImage != null ? AppTheme.primaryPink : Colors.grey.withOpacity(0.3),
            width: _selfieImage != null ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _selfieImage != null
            ? ClipOval(
                child: Image.file(_selfieImage!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.face_retouching_natural_rounded, size: 40, color: AppTheme.primaryPink),
                  const SizedBox(height: 8),
                  const Text(
                    'Take Selfie',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
