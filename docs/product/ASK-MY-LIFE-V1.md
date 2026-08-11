# Ask My Life V1

Status: implemented local deterministic vertical slice.

Ask My Life V1 answers a bounded set of questions from confirmed structured records stored in the local Drift/SQLite database. It is not a chatbot and does not use a generative model.

## Architecture

```text
User question
  → RuleBasedLifeQueryInterpreter
  → typed LifeQueryIntent
  → DriftLifeQueryExecutor
  → local SQL over Entity/Event/Relationship/Category data
  → typed LifeQueryResult
  → evidence-backed answer and Supporting Records sheet
```

The domain owns `LifeQueryInterpreter`, `LifeQueryExecutor`, intent types, result types, supporting-record references, insight identity, and temporal-duration rules. Flutter and Drift remain outside the domain layer.

Questions and answers are transient UI/application values. They are not persisted, logged, sent to analytics, or transmitted. There is no network fallback.

## Supported questions

| Question family | Examples | Typed intent and behavior |
| --- | --- | --- |
| Entity count | “How many phones have I owned?” | `CountEntities`; counts distinct categorized entities connected to confirmed acquisition history. |
| Current/latest entity | “When did I buy my current laptop?” | `FindLatestEntity`; chooses the latest confirmed acquisition and preserves its recorded temporal precision. |
| Previous entity | “What laptop did I have before this one?” | `FindPreviousEntity`; requires at least two confirmed acquisition histories. |
| Entity history | “What vehicles have I owned?” | `FindEntitiesByCategory`; returns confirmed categorized entities and source references. |
| Longest ownership | “What was my longest-owned phone?” | `FindLongestOwnedEntity`; requires at least two eligible acquisition spans. |
| Document expiry | “Which documents expire this year?” | `FindExpiringDocuments`; matches confirmed document entities connected to expiry/renewal events in the requested year. |
| Travel by year | “Where did I travel in 2025?” | `FindTripsByYear`; returns confirmed travel events whose temporal range intersects the year. |
| Places visited | “Which places have I visited?” | `FindPlacesVisited`; requires place entities connected to confirmed travel events. |
| Career start/history | “When did I start my current job?” | `FindCareerHistory`; uses confirmed career-start events connected to employer entities. |
| Replacement history | Questions using replace/replacement/upgrade terminology | `FindReplacementHistory`; returns confirmed replacement events for the requested entity category. |
| Year summary | “What happened in 2026?” / “What happened last year?” | `SummarizeYear`; reports deterministic counts and the exact supporting events intersecting that year. |

Project-owned intents also support direct entity lookup, events by bounded terminology, date-range queries, individual ownership duration, total confirmed memories, most-active-year aggregation, and exact-date anniversary eligibility. These support Insights and future approved UI without expanding V1 into arbitrary language understanding.

## Phrase and synonym behavior

`LifeQueryLanguage` centralizes normalization, aliases, event terminology, and year extraction. Feature widgets contain no parsing rules.

Initial entity aliases include:

- phone, phones, smartphone, smartphones, mobile phone;
- computer, laptop, desktop, tablet;
- vehicle, car, motorcycle, truck;
- document, passport, license, warranty;
- place, country, city, destination; and
- job, career, employer, company, work.

Initial event terminology includes:

- acquisition: bought, purchased, got, acquired, started using;
- expiry: expires, expiration, renewal, valid until;
- travel: traveled, trip, visited, flew;
- career start: started, joined, hired, began;
- replacement: replaced, replacement, upgraded, switched; and
- disposal: sold, disposed, retired, gave away, replaced.

Normalization is case-insensitive and punctuation-insensitive. An explicit four-digit year wins. “This year” uses the local current year; “last year” uses the previous year.

This vocabulary is intentionally conservative. V1 does not guess the meaning of an unsupported question.

## Evidence-backed results

Every answered `LifeQueryResult` contains the exact event/entity references used to produce it. It can include:

- answer type and status;
- headline, summary, and numeric value;
- event IDs and entity IDs;
- supporting records with title, type, context, and unmodified `TemporalValue`;
- confidence derived from deterministic/temporal eligibility rather than model probability;
- temporal precision; and
- typed presentation metadata such as duration labels and year-summary counts.

The Supporting Records sheet renders those same references. It does not expose SQL rows or internal provenance fields. Event references can open Memory Detail; entities remain readable in the supporting sheet until Entity Detail is an approved implemented feature.

If the intent is understood but evidence is insufficient, the result says that more relevant timeline history is needed and provides no fabricated record. If interpretation fails, the result says, “I don't know how to answer that yet,” and retains the supported suggestions.

## Temporal behavior

V1 never creates a date or precision value.

- Exact dates may support year-and-month duration wording.
- Month precision produces “About …” duration wording because the exact day is unknown.
- Year precision produces whole-year “About …” wording.
- Approximate precision produces “Roughly …” wording.
- Ranges produce a rough duration range.
- Unknown, before, and after values do not support an exact ownership-duration claim.
- “N years ago today” is eligible only for an exact date whose month and day match today and whose year is exactly 1, 5, or 10 years earlier.

Year queries use range intersection, so an event recorded as a range can correctly support each intersecting year without being coerced into one exact date.

## Lifecycle and privacy rules

Normal queries require `confirmed` entities, events, and relationships. Archived and soft-deleted records do not contribute to counts, latest/previous selection, rankings, summaries, durations, or supporting records.

No code in the Insights feature imports a network client or logging API. Questions, result text, record names, and supporting titles are never written to logs or the dismissal table. Privacy classifications remain on the underlying domain records and are not weakened by query presentation.

## Performance

- SQL performs lifecycle filtering, relationship traversal, date-range filtering, most-active-year aggregation, and indexed lookups.
- Ownership history uses one bounded relationship query per requested category, not one query per entity.
- Existing SQLite/Drift storage and FTS remain authoritative; no second search database exists.
- Schema v5 adds indexes for entity type, event type, and relationship type, plus the dismissal table.
- Query results are calculated on demand. No personal question/search history cache is retained.
- Explore/Insight providers invalidate when active, archived, or trashed timeline streams change and after restore.
- Answers currently materialize every matching supporting-record reference so counts and evidence cannot diverge. Very large timelines may eventually need paged evidence lists while keeping the aggregate answer in SQL.

## Known limitations

- Entity category matching relies on structured entity type or assigned category. V1 does not infer that an arbitrary product name is a phone solely from its name.
- Free-form event types can use terminology outside the bounded V1 aliases.
- “Current” means the latest confirmed acquisition/start record; V1 does not infer an unrecorded disposal.
- Expiring “soon” currently resolves to the current calendar year; configurable horizons are not included.
- Travel/place answers require explicit structured relationships and terminology.
- Supporting entities do not yet have a dedicated Entity Detail route.
- V1 does not answer compound, hypothetical, causal, emotional, medical, financial-advice, or generative-summary questions.

## Future semantic/local-model path

A future interpreter may use local embeddings or an optional local generative model to map more natural language into the same bounded typed intents. The executor and evidence-backed result contract remain authoritative: no model may generate personal-history facts outside referenced local records.

Remote embeddings, cloud AI, and a vector database are not part of V1. Any future provider that can transmit personal content requires a new accepted ADR and privacy/security review.
