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
  String? _userEmail;

  String _prefKey(String key) => _userEmail != null ? '${_userEmail}_$key' : key;

  static User _defaultUser() => User(
    id: const Uuid().v4(),
    name: '',
    email: '',
    lastActiveDate: DateTime.now(),
  );

  ProfileBloc()
      : super(ProfileState(user: _defaultUser())) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateUser>(_onUpdateUser);
    on<EarnCoins>(_onEarnCoins);
    on<SpendCoins>(_onSpendCoins);
    on<IncrementStreak>(_onIncrementStreak);
    on<AddToWeeklyHistory>(_onAddToWeeklyHistory);
    on<UnlockPuzzle>(_onUnlockPuzzle);
    on<LogCoinTransaction>(_onLogCoinTransaction);
    on<ActivateRestDay>(_onActivateRestDay);
    on<DeactivateRestDay>(_onDeactivateRestDay);
    on<CollectDailyPuzzle>(_onCollectDailyPuzzle);
    on<ClearProfile>(_onClearProfile);
  }

  Future<void> _savePrefs(int coins, int streak, DateTime? lastDate,
      {DateTime? restDayDate, int? maxStreak, int? earnedCoins, int? spentCoins, String? name, String? username, String? email, String? gender, DateTime? dateOfBirth}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey('profile_coins'), coins);
    await prefs.setInt(_prefKey('profile_streak'), streak);
    if (name != null) await prefs.setString(_prefKey('profile_name'), name);
    if (username != null) await prefs.setString(_prefKey('profile_username'), username);
    if (email != null) await prefs.setString(_prefKey('profile_email'), email);
    if (gender != null) await prefs.setString(_prefKey('profile_gender'), gender);
    if (dateOfBirth != null) {
      await prefs.setString(_prefKey('profile_date_of_birth'), dateOfBirth.toIso8601String());
    }
    if (earnedCoins != null) await prefs.setInt(_prefKey('profile_earned_coins'), earnedCoins);
    if (spentCoins != null) await prefs.setInt(_prefKey('profile_spent_coins'), spentCoins);
    final savedMax = prefs.getInt(_prefKey('max_streak')) ?? 0;
    final effectiveMax = maxStreak ?? (streak > savedMax ? streak : savedMax);
    await prefs.setInt(_prefKey('max_streak'), effectiveMax);
    if (lastDate != null) {
      await prefs.setString(_prefKey('profile_last_streak_date'), lastDate.toIso8601String());
    } else {
      await prefs.remove(_prefKey('profile_last_streak_date'));
    }
    if (restDayDate != null) {
      await prefs.setString(_prefKey('rest_day_date'), restDayDate.toIso8601String());
    } else {
      await prefs.remove(_prefKey('rest_day_date'));
    }
  }

  Future<void> _saveWeeklyHistory(Map<String, Map<String, int>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map((k, v) => MapEntry(k, {
      'tasks': v['tasks'] ?? 0,
      'coins': v['coins'] ?? 0,
    }));
    await prefs.setString(_prefKey('weekly_history'), jsonEncode(encoded));
  }

  Future<void> _saveCoinHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final filtered = history.where((entry) {
      final date = DateTime.tryParse(entry['date'] ?? '');
      return date != null && date.isAfter(sevenDaysAgo);
    }).toList();
    await prefs.setString(_prefKey('coin_history'), jsonEncode(filtered));
  }

  Future<void> _checkStreakExpiry(Emitter<ProfileState> emit) async {
    final lastDate = state.lastStreakDate;
    if (lastDate == null) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDateDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final daysSinceLastStreak = todayDate.difference(lastDateDay).inDays;

    // Streak still valid (today or yesterday)
    if (daysSinceLastStreak <= 1) return;

    // One missed day but protected by rest day — don't consume it yet,
    // let _onIncrementStreak handle consumption when user completes tasks.
    final restDay = state.restDayDate;
    if (restDay != null &&
        DateTime(restDay.year, restDay.month, restDay.day)
            .difference(lastDateDay)
            .inDays == 1 &&
        daysSinceLastStreak == 2) {
      return;
    }

    // Streak expired — reset
    emit(state.copyWith(
      user: state.user.copyWith(streak: 0),
      clearLastStreakDate: true,
      clearRestDayDate: true,
    ));
    await _savePrefs(state.user.coins, 0, null,
        restDayDate: null, maxStreak: state.maxStreak,
        earnedCoins: state.user.earnedCoins, spentCoins: state.user.spentCoins);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final rawEmail = prefs.getString('current_user_email');
    _userEmail = rawEmail?.toLowerCase();

    int? intPref(String key) =>
        prefs.getInt(_prefKey(key)) ??
        (rawEmail != null && rawEmail != _userEmail ? prefs.getInt('${rawEmail}_$key') : null);
    String? strPref(String key) =>
        prefs.getString(_prefKey(key)) ??
        (rawEmail != null && rawEmail != _userEmail ? prefs.getString('${rawEmail}_$key') : null);
    List<String>? listPref(String key) =>
        prefs.getStringList(_prefKey(key)) ??
        (rawEmail != null && rawEmail != _userEmail ? prefs.getStringList('${rawEmail}_$key') : null);

    final savedCoins = intPref('profile_coins') ?? 0;
    int savedStreak = intPref('profile_streak') ?? 0;
    final savedEarnedCoins = intPref('profile_earned_coins') ?? 0;
    final savedSpentCoins = intPref('profile_spent_coins') ?? 0;
    final savedLastDateStr = strPref('profile_last_streak_date');
    final savedLastDate = savedLastDateStr != null ? DateTime.tryParse(savedLastDateStr) : null;
    final savedRestDayStr = strPref('rest_day_date');
    final savedRestDay = savedRestDayStr != null ? DateTime.tryParse(savedRestDayStr) : null;
    final savedMaxStreak = intPref('max_streak') ?? 0;
    final savedWeeklyStr = strPref('weekly_history');
    Map<String, Map<String, int>> savedWeekly = {};
    if (savedWeeklyStr != null) {
      final decoded = jsonDecode(savedWeeklyStr) as Map<String, dynamic>;
      savedWeekly = decoded.map((k, v) => MapEntry(k, Map<String, int>.from(v as Map)));
    }

    final savedCollected = listPref('collected_puzzles') ?? <String>[];
    final savedName = strPref('profile_name');
    final savedEmail = strPref('profile_email');
    final savedUsername = strPref('profile_username') ?? '';
    final savedGender = strPref('profile_gender') ?? '';
    final savedDobStr = strPref('profile_date_of_birth');
    final savedDob = savedDobStr != null ? DateTime.tryParse(savedDobStr) : null;

    final savedCoinHistoryStr = strPref('coin_history');
    List<Map<String, dynamic>> savedCoinHistory = [];
    if (savedCoinHistoryStr != null) {
      final decoded = jsonDecode(savedCoinHistoryStr) as List;
      savedCoinHistory = decoded.cast<Map<String, dynamic>>();
    }

    // Migration: original-case prefixed keys → lowercase prefixed keys
    if (rawEmail != null && rawEmail != _userEmail && prefs.getInt('${rawEmail}_profile_streak') != null && prefs.getInt(_prefKey('profile_streak')) == null) {
      final savedEarned = intPref('profile_earned_coins');
      final savedSpent = intPref('profile_spent_coins');

      await prefs.setInt(_prefKey('profile_streak'), savedStreak);
      await prefs.setInt(_prefKey('profile_coins'), savedCoins);
      if (savedEarned != null) await prefs.setInt(_prefKey('profile_earned_coins'), savedEarned);
      if (savedSpent != null) await prefs.setInt(_prefKey('profile_spent_coins'), savedSpent);
      if (savedName != null) await prefs.setString(_prefKey('profile_name'), savedName);
      if (savedEmail != null) await prefs.setString(_prefKey('profile_email'), savedEmail);
      if (savedUsername.isNotEmpty) await prefs.setString(_prefKey('profile_username'), savedUsername);
      if (savedGender.isNotEmpty) await prefs.setString(_prefKey('profile_gender'), savedGender);
      if (savedDobStr != null) await prefs.setString(_prefKey('profile_date_of_birth'), savedDobStr);
      if (savedLastDateStr != null) await prefs.setString(_prefKey('profile_last_streak_date'), savedLastDateStr);
      if (savedRestDayStr != null) await prefs.setString(_prefKey('rest_day_date'), savedRestDayStr);
      if (savedMaxStreak > 0) await prefs.setInt(_prefKey('max_streak'), savedMaxStreak);
      if (savedWeeklyStr != null) await prefs.setString(_prefKey('weekly_history'), savedWeeklyStr);
      if (savedCollected.isNotEmpty) await prefs.setStringList(_prefKey('collected_puzzles'), savedCollected.toList());
      await prefs.remove('${rawEmail}_profile_streak');
      await prefs.remove('${rawEmail}_profile_coins');
      await prefs.remove('${rawEmail}_profile_earned_coins');
      await prefs.remove('${rawEmail}_profile_spent_coins');
      await prefs.remove('${rawEmail}_profile_name');
      await prefs.remove('${rawEmail}_profile_username');
      await prefs.remove('${rawEmail}_profile_email');
      await prefs.remove('${rawEmail}_profile_gender');
      await prefs.remove('${rawEmail}_profile_date_of_birth');
      await prefs.remove('${rawEmail}_profile_last_streak_date');
      await prefs.remove('${rawEmail}_rest_day_date');
      await prefs.remove('${rawEmail}_max_streak');
      await prefs.remove('${rawEmail}_weekly_history');
      await prefs.remove('${rawEmail}_collected_puzzles');
    }

    bool didResetStreak = savedStreak == 0;

    // Emit local data immediately for fast UI, then overwrite with API data
    emit(ProfileState(
      user: state.user.copyWith(
        name: savedName ?? state.user.name,
        username: savedUsername,
        email: savedEmail ?? state.user.email,
        gender: savedGender,
        dateOfBirth: savedDob,
        coins: savedCoins,
        streak: savedStreak,
        earnedCoins: savedEarnedCoins,
        spentCoins: savedSpentCoins,
      ),
      coinHistory: savedCoinHistory,
      lastStreakDate: savedLastDate,
      restDayDate: savedRestDay,
      maxStreak: savedMaxStreak,
      weeklyHistory: savedWeekly,
      collectedPuzzles: savedCollected.toSet(),
    ));

    if (savedLastDate != null) {
      await _checkStreakExpiry(emit);
      didResetStreak = state.user.streak == 0;
    }

    // Try API to enrich profile metadata; keep local streak/coins as source of truth
    try {
      final res = await _client.getUser();
      if (res['status'] == 200 && res['user'] != null) {
        var apiUser = User.fromMap(res['user'] as Map<String, dynamic>);

        if (didResetStreak && apiUser.streak > 0) {
          apiUser = apiUser.copyWith(streak: 0);
        }

        // Preserve locally-saved streak, coins, name & totals (per-user keys prevent cross-user issues)
        final merged = apiUser.copyWith(
          coins: state.user.coins,
          streak: state.user.streak,
          earnedCoins: state.user.earnedCoins,
          spentCoins: state.user.spentCoins,
          name: state.user.name.isNotEmpty ? state.user.name : apiUser.name,
          username: state.user.username.isNotEmpty ? state.user.username : apiUser.username,
          gender: state.user.gender.isNotEmpty ? state.user.gender : apiUser.gender,
          dateOfBirth: state.user.dateOfBirth ?? apiUser.dateOfBirth,
        );

        // Persist user metadata from API response for offline resilience
        final p = await SharedPreferences.getInstance();
        if (merged.name.isNotEmpty) await p.setString(_prefKey('profile_name'), merged.name);
        if (merged.username.isNotEmpty) await p.setString(_prefKey('profile_username'), merged.username);
        if (merged.email.isNotEmpty) await p.setString(_prefKey('profile_email'), merged.email);
        if (merged.gender.isNotEmpty) await p.setString(_prefKey('profile_gender'), merged.gender);
        if (merged.dateOfBirth != null) await p.setString(_prefKey('profile_date_of_birth'), merged.dateOfBirth!.toIso8601String());

        emit(ProfileState(
          user: merged,
          coinHistory: state.coinHistory,
          lastStreakDate: state.lastStreakDate,
          restDayDate: state.restDayDate,
          maxStreak: state.maxStreak,
          weeklyHistory: state.weeklyHistory,
          collectedPuzzles: state.collectedPuzzles,
        ));
        return;
      }
    } catch (_) {}
    // API failed — keep local emit as fallback
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(user: event.user));
    _savePrefs(event.user.coins, event.user.streak, state.lastStreakDate,
        restDayDate: state.restDayDate,
        earnedCoins: event.user.earnedCoins, spentCoins: event.user.spentCoins,
        name: event.user.name, username: event.user.username, email: event.user.email,
        gender: event.user.gender, dateOfBirth: event.user.dateOfBirth);
    try {
      await _client.updateProfile(
        name: event.user.name,
        username: event.user.username,
        gender: event.user.gender,
        dateOfBirth: event.user.dateOfBirth,
      );
    } catch (_) {}
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
    _saveCoinHistory(history);
    _saveWeeklyHistory(weekly);
    _savePrefs(updated.coins, state.user.streak, state.lastStreakDate,
        restDayDate: state.restDayDate,
        earnedCoins: updated.earnedCoins, spentCoins: updated.spentCoins);
    try {
      await _client.earnCoins(event.amount, event.reason);
    } catch (_) {}
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
    _saveCoinHistory(history);
    _savePrefs(updated.coins, state.user.streak, state.lastStreakDate,
        restDayDate: state.restDayDate,
        earnedCoins: updated.earnedCoins, spentCoins: updated.spentCoins);
    try {
      await _client.spendCoins(event.amount, event.reason);
    } catch (_) {}
  }

  Future<void> _onIncrementStreak(IncrementStreak event, Emitter<ProfileState> emit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = state.lastStreakDate;

    int newStreak;
    if (lastDate != null) {
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) return;

      if (diff == 1) {
        newStreak = state.user.streak + 1;
      } else if (diff == 2 && state.restDayDate != null) {
        // Rest day protection: user took one day off, now continuing the streak
        final restDay = DateTime(
          state.restDayDate!.year,
          state.restDayDate!.month,
          state.restDayDate!.day,
        );
        if (restDay.difference(lastDay).inDays == 1) {
          newStreak = state.user.streak + 1;
        } else {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

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
    _saveCoinHistory(history);
    _savePrefs(updated.coins, updated.streak, now,
        restDayDate: null, maxStreak: newMax,
        earnedCoins: updated.earnedCoins, spentCoins: updated.spentCoins);
    try {
      await _client.incrementStreak();
    } catch (_) {}
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

  Future<void> _onActivateRestDay(ActivateRestDay event, Emitter<ProfileState> emit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    emit(state.copyWith(restDayDate: today));
    _savePrefs(state.user.coins, state.user.streak, state.lastStreakDate,
        restDayDate: today,
        earnedCoins: state.user.earnedCoins, spentCoins: state.user.spentCoins);
    try {
      await _client.restDay(
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}');
    } catch (_) {}
  }

  Future<void> _onDeactivateRestDay(DeactivateRestDay event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(clearRestDayDate: true));
    _savePrefs(state.user.coins, state.user.streak, state.lastStreakDate,
        earnedCoins: state.user.earnedCoins, spentCoins: state.user.spentCoins);
  }

  void _onClearProfile(ClearProfile event, Emitter<ProfileState> emit) {
    _userEmail = null;
    emit(ProfileState(user: _defaultUser()));
  }

  Future<void> _onCollectDailyPuzzle(CollectDailyPuzzle event, Emitter<ProfileState> emit) async {
    if (state.collectedPuzzles.contains(event.puzzleId)) return;
    final updated = Set<String>.from(state.collectedPuzzles)..add(event.puzzleId);
    emit(state.copyWith(collectedPuzzles: updated));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey('collected_puzzles'), updated.toList());
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
    _saveCoinHistory(history);
    try {
      await _client.unlockPuzzle(event.puzzleId, event.cost);
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate,
        restDayDate: state.restDayDate,
        earnedCoins: updated.earnedCoins, spentCoins: updated.spentCoins);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey('collected_puzzles'), updatedPuzzles.toList());
  }

  Future<void> _onLogCoinTransaction(LogCoinTransaction event, Emitter<ProfileState> emit) async {
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': event.type,
      'title': event.title,
      'date': DateTime.now().toIso8601String(),
      'amount': event.amount,
    });
    emit(state.copyWith(coinHistory: history));
    _saveCoinHistory(history);
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
