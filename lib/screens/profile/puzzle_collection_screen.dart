import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/models/puzzle_model.dart';
import 'package:mindmate/bloc/profile/profile_state.dart';
import 'package:mindmate/screens/profile/puzzle_detail_screen.dart';

/// Puzzle Collection screen matching the MindMate UI design.
///
/// Layout:
/// - Back arrow + "Puzzle Collection" title
/// - Featured unlocked puzzle (first item, larger)
/// - 2-column grid of remaining puzzles with lock overlay for locked ones
class PuzzleCollectionScreen extends StatelessWidget {
  const PuzzleCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5EF),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final puzzles = allPuzzles;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ═══════════════════════════════════════
                // HEADER: Back + Title
                // ═══════════════════════════════════════
                SliverToBoxAdapter(
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
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Puzzle Collection',
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
                ),

                // ═══════════════════════════════════════
                // GRID: All puzzles (2 columns)
                // ═══════════════════════════════════════
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.35,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final puzzle = puzzles[index];
                        final isUnlocked =
                            state.isPuzzleUnlocked(puzzle.id);
                        return _PuzzleGridCard(
                          puzzle: puzzle,
                          isUnlocked: isUnlocked,
                          onTap: isUnlocked
                              ? () => _openDetail(context, puzzle)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Complete daily tasks to unlock this puzzle!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                        );
                      },
                      childCount: puzzles.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Puzzle puzzle) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => PuzzleDetailScreen(puzzle: puzzle),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PUZZLE GRID CARD (smaller, with lock overlay when locked)
// ═══════════════════════════════════════════════════════════════════════════

class _PuzzleGridCard extends StatelessWidget {
  final Puzzle puzzle;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _PuzzleGridCard({
    required this.puzzle,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'puzzle_${puzzle.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background color in case image is transparent
                Container(color: Colors.white),
                // Image
                Image.asset(
                  puzzle.assetPath,
                  fit: BoxFit.cover,
                ),

                // Locked overlay
                if (!isUnlocked) ...[
                  // Semi-transparent purple-white tint
                  Container(
                    color: const Color(0xFFE8DFFF).withValues(alpha: 0.65),
                  ),
                  // Lock icon centered
                  const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF1F2937),
                      size: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
