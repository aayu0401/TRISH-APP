import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/match_service.dart';
import '../services/auth_service.dart';
import '../config.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _matchService = MatchService();
  final _authService = AuthService();
  List<User> _recommendations = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recommendations: $e')),
        );
      }
    }
  }

  Future<void> _handleSwipe(int index, CardSwiperDirection direction) async {
    if (index >= _recommendations.length) return;

    final user = _recommendations[index];
    String swipeType = 'PASS';

    if (direction == CardSwiperDirection.right) {
      swipeType = 'LIKE';
    } else if (direction == CardSwiperDirection.top) {
      swipeType = 'SUPER_LIKE';
    }

    try {
      final result = await _matchService.swipe(
        targetUserId: user.id!,
        swipeType: swipeType,
      );

      if (result['matched'] == true && mounted) {
        _showMatchDialog(user);
      }
    } catch (e) {
      print('Swipe error: $e');
    }
  }

  void _showMatchDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You and ${user.name} liked each other',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryPink,
                ),
                child: const Text('Continue Swiping'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBackground, AppTheme.cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person, color: AppTheme.primaryPink, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'TRISH',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat, color: AppTheme.primaryPink, size: 30),
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

              // Card Stack
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _recommendations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 80, color: AppTheme.textSecondary),
                                const SizedBox(height: 20),
                                Text(
                                  'No more profiles',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Check back later for new matches',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : CardSwiper(
                            cardsCount: _recommendations.length,
                            onSwipe: _handleSwipe,
                            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                              return _ProfileCard(user: _recommendations[index]);
                            },
                          ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onPressed: () {},
                    ),
                    _ActionButton(
                      icon: Icons.star,
                      color: Colors.blue,
                      size: 70,
                      onPressed: () {},
                    ),
                    _ActionButton(
                      icon: Icons.favorite,
                      color: Colors.green,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final User user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            user.photos.isNotEmpty
                ? Image.network(
                    '$API_URL${user.photos.first.url}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.cardBackground,
                        child: const Icon(Icons.person, size: 100, color: AppTheme.textSecondary),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.cardBackground,
                    child: const Icon(Icons.person, size: 100, color: AppTheme.textSecondary),
                  ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // User Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${user.age}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (user.bio != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        user.bio!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (user.interests.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.interests.take(5).map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPink.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }
}
