"""Host proxy benchmark for pinned PP-OCRv6-small ONNX models.

The Python distribution and stock ONNX Runtime wheel are research tooling, not
production dependencies. Models are loaded only from immutable local snapshots.
"""

from __future__ import annotations

import json
import os
import socket
import statistics
import sys
import tempfile
import threading
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable, TypeVar

from PIL import Image

from benchmark import error_rate, important_field_score, percentile
from preprocess import prepare


ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".research_deps"))
MODELS = ROOT / ".runtime" / "models" / "pp-ocrv6-small"
IMAGES = ROOT / "corpus" / "images"
MANIFEST = ROOT / "corpus" / "resolved-manifest.json"
RESULTS = ROOT / "results"

os.environ.update(
    {
        "HF_HUB_OFFLINE": "1",
        "TRANSFORMERS_OFFLINE": "1",
        "PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK": "True",
        "PADDLE_PDX_CACHE_HOME": str(ROOT / ".runtime" / "paddlex"),
        "ORT_DISABLE_TELEMETRY": "1",
        "OMP_NUM_THREADS": "2",
    }
)

import onnxruntime as ort
import psutil
from paddleocr import PaddleOCR


T = TypeVar("T")


def deny_python_network() -> None:
    def denied(*_args: object, **_kwargs: object) -> None:
        raise RuntimeError("Network access is forbidden during the local OCR benchmark")

    socket.create_connection = denied  # type: ignore[assignment]
    socket.socket.connect = denied  # type: ignore[assignment]
    socket.socket.connect_ex = denied  # type: ignore[assignment]


def measure(call: Callable[[], T]) -> tuple[T, float, float, float]:
    process = psutil.Process()
    stop = threading.Event()
    peak = process.memory_info().rss

    def sample() -> None:
        nonlocal peak
        while not stop.wait(0.002):
            peak = max(peak, process.memory_info().rss)

    sampler = threading.Thread(target=sample, daemon=True)
    cpu_before = process.cpu_times()
    started = time.perf_counter()
    sampler.start()
    try:
        value = call()
    finally:
        elapsed_ms = (time.perf_counter() - started) * 1000
        stop.set()
        sampler.join()
    cpu_after = process.cpu_times()
    cpu_ms = (
        cpu_after.user
        + cpu_after.system
        - cpu_before.user
        - cpu_before.system
    ) * 1000
    return value, elapsed_ms, peak / 1024 / 1024, cpu_ms


def recognize(ocr: PaddleOCR, path: Path) -> list[dict]:
    results = list(ocr.predict(str(path)))
    if len(results) != 1:
        raise RuntimeError(f"Expected one OCR result for {path}, got {len(results)}")
    payload = results[0].json["res"]
    texts = payload["rec_texts"]
    confidences = payload["rec_scores"]
    polygons = payload["rec_polys"]
    return [
        {
            "text": text,
            "confidence": float(confidence),
            "polygon": polygon,
        }
        for text, confidence, polygon in zip(texts, confidences, polygons)
    ]


def summarize(records: list[dict]) -> dict:
    output = {}
    for variant in ("raw", "preprocessed"):
        selected = [record for record in records if record["variant"] == variant]
        inference = [value for record in selected for value in record["inference_ms"]]
        end_to_end = [
            value + record["preprocessing_ms"]
            for record in selected
            for value in record["inference_ms"]
        ]
        rss = [value for record in selected for value in record["peak_rss_mb"]]
        cpu = [value for record in selected for value in record["cpu_ms"]]
        fields_correct = sum(record["important_fields_correct"] for record in selected)
        fields_total = sum(record["important_fields_total"] for record in selected)
        output[variant] = {
            "mean_cer": statistics.fmean(record["cer"] for record in selected),
            "mean_wer": statistics.fmean(record["wer"] for record in selected),
            "important_fields_correct": fields_correct,
            "important_fields_total": fields_total,
            "important_field_accuracy": fields_correct / fields_total,
            "warm_inference_p50_ms": percentile(inference[1:], 0.50),
            "warm_inference_p95_ms": percentile(inference[1:], 0.95),
            "warm_end_to_end_p50_ms": percentile(end_to_end[1:], 0.50),
            "warm_end_to_end_p95_ms": percentile(end_to_end[1:], 0.95),
            "host_process_peak_rss_p50_mb": percentile(rss, 0.50),
            "host_process_peak_rss_p95_mb": percentile(rss, 0.95),
            "host_process_cpu_p50_ms": percentile(cpu, 0.50),
            "host_process_cpu_p95_ms": percentile(cpu, 0.95),
        }
    return output


def main() -> None:
    if not (MODELS / "asset-manifest.json").is_file():
        raise RuntimeError("Run prepare_paddle_models.py before this benchmark")
    deny_python_network()
    ort.disable_telemetry_events()
    ocr, init_ms, init_peak_rss_mb, init_cpu_ms = measure(
        lambda: PaddleOCR(
            text_detection_model_name="PP-OCRv6_small_det",
            text_detection_model_dir=str(MODELS / "det"),
            text_recognition_model_name="PP-OCRv6_small_rec",
            text_recognition_model_dir=str(MODELS / "rec"),
            engine="onnxruntime",
            use_doc_orientation_classify=False,
            use_doc_unwarping=False,
            use_textline_orientation=False,
        )
    )
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    records = []
    first_inference_ms = None
    with tempfile.TemporaryDirectory(prefix="life_timeline_paddle_") as temp:
        for fixture in manifest["fixtures"]:
            source = IMAGES / f"{fixture['id']}.png"
            for variant in ("raw", "preprocessed"):
                selected = source
                preprocessing_ms = 0.0
                if variant == "preprocessed":
                    selected = Path(temp) / f"{fixture['id']}.png"
                    started = time.perf_counter()
                    prepare(Image.open(source)).save(selected)
                    preprocessing_ms = (time.perf_counter() - started) * 1000
                runs = [measure(lambda: recognize(ocr, selected)) for _ in range(3)]
                if first_inference_ms is None:
                    first_inference_ms = runs[0][1]
                lines = runs[-1][0]
                actual = "\n".join(line["text"] for line in lines)
                expected = "\n".join(fixture["lines"])
                hits, field_count = important_field_score(
                    fixture["important_fields"], actual
                )
                records.append(
                    {
                        "fixture_id": fixture["id"],
                        "kind": fixture["kind"],
                        "variant": variant,
                        "cer": error_rate(expected, actual, words=False),
                        "wer": error_rate(expected, actual, words=True),
                        "important_fields_correct": hits,
                        "important_fields_total": field_count,
                        "preprocessing_ms": preprocessing_ms,
                        "inference_ms": [run[1] for run in runs],
                        "peak_rss_mb": [run[2] for run in runs],
                        "cpu_ms": [run[3] for run in runs],
                        "lines": lines,
                        "recognized_text": actual,
                    }
                )
    assets = json.loads((MODELS / "asset-manifest.json").read_text(encoding="utf-8"))
    model_bytes = sum(
        asset["bytes"]
        for asset in assets["files"]
        if asset["file"] in {"inference.onnx", "inference.yml"}
    )
    output = {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "engine": "paddleocr",
        "engine_version": "3.7.0",
        "runtime": "onnxruntime 1.21.1 host research proxy",
        "engine_configuration": {
            "detector": "PP-OCRv6_small_det_onnx",
            "recognizer": "PP-OCRv6_small_rec_onnx",
            "orientation_classifier": False,
            "document_unwarping": False,
            "runtime_models_bundled": True,
            "python_network_calls_denied": True,
            "ort_telemetry_disabled_by_environment_and_api": True,
        },
        "model_assets_bytes": model_bytes,
        "cold_start": {
            "model_initialization_ms": init_ms,
            "first_inference_ms": first_inference_ms,
            "end_to_end_ms": init_ms + first_inference_ms,
            "peak_rss_mb": init_peak_rss_mb,
            "cpu_ms": init_cpu_ms,
        },
        "measurement_limitations": [
            "Windows host metrics are not midrange Android metrics.",
            "Python process RSS includes research-only PaddleOCR/PaddleX dependencies.",
            "The stock host ONNX Runtime wheel is not an approved production runtime.",
            "No Android APK/ABI size delta or packet capture was possible without an attached device build.",
        ],
        "summary": summarize(records),
        "records": records,
    }
    RESULTS.mkdir(exist_ok=True)
    target = RESULTS / "paddleocr-v6-small-host.json"
    target.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    print(target)


if __name__ == "__main__":
    main()

