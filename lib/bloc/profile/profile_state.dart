import 'package:equatable/equatable.dart';
import 'package:mindmate/models/user_model.dart';
import 'package:mindmate/models/puzzle_model.dart';

const List<Puzzle> allPuzzles = [
  Puzzle(id: 'puzzle_1', title: 'Winter Cabin', description: 'A cozy house blanketed in pristine white snow.', assetPath: 'assets/images/puzzle_1.png', coinCost: 50),
  Puzzle(id: 'puzzle_2', title: 'Lakeside Modern', description: 'A sleek modern house resting by a tranquil lake.', assetPath: 'assets/images/puzzle_2.png', coinCost: 75),
  Puzzle(id: 'puzzle_3', title: 'Misty Pine Forest', description: 'Tall pines silhouetted in a soft lavender mist.', assetPath: 'assets/images/puzzle_3.png', coinCost: 100),
  Puzzle(id: 'puzzle_4', title: 'Purple Peaks', description: 'Majestic mountains rising above the purple clouds.', assetPath: 'assets/images/puzzle_4.png', coinCost: 100),
  Puzzle(id: 'puzzle_5', title: 'Ice River Valley', description: 'A winding frozen river through a snowy mountain pass.', assetPath: 'assets/images/puzzle_5.png', coinCost: 120),
  Puzzle(id: 'puzzle_6', title: 'Spring Meadow', description: 'Green hills and a winding path in a beautiful valley.', assetPath: 'assets/images/puzzle_6.png', coinCost: 150),
  Puzzle(id: 'puzzle_7', title: 'Balloon Festival', description: 'Colorful hot-air balloons floating through a pink sky.', assetPath: 'assets/images/puzzle_7.png', coinCost: 200),
];

int getDailyPuzzleIndex() {
  final daysSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return daysSinceEpoch % 7;
}

String getDailyPuzzleId() => 'puzzle_${getDailyPuzzleIndex() + 1}';

enum ProfileStatus { initial, updating, updated, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User user;
  final List<Map<String, dynamic>> coinHistory;
  final Map<String, Map<String, int>> weeklyHistory;
  final DateTime? lastStreakDate;
  final DateTime? restDayDate;
  final int maxStreak;
  final Set<String> collectedPuzzles;
  final int restDayQuota;
  final int restDayUsed;

  const ProfileState({
    this.status = ProfileStatus.initial,
    required this.user,
    this.coinHistory = const [],
    this.weeklyHistory = const {},
    this.lastStreakDate,
    this.restDayDate,
    this.maxStreak = 0,
    this.collectedPuzzles = const {},
    this.restDayQuota = 0,
    this.restDayUsed = 0,
  });

  int get restDayRemaining => (restDayQuota - restDayUsed).clamp(0, restDayQuota);

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    List<Map<String, dynamic>>? coinHistory,
    Map<String, Map<String, int>>? weeklyHistory,
    DateTime? lastStreakDate,
    DateTime? restDayDate,
    int? maxStreak,
    Set<String>? collectedPuzzles,
    int? restDayQuota,
    int? restDayUsed,
    bool clearLastStreakDate = false,
    bool clearRestDayDate = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      coinHistory: coinHistory ?? this.coinHistory,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      lastStreakDate: clearLastStreakDate
          ? null
          : lastStreakDate ?? this.lastStreakDate,
      restDayDate: clearRestDayDate
          ? null
          : restDayDate ?? this.restDayDate,
      maxStreak: maxStreak ?? this.maxStreak,
      collectedPuzzles: collectedPuzzles ?? this.collectedPuzzles,
      restDayQuota: restDayQuota ?? this.restDayQuota,
      restDayUsed: restDayUsed ?? this.restDayUsed,
    );
  }

  List<Map<String, dynamic>> get weeklyBarData {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));

    final days = <Map<String, dynamic>>[];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final record = weeklyHistory[key];
      days.add({
        'day': dayNames[i],
        'tasks': record?['tasks'] ?? 0,
        'coins': record?['coins'] ?? 0,
      });
    }
    return days;
  }

  int get weeklyCoinDiff {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));

    int thisWeek = 0;
    int lastWeek = 0;

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      thisWeek += weeklyHistory[key]?['coins'] ?? 0;

      final lastDate = date.subtract(const Duration(days: 7));
      final lastKey = '${lastDate.year}-${lastDate.month.toString().padLeft(2, '0')}-${lastDate.day.toString().padLeft(2, '0')}';
      lastWeek += weeklyHistory[lastKey]?['coins'] ?? 0;
    }

    return thisWeek - lastWeek;
  }

  bool isPuzzleUnlocked(String id) {
    return collectedPuzzles.contains(id);
  }

  @override
  List<Object?> get props => [status, user, coinHistory, weeklyHistory, lastStreakDate, restDayDate, maxStreak, collectedPuzzles, restDayQuota, restDayUsed];
}
