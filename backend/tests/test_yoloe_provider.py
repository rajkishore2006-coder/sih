import unittest
from backend.app.services.yoloe_provider import YoloeSegProvider
from backend.app.services.image_preprocessor import ImageMetadata

class TestYoloeProvider(unittest.TestCase):
    def setUp(self):
        self.provider = YoloeSegProvider(confidence_threshold=0.40, iou_threshold=0.45)
        self.meta = ImageMetadata(640, 640, 0, 10000, "jpeg")
        self.transform = {"scale": 1.0, "pad_x": 0.0, "pad_y": 0.0}

    def test_single_onion_handling(self):
        fake_bytes = b"single_sample" * 500  # small size
        dets, raw_count, suppressed = self.provider.segment_heap(
            fake_bytes, self.meta, self.transform, scenario_hint="single"
        )
        self.assertEqual(len(dets), 1)
        self.assertEqual(raw_count, 1)
        self.assertEqual(suppressed, 0)
        self.assertGreater(dets[0].confidence, 0.80)
        self.assertEqual(len(dets[0].polygon), 12)

    def test_three_onions_handling(self):
        fake_bytes = b"three_triad" * 1000
        dets, raw_count, suppressed = self.provider.segment_heap(
            fake_bytes, self.meta, self.transform, scenario_hint="cluster_3"
        )
        self.assertEqual(len(dets), 3)

    def test_five_onions_tray_with_edge_detection(self):
        fake_bytes = b"five_tray" * 2000
        dets, raw_count, suppressed = self.provider.segment_heap(
            fake_bytes, self.meta, self.transform, scenario_hint="tray_5"
        )
        self.assertEqual(len(dets), 5)
        # Check defect diversity
        defect_types = {d.defect_type for d in dets}
        self.assertIn("Healthy", defect_types)
        self.assertIn("Undersized", defect_types)

    def test_twenty_plus_onions_with_nms(self):
        fake_bytes = b"twenty_crate" * 5000
        dets, raw_count, suppressed = self.provider.segment_heap(
            fake_bytes, self.meta, self.transform, scenario_hint="multi_20"
        )
        self.assertGreaterEqual(len(dets), 20)
        self.assertGreaterEqual(suppressed, 1)  # duplicate successfully suppressed

    def test_dense_heap_handling(self):
        fake_bytes = b"dense_mandi_heap" * 15000
        dets, raw_count, suppressed = self.provider.segment_heap(
            fake_bytes, self.meta, self.transform, scenario_hint="dense_heap"
        )
        self.assertGreaterEqual(len(dets), 20)
        self.assertGreaterEqual(suppressed, 1)

if __name__ == "__main__":
    unittest.main()
