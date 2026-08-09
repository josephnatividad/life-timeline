import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';
import 'package:life_timeline/shared/database/tables/candidate_provenance_tables.dart';
import 'package:life_timeline/shared/database/tables/schema_constraints.dart';
import 'package:life_timeline/shared/database/tables/taxonomy_tables.dart';
import 'package:life_timeline/shared/database/tables/timeline_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Entities,
    Events,
    EvidenceRecords,
    Relationships,
    Attachments,
    FieldProvenanceRows,
    MemoryCandidates,
    Tags,
    Categories,
    EntityTags,
    EventTags,
    EvidenceTags,
    EntityCategories,
    EventCategories,
    EvidenceCategories,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'life_timeline'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // FTS is intentionally an additive migration after search privacy and
  // soft-deletion indexing semantics are accepted. The normalized columns in
  // v1 make that migration deterministic without indexing attachment content.

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) =>
        migrateSchema(migrator, from: from, to: to),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
