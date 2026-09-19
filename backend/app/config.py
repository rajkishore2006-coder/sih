import os
from pydantic import BaseModel

class Settings(BaseModel):
    app_name: str = "OnionSure AI Heap Analysis API"
    app_version: str = "1.0.0"
    model_weights_path: str = os.getenv("MODEL_WEIGHTS_PATH", "")
    enable_sam2_refinement: bool = os.getenv("ENABLE_SAM2_REFINEMENT", "false").lower() in ("true", "1")
    max_upload_size_mb: int = int(os.getenv("MAX_UPLOAD_SIZE_MB", "15"))
    confidence_threshold: float = float(os.getenv("CONFIDENCE_THRESHOLD", "0.45"))
    is_prototype: bool = True

settings = Settings()
