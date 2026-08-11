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

Implemented foundation:

- Manual encrypted backup
- Manual fresh-install restore
- System file picker / user-selected destination
- Verified attachment, thumbnail, and preserved-original payloads
- Portable archive-reference metadata

Future: - Automatic user-owned backup - Google Drive or other provider
integration - Backup health

## Archive V1

Archive moves selected large attachments away from the device while
retaining local metadata and small previews.

``` text
Timeline metadata       remains local
Thumbnail               remains local
Original attachment     encrypted/archive destination
```

Retrieval occurs only when the user requests the original.

Each V1 `.timelinearchive` contains one original encrypted locally with the
existing AES-256-GCM and Argon2id implementation under a separate `LTARCH01`
container magic. The database stores a logical key, hashes, sizes, algorithm
and format identifiers, and verification timestamps. It stores no password,
key, original bytes, absolute provider path, or provider credential.

The system picker owns destination selection. V1 does not require Google Drive
or any other provider and does not claim persistent access to a selected
directory. Retrieval asks the user to reconnect the archive file, verifies the
encrypted file, authenticates/decrypts locally, verifies the original, and
restores it to app-managed storage.

The archive reference is committed while the original still exists. Local
removal is off by default and occurs only after successful destination
verification and explicit confirmation. Cancellation and pre-commit failure
leave the local original unchanged.

## Storage Manager V1

The implemented UI shows:

-   Database usage
-   Photos
-   Documents
-   Thumbnails
-   Cache
-   Archived content
-   Potential savings

Implemented conservative optimizations:

-   Duplicate detection by hash
-   Optimized managed JPEG images
-   Cache cleanup
-   Archive old attachments

Duplicate reporting is review-only. JPEG optimization defaults to preserving
the original. Cleanup is restricted to explicit app-owned temporary-file
allowlists older than 24 hours. Video optimization and automatic deletion are
future work.

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

Storage Manager shows understandable protection status:

``` text
Last backup
Destination
Backup verified
Important items with only one copy
Recovery readiness
```

Copy protection counts available local, verified archive, and known verified
backup copies independently. Archive is never relabeled as backup. An archived
original in one destination remains a one-copy warning.
