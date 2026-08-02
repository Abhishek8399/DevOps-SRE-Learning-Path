---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0024",
  "aliases": ["V03-L09", "ci-cd-architecture"],
  "curriculumIds": ["CI-001"],
  "slug": "ci-cd-architecture",
  "route": "/book/engineering/ci-cd-architecture",
  "order": 9,
  "volume": "03-engineering-delivery",
  "title": "CI/CD architecture: turn source changes into verified releases",
  "summary": "Trace one release from a validated event and exact source plus pipeline revisions through controller scheduling, a dependency-aware job graph, runner trust and workspace boundaries, cache restore, build and test, immutable Open Container Initiative (OCI) artifact identity, policy and digest-bound approval, short-lived workload authorization, progressive deployment, state reconciliation, and user verification. Learn to contain concurrency, retry, cancellation, partial state, artifact substitution, unsafe migrations, rollback limits, misleading health, and delivery metrics without turning a green pipeline into false proof.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 560,
  "prerequisiteLessonIds": ["LES-0009", "LES-0021", "LES-0022", "LES-0023"],
  "prerequisiteCurriculumIds": ["SCM-001", "AUT-005", "BLD-001", "CTR-001", "CTR-002"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The checked-in lab uses Bash, Python 3 standard library, coreutils, findutils, and flock as a normal user. It makes no network call, opens no port, installs nothing, contacts no hosted CI/CD system, and changes only guarded user identifier (UID)-scoped state below /tmp."},
    {"platform": "Windows Subsystem for Linux (WSL 2) Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "Run from the Ubuntu shell. Linux user identifier (UID), file modes, symlink, flock, Bash, Python, and /tmp behavior are the tested boundary; do not infer native Windows runner or filesystem behavior."},
    {"platform": "GitHub Actions, GitLab CI/CD, Jenkins, Azure Pipelines, containers, Kubernetes, private cloud, and public cloud", "version": "provider-neutral concepts", "support": "concept-only", "notes": "The production sections compare concepts and official contracts. This lesson does not create a hosted pipeline, runner, credential, registry artifact, cluster, environment, cloud resource, or real deployment."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "release-engineer", "build-engineer", "security-engineer", "cloud-infrastructure-engineer"],
  "learningObjectives": [
    "Trace a logical change through event validation, source and pipeline identities, controller scheduling, a dependency-aware job graph, runner and workspace boundaries, cache restore, build, test, packaging, gates, promotion, deployment, reconciliation, and user verification.",
    "Keep source revision, pipeline-definition revision, logical run, attempt, job, runner, workspace, cache entry, artifact digest, approval, environment revision, deployment operation, workload instance, and user operation as separate identities.",
    "Explain state ownership across the CI controller, runner, cache, artifact repository, policy engine, identity provider, deployment controller, runtime, durable data store, and observability system.",
    "Design job dependencies, fan-out, fan-in, concurrency groups, cancellation, deadlines, retries, idempotency, and unknown-outcome reconciliation without duplicate or partially promoted releases.",
    "Distinguish a dependency cache from a release artifact and enforce build-once promotion of one content digest through every environment.",
    "Use short-lived workload identity, OpenID Connect claims, least privilege, protected pipeline code, trust-pool separation, secret boundaries, and approvals bound to immutable release intent.",
    "Choose rolling, canary, blue-green, feature-flag, rollback, roll-forward, and compensation strategies from compatibility, state, capacity, blast radius, and verification evidence.",
    "Treat database and message-contract evolution as durable-state compatibility work that application rollback alone may not reverse.",
    "Build evidence that joins logical changes and attempts to queue, runner, cache, artifact, gate, environment, deployment, runtime, and user outcomes.",
    "Diagnose contaminated workspaces, incomplete cache keys, artifact substitution, approval drift, duplicate deployment, unsafe migration, shallow health, and misleading delivery metrics.",
    "Operate the bounded offline lab without root, network, hosted CI, real secrets, broad cleanup, or false claims about production behavior."
  ],
  "productionSignals": [
    "A green pipeline deploys bytes whose digest differs from the artifact that passed tests.",
    "A clean checkout fails while a persistent runner passes because undeclared generated files remain in the workspace.",
    "A cache hit rate rises while test flakiness and artifact drift also rise because the key omits lockfile, toolchain, platform, or policy inputs.",
    "Pull-request code and protected deployment jobs share runners, writable caches, network reachability, or credentials.",
    "A deployment application programming interface (API) times out after accepting work; a blind retry creates a second release or repeats an irreversible side effect.",
    "Two runs for the same branch race, cancel each other incompletely, or promote out of order.",
    "Approval names a branch, tag, run number, or environment but not the immutable artifact and release-intent digest.",
    "A rolling deployment is probe-green while user transactions fail, queues age, or versions disagree on a database or message schema.",
    "Application rollback succeeds but data remains incompatible because a destructive migration already committed.",
    "Runner queue age, gate wait, retry amplification, artifact retention, and deployment rework grow while the dashboard reports only job duration.",
    "Delivery metrics count attempts as deployments or declare recovery when CI turns green rather than when user service is restored.",
    "Logs or artifacts expose tokens, event payloads, signed URLs, environment details, or high-cardinality identifiers."
  ],
  "diagrams": [
    {
      "id": "LES-0024-DIA-001",
      "title": "One release crosses control, execution, and runtime planes",
      "direction": "left-to-right",
      "boundaries": ["event ingress", "source and pipeline definition", "CI controller and job graph", "runner trust pool and workspace", "cache and artifact services", "policy and approval", "deployment controller", "runtime and durable state", "telemetry and user operation"],
      "evidencePoints": ["event type and trust", "full revisions", "logical run and attempt IDs", "runner image and workspace identity", "cache key and artifact digest", "policy result and immutable approval binding", "deployment operation and desired revision", "observed digest schema and workload state", "user result and reliability window"],
      "textAlternative": "A validated event selects exact source and pipeline revisions. The CI controller schedules a dependency graph onto isolated runners. Jobs may restore validated cache data but publish one immutable artifact. Policy and approval bind that digest to an environment. A deployment controller reconciles runtime state, and telemetry plus a real user operation verifies the promised release."
    },
    {
      "id": "LES-0024-DIA-002",
      "title": "A job graph separates dependencies from execution attempts",
      "direction": "hierarchical",
      "boundaries": ["logical change", "pipeline run", "job graph", "job attempts", "runner workspaces", "fan-in gate", "release record"],
      "evidencePoints": ["change ID", "run ID and pipeline revision", "needs edges and conditions", "attempt number exit cancellation", "runner and workspace IDs", "required results and skipped states", "artifact and environment receipt"],
      "textAlternative": "One logical change creates a pipeline run containing a directed acyclic graph. Each job node can have several attempts on different runners and workspaces. A fan-in gate evaluates the required node outcomes before one release record may advance."
    },
    {
      "id": "LES-0024-DIA-003",
      "title": "Identity and authorization narrow from workflow to environment",
      "direction": "top-to-bottom",
      "boundaries": ["reviewed pipeline code", "runner workload", "OIDC issuer", "short-lived assertion", "external trust policy", "scoped deployment credential", "environment authorization", "audit receipt"],
      "evidencePoints": ["pipeline revision", "repository workflow ref event", "issuer key and token time", "subject audience claims", "claim match and policy version", "actions resources expiry", "artifact environment approval", "principal decision and operation ID"],
      "textAlternative": "Reviewed pipeline code runs in an identified workload. An identity provider issues a short-lived assertion with issuer, subject, audience, time, and workflow claims. An external trust policy validates those claims and grants only the deployment actions and resources needed for one environment, producing an audit receipt."
    },
    {
      "id": "LES-0024-DIA-004",
      "title": "Build once and promote the same digest",
      "direction": "left-to-right",
      "boundaries": ["closed build inputs", "isolated builder", "tests and scans", "immutable artifact repository", "digest-bound approval", "environment promotion", "runtime readback"],
      "evidencePoints": ["source lock pipeline builder identities", "workspace and toolchain", "artifact subject digest", "non-overwritable storage receipt", "policy evidence environment expiry", "same digest in release intent", "served digest configuration and user check"],
      "textAlternative": "Closed inputs enter one isolated builder. Tests and supply-chain evidence refer to the produced digest. The artifact repository stores that object immutably. Approval and each environment promotion name the same digest, which runtime readback and a user check confirm."
    },
    {
      "id": "LES-0024-DIA-005",
      "title": "Progressive deployment is a feedback state machine",
      "direction": "cyclic",
      "boundaries": ["candidate accepted", "small cohort", "startup and readiness", "user and dependency guardrails", "promote hold or abort", "reconcile accepted work", "next cohort or recovery"],
      "evidencePoints": ["operation ID", "cohort size and digest", "controller and probe state", "error latency saturation queue and business outcome", "policy decision and timestamp", "in-flight work duplicates and durable effects", "stable window or rollback target"],
      "textAlternative": "A candidate with an immutable identity enters a small cohort. The controller checks startup and readiness, while user and dependency guardrails evaluate the actual service. Policy either expands, holds, or aborts. Accepted work and durable effects are reconciled before the next cohort or recovery."
    },
    {
      "id": "LES-0024-DIA-006",
      "title": "Timeout cancellation and retry create a partial-state branch",
      "direction": "cyclic",
      "boundaries": ["persist logical intent", "send attempt", "controller accepts", "caller timeout or cancellation", "unknown outcome", "query by stable operation identity", "committed failed or absent", "verify compensate or bounded retry"],
      "evidencePoints": ["intent digest", "attempt ID and deadline", "server operation ID", "last response and cancel acknowledgement", "unknown ledger age", "authoritative control-plane state", "runtime and durable side effects", "user outcome and duplicate count"],
      "textAlternative": "The caller persists one logical intent and sends an attempt. If the controller accepts it but the caller times out or cancels, the outcome is unknown. The caller queries the state owner using the stable operation identity, then verifies, compensates, or retries only after absence is proved."
    }
  ],
  "commands": [
    {
      "id": "LES-0024-CMD-001",
      "question": "Which repository and exact source revision am I observing?",
      "risk": "read-only",
      "command": "git rev-parse --show-toplevel && git rev-parse --verify HEAD",
      "runFrom": "A reviewed local Git worktree; never assume the current directory is the intended repository",
      "expectedBranches": [
        {"when": "An absolute root and a full object ID print", "meaning": "Git resolved the current worktree and HEAD identity.", "nextEvidence": "Record pipeline-definition and submodule or generated-source identities separately."},
        {"when": "Git reports not a repository or an ambiguous revision", "meaning": "The source boundary is not established.", "nextEvidence": "Stop and locate the intended checked-out repository without cloning or fetching implicitly."}
      ],
      "proves": "The local Git root and HEAD object selected by this worktree at that instant.",
      "doesNotProve": "A clean workspace, reviewed pipeline definition, remote branch state, signature trust, built bytes, or deployment."
    },
    {
      "id": "LES-0024-CMD-002",
      "question": "Does the workspace contain tracked or untracked state outside the commit?",
      "risk": "read-only",
      "command": "git status --short --untracked-files=all",
      "runFrom": "The exact local worktree or a runner workspace after its identity is established",
      "expectedBranches": [
        {"when": "No rows print", "meaning": "Git reports no tracked modification or visible untracked path under this configuration.", "nextEvidence": "Inspect ignored and generated inputs plus runner cleanup policy before calling the workspace clean."},
        {"when": "Rows print", "meaning": "The workspace contains changes or untracked paths outside HEAD.", "nextEvidence": "Preserve the listing and determine whether any build step consumed them."}
      ],
      "proves": "Git porcelain status for visible paths in this worktree at one instant.",
      "doesNotProve": "Absence of ignored files, external mounts, background processes, credential residue, or undeclared cache inputs."
    },
    {
      "id": "LES-0024-CMD-003",
      "question": "Would tracked content under this path differ from HEAD?",
      "risk": "read-only",
      "command": "git diff HEAD --exit-code -- .",
      "runFrom": "The exact reviewed worktree",
      "expectedBranches": [
        {"when": "Exit 0 and no diff", "meaning": "No staged or unstaged tracked-content difference from HEAD was reported for this path scope.", "nextEvidence": "Check untracked, ignored, generated, submodule, and external state separately."},
        {"when": "Exit 1 with a diff", "meaning": "The resulting tracked content under this path differs from HEAD.", "nextEvidence": "Preserve the patch and distinguish staged from unstaged changes before identifying which job created or consumed them."}
      ],
      "proves": "The combined staged and unstaged tracked-content difference from HEAD under the displayed path scope.",
      "doesNotProve": "A hermetic build context, untracked or ignored-file absence, submodule state, external inputs, or a reviewed source revision."
    },
    {
      "id": "LES-0024-CMD-004",
      "question": "What dependency edges does a small job graph declare?",
      "risk": "read-only",
      "command": "echo 'build needs=-'; echo 'test needs=build'; echo 'package needs=test'; echo 'deploy needs=package'",
      "runFrom": "Any Ubuntu 24.04 shell; this command only prints a synthetic dependency mapping",
      "expectedBranches": [
        {"when": "Four jobs and their needs print", "meaning": "The model exposes dependency edges rather than relying on file order.", "nextEvidence": "Inspect conditions, skipped and cancelled semantics, artifacts, and fan-in rules in the real controller."}
      ],
      "proves": "That the shell printed the displayed synthetic dependency mapping.",
      "doesNotProve": "Acyclicity, real scheduling, job success, artifact transfer, or provider semantics."
    },
    {
      "id": "LES-0024-CMD-005",
      "question": "Can relevant inputs form a deterministic cache-key fingerprint?",
      "risk": "read-only",
      "command": "echo -n 'lock=abc|toolchain=sha256:builder|platform=linux-amd64|job=build|policy=v3' | sha256sum",
      "runFrom": "Any supported lesson shell; values are synthetic and contain no secret",
      "expectedBranches": [
        {"when": "A 64-hex-character cache key prints", "meaning": "The exact ordered tuple produced one deterministic local fingerprint.", "nextEvidence": "Review whether the real tuple covers every compatibility input and who may write the namespace."}
      ],
      "proves": "Local hashing of the displayed tuple.",
      "doesNotProve": "Cache-object integrity, completeness of real inputs, trustworthy writer, or correctness of restored data."
    },
    {
      "id": "LES-0024-CMD-006",
      "question": "What immutable digest identifies one exact artifact byte sequence?",
      "risk": "read-only",
      "command": "echo -n 'release-bytes-v1' | sha256sum; echo 'size_bytes=16'",
      "runFrom": "Any supported lesson shell; the artifact is a synthetic in-memory byte sequence",
      "expectedBranches": [
        {"when": "A digest and size_bytes=16 print", "meaning": "The local model assigned content identity to these exact bytes.", "nextEvidence": "Verify upload receipt, retention, access policy, provenance subject, and consumer readback for a real artifact."}
      ],
      "proves": "SHA-256 and byte length for the exact local value.",
      "doesNotProve": "Artifact safety, authenticity, provenance, availability, functional correctness, or deployment."
    },
    {
      "id": "LES-0024-CMD-007",
      "question": "Did tested approved and candidate identities remain equal?",
      "risk": "read-only",
      "command": "test 'sha256:aaa' = 'sha256:aaa' && echo 'tested_eq_approved=true'; test 'sha256:aaa' = 'sha256:bbb' && echo 'approved_eq_candidate=true' || echo 'approved_eq_candidate=false'",
      "runFrom": "Any supported lesson shell; identities are synthetic",
      "expectedBranches": [
        {"when": "tested_eq_approved=true and approved_eq_candidate=false", "meaning": "The model detects artifact substitution between approval and candidate.", "nextEvidence": "Stop promotion and trace producer, repository, tag resolution, and deployment receipts by immutable digest."}
      ],
      "proves": "Equality relations among three displayed strings.",
      "doesNotProve": "Why they differ, which is authorized, whether either is safe, or what runtime serves."
    },
    {
      "id": "LES-0024-CMD-008",
      "question": "Which workload-identity claims must policy compare?",
      "risk": "read-only",
      "command": "echo 'iss=issuer.example'; echo 'sub=repo:team/service:environment:prod'; echo 'aud=deploy'; echo 'exp=2000000000'",
      "runFrom": "Any supported lesson shell; this is a synthetic decoded claim set and not a real token",
      "expectedBranches": [
        {"when": "Issuer subject audience and expiry print", "meaning": "The model keeps identity dimensions separate for policy evaluation.", "nextEvidence": "Validate signature, key, time, nonce where applicable, exact workflow claims, and external authorization policy."}
      ],
      "proves": "That four synthetic claim-shaped key=value lines were printed by the shell.",
      "doesNotProve": "Token authenticity, current time validity, runner integrity, policy authorization, or access to any environment."
    },
    {
      "id": "LES-0024-CMD-009",
      "question": "Which abstract deployment outcomes permit a retry?",
      "risk": "read-only",
      "command": "echo 'rejected retry=false'; echo 'committed retry=false'; echo 'unknown retry=false'; echo 'proven_absent_transient retry=true'; echo 'conflict retry=false'",
      "runFrom": "Any supported lesson shell; the table is a safety policy model",
      "expectedBranches": [
        {"when": "Only proven_absent_transient is retry=true", "meaning": "The model requires absence proof and transient classification before replay.", "nextEvidence": "Define the real state-owner query, stable idempotency identity, deadline, cap, and retry budget."}
      ],
      "proves": "The displayed abstract policy mapping.",
      "doesNotProve": "The state of a real deployment, absence proof, idempotency support, or provider retry guidance."
    },
    {
      "id": "LES-0024-CMD-010",
      "question": "Did a canary exceed an error-rate abort threshold?",
      "risk": "read-only",
      "command": "errors=7; requests=500; rate_bp=$((10000*errors/requests)); echo errors=$errors; echo requests=$requests; echo error_rate_basis_points=$rate_bp; test $rate_bp -gt 100 && echo abort=true || echo abort=false",
      "runFrom": "Any supported lesson shell; counts are synthetic and the window is intentionally unspecified",
      "expectedBranches": [
        {"when": "error_rate_basis_points=140 and abort=true", "meaning": "The displayed 140 basis points equal 1.40 percent, so this sample exceeds the modeled 1 percent threshold.", "nextEvidence": "Establish window, baseline, error definition, sample sufficiency, cohort identity, and user impact before a real decision."}
      ],
      "proves": "Arithmetic for seven errors among 500 sampled requests against a 1 percent threshold.",
      "doesNotProve": "Statistical significance, causal attribution, safe rollback, full user health, or a production policy decision."
    },
    {
      "id": "LES-0024-CMD-011",
      "question": "Do accepted production deployment events map one-to-one to logical changes, independently of CI attempts?",
      "risk": "read-only",
      "command": "changes=10; ci_attempts=14; accepted_deployments=11; echo logical_changes=$changes; echo ci_attempts=$ci_attempts; echo accepted_production_deployment_events=$accepted_deployments; echo deployment_events_per_logical_change_x100=$((100*accepted_deployments/changes))",
      "runFrom": "Any supported lesson shell; values are synthetic",
      "expectedBranches": [
        {"when": "logical_changes=10, ci_attempts=14, accepted_production_deployment_events=11, and deployment_events_per_logical_change_x100=110 print", "meaning": "The event-to-change correlation is 1.10 and at least one change may map to more than one deployment event; this is not deployment frequency because no time window is present.", "nextEvidence": "Correlate every event under immutable release intent, classify retry versus incident-driven rework, and calculate each DevOps Research and Assessment (DORA) metric with its own event boundary and window."}
      ],
      "proves": "Three distinct synthetic counts and a 110-per-100 event-to-logical-change correlation indicator.",
      "doesNotProve": "Deployment frequency, deployment rework rate, another complete DORA result, comparable teams, causal quality, or user recovery."
    },
    {
      "id": "LES-0024-CMD-012",
      "question": "Is the guarded local CI/CD model ready without installing elevating or contacting a service?",
      "risk": "read-only",
      "command": "bash lab.sh check",
      "runFrom": "book/labs/LES-0024-ci-cd-architecture in a normal-user Ubuntu 24.04 or Ubuntu WSL shell",
      "expectedBranches": [
        {"when": "state=absent or a validated registered state is reported", "meaning": "The controller could classify its exact UID-scoped local state.", "nextEvidence": "Read the lab README and use only the declared lifecycle command appropriate to that state."},
        {"when": "A root missing-command orphan descriptor symlink owner mode workspace model or lock refusal appears", "meaning": "The safety boundary is not satisfied.", "nextEvidence": "Stop; do not install, elevate, edit state, follow a link, or broaden cleanup."}
      ],
      "proves": "Controller preflight and ownership classification for the lesson local state at that instant.",
      "doesNotProve": "A hosted pipeline, real runner isolation, artifact repository, identity provider, deployment, production recovery, learner reasoning, or mastery."
    }
  ],
  "labs": [
    {
      "id": "LES-0024-LAB-001",
      "title": "Guided release path and failed-canary containment",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or Ubuntu 24.04 WSL, normal user, Bash, Python 3, coreutils, findutils, util-linux flock; local offline model only",
      "timeMinutes": 75,
      "privilege": "Normal user only; UID 0 is refused and no sudo, daemon, socket, credential, or external service is used",
      "network": "No network, hosted CI/CD, Git remote, registry, cloud, cluster, or listening port",
      "changes": ["Creates one guarded UID-scoped descriptor and one private random directory below /tmp", "Creates two distinct private identity-bound workspace directories for the same current UID and bounded lifecycle records", "Runs one local standard-library Python model and records a failed-canary recovery"],
      "abortConditions": ["Root or a missing required command is observed", "Any registered path, owner, mode, sentinel, link count, workspace identity, installed-model digest, child allowlist, or lock invariant fails", "Any step requests installation, network, credential, hosted service, manual state edit, wildcard cleanup, or answer inspection during independent work"],
      "recovery": "Use only bash lab.sh recover after preserving the guided observations and writing the recovery card; use cleanup alone if cleanup-in-progress is reported.",
      "cleanupProof": "The controller must report cleanup_proven=true and a final bash lab.sh check must report state=absent.",
      "path": "book/labs/LES-0024-ci-cd-architecture"
    },
    {
      "id": "LES-0024-LAB-002",
      "title": "Independent CI/CD boundary diagnosis and production transfer",
      "mode": "independent",
      "environment": "A clean guarded LES-0024 local lifecycle; learner response stored outside controller-owned state; no fixture verifier or answer inspection",
      "timeMinutes": 120,
      "privilege": "Normal user only; no root sudo daemon external account token service connection or production authority",
      "network": "Offline only; no fetch hosted runner registry identity provider cluster cloud or real deployment",
      "changes": ["Creates only exact lesson-owned local state and records the independent raw scenario", "Requires bash lab.sh acknowledge-predictions with a lowercase SHA-256 receipt for an external prediction document before any independent evidence view", "Runs one prediction-gated cache-key experiment that changes only the declared pipeline-definition key input and records control treatment unchanged inputs proof limit and zero external calls", "Requires prediction and experiment records before one bounded recovery operation verification and exact cleanup"],
      "abortConditions": ["The raw scenario or external prediction document was not captured before acknowledgement", "The acknowledgement value is not lowercase 64-hex SHA-256 or any independent observe is attempted before its receipt record exists", "The cache-key experiment is absent before independent recovery", "The learner proposes blind retry mutable approval broad cleanup untrusted-to-protected runner sharing real secret use or production action", "Any controller ownership or lifecycle refusal appears"],
      "recovery": "After acknowledgement, evidence views, and bash lab.sh experiment cache-key, write the exact authorized actor, immutable identities, preconditions, scope, concurrency owner, aborts, rollback or compensation, and user proof before invoking bash lab.sh recover; independent recovery refuses without prediction and experiment records.",
      "cleanupProof": "A reviewer requires the external prediction document, acknowledgement and experiment evidence, verifier output, cleanup_proven=true, final state=absent, and the independent response from before recovery; controller success does not score reasoning.",
      "path": "book/labs/LES-0024-ci-cd-architecture"
    }
  ],
  "incidents": [
    {
      "id": "LES-0024-INC-001",
      "signal": "A shared persistent runner is green only with a warm incomplete cache; tested OCI image manifest digest A is not the independently rebuilt deployed OCI image manifest digest B, approval names a branch, and the fleet is mixed.",
      "firstThought": "Release identity and execution cleanliness are unknown. Stop promotion, tag movement, blind reruns, and broad cache deletion while preserving runner, workspace, cache, source, pipeline, artifact, approval, and fleet evidence.",
      "safePath": "Compare clean isolated cache-disabled and complete-key builds, trace both digests, assess runner and credential exposure, select one reviewed immutable artifact, bind approval to digest and environment, canary it, reconcile every instance, and verify user operations.",
      "trap": "Clearing everything, rerunning until green, approving a movable name, or rebuilding per environment destroys evidence and preserves the broken identity contracts."
    },
    {
      "id": "LES-0024-INC-002",
      "signal": "Untrusted fork code shares a runner and long-lived production credential; a version and tag are overwritten, deploy timeout replay creates two releases, destructive schema migration commits, shallow health stays green, and payments fail.",
      "firstThought": "Treat this as supply-chain, credential, artifact-integrity, deployment-identity, durable-data, and customer-impact workstreams. Stop unsafe execution, promotion, replay, and traffic expansion while preserving evidence.",
      "safePath": "Isolate affected runners, rotate authority through its owner, reconcile accepted deployment operations, recover data or deploy a schema-compatible immutable artifact, use a small cohort with payment-level gates, and redesign trust pools, identity, artifact, retry, migration, and evidence boundaries.",
      "trap": "A code rollback cannot restore removed data; another retry can create a third release; manual approval and a green shallow probe do not repair compromised execution or prove payment recovery."
    }
  ],
  "assessmentIds": ["ASM-0055", "ASM-0056", "ASM-0057"],
  "referenceIds": ["REF-0145", "REF-0146", "REF-0147", "REF-0148", "REF-0149", "REF-0150", "REF-0151", "REF-0152"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The checked-in lab is a deterministic offline model. It creates no hosted pipeline, runner, cache service, artifact repository, identity token, registry object, environment, deployment, cluster, cloud resource, or production proof.",
    "The lab's two runner directories are distinct private validated workspaces owned by the same current UID. They demonstrate workspace separation, not a security-isolation boundary against another same-UID process or a compromised host.",
    "The independent controller refuses all seven evidence views until it stores a syntactically valid lowercase SHA-256 receipt supplied through bash lab.sh acknowledge-predictions. The receipt proves only that a digest string was acknowledged: the lab stores no external document content and cannot prove its authorship, quality, completeness, creation time, or that hypotheses preceded scenario inspection; those remain learner and reviewer gates.",
    "Independent recovery and verification require the recorded bash lab.sh experiment cache-key result. That experiment proves only the deterministic local model's single declared cache-key-variable comparison and zero modeled external calls, not a real cache, runner, registry, provider, or production causal result.",
    "Synthetic command outputs and policy tables teach boundaries; they are not complete provider implementations, cryptographic verification, statistical release policy, or authorization decisions.",
    "GitHub Actions, GitLab CI/CD, Jenkins, Azure Pipelines, identity providers, artifact stores, deployment controllers, databases, and observability products differ by version and configuration. Verify current official contracts before production action.",
    "A digest proves byte identity under the named algorithm, not safety. OIDC proves no authorization until signature, issuer, audience, subject, time, workflow claims, external trust, and least-privilege policy are validated.",
    "Rollback may not reverse database, message, payment, or other durable side effects. Every recovery needs compatibility, accepted-work reconciliation, user verification, and a separately owned data plan.",
    "Publishing this chapter or passing its local verifier does not award mastery. Reviewed independent evidence, repeated incidents, delayed recall, and production feedback remain required."
  ]
}
---

# CI/CD architecture: turn source changes into verified releases

## What you see and first thought

You open a pipeline page and see a row of green boxes: build, test, scan, package, approve, deploy. It is tempting to read that picture as one sentence: *the code was good and production was updated*. Slow down. The picture summarizes many independent state transitions owned by different systems. A green build job says its declared process exited acceptably in one execution context. It does not say the workspace was clean. A green test says selected tests accepted selected bytes and dependencies. It does not say the deployed bytes were identical. A successful deploy command says a control-plane request returned an accepted result. It does not say every workload converged, durable data remained compatible, or a user completed the promised operation.

Keep this sentence:

> A pipeline is a distributed controller that moves evidence and immutable intent across trust and state boundaries; it is not a colored YAML diagram.

When an incident page says *CI is broken* or *deployment failed*, put your mind on five questions before you click rerun:

1. **What was the user operation?** Was the promised result a review build, an artifact publication, a staging release, or a production payment service update?
2. **Which immutable identities were involved?** Record exact source, pipeline definition, builder, cache entry, artifact digest, approval intent, environment revision, deployment operation, and serving workload.
3. **Which owner last accepted a valid input and failed to produce the promised output?** That may be event validation, scheduling, runner startup, workspace preparation, dependency resolution, build, test, artifact storage, policy, identity, deployment reconciliation, runtime readiness, durable data, or user verification.
4. **What state may already have changed?** A timeout, cancellation, or red job is not proof of no effect. A deployment controller may have accepted work; a migration may have committed; a message may have been published; a cohort may be serving.
5. **What is the smallest observation that separates competing explanations without destroying evidence?** Preserve first. Do not clear all caches, delete workspaces, move a tag, rotate every release, or rerun until green merely to make the interface comfortable.

Here is the first diagnostic split:

| What you see | First thought | Do not conclude yet |
|---|---|---|
| Job queued for 25 minutes | Runner capacity, labels, trust pool, quota, or upstream dependency may be limiting scheduling | The job process is slow; it has not started |
| Job green only on a warm runner | Undeclared workspace or cache state may be part of correctness | Warm execution is the valid baseline |
| Build digest A, deployed digest B | Artifact continuity is broken until equivalence is proved | Same commit means same bytes |
| Approval says **main approved** | Authorization is bound to a movable name, not one release intent | Any later main artifact is approved |
| Deployment request timed out | Outcome is unknown after transmission | Deployment failed and retry is safe |
| New pods ready, users failing | Readiness predicate is narrower than user success | Kubernetes or the pipeline is healthy |
| Rollback complete, old code fails | Durable data or external effects may be incompatible | Rollback reverses time |
| Pipeline green after three retries | Attempts changed the execution context and may have created real deployment events | The first failure is irrelevant |

The operating goal is not to make the pipeline green. The goal is to restore one precisely stated release operation, preserve enough evidence to explain it, and prove the intended user outcome without duplicate or unauthorized effects.

### CI and CD are related but not identical

**Continuous integration (CI)** is the practice and system for integrating changes frequently and producing fast, trustworthy evidence about them. It normally covers source checkout, dependency resolution, build, static analysis, tests, packaging, and publication. CI asks: *Can this exact change become a reviewed artifact under the declared contract?*

**Continuous delivery** keeps a reviewed artifact in a state where an authorized actor can release it safely. Delivery includes artifact retention, policy, approvals, environment configuration, migration planning, promotion, verification, and recovery readiness.

**Continuous deployment** is a policy choice inside continuous delivery: qualifying changes are automatically deployed to production. It does not remove controls. It makes controls executable, observable, fast, and strong enough to operate without a person manually clicking each time.

An organization may have excellent CI and manual production delivery. It may have automated deployment with poor CI. Avoid maturity slogans. Inspect the actual contracts.

### The outcome ladder

Read every pipeline from left to right using this ladder:

~~~text
event accepted
  -> exact source and pipeline definition selected
  -> job graph created
  -> trusted runner acquired
  -> isolated workspace prepared
  -> dependencies resolved or validated from cache
  -> artifact built once
  -> tests and evidence bound to its digest
  -> policy and approval bind digest to environment
  -> deployment operation accepted
  -> controller converges the intended cohort
  -> runtime and durable state remain compatible
  -> representative user operation succeeds
  -> stability window passes
~~~

Every arrow can fail. Every arrow needs an owner, an identity, a durable record, a timeout, and a proof limit. That is the architecture you are about to learn.

## Terms before commands

Technical language is useful only when each word names a boundary. Learn these terms as an operator, not as vocabulary trivia.

### Event, trigger, payload, and trust

An **event** is a recorded occurrence such as a push, pull request, tag, schedule, manual request, or upstream completion. A **trigger** is the rule that decides whether an event should create a pipeline run. The **payload** is event data: repository, revision, actor, ref, title, changed paths, and other fields.

Event data is input, not shell source and not authorization. A pull-request title controlled by an external contributor must not be pasted into a command string and executed. A protected-branch event and a fork event belong to different trust domains even if both use the same YAML file.

### Pipeline, workflow, controller, and run

A **pipeline** or **workflow** is the reviewed program that describes jobs, dependencies, conditions, permissions, inputs, outputs, timeouts, and environment transitions. The names differ by product; the mechanism is similar.

The **controller** is the service that parses the definition, creates a graph, persists state, schedules jobs, collects results, applies conditions, and exposes an **application programming interface (API)** or user interface. A **logical run** is one controller record for one selected event and definition. A **run attempt** is one execution try. Rerunning a failed workflow creates new evidence and may use a different runner, cache, dependency response, credential, branch head, or environment.

### Directed acyclic graph, stage, job, step, and edge

A **directed acyclic graph (DAG)** is a set of nodes connected by one-way dependency edges with no cycle. A **job** is a schedulable node. A **step** is an ordered action inside a job. A **stage** is a presentation or grouping concept; some systems make it an execution boundary and others do not.

An edge such as *test needs build* means test becomes eligible only after the controller evaluates build according to the edge policy. File order is not a dependency. A skipped upstream node, allowed failure, cancelled node, or conditional expression can change whether downstream work is eligible. Read the controller semantics rather than inferring them from the visual layout.

**Fan-out** runs several independent nodes after one input, such as test shards or architecture builds. **Fan-in** waits for several required results before one gate. Parallel work shortens latency but increases runner demand, log volume, shared-service load, and the number of partial states that recovery must understand.

### Queue, scheduler, runner, agent, and executor

A **queue** holds eligible work that has not acquired execution capacity. Queue age is waiting time, not job runtime. A **scheduler** matches job requirements such as operating system, architecture, label, trust pool, capacity, and quota to an executor.

A **runner** or **agent** is the registered execution worker. An **executor** is the mechanism it uses: a process, shell, container, virtual machine, or another isolated environment. Product names vary. The important questions are: who controls its image, what persists, what network and filesystem it can reach, which credentials arrive, and what cleanup occurs before another trust domain runs.

An **ephemeral runner** is created for a narrow unit of work and destroyed afterward. Ephemeral reduces cross-job persistence; it does not prove a trusted base image, safe network, safe bootstrap, or no external side effect.

### Workspace and isolation

A **workspace** is the directory and surrounding execution context used by a job. It may contain checked-out source, generated files, dependency directories, credentials written by tools, test output, sockets, and process state.

**Isolation** means one job cannot read, alter, or inherit another job's unauthorized state according to the threat model. A clean Git status is narrower: ignored files, mounts, processes, caches, or credentials may remain. Verified cleanup is weaker than a newly provisioned trusted environment but stronger than simply reusing a directory and hoping.

On Linux, a **user identifier (UID)** names a numeric user identity and a **group identifier (GID)** names a numeric group identity. Equal UID ownership can let another process running as that user access state despite separate directories; filesystem permissions are not isolation from the same UID or from root.

### Cache, artifact, output, and log

A **cache** is reusable acceleration data. Correctness must survive a miss. Its key claims that the restored object is compatible with the current inputs. A hit proves that an object was found under that key; it does not prove the key is complete, the writer was trusted, or the bytes are correct.

An **artifact** is a declared output that later jobs or environments consume, retain, inspect, or promote. It needs immutable identity, integrity, retention, access policy, producer evidence, and consumer verification. A release image, package, archive, manifest, Software Bill of Materials (SBOM), or provenance document can be an artifact.

A job **output** is structured data passed to another job, usually small values such as an artifact digest or test-result location. A **log** is diagnostic evidence, not a safe transport for secrets or an authoritative state database.

### Reference, tag, version, and digest

A **reference** is a name used to find content. A branch, tag, version label, or image tag can move unless the owner enforces immutability. A **digest** is a content-derived identifier such as SHA-256 over exact bytes or an **Open Container Initiative (OCI)** manifest. Digest equality proves byte identity under that algorithm and serialization. It does not prove safety, authorization, provenance, or useful behavior.

For this lesson, digest A and digest B in the main incidents mean **OCI image manifest digests**. Do not compare an archive digest from one stage with an image-manifest digest from another and call the mismatch proof of substitution; first compare identities for the same artifact type.

### Gate, policy, approval, and promotion

A **gate** blocks advancement until declared evidence meets a rule. A **policy gate** is evaluated by code. An **approval** is an authorization decision by a human or separate system. An approval is meaningful only if it binds the approver and authority to immutable release intent: artifact digest, source and pipeline revisions, target environment, evidence, migration plan, time or expiry, and constraints.

**Promotion** makes an already built immutable artifact eligible in a later environment. Promotion should move a reference or release record to the same digest. **Rebuilding** performs a new transformation and creates new bytes that do not inherit earlier evidence automatically.

### Identity, secret, token, OIDC, authentication, and authorization

An **identity** names an actor. A human identity names a person or service account acting through a reviewed process. A **workload identity** names a job, workflow, repository, environment, or runtime workload.

A **secret** is confidential data whose possession grants capability, such as a password or private key. A **token** is a credential carrying or referencing claims and authority. Long-lived stored tokens increase exposure time and rotation burden.

**OpenID Connect (OIDC)** is an identity layer that can let a workload obtain a signed, short-lived identity assertion instead of storing a deployment secret. Important claims include:

- **issuer**: which identity provider made the assertion;
- **subject**: which workload or workflow identity it names;
- **audience**: which relying service should accept it;
- **issued-at, not-before, and expiry**: the validity window;
- provider-specific repository, ref, workflow, environment, or event claims.

**Authentication** verifies the asserted identity. **Authorization** decides whether that identity may perform a specific action on a specific resource under current policy. A valid token is not automatic authorization. External trust policy must verify signature, issuer, audience, subject, time, and exact claims, then grant least privilege.

**Least privilege** means the actor receives only the actions, resources, environment, and duration required. Separate builder, artifact publisher, promoter, and deployer authority where risk justifies it. A pull-request test job should not inherit production deployment authority merely because both jobs run in the same product.

### Environment, release, deployment, and reconciliation

An **environment** is a named operational boundary with configuration, policy, identity, runtime, data, and users. Development, staging, and production are not just variables. They have different blast radii and authorization.

A **release** is a durable record that binds intended artifact and configuration to an environment and change. A **deployment** is an event or operation attempting to make runtime match that release. A production deployment event counts when a real production transition is accepted under the organization's consistent definition. Non-deploying CI reruns are not deployment-frequency events. If a retry creates a second accepted production deployment, it is a real event and must not be hidden; correlate both events under the same logical change or release intent.

**Desired state** is what the controller has been asked to make true. **Observed state** is what it currently sees. **Reconciliation** is the repeated comparison and action that moves observed state toward desired state. A deployment command returning zero can precede minutes of reconciliation or a later controller failure.

### Startup, readiness, liveness, health, and user verification

**Startup** asks whether initialization has completed. **Readiness** asks whether this instance should receive new work under a narrow predicate. **Liveness** asks whether the process is stuck in a local failure that a restart can safely repair, such as a deadlock or irrecoverably stuck event loop. Liveness must not restart a process merely because a dependency is down; that can amplify an outage.

**Health** is ambiguous unless the exact predicate is named. A process can be alive and ready while a payment journey fails because of authorization, data, queue, or dependency behavior.

**Deployment verification** checks control-plane and runtime facts: intended digest, cohort count, readiness, configuration, migration state, and controller progress. **User verification** executes or observes the real promised operation and reconciles durable effects. Both are required.

### Rolling, canary, blue-green, feature flag, rollback, and roll-forward

A **rolling deployment** replaces a bounded number of instances at a time. It needs old/new compatibility and capacity for temporary overlap.

A **canary** exposes a small, identified cohort to representative work and expands only when guardrails pass. A canary is useful only when metrics are sensitive, correctly attributed, and observed long enough.

**Blue-green** maintains two deployment sets and switches traffic. It can make routing and rollback explicit but requires duplicate capacity and still shares data or external effects unless designed otherwise.

A **feature flag** separates code deployment from behavior activation. It reduces some rollback cost but creates configuration state, stale-flag debt, authorization, and testing combinations.

**Rollback** asks runtime to serve an earlier compatible application artifact or configuration. It does not reverse database changes, published messages, payments, notifications, or other durable effects. **Roll-forward** deploys a corrected compatible artifact. **Compensation** is a new action that semantically counteracts an earlier irreversible effect.

### Concurrency, cancellation, timeout, retry, and idempotency

**Concurrency** means two operations overlap. A **concurrency group** serializes or supersedes operations sharing one state boundary, such as production for one service. The group key must name the real collision domain.

**Cancellation** is a request to stop future work. It is not proof that the runner stopped, child processes died, artifacts were not uploaded, or a deployment controller did nothing. Record cancellation requested, acknowledged, and terminal states separately.

A **timeout** is the caller's deadline. After a request is transmitted, timeout produces an **unknown outcome** until the authoritative owner is queried.

A **retry** is a new attempt. It is safe only when the failure is classified, the operation is idempotent or absence is proved, one layer owns retry, an overall deadline and attempt cap exist, backoff and jitter protect dependencies, and duplicate effects are reconciled.

**Idempotency** means repeated application of the same logical intent has one durable effect. It requires a stable operation identity bound to intent and atomic state-owner handling. Reusing the same commit is not enough if each attempt receives a new deployment identity.

### Service-level indicators, objectives, and the five delivery metrics

A **service-level indicator (SLI)** is a measured property of service behavior, such as the proportion of runnable jobs assigned an eligible runner within five minutes. A **service-level objective (SLO)** is the target for that SLI over a named population and time window.

**DevOps Research and Assessment (DORA)** currently defines five software-delivery performance metrics. Apply them to one application or service with stable event boundaries:

- **Change lead time:** for each production-deployed change, subtract its version-control commit time from its production deployment time; the eligible population is all deployed changes in the window, and a distribution such as the median or 50th percentile (p50) is reported rather than dividing durations by deployments.
- **Deployment frequency:** count accepted production deployment events in the measurement window and divide by window duration, such as deployments per day; alternatively report the distribution of time between successive accepted production deployment events.
- **Failed deployment recovery time:** for every deployment that fails and requires immediate intervention, subtract the failure start from verified service recovery; report the duration distribution across those failed deployments in the window.
- **Change fail rate:** divide accepted production deployments that require immediate intervention, rollback, or hotfix by all accepted production deployments in the same application and window.
- **Deployment rework rate:** divide unplanned production deployments caused by a production incident by all accepted production deployments for that application in the same window.

Document how one deployment event is accepted, how a change maps to one or more events, how duplicate telemetry is deduplicated, and how retries that cause real deployments remain counted. Deployments per logical change has no time denominator and is therefore a correlation or possible rework signal, not deployment frequency.

### Evidence, observation, inference, and proof limit

An **observation** is directly read from a named source. A **documented contract** is what a system promises. A **calculation** derives a value from named inputs and units. An **inference** is the explanation best supported so far. A **hypothesis** is a testable candidate explanation. An **unknown** is missing evidence that matters to a decision.

A **proof limit** says what evidence cannot establish. Good operators state it every time: a cache hit proves reuse under a key, a digest proves content identity, an approval proves a scoped decision, readiness proves a predicate, and a user journey proves one scoped operation at one time.

## Architecture map

### End-to-end release path

~~~text
untrusted or trusted event
          |
          v
event validator ---- protected source + pipeline definition
          |                         |
          +------------+------------+
                       v
              CI controller database
              logical run + job DAG
                       |
           scheduler / queue / quotas
              |                  |
              v                  v
       runner trust pool A  runner trust pool B
       workspace attempt 1  workspace attempt 2
              |                  |
              +-- dependency cache
              +-- build and test evidence
              +-- immutable OCI manifest digest
                       |
              artifact repository
                       |
          policy engine + independent approval
          exact digest + environment + expiry
                       |
             short-lived deploy identity
                       |
              deployment controller
          desired release <-> observed state
                       |
        canary / rolling / blue-green cohorts
                       |
       runtime + database + queues + dependencies
                       |
         telemetry + real user-operation proof
                       |
              promote / hold / recover
~~~

**Text alternative:** an event is validated against its trust boundary and selects protected source plus a pipeline definition. A CI controller persists one logical run and a dependency graph. A scheduler assigns jobs to isolated runner trust pools and workspaces. Jobs may read validated cache data and produce test evidence plus one immutable OCI image manifest digest. An artifact repository stores it. Policy and an independent approval bind that digest to an environment. A short-lived scoped workload identity asks a deployment controller to reconcile progressive cohorts. Runtime, durable data, dependencies, telemetry, and a real user operation determine promotion, hold, or recovery.

The diagram has three planes:

- The **control plane** stores intent and makes decisions: event service, CI controller, scheduler, policy engine, identity provider, deployment controller.
- The **execution plane** runs untrusted or semi-trusted code: runners, workspaces, builders, test processes.
- The **runtime plane** serves work and owns durable effects: workloads, databases, queues, payment systems, and user operations.

Do not collapse their evidence. A controller record is not runner truth. Runner output is not artifact-store truth. Artifact-store truth is not runtime truth. Runtime readiness is not user truth.

### State-owner map

| State | Authoritative owner | Durable identity | Typical dangerous assumption |
|---|---|---|---|
| Event acceptance | Event receiver/controller | event ID, type, delivery ID | Payload is trusted because delivery is authentic |
| Source | Version-control object database | full commit/tree IDs | Branch name identifies fixed source |
| Pipeline program | Version control plus included-template owner | definition revision/digest | Pipeline used the file currently visible in the UI |
| Run graph | CI controller database | logical run ID, DAG revision | Visual order is dependency order |
| Job attempt | CI controller and runner | job ID, attempt ID | Rerun is the same execution |
| Workspace | Runner/executor | runner and workspace instance IDs | Git status proves isolation |
| Cache | Cache service | namespace, key, object digest, writer | Hit means correct |
| Artifact | Artifact repository | subject type and immutable digest | Version or tag cannot move |
| Policy result | Policy engine | policy revision and evaluation ID | Passed once means valid forever |
| Approval | Approval system | intent digest, environment, actor, expiry | Click approves any bytes from the run |
| Workload identity | Identity provider and relying policy | issuer, subject, audience, token ID | Valid token means authorized |
| Deployment intent | Deployment controller | operation and release IDs | Timeout means rejected |
| Runtime | Orchestrator and nodes | workload IDs and observed digest | Desired state means serving state |
| Durable application effects | Database, queue, external system | transaction/message/business IDs | Code rollback reverses effects |
| User outcome | Application and business reconciliation | operation ID and result | Readiness or HTTP 200 proves completion |

### Identity chain

Use a chain, not one overloaded version variable:

~~~text
change_id
  -> source_commit
  -> pipeline_definition_revision
  -> logical_run_id
  -> attempt_id
  -> job_id
  -> runner_id + workspace_id
  -> cache_key + cache_object_digest
  -> artifact_type + artifact_digest
  -> evidence_bundle_digest
  -> approval_intent_digest
  -> environment_revision
  -> deployment_operation_id
  -> release_id
  -> workload_instance_id
  -> user_operation_id
~~~

**Text alternative:** one logical change selects source and pipeline revisions, which produce a run containing attempts and jobs. Each job uses an identified runner and workspace, may consume a named cache object, and publishes a typed artifact digest. Evidence and approval bind that digest to an environment. A deployment operation creates a release and workload instances. A separate user-operation identity proves the promised result.

This chain lets you answer precise questions. If the same source created two artifact digests, investigate build inputs and determinism. If tested and deployed OCI manifest digests differ, investigate artifact continuity. If one release intent created two deployment operations after retry, investigate idempotency and retry ownership. If runtime digest is correct but users fail, move downstream to configuration, data, dependencies, or application behavior.

### Trust flows one way

Separate runner pools by trust. Untrusted fork or pull-request code may be allowed to read public source and a reviewed read-only base cache. It must not write a cache later trusted by protected release jobs, reach protected networks, request production identity, alter pipeline templates, or publish release artifacts into a trusted namespace.

Protected jobs may consume outputs from lower trust only after treating them as untrusted input and independently rebuilding or verifying according to policy. The safest flow is not *build in an untrusted job, then give that artifact production credentials*. The safe design establishes a reviewed boundary where protected infrastructure reconstructs or validates release inputs with an auditable chain.

### Build once, promote, and read back

~~~text
exact build inputs -> OCI manifest digest A
                         |
          +--------------+--------------+
          |              |              |
       test A          scan A       attest A
          +--------------+--------------+
                         |
                approve A for prod
                         |
                 deploy digest A
                         |
             runtime readback = A ?
                         |
               user operation passes?
~~~

**Text alternative:** exact build inputs produce OCI manifest digest A once. Tests, scans, and attestations name A. Approval authorizes A for production. Deployment requests A, runtime inspection confirms A, and a user operation verifies behavior. If any stage names B, promotion stops until the identity break is explained.

## Request or state path

Follow one production release as a state machine. At each step ask: input, owner, output, identity, failure, retry, and proof.

### 1. Validate the event before selecting authority

The controller receives a push, pull request, tag, schedule, or manual request. It validates delivery authenticity according to the platform, but it still treats payload fields as untrusted data. The event's trust class decides which pipeline definition, runner pool, cache direction, permissions, and environment gates are eligible.

Fork code and fork-controlled text never become shell syntax. A protected deployment must not use a pipeline definition taken from an unreviewed pull-request revision with production permissions.

### 2. Close source and pipeline identities

Record the full source commit and tree, submodule or generated-source identities, lockfiles, and the exact pipeline definition plus included templates. A run triggered from a branch must resolve the branch once and persist the immutable revision. A later branch movement must not silently change the run.

Pipeline code is production code. It selects commands, containers, actions or plugins, permissions, event fields, artifacts, and environments. Review and protect it accordingly.

### 3. Create the logical run and graph

The controller evaluates configuration into a concrete DAG. Persist the graph revision, input parameters, conditions, permissions, concurrency key, timeouts, and job definitions. Dynamic matrices may expand one template into many jobs. Fan-in nodes must say whether skipped, cancelled, allowed-failure, or missing results satisfy the gate.

Graph creation can fail before any runner exists. Separate configuration errors from queue and execution errors.

### 4. Apply concurrency before mutation

Choose a concurrency key that names the actual collision domain, such as service plus production environment. Decide whether a newer run waits, is rejected, or supersedes an older run.

Superseding is not instant safety. The controller must request cancellation, the runner must acknowledge it, child processes must stop, and any external deployment or migration must be reconciled. Only then may the newer operation assume ownership. A cancelled UI label is not a distributed transaction rollback.

### 5. Schedule into a trust and capacity pool

The scheduler matches operating system, architecture, labels, privileges, network, repository trust, and environment authorization. Measure queue age separately from execution duration. A queue can grow because of insufficient runners, a label mismatch, quota, disabled pool, image startup, or a downstream service limit.

Do not solve protected-runner shortage by sending privileged work to an untrusted shared pool.

### 6. Prepare an isolated workspace

The executor creates or validates a workspace. It checks out exact source, prepares toolchain identity, and prevents inherited files, processes, mounts, or credentials. For a persistent runner, cleanup must be explicit and verified. For an ephemeral runner, verify the image and bootstrap chain.

Record runner ID, executor type, image digest, operating system, architecture, tool versions, workspace instance, and start time. These are build inputs and incident evidence.

### 7. Restore cache as an optimization

Construct a cache key from compatibility inputs: dependency lock digest, toolchain or builder digest, operating system, architecture, relevant flags, generator versions, job policy, and sometimes source scope. Define who can write the namespace and whether lower-trust work can influence protected work.

After restore, validate object integrity and domain-specific invariants. A miss rebuilds. A hit does not bypass validation. A corrupted or untrusted object is quarantined, not made correct by renaming the key.

### 8. Build and test one candidate

Build inside the declared context. Tests, static analysis, security checks, contract checks, and integration checks must report the exact subject they evaluated. A test report without source, builder, dependency, and artifact identity is difficult to transfer safely.

Parallel test shards need a deterministic input and complete fan-in. Allowed failures need an explicit policy; otherwise a green graph can hide a missing critical result.

### 9. Publish an immutable artifact and evidence

Package once. Compute the correct artifact identity. For a container release, keep the OCI image manifest digest separate from an archive checksum, layer digest, configuration digest, tag, and multi-platform index digest.

Upload to non-overwritable storage where possible. Record digest, size, media type, producer, upload receipt, retention, access policy, Software Bill of Materials, provenance, signatures or attestations required by policy, and verification result. A successful upload response still needs readback or repository receipt.

### 10. Evaluate gates against immutable intent

Construct canonical release intent: source revision, pipeline revision, artifact type and digest, evidence bundle, environment, configuration or migration revision, compatibility plan, risk, policy version, requested actor, and expiry.

Automated policy and human approval evaluate this object. Do not approve a branch, mutable tag, run page, or filename alone. Separation of duties may require the approver to differ from the executor or artifact publisher.

### 11. Exchange short-lived identity for narrow authority

The job requests a workload identity assertion only when needed. The relying service validates signature, issuer, subject, audience, time, workflow and environment claims, then grants short-lived permission for exact deployment operations on exact resources.

Never print the token. Do not pass it through artifacts or caches. Record non-secret identity and authorization decisions: principal, claim class, policy revision, resource, action, expiry, and audit operation.

### 12. Persist deployment intent before sending

Create one stable logical deployment identity bound to release intent. Persist it before the API call. Send an idempotency key or external operation identity when supported. Set one overall deadline and decide which layer owns retries.

If the response times out after send, mark the outcome unknown. Query the deployment controller by the same identity. Do not issue a new operation merely because the job log ended red.

### 13. Reconcile a progressive cohort

The deployment controller records desired state and updates a bounded cohort. Verify exact runtime digest and configuration, startup, readiness, liveness, scheduling, capacity, dependency health, database/message compatibility, and migration state.

Guardrails compare a named cohort with a suitable baseline over a declared window. Use errors, latency, saturation, queue age, business result, and representative user operations. Expand, hold, or abort. Reconcile in-flight work before switching versions or traffic.

### 14. Verify, record, and retain rollback options

Verification joins controller state to runtime and user truth:

- all intended instances or traffic slices serve the approved digest;
- no unexpected instance or duplicate release remains;
- data and message invariants hold;
- representative user operations succeed exactly as intended;
- error, latency, saturation, queue, and business signals remain inside guardrails;
- credentials and policies operated as scoped;
- the known rollback target remains compatible and available;
- accepted work from failed attempts is reconciled.

Only now is the original release operation restored or complete for the declared scope and time. Store the release receipt and evidence lineage. Retention makes later incident reconstruction possible.

### 15. Separate cleanup from evidence destruction

Temporary workspace and credentials should be removed according to policy, but durable run, artifact, approval, deployment, and incident records need retention. Cleanup must target exact owned state. Broad cache deletion, workspace wiping, tag mutation, and log truncation during diagnosis may remove the difference that explains the failure.

## Failure zoom

Most difficult delivery incidents are identity or ownership failures disguised as ordinary red jobs. Zoom in on three cases and follow the evidence instead of the pipeline colour.

### Failure A: the approved thing and the deployed thing differ

The build job reports digest A. A test job downloads artifact A and passes. Later, a publish step pushes a mutable tag such as release-candidate. Another run overwrites that tag with digest B. The approval page still says release-candidate, and production pulls the tag after it moved.

~~~text
source A -> build -> manifest digest A -> test A -> approval of "release-candidate"
source B -> build -> manifest digest B -> move same tag
deploy  -> resolve mutable tag now -----------------------> runtime B
~~~

The symptom may be a regression that cannot be reproduced from the supposedly approved source. The first thought should be: prove the identity at every boundary.

1. Read the build receipt and record the OCI image manifest digest.
2. Read the test subject from the test evidence, not merely its filename.
3. Read the approval object and ask whether it bound an immutable digest.
4. Read the deployment request and controller revision.
5. Query every running instance or traffic cohort for its actual digest.

If build, test, approval, deployment, and runtime do not name the same digest, the chain of custody is broken. Re-running tests against the current tag does not prove what happened earlier. Preserve both manifests and audit events. Stop further promotion, choose a verified digest, reconcile runtime, and repair the workflow so promotion changes a reference to an already-built immutable object.

An archive checksum is not interchangeable with an OCI image manifest digest. They identify different byte structures. State the object type whenever you state a digest.

### Failure B: a timeout creates a second deployment

A deployment job sends operation D-41. The controller accepts it, but the response is lost. The CI job reaches its timeout and displays failed. A retry creates D-42, starts the same migration again, and competes for the same environment.

~~~text
job attempt 1 --send D-41--> controller --accepted--> environment
       |             response lost
       +--timeout--> UI says failed

job attempt 2 --send D-42--> controller --accepted--> same environment
                                 D-41 is still active
~~~

The red job is only an observation about the client deadline. It does not prove the remote operation failed or stopped. Ask:

- Was an idempotency or deployment identity persisted before the first send?
- Did the server accept the request?
- What does the controller report for D-41?
- Did cancellation reach the controller, the runner only, or neither?
- Which migration versions and application digests are active?
- Can the operation be resumed, reconciled, compensated, rolled forward, or safely rolled back?

Recovery is reconciliation, not another blind retry. Freeze automatic retries, discover all operations for the logical change, elect one intended owner, stop or compensate duplicates where safe, verify data and runtime state, then restore service. The prevention is a stable operation identity, one retry owner, idempotent handlers, bounded concurrency, and explicit unknown-outcome handling.

### Failure C: green deployment, broken service

The rollout controller reaches its desired replica count and the pipeline turns green. Requests still fail because the old application expects a database column that the new migration removed. Infrastructure convergence is not application compatibility.

A safe expansion-and-contraction sequence is:

1. add the new schema or message field without removing the old one;
2. deploy code that can read and write both forms;
3. backfill and verify data;
4. move readers and writers;
5. observe through the compatibility window;
6. remove the old form only after no live or rollback version needs it.

During recovery, restarting pods is useful only for a local failure that restart can safely repair, such as a deadlock or stuck loop. A liveness probe must not restart healthy processes because a database or remote dependency is unavailable. That amplifies an external outage into local churn.

### Observation, inference, proof limit

Keep these three sentences separate in every incident note:

- Observation: what a named source directly reports, with time and identity.
- Inference: the explanation that best joins several observations.
- Proof limit: what the available evidence still cannot establish.

For example: “The controller accepted D-41 at 10:03” is an observation. “The CI timeout hid an active rollout” is an inference after correlating controller and job records. “We cannot prove which bytes the deleted runner workspace contained” is a proof limit. This discipline prevents confidence from outrunning evidence.

## Internals and state ownership

A pipeline is a distributed system. The UI is a projection assembled from several state owners, not the owner of every fact. Troubleshooting becomes much faster when each question goes to the component that can answer it.

### Controller and scheduler

The controller stores run identity, trigger context, evaluated graph, dependencies, conditions, approvals, concurrency policy, cancellation request, and summarized status. The scheduler turns runnable graph nodes into queue entries and matches them to compatible executors.

Important internal states are richer than queued, running, and failed:

~~~text
created -> graph-valid -> blocked-on-needs -> runnable -> queued
        -> leased -> acknowledged -> executing -> uploading
        -> succeeded | failed | timed-out | cancellation-requested
        -> cancelled | outcome-unknown
~~~

A lease prevents two runners from owning the same job accidentally. It needs an expiry and heartbeat because runners disappear. If a lease expires while the original worker is merely partitioned, another worker may start. Therefore side effects still need idempotency; scheduling exactly once is not a realistic end-to-end guarantee.

### Runner and workspace

The runner owns local execution: checkout, processes, filesystem, toolchain, local containers, network access, credentials injected for the job, and log transport. Persistent runners trade startup cost for more residual-state risk. Ephemeral runners reduce cross-run residue but still depend on a trusted image, bootstrap process, and isolation boundary.

Ask five questions about a runner:

1. Who can submit work to it?
2. Which host, network, secrets, devices, and container socket can it reach?
3. What survives between jobs?
4. Which image and toolchain produced this run?
5. What proves cleanup and credential revocation occurred?

The Docker socket is effectively authority over the Docker host. Mounting it into an untrusted job is not ordinary container isolation. Likewise, a Kubernetes service-account token, cloud credential, package-publish token, signing key, or production network route changes the runner's trust class.

### Cache service

The cache service owns reusable optimization objects and cache metadata. It does not own release truth. Correct cache design names:

- key inputs and compatibility rules;
- read and write trust domains;
- restore-prefix behaviour;
- retention and eviction;
- integrity validation;
- miss and corruption behaviour.

A complete dependency-cache key might derive from operating system, architecture, package manager, lockfile digest, toolchain digest, build flags, and policy revision. Branch name alone is usually too weak. An untrusted fork must not write objects that a protected release later trusts.

Deleting every cache can restore a build, but it destroys the evidence needed to identify the bad key and object. Quarantine the suspect key or object, preserve its metadata, reproduce with cache disabled, then repair the namespace.

### Artifact, provenance, and attestation stores

The artifact repository owns immutable release bytes and repository receipts. Provenance states how an artifact was produced. An attestation is a signed statement about a subject, predicate, and producer. A signature authenticates a statement or object but does not make the build process correct; policy decides which identities, builders, inputs, and predicates are acceptable.

For a container, distinguish:

- image manifest digest: a platform-specific runnable image identity;
- image index digest: a multi-platform mapping;
- configuration digest: image configuration identity;
- layer digest: one filesystem layer;
- tag: a mutable human-friendly reference unless the registry enforces otherwise;
- exported archive checksum: identity of the archive file, not automatically the registry manifest.

Approval and deployment must name the same intended object type. A policy comparing an archive checksum with a manifest digest is not a stronger check; it is a type error.

### Identity provider and secret systems

The identity provider owns issuer keys, workload assertions, claims, audience, lifetime, and authentication events. The authorization system owns the decision that a principal may perform an action on a resource. A secret manager owns secret material, versions, access policy, and audit events.

A preferred deployment flow is:

~~~text
protected job -> signed workload assertion -> identity exchange
              -> short-lived scoped credential -> deployment API
~~~

Bind trust to stable claims such as repository or project identity, protected workflow or pipeline definition, environment, ref policy, and audience. Avoid broad wildcards. Keep credential lifetime shorter than the useful attack window, but long enough for the bounded operation. Renewal needs its own policy; silently issuing a fresh credential to an already-cancelled job defeats cancellation.

### Deployment controller and runtime

The deployment controller owns desired release state, strategy, revision history, rollout progress, traffic policy, and reconciliation. Runtime components own actual processes, instances, pods, virtual machines, tasks, load-balancer targets, and live configuration. Observability systems own sampled evidence about behaviour.

Desired state and actual state can disagree. A successful API response may mean only that intent was accepted. A completed rollout may mean only that a controller's convergence conditions passed. Neither proves a representative user operation succeeded.

For every production release retain a join key across:

~~~text
logical change -> source -> run/attempt -> artifact digest -> approval
               -> deployment operation -> controller revision
               -> runtime instances/cohorts -> telemetry -> user verification
~~~

Without this join, dashboards show nearby facts but cannot establish causality or chain of custody.

### Who owns the final status?

No single component owns all meanings of done. The controller owns the run result. The repository owns artifact persistence. The deployment controller owns convergence. The runtime owns actual execution. The service team owns the declared reliability outcome. The user journey owns whether the release delivered its purpose.

Define completion explicitly: “Deployment operation D-41 has converged to manifest digest A for all intended production instances, guardrails remained within threshold for 20 minutes, the checkout canary succeeded, and no duplicate operation remains.” That statement is testable. “Pipeline green” is not.

## Evidence table

Use this table as an incident collection order. Preserve identifiers and timestamps before retrying, cancelling, deleting, or rebuilding.

| Question | Best evidence source | What it can establish | What it cannot establish alone |
|---|---|---|---|
| Why did the run exist? | Trigger event and audit record | Event type, actor, source ref, delivery ID, receive time | That payload authorization was correct |
| Which pipeline definition ran? | Evaluated pipeline snapshot and revision | Exact configuration and included templates after expansion | That a remote reusable component behaved safely |
| Why did a job wait? | Scheduler queue record and runner inventory | Queue age, required labels, capacity, lease attempts | That adding any runner is safe |
| What executed the job? | Runner lease, image digest, tool versions, workspace ID | Executor identity and declared environment | That no undeclared host residue affected it |
| What source was used? | Checkout receipt and object ID | Exact commit or source object | That generated or downloaded dependencies were correct |
| Was cache involved? | Key, object digest, namespace, writer, restore result | Which cached object was read or written | That cached contents were semantically compatible |
| What did tests evaluate? | Test subject digest, source ID, builder ID, report | Results for one declared subject and test set | That a later mutable tag still means that subject |
| What was published? | Repository receipt, media type, digest, size | Stored object identity at publication time | That every later consumer used it |
| What was approved? | Immutable release-intent record and audit entry | Subject, environment, policy, approver, expiry | That runtime matches the approval |
| Which authority was used? | Identity exchange and authorization audit event | Principal, claims class, action, resource, expiry | Secret safety if logs or workspace leaked it |
| Did the deploy request arrive? | API audit log and idempotency record | Acceptance, rejection, or existing operation identity | Successful convergence |
| What did the controller intend? | Deployment revision and strategy state | Desired digest, config, cohort, rollout phase | Actual bytes on every instance |
| What is actually running? | Runtime identity endpoint, orchestrator status, process/container inspection | Current digest/config per observed instance | User-visible correctness everywhere |
| Is the service healthy? | SLI telemetry, cohort comparison, synthetic and real-user signals | Behaviour in a defined window and population | Future reliability or unmeasured journeys |
| Is data compatible? | Migration ledger, schema inspection, invariant query, consumer lag | Applied versions and selected invariants | Full reversibility without a tested recovery path |
| Did cancellation finish? | Controller acknowledgement, runner process state, external-operation state | Which layers stopped or remain active | Automatic reversal of completed side effects |
| How many deployments occurred? | Accepted production deployment events | Actual production deployment-event count | Number of distinct changes without correlation |

### Preserve a minimum evidence bundle

For a serious delivery incident, capture:

- logical change ID, run ID, attempt ID, job ID, event delivery ID;
- source and pipeline revisions;
- runner, executor, image, toolchain, workspace, and lease identity;
- cache key, namespace, object digest, writer trust class, and result;
- artifact type, OCI manifest or index digest as applicable, repository receipt, provenance, and policy result;
- approval subject, actor, time, policy, environment, expiry, and decision;
- workload principal and non-secret authorization result;
- deployment operation, idempotency key, controller revision, strategy, cohort, and status;
- actual runtime digest and configuration per observed instance;
- migration version and compatibility evidence;
- guardrail definition, raw window, baseline, cohort, and representative user result;
- cancellation, retry, rollback, roll-forward, or compensation actions;
- clock source and relevant timezone.

Hash or sign the bundle if its integrity matters. Restrict access because logs can contain source paths, personal data, internal topology, and accidental credentials. Evidence retention is a security and compliance decision, not permission to store everything forever.

### Evidence quality tests

Evidence is stronger when it is:

1. specific to an immutable subject;
2. produced close to the state owner;
3. timestamped by a synchronized clock;
4. correlated by stable identifiers;
5. durable and non-overwritable;
6. independently verifiable;
7. explicit about scope, sampling, and absence.

Absence is tricky. No log line may mean the event did not happen, the logger failed, retention expired, sampling dropped it, the query used the wrong time range, or clocks disagree. Say “no matching event was found in source X for range Y” instead of “it never happened.”

## Command decoders

These local commands teach evidence shapes without requiring a hosted CI service, registry, or cloud account. Run them in Ubuntu or WSL. Read the explanation before treating output as proof.

**Standard output (stdout)** carries the command's ordinary result. **Standard error (stderr)** carries diagnostics and may appear on the same terminal even though it is a separate stream. **Exit status** is an integer returned to the parent shell; it is not printed automatically. In the examples, a final line such as **exit=1** is an observation annotation showing the captured status, not text emitted by the command itself. Empty stderr is stated when expected, but absence of a terminal diagnostic is not proof that every upstream layer succeeded.

### Command 1: close repository and HEAD identity

~~~bash
git rev-parse --show-toplevel && git rev-parse --verify HEAD
~~~

Representative standard output and status:

~~~text
/home/learner/work/reliability-atlas
8f0b1f31c4f954acde3c6dbf451fb7fa76312d98
exit=0
~~~

Outside a Git worktree, the diagnostic is written to standard error and the command normally exits 128:

~~~text
fatal: not a git repository (or any of the parent directories): .git
exit=128
~~~

Decode the syntax:

- **rev-parse** asks Git to resolve repository and object information.
- **--show-toplevel** prints the absolute worktree root.
- **&&** runs the HEAD query only if the root query exits zero.
- **--verify HEAD** requires HEAD to resolve to exactly one object and prints its full object ID.

The object ID may be represented differently by repositories using different object formats; record the complete returned value. The two lines prove local selection at that instant, not remote branch position, commit signature trust, pipeline revision, workspace cleanliness, or built bytes.

### Command 2: decode Git short-status XY fields

~~~bash
git status --short --untracked-files=all
~~~

A representative observation is standard output followed by the recorded exit status:

~~~text
 M app/service.py
M  pipeline.yml
MM scripts/build.sh
A  tests/new_contract.test
R  config/old.yml -> config/current.yml
?? reports/run.json
exit=0
~~~

The first two columns are **XY**, and spaces are meaningful:

| XY example | Index compared with HEAD | Worktree compared with index |
|---|---|---|
| " M" | unchanged | modified but unstaged |
| "M " | modified and staged | unchanged after staging |
| "MM" | staged modification | another unstaged modification |
| "A " | added to index | unchanged after staging |
| "R " | rename staged | unchanged after staging |
| "??" | not tracked | not tracked |

**--short** selects the compact two-column form. **--untracked-files=all** expands untracked directories to individual files; it does not include ignored files unless ignored reporting is separately requested. A dirty result still exits zero because status successfully inspected the repository. No rows plus exit zero means no tracked or visible untracked difference under these options. A fatal repository error appears on standard error and commonly exits 128.

For machine parsing, prefer the documented porcelain form and control path/quoting behavior rather than scraping a colorized human display. This command cannot reveal ignored residue, external mounts, processes, credentials, or whether build code consumed undeclared files.

### Command 3: compare final tracked content with HEAD

~~~bash
git diff HEAD --exit-code -- .
~~~

When tracked content differs, the observation contains a unified patch followed by recorded exit status 1:

~~~diff
diff --git a/app/service.py b/app/service.py
index 2c1743a..987bcab 100644
--- a/app/service.py
+++ b/app/service.py
@@ -1 +1 @@
-MODE = "safe"
+MODE = "debug"
exit=1
~~~

No patch and exit zero means the resulting staged-plus-unstaged tracked content under the current path scope matches HEAD. A bad revision or repository error is different from “changes found”: Git writes a fatal diagnostic to standard error and normally exits above 1, commonly 128.

Decode the flags:

- **HEAD** is the commit-tree baseline.
- **--exit-code** maps no difference to 0 and a difference to 1.
- **--** ends option parsing, so later tokens are paths.
- **.** limits comparison to the current path scope.

This shows the net tracked difference from HEAD. Use separate index-versus-HEAD and worktree-versus-index queries when the incident requires staged/unstaged attribution. It still omits untracked, ignored, generated outside the path, submodule internals, and external inputs.

### Command 4: make a dependency graph visible

~~~bash
echo 'build needs=-'; echo 'test needs=build'; echo 'package needs=test'; echo 'deploy needs=package'
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
build needs=-
test needs=build
package needs=test
deploy needs=package
exit=0
~~~

Each line is one graph node and its dependency. The hyphen means build has no predecessor in this tiny model. A scheduler may run a node when all required predecessors have satisfied their declared conditions. This is a chain, not evidence that real work occurred.

Each semicolon ends one shell command and starts the next regardless of the earlier status. Here every Bash **echo** should return zero; a missing shell or execution failure would be outside this model. The fields are job-name, a space, and **needs=predecessor**. They are printed text, not a parsed graph and not proof of acyclicity.

When debugging a skipped job, ask whether its dependency was absent, failed, cancelled, allowed to fail, conditionally excluded, or produced no required output. When optimizing, find independent nodes that may fan out and the fan-in that must collect every mandatory result. Do not remove a dependency merely to shorten runtime; first state which safety property it enforced.

### Command 5: derive a cache-key example

~~~bash
echo -n 'lock=abc|toolchain=sha256:builder|platform=linux-amd64|job=build|policy=v3' | sha256sum
~~~

Representative standard output and status:

~~~text
3cea12030b1a948d425b4dd1155164b92920e5495f3a211b7ac5f46821927dfa  -
exit=0
~~~

The input is a canonical compatibility description. The output digest can be used as a compact key. The no-newline flag matters: a trailing newline changes the bytes and therefore the digest.

Decode every token:

- **echo -n** writes the quoted bytes without a trailing newline; portability differs outside the declared Bash environment, so production scripts often prefer **printf**.
- The pipe sends standard output from **echo** to standard input of **sha256sum**.
- The first output field is the 64-hex-character SHA-256 digest.
- The second field is a hyphen, meaning **sha256sum** read standard input rather than a named file.
- With ordinary Bash pipeline semantics, the displayed exit status is that of the last command. Enable and understand pipeline failure propagation when an earlier producer can fail.

This is a teaching key, not a complete production design. Replace placeholders with real lockfile and builder digests, canonicalize ordering and encoding, include all compatibility-changing inputs, and put trust-domain separation outside or inside the key. Record the unhashed field schema so humans can explain a miss. A matching hash proves equal input bytes, not that the selected inputs were sufficient.

### Command 6: identify a tiny artifact

~~~bash
echo -n 'release-bytes-v1' | sha256sum; echo 'size_bytes=16'
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
32322ac1052cb41437871d20d4fbdf50b90952b04ee4371a5067c9962babcc1a  -
size_bytes=16
exit=0
~~~

The first value is a SHA-256 digest of exactly 16 bytes; the second declares the size. Digest plus algorithm, size, and media type is stronger than a filename. Any byte change creates a different digest with overwhelming probability.

This output identifies the text payload, not a container image manifest. If these bytes were placed into a tar archive, compressed, or represented as an OCI object, that enclosing object would have its own identity. Always say “digest of what?”

The semicolon is important: the final **echo** runs even if the hashing pipeline fails, and its zero status can become the overall shell status. A production implementation should couple digest and size creation with explicit error handling and compute size from the actual payload instead of trusting a manually typed constant. The hyphen again means standard input, not a filename.

### Command 7: compare immutable subjects

~~~bash
test 'sha256:aaa' = 'sha256:aaa' && echo 'tested_eq_approved=true'; test 'sha256:aaa' = 'sha256:bbb' && echo 'approved_eq_candidate=true' || echo 'approved_eq_candidate=false'
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
tested_eq_approved=true
approved_eq_candidate=false
exit=0
~~~

The first comparison succeeds because the tested and approved identities are equal. The second reports false because the approved identity and candidate identity differ. The command demonstrates the minimum invariant:

~~~text
tested subject = policy-approved subject = deployment subject = runtime subject
~~~

Real validation must also compare the object type, algorithm, registry or repository context, platform when relevant, configuration and migration intent, and evidence policy. String equality cannot authenticate the value; obtain it from trusted receipts and runtime evidence.

The shell **test left = right** compares strings. **&&** executes the next command only when the comparison returns zero; **||** executes its branch when the preceding conditional list is non-zero. The final false comparison is converted into a successful explanatory **echo**, so overall exit zero does not mean every equality held. Consume the printed fields or write an explicit failing invariant check.

### Command 8: decode workload-identity claims

~~~bash
echo 'iss=issuer.example'; echo 'sub=repo:team/service:environment:prod'; echo 'aud=deploy'; echo 'exp=2000000000'
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
iss=issuer.example
sub=repo:team/service:environment:prod
aud=deploy
exp=2000000000
exit=0
~~~

Issuer identifies who signed the assertion. Subject identifies the workload. Audience names the intended relying service. Expiry limits lifetime. A relying service must validate signature, trusted issuer, exact audience, time bounds, subject pattern, environment and workflow claims, then authorize a narrow action.

The prefixes reflect common claim names: **iss** is issuer, **sub** is subject, **aud** is audience, and **exp** is a numeric expiry time, commonly seconds since the Unix epoch in a real token contract. The colon-separated subject value is synthetic provider-shaped text, not a universal grammar. These are four shell **echo** calls; there is no dictionary and no token parser.

The command prints harmless synthetic values; it does not create or validate a token. Never paste a real token into a lesson, shell history, issue, artifact, cache, or log. Decode only in a protected tool, and remember that readable claims are not valid until the signature and policy are verified.

### Command 9: decide whether retry is justified

~~~bash
echo 'rejected retry=false'; echo 'committed retry=false'; echo 'unknown retry=false'; echo 'proven_absent_transient retry=true'; echo 'conflict retry=false'
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
rejected retry=false
committed retry=false
unknown retry=false
proven_absent_transient retry=true
conflict retry=false
exit=0
~~~

Retry depends on state, not colour:

- rejected: correct the request or policy; the same request is unlikely to help;
- committed: success already occurred; reconcile and return that result;
- unknown: query by stable operation identity before deciding;
- proven absent and transient: retry may be safe within budget and backoff;
- conflict: identify the current owner and reconcile concurrency.

Even a transient retry requires an idempotent operation, bounded attempts, jittered backoff, an overall deadline, and one retry owner. Layered retries can multiply load: three client attempts times three library attempts times three controller attempts can produce 27 calls.

Each row has a modeled outcome label and a **retry=true|false** policy field. The shell prints policy text and exits zero; it does not branch, query an operation, enforce idempotency, sleep, or retry. Standard error should be empty in the declared shell. Treat any real command failure separately from the policy values it was meant to display.

### Command 10: evaluate a canary guardrail

~~~bash
errors=7; requests=500; rate_bp=$((10000*errors/requests)); echo errors=$errors; echo requests=$requests; echo error_rate_basis_points=$rate_bp; test $rate_bp -gt 100 && echo abort=true || echo abort=false
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
errors=7
requests=500
error_rate_basis_points=140
abort=true
exit=0
~~~

The calculation uses integer basis points. One basis point is 0.01 percent, so 140 basis points is 1.40 percent. The threshold is 100 basis points, or 1.00 percent; therefore this model aborts.

The shell arithmetic expands **10000*7/500** using integer division. The result is basis points, not a percent field. The **test -gt 100** expression asks whether the integer is greater than 100; equality would not abort. Both the true and false branches print a field and normally end with exit zero, so **abort=true** is data for a caller, not a non-zero shell failure. Production code must define rounding, zero-request handling, overflow bounds, units, window, and missing data.

Production analysis also needs a suitable baseline, minimum sample size, confidence or noise treatment, a fixed observation window, error classification, and latency or business guardrails. Seven failures could share one dependency or one customer cohort. Aggregation must not hide the affected dimension. An empty series is unknown, not automatically healthy.

### Command 11: separate changes, attempts, and deployments

~~~bash
changes=10; ci_attempts=14; accepted_deployments=11; echo logical_changes=$changes; echo ci_attempts=$ci_attempts; echo accepted_production_deployment_events=$accepted_deployments; echo deployment_events_per_logical_change_x100=$((100*accepted_deployments/changes))
~~~

Representative observation (standard output followed by the recorded exit status; standard error is empty):

~~~text
logical_changes=10
ci_attempts=14
accepted_production_deployment_events=11
deployment_events_per_logical_change_x100=110
exit=0
~~~

There are ten logical changes, fourteen CI attempts, and eleven accepted production deployment events. The final integer is 110 per 100 changes, meaning 1.10 accepted deployment events per logical change. Integer arithmetic truncates fractional remainder, and division by zero would fail.

This value is an event-correlation or possible rework indicator, not DORA deployment frequency: it has no time denominator. To calculate deployment frequency, count accepted production deployment events in a stated window and divide by window duration, or measure time between successive events. Exclude CI retries that never deploy. If a retry creates another real production deployment, count it and correlate it under the logical change or release intent. Separately classify incident-driven unplanned deployments for deployment rework rate.

### Command 12: inspect lab prerequisites without mutation

~~~bash
bash lab.sh check
~~~

From clean normal-user state, a representative observation is standard output followed by the recorded exit status:

~~~text
lesson=LES-0024
state=absent
network=none
privilege=non-root
exit=0
~~~

From an elevated shell, the controller writes a refusal to standard error and exits 77:

~~~text
error=root-is-refused-run-as-a-normal-user
exit=77
~~~

Run this from the lesson lab directory. The **check** subcommand validates required local tools, controller-owned state, descriptor grammar, and safety guardrails without creating the lab root. **state=absent** means neither a registered state nor matching orphan was observed for this UID at that instant. **network=none** is the fixture's declared behavior, not host-wide network proof. A successful check does not mean setup, incident injection, recovery, or verification ran. Read every reported path before allowing a script to create state. The lab is deliberately bounded under its declared temporary directory and refuses unsafe conditions.

### Independent gate command: acknowledge an external prediction digest

After the independent scenario and before any evidence view:

~~~bash
prediction_document='/absolute/path/outside-the-lab-root/asm-0057-prediction.md'
read -r prediction_sha256 _ < <(sha256sum -- "$prediction_document")
bash lab.sh acknowledge-predictions "$prediction_sha256"
~~~

Representative fields are:

~~~text
record=prediction_acknowledgment
case=independent
external_prediction_sha256=<the-submitted-lowercase-64-hex-value>
content_stored=false
review_required=true
next_command=bash lab.sh observe graph
exit=0
~~~

**sha256sum** prints digest then filename. Bash **read -r prediction_sha256 _** assigns the first field to the named variable and the remaining field to the throwaway variable. Process substitution exposes that output as input to **read**. Quote the filename and variable so spaces do not become extra shell arguments.

The lab checks the submitted value's lowercase 64-hex shape and records it; it does not read the external document. Before acknowledgement, an independent view refuses because **prediction.record** is absent and exits 73. A receipt proves only controller order and the acknowledged digest string, not authorship, document bytes, content quality, completeness, or creation time.

### Independent experiment command: change one cache-key input

After acknowledgement and evidence collection, and before independent recovery:

~~~bash
bash lab.sh experiment cache-key
~~~

The record has this evidence shape:

~~~text
record=experiment
case=independent
experiment=cache-key
prediction_record_sha256=<digest-of-the-controller-receipt>
declared_variable=pipeline-definition-digest-in-key
control_key_fields=source,lock,runner-image,job-policy
control_definition_digest_in_key=false
control_cache_result=stale-hit
control_artifact_sha256=<previous-artifact-digest>
treatment_key_fields=source,definition,lock,runner-image,job-policy
treatment_definition_digest_in_key=true
treatment_cache_result=miss-build-current
treatment_artifact_sha256=<current-artifact-digest>
unchanged_source_sha256=<source-digest>
unchanged_lock_sha256=<lock-digest>
unchanged_runner_image_sha256=<runner-image-digest>
unchanged_job_policy=lint,test,policy
single_variable_changed=true
proof_limit=deterministic-local-model-only
network_calls=0
hosted_ci_calls=0
registry_calls=0
cloud_calls=0
next_command=bash lab.sh recover
exit=0
~~~

The **control_** fields describe the incomplete key. The **treatment_** fields add only the declared definition input. The **unchanged_** fields are explicit controls, and **single_variable_changed=true** is validated by the model. Independent recovery refuses until this durable experiment record exists.

The result proves the fixture's deterministic comparison and no modeled external calls. It does not prove a real cache was queried, that a provider uses these fields, that the incident has this root cause, or that the treatment is sufficient for production. Preserve your pre-experiment prediction so a reviewer can distinguish reasoning from hindsight.

### Exit status is evidence too

Shell commands return an integer status: zero conventionally means the command's declared condition succeeded; non-zero means it did not. An empty standard output is not automatically failure, and printed success text is not automatically a zero status. In automation, capture command, subject, start and end time, exit status, and required output or artifact. Avoid pipelines that accidentally report only the last process's status; in Bash, strict modes and explicit checks help, but each has semantics you must understand.

## Decision path

When delivery fails, resist the fastest-looking action until you know the state owner and side-effect boundary. Use this path.

~~~text
START: What user or release operation is impaired?
 |
 +-- Can you name run, attempt, source, artifact, environment, deployment operation?
 |      no -> preserve event/UI/log evidence; recover identifiers first
 |      yes
 |
 +-- Did failure occur before any external side effect?
 |      yes -> classify graph / queue / runner / checkout / build / test
 |      no or unknown
 |
 +-- Is artifact identity continuous across build, test, approval, deploy, runtime?
 |      no -> stop promotion; quarantine ambiguity; select verified immutable digest
 |      yes
 |
 +-- Is there an accepted or possibly accepted external operation?
 |      yes/unknown -> query by stable identity; reconcile before retry
 |      proven no
 |
 +-- Are multiple operations competing for the same state?
 |      yes -> freeze automation; elect owner; safely stop/compensate duplicates
 |      no
 |
 +-- Is runtime converged and data/message compatibility valid?
 |      no -> hold/abort; choose roll-forward, rollback, or compensation by compatibility
 |      yes
 |
 +-- Do cohort, service, and representative user guardrails pass?
        no -> limit blast radius and recover
        yes -> observe through declared window; close with evidence
~~~

### Branch A: graph or trigger failure

Start with event delivery, payload, source and pipeline revision, parser or policy error, evaluated graph, conditions, and dependency status. No runner log exists if no runner was scheduled. A webhook can be delivered but rejected; a graph can be valid but intentionally exclude a path.

Fix the smallest incorrect definition. Validate it against representative events, including protected branches, tags, merge requests or pull requests, manual invocations, schedules, and reusable workflows. Prevent unintended double triggers and recursive pipeline commits.

### Branch B: queue or runner failure

Compare queue age with normal, inspect required labels and runner trust class, then check ready capacity, leases, quotas, disabled pools, executor startup, network path, disk, memory, inodes, and process limits. A job “stuck in queue” has not yet proved an application or script problem.

Scale only the correct pool. If arrival rate exceeds service rate for long enough, queue age grows even when every runner is healthy. If one rare label blocks work, more general-purpose runners do nothing. Preserve least privilege when adding capacity.

### Branch C: build, test, cache, or artifact failure

Re-run once without cache only as a controlled experiment, not as the permanent cure. Compare builder identity, source, dependency resolution, environment, cache object, generated files, test subject, and artifact receipt. Quarantine inconsistent cache or artifacts. Do not overwrite the failed subject.

If only a retry passes, treat flakiness as a defect. Record both attempts and the same or different subject. A retry can change time, dependency state, test order, resource pressure, or external data; green does not explain red.

### Branch D: identity, policy, approval, or secret failure

Identify the principal without revealing credentials. Check issuer, audience, subject, time, environment, policy revision, action, resource, and audit denial. For approval, compare immutable release intent with deployment intent. A valid credential can still lack authorization, and an authorized principal can still request a policy-forbidden artifact.

Do not solve a narrow authorization error by issuing a long-lived administrator token. Repair the trust mapping or resource permission, keep lifetime short, and prove the allowed and denied paths.

### Branch E: deployment timeout, cancellation, or conflict

Assume outcome unknown until the remote owner says otherwise. Query using idempotency key, deployment identity, environment, and logical change. Determine whether cancellation was requested, acknowledged, and propagated through child processes and external controllers.

Never let a newer run infer ownership from an older run's cancelled UI badge. Put a concurrency guard at the state owner, not only in the CI controller. Reconcile partial state and record any real accepted production deployment event.

### Branch F: runtime or user failure after green

Join desired revision to actual instance digest and configuration. Check rollout cohort, readiness, local liveness, dependency reachability, saturation, data and message compatibility, telemetry gaps, and representative user operations. Separate a failing new cohort from a common dependency or baseline failure.

Choose recovery by state:

- Roll back when the previous artifact and data contract remain compatible and rollback is faster and safer.
- Roll forward when state has crossed an irreversible boundary or a small verified correction is safer.
- Compensate when an external side effect cannot be erased but can be counteracted.
- Hold when evidence is insufficient and the current bounded cohort is safer than movement.

### Closure conditions

Do not close because a retry turned green. Close when the declared user operation is restored, artifact and runtime identity are proven, duplicate or partial operations are reconciled, data invariants hold, guardrails pass through the observation window, temporary authority is revoked, evidence is retained, and prevention work has an owner and validation method.

## Guided Ubuntu lab

This lesson includes an offline model at **book/labs/LES-0024-ci-cd-architecture**. It needs Ubuntu 24.04 or Ubuntu 24.04 under WSL 2, Bash 5+, Python 3, coreutils, findutils, and flock. It does not need Docker, Kubernetes, a hosted CI account, network access, registry access, cloud access, credentials, or sudo.

The model is intentionally small so you can see every ownership boundary. Its two runner directories are distinct, private, identity-validated workspaces owned by the same current UID. They demonstrate workspace separation, not security isolation from another process with that UID or from a compromised host. The model proves only the encoded local behaviour; it does not prove that a real runner is isolated or a real production deployment is safe.

### Safety boundary before setup

Open a normal, non-root Ubuntu shell:

~~~bash
cd book/labs/LES-0024-ci-cd-architecture
pwd
id
bash lab.sh check
LAB_DRY_RUN=1 bash lab.sh setup
~~~

Read each line. The expected clean branch reports absent state and a dry-run description. If the lab reports root, a missing command, an unregistered lesson root, a changed model, an unexpected child, or an invalid descriptor, stop. Do not use sudo and do not manually delete a similarly named path.

Why so strict? Cleanup is part of the engineering lesson. A name prefix is not proof of ownership. The controller registers one private random root and validates owner, permissions, child allowlist, file type, link count, sentinels, source bytes, and lock inode before mutation.

### Establish a healthy release contract

~~~bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
~~~

Now translate the record into relationships:

- source revision and pipeline-definition digest are different inputs;
- runner-a and runner-b own separate workspaces;
- the cache key includes source, definition, lock, runner image, and job policy;
- tested, approved, candidate, and deployed artifact identities agree;
- workload subject, audience, and environment are narrow;
- approval binds artifact plus environment;
- one logical release creates one promotion and no duplicate;
- user verification is distinct from controller convergence.

Values such as **network_calls=0** describe this model, not every process on your host. The lab cannot observe the entire machine.

### Inject the guided incident

~~~bash
bash lab.sh inject guided
bash lab.sh observe graph
bash lab.sh observe runner
bash lab.sh observe cache
bash lab.sh observe artifact
bash lab.sh observe identity
bash lab.sh observe approval
bash lab.sh observe deployment
~~~

Use one notebook row per view: observation, identity, owner, inference, proof limit, next query. Do not jump from the first red field to “bad artifact.”

In the guided case, source, workspaces, cache, artifact, identity, and approval remain coherent. The canary readiness contract fails and the representative user check fails. The graph refuses promotion, so the known production artifact remains served. The failed canary is evidence that the safety boundary worked.

This distinction is worth remembering:

~~~text
failed release attempt + stopped blast radius = safety control worked
failed release attempt + blind promotion       = production incident
~~~

### Recover the declared operation

~~~bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
~~~

The modeled recovery removes the failed canary, corrects the readiness contract, creates a fresh canary, promotes exactly once, preserves the rollback target, and verifies the user operation. It does not rebuild the artifact because no evidence showed artifact drift.

Before accepting verification, locate evidence for:

1. controller convergence;
2. distinct private workspace identities and separation inside the model, not a security-isolation boundary;
3. valid cache and artifact identity;
4. scoped workload identity;
5. approval bound to the same artifact and environment;
6. exactly one promotion and zero duplicates;
7. rollback target retained;
8. end-to-end user check passed.

If any proof is missing, say incomplete rather than infer success.

### Preview and perform exact cleanup

~~~bash
LAB_DRY_RUN=1 bash lab.sh cleanup
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
~~~

The preview must not alter the active case. Final cleanup should prove the registered state was removed, followed by **state=absent**. If cleanup was interrupted and status says cleanup is in progress, use only **bash lab.sh cleanup** to resume. Never delete the lock file to defeat contention.

### What to write in your engineering journal

Record:

- the user promise;
- the first failed boundary;
- evidence that ruled out artifact, cache, identity, and approval drift;
- why promotion did not occur;
- why rebuilding was not the smallest justified action;
- recovery state transition;
- verification evidence and proof limit;
- one prevention control and one alert.

A strong entry might say: “The modeled canary failed readiness and the user check, while tested, approved, candidate, and production artifact identities remained coherent. Promotion stayed at zero. I recovered the readiness contract and created a fresh canary rather than rebuilding. Verification proved one promotion, no duplicate, retained rollback target, and successful user operation. This proves the local model only.”

### Independent-only enforced order

The guided case does not use prediction acknowledgement or the cache-key experiment. The independent case uses this controller order:

~~~text
scenario
  -> write external prediction document
  -> acknowledge its lowercase SHA-256 receipt
  -> request evidence views
  -> run experiment cache-key
  -> write diagnosis and recovery card
  -> recover
  -> verify operation
  -> exact cleanup
~~~

Independent observation refuses before the acknowledgement record exists. Independent recovery and verification refuse until both prediction and experiment records exist. These transitions enforce record presence and ordering inside the fixture. They do not judge the external prediction content, prove when it was authored, or turn the deterministic cache experiment into production evidence.

### Engineering verifier

After cleanup and from clean state:

~~~bash
bash verify.sh
~~~

The verifier checks syntax, lifecycle refusals, both cases, the independent prediction gate, all seven views, the single-variable cache-key experiment, lock contention, path and identity tampering, cleanup interruption and resume, idempotent cleanup, and final absence. A pass is useful evidence about the local fixture. It does not grade your external prediction or incident explanation and must not be presented as hosted-CI, registry, Kubernetes, or cloud testing.

## Production transfer

The nouns differ across products; the engineering questions remain stable. Transfer the model by locating state owners, immutable identities, trust boundaries, and reconciliation.

### Map concepts, not YAML spelling

| Portable concept | GitHub Actions example | GitLab CI/CD example | Jenkins example | Azure Pipelines example |
|---|---|---|---|---|
| Pipeline definition | workflow | pipeline configuration | Jenkinsfile or configured job | YAML pipeline |
| Run | workflow run | pipeline | build/run | pipeline run |
| Graph node | job | job | stage, parallel branch, or downstream job | job or stage |
| Executor | hosted or self-hosted runner | runner and executor | agent/node and executor | hosted or self-hosted agent |
| Dependency relation | needs | needs or stage ordering | explicit stage/build relation | dependsOn |
| Protected environment gate | environment protection | protected environment / deployment approval controls | authorization plugins or external gate | environment checks and approvals |
| Workload federation | OIDC-issued identity | OIDC ID token flow | external identity integration | workload identity federation where configured |
| Concurrency | concurrency group | resource group or related policy | lockable resource / milestone pattern | exclusive locks or environment checks |
| Artifact exchange | run artifact / package or registry object | job artifact / package or registry object | archived artifact / repository object | pipeline artifact / repository object |

These are orientation examples, not promises that every edition, executor, plugin, or configuration has identical semantics. Inspect the current product documentation and your organization's policy before implementation.

### Ask the same twelve production questions

1. Which events may start which pipeline revision?
2. Can untrusted contributions modify executable workflow code?
3. Which pool runs each trust class, and what can it reach?
4. What survives between jobs and runs?
5. How are cache namespaces separated and validated?
6. What immutable object do tests, policy, approval, deployment, and runtime share?
7. How is provenance produced and verified?
8. Which short-lived principal changes each environment?
9. What exact subject does approval authorize, for how long?
10. Which component serializes competing release operations?
11. How are unknown outcomes and duplicate effects reconciled?
12. Which runtime and user evidence completes the release?

Put answers in version-controlled architecture and operations records. A workflow file alone cannot express every runner, identity-provider, repository, environment, observability, and recovery control.

### A production-ready release contract

Create a canonical release-intent object before approval:

~~~text
release_id
logical_change_id
source_object
pipeline_object
artifact_kind
artifact_digest
provenance_subject_and_builder
required_policy_results
target_environment
configuration_revision
migration_revision_and_compatibility
deployment_strategy_and_limits
rollback_target
approval_policy_and_expiry
requested_workload_principal
verification_plan
~~~

Canonical means ordering and encoding are deterministic. Sign or otherwise protect the record according to threat model. Store it durably. Every later controller should reject a mismatch instead of silently resolving a mutable reference again.

### Runner topology transfer

Separate at least:

- untrusted contribution validation;
- trusted build and signing;
- non-production deployment;
- production deployment;
- high-risk administrative or emergency operations.

Isolation can use ephemeral virtual machines, containers with strong host boundaries, dedicated pools, sandboxing, network segmentation, and short-lived identity. Containers alone are not automatically a security boundary. A shared persistent runner with a privileged socket and long-lived production secret creates a direct path from pipeline code to infrastructure.

Capacity planning must preserve the trust split. Track arrival rate, service time, queue age percentiles, busy workers, cold-start time, failure/retry amplification, and downstream quotas per pool and label. Pre-warm carefully when startup dominates, but keep image freshness and cost visible.

### Deployment topology transfer

Prefer a deployment controller that reconciles declared immutable intent. For Kubernetes this may be a native or GitOps-style controller; for virtual machines it may be an orchestrator or controlled deployment service; for serverless it may be a version and traffic controller. The pattern is:

~~~text
CI produces and authorizes intent
deployment controller reconciles intent
runtime reports actual identity and health
verification joins intent, actual state, and user result
~~~

Keep CI credentials unable to perform unrelated administration. Keep deployment-controller authority environment-scoped. An emergency path needs authentication, authorization, audit, expiry, reconciliation back to source of truth, and post-use review.

### Database and message-contract transfer

Application rollback is unsafe when data or messages become incompatible. Version contracts explicitly. Use expand-and-contract changes, dual read/write only with a bounded plan, online migration safeguards, idempotent backfill, invariant checks, lag monitoring, and a tested recovery path.

Treat migration as its own operation with identity and ledger. Decide whether it runs before, during, or after application cohorts. Serialize incompatible migrations. Do not let every application replica race to execute the same schema change.

### DORA and reliability measurement

Measure all five metrics without rewarding unsafe behaviour:

- **Change lead time:** commit-to-production duration for each deployed change; publish the eligible population and duration distribution.
- **Deployment frequency:** accepted production deployment-event count divided by a stated time window, or the distribution of inter-deployment intervals.
- **Failed deployment recovery time:** failure-start-to-verified-recovery duration for each failed deployment that requires immediate intervention.
- **Change fail rate:** deployments requiring immediate intervention divided by all accepted production deployments in the same service and window.
- **Deployment rework rate:** unplanned deployments caused by production incidents divided by all accepted production deployments in the same service and window.

Correlate events to immutable logical change or release intent. Exclude non-deploying CI attempts from deployment frequency. Count retry-created real production deployments instead of hiding them, then classify incident-driven unplanned deployments for rework. The command decoder's deployments-per-change value is only an event-correlation indicator; it has no time denominator and is not deployment frequency. Add reliability, security, queue, cost, and toil indicators so speed is never interpreted alone.

## Reliability, security, observability, capacity, and cost

CI/CD is a production service even when it only serves engineers. Its failures delay fixes, ship incorrect releases, expose credentials, consume capacity, and erase evidence.

### Reliability: define the service promises

Useful service-level indicators include:

- event acceptance latency and loss rate;
- valid graph creation success;
- queue age by trust pool and label;
- executor acquisition success and cold-start latency;
- job infrastructure-failure rate, separate from code/test failure;
- artifact publication and readback success;
- approval availability and decision latency;
- deployment API acceptance and convergence latency;
- unknown-outcome and duplicate-effect rate;
- canary abort rate by reason;
- verified user-operation success after release;
- recovery and rollback readiness.

An SLO must name population, measurement, target, and window. “95% of trusted Linux build jobs that become runnable receive an eligible runner within five minutes over 28 days” is actionable. “CI is 99.9% available” hides which function and population failed.

Protect reliability with admission control, bounded queues, independent failure domains, executor health checks, circuit breakers for unhealthy dependencies, idempotent operations, tested backup and restore for durable metadata, disaster-recovery exercises, and a degraded path for urgent fixes. A break-glass path is not a replacement for repairing the normal path.

### Security: model who can turn text into authority

The most important threat path is:

~~~text
untrusted input -> executable pipeline code -> privileged runner
                -> credential or socket -> artifact/environment compromise
~~~

Controls should include:

- protected review for pipeline, build, signing, policy, and deployment definitions;
- no secrets for untrusted fork or pull-request code;
- separate runner pools and network zones by trust;
- ephemeral or verified-clean workspaces;
- pinned actions, plugins, builders, base images, and dependencies according to policy;
- short-lived workload identity with exact issuer, audience, subject, environment, action, and resource;
- non-overwritable artifacts, provenance, signature or attestation verification where required;
- separation of artifact production, approval, and high-risk deployment authority;
- protected environments and immutable audit;
- redaction, secret scanning, rapid revocation, and tested credential-incident response;
- least privilege for CI controller, runner, artifact repository, deployment controller, and observers.

Do not confuse masking with containment. A masked secret may still be exfiltrated over a network, transformed, stored in an artifact, or exposed through a child process. Prefer not issuing the secret.

Supply-chain policy must defend both inputs and the pipeline itself. Verify dependency and builder sources, provenance subject, builder identity, source and configuration, policy version, and artifact digest. A signed malicious artifact remains malicious; signature answers who signed, not whether the content is safe.

### Observability: correlate every boundary

Emit structured events with:

- event, logical change, run, attempt, job, and workspace IDs;
- source and evaluated pipeline revisions;
- runner pool, runner instance, executor and builder image digests;
- cache namespace, key digest, hit/miss, writer trust class, validation result;
- artifact kind, digest, repository, provenance and policy result;
- approval subject, environment, actor class and decision;
- workload principal class, authorization decision and expiry, never token material;
- deployment identity, controller revision, strategy, cohort and transition;
- runtime artifact/config identity and representative user result;
- retry owner, attempt number, timeout class, cancellation phase, unknown-outcome state;
- monotonic duration plus synchronized wall time.

Build dashboards around paths, not isolated component totals:

~~~text
event -> graph -> queue -> runner -> artifact -> approval
      -> accepted deployment -> converged cohort -> verified user
~~~

Alert on symptoms that require action: sustained queue-age SLO burn, no eligible protected runner, artifact identity mismatch, approval of mutable intent, unexpected long-lived credential, duplicate deployment identity, rollout guardrail breach, runtime digest drift, migration incompatibility, and verification failure. Route to the owner and include identifiers and a safe first query.

Avoid alerts for every failed developer test. That is feedback, not necessarily an operator incident. Track it for quality and flakiness, but page when the CI/CD service or protected release path violates a reliability or security promise.

### Capacity: queues reveal the bottleneck

Approximate offered concurrency as:

~~~text
offered concurrency = arrival rate x average service time
~~~

If trusted builds arrive at 0.2 jobs per second and average 120 seconds, mean offered concurrency is 24 runners before headroom, burst, maintenance, retries, or label fragmentation. Average is insufficient: measure percentiles, burst windows, cold starts, setup time, and downstream limits.

Capacity belongs to the whole path. Adding runners may move the queue to package storage, test databases, rate-limited APIs, image pulls, deployment controllers, or review gates. Cache can reduce service time but adds storage, egress, corruption, and trust-boundary cost. Matrix fan-out reduces wall time while increasing total compute and fan-in pressure.

Use quotas and fair scheduling so one repository or retry storm cannot starve emergency releases. Reserve or prioritize carefully; permanent priority lanes can hide under-capacity and create unfairness. Shed optional work before mandatory safety checks.

### Cost: optimize verified flow, not cheapest jobs

Track cost per verified logical change and per successful production deployment, not only runner-minute price. Include:

- compute, memory, accelerators, and idle pre-warm;
- runner image and dependency transfer;
- cache and artifact storage, operations, retention, and egress;
- test environment and database lifetime;
- observability ingestion and retention;
- signing, scanning, policy and secret systems;
- failed attempts, flaky retries, duplicate deployments, and human wait;
- incident, recovery, compliance, and developer-toil cost.

A faster expensive runner may reduce total cost if it shortens scarce environment use and engineer waiting. A high cache-hit ratio may cost more if oversized or unsafe objects are transferred. A very short log retention may appear cheap until an incident cannot be reconstructed.

Cost controls must preserve evidence and safety: right-size pools, autoscale by queue age and readiness, shut down leaked environments through exact ownership records, compress and tier artifacts by policy, reduce redundant matrices based on risk, repair flakes, and make retention explicit. Never save money by weakening isolation, provenance, approval, rollback readiness, or user verification without an accepted risk decision.

### One balanced scorecard

Review these together:

| Dimension | Example signal | Dangerous isolated interpretation |
|---|---|---|
| Flow | lead time, queue age | Faster always means better |
| Reliability | verified release success, SLO burn | Green run equals healthy service |
| Security | policy pass, credential lifetime, trust violations | No detected alert equals safe |
| Quality | flake rate, escaped defects, canary abort | Fewer aborts always means better |
| Capacity | eligible-runner utilization, saturation | High utilization always means efficient |
| Cost | cost per verified change | Lowest compute price wins |
| Recovery | unknown outcomes, rollback exercise result | Rollback script exists, so recovery works |

Improvement is a constrained optimization: deliver useful changes faster while holding reliability, security, correctness, recovery, and sustainable cost within explicit boundaries.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| “The YAML is the pipeline.” | It omits event delivery, controller, runners, caches, identities, repositories, environments, runtime, and users. | Maintain an ownership and data-flow map with trust boundaries. |
| “Green means correct.” | Green reflects declared exit conditions, which may omit subject identity or user verification. | Declare completion invariants and verify the exact runtime subject and user operation. |
| “Rebuild in every environment.” | Staging and production receive different bytes and build inputs. | Build once, publish immutable artifact, promote the same digest. |
| “The tag identifies the release.” | Tags are commonly mutable and resolve at different times. | Bind test, approval, deployment, and runtime to the same immutable OCI manifest digest or typed artifact identity. |
| “Run number identifies the artifact.” | One run can produce many artifacts; an artifact can be copied or overwritten. | Record kind, digest, size, media type, repository receipt, and provenance. |
| “A cache hit proves correctness.” | An incomplete key or lower-trust writer can return incompatible bytes. | Separate trust namespaces, complete keys, validate restored objects, quarantine failures. |
| “Delete cache and retry.” | It removes differentiating evidence and leaves the bad design. | Preserve suspect metadata/object, compare cached and uncached, repair key and validation. |
| “Self-hosted runner is trusted.” | Trust depends on submitters, host access, network, residue, image, and credentials. | Classify pools, isolate workspaces, restrict reachability, use ephemeral or verified cleanup. |
| “Masked long-lived secret is safe.” | Code can transform or exfiltrate it; masking only changes selected log display. | Prefer short-lived workload federation and narrow least privilege. |
| “Approval of the run is approval of release.” | A rerun, mutable tag, configuration, or target can change. | Approve immutable release intent with environment, policy and expiry. |
| “Cancel means stopped.” | Cancellation is a distributed request; child and external operations may continue. | Track acknowledgement at every layer and reconcile side effects before successor ownership. |
| “Timeout means failed.” | The remote service may have accepted or completed the operation. | Persist identity before send, mark unknown, query and reconcile before retry. |
| “Retry is harmless.” | Multiple layers amplify calls and duplicate non-idempotent effects. | One retry owner, idempotency key, bounded attempts, backoff, jitter and overall deadline. |
| “Same commit means retries cannot conflict.” | Attempts can mutate the same tag, environment, migration, or release. | Serialize by real collision domain and retain a stable logical release ID. |
| “Deploy API returned zero, so release succeeded.” | Acceptance is not convergence; convergence is not user success. | Join request receipt, controller state, runtime digest, guardrails, and user journey. |
| “Readiness and liveness are the same.” | Dependency-driven liveness causes restart storms. | Readiness controls traffic; liveness covers local failures restart can safely repair, such as deadlock or stuck loop. |
| “Rollback always fixes it.” | Database, message, and external side effects may be incompatible or irreversible. | Expand-contract, version contracts, test rollback/roll-forward, design compensation. |
| “All retries are one deployment.” | Retry-created real production events disappear from metrics. | Count each accepted production deployment event and correlate under logical intent. |
| “More runners fix every queue.” | Labels, quotas, downstream saturation, and trust classes may be the bottleneck. | Measure queue age and eligible capacity per pool; follow bottleneck through the path. |
| “No log means it never happened.” | Collection, clock, retention, sampling, or query may be wrong. | State source and time range; corroborate with the state owner and audit trail. |
| “Clean everything to recover.” | Broad deletion destroys evidence and may touch unowned state. | Validate exact ownership, quarantine, use dry run, and delete only allowlisted state. |

### Design reviews that prevent these traps

Before merging a protected pipeline change, require reviewers to answer:

1. Which new code becomes executable, and under whose trust?
2. What state, network, socket, device, or credential can it reach?
3. What immutable subject flows across jobs and environments?
4. Are cache and artifact namespaces separated by trust and object type?
5. What happens after timeout, cancellation, runner loss, or duplicate event delivery?
6. Which operation is idempotent, and which component owns retries?
7. What serializes collisions at the external state owner?
8. How does a data or message change stay backward and rollback compatible?
9. What telemetry proves runtime identity and user success?
10. What exact recovery and cleanup paths have been tested?

Treat workflow changes like application changes with production authority. Use branch protection, code ownership, tests, policy evaluation, staged rollout of shared templates, version pinning, changelog, compatibility window, and rollback.

### Prevention must be testable

“Be careful” is not a control. Stronger prevention has an owner, enforcement point, failing test, telemetry, and response. For example:

~~~text
Control: deployment request must contain approved OCI manifest digest
Enforcer: deployment API admission policy
Negative test: mutable tag or mismatched digest is rejected
Telemetry: rejection includes release ID and non-secret reason
Owner: platform delivery team
Exception: expiring, audited emergency policy with later reconciliation
~~~

Test the unsafe branch. A policy that has only ever passed might be disconnected.

## Memory card and retrieval

### The five-line memory card

~~~text
Close inputs: exact event, source, pipeline, dependency, builder.
Separate work: trust-class runner, private workspace, cache is optional.
Bind identity: build once; test, approve, deploy, and run one typed digest.
Control change: short-lived authority, stable operation ID, one retry owner.
Prove outcome: reconcile runtime and data, then verify a user operation.
~~~

If you remember only one diagnostic sentence, use:

> A red or green job is a report from one controller; prove the immutable subject, state owner, accepted side effects, actual runtime, and user result.

### Boundary mnemonic: E-G-R-C-A-I-D-U

- **E — Event:** who caused the run, and was the payload trusted?
- **G — Graph:** which exact definition and dependencies were evaluated?
- **R — Runner:** who executed, in which trust pool and workspace?
- **C — Cache:** what was reused, under which compatibility and writer policy?
- **A — Artifact:** which typed immutable digest was produced and tested?
- **I — Identity and intent:** who was authorized, and what did approval bind?
- **D — Deployment and data:** what operation was accepted and reconciled?
- **U — User:** did the representative operation receive the intended result?

Walk the mnemonic forward during design and backward during incident recovery.

### Sixty-second release explanation

Practise saying:

“A validated event selects exact source and pipeline revisions. The controller creates a dependency graph and schedules each job into an appropriate runner trust pool. Workspaces are private to the job; cache is optional and validated. We build once and publish an immutable typed artifact. Tests, provenance, policy, approval, deployment intent, and runtime all bind to that same digest. The deployment job exchanges short-lived identity, persists an idempotent operation identity, and asks a controller to reconcile a bounded cohort. Runtime identity, compatibility, service guardrails, and a real user check decide promotion. Cancellation, timeout, and retry are reconciled because a UI result does not undo external state.”

### Retrieval questions

Answer without looking, then compare with Complete answers.

1. Why are source revision, pipeline revision, run ID, and artifact digest different identities?
2. Why is cache a performance input rather than release evidence?
3. What must a cache key and namespace represent?
4. Why can two attempts for the same commit conflict?
5. What does a CI timeout prove about a remote deployment?
6. What must approval bind?
7. Which digest should be continuous for one platform-specific container release?
8. Why is an archive checksum not interchangeable with an OCI manifest digest?
9. What is the preferred retry decision when outcome is unknown?
10. How do readiness and liveness differ?
11. When is rollback unsafe?
12. What proves a release beyond controller convergence?
13. How should retry-created real deployments affect deployment frequency?
14. Why can a failed canary be a successful safety outcome?
15. What is the proof limit of this local lab's two runner directories?

### Spaced practice

- After 10 minutes: draw the control, execution, artifact, identity, deployment, runtime, and user path from memory.
- Tomorrow: answer the 15 questions and explain one failure without commands.
- In three days: run the independent lab case and request evidence one owner at a time.
- In one week: map the architecture to a CI/CD product you use without copying provider terms first.
- In two weeks: design a release for an application plus incompatible schema change and defend recovery.

Mark answers as recalled, partially recalled, or looked up. Reading fluency is not retrieval. The goal is to reconstruct the system under pressure.

## Complete answers

### 1. Why are source revision, pipeline revision, run ID, and artifact digest different identities?

The source revision identifies application or infrastructure source content. The pipeline revision identifies executable delivery logic, which can change independently. The run ID identifies one controller execution and its event context. The artifact digest identifies produced bytes or a typed content-addressed object.

One source revision can run through two pipeline definitions, one definition can retry into several attempts, and one run can produce several artifacts. Conversely, an artifact may be promoted through many environments without rebuilding. Collapsing these identities makes it impossible to answer whether a change came from source, build logic, execution environment, or artifact substitution.

A reliable receipt joins all four plus builder, dependency, policy, approval, deployment, and runtime identity.

### 2. Why is cache a performance input rather than release evidence?

A cache returns previously computed data to reduce work. Its hit says an object matched the cache lookup rules; it does not say those rules captured every compatibility input, the writer had sufficient trust, the object is intact, or the current job validated it.

Release evidence must refer to the exact tested and published subject. A cache may help produce that subject, so its key, object digest, provenance and validation belong in the build record. But promotion should rely on the final immutable artifact and evidence, never the fact that cache hit.

On corruption, preserve and quarantine the suspect object, reproduce without it, repair the key or producer, and keep miss behaviour correct.

### 3. What must a cache key and namespace represent?

They represent compatibility and trust. Include every input whose change can invalidate reused output: dependency-lock digest, toolchain or builder digest, operating system, architecture, relevant flags, generator and pipeline versions, job policy, and source scope when required.

The namespace must prevent a lower-trust producer from influencing a higher-trust consumer. An untrusted contribution should not populate the cache used by signing or protected release jobs. Define read/write actors, restore-prefix behaviour, retention, validation, and corruption handling. Hashing an incomplete description only makes the incomplete key shorter.

### 4. Why can two attempts for the same commit conflict?

Commit identity does not identify the mutable side effect. Both attempts may move the same tag, upload the same version, acquire the same environment, change the same load balancer, run the same migration, or publish the same release record.

Cancellation is asynchronous, and the first attempt may still be active after the UI marks it cancelled. Use a concurrency key for the real collision domain, persist one logical release and operation identity, enforce ownership at the external controller, make operations idempotent where possible, and reconcile duplicates before allowing a successor.

### 5. What does a CI timeout prove about a remote deployment?

It proves the client did not receive a satisfactory completion before its deadline. It does not prove the request was rejected, the controller stopped, the rollout failed, or no side effect occurred.

Persist a stable operation or idempotency identity before sending. After timeout, label outcome unknown and query the remote state owner with that identity. If it accepted the request, continue observing or safely cancel and reconcile it. Retry only after proving the operation absent or proving repeat execution idempotent. Keep one overall deadline and one retry owner.

### 6. What must approval bind?

Approval should bind an immutable release-intent object: typed artifact digest, source and pipeline revisions or provenance, evidence and policy version, target environment, configuration and migration intent, strategy and risk, requester, expiry, and any rollback constraints.

It also needs authenticated approver identity, authority, decision time, audit event, and separation of duties where required. Approval of a branch, mutable tag, filename, run page, or “latest” is vulnerable to time-of-check/time-of-use substitution. A later change to the subject or target requires reevaluation.

### 7. Which digest should be continuous for one platform-specific container release?

Use the OCI image manifest digest for that platform-specific runnable image from artifact publication through test subject, policy and approval subject, deployment intent, and runtime readback. If deploying a multi-platform image, state whether policy and deployment bind the image index digest and how the runtime-selected platform manifest is verified.

Do not silently substitute tag, configuration digest, layer digest, or exported archive checksum. Record object type with digest. The invariant is typed identity equality, not similar-looking SHA-256 text.

### 8. Why is an archive checksum not interchangeable with an OCI manifest digest?

An exported archive is a serialized file with ordering, metadata, compression and packaging bytes. An OCI image manifest is a structured registry object referencing configuration and layers. Even when both ultimately describe related filesystem content, their byte sequences and semantics differ, so their digests identify different objects.

A checksum comparison across those types either always fails or encourages an unsafe translation assumption. Verify each object in its own domain and carry one intended release identity through promotion. If a conversion is necessary, produce signed provenance that links input and output and test the output as the release subject.

### 9. What is the preferred retry decision when outcome is unknown?

Do not retry yet. Query the state owner using the original operation identity and correlate audit, controller, runtime and data state. If already committed, return or reconcile success. If active, observe or cancel through the owner. If rejected, correct the request. Retry only when absence is proven and the failure is transient, or repeat execution is demonstrably idempotent.

“GET failed” does not prove “POST absent.” If the status query is also unavailable, bound the blast radius, stop successor operations, preserve the unknown state, and escalate according to the operation's risk.

### 10. How do readiness and liveness differ?

Readiness answers whether this instance should receive traffic now. It may become false for startup, warm-up, overload, missing local prerequisites, or dependency conditions that make serving unsafe.

Liveness answers whether the local process is irrecoverably unhealthy in a way restart can safely repair, such as a deadlock or stuck loop. It should not fail merely because a shared database, DNS service, or remote dependency is down. Otherwise every healthy process restarts during the dependency outage, discarding diagnostics and adding load.

Startup probes or explicit startup gates protect slow initialization from premature liveness actions. None of these alone proves a representative user journey.

### 11. When is rollback unsafe?

Rollback is unsafe when the previous version cannot understand current schema, messages, configuration, state, protocol or external effects; when a destructive migration removed required data; when old code would repeat a non-idempotent action; or when the rollback artifact or configuration is unavailable or unverified.

Use expand-and-contract contracts, compatible readers/writers, versioned messages, idempotent backfill, migration ledgers, invariant checks, retained artifacts, and rehearsed rollback and roll-forward. Choose roll-forward when state crossed an irreversible boundary and a small correction is safer. Use compensation for external effects that cannot be erased.

### 12. What proves a release beyond controller convergence?

Prove the approved artifact and configuration are actually served by all intended instances or traffic cohorts; unexpected or duplicate releases are absent; data and message invariants hold; dependencies and capacity are acceptable; error, latency, saturation, queue and business guardrails pass for a declared population and window; and a representative user operation succeeds.

Also prove short-lived authority expired or was revoked as designed, audit evidence is retained, rollback target remains compatible, and partial work from failed attempts is reconciled. State the time and population because health is not timeless or universal.

### 13. How should retry-created real deployments affect deployment frequency?

Count each accepted production deployment event. Exclude CI attempts that did not create a production deployment. Correlate every event under its logical change or release intent so analysis can distinguish ten changes producing eleven deployment events from eleven independent changes.

Do not collapse a retry-created real deployment merely to improve metrics, and do not let retry storms masquerade as productive delivery. Publish the event definition, accepted boundary, production scope, deduplication rules for duplicate telemetry, and correlation method.

### 14. Why can a failed canary be a successful safety outcome?

The release goal failed, but the containment control succeeded. A small cohort exposed a readiness, runtime, compatibility, performance or user problem before broad promotion. If automation holds or aborts, the known production version remains available and evidence is preserved.

Judge separately: release success, safety-control success, and user impact. Investigate and recover the failed release, but do not weaken a guardrail simply because it correctly stopped a bad candidate. Verify the baseline is healthy so a shared dependency outage is not misattributed to the canary.

### 15. What is the proof limit of this local lab's two runner directories?

They are distinct, private, validated workspace directories owned by the same current Ubuntu user. The lab checks their identities, permissions and expected contents according to its local model. It demonstrates workspace separation and lifecycle guardrails.

It is not a security isolation boundary against another process with the same UID, a malicious learner, repository modification, a compromised kernel, or real runner escape. It does not use separate virtual machines, containers, users, namespaces, credentials, networks, or hosted executors. Production runner isolation must be evaluated against a threat model and independently tested.

### A complete incident answer pattern

Use this compact form in assessments and real reviews:

1. **User operation:** name the impaired promise and scope.
2. **Known observations:** cite source, identity and time.
3. **Competing hypotheses:** include graph, runner, cache, artifact, identity, approval, deployment, runtime and data where relevant.
4. **First discriminating query:** choose the smallest evidence from the state owner.
5. **Safety action:** stop promotion or duplicates without destroying evidence.
6. **Recovery:** explain rollback, roll-forward, compensation or hold and its compatibility assumptions.
7. **Verification:** join immutable intent, actual runtime, data, service guardrails and user journey.
8. **Proof limit:** state what remains unknown.
9. **Prevention:** name enforceable control, negative test, telemetry and owner.

## Product-company interview

Strong candidates do not begin with a favourite tool. They define the user promise, scale, trust boundary, failure model, immutable identities, state owners, recovery, and measurable trade-offs.

### Design prompt: a CI/CD platform for 2,000 engineers

Start by clarifying repository count, languages, event rate, job duration, trust classes, compliance, regions, artifact types, deployment targets, availability target, recovery needs, and whether untrusted contributions exist.

A strong design separates:

~~~text
event ingress and validation
        -> durable run controller and DAG scheduler
        -> trust-separated queues
        -> autoscaled ephemeral executor pools
        -> validated cache and immutable artifact services
        -> provenance, policy and digest-bound approval
        -> short-lived workload identity
        -> environment-scoped deployment controllers
        -> runtime identity, telemetry and user verification
~~~

Discuss partition keys, leases, heartbeats, duplicate event delivery, idempotent graph creation, queue fairness, backpressure, regional failure, metadata durability, artifact replication, audit retention, and disaster recovery. Explain that controller exactly-once is insufficient because external side effects still need stable identity and reconciliation.

Capacity estimate: if a stable measured window has a mean trusted arrival rate of 1.5 jobs per second and mean execution time of 8 minutes, Little's Law gives about 720 jobs in service before burst and headroom. A peak arrival rate or 50th-percentile (p50) duration cannot be substituted into that mean calculation. Size from the arrival and service-time distributions, bursts, cold starts, retry amplification, and target queue-age percentiles. Segment by labels and trust; a single total conceals stranded capacity. Autoscale on queue age plus eligible ready capacity, not CPU alone. Bound retries and downstream quotas.

Security answer: untrusted work receives no production authority, protected workflow code is reviewed, runners and networks are separated, privileged build/signing is narrow, artifacts are immutable with verified provenance, deployments use short-lived identity, and approvals bind exact release intent.

### Incident prompt: pipeline timed out, retry is deploying too

Do not answer “cancel both and rerun.” State that the first operation may be accepted despite client timeout and UI cancellation may not reach the external controller.

Immediate response:

1. freeze automatic retries and further promotion for the collision domain;
2. preserve run, attempt, idempotency, deployment, audit, migration and runtime identifiers;
3. query the deployment controller for both operations;
4. determine artifact/config identity, cohort, traffic, migration and accepted side effects;
5. elect one intended owner and safely stop, compensate or reconcile duplicates;
6. verify runtime, data and user operation;
7. record every accepted production deployment event.

Prevention: stable logical release and operation IDs persisted before send, external idempotency, one retry owner, environment-level concurrency, cancellation acknowledgement, unknown-outcome state, compatible migrations, and duplicate-effect telemetry.

### Debugging prompt: same commit produces two image digests

Offer hypotheses rather than immediately claiming nondeterminism:

- different pipeline or builder revision;
- mutable base image or dependency;
- incomplete cache key or lower-trust cache writer;
- generated timestamp, file ordering, locale, timezone, UID/GID or permissions;
- architecture or build flags;
- untracked or ignored workspace residue;
- network-fetched content;
- different build context;
- tag or repository race;
- comparing manifest, index, archive, configuration or layer digests as though same type.

Close source, pipeline, builder, base image, dependencies, platform and context. Build with cache disabled in clean trusted environments, capture provenance, compare typed object structures, and change one hypothesis at a time. Reproducibility helps, but promotion still requires one selected reviewed immutable artifact.

### Security prompt: allow fork builds and production deploys

Separate them. Fork code runs in an untrusted pool without protected secrets, production network or privileged sockets. Its cache writes cannot influence trusted release jobs. Treat fork-controlled workflow modifications as untrusted.

After trusted review and merge, protected pipeline code builds in a trusted ephemeral pool, publishes immutable artifact plus provenance, evaluates policy, obtains digest-bound approval, and exchanges a short-lived environment-scoped identity. Production deployment authority cannot be reached from the fork execution path. Mention audit, revocation, negative tests and emergency access.

### Reliability prompt: reduce pipeline time by 50 percent

First decompose:

~~~text
event delay + graph delay + queue age + setup + execution
+ artifact transfer + approval wait + deployment + verification
~~~

Measure critical path rather than sum of job durations. Parallelize genuinely independent work, shard deterministic tests with complete fan-in, improve compatible cache reuse, prebuild trusted toolchains, reduce transfer size, right-size executors, pre-warm only constrained pools, remove flakes and redundant work, and use change-aware selection only with a safe fallback.

Preserve mandatory safety checks. Report impact on 50th- and 95th-percentile (p50/p95) lead time, infrastructure failures, escaped defects, flake retries, cost per verified change, queue SLO, and security boundary. Faster feedback that increases false green is not an improvement.

### Data prompt: deploy code with a destructive schema migration

Challenge the premise. Propose expansion and contraction: add compatible schema, deploy dual-compatible code, backfill idempotently, verify invariants, move traffic/readers/writers, observe through rollback window, then remove old schema later. Use a migration ledger, lock or single owner, timeout reconciliation, backup/restore evidence, and roll-forward plan.

If forced by product constraints, reduce cohort and traffic, stop old writers, prove backup and restore time, define an irreversible boundary, obtain explicit risk acceptance, and prepare compensation. Never claim application rollback is available after removing data its old version requires.

### Metrics prompt: compute deployment frequency with retries

Define a deployment event before calculating. Count every accepted production deployment event. Do not count a failed CI attempt that never deployed. Do count an accepted deployment created by a retry, then correlate it under the same logical change or release intent. Separate event deduplication caused by duplicate telemetry from hiding actual repeated deployments.

Pair frequency with lead time, change failure, recovery, user reliability, security and cost. Otherwise a retry storm can inflate frequency while harming the service.

### Interview answer rubric

| Signal | Weak | Strong |
|---|---|---|
| Scope | Names tools immediately | Clarifies users, scale, trust, targets and SLO |
| Architecture | Draws one pipeline box | Draws control, execution, artifact, identity, deployment, runtime and user boundaries |
| Identity | Uses tags and run numbers | Carries typed immutable digest and release intent |
| Failure | Says retry and rollback | Handles unknown outcome, duplicates, compatibility and proof limits |
| Security | Masks secrets | Separates trust and uses short-lived least privilege plus policy |
| Capacity | Adds runners | Estimates arrival/service time and follows downstream bottlenecks |
| Verification | Pipeline green | Joins controller, runtime, data, guardrails and user journey |
| Communication | Lists products | States invariants, evidence, trade-offs and decision |

## Independent transfer and rubric

Independent transfer uses **ASM-0057** and its blank **ASM-0057-response-template.md**. The template is intentionally not an answer key. Mastery requires reviewed learner evidence; a local verifier pass cannot award it.

### Independence gate

Begin from clean lab state in a normal Ubuntu user shell. Record time, timezone, Ubuntu/WSL boundary, UID, physical repository path, required commands, network policy, privilege boundary, abort conditions, cleanup command, and any prior help or fixture source you have seen.

If you already inspected the independent outcome, model source, verifier expectations, or another answer, mark the attempt practice and repeat later with a fresh scenario or reviewer-provided transfer. Honesty about contamination is part of operational trust.

Do not install packages, elevate, contact a hosted service, use credentials, or change the machine to bypass a refusal.

### Capture raw state before interpretation

~~~bash
bash lab.sh check
LAB_DRY_RUN=1 bash lab.sh setup
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
~~~

Save your response outside the guarded lab root. Copy the raw scenario before requesting derived views. Confirm it contains inputs but no diagnosis, derived cache/artifact verdict, recovery, deployment result, verification result, or answer key.

Before another command, write:

1. exact user operation and artifact/environment promise;
2. predicted first failed boundary and state owner;
3. at least three competing hypotheses across different boundaries;
4. a disconfirming observation for each;
5. whether any production transition is authorized now;
6. smallest safe next observation and why.

Save that prediction document outside the lab root, then calculate its byte digest and acknowledge only the digest:

~~~bash
prediction_document='/absolute/path/outside-the-lab-root/asm-0057-prediction.md'
read -r prediction_sha256 _ < <(sha256sum -- "$prediction_document")
printf 'prediction_sha256=%s\n' "$prediction_sha256"
bash lab.sh acknowledge-predictions "$prediction_sha256"
~~~

Replace the example path with the real external document. The controller accepts exactly one lowercase 64-hex SHA-256 value and stores a **prediction_acknowledgment** record with **content_stored=false** and **review_required=true**. Every independent **observe** command refuses until that record exists.

This gate proves only that a syntactically valid digest receipt was recorded before the later controller transitions. The controller does not open the external document, compare its content with your claims, or prove when, by whom, or with what quality it was written. Keep the original timestamped document for reviewer comparison; do not treat the receipt as an answer-quality check.

### Request evidence one owner at a time

Available views are:

~~~bash
bash lab.sh observe graph
bash lab.sh observe runner
bash lab.sh observe cache
bash lab.sh observe artifact
bash lab.sh observe identity
bash lab.sh observe approval
bash lab.sh observe deployment
~~~

Do not dump every view immediately. After each, update the hypothesis table: observation, source and identity, what it proves, what it does not prove, hypothesis status, and next discriminating query. State if two records have different clocks or units.

Before the controlled experiment, write your prediction for incomplete versus complete cache-key behavior and what would disconfirm it. Then run:

~~~bash
bash lab.sh experiment cache-key
~~~

The experiment record must identify **declared_variable=pipeline-definition-digest-in-key**. Its control-prefixed fields omit that definition input and report the modeled stale hit; its treatment-prefixed fields include it and report the modeled miss/current build. Source, lock, runner-image, and job-policy fields remain unchanged; **single_variable_changed=true** states the model's invariant. The record also says **proof_limit=deterministic-local-model-only** and reports zero network, hosted-CI, registry, and cloud calls.

This is one answer-isolated controlled model experiment, not proof about a real cache or root cause. Independent recovery and verification refuse until both prediction and experiment records exist. A rerun that changes time, cache and runner together would not be controlled.

Do not inspect **fixtures/pipeline_model.py** or **verify.sh** during the attempt. They encode the fixture and verifier expectations.

### Write diagnosis and recovery before executing it

Your diagnosis must name first violated contract, trigger, supported mechanism, contributing conditions, user and security impact, known unknowns, and evidence that would change your conclusion.

Your recovery card must name:

- authorized actor;
- exact source and pipeline revisions;
- exact typed artifact digest;
- approval or release intent;
- environment and deployment target;
- preconditions and blast radius;
- concurrency and retry owner;
- timeout and unknown-outcome handling;
- state and evidence to preserve;
- success and abort thresholds;
- rollback, roll-forward, or compensation with compatibility limits;
- representative user verification.

Only then run:

~~~bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
~~~

The last check must prove final absence. If a refusal occurs, preserve it and follow the controller's exact safe response. Do not manually remove controller-owned state.

### Production transfer deliverable

Choose an unfamiliar platform or workload and design:

- untrusted event and protected pipeline boundaries;
- scheduler, queue, trust-separated executor pools, workspace and cache policy;
- build, tests, Software Bill of Materials, provenance, policy and immutable publication;
- short-lived identity, least privilege and digest-bound approval;
- environment configuration, progressive rollout and compatibility;
- idempotency, concurrency, timeout, cancellation, retry and reconciliation;
- observability, audit, DORA definitions and representative user verification;
- capacity estimate, downstream bottlenecks, cost and retention;
- incident recovery, rollback, roll-forward, compensation and proof limits.

Name product-specific mappings only after the portable model is complete.

### Fifty-point reviewer rubric

| Criterion | Points | Full-credit evidence |
|---|---:|---|
| Independent reasoning and identity | 10 | Raw inputs captured first; prediction precedes observation; all pipeline, release and user identities remain separate; competing hypotheses are honestly tested. |
| Mechanism and trust-boundary depth | 10 | Event, scheduler, runner/workspace, cache, artifact, identity, approval, environment, deployment, durable state and user boundaries are accurate. |
| Diagnostic evidence quality | 10 | Controlled experiment; observation versus inference; units, windows and proof limits; honest timeout, retry and concurrency reasoning. |
| Recovery, verification and safety | 10 | Exact authorized bounded recovery; state preservation; abort and rollback/compensation limits; original user operation and cleanup/refusal proven. |
| Production transfer and communication | 10 | Defensible design covers isolation, supply chain, identity, delivery, migrations, observability, DORA, capacity, cost, incidents and limitations. |

Mastery is not merely a total. Any fabricated evidence, bypassed safety refusal, leaked credential, destructive unowned cleanup, mutable approval subject, blind retry of unknown side effects, or claim that the local model proves production safety requires remediation regardless of score.

### Self-review before submission

Check that every conclusion cites an observation or documented contract; every digest states its object type; every time-based metric states window and clock; every retry has one owner; every external mutation has stable identity; every recovery preserves evidence and names abort; every verification reaches actual runtime, data and user result; and every proof states its limit.

## References and review

The reference records below are the chapter's external anchors. They are not substitutes for local architecture, policy, product version, or threat-model evidence.

### Reference map

| Record | Source | Use it for | Do not overclaim |
|---|---|---|---|
| REF-0145 | [NIST SP 800-204D: Strategies for the Integration of Software Supply Chain Security in DevSecOps CI/CD Pipelines](https://csrc.nist.gov/pubs/sp/800/204/d/final) | Threat-informed CI/CD and software-supply-chain security integration | That one control profile fits every organization |
| REF-0146 | [NIST SP 800-218: Secure Software Development Framework 1.1](https://csrc.nist.gov/pubs/sp/800/218/final) | Secure-development practices, roles and organizational outcomes | That compliance alone proves a specific release safe |
| REF-0147 | [GitLab: Security for self-managed runners](https://docs.gitlab.com/runner/security/) | Runner execution, trust and self-managed security considerations | That all executors or configurations provide the same isolation |
| REF-0148 | [GitHub: Workflow artifacts](https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts) | Provider-specific workflow artifact concepts | That workflow artifacts automatically equal immutable production packages |
| REF-0149 | [GitHub: OpenID Connect reference](https://docs.github.com/en/actions/reference/security/oidc) | Provider-specific OIDC claims and workload-identity integration | That merely enabling OIDC creates least privilege |
| REF-0150 | [Jenkins: Pipeline](https://www.jenkins.io/doc/book/pipeline/) | Jenkins pipeline and execution concepts | That plugins, agents and controller security are safe by default |
| REF-0151 | [Microsoft: Secure your Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/security/overview) | Azure Pipelines trust, permission and security guidance | That an existing tenant already implements every recommendation |
| REF-0152 | [DORA software delivery performance metrics](https://dora.dev/guides/dora-metrics/) | Current DORA metric concepts and balanced delivery performance | That locally invented event boundaries are comparable without definition |

Product documentation changes. Verify the currently deployed edition and version when implementing. This lesson's provider mappings are conceptual and no hosted platform was executed to create this chapter.

### Architecture review checklist

- [ ] User operation, environment, reliability objective and threat model are explicit.
- [ ] Trigger payload and executable pipeline revisions are authenticated and protected.
- [ ] Logical change, run, attempt, job, runner, workspace, cache, artifact, approval, deployment and user identities are distinct.
- [ ] Untrusted and protected execution paths cannot share inappropriate authority or cache writes.
- [ ] Runner image, bootstrap, network, socket, device, credential and cleanup boundaries are documented.
- [ ] Cache keys represent compatibility; cache namespaces represent trust; misses remain correct.
- [ ] One immutable typed artifact is built once and promoted.
- [ ] Test, provenance, policy, approval, deployment and runtime bind the same intended digest.
- [ ] Workload identity is short-lived, audience-bound, environment-scoped and least privilege.
- [ ] Approval binds immutable release intent, policy and expiry.
- [ ] Concurrency keys name real collision domains and external owners enforce serialization.
- [ ] Timeouts enter unknown-outcome reconciliation; retries are idempotent, bounded and singly owned.
- [ ] Cancellation acknowledgement and external side-effect reconciliation are observable.
- [ ] Progressive strategy, guardrails, baseline, sample, observation window and abort are defined.
- [ ] Startup, readiness, local liveness and representative user checks have distinct meanings.
- [ ] Database, message, configuration and protocol changes remain compatible through recovery.
- [ ] Rollback, roll-forward and compensation boundaries are tested.
- [ ] Evidence joins controller intent, actual runtime, durable state, telemetry and user result.
- [ ] DORA events, denominators and retry correlation are documented.
- [ ] Queue, runner, repository, deployment, observability and cost capacity are modeled.
- [ ] Evidence retention, redaction, access, backup, restore and exact cleanup are tested.

### Final review questions

You are ready for independent review when you can answer yes:

1. Can I draw every state owner between a source event and user outcome?
2. Can I explain which object each digest identifies?
3. Can I prove why build-once promotion prevents a class of drift?
4. Can I diagnose queue, runner, cache, artifact, identity, approval and deployment failures separately?
5. Can I handle timeout and cancellation without blind retry?
6. Can I choose rollback, roll-forward, compensation or hold from compatibility evidence?
7. Can I distinguish controller success, runtime convergence and user success?
8. Can I define deployment frequency without hiding retries or counting non-deploying CI attempts?
9. Can I state exactly what the local lab proves and does not prove?
10. Can I transfer the model to an unfamiliar product without starting from its YAML syntax?

If any answer is no, return to the corresponding boundary, perform retrieval from memory, then use the evidence table and lab. Do not memorize provider vocabulary in place of understanding the system.

### Chapter completion record

Reading this chapter is exposure. Running the guided lab is supported practice. Passing the fixture verifier proves only the encoded local model. Submissions for ASM-0055, ASM-0056, and ASM-0057 create reviewable evidence; they do not award mastery automatically. Advancement requires satisfactory rubric evidence and every critical safety gate, an independent transfer to an unfamiliar case, delayed recall, repeated incident practice, and reviewer or production feedback according to the program's governance.

Carry one sentence forward:

> Build once, bind every decision to the same immutable subject, reconcile every accepted side effect, and call the release complete only when the user promise is proven.
