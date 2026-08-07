---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0084",
  "slug":"technical-writing-operational-documents",
  "aliases":["V00-L03","technical-writing-operational-documents"],
  "curriculumIds":["DOC-001"],
  "route":"/book/start/technical-writing-operational-documents",
  "order":3,
  "volume":"00-start-safely",
  "title":"Technical writing for operations: evidence, diagrams, runbooks, decisions, and incidents",
  "summary":"Turn production evidence into audience-fit diagrams, procedures, decisions, incident records and executive explanations that remain safe, testable, current and useful under pressure.",
  "domain":"foundations",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0007"],
  "prerequisiteCurriculumIds":["FND-001"],
  "testedEnvironments":[
    {"platform":"Official standards and documentation","version":"Google/Microsoft/GitHub engineering-writing guidance, RFC style/keywords/time, C4, Diátaxis, W3C WAI, AWS runbooks, Google SRE incident/postmortem, NIST incident response, Mermaid, OWASP logging and CommonMark reviewed 2026-08-07","support":"concept-only","notes":"Sources establish methods and vocabulary, not fitness, truth or organizational acceptance of a document."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 73 cases, five calculations, authority/root/unknown-artifact refusal and exact cleanup pass."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic fictional document-review model; no publishing, editor, incident, ticket, messaging, provider or runtime call."},
    {"platform":"Organizational documentation and incident systems","version":"not present in the tested boundary","support":"unsupported","notes":"No credential, private document, customer record, production command, publication, message, ticket, decision, incident change or external mutation is authorized."}
  ],
  "targetRoles":["site-reliability-engineer","devops-engineer","platform-engineer","cloud-engineer","infrastructure-engineer","production-engineer","technical-writer","solutions-architect","technical-lead","engineering-manager"],
  "learningObjectives":[
    "Define the reader, task, decision, urgency, scope, prerequisite, owner and success condition before selecting a document type.",
    "Distinguish observed, calculated, decided, declared, inferred and unknown claims and preserve attributable evidence, units, time and confidence.",
    "Separate tutorials, how-to guides, reference and explanation while linking them through one canonical fact set.",
    "Create architecture, request, state, trust, deployment and incident-flow diagrams with stable identities, labelled relationships and text alternatives.",
    "Write runbooks and diagnostic playbooks as prediction, action, evidence, branch, recovery and escalation contracts for an authorized exact target.",
    "Write append-only architecture decisions and decision memos with context, alternatives, trade-offs, consequences, confidence and supersession.",
    "Write live incident and change updates that separate user impact, facts, hypotheses, actions, unknowns, roles and next-update cadence.",
    "Write post-incident records with evidence-linked chronology, system mechanisms, contributing conditions, learning and effectiveness-checked actions.",
    "Translate one fact base for executive, finance, security, engineering, operations and support audiences without contradiction or unsafe disclosure.",
    "Operate documentation as versioned code with ownership, automated checks, rehearsal, usage evidence, review triggers, supersession and archive."
  ],
  "productionSignals":[
    "An operator cannot identify the exact target, permission, prediction, abort point or recovery in a runbook.",
    "A status update says everything is down, names a cause without evidence and omits the next update time.",
    "A diagram mixes business capabilities, processes, containers and hosts while its arrows have no meaning.",
    "A decision is changed in place so reviewers cannot reconstruct what evidence and constraints applied earlier.",
    "A post-incident document blames one person while retry, review, permission, monitoring and recovery conditions remain unexplained.",
    "Two wiki pages and one repository README provide different active procedures for the same event.",
    "An example contains a token, private endpoint, customer identifier, exploitable detail or destructive broad-target command.",
    "A document passes Markdown and link checks but an unfamiliar authorized operator cannot complete the task.",
    "An executive brief and operator update report different user impact, time or decision state.",
    "A critical runbook has no owner, observation date, review trigger, rehearsal receipt or superseding identity."
  ],
  "diagrams":[
    {"id":"LES-0084-DIA-001","title":"Evidence-to-decision documentation loop","direction":"cyclic","boundaries":["reader decision","canonical facts","purpose-fit artifact","review","rehearsal/use","outcome","revision"],"evidencePoints":["audience contract","claim ID","review receipt","execution receipt","task outcome","review trigger"],"textAlternative":"A reader decision selects canonical evidence and a purpose-fit artifact; review and rehearsal expose defects, observed use produces outcomes, and those outcomes trigger revision without rewriting prior evidence."},
    {"id":"LES-0084-DIA-002","title":"Claim provenance graph","direction":"left-to-right","boundaries":["source","observation or declaration","calculation or inference","decision","audience views"],"evidencePoints":["source version","window","unit","formula","confidence","decision owner","view link"],"textAlternative":"Versioned sources produce observations or declarations; calculations and inferences retain their inputs; accountable decisions consume those claims; several audience views link back without changing facts."},
    {"id":"LES-0084-DIA-003","title":"Documentation type compass","direction":"hierarchical","boundaries":["tutorial learning","how-to goal","reference lookup","explanation understanding"],"evidencePoints":["reader mode","task","prerequisite","completion signal"],"textAlternative":"Tutorials guide learning, how-to guides help a competent reader achieve a goal, reference supplies accurate lookup information, and explanation develops understanding; each serves a different reader mode."},
    {"id":"LES-0084-DIA-004","title":"Safe runbook step state machine","direction":"left-to-right","boundaries":["prerequisite","prediction","authorized action","observation","pass branch","abort/recover branch","escalation"],"evidencePoints":["target ID","authority","expected output","validation","stop condition","cleanup receipt"],"textAlternative":"An operator proves prerequisites and prediction before an authorized exact-target action, observes evidence, then follows either a validated pass path or a bounded abort, recovery and escalation path with cleanup proof."},
    {"id":"LES-0084-DIA-005","title":"Incident documentation flow","direction":"top-to-bottom","boundaries":["live state","stakeholder update","handoff","normalized timeline","post-incident analysis","verified action"],"evidencePoints":["user impact","fact/hypothesis label","next update","acknowledged role","source timestamp","effectiveness check"],"textAlternative":"Live evidence feeds controlled internal and stakeholder updates and explicit handoffs; preserved timestamps support later causal learning whose actions close only after effectiveness is verified."},
    {"id":"LES-0084-DIA-006","title":"Documentation lifecycle and truth ownership","direction":"left-to-right","boundaries":["draft","review","approved active","observed use","review due","superseded","archive"],"evidencePoints":["owner","version","approval","rehearsal","usage defect","trigger","replacement ID"],"textAlternative":"A draft becomes active only after accountable review; rehearsal and use generate evidence, time or change triggers review, and a new version supersedes rather than silently overwrites prior truth before controlled archive."}
  ],
  "commands":[
    {"id":"LES-0084-CMD-001","question":"Is this a guarded no-publish documentation-review shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0084 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"fictional fixtures calculations and authority guards pass","nextEvidence":"initialize copied fixtures"},{"when":"lab=fail","meaning":"a named safety or source guard failed","nextEvidence":"correct the boundary without bypass"}],"proves":"offline prerequisites and guard behavior","doesNotProve":"document truth usability or acceptance"},
    {"id":"LES-0084-CMD-002","question":"Can bounded fictional review state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0084 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture copy exists","nextEvidence":"inspect status"},{"when":"refusal","meaning":"authority ownership prior state or target is unsafe","nextEvidence":"preserve the first refusal"}],"proves":"planned local initialization","doesNotProve":"publication or incident-system setup","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0084-CMD-003","question":"Is the intended packet and case set loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"cases=73 and packet ID match","meaning":"reviewed fixture identity matches","nextEvidence":"map the documentation lifecycle"}],"proves":"local fixture identity","doesNotProve":"claim accuracy"},
    {"id":"LES-0084-CMD-004","question":"What evidence and ownership stages are modeled?","risk":"read-only","command":"bash lab.sh roadmap","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"roadmap=pass","meaning":"the fictional lifecycle is explicit","nextEvidence":"challenge each transfer and authority"}],"proves":"declared fictional workflow","doesNotProve":"organizational workflow fitness"},
    {"id":"LES-0084-CMD-005","question":"How many claims are attributable and unknown?","risk":"read-only","command":"bash lab.sh claims","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"claims=pass","meaning":"claim classes conserve and percentages close","nextEvidence":"review high-consequence unattributed claims"}],"proves":"fixture classification arithmetic","doesNotProve":"truth of any claim"},
    {"id":"LES-0084-CMD-006","question":"Do mixed-offset timestamps produce one unambiguous chronology?","risk":"read-only","command":"bash lab.sh timeline","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"timeline=pass","meaning":"RFC3339-shaped inputs normalize and order","nextEvidence":"preserve original clocks and validate source accuracy"}],"proves":"fixture timestamp parsing and durations","doesNotProve":"clock accuracy or causality"},
    {"id":"LES-0084-CMD-007","question":"Are verifiable steps checked and mutations protected?","risk":"read-only","command":"bash lab.sh runbook","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"safe_mutations=true","meaning":"declared mutation guards are complete","nextEvidence":"rehearse on an authorized disposable target"}],"proves":"fixture coverage arithmetic","doesNotProve":"human execution or production safety"},
    {"id":"LES-0084-CMD-008","question":"Are active artifacts current and archives excluded from active truth?","risk":"read-only","command":"bash lab.sh freshness","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"critical_expired=0","meaning":"the fixture has no expired critical active artifact","nextEvidence":"test real review triggers and navigation"}],"proves":"declared freshness classification","doesNotProve":"semantic currency"},
    {"id":"LES-0084-CMD-009","question":"Do five audience views preserve one canonical fact set?","risk":"read-only","command":"bash lab.sh audiences","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"coverage_pct=100 and conflicts=0","meaning":"fixture links and values agree","nextEvidence":"perform human audience and confidentiality review"}],"proves":"fixture projection consistency","doesNotProve":"readability or stakeholder acceptance"},
    {"id":"LES-0084-CMD-010","question":"Can an unattributed material claim support a decision?","risk":"read-only","command":"bash lab.sh evaluate material-claim-unsourced","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"boundary=evidence","meaning":"the decision cannot inherit unsupported certainty","nextEvidence":"source classify or preserve the unknown"}],"proves":"planned evidence boundary","doesNotProve":"claim priority"},
    {"id":"LES-0084-CMD-011","question":"Can a broad destructive command be repaired by clearer prose?","risk":"read-only","command":"bash lab.sh evaluate destructive-command-unbounded","runFrom":"LES-0084 support/lab after setup","expectedBranches":[{"when":"boundary=safety","meaning":"target authority abort and recovery are missing","nextEvidence":"redesign the operation rather than decorate it"}],"proves":"planned safety boundary","doesNotProve":"a replacement command is authorized"},
    {"id":"LES-0084-CMD-012","question":"Do all gates calculations refusals and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0084 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"73 cases five calculations refusals and cleanup pass","nextEvidence":"retain fictional-only limits"},{"when":"failure","meaning":"candidate evidence is rejected","nextEvidence":"preserve the first failed gate"}],"proves":"guarded offline lifecycle","doesNotProve":"document quality or learner mastery","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs":[
    {"id":"LES-0084-LAB-001","title":"Guided evidence-based operational document review","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; fictional local JSON only","timeMinutes":240,"privilege":"normal user; root and publishing/runtime authority refused","network":"none","changes":["one UID-scoped temporary root","copied fictional case and document packet fixtures"],"abortConditions":["root","cloud credential","publishing token","incident/runtime endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve the first failed assertion and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0084-technical-writing-operational-documents/support/lab"},
    {"id":"LES-0084-LAB-002","title":"Independent two-context document design and defense","mode":"independent","environment":"Reviewer-owned sanitized fictional document packets; no production or messaging connection","timeMinutes":240,"privilege":"local author/reviewer only; reviewer owns hidden changes scoring and cleanup","network":"none","changes":["local claim ledger","diagram","runbook","ADR","incident and post-incident records","audience views"],"abortConditions":["production credential or command","employer-confidential incident","customer data","private endpoint","unbounded destructive procedure","fabricated source or outcome"],"recovery":"Discard or sanitize reviewer-owned artifacts after scored evidence is retained.","cleanupProof":"Reviewer confirms no credential endpoint private incident customer record confidential artifact or answer key remains.","path":"drafts/LES-0084-technical-writing-operational-documents/support/lab"}
  ],
  "incidents":[
    {"id":"LES-0084-INC-001","signal":"A recovery runbook sends an unfamiliar operator to the wrong cluster because the target uses an ambiguous nickname.","firstThought":"The document lacks stable target identity and a pre-action readback.","safePath":"Stop mutation, preserve the attempted context, resolve canonical identity/authority, repair the runbook and rehearse on a disposable target.","trap":"Add bold text saying be careful."},
    {"id":"LES-0084-INC-002","signal":"External status names a database as root cause while responders have only correlated connection wait.","firstThought":"A hypothesis crossed an audience boundary as fact.","safePath":"Correct the record, state observed user impact and uncertainty, preserve evidence and control future views from canonical claim IDs.","trap":"Keep the claim to avoid looking uncertain."},
    {"id":"LES-0084-INC-003","signal":"A diagram says traffic is encrypted but omits the proxy termination and plaintext internal hop.","firstThought":"The trust boundary and edge semantics are hidden.","safePath":"Scope the view, label protocol/identity at each edge, show termination and add a meaning-equivalent text alternative.","trap":"Change every arrow to green."},
    {"id":"LES-0084-INC-004","signal":"An accepted ADR is edited after a migration fails, erasing the original assumptions.","firstThought":"History was rewritten instead of superseded.","safePath":"Restore the prior record from version control, create a linked superseding ADR, retain changed evidence and review affected decisions.","trap":"Leave only the corrected version because it is now accurate."},
    {"id":"LES-0084-INC-005","signal":"A post-incident action says retrain the engineer while broad production permission, missing guardrails and an untested recovery path remain.","firstThought":"Individual blame replaced system mechanism and effectiveness.","safePath":"Map causal and contributing conditions, redesign controls, assign measurable actions and verify recurrence risk with representative evidence.","trap":"Rename retraining as process improvement without changing the system."}
  ],
  "assessmentIds":["ASM-0235","ASM-0236","ASM-0237"],
  "referenceIds":["REF-1028","REF-1029","REF-1030","REF-1031","REF-1032","REF-1033","REF-1034","REF-1035","REF-1036","REF-1037","REF-1038","REF-1039","REF-1040","REF-1041","REF-1042","REF-1043","REF-1044","REF-1045"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "This substantive quarantined candidate covers the complete teaching path; representative organizational artifacts, scoped human review, learner transfer and publication acceptance remain unproved.",
    "All claims timestamps procedures incidents documents scores and audiences in the model are fictional.",
    "Writing frameworks and provider guidance are contextual methods rather than universal organizational policy.",
    "Automated structure and consistency checks cannot prove truth readability accessibility usability authority or acceptance.",
    "No private document editor incident channel message ticket production command publication or external mutation is tested.",
    "Formal technical security privacy legal communications accessibility and instructional review plus rehearsal reviewer-scored transfer and delayed recall remain required."
  ]
}
---

# Technical writing for operations: evidence, diagrams, runbooks, decisions, and incidents

## What you see and first thought

At 04:37 UTC the incident channel says: “Checkout is down because the database is overloaded. The team is working on it.”

This looks like an update, but it is a bundle of uncontrolled claims. “Checkout is down” gives no operation, region, percentage, source, or observation window. “Because” promotes a theory to a cause. “Overloaded” names no metric. “The team” names no accountable role. There is no mitigation, unknown, or next-update time.

When you see this, do not begin with grammar. Ask: **what decision can the reader safely make, and which evidence supports it?** If that is unclear, the document is not ready.

### Writing is a production control

Operational writing changes behavior. A runbook causes commands to be executed. A diagram changes a security review. An ADR constrains future designs. A status update changes customer and leadership decisions.

```text
evidence -> claim -> interpretation -> decision -> action -> system outcome
              \---------- ambiguity ----------/       |
                                         wrong target, delay, unsafe action
```

A document can fail months after it was written, in another time zone, when its author is asleep. Treat it like an interface: define inputs, preconditions, semantics, validation, ownership, change review, and retirement.

A safer incident update is: “From 04:32Z to 04:37Z, 31% of checkout submission requests in region R1 returned HTTP 503 according to gateway metric M-17. Browsing is unaffected. Responders are testing whether increased database connection wait contributes; cause is not established. Traffic is being shifted within the approved capacity plan. Incident commander: IC-1. Next update by 04:47Z.”

It is better because every sentence has a job: bounded impact, evidence, hypothesis, action, accountability, and cadence. Completion means the intended reader can use the artifact safely, material claims are traceable, sensitive information is controlled, success is observable, and the lifecycle is owned. Rendering successfully is not completion.

### Three readers can make three different mistakes

Imagine that the same checkout sentence reaches three people.

The on-call engineer may stop inspecting the gateway and jump directly to the database. The support lead may tell every customer that checkout is unavailable even though only one region and operation are affected. The executive may authorize expensive emergency capacity because “overloaded” sounds like a proven capacity shortage. Nothing in the sentence forces those interpretations, but nothing prevents them either.

That is the hidden cost of ambiguous prose: every reader fills missing state with a different mental model. Under pressure, people usually fill gaps with the most available story, not the most defensible one. Good operational writing narrows the range of unsafe interpretations without pretending uncertainty has disappeared.

Use a three-column review:

| Reader asks | Weak document leaves | Useful document supplies |
|---|---|---|
| What is happening? | an adjective such as slow or down | operation, population, region, window, measured effect |
| Why? | one confident story | facts, hypotheses, confidence, competing explanations |
| What should I do? | implied urgency | owned action, authority, decision gate, next update |

### Information has a half-life

A document may be correct when written and dangerous later. Runtime versions change. Ownership moves. A provider changes an interface. A certificate-renewal role loses permission. A dependency name remains while its meaning changes. This is why “documentation debt” is not merely missing prose. It is the accumulated difference between what an artifact says and what an authorized reader needs to act correctly now.

Freshness has at least four dimensions:

- **source freshness:** are the cited facts and contracts current?
- **procedure freshness:** do commands, permissions, targets, and branches still behave as described?
- **audience freshness:** does the intended reader still have the assumed knowledge and authority?
- **routing freshness:** does search, an alert, or a service catalog lead to this artifact as active truth?

Editing the date without proving those dimensions is freshness theater.

### The wisdom rule

When a document feels unclear, resist the urge to add paragraphs immediately. First expose the missing decision, evidence, ownership, or boundary. Prose is the final representation of those states. If the states do not exist, more confident language only hides the problem more effectively.

## Terms before commands

### Reader and outcome

A **reader** is the person using an artifact now. An **audience** is a class of readers sharing context, authority, and information needs. “Engineering” is vague; “primary on-call with production read access” is useful. A **task** is an observable goal. A **decision** chooses among alternatives.

An audience contract states prior knowledge, allowed information and actions, pressure, task or decision, required precision, completion signal, and escalation boundary.

### Claim classes

- **Observed:** recorded by a named source for a scope and time.
- **Calculated:** produced from stated inputs, units, exclusions, and formula.
- **Declared:** asserted by an authoritative owner or interface.
- **Decided:** an accountable choice with context and consequences.
- **Inferred:** an interpretation with confidence and competing explanations.
- **Unknown:** important information not yet established.

**Evidence** supports a claim. **Provenance** traces it to source, version, query, or procedure. An observed value can be true for one window and misleading for another. A correct calculation can use incomplete inputs. Preserve those limits.

### Boundaries and document types

**Scope** states what is covered; a **non-goal** states what is intentionally excluded. A **prerequisite** must be true before starting. A **success condition** proves completion. A **stop condition** prevents unsafe continuation. An **escalation condition** transfers authority explicitly.

A **tutorial** guides learning. A **how-to** helps a competent reader achieve a goal. A **reference** supports exact lookup. An **explanation** builds a mental model. Diátaxis distinguishes these reader modes [REF-1033]. One subject may need all four linked artifacts.

A **runbook** is a bounded procedure with prediction, action, evidence, branches, recovery, and escalation. A **diagnostic playbook** guides evidence-dependent investigation. A **design document** evaluates a proposal. An **ADR** preserves a decision, alternatives, and consequences. A **live incident record** holds response state; audience updates project that state. A **post-incident record** studies mechanisms and verified improvements after recovery.

### Canonical facts, lifecycle, and time

A **canonical fact set** is controlled reusable evidence. Audience **views** may change vocabulary and detail, never values or decision state. An owner is accountable for fitness and lifecycle; reviewers evaluate named concerns; approvers accept named decisions or risks.

Draft, reviewed, approved, active, review due, superseded, and archived are different states. Last modified is not last proven usable. Review triggers include interface, owner, permission, dependency, incident-use, and rehearsal changes.

RFC 8174 gives uppercase MUST, SHOULD, and MAY normative meaning only when a specification establishes that convention [REF-1030]. Prefer explicit operational language such as “Abort if the resolved target differs from the approved ID.” Use timestamps with explicit offsets as profiled by RFC 3339 [REF-1031]. Preserve originals, normalize a copy, and remember that normalization does not prove clock accuracy.

### Runbook versus playbook versus checklist

These terms are often mixed.

A **checklist** is a compact memory aid for a known process. It can confirm that a step occurred, but it rarely teaches diagnosis. A **runbook** describes a repeatable operation whose state transitions and validation are reasonably understood. A **playbook** coordinates a class of situations where evidence selects among several runbooks, investigations, or escalation paths.

For example:

- “Before deployment” checks may be a checklist.
- “Roll back release R from environment E” may be a runbook.
- “Respond to elevated checkout failures” is a playbook because DNS, dependency, code, capacity, and data failures require different evidence paths.

Calling every page a runbook hides whether the next action is deterministic. If the operator must choose, state the decision criteria and evidence. If the action is repeatable, state the exact transition and proof.

### Procedure concepts that prevent accidents

**Idempotence** means repeating an action has the same intended effect as performing it once, within stated boundaries. Do not assume a command is idempotent merely because it returns success twice.

**Blast radius** is the maximum affected scope if an action behaves as written or fails in a plausible way. It includes users, data, dependencies, cost, and recovery effort.

**Readback** requires the operator to compare a resolved target and intended change with approved scope before mutation. It protects against aliases, stale shell context, and copy-paste errors.

**Abort** stops before unacceptable change. **Rollback** returns to a prior known state. **Forward recovery** reaches a safe new state without reversing every change. **Cleanup** removes temporary artifacts. They are not interchangeable.

### Decision-document vocabulary

An **option** is a feasible alternative. A **constraint** removes options regardless of preference. A **criterion** differentiates feasible options. A **trade-off** accepts one disadvantage to obtain another advantage. A **consequence** is an expected result of the choice. A **risk** combines uncertain event, likelihood or exposure, and consequence. An **assumption** is treated as true for the decision but requires validation or monitoring.

A strong ADR does not say “Option B is scalable.” It states the workload and failure assumptions, evidence available, criteria and weights or vetoes, what B improves, what it worsens, who accepts residual risk, and what observation would trigger reconsideration.

### Incident-document vocabulary

**Impact** is the effect on users or business operations, not an internal alarm. **Detection** is when responders or systems recognized actionable evidence. **Mitigation** reduces impact before the underlying condition is fully resolved. **Recovery** restores the agreed user operation. **Resolution** may include stabilizing or eliminating the immediate mechanism. **Cause** requires stronger evidence than chronology. **Contributing condition** made the event more likely, harder to detect, broader, or slower to recover.

**Root cause** is often used as if a system has one deepest answer. In sociotechnical systems, a more useful question is: which mechanisms and conditions explain onset, propagation, detection, response, and recovery, and which changes reduce recurrence or consequence?

### Audience translation is not simplification alone

Translation changes selection, ordering, vocabulary, and permitted disclosure while preserving meaning.

An operator needs exact boundaries and commands. Security needs trust paths, identities, data classes, and abuse possibilities. Finance needs comparable cost units, uncertainty, and commitment timing. An executive needs user outcome, exposure, decision, alternatives, and confidence. Support needs approved customer language and workarounds.

Do not assume the executive version must be vague. It should be concise but decision-complete. Do not assume the engineering version may expose everything. It remains governed by least disclosure.

### Write sentences that preserve mechanism

Prefer a concrete subject and action:

- weak: “High latency was observed.”
- stronger: “Gateway metric M-17 reported p95 upstream latency of 1.8 seconds for checkout submission in R1 from 04:32Z to 04:37Z.”

The stronger sentence names observer, measurement, unit, operation, scope, and time. It still does not explain cause.

Avoid adjectives that hide thresholds: fast, large, healthy, resilient, significant, scalable, seamless. Replace them with a defined criterion or label the judgment. “Recovery met the 60-minute service objective” is testable. “Recovery was fast” depends on the reader.

Use active voice when accountability matters: “The incident commander approved the 5% canary” identifies the decision owner. Passive voice is useful when the actor is unknown or irrelevant, but do not use it to hide responsibility.

### Define jargon at first use

Jargon is efficient shared compression, not proof of expertise. Define a term where an unfamiliar target reader first needs it, then use it consistently. Do not alternate among cluster, environment, platform, and region as if they are synonyms. Maintain a controlled glossary for high-consequence identities and metrics.

When a product term is version-dependent, name the product and version boundary. When a concept is tool-neutral, teach the mechanism before product syntax. This allows the reader to transfer knowledge without pretending implementations are identical.

### Structure for scanning and deep reading

Operational readers scan before they read. Headings should carry information: “Abort when the target identity differs” is stronger than “Important note.” Put the decision, symptom, or question before background. Use tables for exact comparisons and branch matrices; use prose for mechanisms and trade-offs; use ordered lists only when order matters.

Keep warnings next to the risky action. A warning at the beginning of a long page is forgotten at the step that matters. State the consequence and safe alternative, not merely “warning.”

Code blocks must identify language or shell, working context, variables, expected branches, and whether execution mutates state. Long output should retain the decisive lines and explain omissions. Never fabricate successful output from an unrun command; mark illustrative output as fictional.

### Accessibility is part of technical accuracy

If meaning depends only on red versus green, position, animation, or an image, some readers receive a different system description. Use text labels, logical heading order, descriptive links, keyboard-reachable controls, sufficient contrast, and equivalent text for diagrams. Tables need clear headers and simple relationships.

Accessibility review can expose engineering ambiguity. Writing a text alternative forces the author to name what an arrow means. Keyboard testing exposes controls that are visually present but operationally unreachable.

### Edit in passes

First edit for truth: claim classes, provenance, scope, and uncertainty. Second edit for safety: literal actions, authority, disclosure, branches, and cleanup. Third edit for reader path: outcome, order, headings, and navigation. Fourth edit for language: remove repetition, undefined jargon, vague subjects, and unsupported adjectives. Last, compare rendered and source forms and run automated checks.

Editing only for grammar can make a false claim more persuasive. Truth and safety come first.

## Architecture map

### Evidence-to-decision loop

```text
[reader decision] -> [canonical evidence] -> [purpose-fit artifact]
       ^                                         |
       |                                         v
[revision trigger] <- [observed use] <- [review + rehearsal]
```

The reader decision selects evidence and artifact type. Scoped review checks correctness, safety, disclosure, accessibility, and teaching quality. Rehearsal exposes missing context. Use produces outcome evidence and revision triggers. Prior evidence remains intact.

### Claim provenance and views

```text
[source/version/window] -> [observation/declaration] --+
[inputs + formula] -----> [calculation] --------------+-> decision -> views
[evidence + alternatives] -> [inference] -------------+
```

Every arrow means “depends on.” A percentage links to numerator, denominator, exclusions, window, and formula. A decision links to claims available at that time. Audience views link back rather than retyping facts.

### Document compass and safe procedure

```text
reader is learning -> tutorial      reader is acting -> how-to
reader is looking up -> reference   reader is understanding -> explanation

prerequisite -> prediction -> authorized action -> observation
                                                   /          \
                                                pass      stop/recover/escalate
```

Do not interrupt an emergency procedure with a history lecture or disguise a production reference as a beginner tutorial. Every mutation needs a pass branch and a bounded failure branch.

### Incident and lifecycle flow

```text
telemetry -> live state -> operator/stakeholder/handoff views
                    |
                    v
        normalized evidence timeline
                    |
                    v
 mechanisms -> actions -> effectiveness checks

draft -> scoped review -> active -> rehearsal/use -> trigger
  ^                                                |
  +---------------- revision ----------------------+-> superseded -> archive
```

Use a context diagram for external relationships, service/container view for deployable responsibilities, sequence view for order, deployment view for placement, state view for lifecycle, and data-flow view for trust. C4 supplies useful architecture zoom levels [REF-1032]. Label nodes, edge meaning, environment, trust boundary, and observation date. Add an equivalent text explanation; W3C guidance helps decide appropriate alternatives [REF-1034].

### Worked architecture example: checkout submission

Start with a question: “Where can a checkout submission fail, and who owns evidence at each boundary?” That question prevents an attractive but useless inventory.

```text
[Customer browser]
    | HTTPS POST /checkout, request ID
    v
[Edge gateway] -- authenticated HTTPS --> [Checkout API]
    | gateway metrics/logs                    |
    |                                         +-- SQL/TLS --> [Order database]
    |                                         |
    +-- status response                       +-- event/TLS --> [Order queue]
                                                      |
                                                      v
                                               [Fulfilment worker]
```

Scope: production region R1, submission path only, observed 2026-08-07. Browsing, payment-provider internals, and disaster-recovery placement are out of scope.

Each edge now carries meaning. The browser-to-gateway edge owns client-visible status and request identity. The gateway-to-API edge owns routing and upstream timing. The database edge owns connection, transaction, and query evidence. The queue edge owns publish acknowledgement and backlog state. A generic arrow labelled “calls” would hide all of this.

The text alternative must convey the same route: checkout submissions enter the regional edge gateway over HTTPS, travel to the checkout API with a request identity, then synchronously use the order database and publish an order event to the queue consumed by fulfilment. The omitted systems and observation date remain explicit.

### Worked sequence view: hypothesis discrimination

```text
Browser       Gateway       Checkout API      Database       Queue
   | POST        |                |               |             |
   |------------>| route         |               |             |
   |             |-------------->| acquire conn  |             |
   |             |               |-------------->|             |
   |             |               |  wait/timeout |             |
   |             |               |<--------------|             |
   |             | 503 + req ID  |               |             |
   |<------------|<--------------|               |             |
```

This view shows where time was observed, not why the database wait increased. Plausible explanations include exhausted API connection pools, slow queries, lock contention, network loss, authentication delay, or a database resource constraint. The diagram prevents one observation from becoming a causal conclusion.

### Worked trust view

Mark identities and termination:

```text
Internet
  |
  | TLS; public server identity; untrusted client input
  v
[Gateway trust boundary]
  |
  | mTLS; workload identity; allowlisted route metadata
  v
[Application boundary]
  |
  | TLS; database identity; least-privilege service role
  v
[Data boundary: customer order data]
```

If TLS terminates at the gateway and internal traffic is plaintext, say so. A green arrow is not a security claim. Name authentication, authorization, encryption, data class, and termination separately.

### Diagram review card

For every diagram, answer:

1. What exact question does this view answer?
2. Who is the reader and which decision follows?
3. Which environment, version, and observation time apply?
4. Are node responsibilities at one useful abstraction?
5. Does every edge name direction and meaning?
6. Are trust, ownership, and failure boundaries visible?
7. Which relevant details are intentionally omitted?
8. Does the text alternative preserve the relationships?
9. Can canonical names be traced to procedures and evidence?
10. Who reviews the diagram when a dependency or interface changes?

If the picture cannot survive those questions, simplify and split it.

## Request or state path

An operational artifact travels through eighteen states:

1. **Trigger:** record the incident, change, audit, or repeated confusion that creates demand.
2. **Reader:** name authority, knowledge, pressure, disclosure, and accessibility needs.
3. **Outcome:** state the task or decision and observable success.
4. **Type:** choose tutorial, how-to, reference, explanation, procedure, decision, or incident record.
5. **Scope:** declare environment, version, assumptions, prerequisites, and non-goals.
6. **Sources:** inventory code, configuration, telemetry, standards, owners, and prior decisions with versions.
7. **Claims:** classify material statements, preserve unknowns, and attach provenance.
8. **Structure:** arrange the reader's path before polishing sentences.
9. **Examples:** use fictional or disposable targets; explain privilege, blast radius, branches, and cleanup.
10. **Diagrams:** choose one view, stable identities, labelled edges, trust boundaries, and text alternatives.
11. **Review:** map technical, operational, security, privacy, accessibility, communication, and teaching risks to reviewers.
12. **Automated rejection:** run schema, Markdown, link, secret-pattern, unsafe-command, terminology, and build checks.
13. **Rehearsal:** observe a representative authorized reader using a disposable environment without author rescue.
14. **Approval:** record reviewer scope, owner, version, activation, review trigger, and replacement policy.
15. **Discovery:** test symptom search terms, alert and catalog links, and current-route selection.
16. **Use:** capture completion, failed step, escalation, and staleness evidence without unsafe surveillance.
17. **Revision:** trigger review from time or change; supersede decisions and materially changed procedures rather than rewriting history.
18. **Archive:** remove stale work from active navigation, link replacements, and retain evidence under policy.

Skipping a gate transfers risk to the reader. Documentation-as-code makes sources reviewable [REF-1035, REF-1036], but repository storage alone does not establish truth, ownership, usability, or publishing authority.

### Worked path: from alert to active runbook

Suppose an incident review finds that responders spent eleven minutes locating the correct database-pool diagnostic.

The trigger is not “write database docs.” It is “reduce time to discriminate pool exhaustion from database-side wait for checkout API in region R1.” The primary reader is the checkout on-call engineer with read-only production telemetry and no database mutation authority. Success is reaching one of three evidence-backed branches within five rehearsal minutes.

The source inventory includes the API pool metric definition, database session view contract, gateway request metric, service ownership record, and approved escalation path. The claim ledger records what each signal can and cannot establish. The artifact type is a diagnostic playbook linked to exact metric reference and a separate explanation of connection pools.

The first branch checks whether pending pool acquisition increased while active connections reached the configured limit. The second checks whether database sessions exist but query wait increased. The third handles missing or contradictory telemetry. Every query is read-only, scoped, and sanitized. No branch says “increase pool size” because diagnosis does not grant change authority.

A representative on-call engineer rehearses the playbook against three fictional cases. The observer records the first ambiguous step, wrong query assumption, and time to branch. Technical and database reviewers validate signal semantics; security reviews query disclosure; accessibility review checks tables and diagrams; the service owner approves activation. The alert links to the new active identity, and the old wiki page is marked superseded.

The outcome is not “page published.” It is evidence that a representative operator reaches the correct boundary safely. A later metric rename triggers review automatically.

### Review evidence is typed

Record what each review proves:

| Review | Can establish | Cannot establish alone |
|---|---|---|
| technical | source semantics and mechanism accuracy | unfamiliar-reader usability |
| operational | executability, branches, recovery, escalation | confidentiality or legal fitness |
| security/privacy | disclosure, privilege, sensitive handling | service mechanism completeness |
| accessibility | equivalent access and interaction barriers | production authority |
| communications | audience clarity and approved wording | root cause |
| instructional | progression, examples, retrieval | production procedure acceptance |

“Reviewed by five people” is weak evidence if their scopes are unknown.

### Publication is a controlled state transition

Activation should be atomic from the reader's perspective. The new identity becomes active, route and search point to it, predecessor points forward, alert and catalog links are updated, and rollback to the prior publication state is available if the artifact itself is defective. Never leave two pages both labelled current during a gradual migration.

## Failure zoom

### Recognize the failure signature

**Ambiguous target:** “Restart the API cluster.” Stop mutation, resolve canonical environment and resource identity through a read-only interface, compare it to approved scope, and require readback. Bold “be careful” text does not repair identity.

**False certainty:** “The database caused it” when only connection wait is observed. State the observation and window, label the hypothesis, preserve alternatives, and define a discriminating test.

**Mixed diagram abstraction:** customer, function, cluster, and data center appear as peer boxes. Restate the question, choose one zoom level, move detail to linked views, and label every edge.

**Screenshot truth:** “Click the blue button shown below.” Write the stable control name, navigation path, expected state, and validation. A sanitized screenshot can supplement text, never replace semantics.

**Unsafe command dump:** commands lack working directory, placeholders, privilege, prediction, stop condition, and cleanup. Convert each to question, exact target, authority, command, output branches, proof boundary, and recovery.

**Stale polished runbook:** formatting passes while roles or interfaces changed. Mark review due, trace affected dependencies, rehearse, publish a reviewed version, and retire the old route.

**Rewritten ADR:** an old record is edited to match current reality. Restore history and create a linked superseding decision. Microsoft's ADR guidance emphasizes preserved decision history [REF-1039].

**Fact/hypothesis handoff:** repetition turns “possible cache issue” into accepted cause. Hand off under explicit headings: impact, facts, hypotheses, disproved paths, actions, decisions, unknowns, roles, and next check.

**Time confusion:** local times and UTC appear in narrative order. Preserve originals, add sources and offsets, normalize for display, flag clock uncertainty, and never infer causality from sequence alone.

**Disclosure leak:** an external update includes private hosts, customer IDs, token-shaped values, or exploitable defensive detail. Stop propagation, invoke security/privacy handling, rotate exposed secrets, and project future updates through approved fields. OWASP logging guidance informs sensitive-data handling [REF-1044].

**Blame-only postmortem:** “Operator error; retrain.” Describe human action neutrally, then inspect permissions, workload, interface, review, automation, containment, detection, and recovery. Blameless learning is central to Google SRE postmortem practice [REF-1041].

**Action without effectiveness:** “Add alert” closes when merged. Bind the action to a failure mechanism, owner, test, expected signal, noise constraint, and later effectiveness evidence.

### Failure 1 — an accurate document answers the wrong question

An engineer writes an excellent explanation of Linux memory while the on-call needs a five-minute path to distinguish application heap growth, page cache, and container limit pressure.

The prose is accurate but operationally unavailable. The fix is not deleting the explanation. Keep it as explanation, create a bounded diagnostic playbook, and link the mental model at the point where it helps interpret evidence.

### Failure 2 — placeholders become executable literals

A guide contains `kubectl delete pod <pod-name>`. One shell treats angle brackets as syntax; another reader replaces only part of the placeholder; a third runs against the current namespace.

Use a fictional safe example, define every variable, print resolved context, require an exact selector, prefer read-only preview, and state cleanup or recreation behavior. A placeholder convention is not a target guard.

### Failure 3 — success output is documented, partial failure is invisible

A backup guide says the command returns exit code zero. It does not explain that metadata upload can succeed while one data shard fails, or that a pipeline may hide an earlier failure.

Define success as postcondition invariants: expected object count and checksums, manifest completeness, restore readability, and retained failure logs. Exit status is evidence, not the entire outcome.

### Failure 4 — examples teach excessive privilege

A tutorial begins with `sudo -i` because permissions are inconvenient. Learners then reproduce root shells in diagnostics.

State the minimum required privilege per step. Separate observation from mutation. If elevated access is genuinely required, explain why, how authority is granted, which exact target is affected, and how it is relinquished. Never normalize permanent elevation.

### Failure 5 — active and historical incident truth are mixed

The live page is edited after recovery to contain a clean retrospective timeline. Readers can no longer reconstruct what responders believed when decisions were made.

Preserve event-time records and corrections. Build a normalized retrospective view that links to source events. Mark later knowledge as later knowledge. This supports both accountability and fair learning.

### Failure 6 — an executive summary hides the decision

The document contains architecture detail and says the project is “amber.” Leadership cannot tell whether approval, funding, risk acceptance, or escalation is requested.

Lead with the decision: what is requested, by when, consequence of delay, options, recommendation, confidence, and irreversible commitments. Put mechanism detail behind the evidence trail.

### Failure 7 — postmortem actions form a wish list

Twenty low-specificity tasks disperse ownership and never close the dominant mechanisms.

Rank mechanisms by contribution and controllability. Prefer a smaller set of actions with named owners, measurable tests, interaction analysis, and effectiveness dates. Record accepted residual risk rather than hiding it beneath backlog volume.

### Failure 8 — translation changes the number

Engineering reports 31% of submission requests failed in R1 for five minutes. The executive update says “one third of customers could not buy.”

Requests are not customers, R1 is not global, and a five-minute sample is not the whole incident. Translate consequences without changing population, unit, or scope. If customer-level impact is unknown, say so.

### A reusable failure investigation

When a document fails, preserve:

- the exact artifact version and active route;
- reader role, context, and authority;
- task and starting state;
- first divergence between prediction and observation;
- ambiguity, missing prerequisite, stale source, or unsafe branch;
- author assistance that was required;
- system outcome and containment;
- source and lifecycle triggers that failed;
- repair plus representative effectiveness evidence.

Do not reduce the record to “documentation unclear.” Find which state or transition was missing.

## Internals and state ownership

### Separate the state owners

The telemetry owner defines metric semantics. The service owner defines operational contracts. Security and privacy owners define disclosure boundaries. The incident commander controls live incident state. Communications roles control approved audience updates. An author assembles claims but cannot manufacture source authority.

A useful material-claim record contains identity, class, statement, source, version, window, scope, unit, formula, confidence, sensitivity, and review trigger. Version control records text changes; a content registry maps identity to route; lifecycle metadata identifies active truth; publication tooling controls visibility. A commit is not approval, a 200 response is not authority, and a recent edit is not rehearsal.

### Decisions, procedures, and incidents

An ADR needs one accountable owner, context, constraints, alternatives including no change, consequences, accepted risk, assumptions, confidence, measurements, and superseding identity. Preserve material dissent.

A runbook owner is accountable for fitness. A change or incident process grants execution authority; the document does not. The operator owns context readback and stop decisions within that authority.

Canonical live incident state should hold impact and window, facts with sources, hypotheses with confidence, decisions, actions and results, unknowns, acknowledged roles, next update, and sensitivity. Chat coordinates work but is a weak sole state store because messages are unordered, repeated, edited, and difficult to hand off.

Every improvement action names the mechanism it changes, accountable owner, due or review condition, verification, and effectiveness evidence. “Team” is not an owner; “implemented” is not effectiveness.

Time-based review is a fallback. Strong triggers include API/schema, ownership, permission, dependency, recovery-target, security classification, failed rehearsal, and incident-use changes. Critical procedures need periodic rehearsal plus change triggers. Archives preserve identity, dates, replacement links, and retention controls while remaining excluded from active search.

### The documentation control plane

Think of the documentation system as a small control plane:

```text
desired state: approved active identities, owners, review rules
observed state: repository, routes, source versions, rehearsal receipts
controller: validation + review workflow + publication workflow
reconciliation: reject drift, request review, activate, supersede, archive
```

The analogy has limits—human meaning cannot be reconciled mechanically—but it exposes useful invariants. One canonical identity should have one active route. Every active critical artifact should have an owner. Every mutating procedure should have an authority boundary. Every source dependency should have a review trigger.

### Canonical facts need write authority

If anyone can modify incident impact independently in several views, contradiction is inevitable. Define which role or system may update each field and which views are derived. Preserve corrections as events or versions so readers can distinguish “what was known then” from “what is known now.”

Do not centralize everything into one monolith. Centralize identities and material facts; allow audience-owned presentation within validation boundaries.

### Ownership during handoff

An owner label is not a handoff. A valid transfer includes:

- artifact and state identities;
- accepted responsibilities and exclusions;
- current facts, hypotheses, decisions, and unknowns;
- pending actions and deadlines;
- credentials or access transferred through approved mechanisms, never embedded;
- next review and escalation;
- acknowledgement by the receiving role.

During an incident, outgoing and incoming commanders should both acknowledge the transition and time. During service ownership transfer, rehearse critical procedures with the receiving team before removing the prior escalation path.

### State conflicts and resolution

Suppose the service catalog says owner A, the runbook says owner B, and the alert routes to team C. Do not choose the newest timestamp blindly. Identify the authoritative ownership system, freeze risky changes if escalation is unclear, involve accountable owners, correct derived systems, and add drift detection across the relationship.

Conflict is evidence that the control plane failed to reconcile. Fixing one page treats the symptom.

### Retention and deletion

Operational records can contain sensitive data and still have audit or learning value. Classify fields, minimize collection, define access, retain for a justified period, and delete under policy. A source-control repository may make historical removal difficult; do not commit secrets or customer records with the expectation that a later edit erases them. If exposure occurs, follow the organization's response and credential-rotation process.

## Evidence table

| Class | Minimum evidence | Frequent defect | Safe correction |
|---|---|---|---|
| Observed | source, method, window, scope, unit | generalized beyond the sample | narrow scope or gather evidence |
| Calculated | inputs, formula, units, exclusions | precision hides incomplete inputs | expose denominator and limits |
| Declared | authoritative owner/interface and version | remembered policy treated as current | link the controlled declaration |
| Decided | owner, context, alternatives, consequences | preference appears inevitable | preserve choice and trade-offs |
| Inferred | supporting/conflicting evidence and test | hypothesis becomes cause | label confidence and test it |
| Unknown | importance, owner, next evidence, deadline | omission creates false certainty | preserve and assign it |

Apply the most rigor to claims that change production action, security posture, customer communication, architecture, cost, or incident conclusions. Ask: what class, source, version, time, scope, unit, exclusions, transformation, uncertainty, sensitivity, and expiry apply?

### Five lab calculations

The fictional packet has 24 claims: 12 observed, 5 calculated, 4 decided, 2 declared, and 1 unknown. Twenty-one are attributable.

```text
attribution = 21 / 24 * 100 = 87.50%
unknown     =  1 / 24 * 100 =  4.17%
```

Its timestamps normalize to detection 04:30Z, impact 04:32Z, mitigation 04:41Z, and recovery 05:05Z. Impact is 33 minutes; detection-to-recovery is 35 minutes. Parsing does not prove clock accuracy or causality.

The runbook has 14 steps, 12 verifiable or validated, and 5 mutations with all declared guards:

```text
verifiable coverage = 12 / 14 * 100 = 85.71%
mutation protection =  5 /  5 * 100 = 100.00%
```

Ten artifacts classify as 7 current, 2 review due, and 1 superseded/expired, with zero expired critical active artifacts. Five views contain all 43 required canonical links and zero conflicting values. These calculations prove fixture consistency only—not truth, readability, safety, or acceptance.

### Worked claim ledger

Consider four claims from the checkout incident:

| ID | Statement | Class | Source and scope | Confidence | Decision use |
|---|---|---|---|---|---|
| CLM-01 | 31% of submission requests in R1 returned 503 from 04:32Z–04:37Z | observed/calculated | gateway query Q17; 620 failures / 2,000 requests | high for request sample | declare regional incident impact |
| CLM-02 | browser and catalog operations remained within SLO indicator threshold | observed | journey metrics J2/J3, same region/window | medium; synthetic coverage only | scope user communication |
| CLM-03 | database connection wait contributed to 503s | inferred | request traces correlate acquisition timeout with failures | medium | prioritize discriminating tests |
| CLM-04 | increasing pool size would recover service | unknown prediction | no bounded experiment yet | low | must not authorize change |

CLM-01 contains two transformations: raw counts are observed, while 31% is calculated. Keep both. CLM-02 must not become “all other services were healthy”; synthetics cover named journeys. CLM-03 says contributed, not caused, and needs trace sampling limitations. CLM-04 is explicitly unknown, preventing a proposed mitigation from masquerading as an established fact.

### Evidence hierarchy is contextual

There is no universal ladder where one source always wins. Runtime telemetry can contradict declared configuration because deployment drift exists. A code default can be overridden. A dashboard can aggregate away a region. A responder observation can reveal a failure the metric misses.

Resolve conflicts by asking:

1. What exact property is being established?
2. Which boundary could observe it?
3. What time, scope, and transformation apply?
4. Is the source authoritative for desired state, observed state, or interpretation?
5. Can two independent signals discriminate the conflict?

For a configured timeout, repository code may establish the intended default, deployment configuration the desired override, process inspection the loaded value, and traces the experienced behavior. Each owns a different claim.

### Evidence quality and evidence sufficiency

Quality asks whether evidence is trustworthy within its boundary. Sufficiency asks whether the available evidence supports the decision. One clean metric may be high quality but insufficient for a causal conclusion. Several noisy signals may be sufficient for a safe rollback because the decision threshold is intentionally conservative.

State the decision threshold before collecting convenient evidence. Otherwise the threshold moves to fit the preferred option.

### Citation that survives change

“See dashboard” is weak because dashboards change. Record stable source identity, query or panel identity, filters, window, unit, aggregation, and observation timestamp. Where policy permits, preserve a sanitized query or exported evidence digest. Do not paste confidential raw logs into a broadly accessible document.

For code or configuration, cite repository, immutable revision, path, and relevant symbol or range. For standards, cite stable title/version and distinguish requirement from guidance. For an owner declaration, record role, date, scope, and where the controlled decision lives.

### Evidence expiry

Claims expire differently:

- runtime observations expire with the incident window;
- interface contracts expire when versions change;
- organization policies expire on revision or replacement;
- benchmark results expire when workload, hardware, software, or method changes;
- decisions remain historical truth but their active status may be superseded;
- unknowns close only with evidence or an explicit decision to accept uncertainty.

Expiry does not mean deletion. It means the claim cannot support a new decision without review.

## Command decoders

Run from the LES-0084 support/lab directory in Ubuntu 24.04 as a normal user.

### Preflight and state

- `bash lab.sh doctor` checks tools, fixtures, calculations, and no-publish guards without state.
- `bash lab.sh setup` creates only the UID-scoped state root under `/tmp`, a sentinel, and two fictional fixture copies.
- `bash lab.sh status` proves expected packet identity; `roadmap` prints modeled ownership stages.

Root, external authority, symlink, wrong owner, prior unknown state, and unknown artifacts are refusals, not obstacles to bypass.

### Evidence commands

- `bash lab.sh claims` conserves claim counts and prints attribution and unknown percentages. Review consequence, not only coverage.
- `bash lab.sh timeline` normalizes offsets and calculates durations. Inspect original timestamps and clock assumptions.
- `bash lab.sh runbook` checks verifiable steps and mutation guards. It does not authorize or rehearse actions.
- `bash lab.sh freshness` classifies lifecycle state. It cannot detect semantic staleness by itself.
- `bash lab.sh audiences` checks canonical links and conflicting values. It cannot judge understanding or disclosure fitness.

### Boundary and lifecycle commands

`bash lab.sh evaluate material-claim-unsourced` returns an evidence boundary: elegant prose cannot create support. `bash lab.sh evaluate destructive-command-unbounded` returns a safety boundary: redesign target, authority, abort, recovery, and validation.

`bash verify.sh` starts from absent state, runs 73 cases, 72 gates, and five calculations, tests refusals, and proves cleanup. Expected final evidence is:

```text
verify=pass cases=73 calculations=5 refusal=true cleanup=true publish_calls=none runtime_calls=none
```

On failure, preserve the first assertion. Do not weaken expected results until the model, fixture, or assertion is understood.

### Decode one output like an operator

Suppose `bash lab.sh claims` prints:

```text
claims=pass total=24 observed=12 calculated=5 decided=4 declared=2 unknown=1
attributable=21 attribution_pct=87.50 unknown_pct=4.17 conserved=true
```

Read it field by field.

`claims=pass` means the command's assertions passed. It is not a quality grade. `total=24` is the denominator. The six class counts add to 24; `conserved=true` checks that invariant. `attributable=21` counts claims satisfying the fixture's provenance rule. The percentages follow deterministic formulas and rounding.

Now ask what is absent: which three claims are unattributed, whether they are material, whether sources are accurate, whether classification is contested, and whether the packet contains all claims needed for a decision. This habit—decode, verify conservation, then name non-proof—is the difference between reading output and trusting a green word.

### Command-card pattern for real documentation

Every meaningful command card should answer:

| Field | Question |
|---|---|
| purpose | what uncertainty or state transition is this command for? |
| risk | read-only, locally mutating, remotely mutating, destructive, costly? |
| context | exact host, cluster, account, namespace, directory, identity? |
| prerequisites | tools, access, backup, maintenance window, dependency health? |
| prediction | what should happen before running it? |
| command | exact syntax with defined variables and quoting |
| branches | what do success, empty, partial, timeout, and denial mean? |
| proof | what claim can output establish? |
| non-proof | what tempting conclusion remains unsupported? |
| abort/recovery | when to stop and how to contain or restore? |
| cleanup | which exact artifacts must be absent or retained? |

Do not turn every harmless command into a page of ceremony. Scale the card to consequence and ambiguity. A `pwd` observation needs context but not a rollback. A database failover needs full authority and recovery design.

### Shell details that prose must not hide

Explain quoting and expansion where they change meaning. An unset variable can turn a narrow path into a broad target. A pipeline may return the last command's status unless the shell is configured appropriately. Globs expand before the command. Current directory and environment variables change resolution. Aliases and kubeconfig contexts can change targets.

Prefer commands that display resolved identity before mutation. Use literal paths and exact IDs. Avoid teaching readers to copy command substitution from untrusted output. Where possible, provide a dry-run or plan, but state that a plan can become stale before execution.

### Expected output is a branch, not decoration

Document at least:

- expected non-empty output;
- expected empty result and whether it is healthy, inconclusive, or failure;
- permission or authentication denial;
- target not found;
- timeout or partial response;
- inconsistent evidence;
- tool/version mismatch.

For each branch, name the next evidence. “Contact support” is acceptable only when the escalation destination, evidence package, urgency, and safe state are explicit.

### Cleanup is a proof obligation

Cleanup should inventory exact artifacts, remove only owned allowlisted targets, and prove absence. If evidence must be retained, move it to a controlled location and record its identity rather than deleting everything.

The lab's sentinel protects against deleting an unrelated `/tmp` directory. Production procedures need stronger ownership controls: immutable change identity, labels or tags, resource ownership, namespace/account scoping, and independent readback.

## Decision path

When someone says “we need documentation,” walk this path:

1. **Outcome:** what observable task or decision changes?
2. **Reader:** what do they know, see, control, and need under what pressure?
3. **Type:** which primary artifact matches their mode, and which linked artifacts support it?
4. **Evidence:** which material claims can change the outcome, and what supports or limits them?
5. **Disclosure:** what may this audience see and do?
6. **Literal safety:** what happens under wrong context, empty input, timeout, partial failure, repetition, and cleanup failure?
7. **Review:** which technical, operational, security, privacy, accessibility, communication, and teaching concerns need named reviewers?
8. **Rehearsal:** can a representative authorized reader succeed in a disposable environment without author rescue?
9. **Activation:** who can publish, which route becomes authoritative, and how is rollback or supersession handled?
10. **Lifecycle:** which outcome evidence and change triggers cause review, revision, or archive?

Do not solve a missing source with clearer wording, an unsafe command with a warning box, an audience conflict with one huge page, or an authority problem with a runbook. Escalate to the owner of the missing state.

### Worked decision: choose the artifact set

Situation: a new service repeatedly pages on high request latency. Engineers ask for “one troubleshooting document.”

Reader analysis reveals four modes:

- a new engineer needs to learn latency decomposition;
- on-call needs a fast diagnostic path;
- automation needs exact metric and label definitions;
- reviewers need to understand why alert thresholds and escalation were selected.

The correct design is not one giant page. Create:

1. a tutorial using a fictional request trace;
2. a diagnostic playbook beginning with user journey and latency budget;
3. reference for indicators, units, labels, queries, and known limitations;
4. explanation of queueing, dependency latency, saturation, and tail behavior;
5. an ADR for alert and escalation decisions.

Link them by stable service, signal, and decision identities. The alert points to the diagnostic playbook, not the tutorial. The playbook links to reference at each query and explanation only when mechanism interpretation is needed.

### Worked runbook fragment

Weak instruction:

> Restart the checkout service if latency is high.

Operational fragment:

**Question:** Is release R producing elevated application latency in region R1 while dependencies remain within their established indicators?

**Authority:** incident commander approval under change C; operator has deployment read and bounded rollback permission for service identity S in R1 only.

**Preconditions:** current incident identity, target readback, prior version available, database migration compatibility confirmed, queue consumer compatibility confirmed, regional spare capacity above approved floor.

**Prediction:** if the release is causal and rollback is compatible, shifting a 5% canary to prior version should reduce the application span latency distribution without increasing errors or dependency load.

**Observe first:** current deployment identity, request rate, error rate, p50/p95/p99 latency, dependency spans, saturation, and canary allocation for the same window.

**Action:** execute the organization's reviewed canary rollback procedure for the exact immutable release and target. This public lesson intentionally does not invent a production command.

**Pass:** canary request identity proves prior version, error and tail latency improve for the agreed window, and guardrail indicators remain within bounds.

**Abort:** target mismatch, migration incompatibility, insufficient capacity, missing telemetry, or guardrail breach.

**Recovery/escalation:** return traffic to last safe allocation if authorized and safe; otherwise stop further change, preserve evidence, and escalate to the named release and database owners.

This fragment is useful even without a command because it exposes the missing organizational procedure and authority. Fabricating syntax would be less useful.

### Worked ADR

```text
ADR-042: Retain a bounded checkout rollback lane
Status: accepted
Date: 2026-08-07
Owner: checkout service owner

Context:
Deployments can change request behavior faster than full regional diagnosis.
Schema changes are not always backward compatible. Rollback capacity is finite.

Decision:
Maintain the previous application version for a bounded compatibility window.
Require additive/compatible data changes during that window. Permit 5% canary
rollback only after exact target, capacity, telemetry, and compatibility gates.

Alternatives:
A. always roll forward;
B. retain two complete environments;
C. keep bounded prior-version capacity and compatibility (selected);
D. no explicit recovery lane.

Consequences:
Faster causal discrimination and bounded recovery; additional capacity,
release complexity, compatibility discipline, and rehearsal cost.

Reconsider when:
rollback success rate, compatibility cost, or alternative recovery evidence
crosses the agreed threshold.
```

The ADR records why the lane exists. The runbook controls how an authorized operation uses it. The design document explains system-wide implications. Do not collapse them.

### Worked incident update variants

**Operator view:** includes exact metric IDs, active hypotheses, last commands or queries, guardrails, roles, and next branch.

**Support view:** “Some checkout submissions in region R1 failed between 04:32Z and 05:05Z. Browsing remained available. Service has recovered; retry guidance is approved for affected customers. Do not attribute a database cause.”

**Executive view:** “A 33-minute regional checkout submission incident affected a measured subset of requests. Recovery completed at 05:05Z. The immediate decision is whether to continue today's release schedule; responders are validating recurrence risk and will provide evidence by 07:00Z. Cause remains under investigation.”

All variants preserve the same time, scope, and uncertainty. Detail differs because decisions differ.

## Guided Ubuntu lab

### Setup and safety

Open Ubuntu 24.04 as a normal user, enter the LES-0084 support/lab directory, and run `bash lab.sh doctor`. Do not use `sudo`. The lab is local and fictional; exported cloud credentials, publication tokens, incident/runtime endpoints, root, symlinks, and unknown state are refused.

Run `bash lab.sh setup`, then `bash lab.sh status`. Confirm the packet ID, 73 cases, sentinel, exact UID-scoped path, and no network or publishing calls. If identity differs, stop and preserve the first error.

Before running setup, write this prediction:

```text
Only /tmp/reliability-atlas-les0084-docs-<my numeric UID> will be created.
It will contain the sentinel and two fixture copies.
No network, publication, incident, ticket, cloud, or runtime call will occur.
Root and unsafe inherited authority will be refused.
```

Then prove your current user and directory with read-only shell observations. Do not paste employer credentials or export them for the lab. If the doctor reports an inherited authority variable, use a clean local training shell rather than weakening the guard.

### Build the mental model

Run `bash lab.sh roadmap`. For each printed transition, name the state owner, evidence entering it, reviewer authority, and failure if the transfer is wrong. Then run `claims` and independently add the six class counts, calculate 21 divided by 24, and identify why one unknown is preferable to invented certainty.

Create a lab notebook table:

| Command | Prediction | Exact observation | Interpretation | Does not prove |
|---|---|---|---|---|
| doctor | all offline guards pass | copy output | environment is eligible | prose quality |
| setup | one owned root exists | inventory | bounded state initialized | publication |
| claims | counts conserve | output and arithmetic | fixture classification consistent | source truth |
| timeline | four times normalize | originals and UTC | chronology arithmetic | causality |
| runbook | five mutations protected | fields | fixture structural coverage | safe execution |
| freshness | no critical active expiry | classes | fixture lifecycle invariant | semantic currency |
| audiences | 43 links, no conflict | view IDs | projection consistency | comprehension |

Do not write “as expected” without copying the material fields. Comparison is the learning action.

Run `timeline`. Write original timestamps beside normalized UTC values. Recalculate the 33-minute impact and 35-minute detection-to-recovery intervals. Explain why neither duration proves cause.

Run `runbook`. Find the two steps not counted as independently verifiable. For every mutation, locate target, authority, prediction, abort, recovery, and validation. Explain why structural completeness still requires human rehearsal.

Now perform an adversarial paper review. For each fictional mutation, change one hidden assumption:

- the operator is in the wrong environment;
- the target alias resolves differently;
- output is empty;
- permission is read-only;
- action succeeds partially;
- the second execution repeats after a timeout;
- cleanup finds an unknown file.

You do not execute altered commands. State which guard catches the condition, which condition is currently unguarded, and what evidence the operator must preserve. This turns checklist reading into transfer reasoning.

Run `freshness` and `audiences`. Distinguish active truth from archive, then trace one impact fact into each view. A view may omit detail for purpose or sensitivity; it may not alter the canonical value.

### Challenge and cleanup

Run both `evaluate` commands. Say the boundary before reading the output. Finally run `bash verify.sh` from clean state. The final line must report 73 cases, five calculations, refusal and cleanup. Run `bash lab.sh cleanup` if you performed setup separately, then prove the exact state path is absent. Your lab note must contain predictions, observed output, interpretations, non-proof boundaries, and one question the model cannot answer.

### Expected complete transcript

```text
model=valid cases=73 gates=72 calculations=5
doctor=pass network=none user=1000 publish_calls=none runtime_calls=none
model=valid cases=73 gates=72 calculations=5
setup=pass state=/tmp/reliability-atlas-les0084-docs-1000
inject=pass artifact=unknown
clear=pass artifact=unknown
cleanup=pass absent=true
verify=pass cases=73 calculations=5 refusal=true cleanup=true publish_calls=none runtime_calls=none
```

Your numeric UID may differ. The verifier deliberately injects an unknown artifact to prove cleanup refusal, then removes that test artifact through an exact controlled path and proves final absence. It never treats a broad delete as acceptable cleanup.

### Troubleshooting the lab

**Root refused:** leave the root shell. Do not change the lab.

**Python missing:** install or enable Python 3 through your local Ubuntu package-management policy, then rerun doctor. Do not download an unverified binary through the lesson.

**Unknown prior state:** inspect the exact path without following links. If it belongs to an earlier successful lab and has the expected sentinel/owner, use the lab's cleanup command. Otherwise move the investigation outside the lab and do not delete it.

**Fixture digest or identity mismatch:** restore the repository file from the committed learning repository after checking Git status. Do not modify the assertion to fit unknown content.

**Verification failure:** retain the first error and the state inventory. Later failures may be consequences. Repair one assumption, return to absent state, and rerun.

### Guided deliverable

Submit a one-page evidence review containing:

1. the audience and decision for each lab report;
2. the five formulas with units and denominators;
3. one claim the model proves and one it cannot prove;
4. one unsafe command defect and structural repair;
5. one audience translation that preserves canonical facts;
6. exact cleanup evidence.

This deliverable can be reviewed; repository output alone is mentor-operated project evidence, not learner competency.

## Production transfer

Use the local method in production only through explicit authority boundaries.

1. Create a sanitized source inventory; never copy employer-confidential incidents, credentials, customer data, or private endpoints into this repository.
2. Define canonical names and claim identities in the organization's controlled system.
3. Draft locally or in the approved authoring system with no publication credential present.
4. Run structural and security checks; treat success as rejection evidence only.
5. Request scoped technical, operational, security/privacy, accessibility, and communications review.
6. Rehearse procedures on an authorized disposable target with a representative operator and observer.
7. Publish through the organization's approval workflow. Publication and production execution remain separate permissions.
8. Link alerts, catalogs, and search to one active route; mark predecessors superseded.
9. Capture usage defects and effectiveness without collecting unnecessary sensitive data.

### Production document packet

For a significant operational service, maintain a linked packet rather than a single encyclopedia:

- service context and ownership;
- user journeys and reliability commitments;
- architecture, trust, deployment, and dependency views;
- exact signal reference;
- diagnostic playbooks;
- authorized runbooks with recovery;
- decision records;
- change/release strategy;
- incident communication templates;
- post-incident records and action evidence;
- continuity, backup, restore, and disaster-recovery procedures;
- lifecycle index showing active and superseded identities.

Each artifact owns one reader problem. The index supplies navigation and shared identities. Avoid copying contracts into every page; link to controlled reference and state version assumptions.

### Technical design review packet

A design document should make review possible, not merely describe the chosen diagram. Include:

1. problem and measurable outcomes;
2. users, operators, and threat actors;
3. current state and constraints;
4. requirements and explicit non-goals;
5. workload and data assumptions with confidence;
6. proposed architecture and state/request flows;
7. identity, trust, and sensitive-data design;
8. failure modes, degraded modes, recovery, and observability;
9. capacity, performance, and cost ranges;
10. alternatives and decision criteria;
11. migration, compatibility, rollback, and decommission;
12. test and acceptance evidence;
13. ownership, open questions, risks, and decisions requested.

Review comments should attach to claims or decisions. Resolve them with evidence or explicit risk acceptance, not by deleting dissent.

### Post-incident record packet

Start with user impact, duration, scope, detection, mitigation, and recovery. Preserve a source-linked chronology. Explain onset, propagation, detection gaps, response constraints, and recovery mechanisms. Distinguish trigger from enabling and contributing conditions. Record what worked as well as what failed.

For every action, state:

```text
mechanism:
owner:
priority rationale:
expected risk change:
verification:
effectiveness date and evidence:
interaction or new risk:
status:
```

Google SRE incident guidance emphasizes clear roles and coordinated response [REF-1040]. Local organizations define severity, legal, privacy, security, and external-communication processes.

### Worked post-incident extract

**Incident:** INC-204, checkout submission failures in region R1.

**Impact:** From 04:32Z to 05:05Z, gateway query Q17 recorded 620 HTTP 503 responses among 2,000 checkout submission requests in R1. This is 31% of requests in that operation and measured window. Request count is not unique-customer count; customer-level impact remains unknown. Browsing and catalog synthetic journeys stayed within their defined indicators.

**Detection:** The gateway alert opened at 04:30Z, two minutes before the impact window used by Q17. That does not prove user impact began after detection; the metrics have different windows.

**Mitigation and recovery:** Responders began an approved 5% traffic shift at 04:41Z after target and capacity readback. Error rate declined in the shifted cohort. Full measured recovery occurred at 05:05Z. The shift is evidence of mitigation correlation; deeper trace and dependency evidence is required to explain mechanism.

**What happened technically:** A release increased concurrent database acquisition from the checkout API. The configured application pool limit was reached during a demand increase. Requests waiting longer than the API acquisition timeout returned 503. Database CPU remained below its operational threshold, but a subset of queries experienced lock wait, extending connection hold time. The release change and lock wait interacted: neither alone explains the measured failure rate under the reviewed evidence.

**Why impact propagated:** Admission control limited total request rate but did not reserve checkout capacity by operation. Retries from one client version amplified submission concurrency. The retry policy lacked jitter and used a timeout longer than the server's remaining request budget. The API returned a generic 503, causing support and responders initially to group several mechanisms together.

**Why detection and diagnosis took time:** The alert identified gateway failure but linked to an obsolete wiki page. The active pool metric had been renamed without a documentation dependency trigger. The primary dashboard showed averages that hid the affected cohort. Responders used traces to recover the request-to-pool relationship.

**What worked:** Request identities crossed gateway and API boundaries; the release lane retained a compatible prior version; regional spare capacity supported a bounded traffic shift; incident roles and update cadence were acknowledged.

**Recovery constraints:** A full application rollback was not immediately authorized because a data change required compatibility confirmation. Increasing the pool was rejected as an untested mitigation because it could transfer saturation to the database.

This wording avoids a single-person or single-component root cause. It explains interaction, amplification, detection, and recovery.

### Worked actions with effectiveness

**ACT-1 — operation-aware admission control**

- mechanism: prevent retry-amplified submission traffic from consuming the entire API concurrency budget;
- owner: checkout runtime owner;
- change: reserve and cap concurrency by operation with a safe default for unknown operations;
- verification: load test at baseline, burst, and dependency-slowdown conditions; prove browsing and submission guardrails;
- effectiveness: replay a representative incident workload and show bounded queue, no starvation, and acceptable rejection semantics;
- new risk: misclassified operation can receive the wrong budget, so classification telemetry and fallback are required.

**ACT-2 — documentation dependency trigger**

- mechanism: metric rename left the active diagnostic playbook stale;
- owner: observability platform owner with checkout content owner;
- change: bind metric identity changes to affected-content review and block removal while a critical active reference depends on it;
- verification: rename a fictional metric and prove review opens, active route warns, and replacement closes the dependency;
- effectiveness: next two controlled changes complete without orphaned critical references.

**ACT-3 — retry contract**

- mechanism: client retry timing amplified concurrency and exceeded the server request budget;
- owner: API contract owner;
- change: define bounded attempts, exponential delay with jitter, retryable outcomes, idempotency requirement, and end-to-end deadline;
- verification: cross-version contract tests and workload simulation;
- effectiveness: representative failure produces bounded amplification and no duplicate order.

“Update the runbook” may accompany these actions, but it does not replace system changes.

### What the post-incident extract still cannot claim

The numbers are fictional teaching evidence. Even in a real record, the extract would require source links, query review, trace sampling limits, clock assessment, responder review, security/privacy review, action priority decisions, and organizational approval. A coherent narrative is not automatically a proven narrative.

### Executive decision memo

Use this order:

1. decision requested and deadline;
2. consequence of deciding or delaying;
3. measured current state and uncertainty;
4. feasible options and veto constraints;
5. recommendation and why;
6. cost, reliability, security, delivery, and reversibility trade-offs;
7. milestones and evidence gates;
8. accountable owner and next review.

Executives do not need less truth. They need the decision-relevant truth without operational noise.

### Run a productive document review

Do not invite a large group to “review the document” with no question. Send the reader contract, artifact state, material claims, open decisions, and review scopes beforehand. Ask reviewers to label comments as correctness, safety, disclosure, usability, accessibility, decision, or editorial. This separates blocking evidence gaps from preferences.

Begin the meeting with the decision and highest-consequence uncertainty. Walk the request, state, or failure path—not every sentence. For a runbook, rehearse the risky branches. For a design, compare alternatives against the same criteria. For an incident record, inspect source-linked chronology and causal language. For an executive memo, ask whether the requested decision and consequence of delay are unmistakable.

Resolve each material comment as one of:

- accepted change with owner;
- evidence request with source and deadline;
- decision for the accountable owner;
- risk accepted by an authorized role;
- out of scope with linked follow-up;
- rejected with recorded reasoning.

Do not mark a thread resolved merely because prose changed. The underlying claim, decision, or safety boundary must be resolved. Preserve material dissent where future readers need it.

After review, produce a receipt listing artifact version, reviewer, scope, material findings, decisions, unresolved risks, and activation condition. A receipt prevents “security reviewed it” from being interpreted as approval of performance, operations, or all future versions.

### Review the review system

Periodically sample approved documents and ask whether reviewer scopes matched later defects. If incidents repeatedly expose unusable procedures, add representative operational rehearsal rather than another editorial approver. If sensitive details leak, improve classification and projection controls. If reviews wait too long, simplify low-risk paths while protecting high-consequence gates.

A mature process changes when evidence shows the review mechanism is ineffective. More reviewers are not automatically more safety; clear decision rights and the right evidence matter more.

For a live incident, do not experiment with an unapproved template mid-response. Use the accepted incident system, roles, disclosure rules, and cadence. After stabilization, export only authorized evidence for analysis. NIST SP 800-61r3 frames incident response as part of broader cybersecurity risk management [REF-1042]; local policy determines exact authority.

## Reliability, security, observability, capacity, and cost

### Reliability

Define documentation service levels where consequence warrants them: active route availability, critical-runbook rehearsal age, owner coverage, stale dependency detection, and representative task success. Do not use page count as reliability. Design graceful failure: if a runbook dependency is unavailable, state the safe stop and escalation path.

Treat a critical procedure as a dependency of the service. Useful indicators include:

- percentage of critical procedures with an accountable current owner;
- percentage rehearsed within the risk-based window;
- representative task completion without author assistance;
- median and tail time to first discriminating evidence;
- incidents where the active procedure caused delay, wrong action, or escalation;
- time from source/interface change to affected-document review;
- percentage of alert/catalog links resolving to one active identity.

Choose objectives from consequence. A quarterly batch job may tolerate slower documentation repair than emergency credential revocation. Avoid a target that rewards meaningless edits. “95% modified this quarter” can be gamed without improving one outcome.

Design a safe degraded mode. If the dashboard link is down, name an approved alternative query or escalation. If both primary and secondary evidence are unavailable, the procedure may require stopping mutation. Graceful degradation is not inventing confidence; it is retaining a safe path under missing dependencies.

### Security

Apply least disclosure and least privilege. Secret-scan examples, but also review private hostnames, customer identifiers, internal defenses, log injection, and commands with broad selectors. A redacted example must remain technically honest. Documentation never grants execution authority.

Threat-model the document itself:

- Can a malicious contributor insert a dangerous command?
- Can rendered Markdown execute unsafe content?
- Can a public search index expose an internal page?
- Can copied logs contain credentials, session IDs, personal data, or terminal control characters?
- Can a stale procedure direct readers around a new security control?
- Can approval be forged or bypassed?
- Can an attacker learn defensive gaps from an external incident update?

Use protected reviews, trusted rendering, inert links where appropriate, content security controls, secret and unsafe-pattern scanning, least-privilege publication, access logging under policy, and incident-specific disclosure review. Automated scanners miss contextual secrets and technically valid but unsafe commands.

Examples should use unmistakably fictional domains and identities. Never use a real token with a few characters replaced; structure can still reveal sensitive information and readers may mistake it for a credential pattern to copy.

### Observability

Observe outcomes: search success, task completion, branch failures, escalation, stale-link hits, rehearsal defects, and action effectiveness. Protect readers and incident data. A dashboard should answer which critical artifact is unsafe or due, not merely how many pages exist.

Correlate content identity and version with use outcomes when policy allows. If an incident used runbook version 7, later edits to version 8 must not erase which instructions responders saw. Record a minimal execution receipt: artifact identity/version, reader role, context class, branch reached, completion or escalation, defect category, and timestamp. Avoid recording command output that may contain secrets.

Alert on actionable documentation conditions: a critical owner disappears, an active route has two competing identities, a dependency version changes, or rehearsal expires. Do not page an on-call engineer because a low-risk tutorial link is old.

### Capacity and performance

Reviewers and operators are finite capacity. Large undifferentiated documents create queueing and cognitive load. Keep emergency paths short, move explanation to linked pages, precompute safe queries, and distribute ownership. Test retrieval time and time-to-first-useful-evidence under realistic pressure.

Review capacity is a queue. If every punctuation change requires six reviewers, urgent safety corrections wait. Define risk tiers and reviewer scopes. Automate formatting and invariant checks. Batch low-risk editorial work, but fast-track security and procedure defects with appropriate authority.

Reader performance matters too. Put the question and first boundary near the top. Use consistent headings, stable vocabulary, tables for exact comparison, and diagrams only when relationships become clearer. Measure whether readers can locate the right branch, not words per minute.

### Cost

Documentation cost includes authoring, review, rehearsal, translation, tooling, retention, search noise, and incident delay from defects. Prefer one canonical fact set with generated or linked views. Automate stable structural checks; keep human judgment for meaning, risk, and usability. Removing duplicate active truth often saves more than producing another page.

Make cost visible without reducing quality to money. A critical runbook may justify expensive rehearsal because delayed recovery dominates maintenance cost. A rarely used low-risk tutorial may use a lighter review path. Calculate expected maintenance surface from number of active copies, change frequency, reviewer effort, and consequence of staleness.

Generated views reduce copying but add generator, schema, and build dependencies. Handwritten views allow nuance but can drift. Choose deliberately, define canonical fields, and test both semantic consistency and audience usability.

## Traps and prevention

- **Write-more bias:** more prose can hide the decision. Start with outcome and delete unrelated detail.
- **One document for everyone:** incompatible reader modes and disclosure create confusion. Use linked views over canonical facts.
- **Command equals runbook:** syntax lacks prediction, evidence, authority, branches, and recovery.
- **Screenshot equals instruction:** images drift and exclude. Keep semantics in searchable text.
- **Latest edit equals current:** currency requires ownership, triggers, and observed use.
- **Link check equals truth:** automation proves only the condition it checks.
- **Author rehearsal:** authors unconsciously fill gaps. Observe a representative reader without rescue.
- **Root cause certainty:** complex incidents usually have mechanisms and contributing conditions; preserve uncertainty.
- **Training as universal action:** change system controls and verify effectiveness.
- **Wiki duplication:** multiple active routes create split-brain truth. Canonicalize and supersede.
- **Diagram beauty over semantics:** colors and icons cannot replace labelled edges, scope, and text alternatives.
- **Archive deletion:** preserve required evidence while removing it from active authority.

Prevention is a system: content schemas, stable identities, source ledgers, scoped owners, protected publication, automatic dependency triggers, disposable rehearsal, usage feedback, and explicit supersession.

### Prevention controls by layer

| Layer | Preventive control | Detective control | Recovery |
|---|---|---|---|
| claim | typed provenance and scope | unsupported-material-claim check | retract or qualify and relink |
| procedure | exact target and authority contract | representative rehearsal | stop, restore, escalate |
| diagram | view question and edge semantics | name/relationship drift review | regenerate or supersede |
| decision | append-only status and alternatives | implementation-to-ADR audit | superseding decision |
| incident | canonical state and audience projections | contradiction/timestamp check | correction event and notification |
| lifecycle | owner and trigger | expiry, duplicate-route, orphan scan | activate replacement and archive |

Defense in depth matters. A schema can require an owner field, but only governance and real use reveal whether that owner accepts responsibility.

### Editorial self-review

Read once for each concern rather than trying to review everything simultaneously:

1. outcome and audience;
2. factual provenance;
3. mechanism and causal language;
4. literal procedure safety;
5. security and privacy;
6. accessibility and information structure;
7. consistency with canonical identities;
8. lifecycle and ownership;
9. unnecessary repetition;
10. plain-language clarity.

Then ask another qualified reader. Self-review cannot simulate unfamiliarity.

## Memory card and retrieval

### Memory card: READER

- **R — Reader and result:** who acts or decides, and what proves success?
- **E — Evidence:** class, source, time, scope, unit, uncertainty.
- **A — Authority and audience:** what may they see and do?
- **D — Decision path:** prediction, action, observation, branch, recovery.
- **E — Evaluation:** scoped review, automated rejection, representative rehearsal.
- **R — Retirement:** owner, trigger, supersession, archive.

### Retrieval questions

1. Why is writing a production control? 2. What distinguishes observation from inference? 3. Why preserve unknowns? 4. When use a tutorial rather than how-to? 5. What makes a runbook step safe? 6. Why is a commit not approval? 7. What should an edge label communicate? 8. Why normalize but preserve timestamps? 9. How do audience views avoid contradiction? 10. What belongs in an ADR? 11. Why supersede rather than rewrite? 12. What is representative rehearsal? 13. What does link validation prove? 14. How should incident hypotheses be written? 15. What makes a postmortem blameless but accountable? 16. When is an action complete? 17. Which review triggers beat calendar review? 18. Why is page count a bad metric? 19. What is the first response to an ambiguous target? 20. What does the lab verifier not prove?

### Thirty-second incident recall

If you remember only one response during pressure, use:

```text
impact -> facts -> hypotheses -> actions -> unknowns -> owner -> next update
```

For a procedure, use:

```text
target -> authority -> predict -> act -> observe -> branch -> recover -> prove
```

For a decision, use:

```text
context -> constraints -> options -> evidence -> choice -> consequences -> revisit
```

These are retrieval cues, not templates that override local incident or change policy.

## Complete answers

### 1. Why is writing a production control?

Writing changes interpretation, decisions, and actions. A procedure can cause a mutation; a diagram can cause a security boundary to be approved; an incident update can change customer or leadership behavior. The effect may occur long after authoring. Therefore consequential documents need interface-like controls: stable identity, inputs, authority, evidence, review, versioning, observed use, and retirement.

### 2. Observation versus inference

An observation states what a named source reported for a scope, unit, and time. An inference explains or predicts from observations. “Pool acquisition wait increased” is observed; “database overload caused it” is an inference. The inference must retain supporting and conflicting evidence, alternatives, confidence, and a test capable of changing that confidence.

### 3. Why preserve unknowns?

An explicit unknown prevents a reader from mistaking omission for certainty. It also becomes operable: state why it matters, who owns it, what evidence is next, and when the decision must proceed despite uncertainty. Senior engineers do not eliminate uncertainty with confident vocabulary; they manage it.

### 4. Tutorial or how-to?

Use a tutorial when the goal is guided learning and the author controls a safe sequence. Use a how-to when a reader already understands prerequisites and needs to achieve a specific result. A tutorial may intentionally expose several mechanisms; a how-to should not make an incident reader complete a course before acting. Link both to precise reference and deeper explanation.

### 5. What makes a runbook step safe?

Safety requires a proven prerequisite and exact target, bounded authority, predicted result, literal action, observable branches, validation, stop conditions, recovery or forward-recovery path, escalation, and cleanup. Risk determines rigor. Field completeness is not sufficient: the step must be rehearsed by a representative authorized operator on a disposable target.

### 6. Why is a commit not approval?

A commit proves that some identity recorded a text change in version control. It does not prove reviewer scope, technical truth, security acceptance, publication authority, reader usability, or production execution authority. These are separate state transitions and should produce separate evidence.

### 7. What should an edge label communicate?

At minimum, direction and relationship meaning: protocol, event, data, call, dependency, ownership, or trust transition. Where relevant add identity, encryption termination, cardinality, sync/async behavior, and failure semantics. An unlabelled arrow lets every reader invent a different architecture.

### 8. Why normalize and preserve timestamps?

Normalization enables chronological comparison across offsets. Preserving originals maintains provenance and exposes source-clock or parsing questions. Neither step proves clock synchronization or causality. A later event can reflect an earlier hidden condition, so chronology is evidence for investigation, not a causal proof.

### 9. How do audience views avoid contradiction?

They select from stable canonical claim and decision identities. Views may omit detail, translate vocabulary, and reorder material for a reader's task, but cannot independently retype values or change state. Automated equality checks catch some conflicts; scoped human review checks meaning and disclosure.

### 10. What belongs in an ADR?

Title and stable identity, status, date, accountable owner, context, constraints, decision, feasible alternatives including no change, evidence, trade-offs, expected consequences, accepted risk, assumptions, implementation relationships, measurements, and reconsideration or supersession conditions. An ADR is not a complete design and should link to procedures and implementation evidence.

### 11. Why supersede rather than rewrite?

An earlier decision explains why a system exists in its present form. Rewriting it with later knowledge destroys the constraints and uncertainty that future engineers need. A superseding record preserves historical rationality and clearly states which evidence or assumptions changed.

### 12. What is representative rehearsal?

An authorized person resembling the intended reader performs the task in a representative but safe environment from the documented starting state, without hidden author assistance. An observer records hesitation, divergence, branch choice, outcome, and cleanup. Rehearsal is stronger than author testing because it exercises missing context.

### 13. What does link validation prove?

It proves that a destination resolves according to the checker's environment and rules. It does not prove the destination is current, authoritative, relevant, safe, accessible, understandable, or available during an incident. A valid link can lead to stale truth.

### 14. How should incident hypotheses be written?

Name them as hypotheses, state current confidence, supporting and conflicting evidence, scope, owner, and a discriminating next test. Do not let repeated chat messages turn a theory into fact. Audience updates should normally lead with impact and action, not speculative cause.

### 15. Blameless but accountable

Describe human actions neutrally and still identify decisions and owners. Study the system conditions that shaped behavior: access, interface, workload, incentives, review, automation, detection, containment, and recovery. Blamelessness protects learning from shame; it does not remove responsibility for completing improvements.

### 16. When is an action complete?

Implementation is an intermediate state. Completion requires representative evidence that the action changed the intended failure mechanism or consequence without unacceptable new risk. Define this evidence when creating the action, then review effectiveness after enough exposure or a controlled test.

### 17. Which triggers beat calendar review?

Interface/schema change, service-owner transfer, permission change, dependency release, data-classification change, disaster-recovery target change, failed rehearsal, incident-use defect, or contradictory source evidence. Calendar review remains a safety net for changes the dependency model misses.

### 18. Why is page count a bad metric?

It measures inventory, not outcome. More pages can increase duplicated truth, search time, review load, and staleness. Prefer representative task success, time to evidence, critical ownership, rehearsal freshness, conflict rate, and incident defects.

### 19. First response to an ambiguous target

Stop mutation. Resolve canonical environment, account, cluster, namespace, resource, and immutable version through read-only evidence. Compare with approved scope and require readback. If authority or identity remains unclear, preserve state and escalate. A warning banner is not a target control.

### 20. What does the verifier not prove?

It proves deterministic behavior of fictional fixtures: 73 case outcomes, five calculations, authority and root refusal, owned state, and cleanup. It does not prove source truth, prose quality, accessibility, human usability, organizational acceptance, production safety, learner independence, retention, or mastery. Each requires different evidence.

## Product-company interview

### Twelve realistic scenarios

### Scenario 1 — repair “restart the cluster”

**Level:** mid to senior. **Evaluates:** target safety, operational thinking, and willingness to stop.

**Strong answer:** “I would not edit this into a runnable command yet. I need canonical environment and cluster identity, symptom and decision, execution authority, dependency and capacity gates, expected state change, validation, partial-failure branches, recovery, and escalation. The procedure should resolve context read-only and require readback before any mutation. If restart is only a hypothesis, diagnosis and action must remain separate.”

**Weak signs:** immediately proposing a vendor command; relying on current shell context; saying “take a backup” without defining state; adding bold caution; assuming restart is harmless.

**Follow-ups:** How do you prevent wrong-account execution? What if restart succeeds on half the nodes? What evidence proves user recovery rather than process restart? A staff answer adds policy-enforced target scoping, reviewed automation, rehearsal, and action receipts.

### Scenario 2 — “the database is the cause”

**Level:** mid. **Evaluates:** evidence discipline and causal reasoning.

**Strong answer:** separate observed database connection wait from the causal inference. State request scope and time, inspect pool saturation, sessions, query/lock wait, network path, authentication, and dependency traces, and select a test that produces different predictions for competing explanations. Communicate impact and mitigation without waiting for cause.

**Weak signs:** treating correlation or chronology as proof; searching only the preferred subsystem; demanding a single root cause; delaying updates until certainty.

**Follow-ups:** What would falsify your hypothesis? How do sampling and missing spans affect confidence? How would you correct an earlier external claim?

### Scenario 3 — design an architecture diagram

**Level:** junior to staff, calibrated by depth. **Evaluates:** abstraction and communication.

**Strong answer:** ask which reader decision the diagram supports. Choose one view and environment. Use canonical nodes with responsibilities, labelled directional edges, trust/failure boundaries, observation date, scope and omissions, and a text alternative. Link context, service, sequence, deployment, and trust views rather than mixing them.

**Weak signs:** beginning with tool choice; producing every resource in one image; relying on color; unlabelled arrows; no version or scope.

**Follow-ups:** How would security and executives receive different views? How do you detect drift? Which facts remain canonical across views?

### Scenario 4 — ADR after a failed migration

**Level:** senior. **Evaluates:** decision history, accountability, and learning.

**Strong answer:** preserve the original accepted ADR because it records evidence and constraints at decision time. Create a linked superseding ADR with the failure evidence, changed assumptions, options, new choice, consequences, owner, and reconsideration conditions. Link implementation and post-incident evidence.

**Weak signs:** editing the original so it appears correct; blaming reviewers; documenting only the new solution; hiding dissent.

**Follow-ups:** How do you represent an option veto? When is a minor amendment enough? How would you prove teams implemented the superseding decision?

### Scenario 5 — executive incident update

**Level:** senior/lead. **Evaluates:** audience translation under uncertainty.

**Strong answer:** lead with measured user and business effect, scope and duration, current recovery state, immediate decision or exposure, mitigation, uncertainty, accountable owner, and next update. Derive values from canonical incident state. Keep internal hosts, raw logs, customer identifiers, speculative cause, and exploitable details out unless specifically authorized.

**Weak signs:** raw technical transcript; vague “teams engaged”; unsupported recovery estimate; false causal certainty; no next decision.

**Follow-ups:** What changes for a regulator, support, or security audience? How do you correct a material error? What if leadership demands an ETA unsupported by evidence?

### Scenario 6 — postmortem says “human error”

**Level:** all levels; senior depth expected. **Evaluates:** systems reasoning and culture.

**Strong answer:** record the action neutrally and examine why it was possible and consequential: target ambiguity, permissions, interface, workload, training, review, automation, containment, detection, and recovery. Select actions tied to mechanisms and verify effectiveness. Accountability remains through owners and decisions without shame.

**Weak signs:** retraining as the only action; removing all human agency; stopping at five whys; measuring action completion by ticket closure.

**Follow-ups:** How do you handle reckless behavior? Which evidence proves a guardrail helps? Could the new control slow emergency recovery?

### Scenario 7 — three conflicting runbooks

**Level:** senior. **Evaluates:** truth ownership and incident safety.

**Strong answer:** prevent unsafe mutation while identifying the authoritative service and procedure owners. Compare version, scope, evidence, and observed behavior. Create one reviewed active identity, update alerts/catalog/search atomically, mark predecessors superseded with forward links, and add duplicate-route and dependency drift checks.

**Weak signs:** editing all three copies; choosing the newest modified date; deleting history immediately; leaving aliases labelled current.

**Follow-ups:** What if no owner accepts responsibility? How do you keep an emergency path available during reconciliation? How do you measure recurrence?

### Scenario 8 — propose documentation as code

**Level:** lead/platform. **Evaluates:** platform thinking beyond Git.

**Strong answer:** describe stable schemas and identities, versioned review, previews, link and safety checks, protected publication, ownership, reusable canonical data, audience views, search, rehearsal receipts, lifecycle triggers, supersession, audit, accessibility, and feedback. Define a golden path without forcing every artifact into one format.

**Weak signs:** “put Markdown in Git”; requiring developers to maintain complex tooling; assuming pull-request approval proves usability; no migration or ownership model.

**Follow-ups:** What remains human judgment? How do emergency corrections work? How do you prevent the platform team becoming the content owner? What adoption and outcome signals matter?

### Scenario 9 — measure documentation

**Level:** senior. **Evaluates:** indicator design.

**Strong answer:** begin with outcome and consequence. For critical runbooks, measure representative task success, time to first useful evidence, wrong-branch rate, rehearsal age, owner coverage, stale dependency detection, incident defects, and effectiveness of repairs. Segment by artifact risk. Use page views only as supporting discovery evidence.

**Weak signs:** pages written, words, edits, or views as success; one organization-wide score; invasive reader tracking.

**Follow-ups:** How do you set an objective? What is the denominator? How do privacy and sparse incidents limit measurement? Which signals can be gamed?

### Scenario 10 — unsafe example discovered

**Level:** mid to senior. **Evaluates:** incident handling and integrity.

**Strong answer:** stop distribution or mark the artifact unsafe, preserve version and exposure evidence, assess whether credentials/data/targets were exposed, rotate or contain through the approved process, repair canonical source and derived views, notify affected owners/readers, and add a prevention control and effectiveness test. Avoid repeating the sensitive value.

**Weak signs:** silently editing; repeating the secret in a ticket; assuming no execution occurred; deleting history before investigation.

**Follow-ups:** How do you handle immutable repository history? How do you find copied versions? When does this become a security incident?

### Scenario 11 — reviewers disagree

**Level:** lead/staff. **Evaluates:** decision rights and influence.

**Strong answer:** clarify the decision owner and each reviewer's concern and authority. Restate shared outcome, constraints, evidence, alternatives, reversible experiments, and risk. Resolve factual disputes with discriminating evidence. Record material dissent and explicit risk acceptance. Escalate only to the role accountable for the unresolved decision.

**Weak signs:** seeking vague consensus; using seniority as evidence; endlessly adding prose; hiding dissent after decision.

**Follow-ups:** What if security has a veto? What if the owner accepts risk outside authority? How do you maintain trust after a rejected recommendation?

### Scenario 12 — runbook passed CI but failed an incident

**Level:** senior/staff. **Evaluates:** test boundaries and learning.

**Strong answer:** state what CI actually proved—schema, syntax, links, perhaps a model. Preserve the used artifact version and first divergence. Examine source drift, reader prerequisites, target/permission differences, partial output, missing branch, rehearsal representativeness, routing, and triggers. Repair both the procedure and the validation gap, then prove representative task success.

**Weak signs:** adding a random lint rule; blaming the operator; claiming tests are useless; changing expected output until green.

**Follow-ups:** Which failure belongs in automation versus human rehearsal? What evidence closes the repair? How do you avoid overfitting to one incident?

### How answers change by level

A junior answer should distinguish fact from hypothesis and write a clear bounded step. A mid-level answer handles branches, recovery, and audience. A senior answer connects artifacts, review scopes, security, and observed use. A staff answer designs ownership, control-plane invariants, adoption, incentives, and feedback across teams while preserving local expertise.

Interviewers are not evaluating literary style. They are evaluating whether you can make complex state understandable, expose uncertainty, protect action boundaries, and build a documentation system that learns.

## Independent transfer and rubric

Complete ASM-0237 without consulting the guided answer. A reviewer supplies two sanitized contexts, then changes an audience, evidence, or authority constraint after your first design.

For each context produce an audience contract, claim ledger, purpose-fit artifact map, one accessible diagram, one safe procedure branch, decision or incident record, lifecycle plan, and review/rehearsal evidence. Defend every omission. The reviewer scores correctness, provenance, boundary control, literal safety, accessibility, lifecycle, transfer under changed constraints, and cleanup.

Automatic output is insufficient. The reviewer must use hidden perturbations and record observed reasoning. No production credential, private incident, customer data, publication, or runtime mutation is allowed. Repository completion remains separate from learner evidence.

### Suggested unfamiliar contexts

The reviewer may use:

- a failed certificate rotation across a proxy and service;
- a queue backlog with uncertain producer/consumer responsibility;
- a restore test whose checksum passes but application invariants fail;
- a CI release artifact whose provenance is incomplete;
- a regional DNS failure with conflicting resolver evidence;
- a cost decision where engineering and finance use different units.

These are prompts, not answer keys. The reviewer changes details and withholds one relevant fact to observe how the learner handles uncertainty.

### Hidden perturbations

After the first submission, introduce two:

- the primary reader loses mutation authority;
- one canonical metric definition changes;
- an external audience is added;
- a previously reversible decision becomes irreversible;
- the diagram must work without color;
- a dependency owner disputes the timeline;
- a command succeeds partially;
- the active document route has a stale duplicate.

The learner should revise affected claims and artifacts, not rewrite everything. Strong transfer preserves stable identities and explains the blast radius of the changed constraint.

### One-hundred-point rubric

| Dimension | Points | Full-credit evidence |
|---|---:|---|
| audience and outcome | 10 | exact reader, authority, task/decision, success and escalation |
| claim provenance | 15 | material claims typed with source, scope, time, unit, confidence, unknowns |
| artifact selection | 10 | reader modes separated and linked through canonical facts |
| diagram semantics/accessibility | 10 | question, scope, stable nodes, labelled edges, boundaries, text alternative |
| procedure safety | 15 | exact target, authority, prediction, branches, recovery, cleanup |
| decision/incident reasoning | 10 | alternatives or facts/hypotheses, owner, consequence and chronology |
| security/privacy | 10 | least disclosure, no sensitive material, appropriate authority |
| lifecycle | 5 | owner, activation, triggers, supersession and archive |
| perturbation transfer | 10 | changed constraint traced without answer imitation |
| communication and defense | 5 | concise, technically precise, limitations explicit |

A critical safety failure caps the result regardless of arithmetic. Examples include using production credentials, authorizing an unbounded destructive action, fabricating evidence, exposing protected data, or claiming unknown cause as fact to justify mutation.

### Evidence package and delayed recall

The reviewer retains the prompt version, first submission, perturbations, revised artifacts, questions, learner reasoning, score, critical findings, cleanup confirmation, and reviewer identity. Seven or more days later, ask the learner to reconstruct the claim classes, safe-step state machine, and one artifact decision without opening the answer.

A high immediate score plus failed delayed recall is not mastery. A polished artifact produced with extensive prompting is not independent evidence. Record assistance honestly.

## References and review

The source lock contains Google technical-writing instruction [REF-1028], RFC editorial style [REF-1029], normative keywords [REF-1030], timestamps [REF-1031], C4 diagrams [REF-1032], Diátaxis [REF-1033], W3C text-alternative decisions [REF-1034], Google and GitHub documentation workflows [REF-1035, REF-1036], Microsoft style [REF-1037], AWS runbook guidance [REF-1038], Microsoft ADR guidance [REF-1039], Google SRE incident and postmortem guidance [REF-1040, REF-1041], NIST incident response [REF-1042], Mermaid [REF-1043], OWASP logging [REF-1044], and CommonMark [REF-1045].

These sources establish vocabulary and methods, not universal policy. Product behavior and organizational approval can change; follow the recorded review windows and authoritative local policy.

This chapter uses fictional evidence and tests no editor, messaging system, ticket, cloud, or runtime. Automated checks cannot prove truth, accessibility, readability, usability, legal fitness, confidentiality, or production safety. Formal scoped review, representative rehearsal, reviewer-scored transfer, and delayed recall remain required.

### How to use the references

Use REF-1028 and REF-1037 for writing instruction and style questions; REF-1029 for RFC editorial conventions; REF-1030 when normative keywords matter; and REF-1031 for timestamp representation. Use REF-1032 for architecture zoom and REF-1034 for visual alternatives. Use REF-1033 when separating learning, task, reference, and explanation.

REF-1035 and REF-1036 support maintainable documentation workflows, while REF-1045 defines the Markdown baseline used by many tools. REF-1038 and REF-1039 inform runbook and decision-record practice. REF-1040 and REF-1041 inform incident response and postmortem learning. REF-1042 anchors incident response in cybersecurity risk management. REF-1043 documents diagram syntax, not diagram quality. REF-1044 helps reason about logging and sensitive information.

Read the source that owns the claim. Do not cite Mermaid documentation to prove an architecture is correct or a style guide to prove an incident cause.

### Final operational summary

Before publishing consequential technical writing, prove:

```text
reader + outcome
material claims + provenance + unknowns
purpose-fit artifact and accessible views
literal target + authority + branches for actions
scoped review + representative rehearsal
one active identity + owner + triggers + retirement
```

When something is missing, name the missing state. Do not fill it with confident prose. That single habit makes runbooks safer, incidents clearer, decisions more honest, and systems easier to operate.

The durable skill is not producing more pages. It is preserving enough truthful, bounded state that another person can decide and act safely.
