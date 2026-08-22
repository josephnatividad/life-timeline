# Progressive Depth UI Review

Status: implementation and scale-hardening review complete

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
- **Scale verification:** repository/query and widget checks pass with 10,000
  confirmed memories, and the Timeline builds only visible event tiles. The
  read model is still materialized before temporal grouping, but current
  measurements do not justify cursor-pagination and scroll-restoration
  complexity. Reassess only if representative midrange-device profiling
  exceeds the documented budget.

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
- **Hardening follow-up:** Gallery management retains the full Drift collection
  because it owns the collection, but now renders through one lazy
  `CustomScrollView` and `SliverGrid`. A 50-photo fixture verifies that only
  viewport-adjacent image widgets are constructed.

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
- **Scale verification:** deterministic queries still execute against complete
  local history by design. The 100, 1,000, and 10,000-memory query smoke tests
  pass, while the Explore place surface remains bounded to six records. No
  aggregate read model is warranted by current measurements.

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
- **Scale verification:** milestone detection still evaluates the complete
  memory list, but the 10,000-memory benchmark passes its five-second local
  budget. No Recent Story library was added because the implemented Stories V1
  product boundary defines compositions and exports as ephemeral. ADR-0007
  governs sanitized local export; ADR-0008 governs one-time Pro monetization.

## Reminders

- **Before problem:** every reminder linked to a memory rendered inline on
  Memory Detail. The global screen grouped full lists in nested columns.
- **Classification:** parent needed refinement; dedicated screen remains the
  collection owner.
- **Change made:** added a two-row/count query-backed preview and optional
  memory-filtered Reminders route. Empty detail reminders disappear; Add
  reminder remains discoverable in More. Empty root wording now describes a
  clear state and offers the contextual action.
- **Hardening follow-up:** the dedicated screen now uses lazy sliver groups. A
  500-reminder fixture verifies that the full inactive history is not eagerly
  constructed.

## Storage Manager

- **Before problem:** summary, breakdown, backup protection, optimization,
  archive selection, archived retrieval, and diagnostics shared one long page.
- **Classification:** overloaded.
- **Change made:** Storage retains overview, protection, safe opportunities,
  attention state, and an archive count/navigation row. A focused Archived
  originals screen owns selection, encryption handoff, and retrieval.
- **Resulting hierarchy:** understand storage -> open archive management when
  intended.
- **Scale verification:** inventory calculation necessarily scans app-owned
  files and verifies hashes rather than trusting stale presentation metadata. A
  500-file fixture passes its ten-second local budget. Caching is intentionally
  deferred because safe invalidation must not conceal missing or changed files.

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

`AppEmptyState` supports restrained hero, section, and compact presentations,
an optional description, and primary/secondary contextual actions. Semantic
wrappers now distinguish `AppNoResultsState`, `AppCompletedState`,
`AppUnavailableState`, and `AppPermissionRequiredState`; loading and error
remain separate types.

| Context | Meaning and treatment |
| --- | --- |
| Fresh install / Timeline | First-use hero: `Your story starts here` with Add memory and a quieter Restore existing timeline action. |
| Explore | When all overview collections are empty, one first-use hero replaces separate For You and Browse empty blocks. Partially populated Explore shows only sections with content. |
| Stories | First-use hero offers Add memory. Optional milestone discovery is silent until candidates exist. |
| Memory Inbox | Completed/clear: `You're all caught up`; an error still uses `AppErrorState`. |
| Reminders | Completed/clear: `Nothing needs your attention` with Add reminder. The notification permission surface is semantically permission-required. |
| Search | Initial guidance is distinct from a completed query. A zero-match query uses `AppNoResultsState` with Clear search. No filter UI exists yet, so a filtered-empty state is intentionally not fabricated. |
| Trash | Completed/clear: `Trash is empty`. |
| Archive | True empty collection: `Archive is empty`; no unrelated CTA is added. |
| Memory Detail | Empty Photos, Evidence, Relationships, and Reminders remain silent. Add photo and other valid actions stay available through the primary actions or More. The focused Evidence collection has one contextual empty state. |
| Archived originals | When both collections are empty, one state replaces simultaneous Available and Archived empty sections. Partially populated screens show only the populated section. |
| Private OCR | `AppUnavailableState` explicitly says private text extraction is unavailable while manual, local document capture remains available. |
| Permission denied | Google Drive connection and local notification access are distinguished from empty data and expose only their relevant permission/connect actions. |
| Loading or failure | `AppLoadingState` and `AppErrorState` remain separate; a failure is never displayed as an empty collection. |

All ordinary state icons continue through `AppIcons`. No decorative
illustrations or state-specific animations were added. Optional preview loaders
for media/evidence/reminders do not introduce empty containers on Memory Detail,
and Reduced Motion retains a non-animated loading fallback.

## Accessibility and motion

- Section headings retain header semantics; collection counts are announced.
- `View all` labels identify the destination.
- Dynamic Type can wrap section actions and primary actions.
- Full management remains available without gestures.
- Routes use the existing reduced-motion-aware GoRouter transition foundation;
  no independent section entrance animations were added.
- Hugeicons remain accessed only through `AppIcons`.

## Screenshots and device session

The Android 17 Pixel 7 Pro emulator remained protected by an unknown existing
PIN; its light-mode gate is retained as
[`device-lock-gate-light.png`](screenshots/device-lock-gate-light.png). The
follow-up authenticated walkthrough completed on a physical Samsung SM-G955F
running Android 9 at system font scale 1.1. The validated debug APK was
update-installed with app data preserved. No timeline data was cleared, no
security control was bypassed, and no backup or restore operation was started.

The physical-device walkthrough covered Timeline, Memory Detail, Explore,
Stories, Capture, private-OCR unavailable/manual capture, Memory Inbox, Search
no-results, Reminders, Storage, Archived originals, Archive, Trash, Security &
recovery, and Restore entry. Timeline, Memory Detail, Stories, and Archived
originals contained user-owned titles, photos, or filenames; they were
inspected but no unredacted screenshots were retained in the repository.

Privacy-safe evidence includes:

- [`device-explore-light.png`](screenshots/device-explore-light.png)
- [`device-capture-sheet-light.png`](screenshots/device-capture-sheet-light.png)
- [`device-private-ocr-unavailable-light.png`](screenshots/device-private-ocr-unavailable-light.png)
- [`device-memory-inbox-light.png`](screenshots/device-memory-inbox-light.png)
- [`device-search-no-results-light.png`](screenshots/device-search-no-results-light.png)
- [`device-reminders-light.png`](screenshots/device-reminders-light.png)
- [`device-storage-light.png`](screenshots/device-storage-light.png)
- [`device-storage-management-light.png`](screenshots/device-storage-management-light.png)
- [`device-you-light.png`](screenshots/device-you-light.png)
- [`device-you-lifecycle-light.png`](screenshots/device-you-lifecycle-light.png)
- [`device-archive-empty-light.png`](screenshots/device-archive-empty-light.png)
- [`device-trash-empty-light.png`](screenshots/device-trash-empty-light.png)
- [`device-security-backup-light.png`](screenshots/device-security-backup-light.png)
- [`device-restore-entry-light.png`](screenshots/device-restore-entry-light.png)

Real-device findings:

- Memory Detail remained approximately constant in complexity: absent Photos,
  Evidence, and Reminders sections were silent while Create Story and Add photo
  stayed visible.
- Explore showed only its meaningful Years browse path; empty insight and other
  browse placeholders did not appear.
- Stories rendered three recent-memory rows despite a count of eight.
- Archived originals rendered lazily and omitted its empty Archived section.
- Back controls and shallow navigation were present on every pushed route
  inspected.
- Early captures taken during route/inset transitions showed temporarily
  clipped leading content. Settled recaptures were complete, confirming a
  capture-timing artifact rather than a layout defect.
- Resolved 2026-08-23: the disabled Material `DropdownButtonFormField`
  indicator and the date/time-picker navigation controls rendered as invalid
  glyphs on Android 9 because `uses-material-design` was false while Flutter's
  framework controls still relied on the Material Icons font. The framework
  font is now bundled, and app-owned dropdown indicators use the reusable
  `AppDropdownField` with Hugeicons through `AppIcons`.
- Resolved 2026-08-23: the Search leading magnifier crowded the floating outline
  label at font scale 1.1. Search now uses one visual hint plus an explicit
  text-field semantic label instead of duplicating the label in the outline.
- Resolved 2026-08-23: an ordinary one-image Story exposed every eligible
  Memory Media item as a repeated independent switch. The editor now presents
  one selected-photo summary and a focused single-choice photo sheet; choosing
  another image replaces the previous choice. Duplicate generic captions are
  numbered only in the chooser. Then & Now remains the intentional bounded
  two-photo exception with role-labelled Then and Now controls.

This Android 9 build did not accept the shell night-mode override, so no device
theme setting was changed. Dark mode, 2x text scaling, screen-reader semantics,
and Reduced Motion remain covered by focused widget tests rather than being
claimed as physical-device observations.

## Hardening validation

Validated on 2026-08-22 with the project-pinned FVM Flutter 3.44.9 stable SDK:

- Dart formatting completed for all changed Dart files.
- `flutter analyze --no-pub` completed with no issues.
- The complete Flutter suite passed: 263 tests.
- Android debug assembled successfully and installed on an Android 17 Pixel 7
  Pro emulator; the final APK is `build/app/outputs/flutter-apk/app-debug.apk`.
- Query and rendering fixtures cover 10,000 Timeline memories, a 10,000-memory
  Story milestone scan, 10,000 Explore place records, 50 photos, 30 evidence
  records, 500 reminders, and 500 app-managed files.
- iOS build/device verification remains unavailable on the Windows host.
- Android still reports the known future Built-in Kotlin migration warning for
  `file_picker`, `flutter_timezone`, `package_info_plus`, `share_plus`, and
  `workmanager_android`; it does not block the current debug build.

### UI defect follow-up validation

Validated on 2026-08-23 with the project-pinned FVM Flutter 3.44.9 stable SDK:

- Dart formatting completed across `lib/` and `test/` with no changes needed.
- `flutter analyze --no-pub` completed with no issues.
- The complete Flutter suite passed: 267 tests.
- Android debug assembled successfully at
  `build/app/outputs/flutter-apk/app-debug.apk`.
- APK inspection confirms
  `assets/flutter_assets/fonts/MaterialIcons-Regular.otf` is bundled for
  Flutter's framework-owned date/time-picker glyphs. Product-owned icons remain
  behind `AppIcons`.
- Story regression coverage verifies one-photo defaults for ordinary Stories,
  two-photo defaults for Then & Now, replacement selection in the editor, and
  a one-photo composer limit even for a forged multi-ID selection.
- A final physical-device recapture remains pending because no authorized
  Android device was visible to `adb` during this validation run. The prior
  Android 9 observation remains the reproduction evidence; no claim of a
  post-fix physical-device walkthrough is made.
