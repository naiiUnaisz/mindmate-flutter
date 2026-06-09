import 'package:flutter/material.dart';

/// A simple gold coin widget with a subtle 3D effect.
/// Used in the onboarding page 2 illustration.
class CoinWidget extends StatelessWidget {
  final double size;

  const CoinWidget({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [
            Color(0xFFFFF176), // Light gold
            Color(0xFFFFD54F), // Gold
            Color(0xFFF9A825), // Dark gold
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF9A825),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '¢',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF57F17),
          ),
        ),
      ),
    );
  }
}
