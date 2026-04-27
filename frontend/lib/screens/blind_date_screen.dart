import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/match_service.dart';

class BlindDateScreen extends StatefulWidget {
  const BlindDateScreen({super.key});
  @override
  State<BlindDateScreen> createState() => _BlindDateScreenState();
}

class _BlindDateScreenState extends State<BlindDateScreen> with TickerProviderStateMixin {
  final _matchService = MatchService();
  List<User> _profiles = [];
  bool _loading = true;
  int _currentIndex = 0;
  bool _isMatchReveal = false;
  User? _matchedUser;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final data = await _matchService.getRecommendations();
      setState(() { _profiles = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSwipe(String direction) async {
    if (_currentIndex >= _profiles.length) return;
    final user = _profiles[_currentIndex];

    if (direction == 'right') {
      try {
        final result = await _matchService.swipe(targetUserId: user.id!, swipeType: 'LIKE');
        if (result['matched'] == true) {
          setState(() { _matchedUser = user; _isMatchReveal = true; });
          return;
        }
      } catch (_) {}
    }

    setState(() {
      if (_currentIndex < _profiles.length - 1) _currentIndex++;
      else _currentIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(children: [
        // Ambient glows
        Positioned(top: -100, right: -100, child: Container(width: 300, height: 300,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6366F1).withOpacity(0.15)),
        )),
        Positioned(bottom: -100, left: -100, child: Container(width: 300, height: 300,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryPink.withOpacity(0.15)),
        )),
        SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1))),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFFBBF24).withOpacity(0.1), borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.2))),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.workspace_premium, color: Color(0xFFFBBF24), size: 14),
                  SizedBox(width: 6),
                  Text('PREMIUM MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFBBF24), letterSpacing: 0.5)),
                ])),
            ]),
            const SizedBox(height: 24),
            FadeInDown(child: Row(children: [
              const Text('Blind Date', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 10),
              Icon(Icons.auto_fix_high, color: const Color(0xFF6366F1).withOpacity(0.8)),
            ])),
            const SizedBox(height: 4),
            Text('Interests first, faces later.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            // Content
            Expanded(child: _loading
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(color: const Color(0xFF6366F1).withOpacity(0.8), strokeWidth: 2.5),
                  const SizedBox(height: 16),
                  Text('Searching for mysterious connections...', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                ]))
              : _currentIndex >= 0 && _currentIndex < _profiles.length
                ? _buildBlindCard(_profiles[_currentIndex])
                : _buildEmpty()),
          ])),
        ),
        // Match reveal overlay
        if (_isMatchReveal && _matchedUser != null) _buildMatchReveal(),
      ]),
    );
  }

  Widget _buildBlindCard(User user) {
    return FadeIn(child: Column(children: [
      Expanded(child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Mystery avatar
          Center(child: Container(width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(colors: [const Color(0xFF6366F1).withOpacity(0.3), AppTheme.primaryPink.withOpacity(0.3)])),
            child: const Icon(Icons.person, color: Colors.white38, size: 50))),
          const SizedBox(height: 24),
          Center(child: Text('Mystery Person', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.9)))),
          Center(child: Text('${user.age} years old', style: TextStyle(color: Colors.white.withOpacity(0.4)))),
          const SizedBox(height: 28),
          Text('Interests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: (user.interests.isEmpty ? ['Travel', 'Music', 'Art'] : user.interests)
            .map((i) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08))),
              child: Text(i, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)))).toList()),
          const Spacer(),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Text('About', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 8),
            Text(user.bio!, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ]),
      )),
      const SizedBox(height: 20),
      // Action buttons
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _circleBtn(Icons.close, const Color(0xFFEF4444), () => _handleSwipe('left')),
        const SizedBox(width: 32),
        _circleBtn(Icons.favorite, AppTheme.primaryPink, () => _handleSwipe('right'), large: true),
      ]),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.info_outline, color: Colors.white.withOpacity(0.4), size: 16),
          const SizedBox(width: 8),
          Text('Pictures reveal once you both match', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ])),
    ]));
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap, {bool large = false}) {
    final size = large ? 70.0 : 56.0;
    return GestureDetector(onTap: onTap, child: Container(width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20)]),
      child: Icon(icon, color: color, size: size * 0.45)));
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6366F1).withOpacity(0.1)),
      child: Icon(Icons.visibility_off, color: Colors.white.withOpacity(0.2), size: 36)),
    const SizedBox(height: 24),
    const Text('No More Mystery Matches', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
    const SizedBox(height: 8),
    Text('Check back later or try normal discovery.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
  ]));

  Widget _buildMatchReveal() => GestureDetector(
    onTap: () {},
    child: Container(color: const Color(0xFF0F172A).withOpacity(0.95),
      child: Center(child: FadeIn(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ZoomIn(child: const Text('✨', style: TextStyle(fontSize: 64))),
        const SizedBox(height: 24),
        ShaderMask(shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: const Text("It's a Reveal!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))),
        const SizedBox(height: 8),
        Text('You both swiped blindly!', style: TextStyle(color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 32),
        Container(width: 200, height: 260, decoration: BoxDecoration(borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 50)]),
          child: ClipRRect(borderRadius: BorderRadius.circular(32),
            child: Stack(children: [
              Container(color: Colors.white.withOpacity(0.05),
                child: Center(child: Icon(Icons.person, size: 80, color: Colors.white.withOpacity(0.3)))),
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)])),
                  child: Text(_matchedUser?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)))),
            ]))),
        const SizedBox(height: 32),
        ElevatedButton.icon(onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.favorite, color: Color(0xFF0F172A)),
          label: const Text('Start Conversing', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
        const SizedBox(height: 12),
        TextButton(onPressed: () => setState(() { _isMatchReveal = false; if (_currentIndex < _profiles.length - 1) _currentIndex++; else _currentIndex = -1; }),
          child: Text('Continue Browsing', style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600))),
      ])))),
  );
}
