import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy', 'en_US').format(date);
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'en_US').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy HH:mm', 'en_US').format(date);
  }
}
