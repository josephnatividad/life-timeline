---
name: life-timeline-architecture
description: >
  Use when implementing, reviewing, or refactoring Flutter architecture, domain models, persistence, repositories, storage, state management, or feature modules for the Life Timeline project. Enforces local-first Clean Architecture, SOLID, Riverpod, Drift/SQLite, reusable abstractions, provenance, temporal precision, and maintainability.
---

# Life Timeline Architecture Skill

Use for implementation, refactoring and code review.

## Stack

Flutter + Dart + Riverpod + GoRouter + Drift/SQLite.

## Core rules

-   Local-first.
-   No backend required.
-   Domain does not depend on Flutter/Drift/platform SDKs.
-   Feature modules with pragmatic Clean Architecture.
-   Reuse helpers/components; do not duplicate business logic.
-   Prefer composition.
-   Keep providers focused.
-   Large files live in filesystem, never SQLite blobs.
-   Model Entity/Event/Evidence/Relationship explicitly.
-   Support provenance and temporal precision.
-   AI candidates require user confirmation.
-   Use soft delete/undo for destructive record operations.

## Ports

Use interfaces for meaningful replaceable boundaries: AttachmentStorage,
BackupDestination, ArchiveStorage, IntelligenceProvider,
SemanticSearchEngine, EntitlementService.

Do not create interfaces for every class/table without a real boundary.
