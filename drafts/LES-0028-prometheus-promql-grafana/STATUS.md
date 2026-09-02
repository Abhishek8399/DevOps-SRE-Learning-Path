# LES-0028 historical authoring status

The chapter and support records have moved to canonical book paths under `DEC-093` and `DEC-095`. This retained file records the earlier authoring evidence and remaining gates; publication is not learner evidence or a mastery claim.

## Current state

- The lesson has exactly 18 required teaching sections, five diagrams, eleven command cards, two lab contracts, and four incident paths.
- Three assessment records are present: two complete-answer checks and one reviewer-only, answer-isolated independent transfer. Its published rehearsal is explicitly excluded from independent evidence, and the lesson, assessment, and response-template rubrics agree at 100 points.
- Fourteen new official-source reference records cover Prometheus and Grafana. The lesson also reuses canonical metric-type reference `REF-0167`; its reciprocal lesson backlink remains a promotion-time canonical edit.
- A bounded, no-network, normal-user teaching model covers seven deterministic cases: counter resets, vector matching, classic histogram arithmetic, cardinality multiplication, alert states, dashboard contracts, and one incident path.
- The model is explicitly not Prometheus, PromQL, Alertmanager, Grafana, a performance benchmark, provider acceptance, or production evidence.
- A quarantined real-runtime scaffold now pins Prometheus 3.13.2 distroless, Alertmanager 0.33.1, Grafana 13.1.1 Ubuntu, and Python 3.12.13 slim to exact Linux/amd64 manifests. Its four containers have no host ports, use one internal network, read-only roots, dropped capabilities, `no-new-privileges`, bounded tmpfs and finite resource ceilings.
- The scaffold includes a synthetic metrics endpoint, exact Prometheus scrape/rule configuration, a notification-free Alertmanager route, and provisioned Grafana data source/dashboard. It has passed only Python/JSON parsing and `docker compose config`; no product binary has accepted or executed it.
- A guarded `runtime.sh`/Python controller and six-operation-lock unit tests now bind source hashes, enforce normal-user/offline boundaries, validate exact image/network/container envelopes, exercise only internal APIs, and remove only recorded IDs. The controller source parses and ShellCheck passes; Linux unit/static/runtime execution remains pending.
- Canonical registration remains 21 structured lessons, 63 assessments, and 172 references. This draft adds no route and changes no learner evidence.

## Evidence recorded on 2026-08-04

| Gate | Result | Exact boundary |
|---|---|---|
| Direct draft schemas, duplicate keys, relationships, answer isolation, and rubric parity | `PASS` | One lesson, three assessments, fourteen new references, eighteen headings; draft-only scope |
| Deterministic Python model | `PASS` | Seven cases and eleven assertions; Python model only |
| ShellCheck | `PASS` | Version 0.11.0 against `lab.sh` and `verify.sh` |
| Git Bash syntax | `PASS` | `bash -n` against both shell files; syntax only |
| Ubuntu 24.04 normal-user lifecycle | `BLOCKED` | WSL failed before Ubuntu started with `Wsl/Service/CreateInstance/CreateVm/HCS/0x80070569`; no lifecycle or cleanup pass is claimed |
| Prometheus/Grafana runtime | `NOT RUN` | Exact manifests and initial configuration are present, but no pinned product binary has validated or executed them |

## Evidence recorded on 2026-08-10

| Gate | Result | Exact boundary |
|---|---|---|
| Official release and registry identity review | `PASS` | Prometheus 3.13.2, Alertmanager 0.33.1, Grafana 13.1.1 and exact Linux/amd64 manifest digests recorded; this is provenance metadata, not a vulnerability or runtime pass |
| Runtime scaffold and controller source checks | `PASS` | Three Python files parse, JSON/YAML parse, six controller unit-test definitions are present, ShellCheck passes both runtime scripts, and Docker Compose renders; product configuration schemas and live behavior remain untested |
| Ubuntu/Docker execution | `BLOCKED` | `Wsl/Service/E_ACCESSDENIED` prevents Ubuntu startup and the Docker Linux-engine named pipe is absent |

The verifier now attempts cleanup after any failure, removes only the two exact adversarial entries it created, refuses an ambiguous state-root symlink, and reports cleanup failure instead of swallowing it. This hardening is statically checked but remains unproved on Ubuntu until WSL starts successfully.

## Promotion boundary

The following post-publication evidence gates remain open:

1. Complete license review and prove that every exact pinned artifact is locally available offline.
2. Run the guarded controller, validate configuration with the pinned binaries, and test the real stack's scrape, PromQL, recording-rule, alert-rule, Alertmanager and Grafana provisioning behavior; keep deterministic-model evidence separate.
3. Run the complete normal-user Ubuntu lifecycle, root refusal, interrupted setup, replacement/race, adversarial refusal, cleanup, and final-absence matrix.
4. Resolve the canonical `REF-0167` backlink, move every record to its canonical owner, regenerate registries, and prove relationship validation.
5. Run content, schema, reader, lint, typecheck, build, route, asset, 404, privacy, secret, residue, and source-hygiene gates on the exact promoted tree.
