import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_state.dart';
import 'package:application_belajar/bloc/mood/mood_bloc.dart';
import 'package:application_belajar/bloc/mood/mood_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // TITLE
              // ═══════════════════════════════════════
              const Center(
                child: Text(
                  'History Statistic',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════
              // MOOD HISTORY CARD
              // ═══════════════════════════════════════
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mood History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<MoodBloc, MoodState>(
                      builder: (context, state) {
                        final moodMap = <String, String>{};
                        for (final m in state.moodHistory) {
                          final key = '${m.date.year}-${m.date.month.toString().padLeft(2, '0')}-${m.date.day.toString().padLeft(2, '0')}';
                          moodMap[key] = m.mood;
                        }

                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final monday = today.subtract(Duration(days: now.weekday - 1));
                        
                        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final weekDays = <Widget>[];
                        for (int i = 0; i < 7; i++) {
                          final date = monday.add(Duration(days: i));
                          final isFuture = date.isAfter(today);
                          final isToday = date.isAtSameMomentAs(today);
                          
                          final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          final mood = moodMap[key];
                          final emoji = isFuture ? '-' : _moodToEmoji(mood);

                          weekDays.add(
                            _MoodPill(
                              day: dayNames[i],
                              isYellow: isToday,
                              mood: emoji,
                            ),
                          );
                          if (i < 6) weekDays.add(const SizedBox(width: 6));
                        }

                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(children: weekDays),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // BAR CHART CARD
              // ═══════════════════════════════════════
              _buildCard(child: const _BarChartSection()),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // COIN INSIGHT CARD
              // ═══════════════════════════════════════
              _buildCard(child: const _CoinInsightSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: child,
    );
  }
}

String _moodToEmoji(String? mood) {
  switch (mood) {
    case 'happy':
      return '😊';
    case 'sad':
      return '😔';
    case 'normal':
      return '😐';
    default:
      return '😐';
  }
}

String _emojiToMoodImage(String emoji) {
  switch (emoji) {
    case '😊':
      return 'assets/maskot/Happy face (1).png';
    case '😔':
      return 'assets/maskot/down face (2).png';
    case '😐':
      return 'assets/maskot/chill face (1).png';
    default:
      return 'assets/maskot/chill face (1).png';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOOD PILL WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _MoodPill extends StatelessWidget {
  final String day;
  final bool isYellow;
  final String mood;

  const _MoodPill({
    required this.day,
    required this.isYellow,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 80,
      decoration: BoxDecoration(
        color: isYellow ? const Color(0xFFFFF5D1) : const Color(0xFFFFE4F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFD1C4E9),
              shape: BoxShape.circle,
            ),
            child: mood == '-'
                ? const Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        color: Color(0xFF2D1B4E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      _emojiToMoodImage(mood),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BAR CHART WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _BarChartSection extends StatelessWidget {
  const _BarChartSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final data = state.weeklyBarData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend
            Row(
              children: [
                const Icon(Icons.extension, size: 16, color: Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                const Text(
                  'Task Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFACC15),
                  ),
                  child: const Center(
                    child: Icon(Icons.star, size: 8, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Coin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chart
            SizedBox(
              height: 160,
              child: Builder(
                builder: (context) {
                  final maxTasks = data.isEmpty ? 6 : data.map((e) => e['tasks'] as int).reduce((a, b) => a > b ? a : b);
                  final maxCoins = data.isEmpty ? 30 : data.map((e) => e['coins'] as int).reduce((a, b) => a > b ? a : b);
                  
                  // Provide a minimum base scale so small numbers don't fill the whole screen
                  final scaleTasks = maxTasks < 6 ? 6.0 : maxTasks.toDouble();
                  final scaleCoins = maxCoins < 30 ? 30.0 : maxCoins.toDouble();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final entry in data)
                        _BarGroup(
                          day: entry['day'] as String,
                          puzzle: entry['tasks'] as int,
                          coin: entry['coins'] as int,
                          maxPuzzleScale: scaleTasks,
                          maxCoinScale: scaleCoins,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BarGroup extends StatelessWidget {
  final String day;
  final int puzzle;
  final int coin;
  final double maxPuzzleScale;
  final double maxCoinScale;

  const _BarGroup({
    required this.day,
    required this.puzzle,
    required this.coin,
    this.maxPuzzleScale = 6.0,
    this.maxCoinScale = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    const maxHeight = 100.0;

    double puzzleHeight = puzzle == 0 ? 4.0 : (puzzle / maxPuzzleScale) * maxHeight;
    double coinHeight = coin == 0 ? 4.0 : (coin / maxCoinScale) * maxHeight;
    
    // Safety clamp to ensure it absolutely never overflows
    if (puzzleHeight > maxHeight) puzzleHeight = maxHeight;
    if (coinHeight > maxHeight) coinHeight = maxHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Numbers and Bars
        SizedBox(
          height: maxHeight + 24, // accommodate text on top
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Coin Bar (Yellow)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (coin > 0)
                    Text(
                      coin.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: coinHeight,
                    decoration: BoxDecoration(
                      color: coin == 0
                          ? const Color(0xFFFACC15).withValues(alpha: 0.3)
                          : const Color(0xFFFACC15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              // Task Bar (Purple)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (puzzle > 0)
                    Text(
                      puzzle.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: puzzleHeight,
                    decoration: BoxDecoration(
                      color: puzzle == 0
                          ? const Color(0xFF7C3AED).withValues(alpha: 0.3)
                          : const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Day Label
        Text(
          day,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COIN INSIGHT SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _CoinInsightSection extends StatelessWidget {
  const _CoinInsightSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final totalCoins = state.user.coins;
        final earnedCoins = state.user.earnedCoins;
        final spentCoins = state.user.spentCoins;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coin insight',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Left Card (Total coin)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total coin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFACC15),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              totalCoins.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${state.weeklyCoinDiff} from last week',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(
                              0xFFA78BFA,
                            ), // light purple matching design
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right Card (Earned/Spent)
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Earned',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+$earnedCoins',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981), // Green
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Spent',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '−$spentCoins',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFEF4444), // Red
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Manage your coins wisely',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C3AED), // Dark purple
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
