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
    "This substantive manuscript covers the complete teaching path, but several sections still need deeper examples and production variants before promotion from quarantine.",
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

## Guided Ubuntu lab

### Setup and safety

Open Ubuntu 24.04 as a normal user, enter the LES-0084 support/lab directory, and run `bash lab.sh doctor`. Do not use `sudo`. The lab is local and fictional; exported cloud credentials, publication tokens, incident/runtime endpoints, root, symlinks, and unknown state are refused.

Run `bash lab.sh setup`, then `bash lab.sh status`. Confirm the packet ID, 73 cases, sentinel, exact UID-scoped path, and no network or publishing calls. If identity differs, stop and preserve the first error.

### Build the mental model

Run `bash lab.sh roadmap`. For each printed transition, name the state owner, evidence entering it, reviewer authority, and failure if the transfer is wrong. Then run `claims` and independently add the six class counts, calculate 21 divided by 24, and identify why one unknown is preferable to invented certainty.

Run `timeline`. Write original timestamps beside normalized UTC values. Recalculate the 33-minute impact and 35-minute detection-to-recovery intervals. Explain why neither duration proves cause.

Run `runbook`. Find the two steps not counted as independently verifiable. For every mutation, locate target, authority, prediction, abort, recovery, and validation. Explain why structural completeness still requires human rehearsal.

Run `freshness` and `audiences`. Distinguish active truth from archive, then trace one impact fact into each view. A view may omit detail for purpose or sensitivity; it may not alter the canonical value.

### Challenge and cleanup

Run both `evaluate` commands. Say the boundary before reading the output. Finally run `bash verify.sh` from clean state. The final line must report 73 cases, five calculations, refusal and cleanup. Run `bash lab.sh cleanup` if you performed setup separately, then prove the exact state path is absent. Your lab note must contain predictions, observed output, interpretations, non-proof boundaries, and one question the model cannot answer.

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

For a live incident, do not experiment with an unapproved template mid-response. Use the accepted incident system, roles, disclosure rules, and cadence. After stabilization, export only authorized evidence for analysis. NIST SP 800-61r3 frames incident response as part of broader cybersecurity risk management [REF-1042]; local policy determines exact authority.

## Reliability, security, observability, capacity, and cost

### Reliability

Define documentation service levels where consequence warrants them: active route availability, critical-runbook rehearsal age, owner coverage, stale dependency detection, and representative task success. Do not use page count as reliability. Design graceful failure: if a runbook dependency is unavailable, state the safe stop and escalation path.

### Security

Apply least disclosure and least privilege. Secret-scan examples, but also review private hostnames, customer identifiers, internal defenses, log injection, and commands with broad selectors. A redacted example must remain technically honest. Documentation never grants execution authority.

### Observability

Observe outcomes: search success, task completion, branch failures, escalation, stale-link hits, rehearsal defects, and action effectiveness. Protect readers and incident data. A dashboard should answer which critical artifact is unsafe or due, not merely how many pages exist.

### Capacity and performance

Reviewers and operators are finite capacity. Large undifferentiated documents create queueing and cognitive load. Keep emergency paths short, move explanation to linked pages, precompute safe queries, and distribute ownership. Test retrieval time and time-to-first-useful-evidence under realistic pressure.

### Cost

Documentation cost includes authoring, review, rehearsal, translation, tooling, retention, search noise, and incident delay from defects. Prefer one canonical fact set with generated or linked views. Automate stable structural checks; keep human judgment for meaning, risk, and usability. Removing duplicate active truth often saves more than producing another page.

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

## Complete answers

1. Writing changes decisions and actions; an ambiguous instruction can mutate production long after authoring. Treat it as an interface with ownership and validation.
2. Observation names source, scope, and time. Inference interprets observations and retains confidence, alternatives, and a test.
3. An explicit unknown prevents unsupported certainty and gives ownership to the next evidence-gathering action.
4. Use a tutorial when controlling a learner's experience; use how-to when a competent reader needs a goal path.
5. Prove prerequisite and target, predict, authorize a bounded action, observe, validate, and provide stop, recovery, and escalation branches.
6. A commit proves versioned change, not scoped review, risk acceptance, publication, or usability.
7. Direction plus protocol, event, data, trust, or dependency meaning. Unlabelled arrows invite incompatible stories.
8. Normalization permits ordering; originals preserve provenance. Neither corrects an inaccurate source clock.
9. They select canonical claim IDs and may translate detail, but cannot retype or alter values and state.
10. Context, constraints, accountable decision, alternatives, consequences, assumptions, evidence, status, and follow-up.
11. Supersession preserves why the earlier choice was rational and exposes which assumptions changed.
12. An authorized target reader uses the artifact in a representative disposable context without author rescue.
13. It proves destinations resolve under the checker, not truth, relevance, authority, accessibility, or task success.
14. Label hypothesis and confidence, cite supporting/conflicting evidence, and name a discriminating test.
15. Describe actions neutrally, analyze system conditions, assign accountable owners, and verify improvements; no blame does not mean no responsibility.
16. When representative evidence shows the intended mechanism changed risk acceptably—not when code merges.
17. Interface, ownership, permission, dependency, classification, failed-use, and failed-rehearsal changes.
18. It measures inventory, not reader outcomes; more pages can increase stale duplication and search cost.
19. Stop mutation, resolve canonical identity read-only, compare with approved scope, and require readback.
20. It proves deterministic fictional structure, calculations, refusal, and cleanup—not prose quality, truth, production safety, acceptance, or mastery.

## Product-company interview

### Twelve realistic scenarios

1. **Repair “restart the cluster.”** Strong: resolve exact identity read-only, authority, prediction, branches, recovery, validation. Weak: add a warning. Follow-up: how prevent wrong-context execution?
2. **Database is the cause.** Strong: separate observed wait from inference and design a discriminating test. Weak: repeat correlation. Follow-up: what would falsify it?
3. **Design an architecture diagram.** Strong: start with question/audience, one abstraction, labelled edges, trust boundaries, date, alternative text. Weak: one giant topology. Follow-up: which linked views?
4. **ADR after a failed migration.** Strong: preserve original, create superseding ADR with changed evidence. Weak: correct history in place. Follow-up: how represent dissent?
5. **Executive incident update.** Strong: user impact, business consequence, decision, uncertainty, mitigation, risk, cadence from canonical facts. Weak: raw logs or false certainty. Follow-up: what must remain internal?
6. **Postmortem says human error.** Strong: neutral action plus permission, interface, workload, detection, containment, and recovery mechanisms. Weak: retraining only. Follow-up: effectiveness measure?
7. **Three conflicting runbooks.** Strong: stop unsafe use, identify authoritative owner, compare evidence, publish one reviewed route, supersede others. Weak: update all copies. Follow-up: how prevent recurrence?
8. **Docs-as-code proposal.** Strong: versioning, review, schemas, preview, protected publication, ownership, rehearsal, and lifecycle. Weak: “put Markdown in Git.” Follow-up: what cannot CI prove?
9. **Measure documentation.** Strong: task success, time-to-evidence, failed branches, rehearsal age, stale dependencies, and incident defects. Weak: page views. Follow-up: privacy constraints?
10. **Unsafe example discovered.** Strong: stop distribution, assess exposure, rotate secrets if needed, repair source and derived views, add prevention. Weak: silently edit. Follow-up: preserve audit evidence how?
11. **Reviewer disagreement.** Strong: identify decision owner, reviewer scopes, evidence, alternatives, risk acceptance, and dissent. Weak: seek vague consensus. Follow-up: when escalate?
12. **Runbook passed CI but failed incident.** Strong: CI checked structure; analyze representative-use gap, permissions, drift, branch, trigger, and rehearsal design. Weak: add another lint rule only. Follow-up: which outcome closes repair?

At staff level, connect each answer to ownership and feedback loops. The interviewer is evaluating whether you can turn communication from individual craft into a reliable sociotechnical system.

## Independent transfer and rubric

Complete ASM-0237 without consulting the guided answer. A reviewer supplies two sanitized contexts, then changes an audience, evidence, or authority constraint after your first design.

For each context produce an audience contract, claim ledger, purpose-fit artifact map, one accessible diagram, one safe procedure branch, decision or incident record, lifecycle plan, and review/rehearsal evidence. Defend every omission. The reviewer scores correctness, provenance, boundary control, literal safety, accessibility, lifecycle, transfer under changed constraints, and cleanup.

Automatic output is insufficient. The reviewer must use hidden perturbations and record observed reasoning. No production credential, private incident, customer data, publication, or runtime mutation is allowed. Repository completion remains separate from learner evidence.

## References and review

The source lock contains Google technical-writing instruction [REF-1028], RFC editorial style [REF-1029], normative keywords [REF-1030], timestamps [REF-1031], C4 diagrams [REF-1032], Diátaxis [REF-1033], W3C text-alternative decisions [REF-1034], Google and GitHub documentation workflows [REF-1035, REF-1036], Microsoft style [REF-1037], AWS runbook guidance [REF-1038], Microsoft ADR guidance [REF-1039], Google SRE incident and postmortem guidance [REF-1040, REF-1041], NIST incident response [REF-1042], Mermaid [REF-1043], OWASP logging [REF-1044], and CommonMark [REF-1045].

These sources establish vocabulary and methods, not universal policy. Product behavior and organizational approval can change; follow the recorded review windows and authoritative local policy.

This chapter uses fictional evidence and tests no editor, messaging system, ticket, cloud, or runtime. Automated checks cannot prove truth, accessibility, readability, usability, legal fitness, confidentiality, or production safety. Formal scoped review, representative rehearsal, reviewer-scored transfer, and delayed recall remain required.
