import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/shared/database/app_database.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';

final class DriftBackupDataSource implements BackupDataSource {
  const DriftBackupDataSource(this._database);

  static const _tablesInInsertOrder = [
    'entities',
    'events',
    'evidence',
    'tags',
    'categories',
    'relationships',
    'attachments',
    'archive_references',
    'memory_candidates',
    'candidate_extracted_fields',
    'candidate_entity_proposals',
    'field_provenance',
    'feature_usage',
    'insight_dismissals',
    'entity_tags',
    'event_tags',
    'evidence_tags',
    'entity_categories',
    'event_categories',
    'evidence_categories',
  ];

  final AppDatabase _database;

  @override
  int get schemaVersion => _database.schemaVersion;

  @override
  Future<DatabaseSnapshot> exportSnapshot() => _database.transaction(() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in _tablesInInsertOrder) {
      final rows = await _database.customSelect('SELECT * FROM "$table"').get();
      tables[table] = rows
          .map((row) => Map<String, Object?>.from(row.data))
          .toList(growable: false);
    }
    return DatabaseSnapshot(
      schemaVersion: _database.schemaVersion,
      tables: tables,
    );
  });

  @override
  Future<bool> hasUserData() async {
    for (final table in const [
      'entities',
      'events',
      'evidence',
      'attachments',
    ]) {
      final row = await _database
          .customSelect(
            'SELECT EXISTS(SELECT 1 FROM "$table" LIMIT 1) AS present',
          )
          .getSingle();
      if (row.read<int>('present') == 1) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> replaceWithSnapshot(DatabaseSnapshot snapshot) async {
    if (snapshot.schemaVersion < 1 || snapshot.schemaVersion > schemaVersion) {
      throw const BackupFailure('unsupported_database_version');
    }
    await _database.transaction(() async {
      final allowedColumns = <String, Set<String>>{};
      for (final table in _tablesInInsertOrder) {
        final info = await _database
            .customSelect('PRAGMA table_info("$table")')
            .get();
        allowedColumns[table] = {
          for (final row in info) row.read<String>('name'),
        };
      }
      for (final table in _tablesInInsertOrder.reversed) {
        await _database.customStatement('DELETE FROM "$table"');
      }
      for (final table in _tablesInInsertOrder) {
        final rows = snapshot.tables[table] ?? const [];
        for (final row in rows) {
          await _insertValidated(table, row, allowedColumns[table]!);
        }
      }
      await rebuildEventSearchIndex(_database);
    });
  }

  Future<void> _insertValidated(
    String table,
    Map<String, Object?> row,
    Set<String> allowedColumns,
  ) async {
    if (row.isEmpty ||
        row.keys.any(
          (column) =>
              !allowedColumns.contains(column) ||
              !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(column),
        )) {
      throw const BackupFailure('invalid_database_payload');
    }
    final columns = row.keys.toList(growable: false);
    final quotedColumns = columns.map((column) => '"$column"').join(', ');
    final placeholders = List.filled(columns.length, '?').join(', ');
    await _database.customStatement(
      'INSERT INTO "$table" ($quotedColumns) VALUES ($placeholders)',
      [for (final column in columns) row[column]],
    );
  }
}
