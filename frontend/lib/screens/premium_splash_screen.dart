import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;

class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({Key? key}) : super(key: key);

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle());
    }

    // Start animations
    _logoController.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _particleController,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Logo and text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFff6b9d),
                                  Color(0xFFc06c84),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFff6b9d).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // App name
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFff6b9d),
                          Color(0xFFfeca57),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'TRISH',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      'Find Your Perfect Match',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Loading indicator
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFff6b9d),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late Color color;

  Particle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    vx = (random.nextDouble() - 0.5) * 0.002;
    vy = (random.nextDouble() - 0.5) * 0.002;
    size = random.nextDouble() * 3 + 1;
    color = Color.fromRGBO(
      255,
      random.nextInt(100) + 100,
      random.nextInt(100) + 150,
      random.nextDouble() * 0.5 + 0.3,
    );
  }

  void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx *= -1;
    if (y < 0 || y > 1) vy *= -1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
