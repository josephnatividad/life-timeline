# Local OCR Replacement Evaluation

Status: benchmark plan; no replacement selected

Authority: `AGENTS.md`, the PDD, accepted ADRs, and security reviews remain
authoritative.

## Why this evaluation exists

The network-enabled application intentionally excludes Google ML Kit. Google
documents that ML Kit processes OCR inputs and outputs on-device but sends SDK
utilization and performance metrics. Those metrics conflict with the product's
unqualified no-analytics posture once the application has network permission.

Private local OCR remains a product requirement. This bridge does not approve
cloud OCR, remote document processing, or removal of Private Intelligence from
the roadmap. Until a replacement passes this review, Scan Document creates a
private manual Evidence draft and never calls a recognition service.

References:

- [ML Kit Terms and Privacy](https://developers.google.com/ml-kit/terms)
- [ML Kit Android data disclosure](https://developers.google.com/ml-kit/android-data-disclosure)
- [ML Kit Apple data disclosure](https://developers.google.com/ml-kit/ios-data-disclosure)

## Candidate providers

### iOS: Apple Vision

Evaluate `VNRecognizeTextRequest`/`RecognizeTextRequest` through a
project-owned platform adapter. Apple documents that Vision text recognition
processes images on-device. The evaluation must still inspect linked frameworks,
runtime traffic, supported languages, OS-version behavior, confidence values,
and result ordering.

Reference: [Apple Vision text recognition](https://developer.apple.com/documentation/vision/recognizing-text-in-images)

### Android: Tesseract through a project-owned bridge

Evaluate Tesseract 5 and explicitly bundled, license-compatible `traineddata`.
Do not adopt an unaudited Flutter wrapper as the long-term trust boundary. A
project-owned native bridge should expose only the existing
`TextRecognitionEngine` contract and contain no networking API.

Review areas include receipt/document accuracy, image preprocessing, ABI build
maintenance, model size, native crashes, Unicode/language coverage, and the
Apache-2.0 code/model notice obligations.

Reference: [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)

### Android: PaddleOCR with a bundled model and ONNX Runtime

Evaluate a small mobile PaddleOCR detection/recognition model compiled into the
application and executed through ONNX Runtime Mobile. Model downloads at runtime
are prohibited. The review must pin and checksum every model/dictionary asset,
audit its license and notices, restrict runtime operators, and confirm the
runtime has no application telemetry or network path.

This option has greater integration and performance complexity but may better
fit receipts, small text, rotation, and document layouts.

References:

- [PaddleOCR mobile deployment](https://github.com/PaddlePaddle/PaddleOCR/blob/main/deploy/lite/readme.md)
- [PaddleOCR iOS/ONNX sample](https://www.paddleocr.ai/latest/en/version3.x/inference_deployment/cross_platform/ios_deployment.html)
- [ONNX Runtime mobile installation](https://onnxruntime.ai/docs/install/)

## Non-personal benchmark corpus

The fixture corpus must contain synthetic, licensed, or explicitly created test
images only. Never use a user's timeline, real identity document, personal
receipt, booking, address, document number, or production backup.

Create versioned fixture groups for:

- receipts with varied fonts, currencies, totals, and thermal-paper contrast;
- warranty cards with product, purchase, and expiry fields;
- product/model labels with serial-like synthetic identifiers;
- synthetic travel tickets with dates, routes, and booking-like dummy values;
- official-style documents containing invented people and numbers, clearly
  watermarked as fixtures;
- low-light and uneven-light photographs;
- 90-, 180-, and 270-degree rotations and mild perspective distortion;
- controlled blur, motion blur, glare, compression, and partial occlusion;
- small text, dense text, and mixed font weights;
- empty/no-text and adversarial non-document images.

Keep canonical ground-truth text and structured expected fields alongside each
image. Fixtures must contain no real credentials or plausible secrets.

## Measurements

Record results per provider, platform, device class, and fixture group:

| Area | Measurement |
| --- | --- |
| Recognition | Character error rate, word error rate, missing/extra lines |
| Extraction | Correct document classification and exact required-field success |
| Confidence | Calibration and usefulness for review recommendations |
| Latency | Cold and warm p50/p95 end-to-end duration |
| Memory | Peak resident memory and large-image failure behavior |
| Application size | Per-ABI/package change from the no-OCR baseline |
| Offline operation | Airplane-mode success and no runtime model acquisition |
| Privacy | Static dependency audit and packet capture before/during/after OCR |
| Android devices | At least one current midrange 64-bit device and one older supported device |
| Maintenance | Release cadence, native toolchain burden, issue health, ownership |
| Licensing | Runtime, model, dictionary, and attribution compatibility |
| Complexity | Native code, build steps, tests, upgrades, and failure surface |

## Execution and acceptance

1. Freeze a no-OCR baseline build and measure size/startup.
2. Implement each engine only in an isolated spike branch behind the existing
   `TextRecognitionEngine` and `PrivateIntelligenceCapabilities` boundaries.
3. Run identical preprocessing and fixture inputs where technically possible.
4. Run all tests with networking disabled, then repeat with networking enabled
   while capturing traffic.
5. Verify OCR inputs, output, filenames, document metadata, and inferred fields
   never enter logs or telemetry.
6. Compare extraction success using the existing deterministic classifier and
   extractors; do not tune only to the recognition metric.
7. Document unsupported devices/languages and failure behavior.
8. Complete license, security, dependency-maintenance, Android release, and iOS
   build reviews before selection.

No Android engine is selected by this document. Selection requires benchmark
evidence and explicit product/privacy approval.

