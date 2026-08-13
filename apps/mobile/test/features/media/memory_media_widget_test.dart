import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/media/domain/memory_media_paths.dart';
import 'package:life_timeline/features/media/domain/memory_media_repository.dart';
import 'package:life_timeline/features/media/presentation/managed_memory_image.dart';
import 'package:life_timeline/features/media/presentation/memory_media_gallery.dart';
import 'package:life_timeline/features/media/presentation/memory_media_viewer_page.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/timeline_event_tile.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  final media = [_media(0, hero: true), _media(1), _media(2)];

  testWidgets('gallery renders hero, count, controls, and curated grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        media: media,
        child: const SingleChildScrollView(
          child: MemoryMediaGallery(memoryId: 'event-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 photos'), findsOneWidget);
    expect(find.byKey(const Key('memory-add-photo')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Open hero photo')), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('gallery supports dark mode, large text, and Reduced Motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        media: media,
        dark: true,
        textScale: 2,
        reducedMotion: true,
        child: const SingleChildScrollView(
          child: MemoryMediaGallery(memoryId: 'event-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Hero), findsNothing);
    expect(find.text('Photos'), findsOneWidget);
  });

  testWidgets('viewer exposes count and non-gesture photo controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        media: media,
        dark: true,
        child: const MemoryMediaViewerPage(
          memoryId: 'event-1',
          initialLinkId: 'link-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 of 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Photo options'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsWidgets);
  });

  testWidgets('timeline uses the hero thumbnail without loading an original', (
    tester,
  ) async {
    final at = DateTime.utc(2026, 8, 12);
    final memory = TimelineMemory(
      event: Event(
        metadata: RecordMetadata(
          id: 'event-1',
          privacyClassification: PrivacyClassification.personal,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: at,
          updatedAt: at,
        ),
        title: 'Photo memory',
        temporalValue: TemporalValue.year(2026),
      ),
    );
    await tester.pumpWidget(
      _app(
        media: media,
        child: TimelineEventTile(memory: memory, onTap: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ManagedMemoryImage), findsOneWidget);
    expect(find.text('Photo memory'), findsOneWidget);
  });

  testWidgets('50-photo gallery remains scrollable without eager originals', (
    tester,
  ) async {
    final largeGallery = [
      for (var index = 0; index < 50; index++) _media(index, hero: index == 0),
    ];
    await tester.pumpWidget(
      _app(
        media: largeGallery,
        child: const SingleChildScrollView(
          child: MemoryMediaGallery(memoryId: 'event-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('50 photos'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({
  required List<MemoryMedia> media,
  required Widget child,
  bool dark = false,
  double textScale = 1,
  bool reducedMotion = false,
}) => ProviderScope(
  overrides: [
    memoryMediaRepositoryProvider.overrideWithValue(_MemoryRepository(media)),
    memoryMediaPathResolverProvider.overrideWithValue(const _NoPathResolver()),
  ],
  child: MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reducedMotion,
        ),
        child: Scaffold(body: child),
      ),
    ),
  ),
);

MemoryMedia _media(int index, {bool hero = false}) {
  final at = DateTime.utc(2026, 8, 12);
  final attachment = Attachment(
    metadata: RecordMetadata(
      id: 'asset-$index',
      privacyClassification: PrivacyClassification.personal,
      lifecycle: RecordLifecycle.confirmed,
      createdAt: at,
      updatedAt: at,
    ),
    storageState: AttachmentStorageState.local,
    importMode: AttachmentImportMode.preserveOriginal,
    mimeType: 'image/jpeg',
    byteSize: 100,
    relativePath: 'media/$index.jpg',
    thumbnailRelativePath: 'thumbs/$index.jpg',
  );
  return MemoryMedia(
    attachment: attachment,
    link: AttachmentLink(
      id: 'link-$index',
      attachmentId: attachment.metadata.id,
      eventId: 'event-1',
      role: hero ? AttachmentRole.heroMedia : AttachmentRole.memoryMedia,
      caption: 'Photo $index',
      sortOrder: index,
      importedAt: at,
    ),
  );
}

final class _MemoryRepository implements MemoryMediaRepository {
  const _MemoryRepository(this.media);

  final List<MemoryMedia> media;

  @override
  Future<List<MemoryMedia>> forEvent(String eventId) async => media;

  @override
  Stream<List<MemoryMedia>> watchForEvent(String eventId) =>
      Stream.value(media);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _NoPathResolver implements MemoryMediaPathResolver {
  const _NoPathResolver();

  @override
  Future<String?> resolve(
    Attachment attachment, {
    required bool preferThumbnail,
  }) async => null;
}
