#!/usr/bin/env python3
import argparse
import json
import os
import pathlib

PREFIX = "reliability-atlas-les0050-model-"
ALLOWED = {".les0050-sentinel", "architecture.json", "evidence.json"}
SCENARIOS = {
    "zone-loss",
    "quota-exhaustion",
    "api-throttle",
    "managed-region-outage",
    "policy-denial",
    "capacity-shortage",
    "cost-anomaly",
    "shared-dependency",
}


def die(reason):
    raise SystemExit(f"model=fail reason={reason}")


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def validate(data):
    required = {
        "regions", "zones", "replicas", "minimum_ready", "data_scope",
        "steady_units", "peak_units", "quota_units", "replacement_units",
        "scale_rate_per_minute", "startup_minutes", "rpo_minutes",
        "rto_minutes", "restore_minutes", "control_api_on_request_path",
        "inherited_policy_allows_region", "monthly_budget_owner",
    }
    if set(data) != required:
        die("input-shape")
    if len(data["regions"]) != 1 or len(set(data["zones"])) < 2:
        die("topology")
    numeric = ["replicas", "minimum_ready", "steady_units", "peak_units", "quota_units", "replacement_units", "scale_rate_per_minute", "startup_minutes", "rpo_minutes", "rto_minutes", "restore_minutes"]
    if any(not isinstance(data[key], int) or data[key] < 0 for key in numeric):
        die("numeric")
    if data["data_scope"] not in {"zonal", "regional", "multi-region"}:
        die("data-scope")
    if not isinstance(data["control_api_on_request_path"], bool) or not isinstance(data["inherited_policy_allows_region"], bool):
        die("boolean")
    if not isinstance(data["monthly_budget_owner"], str) or not data["monthly_budget_owner"].strip():
        die("budget-owner")
    return data


def root(path):
    candidate = pathlib.Path(path)
    expected = pathlib.Path("/tmp") / f"{PREFIX}{os.getuid()}"
    if candidate != expected or not candidate.is_dir() or candidate.is_symlink():
        die("unsafe-root")
    if candidate.stat().st_uid != os.getuid() or any(item.is_symlink() for item in candidate.iterdir()):
        die("unsafe-owner")
    if not {item.name for item in candidate.iterdir()} <= ALLOWED:
        die("unknown-state")
    return candidate


def evaluate(data):
    surviving = data["replicas"] - max(1, data["replicas"] // len(data["zones"]))
    headroom = data["quota_units"] - data["peak_units"] - data["replacement_units"]
    checks = {
        "zone_diversity": len(set(data["zones"])) >= 2,
        "zone_survivors": surviving >= data["minimum_ready"],
        "data_zone_resilience": data["data_scope"] in {"regional", "multi-region"},
        "quota_headroom": headroom > 0,
        "scale_before_pressure": data["scale_rate_per_minute"] * max(1, data["startup_minutes"]) >= data["replacement_units"],
        "control_data_separation": not data["control_api_on_request_path"],
        "restore_within_rto": data["restore_minutes"] <= data["rto_minutes"],
        "governance": data["inherited_policy_allows_region"],
        "cost_owner": bool(data["monthly_budget_owner"].strip()),
    }
    return checks, surviving, headroom


def scenario(data, name):
    checks, surviving, headroom = evaluate(data)
    if name == "zone-loss":
        return {"scenario": name, "survives": checks["zone_survivors"] and checks["data_zone_resilience"], "ready_replicas": surviving, "boundary": "placement-and-data-scope"}
    if name == "quota-exhaustion":
        return {"scenario": name, "survives": headroom > 0, "headroom_units": headroom, "boundary": "quota-scope"}
    if name == "api-throttle":
        return {"scenario": name, "survives": checks["control_data_separation"], "boundary": "control-data-plane-coupling"}
    if name == "managed-region-outage":
        return {"scenario": name, "survives": data["data_scope"] == "multi-region" or checks["restore_within_rto"], "restore_minutes": data["restore_minutes"], "boundary": "regional-data-recovery"}
    if name == "policy-denial":
        return {"scenario": name, "survives": False, "predicted_denial": True, "boundary": "inherited-governance"}
    if name == "capacity-shortage":
        return {"scenario": name, "survives": False, "boundary": "provider-stock-not-quota", "safe_next": "approved-alternate-or-load-shed"}
    if name == "cost-anomaly":
        return {"scenario": name, "survives": checks["cost_owner"], "boundary": "measured-service-ownership"}
    if name == "shared-dependency":
        return {"scenario": name, "survives": False, "boundary": "correlated-global-dependency"}
    die("scenario")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["show", "evaluate", "scenario", "init", "status"])
    parser.add_argument("source")
    parser.add_argument("name", nargs="?")
    args = parser.parse_args()
    source = pathlib.Path(args.source)
    if args.command in {"init", "status"}:
        work = root(source)
        data = validate(load(work / "architecture.json"))
    else:
        data = validate(load(source))
    if args.command == "show":
        print(json.dumps(data, sort_keys=True, indent=2))
    elif args.command == "evaluate":
        checks, surviving, headroom = evaluate(data)
        decision = "pass" if all(checks.values()) else "fail"
        print(json.dumps({"decision": decision, "checks": checks, "surviving_replicas": surviving, "quota_headroom_units": headroom}, sort_keys=True))
    elif args.command == "scenario":
        if args.name not in SCENARIOS:
            die("scenario")
        print(json.dumps(scenario(data, args.name), sort_keys=True))
    elif args.command == "init":
        (source / "evidence.json").write_text("{}\n", encoding="utf-8")
        print("initialize=pass scenarios=8")
    elif args.command == "status":
        print("status=pass scenarios=8")


if __name__ == "__main__":
    main()
