#!/usr/bin/env python3
import argparse, hashlib, json, os, pathlib, sys

ALLOWED={".les0042-sentinel","cases.json","state.json","diagnoses.json"}
ROOT_PREFIX="reliability-atlas-les0042-model-"

def fail(message):
    raise SystemExit(f"model=fail reason={message}")

def safe_root(raw):
    root=pathlib.Path(raw)
    expected=pathlib.Path("/tmp")/f"{ROOT_PREFIX}{os.getuid()}"
    if root != expected or root.is_symlink() or not root.is_dir(): fail("unsafe root")
    if root.stat().st_uid != os.getuid(): fail("wrong owner")
    names={p.name for p in root.iterdir()}
    if not names <= ALLOWED: fail("unexpected inventory")
    if any(p.is_symlink() for p in root.iterdir()): fail("symlink refused")
    return root

def load(path): return json.loads(path.read_text(encoding="utf-8"))
def write(path,data): path.write_text(json.dumps(data,sort_keys=True,indent=2)+"\n",encoding="utf-8")

def initialize(root):
    root=safe_root(root); cases=load(root/"cases.json")
    digest=hashlib.sha256((root/"cases.json").read_bytes()).hexdigest()
    write(root/"state.json",{"runtime":"kubernetes-workload-model-only","cases":len(cases),"fixtureSha256":digest})
    write(root/"diagnoses.json",{})
    print(f"initialize=pass cases={len(cases)} runtime=kubernetes-workload-model-only")

def verify(root):
    root=safe_root(root); cases=load(root/"cases.json"); state=load(root/"state.json"); diagnoses=load(root/"diagnoses.json")
    if len(cases)!=8 or state.get("cases")!=8: fail("case count")
    if state.get("fixtureSha256")!=hashlib.sha256((root/"cases.json").read_bytes()).hexdigest(): fail("fixture changed")
    if not set(diagnoses) <= set(cases): fail("unknown diagnosis")
    print(f"verify=pass cases={len(cases)} diagnosed={len(diagnoses)}")

def diagnose(root,name,answer=None):
    root=safe_root(root); cases=load(root/"cases.json")
    if name not in cases: fail("unknown case")
    item=cases[name]; proposed=answer or item["boundary"]
    if proposed != item["boundary"]: fail(f"wrong boundary case={name}")
    diagnoses=load(root/"diagnoses.json"); diagnoses[name]={"boundary":proposed,"evidence":item["evidence"]}; write(root/"diagnoses.json",diagnoses)
    print(f"diagnosis=pass case={name} boundary={proposed} nodeName={item['nodeName'] or '<empty>'} reason={item['reason']}")

def list_cases(root):
    root=safe_root(root)
    for name,item in load(root/"cases.json").items(): print(f"case={name} phase={item['phase']} nodeName={item['nodeName'] or '<empty>'} reason={item['reason']}")

def main():
    p=argparse.ArgumentParser(); p.add_argument("command",choices=["initialize","verify","list","diagnose"]); p.add_argument("root"); p.add_argument("name",nargs="?"); p.add_argument("--answer")
    a=p.parse_args()
    if a.command=="initialize": initialize(a.root)
    elif a.command=="verify": verify(a.root)
    elif a.command=="list": list_cases(a.root)
    elif a.command=="diagnose":
        if not a.name: fail("case required")
        diagnose(a.root,a.name,a.answer)

if __name__=="__main__": main()
