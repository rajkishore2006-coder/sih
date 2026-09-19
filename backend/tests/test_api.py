import io
from PIL import Image
from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

def create_dummy_image() -> bytes:
    img = Image.new("RGB", (800, 600), color=(180, 80, 80))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["is_prototype"] is True

def test_model_info_endpoint():
    response = client.get("/api/model-info")
    assert response.status_code == 200
    data = response.json()
    assert "Healthy" in data["classes"]
    assert "Grade A" in data["grades"]

def test_analyze_heap_endpoint():
    img_bytes = create_dummy_image()
    files = {"file": ("heap_test.jpg", img_bytes, "image/jpeg")}
    response = client.post("/api/analyze-heap", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["visible_onion_count"] > 0
    assert "grades" in data
    assert "defects" in data
    assert "estimation_disclaimer" in data
    assert data["is_prototype"] is True
    assert len(data["detections"]) == data["visible_onion_count"]

def test_dynamic_onion_counting():
    """Verify that onion count dynamically scales with the image content (e.g. 3, 4 onions) rather than a fixed grid."""
    from PIL import ImageDraw
    for expected_count in (3, 4):
        img = Image.new("RGB", (800, 600), color=(20, 20, 20))
        draw = ImageDraw.Draw(img)
        # Position discrete onion bulbs with spacing
        for i in range(expected_count):
            cx = 150 + (i % 2) * 450
            cy = 150 + (i // 2) * 300
            draw.ellipse([cx - 70, cy - 70, cx + 70, cy + 70], fill=(200, 80, 80), outline=(100, 30, 30), width=3)
        buf = io.BytesIO()
        img.save(buf, format="JPEG")
        files = {"file": (f"onions_{expected_count}.jpg", buf.getvalue(), "image/jpeg")}
        response = client.post("/api/analyze-heap", files=files)
        assert response.status_code == 200
        data = response.json()
        assert data["visible_onion_count"] == expected_count, (
            f"Expected dynamic count of {expected_count}, got {data['visible_onion_count']}"
        )

