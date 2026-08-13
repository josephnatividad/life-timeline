import 'package:life_timeline/shared/domain/model/record_metadata.dart';

enum ReminderType { expiry, renewal, warranty, anniversary, followUp, custom }

enum ReminderStatus { scheduled, disabled, completed, missed, cancelled }

enum ReminderLeadTime {
  onDay,
  oneDay,
  sevenDays,
  thirtyDays,
  ninetyDays,
  sixMonths,
  custom,
}

/// A calendar date without a time zone or invented precision.
final class LocalDate {
  LocalDate(this.year, this.month, this.day) {
    final parsed = DateTime.utc(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
  }

  factory LocalDate.fromDateTime(DateTime value) =>
      LocalDate(value.year, value.month, value.day);

  final int day;
  final int month;
  final int year;

  DateTime get asUtcDate => DateTime.utc(year, month, day);

  int compareTo(LocalDate other) => asUtcDate.compareTo(other.asUtcDate);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

final class LocalTimeOfDay {
  LocalTimeOfDay(this.hour, this.minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid local time: $hour:$minute');
    }
  }

  static final defaultReminderTime = LocalTimeOfDay(9, 0);

  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) =>
      other is LocalTimeOfDay && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

final class Reminder {
  Reminder({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.reminderDate,
    required this.reminderTime,
    required this.timeZoneId,
    required DateTime scheduledAtUtc,
    required this.type,
    required this.leadTime,
    required this.status,
    required this.notificationId,
    required this.privacyClassification,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.linkedEventId,
    this.linkedEntityId,
    this.sourceEvidenceId,
    this.note,
    DateTime? completedAt,
    DateTime? dismissedAt,
  }) : scheduledAtUtc = scheduledAtUtc.toUtc(),
       createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc(),
       completedAt = completedAt?.toUtc(),
       dismissedAt = dismissedAt?.toUtc() {
    if (id.trim().isEmpty ||
        title.trim().isEmpty ||
        timeZoneId.trim().isEmpty) {
      throw ArgumentError('Reminder id, title, and time zone are required.');
    }
    if (notificationId <= 0) {
      throw ArgumentError.value(notificationId, 'notificationId');
    }
    if (this.updatedAt.isBefore(this.createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt.');
    }
    if (status == ReminderStatus.completed && this.completedAt == null) {
      throw ArgumentError('Completed reminders require completedAt.');
    }
  }

  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? dismissedAt;
  final String id;
  final ReminderLeadTime leadTime;
  final String? linkedEntityId;
  final String? linkedEventId;
  final String? note;
  final int notificationId;
  final PrivacyClassification privacyClassification;
  final LocalDate reminderDate;
  final LocalTimeOfDay reminderTime;
  final DateTime scheduledAtUtc;
  final String? sourceEvidenceId;
  final ReminderStatus status;
  final LocalDate targetDate;
  final String timeZoneId;
  final String title;
  final ReminderType type;
  final DateTime updatedAt;

  bool get isEnabled => status == ReminderStatus.scheduled;
  bool get isFuture => scheduledAtUtc.isAfter(DateTime.now().toUtc());

  Reminder copyWith({
    String? title,
    String? note,
    bool clearNote = false,
    LocalDate? targetDate,
    LocalDate? reminderDate,
    LocalTimeOfDay? reminderTime,
    String? timeZoneId,
    DateTime? scheduledAtUtc,
    ReminderType? type,
    ReminderLeadTime? leadTime,
    ReminderStatus? status,
    PrivacyClassification? privacyClassification,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? dismissedAt,
    bool clearDismissedAt = false,
  }) => Reminder(
    id: id,
    linkedEventId: linkedEventId,
    linkedEntityId: linkedEntityId,
    sourceEvidenceId: sourceEvidenceId,
    title: title ?? this.title,
    note: clearNote ? null : (note ?? this.note),
    targetDate: targetDate ?? this.targetDate,
    reminderDate: reminderDate ?? this.reminderDate,
    reminderTime: reminderTime ?? this.reminderTime,
    timeZoneId: timeZoneId ?? this.timeZoneId,
    scheduledAtUtc: scheduledAtUtc ?? this.scheduledAtUtc,
    type: type ?? this.type,
    leadTime: leadTime ?? this.leadTime,
    status: status ?? this.status,
    notificationId: notificationId,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    dismissedAt: clearDismissedAt ? null : (dismissedAt ?? this.dismissedAt),
  );
}
