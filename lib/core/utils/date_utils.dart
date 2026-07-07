import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatWeekday(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }
}
