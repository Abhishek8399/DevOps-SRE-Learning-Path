# LES-0029 draft status

This directory is a quarantined authoring package for `LES-0029` / `V04-L04` / `OBS-004`.
Nothing here is canonical book content, a live website route, learner evidence, or a mastery claim.

## Current state

- The lesson has exactly 18 required teaching sections, five diagrams, twelve command cards, two lab contracts, and four incident paths.
- Three assessment records are present: two answered checks and one reviewer-only, answer-isolated independent transfer. Its visible rehearsal is explicitly excluded from independent evidence, and the lesson, assessment, and blank response-template rubrics agree at 100 points.
- Fifteen new official or primary-source reference records cover OpenTelemetry, Elastic, Splunk, systemd, Python logging and JSON, OWASP logging security guidance, and RFC 5424.
- A bounded, no-network, normal-user teaching model covers eight deterministic cases: baseline records, multiline framing, parser drift, backpressure, duplicate delivery, sensitive-field redaction, clock skew, and one guided incident.
- The model is explicitly not journald, syslog, an OpenTelemetry SDK or Collector, Elastic, Splunk, a performance benchmark, provider acceptance, or production evidence.
- Canonical registration remains 21 structured lessons, 63 assessments, and 172 references. This draft adds no route and changes no learner evidence.

## Evidence recorded on 2026-08-04

| Gate | Result | Exact boundary |
|---|---|---|
| Direct draft schemas, duplicate keys, relationships, answer isolation, and rubric parity | `PASS` | One lesson, three assessments, fifteen references, eighteen headings; draft-only scope |
| Deterministic Python model | `PASS` | Eight cases and twenty-two assertions; Python model only |
| Scenario contract | `PASS` | Checked-in `structured-logging-reasoning-v1` fixture only |
| ShellCheck | `PASS` | Version 0.11.0 against `lab.sh` and `verify.sh` |
| Git Bash syntax | `PASS` | `bash -n` against both shell files; syntax only |
| Canonical repository regression | `PASS` | 21 lessons, 63 assessments, 172 references; draft remains excluded |
| Content schema tests | `PASS` | 38 passed; one Windows symlink capability case skipped with `EPERM` |
| Reader tests | `PASS` | 21 passed against the unchanged canonical reader corpus |
| Lint and typecheck | `PASS` | Existing website plus unchanged canonical content |
| Production build | `PASS` | Existing canonical routes; this draft has no route |
| Identity, private-path, secret-pattern, conflict-marker, mojibake, reparse-point, and diff hygiene | `PASS` | Draft tree and tracked-diff boundary checked |
| Ubuntu 24.04 normal-user lifecycle | `BLOCKED` | WSL failed before Ubuntu started with `Wsl/Service/CreateInstance/CreateVm/HCS/0x80070569`; no lifecycle or cleanup pass is claimed |
| Representative logging runtime | `NOT RUN` | No immutable journald/syslog/Collector/backend stack or configuration is present |

## Promotion boundary

Promotion remains `NO-GO` until all of the following are complete:

1. Review and lock exact logging runtime artifacts, provenance, licenses, configuration, resource ceilings, storage boundaries, and offline availability.
2. Add representative versioned local behavior for the selected source, collector, buffering, parsing, routing, indexing, querying, retention, security, and failure modes; keep deterministic-model evidence separate.
3. Run the complete normal-user Ubuntu lifecycle, root refusal, interrupted setup, replacement/race, adversarial refusal, cleanup, and final-absence matrix.
4. Move every record to its canonical owner, regenerate registries, and prove all reciprocal relationships without changing learner evidence.
5. Run content, schema, reader, lint, typecheck, build, route, asset, 404, privacy, secret, residue, and source-hygiene gates on the exact promoted tree.
6. Complete technical, security, accessibility, instructional, and independent-review acceptance.
