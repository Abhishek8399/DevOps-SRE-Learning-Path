#!/usr/bin/env python3
import argparse,hashlib,json,os,pathlib
P='reliability-atlas-les0045-model-';A={'.les0045-sentinel','cases.json','state.json','diagnoses.json'}
def die(x):raise SystemExit(f'model=fail reason={x}')
def root(x):
 r=pathlib.Path(x);e=pathlib.Path('/tmp')/f'{P}{os.getuid()}'
 if r!=e or not r.is_dir() or r.is_symlink() or r.stat().st_uid!=os.getuid() or any(p.is_symlink() for p in r.iterdir()) or not {p.name for p in r.iterdir()}<=A:die('unsafe root')
 return r
def load(p):return json.loads(p.read_text())
def write(p,v):p.write_text(json.dumps(v,sort_keys=True,indent=2)+'\n')
def init(x):
 r=root(x);c=load(r/'cases.json');write(r/'state.json',{'runtime':'kubernetes-security-model-only','cases':8,'sha':hashlib.sha256((r/'cases.json').read_bytes()).hexdigest()});write(r/'diagnoses.json',{});print('initialize=pass cases=8')
def verify(x):
 r=root(x);c=load(r/'cases.json');s=load(r/'state.json');d=load(r/'diagnoses.json')
 if len(c)!=8 or s.get('sha')!=hashlib.sha256((r/'cases.json').read_bytes()).hexdigest() or not set(d)<=set(c):die('state')
 print(f'verify=pass cases=8 diagnosed={len(d)}')
def diag(x,n,a=None):
 r=root(x);c=load(r/'cases.json');
 if n not in c:die('case')
 b=c[n]['boundary'];
 if (a or b)!=b:die('wrong boundary')
 d=load(r/'diagnoses.json');d[n]=c[n];write(r/'diagnoses.json',d);print(f'diagnosis=pass case={n} gate={c[n]["gate"]} boundary={b}')
def main():
 p=argparse.ArgumentParser();p.add_argument('cmd');p.add_argument('root');p.add_argument('name',nargs='?');p.add_argument('--answer');a=p.parse_args()
 if a.cmd=='init':init(a.root)
 elif a.cmd=='verify':verify(a.root)
 elif a.cmd=='list':
  for n,v in load(root(a.root)/'cases.json').items():print(f'case={n} gate={v["gate"]}')
 elif a.name:diag(a.root,a.name,a.answer)
 else:die('command')
if __name__=='__main__':main()
