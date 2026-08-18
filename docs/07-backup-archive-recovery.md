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
- Memory Media roles, hero/order links, captions, privacy, and checksums
- Portable archive-reference metadata

Implemented automatic user-owned backup foundation:

- Optional and off by default
- Direct Google Drive `appDataFolder` destination using only `drive.appdata`
- Existing LTBACK01 builder, encryption, restore, and integrity checks reused
- Daily or weekly schedule, default weekly
- Wi-Fi-only by default, with charging preferred for background work
- Three verified generations retained by default
- Retention runs only after a new upload passes server byte-count and SHA-256
  verification; failure keeps older recovery points
- Recovery password stored only on the opted-in device in non-migrating secure
  storage and never uploaded
- Background execution is opportunistic and operating-system controlled; the
  UI exposes the last verified result and allows an explicit backup now
- Fresh/empty timelines can restore either a user-selected LTBACK01 file or a
  verified generation from the connected Drive app-data folder

Provider SDK types remain in infrastructure behind `BackupDestination`.
Additional providers remain future work and require separate privacy and
architecture approval.

Google Drive stores these generations against the connected user's storage
quota rather than developer-owned storage. The integration must remain within
the cost and billing constraints in `15-cost-safety.md`; setup and OAuth client
configuration must follow `setup/GOOGLE-DRIVE-BACKUP-SETUP.md`.

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

For optimized Memory Media, archive prefers the preserved original while the
display image and thumbnail remain local previews. The archive reference
records whether its source was the main file or `preserved_original`, so
retrieval restores the correct slot without overwriting gallery ordering or
captions. Story export requests retrieval when only an archived original can
provide full-resolution output.

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
