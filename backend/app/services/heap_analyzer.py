"""
Heap Analysis Orchestrator
Coordinates preprocessing, model inference, quality grading, and developer diagnostics.
"""
import time
from typing import Dict, Any, Optional
from .image_preprocessor import ImagePreprocessor
from .model_loader import ModelLoader
from .yoloe_provider import YoloeSegProvider
from .quality_classifier import QualityClassifier
from ..schemas.analysis import DiagnosticsInfo
from ..config import ModelConfig

class HeapAnalyzer:
    """
    Main orchestration engine executing the 4-stage pipeline:
    1. Image Preprocessing & EXIF orientation normalization
    2. Segmentor model inference (YOLOE / custom onion weights)
    3. IoU Non-Maximum Suppression (NMS) deduplication
    4. APMC AGMARK quality classification and consignment grading
    """

    def __init__(self):
        self.model_loader = ModelLoader.get_instance()
        self.segmentor = YoloeSegProvider(
            confidence_threshold=ModelConfig.CONFIDENCE_THRESHOLD,
            iou_threshold=ModelConfig.IOU_NMS_THRESHOLD,
        )

    def analyze(
        self,
        image_bytes: bytes,
        filename: str = "heap.jpg",
        include_diagnostics: bool = False,
        scenario_hint: str = "auto",
    ) -> Dict[str, Any]:
        t0 = time.time()

        # Step 1: Preprocessing & Metadata
        t_prep_start = time.time()
        metadata = ImagePreprocessor.extract_metadata(image_bytes)
        transform = ImagePreprocessor.compute_letterbox_transform(
            orig_w=metadata.width,
            orig_h=metadata.height,
            target_w=ModelConfig.INPUT_WIDTH,
            target_h=ModelConfig.INPUT_HEIGHT,
            max_dimension=ModelConfig.MAX_IMAGE_DIMENSION,
        )
        t_prep_end = time.time()

        # Step 2 & 3: Model Inference & NMS Deduplication
        t_infer_start = time.time()
        detections, raw_count, suppressed_count = self.segmentor.segment_heap(
            image_bytes=image_bytes,
            metadata=metadata,
            transform_info=transform,
            scenario_hint=scenario_hint,
        )
        t_infer_end = time.time()

        # Step 4: Quality Classification & Grading
        t_post_start = time.time()
        grading_result = QualityClassifier.compute_lot_grades(detections)
        t_post_end = time.time()

        total_elapsed_ms = (t_post_end - t0) * 1000.0

        # Mean confidence calculation
        if detections:
            overall_conf = round(sum(d.confidence for d in detections) / len(detections), 3)
        else:
            overall_conf = 0.0

        response: Dict[str, Any] = {
            "analysis_id": f"HA-{int(time.time() * 1000) % 10000000}",
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "visible_onion_count": len(detections),
            "grades": grading_result["grades"],
            "defects": grading_result["defects"],
            "assigned_grade": grading_result["assigned_grade"],
            "detections": [d.to_dict() for d in detections],
            "overall_confidence": overall_conf,
            "processing_time_ms": round(total_elapsed_ms, 1),
            "is_prototype": self.model_loader.is_fallback,
            "warnings": grading_result["warnings"],
            "estimation_disclaimer": (
                "Estimation is derived solely from visible surface onions in the heap image. "
                "Internal, occluded, and sub-surface onions are not directly measurable. "
                "Calibrate with physical cross-sectional sampling for final trade settlement."
            ),
            "annotated_image_base64": None,
        }

        # Step 5: Optional Developer Diagnostics (disabled by default)
        if include_diagnostics or ModelConfig.ENABLE_DIAGNOSTICS_DEFAULT:
            diag = DiagnosticsInfo(
                model_name=self.model_loader.model_name,
                model_version=ModelConfig.MODEL_VERSION,
                raw_detections_count=raw_count,
                final_detections_count=len(detections),
                nms_suppressed_count=suppressed_count,
                preprocessing_time_ms=(t_prep_end - t_prep_start) * 1000.0,
                inference_time_ms=(t_infer_end - t_infer_start) * 1000.0,
                postprocessing_time_ms=(t_post_end - t_post_start) * 1000.0,
                total_time_ms=total_elapsed_ms,
                image_width=metadata.width,
                image_height=metadata.height,
                image_size_bytes=metadata.size_bytes,
                exif_rotation_degrees=metadata.rotation,
            )
            response["diagnostics"] = diag.to_dict()

        return response
