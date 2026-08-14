# Product Roadmap

## Phase 0 --- Foundation / Specification

-   Finalize product model
-   Design tokens/components
-   Threat model
-   Backup format
-   Database schema
-   Architecture skeleton
-   Prototype timeline interactions

## Phase 1 --- MVP

Goal: prove that a private local timeline is useful and trustworthy.

Build:

-   Flutter application foundation
-   Riverpod / GoRouter
-   Drift/SQLite
-   Entity/Event/Evidence/Relationship model
-   Manual timeline entries
-   Temporal precision
-   Categories
-   Attachments
-   Memory Media hero/gallery roles and evidence separation
-   Basic search
-   Memory Inbox foundation
-   PIN/Biometric
-   Manual encrypted backup
-   Fresh-install restore
-   Basic reminders
-   Basic Stories/share cards
-   Free/Pro entitlement abstraction

Do not require:

-   Backend
-   User account
-   Company cloud storage
-   Cloud AI
-   Social network
-   Local LLM

## Phase 2 --- Private Intelligence

Private OCR remains required unless product scope explicitly approves shipping
manual document capture without OCR. The former ML Kit implementation was
removed from network-enabled builds because of SDK metrics; a privacy-approved
local replacement must pass the benchmark in
`research/LOCAL-OCR-REPLACEMENT.md`. Cloud OCR is not an alternative.

-   On-device OCR
-   Receipt/document extraction
-   Candidate memory generation
-   Provenance/confidence
-   Duplicate/entity matching
-   AI-assisted capture
-   Better local search
-   Initial insights
-   Pro trial actions

## Phase 3 --- Reflection & Sharing

-   Anniversaries
-   Milestones
-   Then & Now
-   Advanced Stories
-   Life Wrapped
-   Richer insights
-   Share privacy controls

## Phase 4 --- Long-Term Storage

-   Storage Manager
-   Attachment optimization
-   Archive engine
-   Thumbnails for archived content
-   Automatic user-owned backup
-   Google Drive/user-selected provider integration
-   Backup health
-   Recovery Kit

The Google Drive `appDataFolder` automatic-backup foundation is implemented
early as a stabilization dependency. Phase 4 still owns broader provider
support, Recovery Kit product work, and long-term backup-health refinement.

## Phase 5 --- Advanced Private AI

-   Local embeddings
-   Semantic search
-   Device capability detection
-   Optional downloadable local generative model
-   More natural Ask My Life
-   Relationship discovery

## Future / only after evidence

-   Additional import sources
-   Life Book/printing
-   Expansion domains
-   Optional hosted services
-   Optional cloud AI provider

Cloud sync is not part of the default direction and should only be
reconsidered if real user demand outweighs the privacy, compliance and
cost advantages of local-first.
