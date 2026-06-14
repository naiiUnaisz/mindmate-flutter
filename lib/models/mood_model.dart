class Mood {
  final String id;
  final String mood;
  final DateTime date;

  Mood({
    required this.id,
    required this.mood,
    required this.date,
  });

  factory Mood.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'] ?? map['created_at'] ?? map['tanggal'];
    // Backend returns 'mood_level' with values like 'neutral', 'happy', 'sad'
    // App internally uses 'normal' instead of 'neutral'
    String rawMood = (map['mood_level'] ?? map['mood'] ?? 'normal').toString();
    if (rawMood == 'neutral') rawMood = 'normal';
    return Mood(
      id: (map['id'] ?? '').toString(),
      mood: rawMood,
      date: rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'mood': mood,
        'date': date.toIso8601String(),
      };
}
