import 'package:flutter/material.dart';
import 'package:application_belajar/widgets/mascot_painter.dart';
import 'package:application_belajar/widgets/sparkle_painter.dart';
import 'package:application_belajar/widgets/coin_widget.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PAGE 1 ILLUSTRATION: Mascot with sparkles
// ═══════════════════════════════════════════════════════════════════════════

class WelcomeIllustration extends StatefulWidget {
  const WelcomeIllustration({super.key});

  @override
  State<WelcomeIllustration> createState() => _WelcomeIllustrationState();
}

class _WelcomeIllustrationState extends State<WelcomeIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkles background
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(320, 300),
                painter: SparklePainter(
                  animationValue: _sparkleController.value,
                ),
              );
            },
          ),
          // Mascot character
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: SizedBox(
              width: 200,
              height: 220,
              child: CustomPaint(painter: MascotPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE 2 ILLUSTRATION: Task cards with coins + small mascot
// ═══════════════════════════════════════════════════════════════════════════

class TaskCoinsIllustration extends StatefulWidget {
  const TaskCoinsIllustration({super.key});

  @override
  State<TaskCoinsIllustration> createState() => _TaskCoinsIllustrationState();
}

class _TaskCoinsIllustrationState extends State<TaskCoinsIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final floatOffset = _floatController.value * 6;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Task Cards (stacked, slightly offset) ──
              Positioned(
                top: 10 + floatOffset,
                right: 20,
                child: _buildTaskCard(
                  icon: Icons.book_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Tugas',
                  subtitle: 'Catat Materi',
                  width: 220,
                ),
              ),
              Positioned(
                top: 85 + floatOffset * 0.7,
                right: 40,
                child: _buildTaskCard(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Harian',
                  subtitle: 'Jemur',
                  width: 200,
                ),
              ),
              Positioned(
                top: 155 + floatOffset * 0.4,
                right: 60,
                child: _buildTaskCard(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Kebutuhan',
                  subtitle: 'Belanja',
                  width: 180,
                  showDots: true,
                ),
              ),

              // ── Floating Coins ──
              Positioned(
                top: 5 - floatOffset * 0.5,
                right: 30,
                child: Transform.translate(
                  offset: Offset(0, -floatOffset * 0.8),
                  child: const CoinWidget(size: 30),
                ),
              ),
              Positioned(
                top: 80 - floatOffset * 0.3,
                right: 15,
                child: Transform.translate(
                  offset: Offset(0, -floatOffset * 0.5),
                  child: const CoinWidget(size: 24),
                ),
              ),
              Positioned(
                top: 140,
                right: 25,
                child: Transform.translate(
                  offset: Offset(0, -floatOffset * 0.6),
                  child: const CoinWidget(size: 20),
                ),
              ),

              // ── Mascot (small, on the left) ──
              Positioned(
                bottom: 20,
                left: 10,
                child: Transform.translate(
                  offset: Offset(0, -floatOffset * 0.4),
                  child: SizedBox(
                    width: 120,
                    height: 140,
                    child: CustomPaint(painter: MascotPainter()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double width,
    bool showDots = true,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5FF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          if (showDots)
            const Icon(Icons.more_horiz, color: Color(0xFF9CA3AF), size: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE 3 ILLUSTRATION: Puzzle Progress + grid + mascot
// ═══════════════════════════════════════════════════════════════════════════

class PuzzleIllustration extends StatefulWidget {
  const PuzzleIllustration({super.key});

  @override
  State<PuzzleIllustration> createState() => _PuzzleIllustrationState();
}

class _PuzzleIllustrationState extends State<PuzzleIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _pulseController.value;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Puzzle Progress Card ──
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: _buildPuzzleProgressCard(),
              ),

              // ── Puzzle Grid ──
              Positioned(
                top: 80,
                left: 30,
                child: Transform.translate(
                  offset: Offset(0, pulse * 3),
                  child: _buildPuzzleGrid(),
                ),
              ),

              // ── Mascot (right side) ──
              Positioned(
                bottom: 10,
                right: 10,
                child: Transform.translate(
                  offset: Offset(0, -pulse * 4),
                  child: SizedBox(
                    width: 110,
                    height: 130,
                    child: CustomPaint(painter: MascotPainter()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPuzzleProgressCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFC4B5FD)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.extension, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Puzzle Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Complete tasks and get puzzle pieces!',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleGrid() {
    // 2×3 puzzle grid with colorful landscape pieces
    const pieceColors = [
      [Color(0xFF81D4FA), Color(0xFF4FC3F7)], // Sky blue
      [Color(0xFF80CBC4), Color(0xFF4DB6AC)], // Teal
      [Color(0xFFA5D6A7), Color(0xFF66BB6A)], // Green
      [Color(0xFF81D4FA), Color(0xFF29B6F6)], // Light blue
      [Color(0xFFC5E1A5), Color(0xFF9CCC65)], // Light green
      [Color(0xFFFFCC80), Color(0xFFFFB74D)], // Orange/sand
    ];

    return Container(
      width: 180,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final colors = pieceColors[index];
            final isLastPiece = index == 5;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLastPiece
                      ? [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)]
                      : colors,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: isLastPiece
                  ? Center(
                      child: Icon(
                        Icons.extension,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                        size: 24,
                      ),
                    )
                  : _buildPieceDecoration(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPieceDecoration(int index) {
    // Add simple decorative elements to make each piece look like landscape
    switch (index) {
      case 0: // Sky with cloud
        return Stack(
          children: [
            Positioned(
              top: 8,
              left: 6,
              child: Container(
                width: 20,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      case 1: // Rainbow arc
        return CustomPaint(painter: _RainbowArcPainter());
      case 2: // Tree
        return Stack(
          children: [
            Positioned(
              bottom: 4,
              right: 10,
              child: Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF795548).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      case 3: // Mountains
        return CustomPaint(painter: _MountainPainter());
      case 4: // Trees/forest
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 4,
              child: Container(
                width: 14,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF388E3C).withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 8,
              child: Container(
                width: 12,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Simple rainbow arc painter for puzzle piece decoration.
class _RainbowArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final colors = [
      Colors.red.withValues(alpha: 0.3),
      Colors.orange.withValues(alpha: 0.3),
      Colors.yellow.withValues(alpha: 0.3),
      Colors.green.withValues(alpha: 0.3),
    ];

    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: size.width * (0.8 - i * 0.12),
          height: size.height * (0.6 - i * 0.1),
        ),
        3.14,
        3.14,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple mountain silhouette painter for puzzle piece decoration.
class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF546E7A).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
