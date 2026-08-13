import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final class PlatformDeviceTimeZoneService implements DeviceTimeZoneService {
  PlatformDeviceTimeZoneService() {
    tz_data.initializeTimeZones();
  }

  @override
  Future<String> currentTimeZoneId() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;

  @override
  DateTime scheduledUtc({
    required LocalDate date,
    required LocalTimeOfDay time,
    required String timeZoneId,
  }) => tz.TZDateTime(
    tz.getLocation(timeZoneId),
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  ).toUtc();
}

final class PlatformLocalNotificationService
    implements LocalNotificationService {
  PlatformLocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'timeline_reminders';
  static const _payloadPrefix = 'reminder:';

  @override
  Future<String?> initialize({
    required void Function(String reminderId) onTap,
  }) async {
    if (!_initialized) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final id = _reminderId(response.payload);
          if (id != null) onTap(id);
        },
      );
      _initialized = true;
    }
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? _reminderId(launch?.notificationResponse?.payload)
        : null;
  }

  @override
  Future<void> schedule(Reminder reminder, NotificationContent content) async {
    final location = tz.getLocation(reminder.timeZoneId);
    final scheduled = tz.TZDateTime(
      location,
      reminder.reminderDate.year,
      reminder.reminderDate.month,
      reminder.reminderDate.day,
      reminder.reminderTime.hour,
      reminder.reminderTime.minute,
    );
    await _plugin.zonedSchedule(
      id: reminder.notificationId,
      title: content.title,
      body: content.body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Timeline reminders',
          channelDescription: 'Private reminders saved in your timeline',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          visibility: NotificationVisibility.private,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '$_payloadPrefix${reminder.id}',
    );
  }

  @override
  Future<void> cancel(int notificationId) => _plugin.cancel(id: notificationId);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<List<PendingLocalNotification>> pending() async => [
    for (final request in await _plugin.pendingNotificationRequests())
      if (_reminderId(request.payload) case final reminderId?)
        PendingLocalNotification(
          notificationId: request.id,
          reminderId: reminderId,
        ),
  ];

  @override
  Future<NotificationPermissionState> permissionState() async {
    if (kIsWeb) return NotificationPermissionState.denied;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return enabled == null
          ? NotificationPermissionState.notDetermined
          : enabled
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final permissions = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return permissions == null
          ? NotificationPermissionState.notDetermined
          : permissions.isEnabled
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    return NotificationPermissionState.denied;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    bool? granted;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    return granted == true
        ? NotificationPermissionState.granted
        : granted == false
        ? NotificationPermissionState.denied
        : NotificationPermissionState.notDetermined;
  }

  static String? _reminderId(String? payload) {
    if (payload == null || !payload.startsWith(_payloadPrefix)) return null;
    final value = payload.substring(_payloadPrefix.length).trim();
    return value.isEmpty ? null : value;
  }
}
