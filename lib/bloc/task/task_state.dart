import 'package:equatable/equatable.dart';
import 'package:application_belajar/models/task_model.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskCompletionResult {
  final int coinReward;
  final bool isStreakAchieved;
  final int completedTasksToday;

  const TaskCompletionResult({
    required this.coinReward,
    required this.isStreakAchieved,
    required this.completedTasksToday,
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

  const TaskState({
    this.status = TaskStatus.initial,
    this.errorMessage = '',
    this.tasks = const [],
    this.dailyPuzzleTasks = const [],
    this.defaultTasks = const [],
    this.completedTasksToday = 0,
    this.hasAskedMoodToday = false,
    this.lastCompletionResult,
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
      ];
}
