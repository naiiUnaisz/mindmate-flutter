import 'package:equatable/equatable.dart';
import 'package:mindmate/models/mood_model.dart';

enum MoodStatus { initial, loading, success, failure }

class MoodState extends Equatable {
  final MoodStatus status;
  final String errorMessage;
  final List<Mood> moodHistory;
  final Mood? todayMood;

  const MoodState({
    this.status = MoodStatus.initial,
    this.errorMessage = '',
    this.moodHistory = const [],
    this.todayMood,
  });

  int get weeklyMoodCount {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return moodHistory.where((m) => m.date.isAfter(cutoff)).length;
  }

  List<Mood> get weeklyMoods {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return moodHistory.where((m) => m.date.isAfter(cutoff)).toList();
  }

  MoodState copyWith({
    MoodStatus? status,
    String? errorMessage,
    List<Mood>? moodHistory,
    Mood? todayMood,
    bool clearTodayMood = false,
  }) {
    return MoodState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      moodHistory: moodHistory ?? this.moodHistory,
      todayMood: clearTodayMood ? null : todayMood ?? this.todayMood,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, moodHistory, todayMood];
}
