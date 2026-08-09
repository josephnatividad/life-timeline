# ADR-0005: User-Owned Backup and Archive

-   Status: Accepted
-   Date: 2026-08-09

## Decision

Backups are encrypted locally and stored in destinations controlled by
the user.

Archive is a separate capability used to free device storage while
preserving local metadata/previews.

## Constraint

Archive must never be represented as equivalent to having a redundant
backup.
