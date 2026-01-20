import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;

class SwipeFeedbackWidget extends StatefulWidget {
  final String type; // 'like', 'pass', 'super_like'
  final VoidCallback onComplete;

  const SwipeFeedbackWidget({
    Key? key,
    required this.type,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<SwipeFeedbackWidget> createState() => _SwipeFeedbackWidgetState();
}

class _SwipeFeedbackWidgetState extends State<SwipeFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final List<HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Generate particles for super like
    if (widget.type == 'super_like') {
      for (int i = 0; i < 20; i++) {
        _particles.add(HeartParticle());
      }
    }

    // Haptic feedback
    if (widget.type == 'super_like') {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    _controller.forward().then((_) {
      widget.onComplete();
    });

    if (widget.type == 'super_like') {
      _particleController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case 'like':
        return const Color(0xFF4ade80);
      case 'pass':
        return const Color(0xFFef4444);
      case 'super_like':
        return const Color(0xFF3b82f6);
      default:
        return Colors.white;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case 'like':
        return Icons.favorite;
      case 'pass':
        return Icons.close;
      case 'super_like':
        return Icons.star;
      default:
        return Icons.favorite;
    }
  }

  String _getText() {
    switch (widget.type) {
      case 'like':
        return 'LIKE';
      case 'pass':
        return 'PASS';
      case 'super_like':
        return 'SUPER LIKE';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particles for super like
          if (widget.type == 'super_like')
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: HeartParticlePainter(
                    particles: _particles,
                    animation: _particleController,
                    color: _getColor(),
                  ),
                  size: const Size(300, 300),
                );
              },
            ),

          // Main feedback
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: _getColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getColor(),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getColor().withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIcon(),
                          size: 60,
                          color: _getColor(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getText(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getColor(),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HeartParticle {
  late double angle;
  late double distance;
  late double size;
  late double speed;

  HeartParticle() {
    final random = math.Random();
    angle = random.nextDouble() * 2 * math.pi;
    distance = 0;
    size = random.nextDouble() * 8 + 4;
    speed = random.nextDouble() * 100 + 50;
  }

  void update(double progress) {
    distance = progress * speed;
  }
}

class HeartParticlePainter extends CustomPainter {
  final List<HeartParticle> particles;
  final Animation<double> animation;
  final Color color;

  HeartParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      particle.update(animation.value);

      final x = center.dx + math.cos(particle.angle) * particle.distance;
      final y = center.dy + math.sin(particle.angle) * particle.distance;

      final paint = Paint()
        ..color = color.withOpacity(1 - animation.value)
        ..style = PaintingStyle.fill;

      // Draw heart shape
      final path = Path();
      final heartSize = particle.size;
      path.moveTo(x, y + heartSize / 4);
      path.cubicTo(
        x - heartSize / 2,
        y - heartSize / 4,
        x - heartSize,
        y + heartSize / 4,
        x,
        y + heartSize,
      );
      path.cubicTo(
        x + heartSize,
        y + heartSize / 4,
        x + heartSize / 2,
        y - heartSize / 4,
        x,
        y + heartSize / 4,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(HeartParticlePainter oldDelegate) => true;
}
