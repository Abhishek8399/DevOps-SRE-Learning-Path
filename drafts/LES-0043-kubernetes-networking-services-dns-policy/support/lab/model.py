#!/usr/bin/env python3
import argparse,hashlib,json,os,pathlib
PREFIX="reliability-atlas-les0043-model-"; ALLOWED={".les0043-sentinel","cases.json","state.json","diagnoses.json"}
def fail(x): raise SystemExit(f"model=fail reason={x}")
def root(p):
 r=pathlib.Path(p); e=pathlib.Path("/tmp")/f"{PREFIX}{os.getuid()}"
 if r!=e or not r.is_dir() or r.is_symlink() or r.stat().st_uid!=os.getuid(): fail("unsafe root")
 if any(x.is_symlink() for x in r.iterdir()) or not {x.name for x in r.iterdir()}<=ALLOWED: fail("unsafe inventory")
 return r
def load(p): return json.loads(p.read_text(encoding="utf-8"))
def write(p,v): p.write_text(json.dumps(v,sort_keys=True,indent=2)+"\n",encoding="utf-8")
def init(p):
 r=root(p); c=load(r/"cases.json"); write(r/"state.json",{"runtime":"kubernetes-network-model-only","cases":len(c),"sha":hashlib.sha256((r/"cases.json").read_bytes()).hexdigest()}); write(r/"diagnoses.json",{}); print(f"initialize=pass cases={len(c)}")
def verify(p):
 r=root(p); c=load(r/"cases.json"); s=load(r/"state.json"); d=load(r/"diagnoses.json")
 if len(c)!=7 or s.get("cases")!=7 or s.get("sha")!=hashlib.sha256((r/"cases.json").read_bytes()).hexdigest() or not set(d)<=set(c): fail("state invalid")
 print(f"verify=pass cases=7 diagnosed={len(d)}")
def diagnose(p,n,a=None):
 r=root(p); c=load(r/"cases.json");
 if n not in c: fail("unknown case")
 expected=c[n]["boundary"]
 if (a or expected)!=expected: fail(f"wrong boundary case={n}")
 d=load(r/"diagnoses.json"); d[n]={"boundary":expected,"evidence":c[n]["evidence"]}; write(r/"diagnoses.json",d); print(f"diagnosis=pass case={n} boundary={expected} last={c[n]['last']}")
def main():
 p=argparse.ArgumentParser(); p.add_argument("command",choices=["init","verify","list","diagnose"]); p.add_argument("root"); p.add_argument("name",nargs="?"); p.add_argument("--answer"); a=p.parse_args()
 if a.command=="init": init(a.root)
 elif a.command=="verify": verify(a.root)
 elif a.command=="list":
  for n,v in load(root(a.root)/"cases.json").items(): print(f"case={n} last={v['last']} evidence={v['evidence']}")
 elif a.name: diagnose(a.root,a.name,a.answer)
 else: fail("case required")
if __name__=="__main__": main()
