# Stories V1

## Status

Implemented for Phase 1 as a local-only composition, rendering, preview, and system-share workflow. This document describes the shipped V1 boundary; it does not expand the roadmap or introduce cloud services.

## Product intent

Stories turn confirmed timeline records into deliberately shareable, vertical visual summaries. They follow the Quiet Intelligence direction: restrained layouts, clear hierarchy, calm colors, and explicit user control. A Story is an ephemeral export derived from the timeline, not a second source of truth.

The working product name remains Life Timeline. The default attribution is configurable and must not be treated as confirmation of a final app name.

## Supported sources

- Confirmed Event records.
- Confirmed Entity histories built only from confirmed relationships and confirmed Events.
- Deterministic milestone candidates.
- An explicit Then & Now pair of two different confirmed Events.

Event and entity Story photo choices are sourced only from event-linked Memory
Media. Evidence attachments are excluded at the source boundary. Archived
full-resolution media is represented as requiring retrieval and is not
silently replaced by its retained thumbnail.

Archived, candidate, soft-deleted, and missing records are not Story sources. A calendar-year recap is intentionally deferred because the roadmap does not yet define its product rules.

## Composition pipeline

```text
confirmed domain records
  -> StorySource with per-field and per-image privacy metadata
  -> explicit StoryPrivacySelection
  -> mandatory StoryPrivacySanitizer
  -> immutable StoryComposition
  -> fixed Story renderer
  -> local PNG preview
  -> system share sheet
  -> scoped temporary-file cleanup
```

Presentation code cannot pass a raw Event, Entity, Evidence, Attachment, or database row to the renderer. The renderer accepts only a sanitized `StoryComposition`.

## Templates

| Template | Intended use | Media limit | V1 availability |
| --- | --- | ---: | --- |
| Minimal | Typographic memory or milestone | 0 | Core |
| Photo | One photo with bounded text | 1 | Core |
| Stats | A milestone or entity statistic | 0 | Core |
| Journey | Entity history or chronological context | 1 | Core |
| Then & Now | Explicit comparison of two memories | 2 | Core |

Template eligibility is source-aware. Unsupported template/source combinations are rejected by the composer instead of being approximated in the UI. The catalog carries a future entitlement tier and is checked through the existing entitlement service; V1 does not impose a paid gate.

## Privacy policy

Privacy filtering is a domain/application invariant, not a visual convention.

| Classification | Default | Can the user include it? |
| --- | --- | --- |
| `shareSafe` | Suggested when the source and every contributing relationship are share-safe | Yes |
| `personal` | Excluded | Yes, only by explicit selection |
| `sensitive` | Excluded | Yes, only by explicit selection |
| `neverShare` | Excluded | No |

Additional rules:

- A `neverShare` field or image remains excluded even if a forged selection contains its identifier.
- Relationship privacy participates in entity history, related-entity, evidence, attachment, device, and ownership-derived content. A more permissive parent cannot weaken a protected child or relationship.
- Only confirmed relationships contribute data.
- Detailed dates and descriptions are private by default. Approximate temporal values retain their uncertainty; no exact date is invented.
- A public title and caption are newly authored export text. They are never silently copied from private source text and are length-bounded before rendering.
- The privacy review lists what is included and what remains private before the share action.
- Image selection is explicit. Users are reminded that visible details inside an image are not automatically redacted.

## Rendering and export

The canonical canvas is 360 by 640 logical pixels at a 3.0 pixel ratio. The exported PNG is therefore exactly 1080 by 1920 pixels. Story typography is fixed inside the exported artifact so operating-system text scaling does not change output dimensions; editor and preview controls still support Dynamic Type.

The renderer captures a dedicated `RepaintBoundary`, validates logical and output dimensions, encodes PNG bytes locally, and disposes native image resources. Missing or unreadable photos use a neutral fallback surface. Text regions have bounded lines and overflow handling.

Sharing writes a randomly named PNG into the app-owned temporary Story export directory, invokes the operating system share sheet, and deletes that exact file in a `finally` path. Startup/editor maintenance also removes matching Story PNGs older than 24 hours. Cleanup is scoped to the owned directory and filename pattern. No Story bytes are uploaded by Life Timeline.

## Milestones

Milestones are deterministic and computed from confirmed local records:

- 1, 5, 10, and 20-year anniversaries.
- The 100th confirmed memory.
- The 5th and 10th distinct recorded device acquisition.
- A significant recorded device ownership chapter of at least five years, requiring explicit acquisition and disposal events.

“Today” is used only for exact dates whose month and day match. Month, year, and approximate precision use “About”; ranges, before/after, unknown dates, and exact dates on another day do not become today-anniversaries. Milestones are suggestions, not persisted facts.

## Then & Now

Then & Now requires the user to select two different confirmed memories. The pair is not auto-inferred. The template takes at most the first eligible image from each memory and keeps the two sources’ field and media classifications. Selecting the same memory twice is rejected in both UI and domain logic.

## Persistence and architecture

Story composition, milestones, preview state, and exports are ephemeral. V1 adds no Drift table, schema migration, backup payload, cloud service, account dependency, analytics event, or Story history. Source identifiers exist in memory only to maintain traceability while composing.

Ports isolate source creation, sanitization, composition, image rendering, media picking, temporary files, and system sharing. Riverpod provides concrete adapters. Feature widgets never access Drift directly.

## Known limitations and deferred work

- Image content is not visually redacted. The user must inspect faces, addresses, notifications, documents, and other visible details.
- Once the system share sheet hands the PNG to another app, that recipient controls its copy and privacy behavior.
- V1 does not persist drafts, exports, or share history.
- There is no local “save to gallery” workflow; the system share targets determine available destinations.
- Automated best-pair suggestions, Life Wrapped/year recap, video, animation export, custom signature illustrations, and paid template enforcement remain deferred.
- Physical share-sheet behavior and destination availability vary by operating system and installed apps and require device QA.

## Acceptance summary

V1 is complete when all five templates render locally, exact 1080 by 1920 output is verified, `neverShare` data cannot enter a composition, explicit private-field inclusion works, temporary files are cleaned on success and failure, milestones respect temporal precision, and Then & Now rejects same-record pairs.
