# Draft staging area

This directory preserves substantial work that is not yet a published Reliability Atlas lesson.

Nothing below `drafts/` is canonical book content, a live website route, an accepted chapter, learner evidence, or a mastery claim. The production reader and generated registry must load only validated records under `book/`.

## Current staged work

- `LES-0026-observability-foundations/` is the quarantined publication candidate for `V04-L01` / `OBS-001` at `/book/reliability/observability-foundations`.
- It is being built before release engineering because progressive-delivery decisions require trustworthy signals and explicit telemetry-failure reasoning.
- Any local signal pipeline remains a bounded teaching implementation; it cannot establish OpenTelemetry, Prometheus, Grafana, Splunk, Elastic, Datadog, Dynatrace, or production-provider behavior.

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
