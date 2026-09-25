"""Unit tests for ImagePreprocessor."""
import unittest
import base64
import struct
from backend.app.services.image_preprocessor import ImagePreprocessor


def make_dummy_png_bytes(width: int, height: int) -> bytes:
    """Creates minimal valid PNG header with IHDR dimensions."""
    magic = b"\x89PNG\r\n\x1a\n"
    # IHDR chunk: 4 bytes length (13), 4 bytes type ('IHDR'), 4 bytes w, 4 bytes h, 5 bytes flags, 4 bytes crc
    ihdr_data = b"IHDR" + struct.pack(">II", width, height) + b"\x08\x02\x00\x00\x00"
    ihdr_chunk = struct.pack(">I", 13) + ihdr_data + b"\x00\x00\x00\x00"
    return magic + ihdr_chunk + b"\x00" * 32


class TestImagePreprocessor(unittest.TestCase):
    def test_dimensions_extraction_png(self):
        png = make_dummy_png_bytes(1280, 720)
        w, h, rot = ImagePreprocessor.extract_image_dimensions_and_rotation(png)
        self.assertEqual(w, 1280)
        self.assertEqual(h, 720)
        self.assertEqual(rot, 0)

    def test_aspect_ratio_preservation_and_letterbox(self):
        png = make_dummy_png_bytes(1920, 1080)
        meta = ImagePreprocessor.preprocess(png, target_size=(640, 640))

        # Check aspect ratio preservation
        orig_ratio = 1920 / 1080
        scaled_ratio = meta.scaled_width / meta.scaled_height
        self.assertAlmostEqual(orig_ratio, scaled_ratio, places=2)

        # Total canvas size with padding must equal target size 640
        self.assertEqual(meta.scaled_width + 2 * meta.pad_x, 640.0)
        self.assertEqual(meta.scaled_height + 2 * meta.pad_y, 640.0)
        self.assertEqual(meta.scaled_width, 640)
        self.assertGreater(meta.pad_y, 0)

    def test_bidirectional_coordinate_mapping(self):
        png = make_dummy_png_bytes(1920, 1080)
        meta = ImagePreprocessor.preprocess(png, target_size=(640, 640))

        # Test center point (0.5, 0.5) in letterbox space maps to center (0.5, 0.5) in original
        orig_x, orig_y = ImagePreprocessor.letterbox_to_original_coords(
            0.5, 0.5, meta, target_size=(640, 640)
        )
        self.assertAlmostEqual(orig_x, 0.5, places=2)
        self.assertAlmostEqual(orig_y, 0.5, places=2)

    def test_large_image_memory_guard(self):
        # 6000 x 4500 exceeds max_dimension 4096
        png = make_dummy_png_bytes(6000, 4500)
        meta = ImagePreprocessor.preprocess(png, max_dimension=4096)
        self.assertTrue(meta.is_downscaled_guard)
        self.assertLessEqual(max(meta.original_width, meta.original_height), 4096)

    def test_base64_data_uri_handling(self):
        raw = make_dummy_png_bytes(800, 600)
        b64_str = "data:image/png;base64," + base64.b64encode(raw).decode("utf-8")
        meta = ImagePreprocessor.preprocess(b64_str)
        self.assertEqual(meta.original_width, 800)
        self.assertEqual(meta.original_height, 600)


if __name__ == "__main__":
    unittest.main()
