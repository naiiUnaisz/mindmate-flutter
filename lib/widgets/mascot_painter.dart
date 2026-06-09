import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the MindMate kawaii mascot character.
///
/// Draws the character exactly matching the design:
/// - One big round purple body (sphere-like)
/// - Large white/cream face area (visor) in the center
/// - Two small black oval eyes with white shine
/// - Open happy mouth (D-shape) with pink tongue
/// - Pink rosy cheeks
/// - Antenna on top with dark purple circle + puzzle icon
/// - Left arm raised (waving), right arm out to side
/// - Two short stubby legs
class MascotPainter extends CustomPainter {
  final double blinkProgress; // 0.0 = eyes open, 1.0 = eyes closed
  final bool waveArm; // true = left arm raised waving

  MascotPainter({this.blinkProgress = 0.0, this.waveArm = true});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 220; // Base design width = 220

    // ── Colors ──
    const bodyPurple = Color(0xFFB39DDB); // Main body purple
    const bodyPurpleDark = Color(0xFF9575CD); // Darker purple for depth
    const bodyPurpleLight = Color(0xFFD1C4E9); // Light purple highlight
    const faceWhite = Color(0xFFFFF8F0); // Warm white face area
    const eyeBlack = Color(0xFF2D1B4E); // Very dark for eyes
    const mouthDark = Color(0xFF4A148C); // Dark purple mouth
    const tongueColor = Color(0xFFE57373); // Pink-red tongue
    const cheekPink = Color(0xFFF8BBD0); // Soft pink cheeks
    const antennaDark = Color(0xFF7E57C2); // Antenna circle
    const puzzleWhite = Color(0xFFE8E0F0); // Puzzle icon color

    // ═══════════════════════════════════════════════════
    // LEGS (drawn first, behind the body)
    // ═══════════════════════════════════════════════════

    // Left leg
    final leftLegPath = Path();
    leftLegPath.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(cx - 28 * s, cy + 88 * s),
          width: 30 * s,
          height: 40 * s,
        ),
        topLeft: Radius.circular(8 * s),
        topRight: Radius.circular(8 * s),
        bottomLeft: Radius.circular(14 * s),
        bottomRight: Radius.circular(14 * s),
      ),
    );
    canvas.drawPath(leftLegPath, Paint()..color = bodyPurpleDark);

    // Right leg
    final rightLegPath = Path();
    rightLegPath.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(cx + 28 * s, cy + 88 * s),
          width: 30 * s,
          height: 40 * s,
        ),
        topLeft: Radius.circular(8 * s),
        topRight: Radius.circular(8 * s),
        bottomLeft: Radius.circular(14 * s),
        bottomRight: Radius.circular(14 * s),
      ),
    );
    canvas.drawPath(rightLegPath, Paint()..color = bodyPurpleDark);

    // ═══════════════════════════════════════════════════
    // ARMS (behind the body too, except the waving one)
    // ═══════════════════════════════════════════════════

    // Right arm (behind body, extending right and slightly down)
    _drawArm(
      canvas,
      startX: cx + 68 * s,
      startY: cy + 10 * s,
      endX: cx + 95 * s,
      endY: cy + 30 * s,
      handX: cx + 98 * s,
      handY: cy + 32 * s,
      thickness: 22 * s,
      handRadius: 14 * s,
      color: bodyPurple,
      s: s,
    );

    // ═══════════════════════════════════════════════════
    // MAIN BODY (one big round circle)
    // ═══════════════════════════════════════════════════

    final bodyCenter = Offset(cx, cy);
    final bodyRadius = 72 * s;

    // Body shadow
    canvas.drawCircle(
      Offset(cx + 2 * s, cy + 4 * s),
      bodyRadius + 2 * s,
      Paint()
        ..color = bodyPurpleDark.withValues(alpha: 0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * s),
    );

    // Body gradient
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 1.1,
        colors: [bodyPurpleLight, bodyPurple, bodyPurpleDark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: bodyCenter, radius: bodyRadius));
    canvas.drawCircle(bodyCenter, bodyRadius, bodyPaint);

    // ═══════════════════════════════════════════════════
    // FACE AREA (large white oval "visor" in center)
    // ═══════════════════════════════════════════════════

    final faceCenter = Offset(cx, cy + 5 * s);
    final faceWidth = 92 * s;
    final faceHeight = 72 * s;

    // Face area shadow (subtle inner glow)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy + 1 * s),
        width: faceWidth + 2 * s,
        height: faceHeight + 2 * s,
      ),
      Paint()
        ..color = bodyPurpleDark.withValues(alpha: 0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * s),
    );

    // Face area fill
    final facePaint = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.1, -0.2),
            radius: 1.0,
            colors: [Colors.white, faceWhite, const Color(0xFFFCF0E8)],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCenter(
              center: faceCenter,
              width: faceWidth,
              height: faceHeight,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(center: faceCenter, width: faceWidth, height: faceHeight),
      facePaint,
    );

    // ═══════════════════════════════════════════════════
    // EYES
    // ═══════════════════════════════════════════════════

    final eyeY = cy + 2 * s;
    final leftEyeX = cx - 18 * s;
    final rightEyeX = cx + 18 * s;
    final eyeWidth = 11 * s;
    final eyeHeight = 13 * s;
    final eyeOpenHeight = max(0.0, 1.0 - blinkProgress);

    // Left eye
    if (eyeOpenHeight > 0.05) {
      canvas.save();
      canvas.clipRect(
        Rect.fromCenter(
          center: Offset(leftEyeX, eyeY),
          width: eyeWidth * 2,
          height: eyeHeight * eyeOpenHeight * 2,
        ),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(leftEyeX, eyeY),
          width: eyeWidth,
          height: eyeHeight,
        ),
        Paint()..color = eyeBlack,
      );
      // Eye shine (top-left highlight)
      canvas.drawCircle(
        Offset(leftEyeX + 2.5 * s, eyeY - 3 * s),
        2.5 * s,
        Paint()..color = Colors.white,
      );
      canvas.restore();
    } else {
      // Closed eye line
      canvas.drawLine(
        Offset(leftEyeX - 6 * s, eyeY),
        Offset(leftEyeX + 6 * s, eyeY),
        Paint()
          ..color = eyeBlack
          ..strokeWidth = 2.5 * s
          ..strokeCap = StrokeCap.round,
      );
    }

    // Right eye
    if (eyeOpenHeight > 0.05) {
      canvas.save();
      canvas.clipRect(
        Rect.fromCenter(
          center: Offset(rightEyeX, eyeY),
          width: eyeWidth * 2,
          height: eyeHeight * eyeOpenHeight * 2,
        ),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rightEyeX, eyeY),
          width: eyeWidth,
          height: eyeHeight,
        ),
        Paint()..color = eyeBlack,
      );
      // Eye shine
      canvas.drawCircle(
        Offset(rightEyeX + 2.5 * s, eyeY - 3 * s),
        2.5 * s,
        Paint()..color = Colors.white,
      );
      canvas.restore();
    } else {
      canvas.drawLine(
        Offset(rightEyeX - 6 * s, eyeY),
        Offset(rightEyeX + 6 * s, eyeY),
        Paint()
          ..color = eyeBlack
          ..strokeWidth = 2.5 * s
          ..strokeCap = StrokeCap.round,
      );
    }

    // ═══════════════════════════════════════════════════
    // MOUTH (open happy "D" shape with tongue)
    // ═══════════════════════════════════════════════════

    final mouthCenterX = cx;
    final mouthCenterY = cy + 18 * s;
    final mouthWidth = 20 * s;
    final mouthHeight = 14 * s;

    // Mouth background (dark)
    final mouthPath = Path();
    mouthPath.moveTo(mouthCenterX - mouthWidth / 2, mouthCenterY - 2 * s);
    mouthPath.quadraticBezierTo(
      mouthCenterX - mouthWidth / 2,
      mouthCenterY - 4 * s,
      mouthCenterX,
      mouthCenterY - 4 * s,
    );
    mouthPath.quadraticBezierTo(
      mouthCenterX + mouthWidth / 2,
      mouthCenterY - 4 * s,
      mouthCenterX + mouthWidth / 2,
      mouthCenterY - 2 * s,
    );
    mouthPath.quadraticBezierTo(
      mouthCenterX + mouthWidth / 2,
      mouthCenterY + mouthHeight,
      mouthCenterX,
      mouthCenterY + mouthHeight,
    );
    mouthPath.quadraticBezierTo(
      mouthCenterX - mouthWidth / 2,
      mouthCenterY + mouthHeight,
      mouthCenterX - mouthWidth / 2,
      mouthCenterY - 2 * s,
    );
    mouthPath.close();

    canvas.drawPath(mouthPath, Paint()..color = mouthDark);

    // Tongue (small pink semicircle at bottom of mouth)
    final tonguePath = Path();
    tonguePath.addOval(
      Rect.fromCenter(
        center: Offset(mouthCenterX, mouthCenterY + mouthHeight - 4 * s),
        width: mouthWidth * 0.55,
        height: mouthHeight * 0.5,
      ),
    );
    canvas.save();
    canvas.clipPath(mouthPath);
    canvas.drawPath(tonguePath, Paint()..color = tongueColor);
    canvas.restore();

    // ═══════════════════════════════════════════════════
    // CHEEKS (pink rosy circles)
    // ═══════════════════════════════════════════════════

    // Left cheek
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 35 * s, cy + 14 * s),
        width: 18 * s,
        height: 12 * s,
      ),
      Paint()..color = cheekPink.withValues(alpha: 0.7),
    );

    // Right cheek
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 35 * s, cy + 14 * s),
        width: 18 * s,
        height: 12 * s,
      ),
      Paint()..color = cheekPink.withValues(alpha: 0.7),
    );

    // ═══════════════════════════════════════════════════
    // LEFT ARM (waving, in front of body)
    // ═══════════════════════════════════════════════════

    if (waveArm) {
      // Raised waving arm
      _drawArm(
        canvas,
        startX: cx - 65 * s,
        startY: cy - 10 * s,
        endX: cx - 88 * s,
        endY: cy - 35 * s,
        handX: cx - 90 * s,
        handY: cy - 38 * s,
        thickness: 22 * s,
        handRadius: 14 * s,
        color: bodyPurple,
        s: s,
      );
    } else {
      // Resting arm
      _drawArm(
        canvas,
        startX: cx - 68 * s,
        startY: cy + 10 * s,
        endX: cx - 95 * s,
        endY: cy + 30 * s,
        handX: cx - 98 * s,
        handY: cy + 32 * s,
        thickness: 22 * s,
        handRadius: 14 * s,
        color: bodyPurple,
        s: s,
      );
    }

    // ═══════════════════════════════════════════════════
    // ANTENNA (stick + dark purple circle with puzzle)
    // ═══════════════════════════════════════════════════

    final antennaBaseY = cy - bodyRadius + 2 * s;
    final antennaBallY = cy - bodyRadius - 22 * s;
    final antennaBallRadius = 14 * s;

    // Antenna stick
    canvas.drawLine(
      Offset(cx + 5 * s, antennaBaseY),
      Offset(cx + 5 * s, antennaBallY + antennaBallRadius - 2 * s),
      Paint()
        ..color = bodyPurpleDark
        ..strokeWidth = 3.5 * s
        ..strokeCap = StrokeCap.round,
    );

    // Antenna ball (dark purple circle)
    final antennaBallCenter = Offset(cx + 5 * s, antennaBallY);
    canvas.drawCircle(
      antennaBallCenter,
      antennaBallRadius,
      Paint()..color = antennaDark,
    );

    // Puzzle piece icon inside antenna ball
    _drawPuzzleIcon(
      canvas,
      antennaBallCenter,
      antennaBallRadius * 0.55,
      puzzleWhite,
      s,
    );

    // ── Subtle body highlight (top-left) ──
    canvas.drawCircle(
      Offset(cx - 20 * s, cy - 25 * s),
      8 * s,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * s),
    );
  }

  /// Draws a stubby arm with a round hand.
  void _drawArm(
    Canvas canvas, {
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required double handX,
    required double handY,
    required double thickness,
    required double handRadius,
    required Color color,
    required double s,
  }) {
    // Arm body (thick rounded stroke)
    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      Paint()
        ..color = color
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round,
    );

    // Hand (round circle at end)
    canvas.drawCircle(Offset(handX, handY), handRadius, Paint()..color = color);
  }

  /// Draws a simple puzzle piece icon.
  void _drawPuzzleIcon(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    double s,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Main cross shape of puzzle piece
    final path = Path();

    // Center square
    final halfSize = size * 0.45;
    path.addRect(
      Rect.fromCenter(
        center: center,
        width: halfSize * 2,
        height: halfSize * 2,
      ),
    );

    // Top nub
    path.addOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - halfSize),
        width: halfSize * 0.8,
        height: halfSize * 0.8,
      ),
    );

    // Right nub
    path.addOval(
      Rect.fromCenter(
        center: Offset(center.dx + halfSize, center.dy),
        width: halfSize * 0.8,
        height: halfSize * 0.8,
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MascotPainter oldDelegate) {
    return oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.waveArm != waveArm;
  }
}

/// Draws only the kawaii face (eyes + cheeks + mouth) without the body.
/// Used for the initial splash animation phases.
class KawaiiFacePainter extends CustomPainter {
  final double blinkProgress; // 0.0 = open, 1.0 = closed
  final bool isWinking; // If true, only right eye blinks

  KawaiiFacePainter({this.blinkProgress = 0.0, this.isWinking = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 120; // Base design is 120 wide

    const eyeColor = Color(0xFF2D1B4E);
    const cheekColor = Color(0xFFF8BBD0);
    const mouthDark = Color(0xFF4A148C);
    const tongueColor = Color(0xFFE57373);

    final leftEyeHeight = max(0.0, 1.0 - (isWinking ? 0.0 : blinkProgress));
    final rightEyeHeight = max(0.0, 1.0 - blinkProgress);

    // ── Left Eye ──
    if (leftEyeHeight > 0.05) {
      canvas.save();
      canvas.clipRect(
        Rect.fromCenter(
          center: Offset(cx - 22 * s, cy - 8 * s),
          width: 20 * s,
          height: 22 * s * leftEyeHeight,
        ),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - 22 * s, cy - 8 * s),
          width: 14 * s,
          height: 17 * s,
        ),
        Paint()..color = eyeColor,
      );
      // Eye shine
      canvas.drawCircle(
        Offset(cx - 19 * s, cy - 13 * s),
        3 * s,
        Paint()..color = Colors.white,
      );
      canvas.restore();
    } else {
      canvas.drawLine(
        Offset(cx - 30 * s, cy - 8 * s),
        Offset(cx - 14 * s, cy - 8 * s),
        Paint()
          ..color = eyeColor
          ..strokeWidth = 3 * s
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Right Eye ──
    if (rightEyeHeight > 0.05) {
      canvas.save();
      canvas.clipRect(
        Rect.fromCenter(
          center: Offset(cx + 22 * s, cy - 8 * s),
          width: 20 * s,
          height: 22 * s * rightEyeHeight,
        ),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + 22 * s, cy - 8 * s),
          width: 14 * s,
          height: 17 * s,
        ),
        Paint()..color = eyeColor,
      );
      // Eye shine
      canvas.drawCircle(
        Offset(cx + 25 * s, cy - 13 * s),
        3 * s,
        Paint()..color = Colors.white,
      );
      canvas.restore();
    } else {
      if (isWinking) {
        final winkPath = Path()
          ..moveTo(cx + 14 * s, cy - 14 * s)
          ..lineTo(cx + 24 * s, cy - 8 * s)
          ..lineTo(cx + 14 * s, cy - 2 * s);
        canvas.drawPath(
          winkPath,
          Paint()
            ..color = eyeColor
            ..strokeWidth = 2.5 * s
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawLine(
          Offset(cx + 14 * s, cy - 8 * s),
          Offset(cx + 30 * s, cy - 8 * s),
          Paint()
            ..color = eyeColor
            ..strokeWidth = 3 * s
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // ── Open mouth (D-shape with tongue) ──
    final mouthCX = cx;
    final mouthCY = cy + 10 * s;
    final mouthW = 16 * s;
    final mouthH = 10 * s;

    final mouthPath = Path();
    mouthPath.moveTo(mouthCX - mouthW / 2, mouthCY - 2 * s);
    mouthPath.quadraticBezierTo(
      mouthCX - mouthW / 2,
      mouthCY - 3 * s,
      mouthCX,
      mouthCY - 3 * s,
    );
    mouthPath.quadraticBezierTo(
      mouthCX + mouthW / 2,
      mouthCY - 3 * s,
      mouthCX + mouthW / 2,
      mouthCY - 2 * s,
    );
    mouthPath.quadraticBezierTo(
      mouthCX + mouthW / 2,
      mouthCY + mouthH,
      mouthCX,
      mouthCY + mouthH,
    );
    mouthPath.quadraticBezierTo(
      mouthCX - mouthW / 2,
      mouthCY + mouthH,
      mouthCX - mouthW / 2,
      mouthCY - 2 * s,
    );
    mouthPath.close();
    canvas.drawPath(mouthPath, Paint()..color = mouthDark);

    // Tongue
    canvas.save();
    canvas.clipPath(mouthPath);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(mouthCX, mouthCY + mouthH - 3 * s),
        width: mouthW * 0.5,
        height: mouthH * 0.5,
      ),
      Paint()..color = tongueColor,
    );
    canvas.restore();

    // ── Cheeks ──
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 40 * s, cy + 4 * s),
        width: 18 * s,
        height: 12 * s,
      ),
      Paint()..color = cheekColor.withValues(alpha: 0.65),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 40 * s, cy + 4 * s),
        width: 18 * s,
        height: 12 * s,
      ),
      Paint()..color = cheekColor.withValues(alpha: 0.65),
    );
  }

  @override
  bool shouldRepaint(covariant KawaiiFacePainter oldDelegate) {
    return oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.isWinking != isWinking;
  }
}
