#!/usr/bin/env python3
"""Deterministic, disconnected teaching model for LES-0033.

This program validates and evaluates fictional incident-response data. It does
not contact, simulate, or authorize a real incident or production system.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import stat
import sys
from typing import Any

LESSON_ID = "LES-0033"
CASE_ID = "incident-command-v1"
CASE_NAMES = (
    "triage",
    "roles",
    "mitigation",
    "recovery",
    "communication",
    "handoff",
    "review",
)
RESULT_NAMES = {f"result-{name}.json" for name in CASE_NAMES}
BASE_NAMES = {"SENTINEL", "manifest.json", "scenario.json"}
ALLOWED_NAMES = BASE_NAMES | RESULT_NAMES


class Refusal(ValueError):
    """A checked contract was not satisfied."""


def refuse(reason: str) -> None:
    raise Refusal(reason)


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        refuse(f"json-invalid path={path.name} detail={type(exc).__name__}")
    if not isinstance(value, dict):
        refuse(f"json-root-not-object path={path.name}")
    return value


def exact_keys(value: dict[str, Any], expected: set[str], label: str) -> None:
    actual = set(value)
    if actual != expected:
        refuse(
            f"keys-invalid label={label} "
            f"missing={sorted(expected - actual)} extra={sorted(actual - expected)}"
        )


def require(condition: bool, reason: str) -> None:
    if not condition:
        refuse(reason)


def is_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def validate_scenario(value: dict[str, Any]) -> None:
    exact_keys(
        value,
        {
            "schemaVersion",
            "lessonId",
            "caseId",
            "incident",
            "severityPolicy",
            "roles",
            "mitigationCandidates",
            "recovery",
            "communication",
            "handoff",
            "review",
        },
        "scenario",
    )
    require(value["schemaVersion"] == 1, "scenario-version-invalid")
    require(value["lessonId"] == LESSON_ID, "scenario-lesson-invalid")
    require(value["caseId"] == CASE_ID, "scenario-case-invalid")

    incident = value["incident"]
    require(isinstance(incident, dict), "incident-not-object")
    exact_keys(
        incident,
        {
            "id",
            "detectedAt",
            "declaredAt",
            "journey",
            "regionsAffected",
            "failurePercent",
            "multiTeamResponse",
            "criticalBusinessJourney",
            "trend",
        },
        "incident",
    )
    require(incident["id"] == "INC-FICTIONAL-017", "incident-id-invalid")
    require(
        isinstance(incident["regionsAffected"], list)
        and len(incident["regionsAffected"]) == 2
        and len(set(incident["regionsAffected"])) == 2,
        "incident-regions-invalid",
    )
    require(incident["multiTeamResponse"] is True, "incident-team-scope-invalid")
    require(incident["criticalBusinessJourney"] is True, "incident-criticality-invalid")
    require(incident["trend"] in {"worsening", "stable", "improving"}, "incident-trend-invalid")
    failure = incident["failurePercent"]
    require(isinstance(failure, dict) and set(failure) == set(incident["regionsAffected"]), "failure-regions-invalid")
    require(all(is_number(item) and 0 <= item <= 100 for item in failure.values()), "failure-percent-invalid")

    policy = value["severityPolicy"]
    require(isinstance(policy, dict), "severity-policy-not-object")
    exact_keys(
        policy,
        {
            "criticalLabel",
            "declareOnCriticalJourney",
            "declareOnMultipleRegions",
            "declareOnMultipleTeams",
        },
        "severityPolicy",
    )
    require(policy["criticalLabel"] == "SEV-1", "severity-label-invalid")
    require(
        all(policy[key] is True for key in policy if key != "criticalLabel"),
        "severity-policy-criteria-invalid",
    )

    roles = value["roles"]
    required_roles = {
        "incident-commander",
        "operations-lead",
        "communications-lead",
        "planning-lead",
    }
    require(isinstance(roles, list) and len(roles) == 4, "roles-count-invalid")
    for index, role in enumerate(roles):
        require(isinstance(role, dict), f"role-not-object index={index}")
        exact_keys(role, {"role", "owner", "acknowledged"}, f"roles[{index}]")
        require(isinstance(role["owner"], str) and role["owner"], f"role-owner-invalid index={index}")
        require(isinstance(role["acknowledged"], bool), f"role-ack-invalid index={index}")
    require({role["role"] for role in roles} == required_roles, "role-set-invalid")
    require(len({role["owner"] for role in roles}) == 4, "role-owner-conflict")

    candidates = value["mitigationCandidates"]
    require(isinstance(candidates, list) and len(candidates) == 4, "mitigation-count-invalid")
    candidate_names: set[str] = set()
    for index, candidate in enumerate(candidates):
        require(isinstance(candidate, dict), f"mitigation-not-object index={index}")
        exact_keys(
            candidate,
            {
                "name",
                "reliefMinutes",
                "reversibility",
                "blastRadiusSafety",
                "confidence",
                "evidencePreservation",
                "newRisk",
                "authorized",
            },
            f"mitigationCandidates[{index}]",
        )
        require(candidate["name"] not in candidate_names, "mitigation-name-duplicate")
        candidate_names.add(candidate["name"])
        require(is_number(candidate["reliefMinutes"]) and candidate["reliefMinutes"] > 0, "mitigation-relief-invalid")
        for key in ("reversibility", "blastRadiusSafety", "confidence", "evidencePreservation", "newRisk"):
            require(is_number(candidate[key]) and 1 <= candidate[key] <= 5, f"mitigation-score-invalid key={key}")
        require(isinstance(candidate["authorized"], bool), "mitigation-authorization-invalid")
    require("disable-promotion-enrichment" in candidate_names, "mitigation-required-candidate-missing")

    recovery = value["recovery"]
    require(isinstance(recovery, dict), "recovery-not-object")
    exact_keys(
        recovery,
        {
            "journeyErrorWindows",
            "maximumErrorFraction",
            "telemetryCoverage",
            "minimumCoverage",
            "queuesDraining",
            "dataIntegrity",
            "dependenciesHealthy",
            "capacityHeadroomPercent",
            "minimumHeadroomPercent",
            "observeMinutes",
        },
        "recovery",
    )
    windows = recovery["journeyErrorWindows"]
    require(isinstance(windows, list) and len(windows) == 3, "recovery-windows-invalid")
    require(all(is_number(item) and 0 <= item <= 1 for item in windows), "recovery-window-value-invalid")
    for key in ("maximumErrorFraction", "telemetryCoverage", "minimumCoverage"):
        require(is_number(recovery[key]) and 0 <= recovery[key] <= 1, f"recovery-ratio-invalid key={key}")
    require(is_number(recovery["capacityHeadroomPercent"]), "recovery-headroom-invalid")
    require(is_number(recovery["minimumHeadroomPercent"]), "recovery-minimum-headroom-invalid")
    require(isinstance(recovery["observeMinutes"], int) and recovery["observeMinutes"] > 0, "recovery-observation-invalid")
    require(isinstance(recovery["queuesDraining"], bool), "recovery-queue-invalid")
    require(isinstance(recovery["dependenciesHealthy"], bool), "recovery-dependency-invalid")
    require(recovery["dataIntegrity"] in {"verified", "failed", "unknown"}, "recovery-integrity-invalid")

    communication = value["communication"]
    require(isinstance(communication, dict), "communication-not-object")
    communication_keys = {
        "timestamp",
        "state",
        "impact",
        "scope",
        "action",
        "result",
        "uncertainty",
        "workaround",
        "owner",
        "nextUpdateAt",
        "speculativeClaims",
    }
    exact_keys(communication, communication_keys, "communication")
    require(
        all(isinstance(communication[key], str) and communication[key] for key in communication_keys - {"speculativeClaims"}),
        "communication-field-invalid",
    )
    require(isinstance(communication["speculativeClaims"], list), "communication-speculation-invalid")

    handoff = value["handoff"]
    require(isinstance(handoff, dict), "handoff-not-object")
    handoff_keys = {
        "sender",
        "receiver",
        "liveBriefing",
        "scopeTransferred",
        "rolesTransferred",
        "actionsTransferred",
        "risksTransferred",
        "communicationsTransferred",
        "accessChecked",
        "receiverRestatedPriorities",
        "accepted",
        "broadcast",
    }
    exact_keys(handoff, handoff_keys, "handoff")
    require(isinstance(handoff["sender"], str) and handoff["sender"], "handoff-sender-invalid")
    require(isinstance(handoff["receiver"], str) and handoff["receiver"], "handoff-receiver-invalid")
    require(handoff["sender"] != handoff["receiver"], "handoff-parties-conflict")
    require(all(isinstance(handoff[key], bool) for key in handoff_keys - {"sender", "receiver"}), "handoff-flag-invalid")

    review = value["review"]
    require(isinstance(review, dict), "review-not-object")
    exact_keys(
        review,
        {"impactQuantified", "timelineSourcesReconciled", "blameTerms", "causalLinks", "actions"},
        "review",
    )
    require(isinstance(review["blameTerms"], list), "review-blame-terms-invalid")
    require(isinstance(review["causalLinks"], list) and len(review["causalLinks"]) >= 5, "review-causal-links-invalid")
    require(isinstance(review["actions"], list) and len(review["actions"]) >= 4, "review-actions-invalid")
    for index, action in enumerate(review["actions"]):
        require(isinstance(action, dict), f"review-action-not-object index={index}")
        exact_keys(action, {"id", "owner", "acceptanceTest", "riskType"}, f"review.actions[{index}]")
        require(all(isinstance(action[key], str) and action[key] for key in action), f"review-action-field-invalid index={index}")


def regular_owned_file(path: Path, uid: int) -> None:
    details = path.lstat()
    require(stat.S_ISREG(details.st_mode), f"state-child-not-regular child={path.name}")
    require(details.st_uid == uid, f"state-child-owner-invalid child={path.name}")


def validate_state(path: Path, uid: int) -> dict[str, Any]:
    expected = Path(f"/tmp/reliability-atlas-les0033-{uid}")
    require(path == expected, "state-path-invalid")
    require(path.parent.resolve(strict=True) == Path("/tmp"), "state-parent-invalid")
    details = path.lstat()
    require(stat.S_ISDIR(details.st_mode), "state-root-not-directory")
    require(details.st_uid == uid, "state-root-owner-invalid")
    require(path.resolve(strict=True) == expected, "state-root-realpath-invalid")
    children = list(path.iterdir())
    names = {child.name for child in children}
    require(BASE_NAMES <= names, f"state-required-child-missing names={sorted(names)}")
    require(names <= ALLOWED_NAMES, f"state-unexpected-child names={sorted(names - ALLOWED_NAMES)}")
    for child in children:
        require(not child.is_symlink(), f"state-child-symlink child={child.name}")
        regular_owned_file(child, uid)
    require((path / "SENTINEL").read_text(encoding="utf-8") == f"{LESSON_ID}:{uid}\n", "state-sentinel-invalid")
    manifest = load_json(path / "manifest.json")
    exact_keys(manifest, {"schemaVersion", "lessonId", "uid", "statePath", "caseId"}, "manifest")
    require(manifest["schemaVersion"] == 1, "manifest-version-invalid")
    require(manifest["lessonId"] == LESSON_ID, "manifest-lesson-invalid")
    require(manifest["uid"] == uid, "manifest-uid-invalid")
    require(manifest["statePath"] == str(expected), "manifest-path-invalid")
    require(manifest["caseId"] == CASE_ID, "manifest-case-invalid")
    scenario = load_json(path / "scenario.json")
    validate_scenario(scenario)
    return scenario


def mitigation_score(item: dict[str, Any]) -> float:
    return round(
        item["reversibility"]
        + item["blastRadiusSafety"]
        + item["confidence"]
        + item["evidencePreservation"]
        - item["newRisk"]
        - item["reliefMinutes"] / 10,
        3,
    )


def evaluate(case_name: str, scenario: dict[str, Any]) -> dict[str, Any]:
    incident = scenario["incident"]
    if case_name == "triage":
        policy = scenario["severityPolicy"]
        declaration_reasons = [
            "critical-user-journey",
            "multiple-regions",
            "multiple-teams",
            "worsening-impact",
        ]
        return {
            "case": case_name,
            "declare": bool(
                incident["criticalBusinessJourney"]
                and len(incident["regionsAffected"]) >= 2
                and incident["multiTeamResponse"]
            ),
            "severity": policy["criticalLabel"],
            "reasons": declaration_reasons,
            "objective": incident["journey"],
            "proofLimit": "fictional policy mapping is not real incident authority",
        }
    if case_name == "roles":
        roles = scenario["roles"]
        owners = [item["owner"] for item in roles]
        missing = [item["role"] for item in roles if not item["acknowledged"]]
        conflicts = len(owners) - len(set(owners))
        return {
            "case": case_name,
            "coverage": "complete" if not missing and conflicts == 0 else "incomplete",
            "required": len(roles),
            "acknowledged": len(roles) - len(missing),
            "missing": missing,
            "conflicts": conflicts,
            "proofLimit": "role records do not prove readiness, access, or coordination quality",
        }
    if case_name == "mitigation":
        ranked = sorted(
            (
                {
                    "name": item["name"],
                    "score": mitigation_score(item),
                    "authorized": item["authorized"],
                }
                for item in scenario["mitigationCandidates"]
            ),
            key=lambda item: (-item["score"], item["name"]),
        )
        eligible = [item for item in ranked if item["authorized"]]
        selected = eligible[0]["name"] if eligible else None
        return {
            "case": case_name,
            "selected": selected,
            "ranked": ranked,
            "rejectedUnsafe": [item["name"] for item in ranked if not item["authorized"]],
            "proofLimit": "deterministic fixture weights do not authorize production mutation",
        }
    if case_name == "recovery":
        recovery = scenario["recovery"]
        gates = {
            "journeyWindowsHealthy": all(
                item <= recovery["maximumErrorFraction"]
                for item in recovery["journeyErrorWindows"]
            ),
            "coverageValid": recovery["telemetryCoverage"] >= recovery["minimumCoverage"],
            "queuesDraining": recovery["queuesDraining"],
            "dataIntegrityVerified": recovery["dataIntegrity"] == "verified",
            "dependenciesHealthy": recovery["dependenciesHealthy"],
            "capacityHealthy": recovery["capacityHeadroomPercent"] >= recovery["minimumHeadroomPercent"],
        }
        return {
            "case": case_name,
            "userRecovered": all(gates.values()),
            "gates": gates,
            "queuesDraining": recovery["queuesDraining"],
            "dataIntegrity": recovery["dataIntegrity"],
            "observeMinutes": recovery["observeMinutes"],
            "proofLimit": "fixture predicates do not prove real users recovered or future stability",
        }
    if case_name == "communication":
        communication = scenario["communication"]
        required = [
            "timestamp",
            "state",
            "impact",
            "scope",
            "action",
            "result",
            "uncertainty",
            "workaround",
            "owner",
            "nextUpdateAt",
        ]
        missing = [key for key in required if not communication[key]]
        return {
            "case": case_name,
            "requiredFields": "complete" if not missing else "incomplete",
            "missing": missing,
            "speculativeClaims": len(communication["speculativeClaims"]),
            "nextUpdateAt": communication["nextUpdateAt"],
            "proofLimit": "format checks do not prove delivery, truth, approval, or audience comprehension",
        }
    if case_name == "handoff":
        handoff = scenario["handoff"]
        checks = [
            "liveBriefing",
            "scopeTransferred",
            "rolesTransferred",
            "actionsTransferred",
            "risksTransferred",
            "communicationsTransferred",
            "accessChecked",
            "receiverRestatedPriorities",
            "accepted",
            "broadcast",
        ]
        gaps = [key for key in checks if not handoff[key]]
        return {
            "case": case_name,
            "accepted": handoff["accepted"] and not gaps,
            "sender": handoff["sender"],
            "receiver": handoff["receiver"],
            "gaps": len(gaps),
            "gapFields": gaps,
            "broadcast": handoff["broadcast"],
            "proofLimit": "fixture completion does not prove human understanding, fitness, or access",
        }
    if case_name == "review":
        review = scenario["review"]
        actionable = [
            item
            for item in review["actions"]
            if item["owner"] and item["acceptanceTest"] and item["riskType"]
        ]
        return {
            "case": case_name,
            "impactQuantified": review["impactQuantified"],
            "timelineReconciled": review["timelineSourcesReconciled"],
            "blameTerms": len(review["blameTerms"]),
            "causalLinks": len(review["causalLinks"]),
            "actionableItems": len(actionable),
            "riskTypes": sorted({item["riskType"] for item in actionable}),
            "proofLimit": "a well-shaped review does not prove action closure or reduced recurrence",
        }
    refuse(f"case-unknown name={case_name}")


def write_result(path: Path, value: dict[str, Any]) -> None:
    temporary = path.with_suffix(".tmp")
    try:
        temporary.write_text(
            json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n",
            encoding="utf-8",
        )
        os.chmod(temporary, 0o600)
        os.replace(temporary, path)
    finally:
        if temporary.exists() and not temporary.is_symlink():
            temporary.unlink()


def command_validate_scenario(path: Path) -> None:
    scenario = load_json(path)
    validate_scenario(scenario)
    print(f"scenario_valid=true lesson={LESSON_ID} case={CASE_ID} cases={len(CASE_NAMES)}")


def command_validate_state(path: Path, uid: int) -> None:
    validate_state(path, uid)
    print(f"state_valid=true lesson={LESSON_ID} uid={uid} path={path}")


def command_run(case_name: str, state_path: Path, uid: int) -> None:
    require(case_name in CASE_NAMES, f"case-unknown name={case_name}")
    scenario = validate_state(state_path, uid)
    result = evaluate(case_name, scenario)
    output = state_path / f"result-{case_name}.json"
    write_result(output, result)
    validate_state(state_path, uid)
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    subcommands = root.add_subparsers(dest="command", required=True)
    validate_scenario_parser = subcommands.add_parser("validate-scenario")
    validate_scenario_parser.add_argument("path", type=Path)
    validate_state_parser = subcommands.add_parser("validate-state")
    validate_state_parser.add_argument("path", type=Path)
    validate_state_parser.add_argument("--uid", required=True, type=int)
    run_parser = subcommands.add_parser("run")
    run_parser.add_argument("case", choices=CASE_NAMES)
    run_parser.add_argument("state", type=Path)
    run_parser.add_argument("--uid", required=True, type=int)
    return root


def main() -> int:
    arguments = parser().parse_args()
    try:
        if arguments.command == "validate-scenario":
            command_validate_scenario(arguments.path)
        elif arguments.command == "validate-state":
            command_validate_state(arguments.path, arguments.uid)
        elif arguments.command == "run":
            command_run(arguments.case, arguments.state, arguments.uid)
        else:
            refuse("command-invalid")
    except Refusal as exc:
        print(f"refused=true reason={exc}", file=sys.stderr)
        return 78
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
