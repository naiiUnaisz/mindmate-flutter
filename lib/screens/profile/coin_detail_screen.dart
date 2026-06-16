import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_state.dart';
import 'package:mindmate/widgets/coin_widget.dart';

/// Screen displaying the user's current coin balance and transaction history.
/// Follows the provided design:
/// - Custom app bar with back button and title
/// - "Current Coins" card displaying total coins
/// - "History" section with a list of transactions (dummy data for now)
class CoinDetailScreen extends StatelessWidget {
  const CoinDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Coins Detail',
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

            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ═══════════════════════════════════════
                        // CURRENT COINS CARD
                        // ═══════════════════════════════════════
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Coins',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const CoinWidget(size: 32),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${state.user.coins}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ═══════════════════════════════════════
                        // HISTORY TITLE
                        // ═══════════════════════════════════════
                        const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══════════════════════════════════════
                        // HISTORY LIST
                        // ═══════════════════════════════════════
                        if (state.coinHistory.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(
                              child: Text(
                                'No coin history yet',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          for (final item in state.coinHistory)
                            _HistoryItem(data: item),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HISTORY ITEM WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _HistoryItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isExchange = data['type'] == 'exchange';
    final int amount = data['amount'];
    final bool isPositive = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isExchange ? const Color(0xFFE8DFFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isExchange
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.smart_display_rounded,
                          color: Color(0xFF9B7FE6),
                          size: 24,
                        ),
                        Positioned(
                          bottom: -2,
                          right: -4,
                          child: Icon(
                            Icons.music_note_rounded,
                            color: const Color(0xFF9B7FE6),
                            size: 12,
                          ),
                        ),
                      ],
                    )
                  : const CoinWidget(size: 28),
            ),
          ),
          const SizedBox(width: 16),
          // Title and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(data['date']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${isPositive ? '+' : '-'} ${amount.abs()}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final amPm = date.hour < 12 ? 'am' : 'pm';
      
      if (isToday) {
        return 'Today, $hour.$minute $amPm';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}, $hour.$minute $amPm';
      }
    } catch (e) {
      return isoString;
    }
  }
}
