import 'package:drift/drift.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class DriftStorageRepository implements StorageRepository {
  const DriftStorageRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<List<StoredAttachment>> attachments() async {
    final attachmentRows =
        await (_database.select(_database.attachments)
              ..where((row) => row.lifecycle.isNotValue('soft_deleted'))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    final archiveRows = await _database
        .select(_database.archiveReferences)
        .get();
    final archives = {
      for (final row in archiveRows) row.attachmentId: _archiveFromRow(row),
    };
    final links = await _database.select(_database.attachmentLinks).get();
    final roles = <String, Set<AttachmentRole>>{};
    for (final link in links) {
      roles
          .putIfAbsent(link.attachmentId, () => <AttachmentRole>{})
          .add(TimelineMapper.attachmentLinkFromRow(link).role);
    }
    return [
      for (final row in attachmentRows)
        StoredAttachment(
          attachment: TimelineMapper.attachmentFromRow(row),
          archiveReference: archives[row.id],
          roles: Set.unmodifiable(roles[row.id] ?? const {}),
        ),
    ];
  }

  @override
  Future<StoredAttachment?> attachmentById(String id) async {
    final attachment = await (_database.select(
      _database.attachments,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (attachment == null || attachment.lifecycle == 'soft_deleted') {
      return null;
    }
    final archive = await (_database.select(
      _database.archiveReferences,
    )..where((row) => row.attachmentId.equals(id))).getSingleOrNull();
    final linkRows = await (_database.select(
      _database.attachmentLinks,
    )..where((row) => row.attachmentId.equals(id))).get();
    return StoredAttachment(
      attachment: TimelineMapper.attachmentFromRow(attachment),
      archiveReference: archive == null ? null : _archiveFromRow(archive),
      roles: Set.unmodifiable(
        linkRows
            .map((row) => TimelineMapper.attachmentLinkFromRow(row).role)
            .toSet(),
      ),
    );
  }

  @override
  Future<DateTime?> latestContentChangeAt() async {
    final latestAttachment =
        await (_database.select(_database.attachments)
              ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    final latestArchive =
        await (_database.select(_database.archiveReferences)
              ..orderBy([(row) => OrderingTerm.desc(row.archivedAt)])
              ..limit(1))
            .getSingleOrNull();
    final candidates = <DateTime>[
      if (latestAttachment != null) latestAttachment.updatedAt,
      if (latestArchive != null) latestArchive.archivedAt,
    ]..sort();
    return candidates.isEmpty ? null : candidates.last.toUtc();
  }

  @override
  Future<void> saveVerifiedArchive(
    ArchiveReference reference, {
    String? thumbnailRelativePath,
  }) => _database.transaction(() async {
    final exists =
        await (_database.selectOnly(_database.attachments)
              ..addColumns([_database.attachments.id])
              ..where(_database.attachments.id.equals(reference.attachmentId)))
            .getSingleOrNull();
    if (exists == null) throw StateError('Attachment no longer exists.');
    await _database
        .into(_database.archiveReferences)
        .insertOnConflictUpdate(_archiveToCompanion(reference));
    await (_database.update(
      _database.attachments,
    )..where((row) => row.id.equals(reference.attachmentId))).write(
      db.AttachmentsCompanion(
        thumbnailRelativePath: Value(thumbnailRelativePath),
        updatedAt: Value(reference.verifiedAt),
      ),
    );
  });

  @override
  Future<void> markArchiveRemovalStarted(String attachmentId, DateTime at) =>
      (_database.update(
        _database.attachments,
      )..where((row) => row.id.equals(attachmentId))).write(
        db.AttachmentsCompanion(
          storageState: const Value('archived'),
          updatedAt: Value(at.toUtc()),
        ),
      );

  @override
  Future<void> completeArchiveRemoval(
    String attachmentId,
    DateTime at, {
    required ArchiveSourceKind sourceKind,
  }) =>
      (_database.update(
        _database.attachments,
      )..where((row) => row.id.equals(attachmentId))).write(
        db.AttachmentsCompanion(
          storageState: const Value('archived'),
          relativePath: sourceKind == ArchiveSourceKind.main
              ? const Value(null)
              : const Value.absent(),
          preservedOriginalRelativePath:
              sourceKind == ArchiveSourceKind.preservedOriginal
              ? const Value(null)
              : const Value.absent(),
          preservedOriginalByteSize:
              sourceKind == ArchiveSourceKind.preservedOriginal
              ? const Value(null)
              : const Value.absent(),
          preservedOriginalChecksum:
              sourceKind == ArchiveSourceKind.preservedOriginal
              ? const Value(null)
              : const Value.absent(),
          updatedAt: Value(at.toUtc()),
        ),
      );

  @override
  Future<void> revertArchiveRemoval(String attachmentId, DateTime at) =>
      (_database.update(
        _database.attachments,
      )..where((row) => row.id.equals(attachmentId))).write(
        db.AttachmentsCompanion(
          storageState: const Value('local'),
          updatedAt: Value(at.toUtc()),
        ),
      );

  @override
  Future<void> restoreArchivedAttachment({
    required String attachmentId,
    required String relativePath,
    required int byteSize,
    required String checksum,
    required ArchiveSourceKind sourceKind,
    required DateTime at,
  }) =>
      (_database.update(
        _database.attachments,
      )..where((row) => row.id.equals(attachmentId))).write(
        db.AttachmentsCompanion(
          storageState: const Value('local'),
          relativePath: sourceKind == ArchiveSourceKind.main
              ? Value(relativePath)
              : const Value.absent(),
          byteSize: sourceKind == ArchiveSourceKind.main
              ? Value(byteSize)
              : const Value.absent(),
          checksum: sourceKind == ArchiveSourceKind.main
              ? Value(checksum)
              : const Value.absent(),
          preservedOriginalRelativePath:
              sourceKind == ArchiveSourceKind.preservedOriginal
              ? Value(relativePath)
              : const Value.absent(),
          preservedOriginalByteSize:
              sourceKind == ArchiveSourceKind.preservedOriginal
              ? Value(byteSize)
              : const Value.absent(),
          preservedOriginalChecksum:
              sourceKind == ArchiveSourceKind.preservedOriginal
              ? Value(checksum)
              : const Value.absent(),
          updatedAt: Value(at.toUtc()),
        ),
      );

  @override
  Future<void> updateOptimizedAttachment(Attachment attachment) => _database
      .into(_database.attachments)
      .insertOnConflictUpdate(TimelineMapper.attachmentToCompanion(attachment));

  ArchiveReference _archiveFromRow(db.ArchiveReference row) => ArchiveReference(
    id: row.id,
    attachmentId: row.attachmentId,
    destinationType: ArchiveDestinationType.values.byName(row.destinationType),
    logicalKey: row.logicalKey,
    originalByteSize: row.originalByteSize,
    originalSha256: row.originalSha256,
    archiveByteSize: row.archiveByteSize,
    archiveSha256: row.archiveSha256,
    encryptionAlgorithm: row.encryptionAlgorithm,
    formatVersion: row.formatVersion,
    sourceKind: row.sourceKind == 'preserved_original'
        ? ArchiveSourceKind.preservedOriginal
        : ArchiveSourceKind.main,
    archivedAt: row.archivedAt,
    verifiedAt: row.verifiedAt,
  );

  db.ArchiveReferencesCompanion _archiveToCompanion(ArchiveReference value) =>
      db.ArchiveReferencesCompanion(
        id: Value(value.id),
        attachmentId: Value(value.attachmentId),
        destinationType: Value(value.destinationType.name),
        logicalKey: Value(value.logicalKey),
        originalByteSize: Value(value.originalByteSize),
        originalSha256: Value(value.originalSha256),
        archiveByteSize: Value(value.archiveByteSize),
        archiveSha256: Value(value.archiveSha256),
        encryptionAlgorithm: Value(value.encryptionAlgorithm),
        formatVersion: Value(value.formatVersion),
        sourceKind: Value(
          value.sourceKind == ArchiveSourceKind.preservedOriginal
              ? 'preserved_original'
              : 'main',
        ),
        archivedAt: Value(value.archivedAt),
        verifiedAt: Value(value.verifiedAt),
      );
}
