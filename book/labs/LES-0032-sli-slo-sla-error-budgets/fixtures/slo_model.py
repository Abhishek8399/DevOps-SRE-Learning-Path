#!/usr/bin/env python3
"""Deterministic teaching model for LES-0032. It never contacts a service."""

from __future__ import annotations

import argparse
import json
import math
import os
import pathlib
import sys
from typing import Any

LESSON_ID = "LES-0032"
CASE_ID = "slo-control-loop-v1"
ALLOWED_RESULT_NAMES = {
    "result-event-sli.json",
    "result-time-budget.json",
    "result-latency.json",
    "result-coverage.json",
    "result-aggregation.json",
    "result-burn.json",
    "result-alerting.json",
    "result-low-traffic.json",
    "result-policy.json",
}


class ContractError(ValueError):
    """Raised when fixture or state does not match the closed teaching contract."""


def refuse(message: str) -> None:
    print(f"refused=true reason={message}", file=sys.stderr)
    raise SystemExit(78)


def load_json(path: pathlib.Path) -> Any:
    if path.is_symlink() or not path.is_file():
        raise ContractError(f"not-a-regular-file:{path.name}")
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def require_exact_keys(value: dict[str, Any], expected: set[str], where: str) -> None:
    actual = set(value)
    if actual != expected:
        raise ContractError(f"keys:{where}:missing={sorted(expected-actual)}:extra={sorted(actual-expected)}")


def require_count(value: Any, where: str, allow_zero: bool = True) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise ContractError(f"integer:{where}")
    minimum = 0 if allow_zero else 1
    if value < minimum:
        raise ContractError(f"range:{where}")
    return value


def require_ratio(value: Any, where: str, include_one: bool = True) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ContractError(f"number:{where}")
    upper_ok = value <= 1 if include_one else value < 1
    if value < 0 or not upper_ok:
        raise ContractError(f"range:{where}")
    return float(value)


def require_text(value: Any, where: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ContractError(f"text:{where}")
    return value


def validate_event_objective(row: Any, where: str) -> None:
    if not isinstance(row, dict):
        raise ContractError(f"object:{where}")
    require_exact_keys(row, {"name", "target", "totalEvents", "goodEvents", "eligiblePopulation", "goodDefinition"}, where)
    require_text(row["name"], f"{where}.name")
    require_ratio(row["target"], f"{where}.target", include_one=False)
    total = require_count(row["totalEvents"], f"{where}.totalEvents", allow_zero=False)
    good = require_count(row["goodEvents"], f"{where}.goodEvents")
    if good > total:
        raise ContractError(f"good-exceeds-total:{where}")
    require_text(row["eligiblePopulation"], f"{where}.eligiblePopulation")
    require_text(row["goodDefinition"], f"{where}.goodDefinition")


def validate_scenario(path: pathlib.Path) -> dict[str, Any]:
    value = load_json(path)
    if not isinstance(value, dict):
        raise ContractError("scenario-object")
    require_exact_keys(value, {"schemaVersion", "lessonId", "caseId", "measurementPeriod", "eventObjectives", "timeObjective", "latencyObjective", "coverage", "aggregation", "burnWindows", "lowTraffic", "policy"}, "scenario")
    if value["schemaVersion"] != 1 or value["lessonId"] != LESSON_ID or value["caseId"] != CASE_ID:
        raise ContractError("scenario-identity")

    period = value["measurementPeriod"]
    if not isinstance(period, dict):
        raise ContractError("measurementPeriod-object")
    require_exact_keys(period, {"start", "end", "days", "windowType"}, "measurementPeriod")
    require_text(period["start"], "measurementPeriod.start")
    require_text(period["end"], "measurementPeriod.end")
    require_count(period["days"], "measurementPeriod.days", allow_zero=False)
    require_text(period["windowType"], "measurementPeriod.windowType")

    rows = value["eventObjectives"]
    if not isinstance(rows, list) or len(rows) != 2:
        raise ContractError("eventObjectives-count")
    for index, row in enumerate(rows):
        validate_event_objective(row, f"eventObjectives[{index}]")

    time_row = value["timeObjective"]
    if not isinstance(time_row, dict):
        raise ContractError("timeObjective-object")
    require_exact_keys(time_row, {"name", "target", "windowDays", "badMinutesObserved", "samplingIntervalSeconds", "goodDefinition"}, "timeObjective")
    require_text(time_row["name"], "timeObjective.name")
    require_ratio(time_row["target"], "timeObjective.target", include_one=False)
    require_count(time_row["windowDays"], "timeObjective.windowDays", allow_zero=False)
    require_ratio(float(time_row["badMinutesObserved"]) / (time_row["windowDays"] * 1440), "timeObjective.badFraction")
    require_count(time_row["samplingIntervalSeconds"], "timeObjective.samplingIntervalSeconds", allow_zero=False)
    require_text(time_row["goodDefinition"], "timeObjective.goodDefinition")

    latency = value["latencyObjective"]
    if not isinstance(latency, dict):
        raise ContractError("latencyObjective-object")
    require_exact_keys(latency, {"name", "target", "thresholdMilliseconds", "totalEvents", "goodEvents", "eligiblePopulation", "goodDefinition"}, "latencyObjective")
    require_text(latency["name"], "latencyObjective.name")
    require_ratio(latency["target"], "latencyObjective.target", include_one=False)
    require_count(latency["thresholdMilliseconds"], "latencyObjective.thresholdMilliseconds", allow_zero=False)
    total = require_count(latency["totalEvents"], "latencyObjective.totalEvents", allow_zero=False)
    if require_count(latency["goodEvents"], "latencyObjective.goodEvents") > total:
        raise ContractError("latency-good-exceeds-total")
    require_text(latency["eligiblePopulation"], "latencyObjective.eligiblePopulation")
    require_text(latency["goodDefinition"], "latencyObjective.goodDefinition")

    coverage = value["coverage"]
    if not isinstance(coverage, dict):
        raise ContractError("coverage-object")
    require_exact_keys(coverage, {"name", "authoritativeEligibleEvents", "observedEligibleEvents", "observedGoodEvents", "unknownEventsPolicy"}, "coverage")
    authoritative = require_count(coverage["authoritativeEligibleEvents"], "coverage.authoritativeEligibleEvents", allow_zero=False)
    observed = require_count(coverage["observedEligibleEvents"], "coverage.observedEligibleEvents")
    good = require_count(coverage["observedGoodEvents"], "coverage.observedGoodEvents")
    if good > observed or observed > authoritative:
        raise ContractError("coverage-count-order")
    require_text(coverage["name"], "coverage.name")
    if coverage["unknownEventsPolicy"] != "unknown-not-good":
        raise ContractError("coverage-policy")

    aggregation = value["aggregation"]
    if not isinstance(aggregation, dict):
        raise ContractError("aggregation-object")
    require_exact_keys(aggregation, {"name", "groups"}, "aggregation")
    require_text(aggregation["name"], "aggregation.name")
    groups = aggregation["groups"]
    if not isinstance(groups, list) or len(groups) < 2:
        raise ContractError("aggregation-groups")
    for index, group in enumerate(groups):
        if not isinstance(group, dict):
            raise ContractError(f"aggregation-group-object:{index}")
        require_exact_keys(group, {"name", "totalEvents", "goodEvents"}, f"aggregation.groups[{index}]")
        total = require_count(group["totalEvents"], f"aggregation.groups[{index}].totalEvents", allow_zero=False)
        if require_count(group["goodEvents"], f"aggregation.groups[{index}].goodEvents") > total:
            raise ContractError(f"aggregation-good-exceeds-total:{index}")
        require_text(group["name"], f"aggregation.groups[{index}].name")

    burns = value["burnWindows"]
    if not isinstance(burns, dict):
        raise ContractError("burnWindows-object")
    require_exact_keys(burns, {"sloTarget", "signals"}, "burnWindows")
    require_ratio(burns["sloTarget"], "burnWindows.sloTarget", include_one=False)
    signals = burns["signals"]
    if not isinstance(signals, list) or len(signals) != 4:
        raise ContractError("burnWindows-signals")
    for index, signal in enumerate(signals):
        if not isinstance(signal, dict):
            raise ContractError(f"burn-signal-object:{index}")
        require_exact_keys(signal, {"name", "longWindow", "longErrorRate", "shortWindow", "shortErrorRate", "threshold", "severity"}, f"burnWindows.signals[{index}]")
        for field in ("name", "longWindow", "shortWindow", "severity"):
            require_text(signal[field], f"burnWindows.signals[{index}].{field}")
        require_ratio(signal["longErrorRate"], f"burnWindows.signals[{index}].longErrorRate")
        require_ratio(signal["shortErrorRate"], f"burnWindows.signals[{index}].shortErrorRate")
        if not isinstance(signal["threshold"], (int, float)) or signal["threshold"] <= 0:
            raise ContractError(f"burn-threshold:{index}")

    low = value["lowTraffic"]
    if not isinstance(low, dict):
        raise ContractError("lowTraffic-object")
    require_exact_keys(low, {"name", "sloTarget", "totalEvents", "badEvents", "singleFailureImpact", "automaticActionAllowed"}, "lowTraffic")
    require_text(low["name"], "lowTraffic.name")
    require_ratio(low["sloTarget"], "lowTraffic.sloTarget", include_one=False)
    total = require_count(low["totalEvents"], "lowTraffic.totalEvents", allow_zero=False)
    if require_count(low["badEvents"], "lowTraffic.badEvents") > total:
        raise ContractError("lowTraffic-bad-exceeds-total")
    require_text(low["singleFailureImpact"], "lowTraffic.singleFailureImpact")
    if not isinstance(low["automaticActionAllowed"], bool):
        raise ContractError("lowTraffic-automaticActionAllowed")

    policy = value["policy"]
    if not isinstance(policy, dict):
        raise ContractError("policy-object")
    require_exact_keys(policy, {"service", "remainingBudgetFraction", "measurementValid", "userRiskIncreasingChange", "reliabilityChange", "securityChange", "approvers", "reviewAt"}, "policy")
    for field in ("service", "userRiskIncreasingChange", "reliabilityChange", "securityChange", "reviewAt"):
        require_text(policy[field], f"policy.{field}")
    if not isinstance(policy["remainingBudgetFraction"], (int, float)) or not math.isfinite(policy["remainingBudgetFraction"]):
        raise ContractError("policy.remainingBudgetFraction")
    if not isinstance(policy["measurementValid"], bool):
        raise ContractError("policy.measurementValid")
    if not isinstance(policy["approvers"], list) or len(policy["approvers"]) != 3:
        raise ContractError("policy.approvers")
    for index, approver in enumerate(policy["approvers"]):
        require_text(approver, f"policy.approvers[{index}]")
    return value


def validate_state(path: pathlib.Path, uid: int) -> tuple[dict[str, Any], dict[str, Any]]:
    if path.is_symlink() or not path.is_dir():
        raise ContractError("state-not-directory")
    if path.resolve() != pathlib.Path(f"/tmp/reliability-atlas-les0032-{uid}"):
        raise ContractError("state-realpath")
    if path.stat().st_uid != uid:
        raise ContractError("state-owner")
    entries = {entry.name: entry for entry in path.iterdir()}
    allowed = {"SENTINEL", "manifest.json", "scenario.json"} | ALLOWED_RESULT_NAMES
    unexpected = set(entries) - allowed
    if unexpected:
        raise ContractError(f"unexpected-children:{sorted(unexpected)}")
    for name, entry in entries.items():
        if entry.is_symlink() or not entry.is_file() or entry.stat().st_uid != uid:
            raise ContractError(f"unsafe-child:{name}")
    sentinel = entries.get("SENTINEL")
    manifest_path = entries.get("manifest.json")
    scenario_path = entries.get("scenario.json")
    if sentinel is None or manifest_path is None or scenario_path is None:
        raise ContractError("state-required-files")
    if sentinel.read_text(encoding="utf-8") != f"{LESSON_ID}:{uid}\n":
        raise ContractError("sentinel-content")
    manifest = load_json(manifest_path)
    expected_manifest = {"schemaVersion": 1, "lessonId": LESSON_ID, "uid": uid, "statePath": str(path), "caseId": CASE_ID}
    if manifest != expected_manifest:
        raise ContractError("manifest-content")
    scenario = validate_scenario(scenario_path)
    return manifest, scenario


def round6(value: float) -> float:
    return round(value + 0.0, 6)


def event_result(scenario: dict[str, Any]) -> dict[str, Any]:
    objectives = []
    for row in scenario["eventObjectives"]:
        total = row["totalEvents"]
        good = row["goodEvents"]
        bad = total - good
        allowed = total * (1 - row["target"])
        objectives.append({
            "name": row["name"],
            "goodEvents": good,
            "totalEvents": total,
            "badEvents": bad,
            "sli": round6(good / total),
            "target": row["target"],
            "allowedBadEvents": round6(allowed),
            "remainingBudgetEvents": round6(allowed - bad),
            "budgetConsumedFraction": round6(bad / allowed),
            "compliant": bad <= allowed,
        })
    return {"case": "event-sli", "objectives": objectives, "proofLimit": "Arithmetic over declared fixture populations; not a production SLO or user-impact measurement."}


def time_result(scenario: dict[str, Any]) -> dict[str, Any]:
    row = scenario["timeObjective"]
    total_minutes = row["windowDays"] * 24 * 60
    allowed = total_minutes * (1 - row["target"])
    observed = float(row["badMinutesObserved"])
    return {
        "case": "time-budget",
        "windowMinutes": total_minutes,
        "allowedBadMinutes": round6(allowed),
        "observedBadMinutes": observed,
        "remainingBudgetMinutes": round6(allowed - observed),
        "availability": round6(1 - observed / total_minutes),
        "compliant": observed <= allowed,
        "samplingResolutionSeconds": row["samplingIntervalSeconds"],
        "proofLimit": "Sampling can miss or round boundary failures; reachability is not correctness, durability, or every user journey.",
    }


def latency_result(scenario: dict[str, Any]) -> dict[str, Any]:
    row = scenario["latencyObjective"]
    total = row["totalEvents"]
    good = row["goodEvents"]
    bad = total - good
    allowed = total * (1 - row["target"])
    return {
        "case": "latency",
        "thresholdMilliseconds": row["thresholdMilliseconds"],
        "goodEvents": good,
        "totalEvents": total,
        "badEvents": bad,
        "sli": round6(good / total),
        "target": row["target"],
        "allowedBadEvents": round6(allowed),
        "budgetConsumedFraction": round6(bad / allowed),
        "compliant": bad <= allowed,
        "proofLimit": "A threshold ratio answers how many events met the objective; it does not reveal the tail shape or validate correctness.",
    }


def coverage_result(scenario: dict[str, Any]) -> dict[str, Any]:
    row = scenario["coverage"]
    authoritative = row["authoritativeEligibleEvents"]
    observed = row["observedEligibleEvents"]
    observed_good = row["observedGoodEvents"]
    missing = authoritative - observed
    return {
        "case": "coverage",
        "authoritativeEligibleEvents": authoritative,
        "observedEligibleEvents": observed,
        "missingEvents": missing,
        "coverageRatio": round6(observed / authoritative),
        "observedOnlySli": round6(observed_good / observed),
        "conservativeSli": round6(observed_good / authoritative),
        "measurementValid": observed == authoritative,
        "proofLimit": "The conservative bound is a policy choice for this fixture; missing events are unknown, not proven failures or successes.",
    }


def aggregation_result(scenario: dict[str, Any]) -> dict[str, Any]:
    groups = scenario["aggregation"]["groups"]
    ratios = [{"name": row["name"], "ratio": round6(row["goodEvents"] / row["totalEvents"]), "goodEvents": row["goodEvents"], "totalEvents": row["totalEvents"]} for row in groups]
    sum_good = sum(row["goodEvents"] for row in groups)
    sum_total = sum(row["totalEvents"] for row in groups)
    return {
        "case": "aggregation",
        "groups": ratios,
        "weightedGoodOverTotal": round6(sum_good / sum_total),
        "unweightedMeanOfRatios": round6(sum(row["ratio"] for row in ratios) / len(ratios)),
        "correctMethod": "sum-good-divided-by-sum-total",
        "proofLimit": "Weighted aggregation is valid only when groups share the same eligible and good definitions and do not double count events.",
    }


def burn_result(scenario: dict[str, Any]) -> dict[str, Any]:
    target = scenario["burnWindows"]["sloTarget"]
    sustainable_error_rate = 1 - target
    checkout = scenario["eventObjectives"][0]
    actual_bad = checkout["totalEvents"] - checkout["goodEvents"]
    actual_error_rate = actual_bad / checkout["totalEvents"]
    return {
        "case": "burn",
        "sloTarget": target,
        "sustainableErrorRate": round6(sustainable_error_rate),
        "actualErrorRate": round6(actual_error_rate),
        "burnRate": round6(actual_error_rate / sustainable_error_rate),
        "budgetExhaustionDaysIfSustained": round6(scenario["measurementPeriod"]["days"] / (actual_error_rate / sustainable_error_rate)),
        "proofLimit": "A normalized rate forecasts consumption if the observed rate persists; it does not predict that traffic or error rate will remain constant.",
    }


def alerting_result(scenario: dict[str, Any]) -> dict[str, Any]:
    sustainable = 1 - scenario["burnWindows"]["sloTarget"]
    decisions = []
    for signal in scenario["burnWindows"]["signals"]:
        long_burn = signal["longErrorRate"] / sustainable
        short_burn = signal["shortErrorRate"] / sustainable
        active = long_burn > signal["threshold"] and short_burn > signal["threshold"]
        decisions.append({
            "name": signal["name"],
            "longWindow": signal["longWindow"],
            "shortWindow": signal["shortWindow"],
            "longBurnRate": round6(long_burn),
            "shortBurnRate": round6(short_burn),
            "threshold": signal["threshold"],
            "severity": signal["severity"],
            "active": active,
        })
    return {"case": "alerting", "decisions": decisions, "active": [row["name"] for row in decisions if row["active"]], "proofLimit": "Threshold evaluation does not prove page actionability, measurement validity, routing delivery, or root cause."}


def low_traffic_result(scenario: dict[str, Any]) -> dict[str, Any]:
    row = scenario["lowTraffic"]
    error_rate = row["badEvents"] / row["totalEvents"]
    burn = error_rate / (1 - row["sloTarget"])
    return {
        "case": "low-traffic",
        "totalEvents": row["totalEvents"],
        "badEvents": row["badEvents"],
        "errorRate": round6(error_rate),
        "burnRate": round6(burn),
        "automaticActionAllowed": row["automaticActionAllowed"],
        "decision": "human-impact-and-measurement-review-required",
        "proofLimit": "A mathematically large burn rate from ten events does not by itself establish urgent page value or the correct product target.",
    }


def policy_result(scenario: dict[str, Any]) -> dict[str, Any]:
    row = scenario["policy"]
    exhausted = row["remainingBudgetFraction"] < 0
    actions = {
        row["userRiskIncreasingChange"]: "pause" if exhausted and row["measurementValid"] else "review",
        row["reliabilityChange"]: "eligible-through-reviewed-exception",
        row["securityChange"]: "eligible-through-reviewed-emergency-path",
    }
    return {
        "case": "policy",
        "service": row["service"],
        "budgetExhausted": exhausted,
        "measurementValid": row["measurementValid"],
        "actions": actions,
        "approvers": row["approvers"],
        "decision": "pause-user-risk-increasing-change-and-prioritize-reliability",
        "proofLimit": "The fixture applies a declared policy; it does not authorize any real release, freeze, security exception, or business decision.",
    }


CASE_FUNCTIONS = {
    "event-sli": event_result,
    "time-budget": time_result,
    "latency": latency_result,
    "coverage": coverage_result,
    "aggregation": aggregation_result,
    "burn": burn_result,
    "alerting": alerting_result,
    "low-traffic": low_traffic_result,
    "policy": policy_result,
}


def write_result(state: pathlib.Path, case_name: str, result: dict[str, Any]) -> None:
    destination = state / f"result-{case_name}.json"
    temporary = state / f".result-{case_name}.tmp"
    if temporary.exists() or temporary.is_symlink():
        raise ContractError("temporary-result-exists")
    with temporary.open("x", encoding="utf-8") as handle:
        json.dump(result, handle, sort_keys=True, separators=(",", ":"))
        handle.write("\n")
    os.replace(temporary, destination)


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="action", required=True)
    validate_parser = subparsers.add_parser("validate-scenario")
    validate_parser.add_argument("scenario", type=pathlib.Path)
    state_parser = subparsers.add_parser("validate-state")
    state_parser.add_argument("state", type=pathlib.Path)
    state_parser.add_argument("--uid", required=True, type=int)
    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("case", choices=sorted(CASE_FUNCTIONS))
    run_parser.add_argument("state", type=pathlib.Path)
    run_parser.add_argument("--uid", required=True, type=int)
    args = parser.parse_args()
    try:
        if args.action == "validate-scenario":
            validate_scenario(args.scenario)
            print(f"scenario_valid=true lesson={LESSON_ID} case={CASE_ID}")
            return
        if args.action == "validate-state":
            validate_state(args.state, args.uid)
            print(f"state_valid=true lesson={LESSON_ID} uid={args.uid} path={args.state}")
            return
        _, scenario = validate_state(args.state, args.uid)
        result = CASE_FUNCTIONS[args.case](scenario)
        write_result(args.state, args.case, result)
        print(json.dumps(result, sort_keys=True, separators=(",", ":")))
    except (ContractError, json.JSONDecodeError, OSError, ZeroDivisionError) as exc:
        refuse(str(exc).replace(" ", "-"))


if __name__ == "__main__":
    main()
