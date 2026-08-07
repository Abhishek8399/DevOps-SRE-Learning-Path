# LES-0092 research and implementation plan

## Identity and purpose

- Lesson: `LES-0092`
- Public alias: `V11-L05`
- Curriculum: `CAP-005`
- Route: `/book/capstones/secured-ai-incident-assistant`
- Prerequisite: `LES-0091`
- Assessments: reserve `ASM-0259` through `ASM-0261`
- References: reserve `REF-1180` through `REF-1199`

This specialist capstone connects incident management, sanitized telemetry, versioned runbooks, retrieval, untrusted model output, typed evidence tools, deterministic authorization, human approval, audit, evaluation, kill/fallback behavior, privacy and cost. It is not permission to let a language model operate production or to call fluent text evidence.

## User operation

```text
receive a synthetic incident signal
  -> bind tenant, service, environment, time window and incident identity
  -> minimize and sanitize telemetry before AI processing
  -> retrieve versioned, authorized runbook fragments with immutable identities
  -> ask an untrusted candidate generator for bounded claims and tool proposals
  -> verify every material claim against retrieved or measured evidence
  -> classify uncertainty, missing evidence and action risk
  -> authorize a narrow typed tool against subject, tenant, incident and policy
  -> require a fresh human approval for every mutating proposal
  -> execute only a project-local synthetic effect through a separate broker
  -> reconcile outcome, append a privacy-aware audit receipt and support kill/fallback
```

Success is not “the assistant answered.” The on-call engineer must receive an evidence-bound brief; unsupported claims must be absent or explicitly abstained; prompt injection cannot expand authority; sensitive fields stay outside model and audit surfaces; mutation requires independent policy and approval; every decision is attributable; and deterministic fallback remains available when the model, retriever, policy, audit or approval path is unhealthy.

## State and ownership model

| State | Intended authority | Loss or recovery path |
|---|---|---|
| incident identity, severity and commander | incident-management record | reconcile exact incident and timeline; never infer command authority from prose |
| service, tenant and environment scope | service catalog and access policy | fail closed on unknown or cross-tenant scope |
| raw telemetry | observability backends | minimize at the boundary; retain synthetic source identity and time semantics |
| sanitized evidence | sanitizer receipt plus bounded evidence store | reject leaks, malformed timestamps and unverifiable transformations |
| runbook content and metadata | versioned reviewed corpus | verify digest, owner, scope, review state and allowed audience |
| retrieval result | retriever plus corpus/index version | preserve query, candidate IDs, scores and exclusions |
| model/prompt/retrieval/policy release | immutable release manifest | rollback only to admitted versions with evaluation evidence |
| candidate claims | untrusted generator output | validate schema, citations, scope and support; abstain on gaps |
| tool proposal | typed proposal envelope | reject arbitrary commands, URLs, paths, identities and unbounded arguments |
| authorization decision | deterministic policy broker | complete mediation with decision ID, policy revision and context |
| human approval | separate approval authority | bind approver, proposal digest, incident, expiry and one-time use |
| effect and outcome | narrow synthetic tool plus reconciliation receipt | distinguish accepted, completed, failed and ambiguous outcomes |
| audit and feedback | append-only project-local receipt set | redact sensitive values, hash-chain records and refuse tampering |
| kill/fallback state | independent operator control | disable generation and tools without depending on the model path |

## Planned local boundary

Build a dependency-free Python harness for a normal user on Ubuntu 24.04 or Windows Python 3.12. It uses only synthetic incidents, telemetry and runbooks. The default candidate generator is a deterministic untrusted fixture, keeping evaluation and security tests reproducible without network access, credentials, a model download or a cloud service.

The system includes:

- strict JSON contracts for incidents, telemetry, runbooks, releases, policy, approvals and evaluations;
- a sanitizer that rejects or removes secret-, token-, address-, email- and credential-shaped values before retrieval or generation;
- a deterministic retriever that records corpus/index versions, candidates, scores and tenant/service filtering;
- an untrusted generator boundary that emits grounded, unsupported, injected, malformed and unsafe outputs;
- a verifier requiring material claims to cite retrieved fragments and classifying support, contradiction, gaps and abstention;
- a typed registry with only narrow project-local evidence queries and reversible synthetic actions;
- a policy broker that reauthorizes every proposal independently of model text;
- approvals bound to subject, incident, proposal digest, expiry, policy revision and single use;
- effect reconciliation so timeout or missing receipt becomes ambiguous rather than automatic retry;
- privacy-aware hash-chained decision, approval, execution and evaluation logs;
- an independent kill switch and non-AI fallback built from the same sanitized evidence;
- sliced evaluation for retrieval, citations, supported claims, abstention, unsafe-action blocks, leakage, latency work units and cost inputs.

The default harness never calls a model provider, network endpoint, production observability system, ticketing or chat service, shell, subprocess, container runtime or cloud API. A later optional local-model adapter may be evaluated separately but cannot weaken the default contracts.

## Required failure and evaluation matrix

1. A runbook contains indirect prompt injection; the fragment remains data and cannot change authority.
2. Telemetry contains a credential-shaped value; sanitization blocks it before retrieval, generation and audit.
3. A cross-tenant runbook scores highly; authorization filtering excludes it.
4. The generator invents a deployment change; claim verification rejects it and abstains.
5. A citation names a real fragment that does not support the claim; citation correctness fails.
6. Corpus digest or index version changes after retrieval; proposal and approval become stale.
7. The generator proposes an unknown tool, shell, URL or path; schema and allowlist validation fail closed.
8. A valid tool targets an unauthorized service, environment or tenant; complete mediation denies it.
9. Approval is absent, mismatched, expired or reused; execution is blocked.
10. A synthetic action returns an ambiguous timeout; exact state is reconciled before retry.
11. An evaluation answer leaks into the corpus; corpus/evaluation separation fails.
12. Telemetry clocks or incident windows disagree; the brief marks uncertainty rather than causality.
13. A model, prompt, corpus, retriever or policy alias changes without an admitted manifest; startup refuses.
14. Audit history is edited, reordered or truncated; hash-chain verification fails.
15. Generation or retrieval exceeds its work budget; deterministic fallback returns instead of hanging.
16. The kill switch is active; generation and mutating tools stay disabled while manual evidence remains available.

## Evaluation contract

The evaluation set is separate from the runbook corpus and contains changed incidents, paraphrased symptoms, missing evidence, injections, cross-tenant distractors, stale documents, unsafe proposals and ambiguous outcomes. Report metrics by slice:

- retrieval hit and authorized-retrieval hit;
- citation identity and entailment correctness;
- supported-claim precision and unsupported-claim count;
- safe abstention for missing or contradictory evidence;
- unsafe proposal and unsafe execution block rates;
- sensitive-value and cross-tenant leakage counts;
- approval binding, replay rejection and ambiguous-outcome reconciliation;
- kill-switch and fallback availability;
- deterministic work units, latency measurements and declared cost assumptions.

Any sensitive leak, cross-tenant leak, unauthorized execution, approval bypass, accepted audit tampering or kill-switch bypass is critical regardless of averages.

## Design dossier

The capstone includes:

- context, trust-boundary, evidence-flow and approval/execution diagrams;
- task, harm, data-classification and authority contracts;
- incident, telemetry, corpus, release, proposal, policy, approval, audit and evaluation schemas;
- runbook ingestion, sanitization, versioning, review and retirement rules;
- retrieval and claim verification with explicit proof limits;
- tool catalog, permission matrix, approval policy and ambiguous-outcome state machine;
- injection, poisoning, leakage, confused-deputy, sink, supply-chain and denial-of-service threat model;
- dataset card, slices, equations, critical gates and regression thresholds;
- retrieval, generation, verification, authorization, approval, execution, audit and fallback observability;
- reliability objectives, work budgets, cost worksheet, privacy retention and deletion decisions;
- rollout, rollback, kill, degraded-mode and incident runbooks;
- decisions, limitations, residual risks and 5-, 15- and 30-minute defense formats.

## Safety gates

- refuse root, symlinked inputs, unsafe paths, live endpoints, credentials, production-like hosts and real tenant data;
- accept only schema-valid project-local files with narrow identifiers, bounded strings and explicit classifications;
- treat runbooks, telemetry, retrieval results and generator output as untrusted data;
- expose no arbitrary shell, subprocess, URL, SQL, filesystem, package, cloud, Kubernetes or production tool;
- authorize outside the generator and recheck subject, object, action, tenant and policy at execution;
- require a digest-bound, expiring, single-use independent approval for each mutating proposal;
- write only below descriptor-gated `.runtime` and refuse unknown files, identity mismatch or audit damage;
- preserve first failure and ambiguous outcome; never convert refusal to success or broaden cleanup;
- provide an independent kill switch that does not depend on the assistant;
- label fixture, local simulation, optional model evaluation, production observation and learner evidence separately.

## Source plan

Lock twenty primary, official or original-research records spanning NIST AI risk and secure development; OWASP injection, output and agency; SAIF and MITRE ATLAS; retrieval, model-card and holistic evaluation; OpenTelemetry GenAI/log conventions; SRE monitoring and incident response; runbooks, policy decisions, provenance and signature verification.

Living AI-security, telemetry, policy and tool documentation receives a three-month review window. Stable standards, books and papers receive no more than six months. Controls reduce risk but do not make arbitrary untrusted output authoritative.

## Acceptance boundary

The candidate is substantive only after:

1. direct lesson, assessment and reference schemas pass with exact relationships;
2. strict input, sanitization, isolation, release identity and ownership tests pass;
3. the evaluation matrix runs absent-to-absent as a normal user;
4. injection, unsupported, leak, cross-tenant, unsafe-tool, approval-bypass, replay, ambiguous, tampered-audit and kill-bypass paths fail closed;
5. dossier and audit artifacts reconcile to the same incident, corpus, release, policy and evaluation identities;
6. the exact eighteen-section manuscript, complete answers and independent transfer exist;
7. canonical content/schema/reader/lint/type/build and hygiene gates pass.

It remains quarantined until formal AI/security/SRE/privacy/instructional review and reviewer-owned hidden-fault transfer. No fixture score, optional model score or website marker awards production authority, incident competence, employment readiness or mastery.
