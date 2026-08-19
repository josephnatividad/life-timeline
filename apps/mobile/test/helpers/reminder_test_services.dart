import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';

class TestLocalNotificationService implements LocalNotificationService {
  @override
  Future<void> cancel(int notificationId) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<String?> initialize({
    required void Function(String reminderId) onTap,
  }) async => null;

  @override
  Future<List<PendingLocalNotification>> pending() async => const [];

  @override
  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.granted;

  @override
  Future<NotificationPermissionState> requestPermission() async =>
      NotificationPermissionState.granted;

  @override
  Future<void> schedule(Reminder reminder, NotificationContent content) async {}
}

final class TestDeviceTimeZoneService implements DeviceTimeZoneService {
  @override
  Future<String> currentTimeZoneId() async => 'UTC';

  @override
  DateTime scheduledUtc({
    required LocalDate date,
    required LocalTimeOfDay time,
    required String timeZoneId,
  }) => DateTime.utc(date.year, date.month, date.day, time.hour, time.minute);
}

final class TestReminderRepository implements ReminderRepository {
  TestReminderRepository([Iterable<Reminder> reminders = const []])
    : _values = {for (final reminder in reminders) reminder.id: reminder};

  final Map<String, Reminder> _values;

  @override
  Future<List<Reminder>> all() async => _values.values.toList();
  @override
  Future<Reminder?> byId(String id) async => _values[id];
  @override
  Future<void> delete(String id) async => _values.remove(id);
  @override
  Future<List<int>> disableForEvent(String eventId, DateTime at) async => [];
  @override
  Future<int> nextNotificationId() async => _values.length + 1;
  @override
  Future<void> save(Reminder reminder) async => _values[reminder.id] = reminder;
  @override
  Stream<List<Reminder>> watchAll() => Stream.value(_values.values.toList());
  @override
  Stream<List<Reminder>> watchForEvent(String eventId, {int? limit}) =>
      Stream.value(
        _values.values
            .where((reminder) => reminder.linkedEventId == eventId)
            .take(limit ?? _values.length)
            .toList(),
      );

  @override
  Stream<int> watchCountForEvent(String eventId) => Stream.value(
    _values.values.where((item) => item.linkedEventId == eventId).length,
  );
}
