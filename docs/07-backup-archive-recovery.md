# Backup, Archive & Recovery

## Backup and archive are different

**Backup protects against loss.**

**Archive frees device storage.**

Never present them as equivalent.

## Backup

``` text
Local timeline + files
        ↓
Backup builder
        ↓
Versioned manifest
        ↓
Encrypt locally
        ↓
User-owned destination
```

MVP: - Manual encrypted backup - Manual restore - System file picker /
user-selected destination

Future: - Automatic user-owned backup - Google Drive or other provider
integration - Backup health

## Archive

Archive moves selected large attachments away from the device while
retaining local metadata and small previews.

``` text
Timeline metadata       remains local
Thumbnail               remains local
Original attachment     encrypted/archive destination
```

Retrieval occurs only when the user requests the original.

## Storage Manager

Future UI should show:

-   Database usage
-   Photos
-   Documents
-   Videos
-   Thumbnails
-   Cache
-   Archived content
-   Potential savings

Possible optimizations:

-   Duplicate detection by hash
-   Large media review
-   Optimized receipt images
-   Cache cleanup
-   Archive old attachments

## Recovery

Build restore early, not as an afterthought.

Acceptance test:

> A completely fresh installation can restore a valid backup without
> access to the original device.

Recovery should include:

-   Backup version validation
-   Password/key verification
-   Checksum verification
-   Database migration
-   Attachment restoration
-   Final integrity verification

## Backup health

Eventually show understandable protection status:

``` text
Last backup
Destination
Backup verified
Important items with only one copy
Recovery readiness
```
