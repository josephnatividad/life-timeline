// ignore_for_file: prefer_initializing_formals

import 'package:life_timeline/features/private_intelligence/application/capture_intelligence_use_case.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final class CandidateReviewDraft {
  const CandidateReviewDraft({
    required this.title,
    required this.fields,
    this.linkedEntityId,
    this.createEntityName,
  });

  final String? createEntityName;
  final List<ExtractedField> fields;
  final String? linkedEntityId;
  final String title;
}

final class ConfirmCandidateUseCase {
  ConfirmCandidateUseCase({
    required MemoryCandidateRepository candidates,
    required TimelineRepository timeline,
    IntelligenceIdGenerator? ids,
    DateTime Function()? now,
  }) : _candidates = candidates,
       _timeline = timeline,
       _ids = ids ?? IntelligenceIdGenerator(),
       _now = now ?? DateTime.now;

  final MemoryCandidateRepository _candidates;
  final IntelligenceIdGenerator _ids;
  final DateTime Function() _now;
  final TimelineRepository _timeline;

  Future<String> call(String candidateId, CandidateReviewDraft draft) async {
    final candidate = await _candidates.candidateById(candidateId);
    if (candidate == null) throw StateError('Candidate no longer exists.');
    final title = draft.title.trim();
    if (title.isEmpty) throw ArgumentError('A memory title is required.');
    final now = _now().toUtc();
    final eventId = _ids.next('event');
    final updatedCandidate = candidate.copyWith(
      title: title,
      extractedFields: draft.fields,
      reviewStatus: CandidateReviewStatus.reviewing,
      metadata: candidate.metadata.copyWith(updatedAt: now),
    );
    await _candidates.saveCandidate(updatedCandidate);

    final event = Event(
      metadata: RecordMetadata(
        id: eventId,
        privacyClassification: candidate.metadata.privacyClassification,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
      title: title,
      description: candidate.description,
      temporalValue: _reviewedTemporal(candidate, draft.fields),
      eventType: candidate.documentType.name,
    );

    final entities = <Entity>[];
    Entity? entity;
    if (draft.linkedEntityId != null) {
      entity = await _timeline.entityById(draft.linkedEntityId!);
      if (entity == null) throw StateError('Selected entity no longer exists.');
    } else if (draft.createEntityName?.trim().isNotEmpty ?? false) {
      final proposal = candidate.entityProposals.isEmpty
          ? null
          : candidate.entityProposals.first;
      entity = Entity(
        metadata: RecordMetadata(
          id: _ids.next('entity'),
          privacyClassification: candidate.metadata.privacyClassification,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: now,
          updatedAt: now,
        ),
        name: draft.createEntityName!.trim(),
        entityType: proposal?.entityType ?? 'related',
      );
      entities.add(entity);
    }
    final relationships = <Relationship>[];
    if (candidate.sourceEvidenceId != null) {
      relationships.add(
        Relationship(
          metadata: _metadata(_ids.next('relationship'), candidate, now),
          source: TimelineRecordReference(
            type: TimelineRecordType.event,
            id: eventId,
          ),
          target: TimelineRecordReference(
            type: TimelineRecordType.evidence,
            id: candidate.sourceEvidenceId!,
          ),
          relationshipType: 'supported_by',
        ),
      );
    }
    if (entity != null) {
      relationships.add(
        Relationship(
          metadata: _metadata(_ids.next('relationship'), candidate, now),
          source: TimelineRecordReference(
            type: TimelineRecordType.event,
            id: eventId,
          ),
          target: TimelineRecordReference(
            type: TimelineRecordType.entity,
            id: entity.metadata.id,
          ),
          relationshipType: 'involves',
        ),
      );
    }
    final provenance = [
      for (final field in draft.fields)
        FieldProvenance(
          id: _ids.next('provenance'),
          target: ProvenanceTarget(
            type: ProvenanceTargetType.event,
            id: eventId,
          ),
          fieldName: field.key,
          sourceId: candidate.sourceEvidenceId ?? candidate.metadata.id,
          sourceType: candidate.sourceEvidenceId == null
              ? ProvenanceSourceType.user
              : ProvenanceSourceType.attachment,
          extractionMethod: ExtractionMethod.deterministic,
          confidence: field.confidence,
          userConfirmed: true,
          privacyClassification: field.privacyClassification,
          createdAt: now,
          updatedAt: now,
        ),
    ];
    await _candidates.confirmCandidate(
      candidateId: candidateId,
      confirmedEvent: event,
      confirmedAt: now,
      provenance: provenance,
      entities: entities,
      relationships: relationships,
    );
    return eventId;
  }
}

RecordMetadata _metadata(String id, MemoryCandidate candidate, DateTime now) =>
    RecordMetadata(
      id: id,
      privacyClassification: candidate.metadata.privacyClassification,
      lifecycle: RecordLifecycle.confirmed,
      createdAt: now,
      updatedAt: now,
    );

TemporalValue _reviewedTemporal(
  MemoryCandidate candidate,
  List<ExtractedField> fields,
) {
  ExtractedField? purchaseDate;
  for (final field in fields) {
    if (field.key == 'purchaseDate') {
      purchaseDate = field;
      break;
    }
  }
  if (purchaseDate == null) return candidate.temporalValue;
  final match = RegExp(
    r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$',
  ).firstMatch(purchaseDate.value.trim());
  if (match == null) return TemporalValue.unknown();
  try {
    return TemporalValue.exactDate(
      year: int.parse(match.group(1)!),
      month: int.parse(match.group(2)!),
      day: int.parse(match.group(3)!),
    );
  } on ArgumentError {
    return TemporalValue.unknown();
  }
}
