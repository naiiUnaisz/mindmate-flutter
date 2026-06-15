class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isCompleted;
  final bool isCompletedToday;
  final bool isChecked;
  final String taskType;
  final DateTime createdAt;
  final int coinReward;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    this.isCompleted = false,
    this.isCompletedToday = false,
    this.isChecked = false,
    this.taskType = 'puzzle',
    required this.createdAt,
    this.coinReward = 10,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    bool? isCompletedToday,
    bool? isChecked,
    String? taskType,
    DateTime? createdAt,
    int? coinReward,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      isChecked: isChecked ?? this.isChecked,
      taskType: taskType ?? this.taskType,
      createdAt: createdAt ?? this.createdAt,
      coinReward: coinReward ?? this.coinReward,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'isCompletedToday': isCompletedToday,
      'isChecked': isChecked,
      'taskType': taskType,
      'createdAt': createdAt.toIso8601String(),
      'coinReward': coinReward,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: (map['id'] ?? '').toString(),
      title: map['title'] ?? '',
      description: map['description'],
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : DateTime.now(),
      isCompleted: map['is_checked'] ?? map['is_completed'] ?? map['isCompleted'] ?? false,
      isCompletedToday: map['is_completed_today'] ?? map['isCompletedToday'] ?? false,
      isChecked: map['is_checked'] ?? map['isChecked'] ?? false,
      taskType: map['task_type'] ?? map['taskType'] ?? 'puzzle',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      coinReward: int.tryParse((map['coin_reward'] ?? 10).toString()) ?? 10,
    );
  }
}
