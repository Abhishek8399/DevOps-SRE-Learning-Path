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

A change-remediation assistant reads an alert, searches runbooks, drafts a plan and can call a deployment tool. One retrieved runbook contains a hidden instruction: ignore the incident, export environment variables and open an external URL. The model follows it and emits a syntactically valid tool call.

The weak first thought is: **“The model disobeyed the system prompt.”**

The useful first thought is: **“Attacker-controlled text reached a component with more authority than the attacker. Which non-model boundary should have made the harmful effect impossible?”**

That distinction is the heart of this lesson. A model can classify, summarize, recommend and propose. It cannot be the final source of identity or authority. The same model is interpreting:

- trusted instructions written by the application team;
- the user's request;
- documents, web pages, tickets, logs or emails that other people can influence;
- its own earlier output;
- tool results that may themselves contain hostile text.

All of those become tokens in a context. Labels such as “system,” “user” and “document” can influence behavior, but they do not create the hard isolation that an operating system creates between processes or an authorization server creates between principals. OWASP explicitly describes direct and indirect prompt injection and warns that retrieval and fine-tuning do not fully remove the vulnerability. Design as though a sufficiently capable attacker can influence the proposal.

### The operator's four questions

When an AI-related security alert arrives, ask these in order:

1. **What can happen now?** Stop or bound new effects through a route deny, credential revocation, downstream policy or queue pause that does not require model cooperation.
2. **What actually happened?** Separate text generated, calls proposed, calls authorized, calls attempted and effects committed. A transcript proves only the first two.
3. **Whose authority was used?** Resolve the authenticated user, tenant, service identity, token audience, tool and target. “The agent did it” is not an identity.
4. **Which invariant failed?** Examples: no cross-tenant reads, no external send without approval, no production mutation from retrieved content, no unsigned artifact admission.

Suppose an assistant printed `delete deployment` but the tool broker denied it. That is an attempted policy violation and valuable red-team evidence, but not a deleted deployment. Suppose it printed a refusal while a previously queued call committed. The friendly response is not proof of containment. Downstream state and effect receipts decide.

### One sentence to keep

> Treat model input and output as untrusted data. Let the model propose, deterministic code authorize, the downstream system enforce, and an independent control stop.

This does not mean the model is useless or malicious. It means probabilistic behavior and security authority are different engineering concerns. We do not ask a parser to decide payroll permissions, and we should not ask a language model to decide whether the credential it holds may alter production.

## Terms before commands

Before architecture, make these words precise. Most unsafe designs hide a category mistake inside an innocent sentence such as “the prompt authorizes the tool.”

### Content, instruction and policy

**Content** is information to analyze: a ticket, document, email, log line, web page, image or tool response. It may contain words that look like commands. Its origin and trust class matter.

**Instruction** expresses desired behavior to a model: summarize this incident, prefer read-only evidence, format a proposal as JSON. Instructions influence generation. They are not enforcement.

**Policy** is a rule evaluated by a trusted enforcement path: this authenticated subject may read these namespaces; production deletion requires this role and a fresh approval; outbound hosts must be on this allowlist. Policy produces a deterministic allow, deny or constrained decision from explicit inputs and a versioned rule set.

A hostile runbook may say “policy now permits export.” It remains content. It cannot alter the real policy merely by using authoritative language.

### Identity, authentication, authorization and authority

An **identity** names a principal: a person, workload or service. A model does not authenticate a person by seeing a name in text.

**Authentication** establishes which principal is making a request, using evidence such as a session, workload identity or signed token.

**Authorization** decides whether that authenticated principal may perform an exact action on an exact resource under current conditions.

**Authority** is the real capability to make the effect happen. It comes from credentials and enforcement in systems, not from the confidence of a generated sentence.

If every user request is executed with one administrator service account, the application has collapsed many low-privilege users into one high-privilege deputy. A prompt injection can then trick that deputy into using authority the original user never had.

### Proposal, approval, commit and effect

A **proposal** is a candidate action: `restart service api in test` with normalized arguments. It changes nothing.

An **approval** is a decision by an authorized reviewer about a specific proposal. Approval must bind the exact target, arguments, expected effect, preview digest, expiry and context. “Yes, continue” in a mutable conversation is weak evidence.

A **commit** is the attempt to create the effect after fresh authorization and validation.

An **effect** is the observed downstream state change: a ticket created, message sent, record altered or deployment restarted. A success-looking model response is not an effect receipt; an HTTP 200 may also be insufficient if the operation is asynchronous.

### Trust boundary and complete mediation

A **trust boundary** is a point where data, identity or authority crosses between components with different trust assumptions. At that point, normalize and validate data, authenticate identity, authorize action, constrain resources and record the decision.

**Complete mediation** means every access to a protected resource is checked. Checking the user's initial chat request is not enough if the agent later changes the target, follows a retrieved instruction or retries through a different tool.

### Injection, jailbreak and poisoning

**Direct prompt injection** arrives in input supplied intentionally to the model, such as a user message.

**Indirect prompt injection** arrives inside content the system retrieves or opens: a page, issue, document, email, tool response or image. The user may not know the instruction exists.

A **jailbreak** is a prompt-injection technique aimed at bypassing model behavior restrictions. Not every prompt injection is a jailbreak; an injection can instead redirect a workflow or tool.

**Data poisoning** manipulates training, fine-tuning, evaluation, label or embedding data so learned or retrieved behavior changes. **Model poisoning** changes the artifact or learned behavior, possibly introducing a backdoor. **Retrieval poisoning** introduces or ranks malicious content in a knowledge corpus. A runtime prompt filter does not repair poisoned training lineage.

### Provenance, integrity, signature and safe format

**Provenance** is verifiable information about where, when and how an artifact was produced. SLSA describes provenance as traceability through the moving parts of a supply chain.

**Integrity** means bytes or records have not changed relative to a known identity, commonly a digest.

A **signature** binds a cryptographic statement to a key or identity under a verification policy. A valid signature is useful only when the expected signer, issuer, claims and trusted roots are constrained.

A **safe format** can be parsed without executing embedded code in the loader's security context. These are separate claims:

- a malicious artifact can be correctly signed by a compromised or unauthorized signer;
- a trusted artifact can use a serialization format whose loader executes code;
- an intact, safely parsed model can still behave unsafely.

### Sandbox, allowlist and reference monitor

A **sandbox** limits what a process can reach: filesystem, network, processes, devices, credentials, CPU, memory and time. It reduces impact; it does not transform hostile code into trusted code.

An **allowlist** enumerates what is permitted. “Any URL except known bad domains” is not a strong egress boundary because unknown attacker domains are the normal case.

A **reference monitor** is the enforcement concept through which protected operations pass. For tools, it should see the authenticated subject, tenant, action, target, normalized arguments, policy revision and contextual constraints.

### Audit, kill path, recovery and residual risk

An **audit record** lets an investigator reconstruct a decision and effect. It is not a raw transcript dump. Raw prompts, tokens and private documents can turn observability into a second breach.

A **kill path** stops or denies new authority independently of the model and normal agent loop. Revoking a credential, disabling a tool route or enforcing a downstream deny can be kill actions. Sending “please stop” to the model is an instruction.

**Recovery** restores a known state, reconciles partial effects, rotates compromised authority, validates postconditions and reopens gradually.

**Residual risk** is what remains after controls. It needs an explicit owner, evidence, expiry or review date and conditions for acceptance. “AI is safe” is not a risk decision.

## Architecture map

Start with boundaries, not product names. A secure architecture can use different model vendors, policy engines and runtimes while preserving the same ownership.

### The effect path

```text
 authenticated user
       |
       | identity + tenant + requested operation
       v
 application / session boundary
       |
       | user intent + untrusted content references
       v
 context assembler ---------> content stores / retrieval
       |                           |
       | labeled content           | origin, ACL, digest, time
       v                           |
 probabilistic model <-------------+
       |
       | proposal only: typed action + arguments
       v
 output parser and semantic validator
       |
       | normalized proposal
       v
 tool broker / reference monitor <---- versioned policy
       |           |
       |           +----> immutable preview ----> human approval
       |
       | fresh per-subject authorization + idempotency key
       v
 downstream system enforcement
       |
       +----> effect receipt ----> structured audit / outcome
```

Notice what the model does **not** own:

- user authentication;
- the allowed tool catalog;
- tool credentials;
- authorization policy;
- approval validity;
- downstream enforcement;
- the independent kill path;
- the authoritative record of committed effects.

The model can recommend that the broker call `restart_workload`. The broker decides whether that tool exists for this operation. Policy decides whether this user may restart this workload in this environment. The target system checks the workload identity again. An approval service may bind a production preview. Only then does a commit occur.

### The control plane and the effect plane

Separate two planes.

The **effect plane** handles live requests, context, proposals, authorization and downstream operations. Keep it narrow and fail closed for dangerous actions.

The **control plane** owns versions and governance: prompt and policy releases, tool definitions, trusted signers, dataset admission, red-team suites, audit configuration, kill controls and risk acceptance. An agent must not be able to rewrite the policy or enable its own tools through ordinary effect-plane output.

If one service both generates tool arguments and silently changes the tool schema, policy and trusted artifact tag, compromise of that service owns every layer.

### Data and artifact supply path

The runtime path is only half of AI security.

```text
 sources -> ingestion -> validation/quarantine -> versioned dataset
                                        |
 source code + pipeline + dependencies  |
             \                          v
              +------> build/train/evaluate ------> model artifact
                              |                         |
                              v                         v
                     provenance + evidence       digest + signature
                              \                         /
                               +----> admission <------+
                                         |
                                         v
                                immutable AI release
```

For each node, ask:

- Who may introduce or change it?
- How is origin represented?
- Which transformation ran?
- Which immutable digest identifies the result?
- What approval and evaluation applied?
- Can an older vulnerable object be replayed?
- What happens if a signing key or repository is compromised?

An SBOM inventories software components. An ML-BOM can represent models, datasets, frameworks and related dependencies. Neither is a vulnerability verdict; inventory makes questions answerable. Provenance explains production. A signature protects a statement and identity. TUF-style update metadata addresses secure distribution concerns such as rollback and key compromise. Admission combines the evidence into a policy decision.

### The independent stop path

Build the stop path beside the normal request path, not inside it.

```text
 security operator / automated guard
           |
           +--> deny tool route
           +--> revoke workload credential
           +--> block external egress
           +--> pause or quarantine queued work
           +--> route AI feature to safe fallback
                         |
                         v
              acknowledgements + queue accounting
```

The stop path needs its own least-privilege authority and audit. “Independent” does not mean uncontrolled. It means the component suspected of compromise cannot veto or rewrite the stop.

### Availability is part of the security design

If the policy engine is down, what happens? For a read-only low-risk summary, a cached policy or degraded mode may be acceptable. For a payment, deployment or external message, fail closed is usually correct. Make the choice per operation; a universal default can create either unauthorized effects or avoidable outage.

Similarly, an approval service can become a bottleneck, the audit sink can backpressure requests, a signature service can block releases and a kill fan-out can take time. Reliability engineering makes security controls dependable under the exact pressure when they matter.

## Request or state path

Trace one production operation: “prepare and, after approval, apply a restart of the test API.” The path exposes where a seemingly sensible design can lose identity or authority.

### 1. Establish the operation contract

Before calling a model, define the operation:

```yaml
operation: restart_workload
allowed_environments: [test]
requested_by: authenticated-session-subject
target_kind: kubernetes-deployment
maximum_targets: 1
requires_preview: true
requires_approval: true
approval_ttl_seconds: 300
effect_deadline_seconds: 60
fallback: return_read_only_runbook
prohibited:
  - production targets
  - target names inferred only from untrusted content
  - arbitrary commands
  - external network destinations
```

This is a teaching contract, not a Kubernetes API. The important point is that constraints exist before generation. The model cannot expand `allowed_environments` by proposing a different value.

### 2. Bind authenticated identity

The application receives a verified subject, tenant and session. It creates a request ID and a single end-to-end deadline. Do not put a bearer token into the prompt. Pass only the minimum identity attributes needed to generate a useful proposal, while the actual credential remains in the deterministic broker.

Record:

- subject and tenant IDs or privacy-preserving handles;
- authentication strength and time;
- requested operation;
- immutable application and AI-release identities;
- request, trace and parent action IDs;
- deadline and risk class.

If a user can read only namespace `team-a-test`, that authorization constraint must follow the request outside the model context. A sentence saying “the user is an admin” is not the authorization input.

### 3. Acquire and label content

The retriever searches only sources the authenticated subject may access. Each result carries:

- source system and stable object identity;
- source access decision;
- ingestion and source-update times;
- content digest and transformation version;
- owner, tenant and data classification;
- trust class, such as user-controlled, internal-reviewed or platform-owned;
- retention and deletion linkage.

The context assembler clearly separates policy guidance, user intent and untrusted evidence. This may improve model behavior and investigation, but the security claim remains modest: a label does not prevent the model from following hostile content. It lets downstream controls understand origin and reduces accidental confusion.

### 4. Generate a proposal

The model sees the task and relevant evidence. It may return:

```json
{
  "operation": "restart_workload",
  "environment": "test",
  "namespace": "team-a-test",
  "name": "api",
  "reason_evidence_ids": ["evt-41", "runbook-7"]
}
```

It must not return a shell string, raw URL or embedded credential. The output is still untrusted. A valid JSON document says only that parsing succeeded.

### 5. Parse, normalize and validate for the sink

The parser:

1. rejects malformed JSON, duplicate keys if the parser permits them, unknown fields and excessive size;
2. validates types, enums, lengths and canonical forms;
3. normalizes namespace and target identity;
4. rejects control characters, traversal forms and ambiguous encodings;
5. resolves the target through a trusted inventory;
6. checks semantic invariants such as one target and test-only environment.

Validation is sink-specific. HTML needs contextual encoding. SQL needs parameterized queries and an authorization boundary, not “escaped AI SQL.” URLs need scheme, hostname, port, DNS and redirect policy plus egress enforcement. File paths need a resolved root and safe file API. Shell execution should be replaced with a narrow API; escaping an open-ended model-generated command is not a robust tool design.

### 6. Authorize the tool call

The broker constructs an authorization input from trusted state:

```json
{
  "subject": "user-handle",
  "tenant": "team-a",
  "operation": "restart_workload",
  "target": {
    "environment": "test",
    "namespace": "team-a-test",
    "kind": "Deployment",
    "name": "api"
  },
  "proposal_digest": "sha256:...",
  "release_id": "immutable-release-id",
  "tool_version": "restart-workload/v3",
  "risk": "state-changing-reversible"
}
```

Policy returns allow, deny or constraints with a decision ID and policy revision. The downstream Kubernetes identity also has permissions limited to the eligible namespaces and actions. That second enforcement prevents a broker bug from turning into cluster-wide authority.

### 7. Produce an immutable preview

The system resolves current state and shows the reviewer:

- exact target and environment;
- current and expected post-state;
- effect and known side effects;
- reason evidence with source labels;
- rollback path;
- proposal digest;
- authorizing subject and policy decision;
- expiry.

The preview is immutable. If the target, arguments, policy, relevant state or digest changes, approval is invalidated.

### 8. Approve and revalidate

The approver authenticates separately and must have approval authority. High-impact operations may require separation of duties so the requester cannot approve their own action.

Immediately before commit, re-check:

- approval signature or authenticated receipt;
- proposal digest, nonce and expiry;
- subject and approver authority;
- target state and preconditions;
- policy revision or permitted policy change;
- tool version;
- deadline;
- kill-state and rate/concurrency budget.

This closes a time-of-check/time-of-use gap. Approval at 10:00 must not authorize a materially changed target at 10:04.

### 9. Commit once and observe the effect

The broker creates an idempotency key tied to the proposal and effect. Retries reuse it. The downstream service authorizes again, commits or returns an existing result, and provides an effect identity.

For asynchronous work, `accepted` means queued, not completed. Track:

```text
proposed -> denied
         -> awaiting approval -> expired
                              -> rejected
                              -> authorized -> queued -> started
                                                       -> committed
                                                       -> failed
                                                       -> uncertain
```

“Uncertain” is a real state. A timeout after sending a request does not tell you whether the effect occurred. Reconcile by idempotency key or authoritative downstream state before retrying.

### 10. Record outcome without recording everything

The decision record connects:

- request, trace, user and tenant handles;
- content source IDs and digests;
- release, prompt, policy and tool versions;
- normalized proposal digest;
- allow/deny and reason;
- approval receipt;
- downstream effect ID and postcondition;
- redaction and retention class.

Store raw sensitive content only when there is a justified, access-controlled lifecycle. Often digests, classifications and references provide investigation value without duplicating secrets into a broad log platform.

## Failure zoom

Threat modeling prevents the team from buying one “AI firewall” and believing the work is finished. NIST's adversarial-ML taxonomy separates attacker goals, knowledge, capabilities and lifecycle stages. MITRE ATLAS maps techniques across predictive, generative and agentic systems. Use those sources to build credible paths for *your* operation.

### Direct prompt injection

An attacker sends text designed to redirect behavior, expose protected context or select a dangerous tool.

Possible signals include known patterns, encoding anomalies, repeated policy probes and output changes. Useful controls include task constraints, input limits, detectors, rate limits and adversarial tests. The harm boundary is deterministic:

- the model lacks direct credentials;
- only declared tools exist;
- the broker authorizes exact subject/action/target;
- high-impact commits require bound approval;
- downstream systems enforce least privilege.

If the detector misses a novel phrasing, those boundaries still limit effect.

### Indirect prompt injection

The attacker places instructions in a document, web page, issue, email, image, tool output or other retrievable source. A legitimate user unknowingly brings it into context.

This is especially dangerous because the application may trust the user while forgetting that the content has a different author. Preserve source identity, separate content from policy, restrict retrieval by user ACL, disable unnecessary external fetches and assume content may influence the proposal. Do not let a retrieved URL become an allowed egress destination.

### Retrieval and embedding poisoning

An attacker adds, modifies or strategically ranks content so it appears for important queries. The poisoning may be obvious instructions, subtly false operational advice or a trigger that activates only for one target.

Investigate:

- who could write and approve source documents;
- ingestion identities and transformations;
- source and index digests;
- deletion and update propagation;
- ranking and freshness changes;
- tenant separation;
- anomalous source dominance;
- evaluation cases for affected slices.

Rebuilding the index from the same poisoned sources reproduces the problem. Restore from known-good source state, then create a new immutable index release.

### Training, fine-tuning and label poisoning

Poisoning can enter pre-training, fine-tuning, preference data, labels or evaluation sets. It can degrade general behavior, bias one cohort, install a rare trigger or make the evaluation falsely pass.

Controls begin long before training:

- authorized sources and intended-use rights;
- immutable snapshots;
- contributor and transformation lineage;
- schema, distribution, duplicate and outlier analysis;
- protected holdout sets;
- independent evaluation;
- change review and source diversity;
- sample-level traceability where lawful and practical.

A dataset digest proves which bytes were used, not that the bytes were correct. A clean aggregate metric can hide a trigger or harmed slice.

### Model and dependency supply-chain compromise

An artifact may be replaced in a registry, built from different source, signed by the wrong identity, depend on a vulnerable library or execute code when loaded.

Admission should separately evaluate:

1. immutable artifact digest;
2. expected signer identity and issuer;
3. signature and digest claims;
4. source and build provenance;
5. trusted builder and workflow;
6. SBOM and ML-BOM inventory;
7. vulnerability and policy results;
8. model format and loader behavior;
9. compatibility;
10. behavioral evaluation.

Do not deserialize an untrusted code-executing model inside a privileged scanner just to find out what it does. Inspect metadata without executing it, use safer formats where possible, and isolate any necessary conversion with no credentials, no broad filesystem, restricted egress and disposable state.

### Improper output handling

Generated content becomes dangerous when another component interprets it. Common sinks include browsers, Markdown renderers, SQL engines, shells, template engines, file APIs and HTTP clients.

“The model would never output that” is not a validation rule. Treat output like attacker-controlled input:

- parse one expected format;
- reject rather than repair ambiguous objects;
- enforce a strict schema and semantic constraints;
- use safe parameterized APIs;
- encode for the final rendering context;
- constrain targets from trusted inventory;
- keep downstream permissions narrow.

Validation must happen at every new interpreter boundary. Safe JSON can contain an unsafe URL; safe URL syntax can still reach cloud metadata or an internal admin endpoint.

### Excessive agency

OWASP describes excessive functionality, permissions and autonomy. Those dimensions multiply:

- **Functionality:** which operations are exposed? A generic shell is far broader than `get_pod_status`.
- **Permissions:** what can the tool identity actually reach? A read tool should not hold delete rights.
- **Autonomy:** which effects can commit without a reviewer or independent policy?

Reduce all three. Logging and rate limits limit damage and improve detection, but they do not replace mediation.

### Sensitive-information leakage

Leakage may expose training data, retrieved documents, prompts, system instructions, secrets, tool responses, embeddings, caches or logs. The output channel is not the only path; URLs, images, DNS, error messages and tool arguments may carry data.

Classify data at ingestion, minimize context, enforce source ACLs before retrieval, isolate tenants, use secret handles instead of secret values, allowlist egress, validate output and manage retention. System-prompt confidentiality may be useful, but do not put credentials or a sole security control in a prompt and assume secrecy.

### Audit and observability compromise

Raw “log everything for debugging” designs often replicate the most sensitive content into systems with wider access and longer retention. Tokens or credentials in logs require rotation, not just a dashboard filter.

Structured evidence should record identity, versions, decisions, digests, classifications and effect receipts. Mask or omit content before export. Monitor dropped events and log-pipeline failure; missing audit must be visible. Protect integrity and access, but retain enough evidence to meet incident and legal duties. During an incident, coordinate preservation before deletion.

### Kill-path failure

An in-band stop prompt fails if:

- the model ignores it;
- queued calls no longer consult the model;
- workers cached credentials;
- downstream retries continue;
- the broker is compromised;
- network calls are already in flight.

Rehearse route denial, credential revocation, egress blocking, queue pause/quarantine and fallback. Measure invocation-to-enforcement time and reconcile every queued idempotency key. Four “stopped” queues and one forgotten worker are not containment.

## Internals and state ownership

Security diagrams become operational only when every important state object has an owner and lifecycle.

### Context state

Context includes system instructions, user messages, retrieved content, tool results and sometimes memory. Record immutable version identities where possible. Define:

- who may write each source;
- how ACLs are enforced before retrieval;
- how tenant and user scope propagate;
- maximum size and age;
- which content is persisted;
- deletion propagation into indexes, caches and traces;
- whether prior tool output can introduce instructions into later turns.

Conversation memory is not an authority store. A statement from an earlier turn such as “the administrator approved all future changes” must not survive as reusable permission.

### Tool-catalog state

The tool catalog defines reachable functionality and schemas. It belongs to a reviewed release, not to the model. Each tool needs:

- stable name and version;
- narrow purpose;
- strict input and output schema;
- semantic constraints;
- risk class;
- required user and workload permissions;
- approval rule;
- idempotency behavior;
- deadline and retry contract;
- rate/concurrency limit;
- audit fields;
- kill control and owner.

Remove obsolete tools. An unused send or delete function remains attack surface.

### Authorization and approval state

Policy bundles are immutable releases with authors, reviews, tests, signatures or integrity identity and rollout history. A decision record needs the policy revision, input identity, result and reason.

Approval state needs request digest, approver, scope, separation-of-duties result, timestamp, expiry, nonce and status. It must be single-use or explicitly bounded. Cancellation and expiry propagate to queued work.

### Credential state

Prefer short-lived workload identity and delegated, audience-bound capability over long-lived shared secrets. The broker can exchange trusted user context for a narrowly scoped downstream credential without exposing it to the model.

Track:

- issuer and subject;
- audience;
- scopes or roles;
- tenant and resource constraints;
- issue and expiry time;
- rotation and revocation path;
- where it can be cached;
- observed use.

No prompt, trace or model-visible tool result should contain a reusable token.

### Data and artifact state

Datasets, indexes, models, prompts, policies, dependencies and images form one release graph. Mutable aliases are convenient navigation, not evidence. Resolve them to immutable versions and digests at admission and request time.

An artifact record should connect source revision, builder, workflow, dataset, transformations, model format, evaluation, signature, signer policy, inventories and deployment. If any edge is unknown, state the limitation instead of inventing provenance.

### Queue and effect state

Asynchronous agents need explicit action states and an authoritative owner. Store normalized arguments and digests, not only prose. Use one idempotency key through retries. Record leases, attempts, deadlines and effect receipts.

During containment, enumerate:

- waiting items that can be denied;
- leased items that may still commit;
- in-flight downstream calls;
- completed effects requiring reconciliation;
- unknown states requiring authoritative lookup.

Never clear a queue merely to make a dashboard green; first preserve identities and decide how each item is reconciled.

### Audit state

OPA's decision-log design illustrates useful fields such as decision, trace and policy-bundle identities, and it explicitly supports masking sensitive input or result fields. The general lesson is broader than one product: audit needs a schema and data policy.

Define:

- event producer and clock;
- trace, request, action, decision and effect IDs;
- policy and release revisions;
- privacy classification and redaction;
- transport authentication;
- integrity or tamper-evidence requirement;
- retention, deletion and legal-hold behavior;
- access roles and access audit;
- buffering, retry, drop and backpressure behavior.

An unavailable audit sink should not silently discard high-risk decisions. Whether it fails the operation closed or buffers locally depends on risk and capacity, but the choice must be deliberate and observable.

### Kill and recovery state

A kill control has scope: one user, tenant, tool, model release, route or whole feature. Broad global stops are simple but can create major availability impact; narrow stops require reliable identity propagation.

Record invocation, actor, reason, scope, desired state, fan-out targets, acknowledgement times, credential revocations, queue dispositions and exceptions. Recovery is a new controlled transition, not “toggle it back on.” It requires a known-good release, repaired boundary, regression evidence, rotated authority, reconciled effects and monitored staged exposure.

## Evidence table

Use this table during design reviews and incidents. The last column prevents a useful signal from becoming an inflated claim.

| Claim | Strong evidence | What it still does not prove |
|---|---|---|
| The request came from this user | Valid authenticated session, issuer, subject, audience and authentication time | The requested effect is authorized |
| Retrieved content was allowed | Source ACL decision for the same subject, tenant and object version | The content is correct or non-hostile |
| This exact model ran | Release ID, artifact digest and runtime load receipt | The output was safe or useful |
| The artifact is intact | Digest match | Who produced it or whether it is safe |
| The artifact is signed | Verified signature, certificate chain and digest claim | Expected signer, safe format or behavior unless policy checks them |
| The artifact followed the build path | Verified provenance with trusted builder/workflow and source inputs | Clean training data or acceptable runtime behavior |
| The output matched JSON | Strict parse and schema result | Semantic safety for SQL, URL, path, HTML or a tool |
| The tool call was authorized | Decision ID with authenticated subject, action, target and policy revision | The downstream effect committed as intended |
| A human approved | Authenticated, unexpired approval bound to exact preview digest | State stayed unchanged before commit |
| The action succeeded | Downstream effect receipt and verified postcondition | The user outcome was beneficial |
| The detector blocked the attack | Versioned labeled case and detector decision | System-level harm prevention or novel-attack coverage |
| The kill switch fired | Invocation and controller acknowledgement | Every queued/in-flight effect stopped |
| The incident is contained | Route deny, credential revocation, egress and complete action reconciliation | Root cause is eradicated |
| Audit is complete | Sequence and coverage checks, producer health and dropped-event metrics | Events outside instrumented boundaries |
| Logs are privacy-safe | Schema, masking tests, access review and retention proof | Compliance for an unspecified jurisdiction |

### Measure layers separately

For 200 labeled attacks, if a detector blocks 159, its observed recall is:

```text
detector recall = blocked attacks / labeled attacks
                = 159 / 200
                = 79.5%
```

If deterministic authorization blocks 35 of the 41 detector escapes and approval blocks four more, report those layers separately:

```text
escaped detector        = 41 / 200 = 20.5%
contained after escape  = 39 / 41  = 95.12%
effects observed        = 2 / 200  = 1%
```

Do not average 79.5% and 95.12%. They have different denominators and meanings. If the protected invariant is zero unauthorized production changes, even one effect fails the gate.

Slice by attack path. Aggregate recall can hide weak poisoned-retrieval coverage. Also report benign false positives because an unusable control will be bypassed under operational pressure.

## Command decoders

The lab commands are deliberately small. Read them as questions, not incantations.

### `bash lab.sh doctor`

This refuses root, common external AI credentials and `KUBECONFIG`, then validates the source fixture. Success means the local teaching preconditions pass. It does not inspect the host, install software or prove any security control.

### `bash lab.sh setup`

This creates only `/tmp/reliability-atlas-les0069-ai-security-<uid>` with a private umask, sentinel and copied fixture. It refuses an existing or suspicious target. If setup says `state-exists`, inspect ownership and use the guarded cleanup rather than deleting a guessed path.

### `bash lab.sh status`

This inventories the exact two allowed artifacts and reports the case count. An unknown file makes it fail. That refusal is intentional: cleanup code must not remove a directory it no longer understands.

### `bash lab.sh show baseline`

This prints the resolved synthetic state. It helps connect JSON inputs to a decision. The values are booleans in a teaching model, not measurements from a real policy engine or AI system.

### `bash lab.sh evaluate <case>`

This returns the first failed boundary in a fixed order. For example:

```text
case=retrieved-content-authoritative boundary=content-authority
```

That means the fixture represents untrusted content changing authority. It does not mean a detector found a real injection.

### `bash verify.sh`

From absent state, the verifier exercises all 31 branches, proves the expected boundary for each, injects an unknown artifact to test refusal and proves cleanup. A pass validates the teaching harness only.

### Production command discipline

In a real incident, prefer read-only evidence before mutation:

```bash
# Illustrative local JSON inspection; replace paths with reviewed evidence files.
jq '{subject,tenant,operation,target,policy_revision,decision,effect_id}' decision.json
jq -r '.actions[] | [.id,.state,.effect_id] | @tsv' action-ledger.json
sha256sum model-artifact
```

These examples assume `jq` and `sha256sum` exist and the files are sanitized local copies. A digest mismatch proves bytes differ, not why. A ledger row proves only what the ledger recorded until reconciled with the target system.

For container admission, an identity-constrained verification is conceptually stronger than “signature present.” Sigstore's exact CLI and bundle behavior are version-sensitive, so use the installed version's official documentation and verify expected certificate identity, issuer and claims. Never paste production credentials or private artifact URLs into a lesson terminal.

## Decision path

Use this order so a late sophisticated control cannot hide an early basic failure:

1. **Operation:** Is the user operation, prohibited harm, target and fallback defined?
2. **Threat model:** Are actors, assets, entry points, authority and invariants explicit?
3. **Content:** Are origin, ACL, tenant, classification and lifecycle known? Can content alter policy?
4. **Output:** Does one strict schema parse, and is the normalized value safe for its exact sink?
5. **Tool:** Is functionality minimal and typed? Is open-ended shell, URL or SQL avoidable?
6. **Identity:** Is the authenticated subject and tenant propagated outside the model?
7. **Authorization:** Does deterministic policy mediate this subject, action and target? Does the downstream system enforce again?
8. **Secrets:** Are credentials short-lived, audience-bound, scoped, revocable and invisible to the model?
9. **Isolation:** Are filesystem, network, process, device and resource boundaries appropriate?
10. **Approval:** Is high-impact work bound to an immutable preview, approver authority, expiry and fresh state?
11. **Data and model:** Are origin, transformations, integrity, evaluation and immutable versions known?
12. **Supply chain:** Are signer/issuer policy, provenance, inventories, vulnerabilities, format and admission distinct gates?
13. **Audit:** Can decisions and effects be reconstructed without leaking sensitive content?
14. **Adversarial evaluation:** Do credible attacks test protected system invariants and downstream effects?
15. **Kill:** Can an independent control deny routes, revoke authority and account for queued work?
16. **Recovery:** Can the team reconcile effects, restore a known release and prove postconditions?
17. **Risk:** Is remaining risk stated, owned, time-bounded and accepted by the right authority?

Stop at the first failed boundary when deciding whether to expose the capability. Continue collecting other evidence during diagnosis; multiple failures often coexist.

## Guided Ubuntu lab

The lab is in `support/lab`. It needs Ubuntu 24.04, Bash and Python 3 as a normal user. It uses no network and no package installation.

### Safety read

Before running:

- open `lab.sh` and confirm the state path is UID-scoped under `/tmp`;
- confirm root is refused;
- confirm the sentinel and exact inventory protect cleanup;
- confirm common external AI credentials and `KUBECONFIG` cause refusal;
- confirm the Python file performs JSON decisions only.

If those statements are not true in your copy, stop. Never “fix” the lab by removing guards.

### Run the complete lifecycle

```bash
cd drafts/LES-0069-ai-security-trust-boundaries/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
```

Expected shape:

```text
model=valid cases=31
doctor=pass network=none user=<uid>
model=valid cases=31
setup=pass state=/tmp/reliability-atlas-les0069-ai-security-<uid>
status=ready cases=31 state=/tmp/reliability-atlas-les0069-ai-security-<uid>
case=baseline boundary=operable
```

Your UID and ordering of unrelated terminal output may differ. Do not treat the word `operable` as a production claim; it is the name of the all-true synthetic branch.

### Walk the boundary ladder

```bash
bash lab.sh evaluate retrieved-content-authoritative
bash lab.sh evaluate output-sink-unvalidated
bash lab.sh evaluate tool-authorization-missing
bash lab.sh evaluate approval-preview-changed
bash lab.sh evaluate model-provenance-missing
bash lab.sh evaluate executable-model-format
bash lab.sh evaluate audit-content-unredacted
bash lab.sh evaluate containment-path-dependent
```

For each result, explain:

1. which trust assumption failed;
2. what harmful effect becomes possible;
3. which deterministic component owns prevention;
4. what evidence would prove the boundary in production;
5. what the local result cannot prove.

Example: `boundary=approval-binding` means approved and committed proposals may differ. Prevention belongs to the approval/commit service, which binds a digest, target, expiry and nonce and revalidates before effect. Production proof includes the preview, approval and effect receipts. The local boolean cannot prove a human understood the preview.

### Verify refusal and cleanup

```bash
bash verify.sh
```

Expected:

```text
verify=pass cases=31 refusal=true cleanup=true
```

If interrupted, run `bash lab.sh status` and then `bash lab.sh cleanup`. Cleanup refuses unknown state. Do not use a broad recursive delete. Preserve the first failure and inspect the guarded directory.

### Guided incident exercise

Assume `retrieved-content-authoritative`, `shared-service-identity` and `audit-content-unredacted` occur together. Write a six-part response:

1. deny new effect-capable calls outside the model;
2. revoke the shared synthetic identity;
3. preserve sanitized decision and source identities;
4. reconcile attempted versus committed actions;
5. repair content labeling, per-user mediation and audit minimization;
6. rerun relevant attack paths and independent containment before staged recovery.

The exercise is complete only when you can explain why a stronger prompt is insufficient and why deleting all logs immediately can destroy evidence.

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
