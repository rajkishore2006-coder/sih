import unittest
from backend.app.services.image_preprocessor import ImagePreprocessor, ImageMetadata
from backend.app.schemas.analysis import BoundingBox, DetectedOnion, Point2D

class TestImagePreprocessor(unittest.TestCase):
    def test_aspect_ratio_preservation(self):
        # 16:9 ratio image
        orig_w, orig_h = 1920, 1080
        transform = ImagePreprocessor.compute_letterbox_transform(
            orig_w=orig_w, orig_h=orig_h, target_w=640, target_h=640, max_dimension=2048
        )
        self.assertAlmostEqual(transform["scale"], 640 / 1920, places=4)
        self.assertEqual(transform["scaled_w"], 640)
        self.assertEqual(transform["scaled_h"], 360)
        self.assertEqual(transform["pad_x"], 0.0)
        self.assertEqual(transform["pad_y"], 140.0)

    def test_very_large_image_handling(self):
        # Ultra high-res image > 2048px (e.g. 4000x3000)
        orig_w, orig_h = 4000, 3000
        transform = ImagePreprocessor.compute_letterbox_transform(
            orig_w=orig_w, orig_h=orig_h, target_w=640, target_h=640, max_dimension=2048
        )
        self.assertLessEqual(transform["clamped_w"], 2048)
        self.assertLessEqual(transform["clamped_h"], 2048)
        self.assertAlmostEqual(transform["clamped_w"] / transform["clamped_h"], 4000 / 3000, places=2)

    def test_nms_avoids_duplicated_detections(self):
        # Create two overlapping bounding boxes (IoU > 0.5)
        box1 = BoundingBox(0.20, 0.20, 0.40, 0.40)
        box2 = BoundingBox(0.21, 0.21, 0.41, 0.41)
        # Distinct non-overlapping box
        box3 = BoundingBox(0.60, 0.60, 0.80, 0.80)

        poly = [Point2D(0.2, 0.2), Point2D(0.4, 0.2), Point2D(0.4, 0.4)]
        det1 = DetectedOnion(1, box1, poly, 0.95, "Healthy", "Grade A", 55.0, 0.05)
        det2 = DetectedOnion(2, box2, poly, 0.85, "Healthy", "Grade A", 54.0, 0.06)
        det3 = DetectedOnion(3, box3, poly, 0.92, "Healthy", "Grade A", 52.0, 0.05)

        kept, suppressed = ImagePreprocessor.apply_nms([det1, det2, det3], iou_threshold=0.45)
        self.assertEqual(len(kept), 2)
        self.assertEqual(suppressed, 1)
        self.assertEqual(kept[0].confidence, 0.95)
        self.assertEqual(kept[1].confidence, 0.92)

if __name__ == "__main__":
    unittest.main()
