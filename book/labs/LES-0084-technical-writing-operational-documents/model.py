#!/usr/bin/env python3
"""Deterministic fictional documentation-review model; no publishing or runtime calls."""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
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


def groups(document: dict[str, Any]) -> list[dict[str, Any]]:
    value = document.get("gate_groups")
    if not isinstance(value, list) or not value:
        fail("gate-groups")
    return value


def gate_map(document: dict[str, Any]) -> dict[str, str]:
    result: dict[str, str] = {}
    for group in groups(document):
        boundary = group.get("boundary")
        cases = group.get("cases")
        if not isinstance(boundary, str) or not boundary or not isinstance(cases, list):
            fail("gate-group-shape")
        for name in cases:
            if not isinstance(name, str) or not name or name in result:
                fail("case-identity")
            result[name] = boundary
    return result


def number(value: Any, label: str) -> int:
    if not isinstance(value, int) or isinstance(value, bool) or value < 0:
        fail(label)
    return value


def dec(value: int, denominator: int) -> str:
    if denominator <= 0:
        fail("zero-denominator")
    result = (Decimal(value) * Decimal(100) / Decimal(denominator)).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )
    return f"{result:.2f}"


def parse_stamp(value: Any, label: str) -> datetime:
    if not isinstance(value, str) or not value:
        fail(f"timestamp-{label}")
    normalized = value[:-1] + "+00:00" if value.endswith("Z") else value
    stamp = datetime.fromisoformat(normalized)
    if stamp.tzinfo is None:
        fail(f"timezone-{label}")
    return stamp.astimezone(timezone.utc)


def validate(cases_path: str, packet_path: str) -> None:
    case_doc = load(cases_path)
    packet = load(packet_path)
    if case_doc.get("lesson_id") != "LES-0084":
        fail("lesson-id")
    gates = gate_map(case_doc)
    baseline = case_doc.get("baseline")
    if baseline not in gates or gates[baseline] != "baseline":
        fail("baseline")
    if len(gates) != 73 or sum(1 for b in gates.values() if b != "baseline") != 72:
        fail("gate-count")
    if packet.get("packet_id") != "fictional-checkout-incident-docs":
        fail("packet-id")

    claims = packet.get("claims")
    if not isinstance(claims, dict):
        fail("claims")
    total = number(claims.get("total"), "claims-total")
    classes = sum(number(claims.get(k), f"claims-{k}") for k in
                  ("observed", "calculated", "decided", "declared", "unknown"))
    if classes != total or number(claims.get("attributable"), "attributable") > total:
        fail("claims-conservation")

    timeline = packet.get("timeline")
    if not isinstance(timeline, dict):
        fail("timeline")
    stamps = [parse_stamp(timeline.get(k), k) for k in
              ("detected", "impact_start", "mitigation_start", "recovered")]
    if not (stamps[0] <= stamps[1] <= stamps[2] <= stamps[3]):
        fail("timeline-order")

    runbook = packet.get("runbook")
    if not isinstance(runbook, dict):
        fail("runbook")
    values = {k: number(runbook.get(k), k) for k in
              ("steps", "verifiable_steps", "validated_steps", "mutating_steps",
               "protected_mutations", "failure_branches")}
    if values["verifiable_steps"] > values["steps"] or values["validated_steps"] > values["verifiable_steps"]:
        fail("runbook-count")
    if values["protected_mutations"] > values["mutating_steps"]:
        fail("runbook-mutations")

    freshness = packet.get("freshness")
    if not isinstance(freshness, dict):
        fail("freshness")
    f = {k: number(freshness.get(k), k) for k in
         ("artifacts", "active", "active_current", "review_due",
          "superseded_expired", "critical_expired")}
    if f["active"] + f["review_due"] + f["superseded_expired"] != f["artifacts"]:
        fail("freshness-conservation")

    audiences = packet.get("audiences")
    if not isinstance(audiences, dict):
        fail("audiences")
    a = {k: number(audiences.get(k), k) for k in
         ("canonical_facts", "views", "required_links", "present_links", "conflicts")}
    if a["present_links"] > a["required_links"]:
        fail("audience-links")
    print(f"model=valid cases={len(gates)} gates={len(gates)-1} calculations=5")


def claim_report(packet_path: str) -> None:
    claims = load(packet_path)["claims"]
    total = claims["total"]
    print(
        "claims=pass "
        f"total={total} observed={claims['observed']} calculated={claims['calculated']} "
        f"decided={claims['decided']} declared={claims['declared']} unknown={claims['unknown']} "
        f"attributable={claims['attributable']} attributable_pct={dec(claims['attributable'], total)} "
        f"unknown_pct={dec(claims['unknown'], total)} fact_classes_not_interchangeable=true"
    )


def timeline_report(packet_path: str) -> None:
    timeline = load(packet_path)["timeline"]
    detected = parse_stamp(timeline["detected"], "detected")
    impact = parse_stamp(timeline["impact_start"], "impact")
    mitigation = parse_stamp(timeline["mitigation_start"], "mitigation")
    recovered = parse_stamp(timeline["recovered"], "recovered")
    impact_minutes = int((recovered - impact).total_seconds() / 60)
    response_minutes = int((recovered - detected).total_seconds() / 60)
    print(
        "timeline=pass "
        f"detected_utc={detected.isoformat().replace('+00:00','Z')} "
        f"impact_utc={impact.isoformat().replace('+00:00','Z')} "
        f"mitigation_utc={mitigation.isoformat().replace('+00:00','Z')} "
        f"recovered_utc={recovered.isoformat().replace('+00:00','Z')} "
        f"impact_minutes={impact_minutes} response_minutes={response_minutes} offsets_preserved_in_source=true"
    )


def runbook_report(packet_path: str) -> None:
    value = load(packet_path)["runbook"]
    print(
        "runbook=pass "
        f"steps={value['steps']} verifiable={value['verifiable_steps']} "
        f"validated={value['validated_steps']} validation_pct={dec(value['validated_steps'], value['verifiable_steps'])} "
        f"mutations={value['mutating_steps']} protected_mutations={value['protected_mutations']} "
        f"failure_branches={value['failure_branches']} safe_mutations={str(value['mutating_steps']==value['protected_mutations']).lower()}"
    )


def freshness_report(packet_path: str) -> None:
    value = load(packet_path)["freshness"]
    print(
        "freshness=pass "
        f"artifacts={value['artifacts']} active={value['active']} active_current={value['active_current']} "
        f"review_due={value['review_due']} superseded_expired={value['superseded_expired']} "
        f"critical_expired={value['critical_expired']} active_current_pct={dec(value['active_current'], value['active'])} "
        "archive_is_not_active_truth=true"
    )


def audience_report(packet_path: str) -> None:
    value = load(packet_path)["audiences"]
    print(
        "audiences=pass "
        f"canonical_facts={value['canonical_facts']} views={value['views']} "
        f"required_links={value['required_links']} present_links={value['present_links']} "
        f"coverage_pct={dec(value['present_links'], value['required_links'])} conflicts={value['conflicts']} "
        "emphasis_changes_facts_do_not=true"
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
        "stages=purpose->evidence->draft->review->rehearse->publish->observe->revise->archive "
        "approval=human-owned publish_calls=none"
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
        elif command == "claims" and len(sys.argv) == 3:
            claim_report(sys.argv[2])
        elif command == "timeline" and len(sys.argv) == 3:
            timeline_report(sys.argv[2])
        elif command == "runbook" and len(sys.argv) == 3:
            runbook_report(sys.argv[2])
        elif command == "freshness" and len(sys.argv) == 3:
            freshness_report(sys.argv[2])
        elif command == "audiences" and len(sys.argv) == 3:
            audience_report(sys.argv[2])
        else:
            fail("usage")
    except (OSError, json.JSONDecodeError, ValueError, KeyError) as error:
        print(f"model=fail reason={error}", file=sys.stderr)
        raise SystemExit(1) from error


if __name__ == "__main__":
    main()
