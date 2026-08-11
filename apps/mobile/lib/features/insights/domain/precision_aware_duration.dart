import 'package:life_timeline/shared/domain/model/temporal_value.dart';

final class PrecisionAwareDuration {
  const PrecisionAwareDuration({
    required this.label,
    required this.months,
    required this.precision,
  });

  final String label;
  final int months;
  final TemporalPrecision precision;
}

abstract final class PrecisionAwareDurations {
  static PrecisionAwareDuration? between(
    TemporalValue start, {
    TemporalValue? end,
    required DateTime now,
  }) {
    if (start.start == null ||
        start.precision == TemporalPrecision.unknown ||
        start.precision == TemporalPrecision.before ||
        start.precision == TemporalPrecision.after) {
      return null;
    }
    final endPoint = end?.start;
    if (end != null &&
        (endPoint == null ||
            end.precision == TemporalPrecision.unknown ||
            end.precision == TemporalPrecision.before ||
            end.precision == TemporalPrecision.after)) {
      return null;
    }

    if (start.precision == TemporalPrecision.range) {
      final latestStart = start.end!;
      final earliestMonths = _monthsBetween(latestStart, endPoint, now);
      final latestMonths = _monthsBetween(start.start!, endPoint, now);
      if (earliestMonths < 0 || latestMonths < 0) return null;
      return PrecisionAwareDuration(
        label: earliestMonths == latestMonths
            ? 'Roughly ${_yearsOnly(latestMonths)}'
            : 'Roughly ${_yearsOnly(earliestMonths)}–${_yearsOnly(latestMonths)}',
        months: (earliestMonths + latestMonths) ~/ 2,
        precision: TemporalPrecision.range,
      );
    }

    final months = _monthsBetween(start.start!, endPoint, now);
    if (months < 0) return null;
    final prefix = switch (start.precision) {
      TemporalPrecision.exactDate => '',
      TemporalPrecision.month => 'About ',
      TemporalPrecision.year => 'About ',
      TemporalPrecision.approximate => 'Roughly ',
      _ => '',
    };
    final detailed =
        start.precision == TemporalPrecision.exactDate ||
        start.precision == TemporalPrecision.month;
    return PrecisionAwareDuration(
      label:
          '$prefix${detailed ? _yearsAndMonths(months) : _yearsOnly(months)}',
      months: months,
      precision: start.precision,
    );
  }

  static int _monthsBetween(
    TemporalPoint start,
    TemporalPoint? end,
    DateTime now,
  ) {
    final endYear = end?.year ?? now.year;
    final endMonth = end == null ? now.month : (end.month ?? start.month ?? 1);
    var months = (endYear - start.year) * 12 + endMonth - (start.month ?? 1);
    if (start.day != null && end?.day != null && end!.day! < start.day!) {
      months--;
    }
    return months;
  }

  static String _yearsAndMonths(int months) {
    final years = months ~/ 12;
    final remainder = months % 12;
    if (years == 0) return '$months ${months == 1 ? 'month' : 'months'}';
    if (remainder == 0) return '$years ${years == 1 ? 'year' : 'years'}';
    return '$years ${years == 1 ? 'year' : 'years'}, '
        '$remainder ${remainder == 1 ? 'month' : 'months'}';
  }

  static String _yearsOnly(int months) {
    final years = (months / 12).round();
    if (years == 0) return 'less than a year';
    return '$years ${years == 1 ? 'year' : 'years'}';
  }
}
