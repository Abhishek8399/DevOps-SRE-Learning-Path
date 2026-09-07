# LES-0067 guarded offline lab

This deterministic model teaches the first unsafe boundary across operational task definition, user impact, telemetry identity and time, data quality, seasonality, labels, time-safe evaluation, baselines, thresholds, review capacity, alert deduplication/grouping, topology/change evidence, causal claims, forecasts, explanations, feedback, automation authority, idempotency, rollback, drift and privacy.

It does **not** run an anomaly detector, forecasting model, log parser, topology engine, incident platform, observability backend or remediation controller. It calls no model, API, network service or external resource and contains no customer data or credential. Its output is teaching evidence only.

Supported environment: Ubuntu 24.04, normal user, Bash and Python 3 standard library, no network or credentials. State is limited to `/tmp/reliability-atlas-les0067-aiops-<uid>`.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate seasonality-ignored
bash lab.sh evaluate correlation-claimed-cause
bash lab.sh evaluate automation-overprivileged
bash lab.sh cleanup
bash verify.sh
```

Expected: `verify=pass cases=29 refusal=true cleanup=true`. Stop on any guard failure; never bypass ownership, sentinel, symlink, unknown-artifact, credential or external-endpoint checks.
