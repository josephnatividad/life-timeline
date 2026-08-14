# ADR-0011: Allowlisted Network and Automatic User-Owned Backup

- Status: Accepted
- Date: 2026-08-14

## Context

Life Timeline is local-first and operates no company timeline cloud. Automatic
off-device protection nevertheless requires a narrowly approved user-owned
destination. The former ML Kit OCR SDK also documented native utilization and
performance metrics, making a general Internet permission incompatible with
the privacy posture while that SDK remained linked.

## Decision

Network access is deny-by-default even when the application has platform
Internet permission. Each external service requires explicit architecture and
privacy approval plus a narrow application port.

The first approved service is Google Drive acting only as an encrypted
`BackupDestination`:

- remove ML Kit from network-enabled native dependency graphs first;
- request only the Google Drive `drive.appdata` scope;
- upload only locally encrypted and verified LTBACK01 artifacts;
- reuse the existing backup builder, restore pipeline, and integrity checks;
- keep the feature optional and off by default;
- store an unattended recovery password only after explicit opt-in in
  non-migrating, device-only secure storage;
- retain older generations until a new upload is verified;
- treat background scheduling as opportunistic and expose health/attention in
  the UI;
- keep provider SDK/API types inside infrastructure.

OCR, Ask My Life, Insights, Stories, search, classification, extraction, and
image processing remain local and may not reuse the Drive transport. No cloud
OCR fallback is permitted. Google Drive connection is not a Life Timeline
account.

## Consequences

- Android release builds may declare Internet/network-state permissions for
  the approved backup path.
- Every release must audit Dart, Android, and iOS dependency graphs for
  analytics, ads, telemetry, remote OCR, and unapproved network clients.
- Google receives OAuth/network metadata, opaque encrypted bytes, and bounded
  backup-generation metadata; Life Timeline infrastructure receives no user
  timeline content.
- Final Google OAuth identities, signing fingerprints, iOS URL schemes, and
  bundle identifiers are deployment configuration and require human approval.
- Public V1 still requires either a privacy-approved local OCR implementation
  or an explicit product decision to ship manual document capture without OCR.
