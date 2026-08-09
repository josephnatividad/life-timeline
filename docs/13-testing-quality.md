# Testing, Quality & Maintainability

## Quality priorities

For this product, data loss and privacy leakage are higher-severity
defects than ordinary UI bugs.

## Tests

### Unit

-   Domain rules
-   Temporal precision
-   Parsers
-   Privacy sanitizer
-   Provenance
-   Duplicate matching
-   Backup manifest
-   Encryption wrappers
-   Insight calculations

### Repository/database

-   Drift queries
-   Migrations
-   Transactions
-   FTS
-   Soft deletion
-   Relationship integrity

### Widget

-   Timeline
-   Memory Inbox
-   Story renderer
-   Privacy controls
-   Backup/recovery screens
-   Paywall
-   Reduced motion

### Integration

-   Capture → candidate → confirm → timeline
-   Backup → uninstall/fresh state → restore
-   Archive → remove local → retrieve
-   Free → Pro entitlement behavior
-   Share → sanitizer → rendered Story

## Code quality

-   SOLID where it improves changeability.
-   Prefer reusable helpers/components over duplicated behavior.
-   Avoid premature abstractions.
-   Keep feature boundaries explicit.
-   No business logic in widgets.
-   No raw database queries scattered through presentation.
-   No privacy rules duplicated in UI.
-   No direct package dependency usage throughout features when an
    application-level abstraction is warranted.

## Performance

-   Long timelines must be virtualized/lazy.
-   Animate only visible items.
-   Avoid unnecessary rebuilds.
-   Avoid large image decoding on UI thread where possible.
-   Generate thumbnails.
-   Prefer real progress over artificial loading UI.
-   Target smooth performance on representative midrange Android
    devices.

## Definition of done

A feature is not done until:

-   Empty/loading/error states exist
-   Accessibility is considered
-   Reduced motion is respected where relevant
-   Privacy implications are reviewed
-   Tests cover important business rules
-   Data migration/backup impact is considered
