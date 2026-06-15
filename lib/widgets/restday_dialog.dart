import 'package:flutter/material.dart';
import 'dart:math' as math;

Future<bool?> showRestDayDialog(BuildContext context, {int restDayRemaining = 0}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _RestDayDialog(restDayRemaining: restDayRemaining),
  );
}

class _RestDayDialog extends StatelessWidget {
  final int restDayRemaining;
  const _RestDayDialog({this.restDayRemaining = 0});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 80),
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFE8DFFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rest Day',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to take a Rest Day?\nYour streak will stay safe!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rest Days Left: $restDayRemaining',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: restDayRemaining > 0
                        ? Color(0xFF6B7280)
                        : Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Yakin button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: restDayRemaining > 0
                        ? () => Navigator.pop(context, true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: restDayRemaining > 0
                          ? const Color(0xFF7658B2)
                          : const Color(0xFFD1D5DB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      restDayRemaining > 0 ? 'Confirm' : 'None Left',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 96,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF7658B2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Sleepy Mascot
          Positioned(
            top: 0,
            child: SizedBox(
              width: 180,
              height: 160,
              child: Image.asset(
                'assets/maskot/down_face_2.png',
                width: 180,
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => CustomPaint(
                  painter: _RestDayMascotPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = const Color(0xFFB78AF7);
    final faceColor = const Color(0xFFFFE4E6);

    final slitY = h * 0.85;

    // Confetti (soft, sleepy stars)
    final random = math.Random(42);
    for (int i = 0; i < 10; i++) {
      final cx = w * 0.5 + (random.nextDouble() - 0.5) * w * 1.5;
      final cy = slitY - (random.nextDouble() * h * 0.9);
      final colorOptions = [
        const Color(0xFFC4B5FD),
        const Color(0xFFF472B6),
        const Color(0xFF8B5CF6),
      ];
      final color = colorOptions[random.nextInt(colorOptions.length)];
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(random.nextDouble() * math.pi);
      canvas.drawCircle(Offset.zero, 4 + random.nextDouble() * 4, Paint()..color = color);
      canvas.restore();
    }

    // Slit
    final slitRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w/2, slitY), width: w * 0.7, height: h * 0.1),
      const Radius.circular(20),
    );
    canvas.drawRRect(slitRect, Paint()..color = const Color(0xFFD8B4E2));

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, slitY));

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.2, slitY)
      ..cubicTo(w * 0.1, slitY * 0.4, w * 0.2, h * 0.2, w * 0.5, h * 0.2)
      ..cubicTo(w * 0.8, h * 0.2, w * 0.9, slitY * 0.4, w * 0.8, slitY)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = primaryColor);

    // Arms (resting/sleepy, holding a pillow-like shape)
    final armPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final leftArm = Path()
      ..moveTo(w * 0.25, slitY * 0.9)
      ..quadraticBezierTo(w * 0.1, slitY * 0.85, w * 0.08, slitY * 0.9);
    canvas.drawPath(leftArm, armPaint);

    final rightArm = Path()
      ..moveTo(w * 0.75, slitY * 0.9)
      ..quadraticBezierTo(w * 0.9, slitY * 0.85, w * 0.92, slitY * 0.9);
    canvas.drawPath(rightArm, armPaint);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.6),
      width: w * 0.55,
      height: h * 0.4,
    );
    canvas.drawOval(faceRect, Paint()..color = faceColor);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFA6D9);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.33, h * 0.65), width: w * 0.12, height: h * 0.08), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.67, h * 0.65), width: w * 0.12, height: h * 0.08), cheekPaint);

    // Sleepy eyes (closed curves)
    final eyePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final leftEye = Path()
      ..moveTo(w * 0.35, h * 0.58)
      ..quadraticBezierTo(w * 0.4, h * 0.62, w * 0.45, h * 0.58);
    canvas.drawPath(leftEye, eyePaint);

    final rightEye = Path()
      ..moveTo(w * 0.55, h * 0.58)
      ..quadraticBezierTo(w * 0.6, h * 0.62, w * 0.65, h * 0.58);
    canvas.drawPath(rightEye, eyePaint);

    // Small sleepy mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(w * 0.46, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.54, h * 0.72);
    canvas.drawPath(mouth, mouthPaint);

    canvas.restore();

    // Front lip of slit
    final frontSlit = Path()
      ..moveTo(w * 0.15, slitY)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.04, w * 0.85, slitY)
      ..lineTo(w * 0.85, slitY + h * 0.03)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.07, w * 0.15, slitY + h * 0.03)
      ..close();
    canvas.drawPath(frontSlit, Paint()..color = primaryColor.withValues(alpha: 0.8));

    // Z badge above head
    final badgeCenter = Offset(w * 0.65, h * 0.15);
    canvas.drawCircle(badgeCenter, w * 0.08, Paint()..color = const Color(0xFF8B5CF6));
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: w * 0.12,
      fontWeight: FontWeight.bold,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: 'z', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      badgeCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
