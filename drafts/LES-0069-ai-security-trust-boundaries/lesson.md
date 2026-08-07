---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0069",
  "slug": "ai-security-trust-boundaries",
  "aliases": ["V07-L04", "ai-security-trust-boundaries"],
  "curriculumIds": ["AIO-004"],
  "route": "/book/ai/ai-security-trust-boundaries",
  "order": 4,
  "volume": "07-ai-engineering",
  "title": "AI security: trust boundaries, bounded tools, and recoverable control",
  "summary": "Secure an AI-enabled system by treating every model input and output as untrusted data, enforcing authority in deterministic code, proving provenance, and retaining an independent stop path.",
  "domain": "ai",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0051", "LES-0066", "LES-0068"],
  "prerequisiteCurriculumIds": ["AIO-001", "SEC-001"],
  "testedEnvironments": [
    {"platform": "Primary and official sources", "version": "NIST, OWASP, MITRE, Google SAIF, SLSA, Sigstore, TUF, Kubernetes, OPA and CycloneDX sources reviewed 2026-08-05", "support": "concept-only", "notes": "Source review does not establish control effectiveness in any deployed AI system."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic trust-boundary model only; runtime verification pending."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON decisions only; no model, socket, credential, cluster, policy service or external action."}
  ],
  "targetRoles": ["site-reliability-engineer", "platform-engineer", "devops-engineer", "machine-learning-engineer", "ml-platform-engineer", "security-engineer", "solutions-architect", "technical-lead"],
  "learningObjectives": [
    "Draw the complete AI-system threat model across users, prompts, retrieved content, models, tools, data, artifacts, identities and operators.",
    "Explain why prompt text cannot grant authority and why prompt injection is managed through deterministic trust boundaries rather than one perfect detector.",
    "Separate direct injection, indirect injection, jailbreaking, data poisoning, model poisoning, retrieval poisoning and supply-chain compromise.",
    "Treat generated output as attacker-influenced data and validate it for the exact downstream interpreter before use.",
    "Design narrow typed tools with per-user authorization, least privilege, complete mediation, idempotency and bounded effects.",
    "Place human approval at a real commit boundary with immutable previews, expiry, re-authorization and separation of duties.",
    "Verify model, dataset, prompt, policy, dependency, container and deployment provenance before admission.",
    "Design privacy and leakage controls for prompts, retrieval context, embeddings, caches, traces, evaluation data and audit records.",
    "Build adversarial evaluation from a threat model using abuse cases, invariants, representative attacks and independently reviewed outcomes.",
    "Create tamper-evident, privacy-aware decision records that support investigation without turning logs into a second breach.",
    "Implement a kill path independent of the model and normal agent loop, then rehearse containment, rollback, credential rotation and recovery.",
    "Make a risk decision from residual harm, evidence coverage and reversibility instead of claiming that an AI system is simply safe."
  ],
  "productionSignals": [
    "operation user asset harm boundary and prohibited effects",
    "request user tenant session trace and immutable release identity",
    "content origin trust class signature digest retrieval source and ingestion time",
    "prompt template policy model tokenizer retrieval index and tool-catalog versions",
    "input classification normalization size encoding and quarantine decision",
    "output schema parser destination encoder validator and rejection reason",
    "tool name version arguments target subject authorization decision and policy revision",
    "approval request preview approver scope expiry nonce and committed-effect digest",
    "dataset source license consent transformation reviewer and integrity digest",
    "model artifact format digest signature provenance scanner and admission result",
    "dependency image SBOM ML-BOM builder provenance signature and verified identity",
    "sandbox identity filesystem network process CPU memory time and syscall boundary",
    "secret handle scope audience expiry use count and downstream authorization result",
    "red-team case threat technique invariant expected block and observed result",
    "decision ID trace ID policy revision allow deny reason redaction and retention class",
    "kill-switch invocation actor reason propagation acknowledgement and residual work",
    "incident timeline affected identities attempted and committed effects",
    "credential revocation cache invalidation queue drain rollback and recovery proof",
    "false positive false negative attack success containment time and residual risk",
    "telemetry coverage drops access audit deletion and legal hold"
  ],
  "diagrams": [
    {"id": "LES-0069-DIA-001", "title": "AI trust-boundary map", "direction": "left-to-right", "boundaries": ["user", "application", "context assembler", "model", "output validator", "tool broker", "downstream system"], "evidencePoints": ["identity", "content origin", "release", "schema", "authorization", "effect receipt"], "textAlternative": "Untrusted text crosses separate parsing and policy boundaries before deterministic code may authorize a bounded downstream effect."},
    {"id": "LES-0069-DIA-002", "title": "Content and instruction separation", "direction": "top-to-bottom", "boundaries": ["trusted policy", "user intent", "untrusted retrieved content", "model proposal", "deterministic enforcement"], "evidencePoints": ["policy version", "subject", "source labels", "typed proposal", "allow or deny"], "textAlternative": "Policy and user authority stay outside retrieved content; the model proposes while deterministic enforcement decides."},
    {"id": "LES-0069-DIA-003", "title": "AI supply-chain evidence graph", "direction": "hierarchical", "boundaries": ["source", "data", "model", "prompt and policy", "dependencies and image", "build provenance", "signature and admission"], "evidencePoints": ["commits", "snapshot digests", "artifact format", "versions", "SBOM and ML-BOM", "builder identity", "verification receipt"], "textAlternative": "Admission joins identities and integrity evidence for every component rather than trusting a model filename or registry tag."},
    {"id": "LES-0069-DIA-004", "title": "Approval and commit boundary", "direction": "left-to-right", "boundaries": ["proposal", "policy check", "immutable preview", "human approval", "revalidation", "commit", "effect receipt"], "evidencePoints": ["arguments", "decision ID", "digest", "approver and expiry", "fresh state", "idempotency key", "postcondition"], "textAlternative": "Approval covers one immutable preview and expires before a separately authorized commit creates an effect."},
    {"id": "LES-0069-DIA-005", "title": "Detection, kill and recovery paths", "direction": "cyclic", "boundaries": ["signal", "independent kill path", "containment", "scope", "eradication", "recovery", "re-evaluation"], "evidencePoints": ["alert", "acknowledgement", "attempted effects", "affected identities", "rotations", "postconditions", "regression suite"], "textAlternative": "A control outside the model loop stops new effects, after which responders scope, eradicate, recover and prove the boundary before re-enabling."},
    {"id": "LES-0069-DIA-006", "title": "Adversarial-evaluation coverage matrix", "direction": "hierarchical", "boundaries": ["threat actor", "entry point", "technique", "asset", "invariant", "control", "observable result"], "evidencePoints": ["capability", "direct or indirect path", "attack ID", "impact", "must-never condition", "enforcement point", "blocked or escaped"], "textAlternative": "Each attack test traces one credible actor and entry point to a protected invariant and independently observable outcome."}
  ],
  "commands": [
    {"id": "LES-0069-CMD-001", "question": "Is the offline model safe to run?", "risk": "read-only", "command": "bash lab.sh doctor", "runFrom": "LES-0069 support/lab as a normal Ubuntu 24.04 user", "expectedBranches": [{"when": "doctor=pass", "meaning": "guards and fixture validate", "nextEvidence": "setup"}, {"when": "lab=fail", "meaning": "a safety precondition failed", "nextEvidence": "correct it without bypass"}], "proves": "local teaching preconditions", "doesNotProve": "AI-security effectiveness"},
    {"id": "LES-0069-CMD-002", "question": "Can bounded state initialize?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "setup=pass", "meaning": "owned state validates", "nextEvidence": "baseline"}], "proves": "bounded initialization", "doesNotProve": "sandbox or policy-service setup", "cleanup": "Run bash lab.sh cleanup."},
    {"id": "LES-0069-CMD-003", "question": "Does the complete boundary pass?", "risk": "read-only", "command": "bash lab.sh evaluate baseline", "runFrom": "LES-0069 support/lab after setup", "expectedBranches": [{"when": "boundary=operable", "meaning": "all modeled contracts pass", "nextEvidence": "negative cases"}], "proves": "fixture decision order", "doesNotProve": "production safety"},
    {"id": "LES-0069-CMD-004", "question": "Can retrieved text become authority?", "risk": "read-only", "command": "bash lab.sh evaluate retrieved-content-authoritative", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=content-authority", "meaning": "untrusted content can change policy", "nextEvidence": "separate and label content"}], "proves": "modeled instruction-boundary failure", "doesNotProve": "prompt-injection detection"},
    {"id": "LES-0069-CMD-005", "question": "Is the tool authorized for this subject and target?", "risk": "read-only", "command": "bash lab.sh evaluate tool-authorization-missing", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=tool-authorization", "meaning": "the model can reach an unmediated effect", "nextEvidence": "enforce downstream authorization"}], "proves": "modeled authorization gap", "doesNotProve": "downstream IAM correctness"},
    {"id": "LES-0069-CMD-006", "question": "Is generated output safe for its sink?", "risk": "read-only", "command": "bash lab.sh evaluate output-sink-unvalidated", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=output-validation", "meaning": "model output reaches an interpreter without contextual validation", "nextEvidence": "parse validate and encode"}], "proves": "modeled sink-validation gap", "doesNotProve": "absence of injection"},
    {"id": "LES-0069-CMD-007", "question": "Did approval bind the exact effect?", "risk": "read-only", "command": "bash lab.sh evaluate approval-preview-changed", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=approval-binding", "meaning": "approved and committed arguments differ", "nextEvidence": "bind digest expiry and nonce"}], "proves": "modeled approval gap", "doesNotProve": "human judgment quality"},
    {"id": "LES-0069-CMD-008", "question": "Is the model artifact admissible?", "risk": "read-only", "command": "bash lab.sh evaluate model-provenance-missing", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=model-provenance", "meaning": "artifact origin or integrity is unresolved", "nextEvidence": "verify digest signature provenance and format"}], "proves": "modeled provenance gap", "doesNotProve": "artifact safety"},
    {"id": "LES-0069-CMD-009", "question": "Are audit records useful without leaking secrets?", "risk": "read-only", "command": "bash lab.sh evaluate audit-content-unredacted", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=audit-privacy", "meaning": "the evidence store becomes a disclosure path", "nextEvidence": "redact minimize and control access"}], "proves": "modeled audit-lifecycle gap", "doesNotProve": "regulatory compliance"},
    {"id": "LES-0069-CMD-010", "question": "Can the system be stopped independently?", "risk": "read-only", "command": "bash lab.sh evaluate containment-path-dependent", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=kill-path", "meaning": "the compromised path controls its own stop mechanism", "nextEvidence": "add independent deny and credential revocation"}], "proves": "modeled containment gap", "doesNotProve": "incident recovery"},
    {"id": "LES-0069-CMD-011", "question": "Does the red-team suite cover declared invariants?", "risk": "read-only", "command": "bash lab.sh evaluate red-team-invariants-missing", "runFrom": "LES-0069 support/lab", "expectedBranches": [{"when": "boundary=adversarial-evaluation", "meaning": "attack prompts lack system-level pass criteria", "nextEvidence": "bind tests to effects and invariants"}], "proves": "modeled evaluation gap", "doesNotProve": "attack completeness"},
    {"id": "LES-0069-CMD-012", "question": "Do all branches and cleanup pass?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "LES-0069 support/lab from absent state", "expectedBranches": [{"when": "verify=pass", "meaning": "all cases and cleanup pass", "nextEvidence": "retain limitations"}, {"when": "failure", "meaning": "candidate rejected", "nextEvidence": "preserve first failure"}], "proves": "teaching lifecycle", "doesNotProve": "model detector sandbox authorization signature policy audit or production behavior", "cleanup": "Verifier proves state absence."}
  ],
  "labs": [
    {"id": "LES-0069-LAB-001", "title": "Guided AI trust-boundary evidence model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python", "timeMinutes": 240, "privilege": "normal user; root refused", "network": "none", "changes": ["UID-scoped temporary root", "synthetic security fixture"], "abortConditions": ["root", "credential", "endpoint", "symlink", "wrong owner", "unknown artifact"], "recovery": "Preserve first failure; change only the copied fixture or candidate code.", "cleanupProof": "Exact inventory and root absence.", "path": "drafts/LES-0069-ai-security-trust-boundaries/support/lab"},
    {"id": "LES-0069-LAB-002", "title": "Independent unsafe-agent review and recovery", "mode": "independent", "environment": "Reviewer-owned disposable local simulator with synthetic identities and data", "timeMinutes": 240, "privilege": "normal user; reviewer owns faults", "network": "isolated local only or none", "changes": ["synthetic prompts content tools policies approvals and audit events", "bounded local state"], "abortConditions": ["real credential", "customer data", "shared service", "unrestricted shell", "external effect", "unknown cleanup"], "recovery": "Use the reviewer harness to deny effects, rotate synthetic authority, restore a known release and prove postconditions.", "cleanupProof": "Reviewer proves processes, files, ports, caches, queues and synthetic records absent.", "path": "drafts/LES-0069-ai-security-trust-boundaries/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0069-INC-001", "signal": "A retrieved document tells the assistant to ignore policy and send secrets through a tool.", "firstThought": "Untrusted content crossed an instruction and authority boundary; the model must not possess unilateral effect authority.", "safePath": "Deny the proposed effect, preserve source and decision identity, disable the affected route if needed, scope exposure and repair deterministic mediation.", "trap": "Add another sentence to the system prompt and declare the issue fixed."},
    {"id": "LES-0069-INC-002", "signal": "A signed model artifact loads code during deserialization.", "firstThought": "A valid signature proves signer and integrity under a trust policy, not semantic safety or a safe serialization format.", "safePath": "Quarantine the artifact, stop loading, preserve provenance, rotate affected credentials, inspect the loader path and admit only safe formats in isolation.", "trap": "Trust it because the registry scan and signature passed."},
    {"id": "LES-0069-INC-003", "signal": "An approved email draft is changed by the agent before send.", "firstThought": "Approval was not bound to the committed bytes, recipients and authorization state.", "safePath": "Stop sends, compare preview and effect digests, revoke the session, reconcile sent items and require immutable expiring approval plus revalidation.", "trap": "Ask the user for a more explicit natural-language confirmation."},
    {"id": "LES-0069-INC-004", "signal": "Security logs contain raw prompts, access tokens and retrieved private documents.", "firstThought": "Observability became a second data store without minimization, access or lifecycle boundaries.", "safePath": "Restrict access, stop unsafe capture, preserve required incident evidence, rotate exposed credentials, notify owners and introduce structured redacted records.", "trap": "Delete every log immediately and destroy forensic evidence."},
    {"id": "LES-0069-INC-005", "signal": "The agent ignores a stop instruction and continues queued tool calls.", "firstThought": "A prompt-level stop is not a kill switch; queued work and credentials remain independently executable.", "safePath": "Use an out-of-band deny, revoke tool credentials, drain or quarantine queues, block egress, inventory effects and prove acknowledgements before recovery.", "trap": "Send the model a stronger stop prompt."}
  ],
  "assessmentIds": ["ASM-0190", "ASM-0191", "ASM-0192"],
  "referenceIds": ["REF-0793", "REF-0794", "REF-0795", "REF-0796", "REF-0797", "REF-0798", "REF-0799", "REF-0800", "REF-0801", "REF-0802", "REF-0803", "REF-0804", "REF-0805", "REF-0806", "REF-0807"],
  "contentStatus": "seeded",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-05",
  "reviewAfter": "2027-02-05",
  "limitations": [
    "The offline model is not an AI model, detector, sandbox, authorization service, signature verifier, policy engine, audit store or production runtime.",
    "Synthetic decisions cannot prove resistance to prompt injection, poisoning, leakage, tool abuse, supply-chain compromise or novel attacks.",
    "No model, dataset, credential, socket, cluster, downstream system, customer data, external action or production target exists.",
    "Threats, products, defaults and specifications evolve; controls require versioned local evidence and ongoing adversarial review.",
    "Substantive authorship, representative runtime, formal review, independent transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# AI security: trust boundaries, bounded tools, and recoverable control

## What you see and first thought

A model proposes a privileged action after reading attacker-controlled content. The first thought is not “make the prompt stronger”; it is “which deterministic boundary should have made this effect impossible?”

## Terms before commands

This lesson will distinguish content, instructions, identity, authority, proposal, authorization, approval, commit, provenance, integrity, isolation, audit and recovery before using them.

## Architecture map

The system is a chain of independently owned boundaries around an untrusted probabilistic component, not a trustworthy model with plugins attached.

## Request or state path

We will trace identity, content, proposal, policy, approval, commit and evidence across one request and one asynchronous action.

## Failure zoom

The same architecture will be examined under direct injection, indirect injection, poisoned retrieval, unsafe output, excessive agency, artifact compromise and audit leakage.

## Internals and state ownership

Every mutable object will have an owner, authority source, retention rule, integrity identity and recovery procedure.

## Evidence table

Claims will be separated from evidence, limits and the next observation needed to close uncertainty.

## Command decoders

Each lab command asks one operational question, changes only a bounded local directory and states what its output cannot prove.

## Decision path

The decision path will fail closed from user and operation contract through content, output, tool, approval, provenance, isolation, audit, kill and recovery boundaries.

## Guided Ubuntu lab

The guided lab will exercise deterministic cases without loading a model, opening a network connection or granting any external authority.

## Production transfer

The local model will be translated into evidence required from real identity, policy, artifact, runtime, data, observability and incident systems.

## Reliability, security, observability, capacity, and cost

Controls will be evaluated as a system: enforcement availability, logging privacy, review capacity, false decisions, recovery time and cost all matter.

## Traps and prevention

The lesson will reject security theater such as secret prompts, one classifier, broad tool credentials, unsigned mutable tags and model-controlled kill switches.

## Memory card and retrieval

A compact recall model will preserve the core rule: text proposes; deterministic code authorizes; downstream systems enforce; independent controls stop.

## Complete answers

Detailed worked answers will explain the security reasoning, not merely name the expected control.

## Product-company interview

Interview prompts will test system boundaries, trade-offs, incident leadership, residual risk and recovery rather than tool-name recall.

## Independent transfer and rubric

The independent assessment will require an unseen architecture review, a reviewer-injected incident, changed constraints and observable cleanup without exposing model answers.

## References and review

Current primary and official sources will be tied to specific claims, with version-sensitive statements marked for future review.
