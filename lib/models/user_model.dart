class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final int coins;
  final int earnedCoins;
  final int spentCoins;
  final int streak;
  final DateTime lastActiveDate;
  final int totalTasksCompleted;
  final String gender;
  final DateTime? dateOfBirth;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username = '',
    this.coins = 0,
    this.earnedCoins = 0,
    this.spentCoins = 0,
    this.streak = 0,
    required this.lastActiveDate,
    this.totalTasksCompleted = 0,
    this.gender = '',
    this.dateOfBirth,
  });

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get birthdayFormatted {
    if (dateOfBirth == null) return '-';
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year.toString().padLeft(2, '0')}';
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    int? coins,
    int? earnedCoins,
    int? spentCoins,
    int? streak,
    DateTime? lastActiveDate,
    int? totalTasksCompleted,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      earnedCoins: earnedCoins ?? this.earnedCoins,
      spentCoins: spentCoins ?? this.spentCoins,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'coins': coins,
      'earnedCoins': earnedCoins,
      'spentCoins': spentCoins,
      'streak': streak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'totalTasksCompleted': totalTasksCompleted,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
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
      username: map['username'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.tryParse(map['date_of_birth'])
          : null,
    );
  }
}
