"""
Quality Classification and Grading Service
Evaluates per-onion defect severity, diameter standards, and consignment AGMARK grading.
"""
from typing import List, Dict, Any, Tuple
from ..schemas.analysis import DetectedOnion
from ..config import ModelConfig

class QualityClassifier:
    """
    Evaluates individual onion bulb defects and computes aggregate lot grading.
    Conforms strictly to Indian APMC / AGMARK onion trading standards.
    """

    @staticmethod
    def classify_defect(
        base_confidence: float,
        diameter_mm: float,
        surface_roughness: float = 0.1,
        color_variation: float = 0.1,
        neck_extension: float = 0.0,
    ) -> Tuple[str, str, float]:
        """
        Classifies defect type, grade tier, and severity score for an onion.
        Returns: (defect_type, grade, severity_score)
        """
        # 1. Size constraint check (AGMARK: <40mm is Undersized)
        if diameter_mm < ModelConfig.MIN_PREMIUM_DIAMETER_MM:
            return "Undersized", "Grade B", 0.35

        # 2. Sprout detection (neck elongation / premature green shoot)
        if neck_extension > 0.45:
            return "Sprouted", "Reject", 0.85

        # 3. Rot detection (high discoloration & fungal texture)
        if color_variation > 0.60 and surface_roughness > 0.40:
            return "Rotten", "Reject", 0.92

        # 4. Mechanical cut / surface damage
        if surface_roughness > 0.48:
            grade = "Grade B" if surface_roughness < 0.70 else "Reject"
            return "Damaged", grade, round(surface_roughness, 2)

        # 5. Healthy bulb
        return "Healthy", "Grade A", 0.05

    @staticmethod
    def compute_lot_grades(detections: List[DetectedOnion]) -> Dict[str, Any]:
        """
        Computes lot grade percentages and defect summary from visible detections.
        """
        total = len(detections)
        if total == 0:
            return {
                "grades": {"grade_a_percent": 0.0, "grade_b_percent": 0.0, "reject_percent": 0.0},
                "defects": {
                    "healthy": 0, "damaged": 0, "rotten": 0, "sprouted": 0,
                    "undersized": 0, "unknown": 0, "total": 0
                },
                "assigned_grade": "Reject",
                "warnings": ["No onions detected in the provided image."]
            }

        counts = {
            "healthy": sum(1 for d in detections if d.defect_type == "Healthy"),
            "damaged": sum(1 for d in detections if d.defect_type == "Damaged"),
            "rotten": sum(1 for d in detections if d.defect_type == "Rotten"),
            "sprouted": sum(1 for d in detections if d.defect_type == "Sprouted"),
            "undersized": sum(1 for d in detections if d.defect_type == "Undersized"),
            "unknown": sum(1 for d in detections if d.defect_type == "Unknown"),
            "total": total,
        }

        count_a = sum(1 for d in detections if d.grade == "Grade A")
        count_b = sum(1 for d in detections if d.grade == "Grade B")
        count_r = sum(1 for d in detections if d.grade == "Reject")

        pct_a = round((count_a / total) * 100.0, 1)
        pct_b = round((count_b / total) * 100.0, 1)
        pct_r = round((count_r / total) * 100.0, 1)

        # Assign lot grade
        if pct_r > 18.0:
            assigned_grade = "Reject"
        elif (counts["healthy"] / total) >= ModelConfig.GRADE_A_MIN_HEALTHY_RATIO and pct_a >= 65.0:
            assigned_grade = "Grade A"
        else:
            assigned_grade = "Grade B"

        warnings: List[str] = [
            "Heap overlap detected: Surface contour estimates only."
        ]
        if pct_r > 18.0:
            warnings.append("High rejection rate (>18%). Secondary cross-sectional sampling advised.")

        edge_count = sum(1 for d in detections if d.is_edge_onion)
        if edge_count > 0:
            warnings.append(f"{edge_count} bulb(s) positioned near image frame boundaries.")

        return {
            "grades": {
                "grade_a_percent": pct_a,
                "grade_b_percent": pct_b,
                "reject_percent": pct_r,
            },
            "defects": counts,
            "assigned_grade": assigned_grade,
            "warnings": warnings,
        }
