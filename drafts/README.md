# Draft staging area

This directory preserves substantial work that is not yet a published Reliability Atlas lesson.

Nothing below `drafts/` is canonical book content, a live website route, an accepted chapter, learner evidence, or a mastery claim. The production reader and generated registry must load only validated records under `book/`.

## Current staged work

- No substantive lesson publication candidate is currently staged here.
- `LES-0025` was promoted to canonical `book/` locations as the `substantive-draft` lesson `V03-L10` / `CI-002` at `/book/engineering/ci-platform-operations`, with its assessments, references, and bounded lab colocated under their canonical roots.
- Its local engines remain teaching implementations. They demonstrate graph-versus-stage semantics, artifact transfer, minimal job environments, contract comparison, and a green-but-unsafe port; they do not prove vendor-platform behavior, provider acceptance, learner completion, or mastery.

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
