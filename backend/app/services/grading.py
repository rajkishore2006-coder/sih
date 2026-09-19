from typing import List
from backend.app.schemas.analysis import (
    OnionDetection,
    GradeDistribution,
    DefectBreakdown,
    QualityGrade,
    DefectType,
)

class BatchGrader:
    """Computes batch grade distribution and defect breakdowns from visible detections."""

    def compute_distribution(self, detections: List[OnionDetection]) -> GradeDistribution:
        total = len(detections)
        if total == 0:
            return GradeDistribution(grade_a_percent=0.0, grade_b_percent=0.0, reject_percent=0.0)

        grade_a_count = sum(1 for d in detections if d.grade == QualityGrade.GRADE_A)
        grade_b_count = sum(1 for d in detections if d.grade == QualityGrade.GRADE_B)
        reject_count = sum(1 for d in detections if d.grade == QualityGrade.REJECT)

        return GradeDistribution(
            grade_a_percent=round((grade_a_count / total) * 100.0, 1),
            grade_b_percent=round((grade_b_count / total) * 100.0, 1),
            reject_percent=round((reject_count / total) * 100.0, 1),
        )

    def compute_defects(self, detections: List[OnionDetection]) -> DefectBreakdown:
        breakdown = DefectBreakdown()
        for d in detections:
            if d.defect_type == DefectType.HEALTHY:
                breakdown.healthy += 1
            elif d.defect_type == DefectType.DAMAGED:
                breakdown.damaged += 1
            elif d.defect_type == DefectType.ROTTEN:
                breakdown.rotten += 1
            elif d.defect_type == DefectType.SPROUTED:
                breakdown.sprouted += 1
            elif d.defect_type == DefectType.UNDERSIZED:
                breakdown.undersized += 1
            else:
                breakdown.unknown += 1
        return breakdown
