# Draft staging area

This directory preserves substantial work that is not yet a published Reliability Atlas lesson.

Nothing below `drafts/` is canonical book content, a live website route, an accepted chapter, learner evidence, or a mastery claim. The production reader and generated registry must load only validated records under `book/`.

## Current staged work

- `LES-0029` / `V04-L04` / `OBS-004` is a quarantined structured-logging and pipeline candidate at `LES-0029-structured-logging-pipelines/`. Its 18-section lesson, three assessments, fifteen official or primary-source references, and bounded eight-case teaching model pass direct schema, relationship, answer-isolation, rubric-parity, model-assertion, ShellCheck, Git Bash syntax, canonical-regression, build, and hygiene checks.
- `LES-0029` is **not** ready for canonical publication. WSL Ubuntu 24.04 fails before startup with `0x80070569`; no normal-user lifecycle pass exists, and no reviewed journald/syslog/OpenTelemetry Collector/Elastic/Splunk runtime has run. The deterministic model is not a logging product or production substitute.
- The visible LES-0029 transfer is an unscored rehearsal. Only a materially different unseen disposable case may be submitted for the answer-isolated `ASM-0072` independent transfer.
- `LES-0028` / `V04-L03` / `OBS-003` is a quarantined Prometheus, PromQL, and Grafana candidate at `LES-0028-prometheus-promql-grafana/`. Its 18-section lesson, three assessments, fourteen new official-source references, one reused canonical reference, and bounded seven-case teaching model pass direct schema, relationship, answer-isolation, rubric-parity, arithmetic, ShellCheck, and Git Bash syntax checks.
- `LES-0028` is **not** ready for canonical publication. WSL Ubuntu 24.04 currently fails before startup with `0x80070569`; no normal-user lifecycle pass exists, and no immutable Prometheus, Alertmanager, or Grafana stack has run. The deterministic model is not a PromQL engine or provider-runtime substitute.
- The visible LES-0028 transfer is an unscored rehearsal. Only a materially different unseen disposable case may be submitted for the answer-isolated `ASM-0069` independent transfer.
- `LES-0027` / `V04-L02` / `OBS-002` is the current quarantined candidate at `LES-0027-opentelemetry-instrumentation-pipelines/`. Its 18-section lesson, three assessments, twelve new official-reference records, two reused canonical reference identities, and bounded local lab design pass direct schema and static-contract validation.
- `LES-0027` is **not** ready for canonical publication. Its immutable artifact locks remain incomplete, no OpenTelemetry SDK or Collector runtime has executed, and the exact command/evidence gaps are preserved in its `STATUS.md` rather than being converted into claims.
- `LES-0026` was promoted to canonical `book/` locations as the `substantive-draft` lesson `V04-L01` / `OBS-001` at `/book/reliability/observability-foundations`, with its assessments, references, and bounded lab colocated under their canonical roots.
- Its local telemetry pipeline remains a teaching implementation. It cannot establish OpenTelemetry, Prometheus, Grafana, Splunk, Elastic, Datadog, Dynatrace, or production-provider behavior, learner competency, formal acceptance, or mastery.

## Promotion gate

Move a draft into `book/` only after all of the following are true:

1. Stable lesson, route, alias, volume, order, curriculum, assessment, and reference identities are conflict-free.
2. The lesson passes direct schema validation with every required section substantive and every command classified.
3. Complete-answer assessments pass rubric validation, while the independent transfer remains answer-isolated.
4. Every reference has a primary canonical URL, review window, relevance statement, and supported claim scope.
5. Every lab passes static checks, normal-user lifecycle tests, explicit root refusal, adversarial ownership/refusal cases, deterministic cleanup, and final-absence proof in its declared environment.
6. Claims match evidence: local models remain labelled as models, and missing hosted-provider, production, learner, formal-review, and delayed-recall evidence stays explicit.
7. The draft is moved to its canonical lesson, assessment, reference, and lab paths; generated registries are rebuilt rather than edited by hand.
8. Content, registry, schema, reader, lint, typecheck, production build, route, asset, 404, privacy, secret, residue, and source-hygiene gates pass on the exact staged tree.
9. A separate review finds no technical, instructional, safety, accessibility, or mastery-integrity blocker.
10. The checkpoint is committed and pushed without bundling unrelated work.

Draft preservation is useful progress. It is deliberately weaker than publication.
