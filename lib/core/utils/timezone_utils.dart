import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';

class TimezoneUtils {
  static DateTime _toColombia(String rawDate) {
    final dt = DateFormat('MM/dd/yyyy HH:mm').parse(rawDate, true);
    return dt.add(const Duration(hours: -5));
  }

  /// Converts "MM/dd/yyyy HH:mm" (worldcup26.ir UTC) to Colombia time
  static String toLocalTime(String rawDate) {
    try {
      final local = _toColombia(rawDate);
      final now = DateTime.now();
      final isToday = local.day == now.day &&
          local.month == now.month &&
          local.year == now.year;
      final isTomorrow = local.day == now.day + 1 &&
          local.month == now.month &&
          local.year == now.year;

      final time = DateFormat('HH:mm').format(local);
      final date = DateFormat('MMM d').format(local);

      if (isToday) return 'Today $time';
      if (isTomorrow) return 'Tomorrow $time';
      return '$date $time';
    } catch (_) {
      return rawDate;
    }
  }

  static String getLocalizedDate(String localDate, BuildContext context) {
    try {
      final local = _toColombia(localDate);
      final now = DateTime.now();
      final isToday = local.day == now.day &&
          local.month == now.month &&
          local.year == now.year;
      final isTomorrow = local.day == now.day + 1 &&
          local.month == now.month &&
          local.year == now.year;

      final time = DateFormat('HH:mm').format(local);
      final date = DateFormat('MMM d').format(local);

      if (isToday) return '${context.tr('Today', 'Hoy')} $time';
      if (isTomorrow) return '${context.tr('Tomorrow', 'Mañana')} $time';
      return '$date $time';
    } catch (_) {
      return localDate;
    }
  }

  static String toLocalDate(String rawDate) {
    try {
      final local = _toColombia(rawDate);
      return DateFormat('EEE, MMM d').format(local);
    } catch (_) {
      return rawDate;
    }
  }
}
