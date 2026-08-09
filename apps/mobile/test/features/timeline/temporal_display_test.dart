import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  test('formats every precision honestly', () {
    expect(
      TemporalDisplay.label(
        TemporalValue.exactDate(year: 2024, month: 6, day: 2),
      ),
      'June 2, 2024',
    );
    expect(
      TemporalDisplay.label(
        TemporalValue.approximate(TemporalPoint(year: 1998)),
      ),
      'Around 1998',
    );
    expect(
      TemporalDisplay.label(
        TemporalValue.range(
          start: TemporalPoint(year: 2018),
          end: TemporalPoint(year: 2020),
        ),
      ),
      '2018–2020',
    );
    expect(TemporalDisplay.label(TemporalValue.unknown()), 'Date unknown');
  });

  test('orders known dates newest-first and unknown dates last', () {
    final memories = [
      _memory('unknown', TemporalValue.unknown()),
      _memory('before', TemporalValue.before(TemporalPoint(year: 2020))),
      _memory('after', TemporalValue.after(TemporalPoint(year: 2020))),
      _memory('month', TemporalValue.month(year: 2021, month: 3)),
      _memory('year', TemporalValue.year(2021)),
    ];

    final ordered = TemporalDisplay.sortNewestFirst(memories);

    expect(ordered.map((memory) => memory.event.metadata.id), [
      'month',
      'year',
      'after',
      'before',
      'unknown',
    ]);
  });
}

TimelineMemory _memory(String id, TemporalValue temporal) {
  final at = DateTime.utc(2026);
  return TimelineMemory(
    event: Event(
      metadata: RecordMetadata(
        id: id,
        privacyClassification: PrivacyClassification.personal,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: at,
        updatedAt: at,
      ),
      title: id,
      eventType: 'Test',
      temporalValue: temporal,
    ),
  );
}
