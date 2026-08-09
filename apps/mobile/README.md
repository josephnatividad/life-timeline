# Life Timeline mobile foundation

This is the Phase 1 Flutter foundation for the **Life Timeline** working
project name. It contains architecture, dependency composition, local database,
design-system, accessibility/motion, and navigation-shell scaffolding only.

Product features are intentionally deferred.

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

The Drift database currently has no product tables. Adding or changing a
persistent schema requires migration, backup-format, and recovery review.
