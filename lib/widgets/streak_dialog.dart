import 'package:flutter/material.dart';
import 'dart:math' as math;

Future<void> showStreakDialog(BuildContext context, {int streakCount = 1}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _StreakDialog(streakCount: streakCount),
  );
}

class _StreakDialog extends StatelessWidget {
  final int streakCount;
  const _StreakDialog({this.streakCount = 1});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.height < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isSmall ? 16 : 32,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              maxWidth: constraints.maxWidth,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main card
                Container(
                  margin: EdgeInsets.only(top: isSmall ? 60 : 80),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    isSmall ? 50 : 70,
                    24,
                    24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        streakCount > 1
                            ? 'Streak: $streakCount Days!'
                            : 'First Step!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        streakCount > 1
                            ? 'Amazing! $streakCount days streak!\nKeep the momentum going!'
                            : "You've started your streak today.\nLet's keep it going!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmall ? 13 : 14,
                          color: const Color(0xFF7C3AED),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Streak Tracker Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStreakDay(day: 'Mon', isActive: true, label: 'Today'),
                            _buildStreakDay(day: 'Tue', isActive: false, label: 'Day 2'),
                            _buildStreakDay(day: 'Wed', isActive: false, label: 'Day 3'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Keep going button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7658B2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'Keep going',
                            style: TextStyle(
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
                  top: isSmall ? 76 : 96,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
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

                // Mascot
                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: isSmall ? 140 : 180,
                    height: isSmall ? 120 : 160,
                    child: CustomPaint(
                      painter: _StreakMascotPainter(),
                    ),
                  ),
                ),

                // Confetti Decoration
                Positioned(
                  top: isSmall ? 80 : 100,
                  left: 0,
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Container(
                      width: isSmall ? 10 : 15,
                      height: isSmall ? 4 : 6,
                      color: const Color(0xFFFCD34D),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  right: 0,
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: isSmall ? 10 : 15,
                      height: isSmall ? 4 : 6,
                      color: const Color(0xFFFCD34D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakDay({required String day, required bool isActive, required String label}) {
    return Flexible(
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isActive)
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6D28D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFBBF24),
                      size: 24,
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC4B5FD),
                      width: 2,
                    ),
                  ),
                ),

              if (isActive) ...[
                Positioned(
                  top: -3,
                  left: -3,
                  child: const Icon(Icons.star, color: Color(0xFFFCD34D), size: 8),
                ),
                Positioned(
                  bottom: 3,
                  left: -6,
                  child: const Icon(Icons.star, color: Color(0xFFFCD34D), size: 10),
                ),
                Positioned(
                  bottom: 10,
                  right: -6,
                  child: const Icon(Icons.star, color: Color(0xFFFCD34D), size: 8),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF3E8FF) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = const Color(0xFFB78AF7);
    final faceColor = const Color(0xFFFFE4E6);
    
    final slitY = h * 0.85;

    // Confetti
    final random = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final cx = w * 0.5 + (random.nextDouble() - 0.5) * w * 1.5;
      final cy = slitY - (random.nextDouble() * h * 0.9);
      
      final colorOptions = [
        const Color(0xFFFCD34D), // Yellow
        const Color(0xFFF472B6), // Pink
        const Color(0xFF7C3AED), // Purple
      ];
      final color = colorOptions[random.nextInt(colorOptions.length)];
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(random.nextDouble() * math.pi);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 12, height: 6), Paint()..color = color);
      canvas.restore();
    }
    
    // Slit
    final slitRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w/2, slitY), width: w * 0.7, height: h * 0.1),
      const Radius.circular(20),
    );
    canvas.drawRRect(slitRect, Paint()..color = const Color(0xFFD8B4E2)); // Shadow color under mascot

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, slitY));

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.2, slitY)
      ..cubicTo(w * 0.1, slitY * 0.4, w * 0.2, h * 0.2, w * 0.5, h * 0.2)
      ..cubicTo(w * 0.8, h * 0.2, w * 0.9, slitY * 0.4, w * 0.8, slitY)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = primaryColor);

    // Left Arm (waving)
    final leftArm = Path()
      ..moveTo(w * 0.25, slitY * 0.9)
      ..quadraticBezierTo(w * 0.05, slitY * 0.8, w * 0.05, slitY * 0.8);
    canvas.drawPath(leftArm, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.round);
    
    // Right Arm (holding flame)
    final rightArm = Path()
      ..moveTo(w * 0.75, slitY * 0.9)
      ..quadraticBezierTo(w * 0.95, slitY * 0.6, w * 0.85, slitY * 0.4);
    canvas.drawPath(rightArm, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.round);

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

    // Winking Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
      
    // Left eye (open)
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.4, h * 0.55), width: w * 0.06, height: h * 0.1), Paint()..color = const Color(0xFF1F2937));
    
    // Right eye (winking ^)
    final rightEye = Path()
      ..moveTo(w * 0.57, h * 0.58)
      ..quadraticBezierTo(w * 0.6, h * 0.53, w * 0.63, h * 0.58);
    canvas.drawPath(rightEye, eyePaint);

    // Happy mouth (open)
    final mouthPaint = Paint()..color = const Color(0xFF831843);
    final mouthPath = Path()
      ..moveTo(w * 0.45, h * 0.65)
      ..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.55, h * 0.65)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);
    
    // Tongue
    canvas.save();
    canvas.clipPath(mouthPath);
    canvas.drawCircle(Offset(w * 0.5, h * 0.72), w * 0.04, Paint()..color = const Color(0xFFF472B6));
    canvas.restore();

    // Draw Flame in right hand
    _drawFlame(canvas, Offset(w * 0.85, slitY * 0.3), w * 0.15);
    
    canvas.restore(); // Remove clipping

    // Front lip of slit
    final frontSlit = Path()
      ..moveTo(w * 0.15, slitY)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.04, w * 0.85, slitY)
      ..lineTo(w * 0.85, slitY + h * 0.03)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.07, w * 0.15, slitY + h * 0.03)
      ..close();
    canvas.drawPath(frontSlit, Paint()..color = primaryColor.withValues(alpha: 0.8));
    
    // Floating badge above head
    final badgeCenter = Offset(w * 0.65, h * 0.15);
    canvas.drawCircle(badgeCenter, w * 0.08, Paint()..color = const Color(0xFF8B5CF6));
    
    // Draw tiny puzzle piece inside badge
    final puzzlePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromCenter(center: badgeCenter, width: w * 0.06, height: w * 0.06), puzzlePaint);
    canvas.drawCircle(badgeCenter + Offset(0, -w * 0.03), w * 0.015, puzzlePaint);
    canvas.drawCircle(badgeCenter + Offset(-w * 0.03, 0), w * 0.015, puzzlePaint);
  }

  void _drawFlame(Canvas canvas, Offset center, double size) {
    // Outer flame (Orange)
    final outerFlame = Paint()..color = const Color(0xFFF97316);
    final outerPath = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx - size, center.dy + size * 0.5, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx + size, center.dy + size * 0.5, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(outerPath, outerFlame);

    // Inner flame (Yellow)
    final innerFlame = Paint()..color = const Color(0xFFFCD34D);
    final innerPath = Path()
      ..moveTo(center.dx, center.dy - size * 0.4)
      ..quadraticBezierTo(center.dx - size * 0.5, center.dy + size * 0.6, center.dx, center.dy + size * 0.8)
      ..quadraticBezierTo(center.dx + size * 0.5, center.dy + size * 0.6, center.dx, center.dy - size * 0.4)
      ..close();
    canvas.drawPath(innerPath, innerFlame);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
