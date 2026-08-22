"""Generate a deterministic, non-personal OCR fixture corpus."""

from __future__ import annotations

import json
import hashlib
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent
MANIFEST = ROOT / "corpus" / "manifest.json"
IMAGES = ROOT / "corpus" / "images"
SEED = 20260823


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        Path("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    raise RuntimeError("A deterministic Arial or DejaVu Sans font is required")


def render(lines: list[str], style: str) -> Image.Image:
    widths = {"receipt": 900, "dense": 850, "card": 1200, "label": 1100, "small_label": 780, "ticket": 1300, "certificate": 1500, "screenshot": 900}
    width = widths.get(style, 1200)
    margin = 70
    base_size = 34 if style not in {"dense", "small_label"} else 25
    line_gap = 18 if style != "dense" else 10
    sizes = []
    for index, _ in enumerate(lines):
        if style in {"certificate", "mixed"} and index in {1, 2}:
            sizes.append(base_size + 18 - index * 4)
        elif style == "screenshot" and index == 1:
            sizes.append(base_size + 10)
        else:
            sizes.append(base_size)
    height = margin * 2 + sum(size + line_gap for size in sizes)
    image = Image.new("RGB", (width, max(height, 620)), "#fbfaf6")
    draw = ImageDraw.Draw(image)
    y = margin
    for index, (line, size) in enumerate(zip(lines, sizes)):
        face = font(size, bold=index in {0, 1})
        draw.text((margin, y), line, fill="#202124", font=face)
        y += size + line_gap
    draw.rectangle((4, 4, image.width - 5, image.height - 5), outline="#8a8b8f", width=3)
    return image


def transform(image: Image.Image, name: str) -> Image.Image:
    if name == "low_contrast":
        result = ImageEnhance.Contrast(image).enhance(0.24)
        return ImageEnhance.Brightness(result).enhance(1.12)
    if name == "low_light":
        array = np.asarray(image).astype(np.float32)
        gradient = np.linspace(0.22, 0.68, image.width, dtype=np.float32)[None, :, None]
        noise = np.random.default_rng(SEED).normal(0, 7, array.shape)
        return Image.fromarray(np.clip(array * gradient + noise, 0, 255).astype(np.uint8))
    if name == "rotate_90":
        return image.rotate(90, expand=True, fillcolor="#777777")
    if name == "skew":
        shear = 0.12
        return image.transform((image.width + int(image.height * shear), image.height), Image.Transform.AFFINE, (1, -shear, image.height * shear, 0, 1, 0), resample=Image.Resampling.BICUBIC, fillcolor="#777777")
    if name == "perspective":
        # PIL's QUAD order is upper-left, lower-left, lower-right, upper-right.
        return image.transform(image.size, Image.Transform.QUAD, (55, 20, 20, image.height - 35, image.width - 70, image.height - 15, image.width - 25, 0), resample=Image.Resampling.BICUBIC, fillcolor="#777777")
    if name == "blur":
        return image.filter(ImageFilter.GaussianBlur(radius=2.1))
    if name == "small_blur":
        small = image.resize((image.width // 2, image.height // 2), Image.Resampling.LANCZOS)
        return small.filter(ImageFilter.GaussianBlur(radius=1.15))
    raise ValueError(f"Unknown transform: {name}")


def main() -> None:
    random.seed(SEED)
    np.random.seed(SEED)
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    IMAGES.mkdir(parents=True, exist_ok=True)
    rendered: dict[str, Image.Image] = {}
    lines: dict[str, list[str]] = {}
    checksums = []
    for fixture in payload["fixtures"]:
        if "source" in fixture:
            source = fixture["source"]
            image = transform(rendered[source], fixture["transform"])
            fixture["lines"] = lines[source]
        else:
            image = render(fixture["lines"], fixture.get("style", "document"))
        rendered[fixture["id"]] = image
        lines[fixture["id"]] = fixture["lines"]
        target = IMAGES / f"{fixture['id']}.png"
        image.save(target, optimize=True)
        checksums.append(
            {
                "fixture_id": fixture["id"],
                "file": target.name,
                "bytes": target.stat().st_size,
                "sha256": hashlib.sha256(target.read_bytes()).hexdigest(),
            }
        )
    (ROOT / "corpus" / "resolved-manifest.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    (ROOT / "corpus" / "checksums.json").write_text(
        json.dumps({"schema_version": 1, "files": checksums}, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Generated {len(rendered)} synthetic fixtures in {IMAGES}")


if __name__ == "__main__":
    main()
