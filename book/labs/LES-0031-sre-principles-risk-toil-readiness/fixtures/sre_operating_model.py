#!/usr/bin/env python3
"""Deterministic LES-0031 teaching model; not an organizational or production authority."""

from __future__ import annotations

import argparse
from collections.abc import Callable
import json
import math
import os
from pathlib import Path
import sys
import tempfile
from typing import Any


CASES = (
    "risk",
    "toil",
    "automation",
    "workload",
    "ownership",
    "readiness",
    "operating-review",
    "incident",
)
RESULT_FILES = {f"result-{name}.json" for name in CASES}
ALLOWED_STATE_FILES = {"SENTINEL", "manifest.json", "scenario.json", *RESULT_FILES}


class ContractError(ValueError):
    pass


def fail(message: str) -> None:
    raise ContractError(message)


def load_json(path: Path) -> dict[str, Any]:
    def reject_constant(value: str) -> None:
        fail(f"non-finite-number:{value}")

    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle, parse_constant=reject_constant)
    if not isinstance(value, dict):
        fail("root-not-object")
    return value


def exact_keys(value: dict[str, Any], expected: set[str], location: str) -> None:
    actual = set(value)
    if actual != expected:
        fail(f"keys-invalid:{location}:missing={sorted(expected-actual)}:extra={sorted(actual-expected)}")


def finite_number(value: Any, location: str, minimum: float = 0) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        fail(f"number-invalid:{location}")
    if value < minimum:
        fail(f"number-below-minimum:{location}")
    return float(value)


def nonempty_string(value: Any, location: str) -> str:
    if not isinstance(value, str) or not value.strip():
        fail(f"string-invalid:{location}")
    return value


def validate_scenario(scenario: dict[str, Any]) -> None:
    exact_keys(scenario, {"schemaVersion", "lessonId", "caseId", "risk", "toil", "automation", "workload", "ownership", "readiness", "operatingReview", "incident"}, "root")
    if scenario["schemaVersion"] != 1 or scenario["lessonId"] != "LES-0031" or scenario["caseId"] != "sre-operating-model-v1":
        fail("identity-invalid")

    services = scenario.get("risk", {}).get("services")
    if not isinstance(services, list) or not services:
        fail("risk-services-invalid")
    for index, service in enumerate(services):
        exact_keys(service, {"name", "target", "actual", "quarterEvents", "additionalReliabilityCostHours"}, f"risk.services[{index}]")
        nonempty_string(service["name"], f"risk.services[{index}].name")
        for key in ("target", "actual"):
            value = finite_number(service[key], f"risk.services[{index}].{key}")
            if value <= 0 or value >= 1:
                fail(f"ratio-out-of-range:risk.services[{index}].{key}")
        finite_number(service["quarterEvents"], f"risk.services[{index}].quarterEvents", 1)
        finite_number(service["additionalReliabilityCostHours"], f"risk.services[{index}].additionalReliabilityCostHours")

    tasks = scenario.get("toil", {}).get("tasks")
    task_keys = {"name", "minutesPerOccurrence", "occurrencesPerWeek", "manual", "repetitive", "automatable", "tactical", "noEnduringValue", "scalesWithGrowth"}
    if not isinstance(tasks, list) or not tasks:
        fail("toil-tasks-invalid")
    for index, task in enumerate(tasks):
        exact_keys(task, task_keys, f"toil.tasks[{index}]")
        nonempty_string(task["name"], f"toil.tasks[{index}].name")
        finite_number(task["minutesPerOccurrence"], f"toil.tasks[{index}].minutesPerOccurrence")
        finite_number(task["occurrencesPerWeek"], f"toil.tasks[{index}].occurrencesPerWeek")
        for key in task_keys - {"name", "minutesPerOccurrence", "occurrencesPerWeek"}:
            if not isinstance(task[key], bool):
                fail(f"boolean-invalid:toil.tasks[{index}].{key}")

    automation = scenario.get("automation", {})
    exact_keys(automation, {"candidates", "weeksPerQuarter"}, "automation")
    finite_number(automation["weeksPerQuarter"], "automation.weeksPerQuarter", 1)
    if not isinstance(automation["candidates"], list) or not automation["candidates"]:
        fail("automation-candidates-invalid")
    for index, candidate in enumerate(automation["candidates"]):
        exact_keys(candidate, {"name", "buildHours", "quarterMaintenanceHours", "minutesSavedPerOccurrence", "occurrencesPerWeek", "quarterRiskReductionHours"}, f"automation.candidates[{index}]")
        nonempty_string(candidate["name"], f"automation.candidates[{index}].name")
        for key in set(candidate) - {"name"}:
            finite_number(candidate[key], f"automation.candidates[{index}].{key}")

    workload = scenario.get("workload", {})
    exact_keys(workload, {"engineers", "hoursPerEngineerWeek", "toilHours", "nonToilOperationalHours", "overheadHours", "minimumEngineeringFraction"}, "workload")
    for key in ("engineers", "hoursPerEngineerWeek", "toilHours", "nonToilOperationalHours", "overheadHours"):
        finite_number(workload[key], f"workload.{key}", 1 if key in {"engineers", "hoursPerEngineerWeek"} else 0)
    fraction = finite_number(workload["minimumEngineeringFraction"], "workload.minimumEngineeringFraction")
    if fraction > 1:
        fail("workload-minimum-fraction-invalid")

    ownership = scenario.get("ownership", {})
    exact_keys(ownership, {"requiredDecisions", "assignments"}, "ownership")
    if not isinstance(ownership["requiredDecisions"], list) or not isinstance(ownership["assignments"], dict):
        fail("ownership-shape-invalid")
    if len(set(ownership["requiredDecisions"])) != len(ownership["requiredDecisions"]):
        fail("ownership-required-duplicate")
    for index, name in enumerate(ownership["requiredDecisions"]):
        nonempty_string(name, f"ownership.requiredDecisions[{index}]")
    for key, value in ownership["assignments"].items():
        nonempty_string(key, "ownership.assignment-key")
        nonempty_string(value, f"ownership.assignments.{key}")

    controls = scenario.get("readiness", {}).get("controls")
    if not isinstance(controls, list) or not controls:
        fail("readiness-controls-invalid")
    for index, control in enumerate(controls):
        exact_keys(control, {"name", "required", "state", "evidence"}, f"readiness.controls[{index}]")
        nonempty_string(control["name"], f"readiness.controls[{index}].name")
        if not isinstance(control["required"], bool) or control["state"] not in {"present", "missing", "accepted-risk"} or not isinstance(control["evidence"], str):
            fail(f"readiness-control-invalid:{index}")
        if control["state"] != "missing" and not control["evidence"].strip():
            fail(f"readiness-evidence-missing:{index}")

    review = scenario.get("operatingReview", {})
    exact_keys(review, {"periods", "toilLimitHours", "pageLimit"}, "operatingReview")
    finite_number(review["toilLimitHours"], "operatingReview.toilLimitHours")
    finite_number(review["pageLimit"], "operatingReview.pageLimit")
    if not isinstance(review["periods"], list) or not review["periods"]:
        fail("operating-review-periods-invalid")
    for index, period in enumerate(review["periods"]):
        exact_keys(period, {"name", "sloMet", "changeFailures", "pages", "toilHours"}, f"operatingReview.periods[{index}]")
        nonempty_string(period["name"], f"operatingReview.periods[{index}].name")
        if not isinstance(period["sloMet"], bool):
            fail(f"boolean-invalid:operatingReview.periods[{index}].sloMet")
        for key in ("changeFailures", "pages", "toilHours"):
            finite_number(period[key], f"operatingReview.periods[{index}].{key}")

    incident = scenario.get("incident", {})
    exact_keys(incident, {"symptom", "facts", "earliestSupportedBoundary", "unsafeFirstMoves"}, "incident")
    nonempty_string(incident["symptom"], "incident.symptom")
    nonempty_string(incident["earliestSupportedBoundary"], "incident.earliestSupportedBoundary")
    for field in ("facts", "unsafeFirstMoves"):
        if not isinstance(incident[field], list) or not incident[field]:
            fail(f"incident-{field}-invalid")
        for index, item in enumerate(incident[field]):
            nonempty_string(item, f"incident.{field}[{index}]")


def validate_state(state_dir: Path, expected_uid: int) -> dict[str, Any]:
    expected = Path(f"/tmp/reliability-atlas-les0031-{expected_uid}")
    if state_dir != expected or state_dir.is_symlink() or not state_dir.is_dir():
        fail("state-directory-invalid")
    stat_result = state_dir.stat()
    if stat_result.st_uid != expected_uid or (stat_result.st_mode & 0o077) != 0:
        fail("state-owner-or-mode-invalid")
    entries = {entry.name for entry in state_dir.iterdir()}
    unexpected = entries - ALLOWED_STATE_FILES
    if unexpected:
        fail(f"state-unexpected-entry:{sorted(unexpected)}")
    for entry in state_dir.iterdir():
        if entry.is_symlink() or not entry.is_file() or entry.stat().st_uid != expected_uid:
            fail(f"state-child-invalid:{entry.name}")
    sentinel = (state_dir / "SENTINEL").read_text(encoding="utf-8")
    if sentinel != f"LES-0031:{expected_uid}\n":
        fail("sentinel-invalid")
    manifest = load_json(state_dir / "manifest.json")
    exact_keys(manifest, {"schemaVersion", "lessonId", "uid", "statePath", "caseId"}, "manifest")
    if manifest != {"schemaVersion": 1, "lessonId": "LES-0031", "uid": expected_uid, "statePath": str(expected), "caseId": "sre-operating-model-v1"}:
        fail("manifest-invalid")
    scenario = load_json(state_dir / "scenario.json")
    validate_scenario(scenario)
    return scenario


def risk_case(scenario: dict[str, Any]) -> dict[str, Any]:
    rows = []
    for service in scenario["risk"]["services"]:
        allowed_bad = 1 - service["target"]
        observed_bad = 1 - service["actual"]
        allowed_bad_events = service["quarterEvents"] * allowed_bad
        observed_bad_events = service["quarterEvents"] * observed_bad
        remaining = allowed_bad_events - observed_bad_events
        rows.append({
            "name": service["name"],
            "allowedBadFraction": round(allowed_bad, 6),
            "observedBadFraction": round(observed_bad, 6),
            "allowedBadEvents": round(allowed_bad_events, 3),
            "observedBadEvents": round(observed_bad_events, 3),
            "remainingBudgetEvents": round(remaining, 3),
            "budgetState": "available" if remaining >= 0 else "exhausted",
            "additionalReliabilityCostHours": service["additionalReliabilityCostHours"],
        })
    return {"case": "risk", "rows": rows, "exhausted": [row["name"] for row in rows if row["budgetState"] == "exhausted"], "proofLimit": "declared event ratios and engineering-cost estimates only; not business risk acceptance or SLO validity"}


def toil_case(scenario: dict[str, Any]) -> dict[str, Any]:
    rows = []
    for task in scenario["toil"]["tasks"]:
        properties = [task[key] for key in ("manual", "repetitive", "automatable", "tactical", "noEnduringValue", "scalesWithGrowth")]
        score = sum(properties)
        weekly_minutes = task["minutesPerOccurrence"] * task["occurrencesPerWeek"]
        rows.append({"name": task["name"], "propertyCount": score, "classification": "toil-candidate" if score >= 4 else "not-toil-by-fixture", "weeklyMinutes": weekly_minutes})
    total = sum(row["weeklyMinutes"] for row in rows)
    toil = sum(row["weeklyMinutes"] for row in rows if row["classification"] == "toil-candidate")
    return {"case": "toil", "rows": rows, "totalMinutes": total, "toilMinutes": toil, "toilFraction": round(toil / total, 6), "proofLimit": "fixture heuristic supports discussion; real toil classification requires context, risk, value, and team review"}


def automation_case(scenario: dict[str, Any]) -> dict[str, Any]:
    weeks = scenario["automation"]["weeksPerQuarter"]
    rows = []
    for candidate in scenario["automation"]["candidates"]:
        weekly_saved = candidate["minutesSavedPerOccurrence"] * candidate["occurrencesPerWeek"] / 60
        quarter_gross = weekly_saved * weeks + candidate["quarterRiskReductionHours"]
        quarter_net = quarter_gross - candidate["quarterMaintenanceHours"]
        break_even = None if weekly_saved == 0 else candidate["buildHours"] / weekly_saved
        rows.append({"name": candidate["name"], "weeklyLaborSavedHours": round(weekly_saved, 3), "quarterNetBenefitHoursBeforeBuild": round(quarter_net, 3), "breakEvenWeeksIgnoringMaintenanceAndRisk": None if break_even is None else round(break_even, 3), "firstQuarterNetAfterBuildHours": round(quarter_net - candidate["buildHours"], 3)})
    return {"case": "automation", "rows": rows, "bestFirstQuarter": max(rows, key=lambda row: row["firstQuarterNetAfterBuildHours"])["name"], "proofLimit": "declared estimates only; does not include adoption, failure, opportunity cost, security, or maintenance uncertainty"}


def workload_case(scenario: dict[str, Any]) -> dict[str, Any]:
    work = scenario["workload"]
    capacity = work["engineers"] * work["hoursPerEngineerWeek"]
    engineering = capacity - work["toilHours"] - work["nonToilOperationalHours"] - work["overheadHours"]
    required = capacity * work["minimumEngineeringFraction"]
    return {"case": "workload", "capacityHours": capacity, "engineeringHours": engineering, "engineeringFraction": round(engineering / capacity, 6), "requiredEngineeringHours": required, "engineeringGapHours": max(0, required - engineering), "sustainableByFixture": engineering >= required, "proofLimit": "declared weekly allocation only; not individual health, staffing sufficiency, or a universal 50 percent rule"}


def ownership_case(scenario: dict[str, Any]) -> dict[str, Any]:
    ownership = scenario["ownership"]
    required = ownership["requiredDecisions"]
    assignments = ownership["assignments"]
    missing = sorted(set(required) - set(assignments))
    return {"case": "ownership", "requiredCount": len(required), "assignedCount": len(set(required) & set(assignments)), "missing": missing, "coverageFraction": round((len(required) - len(missing)) / len(required), 6), "proofLimit": "named roles do not prove authority, competence, availability, handoff, or exercised accountability"}


def readiness_case(scenario: dict[str, Any]) -> dict[str, Any]:
    controls = scenario["readiness"]["controls"]
    blockers = [item["name"] for item in controls if item["required"] and item["state"] != "present"]
    accepted = [item["name"] for item in controls if item["state"] == "accepted-risk"]
    return {"case": "readiness", "requiredCount": sum(item["required"] for item in controls), "presentRequiredCount": sum(item["required"] and item["state"] == "present" for item in controls), "blockers": blockers, "acceptedRisks": accepted, "decision": "no-go" if blockers else "review-for-go", "proofLimit": "checklist evidence only; final launch authority and unmodelled risks remain outside this fixture"}


def operating_review_case(scenario: dict[str, Any]) -> dict[str, Any]:
    review = scenario["operatingReview"]
    rows = []
    for period in review["periods"]:
        reasons = []
        if not period["sloMet"]:
            reasons.append("slo-breach")
        if period["pages"] > review["pageLimit"]:
            reasons.append("page-load")
        if period["toilHours"] > review["toilLimitHours"]:
            reasons.append("toil-load")
        if period["changeFailures"] > 1:
            reasons.append("change-risk")
        rows.append({"name": period["name"], "interventionReasons": reasons, "needsIntervention": bool(reasons)})
    return {"case": "operating-review", "rows": rows, "interventionPeriods": [row["name"] for row in rows if row["needsIntervention"]], "proofLimit": "threshold triage over three fixture periods; not causal analysis, policy approval, or a complete operating review"}


def incident_case(scenario: dict[str, Any]) -> dict[str, Any]:
    incident = scenario["incident"]
    return {"case": "incident", "symptom": incident["symptom"], "facts": incident["facts"], "earliestSupportedBoundary": incident["earliestSupportedBoundary"], "safeFirstMove": "declare service and team health risks, establish shared owners and user reliability contract, measure work and pages, protect response coverage, then remove the highest-risk recurring source", "unsafeFirstMoves": incident["unsafeFirstMoves"], "proofLimit": "guided facts support an operating-model diagnosis; they do not prove motives, individual performance, or a universal organization design"}


RUNNERS: dict[str, Callable[[dict[str, Any]], dict[str, Any]]] = {
    "risk": risk_case,
    "toil": toil_case,
    "automation": automation_case,
    "workload": workload_case,
    "ownership": ownership_case,
    "readiness": readiness_case,
    "operating-review": operating_review_case,
    "incident": incident_case,
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
    scenario_parser = subparsers.add_parser("validate-scenario")
    scenario_parser.add_argument("path", type=Path)
    state_parser = subparsers.add_parser("validate-state")
    state_parser.add_argument("state", type=Path)
    state_parser.add_argument("--uid", type=int, required=True)
    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("case", choices=sorted(CASES))
    run_parser.add_argument("state", type=Path)
    run_parser.add_argument("--uid", type=int, required=True)
    arguments = parser.parse_args()
    try:
        if arguments.command == "validate-scenario":
            scenario = load_json(arguments.path)
            validate_scenario(scenario)
            print("scenario_valid=true lesson=LES-0031 case=sre-operating-model-v1")
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
    except (ContractError, OSError, json.JSONDecodeError, TypeError, KeyError, ZeroDivisionError) as error:
        print(f"refused=true reason={error}", file=sys.stderr)
        return 78


if __name__ == "__main__":
    raise SystemExit(main())
