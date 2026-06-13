import 'package:flutter/material.dart';
import 'dart:math' as math;

void showRewardDialog(BuildContext context, {int coins = 10, bool showPuzzleReward = false, bool isStreak = false}) {
  showDialog(
    context: context,
    builder: (ctx) => _RewardDialog(coins: coins, showPuzzleReward: showPuzzleReward, isStreak: isStreak),
  );
}

class _RewardDialog extends StatelessWidget {
  final int coins;
  final bool showPuzzleReward;
  final bool isStreak;
  
  const _RewardDialog({required this.coins, this.showPuzzleReward = false, this.isStreak = false});

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
          // Main card
          Container(
            margin: const EdgeInsets.only(top: 80), // Space for mascot
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE5FB), // Light purple background
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isStreak ? 'Streak Reward!' : 'Yay! You got a reward!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isStreak 
                      ? "Incredible! You finished all your tasks today. Here are some bonus coins!" 
                      : "Great job! Keep it up and collect more reward!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Reward Card(s)
                if (showPuzzleReward && !isStreak)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Puzzle Card
                      _buildRewardCard(
                        title: '1 Clip Puzzle',
                        icon: Icons.image_rounded,
                        iconColor: const Color(0xFF60A5FA),
                        colors: const [Color(0xFFDBEAFE), Color(0xFF93C5FD)],
                      ),
                      const SizedBox(width: 16),
                      // Coin Card
                      _buildRewardCard(
                        title: '$coins Coins',
                        icon: Icons.extension_rounded,
                        iconColor: const Color(0xFFFEF08A),
                        colors: const [Color(0xFFFFD700), Color(0xFFF59E0B)],
                      ),
                    ],
                  )
                else
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      _buildRewardCard(
                        title: '$coins Coins',
                        icon: Icons.extension_rounded,
                        iconColor: const Color(0xFFFEF08A),
                        colors: const [Color(0xFFFFD700), Color(0xFFF59E0B)],
                      ),
                      
                      // Small floating confetti around the card
                      Positioned(
                        top: -10, left: -20,
                        child: Transform.rotate(
                          angle: -math.pi / 6,
                          child: Container(width: 12, height: 6, color: const Color(0xFFFCD34D)),
                        ),
                      ),
                      Positioned(
                        bottom: -15, right: -15,
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(width: 14, height: 6, color: const Color(0xFFFCD34D)),
                        ),
                      ),
                      Positioned(
                        bottom: 10, right: -25,
                        child: Transform.rotate(
                          angle: -math.pi / 8,
                          child: Container(width: 16, height: 6, color: const Color(0xFF7C3AED)),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 32),
                
                // Yey Button
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
                      'Yey!',
                      style: TextStyle(
                        fontSize: 18,
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

          // Happy Mascot
          Positioned(
            top: 0,
            child: SizedBox(
              width: 180,
              height: 160,
              child: CustomPaint(
                painter: _HappyMascotPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Color> colors,
  }) {
    return Container(
      width: 100, // Slightly smaller to fit two
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _HappyMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = const Color(0xFFB78AF7);
    final faceColor = const Color(0xFFFFE4E6);
    final darkPurple = const Color(0xFF8B5CF6);
    
    // Slit position
    final slitY = h * 0.85;

    // 1. Draw Confetti (behind mascot)
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final cx = w * 0.5 + (random.nextDouble() - 0.5) * w * 1.2;
      final cy = slitY - (random.nextDouble() * h * 0.8);
      
      final colorOptions = [
        const Color(0xFFFCD34D), // Yellow
        const Color(0xFFF472B6), // Pink
        const Color(0xFF7C3AED), // Purple
        const Color(0xFF60A5FA), // Blue
      ];
      final color = colorOptions[random.nextInt(colorOptions.length)];
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(random.nextDouble() * math.pi);
      
      if (random.nextBool()) {
        // Rectangle confetti
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 10, height: 5), Paint()..color = color);
      } else {
        // Star confetti
        _drawStar(canvas, Offset.zero, 6, Paint()..color = color);
      }
      canvas.restore();
    }
    
    // Background of the slit
    final slitRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w/2, slitY), width: w * 0.7, height: h * 0.1),
      const Radius.circular(20),
    );
    canvas.drawRRect(slitRect, Paint()..color = const Color(0xFFC4B5FD));

    // Save layer to clip mascot body
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, slitY));

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.2, slitY)
      ..cubicTo(w * 0.1, slitY * 0.4, w * 0.2, h * 0.3, w * 0.5, h * 0.3)
      ..cubicTo(w * 0.8, h * 0.3, w * 0.9, slitY * 0.4, w * 0.8, slitY)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = primaryColor);

    // Left Arm (waving/happy)
    final leftArm = Path()
      ..moveTo(w * 0.25, slitY * 0.9)
      ..quadraticBezierTo(w * 0.1, slitY * 0.7, w * 0.05, slitY * 0.8);
    canvas.drawPath(leftArm, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);
    
    // Right Arm (holding puzzle piece)
    final rightArm = Path()
      ..moveTo(w * 0.75, slitY * 0.9)
      ..quadraticBezierTo(w * 0.9, slitY * 0.6, w * 0.85, slitY * 0.5);
    canvas.drawPath(rightArm, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.65),
      width: w * 0.5,
      height: h * 0.35,
    );
    canvas.drawOval(faceRect, Paint()..color = faceColor);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFA6D9);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.35, h * 0.7), width: w * 0.1, height: h * 0.06), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.65, h * 0.7), width: w * 0.1, height: h * 0.06), cheekPaint);

    // Happy eyes (^)
    final eyePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
      
    final leftEye = Path()
      ..moveTo(w * 0.40, h * 0.63)
      ..quadraticBezierTo(w * 0.44, h * 0.59, w * 0.48, h * 0.63);
    canvas.drawPath(leftEye, eyePaint);

    final rightEye = Path()
      ..moveTo(w * 0.60, h * 0.63)
      ..quadraticBezierTo(w * 0.56, h * 0.59, w * 0.52, h * 0.63);
    canvas.drawPath(rightEye, eyePaint);

    // Happy mouth (open)
    final mouthPaint = Paint()..color = const Color(0xFF831843); // Dark red
    final mouthPath = Path()
      ..moveTo(w * 0.45, h * 0.68)
      ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.55, h * 0.68)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // Draw Puzzle Piece in right hand
    canvas.drawCircle(Offset(w * 0.85, slitY * 0.5), w * 0.06, Paint()..color = darkPurple);
    canvas.drawCircle(Offset(w * 0.85, slitY * 0.5) + Offset(0, -w * 0.02), w * 0.03, Paint()..color = Colors.white);
    
    canvas.restore(); // Remove clipping

    // Draw the front lip of the slit
    final frontSlit = Path()
      ..moveTo(w * 0.15, slitY)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.04, w * 0.85, slitY)
      ..lineTo(w * 0.85, slitY + h * 0.03)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.07, w * 0.15, slitY + h * 0.03)
      ..close();
    canvas.drawPath(frontSlit, Paint()..color = primaryColor.withValues(alpha: 0.8));

    // Floating puzzle piece above head
    final puzzleCenter = Offset(w * 0.65, h * 0.15);
    canvas.drawCircle(puzzleCenter, w * 0.06, Paint()..color = darkPurple);
    canvas.drawCircle(puzzleCenter, w * 0.015, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(0, -w * 0.02), w * 0.01, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(0, w * 0.02), w * 0.01, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(-w * 0.02, 0), w * 0.01, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(w * 0.02, 0), w * 0.01, Paint()..color = Colors.white);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5 - math.pi / 2;
      final outerX = center.dx + radius * math.cos(angle);
      final outerY = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      final innerAngle = angle + math.pi / 5;
      final innerRadius = radius * 0.4;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
