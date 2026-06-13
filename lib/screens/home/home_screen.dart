import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/bloc/task/task_bloc.dart';
import 'package:application_belajar/bloc/task/task_event.dart';
import 'package:application_belajar/bloc/task/task_state.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_event.dart';
import 'package:application_belajar/widgets/streak_dialog.dart';
import 'package:application_belajar/widgets/puzzle_widget.dart';
import 'package:application_belajar/widgets/reward_dialog.dart';
import 'package:application_belajar/models/task_model.dart';
import 'package:application_belajar/bloc/profile/profile_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskState = context.read<TaskBloc>().state;
      if (!taskState.hasAskedMoodToday) {
        context.read<TaskBloc>().add(SetMoodAsked());
        _showMoodDialog();
      }
    });
  }

  void _showMoodDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MoodDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, taskState) {
          final result = taskState.lastCompletionResult;
          if (result != null) {
            context.read<ProfileBloc>().add(EarnCoins(
              amount: result.coinReward,
              reason: 'task',
            ));
            if (result.isStreakAchieved) {
              context.read<ProfileBloc>().add(IncrementStreak());
              context.read<ProfileBloc>().add(CollectDailyPuzzle(puzzleId: getDailyPuzzleId()));
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!context.mounted) return;
                await showStreakDialog(context);
                if (!context.mounted) return;
                Navigator.of(context).pushNamed('/puzzle-collection');
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                showRewardDialog(context, coins: result.coinReward, showPuzzleReward: true);
              });
            }
            context.read<TaskBloc>().add(ClearLastCompletionResult());
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                final completedPieces = taskState.completedTasksToday;
                final totalPieces = 6;

                return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══════════════════════════════════════
                    // GREETING HEADER
                    // ═══════════════════════════════════════
                    _GreetingHeader(
                      name: profileState.user.name,
                      isRestDayActive: profileState.restDayDate != null &&
                          DateTime(
                            profileState.restDayDate!.year,
                            profileState.restDayDate!.month,
                            profileState.restDayDate!.day,
                          ).isAtSameMomentAs(
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                            ),
                          ),
                      onRestDay: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Rest Day',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            content: const Text(
                              'Hari ini kamu tidak perlu menyelesaikan 6 task, streak tetap aman. Lanjutkan?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context
                                      .read<ProfileBloc>()
                                      .add(ActivateRestDay());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Rest day aktif! Streak aman.'),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Aktifkan'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // STATS ROW (Coins & Streak)
                    // ═══════════════════════════════════════
                    _StatsRow(
                      coins: profileState.user.coins,
                      streak: profileState.user.streak,
                    ),

                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════
                    // PUZZLE PROGRESS SECTION
                    // ═══════════════════════════════════════
                    _PuzzleSection(
                      completedPieces: completedPieces,
                      totalPieces: totalPieces,
                      puzzleIndex: getDailyPuzzleIndex() + 1,
                    ),

                    const SizedBox(height: 28),

                    // ═══════════════════════════════════════
                    // TO DO LIST TODAY
                    // ═══════════════════════════════════════
                    const Text(
                      'To Do List Today',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (taskState.dailyPuzzleTasks.isEmpty)
                      _buildEmptyState(context)
                    else
                      _buildTaskList(context, taskState),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  ),
);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Text(
            'Start building your progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a task to unlock\nyour first puzzle piece',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _showAddTaskSheet(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Add New Task',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the "Add New Task" or "Edit Task" bottom sheet overlay on top of the homepage.
  void _showAddTaskSheet(BuildContext context, {Task? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AddTaskBottomSheet(taskToEdit: taskToEdit);
      },
    );
  }

  Widget _buildTaskList(BuildContext context, TaskState taskState) {
    return Column(
      children: taskState.dailyPuzzleTasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _TaskItem(
            title: task.title,
            subtitle: task.description ?? '',
            isCompleted: task.isCompleted,
            onComplete: () {
              context.read<TaskBloc>().add(CompleteTask(taskId: task.id));
            },
            onEdit: () => _showAddTaskSheet(context, taskToEdit: task),
            onDelete: () {
              context.read<TaskBloc>().add(DeleteTask(taskId: task.id));
            },
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GREETING HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _GreetingHeader extends StatelessWidget {
  final String name;
  final bool isRestDayActive;
  final VoidCallback? onRestDay;

  const _GreetingHeader({
    required this.name,
    this.isRestDayActive = false,
    this.onRestDay,
  });

  String _getGreeting() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hour = now.hour;
    
    if (hour >= 0 && hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Night 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $name',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Mascot Icon (Sleepy) → Rest Day button
            GestureDetector(
              onTap: onRestDay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: isRestDayActive
                      ? Border.all(color: const Color(0xFF7C3AED), width: 2)
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: CustomPaint(
                          painter: _MascotFacePainter(mood: 'sleepy'),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isRestDayActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          isRestDayActive ? '✓' : 'z',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Menu icon (list) → navigates to Note screen
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/note'),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATS ROW (Total Coin & Current Streak)
// ═══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final int coins;
  final int streak;

  const _StatsRow({required this.coins, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Total Coin
        Expanded(
          child: _StatChip(
            icon: Icons.circle,
            iconColor: const Color(0xFFFBBF24),
            label: 'Total Coin',
            value: '$coins Coin',
            valueColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        // Current Streak
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFEF4444),
            label: 'Current Streak',
            value: '$streak Day',
            valueColor: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PUZZLE PROGRESS SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _PuzzleSection extends StatelessWidget {
  final int completedPieces;
  final int totalPieces;
  final int puzzleIndex;

  const _PuzzleSection({
    required this.completedPieces,
    required this.totalPieces,
    this.puzzleIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.extension_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Puzzle Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Complete tasks and get puzzle pieces!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Puzzle grid
        PuzzleWidget(
          completedPieces: completedPieces,
          totalPieces: totalPieces,
          puzzleIndex: puzzleIndex,
        ),

        const SizedBox(height: 12),

        // "0/6 pieces" text
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$completedPieces/$totalPieces',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(
                text: ' pieces',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Thin progress line with small purple square indicator
        LayoutBuilder(
          builder: (context, constraints) {
            final double percentage = totalPieces > 0
                ? (completedPieces / totalPieces).clamp(0.0, 1.0)
                : 0.0;
            return SizedBox(
              height: 6,
              child: Stack(
                children: [
                  // Background line
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 2.5,
                    child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                  ),
                  // Purple progress line
                  Positioned(
                    left: 0,
                    top: 2.5,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 1,
                      width: constraints.maxWidth * percentage,
                      color: AppColors.primary,
                    ),
                  ),
                  // Purple square indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: percentage == 0
                        ? 0
                        : (constraints.maxWidth - 8) * percentage,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TASK ITEM CARD
// ═══════════════════════════════════════════════════════════════════════════

class _TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFEBE5FB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFEBE5FB)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isCompleted ? null : onComplete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isCompleted
                    ? const Color(0xFF7C3AED)
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              // No child icon needed, just a solid rounded square
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF1F2937),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADD NEW TASK BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class AddTaskBottomSheet extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskBottomSheet({super.key, this.taskToEdit});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _subtaskController = TextEditingController();
  bool _isStep2 = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _subtaskController.text = widget.taskToEdit!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }
    setState(() => _isStep2 = true);
  }

  void _handleSave() {
    final taskBloc = context.read<TaskBloc>();
    if (widget.taskToEdit != null) {
      taskBloc.add(UpdateTask(
        taskId: widget.taskToEdit!.id,
        title: _titleController.text,
        description: _subtaskController.text.isEmpty ? null : _subtaskController.text,
      ));
    } else {
      taskBloc.add(AddTask(
        title: _titleController.text,
        description: _subtaskController.text.isEmpty ? null : _subtaskController.text,
        deadline: DateTime.now(),
      ));
    }
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
            // ── Handle bar ──
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

            // ── Header: back + title ──
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isStep2) {
                      setState(() => _isStep2 = false);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.taskToEdit != null ? 'Edit Task' : 'Add New Task',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 28), // Balance the back arrow
              ],
            ),

            const SizedBox(height: 24),

            // ── Task Title ──
            const Text(
              'Task Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              enabled: !_isStep2,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
              decoration: InputDecoration(
                hintText: 'Write your task title..',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFD1D5DB),
                ),
                filled: true,
                fillColor: _isStep2 ? const Color(0xFFF9FAFB) : Colors.white,
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF7C3AED),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Sub Task Name ──
            const Text(
              'Sub Task Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subtaskController,
              enabled: !_isStep2,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
              decoration: InputDecoration(
                hintText: 'Write your sub task name..',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFD1D5DB),
                ),
                filled: true,
                fillColor: _isStep2 ? const Color(0xFFF9FAFB) : Colors.white,
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF7C3AED),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Next / Save button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isStep2 ? _handleSave : _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  _isStep2 ? 'Save' : 'Next',
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
// MOOD DIALOG
// ═══════════════════════════════════════════════════════════════════════════

class _MoodDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mascot_unlock.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.emoji_emotions,
                size: 80,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How are you feeling today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your mood to start your day!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MoodOption(
                  mood: 'sad',
                  label: 'Sad',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pop(context),
                ),
                _MoodOption(
                  mood: 'normal',
                  label: 'Normal',
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.pop(context),
                ),
                _MoodOption(
                  mood: 'happy',
                  label: 'Happy',
                  color: Colors.green,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  final String mood;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodOption({
    required this.mood,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                painter: _MascotFacePainter(mood: mood),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotFacePainter extends CustomPainter {
  final String mood;

  _MascotFacePainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = const Color(0xFFB78AF7); // Main purple body color
    final faceColor = const Color(0xFFFFE4E6); // Light pink face

    // 1. Draw rounded body/head shape (chubby cute squircle)
    final squircle = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.45), // More rounded
    );
    canvas.drawRRect(squircle, Paint()..color = primaryColor);

    // 2. Draw inner face oval (wider and lower)
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.85,
      height: h * 0.65,
    );
    canvas.drawOval(faceRect, Paint()..color = faceColor);

    // 3. Draw Cheeks (vibrant pink, right under/next to eyes)
    final cheekPaint = Paint()..color = const Color(0xFFFFA6D9).withValues(alpha: 0.85);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.22, h * 0.65), width: w * 0.2, height: h * 0.12), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.78, h * 0.65), width: w * 0.2, height: h * 0.12), cheekPaint);

    // 4. Draw Eyes and Mouth based on mood
    final strokePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..color = const Color(0xFF831843);
    final darkEyePaint = Paint()..color = const Color(0xFF1F2937);

    if (mood == 'happy') {
      // Big cute round eyes • •
      canvas.drawCircle(Offset(w * 0.32, h * 0.52), w * 0.1, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.68, h * 0.52), w * 0.1, darkEyePaint);
      
      // Sparkles in eyes
      canvas.drawCircle(Offset(w * 0.35, h * 0.48), w * 0.035, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(w * 0.28, h * 0.55), w * 0.015, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(w * 0.71, h * 0.48), w * 0.035, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(w * 0.64, h * 0.55), w * 0.015, Paint()..color = Colors.white);

      // Open happy mouth 'D'
      final mouthPath = Path()
        ..moveTo(w * 0.4, h * 0.65)
        ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.6, h * 0.65)
        ..close();
      canvas.drawPath(mouthPath, fillPaint);
      
      // Little pink tongue
      canvas.save();
      canvas.clipPath(mouthPath);
      canvas.drawCircle(Offset(w * 0.5, h * 0.78), w * 0.06, Paint()..color = const Color(0xFFF472B6));
      canvas.restore();
      
    } else if (mood == 'normal') {
      // Small cute dot eyes • •
      canvas.drawCircle(Offset(w * 0.33, h * 0.55), w * 0.06, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.67, h * 0.55), w * 0.06, darkEyePaint);

      // Cute little 'w' mouth
      final mouth = Path()
        ..moveTo(w * 0.43, h * 0.68)
        ..quadraticBezierTo(w * 0.465, h * 0.73, w * 0.5, h * 0.68)
        ..quadraticBezierTo(w * 0.535, h * 0.73, w * 0.57, h * 0.68);
      canvas.drawPath(mouth, strokePaint..strokeWidth = w * 0.045);
      
    } else if (mood == 'sleepy') {
      // Sleepy closed eyes - -
      final leftEye = Path()
        ..moveTo(w * 0.28, h * 0.55)
        ..quadraticBezierTo(w * 0.33, h * 0.58, w * 0.38, h * 0.55);
      final rightEye = Path()
        ..moveTo(w * 0.62, h * 0.55)
        ..quadraticBezierTo(w * 0.67, h * 0.58, w * 0.72, h * 0.55);
      canvas.drawPath(leftEye, strokePaint..strokeWidth = w * 0.045);
      canvas.drawPath(rightEye, strokePaint..strokeWidth = w * 0.045);

      // Cute small sleepy mouth
      final mouth = Path()
        ..moveTo(w * 0.46, h * 0.72)
        ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.54, h * 0.72);
      canvas.drawPath(mouth, strokePaint..strokeWidth = w * 0.04);
      
    } else {
      // Sad puppy eyes (big and teary, slightly slanted)
      canvas.save();
      canvas.translate(w * 0.33, h * 0.55);
      canvas.rotate(math.pi / 12);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.22), darkEyePaint);
      // Sparkles
      canvas.drawCircle(Offset(w * 0.02, -h * 0.05), w * 0.04, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(-w * 0.02, h * 0.05), w * 0.015, Paint()..color = Colors.white);
      canvas.restore();

      canvas.save();
      canvas.translate(w * 0.67, h * 0.55);
      canvas.rotate(-math.pi / 12);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.22), darkEyePaint);
      // Sparkles
      canvas.drawCircle(Offset(w * 0.02, -h * 0.05), w * 0.04, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(-w * 0.02, h * 0.05), w * 0.015, Paint()..color = Colors.white);
      canvas.restore();

      // Sad wobbly pout
      final mouthPath = Path()
        ..moveTo(w * 0.43, h * 0.78)
        ..quadraticBezierTo(w * 0.5, h * 0.73, w * 0.57, h * 0.78);
      canvas.drawPath(mouthPath, strokePaint..strokeWidth = w * 0.045);
      
      // Tears streaming down
      final tearPaint = Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.9);
      canvas.drawCircle(Offset(w * 0.23, h * 0.65), w * 0.03, tearPaint);
      canvas.drawCircle(Offset(w * 0.26, h * 0.75), w * 0.035, tearPaint);
      
      canvas.drawCircle(Offset(w * 0.77, h * 0.65), w * 0.03, tearPaint);
      canvas.drawCircle(Offset(w * 0.74, h * 0.75), w * 0.035, tearPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MascotFacePainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}
