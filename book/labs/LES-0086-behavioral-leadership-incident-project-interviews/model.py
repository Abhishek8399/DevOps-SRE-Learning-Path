#!/usr/bin/env python3
"""Deterministic fictional interview-evidence model; never evaluates a person or predicts hiring."""
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
    if case_doc.get("lesson_id") != "LES-0086":
        fail("lesson-id")
    gates = gate_map(case_doc)
    baseline = case_doc.get("baseline")
    if baseline not in gates or gates[baseline] != "baseline":
        fail("baseline")
    if len(gates) != 73 or sum(v != "baseline" for v in gates.values()) != 72:
        fail("gate-count")
    if packet.get("packet_id") != "fictional-platform-interview-evidence":
        fail("packet-id")

    stories = packet.get("stories")
    if not isinstance(stories, dict):
        fail("stories")
    s = {key: number(stories.get(key), key) for key in (
        "total", "complete", "source_confirmed", "confidential", "fabricated"
    )}
    if s["complete"] > s["total"] or s["source_confirmed"] > s["total"]:
        fail("story-conservation")
    if s["confidential"] != 0 or s["fabricated"] != 0:
        fail("unsafe-story")

    claims = packet.get("claims")
    if not isinstance(claims, dict):
        fail("claims")
    c = {key: number(claims.get(key), key) for key in (
        "total", "observed", "calculated", "qualified", "unknown", "attributable"
    )}
    if c["observed"] + c["calculated"] + c["qualified"] + c["unknown"] != c["total"]:
        fail("claim-conservation")
    if c["attributable"] + c["unknown"] != c["total"]:
        fail("claim-attribution")

    variants = packet.get("variants")
    if not isinstance(variants, dict):
        fail("variants")
    rate = number(variants.get("speech_rate_wpm"), "speech-rate")
    if rate != 130:
        fail("speech-rate")
    items = variants.get("items")
    if not isinstance(items, list) or [item.get("seconds") for item in items] != [30, 120, 300, 900]:
        fail("variant-items")
    for item in items:
        seconds = number(item.get("seconds"), "seconds")
        maximum = number(item.get("maximum_words"), "maximum-words")
        actual = number(item.get("actual_words"), "actual-words")
        if maximum != rate * seconds // 60 or actual > maximum:
            fail("variant-budget")

    coverage = packet.get("coverage")
    if not isinstance(coverage, dict):
        fail("coverage")
    cov = {key: number(coverage.get(key), key) for key in (
        "competencies", "required_links", "present_links", "conflicts"
    )}
    if cov["competencies"] != 12 or cov["present_links"] > cov["required_links"] or cov["conflicts"] != 0:
        fail("coverage-values")

    followups = packet.get("followups")
    if not isinstance(followups, dict):
        fail("followups")
    f = {key: number(followups.get(key), key) for key in (
        "total", "evidence_consistent", "invented_claims"
    )}
    if f["evidence_consistent"] > f["total"] or f["invented_claims"] != 0:
        fail("followup-values")
    print("model=valid cases=73 gates=72 calculations=5")


def roadmap(cases_path: str) -> None:
    document = load(cases_path)
    groups = document["gate_groups"]
    print("roadmap=pass boundaries=" + ",".join(group["boundary"] for group in groups))


def stories(packet_path: str) -> None:
    p = load(packet_path)["stories"]
    print(
        f"stories=pass total={p['total']} complete={p['complete']} "
        f"complete_pct={percent(p['complete'], p['total'])} "
        f"source_pct={percent(p['source_confirmed'], p['total'])} "
        f"confidential={p['confidential']} fabricated={p['fabricated']}"
    )


def claims(packet_path: str) -> None:
    p = load(packet_path)["claims"]
    print(
        f"claims=pass total={p['total']} observed={p['observed']} calculated={p['calculated']} "
        f"qualified={p['qualified']} unknown={p['unknown']} "
        f"attributable_pct={percent(p['attributable'], p['total'])}"
    )


def variants(packet_path: str) -> None:
    p = load(packet_path)["variants"]
    values = ",".join(
        f"{item['seconds']}s:{item['actual_words']}/{item['maximum_words']}"
        for item in p["items"]
    )
    total_actual = sum(item["actual_words"] for item in p["items"])
    total_maximum = sum(item["maximum_words"] for item in p["items"])
    print(
        f"variants=pass rate_wpm={p['speech_rate_wpm']} budgets={values} "
        f"aggregate_pct={percent(total_actual, total_maximum)}"
    )


def coverage(packet_path: str) -> None:
    p = load(packet_path)["coverage"]
    print(
        f"coverage=pass competencies={p['competencies']} present={p['present_links']} "
        f"required={p['required_links']} coverage_pct={percent(p['present_links'], p['required_links'])} "
        f"conflicts={p['conflicts']}"
    )


def followups(packet_path: str) -> None:
    p = load(packet_path)["followups"]
    print(
        f"followups=pass total={p['total']} consistent={p['evidence_consistent']} "
        f"consistent_pct={percent(p['evidence_consistent'], p['total'])} "
        f"invented={p['invented_claims']}"
    )


def show(cases_path: str, name: str) -> None:
    gates = gate_map(load(cases_path))
    if name not in gates:
        fail("unknown-case")
    print(f"case={name} boundary={gates[name]}")


def evaluate(cases_path: str, name: str) -> None:
    gates = gate_map(load(cases_path))
    if name not in gates:
        fail("unknown-case")
    boundary = gates[name]
    result = "pass" if boundary == "baseline" else "refuse"
    print(f"evaluate={result} case={name} boundary={boundary}")


def evaluate_all(cases_path: str) -> None:
    gates = gate_map(load(cases_path))
    refused = sum(boundary != "baseline" for boundary in gates.values())
    passed = sum(boundary == "baseline" for boundary in gates.values())
    print(f"evaluate_all=pass cases={len(gates)} refused={refused} baseline_pass={passed}")


def main(argv: list[str]) -> None:
    if len(argv) < 2:
        fail("command")
    command = argv[1]
    if command == "validate" and len(argv) == 4:
        validate(argv[2], argv[3])
    elif command == "roadmap" and len(argv) == 3:
        roadmap(argv[2])
    elif command in {"stories", "claims", "variants", "coverage", "followups"} and len(argv) == 3:
        globals()[command](argv[2])
    elif command in {"show", "evaluate"} and len(argv) == 4:
        globals()[command](argv[2], argv[3])
    elif command == "evaluate-all" and len(argv) == 3:
        evaluate_all(argv[2])
    else:
        fail("arguments")


if __name__ == "__main__":
    try:
        main(sys.argv)
    except (OSError, json.JSONDecodeError, ValueError, KeyError, TypeError) as error:
        print(f"model=fail reason={error}", file=sys.stderr)
        raise SystemExit(1)
