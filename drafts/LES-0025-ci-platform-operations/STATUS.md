# LES-0025 staging status

Last checked: 2026-08-02

Publication state: **draft quarantine — not canonical, not routed, not registered**.

## Candidate identity

- Lesson: `LES-0025`
- Public alias: `V03-L10`
- Curriculum: `CI-002`
- Intended route: `/book/engineering/ci-platform-operations`
- Intended order: Volume 03, lesson 10

The candidate currently contains one 18-section lesson, three assessments (`ASM-0058`–`ASM-0060`), one independent-response template, eight references (`REF-0153`–`REF-0160`), and one bounded dual-engine lab. These records deliberately remain outside the canonical generated registry.

## Evidence recorded for this draft

- Direct lesson, assessment, and reference schema checks: zero issues.
- Lesson shape: 25,551 whitespace-delimited words and exactly 18 required H2 sections.
- Independent transfer: no model-answer fields.
- Full Ubuntu 24.04 lab verifier: pass.
- Root refusal: exit 77.
- Final lab state: absent, zero orphan roots.
- Cooperative replacement tests: regular file, root, state, rollback root, and rollback state.
- Local engines: graph-based and stage-based teaching executors.
- Observed boundaries: no network target, hosted-CI call, cloud call, provider credential, port, service, Docker dependency, or package installation.
- Static checks: Python AST, pipeline JSON, Bash syntax, privacy/name, secret-shape, conflict-marker, trailing-whitespace, and executable network/cloud-tool scans pass.
- ShellCheck is not installed in the checked environment, so no ShellCheck pass is claimed.
- A separate read-only adversarial re-audit found no blocker in the corrected cleanup boundary, record-existence wording, or declarative-contract claims.

## Important proof boundaries

The local engines execute build, artifact handoff, and test behavior. Permission, concurrency, and timeout values are compared as encoded declarations; the lab does not behaviorally enforce or prove those provider controls.

Cleanup detects and preserves one cooperative replacement at the tested quarantine boundary. It does not claim atomic deletion or protection from indefinitely racing malicious code under the same UID.

Nothing here proves GitHub Actions, GitLab CI/CD, Jenkins, or Azure Pipelines behavior. It also does not prove production readiness, formal chapter acceptance, learner execution, independent learner transfer, delayed recall, or mastery.

## Work remaining before canonical publication

1. Run ShellCheck in an environment where it is installed and disposition every finding.
2. Complete a final technical and instructional review of the entire lesson, not only the three corrected findings.
3. Move the lesson, assessments, references, lab, and response template to their canonical `book/` paths in one reviewed change.
4. Update canonical lab links and ensure no draft-relative path survives publication.
5. Regenerate the content registries; never edit generated imports or ID allowlists by hand.
6. Run content, registry, schema, reader, lint, typecheck, production build, recursive HTTP route/asset/404, privacy, secret, residue, and source-hygiene gates against the exact staged tree.
7. Keep hosted-provider execution, browser QA, formal review, learner evidence, and mastery limitations explicit after publication.

The next agent should begin here, inspect the actual files, and rerun evidence rather than trusting this status note alone.
