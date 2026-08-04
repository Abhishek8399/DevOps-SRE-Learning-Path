---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0033",
  "slug": "incident-command-on-call-recovery",
  "aliases": ["V04-L08", "incident-command-on-call-recovery"],
  "curriculumIds": ["SRE-003"],
  "route": "/book/reliability/incident-command-on-call-recovery",
  "order": 8,
  "volume": "04-reliability-operations",
  "title": "On-call and incident command: stabilize users, coordinate humans, and prove recovery",
  "summary": "Learn the complete incident lifecycle from page to post-incident review: assess user impact, declare early, assign command roles, control concurrent changes, choose reversible mitigations, communicate facts and uncertainty, hand off live state, verify recovery, and turn causal evidence into owned risk reduction.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0007", "LES-0008", "LES-0026", "LES-0031", "LES-0032"],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001", "OBS-001", "SRE-001", "SRE-002"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The guided model uses Bash and Python 3 as a normal user. It creates one UID-scoped temporary directory, opens no port, launches no daemon, sends no notification, and contacts no production, cloud, ticket, chat, identity, or pager system."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The deterministic model is designed for WSL, but Ubuntu availability, user identity, ownership, filesystem behavior, and cleanup must be observed rather than assumed."
    },
    {
      "platform": "Kubernetes, public cloud, private cloud, data platforms, security operations, and production services",
      "version": "concept-only",
      "support": "concept-only",
      "notes": "Transfer examples explain provider and platform boundaries. No real incident was declared, no production change was made, no evidence was collected from an organization, and no communication was sent."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "software-engineer-on-call",
    "observability-engineer",
    "security-engineer",
    "technical-lead",
    "engineering-manager",
    "incident-commander"
  ],
  "learningObjectives": [
    "Distinguish an event, alert, incident, problem, change, emergency, and post-incident review without letting tool names define the operating state.",
    "Triage a page from user impact outward, declare an incident early enough to gain coordination, and revise severity as evidence changes.",
    "Separate incident command, operations, communications, planning, subject-matter expertise, and executive decision authority so responders can work without freelancing.",
    "Build a live incident state document that preserves facts, hypotheses, decisions, actions, owners, timestamps, outcomes, risk, and next checkpoints.",
    "Choose containment, mitigation, rollback, failover, degradation, load shedding, or repair by comparing time-to-relief, reversibility, blast radius, confidence, evidence loss, and security risk.",
    "Control production mutation with one change queue, explicit ownership, preconditions, expected signals, abort criteria, rollback, and recorded results.",
    "Write internal and external updates that state impact, scope, current action, uncertainty, workaround, next update time, and ownership without speculation or false precision.",
    "Perform an acknowledged live handoff that transfers command, current state, recent changes, active risks, open hypotheses, next decisions, access, and communication commitments.",
    "Prove recovery through user journeys, error-budget and telemetry freshness, dependency health, queue drainage, data integrity, change reconciliation, and an observation window.",
    "Create a blameless, causal post-incident review with contributing conditions and specific owned actions that are prioritized, verified, and closed."
  ],
  "productionSignals": [
    "page source, alert rule, firing and delivery time, acknowledgement, escalation target, notification duplication, and missed-page evidence",
    "critical user journey success, latency, correctness, freshness, durability, affected users, regions, tenants, products, and business process",
    "incident identifier, declaration time, current severity, severity history, commander, operations lead, communications lead, planning lead, and role acknowledgements",
    "fact, observation source, query interval, timestamp, timezone, data freshness, hypothesis, confidence, confirming evidence, and rejecting evidence",
    "change identifier, actor, approval boundary, command or mechanism, target, precondition, expected outcome, abort condition, rollback, start, finish, and observed result",
    "traffic, capacity, saturation, queues, retry rate, timeout rate, dependency health, fallback state, feature flag, rollout state, and configuration version",
    "status update audience, channel, author, publication time, impact statement, mitigation state, workaround, uncertainty, and promised next update",
    "handoff sender and receiver, explicit acceptance, transferred roles, open actions, access gaps, active risk, next checkpoint, and broadcast confirmation",
    "mitigation time, user-recovery time, technical-recovery time, validation source, observation duration, regression signal, and residual risk",
    "timeline source, detection gap, response delay, contributing conditions, causal mechanism, counterfactual test, and proof limitation",
    "post-incident action owner, due date, risk reduced, action type, priority, acceptance test, status, verification evidence, and recurrence tracking",
    "responder load, shift duration, interruption count, sleep and fatigue risk, psychological safety, staffing gap, and follow-up support"
  ],
  "diagrams": [
    {
      "id": "LES-0033-DIA-001",
      "title": "Incident response control loop",
      "direction": "cyclic",
      "boundaries": ["detect", "triage", "declare", "command", "stabilize", "verify", "communicate", "learn", "prepare"],
      "evidencePoints": ["page receipt", "user impact", "incident ID", "role acknowledgements", "change log", "recovery probe", "status timestamp", "action closure", "exercise result"],
      "textAlternative": "A signal is detected and triaged against user impact. When coordination is useful, an incident is declared, command roles are assigned, and responders stabilize the service through controlled changes. Recovery is independently verified and communicated. A post-incident review produces risk-reducing actions whose completion improves preparation for the next event."
    },
    {
      "id": "LES-0033-DIA-002",
      "title": "Incident command role tree",
      "direction": "hierarchical",
      "boundaries": ["incident commander", "operations lead", "communications lead", "planning lead", "subject-matter responders", "stakeholders"],
      "evidencePoints": ["decision log", "change queue", "status record", "resource and handoff plan", "bounded findings", "impact and policy decisions"],
      "textAlternative": "The incident commander owns coordination and delegates operations, communications, and planning. Operations owns production changes and technical work. Communications owns consistent updates. Planning tracks resources, future needs, handoffs, and return-to-normal work. Subject-matter responders report through an assigned lead; stakeholders receive facts and make only decisions within their authority."
    },
    {
      "id": "LES-0033-DIA-003",
      "title": "Evidence-to-action ladder",
      "direction": "left-to-right",
      "boundaries": ["observation", "impact", "hypothesis", "discriminating test", "candidate action", "safety review", "controlled change", "result", "next state"],
      "evidencePoints": ["timestamped signal", "journey measure", "prediction", "confirm and reject branches", "time-to-relief", "blast radius and rollback", "single owner", "before and after", "updated incident record"],
      "textAlternative": "A timestamped observation is connected to user impact. Responders form a falsifiable hypothesis and choose a test that separates plausible causes. A candidate action is assessed for relief, risk, reversibility, and evidence loss. One owner executes a controlled change, records the result, and updates shared state before the next action."
    },
    {
      "id": "LES-0033-DIA-004",
      "title": "Stabilize before deep repair",
      "direction": "top-to-bottom",
      "boundaries": ["ongoing user harm", "contain spread", "reduce demand or bypass defect", "restore critical journey", "hold observation window", "repair cause", "reconcile temporary state"],
      "evidencePoints": ["impact trend", "blast-radius boundary", "fallback signal", "synthetic and real journey", "regression and queue trend", "causal test", "configuration and data audit"],
      "textAlternative": "When harm is active, first contain spread and choose a reversible way to reduce demand, bypass a failing component, roll back, fail over, or degrade safely. Prove the critical journey recovered and observe it. Only then perform deeper repair, and later reconcile every temporary flag, route, capacity increase, credential, or manual workaround."
    },
    {
      "id": "LES-0033-DIA-005",
      "title": "Communication fan-out without command fan-in",
      "direction": "hierarchical",
      "boundaries": ["single incident state", "internal responder update", "support and business update", "customer status", "executive or regulator path"],
      "evidencePoints": ["canonical fact set", "technical detail", "workaround and scope", "plain-language impact", "authorized material decisions"],
      "textAlternative": "One canonical incident state feeds audience-specific updates. Responders receive technical facts and assignments. Support and business teams receive scope and workarounds. Customers receive plain-language impact and next-update commitments. Executives or regulators receive authorized material facts. Replies return through the communications lead instead of interrupting operators."
    },
    {
      "id": "LES-0033-DIA-006",
      "title": "Incident-to-learning pipeline",
      "direction": "left-to-right",
      "boundaries": ["raw timeline", "verified timeline", "impact analysis", "causal graph", "contributing conditions", "actions", "acceptance tests", "operational review"],
      "evidencePoints": ["logs and records", "source reconciliation", "user and business measures", "mechanism links", "defense gaps", "owner and due date", "risk-reduction proof", "recurrence and closure trend"],
      "textAlternative": "Raw clocks and records are reconciled into a verified timeline. User and business impact are quantified. A causal graph explains how conditions and defenses combined, without reducing the incident to one person. Actions name owners and acceptance tests. Operational review tracks closure and whether the same failure mode becomes less likely or less harmful."
    }
  ],
  "commands": [
    {
      "id": "LES-0033-CMD-001",
      "question": "Which identity, kernel, Ubuntu release, Python version, UTC time, and directory define this exercise?",
      "risk": "read-only",
      "command": "id; uname -a; cat /etc/os-release; python3 --version; date -u +%Y-%m-%dT%H:%M:%SZ; pwd",
      "runFrom": "a normal Ubuntu shell before entering the guided lab",
      "expectedBranches": [
        {"when": "UID is non-root and the environment matches the declared scope", "meaning": "the local evidence context is recorded", "nextEvidence": "validate the scenario and run lab doctor"},
        {"when": "UID is zero, a dependency is absent, time is implausible, or the path is unexpected", "meaning": "the exercise boundary is unsafe or incomplete", "nextEvidence": "stop and correct or record the mismatch"}
      ],
      "proves": "only local caller and environment identity reported at that instant",
      "doesNotProve": "incident authority, synchronized production clocks, provider equivalence, or operational competence"
    },
    {
      "id": "LES-0033-CMD-002",
      "question": "Does the fictional incident satisfy the exact checked-in scenario contract?",
      "risk": "read-only",
      "command": "python3 fixtures/incident_model.py validate-scenario fixtures/scenario.json",
      "runFrom": "the LES-0033 support/lab directory",
      "expectedBranches": [
        {"when": "scenario_valid=true appears", "meaning": "identity, keys, types, timestamps, roles, actions, and outcome relationships satisfy the model", "nextEvidence": "run doctor and setup"},
        {"when": "refused=true or an error appears", "meaning": "the fixture or model contract is broken", "nextEvidence": "preserve the first error and create no state"}
      ],
      "proves": "only fixture conformance to the deterministic validator",
      "doesNotProve": "that severity, mitigation, communication, timeline, or causal claims fit a real incident"
    },
    {
      "id": "LES-0033-CMD-003",
      "question": "Can the lab create its exact private normal-user state without touching a real incident system?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "the LES-0033 support/lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "state=ready appears", "meaning": "the UID-scoped descriptor validates", "nextEvidence": "inspect status and run one case"},
        {"when": "refused=true appears", "meaning": "root, tool, path, owner, symlink, fixture, or state identity is unsafe", "nextEvidence": "preserve ambiguous state and inspect the refusal"}
      ],
      "proves": "bounded local state creation or validation",
      "doesNotProve": "real paging, incident declaration, notification delivery, safe production access, or mastery",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-004",
      "question": "What exact lab state and result count exist?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the LES-0033 support/lab directory",
      "expectedBranches": [
        {"when": "state=absent appears", "meaning": "the expected state root is absent", "nextEvidence": "run setup only if practice is intended"},
        {"when": "state=ready appears", "meaning": "sentinel, manifest, scenario, children, types, and ownership validate", "nextEvidence": "compare result count with deliberately run cases"},
        {"when": "refused=true appears", "meaning": "state is ambiguous", "nextEvidence": "do not delete broadly; preserve and review"}
      ],
      "proves": "only encoded state validity and allowed result-file count",
      "doesNotProve": "semantic correctness, cleanup, independent work, or mastery"
    },
    {
      "id": "LES-0033-CMD-005",
      "question": "Should the fictional event be declared, and what severity is justified now?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run triage",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "declare=true and severity=SEV-1 appear", "meaning": "the fixture has confirmed critical user harm across two regions with multi-team response", "nextEvidence": "assign acknowledged roles and open shared state"},
        {"when": "another result appears", "meaning": "impact or policy input changed", "nextEvidence": "re-evaluate from declared severity criteria rather than copying a label"}
      ],
      "proves": "the model's decision from declared fictional criteria",
      "doesNotProve": "that any real organization should use the same scale or declaration threshold",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-006",
      "question": "Are command, operations, communications, and planning roles explicit and acknowledged?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run roles",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "coverage=complete and conflicts=0 appear", "meaning": "every required responsibility has one acknowledged owner", "nextEvidence": "route technical actions through operations and decisions through command"},
        {"when": "coverage=incomplete or conflicts are nonzero", "meaning": "ownership is missing or duplicated", "nextEvidence": "the commander resolves the role map before parallel work expands"}
      ],
      "proves": "only role coverage in the fixture",
      "doesNotProve": "skill, access, fatigue safety, or effective human coordination",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-007",
      "question": "Which mitigation best reduces current user harm under the fixture's safety constraints?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run mitigation",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "selected=disable-promotion-enrichment and rejected risky alternatives appear", "meaning": "a reversible degraded path has the best time-to-relief and blast-radius profile", "nextEvidence": "record owner, precondition, abort, rollback, and before/after journey signals"},
        {"when": "a different action wins", "meaning": "risk, reversibility, evidence, or user-impact inputs changed", "nextEvidence": "review the full decision matrix instead of applying a memorized response"}
      ],
      "proves": "deterministic ranking under declared fictional weights",
      "doesNotProve": "production safety, authorization, causal correctness, or universal preference for feature disablement",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-008",
      "question": "Did the controlled mitigation restore the critical user journey without hiding a new failure?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run recovery",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "userRecovered=true, queuesDraining=true, dataIntegrity=verified, and observeMinutes=30 appear", "meaning": "the fixture meets its declared recovery gate", "nextEvidence": "continue observation, communicate status, and reconcile temporary state"},
        {"when": "any gate is false", "meaning": "mitigation is not yet proven", "nextEvidence": "keep the incident active and investigate the failed dimension"}
      ],
      "proves": "the model's recovery predicate over declared samples",
      "doesNotProve": "real recovery, every cohort, long-term stability, or root-cause repair",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-009",
      "question": "Is the internal status update factual, useful, and explicit about uncertainty and its next checkpoint?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run communication",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "requiredFields=complete and speculativeClaims=0 appear", "meaning": "impact, scope, action, uncertainty, workaround, owner, and next update are present", "nextEvidence": "adapt only approved facts for each audience"},
        {"when": "a field is missing or speculation is found", "meaning": "the update can mislead or create interruptions", "nextEvidence": "repair the canonical state before publication"}
      ],
      "proves": "fixture message conformance to the teaching contract",
      "doesNotProve": "delivery, accessibility, legal approval, customer suitability, or truth outside the fixture",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-010",
      "question": "Can command transfer without losing active risk or decision state?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run handoff",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "accepted=true, gaps=0, and broadcast=true appear", "meaning": "sender, receiver, live briefing, explicit acceptance, and team notification are represented", "nextEvidence": "outgoing commander remains until receipt is confirmed"},
        {"when": "acceptance or a required field is absent", "meaning": "command ownership is ambiguous", "nextEvidence": "repeat the live handoff and resolve the gap"}
      ],
      "proves": "handoff completeness in the fixture",
      "doesNotProve": "the receiver understood the system, has access, or is rested enough to lead",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-011",
      "question": "Does the post-incident review explain mechanisms and produce testable risk-reducing actions?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run review",
      "runFrom": "a validated ready LES-0033 lab state",
      "expectedBranches": [
        {"when": "blameTerms=0, causalLinks=5, and actionableItems=4 appear", "meaning": "the fixture separates trigger, conditions, defense gaps, impact path, and owned actions", "nextEvidence": "prioritize and verify action closure in operational review"},
        {"when": "one root cause, human blame, or vague actions dominate", "meaning": "the review will not reliably reduce recurrence", "nextEvidence": "rebuild the causal graph and action acceptance tests"}
      ],
      "proves": "conformance of one fictional review to encoded checks",
      "doesNotProve": "organizational learning, psychological safety, action completion, or reduced recurrence",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0033-CMD-012",
      "question": "Did the complete guarded exercise pass and leave no state?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "the LES-0033 support/lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "verification=passed and final_state=absent appear with expected counts", "meaning": "the checked-in lifecycle and semantic assertions passed on this environment", "nextEvidence": "preserve the result with environment evidence and state its limits"},
        {"when": "a command exits nonzero or cleanup is refused", "meaning": "the first failure is evidence", "nextEvidence": "stop, inspect status, and never broadly remove ambiguous state"}
      ],
      "proves": "only guarded model behavior and exact cleanup for this run",
      "doesNotProve": "production incident competence, communication delivery, independent transfer, retention, or mastery",
      "cleanup": "the verifier uses a guarded exit trap and proves the lesson state absent"
    }
  ],
  "labs": [
    {
      "id": "LES-0033-LAB-001",
      "title": "Guided incident-command and recovery model",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS normal user with Bash and Python 3; no Docker, network, ports, sudo, package installation, provider, ticket, chat, email, notification, pager, organization, or production system",
      "timeMinutes": 180,
      "privilege": "normal user; wrapper and verifier refuse UID 0",
      "network": "none; fixture, decisions, state, and output remain local",
      "changes": ["one lesson-specific private temporary directory", "owned fixture and manifest copies", "at most seven bounded JSON result files"],
      "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "a child is a symlink or unexpected type", "fixture contract is invalid", "semantic assertions differ", "cleanup cannot validate exact ownership", "model output is proposed as authority for a real incident"],
      "recovery": "Run status. If the descriptor validates, run cleanup and repeat setup. Preserve refused foreign or ambiguous state instead of deleting broadly.",
      "cleanupProof": "Cleanup validates exact parent, basename, real path, UID, sentinel, manifest, scenario, allowed children, types, and owners; removes only that directory; then proves exact absence.",
      "path": "drafts/LES-0033-incident-command-on-call-recovery/support/lab"
    },
    {
      "id": "LES-0033-LAB-002",
      "title": "Independent timed incident-leadership simulation",
      "mode": "independent",
      "environment": "A held-back, materially different, disposable local scenario with changed impact, misleading telemetry, competing mitigations, role conflict, communication pressure, shift handoff, recovery ambiguity, and causal evidence; the guided fixture cannot satisfy independence",
      "timeMinutes": 210,
      "privilege": "normal user; no elevated, organizational, communications, contractual, notification, or production authority",
      "network": "none unless a separately reviewed unseen harness declares loopback; employer, cloud, shared, ticket, chat, email, pager, identity, and production systems are prohibited",
      "changes": ["one sanitized learner response outside guarded state", "only resources declared by the unseen disposable case"],
      "abortConditions": ["answered material is visible", "authorization or sanitization is unclear", "real data or systems could be contacted", "a change lacks owner, abort, rollback, or evidence plan", "handoff is unacknowledged", "cleanup cannot be proven"],
      "recovery": "Return to the last verified baseline, narrow the decision, and submit a revised incident record. Do not reveal the answer key before qualified review.",
      "cleanupProof": "Use the unseen case manifest to prove every created process, port, file, container, namespace, queue, and resource absent. Guided cleanup does not cover the independent case.",
      "path": "drafts/LES-0033-incident-command-on-call-recovery/support/lab"
    }
  ],
  "incidents": [
    {
      "id": "LES-0033-INC-001",
      "signal": "Checkout failures rise rapidly in two regions while responders independently roll back, scale, restart, and change routing.",
      "firstThought": "The technical fault is now joined by a coordination hazard. Declare, assign command, pause freelancing, and serialize production changes.",
      "safePath": "Measure user impact, establish one incident record and change queue, assign acknowledged roles, choose the most reversible high-relief mitigation, and verify every result before the next action.",
      "trap": "More hands making uncoordinated changes increase ambiguity, blast radius, and time to recovery even when every individual intends to help."
    },
    {
      "id": "LES-0033-INC-002",
      "signal": "A senior leader asks for root cause and an exact recovery time twelve minutes into a still-growing outage.",
      "firstThought": "They need decision-useful truth, not confident fiction. Separate known impact, current mitigation, uncertainty, and the next update commitment.",
      "safePath": "Route the request through communications, publish facts with timestamps and source, state hypotheses as hypotheses, give a decision or checkpoint time instead of an invented restoration estimate, and protect operators from repeated inquiries.",
      "trap": "Guessing an ETA creates a second incident when reality differs; refusing all communication makes stakeholders create their own narrative."
    },
    {
      "id": "LES-0033-INC-003",
      "signal": "Error rate returns to baseline immediately after a rollback, but the work queue grows and reconciliation lag continues rising.",
      "firstThought": "The front door may have recovered while deferred work and data correctness remain unhealthy. Do not close on one green graph.",
      "safePath": "Verify critical journeys, cohort impact, queue age and drain rate, data integrity, dependency state, telemetry freshness, and a declared observation window; keep residual work owned after user recovery.",
      "trap": "Equating alert reset with recovery hides backlog, corruption, and delayed failure that can trigger a second incident."
    },
    {
      "id": "LES-0033-INC-004",
      "signal": "The current incident commander has worked fourteen hours and sends a long text handoff without a receiving acknowledgement.",
      "firstThought": "Fatigue and ambiguous command are active reliability risks. A document is input to a handoff, not the handoff itself.",
      "safePath": "Find a rested and authorized receiver, conduct a live briefing against the incident state, test access and understanding, obtain explicit acceptance, broadcast the new role map, and keep the outgoing commander until receipt is confirmed.",
      "trap": "Quietly leaving after posting notes creates a period in which everyone assumes somebody else owns the incident."
    },
    {
      "id": "LES-0033-INC-005",
      "signal": "The draft post-incident review says an engineer caused the outage by running the wrong command and assigns training as the only action.",
      "firstThought": "A human action is part of the timeline, not a sufficient causal explanation. Ask why one predictable action could create and sustain broad harm.",
      "safePath": "Trace authorization, interface design, review controls, test coverage, blast-radius limits, observability, rollback, staffing, and incentives; create actions that reduce likelihood, impact, detection delay, and recovery time with named acceptance tests.",
      "trap": "Blame suppresses evidence and leaves the same system conditions waiting for a different person."
    }
  ],
  "assessmentIds": ["ASM-0082", "ASM-0083", "ASM-0084"],
  "referenceIds": ["REF-0259", "REF-0260", "REF-0261", "REF-0262", "REF-0263", "REF-0264", "REF-0265", "REF-0266", "REF-0267", "REF-0268", "REF-0269", "REF-0270", "REF-0271", "REF-0272", "REF-0273"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "The guided incident, people, services, telemetry, decisions, communications, and outcomes are fictional teaching data.",
    "No real page, declaration, ticket, chat room, email, status page, provider, production change, forensic collection, legal decision, or customer communication was executed.",
    "Severity labels and role names vary by organization; the lesson teaches invariants and requires local policy mapping.",
    "The deterministic model cannot reproduce human stress, incomplete access, organizational power, fatigue, ambiguity, adversarial behavior, or distributed-system dynamics.",
    "Security, privacy, safety, fraud, regulated, data-loss, and physical incidents require specialized authorities and evidence-preservation procedures beyond this availability-focused fixture.",
    "Reading or passing automated checks does not establish independent incident leadership, safe production judgment, retention, or mastery."
  ]
}
---

# On-call and incident command: stabilize users, coordinate humans, and prove recovery

## What you see and first thought

Your phone wakes you at 02:13. The message says:

```text
SEV? checkout_success below objective
region=west error_rate=18%
queue_age=11m and rising
deployment=checkout-api 7.42 completed 9m ago
```

The beginner's mind often jumps to, "I need the command that fixes checkout." The mature on-call mind says something different:

> Users may be losing money or time. I need to establish impact, gain control of the response, and choose the safest fast way to stop the harm.

That sentence contains the whole chapter. An incident is never only a broken component. It is a changing technical system, a changing human system, and a stream of incomplete evidence. If ten talented engineers make ten uncoordinated changes, the response itself becomes another failure mode.

Use this first-minute sequence:

```text
Am I safe and able to respond?
  -> Did I receive and acknowledge the page?
  -> What user journey is harmed right now?
  -> How large and fast-growing is the blast radius?
  -> Do I need incident structure now?
  -> What action can reduce harm fastest with the least irreversible risk?
```

Do not begin with root cause. Root cause is a learning goal. During active harm, your immediate goal is **safe restoration**. You may mitigate a queue collapse by disabling optional enrichment long before proving whether the trigger was a deployment, dependency slowdown, retry storm, or capacity loss.

Three clocks matter:

| Clock | Begins | Ends | Why it matters |
|---|---|---|---|
| User-harm clock | The first user is affected | The last relevant user is no longer affected | This is the outcome the organization exists to reduce. |
| Response clock | Detection or page delivery | A qualified responder acts | This reveals detection, routing, and readiness delay. |
| Learning clock | The incident creates evidence | Risk-reducing actions are verified closed | An unwritten review or unclosed action has not completed learning. |

The alert timestamp is not automatically the incident start. The time a dashboard turns green is not automatically user recovery. The time a ticket closes is not automatically learning. State each clock and its evidence.

## Terms before commands

**Event** means something observable happened: a deployment completed, a node disappeared, a latency threshold crossed, or a certificate approached expiry. An event is not automatically harmful.

**Alert** is a rule-selected signal intended to trigger attention or action. A page is one delivery mechanism for an urgent alert. A page can be false, duplicated, delayed, misrouted, or correct but unactionable.

**Incident** is an unplanned interruption, degradation, integrity risk, security condition, or credible threat that requires coordinated response. Your organization owns the exact definition. Tool creation does not make an event an incident; the declared operating process does.

**Problem** is the underlying or recurring condition investigated to prevent future incidents. Incident management restores acceptable service. Problem management reduces recurrence. They overlap but have different urgency.

**Change** is an intentional modification to system state. A deployment may trigger an incident; a rollback is another change used to mitigate it. Every emergency change still needs an owner, scope, evidence expectation, abort condition, and recovery path.

**Emergency** is a condition whose urgency or consequence requires extraordinary coordination or authority. Availability incidents, cybersecurity incidents, safety incidents, data-loss incidents, fraud events, and legal-reporting events can share coordination ideas but must not share authority blindly.

**On-call** is a scheduled responsibility to receive, assess, and coordinate response outside ordinary work flow. It is not an agreement to operate alone, without sleep, without escalation, or without training.

**Acknowledgement** means a responder explicitly accepted the notification. It proves receipt under the tool's semantics, not that the responder has understood the incident or is capable of resolving it.

**Escalation** transfers or expands attention because time, impact, skill, authority, or capacity thresholds were crossed. Escalation is a designed reliability mechanism, not personal failure.

**Triage** is the first bounded assessment: is this real, who is affected, how urgent is it, what is the trend, and what response structure is needed? Triage deliberately avoids an endless investigation.

**Severity** is a policy label that maps impact and urgency to response expectations. `SEV-1`, `P1`, and `Critical` have no universal meaning. A useful severity definition names user/business impact, response time, roles, communication frequency, and authority.

**Blast radius** is the affected scope: users, requests, regions, tenants, products, data, dependencies, or business processes. A percentage without the population can hide a small or catastrophic radius.

**Incident commander (IC)** owns coordination: current objective, role assignment, priorities, decision flow, and shared state. The commander does not need to be the deepest technical expert and should not become the busiest debugger.

**Operations lead** owns technical execution. Subject-matter responders work through this lead. Only the controlled operations path changes production during the incident.

**Communications lead** turns the canonical incident state into updates for responders, support, customers, leadership, or other authorized audiences. This role protects operators from repeated interruptions and prevents conflicting narratives.

**Planning lead** looks beyond the current command cycle: staffing, handoff, pending decisions, resource needs, temporary-state reconciliation, and follow-up work.

**Subject-matter expert (SME)** has deep knowledge of a relevant component. Expertise earns a work assignment and a voice; it does not bypass command or change control.

**Command post** is the recognized place where incident state and coordination live. It may be a room, channel, bridge, document, or resilient combination. It must not depend solely on the failing service.

**Live incident state document** is the canonical working record. It contains current impact, severity, roles, timeline, facts, hypotheses, decisions, change log, communications, risks, and next checkpoints. It is allowed to be imperfect; it is not allowed to be invisible or ownerless.

**Fact** is a claim supported by named evidence. **Hypothesis** is a falsifiable explanation that predicts what evidence should appear. **Assumption** is something temporarily treated as true. Label all three.

**Containment** limits spread. **Mitigation** reduces impact. **Repair** changes the defect or causal mechanism. **Recovery** is the demonstrated return of the required user outcome. One action may serve several purposes, but the words should not be treated as synonyms.

**Rollback** returns a known change toward a prior state. It is not inherently safe: schemas, migrations, caches, feature flags, irreversible writes, and dependency versions may make backward movement dangerous.

**Failover** moves work to another capacity or failure domain. It can overload the destination, copy corrupted state, exceed quotas, or fail because both sides share a dependency.

**Graceful degradation** preserves critical operations while removing optional quality or features. A checkout without recommendations may be acceptable; a successful response that charges twice is not.

**Load shedding** deliberately rejects or defers some work to protect the system's critical path. It requires priority, fairness, retry, and user-communication rules.

**Recovery point** is the time at which declared recovery criteria first hold. **Observation window** is the period they must continue holding before closure or downgrade. Different failure modes need different windows.

**Runbook** is a reviewed procedure for a known operational task, such as rotating a certificate or rolling back a release. **Playbook** guides investigation and decisions through branches when the exact cause is not known. Organizations sometimes swap these terms; record the local convention.

**Handoff** is an acknowledged transfer of responsibility and live state. Posting notes is not a handoff until the receiver accepts.

**Post-incident review (PIR)** or **postmortem** is a structured analysis of impact, timeline, mechanisms, contributing conditions, response, and improvements. "Blameless" means searching for system conditions rather than punishment; it does not mean removing accountability or avoiding precise facts.

**Root cause** often sounds like one final answer. Complex incidents usually have a trigger, latent conditions, missing defenses, propagation mechanisms, detection delays, and recovery constraints. Prefer a **causal graph** over a single-person story.

**Action item** is not "improve monitoring." It names an owner, risk, specific change, due date, priority, acceptance test, and evidence of closure.

**MTTA**, **MTTM**, and **MTTR** are overloaded abbreviations. Teams variously mean time to acknowledge, mitigate, recover, repair, or resolve. Never publish the letters without defining start event, end event, population, percentile, exclusions, and clock source.

## Architecture map

Think of incident response as a control plane for people operating a damaged data plane:

```text
                            AUTHORIZED STAKEHOLDERS
                     risk / business / security / legal
                                  ^
                                  | decisions and facts
                                  |
PAGE -> ON-CALL -> INCIDENT COMMANDER -> COMMUNICATIONS LEAD -> audiences
                    |        |
                    |        +-> PLANNING LEAD -> staff / handoff / follow-up
                    v
              OPERATIONS LEAD
                /    |     \
              app  platform  dependency SMEs
                \    |     /
                 controlled change queue
                          |
                          v
 user -> edge -> service -> queue -> dependency -> durable state
   ^          damaged production/data plane             |
   +---- independent user-journey recovery evidence -----+
```

The top half coordinates authority and information. The bottom half serves users. The incident record connects them.

Every boundary needs evidence:

| Boundary | Ask | Minimum evidence |
|---|---|---|
| Alert to on-call | Did the intended human receive it? | Fire time, delivery, acknowledgement, escalation. |
| On-call to command | Did one person accept coordination? | Incident ID, declaration time, named IC, acknowledgement. |
| Command to operations | Who may change what next? | Assigned owner, serialized action, preconditions, abort and rollback. |
| Operations to system | Did the action execute and change the expected signal? | Audit/change record, result, before/after evidence. |
| System to user | Did the user operation recover? | Independent journey, cohort and correctness evidence. |
| Command to communications | What is safe and useful to say? | Canonical facts, uncertainty, audience approval, next update. |
| Incident to learning | Did evidence become reduced risk? | Reviewed PIR, owned action, acceptance result, recurrence trend. |

The incident commander is analogous to a scheduler. They do not execute every instruction. They allocate scarce attention, prevent conflicting operations, maintain priorities, and decide when the system has enough evidence to transition state.

## Request or state path

Follow a page through its full lifecycle:

```text
signal observed
  -> alert rule evaluated
  -> notification routed
  -> on-call acknowledges
  -> triage validates impact
  -> incident declared and severity assigned
  -> roles acknowledge
  -> incident state and change queue opened
  -> hypotheses and mitigations compared
  -> one controlled action executes
  -> user and system evidence evaluated
  -> action repeats, rolls back, or advances
  -> mitigation and recovery communicated
  -> observation window passes
  -> temporary changes reconciled
  -> incident closes or downgrades
  -> PIR and actions reviewed
  -> action effectiveness verified
```

At each transition, name the owner and evidence. "We scaled" is incomplete. A usable change record says:

```text
02:24:10Z ACTION A-07
owner: operations-lead
target: checkout-worker deployment in west
change: raise replicas from 30 to 45 through reviewed deployment control
hypothesis: queue age is rising because healthy worker throughput is below arrival rate
preconditions: destination quota available; database connections below safe threshold
expected: completion rate rises within 5m; DB saturation remains below 70%
abort: DB connection use > 80%, error rate rises 2 points, or rollout unavailable > 2m
rollback: restore replica count 30
result: NOT STARTED
```

This record makes concurrency visible. If a second responder wants to restart the database while A-07 is active, the operations lead can ask whether the two results would remain interpretable.

Severity is state, not identity. Begin with the best evidence and revise:

```text
02:14 declared SEV-2: one region, degraded checkout, workaround available
02:18 raised SEV-1: second region, payment completion affected, no safe workaround
02:46 lowered SEV-2: critical journey recovered, queue drain and reconciliation active
03:20 resolved: recovery criteria held for 30m; residual work transferred
```

Never rewrite history to make the final severity look inevitable. The transitions reveal how impact evolved and whether policy thresholds worked.

## Failure zoom

### Failure 1: freelancing

Five responders see the same alert. One rolls back, one restarts, one changes a timeout, one scales, and one fails traffic over. No action is malicious. Together they erase causality and can compound the outage.

**On-call wisdom:** when parallel work begins, do not just ask for more help. Ask for structure. Declare, assign roles, and put every production mutation in one visible queue.

### Failure 2: root-cause tunnel vision

An engineer spends forty minutes proving a rare runtime bug while users continue failing. A five-minute feature disable could have restored the critical path.

**On-call wisdom:** ask two questions separately: "How do we reduce harm now?" and "What mechanism created the harm?" The first can proceed without completing the second.

### Failure 3: dangerous rollback

A deployment wrote data in a new schema. Rolling the binary back makes old code misread new rows.

**On-call wisdom:** rollback is a candidate change, not a magic undo button. Check compatibility, migrations, irreversible side effects, caches, flags, and dependency contracts.

### Failure 4: false recovery

The page clears because traffic was routed away. The receiving region reaches 92% capacity, queues grow, and one tenant remains broken because its state never replicated.

**On-call wisdom:** prove the user journey and the destination's headroom. Alert reset proves only that the alert expression stopped firing.

### Failure 5: communication overload

Operators answer the same "What happened?" question in six channels. Messages disagree, and the actual mitigation slows.

**On-call wisdom:** one canonical state, one communications owner, audience-specific outputs, and a promised next update protect both truth and operator attention.

### Failure 6: weak handoff

The outgoing lead posts a summary and logs off. The receiver did not know a temporary firewall exception expires in twenty minutes.

**On-call wisdom:** conduct a live, acknowledged handoff. Ask the receiver to restate current impact, next action, biggest risk, and next communication deadline.

### Failure 7: closing on green

Success rate recovers, but the retry queue contains two million operations and duplicate processing is possible.

**On-call wisdom:** closure is a policy decision supported by multidimensional recovery evidence: users, correctness, backlog, dependencies, telemetry, capacity, and time.

### Failure 8: blame as causality

The review says, "The deployer ignored the warning." It never asks why one warning could be ignored, why the deployment reached all regions, why rollback failed, or why detection came from customers.

**On-call wisdom:** personal action may be relevant evidence, but durable prevention comes from mechanisms and defenses.

## Internals and state ownership

### Declare early, downgrade cheaply

Incident structure has overhead. Missing it during a growing outage costs more. Useful declaration triggers include confirmed customer impact, a second team required, uncertain but potentially severe blast radius, time beyond a triage threshold, security or data-integrity concern, or concurrent production changes.

Declaration does not mean catastrophe. It means: "This deserves explicit coordination and a durable record." A small incident can be closed quickly with the same discipline.

### Severity from impact, not component importance

A failed primary database with no user impact because failover worked may be a serious risk but not the highest active impact. A tiny function that blocks all payments may be critical. Build severity from:

- users or business processes affected;
- degree of loss: unavailable, slow, wrong, stale, duplicated, or insecure;
- geographic and tenant scope;
- duration and growth rate;
- workaround quality;
- data, security, safety, legal, or financial consequence;
- time sensitivity and recoverability.

Severity must drive specific behavior. If `SEV-1` and `SEV-2` lead to the same roles, update cadence, escalation, and authority, the distinction is decorative.

### Role separation is a scaling primitive

Small incidents may begin with one person holding every undelegated role. As cognitive load rises, delegate in this order:

1. command away from the deepest operator;
2. communications away from command;
3. planning when duration, staffing, or handoff grows;
4. bounded technical workstreams under operations.

One person can wear two hats only while the load remains safe and everyone knows which hat owns each decision.

### The live state record

Put the most important current state at the top:

```text
INC-2026-017 | SEV-1 | ACTIVE
Impact: 18% checkout completion failure in west and central since 02:05Z.
Current objective: restore correct checkout completion while preventing duplicates.
IC: role-ic-1 (ack 02:17Z)
Ops: role-ops-1 | Comms: role-comms-1 | Planning: role-plan-1
Mitigation: optional promotion enrichment disabled in west; central canary pending.
User status: west recovered in 3/3 five-minute windows; central still 11% failure.
Largest risk: retry queue may duplicate operations if drained before idempotency check.
Next decision: central canary at 02:31Z.
Next update: 02:35Z.
```

Below it, keep append-only or auditable sections:

- impact and severity history;
- roles and acknowledgements;
- timeline with source and confidence;
- facts, hypotheses, and assumptions;
- decision log;
- change queue and result log;
- communications history;
- open risks and blockers;
- handoff state;
- recovery criteria;
- temporary-state reconciliation list.

### One change queue

Concurrent investigation is healthy. Concurrent mutation is dangerous when results interact. The operations lead can run multiple changes only when targets, risks, and evidence are independent and explicitly coordinated.

Every candidate change answers:

1. Which user harm should this reduce?
2. What hypothesis or operational mechanism supports it?
3. Who owns execution?
4. What exact boundary changes?
5. What must be true before starting?
6. What signal should move, by how much, and when?
7. What signal causes abort?
8. How is rollback or forward recovery performed?
9. What evidence could the change destroy?
10. Who authorizes it under emergency policy?

### Mitigation decision matrix

Score candidates explicitly, but do not let arithmetic replace judgment:

| Candidate | Time to user relief | Reversible | Blast radius | Confidence | Evidence preserved | New risk |
|---|---:|---:|---:|---:|---:|---|
| Disable optional enrichment | 3 min | High | One service path | High | High | Reduced feature quality |
| Roll back binary | 8 min | Medium | Two regions | Medium | Medium | Schema compatibility unknown |
| Fail over all traffic | 6 min | Medium | Global destination | Low | Medium | Destination saturation |
| Restart database | 12 min | Low | Shared state | Low | Low | Availability and recovery risk |
| Add workers | 5 min | High | Worker pool | Medium | High | DB connections and cost |

Select the action that best reduces current harm under constraints, not the one that feels most technically complete.

### Communications as an operational control

A strong update has a stable structure:

```text
02:25Z | ACTIVE | next update 02:35Z
Impact: Some checkout attempts in west and central fail before order confirmation.
Scope: 18% failure in west; 11% in central; other regions not currently observed affected.
Action: Optional promotion enrichment is disabled in west and is being canaried in central.
Result: West completed three healthy five-minute windows; central remains degraded.
Uncertainty: Trigger is not yet confirmed. Retry-queue duplicate risk is under review.
Workaround: Customers may retry once after waiting; support should not request repeated retries.
Owner: Incident command through the approved incident channel.
```

Notice what is absent: blame, an invented root cause, an exact restoration promise, secret infrastructure detail, and a claim about every user.

### Handoff protocol

Use **STATE**:

- **S — Scope and severity:** affected journeys, cohorts, timeline, trend.
- **T — Team and tasks:** roles, active owners, open actions, communication deadline.
- **A — Actions and aftermath:** recent changes, results, temporary state, rollback paths.
- **T — Threats and theories:** largest risks, hypotheses, rejected explanations, access gaps.
- **E — Explicit acceptance:** receiver restates priorities and says they accept; transfer is broadcast.

Fatigue is operational evidence. Long shifts reduce working memory and judgment. A sustainable system has maximum shift guidance, secondary coverage, escalation, recovery time, and a culture in which asking for relief is expected.

### Recovery and closure

Define recovery before you need it. For the fictional checkout incident:

- three independent five-minute windows meet user-journey SLO thresholds;
- correctness probes show no duplicate order or payment;
- retry queue age and depth decline at a safe, predicted rate;
- dependencies remain within capacity and error thresholds;
- telemetry coverage and freshness are valid;
- affected regions and important cohorts recover;
- no rollback or failover regression occurs for thirty minutes;
- temporary changes are recorded with owners and expiry;
- support and communications confirm no contradictory ongoing impact.

"Resolved" may mean user harm ended while permanent repair remains. State the local meaning and retain ownership of residual risk.

### Post-incident causal analysis

Build a graph:

```text
new promotion call became synchronous
  + timeout exceeded checkout worker budget
  + retry policy multiplied work
  + queue capacity had no tenant isolation
  + canary excluded high-promotion traffic
  + alert measured server responses, not completed orders
  -> worker saturation
  -> rising queue age
  -> checkout timeouts
  -> repeated customer retries
  -> duplicate-risk recovery constraint
```

There is a trigger, but no single human "root" explains the blast radius, detection gap, or slow recovery.

Action types should cover different control points:

- prevent: make enrichment asynchronous or bounded;
- contain: isolate queue capacity and retry budgets;
- detect: measure completed order journeys and telemetry coverage;
- mitigate: provide a tested one-step feature bypass;
- recover: test idempotent queue replay;
- coordinate: automate the incident-state template and role acknowledgement;
- learn: verify action closure and exercise the failure mode.

## Evidence table

| Question | Command or record | Risk | Expected branches | Proves | Does not prove | Safest next evidence |
|---|---|---|---|---|---|---|
| What environment am I in? | `id; uname -a; cat /etc/os-release; date -u` | Read-only | Expected normal user or mismatch | Local context | Production parity | Record tool versions and path. |
| Is the page real? | Alert state plus independent journey | Read-only | User harm confirmed, disproved, or unknown | Current sampled evidence | Cause or full population | Expand cohort and time boundaries. |
| Should we declare? | Severity policy plus impact facts | Read-only decision | Declare, monitor, or specialist escalation | Policy mapping | Universal severity | Record decision and reassessment time. |
| Who owns command? | Role acknowledgements | Organizational record | Complete, gap, or conflict | Explicit responsibility | Competence or access | Test role understanding and tooling. |
| What changed? | Deployment/config/audit timeline | Read-only | Correlated, absent, or ambiguous | Temporal evidence | Causality | Compare mechanism and control cohort. |
| What should we do first? | Mitigation matrix | Decision then controlled mutation | Select, reject, or defer | Transparent tradeoff | Production safety | Review precondition, abort, rollback. |
| Did the change execute? | Change audit and command result | Read-only after mutation | Applied, partial, failed, unknown | Mechanism-reported state | User recovery | Independent journey and state probe. |
| Did users recover? | Synthetic plus real-journey SLI | Read-only | Recovered, partial, or unknown | Declared journey sample | All correctness or future stability | Cohorts, queues, integrity, observation. |
| Is communication current? | Canonical status record | Read-only | Current, stale, conflicting | Message state | Delivery or comprehension | Receipt and audience feedback. |
| Can we hand off? | STATE checklist and acknowledgement | Organizational record | Accepted or incomplete | Explicit transfer | Receiver readiness by itself | Restatement, access check, broadcast. |
| Can we close? | Recovery gate | Decision | Pass, hold, or downgrade | Criteria evaluation | Permanent repair | Reconcile temporary state and PIR. |
| Did we learn? | Action closure with acceptance evidence | Read-only review | Verified, ineffective, or overdue | Specific action result | Zero recurrence | Exercise and trend review. |

## Command decoders

### `date -u +%Y-%m-%dT%H:%M:%SZ`

Question: **What UTC timestamp does this shell report right now?**

```text
2026-08-04T02:24:10Z
```

- `date` reads the system clock.
- `-u` renders Coordinated Universal Time (UTC), avoiding local-zone ambiguity.
- `+...` is the output format.
- `%Y-%m-%d` is year-month-day.
- `T` separates date and time in an ISO 8601-style timestamp.
- `%H:%M:%S` is 24-hour hour, minute, second.
- `Z` states UTC.

This proves what that host reported. It does not prove clock synchronization. Compare named clock sources or known event ordering if seconds matter.

### Alert timeline fields

```text
alert=CheckoutCompletionBurn
startsAt=2026-08-04T02:11:30Z
deliveredAt=2026-08-04T02:12:04Z
acknowledgedAt=2026-08-04T02:13:10Z
status=firing
```

- `alert` identifies the rule or notification.
- `startsAt` is the alert system's firing boundary, not necessarily first user harm.
- `deliveredAt` supports notification latency.
- `acknowledgedAt` supports human receipt latency.
- `status=firing` means the alert engine currently considers its condition active.

Do not call `acknowledgedAt - startsAt` "MTTR." It measures one alert's start-to-ack interval under these clocks.

### `systemctl status` during an incident

```bash
# [READ-ONLY]
systemctl --no-pager --full status checkout-worker.service
```

Important fields include `Loaded` (unit discovery and enablement), `Active` (systemd lifecycle state), `Main PID` (the process systemd tracks), recent log lines, and exit reason. `active (running)` proves a process lifecycle state, not successful checkout. Pair it with the user journey.

### `journalctl --since --until`

```bash
# [READ-ONLY]
journalctl --utc --since '2026-08-04 02:00:00' --until '2026-08-04 02:30:00' -u checkout-worker.service --no-pager
```

- `--utc` renders timestamps consistently.
- `--since` and `--until` bound evidence; an unbounded log dump wastes attention.
- `-u` selects one systemd unit.
- `--no-pager` produces stable terminal output.

Absence of a line does not prove absence of an event. Retention, rate limiting, permissions, wrong unit, clock, buffering, or a failed pipeline can hide evidence.

### `kubectl get deployment`

```bash
# [READ-ONLY / PRODUCTION-SENSITIVE CONTEXT]
kubectl --context <approved-context> -n <namespace> get deployment checkout-api -o wide
```

Decode `READY` as ready replicas over desired replicas, `UP-TO-DATE` as replicas at the current template, `AVAILABLE` as replicas satisfying availability rules, and `AGE` as object age. None proves request correctness. During an incident, record exact context and namespace before any mutation, use explicit authorization, and prefer `kubectl diff` for planned changes.

### Queue evidence

```text
queue_depth=120000        # gauge: items now
oldest_age_seconds=660    # gauge: age of oldest item now
arrival_rate=5200/s       # interval rate
completion_rate=3900/s    # interval rate
```

Depth alone can fall while old high-value work remains stuck. Age alone can rise with one poison item. If arrival exceeds completion by 1,300 per second, backlog grows by roughly that rate until conditions change. Retries may make arrivals dependent on failures, so do not extrapolate forever.

### Change record decoder

```text
change=A-07 state=completed actor=ops-1
started=02:24:10Z finished=02:26:02Z
target=feature/promotion-enrichment desired=disabled observed=disabled
rollback=enable-previous-config
```

`desired=disabled` is intent. `observed=disabled` is mechanism-reported state. Neither proves user recovery. Inspect the predicted user signal, unexpected effects, and rollback viability.

### `curl` recovery probe

```bash
# [READ-ONLY / ONLY AGAINST AN APPROVED ENDPOINT]
curl --fail-with-body --silent --show-error --max-time 5 -o response.json -w 'code=%{http_code} total=%{time_total}\n' https://approved.example/health
```

- `--fail-with-body` exits nonzero for HTTP 400 or greater while retaining a body.
- `--silent --show-error` removes progress but keeps errors.
- `--max-time 5` bounds the call.
- `-o` writes the body; inspect and clean it under the approved procedure.
- `-w` prints HTTP status and elapsed seconds.

A health endpoint can be green while checkout fails. Prefer a safe synthetic of the critical operation and never aim examples at an unapproved system.

### Recovery-window arithmetic

If five-minute error ratios are `0.0004`, `0.0003`, and `0.0005` against a `0.001` sustainable error fraction, all three windows are numerically inside the objective. You still need coverage, traffic volume, correctness, backlog, dependency, and rollback evidence. Three samples are a policy choice, not a law.

### Incident metrics

Suppose:

```text
first_user_impact = 02:05
detected          = 02:11
acknowledged      = 02:13
declared          = 02:16
mitigated         = 02:44
user_recovered    = 02:49
resolved          = 03:20
```

Then:

- impact-to-detection gap: 6 minutes;
- detection-to-acknowledgement: 2 minutes;
- acknowledgement-to-declaration: 3 minutes;
- declaration-to-mitigation: 28 minutes;
- first impact-to-user recovery: 44 minutes;
- user recovery-to-resolution: 31 minutes.

Publish names and boundaries, not just "MTTR = 44m." Otherwise another team may compare resolution time to recovery time and draw a false conclusion.

### Post-incident action decoder

Weak:

```text
Improve alerts. Owner: team. Priority: high.
```

Operational:

```text
ACT-17
risk: checkout completion can fail before the server-response SLI detects it
owner: observability-owner
due: 2026-08-25
change: add completed-order journey SLI segmented by region and telemetry coverage
acceptance: replay fixture detects the prior failure within 5m and stays silent on healthy control
rollback: remove only the new recording and alert rules if evaluation load exceeds budget
status: open
```

The operational item can be prioritized, tested, reviewed, and closed.

## Decision path

Use **COMMAND** when the page arrives:

```text
C — Confirm current user impact and responder fitness.
O — Open an incident early when coordination will help.
M — Map severity, roles, boundaries, and authority.
M — Maintain one incident state and one mutation queue.
A — Act first on reversible user-harm reduction.
N — Notice results through independent evidence and uncertainty.
D — Declare recovery only after multidimensional proof and observation.
```

Detailed path:

1. **Personal readiness.** If driving, impaired, disconnected, or too fatigued, acknowledge only as policy allows and escalate immediately. Heroics are not a control.
2. **Page integrity.** Record alert, time, source, routing, and acknowledgement. Check whether duplicates describe one event.
3. **User impact.** Use black-box or journey evidence. State population, scope, time, correctness, and trend.
4. **Declare or bound triage.** If impact is high, uncertain but dangerous, multi-team, concurrent, or long-running, declare. Otherwise set a short reassessment time.
5. **Assign command.** One person explicitly accepts IC. Delegate operations and communications early.
6. **Freeze freelancing.** Inventory in-flight changes. Pause nonessential mutation. Put candidates in a queue.
7. **Set objective.** Example: "Restore correct checkout completion without duplicate charges." This is better than "fix Kubernetes."
8. **Generate alternatives.** Bypass, disable, roll back, fail over, shed, scale, throttle, drain, restore, or repair.
9. **Evaluate safety.** Time-to-relief, reversibility, blast radius, confidence, evidence loss, access, data integrity, security, cost, and destination headroom.
10. **Execute one controlled step.** Name owner, preconditions, expected evidence, abort, rollback, and deadline.
11. **Observe.** Compare before/after user and system signals. Record unexpected outcomes. Update hypotheses.
12. **Communicate.** Publish facts, uncertainty, actions, workaround, and next update time.
13. **Scale humans.** Add expertise, planning, security, data, support, vendor, or leadership through predefined paths.
14. **Handoff before fatigue.** Use a live acknowledged transfer; verify access and restate priorities.
15. **Prove recovery.** User journey, segments, correctness, queues, dependencies, capacity, telemetry, and observation window.
16. **Reconcile.** Track flags, routes, capacity, access, temporary credentials, manual data, muted alerts, and deferred work.
17. **Review.** Reconcile timeline, quantify impact, build causal graph, assess response, create actions.
18. **Close learning.** Verify action acceptance and practice the improved path.

## Guided Ubuntu lab

This lab is a **flight simulator**, not a production incident system. It lets you inspect deterministic incident decisions without sending a page, touching a service, or pretending a script can judge real people.

### Environment card

| Item | Boundary |
|---|---|
| Platform | Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS |
| User | Normal user; UID 0 is refused |
| Runtime | Bash plus Python 3 standard library |
| Network | None |
| Privilege | No `sudo`, container, namespace, daemon, mount, or capability |
| CPU/RAM | One short Python process; below 128 MiB expected |
| Disk | One `/tmp/reliability-atlas-les0033-<uid>` directory; below 1 MiB |
| Ports | None |
| External effects | No page, ticket, chat, email, cloud, identity, status page, or production action |

### Preflight

```bash
# [READ-ONLY]
id
command -v bash
command -v python3
python3 fixtures/incident_model.py validate-scenario fixtures/scenario.json
bash lab.sh doctor
```

Stop on root, missing tools, invalid fixture, unexpected `/tmp` resolution, or refused existing state.

### Predict before output

Write your prediction for each case:

1. Why is declaration justified?
2. Which roles must be separated first?
3. Why does optional-feature bypass outrank database restart?
4. What evidence prevents false recovery?
5. Which communication sentence expresses uncertainty without becoming vague?
6. What makes the handoff complete?
7. Which PIR action is testable rather than aspirational?

### Lifecycle

```bash
# [MUTATING / BOUNDED]
bash lab.sh setup

# [READ-ONLY]
bash lab.sh status

# [MUTATING / BOUNDED]
bash lab.sh run triage
bash lab.sh run roles
bash lab.sh run mitigation
bash lab.sh run recovery
bash lab.sh run communication
bash lab.sh run handoff
bash lab.sh run review

# [MUTATING / BOUNDED]
bash lab.sh cleanup

# [READ-ONLY]
bash lab.sh status
```

The `run` actions write only one allowed result file each inside the validated private state. They do not simulate time, load, or humans. The JSON output separates result and proof limit.

### Full verification

```bash
# [MUTATING / BOUNDED]
bash verify.sh
```

Passing requires seven cases, semantic assertions, unexpected-child refusal, symlink-child refusal, exact cleanup, and final state absence. Preserve the first failure. If status refuses the state, do not use broad deletion.

### Lab interpretation

The lab should make three habits memorable:

- **Impact before infrastructure:** the declared objective is checkout completion, not "make every pod green."
- **One owner per production change:** parallel hypotheses are welcome; invisible mutation is not.
- **Recovery is a predicate:** green error rate plus draining queues plus valid data plus an observation window.

The complete operating and cleanup contract lives in the checked-in `support/lab/README.md` beside this quarantined draft. It becomes a schema-valid canonical lab link only during reviewed promotion into the public book tree.

## Production transfer

### Kubernetes

A pod crash alert is an event. First ask whether the user journey is affected and whether the controller is restoring capacity. Record context and namespace. Check deployment rollout state, events, readiness, resource saturation, service endpoints, dependency health, and recent changes. A mass pod restart destroys evidence and can increase load.

Mitigations may include halting a rollout, routing away from an affected zone, reducing optional work, scaling within dependency limits, or rolling back a compatible release. Use namespace-scoped commands, explicit context, `kubectl diff` before planned mutation, rollout status, and a documented rollback. Verify through the actual service path, not pod count alone.

### Public cloud

Cloud consoles expose alarms, health events, audit trails, quotas, regional state, and automation. Provider health can be evidence, not proof that your architecture is healthy. Know the shared-responsibility boundary and your support escalation path.

Failover must consider destination capacity, quotas, data replication, DNS and cache behavior, identity, encryption keys, cost, and how to fail back. Record every emergency exception and expiry. Do not use the chapter as authority to change a live cloud account.

### Private cloud and virtualization

A hypervisor, storage fabric, network overlay, or control-plane failure may affect many tenants. Separate management-plane reachability from workload data-plane health. Preserve console and audit access outside the failing dependency. Coordinate capacity movement because evacuation can overload surviving hosts or storage.

Track physical failure domains, noisy-neighbor effects, VM state, storage consistency, network convergence, and tenant communication. A successful VM power-on does not prove application recovery.

### CI/CD and developer platforms

If runners queue indefinitely, determine whether existing production delivery or only development throughput is affected. Protect emergency and rollback lanes from the same saturated queue. Freeze nonessential configuration changes, identify recent controller, runner-image, credential, network, or capacity changes, and avoid clearing queues without understanding whether jobs are safe to replay.

Verify recovered wait time, job correctness, artifact integrity, secret isolation, cancellation behavior, and representative workflows across tenants.

### Data platforms

Availability recovery can conflict with correctness. A stream processor may resume while duplicating events; a warehouse may be reachable while serving stale partitions; a queue may drain out of order. Include data owner and integrity roles early. Record checkpoints, offsets, watermark, schema, lineage, replay boundaries, and idempotency.

Never delete a backlog merely to turn a graph green. Define which data can be replayed, skipped, quarantined, or reconstructed and who authorizes that decision.

### Security incidents

Security response may prioritize containment and evidence preservation differently from an availability incident. Involve the authorized security incident process immediately. Do not rotate, isolate, delete, image, notify, or disclose based solely on this lesson. Chain of custody, privacy, legal, regulator, law-enforcement, and customer-notification rules may apply.

The shared concepts are clear roles, canonical state, controlled action, communication authority, recovery evidence, and learning. The specialized authority is not transferable by analogy.

### Global follow-the-sun operations

Handoff is a designed path, not a courtesy. Maintain compatible severity, role, timestamp, terminology, access, and incident-state conventions across regions. Schedule overlap. Measure handoff gaps and practice them. Never assume the next site has context, permission, language support, or healthy tooling.

## Reliability, security, observability, capacity, and cost

### Reliability

Incident management reduces harm only if it changes decisions. Measure detection gaps, declaration delay, mitigation attempts, time to user recovery, repeat incidents, and action effectiveness. Avoid rewarding quick closure if it encourages hidden residual risk.

On-call sustainability is part of reliability. Track page load, interruptions, after-hours burden, escalation frequency, shift length, and recovery time. A service that meets its SLO by exhausting responders is not sustainably reliable.

### Security

Emergency access is powerful. Use least privilege, time bounds, strong identity, separate approval where feasible, audit logs, protected credentials, and post-incident reconciliation. Never paste secrets into the incident document or broad channels. Treat screenshots and logs as potentially sensitive.

Do not weaken authentication, authorization, TLS, audit, or network controls simply because an incident is urgent. If a reviewed break-glass path is necessary, record risk, approver, scope, expiry, monitoring, and exact closure evidence.

### Observability

The incident state needs both white-box and black-box evidence. Preserve raw counters and intervals, query versions, dashboard links or snapshots where policy allows, clock sources, and telemetry gaps. A dashboard is a view, not the evidence itself.

Instrument the response process too: delivery, acknowledgement, declaration, role assignment, change start/result, update publication, mitigation, recovery, handoff, closure, and action completion.

### Capacity

Incidents often move load. Every scale, retry, failover, drain, or replay changes demand somewhere. Compare arrival and completion rates, headroom, quotas, connections, queue age, storage I/O, network, and downstream capacity. Include the recovery workload: draining a backlog can be more expensive than normal traffic.

### Cost

Emergency scale can be justified, but "add capacity" is not free or always effective. Record expected relief, spend rate, quota, downstream risk, expiry, and owner. Reconcile temporary capacity after stability. Compare the cost with avoided user harm, not with zero in isolation.

### Human factors

Stress narrows attention. Checklists, role cards, templates, and exercises move memory into the system. Psychological safety improves evidence quality: responders must be able to say "I do not know," "I made this change," "I need help," and "I am too fatigued" without punishment.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| Waiting for certainty before declaration | Coordination arrives after chaos. | Declare on impact, uncertainty, multi-team need, or elapsed threshold; downgrade cheaply. |
| Severity by executive visibility | Attention replaces measured impact. | Use written impact criteria and revise with evidence. |
| IC as primary debugger | Shared state and coordination disappear. | Delegate operations; command watches the whole system. |
| More responders without roles | Interruptions and conflicting changes grow. | Assign bounded work through a role tree. |
| Parallel production mutation | Results become uninterpretable. | One visible change queue and operations owner. |
| Rollback reflex | Data and dependency compatibility may be irreversible. | Run a rollback-safety checklist and prefer bounded canaries. |
| Restart reflex | Evidence disappears and load spikes. | State a mechanism and expected signal before restart. |
| Root cause before relief | Users wait for intellectual completeness. | Separate stabilization from analysis. |
| Green alert equals recovered | Blind spots, queues, and corruption remain. | Use a multidimensional recovery predicate and observation window. |
| Exact ETA under uncertainty | Fiction destroys trust. | Give known state, current action, decision point, and next update. |
| Six communication channels | Operators become support routers. | One canonical source and communications lead. |
| Text-only handoff | Receipt and understanding are unknown. | Live briefing, restatement, explicit acceptance, broadcast. |
| Permanent emergency flag | Temporary risk becomes normal configuration. | Owner, expiry, reconciliation list, audit. |
| "Human error" root cause | System defenses remain unchanged. | Causal graph and counterfactual defense analysis. |
| Vague action items | Nothing can be verified closed. | Owner, risk, due date, acceptance test, evidence. |
| Counting PIR documents | Writing is mistaken for learning. | Track action closure, exercise results, and recurrence. |

## Memory card and retrieval

When the pager fires, remember:

```text
USER HARM FIRST
DECLARE BEFORE CHAOS
ONE COMMAND STRUCTURE
ONE CHANGE QUEUE
REVERSIBLE RELIEF BEFORE DEEP REPAIR
FACTS, UNCERTAINTY, NEXT UPDATE
HANDOFF REQUIRES ACCEPTANCE
RECOVERY REQUIRES PROOF
LEARNING REQUIRES CLOSED ACTIONS
```

Retrieval questions:

1. Why can a healthy process still be a severe user incident?
2. What conditions justify early declaration?
3. Which responsibilities belong to command, operations, communications, and planning?
4. Why is a production change queue more important than a long chat transcript?
5. What makes a rollback unsafe?
6. How do mitigation, repair, and recovery differ?
7. What must a useful status update contain?
8. Why is a written note not a complete handoff?
9. Which evidence prevents a false recovery declaration?
10. Why is "human error" an incomplete causal explanation?
11. What turns a PIR action into an operational commitment?
12. How would incident command change for a suspected security compromise?

## Complete answers

### 1. Healthy process, unhealthy user

**Direct:** `running` describes a process lifecycle, not a completed user journey.

**Foundation:** The process may accept connections but time out on a dependency, return incorrect data, serve only one region, or exclude failures before instrumentation. User success must be observed at the journey boundary.

**Senior:** Correlate process, saturation, dependencies, queues, telemetry validity, and segmented black-box outcomes. State proof limits and avoid treating one layer as the service contract.

### 2. Declaration conditions

**Direct:** Declare when customer impact, dangerous uncertainty, multi-team coordination, concurrent changes, elapsed triage time, or specialized authority makes structure valuable.

**Foundation:** Declaration creates an ID, roles, shared record, severity, and communication path. It can be downgraded if the event is small.

**Senior:** Define triggers in policy, review declaration delay after incidents, and reward early appropriate declaration rather than only dramatic outcomes.

### 3. Role boundaries

**Direct:** Command coordinates; operations changes the system; communications updates audiences; planning manages future needs, resources, handoff, and reconciliation.

**Foundation:** Clear roles reduce cognitive load and freelancing. The commander owns any role not delegated, but should delegate as scale grows.

**Senior:** Map decision rights, specialist escalations, security/legal authority, and subincident leads. Require acknowledgement and record every transfer.

### 4. One change queue

**Direct:** It makes in-flight mutations, owners, dependencies, and results visible.

**Foundation:** Chat records conversation but may not distinguish ideas from approved actions. The queue serializes interacting changes and preserves interpretability.

**Senior:** Integrate emergency change controls, audit IDs, preconditions, expected signals, abort, rollback, evidence preservation, and post-incident reconciliation without adding unsafe latency.

### 5. Unsafe rollback

**Direct:** The previous software may no longer be compatible with current data, config, dependencies, or state.

**Foundation:** Database migrations, irreversible writes, cache formats, feature flags, and API contracts can make time asymmetric.

**Senior:** Continuously test backward/forward compatibility, rollback windows, expand-contract migrations, state restoration, and progressive delivery. Treat rollback as a production change with its own failure modes.

### 6. Mitigation, repair, recovery

**Direct:** Mitigation reduces harm; repair changes the defect; recovery proves the required outcome is back.

**Foundation:** Disabling enrichment can mitigate checkout while the defect remains. A code fix repairs it. User and correctness evidence over time prove recovery.

**Senior:** Track separate timestamps and residual risks. Do not delay mitigation for repair, and do not infer recovery from change completion.

### 7. Status update

**Direct:** Timestamp, state, impact, scope, current action and result, uncertainty, workaround, owner, and next update.

**Foundation:** Readers need to know what is happening, what to do, and when they will hear more. Hypotheses must not be written as facts.

**Senior:** Maintain one canonical fact set, adapt detail to audience, apply privacy/security/legal review, preserve accessibility, and measure whether communication reduces interruptions and supports decisions.

### 8. Complete handoff

**Direct:** The receiver must participate, demonstrate understanding, explicitly accept, and be announced.

**Foundation:** A note can be unread, stale, or misunderstood. The outgoing owner remains accountable until acceptance.

**Senior:** Transfer roles, user state, changes, access, risks, hypotheses, next decisions, communications, temporary state, and fatigue context. Exercise handoff across time zones.

### 9. Recovery evidence

**Direct:** Critical journeys, cohorts, correctness, queues, dependencies, capacity, telemetry validity, and a stable observation window.

**Foundation:** One green error-rate panel can hide missing data, a growing backlog, or wrong results.

**Senior:** Define a service-specific recovery predicate before incidents, include downstream and data-state reconciliation, require independent evidence, and explicitly own residual risk after downgrade.

### 10. Human error

**Direct:** It names an action, not why the system allowed that action to create and sustain harm.

**Foundation:** Ask about interfaces, permissions, review, tests, blast-radius controls, observability, rollback, workload, and incentives.

**Senior:** Build a causal graph, test counterfactual defenses, preserve accountability for decisions, and avoid moral language that suppresses future evidence.

### 11. Operational action

**Direct:** Owner, risk, specific change, priority, due date, acceptance test, and closure evidence.

**Foundation:** "Improve monitoring" cannot be objectively finished. "Detect the replayed failure within five minutes" can.

**Senior:** Balance prevention, containment, detection, mitigation, recovery, and coordination; track overdue items, validate effectiveness, and retire actions that do not reduce measured risk.

### 12. Security transfer

**Direct:** Keep coordination discipline but activate specialized security authority and evidence rules immediately.

**Foundation:** Containment, forensics, identity, privacy, notification, and legal decisions differ from an availability outage.

**Senior:** Use the organization's security incident response plan, least-privilege break-glass paths, chain of custody, counsel/regulatory ownership, and parallel availability planning. Never improvise disclosure or destructive evidence handling from a generic runbook.

## Product-company interview

**Scenario:** A global checkout service begins returning 18% errors in west after release `7.42`. Central rises to 11% five minutes later. East is healthy. Queue age is increasing. The release added a synchronous promotion dependency. A rollback exists, but the release also wrote a backward-incompatible cache format. The promotion feature can be disabled by region. Three engineers are already making independent changes. A vice president asks for the root cause and exact ETA. Lead the first thirty minutes.

**Model answer:**

"I would first stop the response from becoming a second outage. I would confirm the critical journey and data-correctness impact, acknowledge the page, declare under the organization's severity policy, and name one incident commander. Because I know the service deeply, I may take operations while another trained responder commands. I would assign communications and open a live state record with UTC timestamps, severity, impact, roles, facts, hypotheses, decisions, and a serialized change queue.

"The objective is to restore correct checkout completion without duplicate orders, not to make every component green. I would pause uncoordinated mutation and inventory what has already changed. Release `7.42` is correlated, but correlation is not yet causation. The synchronous promotion call, rising queue age, regional spread, and deployment timing make it a strong hypothesis. A blind rollback is unsafe because cache compatibility is unknown. Database restart is high-blast-radius and lacks a mechanism.

"I would compare candidates. Region-scoped promotion disablement is fast, reversible, preserves the core journey, and avoids the cache rollback risk. After reviewing authorization, exact target, fallback correctness, abort thresholds, and rollback, I would canary west under one owner. I expect checkout completion to improve within one five-minute window, queue growth to stop, and dependency traffic to fall. I would abort if correctness fails, error rate rises, or the flag state is ambiguous. If west improves, I would extend to central through the same controlled path.

"In parallel, read-only workstreams can compare release/control regions, promotion-call latency, worker saturation, retries, queue arrival versus completion, and telemetry coverage. No additional production mutation bypasses operations. Communications would tell leadership: confirmed impact and scope, current reversible mitigation, rollback constraint, uncertainty about the trigger, and the next update time. I would not invent root cause or ETA.

"I would declare user recovery only after segmented journey success, duplicate-order checks, queue drainage, dependency headroom, valid telemetry, and a defined observation window. I would record the temporary feature state and owner. If the event crosses shifts, I would perform an acknowledged live handoff. Afterward, the PIR would examine synchronous coupling, retry amplification, canary population, cache compatibility, change coordination, and detection. Actions would have owners and tests, including an asynchronous or bounded promotion path, compatible rollback design, user-journey SLI, idempotent replay test, and practiced feature-bypass runbook."

**Why weak answers fail:**

- "Roll back immediately" ignores incompatible state.
- "Restart all pods" has no causal mechanism and destroys evidence.
- "Scale everything" can overload dependencies and increase cost without relieving the synchronous bottleneck.
- "Find root cause first" prolongs active harm.
- "Tell leadership thirty minutes" invents certainty.
- "Let each expert fix their part" permits interacting changes without shared control.
- "Close when error rate is green" ignores queues and correctness.

**Answered follow-ups:**

1. **What if no trained IC is available?** The declaring responder temporarily holds command, immediately escalates for a trained replacement, limits work to essential safe actions, and records the authority gap. The absence is a readiness defect for follow-up.
2. **What if disabling promotions violates a business commitment?** The authorized product or risk owner weighs the degraded experience against ongoing checkout failure. SRE supplies impact and technical risk; it does not invent business authority.
3. **What if west improves before the flag change completes?** Do not attribute recovery to the flag. Compare exact timing, control regions, observed flag state, dependency traffic, and alternative mechanisms. Preserve the uncertainty.
4. **Would you fail east traffic into west?** Not without destination headroom, failure-domain independence, data compatibility, routing behavior, and rollback evidence. East is currently healthy; protect it from a speculative move.
5. **When do you involve security?** Immediately if evidence suggests compromise, unauthorized access, sensitive-data exposure, integrity manipulation, or policy thresholds. Security response authority runs alongside availability command.
6. **How do you measure response performance?** Use explicitly bounded intervals such as impact-to-detection, detection-to-acknowledgement, declaration-to-mitigation, impact-to-user-recovery, update timeliness, handoff gaps, repeat incidents, and action effectiveness. Avoid ambiguous MTTR.
7. **Who owns the PIR?** A named facilitator or owner with service and relevant cross-functional participation. The incident commander can contribute but should not control the narrative alone.
8. **What if a mitigation is expensive?** Compare time-bounded spend and downstream risk with user/business harm. Set an expiry and owner; cost does not automatically outrank critical recovery.

## Independent transfer and rubric

The independent assessment is `ASM-0084`. It must use a held-back case with different services, evidence, severity ambiguity, mitigation tradeoffs, communication pressure, and causal conditions. The guided answers are disqualifying as a submission.

Required deliverables:

1. a first-five-minute page and responder-fitness record;
2. user-impact statement with population, interval, correctness, scope, and uncertainty;
3. severity decision and reassessment condition;
4. acknowledged role map and escalation paths;
5. canonical incident-state document;
6. at least six ranked falsifiable hypotheses;
7. at least four mitigation candidates with safety matrix;
8. two complete controlled-change proposals and one rejected dangerous action;
9. internal, customer-safe, and executive updates with next-update commitments;
10. an acknowledged handoff using STATE;
11. service-specific recovery predicate and observation window;
12. causal graph with at least five mechanism links;
13. at least six actions distributed across prevention, containment, detection, mitigation, recovery, and coordination;
14. a five-minute interview defense and at least fifteen explicit non-claims;
15. exact local cleanup proof.

Scoring is 100 points:

| Criterion | Points | Evidence |
|---|---:|---|
| Independence, scope, and evidence integrity | 10 | Unseen case, declared help, sanitized sources, bounded environment. |
| Impact, triage, and severity | 10 | User-first facts, trend, uncertainty, policy mapping, reassessment. |
| Command and role design | 10 | Acknowledged ownership, authority, escalation, no freelancing. |
| Evidence and hypothesis quality | 10 | Timestamped sources, falsifiable branches, proof limits. |
| Mitigation safety | 10 | Relief, reversibility, blast radius, preconditions, abort, rollback. |
| Communication | 10 | Audience-specific facts, uncertainty, workaround, next update. |
| Handoff and human sustainability | 10 | Live acceptance, restatement, access, fatigue and staffing controls. |
| Recovery proof | 10 | Journey, correctness, queues, dependencies, telemetry, observation. |
| Causal review and actions | 10 | Mechanism graph, blameless precision, owned testable improvements. |
| Defense and non-claims | 10 | Clear reasoning, tradeoffs, limits, cleanup and safe transfer. |

Passing a score does not by itself establish mastery. A qualified reviewer must verify independence, safety, reasoning, and evidence; remediation and delayed reassessment remain required.

## References and review

Primary and official records are in `support/references/REF-0259.json` through `REF-0273.json`. Start with:

- Google SRE, *Managing Incidents* and the SRE Workbook *Incident Response* for command structure, roles, shared state, handoff, and practice.
- Google SRE, *Emergency Response* and both postmortem chapters for preparation, evidence, blameless learning, and action follow-through.
- NIST SP 800-61 Rev. 3 for current cybersecurity incident-response integration with risk management.
- AWS Well-Architected Operational Excellence guidance for event/incident/problem process, business-impact prioritization, escalation, communications, runbooks, playbooks, and post-incident improvement.
- Microsoft cloud operations and incident-preparedness guidance for current cloud transfer and exercises.
- Kubernetes documentation for safe, scoped debugging and rollout evidence.
- Prometheus and OpenTelemetry documentation for alert and telemetry semantics used during response.

Review this chapter and every reference by 2027-02-04, and earlier when a referenced framework, provider incident service, command behavior, security standard, or repository lab contract changes. Version-sensitive production commands must be checked against the exact installed provider and organizational policy before use.

Final proof boundary: this chapter can teach vocabulary, mechanisms, decisions, and a safe local model. It cannot grant incident authority, reproduce production pressure, prove a real service recovered, validate a legal or security response, or establish that a learner can lead independently. Those claims require observed work on an authorized unseen simulation, qualified review, remediation, delayed recall, and eventually supervised real operational evidence.
