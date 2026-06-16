import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_event.dart';
import 'package:mindmate/bloc/profile/profile_state.dart';
import 'package:mindmate/models/puzzle_model.dart';
import 'package:mindmate/config/theme.dart';

/// Detail screen for a single puzzle artwork.
///
/// Shows:
/// - Full-resolution hero image
/// - Title, description, and status
/// - Unlock button (if locked) or completion badge (if unlocked)
class PuzzleDetailScreen extends StatefulWidget {
  final Puzzle puzzle;

  const PuzzleDetailScreen({super.key, required this.puzzle});

  @override
  State<PuzzleDetailScreen> createState() => _PuzzleDetailScreenState();
}

class _PuzzleDetailScreenState extends State<PuzzleDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _justUnlocked = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5EF),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isUnlocked = state.isPuzzleUnlocked(widget.puzzle.id);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ═══════════════════════════════════════
              // CUSTOM APP BAR
              // ═══════════════════════════════════════
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
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
                        Expanded(
                          child: Center(
                            child: Text(
                              isUnlocked ? 'Artwork Detail' : 'Unlock Artwork',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════════════
              // HERO IMAGE
              // ═══════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Hero(
                    tag: 'puzzle_${widget.puzzle.id}',
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED)
                                .withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              widget.puzzle.assetPath,
                              fit: BoxFit.cover,
                            ),
                            // Locked tint
                            if (!isUnlocked)
                              Container(
                                color: const Color(0xFFD5CEE8)
                                    .withValues(alpha: 0.55),
                              ),
                            // Unlock success shimmer
                            if (_justUnlocked)
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (_, _) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(
                                          -1 + 2 * _shimmerController.value,
                                          0,
                                        ),
                                        end: Alignment(
                                          1 + 2 * _shimmerController.value,
                                          0,
                                        ),
                                        colors: [
                                          Colors.white.withValues(alpha: 0.0),
                                          Colors.white.withValues(alpha: 0.25),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════════════
              // CONTENT CARD
              // ═══════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.puzzle.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Status badge
                        _StatusBadge(isUnlocked: isUnlocked),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.puzzle.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Container(
                          height: 1,
                          color: const Color(0xFFF3F4F6),
                        ),
                        const SizedBox(height: 24),

                        // Action area
                        if (isUnlocked)
                          _UnlockedActions()
                        else
                          _LockedActions(
                            puzzle: widget.puzzle,
                            userCoins: state.user.coins,
                            onUnlock: () => _handleUnlock(context),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleUnlock(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    if (state.user.coins >= widget.puzzle.coinCost) {
      context.read<ProfileBloc>().add(UnlockPuzzle(
        puzzleId: widget.puzzle.id,
        cost: widget.puzzle.coinCost,
      ));
      setState(() => _justUnlocked = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justUnlocked = false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.puzzle.title} unlocked! 🎉',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Not enough coins. Complete more tasks to earn coins!',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS BADGE
// ═══════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final bool isUnlocked;

  const _StatusBadge({required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 14,
            color: isUnlocked
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 6),
          Text(
            isUnlocked ? 'Unlocked' : 'Locked',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UNLOCKED ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

class _UnlockedActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info row
        Row(
          children: [
            _InfoChip(
              icon: Icons.calendar_today_rounded,
              label: 'Collected',
              value: 'Today',
            ),
            const SizedBox(width: 12),
            _InfoChip(
              icon: Icons.star_rounded,
              label: 'Rarity',
              value: 'Common',
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Set as wallpaper button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Set as profile artwork!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                ),
              );
            },
            icon: const Icon(Icons.wallpaper_rounded, size: 20),
            label: const Text(
              'Set as Profile Art',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INFO CHIP
// ═══════════════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
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
// LOCKED ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

class _LockedActions extends StatelessWidget {
  final Puzzle puzzle;
  final int userCoins;
  final VoidCallback onUnlock;

  const _LockedActions({
    required this.puzzle,
    required this.userCoins,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final hasEnough = userCoins >= puzzle.coinCost;

    return Column(
      children: [
        // Coin balance row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              // Coin icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Balance',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userCoins coins',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              // Cost badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Cost: ${puzzle.coinCost}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Unlock button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onUnlock,
            icon: Icon(
              hasEnough ? Icons.lock_open_rounded : Icons.lock_rounded,
              size: 20,
            ),
            label: Text(
              hasEnough
                  ? 'Unlock for ${puzzle.coinCost} Coins'
                  : 'Not Enough Coins (${puzzle.coinCost})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasEnough ? AppColors.primary : const Color(0xFF9CA3AF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        if (!hasEnough) ...[
          const SizedBox(height: 12),
          const Text(
            'Complete daily tasks to earn more coins!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ],
    );
  }
}
