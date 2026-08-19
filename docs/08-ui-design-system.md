# UI Design System --- Quiet Intelligence

## Direction

**Quiet Intelligence**

Modern and futuristic through hierarchy, motion, intelligence and
temporal relationships---not neon AI clichés.

Principles:

-   Personal
-   Quiet
-   Intelligent
-   Temporal
-   Private
-   Timeless
-   Accessible

## Color tokens

### Light

``` text
background          #F8F8FA
surface             #FFFFFF
surfaceSecondary    #F2F2F6
textPrimary         #18181B
textSecondary       #71717A
textTertiary        #A1A1AA
border              #E4E4E7
divider             #ECECEF
primary             #5451D6
primarySoft         #EEEEFF
success             #2E8B68
warning             #C88725
danger              #D14D4D
```

### Dark

``` text
background          #0D0D10
surface             #16161B
surfaceSecondary    #1E1E24
textPrimary         #F5F5F7
textSecondary       #A1A1AA
textTertiary        #71717A
border              #29292F
primary             #8B87FF
primarySoft         #24223D
```

Gradients are reserved for intelligence/memory emphasis and Stories. Do
not decorate ordinary UI with gradients.

## Typography

Prefer platform-appropriate/system typography or a carefully licensed
modern sans. Keep typography centralized.

Suggested scale:

``` text
Display       40/48 SemiBold
Hero          32/40 SemiBold
Title 1       28/34 SemiBold
Title 2       22/28 SemiBold
Title 3       18/24 SemiBold
Body Large    17/26 Regular
Body          15/22 Regular
Body Small    13/18 Regular
Label         13/18 Medium
Caption       11/16 Medium
```

## Spacing

Use an 8-point-oriented token system:

``` text
4, 8, 12, 16, 20, 24, 32, 40, 48, 64
```

No arbitrary padding values in feature widgets without justification.

## Radius

``` text
small control   8
button         12
card           16
large card     20
bottom sheet   28
pill           full
```

## Navigation

Target five primary destinations:

``` text
Timeline | Explore | Capture | Stories | You
```

Capture is the primary action, but should not visually overpower the
navigation.

## Signature components

-   TimelineNode
-   TimelineHero
-   MemoryCard
-   IntelligenceCard
-   PrivacyNotice
-   MemoryInboxCard
-   StoryCard
-   BackupHealthCard
-   StorageHealthCard
-   EmptyState
-   TimeScrubber

## Timeline

Avoid a generic feed of cards.

The timeline line, nodes, dates, event hierarchy and occasional visual
hero memories should form the product's visual signature.

## Intelligence

Use a restrained `✦`/custom intelligence symbol.

AI should appear contextually:

-   AI Capture
-   Insight
-   Suggested Memory
-   Ask My Life

Avoid robot mascots and chatbot-first UI.

## Accessibility

Design system must support:

-   Dynamic text
-   Screen readers
-   High contrast
-   Large touch targets
-   Reduced motion
-   Keyboard/focus behavior where applicable
-   Semantic labels

## Quiet Intelligence + Progressive Depth

Life Timeline should be simple at first glance and powerful when explored.
Information generally flows from overview, to bounded preview, to exploration,
and finally to management. A parent screen or module orients the user; it does
not attempt to render every record it can access.

### One primary job

Each screen should have one identifiable primary purpose and one primary visual
focus. An ordinary screen should aim for approximately three to five major
visible sections, one dominant call to action where an action is appropriate,
and a limited number of contextual actions. This is a design review budget, not
a runtime limit. Composition screens, long forms, and dedicated management
collections may justify exceptions when their purpose remains clear.

### Section importance

-   **Primary** content is why the screen was opened: memory identity, the
    timeline, an Ask My Life answer, or Story composition. It receives the
    strongest typography, space, and visual focus.
-   **Supporting** content adds context: photos, evidence, relationships,
    reminders, and insights. Parent screens use concise previews and hide
    optional supporting sections when empty.
-   **Utility** content manages or explains a record: privacy controls,
    provenance, lifecycle state, created/modified metadata, deletion, and
    technical storage information. It normally belongs in a contextual More
    menu, sheet, or focused management destination.

Essential actions remain discoverable even when their empty supporting section
is hidden. Frequently used contextual actions can remain visible; management
and destructive actions should be separated, with destructive actions clearly
labeled and confirmed.

### Preview to view all

A collection on a parent screen uses a representative, query-bounded preview:

-   visual media: usually three to five items;
-   rows: usually two or three items;
-   insights: one primary insight and, where useful, one or two recent items;
-   relationships: a small curated row or chip preview.

When more records exist, show an understandable count and a labeled `View all`
action. The count is the collection count, not merely the number fetched for
the preview. The label must identify its destination for screen readers.
Dedicated collection screens own full browsing and management and may use lazy
rendering, filtering, sorting, or search only when the collection warrants it.
Typical navigation depth is Module -> Detail -> Collection.

### Section primitives

Use `AppSection` for editorial rhythm without inventing another surface.
`AppSectionHeader` provides a heading, optional count, supporting text, and
contextual action. `AppCollectionPreview` adds bounded preview content and one
accessible drill-down. Feature-specific rows stay in their feature; these
primitives must not depend on domain models.

Empty states have three presentation levels:

-   **hero** for a wholly empty first-use module;
-   **section** for an important empty section with a contextual next action;
-   **compact** for a small, useful state inside existing content.

Optional sections use a silent empty state and disappear. First use, no result,
filtered empty, completed/clear, unavailable, permission required, and error
are distinct meanings and must use contextual language. Loading failures never
masquerade as empty data.

### Cards, tabs, and visual separation

Cards communicate meaningful grouping or interaction. They are appropriate
for a memory, an actionable intelligence result, or a self-contained Story
preview. Do not use cards merely to separate adjacent page content. Prefer
whitespace, section rhythm, typography, subtle dividers, and restrained tonal
transitions. This preserves the editorial personal-history character and
avoids a generic analytics dashboard.

Tabs are for persistent sibling views that users repeatedly switch between,
such as Upcoming and Past. Do not turn detail relationships such as Photos,
Evidence, Related, and History into a tab bar solely to contain overload.
Prefer overview to focused drill-down.

### Collection and query scaling

Preview UI must be backed by a bounded repository/query API; applying `take`
after fetching hundreds of records is not sufficient. Full queries belong to
dedicated collection screens, where lazy rendering should be used. Measure
before adding cursor pagination: a bounded SQL query or a lazy Drift-backed
list is often enough. Timeline pagination requires its own chronological
read-model design and should not be improvised inside an unrelated screen.

### Density and motion

Density varies by purpose while tokens remain shared: Timeline is moderate,
Memory Detail is spacious and editorial, Explore is moderate and
discovery-oriented, evidence/storage management is moderately dense, Stories
is visual, and settings is efficient. Do not expose a density preference in
Phase 1.

Motion communicates navigation and hierarchy, such as preview to gallery or
timeline item to Memory Detail. Do not animate every section independently.
Every transition follows `09-motion-icons-illustration.md` and provides the
Reduced Motion fallback.
