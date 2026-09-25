"""OnionSure Backend HTTP Application.

Exposes:
- POST /api/analyze-heap (Primary Heap Quality Analysis endpoint)
- GET  /api/models (List registered and active checkpoints)
- POST /api/models/switch (Switch checkpoint or register custom model)
- GET  /health (Service and inference health check)
"""
import json
import cgi
import io
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
from typing import Dict, Any, Tuple

from .config import settings
from .services.heap_analyzer import heap_analyzer
from .services.model_loader import model_loader


def handle_analyze_request(
    body_bytes: bytes,
    headers: Dict[str, str],
    query_params: Dict[str, str],
) -> Tuple[int, Dict[str, Any]]:
    """Core handler for /api/analyze-heap."""
    content_type = headers.get("content-type", "")
    include_diagnostics = (
        query_params.get("include_diagnostics", "").lower() in ("true", "1")
        or headers.get("x-include-diagnostics", "").lower() == "true"
        or settings.enable_diagnostics_default
    )

    image_data: str = ""
    scenario_hint = query_params.get("scenario")

    if "multipart/form-data" in content_type:
        try:
            # Parse multipart body
            fp = io.BytesIO(body_bytes)
            environ = {
                "REQUEST_METHOD": "POST",
                "CONTENT_TYPE": content_type,
                "CONTENT_LENGTH": str(len(body_bytes)),
            }
            form = cgi.FieldStorage(fp=fp, environ=environ, keep_blank_values=True)
            if "file" in form:
                file_item = form["file"]
                image_data = file_item.file.read()
            elif "image" in form:
                image_data = form["image"].value
            else:
                image_data = body_bytes
        except Exception:
            image_data = body_bytes
    elif "application/json" in content_type:
        try:
            payload = json.loads(body_bytes.decode("utf-8"))
            image_data = payload.get("image", "")
            if not scenario_hint:
                scenario_hint = payload.get("scenario")
            if "include_diagnostics" in payload:
                include_diagnostics = bool(payload["include_diagnostics"])
        except Exception:
            return 400, {"error": "Invalid JSON body"}
    else:
        # Raw bytes or text
        image_data = body_bytes

    if not image_data:
        image_data = "placeholder_sample_bytes"

    try:
        result = heap_analyzer.analyze(
            image_bytes_or_base64=image_data,
            include_diagnostics=include_diagnostics,
            scenario_hint=scenario_hint,
        )
        return 200, result.to_dict()
    except Exception as e:
        return 500, {"error": f"Analysis failed: {str(e)}"}


class OnionSureRequestHandler(BaseHTTPRequestHandler):
    """HTTP Request Handler for OnionSure API."""

    def _send_json(self, status: int, data: Dict[str, Any]):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-Include-Diagnostics")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode("utf-8"))

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-Include-Diagnostics")
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == "/health":
            active_m = model_loader.get_active_model()
            self._send_json(200, {
                "status": "healthy",
                "service": "OnionSure AI Inference Engine",
                "active_model": active_m.name,
                "version": active_m.version,
                "checkpoint": active_m.checkpoint_path,
                "is_onion_specific": active_m.is_onion_specific,
            })
        elif path == "/api/models":
            self._send_json(200, {
                "models": model_loader.list_available_models(),
                "active_model": model_loader.get_active_model().name,
            })
        else:
            self._send_json(404, {"error": "Not Found"})

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = dict(urllib.parse.parse_qsl(parsed.query))

        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else b""

        headers_dict = {k.lower(): v for k, v in self.headers.items()}

        if path == "/api/analyze-heap":
            status, resp = handle_analyze_request(body, headers_dict, query)
            self._send_json(status, resp)
        elif path == "/api/models/switch":
            try:
                payload = json.loads(body.decode("utf-8"))
                target = payload.get("model_name") or payload.get("model_path")
                version = payload.get("version")
                if not target:
                    self._send_json(400, {"error": "Missing model_name or model_path"})
                    return
                updated = model_loader.switch_model(target, version)
                self._send_json(200, {
                    "status": "success",
                    "active_model": updated.name,
                    "version": updated.version,
                    "is_onion_specific": updated.is_onion_specific,
                })
            except Exception as e:
                self._send_json(500, {"error": str(e)})
        else:
            self._send_json(404, {"error": "Not Found"})


def run_server(port: int = 8000):
    server_address = ("0.0.0.0", port)
    httpd = HTTPServer(server_address, OnionSureRequestHandler)
    print(f"OnionSure AI Server running on port {port}...")
    httpd.serve_forever()


if __name__ == "__main__":
    run_server()
