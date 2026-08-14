# Private Intelligence V1 Security Review

Status: implemented review, Phase 2 local vertical slice
Authority: `AGENTS.md`, PDDs, and accepted ADRs remain authoritative.

> Historical baseline: the ML Kit implementation reviewed below was removed
> from network-enabled builds on 2026-08-14. It is not in the current native
> dependency graph. The capability/repository/domain boundaries and stored
> OCR-derived data remain, while Scan Document uses manual Evidence capture.
> See `research/LOCAL-OCR-REPLACEMENT.md` and
> `research/NETWORK-DEPENDENCY-AUDIT.md` for the active release position.

## Decision summary

Private Intelligence V1 processes selected images on Android and iOS without an application-authored network request. The pipeline uses a bundled Latin-script ML Kit recognizer through a project-owned interface, deterministic Dart classifiers/extractors, app-private attachment storage, and the existing Drift domain/repository boundaries. OCR output remains candidate data until explicit confirmation.

No backend, account, cloud AI, remote OCR, application analytics, content telemetry, or generative model was introduced. However, Google states that ML Kit SDKs send performance and utilization metrics and documents collection of SDK/device identifiers, diagnostics, configuration, API usage, and error data. That native SDK behavior conflicts with the product's unqualified no-analytics promise even though inference is on-device and the reviewed application code does not send OCR content. This is a P0 release decision, not a detail that the implementation review may waive.

## Dependency review

| Dependency | Version/constraint | Purpose | License | Maintenance/risk decision |
| --- | --- | --- | --- | --- |
| `google_mlkit_text_recognition` | `0.15.1` | Flutter bridge to native on-device OCR | MIT | Community maintained, not a Google-supported Flutter plugin. Pinned below 0.16.0 because 0.16.0 adds another Kotlin Gradle Plugin user and worsens Flutter's built-in-Kotlin migration warning. Review this pin when the plugin supports built-in Kotlin. |
| Google ML Kit Text Recognition | Android `16.0.1`, iOS native package via plugin | Bundled Latin recognizer | Google SDK terms | Mobile-only. Android model is statically linked, not the Play Services download variant. Current iOS integration raises the deployment target to 15.5. Google documents SDK utilization/diagnostic data collection, so privacy approval or an engine change is required before external release. |
| `image_picker` | `^1.2.3` | Camera and system photo selection | BSD-3-Clause | Flutter-team package. Selected files may initially be system/cache paths; the pipeline makes its own working and managed copies. |
| `image` | `^4.9.1` | Orientation normalization, bounded resize, JPEG encoding | MIT | Pure Dart and network-free. Decode/resize is isolated to avoid blocking the UI, but large damaged images can still create memory pressure before resizing. |

The feature has no direct `http`, Firebase, application-analytics, advertising, cloud-storage, or remote-model dependency. The lockfile does contain `http` transitively through existing/web-capable packages such as `package_info_plus`, file selectors, SVG support, and `image_picker` platform interfaces; Private Intelligence imports none of those HTTP APIs. Android's removed network permissions provide a stronger release-runtime boundary. Transitive and native SDK behavior must be re-audited during dependency upgrades, especially on iOS where there is no equivalent manifest permission gate.

Android release shrinking needs narrow `-dontwarn` entries for the plugin's optional Chinese, Devanagari, Japanese, and Korean option classes because those libraries are intentionally `compileOnly` and absent. The rules do not suppress the Latin recognizer or general ML Kit diagnostics. A release APK build verifies the configuration.

## Data flow and trust boundaries

1. The user explicitly selects scan, camera, or an existing photo.
2. `image_picker` returns a platform file reference.
3. A temporary app-controlled JPEG is created. Orientation is normalized and the longest edge is bounded to 2048 pixels on an isolate. The source file is never modified.
4. The bundled native Latin recognizer receives only the temporary local path.
5. Recognized text is held in memory. Deterministic classification and document-specific extractors create typed fields with confidence, privacy, and extraction method.
6. Raw OCR text is discarded. It is not logged or stored wholesale.
7. If a useful candidate exists, the optimized image is copied to app-private managed attachment storage. SQLite stores only metadata, checksum, byte size, MIME type, import mode, and relative path.
8. Evidence, attachment metadata, candidate, structured fields, entity suggestions, and provenance commit in one Drift transaction.
9. The complimentary action counter increments only after that transaction succeeds.
10. Confirmation commits the event, optional entity, evidence/entity relationships, confirmed provenance, candidate resolution, and search entry in one transaction.

## Temporary and managed files

- The temporary working copy is deleted in a `finally` path after success, cancellation after preparation, empty OCR, extraction failure, or persistence failure.
- A managed attachment copied before a failed candidate transaction is removed during rollback handling.
- App or OS termination between native file creation and cleanup can leave an orphan in the app temporary directory. Each subsequent preparation pass removes owned `private_intelligence/ocr_*.jpg` working files older than 24 hours; the OS may also reclaim temporary storage.
- Confirmed optimized copies participate in the existing encrypted backup architecture.
- Ignored candidates remain reversible and therefore retain their evidence/attachment. A retention policy and purge command require product approval.

## Persistence and privacy classification

Persisted candidate data is limited to the proposed title/description, document type, overall confidence, structured fields, entity proposals/matches, duplicate event reference, temporal value, evidence/attachment metadata, and field provenance.

Privacy is field-aware:

- ordinary merchant/product/travel fields default to `personal`;
- serial numbers and booking references are `sensitive`;
- identity document numbers are `neverShare`, low-confidence, and always marked for review;
- the candidate/evidence/attachment aggregate adopts the most restrictive extracted-field classification.

No production log statement records OCR text, extracted values, image paths, candidate titles, entity names, or document identifiers. User-facing failures are generic and do not echo personal content.

## Offline behavior and network inspection

Android uses `com.google.mlkit:text-recognition`, the statically linked library. It does not use `com.google.android.gms:play-services-mlkit-text-recognition`, Firebase model download, or a hosted inference endpoint. The model is available immediately after app installation and capture/OCR/extraction/confirmation have no network dependency.

The Android manifest also removes transitive `INTERNET` and `ACCESS_NETWORK_STATE` permissions at merge time. The release APK permission dump is therefore expected to contain neither permission, making application network access unavailable at the OS boundary. Debug/profile manifests add internet access for Flutter tooling and must not be used as evidence for the release privacy boundary.

iOS ML Kit is delivered through the app's native dependency build. No model-download API is called by Life Timeline, but iOS has no Android-style manifest permission that blocks the SDK's documented metrics. Airplane-mode success proves offline capability; it does not prove absence of later diagnostics uploads.

Package download during development/build is not a runtime content flow. OS camera/photo providers and app-store update mechanisms remain outside the feature boundary.

Authoritative vendor disclosures reviewed for this conclusion:

- [ML Kit terms](https://developers.google.com/ml-kit/terms)
- [ML Kit Android data disclosure](https://developers.google.com/ml-kit/android-data-disclosure)
- [ML Kit Apple data disclosure](https://developers.google.com/ml-kit/ios-data-disclosure)
- [ML Kit on-device overview](https://developers.google.com/ml-kit)

## Threats and mitigations

| Threat | Mitigation | Residual risk |
| --- | --- | --- |
| Personal text leaves the device | Bundled OCR, no remote client, no content logging | Vendor documentation supports on-device inference but does not make an absolute no-network/no-metrics guarantee. Packet inspection and a product privacy decision remain required. |
| Technical SDK metrics conflict with the no-analytics promise | Android release removes network permissions; application code has no metrics client | iOS has no equivalent OS network gate. The current engine cannot be approved for an unqualified no-analytics claim without an explicit policy change or replacement. |
| OCR becomes accepted fact | Candidate lifecycle, qualitative uncertainty, editable fields, explicit confirmation | Users can still confirm an incorrect value. |
| Original image corruption | Read source only; create separate working and managed copies | Provider-backed files can disappear before copying. |
| SQLite bloat/sensitive blobs | No binary image columns; relative references only | Structured sensitive values still exist in the local database. |
| Half-created timeline records | Candidate save and confirmation use Drift transactions with foreign keys | File copy and SQLite are not one filesystem transaction; compensating deletion is used. |
| Duplicate entity creation | Exact confirmed serial match first, then explainable normalized name/type scoring; no silent merge | V1 cannot resolve fuzzy aliases, transliteration, or changed serial formatting reliably. |
| Abuse/reset of complimentary actions | Local persisted counter, increment after committed candidate | No-account local entitlement is not tamper-proof and backup restore can affect local state. |

## Platform and accuracy limitations

- OCR is Android/iOS only; manual entry remains available elsewhere.
- V1 is Latin-script only.
- iOS minimum deployment is 15.5.
- Receipt formats, currencies, locale-specific dates, handwritten text, curved labels, glare, blur, and dense tables can reduce accuracy.
- Ambiguous numeric dates are not converted to an exact timeline date. Only unambiguous `YYYY-MM-DD`-style values become exact dates automatically.
- Scan currently uses the camera capture boundary; edge detection, perspective correction, multi-page scanning, PDFs, and HEIC-specific tuning are deferred.
- Identity extraction is intentionally narrow and must not be treated as identity verification.

## Measured Android artifact impact

The 2026-08-14 verified split release outputs are 30.9 MB
(`armeabi-v7a`, 32,401,925 bytes), 36.9 MB (`arm64-v8a`, 38,646,459
bytes), and 38.9 MB (`x86_64`, 40,769,932 bytes). These are complete APK
sizes, not a controlled with/without-OCR delta; native OCR assets and other
transitive components both contribute. Performance risk is primarily first-use
native initialization plus image decode/OCR CPU and memory on older devices.

The build still reports the repository's pre-existing future Flutter
built-in-Kotlin migration warning for the app, `file_picker`,
`flutter_timezone`, `package_info_plus`, and `share_plus`. The pinned OCR plugin
does not apply Kotlin and adds no new KGP warning. Resolving the remaining
warning is a separate foundation migration/package-upgrade task.

## Future local-only options

Subject to a new dependency/privacy review: platform document scanners, offline multi-script OCR bundles, small bundled classification models, stale-temp cleanup, encrypted-at-rest managed attachments, richer structured entity attributes, and local semantic matching. Any downloaded model, network-capable SDK, or generative model requires a new ADR/security review before adoption.

## Review outcome

This review's blocking ML Kit conflict was resolved by removing the SDK rather
than weakening the privacy promise. Private OCR remains a product requirement,
and no cloud OCR fallback is approved. Public V1 is not feature-complete until
a benchmarked privacy-approved local OCR engine is restored or product scope
explicitly approves manual document capture without OCR. Physical-device
network inspection and iOS build verification on Xcode remain required for the
separate Google Drive encrypted-backup path.
