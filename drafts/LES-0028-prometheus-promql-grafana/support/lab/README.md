# LES-0028 bounded metrics reasoning lab

This lab makes counter resets, label matching, histogram buckets, cardinality multiplication, alert state, dashboard contracts, and an incident path inspectable on Ubuntu without downloads.

It is deliberately **not** Prometheus, PromQL, Alertmanager, Grafana, a provider service, a benchmark, or production evidence. Its Python code implements only the named deterministic teaching cases. Exact runtime work requires separately reviewed immutable artifacts and configuration.

## Environment card

| Field | Contract |
|---|---|
| OS | Ubuntu 24.04 LTS; WSL 2 Ubuntu 24.04 supported |
| Privilege | normal user; UID 0 is refused |
| Network | none |
| Required commands | Bash, Python 3, `id`, `mktemp`, `mv`, `cp`, `rm`, `readlink`, `stat`, `find`, `wc`; verifier additionally uses `grep`, `touch`, and `ln` |
| CPU/RAM/disk | one short Python process; less than 5 MiB owned state |
| Ports/processes | no listening ports and no persistent child process |
| State | exact `/tmp/reliability-atlas-les0028-<UID>` directory |
| Abort | wrong owner/type/path, symlink, unexpected child, invalid manifest/fixture, root caller, failed assertion |
| Cost | no cloud and no paid resource |

## Architecture

```text
checked-in scenario.json
        |
        v
lab.sh --guarded copy--> exact UID-owned /tmp state
        |                           |
        +---- run case ------------+
                    |
                    v
          deterministic Python model
                    |
                    v
          bounded result-<case>.json
```

The wrapper owns lifecycle and path safety. The model owns fixture validation and arithmetic. Result files are evidence only for the exact deterministic inputs.

## Commands

```bash
# [READ-ONLY]
bash lab.sh doctor

# [MUTATING / BOUNDED]
bash lab.sh setup

# [READ-ONLY]
bash lab.sh status

# [MUTATING / BOUNDED]
bash lab.sh run counter-rate
bash lab.sh run vector-match
bash lab.sh run histogram
bash lab.sh run cardinality
bash lab.sh run alert-state
bash lab.sh run dashboard-contract
bash lab.sh run incident

# [MUTATING / BOUNDED]
bash verify.sh

# [MUTATING / BOUNDED]
bash lab.sh cleanup
```

`verify.sh` checks shell and Python syntax, all seven deterministic cases, expected arithmetic, unexpected-child refusal, symlink-child refusal, cleanup, and final absence. Its exit handler removes only the exact adversarial entries it created, attempts validated lab cleanup after failure, and reports a cleanup failure instead of silently discarding it.

## Expected key evidence

The counter case reports:

```text
attemptDelta=232
failureDelta=10
resetCount=2
```

These fields use a simple segment-increase algorithm documented in the result. They are not exact Prometheus `rate()` extrapolation.

The cardinality case reports a bounded maximum of 1,920 series from declared bounded domains and separately reports `request_id` as unbounded. It does not estimate exact bytes.

The final verifier line has this shape:

```text
verification=passed lesson=LES-0028 cases=7 ... cleanup=passed final_state=absent runtime=deterministic-model-only
```

## Troubleshooting

- `root-not-required`: leave the root shell and run as a normal Ubuntu user.
- `missing-tool`: stop. This lab never installs packages. Use a reviewed external setup step if your approved environment lacks a standard prerequisite.
- `unexpected_child` or `unsafe_child_type`: preserve the refused state and inspect the named entry. Do not recursively delete an ambiguous path.
- `manifest_invalid` or `sentinel_invalid`: the wrapper cannot prove ownership. Preserve evidence and do not bypass the guard.
- failed arithmetic assertion: inspect the first failing case and the checked-in scenario. Do not weaken the expected result just to make verification green.

## Cleanup and proof

Cleanup validates the exact parent and basename, resolved path, numeric owner, sentinel, manifest, scenario, allowed child names, file types, ownership, and size before removing the exact state directory. It then proves the path is absent.

The verifier's cleanup covers only the declared lab state. It says nothing about unrelated `/tmp` content or system cleanliness.
