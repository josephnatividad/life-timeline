import 'package:drift/drift.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/persistence_value_codec.dart';

abstract final class ReminderMapper {
  static db.RemindersCompanion toCompanion(Reminder reminder) =>
      db.RemindersCompanion.insert(
        id: reminder.id,
        linkedEventId: Value(reminder.linkedEventId),
        linkedEntityId: Value(reminder.linkedEntityId),
        sourceEvidenceId: Value(reminder.sourceEvidenceId),
        title: reminder.title.trim(),
        note: Value(reminder.note?.trim()),
        targetYear: reminder.targetDate.year,
        targetMonth: reminder.targetDate.month,
        targetDay: reminder.targetDate.day,
        reminderYear: reminder.reminderDate.year,
        reminderMonth: reminder.reminderDate.month,
        reminderDay: reminder.reminderDate.day,
        reminderHour: reminder.reminderTime.hour,
        reminderMinute: reminder.reminderTime.minute,
        timeZoneId: reminder.timeZoneId,
        scheduledAtUtc: reminder.scheduledAtUtc,
        reminderType: typeToStorage(reminder.type),
        leadTime: leadToStorage(reminder.leadTime),
        status: reminder.status.name,
        notificationId: reminder.notificationId,
        privacyClassification: PersistenceValueCodec.privacyToStorage(
          reminder.privacyClassification,
        ),
        createdAt: reminder.createdAt,
        updatedAt: reminder.updatedAt,
        completedAt: Value(reminder.completedAt),
        dismissedAt: Value(reminder.dismissedAt),
      );

  static String typeToStorage(ReminderType value) => switch (value) {
    ReminderType.followUp => 'follow_up',
    _ => value.name,
  };

  static String leadToStorage(ReminderLeadTime value) => switch (value) {
    ReminderLeadTime.onDay => 'on_day',
    ReminderLeadTime.oneDay => 'one_day',
    ReminderLeadTime.sevenDays => 'seven_days',
    ReminderLeadTime.thirtyDays => 'thirty_days',
    ReminderLeadTime.ninetyDays => 'ninety_days',
    ReminderLeadTime.sixMonths => 'six_months',
    ReminderLeadTime.custom => 'custom',
  };
}
