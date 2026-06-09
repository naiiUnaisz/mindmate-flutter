class User {
  final String id;
  final String name;
  final String email;
  final int coins;
  final int earnedCoins;
  final int spentCoins;
  final int streak;
  final DateTime lastActiveDate;
  final int totalTasksCompleted;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.coins = 0,
    this.earnedCoins = 0,
    this.spentCoins = 0,
    this.streak = 0,
    required this.lastActiveDate,
    this.totalTasksCompleted = 0,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? coins,
    int? earnedCoins,
    int? spentCoins,
    int? streak,
    DateTime? lastActiveDate,
    int? totalTasksCompleted,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      earnedCoins: earnedCoins ?? this.earnedCoins,
      spentCoins: spentCoins ?? this.spentCoins,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'coins': coins,
      'earnedCoins': earnedCoins,
      'spentCoins': spentCoins,
      'streak': streak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'totalTasksCompleted': totalTasksCompleted,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['id'] ?? '').toString(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      coins: int.tryParse((map['coin_balance'] ?? 0).toString()) ?? 0,
      earnedCoins: int.tryParse((map['coin_balance'] ?? 0).toString()) ?? 0,
      spentCoins: 0,
      streak: int.tryParse((map['current_streak'] ?? 0).toString()) ?? 0,
      lastActiveDate: map['last_active_date'] != null
          ? DateTime.parse(map['last_active_date'])
          : DateTime.now(),
      totalTasksCompleted: map['total_tasks_completed'] ?? 0,
    );
  }
}
