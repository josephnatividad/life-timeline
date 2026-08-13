# Memory Media UI Review

## Status

Implementation review for the Quiet Intelligence Memory Media V1 slice. The
reference image remains directional rather than pixel-authoritative. Official
tokens, Dynamic Type, Reduced Motion, PDD rules, and accepted ADRs win.

## Timeline

Text-only memories retain the existing temporal node, connector, hierarchy,
and whitespace. A photo-rich memory adds one restrained hero thumbnail below
its metadata; the timeline does not become an edge-to-edge social feed. The
thumbnail uses the managed thumbnail path and bounded cache width, never the
full original. Its Hero tag connects to the Memory Detail hero when motion is
allowed.

## Memory Detail

With a hero, the order is photography, title, temporal label, important
metadata/details, Photos, related records, Evidence, and lifecycle actions.
Without a hero, the original Quiet Intelligence text treatment remains. The
Evidence section uses document language and lower visual weight; receipts are
not shown beside gallery photographs as equal media.

## Gallery

The responsive gallery uses tokenized gaps/radii and two, three, or four
columns according to available width. The hero is presented once, followed by
non-hero thumbnails, media count, Add Photo, and an explicit reorder control.
Opening a photo exposes caption, hero, remove, and delete actions, so long
press is never the only path. Reorder uses a stable, accessible list with a
Save action.

## Viewer

The viewer uses a dark immersive surface so user photography provides the
visual richness. It supports PageView swiping, pinch zoom, optional double-tap
zoom, caption, captured date when available, media count, explicit More
actions, and a system share button only for `share_safe` media. Filesystem paths
never appear. Archived items show the retained preview plus Retrieve Original,
which opens Storage Manager.

## Capture and Add Photo

Capture now presents user concepts: Add Memory, Add Photos, and Scan Document.
Only Scan Document opens camera/library choices that run extraction. Add Photos
chooses an existing memory, then Take Photo or Choose from Photos without OCR.
Add Memory offers Save & Add Photo; Edit and Memory Detail expose Add Photo.

## Light, dark, accessibility, and motion

- All application chrome uses the existing Material 3 light/dark themes;
  photos retain their colors and unavailable states use semantic surfaces.
- Meaningful image labels prefer captions and always include media position.
- Controls use design-system buttons/icon buttons and non-color labels.
- Section headers stack actions under large text. Widget coverage exercises 2x
  text, dark mode, and `disableAnimations`.
- Hero transitions connect timeline/detail/viewer only when Reduced Motion is
  off. Reduced Motion returns the static child; no looping animation exists.
- Swipe, pinch, double tap, and long press are conveniences. Back, More,
  reorder, Add, retrieve, remove, and delete all have visible controls.

## Performance review

Timeline and gallery use thumbnails with bounded decode widths. Memory Detail
does not decode full originals for its grid. The viewer PageView constructs
pages lazily and requests the display-optimized image only for viewing.
Multiple imports are processed sequentially in background isolates. Repository
tests cover stable order and shared assets; widget fixtures cover mixed hero
and gallery media. Device profiling with 1, 10, and 50 real photographs remains
part of release QA.

## Automated review coverage

- one hero, multiple gallery items, hero clear/change, and stable order;
- remove-link and shared-reference survival;
- staged unreferenced deletion and guarded managed paths;
- orientation/dimensions/checksum/thumbnail/preserved-original processing;
- Timeline hero thumbnail, gallery, viewer, dark theme, large text, and Reduced
  Motion widget states;
- Story Memory Media selection, Evidence exclusion, `never_share`, and archived
  retrieval behavior;
- encrypted backup/restore of role, order, hero, captions, privacy, and files;
- schema-v7 migration of Evidence links, archive references, and provenance.

No screenshots were generated in this environment; emulator/device visual
capture remains release QA rather than being represented as completed.

## Remaining UI debt and human decisions

- Device QA for Android/iOS picker permissions, camera cancellation, native
  HEIC display, low-memory behavior, and system share destinations.
- Visual polish review with real mixed-aspect photography and 1/10/50-photo
  memories, including reorder haptics if later approved.
- Final decision on automatic first-photo hero behavior and direct sharing of
  non-`share_safe` media.
- Final localization and tone review for deletion, archived-original, and
  visible-content privacy warnings.
