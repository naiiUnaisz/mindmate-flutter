import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_belajar/bloc/mood/mood_event.dart';
import 'package:application_belajar/bloc/mood/mood_state.dart';
import 'package:application_belajar/models/mood_model.dart';
import 'package:application_belajar/networks/api_client.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final ApiClient _client = ApiClient();
  String? _userEmail;

  // ── Per-user prefs key ──
  String _prefKey(String key) =>
      _userEmail != null ? '${_userEmail}_$key' : 'guest_$key';

  // ── Helpers ──
  static String _dateKey(DateTime dt) {
    final localDt = dt.toLocal();
    return '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')}';
  }

  static Mood? _findTodayMood(List<Mood> moods) {
    final todayKey = _dateKey(DateTime.now());
    for (final m in moods) {
      if (_dateKey(m.date) == todayKey) return m;
    }
    return null;
  }

  // ── Persist to SharedPreferences (always, even if email is null) ──
  Future<void> _saveMoodHistory(List<Mood> moods) async {
    await _ensureUserEmail();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey('mood_history'),
      jsonEncode(moods.map((m) => m.toMap()).toList()),
    );
  }

  // ── Load user email from prefs (call before any prefs operation) ──
  Future<void> _ensureUserEmail() async {
    if (_userEmail != null) return;
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('current_user_email')?.toLowerCase();
  }

  Future<List<Mood>> _loadCachedHistory() async {
    await _ensureUserEmail();
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefKey('mood_history'));
    if (cached == null) return [];
    try {
      final decoded = jsonDecode(cached);
      if (decoded is! List) return [];
      return decoded
          .map((e) => Mood.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  MoodBloc() : super(const MoodState()) {
    on<LoadMoodHistory>(_onLoadMoodHistory);
    on<SubmitMood>(_onSubmitMood);
    on<LoadTodayMood>(_onLoadTodayMood);
    on<ClearMood>(_onClearMood);
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOAD MOOD HISTORY
  // Response format: {"success":true,"data":[{"id":1,"date":"2026-06-14T...","mood_level":"happy"},...]}
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _onLoadMoodHistory(
    LoadMoodHistory event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(status: MoodStatus.loading));
    await _ensureUserEmail();

    // Step 1: Emit cached data immediately for fast UI
    final cached = await _loadCachedHistory();
    if (cached.isNotEmpty) {
      emit(
        state.copyWith(
          status: MoodStatus.success,
          moodHistory: cached,
          todayMood: _findTodayMood(cached),
        ),
      );
    }

    // Step 2: Fetch from API
    try {
      final res = await _client.getMoodHistory();
      if (res['status'] == 200) {
        // Backend: {"success":true,"data":[...list...]}
        final rawData = res['data'];
        final List<dynamic> moodList = rawData is List ? rawData : [];
        final moods = moodList
            .map((e) => Mood.fromMap(e as Map<String, dynamic>))
            .toList();

        // Preserve local today's mood if it hasn't synced to API yet
        final localTodayMood = _findTodayMood(cached);
        if (localTodayMood != null && _findTodayMood(moods) == null) {
          moods.add(localTodayMood);
          // Attempt to sync it in the background
          _client.submitMood(localTodayMood.mood, _dateKey(localTodayMood.date)).catchError((_) {});
        }

        await _saveMoodHistory(moods);

        emit(
          state.copyWith(
            status: MoodStatus.success,
            moodHistory: moods,
            todayMood: _findTodayMood(moods),
          ),
        );
        return;
      }
    } catch (_) {}

    // Step 3: API failed — keep cached data already emitted
    if (cached.isEmpty) {
      emit(state.copyWith(status: MoodStatus.success, moodHistory: const []));
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // SUBMIT MOOD
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _onSubmitMood(SubmitMood event, Emitter<MoodState> emit) async {
    await _ensureUserEmail();

    final dateStr = _dateKey(event.date);

    // Optimistic local update — store with today's date
    final newMood = Mood(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: event.mood,
      date: event.date,
    );

    // Replace today's entry or append
    final updatedHistory = <Mood>[];
    bool replaced = false;
    for (final m in state.moodHistory) {
      if (_dateKey(m.date) == dateStr) {
        updatedHistory.add(newMood);
        replaced = true;
      } else {
        updatedHistory.add(m);
      }
    }
    if (!replaced) updatedHistory.add(newMood);

    // Save locally first — data persists even if API fails
    await _saveMoodHistory(updatedHistory);

    emit(
      state.copyWith(
        status: MoodStatus.success,
        todayMood: newMood,
        moodHistory: updatedHistory,
      ),
    );

    // Send to API (fire-and-forget with sync on success)
    try {
      final res = await _client.submitMood(event.mood, dateStr);
      if (res['status'] == 200 || res['status'] == 201) {
        // Backend confirmed — update id if returned
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final confirmedMood = Mood.fromMap(data);
          final syncedHistory = updatedHistory.map((m) {
            if (_dateKey(m.date) == dateStr) return confirmedMood;
            return m;
          }).toList();
          await _saveMoodHistory(syncedHistory);
          emit(
            state.copyWith(
              status: MoodStatus.success,
              todayMood: confirmedMood,
              moodHistory: syncedHistory,
            ),
          );
        }
      }
    } catch (_) {
      // Local save already done — no rollback needed
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOAD TODAY MOOD (from in-memory history)
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _onLoadTodayMood(
    LoadTodayMood event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(todayMood: _findTodayMood(state.moodHistory)));
  }

  // ─────────────────────────────────────────────────────────────────────
  // CLEAR MOOD (on logout / account switch)
  // ─────────────────────────────────────────────────────────────────────
  void _onClearMood(ClearMood event, Emitter<MoodState> emit) {
    _userEmail = null;
    emit(const MoodState());
  }
}
