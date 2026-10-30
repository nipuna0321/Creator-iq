import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Formats large numbers compactly: 1200 -> "1.2K", 1500000 -> "1.5M"
  static String compactNumber(num value) {
    if (value >= 1000000) {
      final formatted = (value / 1000000).toStringAsFixed(1);
      return '${formatted.endsWith('.0') ? formatted.substring(0, formatted.length - 2) : formatted}M';
    } else if (value >= 1000) {
      final formatted = (value / 1000).toStringAsFixed(1);
      return '${formatted.endsWith('.0') ? formatted.substring(0, formatted.length - 2) : formatted}K';
    }
    return value.toString();
  }

  /// Formats number with commas: 12450 -> "12,450"
  static String numberWithCommas(num value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  /// Formats percentages: 9.589 -> "9.6%"
  static String percentage(num? value) {
    if (value == null) return '0.0%';
    return '${value.toStringAsFixed(1)}%';
  }

  /// Formats date to readable short string: "Oct 12, 2026"
  static String shortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats date to day + month: "Oct 12"
  static String dayAndMonth(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Formats time: "02:30 PM"
  static String timeOnly(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}

