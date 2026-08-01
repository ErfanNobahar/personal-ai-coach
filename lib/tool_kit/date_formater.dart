import 'package:intl/intl.dart';

abstract class DateFormater {
  static String monthFormater(DateTime time) {
    return DateFormat('MMM d, y').format(time); // Saturday, Jul 18, 2026
  }

  static String dayFormater(DateTime time) {
    return DateFormat('EEE d, y').format(time); // Saturday, Jul 18, 2026
  }

  // static String formater(DateTime time) {
  // return DateFormat('MMM d, y').format(time); // Saturday, Jul 18, 2026
  // }
}
