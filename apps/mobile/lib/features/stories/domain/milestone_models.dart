import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

enum MilestoneType {
  anniversary,
  hundredthMemory,
  deviceOrdinal,
  ownershipDuration,
}

final class MilestoneCandidate {
  MilestoneCandidate({
    required this.id,
    required this.type,
    required this.headline,
    required this.detail,
    required List<String> sourceRecordIds,
    required this.privacyClassification,
    this.isExactToday = false,
  }) : sourceRecordIds = List.unmodifiable(sourceRecordIds) {
    if (id.trim().isEmpty ||
        headline.trim().isEmpty ||
        sourceRecordIds.isEmpty) {
      throw ArgumentError(
        'Milestone identity and source records are required.',
      );
    }
  }

  final String detail;
  final String headline;
  final String id;
  final bool isExactToday;
  final PrivacyClassification privacyClassification;
  final List<String> sourceRecordIds;
  final MilestoneType type;
}

abstract interface class MilestoneEngine {
  List<MilestoneCandidate> detect(
    List<TimelineMemory> confirmedMemories, {
    required DateTime now,
  });
}
