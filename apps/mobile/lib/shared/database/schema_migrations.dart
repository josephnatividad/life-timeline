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
      case 6:
        await database.customStatement(
          'ALTER TABLE attachments ADD COLUMN preserved_original_relative_path TEXT NULL',
        );
        await database.customStatement(
          'ALTER TABLE attachments ADD COLUMN pixel_width INTEGER NULL CHECK (pixel_width IS NULL OR pixel_width > 0)',
        );
        await database.customStatement(
          'ALTER TABLE attachments ADD COLUMN pixel_height INTEGER NULL CHECK (pixel_height IS NULL OR pixel_height > 0)',
        );
        await database.customStatement('''
          CREATE TABLE archive_references (
            id TEXT NOT NULL PRIMARY KEY,
            attachment_id TEXT NOT NULL REFERENCES attachments(id) ON DELETE CASCADE,
            destination_type TEXT NOT NULL,
            logical_key TEXT NOT NULL,
            original_byte_size INTEGER NOT NULL CHECK (original_byte_size >= 0),
            original_sha256 TEXT NOT NULL,
            archive_byte_size INTEGER NOT NULL CHECK (archive_byte_size >= 0),
            archive_sha256 TEXT NOT NULL,
            encryption_algorithm TEXT NOT NULL,
            format_version INTEGER NOT NULL CHECK (format_version >= 1),
            archived_at INTEGER NOT NULL,
            verified_at INTEGER NOT NULL,
            CHECK (verified_at >= archived_at)
          )
        ''');
        await database.customStatement(
          'CREATE UNIQUE INDEX archive_references_attachment_idx ON archive_references(attachment_id)',
        );
        await database.customStatement(
          'CREATE INDEX archive_references_archived_at_idx ON archive_references(archived_at)',
        );
        break;
      case 7:
        await database.customStatement('''
          CREATE TEMP TABLE v7_attachment_evidence AS
          SELECT id AS attachment_id, evidence_id, created_at
          FROM attachments
        ''');
        await database.customStatement('''
          CREATE TEMP TABLE v7_archive_references AS
          SELECT * FROM archive_references
        ''');
        await database.customStatement('''
          CREATE TEMP TABLE v7_attachment_provenance AS
          SELECT * FROM field_provenance WHERE attachment_id IS NOT NULL
        ''');
        await database.customStatement(
          'DELETE FROM field_provenance WHERE attachment_id IS NOT NULL',
        );
        await database.customStatement('DELETE FROM archive_references');
        await database.customStatement('''
          CREATE TABLE attachments_v7 (
            id TEXT NOT NULL PRIMARY KEY,
            privacy_classification TEXT NOT NULL CHECK (privacy_classification IN ('share_safe', 'personal', 'sensitive', 'never_share')),
            lifecycle TEXT NOT NULL CHECK (lifecycle IN ('candidate', 'confirmed', 'archived', 'soft_deleted')),
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER NULL,
            display_name TEXT NULL,
            relative_path TEXT NULL,
            thumbnail_relative_path TEXT NULL,
            preserved_original_relative_path TEXT NULL,
            preserved_original_byte_size INTEGER NULL CHECK (preserved_original_byte_size IS NULL OR preserved_original_byte_size >= 0),
            preserved_original_checksum TEXT NULL,
            mime_type TEXT NOT NULL,
            byte_size INTEGER NOT NULL CHECK (byte_size >= 0),
            pixel_width INTEGER NULL CHECK (pixel_width IS NULL OR pixel_width > 0),
            pixel_height INTEGER NULL CHECK (pixel_height IS NULL OR pixel_height > 0),
            checksum TEXT NULL,
            storage_state TEXT NOT NULL CHECK (storage_state IN ('local', 'referenced', 'archived', 'unavailable')),
            import_mode TEXT NOT NULL CHECK (import_mode IN ('reference_original', 'optimized_copy', 'preserve_original')),
            CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL)),
            CHECK (updated_at >= created_at)
          )
        ''');
        await database.customStatement('''
          INSERT INTO attachments_v7 (
            id, privacy_classification, lifecycle, created_at, updated_at,
            deleted_at, display_name, relative_path, thumbnail_relative_path,
            preserved_original_relative_path, preserved_original_byte_size,
            preserved_original_checksum, mime_type, byte_size, pixel_width,
            pixel_height, checksum, storage_state, import_mode
          )
          SELECT
            id, privacy_classification, lifecycle, created_at, updated_at,
            deleted_at, display_name, relative_path, thumbnail_relative_path,
            preserved_original_relative_path, NULL, NULL, mime_type, byte_size,
            pixel_width, pixel_height, checksum, storage_state, import_mode
          FROM attachments
        ''');
        await database.customStatement('DROP TABLE attachments');
        await database.customStatement(
          'ALTER TABLE attachments_v7 RENAME TO attachments',
        );
        await database.customStatement(
          'CREATE INDEX attachments_storage_state_idx ON attachments(storage_state)',
        );
        await database.customStatement(
          'CREATE INDEX attachments_checksum_idx ON attachments(checksum)',
        );
        await database.customStatement('''
          CREATE TABLE attachment_links (
            id TEXT NOT NULL PRIMARY KEY,
            attachment_id TEXT NOT NULL REFERENCES attachments(id) ON DELETE CASCADE,
            event_id TEXT NULL REFERENCES events(id) ON DELETE CASCADE,
            evidence_id TEXT NULL REFERENCES evidence(id) ON DELETE CASCADE,
            role TEXT NOT NULL CHECK (role IN ('hero_media', 'memory_media', 'evidence')),
            caption TEXT NULL,
            sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
            captured_at INTEGER NULL,
            imported_at INTEGER NOT NULL,
            CHECK ((event_id IS NOT NULL) <> (evidence_id IS NOT NULL)),
            CHECK ((role = 'evidence') = (evidence_id IS NOT NULL))
          )
        ''');
        await database.customStatement('''
          INSERT INTO attachment_links (
            id, attachment_id, event_id, evidence_id, role, caption,
            sort_order, captured_at, imported_at
          )
          SELECT
            'evidence-link:' || evidence_id || ':' || attachment_id,
            attachment_id,
            NULL,
            evidence_id,
            'evidence',
            NULL,
            0,
            NULL,
            created_at
          FROM v7_attachment_evidence
        ''');
        await database.customStatement('''
          INSERT INTO archive_references
          SELECT * FROM v7_archive_references
        ''');
        await database.customStatement('''
          INSERT INTO field_provenance
          SELECT * FROM v7_attachment_provenance
        ''');
        await database.customStatement('''
          UPDATE evidence
          SET evidence_type = CASE evidence_type
            WHEN 'document' THEN 'official_document'
            WHEN 'photo' THEN 'other'
            WHEN 'screenshot' THEN 'other'
            WHEN 'metadata' THEN 'other'
            ELSE evidence_type
          END
        ''');
        await database.customStatement('''
          ALTER TABLE archive_references
          ADD COLUMN source_kind TEXT NOT NULL DEFAULT 'main'
          CHECK (source_kind IN ('main', 'preserved_original'))
        ''');
        await createAttachmentLinkIndexes(database);
        await database.customStatement('DROP TABLE IF EXISTS event_search');
        await createEventSearchSchema(database);
        await database.customStatement('DROP TABLE v7_attachment_evidence');
        await database.customStatement('DROP TABLE v7_archive_references');
        await database.customStatement('DROP TABLE v7_attachment_provenance');
        break;
      case 8:
        await database.customStatement('''
          CREATE TABLE reminders (
            id TEXT NOT NULL PRIMARY KEY,
            linked_event_id TEXT NULL REFERENCES events(id) ON DELETE CASCADE,
            linked_entity_id TEXT NULL REFERENCES entities(id) ON DELETE SET NULL,
            source_evidence_id TEXT NULL REFERENCES evidence(id) ON DELETE SET NULL,
            title TEXT NOT NULL CHECK (length(trim(title)) > 0),
            note TEXT NULL,
            target_year INTEGER NOT NULL,
            target_month INTEGER NOT NULL,
            target_day INTEGER NOT NULL,
            reminder_year INTEGER NOT NULL,
            reminder_month INTEGER NOT NULL,
            reminder_day INTEGER NOT NULL,
            reminder_hour INTEGER NOT NULL,
            reminder_minute INTEGER NOT NULL,
            time_zone_id TEXT NOT NULL CHECK (length(trim(time_zone_id)) > 0),
            scheduled_at_utc INTEGER NOT NULL,
            reminder_type TEXT NOT NULL CHECK (reminder_type IN ('expiry', 'renewal', 'warranty', 'anniversary', 'follow_up', 'custom')),
            lead_time TEXT NOT NULL CHECK (lead_time IN ('on_day', 'one_day', 'seven_days', 'thirty_days', 'ninety_days', 'six_months', 'custom')),
            status TEXT NOT NULL CHECK (status IN ('scheduled', 'disabled', 'completed', 'missed', 'cancelled')),
            notification_id INTEGER NOT NULL CHECK (notification_id > 0),
            privacy_classification TEXT NOT NULL CHECK (privacy_classification IN ('share_safe', 'personal', 'sensitive', 'never_share')),
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            completed_at INTEGER NULL,
            dismissed_at INTEGER NULL,
            CHECK (target_month BETWEEN 1 AND 12 AND target_day BETWEEN 1 AND 31),
            CHECK (reminder_month BETWEEN 1 AND 12 AND reminder_day BETWEEN 1 AND 31),
            CHECK (reminder_hour BETWEEN 0 AND 23 AND reminder_minute BETWEEN 0 AND 59),
            CHECK ((status = 'completed') = (completed_at IS NOT NULL)),
            CHECK (updated_at >= created_at)
          )
        ''');
        await database.customStatement(
          'CREATE INDEX reminders_status_schedule_idx ON reminders(status, scheduled_at_utc)',
        );
        await database.customStatement(
          'CREATE INDEX reminders_event_idx ON reminders(linked_event_id)',
        );
        await database.customStatement(
          'CREATE INDEX reminders_entity_idx ON reminders(linked_entity_id)',
        );
        await database.customStatement(
          'CREATE INDEX reminders_evidence_idx ON reminders(source_evidence_id)',
        );
        await database.customStatement(
          'CREATE UNIQUE INDEX reminders_notification_id_idx ON reminders(notification_id)',
        );
        break;
      default:
        throw StateError('Missing explicit migration to schema v$version.');
    }
  }
}

Future<void> createAttachmentLinkIndexes(GeneratedDatabase database) async {
  await database.customStatement(
    'CREATE INDEX IF NOT EXISTS attachment_links_event_idx ON attachment_links(event_id, sort_order)',
  );
  await database.customStatement(
    'CREATE INDEX IF NOT EXISTS attachment_links_evidence_idx ON attachment_links(evidence_id)',
  );
  await database.customStatement(
    'CREATE INDEX IF NOT EXISTS attachment_links_attachment_idx ON attachment_links(attachment_id)',
  );
  await database.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS attachment_links_event_attachment_idx ON attachment_links(event_id, attachment_id)',
  );
  await database.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS attachment_links_evidence_attachment_idx ON attachment_links(evidence_id, attachment_id)',
  );
  await database.customStatement(
    "CREATE UNIQUE INDEX IF NOT EXISTS attachment_links_single_hero_idx ON attachment_links(event_id) WHERE role = 'hero_media'",
  );
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
      media_captions,
      tokenize = 'unicode61 remove_diacritics 2'
    )
  ''');
  await rebuildEventSearchIndex(database);
}

Future<void> rebuildEventSearchIndex(GeneratedDatabase database) async {
  final attachmentLinksExist =
      (await database.customSelect('''
        SELECT EXISTS(
          SELECT 1 FROM sqlite_master
          WHERE type = 'table' AND name = 'attachment_links'
        ) AS present
      ''').getSingle()).read<int>('present') ==
      1;
  final mediaCaptionsExpression = attachmentLinksExist
      ? '''
        COALESCE((
          SELECT group_concat(al.caption, ' ')
          FROM attachment_links al
          WHERE al.event_id = e.id
            AND al.role IN ('hero_media', 'memory_media')
            AND al.caption IS NOT NULL
        ), '')
      '''
      : "''";
  await database.customStatement('DELETE FROM event_search');
  await database.customStatement('''
    INSERT INTO event_search(
      event_id,
      title,
      description,
      event_type,
      entity_names,
      category_names,
      media_captions
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
      ), ''),
      $mediaCaptionsExpression
    FROM events e
    WHERE e.lifecycle <> 'soft_deleted'
  ''');
}

Future<void> refreshEventSearchIndex(
  GeneratedDatabase database,
  String eventId,
) async {
  await database.customStatement(
    'DELETE FROM event_search WHERE event_id = ?',
    [eventId],
  );
  await database.customStatement(
    '''
    INSERT INTO event_search(
      event_id, title, description, event_type, entity_names,
      category_names, media_captions
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
      ), ''),
      COALESCE((
        SELECT group_concat(al.caption, ' ')
        FROM attachment_links al
        WHERE al.event_id = e.id
          AND al.role IN ('hero_media', 'memory_media')
          AND al.caption IS NOT NULL
      ), '')
    FROM events e
    WHERE e.id = ? AND e.lifecycle <> 'soft_deleted'
    ''',
    [eventId],
  );
}
