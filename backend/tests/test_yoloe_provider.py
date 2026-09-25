"""Unit tests for YOLOEProvider and adaptive overlap NMS."""
import unittest
from backend.app.schemas.analysis import BoundingBox
from backend.app.services.image_preprocessor import PreprocessedImageMeta
from backend.app.services.yoloe_provider import (
    YOLOEProvider,
    compute_iou,
    compute_centroid_distance,
    apply_adaptive_overlap_nms,
)


class TestYOLOEProvider(unittest.TestCase):
    def setUp(self):
        self.provider = YOLOEProvider()
        self.dummy_meta = PreprocessedImageMeta(
            original_width=1920,
            original_height=1080,
            scaled_width=640,
            scaled_height=360,
            pad_x=0.0,
            pad_y=140.0,
            scale_factor=0.333,
            exif_rotation_degrees=0,
            size_bytes=50000,
            is_downscaled_guard=False,
        )

    def test_iou_computation(self):
        b1 = BoundingBox(ymin=0.1, xmin=0.1, ymax=0.3, xmax=0.3)
        b2 = BoundingBox(ymin=0.1, xmin=0.1, ymax=0.3, xmax=0.3)
        # Identical boxes must have IoU = 1.0
        self.assertAlmostEqual(compute_iou(b1, b2), 1.0, places=4)

        # Non-overlapping boxes must have IoU = 0.0
        b3 = BoundingBox(ymin=0.5, xmin=0.5, ymax=0.7, xmax=0.7)
        self.assertEqual(compute_iou(b1, b3), 0.0)

    def test_overlapping_distinct_onions_retained(self):
        # Two distinct onions in a heap overlapping by ~40% with distinct centroids
        onion1 = {
            "id": 1,
            "bbox": BoundingBox(ymin=0.20, xmin=0.20, ymax=0.45, xmax=0.45),
            "confidence": 0.92,
        }
        # Overlapping slightly to the right and bottom
        onion2 = {
            "id": 2,
            "bbox": BoundingBox(ymin=0.28, xmin=0.30, ymax=0.53, xmax=0.55),
            "confidence": 0.88,
        }
        kept, suppressed = apply_adaptive_overlap_nms([onion1, onion2])
        # Both distinct overlapping onions must be preserved!
        self.assertEqual(len(kept), 2)
        self.assertEqual(suppressed, 0)

    def test_duplicate_proposal_suppression(self):
        # Two proposals for the same onion with almost identical centroids
        prop1 = {
            "id": 1,
            "bbox": BoundingBox(ymin=0.300, xmin=0.300, ymax=0.500, xmax=0.500),
            "confidence": 0.95,
        }
        prop2 = {
            "id": 2,
            "bbox": BoundingBox(ymin=0.302, xmin=0.301, ymax=0.503, xmax=0.502),
            "confidence": 0.82,
        }
        kept, suppressed = apply_adaptive_overlap_nms([prop1, prop2])
        # Lower confidence duplicate must be suppressed
        self.assertEqual(len(kept), 1)
        self.assertEqual(suppressed, 1)
        self.assertEqual(kept[0]["id"], 1)

    def test_scenario_1_onion(self):
        detections, suppressed, model = self.provider.detect(
            self.dummy_meta, scenario_hint="single"
        )
        self.assertEqual(len(detections), 1)
        self.assertEqual(detections[0]["defect_hint"], "Healthy")
        self.assertGreater(detections[0]["confidence"], 0.70)

    def test_scenario_3_onions(self):
        detections, suppressed, model = self.provider.detect(
            self.dummy_meta, scenario_hint="cluster_3"
        )
        self.assertEqual(len(detections), 3)

    def test_scenario_5_onions(self):
        detections, suppressed, model = self.provider.detect(
            self.dummy_meta, scenario_hint="tray_5"
        )
        self.assertEqual(len(detections), 5)
        # Verify edge onion detected
        edge_onions = [d for d in detections if d.get("is_edge_onion")]
        self.assertGreaterEqual(len(edge_onions), 1)

    def test_scenario_20_plus_onions(self):
        detections, suppressed, model = self.provider.detect(
            self.dummy_meta, scenario_hint="multi_20"
        )
        self.assertGreaterEqual(len(detections), 20)
        # Proposal duplicate was present and must be suppressed by NMS
        self.assertGreaterEqual(suppressed, 1)

    def test_scenario_dense_heap(self):
        detections, suppressed, model = self.provider.detect(
            self.dummy_meta, scenario_hint="dense_heap"
        )
        self.assertGreaterEqual(len(detections), 20)
        # Verify all detections have valid 12-point polygon segmentations
        for d in detections:
            self.assertEqual(len(d["polygon"]), 12)


if __name__ == "__main__":
    unittest.main()
