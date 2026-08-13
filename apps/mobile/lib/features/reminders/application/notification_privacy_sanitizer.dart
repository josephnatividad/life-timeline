import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

abstract interface class NotificationPrivacySanitizer {
  NotificationContent sanitize(Reminder reminder);
}

final class DefaultNotificationPrivacySanitizer
    implements NotificationPrivacySanitizer {
  const DefaultNotificationPrivacySanitizer();

  @override
  NotificationContent sanitize(Reminder reminder) {
    if (reminder.privacyClassification == PrivacyClassification.sensitive ||
        reminder.privacyClassification == PrivacyClassification.neverShare) {
      return const NotificationContent(
        title: 'Life Timeline reminder',
        body: 'A private timeline reminder is coming up.',
      );
    }
    final title = reminder.title.trim();
    if (_mayContainSensitiveIdentifier(title)) {
      return const NotificationContent(
        title: 'Life Timeline reminder',
        body: 'A timeline reminder is coming up.',
      );
    }
    return NotificationContent(
      title: 'Life Timeline reminder',
      body: '$title is coming up.',
    );
  }

  bool _mayContainSensitiveIdentifier(String value) {
    final normalized = value.toLowerCase();
    return RegExp(r'\d{4,}').hasMatch(value) ||
        RegExp(
          r'\b(?=[a-z0-9-]{6,}\b)(?=[a-z0-9-]*[a-z])(?=[a-z0-9-]*\d)',
        ).hasMatch(normalized) ||
        normalized.contains('booking reference') ||
        normalized.contains('home address') ||
        normalized.contains('passport number') ||
        normalized.contains('serial number');
  }
}
