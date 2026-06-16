import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/bloc/task/task_event.dart';
import 'package:mindmate/bloc/task/task_state.dart';
import 'package:mindmate/models/task_model.dart';
import 'package:mindmate/utils/constants.dart';
import 'package:mindmate/networks/api_client.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiClient _client = ApiClient();
  String? _userEmail;

  String _prefKey(String key) => _userEmail != null ? '${_userEmail}_$key' : key;

  Future<void> _saveTasks(List<Task> tasks, List<Task> dailyTasks) async {
    if (_userEmail == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey('tasks'), jsonEncode(tasks.map((t) => t.toMap()).toList()));
    await prefs.setStringList(_prefKey('daily_puzzle_task_ids'), dailyTasks.map((t) => t.id).toList());
    final completedIds = dailyTasks.where((t) => t.isCompleted).map((t) => t.id).toList();
    await prefs.setStringList(_prefKey('daily_completed_ids'), completedIds);
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

    // Also load cached daily task data
    final cachedDailyIds = prefs.getStringList(_prefKey('daily_puzzle_task_ids')) ?? [];
    final cachedDailyCompleted = prefs.getStringList(_prefKey('daily_completed_ids')) ?? [];
    final lastDate = prefs.getString(_prefKey('daily_puzzle_date')) ??
        (rawEmail != null && rawEmail != _userEmail ? prefs.getString('${rawEmail}_daily_puzzle_date') : null);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    try {
      final res = await _client.getTasks();
      List<Task> mergedTasks;
      if (res['status'] == 200 && res['data'] != null) {
        final apiTasks = (res['data'] as List)
            .map((e) => Task.fromMap(e as Map<String, dynamic>))
            .toList();

        final apiIds = apiTasks.map((t) => t.id).toSet();
        final localOnlyTasks = localTasks.where((t) => !apiIds.contains(t.id)).toList();
        mergedTasks = [...apiTasks, ...localOnlyTasks];

        for (final apiTask in apiTasks) {
          final idx = mergedTasks.indexWhere((t) => t.id == apiTask.id);
          if (idx >= 0) {
            mergedTasks[idx] = apiTask;
          }
        }

        // Step 1: Load daily record from API to get completion status
        Set<String> apiCompletedTaskIds = {};
        try {
          final dailyRes = await _client.getDailyRecord();
          if (dailyRes['status'] == 200 && dailyRes['data'] != null) {
            final dailyData = dailyRes['data'] is Map<String, dynamic>
                ? dailyRes['data'] as Map<String, dynamic>
                : null;
            if (dailyData != null) {
              if (dailyData['daily_task_items'] is List) {
                for (final item in dailyData['daily_task_items'] as List) {
                  if (item is Map<String, dynamic>) {
                    final taskId = (item['task_id'] ?? '').toString();
                    final isCompleted = item['is_completed'] == true;
                    if (taskId.isNotEmpty && isCompleted) {
                      apiCompletedTaskIds.add(taskId);
                    }
                  }
                }
              }
            }
          }
        } catch (_) {}

        // Step 2: Apply API completion status to merged tasks
        if (apiCompletedTaskIds.isNotEmpty) {
          for (int i = 0; i < mergedTasks.length; i++) {
            if (apiCompletedTaskIds.contains(mergedTasks[i].id)) {
              mergedTasks[i] = mergedTasks[i].copyWith(
                isCompleted: true,
                isCompletedToday: true,
                isChecked: true,
              );
            }
          }
        }

        // Step 3: Build daily tasks based on date
        List<Task> daily;
        int completedCount;

        if (lastDate != today) {
          // New day: pick up to 6 uncompleted tasks for today's puzzle
          await prefs.setString(_prefKey('daily_puzzle_date'), today);
          await prefs.remove(_prefKey('daily_puzzle_task_ids'));
          await prefs.remove(_prefKey('daily_completed_ids'));

          daily = mergedTasks
              .where((t) => !t.isCompleted)
              .take(AppConstants.maxDailyPuzzleTasks)
              .toList();
          completedCount = 0;
        } else {
          // Same day: restore from saved IDs or API
          if (cachedDailyIds.isNotEmpty) {
            daily = mergedTasks.where((t) => cachedDailyIds.contains(t.id)).toList();
            if (daily.isEmpty) {
              daily = mergedTasks
                  .where((t) => !t.isCompleted)
                  .take(AppConstants.maxDailyPuzzleTasks)
                  .toList();
            }
          } else {
            daily = mergedTasks
                .where((t) => !t.isCompleted)
                .take(AppConstants.maxDailyPuzzleTasks)
                .toList();
          }

          // Count completed from API or cache
          if (apiCompletedTaskIds.isNotEmpty) {
            completedCount = daily.where((t) => apiCompletedTaskIds.contains(t.id)).length;
          } else if (cachedDailyCompleted.isNotEmpty) {
            completedCount = daily.where((t) => cachedDailyCompleted.contains(t.id)).length;
          } else {
            completedCount = daily.where((t) => t.isCompleted).length;
          }
        }

        // Step 4: Save to local cache
        await _saveTasks(mergedTasks, daily);
        await prefs.setStringList(
          _prefKey('daily_puzzle_task_ids'),
          daily.map((t) => t.id).toList(),
        );
        // Save completed task IDs for this daily puzzle
        final completedIds = daily.where((t) => t.isCompleted).map((t) => t.id).toList();
        await prefs.setStringList(_prefKey('daily_completed_ids'), completedIds);

        emit(state.copyWith(
          tasks: mergedTasks,
          dailyPuzzleTasks: daily,
          completedTasksToday: completedCount,
          status: TaskStatus.success,
        ));
      } else {
        if (localTasks.isNotEmpty) {
          // Use local cache with saved daily state
          List<Task> daily = [];
          int completedCount = 0;
          if (lastDate == today && cachedDailyIds.isNotEmpty) {
            daily = localTasks.where((t) => cachedDailyIds.contains(t.id)).toList();
            completedCount = daily.where((t) => t.isCompleted).length;
          }
          emit(state.copyWith(
            tasks: localTasks,
            dailyPuzzleTasks: daily,
            completedTasksToday: completedCount,
            status: TaskStatus.success,
          ));
          return;
        }
        emit(state.copyWith(status: TaskStatus.success));
      }
    } catch (_) {
      if (localTasks.isNotEmpty) {
        List<Task> daily = [];
        int completedCount = 0;
        if (lastDate == today && cachedDailyIds.isNotEmpty) {
          daily = localTasks.where((t) => cachedDailyIds.contains(t.id)).toList();
          completedCount = daily.where((t) => t.isCompleted).length;
        }
        emit(state.copyWith(
          tasks: localTasks,
          dailyPuzzleTasks: daily,
          completedTasksToday: completedCount,
          status: TaskStatus.success,
        ));
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

    final coinReward = AppConstants.baseCoinReward;

    // Emit ONE state with completion result — no second emit after API
    emit(state.copyWith(
      tasks: updatedTasks,
      dailyPuzzleTasks: updatedDaily,
      completedTasksToday: newCompletedCount,
      lastCompletionResult: TaskCompletionResult(
        coinReward: coinReward,
        isStreakAchieved: isStreakAchieved,
        completedTasksToday: newCompletedCount,
      ),
    ));
    await _saveTasks(updatedTasks, updatedDaily);

    // Call API but do NOT emit again — use fire-and-forget
    try {
      await _client.completeTask(event.taskId, source: 'puzzle');
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
