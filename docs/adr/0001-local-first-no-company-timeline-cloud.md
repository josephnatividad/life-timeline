# ADR-0001: Local-First With No Company-Hosted Timeline

-   Status: Accepted
-   Date: 2026-08-09

## Decision

The core product stores personal timeline data locally. The company does
not operate a server-side copy of the user's timeline.

Backups/archives are user-controlled.

No account is required for core use.

## Consequences

Positive: - Strong privacy positioning - Lower infrastructure cost -
Lower breach exposure - Better fit for one-time Pro pricing - Offline
operation

Negative: - Multi-device synchronization is harder - Device storage
requires active management - Recovery design becomes critical

Cloud sync may only be reconsidered through a new ADR based on
demonstrated user demand.
