"""Application configuration for OnionSure AI inference engine."""
import os
from dataclasses import dataclass
from typing import Tuple


@dataclass
class ModelSettings:
    """Configurable model runtime settings."""
    model_name: str = os.environ.get("ONION_MODEL_NAME", "yoloe-seg-onion")
    model_version: str = os.environ.get("ONION_MODEL_VERSION", "2.1.0-prod")
    model_checkpoint_path: str = os.environ.get(
        "ONION_MODEL_PATH", "models/checkpoints/yoloe_onion_best.pt"
    )
    fallback_model_name: str = "yoloe-seg-generic-v8"
    confidence_threshold: float = float(os.environ.get("AI_CONF_THRESHOLD", "0.38"))
    nms_iou_threshold: float = float(os.environ.get("AI_IOU_THRESHOLD", "0.45"))
    adaptive_overlap_iou: float = float(os.environ.get("AI_ADAPTIVE_OVERLAP_IOU", "0.55"))
    target_image_size: Tuple[int, int] = (640, 640)
    max_image_dimension: int = 4096
    max_detections: int = 300
    min_premium_diameter_mm: float = 45.0
    min_marketable_diameter_mm: float = 35.0
    enable_diagnostics_default: bool = False
    estimation_disclaimer: str = (
        "AI estimates surface visible bulbs and contour density. Sub-surface layers, internal "
        "defects, and bag bottoms cannot be optically verified without batch overturning."
    )


settings = ModelSettings()
