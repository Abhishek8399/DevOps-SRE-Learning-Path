"""Process entry point."""

from __future__ import annotations

import signal
import threading

from .app import AtlasServer
from .config import Settings
from .telemetry import log_event


def main() -> None:
    settings = Settings.from_environment()
    server = AtlasServer(settings)

    def stop(signum: int, _frame: object) -> None:
        log_event("shutdown_requested", signal=signum)
        threading.Thread(target=server.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    host, port = server.server_address
    log_event(
        "service_started",
        bind=host,
        port=port,
        version=settings.service_version,
        database=str(settings.database_path),
        fault_mode=settings.fault_mode,
        boundary="local-training-fixture-not-production",
    )
    try:
        server.serve_forever(poll_interval=0.2)
    finally:
        server.server_close()
        log_event("service_stopped")


if __name__ == "__main__":
    main()
