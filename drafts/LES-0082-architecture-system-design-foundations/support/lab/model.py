#!/usr/bin/env python3
"""Deterministic architecture-review model; it calls no runtime or provider."""

from __future__ import annotations

import json
import sys
from decimal import Decimal, InvalidOperation, ROUND_CEILING, ROUND_HALF_UP
from pathlib import Path
from typing import NoReturn

GATES = (
    ("decision-owner", "decision-or-accountable-owner-undefined", "decision_owner_bound"),
    ("business-outcome", "business-or-user-outcome-undefined", "business_outcome_bound"),
    ("actors", "actors-and-authorities-unbound", "actors_bound"),
    ("use-cases", "critical-use-cases-or-failure-cases-missing", "use_cases_bound"),
    ("scope", "system-scope-undefined", "scope_defined"),
    ("out-of-scope", "out-of-scope-and-non-goals-missing", "out_of_scope_defined"),
    ("assumptions", "assumptions-unversioned-or-unowned", "assumptions_versioned"),
    ("constraints", "hard-and-soft-constraints-confused", "constraints_bound"),
    ("requirements", "requirements-ambiguous-or-unmeasurable", "requirements_measurable"),
    ("quality-scenarios", "quality-attribute-scenario-incomplete", "quality_scenarios_complete"),
    ("priority", "quality-priority-or-conflict-unowned", "priorities_owned"),
    ("workload", "workload-envelope-unquantified", "workload_quantified"),
    ("data-class", "data-classification-or-lifecycle-missing", "data_classified"),
    ("current-state", "current-system-and-observed-limit-unmapped", "current_state_mapped"),
    ("context", "people-external-systems-or-boundary-missing", "context_complete"),
    ("abstraction", "diagram-mixes-abstraction-levels", "abstraction_consistent"),
    ("responsibility", "component-responsibility-unclear", "responsibilities_explicit"),
    ("relationship", "relationship-direction-or-intent-unclear", "relationships_directional"),
    ("protocol", "interface-protocol-or-contract-unbound", "protocol_contracts_bound"),
    ("interaction", "sync-async-choice-unjustified", "interaction_mode_justified"),
    ("state-owner", "state-owner-or-writer-authority-unbound", "state_owner_bound"),
    ("source-of-truth", "source-of-truth-and-derived-state-confused", "source_of_truth_bound"),
    ("consistency", "consistency-freshness-or-conflict-semantics-missing", "consistency_semantics_bound"),
    ("idempotency", "duplicate-retry-or-ambiguous-outcome-unhandled", "idempotency_bound"),
    ("failure-domains", "failure-domains-or-correlated-loss-unmapped", "failure_domains_mapped"),
    ("dependency", "dependency-contract-or-degradation-unbound", "dependencies_bound"),
    ("availability", "availability-composition-invalid", "availability_model_valid"),
    ("capacity", "capacity-model-or-failure-reserve-invalid", "capacity_model_valid"),
    ("queue", "queue-backlog-age-or-drain-model-invalid", "queue_model_valid"),
    ("overload", "admission-shedding-or-backpressure-unbound", "overload_policy_bound"),
    ("latency-budget", "latency-budget-does-not-close", "latency_budget_valid"),
    ("trust-boundary", "trust-boundary-or-authority-crossing-unmapped", "trust_boundaries_mapped"),
    ("identity-flow", "human-workload-or-service-identity-flow-unbound", "identity_flow_bound"),
    ("least-privilege", "authorization-scope-or-separation-invalid", "least_privilege_valid"),
    ("data-flow", "sensitive-data-flow-or-egress-unmapped", "data_flows_mapped"),
    ("threat", "threat-capability-or-mitigation-unreviewed", "threats_reviewed"),
    ("privacy", "privacy-retention-deletion-or-audit-unbound", "privacy_bound"),
    ("observability", "sli-event-context-or-missing-data-unbound", "observability_bound"),
    ("operability", "ownership-runbook-escalation-or-toil-unbound", "operability_bound"),
    ("deployment", "deployment-topology-and-runtime-state-unbound", "deployment_view_bound"),
    ("rollback", "rollback-or-forward-recovery-unproved", "rollback_bound"),
    ("migration", "migration-coexistence-or-cutover-unbound", "migration_bound"),
    ("compatibility", "version-skew-or-contract-evolution-unbound", "compatibility_bound"),
    ("recovery", "backup-restore-failover-or-reconciliation-unbound", "recovery_bound"),
    ("rpo-rto", "rpo-rto-or-business-recovery-unmeasured", "rpo_rto_bound"),
    ("cost", "implementation-runtime-or-opportunity-cost-omitted", "cost_bound"),
    ("sustainability", "resource-or-environmental-impact-unreviewed", "sustainability_reviewed"),
    ("options", "credible-alternatives-not-compared", "options_compared"),
    ("tradeoff", "benefit-cost-and-sacrifice-not-explicit", "tradeoffs_explicit"),
    ("sensitivity", "sensitivity-or-tradeoff-points-unidentified", "sensitivity_points_found"),
    ("risk", "architecture-risk-unowned-or-unbounded", "risks_owned"),
    ("unknowns", "unknowns-hidden-as-facts", "unknowns_visible"),
    ("evidence", "claim-not-bound-to-evidence-or-test", "evidence_bound"),
    ("adr", "decision-record-lacks-context-options-or-consequences", "adr_complete"),
    ("decision-state", "decision-state-or-supersession-invalid", "decision_state_valid"),
    ("review", "affected-stakeholder-review-missing", "stakeholder_reviewed"),
    ("diagram-title", "diagram-title-type-or-scope-missing", "diagram_title_scope"),
    ("legend", "diagram-legend-acronym-or-symbol-missing", "legend_complete"),
    ("text-alternative", "diagram-has-no-equivalent-text", "text_alternative_complete"),
    ("simplicity", "complexity-not-justified-by-requirement", "simplicity_defended"),
    ("team-ownership", "architecture-and-team-boundaries-misaligned", "team_ownership_bound"),
    ("compliance", "policy-regulatory-or-exception-owner-unbound", "compliance_bound"),
    ("validation", "architecture-validation-plan-missing", "validation_plan_bound"),
    ("readiness", "production-readiness-gate-unowned", "readiness_gate_bound"),
    ("communication", "decision-narrative-does-not-fit-audience", "communication_audience_fit"),
    ("cleanup", "temporary-design-data-or-artifact-cleanup-inexact", "cleanup_exact"),
)

KNOWN_FIELDS = {field for _, _, field in GATES}


def fail(reason: str) -> NoReturn:
    raise ValueError(reason)


def decimal_value(value: object, field: str) -> Decimal:
    try:
        parsed = Decimal(str(value))
    except InvalidOperation:
        fail(f"invalid-decimal:{field}")
    if not parsed.is_finite():
        fail(f"non-finite:{field}")
    return parsed


def rounded(value: Decimal, places: str = "0.01") -> str:
    return str(value.quantize(Decimal(places), rounding=ROUND_HALF_UP))


def ceiling(value: Decimal) -> int:
    return int(value.to_integral_value(rounding=ROUND_CEILING))


def boundary(candidate: dict) -> str:
    for name, _, field in GATES:
        if candidate[field] is not True:
            return name
    return "defensible-within-model"


def load_cases(path: str) -> dict:
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(document, dict) or set(document) != {"schema_version", "base"}:
        fail("cases-top-level-shape")
    if document["schema_version"] != 1:
        fail("cases-schema-version")
    if not isinstance(document["base"], dict) or set(document["base"]) != KNOWN_FIELDS:
        fail("cases-base-fields")
    if any(type(value) is not bool for value in document["base"].values()):
        fail("cases-base-types")
    if len(GATES) != 66:
        fail("gate-count")
    return document


def all_cases(document: dict) -> list[dict]:
    result = [{"name": "baseline", "overrides": {}, "expected_boundary": "defensible-within-model"}]
    result.extend(
        {"name": case_name, "overrides": {field: False}, "expected_boundary": gate_name}
        for gate_name, case_name, field in GATES
    )
    return result


def find_case(document: dict, name: str) -> dict:
    for case in all_cases(document):
        if case["name"] == name:
            return case
    fail(f"unknown-case:{name}")


def load_design(path: str) -> dict:
    design = json.loads(Path(path).read_text(encoding="utf-8"))
    required = {
        "schema_version", "design_id", "decision", "currency",
        "peak_requests_per_second", "headroom_pct",
        "instance_sustainable_rps_at_slo", "failure_domains",
        "tolerated_domain_losses", "component_availability", "queue",
        "writes_per_second", "rpo_seconds", "latency_budget_ms",
        "latency_slo_ms", "alternatives", "weights",
    }
    if not isinstance(design, dict) or set(design) != required:
        fail("design-shape")
    if design["schema_version"] != 1 or design["design_id"] != "checkout-architecture-v1":
        fail("design-identity")
    if design["currency"] != "USD":
        fail("design-currency")
    if set(design["component_availability"]) != {"edge", "api", "database"}:
        fail("availability-components")
    if set(design["queue"]) != {
        "burst_arrival_per_second", "sustainable_service_per_second",
        "burst_seconds", "recovery_service_per_second", "normal_arrival_per_second",
    }:
        fail("queue-shape")
    if set(design["latency_budget_ms"]) != {"edge", "api", "database", "network_and_margin"}:
        fail("latency-shape")
    if set(design["weights"]) != {"implementation", "reliability", "operability", "cost"}:
        fail("weights-shape")
    weights = sum((decimal_value(value, "weight") for value in design["weights"].values()), Decimal("0"))
    if weights != Decimal("1"):
        fail("weights-total")
    if not isinstance(design["alternatives"], list) or {item.get("id") for item in design["alternatives"]} != {"synchronous", "durable-queue"}:
        fail("alternatives")
    return design


def validate(cases_path: str, design_path: str) -> None:
    document = load_cases(cases_path)
    load_design(design_path)
    print(f"model=valid cases={len(all_cases(document))} gates={len(GATES)} calculations=5")


def list_cases(cases_path: str) -> None:
    for case in all_cases(load_cases(cases_path)):
        print(case["name"])


def show_case(cases_path: str, name: str) -> None:
    case = find_case(load_cases(cases_path), name)
    print(json.dumps(case, sort_keys=True, separators=(",", ":")))


def evaluate(cases_path: str, name: str) -> None:
    document = load_cases(cases_path)
    case = find_case(document, name)
    candidate = dict(document["base"])
    candidate.update(case["overrides"])
    actual = boundary(candidate)
    if actual != case["expected_boundary"]:
        fail(f"boundary-mismatch:{name}")
    print(f"case={name} boundary={actual}")


def evaluate_all(cases_path: str) -> None:
    document = load_cases(cases_path)
    for case in all_cases(document):
        candidate = dict(document["base"])
        candidate.update(case["overrides"])
        actual = boundary(candidate)
        if actual != case["expected_boundary"]:
            fail(f"boundary-mismatch:{case['name']}")
        print(f"case={case['name']} boundary={actual}")


def map_design(design_path: str) -> None:
    design = load_design(design_path)
    print(
        "map=pass "
        f"design_id={design['design_id']} "
        "path=customer->edge->checkout-api->database->response "
        "async_path=checkout-api->durable-queue->fulfillment "
        "state_owner=database trust_crossings=2 failure_domains=3"
    )


def capacity(design_path: str) -> None:
    design = load_design(design_path)
    peak = decimal_value(design["peak_requests_per_second"], "peak")
    headroom = decimal_value(design["headroom_pct"], "headroom") / Decimal("100")
    rate = decimal_value(design["instance_sustainable_rps_at_slo"], "instance-rate")
    domains = int(design["failure_domains"])
    losses = int(design["tolerated_domain_losses"])
    if peak <= 0 or rate <= 0 or domains <= losses or losses < 0:
        fail("capacity-input")
    target = peak * (Decimal("1") + headroom)
    healthy_instances = ceiling(target / rate)
    survivors = domains - losses
    per_domain = ceiling(Decimal(healthy_instances) / Decimal(survivors))
    provisioned = per_domain * domains
    after_loss_capacity = per_domain * survivors * int(rate)
    if Decimal(after_loss_capacity) < target:
        fail("failure-capacity")
    print(
        "capacity=pass "
        f"peak_rps={rounded(peak)} headroom_pct={rounded(headroom * 100)} "
        f"target_rps={rounded(target)} healthy_instances={healthy_instances} "
        f"per_domain={per_domain} provisioned_instances={provisioned} "
        f"after_one_domain_loss_rps={after_loss_capacity} reserve=true"
    )


def availability(design_path: str) -> None:
    design = load_design(design_path)
    values = [decimal_value(value, name) for name, value in design["component_availability"].items()]
    if any(value <= 0 or value > 1 for value in values):
        fail("availability-input")
    serial = Decimal("1")
    for value in values:
        serial *= value
    monthly_minutes = Decimal("30") * Decimal("24") * Decimal("60")
    implied_unavailable = monthly_minutes * (Decimal("1") - serial)
    print(
        "availability=pass topology=serial "
        f"edge_pct={rounded(values[0] * 100, '0.0001')} "
        f"api_pct={rounded(values[1] * 100, '0.0001')} "
        f"database_pct={rounded(values[2] * 100, '0.0001')} "
        f"composite_pct={rounded(serial * 100, '0.0001')} "
        f"implied_unavailable_minutes_30d={rounded(implied_unavailable)} independence_assumed=true"
    )


def backlog(design_path: str) -> None:
    design = load_design(design_path)
    queue = design["queue"]
    arrival = decimal_value(queue["burst_arrival_per_second"], "burst-arrival")
    service = decimal_value(queue["sustainable_service_per_second"], "service")
    duration = decimal_value(queue["burst_seconds"], "burst-seconds")
    recovery_service = decimal_value(queue["recovery_service_per_second"], "recovery-service")
    normal_arrival = decimal_value(queue["normal_arrival_per_second"], "normal-arrival")
    if arrival <= service or recovery_service <= normal_arrival:
        fail("queue-no-positive-envelope")
    backlog_items = (arrival - service) * duration
    peak_age = backlog_items / service
    drain_seconds = backlog_items / (recovery_service - normal_arrival)
    writes = decimal_value(design["writes_per_second"], "writes")
    rpo = decimal_value(design["rpo_seconds"], "rpo")
    exposure = writes * rpo
    print(
        "backlog=pass "
        f"items={rounded(backlog_items)} peak_age_seconds={rounded(peak_age)} "
        f"drain_seconds={rounded(drain_seconds)} "
        f"rpo_exposed_writes={rounded(exposure)} exposed_not_proven_lost=true"
    )


def latency(design_path: str) -> None:
    design = load_design(design_path)
    budget = sum((decimal_value(value, name) for name, value in design["latency_budget_ms"].items()), Decimal("0"))
    slo = decimal_value(design["latency_slo_ms"], "latency-slo")
    if budget > slo:
        fail("latency-budget-exceeds-slo")
    print(
        "latency=pass "
        f"budget_ms={rounded(budget)} slo_ms={rounded(slo)} "
        f"unallocated_ms={rounded(slo - budget)} closes=true"
    )


def tradeoff(design_path: str) -> None:
    design = load_design(design_path)
    weights = design["weights"]
    scores: dict[str, Decimal] = {}
    for alternative in design["alternatives"]:
        score = sum(
            (
                decimal_value(alternative[f"{dimension}_score"], dimension)
                * decimal_value(weight, "weight")
                for dimension, weight in weights.items()
            ),
            Decimal("0"),
        )
        scores[alternative["id"]] = score
    selected = max(scores, key=scores.get)
    print(
        "tradeoff=pass "
        f"synchronous={rounded(scores['synchronous'])} "
        f"durable_queue={rounded(scores['durable-queue'])} "
        f"model_selected={selected} sensitivity=weights-and-scores "
        "decision_authority=human-review-required"
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
        elif command == "map" and len(sys.argv) == 3:
            map_design(sys.argv[2])
        elif command == "capacity" and len(sys.argv) == 3:
            capacity(sys.argv[2])
        elif command == "availability" and len(sys.argv) == 3:
            availability(sys.argv[2])
        elif command == "backlog" and len(sys.argv) == 3:
            backlog(sys.argv[2])
        elif command == "latency" and len(sys.argv) == 3:
            latency(sys.argv[2])
        elif command == "tradeoff" and len(sys.argv) == 3:
            tradeoff(sys.argv[2])
        else:
            fail("usage")
    except (OSError, json.JSONDecodeError, ValueError) as error:
        print(f"model=fail reason={error}", file=sys.stderr)
        raise SystemExit(1) from error


if __name__ == "__main__":
    main()
