import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/bloc/mood/mood_bloc.dart';
import 'package:mindmate/bloc/mood/mood_event.dart';

class MoodDialog extends StatefulWidget {
  const MoodDialog({super.key});

  @override
  State<MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<MoodDialog> {
  @override
  void initState() {
    super.initState();
    _markShownToday();
  }

  Future<void> _markShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setString('mood_dialog_last_shown', today);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mascot_unlock.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.emoji_emotions,
                size: 80,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How are you feeling?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your mood to start your day!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MoodOption(
                  mood: 'sad',
                  label: 'Sad',
                  color: Colors.blueAccent,
                  onTap: () {
                    context.read<MoodBloc>().add(
                      SubmitMood(mood: 'sad', date: DateTime.now()),
                    );
                    Navigator.pop(context);
                  },
                ),
                MoodOption(
                  mood: 'normal',
                  label: 'Normal',
                  color: Colors.orangeAccent,
                  onTap: () {
                    context.read<MoodBloc>().add(
                      SubmitMood(mood: 'normal', date: DateTime.now()),
                    );
                    Navigator.pop(context);
                  },
                ),
                MoodOption(
                  mood: 'happy',
                  label: 'Happy',
                  color: Colors.green,
                  onTap: () {
                    context.read<MoodBloc>().add(
                      SubmitMood(mood: 'happy', date: DateTime.now()),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MoodOption extends StatelessWidget {
  final String mood;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MoodOption({
    super.key,
    required this.mood,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(painter: MascotFacePainter(mood: mood)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class MascotFacePainter extends CustomPainter {
  final String mood;

  MascotFacePainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = const Color(0xFFB78AF7);
    final faceColor = const Color(0xFFFFE4E6);

    final squircle = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.45),
    );
    canvas.drawRRect(squircle, Paint()..color = primaryColor);

    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.85,
      height: h * 0.65,
    );
    canvas.drawOval(faceRect, Paint()..color = faceColor);

    final cheekPaint = Paint()
      ..color = const Color(0xFFFFA6D9).withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.22, h * 0.65),
        width: w * 0.2,
        height: h * 0.12,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.78, h * 0.65),
        width: w * 0.2,
        height: h * 0.12,
      ),
      cheekPaint,
    );

    final strokePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..color = const Color(0xFF831843);
    final darkEyePaint = Paint()..color = const Color(0xFF1F2937);

    if (mood == 'happy') {
      canvas.drawCircle(Offset(w * 0.32, h * 0.52), w * 0.1, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.68, h * 0.52), w * 0.1, darkEyePaint);

      canvas.drawCircle(
        Offset(w * 0.35, h * 0.48),
        w * 0.035,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(w * 0.28, h * 0.55),
        w * 0.015,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(w * 0.71, h * 0.48),
        w * 0.035,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(w * 0.64, h * 0.55),
        w * 0.015,
        Paint()..color = Colors.white,
      );

      final mouthPath = Path()
        ..moveTo(w * 0.4, h * 0.65)
        ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.6, h * 0.65)
        ..close();
      canvas.drawPath(mouthPath, fillPaint);

      canvas.save();
      canvas.clipPath(mouthPath);
      canvas.drawCircle(
        Offset(w * 0.5, h * 0.78),
        w * 0.06,
        Paint()..color = const Color(0xFFF472B6),
      );
      canvas.restore();
    } else if (mood == 'normal') {
      canvas.drawCircle(Offset(w * 0.33, h * 0.55), w * 0.06, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.67, h * 0.55), w * 0.06, darkEyePaint);

      final mouth = Path()
        ..moveTo(w * 0.43, h * 0.68)
        ..quadraticBezierTo(w * 0.465, h * 0.73, w * 0.5, h * 0.68)
        ..quadraticBezierTo(w * 0.535, h * 0.73, w * 0.57, h * 0.68);
      canvas.drawPath(mouth, strokePaint..strokeWidth = w * 0.045);
    } else if (mood == 'sleepy') {
      final leftEye = Path()
        ..moveTo(w * 0.28, h * 0.55)
        ..quadraticBezierTo(w * 0.33, h * 0.58, w * 0.38, h * 0.55);
      final rightEye = Path()
        ..moveTo(w * 0.62, h * 0.55)
        ..quadraticBezierTo(w * 0.67, h * 0.58, w * 0.72, h * 0.55);
      canvas.drawPath(leftEye, strokePaint..strokeWidth = w * 0.045);
      canvas.drawPath(rightEye, strokePaint..strokeWidth = w * 0.045);

      final mouth = Path()
        ..moveTo(w * 0.46, h * 0.72)
        ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.54, h * 0.72);
      canvas.drawPath(mouth, strokePaint..strokeWidth = w * 0.04);
    } else {
      canvas.save();
      canvas.translate(w * 0.33, h * 0.55);
      canvas.rotate(math.pi / 12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.22),
        darkEyePaint,
      );
      canvas.drawCircle(
        Offset(w * 0.02, -h * 0.05),
        w * 0.04,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(-w * 0.02, h * 0.05),
        w * 0.015,
        Paint()..color = Colors.white,
      );
      canvas.restore();

      canvas.save();
      canvas.translate(w * 0.67, h * 0.55);
      canvas.rotate(-math.pi / 12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.22),
        darkEyePaint,
      );
      canvas.drawCircle(
        Offset(w * 0.02, -h * 0.05),
        w * 0.04,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(-w * 0.02, h * 0.05),
        w * 0.015,
        Paint()..color = Colors.white,
      );
      canvas.restore();

      final mouthPath = Path()
        ..moveTo(w * 0.43, h * 0.78)
        ..quadraticBezierTo(w * 0.5, h * 0.73, w * 0.57, h * 0.78);
      canvas.drawPath(mouthPath, strokePaint..strokeWidth = w * 0.045);

      final tearPaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.9);
      canvas.drawCircle(Offset(w * 0.23, h * 0.65), w * 0.03, tearPaint);
      canvas.drawCircle(Offset(w * 0.26, h * 0.75), w * 0.035, tearPaint);

      canvas.drawCircle(Offset(w * 0.77, h * 0.65), w * 0.03, tearPaint);
      canvas.drawCircle(Offset(w * 0.74, h * 0.75), w * 0.035, tearPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MascotFacePainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}
