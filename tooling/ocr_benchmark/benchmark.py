"""Run reproducible OCR measurements without importing production code."""

from __future__ import annotations

import argparse
import json
import os
import re
import statistics
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image

from preprocess import prepare


ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".research_deps"))
try:
    import psutil
except ImportError:  # Memory remains explicitly unavailable without psutil.
    psutil = None
MANIFEST = ROOT / "corpus" / "resolved-manifest.json"
IMAGES = ROOT / "corpus" / "images"
RESULTS = ROOT / "results"


def normalized(text: str) -> str:
    return " ".join(re.sub(r"[^A-Z0-9./:-]+", " ", text.upper()).split())


def distance(left: list[str], right: list[str]) -> int:
    row = list(range(len(right) + 1))
    for i, a in enumerate(left, 1):
        next_row = [i]
        for j, b in enumerate(right, 1):
            next_row.append(min(next_row[-1] + 1, row[j] + 1, row[j - 1] + (a != b)))
        row = next_row
    return row[-1]


def error_rate(expected: str, actual: str, words: bool) -> float:
    expected_items = normalized(expected).split() if words else list(normalized(expected))
    actual_items = normalized(actual).split() if words else list(normalized(actual))
    return distance(expected_items, actual_items) / max(1, len(expected_items))


@dataclass
class Recognition:
    text: str
    lines: list[dict]
    latency_ms: float
    peak_rss_mb: float | None
    cpu_ms: float | None


def tesseract(executable: str, image_path: Path, psm: int) -> Recognition:
    started = time.perf_counter()
    process = subprocess.Popen(
        [executable, str(image_path), "stdout", "--dpi", "300", "--psm", str(psm), "tsv"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
        env={**os.environ, "OMP_THREAD_LIMIT": "2"},
    )
    observed_peak = 0
    observed_cpu = 0.0
    watched = psutil.Process(process.pid) if psutil is not None else None
    while process.poll() is None:
        if watched is not None:
            try:
                observed_peak = max(observed_peak, watched.memory_info().rss)
                cpu = watched.cpu_times()
                observed_cpu = max(observed_cpu, cpu.user + cpu.system)
            except psutil.Error:
                pass
        time.sleep(0.002)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        raise RuntimeError(f"Tesseract failed for {image_path}: {stderr.strip()}")
    latency_ms = (time.perf_counter() - started) * 1000
    groups: dict[tuple[str, str, str, str], list[tuple[str, float]]] = {}
    rows = stdout.splitlines()
    if rows:
        headers = rows[0].split("\t")
        for raw in rows[1:]:
            values = raw.split("\t")
            if len(values) != len(headers):
                continue
            row = dict(zip(headers, values))
            word = row.get("text", "").strip()
            if not word:
                continue
            key = (row["page_num"], row["block_num"], row["par_num"], row["line_num"])
            groups.setdefault(key, []).append((word, float(row.get("conf", "-1"))))
    lines = []
    for words_in_line in groups.values():
        valid = [confidence for _, confidence in words_in_line if confidence >= 0]
        lines.append({"text": " ".join(word for word, _ in words_in_line), "confidence": statistics.fmean(valid) / 100 if valid else None})
    return Recognition(
        "\n".join(line["text"] for line in lines),
        lines,
        latency_ms,
        observed_peak / 1024 / 1024 if observed_peak else None,
        observed_cpu * 1000 if observed_cpu else None,
    )


def important_field_score(fields: dict[str, str], actual: str) -> tuple[int, int]:
    haystack = normalized(actual)
    hits = sum(normalized(value) in haystack for value in fields.values())
    return hits, len(fields)


def percentile(values: list[float], fraction: float) -> float | None:
    values = sorted(value for value in values if value is not None)
    if not values:
        return None
    position = (len(values) - 1) * fraction
    lower = int(position)
    upper = min(lower + 1, len(values) - 1)
    weight = position - lower
    return values[lower] * (1 - weight) + values[upper] * weight


def summarize(records: list[dict]) -> dict:
    summaries = {}
    for variant in ("raw", "preprocessed"):
        selected = [record for record in records if record["variant"] == variant]
        warm_latency = [value for record in selected for value in record["warm_latency_ms"]]
        warm_end_to_end = [
            value + record["preprocessing_ms"]
            for record in selected
            for value in record["warm_latency_ms"]
        ]
        warm_rss = [value for record in selected for value in record["warm_peak_rss_mb"] if value is not None]
        warm_cpu = [value for record in selected for value in record["warm_cpu_ms"] if value is not None]
        fields_correct = sum(record["important_fields_correct"] for record in selected)
        fields_total = sum(record["important_fields_total"] for record in selected)
        summaries[variant] = {
            "mean_cer": statistics.fmean(record["cer"] for record in selected),
            "mean_wer": statistics.fmean(record["wer"] for record in selected),
            "important_fields_correct": fields_correct,
            "important_fields_total": fields_total,
            "important_field_accuracy": fields_correct / fields_total,
            "cold_latency_p50_ms": percentile([record["cold_latency_ms"] for record in selected], 0.50),
            "cold_latency_p95_ms": percentile([record["cold_latency_ms"] for record in selected], 0.95),
            "warm_latency_p50_ms": percentile(warm_latency, 0.50),
            "warm_latency_p95_ms": percentile(warm_latency, 0.95),
            "warm_end_to_end_p50_ms": percentile(warm_end_to_end, 0.50),
            "warm_end_to_end_p95_ms": percentile(warm_end_to_end, 0.95),
            "warm_peak_rss_p50_mb": percentile(warm_rss, 0.50),
            "warm_peak_rss_p95_mb": percentile(warm_rss, 0.95),
            "warm_cpu_p50_ms": percentile(warm_cpu, 0.50),
            "warm_cpu_p95_ms": percentile(warm_cpu, 0.95),
        }
    return summaries


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--engine", choices=["tesseract"], required=True)
    parser.add_argument("--executable", required=True)
    parser.add_argument("--warm-runs", type=int, default=3)
    parser.add_argument("--psm", type=int, default=1)
    args = parser.parse_args()
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    RESULTS.mkdir(exist_ok=True)
    records = []
    with tempfile.TemporaryDirectory(prefix="life_timeline_ocr_") as temp:
        for fixture in manifest["fixtures"]:
            source = IMAGES / f"{fixture['id']}.png"
            for variant in ("raw", "preprocessed"):
                selected = source
                preprocessing_ms = 0.0
                if variant == "preprocessed":
                    selected = Path(temp) / f"{fixture['id']}.png"
                    preprocessing_started = time.perf_counter()
                    prepare(Image.open(source)).save(selected)
                    preprocessing_ms = (
                        time.perf_counter() - preprocessing_started
                    ) * 1000
                runs = [
                    tesseract(args.executable, selected, args.psm)
                    for _ in range(args.warm_runs + 1)
                ]
                result = runs[-1]
                expected = "\n".join(fixture["lines"])
                hits, field_count = important_field_score(fixture["important_fields"], result.text)
                records.append({
                    "fixture_id": fixture["id"],
                    "kind": fixture["kind"],
                    "variant": variant,
                    "cer": error_rate(expected, result.text, words=False),
                    "wer": error_rate(expected, result.text, words=True),
                    "important_fields_correct": hits,
                    "important_fields_total": field_count,
                    "preprocessing_ms": preprocessing_ms,
                    "cold_latency_ms": runs[0].latency_ms,
                    "warm_latency_ms": [run.latency_ms for run in runs[1:]],
                    "cold_peak_rss_mb": runs[0].peak_rss_mb,
                    "warm_peak_rss_mb": [run.peak_rss_mb for run in runs[1:]],
                    "cold_cpu_ms": runs[0].cpu_ms,
                    "warm_cpu_ms": [run.cpu_ms for run in runs[1:]],
                    "lines": result.lines,
                    "recognized_text": result.text,
                })
    executable_version = subprocess.run([args.executable, "--version"], capture_output=True, text=True, encoding="utf-8", errors="replace").stdout.splitlines()[0]
    output = {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "engine": args.engine,
        "engine_version": executable_version,
        "engine_configuration": {"page_segmentation_mode": args.psm},
        "host": {"platform": os.name, "cpu_count": os.cpu_count()},
        "measurement_limitations": ["Host CLI latency, RSS, and CPU are not Android device measurements.", "Application package delta requires a native release-build spike."],
        "summary": summarize(records),
        "records": records,
    }
    target = RESULTS / f"{args.engine}-psm{args.psm}-host.json"
    target.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    print(target)


if __name__ == "__main__":
    main()
