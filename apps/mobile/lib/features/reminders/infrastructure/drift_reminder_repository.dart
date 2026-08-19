import 'package:drift/drift.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/persistence_value_codec.dart';
import 'package:life_timeline/shared/database/mappers/reminder_mapper.dart';

final class DriftReminderRepository implements ReminderRepository {
  const DriftReminderRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<Reminder>> watchAll() =>
      (_database.select(_database.reminders)
            ..orderBy([(row) => OrderingTerm.asc(row.scheduledAtUtc)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Stream<List<Reminder>> watchForEvent(String eventId, {int? limit}) {
    if (limit != null && limit <= 0) {
      throw ArgumentError.value(limit, 'limit');
    }
    final query = _database.select(_database.reminders)
      ..where((row) => row.linkedEventId.equals(eventId))
      ..orderBy([(row) => OrderingTerm.asc(row.scheduledAtUtc)]);
    if (limit != null) query.limit(limit);
    return query.watch().map(
      (rows) => rows.map(_fromRow).toList(growable: false),
    );
  }

  @override
  Stream<int> watchCountForEvent(String eventId) {
    final count = _database.reminders.id.count();
    final query = _database.selectOnly(_database.reminders)
      ..addColumns([count])
      ..where(_database.reminders.linkedEventId.equals(eventId));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  @override
  Future<List<Reminder>> all() async =>
      (await _database.select(_database.reminders).get())
          .map(_fromRow)
          .toList(growable: false);

  @override
  Future<Reminder?> byId(String id) async {
    final row = await (_database.select(
      _database.reminders,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> save(Reminder reminder) => _database
      .into(_database.reminders)
      .insertOnConflictUpdate(ReminderMapper.toCompanion(reminder));

  @override
  Future<void> delete(String id) => (_database.delete(
    _database.reminders,
  )..where((row) => row.id.equals(id))).go();

  @override
  Future<List<int>> disableForEvent(String eventId, DateTime at) =>
      _database.transaction(() async {
        final active =
            await (_database.select(_database.reminders)..where(
                  (row) =>
                      row.linkedEventId.equals(eventId) &
                      row.status.equals('scheduled'),
                ))
                .get();
        if (active.isNotEmpty) {
          await (_database.update(
            _database.reminders,
          )..where((row) => row.linkedEventId.equals(eventId))).write(
            db.RemindersCompanion(
              status: const Value('disabled'),
              updatedAt: Value(at.toUtc()),
            ),
          );
        }
        return [for (final row in active) row.notificationId];
      });

  @override
  Future<int> nextNotificationId() async {
    final row = await _database
        .customSelect(
          'SELECT COALESCE(MAX(notification_id), 0) + 1 AS next_id FROM reminders',
        )
        .getSingle();
    final value = row.read<int>('next_id');
    return value <= 0 || value > 0x7fffffff ? 1 : value;
  }

  Reminder _fromRow(db.Reminder row) => Reminder(
    id: row.id,
    linkedEventId: row.linkedEventId,
    linkedEntityId: row.linkedEntityId,
    sourceEvidenceId: row.sourceEvidenceId,
    title: row.title,
    note: row.note,
    targetDate: LocalDate(row.targetYear, row.targetMonth, row.targetDay),
    reminderDate: LocalDate(
      row.reminderYear,
      row.reminderMonth,
      row.reminderDay,
    ),
    reminderTime: LocalTimeOfDay(row.reminderHour, row.reminderMinute),
    timeZoneId: row.timeZoneId,
    scheduledAtUtc: row.scheduledAtUtc,
    type: _typeFromStorage(row.reminderType),
    leadTime: _leadFromStorage(row.leadTime),
    status: _statusFromStorage(row.status),
    notificationId: row.notificationId,
    privacyClassification: PersistenceValueCodec.privacyFromStorage(
      row.privacyClassification,
    ),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    completedAt: row.completedAt,
    dismissedAt: row.dismissedAt,
  );

  static ReminderType _typeFromStorage(String value) => switch (value) {
    'follow_up' => ReminderType.followUp,
    _ => ReminderType.values.byName(value),
  };
  static ReminderStatus _statusFromStorage(String value) =>
      ReminderStatus.values.byName(value);
  static ReminderLeadTime _leadFromStorage(String value) => switch (value) {
    'on_day' => ReminderLeadTime.onDay,
    'one_day' => ReminderLeadTime.oneDay,
    'seven_days' => ReminderLeadTime.sevenDays,
    'thirty_days' => ReminderLeadTime.thirtyDays,
    'ninety_days' => ReminderLeadTime.ninetyDays,
    'six_months' => ReminderLeadTime.sixMonths,
    'custom' => ReminderLeadTime.custom,
    _ => throw FormatException('Unknown reminder lead time: $value'),
  };
}
