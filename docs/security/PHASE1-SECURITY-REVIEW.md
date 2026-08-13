# Phase 1 Security Review

Status: implementation review for the local app lock and manual encrypted
backup/restore foundation. This document describes the current implementation,
not a promise that all device compromise is preventable.

## Scope and authority

This foundation follows `06-security-privacy.md`,
`07-backup-archive-recovery.md`, accepted ADRs, and `AGENTS.md`. It adds no
account, backend, analytics, developer-owned cloud storage, or cloud AI.
Backup and archive are user-initiated local exports and remain distinct:
backup protects against loss, while archive may free device space.

## Threat model

The implementation addresses:

- casual or opportunistic access to an app left on a device;
- disclosure of an exported backup to someone without its recovery password;
- undetected backup modification, truncation, corruption, or path traversal;
- restoration of a newer, incompatible database into an older app;
- partial restore replacing a usable current timeline;
- accidental inclusion of externally referenced originals in an app-owned
  backup;
- accidental secret or personal-content disclosure through application logs.
- premature local-original deletion before an encrypted archive is verified;
- archive substitution or corruption during explicit retrieval;
- unsafe temporary cleanup reaching user-selected or referenced content.

It does not claim to protect against a fully compromised/rooted device, a
malicious or compromised operating system, screen capture by the OS, runtime
memory inspection with elevated privileges, or an attacker who knows or can
guess the user's PIN or recovery password.

## Selected packages and primitives

| Concern | Selection | Reason |
| --- | --- | --- |
| Password derivation | `cryptography` Argon2id | Established implementation, memory-hard KDF, Apache-2.0, supported on project targets. |
| Backup encryption | `cryptography` AES-256-GCM | Authenticated encryption with streaming APIs; the header is authenticated as additional data. |
| Integrity inventory | SHA-256 | Per-file hashes detect payload substitution and support attachment verification after copying. AES-GCM remains the security boundary against malicious modification. |
| Device secret storage | `flutter_secure_storage` | Uses platform-protected storage behind an application port. Apple data uses device-only accessibility; Android application backup is disabled. |
| Biometrics | `local_auth` | Uses OS face/fingerprint authentication. The app neither receives nor stores biometric templates. |
| Archive | `archive` ZIP | Portable, stream-oriented packaging before encryption. Archive paths, entry types, count, and expanded size are validated independently. |
| File selection | `file_picker` | Provides native import/export selection on the supported Flutter targets. |

`file_picker` is pinned to the 10.3.x line for Flutter 3.44 compatibility; the
11.x line assumes AGP 9 built-in Kotlin. Android compilation also disables
incremental Kotlin caches because this Windows workspace and the Pub cache are
on different drive roots. Revisit both constraints when Flutter's built-in
Kotlin migration and the selected plugins are mutually compatible.

Production KDF parameters are Argon2id with a 19,456 KiB memory cost, two
iterations, parallelism one, a 16-byte random salt, and a 32-byte derived key.
These parameters are explicitly serialized so future readers can derive the
correct key and so a later format can introduce stronger parameters without
silently changing v1. Performance should be measured on the minimum supported
device before release.

No cryptographic primitive was implemented in project code. Container framing,
validation, key lifecycle, and domain-specific error mapping are application
code; AES-GCM, Argon2id, secure random generation, SHA-256, and constant-time
byte comparison come from the cryptographic package.

## PIN and app lock

- PIN input is limited to 4–12 decimal digits. The raw PIN is not persisted.
- A random salt and Argon2id-derived verifier are stored through
  `SecureKeyStore`; comparison uses the package constant-time helper.
- Derived byte lists are overwritten on a best-effort basis after use.
- A non-secret marker in the application-support container establishes the
  install boundary. If the container is new, stale platform-keystore entries
  are cleared before lock settings are read; this prevents iOS Keychain items
  surviving uninstall from locking a fresh recovery install.
- Failed attempts are persisted. The third failure delays five seconds, the
  fourth fifteen seconds, the fifth one minute, and later attempts five
  minutes. A successful verification clears the retry state.
- App lock is evaluated at startup when enabled. Background/resume behavior is
  driven by the selected immediate, one-, five-, fifteen-minute, or restart
  policy.
- Biometrics are optional and never replace the PIN fallback. Cancellation,
  lockout, unavailability, enrollment changes, and failure return to PIN
  without changing the verifier.
- Lifecycle events are advisory. A killed process restarts locked when app lock
  is enabled. Inactive, hidden, paused, and detached Flutter states now render a
  generic privacy cover so ordinary task-switcher snapshots do not expose the
  timeline. Platform snapshot timing and compromised-device behavior remain OS
  concerns and require physical-device validation.

The PIN protects local UI access; it is deliberately not a backup decryption
secret. This separation prevents a lost original device or its secure storage
from becoming necessary for recovery.

## Recovery-password lifecycle

The user enters and confirms an independent recovery password when creating a
backup. The raw password is held only for the operation and is not serialized.
A separate salted Argon2id verifier may be retained in platform secure storage
to report whether recovery has been configured; that verifier is not required
to restore and cannot decrypt the backup. Choosing a new password for a future
backup replaces this local verifier and does not re-encrypt older backups.

There is no service-side escrow or password reset. Losing the password can make
that backup permanently unrecoverable. The UI states this before export.

## Backup format v1

The project-neutral extension is `.timelinebackup`. The outer binary container
is:

1. eight-byte magic `LTBACK01`;
2. unsigned 32-bit JSON-header length;
3. UTF-8 JSON header;
4. AES-256-GCM ciphertext containing one ZIP payload;
5. 16-byte GCM authentication tag.

The JSON header is plaintext because restore must inspect compatibility before
requesting a password. It contains only safe operational metadata: format and
database versions, creation time, attachment count, encrypted payload length,
cipher/KDF identifiers and parameters, random salt, and random nonce. The exact
header bytes are AES-GCM additional authenticated data.

After decryption, the ZIP contains:

```text
manifest.json
database/timeline.json
attachments/<attachment-id>/<safe-file-name>
```

The normalized database export contains the canonical domain tables and not
the derived FTS table. `manifest.json` records app/database/format versions and
the size, SHA-256 hash, type, and logical attachment metadata for every payload
file. It contains no password, PIN, derived key, biometric data, device-bound
secret, or analytics identifier. Unexpected files, duplicate paths, symbolic
links, unsafe paths, excessive entry counts, and excessive expanded size are
rejected.

Only app-managed `local` attachments are copied. `referenced` attachment rows
remain as metadata, but their external paths are cleared in the portable
snapshot. Managed thumbnails and explicitly preserved pre-optimization
originals are copied and verified as separate manifest roles. Archived rows
retain portable archive-reference metadata and managed previews, but the
external archive file is not silently treated as backup content. Absolute
paths are rejected for app-managed files. Attachment IDs and storage mapping
are checked against the manifest before commit.

## Archive format and deletion safety

The project-neutral archive extension is `.timelinearchive`. V1 encrypts one
original per container using the same reviewed encryption service but a
distinct eight-byte magic, `LTARCH01`. The plaintext authenticated header
contains only format, creation, payload-size, cipher/KDF, salt, and nonce
metadata. The raw original is the authenticated encrypted payload; it is not
placed in SQLite.

The archive recovery password is operation-scoped and not persisted. Archive
references contain a logical filename, original/encrypted hashes and sizes,
algorithm and format identifiers, and verification timestamps. They contain no
absolute provider location, key, password, or credential.

The implementation verifies the managed source, encrypts in an app-private
temporary directory, invokes the system destination picker, verifies the
saved archive, and commits its reference before considering local removal.
Local removal is separately confirmed and off by default. If deletion fails
while the source still exists, the row returns to local. If metadata
finalization fails after a successful deletion, the verified archive state is
retained rather than falsely claiming a local original exists.

Retrieval verifies the encrypted archive hash/size before decryption and the
original hash/size after decryption and after the final managed copy. Wrong
password and damaged authentication map to conservative user-facing wording.

## Fresh-install restore and atomicity

Restore requires only the backup file, this application, and the independent
recovery password:

1. inspect and validate the safe outer header;
2. reject a newer database version before mutation;
3. derive the key from the supplied password and header salt;
4. authenticate/decrypt to an app-private temporary area;
5. validate and extract the ZIP defensively;
6. compare header, manifest, database snapshot, hashes, sizes, and attachment
   mappings;
7. show a preview and require explicit replacement confirmation if data exists;
8. copy attachments into a unique new generation;
9. replace canonical rows inside one Drift transaction, accepting supported
   older snapshot versions and rebuilding derived FTS data;
10. remove staging data after success, or remove the new attachment generation
    on failure.

The live database is not overwritten during inspection or staging. A failed
database insertion rolls back the transaction, leaving current rows usable. A
failed attachment stage removes only its newly allocated generation. Existing
attachment generations are retained after a successful replacement rather
than deleted eagerly; safe garbage collection is future hardening work.

## Error and logging policy

Domain/application failures expose short technical codes such as
`authentication_failed`, `checksum_failed`, and
`newer_backup_not_supported`. User-facing text intentionally does not
distinguish a wrong password from authentication damage. No implementation
logging was added for passwords, keys, decrypted data, timeline titles, OCR
content, or attachments.

## Known limitations and recovery risks

- The live SQLite database is not application-level encrypted in this phase;
  it relies on OS storage protection and the app lock is an access-control UI,
  not a defense against filesystem access on a compromised device.
- Password strength uses clear minimum/phrase guidance rather than an entropy
  estimator or compromised-password check. Weak user-chosen passwords remain
  vulnerable to offline guessing of a stolen backup.
- Argon2id cost is fixed for v1 and still needs minimum-device performance and
  denial-of-service testing. Header bounds prevent arbitrary parameter values
  from exceeding accepted limits.
- Secure-memory erasure is best effort in managed Dart memory; immutable input
  strings and library-internal copies cannot be reliably wiped.
- The outer header reveals creation time, versions, attachment count, and
  encrypted size. This is accepted to support pre-password compatibility
  checks without exposing timeline content.
- Export cancellation or a destination-provider failure may leave a partial
  file under provider control. App-private staging is cleaned best effort.
- Archive V1 requires explicit file reconnection and does not persist Android
  document URIs or Apple security-scoped bookmarks. Provider moves or revoked
  permissions therefore require the user to select the file again.
- Each V1 archive contains one original. Multi-select opens one save flow per
  item; durable directory and batch-container designs remain future work.
- An archive and its password remain the user's responsibility. There is no
  escrow, remote recovery, automatic redundancy, or guarantee that an
  archived original has more than one copy.
- JPEG optimization is lossy by design and requires explicit confirmation;
  preserving the source is the default. Release QA must validate fidelity
  across representative orientation and color-profile inputs.
- Cleanup safety depends on maintaining narrow directory/name allowlists.
  Adding a temporary-file producer requires a corresponding review rather
  than broadening cleanup to arbitrary cache or user paths.
- Platform file-provider behavior and biometric enrollment/lockout need manual
  validation on each supported OS and representative devices.
- The Android build still uses Flutter's temporary legacy Kotlin Gradle Plugin
  compatibility. A future Flutter upgrade must migrate the app and plugins to
  built-in Kotlin before that compatibility is removed.
- Google documents performance/utilization and diagnostic data collection for
  the native ML Kit SDK used by OCR. Android release removes network permissions,
  but iOS has no equivalent manifest gate. This conflicts with the unqualified
  no-analytics product promise and is a P0 product/privacy decision. See
  `PRIVATE-INTELLIGENCE-REVIEW.md`.
- Restore retains obsolete app-managed attachment generations after a
  successful replacement. They are app-private but consume space until a
  separately designed, transaction-aware cleanup policy exists.
- No cloud redundancy, automatic backup scheduling, password escrow, or remote
  recovery exists. Users remain responsible for securely retaining both file
  and password.

## Future hardening opportunities

- benchmark and version KDF parameters across minimum-supported devices;
- validate privacy-cover behavior against task-switcher snapshots and screen
  capture timing on supported Android and iOS devices;
- evaluate application-level database encryption under a separate ADR and
  migration/recovery design;
- add an authenticated streaming format that avoids temporary plaintext ZIP
  material while preserving deterministic recovery and portability;
- add a transaction-aware attachment-generation garbage collector;
- add fuzz/property tests for container headers, manifests, archives, and
  normalized database rows;
- conduct external cryptographic and mobile-platform review before broad
  release;
- add automated device tests for process death, low disk space, picker
  cancellation, biometric enrollment changes, and interrupted restore.

## Review conclusion

The design preserves the central recovery invariant: restoration does not
depend on the original device or device-bound secure storage. App-lock and
backup foundations have no known automated-test blocker. The ML Kit metrics
conflict is separately blocking for an external release that includes OCR
under the current privacy promise; the remaining device/platform checks are
release gates for claims beyond local app locking and user-managed encrypted
backup.
