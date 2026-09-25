"""Unit tests for QualityClassifier."""
import unittest
import random
from backend.app.schemas.analysis import BoundingBox, Point2D, DetectionItem
from backend.app.services.quality_classifier import QualityClassifier


class TestQualityClassifier(unittest.TestCase):
    def setUp(self):
        self.classifier = QualityClassifier()
        self.prng = random.Random(42)

    def _make_candidate(self, id_num: int, defect_hint: str, dia: float = 50.0):
        return {
            "id": id_num,
            "bbox": BoundingBox(ymin=0.1, xmin=0.1, ymax=0.3, xmax=0.3),
            "polygon": [Point2D(x=0.2, y=0.2)],
            "confidence": 0.90,
            "defect_hint": defect_hint,
            "diameter_mm": dia,
            "is_edge_onion": False,
        }

    def test_healthy_large_onion_grade_a(self):
        candidate = self._make_candidate(1, "Healthy", dia=55.0)
        item = self.classifier.classify_detection(candidate, self.prng)
        self.assertEqual(item.defect_type, "Healthy")
        self.assertEqual(item.grade, "Grade A")
        self.assertLessEqual(item.severity_score, 0.15)

    def test_damaged_onion_grade_b(self):
        candidate = self._make_candidate(2, "Damaged", dia=50.0)
        item = self.classifier.classify_detection(candidate, self.prng)
        self.assertEqual(item.defect_type, "Damaged")
        self.assertEqual(item.grade, "Grade B")
        self.assertGreater(item.severity_score, 0.35)

    def test_rotten_onion_reject(self):
        candidate = self._make_candidate(3, "Rotten", dia=52.0)
        item = self.classifier.classify_detection(candidate, self.prng)
        self.assertEqual(item.defect_type, "Rotten")
        self.assertEqual(item.grade, "Reject")
        self.assertGreater(item.severity_score, 0.80)

    def test_sprouted_onion_reject(self):
        candidate = self._make_candidate(4, "Sprouted", dia=48.0)
        item = self.classifier.classify_detection(candidate, self.prng)
        self.assertEqual(item.defect_type, "Sprouted")
        self.assertEqual(item.grade, "Reject")

    def test_undersized_onion_grade_b(self):
        candidate = self._make_candidate(5, "Undersized", dia=38.0)
        item = self.classifier.classify_detection(candidate, self.prng)
        self.assertEqual(item.defect_type, "Undersized")
        self.assertEqual(item.grade, "Grade B")

    def test_unknown_classification(self):
        candidate = self._make_candidate(6, "Unknown", dia=50.0)
        item = self.classifier.classify_detection(candidate, self.prng)
        self.assertEqual(item.defect_type, "Unknown")
        self.assertIn(item.grade, ["Grade A", "Grade B", "Reject"])

    def test_summary_and_percentages_calculation(self):
        detections = [
            self.classifier.classify_detection(self._make_candidate(1, "Healthy", 55.0), self.prng),
            self.classifier.classify_detection(self._make_candidate(2, "Healthy", 55.0), self.prng),
            self.classifier.classify_detection(self._make_candidate(3, "Damaged", 50.0), self.prng),
            self.classifier.classify_detection(self._make_candidate(4, "Rotten", 50.0), self.prng),
        ]
        grades, defects = self.classifier.summarize_quality(detections)

        self.assertEqual(defects.total, 4)
        self.assertEqual(defects.healthy, 2)
        self.assertEqual(defects.damaged, 1)
        self.assertEqual(defects.rotten, 1)
        self.assertEqual(grades.grade_a_percent, 50.0)
        self.assertEqual(grades.grade_b_percent, 25.0)
        self.assertEqual(grades.reject_percent, 25.0)


if __name__ == "__main__":
    unittest.main()
