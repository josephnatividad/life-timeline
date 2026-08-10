# Private Intelligence V1 Product and UX Review

Status: Phase 2 local vertical slice implemented for review.

## Supported flow

`Capture → local OCR → deterministic extraction → Memory Inbox → editable review → confirm/link/create → Timeline`

Manual memory entry remains a first-class, always-available path and never consumes a complimentary private-read action.

## Supported document scenarios

| Type | V1 signals and proposed fields | Notes |
| --- | --- | --- |
| Receipt | merchant, total, currency, unambiguous purchase date | Total is chosen from the last total-like line. Line items and tax arithmetic are not reconstructed. |
| Warranty | product, model, serial number, expiry/valid-until text | Expiry is a suggestion only; no notification is scheduled. |
| Product | brand, model, serial/IMEI | Exact confirmed serial reuse is strongest; serials are sensitive. |
| Travel | carrier, booking/PNR, departure, arrival | Booking references are sensitive. Time-zone and itinerary inference are deferred. |
| Identity | narrow document-number suggestion | Number is `neverShare`, low-confidence, and always requires review. This is not identity verification. |
| Generic document | a conservative title | Used only when enough text exists but no strong type wins. |
| Unknown | no candidate | Very short or unusable text does not consume an action or create Inbox clutter. |

Classification is bounded to these types. It does not invent new categories or product features.

## Confidence behavior

Confidence is shown as plain-language review guidance, not a precision claim:

- useful/high: “The local reading looks useful. Please confirm…”;
- mixed: “Some details may need correction…”;
- low: “The document type or several fields are uncertain…”;
- field-level low confidence: “Needs a closer look.”

No candidate reaches Timeline without a confirmation action. Fields remain editable. Identity numbers and other `neverShare` fields are visibly marked for careful review.

## Extraction and temporal rules

- Classification and extraction are deterministic and document-specific.
- Labels such as total, serial, model, expiry, carrier, booking, departure, and arrival anchor extraction.
- Currency symbols/codes are suggestions and can be ambiguous (`¥` cannot determine JPY versus CNY alone).
- Only an unambiguous year-first numeric date becomes `exactDate` automatically.
- Slash-form dates remain a field suggestion while the candidate temporal value stays `unknown`; V1 never creates a fake exact date.
- Raw OCR text is not production content and is not persisted.

## Successful fixture examples

- A clear receipt with merchant, ISO date, and `TOTAL USD 10.80` creates a receipt candidate titled “Purchase at …”, with editable total/date/currency fields and an organization proposal.
- A clear passport-like fixture creates an identity candidate with its document number classified `neverShare` and flagged for review.
- A confirmed candidate creates a searchable event, connects the source evidence, optionally creates or links an entity, and resolves the Inbox record in one transaction.

Fixtures contain synthetic values. Mockup/reference text is not used as production content.

## Duplicate and entity guidance

- A candidate whose normalized title and temporal value exactly match an existing event receives an explicit possible-duplicate surface and a link to inspect the existing memory.
- Entity reuse first checks an exact serial from previously confirmed candidates.
- Otherwise it scores exact normalized name and entity type and explains the reasons.
- The user chooses whether to link or create. V1 never silently merges records.

Fuzzy alias resolution, address-based organization matching, transliteration, and probabilistic merges are deferred.

## Poor-quality and unsupported scenarios

- blur, glare, shadows, perspective distortion, tiny text, handwriting, damaged thermal receipts;
- multi-column invoices, itemized receipt reconstruction, tables, checkboxes, and handwriting;
- multi-page PDFs and document batches;
- non-Latin scripts in V1;
- locale-dependent ambiguous dates and numbers;
- reliable extraction from identity MRZ/barcodes;
- automatic warranty/travel reminder scheduling;
- semantic or generative summaries.

The UI responds with a calm retry/manual-entry path and does not create a low-information unknown candidate.

## Capture and attachment behavior

Scan and Take Photo both use the system camera in V1. Choose Photo uses the system photo picker. The selected original is not modified. An oriented, bounded optimized JPEG is retained in app-private storage after a candidate is created; working files are deleted.

The domain already distinguishes optimized copy, preserve original, and reference original. V1 capture deliberately uses optimized copy because camera/cache references are not durable and the product has not approved a storage-choice prompt. Preserve/reference UI remains deferred.

## Complimentary access

`ProFeature.aiCapture` is a project-owned capability. A local configurable policy currently supplies 10 complimentary successful candidate creations. Cancelled selection, OCR failure, unusable/unknown text, review, confirmation, and manual entry do not count. The quantity is provisional and requires product approval; there is no final paywall or monetization screen in this slice.

## Quiet Intelligence and accessibility

- neutral surfaces, normal typography, restrained intelligence cards, no neon or generative “magic” treatment;
- all icons flow through `AppIcons`;
- privacy and uncertainty are expressed in text, not color alone;
- layouts scroll/reflow and use the design-system spacing/type tokens;
- progress updates use a live region;
- existing Reduced Motion behavior remains authoritative; the capture flow adds no decorative motion.

## Explicitly deferred

Cloud services, accounts, remote OCR, local generative LLMs, semantic search, scheduled reminders, PDF ingestion, multi-page scanning, advanced perspective correction, non-Latin model bundles, final Pro paywall, server-validated entitlement, automatic merges, and background batch capture.

## App-size and performance impact

Verified ABI-split release APKs are 29.0 MB (32-bit ARM), 35.1 MB (64-bit ARM), and 37.1 MB (x86_64). In the arm64 artifact, directly identifiable bundled OCR model/pipeline entries account for about 12.34 MB compressed. Preprocessing bounds the longest image edge to 2048 pixels and runs decode/orientation/resize on an isolate. Native OCR remains device-dependent; older devices may take several seconds and damaged very-large inputs can still exert transient decode memory pressure.

## Human approvals still required

1. Complimentary action quantity (the implementation default is 10).
2. Raising iOS support from 13.0 to 15.5 for the chosen current ML Kit bridge.
3. Retention/purge policy for ignored reversible candidates and their managed images.
4. Whether future capture should expose optimized/original/reference storage choices.
5. Whether “Scan document” should ship before dedicated edge/perspective scanning exists.
