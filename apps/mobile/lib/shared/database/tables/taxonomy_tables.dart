import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/tables/record_columns.dart';
import 'package:life_timeline/shared/database/tables/timeline_tables.dart';

@TableIndex(name: 'tags_lifecycle_idx', columns: {#lifecycle})
class Tags extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get normalizedName => text().unique()();

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
  ];
}

@TableIndex(name: 'categories_lifecycle_idx', columns: {#lifecycle})
@TableIndex(name: 'categories_parent_idx', columns: {#parentId})
class Categories extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get normalizedName => text().unique()();
  TextColumn get parentId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.restrict,
  )();

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
    'CHECK (parent_id IS NULL OR parent_id <> id)',
  ];
}

@TableIndex(name: 'entity_tags_tag_idx', columns: {#tagId})
class EntityTags extends Table {
  TextColumn get entityId =>
      text().references(Entities, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {entityId, tagId};
}

@TableIndex(name: 'event_tags_tag_idx', columns: {#tagId})
class EventTags extends Table {
  TextColumn get eventId =>
      text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {eventId, tagId};
}

@TableIndex(name: 'evidence_tags_tag_idx', columns: {#tagId})
class EvidenceTags extends Table {
  TextColumn get evidenceId =>
      text().references(EvidenceRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {evidenceId, tagId};
}

@TableIndex(name: 'entity_categories_category_idx', columns: {#categoryId})
class EntityCategories extends Table {
  TextColumn get entityId =>
      text().references(Entities, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {entityId, categoryId};
}

@TableIndex(name: 'event_categories_category_idx', columns: {#categoryId})
class EventCategories extends Table {
  TextColumn get eventId =>
      text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {eventId, categoryId};
}

@TableIndex(name: 'evidence_categories_category_idx', columns: {#categoryId})
class EvidenceCategories extends Table {
  TextColumn get evidenceId =>
      text().references(EvidenceRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {evidenceId, categoryId};
}
