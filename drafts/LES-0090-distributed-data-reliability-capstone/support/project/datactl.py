#!/usr/bin/env python3
"""Bounded control surface for the local distributed-data capstone."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any, Sequence

PROJECT_ROOT = Path(__file__).resolve().parent
SCHEMA_PATH = PROJECT_ROOT / "sql" / "schema.sql"
TOPIC = "orders.v1"

EXPECTED_CONTAINERS = {
    "atlas-data-postgres": (
        "postgres:18.4-bookworm@sha256:"
        "882236b897e39051d2368c5ccc6cda944904723506b2dfc97f2a8f5bc9afa382"
    ),
    "atlas-data-redis": (
        "redis:8.6.5-alpine3.23@sha256:"
        "cd218f4b106a332c5c992e38a9480bfb9d7e9f8f7b0ec9a0023bfa36d9a408f9"
    ),
    "atlas-data-kafka": (
        "apache/kafka:4.3.1@sha256:"
        "77e3df9054047a88b520d0cc46e16696d3b22022e1d580aeccd2632df6532837"
    ),
}
EXPECTED_VOLUMES = {
    "atlas-data-postgres-data": "postgres-data",
    "atlas-data-kafka-data": "kafka-data",
}
COMPOSE_PROJECT = "atlas-data-capstone"

ORDER_FIELDS = {
    "schema_version",
    "order_id",
    "idempotency_key",
    "customer_ref",
    "amount_cents",
}
ORDER_ID = re.compile(r"^ord-[a-z0-9]{8,32}$")
IDEMPOTENCY_KEY = re.compile(r"^idem-[a-z0-9]{8,48}$")
CUSTOMER_REF = re.compile(r"^cust-[a-z0-9]{8,32}$")


class ContractError(ValueError):
    """The caller supplied an unsupported or ambiguous contract."""


class RuntimeBoundaryError(RuntimeError):
    """The fixed local runtime does not match its reviewed descriptor."""


def canonical_json(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)


def validate_order(document: Any) -> dict[str, Any]:
    if not isinstance(document, dict):
        raise ContractError("order must be a JSON object")
    unknown = set(document) - ORDER_FIELDS
    missing = ORDER_FIELDS - set(document)
    if unknown or missing:
        raise ContractError(
            f"order fields invalid: missing={sorted(missing)} unknown={sorted(unknown)}"
        )
    if document["schema_version"] != 1:
        raise ContractError("schema_version must equal 1")
    if not isinstance(document["order_id"], str) or not ORDER_ID.fullmatch(
        document["order_id"]
    ):
        raise ContractError("order_id must match ord-[a-z0-9]{8,32}")
    if not isinstance(document["idempotency_key"], str) or not IDEMPOTENCY_KEY.fullmatch(
        document["idempotency_key"]
    ):
        raise ContractError("idempotency_key must match idem-[a-z0-9]{8,48}")
    if not isinstance(document["customer_ref"], str) or not CUSTOMER_REF.fullmatch(
        document["customer_ref"]
    ):
        raise ContractError("customer_ref must match cust-[a-z0-9]{8,32}")
    amount = document["amount_cents"]
    if isinstance(amount, bool) or not isinstance(amount, int):
        raise ContractError("amount_cents must be an integer")
    if not 1 <= amount <= 100_000_000:
        raise ContractError("amount_cents must be between 1 and 100000000")

    normalized = dict(document)
    normalized["payload_hash"] = hashlib.sha256(
        canonical_json(document).encode("ascii")
    ).hexdigest()
    return normalized


def sql_for_order(document: dict[str, Any]) -> str:
    encoded = base64.b64encode(canonical_json(document).encode("ascii")).decode("ascii")
    if not re.fullmatch(r"[A-Za-z0-9+/=]+", encoded):
        raise AssertionError("base64 encoder produced unexpected characters")
    return (
        "SELECT atlas.submit_order("
        f"convert_from(decode('{encoded}','base64'),'UTF8')::jsonb"
        ");"
    )


def load_request(path: Path) -> Any:
    allowed_root = (PROJECT_ROOT / "requests").resolve(strict=True)
    if path.is_symlink():
        raise ContractError("request path must not be a symlink")
    resolved = path.resolve(strict=True)
    try:
        resolved.relative_to(allowed_root)
    except ValueError as error:
        raise ContractError("request path must remain under project requests/") from error
    if not resolved.is_file():
        raise ContractError("request path must be a regular file")
    return json.loads(resolved.read_text(encoding="utf-8"))


def run(
    arguments: Sequence[str],
    *,
    input_text: str | None = None,
    timeout: int = 60,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(arguments),
        input=input_text,
        text=True,
        encoding="utf-8",
        errors="strict",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
        check=False,
    )


def require_success(
    result: subprocess.CompletedProcess[str], operation: str
) -> subprocess.CompletedProcess[str]:
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip() or "no diagnostic"
        raise RuntimeBoundaryError(f"{operation} failed ({result.returncode}): {detail}")
    return result


def inspect_runtime() -> list[dict[str, Any]]:
    result = require_success(
        run(["docker", "inspect", *EXPECTED_CONTAINERS], timeout=30),
        "docker inspect",
    )
    records = json.loads(result.stdout)
    by_name = {record["Name"].lstrip("/"): record for record in records}
    for name, image in EXPECTED_CONTAINERS.items():
        record = by_name.get(name)
        if record is None:
            raise RuntimeBoundaryError(f"missing expected container {name}")
        if record["Config"]["Image"] != image:
            raise RuntimeBoundaryError(f"image mismatch for {name}")
        if record["HostConfig"]["NetworkMode"] != "none":
            raise RuntimeBoundaryError(f"network boundary mismatch for {name}")
        if not record["State"]["Running"]:
            raise RuntimeBoundaryError(f"container is not running: {name}")
        health = record["State"].get("Health", {}).get("Status")
        if health != "healthy":
            raise RuntimeBoundaryError(f"container is not healthy: {name} ({health})")
    return records


def listed_resources(command: Sequence[str]) -> set[str]:
    result = require_success(run(command, timeout=30), "Docker resource listing")
    return {line.strip() for line in result.stdout.splitlines() if line.strip()}


def inspect_cleanup_boundary() -> None:
    containers = listed_resources(
        [
            "docker",
            "ps",
            "-a",
            "--filter",
            f"label=com.docker.compose.project={COMPOSE_PROJECT}",
            "--format",
            "{{.Names}}",
        ]
    )
    if containers != set(EXPECTED_CONTAINERS):
        raise RuntimeBoundaryError(
            f"project container set mismatch: observed={sorted(containers)}"
        )
    volumes = listed_resources(
        [
            "docker",
            "volume",
            "ls",
            "--filter",
            f"label=com.docker.compose.project={COMPOSE_PROJECT}",
            "--format",
            "{{.Name}}",
        ]
    )
    if volumes != set(EXPECTED_VOLUMES):
        raise RuntimeBoundaryError(
            f"project volume set mismatch: observed={sorted(volumes)}"
        )
    inspect_runtime()
    volume_result = require_success(
        run(["docker", "volume", "inspect", *EXPECTED_VOLUMES], timeout=30),
        "Docker volume inspection",
    )
    for record in json.loads(volume_result.stdout):
        name = record["Name"]
        labels = record.get("Labels") or {}
        if labels.get("com.docker.compose.project") != COMPOSE_PROJECT:
            raise RuntimeBoundaryError(f"volume project mismatch: {name}")
        if labels.get("com.docker.compose.volume") != EXPECTED_VOLUMES[name]:
            raise RuntimeBoundaryError(f"volume logical-name mismatch: {name}")


def postgres(sql: str, *, timeout: int = 60) -> str:
    result = require_success(
        run(
            [
                "docker",
                "exec",
                "-i",
                "atlas-data-postgres",
                "psql",
                "-X",
                "-v",
                "ON_ERROR_STOP=1",
                "-U",
                "atlas",
                "-d",
                "atlas",
                "-At",
            ],
            input_text=sql,
            timeout=timeout,
        ),
        "PostgreSQL operation",
    )
    return result.stdout.strip()


def kafka(arguments: Sequence[str], *, timeout: int = 60) -> str:
    result = require_success(
        run(
            [
                "docker",
                "exec",
                "atlas-data-kafka",
                "/opt/kafka/bin/kafka-topics.sh",
                "--bootstrap-server",
                "127.0.0.1:9092",
                *arguments,
            ],
            timeout=timeout,
        ),
        "Kafka operation",
    )
    return result.stdout.strip()


def command_check(path: Path) -> None:
    document = load_request(path)
    normalized = validate_order(document)
    print(
        f"request=valid order_id={normalized['order_id']} "
        f"payload_sha256={normalized['payload_hash']}"
    )


def command_init() -> None:
    inspect_runtime()
    postgres(SCHEMA_PATH.read_text(encoding="utf-8"), timeout=90)
    kafka(
        [
            "--create",
            "--if-not-exists",
            "--topic",
            TOPIC,
            "--partitions",
            "3",
            "--replication-factor",
            "1",
        ],
        timeout=90,
    )
    print("init=pass schema=atlas topic=orders.v1 partitions=3")


def command_submit(path: Path) -> None:
    inspect_runtime()
    normalized = validate_order(load_request(path))
    outcome = postgres(sql_for_order(normalized))
    print(f"submit=pass outcome={outcome}")


def command_status() -> None:
    inspect_runtime()
    counts = postgres(
        "SELECT jsonb_build_object("
        "'orders', (SELECT count(*) FROM atlas.orders),"
        "'outbox', (SELECT count(*) FROM atlas.outbox),"
        "'unpublished', (SELECT count(*) FROM atlas.outbox WHERE NOT published),"
        "'inbox', (SELECT count(*) FROM atlas.consumer_inbox),"
        "'facts', (SELECT count(*) FROM atlas.order_facts),"
        "'quarantine', (SELECT count(*) FROM atlas.quarantine)"
        ");"
    )
    topic = kafka(["--describe", "--topic", TOPIC])
    print(f"status=pass counts={counts}")
    print(topic)


def command_cleanup() -> None:
    inspect_cleanup_boundary()
    result = require_success(
        run(
            [
                "docker",
                "compose",
                "--env-file",
                str(PROJECT_ROOT / "toolchain.env"),
                "-f",
                str(PROJECT_ROOT / "compose.yaml"),
                "down",
                "--volumes",
                "--remove-orphans",
            ],
            timeout=120,
        ),
        "exact Compose cleanup",
    )
    remaining_containers = listed_resources(
        [
            "docker",
            "ps",
            "-a",
            "--filter",
            f"label=com.docker.compose.project={COMPOSE_PROJECT}",
            "--format",
            "{{.Names}}",
        ]
    )
    remaining_volumes = listed_resources(
        [
            "docker",
            "volume",
            "ls",
            "--filter",
            f"label=com.docker.compose.project={COMPOSE_PROJECT}",
            "--format",
            "{{.Name}}",
        ]
    )
    if remaining_containers or remaining_volumes:
        raise RuntimeBoundaryError(
            "cleanup incomplete: "
            f"containers={sorted(remaining_containers)} volumes={sorted(remaining_volumes)}"
        )
    if result.stderr.strip():
        print(result.stderr.strip(), file=sys.stderr)
    print("cleanup=pass containers=absent volumes=absent")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    commands = result.add_subparsers(dest="command", required=True)
    check = commands.add_parser("check")
    check.add_argument("request", type=Path)
    commands.add_parser("init")
    submit = commands.add_parser("submit")
    submit.add_argument("request", type=Path)
    commands.add_parser("status")
    commands.add_parser("cleanup")
    return result


def main() -> int:
    arguments = parser().parse_args()
    try:
        if arguments.command == "check":
            command_check(arguments.request)
        elif arguments.command == "init":
            command_init()
        elif arguments.command == "submit":
            command_submit(arguments.request)
        elif arguments.command == "status":
            command_status()
        elif arguments.command == "cleanup":
            command_cleanup()
        else:
            raise AssertionError(f"unhandled command {arguments.command}")
    except (
        ContractError,
        RuntimeBoundaryError,
        OSError,
        json.JSONDecodeError,
        subprocess.TimeoutExpired,
    ) as error:
        print(f"error={error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
