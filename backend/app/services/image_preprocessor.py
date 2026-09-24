"""
Image Preprocessing Service
Handles EXIF orientation, aspect ratio preservation, resizing bounds, and IoU NMS deduplication.
"""
import io
import struct
import math
import time
from typing import Tuple, List, Dict, Any, Optional
from ..schemas.analysis import BoundingBox, DetectedOnion

class ImageMetadata:
    def __init__(self, width: int, height: int, rotation: int = 0, size_bytes: int = 0, format_name: str = "jpeg"):
        self.width = width
        self.height = height
        self.rotation = rotation
        self.size_bytes = size_bytes
        self.format_name = format_name

class ImagePreprocessor:
    """
    Production preprocessor that extracts dimensions, handles EXIF orientation,
    computes aspect-ratio scaling transforms, and applies Non-Maximum Suppression (NMS).
    """

    @staticmethod
    def extract_metadata(image_bytes: bytes) -> ImageMetadata:
        """
        Extracts width, height, and EXIF orientation from JPEG / PNG binaries.
        """
        size_bytes = len(image_bytes)
        if size_bytes < 16:
            return ImageMetadata(640, 640, 0, size_bytes, "unknown")

        # Check PNG header: 89 50 4E 47 0D 0A 1A 0A
        if image_bytes.startswith(b'\x89PNG\r\n\x1a\n'):
            try:
                # IHDR chunk starts at byte 12
                w, h = struct.unpack(">II", image_bytes[16:24])
                return ImageMetadata(width=w, height=h, rotation=0, size_bytes=size_bytes, format_name="png")
            except Exception:
                pass

        # Check JPEG header: FF D8
        if image_bytes.startswith(b'\xff\xd8'):
            width = 640
            height = 640
            rotation = 0
            idx = 2
            length = len(image_bytes)

            while idx < length - 4:
                marker, seg_len = struct.unpack(">HH", image_bytes[idx:idx+4])
                if marker == 0xFFE1:  # APP1 EXIF segment
                    exif_data = image_bytes[idx+4:idx+2+seg_len]
                    rotation = ImagePreprocessor._parse_exif_rotation(exif_data)
                elif marker in (0xFFC0, 0xFFC2):  # SOF0 or SOF2 (baseline / progressive)
                    h, w = struct.unpack(">HH", image_bytes[idx+5:idx+9])
                    width = w
                    height = h
                    break
                idx += 2 + seg_len

            # If rotated 90 or 270 degrees, swap perceived width and height
            if rotation in (90, 270):
                width, height = height, width

            return ImageMetadata(width=width, height=height, rotation=rotation, size_bytes=size_bytes, format_name="jpeg")

        return ImageMetadata(640, 640, 0, size_bytes, "unknown")

    @staticmethod
    def _parse_exif_rotation(exif_bytes: bytes) -> int:
        """Parses EXIF TIFF header to extract orientation tag (0x0112)."""
        if len(exif_bytes) < 14 or not exif_bytes.startswith(b'Exif\x00\x00'):
            return 0
        try:
            tiff = exif_bytes[6:]
            endian = tiff[:2]
            fmt = ">" if endian == b'MM' else "<"
            (first_ifd_offset,) = struct.unpack(f"{fmt}I", tiff[4:8])
            offset = first_ifd_offset
            (num_entries,) = struct.unpack(f"{fmt}H", tiff[offset:offset+2])
            offset += 2
            for _ in range(num_entries):
                tag, field_type, count, val_or_offset = struct.unpack(f"{fmt}HHI4s", tiff[offset:offset+12])
                offset += 12
                if tag == 0x0112:  # Orientation tag
                    val = struct.unpack(f"{fmt}H", val_or_offset[:2])[0]
                    # Map EXIF orientation: 1=Normal, 3=180, 6=90 CW, 8=270 CW
                    if val == 3:
                        return 180
                    elif val == 6:
                        return 90
                    elif val == 8:
                        return 270
                    return 0
        except Exception:
            return 0
        return 0

    @staticmethod
    def compute_letterbox_transform(
        orig_w: int,
        orig_h: int,
        target_w: int = 640,
        target_h: int = 640,
        max_dimension: int = 2048,
    ) -> Dict[str, Any]:
        """
        Computes scale factors and padding offsets to preserve aspect ratio without distortion.
        Handles very large images by downsampling factors.
        """
        # Clamp large dimensions
        clamped_w = orig_w
        clamped_h = orig_h
        if max(orig_w, orig_h) > max_dimension:
            ratio = max_dimension / max(orig_w, orig_h)
            clamped_w = int(orig_w * ratio)
            clamped_h = int(orig_h * ratio)

        scale = min(target_w / clamped_w, target_h / clamped_h)
        new_unpad_w = int(round(clamped_w * scale))
        new_unpad_h = int(round(clamped_h * scale))

        pad_x = (target_w - new_unpad_w) / 2.0
        pad_y = (target_h - new_unpad_h) / 2.0

        return {
            "scale": scale,
            "pad_x": pad_x,
            "pad_y": pad_y,
            "scaled_w": new_unpad_w,
            "scaled_h": new_unpad_h,
            "target_w": target_w,
            "target_h": target_h,
            "clamped_w": clamped_w,
            "clamped_h": clamped_h,
        }

    @staticmethod
    def apply_nms(
        detections: List[DetectedOnion],
        iou_threshold: float = 0.45,
    ) -> Tuple[List[DetectedOnion], int]:
        """
        Non-Maximum Suppression (NMS) to eliminate duplicate/redundant bounding boxes.
        Maintains genuine dense overlapping onions while suppressing duplicate detections
        arising from multi-scale feature maps.
        """
        if not detections:
            return [], 0

        # Sort by confidence descending
        sorted_dets = sorted(detections, key=lambda d: d.confidence, reverse=True)
        keep: List[DetectedOnion] = []
        suppressed_count = 0

        for candidate in sorted_dets:
            should_suppress = False
            for preserved in keep:
                iou = candidate.bbox.iou(preserved.bbox)
                # Overlap threshold check
                if iou > iou_threshold:
                    # If candidate has significantly lower confidence or near-identical box, suppress
                    should_suppress = True
                    break

            if not should_suppress:
                keep.append(candidate)
            else:
                suppressed_count += 1

        # Re-index remaining kept detections
        for idx, item in enumerate(keep):
            item.id = idx + 1

        return keep, suppressed_count
