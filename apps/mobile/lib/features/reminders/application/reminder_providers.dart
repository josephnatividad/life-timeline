import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/application/notification_privacy_sanitizer.dart';
import 'package:life_timeline/features/reminders/application/reminder_scheduler.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';
import 'package:life_timeline/features/reminders/infrastructure/platform_local_notifications.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';

final deviceTimeZoneServiceProvider = Provider<DeviceTimeZoneService>((ref) {
  return PlatformDeviceTimeZoneService();
});

final reminderStoreProvider = Provider<ReminderRepository>((ref) {
  return ref.watch(reminderRepositoryProvider);
});

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return PlatformLocalNotificationService(FlutterLocalNotificationsPlugin());
});

final notificationPrivacySanitizerProvider =
    Provider<NotificationPrivacySanitizer>((ref) {
      return const DefaultNotificationPrivacySanitizer();
    });

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(
    repository: ref.watch(reminderStoreProvider),
    notifications: ref.watch(localNotificationServiceProvider),
    timeZones: ref.watch(deviceTimeZoneServiceProvider),
    privacy: ref.watch(notificationPrivacySanitizerProvider),
  );
});

final notificationPermissionProvider =
    FutureProvider<NotificationPermissionState>((ref) {
      return ref.watch(localNotificationServiceProvider).permissionState();
    });

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(reminderStoreProvider).watchAll();
});

final eventRemindersProvider = StreamProvider.family<List<Reminder>, String>((
  ref,
  eventId,
) {
  return ref.watch(reminderStoreProvider).watchForEvent(eventId);
});

final eventReminderPreviewProvider = StreamProvider.autoDispose
    .family<List<Reminder>, String>((ref, eventId) {
      return ref.watch(reminderStoreProvider).watchForEvent(eventId, limit: 2);
    });

final eventReminderCountProvider = StreamProvider.autoDispose
    .family<int, String>((ref, eventId) {
      return ref.watch(reminderStoreProvider).watchCountForEvent(eventId);
    });

final reminderProvider = FutureProvider.autoDispose.family<Reminder?, String>((
  ref,
  id,
) {
  return ref.watch(reminderStoreProvider).byId(id);
});

final pendingReminderIntentProvider =
    NotifierProvider<PendingReminderIntentController, String?>(
      PendingReminderIntentController.new,
    );

final class PendingReminderIntentController extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String reminderId) => state = reminderId;
  void clear() => state = null;
}

final reminderBootstrapProvider =
    AsyncNotifierProvider<ReminderBootstrapController, void>(
      ReminderBootstrapController.new,
    );

final class ReminderBootstrapController extends AsyncNotifier<void> {
  bool _initialized = false;

  @override
  Future<void> build() async {
    final notifications = ref.watch(localNotificationServiceProvider);
    final launchReminder = await notifications.initialize(
      onTap: (id) => ref.read(pendingReminderIntentProvider.notifier).set(id),
    );
    if (launchReminder != null) {
      ref.read(pendingReminderIntentProvider.notifier).set(launchReminder);
    }
    await ref.watch(reminderSchedulerProvider).reconcile();
    _initialized = true;
  }

  Future<void> reconcile() async {
    if (!_initialized) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(reminderSchedulerProvider).reconcile(),
    );
  }

  void reconcileUnawaited() => unawaited(reconcile());
}

extension ReminderRepositoryRef on Ref {
  ReminderRepository get reminders => read(reminderRepositoryProvider);
}
