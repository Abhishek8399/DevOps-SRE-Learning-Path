#!/usr/bin/env python3
"""Deterministic fictional roadmap model; never evaluates a learner or predicts hiring."""
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
    value = (Decimal(numerator) * 100 / Decimal(denominator)).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )
    return f"{value:.2f}"


def gates(document: dict[str, Any]) -> dict[str, str]:
    groups = document.get("gate_groups")
    if not isinstance(groups, list) or len(groups) != 19:
        fail("gate-groups")
    result: dict[str, str] = {}
    for group in groups:
        boundary, cases = group.get("boundary"), group.get("cases")
        if not isinstance(boundary, str) or not boundary or not isinstance(cases, list):
            fail("gate-shape")
        for case in cases:
            if not isinstance(case, str) or not case or case in result:
                fail("case-identity")
            result[case] = boundary
    return result


def validate(cases_path: str, packet_path: str) -> None:
    case_doc, packet = load(cases_path), load(packet_path)
    if case_doc.get("lesson_id") != "LES-0087":
        fail("lesson-id")
    mapped = gates(case_doc)
    baseline = case_doc.get("baseline")
    if mapped.get(baseline) != "baseline":
        fail("baseline")
    if len(mapped) != 73 or sum(v != "baseline" for v in mapped.values()) != 72:
        fail("gate-count")
    if packet.get("packet_id") != "fictional-career-roadmap-evidence":
        fail("packet-id")

    roles = packet.get("roles", {})
    r = {k: number(roles.get(k), k) for k in
         ("total_requirements", "mapped_requirements", "versioned_roles", "stale_roles")}
    if r["mapped_requirements"] > r["total_requirements"] or r["versioned_roles"] != 9 or r["stale_roles"] != 0:
        fail("role-values")

    evidence = packet.get("evidence", {})
    e = {k: number(evidence.get(k), k) for k in
         ("total", "observed", "calculated", "qualified", "missing", "attributable")}
    if e["observed"] + e["calculated"] + e["qualified"] + e["missing"] != e["total"]:
        fail("evidence-conservation")
    if e["attributable"] + e["missing"] != e["total"]:
        fail("evidence-attribution")

    dependencies = packet.get("dependencies", {})
    d = {k: number(dependencies.get(k), k) for k in ("required_edges", "resolved_edges", "cycles")}
    if d["resolved_edges"] > d["required_edges"] or d["cycles"] != 0:
        fail("dependency-values")

    capacity = packet.get("capacity", {})
    c = {k: number(capacity.get(k), k) for k in
         ("annual_hours", "fixed_hours", "focus_hours", "reserve_hours")}
    if c["fixed_hours"] + c["focus_hours"] + c["reserve_hours"] != c["annual_hours"]:
        fail("capacity-conservation")
    if c["reserve_hours"] * 100 // c["annual_hours"] < 20:
        fail("capacity-reserve")

    milestones = packet.get("milestones", {})
    m = {k: number(milestones.get(k), k) for k in
         ("total", "structurally_complete", "reading_only", "production_claims")}
    if m["structurally_complete"] > m["total"] or m["reading_only"] != 0 or m["production_claims"] != 0:
        fail("milestone-values")

    reviews = packet.get("reviews", {})
    v = {k: number(reviews.get(k), k) for k in
         ("total", "independent", "answer_key_exposures", "hiring_predictions")}
    if v["independent"] > v["total"] or v["answer_key_exposures"] != 0 or v["hiring_predictions"] != 0:
        fail("review-values")
    print("model=valid cases=73 gates=72 calculations=6")


def roadmap(cases_path: str) -> None:
    groups = load(cases_path)["gate_groups"]
    print("roadmap=pass boundaries=" + ",".join(g["boundary"] for g in groups))


def roles(packet_path: str) -> None:
    p = load(packet_path)["roles"]
    print(f"roles=pass requirements={p['total_requirements']} mapped={p['mapped_requirements']} "
          f"coverage_pct={percent(p['mapped_requirements'], p['total_requirements'])} "
          f"versioned={p['versioned_roles']} stale={p['stale_roles']}")


def evidence(packet_path: str) -> None:
    p = load(packet_path)["evidence"]
    print(f"evidence=pass total={p['total']} observed={p['observed']} calculated={p['calculated']} "
          f"qualified={p['qualified']} missing={p['missing']} "
          f"attributable_pct={percent(p['attributable'], p['total'])}")


def dependencies(packet_path: str) -> None:
    p = load(packet_path)["dependencies"]
    print(f"dependencies=pass resolved={p['resolved_edges']} required={p['required_edges']} "
          f"coverage_pct={percent(p['resolved_edges'], p['required_edges'])} cycles={p['cycles']}")


def capacity(packet_path: str) -> None:
    p = load(packet_path)["capacity"]
    committed = p["fixed_hours"] + p["focus_hours"]
    print(f"capacity=pass annual={p['annual_hours']} fixed={p['fixed_hours']} focus={p['focus_hours']} "
          f"reserve={p['reserve_hours']} committed_pct={percent(committed, p['annual_hours'])} "
          f"reserve_pct={percent(p['reserve_hours'], p['annual_hours'])}")


def milestones(packet_path: str) -> None:
    p = load(packet_path)["milestones"]
    print(f"milestones=pass total={p['total']} complete={p['structurally_complete']} "
          f"structure_pct={percent(p['structurally_complete'], p['total'])} "
          f"reading_only={p['reading_only']} production_claims={p['production_claims']}")


def reviews(packet_path: str) -> None:
    p = load(packet_path)["reviews"]
    print(f"reviews=pass total={p['total']} independent={p['independent']} "
          f"independent_pct={percent(p['independent'], p['total'])} "
          f"answer_key_exposures={p['answer_key_exposures']} hiring_predictions={p['hiring_predictions']}")


def show(cases_path: str, name: str, evaluate: bool = False) -> None:
    mapped = gates(load(cases_path))
    if name not in mapped:
        fail("unknown-case")
    boundary = mapped[name]
    if evaluate:
        result = "pass" if boundary == "baseline" else "refuse"
        print(f"evaluate={result} case={name} boundary={boundary}")
    else:
        print(f"case={name} boundary={boundary}")


def evaluate_all(cases_path: str) -> None:
    mapped = gates(load(cases_path))
    print(f"evaluate_all=pass cases={len(mapped)} refused={sum(v != 'baseline' for v in mapped.values())} "
          f"baseline_pass={sum(v == 'baseline' for v in mapped.values())}")


def main(argv: list[str]) -> None:
    if len(argv) < 2:
        fail("command")
    cmd = argv[1]
    if cmd == "validate" and len(argv) == 4:
        validate(argv[2], argv[3])
    elif cmd == "roadmap" and len(argv) == 3:
        roadmap(argv[2])
    elif cmd in {"roles", "evidence", "dependencies", "capacity", "milestones", "reviews"} and len(argv) == 3:
        globals()[cmd](argv[2])
    elif cmd in {"show", "evaluate"} and len(argv) == 4:
        show(argv[2], argv[3], cmd == "evaluate")
    elif cmd == "evaluate-all" and len(argv) == 3:
        evaluate_all(argv[2])
    else:
        fail("arguments")


if __name__ == "__main__":
    try:
        main(sys.argv)
    except (OSError, json.JSONDecodeError, ValueError, KeyError, TypeError) as error:
        print(f"model=fail reason={error}", file=sys.stderr)
        raise SystemExit(1)
