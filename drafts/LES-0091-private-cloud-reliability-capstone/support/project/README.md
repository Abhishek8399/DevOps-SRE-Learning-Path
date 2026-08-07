# CAP-004 private-cloud reliability simulator

This project is a deterministic teaching simulator. It does **not** install, connect to or operate KVM, libvirt, OpenStack, Ceph, OVS, OVN, Redfish, SSH, a BMC, a cloud account or a production endpoint.

## What it models

- physical racks, power/network failure domains and controller quorum;
- Nova-like resource-provider inventory, allocations, traits and generations;
- CPU/machine compatibility, maintenance drain, migration and evacuation choices;
- OVN intent, chassis bindings, gateway HA, MTU and external-path validation;
- Ceph pool protection, rack-aware placement, fullness and recovery headroom;
- identity, quota, trusted-image and tenant-network admission;
- control-plane and storage upgrade compatibility;
- isolated recovery with cross-authority reconciliation.

The simulator is useful because it forces state ownership and evidence to be explicit. It cannot prove that real OpenStack, Ceph or OVN software behaves correctly in your environment.

## Safe lifecycle

Run from this directory with Python 3.12 or newer:

```bash
python -m unittest discover -s tests -v
python cloudctl.py check
python cloudctl.py initialize
python cloudctl.py baseline
python cloudctl.py scenario compute-host-loss
python cloudctl.py cleanup
python verify.py
```

`python verify.py` is the complete absent-to-absent matrix. It refuses root on POSIX, validates exact project identity, runs all declared scenarios against isolated state, builds a design dossier, asserts expected safe decisions and proves cleanup.

## Safety boundary

- Inputs are only `topology.json` and `workloads.json` in this directory.
- Identifiers must be lowercase synthetic names; hostnames, addresses and credentials are prohibited.
- `.runtime` must be a real directory owned by this project, not a symlink.
- Every mutating command requires a matching runtime descriptor.
- Cleanup removes only the allowlisted generated files after descriptor and path checks.
- No subprocess, socket, HTTP client, virtualization API or infrastructure CLI is used.
- An expected refusal or degraded outcome is evidence, not a harness failure.

If a descriptor, file, schema, identity or ownership check fails, stop. Do not delete the directory manually until you understand why the guard refused.

## Scenario result vocabulary

| Result | Meaning |
|---|---|
| `safe` | The declared workload remains within its contract under the simulated condition. |
| `degraded` | Service may continue, but redundancy, latency or recovery margin is reduced. |
| `blocked` | Admission or change is refused before unsafe mutation. |
| `unavailable` | The user operation is not currently satisfied; recovery steps are required. |

A “safe” simulator result is not a production availability claim. It means only that the model’s explicit invariants held for the fixture.
