import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
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
    this.documentType = DocumentType.unknown,
    this.reviewStatus = CandidateReviewStatus.pending,
    this.overallConfidence,
    this.extractedFields = const [],
    this.entityProposals = const [],
    this.possibleDuplicateEventId,
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
  final DocumentType documentType;
  final String? description;
  final List<EntityProposal> entityProposals;
  final List<ExtractedField> extractedFields;
  final RecordMetadata metadata;
  final double? overallConfidence;
  final String? possibleDuplicateEventId;
  final CandidateReviewStatus reviewStatus;
  final String? sourceEvidenceId;
  final TemporalValue temporalValue;
  final String title;

  MemoryCandidate copyWith({
    RecordMetadata? metadata,
    String? title,
    TemporalValue? temporalValue,
    String? description,
    String? sourceEvidenceId,
    String? confirmedEventId,
    DocumentType? documentType,
    CandidateReviewStatus? reviewStatus,
    double? overallConfidence,
    List<ExtractedField>? extractedFields,
    List<EntityProposal>? entityProposals,
    String? possibleDuplicateEventId,
  }) => MemoryCandidate(
    metadata: metadata ?? this.metadata,
    title: title ?? this.title,
    temporalValue: temporalValue ?? this.temporalValue,
    description: description ?? this.description,
    sourceEvidenceId: sourceEvidenceId ?? this.sourceEvidenceId,
    confirmedEventId: confirmedEventId ?? this.confirmedEventId,
    documentType: documentType ?? this.documentType,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    overallConfidence: overallConfidence ?? this.overallConfidence,
    extractedFields: extractedFields ?? this.extractedFields,
    entityProposals: entityProposals ?? this.entityProposals,
    possibleDuplicateEventId:
        possibleDuplicateEventId ?? this.possibleDuplicateEventId,
  );
}
