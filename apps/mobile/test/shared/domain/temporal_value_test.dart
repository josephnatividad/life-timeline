import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

void main() {
  group('TemporalValue serialization', () {
    final values = <TemporalValue>[
      TemporalValue.exactDate(year: 2024, month: 2, day: 29),
      TemporalValue.month(year: 2020, month: 7),
      TemporalValue.year(1998),
      TemporalValue.approximate(TemporalPoint(year: 1980)),
      TemporalValue.range(
        start: TemporalPoint(year: 2010, month: 3),
        end: TemporalPoint(year: 2012, month: 8),
      ),
      TemporalValue.before(TemporalPoint(year: 1975)),
      TemporalValue.after(TemporalPoint(year: 2001, month: 9)),
      TemporalValue.unknown(),
    ];

    for (final value in values) {
      test('${value.precision.name} round-trips without precision loss', () {
        expect(TemporalValue.fromJson(value.toJson()), value);
      });
    }

    test('approximate years are not coerced into dates', () {
      final value = TemporalValue.approximate(TemporalPoint(year: 1980));
      final json = value.toJson();

      expect(json['precision'], 'approximate');
      expect(value.start?.month, isNull);
      expect(value.start?.day, isNull);
    });

    test('rejects reversed ranges and invalid calendar dates', () {
      expect(
        () => TemporalValue.range(
          start: TemporalPoint(year: 2022),
          end: TemporalPoint(year: 2021),
        ),
        throwsArgumentError,
      );
      expect(
        () => TemporalValue.exactDate(year: 2023, month: 2, day: 29),
        throwsArgumentError,
      );
    });
  });
}
