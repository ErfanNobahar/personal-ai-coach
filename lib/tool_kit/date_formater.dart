import 'package:intl/intl.dart';

abstract class DateFormater {
  /// Output: "Aug 21, 2026"
  static String monthFormater(DateTime time) {
    return DateFormat('MMM d, y').format(time);
  }

  /// Output: "Thu 21, 2026"
  static String dayFormater(DateTime time) {
    return DateFormat('EEE d, y').format(time);
  }

  /// Tries multiple formats so ISO strings like "2026-08-21" just work.
  static DateTime dateFromString(String dateString) {
    final trimmed = dateString.trim();

    // 1. ISO 8601: 2026-08-21
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return DateFormat('yyyy-MM-dd').parse(trimmed);
    }

    // 2. Your existing UI format: Aug 21, 2026
    try {
      return DateFormat('MMM d, y').parse(trimmed);
    } catch (_) {}

    // 3. ISO with time: 2026-08-21T14:30:00
    try {
      return DateTime.parse(trimmed);
    } catch (_) {}

    throw FormatException('Unsupported date format: $dateString');
  }

  /// Convenience: "2026-08-21" → "Aug 21, 2026"
  static String formatString(String dateString) {
    return monthFormater(dateFromString(dateString));
  }

  /// Convenience: "2026-08-21" → "Thu 21, 2026"
  static String dayFormatString(String dateString) {
    return dayFormater(dateFromString(dateString));
  }
}
