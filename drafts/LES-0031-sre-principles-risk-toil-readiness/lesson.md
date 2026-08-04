---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0031",
  "slug": "sre-principles-risk-toil-readiness",
  "aliases": ["V04-L06", "sre-principles-risk-toil-readiness"],
  "curriculumIds": ["SRE-001"],
  "route": "/book/reliability/sre-principles-risk-toil-readiness",
  "order": 6,
  "volume": "04-reliability-operations",
  "title": "SRE principles: turn production pain into an engineering control loop",
  "summary": "Learn what Site Reliability Engineering changes beyond a job title: define user reliability and acceptable risk, distinguish toil from valuable operations, preserve engineering capacity, build shared ownership, review production readiness, protect on-call humans, learn from failure, and prove improvement without mistaking dashboards, automation, or checklists for outcomes.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0007", "LES-0008", "LES-0026"],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001", "OBS-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The bounded teaching model requires only Bash and Python 3 and refuses root. It modifies one UID-scoped temporary directory and contacts no team, ticket, notification, identity, cloud, or production system."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The deterministic lab is designed for WSL. WSL service startup, filesystem, identity, clocks, process boundaries and policy can differ from native Ubuntu and must be recorded rather than assumed equivalent."
    },
    {
      "platform": "Organizations and production services",
      "version": "concept-only",
      "support": "concept-only",
      "notes": "The chapter explains operating models and readiness evidence. No organizational authority, real service review, staffing decision, risk acceptance, on-call qualification or production change has occurred."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "software-engineer-on-call",
    "engineering-manager",
    "technical-lead",
    "incident-commander"
  ],
  "learningObjectives": [
    "Explain SRE as a software-engineering and operating model for reliable services rather than a renamed operations team, tool list, pager rotation, or promise of perfect uptime.",
    "Translate a user operation and business risk tolerance into a measurable reliability contract with explicit owners and consequences while refusing an automatic 100 percent target.",
    "Distinguish operations, toil, engineering, overhead, interrupts, incidents and project work using context and multiple properties instead of personal preference.",
    "Measure toil and protected engineering capacity with matched populations, time windows, units, overlap rules, uncertainty and human-sustainability limits.",
    "Evaluate source removal and automation using risk-adjusted return, including build, maintenance, adoption, failure, security, opportunity cost, canary, abort, rollback and manual fallback.",
    "Design shared production ownership that keeps product risk, service code, change, capacity, security, on-call, incident and learning decisions with accountable authorized owners.",
    "Conduct a production-readiness review that separates assertions from evidence, blockers from accepted risks, and checklist state from an authorized exposure decision.",
    "Build sustainable on-call and escalation conditions with actionable pages, qualified staffing, handoffs, psychological safety, training and follow-up capacity.",
    "Run an operating review that connects user reliability, changes, incidents, pages, toil, capacity, security, cost and preventive engineering without blaming individuals.",
    "Communicate SRE tradeoffs to engineers and executives with precise evidence, reversible decisions, uncertainty and non-claims."
  ],
  "productionSignals": [
    "critical user operations, valid good and total events, correctness, latency, availability, durability, coverage, freshness, objectives and remaining error budget",
    "service criticality, customer harm, financial or data exposure, legal and security constraints, dependency risk and cost of additional reliability",
    "team capacity by declared period, toil, non-toil operations, engineering, overhead, interrupts, unclassified time, overlap and confidence",
    "toil source, trigger, occurrences, duration, growth driver, user risk, owner, automation potential, enduring value and recurrence after intervention",
    "automation build, maintenance, adoption, failure, privilege, security, opportunity cost, labor saved, risk reduced, break-even range and residual manual path",
    "page instances, unique significant events, precision, recall, pages per incident, time to acknowledge, time to action, escalation, abandonment and after-hours load",
    "production-readiness controls, required evidence, desired and running version, owner, blocker, accepted risk, compensating control, expiry and re-review trigger",
    "capacity model, peak and failure demand, queues, saturation, headroom, overload behavior, dependency ceilings and degradation outcome",
    "change volume, failure rate, canary gates, rollback and roll-forward evidence, restore integrity, recovery objectives and observation windows",
    "ownership coverage, decision latency, handoff defects, unowned services, support boundaries, training, staffing, fatigue and psychological-safety indicators",
    "incident user impact, response timeline, contributing conditions, evidence quality, action owners, due dates, recurrence and verified prevention",
    "quarterly operating outcomes linking reliability, delivery velocity, engineering allocation, operational load, security, cost and user value"
  ],
  "diagrams": [
    {
      "id": "LES-0031-DIA-001",
      "title": "SRE reliability control loop",
      "direction": "cyclic",
      "boundaries": ["user operation", "business risk", "SLI and SLO", "service design and change", "production evidence", "incident and toil", "engineering improvement", "review and updated decision"],
      "evidencePoints": ["good and total events", "risk owner and consequence", "objective and budget", "version and rollout", "coverage and outcome", "work and incident population", "tested control", "measured improvement"],
      "textAlternative": "A user operation defines the outcome that matters. Product and engineering translate business risk into a measurable objective and consequence. Teams design, change and operate the service. Production evidence reveals user outcomes, incidents and recurring work. Engineering removes failure and toil sources. An operating review updates priorities and the reliability contract. The loop is shared; SRE is not a terminal queue receiving all problems."
    },
    {
      "id": "LES-0031-DIA-002",
      "title": "Work classification decision tree",
      "direction": "top-to-bottom",
      "boundaries": ["observed work item", "incident or planned", "enduring system value", "manual and repetitive", "safe automation or elimination", "growth with demand", "classified work and uncertainty"],
      "evidencePoints": ["trigger and population", "urgency", "artifact or system change", "occurrences and duration", "failure and privilege boundary", "growth driver", "team-reviewed label"],
      "textAlternative": "Begin with an observed work item, not a person's opinion. Record whether it is an incident or planned, whether it produces enduring value, whether it is manual and repetitive, whether it can be safely automated or eliminated, and whether it grows with demand. Several toil properties support a toil-candidate label; no single property or dislike is enough."
    },
    {
      "id": "LES-0031-DIA-003",
      "title": "Shared production ownership map",
      "direction": "hierarchical",
      "boundaries": ["product risk", "service design and code", "platform control", "change authority", "security and data", "on-call and incident", "learning and prevention"],
      "evidencePoints": ["business owner", "code owner", "interface and SLO", "approver and rollback", "risk owner", "qualified primary and secondary", "action owner and verification"],
      "textAlternative": "Product owns user value and accepted business risk. Development owns service design and code defects. Platform owns its declared control-plane contract. Change, security, data, capacity and incident decisions have explicit accountable owners. SRE brings production expertise and engineering, but does not absorb every responsibility. Learning actions return to the owner able to change the source."
    },
    {
      "id": "LES-0031-DIA-004",
      "title": "Production-readiness evidence gate",
      "direction": "left-to-right",
      "boundaries": ["launch proposal", "service and exposure model", "required control", "current evidence", "blocker or accepted risk", "go limited or no-go", "observation and re-review"],
      "evidencePoints": ["users and blast radius", "version and dependencies", "test result", "owner rationale and expiry", "decision authority", "abort and rollback", "actual user outcome"],
      "textAlternative": "A launch proposal becomes a concrete exposure model. Each required reliability, capacity, change, data, security, observability and human control is matched to version-bound evidence. Missing required evidence is a blocker unless an authorized owner can accept a bounded waivable risk with controls and expiry. The decision is go, limited, no-go or blocked for evidence, followed by observation and re-review."
    },
    {
      "id": "LES-0031-DIA-005",
      "title": "Toil source-removal investment loop",
      "direction": "cyclic",
      "boundaries": ["measure recurring work", "rank user and operator risk", "find source", "choose eliminate simplify automate or absorb", "canary control", "measure residual work and failure", "retire or improve"],
      "evidencePoints": ["hours and growth", "impact and urgency", "causal evidence", "cost and authority", "abort and fallback", "saved time and new incidents", "owner decision"],
      "textAlternative": "Measure recurring work and rank it by user risk, operator risk, growth and time. Find the source rather than merely scripting the final click. Choose elimination, simplification, automation, product change, workload transfer with consent, or temporary absorption. Canary the control, measure residual work and new failure modes, then improve or retire it."
    },
    {
      "id": "LES-0031-DIA-006",
      "title": "Sustainable on-call feedback system",
      "direction": "cyclic",
      "boundaries": ["actionable user risk", "page and qualified responder", "diagnosis and containment", "escalation and handoff", "user recovery", "incident learning", "owned prevention", "training and readiness"],
      "evidencePoints": ["page contract", "acknowledgement", "timeline", "role transfer", "independent outcome", "contributing conditions", "verified action", "simulation and load"],
      "textAlternative": "A page represents urgent actionable user or imminent hard-limit risk and reaches a qualified responder. The responder diagnoses, contains and escalates through rehearsed handoffs. User recovery is verified independently. A learning review creates owned preventive work, which is validated and fed into training and readiness. High page load that prevents follow-up breaks this loop."
    }
  ],
  "commands": [
    {
      "id": "LES-0031-CMD-001",
      "question": "Which user, kernel, Ubuntu release, Python version, UTC time, and directory define this attempt?",
      "risk": "read-only",
      "command": "id; uname -a; cat /etc/os-release; python3 --version; date -u +%Y-%m-%dT%H:%M:%SZ; pwd",
      "runFrom": "a normal Ubuntu shell before touching the lab",
      "expectedBranches": [
        {"when": "the caller is non-root and environment matches the approved scope", "meaning": "the local evidence context is recorded", "nextEvidence": "run the lab doctor"},
        {"when": "the caller is root, release differs, time is implausible, or path is unexpected", "meaning": "identity, portability or time assumptions are unsafe", "nextEvidence": "stop mutation and correct or record the environment gap"}
      ],
      "proves": "only the caller and self-reported local environment identity at that moment",
      "doesNotProve": "organizational authorization, clock synchronization, service access, readiness, or production equivalence"
    },
    {
      "id": "LES-0031-CMD-002",
      "question": "Does the checked-in operating-model scenario satisfy its exact input contract?",
      "risk": "read-only",
      "command": "python3 fixtures/sre_operating_model.py validate-scenario fixtures/scenario.json",
      "runFrom": "the LES-0031 support/lab directory",
      "expectedBranches": [
        {"when": "scenario_valid=true appears", "meaning": "the exact fixture satisfies the model's current structural and numeric checks", "nextEvidence": "run doctor and setup"},
        {"when": "refused=true or a Python error appears", "meaning": "identity, schema, type, range, encoding or code is invalid", "nextEvidence": "preserve the first error and do not create lab state"}
      ],
      "proves": "only fixture conformance to the checked-in validator",
      "doesNotProve": "that the scenario represents a real team, that its heuristic is universal, or that its conclusions are correct outside declared inputs"
    },
    {
      "id": "LES-0031-CMD-003",
      "question": "Can the lab create its exact private normal-user state?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "the LES-0031 support/lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "state=ready appears", "meaning": "the exact UID-scoped descriptor validates", "nextEvidence": "inspect status and run one case"},
        {"when": "refused=true appears", "meaning": "root, dependency, fixture, ownership, symlink, concurrency or state identity is unsafe", "nextEvidence": "do not delete broadly; inspect the exact refusal"}
      ],
      "proves": "only bounded state creation or validation under the script contract",
      "doesNotProve": "SRE adoption, production readiness, user reliability, or cleanup until cleanup runs",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-004",
      "question": "What exact lab state and result count exist?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the LES-0031 support/lab directory",
      "expectedBranches": [
        {"when": "state=absent appears", "meaning": "the expected path is absent", "nextEvidence": "run setup if practice is intended"},
        {"when": "state=ready appears", "meaning": "sentinel, manifest, fixture, types and ownership validate", "nextEvidence": "compare the result count with cases deliberately run"},
        {"when": "refused=true appears", "meaning": "state is ambiguous or violates the descriptor", "nextEvidence": "preserve it for bounded inspection"}
      ],
      "proves": "only encoded state validity and result-file count",
      "doesNotProve": "semantic correctness of results, cleanup, readiness, or learner understanding"
    },
    {
      "id": "LES-0031-CMD-005",
      "question": "Which declared service has exhausted its event-based reliability budget?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run risk",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "public-checkout is exhausted", "meaning": "its fixture bad-event estimate exceeds its allowed count", "nextEvidence": "inspect SLI validity, segmentation, confidence, causes and policy owner"},
        {"when": "another result appears", "meaning": "scenario, formula or model changed", "nextEvidence": "stop and reconcile exact inputs before interpretation"}
      ],
      "proves": "event-ratio arithmetic over declared inputs",
      "doesNotProve": "business harm, target approval, causality, release policy or a production SLO",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-006",
      "question": "Which fixture tasks exhibit several toil properties, and how much measured work do they represent?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run toil",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "600 toil-candidate minutes and fraction 0.645161 appear", "meaning": "two recurring tasks meet at least four encoded properties", "nextEvidence": "review context, user risk, source, owner and uncertainty"},
        {"when": "a different count appears", "meaning": "properties, population or heuristic changed", "nextEvidence": "inspect rows rather than trusting the total"}
      ],
      "proves": "classification and arithmetic under one explicit teaching heuristic",
      "doesNotProve": "individual value, team performance, safe automation, or universal toil classification",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-007",
      "question": "Which automation candidate has the strongest declared first-quarter net result?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run automation",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "worker-self-recovery is selected with 18 first-quarter net hours", "meaning": "its fixture benefit minus maintenance and build is greatest", "nextEvidence": "test assumptions, failure modes, security, adoption and sensitivity"},
        {"when": "another candidate wins", "meaning": "inputs or formula changed", "nextEvidence": "reconcile cost and benefit fields before prioritizing"}
      ],
      "proves": "one deterministic estimate using declared inputs",
      "doesNotProve": "actual return, safety, authorization, adoption, causal risk reduction or correct implementation",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-008",
      "question": "How much engineering capacity remains in the fixture workload?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run workload",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "64 engineering hours, 0.266667 fraction and 56-hour gap appear", "meaning": "declared toil, operations and overhead leave less than the fixture minimum", "nextEvidence": "validate categories and negotiate source, scope, staffing or priority changes"},
        {"when": "sustainableByFixture is true", "meaning": "declared allocation meets the teaching threshold", "nextEvidence": "still review individual distribution, interrupts and outcomes"}
      ],
      "proves": "capacity subtraction under mutually exclusive declared categories",
      "doesNotProve": "individual workload, legal compliance, team health, productivity or a universal staffing target",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-009",
      "question": "Which required production decisions lack assigned roles?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run ownership",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "capacity-owner and on-call-secondary are missing", "meaning": "the fixture contains two explicit decision gaps", "nextEvidence": "identify authorized qualified owners and exercise handoffs"},
        {"when": "coverage is complete", "meaning": "every required key has a nonempty label", "nextEvidence": "test authority, availability, competence and conflicts"}
      ],
      "proves": "key coverage in the fixture assignment map",
      "doesNotProve": "real accountability, staffing, skill, availability, escalation or decision quality",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-010",
      "question": "What readiness decision follows from required missing evidence?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run readiness",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "decision=no-go and three blockers appear", "meaning": "required SLO, dependency-test and secondary-response evidence is absent", "nextEvidence": "run bounded closure work or obtain valid risk decisions without changing missing to present"},
        {"when": "review-for-go appears", "meaning": "every encoded required row is present", "nextEvidence": "review unmodelled risk, exposure and decision authority"}
      ],
      "proves": "the outcome of one fail-closed checklist rule",
      "doesNotProve": "complete readiness, risk acceptance, legal approval, absence of unknowns or authority to launch",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-011",
      "question": "Which fixture periods require an operating intervention?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run operating-review",
      "runFrom": "a validated ready LES-0031 lab state",
      "expectedBranches": [
        {"when": "week-1 and week-2 require intervention", "meaning": "one or more declared SLO, page, toil or change thresholds were crossed", "nextEvidence": "inspect row reasons and form causal hypotheses"},
        {"when": "another set appears", "meaning": "period data or thresholds changed", "nextEvidence": "review the exact populations rather than reusing an old conclusion"}
      ],
      "proves": "threshold triage for three fixture periods",
      "doesNotProve": "causality, correct thresholds, individual fault, or which intervention will work",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0031-CMD-012",
      "question": "Does the complete bounded lifecycle, arithmetic, refusal, and cleanup contract pass?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "the LES-0031 support/lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "verification=passed and final_state=absent appear", "meaning": "encoded syntax, cases, assertions, two refusal probes and exact cleanup passed", "nextEvidence": "record environment and proof limits"},
        {"when": "the verifier fails", "meaning": "the first failed invariant is evidence and final trap attempts bounded cleanup", "nextEvidence": "preserve output and inspect only the exact lesson path"}
      ],
      "proves": "mentor-project behavior for the checked-in deterministic fixture on that environment",
      "doesNotProve": "organizational SRE adoption, real service readiness, team health, learner competence, production transfer or mastery",
      "cleanup": "The verifier traps cleanup; confirm with bash lab.sh status and require state=absent. Preserve ambiguous state instead of deleting it broadly."
    }
  ],
  "labs": [
    {
      "id": "LES-0031-LAB-001",
      "title": "Guided SRE risk, toil, ownership and readiness model",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS normal user with Bash and Python 3; no Docker, network, ports, sudo, package installation, service manager, organization system or production service",
      "timeMinutes": 120,
      "privilege": "normal user; wrapper and verifier refuse UID 0",
      "network": "none; all fixtures, calculations and decision rows are local",
      "changes": ["one lesson-specific temporary directory", "owned fixture copies", "bounded JSON result files"],
      "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "a child is a symlink or unexpected type", "fixture contract is invalid", "a calculation differs from reviewed expectations", "cleanup cannot validate exact ownership"],
      "recovery": "Run status. If the complete descriptor validates, run cleanup and repeat setup. Preserve refused foreign or ambiguous state for review instead of deleting it broadly.",
      "cleanupProof": "Cleanup validates exact parent, basename, real path, UID, sentinel, manifest, scenario, allowed children, types and owner, removes only that directory, and proves exact absence.",
      "path": "drafts/LES-0031-sre-principles-risk-toil-readiness/support/lab"
    },
    {
      "id": "LES-0031-LAB-002",
      "title": "Independent SRE operating-model and readiness review",
      "mode": "independent",
      "environment": "An instructor-provided or learner-created unseen disposable local case with materially changed users, risk, work, ownership, readiness, human and improvement constraints; the guided fixture cannot satisfy independence",
      "timeMinutes": 120,
      "privilege": "normal user; no elevated or organizational operation",
      "network": "none unless a separately reviewed unseen local harness explicitly declares loopback; production, shared, employer, ticket, identity, email, chat, pager and online cloud systems are prohibited",
      "changes": ["one learner-owned sanitized response outside guarded LES-0031 state", "only resources declared by the unseen disposable case"],
      "abortConditions": ["reviewer-only answer material becomes visible", "authorization, accessibility or sanitization is unclear", "state validation fails", "a real organizational or notification system could be contacted", "the learner proposes blame, unbounded automation or unsupported launch", "evidence cannot discriminate the hypothesis"],
      "recovery": "Return to baseline evidence, narrow the hypothesis and submit a revision. Never reveal answered material before independent review.",
      "cleanupProof": "Use the unseen case's own manifest to prove every created process, port, file, queue, container, network or resource absent. Guided lab cleanup does not cover the independent case.",
      "path": "drafts/LES-0031-sre-principles-risk-toil-readiness/support/lab"
    }
  ],
  "incidents": [
    {
      "id": "LES-0031-INC-001",
      "signal": "An operations team is renamed SRE while tickets, pages, authority, staffing and code ownership remain unchanged.",
      "firstThought": "A team label is not an operating mechanism. Inspect user objectives, work mix, production feedback, decision rights, engineering capacity and on-call sustainability.",
      "safePath": "Protect critical response, measure work and pages, define a user reliability contract, assign shared owners, bound intake, and remove recurring sources with tested engineering controls.",
      "trap": "Demanding more automation or exactly fifty percent coding without reducing load can abandon users or drive hidden overtime."
    },
    {
      "id": "LES-0031-INC-002",
      "signal": "A green launch checklist contains required controls relabeled not applicable after evidence could not be produced.",
      "firstThought": "Checklist color is presentation. Trace each requirement to service exposure, version-bound evidence, risk authority, rationale, compensating controls and expiry.",
      "safePath": "Reopen unsupported rows, rank blockers, run bounded closure experiments, and choose go, limited, no-go or blocked-for-evidence with explicit abort and rollback.",
      "trap": "A percentage readiness score can average a catastrophic missing control with many low-risk green rows."
    },
    {
      "id": "LES-0031-INC-003",
      "signal": "A bot automatically restarts failing workers faster, but retry traffic and duplicate side effects increase customer harm.",
      "firstThought": "Automation scaled an action without owning the state transition. Inspect detection validity, idempotency, retry bounds, concurrency, authority, observability and source defect.",
      "safePath": "Disable or constrain the unsafe control through its reviewed rollback, preserve manual recovery, reconcile user state, then design source removal or a bounded state machine with canary and abort.",
      "trap": "Time saved per restart is not return on investment when the automation creates incidents or hides the underlying failure."
    },
    {
      "id": "LES-0031-INC-004",
      "signal": "The primary on-call receives continuous pages while no qualified secondary is available and follow-up work never completes.",
      "firstThought": "This is both a service-response and human-safety incident. More personal endurance is not capacity.",
      "safePath": "Escalate the staffing and service-risk condition, protect rest and handoff, retain only urgent actionable coverage, bring authorized help, reduce exposure if necessary, and create owned source-removal work.",
      "trap": "Silencing all pages protects sleep briefly but may leave users invisible; adding the same exhausted person to more rotations is not redundancy."
    }
  ],
  "assessmentIds": ["ASM-0076", "ASM-0077", "ASM-0078"],
  "referenceIds": ["REF-0229", "REF-0230", "REF-0231", "REF-0232", "REF-0233", "REF-0234", "REF-0235", "REF-0236", "REF-0237", "REF-0238", "REF-0239", "REF-0240", "REF-0241", "REF-0242", "REF-0243"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "The deterministic model classifies and calculates only checked-in fictional inputs; it is not an organization assessment, SLO authority, staffing policy, production-readiness approval or return-on-investment forecast.",
    "The chapter does not prescribe one organization chart, pager rotation, ownership matrix, toil threshold, reliability target or launch process for every company.",
    "No real users, teams, tickets, pages, incidents, services, dependencies, security controls, data systems, change systems or cloud environments were observed or modified.",
    "Passing project checks does not prove learner execution, independent transfer, delayed retention, interview performance, professional level or mastery."
  ]
}
---

# SRE principles: turn production pain into an engineering control loop

## What you see and first thought

You join a team called SRE. The queue is full. Somebody asks for a restart. Another person asks for access. A deployment is waiting. The pager rings again. Every application team says, “Production belongs to SRE.” Management says, “Please automate more.”

The beginner thought is:

> SRE means keeping servers up, doing tickets quickly, and knowing many tools.

The senior thought is:

> What user outcome is at risk, who owns that risk, which production mechanism failed, why is a human repeatedly required, and which engineering change makes the next occurrence safer or unnecessary?

That change in question is the heart of this chapter.

SRE does operate systems. It responds to incidents, carries production responsibility, debugs difficult failures, changes infrastructure, and sometimes performs manual work. But those actions are not the definition. The defining move is to use engineering, measurement, explicit risk decisions, and shared ownership so operational load does not grow one human at a time with the service.

Whenever you see a team drowning in work, remember this:

> Do not start by judging the people. Start by examining the control loop that sends work to them.

A queue is often the last visible boundary. Upstream may be unclear ownership, unsafe product design, missing self-service, poor defaults, broken releases, unactionable alerts, weak capacity planning, or an incentive that makes one team absorb everyone else's risk.

### The five first questions

1. **Which user operation matters?** “The API is up” is weaker than “an authorized customer can complete payment once and see the correct terminal state.”
2. **How reliable does it need to be?** Not “always.” Name the population, objective, window, harm and business owner.
3. **What work reaches humans?** Count incidents, pages, tickets, changes, interrupts, routine operations, engineering and overhead separately.
4. **Who can change the source?** The person clicking restart may not own worker code, retry policy, queue semantics or staffing.
5. **What evidence closes the loop?** A quiet pager, green checklist or completed automation is not automatically user recovery.

### What this chapter will make memorable

Use this compact model:

```text
USER -> RISK -> OBJECTIVE -> SERVICE -> EVIDENCE
  ^                                      |
  |                                      v
REVIEW <- ENGINEERING <- INCIDENT + TOIL
```

If the loop stops at `INCIDENT + TOIL -> HUMAN`, the organization is consuming people instead of improving the system.

## Terms before commands

Do not let familiar words stay vague. Vague terms create political arguments because different people are solving different problems with the same word.

### Reliability

Reliability is the probability or proportion that a service delivers a required outcome under stated conditions for a stated period. The important words are **required outcome**, **conditions**, and **period**.

“The process ran” is not enough if the payment was duplicated. “The endpoint returned 200” is not enough if it returned the wrong balance. Reliability includes the property users depend on: availability, latency, correctness, durability, freshness, or another explicit outcome.

### Site Reliability Engineering

SRE is an engineering discipline and operating model that applies software-engineering methods to service reliability and production operations. It combines:

- measurable user reliability;
- explicit risk tradeoffs;
- software and systems engineering;
- production responsibility and feedback;
- automation and source removal;
- observability and evidence;
- sustainable incident response;
- shared ownership across the lifecycle;
- learning that changes the system.

It is not one product, one team name, Kubernetes administration, cloud operations, dashboards, a NOC, or a promise of zero incidents.

### DevOps and SRE

DevOps is commonly used for a broad philosophy of breaking silos, shortening feedback, automating delivery, and sharing lifecycle responsibility. SRE is a more concrete set of reliability mechanisms and often a role or team. They overlap heavily.

A useful memory aid is:

```text
DevOps asks teams to collaborate across the lifecycle.
SRE gives that collaboration measurable reliability controls.
```

Do not waste interview time arguing which label is superior. Explain mechanisms and outcomes.

### Risk

Risk combines uncertainty with consequence. A failure can harm users, data, money, safety, compliance, trust, delivery speed, staff health or cost.

SRE does not eliminate all risk. It helps owners see, bound, choose and revisit risk using evidence. A reliability target is partly a product decision because higher reliability consumes engineering time, redundancy, complexity and money that cannot be spent elsewhere.

### Service level indicator, objective, and agreement

- **SLI:** the measured indicator, such as valid successful checkout events divided by valid checkout attempts.
- **SLO:** the internal objective for that indicator over a declared window.
- **SLA:** an external or formal commitment with consequences. It may be contractual. It is not merely a dashboard threshold.

The next chapter will go deeply into these. Here they matter because SRE without an objective has no stable way to decide whether reliability work, feature work, or cost reduction is most urgent.

### Error budget

If an SLO allows a bad fraction, that allowance is the error budget.

For a 99.9 percent objective:

```text
allowed bad fraction = 1 - 0.999 = 0.001 = 0.1 percent
```

The budget is not permission to cause incidents. It is a shared decision mechanism. When budget is healthy, change may proceed under policy. When it is consumed too quickly, teams invest in reliability and reduce risky change. Exact policy belongs to accountable owners and may include non-waivable safety, security or data constraints.

### Operations

Operations is work needed to run a service: deploy, observe, respond, recover, maintain, plan capacity, rotate credentials, restore data, coordinate changes and more. Operations is not automatically bad and not automatically toil.

### Toil

Toil is operational work that shows several properties:

- manual;
- repetitive;
- automatable;
- tactical or interrupt-driven;
- little enduring value;
- grows roughly with service size, traffic, customers or changes.

Not every property must be true. Context matters. A one-time manual diagnosis can be high-value engineering learning. A weekly copy-paste task can be toil even if it is easy. A task you dislike is not automatically toil. Calling someone's valuable work “toil” without evidence is disrespectful and analytically weak.

### Engineering work

Engineering work leaves an enduring improvement in the service or operating system: eliminating a defect, building a safe control, simplifying an architecture, improving failure containment, creating a tested self-service path, or making diagnosis substantially faster.

Code alone is not proof of engineering value. A script that restarts faster but creates duplicates can increase toil and risk.

### Non-toil operational work

Some operational work requires judgement and does not repeat predictably: leading a novel incident, reviewing a complex migration, or handling an unusual security event. It remains operational work but may not be toil.

### Overhead

Planning, training, mentoring, hiring, governance and necessary meetings are overhead. Some overhead creates essential capability. Measure it honestly; do not hide it inside engineering or toil to satisfy a target.

### Interrupt

An interrupt is unplanned work that breaks focus. It may be urgent or nonurgent. Interrupt cost includes the task plus context switching, incomplete project work and fatigue.

### On-call

On-call is a defined period during which a qualified person is ready to respond with appropriate urgency. A healthy on-call system includes scope, actionable signals, primary and secondary coverage, escalation, handoff, training, authority, runbooks, compensation according to local policy, psychological safety, and time for follow-up.

### Shared ownership

Shared ownership does not mean everyone owns everything. It means each important decision has an accountable owner, collaborating roles, authority, feedback and handoff. Product owns business value and risk. Developers own service design and code. Platform teams own their contract. SRE contributes production expertise and engineering. Security and data owners retain their obligations.

### Production readiness

Production readiness is evidence that a declared service version and exposure can be operated within accepted risk. It covers more than deployment success:

- user journeys and objectives;
- architecture and dependencies;
- capacity, overload and degradation;
- observability and alerting;
- change, rollback and compatibility;
- data backup, restore and integrity;
- security, privacy and audit;
- on-call, incident command and runbooks;
- ownership, staffing, training and support boundaries.

### Assertion, evidence, blocker, and accepted risk

- **Assertion:** what someone says or expects to be true.
- **Evidence:** an observation tied to version, environment, population, time, method and result.
- **Blocker:** a condition that must close before the proposed exposure.
- **Accepted risk:** a named authorized owner consciously accepts a bounded, usually expiring risk with rationale and controls.

Changing a checklist cell from missing to not applicable is not risk acceptance.

### Blameless learning

Blameless does not mean nobody is accountable. It means analysis seeks system conditions, decision context and mechanisms rather than stopping at personal blame. Actions still need owners and deadlines. Recklessness, policy violation or misconduct can be handled through appropriate processes without corrupting the technical learning review.

## Architecture map

### The reliability control loop

```text
                         BUSINESS / PRODUCT
                   value, harm, risk tolerance
                              |
                              v
USER --operation--> RELIABILITY CONTRACT --consequence policy--+
 ^                    |                                         |
 |                    v                                         v
 |                 SERVICE <--- design/change --- DEVELOPMENT + PLATFORM
 |                    |                                         |
 |                    v                                         |
 |            PRODUCTION EVIDENCE                               |
 |          /         |          \                              |
 |     incidents     toil      capacity/change                  |
 |          \         |          /                              |
 |                    v                                         |
 +-- verified -- ENGINEERING IMPROVEMENT <--- SRE/DEV/PLATFORM--+
                              |
                              v
                     OPERATING REVIEW
```

The key is direction. Production pain should travel back to the owner able to improve the source. If it travels only into an SRE ticket queue, the feedback loop is cut.

### Three systems, not one

An SRE works across three connected systems:

1. **The user system:** people, operations, outcomes and harm.
2. **The technical system:** software, infrastructure, data, dependencies and controls.
3. **The socio-technical system:** ownership, incentives, staffing, communication, change and learning.

A technical fix can fail because the ownership model keeps generating unsafe changes. An organizational change can fail because the service has no telemetry. A perfect dashboard can fail because nobody is authorized to act.

### Ownership is a decision graph

Avoid the statement “SRE owns production.” Replace it with decisions:

```text
Business risk target ---------- product / business owner
Good and total event ---------- product + development + SRE
Service design and code ------- development
Platform contract ------------- platform
Deployment and rollback ------- change owner + service owner
Capacity and overload --------- service + platform capacity owners
Security and data risk -------- security/data + service owner
Primary response -------------- qualified on-call
Incident command -------------- declared incident role
Preventive action ------------- owner able to change source
Verification ------------------ independent evidence owner
```

The same team may fill several roles in a small company. That is fine if the roles are explicit and sustainable. A matrix with names but no authority, time or skill is decorative.

### Work must return to the source

```text
bad pattern:
product -> developer -> ticket -> SRE -> manual click -> repeat

better pattern:
user symptom -> evidence -> source owner -> tested system change
                           \-> bounded response until change lands
```

SRE may build the change, pair with development, provide a platform feature, or coach a readiness review. The important property is that the recurring source changes.

## Request or state path

Use one example: a checkout worker becomes stuck.

### 1. The user operation

The user is not asking for a worker restart. The user is trying to complete checkout exactly once and receive a correct terminal result.

Write the contract:

```text
operation: authorized checkout submission
good: accepted once, correct amount, durable terminal state visible
total: valid authorized attempts reaching the service boundary
bad: rejected incorrectly, duplicate, wrong amount, timeout beyond objective, unknown state
```

### 2. Technical symptom

A worker stops consuming. Queue age rises. Checkout latency and unknown outcomes rise.

### 3. Human work appears

An alert tells on-call to restart the worker. The restart works. The incident closes. Tomorrow it repeats.

### 4. Classify the immediate work

The first novel response may be necessary operations. After the pattern becomes known, the same manual restart is:

- manual;
- repetitive;
- predictable;
- tactical;
- likely automatable;
- no enduring fix;
- likely to grow with traffic or workers.

It is a strong toil candidate.

### 5. Do not automate the click yet

Ask why the worker is stuck:

- deadlock;
- poison message;
- dependency timeout without bound;
- lost lease;
- memory pressure;
- missing liveness signal;
- incorrect restart policy;
- duplicate consumers;
- backlog beyond capacity.

A restart bot can create duplicate side effects, retry storms, data corruption, or a fast loop that hides the defect.

### 6. Bound the response

Until the source is removed, define:

- valid stuck detection;
- maximum automatic attempts;
- cool-down and retry budget;
- idempotency or reconciliation;
- per-worker and global rate limits;
- audit trail;
- manual override;
- abort and rollback;
- user and queue recovery proof.

### 7. Return ownership

The service code owner owns deadlock or poison-message behavior. The platform owner owns worker-runtime or lease contracts. SRE may own the detection/control framework. Product owns acceptable user risk. Incident ownership does not transfer permanent source ownership.

### 8. Verify the improvement

Measure before and after:

- bad user events;
- queue age and saturation;
- stuck occurrences;
- restart attempts;
- duplicate outcomes;
- human minutes;
- pages and actions;
- automation failures;
- residual manual fallback;
- recurrence over a declared window.

Fewer manual restarts alone can mean the bot is working—or the alert is broken.

## Failure zoom

### Failure 1: rename operations to SRE

Symptoms:

- same ticket queue;
- same manual approvals;
- same unbounded support scope;
- no user objectives;
- developers insulated from incidents;
- team judged on ticket closure;
- no protected engineering time.

Root mechanism: incentives and ownership did not change.

Safe move: establish service contracts, work measurement, intake boundaries, shared source ownership and protected engineering capacity. Do not blame the renamed team for being unable to engineer while 100 percent allocated to response.

### Failure 2: automate every ticket

Symptoms:

- faster unsafe access;
- automated configuration drift;
- restart loops;
- hidden errors;
- more privileged service accounts;
- no reduced user incidents.

Root mechanism: the organization automated the surface action before understanding policy and state.

Safe move: eliminate unnecessary requests, create safe defaults and self-service contracts, validate authorization, use least privilege, test failures, and measure source reduction.

### Failure 3: pursue 100 percent reliability

Symptoms:

- change freezes;
- excessive redundancy cost;
- slow delivery;
- fear-based approvals;
- hidden errors because teams cannot admit budget use;
- no connection to user need.

Root mechanism: reliability became an absolute slogan instead of a product risk decision.

Safe move: identify journeys and harm, choose measurable objectives with accountable owners, define non-waivable constraints, and use evidence to balance reliability, delivery and cost.

### Failure 4: checklist-driven readiness

Symptoms:

- rows green without evidence;
- missing becomes not applicable;
- one percentage score;
- no exposure model;
- no decision owner;
- no expiry;
- no rollback rehearsal.

Root mechanism: the artifact replaced judgement.

Safe move: bind every claim to evidence, treat required missing items as blockers, document accepted risk precisely, and issue an exposure-specific decision.

### Failure 5: SRE owns every outage

Symptoms:

- developers ship but never respond;
- code defects become permanent runbook steps;
- SRE headcount grows with services;
- product risk remains implicit;
- handoffs dominate incidents.

Root mechanism: accountability sits away from change authority.

Safe move: make production feedback shared, retain clear role boundaries, and assign prevention to the owner who can change the source.

### Failure 6: on-call becomes heroism

Symptoms:

- single expert;
- missed pages;
- no secondary;
- no rest;
- repeated incidents;
- incomplete reviews;
- fear of escalation.

Root mechanism: human capacity is treated as infinite redundancy.

Safe move: reduce exposure if necessary, bring qualified help, rehearse escalation, improve signals, protect rest and follow-up, and make service scope fit staffed capability.

### Failure 7: blame replaces learning

Symptoms:

- “operator error” as root cause;
- hidden near misses;
- vague action “be careful”;
- same incident recurs;
- people avoid taking action.

Root mechanism: the review stops at the last human action instead of asking why that action was possible and reasonable in context.

Safe move: preserve accountability while analyzing system conditions, interfaces, incentives, safeguards, evidence and decision context. Assign verifiable changes.

## Internals and state ownership

### Reliability belongs to a product, not a dashboard

The actual state exists across:

| State | Primary owner | Durable identity | Failure evidence |
|---|---|---|---|
| user outcome | product/service | journey plus terminal event | invalid result, timeout, abandonment |
| business risk | authorized business owner | risk decision and scope | harm exceeds accepted boundary |
| objective | shared product/development/SRE | versioned SLI/SLO policy | invalid population or budget breach |
| service behavior | development | code/config/artifact version | errors, latency, corruption, overload |
| platform behavior | platform team | platform contract/version | control-plane or resource failure |
| production change | change and service owner | deployment and rollback ID | regression, incompatibility, drift |
| incident response | incident roles | incident/timeline | delayed detection, action or handoff |
| on-call capacity | engineering leadership | rotation and qualification | uncovered shift, overload, fatigue |
| recurring work | service/team owner | work-source record | time growth, recurrence, risk |
| readiness | launch/risk authority | decision and evidence set | missing control, expired acceptance |
| learning action | source owner | action, due date, verifier | recurrence or unverified closure |

No one dashboard owns all of this state.

### Time accounting must conserve time

For one declared team and week:

```text
available hours = engineers * contractual available hours

available = toil
          + non-toil operational work
          + engineering work
          + overhead
          + unclassified time
```

Categories must be mutually exclusive for the calculation. If an incident review is counted as both operations and engineering, totals lie. You may also keep secondary tags, but choose one primary accounting category.

Example:

```text
6 engineers * 40 hours = 240 hours
toil                         92
non-toil operations          38
overhead                     46
engineering                  64
total                       240

engineering fraction = 64 / 240 = 26.67 percent
```

This reveals a system constraint. It does not prove laziness or a universal 50 percent policy. Distribution matters: one person can carry most on-call load while the average looks acceptable.

### Toil inventory schema

For each work source, record:

```text
source_id
service and user operation
trigger
occurrences per week
minutes per occurrence
people interrupted
after-hours flag
manual/repetitive/automatable/tactical/value/growth properties
required privilege and data sensitivity
failure consequence
current owner
source owner
safe fallback
candidate intervention
measurement confidence
```

This turns “we are busy” into a portfolio of engineering decisions.

### Automation return is a range

A beginner formula is:

```text
weekly labor saved = occurrences * minutes saved / 60
break-even weeks = build hours / weekly labor saved
```

A senior estimate adds:

```text
net value = labor saved
          + expected incident risk reduced
          + capacity or delivery value
          - build cost
          - maintenance
          - adoption and migration
          - automation failures
          - security and compliance cost
          - opportunity cost
```

Every term has uncertainty. Provide low/base/high ranges and sensitivity. Do not claim ten hours saved if operators use the saved time to verify a flaky bot for ten hours.

### Readiness is not one score

Some controls are gates. Losing data integrity cannot be averaged with nineteen green documentation rows. Model readiness as dimensions:

```text
user reliability      required / evidence / gap
capacity and overload required / evidence / gap
dependency failure    required / evidence / gap
change and rollback   required / evidence / gap
backup and restore    required / evidence / gap
security and privacy  required / evidence / gap
observability         required / evidence / gap
on-call and incident  required / evidence / gap
ownership and support required / evidence / gap
```

For each gap choose:

- close before launch;
- reduce exposure and close before expansion;
- accept bounded risk with authority and expiry;
- declare non-applicable with technical evidence;
- stop because evidence is unavailable.

### Shared ownership needs disagreement handling

When product wants speed and SRE wants safety, “SRE says no” is weak. Use the contract:

1. State the proposed exposure and user value.
2. State observed reliability and uncertainty.
3. State expected risk and worst credible consequence.
4. State missing evidence.
5. Offer smaller reversible alternatives.
6. Name the authorized decision owner.
7. Record the decision, dissent, controls, expiry and re-review.

This makes disagreement an engineering and business decision rather than a power contest.

## Evidence table

| Observation | Supports | Does not establish | Next discriminating evidence |
|---|---|---|---|
| Team is named SRE | organizational label exists | SRE practices, skill, authority, reliability or sustainability | SLO consequences, work mix, engineering outcomes, shared ownership |
| 78 percent is called toil | one reported aggregate | category validity, individual distribution, source or reducibility | sampled work ledger with definitions and confidence |
| Manual task repeats | recurrence exists | safe automation or low value | failure modes, privilege, source, user risk, elimination alternatives |
| Automation reduced clicks | one surface activity declined | reduced toil, risk or user incidents | total human time, new failures, recurrence, user outcome |
| Dashboard says 99.95 percent | query produced a value | valid SLI, coverage, correctness or accepted target | good/total contract, denominator, freshness, segments, owner |
| Objective is met | measured value is within target under stated inputs | ideal target, zero risk or permission for every change | error-budget policy, trend, dependency/security constraints |
| Pager is quiet | no observed delivery | users healthy or monitoring functional | user journey, telemetry health, evaluator/receiver tests |
| Checklist is 90 percent green | row-state arithmetic | readiness when a critical control is missing | blocker severity, evidence, exposure, owner and acceptance |
| Rollback passed once | one procedure succeeded once | future compatibility or stressed recovery | repeated version-bound rehearsal and observation |
| Restore file exists | an object is present | restorability, integrity, RTO or RPO | isolated restore, validation, clocks, loss window |
| Owner name is listed | a label is present | authority, availability, competence or handoff | acknowledgement, decision exercise and escalation test |
| Postmortem completed | document exists | learning or prevention | action quality, ownership, verification and recurrence |
| Pages per week decreased | notification load changed | improved precision or preserved recall | significant-event ground truth and user impact |
| Engineering fraction increased | accounting category changed | useful engineering outcomes or better reliability | delivered source removal and measured user/operator results |

### Evidence hierarchy

Prefer evidence close to the claim:

1. **User claim:** valid user outcome population.
2. **Technical mechanism claim:** version-bound direct state and behavior.
3. **Work claim:** sampled task events and time with definitions.
4. **Ownership claim:** exercised decision and handoff.
5. **Readiness claim:** tested control under proposed exposure.
6. **Improvement claim:** before/after outcomes with confounders and stability window.

An interview answer becomes senior when it says not only what data to collect, but why that data can decide between actions.

## Command decoders

The lab commands are not magic. Read them as questions.

### Decoder 1: environment identity

```bash
id; uname -a; cat /etc/os-release; python3 --version; date -u +%Y-%m-%dT%H:%M:%SZ; pwd
```

- `id`: who owns created state?
- `uname -a`: which kernel and environment report themselves?
- `/etc/os-release`: which distribution contract is being tested?
- `python3 --version`: which interpreter executes the model?
- `date -u`: what clock frames the attempt?
- `pwd`: which lesson copy are you using?

If `uid=0`, stop. Root is unnecessary and makes ownership/cleanup evidence less representative.

### Decoder 2: fixture validation

```bash
python3 fixtures/sre_operating_model.py validate-scenario fixtures/scenario.json
```

This validates exact keys, types, finite ranges, identifiers and required evidence fields. It does not validate business truth. A syntactically valid fictional organization remains fictional.

### Decoder 3: setup

```bash
bash lab.sh setup
```

Setup refuses root, validates tools and inputs, creates a private candidate, writes an exact sentinel and manifest, copies the scenario, then atomically publishes the state. It never calls `sudo`, a package manager, network, Docker or a real service.

### Decoder 4: risk

```bash
bash lab.sh run risk
```

For each declared service:

```text
allowed bad fraction = 1 - target
observed bad fraction = 1 - actual
allowed bad events = total events * allowed bad fraction
observed bad events = total events * observed bad fraction
remaining = allowed - observed
```

Negative remaining means exhausted under the fixture. It does not say why or who may accept it.

### Decoder 5: toil

```bash
bash lab.sh run toil
```

The teaching heuristic calls a task a toil candidate when at least four of six encoded properties are true. That threshold is deliberately visible so you can challenge it. A real classification requires team context and risk review.

### Decoder 6: automation

```bash
bash lab.sh run automation
```

The model calculates a narrow first-quarter estimate. It explicitly omits several real costs. Use the result to ask better questions, not to approve implementation.

### Decoder 7: workload

```bash
bash lab.sh run workload
```

The calculation assumes categories do not overlap and all six engineers have forty available weekly hours. Vacation, training, regional hours, part-time status and uneven on-call distribution would change the denominator.

### Decoder 8: ownership

```bash
bash lab.sh run ownership
```

This is set difference:

```text
missing decisions = required decisions - assigned decision keys
```

It detects empty map coverage, not whether owners can act.

### Decoder 9: readiness

```bash
bash lab.sh run readiness
```

The model fails closed: every required row must be present. Accepted risk on an optional row is listed but not treated as evidence. Real reviews need severity and non-waivable policy, not only Boolean logic.

### Decoder 10: operating review

```bash
bash lab.sh run operating-review
```

The model flags a period when any declared threshold is crossed. The row tells you why to investigate. It does not say the thresholds are correct or the metrics cause one another.

### Decoder 11: full verification

```bash
bash verify.sh
```

The verifier checks syntax, scenario, setup, eight cases, exact assertions, refusal of an unexpected file, refusal of a symlink and cleanup. `final_state=absent` is a cleanup claim for one path, not an organizational result.

### Decoder 12: first failure rule

If a command fails:

1. keep the first meaningful error;
2. do not skip to a later step;
3. record environment and exact command;
4. distinguish code defect, environment blocker and violated safety contract;
5. never manually erase ambiguous state just to make the verifier green.

## Decision path

### When a team says “we need SRE”

```text
What user/business problem exists?
  |
  +-- no defined problem --> do not create a team label; discover demand
  |
  +-- reliability/operations problem
         |
         v
Is user reliability measurable and owned?
  |
  +-- no --> define journey, indicator, objective and consequence
  |
  +-- yes
         |
         v
Is recurring work measured and source-owned?
  |
  +-- no --> inventory work, pages, changes, incidents and growth
  |
  +-- yes
         |
         v
Can current staffing sustain response and engineering?
  |
  +-- no --> reduce scope/exposure/load, add qualified capacity, renegotiate support
  |
  +-- yes
         |
         v
Choose engagement: embedded, service SRE, platform, consulting, shared on-call,
or product team adopting SRE practices. Review outcomes, not labels.
```

### When deciding whether work is toil

Ask:

1. What exact task event and population?
2. What user or operator risk does it handle?
3. Is it manual?
4. Is it repetitive and predictable?
5. Is it tactical?
6. Does it create enduring value?
7. Could it be eliminated, simplified or safely automated?
8. Does volume grow with service demand?
9. Who owns the source?
10. What uncertainty remains?

Use `toil-candidate`, not a moral judgement.

### When choosing an automation project

```text
Can the demand be removed by product/policy/design change?
  yes -> remove it; avoid automating waste
  no
   |
Is the state and authority contract clear?
  no -> measure and define before automation
  yes
   |
Can failures be bounded, detected and reversed?
  no -> retain manual control and redesign
  yes
   |
Does risk-adjusted value exceed full lifecycle cost?
  uncertain -> run a small reversible experiment
  yes -> canary, measure residual work and user outcome
```

### When reviewing readiness

Use four decisions:

- **Go:** required evidence supports the proposed exposure; residual risks are owned.
- **Limited:** smaller enforced exposure is supported; expansion has explicit gates.
- **No-go:** required blocker remains or risk exceeds authorized boundary.
- **Blocked for evidence:** the reviewer cannot decide because evidence is missing or contradictory.

“Blocked for evidence” is stronger than guessing.

### When product and reliability conflict

Offer options rather than a veto:

| Option | Exposure | Evidence required | Benefit | Risk | Reversal |
|---|---|---|---|---|---|
| full launch | all planned users | all critical gates | maximum immediate value | maximum unresolved blast radius | hardest |
| limited launch | bounded cohort/rate/region | gates for shared state plus cohort | learn sooner | residual shared-dependency risk | rapid withdrawal |
| internal test | controlled identities | correctness and safety | cheap learning | weak user representativeness | easy |
| delay | none | closure experiments | strongest risk reduction | opportunity cost | decision revisited |

Then let the authorized owner decide within legal, safety, security and data constraints.

## Guided Ubuntu lab

### Purpose

You will not “implement SRE” in a Python script. You will practise the arithmetic and distinctions that prevent shallow SRE decisions.

The lab is local, offline and disposable. It teaches eight cases without contacting any real team or service.

### Phase 0: read before running

From the lab directory:

```bash
sed -n '1,240p' README.md
```

Confirm:

- normal user;
- exact `/tmp/reliability-atlas-les0031-<uid>` state;
- no network or external systems;
- cleanup refusal on unexpected state;
- model non-claims.

### Phase 1: establish context

Run command card 001. Write one sentence:

```text
I am running as UID ___ on ___ with Python ___ from ___ at ___ UTC.
```

This is an evidence header, not bureaucracy. Without it, results cannot be reproduced.

### Phase 2: validate and set up

```bash
python3 fixtures/sre_operating_model.py validate-scenario fixtures/scenario.json
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Expected meaning:

- the fixture contract validates;
- root and missing dependencies would refuse;
- the exact owned state is ready;
- zero result files exist initially.

### Phase 3: risk is a tradeoff, not a slogan

```bash
bash lab.sh run risk
```

Build a table:

| Service | Target | Actual | Allowed bad events | Observed bad events | Remaining | State | Missing decision |
|---|---:|---:|---:|---:|---:|---|---|

For `public-checkout`, the fixture yields:

```text
target 0.999 -> allowed bad fraction 0.001
2,000,000 events -> 2,000 allowed bad events
actual 0.9985 -> observed bad fraction 0.0015
2,000,000 events -> 3,000 observed bad events
remaining = -1,000
```

Correct conclusion: the declared event-based budget is exhausted.

Incorrect conclusion: SRE must stop every release. You still need population validity, cause, policy, security/data constraints, trend and authorized owners.

Notice `internal-preview`: its actual reliability exceeds its declared target. Spending 180 hours for another reliability increment may or may not be useful. Ask what users need and what else those hours could produce.

### Phase 4: classify work without insulting work

```bash
bash lab.sh run toil
```

The two fixture toil candidates total 600 minutes per week. The total observed work in that small inventory is 930 minutes, so:

```text
600 / 930 = 0.645161
```

Do not say “64.5 percent of the team is toil.” The denominator is four sampled tasks, not total team capacity. Say:

> Under the fixture heuristic, toil candidates represent 64.5 percent of the minutes in this four-task sample.

That sentence is longer and far more accurate.

### Phase 5: estimate automation honestly

```bash
bash lab.sh run automation
```

The model selects worker self-recovery for the best declared first-quarter result. Now challenge it:

- What if adoption takes 20 hours?
- What if incorrect recovery causes duplicate payments?
- What if maintenance doubles?
- What if fixing the deadlock takes 24 hours and eliminates the need?
- What privilege does the controller require?
- Who is paged when the controller fails?

An ROI table without failure cost is an optimism table.

### Phase 6: measure workload conservation

```bash
bash lab.sh run workload
```

The fixture returns 64 engineering hours of 240, or 26.67 percent, with a 56-hour gap to its declared 50 percent minimum.

Rank responses safely:

1. protect current critical response;
2. validate category definitions and uneven distribution;
3. remove or reduce highest-risk toil sources;
4. reduce noncritical service scope or intake;
5. improve page actionability;
6. share production feedback with source owners;
7. add qualified staffing where durable demand remains;
8. revisit the threshold and service charter with evidence.

Do not order individuals to hide operational hours as “engineering.”

### Phase 7: find ownership holes

```bash
bash lab.sh run ownership
```

The map lacks `capacity-owner` and `on-call-secondary`. Write why each matters:

- Without capacity ownership, peak, headroom and acquisition decisions can remain nobody's job.
- Without a qualified secondary, primary response has no reliable escalation or relief path.

Then state the limit: assigning two labels does not staff or exercise those roles.

### Phase 8: refuse checklist theater

```bash
bash lab.sh run readiness
```

The fixture returns `no-go` because required user-journey SLO, dependency-failure test and secondary on-call evidence are missing.

For each blocker, propose a closure experiment:

| Blocker | Smallest safe evidence | Abort | Owner | Non-claim |
|---|---|---|---|---|
| user journey | controlled correct terminal outcomes with denominator | wrong/duplicate state | product + service | not all users or future load |
| dependency failure | bounded failure/recovery test | data risk or uncontrolled retry | dependency + service | not every dependency mode |
| secondary | qualification and handoff simulation | responder unsafe/unprepared | engineering leadership | not long-term sustainability |

### Phase 9: operating review

```bash
bash lab.sh run operating-review
bash lab.sh run incident
```

Week 1 crosses toil only. Week 2 crosses SLO, page, toil and change thresholds. Week 3 crosses none.

Do not infer that toil caused the SLO breach. Form hypotheses:

- change failures caused incidents and pages;
- page load interrupted preventive work;
- product growth increased both toil and failure;
- invalid classification inflated toil;
- one dependency caused SLO and page changes;
- staffing absence affected response duration.

Choose evidence that separates them.

### Phase 10: verify and clean

```bash
bash verify.sh
bash lab.sh status
```

Required final status:

```text
state=absent
```

If verification fails, the first failure is the result. Do not manually delete unknown state.

### Lab teach-back

Explain in two minutes:

1. why SRE is not a team rename;
2. why toil is not all manual work;
3. why automation return includes risk;
4. why an owner label is not ownership proof;
5. why a checklist cannot grant readiness;
6. why a quiet pager is not user recovery.

## Production transfer

### A practical ninety-day SRE recovery

This is a sequencing pattern, not a universal calendar.

#### Days 1–14: stabilize and make work visible

- Declare critical services and user operations.
- Confirm primary, secondary and management escalation.
- Protect responder rest and safe handoff.
- Preserve critical symptom alerts; pause only clearly nonurgent unowned intake through authorized policy.
- Sample tickets, pages, incidents, changes, routine tasks, engineering and overhead.
- Record source, owner, duration, recurrence, privilege, user risk and growth.
- Identify immediate security, data, capacity or safety blockers.

Deliverable: a service and work map, not an automation backlog.

#### Days 15–30: create decision contracts

- Agree initial user journeys and valid terminal outcomes.
- Build provisional SLIs and objectives with product and development.
- Define error-budget or risk consequences.
- Assign product risk, code, platform, change, capacity, security, data, on-call and incident owners.
- Write support boundaries and escalation.
- Rank top work sources and page populations.

Deliverable: owners can decide which risk and work matters.

#### Days 31–60: remove one source safely

- Choose a high-risk, high-frequency source with clear state.
- Prefer elimination or simplification over automating the final click.
- Define authority, inputs, outputs, idempotency, limits, observability, audit, manual fallback, canary, abort and rollback.
- Test normal, missing, duplicate, delayed, partial, concurrent and recovery cases.
- Roll out to a bounded population.

Deliverable: one measured source-removal loop with proof limits.

#### Days 61–90: institutionalize the review

- Review user SLO, budget, changes, incidents, pages, capacity, toil, engineering allocation, security and cost together.
- Track action owners and verified closure.
- Update readiness standards from incidents and near misses.
- Train and simulate on-call handoffs.
- Renegotiate support scope or staffing when load remains unsustainable.
- Publish outcomes and unknowns without ranking individual heroes.

Deliverable: an operating cadence that can continue after the initial project.

### Production-readiness review worksheet

| Dimension | Questions | Evidence | Common blocker |
|---|---|---|---|
| users | who performs what operation and what harm matters? | journey and terminal outcomes | component metric only |
| objective | what is good, total, target, window and consequence? | versioned SLO policy | target without owner |
| architecture | what boundaries and dependencies exist? | dependency map and failure contracts | unknown critical dependency |
| capacity | peak, headroom, queues, failure demand, scaling? | representative load and model | average used as peak |
| overload | what is shed, queued, rejected or degraded? | bounded overload test | unlimited retries |
| change | artifact, config, migration, canary, rollback? | repeated rehearsal | rollback impossible after schema change |
| data | backup, restore, integrity, RTO/RPO? | isolated restore and reconciliation | backup existence only |
| observability | user signal, coverage, freshness, alerts? | known event and missing-path tests | green missing data |
| security | identity, least privilege, secrets, audit, threat? | control and negative tests | broad automation credential |
| incident | severity, roles, comms, escalation, runbooks? | simulation and acknowledgement | no qualified secondary |
| ownership | who decides and who changes source? | exercised decision map | SRE owns everything |
| launch | exposure, gate, abort, rollback, observation? | rollout plan and authority | monitor closely |

### Limited launch design

A limited launch must constrain the actual harm variable:

- users or tenants;
- region;
- rate or concurrency;
- transaction value;
- data class;
- feature capability;
- duration;
- shared dependency load.

If ten canary users write into the same irreversible global ledger, user count may not bound blast radius.

### Operating review agenda

Keep one evidence pack:

1. user SLI and budget with coverage;
2. significant incidents and near misses;
3. change outcomes and rollback;
4. page quality and human response;
5. toil sources and engineering allocation;
6. capacity, saturation and forecast;
7. security, data and compliance risks;
8. cost per user operation where meaningful;
9. ownership gaps and expiring accepted risks;
10. preventive actions and measured outcomes.

Avoid a meeting that reads charts without making decisions.

### Scaling beyond one SRE team

You do not need an SRE team for every service. Options include:

- product teams using SRE practices themselves;
- a shared reliability consulting group;
- a platform team embedding safe defaults and control planes;
- service-aligned SRE for critical complex systems;
- temporary embedded engagements;
- shared on-call with explicit boundaries.

Choose based on service criticality, operational complexity, scale, available expertise, change rate and expected engineering leverage. SRE scarcity is itself a prioritization constraint.

## Reliability, security, observability, capacity, and cost

### Reliability outcome

Reliability is the product outcome, not simply uptime. SRE work should improve one of these:

- fewer bad user outcomes;
- shorter detection, containment or recovery;
- lower chance or blast radius of failure;
- better correctness or durability;
- more predictable change;
- safer degradation;
- sustainable human response.

Automation that saves time but increases duplicate payments is a reliability failure.

### Security

SRE automation often has broad production authority. Treat it as privileged software:

- least-privilege identity;
- explicit target scope;
- validated inputs;
- deny-by-default behavior;
- bounded concurrency and rate;
- secret-safe logs;
- tamper-evident audit;
- approval for dangerous actions;
- rollback or disable path;
- dependency and supply-chain review;
- separation of duties where required.

Do not “eliminate toil” by bypassing an authorization control. Improve the control with security owners.

### Observability

You need observability for both service and operating system:

```text
service: user outcome, traffic, errors, latency, saturation, dependencies
work: source, count, duration, owner, outcome, recurrence
change: version, rollout, failure, rollback
human: pages, acknowledge, action, escalation, after-hours load
control: automation attempts, success, refusal, override, side effects
evidence path: coverage, freshness, missing and query error
```

Do not instrument individuals for surveillance. Measure systems and workloads with transparent purpose, minimal personal data, access controls and retention.

### Capacity

Capacity includes machines and humans.

Technical capacity:

- arrival rate;
- concurrency;
- service time;
- queues;
- saturation;
- dependency limits;
- failover and overload;
- forecast and acquisition lead time.

Human capacity:

- staffed qualified hours;
- primary and secondary coverage;
- interrupt load;
- training and handoff;
- follow-up time;
- leave and regional constraints;
- cognitive load and service count.

Adding a page does not add response capacity.

### Cost

Reliability cost is not just infrastructure spend:

- redundancy and reserved headroom;
- engineering and operational time;
- opportunity cost;
- tooling and licenses;
- data retention and queries;
- incident harm;
- support and compliance;
- staff attrition and fatigue;
- complexity maintenance.

Use a unit such as cost per successful critical operation when possible. But do not optimize away safety, security, data integrity or essential resilience because a spreadsheet omits rare high-consequence loss.

### Tradeoff table

| Decision | Reliability benefit | New risk/cost | Evidence before expansion |
|---|---|---|---|
| add redundancy | failure tolerance | cost, complexity, correlated failure | failover and capacity test |
| automate restart | faster recovery | loop, duplicates, privilege | state-machine and side-effect test |
| raise SLO | stronger promise | cost, slower change | user need and marginal benefit |
| silence alerts | lower interruption | missed user harm | precision/recall and retained coverage |
| share on-call | better feedback | training and fatigue | qualification and load model |
| centralize platform | consistent controls | shared blast radius | isolation, tenancy, rollback, SLO |
| require PRR | catches risk | process delay and theater | severity-based, evidence-led review |

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| SRE is the person who knows Linux | skill is useful but does not create an operating model | connect skill to user risk, ownership and engineering outcomes |
| SRE owns production alone | separates source authority from feedback | explicit shared decision and source ownership |
| every manual task is toil | manual judgement can be valuable | use multiple properties and context |
| toil is work I dislike | makes classification personal | use event populations, value and growth |
| exactly 50 percent is universal law | contexts and categories differ | declare local target and protect coverage while changing load |
| automation always removes toil | bad policy and failure can scale | eliminate/simplify first; measure total lifecycle outcome |
| script completed means success | user or state can still be wrong | verify independent outcome and residual work |
| 100 percent is the safest target | cost and change can become harmful | explicit business/user risk decision with non-waivable constraints |
| SLO is an SLA | internal objective and external commitment differ | name owner, audience and consequence |
| error budget permits planned outages | budget is a control, not permission | policy, authorization, safeguards and user harm remain |
| green checklist means ready | critical missing rows can be averaged away | evidence gates and exposure-specific decision |
| not applicable closes a gap | label does not prove irrelevance | technical rationale, owner, control, expiry and review |
| one rollback proves recovery | version and stress differ | repeat, test compatibility, observe stability |
| backup means restore | stored bytes may be unusable | isolated restore, integrity and RTO/RPO proof |
| quiet pager means healthy | detection or delivery may be broken | independent user and monitoring-path evidence |
| more pages improve safety | humans ignore noise and lose follow-up time | actionability, significant-event coverage and page budget |
| one expert is redundancy | same person is one failure domain | qualified secondary, documentation, training and handoff |
| blameless means no accountability | actions become unowned | system-focused analysis plus named verified actions |
| operator error is root cause | stops before mechanism and context | ask what made action possible, likely and harmful |
| postmortem document equals learning | recurrence can continue | verify actions and track recurrence |
| platform solves every team | shared controls create shared blast radius | contract, tenancy, rollback and platform SLO |
| maturity model is a score chase | teams optimize labels | measure user and operator outcomes |

### Prevention questions before accepting work

Ask:

- Which service and user operation?
- Is this incident, request, change, toil candidate or project?
- Who owns the source?
- Why must SRE perform it?
- What is the urgency and consequence?
- Is there an approved self-service path?
- What evidence defines success?
- Will this recur or grow?
- What work is displaced?
- What exit condition removes it from the queue?

This is not refusal theater. It is intake engineering.

## Memory card and retrieval

### The SRE loop

```text
USER -> RISK -> OBJECTIVE -> EVIDENCE -> ENGINEERING -> REVIEW
```

### The toil test

```text
manual + repetitive + automatable + tactical + low enduring value + grows
```

Several properties make a toil candidate. Dislike does not.

### The readiness rule

```text
assertion != evidence
missing != not applicable
checklist != authority
quiet != recovered
```

### The ownership rule

```text
incident owner handles now
source owner prevents next
risk owner accepts exposure
evidence owner verifies outcome
```

### The automation rule

```text
remove demand > simplify > safe self-service > bounded automation > manual fallback
```

### The human rule

```text
people are part of capacity, not an unlimited buffer
```

### Sixty-second recall

If asked “What is SRE?” say:

> SRE is a software-engineering approach and operating model for reliable services. It starts with user-relevant objectives and explicit risk, connects production feedback to the teams able to change the system, keeps operational load sustainable, engineers away recurring toil, uses evidence-led readiness and change controls, and learns from incidents. It is not a team rename, tool stack, pager queue, or promise of perfect uptime.

### Five-minute recall frame

1. User outcome and risk.
2. SLI/SLO and consequences.
3. Shared lifecycle ownership.
4. Production feedback and on-call.
5. Work taxonomy and toil measurement.
6. Source removal and safe automation.
7. Readiness and reversible change.
8. Learning and measured outcomes.
9. Human sustainability.
10. Proof limits.

## Complete answers

### Question 1: Why is SRE not simply operations with automation?

**Answer:** Operations with automation can still have no user objective, no shared risk policy, no protected engineering capacity and no source ownership. SRE uses software engineering as one mechanism inside a broader control loop: user reliability is defined, risk owners choose targets and consequences, production feedback reaches code and platform owners, recurring work is measured and reduced, changes and readiness use evidence, on-call is sustainable, and incidents create verified prevention. Automation is valuable when it improves that loop. A fast unsafe script is not SRE.

### Question 2: Why is 100 percent reliability usually a bad default?

**Answer:** Every additional reliability increment can require disproportionate redundancy, testing, complexity, process and cost. It can also reduce feature delivery and make teams hide normal failure. Users may not perceive the extra increment, especially when their device or network is less reliable. The right objective depends on user harm, service role, alternatives, security/data constraints and business risk. Some properties may require extremely strong guarantees, but “100 percent” must not replace analysis.

### Question 3: Is an incident toil?

**Answer:** Not automatically. The first response to a novel high-impact incident requires judgement and produces learning; it can be valuable non-toil operational work. Repeating the same manual mitigation without source improvement becomes a strong toil candidate. Classify the work event and its context, not the word “incident.”

### Question 4: How do you measure toil without spying on people?

**Answer:** Measure work sources and system demand, not individual worth. Define transparent categories with the team, sample tickets/pages/tasks, record trigger, service, duration bands, recurrence, growth, privilege, user risk, owner and outcome, minimize personal data, restrict access and retention, allow correction, and report aggregates with uncertainty. Use the result to improve systems and workload, not rank heroes.

### Question 5: What should you automate first?

**Answer:** First ask whether demand can be eliminated or simplified. If not, choose a high-risk or high-volume recurring source with clear state and authority, measurable benefit, bounded failure, safe fallback and an owner. Include build, maintenance, adoption, security, opportunity cost and failure risk. Canary it and measure user outcome plus residual human work. Do not choose only the easiest visible click.

### Question 6: What is protected engineering time?

**Answer:** It is capacity deliberately reserved for enduring system improvement rather than consumed by immediate operations and overhead. A local policy may use a target such as half of time, but the mechanism matters: the team must reduce or renegotiate load, maintain response coverage, classify time honestly, and deliver measured improvements. Hidden overtime is not protected engineering time.

### Question 7: Who owns reliability?

**Answer:** Reliability is shared but decisions are explicit. Product or business owners define user value and accept business risk. Development owns service design and code. Platform owns platform contracts. SRE contributes production engineering and may operate critical services. Security, data, capacity, change and incident roles retain their decisions. The incident commander owns coordination during an incident; the source owner owns prevention. “Everyone” without a decision map usually means nobody.

### Question 8: What is a production-readiness review?

**Answer:** It is an evidence-led decision about whether a declared service version and exposure can be operated within accepted user, technical, data, security and human risk. It examines journeys/objectives, dependencies, capacity/overload, observability, change/rollback, backup/restore, security/audit, incident/on-call, ownership and launch controls. It produces go, limited, no-go or blocked-for-evidence plus owners and re-review—not a decorative score.

### Question 9: Can risk be accepted when evidence is missing?

**Answer:** Sometimes an authorized owner can accept a bounded waivable risk, but missing evidence remains missing. Record scope, consequence, uncertainty, rationale, compensating controls, owner, expiry, follow-up and re-review. Safety, legal, security, data-integrity or policy controls may be non-waivable. Acceptance is not a way to hide a blocker.

### Question 10: How do you prove an automation reduced toil?

**Answer:** Compare matched before/after work-source populations over a stable window: occurrences, human minutes, people interrupted, after-hours load, failure and override time, maintenance, pages, user outcomes and recurrence. Account for product demand and other changes. Verify that the source or safe handling changed and no new hidden work appeared. A lower click count alone is insufficient.

### Question 11: What makes on-call sustainable?

**Answer:** Critical actionable signals; manageable load; qualified primary and secondary coverage; clear scope, authority and escalation; handoff; training and simulations; useful runbooks; psychological safety; rest and local compensation policy; and protected time to fix sources. Sustainability is measured over rotations and individuals, not inferred from a staffed calendar.

### Question 12: What does blameless mean?

**Answer:** Analyze technical and organizational conditions, information, safeguards, incentives and decision context instead of treating one person's last action as the complete cause. Preserve accountability: evidence must be accurate, actions need owners, deadlines and verification, and misconduct can follow appropriate processes. Blamelessness improves learning; it does not erase responsibility.

### Question 13: A team meets its SLO. Should it stop reliability work?

**Answer:** No automatic conclusion follows. It may safely prioritize product work under policy, but should review trend, segments, security/data constraints, capacity horizon, dependencies, toil, incident risk and measurement validity. Excess reliability may indicate an overly loose target or worthwhile headroom. The target guides tradeoffs; it does not replace judgement.

### Question 14: What is the difference between service recovery and operating-model recovery?

**Answer:** Service recovery proves users again receive the required outcome. Operating-model recovery proves the organization can detect, respond, learn and prevent sustainably: pages are actionable, owners can act, recurring work declines, engineering capacity returns, readiness evidence improves and recurrence stays controlled. One can recover before the other.

### Question 15: What would make you reject an SRE role in an interview?

**Answer:** Warning signs include unlimited support scope, no engineering work, no user objectives, no developer production responsibility, unsafe on-call, hero culture, no escalation, automation measured only by ticket count, SRE blamed for every incident, and no authority to improve sources. Ask for service scope, work mix, rotation health, objectives, ownership, recent engineering examples and incident learning. Context matters, but a title cannot compensate for a structurally reactive role.

## Product-company interview

### 1. “Define SRE for a senior engineer.”

**Strong answer:** “SRE is a software-engineering discipline and operating model for service reliability. I start from critical user operations and measurable objectives, use error-budget or risk policy to align product and reliability decisions, connect production response to source owners, keep on-call and operational load sustainable, and invest engineering in eliminating recurring failure and toil. I use readiness, progressive change, observability, incident learning and capacity controls across the lifecycle. I would not call a team SRE merely because it owns Kubernetes, pages or automation.”

**What the interviewer tests:** whether you understand incentives and systems, not only tools.

### 2. “Your team spends 70 percent on toil. What do you do?”

**Strong answer:** “First I validate the denominator, categories, window and individual distribution; 70 percent reported toil may mix incidents, overhead and engineering. I protect critical response and responder safety, then inventory sources by frequency, time, growth, user risk, privilege and owner. I make intake and source ownership explicit, preserve engineering capacity, and select one high-leverage source for elimination or bounded automation. I measure before/after total human work, failures and user outcomes. If durable load still exceeds staffed capacity, I renegotiate service scope or staffing rather than hiding hours.”

**Trap:** promising a universal automation percentage without source evidence.

### 3. “Product wants to launch; readiness has three gaps.”

**Strong answer:** “I frame the exact exposure and classify each gap as required blocker, waivable bounded risk, non-applicable with evidence, or unknown. I provide the smallest closure experiment and limited-launch alternative, with user/capacity/security/data/human gates, abort and rollback. I name the authorized risk owner and record expiry. I do not say ‘SRE says no’; I make the evidence and choices explicit. Some constraints remain non-waivable.”

### 4. “How do error budgets improve collaboration?”

**Strong answer:** “They translate an agreed SLO into a shared amount of tolerable bad outcome, reducing arguments driven only by product velocity versus operational caution. A policy can allow normal change while the budget is healthy and shift investment toward reliability when burn is excessive. It works only if the SLI is valid, product and engineering accept consequences, measurement is trusted, and security/data constraints remain. The budget is not permission to spend user harm deliberately.”

### 5. “Would you automate restarts?”

**Strong answer:** “Not from the word restart alone. I identify the stuck-state owner and why restart helps, check idempotency and side effects, bound retries/concurrency/rate, require reliable detection, audit, manual override, canary, abort and rollback, and verify user plus queue state. I compare that control with fixing the source. If restart can duplicate payment or hide poison messages, blind automation increases risk.”

### 6. “How do you build shared ownership without chaos?”

**Strong answer:** “I map decisions rather than say everyone owns production: product risk and target, good/total semantics, service code, platform contract, change and rollback, capacity, security/data, on-call, incident command and preventive actions. Each has an accountable owner, collaborators, authority, evidence, handoff and escalation. Product teams retain production feedback; SRE and platform provide expertise and controls. We exercise the map in readiness reviews and incidents.”

### 7. “How would you measure SRE success?”

**Strong answer:** “I avoid one score. I connect user SLI/budget and significant incidents with change outcomes, detection/containment/recovery, page actionability and missed events, toil sources and engineering allocation, capacity horizon, accepted-risk closure, preventive-action verification, security/data outcomes and cost per useful operation. I segment and state uncertainty. Ticket closure and uptime alone can reward the wrong behavior.”

### 8. “Is SRE responsible for availability?”

**Strong answer:** “SRE may be accountable for specific production controls and response, but availability emerges from product, service code, platform, dependencies, change, capacity, security and operations. Product owns risk tolerance; developers own code behavior; platform teams own their contract. I make these boundaries explicit. Making SRE solely responsible while other teams control changes creates an incentive and feedback defect.”

### 9. “How do you handle a noisy on-call?”

**Strong answer:** “I treat responder load as an incident when safety or response capacity is threatened. I preserve critical user-symptom coverage, reconcile unique events, pages and actions, bring qualified escalation, and use exact expiring containment only for proven redundant noise. Then I fix alert populations and service sources, measure precision/recall where ground truth exists, pages per incident, acknowledgement/action time and after-hours load, and protect follow-up engineering. Silencing everything is not recovery.”

### 10. “Tell me about a blameless postmortem.”

**Strong answer:** “I build a timeline from evidence, state user impact, contributing technical and organizational conditions, detection and response, what helped, and why decisions were reasonable given information at the time. I avoid stopping at operator error. Actions are specific, risk-ranked, owned, dated and verified against recurrence or a test. Blameless does not mean evidence-free or no accountability; it means the technical learning is not replaced by punishment.”

### 11. “When should an SRE team refuse a service?”

**Strong answer:** “When critical production controls, ownership, staffing, objectives, access, architecture or engineering leverage are insufficient for safe sustainable responsibility, or when higher-value services consume limited capacity. I provide gap evidence and an engagement path: product team retains ownership, close readiness blockers, use platform standards, or take a limited consulting engagement. Refusal should protect users and teams, not become status or gatekeeping.”

### 12. “What is a senior SRE judgement that AI cannot own?”

**Strong answer:** “AI can accelerate queries, code, summaries and hypothesis generation, but accountable humans must define user harm, authorize production changes, accept business/security/data risk, understand organization incentives, judge ambiguous evidence, protect responders, communicate during incidents and own consequences. I use AI as a bounded assistant: inputs are sanitized, outputs are verified, authority is least privilege, actions are reversible and audited. Expertise is knowing what must remain a human decision and proving the system outcome.”

## Independent transfer and rubric

### Unscored transfer rehearsal

This visible scenario is for rehearsal only. It **cannot** satisfy `ASM-0078` because an independent transfer must be unseen.

Scenario:

> A four-person platform team manually approves 100 namespace requests per week. Each takes six minutes. A proposed bot requires 120 build hours and 16 maintenance hours per quarter, saves five minutes per request, and does not yet validate data classification. Product teams have no declared namespace owner after creation. The platform SLO is green, but two customer services missed launches due to queue delay.

Reasoning:

1. Weekly manual time is `100 * 6 / 60 = 10 hours`.
2. The work is a toil candidate: manual, repetitive, automatable, tactical, low enduring value and demand-scaled.
3. The user problem is safe timely namespace availability, not approval clicks.
4. The bot's naive weekly saving is `100 * 5 / 60 = 8.33 hours`; naive build break-even is about `120 / 8.33 = 14.4 weeks`, before maintenance, adoption, failure, security and opportunity cost.
5. Missing data-classification validation is a security/data blocker. Missing post-creation ownership is an operating blocker.
6. First consider eliminating unnecessary approvals through safe defaults and policy-as-code, then self-service with identity, classification, quota, audit, ownership, expiry and cleanup.
7. Canary on low-risk namespaces, abort on policy mismatch or orphaning, retain reviewed manual fallback, and measure end-to-end lead time, failure, orphan rate, human time and product launch outcome.
8. A green platform SLO may not include provisioning lead time, so it does not reject the customer symptom.

Because the answer is visible, reproducing it proves rehearsal, not independent transfer.

### Scored independent transfer

Use `ASM-0078-response-template.md` with a materially different unseen disposable case. After starting:

- do not open complete answers or answered assessments;
- record every hint, search, tool and human help;
- keep real employers, people, tickets, services and notification systems out of scope;
- use raw sanitized evidence;
- distinguish observation, calculation, inference, hypothesis and decision;
- prove exact cleanup;
- submit to a qualified reviewer.

### Rubric

| Criterion | Points | Required evidence |
|---|---:|---|
| Independence, authorization and evidence integrity | 10 | unseen case, help log, safe scope, sanitization and raw evidence |
| User reliability and risk contract | 10 | journey, population, objective, consequence, owner and uncertainty |
| Architecture, ownership and incentives | 10 | decision graph, authority, feedback, handoffs and gaps |
| Work taxonomy and toil reasoning | 10 | contextual multi-property classification and measured population |
| Hypothesis and diagnostic quality | 10 | six ranked falsifiable hypotheses and discriminating checks |
| Risk, capacity and return calculations | 10 | matched units, assumptions, sensitivity, uncertainty and omitted costs |
| Readiness and risk-acceptance decision | 10 | blockers, accepted risks, constraints, owners, expiry and re-review |
| Safe improvement and recovery | 10 | coverage, canary, abort, rollback, fallback, user proof and cleanup |
| Human sustainability and learning | 10 | pager, staffing, training, escalation, fatigue, safety and prevention |
| Communication and proof limits | 10 | clear five-minute response and twelve precise non-claims |

Passing one unseen case does not award mastery. Mastery requires consistent performance, reviewer agreement, changed transfer, delayed recall and authorized evidence updates.

## References and review

The draft stores fifteen official Google SRE reference records:

- `REF-0229`: the software-engineering approach to operations;
- `REF-0230`: SRE and DevOps relationship, culture and incentives;
- `REF-0231`: reliability risk, cost and error-budget alignment;
- `REF-0232`: SLI, SLO and user-expectation foundations;
- `REF-0233` and `REF-0234`: toil definition, measurement and source reduction;
- `REF-0235`: simplicity, modularity, stability and agility;
- `REF-0236`: reliability testing and quantified confidence;
- `REF-0237`: software engineering informed by production experience;
- `REF-0238` and `REF-0239`: production-readiness and lifecycle engagement models;
- `REF-0240`: reliable launch process design;
- `REF-0241`: team interfaces, shared ownership and collaboration;
- `REF-0242`: on-call load, staffing and human sustainability;
- `REF-0243`: incident learning and blameless postmortem culture.

Review before promotion:

- every SRE definition, risk, toil, engagement, readiness, on-call and postmortem claim against the primary sources;
- examples for accidental universalization of Google-specific numbers or organization design;
- formulas, units, denominators, classification heuristic, assumptions and uncertainty;
- commands, root refusal, ownership validation, partial setup, concurrency, symlink/unexpected-entry refusal, cleanup and final absence;
- security and privacy of work measurement, automation identity, audit and organizational evidence;
- accessibility of diagrams, tables, decision paths, terminology and interview answers;
- independent assessment isolation and exact rubric parity;
- Ubuntu 24.04 normal-user lifecycle plus representative service/team case review;
- canonical identities, reciprocal relationships, reader integration, routes, build and browser behavior;
- technical, instructional, SRE, security, accessibility and independent review.

| Review | Purpose |
|---|---|
| Before direct draft validation | schemas, duplicate keys, headings, commands, relationships, answer isolation, rubric parity and references |
| Before any real-team use | authorization, privacy, purpose, access, retention, employment policy, psychological safety and non-blaming measurement |
| Before any real-service change | service scope, identity, privilege, blast radius, user/data/security risk, canary, abort, rollback and authority |
| Before canonical promotion | Ubuntu lifecycle, representative evidence, registries, reader, tests, build, routes, browser and formal review |
| Every six months | source currency, terminology, examples, policies, accessibility and reference review |
| After a relevant incident or organizational change | assumptions, ownership, staffing, failure modes, safeguards and proof limits |

Evidence boundary: this is mentor-authored curriculum. Reading it or running its deterministic model does not prove a team practises SRE, a service is reliable or production-ready, an SLO is valid, risk is accepted, an automation will return value, on-call is sustainable, a learner can transfer the skill, an interview will be passed, or mastery exists.
