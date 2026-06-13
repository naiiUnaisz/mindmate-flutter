import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:application_belajar/bloc/profile/profile_event.dart';
import 'package:application_belajar/bloc/profile/profile_state.dart';
import 'package:application_belajar/models/user_model.dart';
import 'package:application_belajar/utils/constants.dart';
import 'package:application_belajar/networks/api_client.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiClient _client = ApiClient();
  ProfileBloc()
      : super(ProfileState(
          user: User(
            id: const Uuid().v4(),
            name: 'An Yujin',
            email: 'user@example.com',
            lastActiveDate: DateTime.now(),
          ),
        )) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateUser>(_onUpdateUser);
    on<EarnCoins>(_onEarnCoins);
    on<SpendCoins>(_onSpendCoins);
    on<IncrementStreak>(_onIncrementStreak);
    on<AddToWeeklyHistory>(_onAddToWeeklyHistory);
    on<UnlockPuzzle>(_onUnlockPuzzle);
    on<LogCoinTransaction>(_onLogCoinTransaction);
    on<ActivateRestDay>(_onActivateRestDay);
    on<CollectDailyPuzzle>(_onCollectDailyPuzzle);
  }

  Future<void> _savePrefs(int coins, int streak, DateTime? lastDate, {DateTime? restDayDate, int? maxStreak}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_coins', coins);
    await prefs.setInt('profile_streak', streak);
    final savedMax = prefs.getInt('max_streak') ?? 0;
    final effectiveMax = maxStreak ?? (streak > savedMax ? streak : savedMax);
    await prefs.setInt('max_streak', effectiveMax);
    if (lastDate != null) {
      await prefs.setString('profile_last_streak_date', lastDate.toIso8601String());
    }
    if (restDayDate != null) {
      await prefs.setString('rest_day_date', restDayDate.toIso8601String());
    } else {
      await prefs.remove('rest_day_date');
    }
  }

  Future<void> _saveWeeklyHistory(Map<String, Map<String, int>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map((k, v) => MapEntry(k, {
      'tasks': v['tasks'] ?? 0,
      'coins': v['coins'] ?? 0,
    }));
    await prefs.setString('weekly_history', jsonEncode(encoded));
  }

  void _checkStreakExpiry(Emitter<ProfileState> emit) {
    final lastDate = state.lastStreakDate;
    if (lastDate == null) return;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDateDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final diff = todayDate.difference(lastDateDay).inDays;
    if (diff <= 1) return;
    final restDay = state.restDayDate;
    final isProtected = restDay != null &&
        DateTime(restDay.year, restDay.month, restDay.day)
            .difference(lastDateDay)
            .inDays ==
            1;
    if (isProtected) {
      emit(state.copyWith(clearRestDayDate: true));
      return;
    }
    emit(state.copyWith(
      user: state.user.copyWith(streak: 0),
      clearLastStreakDate: true,
      clearRestDayDate: true,
    ));
    _savePrefs(state.user.coins, 0, null, restDayDate: null, maxStreak: state.maxStreak);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    final savedCoins = prefs.getInt('profile_coins') ?? 0;
    final savedStreak = prefs.getInt('profile_streak') ?? 0;
    final savedLastDateStr = prefs.getString('profile_last_streak_date');
    final savedLastDate = savedLastDateStr != null ? DateTime.tryParse(savedLastDateStr) : null;
    final savedRestDayStr = prefs.getString('rest_day_date');
    final savedRestDay = savedRestDayStr != null ? DateTime.tryParse(savedRestDayStr) : null;
    final savedMaxStreak = prefs.getInt('max_streak') ?? 0;
    final savedWeeklyStr = prefs.getString('weekly_history');
    Map<String, Map<String, int>> savedWeekly = {};
    if (savedWeeklyStr != null) {
      final decoded = jsonDecode(savedWeeklyStr) as Map<String, dynamic>;
      savedWeekly = decoded.map((k, v) => MapEntry(k, Map<String, int>.from(v as Map)));
    }

    final savedCollected = prefs.getStringList('collected_puzzles') ?? <String>[];

    emit(state.copyWith(
      user: state.user.copyWith(coins: savedCoins, streak: savedStreak),
      lastStreakDate: savedLastDate,
      restDayDate: savedRestDay,
      maxStreak: savedMaxStreak,
      weeklyHistory: savedWeekly,
      collectedPuzzles: savedCollected.toSet(),
    ));
    if (savedLastDate != null) {
      _checkStreakExpiry(emit);
    }

    try {
      final res = await _client.getUser();
      if (res['status'] == 200 && res['user'] != null) {
        var user = User.fromMap(res['user'] as Map<String, dynamic>);

        if (user.coins < state.user.coins) user = user.copyWith(coins: state.user.coins);
        user = user.copyWith(streak: state.user.streak);
        emit(state.copyWith(user: user));
        return;
      }
    } catch (_) {}

    if (savedCoins > 0 || savedStreak > 0) {
      emit(state.copyWith(
        user: state.user.copyWith(coins: savedCoins),
      ));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onEarnCoins(EarnCoins event, Emitter<ProfileState> emit) async {
    final updated = state.user.copyWith(
      coins: state.user.coins + event.amount,
      earnedCoins: state.user.earnedCoins + event.amount,
    );
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': event.reason,
      'title': _transactionTitle(event.reason, event.amount),
      'date': DateTime.now().toIso8601String(),
      'amount': event.amount,
    });
    final now = DateTime.now();
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weekly = Map<String, Map<String, int>>.from(state.weeklyHistory);
    weekly.putIfAbsent(dayKey, () => {'tasks': 0, 'coins': 0});
    weekly[dayKey]!['tasks'] = (weekly[dayKey]!['tasks'] ?? 0) + 1;
    weekly[dayKey]!['coins'] = (weekly[dayKey]!['coins'] ?? 0) + event.amount;

    emit(state.copyWith(user: updated, coinHistory: history, weeklyHistory: weekly));
    _saveWeeklyHistory(weekly);
    try {
      await _client.earnCoins(event.amount, event.reason);
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate, restDayDate: state.restDayDate);
  }

  Future<void> _onSpendCoins(SpendCoins event, Emitter<ProfileState> emit) async {
    if (state.user.coins < event.amount) return;
    final updated = state.user.copyWith(
      coins: state.user.coins - event.amount,
      spentCoins: state.user.spentCoins + event.amount,
    );
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': event.reason,
      'title': _transactionTitle(event.reason, event.amount),
      'date': DateTime.now().toIso8601String(),
      'amount': -event.amount,
    });
    emit(state.copyWith(user: updated, coinHistory: history));
    try {
      await _client.spendCoins(event.amount, event.reason);
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate, restDayDate: state.restDayDate);
  }

  Future<void> _onIncrementStreak(IncrementStreak event, Emitter<ProfileState> emit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = state.lastStreakDate;
    final isNewDay = lastDate == null ||
        DateTime(lastDate.year, lastDate.month, lastDate.day).isBefore(today);

    if (!isNewDay) return;

    final newStreak = state.user.streak + 1;
    final newMax = newStreak > state.maxStreak ? newStreak : state.maxStreak;
    final updated = state.user.copyWith(
      streak: newStreak,
      coins: state.user.coins + AppConstants.completionBonus,
      earnedCoins: state.user.earnedCoins + AppConstants.completionBonus,
      totalTasksCompleted:
          state.user.totalTasksCompleted + AppConstants.maxDailyPuzzleTasks,
    );
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': 'bonus',
      'title': '6 tasks completed today',
      'date': now.toIso8601String(),
      'amount': AppConstants.completionBonus,
    });
    emit(state.copyWith(
      user: updated,
      coinHistory: history,
      lastStreakDate: now,
      clearRestDayDate: true,
      maxStreak: newMax,
    ));
    try {
      await _client.incrementStreak();
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, now, restDayDate: null);
  }

  Future<void> _onActivateRestDay(ActivateRestDay event, Emitter<ProfileState> emit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    emit(state.copyWith(restDayDate: today));
    _savePrefs(state.user.coins, state.user.streak, state.lastStreakDate, restDayDate: today);
  }

  Future<void> _onAddToWeeklyHistory(AddToWeeklyHistory event, Emitter<ProfileState> emit) async {
    final now = DateTime.now();
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weekly = Map<String, Map<String, int>>.from(state.weeklyHistory);
    weekly.putIfAbsent(dayKey, () => {'tasks': 0, 'coins': 0});
    weekly[dayKey]!['tasks'] = (weekly[dayKey]!['tasks'] ?? 0) + event.tasks;
    weekly[dayKey]!['coins'] = (weekly[dayKey]!['coins'] ?? 0) + event.coins;
    emit(state.copyWith(weeklyHistory: weekly));
    _saveWeeklyHistory(weekly);
  }

  Future<void> _onCollectDailyPuzzle(CollectDailyPuzzle event, Emitter<ProfileState> emit) async {
    if (state.collectedPuzzles.contains(event.puzzleId)) return;
    final updated = Set<String>.from(state.collectedPuzzles)..add(event.puzzleId);
    emit(state.copyWith(collectedPuzzles: updated));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('collected_puzzles', updated.toList());
  }

  Future<void> _onUnlockPuzzle(UnlockPuzzle event, Emitter<ProfileState> emit) async {
    if (state.user.coins < event.cost) return;
    if (state.isPuzzleUnlocked(event.puzzleId)) return;
    final updatedPuzzles = Set<String>.from(state.collectedPuzzles)..add(event.puzzleId);
    final updated = state.user.copyWith(
      coins: state.user.coins - event.cost,
      spentCoins: state.user.spentCoins + event.cost,
    );
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': 'exchange',
      'title': 'Unlocked $event.puzzleId',
      'date': DateTime.now().toIso8601String(),
      'amount': -event.cost,
    });
    emit(state.copyWith(user: updated, coinHistory: history, collectedPuzzles: updatedPuzzles));
    try {
      await _client.unlockPuzzle(event.puzzleId, event.cost);
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate, restDayDate: state.restDayDate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('collected_puzzles', updatedPuzzles.toList());
  }

  void _onLogCoinTransaction(LogCoinTransaction event, Emitter<ProfileState> emit) {
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': event.type,
      'title': event.title,
      'date': DateTime.now().toIso8601String(),
      'amount': event.amount,
    });
    emit(state.copyWith(coinHistory: history));
  }

  String _transactionTitle(String type, int amount) {
    switch (type) {
      case 'task':
        return 'Completed 1 task';
      case 'bonus':
        return '6 tasks completed today';
      case 'exchange':
        return 'Coin Exchange';
      case 'reward':
        return 'Reward';
      default:
        return 'Transaction';
    }
  }
}
