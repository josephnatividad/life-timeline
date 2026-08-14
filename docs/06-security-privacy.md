# Security & Privacy

## Privacy posture

The developer should not possess a server-side copy of the user's
timeline.

No account is required for core functionality.

If future telemetry, purchases, support or optional services process
personal data, those systems must remain clearly separated from timeline
content.

## Network boundary

Network access is deny-by-default at the architecture level even when a
platform grants the application Internet permission. The first approved
network use is direct Google Drive access for the user's encrypted backup
artifact. The provider receives the minimum OAuth/account/network metadata,
opaque encrypted bytes, and non-sensitive operational metadata needed for
backup generations. Life Timeline operates no proxy or server-side timeline
copy.

OCR, Ask My Life, Insights, Stories, search, extraction, and image processing
must remain local. They must not reuse the backup network client or introduce a
cloud fallback.

The prior ML Kit OCR SDK was removed from network-enabled builds because Google
documents collection of SDK utilization and performance metrics. OCR-derived
records, Evidence, candidate state, and provenance remain compatible. Scan
Document temporarily supports private manual Evidence capture while a
telemetry-free local OCR engine is benchmarked. No cloud OCR replacement is
permitted.

Automatic backup may store the recovery password only after explicit opt-in.
That copy is device-only: Android secure storage disables backup migration,
and iOS uses `AfterFirstUnlockThisDeviceOnly` with synchronization disabled.
It is never placed in LTBACK01, Drive metadata, logs, analytics, or app
infrastructure. Disabling automatic backup deletes this unattended-use copy.

Google Drive receives an opaque encrypted LTBACK01 file plus operational
metadata required to list and verify generations (format/schema versions,
creation time, byte count, and encrypted-file checksum). It does not receive
plaintext timeline fields, attachment names, OCR text, recovery passwords, or
encryption keys. Upload byte count and Drive's server-side SHA-256 must match
before the generation is accepted.

## Data handling rules

Never send these to analytics/crash systems:

-   Event titles/content
-   OCR text
-   Search queries
-   Document numbers
-   Attachment filenames where sensitive
-   Photos/documents
-   Backup contents
-   Encryption keys
-   Extracted private fields

## Local protection

Use:

-   Device private application storage
-   Biometric/PIN application lock
-   Platform secure storage for key material
-   Encrypted backup archives
-   Appropriate database/file encryption strategy based on threat model

## Recovery key separation

A backup must not contain its own usable decryption key.

Recovery must survive device loss, so it cannot depend solely on a key
stored in the lost device's secure enclave/keystore.

## Privacy classification

Fields should support:

``` text
share_safe
personal
sensitive
never_share
```

This classification must be enforced in domain/application logic and
reused by:

-   Stories
-   Export
-   Diagnostics
-   Future integrations

## Sharing principle

Sharing is an explicit local export operation.

Raw timeline records are not made public. The app generates a sanitized
artifact containing only user-approved shareable fields.

### Memory Media

Imported Memory Media defaults to `personal` and stays in app-private storage.
Dimensions, orientation correction, checksums, an optional captured timestamp,
and local storage state may be retained. Precise GPS is not converted into a
timeline location or searchable field. V1 requests no full photo metadata
from the picker and performs no automatic recognition, face inference,
location inference, embedding, upload, analytics, or camera-roll ingestion.

Evidence images are excluded from ordinary Story choices at the source
boundary. Eligible Memory Media still passes through `StoryPrivacySanitizer`;
`never_share` media is never selectable. An archived thumbnail is a browsing
preview only and cannot silently replace the original in a Story export.

### Story export temporary files

Story exports introduce a deliberate local-to-external privacy boundary:

- Raw timeline records never go directly to Story rendering. A mandatory
  sanitizer first produces a bounded composition containing only explicitly
  included fields and images.
- `never_share` fields and images cannot be selected, and the sanitizer
  rejects them even if a caller forges their identifiers.
- Personal and sensitive values are excluded by default. Public titles and
  captions are separately authored export text rather than implicit copies of
  timeline values.
- Relationship, evidence, and attachment classifications participate in the
  strictest effective classification. Only confirmed records and confirmed
  relationships can contribute Story content.
- PNG rendering occurs on-device. Life Timeline does not upload the rendered
  bytes.
- The PNG is written to an app-owned temporary directory under a random,
  non-content filename. The exact file is deleted after the share operation in
  both success and failure paths; matching stale exports older than 24 hours
  are also removed.
- Cleanup is restricted to the owned Story-export directory and filename
  pattern. It must never scan or delete user-selected source media.
- The operating-system share sheet is an explicit transfer boundary. After
  the user selects another app, that recipient controls its copy and handling.

V1 does not perform visual redaction inside user-selected photos. The review
UI therefore warns users to inspect images for faces, addresses,
notifications, documents, location clues, or other visible private details.
Story draft, export, and share history are not persisted.

### Storage Manager and archive boundary

Storage analysis remains on-device. File sizes and SHA-256 hashes are used for
local integrity, duplicate grouping, and copy-protection calculations; they
are not logged or uploaded. Duplicate detection is advisory and never silently
deletes a file.

Archive is an explicit local-to-user-owned-storage boundary. One selected
app-managed original is encrypted locally before the operating-system picker
receives it. The database retains only a logical filename, sizes, hashes,
format/algorithm identifiers, and verification timestamps. It does not retain
the recovery password, key, provider credential, or durable absolute provider
path.

A local original may be removed only after the encrypted destination verifies,
the archive reference commits while the local file still exists, and the user
explicitly opted into removal. Retrieval requires explicit file reconnection,
authentication, decryption, and original-hash verification before an
app-managed path is restored.

Temporary cleanup is restricted to documented app-owned directories, filename
patterns, and a 24-hour stale threshold. It must not traverse user-selected
archive destinations or referenced-original paths.

## Claims

Avoid absolute marketing claims unless technically true.

Preferred wording:

> Your Life Timeline data is stored locally on your device and in
> backups you control. We do not operate a cloud copy of your timeline.
