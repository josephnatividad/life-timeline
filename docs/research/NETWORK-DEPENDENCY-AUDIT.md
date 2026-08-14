# Network Dependency Audit

Status: Android release artifact verified, 2026-08-14

## Policy gate

Network access remains deny-by-default at the architecture level. The only
approved service is direct Google Drive access for encrypted, user-owned
backup through `BackupDestination`. Internet permission does not authorize
OCR, Ask My Life, Insights, Stories, search, extraction, classification, or
image processing to use networking.

## Pre-permission OCR gate

The Android `releaseRuntimeClasspath` was resolved after removing
`google_mlkit_text_recognition`. It contains no `com.google.mlkit` artifact.
The Dart lockfile, generated plugin registrants/metadata, Android sources, iOS
sources, and application imports contain no ML Kit OCR dependency. Stored
OCR-derived records and provenance are database data and remain unchanged.

## Expected network-capable dependencies

| Dependency | Reason present | Permitted use |
| --- | --- | --- |
| `googleapis` | Typed Google Drive v3 REST client | `appDataFolder` backup list/upload/download/delete only |
| `googleapis_auth` | Authenticated HTTP client used by the Google API package | Drive backup requests only |
| `http` | HTTP transport under the Google API client | Drive backup requests only |
| `google_sign_in` and platform implementations | User authorization for the minimum Drive scope | Connect/disconnect the Drive backup destination; not an app account |
| Android `play-services-auth`, `play-services-auth-base`, `play-services-auth-api-phone`, `play-services-auth-blockstore`, `play-services-base`, `play-services-basement`, `play-services-tasks`, `play-services-fido`, and `play-services-identity-credentials` | Transitive Google Sign-In/Credential Manager implementation | Drive OAuth authorization only; application code does not call phone, Block Store, FIDO, or identity-credential APIs directly |
| AndroidX Credentials `credentials` / `credentials-play-services-auth` and Google Identity `googleid` | Transitive Google Sign-In credential integration | Drive OAuth authorization only |

Supporting packages that do not themselves transfer timeline data:

- `connectivity_plus` observes network transport state to enforce the selected
  Wi-Fi/any-network policy. It does not prove Internet reachability and does
  not upload content.
- `workmanager` / AndroidX `work-runtime` schedules opportunistic local work
  with network/charging constraints. It is not a backup transport.

## Built release evidence

The FVM-pinned Flutter 3.44.9 toolchain successfully produced the Android
release APK on 2026-08-14. The packaged manifest was inspected with the Android
SDK analyzer and contains the expected `INTERNET` and `ACCESS_NETWORK_STATE`
permissions. It also contains WorkManager's boot, wake-lock, foreground-service,
and job-scheduling declarations; those support opportunistic scheduling and do
not create an additional content destination.

The packaged DEX inventory, not only the lockfile, was scanned for prohibited
SDK namespaces. The resolved `releaseRuntimeClasspath` and release DEX both
contain no ML Kit or other negative-finding dependency listed below.

## Negative findings

The resolved Android release graph contains no ML Kit, Firebase Analytics,
Google Analytics/App Measurement, advertising SDK, Sentry, Segment, Amplitude,
PostHog, Facebook SDK, Retrofit, OkHttp application client, remote OCR SDK, or
cloud AI SDK.

There is no analytics event, crash-content logger, telemetry adapter, backend
client, application account, or developer-operated backup endpoint in the
implemented flow.

## Native release notes

- Android requires `INTERNET` and `ACCESS_NETWORK_STATE`; the manifest records
  their approved backup-only purpose.
- iOS has no equivalent Internet permission. Its final CocoaPods graph must be
  audited on macOS because this Windows environment cannot resolve/build pods.
- Google OAuth client registrations and iOS URL scheme values are deployment
  credentials and are intentionally not committed. Release configuration must
  bind them to the final approved application identifiers.
- Flutter 3.44.9 still requires its temporary AGP 9 legacy-KGP compatibility
  bridge; the official Flutter guide permits enabling Built-in Kotlin only on
  Flutter 3.47+. The app module has been migrated to the current compiler DSL,
  but the atomic Workmanager 0.9.0+3 federated release set is temporarily pinned
  because newer Workmanager Android packages assume Built-in Kotlin is already
  enabled. `file_picker`, `flutter_timezone`, `package_info_plus`, `share_plus`,
  and `workmanager_android` remain in Flutter's future migration warning. This
  is a build-maintenance risk, not runtime telemetry, and must be removed after
  Flutter 3.47+ and the full plugin graph are compatible.

## Repeatable release checks

Before every public release:

1. Resolve Android `releaseRuntimeClasspath` and fail the release for ML Kit,
   analytics, ads, telemetry, remote OCR, or unapproved HTTP/SDK additions.
2. Inspect `pubspec.lock`, generated plugin metadata, Android merged manifests,
   and the iOS Pod lockfile.
3. Build release artifacts and inspect their dependency/licenses inventory.
4. Exercise Drive authorization, resumable upload, byte/SHA-256 verification,
   retention failure, download verification, and the unchanged LTBACK01 restore
   pipeline.
5. Confirm all non-backup personal-content paths operate with networking
   unavailable.
