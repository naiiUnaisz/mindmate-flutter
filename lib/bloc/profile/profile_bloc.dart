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
  }

  Future<void> _savePrefs(int coins, int streak, DateTime? lastDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_coins', coins);
    await prefs.setInt('profile_streak', streak);
    if (lastDate != null) {
      await prefs.setString('profile_last_streak_date', lastDate.toIso8601String());
    }
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoins = prefs.getInt('profile_coins') ?? 0;
    final savedStreak = prefs.getInt('profile_streak') ?? 0;
    final savedLastDateStr = prefs.getString('profile_last_streak_date');
    final savedLastDate = savedLastDateStr != null ? DateTime.tryParse(savedLastDateStr) : null;

    try {
      final res = await _client.getUser();
      if (res['status'] == 200 && res['user'] != null) {
        var user = User.fromMap(res['user'] as Map<String, dynamic>);
        if (user.coins < savedCoins) user = user.copyWith(coins: savedCoins);
        if (user.streak < savedStreak) user = user.copyWith(streak: savedStreak);
        emit(state.copyWith(user: user, lastStreakDate: savedLastDate));
        return;
      }
    } catch (_) {}

    if (savedCoins > 0 || savedStreak > 0) {
      emit(state.copyWith(
        user: state.user.copyWith(coins: savedCoins, streak: savedStreak),
        lastStreakDate: savedLastDate,
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
    try {
      await _client.earnCoins(event.amount, event.reason);
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate);
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
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate);
  }

  Future<void> _onIncrementStreak(IncrementStreak event, Emitter<ProfileState> emit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = state.lastStreakDate;
    final isNewDay = lastDate == null ||
        DateTime(lastDate.year, lastDate.month, lastDate.day).isBefore(today);

    if (!isNewDay) return;

    final updated = state.user.copyWith(
      streak: state.user.streak + 1,
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
    emit(state.copyWith(user: updated, coinHistory: history, lastStreakDate: now));
    try {
      await _client.incrementStreak();
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, now);
  }

  void _onAddToWeeklyHistory(AddToWeeklyHistory event, Emitter<ProfileState> emit) {
    final now = DateTime.now();
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weekly = Map<String, Map<String, int>>.from(state.weeklyHistory);
    weekly.putIfAbsent(dayKey, () => {'tasks': 0, 'coins': 0});
    weekly[dayKey]!['tasks'] = (weekly[dayKey]!['tasks'] ?? 0) + event.tasks;
    weekly[dayKey]!['coins'] = (weekly[dayKey]!['coins'] ?? 0) + event.coins;
    emit(state.copyWith(weeklyHistory: weekly));
  }

  Future<void> _onUnlockPuzzle(UnlockPuzzle event, Emitter<ProfileState> emit) async {
    if (state.user.coins < event.cost) return;
    if (state.isPuzzleUnlocked(event.puzzleId)) return;
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
    emit(state.copyWith(user: updated, coinHistory: history));
    try {
      await _client.unlockPuzzle(event.puzzleId, event.cost);
    } catch (_) {}
    _savePrefs(updated.coins, updated.streak, state.lastStreakDate);
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
