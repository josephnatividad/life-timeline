from __future__ import annotations

import json
import unittest
from pathlib import Path

from PIL import Image

from benchmark import error_rate, normalized
from preprocess import prepare


ROOT = Path(__file__).resolve().parent


class BenchmarkHarnessTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.manifest = json.loads(
            (ROOT / "corpus" / "resolved-manifest.json").read_text(
                encoding="utf-8"
            )
        )

    def test_fixture_ids_are_unique_and_images_exist(self) -> None:
        fixtures = self.manifest["fixtures"]
        ids = [fixture["id"] for fixture in fixtures]
        self.assertEqual(len(ids), len(set(ids)))
        for fixture_id in ids:
            self.assertTrue(
                (ROOT / "corpus" / "images" / f"{fixture_id}.png").is_file()
            )

    def test_every_fixture_is_visibly_marked_synthetic(self) -> None:
        for fixture in self.manifest["fixtures"]:
            self.assertIn("SYNTHETIC TEST FIXTURE", fixture["lines"][0])

    def test_important_values_exist_in_canonical_text(self) -> None:
        for fixture in self.manifest["fixtures"]:
            text = normalized("\n".join(fixture["lines"]))
            for value in fixture["important_fields"].values():
                self.assertIn(normalized(value), text, fixture["id"])

    def test_error_rates_use_the_expected_denominator(self) -> None:
        self.assertEqual(error_rate("ABC", "ABC", words=False), 0)
        self.assertAlmostEqual(error_rate("ABC", "AB", words=False), 1 / 3)
        self.assertAlmostEqual(error_rate("ONE TWO", "ONE", words=True), 1 / 2)

    def test_preprocessing_is_bounded_and_grayscale(self) -> None:
        source = Image.open(ROOT / "corpus" / "images" / "receipt_clean.png")
        result = prepare(source)
        self.assertEqual(result.mode, "L")
        self.assertLessEqual(result.width, source.width * 2)
        self.assertLessEqual(result.height, source.height * 2)

    def test_committed_engine_results_cover_every_fixture_variant(self) -> None:
        expected = {
            (fixture["id"], variant)
            for fixture in self.manifest["fixtures"]
            for variant in ("raw", "preprocessed")
        }
        for name in (
            "paddleocr-v6-small-host.json",
            "tesseract-psm1-host.json",
            "tesseract-psm6-host.json",
        ):
            result = json.loads((ROOT / "results" / name).read_text(encoding="utf-8"))
            actual = {
                (record["fixture_id"], record["variant"])
                for record in result["records"]
            }
            self.assertEqual(actual, expected, name)
            self.assertEqual(result["project_pipeline_summary"]["records"], 38)

    def test_paddle_models_are_immutable_and_checksum_locked(self) -> None:
        lock = json.loads(
            (ROOT / "paddle-model-assets.lock.json").read_text(encoding="utf-8")
        )
        self.assertEqual(len(lock["models"]), 2)
        for model in lock["models"]:
            self.assertRegex(model["revision"], r"^[0-9a-f]{40}$")
            for checksum in model["files"].values():
                self.assertRegex(checksum, r"^[0-9a-f]{64}$")


if __name__ == "__main__":
    unittest.main()
