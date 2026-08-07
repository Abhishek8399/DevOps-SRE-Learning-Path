#!/usr/bin/env python3
"""Deterministic FinOps evidence and calculation model; it calls no provider runtime."""

from __future__ import annotations

import csv
import json
import sys
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path
from typing import NoReturn

GATES = (
    ("decision-scope", "decision-scope-or-owner-undefined", "decision_scope_defined"),
    ("source-identity", "billing-source-or-export-identity-unbound", "source_identity_bound"),
    ("data-contract", "billing-schema-or-contract-unbound", "data_contract_bound"),
    ("dataset-version", "dataset-version-or-query-unbound", "dataset_version_bound"),
    ("completeness", "billing-data-incomplete", "data_complete"),
    ("freshness", "billing-data-stale", "data_fresh"),
    ("time-boundaries", "billing-or-charge-period-misaligned", "time_boundaries_valid"),
    ("currency", "currency-or-conversion-invalid", "currency_valid"),
    ("cost-semantics", "billed-effective-list-or-contracted-cost-confused", "cost_semantics_valid"),
    ("corrections", "duplicates-late-corrections-or-re-rates-unhandled", "corrections_handled"),
    ("credits-refunds", "credits-refunds-taxes-or-support-mishandled", "adjustments_handled"),
    ("invoice-reconciliation", "dataset-does-not-reconcile-to-invoice", "invoice_reconciled"),
    ("scope-hierarchy", "billing-account-subaccount-or-project-scope-wrong", "scope_hierarchy_valid"),
    ("resource-identity", "resource-or-charge-identity-unbound", "resource_identity_bound"),
    ("owner", "accountable-owner-unbound", "owner_bound"),
    ("tag-taxonomy", "tag-label-or-business-taxonomy-invalid", "tag_taxonomy_valid"),
    ("tag-activation", "tag-activation-history-or-inheritance-misread", "tag_activation_valid"),
    ("allocation-coverage", "allocation-coverage-insufficient", "allocation_coverage_valid"),
    ("shared-pool", "shared-cost-pool-unidentified", "shared_pool_identified"),
    ("allocation-driver", "shared-cost-driver-unjustified", "allocation_driver_valid"),
    ("allocation-conservation", "allocation-does-not-conserve-cost", "allocation_conserves_cost"),
    ("idle-cost", "idle-or-unused-cost-hidden", "idle_cost_visible"),
    ("platform-cost", "platform-overhead-or-support-cost-omitted", "platform_cost_included"),
    ("unit-denominator", "unit-denominator-unstable-or-gameable", "unit_denominator_valid"),
    ("business-outcome", "unit-metric-not-connected-to-value", "business_outcome_bound"),
    ("fully-loaded-cost", "unit-cost-omits-required-costs", "fully_loaded_cost_valid"),
    ("baseline", "optimization-baseline-unbound", "baseline_bound"),
    ("seasonality", "seasonality-or-calendar-effect-ignored", "seasonality_handled"),
    ("planned-demand", "planned-demand-or-product-change-omitted", "planned_demand_included"),
    ("price-rate", "price-rate-or-contract-assumption-stale", "price_rate_valid"),
    ("forecast-method", "forecast-method-or-assumptions-unbound", "forecast_method_bound"),
    ("uncertainty", "forecast-has-no-uncertainty-range", "uncertainty_bounded"),
    ("backtest", "forecast-error-or-backtest-absent", "forecast_backtested"),
    ("budget-forecast", "budget-forecast-and-actual-confused", "budget_forecast_separated"),
    ("budget-latency", "budget-alert-treated-as-real-time-control", "budget_latency_handled"),
    ("anomaly-baseline", "cost-anomaly-baseline-invalid", "anomaly_baseline_valid"),
    ("anomaly-granularity", "aggregate-anomaly-hides-driver", "anomaly_granularity_valid"),
    ("anomaly-owner", "cost-anomaly-has-no-response-owner", "anomaly_owner_bound"),
    ("security-abuse", "cost-spike-security-abuse-unchecked", "security_abuse_checked"),
    ("usage-evidence", "rightsizing-lacks-usage-evidence", "usage_evidence_valid"),
    ("slo-performance", "optimization-ignores-slo-or-performance", "slo_performance_protected"),
    ("failure-reserve", "rightsizing-removes-failure-reserve", "failure_reserve_valid"),
    ("elasticity", "scheduling-scaling-or-shutdown-unsafe", "elasticity_valid"),
    ("storage-lifecycle", "storage-snapshot-or-retention-risk-unreviewed", "storage_lifecycle_valid"),
    ("network-egress", "network-egress-or-topology-cost-unmodeled", "network_egress_valid"),
    ("architecture", "architecture-cost-moves-risk-elsewhere", "architecture_tradeoff_valid"),
    ("commitment-eligibility", "commitment-demand-not-stable-or-eligible", "commitment_eligibility_valid"),
    ("commitment-coverage", "commitment-coverage-excessive", "commitment_coverage_valid"),
    ("commitment-utilization", "commitment-utilization-or-vacancy-unacceptable", "commitment_utilization_valid"),
    ("commitment-concentration", "commitment-concentrates-provider-or-service-risk", "commitment_concentration_valid"),
    ("interruptible-capacity", "spot-or-interruptible-workload-not-tolerant", "interruptible_capacity_valid"),
    ("provider-dependency", "provider-recommendation-unverified", "provider_recommendation_verified"),
    ("implementation-cost", "optimization-effort-risk-or-tools-omitted", "implementation_cost_included"),
    ("change-authority", "optimization-change-unapproved", "change_authority_valid"),
    ("canary", "optimization-canary-or-stop-threshold-absent", "canary_valid"),
    ("rollback", "optimization-rollback-unproved", "rollback_valid"),
    ("realized-savings", "estimated-savings-not-reconciled-to-actual", "realized_savings_verified"),
    ("cost-avoidance", "cost-avoidance-mislabeled-as-savings", "cost_avoidance_labeled"),
    ("sustainability", "cost-optimization-shifts-unreviewed-sustainability-impact", "sustainability_reviewed"),
    ("governance", "policy-exception-or-cadence-unowned", "governance_valid"),
    ("access-privacy", "billing-data-access-or-sensitive-metadata-excessive", "access_privacy_valid"),
    ("communication", "executive-narrative-hides-assumptions-or-risk", "communication_valid"),
    ("audit-cleanup", "temporary-data-access-or-artifact-cleanup-incomplete", "audit_cleanup_exact"),
)

KNOWN_FIELDS = {field for _, _, field in GATES}
REQUIRED_COLUMNS = (
    "charge_id", "charge_period", "provider", "billing_account", "subaccount",
    "service", "resource_id", "owner", "environment", "cost_pool",
    "consumed_quantity", "consumed_unit", "list_cost", "contracted_cost",
    "billed_cost", "effective_cost", "currency", "business_units",
    "successful_transactions", "availability_pct", "latency_p99_ms",
)
MONEY_COLUMNS = ("list_cost", "contracted_cost", "billed_cost", "effective_cost")


def fail(reason: str) -> NoReturn:
    raise ValueError(reason)


def boundary(candidate: dict) -> str:
    for name, _, field in GATES:
        if candidate[field] is not True:
            return name
    return "defensible-within-model"


def load_cases(path: str) -> dict:
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(document, dict) or set(document) != {"schema_version", "base"}:
        fail("top-level-shape")
    if document["schema_version"] != 1:
        fail("schema-version")
    if not isinstance(document["base"], dict) or set(document["base"]) != KNOWN_FIELDS:
        fail("base-fields")
    if any(type(value) is not bool for value in document["base"].values()):
        fail("base-types")
    if len(GATES) != 63:
        fail("gate-count")
    return document


def all_cases(document: dict) -> list[dict]:
    cases = [{"name": "baseline", "overrides": {}, "expected_boundary": "defensible-within-model"}]
    cases.extend(
        {"name": case_name, "overrides": {field: False}, "expected_boundary": boundary_name}
        for boundary_name, case_name, field in GATES
    )
    return cases


def find_case(document: dict, name: str) -> dict:
    for case in all_cases(document):
        if case["name"] == name:
            return case
    fail(f"unknown-case:{name}")


def decimal_value(value: str, field: str) -> Decimal:
    try:
        parsed = Decimal(value)
    except InvalidOperation:
        fail(f"invalid-decimal:{field}")
    if not parsed.is_finite():
        fail(f"non-finite:{field}")
    return parsed


def load_ledger(path: str) -> list[dict]:
    with Path(path).open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if tuple(reader.fieldnames or ()) != REQUIRED_COLUMNS:
            fail("ledger-columns")
        rows = list(reader)
    if not rows:
        fail("ledger-empty")
    charge_ids = [row["charge_id"] for row in rows]
    if any(not value for value in charge_ids) or len(charge_ids) != len(set(charge_ids)):
        fail("charge-identity")
    for row in rows:
        if row["currency"] != "USD" or row["charge_period"] != "2026-07":
            fail("ledger-period-or-currency")
        for field in MONEY_COLUMNS:
            decimal_value(row[field], field)
        for field in ("consumed_quantity", "business_units", "successful_transactions", "availability_pct", "latency_p99_ms"):
            decimal_value(row[field], field)
    return rows


def load_targets(path: str) -> dict:
    target = json.loads(Path(path).read_text(encoding="utf-8"))
    required = {
        "schema_version", "period", "currency", "budget", "forecast",
        "forecast_low", "forecast_high", "prior_effective_cost",
        "availability_slo_pct", "latency_slo_ms", "failure_reserve_pct",
        "successful_transactions", "business_units", "shared_allocation_weights",
        "commitment",
    }
    if not isinstance(target, dict) or set(target) != required:
        fail("targets-shape")
    if target["schema_version"] != 1 or target["period"] != "2026-07" or target["currency"] != "USD":
        fail("targets-identity")
    weights = target["shared_allocation_weights"]
    if not isinstance(weights, dict) or set(weights) != {"payments", "search"}:
        fail("allocation-weights")
    if sum(decimal_value(str(value), "weight") for value in weights.values()) != Decimal("1"):
        fail("allocation-weight-total")
    return target


def money(value: Decimal) -> str:
    return str(value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))


def percent(value: Decimal) -> str:
    return str(value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))


def unit_money(value: Decimal) -> str:
    return str(value.quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP))


def analyze(ledger_path: str, target_path: str) -> None:
    rows = load_ledger(ledger_path)
    target = load_targets(target_path)
    totals = {field: sum((decimal_value(row[field], field) for row in rows), Decimal("0")) for field in MONEY_COLUMNS}
    positive_effective = sum((max(decimal_value(row["effective_cost"], "effective_cost"), Decimal("0")) for row in rows), Decimal("0"))
    direct = sum(
        (max(decimal_value(row["effective_cost"], "effective_cost"), Decimal("0")) for row in rows if row["owner"]),
        Decimal("0"),
    )
    shared = sum(
        (decimal_value(row["effective_cost"], "effective_cost") for row in rows if row["cost_pool"] == "shared"),
        Decimal("0"),
    )
    transactions = decimal_value(str(target["successful_transactions"]), "successful_transactions")
    business_units = decimal_value(str(target["business_units"]), "business_units")
    if positive_effective <= 0 or transactions <= 0 or business_units <= 0:
        fail("analysis-denominator")
    allocation_coverage = direct / positive_effective * Decimal("100")
    effective_total = totals["effective_cost"]
    forecast_value = decimal_value(str(target["forecast"]), "forecast")
    budget = decimal_value(str(target["budget"]), "budget")
    prior = decimal_value(str(target["prior_effective_cost"]), "prior")
    print(
        "analysis=pass "
        f"rows={len(rows)} currency=USD "
        f"list={money(totals['list_cost'])} contracted={money(totals['contracted_cost'])} "
        f"billed={money(totals['billed_cost'])} effective={money(effective_total)} "
        f"direct_allocation_pct={percent(allocation_coverage)} shared={money(shared)} "
        f"cost_per_successful_transaction={unit_money(effective_total / transactions)} "
        f"cost_per_business_unit={unit_money(effective_total / business_units)} "
        f"forecast_variance={money(effective_total - forecast_value)} "
        f"budget_headroom={money(budget - effective_total)} "
        f"period_change_pct={percent((effective_total - prior) / prior * Decimal('100'))}"
    )


def allocate(ledger_path: str, target_path: str) -> None:
    rows = load_ledger(ledger_path)
    target = load_targets(target_path)
    shared = sum(
        (decimal_value(row["effective_cost"], "effective_cost") for row in rows if row["cost_pool"] == "shared"),
        Decimal("0"),
    )
    direct_by_owner = {
        owner: sum(
            (decimal_value(row["effective_cost"], "effective_cost") for row in rows if row["owner"] == owner),
            Decimal("0"),
        )
        for owner in ("payments", "search")
    }
    allocated = {
        owner: shared * decimal_value(str(weight), "weight")
        for owner, weight in target["shared_allocation_weights"].items()
    }
    source_total = sum((decimal_value(row["effective_cost"], "effective_cost") for row in rows), Decimal("0"))
    target_total = sum(direct_by_owner.values(), Decimal("0")) + sum(allocated.values(), Decimal("0"))
    credits = sum(
        (decimal_value(row["effective_cost"], "effective_cost") for row in rows if not row["owner"] and row["cost_pool"] == "adjustment"),
        Decimal("0"),
    )
    target_total += credits
    if target_total != source_total:
        fail("allocation-conservation")
    print(
        "allocation=pass "
        f"shared_source={money(shared)} payments_shared={money(allocated['payments'])} "
        f"search_shared={money(allocated['search'])} source_total={money(source_total)} "
        f"target_total={money(target_total)} conservation=true"
    )


def forecast(target_path: str) -> None:
    target = load_targets(target_path)
    forecast_value = decimal_value(str(target["forecast"]), "forecast")
    budget = decimal_value(str(target["budget"]), "budget")
    low = decimal_value(str(target["forecast_low"]), "forecast_low")
    high = decimal_value(str(target["forecast_high"]), "forecast_high")
    if not low <= forecast_value <= high:
        fail("forecast-range")
    print(
        "forecast=pass "
        f"point={money(forecast_value)} low={money(low)} high={money(high)} "
        f"budget={money(budget)} point_to_budget={money(forecast_value - budget)} "
        "uncertainty=explicit"
    )


def commitment(target_path: str) -> None:
    target = load_targets(target_path)
    item = target["commitment"]
    if not isinstance(item, dict) or set(item) != {"monthly_commitment", "eligible_baseline", "covered_usage", "utilized_commitment"}:
        fail("commitment-shape")
    monthly = decimal_value(str(item["monthly_commitment"]), "monthly_commitment")
    eligible = decimal_value(str(item["eligible_baseline"]), "eligible_baseline")
    covered = decimal_value(str(item["covered_usage"]), "covered_usage")
    utilized = decimal_value(str(item["utilized_commitment"]), "utilized_commitment")
    if min(monthly, eligible, covered, utilized) < 0 or monthly == 0 or eligible == 0:
        fail("commitment-values")
    print(
        "commitment=pass "
        f"coverage_pct={percent(covered / eligible * Decimal('100'))} "
        f"utilization_pct={percent(utilized / monthly * Decimal('100'))} "
        f"vacancy={money(monthly - utilized)} risk=requires-demand-and-failure-review"
    )


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: model.py validate|list|show|evaluate|evaluate-all CASES [CASE] | analyze|allocate LEDGER TARGETS | forecast|commitment TARGETS", file=sys.stderr)
        return 2
    action = sys.argv[1]
    try:
        if action in {"validate", "list", "show", "evaluate", "evaluate-all"}:
            document = load_cases(sys.argv[2])
            cases = all_cases(document)
            if action == "validate":
                for case in cases:
                    observed = boundary({**document["base"], **case["overrides"]})
                    if observed != case["expected_boundary"]:
                        fail(f"expectation:{case['name']}:{observed}")
                print(f"model=valid cases={len(cases)} gates={len(GATES)}")
            elif action == "list":
                print("\n".join(case["name"] for case in cases))
            elif action == "show":
                if len(sys.argv) != 4:
                    fail("case-required")
                case = find_case(document, sys.argv[3])
                print(json.dumps({**document["base"], **case["overrides"]}, sort_keys=True, indent=2))
            elif action == "evaluate":
                if len(sys.argv) != 4:
                    fail("case-required")
                case = find_case(document, sys.argv[3])
                observed = boundary({**document["base"], **case["overrides"]})
                print(f"case={case['name']} boundary={observed} expected={case['expected_boundary']}")
            else:
                for case in cases:
                    observed = boundary({**document["base"], **case["overrides"]})
                    print(f"case={case['name']} boundary={observed} expected={case['expected_boundary']}")
        elif action == "analyze":
            if len(sys.argv) != 4:
                fail("ledger-and-targets-required")
            analyze(sys.argv[2], sys.argv[3])
        elif action == "allocate":
            if len(sys.argv) != 4:
                fail("ledger-and-targets-required")
            allocate(sys.argv[2], sys.argv[3])
        elif action == "forecast":
            if len(sys.argv) != 3:
                fail("targets-required")
            forecast(sys.argv[2])
        elif action == "commitment":
            if len(sys.argv) != 3:
                fail("targets-required")
            commitment(sys.argv[2])
        else:
            fail("unknown-action")
    except (OSError, csv.Error, json.JSONDecodeError, ValueError, KeyError, TypeError) as exc:
        print(f"model=fail reason={exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
