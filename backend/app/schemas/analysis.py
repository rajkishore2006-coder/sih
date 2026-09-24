"""
Data contracts for OnionSure AI Analysis API
Ensures exact JSON alignment between backend model output and frontend viewer.
"""
from typing import List, Optional, Dict, Any

class Point2D:
    def __init__(self, x: float, y: float):
        self.x = round(float(x), 4)
        self.y = round(float(y), 4)

    def to_dict(self) -> Dict[str, float]:
        return {"x": self.x, "y": self.y}

class BoundingBox:
    def __init__(self, ymin: float, xmin: float, ymax: float, xmax: float):
        self.ymin = max(0.0, min(1.0, round(float(ymin), 4)))
        self.xmin = max(0.0, min(1.0, round(float(xmin), 4)))
        self.ymax = max(0.0, min(1.0, round(float(ymax), 4)))
        self.xmax = max(0.0, min(1.0, round(float(xmax), 4)))

    def to_dict(self) -> Dict[str, float]:
        return {
            "ymin": self.ymin,
            "xmin": self.xmin,
            "ymax": self.ymax,
            "xmax": self.xmax,
        }

    def area(self) -> float:
        return max(0.0, self.xmax - self.xmin) * max(0.0, self.ymax - self.ymin)

    def iou(self, other: 'BoundingBox') -> float:
        inter_xmin = max(self.xmin, other.xmin)
        inter_ymin = max(self.ymin, other.ymin)
        inter_xmax = min(self.xmax, other.xmax)
        inter_ymax = min(self.ymax, other.ymax)

        if inter_xmax <= inter_xmin or inter_ymax <= inter_ymin:
            return 0.0

        inter_area = (inter_xmax - inter_xmin) * (inter_ymax - inter_ymin)
        union_area = self.area() + other.area() - inter_area
        return inter_area / union_area if union_area > 0 else 0.0

class DetectedOnion:
    def __init__(
        self,
        item_id: int,
        bbox: BoundingBox,
        polygon: List[Point2D],
        confidence: float,
        defect_type: str,
        grade: str,
        estimated_diameter_mm: float,
        severity_score: float,
        is_edge_onion: bool = False,
    ):
        self.id = item_id
        self.bbox = bbox
        self.polygon = polygon
        self.confidence = round(confidence, 3)
        self.defect_type = defect_type
        self.grade = grade
        self.estimated_diameter_mm = round(estimated_diameter_mm, 1)
        self.severity_score = round(severity_score, 3)
        self.is_edge_onion = is_edge_onion

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "bbox": self.bbox.to_dict(),
            "polygon": [p.to_dict() for p in self.polygon],
            "confidence": self.confidence,
            "defect_type": self.defect_type,
            "grade": self.grade,
            "estimated_diameter_mm": self.estimated_diameter_mm,
            "severity_score": self.severity_score,
            "is_edge_onion": self.is_edge_onion,
        }

class DiagnosticsInfo:
    def __init__(
        self,
        model_name: str,
        model_version: str,
        raw_detections_count: int,
        final_detections_count: int,
        nms_suppressed_count: int,
        preprocessing_time_ms: float,
        inference_time_ms: float,
        postprocessing_time_ms: float,
        total_time_ms: float,
        image_width: int,
        image_height: int,
        image_size_bytes: int,
        exif_rotation_degrees: int = 0,
    ):
        self.model_name = model_name
        self.model_version = model_version
        self.raw_detections_count = raw_detections_count
        self.final_detections_count = final_detections_count
        self.nms_suppressed_count = nms_suppressed_count
        self.preprocessing_time_ms = round(preprocessing_time_ms, 2)
        self.inference_time_ms = round(inference_time_ms, 2)
        self.postprocessing_time_ms = round(postprocessing_time_ms, 2)
        self.total_time_ms = round(total_time_ms, 2)
        self.image_size = {
            "width": image_width,
            "height": image_height,
            "size_bytes": image_size_bytes,
            "exif_rotation_degrees": exif_rotation_degrees,
        }

    def to_dict(self) -> Dict[str, Any]:
        return {
            "model_name": self.model_name,
            "model_version": self.model_version,
            "raw_detections": self.raw_detections_count,
            "final_detections": self.final_detections_count,
            "nms_suppressed": self.nms_suppressed_count,
            "preprocessing_time_ms": self.preprocessing_time_ms,
            "inference_time_ms": self.inference_time_ms,
            "postprocessing_time_ms": self.postprocessing_time_ms,
            "total_time_ms": self.total_time_ms,
            "image_size": self.image_size,
        }
