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
    "This substantive manuscript and deterministic lab remain a quarantined teaching candidate pending formal review, representative architecture evidence and independently scored learner transfer.",
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

Someone says:

> Design a scalable, highly available checkout system.

The tempting response is to draw an API gateway, microservices, Kafka, Redis and three regions. Resist that impulse. Those are possible mechanisms, not the problem.

Your first thought should be:

> Which user is trying to complete which operation, under what load and failures, with what correctness, latency, security and recovery promises?

Until that sentence has an owned answer, “scalable” means nothing. Ten requests per second and ten million requests per second can need completely different systems. “Highly available” can mean the page opens, the order is durably accepted, payment is captured exactly once, or fulfillment completes before a deadline. These are not the same promise.

### The architect’s real job

Architecture is not predicting the future perfectly. It is making the most consequential current decisions visible, testable and changeable:

```text
user outcome
  + measurable conditions
  + workload and data
  + hard constraints
  + failure and threat model
  + feasible alternatives
  + explicit consequences
  + validation and recovery
  = defensible architecture decision
```

“Defensible” does not mean everyone prefers the decision. It means another engineer can trace why it was made, which evidence supported it, which risks were accepted, and what new evidence should cause revision.

### Start with one operation

For checkout, choose a concrete operation:

> A signed-in customer submits one cart and receives an unambiguous order result.

Now questions become useful:

- What identifies the customer, cart and submission?
- When may the API say “accepted”?
- Which state proves that the order exists?
- Can payment or fulfillment happen later?
- What happens when the client times out after the database commits?
- What is the maximum acceptable response time at normal and peak load?
- Which failure must the system tolerate?
- Where may cardholder and personal data travel?
- How much order data may be exposed to loss, and how quickly must service recover?

The operation gives the diagram a reason to exist.

### Architecture is a model, not the system

A diagram, calculation, Architecture Decision Record (ADR) and prototype are models. Each deliberately leaves something out:

| Artifact | Helps answer | Cannot prove alone |
|---|---|---|
| context diagram | who and what interacts with the system | runtime sequence or capacity |
| container diagram | major responsibilities and relationships | code correctness or deployment health |
| dynamic diagram | one operation’s ordered interactions | every concurrent or failure path |
| deployment diagram | where runtime instances and boundaries exist | actual placement or failover |
| capacity calculation | consequence of declared inputs | that inputs match production |
| weighted option table | how preferences affect comparison | that the highest score is authorized |
| ADR | why a decision was accepted | implementation conformance |
| load/fault test | observed behavior in one envelope | all future traffic and failures |

Senior engineers do not ask, “Is the diagram correct?” They ask, “Correct for which question, version and scope—and what evidence must come next?”

Architecture is the set of consequential boundaries and decisions that make required behavior possible. A beautiful diagram is evidence of communication, not evidence that the system works.

### The two failure modes to remember

**Solution-first design** starts with a preferred technology and invents requirements that justify it.

**Document-only design** produces diagrams and ADRs but never converts assumptions into tests or operating controls.

The healthy loop moves both ways:

```text
requirements -> design -> implementation -> observation
      ^                                  |
      +---------- learn and revise ------+
```

## Terms before commands

### Architecture, design and implementation

**Architecture** is the set of decisions and boundaries that are expensive, risky or organizationally difficult to change. Examples include writer authority, trust boundaries, public contracts, failure-domain topology and deployment ownership.

**Design** is the broader arrangement of responsibilities and interactions that satisfies requirements. Not every design choice is architecturally significant.

**Implementation** is the concrete code, configuration and deployed resource state. A team can implement a different architecture from the approved diagram, which is why validation and drift evidence matter.

### System, component and container

A **system** is a bounded collection of people, software, hardware, data and procedures that achieves an outcome. The boundary depends on the question.

A **component** is a replaceable part with a responsibility and interfaces. It is not automatically a process or service.

In the C4 model, a **container** means an application or data store that must be running for the software system to work—for example, a web application, API process, database or queue. It does not specifically mean an OCI/Docker container. Always state which meaning you intend.

### Actor, stakeholder and owner

An **actor** interacts with the system: customer, operator, service, device or external organization.

A **stakeholder** is affected by or can constrain the decision: Product, Security, Finance, Legal, Operations, a downstream team or a customer representative.

An **owner** has accountable decision or operating authority. Participation is not ownership. Every accepted risk, interface, state item and readiness gate needs an owner who can act.

### Requirement, assumption and constraint

A **functional requirement** states behavior: “Submitting a valid cart creates one order.”

A **quality requirement** states how well behavior must work under named conditions: “During the reviewed peak, 99% of accepted submissions return an unambiguous result within 300 ms.”

An **assumption** is believed for this decision but needs validation: “Peak traffic will be 12,000 requests per second.” Record source, owner and review date.

A **constraint** limits feasible choices. Hard constraints, such as data residency or a fixed protocol required by a regulator, can veto an option. Preferences, such as team familiarity, influence comparison but can be traded. Do not average a hard constraint into a score.

### Quality attribute and scenario

A **quality attribute** names a property such as reliability, performance, security, modifiability, operability or cost efficiency. The word alone is too broad.

A **quality-attribute scenario** makes it testable:

```text
source      Who or what causes the event?
stimulus    What happens?
environment Under which operating or failure condition?
artifact    Which part of the system is affected?
response    What must the system do?
measure     Which number or observable fact decides success?
```

Example:

> When one availability zone becomes unreachable during the reviewed peak, the checkout path continues accepting valid orders with p99 latency below 300 ms and availability above 99.95%, without two active writers for an order identity.

Now capacity, topology, writer fencing, latency and availability can be reviewed.

### Workload and workload envelope

A **workload** is the set of operations and data the system processes. A **workload envelope** gives the distributions and boundaries a design must handle:

- steady, peak and burst arrival rate;
- concurrency and request duration;
- payload and result sizes;
- read/write ratio and key distribution;
- seasonality, growth and geographic source;
- failure traffic, retries, replays and maintenance;
- service-time distribution, not only an average.

A point estimate is not an envelope. “12,000 RPS” needs a window, percentile, operation mix and source.

### Interface, protocol and contract

An **interface** is where one owner offers behavior to another. A **protocol** defines interaction rules such as HTTP, gRPC or a message format. A **contract** includes more than fields:

- identity and authorization;
- version and compatibility;
- request/command/event meaning;
- timeout and cancellation;
- acknowledgement boundary;
- error taxonomy;
- duplicate and ordering behavior;
- quotas and size limits;
- ownership and deprecation.

“Service A uses Service B” hides almost everything an operator needs.

### State, authority and derived state

**State** is information that survives long enough to affect later behavior.

The **authoritative owner** decides the accepted value or transition for a fact. A replica, cache, index, materialized view or search document is **derived state** unless the contract explicitly gives it authority.

**Writer authority** answers which participant may accept a new transition for an identity at a moment. Active-active is not a magic availability setting; it requires a conflict, ordering and reconciliation model.

### Synchronous and asynchronous

A **synchronous** dependency keeps the caller waiting for a reply. Its latency and availability are on the immediate path.

An **asynchronous** interaction acknowledges before downstream work completes. This can isolate latency and bursts, but it creates durable backlog, freshness, duplicate, ordering, retry, poison-message, expiry and reconciliation obligations.

Asynchrony moves responsibility; it does not remove it.

### Failure domain, blast radius and correlation

A **failure domain** is a set of elements likely to fail together because they share power, network, software, identity, control plane, operator action or dependency.

**Blast radius** is the affected people, operations, data, tenants, locations and time—not merely the number of servers.

**Correlation** means failures are not independent. Two services in different zones may still share one identity provider, global configuration error or deployment pipeline.

### Trust boundary and threat

A **trust boundary** is where identity, authority, data classification or enforcement assumptions change. Internet-to-edge, workload-to-database, tenant-to-platform and operator-to-control-plane are common examples.

A **threat** is a capable actor or event that can exploit a boundary or asset. Threat modeling asks what is valuable, who can act, how trust changes, what can go wrong, which control changes likelihood or impact, and what residual risk remains.

### Capacity, throughput, latency and saturation

**Capacity** is the maximum work sustainable while meeting the declared service contract. **Throughput** is completed work per unit time. **Latency** is elapsed time for an operation. **Saturation** appears when a constrained resource or queue has insufficient headroom.

Capacity depends on the SLO, workload mix and failure state. A process that handles 1,000 RPS with unacceptable p99 latency does not have 1,000 RPS of usable capacity.

### Availability, reliability and resilience

**Availability** is the proportion of valid opportunities in which the operation is usable under a defined measure.

**Reliability** is consistent correct behavior under defined conditions. It includes more than uptime.

**Resilience** is the ability to withstand, degrade through and recover from disruption. Redundancy without detection, failover, authority and recovery tests is unused inventory, not proven resilience.

### RPO and RTO

The **Recovery Point Objective (RPO)** bounds acceptable data-time exposure after a disruption. It is not a promise that exactly that much data will be lost.

The **Recovery Time Objective (RTO)** bounds the desired time to restore the required business capability. Infrastructure startup is not business recovery; identity, data integrity, routing, dependencies and reconciliation also matter.

### Alternative, trade-off and sensitivity

An **alternative** is a feasible way to satisfy the decision contract. Include a simpler option and the current system when credible.

A **trade-off** is an intentional gain in one property with a sacrifice or obligation elsewhere.

A **sensitivity point** is an input or decision where a small change materially changes the result. Queue consumer rate, regional demand or a reliability weight can be sensitivity points.

A **trade-off point** affects several quality attributes—for example, synchronous cross-region replication may improve some recovery properties while increasing write latency, cost and correlated dependency.

### Risk, issue and unknown

A **risk** is an uncertain future condition with likelihood and consequence. An **issue** is already occurring. An **unknown** is evidence you do not possess.

Do not convert “unknown” to “low risk” because a review deadline arrived. Assign an experiment, owner or explicit risk acceptance.

### ADR and decision state

An **Architecture Decision Record (ADR)** preserves one significant decision’s context, considered options, outcome and consequences. A proposed ADR is not an accepted decision. An accepted ADR should remain historical; new evidence creates a superseding record rather than rewriting why the old choice was made.

An ADR explains why. Tests and conformance evidence show whether implementation follows it.

### SCALE

SCALE is this book’s working loop:

1. **Scope:** bind decision, actors, outcome, boundaries, assumptions and constraints.
2. **Calculate:** quantify workload, latency, capacity, availability, queues, recovery and cost where meaningful.
3. **Architect:** map responsibilities, interfaces, state, identity, data, trust and deployment.
4. **Locate risks:** exercise failures, threats, overload, migration, recovery, sensitivity and unknowns.
5. **Explain trade-offs:** compare feasible options, record the decision, consequences, validation and revision triggers.

It is not a certification or vendor standard. Its purpose is to stop system design from becoming either a product shopping list or an untested document.

## Architecture map

One diagram cannot answer every architecture question. A city map, a building floor plan and a wiring diagram can all describe the same place, but combining them creates noise. Architecture views work the same way: each view must state the question it answers and keep one level of abstraction.

### SCALE is an evidence loop

```text
          ┌───────────┐
          │ 1. Scope  │  decision, actors, outcome, boundary
          └─────┬─────┘
                v
┌────────┐  ┌───────────┐  ┌─────────────┐
│Learn / │<-│2.Calculate│->│3. Architect │
│validate│  └───────────┘  └──────┬──────┘
└───^────┘                         v
    │        ┌──────────────┐  ┌───────────────┐
    └────────│5. Explain    │<-│4. Locate risks│
             │trade-offs    │  └───────────────┘
             └──────────────┘
```

**Text alternative:** bind one decision, calculate its operating envelope, map the responsible structure and flows, locate failure and threat conditions, explain the alternatives, then feed validation evidence into the next revision.

This is deliberately a loop. A load test can disprove the throughput assumption. A threat model can reveal that the selected trust boundary is unacceptable. A restore exercise can show that the recovery target is impossible. Senior engineering means changing the design when evidence changes, not defending the first diagram.

Use a small evidence packet at every pass:

| SCALE step | Question | Minimum receipt |
|---|---|---|
| Scope | What decision must be made, for whom, by when? | decision contract with owner and non-goals |
| Calculate | What demand and target must the design survive? | units, formula, input source and sensitivity |
| Architect | Who owns each responsibility, interface and state transition? | scoped views plus contracts |
| Locate risks | How can the user operation fail, be abused or become unrecoverable? | scenario table with owner and response |
| Explain | Why this option, what did we reject and when should we reconsider? | ADR plus validation plan |
| Learn | What observed evidence supports or contradicts the model? | dated test, drill or production receipt |

### C4 zoom levels without mixed-scale diagrams

The C4 model gives a useful zoom vocabulary. It does not force one drawing tool.

```text
Landscape: other systems in the organization
    └── Context: this system, its people and external systems
          └── Container: deployable/runnable responsibilities
                └── Component: important parts inside one container

One operation: Dynamic view across selected elements
One runtime:   Deployment view mapping instances to nodes/domains
```

Here **container** means a separately running or deployable unit in the C4 sense. It does not necessarily mean a Docker container. A mobile application, database, server-side application and message broker can all appear as C4 containers.

Use each view for a specific conversation:

- **System context:** who uses the system, what outcome they need, which external systems are dependencies and where organizational ownership changes.
- **Container:** major runtime responsibilities, protocols, data stores and ownership. This is usually the most valuable first technical view.
- **Component:** internals of one container only when that detail changes a decision. Do not draw every class.
- **Dynamic:** the ordered interactions for one named scenario, including acknowledgements and failure branches.
- **Deployment:** instances, nodes, zones, regions, network boundaries and failure domains.

A common weak diagram places “customer” beside an internal class, a cloud region, a database table and a Kubernetes pod. The arrows may be accurate individually, but the abstraction is inconsistent. Split it into views.

### The context view: establish the promise

For the fictional checkout system:

```text
Customer ──place order / inspect outcome──> Checkout System
                                                │
                    ┌───────────────────────────┼──────────────────────┐
                    v                           v                      v
              Identity Provider          Payment Provider       Fulfillment
              authenticate user          authorize/capture      prepare goods

Support operator ──investigate / reconcile──> Checkout System
```

The context view should make five things visible:

1. the person or system initiating the operation;
2. the user-visible outcome;
3. external authorities, such as identity or payment;
4. support or operating actors;
5. the declared system boundary.

It should not pretend that an external payment provider is “just an API.” It owns payment facts, has independent failure modes and may produce an ambiguous outcome. That ownership affects reconciliation.

### The container view: responsibilities before products

```text
[Browser]
    │ HTTPS + operation ID
    v
[Edge admission] ──verified identity──> [Checkout API]
                                            │ transaction
                                            v
                                      [Order database]
                                            │ durable obligation
                                            v
                                      [Outbox publisher]
                                            │ event ID
                                            v
                                      [Durable queue]
                                            │ at-least-once delivery
                                            v
                                      [Fulfillment worker]
                                            │ provider command
                                            v
                                      [Payment/Fulfillment systems]
```

Notice that responsibilities are named before vendors. “Durable queue with bounded retention and replay” is an architectural need. Kafka, SQS, RabbitMQ or another technology may implement it after constraints are known. Selecting a product first hides the actual decision.

Every relationship needs more than an arrow. Record:

- initiator and receiver;
- protocol and version;
- authentication and authorization identity;
- request/event schema owner;
- timeout and retry authority;
- acknowledgement meaning;
- ordering and duplicate behavior;
- data classification;
- telemetry correlation field;
- behavior during partial failure.

### Add state, trust and failure-domain overlays

Static boxes alone do not expose the hardest risks. Add three overlays or separate views.

**State view:** mark authoritative facts, derived projections, caches, queue obligations, revisions and reconciliation owner.
**Trust view:** mark principals, credentials, policy decisions, sensitive fields and every boundary where validation must be repeated.
**Failure-domain view:** place instances inside process, node, zone, region and external-provider boundaries.

```text
Region A
├── Zone 1: edge-a, api-a, worker-a
├── Zone 2: edge-b, api-b, worker-b
└── Regional dependencies: order-db-primary, queue endpoint

External domains
├── Identity provider
├── Payment provider
└── Fulfillment provider
```

Two replicas in one zone are process redundancy, not zone redundancy. Three application zones with one regional database may survive an application-zone failure but not a database-region failure. Draw the dependency where it actually fails.

### Diagram quality contract

Before accepting any diagram, ask:

- Is its title a question or declared view, not “architecture v7 final”?
- Is system scope explicit?
- Is one abstraction level used?
- Are relationships directional and labeled?
- Are legends and acronyms explained?
- Are authoritative data and external owners visible?
- Are trust and failure boundaries represented somewhere in the packet?
- Is there an equivalent text explanation for accessibility and review diffs?
- Is it dated, versioned and tied to an owner?
- Can an operator connect a production signal to a box and a user operation?

A beautiful diagram that cannot answer those questions is decoration. A modest diagram with clear ownership and semantics is operationally useful.

## Request or state path

Now trace one operation. The question is not merely “where does the HTTP request go?” The question is:

> At each step, which owner has accepted which obligation, and how can the user learn the truth after any timeout?

We use **place order** because it forces decisions about identity, duplication, authoritative state, payment, asynchronous work and ambiguous outcomes.

### The complete path

```text
Customer
  │ 1. POST /orders + operation_id
  v
Edge ──2. authenticate / admit──> Checkout API
                                      │ 3. authorize command
                                      │ 4. begin transaction
                                      v
                                Order database
                         5. order + outbox commit together
                                      │
              6. durable acceptance───┘
              <──────────────────────── API returns order_id

Outbox publisher ──7. publish event_id──> Durable queue
                                              │ 8. deliver (duplicates possible)
                                              v
                                      Fulfillment worker
                                       │ 9. idempotent command
                                       v
                                  External provider
                                       │ 10. outcome/webhook
                                       v
                                  Reconciliation
                                       │ 11. update authoritative status
                                       v
Customer ──12. GET /orders/{id}──> current user-visible outcome
```

**Text alternative:** the customer submits one operation identity. The edge authenticates and admits it. The checkout API authorizes it and commits the order plus a publication obligation atomically. The response identifies the durable order. A publisher transfers the obligation to a durable queue. A worker processes deliveries idempotently against external owners. Reconciliation updates the authoritative status, which the customer can query after any uncertain response.

### 1. Give the operation a stable identity

TCP connections, HTTP attempts and business operations are different identities. A client may send the same business operation through several network attempts after timeouts.

Use a client- or server-issued **operation ID** with a defined scope:

- bound to the authenticated principal or tenant;
- bound to the operation type;
- retained for at least the maximum retry and ambiguity window;
- mapped to the original result or a clear conflict;
- protected from payload substitution.

If operation `op-42` originally means “place this basket,” a retry with `op-42` and a different basket must not silently create or mutate another order. Return the original result or reject the conflicting reuse.

An idempotency key does not make arbitrary code idempotent. The server needs durable deduplication state and atomic rules around side effects.

### 2. Authenticate, authorize and admit separately

Authentication asks “which principal presented valid proof?” Authorization asks “may this principal perform this action on this resource?” Admission asks “should the system accept more work now?”

Those are distinct decisions:

- a valid user can still lack permission;
- an authorized request can still be rejected by a rate or concurrency limit;
- a healthy edge can admit work into a saturated downstream system unless limits are coordinated.

Forward a constrained service identity and verified claims, not the user’s reusable credential. Record the policy decision and correlation identity without leaking secrets or sensitive payloads.

### 3. Bind validation to the command boundary

The checkout API validates schema, semantic invariants and current authority. Schema validation can prove that `quantity` is an integer. It cannot prove inventory is available, the caller owns the basket or the quoted price is current.

Reject invalid work before expensive dependencies. Preserve a stable error taxonomy so clients know whether to correct, retry, wait or query.

### 4. Define the authoritative commit

The order database is the authority for order acceptance in this design. The commit boundary must answer:

- which facts become durable together;
- which revision identifies the transition;
- what acknowledgement means;
- what happens if the connection disappears before the client sees it;
- how another actor later queries the result.

“HTTP 200” is not itself durability. The API contract must say that a successful response is emitted only after the authoritative order transaction commits.

### 5. Close the database-to-queue gap

A dangerous sequence is:

1. commit the order;
2. publish an event;
3. crash between them.

The order then exists, but fulfillment never learns about it. Reversing the calls creates the opposite failure: work can be consumed for an order that did not commit.

The local design uses a **transactional outbox**: the order row and an unpublished obligation are committed in the same database transaction. A publisher later reads the obligation and sends it to the queue. Publication can repeat, so the event has a stable identity and consumers remain idempotent.

This does not provide magical “exactly once” execution across independent systems. It converts an untracked gap into durable, observable, replayable state.

### 6. Make acknowledgements precise

Every acknowledgement transfers a specific obligation:

| Acknowledgement | What it may mean | What it does not automatically mean |
|---|---|---|
| edge accepted bytes | request entered edge processing | order exists |
| API success after commit | authoritative order and outbox obligation are durable | payment or fulfillment completed |
| broker publish acknowledgement | broker accepted the event under its durability policy | consumer completed business work |
| consumer checkpoint | consumer declares the event handled | external provider outcome is correct |
| provider response | provider accepted or completed a command according to its contract | local state is reconciled |

When a timeout happens, first locate the last durable acknowledgement. Do not blindly retry every layer.

### 7. Treat delivery semantics as a contract

Assume at-least-once delivery unless the entire path proves stronger semantics. A worker can receive the same event after:

- publisher retry;
- acknowledgement loss;
- visibility timeout;
- consumer crash after side effect but before checkpoint;
- replay or disaster recovery.

The consumer stores processed operation/event identity or uses a business-natural uniqueness constraint. Its side effect to an external provider also needs an idempotency identity or reconciliation path.

Ordering is scoped. “FIFO queue” is incomplete without saying whether order is global, per partition, per entity or best effort. Global ordering often damages throughput and availability. Most order workflows need ordering per order identity plus version checks.

### 8. Bound asynchronous waiting

A queue absorbs a finite mismatch between arrival and service. It does not create processing capacity.

Let arrival rate be λ items/s and service rate be μ items/s. While λ > μ, backlog grows at:

```text
growth rate = λ - μ
backlog after t seconds = (λ - μ) × t
oldest-item age at the peak ≈ backlog / μ
```

Once service capacity is greater than normal arrival, drain rate is `μ_recovery - λ_normal` and:

```text
drain time = backlog / (μ_recovery - λ_normal)
```

Alert on oldest age and completion SLO, not only queue depth. Ten thousand tiny messages and ten thousand expensive messages do not represent equal work.

### 9. Make external ambiguity normal

Suppose the payment provider executes a charge, but its response times out. The local worker cannot know whether retrying will double-charge.

The safe path is:

1. use a stable provider idempotency identity if supported;
2. mark the local operation as pending/ambiguous, not failed;
3. query or receive an authoritative provider outcome;
4. reconcile by operation identity;
5. expose a truthful pending state to the user;
6. escalate exceptions with enough audit evidence.

Timeout means “the observer did not receive an answer before its deadline.” It does not mean “the remote action did not happen.”

### 10. Separate authoritative and derived read paths

Search indexes, caches and analytics projections may lag. If a customer asks immediately whether an accepted order exists, choose a read path whose freshness supports that promise.

Options include reading the authority, read-your-write routing, a session revision token or explicitly presenting a pending state. Never call a stale projection “eventually consistent” and leave the acceptable delay undefined.

### 11. Carry causal evidence end to end

Use different fields for different questions:

- trace ID: how one distributed attempt propagated;
- operation ID: which business intent this is;
- order ID: which business entity exists;
- event ID: which durable message delivery is being processed;
- revision: which state transition is observed;
- principal/tenant ID: who owns the action, handled under privacy rules.

One universal “correlation ID” often becomes ambiguous. Propagate structured identities and log safe references.

### 12. Design the uncertain response before the happy response

The client contract should distinguish:

- rejected before acceptance;
- accepted with durable order identity;
- pending with a query/retry-after path;
- conflict because the operation identity was reused differently;
- unavailable before acceptance;
- outcome unknown, requiring status lookup rather than a new business operation.

This prevents retry storms and duplicate side effects.

### 13. Define degradation by user outcome

During recommendation or analytics failure, checkout may proceed without personalization. During payment-authority loss, pretending success may be unsafe. During projection lag, the API can show a pending status with bounded freshness.

A degradation decision says which outcome remains correct, what becomes unavailable, how long the mode may persist, how operators observe it and how recovery reconciles state.

### 14. Recovery reconciles owners

Recovery is not “all pods are green.” It is complete when authoritative owners agree, durable obligations are drained within target, ambiguous external outcomes are reconciled and users see correct state.

For each transition, write this sentence:

> After failure at this arrow, the source of truth is ___, the retry authority is ___, duplicate detection uses ___, and reconciliation is owned by ___.

If the team cannot fill the blanks, the path is not yet designed.

## Failure zoom

Architecture becomes useful when the happy-path arrows are challenged. Use a **failure scenario** with the same discipline as a quality scenario:

> When [stimulus] occurs during [environment], [artifact] must [response], measured by [response measure], while preserving [invariant].

“Highly available” is not a scenario. “During loss of one availability zone at peak traffic, accepted checkout requests remain below 300 ms p99 and no acknowledged order is lost” is testable, although it still needs exact measurement rules.

### Failure modes for the checkout operation

| Failure | User-visible risk | First evidence | Narrow safe response | Recovery proof |
|---|---|---|---|---|
| edge overload | rejection or long wait | admitted, rejected and in-flight rate | bounded admission and explicit retry guidance | latency and rejection return within target |
| API process crash | uncertain response | trace plus operation lookup | retry same operation identity | one authoritative order |
| database unavailable | no safe commit | connection/transaction error | reject before acceptance; preserve intent at client | health plus commit/reconciliation evidence |
| commit succeeded, response lost | duplicate order on retry | operation identity exists | return original outcome | one order for the identity |
| publisher down | fulfillment delay | unpublished outbox age | retain durable obligation; restore publisher | outbox age drains within target |
| duplicate event | duplicate external action | repeated event ID | idempotent consumer/provider command | one business effect |
| queue consumers slow | growing completion delay | oldest-message age | shed optional work/add bounded capacity | backlog drained without overload |
| provider timeout | double charge or false failure | provider operation identity | mark ambiguous and reconcile | local/provider facts agree |
| stale projection | accepted order appears missing | authority revision versus projection | authority/read-your-write/pending UI | freshness below bound |
| zone loss | reduced capacity | topology and survivor saturation | route to provisioned survivors | target met after largest declared loss |
| credential misuse | unauthorized action | policy/audit anomalies | revoke/contain principal, preserve evidence | access removed and affected operations reconciled |
| dual-writer migration | conflicting orders | writer/revision conflict | fence writer authority | one authority and complete reconciliation |

### Overload is a correctness problem

When every layer accepts unlimited work, latency rises, clients time out and retry, queues grow, memory fills and dependency calls multiply. That positive feedback loop can turn a small demand increase into collapse.

Use coordinated controls:

- edge rate limits for abusive or unfair demand;
- bounded concurrency near scarce dependencies;
- short, intentional timeouts derived from the end-to-end budget;
- a retry budget with exponential backoff and jitter;
- load shedding before saturation destroys useful work;
- priority only when classes and starvation behavior are explicit;
- queues only where delayed completion is acceptable and bounded.

The **retry amplification factor** is the number of downstream attempts produced by one user operation. If three layers independently make three attempts, the theoretical worst case is not three; it can be `3 × 3 × 3 = 27` calls. Put retry authority at one appropriate layer.

### Redundancy must survive a named failure

The lab’s fictional capacity model is:

```text
peak demand                      = 12,000 requests/s
headroom                         = 30%
target demand                    = 12,000 × 1.30 = 15,600 requests/s
measured planning rate/instance  = 750 requests/s
healthy instances required       = ceil(15,600 / 750) = 21
failure domains                  = 3
domains the design must lose     = 1
instances per surviving domain   = ceil(21 / 2) = 11
provisioned instances            = 11 × 3 = 33
after one-domain loss            = 22 × 750 = 16,500 requests/s
```

This proves only arithmetic for declared inputs. It assumes even distribution, comparable instances, usable downstream capacity and a trustworthy 750 requests/s planning rate. A benchmark, load test and failure exercise must validate those assumptions.

### Availability is path-dependent

For three independent serial requirements, a simplified estimate is:

```text
Apath = Aedge × Aapi × Adatabase
      = 0.9995 × 0.999 × 0.9995
      = 0.998001 approximately
      = 99.8001%
```

Over a 30-day period:

```text
implied unavailable minutes
  = (1 - 0.998001) × 30 × 24 × 60
  ≈ 86.35 minutes
```

Do not use this as a forecast. Real failures are correlated, maintenance definitions differ, dependencies may be bypassed, retries can mask brief faults and recovery time dominates many incidents. Provider SLA credits are contracts, not observed user availability.

The calculation is still valuable: it exposes an impossible claim early. If leadership requests 99.99% for a serial path whose required components cannot support it, redesign the topology or renegotiate the objective.

### Recovery has more than one clock

Track at least:

- **detection time:** failure begins to useful signal;
- **decision time:** signal to authorized action;
- **restoration time:** action to service availability;
- **data recovery time:** restore/replay to chosen recovery point;
- **reconciliation time:** resolve duplicates, gaps and ambiguous external effects;
- **user recovery time:** correct service and visible state for the user.

A pod restart can reduce restoration time while doing nothing for data correctness. The user-relevant RTO ends only at the recovery condition written into the objective.

The lab models five minutes of recovery-point exposure at 250 acknowledged writes/s:

```text
exposed operations = 250 × 300 = 75,000
```

Those operations are **exposed**, not proven lost. Logs, replicas, external records or reconciliation may recover some or all of them. State the recovery point, then measure restore and reconciliation.

### Threats are adversarial failure scenarios

For each trust boundary ask:

- can an identity be spoofed?
- can payload or state be tampered with?
- can an actor deny a sensitive action without adequate audit?
- can data be disclosed through logs, caches, backups or error messages?
- can resources be exhausted?
- can a principal gain broader authority?

Map controls to the flow: authentication, authorization, input limits, encryption, secret handling, key rotation, audit integrity, isolation, retention and incident response. “Use TLS” is necessary but does not answer authorization, data minimization or compromised credentials.

### Correlated failure defeats naive independence

Independent replicas may share:

- one region, network control plane or DNS path;
- one identity provider;
- one deployment artifact or destructive automation;
- one quota, account or credential;
- one schema migration;
- one human runbook error.

Architecture review must ask “what do these redundant things still share?” The shared element often defines the real blast radius.

## Internals and state ownership

State ownership answers who is allowed to declare a fact true.

### Build a state catalog

| State | Authority | Writer rule | Revision | Derived copies | Reconciliation owner |
|---|---|---|---|---|---|
| order acceptance | order service/database | one transactional writer per order | order version | search, support view | order team |
| publication obligation | transactional outbox | same order transaction | event ID | broker copy | platform + order team |
| payment outcome | payment provider, reflected locally | provider operation identity | provider revision/time | local order status | payments team |
| fulfillment outcome | fulfillment owner | idempotent command | fulfillment revision | customer projection | fulfillment team |
| customer-facing projection | projection service | event-driven derived writer | consumed source revision | cache | experience team |

The word **authority** does not mean one physical database forever. It means the conflict rule is explicit. Multi-leader systems need a conflict protocol, key ownership or consensus semantics—not “both are primary.”

### Authority, durability and availability are different

- **Authority:** which record wins when facts conflict?
- **Durability:** after which acknowledgement should the fact survive the declared failures?
- **Availability:** can the operation be served in the declared environment?

A highly available cache is not authoritative. An authoritative database may be temporarily unavailable. A durable queue can own a processing obligation without owning the final business fact.

### Every derived copy needs a contract

For caches, indexes, projections and replicas define:

- source authority and source revision;
- update mechanism;
- expected and maximum freshness;
- behavior when updates stop;
- replay/bootstrap method;
- deletion and retention propagation;
- read selection rules;
- reconciliation owner and evidence.

If a projection is rebuilt from events, verify that the source retains enough ordered history, schema compatibility and deletion semantics. “We can replay” is a hypothesis until a timed replay succeeds.

### Migration is a temporary architecture

A migration deserves its own state and request paths. Common stages are:

1. expand schemas or contracts compatibly;
2. establish one writer authority;
3. copy/backfill with revision evidence;
4. compare old and new reads;
5. shadow or canary selected operations;
6. switch reads;
7. switch writer authority with fencing;
8. observe and reconcile;
9. remove compatibility only after rollback policy expires.

Dual writing from application code creates partial-success ambiguity. If unavoidable, declare which system is authoritative, make each write idempotent and run continuous reconciliation. Never merge conflicting records by timestamp alone; clocks and business meaning do not provide a safe universal winner.

### Schema and event evolution

Compatibility is directional:

- backward compatible: new reader can read old data;
- forward compatible: old reader can read new data;
- full compatible: both directions under the stated rules.

During rolling deployment, old and new producers/consumers coexist. Prefer additive fields, tolerant readers and explicit version/removal windows. Test replay of historical messages against candidate consumers. Schema registry approval cannot prove business-semantic compatibility.

## Evidence table

Architecture claims need receipts. Different artifacts prove different things.

| Claim | Candidate evidence | What it proves | What it cannot prove |
|---|---|---|---|
| peak is 12k RPS | dated production query with definition | observed sample under named filters | future growth or correctness of instrumentation |
| one instance supports 750 RPS | reproducible representative load test | behavior in that environment and workload | production capacity under all failures |
| zone loss is tolerated | controlled failure exercise | observed response for tested topology | region/provider/common-control-plane failure |
| RPO is five minutes | backup configuration plus restore drill | configured policy and achieved drill point | every future recovery |
| API is idempotent | concurrent retry tests plus storage constraints | tested duplicate behavior | all downstream side effects unless included |
| design decision was approved | accepted ADR | accountable decision and rationale | implementation conformance |
| deployment follows design | topology/config inspection and policy tests | sampled conformance | runtime correctness |
| SLO is met | valid user-journey SLI over window | observed objective performance | absence of unmeasured harm |

Use an evidence register:

| ID | Claim | Source/experiment | Environment and time | Result | Limits | Owner | Recheck trigger |
|---|---|---|---|---|---|---|---|
| E-01 | survivor capacity ≥ 15.6k RPS | zone-loss load test | staging-equivalent, date | pending | dependency quotas not yet tested | performance owner | instance/runtime change |

Separate four states:

- **declared:** a stakeholder or contract says it is required;
- **calculated:** a model produces it from explicit inputs;
- **tested:** a bounded experiment observed it;
- **observed:** production telemetry measured it.

Do not label a calculated number “validated.” Do not label a successful test “guaranteed.”

## Command decoders

The lab is deliberately offline. It teaches evidence discipline without pretending that fictional JSON represents production. Run it as a normal Ubuntu user from:

```bash
cd drafts/LES-0082-architecture-system-design-foundations/support/lab
```

Do not use `sudo`. The guard refuses root because root would weaken ownership and cleanup evidence.

### 1. Decode `bash lab.sh doctor`

This checks Bash/Python prerequisites, fixture schemas, model gates, absence of cloud credentials/runtime endpoints and authority boundaries. Expected key line:

```text
doctor=pass network=none user=1000 runtime_calls=none
```

Your numeric UID may differ if the lab contract allows it; the tested environment uses UID 1000. This proves the offline shell is internally ready. It does not prove the architecture is suitable.

### 2. Decode `bash lab.sh setup`

Setup creates one UID-scoped temporary state root and copies allowlisted fictional fixtures. It refuses symlinks, wrong ownership, unknown files, root and runtime authority.

```text
setup=pass ...
```

Mutation is bounded to the printed temporary root. If setup refuses, preserve the first reason. Never bypass the guard with `sudo` or by weakening checks.

### 3. Decode `bash lab.sh status`

Status prints the design identity and case inventory:

```text
cases=67 gates=66 calculations=5
```

There is one passing baseline plus one deliberately failing case for each of 66 gates. This proves fixture identity, not requirement correctness.

### 4. Decode `bash lab.sh map`

Map prints the fictional user operation, authority, trust crossings and failure domains. For every relationship, say aloud:

> initiator, receiver, protocol, identity, acknowledgement, timeout, retry owner, state change and failure effect.

If an answer is absent, record a design unknown. The command reports declared data; it does not inspect a deployment.

### 5. Decode `bash lab.sh capacity`

Expected values include target `15600` RPS, `21` healthy instances, `11` per domain, `33` provisioned and `16500` RPS after one-domain loss. Recalculate by hand using the equations in Failure zoom.

Then challenge the model: Is 750 RPS measured at the required latency? Does database capacity survive? Is traffic redistributed fast enough? Is 30% headroom policy or evidence?

### 6. Decode `bash lab.sh availability`

Expected composite is approximately `99.8001%` and `86.35` implied unavailable minutes over 30 days. The output explicitly states independence. If components share failure causes, multiplication is not a reliable predictor.

The lesson is not “multiply every SLA.” The lesson is “map the required path and expose unsupported objectives.”

### 7. Decode `bash lab.sh backlog`

The fixture has burst arrival 700 items/s, service 500 items/s for 120 seconds:

```text
backlog = (700 - 500) × 120 = 24,000 items
peak oldest age ≈ 24,000 / 500 = 48 seconds
```

Recovery service is 650 while normal arrival is 400:

```text
drain = 24,000 / (650 - 400) = 96 seconds
```

The same command reports 75,000 operations inside a five-minute RPO exposure. It does not declare them lost.

### 8. Decode `bash lab.sh latency`

The component budget is:

```text
edge 40 + API 90 + database 110 + reserve/other 60 = 300 ms
```

It exactly consumes a 300 ms target, leaving zero unallocated margin. `closes=true` means the arithmetic does not exceed the target. Zero margin is a warning: queueing, network variance and measurement overhead still exist.

Do not add unrelated p99 values and call the result an observed end-to-end p99. Component percentiles do not compose that simply. The budget is an allocation to test.

### 9. Decode `bash lab.sh tradeoff`

The fictional weighted scores are 3.20 for synchronous coupling and 3.60 for durable asynchronous work. The output says `human-review-required`.

A score communicates assumptions; it does not authorize the decision. Test:

- Is either option vetoed by a hard constraint?
- Who chose weights?
- How much must one weight/score change to reverse the rank?
- Are uncertainties hidden behind precise decimals?
- What operational burden is missing?

### 10. Decode requirement-boundary evaluation

```bash
bash lab.sh evaluate requirements-ambiguous-or-unmeasurable
```

The expected boundary is `requirements`. An attractive topology cannot close an undefined target. Rewrite the requirement using source, stimulus, environment, artifact, response and measure.

### 11. Decode state-authority evaluation

```bash
bash lab.sh evaluate state-owner-or-writer-authority-unbound
```

The expected boundary is `state-owner`. More boxes or arrows cannot establish writer authority. Bind writer, revision, acknowledgement, conflict and reconciliation rules.

### 12. Decode `bash verify.sh`

Run verification from absent lab state. It executes the full lifecycle, all 67 cases, all calculations, refusal tests and exact cleanup:

```text
verify=pass cases=67 calculations=5 refusal=true cleanup=true runtime_calls=none
```

This proves deterministic lab behavior in its tested boundary. It does not prove your architecture judgment or production readiness.

## Decision path

Use this sequence in design work and interviews.

1. **Bind the decision.** Write owner, deadline, affected users, business outcome, scope and non-goals.
2. **Discover requirements.** Separate functions, quality scenarios, assumptions, constraints and unknowns.
3. **Quantify the envelope.** Estimate steady/peak/burst/growth traffic, data, concurrency, latency, recovery and cost units.
4. **Map current and proposed systems.** Draw context, containers, one critical operation, state ownership, trust and deployment.
5. **Write invariants.** Examples: one accepted operation creates at most one order; no unauthorized tenant crosses isolation; acknowledged state meets the recovery contract.
6. **Locate risks.** Exercise overload, dependency loss, domain loss, ambiguity, replay, abuse, migration and operator error.
7. **Generate credible alternatives.** Include status quo and simpler options, not one preferred design plus two strawmen.
8. **Apply veto constraints first.** Security, regulatory, correctness or recovery constraints can make an option infeasible.
9. **Compare trade-offs and sensitivity.** Show benefits, costs, uncertainties and what would reverse the decision.
10. **Record the decision.** Create an ADR with status, context, decision, options, consequences, owner and supersession rule.
11. **Plan validation and migration.** Bind hypotheses to tests, acceptance thresholds, compatibility, canary, stop, rollback and reconciliation.
12. **Review after evidence changes.** Capacity, threat, cost and organizational assumptions expire.

### Write measurable quality scenarios

Use this template:

| Field | Checkout example |
|---|---|
| source | legitimate customer population |
| stimulus | peak checkout requests plus one-zone loss |
| environment | seasonal peak, one zone unavailable |
| artifact | checkout user journey |
| response | accept within budget or reject explicitly without duplicate order |
| measure | p99 accepted latency ≤ 300 ms, error ≤ agreed target, one order per operation ID |

One scenario can contain several measures, but each must have an unambiguous event, population, window and data source.

### Compare alternatives honestly

For every option record:

- short description and assumptions;
- requirements satisfied or missed;
- correctness and consistency semantics;
- reliability and recovery behavior;
- security/privacy effects;
- operational complexity and skills;
- migration and reversibility;
- cost range and largest drivers;
- unknowns and validation experiments.

Weighted matrices can assist discussion after hard constraints. Keep raw evidence visible. A score of 3.60 versus 3.20 is not meaningful if inputs are guesses with ±1 uncertainty.

### Minimal ADR

```markdown
# ADR-042: Publish accepted orders through a transactional outbox
Status: Proposed
Owner: Checkout team
Date: YYYY-MM-DD
Review trigger: database/queue platform change or measured completion breach

## Context
One accepted order must create durable fulfillment work despite process failure.

## Decision drivers
- no untracked database-to-broker gap
- bounded customer acknowledgement
- replay and audit

## Options
1. publish after database commit
2. publish before database commit
3. transactional outbox and idempotent consumers

## Decision
Choose option 3 under the stated database and polling assumptions.

## Consequences
Positive: durable visible obligation and replay.
Negative: publication lag, duplicate delivery, outbox operations and cleanup.

## Validation
Crash-point tests, duplicate-delivery tests, oldest-unpublished alert and replay drill.
```

An ADR should be short enough to read and complete enough to recover the reasoning. When context changes, supersede it; do not erase history.

## Guided Ubuntu lab

This lab is a design-review simulator, not a deployment. It runs on Ubuntu 24.04 with Bash and Python 3, uses fictional JSON, makes no network calls and refuses runtime authority.

### Safety contract

Before starting:

- use a normal user, never root or `sudo`;
- remove/export no cloud credentials for this shell;
- do not point fixtures at an employer or production design;
- expect only one printed UID-scoped temporary directory;
- stop on the first refusal;
- run cleanup and prove absence when finished.

The lab refuses cloud credential variables, runtime endpoints, Docker/Kubernetes authority, symlinks, wrong ownership and unknown artifacts. The guard is part of the lesson: evidence gathered with uncontrolled authority is harder to trust.

### Exercise A: prove the shell boundary

```bash
cd drafts/LES-0082-architecture-system-design-foundations/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Record:

1. the user identity;
2. network/runtime call count;
3. design ID;
4. number of cases, gates and calculations;
5. exact temporary root.

Expected interpretation: the fixture and analysis engine are ready; no architecture claim has yet been validated.

### Exercise B: reconstruct the operation

```bash
bash lab.sh map
```

Without looking back at this chapter, write a table:

| Hop | Initiator → receiver | Identity | State/obligation | Acknowledgement | Failure response |
|---|---|---|---|---|---|

Mark the authoritative order commit, the outbox obligation, the broker acknowledgement, the consumer checkpoint and the external-provider outcome. Circle every point where a timeout can create ambiguity.

Then answer:

1. Why is the operation ID different from the trace ID?
2. What gap does the outbox close?
3. Why can duplicate delivery still occur?
4. Who is allowed to retry an ambiguous provider command?
5. Which read path tells a customer the truth immediately after acceptance?

Do not continue until each answer names an owner or mechanism, not just a product.

### Exercise C: calculate and challenge capacity

```bash
bash lab.sh capacity
```

Recalculate the five output values by hand. Then change one input only in a paper copy:

- per-instance capacity falls from 750 to 600 RPS; or
- failure tolerance changes from one domain to two; or
- headroom rises from 30% to 50%.

Explain which result changes and why. Do not edit the canonical fixture merely to obtain a passing result.

The senior question is not “did the script say reserve=true?” It is “what evidence makes each input believable, and which dependency becomes limiting first?”

### Exercise D: challenge availability assumptions

```bash
bash lab.sh availability
```

Write the serial equation and the 30-day conversion. Then list three correlated failures that violate independence. Examples: one regional network path, one identity provider, or one deployment that breaks API and database compatibility.

Finally, propose one response for each:

- remove a dependency from the synchronous success path;
- provide a safe degraded path;
- reduce detection/recovery time;
- improve redundancy across the actual shared failure domain.

Do not simply increase the target percentages.

### Exercise E: make queue delay visible

```bash
bash lab.sh backlog
```

Confirm 24,000 items, 48 seconds peak age and 96 seconds drain. Draw a timeline:

```text
0s                         120s                              216s
| burst: +200 items/s       | recovery drain: 250 items/s     |
| backlog 0 → 24,000        | backlog 24,000 → 0              |
```

Now answer: if the API enqueue latency is 20 ms but fulfillment completes 10 minutes late, which SLI is green and which user journey is failing? The correct design observes both admission and completion.

### Exercise F: allocate latency

```bash
bash lab.sh latency
```

The sum closes with zero spare budget. Create a better proposal with explicit margin; for example, allocate no more than 270 ms and reserve 30 ms for unmodeled variation. This is an allocation hypothesis, not permission to ignore an end-to-end measurement.

State where queueing time is measured. Service time without queueing can appear healthy while saturation drives user latency.

### Exercise G: inspect trade-off sensitivity

```bash
bash lab.sh tradeoff
```

The asynchronous option ranks higher under fictional weights. Find the smallest plausible change to weights or scores that reverses the result. Then identify:

- one hard veto constraint;
- one uncertain assumption;
- one validation experiment;
- one operational consequence;
- the accountable human decision owner.

If you cannot reverse a weighted result under any plausible change, check whether the matrix was built to justify a predetermined choice.

### Exercise H: investigate two rejected designs

```bash
bash lab.sh evaluate requirements-ambiguous-or-unmeasurable
bash lab.sh evaluate state-owner-or-writer-authority-unbound
```

For the requirements failure, rewrite one complete quality scenario. For the state-owner failure, create a state catalog row with authority, writer, revision, acknowledgement and reconciliation owner.

### Exercise I: verify and clean

First clean the guided state:

```bash
bash lab.sh cleanup
```

Then run the verifier from absent state:

```bash
bash verify.sh
```

Accept only the exact pass contract:

```text
verify=pass cases=67 calculations=5 refusal=true cleanup=true runtime_calls=none
```

If verification fails, preserve the first failure line, run `bash lab.sh status` if allowed and correct the cause. Do not delete broad temporary directories.

### Lab evidence to retain

Retain a small, sanitized worksheet:

- commands and exact outputs;
- handwritten/recomputed equations;
- one operation/path table;
- one state catalog;
- three challenged assumptions;
- one alternative sensitivity;
- one proposed ADR;
- cleanup proof.

The evidence shows that you performed a bounded review. It does not award mastery; that requires unfamiliar transfer reviewed against the rubric.

## Production transfer

Do not copy the fictional numbers into production. Transfer the method.

### Read-only discovery packet

With organizational authorization, collect:

- business operation and criticality;
- product/service ownership and escalation contacts;
- current context/container/deployment views;
- API/event schemas and compatibility policy;
- authoritative/derived state catalog;
- 30/90-day workload distributions with query definitions;
- SLO/SLI definitions and missing-data behavior;
- dependency/failure-domain inventory;
- recent incidents, recovery drills and capacity tests;
- threat model, data classification and retention constraints;
- current ADRs, exceptions and migration plans;
- cost units and major drivers.

Sanitize customer data, internal URLs, credentials and employer-confidential architecture before using any external assistant or personal repository.

### Separate observation from mutation

Architecture discovery is usually read-only. Deployment, load, fault injection, failover, restore, policy change and traffic movement require separate authority, rollback and change windows.

Use this progression:

1. inspect documented and observed state;
2. reproduce the model in a disposable representative environment;
3. validate one hypothesis with bounded load/fault/security tests;
4. review evidence and risks;
5. obtain change authorization;
6. canary with stop conditions;
7. expand gradually;
8. reconcile state and retain receipts.

### Production-readiness evidence

Before launch, require owners and evidence for:

- service and user-journey SLOs;
- capacity after the largest declared failure;
- dependency timeouts, retries and circuit behavior;
- admission, load shedding and queue bounds;
- idempotency and ambiguous outcomes;
- schema compatibility and rollback/forward recovery;
- backup, restore, replay and reconciliation;
- identity, authorization, secret/key lifecycle and audit;
- data minimization, residency, retention and deletion;
- telemetry coverage, alert quality and missing-data behavior;
- dashboards/runbooks/on-call ownership;
- deployment canary, stop and rollback conditions;
- cost envelope and budget alarms;
- known risks, accepted exceptions and review dates.

Green health checks do not close these items. Attach dated evidence.

### Migration and release safety

A safe rollout defines:

- **compatibility window:** which old/new producers and consumers coexist;
- **canary population:** enough to reveal risk without excessive blast radius;
- **leading signals:** errors, latency, saturation, state divergence, security denials;
- **stop threshold:** objective condition that halts expansion;
- **rollback feasibility:** whether old code understands new state;
- **forward recovery:** how to repair when rollback would worsen data;
- **reconciliation:** how to prove no entity or obligation was skipped/duplicated.

Database and event changes often make binary rollback unsafe. Expand/contract schemas and forward repair may be the correct strategy.

### Architecture review meeting that produces decisions

Send the packet before the meeting. During review:

1. restate decision and veto constraints;
2. walk one user operation;
3. challenge workload math;
4. inspect state/trust/failure boundaries;
5. exercise top failure and threat scenarios;
6. compare alternatives and sensitivity;
7. assign unknowns to experiments;
8. record decision owner and due dates.

Meeting attendance is not approval. Preserve decisions in ADRs and actions in an owned tracker.

## Reliability, security, observability, capacity, and cost

These properties interact. Optimize them together around the user operation.

### Reliability

Reliability design begins with invariants and failure modes:

- define what an accepted operation guarantees;
- remove unnecessary synchronous dependencies;
- isolate failure domains and tenants;
- bound waiting, retries, concurrency and backlog;
- degrade deliberately;
- make recovery and reconciliation testable;
- use error budgets to connect objectives with change risk.

Redundancy without tested failover can add components and correlated complexity without improving user reliability.

### Security and privacy

Security architecture follows identities and data:

- authenticate workloads and people;
- authorize each operation at the resource boundary;
- minimize privileges and credential lifetime;
- validate at every trust transition;
- encrypt in transit/at rest and own key rotation;
- minimize collection and observability payloads;
- define residency, retention, deletion and backup treatment;
- protect audit evidence from tampering;
- rehearse containment and credential revocation.

Privacy changes observability: a trace must correlate work without copying payment details or credentials. Redaction after ingestion may be too late.

### Observability

Design telemetry from questions:

| Question | Useful signal |
|---|---|
| Can users place orders? | valid/total user-journey events |
| Where is time spent? | trace spans plus queue wait and service time |
| Is durable work falling behind? | oldest unpublished/event age and drain rate |
| Are retries amplifying? | attempts per operation ID |
| Are projections stale? | source versus applied revision and age |
| Is one tenant harmed? | privacy-safe tenant/service-level segmentation |
| Did recovery finish? | authority/reconciliation differences and outstanding obligations |

Define missing-data behavior. “No errors” is meaningless if telemetry stopped.

Cardinality is an architectural constraint. Do not put raw user/order IDs into unbounded metric labels. Keep high-cardinality detail in appropriately protected logs/traces and aggregate metrics.

### Capacity and performance

Capacity planning connects:

```text
demand → concurrency → service/queue time → resource saturation → user latency
```

Little’s Law, under a stable system and consistent units, is:

```text
L = λW
```

If average arrival is 1,000 requests/s and average time in system is 0.2 s, average in-flight work is about 200. This does not describe tail latency, burst transients or an unstable queue.

Plan for the largest declared failure and downstream limits. CPU headroom is irrelevant if database connections, provider quota or partition hotspots saturate first.

### Cost and sustainability

Model units instead of one monthly total:

- compute instance/pod hours;
- storage capacity, operations and retention;
- database read/write/replication units;
- queue requests and retained bytes;
- network egress and cross-zone/region traffic;
- observability ingestion, indexing and retention;
- licenses and support;
- engineering migration/on-call cost;
- expected incident impact range.

The cheapest steady-state topology can be expensive after incidents, manual operations and recovery are included. Conversely, duplicating every component “for reliability” can waste resources and create state complexity.

### Trade-off examples

| Decision | Improves | Can worsen | Required evidence |
|---|---|---|---|
| synchronous cross-region write | recovery-point exposure | latency, availability, cost | latency/failure test and consistency contract |
| asynchronous queue | admission isolation, replay | freshness, duplicates, operations | backlog/age/drain and idempotency tests |
| cache | latency, origin capacity | freshness, invalidation, privacy | hit ratio, staleness and deletion propagation |
| aggressive retry | brief transient success | overload, duplicates, cost | attempt budget and amplification |
| detailed tracing | diagnosis | cost, cardinality, sensitive data | sampling/privacy/retention design |
| multi-region active-active | regional availability | conflict, deployment, cost | writer/conflict and failover/reconciliation drills |

## Traps and prevention

### Trap: technology before the operation

**Signal:** the design starts with Kubernetes, Kafka or a database but cannot state the user promise.
**Prevention:** bind the decision, operation, measurable scenarios and state authority first.

### Trap: one enormous diagram

**Signal:** people, classes, pods, regions and tables share one canvas.
**Prevention:** split context, container, dynamic, deployment, state and trust views; keep equivalent text.

### Trap: averages hide pain

**Signal:** average latency and daily traffic are inside target while peak users fail.
**Prevention:** distributions, percentiles, bursts, cohorts, queue age and failure environments.

### Trap: SLA arithmetic becomes a promise

**Signal:** provider marketing percentages are averaged or multiplied without topology/correlation.
**Prevention:** model the required user path, observed SLIs, redundancy, shared failures and recovery.

### Trap: queue means infinite safety

**Signal:** enqueue is healthy while oldest age grows without bound.
**Prevention:** arrival/service/drain envelope, retention, admission, completion SLO and replay test.

### Trap: “exactly once”

**Signal:** a broker setting is assumed to prevent duplicate business effects across databases/providers.
**Prevention:** stable identities, atomic local transitions, idempotent effects and reconciliation.

### Trap: dual writers during migration

**Signal:** both systems accept writes and conflicts are merged later by timestamp.
**Prevention:** fence one authority, version writes, compare continuously and define rollback/forward repair.

### Trap: timeout means failure

**Signal:** every timeout causes a fresh payment/order operation.
**Prevention:** treat outcome as unknown; query/reconcile using the same operation identity.

### Trap: score selects the architecture

**Signal:** the highest weighted total overrides a regulatory or correctness requirement.
**Prevention:** apply veto constraints first, expose sensitivity and retain accountable human judgment.

### Trap: ADR written after implementation

**Signal:** the record rationalizes an irreversible choice and omits alternatives.
**Prevention:** record significant decisions while options remain real; supersede rather than rewrite history.

### Trap: test environment proves production

**Signal:** one synthetic load test is called “production capacity.”
**Prevention:** state environment, workload, limits and uncertainty; validate progressively and observe production.

### Trap: recovery stops when service starts

**Signal:** pods are ready but queues, projections and external outcomes disagree.
**Prevention:** recovery objective includes restore, drain, replay, reconciliation and user-visible correctness.

### Trap: observability leaks data

**Signal:** tokens, payment fields or personal identifiers appear in logs/traces.
**Prevention:** data classification, collection minimization, safe correlation, access control and retention at design time.

### Prevention checklist

Before implementation, confirm:

- decision and owner are explicit;
- every important quality has a measurable scenario;
- calculations include units, source, assumption and sensitivity;
- views use consistent abstraction;
- every state has authority and reconciliation;
- acknowledgements/retries/ambiguity are specified;
- trust and failure domains are visible;
- alternatives include status quo and simpler choices;
- hard constraints cannot be averaged away;
- migration/recovery evidence has owners;
- ADR and tests can falsify the design.

## Memory card and retrieval

### One-page memory card

```text
SYSTEM DESIGN = a defensible decision, not a box collection

SCOPE
  decision • owner • user operation • outcome • boundary • non-goals
  requirements • constraints • assumptions • unknowns

CALCULATE
  steady/peak/burst/growth • bytes • concurrency • geography
  latency budget • headroom • largest-failure reserve
  availability path • queue growth/drain • RPO/RTO • cost units

ARCHITECT
  C4 context/container/dynamic/deployment
  state authority/revision/reconciliation
  identity/trust/data • protocol/ack/timeout/retry

LOCATE RISKS
  overload • dependency/domain loss • ambiguity • duplicates/order
  stale state • abuse • migration coexistence • recovery/operator error

EXPLAIN
  alternatives • vetoes • sensitivity • consequences • residual owner
  ADR • validation • migration • canary/stop/rollback • review trigger

WHEN AN INCIDENT HAPPENS
  Which user operation?
  Last durable acknowledgement?
  Current authority?
  Retry authority?
  Blast radius/shared failure?
  Backlog/oldest age?
  Safe degradation?
  Reconciliation and recovery proof?
```

### Retrieval questions

Answer without looking back. Explanation matters more than vocabulary.

1. Why is architecture a model rather than the running system?
2. What six fields make a quality-attribute scenario testable?
3. When do you use C4 context, container, component, dynamic and deployment views?
4. Why is a C4 container not necessarily a Docker container?
5. What is the difference between an operation ID, trace ID, entity ID and event ID?
6. What does a successful checkout acknowledgement guarantee in this design?
7. Why does a transactional outbox not create exactly-once business execution?
8. What does timeout mean, and what must happen after an ambiguous payment timeout?
9. How do authoritative and derived state differ?
10. At 700 arrivals/s and 500 services/s for 120 seconds, what backlog and approximate oldest age result?
11. Why must recovery service exceed normal arrival rate to drain a queue?
12. How is failure-aware capacity different from healthy capacity?
13. Why is serial availability multiplication useful yet dangerous?
14. What are RPO and RTO, and why are “exposed” operations not automatically lost?
15. Why can retries cause multiplicative overload?
16. What is a veto constraint, and why must it be applied before weighted scoring?
17. What evidence does an ADR provide, and what does it not prove?
18. Why is a migration a temporary architecture?
19. What proves recovery beyond green health checks?
20. Walk through SCALE for an unfamiliar service.

## Complete answers

### 1. Architecture is a model

An architecture artifact selects facts about a system so people can make a decision. A diagram or ADR is not executing requests, holding state or experiencing failure. It may also become stale. Therefore it proves what was declared and decided at a time, while runtime/configuration inspection, tests, drills and telemetry provide conformance and behavior evidence. A senior engineer keeps the model linked to dated receipts and revises it when they diverge.

### 2. Testable quality scenario

The six fields are **stimulus source, stimulus, environment, affected artifact, response and response measure**. “Fast under load” omits who creates load, what load means, which path is affected and how acceptance is measured. A complete version names peak legitimate customers, one-zone loss, checkout path, bounded acceptance/rejection behavior and numeric latency/error/correctness thresholds.

### 3. Selecting C4 views

Use **context** for people, the system boundary and external systems. Use **container** for major runnable/deployable responsibilities, protocols and data stores. Use **component** only to explain important internals of one container. Use **dynamic** for the ordered interactions of one scenario. Use **deployment** for instances, nodes and failure domains. Keep levels separate so the reader knows whether an arrow represents an organizational dependency, service call or internal function.

### 4. C4 container versus Docker container

A C4 container is an application or data store that runs or stores data as a unit in the architecture model. It may be a web app, mobile app, database or server application. A Docker container is an operating-system-level packaging/runtime mechanism. A C4 container may run in Docker, several Docker containers or no Docker at all.

### 5. Identities

An **operation ID** represents one business intent across retries. A **trace ID** represents propagation of one distributed attempt or trace. An **entity ID** names a durable business object such as an order. An **event ID** names one durable message/publication. Keeping them distinct allows operators to answer whether multiple traces belong to one intent, whether an entity was created, and whether the same message was redelivered.

### 6. Checkout acknowledgement

In the fictional design, a successful API response is sent after one transaction durably records both the authoritative accepted order and an outbox obligation. It guarantees neither payment completion nor fulfillment. The response returns an order identity so the client can query truth after a lost response. The exact durability still depends on the database’s acknowledged-commit configuration and declared failure model.

### 7. Outbox and duplicates

The outbox closes the untracked gap between committing local state and remembering to publish. The publisher can crash after broker acceptance but before recording publication, so it may publish again. A consumer can crash after a side effect but before checkpointing, so delivery may repeat. Stable event/operation identities, idempotent handlers and reconciliation are still required. Independent systems do not share one magical atomic transaction.

### 8. Ambiguous timeout

A timeout means an observer did not receive a response before its deadline. The remote action may have failed, may still be executing or may have succeeded. After an ambiguous payment timeout, reuse the provider operation/idempotency identity, mark local state pending or unknown, query/receive authoritative provider status and reconcile. Starting a new payment identity risks a duplicate charge.

### 9. Authoritative versus derived state

Authoritative state is permitted to decide the business fact under an explicit conflict rule. Derived state is calculated or copied for another purpose, such as search, caching or analytics. Derived state needs a source revision, freshness target, replay/bootstrap path and reconciliation owner. High availability of a cache does not make it authoritative.

### 10. Backlog calculation

Backlog growth is `700 - 500 = 200` items/s. Over 120 seconds, `200 × 120 = 24,000` items accumulate. At 500 services/s, a simple peak-age approximation is `24,000 / 500 = 48` seconds. The approximation assumes homogeneous work and stable rate; actual oldest age should be measured from message timestamps.

### 11. Drain capacity

Normal arrivals continue during recovery. If recovery service equals normal arrival, new work consumes all capacity and the old backlog never shrinks. Net drain is `μ_recovery - λ_normal`. With 650 service and 400 normal arrival, net drain is 250 items/s, so 24,000 items drain in 96 seconds.

### 12. Failure-aware capacity

Healthy capacity asks whether all provisioned instances cover demand. Failure-aware capacity asks whether the survivors after the largest declared failure cover demand plus required headroom. In the fixture, 21 healthy-equivalent instances are needed, but distributing 11 into each of three domains provisions 33 so that 22 survivors still provide 16,500 RPS after one domain is lost.

### 13. Availability multiplication

Multiplication is useful for a required serial path because every required component must be available, revealing that component targets may not support the promised path target. It is dangerous when treated as a forecast: failures can be correlated; retries, failover and degraded paths change topology; definitions/windows differ; and restoration affects outcomes. Use it as a model with explicit assumptions, then validate with user-journey SLIs and failure evidence.

### 14. RPO, RTO and exposure

RPO is the maximum acceptable point-in-time data gap relative to an incident; RTO is the maximum acceptable time to restore the defined business capability. A five-minute gap at 250 writes/s exposes 75,000 operations. They are not automatically lost because replicas, logs, provider records or reconciliation may recover them. Only restore/reconciliation evidence establishes the actual outcome.

### 15. Retry amplification

If several layers retry independently, one failed user operation fans out. Three attempts at client, service and dependency layers can create up to 27 dependency calls. Those calls increase saturation, produce more timeouts and trigger more retries. Assign retry authority, use attempt/time budgets, exponential backoff with jitter, and stop retrying non-transient or ambiguous side effects blindly.

### 16. Veto constraints

A veto constraint is a non-negotiable feasibility condition, such as a legal residency rule, correctness invariant, security boundary or recovery requirement. Weighted scores trade preferences against each other; they must not allow excellent cost to compensate for violating law or correctness. Reject infeasible options first, then score and analyze sensitivity among viable options.

### 17. ADR evidence

An ADR proves that a named decision, context, alternatives, consequences, status and owner were recorded. It helps future engineers understand why a choice was reasonable. It does not prove the code conforms, the assumptions remain true or the design behaves correctly. Link tests, policy checks, topology evidence and review triggers.

### 18. Migration as architecture

During migration, old and new versions, schemas, routes and state copies coexist. That topology has unique writer authority, compatibility, duplication, rollback and reconciliation risks. Treating migration as a script ignores its operational lifetime. Model its stages and transitions, including what happens if the process pauses halfway.

### 19. Complete recovery proof

Green health checks show that processes respond to a configured probe. Recovery proof also shows authoritative data at the selected recovery point, replayed durable obligations, drained queues within target, reconciled duplicates/gaps/external effects, restored security controls and correct user-visible outcomes. Evidence should be dated and tied to the incident or drill.

### 20. SCALE walkthrough

First scope the unfamiliar service: user operation, outcome, owner, boundary, non-goals, requirements, constraints and unknowns. Calculate traffic/data/recovery/cost envelopes with units and sensitivity. Architect context/container/dynamic/deployment plus state/trust views. Locate overload, dependency, domain, ambiguity, threat, migration and operator risks. Explain feasible alternatives, vetoes, consequences and residual risks in an ADR. Validate hypotheses and loop observed evidence back into assumptions.

### Guided-lab answer key

**Why operation ID differs from trace ID:** one business intent can have multiple network attempts/traces; deduplication must follow intent.
**Gap closed by outbox:** durable local commit versus durable publication obligation.
**Why duplicates remain:** acknowledgement loss and crash/replay can repeat publish or consumption.
**Who retries ambiguous provider work:** one explicitly designated owner using the same provider identity after checking/reconciling status.
**Immediate truthful read:** the authority or a read-your-write path with a known revision; otherwise expose pending and bounded freshness.

**Green enqueue versus failing fulfillment:** admission latency SLI is green, but the end-to-end order-completion SLI is failing. Both must exist.
**Zero latency margin:** the arithmetic fits but the allocation is fragile; test end-to-end percentiles and reserve variation budget.
**Attractive design with vague requirement:** it remains unreviewable because no acceptance boundary exists.
**Diagram with no writer authority:** it remains unsafe because a box does not define conflict, commit or reconciliation semantics.

## Product-company interview

Interviewers are evaluating how you reduce ambiguity, quantify assumptions, preserve correctness and defend trade-offs. Say assumptions aloud. Do not race to name products.

### Scenario 1: “Design checkout for a global marketplace”

**Strong opening:** “I’ll first bind the operation and promises. Is checkout authorization or final settlement in scope? What peak/burst geography, latency, availability, RPO/RTO, payment regulations and inventory consistency matter? I’ll model one place-order path, then capacity and failure behavior.”

**Model direction:** establish operation identity; authoritative order commit; idempotency; payment ambiguity; transactional outbox; bounded asynchronous fulfillment; state/trust/failure-domain views; end-to-end completion SLI.

**Weak answer:** “Use Kubernetes, Kafka, Redis and multi-region databases.”
**Why weak:** products appear before requirements, ownership and consistency.

**Follow-up:** “The client times out after payment.”
**Answer:** timeout is unknown outcome. Query/reconcile using the same operation/provider identity; never create a new charge blindly.

### Scenario 2: “Estimate capacity”

**Strong answer:** state units and assumptions. Example: “Peak is 12k RPS, 30% headroom gives 15.6k. A representative test at the required p99 yields 750 RPS/instance, so 21 healthy equivalents. To survive one of three equal domains, put 11 in each, 33 total; 22 survivors provide 16.5k. I still need database, quota and redistribution evidence.”

**Weak answer:** divide traffic by CPU or choose an instance count without headroom/failure.
**Follow-up:** “What if traffic is uneven?”
**Answer:** model hotspot key/region/tenant distributions, not just aggregate RPS; test routing and rebalance time.

### Scenario 3: “Guarantee exactly once”

**Strong answer:** ask exactly once at which boundary. A broker may deduplicate or transact within its scope, but a database plus external payment side effect still needs stable identities, atomic local transitions, idempotent operations and reconciliation.

**Weak answer:** enable an “exactly-once” broker setting.
**Follow-up:** “Consumer charged the card then crashed.”
**Answer:** repeat with the same provider idempotency identity or reconcile provider status before any new action; checkpoint only according to the business transition.

### Scenario 4: “Design for 99.99%”

**Strong answer:** define the valid event, population and window; map required dependencies; distinguish availability from durability; identify correlated failures and recovery; calculate a first-order path model; then propose topology/degradation and validate with user-journey SLIs and drills.

**Weak answer:** deploy three replicas and quote provider SLAs.
**Follow-up:** “Three dependencies are each 99.9%.”
**Answer:** if all are required and independent, serial availability is roughly 99.7%, so the requested objective is unsupported without changing the path or targets. Real correlation makes simple math insufficient.

### Scenario 5: “Queue depth keeps growing”

**Strong answer:** inspect arrival rate, service rate, oldest age, retry amplification, poison messages, partition skew and downstream saturation. Bound admission, stop retry amplification, restore net drain capacity and protect downstream systems. Communicate completion impact.

**Weak answer:** add consumers immediately.
**Why weak:** downstream capacity or partitioning may prevent scaling and make overload worse.

**Follow-up:** “How long to recover?”
**Answer:** `backlog / (recovery service - normal arrival)` when rates are stable and net drain is positive; validate using oldest-age telemetry.

### Scenario 6: “Active-active multi-region orders”

**Strong answer:** first ask whether writes for one order must occur in multiple regions simultaneously. Prefer home-region/key ownership when it satisfies requirements. If true multi-writer is required, define conflict semantics, fencing, global identity, dependency locality, RPO/RTO, failover/failback and reconciliation.

**Weak answer:** “Use a globally distributed database.”
**Follow-up:** “Network partition occurs.”
**Answer:** state which operations remain available, which consistency invariant is preserved and how conflicting/ambiguous writes reconcile; there is no free simultaneous consistency and partition availability for the same fact.

### Scenario 7: “Migrate the order database with zero downtime”

**Strong answer:** define zero downtime precisely, use expand/contract compatibility, establish writer authority, backfill with revisions, shadow/compare reads, canary, fence cutover, observe and reconcile. Plan forward recovery because schema/state changes can make binary rollback unsafe.

**Weak answer:** dual-write both databases and switch DNS.
**Follow-up:** “One write succeeds and one fails.”
**Answer:** the predeclared authority decides truth; retry idempotently and reconcile. Do not choose by timestamp.

### Scenario 8: “Secure a multi-tenant API”

**Strong answer:** map principal/workload identities and tenant ownership; authenticate at entry, authorize each resource action, propagate constrained identity, enforce tenant isolation at query/storage boundaries, minimize sensitive data, rotate secrets/keys, protect audit trails and test cross-tenant denial.

**Weak answer:** use TLS and JWT.
**Why weak:** those mechanisms do not establish resource authorization or isolation.

**Follow-up:** “Can tenant ID come from the request body?”
**Answer:** never trust it alone. Derive/bind permitted tenant scope from verified identity and validate resource ownership.

### Scenario 9: “How would you review an existing architecture?”

**Strong answer:** obtain a decision and owner, trace one user operation, inspect current topology/state/trust/failure boundaries, compare declared requirements with workload/SLO/incident evidence, locate top risks, propose alternatives/experiments, and record decisions. Begin read-only; seek separate authority for tests or changes.

**Weak answer:** run a generic best-practice checklist.
**Follow-up:** “Documentation is stale.”
**Answer:** label it as a hypothesis, reconstruct from configs/runtime/owners, record divergence and create dated evidence rather than silently updating the picture.

### Scenario 10: “Defend asynchronous fulfillment to executives”

**Strong executive narrative:** “We accept and durably identify the order in the interactive path, then isolate slower fulfillment behind a durable obligation. This reduces checkout dependence on provider latency. The cost is pending state, duplicate-safe processing and queue operations. We will cap completion age, reconcile ambiguous payments and reconsider if completion targets or operating cost are missed.”

**Weak answer:** explain broker partitions and consumer groups before business consequences.
**Follow-up:** “Why not synchronous?”
**Answer:** present the synchronous option’s simpler freshness plus its availability/latency coupling, then show the measured requirements and decision trigger.

### Scenario 11: “A design passes all tests; is it production-ready?”

**Strong answer:** only if the tests are representative and the rest of the readiness evidence closes. Inspect security/privacy, operational ownership, SLOs, capacity after failure, restore/reconciliation, migration, canary/rollback, cost and known risks. Tests prove their bounded hypotheses.

**Weak answer:** yes, because CI is green.
**Follow-up:** “What evidence would change your decision?”
**Answer:** name revision triggers such as workload growth, dependency topology, incident pattern, regulation, cost or failed recovery drill.

### Scenario 12: “Reduce architecture cost by 30%”

**Strong answer:** preserve explicit reliability/security constraints; build unit cost and utilization model; find idle reserve, storage/telemetry retention, cross-zone egress and manual operations; test right-sizing or topology alternatives under peak and failure; canary with user SLO and rollback.

**Weak answer:** remove replicas or buy smaller instances immediately.
**Follow-up:** “Can headroom be cut?”
**Answer:** only with evidence about demand error, scale-up time, failure reserve and downstream saturation; headroom is risk capacity, not arbitrary waste.

### A concise interview structure

Use this spoken sequence:

1. “I will clarify the operation, scale and non-negotiable qualities.”
2. “Here are my explicit assumptions.”
3. “This is the authority and end-to-end path.”
4. “This capacity model includes the declared failure.”
5. “These are the top failure, threat and ambiguity cases.”
6. “I considered these feasible alternatives.”
7. “This is my recommendation, consequence and validation/revision plan.”

If interrupted, that structure lets the interviewer choose depth without losing your reasoning.

## Independent transfer and rubric

Published explanations cannot demonstrate independent skill. A reviewer supplies two sanitized, unfamiliar systems and keeps constraint changes hidden until the second round.

### Transfer A: unfamiliar moderate-scale system

The reviewer provides only:

- business operation and actors;
- approximate workload/data envelope;
- three quality targets;
- two external dependencies;
- one security/privacy constraint;
- one incident summary.

The learner must produce:

1. decision contract and clarifying questions;
2. assumptions/constraints/unknown register;
3. one complete quality scenario per target;
4. context, container, dynamic, state/trust and deployment views with text alternatives;
5. workload, capacity, latency, queue/recovery and availability calculations where applicable;
6. state authority and interface/acknowledgement contracts;
7. top ten failure/threat/migration risks;
8. three feasible alternatives including status quo/simpler path;
9. ADR and validation/migration plan;
10. five-minute engineering defense and two-minute executive explanation.

### Transfer B: changed scale and hidden constraint

After submission, the reviewer changes at least two conditions—for example:

- traffic grows 20× with regional hotspots;
- RPO becomes near-zero;
- residency prevents cross-border replication;
- a provider becomes unavailable for 30 minutes;
- cost ceiling falls 35%;
- old clients must coexist for six months.

The learner must update the model without discarding history:

- identify invalid assumptions;
- show sensitivity and affected views;
- revise or supersede the ADR;
- preserve veto constraints;
- update migration/recovery validation;
- explain why the recommendation changed or remained.

### Scoring rubric

| Dimension | Weight | Insufficient | Competent | Advanced |
|---|---:|---|---|---|
| decision/requirements | 12 | solution-first, vague targets | bounded decision and measurable scenarios | resolves conflicts and exposes unknowns |
| workload/calculation | 12 | unitless guesses | correct units/formulas/assumptions | sensitivity, failure envelope and limiting dependency |
| views/communication | 10 | mixed abstraction | scoped consistent views + text | audience-fit views expose operational decisions |
| request/state semantics | 14 | arrows without acknowledgements | owners, authority, identity, retry | ambiguous outcomes, revisions and reconciliation closed |
| reliability/recovery | 12 | replica checklist | named failures, RPO/RTO, restore | correlated failures and user recovery evidence |
| security/privacy | 10 | TLS-only | identities, authorization, data boundaries | abuse, key/audit/retention and incident response |
| alternatives/trade-offs | 10 | one preferred solution | credible options and consequences | vetoes, sensitivity, residual risk and reversibility |
| migration/validation | 10 | big-bang/go-live hope | compatibility, canary, rollback/tests | forward recovery, reconciliation and falsifiable gates |
| observability/operations | 5 | component health only | user journey, saturation and runbook ownership | missing-data, cardinality and recovery completion |
| defense/adaptation | 5 | memorized answer | explains decisions and adapts | preserves evidence/history under constraint change |

Total: 100.

### Evidence and decision rule

- **85–100:** candidate evidence for advanced performance, subject to reviewer confidence and delayed recall.
- **70–84:** competent transfer with named gaps and targeted remediation.
- **Below 70:** repeat after remediation with a different system.
- Any security/privacy veto violation, fabricated benchmark, hidden production access or unresolved state-authority contradiction requires remediation regardless of score.

Require two independent reviewers where possible, plus a delayed defense after at least seven days. Reading completion, lab pass and self-rating never award mastery.

### Reviewer prompts

The reviewer should ask:

- “Which assumption would most likely reverse your decision?”
- “Where is the last durable acknowledgement?”
- “Which component is authoritative after this exact timeout?”
- “Show capacity after the largest shared failure.”
- “What prevents retry amplification?”
- “How do you prove restore and reconciliation?”
- “Which option did a hard constraint eliminate?”
- “What breaks if old and new versions coexist twice as long?”
- “Explain the choice without product names.”
- “What evidence would cause you to supersede this ADR?”

## References and review

These records anchor methods and terminology. They do not certify this fictional design or any local architecture.

1. **REF-0994 — C4 model, diagrams.** Use for the hierarchy of system landscape/context/container/component and supporting dynamic/deployment views. The chapter adds state/trust overlays because one notation does not answer every concern.
2. **REF-0995 — C4 notation.** Supports explicit people, software systems, containers, components and labeled relationships. A team may use another notation if the semantics remain clear.
3. **REF-0996 — SEI Architecture Tradeoff Analysis Method (ATAM).** Supports stakeholder-driven quality attributes, scenarios, sensitivity/trade-off points and risk discovery. This chapter teaches a lightweight review, not a claim of formal ATAM execution.
4. **REF-0997 — ISO/IEC 25010:2023.** Provides a current product-quality model vocabulary. Access/licensing limits may require consulting the official standard through an authorized source.
5. **REF-0998 — RFC 2119.** Defines normative requirement words such as MUST, SHOULD and MAY for specifications.
6. **REF-0999 — RFC 8174.** Clarifies that those key words carry normative meaning when shown in uppercase as specified. Do not casually capitalize them in prose.
7. **REF-1000 — NIST SP 800-160 Volume 1 Revision 1.** Grounds systems-security engineering as a lifecycle concern rather than a final control checklist.
8. **REF-1001 — OWASP Threat Modeling.** Supports structured analysis of what is being built, what can go wrong, mitigations and adequacy. Threat modeling must remain connected to the actual data/identity flow.
9. **REF-1002 — Architecture Decision Records organization.** Provides community ADR resources and formats. Choose a small template and preserve supersession/history.
10. **REF-1003 — AWS Well-Architected Framework.** Useful provider guidance across operational excellence, security, reliability, performance efficiency, cost optimization and sustainability. Recheck current service-specific advice before use.
11. **REF-1004 — Azure Well-Architected Framework.** Useful cross-cutting provider principles and workload review guidance. It does not replace workload-specific evidence.
12. **REF-1005 — Google Cloud Well-Architected Framework.** Useful provider architecture perspectives and pillar guidance. Treat recommendations as context-dependent.
13. **REF-1006 — Azure Cloud Design Patterns.** Catalog of recurring distributed-system patterns and trade-offs. A named pattern is not proof it fits.
14. **REF-1007 — Google Cloud reliability pillar.** Useful current reliability design guidance; validate service behavior, limits and failure model against primary service documentation.
15. **REF-1008 — AWS ADR process guidance.** Supports recording significant decisions with context and consequences as a living architecture practice.
16. **REF-1009 — Azure Architecture Center.** Broad reference architectures and decision guides. Adapt after requirements/evidence; never copy a reference architecture as automatic approval.

### Source discipline

For standards and provider guidance:

- verify URL, version and review date;
- prefer official/primary sources;
- distinguish normative specification from explanatory guidance;
- state applicability and limitations;
- do not paste proprietary/confidential material;
- recheck temporally changing service limits, features and prices.

### Final architecture review

Before calling a design ready for implementation, a reviewer should be able to answer:

1. What user operation and business decision does this packet serve?
2. Which requirements are measurable, conflicting or still unknown?
3. Where did every numeric input come from?
4. What are the state, identity, trust and failure boundaries?
5. What does each acknowledgement guarantee?
6. How are duplicates, ordering and ambiguous outcomes handled?
7. What happens under overload and the largest shared failure?
8. How are restore, replay and reconciliation proven?
9. Which alternative was chosen, rejected or vetoed—and why?
10. What migration, canary, stop and recovery evidence is required?
11. Who owns residual risks and expiry dates?
12. What new evidence will trigger a new decision?

If those answers are explicit, the architecture is reviewable. It is still a hypothesis until implementation and operational evidence support it.
