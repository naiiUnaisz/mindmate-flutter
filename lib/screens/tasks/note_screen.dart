import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/bloc/task/task_bloc.dart';
import 'package:application_belajar/bloc/task/task_event.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_event.dart';
import 'package:application_belajar/widgets/reward_dialog.dart';

/// Note screen with "To do List" / "Default Task" tabs.
/// Users can add notes via the purple FAB which opens a create note sheet.
class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  /// 0 = To do List, 1 = Default Task
  int _activeTab = 0;

  // Dynamic lists — user can add items
  static final List<_NoteItem> _toDoItems = [];
  static final List<_NoteItem> _defaultItems = [];

  List<_NoteItem> get _currentItems =>
      _activeTab == 0 ? _toDoItems : _defaultItems;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final todoJson = prefs.getString('note_todo_items');
    final defaultJson = prefs.getString('note_default_items');
    setState(() {
      if (todoJson != null) {
        final list = jsonDecode(todoJson) as List;
        _toDoItems
          ..clear()
          ..addAll(list.map((e) => _NoteItem.fromMap(e as Map<String, dynamic>)));
      }
      if (defaultJson != null) {
        final list = jsonDecode(defaultJson) as List;
        _defaultItems
          ..clear()
          ..addAll(list.map((e) => _NoteItem.fromMap(e as Map<String, dynamic>)));
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'note_todo_items',
      jsonEncode(_toDoItems.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'note_default_items',
      jsonEncode(_defaultItems.map((e) => e.toMap()).toList()),
    );
  }

  void _addNote(String title, String subtitle) {
    setState(() {
      _currentItems.add(_NoteItem(title: title, subtitle: subtitle));
    });
    _saveData();
    if (_activeTab == 1) {
      context.read<TaskBloc>().add(AddDefaultTask(title: title, description: subtitle));
    }
  }

  void _deleteNote(int index) {
    final item = _currentItems[index];
    setState(() {
      _currentItems.removeAt(index);
    });
    _saveData();
    if (_activeTab == 1) {
      context.read<TaskBloc>().add(RemoveDefaultTask(title: item.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ═══════════════════════════════════════
            // HEADER: back arrow + "Note"
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 30,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Note',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════
            // TAB TOGGLE (centered)
            // ═══════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TabButton(
                  label: 'To do List',
                  isActive: _activeTab == 0,
                  onTap: () => setState(() => _activeTab = 0),
                ),
                const SizedBox(width: 10),
                _TabButton(
                  label: 'Default Task',
                  isActive: _activeTab == 1,
                  onTap: () => setState(() => _activeTab = 1),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════
            // TASK LIST or EMPTY STATE
            // ═══════════════════════════════════════
            Expanded(
              child: _currentItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _currentItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      itemBuilder: (context, index) {
                        final item = _currentItems[index];
                        return _NoteTaskRow(
                          title: item.title,
                          subtitle: item.subtitle,
                          isCompleted: item.isCompleted,
                          onCheck: () {
                            if (item.isCompleted) return;
                            setState(() {
                              item.isCompleted = true;
                            });
                            _saveData();
                            context
                                .read<ProfileBloc>()
                                .add(EarnCoins(amount: 10, reason: 'task'));
                            showRewardDialog(context);
                          },
                          onMore: () => _showMoreOptions(context, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ═══════════════════════════════════════
      // FAB → opens Create Note sheet
      // ═══════════════════════════════════════
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteSheet(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to create a new note',
            style: TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
          ),
        ],
      ),
    );
  }

  // ── Create Note Bottom Sheet ──
  void _showCreateNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CreateNoteSheet(
          onSave: (title, subtitle) {
            _addNote(title, subtitle);
          },
        );
      },
    );
  }

  // ── More Options ──
  void _showMoreOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF6B7280),
                ),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditNoteSheet(context, index);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteNote(index);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.task_alt_outlined,
                  color: Color(0xFF6B7280),
                ),
                title: const Text('Default Task'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      if (_activeTab == 0) {
                        final item = _toDoItems.removeAt(index);
                        _defaultItems.add(item);
                        context.read<TaskBloc>().add(AddDefaultTask(title: item.title, description: item.subtitle));
                      } else {
                        final item = _defaultItems.removeAt(index);
                        _toDoItems.add(item);
                        context.read<TaskBloc>().add(RemoveDefaultTask(title: item.title));
                      }
                    });
                    _saveData();
                  },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Edit Note ──
  void _showEditNoteSheet(BuildContext context, int index) {
    final item = _currentItems[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CreateNoteSheet(
          initialTitle: item.title,
          initialSubtitle: item.subtitle,
          isEdit: true,
          onSave: (title, subtitle) {
            setState(() {
              _currentItems[index] = _NoteItem(
                title: title,
                subtitle: subtitle,
                isCompleted: _currentItems[index].isCompleted,
              );
            });
            _saveData();
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _NoteItem {
  final String title;
  final String subtitle;
  bool isCompleted;

  _NoteItem({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'isCompleted': isCompleted,
      };

  factory _NoteItem.fromMap(Map<String, dynamic> map) => _NoteItem(
        title: map['title'] ?? '',
        subtitle: map['subtitle'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB TOGGLE BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTE TASK ROW
// ═══════════════════════════════════════════════════════════════════════════

class _NoteTaskRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onCheck;
  final VoidCallback onMore;

  const _NoteTaskRow({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    required this.onCheck,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCheck,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.primary : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: isCompleted ? AppColors.primary : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isCompleted ? const Color(0xFFD1D5DB) : const Color(0xFF9CA3AF),
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onMore,
            child: const Icon(
              Icons.more_horiz,
              size: 22,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CREATE NOTE BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _CreateNoteSheet extends StatefulWidget {
  final String? initialTitle;
  final String? initialSubtitle;
  final bool isEdit;
  final void Function(String title, String subtitle) onSave;

  const _CreateNoteSheet({
    this.initialTitle,
    this.initialSubtitle,
    this.isEdit = false,
    required this.onSave,
  });

  @override
  State<_CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<_CreateNoteSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _subtitleController = TextEditingController(
      text: widget.initialSubtitle ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note title')),
      );
      return;
    }
    widget.onSave(
      _titleController.text.trim(),
      _subtitleController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.isEdit ? 'Edit Note' : 'Create Note',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),

            const SizedBox(height: 24),

            // ── Note Title ──
            const Text(
              'Note Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            _NoteInputField(
              controller: _titleController,
              hintText: 'Write your note title..',
            ),

            const SizedBox(height: 20),

            // ── Description ──
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            _NoteInputField(
              controller: _subtitleController,
              hintText: 'Write a short description..',
            ),

            const SizedBox(height: 24),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  widget.isEdit ? 'Update' : 'Save',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTE INPUT FIELD
// ═══════════════════════════════════════════════════════════════════════════

class _NoteInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _NoteInputField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
      ),
    );
  }
}
