---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0083",
  "slug":"architecture-strategy-migration-governance",
  "aliases":["V10-L02","architecture-strategy-migration-governance"],
  "curriculumIds":["ARC-002"],
  "route":"/book/architecture/architecture-strategy-migration-governance",
  "order":2,
  "volume":"10-architecture-leadership",
  "title":"Architecture strategy and migration: govern change, vendors, standards, and investment",
  "summary":"Turn executive intent into evidence-gated portfolio strategy, capacity and cost ranges, standards, vendor due diligence, dependency-aware migration waves, reversible transitions, governance and audience-fit decisions.",
  "domain":"architecture",
  "level":{"from":"advanced","to":"expert"},
  "estimatedMinutes":660,
  "prerequisiteLessonIds":["LES-0082","LES-0035","LES-0081"],
  "prerequisiteCurriculumIds":["ARC-001","PERF-001","FIN-001"],
  "testedEnvironments":[
    {"platform":"Official standards and documentation","version":"ISO architecture/IT governance/risk, NIST RMF/C-SCRM, TOGAF, provider migration, government technology/open-standards/acquisition and FinOps guidance reviewed 2026-08-07","support":"concept-only","notes":"Sources establish methods and vocabulary, not fitness of a local strategy, supplier or migration."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 71 cases, five calculations, authority/root/unknown-artifact refusal and exact cleanup pass."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic fictional strategy model; no discovery, provider, vendor, contract, migration or runtime call."},
    {"platform":"Production, provider or vendor runtime","version":"not present in the tested boundary","support":"unsupported","notes":"No credential, endpoint, portfolio, contract, price, infrastructure, data movement, cutover, purchase or production mutation is authorized."}
  ],
  "targetRoles":["site-reliability-engineer","devops-engineer","platform-engineer","cloud-engineer","infrastructure-engineer","solutions-architect","enterprise-architect","technical-lead","staff-engineer","engineering-manager"],
  "learningObjectives":[
    "Translate executive intent into a measurable strategy mandate with decision rights, risk appetite and revision triggers.",
    "Build a versioned portfolio evidence model that distinguishes observed, declared, inferred and unknown facts.",
    "Rationalize workloads across retire, retain, rehost, relocate, repurchase, replatform and refactor without assuming migration.",
    "Define target architecture principles, standards, exceptions and governance that constrain decisions without centralizing all design.",
    "Estimate compound demand, failure-aware capacity, transfer/cutover time, transition cost, benefits and break-even with ranges.",
    "Evaluate vendors using hard vetoes, security and supply-chain evidence, interoperability, export, concentration and exit.",
    "Design shared-foundation readiness, pilots and dependency-aware migration waves within delivery and operations capacity.",
    "Design coexistence, compatibility, writer fencing, synchronization, rollback feasibility, forward recovery and reconciliation.",
    "Create go/no-go, stop, handover, benefit-realization, retention and decommission evidence gates.",
    "Communicate one decision accurately to executives, finance, security, engineering and operations."
  ],
  "productionSignals":[
    "mandate owner outcome scope non-goal constraint risk appetite horizon and review trigger",
    "portfolio item owner criticality lifecycle evidence source observation window confidence and unknown",
    "technical data identity business shared-service contract and business-cycle dependency",
    "retain retire rehost relocate repurchase replatform refactor rationale and target state",
    "principle statement rationale implication measure exception owner and expiry",
    "decision right proposal consultation approval exception escalation and evidence cadence",
    "current peak growth headroom sustainable rate failure domain survivor capacity and limiting dependency",
    "data volume throughput efficiency source change final sync validation window and uncertainty",
    "current target transition opportunity support risk exit cost benefit range and break-even",
    "supplier security transparency vulnerability lifecycle portability export concentration contract and exit",
    "foundation identity organization network security logging quota automation support and recovery readiness",
    "pilot dependency group wave size team capacity business freeze and go-no-go authority",
    "coexistence version compatibility route writer fence synchronization lag and reconciliation",
    "stop rollback traffic reversal state recovery external effects and forward repair",
    "user data security reliability performance operations financial and decommission success evidence"
  ],
  "diagrams":[
    {"id":"LES-0083-DIA-001","title":"Evidence-gated strategy loop","direction":"cyclic","boundaries":["mandate","portfolio evidence","options","decision","waves","outcomes","review"],"evidencePoints":["owner","confidence","veto","ADR","pilot","benefit receipt"],"textAlternative":"Executive intent becomes a versioned evidence model, feasible options and accountable decision; pilot and wave outcomes revise the next strategy cycle."},
    {"id":"LES-0083-DIA-002","title":"Portfolio confidence and dependency map","direction":"hierarchical","boundaries":["portfolio","observed","declared","inferred","unknown","dependency groups"],"evidencePoints":["source","window","owner","criticality","business cycle"],"textAlternative":"Portfolio records retain evidence confidence and combine technical, owner and business evidence into migration dependency groups."},
    {"id":"LES-0083-DIA-003","title":"Workload rationalization decision tree","direction":"top-down","boundaries":["business need","retire","retain","move","buy","modernize"],"evidencePoints":["outcome","constraint","complexity","risk","value"],"textAlternative":"Each workload is tested for retirement or retention before move, purchase or modernization strategies are compared."},
    {"id":"LES-0083-DIA-004","title":"Migration transition-state architecture","direction":"left-to-right","boundaries":["source","replication","coexistence","cutover","target","reconciliation","decommission"],"evidencePoints":["version","writer fence","lag","checkpoint","rollback point","retention"],"textAlternative":"Old and new systems coexist through compatible replication, one writer authority, gated cutover, reconciliation and evidence-based retirement."},
    {"id":"LES-0083-DIA-005","title":"Vendor feasibility and preference funnel","direction":"top-down","boundaries":["requirements","hard vetoes","due diligence","weighted preferences","contract","validation"],"evidencePoints":["security","residency","export","exit","score sensitivity","acceptance"],"textAlternative":"Hard constraints remove infeasible suppliers before preference scoring, contract evidence and technical validation inform a human decision."},
    {"id":"LES-0083-DIA-006","title":"Portfolio-to-wave governance system","direction":"left-to-right","boundaries":["strategy board","architecture/security/finance","platform foundation","application waves","operations","outcomes"],"evidencePoints":["decision rights","exception","go-no-go","stop","handover","benefit review"],"textAlternative":"Cross-functional strategy sets guardrails while wave owners earn approval from evidence and operations returns outcome evidence to governance."}
  ],
  "commands":[
    {"id":"LES-0083-CMD-001","question":"Is this a guarded no-runtime strategy shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0083 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"fixtures calculations and authority guards pass","nextEvidence":"initialize copied fixtures"},{"when":"lab=fail","meaning":"a named safety or source guard failed","nextEvidence":"correct the boundary without bypass"}],"proves":"offline prerequisites and guard","doesNotProve":"portfolio strategy or migration fitness"},
    {"id":"LES-0083-CMD-002","question":"Can bounded fictional strategy state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0083 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture exists","nextEvidence":"inspect status"},{"when":"refusal","meaning":"authority ownership or prior state is unsafe","nextEvidence":"preserve the first refusal"}],"proves":"planned local initialization","doesNotProve":"provider or migration setup","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0083-CMD-003","question":"Is the intended strategy and case set loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"cases=71 and strategy ID match","meaning":"reviewed fixture identity matches","nextEvidence":"map the roadmap"}],"proves":"local fixture identity","doesNotProve":"inventory correctness"},
    {"id":"LES-0083-CMD-004","question":"What decision stages and evidence transfers are modeled?","risk":"read-only","command":"bash lab.sh roadmap","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"roadmap=pass","meaning":"the fictional lifecycle is explicit","nextEvidence":"challenge ownership and gates"}],"proves":"declared fictional roadmap","doesNotProve":"organizational readiness"},
    {"id":"LES-0083-CMD-005","question":"How trustworthy is the portfolio inventory?","risk":"read-only","command":"bash lab.sh inventory","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"inventory=pass","meaning":"confidence classes conserve the total","nextEvidence":"close critical unknowns"}],"proves":"fixture classification arithmetic","doesNotProve":"real asset discovery"},
    {"id":"LES-0083-CMD-006","question":"What three-year capacity survives the declared failure?","risk":"read-only","command":"bash lab.sh capacity","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"capacity=pass","meaning":"fictional growth headroom and survivor arithmetic close","nextEvidence":"validate input ranges"}],"proves":"fixture arithmetic","doesNotProve":"benchmark or production capacity"},
    {"id":"LES-0083-CMD-007","question":"Can bulk copy, final sync and validation fit the cutover?","risk":"read-only","command":"bash lab.sh transfer","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"closes=true","meaning":"declared rates fit the fictional window","nextEvidence":"test change capture and variance"}],"proves":"transfer/cutover arithmetic","doesNotProve":"data compatibility or achieved throughput"},
    {"id":"LES-0083-CMD-008","question":"Does the migration break even inside the decision horizon?","risk":"read-only","command":"bash lab.sh economics","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"breaks_even_within_horizon=false","meaning":"the fictional cost-saving claim fails","nextEvidence":"evaluate other outcomes honestly"}],"proves":"declared horizon arithmetic","doesNotProve":"future bills or business value"},
    {"id":"LES-0083-CMD-009","question":"Can a tied high vendor score survive a hard exit veto?","risk":"read-only","command":"bash lab.sh vendor","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"managed_suite_veto=exit-plan","meaning":"feasibility precedes preference","nextEvidence":"perform due diligence and sensitivity"}],"proves":"declared score/veto logic","doesNotProve":"best supplier or contract"},
    {"id":"LES-0083-CMD-010","question":"Can undocumented current state support strategy?","risk":"read-only","command":"bash lab.sh evaluate current-state-asserted-without-evidence","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"boundary=current-state","meaning":"target choice cannot repair unknown baseline","nextEvidence":"version evidence and confidence"}],"proves":"planned evidence boundary","doesNotProve":"inventory priority"},
    {"id":"LES-0083-CMD-011","question":"Can a migration pass without cutover closure?","risk":"read-only","command":"bash lab.sh evaluate cutover-window-does-not-close","runFrom":"LES-0083 support/lab after setup","expectedBranches":[{"when":"boundary=cutover","meaning":"transition timing is infeasible","nextEvidence":"change method rate window or scope"}],"proves":"planned transition boundary","doesNotProve":"real cutover duration"},
    {"id":"LES-0083-CMD-012","question":"Do all gates calculations refusals and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0083 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"71 cases five calculations refusals and cleanup pass","nextEvidence":"retain fictional-only limits"},{"when":"failure","meaning":"candidate evidence is rejected","nextEvidence":"preserve first failed gate"}],"proves":"guarded offline lifecycle","doesNotProve":"representative strategy or learner mastery","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs":[
    {"id":"LES-0083-LAB-001","title":"Guided portfolio strategy, vendor and migration evidence review","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; fictional local JSON only","timeMinutes":300,"privilege":"normal user; root and runtime authority refused","network":"none","changes":["one UID-scoped temporary root","copied fictional case and strategy fixtures"],"abortConditions":["root","cloud credential","runtime or vendor endpoint","Kubernetes or Docker authority","symlink","wrong owner","unknown artifact"],"recovery":"Preserve the first failed assertion and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0083-architecture-strategy-migration-governance/support/lab"},
    {"id":"LES-0083-LAB-002","title":"Independent two-scale strategy and migration review","mode":"independent","environment":"Reviewer-owned sanitized portfolio/evidence packets; no production connection","timeMinutes":300,"privilege":"read-only analyst; reviewer owns hidden constraints scoring and cleanup","network":"none","changes":["local portfolio register","calculations","decision record","wave and transition plans"],"abortConditions":["production credential or mutation","employer-confidential inventory or contract","customer data","fabricated price or benchmark","missing writer/recovery/security boundary"],"recovery":"Discard or sanitize reviewer-owned artifacts after scored evidence is retained.","cleanupProof":"Reviewer confirms no credential endpoint external resource confidential artifact or answer key remains.","path":"drafts/LES-0083-architecture-strategy-migration-governance/support/lab"}
  ],
  "incidents":[
    {"id":"LES-0083-INC-001","signal":"A migration wave fails because an unobserved month-end dependency was absent from seven days of flow data.","firstThought":"Discovery sampling was treated as completeness and business-cycle evidence was omitted.","safePath":"Pause dependent waves, restore/reconcile, expand observation and owner validation, then revise groups and confidence.","trap":"Blame the application team or add every shared service to every wave."},
    {"id":"LES-0083-INC-002","signal":"A vendor wins the scorecard but cannot provide secure export or a credible exit path.","firstThought":"A hard lifecycle constraint was incorrectly averaged with preferences.","safePath":"Mark the option infeasible, require evidence or compare viable alternatives, and retain accountable exception authority.","trap":"Increase the portability weight until the spreadsheet looks right."},
    {"id":"LES-0083-INC-003","signal":"Target writes begin, cutover fails, and DNS is switched back while source data is stale.","firstThought":"Traffic reversal was mistaken for state rollback and writer authority/reconciliation were unbound.","safePath":"Fence writers, stop unsafe traffic, establish authoritative state, execute tested forward recovery or reconciliation.","trap":"Enable dual write and merge by timestamp."},
    {"id":"LES-0083-INC-004","signal":"The program reports 30 percent savings although current and target costs use different periods and allocation rules.","firstThought":"The financial comparison lacks semantic identity and a valid counterfactual.","safePath":"Normalize currencies periods meanings one-time/opportunity/exit costs and service outcomes, then restate a range.","trap":"Present avoided list price as realized saving."},
    {"id":"LES-0083-INC-005","signal":"Servers are healthy after a wave but users fail, support has no runbook and source deletion is scheduled.","firstThought":"Infrastructure activity was used as success while user, handover, reconciliation and retention gates remain open.","safePath":"Stop decommission, restore user outcome, reconcile data/security controls, complete operations acceptance and retain recovery evidence.","trap":"Close the wave because the project deadline passed."}
  ],
  "assessmentIds":["ASM-0232","ASM-0233","ASM-0234"],
  "referenceIds":["REF-1010","REF-1011","REF-1012","REF-1013","REF-1014","REF-1015","REF-1016","REF-1017","REF-1018","REF-1019","REF-1020","REF-1021","REF-1022","REF-1023","REF-1024","REF-1025","REF-1026","REF-1027"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "This is a substantive teaching manuscript with fictional offline evidence; organizational use still requires local validation and accountable review.",
    "All portfolio inventory capacity transfer cost benefit vendor risk and score data in the model are fictional.",
    "Provider and government migration frameworks are contextual guidance rather than universal migration requirements.",
    "Weighted vendor scores are advisory and never override security legal correctness residency export or exit vetoes.",
    "No portfolio discovery contract price vendor capability provider foundation migration cutover data reconciliation or production behavior is tested.",
    "Formal technical security privacy financial procurement legal and instructional review plus reviewer-scored transfer and delayed recall remain required."
  ]
}
---

# Architecture strategy and migration: govern change, vendors, standards, and investment

## What you see and first thought

You receive a slide with one sentence:

> Move all 120 applications to cloud in 18 months and reduce cost by 30 percent.

The sentence matters. It may express urgency, a data-center exit, a board expectation or a response to business risk. But it is not yet a strategy, a workload decision, a budget, a migration plan or authorization to change production.

Your first response should not be “Which cloud?” or “How many migration waves?” It should be:

> Which organizational outcome requires this change, which parts are hard constraints, what evidence supports the portfolio and cost claims, who owns the decision, and what would make us stop or revise it?

That response is not resistance. It prevents the organization from executing a slogan.

### The strategy engineer’s real job

At system-design scale, you connect one user operation to components, state and failure behavior. At strategy scale, you connect many changing systems and teams to organizational outcomes over time.

Your job is to make five things explicit:

1. **Direction:** the outcome and boundary leadership intends.
2. **Evidence:** what is observed, declared, inferred or still unknown.
3. **Choice:** feasible alternatives and why one is recommended.
4. **Authority:** who may decide, approve risk, grant an exception or stop change.
5. **Learning:** which results cause the strategy to continue, change or end.

The architecture strategy is therefore not a large target-state diagram. It is a governed sequence of decisions and transitions.

### Ask what problem “move” is solving

The same request can hide different motives:

- a data-center lease ends in 18 months;
- hardware or software reaches end of support;
- security controls cannot meet obligations;
- teams need faster product delivery;
- demand has outgrown current capacity;
- resilience or recovery is inadequate;
- a merger requires consolidation;
- a vendor contract is unaffordable;
- leadership believes cloud is automatically cheaper.

These motives produce different strategies. A lease expiry is a hard time constraint that may favor rehost now and modernize later. A product-velocity goal may justify selective refactoring. A security failure may require immediate containment independent of migration. A cost claim requires a comparable baseline and counterfactual.

Do not let “cloud,” “modernize,” “consolidate” or “AI” stand in for the outcome.

### Separate direction from authorization

An executive sponsor can authorize discovery and set risk appetite. That does not mean every application team is authorized to expose data, move production, accept downtime, sign a contract or delete the source.

| Stage | Typical authority | Evidence required |
|---|---|---|
| discovery | portfolio/program owner plus data owners | scope, collection purpose, access and retention |
| analysis | architecture/finance/security/application owners | versioned evidence and uncertainty |
| proof of concept | technical owner in disposable environment | bounded hypothesis and cleanup |
| pilot | service/business owner and change authority | readiness, recovery and stop conditions |
| production wave | named go/no-go authority | tested runbook, staffing, timing and current evidence |
| decommission | data, legal, service and recovery owners | reconciliation, retention, exit and restore obligations closed |

A strategy document cannot silently grant missing authority.

### The four confidence labels

Suppose the portfolio spreadsheet contains 120 rows. It can still be a poor inventory.

- **Observed:** measured from a named source during a stated window.
- **Declared:** provided by an accountable owner or contract.
- **Inferred:** derived from other evidence by an explicit rule.
- **Unknown:** no adequate evidence exists.

Observed does not mean complete. Seven days of network flows can miss month-end batch work. Declared does not mean false; owners may know manual business dependencies no tool sees. Inferred does not mean fact. Unknown does not mean low risk.

In the fictional packet:

```text
total applications       120
observed records          72 = 60%
owner-declared records    30 = 25%
unknown records           18 = 15%
```

If one unknown system performs settlement, identity, certificate issuance or regulatory reporting, scheduling it as “low complexity” is unsafe. Close high-consequence unknowns first.

### Migration is a temporary architecture

During migration, the organization operates more systems:

```text
source + target + replication + compatibility + routing
       + migration tooling + monitoring + reconciliation
```

That transition architecture may last weeks or years. It has user operations, state authority, credentials, network paths, support ownership, capacity, cost and failure modes. Treating it as a project plan is how teams create dual writers, unrecoverable cutovers and indefinite duplicate estates.

### The first safe response

When evidence is incomplete:

1. preserve the mandate exactly;
2. clarify outcome, constraint, target and assumption;
3. authorize read-only discovery with data protections;
4. version the portfolio and confidence labels;
5. identify critical unknowns and sampling gaps;
6. compare strategies, including retain and retire;
7. define principles, decision rights and exceptions;
8. model ranges for capacity, time, cost and benefits;
9. prove common foundations;
10. authorize a bounded pilot with stop and recovery conditions;
11. use pilot evidence to revise later waves.

This is faster than recovering from a confident but false plan.

## Terms before commands

### Strategy, roadmap, plan and architecture

A **strategy** is a coherent set of choices for achieving outcomes under constraints and uncertainty. It says what will and will not be done, why, and how evidence changes the choices.

A **roadmap** orders capabilities and decisions over time. A **plan** assigns activities, owners, timing and resources for bounded scope. An **architecture** describes consequential structure and decisions. A **transition architecture** describes intermediate structure while old and new states coexist.

A slide containing products and dates can be a roadmap artifact. It is not a strategy unless it exposes choices, evidence and consequences.

### Mandate, outcome, target and constraint

A **mandate** is an authoritative direction, but still needs interpretation and an authority boundary. An **outcome** is a change experienced by users, the organization or its risk position. A **target** is a desired measured result. A **constraint** limits feasible choices.

“Thirty percent cheaper” is a target only when the baseline, included costs, horizon and measurement are defined. “Lease ends on 30 June” is usually a constraint.

### Portfolio, workload, application and service

A **portfolio** is the governed collection being evaluated. An **application** is a software capability as the organization inventories it. A **service** is an owned value and operating boundary. A **workload** is the resources and operations that deliver a capability in an environment.

These do not always map one to one. Define the unit before counting.

### Inventory and evidence confidence

An **inventory** is a versioned set of portfolio records with identity and evidence lineage. **Evidence confidence** expresses how strongly a claim is supported for the decision. It depends on source, window, freshness, coverage, agreement and consequence—not whether a tool generated it.

Use confidence to select investigation, never to hide uncertainty behind an average score.

### Dependency and dependency group

A **dependency** exists when the outcome or transition of one item relies on another capability, data, identity, sequence or organizational action.

Dependencies can be runtime, deployment-time, data, identity, network, certificate, contractual, operational or business-cycle. A **dependency group** must transition together or through an explicit compatibility bridge.

Shared identity, DNS, monitoring and backup should not glue the entire portfolio into one impossible wave; model them as foundations with readiness evidence.

### Criticality and complexity

**Criticality** expresses consequence if an outcome is unavailable, incorrect, insecure or unrecoverable. **Complexity** expresses difficulty and uncertainty of changing it.

A low-complexity payment system can be critical. A complex internal report may be low criticality. Early pilots are normally low criticality and sufficiently representative—not simply the easiest unused server.

### Workload rationalization

**Rationalization** assigns a justified strategy:

- **Retire:** remove the capability because its outcome is no longer needed.
- **Retain:** keep it because movement lacks value or violates a constraint.
- **Rehost:** move with minimal application change.
- **Relocate:** move an existing platform estate with minimal workload change.
- **Repurchase:** replace the capability with a product/service.
- **Replatform:** make bounded platform changes without redesigning the core.
- **Refactor or re-architect:** materially change structure/code to achieve new qualities.

Provider names vary. Record your local definition. The decision matters more than whether a list is called six or seven Rs.

### Principle, standard, guardrail and pattern

An **architecture principle** guides repeated decisions. A **standard** specifies an agreed requirement or interface. A **guardrail** allows teams to act safely inside a boundary. A **pattern** is a reusable solution shape with context and trade-offs.

Example:

```text
Principle: Business state has one declared authority during migration.
Rationale: Prevent divergent accepted facts and unresolvable rollback.
Implication: Dual writing requires fencing, idempotency and reconciliation.
Evidence: Authority table plus tested cutover/recovery transitions.
Exception: Named risk owner, expiry and compensating controls.
```

### Governance, management and decision rights

**Governance** evaluates direction, constraints, risk and outcomes and assigns decision rights. **Management** plans and executes within those boundaries.

Effective governance answers who proposes, consults, decides, accepts residual risk, grants exceptions, stops a wave and reviews evidence. A review board that redraws every team’s diagram is a bottleneck, not necessarily governance.

### Exception and technical debt

An **exception** is an approved temporary or scoped departure from a rule. It needs rationale, owner, risk, compensating controls, expiry and closure evidence.

**Technical debt** is a future consequence from a present technical choice. Calling every deviation “debt” hides whether it is intentional or harmful. Track consequence and decision, not a shame label.

### Risk, issue, appetite and residual risk

A **risk** is uncertainty affecting an objective. An **issue** is already occurring. **Risk appetite** describes the type and amount governing authority will pursue or retain. **Residual risk** remains after treatment.

Risk is not a color without defined likelihood, consequence, time, evidence and owner. Unknown inventory is not automatically low likelihood.

### Estimate, forecast, budget and actual

An **estimate** is a model under stated inputs. A **forecast** is a time-based expectation updated with evidence. A **budget** is an authorized financial boundary. An **actual** is a measured or billed outcome with defined semantics.

Do not present an estimate as a budget or avoided list price as realized saving.

### Total cost and opportunity cost

A strategy cost model can include current run, target run, one-time transition, coexistence, people/training, tooling/support/contracts, incident exposure, exit/decommission and **opportunity cost**—valuable work displaced by the program.

Total cost is comparable only when period, currency, inclusions and service outcomes match.

### Supplier, vendor and concentration

A **supplier** provides a product or service under a relationship and contract. Evaluation includes capability, attributable evidence, commercial terms, security, operations and lifecycle.

**Concentration risk** arises when many critical outcomes depend on one supplier, region, identity plane, skill set or contract. Multi-vendor design may reduce one concentration while increasing integration risk.

### Veto and weighted preference

A **veto constraint** makes an option infeasible: illegal residency, absent required security evidence, inability to export/recover authoritative data or violation of correctness.

A **weighted preference** ranks feasible choices. Never average a veto away with price or features.

### Portability, interoperability and exit

**Portability** is the ability to move with acceptable effort. **Interoperability** is the ability to exchange and use information through understood contracts. An **exit plan** covers data/config export, semantics, timing, identity, dependencies, assistance, verification, retention, deletion and commercial duties.

“Uses containers” does not prove portability. Managed identity, data APIs, event semantics, operational tooling and skills often dominate.

### Pilot, wave and migration factory

A **pilot** tests assumptions at bounded blast radius while remaining representative. A **wave** is a governed dependency group transitioned within delivery capacity. A **migration factory** standardizes repeatable work.

Automation should remove known repetition without suppressing workload-specific risk. Faster execution of a false inventory is not progress.

### Coexistence and compatibility window

**Coexistence** is the period where source and target participate in the flow. A **compatibility window** defines supported versions, schemas and protocols.

Long coexistence increases duplicate cost, attack surface and ambiguity. Short coexistence increases coordination and rollback constraints.

### Cutover, rollback and forward recovery

**Cutover** transfers traffic or writer authority. **Rollback** returns to a previous safe state. Routing reversal is only traffic rollback; target writes or external effects can make state rollback unsafe.

**Forward recovery** repairs the new state and continues when reversal would lose or corrupt accepted facts. Both paths need business reconciliation.

### Reconciliation, handover and decommission

**Reconciliation** compares authoritative business facts and obligations, explains differences and repairs them. **Operational handover** transfers access, knowledge, telemetry, authority, runbooks and escalation. **Decommission** ends a system after traffic, writer, retention, legal, backup, contract, credential and dependency obligations close.

### Benefit realization

**Benefit realization** measures whether intended outcomes occurred after change, using a baseline, counterfactual, window and owner.

Migrated-server count measures activity. It does not prove improved delivery, cost, resilience, security or user outcome.

## Architecture map

One strategy diagram cannot answer portfolio, transition and governance questions. Use complementary views with explicit scope.

### Evidence-gated strategy loop

```text
Executive intent
      │
      v
[Mandate + outcomes + constraints]
      │
      v
[Versioned portfolio evidence] <──────────────┐
      │                                        │
      v                                        │
[Options + ranges + risks + vetoes]            │
      │                                        │
      v                                        │
[Accountable decision / ADR]                   │
      │                                        │
      v                                        │
[Foundation -> pilot -> dependency waves]      │
      │                                        │
      v                                        │
[User/data/security/operations/cost outcomes]──┘
```

**Text alternative:** intent becomes an owned mandate; versioned evidence supports feasible options; accountable decision authorizes bounded transitions; observed outcomes update portfolio assumptions and later decisions.

This loop prevents treating the first target architecture as permanent truth or a program milestone as proof of value.

### Portfolio confidence view

```text
Portfolio v2026-08-07 (120)
├── Observed (72)
│   ├── telemetry/config source
│   └── explicit window and coverage
├── Owner-declared (30)
│   ├── accountable owner
│   └── declaration date/evidence
└── Unknown (18)
    ├── consequence if wrong
    ├── investigation owner
    └── closure deadline

Dependency groups combine:
runtime + data + identity + business cycle + contract + operator knowledge
```

Do not collapse this to an average “confidence 82%.” The unknown identity provider and unknown low-value report have different consequences.

### Rationalization view

```text
Is the business outcome still required?
├── No  -> Retire, with retention/dependency proof
└── Yes
    ├── Must remain for now? -> Retain with review trigger
    └── Change is justified
        ├── Replace capability? -> Repurchase
        ├── Move with minimal change? -> Rehost / Relocate
        ├── Bounded platform optimization? -> Replatform
        └── New qualities require redesign? -> Refactor / Re-architect
```

This is a conversation guide, not an algorithm. One workload can use different strategies for application, database and operating model. Record scope.

### Transition-state view

```text
                ┌──────── compatibility ────────┐
Users -> Router -> Source v1                    Target v2
                 │ authoritative writer             │
                 └── change log -> replicator ──────┘
                                      │
                                lag/checkpoint

Cutover:
  stop/admit -> final sync -> validate -> fence source
  -> enable target writer -> user verification -> reconcile

Recovery:
  traffic reversal only if state contract permits
  otherwise forward repair + reconciliation
```

This view must show writer authority, not just data arrows.

### Governance view

```text
Governing sponsor / investment authority
   │ sets outcomes, risk appetite, funding boundary
   v
Cross-functional strategy owners
   ├── architecture: principles, options, transition integrity
   ├── security/privacy/legal: vetoes, treatment, acceptance
   ├── finance/procurement: economics, contract, exit
   ├── platform: foundation and delivery capacity
   ├── application/business: user outcome and criticality
   └── operations: support, recovery and stop readiness
            │
            v
Wave go/no-go owner -> execution team -> outcome evidence
            │                               │
            └──────── review/escalate <─────┘
```

Consultation is not authority. Put roles on propose, approve, risk-accept, stop and decommission actions.

### Vendor feasibility funnel

```text
All candidates
   │
   ├── hard constraints:
   │   legal • residency • security • correctness • export • exit
   v
Feasible candidates
   │
   ├── attributable due diligence and contract evidence
   v
Weighted preferences + sensitivity
   │
   v
Proof of concept / acceptance tests
   │
   v
Human decision + residual risk + review trigger
```

In the fixture both vendors score 3.95. The managed suite lacks an exit plan, so it is infeasible before preference ranking. The portable platform is the only fixture candidate that passes the stated veto; that still does not prove it should be purchased.

### Portfolio-to-wave view

```text
Portfolio
  ├── dependency group A ──┐
  ├── dependency group B ──┼──> Foundation readiness
  ├── shared identity ─────┤           │
  └── shared data ─────────┘           v
                                  Representative pilot
                                       │ evidence
                     ┌─────────────────┴─────────────────┐
                     v                                   v
                  Wave 1                              Wave 2
             go/no-go + stop                    go/no-go + stop
                     │                                   │
                     └────────> operations/handover <────┘
                                      │
                               outcome learning
```

Wave order is not simply low ID to high ID. It reflects dependencies, criticality, business timing, foundation readiness, team capacity and learning from earlier transitions.

### View quality contract

Every strategy view should state:

- entity and decision scope;
- version/date and owner;
- evidence confidence or source;
- relationship direction and meaning;
- time horizon or transition stage;
- assumptions and known omissions;
- equivalent text;
- review/supersession trigger.

An enterprise diagram can be impressive while hiding the only writer, contract expiry or unknown dependency. Those facts change the decision.

## Request or state path

Follow strategy as a state machine. Each state has an owner, entry evidence, permitted actions and exit criteria.

### 1. Capture intent without silently rewriting it

| Statement | Classification | Required clarification |
|---|---|---|
| move all applications | proposed scope/solution | are retain/retire allowed and what counts as application? |
| in 18 months | target or hard deadline | what event creates it and what happens if missed? |
| reduce cost 30% | target/assumption | baseline, horizon, scope, currency and service outcome? |

Never “improve” the mandate in meeting notes until its owner confirms the change.

### 2. Establish decision and evidence authority

Bind the executive sponsor, portfolio owner, security/privacy/legal risk authority, finance/procurement owner, application/data owners, wave go/no-go and stop authority, and decommission authority.

Define who may access inventory, flow, contract and cost data. Discovery itself can expose sensitive architecture and commercial information.

### 3. Build the versioned current-state packet

For every portfolio item collect what the decision needs:

- stable identity and owned business outcome;
- criticality and tolerated interruption/data exposure;
- lifecycle/support state;
- runtime and deployment topology;
- data volume/class/residency/retention;
- dependencies and observation coverage;
- current demand/performance/reliability;
- cost semantics and contract dates;
- skills, support and recovery evidence;
- evidence source, date, confidence and unknowns.

Do not wait for a mythical perfect CMDB. Close decision-critical unknowns and keep the rest visible.

### 4. Classify dependencies with several sources

Discovery tools observe configured or executed relationships. They often cannot tell whether a connection is critical, degraded operation is acceptable, a monthly file matters, a human approval blocks recovery or two systems must cut over together.

Combine runtime observation, configuration, schemas, identity, batch schedules, contracts, incidents and owner review. Record disagreement and sampling gaps.

### 5. Rationalize instead of mass-migrating

For each workload or dependency group ask:

1. Is the outcome still required?
2. What happens if it is retained?
3. Which qualities must change?
4. Which constraints eliminate options?
5. Is movement necessary?
6. What is the smallest reversible strategy?
7. What later modernization remains?

A data-center exit may justify rehost under time pressure and a separate modernization roadmap. Combining both can exceed delivery capacity and cutover risk.

### 6. Define target principles and standards

Useful principles include:

- business state has one authority during transition;
- critical workloads expose user-journey SLOs before migration;
- identity, network, audit and recovery foundations precede waves;
- data export and exit are acceptance criteria;
- exceptions expire and carry an owner;
- no source is decommissioned before reconciliation.

Turn principles into evidence gates. “Cloud first” is not testable enough.

### 7. Quantify capacity as a range

The fictional model grows peak demand for three years:

```text
current peak = 8,000 RPS
annual growth = 25%
future peak = 8,000 × 1.25³ = 15,625 RPS
target with 30% headroom = 20,312.5 RPS
rate per instance at SLO = 600 RPS
healthy equivalents = ceil(20,312.5 / 600) = 34
```

For three equal domains with one lost:

```text
instances/domain = ceil(34 / 2 survivors) = 17
provisioned = 17 × 3 = 51
surviving capacity = 17 × 2 × 600 = 20,400 RPS
```

This is arithmetic, not a forecast or benchmark. Growth, sustainable rate, distribution, scale time and downstream limits need ranges and validation.

### 8. Quantify movement and cutover separately

Bulk copy happens before the cutover window:

```text
data = 48 decimal TB = 384,000 gigabits
effective link = 2.4 Gbit/s × 75% = 1.8 Gbit/s
bulk time = 384,000 / 1.8 / 3,600 = 59.26 hours
```

While bulk copy runs:

```text
delta = 59.26 h × 20 GB/h = 1,185.19 GB
final sync = 1,185.19 / 810 GB/h = 1.46 h
validation = 1.50 h
cutover budget = 1.46 + 1.50 = 2.96 h
```

The four-hour window closes only under declared decimal units, efficiency, change rate, final-sync rate and validation scope. Encryption, retries, transformation, indexes, checksums, freeze time and variance can change it.

### 9. Compare economics with the same meaning

For 36 months:

```text
current = USD 2.40m/year × 3 = USD 7.20m
target run = USD 1.85m/year × 3 = USD 5.55m
one-time program = USD 1.80m
proposed total = USD 7.35m
net saving = 7.20 - 7.35 = -USD 0.15m
annual run-rate difference = USD 0.55m
break-even = 1.80 / 0.55 × 12 = 39.27 months
```

The migration does not break even inside the fictional horizon. That does not automatically reject it. It rejects a near-term saving claim. Resilience, security, agility, contract exit or strategic capability may justify investment if measured rather than used as vague rescue words.

### 10. Evaluate vendors in the correct order

1. verify requirements and hard constraints;
2. require attributable supplier evidence;
3. reject infeasible candidates;
4. score preferences among feasible candidates;
5. test sensitivity and uncertainty;
6. inspect contract, support, limits, roadmap and exit;
7. validate critical capabilities in a bounded environment;
8. record human decision and residual risk.

A demo is not an acceptance test. A questionnaire is evidence of a supplier declaration, not observed capability.

### 11. Prove common foundations

Before workload waves validate organizational boundaries, human/workload identity, emergency access, network/DNS/hybrid paths, logging/audit/metrics, keys/secrets/certificates, policy/quotas/cost allocation, backup/restore, build/deployment and support escalation.

A landing zone deployed successfully does not prove workloads can operate in it.

### 12. Select a representative bounded pilot

Choose a pilot that is low enough criticality for controlled learning, representative of meaningful dependencies, owned by an engaged team, reversible or forward-recoverable, measurable and supportable.

Do not select an unused static site and claim it validates database replication or regulated workloads.

### 13. Build dependency-aware waves

Wave size is bounded by migration throughput, application-owner availability, platform/security/review capacity, network/data movement, operations handover, business freezes and ability to recover concurrent failures.

Overlapping waves can improve throughput but increase shared-team load and unresolved-defect risk. Measure work in progress, not only starts.

### 14. Design coexistence and compatibility

For every transition answer:

- which versions and schemas interoperate;
- where writer authority lives and how it is fenced;
- how change is captured and ordered;
- how lag, duplicates and conflicts are handled;
- when rollback remains feasible;
- when forward recovery becomes mandatory.

The plan is incomplete until these are explicit.

### 15. Gate cutover

Before go, prove bulk copy/checksums and lag, target capacity/security/observability, compatibility, staffed business validation, writer fence/routing rehearsal, objective stop thresholds, timed recovery decisions and communication readiness.

The go/no-go owner should not be the only person who built the migration.

### 16. Treat recovery as a business transition

If failure occurs before target writes, traffic rollback may suffice. After target writes ask whether changes replicate back, source understands them, external providers observed effects, which record is authoritative and how gaps/duplicates reconcile.

If those answers are unsafe, stop calling DNS reversal “rollback.” Use tested forward recovery.

### 17. Complete handover and benefit measurement

Operations acceptance includes user-outcome dashboards, access/escalation, restore/incident runbooks, risks/exceptions, capacity/limit/cost signals, vendor support, ownership/SLO and rehearsal.

Measure benefits later against a comparable baseline. Avoid claiming savings when work, risk or cost merely moved.

### 18. Decommission from evidence

Before retirement prove no valid traffic remains, writer authority is target-side, records reconcile, retention/legal/deletion are approved, restore evidence remains, contracts close, credentials/routes/monitoring/backups retire safely and owners sign.

Deletion is separately authorized. This lab never performs it.

### 19. Feed outcomes back into strategy

After each wave update portfolio confidence, dependencies, team throughput, transfer/cutover distributions, transition/run cost, incident/support load, realized outcomes, risks/exceptions/vendor evidence and later choices.

Strategy that cannot change when evidence changes is branding, not engineering.

## Failure zoom

Architecture programs rarely fail because nobody drew a target diagram. They fail because a confident diagram hides an untested boundary. Learn to name the boundary before proposing a product.

### Failure 1: incomplete discovery becomes false certainty

Suppose seven days of network flow show no connection from settlement to the reporting system. The team marks the systems independent and places them in different waves. On the last business day of the month, settlement publishes a file that finance must consume before close. The migration succeeds technically and fails operationally.

The first bad assumption was not “the network tool missed a packet.” It was “one observation method over one short window represents the whole business cycle.”

Containment is to pause the dependent wave, preserve source and target evidence, restore the required business path, and reconcile any partial output. Correction is to combine:

- runtime flow over representative periods;
- configuration and code references;
- identity and certificate relationships;
- data-store and queue relationships;
- schedules, batch calendars and file exchanges;
- owner interviews and business-cycle events;
- failure and recovery dependencies.

Record each relationship with source, observation window, direction, criticality, confidence and owner. Absence of evidence is an `unknown` until the observation method was capable of detecting the relationship.

### Failure 2: a rationalization label becomes a migration method

“Replatform” does not tell an engineer which protocol changes, how state moves, whether identifiers remain stable, or how rollback works. It is a portfolio-level intent. A team that treats the label as an executable plan discovers the missing work during cutover.

For every selected strategy, attach a transition design:

| Portfolio choice | Transition questions that still remain |
|---|---|
| Retire | Who proves no business use, what retention applies, and how is access removed? |
| Retain | Which risks remain, who funds operation, and when is the decision reviewed? |
| Rehost | What changes in networking, identity, storage, licensing, backup and support? |
| Relocate | Which platform assumptions survive unchanged and which surrounding dependencies move? |
| Repurchase | How are data, identity, integrations, controls, contract and exit handled? |
| Replatform | Which managed behavior differs, how is compatibility tested, and how is state recovered? |
| Refactor | Which behavior is preserved, how is parity proved, and can old/new versions coexist? |

### Failure 3: target capacity works only when nothing has failed

An average throughput number is not capacity. If a service needs 20,312.5 RPS after growth and headroom, 34 instances at 600 RPS appear sufficient. Spread as 17 instances across each of three failure domains, however, the system provisions 51 instances. Losing one domain leaves 34 survivors and 20,400 RPS. That narrowly closes the declared target.

This arithmetic is still not a benchmark. CPU throttling, downstream quotas, connection pools, skew, retry amplification, storage latency and maintenance can make the sustainable per-instance rate lower. The correct conclusion is:

> Under the declared 600 sustainable RPS assumption, a three-domain 17/17/17 layout survives one complete domain loss with 87.5 RPS margin. Validate the rate and vary growth and headroom before approval.

Never convert a fragile assumption into a purchasing quantity without sensitivity analysis.

### Failure 4: bulk transfer is confused with cutover duration

The fictional dataset is 48 decimal TB. At 2.4 Gbit/s and 75 percent useful efficiency, bulk copy takes about 59.26 hours. That can occur while the source remains online. During those hours, a source changing at 20 GB/h accumulates roughly 1,185.19 GB. Final synchronization at 810 GB/h takes 1.46 hours; add 1.5 hours for validation and the cutover is about 2.96 hours.

The four-hour window closes on paper. It fails if:

- the measured throughput used binary units while the estimate used decimal units;
- change capture cannot reproduce order or deletes;
- validation time grows with record count;
- the final rate shares a throttled path with production;
- a schema change invalidates replay;
- external effects cannot be paused or reconciled.

Bulk duration answers “how long until a near-current copy exists?” Cutover duration answers “how long users experience restricted change while authority moves and correctness is proved?” They are related but not interchangeable.

### Failure 5: traffic rollback is mistaken for state rollback

At 10:00, target becomes the writer. At 10:07, an error appears. DNS is pointed back to source. Source is now seven minutes stale. The traffic route moved backward; state did not.

Safe recovery requires an explicit model:

1. Stop or fence writes so divergence stops growing.
2. Identify the authoritative log or store.
3. Account for acknowledged, pending and externally visible operations.
4. Choose a tested repair: replay target changes to source, restore from a checkpoint plus log, continue forward on target, or compensate external effects.
5. Reconcile counts, values, identities and business invariants.
6. Reopen traffic only under named incident authority.

Dual writing is not a magic escape. It creates ordering, partial-success, retry, conflict and idempotency problems. If dual write is required, specify the coordinator, durable intent, replay key, conflict rule and reconciliation process.

### Failure 6: a vendor score averages away a veto

The lab gives two suppliers the same weighted preference score: 3.95. The managed suite has no credible exit plan. It is infeasible even though its score is high.

Use this order:

1. prove the requirement and decision authority;
2. apply hard legal, security, residency, export, operational and lifecycle constraints;
3. perform supply-chain and technical due diligence;
4. compare weighted preferences among feasible options;
5. test score sensitivity;
6. bind claims into contract and acceptance evidence;
7. validate the integration and exit mechanics.

A score describes preference under a model. It does not create missing evidence and it does not own risk.

### Failure 7: “30 percent cheaper” compares different meanings

The fictional current service costs USD 2.4 million per year. The proposed run cost is USD 1.85 million per year with USD 1.8 million one-time transition cost. Over 36 months:

- current counterfactual: `3 × 2.4m = 7.2m`;
- proposal: `3 × 1.85m + 1.8m = 7.35m`;
- net saving: `7.2m - 7.35m = -0.15m`;
- simple break-even: `1.8m / ((2.4m - 1.85m) / 12) = 39.27 months`.

It does not break even within the decision horizon. The proposal may still be correct because it removes an unacceptable facility risk or enables faster delivery, but those outcomes must be measured honestly. Do not relabel them as savings.

### Failure 8: the platform is ready but operations is not

Health checks pass after a wave, yet the support team has no access, alerts route to the project team, restore has never been rehearsed, and the runbook names retired endpoints. This is not handover.

Operations acceptance should require:

- named service and on-call ownership;
- least-privilege access tested by the receiving team;
- actionable service-level alerts and dashboards;
- failure, restore and reconciliation procedures rehearsed;
- capacity, dependency, certificate and quota limits documented;
- support, vendor and escalation contacts verified;
- known risks, exceptions and expiry dates accepted;
- cost allocation and benefit measurement active.

### Failure 9: decommission is used to force completion

Removing the source early may make a dashboard appear green, but it destroys recovery evidence. Decommission only after traffic, writers, reconciliation, retention, legal hold, backup, restore, contracts, routes, credentials, monitoring and ownership are each closed by the correct authority.

“The migration deadline passed” is not deletion authority.

### A reusable failure lens

When a program feels confused, ask five questions:

1. **State:** What fact, data or authority changes?
2. **Owner:** Who can decide, operate, accept risk and authorize deletion?
3. **Evidence:** Is the claim observed, declared, inferred or unknown?
4. **Time:** What happens before, during and after coexistence?
5. **Recovery:** What exact state can be restored or reconciled after the point of no return?

These questions work in a design review, vendor meeting, migration bridge or post-incident review.

## Internals and state ownership

An architecture program has multiple control planes. Confusing them creates gaps or accidental centralization.

### The strategy control plane

This plane holds the mandate, outcomes, scope, non-goals, principles, risk appetite, investment envelope, portfolio choices, roadmap and review triggers. A strategy sponsor owns business direction; an architecture authority ensures decisions remain coherent; neither should silently approve production change.

### The evidence control plane

This plane holds inventory records, dependency observations, confidence labels, benchmarks, cost sources, risk evidence, vendor responses and observation windows. Every material fact needs:

- a stable identifier;
- a definition and unit;
- a source and collection method;
- the time or version observed;
- a confidence label;
- an accountable owner;
- an expiry or next review;
- links to decisions that consume it.

Updating evidence must not rewrite history. A decision made against version 3 should still be reviewable after version 4 arrives.

### The decision control plane

An architecture decision record records context, feasible options, constraints, chosen option, owner, consulted parties, rationale, evidence version, consequences and review trigger. An exception record adds the violated standard, compensating control, risk owner and expiry.

Decision rights can be expressed with a small table:

| Decision | Proposes | Consults | Approves | Executes | Verifies |
|---|---|---|---|---|---|
| Portfolio rationalization | workload owner | architecture, finance, security, operations | portfolio authority | program team | governance review |
| Target standard | platform/architecture | product teams, security, operations | architecture authority | platform teams | conformance evidence |
| Wave go/no-go | wave lead | owners, support, security | change authority | migration team | independent gate owner |
| Risk acceptance | control owner | security/legal/operations | named risk owner | delivery team | governance/audit |
| Source deletion | service/data owner | legal, security, records, operations | deletion authority | authorized operator | evidence reviewer |

The same person may occupy several roles in a small organization, but the responsibilities must still be explicit.

### The execution control plane

This plane owns project backlog, foundation readiness, pilots, waves, change windows, tests, cutover, recovery and handover. Its state changes quickly. It must consume approved strategy and return measured outcomes; it must not silently redefine business goals because delivery became difficult.

### The runtime control plane

This plane owns identities, routes, configurations, quotas, writer leases, schemas, replication checkpoints, telemetry, backups and production health. During migration, source and target may each have runtime state. Declare which system is authoritative for:

- reads;
- writes;
- identity and authorization;
- configuration;
- event ordering;
- schema;
- durable recovery;
- externally visible side effects.

“Both are authoritative” is usually an unresolved conflict.

### The commercial and supply-chain control plane

Contracts, service descriptions, data-processing terms, sub-processors, support commitments, vulnerability processes, licensing, renewal, price adjustment, export formats, deletion confirmation and termination assistance are architecture inputs. Marketing material is evidence of a claim, not a binding commitment.

Procurement owns commercial process; security owns security judgment; legal owns legal interpretation; technical teams own validation; the accountable business authority owns the combined choice. No one-dimensional score replaces these roles.

### The benefit and risk control plane

Benefit registers must name a baseline, counterfactual, measure, owner, collection cadence and attribution caveat. Risk registers must name scenario, cause, consequence, likelihood, impact, controls, residual exposure, owner and trigger.

Keep these two registers connected. A benefit that depends on accepting new concentration risk is not wrong, but the trade must be visible.

### Ownership changes over time

Ownership should move deliberately:

```text
strategy sponsor
      |
      v
portfolio decision owner
      |
      v
wave/change authority
      |
      v
target service owner + on-call
      |
      v
records/deletion authority closes source
```

Handover is not a document upload. It is the receiving owner demonstrating access, diagnosis, recovery and decision capability.

## Evidence table

Use different evidence classes because they support different claims.

| Evidence class | Meaning | Example | Safe use | Unsafe leap |
|---|---|---|---|---|
| Observed | Captured directly by a known method | 95th percentile requests from a named metric over 30 days | Size a test range with caveats | Call it future peak demand |
| Declared | Supplied by an accountable source | Owner says quarter close is critical | Add business-cycle discovery and validation | Treat memory as measured fact |
| Inferred | Derived from other evidence | Shared database suggests coupling | Prioritize investigation | Declare a hard dependency |
| Unknown | Material fact not established | No restore test evidence | Create closure work or bound risk | Replace with a convenient default |
| Estimated | Calculated from assumptions | 59.26-hour bulk copy | Compare scenarios and sensitivity | Promise delivery duration |
| Tested | Reproduced under named conditions | 600 sustainable RPS in a test profile | Support that specific envelope | Claim all production traffic is safe |
| Contractual | Binding commitment in applicable terms | Export format and assistance in signed schedule | Hold supplier to the term | Assume implementation works |
| Decided | Authorized choice with rationale | ADR selects portable platform | Direct scoped work | Treat decision as permanent truth |
| Realized | Outcome measured after change | Error budget and cost per transaction after wave | Review benefits and strategy | Attribute every change to migration |

### The minimum portfolio row

For each workload, capture:

| Field | Why it exists |
|---|---|
| stable ID and name | Prevent aliases from splitting or merging records accidentally |
| service/business capability | Connect infrastructure to user outcome |
| accountable owner and support team | Bind validation, risk and handover |
| lifecycle and criticality | Distinguish investment from retirement and sequence risk |
| runtime/deployment locations | Establish present boundaries without assuming completeness |
| data class, residency and retention | Bound security, legal and movement decisions |
| demand and business calendar | Reveal peaks, freezes and batch cycles |
| dependencies with direction | Form groups and transition contracts |
| recovery objectives and evidence | Keep continuity requirements explicit |
| current cost meaning and source | Enable comparable economics |
| rationalization choice and rationale | Preserve why the target was selected |
| evidence version, confidence and expiry | Prevent stale certainty |

### A claim ledger

For every statement used to approve investment or change, retain this chain:

```text
claim
  -> definition and unit
  -> evidence source and window
  -> assumptions and uncertainty
  -> calculation or test
  -> reviewer
  -> decision that consumed it
  -> outcome that later confirmed or challenged it
```

Example:

> Claim: target must sustain 20,312.5 RPS after one failure domain is lost.

- Definition: accepted API requests per second at the service boundary.
- Inputs: 8,000 current peak, 25 percent annual growth for three years, 30 percent headroom.
- Assumptions: compound growth, unchanged request mix, no retry amplification.
- Calculation: `8000 × 1.25^3 × 1.30 = 20312.5`.
- Test still required: representative workload at the dependency and failure envelope.
- Decision use: minimum candidate topology, not final purchasing authority.

### Evidence freshness

Evidence decays at different rates. A signed retention policy may remain valid for a year; service traffic, pricing and quota evidence may change weekly. Set expiry from volatility and consequence. If expired evidence supports a go/no-go gate, either refresh it or let an authorized owner explicitly accept the uncertainty.

### Evidence is not volume

Ten dashboards do not outweigh one missing writer-authority test. Prefer evidence that closes a decision boundary. A useful review asks:

- Which decision could change because of this item?
- What collection method can be wrong?
- What period or failure mode is absent?
- Who can challenge the interpretation?
- When does it expire?

That is how an architecture repository becomes a decision system rather than a document warehouse.

## Command decoders

Run these commands only from `support/lab` in Ubuntu 24.04 as a normal user. They read fictional JSON and create at most one UID-scoped directory under `/tmp`. They do not inspect the computer, cloud account, employer estate or vendor.

### Command 1: prove the boundary before creating state

```bash
bash lab.sh doctor
```

Expected:

```text
model=valid cases=71 gates=70 calculations=5
doctor=pass network=none user=1000 runtime_calls=none
```

`model=valid` means both JSON fixtures passed structural and conservation checks. `cases=71` is one defensible baseline plus 70 single-boundary failures. `user=1000` is the example unprivileged UID, not a required literal value. `network=none` and `runtime_calls=none` describe this program's behavior; they are not a network sandbox proof.

If it returns `lab=fail reason=root-refused`, leave the root shell and rerun as a normal user. If it names a credential or runtime authority, use a clean teaching shell; do not unset credentials in a shell where active work depends on them.

### Command 2: initialize the bounded copy

```bash
bash lab.sh setup
```

It creates `/tmp/reliability-atlas-les0083-strategy-$(id -u)` with mode-limited copied fixtures and a sentinel. Expected:

```text
model=valid cases=71 gates=70 calculations=5
setup=pass state=/tmp/reliability-atlas-les0083-strategy-1000
```

`setup` proves deterministic local initialization. It does not create a cloud foundation, inventory anything, contact a supplier or migrate data. If state already exists, inspect it with `status`; do not delete an unfamiliar directory.

### Command 3: confirm identity, not correctness

```bash
bash lab.sh status
```

Expected fields:

```text
status=ready cases=71 strategy_id=fictional-payments-modernization state=/tmp/reliability-atlas-les0083-strategy-1000 runtime_calls=none
```

This answers “did I load the reviewed fixture?” It does not answer “is this strategy right?” Identity checks prevent a correct analysis of the wrong dataset.

### Command 4: decode the lifecycle

```bash
bash lab.sh roadmap
```

Expected:

```text
roadmap=pass strategy_id=fictional-payments-modernization stages=discover->rationalize->foundation->pilot->waves->reconcile->decommission decision=human-owned provider_calls=none
```

Read the arrows as evidence transfers, not a promise that work is strictly linear. Discovery continues during waves; outcomes revise rationalization; a failed pilot can revise foundations. `decision=human-owned` prevents the model from becoming an approval engine.

### Command 5: measure inventory confidence

```bash
bash lab.sh inventory
```

Expected:

```text
inventory=pass total=120 observed=72 declared=30 unknown=18 observed_pct=60.00 unknown_pct=15.00 evidence_not_uniform=true
```

The conservation check is:

```text
72 observed + 30 declared + 18 unknown = 120 total
observed percent = 72 / 120 × 100 = 60.00%
unknown percent  = 18 / 120 × 100 = 15.00%
```

Do not average confidence across fields. A workload may have observed CPU demand and unknown data retention. Prioritize unknowns by decision consequence, not merely by count.

### Command 6: calculate failure-aware capacity

```bash
bash lab.sh capacity
```

Expected:

```text
capacity=pass future_peak_rps=15625.00 target_rps=20312.50 healthy_instances=34 per_domain=17 provisioned_instances=51 surviving_rps=20400.00 assumptions_require_validation=true
```

Decode it:

```text
future peak = 8000 × (1 + 0.25)^3 = 15625 RPS
target      = 15625 × (1 + 0.30) = 20312.5 RPS
healthy     = ceil(20312.5 / 600) = 34 instances
per domain  = ceil(34 / (3 - 1)) = 17 instances
provisioned = 17 × 3 = 51 instances
survivors   = 17 × 2 × 600 = 20400 RPS
```

The calculation assumes one whole failure domain is unavailable and the other two accept load evenly. It does not include control-plane failure, correlated dependency loss or degraded per-instance performance.

### Command 7: separate bulk copy from cutover

```bash
bash lab.sh transfer
```

Expected:

```text
transfer=pass bulk_hours=59.26 source_delta_gb=1185.19 final_sync_hours=1.46 validation_hours=1.50 cutover_hours=2.96 window_hours=4.00 closes=true decimal_units=true
```

The model uses decimal units: one TB is 1,000 GB and one byte is eight bits.

```text
useful link = 2.4 Gbit/s × 0.75 = 1.8 Gbit/s
bulk hours  = 48,000 GB × 8 / 1.8 / 3600 = 59.26 h
delta       = 59.26 h × 20 GB/h = 1185.19 GB
final sync  = 1185.19 / 810 = 1.46 h
cutover     = 1.46 + 1.50 = 2.96 h
```

`closes=true` means arithmetic closure under inputs, not that replication preserves semantics or that throughput will be achieved.

### Command 8: expose the economic claim

```bash
bash lab.sh economics
```

Expected:

```text
economics=pass horizon_months=36 current_total=7200000.00 proposed_total=7350000.00 net_saving=-150000.00 break_even_months=39.27 breaks_even_within_horizon=false benefits_excluded=true
```

`benefits_excluded=true` is important. The model compares only declared cost. Reliability, delivery speed, risk removal or revenue benefit require separate measures and cannot be invented to rescue the result.

### Command 9: apply veto before preference

```bash
bash lab.sh vendor
```

Expected:

```text
vendor=pass managed_suite=3.95 portable_platform=3.95 managed_suite_veto=exit-plan feasible_selected=portable-platform score_is_advisory=true decision_authority=human-review-required
```

A tie is not the deciding fact. The managed suite fails a hard lifecycle requirement. The portable platform remains a feasible candidate, not an automatic winner. Due diligence, contract, proof and accountable approval remain.

### Commands 10 and 11: inspect one isolated failed boundary

```bash
bash lab.sh show current-state-asserted-without-evidence
bash lab.sh evaluate current-state-asserted-without-evidence
bash lab.sh evaluate cutover-window-does-not-close
```

`show` prints the case record so you can inspect expected and actual boundaries. `evaluate` recomputes whether that single failure is correctly classified. Expected classifications include:

```text
case=current-state-asserted-without-evidence boundary=current-state
case=cutover-window-does-not-close boundary=cutover
```

The first says a target cannot repair an untrusted baseline. The second says a transition that exceeds the authorized window is infeasible even if the target design is attractive.

Use `bash lab.sh list` to see all case names and `bash lab.sh evaluate-all` to check every gate. Do not memorize 70 labels. Learn to locate the first violated boundary.

### Command 12: verify lifecycle and refusal

From absent state:

```bash
bash verify.sh
```

The verifier runs doctor, setup, all calculations, all 71 cases, unknown-artifact refusal, cleanup and exact absence checks. The final line is:

```text
verify=pass cases=71 calculations=5 refusal=true cleanup=true runtime_calls=none
```

If it fails, preserve the first error. A later cleanup message cannot turn an earlier failed assertion into a pass. This proves the fictional software lifecycle only; it proves no learner mastery, production readiness or strategic fitness.

## Decision path

Use this path when a proposal, supplier or migration is placed in front of you.

### Step 1: restate the decision

Write one sentence:

> By [date/review trigger], [named authority] must decide [choice] for [scope] to improve [measured outcomes], within [constraints and risk appetite].

If the sentence says only “adopt platform X,” the outcome is missing. If nobody is named, authority is missing.

### Step 2: expose unknowns that can reverse the choice

Do not try to discover everything equally. Ask which unknown could:

- make the target illegal or insecure;
- split or join a migration dependency group;
- invalidate capacity or cutover;
- change the financial ranking;
- make exit or recovery impossible;
- prevent operations acceptance.

Close those first or bound them with named risk acceptance.

### Step 3: form feasible options

Include “retain,” “retire,” staged change and hybrid/coexistence where meaningful. Remove an option only with a recorded constraint, not because the team already prefers a technology.

### Step 4: apply vetoes

Check legal, security, residency, correctness, recovery, export, support and lifecycle constraints before weighted comparison. A hard veto can be accepted only by the authority that owns that risk, with duration and compensating control; a spreadsheet cannot accept it.

### Step 5: compare ranges

Present demand, capacity, schedule, transfer, cost and benefits as:

- base input and source;
- low/base/high or distribution;
- formula and unit;
- sensitivity drivers;
- excluded effects;
- expiry and validation plan.

An executive may want one number. Give the decision range first, then state the planning number and why.

### Step 6: choose reversible commitment

Separate:

1. information-gathering work;
2. proof-of-concept;
3. bounded pilot;
4. production wave;
5. irreversible contract, deletion or dependency.

Approve only the next commitment justified by evidence. A pilot should buy information, not disguise a full rollout.

### Step 7: gate the transition

Before go/no-go, require current evidence for user outcome, data correctness, security, capacity, observability, support, writer authority, cutover time, recovery and communication. Name stop authority before the bridge begins.

### Step 8: measure outcome and revisit strategy

After the wave, compare realized behavior with the claim ledger. Update evidence confidence, unit cost, incident load, support load, throughput, transfer variance and user outcome. Trigger review when assumptions leave their approved range.

### A concise decision record

```text
Decision:
Owner and date:
Outcome and scope:
Options considered:
Hard constraints/vetoes:
Evidence version and confidence:
Capacity/cost/schedule ranges:
Security, reliability and exit consequences:
Chosen option and why:
What would change the decision:
Next reversible commitment:
Exceptions, owner and expiry:
Outcome review date:
```

This record is short enough to use and rich enough to challenge.

## Guided Ubuntu lab

This exercise teaches reasoning with safe fictional state. It deliberately cannot discover your machine or migrate anything.

### Before you begin

You need Ubuntu 24.04, Bash and Python 3. Run as a normal user. From the repository:

```bash
cd drafts/LES-0083-architecture-strategy-migration-governance/support/lab
id
python3 --version
bash lab.sh doctor
```

Stop if `id` says `uid=0(root)`. The lab refuses root because a teaching model needs no administrative authority. Do not use `sudo` to make a failed guard disappear.

### Exercise A: build an evidence-confidence explanation

Initialize and inspect:

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh inventory
```

Write four sentences in your own notes:

1. How many portfolio items are directly observed?
2. Why are 30 declared items not equivalent to 72 observed items?
3. What does an unknown item permit you to conclude?
4. Which unknowns would you close before selecting a pilot?

Then inspect the source without editing it:

```bash
python3 -m json.tool fixtures/strategy.json | less
```

Press `q` to leave `less`. Find `portfolio` and confirm that the four classes conserve the total. The answer is not “discover all 120 again.” The senior answer is “close the unknown facts that can reverse the next decision, while retaining confidence per field.”

### Exercise B: challenge the capacity estimate

```bash
bash lab.sh capacity
```

Recalculate by hand:

```text
8000 × 1.25 × 1.25 × 1.25 = 15625
15625 × 1.30 = 20312.5
ceil(20312.5 / 600) = 34
ceil(34 / 2 surviving domains) = 17 per domain
17 × 3 = 51 provisioned
17 × 2 × 600 = 20400 surviving RPS
```

Now answer:

- What input would you vary first?
- Why is 20,400 only 87.5 RPS above target?
- What happens if the sustainable rate falls to 550 RPS?
- Which downstream dependency could become the actual limit?

At 550 RPS, the existing two-domain survivor capacity is `17 × 2 × 550 = 18,700 RPS`, so it fails the target. The topology must change or the sustainable rate must be restored and proved.

### Exercise C: explain why transfer “closes” but is unapproved

```bash
bash lab.sh transfer
```

Draw this on paper:

```text
source online
   |----- 59.26 h bulk copy -----|
   |----- changes accumulate ----| 1185.19 GB
                                  |-- 1.46 h final sync --|
                                                        |-- 1.50 h validate --|
                                  <------ 2.96 h cutover ------> within 4 h
```

List three ways reality can invalidate the estimate. Good examples are lower useful throughput, higher change rate, longer validation, replay incompatibility or shared-path throttling.

Then answer: if the cutover window is two hours, does faster bulk copy automatically help? Not necessarily. The window is dominated by final delta and validation. You must reduce change rate, increase safe final throughput, reduce validated scope with equivalent evidence, change the transition method or obtain a different window.

### Exercise D: defend an honest business case

```bash
bash lab.sh economics
```

Practice saying this aloud:

> The three-year cost comparison is USD 150,000 unfavorable and simple break-even occurs at 39.27 months, outside the 36-month horizon. I would not claim savings. I would ask whether measured risk reduction, delivery capability or facility-exit necessity justifies the investment, and I would keep those outcomes separate from cost.

Now identify costs the tiny model excludes: parallel operations, people, training, support tiers, network transfer, taxes, licenses, contract exit, stranded assets, risk, opportunity cost and decommission. Exclusion does not mean every item is material; it means the reviewer must know what is absent.

### Exercise E: refuse a misleading vendor result

```bash
bash lab.sh vendor
```

Answer:

1. Did the portable platform “win”? No. It is the only feasible candidate in this small fixture and still needs review.
2. Can an executive waive the exit requirement? Only if that executive actually owns the legal, security, operational and business exposure under the organization's governance; affected control owners must still be involved and the exception bounded.
3. What should be tested? Export completeness, usable format, identity and data deletion, dependency replacement, time/cost, contract assistance and operation after supplier loss.

### Exercise F: learn boundary-first diagnosis

```bash
bash lab.sh list | head
bash lab.sh show vendor-exit-plan-unbound
bash lab.sh evaluate vendor-exit-plan-unbound
bash lab.sh show dual-writer-authority
bash lab.sh evaluate dual-writer-authority
bash lab.sh evaluate-all
```

For each shown case, state:

- the first unsafe assumption;
- the evidence needed;
- the authority who can accept residual risk;
- the next reversible action.

If a case name differs from your expectation, use `bash lab.sh list` and select the exact emitted name. Do not invent a case or edit the fixture merely to make a command pass.

### Exercise G: observe safe refusal and cleanup

The verifier exercises refusal automatically:

```bash
bash verify.sh
```

You can inspect normal cleanup separately:

```bash
bash lab.sh setup
bash lab.sh cleanup
test ! -e "/tmp/reliability-atlas-les0083-strategy-$(id -u)" && echo "state absent"
```

If `setup` reports existing state after the verifier, stop and inspect. Do not recursively remove a computed path. The lab cleanup deletes only the sentinel and two known fixture copies, then removes the empty directory.

### Guided completion standard

Reading output is not completion. You should be able to explain, without the page:

- why confidence belongs to individual facts;
- why capacity includes a failure envelope;
- why bulk and cutover time differ;
- why a negative cost result can coexist with a valid strategic choice;
- why veto precedes score;
- why traffic reversal is not state rollback;
- why decommission has separate authority.

This is practice evidence, not a mastery award.

## Production transfer

The lab's method transfers to production; its numbers do not. Use the following staged procedure with organizational approval.

### Stage 0: establish legal and security handling

Before collecting estate or supplier data, agree where it may be stored, who may access it, how long it is retained and what must be sanitized. Architecture inventories and contracts can reveal critical systems, vulnerabilities, customer relationships and commercial terms. Never paste employer-confidential data into this public learning repository.

### Stage 1: create a read-only evidence packet

Start with authorized exports from existing asset, service, identity, monitoring, cost, configuration, recovery and ownership systems. Record source and timestamp. Do not install discovery agents or scan networks merely because inventory is incomplete.

Reconcile identifiers across sources and retain disagreements:

```text
service catalog says owner=A
deployment metadata says team=B
on-call route says team=C
result: owner=unknown, candidates=A/B/C, closure task assigned
```

The wrong response is to choose the most convenient value.

### Stage 2: sample across the business cycle

Choose observation windows that include daily, weekly, month-end, quarter-end, certificate rotation, release, backup, restore and incident behavior where applicable. Add owner workshops because runtime telemetry cannot reveal every manual or contractual dependency.

### Stage 3: rationalize with workload owners

For each workload, compare all feasible choices against business need, lifecycle, risk, value and transition complexity. Record the choice as provisional when a decision-changing unknown remains. Make retirement an investigated option; moving unused software is waste.

### Stage 4: prove the foundation

Validate identity, account/project/subscription organization, network paths, name resolution, time, certificates, secrets, policy, logging, key management, quotas, images, artifact provenance, backup, recovery, cost allocation and support. Test failure paths and operator access.

Use provider plan, policy and dry-run mechanisms where available. For infrastructure-as-code, run formatting, validation, static/security checks and a reviewed plan before apply. For Kubernetes, scope namespace/context explicitly and prefer server-side dry run and `kubectl diff` before approved mutation.

### Stage 5: run a representative bounded pilot

A good pilot is important enough to expose real constraints, small enough to recover, and representative of dependencies and operations. Define the learning questions before selecting it. A toy stateless service can validate a pipeline but cannot validate state migration.

Pilot exit criteria should include user outcome, error budget behavior, security controls, achievable capacity, recovery, operational acceptance, unit cost and discovered exceptions.

### Stage 6: form waves from dependencies and capacity

Group workloads that must transition together; sequence around business freezes; limit work in progress to engineering and operations capacity. Reserve capacity for incidents and discovered work.

Do not calculate velocity from the first easy wave and extrapolate blindly. Track distributions:

- preparation lead time;
- execution time;
- cutover and validation duration;
- defect and rollback/repair rate;
- support load;
- new dependency discovery;
- cost and benefit variance.

### Stage 7: approve the exact production change

The change record should bind:

- source and target identities;
- versions, schemas and compatibility range;
- route and writer-authority transitions;
- copy checkpoint and replication lag;
- validation queries and business invariants;
- user and security signals;
- stop, rollback and forward-recovery conditions;
- named decision and execution roles;
- communications;
- retention and decommission gates.

Approval of the program does not approve this cutover.

### Stage 8: operate coexistence deliberately

During coexistence, monitor source and target plus the bridge between them. Protect against configuration drift and incompatible releases. If source and target accept different schema versions, define expand/migrate/contract sequencing.

Keep one writer authority unless a deliberately designed multi-writer protocol exists. Measure lag and reconciliation backlog. A green target with a red replication path is not healthy.

### Stage 9: hand over and realize benefits

The receiving team demonstrates:

- access and dashboard interpretation;
- incident triage;
- deploy and rollback or forward repair;
- restore and reconciliation;
- capacity and cost diagnosis;
- vendor escalation;
- exception and certificate renewal;
- runbook use under simulation.

Continue measuring the counterfactual and agreed outcomes. Report uncertainty and external changes so the program does not claim unrelated benefit.

### Stage 10: decommission under separate authorization

Prove no valid traffic or writer remains. Close data retention, legal hold, backup/restore, credentials, network, monitoring, license, support and contract obligations. Preserve auditable evidence. Execute deletion only through the organization's authorized process.

### What to retain for review

Retain sanitized, access-controlled versions of:

- mandate and decision rights;
- portfolio/evidence version;
- rationalization and ADRs;
- risk, exception and assumption logs;
- foundation and pilot evidence;
- wave and change decisions;
- cutover/recovery/reconciliation results;
- handover acceptance;
- cost and benefit receipts;
- decommission approvals.

Retention itself must follow applicable policy; “keep everything forever” is not governance.

## Reliability, security, observability, capacity, and cost

These qualities are not review chapters added after vendor selection. They shape the feasible architecture.

### Reliability

Define user journeys and failure consequences before availability numbers. Map service-level indicators, objectives, error budgets, recovery objectives, dependency budgets and maintenance behavior. Evaluate source, transition and target states—not just the final diagram.

Ask whether the proposed platform reduces one failure mode while introducing concentration, control-plane or supplier dependence. Require tested recovery at the scope and time the business needs.

### Security and supply chain

Threat-model identities, administrative paths, build and artifact provenance, data movement, temporary stores, replication channels, logs, backups, support access and decommission. Verify least privilege and separation of duties at transition time, when teams often create broad temporary access.

For suppliers, request evidence for secure development, vulnerability disclosure and remediation, component transparency, support lifecycle, incident notification, sub-processors, data handling, export and deletion. Evidence must match the service and version being purchased.

### Observability

Build signals around decisions:

- Is user outcome preserved?
- Is state converging?
- Is a dependency or quota limiting capacity?
- Is cost moving because of demand, waste, rate or allocation?
- Is an exception nearing expiry?
- Is a claimed benefit materializing?

During migration, correlate source and target identifiers. Preserve enough traceability to explain duplicates, missing operations and latency changes. Avoid sending sensitive payloads into logs merely to make debugging easier.

### Capacity and performance

Model demand distribution, growth, headroom, workload mix, concurrency, latency, sustainable resource rate, dependency quotas and failure envelopes. Distinguish request rate from useful completed work. Retries can make infrastructure busier while users achieve less.

Validate with representative tests and controlled failure. Record the limiting resource and saturation signature. Recompute after each wave because consolidation, tenancy and workload mix change the result.

### Cost and financial operations

Make cost attributable to a product, environment and driver. Separate:

- recurring run cost;
- one-time transition;
- parallel-operation and stranded cost;
- people and support;
- network and data movement;
- license and commitment;
- risk and opportunity;
- exit and decommission;
- measurable benefit.

Compare the same currency, period, tax treatment, allocation and service level. Show unit economics such as cost per successful transaction alongside total spend. A lower bill caused by lost traffic is not efficiency.

### The five-way trade review

For every material option, write one consequence under each heading:

| Quality | Prompt |
|---|---|
| Reliability | What new failure mode or recovery dependency appears? |
| Security | What identity, data or supply-chain boundary changes? |
| Observability | What evidence is needed to operate and reconcile it? |
| Capacity | What demand and failure envelope must it survive? |
| Cost | Which recurring, transition, opportunity and exit costs change? |

If an option contains only benefits, the analysis is incomplete.

## Traps and prevention

| Trap | Why capable teams fall into it | Prevention |
|---|---|---|
| Mandate literalism | Urgency is mistaken for a complete decision | Translate intent into outcome, constraints, authority and review triggers |
| Provider-first architecture | Product familiarity narrows options before requirements exist | Define outcomes, principles and hard constraints before products |
| Migration by spreadsheet | A row status hides runtime, state and authority transitions | Link portfolio choice to transition design and gate evidence |
| One strategy for every workload | Standardization feels efficient | Rationalize per workload, then standardize reusable transition patterns |
| Discovery equals truth | Tool output appears objective | Preserve method, window, confidence and business validation |
| Weighted score authority | Arithmetic looks neutral | Apply vetoes first, sensitivity-test preferences, keep human ownership |
| Cheapest list price | Different meanings and omitted costs are compared | Normalize period, service, allocation, transition, risk and exit |
| Pilot theater | An easy demo cannot expose hard constraints | Select a representative bounded pilot with learning questions |
| Wave-size optimism | More parallel work appears faster | Limit by dependency, team, change and operations capacity |
| Green infrastructure equals success | Host health is easier to measure than user outcome | Gate on journeys, correctness, security, operations and benefits |
| DNS rollback | Routing is confused with state restoration | Bind writer authority, checkpoints, replay and reconciliation |
| Permanent exception | Delivery pressure removes an important control | Name risk owner, compensation, expiry and closure evidence |
| Premature source deletion | Irreversibility is used to force commitment | Separate decommission and deletion authority from wave completion |
| Architecture police | Governance becomes centralized ticket approval | Publish principles and paved paths; centralize only material exceptions |
| Frozen strategy | Changing a plan appears weak | Predefine evidence thresholds and review triggers |

### The prevention habit

Before approving any architecture or migration statement, complete this sentence:

> This claim is supported by **[evidence class and version]**, is valid within **[conditions and time]**, is owned by **[role]**, and must be revisited when **[trigger]**.

If you cannot fill one field, you have found the next engineering task.

## Memory card and retrieval

### One-page memory card

```text
INTENT
  outcome + scope + non-goals + constraints + risk appetite + horizon + owner

EVIDENCE
  observed / declared / inferred / unknown
  source + window + unit + confidence + owner + expiry

OPTIONS
  retire | retain | rehost | relocate | repurchase | replatform | refactor
  hard vetoes before weighted preferences

QUANTIFY
  demand × compound growth × headroom
  capacity must survive declared failure
  bulk copy != cutover
  current counterfactual vs target run + transition + exit
  range + sensitivity, never unsupported precision

TRANSITION
  foundation -> representative pilot -> dependency waves
  compatibility + one writer + replication checkpoint
  cutover + validation + recovery + reconciliation
  handover -> benefit evidence -> authorized decommission

GOVERN
  decision owner + evidence version + exception owner/expiry
  go/no-go + stop + risk acceptance + deletion are distinct authorities

REMEMBER
  A target diagram is not a transition architecture.
  Traffic rollback is not state rollback.
  A score cannot average away a veto.
  Strategy changes when evidence changes.
```

### Retrieval questions

Answer without scrolling, then compare with the complete answers.

1. Why is “move 120 applications in 18 months” not yet a strategy?
2. What is the practical difference between observed, declared, inferred and unknown evidence?
3. Why should evidence confidence attach to a field rather than only to a workload?
4. Name the seven rationalization choices and the question that must come first.
5. How do a principle, standard, guardrail and pattern differ?
6. Why are governance and management not synonyms?
7. Why must hard vendor vetoes be evaluated before weighted scores?
8. What does a tied score of 3.95 prove in the lab?
9. Calculate the three-year future peak from 8,000 RPS at 25 percent annual growth.
10. Why does the lab provision 51 instances when only 34 appear healthy-capacity sufficient?
11. What does `assumptions_require_validation=true` tell a reviewer?
12. Why are bulk-copy time and cutover time different?
13. What makes the fictional four-hour cutover close, and what remains unproved?
14. Why does the fictional proposal fail the 36-month cost-saving claim?
15. Why can a proposal with negative net savings still be strategically valid?
16. Explain why changing DNS back is not state rollback.
17. What makes a pilot representative rather than merely easy?
18. Which evidence must be complete before operations accepts a migrated service?
19. Why is decommission a separate decision from migration completion?
20. What five questions form the reusable failure lens?

## Complete answers

### Answer 1: intent is not yet an executable choice

The sentence supplies a target count, duration and cost aspiration, but it does not establish the business problem, baseline, service outcomes, scope boundaries, legal/security constraints, risk appetite, investment authority, rationalization choices or review triggers. It may be a valid executive intent. Engineering turns it into a strategy by defining the decisions and evidence required to achieve the underlying outcome. Treating the sentence as complete would hide whether some workloads should be retired or retained and whether “30 percent” compares equivalent costs.

### Answer 2: the four confidence classes

**Observed** means captured directly by a named method during a named period. **Declared** means an accountable person or system states it but direct observation has not established it. **Inferred** means other evidence suggests it—for example a shared database suggests coupling. **Unknown** means the fact remains unestablished.

None is automatically useless. A declared quarter-close dependency may be critical. The label tells the decision-maker how the claim was obtained, how it could be wrong and what validation remains. Unknown never means absent.

### Answer 3: confidence belongs to each fact

A single workload can have highly trustworthy demand metrics, a declared owner, an inferred dependency and unknown retention. Giving the workload one “80 percent confidence” score blends materially different decisions. Field-level confidence lets you close the unknown that can reverse the next choice without re-discovering facts that are already adequate.

### Answer 4: rationalization starts with need

The choices are **retire, retain, rehost, relocate, repurchase, replatform and refactor**. First ask whether the business capability is still needed. Then ask whether change is justified. Only then compare movement, purchase or modernization choices. This order prevents teams from spending money moving unused or appropriately retained software.

### Answer 5: four mechanisms with different force

A **principle** expresses durable decision intent, such as preferring recoverable change. A **standard** sets a testable requirement, such as an approved identity protocol and version. A **guardrail** enforces or detects a boundary through policy, pipeline or review. A **pattern** is a reusable implementation with known trade-offs. If every preference is called a standard, exceptions explode; if every standard is merely advisory, governance becomes theater.

### Answer 6: governance sets direction and accountability

Governance evaluates needs, directs priorities and monitors outcomes on behalf of accountable authority. Management plans and executes within that direction. A governance body should not become the team performing every design, and a delivery manager should not silently accept enterprise risk. The distinction keeps decision rights visible while allowing decentralized implementation.

### Answer 7: vetoes define feasibility

A weighted score permits strength in one area to compensate for weakness in another. Some requirements are not compensatory: unlawful residency, unmitigated critical security exposure, inability to recover, unusable export or no support through the required lifecycle. Those remove an option or require explicit acceptance from the owner of that risk. Only feasible options should be compared by preferences.

### Answer 8: the tie proves almost nothing about selection

The 3.95/3.95 result proves the fixture's declared weights and ratings produce the same arithmetic score. It does not prove equal technical capability, trustworthy ratings, price, fitness or supplier selection. The managed suite is vetoed for missing exit evidence; the portable platform remains a feasible candidate requiring due diligence and human approval.

### Answer 9: compound growth produces 15,625 RPS

`8000 × 1.25^3 = 15,625` RPS. Growth compounds because each year's 25 percent applies to the previous year's larger demand. Adding `3 × 25%` to the original happens to give 14,000 RPS and underestimates this scenario. The estimate still depends on whether 25 percent, three years and the current peak definition are valid.

### Answer 10: failure survival drives 51 instances

The target after 30 percent headroom is 20,312.5 RPS. At 600 sustainable RPS, 34 instances satisfy that with all healthy. The requirement also says one of three failure domains may be lost. Two surviving domains therefore need 17 instances each; symmetry yields 17 per domain, or 51 provisioned. After one domain fails, 34 survivors provide 20,400 RPS.

This is N+failure capacity, not waste inferred from average utilization.

### Answer 11: arithmetic is conditional evidence

`assumptions_require_validation=true` prevents the output from masquerading as a benchmark. The calculation is internally consistent only if demand, growth, headroom, failure scope and 600 sustainable RPS are valid. A reviewer should request source evidence, representative load testing, dependency limits and sensitivity—not celebrate a green word.

### Answer 12: most bytes can move before the outage window

Bulk copy creates a near-current target while the source remains available. Changes continue accumulating. Cutover contains the final synchronization, writer transfer, validation and routing/communication needed while normal writes may be restricted. Faster bulk transfer can reduce the accumulated delta, but cutover can still be dominated by final change rate, semantic validation or authority changes.

### Answer 13: the arithmetic closes under declared inputs

The 48 TB bulk copy takes 59.26 hours; source changes create a 1,185.19 GB delta; final sync takes 1.46 hours; validation adds 1.5 hours. The 2.96-hour sum fits the four-hour window.

It does not prove achievable throughput, change-capture correctness, ordering, delete semantics, schema compatibility, validation completeness, user readiness or recovery. Those require representative technical and operational evidence.

### Answer 14: the horizon ends before break-even

Remaining for three years costs USD 7.2 million. The proposal costs USD 5.55 million to run plus USD 1.8 million transition, totaling USD 7.35 million. Net saving is negative USD 150,000. Annual run-rate reduction is USD 550,000, so the simple break-even for the transition cost is about 39.27 months, later than the 36-month horizon.

Calling this “30 percent savings” would be a semantic and arithmetic error.

### Answer 15: cost is one outcome, not every outcome

The current facility may be closing, support may end, an unacceptable recovery risk may exist, or the target may enable a measured business capability. Those can justify a more expensive three-year path. The honest record says the cost claim fails and separately quantifies the required risk reduction or benefit. It does not manufacture savings from avoided list price or vague agility.

### Answer 16: routes do not rewind accepted writes

After target becomes writer, it may contain acknowledged operations absent from source. Pointing clients back to source exposes stale state and may duplicate external effects when clients retry. Recovery must fence writes, determine authority, account for acknowledged operations, replay/restore/compensate through a tested method, reconcile invariants and only then reopen traffic.

### Answer 17: a pilot buys relevant information

A representative pilot exercises important characteristics of later waves: state, dependencies, identity, observability, deployment, recovery, support and cost. It remains bounded enough to recover. Its learning questions and exit criteria are declared before execution. An easy stateless demonstration may validate pipeline mechanics, but it cannot justify claims about database migration or complex coexistence.

### Answer 18: operations must demonstrate capability

Acceptance includes named ownership and on-call, tested access, user/service dashboards, actionable alerts, deployment/recovery/reconciliation procedures, dependency and quota knowledge, security/certificate/secret operations, vendor escalation, accepted risks/exceptions, runbooks and cost attribution. The receiving team should demonstrate these under a rehearsal; receiving a folder is not evidence.

### Answer 19: retirement destroys options and evidence

A migration can meet target health while retention, legal hold, reconciliation, source traffic, backup, contractual or recovery obligations remain. Decommission removes routes, credentials, support and recovery resources; deletion can be irreversible. It therefore needs its own evidence and authorized owner. A project deadline or target go-live does not grant that authority.

### Answer 20: use state, owner, evidence, time and recovery

Ask:

1. What state, fact or authority changes?
2. Who decides, operates, accepts risk and authorizes deletion?
3. Is the claim observed, declared, inferred or unknown?
4. What happens before, during and after coexistence?
5. What exact state can be restored or reconciled after the point of no return?

Together these questions expose most hidden boundaries in architecture strategy, procurement and migration.

### Answers to the guided-lab challenge questions

Close unknowns by **decision consequence**. Before a pilot, prioritize owner, criticality, data class, writer, dependency, recovery and business-calendar unknowns because any can change scope or safety. Vary sustainable per-instance rate first in the capacity model because the margin is only 87.5 RPS; at 550 RPS, surviving capacity is 18,700 and fails. Check databases, queues, identity, network, external APIs and quotas because a downstream limit can invalidate compute capacity.

For transfer, test useful throughput, source change distribution, replay correctness, validation duration and contention. A two-hour window does not automatically benefit from faster bulk copy; the final delta and validation must fit. For vendor exit, test export completeness and format, identity/data migration, continued operation, deletion, dependency replacement, assistance, time and cost. For every isolated failed case, name the first boundary, evidence owner, risk authority and next reversible step before proposing technology.

## Product-company interview

Senior interviews test whether you can preserve truth while moving a decision forward. Structure answers as **outcome → evidence → options → trade-off → decision/authority → validation/recovery**.

### Scenario 1: “The CEO says move everything to cloud in 18 months. What do you do?”

**Weak answer:** “I would choose a provider, build a landing zone and use the seven migration Rs.”

**Strong answer:** “I would treat that as important intent, clarify the underlying outcome and decision authority, then build a versioned portfolio baseline with confidence and dependencies. I would test retire and retain before movement, define legal/security/recovery constraints, quantify delivery capacity, and propose a staged roadmap: foundation, representative pilot, dependency-aware waves, handover and evidence-based decommission. I would report which parts of the 18-month target are evidenced, which assumptions could reverse it and what next reversible commitment needs approval.”

**Follow-up:** “Are you challenging the CEO?”
**Response:** “I am preserving the intent while making the risks and choices executable. If 18 months is an immovable constraint, scope, cost, risk acceptance or service outcomes must be negotiated by their owners rather than hidden.”

### Scenario 2: “Our CMDB is 70 percent accurate. Can we start?”

**Weak answer:** “No, reach 100 percent first.”

**Strong answer:** “A portfolio-wide percentage hides which facts are reliable. I would classify critical fields as observed, declared, inferred or unknown, reconcile identities across sources, and close the unknowns that can reverse pilot scope or safety. We can begin read-only analysis and bounded foundation work while keeping production-wave approval gated on owner, dependency, data, recovery and business-cycle evidence.”

**Follow-up:** “How do you prove a dependency is absent?”
**Response:** “I usually cannot prove universal absence. I can show that named methods over representative windows detected none, that owners validated known manual and business-cycle paths, and retain an uncertainty statement.”

### Scenario 3: “How would you pick the first application?”

**Weak answer:** “Choose the easiest low-risk application.”

**Strong answer:** “I would choose a bounded but representative dependency group that tests the foundation and transition questions relevant to later waves: identity, deployment, state, observability, recovery, support and cost. I would avoid the highest-consequence workload and avoid a toy that proves only a pipeline. I would declare learning questions and exit criteria before selection so the result cannot be reinterpreted after the fact.”

**Follow-up:** “What if the pilot fails?”
**Response:** “If bounded recovery works, failure can be valuable evidence. I would classify whether the foundation, application pattern, process, capacity assumption or target decision failed, update strategy, and not extrapolate success.”

### Scenario 4: “A vendor has the best score. Why not select it?”

**Weak answer:** “The highest weighted score wins.”

**Strong answer:** “I would first confirm it passes hard constraints for security, legal/residency, correctness, support, export and exit. Then I would examine rating evidence and weight sensitivity. Marketing claims need technical or contractual acceptance. The score informs preference among feasible options; it does not own risk or approve the contract.”

**Follow-up:** “The sponsor wants an exception to missing export.”
**Response:** “I would identify who owns lock-in, records, security and continuity exposure, quantify the exit scenario, seek binding remediation or alternatives, and record a bounded exception only through the authorized risk process. A sponsor title alone does not prove all those authorities.”

### Scenario 5: “Estimate capacity three years out.”

**Weak answer:** “Current utilization is 40 percent, so double the cluster.”

**Strong answer:** “I would define the user workload and peak distribution, establish sustainable throughput under a representative mix, compound demand growth, add justified headroom, then size for the declared failure and maintenance envelope. I would check downstream quotas and run sensitivity on growth and per-unit rate. I would present a range and the limiting resource, then validate by load and failure testing.”

**Follow-up:** “Give me the lab number.”
**Response:** “At 8,000 RPS, 25 percent compound growth for three years gives 15,625; 30 percent headroom gives 20,312.5. At 600 RPS per instance, a three-domain topology surviving one lost domain needs 17 per domain, 51 provisioned, leaving 20,400 RPS on two domains. The 87.5 margin makes rate validation critical.”

### Scenario 6: “Can 48 TB move in a four-hour outage?”

**Weak answer:** “No, 48 TB is too large.”

**Strong answer:** “I would separate online bulk copy from final cutover. Under the fictional inputs, bulk takes 59.26 hours while source remains live; the accumulated 1,185.19 GB delta takes 1.46 hours at the final rate and validation adds 1.5 hours, so the 2.96-hour cutover fits. I would not approve from arithmetic alone: change capture, ordering, schema compatibility, achieved throughput, validation and recovery must be tested.”

**Follow-up:** “What would you monitor?”
**Response:** “Copy throughput/error, source change rate, replication lag, checkpoint age, replay failures, reconciliation backlog, source/target user signals and the remaining cutover-window budget.”

### Scenario 7: “Describe rollback for a database cutover.”

**Weak answer:** “Switch DNS back.”

**Strong answer:** “I would identify writer authority and the last common checkpoint. Before cutover I would prove source restore or target forward recovery, replay, idempotency and business reconciliation. After target accepts writes, route reversal alone is unsafe; I must fence writes, account for acknowledged operations and external effects, then replay target-to-source, restore plus logs, or continue forward according to the tested recovery path.”

**Follow-up:** “Would you use dual write?”
**Response:** “Only with a deliberately designed protocol for durable intent, ordering, idempotency, partial failure, conflict and reconciliation. Application-level fire-and-forget dual write usually increases ambiguity.”

### Scenario 8: “The business case says 30 percent savings.”

**Weak answer:** “Cloud is pay-as-you-go, so that seems reasonable.”

**Strong answer:** “I would normalize current counterfactual, target run and one-time transition costs using the same horizon and service meaning. I would include parallel run, people, support, data movement, licensing, commitments, opportunity and exit where material. In the lab, the proposal is USD 150,000 worse over 36 months and breaks even at 39.27 months, so I would reject the savings claim while evaluating other measured outcomes separately.”

**Follow-up:** “How do you handle uncertain prices?”
**Response:** “Use attributable sources, low/base/high ranges, commitment and growth scenarios, unit economics and sensitivity. Update with actuals after each wave.”

### Scenario 9: “How do you govern architecture without slowing teams?”

**Weak answer:** “Create an architecture board that approves every change.”

**Strong answer:** “I would publish a small set of outcome-linked principles, testable standards and paved patterns. Automate safe guardrails and delegate decisions within them. Central review focuses on material exceptions, shared irreversible choices and risk thresholds. Every exception has an owner, compensation and expiry; outcomes and incidents feed standards back.”

**Follow-up:** “What belongs in an ADR?”
**Response:** “Context, decision, feasible alternatives, constraints, evidence version, consequences, owner and review/supersession trigger—not a transcript of every meeting.”

### Scenario 10: “How do you plan migration waves?”

**Weak answer:** “Twenty applications per month.”

**Strong answer:** “I would form dependency groups using technical, data, owner and business-cycle evidence; sequence foundation and representative pilot first; then cap concurrent groups by application, platform, change and support capacity. I would respect freezes and shared bottlenecks and update wave size from preparation/cutover/support distributions, not an application-count average.”

**Follow-up:** “A dependency is discovered mid-wave.”
**Response:** “Stop at the safe boundary, preserve evidence, decide whether the dependency can remain compatible across coexistence or must join the group, revise recovery and approval, then update discovery confidence for later waves.”

### Scenario 11: “When is migration complete?”

**Weak answer:** “When all workloads run on the target.”

**Strong answer:** “A wave is complete when user and data outcomes, security, reliability, performance, operations acceptance and cost evidence meet their criteria. Program completion also requires benefit review and authorized source retirement. Decommission waits for no valid traffic/writers, reconciliation, retention/legal, restore, contract, route, credential and ownership closure.”

**Follow-up:** “The old platform contract expires tomorrow.”
**Response:** “That is a serious planning failure but not proof that unsafe deletion is acceptable. I would escalate continuity and commercial options under incident/change authority, preserve required recovery evidence, and make risk ownership explicit.”

### Scenario 12: “Present the same decision to five audiences.”

**Weak answer:** Repeat the target architecture slide.

**Strong answer:**

- **Executive:** outcome, options, investment range, major risk, decision and trigger.
- **Finance:** counterfactual, cost semantics, range, break-even, sensitivity and benefit owner.
- **Security/legal:** data/identity boundaries, threats, controls, residual risk, supplier and exit evidence.
- **Engineering:** interfaces, dependencies, standards, compatibility, capacity assumptions and validation.
- **Operations:** user signals, failure modes, access, alerts, recovery, reconciliation, support and handover.

The facts must remain consistent while emphasis changes.

**Follow-up:** “What if an audience asks for certainty you do not have?”
**Response:** “I state the unknown, consequence, current range and closure plan. False precision may win a meeting and destroy trust during execution.”

### Interview self-check

A strong answer:

- begins with the decision or outcome;
- names the first missing evidence;
- distinguishes fact from assumption;
- includes failure, recovery and authority;
- quantifies with units and ranges when possible;
- proposes the next reversible action;
- never claims production proof from a model.

If your answer is mainly a product list, go one layer deeper into state, evidence and trade-offs.

## Independent transfer and rubric

The independent assessment is `ASM-0234`. It intentionally contains no published answer fields.

### Reviewer setup

The reviewer creates two sanitized fictional portfolios at materially different scales—for example, 12 workloads in one dependency domain and 350 workloads across regulated business units. The reviewer privately controls:

- one hard constraint that is initially hidden;
- one weak evidence assumption;
- one delivery, demand, transfer or financial input that changes after the first defense;
- expected safety boundaries;
- scoring and cleanup.

The learner gets no production credential, employer inventory, private contract, customer data or answer key.

### Required evidence package

Produce:

1. mandate, outcomes, scope, non-goals, risk appetite and review triggers;
2. versioned portfolio with field-level confidence and unknown-closure priorities;
3. criticality, lifecycle, business cycles and dependency groups;
4. comparable current-state baseline;
5. rationalization and alternatives;
6. target principles, standards, patterns and exceptions;
7. decision rights and governance;
8. failure-aware capacity range;
9. bulk, delta, cutover and validation calculation;
10. economic counterfactual, transition/exit cost, range and break-even;
11. vendor veto, due-diligence, preference and sensitivity record;
12. foundation, pilot and wave plan;
13. coexistence, compatibility, writer and synchronization design;
14. go/no-go, stop, recovery and reconciliation;
15. operations, benefit and decommission evidence;
16. one decision record and five audience-fit explanations;
17. a revised strategy after the reviewer changes evidence and constraints.

### Scoring

The reviewer scores ten criteria at ten points each:

| Criterion | Full-credit observable evidence |
|---|---|
| Mandate and constraints | Accountable, bounded and measurable; conflicts and risk appetite visible |
| Portfolio evidence | Versioned confidence, dependencies, cycles and prioritized unknown closure |
| Options and principles | Credible rationalization, standards, exceptions and rights |
| Capacity and transfer | Correct units, failure reserve, movement/cutover ranges and sensitivity |
| Economics and value | Comparable semantics, transition/opportunity/exit, benefits and break-even |
| Vendor/supply chain | Vetoes, security, portability, export, concentration, contract and exit |
| Waves and transition | Foundation, representative pilot, dependencies, coexistence and one writer |
| Recovery and retirement | Stop, state recovery, reconciliation, handover, retention and decommission |
| Governance/communication | Owners, risks, cadence, ADR and audience-fit defense |
| Unfamiliar adaptation | Hidden changes cause justified revisions without unsafe improvisation |

### Mastery boundary

Repository tests can prove that the assessment schema and lab behave as authored. They cannot prove that a learner can solve unfamiliar cases. Mastery requires reviewer-scored evidence, follow-up defense and later retrieval. Record the result only in the learner's private progress system, never as an automatic site claim.

If the first attempt is weak, remediation targets the failed mechanism. Examples:

- redo confidence classification with contradictory sources;
- recalculate capacity after a degraded rate;
- redesign cutover after the window changes;
- remove a vendor after a hard veto appears;
- revise the business case after transition cost increases;
- defend state recovery when traffic rollback is unavailable.

## References and review

These records anchor terminology and official methods. The chapter paraphrases them and adds a fictional reasoning model. No source certifies this strategy, supplier or migration.

### Architecture, governance and risk foundations

- [REF-1010 — ISO/IEC/IEEE 42010:2022 architecture description](https://www.iso.org/standard/74393.html): stakeholders, concerns, viewpoints and model kinds; useful for remembering that a diagram is a governed description, not the architecture itself.
- [REF-1011 — ISO/IEC 38500:2024 governance of IT](https://www.iso.org/standard/81684.html): governance responsibility, strategy, acquisition, performance, conformance and human behavior.
- [REF-1012 — ISO 31000:2018 risk management](https://www.iso.org/standard/65694.html): principles and process for explicit uncertainty and accountable risk decisions.
- [REF-1013 — TOGAF Standard, 10th Edition overview](https://www.opengroup.org/togaf): architecture method and capability context; use selectively rather than turning delivery into ceremony.
- [REF-1014 — NIST SP 800-37 Rev. 2](https://csrc.nist.gov/pubs/sp/800/37/r2/final): system life-cycle risk management and continuous monitoring.
- [REF-1015 — NIST SP 800-161 Rev. 1 Update 1](https://csrc.nist.gov/pubs/sp/800/161/r1/upd1/final): cybersecurity supply-chain risk across acquisition and operation.

### Portfolio, strategy and migration guidance

- [REF-1016 — AWS detailed portfolio discovery](https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-migration/detailed-portfolio-discovery.html): iterative inventory, dependencies, criticality and migration evidence.
- [REF-1017 — AWS migration wave planning](https://docs.aws.amazon.com/prescriptive-guidance/latest/large-migration-guide/wave-planning.html): dependency-aware wave planning and governance.
- [REF-1018 — AWS migration strategies](https://docs.aws.amazon.com/prescriptive-guidance/latest/large-migration-guide/migration-strategies.html): the seven rationalization choices used in this chapter.
- [REF-1019 — Azure cloud adoption strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/strategy/): motivations, outcomes, business justification and alignment.
- [REF-1020 — Azure plan migration](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/plan-migration): readiness, waves, workload planning and transition context.
- [REF-1021 — Google Cloud migration get started](https://cloud.google.com/architecture/migration-to-google-cloud-getting-started): assess, plan, deploy and optimize phases.
- [REF-1026 — Azure document the cloud adoption plan](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/plan/): backlogs, skills, rationalization and plan documentation.
- [REF-1027 — Google Cloud migration foundation](https://cloud.google.com/architecture/migration-to-google-cloud-building-your-foundation): organizational, identity, networking, security, operations and governance foundations.

Provider guidance is contextual. It does not authorize a provider choice or replace local regulatory, security, financial and operational review.

### Public-interest standards, acquisition and financial practice

- [REF-1022 — UK Technology Code of Practice](https://www.gov.uk/guidance/the-technology-code-of-practice): user needs, accessibility, security, open technology, sustainability and operational considerations.
- [REF-1023 — UK Open Standards principles](https://www.gov.uk/government/publications/open-standards-principles/open-standards-principles): interoperability, fair competition and avoiding unnecessary lock-in.
- [REF-1024 — CISA Secure by Demand guide](https://www.cisa.gov/resources-tools/resources/secure-demand-guide): questions and evidence for purchasing secure software.
- [REF-1025 — FinOps Framework](https://www.finops.org/framework/): collaborative cost, value, allocation and decision practices.

### Review and limitation statement

Validated teaching boundaries:

- Ubuntu 24.04 normal-user guarded lifecycle;
- Python 3 standard-library model;
- 71 fictional cases and five deterministic calculations;
- root, credential/runtime authority, symlink, ownership and unknown-artifact refusal;
- no network, provider, vendor, discovery, contract, infrastructure, data movement or production call.

Not validated:

- any real portfolio, dependency, benchmark, price, contract or supplier;
- any legal, regulatory, security or financial conclusion;
- any provider foundation, migration, cutover, restore, reconciliation or deletion;
- learner mastery or transfer.

Formal technical, security, privacy, legal, finance, procurement and instructional review remains necessary before applying this material to an organization. Review the chapter when a cited method materially changes or by the frontmatter review date, whichever comes first.
