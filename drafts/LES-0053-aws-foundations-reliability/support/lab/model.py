#!/usr/bin/env python3
import argparse
import json
import os
import pathlib

PREFIX = "reliability-atlas-les0053-model-"
ALLOWED = {".les0053-sentinel", "cases.json", "evidence.json"}
FIELDS = {
    "identity_bounded",
    "immutable_artifact",
    "private_data",
    "multi_az",
    "quota_headroom",
    "restore_tested",
    "user_sli",
    "bounded_retries",
}


def die(reason):
    raise SystemExit(f"model=fail reason={reason}")


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def guarded_root(value):
    candidate = pathlib.Path(value)
    expected = pathlib.Path("/tmp") / f"{PREFIX}{os.getuid()}"
    if candidate != expected or not candidate.is_dir() or candidate.is_symlink():
        die("unsafe-root")
    if candidate.stat().st_uid != os.getuid():
        die("unsafe-owner")
    children = list(candidate.iterdir())
    if any(child.is_symlink() for child in children):
        die("child-symlink")
    if {child.name for child in children} - ALLOWED:
        die("unexpected-artifact")
    sentinel = candidate / ".les0053-sentinel"
    if not sentinel.is_file() or sentinel.read_text(encoding="utf-8") != f"les0053:{os.getuid()}\n":
        die("sentinel")
    return candidate


def validate(cases):
    if not isinstance(cases, dict) or len(cases) != 9:
        die("case-count")
    for name, value in cases.items():
        if not isinstance(name, str) or not isinstance(value, dict) or set(value) != FIELDS:
            die("shape")
        if any(type(value[field]) is not bool for field in FIELDS):
            die("type")
    return cases


def evaluate(value):
    checks = [
        ("identity", value["identity_bounded"]),
        ("artifact", value["immutable_artifact"]),
        ("network-exposure", value["private_data"]),
        ("failure-domain", value["multi_az"]),
        ("capacity-quota", value["quota_headroom"]),
        ("recovery", value["restore_tested"]),
        ("observability", value["user_sli"]),
        ("resilience", value["bounded_retries"]),
    ]
    for boundary, passed in checks:
        if not passed:
            return {"decision": "not-operable", "boundary": boundary}
    return {"decision": "operable", "boundary": "user-outcome"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command")
    parser.add_argument("source")
    parser.add_argument("name", nargs="?")
    args = parser.parse_args()

    if args.command in {"init", "status"}:
        root = guarded_root(args.source)
        cases = validate(load(root / "cases.json"))
    else:
        cases = validate(load(pathlib.Path(args.source)))
        root = None

    if args.name is not None and args.name not in cases:
        die("case")

    if args.command == "show":
        print(json.dumps(cases[args.name], indent=2, sort_keys=True))
    elif args.command == "evaluate":
        print(json.dumps({"case": args.name, **evaluate(cases[args.name])}, sort_keys=True))
    elif args.command == "list":
        for name in cases:
            print(f"case={name}")
    elif args.command == "init":
        (root / "evidence.json").write_text("{}\n", encoding="utf-8")
        print("initialize=pass cases=9")
    elif args.command == "status":
        print("status=pass cases=9")
    else:
        die("command")


if __name__ == "__main__":
    main()

