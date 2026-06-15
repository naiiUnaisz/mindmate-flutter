import 'package:equatable/equatable.dart';

class NoteItem {
  final String id;
  final String title;
  final String content;
  final bool isCompleted;
  final String tab; // 'todo' or 'default'
  final DateTime createdAt;

  NoteItem({
    required this.id,
    required this.title,
    this.content = '',
    this.isCompleted = false,
    this.tab = 'todo',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    bool? isCompleted,
    String? tab,
    DateTime? createdAt,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
      tab: tab ?? this.tab,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'is_completed': isCompleted,
    'tab': tab,
    'created_at': createdAt.toIso8601String(),
  };

  factory NoteItem.fromMap(Map<String, dynamic> map) => NoteItem(
    id: (map['id'] ?? '').toString(),
    title: map['title'] ?? '',
    content: map['content'] ?? map['subtitle'] ?? '',
    isCompleted: map['is_completed'] ?? map['isCompleted'] ?? false,
    tab: map['tab'] ?? 'todo',
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : DateTime.now(),
  );
}

enum NoteStatus { initial, loading, success, failure }

class NoteState extends Equatable {
  final NoteStatus status;
  final String errorMessage;
  final List<NoteItem> notes;

  const NoteState({
    this.status = NoteStatus.initial,
    this.errorMessage = '',
    this.notes = const [],
  });

  List<NoteItem> get todoNotes =>
      notes.where((n) => n.tab == 'todo').toList();

  List<NoteItem> get completedNotes =>
      notes.where((n) => n.isCompleted).toList();

  List<NoteItem> get defaultNotes =>
      notes.where((n) => n.tab == 'default').toList();

  NoteState copyWith({
    NoteStatus? status,
    String? errorMessage,
    List<NoteItem>? notes,
  }) {
    return NoteState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, notes];
}
