import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract final class TemporalDisplay {
  static String label(TemporalValue value) => TemporalLabel.format(value);

  static String sectionLabel(TemporalValue value) => switch (value.precision) {
    TemporalPrecision.exactDate || TemporalPrecision.month =>
      '${TemporalLabel.monthName(value.start!.month!)} ${value.start!.year}',
    TemporalPrecision.year ||
    TemporalPrecision.approximate => '${value.start!.year}',
    TemporalPrecision.range => '${value.start!.year}–${value.end!.year}',
    TemporalPrecision.before => 'Before ${value.start!.year}',
    TemporalPrecision.after => 'After ${value.start!.year}',
    TemporalPrecision.unknown => 'Date unknown',
  };

  static List<TimelineMemory> sortNewestFirst(Iterable<TimelineMemory> values) {
    final result = values.toList();
    result.sort((left, right) {
      final temporal = _compareTemporal(
        right.event.temporalValue,
        left.event.temporalValue,
      );
      if (temporal != 0) {
        return temporal;
      }
      final updated = right.event.metadata.updatedAt.compareTo(
        left.event.metadata.updatedAt,
      );
      return updated != 0
          ? updated
          : left.event.metadata.id.compareTo(right.event.metadata.id);
    });
    return result;
  }

  static int _compareTemporal(TemporalValue left, TemporalValue right) {
    final leftKey = _sortKey(left);
    final rightKey = _sortKey(right);
    for (var index = 0; index < leftKey.length; index++) {
      final comparison = leftKey[index].compareTo(rightKey[index]);
      if (comparison != 0) {
        return comparison;
      }
    }
    return 0;
  }

  /// A display-only tuple. It never changes or fills persisted date fields.
  static List<int> _sortKey(TemporalValue value) {
    if (value.precision == TemporalPrecision.unknown) {
      return const [0, 0, 0, 0];
    }
    final point = value.start!;
    final boundaryRank = switch (value.precision) {
      TemporalPrecision.before => 0,
      TemporalPrecision.exactDate ||
      TemporalPrecision.month ||
      TemporalPrecision.year ||
      TemporalPrecision.approximate ||
      TemporalPrecision.range => 1,
      TemporalPrecision.after => 2,
      TemporalPrecision.unknown => 0,
    };
    return [point.year, point.month ?? 0, point.day ?? 0, boundaryRank];
  }
}
