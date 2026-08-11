import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/insights/domain/precision_aware_duration.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

void main() {
  final now = DateTime.utc(2026, 8, 11);

  test('exact dates allow a detailed duration', () {
    final result = PrecisionAwareDurations.between(
      TemporalValue.exactDate(year: 2021, month: 1, day: 1),
      end: TemporalValue.exactDate(year: 2023, month: 4, day: 1),
      now: now,
    );

    expect(result?.label, '2 years, 3 months');
    expect(result?.precision, TemporalPrecision.exactDate);
  });

  test('year-only dates stay approximate', () {
    final result = PrecisionAwareDurations.between(
      TemporalValue.year(2019),
      end: TemporalValue.year(2021),
      now: now,
    );

    expect(result?.label, 'About 2 years');
  });

  test('approximate dates use rough language', () {
    final result = PrecisionAwareDurations.between(
      TemporalValue.approximate(TemporalPoint(year: 2019)),
      end: TemporalValue.year(2021),
      now: now,
    );

    expect(result?.label, 'Roughly 2 years');
  });

  test('ranges preserve uncertainty', () {
    final result = PrecisionAwareDurations.between(
      TemporalValue.range(
        start: TemporalPoint(year: 2018),
        end: TemporalPoint(year: 2020),
      ),
      end: TemporalValue.year(2022),
      now: now,
    );

    expect(result?.label, 'Roughly 2 years–4 years');
  });

  test('unknown and one-sided dates do not produce durations', () {
    expect(
      PrecisionAwareDurations.between(TemporalValue.unknown(), now: now),
      isNull,
    );
    expect(
      PrecisionAwareDurations.between(
        TemporalValue.before(TemporalPoint(year: 2020)),
        now: now,
      ),
      isNull,
    );
  });
}
