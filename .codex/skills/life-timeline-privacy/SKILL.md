---
name: life-timeline-privacy
description: >
  Use whenever work touches personal timeline content, files, AI, OCR, analytics, diagnostics, sharing, export, backup, archive, encryption, or recovery. Enforces local-first privacy, privacy classifications, sanitized Stories, safe telemetry, user-owned encrypted backups, and explicit review before off-device transmission.
---

# Life Timeline Privacy & Data Safety Skill

Use whenever code touches personal content, files, sharing, analytics,
AI, backup, export or diagnostics.

## Non-negotiable

The company does not receive a cloud copy of the timeline in the default
architecture.

## Never send to telemetry

Timeline text, OCR text, searches, document numbers, sensitive
filenames, photos/documents, backup contents, encryption keys.

## Sharing

Every field has/derives a privacy class: share_safe, personal,
sensitive, never_share.

Story generation must pass through the privacy sanitizer.

`never_share` cannot be overridden by ordinary Story UI.

## AI

Prefer local processing. AI output is a candidate, not confirmed truth.
Retain provenance/confidence where applicable.

## Backup

Encrypt before leaving the device. Do not store the usable recovery key
inside the backup. Restore must work after loss of the original device.

## Review

If a new dependency transmits user content off-device, stop and require
an explicit architecture/privacy decision.
