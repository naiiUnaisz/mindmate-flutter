/// Structured coin history item from GET /api/coins/history.
class CoinHistoryItem {
  final int id;
  final int amount;
  final String status; // 'reward' | 'expense'
  final String description;
  final DateTime date;

  const CoinHistoryItem({
    required this.id,
    required this.amount,
    required this.status,
    required this.description,
    required this.date,
  });

  bool get isReward => status == 'reward';
  bool get isExpense => status == 'expense';

  factory CoinHistoryItem.fromMap(Map<String, dynamic> map) {
    return CoinHistoryItem(
      id: int.tryParse((map['id'] ?? 0).toString()) ?? 0,
      amount: int.tryParse((map['amount'] ?? 0).toString()) ?? 0,
      status: map['status']?.toString() ?? map['type']?.toString() ?? 'reward',
      description: map['description']?.toString() ?? map['title']?.toString() ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'status': status,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
