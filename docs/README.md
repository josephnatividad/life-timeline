# Life Timeline --- Product & Engineering Specification

> **Working title only:** "Life Timeline" is a generic project name and
> is not the final product/brand name.

This repository is the source of truth for the product we intend to
build: a private, local-first application that helps people capture,
organize, retrieve, understand, celebrate, and preserve their life
history without requiring the developer to host their personal timeline.

## Product thesis

**A private intelligence layer for your life.**

The product is not a diary, social network, cloud drive, or generic
chatbot. It is a structured personal history system whose timeline is
the primary interface.

A user should eventually be able to ask:

-   When did I replace my laptop?
-   How many phones have I owned?
-   Which documents expire this year?
-   What vehicles have I owned?
-   When did I first visit Japan?
-   How long did I work at a company?
-   What changed in my life during 2028?

Answers should come from the user's own structured records and link back
to supporting evidence.

## Core principles

1.  **Local-first:** timeline data lives on the user's device.
2.  **No mandatory account:** the core product should work without
    registration.
3.  **No company-hosted timeline:** backups and archives belong to the
    user.
4.  **Private AI first:** prefer deterministic logic and on-device
    ML/AI.
5.  **Human confirmation:** AI suggests; the user decides what becomes
    history.
6.  **Structured data first:** entities, events, evidence and
    relationships---not blobs of prose.
7.  **Portable for life:** backups, migrations and exports must be
    designed for decades.
8.  **Quiet Intelligence:** modern, intelligent UI without visual noise.
9.  **Private by default, share by choice:** share generated sanitized
    Stories, never raw private records.
10. **No feature hostage:** Free users retain access to their timeline
    and data.

## Documentation map

-   `01-product-vision.md` --- product definition, positioning and
    principles
-   `02-product-model.md` --- entities, events, evidence, relationships,
    provenance and temporal precision
-   `03-tech-architecture.md` --- Flutter/local-first architecture
-   `04-data-storage-and-longevity.md` --- database, files, migrations
    and long-term durability
-   `05-private-intelligence.md` --- local AI/OCR/search architecture
-   `06-security-privacy.md` --- privacy and security requirements
-   `07-backup-archive-recovery.md` --- backup vs archive and recovery
    design
-   `08-ui-design-system.md` --- Quiet Intelligence design system
-   `09-motion-icons-illustration.md` --- motion, Hugeicons and visual
    language
-   `10-stories-sharing.md` --- privacy-safe social sharing
-   `11-business-model.md` --- Free/Pro and long-term sustainability
-   `12-roadmap.md` --- MVP through future production phases
-   `13-testing-quality.md` --- testing, observability and code quality
-   `14-codex-implementation-guide.md` --- instructions for AI-assisted
    development
-   `adr/` --- architecture decision records
-   `.codex/skills/` --- reusable project-specific Codex guidance

## Current technical direction

``` text
Flutter + Dart
├── Riverpod
├── GoRouter
├── Drift + SQLite
├── SQLite FTS
├── Device filesystem
├── local_auth
├── flutter_secure_storage
├── On-device OCR / ML
├── Hugeicons Free
└── Platform APIs where required
```

Cloud services are not required for the MVP or core lifetime experience.
