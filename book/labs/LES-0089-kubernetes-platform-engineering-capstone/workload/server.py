#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

VERSION = "1.0.0"
LOCK = threading.Lock()
REQUESTS: dict[tuple[str, int], int] = {}


class Handler(BaseHTTPRequestHandler):
    server_version = "AtlasPlatformDemo/1.0"

    def do_GET(self) -> None:
        routes = {
            "/": (200, {"service": "payments-api", "version": VERSION, "status": "ok"}),
            "/livez": (200, {"status": "live"}),
            "/readyz": (200, {"status": "ready"}),
            "/version": (200, {"version": VERSION}),
        }
        if self.path == "/metrics":
            with LOCK:
                lines = [
                    "# HELP atlas_http_requests_total Bounded requests handled by route and status.",
                    "# TYPE atlas_http_requests_total counter",
                    *[
                        f'atlas_http_requests_total{{route="{route}",status="{status}"}} {count}'
                        for (route, status), count in sorted(REQUESTS.items())
                    ],
                ]
            status = 200
            payload = ("\n".join(lines) + "\n").encode()
            content_type = "text/plain; version=0.0.4"
        else:
            status, body = routes.get(self.path, (404, {"error": "not_found"}))
            payload = json.dumps(body, sort_keys=True).encode()
            content_type = "application/json"
        route = self.path if self.path in routes or self.path == "/metrics" else "other"
        with LOCK:
            REQUESTS[(route, status)] = REQUESTS.get((route, status), 0) + 1
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args: object) -> None:
        print(json.dumps({"event": "http_request", "client": self.client_address[0], "message": format % args}))


def main() -> None:
    port = int(os.environ.get("PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(json.dumps({"event": "startup", "port": port, "version": VERSION}))
    server.serve_forever()


if __name__ == "__main__":
    main()
