# Atlas capstone runbook

## First 60 seconds

1. Name the affected user operation: read items, create item, or all requests.
2. Record the first user-visible status and request ID. Do not restart yet.
3. Check `/livez` and `/readyz` separately.
4. Confirm the version at `/version` and the actual container/image identity.
5. Use metrics to quantify rate, errors and latency; use the correlated JSON log to explain one request.
6. Preserve the database, WAL and process state before any recovery that could destroy evidence.

## Service is alive but not ready

Signal: `/livez` is 200 and `/readyz` is 503.

```bash
curl -i http://127.0.0.1:18080/livez
curl -i http://127.0.0.1:18080/readyz
docker compose ps
docker compose logs --no-color --tail 100 app
docker inspect "$(docker compose ps -q app)" \
  --format 'image={{.Image}} health={{.State.Health.Status}}'
```

Interpretation: the process can answer but the declared SQLite schema is unavailable, wrong, locked beyond its timeout, or deliberately faulted. Do not route writes merely because liveness passes. Check mount ownership, free blocks and inodes, database path, schema metadata and storage errors. In this fixture, a recovery candidate must make readiness pass and preserve item conservation.

## User-visible 5xx rate

Signal: `AtlasAvailabilityBudgetBurnFast` or a rising 5xx ratio.

```promql
sum(rate(atlas_http_requests_total{status_class=~"5.."}[5m]))
/
clamp_min(sum(rate(atlas_http_requests_total[5m])), 0.001)
```

Separate storage failures from proxy errors. A 503 with `storage_unavailable` is application-owned. A proxy-generated 502/504 will appear in proxy access/error logs and may not increment application response counters. Compare request IDs and the last known healthy version before choosing rollback.

## Latency objective at risk

Signal: local p95 exceeds 250 ms for five minutes.

1. Verify the user route and traffic volume; do not average unlike operations.
2. Compare proxy duration, application duration and SQLite lock/wait evidence.
3. Check whether the deterministic `latency` fault is active.
4. Check saturation—threads, file descriptors, CPU, memory, I/O and queueing—before tuning.
5. Roll back a correlated release or remove a bounded fault; do not “fix” latency by weakening durability silently.

## Backup and restore

The backup command uses SQLite's online backup API. The manifest records hash, bytes, item count and time. Restore always targets a new path and never overwrites a live database.

```bash
python3 ops/db_admin.py backup \
  --database "$PWD/var/atlas.db" \
  --output "$PWD/backups/atlas-001.db" \
  --boundary "$PWD"
python3 ops/db_admin.py verify \
  --database "$PWD/backups/atlas-001.db" \
  --manifest "$PWD/backups/atlas-001.db.manifest.json"
python3 ops/db_admin.py restore \
  --database "$PWD/backups/atlas-001.db" \
  --manifest "$PWD/backups/atlas-001.db.manifest.json" \
  --target "$PWD/var/restored-atlas.db" \
  --boundary "$PWD"
```

After restore, start a separate process against the restored path, check readiness, compare item counts and sample important reads. Only a separately authorized cutover may replace an active database. A successful backup command without a restore drill is incomplete recovery evidence.

## Rollback decision

Rollback is appropriate when a recent version correlates with user harm, the previous artifact and schema remain compatible, and rollback risk is lower than forward repair. Stop when evidence contradicts any of those assumptions. Record:

- current and target image digests;
- schema versions and data compatibility;
- user SLI before and after;
- exact command authority;
- abort condition;
- preserved logs and backup;
- verification and observation window.

## Escalation packet

Send the smallest packet that lets another engineer act: impact, start time, affected operation, current status, request/example ID, version/change, evidence links, actions attempted, current hypothesis with confidence, explicit unknowns, next decision time and needed authority. Never paste credentials, private data or raw database contents.
