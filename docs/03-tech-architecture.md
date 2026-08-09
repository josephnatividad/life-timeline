# Technical Architecture

## Stack

``` text
Flutter + Dart
│
├── Riverpod              state/dependency composition
├── GoRouter              navigation
├── Drift                 typed SQLite persistence
├── SQLite FTS            local full-text search
├── Device filesystem     attachments/thumbnails
├── local_auth            biometric authentication
├── flutter_secure_storage secure key material
├── share_plus            system sharing
├── On-device OCR/ML      capture intelligence
└── Platform channels     only when required
```

Package choices should be verified at implementation time for
maintenance, platform support, license and compatibility.

## Architecture

Use pragmatic Clean Architecture with feature modules.

``` text
lib/
├── app/
│   ├── bootstrap/
│   ├── navigation/
│   ├── theme/
│   └── providers/
├── features/
│   ├── timeline/
│   ├── entities/
│   ├── memory_inbox/
│   ├── capture/
│   ├── search/
│   ├── insights/
│   ├── stories/
│   ├── backup/
│   ├── archive/
│   ├── security/
│   └── settings/
├── shared/
│   ├── domain/
│   ├── database/
│   ├── storage/
│   ├── intelligence/
│   ├── crypto/
│   ├── ui/
│   ├── utils/
│   └── constants/
└── main.dart
```

Feature structure where complexity warrants it:

``` text
feature/
├── domain/
├── application/
├── infrastructure/
└── presentation/
```

Do not create ceremony for trivial features.

## Dependency rule

Presentation → Application → Domain.

Infrastructure implements ports defined by inner layers.

Domain must not import Flutter UI, Drift, ML runtimes, platform SDKs, or
storage providers.

## Key ports

``` dart
abstract interface class TimelineRepository {}
abstract interface class AttachmentStorage {}
abstract interface class BackupDestination {}
abstract interface class ArchiveStorage {}
abstract interface class IntelligenceProvider {}
abstract interface class SemanticSearchEngine {}
abstract interface class EntitlementService {}
```

## AI provider strategy

Keep the application independent from implementation:

``` text
IntelligenceProvider
├── RuleBasedIntelligence
├── OnDeviceIntelligence
├── LocalGenerativeIntelligence (future)
└── CloudIntelligence (possible future, never required)
```

## Engineering rules

-   Prefer reusable components/helpers for repeated behavior.
-   Do not duplicate parsing, privacy, date, storage or formatting
    logic.
-   Prefer composition over inheritance.
-   Keep widgets small and presentation-focused.
-   Business rules belong in domain/application code.
-   Avoid giant service classes and giant Riverpod providers.
-   Repository interfaces should represent meaningful boundaries, not
    every database table.
-   No backend assumptions in core domain code.
