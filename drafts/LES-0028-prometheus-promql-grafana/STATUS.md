# LES-0028 draft status

This directory is a quarantined authoring package for `LES-0028` / `V04-L03` / `OBS-003`.
Nothing here is canonical book content, a live website route, learner evidence, or a mastery claim.

## Current state

- The lesson has exactly 18 required teaching sections, five diagrams, eleven command cards, two lab contracts, and four incident paths.
- Three assessment records are present: two complete-answer checks and one reviewer-only, answer-isolated independent transfer. Its published rehearsal is explicitly excluded from independent evidence, and the lesson, assessment, and response-template rubrics agree at 100 points.
- Fourteen new official-source reference records cover Prometheus and Grafana. The lesson also reuses canonical metric-type reference `REF-0167`; its reciprocal lesson backlink remains a promotion-time canonical edit.
- A bounded, no-network, normal-user teaching model covers seven deterministic cases: counter resets, vector matching, classic histogram arithmetic, cardinality multiplication, alert states, dashboard contracts, and one incident path.
- The model is explicitly not Prometheus, PromQL, Alertmanager, Grafana, a performance benchmark, provider acceptance, or production evidence.
- Canonical registration remains 21 structured lessons, 63 assessments, and 172 references. This draft adds no route and changes no learner evidence.

## Evidence recorded on 2026-08-04

| Gate | Result | Exact boundary |
|---|---|---|
| Direct draft schemas, duplicate keys, relationships, answer isolation, and rubric parity | `PASS` | One lesson, three assessments, fourteen new references, eighteen headings; draft-only scope |
| Deterministic Python model | `PASS` | Seven cases and eleven assertions; Python model only |
| ShellCheck | `PASS` | Version 0.11.0 against `lab.sh` and `verify.sh` |
| Git Bash syntax | `PASS` | `bash -n` against both shell files; syntax only |
| Ubuntu 24.04 normal-user lifecycle | `BLOCKED` | WSL failed before Ubuntu started with `Wsl/Service/CreateInstance/CreateVm/HCS/0x80070569`; no lifecycle or cleanup pass is claimed |
| Prometheus/Grafana runtime | `NOT RUN` | No immutable runtime artifacts or configuration are present |

The verifier now attempts cleanup after any failure, removes only the two exact adversarial entries it created, refuses an ambiguous state-root symlink, and reports cleanup failure instead of swallowing it. This hardening is statically checked but remains unproved on Ubuntu until WSL starts successfully.

## Promotion boundary

Promotion remains `NO-GO` until all of the following are complete:

1. Review and lock exact Prometheus, Alertmanager, and Grafana artifacts, provenance, licenses, configuration, resource ceilings, and offline availability.
2. Add a real versioned local stack with tested scrape, PromQL, recording-rule, alert-rule, and Grafana provisioning behavior; keep deterministic-model evidence separate.
3. Run the complete normal-user Ubuntu lifecycle, root refusal, interrupted setup, replacement/race, adversarial refusal, cleanup, and final-absence matrix.
4. Resolve the canonical `REF-0167` backlink, move every record to its canonical owner, regenerate registries, and prove relationship validation.
5. Run content, schema, reader, lint, typecheck, build, route, asset, 404, privacy, secret, residue, and source-hygiene gates on the exact promoted tree.
