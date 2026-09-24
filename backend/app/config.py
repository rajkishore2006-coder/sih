"""
OnionSure AI Pipeline Configuration
Production-ready configuration supporting environment variables and dynamic model overrides.
"""
import os
from typing import Dict, Any

class ModelConfig:
    # Model Identification & Paths
    MODEL_NAME: str = os.getenv("ONION_MODEL_NAME", "yoloe-seg-onion")
    MODEL_PATH: str = os.getenv("ONION_MODEL_PATH", "models/yoloe_seg_onion_v1.pt")
    FALLBACK_MODEL_NAME: str = "yoloe-seg-onion-prototype"
    MODEL_VERSION: str = os.getenv("ONION_MODEL_VERSION", "1.2.0")
    
    # Inference Target Dimensions
    INPUT_WIDTH: int = int(os.getenv("ONION_INPUT_WIDTH", "640"))
    INPUT_HEIGHT: int = int(os.getenv("ONION_INPUT_HEIGHT", "640"))
    MAX_IMAGE_DIMENSION: int = int(os.getenv("ONION_MAX_IMAGE_DIMENSION", "2048"))
    
    # Detection Thresholds
    CONFIDENCE_THRESHOLD: float = float(os.getenv("ONION_CONF_THRESH", "0.40"))
    IOU_NMS_THRESHOLD: float = float(os.getenv("ONION_IOU_THRESH", "0.45"))
    MIN_ONION_PIXEL_AREA: int = int(os.getenv("ONION_MIN_AREA", "250"))
    
    # Defect & Grading Standards (APMC AGMARK standards)
    MIN_PREMIUM_DIAMETER_MM: float = 40.0  # Under 40mm = Undersized
    GRADE_A_MIN_HEALTHY_RATIO: float = 0.70  # >70% healthy for Grade A
    MAX_REJECT_TOLERANCE_RATIO: float = 0.15  # >15% rejects degrades to Reject
    
    # Developer Diagnostics
    ENABLE_DIAGNOSTICS_DEFAULT: bool = os.getenv("ONION_ENABLE_DIAGNOSTICS", "false").lower() == "true"

    @classmethod
    def as_dict(cls) -> Dict[str, Any]:
        return {
            "model_name": cls.MODEL_NAME,
            "model_path": cls.MODEL_PATH,
            "fallback_model_name": cls.FALLBACK_MODEL_NAME,
            "model_version": cls.MODEL_VERSION,
            "input_resolution": f"{cls.INPUT_WIDTH}x{cls.INPUT_HEIGHT}",
            "confidence_threshold": cls.CONFIDENCE_THRESHOLD,
            "iou_nms_threshold": cls.IOU_NMS_THRESHOLD,
            "min_premium_diameter_mm": cls.MIN_PREMIUM_DIAMETER_MM,
            "diagnostics_enabled_by_default": cls.ENABLE_DIAGNOSTICS_DEFAULT,
        }
