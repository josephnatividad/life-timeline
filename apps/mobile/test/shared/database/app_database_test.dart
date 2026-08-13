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

  test('schema v8 preserves the complete relational baseline', () async {
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();
    final names = rows.map((row) => row.read<String>('name')).toSet();

    expect(database.schemaVersion, 8);
    expect(
      names,
      containsAll(<String>{
        'entities',
        'events',
        'evidence',
        'relationships',
        'attachments',
        'attachment_links',
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
        'insight_dismissals',
        'archive_references',
        'reminders',
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
        'attachment_links_event_idx',
        'attachment_links_evidence_idx',
        'attachment_links_attachment_idx',
        'attachment_links_single_hero_idx',
        'relationships_source_entity_idx',
        'relationships_target_event_idx',
        'provenance_event_idx',
        'memory_candidates_lifecycle_idx',
        'candidate_fields_candidate_idx',
        'candidate_entities_candidate_idx',
        'entity_tags_tag_idx',
        'entities_type_idx',
        'events_type_idx',
        'relationships_type_idx',
        'insight_dismissals_dismissed_at_idx',
        'archive_references_attachment_idx',
        'archive_references_archived_at_idx',
        'reminders_status_schedule_idx',
        'reminders_notification_id_idx',
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
      expect(names, contains('preserved_original_relative_path'));
      expect(names, contains('preserved_original_byte_size'));
      expect(names, contains('preserved_original_checksum'));
      expect(names, isNot(contains('evidence_id')));
      expect(names, contains('pixel_width'));
      expect(names, contains('pixel_height'));
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
      await migrateSchema(database, database.createMigrator(), from: 8, to: 8);

      expect(
        migrateSchema(database, database.createMigrator(), from: 8, to: 9),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('v7 to v8 adds reminders without resetting timeline data', () async {
    await database.customStatement('DROP TABLE reminders');
    await database
        .into(database.events)
        .insert(TimelineMapper.eventToCompanion(TestRecordFactory.event()));

    await migrateSchema(database, database.createMigrator(), from: 7, to: 8);

    expect(await database.select(database.events).get(), hasLength(1));
    final table = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'reminders'",
        )
        .getSingleOrNull();
    expect(table?.read<String>('name'), 'reminders');
  });

  test('foreign keys are enabled', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('schema v8 retains the local FTS5 event and caption index', () async {
    final row = await database
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE name = 'event_search'",
        )
        .getSingle();

    expect(row.read<String>('sql'), contains('fts5'));
    expect(row.read<String>('sql'), contains('media_captions'));
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

  test('sequential v1 to v8 migration preserves a realistic legacy graph', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          _createSequentialV1Fixture(raw.execute);
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(migrated.close);

    final events = await migrated
        .customSelect('SELECT id, lifecycle, temporal_precision FROM events')
        .get();
    final relationship = await migrated
        .customSelect(
          "SELECT source_event_id, target_evidence_id FROM relationships WHERE id = 'relationship-proof'",
        )
        .getSingle();
    final evidence = await migrated
        .customSelect("SELECT title FROM evidence WHERE id = 'evidence-proof'")
        .getSingle();
    final attachment = await migrated
        .customSelect(
          "SELECT id, relative_path FROM attachments WHERE id = 'attachment-proof'",
        )
        .getSingle();
    final link = await migrated
        .customSelect(
          "SELECT evidence_id, role FROM attachment_links WHERE attachment_id = 'attachment-proof'",
        )
        .getSingle();
    final candidate = await migrated
        .customSelect(
          "SELECT title, document_type, review_status FROM memory_candidates WHERE id = 'candidate-proof'",
        )
        .getSingle();
    final reminderTable = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'reminders'",
        )
        .getSingle();
    final search = await migrated
        .customSelect(
          "SELECT event_id FROM event_search WHERE event_search MATCH 'legacy' ORDER BY event_id",
        )
        .get();
    final foreignKeyProblems = await migrated
        .customSelect('PRAGMA foreign_key_check')
        .get();

    expect(events, hasLength(3));
    expect({
      for (final row in events) row.read<String>('lifecycle'),
    }, containsAll({'confirmed', 'archived', 'soft_deleted'}));
    expect({
      for (final row in events) row.read<String>('temporal_precision'),
    }, containsAll({'approximate', 'year', 'range'}));
    expect(relationship.read<String>('source_event_id'), 'event-active');
    expect(relationship.read<String>('target_evidence_id'), 'evidence-proof');
    expect(evidence.read<String>('title'), 'Legacy receipt');
    expect(attachment.read<String>('relative_path'), 'photos/proof.jpg');
    expect(link.read<String>('evidence_id'), 'evidence-proof');
    expect(link.read<String>('role'), 'evidence');
    expect(candidate.read<String>('title'), 'Legacy candidate');
    expect(candidate.read<String>('document_type'), 'unknown');
    expect(candidate.read<String>('review_status'), 'pending');
    expect(reminderTable.read<String>('name'), 'reminders');
    expect(
      search.map((row) => row.read<String>('event_id')),
      containsAll({'event-active', 'event-archived'}),
    );
    expect(foreignKeyProblems, isEmpty);
  });

  test('v2 to v3 migration adds candidate intelligence without reset', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          _createLegacyRelationalFixture(raw.execute);
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
        storageState: AttachmentStorageState.local,
        importMode: AttachmentImportMode.optimizedCopy,
        mimeType: 'image/jpeg',
        byteSize: 1,
        relativePath: 'attachments/intelligence/legacy.jpg',
      ),
      Attachment(
        metadata: TestRecordFactory.metadata('already-canonical'),
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

  test('v4 to v5 migration adds insight dismissal and query indexes', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          _createLegacyRelationalFixture(raw.execute);
          raw.execute(
            "INSERT INTO entities(id, entity_type) VALUES ('kept', 'phone')",
          );
          raw.execute('PRAGMA user_version = 4');
        },
      ),
    );
    addTearDown(migrated.close);

    final kept = await migrated
        .customSelect('SELECT id FROM entities')
        .getSingle();
    final table = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'insight_dismissals'",
        )
        .getSingle();
    final indexes = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name IN ('entities_type_idx', 'events_type_idx', 'relationships_type_idx')",
        )
        .get();

    expect(kept.read<String>('id'), 'kept');
    expect(table.read<String>('name'), 'insight_dismissals');
    expect(indexes, hasLength(3));
  });

  test('v5 to v7 preserves attachments and creates evidence links', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE events (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL DEFAULT '',
              description TEXT,
              event_type TEXT,
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE entities (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL DEFAULT '',
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE relationships (
              id TEXT NOT NULL PRIMARY KEY,
              source_event_id TEXT,
              target_event_id TEXT,
              source_entity_id TEXT,
              target_entity_id TEXT,
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE categories (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL DEFAULT '',
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE event_categories (
              event_id TEXT NOT NULL,
              category_id TEXT NOT NULL
            )
          ''');
          raw.execute('''
            CREATE TABLE evidence (
              id TEXT NOT NULL PRIMARY KEY,
              evidence_type TEXT NOT NULL
            )
          ''');
          raw.execute(
            "INSERT INTO evidence(id, evidence_type) VALUES ('evidence-1', 'photo')",
          );
          raw.execute('''
            CREATE TABLE field_provenance (
              id TEXT NOT NULL PRIMARY KEY,
              attachment_id TEXT
            )
          ''');
          raw.execute('''
            CREATE TABLE attachments (
              id TEXT NOT NULL PRIMARY KEY,
              evidence_id TEXT NOT NULL,
              privacy_classification TEXT NOT NULL,
              lifecycle TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER,
              storage_state TEXT NOT NULL,
              import_mode TEXT NOT NULL,
              mime_type TEXT NOT NULL,
              byte_size INTEGER NOT NULL,
              checksum TEXT,
              display_name TEXT,
              relative_path TEXT,
              thumbnail_relative_path TEXT
            )
          ''');
          raw.execute('''
            INSERT INTO attachments (
              id, evidence_id, privacy_classification, lifecycle,
              created_at, updated_at, storage_state, import_mode,
              mime_type, byte_size, relative_path
            ) VALUES (
              'kept', 'evidence-1', 'personal', 'confirmed',
              1, 1, 'local', 'preserve_original',
              'image/jpeg', 12, 'photos/kept.jpg'
            )
          ''');
          raw.execute('PRAGMA user_version = 5');
        },
      ),
    );
    addTearDown(migrated.close);

    final kept = await migrated
        .customSelect('SELECT id, relative_path FROM attachments')
        .getSingle();
    final columns = await migrated
        .customSelect('PRAGMA table_info(attachments)')
        .get();
    final archiveTable = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'archive_references'",
        )
        .getSingle();
    final link = await migrated
        .customSelect(
          'SELECT attachment_id, evidence_id, role FROM attachment_links',
        )
        .getSingle();
    final evidenceType = await migrated
        .customSelect(
          "SELECT evidence_type FROM evidence WHERE id = 'evidence-1'",
        )
        .getSingle();

    expect(kept.read<String>('id'), 'kept');
    expect(kept.read<String>('relative_path'), 'photos/kept.jpg');
    expect(
      columns.map((row) => row.read<String>('name')),
      containsAll(<String>[
        'preserved_original_relative_path',
        'pixel_width',
        'pixel_height',
        'preserved_original_byte_size',
        'preserved_original_checksum',
      ]),
    );
    expect(archiveTable.read<String>('name'), 'archive_references');
    expect(link.read<String>('attachment_id'), 'kept');
    expect(link.read<String>('evidence_id'), 'evidence-1');
    expect(link.read<String>('role'), 'evidence');
    expect(evidenceType.read<String>('evidence_type'), 'other');
  });

  test('v6 to v7 retains archive and attachment provenance references', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE events (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL DEFAULT '',
              description TEXT,
              event_type TEXT,
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE entities (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL DEFAULT '',
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE relationships (
              id TEXT NOT NULL PRIMARY KEY,
              source_event_id TEXT,
              target_event_id TEXT,
              source_entity_id TEXT,
              target_entity_id TEXT,
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE categories (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL DEFAULT '',
              lifecycle TEXT NOT NULL DEFAULT 'confirmed'
            )
          ''');
          raw.execute('''
            CREATE TABLE event_categories (
              event_id TEXT NOT NULL,
              category_id TEXT NOT NULL
            )
          ''');
          raw.execute('''
            CREATE TABLE evidence (
              id TEXT NOT NULL PRIMARY KEY,
              evidence_type TEXT NOT NULL
            )
          ''');
          raw.execute(
            "INSERT INTO evidence(id, evidence_type) VALUES ('proof', 'document')",
          );
          raw.execute('''
            CREATE TABLE attachments (
              id TEXT NOT NULL PRIMARY KEY,
              evidence_id TEXT NOT NULL,
              privacy_classification TEXT NOT NULL,
              lifecycle TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER,
              display_name TEXT,
              relative_path TEXT,
              thumbnail_relative_path TEXT,
              preserved_original_relative_path TEXT,
              mime_type TEXT NOT NULL,
              byte_size INTEGER NOT NULL,
              pixel_width INTEGER,
              pixel_height INTEGER,
              checksum TEXT,
              storage_state TEXT NOT NULL,
              import_mode TEXT NOT NULL
            )
          ''');
          raw.execute('''
            INSERT INTO attachments (
              id, evidence_id, privacy_classification, lifecycle,
              created_at, updated_at, mime_type, byte_size,
              storage_state, import_mode, relative_path
            ) VALUES (
              'asset', 'proof', 'sensitive', 'confirmed', 1, 1,
              'application/pdf', 12, 'local', 'preserve_original',
              'documents/proof.pdf'
            )
          ''');
          raw.execute('''
            CREATE TABLE archive_references (
              id TEXT NOT NULL PRIMARY KEY,
              attachment_id TEXT NOT NULL,
              destination_type TEXT NOT NULL,
              logical_key TEXT NOT NULL,
              original_byte_size INTEGER NOT NULL,
              original_sha256 TEXT NOT NULL,
              archive_byte_size INTEGER NOT NULL,
              archive_sha256 TEXT NOT NULL,
              encryption_algorithm TEXT NOT NULL,
              format_version INTEGER NOT NULL,
              archived_at INTEGER NOT NULL,
              verified_at INTEGER NOT NULL
            )
          ''');
          raw.execute('''
            INSERT INTO archive_references VALUES (
              'archive', 'asset', 'userSelectedFile', 'proof.archive',
              12, 'source-hash', 20, 'archive-hash', 'aes', 1, 1, 1
            )
          ''');
          raw.execute('''
            CREATE TABLE field_provenance (
              id TEXT NOT NULL PRIMARY KEY,
              attachment_id TEXT
            )
          ''');
          raw.execute(
            "INSERT INTO field_provenance VALUES ('provenance', 'asset')",
          );
          raw.execute('PRAGMA user_version = 6');
        },
      ),
    );
    addTearDown(migrated.close);

    final archive = await migrated
        .customSelect(
          'SELECT attachment_id, source_kind FROM archive_references',
        )
        .getSingle();
    final provenance = await migrated
        .customSelect('SELECT attachment_id FROM field_provenance')
        .getSingle();
    final link = await migrated
        .customSelect('SELECT evidence_id, role FROM attachment_links')
        .getSingle();

    expect(archive.read<String>('attachment_id'), 'asset');
    expect(archive.read<String>('source_kind'), 'main');
    expect(provenance.read<String>('attachment_id'), 'asset');
    expect(link.read<String>('evidence_id'), 'proof');
    expect(link.read<String>('role'), 'evidence');
  });
}

void _createLegacyRelationalFixture(void Function(String sql) execute) {
  execute('''
    CREATE TABLE entities (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL DEFAULT '',
      entity_type TEXT,
      lifecycle TEXT NOT NULL DEFAULT 'confirmed'
    )
  ''');
  execute('''
    CREATE TABLE events (
      id TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL DEFAULT '',
      description TEXT,
      event_type TEXT,
      lifecycle TEXT NOT NULL DEFAULT 'confirmed'
    )
  ''');
  execute('''
    CREATE TABLE relationships (
      id TEXT NOT NULL PRIMARY KEY,
      source_event_id TEXT,
      target_event_id TEXT,
      source_entity_id TEXT,
      target_entity_id TEXT,
      relationship_type TEXT,
      lifecycle TEXT NOT NULL DEFAULT 'confirmed'
    )
  ''');
  execute('''
    CREATE TABLE categories (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL DEFAULT '',
      lifecycle TEXT NOT NULL DEFAULT 'confirmed'
    )
  ''');
  execute('''
    CREATE TABLE event_categories (
      event_id TEXT NOT NULL,
      category_id TEXT NOT NULL
    )
  ''');
  execute('''
    CREATE TABLE evidence (
      id TEXT NOT NULL PRIMARY KEY,
      evidence_type TEXT NOT NULL
    )
  ''');
  execute('''
    CREATE TABLE field_provenance (
      id TEXT NOT NULL PRIMARY KEY,
      attachment_id TEXT
    )
  ''');
  execute('''
    CREATE TABLE attachments (
      id TEXT NOT NULL PRIMARY KEY,
      evidence_id TEXT NOT NULL,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      display_name TEXT,
      relative_path TEXT,
      thumbnail_relative_path TEXT,
      mime_type TEXT NOT NULL,
      byte_size INTEGER NOT NULL,
      checksum TEXT,
      storage_state TEXT NOT NULL,
      import_mode TEXT NOT NULL
    )
  ''');
}

void _createSequentialV1Fixture(void Function(String sql) execute) {
  execute('''
    CREATE TABLE entities (
      id TEXT NOT NULL PRIMARY KEY,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      name TEXT NOT NULL,
      normalized_name TEXT NOT NULL,
      entity_type TEXT NOT NULL,
      notes TEXT
    )
  ''');
  execute("""
    INSERT INTO entities VALUES (
      'entity-place', 'personal', 'confirmed', 1, 1, NULL,
      'Legacy Place', 'legacy place', 'place', NULL
    )
  """);
  execute('''
    CREATE TABLE events (
      id TEXT NOT NULL PRIMARY KEY,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      title TEXT NOT NULL,
      normalized_title TEXT NOT NULL,
      description TEXT,
      event_type TEXT,
      temporal_precision TEXT NOT NULL,
      start_year INTEGER,
      start_month INTEGER,
      start_day INTEGER,
      end_year INTEGER,
      end_month INTEGER,
      end_day INTEGER,
      qualifier TEXT
    )
  ''');
  execute("""
    INSERT INTO events VALUES
      ('event-active', 'personal', 'confirmed', 1, 1, NULL,
       'Legacy active memory', 'legacy active memory', NULL, 'purchase',
       'approximate', 2018, NULL, NULL, NULL, NULL, NULL, 'around'),
      ('event-archived', 'sensitive', 'archived', 1, 2, NULL,
       'Legacy archived memory', 'legacy archived memory', NULL, 'travel',
       'year', 2019, NULL, NULL, NULL, NULL, NULL, NULL),
      ('event-trash', 'never_share', 'soft_deleted', 1, 3, 3,
       'Legacy trashed memory', 'legacy trashed memory', NULL, 'private',
       'range', 2020, 1, NULL, 2020, 3, NULL, NULL)
  """);
  execute('''
    CREATE TABLE evidence (
      id TEXT NOT NULL PRIMARY KEY,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      title TEXT NOT NULL,
      normalized_title TEXT NOT NULL,
      evidence_type TEXT NOT NULL,
      summary TEXT
    )
  ''');
  execute("""
    INSERT INTO evidence VALUES (
      'evidence-proof', 'sensitive', 'confirmed', 1, 1, NULL,
      'Legacy receipt', 'legacy receipt', 'photo', NULL
    )
  """);
  execute('''
    CREATE TABLE relationships (
      id TEXT NOT NULL PRIMARY KEY,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      source_entity_id TEXT,
      source_event_id TEXT,
      source_evidence_id TEXT,
      target_entity_id TEXT,
      target_event_id TEXT,
      target_evidence_id TEXT,
      relationship_type TEXT NOT NULL,
      notes TEXT
    )
  ''');
  execute("""
    INSERT INTO relationships VALUES
      ('relationship-place', 'personal', 'confirmed', 1, 1, NULL,
       NULL, 'event-active', NULL, 'entity-place', NULL, NULL, 'involves', NULL),
      ('relationship-proof', 'sensitive', 'confirmed', 1, 1, NULL,
       NULL, 'event-active', NULL, NULL, NULL, 'evidence-proof', 'supported_by', NULL)
  """);
  execute('''
    CREATE TABLE categories (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      lifecycle TEXT NOT NULL
    )
  ''');
  execute(
    "INSERT INTO categories VALUES ('category-legacy', 'Legacy', 'confirmed')",
  );
  execute('''
    CREATE TABLE event_categories (
      event_id TEXT NOT NULL,
      category_id TEXT NOT NULL
    )
  ''');
  execute(
    "INSERT INTO event_categories VALUES ('event-active', 'category-legacy')",
  );
  execute('''
    CREATE TABLE memory_candidates (
      id TEXT NOT NULL PRIMARY KEY,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      temporal_precision TEXT NOT NULL,
      start_year INTEGER,
      start_month INTEGER,
      start_day INTEGER,
      end_year INTEGER,
      end_month INTEGER,
      end_day INTEGER,
      qualifier TEXT,
      title TEXT NOT NULL,
      description TEXT,
      source_evidence_id TEXT,
      confirmed_event_id TEXT
    )
  ''');
  execute("""
    INSERT INTO memory_candidates VALUES (
      'candidate-proof', 'sensitive', 'candidate', 1, 1, NULL,
      'unknown', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
      'Legacy candidate', NULL, 'evidence-proof', NULL
    )
  """);
  execute('''
    CREATE TABLE attachments (
      id TEXT NOT NULL PRIMARY KEY,
      evidence_id TEXT NOT NULL,
      privacy_classification TEXT NOT NULL,
      lifecycle TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      display_name TEXT,
      relative_path TEXT,
      thumbnail_relative_path TEXT,
      mime_type TEXT NOT NULL,
      byte_size INTEGER NOT NULL,
      checksum TEXT,
      storage_state TEXT NOT NULL,
      import_mode TEXT NOT NULL
    )
  ''');
  execute("""
    INSERT INTO attachments VALUES (
      'attachment-proof', 'evidence-proof', 'sensitive', 'confirmed', 1, 1, NULL,
      'proof.jpg', 'photos/proof.jpg', 'thumbnails/proof.jpg',
      'image/jpeg', 42, 'proof-checksum', 'local', 'preserve_original'
    )
  """);
  execute('''
    CREATE TABLE field_provenance (
      id TEXT NOT NULL PRIMARY KEY,
      attachment_id TEXT
    )
  ''');
  execute(
    "INSERT INTO field_provenance VALUES ('provenance-proof', 'attachment-proof')",
  );
}
