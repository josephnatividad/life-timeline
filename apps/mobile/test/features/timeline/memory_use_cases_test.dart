import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/timeline/application/memory_editor_draft.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/shared/database/app_database.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

void main() {
  late AppDatabase database;
  late DriftTimelineRepository repository;
  late SaveMemoryUseCase saveMemory;
  late SetMemoryArchiveStateUseCase archiveState;
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
