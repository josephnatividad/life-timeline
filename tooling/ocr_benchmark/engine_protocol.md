# OCR engine result protocol

An isolated provider writes one UTF-8 JSON object per fixture to stdout:

```json
{"fixture_id":"receipt_clean","lines":[{"text":"TOTAL USD 23.40","confidence":0.98}],"latency_ms":41.2,"peak_rss_mb":93.1}
```

Required fields are `fixture_id`, `lines`, and `latency_ms`. Confidence and
peak RSS are nullable when a provider cannot expose them reliably. Lines must
be returned in reading order. Bounding boxes may be added later without
changing the production `TextRecognitionEngine` contract.

The benchmark converts these provider-neutral lines to the same conceptual
`OcrDocument` consumed by Life Timeline's deterministic classification and
extraction pipeline. Engine-specific objects must not cross that boundary.

