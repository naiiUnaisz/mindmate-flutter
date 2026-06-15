import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {}

class AddNote extends NoteEvent {
  final String title;
  final String content;
  final String tab; // 'todo' or 'default'

  const AddNote({
    required this.title,
    required this.content,
    this.tab = 'todo',
  });

  @override
  List<Object?> get props => [title, content, tab];
}

class UpdateNote extends NoteEvent {
  final String id;
  final String title;
  final String content;

  const UpdateNote({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class DeleteNote extends NoteEvent {
  final String id;

  const DeleteNote({required this.id});

  @override
  List<Object?> get props => [id];
}

class CompleteNote extends NoteEvent {
  final String id;

  const CompleteNote({required this.id});

  @override
  List<Object?> get props => [id];
}

class MoveNote extends NoteEvent {
  final String id;
  final String fromTab;
  final String toTab;

  const MoveNote({
    required this.id,
    required this.fromTab,
    required this.toTab,
  });

  @override
  List<Object?> get props => [id, fromTab, toTab];
}

class ClearNotes extends NoteEvent {}
