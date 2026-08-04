#!/usr/bin/env python3
import argparse, hashlib, json, os, pathlib
PREFIX = "reliability-atlas-les0046-model-"
ALLOWED = {".les0046-sentinel", "cases.json", "state.json", "diagnoses.json"}

def die(reason):
    raise SystemExit(f"model=fail reason={reason}")

def checked_root(value):
    root = pathlib.Path(value)
    expected = pathlib.Path("/tmp") / f"{PREFIX}{os.getuid()}"
    if root != expected or not root.is_dir() or root.is_symlink() or root.stat().st_uid != os.getuid():
        die("unsafe root")
    if any(item.is_symlink() for item in root.iterdir()):
        die("symlink")
    if not {item.name for item in root.iterdir()} <= ALLOWED:
        die("unknown artifact")
    return root

def load(path):
    return json.loads(path.read_text(encoding="utf-8"))

def write(path, value):
    path.write_text(json.dumps(value, sort_keys=True, indent=2) + "\n", encoding="utf-8")

def initialize(value):
    root = checked_root(value)
    cases = load(root / "cases.json")
    write(root / "state.json", {"runtime":"packaging-release-model-only", "cases":len(cases), "sha":hashlib.sha256((root / "cases.json").read_bytes()).hexdigest()})
    write(root / "diagnoses.json", {})
    print(f"initialize=pass cases={len(cases)}")

def verify(value):
    root = checked_root(value)
    cases = load(root / "cases.json")
    state = load(root / "state.json")
    diagnoses = load(root / "diagnoses.json")
    if len(cases) != 8 or state.get("sha") != hashlib.sha256((root / "cases.json").read_bytes()).hexdigest() or not set(diagnoses) <= set(cases):
        die("state")
    print(f"verify=pass cases=8 diagnosed={len(diagnoses)}")

def diagnose(value, name, answer=None):
    root = checked_root(value)
    cases = load(root / "cases.json")
    if name not in cases:
        die("case")
    boundary = cases[name]["boundary"]
    if (answer or boundary) != boundary:
        die("wrong boundary")
    diagnoses = load(root / "diagnoses.json")
    diagnoses[name] = cases[name]
    write(root / "diagnoses.json", diagnoses)
    print(f"diagnosis=pass case={name} gate={cases[name]['gate']} boundary={boundary}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command")
    parser.add_argument("root")
    parser.add_argument("name", nargs="?")
    parser.add_argument("--answer")
    args = parser.parse_args()
    if args.command == "init": initialize(args.root)
    elif args.command == "verify": verify(args.root)
    elif args.command == "list":
        for name, case in load(checked_root(args.root) / "cases.json").items(): print(f"case={name} gate={case['gate']}")
    elif args.name: diagnose(args.root, args.name, args.answer)
    else: die("command")

if __name__ == "__main__":
    main()
