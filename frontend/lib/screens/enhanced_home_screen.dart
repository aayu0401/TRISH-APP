import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/match.dart';
import '../services/match_service.dart';
import '../widgets/profile_card.dart';
import '../utils/app_snackbar.dart';
import '../services/profile_view_service.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../widgets/ai_assistant_overlay.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final _matchService = MatchService();
  final _profileViewService = ProfileViewService();
  final CardSwiperController _swiperController = CardSwiperController();
  
  List<User> _recommendations = [];
  bool _isLoading = true;
  int _todayLikes = 0;
  int _todayMatches = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRecommendations();
    _loadDailyStats();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await _matchService.getRecommendations();
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.error(context, 'Failed to load recommendations');
    }
  }

  Future<void> _loadDailyStats() async {
    // TODO: Implement actual API call for daily stats
    setState(() {
      _todayLikes = 12;
      _todayMatches = 3;
    });
  }

  Future<bool> _handleSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    if (previousIndex >= _recommendations.length) return true;

    final user = _recommendations[previousIndex];
    String swipeType = 'PASS';

    if (direction == CardSwiperDirection.right) {
      swipeType = 'LIKE';
      if (user.id != null) _profileViewService.recordView(user.id!).catchError((_) {});
      _showSwipeFeedback('Liked!', AppTheme.successGreen, Icons.favorite);
      setState(() => _todayLikes++);
    } else if (direction == CardSwiperDirection.top) {
      swipeType = 'SUPER_LIKE';
      if (user.id != null) _profileViewService.recordView(user.id!).catchError((_) {});
      _showSwipeFeedback('Super Like!', AppTheme.accentBlue, Icons.star);
    } else if (direction == CardSwiperDirection.left) {
      _showSwipeFeedback('Passed', AppTheme.errorRed, Icons.close);
    }

    try {
      final result = await _matchService.swipe(
        targetUserId: user.id!,
        swipeType: swipeType,
      );

      if (result['matched'] == true && mounted) {
        setState(() => _todayMatches++);
        await Future.delayed(const Duration(milliseconds: 300));
        final matchJson = result['match'];
        _showMatchDialog(user, matchJson: matchJson);
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Swipe failed. Please try again.');
    }

    return true;
  }

  Future<void> _handleRewind() async {
    try {
      final result = await _matchService.rewind();
      if (result['success'] == true && result['user'] != null && mounted) {
        await _loadRecommendations();
        AppSnackBar.success(context, 'Profile restored! Swipe again.');
      } else if (mounted) {
        AppSnackBar.info(context, 'No pass to rewind');
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Rewind failed');
    }
  }

  void _showSwipeFeedback(String text, Color color, IconData icon) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.5 - 75,
        child: FadeInDown(
          duration: const Duration(milliseconds: 300),
          child: FadeOutUp(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 800), () {
      overlayEntry.remove();
    });
  }

  void _showMatchDialog(User user, {Map<String, dynamic>? matchJson}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ZoomIn(
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.extraLargeRadius,
              boxShadow: AppTheme.glowShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Heart
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "It's a Match!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You and ${user.name} liked each other',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Keep Swiping'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Match? match;
                          if (matchJson != null) {
                            match = Match.fromJson(matchJson);
                          } else {
                            match = Match(
                              id: 0,
                              user1: user,
                              user2: user,
                              matchedAt: DateTime.now(),
                              isActive: true,
                            );
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(match: match!),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryPink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Send Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Light Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1520623321903-518f921f7ee9?w=1600', // Light aesthetic background
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
                     Colors.white.withOpacity(0.9),
                     AppTheme.darkBackground.withOpacity(0.8),
                   ],
                 ),
               ),
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildDailyStats(),
                Expanded(child: _buildCardStack()),
                _buildActionButtons(),
              ],
            ),
          ),
          const AIAssistantOverlay(context: 'home'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HeaderButton(
              icon: Icons.person_outline_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
             // Gradient Text Logo
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'TRISH',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontFamily: 'Nunito', // Assuming Nunito or similar rounded font
                ),
              ),
            ),
            _HeaderButton(
              icon: Icons.chat_bubble_outline_rounded,
              badge: _todayMatches > 0 ? _todayMatches.toString() : null,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MatchesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.favorite,
                label: 'Today\'s Likes',
                value: _todayLikes.toString(),
                gradient: AppTheme.primaryGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                label: 'New Matches',
                value: _todayMatches.toString(),
                gradient: AppTheme.blueGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primaryPink,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Finding your perfect matches...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return FadeIn(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowShadow,
                ),
                child: const Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No more profiles',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Check back later for new matches',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadRecommendations,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: CardSwiper(
          controller: _swiperController,
          cardsCount: _recommendations.length,
          onSwipe: _handleSwipe,
          numberOfCardsDisplayed: 3,
          backCardOffset: const Offset(0, 40),
          padding: const EdgeInsets.all(0),
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return ProfileCard(
              user: _recommendations[index],
              showActions: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SwipeButton(
              icon: Icons.close,
              color: AppTheme.errorRed,
              size: 65,
              onPressed: _swiperController.swipeLeft,
            ),
            _SwipeButton(
              icon: Icons.undo_rounded,
              color: AppTheme.accentBlue,
              size: 50,
              onPressed: _handleRewind,
            ),
            _SwipeButton(
              icon: Icons.star,
              color: AppTheme.accentBlue,
              size: 55,
              onPressed: _swiperController.swipeTop,
            ),
            _SwipeButton(
              icon: Icons.favorite,
              color: AppTheme.successGreen,
              size: 65,
              onPressed: _swiperController.swipeRight,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    this.badge,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: AppTheme.primaryPink),
            onPressed: onPressed,
            iconSize: 26,
            padding: const EdgeInsets.all(12),
          ),
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 22,
                minHeight: 22,
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (gradient is LinearGradient) 
                      ? (gradient as LinearGradient).colors.first.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const _SwipeButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onPressed,
  });

  @override
  State<_SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<_SwipeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}
