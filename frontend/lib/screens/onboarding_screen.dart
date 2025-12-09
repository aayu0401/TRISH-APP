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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _navigateToLogin(),
                    child: const Text('Skip'),
                  ),
                ),
              ),
              
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),
              
              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
              ),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _currentPage == _pages.length - 1
                    ? Column(
                        children: [
                          FadeInUp(
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _navigateToRegister(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: AppTheme.mediumRadius,
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: TextButton(
                              onPressed: () => _navigateToLogin(),
                              child: const Text('Already have an account? Sign In'),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: AppTheme.mediumRadius,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            delay: Duration(milliseconds: 200 * index),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: page.gradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow,
              ),
              child: Icon(
                page.icon,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            delay: Duration(milliseconds: 400 * index),
            child: Text(
              page.title,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: Duration(milliseconds: 600 * index),
            child: Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
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
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        gradient: isActive ? AppTheme.primaryGradient : null,
        color: isActive ? null : AppTheme.textTertiary,
        borderRadius: BorderRadius.circular(4),
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
