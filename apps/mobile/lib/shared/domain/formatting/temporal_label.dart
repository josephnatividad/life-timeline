import 'package:life_timeline/shared/domain/model/temporal_value.dart';

abstract final class TemporalLabel {
  static String format(TemporalValue value) => switch (value.precision) {
    TemporalPrecision.exactDate => _exact(value.start!),
    TemporalPrecision.month => _month(value.start!),
    TemporalPrecision.year => '${value.start!.year}',
    TemporalPrecision.approximate => 'Around ${partial(value.start!)}',
    TemporalPrecision.range =>
      '${partial(value.start!)}–${partial(value.end!)}',
    TemporalPrecision.before => 'Before ${partial(value.start!)}',
    TemporalPrecision.after => 'After ${partial(value.start!)}',
    TemporalPrecision.unknown => 'Date unknown',
  };

  static String partial(TemporalPoint point) {
    if (point.day != null) return _exact(point);
    if (point.month != null) return _month(point);
    return '${point.year}';
  }

  static String _exact(TemporalPoint point) =>
      '${monthName(point.month!)} ${point.day}, ${point.year}';

  static String _month(TemporalPoint point) =>
      '${monthName(point.month!)} ${point.year}';

  static String monthName(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}
