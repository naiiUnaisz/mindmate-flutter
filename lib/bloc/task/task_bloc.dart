import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:application_belajar/bloc/task/task_event.dart';
import 'package:application_belajar/bloc/task/task_state.dart';
import 'package:application_belajar/models/task_model.dart';
import 'package:application_belajar/utils/constants.dart';
import 'package:application_belajar/networks/api_client.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiClient _client = ApiClient();

  TaskBloc() : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<UpdateTask>(_onUpdateTask);
    on<CompleteTask>(_onCompleteTask);
    on<AddToDailyPuzzle>(_onAddToDailyPuzzle);
    on<RemoveFromDailyPuzzle>(_onRemoveFromDailyPuzzle);
    on<AddDefaultTask>(_onAddDefaultTask);
    on<RemoveDefaultTask>(_onRemoveDefaultTask);
    on<ResetDailyPuzzle>(_onResetDailyPuzzle);
    on<ClearLastCompletionResult>(_onClearLastCompletionResult);
    on<SetMoodAsked>(_onSetMoodAsked);
    on<ClearTasks>(_onClearTasks);
  }

  List<Task> _buildDailyFrom(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.take(AppConstants.maxDailyPuzzleTasks).map((t) => Task(
      id: t.id,
      title: t.title,
      description: t.description,
      deadline: now,
      isCompleted: t.isCompleted,
      createdAt: now,
      coinReward: t.coinReward,
    )).toList();
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading, tasks: [], dailyPuzzleTasks: [], completedTasksToday: 0));
    try {
      final res = await _client.getTasks();
      if (res['status'] == 200 && res['data'] != null) {
        final list = (res['data'] as List)
            .map((e) => Task.fromMap(e as Map<String, dynamic>))
            .toList();
        final daily = state.dailyPuzzleTasks.isNotEmpty
            ? state.dailyPuzzleTasks
            : _buildDailyFrom(list);
        final completedCount = daily.where((t) => t.isCompleted).length;
        emit(state.copyWith(
          tasks: list,
          dailyPuzzleTasks: daily,
          completedTasksToday: completedCount,
          status: TaskStatus.success,
        ));
      } else {
        emit(state.copyWith(status: TaskStatus.success));
      }
    } catch (_) {
      emit(state.copyWith(status: TaskStatus.success));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final res = await _client.createTask(event.title, event.description, event.deadline);
      final serverTask = res['data'] != null
          ? Task.fromMap(res['data'] as Map<String, dynamic>)
          : Task(
              id: const Uuid().v4(),
              title: event.title,
              description: event.description,
              deadline: event.deadline,
              createdAt: DateTime.now(),
            );

      final updatedTasks = List<Task>.from(state.tasks)..add(serverTask);
      var updatedDaily = List<Task>.from(state.dailyPuzzleTasks);
      if (updatedDaily.length < AppConstants.maxDailyPuzzleTasks) {
        updatedDaily.add(serverTask);
      }
      emit(state.copyWith(tasks: updatedTasks, dailyPuzzleTasks: updatedDaily));
    } catch (_) {
      final task = Task(
        id: const Uuid().v4(),
        title: event.title,
        description: event.description,
        deadline: event.deadline,
        createdAt: DateTime.now(),
      );
      final updatedTasks = List<Task>.from(state.tasks)..add(task);
      var updatedDaily = List<Task>.from(state.dailyPuzzleTasks);
      if (updatedDaily.length < AppConstants.maxDailyPuzzleTasks) {
        updatedDaily.add(task);
      }
      emit(state.copyWith(tasks: updatedTasks, dailyPuzzleTasks: updatedDaily));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(
      tasks: state.tasks.where((t) => t.id != event.taskId).toList(),
      dailyPuzzleTasks:
          state.dailyPuzzleTasks.where((t) => t.id != event.taskId).toList(),
    ));
    try {
      await _client.deleteTask(event.taskId);
    } catch (_) {}
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final updatedTasks = state.tasks.map((t) {
      return t.id == event.taskId
          ? t.copyWith(title: event.title, description: event.description)
          : t;
    }).toList();
    final updatedDaily = state.dailyPuzzleTasks.map((t) {
      return t.id == event.taskId
          ? t.copyWith(title: event.title, description: event.description)
          : t;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks, dailyPuzzleTasks: updatedDaily));
    try {
      await _client.updateTask(event.taskId, event.title, event.description);
    } catch (_) {}
  }

  Future<void> _onCompleteTask(CompleteTask event, Emitter<TaskState> emit) async {
    final taskIndex =
        state.dailyPuzzleTasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex == -1) {
      emit(state.copyWith(lastCompletionResult: null, clearCompletionResult: true));
      return;
    }

    final completedTask = state.dailyPuzzleTasks[taskIndex];
    final updatedDaily = state.dailyPuzzleTasks.toList();
    updatedDaily[taskIndex] = completedTask.copyWith(isCompleted: true);

    final updatedTasks = state.tasks.map((t) =>
      t.id == event.taskId ? t.copyWith(isCompleted: true) : t).toList();

    final newCompletedCount = state.completedTasksToday + 1;
    final isStreakAchieved = newCompletedCount == AppConstants.maxDailyPuzzleTasks;

    emit(state.copyWith(
      tasks: updatedTasks,
      dailyPuzzleTasks: updatedDaily,
      completedTasksToday: newCompletedCount,
      lastCompletionResult: TaskCompletionResult(
        coinReward: completedTask.coinReward,
        isStreakAchieved: isStreakAchieved,
        completedTasksToday: newCompletedCount,
      ),
    ));

    try {
      await _client.completeTask(event.taskId);
    } catch (_) {}
  }

  void _onAddToDailyPuzzle(AddToDailyPuzzle event, Emitter<TaskState> emit) {
    if (state.dailyPuzzleTasks.length >= AppConstants.maxDailyPuzzleTasks) return;
    if (state.dailyPuzzleTasks.any((t) => t.id == event.task.id)) return;
    emit(state.copyWith(dailyPuzzleTasks: [...state.dailyPuzzleTasks, event.task]));
  }

  void _onRemoveFromDailyPuzzle(
      RemoveFromDailyPuzzle event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      dailyPuzzleTasks:
          state.dailyPuzzleTasks.where((t) => t.id != event.taskId).toList(),
    ));
  }

  void _onAddDefaultTask(AddDefaultTask event, Emitter<TaskState> emit) {
    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: event.title,
      description: event.description,
      deadline: now,
      createdAt: now,
    );
    final updatedDefaults = List<Task>.from(state.defaultTasks)..add(task);
    var updatedDaily = List<Task>.from(state.dailyPuzzleTasks);
    if (updatedDaily.length < AppConstants.maxDailyPuzzleTasks) {
      updatedDaily.add(Task(
        id: const Uuid().v4(),
        title: task.title,
        description: task.description,
        deadline: now,
        createdAt: now,
      ));
    }
    emit(state.copyWith(defaultTasks: updatedDefaults, dailyPuzzleTasks: updatedDaily));
  }

  void _onRemoveDefaultTask(RemoveDefaultTask event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      defaultTasks: state.defaultTasks.where((t) => t.title != event.title).toList(),
      dailyPuzzleTasks: state.dailyPuzzleTasks
          .where((t) => !(t.title == event.title && !t.isCompleted))
          .toList(),
    ));
  }

  void _onClearLastCompletionResult(
      ClearLastCompletionResult event, Emitter<TaskState> emit) {
    emit(state.copyWith(lastCompletionResult: null, clearCompletionResult: true));
  }

  void _onResetDailyPuzzle(ResetDailyPuzzle event, Emitter<TaskState> emit) {
    emit(state.copyWith(dailyPuzzleTasks: [], completedTasksToday: 0));
  }

  void _onSetMoodAsked(SetMoodAsked event, Emitter<TaskState> emit) {
    emit(state.copyWith(hasAskedMoodToday: true));
  }

  void _onClearTasks(ClearTasks event, Emitter<TaskState> emit) {
    emit(const TaskState());
  }
}
