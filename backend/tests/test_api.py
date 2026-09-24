import unittest
from backend.app.services.heap_analyzer import HeapAnalyzer
from backend.app.services.model_loader import ModelLoader
from backend.app.config import ModelConfig

class TestApiAndContract(unittest.TestCase):
    def setUp(self):
        self.analyzer = HeapAnalyzer()
        self.sample_bytes = b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00\xff\xdb\x00C\x00" + (b"\x00" * 30000)

    def test_default_api_response_contract_no_diagnostics(self):
        res = self.analyzer.analyze(
            image_bytes=self.sample_bytes,
            filename="sample_heap.jpg",
            include_diagnostics=False
        )
        # Required contract keys
        self.assertIn("analysis_id", res)
        self.assertIn("timestamp", res)
        self.assertIn("visible_onion_count", res)
        self.assertIn("grades", res)
        self.assertIn("defects", res)
        self.assertIn("assigned_grade", res)
        self.assertIn("detections", res)
        self.assertIn("overall_confidence", res)
        self.assertIn("processing_time_ms", res)
        self.assertIn("is_prototype", res)
        self.assertIn("warnings", res)
        self.assertIn("estimation_disclaimer", res)

        # Developer diagnostics should be absent by default
        self.assertNotIn("diagnostics", res)

    def test_api_with_diagnostics_enabled(self):
        res = self.analyzer.analyze(
            image_bytes=self.sample_bytes,
            filename="sample_heap.jpg",
            include_diagnostics=True
        )
        self.assertIn("diagnostics", res)
        diag = res["diagnostics"]
        self.assertIn("model_name", diag)
        self.assertIn("raw_detections", diag)
        self.assertIn("final_detections", diag)
        self.assertIn("nms_suppressed", diag)
        self.assertIn("inference_time_ms", diag)
        self.assertIn("image_size", diag)
        self.assertEqual(diag["final_detections"], res["visible_onion_count"])

    def test_model_loader_configuration(self):
        loader = ModelLoader.get_instance()
        info = loader.get_model_info()
        self.assertIn("active_model_name", info)
        self.assertIn("is_fallback", info)
        self.assertIn("configured_model_path", info)
        self.assertIn("confidence_threshold", info)

if __name__ == "__main__":
    unittest.main()
