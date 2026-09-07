from __future__ import annotations

from dataclasses import replace
import http.client
import json
from pathlib import Path
import tempfile
import threading
import unittest

from atlas_service.app import AtlasServer
from atlas_service.config import Settings


class HttpTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.settings = Settings(
            bind="127.0.0.1",
            port=0,
            database_path=Path(self.temp.name) / "state.db",
            service_version="test-1",
            fault_mode="none",
            fault_delay_ms=1,
            max_body_bytes=16_384,
        )
        self.server = AtlasServer(self.settings)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.port = self.server.server_address[1]

    def tearDown(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.temp.cleanup()

    def request(
        self,
        method: str,
        path: str,
        body: dict[str, object] | None = None,
        headers: dict[str, str] | None = None,
    ) -> tuple[int, dict[str, str], bytes]:
        connection = http.client.HTTPConnection("127.0.0.1", self.port, timeout=2)
        encoded = json.dumps(body).encode() if body is not None else None
        request_headers = dict(headers or {})
        if body is not None:
            request_headers["Content-Type"] = "application/json"
        connection.request(method, path, body=encoded, headers=request_headers)
        response = connection.getresponse()
        response_body = response.read()
        response_headers = {key.lower(): value for key, value in response.getheaders()}
        connection.close()
        return response.status, response_headers, response_body

    def test_health_create_replay_conflict_and_metrics(self) -> None:
        status, _, _ = self.request("GET", "/livez")
        self.assertEqual(status, 200)
        status, _, _ = self.request("GET", "/readyz")
        self.assertEqual(status, 200)

        headers = {"Idempotency-Key": "integration-key-0001", "X-Request-ID": "req-1"}
        status, response_headers, first_body = self.request(
            "POST", "/api/v1/items", {"name": "alpha"}, headers
        )
        self.assertEqual(status, 201)
        self.assertEqual(response_headers["idempotency-replayed"], "false")
        self.assertEqual(response_headers["x-request-id"], "req-1")

        status, response_headers, replay_body = self.request(
            "POST", "/api/v1/items", {"name": "alpha"}, headers
        )
        self.assertEqual(status, 200)
        self.assertEqual(response_headers["idempotency-replayed"], "true")
        self.assertEqual(first_body, replay_body)

        status, _, body = self.request(
            "POST", "/api/v1/items", {"name": "different"}, headers
        )
        self.assertEqual(status, 409)
        self.assertEqual(json.loads(body)["error"], "idempotency_conflict")

        status, _, body = self.request("GET", "/api/v1/items")
        self.assertEqual(status, 200)
        self.assertEqual(len(json.loads(body)["items"]), 1)

        status, _, body = self.request("GET", "/metrics")
        self.assertEqual(status, 200)
        text = body.decode()
        self.assertIn("atlas_http_requests_total", text)
        self.assertNotIn("integration-key-0001", text)

    def test_readiness_fault_does_not_change_liveness(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.server = AtlasServer(replace(self.settings, port=0, fault_mode="readiness-failure"))
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.port = self.server.server_address[1]
        status, _, _ = self.request("GET", "/livez")
        self.assertEqual(status, 200)
        status, _, _ = self.request("GET", "/readyz")
        self.assertEqual(status, 503)

    def test_write_fault_returns_bounded_error(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.server = AtlasServer(replace(self.settings, port=0, fault_mode="write-failure"))
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.port = self.server.server_address[1]
        status, _, body = self.request(
            "POST",
            "/api/v1/items",
            {"name": "alpha"},
            {"Idempotency-Key": "integration-key-0002"},
        )
        self.assertEqual(status, 503)
        self.assertEqual(json.loads(body), {"error": "storage_unavailable"})


if __name__ == "__main__":
    unittest.main()
