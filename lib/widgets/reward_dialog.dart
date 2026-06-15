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
              color: const Color(0xFFE8DFFF), // Light purple background
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
            child: Image.asset(
              'assets/maskot/i_got_puzzle_2b.png',
              width: 180,
              height: 160,
              fit: BoxFit.contain,
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

