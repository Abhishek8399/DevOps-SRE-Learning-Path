# LES-0026 staging status

Last checked: 2026-08-02

Publication state: **draft quarantine — not canonical, not routed, not registered**.

## Candidate identity

- Lesson: `LES-0026`
- Public alias: `V04-L01`
- Curriculum: `OBS-001`
- Intended route: `/book/reliability/observability-foundations`
- Intended order: Volume 04, lesson 1
- Intended assessments: `ASM-0061` through `ASM-0063`
- Intended references: `REF-0164` through `REF-0172`

This lesson deliberately comes before release engineering. `REL-001` requires trustworthy observability signals for canary, rollback, and migration decisions; teaching deployment gates first would encourage decisions from incomplete evidence.

## Draft contract

The publication candidate must contain exactly the canonical 18 H2 sections, definitions before commands, mechanism-first diagrams, twelve bounded Ubuntu command cards with decoded output, a guarded local lab, incidents, complete answer guides, an answer-isolated transfer, and nine primary or official references.

The local lab may model signal production, correlation, collection, loss, cardinality, sampling, retention, and privacy. It must not claim to be OpenTelemetry, Prometheus, Grafana, Splunk, Elastic, Datadog, Dynatrace, or another vendor implementation unless that exact product is actually executed and reviewed.

## Proof boundaries

Draft content, schema validity, mentor-operated lab output, and website rendering are project evidence only. They do not prove production telemetry quality, vendor behavior, formal chapter acceptance, learner execution, independent transfer, delayed recall, or mastery.

Telemetry is evidence with failure modes, not truth by definition. Every claim must distinguish what a signal establishes from what missing, delayed, sampled, aggregated, redacted, or mis-correlated data cannot establish.

## Completed staging evidence

- The candidate contains the exact 18-section lesson contract, six diagrams, twelve command cards, two labs, four incidents, three assessments, and nine versioned official or primary references.
- Direct lesson, assessment, reference, duplicate-key, relationship, backlink, rubric, and command-parity checks report zero issues. The assessment totals are `50/50`, `50/50`, and `100/100`.
- All twelve command cards ran byte-for-byte in Ubuntu 24.04 and returned the documented branches.
- The bounded lab passes Bash syntax, ShellCheck 0.9, Python AST/config checks, explicit root refusal (`77`), two private-regression fault tests, all thirteen restartable cleanup boundaries, and final absence checks (`state=absent`, `state_recovery_count=0`, `orphan_count=0`, `/tmp` residue `0`).
- The full verifier also passes when started with an inherited cleanup-fault setting; it clears that ambient setting before baseline work while retaining its own explicit fault tests.
- Independent lesson and lab re-audits found no remaining blocker after corrections to answer isolation, evidence wording, cardinality arithmetic, histogram and percentile semantics, procfs sourcing, privacy, trace topology, clock ordering, cleanup safety, and failure residue detection.
- Current canonical-corpus gates remain green while this draft is quarantined: content validation, registry check, content-schema tests (`38` pass, `1` environment skip), reader tests (`21` pass), lint, type-check, and production build.

These are maintainer and project checks. They do not establish learner execution, unfamiliar transfer, delayed recall, production-provider behavior, formal acceptance, or mastery.

## Work remaining before canonical publication

1. Move the reviewed artifacts to canonical `book/` roots in one rename-aware change and remove every draft-relative path.
2. Regenerate the content registry and update reader contracts, corpus counts, the content matrix, master plan, progress records, and verification ledger.
3. Rerun schema, content, reader, lint, type, build, HTTP, offline, privacy, and source-hygiene gates against the promoted tree.
4. Complete route-level browser QA and record the exact canonical commit and remote parity evidence.
5. Keep formal chapter acceptance, learner-operated evidence, representative real-system transfer, delayed recall, and mastery limitations explicit after publication.

The next agent must inspect and rerun actual evidence instead of trusting this status note.
