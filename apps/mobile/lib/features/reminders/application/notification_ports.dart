import 'package:life_timeline/features/reminders/domain/reminder.dart';

enum NotificationPermissionState { granted, denied, notDetermined }

final class PendingLocalNotification {
  const PendingLocalNotification({
    required this.notificationId,
    required this.reminderId,
  });

  final int notificationId;
  final String reminderId;
}

abstract interface class LocalNotificationService {
  Future<String?> initialize({required void Function(String reminderId) onTap});
  Future<void> schedule(Reminder reminder, NotificationContent content);
  Future<void> cancel(int notificationId);
  Future<void> cancelAll();
  Future<List<PendingLocalNotification>> pending();
  Future<NotificationPermissionState> permissionState();
  Future<NotificationPermissionState> requestPermission();
}

abstract interface class DeviceTimeZoneService {
  Future<String> currentTimeZoneId();
  DateTime scheduledUtc({
    required LocalDate date,
    required LocalTimeOfDay time,
    required String timeZoneId,
  });
}

final class NotificationContent {
  const NotificationContent({required this.title, required this.body});

  final String body;
  final String title;
}
