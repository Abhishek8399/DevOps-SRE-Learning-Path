# LES-0027 draft status

This directory is a quarantined authoring package. Nothing here is canonical book content, a live website route, accepted learner evidence, or proof of mastery.

The package targets `LES-0027` / `V04-L02` / `OBS-002`, but those identities remain unpublished until promotion gates pass.

## Current state

- Lesson prose: substantive draft authored; direct lesson-schema and duplicate-key validation reports zero issues after the command/lab contract reconciliation
- Lesson structure: 18 required H2 sections in exact order, 6 diagrams, 12 commands, 2 labs, 4 incidents, 3 assessment links, and 14 reference links. The 2026-08-02 direct check counted 26,001 whitespace-delimited tokens in the complete file and 21,389 in the body; these are size indicators, not quality or mastery measures
- Assessments: ASM-0064 and ASM-0065 full-answer records plus answer-isolated ASM-0066 are present in draft support and were validated separately
- References: the lesson reuses canonical identities REF-0166 and REF-0170 and the draft support directory contains new REF-0173 through REF-0184; all twelve new records were validated separately
- Local support lab: the Ubuntu 24.04 verifier passes Python/shell parsing, seven static contract tests, the deterministic non-runtime model, fail-closed placeholder-lock paths, action-risk-map checks, source-level root guards, and initial/final absence. It created no runtime, performed no download, and did not execute cleanup against a lifecycle
- Runtime boundary: image and package locks intentionally contain placeholders; required artifacts are not prepared; Docker client 29.6.2 and Compose 5.3.1 were available, while the latest daemon probe timed out; no OpenTelemetry SDK, Collector, OTLP runtime, backend, or root-path execution occurred
- Formal technical review: first independent source audit completed for the quarantined candidate; high-severity runtime-safety findings remain open
- Instructional review: not started
- Learner execution and transfer: not started
- Canonical publication: not started

## Independent audit decision

**GO for a quarantined draft checkpoint. NO-GO for canonical promotion, runtime claims, or learner execution.**

The independent audit confirms that the lesson structure, assessment schemas, answer isolation, reference schemas, static lab contracts, fail-closed model, source-level root guards, source hygiene, and final absence pass. It also confirms that the checked-in runtime paths have untested safety defects and incomplete evidence contracts. The lesson and README now describe those limits directly rather than presenting future measurements as current behavior.

## Blocking work before promotion

1. Replace every `RECORD_REAL_*` marker with a resolver-derived, reviewed immutable dependency set. Current official research points to Python 3.12.13 slim-bookworm, Collector Contrib 0.157.0, OpenTelemetry Python 1.44.0, and Python semantic-convention package 0.65b0, but full transitive wheel hashes, signatures/provenance, exact compatibility, and the final reviewed lock are not complete.
2. Split verification into explicit incomplete-lock/static and runtime-ready modes. The current verifier deliberately requires placeholder locks and absent prepared artifacts, so it cannot validate a future completed cache and active lifecycle.
3. Implement real per-hop evidence for `CMD-007` through `CMD-009`: source creation, SDK export, agent receive/process/export, gateway receive/process/export, sink visibility, units, timestamps, resets, freshness, refusal, queue, retry, and drop deltas. The current audit correctly exits 78.
4. Implement the queue experiment needed by `CMD-011`. Four bounded HTTP outcomes and later current-window identifier visibility do not measure queue occupancy, age, retry attempts, refusals, drops, drain, or per-hop reconciliation; SDK batching is an alternative explanation.
5. Make cleanup atomically acquire the same operation lock before renaming state or touching Docker. The current check-then-rename sequence can race an active operation.
6. Stage a complete state document and atomically publish it, or safely roll back before Docker creation. An early setup write failure can currently leave a directory that `status` and `cleanup` cannot parse.
7. Strengthen Collector-config validation: require a successful container start/attach, an observed exited state and timestamps, exit code zero, exact removal, and a specific not-found result rather than treating generic inspect failure as absence.
8. Enforce the advertised runtime safety contract in both rendered-Compose and live-container checks, including non-root user, CPU/memory/PID/tmpfs bounds, restart policy, exact read-only/capability settings, and membership in only the internal telemetry network.
9. Supervise the sole async worker or expose worker death in health, verify the direct worker-to-service-B parent relationship, and add explicit provider flush/shutdown behavior before service recreation is used as evidence.
10. Make evidence durably auditable: preserve a sanitized bounded gateway evidence artifact rather than only a substring-search hash/count, revalidate every action/window/resource/network/config binding on load, and require deterministic trace-ID equality in the sampling comparison.
11. At promotion, add LES-0027 backlinks to reused canonical REF-0166 and REF-0170, move support into canonical roots, regenerate registries, and run the complete repository relationship, runtime, reader, build, route, browser, hygiene, commit, push, and parity gates.

The doctor/configuration interface, bounded in-process async carrier, current-operation bindings, gateway log windows, and head-sampling gateway-retention receipts now exist and the prose has been narrowed to them. None of the remaining blockers may be converted into a runtime or mastery claim by wording alone.

## Proof boundary

Draft metadata, prose, commands, diagrams, assessment prompts, references, and local fixtures are design artifacts. The verifier establishes only its checked-in static contracts, deterministic model, fail-closed placeholder behavior, source-level safety checks, and initial/final absence. It did not execute a cleanup lifecycle or root path. It does not establish OpenTelemetry SDK, OTLP, Collector, backend, provider, production, security, performance, interoperability, learner competency, delayed recall, or mastery claims. Exact immutable locks, corrected runtime safety controls, real configuration validation, and the normal-user offline runtime lifecycle remain blocked and must pass before this package can be considered for promotion.

## Promotion gate

Promotion requires direct lesson validation; exact structural counts; validated assessment and reference records; pinned and reviewed support artifacts; normal-user Ubuntu execution; root refusal where applicable; deterministic cleanup; content, schema, reader, lint, typecheck, build, route, asset, 404, privacy, secret, and residue checks; independent review; a focused commit; push; and exact remote parity.
