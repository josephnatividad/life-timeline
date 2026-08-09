# Codex Skills Usage

Repository-local skills:

```text
.codex/skills/
├── life-timeline-ui/
├── life-timeline-architecture/
└── life-timeline-privacy/
```

Each `SKILL.md` has YAML `name` and `description` metadata for discovery.

## Verify discovery

Ask Codex:

```text
Which project skills are available to you?
List their names and when you would use each.
Do not modify anything.
```

Then test directly:

```text
Read $life-timeline-ui and summarize the most important constraints for a Flutter screen.
Do not modify files.
```

Expected concepts include Quiet Intelligence, tokens, Hugeicons through `AppIcons`, restrained motion, accessibility/reduced motion, timeline-first layout and avoiding noisy AI aesthetics.

## Explicit invocation

Recommended during early/high-impact development:

```text
Use $life-timeline-ui.
Implement the Timeline home screen.
Before coding, state the key design-system constraints you will follow.
```

```text
Use $life-timeline-architecture.
Design the Drift schema for Entity, Event, Evidence and Relationship.
```

```text
Use $life-timeline-privacy and $life-timeline-architecture.
Implement encrypted backup and fresh-install restore.
Review privacy and recovery risks before finishing.
```

## Review prompts

```text
Use $life-timeline-ui.
Review this screen against the skill and `08-ui-design-system.md`.
List violations, then fix them.
```

```text
Use $life-timeline-architecture.
Review this feature for domain leakage, duplicated logic and persistence coupling.
```

```text
Use $life-timeline-privacy.
Audit this path for off-device transmission, sensitive logging, unsafe sharing and backup-key mistakes.
```

## Source-of-truth hierarchy

```text
PDD + accepted ADRs
        ↓
AGENTS.md
        ↓
Task-specific skills
        ↓
Implementation
```

Skills are reusable task guidance; they do not replace the PDD or ADRs.
