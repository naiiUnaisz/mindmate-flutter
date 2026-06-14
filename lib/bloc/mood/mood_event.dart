import 'package:equatable/equatable.dart';

abstract class MoodEvent extends Equatable {
  const MoodEvent();

  @override
  List<Object?> get props => [];
}

class SubmitMood extends MoodEvent {
  final String mood;
  final DateTime date;

  const SubmitMood({required this.mood, required this.date});

  @override
  List<Object?> get props => [mood, date];
}

class LoadMoodHistory extends MoodEvent {}

class LoadTodayMood extends MoodEvent {}

/// Clear all mood data on logout / account switch
class ClearMood extends MoodEvent {}
