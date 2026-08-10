# LES-0027 publication-candidate status

This directory remains quarantined authoring work. It is not canonical book content, a live website route, accepted learner evidence, or proof of mastery.

## Current state

- Identity: `LES-0027` / `V04-L02` / `OBS-002`
- Manuscript: substantive exact-18-section lesson with six diagrams, twelve command cards, two labs, four incident paths, three assessments, and fourteen reference links
- Direct contracts on 2026-08-10: lesson issues `0`; assessment issues `0`; reference issues `0`; three assessment records; twelve new reference records
- Dependencies: Python 3.12.13 slim-bookworm and Collector Contrib 0.157.0 are digest pinned; fourteen Python wheels are version and hash pinned; normal setup prohibits pulls and package-index access
- Runtime topology: five non-root, read-only, capability-dropped, resource-bounded containers on one Docker-internal network with no published host ports
- Evidence contract: source creation, SDK export, agent receive/process/export, gateway receive/process/export, debug-sink visibility, reset identities, bounded gateway evidence, queue/retry/drain, context break/recovery, deterministic sampling, and exact resource receipts
- Prior runtime evidence: the pre-lock-hardening controller completed the bounded Ubuntu 24.04 lifecycle on 2026-08-07, including three-span per-hop reconciliation, context break/recovery, a twelve-span gateway outage with queue drain and zero refusal/drop, deterministic 100% versus 25% sampling, evidence audit, and exact cleanup
- Current hardening: operation serialization now uses a kernel-held nonblocking file lock plus owner, mode, link-count, inode, and lifecycle-token checks. A live owner is refused; a matching sentinel from an abruptly terminated owner can be reclaimed only after the kernel lock is released; a foreign token fails closed
- Current source checks: Python AST parses six implementation/test files; Windows ShellCheck passes `verify.sh` and `lab.sh`; `git diff --check` passes
- Current draft contracts: direct lesson, assessment, and reference schemas report zero issues; exact 3/12 ownership and relationship checks pass; `ASM-0066` contains every reviewer-only field and no model-answer field
- Current canonical regression: content and registry validation, 38 runnable schema tests with one documented Windows capability skip, 21 reader tests, lint, typecheck, and production build pass against the unchanged 21/63/172 live corpus

## Resolved independent-audit blockers

1. Immutable image and transitive wheel locks are complete and digest bound.
2. Verification has explicit zero-mutation `static` and full offline `runtime` modes.
3. Per-hop counters, units, freshness, process-reset boundaries, refusal, retry, and drop evidence are implemented.
4. The gateway interruption measures queue occupancy, a controller-observed residence lower bound, retry records, drain, and exact twelve-span reconciliation.
5. Cleanup acquires the operation lock before state rename; the lock follows the atomically renamed path and remains held through exact runtime removal, local-artifact removal, and final state deletion.
6. Setup stages a complete state document and removes unpublished staging/root state after an injected write failure.
7. Collector validation requires successful attach, exited state, timestamps, exit zero, exact removal, and a specific not-found result.
8. Rendered and live checks enforce user, memory, CPU, PIDs, tmpfs, restart, read-only root, capabilities, security options, mounts, zero ports, and exact internal-network membership.
9. The async worker is supervised and health visible; direct downstream parentage and provider flush/shutdown are explicit.
10. Evidence records are bounded, sanitized, digest protected, source/config/resource/network/action/window bound, and sampling trace-ID equality is required.

## Open promotion gates

1. Rerun all fourteen Linux tests and `bash verify.sh static` after the operation-lock change.
2. Rerun `bash verify.sh runtime` from absence and retain its final zero-resource proof. This is currently blocked before Ubuntu startup by `Wsl/Service/E_ACCESSDENIED`; the Docker client is present but the Linux-engine named pipe is absent.
3. After the current runtime passes, add `LES-0027` backlinks to canonical `REF-0166` and `REF-0170`; move the lesson, three assessments, independent response template, twelve references, and lab into canonical roots; regenerate registries.
4. Run repository content, registry, schema, reader, lint, type, build, route, asset, link, 404, privacy, secret, residue, browser, accessibility, and responsive checks.
5. Complete instructional/editorial review, update persistent project trackers, commit, push to `origin/main`, and prove exact remote parity.

## Decision

**GO for continued quarantined engineering. NO-GO for canonical promotion until the current source-bound full runtime and repository promotion gates pass.**

The external WSL failure does not invalidate earlier evidence, but earlier evidence cannot verify the changed controller source. No backend ingest, production behavior, provider interoperability, security posture, performance capacity, learner competency, delayed recall, hiring outcome, or mastery is inferred.
