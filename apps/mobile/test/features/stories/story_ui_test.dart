import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/presentation/stories_home_page.dart';
import 'package:life_timeline/features/stories/presentation/story_editor_page.dart';
import 'package:life_timeline/features/stories/presentation/story_preview_page.dart';
import 'package:life_timeline/features/stories/presentation/then_now_selection_page.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  testWidgets('Stories home has milestones, memories, entities, and pairing', (
    tester,
  ) async {
    final memories = [
      _memory('event-1', 'First phone', 2018),
      _memory('event-2', 'Current phone', 2026),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timelineMemoryPreviewProvider(
            6,
          ).overrideWith((ref) => Stream.value(memories)),
          timelineMemoryCountProvider.overrideWith(
            (ref) => Stream.value(memories.length),
          ),
          milestoneCandidatesProvider.overrideWithValue(
            AsyncData([
              MilestoneCandidate(
                id: 'milestone-1',
                type: MilestoneType.anniversary,
                headline: 'About 5 years ago',
                detail: 'First phone',
                sourceRecordIds: const ['event-1'],
                privacyClassification: PrivacyClassification.shareSafe,
              ),
            ]),
          ),
          storyTemporaryCleanupProvider.overrideWith((ref) async {}),
        ],
        child: const _TestApp(child: StoriesHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Share a moment, not your timeline'), findsOneWidget);
    expect(find.text('For you'), findsOneWidget);
    expect(find.text('About 5 years ago'), findsOneWidget);
    expect(find.byKey(const Key('create-then-now')), findsOneWidget);
    await _reveal(tester, find.text('Recent memories'));
    expect(find.text('First phone'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stories home has a deliberate low-data state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timelineMemoryPreviewProvider(
            6,
          ).overrideWith((ref) => Stream.value([])),
          timelineMemoryCountProvider.overrideWith((ref) => Stream.value(0)),
          storyTemporaryCleanupProvider.overrideWith((ref) async {}),
        ],
        child: const _TestApp(child: StoriesHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your first Story begins with a memory'), findsOneWidget);
  });

  testWidgets('Stories root remains bounded with 100 source memories', (
    tester,
  ) async {
    final preview = List.generate(
      6,
      (index) => _memory('event-$index', 'Memory $index', 2020 + index),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timelineMemoryPreviewProvider(
            6,
          ).overrideWith((ref) => Stream.value(preview)),
          timelineMemoryCountProvider.overrideWith((ref) => Stream.value(100)),
          milestoneCandidatesProvider.overrideWithValue(const AsyncData([])),
          storyTemporaryCleanupProvider.overrideWith((ref) async {}),
        ],
        child: const _TestApp(child: StoriesHomePage()),
      ),
    );
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Recent memories'));

    expect(find.text('100'), findsOneWidget);
    expect(find.text('Memory 0'), findsOneWidget);
    expect(find.text('Memory 2'), findsOneWidget);
    expect(find.text('Memory 3'), findsNothing);
    expect(find.text('Choose another memory'), findsOneWidget);
  });

  testWidgets(
    'editor exposes templates while never-share has no selectable control',
    (tester) async {
      final source = _source();
      await tester.pumpWidget(
        ProviderScope(
          child: _TestApp(
            dark: true,
            reducedMotion: true,
            textScaler: const TextScaler.linear(1.6),
            child: StoryEditorPage(source: source),
          ),
        ),
      );
      await tester.pump();

      await _reveal(tester, find.byKey(const Key('story-template-minimal')));
      expect(find.byKey(const Key('story-template-minimal')), findsOneWidget);
      expect(find.byKey(const Key('story-template-photo')), findsOneWidget);
      await _reveal(tester, find.byKey(const Key('story-field-personal')));
      expect(find.byKey(const Key('story-field-never')), findsNothing);
      expect(find.text('Private by default'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview renders, reviews privacy, shares, and cleans locally', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final files = _CapturingTemporaryFiles();
    final share = _RecordingShareService();
    final composition = StoryComposition(
      sourceId: 'event:event-1',
      sourceType: StorySourceType.event,
      templateId: StoryTemplateId.minimal,
      themeVariant: StoryThemeVariant.midnight,
      branding: const StoryBrandingConfig(),
      sourceRecordIds: const ['event-1'],
      fields: [
        StoryField(
          id: 'event.title',
          label: 'Memory title',
          value: 'A share-safe memory',
          kind: StoryFieldKind.title,
          privacyClassification: PrivacyClassification.shareSafe,
        ),
      ],
      media: const [],
      excludedFields: const [
        StoryExcludedField(
          id: 'never',
          label: 'Booking information',
          privacyClassification: PrivacyClassification.neverShare,
          reason: StoryExclusionReason.protectedAlways,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storyTemporaryFileStoreProvider.overrideWithValue(files),
          storyShareServiceProvider.overrideWithValue(share),
        ],
        child: _TestApp(
          dark: true,
          reducedMotion: true,
          child: StoryPreviewPage(
            composition: composition,
            imageRenderer: const _PngHeaderRenderer(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A share-safe memory'), findsWidgets);
    await _reveal(tester, find.text('Booking information'));
    expect(find.text('Booking information'), findsOneWidget);
    expect(find.text('BOOKING-SECRET'), findsNothing);
    await _reveal(tester, find.byKey(const Key('share-story')));
    await tester.tap(find.byKey(const Key('share-story')));
    await tester.pumpAndSettle();

    expect(share.calls, 1);
    expect(files.deleted, isTrue);
    expect(files.bytes, isNotNull);
    expect(_pngDimensions(files.bytes!), (width: 1080, height: 1920));
    expect(find.byKey(const Key('story-export-result')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Then & Now selection prevents choosing the same record', (
    tester,
  ) async {
    final memories = [
      _memory('event-1', 'Then memory', 2018),
      _memory('event-2', 'Now memory', 2026),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timelineMemoriesProvider.overrideWith(
            (ref) => Stream.value(memories),
          ),
        ],
        child: const _TestApp(child: ThenNowSelectionPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('then-event-1')));
    await tester.pump();
    final duplicateNow = tester.widget<ListTile>(
      find.descendant(
        of: find.byKey(const Key('now-event-1')),
        matching: find.byType(ListTile),
      ),
    );
    expect(duplicateNow.enabled, isFalse);
  });
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 16 && target.evaluate().isEmpty; attempt++) {
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -260));
    await tester.pump();
  }
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
  await tester.pump();
}

TimelineMemory _memory(String id, String title, int year) {
  final entity = Entity(
    metadata: _metadata('entity-$id'),
    name: '$title entity',
    entityType: 'phone',
  );
  return TimelineMemory(
    event: Event(
      metadata: _metadata(id),
      title: title,
      temporalValue: TemporalValue.year(year),
      eventType: 'Purchased',
    ),
    relatedEntity: entity,
  );
}

StorySource _source() => StorySource(
  id: 'event:event-1',
  sourceType: StorySourceType.event,
  title: 'Local title',
  sourceRecordIds: const ['event-1'],
  fields: [
    StoryField(
      id: 'safe',
      label: 'Country',
      value: 'Japan',
      kind: StoryFieldKind.location,
      privacyClassification: PrivacyClassification.shareSafe,
      suggestedByDefault: true,
    ),
    StoryField(
      id: 'personal',
      label: 'Detailed date',
      value: 'August 11, 2026',
      kind: StoryFieldKind.date,
      privacyClassification: PrivacyClassification.personal,
    ),
    StoryField(
      id: 'never',
      label: 'Booking information',
      value: 'BOOKING-SECRET',
      kind: StoryFieldKind.detail,
      privacyClassification: PrivacyClassification.neverShare,
    ),
  ],
);

RecordMetadata _metadata(String id) => RecordMetadata(
  id: id,
  privacyClassification: PrivacyClassification.shareSafe,
  lifecycle: RecordLifecycle.confirmed,
  createdAt: DateTime.utc(2020),
  updatedAt: DateTime.utc(2020),
);

final class _CapturingTemporaryFiles implements StoryTemporaryFileStore {
  Uint8List? bytes;
  var deleted = false;

  @override
  Future<void> cleanupStaleFiles(DateTime now) async {}

  @override
  Future<void> delete(TemporaryStoryFile file) async => deleted = true;

  @override
  Future<TemporaryStoryFile> writePng(Uint8List pngBytes) async {
    bytes = pngBytes;
    return const TemporaryStoryFile(path: 'captured-story.png');
  }
}

final class _RecordingShareService implements StoryShareService {
  var calls = 0;

  @override
  Future<StoryShareOutcome> sharePng(
    TemporaryStoryFile file, {
    required String shareTitle,
  }) async {
    calls++;
    return StoryShareOutcome.shared;
  }
}

final class _PngHeaderRenderer implements StoryImageRenderer {
  const _PngHeaderRenderer();

  @override
  Future<Uint8List> render(
    StoryComposition composition,
    StoryRenderConfig config,
  ) async {
    final bytes = Uint8List(24);
    bytes.setAll(0, const [137, 80, 78, 71, 13, 10, 26, 10]);
    final data = ByteData.sublistView(bytes);
    data
      ..setUint32(16, config.outputWidth, Endian.big)
      ..setUint32(20, config.outputHeight, Endian.big);
    return bytes;
  }
}

final class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.dark = false,
    this.reducedMotion = false,
    this.textScaler,
  });

  final Widget child;
  final bool dark;
  final bool reducedMotion;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: reducedMotion, textScaler: textScaler),
        child: child,
      ),
    ),
  );
}

({int width, int height}) _pngDimensions(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
  );
}
