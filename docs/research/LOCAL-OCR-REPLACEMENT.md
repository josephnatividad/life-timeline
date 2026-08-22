# Local OCR Replacement Benchmark

Status: benchmark complete; production integration not approved

Decision: **MORE EVIDENCE REQUIRED**

Benchmark date: 2026-08-23

Authority: `AGENTS.md`, the PDD, accepted ADRs, and security reviews remain
authoritative. This research does not change the current unavailable OCR
capability, the manual document-capture path, or the release gate for Private
Intelligence.

## Why this benchmark exists

Google ML Kit was removed from the network-enabled production dependency graph
because its documented SDK utilization/performance metrics conflict with Life
Timeline's no-analytics privacy posture. Existing OCR-derived records and
provenance remain valid. Private local OCR remains a product requirement, and no
cloud OCR replacement is permitted. Until a candidate passes this benchmark's
remaining privacy and device gates, Scan Document continues to create private
Evidence with manual details.

## Executive result

PP-OCRv6-small is the clear host-accuracy leader and is therefore reported
first. On the 19-fixture synthetic corpus it reached 93.75% exact important-field
recognition versus 83.33% for Tesseract on raw inputs. Excluding the deliberately
90-degree-rotated fixture, PP-OCRv6-small recognized every important field and
had 0.15% mean CER. It also recognized the severe low-light product label that
Tesseract missed.

That accuracy result is not sufficient for production selection:

- both Android engines failed the 90-degree-rotated ticket without an explicit
  orientation stage;
- PP-OCRv6-small's host proxy was slower, retained up to about 1.64 GB in the
  Python research process, and requires roughly 31.6 MB of model/config assets
  before ONNX Runtime, OpenCV, and bridge code;
- PaddleOCR's Android sample pins an old full ONNX Runtime AAR, targets API 26,
  and does not meet this project's reproducible no-telemetry build requirement;
- Tesseract's tested Windows binary linked libcurl, while the project requires a
  source build with curl and archive support disabled;
- no Android device is currently attached, and no macOS/Xcode/iOS environment
  is available, so release APK/IPA size, mobile latency, mobile memory, packet
  capture, and Apple Vision accuracy remain unmeasured.

No production OCR dependency, model, plugin, native bridge, permission, or
feature behavior was added. Existing confirmed OCR-created records, provenance,
Memory Inbox data, Evidence, backup/restore, and manual capture are untouched.

## Product and architecture boundaries

Every candidate must satisfy all of these conditions:

- recognition and image preprocessing execute on the user's device;
- source images, recognized text, inferred fields, and confidence values are
  never uploaded, logged, or added to analytics;
- models and dictionaries are bundled and checksum-pinned; runtime acquisition
  is prohibited;
- the candidate implements the existing `TextRecognitionEngine` boundary and
  returns project-owned `OcrDocument`/`OcrLine` values;
- engine SDK, ONNX, Vision, OpenCV, and native platform types stay inside the
  infrastructure/platform adapter;
- the existing deterministic classifier, extraction pipeline, provenance,
  candidate review, and Memory Inbox architecture remain authoritative;
- OCR is a proposal mechanism only. It must never silently confirm memories or
  invent exact temporal values;
- lack of OCR must continue to degrade to private document Evidence plus manual
  details, with no cloud fallback.

The benchmark adapter at
`apps/mobile/tool/evaluate_ocr_extraction.dart` converts provider-neutral lines
to `OcrDocument` and runs the unmodified production classifier/extractors. Drift,
repositories, providers, and feature code never receive benchmark-engine types.

## Versioned non-personal fixture corpus

The corpus contains 19 deterministic images generated from fictional text. Every
image visibly begins with `SYNTHETIC TEST FIXTURE`; identity-, travel-, receipt-,
warranty-, invoice-, and certificate-like examples are explicitly invalid.

| Coverage requirement | Fixture IDs |
| --- | --- |
| Receipts and dense/small text | `receipt_clean`, `receipt_dense_small` |
| Warranty | `warranty_card` |
| Invoice | `invoice` |
| Product/model and serial labels | `product_label`, `serial_plate_small` |
| Ticket and boarding pass | `travel_ticket`, `boarding_pass` |
| Certificate and official-style document | `certificate_official`, `official_notice` |
| Screenshot and mixed font sizes | `app_screenshot`, `mixed_font_sizes` |
| Low contrast and low light | `receipt_low_contrast`, `product_low_light` |
| 90-degree rotation | `ticket_rotated_90` |
| Skew and perspective | `invoice_skew`, `warranty_perspective` |
| Blur and very small blurred text | `certificate_blur`, `small_text_blur` |

Canonical text and expected important fields are in
`tooling/ocr_benchmark/corpus/manifest.json`. The resolved manifest, PNGs, and
SHA-256 inventory are versioned beside it. The generator uses a fixed seed and
Arial or DejaVu Sans; no personal, production, backup, or user-provided input was
used.

## Candidates and exact benchmark configuration

### Android accuracy leader: PP-OCRv6-small + ONNX Runtime

- PaddleOCR `3.7.0`, PaddleX `3.7.2`.
- PP-OCRv6-small detector revision
  `28fe5895c24fd108c19eb3e8479f4ab385fbfc62`.
- PP-OCRv6-small recognizer revision
  `b8f84f0b80c529de40b4fbb3544b84fa7233a513`.
- ONNX Runtime `1.21.1` host wheel, matching the version in PaddleOCR's official
  Android sample; this is a research proxy, not an approved release runtime.
- Document orientation, document unwarping, and text-line orientation modules
  were disabled so the benchmark did not silently acquire extra models.
- Models were loaded only from pinned local directories. `HF_HUB_OFFLINE=1`,
  `TRANSFORMERS_OFFLINE=1`, and `ORT_DISABLE_TELEMETRY=1` were set; the ONNX
  telemetry-disable API was also called; Python socket connections were blocked.
- The two ONNX files total 31,039,890 bytes. Including their downloaded pinned
  configs, the host model/config set is about 31.6 MB. Exact checksums are in
  `tooling/ocr_benchmark/paddle-model-assets.lock.json`.

The official Android sample also lists PP-OCRv6-tiny. Its official detector and
recognizer repositories are about 2.03 MB and 4.65 MB respectively, but it was
not substituted after the small model won the accuracy-oriented candidate
choice. Tiny remains a later size/performance comparison, not an approved
engine.

### Android lower-complexity candidate: Tesseract 5

- Tesseract `5.5.3.20260724` with Leptonica `1.87.0`.
- Official Windows release size: 26,573,224 bytes.
- Release SHA-256, verified against GitHub release metadata:
  `bee9e3434bd94fd65387d9be28cd467a41f61b1275383b55b0f59a1331270ae4`.
- English trained data: 4,113,088 bytes; OSD data: 10,562,727 bytes.
- Page segmentation mode 6 was selected after mode 1 doubled latency and did not
  recover the 90-degree rotation. Both configuration results are retained.
- Every CLI invocation loaded a fresh process; the reported "warm" values mean
  warm OS file caches, not a persistent Android engine instance.

The Windows distribution is an accuracy proxy only. Production evaluation must
build Tesseract and Leptonica from pinned source with legacy/training/graphics,
curl, archive, and unused image-format support removed as appropriate.

### iOS candidate: Apple Vision

The intended adapter is `VNRecognizeTextRequest`/`RecognizeTextRequest`, with
newer structured document recognition gated by OS availability. The project
currently targets iOS 15.5, so a V1 adapter cannot assume the newest Vision API.
Apple states that Vision APIs execute on-device, but there was no available
macOS/Xcode/iPhone environment in this benchmark. Apple Vision therefore has no
fabricated CER, WER, latency, memory, or size score.

## Recognition results

All accuracy values include the deliberately difficult 90-degree and low-light
fixtures unless a row says otherwise. Lower CER/WER is better.

| Engine/input | Mean CER | Mean WER | Exact important fields |
| --- | ---: | ---: | ---: |
| PP-OCRv6-small raw | 4.11% | 7.54% | 45/48 (93.75%) |
| PP-OCRv6-small preprocessed | 4.04% | 8.63% | 45/48 (93.75%) |
| Tesseract PSM 6 raw | 9.28% | 16.35% | 40/48 (83.33%) |
| Tesseract PSM 6 preprocessed | 8.65% | 15.30% | 41/48 (85.42%) |

The aggregate is dominated by explicit stress failures:

| Engine/input | Excluded stress cases | Mean CER | Mean WER | Exact fields |
| --- | --- | ---: | ---: | ---: |
| PP-OCRv6-small raw | 90-degree rotation | 0.15% | 2.40% | 45/45 |
| PP-OCRv6-small preprocessed | 90-degree rotation | 0.22% | 3.55% | 45/45 |
| Tesseract raw | rotation + severe low light | 0.26% | 1.85% | 40/42 |
| Tesseract preprocessed | rotation + severe low light | 0.18% | 0.93% | 41/42 |

Failure interpretation:

- Both providers returned unusable text for the 90-degree-rotated ticket and
  recovered 0/3 important fields. An explicit bundled orientation stage or a
  deterministic user rotation control is required; EXIF transpose alone is not
  enough for rotated pixel data.
- Paddle recognized all three fields in the severe low-light product label.
  Tesseract recovered none, even after the common preprocessing pass.
- Tesseract lost both important fields on the raw small blurred serial plate and
  recovered one after preprocessing. Paddle recovered both without the common
  preprocessing pass.

### Raw versus common preprocessing

The bounded preprocessing pass performs EXIF transpose, grayscale conversion,
up-to-2x resize, autocontrast, modest contrast enhancement, and unsharp masking.

- Tesseract PSM 6 gained one important field and modestly improved CER/WER, but
  added roughly 35 ms to host p50 end-to-end latency and did not solve rotation
  or severe low light.
- Paddle's field accuracy was unchanged. Outside the rotation failure, raw input
  had better CER/WER, while preprocessing increased host p50 end-to-end latency
  from about 617 ms to 785 ms. Blanket preprocessing is therefore not justified
  for PP-OCRv6-small; any future transforms should be evidence-driven and
  conditional.
- Tesseract PSM 1 was rejected as the default host configuration: it was about
  378 ms p50 versus about 214 ms for PSM 6, used roughly twice the process RSS,
  and produced unstable preprocessed results without fixing rotation.

## Existing classifier and extraction compatibility

Provider lines and confidence values passed through the existing project-owned
models without adding engine types to domain code.

| Engine/input set | Classification | Supported extracted fields |
| --- | ---: | ---: |
| PP-OCRv6-small, raw + preprocessed | 32/38 (84.21%) | 61/72 (84.72%) |
| Tesseract PSM 6, raw + preprocessed | 30/38 (78.95%) | 53/72 (73.61%) |

These are end-to-end pipeline outcomes, not pure OCR accuracy. The benchmark
exposed two existing deterministic-pipeline limitations:

- perfectly recognized warranty fixtures classify as `product` because product,
  model, and serial markers outweigh the warranty markers; expiry is then not
  extracted;
- one low-contrast Paddle receipt joined the recognized date and time without a
  space (`2026-05-1418:42`), so the current date regex did not accept it even
  though the date characters were correct.

Those issues should become separate deterministic classifier/extractor tests if
an OCR engine is later approved. They were not changed during this spike and do
not justify adding a new product feature.

## Host performance, memory, and size evidence

Host figures are not cross-engine mobile benchmarks: Tesseract uses a fresh CLI
process for each call, while Paddle uses a persistent Python pipeline. They are
useful for risk discovery only. The host was a high-end 24-core Intel Core Ultra
9 275HX Windows 11 machine with 33.8 GB of physical RAM, not a representative
phone.

| Measure | PP-OCRv6-small raw | Tesseract PSM 6 raw |
| --- | ---: | ---: |
| Model init + first inference | 1,030 ms | Not comparable (per-call CLI load) |
| Warm host latency p50/p95 | 617/760 ms | 214/264 ms |
| Host process RSS p50/p95 | 1,105/1,637 MB | 36.9/39.0 MB per process |
| Host CPU p50/p95 | 10,453/12,944 ms | 203/281 ms per process |

Paddle's research process grew from about 220 MB during initialization to a
plateau around 1.6 GB across repeated large-image runs. Python/PaddleX/OpenCV
overhead and allocator retention make that number non-transferable to Android,
but the trend is a blocking measurement risk: a native Android sample must prove
bounded memory and repeated-run stability on a midrange device.

Known package-size inputs:

- PP-OCRv6-small host model/config assets: about 31.6 MB; the Android sample's
  required detector/recognizer assets must be measured in the release build.
- Stock `onnxruntime-android:1.21.1` AAR: 27,944,395 bytes compressed; its arm64
  native libraries total 18,009,128 bytes before APK compression.
- OpenCV, bridge, resources, and release packaging delta: not yet measured.
- Tesseract English data: 4.1 MB; optional OSD data: 10.6 MB; stripped arm64
  native libraries and APK delta: not yet measured.
- Apple Vision models/frameworks are supplied by the OS; actual IPA and startup
  deltas still require an iOS release build.

## Privacy and network audit

### Apple Vision

Apple documents Vision as on-device. The future adapter must accept only local
image references/bytes, contain no URL transport, avoid content logging, and be
tested in airplane mode with packet capture. OS framework use does not authorize
any application networking or remote model acquisition.

### Tesseract

Tesseract has no required telemetry service, but network capability is a build
choice. Current upstream CMake has optional curl support and Tesseract can use it
to process image URLs. The tested official Windows binary reports libcurl. A
candidate Android build therefore fails the privacy gate unless it is reproduced
with `DISABLE_CURL=ON` and `DISABLE_ARCHIVE=ON` (plus other unused capabilities),
contains no network library or URL-input API, bundles all trained data, and passes
static and dynamic network audits.

### PaddleOCR and ONNX Runtime

The research Python distribution is intentionally not a production dependency;
it includes network-capable Hub, request, and model-source packages. The official
Android sample is narrower, but its runtime still requires a deliberate audit.

The exact `onnxruntime-android:1.21.1` AAR was downloaded and inspected:

- SHA-256:
  `30e594a4b9246fe3ca25768570e90f71e6d33ceb7b7dd72f92dcd7c267611d3f`;
- its manifest declares minimum API 24 and no Internet/network-state permission;
- the archive contains no separate 1DS library or telemetry endpoint string;
- native/JNI binaries still expose telemetry enable/disable APIs.

That artifact-level result does not approve the stock AAR. Current ONNX Runtime
privacy documentation says official non-Windows builds can include 1DS telemetry
and that official telemetry is on by default; the Java build adds Internet and
network-state permissions when telemetry is enabled. The Paddle sample's 1.21.1
pin is also substantially behind current ONNX Runtime releases. A production
candidate must use a project-owned, pinned, reduced-operator Android build with
telemetry omitted at compile time, then verify the resulting AAR has no telemetry
transport, identifiers, permissions, network namespaces, or unexpected Maven
dependencies. Runtime disabling alone is insufficient for approval.

Models and dictionaries must be copied into app assets at build time and verified
against `paddle-model-assets.lock.json`; no Hub/model-source package may ship.

## License and maintenance review

| Candidate | License/notice position | Maintenance and integration risk |
| --- | --- | --- |
| Apple Vision | Apple platform SDK terms; no redistributed third-party model | Lowest bridge surface, but OS/API availability matrix and iOS-only tests remain |
| Tesseract 5.5.3 | Apache-2.0; `tessdata_fast` Apache-2.0; Leptonica notice/license must be included | Mature engine, but modern project-owned Android/NDK bridge, ABI builds, crash handling, and model updates are owned by this project |
| PP-OCRv6-small | PaddleOCR/models Apache-2.0; ONNX Runtime MIT; OpenCV 4.5+ Apache-2.0 | New model family and Android demo; full runtime/OpenCV/model chain, reduced-op build, checksums, and notices increase update burden |

The Paddle Android demo requires JDK 17, Kotlin 2.1, minimum API 26, ONNX Runtime
1.21.1, and OpenCV 4.5.3. Life Timeline currently inherits Flutter 3.44.9's API
24 minimum and is deliberately managing Kotlin/AGP compatibility. Copying the
sample would drop Android 7/7.1 support and increase build-system risk; that is a
human product/platform decision, not an implementation default.

## Fixed weighted scorecard

Scores use 0-5 and the required weights. They are provisional because mobile
performance, release size, and packet capture are absent. Privacy gates remain
binary: a higher weighted score cannot approve a network-capable build.

| Candidate | Accuracy 35 | Privacy 25 | Performance 15 | Size 10 | Maintenance 10 | Integration 5 | Weighted /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tesseract 5 custom no-network build | 3.4 | 4.0 | 3.5 | 3.5 | 3.0 | 3.5 | 70.8 provisional |
| PP-OCRv6-small + custom no-telemetry ORT | 4.6 | 2.5 | 2.0 | 1.5 | 2.5 | 2.5 | 61.2 provisional |
| Apple Vision | Not measured | 5.0 provisional | Not measured | 5.0 provisional | 4.5 | 4.0 | Not scoreable |

Tesseract's provisional total reflects smaller/lower-complexity expectations,
not superior recognition. Paddle is the measured accuracy leader. Neither row is
eligible for selection until its assumed custom build exists and passes mobile
privacy/performance tests. Apple Vision cannot be used to complete a platform
combination until its accuracy and performance cells are measured.

## Recommendation and remaining decision evidence

**Recommendation: MORE EVIDENCE REQUIRED.**

Do not implement a production OCR provider yet. The minimum next benchmark,
still on non-personal fixtures and outside feature code, is:

1. Build two arm64 Android spike AARs: Tesseract 5.5.3 with optional network and
   archive support omitted, and PP-OCRv6-small with a current compatible
   reduced-operator ONNX Runtime built without telemetry and models bundled.
2. Keep Life Timeline's API 24 baseline for the Tesseract spike. For Paddle,
   first prove whether the bridge can support API 24; raising the product minimum
   to API 26 requires explicit human approval.
3. Run the same corpus on an attached current midrange arm64 device and an older
   supported device. Record cold/warm p50/p95, process RSS/peak, CPU, thermal
   behavior, repeated-run memory stability, crash behavior, and release AAB/APK
   ABI deltas.
4. Add an explicit local orientation strategy and rerun the rotated fixture. Do
   not add a remotely acquired orientation model.
5. Run airplane-mode tests and packet capture before/during/after initialization
   and recognition. Verify no DNS, socket, telemetry identifier, content log, or
   runtime asset acquisition.
6. Run Apple Vision on the identical corpus on the minimum supported iOS version
   and a current device; record the same accuracy, extraction, latency, memory,
   size, and offline evidence.
7. Recalculate this fixed scorecard and choose one of the platform combinations
   only after every privacy gate passes.

If public V1 reaches its scope gate before this evidence exists, product must
explicitly decide whether to ship manual document Evidence capture without OCR.
Private Intelligence must not be silently removed from the roadmap and cloud OCR
remains prohibited.

## Reproducible artifacts

- Harness and instructions: `tooling/ocr_benchmark/README.md`
- Host environment: `tooling/ocr_benchmark/results/host-environment.json`
- Corpus source: `tooling/ocr_benchmark/corpus/manifest.json`
- Fixture checksums: `tooling/ocr_benchmark/corpus/checksums.json`
- Paddle model lock: `tooling/ocr_benchmark/paddle-model-assets.lock.json`
- Tesseract PSM 6 results:
  `tooling/ocr_benchmark/results/tesseract-psm6-host.json`
- Tesseract PSM 1 comparison:
  `tooling/ocr_benchmark/results/tesseract-psm1-host.json`
- PP-OCRv6-small results:
  `tooling/ocr_benchmark/results/paddleocr-v6-small-host.json`
- Existing-pipeline adapter:
  `apps/mobile/tool/evaluate_ocr_extraction.dart`

## Primary references

- [ML Kit terms and privacy](https://developers.google.com/ml-kit/terms)
- [ML Kit Android data disclosure](https://developers.google.com/ml-kit/android-data-disclosure)
- [Apple Vision on-device APIs](https://developer.apple.com/videos/play/wwdc2025/272/)
- [Apple text recognition](https://developer.apple.com/documentation/vision/recognizing-text-in-images)
- [PaddleOCR PP-OCRv6 Android deployment](https://www.paddleocr.ai/latest/en/version3.x/inference_deployment/cross_platform/android_deployment.html)
- [PP-OCRv6-small detector](https://huggingface.co/PaddlePaddle/PP-OCRv6_small_det_onnx)
- [PP-OCRv6-small recognizer](https://huggingface.co/PaddlePaddle/PP-OCRv6_small_rec_onnx)
- [ONNX Runtime privacy](https://github.com/microsoft/onnxruntime/blob/main/docs/Privacy.md)
- [ONNX Runtime Java Android telemetry permissions](https://github.com/microsoft/onnxruntime/blob/main/java/README.md)
- [Tesseract 5.5.3 release](https://github.com/tesseract-ocr/tesseract/releases/tag/5.5.3)
- [Tesseract optional curl/archive build flags](https://github.com/tesseract-ocr/tesseract/blob/main/CMakeLists.txt)
- [Tesseract fast models and license](https://github.com/tesseract-ocr/tessdata_fast)
