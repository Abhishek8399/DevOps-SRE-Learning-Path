# Atlas production-service reliability capstone

This is a **local training fixture**, not an Internet-facing production service. It lets one service evolve through code, state, tests, delivery, containers, TLS, telemetry, SLOs, incidents, backup, restore and rollback without requiring a cloud account.

Python's standard-library HTTP server keeps the mechanism visible and the baseline dependency-free. Python's own documentation says `http.server` is not recommended for production; do not remove that boundary or expose this fixture to untrusted traffic.

## What runs

| Boundary | Purpose | Default address |
|---|---|---|
| Python service | API, liveness, readiness, metrics and SQLite owner | `127.0.0.1:8080` locally |
| App container | Non-root, read-only image with writable state volume | `127.0.0.1:18080` |
| NGINX profile | Disposable local TLS and proxy deadlines | `https://127.0.0.1:18443` |
| Prometheus profile | Internal scrape, rules and 24-hour local TSDB | `127.0.0.1:19090` |

The application and Prometheus share an internal backend network. Host access uses a separate edge network because Docker Desktop cannot publish a port from an internal-only network. Every published port remains bound to loopback.

## Fastest trustworthy start

From Ubuntu 24.04 WSL, run:

```bash
cd /mnt/c/Users/ajha/Repos/DevOps-SRE-Learning-Path/drafts/LES-0088-production-service-reliability-capstone/support/project
bash verify.sh
```

That verifier compiles the code, runs seven tests, starts four real listener modes, checks API and telemetry behavior, creates and verifies a live SQLite backup, restores it to a separate target, evaluates healthy and delayed SLO samples, validates structured logs and proves temporary-state cleanup. It refuses root and sends no external request.

## Run the dependency-free baseline

```bash
export PYTHONPATH=service
export ATLAS_DB_PATH="$PWD/var/atlas.db"
python3 -m atlas_service
```

In a second terminal:

```bash
curl --fail --show-error http://127.0.0.1:8080/livez
curl --fail --show-error http://127.0.0.1:8080/readyz
curl --fail --show-error \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: manual-example-0001' \
  --data '{"name":"first item"}' \
  http://127.0.0.1:8080/api/v1/items
curl --fail --show-error http://127.0.0.1:8080/metrics
```

`/livez` asks whether the process can serve. `/readyz` asks whether the expected schema can be read from durable state. A readiness failure must not be hidden by a successful liveness check.

## Run the app container

```bash
docker build --check .
docker compose config --quiet
docker compose up -d app
curl --fail http://127.0.0.1:18080/readyz
docker compose down --volumes
```

The test volume is deliberately removed in the final command. Do not use `--volumes` against an unrelated Compose project.

## Run TLS and Prometheus

```bash
bash ops/generate-certs.sh
docker compose --profile full up -d
curl --cacert certs/localhost.crt https://127.0.0.1:18443/readyz
curl http://127.0.0.1:19090/-/ready
docker compose --profile full down --volumes
bash ops/cleanup.sh
```

The proxy returns 404 for `/metrics`. Prometheus reaches metrics on the internal network. The certificate is self-signed, valid for seven days, local only and removed by allowlisted cleanup.

## Fault modes

Set `ATLAS_FAULT_MODE` before starting a process:

- `readiness-failure`: liveness remains 200 while readiness returns 503.
- `write-failure`: writes return a bounded 503 without leaking database details.
- `latency`: API paths wait `ATLAS_FAULT_DELAY_MS`, bounded to 0..2000 ms.

These are deterministic learning controls, not a claim that every production failure has been modeled.

## Evidence boundary

Passing project checks proves only the committed fixture behavior in the recorded environment. It does not prove Internet safety, production scale, multi-node durability, organization-specific change approval, on-call performance, learner mastery or employment readiness. Preserve those gaps in every portfolio or interview explanation.
