# LES-0032 bounded SLO control-loop lab

This lab teaches arithmetic and decision boundaries for service level indicators (SLIs), service level objectives (SLOs), service level agreements (SLAs), error budgets, aggregation, telemetry coverage, burn rates, and policy. It reads one fictional checked-in scenario. It does **not** contact Prometheus, Grafana, Kubernetes, a cloud, a customer, a pager, or a production service.

## Environment contract

| Property | Contract |
|---|---|
| Tested design target | Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS |
| Runtime | Bash and Python 3 standard library |
| User | Normal user; `lab.sh` and `verify.sh` refuse UID 0 |
| Network | None |
| Privilege | No `sudo`, capabilities, daemon, container, namespace, mount, or package installation |
| CPU and memory | One short-lived Python process; under 128 MiB expected |
| Disk | One private `/tmp/reliability-atlas-les0032-<uid>` directory; under 1 MiB expected |
| Ports | None |
| Changes | Sentinel, manifest, copied fixture, and at most nine JSON result files inside the exact state directory |

The model is deterministic teaching software. Its output is not evidence that a real SLI is valid, an SLO is approved, an SLA is enforceable, a page is actionable, or a change is authorized.

## Preflight

Run from this directory:

```bash
# [READ-ONLY]
id
command -v bash
command -v python3
bash lab.sh doctor
python3 fixtures/slo_model.py validate-scenario fixtures/scenario.json
```

Stop if you are root, a required command is missing, the fixture fails validation, `/tmp` is not the expected real path, or an existing state directory is refused. Do not broadly delete a refused path.

## Lifecycle

```bash
# [MUTATING / BOUNDED]
bash lab.sh setup

# [READ-ONLY]
bash lab.sh status

# [MUTATING / BOUNDED]
bash lab.sh run event-sli
bash lab.sh run time-budget
bash lab.sh run latency
bash lab.sh run coverage
bash lab.sh run aggregation
bash lab.sh run burn
bash lab.sh run alerting
bash lab.sh run low-traffic
bash lab.sh run policy

# [MUTATING / BOUNDED]
bash lab.sh cleanup

# [READ-ONLY]
bash lab.sh status
```

Each `run` overwrites only its own allowed result file after validating the complete state descriptor. Read output as a calculation over declared input—not as a production verdict.

## Full verification

```bash
# [MUTATING / BOUNDED]
bash verify.sh
```

The verifier checks syntax, scenario and state contracts, nine cases, 24 semantic assertions, refusal of an unexpected file, refusal of a symlink child, exact cleanup, and final state absence. Its exit status is the primary result. The final line must contain `verification=passed`, `cases=9`, `assertions=24`, and `final_state=absent`.

## Recovery and cleanup

If a case fails, keep the first error. Run `bash lab.sh status`. If state validates, run `bash lab.sh cleanup`, then repeat `doctor` and `setup`. If state is refused, preserve the exact path for review; the script intentionally refuses ambiguous deletion.

Cleanup validates the exact `/tmp` parent, lesson-and-UID basename, resolved path, owner, sentinel, manifest, scenario, allowed child names, file types, and child owners before removal. It then proves absence.

## Proof boundary

Passing proves only that the checked-in deterministic fixture and guarded local lifecycle behaved as asserted on the recorded environment. It does not prove real-user coverage, telemetry completeness, SLO fitness, stakeholder approval, contractual meaning, production PromQL correctness, paging delivery, learner independence, delayed retention, or mastery.
