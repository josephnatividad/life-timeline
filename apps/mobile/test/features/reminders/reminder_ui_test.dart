import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/design_system/theme/app_theme.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';
import 'package:life_timeline/features/reminders/presentation/reminder_editor_page.dart';
import 'package:life_timeline/features/reminders/presentation/reminders_page.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

import '../../helpers/reminder_test_services.dart';

void main() {
  testWidgets('list communicates upcoming and inactive states with text', (
    tester,
  ) async {
    final repository = _UiReminderRepository([
      _reminder('upcoming', ReminderStatus.scheduled),
      _reminder('disabled', ReminderStatus.disabled),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderStoreProvider.overrideWithValue(repository),
          localNotificationServiceProvider.overrideWithValue(
            TestLocalNotificationService(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const RemindersPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past / inactive'), findsOneWidget);
    expect(find.textContaining('Scheduled'), findsOneWidget);
    expect(find.textContaining('Notifications off'), findsOneWidget);
  });

  testWidgets('editor presets remain usable in dark mode and large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.6),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: const ProviderScope(child: ReminderEditorPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Your timeline quietly remembers for you.'),
      findsOneWidget,
    );
    expect(find.text('On the day'), findsOneWidget);
    expect(find.text('1 week before'), findsOneWidget);
    expect(find.byKey(const Key('save-reminder')), findsOneWidget);
  });

  testWidgets(
    'reopening an edited reminder reloads its saved schedule settings',
    (tester) async {
      final repository = _UiReminderRepository([
        _reminder('persisted', ReminderStatus.scheduled),
      ]);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => context.push('/edit'),
                  child: const Text('Open reminder'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/edit',
            builder: (context, state) =>
                const ReminderEditorPage(reminderId: 'persisted'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reminderStoreProvider.overrideWithValue(repository),
            localNotificationServiceProvider.overrideWithValue(
              TestLocalNotificationService(),
            ),
            deviceTimeZoneServiceProvider.overrideWithValue(
              TestDeviceTimeZoneService(),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Open reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30 days before'));
      await tester.ensureVisible(find.byKey(const Key('reminder-enabled')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reminder-enabled')));
      await tester.ensureVisible(find.byKey(const Key('save-reminder')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-reminder')));
      await tester.pumpAndSettle();

      expect(find.textContaining('hours and'), findsOneWidget);
      expect(repository.values.single.leadTime, ReminderLeadTime.thirtyDays);
      expect(repository.values.single.status, ReminderStatus.disabled);

      await tester.tap(find.text('Open reminder'));
      await tester.pumpAndSettle();

      final thirtyDaysChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('30 days before'),
          matching: find.byType(FilterChip),
        ),
      );
      final enabledSwitch = tester.widget<SwitchListTile>(
        find.byKey(const Key('reminder-enabled')),
      );
      expect(thirtyDaysChip.selected, isTrue);
      expect(enabledSwitch.value, isFalse);
    },
  );
}

Reminder _reminder(String id, ReminderStatus status) => Reminder(
  id: id,
  title: id == 'upcoming' ? 'Passport renewal' : 'Warranty follow-up',
  targetDate: LocalDate(2031, 6, 12),
  reminderDate: LocalDate(2031, 3, 12),
  reminderTime: LocalTimeOfDay(9, 0),
  timeZoneId: 'UTC',
  scheduledAtUtc: DateTime.utc(2031, 3, 12, 9),
  type: ReminderType.expiry,
  leadTime: ReminderLeadTime.ninetyDays,
  status: status,
  notificationId: id == 'upcoming' ? 1 : 2,
  privacyClassification: PrivacyClassification.personal,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

final class _UiReminderRepository implements ReminderRepository {
  _UiReminderRepository(this.values);
  final List<Reminder> values;

  @override
  Future<List<Reminder>> all() async => values;
  @override
  Future<Reminder?> byId(String id) async =>
      values.where((item) => item.id == id).firstOrNull;
  @override
  Future<void> delete(String id) async =>
      values.removeWhere((item) => item.id == id);
  @override
  Future<List<int>> disableForEvent(String eventId, DateTime at) async => [];
  @override
  Future<int> nextNotificationId() async => values.length + 1;
  @override
  Future<void> save(Reminder reminder) async {
    values.removeWhere((item) => item.id == reminder.id);
    values.add(reminder);
  }

  @override
  Stream<List<Reminder>> watchAll() => Stream.value(values);
  @override
  Stream<List<Reminder>> watchForEvent(String eventId, {int? limit}) =>
      Stream.value(
        values
            .where((item) => item.linkedEventId == eventId)
            .take(limit ?? values.length)
            .toList(),
      );

  @override
  Stream<int> watchCountForEvent(String eventId) => Stream.value(
    values.where((item) => item.linkedEventId == eventId).length,
  );
}
