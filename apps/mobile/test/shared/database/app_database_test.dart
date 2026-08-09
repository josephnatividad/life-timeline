import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/database/app_database.dart' hide Tag;
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

  test('schema v1 creates the complete baseline table set', () async {
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();
    final names = rows.map((row) => row.read<String>('name')).toSet();

    expect(database.schemaVersion, 1);
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
      await migrateSchema(database.createMigrator(), from: 1, to: 1);

      expect(
        migrateSchema(database.createMigrator(), from: 1, to: 2),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('foreign keys are enabled', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });
}
