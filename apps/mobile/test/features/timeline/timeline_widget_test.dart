import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/app/life_timeline_app.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/timeline/application/memory_editor_draft.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/memory_detail_page.dart';
import 'package:life_timeline/features/timeline/presentation/timeline_home_page.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/memory_editor.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/temporal_input.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Category, Event;
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

import '../../helpers/reminder_test_services.dart';
import '../../helpers/security_test_controller.dart';

void main() {
  testWidgets('empty timeline explains the next action', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            UnlockedSecurityController.new,
          ),
          appDatabaseProvider.overrideWithValue(database),
          timelineMemoriesProvider.overrideWith((ref) => Stream.value([])),
          localNotificationServiceProvider.overrideWithValue(
            TestLocalNotificationService(),
          ),
          deviceTimeZoneServiceProvider.overrideWithValue(
            TestDeviceTimeZoneService(),
          ),
          reminderStoreProvider.overrideWithValue(TestReminderRepository()),
        ],
        child: const MaterialApp(home: TimelineHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your story starts here.'), findsOneWidget);
    expect(find.text('Add memory'), findsOneWidget);
  });

  testWidgets('TemporalInput exposes every supported precision', (
    tester,
  ) async {
    TemporalValue? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TemporalInput(onChanged: (next) => value = next)),
      ),
    );

    await tester.tap(find.byKey(const Key('temporal-precision')));
    await tester.pumpAndSettle();

    for (final label in [
      'Exact date',
      'Month and year',
      'Year only',
      'Approximate date',
      'Date range',
      'Before a date',
      'After a date',
      'Unknown',
    ]) {
      expect(find.text(label), findsWidgets);
    }

    await tester.tap(find.text('Unknown').last);
    await tester.pumpAndSettle();
    expect(value?.precision, TemporalPrecision.unknown);
    expect(
      find.text('No date will be invented. You can refine it later.'),
      findsOneWidget,
    );
  });

  testWidgets('Add Memory saves through the application boundary', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    String? savedId;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemoryEditor(onSaved: (id) => savedId = id),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('memory-title')), 'First car');
    await tester.enterText(find.byKey(const Key('memory-type')), 'Purchased');
    await tester.enterText(
      find.byKey(const Key('memory-category')),
      'Vehicles',
    );
    await tester.tap(find.byKey(const Key('temporal-precision')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unknown').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('privacy-personal')));
    final saveButton = find.byKey(const Key('save-memory'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(savedId, isNotNull);
    final memory = await DriftTimelineRepository(database).memoryById(savedId!);
    expect(memory?.event.title, 'First car');
    expect(memory?.event.temporalValue.precision, TemporalPrecision.unknown);
    expect(memory?.category?.name, 'Vehicles');
  });

  testWidgets('saved memory detail keeps Timeline as the back destination', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            UnlockedSecurityController.new,
          ),
          appDatabaseProvider.overrideWithValue(database),
          timelineMemoriesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const LifeTimelineApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add memory'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memory-title')),
      'First apartment',
    );
    await tester.enterText(find.byKey(const Key('memory-type')), 'Moved');
    await tester.enterText(find.byKey(const Key('memory-category')), 'Home');
    await tester.tap(find.byKey(const Key('temporal-precision')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unknown').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('privacy-personal')));
    final saveButton = find.byKey(const Key('save-memory'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await _pumpUntilFound(tester, find.text('Memory'));
    await tester.pump(AppMotion.reveal);

    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('First apartment'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.binding.handlePopRoute();
    await _pumpUntilFound(tester, find.text('Your story starts here.'));

    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Your story starts here.'), findsOneWidget);
    await tester.pump(AppMotion.reveal);
    await tester.pump(const Duration(milliseconds: 1));
    await _unmountProviderTree(tester);
  });

  testWidgets('Edit Memory persists changed controller values', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftTimelineRepository(database);
    final original = _memory();
    await repository.saveMemory(original);
    String? savedId;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemoryEditor(
                initialDraft: MemoryEditorDraft.fromMemory(original),
                onSaved: (id) => savedId = id,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('memory-title')),
      'Kyoto revisited',
    );
    tester.widget<AppButton>(find.byKey(const Key('save-memory'))).onPressed!();
    await tester.pumpAndSettle();

    expect(savedId, 'memory-1');
    expect(
      (await repository.memoryById('memory-1'))?.event.title,
      'Kyoto revisited',
    );
  });

  testWidgets('Memory Detail renders structured fields and privacy', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await DriftTimelineRepository(database).saveMemory(_memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: MemoryDetailPage(memoryId: 'memory-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trip to Kyoto'), findsOneWidget);
    expect(find.text('Around 2019'), findsOneWidget);
    expect(find.text('Travel'), findsWidgets);
    expect(find.text('Sensitive'), findsOneWidget);
    expect(find.text('No evidence attached'), findsOneWidget);
    await _unmountProviderTree(tester);
  });

  testWidgets('archive Undo remains safe after Memory Detail is unmounted', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftTimelineRepository(database);
    await repository.saveMemory(_memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            UnlockedSecurityController.new,
          ),
          appDatabaseProvider.overrideWithValue(database),
          timelineMemoriesProvider.overrideWith(
            (ref) => Stream.value([_memory()]),
          ),
          localNotificationServiceProvider.overrideWithValue(
            TestLocalNotificationService(),
          ),
          deviceTimeZoneServiceProvider.overrideWithValue(
            TestDeviceTimeZoneService(),
          ),
          reminderStoreProvider.overrideWithValue(TestReminderRepository()),
        ],
        child: const LifeTimelineApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trip to Kyoto'));
    await _pumpUntilFound(tester, find.byType(MemoryDetailPage));
    await tester.tap(find.bySemanticsLabel('Memory options'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('archive-memory')));
    await _pumpUntilFound(tester, find.text('Memory archived.'));
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(MemoryDetailPage), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(
      (await repository.memoryById('memory-1'))?.event.metadata.lifecycle,
      RecordLifecycle.confirmed,
    );
    await _unmountProviderTree(tester);
  });

  testWidgets('Timeline event opens Memory Detail', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await DriftTimelineRepository(database).saveMemory(_memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            UnlockedSecurityController.new,
          ),
          appDatabaseProvider.overrideWithValue(database),
          timelineMemoriesProvider.overrideWith(
            (ref) => Stream.value([_memory()]),
          ),
          localNotificationServiceProvider.overrideWithValue(
            TestLocalNotificationService(),
          ),
          deviceTimeZoneServiceProvider.overrideWithValue(
            TestDeviceTimeZoneService(),
          ),
          reminderStoreProvider.overrideWithValue(TestReminderRepository()),
        ],
        child: const LifeTimelineApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trip to Kyoto'));
    await tester.pumpAndSettle();

    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('No evidence attached'), findsOneWidget);
    await _unmountProviderTree(tester);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Expected destination did not appear within 3 seconds.');
}

Future<void> _unmountProviderTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

TimelineMemory _memory() {
  final at = DateTime.utc(2026, 8, 10);
  RecordMetadata metadata(String id) => RecordMetadata(
    id: id,
    privacyClassification: PrivacyClassification.sensitive,
    lifecycle: RecordLifecycle.confirmed,
    createdAt: at,
    updatedAt: at,
  );
  return TimelineMemory(
    event: Event(
      metadata: metadata('memory-1'),
      title: 'Trip to Kyoto',
      eventType: 'Travel',
      description: 'A quiet spring visit.',
      temporalValue: TemporalValue.approximate(TemporalPoint(year: 2019)),
    ),
    category: Category(metadata: metadata('category-1'), name: 'Travel'),
  );
}
