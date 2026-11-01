import 'package:intl/intl.dart';

/// Formatting helpers for numbers, percentages and dates.
class Fmt {
  Fmt._();

  /// 1234 → "1.2K", 2500000 → "2.5M".
  static String compact(num value) {
    if (value.abs() >= 1000000) return '${_trim(value / 1000000)}M';
    if (value.abs() >= 1000) return '${_trim(value / 1000)}K';
    return value.round().toString();
  }

  /// 4.236 → "4.2%".
  static String percent(double value, {int digits = 1}) => '${value.toStringAsFixed(digits)}%';

  /// Signed change, e.g. "+12.5%" or "-3.0%".
  static String change(double value) => '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';

  static String date(DateTime d) => DateFormat('MMM d, yyyy').format(d);
  static String shortDate(DateTime d) => DateFormat('MMM d').format(d);
  static String time(DateTime d) => DateFormat('h:mm a').format(d);
  static String weekday(DateTime d) => DateFormat('EEE').format(d);

  /// Formats an hour (0–23) as "6 PM".
  static String hour(int h) => DateFormat('h a').format(DateTime(2000, 1, 1, h));

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
