#!/usr/bin/env python3
"""Run the complete bounded CAP-003 runtime verification matrix."""

from __future__ import annotations

import subprocess
import sys
import time
from pathlib import Path
from typing import Sequence

PROJECT_ROOT = Path(__file__).resolve().parent
DATACTL = [sys.executable, str(PROJECT_ROOT / "datactl.py")]


class VerificationFailure(RuntimeError):
    """A command or an evidence assertion did not match the reviewed scenario."""


def execute(
    arguments: Sequence[str],
    *,
    expected_exit: int = 0,
    timeout: int = 240,
) -> str:
    result = subprocess.run(
        list(arguments),
        cwd=PROJECT_ROOT,
        text=True,
        encoding="utf-8",
        errors="strict",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
        check=False,
    )
    combined = "\n".join(
        part.strip() for part in (result.stdout, result.stderr) if part.strip()
    )
    if combined:
        print(combined)
    if result.returncode != expected_exit:
        raise VerificationFailure(
            f"command exit differs: expected={expected_exit} "
            f"observed={result.returncode} command={list(arguments)!r}"
        )
    return combined


def require_text(receipt: str, expected: str) -> None:
    if expected not in receipt:
        raise VerificationFailure(f"receipt is missing expected evidence: {expected}")


def control(*arguments: str, expected_exit: int = 0) -> str:
    return execute([*DATACTL, *arguments], expected_exit=expected_exit)


def cycle_duplicate_and_poison() -> None:
    control("up")
    control("init")
    first = control("submit", "requests/order-001.json")
    require_text(first, '"replayed": false')
    replay = control("submit", "requests/order-001.json")
    require_text(replay, '"replayed": true')
    conflict = control(
        "submit", "requests/order-001-conflict.json", expected_exit=2
    )
    require_text(conflict, "idempotency_conflict")
    interrupted = control("relay", "--stop-after-publish", expected_exit=75)
    require_text(interrupted, "outbox_ack=false")
    control("relay")
    control("inject-poison")
    consumed = control("consume")
    require_text(
        consumed,
        "records=3 new=1 duplicates=1 quarantined=1 cache=converged",
    )
    replayed = control("consume")
    require_text(
        replayed,
        "records=3 new=0 duplicates=2 quarantined=1 cache=converged",
    )
    status = control("status")
    for evidence in (
        '"facts": 1',
        '"orders": 1',
        '"quarantine": 1',
        '"duplicate_deliveries": 1',
    ):
        require_text(status, evidence)
    control("cleanup")


def cycle_skew_and_reconciliation() -> None:
    control("up")
    control("init")
    seeded = control("seed-backlog", "--count", "9", "--partition", "0")
    require_text(seeded, 'end_offsets={"0":9,"1":0,"2":0}')
    waiting = control("backlog")
    require_text(waiting, '"dominant_partition_share_pct":100.0')
    require_text(waiting, '"total_lag":9')
    failed_gate = control("reconcile", expected_exit=4)
    require_text(failed_gate, "reconcile=fail")
    require_text(failed_gate, '"missing_facts":9')
    consumed = control("consume")
    require_text(consumed, "records=9 new=9 duplicates=0 quarantined=0")
    drained = control("backlog")
    require_text(drained, '"total_lag":0')
    passed_gate = control("reconcile")
    require_text(passed_gate, "reconcile=pass")
    require_text(passed_gate, '"missing_facts":0')
    control("cleanup")


def cycle_backup_restore_replay() -> None:
    control("up")
    control("init")
    control("seed-backlog", "--count", "6", "--partition", "1")
    backup = control("backup")
    require_text(backup, "backup=pass")
    require_text(backup, '"orders":6')
    restored = control("restore")
    require_text(restored, "restore=pass target=isolated_database")
    require_text(restored, "snapshot_rpo_rows=0")
    replayed = control("replay-restore")
    require_text(replayed, "replay-restore=pass applied=6 duplicates=0 skipped=0")
    require_text(replayed, '"missing_facts":0')
    refused = control("restore", expected_exit=2)
    require_text(refused, "isolated restore database already exists")
    control("cleanup")
    if (PROJECT_ROOT / ".runtime").exists():
        raise VerificationFailure("runtime artifact directory remains after cleanup")


def main() -> int:
    started = time.monotonic()
    owns_runtime = False
    try:
        execute([sys.executable, "-m", "py_compile", "datactl.py"])
        execute([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"])
        execute(
            [
                "docker",
                "compose",
                "--env-file",
                "toolchain.env",
                "config",
                "--quiet",
            ]
        )
        for name, scenario in (
            ("duplicate-poison", cycle_duplicate_and_poison),
            ("skew-reconciliation", cycle_skew_and_reconciliation),
            ("backup-restore-replay", cycle_backup_restore_replay),
        ):
            owns_runtime = True
            print(f"scenario={name} state=running")
            scenario()
            owns_runtime = False
            print(f"scenario={name} state=passed")
    except (
        OSError,
        subprocess.TimeoutExpired,
        VerificationFailure,
    ) as error:
        print(f"verify=fail error={error}", file=sys.stderr)
        if owns_runtime:
            cleanup = subprocess.run(
                [*DATACTL, "cleanup"],
                cwd=PROJECT_ROOT,
                text=True,
                encoding="utf-8",
                errors="replace",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=180,
                check=False,
            )
            print(
                "failure_cleanup="
                f"{'pass' if cleanup.returncode == 0 else 'refused'} "
                f"exit={cleanup.returncode}",
                file=sys.stderr,
            )
        return 1
    elapsed = round(time.monotonic() - started, 3)
    print(
        "verify=pass scenarios=3 "
        "runtime_start=absent runtime_end=absent "
        f"elapsed_seconds={elapsed}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
