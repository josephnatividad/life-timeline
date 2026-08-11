import 'package:drift/drift.dart';

/// Applies every additive migration in order.
///
/// Schema v1 is created by `Migrator.createAll`. Future versions must add an
/// explicit case here and accompanying migration tests. There is intentionally
/// no destructive fallback or reset-on-mismatch behavior.
Future<void> migrateSchema(
  GeneratedDatabase database,
  Migrator migrator, {
  required int from,
  required int to,
}) async {
  for (var version = from + 1; version <= to; version++) {
    switch (version) {
      case 2:
        await createEventSearchSchema(database);
        break;
      case 3:
        await database.customStatement(
          "ALTER TABLE memory_candidates ADD COLUMN document_type TEXT NOT NULL DEFAULT 'unknown'",
        );
        await database.customStatement(
          "ALTER TABLE memory_candidates ADD COLUMN review_status TEXT NOT NULL DEFAULT 'pending'",
        );
        await database.customStatement(
          'ALTER TABLE memory_candidates ADD COLUMN overall_confidence REAL NULL CHECK (overall_confidence IS NULL OR overall_confidence BETWEEN 0 AND 1)',
        );
        await database.customStatement(
          'ALTER TABLE memory_candidates ADD COLUMN possible_duplicate_event_id TEXT NULL REFERENCES events(id) ON DELETE SET NULL',
        );
        await database.customStatement('''
          CREATE TABLE candidate_extracted_fields (
            id TEXT NOT NULL PRIMARY KEY,
            candidate_id TEXT NOT NULL REFERENCES memory_candidates(id) ON DELETE CASCADE,
            key TEXT NOT NULL,
            value TEXT NOT NULL,
            value_type TEXT NOT NULL,
            confidence REAL NOT NULL CHECK (confidence BETWEEN 0 AND 1),
            privacy_classification TEXT NOT NULL,
            extraction_method TEXT NOT NULL,
            source_excerpt TEXT NULL,
            review_recommended INTEGER NOT NULL DEFAULT 0 CHECK (review_recommended IN (0, 1))
          )
        ''');
        await database.customStatement(
          'CREATE INDEX candidate_fields_candidate_idx ON candidate_extracted_fields(candidate_id)',
        );
        await database.customStatement(
          'CREATE INDEX candidate_fields_key_idx ON candidate_extracted_fields(key)',
        );
        await database.customStatement('''
          CREATE TABLE candidate_entity_proposals (
            id TEXT NOT NULL PRIMARY KEY,
            candidate_id TEXT NOT NULL REFERENCES memory_candidates(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            confidence REAL NOT NULL CHECK (confidence BETWEEN 0 AND 1),
            brand TEXT NULL,
            model TEXT NULL,
            serial_number TEXT NULL,
            suggested_entity_id TEXT NULL REFERENCES entities(id) ON DELETE SET NULL,
            match_score REAL NULL CHECK (match_score IS NULL OR match_score BETWEEN 0 AND 1),
            match_reasons TEXT NOT NULL DEFAULT ''
          )
        ''');
        await database.customStatement(
          'CREATE INDEX candidate_entities_candidate_idx ON candidate_entity_proposals(candidate_id)',
        );
        await database.customStatement(
          'CREATE INDEX candidate_entities_suggested_idx ON candidate_entity_proposals(suggested_entity_id)',
        );
        await database.customStatement(
          'CREATE INDEX candidate_entities_serial_idx ON candidate_entity_proposals(serial_number)',
        );
        await database.customStatement('''
          CREATE TABLE feature_usage (
            feature TEXT NOT NULL PRIMARY KEY,
            usage_count INTEGER NOT NULL DEFAULT 0 CHECK (usage_count >= 0),
            updated_at INTEGER NOT NULL
          )
        ''');
        break;
      case 4:
        // Schema v3 intelligence captures wrote files beneath the canonical
        // attachment root but accidentally persisted that root segment again.
        // Normalize only those known legacy paths; attachment bytes stay put.
        await database.customStatement('''
          UPDATE attachments
          SET relative_path = substr(relative_path, 13)
          WHERE storage_state = 'local'
            AND relative_path LIKE 'attachments/intelligence/%'
        ''');
        break;
      case 5:
        await database.customStatement('''
          CREATE TABLE insight_dismissals (
            insight_type TEXT NOT NULL,
            subject_key TEXT NOT NULL DEFAULT '',
            data_fingerprint TEXT NOT NULL,
            dismissed_at INTEGER NOT NULL,
            PRIMARY KEY (insight_type, subject_key, data_fingerprint)
          )
        ''');
        await database.customStatement(
          'CREATE INDEX insight_dismissals_dismissed_at_idx ON insight_dismissals(dismissed_at)',
        );
        await database.customStatement(
          'CREATE INDEX entities_type_idx ON entities(entity_type)',
        );
        await database.customStatement(
          'CREATE INDEX events_type_idx ON events(event_type)',
        );
        await database.customStatement(
          'CREATE INDEX relationships_type_idx ON relationships(relationship_type)',
        );
        break;
      default:
        throw StateError('Missing explicit migration to schema v$version.');
    }
  }
}

Future<void> createEventSearchSchema(GeneratedDatabase database) async {
  await database.customStatement('''
    CREATE VIRTUAL TABLE IF NOT EXISTS event_search USING fts5(
      event_id UNINDEXED,
      title,
      description,
      event_type,
      entity_names,
      category_names,
      tokenize = 'unicode61 remove_diacritics 2'
    )
  ''');
  await rebuildEventSearchIndex(database);
}

Future<void> rebuildEventSearchIndex(GeneratedDatabase database) async {
  await database.customStatement('DELETE FROM event_search');
  await database.customStatement('''
    INSERT INTO event_search(
      event_id,
      title,
      description,
      event_type,
      entity_names,
      category_names
    )
    SELECT
      e.id,
      e.title,
      COALESCE(e.description, ''),
      COALESCE(e.event_type, ''),
      COALESCE((
        SELECT group_concat(en.name, ' ')
        FROM relationships r
        JOIN entities en ON (
          (r.source_event_id = e.id AND r.target_entity_id = en.id) OR
          (r.target_event_id = e.id AND r.source_entity_id = en.id)
        )
        WHERE r.lifecycle <> 'soft_deleted'
          AND en.lifecycle <> 'soft_deleted'
      ), ''),
      COALESCE((
        SELECT group_concat(c.name, ' ')
        FROM event_categories ec
        JOIN categories c ON c.id = ec.category_id
        WHERE ec.event_id = e.id
          AND c.lifecycle <> 'soft_deleted'
      ), '')
    FROM events e
    WHERE e.lifecycle <> 'soft_deleted'
  ''');
}
