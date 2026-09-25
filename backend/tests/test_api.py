"""Integration and contract tests for the OnionSure API."""
import unittest
import json
from backend.app.main import handle_analyze_request
from backend.app.services.model_loader import model_loader


class TestAPI(unittest.TestCase):
    def test_analyze_heap_default_contract(self):
        body = json.dumps({"image": "sample_mock_image_bytes_tray_5", "scenario": "tray_5"}).encode("utf-8")
        headers = {"content-type": "application/json"}
        query = {}

        status, data = handle_analyze_request(body, headers, query)
        self.assertEqual(status, 200)

        # Check required fields in API contract
        self.assertIn("analysis_id", data)
        self.assertIn("timestamp", data)
        self.assertIn("visible_onion_count", data)
        self.assertEqual(data["visible_onion_count"], 5)

        # Grades contract
        self.assertIn("grades", data)
        self.assertIn("grade_a_percent", data["grades"])
        self.assertIn("grade_b_percent", data["grades"])
        self.assertIn("reject_percent", data["grades"])

        # Defects contract
        self.assertIn("defects", data)
        for key in ["healthy", "damaged", "rotten", "sprouted", "undersized", "unknown", "total"]:
            self.assertIn(key, data["defects"])
        self.assertEqual(data["defects"]["total"], 5)

        # Detections list contract
        self.assertIn("detections", data)
        self.assertEqual(len(data["detections"]), 5)
        first = data["detections"][0]
        self.assertIn("id", first)
        self.assertIn("bbox", first)
        self.assertIn("polygon", first)
        self.assertIn("confidence", first)
        self.assertIn("defect_type", first)
        self.assertIn("grade", first)
        self.assertIn("estimated_diameter_mm", first)
        self.assertIn("severity_score", first)
        self.assertIn("is_edge_onion", first)

        # Diagnostics disabled by default
        self.assertNotIn("diagnostics", data)

    def test_analyze_heap_with_diagnostics_enabled(self):
        body = json.dumps({"image": "sample_dense_heap_bytes", "scenario": "dense_heap"}).encode("utf-8")
        headers = {"content-type": "application/json", "x-include-diagnostics": "true"}
        query = {"include_diagnostics": "true"}

        status, data = handle_analyze_request(body, headers, query)
        self.assertEqual(status, 200)

        # Diagnostics must be present when requested
        self.assertIn("diagnostics", data)
        diag = data["diagnostics"]
        self.assertIn("model_name", diag)
        self.assertIn("model_version", diag)
        self.assertIn("raw_detections", diag)
        self.assertIn("final_detections", diag)
        self.assertIn("nms_suppressed", diag)
        self.assertIn("total_time_ms", diag)
        self.assertIn("image_size", diag)
        self.assertGreaterEqual(diag["raw_detections"], diag["final_detections"])

    def test_model_switching_and_fallback(self):
        orig_model = model_loader.get_active_model()
        self.assertTrue(orig_model.is_onion_specific)

        # Switch to custom model path
        updated = model_loader.switch_model("models/custom_trained_onion_v3.pt", version="3.0.0")
        self.assertEqual(updated.name, "custom_trained_onion_v3")
        self.assertEqual(updated.version, "3.0.0")

        # Verify active model is updated
        self.assertEqual(model_loader.get_active_model().name, "custom_trained_onion_v3")

        # Revert back to original model
        model_loader.switch_model(orig_model.name)
        self.assertEqual(model_loader.get_active_model().name, orig_model.name)


if __name__ == "__main__":
    unittest.main()
