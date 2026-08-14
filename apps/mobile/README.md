# Life Timeline mobile foundation

This is the Phase 1 Flutter foundation for the **Life Timeline** working
project name. It contains the local-first product foundation and implemented
vertical slices described by the repository PDDs and accepted ADRs.

## Structure

```text
lib/
├── app/             bootstrap, root composition, navigation, app providers
├── design_system/   tokens, themes, motion, Hugeicons through AppIcons
├── features/        feature-oriented boundaries and presentation placeholders
└── shared/          cross-feature database and reusable foundation UI
```

Feature dependencies point inward: presentation → application → domain.
Infrastructure implements meaningful ports owned by inner layers. Domain code
must remain independent of Flutter, Riverpod, Drift, and platform SDKs.

## Foundation commands

```text
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
```

The project pins Flutter 3.44.9 in `.fvmrc`. Install FVM, then run all Flutter
and Dart commands through `fvm` so local development and CI use the same SDK.
On Windows, enabling Developer Mode allows FVM to create its optional IDE SDK
symlink; the `fvm flutter` and `fvm dart` command proxies work without it.

The Drift database is versioned and production migrations must remain
non-destructive. Adding or changing persistent state requires schema,
backup-format, restore, search-index, and recovery review.

## Google Drive backup configuration

Automatic backup is optional, off by default, and restricted to encrypted
LTBACK01 artifacts in Google Drive `appDataFolder`. It is not an application
account. Do not add broad Drive scopes or reuse this transport from product
features.

Deployment must create Google OAuth clients for the final approved identities
and signing certificates. Current provisional identifiers are:

- Android: `com.lifetimeline.life_timeline`
- iOS: `com.lifetimeline.lifeTimeline`

This project intentionally does not apply the Firebase/Google Services Gradle
plugin. Android therefore requires the approved web OAuth client ID at build
time, plus a matching Android OAuth client registered for the application ID
and signing certificate:

```text
fvm flutter run --dart-define=LIFE_TIMELINE_GOOGLE_SERVER_CLIENT_ID=<client-id>
```

iOS also requires its OAuth client ID and matching reversed-client-ID URL
scheme in the final Xcode configuration:

```text
--dart-define=LIFE_TIMELINE_GOOGLE_IOS_CLIENT_ID=<ios-client-id>
```

OAuth client IDs are deployment configuration, not timeline secrets, but they
must still be managed per environment. Never commit client secrets, access
tokens, refresh tokens, recovery passwords, or real timeline fixtures. Audit
the iOS Pod lockfile on macOS before release; it is not generated on Windows.
