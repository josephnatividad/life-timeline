"""Bounded, deterministic preprocessing variants used by every candidate."""

from __future__ import annotations

from PIL import Image, ImageEnhance, ImageFilter, ImageOps


def prepare(image: Image.Image) -> Image.Image:
    image = ImageOps.exif_transpose(image).convert("L")
    if image.width < 1400:
        scale = min(2.0, 1400 / image.width)
        image = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
    image = ImageOps.autocontrast(image, cutoff=1)
    image = ImageEnhance.Contrast(image).enhance(1.18)
    return image.filter(ImageFilter.UnsharpMask(radius=1.2, percent=115, threshold=4))

