# Ask My Life and Insights UI Review

Status: implementation and automated quality review complete; physical-device screenshot review remains.

Authority remains `AGENTS.md`, the PDD, accepted ADRs, `08-ui-design-system.md`, `09-motion-icons-illustration.md`, `UI-REFERENCE-SPEC.md`, and `PHASE1-UI-REFINEMENT.md`.

## Screens implemented

### Ask My Life

- Strong `Ask your life` heading with the existing Life Intelligence signature icon.
- One labeled input and one clear submit action; no chat transcript, bubbles, avatar, or conversational chrome.
- Four lightweight suggested-question chips from the centralized supported vocabulary.
- Deliberate initial, answered, insufficient-data, unsupported, progress, and local-query-error states.
- Structured answer hierarchy: source context, primary headline, metric/duration, supporting summary, optional year details, then evidence access.
- Reusable Supporting Records sheet with title, temporal precision, type/category context, and Memory Detail navigation for events.

### Explore

- Editorial introduction and secondary Ask My Life entry point.
- Approximately 3–5 high-value eligible insights: one prominent `IntelligenceCard` followed by compact rows.
- Things, Years, Places, and Categories sections with whitespace and list/timeline treatments instead of a dashboard grid.
- Low-data copy for every section.
- Per-insight dismissal using a labeled control.

## Design-system components reused

- `AppScaffold` and `ScreenContainer`;
- `AppTextField`, `AppButton`, `AppIconButton`, and `AppChip`;
- `AppSectionHeader`, `AppBadge`, and `AppDivider`;
- `IntelligenceCard` and `TimelineNode`;
- `AppBottomSheet`;
- `AppEmptyState`, `AppLoadingState`, and `AppErrorState` patterns;
- `FadeSlideIn` and shared page/sheet transitions; and
- Hugeicons only through `AppIcons`, plus the existing Life Intelligence signature-icon abstraction.

## New reusable components

- `AskLifeInput`: labeled private-query input plus primary action.
- `SuggestedQuestionChip`: lightweight, reusable supported-question affordance.
- `LifeAnswerCard`: maps typed results into answer/context/metric/evidence hierarchy while composing `IntelligenceCard`.
- `SupportingRecordsSheet`: reusable evidence access for Ask My Life and Explore insights.
- `ExploreOverview`/`ExploreSummary`: presentation-neutral local overview read model.

`IntelligenceCard` was extended rather than duplicated. It now supports optional supporting text, metric/highlight, dismissal, and CTA while retaining its single restrained intelligence cue and static post-reveal behavior.

## Visual hierarchy decisions

- The intelligence symbol identifies the capability once; it is not repeated as decoration around every statistic.
- The answer metric receives `headlineLarge`; supporting context stays in label/body hierarchy.
- Year-summary derived counts use compact badges after the main answer rather than a KPI grid.
- Supporting records are one action away and remain visually subordinate to the answer while preserving evidence access.
- Explore uses one bounded intelligence surface. Other insights and records use flat list rows, section rhythm, and timeline marks.
- Categories are lightweight chips because they are query entry points, not content cards.

No neon, glow, glass, giant AI banner, robot avatar, or continuous animation was introduced.

## Motion

- Answer and primary-insight appearance uses the existing one-time `FadeSlideIn` level-1/2 treatment.
- Supporting records use the standard bottom-sheet transition.
- Suggestion selection uses standard chip feedback.
- There is no fake AI thinking animation or artificial delay. While a real local query is pending, a static live-region status describes the actual operation.
- Reduced Motion resolves answer/insight reveal to static content through `AppMotion`.

## Accessibility

- Input labels, submit action, suggested questions, dismiss actions, and supporting-record controls have explicit semantics/tooltips.
- Supporting records communicate temporal uncertainty in visible text (`Around 2020`, ranges, before/after) rather than hiding it in metadata.
- Intelligence is not communicated by violet alone; headings and text state remain authoritative.
- Progress and new results use live-region semantics without hiding descendant actions.
- All icon actions retain 48dp targets through `AppIconButton`.
- Layouts scroll/reflow, use no fixed text heights, and compose wrapping chips/badges.
- Widget coverage verifies the answer, evidence sheet, unsupported state, low-data state, dark Explore, Reduced Motion, and the Ask screen at 320 logical pixels with 200% text scaling.
- Keyboard submit uses the search action; focus is dismissed before query execution.

## Light and dark modes

- All surfaces use Material 3 semantic colors from `AppTheme`.
- `IntelligenceCard` uses `primaryContainer`, `onPrimaryContainer`, primary border/accent, and no fixed light background.
- Dismiss controls, chips, inputs, list rows, and sheets inherit themed colors.
- Dark-mode widget review found no fixed white surface, luminous gradient, or reduced text contrast introduced by this feature.

Physical OLED/LCD and high-contrast device review remains a release task.

## Responsiveness

- Screens use `ScreenContainer`, vertical composition, wrapping chips, and scrollable content rather than a fixed mockup width.
- Answer and insight typography can grow vertically.
- Supporting sheets use safe-area-aware shared infrastructure.
- The UI does not add an unapproved numeric breakpoint or tablet layout rule.
- Automated tests exercise standard phone constraints, a 320-logical-pixel compact width at 200% text scaling, and the existing design-system large-text behavior for `IntelligenceCard` primitives. A dedicated physical large-text/landscape pass remains release QA.

## Privacy review

- No query history UI exists.
- Questions and answers are not persisted or logged.
- Initial-state copy accurately says records are on this device and does not make an absolute claim that ignores user-owned backups.
- Supporting records expose only user-visible titles, type, context, and temporal precision—not database columns, SQL, or raw provenance internals.
- Archived and trashed records do not appear in normal answers or insights.

## Screenshots

Screenshots are not included because this workspace did not provide a deterministic emulator session populated with representative synthetic insight fixtures. Release QA should capture:

- Ask My Life initial, answered, unsupported, insufficient-data, and supporting-record states;
- Explore with eligible and low-data sections;
- light and dark themes;
- 200% text scale; and
- Reduced Motion on a representative compact Android device and large iPhone.

No personal or OCR-derived fixture content should be used for documentation screenshots.

## Remaining UI debt

- Entity supporting records cannot open a dedicated Entity Detail screen because that product screen is not yet implemented.
- Contextual suggestions are bounded/static in V1. They may become data-aware without storing query history.
- The current English taxonomy and copy require localization design before international release.
- Manual screen-reader, switch-control, high-contrast, landscape, and physical-device Dynamic Type testing remains release QA.
- Rich evidence thumbnails are deferred until the approved evidence-rendering foundation exists.
- Final custom Life Intelligence artwork and Hugeicons Free release-license verification remain existing design-system approval items.

## Quality-gate outcome

The implementation meets the current Quiet Intelligence direction: private, local, structured, evidence-backed, restrained, responsive, accessible in code, and visually distinct from a chatbot or generic dashboard. No reference-image-only rule became a product or design-system invariant.
