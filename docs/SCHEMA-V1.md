# Drift schema evolution

Schema v1 is the Phase 1 persistence baseline. It contains the core timeline,
provenance, candidate, attachment-metadata, and taxonomy records. Attachment
photo and document bytes remain outside SQLite; the database stores relative
local references and integrity metadata only.

## Tables

- Core: `entities`, `events`, `evidence`, `relationships`
- Attachment metadata: `attachments`
- Inbox and explainability: `memory_candidates`, `field_provenance`
- Taxonomy: `tags`, `categories`
- Assignments: `entity_tags`, `event_tags`, `evidence_tags`,
  `entity_categories`, `event_categories`, `evidence_categories`

Foreign keys are enabled on every connection. User-owned records use lifecycle
state plus a deletion timestamp for soft deletion. Join tables use composite
primary keys. Normalized tag and category names are unique.

## Indexes

The 33 declared indexes cover lifecycle filtering; normalized entity names;
event and candidate temporal starts; evidence type; attachment ownership,
storage state, and checksum; every relationship endpoint; every provenance
target; category parent lookup; and reverse lookup through every taxonomy join.
SQLite also creates indexes for primary-key and unique constraints.

## Schema v2 local full-text search

Schema v2 adds the additive `event_search` FTS5 virtual table for the Phase 1
manual-memory vertical slice. It indexes only:

- event title;
- event description;
- event type;
- related entity names;
- assigned category names.

The FTS table is local and part of the same device-owned database. Local search
can find every privacy classification, including `never_share`, because that
classification restricts sharing rather than the user's private on-device
retrieval. Results retain their classification and the UI displays it. Search
returns matched-field labels instead of raw snippets, so generic result helpers
do not reproduce private descriptions or related names.

Attachment display names, local paths, filenames, extracted document text, and
binary content are never indexed. Active search filters to confirmed events.
Archived records remain preserved but are excluded from normal search; restored
records become searchable again. Soft deletion removes the derived FTS row.
Editing a memory rebuilds its FTS row transactionally, including privacy or
relationship/category changes. Search queries and content are never logged.

## Migration policy

New installations create the current relational schema and FTS index. Existing
v1 installations receive an additive v1-to-v2 migration and index backfill.
Every future schema version must have a reviewed migration and migration tests.
Production code has no reset-on-schema-change fallback.
