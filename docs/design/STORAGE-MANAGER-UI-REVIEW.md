# Storage Manager UI Review

## Status

IMPLEMENTATION-READY for Storage Manager, Archive Engine, and Backup Health V1
as documented in `docs/product/STORAGE-MANAGER-V1.md`. No blocking conflict
with the official design system, motion guidance, PDD, or accepted ADRs
remains.

## Quiet Intelligence fit

The screen leads with one calm storage summary and a plain-language recommended
action. Measured categories, protection status, safe opportunities, and
archive actions follow in descending importance. Neutral Material 3 surfaces,
tokenized spacing, restrained color, and generous vertical separation avoid a
dashboard-like or neon “AI” treatment.

Intelligence is limited to explainable local measurements and recommendations.
The UI does not imply cloud monitoring, automatic deletion, or certainty when
a platform value is unavailable.

## Navigation and hierarchy

Storage Manager is opened from You > Privacy & control and uses the standard
app scaffold/app bar, including normal system and app back navigation. It is a
full-screen management surface, not a shell destination.

The hierarchy is:

1. measured app-owned storage and recommended action;
2. category breakdown;
3. backup and copy protection;
4. conservative optimization opportunities;
5. selection and archive confirmation;
6. archived originals and explicit retrieval;
7. unavailable or missing-file attention state.

## Reused components

- `AppScaffold` and `ScreenContainer`;
- `AppButton`, `AppTextField`, `AppBottomSheet`, and `AppBadge`;
- `AppSectionHeader`, `AppEmptyState`, `AppLoadingState`, and `AppErrorState`;
- `AppColors`, `AppTypography`, `AppSpacing`, and `AppRadius`;
- Hugeicons only through `AppIcons` and `AppIcon`.

Storage-specific composition remains inside the feature:

- storage summary surface;
- measured storage rows;
- backup/protection surface;
- operation progress surface;
- selectable/retrievable attachment row;
- archive, recovery-password, optimization, and warning sheets.

## Archive and retrieval UX

Archive candidates are limited to available app-managed originals without an
existing archive reference. Selection is explicit. The confirmation sheet:

- requests a recovery password;
- explains local encryption and the system destination picker;
- warns when selected items have only one independently verified copy;
- defaults local-original removal to off;
- requires an explicit switch before any local removal.

Progress communicates source verification, preview preparation, local
encryption, destination selection, archive verification, reference recording,
optional removal, and completion. Retrieval distinctly announces
“Authenticating and decrypting locally.”

The unavailable-original message is:

> Original file is currently unavailable. Your timeline record and preview are
> still safe.

Archive is explicitly described as a storage action, not a second backup.

## Responsive layout and Dynamic Type

Content uses fluid screen gutters and wrapping/stacked actions. Storage rows
give labels flexible width. Attachment actions sit below metadata rather than
competing in a trailing row. Opportunity actions sit below their explanations.
Backup status is placed on its own line.

Large-text testing exposed a shared `AppBadge` single-line overflow; the
primitive now gives its label flexible wrapping space, benefiting every
feature. The Storage Manager is widget-tested at a 360-pixel logical width and
2x text scaling.

## Dark mode

All feature surfaces use the active Material 3 color scheme and official
tokens. There are no hardcoded light-only fills, decorative gradients, or
image-dependent labels. Error and attention meaning is carried in text as well
as color.

## Motion and Reduced Motion

The screen uses determinate progress for known archive stages and the shared
bottom-sheet transition. With Reduced Motion enabled, the shared sheet uses no
animation and essential progress remains textual. No archive, deletion, or
verification result depends on animation.

## Accessibility

- Storage summary and operation progress provide semantic labels.
- Operation progress is a live region and names the current stage.
- Selection controls name the attachment being selected.
- Status, copy count, and unavailable states use words, not color alone.
- Password fields are labeled and supporting text explains recovery use.
- Destructive local removal is a separate, off-by-default switch.
- Buttons and icons use design-system touch targets and AppIcons semantics.
- Content scrolls under large text and narrow layouts.

## Corrected conceptual-reference weaknesses

- No mockup value is treated as authoritative storage telemetry.
- No provider destination is hardcoded or recreated in-app.
- Archive is not presented as backup or cloud sync.
- Duplicate “savings” do not become an automatic-delete rule.
- Device free space is omitted when it cannot be measured reliably.
- Password, privacy, monetization, and domain rules come from the PDD/ADRs,
  not a generated image.
- The working name remains Life Timeline; placeholder branding is not used.

## Manual QA and remaining decisions

- Verify Android and iOS save/open picker cancellation, provider errors,
  process interruption, low-space behavior, and file replacement semantics.
- Validate screen-reader announcements during picker transitions.
- Test localized text expansion when localization is introduced.
- Confirm final recovery-password and one-copy warning language.
- Decide whether a future durable archive-directory connection is worth its
  permission and recovery complexity.

