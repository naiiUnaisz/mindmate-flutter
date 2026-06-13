import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/networks/api_client.dart';
import 'package:application_belajar/bloc/task/task_bloc.dart';
import 'package:application_belajar/bloc/task/task_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                      child: const Icon(Icons.settings_outlined, size: 24, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _ProfileCard(),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Data Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _MenuItem(label: 'Puzzle Collect', onTap: () => Navigator.pushNamed(context, '/puzzle-collection')),
                    _MenuItem(label: 'Coins Detail', onTap: () => Navigator.pushNamed(context, '/coin-detail')),
                    _MenuItem(label: 'Trash', onTap: () => Navigator.pushNamed(context, '/trash')),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: const Text('Log Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFEF4444))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const _LogoutDialog());
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE CARD (purple banner + avatar + info)
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileBloc>().state.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: 50,
              child: Icon(Icons.extension, size: 200, color: const Color(0xFF7C3AED).withValues(alpha: 0.04)),
            ),
            Column(
              children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primary.withValues(alpha: 0.5),
                ]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: Colors.white54, thickness: 1, endIndent: 12, indent: 80)),
                  Text('PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: Colors.white)),
                  Expanded(child: Divider(color: Colors.white54, thickness: 1, indent: 12, endIndent: 80)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: const Color(0xFFF3E8FF), child: const Icon(Icons.person, size: 36, color: Color(0xFF7658B2))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                        const SizedBox(height: 2),
                        Text(user.email, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.primary.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF3F4F6)),
                      child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _StatColumn(value: 'Female', label: 'GENDER'),
                  const SizedBox(width: 24),
                  _StatColumn(value: '23', label: 'AGE'),
                  const SizedBox(width: 24),
                  _StatColumn(value: '01/09/03', label: 'BIRTHDAY'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Registered on: ${user.lastActiveDate.day.toString().padLeft(2, '0')}/${user.lastActiveDate.month.toString().padLeft(2, '0')}/${user.lastActiveDate.year}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF)),
                  ),
                  const Text('<<<<<<<<<<', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD1D5DB), letterSpacing: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MANAGEMENT MENU ITEM
// ═══════════════════════════════════════════════════════════════════════════

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM LOGOUT DIALOG
// ═══════════════════════════════════════════════════════════════════════════

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

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
            margin: const EdgeInsets.only(top: 60), // Space for mascot
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE5FB), // Light purple background
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Log Out of MindMate?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You'll need to log in again to access\nyour account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<TaskBloc>().add(ClearTasks());
                          ApiClient().apiLogout();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7658B2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 76,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Mascot
          Positioned(
            top: 0,
            child: SizedBox(
              width: 140,
              height: 120,
              child: CustomPaint(
                painter: _SadMascotPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SAD MASCOT PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _SadMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = const Color(0xFFB78AF7);
    final faceColor = const Color(0xFFFFE4E6);
    final darkPurple = const Color(0xFF8B5CF6);
    
    // Slit position
    final slitY = h * 0.95;
    
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
      ..cubicTo(w * 0.1, slitY * 0.5, w * 0.2, h * 0.2, w * 0.5, h * 0.2)
      ..cubicTo(w * 0.8, h * 0.2, w * 0.9, slitY * 0.5, w * 0.8, slitY)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = primaryColor);

    // Arms
    final leftArm = Path()
      ..moveTo(w * 0.25, slitY)
      ..quadraticBezierTo(w * 0.15, slitY * 0.8, w * 0.1, slitY);
    canvas.drawPath(leftArm, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);
    
    final rightArm = Path()
      ..moveTo(w * 0.75, slitY)
      ..quadraticBezierTo(w * 0.85, slitY * 0.8, w * 0.9, slitY);
    canvas.drawPath(rightArm, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.6),
      width: w * 0.55,
      height: h * 0.45,
    );
    canvas.drawOval(faceRect, Paint()..color = faceColor);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFA6D9);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.35, h * 0.65), width: w * 0.12, height: h * 0.08), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.65, h * 0.65), width: w * 0.12, height: h * 0.08), cheekPaint);

    // Sad eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
      
    // Left eye (slanted down)
    final leftEye = Path()
      ..moveTo(w * 0.40, h * 0.58)
      ..quadraticBezierTo(w * 0.44, h * 0.56, w * 0.48, h * 0.61);
    canvas.drawPath(leftEye, eyePaint);

    // Right eye (slanted down)
    final rightEye = Path()
      ..moveTo(w * 0.60, h * 0.58)
      ..quadraticBezierTo(w * 0.56, h * 0.56, w * 0.52, h * 0.61);
    canvas.drawPath(rightEye, eyePaint);

    // Sad mouth
    final mouth = Path()
      ..moveTo(w * 0.46, h * 0.73)
      ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.54, h * 0.73);
    canvas.drawPath(mouth, eyePaint);

    // Tears
    final tearPaint = Paint()..color = const Color(0xFF60A5FA);
    // Left tear
    final leftTear = Path()
      ..moveTo(w * 0.39, h * 0.63)
      ..quadraticBezierTo(w * 0.37, h * 0.67, w * 0.39, h * 0.69)
      ..quadraticBezierTo(w * 0.41, h * 0.67, w * 0.39, h * 0.63);
    canvas.drawPath(leftTear, tearPaint);
    
    // Right tear
    final rightTear = Path()
      ..moveTo(w * 0.61, h * 0.63)
      ..quadraticBezierTo(w * 0.59, h * 0.67, w * 0.61, h * 0.69)
      ..quadraticBezierTo(w * 0.63, h * 0.67, w * 0.61, h * 0.63);
    canvas.drawPath(rightTear, tearPaint);

    canvas.restore(); // Remove clipping

    // Draw the front lip of the slit
    final frontSlit = Path()
      ..moveTo(w * 0.15, slitY)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.04, w * 0.85, slitY)
      ..lineTo(w * 0.85, slitY + h * 0.03)
      ..quadraticBezierTo(w * 0.5, slitY + h * 0.07, w * 0.15, slitY + h * 0.03)
      ..close();
    canvas.drawPath(frontSlit, Paint()..color = primaryColor.withValues(alpha: 0.8));

    // Floating puzzle
    final puzzleCenter = Offset(w * 0.65, h * 0.12);
    canvas.drawCircle(puzzleCenter, w * 0.07, Paint()..color = darkPurple);
    // puzzle piece dots
    canvas.drawCircle(puzzleCenter, w * 0.018, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(0, -w * 0.025), w * 0.012, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(0, w * 0.025), w * 0.012, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(-w * 0.025, 0), w * 0.012, Paint()..color = Colors.white);
    canvas.drawCircle(puzzleCenter + Offset(w * 0.025, 0), w * 0.012, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
