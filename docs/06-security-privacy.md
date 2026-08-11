# Security & Privacy

## Privacy posture

The developer should not possess a server-side copy of the user's
timeline.

No account is required for core functionality.

If future telemetry, purchases, support or optional services process
personal data, those systems must remain clearly separated from timeline
content.

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

## Claims

Avoid absolute marketing claims unless technically true.

Preferred wording:

> Your Life Timeline data is stored locally on your device and in
> backups you control. We do not operate a cloud copy of your timeline.
