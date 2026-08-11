# Stories UI Review

## Status

IMPLEMENTATION-READY for the Phase 1 Stories V1 scope documented in `docs/product/STORIES-V1.md`. The PDD, accepted ADRs, and official design-system documents remain authoritative.

## Quiet Intelligence fit

The Stories flow uses a calm document-like hierarchy, generous spacing, tokenized surfaces, a restrained primary palette, and focused actions. Templates vary composition without introducing neon AI styling, decorative excess, or feature-specific token systems. Milestones use an intelligence surface as a suggestion; they do not claim certainty beyond stored temporal precision.

## Screen and navigation review

| Surface | Purpose | Primary exit/action |
| --- | --- | --- |
| Stories home | Entry point, milestones, confirmed memories, entity histories, low-data guidance | Create from a source or start Then & Now |
| Then & Now selection | Explicitly choose two different memories | Continue to editor; back to Stories |
| Story editor | Choose template/theme, author public text, choose photo, and include fields | Review Story; back to source list |
| Story preview/privacy review | Show the export and exact included/kept-private inventory | Share through system sheet; back to edit |

Memory Detail exposes “Create Story” only for active confirmed memories. Invalid or stale route payloads redirect safely to Stories rather than showing a broken page. Existing shell navigation and back behavior remain intact.

## Reused design-system components

- `AppScaffold` and `ScreenContainer` for page structure and responsive width.
- `AppButton`, `AppIconButton`, `AppChip`, `AppSectionHeader`, and app state components.
- `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, and motion tokens.
- `StorySurface`, `StorySafeArea`, and Story typography foundations.
- `AppIcons` and `AppSignatureIcon`; feature code does not reference Hugeicons directly.

## Story-specific components

- Template and theme choosers.
- Privacy field/media selector.
- Included/kept-private review rows.
- Milestone suggestion card.
- Dedicated fixed-canvas Story render surface shared by preview and export.
- Minimal, Photo, Stats, Journey, and Then & Now compositions.

These components are composition-based and remain inside the Stories feature unless another feature demonstrates a real reuse boundary.

## Visual hierarchy

The source and intent lead, template and theme choices follow, privacy choices precede preview, and sharing is available only from the final review. The preview is visually dominant but does not hide the privacy inventory. Supporting copy explains local rendering without making unsupported security claims.

Image treatment is limited to one or two bounded regions depending on the template. Neutral fallbacks preserve hierarchy when a file is missing. Branding is low-emphasis and configurable.

## Responsive behavior and text scaling

Editor screens use responsive containers, wrapping chips, expanded row content, and scrollable layouts. Interactive UI follows the user’s text scale. The exported Story intentionally uses fixed Story typography and a no-scaling canvas because it is a deterministic 1080 by 1920 artifact; text is line- and length-bounded to avoid clipping.

At large text sizes, labels and privacy messages wrap instead of forcing badge-like single-line layouts. Touch targets come from the official button, switch, and icon-button primitives.

## Dark mode

Editor and review surfaces use the active Material 3 color scheme and official dark tokens. Story theme variants are artifact palettes selected by the user; the preview does not automatically invert with app dark mode. Each variant maintains readable foreground/background contrast and uses neutral missing-image treatments.

## Motion and Reduced Motion

Template/theme preview changes may use the shared quiet fade/slide timing. Screen transitions use the standard navigation transition. With Reduced Motion enabled, transition helpers resolve to static or immediate state changes. The exported PNG contains no motion, and no essential information depends on animation.

## Accessibility

- Controls have visible text labels and semantic grouping.
- Included/excluded status is communicated by words and icons, not color alone.
- `neverShare` items have no interactive include control.
- The preview has an accessible label and is followed by a text privacy inventory.
- Missing-image states remain understandable without the image.
- System share results and failures are announced in-page with actionable retry text.
- Back navigation is available through app bars and device navigation.

## Corrected reference-image weaknesses

- The mockup’s brand text is not treated as the final app name.
- Image-specific spacing, radii, shadows, and colors were not promoted into hardcoded tokens.
- Story privacy is explicit and enforced before rendering rather than implied by decorative badges.
- Approximate dates are not rendered as false exact anniversaries.
- Share destinations are not recreated in-app; the operating system owns destination selection.
- Long status text uses wrapping surfaces rather than compact badges.
- Then & Now requires explicit source selection instead of opaque automatic pairing.

## Remaining UI debt and manual QA

- Validate the native share sheet on supported Android and iOS devices, including cancel and unavailable-target behavior.
- Capture final golden references after product approval of the working attribution and artifact palette.
- Verify image crop focal points with a broad real-photo set; V1 uses deterministic cover fitting without face detection.
- Revisit localized text expansion when localization is introduced.
- Confirm final marketing language and whether attribution may be disabled; the current capability is configuration-only.

No blocking conflict with `08-ui-design-system.md`, `09-motion-icons-illustration.md`, or accepted ADRs remains.
