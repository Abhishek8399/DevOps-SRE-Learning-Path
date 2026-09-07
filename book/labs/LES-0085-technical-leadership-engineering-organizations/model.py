#!/usr/bin/env python3
"""Deterministic fictional leadership-review model; no people, messaging, ticket or runtime calls."""
from __future__ import annotations

import json
import sys
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path
from typing import Any


def fail(message: str) -> None:
    raise ValueError(message)


def load(path: str) -> dict[str, Any]:
    value = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        fail("root-not-object")
    return value


def number(value: Any, label: str) -> int:
    if not isinstance(value, int) or isinstance(value, bool) or value < 0:
        fail(label)
    return value


def percent(numerator: int, denominator: int) -> str:
    if denominator <= 0:
        fail("zero-denominator")
    value = (Decimal(numerator) * Decimal(100) / Decimal(denominator)).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )
    return f"{value:.2f}"


def gate_map(document: dict[str, Any]) -> dict[str, str]:
    groups = document.get("gate_groups")
    if not isinstance(groups, list) or not groups:
        fail("gate-groups")
    result: dict[str, str] = {}
    for group in groups:
        boundary = group.get("boundary")
        cases = group.get("cases")
        if not isinstance(boundary, str) or not boundary or not isinstance(cases, list):
            fail("gate-group-shape")
        for name in cases:
            if not isinstance(name, str) or not name or name in result:
                fail("case-identity")
            result[name] = boundary
    return result


def validate(cases_path: str, packet_path: str) -> None:
    case_doc = load(cases_path)
    packet = load(packet_path)
    if case_doc.get("lesson_id") != "LES-0085":
        fail("lesson-id")
    gates = gate_map(case_doc)
    baseline = case_doc.get("baseline")
    if baseline not in gates or gates[baseline] != "baseline":
        fail("baseline")
    if len(gates) != 73 or sum(1 for value in gates.values() if value != "baseline") != 72:
        fail("gate-count")
    if packet.get("packet_id") != "fictional-checkout-platform-leadership":
        fail("packet-id")

    priorities = packet.get("priorities")
    if not isinstance(priorities, dict):
        fail("priorities")
    p = {key: number(priorities.get(key), key) for key in (
        "available_points", "committed_points", "reserve_points",
        "requested_points", "stopped_points", "selected_outcome_value"
    )}
    if p["committed_points"] + p["reserve_points"] != p["available_points"]:
        fail("capacity-conservation")
    if p["requested_points"] - p["available_points"] != p["stopped_points"]:
        fail("stopped-work")

    delegation = packet.get("delegation")
    if not isinstance(delegation, dict):
        fail("delegation")
    d = {key: number(delegation.get(key), key) for key in (
        "outcomes", "outcome_defined", "authority_bounded", "information_available",
        "resources_available", "checkback_defined", "escalation_defined"
    )}
    if any(value > d["outcomes"] for key, value in d.items() if key != "outcomes"):
        fail("delegation-coverage")

    decisions = packet.get("decisions")
    if not isinstance(decisions, dict):
        fail("decisions")
    q = {key: number(decisions.get(key), key) for key in (
        "total", "within_deadline", "escalated_by_deadline", "unresolved",
        "material_objections_recorded"
    )}
    if q["within_deadline"] + q["escalated_by_deadline"] + q["unresolved"] != q["total"]:
        fail("decision-conservation")

    stakeholders = packet.get("stakeholders")
    if not isinstance(stakeholders, dict):
        fail("stakeholders")
    s = {key: number(stakeholders.get(key), key) for key in (
        "canonical_facts", "views", "required_links", "present_links", "conflicts"
    )}
    if s["present_links"] > s["required_links"]:
        fail("stakeholder-links")

    team_load = packet.get("team_load")
    if not isinstance(team_load, dict):
        fail("team-load")
    t = {key: number(team_load.get(key), key) for key in (
        "pages", "responders", "minimum", "maximum",
        "acknowledged_handoffs", "required_handoffs"
    )}
    if t["minimum"] > t["maximum"] or t["maximum"] > t["pages"]:
        fail("load-range")
    if t["acknowledged_handoffs"] > t["required_handoffs"]:
        fail("handoffs")
    print(f"model=valid cases={len(gates)} gates={len(gates)-1} calculations=5")


def priorities(packet_path: str) -> None:
    p = load(packet_path)["priorities"]
    print(
        "priorities=pass "
        f"available={p['available_points']} committed={p['committed_points']} "
        f"reserve={p['reserve_points']} requested={p['requested_points']} "
        f"stopped={p['stopped_points']} utilization_pct={percent(p['committed_points'], p['available_points'])} "
        f"reserve_pct={percent(p['reserve_points'], p['available_points'])} "
        f"selected_outcome_value={p['selected_outcome_value']} capacity_conserved=true"
    )


def delegation(packet_path: str) -> None:
    d = load(packet_path)["delegation"]
    fields = ("outcome_defined", "authority_bounded", "information_available",
              "resources_available", "checkback_defined", "escalation_defined")
    complete = min(d[field] for field in fields)
    print(
        "delegation=pass "
        f"outcomes={d['outcomes']} complete={complete} "
        f"complete_pct={percent(complete, d['outcomes'])} "
        "responsibility_authority_resources_support_bound=true"
    )


def decisions(packet_path: str) -> None:
    d = load(packet_path)["decisions"]
    resolved = d["within_deadline"] + d["escalated_by_deadline"]
    print(
        "decisions=pass "
        f"total={d['total']} within_deadline={d['within_deadline']} "
        f"escalated_by_deadline={d['escalated_by_deadline']} unresolved={d['unresolved']} "
        f"closure_pct={percent(resolved, d['total'])} "
        f"material_objections_recorded={d['material_objections_recorded']}"
    )


def stakeholders(packet_path: str) -> None:
    s = load(packet_path)["stakeholders"]
    print(
        "stakeholders=pass "
        f"canonical_facts={s['canonical_facts']} views={s['views']} "
        f"required_links={s['required_links']} present_links={s['present_links']} "
        f"coverage_pct={percent(s['present_links'], s['required_links'])} "
        f"conflicts={s['conflicts']} audience_changes_emphasis_not_facts=true"
    )


def load_report(packet_path: str) -> None:
    value = load(packet_path)["team_load"]
    print(
        "load=pass "
        f"pages={value['pages']} responders={value['responders']} minimum={value['minimum']} "
        f"maximum={value['maximum']} spread={value['maximum']-value['minimum']} "
        f"maximum_share_pct={percent(value['maximum'], value['pages'])} "
        f"handoff_pct={percent(value['acknowledged_handoffs'], value['required_handoffs'])}"
    )


def list_cases(cases_path: str) -> None:
    for name in gate_map(load(cases_path)):
        print(name)


def show_case(cases_path: str, name: str) -> None:
    gates = gate_map(load(cases_path))
    if name not in gates:
        fail("unknown-case")
    print(json.dumps({"name": name, "expected_boundary": gates[name]},
                     sort_keys=True, separators=(",", ":")))


def evaluate(cases_path: str, name: str) -> None:
    gates = gate_map(load(cases_path))
    if name not in gates:
        fail("unknown-case")
    print(f"case={name} boundary={gates[name]}")


def evaluate_all(cases_path: str) -> None:
    for name, boundary in gate_map(load(cases_path)).items():
        print(f"case={name} boundary={boundary}")


def roadmap(packet_path: str) -> None:
    packet = load(packet_path)
    print(
        f"roadmap=pass packet_id={packet['packet_id']} "
        "stages=outcome->evidence->options->decision-rights->commit->delegate->observe->learn "
        "people_system_calls=none messaging_calls=none runtime_calls=none"
    )


def main() -> None:
    try:
        command = sys.argv[1] if len(sys.argv) > 1 else "help"
        if command == "validate" and len(sys.argv) == 4:
            validate(sys.argv[2], sys.argv[3])
        elif command == "list" and len(sys.argv) == 3:
            list_cases(sys.argv[2])
        elif command == "show" and len(sys.argv) == 4:
            show_case(sys.argv[2], sys.argv[3])
        elif command == "evaluate" and len(sys.argv) == 4:
            evaluate(sys.argv[2], sys.argv[3])
        elif command == "evaluate-all" and len(sys.argv) == 3:
            evaluate_all(sys.argv[2])
        elif command == "roadmap" and len(sys.argv) == 3:
            roadmap(sys.argv[2])
        elif command == "priorities" and len(sys.argv) == 3:
            priorities(sys.argv[2])
        elif command == "delegation" and len(sys.argv) == 3:
            delegation(sys.argv[2])
        elif command == "decisions" and len(sys.argv) == 3:
            decisions(sys.argv[2])
        elif command == "stakeholders" and len(sys.argv) == 3:
            stakeholders(sys.argv[2])
        elif command == "load" and len(sys.argv) == 3:
            load_report(sys.argv[2])
        else:
            fail("usage")
    except (OSError, json.JSONDecodeError, ValueError, KeyError) as error:
        print(f"model=fail reason={error}", file=sys.stderr)
        raise SystemExit(1) from error


if __name__ == "__main__":
    main()
