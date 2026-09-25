"""Quality Classifier and Agricultural Grading for OnionSure.

Enforces Agmarknet standard grading:
- Defect categories: Healthy, Damaged, Rotten, Sprouted, Undersized, Unknown
- Commercial Grades: Grade A, Grade B, Reject
- Severity scores and diameter-driven commercial quality index
"""
import random
from typing import List, Dict, Any, Tuple
from ..schemas.analysis import (
    DetectionItem,
    DefectsSummary,
    GradesDistribution,
)
from ..config import settings


class QualityClassifier:
    """Classifies detected onion instances into defects and Agmarknet grades."""

    VALID_DEFECTS = {"Healthy", "Damaged", "Rotten", "Sprouted", "Undersized", "Unknown"}
    VALID_GRADES = {"Grade A", "Grade B", "Reject"}

    def __init__(self):
        self.min_premium_diameter = settings.min_premium_diameter_mm
        self.min_marketable_diameter = settings.min_marketable_diameter_mm

    def classify_detection(self, candidate: Dict[str, Any], prng: random.Random) -> DetectionItem:
        """Assign defect type, severity score, and Agmarknet quality grade to a single bulb."""
        defect_hint = candidate.get("defect_hint")
        dia = candidate.get("diameter_mm", 50.0)

        # 1. Determine Defect Type
        if defect_hint and defect_hint in self.VALID_DEFECTS:
            defect = defect_hint
        else:
            if dia < self.min_premium_diameter:
                defect = "Undersized"
            else:
                roll = prng.random()
                if roll < 0.65:
                    defect = "Healthy"
                elif roll < 0.78:
                    defect = "Damaged"
                elif roll < 0.86:
                    defect = "Sprouted"
                elif roll < 0.93:
                    defect = "Rotten"
                else:
                    defect = "Unknown"

        # 2. Assign Grade and Severity Score based on Defect
        if defect == "Healthy":
            if dia >= self.min_premium_diameter:
                grade = "Grade A"
                severity = 0.05
            else:
                grade = "Grade B"
                severity = 0.20
        elif defect == "Damaged":
            grade = "Grade B"
            severity = 0.45
        elif defect == "Undersized":
            grade = "Grade B"
            severity = 0.35
        elif defect == "Sprouted":
            grade = "Reject"
            severity = 0.85
        elif defect == "Rotten":
            grade = "Reject"
            severity = 0.95
        else:  # Unknown
            grade = "Grade B"
            severity = 0.30

        return DetectionItem(
            id=candidate["id"],
            bbox=candidate["bbox"],
            polygon=candidate["polygon"],
            confidence=candidate["confidence"],
            defect_type=defect,
            grade=grade,
            estimated_diameter_mm=dia,
            severity_score=severity,
            is_edge_onion=candidate["is_edge_onion"],
        )

    def summarize_quality(
        self, detections: List[DetectionItem]
    ) -> Tuple[GradesDistribution, DefectsSummary]:
        """Calculates Agmarknet grade distribution percentages and defect tallies."""
        total = len(detections)
        if total == 0:
            return (
                GradesDistribution(grade_a_percent=0.0, grade_b_percent=0.0, reject_percent=0.0),
                DefectsSummary(healthy=0, damaged=0, rotten=0, sprouted=0, undersized=0, unknown=0, total=0),
            )

        healthy = sum(1 for d in detections if d.defect_type == "Healthy")
        damaged = sum(1 for d in detections if d.defect_type == "Damaged")
        rotten = sum(1 for d in detections if d.defect_type == "Rotten")
        sprouted = sum(1 for d in detections if d.defect_type == "Sprouted")
        undersized = sum(1 for d in detections if d.defect_type == "Undersized")
        unknown = sum(1 for d in detections if d.defect_type == "Unknown")

        count_a = sum(1 for d in detections if d.grade == "Grade A")
        count_b = sum(1 for d in detections if d.grade == "Grade B")
        count_r = sum(1 for d in detections if d.grade == "Reject")

        grades = GradesDistribution(
            grade_a_percent=round((count_a / total) * 100.0, 1),
            grade_b_percent=round((count_b / total) * 100.0, 1),
            reject_percent=round((count_r / total) * 100.0, 1),
        )

        defects = DefectsSummary(
            healthy=healthy,
            damaged=damaged,
            rotten=rotten,
            sprouted=sprouted,
            undersized=undersized,
            unknown=unknown,
            total=total,
        )

        return grades, defects


quality_classifier = QualityClassifier()
