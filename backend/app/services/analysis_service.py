import time
import uuid
from datetime import datetime, timezone
from typing import Tuple, List
from PIL import Image
from backend.app.schemas.analysis import (
    HeapAnalysisResponse,
    OnionDetection,
)
from backend.app.services.image_utils import decode_image, render_annotated_image
from backend.app.services.segmentation import get_segmentation_engine
from backend.app.services.refinement import MaskRefiner
from backend.app.services.quality import QualityClassifier
from backend.app.services.grading import BatchGrader
from backend.app.config import settings

class HeapAnalysisService:
    def __init__(self):
        self.segmenter = get_segmentation_engine(settings.model_weights_path)
        self.refiner = MaskRefiner()
        self.classifier = QualityClassifier()
        self.grader = BatchGrader()

    def analyze_heap_image(self, image_bytes: bytes, filename: str = "heap.jpg") -> HeapAnalysisResponse:
        start_time = time.time()
        image = decode_image(image_bytes)
        w, h = image.size

        # 1. Instance segmentation
        raw_detections = self.segmenter.segment_heap(image)

        # 2. Refinement if enabled
        if settings.enable_sam2_refinement:
            raw_detections = self.refiner.refine(image, raw_detections)

        # 3. Quality defect classification & grading
        detections: List[OnionDetection] = []
        for idx, raw in enumerate(raw_detections, start=1):
            defect_type, grade, est_dia, severity = self.classifier.classify(raw, idx)
            detections.append(
                OnionDetection(
                    id=idx,
                    bbox=raw.bbox,
                    polygon=raw.polygon,
                    confidence=raw.confidence,
                    defect_type=defect_type,
                    grade=grade,
                    estimated_diameter_mm=est_dia,
                    severity_score=severity,
                )
            )

        # 4. Grading distributions & defect counts
        grades = self.grader.compute_distribution(detections)
        defects = self.grader.compute_defects(detections)

        # 5. Calculate overall confidence & identify heap warnings
        total_conf = sum(d.confidence for d in detections) if detections else 0.85
        overall_confidence = round(total_conf / max(1, len(detections)), 2)

        warnings = []
        if len(detections) < 5:
            warnings.append("Low onion count detected. Ensure camera is centered on heap.")
        if w < 600 or h < 600:
            warnings.append("Low image resolution. Higher resolution recommended for accurate defect detection.")
        if grades.reject_percent > 20.0:
            warnings.append("Elevated rejection rate (>20%). Manual cross-check recommended before grading sign-off.")
        warnings.append("Heap overlap detected: Estimates reflect visible surface onions only.")

        # 6. Render annotated preview
        annotated_b64 = render_annotated_image(image, detections)
        elapsed_ms = int((time.time() - start_time) * 1000)

        return HeapAnalysisResponse(
            success=True,
            analysis_id=f"HA-{uuid.uuid4().hex[:8].upper()}",
            timestamp=datetime.now(timezone.utc).isoformat(),
            visible_onion_count=len(detections),
            grades=grades,
            defects=defects,
            detections=detections,
            overall_confidence=overall_confidence,
            processing_time_ms=elapsed_ms,
            is_prototype=settings.is_prototype,
            warnings=warnings,
            annotated_image_base64=annotated_b64,
        )
