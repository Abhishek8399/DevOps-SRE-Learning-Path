"""Validated runtime configuration."""

from __future__ import annotations

from dataclasses import dataclass
from ipaddress import ip_address
import os
from pathlib import Path


ALLOWED_FAULT_MODES = frozenset({"none", "latency", "readiness-failure", "write-failure"})


def _bounded_int(name: str, default: int, minimum: int, maximum: int) -> int:
    raw = os.environ.get(name, str(default))
    try:
        value = int(raw)
    except ValueError as exc:
        raise ValueError(f"{name} must be an integer") from exc
    if not minimum <= value <= maximum:
        raise ValueError(f"{name} must be between {minimum} and {maximum}")
    return value


def _boolean(name: str, default: bool = False) -> bool:
    raw = os.environ.get(name, str(default)).strip().lower()
    if raw not in {"true", "false"}:
        raise ValueError(f"{name} must be true or false")
    return raw == "true"


@dataclass(frozen=True, slots=True)
class Settings:
    bind: str
    port: int
    database_path: Path
    service_version: str
    fault_mode: str
    fault_delay_ms: int
    max_body_bytes: int

    @classmethod
    def from_environment(cls) -> "Settings":
        bind = os.environ.get("ATLAS_BIND", "127.0.0.1").strip()
        try:
            address = ip_address(bind)
        except ValueError as exc:
            raise ValueError("ATLAS_BIND must be an IP address, not a hostname") from exc
        if not address.is_loopback and not _boolean("ATLAS_ALLOW_NON_LOOPBACK"):
            raise ValueError(
                "non-loopback ATLAS_BIND requires ATLAS_ALLOW_NON_LOOPBACK=true"
            )

        database_path = Path(
            os.environ.get("ATLAS_DB_PATH", "var/atlas.db")
        ).expanduser()
        if not database_path.is_absolute():
            database_path = (Path.cwd() / database_path).resolve()
        if database_path.name in {"", ".", ".."}:
            raise ValueError("ATLAS_DB_PATH must name a database file")

        service_version = os.environ.get("ATLAS_VERSION", "dev").strip()
        if not service_version or len(service_version) > 64:
            raise ValueError("ATLAS_VERSION must contain 1 to 64 characters")

        fault_mode = os.environ.get("ATLAS_FAULT_MODE", "none").strip()
        if fault_mode not in ALLOWED_FAULT_MODES:
            allowed = ", ".join(sorted(ALLOWED_FAULT_MODES))
            raise ValueError(f"ATLAS_FAULT_MODE must be one of: {allowed}")

        return cls(
            bind=bind,
            port=_bounded_int("ATLAS_PORT", 8080, 0, 65535),
            database_path=database_path,
            service_version=service_version,
            fault_mode=fault_mode,
            fault_delay_ms=_bounded_int("ATLAS_FAULT_DELAY_MS", 400, 0, 2000),
            max_body_bytes=_bounded_int("ATLAS_MAX_BODY_BYTES", 16_384, 256, 1_048_576),
        )
