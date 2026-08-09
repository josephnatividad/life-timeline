# AGENTS.md — Life Timeline Project Instructions

> **Working title only:** “Life Timeline” is a generic project name. Do not treat it as the final brand name.

## Before substantial work

1. Read `README.md`.
2. Read the specification relevant to the requested feature.
3. Read applicable files under `adr/`.
4. Use applicable project skill(s) under `.codex/skills/`.
5. Stay inside the current roadmap phase unless explicitly asked to expand scope.

## Product identity

The product is a **private intelligence layer for a person's life**: capture, organize, retrieve, understand, preserve and selectively celebrate personal history.

It is not a public social network, cloud drive, generic AI chatbot, mandatory subscription SaaS, or daily diary.

## Non-negotiable architecture

- Flutter + Dart.
- Riverpod for state/dependency composition.
- GoRouter for navigation.
- Drift + SQLite for structured local data.
- Device filesystem for large attachments; never large SQLite blobs.
- Local-first; core functionality works without a backend.
- No mandatory account or company-hosted timeline.
- No mandatory cloud AI; prefer deterministic logic and on-device ML/AI.
- Pragmatic Clean Architecture and SOLID.
- Reuse helpers, utilities, services and components instead of duplicating logic.

## Domain model

Use Entity, Event, Evidence, Relationship, field provenance, temporal precision and candidate/confirmed lifecycle.

AI/import discoveries go to the Memory Inbox and require user confirmation. Never invent exact dates for approximate memories.

## Privacy and security

- Do not upload timeline content, photos, documents, OCR text or searches without an explicit approved architecture decision.
- Never leak sensitive content into analytics/crash logs.
- Enforce `share_safe`, `personal`, `sensitive`, `never_share`.
- Stories are sanitized local exports.
- User-owned backups are encrypted before leaving the device.
- Recovery must survive loss of the original device.
- Backup and Archive are separate concepts.

## UI direction

Design language: **Quiet Intelligence**.

- Modern, intelligent, calm, temporal and timeless.
- Tokenize colors, spacing, typography, radius and motion.
- Use Hugeicons Free through `AppIcons`; verify license before release.
- Do not mix icon libraries screen-by-screen.
- Prefer timeline structure over generic card feeds.
- Restrained indigo/violet intelligence accent.
- Avoid neon AI aesthetics, robot mascots, excessive glassmorphism, decorative gradients and constant animation.
- User memories provide most visual richness.
- Respect accessibility and Reduced Motion.

## Business model

- Free remains genuinely useful.
- Never gate access to user-created timeline data behind Pro.
- Free gets a generous taste of Pro intelligence.
- Primary direction: one-time Pro.
- Subscription only for a future service with genuine recurring cost.
- No advertising without an explicit product decision.

## Code quality

- Keep widgets presentation-focused.
- Business rules belong in domain/application layers.
- Avoid giant providers/services/widgets.
- Prefer composition.
- Add tests for important domain, privacy, backup, migration and recovery behavior.
- Consider backup/migration compatibility whenever persistent schemas change.
- Keep changes focused.

## Conflicts

If a request conflicts with an accepted ADR or these non-negotiables, do not silently violate them. Explain the conflict and propose the smallest compatible alternative. Major architectural changes require a new/superseding ADR.
