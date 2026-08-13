// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/tables/timeline_tables.dart';

@TableIndex(
  name: 'reminders_status_schedule_idx',
  columns: {#status, #scheduledAtUtc},
)
@TableIndex(name: 'reminders_event_idx', columns: {#linkedEventId})
@TableIndex(name: 'reminders_entity_idx', columns: {#linkedEntityId})
@TableIndex(name: 'reminders_evidence_idx', columns: {#sourceEvidenceId})
@TableIndex(
  name: 'reminders_notification_id_idx',
  columns: {#notificationId},
  unique: true,
)
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get linkedEventId =>
      text().nullable().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get linkedEntityId => text().nullable().references(
    Entities,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get sourceEvidenceId => text().nullable().references(
    EvidenceRecords,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  IntColumn get targetYear => integer()();
  IntColumn get targetMonth => integer()();
  IntColumn get targetDay => integer()();
  IntColumn get reminderYear => integer()();
  IntColumn get reminderMonth => integer()();
  IntColumn get reminderDay => integer()();
  IntColumn get reminderHour => integer()();
  IntColumn get reminderMinute => integer()();
  TextColumn get timeZoneId => text()();
  DateTimeColumn get scheduledAtUtc => dateTime()();
  TextColumn get reminderType => text().check(
    reminderType.isIn(const [
      'expiry',
      'renewal',
      'warranty',
      'anniversary',
      'follow_up',
      'custom',
    ]),
  )();
  TextColumn get leadTime => text().check(
    leadTime.isIn(const [
      'on_day',
      'one_day',
      'seven_days',
      'thirty_days',
      'ninety_days',
      'six_months',
      'custom',
    ]),
  )();
  TextColumn get status => text().check(
    status.isIn(const [
      'scheduled',
      'disabled',
      'completed',
      'missed',
      'cancelled',
    ]),
  )();
  IntColumn get notificationId =>
      integer().check(notificationId.isBiggerThanValue(0))();
  TextColumn get privacyClassification => text().check(
    privacyClassification.isIn(const [
      'share_safe',
      'personal',
      'sensitive',
      'never_share',
    ]),
  )();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get dismissedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(title)) > 0)',
    'CHECK (length(trim(time_zone_id)) > 0)',
    'CHECK (target_month BETWEEN 1 AND 12 AND target_day BETWEEN 1 AND 31)',
    'CHECK (reminder_month BETWEEN 1 AND 12 AND reminder_day BETWEEN 1 AND 31)',
    'CHECK (reminder_hour BETWEEN 0 AND 23 AND reminder_minute BETWEEN 0 AND 59)',
    "CHECK ((status = 'completed') = (completed_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
  ];
}
