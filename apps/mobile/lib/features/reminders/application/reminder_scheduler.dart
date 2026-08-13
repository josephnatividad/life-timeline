// ignore_for_file: prefer_initializing_formals

import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/application/notification_privacy_sanitizer.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';

final class ReminderSaveResult {
  const ReminderSaveResult({
    required this.reminder,
    required this.notificationPermission,
  });

  final NotificationPermissionState notificationPermission;
  final Reminder reminder;
}

final class ReminderScheduler {
  const ReminderScheduler({
    required ReminderRepository repository,
    required LocalNotificationService notifications,
    required DeviceTimeZoneService timeZones,
    required NotificationPrivacySanitizer privacy,
    DateTime Function()? now,
  }) : _repository = repository,
       _notifications = notifications,
       _timeZones = timeZones,
       _privacy = privacy,
       _now = now ?? DateTime.now;

  final LocalNotificationService _notifications;
  final DateTime Function() _now;
  final NotificationPrivacySanitizer _privacy;
  final ReminderRepository _repository;
  final DeviceTimeZoneService _timeZones;

  Future<ReminderSaveResult> save(Reminder reminder) async {
    final normalized = await _normalize(reminder);
    await _repository.save(normalized);
    final permission = await _notifications.permissionState();
    if (normalized.status == ReminderStatus.scheduled &&
        permission == NotificationPermissionState.granted) {
      await _notifications.schedule(normalized, _privacy.sanitize(normalized));
    } else {
      await _notifications.cancel(normalized.notificationId);
    }
    return ReminderSaveResult(
      reminder: normalized,
      notificationPermission: permission,
    );
  }

  Future<Reminder> _normalize(Reminder reminder) async {
    final zone = await _timeZones.currentTimeZoneId();
    final scheduled = _timeZones.scheduledUtc(
      date: reminder.reminderDate,
      time: reminder.reminderTime,
      timeZoneId: zone,
    );
    final status =
        reminder.status == ReminderStatus.scheduled &&
            !scheduled.isAfter(_now().toUtc())
        ? ReminderStatus.missed
        : reminder.status;
    return reminder.copyWith(
      timeZoneId: zone,
      scheduledAtUtc: scheduled,
      status: status,
      updatedAt: _now().toUtc(),
    );
  }

  Future<void> setEnabled(Reminder reminder, bool enabled) async {
    await save(
      reminder.copyWith(
        status: enabled ? ReminderStatus.scheduled : ReminderStatus.disabled,
        clearCompletedAt: enabled,
      ),
    );
  }

  Future<void> delete(Reminder reminder) async {
    await _repository.delete(reminder.id);
    await _notifications.cancel(reminder.notificationId);
  }

  /// Records that the user opened the delivered notification.
  ///
  /// Opening is intentionally distinct from completing the underlying task.
  /// The persisted acknowledgement prevents an elapsed, user-opened reminder
  /// from being presented as though it was ignored.
  Future<Reminder?> acknowledgeNotification(String reminderId) async {
    final reminder = await _repository.byId(reminderId);
    if (reminder == null) return null;
    final acknowledgedAt = _now().toUtc();
    final acknowledged = reminder.copyWith(
      dismissedAt: acknowledgedAt,
      updatedAt: acknowledgedAt,
    );
    await _repository.save(acknowledged);
    await _notifications.cancel(acknowledged.notificationId);
    return acknowledged;
  }

  Future<NotificationPermissionState> requestPermission() async {
    final state = await _notifications.requestPermission();
    if (state == NotificationPermissionState.granted) {
      await reconcile();
    }
    return state;
  }

  Future<void> reconcile() => ReminderSchedulerReconciler(
    repository: _repository,
    notifications: _notifications,
    timeZones: _timeZones,
    privacy: _privacy,
    now: _now,
  ).reconcile();
}

final class ReminderSchedulerReconciler {
  const ReminderSchedulerReconciler({
    required ReminderRepository repository,
    required LocalNotificationService notifications,
    required DeviceTimeZoneService timeZones,
    required NotificationPrivacySanitizer privacy,
    DateTime Function()? now,
    this.pendingLimit = 60,
  }) : _repository = repository,
       _notifications = notifications,
       _timeZones = timeZones,
       _privacy = privacy,
       _now = now ?? DateTime.now;

  final LocalNotificationService _notifications;
  final DateTime Function() _now;
  final int pendingLimit;
  final NotificationPrivacySanitizer _privacy;
  final ReminderRepository _repository;
  final DeviceTimeZoneService _timeZones;

  Future<void> reconcile() async {
    final reminders = await _repository.all();
    final pending = await _notifications.pending();
    final pendingByReminder = {
      for (final item in pending) item.reminderId: item,
    };
    final currentZone = await _timeZones.currentTimeZoneId();
    final now = _now().toUtc();
    final eligible = <Reminder>[];

    for (final reminder in reminders) {
      final scheduled = _timeZones.scheduledUtc(
        date: reminder.reminderDate,
        time: reminder.reminderTime,
        timeZoneId: currentZone,
      );
      if (reminder.status == ReminderStatus.scheduled &&
          !scheduled.isAfter(now)) {
        await _repository.save(
          reminder.copyWith(
            status: ReminderStatus.missed,
            scheduledAtUtc: scheduled,
            timeZoneId: currentZone,
            updatedAt: now,
          ),
        );
        continue;
      }
      if (reminder.status == ReminderStatus.scheduled) {
        final adjusted = reminder.copyWith(
          scheduledAtUtc: scheduled,
          timeZoneId: currentZone,
          updatedAt: reminder.timeZoneId == currentZone
              ? reminder.updatedAt
              : now,
        );
        if (adjusted.timeZoneId != reminder.timeZoneId ||
            adjusted.scheduledAtUtc != reminder.scheduledAtUtc) {
          await _repository.save(adjusted);
        }
        eligible.add(adjusted);
      }
    }

    eligible.sort((a, b) => a.scheduledAtUtc.compareTo(b.scheduledAtUtc));
    final selected = eligible.take(pendingLimit).toList(growable: false);
    final selectedIds = {for (final reminder in selected) reminder.id};
    for (final item in pending) {
      if (!selectedIds.contains(item.reminderId)) {
        await _notifications.cancel(item.notificationId);
      }
    }

    if (await _notifications.permissionState() !=
        NotificationPermissionState.granted) {
      return;
    }
    for (final reminder in selected) {
      final platform = pendingByReminder[reminder.id];
      if (platform == null ||
          platform.notificationId != reminder.notificationId) {
        if (platform != null) {
          await _notifications.cancel(platform.notificationId);
        }
        await _notifications.schedule(reminder, _privacy.sanitize(reminder));
      }
    }
  }
}
