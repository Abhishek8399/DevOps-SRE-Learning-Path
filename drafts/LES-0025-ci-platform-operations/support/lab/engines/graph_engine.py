#!/usr/bin/env python3
"""Dependency-graph local CI teaching engine."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any

from engine_runtime import Runtime, canonical_json, load_json, require_exact_keys, validate_contract


def validate_config(config: dict[str, Any]) -> list[dict[str, Any]]:
    require_exact_keys(
        config,
        {"contract", "engine", "jobs", "pipelineIdentity", "portableInput", "schemaVersion", "sourceIdentity"},
        "graph-config",
    )
    if config["schemaVersion"] != 1 or config["engine"] != "local-graph":
        raise ValueError("graph-config-identity-invalid")
    for field in ("pipelineIdentity", "portableInput", "sourceIdentity"):
        if not isinstance(config[field], str) or not config[field]:
            raise ValueError(f"graph-{field}-invalid")
    validate_contract(config)
    jobs = config["jobs"]
    if not isinstance(jobs, list) or len(jobs) != 2:
        raise ValueError("graph-jobs-invalid")
    for job in jobs:
        if not isinstance(job, dict):
            raise ValueError("graph-job-must-be-object")
        require_exact_keys(job, {"action", "id", "needs"}, "graph-job")
    expected = [
        {"action": "build", "id": "build", "needs": []},
        {"action": "test", "id": "test", "needs": ["build"]},
    ]
    if jobs != expected:
        raise ValueError("graph-job-contract-invalid")
    return jobs


def run(config_path: Path, workspace: Path, portable_job: Path) -> dict[str, Any]:
    config_bytes, config = load_json(config_path)
    jobs = validate_config(config)
    runtime = Runtime(workspace, portable_job, config["portableInput"])
    pending = {job["id"]: job for job in jobs}
    completed: set[str] = set()
    while pending:
        ready = [job for job in jobs if job["id"] in pending and set(job["needs"]) <= completed]
        if not ready:
            raise ValueError("graph-has-cycle-or-missing-dependency")
        for job in ready:
            runtime.execute(job["id"], job["action"])
            completed.add(job["id"])
            del pending[job["id"]]
    return runtime.report(config_bytes, config, "local-graph", ["build->test"])


def main() -> None:
    if os.geteuid() == 0:
        raise SystemExit("root-is-refused-run-as-a-normal-user")
    parser = argparse.ArgumentParser(description="offline graph CI teaching engine")
    parser.add_argument("--config", required=True)
    parser.add_argument("--workspace", required=True)
    parser.add_argument("--portable-job", required=True)
    args = parser.parse_args()
    report = run(Path(args.config), Path(args.workspace), Path(args.portable_job))
    print(canonical_json(report))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"graph-engine-refused={error}", file=sys.stderr)
        raise SystemExit(65) from error
