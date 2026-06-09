import 'package:flutter/material.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/screens/home/home_screen.dart';
import 'package:application_belajar/screens/relax/relax_screen.dart';
import 'package:application_belajar/screens/insights/insights_screen.dart';
import 'package:application_belajar/screens/profile/profile_screen.dart';

/// Main screen with custom bottom navigation bar matching the MindMate design.
///
/// Navigation items:
/// - Home (house icon)
/// - Relax (play icon)
/// - + button (floating, center, purple)
/// - Insights (bar chart icon)
/// - Profile (person icon)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RelaxScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // FLOATING ACTION BUTTON (center + icon)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B7FE6), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openAddTask,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // CUSTOM BOTTOM NAVIGATION BAR
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      height: 72 + 24 + 20, // navbar height + half FAB overlap + bottom margin
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Navbar background
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF), // Light purple background
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    iconWidget: _buildPuzzleHomeIcon(
                      isActive: _selectedIndex == 0,
                    ),
                    label: 'Home',
                    isActive: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _NavItem(
                    iconWidget: _buildRelaxIcon(isActive: _selectedIndex == 1),
                    label: 'Relax',
                    isActive: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  // Spacer for the center FAB
                  const SizedBox(width: 48),
                  _NavItem(
                    iconWidget: Icon(
                      Icons.insights_rounded,
                      color: _selectedIndex == 2
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF1F2937),
                      size: 26,
                    ),
                    label: 'Insights',
                    isActive: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _NavItem(
                    iconWidget: Icon(
                      Icons.person_rounded,
                      color: _selectedIndex == 3
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF1F2937),
                      size: 26,
                    ),
                    label: 'Profile',
                    isActive: _selectedIndex == 3,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                ],
              ),
            ),
          ),
          // FAB
          Positioned(top: 0, child: _buildFAB()),
        ],
      ),
    );
  }

  Widget _buildPuzzleHomeIcon({required bool isActive}) {
    final color = isActive ? const Color(0xFF7C3AED) : const Color(0xFF1F2937);
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.home_filled, color: color, size: 28),
        CustomPaint(
          size: const Size(28, 28),
          painter: _PuzzleLinesPainter(
            color: const Color(0xFFF3E8FF),
          ), // Navbar bg color
        ),
      ],
    );
  }

  Widget _buildRelaxIcon({required bool isActive}) {
    final color = isActive ? const Color(0xFF7C3AED) : const Color(0xFF1F2937);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.smart_display_rounded, color: color, size: 26),
        Positioned(
          bottom: -2,
          right: -4,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF), // match navbar bg
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(Icons.music_note_rounded, color: color, size: 12),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION ITEM
// ═══════════════════════════════════════════════════════════════════════════

class _NavItem extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconWidget,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: iconWidget,
            ),
            const SizedBox(height: 4),
            Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF1F2937),
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(2),
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

// ═══════════════════════════════════════════════════════════════════════════
// PUZZLE HOUSE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _PuzzleLinesPainter extends CustomPainter {
  final Color color;
  _PuzzleLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2 + 2;

    // Draw vertical gap
    Path vPath = Path()
      ..moveTo(cx, 4)
      ..lineTo(cx, size.height - 2);

    // Draw horizontal gap
    Path hPath = Path()
      ..moveTo(4, cy)
      ..lineTo(size.width - 4, cy);

    // Draw simple puzzle knobs (semi-circles)
    Path vKnob = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy + 4), radius: 2.5),
        -1.57,
        3.14,
      );

    Path hKnob = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx - 4, cy), radius: 2.5),
        0,
        3.14,
      );

    canvas.drawPath(vPath, paint);
    canvas.drawPath(hPath, paint);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(vKnob, fillPaint);
    canvas.drawPath(hKnob, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _PuzzleLinesPainter old) => old.color != color;
}
