import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/match_service.dart';
import '../services/auth_service.dart';
import '../widgets/profile_card.dart';
import '../widgets/loading_widgets.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final _matchService = MatchService();
  final _authService = AuthService();
  final CardSwiperController _swiperController = CardSwiperController();
  
  List<User> _recommendations = [];
  bool _isLoading = true;
  int _currentCardIndex = 0;
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
      if (mounted) {
        _showErrorSnackBar('Failed to load recommendations');
      }
    }
  }

  Future<void> _loadDailyStats() async {
    // TODO: Implement actual API call for daily stats
    setState(() {
      _todayLikes = 12;
      _todayMatches = 3;
    });
  }

  Future<void> _handleSwipe(int index, CardSwiperDirection direction) async {
    if (index >= _recommendations.length) return;

    final user = _recommendations[index];
    String swipeType = 'PASS';

    if (direction == CardSwiperDirection.right) {
      swipeType = 'LIKE';
      _showSwipeFeedback('Liked!', AppTheme.successGreen, Icons.favorite);
      setState(() => _todayLikes++);
    } else if (direction == CardSwiperDirection.top) {
      swipeType = 'SUPER_LIKE';
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
        _showMatchDialog(user);
      }
    } catch (e) {
      _showErrorSnackBar('Swipe failed. Please try again.');
    }

    setState(() => _currentCardIndex = index + 1);
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

  void _showMatchDialog(User user) {
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(match: user),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildDailyStats(),
              Expanded(child: _buildCardStack()),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HeaderButton(
              icon: Icons.person_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'TRISH',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            _HeaderButton(
              icon: Icons.chat_bubble_outline,
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
              onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
            ),
            _SwipeButton(
              icon: Icons.star,
              color: AppTheme.accentBlue,
              size: 55,
              onPressed: () => _swiperController.swipe(CardSwiperDirection.top),
            ),
            _SwipeButton(
              icon: Icons.favorite,
              color: AppTheme.successGreen,
              size: 65,
              onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
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
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: AppTheme.textPrimary),
            onPressed: onPressed,
            iconSize: 26,
          ),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
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
      decoration: AppTheme.glassmorphicDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
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
