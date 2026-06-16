import 'package:equatable/equatable.dart';
import 'package:mindmate/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final String? description;
  final DateTime deadline;

  const AddTask({
    required this.title,
    this.description,
    required this.deadline,
  });

  @override
  List<Object?> get props => [title, description, deadline];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class UpdateTask extends TaskEvent {
  final String taskId;
  final String title;
  final String? description;

  const UpdateTask({
    required this.taskId,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [taskId, title, description];
}

class CompleteTask extends TaskEvent {
  final String taskId;

  const CompleteTask({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class AddToDailyPuzzle extends TaskEvent {
  final Task task;

  const AddToDailyPuzzle({required this.task});

  @override
  List<Object?> get props => [task];
}

class RemoveFromDailyPuzzle extends TaskEvent {
  final String taskId;

  const RemoveFromDailyPuzzle({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class AddDefaultTask extends TaskEvent {
  final String title;
  final String? description;

  const AddDefaultTask({required this.title, this.description});

  @override
  List<Object?> get props => [title, description];
}

class RemoveDefaultTask extends TaskEvent {
  final String title;

  const RemoveDefaultTask({required this.title});

  @override
  List<Object?> get props => [title];
}

class ResetDailyPuzzle extends TaskEvent {}

class ClearLastCompletionResult extends TaskEvent {}

class SetMoodAsked extends TaskEvent {}

class ClearTasks extends TaskEvent {}

class RefreshPuzzles extends TaskEvent {}

class UnlockPuzzlePiece extends TaskEvent {}
