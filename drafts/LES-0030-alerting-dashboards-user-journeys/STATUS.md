# LES-0030 historical authoring status

The chapter and support records have moved to canonical book paths under `DEC-093` and `DEC-095`. This retained file records the earlier authoring evidence and remaining gates; publication is not learner evidence or a mastery claim.

## Current state

- The lesson has exactly 18 required teaching sections, six diagrams, twelve command cards, two lab contracts, and four incident paths.
- Three assessment records are present: two answered checks and one reviewer-only, answer-isolated independent transfer. Its visible rehearsal is explicitly excluded from independent evidence, and the lesson, assessment, and blank response-template rubrics agree at 100 points.
- Fifteen official or primary-source references cover Google SRE monitoring and SLO guidance, Prometheus rule and Alertmanager behavior, Grafana alert state and dashboard guidance, and black-box probing.
- A bounded, no-network, normal-user teaching model covers eight deterministic cases: alert quality, alert state transitions, multiwindow burn rates, missing evidence, routing reduction, flapping, dashboard truth, and one guided incident.
- The model is explicitly not Prometheus, Alertmanager, Grafana, a synthetic provider, a notification service, a performance benchmark, HA evidence, or production evidence.
- Canonical registration remains 21 structured lessons, 63 assessments, and 172 references. This draft adds no route and changes no learner evidence.

## Evidence recorded on 2026-08-04

| Gate | Result | Exact boundary |
|---|---|---|
| Direct draft schemas, duplicate keys, relationships, answer isolation, and rubric parity | `PASS` | One lesson, three assessments, fifteen references, eighteen headings; draft-only scope |
| Deterministic Python model | `PASS` | Eight cases and twenty-two assertions; Python model only |
| Scenario contract | `PASS` | Checked-in `alert-lifecycle-reasoning-v1` fixture only |
| ShellCheck | `PASS` | Version 0.11.0 against `lab.sh` and `verify.sh` |
| Git Bash syntax | `PASS` | `bash -n` against both shell files; syntax only |
| Git Bash lifecycle | `NOT RUN` | Its `python3` resolves to the Windows Store placeholder; no lifecycle or cleanup pass is claimed |
| Canonical repository regression | `PASS` | 21 lessons, 63 assessments, 172 references; draft remains excluded |
| Content schema tests | `PASS` | 38 passed; one Windows symlink capability case skipped with `EPERM` |
| Reader tests | `PASS` | 21 passed against the unchanged canonical reader corpus |
| Lint and typecheck | `PASS` | Existing website plus unchanged canonical content |
| Production build | `PASS` | Existing canonical routes; this draft has no route |
| Identity, private-path, secret-pattern, conflict-marker, mojibake, reparse-point, whitespace, and diff hygiene | `PASS` | Draft tree and tracked-diff boundary checked |
| Ubuntu 24.04 normal-user lifecycle | `BLOCKED` | WSL failed before Ubuntu started with `Wsl/Service/CreateInstance/CreateVm/HCS/0x80070569`; no lifecycle or cleanup pass is claimed |
| Representative alerting and dashboard runtime | `NOT RUN` | No immutable Prometheus, Alertmanager, Grafana, receiver, probe, or HA stack is present |

## Promotion boundary

The following post-publication evidence gates remain open:

1. Review and lock exact Prometheus, Alertmanager, Grafana, probe and receiver artifacts, provenance, licenses, configuration, resource ceilings, storage boundaries, identities, secrets, ports, networks, and offline availability.
2. Add representative versioned local behavior for rule evaluation, state timing, missing series, no data, query error, grouping, deduplication, inhibition, silences, routing, delivery, acknowledgement, dashboards, recovery, HA limitations, and failure modes; keep deterministic-model evidence separate.
3. Run the complete normal-user Ubuntu lifecycle, root refusal, interrupted setup, replacement/race, adversarial refusal, cleanup, and final-absence matrix.
4. Move every record to its canonical owner, regenerate registries, and prove all reciprocal relationships without changing learner evidence.
5. Run content, schema, reader, lint, typecheck, build, route, asset, 404, privacy, secret, residue, and source-hygiene gates on the exact promoted tree.
6. Complete technical, SRE, security, accessibility, instructional, and independent-review acceptance.
