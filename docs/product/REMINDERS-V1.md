# Reminders V1

Status: Implemented for Phase 1

## Purpose

Reminders turn an exact future date already understood by Life Timeline into a user-confirmed, local device notification. They are a timeline companion, not a calendar, alarm clock, or task manager. No reminder data, schedule, notification content, or interaction is sent to a Life Timeline service.

## Domain

`Reminder` stores:

- an app-owned ID and unique local notification ID;
- optional links to an Event, Entity, and source Evidence;
- title and optional private note;
- an exact target calendar date;
- an exact reminder calendar date and local wall-clock time;
- the IANA time-zone ID used for the latest schedule calculation;
- a derived UTC instant used for ordering and reconciliation;
- type, lead-time preset, lifecycle status, privacy classification, and audit timestamps.

Supported types are expiry, renewal, warranty, anniversary, follow-up, and custom. Supported states are scheduled, disabled, completed, missed, and cancelled. Platform-specific states do not enter the domain.

V1 uses one-time reminders. Anniversary reminders can target the next explicit occurrence, but a generalized recurrence engine is deferred.

## Presets and suggestions

Presets are deterministic:

- Expiry and renewal: 30 days, 90 days, six calendar months, or custom.
- Warranty: 7 days, 30 days, or custom.
- Anniversary: on the day, 1 day, 1 week, or custom.
- Follow-up/custom: a small set of day-based choices or custom.

Local OCR candidate review can suggest a reminder only when a reviewed date field is typed as a date, has confidence of at least 0.70, uses an expiry-style field key, and parses as an exact `YYYY-MM-DD`-style date. Warranty defaults to 30 days, identity documents to six months, and other reliable expiry dates to 90 days. Suggestions are off by default and never schedule without confirmation.

Insights do not create reminders. Existing expiry insights lead to supporting records; Memory Detail then provides the contextual Add reminder action.

## Temporal precision

An exact `TemporalValue` can initialize a reminder directly. Month, year, approximate, before, after, range, and unknown values are never converted into an invented exact date.

For an imprecise memory, the UI states that the memory has no exact date and lets the user choose a separate exact reminder date. That action does not modify the historical date. A passed reminder instant becomes missed instead of being silently removed or scheduled in the past. Date-only reminders default to 09:00 local time.

## Local scheduling

The platform adapter uses `flutter_local_notifications` behind `LocalNotificationService`. `timezone` performs IANA/DST calendar calculations and `flutter_timezone` obtains the device's current IANA zone. Domain and application code contain no plugin types.

Scheduling uses inexact, idle-compatible Android alarms. Exact-alarm permissions are intentionally not requested because these reminders tolerate small delivery delays and are not alarm-clock or medical-alarm functions. The database preserves local calendar intent; UTC is derived rather than authoritative.

`ReminderSchedulerReconciler` compares database reminders with OS pending requests. It:

- marks elapsed scheduled reminders as missed;
- updates future schedules when the device zone changes;
- cancels orphan or inactive OS requests;
- repairs missing requests when permission is granted;
- schedules only the next 60 requests to remain below iOS's 64-pending-request limit.

Reconciliation runs at notification initialization, app resume, permission grant, lifecycle changes, and completed restore. Android also registers the plugin reboot and package-replaced receiver.

## Permissions

Reminder records remain usable if notifications are denied. Enabling a reminder prompts contextually rather than at app launch. When permission remains unavailable, the UI reports: “Reminder saved. Notifications are currently turned off.” Reconciliation schedules saved future reminders after permission is later granted.

Android declares `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED`. It does not declare exact-alarm permission. iOS requests alert, badge, and sound authorization through the local plugin.

## Privacy and app lock

`NotificationPrivacySanitizer` is the only application policy that constructs notification content. Sensitive and `neverShare` reminders use generic content. Notes, OCR text, document identifiers, serial numbers, booking references, addresses, and other timeline fields never enter notification payloads. Payloads contain only a version-independent opaque reminder ID prefix.

Notification visibility is private on Android. A tap creates a pending reminder intent. `ReminderAppCoordinator` does not navigate until the existing security session reports unlocked; after PIN/biometric unlock, the reminder is looked up locally and the linked Memory Detail opens. A deleted or unlinked reminder falls back to the Reminders list.

## Lifecycle behavior

- Archive preserves reminders unchanged.
- Moving a linked memory to Trash disables its scheduled reminders in the same Drift transaction; reconciliation cancels OS requests.
- Restoring from Trash does not silently re-enable notifications. The reminder remains available for explicit re-enabling.
- Permanent deletion cascades linked reminder rows in the database transaction; reconciliation removes orphan OS requests.

## Backup and restore

Schema v8 adds `reminders` to encrypted database snapshots. OS notification schedules are not backup data. Restore completes and validates the database first, refreshes reminder read models, then reconciles future eligible reminders. A clean replacement restore has collision-free app-local notification IDs; the unique index rejects malformed collisions. Past or disabled reminders are restored as records but are not incorrectly scheduled.

## Platform limitations

- Android OEM battery policy may delay or suppress inexact work despite a valid schedule.
- iOS retains only 64 pending notifications, so V1 uses a rolling 60-request window.
- Uninstall clears OS schedules; restoring the encrypted backup and granting permission rebuilds them.
- Time-zone changes are repaired by calendar-aware OS scheduling and the next app reconciliation.
- General recurrence, calendar sync, remote push, accounts, cloud scheduling, email, and SMS are out of scope.

## Verification boundaries

Automated tests cover temporal rules, OCR suggestion gates, privacy sanitization, save/edit/disable/delete state, scheduling and permission denial, timezone reconciliation, lifecycle cascade, backup round-trip, schema/index integrity, and core UI states. Physical notification delivery, OEM reboot behavior, and iOS device behavior require release-device QA.
