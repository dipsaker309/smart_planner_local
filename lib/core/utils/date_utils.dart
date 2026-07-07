import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static String dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime previousDay(DateTime date) {
    return DateTime(date.year, date.month, date.day).subtract(
      const Duration(days: 1),
    );
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}