#!/usr/bin/env python3
import argparse,json,os,pathlib
P='reliability-atlas-les0047-model-';A={'.les0047-sentinel','cases.json','diagnoses.json'}
def die(x):raise SystemExit(f'model=fail reason={x}')
def root(x):
 r=pathlib.Path(x);e=pathlib.Path('/tmp')/f'{P}{os.getuid()}'
 if r!=e or not r.is_dir() or r.is_symlink() or r.stat().st_uid!=os.getuid() or any(p.is_symlink() for p in r.iterdir()) or not {p.name for p in r.iterdir()}<=A:die('unsafe root')
 return r
def load(p):return json.loads(p.read_text())
def write(p,v):p.write_text(json.dumps(v,sort_keys=True,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('cmd');p.add_argument('root');p.add_argument('name',nargs='?');p.add_argument('--answer');a=p.parse_args();r=root(a.root);c=load(r/'cases.json')
 if len(c)!=8:die('cases')
 if a.cmd=='init':write(r/'diagnoses.json',{});print('initialize=pass cases=8')
 elif a.cmd=='verify':print(f'verify=pass cases=8 diagnosed={len(load(r/"diagnoses.json"))}')
 elif a.cmd=='list':
  for n,v in c.items():print(f'case={n} boundary={v["boundary"]}')
 elif a.name:
  if a.name not in c or (a.answer and a.answer!=c[a.name]['boundary']):die('wrong boundary')
  d=load(r/'diagnoses.json');d[a.name]=c[a.name];write(r/'diagnoses.json',d);print(f'diagnosis=pass case={a.name}')
 else:die('command')
if __name__=='__main__':main()
