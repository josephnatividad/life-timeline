import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/features/storage/infrastructure/local_image_optimization_service.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory sandbox;
  late _OptimizationPaths paths;
  late File original;
  late _OptimizationRepository repository;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('image_optimization_test_');
    paths = await _OptimizationPaths.create(sandbox);
    original = File(p.join(paths.attachmentRoot, 'photos', 'original.jpg'));
    await original.parent.create(recursive: true);
    await original.writeAsBytes(image.encodeJpg(_noisyImage(), quality: 100));
    repository = _OptimizationRepository(
      _attachment(
        relativePath: p.join('photos', 'original.jpg'),
        byteSize: await original.length(),
      ),
    );
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test(
    'creates and verifies an optimized copy while preserving original',
    () async {
      final result = await LocalImageOptimizationService(
        repository,
        paths,
        minimumBytes: 1,
        maximumDimension: 300,
      ).optimize('attachment-1', preserveOriginal: true);

      expect(result.outcome, ImageOptimizationOutcome.optimized);
      expect(result.afterBytes, lessThan(result.beforeBytes));
      expect(result.originalPreserved, isTrue);
      expect(await original.exists(), isTrue);
      expect(repository.value.importMode, AttachmentImportMode.optimizedCopy);
      expect(
        repository.value.preservedOriginalRelativePath,
        p.join('photos', 'original.jpg'),
      );
      expect(repository.value.pixelWidth, 300);
      expect(repository.value.pixelHeight, 200);
      expect(
        await File(
          p.join(paths.attachmentRoot, repository.value.relativePath),
        ).exists(),
        isTrue,
      );
    },
  );

  test('removes original only after optimized metadata is committed', () async {
    final result = await LocalImageOptimizationService(
      repository,
      paths,
      minimumBytes: 1,
      maximumDimension: 300,
    ).optimize('attachment-1', preserveOriginal: false);

    expect(result.outcome, ImageOptimizationOutcome.optimized);
    expect(result.originalRemoved, isTrue);
    expect(await original.exists(), isFalse);
    expect(repository.value.preservedOriginalRelativePath, isNull);
    expect(repository.updateCount, 2);
  });

  test('unsupported source is left unchanged', () async {
    repository.value = _attachment(
      relativePath: p.join('photos', 'original.jpg'),
      byteSize: await original.length(),
      mimeType: 'image/png',
    );

    final result = await LocalImageOptimizationService(
      repository,
      paths,
      minimumBytes: 1,
      maximumDimension: 300,
    ).optimize('attachment-1', preserveOriginal: false);

    expect(result.outcome, ImageOptimizationOutcome.unsupported);
    expect(await original.exists(), isTrue);
    expect(repository.updateCount, 0);
  });
}

image.Image _noisyImage() {
  final value = image.Image(width: 600, height: 400);
  for (var y = 0; y < value.height; y++) {
    for (var x = 0; x < value.width; x++) {
      value.setPixelRgba(
        x,
        y,
        (x * 17 + y * 31) % 256,
        (x * 47 + y * 13) % 256,
        (x * 7 + y * 61) % 256,
        255,
      );
    }
  }
  return value;
}

Attachment _attachment({
  required String relativePath,
  required int byteSize,
  String mimeType = 'image/jpeg',
}) => Attachment(
  metadata: RecordMetadata(
    id: 'attachment-1',
    privacyClassification: PrivacyClassification.sensitive,
    lifecycle: RecordLifecycle.confirmed,
    createdAt: DateTime.utc(2026, 8, 1),
    updatedAt: DateTime.utc(2026, 8, 1),
  ),
  evidenceId: 'evidence-1',
  storageState: AttachmentStorageState.local,
  importMode: AttachmentImportMode.preserveOriginal,
  mimeType: mimeType,
  byteSize: byteSize,
  relativePath: relativePath,
);

final class _OptimizationPaths implements StoragePathProvider {
  _OptimizationPaths._(this.root);

  static Future<_OptimizationPaths> create(Directory sandbox) async {
    final root = Directory(p.join(sandbox.path, 'support', 'attachments'));
    await root.create(recursive: true);
    return _OptimizationPaths._(root.path);
  }

  final String root;
  String get attachmentRoot => root;

  @override
  Future<String> applicationDocumentsPath() async => p.dirname(root);

  @override
  Future<String> applicationSupportPath() async => p.dirname(root);

  @override
  Future<String> attachmentRootPath() async => root;

  @override
  Future<String> temporaryPath() async => p.dirname(p.dirname(root));
}

final class _OptimizationRepository implements StorageRepository {
  _OptimizationRepository(this.value);

  int updateCount = 0;
  Attachment value;

  @override
  Future<StoredAttachment?> attachmentById(String id) async =>
      id == value.metadata.id ? StoredAttachment(attachment: value) : null;

  @override
  Future<List<StoredAttachment>> attachments() async => [
    StoredAttachment(attachment: value),
  ];

  @override
  Future<void> updateOptimizedAttachment(Attachment attachment) async {
    updateCount++;
    value = attachment;
  }

  @override
  Future<void> completeArchiveRemoval(String attachmentId, DateTime at) =>
      throw UnimplementedError();

  @override
  Future<DateTime?> latestContentChangeAt() async => value.metadata.updatedAt;

  @override
  Future<void> markArchiveRemovalStarted(String attachmentId, DateTime at) =>
      throw UnimplementedError();

  @override
  Future<void> restoreArchivedAttachment({
    required String attachmentId,
    required String relativePath,
    required int byteSize,
    required String checksum,
    required DateTime at,
  }) => throw UnimplementedError();

  @override
  Future<void> revertArchiveRemoval(String attachmentId, DateTime at) =>
      throw UnimplementedError();

  @override
  Future<void> saveVerifiedArchive(
    ArchiveReference reference, {
    String? thumbnailRelativePath,
  }) => throw UnimplementedError();
}
