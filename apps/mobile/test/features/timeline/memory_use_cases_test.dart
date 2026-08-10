import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/timeline/application/memory_editor_draft.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Attachment, Event, Relationship;
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  late AppDatabase database;
  late DriftTimelineRepository repository;
  late SaveMemoryUseCase saveMemory;
  late SetMemoryArchiveStateUseCase archiveState;
  late DeleteMemoryUseCase deleteMemory;
  late _RecordingAttachmentCleanup attachmentCleanup;
  final now = DateTime.utc(2026, 8, 10, 9);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTimelineRepository(database);
    saveMemory = SaveMemoryUseCase(
      repository,
      _FixedIdGenerator(),
      now: () => now,
    );
    archiveState = SetMemoryArchiveStateUseCase(repository, now: () => now);
    attachmentCleanup = _RecordingAttachmentCleanup();
    deleteMemory = DeleteMemoryUseCase(
      repository,
      attachmentCleanup,
      now: () => now,
    );
  });

  tearDown(() => database.close());

  test('Add Memory validates and persists a structured aggregate', () async {
    final id = await saveMemory(_draft());

    final memory = await repository.memoryById(id);
    expect(memory?.event.title, 'Graduated from university');
    expect(memory?.event.temporalValue.precision, TemporalPrecision.year);
    expect(memory?.category?.name, 'Education');
    expect(memory?.relatedEntity?.name, 'Example University');
    expect(
      memory?.relatedEntityRelationship?.relationshipType,
      'related_entity',
    );

    final provenance = await repository.provenanceFor(
      ProvenanceTarget(type: ProvenanceTargetType.event, id: id),
    );
    expect(provenance, isNotEmpty);
    expect(provenance.every((field) => field.userConfirmed), isTrue);
    expect(
      provenance.every(
        (field) => field.extractionMethod == ExtractionMethod.manual,
      ),
      isTrue,
    );
  });

  test('Edit Memory reuses the same validation and event identity', () async {
    final id = await saveMemory(_draft());
    final original = (await repository.memoryById(id))!;

    await saveMemory(
      MemoryEditorDraft.fromMemory(original).copyWithForTest(
        title: 'Graduated with honors',
        description: 'A revised description',
      ),
    );

    final edited = await repository.memoryById(id);
    expect(edited?.event.metadata.id, id);
    expect(edited?.event.title, 'Graduated with honors');
    expect(edited?.event.description, 'A revised description');
    expect((await repository.watchMemories().first), hasLength(1));
  });

  test('Archive hides a memory and Restore returns it unchanged', () async {
    final id = await saveMemory(_draft());

    await archiveState.archive(id);
    expect(await repository.watchMemories().first, isEmpty);
    expect(
      (await repository.watchMemories(archived: true).first).single.event.title,
      'Graduated from university',
    );

    await archiveState.restore(id);
    expect(
      (await repository.watchMemories().first).single.event.title,
      'Graduated from university',
    );
    expect(await repository.watchMemories(archived: true).first, isEmpty);
  });

  test('editing an archived memory does not restore it implicitly', () async {
    final id = await saveMemory(_draft());
    await archiveState.archive(id);
    final archived =
        (await repository.watchMemories(archived: true).first).single;

    await saveMemory(
      MemoryEditorDraft.fromMemory(
        archived,
      ).copyWithForTest(title: 'Updated while archived'),
    );

    expect(await repository.watchMemories().first, isEmpty);
    expect(
      (await repository.watchMemories(archived: true).first).single.event.title,
      'Updated while archived',
    );
  });

  test('Trash hides a memory and restore returns it to Timeline', () async {
    final id = await saveMemory(_draft());

    await deleteMemory.moveToTrash(id);

    expect(await repository.watchMemories().first, isEmpty);
    expect(await repository.searchMemories('graduated'), isEmpty);
    expect(
      (await repository.watchTrashedMemories().first).single.event.metadata.id,
      id,
    );

    await deleteMemory.restoreFromTrash(id);

    expect(await repository.watchTrashedMemories().first, isEmpty);
    expect(
      (await repository.watchMemories().first).single.event.metadata.id,
      id,
    );
    expect(await repository.searchMemories('graduated'), hasLength(1));
  });

  test('permanent delete removes an orphaned managed attachment', () async {
    final id = await saveMemory(_draft());
    final evidence = Evidence(
      metadata: _metadata('evidence-owned'),
      evidenceType: EvidenceType.photo,
      title: 'Owned evidence',
    );
    await repository.saveEvidence(
      evidence,
      attachments: [
        Attachment(
          metadata: _metadata('attachment-owned'),
          evidenceId: evidence.metadata.id,
          storageState: AttachmentStorageState.local,
          importMode: AttachmentImportMode.optimizedCopy,
          mimeType: 'image/jpeg',
          byteSize: 8,
          relativePath: 'intelligence/owned.jpg',
          thumbnailRelativePath: 'thumbnails/owned.jpg',
        ),
      ],
    );
    await repository.saveRelationship(
      Relationship(
        metadata: _metadata('relationship-evidence'),
        source: TimelineRecordReference(type: TimelineRecordType.event, id: id),
        target: TimelineRecordReference(
          type: TimelineRecordType.evidence,
          id: evidence.metadata.id,
        ),
        relationshipType: 'supported_by',
      ),
    );
    await deleteMemory.moveToTrash(id);

    await deleteMemory.permanentlyDelete(id);

    expect(await repository.eventById(id, includeDeleted: true), isNull);
    expect(
      await repository.evidenceById(evidence.metadata.id, includeDeleted: true),
      isNull,
    );
    expect(
      attachmentCleanup.deleted,
      containsAll(['intelligence/owned.jpg', 'thumbnails/owned.jpg']),
    );
    expect(await repository.matchableEntities(), isNotEmpty);
  });

  test(
    'permanent delete preserves evidence shared by another memory',
    () async {
      final firstId = await saveMemory(_draft());
      final secondId = await saveMemory(
        _draft().copyWithForTest(title: 'A second memory'),
      );
      final evidence = Evidence(
        metadata: _metadata('evidence-shared'),
        evidenceType: EvidenceType.document,
        title: 'Shared evidence',
      );
      await repository.saveEvidence(
        evidence,
        attachments: [
          Attachment(
            metadata: _metadata('attachment-shared'),
            evidenceId: evidence.metadata.id,
            storageState: AttachmentStorageState.local,
            importMode: AttachmentImportMode.preserveOriginal,
            mimeType: 'application/pdf',
            byteSize: 12,
            relativePath: 'documents/shared.pdf',
          ),
        ],
      );
      for (final entry in [(firstId, 'first'), (secondId, 'second')]) {
        await repository.saveRelationship(
          Relationship(
            metadata: _metadata('relationship-${entry.$2}'),
            source: TimelineRecordReference(
              type: TimelineRecordType.event,
              id: entry.$1,
            ),
            target: TimelineRecordReference(
              type: TimelineRecordType.evidence,
              id: evidence.metadata.id,
            ),
            relationshipType: 'supported_by',
          ),
        );
      }
      await deleteMemory.moveToTrash(firstId);

      await deleteMemory.permanentlyDelete(firstId);

      expect(await repository.eventById(firstId, includeDeleted: true), isNull);
      expect(await repository.eventById(secondId), isNotNull);
      expect(await repository.evidenceById(evidence.metadata.id), isNotNull);
      expect(
        await repository.attachmentsForEvidence(evidence.metadata.id),
        hasLength(1),
      );
      expect(attachmentCleanup.deleted, isEmpty);
    },
  );

  test(
    'permanent delete preserves evidence cited by other provenance',
    () async {
      final firstId = await saveMemory(_draft());
      final secondId = await saveMemory(
        _draft().copyWithForTest(title: 'A provenance-linked memory'),
      );
      final evidence = Evidence(
        metadata: _metadata('evidence-provenance'),
        evidenceType: EvidenceType.document,
        title: 'Provenance source',
      );
      await repository.saveEvidence(evidence);
      await repository.saveRelationship(
        Relationship(
          metadata: _metadata('relationship-provenance'),
          source: TimelineRecordReference(
            type: TimelineRecordType.event,
            id: firstId,
          ),
          target: TimelineRecordReference(
            type: TimelineRecordType.evidence,
            id: evidence.metadata.id,
          ),
          relationshipType: 'supported_by',
        ),
      );
      await repository.saveMemory(
        (await repository.memoryById(secondId))!,
        provenance: [
          FieldProvenance(
            id: 'provenance-other-event',
            target: ProvenanceTarget(
              type: ProvenanceTargetType.event,
              id: secondId,
            ),
            fieldName: 'title',
            sourceId: evidence.metadata.id,
            sourceType: ProvenanceSourceType.attachment,
            extractionMethod: ExtractionMethod.metadata,
            confidence: 1,
            userConfirmed: true,
            privacyClassification: PrivacyClassification.personal,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      await deleteMemory.moveToTrash(firstId);

      await deleteMemory.permanentlyDelete(firstId);

      expect(await repository.evidenceById(evidence.metadata.id), isNotNull);
    },
  );

  test('cleanup failure does not misreport the committed deletion', () async {
    final id = await saveMemory(_draft());
    await deleteMemory.moveToTrash(id);
    attachmentCleanup.fail = true;

    final cleanupComplete = await deleteMemory.permanentlyDelete(id);

    expect(cleanupComplete, isFalse);
    expect(await repository.eventById(id, includeDeleted: true), isNull);
  });

  test('permanent delete refuses a memory outside Trash', () async {
    final id = await saveMemory(_draft());

    expect(deleteMemory.permanentlyDelete(id), throwsA(isA<StateError>()));
    expect(await repository.eventById(id), isNotNull);
  });

  test(
    'Add Memory rejects missing required fields before persistence',
    () async {
      expect(
        saveMemory(
          MemoryEditorDraft(
            title: ' ',
            eventType: 'Milestone',
            categoryName: 'Personal',
            temporalValue: TemporalValue.unknown(),
            privacyClassification: PrivacyClassification.personal,
          ),
        ),
        throwsA(isA<MemoryValidationException>()),
      );
      expect(await repository.watchMemories().first, isEmpty);
    },
  );
}

RecordMetadata _metadata(String id) => RecordMetadata(
  id: id,
  privacyClassification: PrivacyClassification.personal,
  lifecycle: RecordLifecycle.confirmed,
  createdAt: DateTime.utc(2026, 8, 10, 8),
  updatedAt: DateTime.utc(2026, 8, 10, 8),
);

final class _RecordingAttachmentCleanup implements ManagedAttachmentCleanup {
  final deleted = <String>[];
  var fail = false;

  @override
  Future<void> deleteManagedFiles(Iterable<String> relativePaths) async {
    if (fail) throw const FileSystemException('Simulated cleanup failure');
    deleted.addAll(relativePaths);
  }
}

MemoryEditorDraft _draft() => MemoryEditorDraft(
  title: 'Graduated from university',
  eventType: 'Graduated',
  categoryName: 'Education',
  temporalValue: TemporalValue.year(2020),
  privacyClassification: PrivacyClassification.personal,
  description: 'Completed a degree.',
  relatedEntityName: 'Example University',
);

final class _FixedIdGenerator implements RecordIdGenerator {
  var _next = 0;

  @override
  String next(String prefix) => '$prefix-${_next++}';
}

extension on MemoryEditorDraft {
  MemoryEditorDraft copyWithForTest({String? title, String? description}) =>
      MemoryEditorDraft(
        eventId: eventId,
        createdAt: createdAt,
        categoryId: categoryId,
        relatedEntityId: relatedEntityId,
        relationshipId: relationshipId,
        title: title ?? this.title,
        eventType: eventType,
        lifecycle: lifecycle,
        categoryName: categoryName,
        temporalValue: temporalValue,
        privacyClassification: privacyClassification,
        description: description ?? this.description,
        relatedEntityName: relatedEntityName,
      );
}
