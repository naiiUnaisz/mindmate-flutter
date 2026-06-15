import 'package:equatable/equatable.dart';
import 'package:application_belajar/models/task_model.dart';
import 'package:application_belajar/models/puzzle_model.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskCompletionResult {
  final int coinReward;
  final bool isStreakAchieved;
  final int completedTasksToday;
  final int? currentCoinBalance;
  final int? currentStreak;
  final bool puzzleOpened;

  const TaskCompletionResult({
    required this.coinReward,
    required this.isStreakAchieved,
    required this.completedTasksToday,
    this.currentCoinBalance,
    this.currentStreak,
    this.puzzleOpened = false,
  });
}

class TaskState extends Equatable {
  final TaskStatus status;
  final String errorMessage;
  final List<Task> tasks;
  final List<Task> dailyPuzzleTasks;
  final List<Task> defaultTasks;
  final int completedTasksToday;
  final bool hasAskedMoodToday;
  final TaskCompletionResult? lastCompletionResult;

  // Server-driven puzzle data
  final DailyPuzzleData dailyPuzzleData;
  final String? lastLoadedDate; // For daily reset detection

  const TaskState({
    this.status = TaskStatus.initial,
    this.errorMessage = '',
    this.tasks = const [],
    this.dailyPuzzleTasks = const [],
    this.defaultTasks = const [],
    this.completedTasksToday = 0,
    this.hasAskedMoodToday = false,
    this.lastCompletionResult,
    this.dailyPuzzleData = DailyPuzzleData.empty,
    this.lastLoadedDate,
  });

  TaskState copyWith({
    TaskStatus? status,
    String? errorMessage,
    List<Task>? tasks,
    List<Task>? dailyPuzzleTasks,
    List<Task>? defaultTasks,
    int? completedTasksToday,
    bool? hasAskedMoodToday,
    TaskCompletionResult? lastCompletionResult,
    bool clearCompletionResult = false,
    DailyPuzzleData? dailyPuzzleData,
    String? lastLoadedDate,
  }) {
    return TaskState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tasks: tasks ?? this.tasks,
      dailyPuzzleTasks: dailyPuzzleTasks ?? this.dailyPuzzleTasks,
      defaultTasks: defaultTasks ?? this.defaultTasks,
      completedTasksToday: completedTasksToday ?? this.completedTasksToday,
      hasAskedMoodToday: hasAskedMoodToday ?? this.hasAskedMoodToday,
      lastCompletionResult:
          clearCompletionResult ? null : lastCompletionResult ?? this.lastCompletionResult,
      dailyPuzzleData: dailyPuzzleData ?? this.dailyPuzzleData,
      lastLoadedDate: lastLoadedDate ?? this.lastLoadedDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        tasks,
        dailyPuzzleTasks,
        defaultTasks,
        completedTasksToday,
        hasAskedMoodToday,
        lastCompletionResult,
        dailyPuzzleData,
        lastLoadedDate,
      ];
}
