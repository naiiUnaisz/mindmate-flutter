import 'package:flutter/material.dart';

/// Puzzle grid widget matching the MindMate design exactly.
///
/// Shows a clean 2×3 grid with simple flat colors:
/// - Cream/beige cells
/// - Light lavender cells
/// Pattern (0/6 uncompleted state):
///   Row 1: cream | cream | lavender
///   Row 2: cream | cream | lavender
///
/// When pieces are completed, cells change to show progress.
class PuzzleWidget extends StatelessWidget {
  final int completedPieces;
  final int totalPieces;

  const PuzzleWidget({
    super.key,
    required this.completedPieces,
    required this.totalPieces,
  });

  // Empty/uncompleted cell colors in the grid pattern
  // Matches the exact design: cream + lavender alternating
  static const _cellColors = [
    Color(0xFFF0EADB), // Row 1, Col 1 — cream
    Color(0xFFE5DDF5), // Row 1, Col 2 — lavender
    Color(0xFFF0EADB), // Row 1, Col 3 — cream
    Color(0xFFE5DDF5), // Row 2, Col 1 — lavender
    Color(0xFFF0EADB), // Row 2, Col 2 — cream
    Color(0xFFE5DDF5), // Row 2, Col 3 — lavender
  ];

  // Completed cell colors are no longer needed as we reveal the background


  int get _imageIndex {
    // 1 to 7 based on the current weekday (1=Mon, 7=Sun)
    return ((DateTime.now().weekday - 1) % 7) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEDEDED),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: AspectRatio(
          aspectRatio: 3 / 2, // Standard landscape proportion
          child: Stack(
            children: [
              // The completed landscape background
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/puzzle_$_imageIndex.png',
                  fit: BoxFit.cover,
                ),
              ),
              // The grid overlay for uncompleted pieces
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildCell(0),
                          _buildCell(1),
                          _buildCell(2),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildCell(3),
                          _buildCell(4),
                          _buildCell(5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final isCompleted = index < completedPieces;
    final color = isCompleted
        ? Colors.transparent
        : _cellColors[index % _cellColors.length];

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}


