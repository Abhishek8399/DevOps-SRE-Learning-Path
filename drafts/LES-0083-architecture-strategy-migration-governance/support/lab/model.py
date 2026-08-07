#!/usr/bin/env python3
"""Deterministic strategy/migration review model; no provider or runtime calls."""

from __future__ import annotations

import json
import sys
from decimal import Decimal, InvalidOperation, ROUND_CEILING, ROUND_HALF_UP
from pathlib import Path
from typing import NoReturn

GATES = (
    ("mandate","decision-mandate-undefined","decision_mandate_bound"),
    ("owner","executive-owner-or-sponsor-undefined","executive_owner_bound"),
    ("outcome","business-outcomes-unmeasurable","business_outcomes_measurable"),
    ("scope","scope-or-non-goals-unbound","scope_and_non_goals_bound"),
    ("stakeholders","stakeholders-or-operators-missing","stakeholders_and_operators_bound"),
    ("current-state","current-state-asserted-without-evidence","current_state_evidenced"),
    ("inventory","portfolio-inventory-unversioned","portfolio_inventory_versioned"),
    ("confidence","evidence-confidence-hidden","evidence_confidence_visible"),
    ("unknowns","unknowns-unowned","unknowns_owned"),
    ("criticality","application-criticality-unbound","application_criticality_bound"),
    ("business-cycle","business-cycles-or-freezes-missing","business_cycles_bound"),
    ("dependencies","dependencies-unclassified","dependencies_classified"),
    ("shared-services","shared-services-and-blast-radius-unmapped","shared_services_mapped"),
    ("data-gravity","data-volume-or-gravity-unquantified","data_gravity_quantified"),
    ("regulation","regulatory-constraints-unbound","regulatory_constraints_bound"),
    ("residency","residency-constraints-unbound","residency_constraints_bound"),
    ("contracts","contract-renewal-or-exit-dates-unbound","contract_dates_bound"),
    ("delivery-capacity","skills-or-team-capacity-unbound","skills_and_capacity_bound"),
    ("options","strategy-options-incomplete","strategy_options_complete"),
    ("retain-retire","retain-or-retire-not-considered","retire_and_retain_considered"),
    ("value","modernization-value-unbound","modernization_value_bound"),
    ("target-state","target-state-or-transition-state-unbound","target_state_bound"),
    ("principles","architecture-principles-unmeasurable","architecture_principles_testable"),
    ("standards","standards-applicability-unbound","standards_applicability_bound"),
    ("exceptions","exception-process-unowned","exception_process_owned"),
    ("decision-rights","decision-rights-or-escalation-unbound","decision_rights_bound"),
    ("governance-cadence","governance-cadence-or-evidence-missing","governance_cadence_bound"),
    ("risk-criteria","risk-likelihood-impact-criteria-unbound","risk_criteria_bound"),
    ("risk-owner","risk-treatment-or-owner-unbound","risk_owners_bound"),
    ("security-lifecycle","security-or-privacy-lifecycle-unbound","security_privacy_lifecycle_bound"),
    ("supplier-risk","supplier-supply-chain-risk-unreviewed","supplier_risk_reviewed"),
    ("vendor-security","vendor-security-evidence-unbound","vendor_security_evidence_bound"),
    ("vendor-exit","vendor-exit-plan-unbound","vendor_exit_plan_bound"),
    ("portability","portability-or-interoperability-unbound","portability_and_interoperability_bound"),
    ("data-export","data-export-format-semantics-or-time-unbound","data_export_semantics_bound"),
    ("limits","service-limits-or-quotas-unbound","service_limits_and_quotas_bound"),
    ("commercial","commercial-assumptions-unversioned","commercial_assumptions_versioned"),
    ("cost","cost-model-semantics-unbound","cost_model_semantics_bound"),
    ("unit-economics","unit-outcome-or-denominator-unbound","unit_economics_bound"),
    ("benefits","benefits-baseline-or-counterfactual-unbound","benefits_baseline_bound"),
    ("opportunity-cost","opportunity-cost-hidden","opportunity_cost_visible"),
    ("uncertainty","estimate-range-or-confidence-unbound","uncertainty_range_bound"),
    ("sensitivity","decision-sensitivity-unanalyzed","sensitivity_analyzed"),
    ("capacity-growth","capacity-or-growth-model-invalid","capacity_growth_model_valid"),
    ("failure-reserve","largest-failure-reserve-invalid","failure_reserve_valid"),
    ("foundation","target-foundation-readiness-unbound","foundation_readiness_bound"),
    ("platform-readiness","identity-network-or-logging-not-ready","identity_network_and_logging_ready"),
    ("wave-dependencies","migration-wave-dependencies-unbound","wave_dependencies_bound"),
    ("wave-capacity","wave-size-exceeds-delivery-capacity","wave_capacity_bound"),
    ("coexistence","coexistence-architecture-unbound","coexistence_architecture_bound"),
    ("compatibility","compatibility-window-unbound","compatibility_window_bound"),
    ("writer","writer-authority-or-fencing-unbound","writer_authority_bound"),
    ("sync","data-sync-lag-or-loss-unbound","data_sync_and_lag_bound"),
    ("cutover","cutover-window-does-not-close","cutover_budget_valid"),
    ("rollback","rollback-feasibility-unproved","rollback_feasibility_bound"),
    ("forward-recovery","forward-recovery-unbound","forward_recovery_bound"),
    ("reconciliation","business-reconciliation-unbound","reconciliation_bound"),
    ("decommission","decommission-or-retention-evidence-unbound","decommission_evidence_bound"),
    ("success","migration-success-metrics-unbound","success_metrics_bound"),
    ("signals","leading-or-lagging-signals-unbound","leading_and_lagging_signals_bound"),
    ("go-no-go","go-no-go-authority-unbound","go_no_go_authority_bound"),
    ("stop","stop-conditions-unbound","stop_conditions_bound"),
    ("handover","operational-handover-unbound","operational_handover_bound"),
    ("support","support-model-or-escalation-unbound","support_model_bound"),
    ("roadmap","roadmap-dependencies-unbound","roadmap_dependencies_bound"),
    ("decision-record","strategy-decision-record-incomplete","decision_record_complete"),
    ("communication","stakeholder-narrative-not-audience-fit","stakeholder_narrative_fit"),
    ("review-trigger","review-or-supersession-trigger-unbound","review_triggers_bound"),
    ("validation","strategy-validation-plan-missing","validation_plan_bound"),
    ("cleanup","temporary-portfolio-data-cleanup-inexact","cleanup_exact"),
)
FIELDS = {field for _, _, field in GATES}

def fail(reason: str) -> NoReturn:
    raise ValueError(reason)

def dec(value: object, field: str) -> Decimal:
    try:
        result = Decimal(str(value))
    except InvalidOperation:
        fail(f"invalid-decimal:{field}")
    if not result.is_finite():
        fail(f"non-finite:{field}")
    return result

def rnd(value: Decimal, places: str = "0.01") -> str:
    return str(value.quantize(Decimal(places), rounding=ROUND_HALF_UP))

def ceil(value: Decimal) -> int:
    return int(value.to_integral_value(rounding=ROUND_CEILING))

def load_cases(path: str) -> dict:
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(doc, dict) or set(doc) != {"schema_version","base"} or doc["schema_version"] != 1:
        fail("cases-shape")
    if not isinstance(doc["base"], dict) or set(doc["base"]) != FIELDS:
        fail("cases-fields")
    if any(type(v) is not bool for v in doc["base"].values()):
        fail("cases-types")
    if len(GATES) != 70:
        fail("gate-count")
    return doc

def cases(doc: dict) -> list[dict]:
    result=[{"name":"baseline","overrides":{},"expected":"defensible-within-model"}]
    result.extend({"name":case,"overrides":{field:False},"expected":gate} for gate,case,field in GATES)
    return result

def find(doc: dict, name: str) -> dict:
    for item in cases(doc):
        if item["name"] == name:
            return item
    fail(f"unknown-case:{name}")

def boundary(candidate: dict) -> str:
    for gate,_,field in GATES:
        if candidate[field] is not True:
            return gate
    return "defensible-within-model"

def load_strategy(path: str) -> dict:
    data=json.loads(Path(path).read_text(encoding="utf-8"))
    required={"schema_version","strategy_id","decision","currency","portfolio","capacity","transfer","economics","vendor_weights","vendors"}
    if not isinstance(data,dict) or set(data) != required:
        fail("strategy-shape")
    if data["schema_version"] != 1 or data["strategy_id"] != "payments-modernization-strategy-v1" or data["currency"] != "USD":
        fail("strategy-identity")
    if set(data["portfolio"]) != {"applications_total","observed_records","owner_declared_records","unknown_records","critical_applications"}:
        fail("portfolio-shape")
    if set(data["capacity"]) != {"current_peak_rps","annual_growth_pct","years","headroom_pct","instance_sustainable_rps_at_slo","failure_domains","tolerated_domain_losses"}:
        fail("capacity-shape")
    if set(data["transfer"]) != {"data_tb_decimal","usable_link_gbps","transfer_efficiency_pct","source_change_gb_per_hour","final_sync_effective_gb_per_hour","validation_hours","cutover_window_hours"}:
        fail("transfer-shape")
    if set(data["economics"]) != {"current_annual_cost","target_annual_cost","one_time_program_cost","horizon_months"}:
        fail("economics-shape")
    dimensions={"security","reliability","portability","operability","cost"}
    if set(data["vendor_weights"]) != dimensions or sum((dec(v,"weight") for v in data["vendor_weights"].values()),Decimal(0)) != Decimal(1):
        fail("vendor-weights")
    if not isinstance(data["vendors"],list) or {v.get("id") for v in data["vendors"]} != {"managed-suite","portable-platform"}:
        fail("vendors")
    return data

def validate(cpath: str, spath: str) -> None:
    doc=load_cases(cpath); load_strategy(spath)
    print(f"model=valid cases={len(cases(doc))} gates={len(GATES)} calculations=5")

def inventory(spath: str) -> None:
    p=load_strategy(spath)["portfolio"]
    total=int(p["applications_total"]); observed=int(p["observed_records"]); declared=int(p["owner_declared_records"]); unknown=int(p["unknown_records"])
    if observed+declared+unknown != total or int(p["critical_applications"]) > total:
        fail("portfolio-total")
    print(f"inventory=pass total={total} observed={observed} declared={declared} unknown={unknown} observed_pct={rnd(Decimal(observed)*100/total)} unknown_pct={rnd(Decimal(unknown)*100/total)} evidence_not_uniform=true")

def capacity(spath: str) -> None:
    c=load_strategy(spath)["capacity"]
    peak=dec(c["current_peak_rps"],"peak"); growth=dec(c["annual_growth_pct"],"growth")/100; years=int(c["years"]); head=dec(c["headroom_pct"],"headroom")/100; rate=dec(c["instance_sustainable_rps_at_slo"],"rate"); domains=int(c["failure_domains"]); losses=int(c["tolerated_domain_losses"])
    if min(peak,rate) <= 0 or domains <= losses or years < 0:
        fail("capacity-input")
    future=peak*((Decimal(1)+growth)**years); target=future*(Decimal(1)+head); healthy=ceil(target/rate); survivors=domains-losses; per_domain=ceil(Decimal(healthy)/survivors); provisioned=per_domain*domains; surviving=Decimal(per_domain*survivors)*rate
    if surviving < target:
        fail("failure-reserve")
    print(f"capacity=pass future_peak_rps={rnd(future)} target_rps={rnd(target)} healthy_instances={healthy} per_domain={per_domain} provisioned_instances={provisioned} surviving_rps={rnd(surviving)} assumptions_require_validation=true")

def transfer(spath: str) -> None:
    t=load_strategy(spath)["transfer"]
    tb=dec(t["data_tb_decimal"],"data"); gbps=dec(t["usable_link_gbps"],"link"); efficiency=dec(t["transfer_efficiency_pct"],"efficiency")/100; change=dec(t["source_change_gb_per_hour"],"change"); final_rate=dec(t["final_sync_effective_gb_per_hour"],"final"); validation=dec(t["validation_hours"],"validation"); window=dec(t["cutover_window_hours"],"window")
    if min(tb,gbps,efficiency,final_rate,window) <= 0 or efficiency > 1:
        fail("transfer-input")
    bulk_hours=(tb*Decimal(8000))/(gbps*efficiency*Decimal(3600)); changed=bulk_hours*change; final_hours=changed/final_rate; cutover=final_hours+validation
    print(f"transfer=pass bulk_hours={rnd(bulk_hours)} source_delta_gb={rnd(changed)} final_sync_hours={rnd(final_hours)} validation_hours={rnd(validation)} cutover_hours={rnd(cutover)} window_hours={rnd(window)} closes={str(cutover<=window).lower()} decimal_units=true")
    if cutover > window:
        fail("cutover-window")

def economics(spath: str) -> None:
    e=load_strategy(spath)["economics"]
    current=dec(e["current_annual_cost"],"current"); target=dec(e["target_annual_cost"],"target"); one=dec(e["one_time_program_cost"],"one-time"); months=int(e["horizon_months"]); annual_saving=current-target
    if annual_saving <= 0 or months <= 0:
        fail("economics-input")
    years=Decimal(months)/12; current_total=current*years; proposed_total=target*years+one; net=current_total-proposed_total; break_even=one/annual_saving*12
    print(f"economics=pass horizon_months={months} current_total={rnd(current_total)} proposed_total={rnd(proposed_total)} net_saving={rnd(net)} break_even_months={rnd(break_even)} breaks_even_within_horizon={str(break_even<=months).lower()} benefits_excluded=true")

def vendor(spath: str) -> None:
    data=load_strategy(spath); scores={}
    for vendor in data["vendors"]:
        scores[vendor["id"]]=sum((dec(vendor[f"{d}_score"],d)*dec(w,"weight") for d,w in data["vendor_weights"].items()),Decimal(0))
    feasible=[v for v in data["vendors"] if v["security_evidence"] is True and v["exit_plan"] is True]
    if not feasible:
        fail("no-feasible-vendor")
    selected=max(feasible,key=lambda v:scores[v["id"]])["id"]
    print(f"vendor=pass managed_suite={rnd(scores['managed-suite'])} portable_platform={rnd(scores['portable-platform'])} managed_suite_veto=exit-plan feasible_selected={selected} score_is_advisory=true decision_authority=human-review-required")

def evaluate(cpath: str, name: str) -> None:
    doc=load_cases(cpath); case=find(doc,name); candidate=dict(doc["base"]); candidate.update(case["overrides"]); actual=boundary(candidate)
    if actual != case["expected"]:
        fail(f"boundary-mismatch:{name}")
    print(f"case={name} boundary={actual}")

def evaluate_all(cpath: str) -> None:
    doc=load_cases(cpath)
    for item in cases(doc):
        candidate=dict(doc["base"]); candidate.update(item["overrides"]); actual=boundary(candidate)
        if actual != item["expected"]:
            fail(f"boundary-mismatch:{item['name']}")
        print(f"case={item['name']} boundary={actual}")

def list_cases(cpath: str) -> None:
    for item in cases(load_cases(cpath)): print(item["name"])

def show(cpath: str,name: str) -> None:
    print(json.dumps(find(load_cases(cpath),name),sort_keys=True,separators=(",",":")))

def roadmap(spath: str) -> None:
    data=load_strategy(spath)
    print(f"roadmap=pass strategy_id={data['strategy_id']} stages=discover->rationalize->foundation->pilot->waves->reconcile->decommission decision=human-owned provider_calls=none")

def main() -> None:
    try:
        cmd=sys.argv[1] if len(sys.argv)>1 else "help"
        if cmd=="validate" and len(sys.argv)==4: validate(sys.argv[2],sys.argv[3])
        elif cmd=="list" and len(sys.argv)==3: list_cases(sys.argv[2])
        elif cmd=="show" and len(sys.argv)==4: show(sys.argv[2],sys.argv[3])
        elif cmd=="evaluate" and len(sys.argv)==4: evaluate(sys.argv[2],sys.argv[3])
        elif cmd=="evaluate-all" and len(sys.argv)==3: evaluate_all(sys.argv[2])
        elif cmd=="roadmap" and len(sys.argv)==3: roadmap(sys.argv[2])
        elif cmd=="inventory" and len(sys.argv)==3: inventory(sys.argv[2])
        elif cmd=="capacity" and len(sys.argv)==3: capacity(sys.argv[2])
        elif cmd=="transfer" and len(sys.argv)==3: transfer(sys.argv[2])
        elif cmd=="economics" and len(sys.argv)==3: economics(sys.argv[2])
        elif cmd=="vendor" and len(sys.argv)==3: vendor(sys.argv[2])
        else: fail("usage")
    except (OSError,json.JSONDecodeError,ValueError) as error:
        print(f"model=fail reason={error}",file=sys.stderr); raise SystemExit(1) from error

if __name__=="__main__":
    main()
