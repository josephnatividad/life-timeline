import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Attachment, Tag;
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

import 'test_record_factory.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('schema v4 preserves the complete relational baseline', () async {
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();
    final names = rows.map((row) => row.read<String>('name')).toSet();

    expect(database.schemaVersion, 4);
    expect(
      names,
      containsAll(<String>{
        'entities',
        'events',
        'evidence',
        'relationships',
        'attachments',
        'field_provenance',
        'memory_candidates',
        'candidate_extracted_fields',
        'candidate_entity_proposals',
        'feature_usage',
        'tags',
        'categories',
        'entity_tags',
        'event_tags',
        'evidence_tags',
        'entity_categories',
        'event_categories',
        'evidence_categories',
      }),
    );
  });

  test('important lookup and integrity indexes exist', () async {
    final rows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final names = rows.map((row) => row.read<String>('name')).toSet();

    expect(
      names,
      containsAll(<String>{
        'entities_lifecycle_idx',
        'entities_normalized_name_idx',
        'events_temporal_start_idx',
        'attachments_evidence_idx',
        'relationships_source_entity_idx',
        'relationships_target_event_idx',
        'provenance_event_idx',
        'memory_candidates_lifecycle_idx',
        'candidate_fields_candidate_idx',
        'candidate_entities_candidate_idx',
        'entity_tags_tag_idx',
      }),
    );
  });

  test(
    'attachment table stores metadata and paths but no binary payload',
    () async {
      final columns = await database
          .customSelect('PRAGMA table_info(attachments)')
          .get();
      final names = columns.map((row) => row.read<String>('name')).toSet();
      final types = columns.map((row) => row.read<String>('type')).toSet();

      expect(names, contains('relative_path'));
      expect(names, contains('thumbnail_relative_path'));
      expect(names, isNot(contains('data')));
      expect(names, isNot(contains('content')));
      expect(types, isNot(contains('BLOB')));
    },
  );

  test('normalized tag names are unique', () async {
    final first = Tag(
      metadata: TestRecordFactory.metadata('tag-1'),
      name: 'Travel',
    );
    final second = Tag(
      metadata: TestRecordFactory.metadata('tag-2'),
      name: ' travel ',
    );
    await database
        .into(database.tags)
        .insert(TimelineMapper.tagToCompanion(first));

    expect(
      database
          .into(database.tags)
          .insert(TimelineMapper.tagToCompanion(second)),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'migration baseline is explicit and rejects unimplemented upgrades',
    () async {
      await migrateSchema(database, database.createMigrator(), from: 4, to: 4);

      expect(
        migrateSchema(database, database.createMigrator(), from: 4, to: 5),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('foreign keys are enabled', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('schema v4 retains the local FTS5 event index', () async {
    final row = await database
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE name = 'event_search'",
        )
        .getSingle();

    expect(row.read<String>('sql'), contains('fts5'));
  });

  test('v1 to v2 migration adds FTS without resetting relational data', () async {
    await database.customStatement('DROP TABLE event_search');
    await database
        .into(database.entities)
        .insert(TimelineMapper.entityToCompanion(TestRecordFactory.entity()));
    await database
        .into(database.events)
        .insert(TimelineMapper.eventToCompanion(TestRecordFactory.event()));

    await migrateSchema(database, database.createMigrator(), from: 1, to: 2);

    expect(await database.select(database.entities).get(), hasLength(1));
    final searchTable = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE name = 'event_search'",
        )
        .getSingle();
    expect(searchTable.read<String>('name'), 'event_search');
    final indexed = await database
        .customSelect(
          "SELECT event_id FROM event_search WHERE event_search MATCH 'started'",
        )
        .getSingle();
    expect(indexed.read<String>('event_id'), 'event-1');
  });

  test('v2 to v3 migration adds candidate intelligence without reset', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('CREATE TABLE entities (id TEXT NOT NULL PRIMARY KEY)');
          raw.execute('CREATE TABLE events (id TEXT NOT NULL PRIMARY KEY)');
          raw.execute(
            'CREATE TABLE attachments (storage_state TEXT, relative_path TEXT)',
          );
          raw.execute(
            'CREATE TABLE memory_candidates (id TEXT NOT NULL PRIMARY KEY)',
          );
          raw.execute("INSERT INTO memory_candidates(id) VALUES ('kept')");
          raw.execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(migrated.close);

    final columns = await migrated
        .customSelect('PRAGMA table_info(memory_candidates)')
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();
    final kept = await migrated
        .customSelect('SELECT id FROM memory_candidates')
        .getSingle();
    final newTables = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('candidate_extracted_fields', 'candidate_entity_proposals', 'feature_usage')",
        )
        .get();

    expect(kept.read<String>('id'), 'kept');
    expect(
      names,
      containsAll([
        'document_type',
        'review_status',
        'overall_confidence',
        'possible_duplicate_event_id',
      ]),
    );
    expect(newTables, hasLength(3));
  });

  test('v3 to v4 migration normalizes intelligence attachment paths', () async {
    await database
        .into(database.evidenceRecords)
        .insert(
          TimelineMapper.evidenceToCompanion(
            TestRecordFactory.evidence(id: 'evidence-legacy'),
          ),
        );
    for (final attachment in [
      Attachment(
        metadata: TestRecordFactory.metadata('legacy'),
        evidenceId: 'evidence-legacy',
        storageState: AttachmentStorageState.local,
        importMode: AttachmentImportMode.optimizedCopy,
        mimeType: 'image/jpeg',
        byteSize: 1,
        relativePath: 'attachments/intelligence/legacy.jpg',
      ),
      Attachment(
        metadata: TestRecordFactory.metadata('already-canonical'),
        evidenceId: 'evidence-legacy',
        storageState: AttachmentStorageState.local,
        importMode: AttachmentImportMode.optimizedCopy,
        mimeType: 'image/jpeg',
        byteSize: 1,
        relativePath: 'documents/already-canonical.jpg',
      ),
    ]) {
      await database
          .into(database.attachments)
          .insert(TimelineMapper.attachmentToCompanion(attachment));
    }

    await migrateSchema(database, database.createMigrator(), from: 3, to: 4);

    final paths = await database
        .customSelect('SELECT id, relative_path FROM attachments ORDER BY id')
        .get();
    expect(
      paths[0].read<String>('relative_path'),
      'documents/already-canonical.jpg',
    );
    expect(paths[1].read<String>('relative_path'), 'intelligence/legacy.jpg');
  });
}
