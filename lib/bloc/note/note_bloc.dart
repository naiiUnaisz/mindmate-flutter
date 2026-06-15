import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_belajar/bloc/note/note_event.dart';
import 'package:application_belajar/bloc/note/note_state.dart';
import 'package:application_belajar/networks/api_client.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final ApiClient _client = ApiClient();
  String? _userEmail;
  bool _loaded = false;

  String _prefKey(String key) =>
      _userEmail != null ? '${_userEmail}_$key' : 'guest_$key';

  NoteBloc() : super(const NoteState()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<CompleteNote>(_onCompleteNote);
    on<MoveNote>(_onMoveNote);
    on<ClearNotes>(_onClearNotes);
  }

  Future<void> _ensureUserEmail() async {
    if (_userEmail != null) return;
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('current_user_email')?.toLowerCase();
  }

  Future<void> _saveToPrefs(List<NoteItem> notes) async {
    await _ensureUserEmail();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey('notes'),
      jsonEncode(notes.map((n) => n.toMap()).toList()),
    );
  }

  List<NoteItem> _loadFromCache(String json) {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded
          .map((e) => NoteItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NoteState> emit,
  ) async {
    if (_loaded) return;
    _loaded = true;

    await _ensureUserEmail();
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefKey('notes'));

    List<NoteItem> items = [];
    if (cached != null) {
      items = _loadFromCache(cached);
    }

    // Try API to enrich data
    try {
      final res = await _client.getNotes();
      if (res['status'] == 200 && res['data'] != null) {
        final apiList = (res['data'] as List)
            .map((e) => NoteItem.fromMap(e as Map<String, dynamic>))
            .toList();

        // Merge: API items + local cache items (local wins on conflict)
        for (final apiItem in apiList) {
          final idx = items.indexWhere((n) => n.id == apiItem.id);
          if (idx < 0) {
            items.add(apiItem);
          }
        }
        await _saveToPrefs(items);
      }
    } catch (_) {}

    emit(state.copyWith(status: NoteStatus.success, notes: items));
  }

  Future<void> _onAddNote(
    AddNote event,
    Emitter<NoteState> emit,
  ) async {
    final localId = const Uuid().v4();
    final newNote = NoteItem(
      id: localId,
      title: event.title,
      content: event.content,
      tab: event.tab,
    );

    final updated = List<NoteItem>.from(state.notes)..add(newNote);
    emit(state.copyWith(notes: updated));
    await _saveToPrefs(updated);

    try {
      final res = await _client.createNote(event.title, event.content);
      if (res['status'] == 200 || res['status'] == 201) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final apiNote = NoteItem.fromMap(data);
          final synced = updated.map((n) =>
              n.id == localId ? apiNote : n).toList();
          emit(state.copyWith(notes: synced));
          await _saveToPrefs(synced);
        }
      }
    } catch (_) {}
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NoteState> emit,
  ) async {
    final updated = state.notes.map((n) {
      return n.id == event.id
          ? n.copyWith(title: event.title, content: event.content)
          : n;
    }).toList();

    emit(state.copyWith(notes: updated));
    await _saveToPrefs(updated);

    try {
      await _client.updateNote(event.id, event.title, event.content);
    } catch (_) {}
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NoteState> emit,
  ) async {
    final updated = state.notes.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notes: updated));
    await _saveToPrefs(updated);

    try {
      await _client.deleteNote(event.id);
    } catch (_) {}
  }

  Future<void> _onCompleteNote(
    CompleteNote event,
    Emitter<NoteState> emit,
  ) async {
    final updated = state.notes.map((n) {
      return n.id == event.id
          ? n.copyWith(isCompleted: !n.isCompleted)
          : n;
    }).toList();

    emit(state.copyWith(notes: updated));
    await _saveToPrefs(updated);

    try {
      final note = state.notes.firstWhere((n) => n.id == event.id);
      await _client.updateNote(event.id, note.title, note.content);
    } catch (_) {}
  }

  Future<void> _onMoveNote(
    MoveNote event,
    Emitter<NoteState> emit,
  ) async {
    final updated = state.notes.map((n) {
      return n.id == event.id ? n.copyWith(tab: event.toTab) : n;
    }).toList();

    emit(state.copyWith(notes: updated));
    await _saveToPrefs(updated);
  }

  void _onClearNotes(ClearNotes event, Emitter<NoteState> emit) {
    _userEmail = null;
    _loaded = false;
    emit(const NoteState());
  }
}
