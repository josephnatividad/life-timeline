import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/application/notification_privacy_sanitizer.dart';
import 'package:life_timeline/features/reminders/application/reminder_scheduler.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

void main() {
  late _MemoryReminderRepository repository;
  late _FakeNotifications notifications;
  late _FakeTimeZones timeZones;

  setUp(() {
    repository = _MemoryReminderRepository();
    notifications = _FakeNotifications();
    timeZones = _FakeTimeZones();
  });

  test(
    'permission denial preserves reminder without platform schedule',
    () async {
      notifications.permission = NotificationPermissionState.denied;
      final scheduler = _scheduler(repository, notifications, timeZones);

      final result = await scheduler.save(_reminder());

      expect(result.notificationPermission, NotificationPermissionState.denied);
      expect(await repository.byId('reminder-1'), isNotNull);
      expect(notifications.scheduled, isEmpty);
    },
  );

  test('save and edit reschedule through the app-owned boundary', () async {
    final scheduler = _scheduler(repository, notifications, timeZones);
    final original = _reminder();
    await scheduler.save(original);
    final edited = original.copyWith(
      reminderDate: LocalDate(2031, 4, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );
    await scheduler.save(edited);

    expect(notifications.scheduled, hasLength(2));
    expect(
      (await repository.byId(original.id))?.reminderDate,
      edited.reminderDate,
    );
  });

  test('past reminder becomes missed and is cancelled', () async {
    final scheduler = _scheduler(repository, notifications, timeZones);
    final past = _reminder().copyWith(
      reminderDate: LocalDate(2025, 1, 1),
      scheduledAtUtc: DateTime.utc(2025, 1, 1, 9),
    );

    await scheduler.save(past);

    expect((await repository.byId(past.id))?.status, ReminderStatus.missed);
    expect(notifications.cancelled, contains(past.notificationId));
  });

  test(
    'notification acknowledgement is durable without completing task',
    () async {
      final scheduler = _scheduler(repository, notifications, timeZones);
      await repository.save(_reminder());

      final acknowledged = await scheduler.acknowledgeNotification(
        'reminder-1',
      );

      expect(acknowledged?.dismissedAt, DateTime.utc(2026));
      expect(acknowledged?.status, ReminderStatus.scheduled);
      expect((await repository.byId('reminder-1'))?.dismissedAt, isNotNull);
      expect(notifications.cancelled, contains(1));
    },
  );

  test(
    'reconciliation repairs missing, cancels orphan, and updates zone',
    () async {
      await repository.save(_reminder());
      notifications.pendingItems.add(
        const PendingLocalNotification(
          notificationId: 999,
          reminderId: 'orphan',
        ),
      );
      timeZones.zone = 'Asia/Manila';
      final scheduler = _scheduler(repository, notifications, timeZones);

      await scheduler.reconcile();

      expect(notifications.cancelled, contains(999));
      expect(notifications.scheduled.single.id, 'reminder-1');
      expect((await repository.byId('reminder-1'))?.timeZoneId, 'Asia/Manila');
    },
  );
}

ReminderScheduler _scheduler(
  ReminderRepository repository,
  LocalNotificationService notifications,
  DeviceTimeZoneService timeZones,
) => ReminderScheduler(
  repository: repository,
  notifications: notifications,
  timeZones: timeZones,
  privacy: const DefaultNotificationPrivacySanitizer(),
  now: () => DateTime.utc(2026),
);

Reminder _reminder() => Reminder(
  id: 'reminder-1',
  linkedEventId: 'event-1',
  title: 'Renew passport',
  targetDate: LocalDate(2031, 6, 12),
  reminderDate: LocalDate(2031, 3, 12),
  reminderTime: LocalTimeOfDay(9, 0),
  timeZoneId: 'UTC',
  scheduledAtUtc: DateTime.utc(2031, 3, 12, 9),
  type: ReminderType.expiry,
  leadTime: ReminderLeadTime.ninetyDays,
  status: ReminderStatus.scheduled,
  notificationId: 1,
  privacyClassification: PrivacyClassification.personal,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

final class _MemoryReminderRepository implements ReminderRepository {
  final values = <String, Reminder>{};
  final controller = StreamController<List<Reminder>>.broadcast();

  @override
  Future<List<Reminder>> all() async => values.values.toList();
  @override
  Future<Reminder?> byId(String id) async => values[id];
  @override
  Future<void> delete(String id) async => values.remove(id);
  @override
  Future<List<int>> disableForEvent(String eventId, DateTime at) async => [];
  @override
  Future<int> nextNotificationId() async => values.length + 1;
  @override
  Future<void> save(Reminder reminder) async => values[reminder.id] = reminder;
  @override
  Stream<List<Reminder>> watchAll() => controller.stream;
  @override
  Stream<List<Reminder>> watchForEvent(String eventId, {int? limit}) =>
      controller.stream.map(
        (values) => values.take(limit ?? values.length).toList(),
      );

  @override
  Stream<int> watchCountForEvent(String eventId) => controller.stream.map(
    (values) => values.where((item) => item.linkedEventId == eventId).length,
  );
}

final class _FakeNotifications implements LocalNotificationService {
  NotificationPermissionState permission = NotificationPermissionState.granted;
  final scheduled = <Reminder>[];
  final cancelled = <int>[];
  final pendingItems = <PendingLocalNotification>[];

  @override
  Future<void> cancel(int notificationId) async =>
      cancelled.add(notificationId);
  @override
  Future<void> cancelAll() async => pendingItems.clear();
  @override
  Future<String?> initialize({
    required void Function(String reminderId) onTap,
  }) async => null;
  @override
  Future<List<PendingLocalNotification>> pending() async => pendingItems;
  @override
  Future<NotificationPermissionState> permissionState() async => permission;
  @override
  Future<NotificationPermissionState> requestPermission() async => permission;
  @override
  Future<void> schedule(Reminder reminder, NotificationContent content) async {
    scheduled.add(reminder);
  }
}

final class _FakeTimeZones implements DeviceTimeZoneService {
  String zone = 'UTC';

  @override
  Future<String> currentTimeZoneId() async => zone;

  @override
  DateTime scheduledUtc({
    required LocalDate date,
    required LocalTimeOfDay time,
    required String timeZoneId,
  }) => DateTime.utc(date.year, date.month, date.day, time.hour, time.minute);
}
