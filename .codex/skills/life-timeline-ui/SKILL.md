---
name: life-timeline-ui
description: >
  Use when designing, implementing, reviewing, or refactoring Flutter UI for the Life Timeline project. Enforces Quiet Intelligence, design tokens, Hugeicons through AppIcons, restrained motion, accessibility, privacy-aware UI, timeline-first layouts, and reusable components.
---

# Life Timeline UI Skill

Use this skill whenever implementing or reviewing UI for this project.

## Design language

Name: **Quiet Intelligence**

The UI must feel modern, intelligent and slightly futuristic without
becoming noisy.

### Always

-   Use design tokens.
-   Use restrained surfaces and whitespace.
-   Let user photos/memories provide visual richness.
-   Use indigo/violet accent primarily for intelligence/selection.
-   Use timeline structure instead of turning everything into cards.
-   Use Hugeicons only through `AppIcons`.
-   Use custom signature icons only for Life Intelligence, Life Graph,
    Memory, Story, Timeline Milestone and Private AI.
-   Support light/dark themes.
-   Respect reduced motion and accessibility.

### Never

-   Neon AI gradients everywhere
-   Robot mascots
-   Generic chatbot-first UI
-   Random colors/radii/spacing
-   Multiple icon libraries mixed together
-   Permanent pulsing/glowing UI
-   Unnecessary glassmorphism
-   Excessive shadows
-   Confetti for ordinary actions

## Motion

Use levels: 0 static, 1 micro, 2 structural, 3 meaningful, 4 emotional.

Most UI is 0--2.

Tokens: 80ms, 140ms, 220ms, 320ms, 450ms, 600--900ms Story-only.

Motion must communicate continuity, intelligence, change or
accomplishment.

## Screen checklist

For every screen: 1. Define information hierarchy. 2. Reuse
design-system components. 3. Use tokenized spacing/type/color/radius. 4.
Define empty/error/loading states. 5. Define accessibility semantics. 6.
Define reduced-motion behavior. 7. Check privacy implications. 8. Keep
visual noise low.
