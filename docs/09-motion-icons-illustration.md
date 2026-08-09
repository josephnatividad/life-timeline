# Motion, Icons & Illustration

## Motion principle

Motion explains:

-   Change
-   Continuity
-   Intelligence
-   Accomplishment

If removing an animation does not reduce understanding, emotional
meaning, continuity or feedback, question whether it belongs.

## Motion levels

``` text
0 Static
1 Micro interaction
2 Structural/navigation
3 Meaningful event/intelligence
4 Emotional Story/milestone
```

Most UI stays at levels 0--2.

## Duration tokens

``` text
instant    80ms
quick     140ms
standard  220ms
emphasis  320ms
reveal    450ms
story     600–900ms
```

Prefer subtle transforms and opacity. Avoid perpetual pulsing,
decorative looping animations and fake loading delays.

## Signature motion

-   Timeline viewport reveal: subtle fade + \~8px translation
-   Memory → detail: shared element/Hero transition
-   Add memory: node appears and connects
-   Intelligence: one-time subtle reveal, then static
-   Story creation: meaningful recomposition/morph
-   Backup: real progress stages, not fake spinner
-   Time scrubber: smooth settling + restrained haptics
-   Milestones/Life Wrapped: richer motion permitted

Respect OS Reduced Motion.

## Icons

Primary icon library: **Hugeicons Free**, subject to license
verification at implementation/release time.

Rules:

-   Use one primary icon family.
-   Rounded stroke style.
-   Consistent visual weight.
-   24px normal, 20px compact, 28--32px feature.
-   Do not mix Hugeicons, Lucide, Material and random SVGs
    screen-by-screen.
-   Wrap icons behind `AppIcons`.

Example:

``` dart
abstract final class AppIcons {
  static const timeline = ...;
  static const explore = ...;
  static const capture = ...;
  static const stories = ...;
  static const privacy = ...;
}
```

## Custom icons

Create only a small signature set where the product has unique concepts:

-   Life Intelligence
-   Life Graph
-   Memory
-   Story
-   Timeline Milestone
-   Private AI

Library icons remain appropriate for universal concepts.

## Illustration style

Use custom minimal editorial illustrations:

-   Thin geometric forms
-   Timeline paths/nodes
-   Soft atmospheric gradients
-   Objects rather than cartoon mascots
-   User photography whenever possible

Avoid generic SaaS people-with-laptop illustrations.

Stories can be more expressive than the core application.
