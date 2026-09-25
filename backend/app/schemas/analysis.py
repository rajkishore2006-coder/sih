"""Data models and serialization schemas for Heap Analysis."""
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Dict, Any


@dataclass
class BoundingBox:
    ymin: float
    xmin: float
    ymax: float
    xmax: float

    def to_dict(self) -> Dict[str, float]:
        return {
            "ymin": round(self.ymin, 4),
            "xmin": round(self.xmin, 4),
            "ymax": round(self.ymax, 4),
            "xmax": round(self.xmax, 4),
        }


@dataclass
class Point2D:
    x: float
    y: float

    def to_dict(self) -> Dict[str, float]:
        return {"x": round(self.x, 4), "y": round(self.y, 4)}


@dataclass
class DetectionItem:
    id: int
    bbox: BoundingBox
    polygon: List[Point2D]
    confidence: float
    defect_type: str  # 'Healthy' | 'Damaged' | 'Rotten' | 'Sprouted' | 'Undersized' | 'Unknown'
    grade: str        # 'Grade A' | 'Grade B' | 'Reject'
    estimated_diameter_mm: float
    severity_score: float
    is_edge_onion: bool

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "bbox": self.bbox.to_dict(),
            "polygon": [p.to_dict() for p in self.polygon],
            "confidence": round(self.confidence, 3),
            "defect_type": self.defect_type,
            "defectType": self.defect_type,
            "grade": self.grade,
            "estimated_diameter_mm": round(self.estimated_diameter_mm, 1),
            "estimatedDiameterMm": round(self.estimated_diameter_mm, 1),
            "severity_score": round(self.severity_score, 2),
            "severityScore": round(self.severity_score, 2),
            "is_edge_onion": self.is_edge_onion,
            "isEdgeOnion": self.is_edge_onion,
        }


@dataclass
class GradesDistribution:
    grade_a_percent: float
    grade_b_percent: float
    reject_percent: float

    def to_dict(self) -> Dict[str, float]:
        return {
            "grade_a_percent": round(self.grade_a_percent, 1),
            "gradeAPercent": round(self.grade_a_percent, 1),
            "grade_b_percent": round(self.grade_b_percent, 1),
            "gradeBPercent": round(self.grade_b_percent, 1),
            "reject_percent": round(self.reject_percent, 1),
            "rejectPercent": round(self.reject_percent, 1),
        }


@dataclass
class DefectsSummary:
    healthy: int
    damaged: int
    rotten: int
    sprouted: int
    undersized: int
    unknown: int
    total: int

    def to_dict(self) -> Dict[str, int]:
        return asdict(self)


@dataclass
class DeveloperDiagnostics:
    model_name: str
    model_version: str
    raw_detections: int
    final_detections: int
    nms_suppressed: int
    preprocessing_time_ms: float
    inference_time_ms: float
    postprocessing_time_ms: float
    total_time_ms: float
    image_size: Dict[str, Any]

    def to_dict(self) -> Dict[str, Any]:
        return {
            "model_name": self.model_name,
            "modelName": self.model_name,
            "model_version": self.model_version,
            "modelVersion": self.model_version,
            "raw_detections": self.raw_detections,
            "rawDetections": self.raw_detections,
            "final_detections": self.final_detections,
            "finalDetections": self.final_detections,
            "nms_suppressed": self.nms_suppressed,
            "nmsSuppressed": self.nms_suppressed,
            "preprocessing_time_ms": round(self.preprocessing_time_ms, 1),
            "preprocessingTimeMs": round(self.preprocessing_time_ms, 1),
            "inference_time_ms": round(self.inference_time_ms, 1),
            "inferenceTimeMs": round(self.inference_time_ms, 1),
            "postprocessing_time_ms": round(self.postprocessing_time_ms, 1),
            "postprocessingTimeMs": round(self.postprocessing_time_ms, 1),
            "total_time_ms": round(self.total_time_ms, 1),
            "totalTimeMs": round(self.total_time_ms, 1),
            "image_size": self.image_size,
            "imageSize": self.image_size,
        }


@dataclass
class HeapAnalysisResponse:
    analysis_id: str
    timestamp: str
    visible_onion_count: int
    grades: GradesDistribution
    defects: DefectsSummary
    detections: List[DetectionItem]
    overall_confidence: float
    processing_time_ms: float
    is_prototype: bool
    warnings: List[str]
    estimation_disclaimer: str
    annotated_image_base64: Optional[str] = None
    diagnostics: Optional[DeveloperDiagnostics] = None

    def to_dict(self) -> Dict[str, Any]:
        data: Dict[str, Any] = {
            "analysis_id": self.analysis_id,
            "analysisId": self.analysis_id,
            "timestamp": self.timestamp,
            "visible_onion_count": self.visible_onion_count,
            "visibleOnionCount": self.visible_onion_count,
            "grades": self.grades.to_dict(),
            "defects": self.defects.to_dict(),
            "detections": [d.to_dict() for d in self.detections],
            "overall_confidence": round(self.overall_confidence, 3),
            "overallConfidence": round(self.overall_confidence, 3),
            "processing_time_ms": round(self.processing_time_ms, 1),
            "processingTimeMs": round(self.processing_time_ms, 1),
            "is_prototype": self.is_prototype,
            "isPrototype": self.is_prototype,
            "warnings": self.warnings,
            "estimation_disclaimer": self.estimation_disclaimer,
            "disclaimer": self.estimation_disclaimer,
            "annotated_image_base64": self.annotated_image_base64,
        }
        if self.diagnostics:
            data["diagnostics"] = self.diagnostics.to_dict()
        return data
