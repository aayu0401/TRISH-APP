import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeView = 'main';
  bool _notifMatches = true, _notifMessages = true, _notifLikes = false;
  bool _notifAi = true, _notifSmart = true;
  bool _showOnline = true, _showDist = true, _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _activeView == 'main'
              ? _mainView()
              : _activeView == 'notifications'
                  ? _notifView()
                  : _privacyView(),
        ),
      ),
    );
  }

  Widget _back(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 12),
    child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppTheme.textTertiary.withOpacity(0.6))),
  );

  Widget _tile(IconData icon, String label, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryPink.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryPink, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary))),
          Icon(Icons.chevron_right, color: AppTheme.textTertiary.withOpacity(0.5), size: 20),
        ]),
      ),
    ),
  );

  Widget _toggle(IconData icon, String label, bool val, ValueChanged<bool> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(
          color: val ? AppTheme.successGreen.withOpacity(0.08) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: val ? AppTheme.successGreen : AppTheme.textTertiary, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary))),
        Switch(value: val, onChanged: onChanged, activeColor: AppTheme.successGreen),
      ]),
    ),
  );

  Widget _mainView() {
    final user = context.watch<UserProvider>().currentUser;
    return SingleChildScrollView(
      key: const ValueKey('main'), padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FadeInDown(child: Row(children: [_back(() => Navigator.pop(context)), const SizedBox(width: 16),
          const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))])),
        const SizedBox(height: 24),
        FadeInDown(delay: const Duration(milliseconds: 100), child: Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))]),
          child: Column(children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
              child: Center(child: Text((user?.name ?? 'T')[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)))),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Trish User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(12)),
              child: const Text('✨ Premium Member', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
        )),
        const SizedBox(height: 28),
        _label('ACCOUNT'),
        _tile(Icons.notifications_outlined, 'Notifications', () => setState(() => _activeView = 'notifications')),
        _tile(Icons.lock_outline, 'Privacy & Safety', () => setState(() => _activeView = 'privacy')),
        _tile(Icons.shield_outlined, 'Security', () {}),
        const SizedBox(height: 20),
        _label('SUPPORT'),
        _tile(Icons.help_outline, 'Help Center', () {}),
        _tile(Icons.mail_outline, 'Contact Us', () {}),
        const SizedBox(height: 20),
        _label('LOGIN'),
        GestureDetector(
          onTap: () => _handleLogout(context),
          child: Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout, color: Color(0xFFEF4444), size: 20), SizedBox(width: 12),
              Text('Log Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height: 32),
        Center(child: Text('TRISH APP V1.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppTheme.textTertiary.withOpacity(0.5)))),
      ]),
    );
  }

  Widget _notifView() => SingleChildScrollView(
    key: const ValueKey('notif'), padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [_back(() => setState(() => _activeView = 'main')), const SizedBox(width: 16),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text('Manage your alerts', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ])]),
      const SizedBox(height: 28),
      _label('PUSH NOTIFICATIONS'),
      _toggle(Icons.favorite_outline, 'New Matches', _notifMatches, (v) => setState(() => _notifMatches = v)),
      _toggle(Icons.chat_bubble_outline, 'Messages', _notifMessages, (v) => setState(() => _notifMessages = v)),
      _toggle(Icons.thumb_up_outlined, 'Likes', _notifLikes, (v) => setState(() => _notifLikes = v)),
      const SizedBox(height: 20),
      _label('SMART ALERTS'),
      _toggle(Icons.auto_awesome, 'AI Match Insights', _notifAi, (v) => setState(() => _notifAi = v)),
      _toggle(Icons.lightbulb_outline, 'Conversation Starters', _notifSmart, (v) => setState(() => _notifSmart = v)),
    ]),
  );

  Widget _privacyView() => SingleChildScrollView(
    key: const ValueKey('privacy'), padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [_back(() => setState(() => _activeView = 'main')), const SizedBox(width: 16),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Privacy & Safety', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text('Control your visibility', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ])]),
      const SizedBox(height: 28),
      _label('VISIBILITY'),
      _toggle(Icons.circle, 'Show Online Status', _showOnline, (v) => setState(() => _showOnline = v)),
      _toggle(Icons.location_on_outlined, 'Show Distance', _showDist, (v) => setState(() => _showDist = v)),
      _toggle(Icons.done_all, 'Read Receipts', _readReceipts, (v) => setState(() => _readReceipts = v)),
    ]),
  );

  Future<void> _handleLogout(BuildContext ctx) async {
    final ok = await showDialog<bool>(context: ctx, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(c, true),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
          child: const Text('Log Out', style: TextStyle(color: Colors.white))),
      ],
    ));
    if (ok == true && mounted) {
      await ctx.read<AuthProvider>().logout();
      if (mounted) Navigator.of(ctx).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }
}
