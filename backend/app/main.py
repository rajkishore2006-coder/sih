"""
OnionSure AI Backend Application
Implements /api/analyze-heap, /api/health, and /api/model-info.
Designed with pure standard library support for zero-dependency portability and robust testability.
"""
import sys
import json
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from .services.heap_analyzer import HeapAnalyzer
from .services.model_loader import ModelLoader
from .config import ModelConfig

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("onionsure.api")

heap_analyzer = HeapAnalyzer()

def parse_multipart_form(body_bytes: bytes, content_type: str) -> tuple[bytes, str, dict]:
    """
    Parses multipart/form-data to extract uploaded file bytes and form fields.
    """
    if "boundary=" not in content_type:
        return body_bytes, "heap.jpg", {}

    boundary = content_type.split("boundary=")[1].strip()
    if boundary.startswith('"') and boundary.endswith('"'):
        boundary = boundary[1:-1]
    boundary_bytes = ("--" + boundary).encode("latin-1")

    parts = body_bytes.split(boundary_bytes)
    file_bytes = b""
    filename = "heap.jpg"
    fields = {}

    for part in parts:
        if not part or part == b"--\r\n" or part == b"--":
            continue
        if b"\r\n\r\n" in part:
            header_bytes, payload_bytes = part.split(b"\r\n\r\n", 1)
            # Remove trailing \r\n
            if payload_bytes.endswith(b"\r\n"):
                payload_bytes = payload_bytes[:-2]
            header_str = header_bytes.decode("latin-1", errors="ignore")

            if 'filename="' in header_str:
                fn_start = header_str.find('filename="') + 10
                fn_end = header_str.find('"', fn_start)
                if fn_end != -1:
                    filename = header_str[fn_start:fn_end]
                file_bytes = payload_bytes
            elif 'name="' in header_str:
                name_start = header_str.find('name="') + 6
                name_end = header_str.find('"', name_start)
                if name_end != -1:
                    field_name = header_str[name_start:name_end]
                    fields[field_name] = payload_bytes.decode("utf-8", errors="ignore")

    return file_bytes or body_bytes, filename, fields

class OnionSureRequestHandler(BaseHTTPRequestHandler):
    """HTTP Request Handler for OnionSure AI Services."""

    def _send_json(self, status_code: int, data: dict):
        response_bytes = json.dumps(data, indent=2).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-Include-Diagnostics, Authorization")
        self.send_header("Content-Length", str(len(response_bytes)))
        self.end_headers()
        self.wfile.write(response_bytes)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-Include-Diagnostics, Authorization")
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/")

        if path in ("/api/health", "/health"):
            model_info = ModelLoader.get_instance().get_model_info()
            self._send_json(200, {
                "status": "healthy",
                "service": "OnionSure AI Inspection Engine",
                "version": ModelConfig.MODEL_VERSION,
                "model": model_info,
            })
        elif path in ("/api/model-info", "/model-info"):
            self._send_json(200, ModelConfig.as_dict())
        else:
            self._send_json(404, {"error": "Endpoint not found", "path": path})

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/")

        if path in ("/api/analyze-heap", "/analyze-heap"):
            content_length = int(self.headers.get("Content-Length", 0))
            content_type = self.headers.get("Content-Type", "")

            if content_length <= 0:
                self._send_json(400, {"error": "Missing image file in request body."})
                return

            body_bytes = self.rfile.read(content_length)

            # Query params & header diagnostics check
            query_params = parse_qs(parsed.query)
            include_diag_query = query_params.get("include_diagnostics", ["false"])[0].lower() == "true"
            include_diag_header = self.headers.get("X-Include-Diagnostics", "").lower() == "true"
            include_diagnostics = include_diag_query or include_diag_header

            scenario_hint = query_params.get("scenario", ["auto"])[0]

            file_bytes, filename, fields = parse_multipart_form(body_bytes, content_type)
            if not file_bytes:
                self._send_json(400, {"error": "No valid image payload could be read."})
                return

            try:
                result = heap_analyzer.analyze(
                    image_bytes=file_bytes,
                    filename=filename,
                    include_diagnostics=include_diagnostics,
                    scenario_hint=scenario_hint,
                )
                self._send_json(200, result)
            except Exception as e:
                logger.error(f"Inference error: {e}", exc_info=True)
                self._send_json(500, {"error": f"Inference pipeline error: {str(e)}"})
        else:
            self._send_json(404, {"error": "Endpoint not found", "path": path})

def run_server(port: int = 8000, host: str = "0.0.0.0"):
    server_address = (host, port)
    httpd = HTTPServer(server_address, OnionSureRequestHandler)
    logger.info(f"OnionSure AI Server running on http://{host}:{port}/api/analyze-heap")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down OnionSure AI Server.")
        httpd.server_close()

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    run_server(port=port)
