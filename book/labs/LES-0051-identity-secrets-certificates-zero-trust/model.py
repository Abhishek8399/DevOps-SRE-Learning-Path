#!/usr/bin/env python3
import argparse,json,os,pathlib
P='reliability-atlas-les0051-model-';A={'.les0051-sentinel','cases.json','evidence.json'}
def die(x):raise SystemExit(f'model=fail reason={x}')
def load(p):return json.loads(p.read_text())
def root(x):
 r=pathlib.Path(x);e=pathlib.Path('/tmp')/f'{P}{os.getuid()}'
 if r!=e or not r.is_dir() or r.is_symlink() or r.stat().st_uid!=os.getuid() or any(p.is_symlink() for p in r.iterdir()) or not {p.name for p in r.iterdir()}<=A:die('unsafe-root')
 return r
def check(v):
 rules=[('issuer-trust',v['issuer_trusted']),('audience',v['audience_ok']),('token-time',v['time_ok']),('authorization-scope',v['scope_ok']),('credential-lifecycle',v['credential_state']!='leaked-static'),('certificate-validity',v['certificate_ok']),('identity-lifecycle',v['identity_active']),('key-state',v['key_state']=='active')]
 for n,ok in rules:
  if not ok:return {'decision':'deny','boundary':n}
 if not v['control_available']:
  return {'decision':'bounded-existing-session-only','boundary':'identity-control-plane'} if v['credential_state']=='bounded-existing-session' else {'decision':'deny','boundary':'identity-control-plane'}
 return {'decision':'allow','boundary':'resource-policy'}
def main():
 p=argparse.ArgumentParser();p.add_argument('cmd');p.add_argument('source');p.add_argument('name',nargs='?');a=p.parse_args()
 if a.cmd in {'init','status'}:r=root(a.source);c=load(r/'cases.json')
 else:c=load(pathlib.Path(a.source))
 if len(c)!=9 or a.name and a.name not in c:die('cases')
 if a.cmd=='show':print(json.dumps(c[a.name],sort_keys=True,indent=2))
 elif a.cmd=='evaluate':print(json.dumps({'case':a.name,**check(c[a.name])},sort_keys=True))
 elif a.cmd=='list':
  for n in c:print(f'case={n}')
 elif a.cmd=='init':(r/'evidence.json').write_text('{}\n');print('initialize=pass cases=9')
 elif a.cmd=='status':print('status=pass cases=9')
 else:die('command')
if __name__=='__main__':main()
