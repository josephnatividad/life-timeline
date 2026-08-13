# Reminders UI Review

Status: Implementation-ready Phase 1 slice

## Quiet Intelligence direction

The reminder experience uses the existing Quiet Intelligence hierarchy: clear page titles, generous spacing, compact contextual actions, restrained primary-color emphasis, and plain-language state. The key product sentence is “Your timeline quietly remembers for you.” The UI avoids calendar grids, alarm imagery, dense task rows, checklists, countdowns, warning-heavy banners, and neon or “AI” styling.

## Surfaces

### Reminders

The You area contains a single Reminders row. The Reminders page groups records as Upcoming and Past / inactive. Rows show the reminder title, accessible full date, preset, and an explicit text state. A single Add reminder action supports manual creation.

### Add/Edit reminder

The editor composes existing primitives: `AppScaffold`, `ScreenContainer`, `AppTextField`, `AppSectionHeader`, `AppChip`, `AppButton`, `AppIcon`, Material date/time pickers, and an optional `IntelligenceCard`. It supports target date, reminder date, local time, contextual presets, enabled state, title, private note, and deletion.

The default is 09:00 local. Notes explicitly explain that they never appear in notification content. An imprecise memory receives a calm explanatory intelligence surface and a separate reminder-date path.

### Memory Detail

Memory Detail uses a compact Reminder section between the summary and media. Existing reminders are simple editable rows; Add reminder is a tertiary contextual action. The section does not become a dominant card.

### Candidate Review

A reliable exact OCR expiry date can produce a deterministic Reminder suggestion surface. The opt-in switch is off by default and states that nothing schedules until selected. Candidate confirmation remains the primary action.

### Insights

Expiry insights retain their current supporting-record navigation. Users add reminders from the resulting Memory Detail, avoiding reminder controls on every insight card.

## Components reused

- App scaffold, safe content container, app bar, and existing standard transition.
- App button variants and tokenized icon abstraction.
- App text field, chip, section header, badge, state views, and intelligence card.
- Material adaptive switch and localized date/time pickers.
- Existing Snackbar confirmation pattern.

No feature code imports Hugeicons. `AppIcons.reminder` is an app-owned alias and remains replaceable.

## Hierarchy and responsive behavior

Primary sequence: context → title/note → target date → preset → exact reminder date/time → enabled state → save. Long text wraps; section-header actions stack under large text using the existing component behavior. Forms scroll, use safe insets, and contain no fixed screen dimensions. Touch targets inherit the design-system minimums.

## Accessibility

- Reminder dates use platform-localized full-date strings.
- Reminder rows provide combined semantic labels.
- Scheduled, missed, completed, disabled, and cancelled states are written in text and never rely on color.
- Chips are real filter controls with selected semantics.
- Switches include title and explanatory subtitle.
- Dark mode uses the existing Material 3 theme rather than feature-owned colors.
- Large-text and `disableAnimations` widget coverage verifies the core editor and list remain usable.

## Motion

V1 relies on existing Level 1–2 app navigation, chip selection, switch, Snackbar, and bottom/platform picker motion. No ringing, looping bell, countdown, or fake scheduling progress is used. Existing transition helpers and system `disableAnimations`/Reduced Motion policy remain authoritative.

## Dark mode

All surfaces use theme color roles. There are no reminder-specific hardcoded light backgrounds, shadows, gradients, or status colors. Sensitive/generic notification behavior is identical across themes.

## UI debt and device review

- A standalone Entity Detail screen is not yet present in the Phase 1 navigation, so entity-linked reminders are supported by the domain/schema but do not yet have a dedicated contextual Entity Detail action.
- Completed and cancelled actions are represented in the domain/list but V1 editing primarily exposes enable/disable and delete; dedicated completion affordances need product approval.
- Opening operating-system notification settings after a permanent denial is not yet surfaced as a separate settings button.
- Screenshot capture was not added because this Windows environment does not provide authoritative iOS rendering. Android and iOS device passes should verify notification prompt wording, lock-screen redaction, large accessibility sizes, reboot persistence, and OEM behavior.
- Annual recurrence remains a documented follow-up; V1 shows explicit one-time anniversary dates.
