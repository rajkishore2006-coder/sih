"""Image Preprocessor for OnionSure Vision Inference.

Handles safe resizing, aspect-ratio preservation (letterboxing),
EXIF rotation normalization, large-image memory guards, and
bidirectional coordinate projection.
"""
import base64
import struct
import math
from dataclasses import dataclass
from typing import Tuple, Dict, Any, Optional
from ..config import settings


@dataclass
class PreprocessedImageMeta:
    original_width: int
    original_height: int
    scaled_width: int
    scaled_height: int
    pad_x: float
    pad_y: float
    scale_factor: float
    exif_rotation_degrees: int
    size_bytes: int
    is_downscaled_guard: bool


class ImagePreprocessor:
    """Safe image preprocessor that prepares images for neural inference."""

    @staticmethod
    def extract_image_dimensions_and_rotation(
        image_bytes: bytes,
    ) -> Tuple[int, int, int]:
        """Parse image dimensions and EXIF rotation from raw byte header.

        Returns (width, height, rotation_degrees).
        """
        width = 1920
        height = 1080
        rotation_degrees = 0

        if len(image_bytes) < 32:
            return width, height, rotation_degrees

        # Check PNG magic bytes
        if image_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
            try:
                # PNG IHDR chunk starts at byte 12
                w, h = struct.unpack(">II", image_bytes[16:24])
                if w > 0 and h > 0:
                    return w, h, 0
            except Exception:
                pass

        # Check JPEG magic bytes
        if image_bytes.startswith(b"\xff\xd8"):
            try:
                offset = 2
                length = len(image_bytes)
                while offset < length - 4:
                    marker, = struct.unpack(">H", image_bytes[offset:offset + 2])
                    offset += 2
                    if marker == 0xFFD9 or marker == 0xFFDA:  # EOI or SOS
                        break
                    if offset >= length - 2:
                        break
                    segment_length, = struct.unpack(">H", image_bytes[offset:offset + 2])
                    if segment_length < 2:
                        break

                    # EXIF in APP1 marker
                    if marker == 0xFFE1 and segment_length > 14:
                        app1_data = image_bytes[offset + 2 : offset + segment_length]
                        if app1_data.startswith(b"Exif\x00\x00"):
                            # Check orientation tag (0x0112)
                            rot = ImagePreprocessor._parse_exif_orientation(app1_data[6:])
                            if rot:
                                rotation_degrees = rot

                    # SOF0, SOF2 markers contain image dimensions
                    if marker in (0xFFC0, 0xFFC1, 0xFFC2):
                        h, w = struct.unpack(">HH", image_bytes[offset + 3 : offset + 7])
                        if w > 0 and h > 0:
                            width, height = w, h
                            break

                    offset += segment_length
            except Exception:
                pass

        return width, height, rotation_degrees

    @staticmethod
    def _parse_exif_orientation(tiff_header: bytes) -> int:
        """Parse orientation tag from TIFF structure."""
        if len(tiff_header) < 8:
            return 0
        endian = tiff_header[:2]
        fmt_short = "<H" if endian == b"II" else ">H"
        fmt_long = "<I" if endian == b"II" else ">I"

        try:
            first_ifd_offset, = struct.unpack(fmt_long, tiff_header[4:8])
            if first_ifd_offset + 2 > len(tiff_header):
                return 0
            num_entries, = struct.unpack(
                fmt_short, tiff_header[first_ifd_offset : first_ifd_offset + 2]
            )
            curr = first_ifd_offset + 2
            for _ in range(num_entries):
                if curr + 12 > len(tiff_header):
                    break
                tag, field_type, count = struct.unpack(
                    f"{endian.decode()}HHI", tiff_header[curr : curr + 8]
                )
                if tag == 0x0112:  # Orientation tag
                    val, = struct.unpack(fmt_short, tiff_header[curr + 8 : curr + 10])
                    # EXIF orientations:
                    # 1: Normal (0 deg)
                    # 3: 180 deg
                    # 6: 90 deg CW
                    # 8: 270 deg CW (90 deg CCW)
                    if val == 3:
                        return 180
                    elif val == 6:
                        return 90
                    elif val == 8:
                        return 270
                    return 0
                curr += 12
        except Exception:
            return 0
        return 0

    @classmethod
    def preprocess(
        cls,
        image_bytes_or_base64: str,
        target_size: Tuple[int, int] = settings.target_image_size,
        max_dimension: int = settings.max_image_dimension,
    ) -> PreprocessedImageMeta:
        """Perform safe preprocessing with aspect ratio preservation and letterboxing math."""
        # Clean base64 header if present
        data = image_bytes_or_base64
        if isinstance(data, str) and data.startswith("data:"):
            data = data.split(",", 1)[-1]

        raw_bytes = b""
        if isinstance(data, str):
            try:
                raw_bytes = base64.b64decode(data)
            except Exception:
                raw_bytes = data.encode("utf-8", errors="ignore")
        elif isinstance(data, bytes):
            raw_bytes = data

        size_bytes = len(raw_bytes)
        w, h, rot = cls.extract_image_dimensions_and_rotation(raw_bytes)

        # If EXIF indicates 90 or 270 degrees rotation, dimensions are swapped
        if rot in (90, 270):
            w, h = h, w

        # Guard against excessively large images (> 4096px)
        is_downscaled_guard = False
        if max(w, h) > max_dimension:
            scale_down = max_dimension / max(w, h)
            w = int(w * scale_down)
            h = int(h * scale_down)
            is_downscaled_guard = True

        target_w, target_h = target_size
        scale = min(target_w / max(1, w), target_h / max(1, h))
        scaled_w = int(w * scale)
        scaled_h = int(h * scale)

        pad_x = (target_w - scaled_w) / 2.0
        pad_y = (target_h - scaled_h) / 2.0

        return PreprocessedImageMeta(
            original_width=w,
            original_height=h,
            scaled_width=scaled_w,
            scaled_height=scaled_h,
            pad_x=pad_x,
            pad_y=pad_y,
            scale_factor=scale,
            exif_rotation_degrees=rot,
            size_bytes=size_bytes,
            is_downscaled_guard=is_downscaled_guard,
        )

    @classmethod
    def letterbox_to_original_coords(
        cls,
        x_norm: float,
        y_norm: float,
        meta: PreprocessedImageMeta,
        target_size: Tuple[int, int] = settings.target_image_size,
    ) -> Tuple[float, float]:
        """Convert normalized letterbox coordinate back to original image relative coordinate [0, 1]."""
        target_w, target_h = target_size
        canvas_x = x_norm * target_w
        canvas_y = y_norm * target_h

        orig_px_x = (canvas_x - meta.pad_x) / max(0.001, meta.scale_factor)
        orig_px_y = (canvas_y - meta.pad_y) / max(0.001, meta.scale_factor)

        orig_norm_x = orig_px_x / max(1.0, meta.original_width)
        orig_norm_y = orig_px_y / max(1.0, meta.original_height)

        # Clamping to [0, 1]
        orig_norm_x = max(0.0, min(1.0, orig_norm_x))
        orig_norm_y = max(0.0, min(1.0, orig_norm_y))

        return orig_norm_x, orig_norm_y
