"""SQLite state owner with explicit transaction and backup contracts."""

from __future__ import annotations

from contextlib import closing
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sqlite3
import uuid


class StorageUnavailable(RuntimeError):
    """The state owner cannot complete the requested operation."""


class IdempotencyConflict(ValueError):
    """An idempotency key was reused for a different request."""


@dataclass(frozen=True, slots=True)
class CreateResult:
    item: dict[str, str]
    created: bool


class Store:
    def __init__(self, database_path: Path) -> None:
        self.database_path = database_path

    def _connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(
            self.database_path,
            timeout=2.0,
            isolation_level=None,
        )
        connection.row_factory = sqlite3.Row
        connection.execute("PRAGMA foreign_keys = ON")
        connection.execute("PRAGMA busy_timeout = 2000")
        return connection

    def initialize(self) -> None:
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            with closing(self._connect()) as connection:
                connection.execute("PRAGMA journal_mode = WAL")
                connection.execute("PRAGMA synchronous = FULL")
                connection.executescript(
                    """
                    BEGIN IMMEDIATE;
                    CREATE TABLE IF NOT EXISTS schema_metadata (
                        singleton INTEGER PRIMARY KEY CHECK (singleton = 1),
                        schema_version INTEGER NOT NULL
                    );
                    INSERT INTO schema_metadata(singleton, schema_version)
                    VALUES (1, 1)
                    ON CONFLICT(singleton) DO NOTHING;
                    CREATE TABLE IF NOT EXISTS items (
                        id TEXT PRIMARY KEY,
                        name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 120),
                        created_at TEXT NOT NULL
                    );
                    CREATE TABLE IF NOT EXISTS idempotency_keys (
                        key TEXT PRIMARY KEY,
                        request_hash TEXT NOT NULL,
                        item_id TEXT NOT NULL REFERENCES items(id),
                        created_at TEXT NOT NULL
                    );
                    COMMIT;
                    """
                )
        except sqlite3.Error as exc:
            raise StorageUnavailable("database initialization failed") from exc

    def ready(self) -> bool:
        try:
            with closing(self._connect()) as connection:
                row = connection.execute(
                    "SELECT schema_version FROM schema_metadata WHERE singleton = 1"
                ).fetchone()
                return row is not None and row["schema_version"] == 1
        except sqlite3.Error:
            return False

    def list_items(self, limit: int = 100) -> list[dict[str, str]]:
        try:
            with closing(self._connect()) as connection:
                rows = connection.execute(
                    "SELECT id, name, created_at FROM items ORDER BY created_at, id LIMIT ?",
                    (limit,),
                ).fetchall()
        except sqlite3.Error as exc:
            raise StorageUnavailable("item read failed") from exc
        return [dict(row) for row in rows]

    def get_item(self, item_id: str) -> dict[str, str] | None:
        try:
            with closing(self._connect()) as connection:
                row = connection.execute(
                    "SELECT id, name, created_at FROM items WHERE id = ?",
                    (item_id,),
                ).fetchone()
        except sqlite3.Error as exc:
            raise StorageUnavailable("item read failed") from exc
        return dict(row) if row is not None else None

    def create_item(self, name: str, idempotency_key: str) -> CreateResult:
        canonical = json.dumps({"name": name}, sort_keys=True, separators=(",", ":"))
        request_hash = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
        now = datetime.now(timezone.utc).isoformat()
        item_id = str(uuid.uuid4())
        try:
            with closing(self._connect()) as connection:
                connection.execute("BEGIN IMMEDIATE")
                existing = connection.execute(
                    """
                    SELECT k.request_hash, i.id, i.name, i.created_at
                    FROM idempotency_keys AS k
                    JOIN items AS i ON i.id = k.item_id
                    WHERE k.key = ?
                    """,
                    (idempotency_key,),
                ).fetchone()
                if existing is not None:
                    if existing["request_hash"] != request_hash:
                        connection.execute("ROLLBACK")
                        raise IdempotencyConflict(
                            "idempotency key already represents a different request"
                        )
                    connection.execute("COMMIT")
                    return CreateResult(
                        item={
                            "id": existing["id"],
                            "name": existing["name"],
                            "created_at": existing["created_at"],
                        },
                        created=False,
                    )
                connection.execute(
                    "INSERT INTO items(id, name, created_at) VALUES (?, ?, ?)",
                    (item_id, name, now),
                )
                connection.execute(
                    """
                    INSERT INTO idempotency_keys(key, request_hash, item_id, created_at)
                    VALUES (?, ?, ?, ?)
                    """,
                    (idempotency_key, request_hash, item_id, now),
                )
                connection.execute("COMMIT")
                return CreateResult(
                    item={"id": item_id, "name": name, "created_at": now},
                    created=True,
                )
        except IdempotencyConflict:
            raise
        except sqlite3.Error as exc:
            raise StorageUnavailable("item transaction failed") from exc

    def item_count(self) -> int:
        try:
            with closing(self._connect()) as connection:
                row = connection.execute("SELECT COUNT(*) AS count FROM items").fetchone()
                return int(row["count"])
        except sqlite3.Error as exc:
            raise StorageUnavailable("item count failed") from exc

    def backup_to(self, destination: Path) -> None:
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            raise FileExistsError(f"backup destination already exists: {destination}")
        try:
            with closing(self._connect()) as source:
                with closing(sqlite3.connect(destination)) as target:
                    source.backup(target)
                    result = target.execute("PRAGMA integrity_check").fetchone()
                    if result is None or result[0] != "ok":
                        raise StorageUnavailable("backup integrity check failed")
        except (sqlite3.Error, StorageUnavailable) as exc:
            destination.unlink(missing_ok=True)
            if isinstance(exc, StorageUnavailable):
                raise
            raise StorageUnavailable("database backup failed") from exc
