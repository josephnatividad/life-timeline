import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

final class ReminderDateUnavailable implements Exception {
  const ReminderDateUnavailable([
    this.message = "This memory doesn't have an exact date yet.",
  ]);

  final String message;
  @override
  String toString() => message;
}

abstract final class ReminderPolicy {
  static LocalDate exactDate(TemporalValue temporal) {
    if (temporal.precision != TemporalPrecision.exactDate) {
      throw const ReminderDateUnavailable();
    }
    final point = temporal.start!;
    return LocalDate(point.year, point.month!, point.day!);
  }

  static List<ReminderLeadTime> presets(ReminderType type) => switch (type) {
    ReminderType.expiry || ReminderType.renewal => const [
      ReminderLeadTime.thirtyDays,
      ReminderLeadTime.ninetyDays,
      ReminderLeadTime.sixMonths,
      ReminderLeadTime.custom,
    ],
    ReminderType.warranty => const [
      ReminderLeadTime.sevenDays,
      ReminderLeadTime.thirtyDays,
      ReminderLeadTime.custom,
    ],
    ReminderType.anniversary => const [
      ReminderLeadTime.onDay,
      ReminderLeadTime.oneDay,
      ReminderLeadTime.sevenDays,
      ReminderLeadTime.custom,
    ],
    ReminderType.followUp || ReminderType.custom => const [
      ReminderLeadTime.onDay,
      ReminderLeadTime.oneDay,
      ReminderLeadTime.sevenDays,
      ReminderLeadTime.thirtyDays,
      ReminderLeadTime.custom,
    ],
  };

  static LocalDate dateFor(LocalDate target, ReminderLeadTime leadTime) {
    final targetDate = target.asUtcDate;
    final value = switch (leadTime) {
      ReminderLeadTime.onDay || ReminderLeadTime.custom => targetDate,
      ReminderLeadTime.oneDay => targetDate.subtract(const Duration(days: 1)),
      ReminderLeadTime.sevenDays => targetDate.subtract(
        const Duration(days: 7),
      ),
      ReminderLeadTime.thirtyDays => targetDate.subtract(
        const Duration(days: 30),
      ),
      ReminderLeadTime.ninetyDays => targetDate.subtract(
        const Duration(days: 90),
      ),
      ReminderLeadTime.sixMonths => _subtractMonths(targetDate, 6),
    };
    return LocalDate.fromDateTime(value);
  }

  /// Returns the next explicit occurrence without introducing recurrence.
  static LocalDate nextAnniversary(LocalDate historical, LocalDate today) {
    var candidate = _dateInYear(historical, today.year);
    if (candidate.compareTo(today) < 0) {
      candidate = _dateInYear(historical, today.year + 1);
    }
    return candidate;
  }

  static LocalDate _dateInYear(LocalDate historical, int year) {
    final lastDay = DateTime.utc(year, historical.month + 1, 0).day;
    return LocalDate(year, historical.month, historical.day.clamp(1, lastDay));
  }

  static DateTime _subtractMonths(DateTime date, int months) {
    final total = date.year * 12 + date.month - 1 - months;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, date.day.clamp(1, lastDay));
  }
}
