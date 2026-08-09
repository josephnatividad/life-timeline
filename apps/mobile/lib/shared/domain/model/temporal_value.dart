enum TemporalPrecision {
  exactDate,
  month,
  year,
  approximate,
  range,
  before,
  after,
  unknown,
}

final class TemporalPoint {
  TemporalPoint({required this.year, this.month, this.day}) {
    if (year < 1 || year > 9999) {
      throw ArgumentError.value(year, 'year', 'Must be between 1 and 9999.');
    }
    if (month != null && (month! < 1 || month! > 12)) {
      throw ArgumentError.value(month, 'month', 'Must be between 1 and 12.');
    }
    if (day != null && month == null) {
      throw ArgumentError('A day requires a month.');
    }
    if (day != null) {
      final lastDay = DateTime.utc(
        year,
        month! + 1,
      ).subtract(const Duration(days: 1)).day;
      if (day! < 1 || day! > lastDay) {
        throw ArgumentError.value(day, 'day', 'Invalid day for the month.');
      }
    }
  }

  factory TemporalPoint.fromJson(Map<String, Object?> json) => TemporalPoint(
    year: json['year']! as int,
    month: json['month'] as int?,
    day: json['day'] as int?,
  );

  final int? day;
  final int? month;
  final int year;

  bool get hasDay => day != null;
  bool get hasMonth => month != null;

  Map<String, Object?> toJson() => {'year': year, 'month': month, 'day': day};

  @override
  bool operator ==(Object other) =>
      other is TemporalPoint &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

final class TemporalValue {
  TemporalValue._({required this.precision, this.start, this.end}) {
    _validate();
  }

  factory TemporalValue.exactDate({
    required int year,
    required int month,
    required int day,
  }) => TemporalValue._(
    precision: TemporalPrecision.exactDate,
    start: TemporalPoint(year: year, month: month, day: day),
  );

  factory TemporalValue.month({required int year, required int month}) =>
      TemporalValue._(
        precision: TemporalPrecision.month,
        start: TemporalPoint(year: year, month: month),
      );

  factory TemporalValue.year(int year) => TemporalValue._(
    precision: TemporalPrecision.year,
    start: TemporalPoint(year: year),
  );

  factory TemporalValue.approximate(TemporalPoint around) =>
      TemporalValue._(precision: TemporalPrecision.approximate, start: around);

  factory TemporalValue.range({
    required TemporalPoint start,
    required TemporalPoint end,
  }) => TemporalValue._(
    precision: TemporalPrecision.range,
    start: start,
    end: end,
  );

  factory TemporalValue.before(TemporalPoint point) =>
      TemporalValue._(precision: TemporalPrecision.before, start: point);

  factory TemporalValue.after(TemporalPoint point) =>
      TemporalValue._(precision: TemporalPrecision.after, start: point);

  factory TemporalValue.unknown() =>
      TemporalValue._(precision: TemporalPrecision.unknown);

  factory TemporalValue.fromJson(Map<String, Object?> json) => TemporalValue._(
    precision: _precisionFromStorage(json['precision']! as String),
    start: switch (json['start']) {
      final Map<String, Object?> value => TemporalPoint.fromJson(value),
      _ => null,
    },
    end: switch (json['end']) {
      final Map<String, Object?> value => TemporalPoint.fromJson(value),
      _ => null,
    },
  );

  final TemporalPoint? end;
  final TemporalPrecision precision;
  final TemporalPoint? start;

  void _validate() {
    switch (precision) {
      case TemporalPrecision.exactDate:
        if (start == null || !start!.hasDay || end != null) {
          throw ArgumentError('Exact dates require one complete date.');
        }
        return;
      case TemporalPrecision.month:
        if (start == null || !start!.hasMonth || start!.hasDay || end != null) {
          throw ArgumentError('Month precision requires only year and month.');
        }
        return;
      case TemporalPrecision.year:
        if (start == null || start!.hasMonth || end != null) {
          throw ArgumentError('Year precision requires only a year.');
        }
        return;
      case TemporalPrecision.approximate:
      case TemporalPrecision.before:
      case TemporalPrecision.after:
        if (start == null || end != null) {
          throw ArgumentError('$precision requires one partial date.');
        }
        return;
      case TemporalPrecision.range:
        if (start == null || end == null || _isAfter(start!, end!)) {
          throw ArgumentError('Ranges require ordered start and end values.');
        }
        return;
      case TemporalPrecision.unknown:
        if (start != null || end != null) {
          throw ArgumentError('Unknown precision cannot contain a date.');
        }
        return;
    }
  }

  static bool _isAfter(TemporalPoint left, TemporalPoint right) {
    final leftValue =
        left.year * 10000 + (left.month ?? 1) * 100 + (left.day ?? 1);
    final rightValue =
        right.year * 10000 + (right.month ?? 12) * 100 + (right.day ?? 31);
    return leftValue > rightValue;
  }

  Map<String, Object?> toJson() => {
    'precision': _precisionToStorage(precision),
    'start': start?.toJson(),
    'end': end?.toJson(),
  };

  static String _precisionToStorage(TemporalPrecision value) => switch (value) {
    TemporalPrecision.exactDate => 'exact_date',
    TemporalPrecision.month => 'month',
    TemporalPrecision.year => 'year',
    TemporalPrecision.approximate => 'approximate',
    TemporalPrecision.range => 'range',
    TemporalPrecision.before => 'before',
    TemporalPrecision.after => 'after',
    TemporalPrecision.unknown => 'unknown',
  };

  static TemporalPrecision _precisionFromStorage(String value) =>
      switch (value) {
        'exact_date' => TemporalPrecision.exactDate,
        'month' => TemporalPrecision.month,
        'year' => TemporalPrecision.year,
        'approximate' => TemporalPrecision.approximate,
        'range' => TemporalPrecision.range,
        'before' => TemporalPrecision.before,
        'after' => TemporalPrecision.after,
        'unknown' => TemporalPrecision.unknown,
        _ => throw FormatException('Unknown temporal precision: $value'),
      };

  @override
  bool operator ==(Object other) =>
      other is TemporalValue &&
      precision == other.precision &&
      start == other.start &&
      end == other.end;

  @override
  int get hashCode => Object.hash(precision, start, end);
}
