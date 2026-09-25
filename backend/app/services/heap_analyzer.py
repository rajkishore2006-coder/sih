"""Heap Analyzer Service.

Coordinates image preprocessing, YOLOE segmentation inference,
quality classification, commercial grading, and developer diagnostics.
"""
import time
import random
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone

from ..schemas.analysis import (
    HeapAnalysisResponse,
    DeveloperDiagnostics,
    DetectionItem,
)
from ..config import settings
from .image_preprocessor import ImagePreprocessor
from .yoloe_provider import yoloe_provider
from .quality_classifier import quality_classifier
from .model_loader import model_loader


class HeapAnalyzer:
    """End-to-end analyzer for onion heap imagery."""

    def analyze(
        self,
        image_bytes_or_base64: str,
        include_diagnostics: bool = False,
        scenario_hint: Optional[str] = None,
    ) -> HeapAnalysisResponse:
        t_total_start = time.perf_counter()

        # Step 1: Safe Preprocessing & Aspect-Ratio Preservation
        t_prep_start = time.perf_counter()
        meta = ImagePreprocessor.preprocess(image_bytes_or_base64)
        t_prep_end = time.perf_counter()

        # Step 2: YOLOE Object Detection & Instance Segmentation
        t_infer_start = time.perf_counter()
        active_model = model_loader.get_active_model()
        candidates, suppressed_count, used_model = yoloe_provider.detect(
            image_meta=meta,
            model_info=active_model,
            scenario_hint=scenario_hint,
        )
        t_infer_end = time.perf_counter()

        # Step 3: Quality Classification and Commercial Grading
        t_post_start = time.perf_counter()
        seed = abs(meta.size_bytes * 13 + meta.original_width * 7)
        prng = random.Random(seed)

        detections: List[DetectionItem] = []
        for c in candidates:
            item = quality_classifier.classify_detection(c, prng)
            detections.append(item)

        grades, defects = quality_classifier.summarize_quality(detections)

        # Generate contextual quality warnings
        warnings = ["Heap overlap detected: Surface contour estimates only."]
        if grades.reject_percent > 18.0:
            warnings.append(
                f"High rejection rate ({grades.reject_percent}%). Secondary cross-sectional sampling advised."
            )
        edge_count = sum(1 for d in detections if d.is_edge_onion)
        if edge_count > 0:
            warnings.append(f"{edge_count} bulb(s) positioned near image frame boundaries.")

        if meta.is_downscaled_guard:
            warnings.append("High resolution image was downsampled to preserve inference stability.")

        # Compute overall confidence
        if detections:
            avg_conf = sum(d.confidence for d in detections) / len(detections)
            overall_confidence = round(avg_conf, 3)
        else:
            overall_confidence = 0.90

        t_post_end = time.perf_counter()
        t_total_end = time.perf_counter()

        prep_time_ms = (t_prep_end - t_prep_start) * 1000.0
        infer_time_ms = (t_infer_end - t_infer_start) * 1000.0
        post_time_ms = (t_post_end - t_post_start) * 1000.0
        total_time_ms = (t_total_end - t_total_start) * 1000.0

        # Optional Developer Diagnostics
        diagnostics = None
        if include_diagnostics or settings.enable_diagnostics_default:
            diagnostics = DeveloperDiagnostics(
                model_name=used_model.name,
                model_version=used_model.version,
                raw_detections=len(detections) + suppressed_count,
                final_detections=len(detections),
                nms_suppressed=suppressed_count,
                preprocessing_time_ms=prep_time_ms,
                inference_time_ms=infer_time_ms,
                postprocessing_time_ms=post_time_ms,
                total_time_ms=total_time_ms,
                image_size={
                    "width": meta.original_width,
                    "height": meta.original_height,
                    "scaled_width": meta.scaled_width,
                    "scaled_height": meta.scaled_height,
                    "size_bytes": meta.size_bytes,
                    "exif_rotation_degrees": meta.exif_rotation_degrees,
                },
            )

        analysis_id = f"HA-{int(prng.random() * 899999 + 100000)}"
        timestamp = datetime.now(timezone.utc).isoformat()

        return HeapAnalysisResponse(
            analysis_id=analysis_id,
            timestamp=timestamp,
            visible_onion_count=len(detections),
            grades=grades,
            defects=defects,
            detections=detections,
            overall_confidence=overall_confidence,
            processing_time_ms=total_time_ms,
            is_prototype=True,
            warnings=warnings,
            estimation_disclaimer=settings.estimation_disclaimer,
            annotated_image_base64=None,
            diagnostics=diagnostics,
        )


heap_analyzer = HeapAnalyzer()
