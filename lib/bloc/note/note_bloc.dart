import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/bloc/note/note_event.dart';
import 'package:mindmate/bloc/note/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
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
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NoteState> emit,
  ) async {
    final updated = state.notes.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notes: updated));
    await _saveToPrefs(updated);
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
