import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'AI-Powered Matching',
      description: 'Our advanced AI analyzes your personality and preferences to find your perfect match',
      icon: Icons.psychology,
      gradient: AppTheme.primaryGradient,
    ),
    OnboardingPage(
      title: 'Verified & Safe',
      description: 'Full KYC verification ensures you connect with real, genuine people',
      icon: Icons.verified_user,
      gradient: AppTheme.blueGradient,
    ),
    OnboardingPage(
      title: 'Send Gifts',
      description: 'Express your feelings with virtual and real gifts delivered to your matches',
      icon: Icons.card_giftcard,
      gradient: AppTheme.accentGradient,
    ),
    OnboardingPage(
      title: 'Smart Conversations',
      description: 'Get AI-powered icebreakers and conversation suggestions',
      icon: Icons.chat_bubble_outline,
      gradient: AppTheme.goldGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1518196775791-3e9cc78222ca?w=1600',
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
                    AppTheme.darkBackground.withOpacity(0.5),
                    AppTheme.darkBackground.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(
                AppTheme.darkBackground.withOpacity(0.2),
                BlendMode.darken,
              ),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Branding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'TRISH',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          children: [
                            TextSpan(
                              text: ' ELITE',
                              style: TextStyle(color: AppTheme.primaryPink),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _navigateToLogin(),
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _buildPage(_pages[index], index),
                  ),
                ),
                
                // Bottom Section
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildIndicator(index == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      if (_currentPage == _pages.length - 1)
                        Column(
                          children: [
                            FadeInUp(
                              child: _buildPrimaryButton(
                                'Begin Neural Journey',
                                () => _navigateToRegister(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInUp(
                              delay: const Duration(milliseconds: 100),
                              child: TextButton(
                                onPressed: () => _navigateToLogin(),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Already a member? ',
                                    style: TextStyle(color: Colors.white54),
                                    children: [
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        _buildPrimaryButton(
                          'Next Protocol',
                          () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.fastOutSlowIn,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: AppTheme.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.mediumRadius,
            ),
          ),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: page.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (page.gradient as LinearGradient).colors[0].withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(page.icon, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              page.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 32 : 12,
      decoration: BoxDecoration(
        gradient: isActive ? AppTheme.primaryGradient : null,
        color: isActive ? null : Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
