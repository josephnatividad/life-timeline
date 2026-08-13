import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';
import 'package:life_timeline/shared/database/tables/candidate_provenance_tables.dart';
import 'package:life_timeline/shared/database/tables/insight_tables.dart';
import 'package:life_timeline/shared/database/tables/reminder_tables.dart';
import 'package:life_timeline/shared/database/tables/schema_constraints.dart';
import 'package:life_timeline/shared/database/tables/storage_tables.dart';
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
    AttachmentLinks,
    ArchiveReferences,
    FieldProvenanceRows,
    MemoryCandidates,
    CandidateExtractedFields,
    CandidateEntityProposals,
    FeatureUsage,
    Tags,
    Categories,
    EntityTags,
    EventTags,
    EvidenceTags,
    EntityCategories,
    EventCategories,
    EvidenceCategories,
    InsightDismissals,
    Reminders,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'life_timeline'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await createAttachmentLinkIndexes(this);
      await createEventSearchSchema(this);
    },
    onUpgrade: (migrator, from, to) =>
        migrateSchema(this, migrator, from: from, to: to),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
