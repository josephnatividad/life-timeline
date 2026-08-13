# Private Intelligence

## Principle

**Local AI first. Cloud AI never required.**

The product should be useful even without a generative model.

## Intelligence ladder

### Level 1 --- deterministic

Runs everywhere:

-   SQLite queries
-   SQLite FTS
-   Date/currency parsers
-   Regex
-   EXIF parsing
-   Statistics
-   Taxonomy/rules
-   Relationship queries

### Level 2 --- on-device ML

Where supported:

-   OCR
-   Document classification
-   Image classification
-   Entity extraction
-   Embeddings
-   Semantic matching

### Level 3 --- local generative intelligence

Optional downloadable capability on sufficiently capable devices:

-   Natural-language interpretation
-   Complex extraction
-   Summaries
-   Conversational queries

The core product must remain functional without Level 3.

## Structured query before LLM

Questions such as these should prefer deterministic structured queries:

-   How many phones have I owned?
-   Which documents expire this year?
-   What was my longest-owned laptop?
-   What vehicles did I own between 2018 and 2025?

Use AI primarily to interpret messy input or natural language, not to
invent answers.

## Evidence-backed answers

Every answer from "Ask My Life" should provide references to the records
used.

Never present unsupported model-generated personal history as fact.

## Capture pipeline

Document scanning and Memory Media import are intentionally separate. Add
Photos stores a curated memory image and never starts OCR automatically. Scan
Document is the explicit extraction path for receipts, warranties, tickets,
certificates, and official documents. Image recognition, face inference,
location inference, and embeddings are not run for Memory Media in V1.

``` text
Photo/document
      ↓
On-device OCR
      ↓
Classifier/parser
      ↓
Candidate fields
      ↓
Confidence/provenance
      ↓
User review
      ↓
Confirmed entity/event/evidence
```

## Free/Pro AI

Because local inference has no recurring developer inference cost, Free
can receive a generous taste of Pro AI actions.

Pro can unlock unlimited supported on-device intelligence.

Do not introduce cloud credits unless a future optional cloud service
actually incurs ongoing cost.
