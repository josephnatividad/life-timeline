# Phase 1 UI Refinement

Status: implemented and verified in code; manual device screenshot review remains.

This document records the Phase 1 lifecycle and UX refinement pass. It is subordinate to `AGENTS.md`, the PDD, accepted ADRs, `08-ui-design-system.md`, and `09-motion-icons-illustration.md`. The reference image remains directional rather than authoritative.

## Scope and principles

The pass keeps the existing Phase 1 product boundary: local-first timeline management, private capture foundations, local search, app security, and encrypted backup/recovery. It adds no cloud service, backend, account, new AI capability, Story implementation, or monetization change.

The visual standard is Quiet Intelligence: strong content hierarchy, restrained surfaces, tokenized spacing and color, sparse accent use, calm language, and motion only when it explains a state or navigation change.

## Screens reviewed

| Area | Findings and resulting treatment |
| --- | --- |
| Timeline Home | The existing chronological line, nodes, grouped period headers, and non-card event rows already establish timeline identity. Archive was removed from the primary header; Inbox and Search remain the two relevant contextual actions. Imprecise dates continue to use the domain-aware temporal formatter. |
| Add/Edit Memory | Add and edit share `MemoryEditor`. Required identity, time, and privacy fields remain visible; description and related entity stay under `More details`. Edit mode expands optional details when existing content would otherwise be hidden. |
| Memory Detail | Title, temporal value, badges, description, relationships, evidence state, and history remain content-led. Edit and More are app-bar actions. Archive/restore and Trash are grouped in the standard bottom-sheet pattern instead of appearing as a settings-like destructive footer. |
| Search | Uses `AppSearchField`, debounced local search, hierarchical results, and product-specific initial/empty/error/loading states. No unvalidated filters were added. Archived and trashed memories remain excluded from normal search. |
| Memory Inbox | Candidate copy communicates review readiness without exposing raw confidence percentages. Candidate confirmation now preserves the navigation stack when opening the resulting Memory Detail. |
| Capture | Capture remains the central navigation action without an oversized floating control. The sheet communicates on-device processing and keeps manual entry available. Signature icon size now uses the official token. |
| Unlock/PIN | Existing focused local-lock hierarchy, semantic status messages, and tokenized controls were retained. No personal timeline content is exposed before unlock. |
| Backup/Restore | Existing staged selection, verification, local authentication/decryption, result states, and restored-data invalidation were retained. Restore refresh also invalidates Trash. |
| Explore | The existing honest foundation destination remains minimal and non-broken; no unapproved Explore features were invented. |
| Stories | The navigation destination remains a minimal foundation placeholder. No Story templates or creation behavior were added. |
| You / Settings | Archive and Trash are placed under a secondary `Memory lifecycle` section. Security and recovery remain the primary privacy/control destination. |
| Navigation shell | Timeline / Explore / Capture / Stories / You remains unchanged and scalable. Nested screens use the themed back icon and preserve the stack. |

## Lifecycle UX decisions

### Archive

- Archive is a reversible historical lifecycle state, not deletion.
- Archive is available from Memory Detail and provides Undo.
- Archived memories are excluded from the active timeline and normal search.
- The Archived Memories screen lives under You and permits restore or move to Trash.
- Archiving preserves the event aggregate, relationships, evidence, attachments, provenance, categories, and entities.

### Trash

- Moving a memory to Trash is a soft delete and provides Undo from active or archived contexts.
- Trashed memories are excluded from the active timeline and normal search.
- Trash lives under You and exposes explicit Restore and Permanently Delete actions.
- Restore from Trash returns a memory to the active timeline. It does not infer or recreate its previous archived state. This simple deterministic rule should only change with an approved product decision and corresponding persistence design.
- Opening the body of a Trash card performs no hidden action; restore requires the labeled restore control.

### Permanent deletion

- Permanent deletion is available only from Trash and requires explicit confirmation.
- The dialog explains that the memory, its direct links and provenance, orphaned supporting evidence, and app-managed copies may be removed. It also explains that shared entities and evidence remain.
- Database deletion is transactional. Failure before commit leaves the memory in Trash.
- Candidate links and direct event relationships are removed with the event.
- Evidence is deleted only when it is no longer referenced by another relationship, candidate, or provenance source. Shared categories and entities are preserved.
- SQLite stores attachment metadata and relative references only. After the database transaction commits, cleanup is restricted to app-managed files under the application attachments directory. External/referenced originals are never deleted.
- Filesystem cleanup is best-effort after commit. If it cannot complete, the UI truthfully reports that the memory was deleted but some app-managed files remain; it does not falsely claim the transaction was rolled back.
- Ordinary historical changes such as sold, replaced, expired, moved, or completed remain timeline history. Delete is intended for mistakes, duplicates, or explicit removal.

No lifecycle schema migration was required. Existing `RecordLifecycle`, `deleted_at`, foreign keys, and cascade rules support archive and soft deletion. Database schema v4 remains independently required for the accepted attachment-path migration; no reset-on-change behavior was introduced.

## Components changed or reused

- `TimelineNode`, `TimelineConnector`, `TimelineSectionHeader`, and `TimelineEventTile` retain the distinctive chronological structure rather than a generic card feed.
- `MemoryCard` now places trailing actions below its summary at large text scales, preserving readable hierarchy and touch targets.
- `LifecycleMemoryCard` composes `MemoryCard` and standardized icon actions for Archive and Trash instead of duplicating list styling.
- `MemoryEditor` continues to serve Add and Edit with progressive disclosure.
- `MemorySummary` uses `AppSectionHeader`, `AppBadge`, `PrivacyBadge`, and an intentional evidence empty state.
- `AppBottomSheet` is the common Memory Detail action surface.
- `AppEmptyState`, `AppLoadingState`, and `AppErrorState` are used for Archive and Trash and remain consistent across reviewed screens.
- All application icons use Hugeicons only through `AppIcons`; new lifecycle icons are archive, restore, trash, delete forever, and undo. Signature icon sizes use `AppIconSize` tokens.

Screen-specific components were retained where their semantics are genuinely local, such as temporal input and memory metadata rows. A generic catch-all row or utility was not introduced merely to reduce line count.

## Accessibility fixes and review

- Lifecycle actions have explicit screen-reader labels containing the affected memory title.
- Permanent deletion is never triggered by a card tap and is separated from Restore.
- Disabled/busy actions are removed from interaction rather than replaced with no-op callbacks.
- `MemoryCard` reflows action controls at large text scale; a widget test covers a 2x text scale in a narrow layout.
- Existing icon buttons retain the design-system 48dp minimum interactive target.
- Lifecycle and privacy states are expressed in text and semantics, not color alone.
- Error and progress states continue to use live-region semantics where state changes require announcement.
- Responsive layout uses tokenized constraints and text reflow rather than pixel-specific per-screen values.

## Dark mode review

- Archive and Trash use semantic Material 3 surface, outline, primary, and error colors rather than fixed light colors.
- The destructive action uses `colorScheme.error`; confirmation and feedback remain legible in both themes.
- A Trash widget test renders with the dark theme, while Archive renders with the light theme.
- No new gradients, neon AI treatments, fixed white surfaces, or image overlays were introduced.

Manual review on representative OLED/LCD devices is still required before release, especially at high contrast settings and with real user images.

## Motion review

- Timeline reveal continues to use the shared `FadeSlideIn` helper.
- Memory options use the shared bottom-sheet transition.
- Navigation uses the shared screen transition configured by the router.
- No repeated decorative animation was added to lifecycle lists or destructive actions.
- All shared motion resolves through `AppMotion`; Reduced Motion collapses transitions to their documented fallback.

## Verification coverage

Automated coverage includes:

- archive and restore;
- editing without implicitly restoring an archived memory;
- Trash exclusion from timeline and search;
- restore from Trash and search-index restoration;
- permanent-delete restriction to Trash;
- transactional event/relationship removal;
- orphaned attachment metadata and managed-file cleanup;
- preservation of shared evidence, attachments, entities, and evidence cited by other provenance;
- cleanup-failure truthfulness after a committed deletion;
- path traversal rejection in managed attachment cleanup;
- explicit destructive confirmation in dark mode;
- lifecycle actions in light mode; and
- large-text reflow for actionable Memory Cards.

## Remaining design debt

- Real evidence and attachment rendering is not implemented; the Memory Detail evidence section intentionally remains an empty-state foundation.
- Entity Detail, richer Explore, and Story templates remain roadmap work, not gaps to fill from the reference image.
- The candidate review source preview can become richer only when approved evidence presentation and redaction rules are available.
- Archive/Trash bulk actions, retention timers, automatic emptying, and advanced search filters are intentionally absent because they are not Phase 1 requirements.
- Restore-to-previous-lifecycle would require storing lifecycle history; current restore-to-active behavior needs human approval before any change.
- Custom signature icons remain behind the existing interface and need a future approved asset set.
- Screenshots are not included because this pass did not have a deterministic emulator fixture with representative, non-personal test data. Capture light/dark, large-text, and Reduced Motion screenshots during release QA.
- A filesystem-cleanup retry ledger is not part of Phase 1. Failed post-commit cleanup is reported without exposing file paths; a future privacy review may decide whether automatic retry is warranted.

## Acceptance summary

The implemented UI remains tokenized, reusable, local-first, privacy-aware, responsive, and consistent with Quiet Intelligence. No reference-image-only product rule was promoted into the domain or design system.
