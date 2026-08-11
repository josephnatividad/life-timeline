# Insights V1

Status: implemented deterministic local vertical slice.

Insights V1 derives a small set of evidence-backed observations from confirmed structured history. It uses the same typed query executor as Ask My Life and never treats weak/incomplete data as an insight.

## Supported insights and eligibility

| Insight | Eligibility |
| --- | --- |
| Confirmed-memory total | At least three confirmed events. Unknown dates count toward the total but not toward timeline span. |
| Timeline span | At least three confirmed events and at least two distinct known years. |
| Phone/computer/vehicle count | At least two categorized entities, each connected to a confirmed acquisition event. |
| Places visited | At least two place entities connected to confirmed travel events. |
| Upcoming document expiry | At least one confirmed document entity connected to an expiry/renewal event in the current year. |
| Longest-owned phone/computer | At least two eligible ownership histories with supported temporal precision. |
| Current-year summary | At least three confirmed memories intersecting the current year. |
| Most-active year | At least one dated confirmed event; SQLite groups by start year and resolves a tie in favor of the more recent year. |
| Anniversary milestone | An exact-date confirmed event exactly 1, 5, or 10 years ago today. Year-only, month-only, approximate, range, before, after, and unknown dates are ineligible for “today” wording. |

Explore displays approximately 3–5 eligible insights in priority order. It uses one prominent intelligence surface followed by compact rows rather than a dashboard grid. An eligible insight may exist without appearing in the first five.

## Deterministic generation

`DeterministicInsightEngine` requests typed results from `LifeQueryExecutor`. Every insight wraps one `LifeQueryResult`, retaining its entity/event references. The engine does not generate prose from a model and does not scan raw attachment/OCR text.

Eligibility is evaluated after lifecycle, category, relationship, and temporal rules. Insufficient query results are discarded rather than displayed with speculative wording.

## Identity, dismissal, and regeneration

An insight identity contains:

- `insightType`;
- optional non-content `subjectId` such as `phone` or a year;
- a versioned stable fingerprint derived from result type, result wording, numeric value, and supporting record IDs; and
- `dismissedAt`.

Schema v5 stores only `insight_type`, `subject_key`, `data_fingerprint`, and `dismissed_at`. It does not store the insight headline, record names, question text, or answer text.

Dismissal applies only to an exact type/subject/fingerprint. When supporting IDs or derived values materially change, the fingerprint changes and the insight may become eligible again. A dismissed unchanged insight does not return on each launch.

Insight dismissals participate in encrypted user-owned backup/restore. Restore invalidates the Explore/Insights providers.

## Temporal precision

Ownership duration uses `PrecisionAwareDurations`:

- exact date: detailed years/months where supported;
- month: “About” years/months;
- year: “About” whole years;
- approximate: “Roughly” whole years;
- range: rough minimum–maximum duration; and
- before/after/unknown: ineligible.

An absent disposal event means the eligible ownership span ends at the current local date. This is described as recorded ownership, not proof that the user still owns the entity.

Year summaries count events whose stored temporal range intersects the year. They do not manufacture exact dates.

## Explore behavior

Explore has editorial sections:

- **Insights:** eligible deterministic observations;
- **Things:** a restrained sample of categorized confirmed entities;
- **Years:** recent non-empty deterministic year summaries;
- **Places:** confirmed place/travel relationships; and
- **Categories:** lightweight entry points into supported Ask My Life questions.

The screen deliberately avoids a KPI dashboard and repeated identical cards. Low-data sections contain calm explanatory copy rather than fake statistics.

## Life Wrapped dependencies

The deterministic `SummarizeYear` result provides the initial future Life Wrapped input:

- total confirmed memories;
- trips;
- acquisition/purchase events;
- career-start/milestone events;
- document expiry/renewal milestones; and
- exact supporting event references.

Life Wrapped itself is not implemented. Before it can ship, the product still needs approved Story templates, privacy sanitization/review, additional summary taxonomy, stable category semantics, image/evidence selection, and expressive Story motion. Insights V1 does not bypass those dependencies.

## Privacy and lifecycle

Only confirmed records participate. Archived and soft-deleted records are excluded. There is no cloud service, account, analytics event, remote model, embedding store, or personal-content log.

The company receives no copy of insight inputs or outputs under the default architecture.

## Known limitations and future work

- V1 taxonomy is intentionally bounded and English-first.
- Entity category quality depends on structured type/category data.
- Current ownership/job status cannot be inferred when an ending event was never recorded.
- No background scheduling or notifications are added for expiry/anniversary insights.
- Dismissal fingerprints are versioned but there is no cleanup/compaction policy yet; rows contain no personal text and are small.
- Cross-category replacement graphs and richer career tenure remain future deterministic extensions.
- Local semantic interpretation may later map more phrases to existing typed intents; it must preserve the same evidence contract.
