/// Represents a single puzzle piece from the backend API.
/// Maps to the `puzzle_pieces` array in GET /api/puzzles response.
class PuzzlePiece {
  final int id;
  final int pieceNumber;
  final bool isOpened;
  final DateTime? openedAt;

  const PuzzlePiece({
    required this.id,
    required this.pieceNumber,
    this.isOpened = false,
    this.openedAt,
  });

  factory PuzzlePiece.fromMap(Map<String, dynamic> map) {
    return PuzzlePiece(
      id: int.tryParse((map['id'] ?? 0).toString()) ?? 0,
      pieceNumber: int.tryParse((map['piece_number'] ?? 0).toString()) ?? 0,
      isOpened: map['is_opened'] == true,
      openedAt: map['opened_at'] != null
          ? DateTime.tryParse(map['opened_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'piece_number': pieceNumber,
      'is_opened': isOpened,
      'opened_at': openedAt?.toIso8601String(),
    };
  }
}

/// Aggregated puzzle data for today from GET /api/puzzles.
class DailyPuzzleData {
  final String date;
  final int puzzleCompletedCount;
  final bool isRestDay;
  final List<PuzzlePiece> puzzlePieces;

  const DailyPuzzleData({
    required this.date,
    this.puzzleCompletedCount = 0,
    this.isRestDay = false,
    this.puzzlePieces = const [],
  });

  /// Number of opened pieces
  int get openedCount => puzzlePieces.where((p) => p.isOpened).length;

  /// Total pieces (max 6)
  int get totalPieces => puzzlePieces.length;

  factory DailyPuzzleData.fromMap(Map<String, dynamic> map) {
    final data = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;

    final piecesRaw = data['puzzle_pieces'];
    final pieces = <PuzzlePiece>[];
    if (piecesRaw is List) {
      for (final p in piecesRaw) {
        if (p is Map<String, dynamic>) {
          pieces.add(PuzzlePiece.fromMap(p));
        }
      }
    }

    return DailyPuzzleData(
      date: data['date']?.toString() ?? '',
      puzzleCompletedCount:
          int.tryParse((data['puzzle_completed_count'] ?? 0).toString()) ?? 0,
      isRestDay: data['is_rest_day'] == true,
      puzzlePieces: pieces,
    );
  }

  /// Empty state for when no data is available
  static const DailyPuzzleData empty = DailyPuzzleData(date: '');
}

/// Static puzzle catalog for the collection screen (unchanged from original usage).
class Puzzle {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final int coinCost;

  const Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.coinCost,
  });
}
