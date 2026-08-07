---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0082",
  "slug": "architecture-system-design-foundations",
  "aliases": ["V10-L01", "architecture-system-design-foundations"],
  "curriculumIds": ["ARC-001"],
  "route": "/book/architecture/architecture-system-design-foundations",
  "order": 1,
  "volume": "10-architecture-leadership",
  "title": "Architecture and system design: turn requirements into evidence-backed trade-offs",
  "summary": "Design systems from user outcomes, measurable quality scenarios and workload evidence through C4, state and trust flows, capacity, failure analysis, alternatives, ADRs, validation and audience-fit communication.",
  "domain": "architecture",
  "level": {"from": "intermediate", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0007", "LES-0008"],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001", "DOC-001"],
  "testedEnvironments": [
    {"platform":"Official standards and documentation","version":"C4, SEI ATAM, ISO/IEC 25010:2023, IETF, NIST, OWASP, ADR and provider architecture guidance reviewed 2026-08-07","support":"concept-only","notes":"Sources establish documented methods and vocabulary, not fitness of any design."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 67 cases, five calculations, authority/root/unknown-artifact refusal and exact cleanup pass."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic fictional design model; no runtime, provider, service or benchmark."},
    {"platform":"Production or cloud runtime","version":"not present in the tested boundary","support":"unsupported","notes":"No account, credential, endpoint, deployment, data store, queue, traffic, fault, migration or production mutation is authorized."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "software-engineer", "cloud-engineer", "infrastructure-engineer", "solutions-architect", "technical-lead", "staff-engineer", "engineering-manager"],
  "learningObjectives": [
    "Turn a vague design request into a decision contract with owners, actors, outcomes, scope, non-goals, assumptions and constraints.",
    "Write functional requirements and measurable quality-attribute scenarios with stimulus, environment, response and response measure.",
    "Use SCALE to scope, calculate, architect, locate risks and explain trade-offs without treating it as a vendor framework.",
    "Draw C4 context, container, dynamic and deployment views at consistent abstraction levels with equivalent text.",
    "Trace synchronous, asynchronous, state, identity, data and trust flows through owners, protocols and failure boundaries.",
    "Quantify workload, latency budgets, failure-aware capacity, availability composition, backlog/drain time and recovery exposure.",
    "Choose consistency, idempotency, overload, degradation and recovery semantics from the user operation.",
    "Compare credible alternatives using explicit benefits, costs, veto constraints, sensitivity points and residual risk.",
    "Integrate reliability, security, privacy, observability, operability, capacity, cost and sustainability into one design.",
    "Record architecturally significant decisions with context, options, consequences, state, owners and supersession.",
    "Design migration, compatibility, canary, rollback, restore and production-readiness evidence before implementation.",
    "Defend the same architecture in concise executive, engineering, operations and interview narratives."
  ],
  "productionSignals": [
    "decision owner stakeholders business outcome scope non-goals assumptions constraints and review date",
    "actor user operation success condition criticality and failure consequence",
    "functional requirement quality attribute stimulus source environment artifact response and measure",
    "steady peak burst growth seasonality item bytes read write ratio concurrency and geographic distribution",
    "system context external system authority trust boundary and data class",
    "container component responsibility owner technology protocol interface version timeout and dependency",
    "request command event acknowledgement duplicate ordering idempotency and ambiguous outcome",
    "authoritative state derived state cache index queue log revision writer and reconciliation owner",
    "latency budget queue age throughput saturation headroom and largest-failure reserve",
    "component availability dependency topology correlation detection recovery and composite SLO",
    "identity principal credential token policy authorization decision and audit",
    "sensitive data collection purpose residency retention encryption deletion and egress",
    "SLI event context trace/log/metric coverage missing-data behavior dashboard and alert owner",
    "deployment unit failure domain release strategy compatibility canary stop rollback and forward recovery",
    "backup recovery point restore elapsed time writer fencing and business reconciliation",
    "alternative option assumption score veto constraint sensitivity tradeoff risk and residual owner",
    "implementation run operating migration opportunity and incident cost range",
    "ADR status context decision alternatives consequences owner date and supersession",
    "validation hypothesis environment load fault security recovery and acceptance evidence",
    "audience decision recommendation uncertainty evidence consequence and next review"
  ],
  "diagrams": [
    {"id":"LES-0082-DIA-001","title":"SCALE architecture decision loop","direction":"cyclic","boundaries":["scope","calculate","architect","locate risks","explain trade-offs","validate and learn"],"evidencePoints":["decision contract","workload math","views and flows","failure/threat table","ADR","test result"],"textAlternative":"A design begins with a bounded decision, quantifies the workload, maps structure and flows, locates risks, explains alternatives and returns validation evidence to the next revision."},
    {"id":"LES-0082-DIA-002","title":"C4 zoom and runtime views","direction":"hierarchical","boundaries":["system landscape","system context","containers","components","dynamic operation","deployment topology"],"evidencePoints":["people and systems","scope","responsibilities","relationships","sequence","runtime nodes"],"textAlternative":"Static C4 zoom levels explain what exists while dynamic and deployment views explain one operation and where instances run."},
    {"id":"LES-0082-DIA-003","title":"Checkout request, state and trust flow","direction":"left-to-right","boundaries":["customer","edge","checkout API","authoritative database","durable queue","fulfillment"],"evidencePoints":["request identity","authentication","idempotency key","commit","event ID","consumer checkpoint"],"textAlternative":"A checkout crosses trust boundaries, commits authoritative state once, publishes durable work and reconciles the eventual fulfillment outcome."},
    {"id":"LES-0082-DIA-004","title":"Quality-attribute scenario","direction":"left-to-right","boundaries":["stimulus source","stimulus","environment","artifact","response","response measure"],"evidencePoints":["peak event","failure","target component","behavior","latency/availability/recovery"],"textAlternative":"A quality requirement becomes testable when a named source produces a stimulus in an environment, the affected artifact responds and a numeric measure decides acceptance."},
    {"id":"LES-0082-DIA-005","title":"Failure-aware capacity and queue envelope","direction":"hierarchical","boundaries":["demand","headroom","healthy capacity","domain loss","admission","queue","drain"],"evidencePoints":["peak RPS","target RPS","instances","survivors","rejections","backlog","oldest age"],"textAlternative":"Capacity must cover demand plus headroom after the declared failure while admission and queue policies keep backlog age and recovery time bounded."},
    {"id":"LES-0082-DIA-006","title":"Alternative-to-ADR evidence chain","direction":"left-to-right","boundaries":["requirements","options","scenario analysis","sensitivity and risk","decision","validation","supersession"],"evidencePoints":["veto constraints","scores","tradeoffs","owners","ADR state","test receipt","new context"],"textAlternative":"Alternatives are compared against requirements; sensitivities and risks inform a recorded decision that remains revisable through new evidence and explicit supersession."}
  ],
  "commands": [
    {"id":"LES-0082-CMD-001","question":"Is this a guarded no-runtime architecture shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0082 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"fixtures, model, calculations and authority guards pass","nextEvidence":"initialize copied fixtures"},{"when":"lab=fail","meaning":"a named safety or source guard failed","nextEvidence":"correct the boundary without bypass"}],"proves":"offline prerequisites and guard","doesNotProve":"design fitness or runtime behavior"},
    {"id":"LES-0082-CMD-002","question":"Can bounded fictional design state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0082 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture exists","nextEvidence":"inspect status"},{"when":"refusal","meaning":"authority ownership or prior state is unsafe","nextEvidence":"preserve the first refusal"}],"proves":"planned local initialization","doesNotProve":"production environment creation","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0082-CMD-003","question":"Is the intended design and case set loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"cases=67 and design ID match","meaning":"reviewed fixture identity matches","nextEvidence":"map the operation"},{"when":"another identity","meaning":"fixture drift exists","nextEvidence":"stop and validate source"}],"proves":"local fixture identity","doesNotProve":"requirements correctness"},
    {"id":"LES-0082-CMD-004","question":"What operation, state owner, trust crossings and failure domains are modeled?","risk":"read-only","command":"bash lab.sh map","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"map=pass","meaning":"the synthetic path is explicit","nextEvidence":"challenge every relationship"}],"proves":"declared fictional path","doesNotProve":"deployed topology"},
    {"id":"LES-0082-CMD-005","question":"How much capacity survives the declared domain loss?","risk":"read-only","command":"bash lab.sh capacity","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"reserve=true","meaning":"synthetic survivor capacity covers target demand","nextEvidence":"test assumptions and distribution"}],"proves":"fixture arithmetic","doesNotProve":"instance benchmark or production capacity"},
    {"id":"LES-0082-CMD-006","question":"What does serial availability multiplication imply?","risk":"read-only","command":"bash lab.sh availability","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"availability=pass","meaning":"declared independent component probabilities compose","nextEvidence":"challenge independence and topology"}],"proves":"synthetic serial math","doesNotProve":"future availability"},
    {"id":"LES-0082-CMD-007","question":"What backlog, drain time and RPO exposure follow from the inputs?","risk":"read-only","command":"bash lab.sh backlog","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"backlog=pass","meaning":"bounded queue and exposure arithmetic completed","nextEvidence":"bind oldest-age and business reconciliation"}],"proves":"synthetic envelope","doesNotProve":"lost data or broker behavior"},
    {"id":"LES-0082-CMD-008","question":"Does the component latency budget close against the SLO?","risk":"read-only","command":"bash lab.sh latency","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"closes=true","meaning":"declared component budgets sum within the target","nextEvidence":"measure percentiles under load"}],"proves":"budget arithmetic","doesNotProve":"observed latency"},
    {"id":"LES-0082-CMD-009","question":"How does the weighted alternative model behave?","risk":"read-only","command":"bash lab.sh tradeoff","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"decision_authority=human-review-required","meaning":"score is advisory and sensitivity remains","nextEvidence":"inspect vetoes and change weights"}],"proves":"declared score calculation","doesNotProve":"best architecture"},
    {"id":"LES-0082-CMD-010","question":"Can an attractive design still have an unmeasurable contract?","risk":"read-only","command":"bash lab.sh evaluate requirements-ambiguous-or-unmeasurable","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"boundary=requirements","meaning":"implementation cannot close an undefined requirement","nextEvidence":"write stimulus response and measure"}],"proves":"planned requirement boundary","doesNotProve":"requirement priority"},
    {"id":"LES-0082-CMD-011","question":"Can a diagram exist while writer authority is unsafe?","risk":"read-only","command":"bash lab.sh evaluate state-owner-or-writer-authority-unbound","runFrom":"LES-0082 support/lab after setup","expectedBranches":[{"when":"boundary=state-owner","meaning":"boxes do not establish authority","nextEvidence":"bind writer revision acknowledgement and reconciliation"}],"proves":"planned state boundary","doesNotProve":"storage behavior"},
    {"id":"LES-0082-CMD-012","question":"Do all gates, calculations, refusals and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0082 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"67 cases, five calculations, refusals and cleanup pass","nextEvidence":"retain fictional-only limits"},{"when":"failure","meaning":"candidate evidence is rejected","nextEvidence":"preserve the first failed gate"}],"proves":"guarded offline lifecycle","doesNotProve":"representative architecture or learner mastery","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0082-LAB-001","title":"Guided checkout architecture evidence and tradeoff review","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; fictional local JSON only","timeMinutes":240,"privilege":"normal user; root and runtime authority refused","network":"none","changes":["one UID-scoped temporary root","copied fictional design and decision fixtures"],"abortConditions":["root","cloud credential","runtime endpoint","Kubernetes or Docker authority","symlink","wrong owner","unknown artifact"],"recovery":"Preserve the first failed assertion and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0082-architecture-system-design-foundations/support/lab"},
    {"id":"LES-0082-LAB-002","title":"Independent unfamiliar two-scale architecture review","mode":"independent","environment":"Reviewer-owned sanitized design briefs and evidence packet; no production connection","timeMinutes":240,"privilege":"read-only analyst; reviewer owns hidden constraints, scoring and cleanup","network":"none","changes":["local diagrams","calculations","risk table","ADR and review narrative"],"abortConditions":["production credential or mutation","employer-confidential architecture","customer data","fabricated benchmark","missing recovery or security boundary"],"recovery":"Discard or sanitize reviewer-owned artifacts after scored evidence is retained.","cleanupProof":"Reviewer confirms no credential, endpoint, external resource or confidential artifact remains.","path":"drafts/LES-0082-architecture-system-design-foundations/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0082-INC-001","signal":"A design review shows many services but cannot state the user operation or success measure.","firstThought":"The team has solution structure without a decision or measurable requirement.","safePath":"Return to actors, operation, outcome, scope, workload and quality scenarios before selecting components.","trap":"Add more diagram detail or fashionable technology."},
    {"id":"LES-0082-INC-002","signal":"The architecture promises 99.99 percent although three serial dependencies each promise less.","firstThought":"Component targets, topology, correlation and recovery do not support the claim by multiplication alone.","safePath":"Model the user path, dependencies, correlation, redundancy, detection and recovery; negotiate a defensible SLO.","trap":"Average provider SLA percentages."},
    {"id":"LES-0082-INC-003","signal":"A queue protects checkout during a burst but oldest-message age keeps growing.","firstThought":"Asynchrony moved waiting and failure into durable backlog; service and drain capacity are insufficient.","safePath":"Measure arrival, service, backlog age, retry amplification and downstream SLO; admit, shed or add bounded drain capacity.","trap":"Call the API healthy because enqueue latency is low."},
    {"id":"LES-0082-INC-004","signal":"A migration creates two writers and intermittent duplicate orders.","firstThought":"Coexistence lacks writer authority, idempotency and reconciliation.","safePath":"Fence authority, preserve operation identities, reconcile ambiguous outcomes and redesign cutover/rollback.","trap":"Retry every timeout or merge databases by timestamp."},
    {"id":"LES-0082-INC-005","signal":"A weighted matrix selects the complex option despite an unmet regulatory constraint.","firstThought":"A score cannot average away a veto requirement or invalid assumption.","safePath":"Separate hard constraints from preferences, expose sensitivity, reject infeasible options and record the human decision.","trap":"Treat the highest spreadsheet score as authorization."}
  ],
  "assessmentIds": ["ASM-0229", "ASM-0230", "ASM-0231"],
  "referenceIds": ["REF-0994", "REF-0995", "REF-0996", "REF-0997", "REF-0998", "REF-0999", "REF-1000", "REF-1001", "REF-1002", "REF-1003", "REF-1004", "REF-1005", "REF-1006", "REF-1007", "REF-1008", "REF-1009"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "This file begins as a schema-complete teaching scaffold; the full manuscript is still being written.",
    "All services, traffic, availability, latency, capacity, queue, cost, risk and scores in the local model are fictional.",
    "Serial availability multiplication assumes independent probabilities and a required topology; real dependencies are often correlated and recoverable.",
    "Weighted alternative scores are discussion aids and never replace hard constraints, accountable judgment or validation.",
    "No provider, runtime, endpoint, load, fault, security control, data store, queue, migration or production behavior is tested.",
    "Formal technical, security, privacy, financial and instructional review, representative design evidence, two reviewer-scored transfers, delayed recall and learner evidence remain required."
  ]
}
---

# Architecture and system design: turn requirements into evidence-backed trade-offs

## What you see and first thought

Someone says, “Design a scalable checkout system.” Do not begin with microservices, Kafka or a cloud diagram. First ask which user operation must succeed, at what scale, under which failures, with which data and security promises, and who owns the trade-off.

Architecture is the set of consequential boundaries and decisions that make required behavior possible. A beautiful diagram is evidence of communication, not evidence that the system works.

## Terms before commands

This chapter will define architecture, system, workload, requirement, constraint, quality attribute, scenario, component, container, interface, state owner, failure domain, trust boundary, alternative, risk, sensitivity point, trade-off and Architecture Decision Record before relying on them.

SCALE means **Scope, Calculate, Architect, Locate risks, Explain trade-offs**. It is this book’s decision loop, not a certification or vendor standard.

## Architecture map

The architecture will be shown through consistent C4 context, container, dynamic and deployment views plus state, data and trust flows. Every view needs a title, scope, legend, labeled directional relationships and an equivalent text explanation.

## Request or state path

The central operation follows customer intent through edge admission, identity, checkout processing, authoritative commit, durable work, fulfillment and user-visible reconciliation. Each acknowledgement must say which owner has accepted which obligation.

## Failure zoom

The design will zoom into dependency loss, domain loss, overload, queue growth, duplicate delivery, ambiguous commit, stale derived state, credential abuse, migration overlap and recovery. Each failure is tied to user impact and the narrowest safe response.

## Internals and state ownership

Every fact needs one authoritative writer or an explicit conflict protocol. Caches, indexes, replicas, queues and projections are not “the data”; they are owner-specific state with revision, freshness, replay and reconciliation rules.

## Evidence table

Evidence will distinguish declared requirements, calculated envelopes, diagrams, contracts, test results and observed production behavior. A model output proves only its formula and inputs.

## Command decoders

Every lab command will be decoded field by field, including units, assumptions, expected branches, what it proves and what it cannot prove.

## Decision path

The path is: bind the decision, make requirements measurable, quantify demand, map structure and flows, locate failures and threats, compare alternatives, record the decision, validate it and revise it when evidence changes.

## Guided Ubuntu lab

The guarded lab analyzes a fictional checkout design with no network or runtime authority. It maps the path and calculates failure-aware capacity, composite availability, backlog/drain time, RPO exposure, latency closure and alternative sensitivity.

## Production transfer

Production transfer requires a sanitized current-state packet, representative workload evidence, affected owners, real interface and data contracts, a disposable validation environment and separately authorized changes.

## Reliability, security, observability, capacity, and cost

These are interacting architecture properties, not independent checklist columns. Redundancy changes cost and consistency; encryption changes keys and latency; queues change recovery and freshness; observability changes privacy and resource use.

## Traps and prevention

The chapter will challenge technology-first design, mixed diagram levels, averages without distributions, provider-SLA arithmetic, unbounded queues, dual writers, score-driven decisions and ADRs written after implementation.

## Memory card and retrieval

The memory card will reduce the design loop to one incident-usable page, followed by retrieval questions that require explanation rather than recognition.

## Complete answers

Every retrieval and lab question will receive a direct answer, foundational mechanism and senior production interpretation.

## Product-company interview

Interview practice will cover requirement discovery, scale math, APIs/events, data ownership, overload, multi-region trade-offs, security, migration and architecture defense with weak-answer analysis and follow-ups.

## Independent transfer and rubric

The reviewer will provide two unfamiliar designs at different scales with hidden constraint changes. Published answers cannot satisfy the transfer.

## References and review

Sixteen primary or official records anchor methods and terminology. They do not certify a local design, and all current provider guidance must be reviewed again before use.
