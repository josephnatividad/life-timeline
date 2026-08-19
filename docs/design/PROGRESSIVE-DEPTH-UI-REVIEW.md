# Progressive Depth UI Review

Status: implementation review

## Scope and authority

This review inspected the implemented Flutter widgets, routes, Riverpod
providers, repository interfaces, and Drift implementations. It is not an
interpretation of the reference mockup alone. `AGENTS.md`, the PDD, accepted
ADRs, `08-ui-design-system.md`, and `09-motion-icons-illustration.md` win where
sources differ.

No schema migration, backup-format change, network service, cloud dependency,
or product capability was added.

## Timeline / Home

- **Before problem:** rendering was lazy, but each row subscribed to the full
  media collection merely to find a hero image. Timeline and Home are not
  separate screens in the actual app.
- **Classification:** needs query refinement; visual hierarchy healthy.
- **Change made:** timeline rows now subscribe to a hero-only query.
- **Resulting hierarchy:** one authoritative chronological landing experience.
- **Primitives:** existing timeline nodes/connectors retained.
- **Remaining debt:** confirmed memories are still materialized as one read
  model before temporal grouping; introduce cursor pagination only with a
  deliberate temporal-ordering and scroll-restoration design.

## Memory Detail

- **Before problem:** a single scroll rendered every media tile, evidence row,
  and historical reminder. Evidence used relationship lookup plus N+1 evidence
  and attachment queries. Technical created/updated/status rows permanently
  followed emotional content. Empty evidence and reminders consumed space.
- **Classification:** needed drill-down architecture.
- **Change made:** retained hero, identity, temporal context, badges, About, and
  visible Create Story/Add photo actions. Photos are bounded to four non-hero
  previews, evidence to three rows, and reminders to two rows; each shows the
  full count and focused destination when needed. Empty optional sections are
  silent. Related remains one conditional row. Technical record details moved
  to More; archive/trash remain separated management actions.
- **Resulting hierarchy:** identity -> meaning/actions -> conditional supporting
  previews -> More for utility.
- **Primitives:** `AppSection`, `AppCollectionPreview`, semantic count headers.
- **Remaining debt:** the model exposes only one `relatedEntity` in the memory
  read model. A Relationships destination would be empty architecture until a
  real collection/query exists.

## Media and Evidence

- **Before problem:** Memory Detail fetched and rendered complete collections;
  evidence used N+1 queries.
- **Classification:** needed drill-down architecture.
- **Change made:** added bounded media preview, hero, and count repository
  streams; added one joined evidence collection query returning total count and
  bounded rows. Memory Gallery and Memory Evidence own full collection views.
- **Resulting hierarchy:** preview -> collection -> existing viewer/actions.
- **Remaining debt:** Gallery management currently uses a full Drift stream and
  a shrink-wrapped grid. This is acceptable for the present Phase 1 fixture but
  should become a sliver/lazy grid before stress beyond the documented 50-photo
  case.

## Explore / Insights

- **Before problem:** Insights, Things, Years, Places, and Categories formed an
  endlessly extensible dashboard rhythm. Provider invalidation watched and
  materialized active, archived, and trashed memory lists. A raw place-history
  placeholder was visible.
- **Classification:** needed refinement.
- **Change made:** one For You insight leads; at most two recent insights appear
  with an Insights drill-down. Things, Places, Years, and Categories are grouped
  under one Browse your life section. Optional browse rows disappear when
  empty. Place overview results are bounded. A lightweight timeline revision
  stream invalidates deterministic insight loaders without loading three full
  memory collections solely for reactivity.
- **Resulting hierarchy:** Ask -> For You -> Recent insights when present ->
  Browse your life.
- **Remaining debt:** deterministic queries still execute against the complete
  local history by design; large-fixture profiling should guide indexes or
  aggregate read models rather than arbitrary presentation limits.

## Stories

- **Before problem:** the root mixed creation, milestone discovery, up to 20
  memory sources, and up to 10 entity sources.
- **Classification:** needed refinement.
- **Change made:** creation is the primary section, For You owns bounded
  milestone suggestions, recent memories show three rows, and a dedicated
  chooser owns all confirmed memory sources. Entity sources are conditional and
  bounded to three.
- **Resulting hierarchy:** Create something -> For You -> Recent memories ->
  conditional things/places.
- **Remaining debt:** milestone detection still evaluates the complete memory
  list. It is deterministic and local, but should be benchmarked with the
  10,000-memory fixture. No Recent Story library was added because ADR-0008
  defines V1 Stories as ephemeral and forbids drafts/history/library.

## Reminders

- **Before problem:** every reminder linked to a memory rendered inline on
  Memory Detail. The global screen grouped full lists in nested columns.
- **Classification:** parent needed refinement; dedicated screen remains the
  collection owner.
- **Change made:** added a two-row/count query-backed preview and optional
  memory-filtered Reminders route. Empty detail reminders disappear; Add
  reminder remains discoverable in More. Empty root wording now describes a
  clear state and offers the contextual action.
- **Remaining debt:** the dedicated screen should move to sliver groups if
  profiling shows very large inactive histories cause frame cost.

## Storage Manager

- **Before problem:** summary, breakdown, backup protection, optimization,
  archive selection, archived retrieval, and diagnostics shared one long page.
- **Classification:** overloaded.
- **Change made:** Storage retains overview, protection, safe opportunities,
  attention state, and an archive count/navigation row. A focused Archived
  originals screen owns selection, encryption handoff, and retrieval.
- **Resulting hierarchy:** understand storage -> open archive management when
  intended.
- **Remaining debt:** inventory calculation necessarily scans app-owned files;
  future work should profile scanning/caching rather than hiding values.

## Inbox, Search, Archive, Trash, and Settings

- **Before problem:** Inbox and Search empty wording was generic. The other
  screens already had one job and lazy collection rendering.
- **Classification:** healthy; wording-only refinement where useful.
- **Change made:** Inbox uses the completed state `You're all caught up`.
  Search distinguishes no results and provides Clear search. Archive, Trash,
  You, Security, backup/restore, Add/Edit Memory, Capture, Candidate Review,
  Ask My Life, Story Editor/Preview, media viewer, and reorder were intentionally
  not restructured.
- **Remaining debt:** none specific to Progressive Depth.

## Empty-state audit

`AppEmptyState` now supports restrained hero, section, and compact
presentations. Error and loading remain separate types. Optional Memory Detail
sections are silent when empty, preventing stacked advertisements for Photos,
Evidence, Relationships, Reminders, Stories, and Insights. OCR unavailable and
permission-required flows remain feature-specific and were not converted into
generic empty data.

## Accessibility and motion

- Section headings retain header semantics; collection counts are announced.
- `View all` labels identify the destination.
- Dynamic Type can wrap section actions and primary actions.
- Full management remains available without gestures.
- Routes use the existing reduced-motion-aware GoRouter transition foundation;
  no independent section entrance animations were added.
- Hugeicons remain accessed only through `AppIcons`.

## Screenshots

No emulator screenshot was captured during this code-only review. Widget tests,
light/dark themes, text scaling, and Reduced Motion are the verification source
for the implementation; a signed-in or device-specific visual session is not
required for these local UI changes.
