# Architecture and state ownership

## User and evidence path

```text
loopback client
  |
  | HTTPS :18443, local CA trust, request ID
  v
NGINX proxy --------------------> stdout access evidence
  |
  | HTTP :8080, deadline and forwarded context
  v
Atlas process ------------------> JSON event log
  |     | \
  |     |  \--------------------> /metrics (internal scrape only)
  |     |
  |     +-----------------------> in-memory bounded counters/histograms
  |
  +-----------------------------> SQLite transaction + WAL on named volume
                                      |
                                      +--> online snapshot + manifest
                                                |
                                                +--> staged integrity-checked restore

Prometheus --internal scrape--> Atlas /metrics
    |
    +--> recording rules --> symptom/SLO alerts --> runbook link
```

Reading the diagram left to right answers “where did this request go?” Reading it top to bottom answers “who owns each state?” The proxy owns TLS termination and hop timeouts. The app owns HTTP validation, request correlation, idempotency and response semantics. SQLite owns transactions and persisted items. Prometheus owns sampled time-series state, not application truth. Backup files own point-in-time recovery evidence only after their manifest and integrity checks pass.

## Trust and failure boundaries

| Boundary | Accepted input | Owned state | Failure signal | Does not prove |
|---|---|---|---|---|
| Edge | loopback TLS request | short-lived connection | handshake or proxy status | public PKI or Internet safety |
| Application | bounded JSON and headers | process metrics and request context | 4xx/5xx, log, duration | multi-process consistency |
| SQLite | parameterized transaction | items, keys, schema, WAL | readiness, storage counter | network-database behavior |
| Prometheus | internal text exposition | 24-hour local series | `up`, rule state | paging delivery |
| Recovery | verified snapshot and manifest | separate restore target | hash, integrity, count | production RPO/RTO |

## Why two Docker networks

`backend` is internal and carries only application-to-Prometheus traffic. `edge` permits Docker Desktop to publish explicitly loopback-bound operator ports. The app joins both because it is the proxy upstream and scrape target; Prometheus joins both because it scrapes internally and exposes a local UI. No port binds to `0.0.0.0` on the host.

## Deliberate limitations

- One process and one SQLite writer model; no distributed consensus or failover.
- Standard-library training server; not hardened for untrusted production use.
- Self-signed short-lived TLS; no automated external PKI, revocation or rotation controller.
- In-memory app metrics reset on restart; Prometheus retains only a bounded local window.
- No notification receiver; alert rules are evaluated but no page is sent.
- No cloud, Kubernetes, IaC apply, secrets manager or production identity.
