# Storage Manager, Archive, and Backup Health V1

## Status

IMPLEMENTATION-READY for the first local-first storage-management vertical
slice. The PDD, accepted ADRs, `AGENTS.md`, and the official design-system and
security documents remain authoritative.

## Purpose

Storage Manager helps a person understand Life Timeline's app-owned storage,
identify conservative opportunities to save space, and move selected managed
originals to an encrypted user-owned archive without confusing archive with
backup.

The implementation adds no account, backend, analytics, cloud AI, automatic
cloud dependency, or developer-owned copy of timeline data.

## V1 scope

V1 includes:

- actual measurement of app-owned attachments, thumbnails, SQLite files,
  supported temporary files, and other application-support files;
- exact duplicate detection using local SHA-256 hashes, with review-only
  reporting and no automatic duplicate deletion;
- allowlisted cleanup of stale app-owned temporary files older than 24 hours;
- optional JPEG optimization for app-managed originals;
- encrypted, user-selected archive export for individual managed originals;
- explicit archive reconnection and verified local retrieval;
- copy-protection status that distinguishes local, archive, and verified
  backup copies;
- backup/restore support for thumbnails, preserved originals, and archive
  reference metadata;
- additive Drift schema v6 migration, extended by the non-destructive Memory
  Media schema v7 migration.

V1 does not include video transcoding, PDF recompression, automatic archive,
automatic duplicate deletion, provider accounts, background cloud sync,
directory-wide archive reconnection, or a guarantee that device-wide free
space is available on every platform.

## Storage inventory

The inventory measures files rather than estimating their sizes from UI
metadata. App-owned storage is presented as:

- photos;
- documents;
- thumbnails;
- SQLite database, WAL, and shared-memory files;
- allowlisted cache/temporary files;
- other managed application-support files.

Referenced external originals are counted as references, not app-owned bytes.
Archived originals are reported from verified archive-reference metadata, not
as local file usage. A missing managed path is reported as needing attention.
When the platform does not expose reliable device-wide free space through the
current abstraction, the UI omits that value instead of inventing one.

## Archive model

Archive saves device space; backup protects against loss. These concepts are
never presented as equivalent.

Each V1 archive contains one encrypted original and uses the
`.timelinearchive` extension. Its authenticated outer container uses the
eight-byte `LTARCH01` magic and the existing AES-256-GCM plus Argon2id
implementation. The recovery password is entered for archive creation and
again for retrieval. It is not persisted in the archive reference or
database.

The archive reference stores only operational metadata:

- attachment ID;
- destination type and non-sensitive logical file key;
- original size and SHA-256 hash;
- encrypted archive size and SHA-256 hash;
- encryption algorithm and archive format version;
- archive and verification timestamps.

It does not store an absolute provider path, password, key, original bytes, or
provider credential. V1 deliberately asks the user to reconnect the encrypted
file through the system picker when retrieving.

## Safe archive sequence

The archive engine follows this order:

1. Resolve the app-managed relative path inside the attachment root.
2. Verify file existence, size, and any recorded source checksum.
3. Retain or create a small local image preview when possible.
4. Encrypt the original in an app-private operation directory.
5. Ask the operating system for a user-owned destination.
6. Verify the saved encrypted archive.
7. Commit the archive reference while the local original still exists.
8. If the user explicitly selected local removal, mark the attachment as
   archived and attempt file deletion.
9. Clear the local path only after deletion succeeds.

Cancellation, encryption failure, destination failure, or verification
failure before step 7 leaves the attachment row and original untouched. A
file-deletion failure reverts the row to local while the file still exists.
If metadata finalization fails after a successful file deletion, the row
remains archived with its verified archive reference; it is never falsely
reverted to an available local state.

## Retrieval sequence

1. Read the archive reference.
2. Ask the user to reconnect one `.timelinearchive` file.
3. Verify encrypted size and SHA-256 before decryption.
4. Authenticate and decrypt locally with the supplied password.
5. Verify original size and SHA-256.
6. Copy into a new app-managed relative path and verify the copy again.
7. Update the attachment to `local` while retaining archive-reference
   metadata.

Cancel returns without mutation. An unavailable file reports that the
original is currently unavailable while its timeline metadata and preview
remain safe. Wrong-password and damaged-container failures share conservative
authentication wording.

## Copy protection and backup health

For each attachment, copy protection counts independently verified locations:

- available app-managed local original;
- verified external archive;
- last verified backup when that backup is known to contain the original.

Zero copies is critical, one copy needs attention, and two or more is
protected. A verified archive is still only one copy. Backup status includes
pending timeline changes and counts of one-copy, archive-only, and
no-verified-copy items.

The backup payload includes available managed originals, managed thumbnails,
and explicitly preserved pre-optimization originals. Archive-reference rows
are included as metadata, but the external `.timelinearchive` file is not
silently copied into a backup. On restore, archived rows retain their archive
reference and local preview while the original remains explicitly
reconnectable.

## Safe opportunities

### Duplicate detection

Only byte-identical managed files with matching size and SHA-256 are grouped.
Potential savings count distinct physical relative paths. Sharing one physical
path is not presented as reclaimable duplication. V1 does not delete a member
of a duplicate group.

### JPEG optimization

V1 optimization applies only to app-managed JPEG originals. It bakes
orientation, preserves aspect ratio, bounds the longest dimension, writes a
high-quality JPEG, and accepts the result only when it is at least five
percent smaller. The new file and checksum are committed before any optional
original removal. Preserving the original is the default.

### Temporary cleanup

Cleanup never scans arbitrary user-selected paths. It removes only files older
than 24 hours that match an explicit application-owned allowlist:

- Story exports named `story-export-*.png`;
- backup staging files under the dedicated staging directory;
- OCR temporary files named `ocr_*`;
- storage processing files named `storage-*`.

Unrecognized files, even inside one of these roots, are retained unless the
root's rule explicitly owns all of its contents.

## Schema v6

Schema v6 adds optional attachment fields:

- `preserved_original_relative_path`;
- `pixel_width`;
- `pixel_height`.

It also adds the one-to-one `archive_references` table with a cascading
attachment foreign key, non-negative size checks, positive format version,
verification-time ordering, a unique attachment index, and an archive-time
index. The migration is additive and does not reset user data.

## Memory Media extension: schema v7

Schema v7 normalizes attachment rows into reusable file assets and adds
`attachment_links` for event/evidence ownership, roles, captions, ordering,
captured time, and import time. Existing attachment `evidence_id` values are
conservatively migrated to `evidence` links. A partial unique index enforces
one hero per Event. Archive references retain whether the archived source is
the main file or a preserved original. Existing archive/provenance references
are copied through the table rebuild; no database reset is used.

Memory Media image assets participate in the existing photo, thumbnail,
duplicate-hash, copy-protection, backup, archive, and retrieval measurements.
Evidence-role image assets are reported under Documents/Evidence rather than
being presented as ordinary personal photographs.

## Platform behavior

- Android export uses the existing native Storage Access Framework save path,
  so the operating system owns destination selection and verification.
- Retrieval uses the native file picker and receives access only to the file
  the user selected.
- Apple and other supported picker implementations use the platform save/open
  flow. V1 does not claim a durable security-scoped directory connection.
- Multi-item archive currently asks for a destination once per encrypted
  original. Batch-container and durable directory UX are future design work.

## Human approval still required

- final archive recovery-password guidance and whether archive and backup UX
  should encourage one shared recovery phrase or separate phrases;
- minimum-device Argon2id performance acceptance;
- whether V2 should support a durable user-selected archive directory and its
  platform-specific permission lifecycle;
- product thresholds for large-image suggestions and future video handling;
- final localized copy for one-copy and unavailable-original warnings.
