
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrishLogo extends StatelessWidget {
  final double size;
  final bool isLight;

  const TrishLogo({
    super.key, 
    this.size = 40,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: EdgeInsets.all(size * 0.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF80AB), Color(0xFFFF4081)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4081).withOpacity(0.4),
                blurRadius: size * 0.4,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            color: Colors.white,
            size: size * 0.8,
          ),
        ),
        SizedBox(width: size * 0.3),
        // Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          ).createShader(bounds),
          child: Text(
            'TRISH',
            style: GoogleFonts.nunito( // Rounded, friendly, yet premium
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: Colors.white, // Required for ShaderMask
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
