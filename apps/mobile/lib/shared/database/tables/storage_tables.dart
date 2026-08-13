import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/tables/timeline_tables.dart';

@TableIndex(
  name: 'archive_references_attachment_idx',
  columns: {#attachmentId},
  unique: true,
)
@TableIndex(name: 'archive_references_archived_at_idx', columns: {#archivedAt})
class ArchiveReferences extends Table {
  TextColumn get id => text()();
  TextColumn get attachmentId =>
      text().references(Attachments, #id, onDelete: KeyAction.cascade)();
  TextColumn get destinationType => text()();
  TextColumn get logicalKey => text()();
  IntColumn get originalByteSize => integer().check(
    const CustomExpression<bool>('original_byte_size >= 0'),
  )();
  TextColumn get originalSha256 => text()();
  IntColumn get archiveByteSize =>
      integer().check(const CustomExpression<bool>('archive_byte_size >= 0'))();
  TextColumn get archiveSha256 => text()();
  TextColumn get encryptionAlgorithm => text()();
  TextColumn get sourceKind => text()
      .withDefault(const Constant('main'))
      .check(
        const CustomExpression<bool>(
          "source_kind IN ('main', 'preserved_original')",
        ),
      )();
  IntColumn get formatVersion =>
      integer().check(const CustomExpression<bool>('format_version >= 1'))();
  DateTimeColumn get archivedAt => dateTime()();
  DateTimeColumn get verifiedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (verified_at >= archived_at)',
  ];
}
