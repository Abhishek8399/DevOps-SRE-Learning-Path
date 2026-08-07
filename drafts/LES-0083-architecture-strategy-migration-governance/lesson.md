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
    "This file begins as a schema-complete teaching scaffold; the full manuscript is still being written.",
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

The full manuscript will begin with the executive request, expose why a deadline and percentage are not yet a strategy, and establish the first evidence-safe response.

## Terms before commands

The manuscript will define mandate, outcome, portfolio, confidence, rationalization, principle, standard, guardrail, governance, exception, risk appetite, supplier, veto, transition state, wave, rollback, forward recovery and benefit realization before using them.

## Architecture map

The architecture will connect portfolio evidence, decisions, governance, shared foundations, workload waves, operations and measurable outcomes without confusing enterprise views with workload internals.

## Request or state path

The central path will follow a strategy from executive intent through discovery, rationalization, investment, vendor and standards decisions, pilot, waves, cutover, handover, reconciliation and retirement.

## Failure zoom

Failure analysis will cover incomplete discovery, false dependencies, incompatible versions, dual writers, cutover overrun, rollback impossibility, vendor exit, cost-semantic drift, support gaps and premature decommission.

## Internals and state ownership

The manuscript will bind ownership for portfolio facts, decision records, principles, exceptions, contracts, writer state, benefits, risks and evidence expiry.

## Evidence table

Evidence will distinguish observed, declared, inferred and unknown portfolio data plus estimates, tests, contractual commitments, decisions and realized outcomes.

## Command decoders

Every command will be decoded with inputs, equations, units, output fields, assumptions, branches, proof and non-proof boundaries.

## Decision path

The path will join mandate, evidence confidence, options, vetoes, quantitative ranges, governance, pilot, wave gates, operations and review triggers.

## Guided Ubuntu lab

The guarded lab will walk through all 71 cases and five calculations without any provider, vendor, discovery or migration authority.

## Production transfer

Transfer will begin read-only with authorized sanitized portfolio evidence and will separate analysis, proof-of-concept, pilot and production-change authority.

## Reliability, security, observability, capacity, and cost

These properties will be modeled as strategy constraints and outcomes whose trade-offs persist through procurement, transition and steady-state operations.

## Traps and prevention

The chapter will challenge mandate literalism, migration-by-spreadsheet, uniform strategy, provider-first design, scorecard authority, false rollback, incomparable cost and activity-based success.

## Memory card and retrieval

A one-page strategy/migration memory card and retrieval set will support incident, review and interview recall.

## Complete answers

Every retrieval and guided-lab question will receive a direct answer, mechanism explanation and senior production interpretation.

## Product-company interview

Interview practice will cover portfolio discovery, rationalization, capacity/cost uncertainty, vendor evaluation, governance, migration architecture, cutover/recovery and executive defense.

## Independent transfer and rubric

A reviewer will provide two unfamiliar portfolios and change hidden evidence, constraint and delivery assumptions; published answers cannot satisfy the transfer.

## References and review

Eighteen primary or official records anchor terminology and methods. They do not certify a strategy, supplier, provider, migration or business case.
