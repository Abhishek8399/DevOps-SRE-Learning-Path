#!/usr/bin/env python3
"""Deterministic LES-0028 teaching model. This is not a PromQL engine."""

from __future__ import annotations

import argparse
import json
import math
import os
import stat
import sys
import tempfile
from pathlib import Path
from typing import Any

MAX_JSON_BYTES = 1_048_576
CASES = {
    "counter-rate",
    "vector-match",
    "histogram",
    "cardinality",
    "alert-state",
    "dashboard-contract",
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


def require_keys(value: dict[str, Any], keys: set[str], location: str) -> None:
    missing = sorted(keys - value.keys())
    extra = sorted(value.keys() - keys)
    if missing:
        fail(f"missing_keys={location}:{','.join(missing)}")
    if extra:
        fail(f"unexpected_keys={location}:{','.join(extra)}")


def validate_scenario(scenario: dict[str, Any]) -> None:
    require_keys(
        scenario,
        {"schemaVersion", "lessonId", "caseId", "counterWindow", "vectorMatch", "histogram", "cardinality", "alertState", "dashboard", "incident"},
        "scenario",
    )
    if scenario["schemaVersion"] != 1 or scenario["lessonId"] != "LES-0028":
        fail("scenario_identity_invalid")
    if scenario["caseId"] != "prometheus-reasoning-v1":
        fail("scenario_case_invalid")
    counter = scenario["counterWindow"]
    if not isinstance(counter, dict) or counter.get("elapsedSeconds") != 60:
        fail("counter_window_invalid")
    series = counter.get("series")
    if not isinstance(series, list) or len(series) != 4:
        fail("counter_series_invalid")
    for row in series:
        if not isinstance(row, dict) or set(row) != {"labels", "samples"}:
            fail("counter_row_invalid")
        labels, samples = row["labels"], row["samples"]
        if not isinstance(labels, dict) or set(labels) != {"service", "operation", "instance", "outcome"}:
            fail("counter_labels_invalid")
        if labels["outcome"] not in {"success", "failure"}:
            fail("counter_outcome_invalid")
        if not isinstance(samples, list) or len(samples) != 5 or not all(isinstance(item, int) and item >= 0 for item in samples):
            fail("counter_samples_invalid")
    histogram = scenario["histogram"]
    if not isinstance(histogram, dict) or not isinstance(histogram.get("buckets"), list):
        fail("histogram_invalid")
    dashboard = scenario["dashboard"]
    if not isinstance(dashboard, dict) or not isinstance(dashboard.get("panels"), list):
        fail("dashboard_invalid")


def validate_state(state_dir: Path, expected_uid: int) -> dict[str, Any]:
    expected = Path("/tmp") / f"reliability-atlas-les0028-{expected_uid}"
    if state_dir != expected:
        fail("state_path_not_exact")
    if state_dir.is_symlink() or not state_dir.is_dir():
        fail("state_directory_invalid")
    root_info = state_dir.lstat()
    if root_info.st_uid != expected_uid:
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
    if sentinel.read_text(encoding="utf-8") != f"LES-0028:{expected_uid}\n":
        fail("sentinel_invalid")
    manifest = load_json(state_dir / "manifest.json")
    require_keys(manifest, {"schemaVersion", "lessonId", "uid", "statePath", "caseId"}, "manifest")
    if manifest != {
        "schemaVersion": 1,
        "lessonId": "LES-0028",
        "uid": expected_uid,
        "statePath": str(expected),
        "caseId": "prometheus-reasoning-v1",
    }:
        fail("manifest_invalid")
    scenario = load_json(state_dir / "scenario.json")
    validate_scenario(scenario)
    return scenario


def reset_adjusted_delta(samples: list[int]) -> tuple[int, int]:
    total = 0
    resets = 0
    previous = samples[0]
    for current in samples[1:]:
        if current >= previous:
            total += current - previous
        else:
            resets += 1
            total += current
        previous = current
    return total, resets


def counter_rate(scenario: dict[str, Any]) -> dict[str, Any]:
    totals = {"success": 0, "failure": 0}
    resets = 0
    rows = []
    elapsed = scenario["counterWindow"]["elapsedSeconds"]
    for row in scenario["counterWindow"]["series"]:
        delta, row_resets = reset_adjusted_delta(row["samples"])
        outcome = row["labels"]["outcome"]
        totals[outcome] += delta
        resets += row_resets
        rows.append({"labels": row["labels"], "delta": delta, "simpleRatePerSecond": delta / elapsed, "resets": row_resets})
    attempts = totals["success"] + totals["failure"]
    return {
        "case": "counter-rate",
        "algorithm": "sum non-negative segment increases; after a decrease add the new value",
        "elapsedSeconds": elapsed,
        "rows": rows,
        "successDelta": totals["success"],
        "failureDelta": totals["failure"],
        "attemptDelta": attempts,
        "failureFraction": totals["failure"] / attempts,
        "resetCount": resets,
        "proofLimit": "deterministic endpoint model; not Prometheus rate extrapolation",
    }


def label_key(labels: dict[str, str], names: list[str]) -> tuple[tuple[str, str], ...]:
    return tuple((name, labels.get(name, "")) for name in names)


def vector_match(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["vectorMatch"]
    names = spec["matchLabels"]
    left: dict[tuple[tuple[str, str], ...], list[dict[str, Any]]] = {}
    right: dict[tuple[tuple[str, str], ...], list[dict[str, Any]]] = {}
    for row in spec["numerators"]:
        left.setdefault(label_key(row["labels"], names), []).append(row)
    for row in spec["denominators"]:
        right.setdefault(label_key(row["labels"], names), []).append(row)
    matches = []
    for key in sorted(set(left) | set(right)):
        lhs, rhs = left.get(key, []), right.get(key, [])
        if len(lhs) != 1 or len(rhs) != 1:
            fail(f"vector_match_not_one_to_one={key}")
        if rhs[0]["value"] == 0:
            fail(f"vector_match_zero_denominator={key}")
        matches.append({"labels": dict(key), "numerator": lhs[0]["value"], "denominator": rhs[0]["value"], "fraction": lhs[0]["value"] / rhs[0]["value"]})
    return {"case": "vector-match", "match": "one-to-one", "matchLabels": names, "results": matches, "proofLimit": "fixture label universe only"}


def histogram(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["histogram"]
    finite: list[tuple[float, int]] = []
    previous = -1
    infinity = None
    for row in spec["buckets"]:
        count = row["count"]
        if not isinstance(count, int) or count < previous:
            fail("histogram_buckets_not_cumulative")
        previous = count
        if row["le"] == "+Inf":
            infinity = count
        else:
            finite.append((float(row["le"]), count))
    if infinity != spec["count"]:
        fail("histogram_infinity_count_mismatch")
    threshold_count = next((count for bound, count in finite if math.isclose(bound, spec["threshold"])), None)
    if threshold_count is None:
        fail("histogram_threshold_bucket_missing")
    rank = spec["quantile"] * spec["count"]
    lower_bound, lower_count = 0.0, 0
    estimate = None
    estimate_bucket = None
    for upper_bound, upper_count in finite:
        if rank <= upper_count:
            population = upper_count - lower_count
            if population <= 0:
                fail("histogram_quantile_empty_bucket")
            fraction = (rank - lower_count) / population
            estimate = lower_bound + fraction * (upper_bound - lower_bound)
            estimate_bucket = [lower_bound, upper_bound]
            break
        lower_bound, lower_count = upper_bound, upper_count
    if estimate is None:
        fail("histogram_quantile_in_infinite_bucket")
    return {
        "case": "histogram",
        "unit": spec["unit"],
        "count": spec["count"],
        "threshold": spec["threshold"],
        "thresholdFraction": threshold_count / spec["count"],
        "quantile": spec["quantile"],
        "linearInterpolationEstimate": estimate,
        "estimateBucket": estimate_bucket,
        "proofLimit": "classic cumulative bucket teaching model with linear interpolation",
    }


def cardinality(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["cardinality"]
    product = math.prod(spec["boundedDomains"].values())
    sample_rate = product / spec["scrapeIntervalSeconds"]
    retained = sample_rate * spec["retentionSeconds"]
    return {
        "case": "cardinality",
        "boundedSeriesMaximum": product,
        "seriesBudget": spec["seriesBudget"],
        "withinBoundedBudget": product <= spec["seriesBudget"],
        "unboundedLabels": spec["unboundedLabels"],
        "sampleRatePerSecondIfAllActive": sample_rate,
        "retainedSampleEstimateIfStable": retained,
        "proofLimit": "combinatorial planning estimate; not observed series, bytes, churn, or query cost",
    }


def alert_state(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["alertState"]
    active = 0
    was_firing = False
    states = []
    for value in spec["values"]:
        if value > spec["threshold"]:
            active += 1
            state = "firing" if active >= spec["forEvaluations"] else "pending"
            was_firing = state == "firing" or was_firing
        else:
            state = "resolved" if was_firing else "inactive"
            active = 0
            was_firing = False
        states.append(state)
    if states != spec["expectedStates"]:
        fail("alert_state_unexpected")
    return {"case": "alert-state", "threshold": spec["threshold"], "forEvaluations": spec["forEvaluations"], "states": states, "proofLimit": "deterministic state model; not Prometheus or Alertmanager execution"}


def dashboard_contract(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["dashboard"]
    required = {"id", "question", "queryId", "unit", "scope", "freshness", "noData", "drillDown", "owner"}
    query_ids = set(spec["queries"])
    validated = []
    for panel in spec["panels"]:
        if set(panel) != required or not all(isinstance(panel[key], str) and panel[key].strip() for key in required):
            fail(f"dashboard_panel_contract_invalid={panel.get('id', 'unknown')}")
        if panel["queryId"] not in query_ids:
            fail(f"dashboard_query_unresolved={panel['queryId']}")
        validated.append(panel["id"])
    return {"case": "dashboard-contract", "owner": spec["owner"], "validatedPanels": validated, "result": "static-contract-passed", "proofLimit": "not Grafana schema, rendering, accessibility, or query execution"}


def incident(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["incident"]
    return {
        "case": "incident",
        "symptom": spec["symptom"],
        "facts": spec["facts"],
        "earliestSupportedBoundary": spec["earliestSupportedBoundary"],
        "unsafeFirstMoves": spec["unsafeFirstMoves"],
        "safeFirstMove": "bound or roll back the offending label schema while preserving user-outcome evidence",
        "proofLimit": "guided fixture diagnosis; does not establish causality in another system",
    }


RUNNERS = {
    "counter-rate": counter_rate,
    "vector-match": vector_match,
    "histogram": histogram,
    "cardinality": cardinality,
    "alert-state": alert_state,
    "dashboard-contract": dashboard_contract,
    "incident": incident,
}


def atomic_json(path: Path, value: dict[str, Any]) -> None:
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
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
    sub = parser.add_subparsers(dest="command", required=True)
    validate_scenario_parser = sub.add_parser("validate-scenario")
    validate_scenario_parser.add_argument("path", type=Path)
    validate_state_parser = sub.add_parser("validate-state")
    validate_state_parser.add_argument("state", type=Path)
    validate_state_parser.add_argument("--uid", type=int, required=True)
    run_parser = sub.add_parser("run")
    run_parser.add_argument("case", choices=sorted(CASES))
    run_parser.add_argument("state", type=Path)
    run_parser.add_argument("--uid", type=int, required=True)
    args = parser.parse_args()
    try:
        if args.command == "validate-scenario":
            scenario = load_json(args.path)
            validate_scenario(scenario)
            print("scenario_valid=true lesson=LES-0028 case=prometheus-reasoning-v1")
            return 0
        if args.command == "validate-state":
            validate_state(args.state, args.uid)
            print(f"state_valid=true path={args.state} uid={args.uid}")
            return 0
        scenario = validate_state(args.state, args.uid)
        result = RUNNERS[args.case](scenario)
        atomic_json(args.state / f"result-{args.case}.json", result)
        print(json.dumps(result, sort_keys=True, separators=(",", ":")))
        return 0
    except (ContractError, OSError, json.JSONDecodeError, TypeError, KeyError) as error:
        print(f"refused=true reason={error}", file=sys.stderr)
        return 78


if __name__ == "__main__":
    raise SystemExit(main())
