# LES-0028 real-runtime scaffold

This directory is quarantined source for a future offline Prometheus, Alertmanager, and Grafana exercise. It is not yet an executable learner command path.

## Current contract

- Prometheus 3.13.2 distroless, Alertmanager 0.33.1, Grafana 13.1.1 Ubuntu, and Python 3.12.13 slim are pinned to exact Linux/amd64 manifest digests.
- The Compose model publishes no host port and uses one internal Docker network.
- Every container has a read-only root filesystem, all Linux capabilities removed, `no-new-privileges`, no restart, finite CPU, memory, swap and PID ceilings, and bounded tmpfs state.
- Prometheus scrapes only the synthetic fixture, evaluates one recording rule and one alerting rule, and sends alerts only to the local Alertmanager.
- Alertmanager has a local receiver with no notification integration.
- Grafana disables update/plugin checks, analytics and sign-up; provisions one local Prometheus data source and one two-panel teaching dashboard.
- The fixture exposes only synthetic values and three bounded state transitions. It contains no secret, credential, personal record or production endpoint.

## Guarded workflow

Use only the wrapper; do not run `docker compose up` manually:

```text
bash runtime.sh doctor
bash runtime.sh prepare --allow-network-downloads   # explicit network step, only when images are absent
bash runtime.sh validate-configs
bash runtime.sh setup
bash runtime.sh status
bash runtime.sh exercise
bash runtime.sh cleanup --expect-token <token-from-setup>
```

The controller performs exact rendered/live resource validation, config validation with the pinned binaries, token-bound ownership state, kernel operation serialization, internal API assertions and ID-bound cleanup. The guarded commands are source-complete, but their Linux execution is still pending the environment gate. Running `docker compose up` manually would bypass those controls and is outside the lesson contract.

The current Windows session has no Docker Linux engine and WSL refuses Ubuntu startup. Static parsing can review this scaffold, but it cannot establish container users, mounts, tmpfs behavior, product configuration acceptance, scrape success, PromQL results, rule state, Alertmanager receipt, Grafana provisioning or cleanup.

## Source boundary

`artifacts.lock.json` records the exact registry identities and official release/download pages reviewed on 2026-08-10. Registry identity does not prove vulnerability absence, license acceptance, configuration correctness, runtime fitness or production readiness.
