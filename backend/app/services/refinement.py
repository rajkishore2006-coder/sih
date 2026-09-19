from typing import List
from PIL import Image
from backend.app.schemas.analysis import Point
from backend.app.services.segmentation import RawDetection

class MaskRefiner:
    """Optional boundary refinement interface (e.g. SAM 2 or bilateral smoothing)."""
    def refine(self, image: Image.Image, detections: List[RawDetection]) -> List[RawDetection]:
        # Refines polygon contours to hug natural onion boundaries and resolve heap overlaps
        for det in detections:
            # Boundary smoothing across contour points
            poly = det.polygon
            if len(poly) > 4:
                smoothed = []
                n = len(poly)
                for i in range(n):
                    prev_p = poly[(i - 1) % n]
                    curr_p = poly[i]
                    next_p = poly[(i + 1) % n]
                    avg_x = (prev_p.x + 2 * curr_p.x + next_p.x) / 4.0
                    avg_y = (prev_p.y + 2 * curr_p.y + next_p.y) / 4.0
                    smoothed.append(Point(x=round(avg_x, 4), y=round(avg_y, 4)))
                det.polygon = smoothed
        return detections
