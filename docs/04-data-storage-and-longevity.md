# Data Storage & Longevity

## Source of truth

Structured data lives in SQLite through Drift.

Large binary data must not be stored as SQLite blobs.

``` text
SQLite
├── entities
├── events
├── evidence
├── relationships
├── attachments metadata
├── field provenance
├── reminders
├── tags
├── candidate memories
└── search index

Filesystem
├── attachments/
├── thumbnails/
├── temporary/
└── exports/
```

## Attachment storage states

Attachment metadata is stored separately from contextual links. An attachment
link has exactly one parent and one semantic role:

``` text
Event    -> hero_media | memory_media
Evidence -> evidence
```

An Event has at most one `hero_media` link. Explicit `sort_order` provides
stable gallery ordering. Removing a link is different from deleting an asset;
physical deletion requires a reference check and staged filesystem cleanup.
SQLite stores only metadata and app-relative/local references, never image or
document bytes.

``` text
local
referenced
archived
unavailable
```

The model must allow the timeline record to remain useful when an
original file has been archived or is temporarily unavailable.

## Import modes

Where technically reliable:

1.  Reference original --- minimal extra storage, less durable.
2.  Keep optimized copy --- recommended default for many images.
3.  Preserve original --- maximum fidelity.

Never imply a referenced file is safely preserved.

## Longevity requirements

This is a decades-long data product. Treat compatibility as a feature.

Required:

-   Explicit schema migrations
-   Backup format versioning
-   Manifest versioning
-   Checksums
-   Corruption detection
-   Restore validation
-   Backward-compatible import where practical
-   Original attachment preservation when requested
-   Human-readable exports

## Open exit

Users must be able to leave.

Long-term export targets:

-   JSON structured export
-   CSV tables where meaningful
-   Human-readable PDF/report export
-   Original files in organized folders
-   Full encrypted application backup for exact restoration

Do not intentionally create data lock-in.
