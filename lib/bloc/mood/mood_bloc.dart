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
  bool _loaded = false;

  String _prefKey(String key) =>
      _userEmail != null ? '${_userEmail}_$key' : 'guest_$key';

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

  Future<void> _saveMoodHistory(List<Mood> moods) async {
    await _ensureUserEmail();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey('mood_history'),
      jsonEncode(moods.map((m) => m.toMap()).toList()),
    );
  }

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

  Future<void> _onLoadMoodHistory(
    LoadMoodHistory event,
    Emitter<MoodState> emit,
  ) async {
    if (_loaded) return;
    _loaded = true;

    await _ensureUserEmail();
    final cached = await _loadCachedHistory();
    List<Mood> moods = List<Mood>.from(cached);

    // Try API to enrich
    try {
      final res = await _client.getMoodHistory();
      if (res['status'] == 200) {
        final rawData = res['data'];
        if (rawData is List) {
          final apiMoods = rawData
              .map((e) => Mood.fromMap(e as Map<String, dynamic>))
              .toList();

          // Merge: keep local today's mood if API doesn't have it yet
          final localToday = _findTodayMood(moods);
          moods = apiMoods;
          if (localToday != null && _findTodayMood(moods) == null) {
            moods.add(localToday);
            _client.submitMood(localToday.mood, _dateKey(localToday.date))
                .catchError((_) => <String, dynamic>{});
          }

          await _saveMoodHistory(moods);
        }
      }
    } catch (_) {}

    // Fallback: if today's mood not in history but flag is set, create stub
    Mood? todayMood = _findTodayMood(moods);
    if (todayMood == null && await _isTodayMoodSubmitted()) {
      todayMood = Mood(
        id: 'today',
        mood: 'submitted',
        date: DateTime.now(),
      );
      moods.add(todayMood);
      await _saveMoodHistory(moods);
    }

    emit(state.copyWith(
      status: MoodStatus.success,
      moodHistory: moods,
      todayMood: todayMood,
    ));
  }

  Future<void> _markTodayMoodSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    await prefs.setString(_prefKey('today_mood_submitted'), today);
  }

  Future<bool> _isTodayMoodSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey('today_mood_submitted'));
    if (saved == null) return false;
    return saved == _dateKey(DateTime.now());
  }

  Future<void> _onSubmitMood(SubmitMood event, Emitter<MoodState> emit) async {
    await _ensureUserEmail();

    final dateStr = _dateKey(event.date);
    final newMood = Mood(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: event.mood,
      date: event.date,
    );

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

    await _saveMoodHistory(updatedHistory);
    await _markTodayMoodSubmitted();

    emit(state.copyWith(
      status: MoodStatus.success,
      todayMood: newMood,
      moodHistory: updatedHistory,
    ));

    try {
      final res = await _client.submitMood(event.mood, dateStr);
      if (res['status'] == 200 || res['status'] == 201) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final confirmedMood = Mood.fromMap(data);
          final syncedHistory = updatedHistory.map((m) {
            if (_dateKey(m.date) == dateStr) return confirmedMood;
            return m;
          }).toList();
          await _saveMoodHistory(syncedHistory);
          emit(state.copyWith(
            status: MoodStatus.success,
            todayMood: confirmedMood,
            moodHistory: syncedHistory,
          ));
        }
      }
    } catch (_) {}
  }

  Future<void> _onLoadTodayMood(
    LoadTodayMood event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(todayMood: _findTodayMood(state.moodHistory)));
  }

  void _onClearMood(ClearMood event, Emitter<MoodState> emit) {
    _userEmail = null;
    _loaded = false;
    emit(const MoodState());
  }
}
