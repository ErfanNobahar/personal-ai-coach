abstract class TimeFormater {
  /// Normalizes any of the following into a clean "HH:mm" string:
  ///   "20:00"
  ///   "20:00:00"
  ///   "20"
  ///   "2020-09-10T21"
  ///   "2020-09-10T21:30"
  ///   "2020-09-10T21:30:00"
  ///   "2020-09-10T21:30:00.000Z"
  ///   "2020-09-10 21:30:00"
  static String normalizeTimeString(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      throw FormatException('Empty time string');
    }

    // 1. If it contains 'T' or a space followed by digits, it's a datetime —
    //    pull out just the time portion after the date.
    String timePart = trimmed;
    if (trimmed.contains('T')) {
      timePart = trimmed.split('T').last;
    } else if (RegExp(r'^\d{4}-\d{2}-\d{2}\s').hasMatch(trimmed)) {
      timePart = trimmed.split(RegExp(r'\s+')).last;
    }

    // 2. Strip timezone / milliseconds junk: "21:30:00.000Z", "21:30:00+02:00"
    timePart = timePart
        .replaceAll('Z', '')
        .split('.')
        .first // drop milliseconds
        .split('+')
        .first; // drop timezone offset

    // Handle "-HH:mm" negative offsets (rare, but be safe) only if
    // it's a suffix, not the leading date separator (already stripped above).
    final offsetMatch = RegExp(
      r'^(\d{1,2}(:\d{2}){0,2})-\d{2}:\d{2}$',
    ).firstMatch(timePart);
    if (offsetMatch != null) {
      timePart = offsetMatch.group(1)!;
    }

    // 3. Now split into hour/minute/second.
    final segments = timePart.split(':');

    final hourStr = segments.isNotEmpty ? segments[0] : '';
    final minuteStr = segments.length > 1 ? segments[1] : '0';

    final hour = int.tryParse(hourStr);
    final minute = int.tryParse(minuteStr);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      throw FormatException('Unsupported time format: $input');
    }

    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Converts any of the messy formats above directly into total minutes since midnight.
  static int toMinutes(String input) {
    final normalized = normalizeTimeString(input);
    final parts = normalized.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
