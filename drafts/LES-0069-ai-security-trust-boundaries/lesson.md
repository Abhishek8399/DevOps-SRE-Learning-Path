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
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic trust-boundary lifecycle verified as UID 1000 on 2026-08-07; no external system or AI behavior."},
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
  "contentStatus": "substantive-draft",
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

The local lab teaches decision order. Production transfer means replacing every boolean with owned evidence from a real component. Never say “the lab proves our agent is secure.” Say which production boundary now supplies the corresponding evidence.

### Translate each synthetic boundary

| Lab boundary | Production owner | Representative evidence |
|---|---|---|
| `operation-contract` | Product and service owner | Operation catalog, prohibited effects, SLO, fallback and risk classification |
| `threat-model` | Security plus system owners | Data-flow diagram, actors, assets, entry points, invariants and reviewed abuse cases |
| `content-origin` | Ingestion and retrieval platform | Source ID, ACL decision, tenant, digest, transformation, timestamps and classification |
| `content-authority` | Context assembler and broker | Separation design plus tests proving content cannot alter deterministic policy |
| `output-schema` | Application parser | Pinned schema, parser configuration, rejection tests and size limits |
| `output-validation` | Sink adapter | Semantic constraints, safe API use, contextual encoding and negative tests |
| `tool-functionality` | Tool-platform owner | Reviewed catalog showing only operation-specific capabilities |
| `tool-authorization` | Policy owner and broker | Subject/action/target decision with policy revision and deny tests |
| `downstream-authorization` | Target-system owner | IAM/RBAC policy, effective-permission test and effect receipt |
| `identity-propagation` | Identity platform | Authenticated subject and tenant bound through request, broker and target |
| `secret-scope` | Identity/secrets platform | Audience, scopes, resource limits, TTL, rotation and revocation evidence |
| `sandbox-isolation` | Runtime platform | Workload configuration and escape/egress/resource tests |
| `approval-binding` | Approval and commit service | Preview digest, approver, expiry, nonce, fresh revalidation and committed digest |
| `data-provenance` | Data platform | Authorized source, snapshot, transformation run, reviewer and digest |
| `model-provenance` | ML platform | Model digest, source/build/train lineage, evaluation and admission receipt |
| `signer-policy` | Supply-chain platform | Expected identity, issuer, trusted roots, verified claims and policy version |
| `artifact-format` | Runtime and security owner | Admitted format, loader behavior, isolation and malicious-fixture tests |
| `audit-privacy` | Observability and privacy owners | Structured schema, masking tests, access, retention and deletion proof |
| `adversarial-evaluation` | Security evaluation owner | Versioned threats, invariants, denominators, escapes and downstream outcomes |
| `kill-path` | Incident-control owner | Out-of-band invocation, propagation, denial, revocation and acknowledgement |
| `kill-accounting` | Queue and target owners | Every queued action reconciled by stable action/idempotency identity |
| `recovery-proof` | Service owner and incident command | Known-good release, rotated authority, repaired boundary and verified postconditions |
| `risk-ownership` | Accountable business/security authority | Residual-risk statement, evidence, expiry, conditions and signed decision |

### Example: Kubernetes-hosted remediation assistant

Suppose the assistant runs in Kubernetes and restarts only test Deployments.

The platform should not mount a human administrator's `KUBECONFIG`. A broker workload gets a narrowly scoped service identity. The model-facing process does not receive that credential. The broker accepts a typed request such as namespace, Deployment name and operation enum. Policy verifies the authenticated subject and inventory ownership. Kubernetes RBAC limits the broker identity to a dedicated API or a tightly bounded set of verbs and namespaces.

Container isolation adds defense:

- non-root process and immutable image digest;
- read-only root filesystem where compatible;
- no privilege escalation and dropped capabilities;
- default-deny network policy with explicit destinations;
- no host namespace, host path or container-runtime socket;
- CPU, memory and ephemeral-storage limits;
- separate identities for retrieval, proposal and commit services;
- Pod Security Admission aligned to the workload's needs.

These controls reduce blast radius. They do not make arbitrary model-generated shell safe. A generic `kubectl` or shell tool remains unnecessarily broad when a narrow restart API can express the operation.

### Example: document assistant with no mutation

A read-only assistant can still leak data. Retrieval authorization must occur before content enters context, using the same user and tenant boundary. Cache keys include tenant, user or entitlement boundary, immutable index and policy identity. Output rendering uses contextual encoding; outbound links and image fetches do not automatically carry private context.

The safer fallback is often “return source links the user already may open” rather than copy every private document into a long-lived transcript. If the model service is unavailable or policy evidence is stale, return an explicit unavailable result instead of querying through a privileged shared account.

### Example: code assistant and CI

Generated code is output entering compilers, package managers, tests, shells and deployment pipelines. Keep it on an untrusted contribution path:

1. create a branch or patch, not a direct protected-branch mutation;
2. identify generated changes and the model release;
3. run formatting, tests, static analysis, secret detection and dependency policy;
4. resolve every suggested package through the normal approved registry and lockfile process;
5. require human review for material changes;
6. build in an isolated, ephemeral worker with minimal secrets and egress;
7. generate provenance and sign the resulting artifact through the trusted pipeline;
8. deploy with normal progressive delivery and rollback controls.

The model's statement that a package exists is not registry evidence. The model's successful unit test is not a CI result. Never execute an unreviewed generated install command with broad developer credentials.

### Production incident: harmful tool proposal

At 14:02 an indirect instruction in a ticket causes an assistant to propose sending a diagnostic bundle to an unfamiliar host. The broker denies the host because it is not allowlisted. At 14:05 responders learn that an older worker bypassed the broker and holds a broad egress-capable credential.

The incident commander should:

1. disable both current and legacy tool routes outside the model;
2. revoke the relevant workload credentials and block egress at the network boundary;
3. preserve request, ticket-source, release, worker, credential, policy and network identities;
4. enumerate proposed, authorized, attempted and committed actions from broker and downstream evidence;
5. investigate whether other content reached the legacy path;
6. remove the bypass, rotate affected authority, reconcile partial effects and notify owners;
7. add the legacy path to inventory, red-team cases and kill fan-out;
8. restore a known release in read-only mode, then stage bounded tool capability only after independent evidence.

Do not close the incident because the current broker logged `deny`. The bypass makes the system boundary larger than the dashboard.

## Reliability, security, observability, capacity, and cost

Security controls are production services. They can fail open, fail closed, overload, drift, create noisy alerts or become too expensive to operate. Design their service contracts explicitly.

### Reliability

For each operation, decide what happens when identity, policy, approval, signature verification, audit or the target system is unavailable.

- High-impact mutations usually fail closed.
- Low-risk read-only answers may degrade to cached public content or a non-AI path.
- Cached authorization needs a short TTL, policy identity and revocation semantics.
- Audit buffering needs bounded disk/memory and visible drops.
- Queue consumers must check kill and authorization state at commit time, not only enqueue time.
- Credential revocation needs measured propagation and a plan for cached tokens.

Define control SLOs around decisions that matter: policy decision availability and latency, approval completion, audit delivery, kill propagation and queue reconciliation. A policy engine with 99.9% availability may still be unacceptable if the missing 0.1% fails open for production deletion.

### Security

Layer controls by independent failure mode:

```text
detector signal
    -> strict parse and semantic validation
    -> minimal tool catalog
    -> per-subject policy
    -> downstream least privilege
    -> bound approval for high impact
    -> rate/concurrency limits
    -> independent kill and recovery
```

Independence matters. If one model decides that input is safe, selects the tool, authorizes it, approves it and declares success, the layers are names around one failure.

Protect the security system itself:

- limit who can change prompts, tool definitions, policy and trusted signers;
- require reviewed, versioned releases;
- separate development, evaluation and production authority;
- monitor emergency overrides;
- rotate signing and workload keys;
- secure red-team datasets because they can contain sensitive attack knowledge;
- restrict audit access and record access to the audit system.

### Observability

Observe both decisions and effects without storing uncontrolled content.

Useful counters and distributions include:

- requests and actions by operation, risk, release and decision;
- detector blocks by technique and version;
- schema/semantic rejection reasons;
- policy allows/denies and stale-policy decisions;
- approval requests, expiry, rejection and time-to-decision;
- downstream attempts, commits, failures, uncertain states and reconciliation age;
- cross-tenant denial attempts;
- kill invocation-to-acknowledgement and remaining queued work;
- audit buffer depth, export failures and dropped events;
- redaction/masking failures;
- artifact admissions and rejection reasons;
- credential age, scope and revocation latency.

Avoid unbounded labels such as raw prompt, document ID, URL, user email or tool arguments in metrics. Keep high-cardinality identity in sampled or structured stores with access control, and use stable low-cardinality dimensions in metrics.

Alert on user-impacting or boundary failures, not every odd prompt. One blocked injection is evidence the boundary worked. A surge may indicate attack or bad content and deserves investigation, but paging every block teaches operators to disable the control.

### Capacity

Security adds work:

- input and output scanning;
- schema and policy evaluation;
- approval queues;
- signature and provenance verification;
- sandbox startup;
- audit serialization and export;
- red-team suites in delivery pipelines;
- kill fan-out and reconciliation.

Capacity-plan peak incident conditions. A mass kill may create the highest decision and queue-reconciliation load of the year. Audit pipelines may receive larger events exactly during attack. If the policy service saturates, retries can amplify the outage. Use deadlines, bounded retries, bulkheads, admission control and load tests with safe synthetic data.

Human review is also capacity. If 10,000 daily actions require approval, reviewers will rubber-stamp or the service will stall. Reduce approval volume by removing unnecessary autonomy, keeping risky operations rare and enabling low-risk deterministic automation with clear limits. Approval is not a substitute for good authorization.

### Performance

Budget latency per stage:

```text
total = authentication
      + retrieval and ACL
      + model generation
      + parse/validation
      + policy
      + approval wait (when required)
      + downstream commit
      + outcome confirmation
```

Do not bypass a boundary to save milliseconds without an explicit risk decision. Optimize with local policy evaluation, narrow schemas, preverified immutable artifacts, connection reuse and asynchronous workflows where the user contract permits. Preserve one end-to-end deadline so retries do not outlive user intent or approval.

### Cost

Track cost per useful, authorized outcome rather than cost per model request. Include:

- model tokens or accelerator time;
- retrieval and storage;
- policy and scanning services;
- sandbox workers;
- human approval and investigation time;
- audit storage and egress;
- red-team and release-validation compute;
- incident harm and recovery.

Security controls can reduce cost by preventing runaway tool loops, unbounded output, data exfiltration response and unsafe releases. Cost pressure must not silently widen permissions, retain less evidence than required or replace independent review with a self-scoring model. Document accepted trade-offs and review them against observed false positives, escaped attacks and operational toil.

## Traps and prevention

### Trap: “The system prompt is secret”

**Why it fails:** prompts can leak, behavior can be inferred, and the prompt is interpreted beside attacker-influenced text.

**Prevention:** keep secrets out of prompts; use prompts for behavior guidance and deterministic systems for identity, authorization and enforcement.

### Trap: “Our injection classifier passed”

**Why it fails:** tests cover a finite distribution, attackers adapt, indirect and multimodal paths differ, and false positives create bypass pressure.

**Prevention:** measure the detector by technique and benign slice, then observe whether escaped proposals can create effects. Keep least privilege and mediation primary.

### Trap: “Valid JSON is safe”

**Why it fails:** JSON can contain an internal URL, traversal path, dangerous query or unauthorized target.

**Prevention:** strict schema plus semantic and sink-specific validation, trusted inventory resolution, safe APIs and downstream authorization.

### Trap: “The tool is read-only”

**Why it fails:** reads can disclose secrets, trigger side effects, consume resources or reach other tenants. Some HTTP GET endpoints mutate.

**Prevention:** define exact operation semantics, target scope, identity and data classification; test the downstream implementation.

### Trap: “The service account needs admin so the agent can help everyone”

**Why it fails:** it turns the application into a confused deputy and destroys user/tenant boundaries.

**Prevention:** propagate subject and tenant, use delegated or resource-scoped capability, split tools and enforce again downstream.

### Trap: “A human clicked approve”

**Why it fails:** the preview may be vague, mutable, expired or different from committed bytes; reviewers may lack authority.

**Prevention:** immutable precise preview, digest, target, effect, expiry, nonce, approver authorization, separation of duties and pre-commit revalidation.

### Trap: “Signed means safe”

**Why it fails:** the signer may be wrong or compromised, the artifact format may execute code, dependencies may be vulnerable and behavior may be harmful.

**Prevention:** constrain identity and issuer; verify provenance, inventory, format and evaluation as separate gates.

### Trap: “Run the untrusted model in our scanner”

**Why it fails:** loading may execute code before scanning, using the scanner's filesystem, network or credentials.

**Prevention:** do not deserialize merely to inspect. Prefer safe formats and metadata inspection; isolate necessary conversion in a disposable credential-free environment.

### Trap: “Log every prompt for forensics”

**Why it fails:** logs become a high-value copy of secrets and private content with broad access and long retention.

**Prevention:** structured events, minimization, masking before export, protected content references, retention classes and access auditing.

### Trap: “Tell the agent to stop”

**Why it fails:** queued workers and credentials continue; the compromised loop controls its own stop.

**Prevention:** out-of-band route deny, credential revocation, egress control, queue quarantine and complete action reconciliation.

### Trap: “Delete the evidence immediately”

**Why it fails:** responders lose scope, effect and disclosure evidence and may violate preservation duties.

**Prevention:** restrict access and unsafe capture, coordinate legal/privacy/incident requirements, preserve the minimum protected evidence, then remediate lifecycle safely.

### Trap: “No alert means no attack”

**Why it fails:** telemetry coverage, masking, drops, clock errors or detector blind spots may hide activity.

**Prevention:** monitor coverage and drops, reconcile downstream state, test negative controls and state evidence limits explicitly.

## Memory card and retrieval

Use **T-P-A-E-S-R** under pressure:

```text
T  Text is untrusted: user, document, tool result, model output
P  Proposal is typed: parse, normalize, validate for the exact sink
A  Authority is deterministic: subject, tenant, action, target, policy
E  Effect is downstream: idempotency key, commit receipt, postcondition
S  Stop is independent: deny, revoke, block, quarantine, account
R  Recover with evidence: scope, rotate, reconcile, restore, retest, own risk
```

### Sixty-second incident recall

If an agent appears unsafe:

1. **Contain:** disable effect paths outside the model and revoke authority.
2. **Preserve:** request, release, content source, policy, credential, action and effect identities.
3. **Reconcile:** proposed is not authorized; authorized is not committed; committed is not a good outcome.
4. **Scope:** users, tenants, tools, destinations, releases, time and telemetry gaps.
5. **Eradicate:** remove bypasses, poison, unsafe artifacts and leaked credentials.
6. **Recover:** known release, repaired boundaries, clean state, staged exposure.
7. **Learn:** add threat cases, metrics, runbooks, ownership and residual-risk review.

### Five questions for any AI architecture

- Where does untrusted text enter?
- Where is authenticated identity preserved?
- Which deterministic component authorizes each effect?
- What evidence proves downstream state?
- How can responders stop it without model cooperation?

If a diagram cannot answer those questions, it is not yet an operational security architecture.

### Flash cards

**Prompt injection versus poisoning?** Injection manipulates runtime context or behavior through input; poisoning changes training, evaluation, embedding or retrieval sources/artifacts. They can combine.

**Signature versus provenance?** A signature verifies a statement under a key/identity policy; provenance describes production history. Neither alone proves safe behavior.

**Approval versus authorization?** Authorization determines whether the subject may act; approval is an additional decision for a particular proposed effect. Both may be required.

**Detector versus invariant?** A detector predicts whether input resembles an attack; an invariant defines a system condition that must hold, such as no unauthorized commit.

**Kill versus recovery?** Kill stops or bounds new effects. Recovery establishes known state, reconciles existing effects and safely resumes.

## Complete answers

### 1. Why can prompt injection not be solved only by a better system prompt?

**Direct answer:** The system prompt and attacker-influenced content are interpreted by the same probabilistic model. Prompt hierarchy can improve behavior, but it does not authenticate identity, enforce permission or guarantee that a downstream effect is denied.

**Reasoning:** A direct attacker can vary wording and encoding. An indirect attacker can place instructions in a file, image or tool result. A future model or prompt version may react differently. Even a perfect refusal in the current turn cannot stop a previously queued action. Therefore, design for proposal compromise: the model has no direct credential, tools are minimal and typed, deterministic policy checks subject/action/target, downstream systems enforce least privilege, approvals bind high-impact effects and an out-of-band path can stop work.

**Weak answer:** “Prompt injection is impossible to prevent, so AI agents cannot be used.” This jumps from imperfect detection to no useful control. We routinely build secure systems around untrusted input by constraining authority and effects.

### 2. A model emits valid JSON for a tool. Is it safe to execute?

**Direct answer:** No. Syntax is only the first boundary.

Assume the output is:

```json
{"operation":"fetch_url","url":"http://internal-service/admin"}
```

The JSON may match types while violating the operation contract. The application must reject unknown fields and excessive input, normalize values, constrain schemes/hosts/ports/redirects, prevent DNS or address rebinding where relevant, enforce egress at the network layer and authorize the exact destination. Better, replace open-ended fetch with an operation that resolves an approved source ID through trusted inventory.

For SQL, use a narrow query API and parameterization; for files, resolve beneath an owned root with safe APIs; for HTML, encode for the rendering context; for shell, avoid free-form commands. The target system must enforce permissions independently.

### 3. What does a valid artifact signature prove?

**Direct answer:** It proves that a signature over particular data verifies under a key or certificate. Under a correctly constrained policy, it can bind artifact bytes and claims to an expected signer identity and issuer.

It does **not** alone prove:

- the signer was authorized by your organization;
- the signing key was uncompromised;
- the source and builder were trusted;
- the dataset was clean;
- dependencies were acceptable;
- the format is safe to load;
- the model behaves safely;
- the version is not an old vulnerable rollback.

Use digest, identity-constrained signature verification, provenance, inventories, update/rollback controls, safe-format admission, vulnerability evidence and behavioral evaluation as separate gates. Preserve the verification receipt with the admitted release.

### 4. How do you design human approval that actually controls an effect?

**Direct answer:** Bind an authenticated, authorized approver to one immutable preview and revalidate immediately before commit.

The preview includes exact operation, target, environment, arguments, expected state change, important side effects, evidence, rollback, requester, policy decision, digest and expiry. Approval records the preview digest, approver identity, scope, time, expiry and nonce. Separation of duties applies where required.

Before commit, the service checks that:

- the proposal bytes and target still match;
- approval remains valid and unused;
- the approver and requester still have authority;
- current target state satisfies preconditions;
- policy/tool/release identity is acceptable;
- the kill state, deadline and budgets permit work.

The commit uses an idempotency key and returns an effect receipt. A general “yes” in a chat is not enough because later model output can change recipients, targets or arguments.

### 5. How should prompt-injection evaluation be measured?

Start from a threat model, not a bag of clever prompts. Represent direct, indirect, retrieval, encoded, split, multilingual and tool-result paths relevant to the actual system. Label benign cases too.

For each case record:

- technique and entry point;
- actor capability and content origin;
- protected asset and invariant;
- release, detector, policy and tool versions;
- expected decision;
- actual detector result;
- authorization/approval result;
- attempted and committed downstream effect;
- cleanup and reviewer judgment.

Report detector recall per attack slice, benign false-positive rate and precision when meaningful. Separately report escaped attacks contained by authorization/approval and the system attack-to-effect rate. Include uncertainty and do not claim novel-attack coverage. A model refusal is supporting evidence; the pass criterion is the protected invariant and downstream state.

### 6. What is the correct response when a kill switch leaves unknown queued actions?

**Direct answer:** Containment is unproven. Keep the route disabled and reconcile every stable action identity.

Identify waiting, leased, in-flight, completed, failed and uncertain actions. Deny waiting work, revoke credentials, block egress as needed and query authoritative target state or idempotency records for uncertain calls. Preserve timestamps from kill invocation through controller and worker acknowledgement. Undo reversible unauthorized effects safely; do not blindly retry or delete queue records.

Repair the propagation or inventory gap, add the missed worker to kill fan-out, test under load and prove all dispositions before recovery. Report the limitation honestly: “new broker calls were denied” is narrower than “the system was contained.”

### 7. Should raw prompts be retained for security investigations?

Only when a documented purpose, legal basis, access model and retention period justify the exposure. Raw prompts can contain credentials, private documents, regulated data and attacker material. Default to structured records with stable content references, digests, classifications, model/prompt/policy/tool versions, decisions and effect receipts.

If protected content capture is necessary, separate it from general logs, encrypt it, restrict and audit access, mask before export, define deletion and legal hold, test redaction and monitor drops. During an incident, stop unsafe new capture and restrict exposure while coordinating evidence preservation. Do not destroy required evidence reflexively.

### 8. How do reliability and security interact when policy is unavailable?

The answer depends on the operation's harm contract. A production mutation should fail closed or enter a previously reviewed safe queue state. A public-document summary might degrade to a non-personalized cache. The decision must be explicit and tested.

Avoid unbounded retries: they can overload the policy service and outlive user intent. Use one deadline, bulkheads, local verified policy bundles where appropriate, health and staleness signals, and clear degraded modes. Measure decision latency, availability, stale use and fail-open/fail-closed counts. Reliability is what keeps the security boundary present during failure.

## Product-company interview

### Interview 1 — Design a secure incident-remediation agent

**Level:** Senior / Staff

**Evaluates:** threat modeling, distributed authorization, operational safety and system design.

**Strong answer:** Begin with a narrow operation and prohibited effects. Draw user, content, model, parser, broker, approval and target boundaries. Keep credentials out of the model. Expose typed read tools first, propagate user/tenant identity, authorize every subject/action/target in deterministic policy and enforce least privilege downstream. For mutations, use immutable preview, authorized approval, fresh revalidation, idempotency and effect receipts. Label and ACL retrieved content, validate output for each sink, isolate runtimes and allowlist egress. Release immutable model/prompt/policy/tool versions through provenance and evaluation gates. Observe decisions and outcomes with redacted audit. Provide route deny, credential revocation, queue quarantine and a safe non-AI fallback. Test direct/indirect injection against system invariants and rehearse recovery.

**Weak signals:** starts with model vendor; says “use guardrails”; gives the agent cluster-admin; treats approval text as authorization; has no queue/kill design.

**Follow-up:** “The policy service adds 80 ms. Remove it?”

**Senior response:** First compare the operation SLO and risk. Optimize through local verified bundles or co-location, not by bypassing mediation. For high-risk mutations, an explicit latency trade-off is preferable to unauthorized action. Measure tails and staleness.

### Interview 2 — A red-team suite blocks 98% of attacks. Can you launch?

**Level:** Senior

**Evaluates:** measurement literacy and risk judgment.

**Strong answer:** Not from that number. Ask denominator, threat coverage, attack slices, benign false positives, release versions and confidence. Determine what the 2% escapes can do. If deterministic authorization blocks every unauthorized effect, residual risk differs from an agent with administrator credentials. Inspect downstream outcomes, critical invariants, independent review, kill/recovery evidence and harmed-user slices. Launch is a conjunctive risk decision, not one averaged score.

**Follow-up:** “No escaped attack caused an effect in 1,000 cases.”

**Senior response:** That is useful bounded evidence, not proof of impossibility. Report the observed upper uncertainty, coverage and environment; keep least privilege, staged exposure, monitoring and an owned residual-risk decision.

### Interview 3 — Signed model, verified digest, still compromised

**Level:** Staff / Architect

**Evaluates:** supply-chain reasoning.

**Strong answer:** Preserve artifact, signature, certificate, provenance and admission receipts; stop loading or serving the affected release; scope hosts and credentials. Determine whether expected signer/issuer policy was enforced, whether the signer or build path was compromised, and whether the model format executed code. A digest proves identity and integrity; a signature under policy proves signer/claims; provenance describes production. None alone proves behavior or safe loading. Rotate affected keys/credentials, rebuild from known source with a trusted isolated builder, choose safe format, reevaluate behavior, prevent replay and stage recovery.

**Weak signals:** “Signature passed, so it cannot be supply chain”; loads the artifact in a privileged debugger; overwrites evidence.

### Interview 4 — Human approval did not prevent an external email

**Level:** Senior

**Evaluates:** TOCTOU, identity and incident response.

**Strong answer:** Stop send authority, preserve preview/approval/commit/effect identities and reconcile messages. Compare recipients, body and attachments by digest. Check approver authority, expiry, nonce and state revalidation. The likely flaw is that approval covered a draft while the agent could mutate it before send. Bind approval to exact bytes and recipients, require fresh authorization, use single-use idempotent commit and give the sender identity only the scoped capability. Rotate leaked credentials and notify affected owners.

**Follow-up:** “Would two approvers fix it?”

**Senior response:** Two people approving an unbound mutable preview repeat the same failure. Fix binding and authority first; use multiple approvers only when risk or regulation justifies it.

### Interview 5 — Kill switch says success; six actions finish

**Level:** Staff / Incident lead

**Evaluates:** containment evidence and leadership.

**Strong answer:** Declare containment incomplete, keep routes denied, revoke worker credentials and account for every queue/idempotency identity. Separate actions already committed before invocation from those committed during propagation. Query target systems, not only queue state. Measure acknowledgement and enforcement latency, find workers outside fan-out or holding cached credentials, reconcile/undo effects, and communicate known/unknown scope. Repair the control, test under load and recover through a known release and staged exposure.

**Weak signals:** trusts the UI; clears the queue; asks the model to stop; resumes after broker health turns green.

### Behavioral leadership prompt

**Question:** “A product leader wants launch today and says security is blocking innovation. What do you do?”

**Strong answer:** Translate findings into user and business effects, not abstract fear. State the exact failed invariant, evidence, likelihood limits, reversibility and exposure. Offer the smallest safe path: read-only mode, narrower cohort, no external tools, tighter identity, manual workflow or delayed risky capability. Name what must be true to expand and who owns residual-risk acceptance. Document the decision without exaggerating certainty. If an unauthorized high-impact effect remains credible and outside delegated risk authority, escalate through the defined governance path rather than silently accepting it.

## Independent transfer and rubric

`ASM-0192` is deliberately answer-isolated. Do not read `ASM-0190` or `ASM-0191` while performing it if the goal is genuine transfer. A reviewer owns the unseen environment and fault.

### Safe environment

Use synthetic identities, content, policies, artifacts, tools, approvals, queues and effects in a disposable local simulator. No customer data, real credential, shared service, production namespace, unrestricted shell, external model endpoint or external effect is allowed. The reviewer records the initial inventory and owns reset.

### Required phases

1. **Map:** define operation, actors, assets, trust boundaries, prohibited effects and residual-risk owner.
2. **Trace:** follow identity, content, proposal, policy, approval, commit, effect and audit.
3. **Review supply chain:** connect source, data, model, prompt, policy, tools, dependencies, build, signature, inventories and admission.
4. **Design evaluation:** choose credible threat paths, benign controls, slices, invariants, denominators and observable outcomes.
5. **Respond:** contain one reviewer-injected injection, poisoning, leakage, unsafe-tool or artifact incident without model cooperation.
6. **Recover:** reconcile all work, rotate synthetic authority, restore a known release and prove postconditions.
7. **Change:** revise after one material constraint, such as strict data residency, no human approval latency, multi-tenant isolation, policy outage or cost limit.
8. **Defend later:** explain decisions after a delay without the lesson open.
9. **Clean:** prove every process, file, port, queue, cache and synthetic record is absent or restored.

### Evidence standard

Screenshots and transcripts support evidence but do not replace authoritative state. Each claim binds subject, tenant, content origin, immutable release, policy/tool version and event time. The model transcript never proves authorization or effect. Detector metrics remain separate from authorization and downstream outcome. Signature, provenance, safe format and behavior remain separate claims.

### Scoring interpretation

The rubric totals 100:

- 90–100: strong expert candidate in the tested scenario; still not universal mastery.
- 80–89: good design with material gaps to repair and retest.
- 70–79: partial understanding; supervised practice required.
- below 70: do not claim transfer; revisit the first failed rubric domains.

Any real credential, external effect, hidden cleanup, fabricated evidence or bypassed safety guard invalidates the attempt regardless of score. Mastery requires reviewer-observed evidence, explanation, changed-constraint defense and delayed retrieval—not reading completion.

### Further exploration

- Build a policy-input schema for one real-looking but synthetic tool and enumerate every trusted versus untrusted field.
- Create an attack-to-invariant matrix from MITRE ATLAS techniques relevant to that tool.
- Compare one SBOM and ML-BOM representation and identify what each cannot say.
- Design a kill exercise with queued, leased, in-flight, completed and uncertain actions.
- Review a local Kubernetes manifest using the official security checklist; use `kubectl diff` only against a disposable, explicitly scoped cluster if one exists.
- Model policy outage, audit backpressure and approval overload without weakening authorization.

## References and review

The reference records in `support/references` contain exact URLs, review dates and relevance. They are used as follows:

1. **REF-0793 — NIST AI 600-1 GenAI Profile:** lifecycle governance, measurement and generative-AI risk framing.
2. **REF-0794 — NIST AI 100-2 E2025:** adversarial-ML terminology and attack taxonomy. NIST records an identified erratum; consult the publication page for updates.
3. **REF-0795 — OWASP Prompt Injection:** direct/indirect injection, mitigation limits, least privilege, approval and adversarial testing.
4. **REF-0796 — OWASP Data and Model Poisoning:** training, fine-tuning, embedding, artifact and lineage risks.
5. **REF-0797 — OWASP Improper Output Handling:** model output as untrusted downstream input and sink-specific consequences.
6. **REF-0798 — OWASP Excessive Agency:** excessive functionality, permission and autonomy plus complete mediation.
7. **REF-0799 — MITRE ATLAS:** living tactics, techniques, mitigations and case-study vocabulary. Review more frequently because it evolves.
8. **REF-0800 — Google SAIF controls:** data, infrastructure, model, application, assurance and governance control map.
9. **REF-0801 — SLSA v1.2 provenance:** verifiable artifact origin and production information.
10. **REF-0802 — Sigstore Cosign verification:** identity/issuer-constrained signature and attestation verification. CLI details are version-sensitive.
11. **REF-0803 — NIST SSDF 1.1:** secure development and supplier practices for the application/platform around the model.
12. **REF-0804 — TUF specification:** update metadata and resilience to repository/key compromise and rollback-related threats. The latest listed version can change.
13. **REF-0805 — Kubernetes Security Checklist:** workload, identity, admission, secret and network baseline; the checklist itself warns that security is not one-size-fits-all.
14. **REF-0806 — OPA Decision Logs:** decision identity, policy/bundle context and sensitive-field masking.
15. **REF-0807 — CycloneDX AI/ML-BOM:** machine-readable model, dataset, framework and dependency transparency.

### Review boundary

The sources were reviewed on 2026-08-05. Living documentation and specifications have shorter review windows in their JSON records. Before implementing version-specific commands or policy, pin the local product version and consult its official documentation.

This lesson does not claim that any framework certifies a system, that one control prevents all prompt injection, or that the offline lab demonstrates production security. It synthesizes operational design principles from primary and official sources and makes limitations explicit.

### Final lesson summary

- Text is data, even when it looks like an instruction.
- The model proposes; authenticated deterministic systems authorize.
- Validate generated output for the exact downstream interpreter.
- Minimize tool functionality, permission and autonomy.
- Bind approvals to immutable effects and revalidate before commit.
- Treat digest, signature, provenance, safe format and behavior as separate evidence.
- Test attacks against system invariants and downstream state, not just refusals.
- Build privacy-aware audit and observe its coverage.
- Stop through an independent path; reconcile queues and effects.
- Recover through known state, rotated authority, regression evidence and owned residual risk.
