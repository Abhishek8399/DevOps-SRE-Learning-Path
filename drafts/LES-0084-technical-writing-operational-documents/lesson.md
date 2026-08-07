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
    "This file begins as a schema-complete teaching scaffold; the full manuscript is still being written.",
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

The full manuscript will begin with an ambiguous incident update and show why writing is an operational control surface rather than decoration.

## Terms before commands

The manuscript will define audience, task, decision, claim classes, document types, views, procedures, decisions, incident records, lifecycle and evidence before using them.

## Architecture map

Six diagrams will connect evidence, document type, accessible system views, safe procedures, incident learning and lifecycle ownership.

## Request or state path

The path will trace purpose, evidence, drafting, review, rehearsal, publication, observed use, revision, supersession and archive.

## Failure zoom

Failure analysis will cover ambiguous targets, false certainty, unsafe examples, diagram drift, stale procedures, rewritten decisions, leaking updates and blame-only postmortems.

## Internals and state ownership

The manuscript will bind ownership for canonical facts, artifact versions, decisions, procedure authority, live incident state, actions, review triggers and archives.

## Evidence table

Evidence will distinguish observed, calculated, decided, declared, inferred and unknown claims plus source, window, unit, confidence, sensitivity and expiry.

## Command decoders

Every lab command will be decoded with inputs, output fields, equations, assumptions, branches, proof and non-proof boundaries.

## Decision path

The decision path will select reader, task, artifact, evidence, disclosure, review, rehearsal, publication and lifecycle controls.

## Guided Ubuntu lab

The guarded lab will walk through all 73 cases and five calculations without publishing, incident, messaging or runtime authority.

## Production transfer

Transfer will begin with sanitized authorized document evidence and separate local drafting, review, rehearsal, organizational publication and production authority.

## Reliability, security, observability, capacity, and cost

The chapter will treat documentation freshness, confidentiality, usable evidence, review capacity, cognitive load and maintenance cost as engineering concerns.

## Traps and prevention

The chapter will challenge write-more bias, one-document-for-everything, screenshot truth, command dumps, root-cause certainty, wiki duplication and validation theater.

## Memory card and retrieval

A one-page operational-writing memory card and retrieval set will support incident, review and interview recall.

## Complete answers

Every retrieval and guided-lab question will receive a direct answer, mechanism explanation and senior production interpretation.

## Product-company interview

Interview practice will cover runbooks, diagrams, ADRs, design docs, incident updates, postmortems, executive summaries, disagreement and documentation systems.

## Independent transfer and rubric

A reviewer will provide two unfamiliar writing contexts and change hidden audience, evidence and safety constraints; published answers cannot satisfy the transfer.

## References and review

Eighteen primary, creator-maintained or official records anchor terminology and methods. They do not certify a document, procedure, decision or communication.
