import 'package:drift/drift.dart';
import 'package:life_timeline/features/media/domain/memory_media_repository.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class DriftMemoryMediaRepository implements MemoryMediaRepository {
  const DriftMemoryMediaRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<MemoryMedia>> watchForEvent(String eventId) =>
      _eventQuery(eventId).watch().map(_mapRows);

  @override
  Stream<List<MemoryMedia>> watchGalleryPreview(
    String eventId, {
    required int limit,
  }) {
    if (limit <= 0) throw ArgumentError.value(limit, 'limit');
    final query = _eventQuery(eventId, galleryOnly: true)..limit(limit);
    return query.watch().map(_mapRows);
  }

  @override
  Stream<MemoryMedia?> watchHeroForEvent(String eventId) {
    final query = _eventQuery(eventId, heroOnly: true)..limit(1);
    return query.watch().map((rows) => rows.isEmpty ? null : _mapRow(rows[0]));
  }

  @override
  Stream<int> watchMediaCount(String eventId) {
    final count = _database.attachmentLinks.id.count();
    final query = _database.selectOnly(_database.attachmentLinks)
      ..addColumns([count])
      ..where(
        _database.attachmentLinks.eventId.equals(eventId) &
            _database.attachmentLinks.role.isNotValue('evidence'),
      );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  @override
  Future<List<MemoryMedia>> forEvent(String eventId) async =>
      _mapRows(await _eventQuery(eventId).get());

  @override
  Future<MemoryMedia?> byLinkId(String linkId) async {
    final query = _baseQuery()
      ..where(_database.attachmentLinks.id.equals(linkId));
    final rows = await query.get();
    return rows.isEmpty ? null : _mapRow(rows.single);
  }

  @override
  Future<void> add({
    required Attachment attachment,
    required AttachmentLink link,
  }) => _database.transaction(() async {
    if (link.eventId == null || link.role == AttachmentRole.evidence) {
      throw ArgumentError('Memory Media must be linked to an event.');
    }
    await _database
        .into(_database.attachments)
        .insertOnConflictUpdate(
          TimelineMapper.attachmentToCompanion(attachment),
        );
    await _database
        .into(_database.attachmentLinks)
        .insert(TimelineMapper.attachmentLinkToCompanion(link));
    await refreshEventSearchIndex(_database, link.eventId!);
  });

  @override
  Future<void> updateCaption({
    required String linkId,
    required String? caption,
  }) async {
    final normalized = caption?.trim();
    await (_database.update(
      _database.attachmentLinks,
    )..where((row) => row.id.equals(linkId))).write(
      db.AttachmentLinksCompanion(
        caption: Value(normalized?.isEmpty ?? true ? null : normalized),
      ),
    );
    final link = await (_database.select(
      _database.attachmentLinks,
    )..where((row) => row.id.equals(linkId))).getSingleOrNull();
    if (link?.eventId case final eventId?) {
      await refreshEventSearchIndex(_database, eventId);
    }
  }

  @override
  Future<void> reorder({
    required String eventId,
    required List<String> orderedLinkIds,
  }) => _database.transaction(() async {
    final current =
        await (_database.select(_database.attachmentLinks)..where(
              (row) =>
                  row.eventId.equals(eventId) & row.role.isNotValue('evidence'),
            ))
            .get();
    final currentIds = current.map((row) => row.id).toSet();
    if (orderedLinkIds.length != currentIds.length ||
        orderedLinkIds.toSet().length != orderedLinkIds.length ||
        !orderedLinkIds.every(currentIds.contains)) {
      throw ArgumentError('Reorder must include every memory-media link once.');
    }
    for (final (index, id) in orderedLinkIds.indexed) {
      await (_database.update(_database.attachmentLinks)
            ..where((row) => row.id.equals(id)))
          .write(db.AttachmentLinksCompanion(sortOrder: Value(index)));
    }
  });

  @override
  Future<void> setHero({
    required String eventId,
    required String linkId,
  }) => _database.transaction(() async {
    final target =
        await (_database.select(_database.attachmentLinks)..where(
              (row) =>
                  row.id.equals(linkId) &
                  row.eventId.equals(eventId) &
                  row.role.isNotValue('evidence'),
            ))
            .getSingleOrNull();
    if (target == null) {
      throw StateError('The selected media is not linked to this memory.');
    }
    await (_database.update(_database.attachmentLinks)..where(
          (row) => row.eventId.equals(eventId) & row.role.equals('hero_media'),
        ))
        .write(const db.AttachmentLinksCompanion(role: Value('memory_media')));
    await (_database.update(_database.attachmentLinks)
          ..where((row) => row.id.equals(linkId)))
        .write(const db.AttachmentLinksCompanion(role: Value('hero_media')));
  });

  @override
  Future<void> clearHero({
    required String eventId,
    required String linkId,
  }) async {
    final changed =
        await (_database.update(_database.attachmentLinks)..where(
              (row) =>
                  row.id.equals(linkId) &
                  row.eventId.equals(eventId) &
                  row.role.equals('hero_media'),
            ))
            .write(
              const db.AttachmentLinksCompanion(role: Value('memory_media')),
            );
    if (changed != 1) {
      throw StateError('The selected photo is no longer the hero.');
    }
  }

  @override
  Future<void> removeFromMemory({
    required String eventId,
    required String linkId,
  }) async {
    final removed =
        await (_database.delete(_database.attachmentLinks)..where(
              (row) => row.id.equals(linkId) & row.eventId.equals(eventId),
            ))
            .go();
    if (removed != 1) {
      throw StateError('The media link no longer exists.');
    }
    await refreshEventSearchIndex(_database, eventId);
  }

  @override
  Future<UnreferencedMediaDeletion> deleteUnreferenced({
    required String eventId,
    required String linkId,
  }) => _database.transaction(() async {
    final link =
        await (_database.select(_database.attachmentLinks)..where(
              (row) => row.id.equals(linkId) & row.eventId.equals(eventId),
            ))
            .getSingleOrNull();
    if (link == null) throw StateError('The media link no longer exists.');
    await (_database.delete(
      _database.attachmentLinks,
    )..where((row) => row.id.equals(linkId))).go();
    await refreshEventSearchIndex(_database, eventId);

    final remainingLinkCount =
        await (_database.selectOnly(_database.attachmentLinks)
              ..addColumns([_database.attachmentLinks.id.count()])
              ..where(
                _database.attachmentLinks.attachmentId.equals(
                  link.attachmentId,
                ),
              ))
            .map((row) => row.read(_database.attachmentLinks.id.count()) ?? 0)
            .getSingle();
    final provenanceCount =
        await (_database.selectOnly(_database.fieldProvenanceRows)
              ..addColumns([_database.fieldProvenanceRows.id.count()])
              ..where(
                _database.fieldProvenanceRows.attachmentId.equals(
                  link.attachmentId,
                ),
              ))
            .map(
              (row) => row.read(_database.fieldProvenanceRows.id.count()) ?? 0,
            )
            .getSingle();
    final archiveCount =
        await (_database.selectOnly(_database.archiveReferences)
              ..addColumns([_database.archiveReferences.id.count()])
              ..where(
                _database.archiveReferences.attachmentId.equals(
                  link.attachmentId,
                ),
              ))
            .map((row) => row.read(_database.archiveReferences.id.count()) ?? 0)
            .getSingle();
    if (remainingLinkCount != 0 || provenanceCount != 0 || archiveCount != 0) {
      return const UnreferencedMediaDeletion(assetDeleted: false);
    }

    final asset = await (_database.select(
      _database.attachments,
    )..where((row) => row.id.equals(link.attachmentId))).getSingleOrNull();
    if (asset == null) {
      return const UnreferencedMediaDeletion(assetDeleted: false);
    }
    final paths = <String>{
      if (asset.importMode != 'reference_original' &&
          asset.relativePath != null)
        asset.relativePath!,
      ?asset.thumbnailRelativePath,
      ?asset.preservedOriginalRelativePath,
    };
    final now = DateTime.now().toUtc();
    await (_database.update(
      _database.attachments,
    )..where((row) => row.id.equals(asset.id))).write(
      db.AttachmentsCompanion(
        lifecycle: const Value('soft_deleted'),
        updatedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
    return UnreferencedMediaDeletion(
      assetDeleted: true,
      attachmentId: asset.id,
      managedRelativePaths: List.unmodifiable(paths),
    );
  });

  @override
  Future<void> completeManagedDeletion(String attachmentId) =>
      _database.transaction(() async {
        final links =
            await (_database.selectOnly(_database.attachmentLinks)
                  ..addColumns([_database.attachmentLinks.id.count()])
                  ..where(
                    _database.attachmentLinks.attachmentId.equals(attachmentId),
                  ))
                .map(
                  (row) => row.read(_database.attachmentLinks.id.count()) ?? 0,
                )
                .getSingle();
        if (links != 0) {
          throw StateError('A referenced asset cannot finish deletion.');
        }
        final protectedReferences = await _database
            .customSelect(
              '''
          SELECT
            (SELECT COUNT(*) FROM field_provenance WHERE attachment_id = ?) +
            (SELECT COUNT(*) FROM archive_references WHERE attachment_id = ?)
              AS reference_count
          ''',
              variables: [
                Variable.withString(attachmentId),
                Variable.withString(attachmentId),
              ],
              readsFrom: {
                _database.fieldProvenanceRows,
                _database.archiveReferences,
              },
            )
            .map((row) => row.read<int>('reference_count'))
            .getSingle();
        if (protectedReferences != 0) {
          throw StateError('A protected asset cannot finish deletion.');
        }
        final deleted =
            await (_database.delete(_database.attachments)..where(
                  (row) =>
                      row.id.equals(attachmentId) &
                      row.lifecycle.equals('soft_deleted'),
                ))
                .go();
        if (deleted != 1) {
          throw StateError('The staged media deletion no longer exists.');
        }
      });

  JoinedSelectStatement<HasResultSet, dynamic> _baseQuery() =>
      _database.select(_database.attachments).join([
        innerJoin(
          _database.attachmentLinks,
          _database.attachmentLinks.attachmentId.equalsExp(
            _database.attachments.id,
          ),
        ),
      ]);

  JoinedSelectStatement<HasResultSet, dynamic> _eventQuery(
    String eventId, {
    bool galleryOnly = false,
    bool heroOnly = false,
  }) {
    assert(!(galleryOnly && heroOnly));
    final query = _baseQuery()
      ..where(
        _database.attachmentLinks.eventId.equals(eventId) &
            _database.attachmentLinks.role.isNotValue('evidence') &
            (galleryOnly
                ? _database.attachmentLinks.role.equals('memory_media')
                : const Constant(true)) &
            (heroOnly
                ? _database.attachmentLinks.role.equals('hero_media')
                : const Constant(true)) &
            _database.attachments.lifecycle.isNotValue('soft_deleted'),
      )
      ..orderBy([
        OrderingTerm.asc(_database.attachmentLinks.sortOrder),
        OrderingTerm.asc(_database.attachmentLinks.importedAt),
      ]);
    return query;
  }

  List<MemoryMedia> _mapRows(List<TypedResult> rows) =>
      List.unmodifiable(rows.map(_mapRow));

  MemoryMedia _mapRow(TypedResult result) => MemoryMedia(
    attachment: TimelineMapper.attachmentFromRow(
      result.readTable(_database.attachments),
    ),
    link: TimelineMapper.attachmentLinkFromRow(
      result.readTable(_database.attachmentLinks),
    ),
  );
}
