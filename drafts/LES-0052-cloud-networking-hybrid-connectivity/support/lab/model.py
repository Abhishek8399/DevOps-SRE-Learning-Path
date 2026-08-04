#!/usr/bin/env python3
import argparse,json,os,pathlib,ipaddress
P='reliability-atlas-les0052-model-';A={'.les0052-sentinel','cases.json','evidence.json'}
def die(x):raise SystemExit(f'model=fail reason={x}')
def load(p):return json.loads(p.read_text())
def root(x):
 r=pathlib.Path(x);e=pathlib.Path('/tmp')/f'{P}{os.getuid()}'
 if r!=e or not r.is_dir() or r.is_symlink() or r.stat().st_uid!=os.getuid() or any(p.is_symlink() for p in r.iterdir()) or not {p.name for p in r.iterdir()}<=A:die('unsafe-root')
 return r
def validate(cases):
 if len(cases)!=9:die('case-count')
 required={'source_cidr','remote_cidr','dns_private','endpoint_identity','forward_route','return_route','policy_allow','nat_capacity','mtu_ok','transit_required'}
 for value in cases.values():
  if set(value)!=required:die('shape')
  ipaddress.ip_network(value['source_cidr']);ipaddress.ip_network(value['remote_cidr'])
 return cases
def evaluate(v):
 a=ipaddress.ip_network(v['source_cidr']);b=ipaddress.ip_network(v['remote_cidr'])
 checks=[('address-plan',not a.overlaps(b)),('dns-endpoint',v['dns_private'] and v['endpoint_identity']),('forward-route',v['forward_route']),('transitivity',not v['transit_required']),('network-policy',v['policy_allow']),('nat-capacity',v['nat_capacity']),('mtu-path',v['mtu_ok']),('return-route',v['return_route'])]
 for boundary,ok in checks:
  if not ok:return {'decision':'unreachable','boundary':boundary}
 return {'decision':'reachable','boundary':'application'}
def main():
 p=argparse.ArgumentParser();p.add_argument('cmd');p.add_argument('source');p.add_argument('name',nargs='?');a=p.parse_args()
 if a.cmd in {'init','status'}:r=root(a.source);cases=validate(load(r/'cases.json'))
 else:cases=validate(load(pathlib.Path(a.source)))
 if a.name and a.name not in cases:die('case')
 if a.cmd=='show':print(json.dumps(cases[a.name],sort_keys=True,indent=2))
 elif a.cmd=='evaluate':print(json.dumps({'case':a.name,**evaluate(cases[a.name])},sort_keys=True))
 elif a.cmd=='list':
  for name in cases:print(f'case={name}')
 elif a.cmd=='init':(r/'evidence.json').write_text('{}\n');print('initialize=pass cases=9')
 elif a.cmd=='status':print('status=pass cases=9')
 else:die('command')
if __name__=='__main__':main()
