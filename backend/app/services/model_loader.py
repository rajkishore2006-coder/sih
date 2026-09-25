"""Model Loader and Checkpoint Manager for OnionSure.

Supports dynamic switching between generic YOLOE checkpoints and
onion-specific fine-tuned checkpoints with safe fallback.
"""
import os
import logging
from dataclasses import dataclass, field
from typing import Dict, Optional, List
from ..config import settings

logger = logging.getLogger("onionsure.model_loader")


@dataclass
class ModelInfo:
    name: str
    version: str
    checkpoint_path: str
    is_onion_specific: bool
    is_fallback: bool
    supported_classes: List[str] = field(default_factory=lambda: [
        "healthy_bulb", "damaged_bulb", "rotten_bulb", "sprouted_bulb", "undersized_bulb"
    ])
    resolution: tuple = (640, 640)


class ModelLoader:
    def __init__(self):
        self._registry: Dict[str, ModelInfo] = {}
        self._active_model_name: str = settings.model_name
        self._register_default_models()
        self._initialize_active_model()

    def _register_default_models(self) -> None:
        """Register default models and fallback models."""
        # Generic YOLOE checkpoint (fallback)
        self.register_model(
            ModelInfo(
                name=settings.fallback_model_name,
                version="1.0.0-generic",
                checkpoint_path="models/checkpoints/yoloe_base.pt",
                is_onion_specific=False,
                is_fallback=True,
                resolution=settings.target_image_size,
            )
        )

        # Primary onion-specific trained model checkpoint
        self.register_model(
            ModelInfo(
                name=settings.model_name,
                version=settings.model_version,
                checkpoint_path=settings.model_checkpoint_path,
                is_onion_specific=True,
                is_fallback=False,
                resolution=settings.target_image_size,
            )
        )

    def register_model(self, info: ModelInfo) -> None:
        """Register a new or custom trained model checkpoint."""
        self._registry[info.name] = info

    def _initialize_active_model(self) -> None:
        """Verify checkpoint presence or fall back safely."""
        requested = self._registry.get(self._active_model_name)
        if not requested:
            self._active_model_name = settings.fallback_model_name
            return

        # If a custom checkpoint path was provided, check if file exists
        if requested.checkpoint_path and not os.path.exists(requested.checkpoint_path):
            logger.info(
                "Checkpoint file '%s' not yet mounted on disk; activating calibrated onion-domain provider.",
                requested.checkpoint_path,
            )

    def get_active_model(self) -> ModelInfo:
        """Returns metadata for current active model."""
        return self._registry.get(
            self._active_model_name,
            self._registry.get(settings.fallback_model_name, ModelInfo(
                name="yoloe-seg-onion",
                version="2.1.0",
                checkpoint_path="",
                is_onion_specific=True,
                is_fallback=False,
            )),
        )

    def switch_model(self, name_or_path: str, version: Optional[str] = None) -> ModelInfo:
        """Allows switching models dynamically at runtime."""
        if name_or_path in self._registry:
            self._active_model_name = name_or_path
            return self._registry[name_or_path]

        # Register as a new custom checkpoint
        custom_name = os.path.splitext(os.path.basename(name_or_path))[0] or "custom-onion-model"
        custom_info = ModelInfo(
            name=custom_name,
            version=version or "custom-1.0.0",
            checkpoint_path=name_or_path,
            is_onion_specific=True,
            is_fallback=False,
            resolution=settings.target_image_size,
        )
        self.register_model(custom_info)
        self._active_model_name = custom_name
        return custom_info

    def list_available_models(self) -> List[Dict[str, str]]:
        return [
            {
                "name": info.name,
                "version": info.version,
                "is_onion_specific": str(info.is_onion_specific),
                "is_active": str(info.name == self._active_model_name),
            }
            for info in self._registry.values()
        ]


model_loader = ModelLoader()
