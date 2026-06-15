import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_belajar/bloc/task/task_event.dart';
import 'package:application_belajar/bloc/task/task_state.dart';
import 'package:application_belajar/models/task_model.dart';
import 'package:application_belajar/utils/constants.dart';
import 'package:application_belajar/networks/api_client.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiClient _client = ApiClient();
  String? _userEmail;

  String _prefKey(String key) => _userEmail != null ? '${_userEmail}_$key' : key;

  Future<void> _saveTasks(List<Task> tasks, List<Task> dailyTasks) async {
    if (_userEmail == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey('tasks'), jsonEncode(tasks.map((t) => t.toMap()).toList()));
    await prefs.setStringList(_prefKey('daily_puzzle_task_ids'), dailyTasks.map((t) => t.id).toList());
  }

  List<Task>? _loadTasksSync(String json) {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => Task.fromMap(e as Map<String, dynamic>)).toList();
    }
    return null;
  }

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

    final prefs = await SharedPreferences.getInstance();
    final rawEmail = prefs.getString('current_user_email');
    _userEmail = rawEmail?.toLowerCase();

    // Load local cache first
    final cachedTasksJson = prefs.getString(_prefKey('tasks'));
    List<Task> localTasks = [];
    if (cachedTasksJson != null) {
      final loaded = _loadTasksSync(cachedTasksJson);
      if (loaded != null) localTasks = loaded;
    }

    try {
      final res = await _client.getTasks();
      List<Task> mergedTasks;
      if (res['status'] == 200 && res['data'] != null) {
        final apiTasks = (res['data'] as List)
            .map((e) => Task.fromMap(e as Map<String, dynamic>))
            .toList();

        // Merge: API tasks are source of truth, but keep local tasks not in API
        final apiIds = apiTasks.map((t) => t.id).toSet();
        final localOnlyTasks = localTasks.where((t) => !apiIds.contains(t.id)).toList();
        mergedTasks = [...apiTasks, ...localOnlyTasks];

        // Sync API completion status back to local-only tasks
        for (final apiTask in apiTasks) {
          final idx = mergedTasks.indexWhere((t) => t.id == apiTask.id);
          if (idx >= 0) {
            mergedTasks[idx] = apiTask;
          }
        }

        // daily_puzzle_date: lowercase prefixed → original-case prefixed
        final lastDate = prefs.getString(_prefKey('daily_puzzle_date')) ??
            (rawEmail != null && rawEmail != _userEmail ? prefs.getString('${rawEmail}_daily_puzzle_date') : null);
        final today = DateTime.now().toIso8601String().substring(0, 10);

        // Migration: original-case prefixed daily_puzzle_date → lowercase
        if (rawEmail != null && rawEmail != _userEmail && prefs.getString('${rawEmail}_daily_puzzle_date') != null && prefs.getString(_prefKey('daily_puzzle_date')) == null && lastDate != null) {
          await prefs.setString(_prefKey('daily_puzzle_date'), lastDate);
          await prefs.remove('${rawEmail}_daily_puzzle_date');
        }

        List<Task> daily;
        int completedCount;

        if (lastDate != today) {
          await prefs.setString(_prefKey('daily_puzzle_date'), today);
          daily = mergedTasks
              .where((t) => !t.isCompleted)
              .take(AppConstants.maxDailyPuzzleTasks)
              .map((t) => Task(
                    id: t.id,
                    title: t.title,
                    description: t.description,
                    deadline: DateTime.now(),
                    isCompleted: t.isCompleted,
                    createdAt: DateTime.now(),
                    coinReward: t.coinReward,
                  ))
              .toList();
          completedCount = 0;
        } else {
          final savedDailyIds = prefs.getStringList(_prefKey('daily_puzzle_task_ids')) ?? [];
          if (savedDailyIds.isNotEmpty) {
            daily = mergedTasks.where((t) => savedDailyIds.contains(t.id)).toList();
            // If no daily tasks matched saved IDs (e.g. UUID tasks not in API),
            // fall back to rebuilding from merged tasks
            if (daily.isEmpty) {
              daily = mergedTasks
                  .where((t) => !t.isCompleted)
                  .take(AppConstants.maxDailyPuzzleTasks)
                  .map((t) => Task(
                        id: t.id,
                        title: t.title,
                        description: t.description,
                        deadline: DateTime.now(),
                        isCompleted: t.isCompleted,
                        createdAt: DateTime.now(),
                        coinReward: t.coinReward,
                      ))
                  .toList();
            }
          } else {
            daily = state.dailyPuzzleTasks.isNotEmpty
                ? state.dailyPuzzleTasks
                : _buildDailyFrom(mergedTasks);
          }
          completedCount = daily.where((t) => t.isCompleted).length;
        }

        await _saveTasks(mergedTasks, daily);

        emit(state.copyWith(
          tasks: mergedTasks,
          dailyPuzzleTasks: daily,
          completedTasksToday: completedCount,
          status: TaskStatus.success,
        ));
      } else {
        // API failed — use local cache
        if (localTasks.isNotEmpty) {
          emit(state.copyWith(tasks: localTasks, status: TaskStatus.success));
          return;
        }
        emit(state.copyWith(status: TaskStatus.success));
      }
    } catch (_) {
      // Network error — use local cache
      if (localTasks.isNotEmpty) {
        emit(state.copyWith(tasks: localTasks, status: TaskStatus.success));
        return;
      }
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
      await _saveTasks(updatedTasks, updatedDaily);
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
      await _saveTasks(updatedTasks, updatedDaily);
      emit(state.copyWith(tasks: updatedTasks, dailyPuzzleTasks: updatedDaily));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final task = state.tasks.where((t) => t.id == event.taskId).firstOrNull;
    if (task != null && task.isCompleted) return;
    final updatedTasks =
        state.tasks.where((t) => t.id != event.taskId).toList();
    final updatedDaily = state.dailyPuzzleTasks.where((t) => t.id != event.taskId).toList();
    emit(state.copyWith(
      tasks: updatedTasks,
      dailyPuzzleTasks: updatedDaily,
    ));
    await _saveTasks(updatedTasks, updatedDaily);
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
    await _saveTasks(updatedTasks, updatedDaily);
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
    await _saveTasks(updatedTasks, updatedDaily);

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
    _userEmail = null;
    emit(const TaskState());
  }
}
