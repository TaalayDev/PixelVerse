import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String format(String pattern) {
    return DateFormat(pattern, 'ru').format(this);
  }
}
