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

## Claims

Avoid absolute marketing claims unless technically true.

Preferred wording:

> Your Life Timeline data is stored locally on your device and in
> backups you control. We do not operate a cloud copy of your timeline.
