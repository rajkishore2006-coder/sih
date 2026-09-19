from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field

class QualityGrade(str, Enum):
    GRADE_A = "Grade A"
    GRADE_B = "Grade B"
    REJECT = "Reject"

class DefectType(str, Enum):
    HEALTHY = "Healthy"
    DAMAGED = "Damaged"
    ROTTEN = "Rotten"
    SPROUTED = "Sprouted"
    UNDERSIZED = "Undersized"
    UNKNOWN = "Unknown"

class Point(BaseModel):
    x: float = Field(..., description="Normalized X coordinate [0.0 - 1.0]")
    y: float = Field(..., description="Normalized Y coordinate [0.0 - 1.0]")

class BoundingBox(BaseModel):
    ymin: float = Field(..., description="Normalized top coordinate [0.0 - 1.0]")
    xmin: float = Field(..., description="Normalized left coordinate [0.0 - 1.0]")
    ymax: float = Field(..., description="Normalized bottom coordinate [0.0 - 1.0]")
    xmax: float = Field(..., description="Normalized right coordinate [0.0 - 1.0]")

class OnionDetection(BaseModel):
    id: int
    bbox: BoundingBox
    polygon: List[Point] = Field(default_factory=list, description="Segmentation contour polygon")
    confidence: float
    defect_type: DefectType
    grade: QualityGrade
    estimated_diameter_mm: Optional[float] = None
    severity_score: float = Field(default=0.0, description="Defect severity [0.0 - 1.0]")

class GradeDistribution(BaseModel):
    grade_a_percent: float = Field(..., description="Percentage of visible onions meeting Grade A")
    grade_b_percent: float = Field(..., description="Percentage of visible onions meeting Grade B")
    reject_percent: float = Field(..., description="Percentage of visible onions classified as Reject")

class DefectBreakdown(BaseModel):
    healthy: int = 0
    damaged: int = 0
    rotten: int = 0
    sprouted: int = 0
    undersized: int = 0
    unknown: int = 0

class HeapAnalysisResponse(BaseModel):
    success: bool = True
    analysis_id: str
    timestamp: str
    visible_onion_count: int
    grades: GradeDistribution
    defects: DefectBreakdown
    detections: List[OnionDetection]
    overall_confidence: float
    processing_time_ms: int
    is_prototype: bool = True
    warnings: List[str] = Field(default_factory=list)
    estimation_disclaimer: str = (
        "Estimation is derived solely from visible surface onions in the heap image. "
        "Internal, occluded, and sub-surface onions are not directly measurable. "
        "Calibrate with physical cross-sectional sampling for final trade settlement."
    )
    annotated_image_base64: Optional[str] = None

class HealthResponse(BaseModel):
    status: str = "ok"
    version: str
    is_prototype: bool
    model_loaded: bool
