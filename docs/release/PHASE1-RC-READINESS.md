# Phase 1 Release-Candidate Readiness

Audit date: 2026-08-14

Scope: frozen Phase 1 implementation in `apps/mobile`

Authority: `AGENTS.md`, PDDs, accepted ADRs, then approved review documents

> Update after the frozen audit: the ML Kit P0 described in this report was
> resolved by removing ML Kit from network-enabled native dependency graphs.
> Manual document Evidence capture remains, and the local OCR replacement is a
> separate benchmark. The approved encrypted Google Drive `appDataFolder`
> backup foundation was then added. Historical measurements and findings below
> remain an audit record; current network findings are in
> `research/NETWORK-DEPENDENCY-AUDIT.md`.

## Executive Summary

The local-first core is coherent and the audit fixed concrete defects in
sequential migration, restore safety, backup replacement detection, attachment
lifecycle, candidate search indexing, reminder notification navigation/state,
app-switcher privacy, and search-query scaling. Expanded regression fixtures now
exercise semantic backup/restore, corruption, transactional candidate handling,
Story privacy attacks, 50-photo media, and a 10,000-memory database smoke test.

One known P0 remains: Google documents utilization/diagnostic metrics for the
native ML Kit SDK used by OCR. This conflicts with the product's unqualified
no-analytics promise. Android release removes network permissions, but iOS has
no equivalent manifest barrier. Product/privacy ownership must select an
audited no-telemetry engine, narrow release scope behind a verified boundary,
or formally revise the promise and disclosures. The code audit cannot make that
policy decision.

The implementation can proceed to controlled device testing, but the release
candidate is not approved for internal/external distribution containing OCR
under the current privacy promise.

## Automated Validation

Baseline before stabilization: 217 tests across 48 test files, all passing.

Audit additions cover:

- realistic encrypted backup -> destructive reset -> restore semantic equality;
- wrong password, truncation, ciphertext mutation, invalid manifest,
  missing/corrupt attachments, unsupported versions, and interrupted commit;
- sequential v1 -> v8 migration with active/archive/trash, temporal values,
  media, evidence, relationships, candidates, search, and reminders;
- foreign-key, uniqueness/index, soft-delete, archive-protected file, and
  transaction rollback behavior;
- notification acknowledgement/deep-link back stack and lock-gate privacy cover;
- Story privacy attacks across all five templates;
- 1/10/50-photo ordering, hero selection, Gallery scrolling, and non-eager
  original resolution;
- OCR interruption cleanup and no false complimentary usage;
- 100/1,000/10,000-memory timeline/search/Ask database smoke thresholds.

Final validation results:

- `dart format lib test`: 242 files checked; three audit files formatted;
- Drift/build_runner: completed successfully, 192 outputs verified/written with
  no generated source remaining changed;
- `flutter analyze --no-pub`: no issues;
- full `flutter test --no-pub`: 238/238 tests passed after the restore-selection
  lifecycle hotfix, an increase of 21 tests from the 217-test baseline;
- Android debug APK: built successfully at
  `build/app/outputs/flutter-apk/app-debug.apk` (207,118,716 bytes,
  SHA-256 `B0A9E7F17B124C25747C9038CCB442802EE155581E85764A0F3032BA2178939E`);
- additional split release-manifest verification: builds succeeded for
  `armeabi-v7a` (32,401,925 bytes), `arm64-v8a` (38,646,459 bytes), and
  `x86_64` (40,769,932 bytes). The current arm64 merged manifest retains
  biometric, notifications, reboot, and vibration permissions and contains
  neither `INTERNET` nor `ACCESS_NETWORK_STATE`;
- iOS build/check: not executable on this Windows host; macOS/Xcode remains a
  required manual gate.

Both Android build modes emit the expected future built-in-Kotlin warning for
the app, `file_picker`, `flutter_timezone`, `package_info_plus`, and `share_plus`.
Release builds here use non-production identity/signing and are validation
artifacts, not distributable release approval.

## Feature Inventory

Classification describes implemented product behavior, not whether physical
device QA or the remaining privacy decision is complete.

| Capability | State | Evidence and limitation |
| --- | --- | --- |
| Timeline | COMPLETE | Confirmed active events, temporal grouping, media hero, archive/trash isolation, and navigation are implemented. Query still materializes the complete active result set. |
| Add/Edit Memory | COMPLETE | Create/edit/detail flows, lifecycle actions, media, categories, privacy, and saved-detail navigation exist. |
| Temporal precision | COMPLETE | Exact, month, year, approximate, range, before, after, and unknown persist without fabricated exact dates. |
| Entities | PARTIAL | Domain/storage, candidate linking, search context, and targeted views exist; full Entity Detail/management from the visual reference does not. |
| Relationships | PARTIAL | Typed domain/storage and OCR confirmation links exist; general-purpose relationship management UI is intentionally incomplete. |
| Search | COMPLETE | SQLite FTS, lifecycle filtering, media-aware results, rebuilds, and candidate-confirmation indexing exist. Audit removed an N+1 result load. |
| Archive | COMPLETE | Record lifecycle archive/restore is implemented and excluded from normal surfaces. |
| Trash | COMPLETE | Soft delete/restore and dedicated Trash behavior are implemented. |
| Permanent deletion | COMPLETE | Transactional row cascade plus guarded app-managed file cleanup exists. Audit now preserves archive-referenced originals. |
| Memory Media | COMPLETE | Import/reference, captions, ordering, hero, thumbnails, optimization, deletion, and storage state exist. |
| Gallery | COMPLETE | Timeline-wide Gallery, memory Gallery, viewer, and unavailable/archive states exist. |
| Evidence | PARTIAL | Domain/schema, attachment/provenance relations, OCR evidence, and backup are implemented; general manual-evidence management is not. |
| OCR | PARTIAL | On-device capture/classification/extraction/candidate flow is implemented and failure-tested; the ML Kit metrics/privacy P0 prevents release approval. |
| Memory Inbox | PARTIAL | Candidate review/edit/link/confirm/ignore is transactional; ignored-candidate explicit deletion/retention is unresolved. |
| Private Intelligence | PARTIAL | Deterministic local V1 vertical slice is implemented; scope, accuracy/device limits, and OCR SDK privacy decision remain. |
| Ask My Life | COMPLETE | Deterministic supported queries, citations/supporting records, lifecycle filtering, and no generative fallback exist. |
| Insights | COMPLETE | Deterministic local insights, dismissal, privacy/lifecycle filtering, and empty/error states exist. |
| Stories | COMPLETE | Five approved template families, editor/preview/render/export, privacy review, and temporary-file cleanup exist. Story drafts are intentionally not persisted. |
| Then & Now | COMPLETE | Approved template/source selection and privacy sanitization exist. |
| Milestones | COMPLETE | Deterministic milestone derivation and Story integration exist. |
| Storage Manager | COMPLETE | Storage summaries, managed/referenced/archive states, optimization, and safety UI exist. |
| Archive Engine | COMPLETE | Encrypt/verify/save/reference/remove/reconnect/retrieve flows and compensating safety behavior exist. |
| PIN | COMPLETE | Salted Argon2id verifier, secure storage, constant-time comparison, and persisted throttling exist. |
| Biometrics | COMPLETE | OS biometric capability/authentication with PIN fallback exists; enrollment and hardware variants need physical-device QA. |
| App Lock | COMPLETE | Startup/resume policies, lock gate, notification gating, and lifecycle privacy cover exist; platform snapshot timing needs physical QA. |
| Encrypted backup | COMPLETE | User-selected destination, AES-256-GCM/Argon2id container, manifest/hash verification, normalized data, and managed attachments exist. |
| Restore | COMPLETE | Preflight/preview, replace transaction, staged attachment generation, search rebuild, read-model refresh, and reminder reconciliation exist. |
| Reminders | COMPLETE | Persist/edit/disable/complete/missed/opened/lifecycle reconciliation and privacy-safe content exist. |
| Local notifications | COMPLETE | Local scheduling, permission flow, timezone handling, action/deep-link coordination, and Back-to-Timeline stack exist; killed/reboot/OEM/iOS behavior remains device QA. |

No audited capability was implemented but undocumented. Some review documents
correctly describe later-phase vertical slices that the older roadmap still
places after Phase 1.

## Roadmap Realignment

| Priority | Finding | Disposition |
| --- | --- | --- |
| P0 | PDD says no analytics; ML Kit documents native utilization/diagnostic metrics. | Owner decision required; current external release blocked. |
| P2 | Memory Inbox Ignore is reversible but has no approved retention/delete policy for sensitive evidence. | Keep data to avoid silent loss; decide policy separately. |
| P2 | Full Entity Detail/general relationship/evidence management appears in design/reference expectations but is not a complete product surface. | Treat as deferred; do not infer a feature requirement from the mockup. |
| P3 | `12-roadmap.md` schedules OCR, intelligence, richer Stories, storage, and archive after the original Phase 1 while accepted V1/review docs and code now implement those vertical slices. | Realign roadmap only after product-owner scope approval; do not remove stable work. |
| P3 | Backup/archive/file-safety requirements are duplicated across PDD, security review, and V1 docs. | Keep PDD/ADRs authoritative; reviews serve as implementation evidence. |
| P3 | Working app identity, package IDs, and release signing remain provisional. | Fine for local QA; decide before external signing/distribution. |
| DEFERRED | Video, cloud sync/backup, automatic backup, semantic embeddings, local LLM, localization, photo editing, camera-roll ingestion, and Life Wrapped. | Explicitly excluded from this stabilization. |

No missing Phase 1 requirement was filled by inventing a new product capability.

## P0 Issues

### Open: ML Kit diagnostics versus no analytics

Google's own terms and platform disclosures describe ML Kit performance,
utilization, identifier, diagnostic, configuration, API-use, and error data.
On-device inference and lack of an app HTTP client do not negate that native SDK
behavior. See `docs/product/PHASE1-DECISIONS-REQUIRED.md` and
`docs/security/PRIVATE-INTELLIGENCE-REVIEW.md`.

### Closed during stabilization

- v1 -> v2 migration attempted to rebuild search through a v7 table that did not
  yet exist; migration now feature-detects `attachment_links`.
- restore staging could map a missing/corrupt staged attachment too late; size and
  existence are now verified before commit with generation cleanup.
- backup replacement preview ignored candidate-/reminder-only databases; all
  canonical tables now participate in user-data detection.
- permanent deletion could remove an attachment still protected by a verified
  archive reference; the file cleanup guard now includes archive references.

## P1 Issues

No known automated-test P1 remains after stabilization. Physical-device
backup/provider, notification/reboot, biometric, OCR, interruption, and iOS build
checks are still required before changing this conclusion.

Closed P1 defects:

- candidate confirmation did not index already-existing linked entity names;
- notification taps were recorded only as a route action and could still display
  Missed; notification acknowledgement is now durable and does not falsely
  complete a reminder;
- a notification-opened detail route could leave no in-app Back destination;
  Timeline is now established as root before pushing the destination;
- restored read models and notification schedules are invalidated/reconciled on
  successful commit, so restored data does not require an app restart.
- Android restore selection no longer depends on a document provider returning
  a nullable filesystem path. The native picker streams the selected URI into a
  controlled cache file and picker/inspection failures are visible. Privacy and
  lock screens are opaque overlays that keep an admitted navigator mounted, so
  platform picker/camera Futures survive background, immediate lock, and unlock.
  Controller disposal also cleans prepared staging without invalid Riverpod
  lifecycle reads.

## P2 Issues

- Timeline/database source queries still load the complete active timeline;
  Flutter lazily builds visible widgets, but true database pagination is deferred.
- Successful replacement retains obsolete app-managed attachment generations.
  They are unreferenced/app-private but consume space pending a transaction-aware
  garbage-collection design.
- Ignored OCR candidate retention/deletion needs product approval.
- Entity, relationship, and manual Evidence product surfaces remain partial.
- Low-storage, provider interruption, OS process death, notification delivery,
  biometric enrollment/lockout, and OCR image-quality outcomes require physical
  device testing.
- The Flutter lifecycle privacy cover is best-effort and must be verified against
  actual Android/iOS task-switcher capture timing.

## P3 / Technical Debt

- Date/temporal presentation has small repeated formatting paths worth
  consolidating only under targeted tests.
- Flutter 3.44.9 still uses the temporary Kotlin Gradle Plugin compatibility
  bridge. Built-in Kotlin app migration requires Flutter 3.47 or newer and
  compatible plugins; forcing it now is unsafe.
- `drift_flutter` currently resolves EOL compatibility packages
  `sqlite3_flutter_libs`/`sqlcipher_flutter_libs` transitively even though the
  current `sqlite3` native hooks are used. Track the upstream removal.
- Several safe major dependency updates exist but were not mixed into an RC
  stabilization audit.
- Final application identifiers, production signing, and distribution custody
  remain release-administration work.
- The roadmap needs an approved historical/current-phase realignment.

## Privacy Review

- Domain privacy classification is persisted, not UI-only.
- No application analytics, advertising, backend, cloud AI, account system, or
  personal-content network client was found.
- Searches found no production logging of titles/descriptions, OCR text, Ask
  questions, document values, paths/content, PINs, passwords, or keys.
- Story sanitization blocks `neverShare`, enforces explicit policy for sensitive
  and personal fields, and prevents Evidence images from becoming ordinary
  Story media. Attack tests cover all templates.
- Notification payloads remain generic; private note and linked personal data are
  not placed on the lock screen.
- Android main/release manifest removes `INTERNET` and `ACCESS_NETWORK_STATE`;
  debug/profile add internet for Flutter tooling. iOS has no equivalent barrier.
- ML Kit's documented metrics remain the open P0. Vendor sources:
  [terms](https://developers.google.com/ml-kit/terms),
  [Android disclosure](https://developers.google.com/ml-kit/android-data-disclosure),
  [Apple disclosure](https://developers.google.com/ml-kit/ios-data-disclosure).

## Security Review

- PIN verification uses Argon2id, random salt, secure storage, constant-time
  comparison, persisted retry throttling, and best-effort derived-byte clearing.
- Biometrics are OS-mediated and always fall back to PIN; templates are not
  received or stored by the app.
- App lock evaluates startup/resume policy, gates notification destinations, and
  now covers UI during inactive/paused/hidden/detached states.
- Backup/archive use reviewed package cryptography: independent recovery
  password, bounded Argon2id parameters, AES-256-GCM authenticated container,
  SHA-256 inventory, defensive ZIP/path limits, generic failure mapping, and no
  password escrow.
- Restore validates before mutation and replaces rows transactionally after
  staging a unique attachment generation. Plaintext staging is app-private and
  cleaned best-effort; process-death residue remains manual QA.
- Live SQLite is not application-level encrypted and relies on OS storage
  protection plus UI app lock, as already documented and accepted for this phase.

## Data Integrity

Schema version is explicitly v8, with seven sequential upgrade steps (v1 -> v2
through v7 -> v8). There are 22 persistent tables plus derived FTS5
`event_search`:

- core: `entities`, `events`, `evidence`, `attachments`, `attachment_links`,
  `relationships`;
- taxonomy: `tags`, `categories` and six entity/event/evidence join tables;
- provenance/intelligence: `memory_candidates`, `candidate_extracted_fields`,
  `candidate_entity_proposals`, `feature_usage`, `field_provenance`;
- state/storage: `insight_dismissals`, `archive_references`, `reminders`.

Foreign keys are enabled. Cascades/set-null, partial single-hero uniqueness,
event/evidence attachment-link uniqueness, archive-reference uniqueness,
notification-ID uniqueness, lifecycle/type/date/search/reminder/provenance indexes,
and transaction boundaries protect the principal relationships. Binaries remain
outside SQLite. Story output is temporary/exported rather than persisted as
Story metadata, so no Story table is required by the approved V1 behavior.

The sequential migration torture test preserves representative active,
archived, trashed, temporal, relationship, evidence, media, candidate, FTS, and
reminder state and finishes with a clean `PRAGMA foreign_key_check`.

## Backup/Restore

The semantic fixture goes beyond "restore completed": it compares canonical
counts/IDs, exact/approximate/range temporal forms, entity relationships,
Evidence and its three media roles, photo ordering/hero/captions, checksums,
privacy, archive references, candidate/provenance, reminders, FTS, and lifecycle
visibility after a destructive reset.

Wrong-password, truncated/modified ciphertext, invalid-manifest,
missing/corrupt-attachment, future-version, and interrupted-commit cases leave
existing rows/files usable. Old supported normalized snapshots remain accepted.
Fresh install and replacement still need real provider/device testing, including
low disk and hard process termination.

## Performance

The audit replaced per-result search row loading with one ordered batch query.
An in-memory smoke fixture at 100, 1,000, and 10,000 events stayed within generous
regression thresholds (timeline/Ask under 30 seconds and FTS search under five
seconds on the audit host); the full suite portion completed in under one second.
This is a guardrail, not a mobile benchmark.

Remaining risk is full Timeline materialization and full-set deterministic
aggregation at long-horizon scale. Minimum-device profiling must capture startup,
query time, frame jank, peak memory, SQLite size, Gallery/detail behavior, and
real-image decode at 10,000 memories before declaring performance production-ready.

## Accessibility

The implementation uses the tokenized Material 3 light/dark themes, Dynamic Type
compatible text, documented target sizes, semantic labels/states, Reduced Motion
helpers, non-color-only status copy, confirmation for destructive actions, and
`AppIcons`/Hugeicons abstraction. The audit found no reason for a wholesale
visual redesign.

Automated widget coverage cannot certify maximum text scale, TalkBack/VoiceOver
reading order, switch navigation, every contrast combination, platform dialogs,
or actual reduced-motion settings. Those checks are enumerated in the device QA
plan.

## Platform Status

### Android

- Flutter/FVM pin: 3.44.9 stable.
- The release manifest now permits Internet/network-state access solely for
  the approved encrypted Google Drive backup destination and still denies
  Android application backup.
- A release APK was built and its packaged manifest, DEX inventory, and
  `releaseRuntimeClasspath` were audited after ML Kit removal.
- Current builds warn that `file_picker`, `flutter_timezone`,
  `package_info_plus`, `share_plus`, and the pinned `workmanager_android` still
  apply the Kotlin Gradle Plugin.
  Flutter's documented app migration requires 3.47+, so the warning is WATCH
  rather than a risky RC-time migration.
- Production application ID/signing are not approved.

### iOS

- Target configuration remains at minimum iOS 15.5; ML Kit is no longer in the
  dependency graph.
- This Windows audit host cannot execute Xcode/iOS compilation, signing, SPM
  resolution, simulator, or physical-device checks. A macOS/Xcode run is required.
- Apple Vision/replacement-OCR evaluation, Face ID/Touch ID,
  notification/Focus behavior, Google Drive OAuth/URL schemes, provider file
  operations, device-only secure-storage behavior, and snapshot cover are
  explicit manual gates.

Flutter's migration reference: [migrate an app to built-in Kotlin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers).

## Dependency Risks

The Google Drive bridge added only the approved auth/transport/scheduler
dependencies. Dependency churn remains separate from stabilization.

| Class | Dependencies/findings | Action |
| --- | --- | --- |
| HEALTHY | `archive`, `cryptography`, Drift, Riverpod, GoRouter, local notifications, `image`, `image_picker`, `local_auth`, path/path-provider, timezone, Hugeicons behind `AppIcons` | Retain normal update/license review. |
| WATCH | `file_picker` 10.3.10, `flutter_timezone`, `package_info_plus` 9.0.1, `flutter_secure_storage` 10.3.1, `share_plus` 12.0.2, the atomic Workmanager 0.9.0 compatibility set, and Flutter 3.44 Kotlin bridge | Reassess compatibility, changelogs, licenses, and majors in a separate upgrade branch; remove the Workmanager overrides after Flutter 3.47+ and plugin compatibility are verified. |
| REPLACE LATER | EOL transitive `sqlite3_flutter_libs` and `sqlcipher_flutter_libs` compatibility packages resolved through `drift_flutter`; local OCR engine intentionally absent pending benchmark | Follow upstream native-hook removal; do not delete transitives manually. Select/audit the local OCR replacement from benchmark evidence. |
| REMOVE | None confirmed | Avoid speculative removals during freeze. |

Direct packages use permissive/open-source licenses or reviewed vendor terms.
ML Kit was removed because its SDK metrics conflict with the privacy promise;
no cloud OCR fallback is allowed. `file_picker` 11 includes fixes but also
compatibility/API changes; upgrading solely to chase the Kotlin warning is not
justified under the pinned toolchain.

## Manual QA Remaining

The complete checkbox matrix is in `docs/qa/PHASE1-DEVICE-QA.md`. Mandatory gates
include real backup/restore and corruption/interruption/low-disk behavior,
historical installed-app upgrades, archive provider loss/reconnect, notification
delivery after process death/reboot/timezone/permission changes, biometric
enrollment and lockout, app-switcher privacy, Story attack attempts, OCR quality
and traffic inspection, 1/10/50 real photos, core airplane-mode operation,
minimum-device 10,000-memory profiling, light/dark/max-text/Reduced Motion, and
TalkBack/VoiceOver.

## Deferred Features

No video, cloud sync, automatic or user-owned scheduled backup, accounts,
backend/cloud AI, semantic embeddings, local LLM, localization, photo editing,
camera-roll ingestion, or Life Wrapped was added. Full entity/relationship/manual
Evidence management, ignored-candidate deletion policy, attachment-generation
garbage collection, and true Timeline pagination remain explicitly deferred or
decision-gated.

## Release Recommendation

**NOT READY FOR PUBLIC V1**

The ML Kit privacy P0 is resolved by SDK removal, not by weakening the privacy
promise. Remaining release gates are physical-device Drive/network QA, final
Google OAuth/bundle identity configuration, iOS CocoaPods/Xcode build and
dependency audit, and either restoration of a benchmarked privacy-approved
local OCR engine or explicit product approval to ship manual document capture
without OCR. No cloud OCR fallback is permitted.
