import 'package:equatable/equatable.dart';
import 'package:application_belajar/models/user_model.dart';
import 'package:application_belajar/models/puzzle_model.dart';

class ProfileState extends Equatable {
  final User user;
  final List<Map<String, dynamic>> coinHistory;
  final Map<String, Map<String, int>> weeklyHistory;
  final DateTime? lastStreakDate;

  const ProfileState({
    required this.user,
    this.coinHistory = const [],
    this.weeklyHistory = const {},
    this.lastStreakDate,
  });

  ProfileState copyWith({
    User? user,
    List<Map<String, dynamic>>? coinHistory,
    Map<String, Map<String, int>>? weeklyHistory,
    DateTime? lastStreakDate,
    bool clearLastStreakDate = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      coinHistory: coinHistory ?? this.coinHistory,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      lastStreakDate: clearLastStreakDate
          ? null
          : lastStreakDate ?? this.lastStreakDate,
    );
  }

  List<Map<String, dynamic>> get weeklyBarData {
    final now = DateTime.now();
    final days = <Map<String, dynamic>>[];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final record = weeklyHistory[key];
      days.add({
        'day': dayNames[date.weekday - 1],
        'tasks': record?['tasks'] ?? 0,
        'coins': record?['coins'] ?? 0,
      });
    }
    return days;
  }

  bool isPuzzleUnlocked(String id) {
    const puzzles = [
      Puzzle(id: 'puzzle_1', title: 'Winter Cabin', description: 'A cozy house blanketed in pristine white snow.', assetPath: 'assets/images/puzzle_1.png', coinCost: 50),
      Puzzle(id: 'puzzle_2', title: 'Lakeside Modern', description: 'A sleek modern house resting by a tranquil lake.', assetPath: 'assets/images/puzzle_2.png', coinCost: 75),
      Puzzle(id: 'puzzle_3', title: 'Misty Pine Forest', description: 'Tall pines silhouetted in a soft lavender mist.', assetPath: 'assets/images/puzzle_3.png', coinCost: 100),
      Puzzle(id: 'puzzle_4', title: 'Purple Peaks', description: 'Majestic mountains rising above the purple clouds.', assetPath: 'assets/images/puzzle_4.png', coinCost: 100),
      Puzzle(id: 'puzzle_5', title: 'Ice River Valley', description: 'A winding frozen river through a snowy mountain pass.', assetPath: 'assets/images/puzzle_5.png', coinCost: 120),
      Puzzle(id: 'puzzle_6', title: 'Spring Meadow', description: 'Green hills and a winding path in a beautiful valley.', assetPath: 'assets/images/puzzle_6.png', coinCost: 150),
      Puzzle(id: 'puzzle_7', title: 'Balloon Festival', description: 'Colorful hot-air balloons floating through a pink sky.', assetPath: 'assets/images/puzzle_7.png', coinCost: 200),
    ];
    final index = puzzles.indexWhere((p) => p.id == id);
    if (index < 0) return false;
    return user.streak >= (index + 1);
  }

  @override
  List<Object?> get props => [user, coinHistory, weeklyHistory, lastStreakDate];
}
