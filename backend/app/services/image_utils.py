import io
import base64
from typing import List, Tuple
from PIL import Image, ImageDraw, ImageFont
from backend.app.schemas.analysis import OnionDetection, DefectType

DEFECT_COLORS = {
    DefectType.HEALTHY: (34, 197, 94, 180),     # Emerald Green
    DefectType.DAMAGED: (249, 115, 22, 180),    # Orange
    DefectType.ROTTEN: (239, 68, 68, 190),      # Crimson Red
    DefectType.SPROUTED: (234, 179, 8, 180),    # Yellow
    DefectType.UNDERSIZED: (168, 85, 247, 180), # Purple
    DefectType.UNKNOWN: (156, 163, 175, 180),   # Gray
}

DEFECT_STROKE_COLORS = {
    DefectType.HEALTHY: (22, 163, 74, 255),
    DefectType.DAMAGED: (234, 88, 12, 255),
    DefectType.ROTTEN: (220, 38, 38, 255),
    DefectType.SPROUTED: (202, 138, 4, 255),
    DefectType.UNDERSIZED: (147, 51, 234, 255),
    DefectType.UNKNOWN: (107, 114, 128, 255),
}

def decode_image(image_bytes: bytes) -> Image.Image:
    image = Image.open(io.BytesIO(image_bytes))
    if image.mode != "RGB":
        image = image.convert("RGB")
    return image

def render_annotated_image(image: Image.Image, detections: List[OnionDetection]) -> str:
    """Draws segmentation polygons and defect bounding boxes over the image and returns base64 png."""
    overlay = image.copy().convert("RGBA")
    draw_overlay = ImageDraw.Draw(overlay, "RGBA")
    w, h = image.size

    for det in detections:
        defect = det.defect_type
        fill_color = DEFECT_COLORS.get(defect, (156, 163, 175, 120))
        stroke_color = DEFECT_STROKE_COLORS.get(defect, (255, 255, 255, 255))

        # Draw polygon mask if points exist
        if len(det.polygon) >= 3:
            poly_points = [(p.x * w, p.y * h) for p in det.polygon]
            draw_overlay.polygon(poly_points, fill=fill_color, outline=stroke_color)

        # Draw bounding box
        bbox = det.bbox
        x0, y0 = bbox.xmin * w, bbox.ymin * h
        x1, y1 = bbox.xmax * w, bbox.ymax * h
        draw_overlay.rectangle([x0, y0, x1, y1], outline=stroke_color, width=2)

        # Draw badge label
        label = f"#{det.id} {defect.value} ({int(det.confidence * 100)}%)"
        draw_overlay.rectangle([x0, max(0, y0 - 18), x0 + len(label) * 7 + 8, y0], fill=(15, 23, 42, 210))
        draw_overlay.text((x0 + 4, max(0, y0 - 16)), label, fill=(255, 255, 255, 255))

    final_img = Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB")
    buffer = io.BytesIO()
    final_img.save(buffer, format="JPEG", quality=85)
    return base64.b64encode(buffer.getvalue()).decode("utf-8")
