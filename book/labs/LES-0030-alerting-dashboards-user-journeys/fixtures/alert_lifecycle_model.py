#!/usr/bin/env python3
"""Deterministic LES-0030 teaching model. This is not an alerting product."""

from __future__ import annotations

import argparse
import json
import os
import stat
import sys
import tempfile
from collections import Counter
from pathlib import Path
from typing import Any

MAX_JSON_BYTES = 1_048_576
CASES = {
    "alert-quality",
    "state-machine",
    "burn-rate",
    "no-data",
    "routing",
    "flapping",
    "dashboard",
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


def is_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def validate_scenario(scenario: dict[str, Any]) -> None:
    require_exact_keys(
        scenario,
        {
            "schemaVersion", "lessonId", "caseId", "alertQuality",
            "stateMachine", "burnRate", "noData", "routing", "flapping",
            "dashboard", "incident",
        },
        "scenario",
    )
    if scenario["schemaVersion"] != 1 or scenario["lessonId"] != "LES-0030":
        fail("scenario_identity_invalid")
    if scenario["caseId"] != "alert-lifecycle-reasoning-v1":
        fail("scenario_case_invalid")

    quality = scenario["alertQuality"]
    require_exact_keys(
        quality,
        {"significantEvents", "alertsFired", "truePositives", "evaluationWindowDays"},
        "alertQuality",
    )
    if not all(isinstance(quality[key], int) and quality[key] > 0 for key in quality):
        fail("alert_quality_numbers_invalid")
    if quality["truePositives"] > min(quality["significantEvents"], quality["alertsFired"]):
        fail("alert_quality_population_invalid")

    machine = scenario["stateMachine"]
    require_exact_keys(
        machine,
        {"evaluationIntervalSeconds", "pendingForSeconds", "keepFiringForSeconds", "breaches"},
        "stateMachine",
    )
    if not all(isinstance(machine[key], int) and machine[key] >= 0 for key in (
        "evaluationIntervalSeconds", "pendingForSeconds", "keepFiringForSeconds"
    )):
        fail("state_machine_duration_invalid")
    if machine["evaluationIntervalSeconds"] <= 0:
        fail("state_machine_interval_invalid")
    if not isinstance(machine["breaches"], list) or len(machine["breaches"]) < 2:
        fail("state_machine_series_invalid")
    if not all(isinstance(value, bool) for value in machine["breaches"]):
        fail("state_machine_breach_type_invalid")

    burn = scenario["burnRate"]
    require_exact_keys(burn, {"sloTarget", "periodDays", "policies"}, "burnRate")
    if not is_number(burn["sloTarget"]) or not 0 < burn["sloTarget"] < 1:
        fail("burn_rate_slo_invalid")
    if not isinstance(burn["periodDays"], int) or burn["periodDays"] <= 0:
        fail("burn_rate_period_invalid")
    if not isinstance(burn["policies"], list) or not burn["policies"]:
        fail("burn_rate_policies_invalid")
    policy_keys = {
        "name", "severity", "longWindow", "shortWindow", "threshold",
        "longErrorRatio", "shortErrorRatio",
    }
    names: set[str] = set()
    for index, policy in enumerate(burn["policies"]):
        if not isinstance(policy, dict):
            fail(f"burn_rate_policy_type_invalid={index}")
        require_exact_keys(policy, policy_keys, f"burnRate.policies[{index}]")
        if policy["name"] in names or not isinstance(policy["name"], str):
            fail(f"burn_rate_policy_name_invalid={index}")
        names.add(policy["name"])
        if policy["severity"] not in {"page", "ticket"}:
            fail(f"burn_rate_policy_severity_invalid={index}")
        if not all(is_number(policy[key]) and policy[key] >= 0 for key in (
            "threshold", "longErrorRatio", "shortErrorRatio"
        )):
            fail(f"burn_rate_policy_number_invalid={index}")

    no_data = scenario["noData"]
    require_exact_keys(no_data, {"evaluations"}, "noData")
    evaluation_keys = {"name", "queryStatus", "expectedSeries", "returned"}
    if not isinstance(no_data["evaluations"], list) or not no_data["evaluations"]:
        fail("no_data_evaluations_invalid")
    for index, evaluation in enumerate(no_data["evaluations"]):
        if not isinstance(evaluation, dict):
            fail(f"no_data_evaluation_type_invalid={index}")
        require_exact_keys(evaluation, evaluation_keys, f"noData.evaluations[{index}]")
        if evaluation["queryStatus"] not in {"success", "error"}:
            fail(f"no_data_status_invalid={index}")
        if not isinstance(evaluation["expectedSeries"], list) or not all(
            isinstance(item, str) and item for item in evaluation["expectedSeries"]
        ):
            fail(f"no_data_expected_invalid={index}")
        if not isinstance(evaluation["returned"], dict) or not all(
            isinstance(key, str) and is_number(value)
            for key, value in evaluation["returned"].items()
        ):
            fail(f"no_data_returned_invalid={index}")

    routing = scenario["routing"]
    require_exact_keys(routing, {"alerts"}, "routing")
    routing_keys = {"fingerprint", "groupKey", "inhibited", "silenced"}
    if not isinstance(routing["alerts"], list) or not routing["alerts"]:
        fail("routing_alerts_invalid")
    for index, alert in enumerate(routing["alerts"]):
        if not isinstance(alert, dict):
            fail(f"routing_alert_type_invalid={index}")
        require_exact_keys(alert, routing_keys, f"routing.alerts[{index}]")
        if not all(isinstance(alert[key], str) and alert[key] for key in ("fingerprint", "groupKey")):
            fail(f"routing_identity_invalid={index}")
        if not isinstance(alert["inhibited"], bool) or not isinstance(alert["silenced"], bool):
            fail(f"routing_state_invalid={index}")
        if alert["inhibited"] and alert["silenced"]:
            fail(f"routing_multiple_suppression_invalid={index}")

    flapping = scenario["flapping"]
    require_exact_keys(flapping, {"fireThreshold", "recoverThreshold", "values"}, "flapping")
    if not is_number(flapping["fireThreshold"]) or not is_number(flapping["recoverThreshold"]):
        fail("flapping_threshold_invalid")
    if flapping["recoverThreshold"] >= flapping["fireThreshold"]:
        fail("flapping_hysteresis_invalid")
    if not isinstance(flapping["values"], list) or not all(is_number(value) for value in flapping["values"]):
        fail("flapping_values_invalid")

    dashboard = scenario["dashboard"]
    require_exact_keys(dashboard, {"panels"}, "dashboard")
    panel_keys = {
        "name", "numerator", "denominator", "expectedDenominator",
        "freshnessAgeSeconds", "freshnessLimitSeconds",
    }
    if not isinstance(dashboard["panels"], list) or not dashboard["panels"]:
        fail("dashboard_panels_invalid")
    for index, panel in enumerate(dashboard["panels"]):
        if not isinstance(panel, dict):
            fail(f"dashboard_panel_type_invalid={index}")
        require_exact_keys(panel, panel_keys, f"dashboard.panels[{index}]")
        if not isinstance(panel["name"], str) or not panel["name"]:
            fail(f"dashboard_panel_name_invalid={index}")
        for key in ("numerator", "denominator"):
            if panel[key] is not None and (not is_number(panel[key]) or panel[key] < 0):
                fail(f"dashboard_panel_value_invalid={index}:{key}")
        if not all(is_number(panel[key]) and panel[key] >= 0 for key in (
            "expectedDenominator", "freshnessAgeSeconds", "freshnessLimitSeconds"
        )):
            fail(f"dashboard_panel_contract_invalid={index}")

    incident = scenario["incident"]
    require_exact_keys(
        incident,
        {"symptom", "facts", "earliestSupportedBoundary", "unsafeFirstMoves"},
        "incident",
    )
    if not isinstance(incident["symptom"], str) or not incident["symptom"]:
        fail("incident_symptom_invalid")
    if not all(isinstance(value, str) and value for value in incident["facts"]):
        fail("incident_facts_invalid")
    if not all(isinstance(value, str) and value for value in incident["unsafeFirstMoves"]):
        fail("incident_moves_invalid")


def validate_state(state_dir: Path, expected_uid: int) -> dict[str, Any]:
    expected = Path("/tmp") / f"reliability-atlas-les0030-{expected_uid}"
    if state_dir != expected:
        fail("state_path_not_exact")
    if state_dir.is_symlink() or not state_dir.is_dir():
        fail("state_directory_invalid")
    if state_dir.lstat().st_uid != expected_uid:
        fail("state_owner_invalid")
    allowed = {"SENTINEL", "manifest.json", "scenario.json"} | {
        f"result-{name}.json" for name in CASES
    }
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
    if sentinel.read_text(encoding="utf-8") != f"LES-0030:{expected_uid}\n":
        fail("sentinel_invalid")
    manifest = load_json(state_dir / "manifest.json")
    require_exact_keys(
        manifest,
        {"schemaVersion", "lessonId", "uid", "statePath", "caseId"},
        "manifest",
    )
    if manifest != {
        "schemaVersion": 1,
        "lessonId": "LES-0030",
        "uid": expected_uid,
        "statePath": str(expected),
        "caseId": "alert-lifecycle-reasoning-v1",
    }:
        fail("manifest_invalid")
    scenario = load_json(state_dir / "scenario.json")
    validate_scenario(scenario)
    return scenario


def alert_quality(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["alertQuality"]
    false_positives = spec["alertsFired"] - spec["truePositives"]
    missed = spec["significantEvents"] - spec["truePositives"]
    precision = spec["truePositives"] / spec["alertsFired"]
    recall = spec["truePositives"] / spec["significantEvents"]
    return {
        "case": "alert-quality",
        **spec,
        "falsePositives": false_positives,
        "missedSignificantEvents": missed,
        "precision": round(precision, 6),
        "recall": round(recall, 6),
        "proofLimit": "declared event labels only; no claim that significance classification or observation coverage is complete",
    }


def state_machine(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["stateMachine"]
    interval = spec["evaluationIntervalSeconds"]
    pending_since: int | None = None
    clear_since: int | None = None
    state = "normal"
    rows: list[dict[str, Any]] = []
    for index, breach in enumerate(spec["breaches"]):
        at = index * interval
        if breach:
            clear_since = None
            if state == "normal":
                pending_since = at
                state = "pending" if spec["pendingForSeconds"] > 0 else "firing"
            if state == "pending" and pending_since is not None:
                if at - pending_since >= spec["pendingForSeconds"]:
                    state = "firing"
        else:
            pending_since = None
            if state == "pending":
                state = "normal"
            elif state == "firing":
                if clear_since is None:
                    clear_since = at
                if at - clear_since >= spec["keepFiringForSeconds"]:
                    state = "normal"
                    clear_since = None
        rows.append({"atSeconds": at, "breach": breach, "state": state})
    transitions = sum(rows[index]["state"] != rows[index - 1]["state"] for index in range(1, len(rows)))
    return {
        "case": "state-machine",
        "rows": rows,
        "stateTransitions": transitions,
        "finalState": state,
        "proofLimit": "discrete teaching evaluations only; not Prometheus or Grafana scheduler semantics",
    }


def burn_rate(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["burnRate"]
    error_budget = 1 - spec["sloTarget"]
    rows = []
    for policy in spec["policies"]:
        long_burn = policy["longErrorRatio"] / error_budget
        short_burn = policy["shortErrorRatio"] / error_budget
        fires = long_burn > policy["threshold"] and short_burn > policy["threshold"]
        rows.append({
            "name": policy["name"],
            "severity": policy["severity"],
            "longBurnRate": round(long_burn, 6),
            "shortBurnRate": round(short_burn, 6),
            "fires": fires,
        })
    return {
        "case": "burn-rate",
        "errorBudgetFraction": round(error_budget, 6),
        "firingPolicies": [row["name"] for row in rows if row["fires"]],
        "rows": rows,
        "proofLimit": "ratio arithmetic over declared inputs; not traffic sufficiency, SLI validity, or live rule evaluation",
    }


def no_data(scenario: dict[str, Any]) -> dict[str, Any]:
    rows = []
    for evaluation in scenario["noData"]["evaluations"]:
        expected = set(evaluation["expectedSeries"])
        returned = set(evaluation["returned"])
        missing = sorted(expected - returned)
        if evaluation["queryStatus"] == "error":
            classification = "query-error"
        elif not returned:
            classification = "no-data"
        elif missing:
            classification = "missing-series"
        elif all(value == 0 for value in evaluation["returned"].values()):
            classification = "value-zero"
        else:
            classification = "value-present"
        rows.append({
            "name": evaluation["name"],
            "classification": classification,
            "missingSeries": missing,
        })
    return {
        "case": "no-data",
        "classifications": {row["name"]: row["classification"] for row in rows},
        "rows": rows,
        "proofLimit": "fixture population contract only; dynamic service discovery needs separately versioned expected-series logic",
    }


def routing(scenario: dict[str, Any]) -> dict[str, Any]:
    alerts = scenario["routing"]["alerts"]
    unique: dict[str, dict[str, Any]] = {}
    for alert in alerts:
        unique.setdefault(alert["fingerprint"], alert)
    deliverable = [alert for alert in unique.values() if not alert["inhibited"] and not alert["silenced"]]
    groups = Counter(alert["groupKey"] for alert in deliverable)
    return {
        "case": "routing",
        "receivedAlerts": len(alerts),
        "uniqueAlerts": len(unique),
        "duplicateDeliveries": len(alerts) - len(unique),
        "inhibitedAlerts": sum(alert["inhibited"] for alert in unique.values()),
        "silencedAlerts": sum(alert["silenced"] for alert in unique.values()),
        "deliverableAlerts": len(deliverable),
        "notificationGroups": len(groups),
        "groupSizes": dict(sorted(groups.items())),
        "proofLimit": "declared flags and fingerprints only; not Alertmanager matching, timing, HA, or receiver delivery",
    }


def flapping(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["flapping"]
    naive_states = ["firing" if value > spec["fireThreshold"] else "normal" for value in spec["values"]]
    hysteresis_states = []
    firing = False
    for value in spec["values"]:
        if not firing and value > spec["fireThreshold"]:
            firing = True
        elif firing and value <= spec["recoverThreshold"]:
            firing = False
        hysteresis_states.append("firing" if firing else "normal")
    transitions = lambda states: sum(states[index] != states[index - 1] for index in range(1, len(states)))
    return {
        "case": "flapping",
        "naiveStates": naive_states,
        "hysteresisStates": hysteresis_states,
        "naiveTransitions": transitions(naive_states),
        "hysteresisTransitions": transitions(hysteresis_states),
        "proofLimit": "threshold sequence only; hysteresis can hide real recovery or degradation if its contract is wrong",
    }


def dashboard(scenario: dict[str, Any]) -> dict[str, Any]:
    rows = []
    for panel in scenario["dashboard"]["panels"]:
        numerator = panel["numerator"]
        denominator = panel["denominator"]
        if numerator is None or denominator is None:
            state = "no-data"
            value = None
            coverage = 0.0
        else:
            value = numerator / denominator if denominator else None
            coverage = denominator / panel["expectedDenominator"] if panel["expectedDenominator"] else 1.0
            if panel["freshnessAgeSeconds"] > panel["freshnessLimitSeconds"]:
                state = "stale"
            elif coverage < 1:
                state = "partial"
            elif value == 0:
                state = "value-zero"
            else:
                state = "value-present"
        rows.append({
            "name": panel["name"],
            "state": state,
            "value": value,
            "coverage": round(coverage, 6),
        })
    return {
        "case": "dashboard",
        "states": {row["name"]: row["state"] for row in rows},
        "rows": rows,
        "proofLimit": "panel contracts over fixtures only; not query correctness, visualization usability, or user health",
    }


def incident(scenario: dict[str, Any]) -> dict[str, Any]:
    spec = scenario["incident"]
    return {
        "case": "incident",
        "symptom": spec["symptom"],
        "facts": spec["facts"],
        "earliestSupportedBoundary": spec["earliestSupportedBoundary"],
        "safeFirstMove": "preserve one root-cause and one user-journey alert, repair bounded grouping/inhibition/deduplication, and verify receiver plus user recovery separately",
        "unsafeFirstMoves": spec["unsafeFirstMoves"],
        "proofLimit": "guided facts locate notification amplification; they do not prove organizational root cause or complete user impact",
    }


RUNNERS = {
    "alert-quality": alert_quality,
    "state-machine": state_machine,
    "burn-rate": burn_rate,
    "no-data": no_data,
    "routing": routing,
    "flapping": flapping,
    "dashboard": dashboard,
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
            print("scenario_valid=true lesson=LES-0030 case=alert-lifecycle-reasoning-v1")
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
