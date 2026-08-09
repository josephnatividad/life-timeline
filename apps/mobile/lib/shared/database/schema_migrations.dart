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
