# ADR-0004: Local AI First; Cloud AI Not Required

-   Status: Accepted
-   Date: 2026-08-09

## Decision

Prefer deterministic queries and on-device OCR/ML. The core product must
not depend on cloud AI.

A future cloud provider may exist only as an optional implementation
behind `IntelligenceProvider` and requires a separate ADR/privacy
review.

## Rationale

Privacy, offline operation, predictable economics and one-time pricing
all improve when inference stays on-device.
