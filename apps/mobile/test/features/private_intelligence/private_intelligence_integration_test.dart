import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/private_intelligence/application/capture_intelligence_use_case.dart';
import 'package:life_timeline/features/private_intelligence/application/confirm_candidate_use_case.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_ports.dart';
import 'package:life_timeline/features/private_intelligence/domain/document_intelligence.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/features/private_intelligence/infrastructure/drift_intelligence_services.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Attachment, Entity, Event, MemoryCandidate, Relationship;
import 'package:life_timeline/shared/database/repositories/drift_memory_candidate_repository.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

void main() {
  late AppDatabase database;
  late DriftMemoryCandidateRepository candidates;
  late DriftTimelineRepository timeline;
  late DriftFeatureUsageRepository usage;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    candidates = DriftMemoryCandidateRepository(database);
    timeline = DriftTimelineRepository(database);
    usage = DriftFeatureUsageRepository(database);
  });

  tearDown(() => database.close());

  test(
    'local capture creates a structured candidate and counts once',
    () async {
      final preparation = _Preparation();
      final attachments = _Attachments();
      final useCase = _capture(
        candidates: candidates,
        timeline: timeline,
        usage: usage,
        preparation: preparation,
        attachments: attachments,
      );

      final result = await useCase(CaptureSource.photoLibrary);
      final candidate = await candidates.candidateById(result.candidateId!);

      expect(result.outcome, CaptureIntelligenceOutcome.created);
      expect(candidate?.documentType, DocumentType.receipt);
      expect(candidate?.extractedFields, isNotEmpty);
      expect(candidate?.sourceEvidenceId, isNotNull);
      expect(await usage.usageCount(ProFeature.aiCapture), 1);
      expect(preparation.discarded, isTrue);
      expect(attachments.removed, isFalse);
      final provenance = await database
          .select(database.fieldProvenanceRows)
          .get();
      expect(provenance, isNotEmpty);
      expect(provenance.every((row) => row.userConfirmed == false), isTrue);
    },
  );

  test('cancelled and empty OCR attempts do not consume usage', () async {
    final cancelled = CaptureIntelligenceUseCase(
      acquisition: _Acquisition(cancel: true),
      preparation: _Preparation(),
      attachments: _Attachments(),
      recognizer: const _Recognizer(),
      candidates: candidates,
      timeline: timeline,
      usage: usage,
      entitlements: const _Entitlements(),
      usagePolicy: const ComplimentaryUsagePolicy(aiCaptureActions: 2),
    );
    expect(
      (await cancelled(CaptureSource.camera)).outcome,
      CaptureIntelligenceOutcome.cancelled,
    );

    final empty = CaptureIntelligenceUseCase(
      acquisition: _Acquisition(),
      preparation: _Preparation(),
      attachments: _Attachments(),
      recognizer: const _Recognizer(empty: true),
      candidates: candidates,
      timeline: timeline,
      usage: usage,
      entitlements: const _Entitlements(),
      usagePolicy: const ComplimentaryUsagePolicy(aiCaptureActions: 2),
    );
    expect(
      (await empty(CaptureSource.camera)).outcome,
      CaptureIntelligenceOutcome.noUsefulText,
    );
    expect(await usage.usageCount(ProFeature.aiCapture), 0);
  });

  test(
    'confirmation atomically connects evidence and appears in search',
    () async {
      final captured = await _capture(
        candidates: candidates,
        timeline: timeline,
        usage: usage,
        preparation: _Preparation(),
        attachments: _Attachments(),
      )(CaptureSource.scan);
      final candidate = await candidates.candidateById(captured.candidateId!);
      final eventId =
          await ConfirmCandidateUseCase(
            candidates: candidates,
            timeline: timeline,
          ).call(
            captured.candidateId!,
            CandidateReviewDraft(
              title: 'Bought a kettle',
              fields: candidate!.extractedFields,
              createEntityName: 'Corner Market',
            ),
          );

      final event = await timeline.eventById(eventId);
      final evidence = await timeline.evidenceById(candidate.sourceEvidenceId!);
      final links = await timeline.relationshipsFor(
        TimelineRecordReference(type: TimelineRecordType.event, id: eventId),
      );
      final search = await timeline.searchMemories('kettle');

      expect(event?.metadata.lifecycle, RecordLifecycle.confirmed);
      expect(evidence?.metadata.lifecycle, RecordLifecycle.confirmed);
      expect(links, hasLength(2));
      expect(search.single.memory.event.metadata.id, eventId);
      expect(
        (await candidates.candidateById(captured.candidateId!))?.reviewStatus,
        CandidateReviewStatus.confirmed,
      );
    },
  );

  test('confirmation indexes an existing linked entity', () async {
    const existingEntityId = 'existing-entity';
    final at = DateTime.utc(2026, 8, 10);
    await timeline.saveEntity(
      Entity(
        metadata: RecordMetadata(
          id: existingEntityId,
          privacyClassification: PrivacyClassification.personal,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: at,
          updatedAt: at,
        ),
        name: 'Asteria Clinic',
        entityType: 'organization',
      ),
    );
    final captured = await _capture(
      candidates: candidates,
      timeline: timeline,
      usage: usage,
      preparation: _Preparation(),
      attachments: _Attachments(),
    )(CaptureSource.scan);
    final candidate = await candidates.candidateById(captured.candidateId!);

    final eventId =
        await ConfirmCandidateUseCase(
          candidates: candidates,
          timeline: timeline,
        ).call(
          captured.candidateId!,
          CandidateReviewDraft(
            title: 'Annual checkup',
            fields: candidate!.extractedFields,
            linkedEntityId: existingEntityId,
          ),
        );

    final search = await timeline.searchMemories('Asteria');
    expect(search.single.memory.event.metadata.id, eventId);
  });

  test('complimentary limit blocks OCR before image acquisition', () async {
    await usage.increment(ProFeature.aiCapture, DateTime.utc(2026));
    final acquisition = _Acquisition();
    final useCase = CaptureIntelligenceUseCase(
      acquisition: acquisition,
      preparation: _Preparation(),
      attachments: _Attachments(),
      recognizer: const _Recognizer(),
      candidates: candidates,
      timeline: timeline,
      usage: usage,
      entitlements: const _Entitlements(),
      usagePolicy: const ComplimentaryUsagePolicy(aiCaptureActions: 1),
    );

    expect(
      (await useCase(CaptureSource.camera)).outcome,
      CaptureIntelligenceOutcome.limitReached,
    );
    expect(acquisition.calls, 0);
  });

  test(
    'failed candidate transaction removes managed and temporary copies',
    () async {
      final preparation = _Preparation();
      final attachments = _Attachments();
      final useCase = CaptureIntelligenceUseCase(
        acquisition: _Acquisition(),
        preparation: preparation,
        attachments: attachments,
        recognizer: const _Recognizer(),
        candidates: _FailingCandidates(),
        timeline: timeline,
        usage: usage,
        entitlements: const _Entitlements(),
        usagePolicy: const ComplimentaryUsagePolicy(aiCaptureActions: 1),
      );

      await expectLater(useCase(CaptureSource.camera), throwsStateError);
      expect(preparation.discarded, isTrue);
      expect(attachments.removed, isTrue);
      expect(await usage.usageCount(ProFeature.aiCapture), 0);
    },
  );

  test(
    'OCR interruption cleans temporary work without consuming usage',
    () async {
      final acquisition = _Acquisition();
      final preparation = _Preparation();
      final useCase = CaptureIntelligenceUseCase(
        acquisition: acquisition,
        preparation: preparation,
        attachments: _Attachments(),
        recognizer: const _FailingRecognizer(),
        candidates: candidates,
        timeline: timeline,
        usage: usage,
        entitlements: const _Entitlements(),
        usagePolicy: const ComplimentaryUsagePolicy(aiCaptureActions: 1),
      );

      await expectLater(useCase(CaptureSource.camera), throwsStateError);
      expect(preparation.discarded, isTrue);
      expect(acquisition.released, isTrue);
      expect(await usage.usageCount(ProFeature.aiCapture), 0);
      expect(await candidates.pendingCandidates(), isEmpty);
    },
  );

  test(
    'failed confirmation rolls back a partially inserted timeline graph',
    () async {
      final captured = await _capture(
        candidates: candidates,
        timeline: timeline,
        usage: usage,
        preparation: _Preparation(),
        attachments: _Attachments(),
      )(CaptureSource.scan);
      final candidate = await candidates.candidateById(captured.candidateId!);
      final confirmedAt = DateTime.now().toUtc();
      final failedEvent = Event(
        metadata: RecordMetadata(
          id: 'event-halfway-failure',
          privacyClassification: PrivacyClassification.sensitive,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: confirmedAt,
          updatedAt: confirmedAt,
        ),
        title: 'Must roll back',
        temporalValue: TemporalValue.unknown(),
        eventType: 'receipt',
      );

      await expectLater(
        candidates.confirmCandidate(
          candidateId: captured.candidateId!,
          confirmedEvent: failedEvent,
          confirmedAt: confirmedAt,
          relationships: [
            Relationship(
              metadata: RecordMetadata(
                id: 'relationship-invalid-target',
                privacyClassification: PrivacyClassification.sensitive,
                lifecycle: RecordLifecycle.confirmed,
                createdAt: confirmedAt,
                updatedAt: confirmedAt,
              ),
              source: TimelineRecordReference(
                type: TimelineRecordType.event,
                id: failedEvent.metadata.id,
              ),
              target: TimelineRecordReference(
                type: TimelineRecordType.entity,
                id: 'missing-entity',
              ),
              relationshipType: 'involves',
            ),
          ],
        ),
        throwsA(anything),
      );

      expect(await timeline.eventById(failedEvent.metadata.id), isNull);
      expect(
        (await candidates.candidateById(
          candidate!.metadata.id,
        ))?.metadata.lifecycle,
        RecordLifecycle.candidate,
      );
      expect(await database.select(database.relationships).get(), isEmpty);
    },
  );

  test('exact title and date are surfaced as a possible duplicate', () async {
    final now = DateTime.utc(2026, 8, 10);
    await timeline.saveEvent(
      Event(
        metadata: RecordMetadata(
          id: 'existing-receipt',
          privacyClassification: PrivacyClassification.personal,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: now,
          updatedAt: now,
        ),
        title: 'Purchase at Corner Market',
        temporalValue: TemporalValue.exactDate(year: 2026, month: 8, day: 9),
        eventType: 'receipt',
      ),
    );

    final captured = await _capture(
      candidates: candidates,
      timeline: timeline,
      usage: usage,
      preparation: _Preparation(),
      attachments: _Attachments(),
    )(CaptureSource.photoLibrary);
    final candidate = await candidates.candidateById(captured.candidateId!);

    expect(candidate?.possibleDuplicateEventId, 'existing-receipt');
  });
}

CaptureIntelligenceUseCase _capture({
  required DriftMemoryCandidateRepository candidates,
  required DriftTimelineRepository timeline,
  required DriftFeatureUsageRepository usage,
  required _Preparation preparation,
  required _Attachments attachments,
}) => CaptureIntelligenceUseCase(
  acquisition: _Acquisition(),
  preparation: preparation,
  attachments: attachments,
  recognizer: const _Recognizer(),
  candidates: candidates,
  timeline: timeline,
  usage: usage,
  entitlements: const _Entitlements(),
  usagePolicy: const ComplimentaryUsagePolicy(aiCaptureActions: 3),
);

final class _Acquisition implements ImageAcquisitionService {
  _Acquisition({this.cancel = false});
  final bool cancel;
  int calls = 0;
  bool released = false;

  @override
  Future<CapturedImage?> acquire(CaptureSource source) async {
    calls++;
    return cancel ? null : CapturedImage(path: 'fixture.jpg', source: source);
  }

  @override
  Future<void> release(CapturedImage image) async => released = true;
}

final class _Preparation implements ImagePreparationService {
  bool discarded = false;
  @override
  Future<PreparedImage> prepare(CapturedImage image) async =>
      const PreparedImage(
        path: 'prepared.jpg',
        mimeType: 'image/jpeg',
        byteSize: 10,
      );
  @override
  Future<void> discard(PreparedImage image) async => discarded = true;
}

final class _Attachments implements CandidateAttachmentStore {
  bool removed = false;
  @override
  Future<ManagedImage> store(PreparedImage image, String attachmentId) async =>
      ManagedImage(
        absolutePath: 'managed.jpg',
        relativePath: 'intelligence/$attachmentId.jpg',
        byteSize: image.byteSize,
        checksum: 'fixture-checksum',
      );
  @override
  Future<void> remove(ManagedImage image) async => removed = true;
}

final class _Recognizer implements TextRecognitionEngine {
  const _Recognizer({this.empty = false});
  final bool empty;
  @override
  Future<OcrDocument> recognize(String imagePath) async => empty
      ? const OcrDocument(lines: [])
      : const OcrDocument(
          lines: [
            OcrLine(text: 'Corner Market'),
            OcrLine(text: 'Receipt'),
            OcrLine(text: '2026-08-09'),
            OcrLine(text: 'TOTAL USD 10.80'),
          ],
        );
  @override
  Future<void> close() async {}
}

final class _FailingRecognizer implements TextRecognitionEngine {
  const _FailingRecognizer();

  @override
  Future<OcrDocument> recognize(String imagePath) =>
      throw StateError('simulated OCR interruption');

  @override
  Future<void> close() async {}
}

final class _Entitlements implements EntitlementService {
  const _Entitlements();
  @override
  Future<bool> hasAccess(ProFeature feature) async => false;
}

final class _FailingCandidates implements MemoryCandidateRepository {
  @override
  Future<void> saveCaptureCandidate({
    required MemoryCandidate candidate,
    required Evidence evidence,
    required Attachment attachment,
    List<FieldProvenance> provenance = const [],
  }) => throw StateError('fixture transaction failure');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
