import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/private_intelligence/application/confirm_candidate_use_case.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/features/reminders/application/notification_privacy_sanitizer.dart';
import 'package:life_timeline/features/reminders/application/reminder_policy.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

void main() {
  test('exact dates remain schedulable without precision coercion', () {
    final date = ReminderPolicy.exactDate(
      TemporalValue.exactDate(year: 2031, month: 6, day: 12),
    );
    expect(date, LocalDate(2031, 6, 12));
  });

  test('month, approximate, and unknown dates are rejected', () {
    for (final value in [
      TemporalValue.month(year: 2031, month: 6),
      TemporalValue.approximate(TemporalPoint(year: 2031, month: 6)),
      TemporalValue.unknown(),
    ]) {
      expect(
        () => ReminderPolicy.exactDate(value),
        throwsA(isA<ReminderDateUnavailable>()),
      );
    }
  });

  test('six-month preset uses calendar arithmetic at month boundaries', () {
    expect(
      ReminderPolicy.dateFor(
        LocalDate(2032, 8, 31),
        ReminderLeadTime.sixMonths,
      ),
      LocalDate(2032, 2, 29),
    );
  });

  test('anniversary helper creates one explicit next occurrence', () {
    expect(
      ReminderPolicy.nextAnniversary(
        LocalDate(2016, 6, 14),
        LocalDate(2026, 8, 13),
      ),
      LocalDate(2027, 6, 14),
    );
    expect(
      ReminderPolicy.nextAnniversary(
        LocalDate(2016, 2, 29),
        LocalDate(2027, 1, 1),
      ),
      LocalDate(2027, 2, 28),
    );
  });

  test('sensitive notification content is generic and excludes note', () {
    final reminder = _reminder(
      privacy: PrivacyClassification.neverShare,
      title: 'Passport 123456789',
      note: 'OCR secret and home address',
    );
    final content = const DefaultNotificationPrivacySanitizer().sanitize(
      reminder,
    );

    expect(content.body, 'A private timeline reminder is coming up.');
    expect(content.body, isNot(contains('123456789')));
    expect(content.body, isNot(contains('OCR')));
  });

  test('personal notification titles with identifiers are also redacted', () {
    final content = const DefaultNotificationPrivacySanitizer().sanitize(
      _reminder(
        privacy: PrivacyClassification.personal,
        title: 'Passport 123456789',
      ),
    );

    expect(content.body, 'A timeline reminder is coming up.');
    expect(content.body, isNot(contains('123456789')));
  });

  test('OCR reminder suggestions require a reliable exact expiry field', () {
    final valid = CandidateReminderSuggestion.from(DocumentType.warranty, [
      ExtractedField(
        id: 'field-1',
        key: 'warrantyExpiry',
        value: '2027-11-12',
        valueType: ExtractedValueType.date,
        confidence: 0.92,
        privacyClassification: PrivacyClassification.personal,
        extractionMethod: 'ocr',
      ),
    ]);
    final imprecise = CandidateReminderSuggestion.from(DocumentType.warranty, [
      ExtractedField(
        id: 'field-2',
        key: 'warrantyExpiry',
        value: '2027-11',
        valueType: ExtractedValueType.date,
        confidence: 0.92,
        privacyClassification: PrivacyClassification.personal,
        extractionMethod: 'ocr',
      ),
    ]);

    expect(valid?.targetDate, LocalDate(2027, 11, 12));
    expect(valid?.leadTime, ReminderLeadTime.thirtyDays);
    expect(imprecise, isNull);
  });
}

Reminder _reminder({
  required PrivacyClassification privacy,
  required String title,
  String? note,
}) => Reminder(
  id: 'reminder-1',
  title: title,
  note: note,
  targetDate: LocalDate(2031, 6, 12),
  reminderDate: LocalDate(2031, 3, 12),
  reminderTime: LocalTimeOfDay(9, 0),
  timeZoneId: 'UTC',
  scheduledAtUtc: DateTime.utc(2031, 3, 12, 9),
  type: ReminderType.expiry,
  leadTime: ReminderLeadTime.ninetyDays,
  status: ReminderStatus.scheduled,
  notificationId: 1,
  privacyClassification: privacy,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
