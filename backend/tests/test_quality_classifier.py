import unittest
from backend.app.services.quality_classifier import QualityClassifier
from backend.app.schemas.analysis import BoundingBox, DetectedOnion, Point2D

class TestQualityClassifier(unittest.TestCase):
    def test_undersized_defect_classification(self):
        # Diameter < 40mm must be classified as Undersized under APMC rules
        defect, grade, sev = QualityClassifier.classify_defect(
            base_confidence=0.90, diameter_mm=36.0
        )
        self.assertEqual(defect, "Undersized")
        self.assertEqual(grade, "Grade B")

    def test_sprouted_defect_classification(self):
        defect, grade, sev = QualityClassifier.classify_defect(
            base_confidence=0.88, diameter_mm=55.0, neck_extension=0.75
        )
        self.assertEqual(defect, "Sprouted")
        self.assertEqual(grade, "Reject")

    def test_rotten_defect_classification(self):
        defect, grade, sev = QualityClassifier.classify_defect(
            base_confidence=0.85, diameter_mm=52.0, color_variation=0.70, surface_roughness=0.55
        )
        self.assertEqual(defect, "Rotten")
        self.assertEqual(grade, "Reject")

    def test_damaged_defect_classification(self):
        defect, grade, sev = QualityClassifier.classify_defect(
            base_confidence=0.92, diameter_mm=54.0, surface_roughness=0.52
        )
        self.assertEqual(defect, "Damaged")
        self.assertEqual(grade, "Grade B")

    def test_lot_grading_grade_a(self):
        poly = [Point2D(0, 0)]
        bbox = BoundingBox(0.1, 0.1, 0.2, 0.2)
        # 8 Healthy, 2 Damaged
        dets = [
            DetectedOnion(i, bbox, poly, 0.9, "Healthy", "Grade A", 55.0, 0.05)
            for i in range(8)
        ] + [
            DetectedOnion(i+8, bbox, poly, 0.85, "Damaged", "Grade B", 50.0, 0.45)
            for i in range(2)
        ]
        result = QualityClassifier.compute_lot_grades(dets)
        self.assertEqual(result["assigned_grade"], "Grade A")
        self.assertEqual(result["grades"]["grade_a_percent"], 80.0)
        self.assertEqual(result["defects"]["healthy"], 8)
        self.assertEqual(result["defects"]["damaged"], 2)

    def test_lot_grading_reject(self):
        poly = [Point2D(0, 0)]
        bbox = BoundingBox(0.1, 0.1, 0.2, 0.2)
        # 5 Healthy, 5 Rotten/Sprouted -> 50% Reject
        dets = [
            DetectedOnion(i, bbox, poly, 0.9, "Healthy", "Grade A", 55.0, 0.05)
            for i in range(5)
        ] + [
            DetectedOnion(i+5, bbox, poly, 0.85, "Rotten", "Reject", 50.0, 0.90)
            for i in range(5)
        ]
        result = QualityClassifier.compute_lot_grades(dets)
        self.assertEqual(result["assigned_grade"], "Reject")
        self.assertEqual(result["grades"]["reject_percent"], 50.0)

if __name__ == "__main__":
    unittest.main()
