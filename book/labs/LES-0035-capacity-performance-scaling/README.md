# LES-0035 bounded capacity reasoning lab

This lab teaches capacity reasoning without generating load. It reads a fictional JSON scenario, runs seven deterministic calculations, writes only one validated UID-scoped directory under `/tmp`, opens no port, and sends no network request.

## Requirements

- Ubuntu 24.04 or WSL 2 Ubuntu 24.04
- a normal, non-root user
- Bash, Python 3, and standard GNU utilities

From this directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh run curve
bash lab.sh run queue
bash lab.sh run forecast
bash lab.sh run autoscale
bash lab.sh run workload
bash lab.sh run overload
bash verify.sh
```

The verifier checks the scenario contract, lifecycle, operation accounting, performance knee, Little's Law arithmetic, forecast, autoscaling delay, workload validity, overload policy, unexpected-entry refusal, and exact cleanup.

The state path is exactly `/tmp/reliability-atlas-les0035-<uid>`. Cleanup validates the real path, owner, sentinel, manifest, scenario and allowed children before removal. If validation refuses a state, preserve it and inspect it; do not delete a lookalike path manually.

This model does not benchmark the computer or establish production capacity. Its numbers are fictional. A real load test still requires authorization, representative traffic and data, isolated blast radius, generator calibration, staged ramps, abort conditions, recovery proof, observability, cost review and an explicit decision owner.
