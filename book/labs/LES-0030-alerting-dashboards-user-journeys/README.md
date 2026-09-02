# LES-0030 bounded alert-lifecycle model

This local lab teaches alerting and dashboard reasoning without downloading or impersonating Prometheus, Alertmanager, Grafana, a paging provider, or a synthetic-monitoring service.

## Safety boundary

- Run as a normal Ubuntu 24.04 user. Root is refused with exit code `77`.
- The lab requires only Bash, Python 3, and standard core utilities.
- It makes no network, cloud, package-manager, Docker, Kubernetes, systemd, notification, email, SMS, or pager call.
- Its only mutable state is `/tmp/reliability-atlas-les0030-<numeric-uid>`.
- Setup uses a private candidate directory, exact sentinel and manifest, non-symlink files, UID ownership checks, and atomic directory publication.
- Cleanup validates every child before removing the exact UID-scoped state. Unknown children and symlinks are refused.
- The verifier removes only the two exact adversarial entries it creates, then proves final absence.

## What the eight cases teach

| Case | Question answered | Important non-claim |
|---|---|---|
| `alert-quality` | How do precision, recall, false positives, and misses differ? | Declared labels are not a complete production ground truth. |
| `state-machine` | How do normal, pending, firing, retained-firing, and resolved states evolve? | This is not a Prometheus or Grafana scheduler. |
| `burn-rate` | Why must both long and short windows breach? | Arithmetic does not prove the SLI or traffic population is valid. |
| `no-data` | Is the result zero, no data, a missing series, or a query error? | Dynamic discovery needs its own expected-population contract. |
| `routing` | What do deduplication, grouping, inhibition, and silencing change? | Declared flags do not implement Alertmanager matching or delivery. |
| `flapping` | How can a recovery threshold reduce state churn? | Hysteresis can hide reality if its contract is wrong. |
| `dashboard` | Is a panel current, complete, absent, partial, or truly zero? | A panel state does not prove user health or usability. |
| `incident` | Where does a notification storm first diverge? | The fixture does not prove organizational root cause or full impact. |

## Commands

From this directory in Ubuntu:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh run alert-quality
bash lab.sh run state-machine
bash lab.sh run burn-rate
bash lab.sh run no-data
bash lab.sh run routing
bash lab.sh run flapping
bash lab.sh run dashboard
bash lab.sh run incident
bash lab.sh cleanup
```

Run the complete lifecycle and refusal verifier:

```bash
bash verify.sh
```

## Interpretation discipline

For every result, say four things:

1. the exact input population and time window;
2. the boundary or state the result describes;
3. the safest decision the evidence supports;
4. what the model cannot prove.

A passing verifier is mentor-operated project evidence only. It does not establish learner competence, an unseen transfer, retained skill, vendor behavior, production readiness, or mastery.
