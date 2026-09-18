# AI-Based Smart Onion Batch Quality Estimation from Heap Images

## Delivery plan

1. Backend foundation
   - Add a FastAPI application under `backend/app`.
   - Define a versioned `POST /api/analyze-heap` contract.
   - Validate image uploads, return structured errors, and expose health/status endpoints.

2. Inference architecture
   - Add an instance-segmentation interface with an optional YOLO11-Seg/Ultralytics adapter.
   - Add an optional SAM 2 refinement interface for difficult overlap cases.
   - Fall back to a clearly labelled prototype detector when model weights are unavailable.

3. Quality and batch estimation
   - Add a modular per-onion quality classifier interface.
   - Add a prototype classifier with `Healthy`, `Damaged`, `Rotten`, `Sprouted`, `Undersized`, and `Unknown` outputs.
   - Calculate Grade A, Grade B, and Reject from visible detected onions only.
   - Return defect counts, confidence, processing time, warnings, and an estimation disclaimer.

4. Mobile integration
   - Preserve the existing batch, QR, report, and verification flow.
   - Add a typed heap-analysis response model and API client.
   - Upgrade inspection to support one heap image, camera/gallery capture, loading, retry, and errors.
   - Add annotated-image visualization, distribution cards, defect results, and visible-sample disclaimer.

5. Reporting and persistence
   - Extend the existing PDF report with image, segmentation summary, Grade A/B/Reject, defects, confidence, and limitations.
   - Add analysis history using the existing local store first, then Firebase persistence behind services.

6. Validation and model readiness
   - Add backend unit/API tests and Flutter parsing/widget tests.
   - Add environment-based configuration and documented model-weight setup.
   - Validate with real heap images and record failure cases involving overlap, occlusion, lighting, and bags.

## Proposed structure

```text
backend/
  app/
    __init__.py
    main.py
    config.py
    api/
      __init__.py
      routes.py
    schemas/
      __init__.py
      analysis.py
    services/
      __init__.py
      analysis_service.py
      segmentation.py
      refinement.py
      quality.py
      grading.py
      image_utils.py
  tests/
    __init__.py
    test_api.py
  requirements.txt
  .env.example

lib/
  models/
    analysis_models.dart
  services/
    heap_analysis_service.dart
  widgets/
    segmentation_overlay.dart
    quality_distribution.dart
  screens/
    heap_analysis_screen.dart
```

## Accuracy boundary

The initial backend is an end-to-end prototype. It must label fallback detections and quality results as prototype output. A custom onion segmentation dataset, onion defect dataset, model fine-tuning, calibration, and mandi validation are required before production use.
