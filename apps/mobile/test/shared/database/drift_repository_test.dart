import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/database/app_database.dart';
import 'package:life_timeline/shared/database/repositories/drift_memory_candidate_repository.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

import 'test_record_factory.dart';

void main() {
  late AppDatabase database;
  late DriftTimelineRepository timeline;
  late DriftMemoryCandidateRepository candidates;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    timeline = DriftTimelineRepository(database);
    candidates = DriftMemoryCandidateRepository(database);
  });

  tearDown(() => database.close());

  test(
    'entity, event, evidence, attachment and relationship round-trip',
    () async {
      final entity = TestRecordFactory.entity();
      final event = TestRecordFactory.event();
      final evidence = TestRecordFactory.evidence();
      final attachment = TestRecordFactory.attachment();

      await timeline.saveEntity(entity);
      await timeline.saveEvent(event);
      await timeline.saveEvidence(evidence, attachments: [attachment]);
      await timeline.saveRelationship(TestRecordFactory.relationship());

      final storedEvent = await timeline.eventById('event-1');
      expect(storedEvent?.title, event.title);
      expect(storedEvent?.temporalValue.precision.name, 'approximate');
      expect(storedEvent?.temporalValue.start?.year, 2018);
      expect(storedEvent?.temporalValue.start?.month, isNull);
      expect((await timeline.entityById('entity-1'))?.name, entity.name);
      expect(
        (await timeline.evidenceById('evidence-1'))?.title,
        evidence.title,
      );
      expect(
        (await timeline.attachmentsForEvidence(
          'evidence-1',
        )).single.relativePath,
        attachment.relativePath,
      );

      final relationships = await timeline.relationshipsFor(
        TimelineRecordReference(type: TimelineRecordType.event, id: 'event-1'),
      );
      expect(relationships.single.source.id, 'entity-1');
      expect(relationships.single.target.id, 'event-1');
    },
  );

  test(
    'foreign-key integrity rejects missing relationship endpoints',
    () async {
      await timeline.saveEntity(TestRecordFactory.entity());

      expect(
        timeline.saveRelationship(
          TestRecordFactory.relationship(targetId: 'missing-event'),
        ),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'soft deletion hides a user record unless explicitly requested',
    () async {
      await timeline.saveEntity(TestRecordFactory.entity());
      final deletedAt = TestRecordFactory.createdAt.add(
        const Duration(hours: 1),
      );

      await timeline.softDeleteEntity('entity-1', deletedAt);

      expect(await timeline.entityById('entity-1'), isNull);
      final deleted = await timeline.entityById(
        'entity-1',
        includeDeleted: true,
      );
      expect(deleted?.metadata.lifecycle, RecordLifecycle.softDeleted);
      expect(deleted?.metadata.deletedAt, deletedAt);
    },
  );

  test('field provenance round-trips through its domain boundary', () async {
    await timeline.saveEvent(TestRecordFactory.event());
    await timeline.saveFieldProvenance(TestRecordFactory.provenance());

    final fields = await timeline.provenanceFor(
      ProvenanceTarget(type: ProvenanceTargetType.event, id: 'event-1'),
    );

    expect(fields.single.sourceId, 'user-entry-1');
    expect(fields.single.extractionMethod, ExtractionMethod.manual);
    expect(fields.single.userConfirmed, isTrue);
    expect(fields.single.privacyClassification, PrivacyClassification.personal);
  });

  test(
    'candidate confirmation atomically creates an event and provenance',
    () async {
      await timeline.saveEvidence(TestRecordFactory.evidence());
      await candidates.saveCandidate(TestRecordFactory.candidate());
      final confirmedAt = TestRecordFactory.createdAt.add(
        const Duration(days: 1),
      );

      await candidates.confirmCandidate(
        candidateId: 'candidate-1',
        confirmedEvent: TestRecordFactory.event(),
        confirmedAt: confirmedAt,
        provenance: [TestRecordFactory.provenance()],
      );

      final candidate = await candidates.candidateById('candidate-1');
      expect(candidate?.metadata.lifecycle, RecordLifecycle.confirmed);
      expect(candidate?.confirmedEventId, 'event-1');
      expect(await timeline.eventById('event-1'), isNotNull);
      expect(
        await timeline.provenanceFor(
          ProvenanceTarget(type: ProvenanceTargetType.event, id: 'event-1'),
        ),
        hasLength(1),
      );
      expect(await candidates.pendingCandidates(), isEmpty);
    },
  );

  test(
    'failed confirmation rolls back the event and candidate update',
    () async {
      await timeline.saveEvidence(TestRecordFactory.evidence());
      await candidates.saveCandidate(TestRecordFactory.candidate());
      final invalidProvenance = FieldProvenance(
        id: 'bad-provenance',
        target: ProvenanceTarget(
          type: ProvenanceTargetType.entity,
          id: 'missing-entity',
        ),
        fieldName: 'name',
        sourceId: 'source-1',
        sourceType: ProvenanceSourceType.system,
        extractionMethod: ExtractionMethod.deterministic,
        userConfirmed: false,
        privacyClassification: PrivacyClassification.personal,
        createdAt: TestRecordFactory.createdAt,
        updatedAt: TestRecordFactory.createdAt,
      );

      expect(
        candidates.confirmCandidate(
          candidateId: 'candidate-1',
          confirmedEvent: TestRecordFactory.event(),
          confirmedAt: TestRecordFactory.createdAt.add(const Duration(days: 1)),
          provenance: [invalidProvenance],
        ),
        throwsA(isA<Exception>()),
      );

      expect(await timeline.eventById('event-1'), isNull);
      expect(
        (await candidates.candidateById('candidate-1'))?.metadata.lifecycle,
        RecordLifecycle.candidate,
      );
    },
  );
}
