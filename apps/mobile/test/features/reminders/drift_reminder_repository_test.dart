import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/infrastructure/drift_reminder_repository.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Entity, Event, Reminder;
import 'package:life_timeline/shared/database/backup/drift_backup_data_source.dart';
import 'package:life_timeline/shared/database/repositories/drift_memory_candidate_repository.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

import '../../shared/database/test_record_factory.dart';

void main() {
  late AppDatabase database;
  late DriftTimelineRepository timeline;
  late DriftReminderRepository reminders;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    timeline = DriftTimelineRepository(database);
    reminders = DriftReminderRepository(database);
    await timeline.saveEvent(TestRecordFactory.event());
  });

  tearDown(() => database.close());

  test('reminder persists and notification identifiers are unique', () async {
    await reminders.save(_reminder());

    final stored = await reminders.byId('reminder-1');
    expect(stored?.linkedEventId, 'event-1');
    expect(stored?.targetDate, LocalDate(2031, 6, 12));
    expect(stored?.reminderDate, LocalDate(2031, 3, 12));
    expect(stored?.reminderTime, LocalTimeOfDay(9, 0));
    expect(stored?.type, ReminderType.expiry);
    expect(stored?.leadTime, ReminderLeadTime.ninetyDays);
    expect(stored?.status, ReminderStatus.scheduled);
    expect(
      reminders.save(_reminder(id: 'reminder-2')),
      throwsA(isA<Exception>()),
    );
  });

  test('archive preserves reminders while Trash disables them', () async {
    await reminders.save(_reminder());
    await timeline.archiveEvent('event-1', DateTime.utc(2026, 2));
    expect(
      (await reminders.byId('reminder-1'))?.status,
      ReminderStatus.scheduled,
    );

    await timeline.restoreEvent('event-1', DateTime.utc(2026, 3));
    await timeline.softDeleteEvent('event-1', DateTime.utc(2026, 4));
    expect(
      (await reminders.byId('reminder-1'))?.status,
      ReminderStatus.disabled,
    );
  });

  test('permanent memory deletion cascades dependent reminders', () async {
    await reminders.save(_reminder());
    await timeline.softDeleteEvent('event-1', DateTime.utc(2026, 4));

    await timeline.permanentlyDeleteEvent('event-1');

    expect(await reminders.byId('reminder-1'), isNull);
  });

  test('portable backup includes and restores reminder records', () async {
    await reminders.save(_reminder());
    final source = DriftBackupDataSource(database);
    final snapshot = await source.exportSnapshot();
    expect(snapshot.tables['reminders'], hasLength(1));

    await reminders.delete('reminder-1');
    await source.replaceWithSnapshot(snapshot);

    expect((await reminders.byId('reminder-1'))?.title, 'Renew passport');
  });

  test(
    'candidate confirmation persists memory and opted-in reminder atomically',
    () async {
      final candidates = DriftMemoryCandidateRepository(database);
      await timeline.saveEvidence(TestRecordFactory.evidence());
      await candidates.saveCandidate(TestRecordFactory.candidate());
      final now = TestRecordFactory.createdAt.add(const Duration(days: 1));
      final event = Event(
        metadata: RecordMetadata(
          id: 'event-from-ocr',
          privacyClassification: PrivacyClassification.personal,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: now,
          updatedAt: now,
        ),
        title: 'Warranty',
        temporalValue: TemporalValue.exactDate(year: 2027, month: 11, day: 12),
        eventType: 'warranty',
      );
      final reminder = _reminder(
        id: 'ocr-reminder',
        linkedEventId: 'event-from-ocr',
        notificationId: 2,
      );

      await candidates.confirmCandidate(
        candidateId: 'candidate-1',
        confirmedEvent: event,
        confirmedAt: now,
        reminder: reminder,
      );

      expect(await timeline.eventById('event-from-ocr'), isNotNull);
      expect((await reminders.byId('ocr-reminder'))?.sourceEvidenceId, isNull);
    },
  );
}

Reminder _reminder({
  String id = 'reminder-1',
  String linkedEventId = 'event-1',
  int notificationId = 1,
}) => Reminder(
  id: id,
  linkedEventId: linkedEventId,
  title: 'Renew passport',
  targetDate: LocalDate(2031, 6, 12),
  reminderDate: LocalDate(2031, 3, 12),
  reminderTime: LocalTimeOfDay(9, 0),
  timeZoneId: 'UTC',
  scheduledAtUtc: DateTime.utc(2031, 3, 12, 9),
  type: ReminderType.expiry,
  leadTime: ReminderLeadTime.ninetyDays,
  status: ReminderStatus.scheduled,
  notificationId: notificationId,
  privacyClassification: PrivacyClassification.personal,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
