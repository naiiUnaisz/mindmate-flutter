import 'package:flutter/material.dart';

/// Trash screen representing an empty state.
/// Matches the MindMate "No Rubbish Yet" design.
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // HEADER: Back + Title
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Trash',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // EMPTY STATE (Mascot + Text)
            // ═══════════════════════════════════════
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mascot Stack
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // ── Main Mascot CustomPaint ──
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _ConfusedMascotPainter(),
                          ),
                          
                          // ── Floating Question Marks ──
                          // Left big question mark
                          const Positioned(
                            left: 10,
                            top: 80,
                            child: Text(
                              '?',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5B3482), // Dark purple
                              ),
                            ),
                          ),
                          
                          // Right small question marks
                          const Positioned(
                            right: 25,
                            top: 110,
                            child: Text(
                              '??',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5B3482),
                              ),
                            ),
                          ),
                          
                          // Question mark inside the bubble
                          const Positioned(
                            right: 65,
                            top: 30,
                            child: Icon(
                              Icons.extension,
                              size: 16,
                              color: Color(0xFFE9D5FF),
                            ), // Close enough to the white star/blob in the design
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Rubbish Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA78BFA),
                      ),
                    ),
                    const SizedBox(height: 80), // Offset slightly upwards
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONFUSED MASCOT PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _ConfusedMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Colors
    final primaryColor = const Color(0xFFB78AF7);
    final darkPurple = const Color(0xFF8B5CF6);
    final faceColor = const Color(0xFFFFE4E6);
    final cheekColor = const Color(0xFFFFA6D9);
    final eyeColor = const Color(0xFF1F2937);
    final sweatColor = const Color(0xFF93C5FD);
    
    // 1. Antenna Bubble (Top right)
    final antennaPath = Path()
      ..moveTo(w * 0.7, h * 0.25)
      ..lineTo(w * 0.85, h * 0.1);
    canvas.drawPath(
      antennaPath, 
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
    );
    
    // Bubble Circle
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.08), 
      20, 
      Paint()..color = darkPurple
    );

    // 2. Main Body (Perfect Circle)
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5), 
      w * 0.45, 
      Paint()..color = primaryColor
    );
    
    // 3. Inner Face (Slightly flattened circle)
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.55),
      width: w * 0.65,
      height: h * 0.55,
    );
    canvas.drawOval(faceRect, Paint()..color = faceColor);
    
    // 4. Cheeks
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.3, h * 0.6), width: w * 0.14, height: h * 0.1), 
      Paint()..color = cheekColor
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.7, h * 0.6), width: w * 0.14, height: h * 0.1), 
      Paint()..color = cheekColor
    );
    
    // 5. Eyes (Vertical Ovals)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.4, h * 0.52), width: w * 0.08, height: h * 0.12), 
      Paint()..color = eyeColor
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.6, h * 0.52), width: w * 0.08, height: h * 0.12), 
      Paint()..color = eyeColor
    );
    
    // 6. Open Mouth
    final mouthRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.08, height: h * 0.12);
    canvas.drawOval(mouthRect, Paint()..color = const Color(0xFF4C1D95));
    // Tongue (bottom of mouth)
    canvas.save();
    canvas.clipPath(Path()..addOval(mouthRect));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.08, height: h * 0.08), 
      Paint()..color = const Color(0xFFF472B6)
    );
    canvas.restore();
    
    // 7. Sweat Drop (Top right of face)
    final sweatPath = Path()
      ..moveTo(w * 0.75, h * 0.42)
      ..quadraticBezierTo(w * 0.77, h * 0.47, w * 0.75, h * 0.49)
      ..quadraticBezierTo(w * 0.73, h * 0.47, w * 0.75, h * 0.42);
    canvas.drawPath(sweatPath, Paint()..color = sweatColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
