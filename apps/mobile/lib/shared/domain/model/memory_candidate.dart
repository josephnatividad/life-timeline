import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

final class MemoryCandidate {
  MemoryCandidate({
    required this.metadata,
    required this.title,
    required this.temporalValue,
    this.description,
    this.sourceEvidenceId,
    this.confirmedEventId,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
    if (metadata.lifecycle == RecordLifecycle.confirmed &&
        confirmedEventId == null) {
      throw ArgumentError('Confirmed candidates require a confirmed event.');
    }
  }

  final String? confirmedEventId;
  final String? description;
  final RecordMetadata metadata;
  final String? sourceEvidenceId;
  final TemporalValue temporalValue;
  final String title;
}
