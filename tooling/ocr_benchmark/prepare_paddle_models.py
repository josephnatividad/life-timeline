"""Download immutable official PP-OCRv6 models for this research spike only."""

from __future__ import annotations

import hashlib
import json
import os
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".research_deps"))

from huggingface_hub import snapshot_download


MODELS = {
    "det": (
        "PaddlePaddle/PP-OCRv6_small_det_onnx",
        "28fe5895c24fd108c19eb3e8479f4ab385fbfc62",
    ),
    "rec": (
        "PaddlePaddle/PP-OCRv6_small_rec_onnx",
        "b8f84f0b80c529de40b4fbb3544b84fa7233a513",
    ),
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    cache = ROOT / ".runtime" / "hf"
    output = ROOT / ".runtime" / "models" / "pp-ocrv6-small"
    cache.mkdir(parents=True, exist_ok=True)
    os.environ["HF_HOME"] = str(cache)
    records = []
    for role, (repository, revision) in MODELS.items():
        target = output / role
        snapshot_download(
            repo_id=repository,
            revision=revision,
            local_dir=target,
            allow_patterns=["README.md", "inference.json", "inference.onnx", "inference.yml"],
        )
        for path in sorted(target.iterdir()):
            if path.is_file():
                records.append(
                    {
                        "role": role,
                        "repository": repository,
                        "revision": revision,
                        "file": path.name,
                        "bytes": path.stat().st_size,
                        "sha256": sha256(path),
                    }
                )
    manifest = output / "asset-manifest.json"
    manifest.write_text(json.dumps({"files": records}, indent=2) + "\n", encoding="utf-8")
    lock = json.loads(
        (ROOT / "paddle-model-assets.lock.json").read_text(encoding="utf-8")
    )
    expected = {
        (model["role"], file_name): checksum
        for model in lock["models"]
        for file_name, checksum in model["files"].items()
    }
    role_name = {"det": "detector", "rec": "recognizer"}
    for record in records:
        key = (role_name[record["role"]], record["file"])
        if expected.get(key) != record["sha256"]:
            raise RuntimeError(f"Pinned model checksum mismatch: {key}")
    print(manifest)


if __name__ == "__main__":
    main()
