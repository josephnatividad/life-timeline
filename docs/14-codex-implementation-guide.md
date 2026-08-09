# Codex Implementation Guide

This document tells coding agents how to interpret this repository.

## Priority order

When implementing a feature:

1.  Protect user data.
2.  Preserve local-first architecture.
3.  Preserve domain model correctness.
4.  Maintain privacy boundaries.
5.  Follow the design system.
6.  Reuse existing abstractions/components.
7.  Optimize only after correctness, except obvious performance hazards.

## Non-negotiables

-   Do not introduce a backend because implementation is easier.
-   Do not upload timeline content to external services.
-   Do not add cloud AI without an explicit architecture decision.
-   Do not store large attachments as SQLite blobs.
-   Do not silently convert AI extraction into confirmed history.
-   Do not invent exact dates for approximate memories.
-   Do not expose `never_share` fields through Stories.
-   Do not implement social feeds/followers/likes.
-   Do not gate access to user-created timeline data behind Pro.
-   Do not add arbitrary UI colors, spacing, radii or motion when a
    token exists.

## Before coding

Read:

-   `README.md`
-   Relevant feature specification
-   `03-tech-architecture.md`
-   `08-ui-design-system.md`
-   Relevant ADRs
-   Relevant `.codex/skills/*/SKILL.md`

## UI implementation checklist

Before creating a screen:

-   Identify existing design-system components.
-   Use tokenized spacing/colors/type/radius.
-   Use Hugeicons through `AppIcons`.
-   Determine motion level (0--4).
-   Check reduced-motion behavior.
-   Determine empty/error/loading states.
-   Determine privacy classification/display implications.
-   Prefer user's content as visual emphasis.
-   Avoid unnecessary cards and gradients.

## Architecture checklist

Before adding a dependency:

-   Is it actively maintained?
-   Does its license fit commercial use?
-   Can the feature be implemented locally?
-   Does it leak user data?
-   Should it be wrapped behind a project interface?
-   Does it introduce a permanent format/storage dependency?

## Agent behavior

When requirements conflict, do not silently choose a direction that
violates local-first/privacy principles. Surface the conflict.

When a requested implementation would introduce substantial
architectural debt, propose the smallest compatible alternative.

Keep changes focused. Do not refactor unrelated areas without a concrete
reason.
