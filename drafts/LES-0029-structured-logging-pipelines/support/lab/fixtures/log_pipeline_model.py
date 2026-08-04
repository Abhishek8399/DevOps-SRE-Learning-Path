#!/usr/bin/env python3
"""Deterministic LES-0029 teaching model. This is not a vendor log pipeline."""

from __future__ import annotations

import argparse
import json
import os
import re
import stat
import sys
import tempfile
from collections import Counter
from pathlib import Path
from typing import Any

MAX_JSON_BYTES = 1_048_576
CASES = {
    "baseline",
    "multiline",
    "parser-drift",
    "backpressure",
    "duplicate-delivery",
    "privacy",
    "clock-skew",
    "incident",
}


class ContractError(ValueError):
    pass


def fail(message: str) -> None:
    raise ContractError(message)


def load_json(path: Path) -> dict[str, Any]:
    info = path.lstat()
    if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
        fail(f"unsafe_json_type={path.name}")
    if info.st_size > MAX_JSON_BYTES:
        fail(f"json_too_large={path.name}")
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        fail(f"json_root_not_object={path.name}")
    return value


def require_exact_keys(value: dict[str, Any], keys: set[str], location: str) -> None:
    missing = sorted(keys - value.keys())
    extra = sorted(value.keys() - keys)
    if missing:
        fail(f"missing_keys={location}:{','.join(missing)}")
    if extra:
        fail(f"unexpected_keys={location}:{','.join(extra)}")


def validate_scenario(scenario: dict[str, Any]) -> None:
    require_exact_keys(
        scenario,
        {"schemaVersion", "lessonId", "caseId", "baselineEvents", "multiline", "parserDrift", "backpressure", "duplicateDelivery", "privacy", "clockSkew", "incident"},
        "scenario",
    )
    if scenario["schemaVersion"] != 1 or scenario["lessonId"] != "LES-0029":
        fail("scenario_identity_invalid")
    if scenario["caseId"] != "structured-logging-reasoning-v1":
        fail("scenario_case_invalid")
    baseline = scenario["baselineEvents"]
    expected = {"event_time", "observed_time", "service", "environment", "event_name", "severity", "message", "trace_id", "outcome", "duration_ms"}
    if not isinstance(baseline, list) or len(baseline) != 8:
        fail("baseline_event_count_invalid")
    for index, record in enumerate(baseline):
        if not isinstance(record, dict) or set(record) != expected:
            fail(f"baseline_shape_invalid={index}")
        if not isinstance(record["event_time"], int) or not isinstance(record["observed_time"], int):
            fail(f"baseline_time_invalid={index}")
        if record["observed_time"] < record["event_time"]:
            fail(f"baseline_observed_before_event={index}")
        if not isinstance(record["duration_ms"], int) or record["duration_ms"] < 0:
            fail(f"baseline_duration_invalid={index}")
    multiline = scenario["multiline"]
    require_exact_keys(multiline, {"startPattern", "physicalLines", "expectedLogicalEvents"}, "multiline")
    if multiline["startPattern"] != "timestamp-prefix" or not isinstance(multiline["physicalLines"], list):
        fail("multiline_contract_invalid")
    parser = scenario["parserDrift"]
    require_exact_keys(parser, {"requiredFields", "integerFields", "records"}, "parserDrift")
    if not all(isinstance(item, str) for item in parser["requiredFields"] + parser["integerFields"]):
        fail("parser_field_contract_invalid")
    backpressure = scenario["backpressure"]
    require_exact_keys(backpressure, {"produced", "consumed", "queuedAtEnd", "dropped", "queueCapacity", "policy"}, "backpressure")
    numeric = [backpressure[key] for key in ("produced", "consumed", "queuedAtEnd", "dropped", "queueCapacity")]
    if not all(isinstance(value, int) and value >= 0 for value in numeric):
        fail("backpressure_numeric_invalid")
    if backpressure["produced"] != backpressure["consumed"] + backpressure["queuedAtEnd"] + backpressure["dropped"]:
        fail("backpressure_conservation_invalid")
    if backpressure["queuedAtEnd"] > backpressure["queueCapacity"]:
        fail("backpressure_capacity_invalid")
    duplicate = scenario["duplicateDelivery"]
    require_exact_keys(duplicate, {"deliveryMode", "eventIds"}, "duplicateDelivery")
    if not isinstance(duplicate["eventIds"], list) or not all(isinstance(value, str) and value for value in duplicate["eventIds"]):
        fail("duplicate_ids_invalid")
    privacy = scenario["privacy"]
    require_exact_keys(privacy, {"forbiddenFields", "records"}, "privacy")
    if not isinstance(privacy["records"], list) or not isinstance(privacy["forbiddenFields"], list):
        fail("privacy_contract_invalid")
    clocks = scenario["clockSkew"]
    require_exact_keys(clocks, {"records"}, "clockSkew")
    for record in clocks["records"]:
        if set(record) != {"eventId", "eventTime", "observedTime"}:
            fail("clock_record_invalid")


def validate_state(state_dir: Path, expected_uid: int) -> dict[str, Any]:
    expected = Path("/tmp") / f"reliability-atlas-les0029-{expected_uid}"
    if state_dir != expected:
        fail("state_path_not_exact")
    if state_dir.is_symlink() or not state_dir.is_dir():
        fail("state_directory_invalid")
    if state_dir.lstat().st_uid != expected_uid:
        fail("state_owner_invalid")
    allowed = {"SENTINEL", "manifest.json", "scenario.json"} | {f"result-{name}.json" for name in CASES}
    for child in state_dir.iterdir():
        info = child.lstat()
        if child.name not in allowed:
            fail(f"unexpected_child={child.name}")
        if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
            fail(f"unsafe_child_type={child.name}")
        if info.st_uid != expected_uid:
            fail(f"child_owner_invalid={child.name}")
        if info.st_size > MAX_JSON_BYTES:
            fail(f"child_too_large={child.name}")
    sentinel = state_dir / "SENTINEL"
    if sentinel.read_text(encoding="utf-8") != f"LES-0029:{expected_uid}\n":
        fail("sentinel_invalid")
    manifest = load_json(state_dir / "manifest.json")
    require_exact_keys(manifest, {"schemaVersion", "lessonId", "uid", "statePath", "caseId"}, "manifest")
    if manifest != {"schemaVersion": 1, "lessonId": "LES-0029", "uid": expected_uid, "statePath": str(expected), "caseId": "structured-logging-reasoning-v1"}:
        fail("manifest_invalid")
    scenario = load_json(state_dir / "scenario.json")
    validate_scenario(scenario)
    return scenario


def baseline(scenario: dict[str, Any]) -> dict[str, Any]:
    records = scenario["baselineEvents"]
    by_trace = Counter(record["trace_id"] for record in records)
    by_severity = Counter(record["severity"] for record in records)
    delays = [record["observed_time"] - record["event_time"] for record in records]
    return {
        "case": "baseline",
        "records": len(records),
        "traceCounts": dict(sorted(by_trace.items())),
        "severityCounts": dict(sorted(by_severity.items())),
        "maximumObservationDelaySeconds": max(delays),
        "proofLimit": "checked-in records only; not application, collector, journal, index, or search evidence",
    }


def multiline(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["multiline"]
    starts = re.compile(r"^\d{4}-\d{2}-\d{2}T")
    logical: list[list[str]] = []
    for line in spec["physicalLines"]:
        if starts.match(line):
            logical.append([line])
        elif not logical:
            fail("multiline_continuation_without_start")
        else:
            logical[-1].append(line)
    if len(logical) != spec["expectedLogicalEvents"]:
        fail("multiline_logical_count_unexpected")
    return {
        "case": "multiline",
        "physicalLines": len(spec["physicalLines"]),
        "logicalEvents": len(logical),
        "continuationLines": sum(len(event) - 1 for event in logical),
        "eventLineCounts": [len(event) for event in logical],
        "proofLimit": "one timestamp-prefix teaching rule; not a universal multiline parser",
    }


def parser_drift(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["parserDrift"]
    accepted = 0
    rejected: list[dict[str, Any]] = []
    for index, record in enumerate(spec["records"]):
        missing = sorted(set(spec["requiredFields"]) - record.keys())
        wrong_types = sorted(field for field in spec["integerFields"] if field in record and not isinstance(record[field], int))
        if missing or wrong_types:
            rejected.append({"recordIndex": index, "missingFields": missing, "wrongTypeFields": wrong_types})
        else:
            accepted += 1
    return {
        "case": "parser-drift",
        "input": len(spec["records"]),
        "accepted": accepted,
        "rejected": len(rejected),
        "rejectionDetails": rejected,
        "proofLimit": "fixture schema validation only; not Elastic, Splunk, Logstash, or collector behavior",
    }


def backpressure(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["backpressure"]
    loss_fraction = spec["dropped"] / spec["produced"] if spec["produced"] else 0.0
    return {
        "case": "backpressure",
        **spec,
        "lossFraction": loss_fraction,
        "conservationPassed": spec["produced"] == spec["consumed"] + spec["queuedAtEnd"] + spec["dropped"],
        "proofLimit": "declared count conservation; no timing, concurrency, disk queue, or vendor retry behavior",
    }


def duplicate_delivery(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["duplicateDelivery"]
    counts = Counter(spec["eventIds"])
    duplicates = sum(count - 1 for count in counts.values())
    return {
        "case": "duplicate-delivery",
        "deliveryMode": spec["deliveryMode"],
        "received": len(spec["eventIds"]),
        "unique": len(counts),
        "duplicateDeliveries": duplicates,
        "duplicateEventIds": sorted(event_id for event_id, count in counts.items() if count > 1),
        "proofLimit": "exact fixture IDs only; an event_id does not itself implement durable idempotency",
    }


def privacy(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["privacy"]
    forbidden = set(spec["forbiddenFields"])
    findings: Counter[str] = Counter()
    sanitized = []
    for record in spec["records"]:
        clean = {}
        for key, value in record.items():
            if key in forbidden:
                findings[key] += 1
                clean[key] = "[REDACTED]"
            else:
                clean[key] = value
        sanitized.append(clean)
    leaked_values = [value for record in sanitized for key, value in record.items() if key in forbidden and value != "[REDACTED]"]
    if leaked_values:
        fail("privacy_redaction_failed")
    return {
        "case": "privacy",
        "records": len(spec["records"]),
        "sensitiveOccurrences": sum(findings.values()),
        "fieldsDetected": dict(sorted(findings.items())),
        "redactionPassed": True,
        "proofLimit": "exact field-name policy only; no free-text, encoded-value, retention, access, or legal compliance proof",
    }


def clock_skew(scenario: dict[str, Any]) -> dict[str, Any]:
    records = scenario["clockSkew"]["records"]
    rows = [{"eventId": record["eventId"], "observationDelaySeconds": record["observedTime"] - record["eventTime"]} for record in records]
    return {
        "case": "clock-skew",
        "records": len(rows),
        "maximumPositiveDelaySeconds": max(row["observationDelaySeconds"] for row in rows),
        "negativeDelayRecords": sum(row["observationDelaySeconds"] < 0 for row in rows),
        "rows": rows,
        "proofLimit": "timestamp arithmetic only; negative delay suggests clock or mapping error but does not identify cause",
    }


def incident(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["incident"]
    return {
        "case": "incident",
        "symptom": spec["symptom"],
        "facts": spec["facts"],
        "earliestSupportedBoundary": spec["earliestSupportedBoundary"],
        "safeFirstMove": "stop or roll back the incompatible schema producer while preserving rejected-event evidence and user-outcome signals",
        "unsafeFirstMoves": spec["unsafeFirstMoves"],
        "proofLimit": "guided evidence supports a boundary and mitigation; it does not prove the deployment's organizational root cause",
    }


RUNNERS = {
    "baseline": baseline,
    "multiline": multiline,
    "parser-drift": parser_drift,
    "backpressure": backpressure,
    "duplicate-delivery": duplicate_delivery,
    "privacy": privacy,
    "clock-skew": clock_skew,
    "incident": incident,
}


def atomic_json(path: Path, value: dict[str, Any]) -> None:
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    validate_scenario_parser = subparsers.add_parser("validate-scenario")
    validate_scenario_parser.add_argument("path", type=Path)
    validate_state_parser = subparsers.add_parser("validate-state")
    validate_state_parser.add_argument("state", type=Path)
    validate_state_parser.add_argument("--uid", type=int, required=True)
    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("case", choices=sorted(CASES))
    run_parser.add_argument("state", type=Path)
    run_parser.add_argument("--uid", type=int, required=True)
    arguments = parser.parse_args()
    try:
        if arguments.command == "validate-scenario":
            scenario = load_json(arguments.path)
            validate_scenario(scenario)
            print("scenario_valid=true lesson=LES-0029 case=structured-logging-reasoning-v1")
            return 0
        if arguments.command == "validate-state":
            validate_state(arguments.state, arguments.uid)
            print(f"state_valid=true path={arguments.state} uid={arguments.uid}")
            return 0
        scenario = validate_state(arguments.state, arguments.uid)
        result = RUNNERS[arguments.case](scenario)
        atomic_json(arguments.state / f"result-{arguments.case}.json", result)
        print(json.dumps(result, sort_keys=True, separators=(",", ":")))
        return 0
    except (ContractError, OSError, json.JSONDecodeError, TypeError, KeyError) as error:
        print(f"refused=true reason={error}", file=sys.stderr)
        return 78


if __name__ == "__main__":
    raise SystemExit(main())
