# ADR 0010: Local device reminder scheduling

- Status: Accepted
- Date: 2026-08-13

## Context

Phase 1 needs actionable reminders for exact future timeline dates without introducing a company timeline cloud, account, push server, or remote scheduler. Scheduling must preserve local calendar intent across DST and time-zone changes, remain useful without notification permission, respect app lock, and survive restarts where the operating system permits.

Android exact alarms add special permission and store-policy implications that do not match a low-urgency life-timeline reminder. iOS limits applications to 64 pending local notifications.

## Decision

Use `flutter_local_notifications` only in an infrastructure adapter behind `LocalNotificationService`. Use `timezone` for IANA/DST calendar calculations and `flutter_timezone` to obtain the current device IANA identifier.

Persist reminder intent in Drift as exact local date/time components plus the current IANA zone and a derived UTC ordering value. Use one-time, inexact local schedules. Do not request Android exact-alarm permission. Register Android reboot/package-replaced receivers and reconcile database state against pending platform requests on application lifecycle boundaries.

Use a rolling horizon of 60 OS requests. Database records outside that horizon remain scheduled in the domain and enter the platform window during later reconciliation.

Notification payloads contain only an opaque reminder ID. Notification content passes through `NotificationPrivacySanitizer`, and tap navigation waits for the existing app-lock session to unlock.

## Consequences

- The feature remains local-first and works without a service, account, or network permission.
- Delivery can be delayed by Android OEM power management because exact alarms are intentionally avoided.
- OS schedules are disposable derived state; Drift plus reconciliation is authoritative.
- Backup stores reminder records but never platform schedules.
- Annual/general recurrence is not part of V1.
- The three packages add native maintenance exposure, isolated behind ports and covered by platform configuration tests/builds.
