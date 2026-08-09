# Drift schema v1

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

## Full-text search deferral

SQLite FTS remains a Phase 1 MVP requirement, but it is intentionally not part
of schema v1. Before adding an FTS virtual table, the project must accept rules
for all of the following:

- which fields from `sensitive` and `never_share` records may be tokenized;
- how privacy-classification changes remove previously indexed tokens;
- how archived and soft-deleted records are excluded and how indexes rebuild;
- whether evidence display names are searchable without indexing local paths or
  leaking attachment metadata into snippets.

Adding FTS without these rules would create a second, less-visible copy of
private text and ambiguous deletion behavior. The v1 normalized title/name
columns, stable IDs, lifecycle columns, and privacy classifications prepare a
deterministic additive FTS migration. Basic local FTS must be added and tested
before the MVP search feature is implemented; this deferral does not move local
search out of Phase 1.

## Migration policy

New installations create v1 with `createAll`. Every future schema version must
have a reviewed, additive migration and migration tests. Production code has no
reset-on-schema-change fallback.
