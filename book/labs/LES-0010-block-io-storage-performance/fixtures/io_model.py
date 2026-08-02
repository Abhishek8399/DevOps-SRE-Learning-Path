#!/usr/bin/env python3
"""Deterministic teaching model for LES-0010.

This program prints synthetic observations.  It performs no disk benchmark and
does not inspect host performance.  Stable values let a learner reason about
rates, latency, concurrency, and boundaries without creating I/O pressure.
"""

from __future__ import annotations

import argparse
import sys


PROFILES = {
    "baseline": {
        "app_p95_ms": 42,
        "commit_p95_ms": 7,
        "requests_s": 120,
        "device": "vda",
        "r_s": 38.0,
        "w_s": 142.0,
        "rkb_s": 1216.0,
        "wkb_s": 4544.0,
        "rrqm": 3.0,
        "wrqm": 18.0,
        "r_await": 2.1,
        "w_await": 4.8,
        "aqu": 0.72,
        "util": 31.0,
        "dirty_kib": 16384,
        "writeback_kib": 512,
        "blocked": 0,
        "bi_kib_s": 1216,
        "bo_kib_s": 4544,
        "pid": 4242,
        "kbrd_s": 40.0,
        "kbwr_s": 4096.0,
        "iodelay": 0,
        "operation": "ok",
    },
    "incident": {
        "app_p95_ms": 918,
        "commit_p95_ms": 844,
        "requests_s": 119,
        "device": "vda",
        "r_s": 41.0,
        "w_s": 139.0,
        "rkb_s": 1312.0,
        "wkb_s": 4448.0,
        "rrqm": 4.0,
        "wrqm": 19.0,
        "r_await": 8.2,
        "w_await": 612.0,
        "aqu": 84.90,
        "util": 99.2,
        "dirty_kib": 262144,
        "writeback_kib": 65536,
        "blocked": 17,
        "bi_kib_s": 1312,
        "bo_kib_s": 4448,
        "pid": 4242,
        "kbrd_s": 52.0,
        "kbwr_s": 4096.0,
        "iodelay": 602,
        "operation": "timeout",
    },
    "recovered": {
        "app_p95_ms": 51,
        "commit_p95_ms": 9,
        "requests_s": 121,
        "device": "vda",
        "r_s": 39.0,
        "w_s": 145.0,
        "rkb_s": 1248.0,
        "wkb_s": 4640.0,
        "rrqm": 3.0,
        "wrqm": 17.0,
        "r_await": 2.5,
        "w_await": 6.1,
        "aqu": 0.91,
        "util": 36.4,
        "dirty_kib": 18432,
        "writeback_kib": 1024,
        "blocked": 0,
        "bi_kib_s": 1248,
        "bo_kib_s": 4640,
        "pid": 4242,
        "kbrd_s": 44.0,
        "kbwr_s": 4192.0,
        "iodelay": 4,
        "operation": "ok",
    },
}


def require_profile(name: str) -> dict[str, object]:
    try:
        return PROFILES[name]
    except KeyError:
        raise SystemExit(f"unsupported_profile={name}") from None


def summary(profile: str) -> None:
    value = require_profile(profile)
    print("scope=synthetic-checkout-volume interval_s=60 clock=virtual")
    print(
        f"profile={profile} requests_s={value['requests_s']} "
        f"app_p95_ms={value['app_p95_ms']} commit_p95_ms={value['commit_p95_ms']} "
        f"operation={value['operation']}"
    )


def path(profile: str) -> None:
    value = require_profile(profile)
    print("stage owner input output evidence")
    print(f"request api accepted completed app_p95_ms={value['app_p95_ms']}")
    print(f"commit filesystem dirty-pages durable-intent commit_p95_ms={value['commit_p95_ms']}")
    print(f"writeback kernel dirty-pages block-requests Dirty_kib={value['dirty_kib']}")
    print(f"device block-layer requests completions w_await_ms={value['w_await']}")
    print(f"result api completion response operation={value['operation']}")


def device(profile: str) -> None:
    v = require_profile(profile)
    print("Device r/s rkB/s rrqm/s r_await w/s wkB/s wrqm/s w_await aqu-sz %util")
    print(
        f"{v['device']} {v['r_s']:.1f} {v['rkb_s']:.1f} {v['rrqm']:.1f} "
        f"{v['r_await']:.1f} {v['w_s']:.1f} {v['wkb_s']:.1f} {v['wrqm']:.1f} "
        f"{v['w_await']:.1f} {v['aqu']:.2f} {v['util']:.1f}"
    )
    print("sample_semantics=interval-derived synthetic=true units=rates-per-second,kibibytes,ms,average-requests,percent")


def system(profile: str) -> None:
    v = require_profile(profile)
    print("procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----")
    print(" r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st")
    wa = 3 if profile != "incident" else 37
    idle = 82 if profile != "incident" else 48
    print(f" 2 {v['blocked']:2d}      0 524288  32768 786432    0    0 {v['bi_kib_s']:5d} {v['bo_kib_s']:5d} 1100 2400 10 5 {idle:2d} {wa:2d} 0")
    print(f"Dirty_kib={v['dirty_kib']} Writeback_kib={v['writeback_kib']} interval_s=1 synthetic=true")


def process(profile: str) -> None:
    v = require_profile(profile)
    print("UID PID kB_rd/s kB_wr/s kB_ccwr/s iodelay Command")
    print(f"1000 {v['pid']} {v['kbrd_s']:.1f} {v['kbwr_s']:.1f} 0.0 {v['iodelay']} ledger-api")
    print("sample_semantics=interval-derived synthetic=true iodelay_unit=clock-ticks")


def mount(_: str) -> None:
    print("TARGET SOURCE FSTYPE OPTIONS MAJ:MIN")
    print("/srv/ledger /dev/mapper/vgdata-ledger ext4 rw,relatime 253:2")
    print("parent_chain=vda2>dm-2 filesystem_boundary=/srv/ledger synthetic=true")


def verify(profile: str) -> None:
    value = require_profile(profile)
    if value["operation"] != "ok":
        print(f"operation_verified=false profile={profile} result={value['operation']}")
        raise SystemExit(1)
    print(f"operation_verified=true profile={profile} result=ok synthetic=true")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="deterministic LES-0010 I/O evidence model")
    parser.add_argument("view", choices=("summary", "path", "device", "system", "process", "mount", "verify"))
    parser.add_argument("profile", choices=tuple(PROFILES), nargs="?", default="incident")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    functions = {
        "summary": summary,
        "path": path,
        "device": device,
        "system": system,
        "process": process,
        "mount": mount,
        "verify": verify,
    }
    functions[args.view](args.profile)
    return 0


if __name__ == "__main__":
    sys.exit(main())
