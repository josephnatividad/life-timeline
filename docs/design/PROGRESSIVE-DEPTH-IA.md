# Progressive Depth Information Architecture

Status: implemented foundation for Phase 1 UI

## Design philosophy

Life Timeline combines **Quiet Intelligence** with **Progressive Depth**:

```text
Overview -> Preview -> Explore -> Manage
```

The first view protects emotional focus. Depth appears through explicit,
shallow navigation when data or intent warrants it. Capability is preserved;
technical and collection-management detail is moved to a more appropriate
owner.

PDD documents, accepted ADRs, and `AGENTS.md` remain authoritative. This IA
does not change privacy, domain, backup, monetization, or intelligence rules.
In particular, Stories remain ephemeral under the implemented Stories V1
product boundary and ADR-0007's sanitized local-export decision, so this work
does not invent a persisted Story library or drafts screen. ADR-0008 governs
one-time Pro monetization, not Story persistence.

## Module hierarchy

```text
Timeline
└── Memory Detail
    ├── Photos -> Memory Gallery
    ├── Evidence -> Memory Evidence
    └── Reminders -> Memory Reminders (only when depth exists)

Explore
├── Ask My Life
└── Insights -> All eligible insights

Stories
├── Choose a memory -> Story Editor -> Story Preview
└── Then & Now -> Story Editor -> Story Preview

You
├── Security & recovery -> Backup / Restore / Automatic backup
├── Storage -> Archived originals
├── Reminders
├── Archived memories
└── Trash
```

The primary shell remains `Timeline | Explore | Capture | Stories | You`.
There is no separate Home dashboard in the current application. Timeline is
both the shell landing screen and the authoritative chronological experience,
avoiding duplicated long-form content.

## Screen-purpose matrix

| Screen | Primary purpose | Primary content/action | Collection owner | Result |
|---|---|---|---|---|
| Timeline | Revisit confirmed history chronologically | Timeline and Capture/Search access | Active memories | Retained |
| Memory Detail | Understand and revisit one memory | Hero, identity, About, contextual actions | Bounded child previews | Refined |
| Add/Edit Memory | Create or correct one memory | Focused editor and Save | None | Retained |
| Explore | Discover something about my life | Ask, one insight, browse paths | Overview only | Refined |
| Ask My Life | Answer one supported local question | Prompt, answer, supporting records | Query result | Retained |
| Insights | Review eligible deterministic insights | Insight rows and supporting records | Full eligible insight set | Added drill-down |
| Stories | Start a meaningful local Story | Creation actions, one suggestion area, recent sources | Bounded source preview | Refined |
| Story memory chooser | Choose a source memory | Lazy source list | Confirmed memories | Added drill-down |
| Memory Inbox | Review private capture suggestions | Pending candidates | Pending candidates | Wording refined |
| Reminders | See what needs attention | Upcoming/past reminders | All or memory-filtered reminders | Refined |
| Storage | Understand local storage | Summary, protection, safe opportunities | Storage overview | Refined |
| Archived originals | Archive or retrieve originals | Select/archive/retrieve | Archive candidates and references | Added drill-down |
| Archive/Trash | Manage memory lifecycle | Restore/trash/permanent delete | Lifecycle collection | Retained |
| Search | Find a memory | Search and results | Search result set | Wording/action refined |
| You | Reach personal controls | Small fixed navigation menu | None | Retained |

## Collection ownership and preview rules

| Collection | Parent preview | Full owner | Empty policy |
|---|---:|---|---|
| Memory photos | Hero plus up to 4 non-hero images | Memory Gallery | Silent on detail; Add photo remains visible |
| Memory evidence | Up to 3 rows plus total count | Memory Evidence | Silent on detail |
| Memory reminders | Up to 2 rows plus total count | Memory-filtered Reminders | Silent on detail; Add reminder remains in More |
| Related entity | One meaningful row supported by current model | Memory Detail | Silent; no empty manager |
| Explore insights | 1 primary plus up to 2 recent | Insights | Compact shaping state |
| Story source memories | Up to 3 recent | Story memory chooser | Hero first-use state |
| Archived originals | Counts and navigation row | Archived originals | Compact clear state |

Counts reflect the full collection. Parent previews use bounded SQL/Drift
queries rather than loading the full collection and truncating in widgets.

## Navigation relationships

The target depth is Module -> Detail -> Collection. Back returns to the
immediate parent and GoRouter owns the history. Collection destinations are
ordinary pushed routes, not new shell destinations and not persistent tabs.
Media viewer/reorder remain children of the gallery relationship; Story Editor
and Preview remain task steps.

## Scalability examples

- A Memory with 0, 1, or 50 photos has the same parent structure; only the
  count and at most four preview cells change.
- A Memory with 0, 1, or 30 evidence records shows zero or at most three rows.
- Multiple historical reminders add no more than two rows to Memory Detail.
- Explore renders one primary insight, at most two recent insights, and four
  browse paths even as the timeline grows.
- Stories renders at most three recent memory sources on its root; the chooser
  owns the full source collection.
- Storage renders archive counts on its overview; attachment selection belongs
  to Archived originals.

Timeline itself remains a lazy-rendered authoritative list, while its
repository materializes the confirmed-memory read model. Repository and widget
checks pass at 10,000 memories and build only viewport-visible event tiles, so
cursor pagination is not currently justified. If representative device
profiling later exceeds the performance budget, pagination must preserve
unknown/approximate/range ordering and scroll restoration; it must not be
improvised as a presentation-only limit.

Dedicated Gallery and Reminders collections use lazy slivers. Their collection
owners may read the complete local collection, while construction and image
work remain viewport-bounded.

## Future extension strategy

Future semantic search belongs behind Search/Explore. Richer local intelligence
and Life Wrapped can contribute a high-value Explore or Stories preview and a
focused destination. Video belongs to the existing media ownership boundary.
Richer relationship views should be added only after the domain exposes a real
multi-relationship collection. These slots avoid redesigning the roots, but no
future feature is implemented by this IA.
