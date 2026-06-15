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
    if (state.status == NoteStatus.success) return;

    await _ensureUserEmail();
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefKey('notes'));

    List<NoteItem> items = [];
    if (cached != null) {
      items = _loadFromCache(cached);
    }

    emit(state.copyWith(status: NoteStatus.success, notes: items));

    // Try API to enrich data
    try {
      final res = await _client.getNotes();
      if (res['status'] == 200 && res['data'] != null) {
        final apiList = (res['data'] as List)
            .map((e) => NoteItem.fromMap(e as Map<String, dynamic>))
            .toList();

        for (final apiItem in apiList) {
          final idx = items.indexWhere((n) => n.id == apiItem.id);
          if (idx < 0) {
            items.add(apiItem);
          }
        }
        await _saveToPrefs(items);
        emit(state.copyWith(status: NoteStatus.success, notes: items));
      }
    } catch (_) {
      emit(state.copyWith(
        status: NoteStatus.success,
        errorMessage: 'Gagal memuat catatan dari server',
      ));
    }
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
      final res = await _client.createNote(event.title, event.content, tab: event.tab);
      if (res['status'] == 200 || res['status'] == 201) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final apiNote = NoteItem.fromMap(data).copyWith(tab: event.tab);
          final synced = updated.map((n) =>
              n.id == localId ? apiNote : n).toList();
          emit(state.copyWith(notes: synced));
          await _saveToPrefs(synced);
        }
      }
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Gagal menyimpan catatan ke server',
      ));
    }
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
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Gagal memperbarui catatan',
      ));
    }
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
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Gagal menghapus catatan',
      ));
    }
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

    final toggled = updated.firstWhere((n) => n.id == event.id);

    try {
      await _client.updateNote(
        event.id, toggled.title, toggled.content,
        isCompleted: toggled.isCompleted,
      );
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Gagal memperbarui status catatan',
      ));
    }
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
    emit(const NoteState());
  }
}
