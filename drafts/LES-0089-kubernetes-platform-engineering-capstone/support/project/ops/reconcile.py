#!/usr/bin/env python3
"""Apply one committed desired-state file and record an auditable receipt."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import tempfile
import time
from pathlib import Path


class ReconcileError(RuntimeError):
    pass


def run(command: list[str], *, cwd: Path, stdin: str | None = None, ok: set[int] = {0}) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command, cwd=cwd, input=stdin, text=True, capture_output=True, check=False
    )
    if result.returncode not in ok:
        detail = (result.stderr or result.stdout).strip()
        raise ReconcileError(f"command failed rc={result.returncode}: {' '.join(command)}: {detail}")
    return result


def repository_root(start: Path) -> Path:
    result = run(["git", "rev-parse", "--show-toplevel"], cwd=start)
    return Path(result.stdout.strip()).resolve()


def resolve_commit(root: Path, revision: str) -> str:
    if not revision or revision.startswith("-"):
        raise ReconcileError("revision is empty or option-shaped")
    result = run(["git", "rev-parse", "--verify", f"{revision}^{{commit}}"], cwd=root)
    commit = result.stdout.strip()
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ReconcileError("Git did not return a full commit identity")
    return commit


def validate_source(path: str) -> str:
    candidate = Path(path)
    if candidate.is_absolute() or ".." in candidate.parts:
        raise ReconcileError("source must be a repository-relative path without traversal")
    normalized = candidate.as_posix()
    required = "drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/"
    if not normalized.startswith(required) or not normalized.endswith((".yaml", ".yml")):
        raise ReconcileError(f"source must be one CAP-002 desired-state YAML under {required}")
    return normalized


def committed_source(root: Path, commit: str, path: str) -> str:
    result = run(["git", "show", f"{commit}:{path}"], cwd=root)
    if not result.stdout.strip():
        raise ReconcileError("committed desired state is empty")
    return result.stdout


def write_receipt(path: Path, value: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".reconcile.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    except BaseException:
        Path(temporary).unlink(missing_ok=True)
        raise


def reconcile_once(
    root: Path, commit: str, source_path: str, kubeconfig: Path, receipt_path: Path
) -> dict[str, object]:
    desired = committed_source(root, commit, source_path)
    digest = hashlib.sha256(desired.encode()).hexdigest()
    environment = {**os.environ, "KUBECONFIG": str(kubeconfig)}
    diff = subprocess.run(
        ["kubectl", "diff", "--server-side", "--field-manager=atlas-reconciler", "-f", "-"],
        cwd=root, input=desired, text=True, capture_output=True, check=False, env=environment,
    )
    if diff.returncode not in {0, 1}:
        raise ReconcileError(f"kubectl diff failed rc={diff.returncode}: {(diff.stderr or diff.stdout).strip()}")
    apply = subprocess.run(
        [
            "kubectl", "apply", "--server-side", "--field-manager=atlas-reconciler",
            "--force-conflicts", "-f", "-",
        ],
        cwd=root, input=desired, text=True, capture_output=True, check=False, env=environment,
    )
    if apply.returncode != 0:
        raise ReconcileError(f"kubectl apply failed rc={apply.returncode}: {(apply.stderr or apply.stdout).strip()}")
    receipt: dict[str, object] = {
        "schemaVersion": 1,
        "commit": commit,
        "source": source_path,
        "desiredSha256": digest,
        "driftObserved": diff.returncode == 1,
        "applyOutput": [line for line in apply.stdout.splitlines() if line],
    }
    write_receipt(receipt_path, receipt)
    return receipt


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True)
    parser.add_argument("--revision", default="HEAD")
    parser.add_argument("--kubeconfig", type=Path)
    parser.add_argument("--receipt", type=Path)
    parser.add_argument("--watch-seconds", type=int, default=0)
    parser.add_argument("--iterations", type=int, default=1)
    args = parser.parse_args()
    try:
        project_root = Path(__file__).resolve().parents[1]
        root = repository_root(project_root)
        source = validate_source(args.source)
        kubeconfig = (args.kubeconfig or project_root / ".state/kubeconfig").resolve()
        receipt = (args.receipt or project_root / ".state/reconcile-receipt.json").resolve()
        if not kubeconfig.is_file():
            raise ReconcileError(f"kubeconfig not found: {kubeconfig}")
        if args.iterations < 1 or args.watch_seconds < 0:
            raise ReconcileError("iterations must be positive and watch-seconds non-negative")
        for iteration in range(args.iterations):
            commit = resolve_commit(root, args.revision)
            outcome = reconcile_once(root, commit, source, kubeconfig, receipt)
            print(
                f"reconcile=pass iteration={iteration + 1} commit={commit[:12]} "
                f"drift={str(outcome['driftObserved']).lower()} sha256={outcome['desiredSha256']}"
            )
            if iteration + 1 < args.iterations:
                time.sleep(args.watch_seconds)
        return 0
    except (OSError, ReconcileError) as error:
        print(f"reconcile=failed reason={error}", file=os.sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
