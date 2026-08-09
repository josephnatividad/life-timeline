# ADR-0002: Flutter + Riverpod + Drift

-   Status: Accepted
-   Date: 2026-08-09

## Decision

Use Flutter/Dart as the mobile stack, Riverpod for state/dependency
composition, GoRouter for navigation, and Drift/SQLite for structured
persistence.

## Rationale

The product is highly device-centric: local database, filesystem,
encryption, camera/OCR, generated graphics, background work and future
on-device ML.

Drift provides typed relational queries, migrations and reactive access
suitable for the long-lived structured data model.

## Constraint

Framework/package APIs must not leak into the domain layer.
