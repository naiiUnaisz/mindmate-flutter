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
                  margin: EdgeInsets.only(top: isSmall ? 150 : 160),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    isSmall ? 50 : 70,
                    24,
                    24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DFFF),
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
                  top: isSmall ? 166 : 176,
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

                // Mascot — non-positioned, renders above the card
                Padding(
                  padding: EdgeInsets.only(top: isSmall ? 30 : 40),
                  child: Image.asset(
                    'assets/maskot/i_got_puzzle_2.png',
                    width: 180,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),

                // Confetti Decoration
                Positioned(
                  top: isSmall ? 170 : 180,
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
              color: isActive ? const Color(0xFFE8DFFF) : const Color(0xFFF9FAFB),
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

