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
├── Local intelligence port capability-gated local processing
└── Platform channels     only when required
```

Package choices should be verified at implementation time for
maintenance, platform support, license and compatibility.

## Approved network services

Network availability is not a general capability grant. Infrastructure may
contact only an external service that has an accepted architecture/privacy
decision and a narrow application port. Domain and presentation code must not
create network clients or depend on provider SDK types.

The initial approved service is Google Drive acting only as a user-owned
encrypted `BackupDestination`. Timeline records and attachments must be
packaged and encrypted locally before this boundary. OCR, Ask My Life,
Insights, Stories, search, classification, extraction, and image processing
remain local and have no network fallback.

Every added network-capable dependency requires a dependency, data-flow,
logging, privacy, and release-manifest review. Merely having `INTERNET`
permission does not authorize a feature to use it.

The production Drive implementation is isolated behind `BackupDestination`
and `BackupDestinationAuthorization`. Provider SDK/API types stay in
infrastructure. The only requested OAuth scope is `drive.appdata`; the app is
not granted general access to the user's visible Drive. The connection is a
backup destination, not a Life Timeline account.

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
