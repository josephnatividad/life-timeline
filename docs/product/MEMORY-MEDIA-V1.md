# Memory Media V1

## Status and boundary

Implemented as the Phase 1 local-first image vertical slice. PDD documents,
accepted ADRs, `AGENTS.md`, and the official design system remain authoritative.
This feature adds no backend, account, cloud storage, cloud AI, analytics,
automatic camera-roll ingestion, social feed, or photo-backup service.

## Memory Media versus Evidence

Memory Media answers "what did this moment look like?" Evidence answers "what
supports or proves this memory?" Both use one attachment-asset model for paths,
checksums, thumbnails, backup, archive, and integrity, but contextual links
retain different semantics:

| Parent | Role | Ordinary Story choice |
| --- | --- | --- |
| Event | `hero_media` | Eligible after privacy review |
| Event | `memory_media` | Eligible after privacy review |
| Evidence | `evidence` | Excluded |

An asset may have multiple links. Links, not files, own captions and order.
Existing pre-v7 attachments migrate to Evidence links; migration never guesses
that an old proof image is a personal photograph.

## Hero and gallery behavior

- A memory has zero or one hero image and any number of gallery links.
- The first newly imported photo becomes the initial hero. This convenience is
  an explicit V1 behavior and remains subject to product approval.
- Setting a new hero demotes the prior hero without changing files or order.
- Clearing or removing the hero does not promote another photo automatically.
- Stable integer order is persisted on links. Reorder changes no attachment
  checksum, provenance, privacy, archive state, or bytes.
- Captions are optional and participate in local SQLite FTS. The image itself
  does not affect factual Ask My Life answers.

The UI is optimized for curated selection, but storage has no permanent media
count limit. Timeline views load thumbnails; gallery thumbnails use bounded
decode widths; the viewer pages images and loads a display version on demand.

## Add and capture flows

Add/Edit Memory and Memory Detail expose Add Photo with Take Photo and Choose
from Photos. This path never runs OCR. The global Capture surface distinguishes:

- Add Memory â€” record something that happened;
- Add Photos â€” choose a memory, then add photographs;
- Scan Document â€” explicitly run the existing local extraction/review flow.

Expensive image preparation runs outside the UI isolate and processes multiple
selections sequentially to bound memory use.

## Supported images and processing

JPEG, PNG, and WebP are decoded by the existing safe image library, have
orientation baked, dimensions recorded, a bounded display JPEG produced, a
thumbnail produced, and SHA-256 values calculated. Source files are never
overwritten. Preserving the managed original is the V1 default.

HEIC/HEIF is accepted where the platform can safely display it. If the Dart
decoder cannot transcode it, the app retains a durable managed original rather
than destructively approximating it; thumbnail/display availability then
depends on platform decoding. A dedicated cross-platform HEIC transcoder is
deferred pending dependency/license/maintenance approval.

The picker requests no full metadata. V1 records dimensions and optional
captured time only when a trusted source supplies it. It does not persist GPS
into searchable fields, infer locations or people, or create embeddings.

## Privacy

Memory Media defaults to `personal`. Direct photo sharing is exposed only for
`share_safe` media and always invokes the system share sheet explicitly.
Stories may offer `personal` or `sensitive` media only through explicit
selection; `never_share` is impossible to select. The strictest effective
classification of the Event and attachment is used. Visible image details are
not automatically redacted, so Story review remains mandatory.

## Remove and delete

Remove from this memory deletes only the contextual link. Delete managed photo
first removes that link, then checks all other Event/Evidence links,
attachment-target provenance, and archive references. If protected references
remain, the physical asset stays. If none remain, the row is soft-staged,
managed files are deleted inside the guarded attachment root, and only then is
the row purged. A cleanup failure therefore leaves a tracked tombstone rather
than an untracked orphan.

## Storage, archive, and backup

Storage Manager classifies Event-linked images as Photos and evidence-only
images as Documents/Evidence. All participate in checksums, duplicate review,
optimization, copy protection, archive, and retrieval.

For an optimized image with a preserved original, archive encrypts the
preserved original while retaining the display image and thumbnail. The
archive reference records the source slot. If local removal is requested, only
the archived source slot is cleared after destination verification. Retrieval
restores that same slot.

Encrypted manual backup includes managed display files, thumbnails, preserved
originals, attachment metadata, contextual links, hero role, order, captions,
privacy, checksums, and archive references. Fresh-install restore inserts
assets before links and rebuilds local FTS. Portable pre-v7 snapshots are
upgraded conservatively to Evidence links.

## Stories

Story source creation queries Memory Media directly. Evidence is excluded at
the source boundary. Then & Now uses eligible media from each Event. If a full
original is archived, the editor explains that retrieval is needed and links
to Storage Manager; it never exports the retained thumbnail as a hidden
high-resolution substitute.

## Future video path

The asset/link model can later support video MIME types, poster thumbnails,
duration, and a dedicated viewer/renderer. V1 deliberately adds no video
transcoding, editing, audio workflow, autoplay, or Story video export.

## Human approval still required

- Confirm first-imported-photo-as-hero as final product behavior.
- Confirm whether direct sharing should remain `share_safe`-only or gain a
  separate warning/confirmation flow for `personal` media.
- Approve a maintained HEIC/HEIF transcoding dependency if consistent previews
  are required on platforms whose native decoder cannot display the file.
- Approve final localized permission, deletion, archive-retrieval, and visible
  privacy-warning copy.
