# ADR-0009: Shared Attachment Assets with Contextual Media Roles

-   Status: Accepted
-   Date: 2026-08-12

## Context

The original Phase 1 schema made every attachment belong directly to Evidence.
That was sufficient for scanned receipts and document OCR, but it incorrectly
made an ordinary memory photograph answer "what proves this?" instead of "what
did this moment look like?" It also made safe sharing, gallery order, hero
selection, shared references, and archive-preview behavior ambiguous.

## Decision

An `attachments` row represents one file asset and owns storage/integrity
metadata only. An `attachment_links` row supplies context:

- `hero_media` or `memory_media` links have one Event parent;
- `evidence` links have one Evidence parent;
- each link may carry caption, stable order, captured time, and import time;
- an Event has at most one hero link, enforced by a partial unique index.

Memory Media and Evidence reuse the same files, checksums, thumbnails, backup,
archive, retrieval, and corruption handling. Removing a link does not imply
file deletion. Physical deletion requires zero remaining links, provenance
references, and archive references, then a staged managed-file cleanup.

Existing schema-v6 attachment ownership migrates conservatively to `evidence`
links. Existing image evidence is not silently reclassified as Memory Media.
The migration preserves archive and attachment-provenance rows and never
resets the database.

Story source construction may read only Event-linked Memory Media. Evidence is
excluded before Story selection and remains subject to a separate future
product decision. `StoryPrivacySanitizer` remains authoritative for all Story
media.

## Relationship to accepted ADRs

This ADR extends ADR-0003. It retains the Entity/Event/Evidence/Relationship
model while correcting the narrower assumption that every attachment is
Evidence-owned. It follows ADR-0005 for user-owned backup/archive and ADR-0007
for sanitized local Story export.

## Consequences

- Schema v7 rebuilds attachment metadata without binary data and adds the link
  table plus explicit indexes and constraints.
- Features use `MemoryMediaRepository`; widgets never access Drift.
- Caption search is local FTS text only. No image recognition, embeddings,
  face inference, GPS conversion, cloud dependency, analytics, or automatic
  camera-roll ingestion is introduced.
- Video can later add compatible asset MIME types and renderers without
  changing the contextual ownership decision.
