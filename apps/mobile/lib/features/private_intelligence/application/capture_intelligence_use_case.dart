// ignore_for_file: prefer_initializing_formals

import 'dart:math';

import 'package:life_timeline/features/private_intelligence/application/intelligence_ports.dart';
import 'package:life_timeline/features/private_intelligence/domain/document_intelligence.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

enum CaptureIntelligenceOutcome {
  created,
  cancelled,
  noUsefulText,
  limitReached,
}

final class CaptureIntelligenceResult {
  const CaptureIntelligenceResult(this.outcome, {this.candidateId});
  final String? candidateId;
  final CaptureIntelligenceOutcome outcome;
}

final class IntelligenceIdGenerator {
  IntelligenceIdGenerator({Random? random})
    : _random = random ?? Random.secure();
  final Random _random;

  String next(String prefix) =>
      '$prefix-${DateTime.now().toUtc().microsecondsSinceEpoch}-${_random.nextInt(0x7fffffff).toRadixString(36)}';
}

final class CaptureIntelligenceUseCase {
  CaptureIntelligenceUseCase({
    required ImageAcquisitionService acquisition,
    required ImagePreparationService preparation,
    required CandidateAttachmentStore attachments,
    required TextRecognitionEngine recognizer,
    required MemoryCandidateRepository candidates,
    required TimelineRepository timeline,
    required FeatureUsageRepository usage,
    required EntitlementService entitlements,
    required ComplimentaryUsagePolicy usagePolicy,
    IntelligenceIdGenerator? ids,
    DeterministicDocumentClassifier classifier =
        const DeterministicDocumentClassifier(),
    DeterministicExtractionPipeline? extraction,
    DateTime Function()? now,
  }) : _acquisition = acquisition,
       _preparation = preparation,
       _attachments = attachments,
       _recognizer = recognizer,
       _candidates = candidates,
       _timeline = timeline,
       _usage = usage,
       _entitlements = entitlements,
       _usagePolicy = usagePolicy,
       _ids = ids ?? IntelligenceIdGenerator(),
       _classifier = classifier,
       _extraction = extraction ?? DeterministicExtractionPipeline(),
       _now = now ?? DateTime.now;

  final ImageAcquisitionService _acquisition;
  final CandidateAttachmentStore _attachments;
  final MemoryCandidateRepository _candidates;
  final DeterministicDocumentClassifier _classifier;
  final EntitlementService _entitlements;
  final DeterministicExtractionPipeline _extraction;
  final IntelligenceIdGenerator _ids;
  final DateTime Function() _now;
  final ImagePreparationService _preparation;
  final TextRecognitionEngine _recognizer;
  final TimelineRepository _timeline;
  final FeatureUsageRepository _usage;
  final ComplimentaryUsagePolicy _usagePolicy;

  Future<CaptureIntelligenceResult> call(
    CaptureSource source, {
    CaptureStageChanged? onStage,
  }) async {
    final hasPro = await _entitlements.hasAccess(ProFeature.aiCapture);
    final used = await _usage.usageCount(ProFeature.aiCapture);
    if (!hasPro && used >= _usagePolicy.aiCaptureActions) {
      return const CaptureIntelligenceResult(
        CaptureIntelligenceOutcome.limitReached,
      );
    }
    onStage?.call('Choose an image');
    final captured = await _acquisition.acquire(source);
    if (captured == null) {
      return const CaptureIntelligenceResult(
        CaptureIntelligenceOutcome.cancelled,
      );
    }

    PreparedImage? prepared;
    ManagedImage? managed;
    try {
      onStage?.call('Preparing image privately');
      prepared = await _preparation.prepare(captured);
      onStage?.call('Reading text on this device');
      final document = await _recognizer.recognize(prepared.path);
      if (document.isEmpty || document.text.trim().length < 8) {
        return const CaptureIntelligenceResult(
          CaptureIntelligenceOutcome.noUsefulText,
        );
      }
      onStage?.call('Organizing a reviewable draft');
      final classification = _classifier.classify(document);
      if (classification.documentType == DocumentType.unknown) {
        return const CaptureIntelligenceResult(
          CaptureIntelligenceOutcome.noUsefulText,
        );
      }
      final candidateId = _ids.next('candidate');
      var extraction = _extraction.extract(
        document,
        classification,
        candidateId,
      );
      extraction = ExtractionResult(
        title: extraction.title,
        description: extraction.description,
        fields: extraction.fields,
        entityProposals: await _matchEntities(extraction.entityProposals),
        overallConfidence:
            (extraction.overallConfidence + classification.confidence) / 2,
      );
      final evidenceId = _ids.next('evidence');
      final attachmentId = _ids.next('attachment');
      managed = await _attachments.store(prepared, attachmentId);
      final now = _now().toUtc();
      final privacy = _mostRestrictive(extraction.fields);
      final temporal = _temporalFrom(extraction.fields);
      final possibleDuplicateEventId = await _possibleDuplicate(
        extraction.title,
        temporal,
      );
      final candidate = MemoryCandidate(
        metadata: RecordMetadata(
          id: candidateId,
          privacyClassification: privacy,
          lifecycle: RecordLifecycle.candidate,
          createdAt: now,
          updatedAt: now,
        ),
        title: extraction.title,
        description: extraction.description,
        temporalValue: temporal,
        sourceEvidenceId: evidenceId,
        documentType: classification.documentType,
        overallConfidence: extraction.overallConfidence,
        extractedFields: extraction.fields,
        entityProposals: extraction.entityProposals,
        possibleDuplicateEventId: possibleDuplicateEventId,
      );
      final evidence = Evidence(
        metadata: RecordMetadata(
          id: evidenceId,
          privacyClassification: privacy,
          lifecycle: RecordLifecycle.candidate,
          createdAt: now,
          updatedAt: now,
        ),
        evidenceType: _evidenceType(classification.documentType),
        title: '${_label(classification.documentType)} capture',
        summary: 'Local OCR candidate; review required.',
      );
      final attachment = Attachment(
        metadata: RecordMetadata(
          id: attachmentId,
          privacyClassification: privacy,
          lifecycle: RecordLifecycle.candidate,
          createdAt: now,
          updatedAt: now,
        ),
        evidenceId: evidenceId,
        storageState: AttachmentStorageState.local,
        importMode: AttachmentImportMode.optimizedCopy,
        mimeType: prepared.mimeType,
        byteSize: managed.byteSize,
        checksum: managed.checksum,
        displayName: '${_label(classification.documentType)}.jpg',
        relativePath: managed.relativePath,
      );
      final provenance = [
        for (final extracted in extraction.fields)
          FieldProvenance(
            id: _ids.next('provenance'),
            target: ProvenanceTarget(
              type: ProvenanceTargetType.memoryCandidate,
              id: candidateId,
            ),
            fieldName: extracted.key,
            sourceId: evidenceId,
            sourceType: ProvenanceSourceType.attachment,
            extractionMethod: ExtractionMethod.deterministic,
            confidence: extracted.confidence,
            userConfirmed: false,
            privacyClassification: extracted.privacyClassification,
            createdAt: now,
            updatedAt: now,
          ),
      ];
      await _candidates.saveCaptureCandidate(
        candidate: candidate,
        evidence: evidence,
        attachment: attachment,
        provenance: provenance,
      );
      await _usage.increment(ProFeature.aiCapture, now);
      managed = null;
      return CaptureIntelligenceResult(
        CaptureIntelligenceOutcome.created,
        candidateId: candidateId,
      );
    } finally {
      if (managed != null) {
        await _bestEffort(() => _attachments.remove(managed!));
      }
      if (prepared != null) {
        await _bestEffort(() => _preparation.discard(prepared!));
      }
      await _bestEffort(() => _acquisition.release(captured));
    }
  }

  Future<List<EntityProposal>> _matchEntities(
    List<EntityProposal> proposals,
  ) async {
    final existing = await _timeline.matchableEntities();
    final results = <EntityProposal>[];
    for (final proposal in proposals) {
      if (proposal.serialNumber case final serial?) {
        final entityId = await _candidates.entityIdForExactSerial(serial);
        if (entityId != null) {
          results.add(
            EntityProposal(
              id: proposal.id,
              name: proposal.name,
              entityType: proposal.entityType,
              confidence: proposal.confidence,
              brand: proposal.brand,
              model: proposal.model,
              serialNumber: serial,
              suggestedEntityId: entityId,
              matchScore: 1,
              matchReasons: const ['Same exact serial number'],
            ),
          );
          continue;
        }
      }
      results.add(_bestMatch(proposal, existing));
    }
    return results;
  }

  Future<String?> _possibleDuplicate(
    String title,
    TemporalValue temporal,
  ) async {
    final results = await _timeline.searchMemories(title);
    final normalized = _normalize(title);
    for (final result in results) {
      final event = result.memory.event;
      if (_normalize(event.title) == normalized &&
          event.temporalValue == temporal) {
        return event.metadata.id;
      }
    }
    return null;
  }

  EntityProposal _bestMatch(EntityProposal proposal, List<Entity> existing) {
    final name = _normalize(proposal.name);
    Entity? best;
    var score = 0.0;
    final reasons = <String>[];
    for (final entity in existing) {
      var candidateScore = 0.0;
      final candidateReasons = <String>[];
      if (_normalize(entity.name) == name) {
        candidateScore += 0.75;
        candidateReasons.add('Same normalized name');
      }
      if (entity.entityType == proposal.entityType) {
        candidateScore += 0.15;
        candidateReasons.add('Same entity type');
      }
      if (candidateScore > score) {
        best = entity;
        score = candidateScore.clamp(0, 1);
        reasons
          ..clear()
          ..addAll(candidateReasons);
      }
    }
    if (best == null || score < 0.7) return proposal;
    return EntityProposal(
      id: proposal.id,
      name: proposal.name,
      entityType: proposal.entityType,
      confidence: proposal.confidence,
      brand: proposal.brand,
      model: proposal.model,
      serialNumber: proposal.serialNumber,
      suggestedEntityId: best.metadata.id,
      matchScore: score,
      matchReasons: reasons,
    );
  }
}

Future<void> _bestEffort(Future<void> Function() action) async {
  try {
    await action();
  } on Object {
    // Cleanup must not turn a committed candidate into a reported failure.
  }
}

String _normalize(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

PrivacyClassification _mostRestrictive(List<ExtractedField> fields) {
  var result = PrivacyClassification.personal;
  for (final field in fields) {
    if (field.privacyClassification.index > result.index) {
      result = field.privacyClassification;
    }
  }
  return result;
}

TemporalValue _temporalFrom(List<ExtractedField> fields) {
  final date = fields.where(
    (field) => field.valueType == ExtractedValueType.date,
  );
  if (date.isEmpty) return TemporalValue.unknown();
  final match = RegExp(
    r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$',
  ).firstMatch(date.first.value);
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

EvidenceType _evidenceType(DocumentType type) => switch (type) {
  DocumentType.receipt => EvidenceType.receipt,
  DocumentType.travel => EvidenceType.ticket,
  _ => EvidenceType.document,
};

String _label(DocumentType type) => switch (type) {
  DocumentType.genericDocument => 'Document',
  _ => '${type.name[0].toUpperCase()}${type.name.substring(1)}',
};
