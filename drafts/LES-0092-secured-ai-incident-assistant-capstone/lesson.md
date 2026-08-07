---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0092",
  "slug":"secured-ai-incident-assistant",
  "aliases":["V11-L05","secured-ai-incident-assistant"],
  "curriculumIds":["CAP-005"],
  "route":"/book/capstones/secured-ai-incident-assistant",
  "order":5,
  "volume":"11-capstones",
  "title":"Secured AI incident-assistant capstone: evidence before eloquence, authority outside the model",
  "summary":"Build and defend a local incident-support system that sanitizes evidence, retrieves authorized runbooks, verifies claims, constrains tools, separates approval, audits decisions and fails safely.",
  "domain":"capstone-engineering",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0091"],
  "prerequisiteCurriculumIds":["AUT-002","OBS-001","SRE-003","SEC-001","AIO-001","AIO-002","AIO-003","AIO-004"],
  "testedEnvironments":[
    {"platform":"Windows and Ubuntu","version":"Windows 11 host, Ubuntu 24.04 WSL and Python 3.12","support":"required","notes":"Twenty-two tests and the sixteen-scenario absent-to-absent deterministic verifier pass as a normal user."},
    {"platform":"AI model or provider","version":"none in the default project","support":"concept-only","notes":"The generator is an untrusted deterministic fixture. No model, tokenizer, embedding service, provider, network or model download is invoked."},
    {"platform":"Production incident systems","version":"not executed","support":"concept-only","notes":"No observability, ticketing, chat, policy, approval, cluster, cloud, shell or production endpoint is contacted."}
  ],
  "targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","production-engineer","ai-platform-engineer","security-engineer","staff-engineer"],
  "learningObjectives":[
    "Trace one incident-support request through sanitization, authorized retrieval, untrusted generation, claim verification, policy, approval, effect reconciliation and audit.",
    "Separate fluent output from evidence, authorization, incident command and production state.",
    "Design retrieval, tool and approval boundaries that resist injection, leakage, cross-tenant access, unsafe output and ambiguous retry.",
    "Build a sliced evaluation contract in which critical confidentiality and authority failures override aggregate quality scores.",
    "Operate independent kill and deterministic fallback paths while stating what local evidence cannot prove."
  ],
  "productionSignals":[
    "A confident incident diagnosis cites a document that does not support the material claim.",
    "A document from one tenant or environment enters another incident context.",
    "Sensitive telemetry appears in prompt, trace, retrieval, model output or audit surfaces.",
    "A model-selected tool uses broad identity, arbitrary arguments or reusable approval.",
    "A tool request times out after acceptance and the caller cannot distinguish completion from failure.",
    "The active model, prompt, corpus, index, verifier or policy differs from the evaluated release."
  ],
  "diagrams":[
    {"id":"LES-0092-DIA-001","title":"Evidence-to-effect path with independent authority","direction":"left-to-right","boundaries":["incident and source evidence","sanitizer","authorized corpus retrieval","untrusted generator","claim verifier","policy","human approval","tool broker","target state","audit and user validation"],"evidencePoints":["incident identity","sanitizer receipt","corpus/index version","candidate claims","citation support","decision ID","approval digest","effect receipt","postcondition","audit hash"],"textAlternative":"Evidence is minimized before retrieval and generation; generated claims and proposals cross independent verification, policy and approval before a narrow effect can occur."},
    {"id":"LES-0092-DIA-002","title":"Trust boundaries around an untrusted generator","direction":"hierarchical","boundaries":["trusted identity and policy","untrusted telemetry and documents","untrusted generator output","typed tool boundary","least-privileged downstream service","independent kill and fallback"],"evidencePoints":["classification","scope attributes","output schema","authorization context","effect identity","kill state"],"textAlternative":"Neither input content nor generated output owns authority; trusted identity, policy, approval, downstream mediation and kill controls surround the generator."},
    {"id":"LES-0092-DIA-003","title":"Release and evaluation closure","direction":"left-to-right","boundaries":["source artifacts","immutable release manifest","separated evaluation set","slice metrics","critical gates","staged rollout","rollback"],"evidencePoints":["digests","dataset identity","per-slice results","zero-tolerance failures","stage decision","rollback target"],"textAlternative":"Every behavior-changing artifact is bound into a release and evaluated on separate cases before shadow, read-only or reversible-effect stages."},
    {"id":"LES-0092-DIA-004","title":"Accepted is not completed","direction":"left-to-right","boundaries":["proposal","authorization","approval","accepted task","completion receipt","authoritative state","user validation"],"evidencePoints":["proposal digest","policy revision","approval expiry","task identity","terminal outcome","postcondition","user signal"],"textAlternative":"A timeout after acceptance creates ambiguity; reconcile task and target state before retry and close only after the intended user signal passes."}
  ],
  "commands":[
    {"id":"LES-0092-CMD-001","question":"Are the six synthetic contracts internally safe and cross-linked?","risk":"read-only","command":"python assistantctl.py check","runFrom":"support/project as a normal user","expectedBranches":[{"when":"check=pass authority=local-fixture-only model=none network=none","meaning":"strict inputs, identities and declared boundaries satisfy implemented checks","nextEvidence":"initialize an owned disposable runtime"},{"when":"status=refused","meaning":"schema, identity, sensitive-data, path or authority validation failed","nextEvidence":"preserve the first message and repair only the named project input"}],"proves":"bounded fixture contract validity","doesNotProve":"real-model quality, external safety or production readiness","cleanup":"No runtime is created."},
    {"id":"LES-0092-CMD-002","question":"Can an owned local evaluation runtime be created?","risk":"mutating-bounded","command":"python assistantctl.py initialize","runFrom":"support/project with .runtime absent","expectedBranches":[{"when":"initialize=pass runtime=owned","meaning":"a digest-bound descriptor, receipt directory and first audit record exist","nextEvidence":"run the grounded baseline"},{"when":"status=refused","meaning":"root, path, input, ownership or existing-state guard stopped creation","nextEvidence":"do not bypass the guard"}],"proves":"one exact project-local runtime","doesNotProve":"an AI service or incident integration","cleanup":"Run python assistantctl.py cleanup after evidence capture."},
    {"id":"LES-0092-CMD-003","question":"Can the fixture produce claims that are supported and explicitly limited?","risk":"mutating-bounded","command":"python assistantctl.py baseline","runFrom":"support/project after initialize","expectedBranches":[{"when":"baseline=pass with four verifiedClaims and two abstentions","meaning":"authorized retrieval, exact citation support, read-only policy and work budget passed","nextEvidence":"inspect evidence IDs and run adversarial cases"},{"when":"status=refused","meaning":"grounding, scope, release, policy, audit or budget failed","nextEvidence":"stop at the first failed invariant"}],"proves":"one deterministic grounded fixture path","doesNotProve":"a generative model, causal diagnosis or production correctness","cleanup":"Baseline and audit files are removed only by guarded cleanup."},
    {"id":"LES-0092-CMD-004","question":"Does injection expand authority?","risk":"mutating-bounded","command":"python assistantctl.py scenario prompt-injection","runFrom":"support/project after baseline","expectedBranches":[{"when":"result=blocked","meaning":"instruction-shaped document content remained untrusted and caused no effect","nextEvidence":"review the receipt and adjacent authority tests"},{"when":"status=refused","meaning":"runtime ownership or scenario identity failed","nextEvidence":"preserve the first failure"}],"proves":"one declared injection fixture is blocked","doesNotProve":"universal prompt-injection prevention","cleanup":"The named receipt is removed by exact cleanup."},
    {"id":"LES-0092-CMD-005","question":"Does the full local security and evaluation matrix pass?","risk":"mutating-bounded","command":"python verify.py","runFrom":"support/project with .runtime absent","expectedBranches":[{"when":"verify=pass tests=22 scenarios=16 cleanup=absent","meaning":"tests, outcomes, audit, dossier and cleanup matched the locked contract","nextEvidence":"review slice outcomes and proof limits"},{"when":"verify=refused or exception","meaning":"a safety, evidence or ownership invariant changed","nextEvidence":"preserve the first failure and use only guarded cleanup"}],"proves":"one absent-to-absent deterministic lifecycle","doesNotProve":"real-model population behavior, external authorization or mastery","cleanup":"Verifier performs descriptor-gated exact cleanup."},
    {"id":"LES-0092-CMD-006","question":"Can cleanup prove exact project ownership?","risk":"destructive-disposable","command":"python assistantctl.py cleanup","runFrom":"support/project with a matching descriptor","expectedBranches":[{"when":"cleanup=pass runtime=absent","meaning":"only allowlisted owned artifacts were removed","nextEvidence":"independently confirm .runtime is absent"},{"when":"unknown artifact, descriptor mismatch or audit damage","meaning":"ownership is unproved","nextEvidence":"stop and never broaden deletion"}],"proves":"exact disposable-state cleanup","doesNotProve":"general host or production-data safety","cleanup":"Terminal cleanup refuses broad deletion."}
  ],
  "labs":[
    {"id":"LES-0092-LAB-001","title":"Guided evidence, authority and adversarial-evaluation lab","mode":"guided","environment":"Ubuntu 24.04 WSL or Windows Python 3.12","timeMinutes":240,"privilege":"normal user; no sudo, provider credential, network endpoint or real incident data","network":"no network, model or external client","changes":["project-local .runtime","baseline evidence","sixteen evaluation receipts","hash-chained audit","design dossier"],"abortConditions":["root","unsafe path","identity mismatch","sensitive-shaped value","unknown runtime file","descriptor or audit tampering","external client or real data"],"recovery":"Preserve the first failure and use only descriptor-gated cleanup.","cleanupProof":"Verifier ends with .runtime absent; adversarial tests prove unknown artifacts and descriptor tampering block deletion.","path":"drafts/LES-0092-secured-ai-incident-assistant-capstone/support/project"},
    {"id":"LES-0092-LAB-002","title":"Independent changed-domain assistant and hidden-fault defense","mode":"independent","environment":"Fresh clone with reviewer-owned synthetic domain, corpus, tools and hidden evaluation cases","timeMinutes":240,"privilege":"normal user and independent reviewer; no answer key, hosted provider or external effect","network":"offline deterministic inputs; an optional local model requires separate authorization and evaluation","changes":["new synthetic contracts","reviewer hidden cases","learner architecture and harness","evaluation dossier","bounded receipts"],"abortConditions":["guided-copy fixture","answer leakage","real identity or sensitive data","open-ended tool","external endpoint","unsafe cleanup","unsupported production claim"],"recovery":"Reviewer disables the harness, preserves evidence and restores only named disposable state.","cleanupProof":"Reviewer confirms exact absence, audit result and zero external/model call in the required path.","path":"drafts/LES-0092-secured-ai-incident-assistant-capstone/support/project"}
  ],
  "incidents":[
    {"id":"LES-0092-INC-001","signal":"A confident answer cites an irrelevant fragment.","firstThought":"The citation exists, but entailment and claim support failed.","safePath":"Separate the claim, cited span and measured evidence; reject or abstain before action.","trap":"Assume any citation makes output grounded."},
    {"id":"LES-0092-INC-002","signal":"A cross-tenant document enters context.","firstThought":"Confidentiality failed before generation.","safePath":"Disable affected retrieval, preserve provenance, investigate ingestion/index/cache scope and notify owners.","trap":"Filter the final answer and call the leak contained."},
    {"id":"LES-0092-INC-003","signal":"A runbook tells the model to ignore approval.","firstThought":"Untrusted content is attempting to cross the instruction boundary.","safePath":"Quarantine the version, keep authority outside the model and test related corpus paths.","trap":"Rely only on a stronger system prompt."},
    {"id":"LES-0092-INC-004","signal":"A tool timed out after returning accepted.","firstThought":"Outcome is ambiguous, not failed.","safePath":"Reconcile task identity and target postcondition before retry or compensation.","trap":"Retry automatically and duplicate the effect."},
    {"id":"LES-0092-INC-005","signal":"The active prompt/index/policy alias changed without evaluation.","firstThought":"Behavioral release identity is unproved.","safePath":"Freeze or roll back to an admitted manifest and evaluate the complete artifact closure.","trap":"Track only the model name."},
    {"id":"LES-0092-INC-006","signal":"The assistant kill switch depends on the assistant.","firstThought":"The control shares the failed trust boundary.","safePath":"Disable tools and generation through an independent operator path; keep deterministic fallback.","trap":"Ask the model to stop itself."}
  ],
  "assessmentIds":["ASM-0259","ASM-0260","ASM-0261"],
  "referenceIds":["REF-1180","REF-1181","REF-1182","REF-1183","REF-1184","REF-1185","REF-1186","REF-1187","REF-1188","REF-1189","REF-1190","REF-1191","REF-1192","REF-1193","REF-1194","REF-1195","REF-1196","REF-1197","REF-1198","REF-1199"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2026-11-07",
  "limitations":[
    "The default project uses a deterministic untrusted fixture and invokes no model, tokenizer, embedding service, provider, network or external tool.",
    "Sixteen synthetic cases cannot represent the open-ended attack, language, incident, organization or model population.",
    "AI-security, provider, telemetry and policy guidance changes quickly; release-specific designs require current source, privacy and security review.",
    "Local tests, evaluation outcomes, dossier output and reading completion are not production safety, incident competence, experience or mastery evidence."
  ]
}
---

# Secured AI incident-assistant capstone: evidence before eloquence, authority outside the model

## What you see and first thought

An incident page opens. Error ratio is climbing. A polished assistant writes: “Root cause: database saturation. Restart the database immediately.”

The sentence is fast, confident and specific. That is exactly why you must slow down.

Your first questions are:

1. What exact user operation is failing?
2. Which observations support each material claim?
3. Was every retrieved document allowed for this incident?
4. Which component proposes an action, and which independent component authorizes it?
5. If an action timed out, do we know whether it happened?
6. Can an operator stop the assistant when the assistant path is broken?

A useful assistant reduces search and coordination time. It does not become incident commander, policy engine or production truth.

> Fluent language is an interface property. Evidence and authority are system properties.

Split every confident diagnosis into three boxes:

```text
observation                  hypothesis                    decision
12% request errors          rev-b may be related          compare or roll back rev-b
payment timeouts rose       dependency may contribute     inspect dependency path
database CPU is unknown     database cause is unproved    collect database evidence
```

An observation came from an identified source at a time. A hypothesis explains observations but may be wrong. A decision spends authority and creates consequences. The assistant may help draft all three, but the architecture must never let it silently convert one into the next.

This capstone uses no real AI model. That is deliberate. A deterministic hostile fixture repeats injection, leakage, unsupported-claim, unsafe-tool, approval, ambiguity, audit and kill-switch failures without a model download or probabilistic noise. You are testing the safety frame around intelligence.

## Terms before commands

### AI, machine learning and a model

**Artificial intelligence**, or AI, is a broad label for systems that perform tasks associated with prediction, perception, language or decision support. **Machine learning**, or ML, builds behavior from data rather than only hand-written rules. A **model** is an artifact that maps input to output.

The word model does not tell you what evidence exists. A language model can produce a plausible incident explanation because a text pattern is likely, not because it observed your database.

### Generative model and language model

A **generative model** produces new content. A **large language model**, or LLM, generates sequences of text-like tokens from context. “Large” describes scale, not truthfulness, authorization or operational judgment.

At **inference** time, a deployed model receives input and produces output. Inference can be remote through a provider or local through a runtime. This lesson invokes neither.

### Token, tokenizer, prompt and context window

A **token** is a unit a language model processes. It may be a word, word fragment, punctuation or byte-like unit depending on the **tokenizer**. The same text can consume different token counts under different tokenizers.

A **prompt** is input supplied to a model. A **system instruction** is application-controlled context intended to shape behavior. **Retrieved context** is data selected from external knowledge. Conversation history, tool results and user input may also enter the **context window**, the finite input region available to one model call.

More context is not automatically better. It increases latency and cost, can bury relevant evidence, expands sensitive-data exposure and gives untrusted documents more opportunity to influence output.

### Probability, temperature and determinism

A language model generally scores possible next tokens. **Temperature** or related sampling controls alter how token probabilities are sampled. Lower temperature can reduce variation; it does not turn generated content into fact.

Even a deterministic configuration proves only repeatability for a fixed artifact and input. It does not prove correctness. Our fixture is deterministic so that a failed safety test can be reproduced exactly.

### Embedding, vector and similarity

An **embedding** maps content to a numeric vector intended to preserve useful semantic relationships. A vector search compares a query vector with stored vectors using a distance or similarity function.

Similarity is not authorization, freshness or truth. A tenant-b document may be extremely similar to a tenant-a incident and still be forbidden. A retired runbook can rank first and still be unusable.

### Corpus, chunk, index, retriever and reranker

A **corpus** is the governed document collection. A **chunk** or fragment is a bounded portion stored or retrieved as one unit. An **index** is the derived structure used to search the corpus. A **retriever** selects candidates. A **reranker** may reorder candidates using another scoring step.

Every stage has identity:

```text
document version -> fragment identity -> index build -> retriever version -> candidate set
```

If the corpus changes but the index does not, search may be stale. If the index changes after evaluation, the evaluated release is no longer the active release.

### Retrieval-augmented generation

**Retrieval-augmented generation**, or RAG, supplies retrieved information to a generator. It separates some knowledge from model parameters and can make sources visible.

RAG does not automatically solve hallucination, authorization or injection:

- retrieval can miss the correct document;
- it can return forbidden, stale or poisoned content;
- the model can ignore or misread the source;
- a citation can point to text that does not support the sentence;
- untrusted text can contain instructions.

### Grounding, citation, entailment and abstention

A claim is **grounded** when identified evidence actually supports it under a defined rule. A **citation** names the evidence. **Entailment** asks whether that evidence supports the claim, not merely whether the topic is related.

An **abstention** is a deliberate refusal to claim what evidence cannot support. “The release occurred before the error increase; causation is unproved” is stronger operational communication than a fabricated root cause.

### Prompt injection, jailbreak and poisoning

**Prompt injection** is untrusted input attempting to change instructions or behavior. It may be direct from a user or indirect inside a document, ticket, log or tool result. A **jailbreak** attempts to bypass behavioral restrictions. **Poisoning** changes data, documents, models or derived artifacts so later behavior is corrupted.

Do not memorize these as word-filter problems. The durable control is limited authority:

> Assume some malicious instruction will reach the model. Design so model output still cannot authorize itself.

### Agent, tool and effect

An **agent** is an application loop that uses model output to choose or sequence steps. A **tool** is a callable capability. An **effect** is a state change outside the reasoning process.

“Tool use” can mean a read-only metric lookup or an arbitrary cluster-admin shell. The name is not the risk. Functionality, permission, autonomy, input validation and downstream mediation determine blast radius.

### Proposal, authorization and approval

A **proposal** is an untrusted request describing an intended tool, target and arguments. **Authorization** is a deterministic decision about whether a subject may perform an action on an object in context. **Approval** is a human or independent authority accepting one exact risk.

The secure order is:

```text
model proposes -> policy authorizes -> human approves exact digest -> broker executes
```

Approval cannot repair an unauthorized action. A generic “approve anything for 24 hours” button is ceremony, not control.

### Accepted, completed, reconciled and validated

An effect request can be:

- **proposed** but not authorized;
- **authorized** but not approved;
- **accepted** by a target;
- **completed** with a terminal receipt;
- **reconciled** against authoritative state;
- **validated** through the intended user operation.

A timeout after accepted is ambiguous. Retrying without reconciliation can repeat the change.

### Release manifest and artifact closure

The model name is only one behavioral input. A defensible **release manifest** binds the model or fixture, tokenizer when applicable, prompt, corpus, index build, retriever, verifier, tool schemas, policy, application image and evaluation report.

Think of this set as the **artifact closure**: everything that can materially change behavior. If any member changes, the old evaluation cannot automatically describe the new system.

### Evaluation case, slice, metric and critical invariant

An **evaluation case** has input, expected evidence or behavior and scoring. A **slice** groups cases by meaningful risk: missing evidence, cross-tenant retrieval, injection or ambiguous effect.

A **metric** compresses observations, such as supported-claim precision. A **critical invariant** is a condition that must never be violated in accepted evidence: no cross-tenant disclosure, unauthorized mutation or kill bypass. Averages do not waive it.

### Precision, recall and why both matter

For retrieval:

```text
precision = relevant authorized fragments returned / all fragments returned
recall    = relevant authorized fragments returned / all relevant authorized fragments
```

High precision with low recall gives a clean but incomplete brief. High recall with low precision floods the model with distractors and attack surface. Neither metric checks tenant authorization unless the denominator and labels include it.

For claims, use a separate measure:

```text
supported-claim precision = supported material claims / all material claims
```

One unsupported high-impact action can matter more than twenty correct low-risk statements.

### Incident command, kill switch and fallback

**Incident command** assigns human authority for coordination, operations and communication. An assistant may support those roles but cannot infer that it owns them.

A **kill switch** disables risky capability through an independent path. **Fallback** preserves a simpler service when the assisted path is unavailable. Here, fallback keeps sanitized evidence, approved runbooks and a human checklist while disabling generation and tools.

## Architecture map

### One incident-support request

```text
synthetic incident and telemetry
        |
        v
classification + minimization + sanitizer receipt
        |
        v
tenant/service/environment authorization
        |
        v
versioned corpus -> index identity -> retrieved fragment set
        |
        v
untrusted generator -> claims + citations + proposal + abstentions
        |
        +--> claim verifier: supported / contradicted / missing
        |
        +--> typed proposal validator
                 |
                 v
        deterministic policy decision
                 |
                 v
        exact human approval when mutation is requested
                 |
                 v
        narrow broker -> accepted/completed/ambiguous effect
                 |
                 v
        reconciliation -> user-operation validation

Every boundary -> privacy-aware audit identity
Independent operator -> kill generation/tools -> deterministic fallback
```

Read the path left to right. Data gets smaller and better classified before reaching the generator. Authority does not enter the generator. Output becomes actionable only after independent verification.

### The three-plane memory model

```text
EVIDENCE PLANE             REASONING PLANE              EFFECT PLANE
source identity            retrieval candidates         subject identity
classification             untrusted context            policy decision
sanitization               untrusted output             exact approval
time and scope             claims/citations             typed broker
runbook versions           hypotheses/abstention        effect reconciliation
```

Remember:

> Evidence may inform reasoning. Reasoning may propose an effect. Only the effect plane grants authority.

### Trust boundary map

“Internal” is not synonymous with trusted. A runbook can be compromised. A log line can contain user-controlled text. A model can generate malformed JSON. An authenticated operator can lack permission for the target tenant.

```text
trusted identity -----------+
trusted policy -------------+--> effect decision
exact approval -------------+

telemetry -----+
runbooks ------+--> untrusted reasoning context --> untrusted proposal
tool results --+
```

The policy service trusts identity and signed policy inputs, not the model's description of identity. The downstream service enforces the decision again because the broker itself can fail.

### Control plane and data plane

The assistant **control plane** holds release manifests, policies, schemas, tool definitions, evaluation gates and rollout state. Its **data plane** carries incident inputs, retrieved fragments, candidate output, proposals and receipts.

A model response can be healthy while the control plane is unsafe. A policy service can be healthy while the evidence plane leaks. Operate each path separately.

### Independent stop and degraded path

```text
operator control ----> disable generator
        |------------> disable tool broker
        |------------> revoke downstream identity
        |
        +------------> keep sanitized evidence + manual runbooks + human command
```

Do not put the kill switch behind the component it must stop. Do not make “AI unavailable” mean “on-call cannot see evidence.”

### Release and evaluation path

```text
source revisions
   -> immutable artifact digests
      -> compatibility checks
         -> separated evaluation cases
            -> per-slice metrics + critical gates
               -> admitted release
                  -> shadow
                     -> reviewed suggestions
                        -> read-only tools
                           -> narrowly approved reversible effects
```

Moving right increases authority. Evidence requirements should increase with it. A good demo may justify another experiment; it does not justify automatic remediation.

## Request or state path

### Step 1: bind the incident

The request starts with trusted scope, not free-form prose:

```json
{
  "incidentId": "inc-checkout-latency",
  "tenant": "tenant-a",
  "service": "checkout",
  "environment": "lab",
  "commander": "operator-a",
  "window": {"startTick": 100, "endTick": 160}
}
```

The incident identity joins every later record. If a proposal names another tenant or incident, policy refuses it. Do not ask the model to infer scope from a chat sentence.

### Step 2: minimize and sanitize

Raw observability data may contain request bodies, identity claims, addresses, credentials or customer content. Decide what the task needs before copying anything.

The local fixture keeps only:

- synthetic event identity;
- tenant and service;
- event tick;
- signal name;
- bounded value and unit;
- source class;
- explicit synthetic classification.

Sanitization is not a regular expression victory. Patterns catch known shapes, while allowlisted schemas reduce the possible surface. In production, use source-specific parsing, classification, structured redaction, access control, retention and tests. Preserve a receipt showing which transformation version ran.

### Step 3: authorize before retrieval

Filter by trusted tenant, service, environment, audience, review state and time before similarity ranking.

```text
all corpus fragments
  -> authorized candidates
     -> reviewed and unexpired candidates
        -> similarity/ranking
           -> bounded context
```

If you rank everything first, a forbidden fragment may enter a cache, trace, reranker or model even if the final answer hides it.

The fixture excludes:

- `frag-tenant-b-only` because the incident belongs to tenant-a;
- `frag-stale` because its document is retired and expired.

### Step 4: record retrieval evidence

For each fragment, record document ID, fragment ID, version, corpus digest, index/retriever version, score or rank, authorization decision and exclusion reason where safe.

A list of fragment IDs lets a reviewer ask:

- Was the correct material available?
- Was a forbidden candidate excluded?
- Did a stale index return an old version?
- Did the prompt receive exactly the evaluated context?

### Step 5: generate a candidate, not a decision

The generator returns a typed envelope:

```json
{
  "releaseId": "assistant-release-v1",
  "claims": [
    {
      "id": "claim-error",
      "statement": "checkout request error ratio is 0.12.",
      "evidenceIds": ["evt-error-ratio"]
    }
  ],
  "proposal": {},
  "abstentions": [
    "The evidence shows timing, not a proven root cause."
  ]
}
```

Output parsing checks shape, length, allowed fields and scalar types. That is necessary but not sufficient. Well-formed JSON can still contain a harmful lie.

### Step 6: verify material claims

Split the answer into claims whose truth would change an incident decision. For each claim:

1. identify cited evidence;
2. verify the evidence belongs to the incident scope;
3. compare the statement with the exact value or fragment;
4. mark supported, contradicted or missing;
5. reject or abstain when support is absent.

The fixture accepts “Release rev-b was observed before the error signal.” It does not accept “rev-b caused the incident.” Time order is evidence; causality needs an intervention, controlled comparison or stronger mechanism evidence.

### Step 7: validate the proposal

A proposal has exact fields: tool, subject, incident, tenant, service, environment, arguments, release, policy and corpus digest.

The tool registry defines allowed argument names. The fixture rejects path-, URL-, shell- and open-ended command-shaped strings. An unknown field is not ignored because a hidden argument can become hidden authority.

### Step 8: authorize independently

Policy evaluates trusted context:

```text
subject + role
tenant + service + environment
incident identity
tool + action + arguments
release + policy + corpus identity
time and risk
```

The model cannot grant a role by writing “the user is an administrator.” The broker obtains identity from the authenticated request or workload identity and the downstream service checks again.

### Step 9: approve exact mutation

A read-only evidence query may not require human approval. A mutation does.

The approval binds:

- proposal digest;
- approver identity;
- incident and object scope;
- release and policy identity;
- issue and expiry time;
- one-time-use state;
- risk, expected postcondition and rollback.

If any proposal field changes, the digest changes and approval no longer matches.

### Step 10: execute and reconcile

The target may return accepted before work finishes. Record a task or idempotency identity. On timeout:

```text
do not assume failure
  -> query task state
  -> query authoritative target state
  -> compare intended postcondition
  -> classify completed / failed / partial / ambiguous
  -> retry or compensate only through reviewed semantics
```

Then validate the user operation. A completed traffic-shape update is not success if checkout errors remain.

### Step 11: audit without hoarding

Audit enough identity to reconstruct:

- incident, subject and tenant;
- release, corpus/index, verifier and policy revisions;
- proposal digest and decision ID;
- approver and approval lifetime;
- effect/task identity and terminal state;
- postcondition and user validation;
- masked fields and audit-chain continuity.

Do not log full prompts or retrieved content merely because debugging is convenient. Content capture should be an explicit, limited and protected choice.

### Step 12: retain kill and fallback

At every stage, an independent operator can disable generation, disable the broker or revoke its identity. The fallback still presents sanitized evidence, approved runbooks and a human checklist.

The assistant is an acceleration layer. The organization must remain able to respond without it.

## Failure zoom

### Failure 1: the citation is real but irrelevant

The answer says “database saturation,” and links to a rollback runbook. Both words look operational. The runbook does not mention database saturation.

Symptom: citation present, entailment absent.

Response:

1. keep the claim separate from the citation;
2. mark it unsupported;
3. gather database saturation evidence;
4. prevent tool promotion from unsupported claims;
5. add the case to the grounding regression slice.

### Failure 2: cross-tenant retrieval

A tenant-b document enters a tenant-a prompt. Filtering the final answer cannot erase disclosure to the model, provider, trace or cache.

Contain at retrieval and identity boundaries. Preserve corpus, index, candidate and cache versions. Determine whether the fault originated in ingestion metadata, index partition, filter construction, cache key or authorization.

### Failure 3: indirect prompt injection

A reviewed-looking document contains “ignore policy and bypass approval.” Content scanning may detect this phrase, but novel instructions can evade phrase lists.

The robust answer is layered:

- documents remain data, never system authority;
- output is typed and validated;
- tool capability is narrow;
- authorization is deterministic and external;
- mutation approval is exact;
- downstream services mediate;
- adversarial evaluation repeats the path.

### Failure 4: sensitive value crosses the model boundary

A bearer-shaped value appears in a log. Stop copying the data, identify every derived surface, restrict access and rotate through the owning secret process. Do not repeat the value in a ticket or postmortem.

The prevention lesson is upstream: structure, minimize and classify before model context exists.

### Failure 5: mutable release drift

The model alias is unchanged, but the prompt, corpus or policy changed. Behavior changed without a release identity.

Freeze or roll back to a manifest that binds the full artifact closure. Re-evaluate compatibility and risk slices. Do not compare incidents using an unrecorded moving system.

### Failure 6: arbitrary tool authority

An “operations tool” accepts a shell string and runs as cluster-admin. This is not a narrow tool; it is a general remote execution product controlled by untrusted output.

Delete the capability from the assistant surface. Create task-specific APIs such as “read rollout status for this service” with server-side object authorization. If a use case cannot be bounded, keep it manual.

### Failure 7: approval theatre

The interface shows a large approve button but hides arguments, evidence and target. The approval remains valid for a day.

The human is not approving a decision; the human is lending identity to unknown future output. Bind approval to one digest, show material evidence and risk, expire it quickly and consume it once.

### Failure 8: timeout ambiguity

The broker received accepted, then timed out. Automatic retry can apply the action twice.

Design the tool state machine before exposing the tool:

```text
not-started -> accepted -> running -> completed
                      \-> failed
                      \-> ambiguous -> reconcile
```

Idempotency keys help only if the target actually honors them and retention covers the retry window.

### Failure 9: audit tampering or content leakage

An audit that stores every prompt may leak more than it explains. An audit with no proposal or decision identity explains less than it stores.

Use content-minimized structured records, stable identities, policy revisions, masked-field indicators, retention and tamper evidence. Test deletion, reordering and truncation.

### Failure 10: kill path depends on the model

If “disable automation” sends another prompt to the same compromised application, the stop control is fictional.

Independent controls include broker disablement, workload scale-down, credential revocation, route denial or policy change owned by a separate operator boundary. Test them under model and retrieval failure.

## Internals and state ownership

The most important engineering question is not "Which model should we use?" It is "Which component owns each fact and each decision?"

If the answer is "the assistant knows," the design is already unsafe. Knowledge, identity, authorization and target state need named authorities.

### The fourteen authorities

| State | Authoritative owner | What the assistant may do | What it must never do |
| --- | --- | --- | --- |
| incident identity and severity | incident-management system | display the current value | invent or silently change it |
| authenticated subject | identity provider or workload identity | carry the verified identity | accept identity claims from prompt text |
| tenant, service and environment scope | service catalog plus authorization system | request an allowed scope | widen scope because a document asks |
| telemetry facts | identified telemetry backend | summarize timestamped observations | turn missing data into a fact |
| runbook source | governed document repository | quote an authorized version | treat retrieved prose as instruction authority |
| corpus and index version | ingestion and retrieval pipeline | include identities in evidence | search an unversioned or unknown index |
| candidate response | generator | produce untrusted structured output | declare its own output verified |
| claim support | independent verifier plus evidence policy | submit claims and citations | waive support requirements |
| tool schema | tool registry | propose one typed call | invent a tool or argument |
| authorization | policy decision and enforcement points | provide proposal context | grant roles or approve itself |
| human approval | approval service | request exact approval | reuse, extend or alter approval |
| effect state | downstream target and task service | report the reconciled state | infer success from a timeout |
| audit history | append-only audit service | emit structured events | edit prior decisions |
| kill state | independent operations control | observe that it is disabled | override or depend on itself to stop |

This table is a practical debugging map. When two systems disagree, ask which row owns the truth. The model output is authoritative only for one thing: the text the model produced.

### Strict parsing is a security boundary

The local project rejects unknown and duplicate fields. That may look unfriendly until you imagine this object:

```json
{
  "tool": "read-rollout",
  "service": "checkout",
  "service": "payments-admin"
}
```

Different JSON parsers may keep the first or last duplicate. A reviewer may read one value while the executor uses another. Rejecting duplicates removes the ambiguity. Rejecting unknown fields prevents a hidden field from acquiring meaning after a downstream upgrade.

Boundary validation should check:

- shape: object, array, string, number or boolean;
- allowed field names;
- identifier syntax and length;
- bounded numeric ranges;
- cross-record references;
- enum values;
- release identities and digests;
- sensitive-shaped values;
- exact paths owned by the disposable project.

Validation is not business authorization. A syntactically valid tenant-b identifier is still forbidden in a tenant-a incident.

### Sanitization reduces exposure; it does not establish trust

Sanitization removes or masks values that should not cross the assistant boundary. Useful techniques include structured allowlists, field classification, tokenization, hashing where linkage is required and dropping high-risk payloads.

Sanitization cannot prove that remaining prose is truthful or harmless. A runbook with no secret can still be poisoned. A masked account number can still reveal that a particular customer is involved. Treat sanitization as one privacy control, followed by authorization, minimization, retention and access controls.

The fixture rejects values shaped like credentials before it builds context. In production, use organization-specific detectors and deterministic structured extraction, but measure false negatives and false positives. A detector result is evidence, not magic.

### Retrieval has two separate questions

The retriever must answer:

1. Is this fragment relevant?
2. Is this subject allowed to receive it for this operation?

Similarity answers only the first, and imperfectly. Authorization must run before forbidden content enters model context. A safe sequence is:

```text
authenticated scope
  -> candidate partition constrained by tenant/service/environment
  -> object authorization
  -> freshness and lifecycle checks
  -> similarity/ranking
  -> bounded fragments with provenance
```

Filtering after vector search may leak through candidate logs, caches, timing or provider context. Prefer pre-filtered partitions or retrieval APIs that enforce object authorization at the data boundary, and verify again before assembly.

### The generator is a candidate producer

The deterministic generator in this lab is intentionally untrusted. It can emit a supported claim, an unsupported causal statement, a forged citation or an unsafe proposal depending on the scenario.

That design makes one lesson visible: output validation must not depend on the generator volunteering to be honest.

A production adapter should return a versioned object, not free text alone:

```json
{
  "releaseId": "rel-ai-incident-001",
  "claims": [
    {
      "text": "Revision rev-b preceded the error increase.",
      "evidenceIds": ["event-003", "fragment-rollback-01"]
    }
  ],
  "abstentions": [
    "Database saturation is not established by available evidence."
  ],
  "proposal": null
}
```

Schema conformance proves that the output can be parsed. It does not prove that the claim is true. Each material claim still needs support evaluation.

### Claim verification is narrower than fact checking

The local verifier maps each claim to exact allowed evidence. That is deterministic and useful for a fixture. A real system faces paraphrase, numerical reasoning, conflicting sources and incomplete evidence.

Separate at least four outcomes:

- `supported`: the cited evidence directly supports the material claim;
- `contradicted`: identified evidence conflicts with it;
- `insufficient`: evidence is related but does not establish it;
- `unverifiable`: the required authority is unavailable.

For high-risk actions, "insufficient" and "unverifiable" must not silently become "probably true." Route them to abstention or human investigation.

### Tool schemas define capability

A tool is not a function name with an arbitrary dictionary. Its schema is the capability boundary.

Compare:

```text
unsafe: run(command="kubectl delete pod ...")

bounded: restart_workload(
  incident_id,
  tenant_id,
  namespace_id,
  workload_id,
  expected_revision,
  idempotency_key
)
```

The bounded call names the object and precondition. The broker can authorize each field, the downstream service can mediate again, and the audit can describe the intended effect without storing a shell program.

Read-only tools still need boundaries. A broad log query can disclose secrets or another tenant. "Read-only" means no intended mutation; it does not mean harmless.

### Policy and approval solve different problems

Policy answers whether an action is permitted under organizational rules. Approval records that an authorized human accepted one exact residual-risk decision. Neither replaces the other.

The project calculates a digest over the canonical proposal. Approval binds that digest, incident, approver, issue time, expiry and single-use state. Changing an argument creates a new proposal and requires a new decision.

Do not let the assistant summarize away the risky fields. The approval view should show target, effect, evidence, unsupported claims, blast radius, expected postcondition, rollback and expiry.

### Accepted, completed and validated are different states

An API response such as HTTP 202 means the request was accepted for processing. It does not say the operation completed. A 200 response can also describe only the broker's successful submission.

The local project models ambiguous outcome because this is where real automation causes duplicate effects. Persist:

- a client idempotency identity;
- downstream task identity;
- accepted timestamp;
- terminal completion or failure;
- authoritative postcondition;
- user-level validation.

On a timeout, reconcile those identities. Never convert "I did not receive the result" into "the operation did not occur."

### Audit integrity and audit privacy

The fixture creates a hash chain: each record includes the prior record digest. Deletion, reordering or modification breaks verification. This is tamper evidence, not an immutable production ledger. Someone who can replace the whole directory and trust anchor can still fabricate a new chain.

A production design also needs protected storage, access separation, retention policy, clock quality, export monitoring and an external trust anchor. Keep structured identifiers and decisions. Avoid raw prompts, secret values and unrestricted retrieved content unless a documented investigation need justifies protected capture.

### Runtime ownership makes cleanup safe

The lab owns only `support/project/.runtime`. Initialization writes a descriptor containing project and input identities. Cleanup checks the descriptor, known file set and audit integrity before removing anything.

If an unknown file appears, cleanup refuses. That is a feature. "Delete whatever is under this path" is convenient only until the path or mount is wrong.

The general pattern is:

```text
resolve exact root
  -> reject broad or unsafe root
  -> create ownership descriptor
  -> allowlist generated artifacts
  -> verify ownership before deletion
  -> remove only declared disposable state
  -> prove absence
```

## Evidence table

Use this table when the assistant, a dashboard or a teammate makes a strong statement. Read across the row before acting.

| Signal | What it can prove | What it cannot prove alone | Next evidence |
| --- | --- | --- | --- |
| request error ratio increased | a measured request population crossed a defined error condition | root cause or affected dependency | labels, exemplars, traces and deployment timeline |
| latency percentile increased | the observed population became slower at that percentile | which component consumed the time | trace spans, queues, saturation and downstream latency |
| deployment rev-b completed | an orchestrator reported the rollout terminal state | that rev-b caused or fixed user impact | before/after user signal, cohort comparison and mechanism evidence |
| runbook fragment retrieved | retriever returned a fragment under recorded versions | correctness, freshness, authorization or claim support | lifecycle, scope, source and cited span |
| similarity score is high | query and fragment are close under one embedding/index configuration | authorization, truth or entailment | object policy and claim-level support |
| citation ID exists | output points to an identified source | cited text supports the sentence | exact span and entailment judgment |
| model confidence is high | model assigned a score under one method | calibrated correctness in this incident population | calibration study and independent evidence |
| policy decision is allow | declared policy allowed the exact input | human acceptance or downstream success | approval when required and effect receipt |
| human clicked approve | an interface recorded an interaction | informed approval of exact arguments | digest, identity, expiry and displayed evidence |
| downstream returned accepted | target registered a task | terminal completion | task query and authoritative postcondition |
| task says completed | downstream workflow reached its terminal success state | user operation recovered | SLI and direct synthetic/user validation |
| audit chain verifies | records are internally linked from the selected anchor | complete capture or external immutability | coverage tests, protected anchor and access audit |
| all sixteen local cases pass | implemented fixture invariants match expected decisions | universal attack resistance or production safety | representative sliced evaluation and independent red team |
| kill switch reports disabled | one control-plane state changed | all in-flight effects stopped | broker requests, credentials, routes and target tasks |

The disciplined phrase is: "This proves X under Y boundary; it does not yet prove Z." That sentence prevents both panic and overconfidence.

## Command decoders

Run every command from `drafts/LES-0092-secured-ai-incident-assistant-capstone/support/project` as a normal user. Do not use `sudo`. The project needs only Python 3.12-compatible standard-library behavior and contacts no network service.

### Decoder 1: preflight contract check

```bash
python assistantctl.py check
```

- `python` starts the interpreter available in your shell. On some Ubuntu systems use `python3`.
- `assistantctl.py` is the local command-line control plane.
- `check` selects the read-only preflight subcommand.

Expected terminal summary:

```text
check=pass authority=local-fixture-only model=none network=none
```

This means the six JSON inputs passed the implemented shape, identity, cross-reference, sensitive-value and boundary checks. It does not mean the source data is representative of your company.

If it fails, preserve the first message. Do not edit several files at once. The first violated invariant is usually closest to the cause.

### Decoder 2: initialize owned state

```bash
python assistantctl.py initialize
```

This creates `.runtime` only after proving the root is the expected project directory and runtime is absent. It writes a descriptor and initializes audit state.

Expected branch:

```text
initialize=pass runtime=owned
```

If the runtime already exists, inspect status or clean it through the guarded command. Do not manually broaden a removal command.

### Decoder 3: inspect status

```bash
python assistantctl.py status
```

Status is an observation command. It reports descriptor, release, receipts, audit and kill state. A healthy status does not imply a baseline or scenario passed; it only describes the currently owned local state.

### Decoder 4: run the grounded baseline

```bash
python assistantctl.py baseline
```

The baseline executes authorized retrieval, candidate generation, claim verification, read-only proposal policy and audit. Its contract expects four verified claims and two abstentions.

Read the generated receipt rather than trusting the one-line summary:

```bash
python -m json.tool .runtime/receipts/baseline.json
```

`-m` asks Python to run a module. `json.tool` parses and pretty-prints JSON. Successful formatting proves JSON syntax only; inspect release, evidence, claims, abstentions and decision fields.

### Decoder 5: run one adversarial case

```bash
python assistantctl.py scenario prompt-injection
```

`scenario` selects the evaluation path; `prompt-injection` is an allowlisted case ID, not arbitrary input. Expected result is `blocked`. That word is meaningful only with a reason code, zero effect and audit receipt.

List declared cases from the input without installing another utility:

```bash
python -c "import json; data=json.load(open('evaluations.json', encoding='utf-8')); print(*(case['id'] for case in data['cases']), sep='\n')"
```

`-c` executes the following short Python program. It opens one local file, parses JSON and prints case IDs one per line. In production automation prefer a maintained script; this is a transparent inspection command.

### Decoder 6: execute the complete verifier

```bash
python verify.py
```

The verifier begins with `.runtime` absent, compiles code, executes 22 tests, initializes, runs the baseline and all sixteen cases, verifies outcome totals, audit chain and eight-section dossier, performs guarded cleanup and proves `.runtime` is absent again.

The expected summary includes:

```text
verify=pass tests=22 scenarios=16 cleanup=absent
```

Do not report only "tests passed." Report the boundary: deterministic fixture, six inputs, sixteen known cases, no model, no network and no external effect.

### Decoder 7: clean only owned disposable state

```bash
python assistantctl.py cleanup
```

Cleanup is destructive only to the declared project runtime. It refuses descriptor mismatch, unexpected artifacts and audit damage. Confirm absence independently:

```bash
test ! -e .runtime && echo "cleanup evidence: .runtime absent"
```

`test ! -e` succeeds when the path does not exist. The `&&` operator runs `echo` only after that success. This proves path absence at that moment, not absence of external side effects; the design separately prevents external clients.

## Decision path

When pressure rises, use the following sequence. It is intentionally less exciting than "ask the model."

### Gate 1: name the user operation

Write one sentence:

> A defined user, using a defined path, cannot complete a defined operation during a defined time window.

"The platform is broken" is too broad. "Tenant-a checkout requests through public API revision rev-b returned 5xx at 12% from 14:03 to 14:11 UTC" is investigable.

If the operation is unknown, the assistant can help locate telemetry, but it cannot safely choose remediation.

### Gate 2: classify and minimize evidence

Ask:

- Does this field contain a credential, personal data, customer content or regulated value?
- Is the field needed for this exact task?
- Can a stable synthetic identifier replace it?
- Which provider, trace, cache, prompt store and audit would receive it?

If classification is unknown, keep data outside the model path. "We can delete it later" is not a privacy control.

### Gate 3: authorize retrieval before ranking

Resolve subject, tenant, service and environment from trusted systems. Constrain the candidate corpus before semantic ranking. Reject a document whose lifecycle is retired, whose version is unknown or whose scope is not authorized.

If the identity service or object policy is unavailable, fail closed for protected content and use a documented human fallback. Do not remove the filter to improve availability.

### Gate 4: bind the complete release

Record the active:

- model or deterministic fixture digest;
- tokenizer and serving configuration where applicable;
- system and task prompt versions;
- corpus snapshot and index build;
- retriever and reranker;
- output schema and verifier;
- tool registry;
- policy bundle;
- application and runtime image;
- evaluation-set identity.

If the active closure differs from the admitted manifest, stop promotion or fall back. A model alias alone is not release identity.

### Gate 5: split output into atomic claims

Do not verify a paragraph as one blob. Split material statements:

```text
1. rev-b completed at 14:01 UTC               -> observable fact
2. errors rose at 14:03 UTC                    -> observable fact
3. rev-b caused the errors                     -> causal claim
4. rollback is allowed for checkout/rev-b       -> policy/runbook claim
5. rollback will restore checkout               -> prediction
```

Claims 1 and 2 do not establish claim 3. Claim 4 requires current authorized runbook and policy evidence. Claim 5 needs mechanism evidence and still remains uncertain.

Unsupported material claims become an explicit abstention. They do not inherit support from nearby sentences.

### Gate 6: classify the proposed capability

There are three useful bands:

1. **explain**: summarize identified evidence;
2. **recommend**: propose a bounded next investigation or action;
3. **effect**: invoke a downstream capability.

Moving from explain to recommend increases validation needs. Moving to effect requires typed tools, authorization, often approval, reconciliation, audit and rollback.

If a proposal needs a shell, arbitrary URL, file path or general administrator identity, it is not ready for assistant execution.

### Gate 7: authorize exact fields

Policy must evaluate trusted identity and every material proposal field. The output "role=admin" is data from an untrusted producer, not an entitlement.

Use default deny. Return a structured reason. Enforce again downstream so a compromised broker cannot bypass object policy.

If policy is unavailable, do not silently treat an error as allow. Decide explicitly whether the operation fails closed, falls back to read-only or enters a separately controlled emergency procedure.

### Gate 8: approve residual risk

For a mutation, show the human:

- what was observed and what remains unknown;
- the exact object and action;
- arguments and preconditions;
- blast radius;
- expected user-visible postcondition;
- rollback or compensation;
- release and policy identities;
- approval expiry.

Bind the decision to a digest and consume it once. If any material field changes, return to policy and approval.

### Gate 9: execute through a state machine

Before calling the target, know how you will answer:

- Was the request never started?
- Was it accepted?
- Is it running?
- Did it complete, fail or partially apply?
- Can the target answer idempotently?
- How is authoritative state queried?

If the result is ambiguous, reconcile. Do not retry because a client timed out.

### Gate 10: validate the user signal

Success is not "the API returned 200" or "the task completed." Re-run the user operation or an approved synthetic equivalent and check guardrails.

For a rollback, validate at least:

- error ratio or success rate;
- latency;
- saturation and dependency health;
- rollback completion and replica readiness;
- unintended impact in adjacent cohorts.

If the user signal did not recover, the incident remains open even if automation completed.

### Gate 11: choose stop or fallback at every boundary

Stop conditions include:

- sensitive data crossed an unapproved boundary;
- cross-tenant retrieval;
- release identity mismatch;
- unsupported material claim promoted as fact;
- unknown tool or field;
- authorization or approval mismatch;
- ambiguous effect without reconciliation;
- audit integrity failure;
- budget or dependency exhaustion.

The fallback is useful but weaker: sanitized evidence, source links, a deterministic checklist and human-owned actions. Say what is unavailable.

## Guided Ubuntu lab

This lab is safe for Ubuntu 24.04 or Ubuntu 24.04 under WSL. It uses synthetic data and the Python standard library. It neither starts a container nor calls a model.

### Lab contract

You may create only the project-local `.runtime` directory through `assistantctl.py`. Do not use real incident data, tokens, provider credentials, production endpoints or `sudo`.

Abort if:

- the repository root is not the expected learning repository;
- `.runtime` contains an unknown file;
- any command requests a credential or network access;
- a fixture contains a real identity or sensitive value;
- cleanup reports an ownership or audit mismatch.

Expected total time is about four hours when you read every receipt and explain each decision. Running the verifier alone is quick; understanding it is the work.

### Step 1: enter the repository without hard-coding a username

From any directory inside the repository:

```bash
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root/drafts/LES-0092-secured-ai-incident-assistant-capstone/support/project"
pwd
```

`git rev-parse --show-toplevel` asks Git for the current worktree root. Command substitution `$(...)` places that output in `repo_root`. Quoting protects paths containing spaces. `pwd` should end with the exact project path.

If Git says the directory is not a repository, locate the clone first. Do not guess a broad filesystem path.

### Step 2: prove the interpreter and local boundary

```bash
python3 --version
find . -maxdepth 2 -type f -print | sort
test ! -e .runtime && echo "precondition: runtime absent"
```

`find .` starts at the current project. `-maxdepth 2` bounds traversal. `-type f` selects files. `sort` makes review stable.

You should see the six JSON contracts, `assistantctl.py`, `verify.py`, tests and documentation. You should not see `.runtime`. Python 3.12 is the recorded tested environment; newer compatible versions require their own verification record.

### Step 3: inspect inputs before trusting code

Start with identities, not every line:

```bash
python3 - <<'PY'
import json
from pathlib import Path

for path in sorted(Path(".").glob("*.json")):
    data = json.loads(path.read_text(encoding="utf-8"))
    print(f"{path.name:18} schema={data.get('schemaVersion')} keys={sorted(data)}")
PY
```

The quoted `'PY'` delimiter prevents the shell from expanding characters inside the Python program. The script reads only top-level local JSON files.

Now answer in your own notes:

1. Which file owns incident scope?
2. Which owns runbook lifecycle and tenant?
3. Which owns tool permissions?
4. Which binds the release?
5. Which declares expected adversarial outcomes?

Expected mapping: `incident.json`, `runbooks.json`, `policy.json`, `release.json` and `evaluations.json`. `telemetry.json` owns observations, not authorization.

### Step 4: run the read-only contract check

```bash
python3 assistantctl.py check
```

Expected:

```text
check=pass authority=local-fixture-only model=none network=none
```

Explain each field:

- `check=pass`: implemented fixture checks passed;
- `authority=local-fixture-only`: no external source is being claimed;
- `model=none`: candidate behavior is deterministic code;
- `network=none`: the required path has no network client.

Do not translate this into "the AI assistant is secure." There is no AI runtime in this path.

### Step 5: create exact disposable state

```bash
python3 assistantctl.py initialize
python3 assistantctl.py status
find .runtime -maxdepth 2 -type f -print | sort
```

Inspect the descriptor:

```bash
python3 -m json.tool .runtime/descriptor.json
```

Find the project identifier, input digests and owned paths. Those fields let cleanup distinguish known state from an arbitrary directory.

Checkpoint: why is a marker file better than trusting the directory name? Because directory names can be copied, mistyped, mounted differently or populated by another process. A descriptor adds identity and content checks; it is still not protection against an attacker who controls the whole directory and trust root.

### Step 6: run and inspect the baseline

```bash
python3 assistantctl.py baseline
python3 -m json.tool .runtime/receipts/baseline.json
```

Locate:

- the active release and corpus identities;
- four verified claims;
- evidence IDs for every claim;
- two abstentions;
- retrieval scope;
- policy result;
- work-unit count;
- zero external effect.

Write two columns:

```text
can say                                      cannot yet say
rev-b preceded the error event               rev-b caused the error
approved rollback runbook exists             rollback will certainly recover users
dependency timeout signal was observed       dependency is the only cause
```

If your "can say" column contains a cause that the receipt does not support, re-read the evidence.

### Step 7: inspect the injection decision

```bash
python3 assistantctl.py scenario prompt-injection
python3 -m json.tool .runtime/receipts/scenario-prompt-injection.json
```

Confirm all of the following:

- outcome is `blocked`;
- the content is identified as untrusted;
- no policy or approval was manufactured;
- no tool effect exists;
- an audit event records the reason.

Then state the proof boundary: this case blocks one known synthetic injection. It does not prove prevention of unseen attacks.

### Step 8: run the three most dangerous operational branches

```bash
python3 assistantctl.py scenario cross-tenant
python3 assistantctl.py scenario unauthorized-scope
python3 assistantctl.py scenario ambiguous-outcome
```

Expected outcomes:

| Case | Expected | Why |
| --- | --- | --- |
| `cross-tenant` | blocked | forbidden content must not enter context |
| `unauthorized-scope` | blocked | generated proposal cannot widen trusted scope |
| `ambiguous-outcome` | ambiguous | accepted plus timeout is not safe to retry |

For the ambiguous case, inspect its receipt and identify task identity, known observations and missing terminal evidence. The correct response is reconciliation, not another mutation.

### Step 9: exercise release, audit and kill boundaries

```bash
python3 assistantctl.py scenario release-drift
python3 assistantctl.py scenario audit-tamper
python3 assistantctl.py scenario kill-switch
```

All three prevent normal promotion, but their outputs differ. Release drift and audit damage are blocked safety invariants. Kill state selects deterministic fallback. An operator still receives useful sanitized evidence without generation or tools.

This distinction matters: a safe system should degrade deliberately rather than collapse every failure into a blank screen.

### Step 10: run all tests and the absent-to-absent verifier

First clean the manually created runtime:

```bash
python3 assistantctl.py cleanup
test ! -e .runtime
```

Now run:

```bash
python3 verify.py
```

The verifier should report 22 tests, 16 scenarios and absent cleanup. Expected scenario totals are:

- 12 `blocked`;
- 3 `fallback`;
- 1 `ambiguous`.

It also verifies four baseline claims, two abstentions, nineteen audit records and eight dossier sections.

### Step 11: inspect static absence of powerful clients

```bash
python3 - <<'PY'
import ast
from pathlib import Path

for name in ("assistantctl.py", "verify.py"):
    tree = ast.parse(Path(name).read_text(encoding="utf-8"))
    imports = sorted({
        alias.name.split(".")[0]
        for node in ast.walk(tree)
        if isinstance(node, ast.Import)
        for alias in node.names
    } | {
        node.module.split(".")[0]
        for node in ast.walk(tree)
        if isinstance(node, ast.ImportFrom) and node.module
    })
    print(name, imports)
PY
```

You should not find model SDKs, HTTP clients, sockets, subprocess, Docker or Kubernetes clients. Static absence supports the local no-client claim. It cannot detect every possible indirect effect in arbitrary code, which is why tests and code review remain necessary.

### Step 12: final cleanup proof and lab report

```bash
test ! -e .runtime && echo "final evidence: runtime absent"
git status --short
```

The lab should not modify tracked files. If `git status` shows changes, inspect them; do not discard unrelated user work.

Your lab report must contain:

1. exact environment and commit;
2. the six input authorities;
3. baseline supported and unsupported statements;
4. sixteen case outcomes by slice;
5. one explanation of cross-tenant containment;
6. one ambiguous-effect reconciliation plan;
7. kill and fallback behavior;
8. cleanup evidence;
9. what this lab proves;
10. what still requires representative model, security and production evaluation.

## Production transfer

The local fixture is a design instrument. Moving to a real model or incident system is a new engineering project, not a configuration toggle.

### Start with the decision, not the chatbot

Define the exact user and operation:

```text
During a declared incident, an authenticated responder requests a
source-linked summary and bounded next-investigation suggestions for
one authorized service and environment.
```

That is safer and more measurable than "AI helps with incidents." Decide which actions remain impossible, which remain manual and which may later enter a reversible automation stage.

Write success and harm metrics before selecting a model:

- time to find relevant evidence;
- supported-claim rate;
- useful abstention rate;
- responder correction rate;
- cross-scope retrieval count;
- sensitive-data exposure count;
- unsupported high-risk recommendation count;
- reviewer minutes per case;
- task latency and cost;
- incident outcome guardrails.

### Build a non-AI baseline

Compare the model-assisted path with search, dashboards, runbook links and deterministic templates. If a curated search page is equally useful, the model adds cost and attack surface without clear benefit.

A fair experiment uses the same synthetic or approved incident cases and measures human task outcomes, not whether respondents liked the prose. Capture time, correctness, missed evidence, unsafe recommendations and reviewer burden.

### Create the data contract

Inventory each source:

| Source | Owner | Classification | Freshness | Scope key | Retention | Failure mode |
| --- | --- | --- | --- | --- | --- | --- |
| alert event | observability team | internal | seconds | tenant/service/env | incident policy | missing labels |
| trace exemplar | application owner | restricted | seconds | trace plus tenant | short | payload leakage |
| deployment | delivery platform | internal | minutes | service/env/revision | audit policy | stale status |
| runbook | service owner | internal/restricted | reviewed version | tenant/service/env | lifecycle | retired guidance |
| policy | security/platform | controlled | admitted bundle | subject/action/object | policy retention | unavailable engine |

For every field, state whether it may enter retrieval, model input, model output, trace, cache, audit and evaluation storage. "Internal" is not a sufficient classification.

Use synthetic identities in development. A production evaluation set containing incident text may itself become sensitive operational data.

### Choose a model boundary

Deployment options include:

- hosted provider API;
- organization-managed cloud endpoint;
- on-premises serving;
- local model for a bounded environment;
- deterministic templates with no generative model.

The selection changes data residency, egress, authentication, isolation, logging, update control, capacity, cost and incident dependencies. It does not remove the need for external authorization and verification.

For a provider, verify current official terms and controls for data retention, training use, region, encryption, access logging, abuse monitoring, availability and version changes. Do not infer them from a product name or an old blog post.

### Implement an adapter, not model authority

Place a narrow adapter behind the existing candidate contract:

```text
AssistantCandidate generate(
  release_id,
  sanitized_incident,
  authorized_fragments,
  allowed_output_schema,
  deadline,
  budget
)
```

The adapter owns request formatting, provider error translation, token budgets and response parsing. It must not own user identity, policy, approval or downstream credentials.

Reject responses that fail schema or release identity. Keep raw model output out of normal logs. Record bounded metrics and masked diagnostic codes.

### Replace exact fixture matching with measured verification

Real-language verification can combine:

- deterministic checks for numbers, timestamps, identifiers and cited spans;
- source-authority and freshness rules;
- structured calculation;
- a separately evaluated entailment model;
- human review for high-risk or unresolved claims.

An entailment model is also probabilistic. Evaluate it independently, calibrate thresholds and preserve an `insufficient` state. Do not allow one model to generate a claim and then declare itself supported.

### Build the retrieval pipeline as a governed product

Ingestion should:

1. authenticate the source;
2. preserve document and version identity;
3. apply classification and scope metadata;
4. validate lifecycle and owner;
5. chunk without losing provenance;
6. build a versioned index;
7. test retrieval quality and authorization;
8. publish atomically;
9. retain rollback;
10. remove revoked content from index, caches and derived stores.

Evaluate retrieval separately from generation. Useful measures include recall at a bounded candidate count, precision, forbidden-retrieval rate, stale-fragment rate and no-answer behavior. Slice by service, language, document type and incident class.

### Introduce tools through maturity stages

Use a one-way promotion path:

```text
offline fixture
  -> shadow with no responder output
  -> read-only source-linked assistance
  -> recommendation only
  -> human-executed action
  -> one reversible typed tool
  -> bounded automation under explicit policy
```

Each stage needs entry criteria, observation period, exit criteria and rollback. Never make tool access the reward for a good demo.

The first effect should be low blast radius, idempotent or reconcilable, reversible and easy to validate. Server-side object authorization remains mandatory.

### Design for provider and assistant outage

The incident process must continue if the model endpoint, vector index, policy engine or assistant UI is unavailable. Decide:

- which data is still visible;
- whether cached runbooks may be used and for how long;
- which operations fail closed;
- who can invoke emergency manual procedures;
- how the assistant is disabled;
- how recovery is verified.

Do not place the only copy of a critical runbook behind the assistant.

### Separate rollout from proof

Passing an offline evaluation allows only the next controlled stage. A production rollout needs:

- representative evaluation with protected data handling;
- independent security and privacy review;
- red-team cases not visible to builders;
- accessibility and human-factors review;
- load and failure testing;
- rollback rehearsal;
- on-call ownership;
- monitoring and alert response;
- documented residual-risk acceptance.

A clean local verifier remains valuable as a regression gate, but it is one layer of evidence.

## Reliability, security, observability, capacity, and cost

An assistant in incident response becomes part of the socio-technical control plane. Treat it with the same discipline as deployment automation, while remembering its output is probabilistic.

### Reliability: define the service level around user value

Possible SLIs include:

- valid response ratio;
- grounded material-claim ratio;
- authorized retrieval ratio;
- time to first source-linked evidence;
- complete response latency;
- fallback availability;
- tool reconciliation completion;
- responder-confirmed usefulness.

Availability alone is misleading. An assistant that returns fluent unsupported output is available but harmful.

Example objective:

> For approved read-only incident-summary requests in a rolling 28-day window, 99% return either a schema-valid source-linked response or an explicit safe fallback within 20 seconds, with zero confirmed cross-tenant disclosures.

This is only an example. Select values from user need and measured capability. Confidentiality may be a zero-tolerance release gate rather than an error-budget metric.

Dependencies need separate budgets: identity, telemetry, corpus, index, model, policy, approval and audit. A shared dependency can create correlated failure with the production service under investigation.

### Reliability: deadlines, retries and graceful degradation

Allocate an end-to-end deadline:

```text
identity 0.5s
retrieval 2.0s
generation 8.0s
verification 2.0s
policy 0.5s
response reserve 2.0s
total 15.0s
```

Do not blindly retry model generation; it may consume budget and return different output. Retrieval retries must respect deadline and idempotency. Tool retries require outcome reconciliation.

Graceful degradation can return:

1. verified source-linked summary;
2. deterministic evidence list when generation fails;
3. authorized runbook links when verification fails;
4. incident contact and manual checklist when dependencies fail.

Label each mode so responders know what capability is missing.

### Security: threat-model every boundary

Assets include incident evidence, customer data, runbooks, credentials, tool authority, approval identity, release artifacts and audit history.

Threat actors include external users, compromised accounts, malicious insiders, poisoned sources, compromised dependencies and accidental operators. The model and retrieved content are not actors in the human sense, but their output remains untrusted input.

Important threats:

- direct and indirect prompt injection;
- corpus or index poisoning;
- cross-tenant retrieval;
- sensitive-data leakage through prompts, traces, caches and output;
- insecure output rendered into HTML, SQL, shell or URLs;
- excessive tool authority;
- approval replay or confused deputy behavior;
- model, prompt or policy supply-chain substitution;
- audit tampering;
- denial of wallet or resource exhaustion;
- kill-switch bypass.

Controls should be independent and layered. Prompt wording is a usability control, not an authorization boundary.

### Security: least privilege and complete mediation

Give the broker a distinct workload identity. Grant only named actions over named resource scopes. Use short-lived credentials where supported. Avoid sharing responder or cluster-admin credentials.

Every request must be checked, not only the first request in a conversation. Conversation state can change; policy and resource ownership can change. Downstream enforcement protects against a compromised orchestrator.

Render model output according to its sink. Escape HTML, parameterize database operations, forbid open redirects and never interpolate generated text into a shell.

### Security: supply-chain closure

The release manifest should bind:

- source commit;
- dependency lock;
- container or runtime image digest;
- model and tokenizer identity;
- prompt templates;
- corpus and index;
- output schemas;
- tool registry;
- policy bundle;
- evaluator and evaluation set;
- build provenance and signatures where applicable.

Verify signatures and provenance at admission, but remember: a signed harmful artifact is authentically harmful. Security testing and review remain necessary.

### Observability: trace decisions without leaking content

Use one correlation chain:

```text
request_id
  -> retrieval_id
  -> candidate_id
  -> verification_id
  -> policy_decision_id
  -> approval_id
  -> effect_task_id
  -> validation_id
```

Metrics should use bounded labels such as release, stage, result and error class. Never use prompt text, incident description, user ID or document content as metric labels.

Useful counters and histograms include:

- requests by mode and outcome;
- retrieval empty, forbidden and stale counts;
- claims supported, contradicted, insufficient and unverifiable;
- abstentions;
- policy allow/deny/error;
- approval expired/replayed/mismatched;
- tool accepted/completed/failed/ambiguous;
- kill and fallback activations;
- token, retrieval and verifier work units;
- latency per stage.

Trace sampling and logging policies must account for sensitive context. A debug flag should not silently record raw prompts in production.

### Observability: alerts must be actionable

Page when immediate human action protects users or authority:

- confirmed cross-tenant retrieval;
- unauthorized effect attempt;
- kill control failure;
- audit integrity failure during active automation;
- ambiguous high-risk effect requiring reconciliation.

Ticket or investigate trends:

- rising abstention;
- retrieval no-answer increase;
- latency or cost regression;
- drift in claim support;
- reviewer disagreement;
- capacity saturation.

Alert on symptoms and guardrails, not every model exception. If fallback is healthy and user impact is low, a page may create more incident load than value.

### Capacity: model the whole queue

Estimate arrivals, service time and concurrency by stage. One slow model request holds memory, connection slots and downstream budget. Tail latency grows sharply as utilization approaches saturation.

For a rough planning example, if peak arrival is 4 requests/second and generation occupies a slot for 8 seconds, average in-flight generation demand is about 32 slots before headroom, retries or variance:

```text
in_flight ~= arrival_rate * service_time
           ~= 4 requests/s * 8 s
           ~= 32 requests
```

This is Little's Law under stable averages, not a sizing guarantee. Load-test realistic token lengths and tail behavior.

Bound:

- concurrent requests per tenant and globally;
- input and output tokens;
- retrieved fragments and bytes;
- tool proposals per incident;
- evaluation and retry work;
- queue wait;
- maximum total deadline.

Prefer admission control and explicit fallback over an unbounded queue during a major incident.

### Capacity: incident correlation risk

The worst time for an assistant may be a widespread incident when every responder opens it and shared telemetry is already overloaded. Protect primary incident systems:

- use bounded read APIs;
- cache only appropriately scoped and fresh data;
- isolate assistant quotas;
- shed expensive enrichment;
- avoid fan-out queries;
- test regional and dependency failure.

The assistant must not amplify the incident it is meant to help.

### Cost: count the complete unit

Model-call price is only one component:

```text
cost per useful reviewed outcome =
  model inference
  + embedding and indexing
  + retrieval storage and queries
  + observability and protected audit
  + policy/approval infrastructure
  + evaluation and red-team work
  + responder review time
  + engineering and on-call ownership
```

Track cost by useful task and release, not only by token. A cheap answer that wastes ten responder minutes is expensive.

Cost controls include prompt minimization, retrieval budgets, smaller evaluated models for bounded tasks, caching of non-sensitive stable artifacts, batching where latency permits, per-tenant quotas and deterministic fallback.

Never trade confidentiality or authorization for a lower bill.

### Performance: measure quality and latency together

Changing fragment count, context length, model size, quantization, batching or verifier depth can improve one metric while harming another. Use a Pareto view across:

- task success;
- critical safety failures;
- latency percentiles;
- throughput;
- resource use;
- cost;
- human review time.

Promote only an artifact closure that meets all critical gates and an acceptable operating envelope. An average score cannot compensate for one cross-tenant disclosure.

## Traps and prevention

### Trap: a polished answer is treated as a diagnosis

**Why it fails:** language quality and factual support are different properties.

**Prevention:** require atomic claims, exact evidence IDs, support states and visible abstentions. Keep incident command with accountable humans.

### Trap: any citation is called grounding

**Why it fails:** the cited text may be irrelevant, stale, forbidden or contradictory.

**Prevention:** verify source authority, scope, version and claim-level support. Show the exact span, not only a document title.

### Trap: vector similarity is used as access control

**Why it fails:** semantic closeness says nothing about the subject's entitlement.

**Prevention:** constrain and authorize candidate objects before context assembly, verify again at use and include tenant/service/environment in cache identity.

### Trap: a stronger prompt is the prompt-injection defense

**Why it fails:** untrusted content can influence a generator, and novel attacks will not match a phrase list.

**Prevention:** separate instructions from data, validate structured output, use narrow capabilities, external policy, downstream mediation, exact approval and adversarial evaluation.

### Trap: sensitive data is removed only from the final answer

**Why it fails:** the value may already exist in input, retrieval logs, provider systems, traces, caches or audit.

**Prevention:** classify and minimize before context construction; inventory every derived surface; use protected retention and deletion controls.

### Trap: the model name identifies the release

**Why it fails:** prompt, corpus, index, schema, tools, policy and runtime change behavior.

**Prevention:** create an immutable full-closure manifest and admit only tested digests.

### Trap: read-only means safe

**Why it fails:** read tools can disclose protected content, overload systems or enable lateral movement.

**Prevention:** apply object authorization, query budgets, classification, rate limits, redaction and audit to reads.

### Trap: human approval makes any tool acceptable

**Why it fails:** a human cannot meaningfully approve hidden arguments, arbitrary shell or a reusable capability under incident pressure.

**Prevention:** minimize tool power first; then bind one informed approval to exact arguments, risk, expiry and postcondition.

### Trap: a timeout means failure

**Why it fails:** the target may have accepted or completed the effect.

**Prevention:** preserve idempotency/task identity and reconcile authoritative state before retry.

### Trap: audit means store everything

**Why it fails:** raw prompts and retrieved content create a concentrated sensitive-data store.

**Prevention:** keep structured decision identity, masking indicators and protected evidence references; capture content only through an explicit investigation control.

### Trap: an average evaluation score permits release

**Why it fails:** strong common-case results can hide catastrophic failures in rare slices.

**Prevention:** define zero-tolerance or strict critical gates for confidentiality, authorization and unsafe effects; report every slice and uncertainty.

### Trap: a kill switch inside the assistant is independent

**Why it fails:** the same failure, identity or route can disable both service and stop control.

**Prevention:** own broker disablement, credential revocation, routing denial and fallback through a separate control boundary; exercise it.

### Trap: local tests establish production safety

**Why it fails:** fixtures cannot cover open-ended language, real data, integrations, traffic, adversaries or human behavior.

**Prevention:** state the proof boundary; add representative evaluation, independent review, staged rollout, monitoring and rollback.

## Memory card and retrieval

### The sentence to remember

> The model may propose language; identified sources own facts, policy owns permission, approval owns accepted risk, the target owns effect state, and humans own incident command.

### The twelve-link chain

```text
scope
 -> minimize
 -> authorize retrieval
 -> bind release
 -> generate candidate
 -> verify claims
 -> validate typed proposal
 -> authorize
 -> approve exact mutation
 -> execute and reconcile
 -> validate user signal
 -> audit, kill and fallback
```

If one link is missing, do not hide the gap with fluent text.

### Five fast questions during an incident

1. What is observation, hypothesis and decision?
2. Which source supports this exact claim?
3. Was every fragment authorized before it entered context?
4. Who independently authorizes this exact effect?
5. If the call timed out, where is authoritative task and target state?

### Proof vocabulary

- **Observed:** an identified source reported it.
- **Supported:** evidence establishes the material claim under a stated rule.
- **Inferred:** reasoning connects evidence but uncertainty remains.
- **Authorized:** policy allowed the exact operation.
- **Approved:** an authorized human accepted one exact residual-risk decision.
- **Accepted:** a target registered work.
- **Completed:** the target reported a terminal successful effect.
- **Validated:** the intended postcondition and user signal passed.
- **Reconciled:** task and target state resolved a previously ambiguous outcome.
- **Abstained:** evidence was insufficient to claim more.

### Retrieval practice

Close the page and answer:

1. Why is a citation not proof?
2. Where must tenant authorization happen?
3. What changes invalidate an approval?
4. Why can a 202 response not trigger a blind retry?
5. Which system must own the kill state?
6. What does the local verifier not prove?

Reopen the page, correct your answer, then explain it aloud in two minutes. Repeat tomorrow and one week later. Recognition while reading is not retrieval.

## Complete answers

### Answer 1: What is the difference between an AI answer and evidence?

An AI answer is generated output. Evidence is an identified observation or source with provenance, scope, time and meaning.

A model may say "database CPU saturation caused checkout failures." Evidence would be a timestamped database CPU series, request traces showing time spent waiting on that database, saturation or queue measurements, and a controlled change or recovery pattern consistent with the mechanism.

The answer can help form a hypothesis. It cannot upgrade itself into evidence. During an incident, label generated text as candidate reasoning and attach each material claim to independent evidence.

### Answer 2: What does retrieval-augmented generation add, and what does it not add?

RAG adds selected external context to generation. It can make current runbooks or incident evidence available without placing everything in model parameters, and it can expose citations.

It does not guarantee:

- that the correct fragment was retrieved;
- that retrieval was authorized;
- that the source is current or true;
- that the model followed the source;
- that a citation entails the claim;
- that document instructions were harmless.

Treat retrieval, authorization, generation and claim verification as separate measurable components.

### Answer 3: Why is semantic similarity not authorization?

Similarity estimates how close two representations are under one embedding and index. Authorization decides whether a verified subject may perform an operation on an object in context.

A confidential tenant-b rollback document may be the most similar item to a tenant-a question. Returning it would be a high-quality similarity result and a confidentiality failure.

Apply trusted scope and object policy before forbidden content enters context. Include scope in caches and recheck before use.

### Answer 4: Why is a citation not sufficient grounding?

A citation can exist while the statement overreaches. A source saying "revision rev-b was deployed at 14:01" supports deployment time, not "rev-b caused database saturation."

Grounding needs:

1. identified and authorized source;
2. current version and provenance;
3. exact relevant span;
4. a material claim no broader than the span supports;
5. handling for contradiction or insufficient evidence.

When support is incomplete, the strong response is an explicit abstention plus the next evidence needed.

### Answer 5: What is prompt injection in this system?

Prompt injection occurs when untrusted input attempts to influence model behavior as if it were an instruction. It can be direct in a user request or indirect inside a runbook, ticket, log, webpage or retrieved document.

The risk is not only offensive text. An injected document can ask for secret disclosure, policy bypass, tool use or source suppression.

Because it is impossible to rely on perfect text detection, architecture contains the consequence: content remains data, output is typed and verified, authority stays outside the generator, tools are narrow, downstream authorization repeats and adversarial cases are evaluated.

### Answer 6: Why is filtering suspicious phrases insufficient?

Attackers can paraphrase, encode, split or contextually disguise instructions. Legitimate security documentation may also contain the same phrases, causing false positives.

Filters are useful as one signal and quarantine aid. They are not an authorization mechanism. The robust controls are structural: trust separation, scope enforcement, schema validation, least privilege, external policy, exact approval and effect reconciliation.

### Answer 7: What is behavioral artifact closure?

It is the complete set of versioned artifacts that can change system behavior. For this assistant it includes more than a model:

- model and tokenizer;
- prompts;
- corpus and index;
- retriever/reranker;
- schemas and verifier;
- tool registry;
- policy;
- application/runtime;
- evaluation set and configuration.

Bind their digests into one immutable release manifest. If any member changes, the active behavior is no longer the evaluated release and must return through appropriate gates.

### Answer 8: Why must evaluation data be separated?

If builders tune prompts, rules or cases while repeatedly seeing the final evaluation answers, the system learns the test rather than the broader task. Reported performance becomes optimistic.

Use development cases for iteration, a protected validation set for decisions and reviewer-owned hidden cases for independent transfer or final gates. Track dataset identity, provenance, leakage risk and slice coverage.

For sensitive incident data, separation also includes access, retention and privacy controls.

### Answer 9: Why can critical invariants override average quality?

Suppose 999 answers are helpful and one discloses another tenant's runbook. A 99.9% helpful average does not make that disclosure acceptable.

Aggregate metrics summarize common behavior; critical invariants constrain unacceptable behavior. Confidentiality, authorization and harmful-effect failures often need zero observed failures in the admission set plus confidence bounds, red-team review and staged monitoring.

This does not mathematically prove zero future failures. It establishes a conservative release rule and makes residual uncertainty explicit.

### Answer 10: What makes a tool typed and bounded?

A typed tool has a versioned schema with allowed fields, types, ranges and semantics. A bounded tool also limits subject, objects, operation, arguments, rate, deadline and blast radius.

`restart_workload(namespace_id, workload_id, expected_revision, idempotency_key)` can be authorized and reconciled. `run_shell(command)` delegates arbitrary future meaning to untrusted text.

The downstream service must validate the same object permissions and preconditions. Schema validation at the assistant is necessary but not sufficient.

### Answer 11: What is complete mediation?

Complete mediation means every access is checked against current authority, rather than trusting that an earlier check permanently covers later operations.

In this path, retrieval checks document access, the broker checks the exact tool proposal, approval checks the exact digest and the downstream target checks object authority again. A long conversation, cached result or previous allow does not become a permanent entitlement.

This limits damage when scope, role, policy or target ownership changes and protects against a compromised intermediate component.

### Answer 12: Why bind approval to a proposal digest?

A digest is a stable fingerprint of the canonical proposal fields. Binding approval to it prevents approval of one action from being reused for a different target, argument or release.

The approval also needs approver identity, incident scope, issue and expiry time, policy revision and single-use state. The reviewer must see the same material fields that are hashed.

A digest does not make a bad proposal good. It proves only that the approved object matches the executed object when canonicalization and verification are correct.

### Answer 13: What is the difference between accepted and completed?

Accepted means a service registered the request or task. Completed means the target reached a terminal success state for the effect.

An asynchronous API often returns HTTP 202 and a task ID. The client must query that task or receive a trusted terminal event. Even completed is not the final user outcome: verify the intended postcondition and SLI.

Treating accepted as completed leads to false success. Treating a timeout after accepted as failure leads to duplicate retries.

### Answer 14: What should happen after an ambiguous timeout?

Stop automatic mutation. Preserve proposal, idempotency and task identities. Query the task system and authoritative target state. Compare the intended postcondition.

Classify the outcome as completed, failed, partial or still ambiguous. Retry only when target semantics and the reconciliation result prove that doing so is safe. Otherwise escalate to a human with the exact uncertainty and compensation options.

Do not make a second model call to guess whether the first effect happened.

### Answer 15: What should a useful audit contain?

It should reconstruct who requested what, under which evidence and release, which policy decided, what was approved, what effect identity resulted and whether the user signal recovered.

Useful fields include request/incident/subject/scope IDs, source and artifact versions, claim-support decisions, proposal digest, policy decision, approval identity and lifetime, task/effect state, postcondition, validation result and masking indicators.

Protect access and integrity. Avoid raw prompts, secrets and unrestricted retrieved content by default. A hash chain detects some modification but needs protected anchors and storage for production assurance.

### Answer 16: Why must the kill path be independent?

A stop control must remain usable when the assistant application, model path, credentials or output is compromised. If disabling the assistant requires asking that same assistant to act, one failure can remove both service and control.

Independent controls include disabling the broker, revoking its workload identity, denying its route, scaling its workers to zero or changing external policy. Ownership and access should be separate enough to survive the target failure.

Test kill activation, in-flight work handling, audit and recovery. A button that has never been exercised is a hypothesis.

### Answer 17: What is a deterministic fallback?

It is a non-generative path that exposes bounded useful information under known rules: sanitized observations, authorized runbook links, source timestamps, missing-evidence indicators and a human checklist.

It should not reuse the failed generator or broad tool path. Label fallback clearly and state what is unavailable. Keep it small enough to test and operate during dependency failure.

Fallback preserves incident capability; it does not need to imitate fluent AI output.

### Answer 18: What must be evaluated when a real-model adapter is added?

Evaluate the complete release on representative, separated and adversarial cases:

- retrieval relevance and forbidden-access rates;
- material claim support, contradiction and abstention;
- prompt-injection and data-exfiltration resistance;
- schema and tool-proposal validity;
- critical authorization/effect invariants;
- latency, capacity and cost;
- privacy and logging behavior;
- human task accuracy, correction and review time;
- behavior under dependency failure and kill.

Slice by incident type, service, language, input length, document type, risk and user group where appropriate. Compare with the non-AI baseline. An adapter passing the deterministic fixture contract is only the starting gate.

### Answer 19: What does `python verify.py` prove and not prove?

It proves that, on the tested interpreter and repository version, the implemented deterministic lifecycle matches its locked contracts: 22 tests, one baseline, sixteen expected scenario outcomes, audit/dossier checks and exact cleanup. Static tests support the declared absence of model, network and external clients.

It does not prove:

- the open-ended behavior of a model;
- real-provider or external-system integration;
- representative population quality;
- universal attack resistance;
- production availability or safety;
- learner understanding or incident competence.

Always state both halves. A test result without its boundary is easy to misuse.

### Answer 20: What evidence would support mastery?

Reading completion and a passing guided lab are not mastery. Stronger evidence includes:

1. independently designing a changed-domain architecture;
2. implementing strict contracts and a guarded harness without copying the answer;
3. finding reviewer-owned hidden faults;
4. explaining trade-offs under questioning;
5. resolving an ambiguous effect safely;
6. producing a threat model, evaluation dossier and production transfer plan;
7. repeating the work after delay;
8. receiving independent review.

Even that proves competence for a bounded task, not permanent expertise or guaranteed employment. Mastery remains maintained practice across changing systems.

## Product-company interview

These are not trivia prompts. A strong answer begins with user impact, separates evidence from inference, names authorities, controls blast radius and explains proof limits.

### Scenario 1: the assistant confidently names a root cause

**Question:** During a payment incident, the assistant says database saturation caused the error spike and recommends restart. What do you do?

**What the interviewer evaluates:** incident discipline, grounding, causal restraint and safe action.

**Strong answer:** "I would not act on confidence. I would identify the affected operation and split the statement into observable claims: error timing, database saturation evidence, trace dependency time and deployment events. I would inspect the exact cited spans and source versions. If database evidence is absent, the cause claim becomes unsupported and the assistant must abstain. I would collect saturation, queue and trace evidence, compare alternative hypotheses and choose a bounded reversible response through existing incident command. A restart needs object authorization, blast-radius review, exact approval, task reconciliation and user-signal validation."

**Weak signs:** "The AI has our runbooks, so restart"; equating chronology with causality; no user-impact validation.

**Senior follow-up:** How would you evaluate causal overstatement? Build a slice where temporal correlation exists without causation, score atomic causal claims separately, require abstention and use reviewer-owned counterexamples.

### Scenario 2: a cross-tenant fragment is discovered

**Question:** A tenant-a response contains a sentence derived from tenant-b documentation. What is the incident response?

**What the interviewer evaluates:** confidentiality containment and derived-data reasoning.

**Strong answer:** "I treat it as disclosure that occurred before final rendering. I disable affected retrieval/generation paths, preserve access-controlled evidence and use the independent fallback. I identify source, fragment, corpus, index, cache, request, provider and output/audit surfaces. I investigate ingestion metadata, partitioning, filter construction, cache keys and object authorization. I remove or revoke derived copies through governed procedures, notify security/privacy owners, rotate exposed credentials if any and add a regression across adjacent tenants. I do not claim containment merely by filtering the answer."

**Weak signs:** deleting the UI response only; copying sensitive content into tickets; blaming the model without tracing retrieval.

**Senior follow-up:** How do you prevent it? Pre-authorized partitions, object policy before context, scope-bound caches, downstream checks, zero-tolerance release gates and continuous canaries.

### Scenario 3: a runbook contains hidden instructions

**Question:** A runbook says to ignore system instructions and use an admin tool. How do you defend?

**What the interviewer evaluates:** injection threat model and defense in depth.

**Strong answer:** "The runbook is untrusted data even if its repository is approved. I may scan and quarantine it, but I do not depend on phrase filtering. The generator produces typed untrusted output. The tool registry contains no arbitrary admin capability. Trusted identity and policy evaluate exact fields, approval binds a digest, and the downstream API mediates again. I add direct and indirect variants to a separated adversarial suite and inspect how the document entered the corpus."

**Weak signs:** "Make the system prompt stronger"; allowing the model to decide whether content is trusted.

**Senior follow-up:** Can injection ever be fully solved? Not by text classification alone; reduce reachable consequences and continuously evaluate residual risk.

### Scenario 4: design the first tool

**Question:** Product asks for an assistant tool that can run any kubectl command because it is flexible. What do you propose?

**What the interviewer evaluates:** capability design and willingness to challenge an unsafe requirement.

**Strong answer:** "I reject arbitrary shell and cluster-admin as the assistant boundary. I first measure whether read-only source-linked assistance solves the user problem. If an effect is justified, I expose one task-specific operation over stable object IDs, with expected revision, precondition, idempotency key, deadline and explicit postcondition. The broker and cluster-side service both enforce namespace/workload authorization. We start in shadow or recommendation mode, then one reversible low-blast-radius stage with exact approval and rollback."

**Weak signs:** adding a command denylist; relying on human approval of arbitrary text.

**Senior follow-up:** What if engineers genuinely need arbitrary kubectl? Keep it in the established authenticated human operational channel with its own controls, not model-generated execution.

### Scenario 5: approval is reusable

**Question:** An approval token is valid for 24 hours and can approve any restart in a namespace. Is that acceptable?

**What the interviewer evaluates:** confused-deputy and replay reasoning.

**Strong answer:** "That is delegated future authority, not approval of one decision. I bind approval to the canonical proposal digest, subject, incident, target, arguments, release, policy, expected postcondition and short expiry, and consume it once. The reviewer sees evidence, uncertainty, blast radius and rollback. A changed proposal returns through policy and approval."

**Weak signs:** "It is okay because only on-call engineers approve"; no replay or visibility discussion.

**Senior follow-up:** Where is approval checked? At a service independent of generation and again at the effect broker before downstream authorization.

### Scenario 6: the effect API times out

**Question:** The tool received 202 Accepted, then the client timed out. Should it retry?

**What the interviewer evaluates:** distributed state and safe retry.

**Strong answer:** "No blind retry. Accepted means the target registered work. I persist idempotency and task IDs, query terminal task state and authoritative target state, compare the intended postcondition and classify completed, failed, partial or ambiguous. Retry only if target idempotency semantics and reconciliation prove it safe. Then validate the user SLI."

**Weak signs:** "Use exponential backoff"; assuming timeout means failure.

**Senior follow-up:** When is an idempotency key insufficient? When the target does not honor it, retention expired, arguments changed or multiple downstream effects are not transactionally bound.

### Scenario 7: the model alias stayed constant

**Question:** Quality regressed even though the configured model name did not change. How do you investigate?

**What the interviewer evaluates:** release engineering for behavioral systems.

**Strong answer:** "I compare the complete active manifest with the admitted manifest: exact model and tokenizer, serving parameters, prompts, corpus snapshot, index, retriever/reranker, schemas, verifier, tool registry, policy, application and evaluation identity. I also check provider-side version behavior where applicable. I freeze promotion or roll back to known digests, reproduce the regression by slice and restore only after compatibility and critical gates pass."

**Weak signs:** checking only model name or temperature; tuning directly in production.

**Senior follow-up:** How do you handle a provider that updates behind an alias? Pin an immutable version when supported, monitor fingerprints and behavior canaries, contract for change notification, and maintain fallback or provider portability proportionate to risk.

### Scenario 8: the average score is excellent

**Question:** The system scores 97% overall, but one hidden case allows a cross-tenant document. Ship?

**What the interviewer evaluates:** evaluation judgment and risk ownership.

**Strong answer:** "No. Overall task score cannot average away confidentiality failure. I block promotion, trace the retrieval and cache boundary, repair complete mediation, expand adjacent hidden slices and rerun the exact release. I report sample sizes and uncertainty rather than claiming universal safety. Release requires the critical confidentiality gate plus independent security/privacy review."

**Weak signs:** accepting the error because it is below 3%; removing the case; reporting only the aggregate.

**Senior follow-up:** Does zero failures prove safety? No. It provides evidence bounded by the evaluated sample; confidence, coverage, red team, staged rollout and monitoring address remaining uncertainty.

### Scenario 9: observability wants full prompts

**Question:** The operations team asks to log every prompt and response for debugging. What do you decide?

**What the interviewer evaluates:** observability/privacy trade-offs.

**Strong answer:** "I start from the debugging question and store structured identities, stage outcomes, release versions, reason codes, masked-field indicators and protected evidence references. Full content is off by default because incidents may include credentials, customer data or sensitive topology. If a limited capture is necessary, it needs explicit access, encryption, short retention, deletion, audit and incident-specific authorization. Metrics never use content as labels."

**Weak signs:** logging everything in a central platform; assuming redaction is perfect.

**Senior follow-up:** How do you debug a grounding failure without raw prompt storage? Reproduce from governed source and artifact identities in a protected environment, or enable bounded approved capture for selected synthetic/consented cases.

### Scenario 10: design the kill switch

**Question:** How would you stop a compromised incident assistant during a major outage?

**What the interviewer evaluates:** control independence and recovery.

**Strong answer:** "I separate generation and effect controls. An authorized operator outside the assistant can disable broker policy, revoke workload credentials, deny routes or scale effect workers down. The system stops new effects, reconciles in-flight tasks and records the transition. A deterministic read-only fallback remains. Recovery requires root-cause review, clean release identity, credential restoration, staged validation and explicit re-enable."

**Weak signs:** a prompt saying "do not execute"; an in-app button using the same failed API.

**Senior follow-up:** What should happen to already accepted tasks? Query and reconcile them; kill semantics must define whether queued/running operations are cancelled, completed or escalated.

### Scenario 11: capacity during a global incident

**Question:** Assistant demand increases tenfold while observability systems are degraded. How do you protect production?

**What the interviewer evaluates:** queueing, dependency protection and graceful degradation.

**Strong answer:** "I prioritize incident roles and bounded operations, enforce per-tenant/global concurrency and work budgets, cap retrieval fan-out and context, shed nonessential enrichment and switch to cached authorized runbook links or deterministic fallback. Assistant quotas are isolated from primary telemetry. I expose queue age and mode, reject before deadlines become impossible and avoid retry storms. We pre-load-test this correlated failure."

**Weak signs:** autoscale without dependency limits; unlimited queues; raising telemetry query quotas during its outage.

**Senior follow-up:** Which metrics drive admission? Queue wait versus remaining deadline, stage saturation, downstream health, work units, tenant fairness and fallback capacity.

### Scenario 12: justify the product to leadership

**Question:** How do you decide whether the incident assistant should exist?

**What the interviewer evaluates:** product thinking, cost and accountable risk.

**Strong answer:** "I define a bounded responder task and compare it with a non-AI baseline. In a controlled evaluation I measure time to evidence, correct supported conclusions, abstention, correction burden, critical failures, latency and complete cost. I include security/privacy review, on-call ownership and outage fallback. If curated search performs similarly, I choose the simpler system. If assistance materially improves safe task outcomes, I stage it from read-only with explicit residual-risk ownership."

**Weak signs:** adoption or demo quality as success; claiming headcount replacement; ignoring ongoing evaluation and operations.

**Senior follow-up:** What would make you remove it? Persistent critical failures, no measured advantage, unsustainable review/cost, unacceptable dependency risk or inability to maintain governance.

## Independent transfer and rubric

The independent task is not "repeat the incident-assistant fixture with different names." It tests whether you can transfer the safety principles to a changed domain.

### Assignment

Design a secured assistant for one of these synthetic domains:

- database schema-migration review;
- certificate-renewal operations;
- warehouse job-failure triage;
- feature-flag rollback support;
- backup-restore validation.

An independent reviewer supplies:

- a new synthetic incident and data classification;
- a corpus with authorized, forbidden, retired and adversarial documents;
- at least one read-only and one reversible effect;
- a changed identity/scope model;
- a separated evaluation set;
- at least five hidden faults.

You receive no answer key and may not copy the project fixture as your domain model.

### Required deliverables

1. operation, user, harm and non-AI baseline contract;
2. authority and trust-boundary diagram;
3. strict versioned input/output schemas;
4. release artifact-closure manifest;
5. authorized retrieval design and cache identity;
6. atomic claim/support/abstention contract;
7. typed tool, downstream authorization and reconciliation state machine;
8. digest-bound approval design;
9. privacy-aware audit plus independent kill/fallback;
10. deterministic local harness with safe cleanup;
11. development, separated and hidden evaluation results by slice;
12. production transfer, rollout, rollback, capacity and cost plan;
13. incident response for each discovered hidden fault;
14. short oral defense.

### Mandatory hidden-fault families

The reviewer chooses at least five and may add novel faults:

- duplicate-key or unknown-field ambiguity;
- forbidden-scope retrieval before final filtering;
- retired or poisoned source;
- unsupported causal claim with a plausible citation;
- sensitive value in input or audit;
- mutable release alias;
- open-ended tool argument;
- subject/object authorization confusion;
- approval replay or proposal mismatch;
- timeout after acceptance;
- audit deletion/reordering;
- kill path coupled to the assistant;
- unbounded queue or budget;
- cleanup ownership failure.

### Admission gates

The submission cannot pass if any of these is true:

- real sensitive data or external effect entered the required path;
- answer material leaked into the hidden evaluation;
- a protected object reached context without authorization;
- a material claim was promoted without support or abstention;
- a tool accepts arbitrary shell, URL or path;
- the generator owns policy, approval or incident command;
- a mutation can retry from ambiguity without reconciliation;
- cleanup can delete outside exact owned state;
- critical outcomes are hidden behind an aggregate score;
- proof claims exceed executed evidence.

### Scoring rubric: 100 points

| Area | Points | Full-credit evidence |
| --- | ---: | --- |
| task, user, harm and baseline | 8 | exact bounded operation, measurable benefit/harm and credible non-AI comparator |
| authority and trust boundaries | 10 | every state has one authority; untrusted inputs/output and independent controls are explicit |
| contracts and artifact closure | 10 | strict schemas, cross-links, immutable full release identity and drift response |
| retrieval and privacy | 12 | pre-context authorization, lifecycle/provenance, scope-bound cache, minimization and derived-surface handling |
| grounding and abstention | 10 | atomic claims, exact evidence, contradiction/insufficient states and safe abstention |
| tools, policy and approval | 14 | typed least capability, external complete mediation, exact digest approval and downstream enforcement |
| effect reconciliation | 8 | accepted/completed/validated separation, idempotency limits and ambiguous-state response |
| audit, kill and fallback | 8 | useful minimized reconstruction, tested integrity, independent stop and usable deterministic fallback |
| evaluation quality | 10 | separated cases, meaningful slices, critical gates, uncertainty and no answer leakage |
| operability and economics | 5 | SLI/SLO, observability, capacity, correlated failure and complete cost |
| incident response and communication | 5 | contains each hidden fault, protects evidence, names uncertainty and avoids unsafe claims |

Minimum guided-pass score is 80 with every admission gate satisfied. A score of 80 does not mean production ready.

### Oral defense prompts

The reviewer asks:

1. Which fact can the generator authoritatively own?
2. Show where forbidden content is stopped before context.
3. Change one proposal field; prove old approval fails.
4. Create an accepted-timeout branch; explain why retry is unsafe.
5. Disable generation and tools without calling the assistant.
6. Show one critical failure that an average score would hide.
7. Explain what the harness cannot prove.

An answer is strong when it points to executed evidence, names the authority and states limits. Memorized phrases without artifacts do not pass.

### Reviewer decision

The independent assessment record is `ASM-0261`. The reviewer owns hidden inputs and scores from observed artifacts and defense. A later delayed-recall session should repeat the architecture and incident reasoning without the manuscript.

Possible decisions:

- `not yet`: an admission gate failed or evidence is missing;
- `guided competent`: guided task passed but transfer remains weak;
- `bounded independent competence`: changed-domain implementation and defense passed;
- `review required for production`: always true before real data, model, provider or effect.

No rubric result guarantees employment, staff level or permanent mastery.

## References and review

These sources anchor risk, security, retrieval, evaluation, observability, incident operations, policy and supply-chain claims. They do not replace release-specific product documentation or organizational review.

### AI risk and secure-development foundations

1. **REF-1180 — NIST, [AI Risk Management Framework Core](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/).** Use the Govern, Map, Measure and Manage functions to place the assistant inside accountable organizational risk management rather than treating safety as a prompt setting.
2. **REF-1181 — NIST AI 600-1, [Artificial Intelligence Risk Management Framework: Generative Artificial Intelligence Profile](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf).** Use the profile when mapping generative-AI-specific risks, measurement, governance and residual-risk treatment.
3. **REF-1182 — NIST, [Secure Software Development Practices for Generative AI and Dual-Use Foundation Models](https://www.nist.gov/news-events/news/2024/07/secure-software-development-practices-generative-ai-and-dual-use-foundation).** Connect model and data artifacts to secure software lifecycle practices rather than operating an isolated AI pipeline.

### Threat models and control boundaries

4. **REF-1183 — OWASP, [LLM01:2025 Prompt Injection](https://genai.owasp.org/llmrisk/llm01-prompt-injection/).** Supports treating direct and indirect injection as an architectural risk requiring layered controls.
5. **REF-1184 — OWASP, [LLM05:2025 Improper Output Handling](https://genai.owasp.org/llmrisk/llm052025-improper-output-handling/).** Supports sink-specific validation and the rule that generated output remains untrusted input.
6. **REF-1185 — OWASP, [LLM06:2025 Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/).** Supports minimizing functionality, permissions and autonomy and requiring authorization for consequential actions.
7. **REF-1186 — Google, [Security Controls for Generative AI Systems](https://saif.google/secure-ai-framework/controls).** Provides a control-oriented frame across data, models, infrastructure, applications and operations.
8. **REF-1187 — MITRE, [ATLAS](https://atlas.mitre.org/).** Use as an evolving knowledge base for adversarial tactics and techniques when expanding threat models and red-team cases.

### Retrieval and evaluation

9. **REF-1188 — Lewis et al., [Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks](https://arxiv.org/abs/2005.11401).** Original RAG research grounds the retrieval-plus-generation concept; production authorization and injection controls are additional engineering requirements.
10. **REF-1189 — Liang et al., [Holistic Evaluation of Language Models](https://arxiv.org/abs/2211.09110).** Supports multi-dimensional, scenario-aware evaluation rather than one undifferentiated score.
11. **REF-1190 — Mitchell et al., [Model Cards for Model Reporting](https://arxiv.org/abs/1810.03993).** Supports documenting intended use, evaluation, limitations and relevant groups instead of presenting a model as context-free capability.

### Observability and incident operations

12. **REF-1191 — OpenTelemetry, [Generative AI Semantic Conventions](https://github.com/open-telemetry/semantic-conventions-genai).** Consult the current maturity and version before implementation; semantic conventions can change and must not justify sensitive content capture.
13. **REF-1192 — OpenTelemetry, [Logs Data Model](https://opentelemetry.io/docs/specs/otel/logs/data-model/).** Grounds structured log concepts and resource/scope relationships used for bounded audit and operational telemetry.
14. **REF-1193 — Google SRE, [Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/).** Supports user-oriented symptoms, actionable alerting and disciplined monitoring design.
15. **REF-1194 — Google SRE, [Managing Incidents](https://sre.google/sre-book/managing-incidents/).** Grounds clear roles, coordination and control during incidents; an assistant does not replace incident command.
16. **REF-1195 — NIST SP 800-61 Rev. 3, [Incident Response Recommendations and Considerations for Cybersecurity Risk Management](https://csrc.nist.gov/pubs/sp/800/61/r3/final).** Connects preparation, response and lessons learned to broader cybersecurity risk management.
17. **REF-1196 — AWS Well-Architected, [OPS07-BP03 Use runbooks to perform procedures](https://docs.aws.amazon.com/wellarchitected/latest/framework/ops_ready_to_support_use_runbooks.html).** Supports tested, maintained procedural guidance while this lesson adds version, authorization and untrusted-content boundaries.

### Policy and supply-chain integrity

18. **REF-1197 — Open Policy Agent, [Decision Logs](https://www.openpolicyagent.org/docs/management-decision-logs).** Grounds decision-log concepts; production use still requires privacy, masking, transport and retention design.
19. **REF-1198 — SLSA, [Provenance](https://slsa.dev/spec/v1.2/provenance).** Supports verifiable build provenance as one part of behavioral artifact closure.
20. **REF-1199 — Sigstore, [Verifying Signatures](https://docs.sigstore.dev/cosign/verifying/verify/).** Supports signature verification procedures; authenticity does not establish behavioral safety.

### Review cadence

This chapter was reviewed on 2026-08-07 and should be reviewed again by 2026-11-07, or earlier when any of these changes:

- active NIST, OWASP, OpenTelemetry, SLSA, Sigstore or provider guidance;
- model, tokenizer, serving or provider behavior;
- corpus/index architecture or authorization model;
- tool capability, policy or approval workflow;
- data classification, privacy obligation or retention;
- incident command or on-call ownership;
- evaluation population or critical-gate definition.

Review means more than checking that URLs open. Re-evaluate claims against current primary sources, run the complete harness, inspect dependency and artifact identities, review threat and privacy models, exercise kill/fallback and update representative hidden cases.

### Final lesson summary

The secured incident assistant is not a model wrapped in a chat page. It is a governed evidence-to-effect system.

The durable architecture is:

```text
identified incident
  -> minimized evidence
  -> authorized versioned retrieval
  -> untrusted candidate generation
  -> atomic claim verification and abstention
  -> typed bounded proposal
  -> external policy
  -> exact independent approval
  -> least-privileged effect
  -> outcome reconciliation
  -> postcondition and user validation
  -> privacy-aware audit
  -> independent kill and deterministic fallback
```

Remember the operational rule:

> Evidence before eloquence. Authority outside the model. Reconcile before retry. Validate the user, not the success message.

The local project gives you a reproducible place to inspect those boundaries. Its passing result is evidence about one deterministic implementation and sixteen declared cases. Production transfer requires a separately evaluated model adapter, representative protected cases, independent review, staged rollout, on-call ownership and continuing measurement.
