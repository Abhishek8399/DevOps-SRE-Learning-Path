# LES-0037 historical authoring status

Status: **published as canonical reading content; formal acceptance, learner evidence, and mastery remain separate**

Last reviewed: 2026-08-04

## Scope completed

- LES-0037 / V05-L01 / IAC-001 tool-neutral infrastructure-as-code lesson with one required H1 and the exact 18-section teaching contract.
- Six diagrams connecting configuration, state bindings, remote observations, dependency graphs, plans, governed execution, partial failure, drift and verification.
- Twelve command records with questions, risk, branches, proof, non-proof and cleanup boundaries.
- Two lab contracts and five incident patterns.
- Three assessments: answered diagnostic ASM-0094, answered production design ASM-0095 and answer-isolated reviewer-only transfer ASM-0096.
- Fifteen official or authoritative references, REF-0319 through REF-0333, with review schedules.
- Bounded normal-user Bash/Python model with seven fictional cases: graph, plan, drift, policy, partial execution, convergence and sensitive-state handling.
- Explicit separation of configuration, state and remote reality; plan proposal and authorization; display redaction and stored sensitivity; convergence and user-outcome verification.

## Validation evidence

Passed on 2026-08-04:

- direct schema validation: one lesson, three assessments and fifteen references with no record issue;
- exact assessment and reference backlinks;
- exactly one H1 and 18 H2 teaching sections;
- assessment totals of 50, 100 and 100 points with no rubric item above the schema maximum;
- all nineteen JSON documents parse through the direct validation path;
- Python scenario validation and source execution through Windows Python without provider, backend, credential, network or infrastructure access;
- deterministic expected results: graph order network/database/service with no cycle; one create, update and delete plus one no-op; one out-of-band drift; one public-database policy denial; one success, failure and blocked action during partial execution; a zero-change second model plan; and redacted display with sensitive stored state and no encryption claim;
- approved-host Git Bash read-only syntax checks for lab.sh and verify.sh;
- ShellCheck at warning severity for both scripts;
- fifteen source URLs opened against official HashiCorp, OpenTofu, AWS and NIST sources.

## Failed, blocked, or absent evidence

- The Git Bash runtime preflight resolves `python3` to the disabled Microsoft Store alias, so the full Bash lifecycle did not run there.
- WSL lists Ubuntu-24.04, but VM startup fails with Windows logon-right error `0x80070569`. The declared Ubuntu 24.04 normal-user verifier, root refusal, hostile-state checks and final absence proof therefore did not run.
- Windows Python execution validates only the deterministic teaching model. It is not a substitute for the wrapper's ownership, race, refusal and cleanup lifecycle.
- No Terraform or OpenTofu binary, provider, module download, remote backend, state lock, credential, cloud account, API, real resource, plan or apply was used.
- No formal infrastructure, security, instructional, accessibility or operational acceptance exists.
- No learner has completed the unseen independent transfer, timed defense, delayed recall or supervised production transfer.
- The lesson is not in the structured registry or local website and creates no public route.

## Promotion gate

Do not move this draft into canonical book directories until all of the following are complete:

1. Restore an approved Ubuntu 24.04 normal-user runtime and pass the complete `verify.sh` lifecycle, root refusal, adversarial ownership/refusal cases and final state absence.
2. Run version-pinned Terraform and OpenTofu local-only configurations without credentials, comparing language, graph, plan, test and state behavior while recording product differences.
3. Exercise a protected local or disposable state backend with locking, versioning, concurrent-writer refusal, snapshot and verified restore.
4. Prove import and address-preserving refactor on disposable resources without recreation, then recover from an intentionally interrupted or partial local execution.
5. Review policy, runner trust, supply chain, state/plan sensitivity, separation of duties and break-glass handling with accountable reviewers.
6. Complete browser rendering, navigation, print, theme, keyboard, screen-reader and responsive review after canonical integration.
7. Obtain formal technical, instructional, security, accessibility and operational acceptance.
8. Complete ASM-0096 on a materially different unseen system under answer isolation, qualified review, remediation and delayed reassessment.
9. Re-run canonical content/schema/reader/lint/type/build, link, source-hygiene and fresh-clone gates, then record exact commit, tree, remote parity, rollback and proof limits.

Passing schemas and a deterministic comparison model is necessary but cannot establish provider behavior, infrastructure safety, professional level or mastery.
