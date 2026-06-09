import 'dart:math';
import 'package:flutter/material.dart';

/// Draws decorative sparkle/star shapes around a given area.
/// Used for the onboarding page 1 illustration.
class SparklePainter extends CustomPainter {
  final double animationValue; // 0.0 – 1.0 for shimmer/pulse

  SparklePainter({this.animationValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final sparkleColor = const Color(0xFFFFD54F); // Gold/yellow
    final sparkleColorLight = const Color(0xFFFFF176);

    // Define sparkle positions (relative to size)
    final sparkles = [
      _SparkleData(0.12, 0.25, 18, 0.0),
      _SparkleData(0.08, 0.45, 12, 0.3),
      _SparkleData(0.22, 0.15, 10, 0.6),
      _SparkleData(0.85, 0.20, 16, 0.2),
      _SparkleData(0.92, 0.40, 11, 0.5),
      _SparkleData(0.78, 0.10, 8, 0.8),
      _SparkleData(0.88, 0.55, 9, 0.4),
    ];

    for (final sparkle in sparkles) {
      final phaseOffset = sparkle.phase;
      final pulseValue = ((animationValue + phaseOffset) % 1.0);
      final scale = 0.6 + 0.4 * sin(pulseValue * pi);
      final opacity = 0.5 + 0.5 * sin(pulseValue * pi);

      final x = size.width * sparkle.relX;
      final y = size.height * sparkle.relY;
      final baseSize = sparkle.size * scale;

      _drawFourPointStar(
        canvas,
        Offset(x, y),
        baseSize,
        sparkleColor.withValues(alpha: opacity),
        sparkleColorLight.withValues(alpha: opacity * 0.6),
      );
    }
  }

  void _drawFourPointStar(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    Color glowColor,
  ) {
    // Draw glow
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.3);
    canvas.drawCircle(center, size * 0.4, glowPaint);

    // Draw four-point star
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Vertical spike
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx + size * 0.15, center.dy - size * 0.15,
        center.dx + size * 0.5, center.dy);
    path.quadraticBezierTo(center.dx + size * 0.15, center.dy + size * 0.15,
        center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx - size * 0.15, center.dy + size * 0.15,
        center.dx - size * 0.5, center.dy);
    path.quadraticBezierTo(center.dx - size * 0.15, center.dy - size * 0.15,
        center.dx, center.dy - size);
    path.close();

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _SparkleData {
  final double relX;
  final double relY;
  final double size;
  final double phase;

  _SparkleData(this.relX, this.relY, this.size, this.phase);
}
