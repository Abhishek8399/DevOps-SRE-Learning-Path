#!/usr/bin/env python3
"""Ordered-stage local CI teaching engine."""

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
        {"contract", "engine", "pipelineIdentity", "portableInput", "schemaVersion", "sourceIdentity", "stages"},
        "stage-config",
    )
    if config["schemaVersion"] != 1 or config["engine"] != "local-stage":
        raise ValueError("stage-config-identity-invalid")
    for field in ("pipelineIdentity", "portableInput", "sourceIdentity"):
        if not isinstance(config[field], str) or not config[field]:
            raise ValueError(f"stage-{field}-invalid")
    validate_contract(config)
    stages = config["stages"]
    if not isinstance(stages, list) or len(stages) != 2:
        raise ValueError("stages-invalid")
    for stage in stages:
        if not isinstance(stage, dict):
            raise ValueError("stage-must-be-object")
        require_exact_keys(stage, {"id", "jobs"}, "stage")
        if not isinstance(stage["jobs"], list):
            raise ValueError("stage-jobs-must-be-array")
        for job in stage["jobs"]:
            if not isinstance(job, dict):
                raise ValueError("stage-job-must-be-object")
            require_exact_keys(job, {"action", "id"}, "stage-job")
    expected = [
        {"id": "build-stage", "jobs": [{"action": "build", "id": "build"}]},
        {"id": "test-stage", "jobs": [{"action": "test", "id": "test"}]},
    ]
    if stages != expected:
        raise ValueError("stage-job-contract-invalid")
    return stages


def run(config_path: Path, workspace: Path, portable_job: Path) -> dict[str, Any]:
    config_bytes, config = load_json(config_path)
    stages = validate_config(config)
    runtime = Runtime(workspace, portable_job, config["portableInput"])
    for stage in stages:
        for job in stage["jobs"]:
            runtime.execute(job["id"], job["action"])
    return runtime.report(config_bytes, config, "local-stage", ["build->test"])


def main() -> None:
    if os.geteuid() == 0:
        raise SystemExit("root-is-refused-run-as-a-normal-user")
    parser = argparse.ArgumentParser(description="offline stage CI teaching engine")
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
        print(f"stage-engine-refused={error}", file=sys.stderr)
        raise SystemExit(65) from error
