# Local OCR benchmark harness

This directory is research tooling only. It is not imported by the Flutter
application and does not add an OCR runtime, model, or native dependency to a
production build.

All fixtures are synthetic and carry a visible `SYNTHETIC TEST FIXTURE` mark.
`corpus/manifest.json` is the source of truth for expected text, important
fields, and transformations. Generate the images with:

```powershell
python generate_corpus.py
```

Research dependencies are pinned in `research-requirements.txt` and belong in
the ignored `.research_deps/` directory. They are intentionally isolated from
Flutter's dependency graph.

The Paddle host proxy has a deliberate two-step setup. The first command is the
only model-network step; it downloads immutable official revisions and verifies
every file against `paddle-model-assets.lock.json`:

```powershell
python prepare_paddle_models.py
python benchmark_paddle.py
```

`benchmark_paddle.py` then requires local models, enables the Hub/offline flags,
disables ONNX telemetry by environment and API, and denies Python socket
connections. It does not make the stock research runtime production-safe.

Run a Tesseract CLI benchmark with:

```powershell
python benchmark.py --engine tesseract --executable <path-to-tesseract>
```

The runner tests each source image as-is and after the project-owned bounded
preprocessing pipeline. It writes machine-readable results under `results/`.
The engine process receives only local image paths and no URL. Platform-level
firewall/packet-capture verification is still required before production
approval.

PaddleOCR/ONNX measurements must be supplied by an audited isolated adapter
that writes the same JSONL protocol documented in `engine_protocol.md`. The
stock ONNX Runtime Android AAR is deliberately not accepted by this harness as
a production-equivalent runtime because it is not a project-reproducible,
reduced-operator build with telemetry omitted at compile time.

To include downstream classification/extraction results without copying domain
logic into Python, run from `apps/mobile`:

```powershell
dart run tool/evaluate_ocr_extraction.dart `
  ../../tooling/ocr_benchmark/results/<result>.json `
  ../../tooling/ocr_benchmark/corpus/resolved-manifest.json
```
