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
import uuid
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
EVENT_FIELDS = {
    "schema_version",
    "event_id",
    "event_type",
    "order_id",
    "customer_ref",
    "amount_cents",
    "occurred_at",
}
ORDER_ID = re.compile(r"^ord-[a-z0-9]{8,32}$")
IDEMPOTENCY_KEY = re.compile(r"^idem-[a-z0-9]{8,48}$")
CUSTOMER_REF = re.compile(r"^cust-[a-z0-9]{8,32}$")
EVENT_ID = re.compile(r"^evt-[a-f0-9]{24}$")
DELIVERY_LINE = re.compile(
    r"^Partition:(?P<partition>[0-9]+)\|"
    r"Offset:(?P<offset>[0-9]+)\|"
    r"(?P<key>evt-[a-f0-9]{24})\|(?P<payload>\{.*\})$"
)
END_OFFSET_LINE = re.compile(
    r"^orders\.v1:(?P<partition>[0-9]+):(?P<end_offset>[0-9]+)$"
)


class ContractError(ValueError):
    """The caller supplied an unsupported or ambiguous contract."""


class RuntimeBoundaryError(RuntimeError):
    """The fixed local runtime does not match its reviewed descriptor."""


def canonical_json(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)


def kafka_murmur2(data: bytes) -> int:
    """Return Kafka's unsigned murmur2 key hash."""
    length = len(data)
    value = 0x9747B28C ^ length
    index = 0
    while length >= 4:
        chunk = (
            data[index]
            | (data[index + 1] << 8)
            | (data[index + 2] << 16)
            | (data[index + 3] << 24)
        )
        chunk = (chunk * 0x5BD1E995) & 0xFFFFFFFF
        chunk ^= chunk >> 24
        chunk = (chunk * 0x5BD1E995) & 0xFFFFFFFF
        value = (value * 0x5BD1E995) & 0xFFFFFFFF
        value ^= chunk
        index += 4
        length -= 4
    if length == 3:
        value ^= data[index + 2] << 16
    if length >= 2:
        value ^= data[index + 1] << 8
    if length >= 1:
        value ^= data[index]
        value = (value * 0x5BD1E995) & 0xFFFFFFFF
    value ^= value >> 13
    value = (value * 0x5BD1E995) & 0xFFFFFFFF
    value ^= value >> 15
    return value & 0xFFFFFFFF


def kafka_partition(key: str, partition_count: int = 3) -> int:
    if partition_count <= 0:
        raise ValueError("partition_count must be positive")
    return (kafka_murmur2(key.encode("utf-8")) & 0x7FFFFFFF) % partition_count


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


def validate_event(document: Any) -> dict[str, Any]:
    if not isinstance(document, dict) or set(document) != EVENT_FIELDS:
        raise ContractError("event fields invalid")
    if document["schema_version"] != 1:
        raise ContractError("event schema version unsupported")
    if document["event_type"] != "order.accepted.v1":
        raise ContractError("event type unsupported")
    if not isinstance(document["event_id"], str) or not EVENT_ID.fullmatch(
        document["event_id"]
    ):
        raise ContractError("event identity invalid")
    if not isinstance(document["order_id"], str) or not ORDER_ID.fullmatch(
        document["order_id"]
    ):
        raise ContractError("event order identity invalid")
    if not isinstance(document["customer_ref"], str) or not CUSTOMER_REF.fullmatch(
        document["customer_ref"]
    ):
        raise ContractError("event customer reference invalid")
    amount = document["amount_cents"]
    if isinstance(amount, bool) or not isinstance(amount, int) or amount <= 0:
        raise ContractError("event amount invalid")
    if not isinstance(document["occurred_at"], str) or len(document["occurred_at"]) > 64:
        raise ContractError("event timestamp invalid")
    return document


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


def inspect_runtime(*, require_healthy: bool = True) -> list[dict[str, Any]]:
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
        labels = record["Config"].get("Labels") or {}
        if labels.get("com.docker.compose.project") != COMPOSE_PROJECT:
            raise RuntimeBoundaryError(f"project ownership mismatch for {name}")
        if require_healthy:
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
    inspect_runtime(require_healthy=False)
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
                "-q",
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


def kafka_produce(event_id: str, payload: dict[str, Any]) -> None:
    if not EVENT_ID.fullmatch(event_id):
        raise RuntimeBoundaryError("database returned an invalid event identity")
    line = f"{event_id}|{canonical_json(payload)}\n"
    require_success(
        run(
            [
                "docker",
                "exec",
                "-i",
                "atlas-data-kafka",
                "/opt/kafka/bin/kafka-console-producer.sh",
                "--bootstrap-server",
                "127.0.0.1:9092",
                "--topic",
                TOPIC,
                "--producer-property",
                "acks=all",
                "--property",
                "parse.key=true",
                "--property",
                "key.separator=|",
            ],
            input_text=line,
            timeout=60,
        ),
        "Kafka publish",
    )


def kafka_end_offsets() -> dict[int, int]:
    result = require_success(
        run(
            [
                "docker",
                "exec",
                "atlas-data-kafka",
                "/opt/kafka/bin/kafka-get-offsets.sh",
                "--bootstrap-server",
                "127.0.0.1:9092",
                "--topic",
                TOPIC,
            ],
            timeout=60,
        ),
        "Kafka end-offset read",
    )
    offsets: dict[int, int] = {}
    for line in result.stdout.splitlines():
        match = END_OFFSET_LINE.fullmatch(line.strip())
        if not match:
            raise RuntimeBoundaryError(f"unrecognized Kafka end offset: {line!r}")
        offsets[int(match.group("partition"))] = int(match.group("end_offset"))
    if set(offsets) != {0, 1, 2}:
        raise RuntimeBoundaryError(
            f"Kafka partition set mismatch: observed={sorted(offsets)}"
        )
    return offsets


def kafka_records() -> list[dict[str, Any]]:
    result = require_success(
        run(
            [
                "docker",
                "exec",
                "atlas-data-kafka",
                "/opt/kafka/bin/kafka-console-consumer.sh",
                "--bootstrap-server",
                "127.0.0.1:9092",
                "--topic",
                TOPIC,
                "--from-beginning",
                "--timeout-ms",
                "5000",
                "--formatter-property",
                "print.partition=true",
                "--formatter-property",
                "print.offset=true",
                "--formatter-property",
                "print.key=true",
                "--formatter-property",
                "print.value=true",
                "--formatter-property",
                "key.separator=|",
                "--max-messages",
                "1000",
            ],
            timeout=60,
        ),
        "Kafka bounded read",
    )
    records = []
    for line in result.stdout.splitlines():
        match = DELIVERY_LINE.fullmatch(line.strip())
        if not match:
            raise RuntimeBoundaryError(f"unrecognized Kafka record: {line!r}")
        payload = json.loads(match.group("payload"))
        if not isinstance(payload, dict):
            raise RuntimeBoundaryError("Kafka event payload must be an object")
        key = match.group("key")
        if payload.get("event_id") != key:
            raise RuntimeBoundaryError("Kafka key and payload event identity differ")
        records.append(
            {
                "source_partition": int(match.group("partition")),
                "source_offset": int(match.group("offset")),
                "key": key,
                "payload": payload,
            }
        )
    return records


def sql_for_delivery(record: dict[str, Any]) -> str:
    payload = record["payload"]
    document = {
        "source_partition": record["source_partition"],
        "source_offset": record["source_offset"],
        "payload_hash": hashlib.sha256(
            canonical_json(payload).encode("ascii")
        ).hexdigest(),
        "event": payload,
    }
    encoded = base64.b64encode(canonical_json(document).encode("ascii")).decode("ascii")
    return (
        "SELECT atlas.process_event("
        f"convert_from(decode('{encoded}','base64'),'UTF8')::jsonb"
        ");"
    )


def quarantine_delivery(record: dict[str, Any], reason_code: str) -> None:
    if reason_code not in {"event_contract_invalid"}:
        raise AssertionError("unknown quarantine reason")
    payload_hash = hashlib.sha256(
        canonical_json(record["payload"]).encode("ascii")
    ).hexdigest()
    event_id = record["key"]
    outcome = postgres(
        "INSERT INTO atlas.quarantine("
        "source_partition,source_offset,event_id,raw_hash,reason_code,observed_at"
        ") VALUES ("
        f"{record['source_partition']},{record['source_offset']},'{event_id}',"
        f"'{payload_hash}','{reason_code}',clock_timestamp()"
        ") ON CONFLICT (source_partition,source_offset,raw_hash) DO NOTHING "
        "RETURNING quarantine_id;"
    )
    if outcome and not outcome.isdigit():
        raise RuntimeBoundaryError("quarantine receipt is invalid")


def update_cache(event: dict[str, Any]) -> None:
    order_id = event.get("order_id")
    if not isinstance(order_id, str) or not ORDER_ID.fullmatch(order_id):
        raise RuntimeBoundaryError("event order identity is invalid")
    result = require_success(
        run(
            [
                "docker",
                "exec",
                "atlas-data-redis",
                "redis-cli",
                "-h",
                "127.0.0.1",
                "SET",
                f"order:{order_id}",
                canonical_json(event),
                "EX",
                "300",
            ],
            timeout=30,
        ),
        "Redis cache update",
    )
    if result.stdout.strip() != "OK":
        raise RuntimeBoundaryError("Redis cache update returned an unexpected receipt")


def command_check(path: Path) -> None:
    document = load_request(path)
    normalized = validate_order(document)
    print(
        f"request=valid order_id={normalized['order_id']} "
        f"payload_sha256={normalized['payload_hash']}"
    )


def command_up() -> None:
    fixed_containers = listed_resources(
        ["docker", "ps", "-a", "--format", "{{.Names}}"]
    ) & set(EXPECTED_CONTAINERS)
    fixed_volumes = listed_resources(
        ["docker", "volume", "ls", "--format", "{{.Name}}"]
    ) & set(EXPECTED_VOLUMES)
    project_containers = listed_resources(
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
    project_volumes = listed_resources(
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
    if fixed_containers or fixed_volumes or project_containers or project_volumes:
        raise RuntimeBoundaryError(
            "fresh runtime required: "
            f"containers={sorted(fixed_containers | project_containers)} "
            f"volumes={sorted(fixed_volumes | project_volumes)}"
        )
    require_success(
        run(
            [
                "docker",
                "compose",
                "--env-file",
                str(PROJECT_ROOT / "toolchain.env"),
                "-f",
                str(PROJECT_ROOT / "compose.yaml"),
                "up",
                "-d",
                "--wait",
            ],
            timeout=180,
        ),
        "Compose startup",
    )
    inspect_runtime()
    print("up=pass containers=3 network=none images=pinned health=healthy")


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


def command_relay(*, stop_after_publish: bool) -> int:
    inspect_runtime()
    raw = postgres(
        "SELECT jsonb_build_object("
        "'event_id', event_id, 'payload', event_payload"
        ") FROM atlas.outbox WHERE NOT published "
        "ORDER BY created_at, event_id LIMIT 1;"
    )
    if not raw:
        print("relay=idle unpublished=0")
        return 0
    envelope = json.loads(raw)
    if set(envelope) != {"event_id", "payload"}:
        raise RuntimeBoundaryError("outbox envelope fields are invalid")
    event_id = envelope["event_id"]
    payload = envelope["payload"]
    if not isinstance(event_id, str) or not isinstance(payload, dict):
        raise RuntimeBoundaryError("outbox envelope types are invalid")
    kafka_produce(event_id, payload)
    if stop_after_publish:
        print(f"relay=interrupted event_id={event_id} outbox_ack=false")
        return 75
    acknowledged = postgres(
        "UPDATE atlas.outbox SET published=true, published_at=clock_timestamp() "
        f"WHERE event_id='{event_id}' AND NOT published RETURNING event_id;"
    )
    if acknowledged != event_id:
        raise RuntimeBoundaryError("outbox acknowledgement lost ownership")
    print(f"relay=pass event_id={event_id} outbox_ack=true")
    return 0


def command_consume() -> None:
    inspect_runtime()
    records = kafka_records()
    new_count = 0
    duplicate_count = 0
    quarantine_count = 0
    for record in records:
        try:
            validate_event(record["payload"])
        except ContractError:
            quarantine_delivery(record, "event_contract_invalid")
            quarantine_count += 1
            continue
        raw = postgres(sql_for_delivery(record))
        outcome = json.loads(raw)
        if set(outcome) != {"duplicate", "event_id", "order_id"}:
            raise RuntimeBoundaryError("consumer receipt fields are invalid")
        if outcome["event_id"] != record["key"]:
            raise RuntimeBoundaryError("consumer receipt event identity differs")
        if outcome["duplicate"] is True:
            duplicate_count += 1
        elif outcome["duplicate"] is False:
            new_count += 1
        else:
            raise RuntimeBoundaryError("consumer duplicate receipt is not boolean")
        update_cache(record["payload"])
    print(
        f"consume=pass records={len(records)} new={new_count} "
        f"duplicates={duplicate_count} quarantined={quarantine_count} "
        "cache=converged"
    )


def command_inject_poison() -> None:
    inspect_runtime()
    event_id = "evt-" + ("f" * 24)
    payload = {
        "schema_version": 99,
        "event_id": event_id,
        "event_type": "order.accepted.v99",
        "order_id": "ord-poison001",
        "customer_ref": "cust-poison001",
        "amount_cents": 1,
        "occurred_at": "synthetic",
    }
    kafka_produce(event_id, payload)
    print(f"inject-poison=pass event_id={event_id} expected=quarantine")


def command_seed_backlog(*, count: int, partition: int) -> None:
    inspect_runtime()
    if not 1 <= count <= 30:
        raise ContractError("count must be between 1 and 30")
    if partition not in {0, 1, 2}:
        raise ContractError("partition must be 0, 1 or 2")
    selected: list[str] = []
    candidate = 1
    while len(selected) < count and candidate <= 10_000:
        suffix = f"seed{candidate:08d}"
        document = {
            "schema_version": 1,
            "order_id": f"ord-{suffix}",
            "idempotency_key": f"idem-{suffix}",
            "customer_ref": f"cust-{suffix}",
            "amount_cents": 1000 + candidate,
        }
        normalized = validate_order(document)
        event_id = "evt-" + hashlib.md5(
            f"{document['order_id']}:{normalized['payload_hash']}".encode("ascii"),
            usedforsecurity=False,
        ).hexdigest()[:24]
        candidate += 1
        if kafka_partition(event_id) != partition:
            continue
        outcome = json.loads(postgres(sql_for_order(normalized)))
        if outcome != {
            "event_id": event_id,
            "order_id": document["order_id"],
            "replayed": False,
        }:
            raise RuntimeBoundaryError("seed submission receipt differs")
        kafka_produce(event_id, json.loads(postgres(
            "SELECT event_payload FROM atlas.outbox "
            f"WHERE event_id='{event_id}' AND NOT published;"
        )))
        acknowledged = postgres(
            "UPDATE atlas.outbox SET published=true, published_at=clock_timestamp() "
            f"WHERE event_id='{event_id}' AND NOT published RETURNING event_id;"
        )
        if acknowledged != event_id:
            raise RuntimeBoundaryError("seed outbox acknowledgement differs")
        selected.append(event_id)
    if len(selected) != count:
        raise RuntimeBoundaryError("could not construct the requested partition backlog")
    observed = kafka_end_offsets()
    print(
        "seed-backlog=pass "
        f"published={count} target_partition={partition} "
        f"end_offsets={canonical_json(observed)}"
    )


def command_backlog() -> None:
    inspect_runtime()
    end_offsets = kafka_end_offsets()
    raw = postgres(
        "WITH observed AS ("
        "SELECT source_partition,source_offset FROM atlas.delivery_attempts "
        "UNION ALL "
        "SELECT source_partition,source_offset FROM atlas.quarantine "
        "WHERE source_partition IS NOT NULL AND source_offset IS NOT NULL"
        "), watermarks AS ("
        "SELECT source_partition,max(source_offset) AS max_offset "
        "FROM observed GROUP BY source_partition"
        ") SELECT coalesce(jsonb_object_agg(source_partition,max_offset),'{}'::jsonb) "
        "FROM watermarks;"
    )
    watermarks = {int(key): int(value) for key, value in json.loads(raw).items()}
    partitions: dict[str, dict[str, int]] = {}
    total_lag = 0
    for partition in sorted(end_offsets):
        next_offset = watermarks.get(partition, -1) + 1
        lag = max(0, end_offsets[partition] - next_offset)
        total_lag += lag
        partitions[str(partition)] = {
            "end_offset": end_offsets[partition],
            "next_offset": next_offset,
            "lag": lag,
        }
    total_records = sum(end_offsets.values())
    dominant_share = (
        round(100 * max(end_offsets.values()) / total_records, 1)
        if total_records
        else 0.0
    )
    report = {
        "total_lag": total_lag,
        "total_records": total_records,
        "dominant_partition_share_pct": dominant_share,
        "partitions": partitions,
    }
    print(f"backlog=pass report={canonical_json(report)}")


def command_reconcile() -> int:
    inspect_runtime()
    raw = postgres(
        "SELECT jsonb_build_object("
        "'source_rows',(SELECT count(*) FROM atlas.orders),"
        "'fact_rows',(SELECT count(*) FROM atlas.order_facts),"
        "'source_amount_cents',(SELECT coalesce(sum(amount_cents),0) FROM atlas.orders),"
        "'fact_amount_cents',(SELECT coalesce(sum(amount_cents),0) FROM atlas.order_facts),"
        "'missing_facts',(SELECT count(*) FROM atlas.orders o "
        "LEFT JOIN atlas.order_facts f USING(order_id) WHERE f.order_id IS NULL),"
        "'orphan_facts',(SELECT count(*) FROM atlas.order_facts f "
        "LEFT JOIN atlas.orders o USING(order_id) WHERE o.order_id IS NULL),"
        "'value_mismatches',(SELECT count(*) FROM atlas.orders o "
        "JOIN atlas.order_facts f USING(order_id) "
        "WHERE o.customer_ref<>f.customer_ref OR o.amount_cents<>f.amount_cents),"
        "'unpublished',(SELECT count(*) FROM atlas.outbox WHERE NOT published),"
        "'quarantined',(SELECT count(*) FROM atlas.quarantine)"
        ");"
    )
    metrics = json.loads(raw)
    passed = (
        metrics["source_rows"] == metrics["fact_rows"]
        and metrics["source_amount_cents"] == metrics["fact_amount_cents"]
        and all(
            metrics[name] == 0
            for name in (
                "missing_facts",
                "orphan_facts",
                "value_mismatches",
                "unpublished",
                "quarantined",
            )
        )
    )
    run_id = f"run-{uuid.uuid4().hex}"
    encoded = base64.b64encode(canonical_json(metrics).encode("ascii")).decode("ascii")
    status = "pass" if passed else "fail"
    receipt = postgres(
        "INSERT INTO atlas.pipeline_runs("
        "run_id,job_name,input_dataset,output_dataset,status,metrics,"
        "started_at,completed_at"
        ") VALUES ("
        f"'{run_id}','order_fact_reconciliation','atlas.orders',"
        f"'atlas.order_facts','{status}',"
        f"convert_from(decode('{encoded}','base64'),'UTF8')::jsonb,"
        "clock_timestamp(),clock_timestamp()"
        ") RETURNING run_id;"
    )
    if receipt != run_id:
        raise RuntimeBoundaryError("lineage receipt identity differs")
    print(
        f"reconcile={status} run_id={run_id} metrics={canonical_json(metrics)}"
    )
    return 0 if passed else 4


def command_status() -> None:
    inspect_runtime()
    counts = postgres(
        "SELECT jsonb_build_object("
        "'orders', (SELECT count(*) FROM atlas.orders),"
        "'outbox', (SELECT count(*) FROM atlas.outbox),"
        "'unpublished', (SELECT count(*) FROM atlas.outbox WHERE NOT published),"
        "'deliveries', (SELECT count(*) FROM atlas.delivery_attempts),"
        "'duplicate_deliveries', (SELECT count(*) FROM atlas.delivery_attempts "
        "WHERE duplicate),"
        "'inbox', (SELECT count(*) FROM atlas.consumer_inbox),"
        "'facts', (SELECT count(*) FROM atlas.order_facts),"
        "'quarantine', (SELECT count(*) FROM atlas.quarantine),"
        "'pipeline_runs', (SELECT count(*) FROM atlas.pipeline_runs)"
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
    commands.add_parser("up")
    commands.add_parser("init")
    submit = commands.add_parser("submit")
    submit.add_argument("request", type=Path)
    relay = commands.add_parser("relay")
    relay.add_argument("--stop-after-publish", action="store_true")
    commands.add_parser("consume")
    commands.add_parser("inject-poison")
    seed_backlog = commands.add_parser("seed-backlog")
    seed_backlog.add_argument("--count", type=int, default=9)
    seed_backlog.add_argument("--partition", type=int, default=0)
    commands.add_parser("backlog")
    commands.add_parser("reconcile")
    commands.add_parser("status")
    commands.add_parser("cleanup")
    return result


def main() -> int:
    arguments = parser().parse_args()
    try:
        if arguments.command == "check":
            command_check(arguments.request)
        elif arguments.command == "up":
            command_up()
        elif arguments.command == "init":
            command_init()
        elif arguments.command == "submit":
            command_submit(arguments.request)
        elif arguments.command == "relay":
            return command_relay(stop_after_publish=arguments.stop_after_publish)
        elif arguments.command == "consume":
            command_consume()
        elif arguments.command == "inject-poison":
            command_inject_poison()
        elif arguments.command == "seed-backlog":
            command_seed_backlog(count=arguments.count, partition=arguments.partition)
        elif arguments.command == "backlog":
            command_backlog()
        elif arguments.command == "reconcile":
            return command_reconcile()
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
