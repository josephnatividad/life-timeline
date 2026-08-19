import 'package:life_timeline/features/reminders/domain/reminder.dart';

abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchAll();
  Stream<List<Reminder>> watchForEvent(String eventId, {int? limit});
  Stream<int> watchCountForEvent(String eventId);
  Future<List<Reminder>> all();
  Future<Reminder?> byId(String id);
  Future<void> save(Reminder reminder);
  Future<void> delete(String id);
  Future<List<int>> disableForEvent(String eventId, DateTime at);
  Future<int> nextNotificationId();
}
