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

  String _prefKey(String key) =>
      _userEmail != null ? '${_userEmail}_$key' : key;

  static User _defaultUser() => User(
    id: const Uuid().v4(),
    name: '',
    email: '',
    lastActiveDate: DateTime.now(),
  );

  ProfileBloc() : super(ProfileState(user: _defaultUser())) {
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

  Future<void> _savePrefs(
    int coins,
    int streak,
    DateTime? lastDate, {
    DateTime? restDayDate,
    int? maxStreak,
    int? earnedCoins,
    int? spentCoins,
    String? name,
    String? username,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey('profile_coins'), coins);
    await prefs.setInt(_prefKey('profile_streak'), streak);
    if (name != null) await prefs.setString(_prefKey('profile_name'), name);
    if (username != null)
      await prefs.setString(_prefKey('profile_username'), username);
    if (email != null) await prefs.setString(_prefKey('profile_email'), email);
    if (gender != null)
      await prefs.setString(_prefKey('profile_gender'), gender);
    if (dateOfBirth != null) {
      await prefs.setString(
        _prefKey('profile_date_of_birth'),
        dateOfBirth.toIso8601String(),
      );
    }
    if (earnedCoins != null)
      await prefs.setInt(_prefKey('profile_earned_coins'), earnedCoins);
    if (spentCoins != null)
      await prefs.setInt(_prefKey('profile_spent_coins'), spentCoins);
    final savedMax = prefs.getInt(_prefKey('max_streak')) ?? 0;
    final effectiveMax = maxStreak ?? (streak > savedMax ? streak : savedMax);
    await prefs.setInt(_prefKey('max_streak'), effectiveMax);
    if (lastDate != null) {
      await prefs.setString(
        _prefKey('profile_last_streak_date'),
        lastDate.toIso8601String(),
      );
    } else {
      await prefs.remove(_prefKey('profile_last_streak_date'));
    }
    if (restDayDate != null) {
      await prefs.setString(
        _prefKey('rest_day_date'),
        restDayDate.toIso8601String(),
      );
    } else {
      await prefs.remove(_prefKey('rest_day_date'));
    }
  }

  Future<void> _saveProfileFields(User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.name.isNotEmpty)
      await prefs.setString(_prefKey('profile_name'), user.name);
    if (user.username.isNotEmpty)
      await prefs.setString(_prefKey('profile_username'), user.username);
    if (user.email.isNotEmpty)
      await prefs.setString(_prefKey('profile_email'), user.email);
    if (user.gender.isNotEmpty)
      await prefs.setString(_prefKey('profile_gender'), user.gender);
    if (user.dateOfBirth != null)
      await prefs.setString(
        _prefKey('profile_date_of_birth'),
        user.dateOfBirth!.toIso8601String(),
      );
    if (user.avatar != null)
      await prefs.setString(_prefKey('profile_avatar'), user.avatar!);
  }

  Future<void> _saveWeeklyHistory(Map<String, Map<String, int>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map(
      (k, v) =>
          MapEntry(k, {'tasks': v['tasks'] ?? 0, 'coins': v['coins'] ?? 0}),
    );
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
        DateTime(
              restDay.year,
              restDay.month,
              restDay.day,
            ).difference(lastDateDay).inDays ==
            1 &&
        daysSinceLastStreak == 2) {
      return;
    }

    // Streak expired — reset
    emit(
      state.copyWith(
        user: state.user.copyWith(streak: 0),
        clearLastStreakDate: true,
        clearRestDayDate: true,
      ),
    );
    await _savePrefs(
      state.user.coins,
      0,
      null,
      restDayDate: null,
      maxStreak: state.maxStreak,
      earnedCoins: state.user.earnedCoins,
      spentCoins: state.user.spentCoins,
    );
    await _saveProfileFields(state.user);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rawEmail = prefs.getString('current_user_email');
    _userEmail = rawEmail?.toLowerCase();

    int? intPref(String key) =>
        prefs.getInt(_prefKey(key)) ??
        (rawEmail != null && rawEmail != _userEmail
            ? prefs.getInt('${rawEmail}_$key')
            : null);
    String? strPref(String key) =>
        prefs.getString(_prefKey(key)) ??
        (rawEmail != null && rawEmail != _userEmail
            ? prefs.getString('${rawEmail}_$key')
            : null);
    List<String>? listPref(String key) =>
        prefs.getStringList(_prefKey(key)) ??
        (rawEmail != null && rawEmail != _userEmail
            ? prefs.getStringList('${rawEmail}_$key')
            : null);

    final localCoins = intPref('profile_coins') ?? 0;
    int localStreak = intPref('profile_streak') ?? 0;
    final localEarnedCoins = intPref('profile_earned_coins') ?? 0;
    final localSpentCoins = intPref('profile_spent_coins') ?? 0;
    final localLastDateStr = strPref('profile_last_streak_date');
    final localLastDate = localLastDateStr != null
        ? DateTime.tryParse(localLastDateStr)
        : null;
    final localRestDayStr = strPref('rest_day_date');
    final localRestDay = localRestDayStr != null
        ? DateTime.tryParse(localRestDayStr)
        : null;
    final localMaxStreak = intPref('max_streak') ?? 0;
    final localWeeklyStr = strPref('weekly_history');
    Map<String, Map<String, int>> localWeekly = {};
    if (localWeeklyStr != null) {
      final decoded = jsonDecode(localWeeklyStr) as Map<String, dynamic>;
      localWeekly = decoded.map(
        (k, v) => MapEntry(k, Map<String, int>.from(v as Map)),
      );
    }

    final localCollected = listPref('collected_puzzles') ?? <String>[];
    final localName = strPref('profile_name');
    final localEmail = strPref('profile_email');
    final localUsername = strPref('profile_username') ?? '';
    final localGender = strPref('profile_gender') ?? '';
    final localDobStr = strPref('profile_date_of_birth');
    final localDob = localDobStr != null
        ? DateTime.tryParse(localDobStr)
        : null;
    final localAvatar = strPref('profile_avatar');

    final localCoinHistoryStr = strPref('coin_history');
    List<Map<String, dynamic>> localCoinHistory = [];
    if (localCoinHistoryStr != null) {
      final decoded = jsonDecode(localCoinHistoryStr) as List;
      localCoinHistory = decoded.cast<Map<String, dynamic>>();
    }

    // Migration: original-case prefixed keys → lowercase prefixed keys
    if (rawEmail != null &&
        rawEmail != _userEmail &&
        prefs.getInt('${rawEmail}_profile_streak') != null &&
        prefs.getInt(_prefKey('profile_streak')) == null) {
      await prefs.setInt(_prefKey('profile_streak'), localStreak);
      await prefs.setInt(_prefKey('profile_coins'), localCoins);
      if (localName != null)
        await prefs.setString(_prefKey('profile_name'), localName);
      if (localEmail != null)
        await prefs.setString(_prefKey('profile_email'), localEmail);
      if (localUsername.isNotEmpty)
        await prefs.setString(_prefKey('profile_username'), localUsername);
      if (localGender.isNotEmpty)
        await prefs.setString(_prefKey('profile_gender'), localGender);
      if (localDobStr != null)
        await prefs.setString(_prefKey('profile_date_of_birth'), localDobStr);
      if (localLastDateStr != null)
        await prefs.setString(
          _prefKey('profile_last_streak_date'),
          localLastDateStr,
        );
      if (localRestDayStr != null)
        await prefs.setString(_prefKey('rest_day_date'), localRestDayStr);
      if (localMaxStreak > 0)
        await prefs.setInt(_prefKey('max_streak'), localMaxStreak);
      if (localWeeklyStr != null)
        await prefs.setString(_prefKey('weekly_history'), localWeeklyStr);
      if (localCollected.isNotEmpty)
        await prefs.setStringList(
          _prefKey('collected_puzzles'),
          localCollected.toList(),
        );
      await prefs.remove('${rawEmail}_profile_streak');
      await prefs.remove('${rawEmail}_profile_coins');
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

    // ── Step 1: Emit local data immediately for fast UI ──
    emit(
      ProfileState(
        user: state.user.copyWith(
          name: localName ?? state.user.name,
          username: localUsername,
          email: localEmail ?? state.user.email,
          gender: localGender,
          dateOfBirth: localDob,
          avatar: localAvatar,
          coins: localCoins,
          streak: localStreak,
          earnedCoins: localEarnedCoins,
          spentCoins: localSpentCoins,
        ),
        coinHistory: localCoinHistory,
        lastStreakDate: localLastDate,
        restDayDate: localRestDay,
        maxStreak: localMaxStreak,
        weeklyHistory: localWeekly,
        collectedPuzzles: localCollected.toSet(),
      ),
    );

    if (localLastDate != null) {
      await _checkStreakExpiry(emit);
    }

    // ── Step 2: Try API to enrich (source of truth for profile fields) ──
    try {
      final res = await _client.getUser();
      if (res['status'] == 200 && res['user'] != null) {
        final apiUser = User.fromMap(res['user'] as Map<String, dynamic>);

        final mergedCoins = localCoins > apiUser.coins
            ? localCoins
            : apiUser.coins;
        final mergedStreak = localStreak > apiUser.streak
            ? localStreak
            : apiUser.streak;
        // earnedCoins & spentCoins tidak ada di backend — selalu pakai lokal
        final mergedEarned = localEarnedCoins;
        final mergedSpent = localSpentCoins;

        final merged = apiUser.copyWith(
          coins: mergedCoins,
          streak: mergedStreak,
          earnedCoins: mergedEarned,
          spentCoins: mergedSpent,
          name: apiUser.name.isNotEmpty
              ? apiUser.name
              : (localName ?? state.user.name),
          username: apiUser.username.isNotEmpty
              ? apiUser.username
              : (localUsername.isNotEmpty
                    ? localUsername
                    : state.user.username),
          email: apiUser.email.isNotEmpty
              ? apiUser.email
              : (localEmail ?? state.user.email),
          gender: apiUser.gender.isNotEmpty
              ? apiUser.gender
              : (localGender.isNotEmpty ? localGender : state.user.gender),
          dateOfBirth:
              apiUser.dateOfBirth ?? (localDob ?? state.user.dateOfBirth),
          avatar: apiUser.avatar ?? localAvatar,
        );

        final p = await SharedPreferences.getInstance();
        await p.setInt(_prefKey('profile_coins'), merged.coins);
        await p.setInt(_prefKey('profile_streak'), merged.streak);
        await p.setInt(_prefKey('profile_earned_coins'), merged.earnedCoins);
        await p.setInt(_prefKey('profile_spent_coins'), merged.spentCoins);
        if (merged.name.isNotEmpty)
          await p.setString(_prefKey('profile_name'), merged.name);
        if (merged.username.isNotEmpty)
          await p.setString(_prefKey('profile_username'), merged.username);
        if (merged.email.isNotEmpty)
          await p.setString(_prefKey('profile_email'), merged.email);
        if (merged.gender.isNotEmpty)
          await p.setString(_prefKey('profile_gender'), merged.gender);
        if (merged.dateOfBirth != null)
          await p.setString(
            _prefKey('profile_date_of_birth'),
            merged.dateOfBirth!.toIso8601String(),
          );
        if (merged.avatar != null)
          await p.setString(_prefKey('profile_avatar'), merged.avatar!);

        emit(
          ProfileState(
            user: merged,
            coinHistory: localCoinHistory,
            lastStreakDate: localLastDate,
            restDayDate: localRestDay,
            maxStreak: localMaxStreak,
            weeklyHistory: localWeekly,
            collectedPuzzles: localCollected.toSet(),
          ),
        );

        // Try enriching coin history from API
        try {
          final coinRes = await _client.getCoinHistory();
          if (coinRes['status'] == 200) {
            final apiData = coinRes['data'] ?? coinRes['history'] ?? [];
            if (apiData is List && apiData.isNotEmpty) {
              final parsed = apiData.cast<Map<String, dynamic>>();
              emit(state.copyWith(coinHistory: parsed));
              await _saveCoinHistory(parsed);
            }
          }
        } catch (_) {}

        // Try enriching streak from API
        try {
          final streakRes = await _client.getStreak();
          if (streakRes['status'] == 200) {
            // Response: {"success":true,"data":{"current_streak":"1","restday_quota":"1"}}
            final data = streakRes['data'];
            if (data is Map<String, dynamic>) {
              final apiStreak =
                  int.tryParse(
                    (data['current_streak'] ?? data['streak'] ?? 0).toString(),
                  ) ??
                  0;
              if (apiStreak > state.user.streak) {
                emit(
                  state.copyWith(user: state.user.copyWith(streak: apiStreak)),
                );
                final p = await SharedPreferences.getInstance();
                await p.setInt(_prefKey('profile_streak'), apiStreak);
              }
            }
          }
        } catch (_) {}

      }
    } catch (_) {}

    // Try puzzles from API
    try {
      final puzzleRes = await _client.getPuzzles();
      if (puzzleRes['status'] == 200) {
        var data = puzzleRes['puzzles'] ?? puzzleRes['data'] ?? [];
        if (data is Map<String, dynamic> && data.containsKey('puzzle_pieces')) {
          data = data['puzzle_pieces'];
        }
        if (data is List) {
          Set<String> puzzlesFromApi = {};
          for (final p in data) {
            if (p is Map<String, dynamic>) {
              final pid = p['puzzle_id'] ?? p['id'];
              final isUnlocked = p['unlocked'] == true || p['is_unlocked'] == true;
              if (pid != null && (isUnlocked || !p.containsKey('unlocked'))) {
                puzzlesFromApi.add(pid.toString());
              }
            }
          }
          if (puzzlesFromApi.isNotEmpty) {
            final mergedPuzzles = Set<String>.from(state.collectedPuzzles)
              ..addAll(puzzlesFromApi);
            emit(state.copyWith(collectedPuzzles: mergedPuzzles));
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList(_prefKey('collected_puzzles'), mergedPuzzles.toList());
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<ProfileState> emit,
  ) async {
    // 1. Optimistic update — emit langsung ke UI
    emit(state.copyWith(user: event.user));

    // 2. Simpan ke SharedPreferences segera (data tidak hilang saat app close)
    await _savePrefs(
      event.user.coins,
      event.user.streak,
      state.lastStreakDate,
      restDayDate: state.restDayDate,
      earnedCoins: event.user.earnedCoins,
      spentCoins: event.user.spentCoins,
      name: event.user.name,
      username: event.user.username,
      email: event.user.email,
      gender: event.user.gender,
      dateOfBirth: event.user.dateOfBirth,
    );
    await _saveProfileFields(event.user);

    // 3. Kirim ke API dan update prefs dengan response dari backend
    try {
      final res = await _client.updateProfile(
        name: event.user.name,
        username: event.user.username,
        gender: event.user.gender,
        dateOfBirth: event.user.dateOfBirth,
        avatar: event.user.avatar,
      );
      if (res['status'] == 200 && res['user'] is Map) {
        final apiUser = User.fromMap(res['user'] as Map<String, dynamic>);
        // Merge: gunakan data API untuk profile fields, tapi pertahankan coins/streak lokal
        final merged = apiUser.copyWith(
          coins: event.user.coins,
          streak: event.user.streak,
          earnedCoins: event.user.earnedCoins,
          spentCoins: event.user.spentCoins,
          avatar: event.user.avatar ?? apiUser.avatar,
        );
        emit(state.copyWith(user: merged));
        await _saveProfileFields(merged);
      }
    } catch (_) {
      // API gagal — data lokal sudah tersimpan, tidak perlu rollback
    }
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

    emit(
      state.copyWith(
        user: updated,
        coinHistory: history,
        weeklyHistory: weekly,
      ),
    );
    await _saveCoinHistory(history);
    await _saveWeeklyHistory(weekly);
    await _savePrefs(
      updated.coins,
      state.user.streak,
      state.lastStreakDate,
      restDayDate: state.restDayDate,
      earnedCoins: updated.earnedCoins,
      spentCoins: updated.spentCoins,
    );
    await _saveProfileFields(state.user);
    try {
      await _client.earnCoins(event.amount, event.reason);
    } catch (_) {}
  }

  Future<void> _onSpendCoins(
    SpendCoins event,
    Emitter<ProfileState> emit,
  ) async {
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
    await _saveCoinHistory(history);
    await _savePrefs(
      updated.coins,
      state.user.streak,
      state.lastStreakDate,
      restDayDate: state.restDayDate,
      earnedCoins: updated.earnedCoins,
      spentCoins: updated.spentCoins,
    );
    await _saveProfileFields(state.user);
    try {
      await _client.spendCoins(event.amount, event.reason);
    } catch (_) {}
  }

  Future<void> _onIncrementStreak(
    IncrementStreak event,
    Emitter<ProfileState> emit,
  ) async {
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
    emit(
      state.copyWith(
        user: updated,
        coinHistory: history,
        lastStreakDate: now,
        clearRestDayDate: true,
        maxStreak: newMax,
      ),
    );
    await _saveCoinHistory(history);
    await _savePrefs(
      updated.coins,
      updated.streak,
      now,
      restDayDate: null,
      maxStreak: newMax,
      earnedCoins: updated.earnedCoins,
      spentCoins: updated.spentCoins,
    );
    await _saveProfileFields(state.user);
    try {
      await _client.incrementStreak();
    } catch (_) {}
  }

  Future<void> _onAddToWeeklyHistory(
    AddToWeeklyHistory event,
    Emitter<ProfileState> emit,
  ) async {
    final now = DateTime.now();
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weekly = Map<String, Map<String, int>>.from(state.weeklyHistory);
    weekly.putIfAbsent(dayKey, () => {'tasks': 0, 'coins': 0});
    weekly[dayKey]!['tasks'] = (weekly[dayKey]!['tasks'] ?? 0) + event.tasks;
    weekly[dayKey]!['coins'] = (weekly[dayKey]!['coins'] ?? 0) + event.coins;
    emit(state.copyWith(weeklyHistory: weekly));
    await _saveWeeklyHistory(weekly);
  }

  Future<void> _onActivateRestDay(
    ActivateRestDay event,
    Emitter<ProfileState> emit,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    emit(state.copyWith(restDayDate: today));
    await _savePrefs(
      state.user.coins,
      state.user.streak,
      state.lastStreakDate,
      restDayDate: today,
      earnedCoins: state.user.earnedCoins,
      spentCoins: state.user.spentCoins,
    );
    await _saveProfileFields(state.user);
    try {
      await _client.restDay(
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      );
    } catch (_) {}
  }

  Future<void> _onDeactivateRestDay(
    DeactivateRestDay event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(clearRestDayDate: true));
    await _savePrefs(
      state.user.coins,
      state.user.streak,
      state.lastStreakDate,
      earnedCoins: state.user.earnedCoins,
      spentCoins: state.user.spentCoins,
    );
    await _saveProfileFields(state.user);
  }

  void _onClearProfile(ClearProfile event, Emitter<ProfileState> emit) {
    _userEmail = null;
    emit(ProfileState(user: _defaultUser()));
  }

  Future<void> _onCollectDailyPuzzle(
    CollectDailyPuzzle event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.collectedPuzzles.contains(event.puzzleId)) return;
    final updated = Set<String>.from(state.collectedPuzzles)
      ..add(event.puzzleId);
    emit(state.copyWith(collectedPuzzles: updated));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey('collected_puzzles'), updated.toList());
    try {
      await _client.unlockPuzzle(event.puzzleId, 0);
    } catch (_) {}
  }

  Future<void> _onUnlockPuzzle(
    UnlockPuzzle event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user.coins < event.cost) return;
    if (state.isPuzzleUnlocked(event.puzzleId)) return;
    final updatedPuzzles = Set<String>.from(state.collectedPuzzles)
      ..add(event.puzzleId);
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
    emit(
      state.copyWith(
        user: updated,
        coinHistory: history,
        collectedPuzzles: updatedPuzzles,
      ),
    );
    await _saveCoinHistory(history);
    try {
      await _client.unlockPuzzle(event.puzzleId, event.cost);
    } catch (_) {}
    await _savePrefs(
      updated.coins,
      updated.streak,
      state.lastStreakDate,
      restDayDate: state.restDayDate,
      earnedCoins: updated.earnedCoins,
      spentCoins: updated.spentCoins,
    );
    await _saveProfileFields(state.user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefKey('collected_puzzles'),
      updatedPuzzles.toList(),
    );
  }

  Future<void> _onLogCoinTransaction(
    LogCoinTransaction event,
    Emitter<ProfileState> emit,
  ) async {
    final history = List<Map<String, dynamic>>.from(state.coinHistory);
    history.insert(0, {
      'type': event.type,
      'title': event.title,
      'date': DateTime.now().toIso8601String(),
      'amount': event.amount,
    });
    emit(state.copyWith(coinHistory: history));
    await _saveCoinHistory(history);
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
