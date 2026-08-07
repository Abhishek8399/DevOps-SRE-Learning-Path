---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0070",
  "slug": "devsecops-software-supply-chain",
  "aliases": ["V08-L02", "devsecops-software-supply-chain"],
  "curriculumIds": ["SEC-002"],
  "route": "/book/security/devsecops-software-supply-chain",
  "order": 2,
  "volume": "08-security-engineering",
  "title": "DevSecOps and software supply chains: evidence from source to admission",
  "summary": "Trace software from reviewed source through dependency resolution, isolated build, scanning, SBOM, provenance, signing, verification, admission, runtime inventory, revocation and recovery without treating any single tool result as proof of safety.",
  "domain": "security",
  "level": {"from": "intermediate", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0022", "LES-0023", "LES-0024"],
  "prerequisiteCurriculumIds": ["BLD-001", "CTR-002", "CI-001"],
  "testedEnvironments": [
    {"platform": "Primary and official sources", "version": "NIST SSDF and SP 800-204D, SLSA v1.2, SPDX, CISA, OCI, Sigstore, GitHub, OSV, Kubernetes, OpenSSF and OWASP sources reviewed 2026-08-07", "support": "concept-only", "notes": "Sources support definitions and mechanisms, not a claim that a pipeline or artifact is secure."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic evidence-gate model only; no build, scanner, registry, signer or cluster."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON decisions only; no third-party dependency or network."},
    {"platform": "Representative supply-chain toolchain", "version": "not available", "support": "unsupported", "notes": "No real resolver, scanner, SBOM generator, signing service, registry, admission controller or runtime inventory evidence."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "security-engineer", "release-engineer", "software-engineer", "kubernetes-engineer", "technical-lead"],
  "learningObjectives": [
    "Model the software supply chain as identities, transformations, evidence and policy decisions rather than a list of tools.",
    "Distinguish source revision, dependency graph, build environment, artifact digest, SBOM, provenance, signature, attestation and deployment identity.",
    "Threat-model source, dependency, workflow, runner, registry, admission and runtime boundaries.",
    "Design dependency selection, locking, integrity, license, vulnerability and exception policies with time-bound evidence.",
    "Place secret, source, dependency, IaC, container and deployment checks where each has the evidence it needs.",
    "Explain why a clean scan is neither timeless nor complete and why severity alone is insufficient policy.",
    "Generate and bind an SBOM to the exact artifact while preserving completeness and lifecycle limitations.",
    "Authenticate provenance and verify its subject, builder and build parameters against consumer expectations.",
    "Separate cryptographic signature validity from authorization of the signer and accept immutable artifact identities.",
    "Enforce verification at promotion and admission without creating an unsafe availability or bypass path.",
    "Maintain runtime inventory so vulnerability or revocation information maps to deployed digests.",
    "Recover from a compromised dependency, workflow, builder, signer, registry or artifact with evidence."
  ],
  "productionSignals": [
    "repository path branch review protection and immutable commit",
    "workflow digest action or plugin commit permission set and trigger",
    "runner image digest isolation lifecycle identity network and cache lineage",
    "dependency manifest lockfile version source integrity and transitive graph",
    "scanner version configuration rule pack database timestamp and coverage",
    "finding component reachability exploitability exposure severity owner and exception",
    "builder identity environment digest inputs parameters materials and timestamps",
    "artifact repository media type immutable digest size and registry location",
    "SBOM format tool component identifiers relationships hashes and subject digest",
    "provenance predicate subject builder build type invocation and materials",
    "signature certificate identity issuer key or workload identity and transparency evidence",
    "consumer policy expected repository builder signer workflow source and parameters",
    "promotion approval artifact digest evidence digests exceptions and decision",
    "admission request workload digest policy result latency timeout and failure mode",
    "runtime workload owner artifact digest SBOM mapping exposure and revocation state"
  ],
  "diagrams": [
    {"id": "LES-0070-DIA-001", "title": "Software supply-chain evidence path", "direction": "left-to-right", "boundaries": ["reviewed source", "locked graph", "isolated build", "artifact digest", "SBOM and provenance", "signature and policy", "admission", "runtime inventory"], "evidencePoints": ["commit", "lockfile", "builder", "digest", "subjects", "identity", "decision", "deployment"], "textAlternative": "Reviewed source and locked dependencies enter an isolated build; digest-bound evidence is verified by consumer policy before admission and retained in runtime inventory."},
    {"id": "LES-0070-DIA-002", "title": "Threat paths and control ownership", "direction": "hierarchical", "boundaries": ["developer endpoint", "source host", "dependency ecosystem", "workflow and runner", "registry", "promotion and admission", "runtime"], "evidencePoints": ["actor", "asset", "entry", "control owner", "residual risk"], "textAlternative": "Threats can alter source, dependencies, pipeline logic, builder state, registry objects, policy decisions or runtime references; each boundary needs an owner."},
    {"id": "LES-0070-DIA-003", "title": "Different supply-chain claims", "direction": "hierarchical", "boundaries": ["artifact digest", "component inventory", "known-vulnerability match", "production history", "cryptographic identity", "consumer authorization"], "evidencePoints": ["SBOM", "database time", "provenance", "signature", "policy"], "textAlternative": "An SBOM inventories, a scanner matches time-bound knowledge, provenance describes production, a signature authenticates, and policy authorizes."},
    {"id": "LES-0070-DIA-004", "title": "Consumer verification decision", "direction": "top-to-bottom", "boundaries": ["resolve digest", "authenticate evidence", "match subject", "evaluate builder and source", "evaluate findings", "admit or deny"], "evidencePoints": ["digest", "signature", "subject", "builder", "policy", "receipt"], "textAlternative": "The consumer resolves a digest, authenticates evidence, checks subject and production expectations, evaluates risk policy, then records allow or deny."},
    {"id": "LES-0070-DIA-005", "title": "Vulnerability response from advisory to runtime", "direction": "left-to-right", "boundaries": ["new advisory", "normalize identity", "SBOM search", "deployed digest inventory", "exposure", "contain or patch", "verify"], "evidencePoints": ["advisory", "component", "digest", "workload", "risk", "decision", "SLI"], "textAlternative": "A new advisory maps through component and SBOM identities to deployed digests and owners before risk-based containment, replacement and user verification."},
    {"id": "LES-0070-DIA-006", "title": "Compromise recovery loop", "direction": "cyclic", "boundaries": ["detect", "freeze promotion", "preserve evidence", "scope", "revoke", "rebuild", "verify and restore", "prevent"], "evidencePoints": ["timeline", "denylist", "inventory", "replacement digest", "admission", "SLI", "owner"], "textAlternative": "Containment freezes promotion, scopes affected artifacts, revokes trust, rebuilds from known roots, verifies replacement and rehearses prevention."}
  ],
  "commands": [
    {"id": "LES-0070-CMD-001", "question": "What exact source revision and local changes enter review?", "risk": "read-only", "command": "git rev-parse HEAD; git status --short; git diff --check", "runFrom": "reviewed repository checkout", "expectedBranches": [{"when": "expected commit and clean tree", "meaning": "local source identity is bounded", "nextEvidence": "review and workflow identity"}, {"when": "unexpected or dirty", "meaning": "the proposal differs from reviewed source", "nextEvidence": "stop and reconcile"}], "proves": "selected checkout identity and local state", "doesNotProve": "remote protection, author identity or build output"},
    {"id": "LES-0070-CMD-002", "question": "Is the dependency graph locked and reviewable?", "risk": "sampled-read-only", "command": "npm ci --ignore-scripts --dry-run", "runFrom": "disposable reviewed Node.js repository with documented npm version and no secrets", "expectedBranches": [{"when": "frozen resolution succeeds", "meaning": "one resolver accepts the recorded graph", "nextEvidence": "source integrity and policy checks"}, {"when": "manifest or lock drift fails", "meaning": "graph identity is unresolved", "nextEvidence": "stop before build"}], "proves": "the selected npm resolver can interpret the lockfile without lifecycle scripts", "doesNotProve": "package safety, license acceptability or installed-tree equivalence"},
    {"id": "LES-0070-CMD-003", "question": "What components does the SBOM generator report for the exact artifact?", "risk": "read-only", "command": "syft IMAGE@sha256:DIGEST -o spdx-json=sbom.spdx.json", "runFrom": "approved disposable workstation after replacing placeholders and verifying tool version", "expectedBranches": [{"when": "SBOM completes for expected digest", "meaning": "the tool emitted an inventory claim", "nextEvidence": "validate format completeness and binding"}, {"when": "wrong digest parse failure or coverage gap", "meaning": "inventory cannot support policy", "nextEvidence": "stop and preserve diagnostics"}], "proves": "one tool's component observations for one input", "doesNotProve": "complete components, vulnerability absence, provenance or authenticity"},
    {"id": "LES-0070-CMD-004", "question": "Which known vulnerabilities match this source at this time?", "risk": "sampled-read-only", "command": "osv-scanner scan source -r .", "runFrom": "disposable checkout with pinned scanner and documented database mode", "expectedBranches": [{"when": "results and coverage metadata exist", "meaning": "known records were matched to extracted identities", "nextEvidence": "triage reachability and policy"}, {"when": "unsupported artifact stale data or extraction failure", "meaning": "a clean-looking result is unusable", "nextEvidence": "repair coverage"}], "proves": "time-bound matches from declared scanner and data", "doesNotProve": "absence of unknown flaws, exploitability or complete extraction"},
    {"id": "LES-0070-CMD-005", "question": "Does local image metadata expose the expected digest?", "risk": "read-only", "command": "docker image inspect --format '{{json .RepoDigests}}' IMAGE:TAG", "runFrom": "approved local Docker context with no pull implied", "expectedBranches": [{"when": "expected repository digest is present", "meaning": "local metadata binds a content reference", "nextEvidence": "registry and evidence verification"}, {"when": "tag or digest differs", "meaning": "the reviewed artifact is not selected", "nextEvidence": "stop promotion"}], "proves": "selected local Docker metadata", "doesNotProve": "registry authenticity, signature or deployment"},
    {"id": "LES-0070-CMD-006", "question": "Is the signature valid for the expected identity and issuer?", "risk": "sampled-read-only", "command": "cosign verify --certificate-identity IDENTITY --certificate-oidc-issuer ISSUER IMAGE@sha256:DIGEST", "runFrom": "approved verifier with literal reviewed identity issuer and digest", "expectedBranches": [{"when": "cryptography and identity constraints pass", "meaning": "evidence authenticates under declared trust", "nextEvidence": "verify subject and provenance expectations"}, {"when": "missing invalid or unexpected signer", "meaning": "artifact is unauthorized by this policy", "nextEvidence": "deny and investigate"}], "proves": "Cosign verification under supplied constraints", "doesNotProve": "artifact safety, source review, builder integrity or vulnerability status"},
    {"id": "LES-0070-CMD-007", "question": "Does provenance name the exact artifact and expected source?", "risk": "sampled-read-only", "command": "slsa-verifier verify-image IMAGE@sha256:DIGEST --source-uri SOURCE_URI", "runFrom": "approved verifier after checking current CLI syntax and trust model", "expectedBranches": [{"when": "provenance and expectations pass", "meaning": "subject and source meet selected policy", "nextEvidence": "evaluate builder parameters materials and findings"}, {"when": "subject source or builder differs", "meaning": "evidence is unacceptable", "nextEvidence": "deny"}], "proves": "one verifier result for supplied expectations", "doesNotProve": "source correctness, all build properties or runtime safety"},
    {"id": "LES-0070-CMD-008", "question": "Which Pods declare tags instead of digests?", "risk": "read-only", "command": "kubectl get pods -A -o yaml", "runFrom": "approved read-only cluster context", "expectedBranches": [{"when": "governed workloads use accepted digests", "meaning": "declared references are immutable", "nextEvidence": "compare runtime imageID and admission receipt"}, {"when": "tags or unexpected registries appear", "meaning": "runtime identity can drift", "nextEvidence": "scope before changing"}], "proves": "declared Pod image references and surrounding state", "doesNotProve": "pulled bytes, admission history or complete inventory"},
    {"id": "LES-0070-CMD-009", "question": "What image digest does runtime status report?", "risk": "read-only", "command": "kubectl get pods -A -o json", "runFrom": "approved read-only cluster context", "expectedBranches": [{"when": "imageID matches admitted digest", "meaning": "runtime status reports expected content", "nextEvidence": "map SBOM and user service"}, {"when": "missing or mismatched", "meaning": "inventory is incomplete or drifted", "nextEvidence": "preserve pod and node evidence"}], "proves": "reported identities and state for visible Pods", "doesNotProve": "all nodes, historical instances, admission or process integrity"},
    {"id": "LES-0070-CMD-010", "question": "Would policy reject the tampered fixture?", "risk": "read-only", "command": "conftest test deployment.yaml --policy policy/", "runFrom": "reviewed disposable fixture and pinned policy engine", "expectedBranches": [{"when": "positive and negative fixtures behave as expected", "meaning": "local policy matches examples", "nextEvidence": "shadow admission evaluation"}, {"when": "tampered passes or valid fails", "meaning": "policy or contract is wrong", "nextEvidence": "stop rollout"}], "proves": "local policy behavior for represented fixtures", "doesNotProve": "cluster wiring, full coverage, availability or bypass resistance"},
    {"id": "LES-0070-CMD-011", "question": "Does one SBOM claim the newly disclosed component?", "risk": "read-only", "command": "jq -r '.packages[]' sbom.spdx.json", "runFrom": "validated local SPDX JSON copied from trusted evidence storage", "expectedBranches": [{"when": "component identity matches", "meaning": "this document claims component presence", "nextEvidence": "map subject digest to deployments"}, {"when": "no match", "meaning": "not found in this inventory", "nextEvidence": "check aliases completeness and other artifacts"}], "proves": "a query over one SBOM", "doesNotProve": "runtime absence, non-reachability or vulnerability status"},
    {"id": "LES-0070-CMD-012", "question": "Does the offline model cover every gate and clean exactly?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "LES-0070 support/lab as normal Ubuntu 24.04 user from absent state", "expectedBranches": [{"when": "verify passes", "meaning": "34 branches refusal and cleanup pass", "nextEvidence": "retain model-only boundary"}, {"when": "failure", "meaning": "candidate is rejected", "nextEvidence": "preserve first failure"}], "proves": "deterministic decision ordering and bounded lifecycle", "doesNotProve": "build, scan, SBOM, signature, provenance, registry, admission or production security", "cleanup": "Verifier proves exact state absence."}
  ],
  "labs": [
    {"id": "LES-0070-LAB-001", "title": "Guided supply-chain evidence-gate model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; no supply-chain products", "timeMinutes": 240, "privilege": "normal user; root refused", "network": "none", "changes": ["one UID-scoped temporary root", "one copied synthetic 34-case fixture"], "abortConditions": ["root", "credential", "endpoint", "registry", "cluster", "symlink", "wrong owner", "unknown artifact"], "recovery": "Preserve first failure and remove only exact allowlisted state.", "cleanupProof": "Exact inventory followed by root absence.", "path": "drafts/LES-0070-devsecops-software-supply-chain/support/lab"},
    {"id": "LES-0070-LAB-002", "title": "Independent tampered-artifact rejection and recovery", "mode": "independent", "environment": "Reviewer-owned disposable local repository, registry and Kubernetes cluster with synthetic code", "timeMinutes": 240, "privilege": "normal-user developer and namespace-scoped deployer; reviewer owns trust roots and faults", "network": "isolated local only", "changes": ["synthetic source dependencies artifacts and evidence", "tamper revocation and advisory faults"], "abortConditions": ["production", "public registry", "real secret", "customer data", "broad credential", "mutable promotion", "unknown cleanup"], "recovery": "Freeze promotion, preserve evidence, deny digests, rebuild from trusted roots, verify and restore synthetic service.", "cleanupProof": "Reviewer proves repos, runners, images, evidence, identities, namespaces, policies, ports and caches absent.", "path": "drafts/LES-0070-devsecops-software-supply-chain/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0070-INC-001", "signal": "A dependency release contains malicious install behavior.", "firstThought": "This may be code execution in developer and builder environments, not only an application CVE.", "safePath": "Freeze resolution, preserve lock and runner evidence, scope fetched versions and hooks, revoke exposed authority, replace and rebuild cleanly.", "trap": "Run the package manager on every shared runner to reproduce it."},
    {"id": "LES-0070-INC-002", "signal": "A signature verifies but provenance names a different subject digest.", "firstThought": "Cryptography succeeded for a statement that is not bound to this candidate.", "safePath": "Deny, preserve all digests and verifier output, investigate substitution, then rebuild and re-verify every binding.", "trap": "Accept because the signer is trusted."},
    {"id": "LES-0070-INC-003", "signal": "A scanner reports zero critical findings after failing to parse the lockfile.", "firstThought": "This is missing coverage, not a clean result.", "safePath": "Fail required coverage, record tool/data identities, repair extraction, compare expected component count and rerun.", "trap": "Publish the green badge."},
    {"id": "LES-0070-INC-004", "signal": "A trusted workflow produces unexpected artifacts after runner compromise.", "firstThought": "Reviewed source cannot explain builder-controlled output.", "safePath": "Disable runner and promotion, revoke authority, scope artifacts, deny digests, rebuild on fresh attested infrastructure and reconcile deployments.", "trap": "Rerun the commit on the same persistent runner."},
    {"id": "LES-0070-INC-005", "signal": "A critical advisory appears in hundreds of SBOMs.", "firstThought": "Inventory presence begins prioritization; deployment, exposure and reachability decide urgency.", "safePath": "Normalize identity, map deployed digests and owners, classify exposure, contain high-risk paths, rebuild and verify rollout.", "trap": "Patch every repository alphabetically."}
  ],
  "assessmentIds": ["ASM-0193", "ASM-0194", "ASM-0195"],
  "referenceIds": ["REF-0808", "REF-0809", "REF-0810", "REF-0811", "REF-0812", "REF-0813", "REF-0814", "REF-0815", "REF-0816", "REF-0817", "REF-0818", "REF-0819", "REF-0820", "REF-0821", "REF-0822"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline model performs no build, scan, SBOM generation, signing, attestation, registry, admission or runtime inventory operation.",
    "No representative ecosystem, CI platform, builder, registry, cluster or policy engine was exercised.",
    "Tool syntax, schemas, vulnerability data, hosted features and trust models are version-dependent.",
    "A passing pipeline cannot prove absence of malicious code, unknown vulnerabilities or compromised trust roots.",
    "Formal review, independent transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# DevSecOps and software supply chains: evidence from source to admission

> A pipeline is not secure because it contains security tools. It becomes defensible when every transformation has a named input, accountable executor, immutable output, authenticated evidence, explicit consumer policy, recorded decision and rehearsed revocation path.

## What you see and first thought

### A green scan is a bounded claim

You open a pipeline and see green jobs for secrets, dependencies, source, infrastructure and an image. Pause before saying “secure.” Ask:

**Which exact artifact are we about to run, where did it come from, and what evidence lets this consumer trust it?**

A green job may be accurate yet irrelevant. It may have scanned another commit. A tag may have moved after scanning. The SBOM may describe a different digest. A valid signature may belong to an identity that is not authorized to release this service. A parser may have skipped the lockfile and produced zero findings. Admission may exclude one namespace. A node may still run an older digest.

Translate every “passed” into this sentence:

> Tool T, version V, configuration C and knowledge time K examined input I, produced result R, and policy P made decision D.

If an item is missing, the badge is weaker than it looks.

### Follow one immutable identity

For a container, follow `registry/repository@sha256:…` rather than `repository:latest`. Look for the same digest in:

1. build output;
2. SBOM subject;
3. provenance subject;
4. signature or attestation;
5. promotion record;
6. admitted workload;
7. runtime `imageID`;
8. deployment inventory used during response.

Matching does not prove the bytes are harmless. It proves the evidence concerns the bytes you intend to use. Without this binding, teams can make correct statements about the wrong object.

### First-response wisdom

If a dependency looks malicious, do not reproduce it first on a privileged shared runner. Package installation may execute lifecycle hooks. Freeze new resolution, preserve manifest, lockfile, package source, runner and egress evidence, then investigate without credentials in a disposable environment.

If a signature fails, deny the candidate. Never compensate by deploying a mutable tag. Determine whether the cause is missing evidence, wrong digest, unexpected identity, revoked trust, transparency failure, time error or policy mismatch.

If a scanner reports no findings after an extraction warning, the state is **coverage failure**, not **clean**.

If admission is unavailable, the failure mode is both a security and reliability decision. Design fail-open, fail-closed and emergency behavior per risk tier before the outage. Every bypass must be narrow, authenticated, expiring and audited.

## Terms before commands

### Supply chain and DevSecOps

The **software supply chain** includes every actor, system and transformation that can influence software: developer endpoint, source host, dependencies, registries, workflow definitions, actions/plugins, runners, compilers, base images, builders, artifact stores, signing identities, policy services, deployment controllers and runtime nodes.

It is a graph. One application can contain thousands of transitive components. A CI action has its own dependencies. A builder image is also an artifact with an origin. A generated file may come from a tool that was never declared.

**DevSecOps** means engineering security responsibilities and feedback into delivery with shared ownership and automation. It does not mean “security owns a final scan,” nor “developers operate every scanner.” Good DevSecOps provides safe defaults, fast relevant feedback, centrally governed high-consequence boundaries, durable promotion evidence, expiring exceptions and tested incident paths.

Security cannot only “shift left.” Some evidence exists only after build; some controls belong at promotion, admission and runtime. Use the earliest useful feedback and the latest independent enforcement.

### Manifest, lockfile and graph

A **manifest** states dependency intent, often with version ranges. A **lockfile** records one concrete resolution, usually exact direct/transitive versions plus source or integrity information. The **resolved graph** is what a particular resolver version and configuration selected.

A lockfile improves repeatability and incident search. It does not prove a package is benign, registry delivery is authentic, a name maps to the intended project, or lifecycle scripts are safe. Generate it intentionally, review it with the manifest and make CI reject silent rewrites.

### Artifact, tag and digest

An **artifact** is produced content: binary, package, archive, image, chart, model or bundle. A **tag** is a convenient mutable pointer. A **digest** is a content-derived identity for a defined representation.

Remember: **a tag says what a name points to now; a digest says which content was resolved.** Record repository and media type too. An OCI multi-platform index and its platform manifest have different digests.

### SBOM and scanner

An **SBOM** is structured inventory evidence: components, identifiers, versions, suppliers, relationships and sometimes hashes. SPDX and CycloneDX are common formats. An SBOM is not a vulnerability report, proof of completeness, proof a component executed, provenance, a signature or a policy decision.

A scanner uses evidence and a knowledge base to report matches. Common categories:

- **SAST:** patterns and flows in source or intermediate form;
- **SCA:** third-party component identity, vulnerability and policy concerns;
- **secret scanning:** credential-shaped material and sometimes validity;
- **IaC scanning:** configuration rules over proposed infrastructure;
- **image scanning:** packages/files observed in image content.

Each sees a different representation. Source scanning misses packages added by a base image. Image scanning may not understand application reachability. IaC scanning cannot prove the provider applied the same plan. Overlap the claims; do not merge the badges.

### Vulnerability, exploitability, exposure and risk

A **vulnerability** is a weakness. A scanner often matches component identity/version to known records. **Exploitability** asks whether an attacker can exercise it in this build. **Exposure** asks whether the path is reachable by relevant actors. **Risk** combines likelihood and impact in context.

Severity is input, not destiny. An internet-facing remotely exploitable issue in a privileged service can outrank a numerically higher finding in unreachable test code. “Unreachable” must be bound to digest, configuration, environment and evidence because releases change.

### Provenance, attestation, signature and authorization

**Provenance** describes production: subject digest, builder, build type, invocation and materials. An **attestation** is an authenticated statement about a subject using a defined predicate such as provenance, an SBOM or a result.

A digital **signature** authenticates bytes or a statement under a cryptographic trust model. It does not answer whether the signer was allowed to release this service. That is authorization:

> Is identity I allowed to produce artifact A from repository R through workflow W for environment E now?

A compromised valid key can sign malware. An authorized builder can make a mistake. Verify cryptography, identity, scope, provenance expectations and policy.

### SLSA, promotion, admission and revocation

SLSA provides specifications and increasing build-assurance requirements. It helps producers express provenance and consumers verify expectations. A level is not a universal safety score and does not replace source security, vulnerability management or runtime controls.

**Promotion** moves an already-built immutable artifact into a more trusted state. **Admission** evaluates a proposed API object before persistence. Both are consumer boundaries: producers supply evidence; consumers decide acceptance.

**Revocation** withdraws trust from a key, certificate, identity or builder. A **digest denylist** blocks specific content even if old evidence once passed. A design is incomplete until trust can be withdrawn quickly.

## Architecture map

### End-to-end evidence path

```text
reviewed commit -- workflow@immutable-id -- locked dependency graph
       \                    |                    /
        +------- isolated least-privilege builder
                              |
                    artifact@digest
                    /      |       \
                 SBOM  provenance  scan result
                    \      |       /
                 authenticated evidence
                              |
                  consumer verification policy
                              |
                     promotion decision
                              |
                admission resolves and verifies
                              |
                     runtime image identity
                              |
                digest/SBOM/workload inventory
```

At each arrow ask:

1. **Identity:** exact input and output?
2. **Authority:** who may transform it?
3. **Evidence:** which durable record supports the claim?
4. **Recovery:** how is trust removed?

### Producer, distributor and consumer

The **producer** reviews source and creates artifact plus evidence. The **distributor** stores and serves them. The **consumer** resolves an immutable artifact, authenticates evidence and applies acceptance policy.

Do not let the producer be the only enforcement point. If a compromised pipeline can create malware and mark its own checks green, an independently governed consumer policy must constrain trusted source, builder and signer identities. A successful registry push proves storage, not approval.

### Evidence graph

Store relationships rather than an evidence pile:

```text
commit C
 -> workflow W@digest
 -> materials M1..Mn@digests
 -> builder B@identity
 -> artifact A@digest
 -> SBOM S says subject A
 -> provenance P says subject A, source C, builder B
 -> signature authenticates A or P as identity I
 -> policy Q allows I/B/C and finding set F
 -> decision D admits A to environment E
 -> workload R reports A at runtime
```

If you retain files without these edges, responders must reconstruct the graph during an incident.

### Separation and operating cost

Source review, builder, signing identity, artifact store, policy definition, promotion authority, deployment authority and runtime inventory should have explicit ownership. Separation reduces the chance one stolen credential can rewrite, build, sign, promote and erase evidence.

It also introduces production dependencies. Identity issuers, transparency services, evidence stores and admission webhooks consume latency and capacity. Monitor them, provide rollback and test outages. A security control that regularly blocks legitimate recovery will attract unsafe bypasses.

## Request or state path

### Source and workflow

A release begins with an authenticated subject and immutable source revision. Branch and pull-request names are navigation; the reviewed object is a commit. Protection must cover merges, required reviews, status checks, workflow changes and emergency overrides.

Workflow code is production code. It may read secrets, mint identity tokens, publish artifacts and change environments. Pin actions, plugins, templates and builder images to immutable identities. Keep a friendly version label in a comment or automated update record, but execute the reviewed commit or digest.

Fork and pull-request workflows are dangerous when untrusted content enters shell commands, paths, generated configuration or caches. A job with secrets or write authority must not execute contributor-controlled code merely because someone clicked approve without understanding trigger semantics.

### Dependency resolution

Resolution consumes manifest, lockfile, resolver version, registry configuration, namespaces, credentials, platform markers, caches and network responses. Capture the resulting direct/transitive graph, exact source and integrity data. CI should enforce the lock, not silently repair it.

Restrict public fallback where private namespaces are expected. Otherwise a dependency-confusion package can win resolution. Review a new dependency more deeply than a routine patch: necessity, maintainer identity, project history, transitive fan-out, install scripts, license, repository signals, replacement options and removal cost. OpenSSF Scorecard is useful evidence, not an approval oracle.

### Builder

Start privileged builds from a known image/environment. Give the job only required inputs, short-lived identity, constrained egress and an end-of-job lifecycle that leaves no attacker-controlled state for another job.

**Isolation** stops jobs affecting one another beyond explicit stores. **Hermeticity** means declared inputs, not undeclared host/network state, supply dependencies. **Reproducibility** means repeating defined inputs/process produces equivalent output. These reinforce each other but are not synonyms.

A reproducibility mismatch can be innocent timestamps or ordering, an undeclared input, or tampering. Define what representation must match and any canonicalization before claiming equivalence.

### Artifact and evidence creation

Generate an SBOM from the final artifact when possible. Source manifests describe intent; artifact analysis describes what the generator observed after build. Keep both if they answer distinct questions.

Generate provenance inside or through the trusted build platform. A job-authored JSON file may be syntactically valid but offers little assurance if arbitrary job code can invent its builder identity. Bind every statement to the output digest.

For scan evidence record input digest, scanner/version, configuration, rule pack, extraction coverage, knowledge-base revision/time, results and operational errors. Authenticate evidence used by policy so it cannot be swapped after the job.

### Verification, promotion and admission

The consumer should:

1. resolve candidate to an immutable digest;
2. retrieve evidence associated with that digest;
3. authenticate it against configured trust roots;
4. require every statement subject to equal the candidate;
5. compare source, builder, workflow, materials and parameters with expectations;
6. evaluate vulnerabilities, licenses and exceptions with a versioned policy;
7. record allow/deny plus inputs and policy version;
8. promote that same digest.

Verify close enough to use that a tag or evidence object cannot be replaced afterward.

Admission must inspect resolved content and authenticated evidence, not labels a workload author can set. Cache results by artifact digest and policy version; invalidate when policy, trust or revocation changes. Observe latency, errors, timeouts and bypasses. Emergency authority must be narrow, expiring and linked to a change or incident.

### Runtime inventory

Capture declared image reference and runtime-reported `imageID`. Map digest to cluster, namespace, workload, owner, environment, SBOM and evidence. This converts “a CVE exists” into “these deployed digests and user journeys may be affected.”

Inventory is changing state. Reconcile deleted workloads and restarts, record freshness, and expose gaps. A six-hour-old list may be unacceptable during an actively exploited incident.

## Failure zoom

### Source or review compromise

An attacker can steal a developer token, compromise a maintainer, alter protection or modify workflow code. Signed commits improve attribution/integrity but do not make a malicious change safe.

Preserve commit/parent, review identities/times, policy changes, workflow diff, identity/source audit and descendant build/artifact identities. Freeze affected release paths, revoke compromised authority and deny descendant artifacts. Do not destroy branches or logs before scoping.

### Dependency compromise

Threats include maintainer takeover, malicious release, typosquatting, dependency confusion, registry compromise and vulnerable transitive code. Integrity hashes detect bytes differing from the recorded resolution; they do not make intentionally locked malicious bytes safe.

Package installation may execute lifecycle code before the application exists. Investigate suspicious packages in a disposable no-secret environment with bounded egress and no shared cache. Determine which developers, runners and releases actually fetched or executed the component.

### Workflow, cache and runner compromise

A reusable action referenced by a mutable tag can change without a repository diff. Untrusted issue text can become a shell program. A broad workflow token can publish releases. A cache writable by untrusted jobs can inject tools into privileged builds.

Pin external execution, minimize token permissions, separate untrusted testing from release, pass untrusted values as data rather than interpreter text, and prevent low-trust writers from feeding high-trust caches.

A compromised runner can alter compiler output, steal secrets, forge local result files and persist. Prefer ephemeral runners for privileged work, protect bootstrap and image supply chains, restrict metadata/egress, and use short-lived workload identity. The build platform should issue trustworthy provenance independently of arbitrary job assertions.

### Registry or evidence substitution

Tags can retarget after scan. An SBOM stored by filename can be moved beside another image. OCI referrers help discover related artifacts but do not remove the need to authenticate evidence and compare the subject.

Use digests, repository scoping, authenticated transport, protected deletion/retagging, replicated evidence and audit. Exercise registry outage, tag substitution and orphan-evidence cases.

### Signer or builder compromise

Signing authority is high impact because consumers automate trust. Protect it with workload identity, short lifetime, least privilege, isolated issuance, audit and separation from arbitrary job code.

On compromise, revoke authority and deny artifacts in the affected builder/run/time scope. Re-signing unknown bytes does not heal them. Rebuild reviewed source and materials on known-clean infrastructure, produce new evidence and deploy a new digest.

### Policy/admission failure

Policy can be wrong, stale, unavailable or bypassed. A broad allow is no control for that scope. A fragile deny service can block restoration and encourage permanent bypasses.

Version and review policy, test allowed/denied/error fixtures, run shadow mode, canary enforcement, measure decisions and predefine failure behavior. Protect policy distribution and verifier trust configuration as supply-chain artifacts too.

### Scanner “success” with no coverage

Watch for unsupported manifests, database-update errors, direct-only analysis, wrong ecosystem mapping, base-distribution mismatch, broad suppressions and source/image identity drift. A gate needs distinct outcomes:

- pass;
- findings fail;
- operational error;
- not applicable;
- incomplete coverage.

Never convert all “no finding objects” into green.

## Internals and state ownership

### Content addressing: bytes of what?

A digest maps bytes to a fixed-size identity. Verification recomputes the digest for the precisely defined object. The important phrase is **defined object**. OCI has indexes, manifests, configurations and layers, each with descriptors and digests. An unpacked filesystem is not simply one of those hashes.

Content addressing supplies integrity and identity within the scheme. It does not identify a producer or establish safety.

### Decode Cosign verification

Verification may require signed payload, signature, public key/certificate chain, roots/issuer, identity constraints, transparency evidence, time/revocation semantics and authorization policy.

“Certificate issued by this provider” is often too broad. Constrain expected repository/workflow/service identity according to the verifier’s model. First authenticate; then authorize that identity for this artifact and environment.

### Provenance fields

The **subject** is the output described by digest. **Materials** are inputs such as source revision or dependency artifacts. **Builder identity** names the platform. **Build type** names the process contract. Invocation describes parameters and environment.

Consumer questions:

- Subject equals candidate?
- Builder trusted for this repository?
- Expected source and commit?
- Dangerous parameters absent?
- Materials allowed and immutable?
- Claimed assurance applies to this path?

Authenticated provenance can reveal an unsafe build. That is a success: trustworthy history gives policy enough evidence to deny.

### SBOM identity

Display name alone is weak identity. Useful fields may include ecosystem coordinates, package URL, version, supplier, hashes, CPE where appropriate and a document-local identifier. Relationships preserve “depends on,” “contains” and generated relationships.

False negatives often come from identity mismatch. Retain raw fields while normalizing aliases. False positives occur when a heuristic maps the wrong vendor/product. Correct or narrowly suppress that mapping; do not globally ignore an identifier.

### Time-varying vulnerability state

A scan is a query at time `t`. Advisories are published, revised and withdrawn later. Reevaluate stored SBOMs when intelligence changes instead of rebuilding merely to rediscover inventory.

Store source/revision/time, component identity, match and coverage, exploit/reachability evidence, triage, exception and reevaluation time.

### Policy code, data and owner map

Policy code defines logic; policy data names trusted registries/builders/signers, thresholds, exceptions and environment rules. Version, review, test and audit both. Prefer structured denial reasons over one boolean, and never log tokens or secret values.

| State | Authority | Main recovery concern |
|---|---|---|
| Commit/review | Source platform | Account or protection compromise |
| Lock and graph | Repository/resolver contract | Source substitution |
| Runner image/config | CI platform | Persistent contamination |
| Artifact/digest | Registry | Retag, deletion, outage |
| SBOM/provenance/result | Evidence producer/store | Forgery or subject mismatch |
| Roots and signer allowlist | Security/platform authority | Rotation/revocation |
| Promotion | Release plane | Stale decision/bypass |
| Admission | Cluster policy plane | Timeout/failure mode |
| Runtime inventory | Inventory owner | Staleness and missing mappings |

## Evidence table

| Question | Starting evidence | Proves | Does not prove |
|---|---|---|---|
| Which source was reviewed? | Commit, parent, reviews, protection event | Selected immutable source and review | Correctness or uncompromised reviewers |
| Which graph was selected? | Manifest, lock, resolver/version, source config | Recorded resolution | Benign packages or installed completeness |
| What executed the build? | Builder identity, image, workflow, provenance | Claimed/observed production path | No builder compromise beyond supported assurance |
| Which artifact? | Repository, media type, digest | Content identity in that system | Producer identity or safety |
| What components? | Subject-bound SBOM and generator metadata | Tool observations | Complete inventory or vulnerability absence |
| Which known findings? | Tool/config/data time/input/coverage/results | Time-bound matches | Unknown flaws, exploitability or impact |
| Who authenticated it? | Verified signature/certificate/identity | Cryptographic validity under selected roots | Authorization or correctness |
| How was it made? | Authenticated subject-matched provenance | Declared trusted production history | Safe code or acceptance |
| Why allowed? | Policy/version/inputs/exceptions/receipt | Consumer decision then | Future safety or runtime state |
| What runs? | Workload, admission receipt, runtime `imageID` | Selected declared/reported identity | All history or process integrity |
| What is affected? | Advisory + SBOM/digest/deployment inventory | Mapped exposure candidates | Actual exploitability |
| Can trust be removed? | Revocation/denylist propagation test | Tested containment mechanism | Every unobserved copy removed |

Evidence has different freshness. A commit digest remains stable. Vulnerability results age immediately. A signature can remain cryptographically valid after its signer should no longer be trusted. A policy decision can become invalid when an advisory or denylist changes. Give each claim its own expiry and reevaluation trigger.

### Minimum incident evidence packet

For every production artifact keep enough to answer:

- candidate repository, media type and digest;
- source repository and commit;
- workflow/builder identities and run;
- input material identities;
- SBOM/provenance/result digests and subjects;
- verified signer identity and trust policy;
- promotion/admission decision;
- environments and workloads running it;
- current owner and rollback/replacement;
- exceptions and expiry.

Do not put credentials, source secrets or sensitive SBOM access details in a broadly visible ticket. Preserve them in an approved evidence store and link by controlled identity.

## Command decoders

### Commands are questions

The metadata above contains twelve command cards. Placeholders such as `IMAGE`, `DIGEST`, `IDENTITY` and `ISSUER` are intentionally non-executable. Confirm current product syntax and use a disposable or authorized environment.

### Git identity

```bash
git rev-parse HEAD
git status --short
git diff --check
```

`rev-parse` names the current commit. `status --short` exposes uncommitted inputs. `diff --check` finds whitespace errors, not security defects. If the tree is dirty, evidence attached only to `HEAD` does not identify the actual build input.

### Frozen resolution

```bash
npm ci --ignore-scripts --dry-run
```

`npm ci` expects a lock-governed install. `--ignore-scripts` reduces lifecycle execution for this diagnostic. `--dry-run` reports intended operations; exact behavior depends on npm version. Network and registry credentials may still be involved. This is not a safety proof.

### SBOM generation

```bash
syft IMAGE@sha256:DIGEST -o spdx-json=sbom.spdx.json
```

The immutable image reference identifies input. Output format determines the schema. Tool version/catalogers affect inventory. Validate JSON/schema, creation metadata, relationships, component count and subject binding. A successful empty document is not success.

### Vulnerability query

```bash
osv-scanner scan source -r .
```

Record scanner version, configuration, database/network mode and discovered inputs. Package identity extraction precedes vulnerability matching, so coverage errors invalidate a clean claim. Be cautious with automated remediation on untrusted projects because package-manager operations can execute project code.

### Signature verification

```bash
cosign verify \
  --certificate-identity IDENTITY \
  --certificate-oidc-issuer ISSUER \
  IMAGE@sha256:DIGEST
```

Identity and issuer constraints express who you expected. Do not broaden them to make a failure disappear. After cryptographic verification, inspect claims and apply authorization: allowed repository, workflow, builder, artifact and environment.

### Provenance verification

```bash
slsa-verifier verify-image \
  IMAGE@sha256:DIGEST \
  --source-uri SOURCE_URI
```

Version-check this example before use. Verification should authenticate provenance, match the subject and evaluate source/builder expectations. It cannot prove source correctness, absence of vulnerabilities or runtime behavior.

### Declared versus running image

```bash
kubectl get pods -A \
  -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\n"}{end}{end}'
```

This shows ordinary container declarations, not init/ephemeral containers. A tag is mutable. Compare selected runtime status:

```bash
kubectl get pods -A \
  -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .status.containerStatuses[*]}{.imageID}{"\n"}{end}{end}'
```

Runtime formats vary and missing status may mean not started. Neither query proves admission verification; correlate policy/audit evidence.

### Offline model

```bash
cd drafts/LES-0070-devsecops-software-supply-chain/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate signature-unverified
bash lab.sh evaluate signer-not-authorized
bash lab.sh cleanup
```

The first case means authentication is absent or invalid. The second means authentication passed but the identity lacks authorization. Keeping those separate prevents “signed equals trusted.”

## Decision path

### Release gate

```text
1 Can I name the immutable candidate digest?
  no -> stop
2 Can I name reviewed source and locked materials?
  no -> stop or explicitly classify untraceable origin
3 Was workflow/builder authorized and isolated?
  no -> rebuild on trusted infrastructure
4 Are required checks complete, current and subject-bound?
  no/error -> not a pass
5 Are SBOM/provenance authenticated and subject-matched?
  no -> deny
6 Are signer, builder, source and parameters allowed?
  no -> deny even when cryptography is valid
7 Are findings acceptable or narrowly excepted?
  no -> remediate or obtain authorized risk acceptance
8 Does promotion/admission enforce the decision?
  no -> evidence is advisory
9 Can runtime identity be found and trust revoked?
  no -> release creates unmanaged risk
10 Record, deploy same digest and verify user outcome
```

### Finding triage

For every finding establish component/code/config identity, affected range, location (developer/build/image/runtime), reachable entry, required privilege, exploit signal, confidentiality/integrity/availability impact, containment, owner/deadline, exception and proof the replacement is deployed.

Do not allow “not exploitable” to become permanent copied text. Bind the conclusion to artifact digest, configuration, environment, evidence and reevaluation condition.

### Exception gate

A defensible exception includes rule/finding ID, exact artifact/component/environment, reason, compensating controls, authorized risk owner, creation/expiry, remediation plan, monitoring and reevaluation triggers.

An ignore file with no owner and expiry is hidden acceptance. A false-positive suppression needs the same care because an overbroad pattern may hide a later true finding.

### Tool or service selection

Hosted signing/attestation reduces direct key handling but depends on provider identity, availability, features and trust model. Self-managed systems offer control but require root protection, upgrades, backups, HA and incident response. Choose the design whose roots, failures and recovery the organization can operate and explain.

## Guided Ubuntu lab

### What this lab teaches

This lab is a decision simulator, not a fake scanner. It makes you predict which boundary fails first when evidence is missing or mismatched. That ordering matters in production: there is no value debating a medium CVE if the artifact has no trustworthy identity.

It writes only a UID-specific directory under `/tmp`, uses Python's standard library, makes no network call and refuses root or selected external credentials.

### Preflight

Run from Ubuntu 24.04 as your normal user:

```bash
cd drafts/LES-0070-devsecops-software-supply-chain/support/lab
pwd
id
bash lab.sh doctor
```

Expected shape:

```text
model=valid cases=34
doctor=pass network=none user=1000
```

Your UID may differ. Stop if `id -u` is `0`, the path is not the LES-0070 lab, or doctor reports a boundary failure. Do not bypass guards.

### Predict before setup

Write down:

- why the baseline needs both `signature_verified` and `signer_policy_bound`;
- why `sbom_generated` and `sbom_artifact_bound` are separate;
- why runtime inventory follows admission;
- which check should fail before vulnerability policy when scanner identity is unknown.

Now initialize copied state:

```bash
bash lab.sh setup
bash lab.sh status
```

Expected:

```text
setup=pass state=/tmp/reliability-atlas-les0070-supply-chain-<uid>
status=ready cases=34 state=/tmp/reliability-atlas-les0070-supply-chain-<uid>
```

### Walk the chain

```bash
bash lab.sh evaluate baseline
bash lab.sh evaluate dependency-graph-unlocked
bash lab.sh evaluate scanner-version-unknown
bash lab.sh evaluate sbom-for-other-digest
bash lab.sh evaluate provenance-subject-mismatch
bash lab.sh evaluate signature-unverified
bash lab.sh evaluate signer-not-authorized
bash lab.sh evaluate admission-check-bypassed
bash lab.sh evaluate deployment-inventory-stale
```

Expected boundary names are respectively `admissible`, `dependency-lock`, `scanner-identity`, `sbom-binding`, `provenance-binding`, `signature-verification`, `signer-policy`, `admission-policy` and `runtime-inventory`.

Use `show` to inspect resolved state:

```bash
bash lab.sh show provenance-subject-mismatch
```

Notice later booleans remain true. The model still stops at the first failed prerequisite. This prevents risk-score averaging: a valid signer cannot compensate for evidence attached to a different subject.

### Refusal and cleanup

The verifier intentionally creates an unknown file and proves the lab refuses to operate until the harness removes that exact injected fixture. Then it cleans known files and proves absence:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=34 refusal=true cleanup=true
```

Passing proves only 34 deterministic branches and safety lifecycle on this machine. It proves no real build or security product.

### Explain it back

After the run, say this without looking:

> First bind reviewed source and workflow. Freeze dependency identity. Isolate the builder. Record scanner and knowledge identity. Bind SBOM and provenance subjects to the artifact digest. Authenticate evidence, authorize signer/builder/source, enforce at admission, observe runtime digest, and retain revocation plus recovery.

If that sentence feels natural, you are learning the system rather than memorizing products.

## Production transfer

### Representative implementation sequence

Do not introduce every blocker at once. A safe program often proceeds:

1. inventory repositories, package ecosystems, CI platforms, runners, registries and deployment paths;
2. remove long-lived/broad release credentials and separate untrusted jobs;
3. enforce clean/frozen resolution and immutable workflow dependencies;
4. build once and publish by digest;
5. generate artifact-level SBOM and build-platform provenance;
6. authenticate evidence and verify subject/source/builder in report mode;
7. define findings and exception policy with owners;
8. enforce promotion for a canary service;
9. enforce admission with measured failure behavior;
10. map runtime digests to evidence and rehearse revocation;
11. expand by risk tier while measuring developer and service outcomes.

Each stage needs an exit criterion. “Installed scanner” is activity. “Every release candidate has complete extraction status and no parse errors hidden as pass” is an outcome.

### Compromised dependency incident

Suppose version `4.2.1` of a transitive package runs a credential-stealing install script.

**Contain:** freeze resolution/build jobs that can fetch it; block the package version at approved mirrors; isolate affected runners; revoke tokens available to install steps; deny known artifact digests built in the exposure window.

**Preserve:** manifest/lock history, resolver version/config, registry/mirror logs, download hashes, install output, runner image/state, process/egress telemetry, build runs, artifacts, evidence and deployments. Avoid installing it again on an evidence-rich host.

**Scope:** which repos resolved it, which jobs installed it, what identities were present, what egress occurred, which artifacts were produced, which environments run them.

**Recover:** restore an approved version/source, clean caches under controlled ownership, rebuild from reviewed commits on fresh builders, produce new SBOM/provenance/signature, admit only new digests, rotate exposed authority and verify user journeys.

**Prevent:** namespace/source policy, immutable locks, lifecycle-script policy, ephemeral runners, egress constraints, short-lived identity, package review, runtime inventory and a rehearsed denylist.

### Tampered artifact

If registry bytes or associations are altered, a digest mismatch or subject mismatch should fail verification. Freeze promotion, preserve candidate/evidence descriptors and verifier output, determine whether tag mutation, manifest substitution, evidence association or trust configuration changed, and compare producer versus registry records.

Do not “fix metadata” around unknown bytes. Rebuild and republish a new digest through trusted infrastructure. Reconcile every workload referencing the affected digest and prove absence after replacement.

### New vulnerability

When an advisory arrives:

```text
advisory identity/revision
 -> normalize ecosystem/package/version
 -> search validated SBOM inventory
 -> obtain subject artifact digests
 -> join current deployment inventory
 -> add exposure/reachability/exploit evidence
 -> prioritize and contain
 -> rebuild replacement
 -> verify admission and user service
 -> prove old digest absent or approved exception
```

The join is the superpower. Without it, teams open thousands of repository tickets and still cannot answer what runs.

### Metrics that show outcome

Useful measures include:

- percent of released digests with authenticated subject-matched provenance;
- percent with validated SBOM and extraction coverage;
- privileged workflows pinned and least-privilege;
- time from advisory to affected-deployment inventory;
- time from signer/builder compromise to deny propagation;
- expired exception count and oldest age;
- admission bypass count by authority/reason;
- policy false-positive/false-negative samples;
- release lead-time impact;
- recovery exercise success.

Never game these by shrinking scope. Publish numerator, denominator, exclusions and freshness.

## Reliability, security, observability, capacity, and cost

### Reliability

Security controls are dependencies. Model evidence-store, identity issuer, registry, transparency, policy and admission outages. Cache only authenticated results, bound to digest and policy version. Decide how stale evidence can be and how revocation invalidates cache.

Admission timeouts consume API latency. A fail-closed webhook with insufficient replicas or a circular dependency can stop all workload changes. Use narrow selectors, capacity, disruption budgets, tested timeout behavior and an audited recovery path. Do not hide outages with global fail-open.

### Security

Apply least privilege at every stage:

- read-only source token for test;
- write package permission only for release job;
- separate identity per repository/workflow/environment;
- no production secrets in pull-request jobs;
- restricted egress from builders;
- protected trust roots and policy data;
- consumer-side verification;
- short-lived emergency authority.

Treat generated SBOMs as potentially sensitive. They can reveal internal packages, architecture and versions. Provide necessary responders and consumers access without publishing private inventory accidentally.

### Observability

Correlate repository/commit, workflow/run, runner/builder, artifact/evidence digests, policy version, admission request and workload UID. Log structured decisions and reasons, not secret content.

Alert on control failure, not ordinary finding volume alone:

- required scanner input skipped;
- vulnerability database beyond freshness objective;
- evidence subject mismatch;
- signer identity outside allowlist;
- admission error/timeout spike;
- bypass or exception without valid expiry;
- deployed digest absent from inventory;
- revoked digest still running.

### Capacity and performance

Model repository count, changes per hour, dependency graph size, image bytes/layers, concurrent builds, SBOM components, advisory updates, admission QPS and inventory joins. Scanning every full image repeatedly wastes time. Reuse authenticated digest-bound evidence when policy permits, but re-evaluate time-varying vulnerability data without pretending the artifact changed.

Keep CI feedback fast: cheap deterministic checks early, expensive artifact checks after build, central asynchronous reevaluation for new advisories, and hard enforcement at the narrow release boundary.

### Cost

Costs include runner minutes, scanner licenses, vulnerability feeds, evidence storage/egress, signing/KMS, registry retention, admission capacity, platform engineering and developer delay. The highest cost may be incident uncertainty from missing identity rather than a tool invoice.

Optimize after preserving control meaning. Deduplicate by digest, tier evidence retention, share platform services, sample exploratory checks but never sample mandatory admission, and measure cost per governed release plus time saved during response.

## Traps and prevention

### Trap: “Signed means safe”

**Why it fails:** a signature authenticates under a key or identity. The signer can be unauthorized, compromised or faithfully signing unsafe output.

**Prevent:** constrain identity/issuer, repository, workflow, builder and environment; verify provenance subject; apply findings policy; retain revocation.

### Trap: scan by tag, deploy by tag

**Why it fails:** the pointer can change between operations.

**Prevent:** resolve once, scan/evidence/promote/deploy the same digest, and compare runtime identity.

### Trap: SBOM from manifest equals final artifact

**Why it fails:** build stages, base images, vendoring, static binaries, generated files and removed packages change content.

**Prevent:** preserve source graph evidence and independently catalog the final artifact; document known blind spots.

### Trap: fail pipeline on every “critical”

**Why it fails:** identity errors, false positives, build-only components and non-reachable findings create noise; teams suppress controls globally.

**Prevent:** keep a conservative default but triage with ecosystem identity, exposure, exploitability, environment and impact. Make exceptions narrow and expiring.

### Trap: allow every failure temporarily

**Why it fails:** temporary bypass becomes the real path.

**Prevent:** separate tool error from risk finding, repair reliability, scope emergency authority, expire automatically and alert on use.

### Trap: persistent trusted runner

**Why it fails:** one job plants state or steals authority from later jobs.

**Prevent:** ephemeral isolation, known runner image, no cross-trust cache writes, short-lived identity, egress control and post-job destruction proof.

### Trap: mutable CI action version

**Why it fails:** third-party code changes without review in your repository.

**Prevent:** pin full immutable identity, automate reviewed updates and audit nested execution dependencies.

### Trap: security job has broad secrets

**Why it fails:** scanners parse attacker-controlled source and formats; compromise gains release/cloud authority.

**Prevent:** scan untrusted code without secrets, isolate network, use least privilege and split privileged publication from analysis.

### Trap: one scanner is the policy

**Why it fails:** tool output is evidence, with coverage and freshness limits. Product defaults may change.

**Prevent:** normalize results into an organization-owned versioned policy with explicit error, coverage, exception and owner semantics.

### Trap: admission label says “verified”

**Why it fails:** the requester may set the label.

**Prevent:** admission resolves identity and independently retrieves/authenticates evidence or trusts only protected controller-written state with verified ownership.

### Trap: no runtime join

**Why it fails:** the organization knows what it built but not where it runs.

**Prevent:** reconcile deployment digest/owner/environment inventory, measure freshness and test advisory-to-workload queries.

### Trap: delete compromised evidence

**Why it fails:** scoping and causal analysis disappear.

**Prevent:** freeze promotion, preserve immutable records under incident access controls, deny affected identities, then recover with new artifacts.

## Memory card and retrieval

### The eight nouns

Remember:

```text
source -> graph -> builder -> artifact -> inventory -> history -> identity -> policy
```

- **source:** reviewed immutable revision;
- **graph:** exact direct/transitive materials;
- **builder:** authorized isolated executor;
- **artifact:** immutable produced digest;
- **inventory:** SBOM component claim;
- **history:** provenance claim;
- **identity:** signature/certificate authentication;
- **policy:** consumer authorization and risk decision.

Then add **admission**, **runtime**, **revocation**.

### Five distinctions

1. Tag is a pointer; digest is content identity.
2. SBOM is inventory; scanning is time-bound matching.
3. Provenance is production history; signature authenticates a statement/object.
4. Authentication says who/what; authorization says allowed for this operation.
5. Pipeline pass is release-time evidence; runtime inventory enables later response.

### Sixty-second incident prompt

When told “supply-chain incident,” ask:

- What exact identity is suspect?
- Which boundary could alter it?
- Which authority was exposed?
- Which evidence is trustworthy?
- Which artifacts descend from it?
- Where do those digests run?
- How do we freeze, revoke and deny?
- What clean root can rebuild?
- How will user recovery and old-digest absence be proved?

### Retrieval exercise

Without looking, draw this:

```text
commit C + lock L + workflow W
          -> builder B
          -> artifact A
          -> SBOM/provenance/results about A
          -> signature identity I
          -> policy P
          -> admission D
          -> runtime R
```

On each edge write one failure and one evidence point. Repeating this weekly is more useful than memorizing scanner flags.

## Complete answers

### Question 1: Why is an SBOM not a vulnerability report?

**Direct answer:** an SBOM claims which components and relationships a generator observed for a subject. A vulnerability report compares component identities or code/configuration evidence with a knowledge source at a particular time. The inventory can remain unchanged while the result changes after a new advisory.

**Step by step:**

1. Artifact digest A is produced.
2. Generator G catalogs A and emits SBOM S.
3. S must identify A as its subject and describe components with useful identifiers.
4. Scanner V at time T extracts or consumes identities and queries knowledge K.
5. V reports matches and coverage.
6. Policy adds exposure, reachability, exploitability, impact and exceptions.
7. A future K2 may reveal a vulnerability without rebuilding A.

Therefore store reusable SBOM evidence and reevaluate it. Do not regenerate inventory just to pretend the knowledge base is current.

### Question 2: A signature verifies. What remains to check?

**Direct answer:** verify that the signed subject is the candidate digest, the identity and issuer match expectation, the identity is authorized for this repository/workflow/environment, provenance names a trusted builder/source/materials, findings meet policy, trust is not revoked, and the same digest is promoted and deployed.

**Why:** cryptography can prove integrity/authentication within its model. It cannot prove intent, authorization, source review, builder isolation, component safety or operational fitness.

**Example:** attacker steals a valid release key and signs malware. `verify` can correctly return success. Consumer policy must revoke the key, deny affected digests and require clean rebuild evidence.

### Question 3: Why pin CI actions to full commit identities?

**Direct answer:** a mutable tag can point to different action code later without a diff in the consuming repository. A full commit identity binds execution to reviewed content.

This does not finish the problem. The action repository or commit may already be malicious; nested downloads may remain mutable; runner permissions may be excessive. Combine pinning with review, automated update proposals, least privilege, isolation and egress policy.

### Question 4: Scanner reports zero findings but one lockfile was unsupported. Pass or fail?

**Direct answer:** required coverage failed, so the release does not receive a clean result. Record operational error/unsupported input separately from risk findings, repair extraction or obtain a reviewed narrow exception.

Zero matches means only “no matched records were emitted.” It says nothing useful when expected components were never identified.

### Question 5: How do you respond to a malicious dependency?

**Direct answer:** freeze fetching/building, block the component/version, isolate runners, revoke exposed authority, preserve dependency/runner/network/build evidence, map affected artifacts and deployments, rebuild from trusted materials on clean builders, verify new evidence, deploy new digests and prove the old identities absent.

Do not begin by deleting caches or rotating every dependency. Preserve enough evidence to determine which cache, job, identity and artifact were affected. Rotate authority based on exposure and uncertainty.

### Question 6: Where should verification occur?

**Direct answer:** producers should generate evidence; promotion should verify before increasing trust; admission should independently enforce for runtime; inventory should continually reconcile actual deployments. Earlier checks give fast feedback, later checks prevent substitution/bypass.

One check cannot cover all timing. If only CI verifies, a later tag mutation can win. If only admission verifies, developers get slow feedback and the admission service carries every mistake.

### Question 7: Should admission fail open or closed?

**Direct answer:** there is no safe universal switch. For high-risk governed workloads, failure to verify normally denies. But the system must be reliable and have a narrowly controlled recovery path. Classify workloads, selectors, cache freshness, timeout, failure policy and emergency authority in advance.

Fail-open preserves availability by removing the security boundary. Fail-closed preserves the boundary but can halt recovery. Reduce the dilemma with highly available verification, local authenticated caches, digest denylisting, canary rollout and tested break-glass.

### Question 8: What makes an exception acceptable?

**Direct answer:** exact scope, evidence-based reason, compensating controls, authorized risk owner, deadline, monitoring, remediation plan and automatic reevaluation. It must be visible in promotion and admission decisions.

“Ignore CVE-1234” is insufficient. Which package mapping? Which digest? Which environment? Why non-reachable? Until when? What change invalidates that claim?

### Question 9: How do you prove remediation?

**Direct answer:** produce a replacement digest from trusted inputs/builders; verify its SBOM, provenance, signatures and policy; deploy it; confirm user/service health; query runtime inventory to prove affected digests are absent or explicitly quarantined; close/revoke temporary exceptions and credentials.

A merged dependency update is intent, not remediation. A successful build is output, not deployment. A completed rollout is not user recovery until the actual journey works.

## Product-company interview

### Design a secure delivery chain

**Prompt:** “Design a software supply-chain security system for hundreds of services deploying to Kubernetes.”

Start with requirements, not tools:

- artifact types and package ecosystems;
- source/CI/registry/cluster boundaries;
- release volume and latency objective;
- trust and attacker model;
- regulatory/evidence retention;
- tenant and team ownership;
- availability and disaster recovery;
- current maturity and migration constraints.

Then draw:

```text
reviewed source + locked graph
 -> ephemeral least-privilege build
 -> artifact digest + SBOM + provenance + results
 -> authenticated evidence store
 -> promotion policy
 -> registry
 -> admission verification
 -> runtime digest inventory
 -> advisory/revocation response
```

Explain independent consumer verification, signer/builder identity policy, digest continuity, time-varying vulnerability reevaluation, expiring exceptions and emergency recovery. Add scale: event-driven scans by new digest, advisory-driven reevaluation, local admission caches and horizontally scalable inventory.

A senior answer states limitations: no scanner proves unknown vulnerability absence; signatures do not establish safety; admission can fail; SBOM completeness varies; trust roots can be compromised. Then it owns those residual risks.

### Debug a subject mismatch

**Prompt:** “Cosign verifies the attestation, but policy says the SBOM subject does not match the image.”

Good investigation:

1. Freeze promotion and retain candidate/evidence descriptors.
2. Resolve image tag to digest once and record media type.
3. Inspect attestation subject algorithm/value.
4. Determine whether evidence refers to index, platform manifest, another repository or previous build.
5. Verify evidence authentication and storage relationship independently.
6. Compare build output, publication and association steps.
7. Correct the producer only after determining substitution versus configuration error.
8. Recreate evidence for the correct immutable subject; never edit a signed statement.
9. Re-run policy and prove admission uses the same digest.

Weak answer: “Turn off subject validation because the signer passed.” That removes the binding that makes the statement relevant.

### Prioritize 10,000 findings

Use a pipeline:

- validate scanner coverage and component identity;
- deduplicate by advisory/component/artifact;
- map artifacts to current deployments and owners;
- enrich with exposure, reachability, exploit maturity and privilege;
- prioritize user/asset impact;
- apply verified compensating controls;
- batch rebuild common base/dependency fixes;
- track exception expiry and old-digest absence.

Do not promise perfect reachability. State uncertainty and choose conservative containment for high-impact exposed paths.

### Behavioral ownership

**Prompt:** “A security gate is blocking releases and teams want it disabled.”

A strong response separates:

- real findings from tool errors;
- false positives from inconvenient truths;
- control objective from current implementation;
- immediate business need from permanent policy.

Restore reliability quickly without silently removing the invariant: isolate the failure, use an approved narrow time-bound bypass only if risk authority accepts it, preserve every use, fix capacity/coverage, backfill verification, and publish recurrence actions. Measure gate latency/error and bypass debt.

### Staff-level trade-off

At staff level, discuss organization and economics. Central teams should own trust roots, common policy contracts and platform services; application teams own dependency necessity, service exposure and remediation. Security owns risk methodology; business-authorized owners accept residual risk. Design policy feedback so teams can self-correct without opening tickets for every release.

## Independent transfer and rubric

### Reviewer-owned exercise

The independent exercise requires a disposable local repository, package mirror/registry and Kubernetes cluster. The reviewer—not the learner—owns fault injection and trust roots. Use synthetic code only.

Required scenarios:

1. valid source-to-runtime path;
2. mutable dependency or workflow rejection;
3. scanner coverage error distinguished from clean;
4. SBOM subject mismatch;
5. provenance subject/source/builder mismatch;
6. cryptographically valid but unauthorized signer;
7. tag substitution after scan;
8. admission unavailable under declared failure policy;
9. newly published advisory mapped to deployed digest;
10. signer/builder revocation, replacement and old-digest absence.

### Deliverables

- threat model with assets, actors, entry points, controls, owners and residual risks;
- architecture/evidence graph;
- reproducible source, lock, builder and artifact identities;
- validated SBOM and provenance bound to the artifact;
- authenticated verification and policy receipts;
- positive, negative and operational-error test matrix;
- runtime deployment inventory;
- incident timeline and containment decisions;
- replacement/rollback plus user verification;
- exact cleanup proof and limitations.

### Abort conditions

Stop on production access, public publication, real credentials/data, shared trusted runner, unknown registry/cluster ownership, unreviewed destructive cleanup, broad signing key, mutable promotion or missing rollback.

### Scoring rubric: 100 points

| Criterion | Points | Observable evidence |
|---|---:|---|
| Mental model and threat boundaries | 10 | Explains identities, transformations, producer/consumer trust and attackers |
| Source/dependency identity | 10 | Reviewed commit, pinned workflow, frozen graph, sources and integrity |
| Builder security | 10 | Isolation, least privilege, egress, clean lifecycle and provenance authority |
| Artifact/SBOM binding | 10 | Immutable digest, validated inventory, relationships and known gaps |
| Provenance/signature verification | 10 | Authentication plus subject, source, builder and signer authorization |
| Scanner and policy quality | 10 | Tool/data/coverage, structured outcomes, risk triage and expiring exceptions |
| Promotion/admission/runtime | 10 | Same digest, enforced decision, runtime identity and current inventory |
| Incident containment/recovery | 10 | Freeze, preserve, scope, revoke, rebuild, replace and absence proof |
| Reliability/capacity/cost | 10 | Failure modes, SLOs, scale model, caches, rollout and economics |
| Communication/independence | 10 | Clear evidence, limitations, trade-offs, cleanup and no fabricated claims |

Minimum suggestion: 80/100 overall, at least 6/10 in every row, and no critical safety breach. Reading this answer does not award a score. A reviewer must inspect learner-produced evidence.

### What mastery looks like

The learner can receive an unfamiliar pipeline and reconstruct source, workflow, graph, builder, artifact, evidence, consumer decision and runtime identity. They refuse invalid shortcuts, diagnose mismatched claims, design proportionate policy, preserve reliability and lead recovery without depending on one vendor command.

## References and review

### Primary and official sources

1. [NIST Secure Software Development Framework SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final) — outcome-based secure development practices.
2. [NIST SP 800-204D](https://csrc.nist.gov/pubs/sp/800/204/d/final) — integrating supply-chain security in DevSecOps pipelines.
3. [SLSA v1.2 specification](https://slsa.dev/spec/v1.2/) — integrity framework and specification.
4. [SLSA build requirements](https://slsa.dev/spec/v1.2/build-requirements) — provenance and build-platform requirements.
5. [SLSA artifact verification](https://slsa.dev/spec/v1.2/verifying-artifacts) — consumer verification sequence.
6. [SPDX specifications](https://spdx.dev/use/specifications/) — machine-readable software metadata and SBOM formats.
7. [CISA 2025 SBOM Minimum Elements](https://www.cisa.gov/sites/default/files/2025-08/2025_CISA_SBOM_Minimum_Elements.pdf) — current minimum-element guidance.
8. [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use) — workflow, token, pinning and runner boundaries.
9. [GitHub artifact attestations](https://docs.github.com/en/enterprise-cloud@latest/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations) — version-sensitive hosted implementation.
10. [Sigstore Cosign verification](https://docs.sigstore.dev/cosign/verifying/verify/) — identity-constrained signature verification.
11. [OCI Image and Distribution 1.1](https://opencontainers.org/posts/blog/2024-03-13-image-and-distribution-1-1/) — artifact relationships and distribution.
12. [OSV-Scanner usage](https://google.github.io/osv-scanner/usage/) — extraction, matching and remediation boundaries.
13. [Kubernetes dynamic admission control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) — request path, timeout and failure behavior.
14. [OpenSSF Scorecard checks](https://github.com/ossf/scorecard/blob/main/docs/checks.md) — repository security signals and definitions.
15. [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/) — dependency identification and known-vulnerability matching.

### Review discipline

The sources were reviewed on 2026-08-07. Product syntax, schemas, hosted features, current releases and vulnerability feeds change. Recheck before operational use. Source authority does not convert this chapter into runtime evidence.

### Honest boundary

This candidate has a deterministic offline model only. It does not prove a package manager, scanner, SBOM generator, SLSA/Cosign verifier, OCI registry, Kubernetes admission control, policy engine or production incident path. Canonical publication, formal technical/editorial review, representative integration, independent transfer, delayed recall and learner evidence remain separate gates.
