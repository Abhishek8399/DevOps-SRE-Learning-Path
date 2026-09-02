---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0032",
  "slug": "sli-slo-sla-error-budgets",
  "aliases": ["V04-L07", "sli-slo-sla-error-budgets"],
  "curriculumIds": ["SRE-002"],
  "route": "/book/reliability/sli-slo-sla-error-budgets",
  "order": 7,
  "volume": "04-reliability-operations",
  "title": "SLIs, SLOs, SLAs, and error budgets: make reliability a decision system",
  "summary": "Start with a user operation, define valid good and total populations, choose an evidence-based objective and window, calculate error budgets without hiding units or missing data, distinguish contractual consequences, and turn burn rates into actionable policy rather than decorative percentages.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0007", "LES-0008", "LES-0026"],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001", "OBS-001", "SRE-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The bounded teaching model requires only Bash and Python 3, refuses root, changes one UID-scoped temporary directory, opens no port, and contacts no monitoring, cloud, contractual, identity, notification, or production system."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The model is designed for WSL, but WSL service startup, filesystem ownership, clock, path, and process behavior must be recorded rather than assumed equivalent to native Ubuntu."
    },
    {
      "platform": "Prometheus, Kubernetes, public cloud, private cloud, and production services",
      "version": "concept-only",
      "support": "concept-only",
      "notes": "The chapter explains transfer and includes reviewable PromQL patterns. No provider runtime, real SLI, stakeholder approval, SLA interpretation, page delivery, error-budget action, or production change has been executed."
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
    "technical-lead",
    "engineering-manager",
    "incident-commander"
  ],
  "learningObjectives": [
    "Translate a user operation into an SLI specification whose eligible, good, bad, partial, retry, duplicate, exclusion, unknown, unit, interval, source, coverage and freshness rules are explicit.",
    "Distinguish an SLI measurement from an SLO target and an SLA with explicit consequences, including the owners authorized to define and act on each.",
    "Calculate event-based and time-based attainment, allowed bad events or time, consumed budget, remaining budget and burn rate with matched populations and visible units.",
    "Choose rolling or calendar windows and explain how traffic, old samples, sampling resolution, missing data and counter resets change interpretation.",
    "Design latency, availability, correctness, freshness, durability and pipeline SLIs without confusing infrastructure health, averages or percentiles with user success.",
    "Aggregate numerators and denominators safely, preserve important cohorts, detect measurement coverage defects, and refuse mean-of-ratios or mean-of-percentiles fallacies.",
    "Build multi-window, multi-burn-rate alerts that balance precision, recall, detection, reset, urgency, low-traffic behavior and human actionability.",
    "Create an error-budget policy that changes priorities through authorized owners while preserving reviewed reliability and urgent security exception paths.",
    "Debug a suspicious green or red SLO by separating service failure, instrumentation failure, query failure, pipeline failure, policy failure and contractual claims.",
    "Defend reliability targets and decisions in product-company interviews using formulas, evidence, tradeoffs, safe actions and precise non-claims."
  ],
  "productionSignals": [
    "critical user and machine journeys, eligibility, goodness, partial success, correctness, latency, freshness, durability, completion and abandonment",
    "raw good, bad, total, excluded, duplicate, retried, unknown and late events by immutable interval, source, version, region, tenant and journey",
    "telemetry coverage, source freshness, collection gaps, counter resets, label changes, clock alignment, pipeline loss and query evaluation failures",
    "event-based, time-based and time-slice SLI values with numerator, denominator, units, aggregation and uncertainty",
    "SLO target, rolling or calendar window, authors, reviewers, approvers, approval time, review date and change history",
    "allowed bad events or minutes, consumed amount, remaining amount, budget fraction and trajectory with explicit rounding policy",
    "short- and long-window bad ratios, sustainable bad ratio, normalized burn rate, threshold, state, severity, detection time and reset time",
    "page, ticket and dashboard delivery, route owner, acknowledgement, action taken, user recovery, false positives, false negatives and notification duplication",
    "error-budget policy state, feature posture, reliability exception, security exception, escalation, expiry and authorized decision record",
    "SLA scope, measurement source, exclusions, consequence, claim period, contractual owner and dispute path",
    "dependency objectives, end-to-end objective, headroom, correlated failure, retry amplification, fallback and degradation behavior",
    "reliability investment, user harm, revenue or mission impact, engineering cost, opportunity cost, and evidence that a policy action improved outcomes"
  ],
  "diagrams": [
    {
      "id": "LES-0032-DIA-001",
      "title": "Reliability decision chain",
      "direction": "left-to-right",
      "boundaries": ["user need", "journey contract", "event observation", "SLI implementation", "SLO and window", "error budget", "burn signal", "policy decision", "engineering outcome"],
      "evidencePoints": ["research and harm", "eligible/good rules", "raw counters", "coverage and query", "approved target", "remaining budget", "long/short rates", "authorized record", "measured user result"],
      "textAlternative": "A user need becomes a journey contract. Events are observed and transformed by a versioned SLI implementation. Authorized owners approve a target and window. The measured distance from that objective becomes an error budget and burn signal. A pre-agreed policy changes engineering priorities, and the resulting user outcome feeds the next review."
    },
    {
      "id": "LES-0032-DIA-002",
      "title": "Good, bad, excluded, and unknown population",
      "direction": "hierarchical",
      "boundaries": ["candidate events", "eligibility rule", "eligible events", "good rule", "good events", "bad events", "unknown events", "excluded events"],
      "evidencePoints": ["source total", "filter version", "eligible total", "terminal outcome", "numerator", "complement", "coverage gap", "reason-coded exclusions"],
      "textAlternative": "Candidate events first pass an eligibility rule. Explicitly excluded events remain outside the denominator with reasons. Every eligible event must become good, bad, or unknown. Good is the numerator; all eligible events are the intended denominator. Unknown is never silently counted as good and triggers the declared missing-data policy."
    },
    {
      "id": "LES-0032-DIA-003",
      "title": "Measurement pipeline and trust boundaries",
      "direction": "left-to-right",
      "boundaries": ["client", "edge", "service", "dependency", "metric exporter", "collector", "time-series store", "recording rule", "SLO evaluator", "dashboard and alert"],
      "evidencePoints": ["operation ID", "accepted count", "terminal state", "dependency outcome", "counter sample", "scrape status", "raw series", "rule output", "budget state", "delivery receipt"],
      "textAlternative": "A request crosses client, edge, service and dependency boundaries. Instrumentation exports counters, a collector scrapes them, a store persists samples, recording rules aggregate good and total rates, an evaluator compares the result with the objective, and dashboards or alerts present decisions. Every hop can lose, duplicate, delay, relabel, reset, or misclassify evidence."
    },
    {
      "id": "LES-0032-DIA-004",
      "title": "Error-budget geometry",
      "direction": "top-to-bottom",
      "boundaries": ["100 percent ideal", "approved SLO", "allowed bad fraction", "actual bad fraction", "remaining budget", "policy state"],
      "evidencePoints": ["one", "target", "one minus target", "bad over total", "allowed minus actual", "signed response"],
      "textAlternative": "The distance between one hundred percent and the approved objective is the allowed bad fraction. Multiplying it by the eligible population gives allowed bad events. Actual bad events consume that allowance. Positive remaining budget does not prove users are happy; negative remaining budget invokes the agreed policy if measurement is valid."
    },
    {
      "id": "LES-0032-DIA-005",
      "title": "Multi-window burn-rate state",
      "direction": "hierarchical",
      "boundaries": ["raw bad and total counters", "long-window bad ratio", "short-window bad ratio", "normalize by budget rate", "long threshold", "short threshold", "AND state", "page or ticket"],
      "evidencePoints": ["counter deltas", "significance", "currently active", "burn multiple", "budget threat", "reset evidence", "firing state", "routing receipt"],
      "textAlternative": "The same valid counters produce long- and short-window bad ratios. Each is divided by the sustainable bad ratio. The long window asks whether the event is significant; the short window asks whether it is still active. Both must exceed the same tier threshold before the notification is selected."
    },
    {
      "id": "LES-0032-DIA-006",
      "title": "SLO policy feedback loop",
      "direction": "cyclic",
      "boundaries": ["measure", "validate", "compare", "decide", "stabilize", "improve", "verify", "review objective"],
      "evidencePoints": ["raw population", "coverage", "target/window", "policy record", "user recovery", "risk reduction", "new outcome", "stakeholder approval"],
      "textAlternative": "Measure the user journey, validate the evidence, compare it with the objective, and make a policy-backed decision. Stabilize current harm, improve the source, verify the new user outcome, then review whether the objective and implementation still represent user and business needs."
    }
  ],
  "commands": [
    {
      "id": "LES-0032-CMD-001",
      "question": "Which user, kernel, Ubuntu release, Python version, UTC time, and directory define this attempt?",
      "risk": "read-only",
      "command": "id; uname -a; cat /etc/os-release; python3 --version; date -u +%Y-%m-%dT%H:%M:%SZ; pwd",
      "runFrom": "a normal Ubuntu shell before touching the lab",
      "expectedBranches": [
        {"when": "the caller is non-root and environment matches the approved scope", "meaning": "the local evidence context is recorded", "nextEvidence": "run the model's scenario validation and lab doctor"},
        {"when": "the caller is root, release differs, time is implausible, Python is absent, or path is unexpected", "meaning": "identity, portability, time, dependency, or path assumptions are unsafe", "nextEvidence": "stop mutation and correct or record the gap"}
      ],
      "proves": "only caller and self-reported local environment identity at that moment",
      "doesNotProve": "organizational authorization, synchronized clocks, production equivalence, SLI validity, or SLO approval"
    },
    {
      "id": "LES-0032-CMD-002",
      "question": "Does the fictional SLO scenario satisfy its exact input contract?",
      "risk": "read-only",
      "command": "python3 fixtures/slo_model.py validate-scenario fixtures/scenario.json",
      "runFrom": "book/labs/LES-0032-sli-slo-sla-error-budgets",
      "expectedBranches": [
        {"when": "scenario_valid=true appears", "meaning": "the exact fixture satisfies current identity, key, type, count, range, and relationship checks", "nextEvidence": "run doctor and setup"},
        {"when": "refused=true or a Python error appears", "meaning": "the fixture or model is invalid", "nextEvidence": "preserve the first error and do not create state"}
      ],
      "proves": "only conformance to the checked-in deterministic validator",
      "doesNotProve": "real telemetry, correct policy, user impact, production math, or universal SLO design"
    },
    {
      "id": "LES-0032-CMD-003",
      "question": "Can the lab create its exact private normal-user state?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "book/labs/LES-0032-sli-slo-sla-error-budgets as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "state=ready appears", "meaning": "the exact UID-scoped state descriptor validates", "nextEvidence": "inspect status and run one case"},
        {"when": "refused=true appears", "meaning": "root, tool, fixture, ownership, symlink, concurrency, path, or state identity is unsafe", "nextEvidence": "preserve the path and inspect only the stated refusal"}
      ],
      "proves": "bounded state creation or validation under this script contract",
      "doesNotProve": "SLO correctness, real service access, policy authority, cleanup, or learner understanding",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-004",
      "question": "What exact lab state and result count exist?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "book/labs/LES-0032-sli-slo-sla-error-budgets",
      "expectedBranches": [
        {"when": "state=absent appears", "meaning": "the expected state path is absent", "nextEvidence": "run setup if practice is intended"},
        {"when": "state=ready appears", "meaning": "sentinel, manifest, scenario, children, types, and ownership validate", "nextEvidence": "compare result count with deliberately run cases"},
        {"when": "refused=true appears", "meaning": "state is ambiguous or violates the descriptor", "nextEvidence": "preserve it for bounded review"}
      ],
      "proves": "only encoded state validity and count of allowed result files",
      "doesNotProve": "semantic correctness, production evidence, cleanup, independence, or mastery"
    },
    {
      "id": "LES-0032-CMD-005",
      "question": "Which event-based objective is compliant and how many bad events remain?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run event-sli",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "checkout shows 0.9984, minus 1,200 remaining events, and 1.6 consumed while catalog shows 0.9975 and 1,000 remaining", "meaning": "the reviewed fixture arithmetic is intact", "nextEvidence": "inspect exact eligibility, good definitions, coverage, and policy"},
        {"when": "different values appear", "meaning": "input, formula, or output contract changed", "nextEvidence": "reconcile raw good, total, target, and rounding before interpretation"}
      ],
      "proves": "good/total and error-budget arithmetic over two declared populations",
      "doesNotProve": "that the populations are real, complete, user-relevant, approved, or causal",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-006",
      "question": "How many bad minutes does a 99.9 percent objective allow over the fixture's 28 days?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run time-budget",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "40.32 allowed, 47.5 observed, and minus 7.18 remaining minutes appear", "meaning": "time-window arithmetic marks the fixture noncompliant", "nextEvidence": "inspect sampling resolution, good definition, gaps, maintenance rules, and user impact"},
        {"when": "another result appears", "meaning": "target, window, observation, or formula changed", "nextEvidence": "recalculate from total minutes and declared bad samples"}
      ],
      "proves": "time allowance and observed remainder under one sampling definition",
      "doesNotProve": "continuous observation, every user's experience, correctness, durability, or SLA breach",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-007",
      "question": "Does the latency threshold objective pass, and why is this not the same as reporting p99 latency?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run latency",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "98,750 of 100,000 are good and 1.25 of budget is consumed", "meaning": "98.75 percent met the 400 millisecond threshold against a 99 percent target", "nextEvidence": "inspect correctness, full distribution, bucket boundary, coverage, and segments"},
        {"when": "a different ratio appears", "meaning": "population, threshold, or target changed", "nextEvidence": "reconcile raw histogram or event counts"}
      ],
      "proves": "the fraction of fixture events meeting one latency boundary",
      "doesNotProve": "the p99 value, tail shape, response correctness, or that histogram interpolation is exact",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-008",
      "question": "Can a 99.9 percent observed-only SLI be trusted when telemetry coverage is 90 percent?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run coverage",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "coverage is 0.9, observed-only SLI is 0.999, conservative bound is 0.8991, and measurementValid=false", "meaning": "one thousand eligible events are unknown", "nextEvidence": "reconcile source counts and apply the approved missing-data policy"},
        {"when": "measurement is valid", "meaning": "observed and authoritative totals match under fixture rules", "nextEvidence": "still check duplication, semantics, freshness, and correctness"}
      ],
      "proves": "a declared coverage ratio and two explicitly different calculations",
      "doesNotProve": "that missing events failed, that the independent total is authoritative in reality, or which source is wrong",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-009",
      "question": "Why must group numerators and denominators be summed instead of averaging percentages?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run aggregation",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "weighted good-over-total is 0.991 while unweighted mean is 0.995", "meaning": "unequal group volumes make the simple mean overweight the small group", "nextEvidence": "verify shared semantics, exclusivity, completeness, and important cohort views"},
        {"when": "values match", "meaning": "equal weights or coincidental ratios may hide the same conceptual risk", "nextEvidence": "inspect raw counts rather than accepting the mean"}
      ],
      "proves": "the mathematical difference for declared group counts",
      "doesNotProve": "that combining groups is semantically valid or that the aggregate reveals harmed minorities",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-010",
      "question": "How quickly is checkout consuming budget if its 0.16 percent bad ratio persists?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run burn",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "sustainable rate 0.001, actual rate 0.0016, burn 1.6, and 17.5 days to exhaustion appear", "meaning": "the fixture consumes budget 1.6 times the sustainable rate", "nextEvidence": "inspect shorter and longer windows, trend, coverage, traffic, and policy"},
        {"when": "burn differs", "meaning": "target or bad ratio changed", "nextEvidence": "recompute actual bad ratio divided by one minus target"}
      ],
      "proves": "normalized burn and a constant-rate projection over declared inputs",
      "doesNotProve": "that future traffic or errors stay constant, when the incident began, root cause, or page urgency",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-011",
      "question": "Which burn signals notify, how does low traffic change judgment, and what does policy permit?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run alerting; bash lab.sh run low-traffic; bash lab.sh run policy",
      "runFrom": "a validated ready LES-0032 lab state",
      "expectedBranches": [
        {"when": "three active signals, recovered-spike inactive, low-traffic human review, and feature pause with reliability/security exception paths appear", "meaning": "long/short AND logic and fixture policy behave as reviewed", "nextEvidence": "inspect actionability, routing, impact, approval, canary, and recovery"},
        {"when": "another decision appears", "meaning": "signal, threshold, low-traffic context, or policy inputs changed", "nextEvidence": "review each case separately before operational use"}
      ],
      "proves": "three deterministic decision functions over declared fixture data",
      "doesNotProve": "page delivery, human response, policy approval, production authorization, contractual meaning, or correct target",
      "cleanup": "bash lab.sh cleanup"
    },
    {
      "id": "LES-0032-CMD-012",
      "question": "Does the complete bounded lifecycle, math, refusal, and cleanup contract pass?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "book/labs/LES-0032-sli-slo-sla-error-budgets as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "verification=passed, cases=9, assertions=24, and final_state=absent appear", "meaning": "encoded syntax, cases, assertions, two refusal probes, and exact cleanup passed", "nextEvidence": "record environment, commit, and proof limits"},
        {"when": "the verifier fails", "meaning": "the first failed invariant is evidence and the exit trap attempted bounded cleanup", "nextEvidence": "preserve output and inspect only the exact lesson state"}
      ],
      "proves": "mentor-project behavior for the checked-in deterministic fixture on that environment",
      "doesNotProve": "real SLI validity, SLO approval, production PromQL, policy success, contractual status, learner competence, or mastery",
      "cleanup": "The verifier traps cleanup; confirm with bash lab.sh status and require state=absent. Preserve ambiguous state instead of deleting it broadly."
    }
  ],
  "labs": [
    {
      "id": "LES-0032-LAB-001",
      "title": "Guided SLI, SLO, budget, burn, and policy model",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS normal user with Bash and Python 3; no Docker, network, ports, sudo, package installation, monitoring daemon, contract, notification, organization system, or production service",
      "timeMinutes": 150,
      "privilege": "normal user; wrapper and verifier refuse UID 0",
      "network": "none; fixture, arithmetic, state, and decisions remain local",
      "changes": ["one lesson-specific private temporary directory", "owned fixture and manifest copies", "at most nine bounded JSON result files"],
      "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "a child is a symlink or unexpected type", "fixture contract is invalid", "arithmetic differs from reviewed expectations", "cleanup cannot validate exact ownership", "any real service or policy action is proposed from model output"],
      "recovery": "Run status. If the descriptor validates, run cleanup and repeat setup. Preserve refused foreign or ambiguous state for review instead of deleting broadly.",
      "cleanupProof": "Cleanup validates exact parent, basename, real path, UID, sentinel, manifest, scenario, allowed children, types, and owner; removes only that directory; then proves exact absence.",
      "path": "book/labs/LES-0032-sli-slo-sla-error-budgets"
    },
    {
      "id": "LES-0032-LAB-002",
      "title": "Independent user-journey SLO and policy defense",
      "mode": "independent",
      "environment": "An instructor-provided or held-back unseen disposable local case with materially changed journeys, populations, measurement defects, traffic, objectives, burn signals, policy conflict, and proposed change; the guided fixture cannot satisfy independence",
      "timeMinutes": 180,
      "privilege": "normal user; no elevated, contractual, notification, or organizational operation",
      "network": "none unless a separately reviewed unseen harness explicitly declares loopback; production, shared, employer, cloud, contract, identity, email, chat, ticket, and pager systems are prohibited",
      "changes": ["one learner-owned sanitized response outside guarded LES-0032 state", "only resources explicitly declared by the unseen disposable case"],
      "abortConditions": ["answered material becomes visible", "authorization, accessibility, or sanitization is unclear", "population or state validation fails", "real data or systems could be contacted", "a percentage is used without raw counts and units", "an unsupported contract or change decision is proposed"],
      "recovery": "Return to baseline evidence, narrow the hypothesis, and submit a revision. Never reveal answered material before independent review.",
      "cleanupProof": "Use the unseen case's own manifest to prove every created process, port, file, queue, container, network, and resource absent. Guided cleanup does not cover the independent case.",
      "path": "book/labs/LES-0032-sli-slo-sla-error-budgets"
    }
  ],
  "incidents": [
    {
      "id": "LES-0032-INC-001",
      "signal": "A checkout SLO is green while an independently owned edge counter contains far more eligible operations than the SLI denominator.",
      "firstThought": "Green is a query result, not truth. Validate eligible-population coverage before interpreting the percentage.",
      "safePath": "Align intervals and semantics, quantify unknown events, test loss/duplication/filter/reset hypotheses, apply the approved missing-data policy, and recalculate from reconciled raw counts.",
      "trap": "Calling unobserved operations successful because no application error exists hides failures before instrumentation."
    },
    {
      "id": "LES-0032-INC-002",
      "signal": "A 99.9 percent SLO page fires repeatedly for a service that receives only ten meaningful operations per month.",
      "firstThought": "The burn calculation may be correct while the notification strategy is wrong. One failure is a 100x burn but impact and response opportunity decide actionability.",
      "safePath": "Inspect single-event harm, retries and recovery, measurement validity, synthetic coverage, related-population aggregation, target fitness, ticket/manual paths, and whether the product should reduce failure impact.",
      "trap": "Silencing the alert without an alternative makes rare high-value failures invisible; paging on every mathematical spike can exhaust responders without helping users."
    },
    {
      "id": "LES-0032-INC-003",
      "signal": "The long burn window remains above threshold after users recover, but the short window is healthy.",
      "firstThought": "The significant event remains in long-window history, while current burn may have stopped. Check the intended long AND short state and independent recovery evidence.",
      "safePath": "Verify current user success, measurement freshness, short-window reset, alert-state transitions, and incident follow-up; keep the historical budget loss visible without continuing a false active page.",
      "trap": "Using only the long window creates slow reset; using only the short window produces noisy alerts and can miss sustained lower burns."
    },
    {
      "id": "LES-0032-INC-004",
      "signal": "An exhausted error budget is used to block an idempotency fix and a critical security control while a feature team requests an exception for a new synchronous dependency.",
      "firstThought": "A budget policy must reduce user risk, not mechanically stop all change. Inspect the signed exception and authority model.",
      "safePath": "Pause user-risk-increasing feature work, route reliability and urgent security changes through reviewed canary/rollback exception paths, document owners and expiry, and verify resulting user outcomes.",
      "trap": "A blanket freeze can preserve the defect; an informal exception can bypass the very control the policy exists to provide."
    }
  ],
  "assessmentIds": ["ASM-0079", "ASM-0080", "ASM-0081"],
  "referenceIds": ["REF-0244", "REF-0245", "REF-0246", "REF-0247", "REF-0248", "REF-0249", "REF-0250", "REF-0251", "REF-0252", "REF-0253", "REF-0254", "REF-0255", "REF-0256", "REF-0257", "REF-0258"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "The deterministic model calculates only fictional checked-in inputs; it is not a Prometheus implementation, production SLO evaluator, stakeholder approval system, legal interpretation, or change authority.",
    "The chapter does not prescribe one SLI, target, window, burn threshold, exclusion, missing-data rule, rounding policy, SLA, or error-budget policy for every service.",
    "No real users, services, telemetry systems, contracts, pages, teams, clouds, dependencies, policy decisions, releases, or incidents were observed or modified.",
    "Provider functions and specifications evolve; Prometheus, Google Cloud, and OpenSLO references require scheduled review before implementation.",
    "Passing project checks does not prove learner execution, independent transfer, delayed retention, interview performance, professional level, or mastery."
  ]
}
---

# SLIs, SLOs, SLAs, and error budgets: make reliability a decision system

The shortest useful version is this:

> A percentage becomes an SLO only after you can say whose experience it represents, which events count, what good means, where evidence comes from, what time window applies, who approved the target, and what decision changes when the budget is threatened.

Without that chain, `99.9%` is decoration.

This chapter starts from zero and grows to senior production judgment. You will calculate every value yourself, but arithmetic is only one layer. The difficult work is choosing a population that represents users, detecting when measurement lies, and connecting the result to an authorized action.

## What you see and first thought

You are on call. A dashboard says:

```text
Checkout availability SLO: 99.95%       target: 99.90%       status: GREEN
```

Your first thought should **not** be “checkout is healthy.” Think:

> “This is a claim produced by a measurement pipeline. Which user operation, numerator, denominator, interval, boundary, coverage, and policy created it?”

The green result can coexist with broken users:

- the metric may count only requests that reached the application, hiding failures at Domain Name System (DNS), Transport Layer Security (TLS), load balancer, or edge boundaries;
- a `200` response may contain an incorrect or stale answer;
- retries may make one harmed user operation look like several events;
- one high-volume healthy region may hide a fully broken small region;
- missing telemetry may remove bad events from the denominator;
- the query may average percentages rather than aggregate raw counts;
- the SLO may cover API availability while the user needs a complete order;
- the target may never have been approved or tied to a decision.

Now consider the opposite screen:

```text
Monthly settlement burn rate: 100x       status: FIRING
traffic: 10 operations/month             failures: 1
```

The math can be correct and the page can still be poor. One of ten operations failed, so the bad ratio is 10%. Against a 99.9% objective, the sustainable bad ratio is 0.1%; `10% / 0.1% = 100x`. But should a person be woken immediately? That depends on the impact of the one operation, whether intervention can help, whether the signal is timely, and whether a ticket, automated recovery, or synchronous business workflow is better.

When you see an SLO panel, ask these questions in order:

1. What exact user operation is protected?
2. What events or time slices are eligible?
3. What makes one eligible item good?
4. Where is the observation made, and what can it miss?
5. Are good, total, unknown, and coverage values fresh and internally consistent?
6. What target and window were approved, by whom, and why?
7. What amount and unit of budget remains?
8. Is the budget currently burning, or is old failure merely still in the long window?
9. What action is expected, who is authorized, and can it reduce user harm now?
10. What does this evidence still not prove?

That sequence is the mental habit this chapter builds.

## Terms before commands

### Reliability

**Everyday meaning:** the product keeps doing the important thing people depend on.

**Precise meaning here:** the probability or proportion that a defined user operation satisfies defined success conditions over a declared population and time context.

**On-call relevance:** “the process is running” and “the user operation is reliable” are different statements. Reliability starts at the user contract, not the server dashboard.

### Service level indicator — SLI

**Everyday meaning:** the ruler used to measure one part of service quality.

**Precise meaning:** a carefully defined quantitative measure of service behavior. A common event-based form is:

```text
SLI = good eligible events / all eligible events
```

**On-call relevance:** if “good” or “eligible” is wrong, every SLO, budget, dashboard, alert, and policy conclusion built on it is wrong.

An SLI has two layers:

- **SLI specification:** vendor-neutral meaning, such as “the fraction of accepted checkout attempts that commit exactly once and return confirmation within two seconds.”
- **SLI implementation:** exact sources and query, such as edge accepted counter plus transaction-state event plus latency histogram, aggregated over defined labels.

The specification can remain stable while the implementation changes. Version both.

### Service level objective — SLO

**Everyday meaning:** the reliability level the service is trying to deliver.

**Precise meaning:** an approved target or range for an SLI over a declared compliance window.

```text
At least 99.9% of eligible checkout operations
will be good over each rolling 28-day window.
```

This statement contains:

- the SLI population and goodness contract;
- target `99.9%`;
- comparison “at least”;
- rolling window length `28 days`;
- implicit owners and policy that must be documented elsewhere.

**On-call relevance:** an SLO says how much imperfection is tolerable and creates a common basis for reliability versus delivery decisions. It is not a promise of zero incidents.

### Service level agreement — SLA

**Everyday meaning:** a service promise whose failure has an explicit consequence.

**Precise meaning:** a contract or agreement containing service objectives plus consequences, scope, measurement rules, exclusions, claim process, and authorized parties. Consequences may be credits, penalties, termination rights, escalation, or another explicit commitment.

**On-call relevance:** never infer an SLA breach from an internal SLO dashboard. Read the actual agreement and involve its legal/business owner. The target, measurement source, time window, exclusions, and consequence may differ.

Memory rule:

```text
SLI = what did we measure?
SLO = what level did we approve?
SLA = what explicit consequence was agreed?
```

### Eligible event

**Everyday meaning:** an operation allowed into this measurement.

**Precise meaning:** one event that satisfies the population inclusion contract. Examples: valid checkout attempts accepted at the public edge; scheduled pipeline partitions due in the interval; authenticated interactive searches not marked as load tests.

**On-call relevance:** eligibility defines the denominator. If failures disappear before eligibility is observed, the SLI can become healthier as the service becomes less reachable.

### Good event

**Everyday meaning:** one eligible operation met the user's important expectation.

**Precise meaning:** an eligible event that satisfies all declared goodness conditions—perhaps correctness **and** completion **and** latency.

**On-call relevance:** `HTTP 200` is not universally good. A successful status with stale stock, duplicate charge, partial result, or excessive latency may be bad for the chosen journey.

### Bad event

An eligible event that does not satisfy goodness. For a complete binary classification:

```text
bad = total eligible - good
```

This subtraction is valid only when every eligible event is represented exactly once and goodness is binary. Partial outcomes, duplicates, retries, and unknowns must be handled explicitly.

### Excluded event

An event deliberately outside the SLI population under a documented rule—such as a clearly marked authorized load test. Exclusion is not the same as failure or missing data.

Every exclusion needs a reason, owner, review, and abuse protection. “Exclude all incidents” makes an SLI meaningless.

### Unknown event

An event expected in the eligible population whose outcome cannot be classified because evidence is missing, late, conflicting, or corrupt.

Unknown does not mean good. Unknown also does not prove bad. A missing-data policy may conservatively count it against the objective, mark status invalid, or use a bounded estimate. Label the decision separately from the fact.

### Measurement coverage

The fraction of independently expected eligible events represented in the SLI implementation:

```text
coverage = observed eligible events / authoritative expected eligible events
```

Coverage requires a genuinely independent or more authoritative comparison. Two dashboards derived from the same broken counter are not independent.

### Availability

The proportion of events or time during which a defined operation is usable. Two common forms differ:

```text
event availability = good requests / eligible requests
time availability  = good sampled time / eligible sampled time
```

They weight harm differently. Event-based measurement weights busy periods more because more operations occur. Time-based measurement gives each sampled interval its declared weight.

### Latency

Elapsed time between defined start and end boundaries. “Request latency” is incomplete until you name boundaries: client send to response complete, edge accept to last byte, queue enqueue to durable processing, and so on.

For an SLO, a useful form is a threshold ratio:

```text
good = eligible requests completed correctly within 400 ms
total = all eligible requests
```

This is not the same question as “what is p99 latency?” The threshold ratio directly tells how many events met a known promise.

### Percentile and quantile

The 99th percentile is a value at or below which approximately 99% of observations fall. It is a latency value, such as `380 ms`, not a success percentage. Quantile uses a fraction (`0.99`); percentile uses a percentage (`99th`).

Do not average percentiles across instances. Precomputed percentiles do not contain enough information to reconstruct the combined distribution. Aggregate compatible histogram buckets or raw distributions, then calculate the percentile.

### Error budget

**Everyday meaning:** the amount of imperfection allowed before reliability must take priority.

For a ratio SLO:

```text
allowed bad fraction = 1 - SLO target
allowed bad events   = total eligible events × allowed bad fraction
remaining events     = allowed bad events - actual bad events
consumed fraction    = actual bad events / allowed bad events
```

For a 99.9% target, the allowed bad fraction is `0.001`, or `0.1%`.

**On-call relevance:** budget is a prioritization mechanism, not permission to deliberately harm users and not a performance score for individuals.

### Burn rate

How fast budget is consumed relative to the sustainable rate:

```text
burn rate = current bad-event ratio / (1 - SLO target)
```

- `0x`: no observed bad events in that valid window;
- `1x`: if sustained for a full objective window, exactly all budget is consumed;
- `2x`: full budget is consumed in half the window;
- `14.4x`: full budget is consumed in about `window / 14.4` if sustained.

Burn rate is dimensionless. The underlying bad ratio and lookback window still matter.

### Rolling window

A window continuously ending “now,” such as the last 28 days. As time advances, new data enters and old data leaves. Remaining budget can recover when a bad period rolls out, even without a new deployment.

### Calendar window

A fixed period such as July or a contractual quarter. It starts and ends at named boundaries. Budget often resets at the next period, subject to the exact agreement or policy.

### Time slice

A fixed interval, such as one minute, classified good or bad based on its own rule. A time-slice SLI is:

```text
good time slices / eligible time slices
```

It avoids high-traffic periods dominating, but a lightly bad minute and a completely failed minute may receive the same weight. Slice length and classification threshold become important policy choices.

### Precision, recall, detection time, and reset time

- **Precision:** fraction of notifications that correspond to significant actionable events.
- **Recall:** fraction of significant events that the alert detects.
- **Detection time:** delay from harmful condition to notification.
- **Reset time:** delay from recovery to alert clearing.

An alert that fires instantly on everything has fast detection and terrible precision. A 36-hour window may improve precision but reset long after recovery. Multi-window burn alerts balance these properties.

## Architecture map

An SLO is not one PromQL expression. It is a socio-technical control system:

```text
       USER AND BUSINESS BOUNDARY
       What operation matters? What harm is tolerable?
                         |
                         v
  +---------------- SLI SPECIFICATION ----------------+
  | eligible | good | bad | unknown | exclusions      |
  | boundaries | units | aggregation | required views |
  +----------------------------------------------------+
                         |
                         v
  client -> edge -> service -> dependency -> terminal state
     |         |          |           |             |
     +---------+----------+-----------+-------------+
                         evidence
                         |
                         v
  exporter -> collector -> time-series store -> recording rules
      |            |              |                 |
   counter      scrape/gap     raw samples      good/total rates
                         |
                         v
                 SLO EVALUATION
       target + window + budget + burn + coverage
                         |
            +------------+-------------+
            |                          |
            v                          v
      dashboard/report            page/ticket
            |                          |
            +------------+-------------+
                         v
             ERROR-BUDGET POLICY
  product owner + service owner + SRE + risk/contract owner
                         |
                         v
      continue / pause / stabilize / exception / escalate
                         |
                         v
               measured user outcome
```

The ownership boundaries matter:

| Boundary | Typical owner | Required decision |
|---|---|---|
| User need and harm | Product/business risk owner | Which journeys and failure levels matter? |
| Service behavior | Service engineering owner | What correct terminal behavior exists? |
| SLI implementation | Service and observability owners | Where and how are eligible and good events measured? |
| SLO target/window | Product, service, SRE, risk owners | Which tradeoff is approved and achievable? |
| Error-budget policy | Same accountable stakeholders | What changes when budget is threatened or exhausted? |
| SLA | Authorized business/legal/contract owners | What consequence and dispute process apply? |
| Alert route | On-call/service owners | Who can act, by when, using which safe control? |

No tool owns these decisions. “We use Grafana” describes presentation. “We use Prometheus” describes part of measurement. “We have an SLO” is true only when the complete control loop exists.

### Six layers to inspect

1. **Intent:** the user journey and risk decision.
2. **Semantics:** eligible and good definitions.
3. **Instrumentation:** events and counters at chosen boundaries.
4. **Transport and storage:** collection, timestamps, labels, retention, gaps.
5. **Computation:** queries, aggregation, target, window, budget, burn.
6. **Action:** dashboard, alert, policy, authorized response, verified outcome.

When a number looks wrong, locate the earliest layer where evidence diverges. Do not start by editing an alert threshold.

## Request or state path

Consider one checkout attempt.

```text
User clicks Pay
   |
   | operation_id=op-731; client starts timer
   v
Public edge accepts attempt ---------> eligible total +1
   |
   | request may retry; operation identity must survive
   v
Checkout validates cart
   |
   +--> inventory reservation
   +--> payment authorization
   +--> durable order commit
   |
   v
Exactly one terminal outcome
   |
   +--> correct commit + confirmation <= 2 s ----> good +1
   +--> rejection explicitly outside promise? --> classified rule
   +--> timeout / wrong / duplicate / partial ----> bad +1
   +--> evidence missing or conflicting ---------> unknown +1
```

### Attempt versus user operation

Suppose the client retries three times and the third attempt succeeds. Possible populations include:

- transport attempts: three total, two bad, one good;
- logical checkout operations: one total, perhaps good if completed within the user deadline;
- user sessions: one session, perhaps bad if the user abandoned before the retry succeeded.

None is universally correct. Choose the population matching the decision. Preserve operation identity so retries do not silently change what you count.

### Boundary placement

Measuring at the application is convenient but excludes requests that never arrive. Measuring only at the edge sees reachability but may not know durable business outcome. Measuring only the database sees commits but not user-visible confirmation latency.

A strong SLI may join or compare evidence from multiple boundaries:

```text
eligible: accepted at trusted public edge
good:     terminal order state is committed exactly once
          AND user confirmation completed within 2 seconds
coverage: edge eligible IDs reconciled with terminal outcome IDs
```

This is harder than `2xx / all HTTP`. It is also closer to the operation users buy.

### Counter path in Prometheus

For a request-based SLI, instrumentation often exposes monotonic counters:

```text
checkout_operations_total{outcome="good"} 1996800
checkout_operations_total{outcome="bad"}     3200
```

“Monotonic” means the counter normally increases until its process restarts. A collector scrapes samples. PromQL `rate(counter[window])` estimates average per-second increase and adjusts for counter resets detected within the range.

Conceptual recording rules:

```promql
sum without(instance, pod) (
  rate(checkout_operations_total{outcome="bad"}[5m])
)

/

sum without(instance, pod) (
  rate(checkout_operations_total{outcome=~"good|bad"}[5m])
)
```

The numerator and denominator are aggregated separately. Never average per-pod ratios: a quiet pod would receive the same weight as a busy pod.

### State path for a rolling window

At evaluation time `T`:

```text
window start = T - 28 days
include valid events whose event-time policy places them in [start, T]
drop events older than start
recalculate good / total and budget
```

Late events, backfill, clock corrections, and retention can revise historical state. A dashboard value is not immutable unless the system records a finalized snapshot under a declared policy.

## Failure zoom

### Failure family one: healthy components, broken journey

```text
edge 200 OK -> checkout 200 OK -> payment authorized
                                  |
                                  v
                         order commit failed
```

Infrastructure availability is green; the user has a charge without an order. A component SLO cannot substitute for the end-to-end journey.

First evidence:

- accepted operation IDs at the user boundary;
- terminal transaction states;
- correctness and idempotency reconciliation;
- confirmation latency and user-visible outcome;
- dependency and recent-change evidence.

### Failure family two: green because the denominator disappeared

```text
actual edge attempts:       10,000
application observed:        9,000
application good:            8,991

observed-only SLI = 8,991 / 9,000  = 99.9%
coverage          = 9,000 / 10,000 = 90.0%
```

The 99.9% is correct only for the observed subset. It does not represent all expected eligible attempts. If the thousand missing requests failed before application instrumentation, the green number hides the outage.

Safe conclusion: measurement is invalid or incomplete until reconciled. Under the lab's explicit conservative policy, `8,991 / 10,000 = 89.91%` is a lower bound for decisions. It does not prove the missing thousand failed.

### Failure family three: aggregate hides a cohort

```text
region-small: 100 / 100 = 100%
region-large: 891 / 900 =  99%

wrong unweighted mean: (100% + 99%) / 2 = 99.5%
right global ratio:     (100 + 891) / (100 + 900) = 99.1%
```

Even the correct global ratio can hide that one tenant, region, client version, or accessibility path is fully broken. Maintain a global objective for overall risk and segmented views/objectives for important cohorts. Avoid unbounded high-cardinality labels; choose controlled dimensions.

### Failure family four: p99 is averaged

```text
pod-a p99 = 100 ms, 100 requests
pod-b p99 = 900 ms, 10,000 requests
```

`(100 + 900) / 2 = 500 ms` is not the combined p99. Percentiles are order statistics, not additive values. Use aggregatable histograms with compatible buckets or a native histogram, sum distributions across the desired population, then compute the quantile. For a threshold SLO, directly compute the fraction at or below the threshold.

### Failure family five: long window keeps firing after recovery

The one-hour bad ratio remains above threshold because the incident is still in history. The five-minute ratio becomes healthy after recovery.

```text
long burn > 13.44x   true
short burn > 13.44x  false
page condition      false because true AND false = false
```

The long window preserves significance; the short window improves reset. User recovery still needs independent proof. An absent alert is not recovery evidence.

### Failure family six: missing traffic looks perfect

If no events arrive:

```text
good = 0
total = 0
SLI = 0 / 0 = undefined
```

Do not coerce undefined to `100%`. Determine whether zero traffic is normal, an ingestion gap, an upstream outage, or a complete reachability failure. Pair the SLI with traffic, coverage, and freshness signals.

### Failure family seven: correct budget, wrong policy

An exhausted budget triggers “freeze every change.” The freeze blocks the reliability fix and urgent security remediation while allowing an executive's feature through informally.

The arithmetic is not the failure. Governance is. A useful policy names:

- user-risk-increasing changes that pause;
- reliability and critical security exception paths;
- required evidence, canary, abort, rollback, and observation;
- approvers and escalation;
- expiry and re-review;
- how disagreements or invalid measurement are handled.

## Internals and state ownership

### Event-based mathematics

Let:

- `G` = good eligible events;
- `T` = total eligible events;
- `B = T - G` = bad events, only under complete binary classification;
- `S` = objective target as a fraction;
- `E = 1 - S` = sustainable bad fraction.

Then:

```text
SLI                    = G / T
actual bad ratio       = B / T
allowed bad events     = T × E
remaining budget       = (T × E) - B
budget consumed        = B / (T × E)
burn rate              = (B / T) / E
```

For the checkout fixture:

```text
G = 1,996,800 events
T = 2,000,000 events
B = 3,200 events
S = 0.999
E = 0.001

SLI                = 1,996,800 / 2,000,000 = 0.9984 = 99.84%
allowed bad        = 2,000,000 × 0.001     = 2,000 events
remaining          = 2,000 - 3,200         = -1,200 events
consumed           = 3,200 / 2,000         = 1.6 = 160%
burn               = 0.0016 / 0.001        = 1.6x
```

Always show the unit. `-1,200 events` and `-1,200 minutes` mean different harm.

### Floating-point and discrete-event rounding

Many languages cannot represent `0.999` exactly in binary floating point. A calculation may produce `2000.0000000000018`. Never let accidental truncation decide whether one real event is allowed.

Define a policy:

- store raw integer good and total counts;
- use decimal/rational arithmetic where decisions demand it;
- define whether partial budget permits a discrete bad event;
- preserve unrounded values for calculation and round only display;
- test boundary cases immediately below, at, and above the target.

The lab rounds display to six decimals but does not claim production numeric policy.

### Time-based availability mathematics

For 28 days:

```text
total minutes = 28 × 24 × 60 = 40,320 minutes
99.9% budget  = 40,320 × 0.001 = 40.32 bad minutes
```

If 47.5 bad minutes are observed:

```text
remaining = 40.32 - 47.5 = -7.18 minutes
availability = 1 - (47.5 / 40,320) ≈ 99.8822%
```

Sampling every 30 seconds does not provide continuous truth. It may miss failures between samples, round partial intervals, and represent only the synthetic path. Record sampling resolution and classification rules.

### Event versus time weighting

Imagine one hour:

```text
09:00-09:01: 100,000 requests, 10,000 failures
09:01-10:00: 1,000 requests, 0 failures
```

Event SLI:

```text
91,000 / 101,000 ≈ 90.10%
```

Minute-slice availability if only the first minute is bad:

```text
59 / 60 ≈ 98.33%
```

Both can be correctly calculated and answer different questions. The event SLI weights harmed operations; time slices weight minutes. Choose based on user impact, not the prettier number.

### Latency threshold and histogram state

For classic Prometheus histograms, `_bucket{le="0.4"}` is cumulative: it counts observations less than or equal to 0.4 seconds. `_count` counts all observations.

Conceptual threshold ratio:

```promql
sum(rate(search_duration_seconds_bucket{le="0.4"}[5m]))
/
sum(rate(search_duration_seconds_count[5m]))
```

This works only if:

- the bucket boundary `0.4` exists and matches the objective;
- eligible populations match numerator and denominator;
- errors are included or excluded according to the specification;
- label aggregation does not double count;
- counter resets and scrape gaps remain handled;
- units are seconds, so `0.4` means 400 milliseconds.

If the desired threshold lies between classic bucket boundaries, the exact fraction is unavailable. Redesign buckets or use an explicitly reviewed interpolation/alternative. Do not claim exactness.

### Rolling-window state

A rolling window is a moving population. If a bad day leaves the window, budget can improve even if today's service is merely average. If traffic grows, an event-based allowed count can grow because `T × E` grows. This does not erase user harm; it changes compliance under the declared population.

Store or reconstruct:

- window start/end and timezone;
- event-time versus processing-time rule;
- source versions and query version;
- late-arrival and backfill policy;
- finalized versus provisional status;
- objective version active for that interval.

### Calendar-window state

A calendar month has fixed boundaries but unequal duration across months. “99.9% monthly” permits different bad minutes in February and March. State the timezone and whether planned maintenance is eligible. Do not assume the contract excludes it.

### Burn-rate derivation

For a 99.9% SLO:

```text
sustainable bad ratio = 1 - 0.999 = 0.001
```

If current bad ratio is 2%:

```text
2% = 0.02
burn = 0.02 / 0.001 = 20x
```

If sustained, approximate time to consume a fresh full 28-day budget:

```text
28 days / 20 = 1.4 days
```

This is a constant-rate projection. Real traffic and failures vary, and existing consumption shortens the remaining time.

### Deriving a burn threshold from budget portion

If you want notification after consuming 2% of a 30-day budget in one hour:

```text
burn threshold = budget portion × objective window / alert window
               = 0.02 × 720 hours / 1 hour
               = 14.4x
```

This derivation is independent of the number of nines. The resulting absolute bad-ratio threshold still depends on the SLO:

```text
99.9% SLO: sustainable 0.001; threshold bad ratio = 14.4 × 0.001 = 1.44%
99.99% SLO: sustainable 0.0001; threshold bad ratio = 14.4 × 0.0001 = 0.144%
```

For the fixture's 28-day window, the same 2%-in-one-hour design is `0.02 × 672 / 1 = 13.44x`; the six-hour 5% tier is `5.6x`; and the three-day 10% tier is approximately `0.933333x`. Thresholds belong to the objective window. Do not mix the common 30-day values with a 28-day objective without stating that you intentionally chose a different budget portion.

### Multi-window state machine

For one paging tier:

```text
long_violation  = long_bad_ratio  / E > threshold
short_violation = short_bad_ratio / E > threshold
page_active     = long_violation AND short_violation
```

Multiple tiers combine with OR:

```text
(14.4x over 1h AND 14.4x over 5m)
OR
(6x over 6h AND 6x over 30m)
```

Long windows select material budget consumption. Short windows prove current activity and clear sooner after recovery.

### SLO and dependency composition

If a user journey requires independent serial dependencies, naive availability multiplication gives an optimistic planning approximation:

```text
journey availability ≈ A × B × C
```

Three dependencies each at 99.9% yield about `99.7003%`, assuming independence and aligned semantics. Real failures are often correlated, retries change load, and end-to-end correctness is not the product of component uptime. Measure the journey directly and use dependency objectives for diagnosis and planning.

### Who owns truth

No single record is absolute truth:

- edge counters own evidence of accepted traffic at that boundary;
- service counters own emitted classifications at their code version;
- durable state owns recorded terminal outcomes under its consistency model;
- synthetic probes own their scripted observation only;
- Prometheus owns stored samples and query results, not user intent;
- the SLO document owns approved semantics and target version;
- the policy record owns declared response, not whether the response worked;
- the contract owns SLA consequences, interpreted by authorized owners.

Senior judgment reconciles these owners instead of promoting one dashboard to reality.

## Evidence table

| Question | Evidence or command | Risk | Expected branches | Proves | Does not prove | Safest next evidence |
|---|---|---|---|---|---|---|
| What environment produced the result? | `id; uname -a; cat /etc/os-release; python3 --version; date -u ...; pwd` | Read-only | expected normal user / mismatch | local context | authorization or production parity | record mismatch or continue doctor |
| Is fixture structure valid? | `python3 ... validate-scenario ...` | Read-only | valid / refused | checked-in contract conformance | real SLI validity | inspect first error or setup |
| Is state exact and owned? | `bash lab.sh status` | Read-only | absent / ready / refused | local descriptor state | calculation meaning | setup, compare result count, or preserve |
| What event SLI and budget result? | `bash lab.sh run event-sli` | Bounded mutation | checkout exhausted / catalog compliant | declared arithmetic | population quality | eligibility and coverage evidence |
| What time budget exists? | `bash lab.sh run time-budget` | Bounded mutation | compliant / noncompliant | minutes under sampling rule | continuous availability | sample gaps and journey proof |
| Does latency threshold pass? | `bash lab.sh run latency` | Bounded mutation | within / beyond budget | threshold-event ratio | p99 or correctness | histogram and outcome evidence |
| Is telemetry complete? | `bash lab.sh run coverage` | Bounded mutation | valid / invalid | observed versus expected count | cause of missing events | boundary reconciliation |
| Is aggregation weighted? | `bash lab.sh run aggregation` | Bounded mutation | weighted differs / matches | fixture math | semantic combinability | label/population review |
| How fast is budget burning? | `bash lab.sh run burn` | Bounded mutation | below / at / above 1x | normalized current rate | future persistence | multiple windows and trend |
| Should a signal page or ticket? | `bash lab.sh run alerting` | Bounded mutation | both windows active / not active | fixture threshold state | actionability or delivery | user impact and receiver evidence |
| How should rare traffic change response? | `bash lab.sh run low-traffic` | Bounded mutation | high mathematical burn / human review | sparse-population math | page value | single-event impact and alternatives |
| What does exhausted policy permit? | `bash lab.sh run policy` | Bounded mutation | pause / exception path | fixture policy result | real authority | signed policy and approval record |

The table prevents a common operational error: treating one command as a verdict. Each command answers one bounded question and hands you to the next evidence boundary.

## Command decoders

### Decoder one: environment identity

Question: **Can another engineer understand where this evidence came from?**

```bash
# [READ-ONLY]
id
uname -a
cat /etc/os-release
python3 --version
date -u +%Y-%m-%dT%H:%M:%SZ
pwd
```

Representative output:

```text
uid=1000(learner) gid=1000(learner) groups=1000(learner),27(sudo)
Linux labhost 6.8.0-xx-generic #xx-Ubuntu SMP ... x86_64 GNU/Linux
PRETTY_NAME="Ubuntu 24.04 LTS"
VERSION_ID="24.04"
Python 3.12.x
2026-08-04T10:20:30Z
/work/reliability-atlas/book/labs/LES-0032-sli-slo-sla-error-budgets
```

Field by field:

- `uid=1000`: numeric user identity. The lab refuses `0`, which is root.
- `gid=1000`: primary group identity.
- `groups=...`: supplementary groups. Membership in `sudo` does not mean this command elevated.
- `Linux`: kernel family.
- `labhost`: hostname; sanitize real hostnames before sharing.
- `6.8...`: kernel release, relevant to behavior but not proof of distribution identity.
- `x86_64`: machine architecture.
- `PRETTY_NAME`: human display name from `/etc/os-release`.
- `VERSION_ID`: machine-useful distribution version.
- `Python 3.12.x`: interpreter chosen by `PATH`; record exact output.
- trailing `Z`: Coordinated Universal Time (UTC), avoiding local timezone ambiguity.
- `pwd`: current directory; commands using relative paths depend on it.

Trap: `date -u` proves only the host's reported clock, not synchronization. Compare with an approved time source when cross-system ordering matters.

### Decoder two: event result JSON

```bash
# [MUTATING / BOUNDED]
bash lab.sh run event-sli
```

Representative fragment:

```json
{
  "name": "checkout-completion",
  "goodEvents": 1996800,
  "totalEvents": 2000000,
  "badEvents": 3200,
  "sli": 0.9984,
  "target": 0.999,
  "allowedBadEvents": 2000.0,
  "remainingBudgetEvents": -1200.0,
  "budgetConsumedFraction": 1.6,
  "compliant": false
}
```

- `goodEvents`, `totalEvents`, `badEvents`: counts, not rates. Their unit is events over the fixture interval.
- `sli`: fraction from zero to one. Multiply by 100 for percent: `0.9984 = 99.84%`.
- `target`: approved-looking fixture value, not a real approval.
- `allowedBadEvents`: `total × (1 - target)`.
- `remainingBudgetEvents`: negative means actual bad count exceeded allowance.
- `budgetConsumedFraction`: `1.6` means 160%, not 1.6%.
- `compliant`: comparison under the exact fixture formula.

First safe interpretation: the fixture objective is noncompliant. Next evidence: validate that good and total describe the intended user population. The JSON cannot prove that.

### Decoder three: time-budget result

```json
{
  "windowMinutes": 40320,
  "allowedBadMinutes": 40.32,
  "observedBadMinutes": 47.5,
  "remainingBudgetMinutes": -7.18,
  "availability": 0.998822,
  "samplingResolutionSeconds": 30,
  "compliant": false
}
```

- `windowMinutes`: capacity of the window, not observed traffic.
- `allowedBadMinutes`: mathematical allowance.
- `observedBadMinutes`: result of the fixture's sampling/classification process.
- `remainingBudgetMinutes`: allowance minus observed.
- `availability`: a ratio; display is approximately 99.8822%.
- `samplingResolutionSeconds`: evidence granularity. A 12-second failure may be missed or rounded depending on probe timing.

Trap: a “downtime calculator” silently assumes time-based continuous availability. It is not interchangeable with an event-based user SLO.

### Decoder four: latency-threshold result

```json
{
  "thresholdMilliseconds": 400,
  "goodEvents": 98750,
  "totalEvents": 100000,
  "sli": 0.9875,
  "target": 0.99,
  "budgetConsumedFraction": 1.25
}
```

Read it aloud: “98.75% of the declared eligible events completed within the 400-millisecond goodness boundary; the objective asks for 99%; 125% of the allowed slow-event budget was consumed.”

Do not say “p99 is 400 ms.” This result does not reveal p99. The actual p99 could be above 400 ms, and its exact value requires the distribution.

### Decoder five: coverage result

```json
{
  "authoritativeEligibleEvents": 10000,
  "observedEligibleEvents": 9000,
  "missingEvents": 1000,
  "coverageRatio": 0.9,
  "observedOnlySli": 0.999,
  "conservativeSli": 0.8991,
  "measurementValid": false
}
```

Interpret combinations:

- high observed SLI + low coverage = unreliable verdict;
- low observed SLI + full coverage = supported service-quality problem, still not root cause;
- low observed SLI + low coverage = both service and measurement hypotheses remain;
- high SLI + full count coverage = stronger, but semantics, correctness, duplication, and segmentation remain.

`conservativeSli` treats all unknowns as not good under the fixture policy. It is a lower bound, not evidence that 1,000 failed.

### Decoder six: weighted aggregation

```json
{
  "weightedGoodOverTotal": 0.991,
  "unweightedMeanOfRatios": 0.995,
  "correctMethod": "sum-good-divided-by-sum-total"
}
```

Why `0.991`:

```text
(100 + 891) / (100 + 900) = 991 / 1000 = 0.991
```

Why `0.995` is wrong for global event success:

```text
(1.00 + 0.99) / 2 = 0.995
```

The mean gives the 100-event region half the weight and the 900-event region half. That is not the event population.

Still keep per-region evidence. A weighted global value answers overall event fraction, not equitable experience.

### Decoder seven: burn result

```json
{
  "sustainableErrorRate": 0.001,
  "actualErrorRate": 0.0016,
  "burnRate": 1.6,
  "budgetExhaustionDaysIfSustained": 17.5
}
```

- `sustainableErrorRate`: budget fraction per event, not errors per second.
- `actualErrorRate`: bad events divided by eligible events in the declared population.
- `burnRate`: dimensionless ratio of those two rates.
- `budgetExhaustionDaysIfSustained`: 28 / 1.6. It assumes a fresh budget and constant rate.

Burn is not “time remaining” when part of the budget is already consumed. For current runway, use remaining budget and current valid event rate with explicit assumptions.

### Decoder eight: multi-window alert result

```json
{
  "name": "page-fast",
  "longWindow": "1h",
  "shortWindow": "5m",
  "longBurnRate": 20.0,
  "shortBurnRate": 25.0,
  "threshold": 13.44,
  "severity": "page",
  "active": true
}
```

The long rate exceeds 13.44 and the short rate exceeds 13.44. The AND condition is true. If the short rate were `0.2x`, the page would clear even while the one-hour rate retained incident history.

Threshold crossing proves rule state only. Before paging is considered successful, verify:

- notification was delivered to the intended route;
- a qualified responder acknowledged;
- the alert contains a user impact, urgency, safe action, and dashboard/runbook;
- action can reduce harm before budget exhaustion;
- duplicate notifications are inhibited.

### Decoder nine: low-traffic output

```json
{
  "totalEvents": 10,
  "badEvents": 1,
  "errorRate": 0.1,
  "burnRate": 100.0,
  "automaticActionAllowed": false,
  "decision": "human-impact-and-measurement-review-required"
}
```

The burn math is correct. The decision is not automatic because the sample is sparse. Ask:

- Is one failure catastrophic, reversible, retried, or merely delayed?
- Will waking someone now improve this event?
- Is the event already over before detection?
- Can a synthetic journey provide earlier evidence?
- Can related operations form a meaningful population without hiding a critical path?
- Should the product reduce single-event impact?

### Decoder ten: policy output

```json
{
  "budgetExhausted": true,
  "decision": "pause-user-risk-increasing-change-and-prioritize-reliability",
  "actions": {
    "new recommendation dependency in checkout": "pause",
    "idempotency fix with canary and rollback": "eligible-through-reviewed-exception",
    "critical credential-rotation control": "eligible-through-reviewed-emergency-path"
  }
}
```

The action values are policy categories, not commands. “Eligible” does not mean approved or safe. A real exception still needs authorization, scoped canary, abort, rollback, observation, and outcome proof.

### Decoder eleven: exit status

```bash
# [MUTATING / BOUNDED]
bash verify.sh
printf 'exit=%s\n' "$?"
```

Representative success:

```text
verification=passed lesson=LES-0032 cases=9 assertions=24 refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only
exit=0
```

- exit `0`: every encoded check passed.
- nonzero: at least one check or cleanup condition failed; preserve the first error.
- `cases=9`: all named model paths ran.
- `assertions=24`: fixed semantic output checks ran; this is not test coverage percentage.
- `refusals=...`: cleanup rejected two ambiguous child types.
- `final_state=absent`: the exact expected directory is absent after verification.

### Decoder twelve: production PromQL shape

Conceptual recording rules for a 5-minute bad ratio:

```promql
sum without(instance, pod) (
  rate(checkout_operations_total{outcome="bad"}[5m])
)
/
sum without(instance, pod) (
  rate(checkout_operations_total{outcome=~"good|bad"}[5m])
)
```

Token by token:

- `checkout_operations_total`: counter name; `_total` convention suggests monotonic counter semantics.
- `{outcome="bad"}`: exact label matcher selecting bad outcomes.
- `[5m]`: range vector containing samples from the prior five minutes.
- `rate(...)`: estimated average per-second counter increase across the range, with reset handling.
- `sum without(instance, pod)`: aggregate away replica identity while preserving other labels.
- `/`: vector division; label sets must match after aggregation.
- `outcome=~"good|bad"`: regular-expression matcher selecting the complete binary eligible population.

What it cannot prove:

- the counter increments exactly once per user operation;
- edge failures are included;
- outcome semantics are correct;
- traffic is complete and fresh;
- preserved labels do not split numerator and denominator unexpectedly;
- the five-minute result represents a 28-day SLO;
- the query is deployed, evaluated, routed, or reviewed.

Use `promtool check rules` against a pinned reviewed Prometheus version before deployment, then unit-test boundary series and evaluate on representative data. This chapter does not execute that provider runtime.

## Decision path

Use this path when designing or debugging an SLO.

### Step one: name the user operation

Bad question: “What SLO should the API have?”

Better question: “Can a merchant submit one valid checkout and receive one durable correct confirmation before their two-second patience boundary?”

If you cannot name the operation, stop. Component metrics can support diagnosis but not replace user intent.

### Step two: define the population before the target

Write:

```text
eligible =
good =
bad =
partial =
retry =
duplicate =
excluded =
unknown =
```

Make examples for every branch. A definition that cannot classify realistic edge cases is not ready.

### Step three: choose observation boundaries

Rank sources by proximity to the user result and independence:

1. terminal business outcome plus user confirmation;
2. trusted edge acceptance plus operation correlation;
3. application counter;
4. dependency/component metric;
5. process/host health.

Often you need several. Record what each misses.

### Step four: validate measurement

Before calculating SLO status, test:

- count conservation across boundaries;
- coverage and freshness;
- counter monotonicity and resets;
- retry and duplicate identity;
- clock and interval alignment;
- label/filter equivalence;
- event-time and late-arrival rules;
- query errors and absent series;
- segmentation and cardinality;
- correctness samples independent of the metric.

If measurement is invalid, status is **unknown/invalid**, not automatically good or bad.

### Step five: establish a baseline without normalizing harm

Observe representative periods across peak, quiet, deployment, dependency degradation, and recovery. Baseline tells what exists; it does not decide what users deserve.

Use user research, support evidence, business harm, contractual needs, dependency constraints, engineering feasibility, and cost to propose a target.

### Step six: choose target and window

Ask:

- At what failure level do users change behavior or suffer material harm?
- Does the service have enough volume for event ratios?
- Does the window match decision cadence and seasonality?
- Can the architecture and dependencies realistically support the target?
- What does each extra nine cost?
- Can monitoring and response act before a catastrophic outage consumes the budget?
- Is there an internal margin below an external commitment?

Do not choose `99.9%` because it looks standard.

### Step seven: approve the objective and policy together

An SLO without policy is a report. Record:

- authors, technical reviewers, business approvers;
- exact SLI specification and implementation version;
- target, comparison, window, timezone, rounding, missing data;
- budget calculation and current source;
- feature, reliability, security, and emergency actions;
- escalation and dispute path;
- effective date, expiry, review date, and change history.

### Step eight: design alerts from response need

Page only when:

- user or imminent hard-limit harm is material;
- intervention is urgent;
- a qualified responder can perform a safe useful action;
- the alert arrives before that action becomes pointless;
- evidence is valid enough to justify interruption.

Use multi-window burn tiers as starting points, then test on your traffic and incidents. Route slow burns to owned work rather than waking someone.

### Step nine: respond to a burn

```text
validate signal
  -> declare/coordinate incident if needed
  -> segment user harm
  -> stabilize through reviewed controls
  -> verify user recovery independently
  -> preserve budget and timeline evidence
  -> invoke policy through authorized owners
  -> remove contributing causes
  -> verify resulting reliability
```

Do not begin with “tune alert.” A noisy alert can indicate poor alert logic, invalid measurement, or a real service with unacceptable frequent harm.

### Step ten: review the control loop

At the scheduled review, ask:

- Does the SLI still represent the product?
- Which user cohorts are hidden?
- How often was measurement invalid?
- Did alerts have precision, recall, useful detection, and reset?
- Did policy decisions occur consistently and improve outcomes?
- Did the service deliberately overperform, creating dependency expectations?
- Did target changes follow evidence and approval?
- Do references, providers, queries, and contracts need version review?

## Guided Ubuntu lab

The lab is a calculator with guardrails, not a monitoring stack. That is deliberate: first learn the invariants without installation, network, or provider noise. Later production transfer adds Prometheus and platform specifics.

### Environment card

| Item | Value |
|---|---|
| Tested design target | Ubuntu 24.04 LTS; WSL 2 Ubuntu 24.04 supported by design |
| Expected time | 120–150 minutes with written predictions |
| User | Normal user; root refused |
| Required tools | Bash, Python 3, `id`, `mktemp`, `readlink`, `stat`, `find` |
| Network | None |
| CPU/RAM | One short-lived Python process; under 128 MiB expected |
| Disk | Under 1 MiB in `/tmp/reliability-atlas-les0032-<uid>` |
| Ports | None |
| Changes | Exact temporary directory, copied fixture, manifest, sentinel, result JSON |
| Abort | Root, invalid fixture, ambiguous state, unexpected/symlink child, mismatched arithmetic, or uncertain cleanup |
| Cleanup | Descriptor-validated removal and exact absence proof |

### Preflight

```bash
# [READ-ONLY]
id
command -v bash
command -v python3
command -v readlink
python3 fixtures/slo_model.py validate-scenario fixtures/scenario.json
bash lab.sh doctor
```

If a command is missing, do not install automatically. On reviewed Ubuntu 24.04, Bash is from `bash`, Python from `python3`, and `readlink`/`stat` from `coreutils`. Package installation is outside this no-network lab and requires separate approval.

### Prediction sheet

Before running a case, write your prediction:

| Case | Prediction | Formula | Unit | What would surprise me? |
|---|---|---|---|---|
| event-sli |  |  | events / fraction |  |
| time-budget |  |  | minutes / fraction |  |
| latency |  |  | events / milliseconds |  |
| coverage |  |  | events / fraction |  |
| aggregation |  |  | events / fraction |  |
| burn |  |  | dimensionless / days |  |
| alerting |  |  | burn multiple / state |  |
| low-traffic |  |  | events / fraction |  |
| policy |  |  | decision category |  |

Prediction makes the lab diagnostic. Without it, surprising output can pass unnoticed.

### Setup and state

```bash
# [MUTATING / BOUNDED]
bash lab.sh setup

# [READ-ONLY]
bash lab.sh status
```

Expected shape:

```text
state=ready existing=false path=/tmp/reliability-atlas-les0032-1000
state=ready path=/tmp/reliability-atlas-les0032-1000 case=slo-control-loop-v1 results=0 runtime=deterministic-model-only
```

Your UID will differ. `results=0` is a count of result files, not successful tests.

### Experiment one: event budgets

```bash
# [MUTATING / BOUNDED]
bash lab.sh run event-sli
```

Answer before reading onward:

1. Why is checkout noncompliant even though 99.84% sounds high?
2. Why does catalog retain 1,000 bad events of budget?
3. What must be true before either conclusion transfers to production?

Model answer:

1. The decision is relative to an approved target. Checkout asks for 99.9%, permits about 2,000 bad events, and contains 3,200. It consumed 160%.
2. Catalog target 99.5% permits `400,000 × 0.005 = 2,000`; actual bad is 1,000; remaining is 1,000.
3. Eligibility, goodness, coverage, uniqueness, interval, query, target approval, and policy must all be valid. Fixture arithmetic proves none of those production facts.

### Experiment two: time budget

```bash
# [MUTATING / BOUNDED]
bash lab.sh run time-budget
```

Change nothing. Calculate manually:

```text
28 × 24 × 60 = 40,320 minutes
40,320 × 0.001 = 40.32 allowed minutes
40.32 - 47.5 = -7.18 minutes
```

Then ask: with a 30-second probe, how are 10-second failures represented? The output cannot answer. That missing rule is part of SLI implementation.

### Experiment three: latency threshold

```bash
# [MUTATING / BOUNDED]
bash lab.sh run latency
```

Translate the JSON into one precise sentence without using “p99.” If you say “99% of requests were under 400 ms,” correct yourself: the actual ratio is 98.75%, while 99% is the target.

### Experiment four: coverage failure

```bash
# [MUTATING / BOUNDED]
bash lab.sh run coverage
```

Draw two boxes:

```text
expected at edge: 10,000
observed in SLI:   9,000
```

Write at least four hypotheses for the missing thousand:

- edge/app filters differ;
- requests failed before app instrumentation;
- telemetry was dropped or delayed;
- events are duplicated at the edge;
- time windows or clocks differ;
- one deployment version stopped emitting;
- label change split the query.

For each, write evidence that would reject it. That turns guessing into troubleshooting.

### Experiment five: aggregation

```bash
# [MUTATING / BOUNDED]
bash lab.sh run aggregation
```

Recalculate both values. Then explain why even `99.1%` may need region views. Correct global math does not guarantee fair or safe segment experience.

### Experiment six: burn

```bash
# [MUTATING / BOUNDED]
bash lab.sh run burn
```

Say the result correctly:

> “Over the declared fixture population, bad-event ratio is 0.16%, which is 1.6 times the 0.1% sustainable bad ratio for a 99.9% objective. If a fresh 28-day budget burned constantly at that rate, it would exhaust in 17.5 days.”

Do not say “the service will fail in 17.5 days.”

### Experiment seven: multi-window alert state

```bash
# [MUTATING / BOUNDED]
bash lab.sh run alerting
```

Inspect `recovered-spike`: long burn is high, short burn is below threshold, so active is false. This is the reset-time reason for the short window.

For each active signal, decide whether the fixture says `page` or `ticket`. It does not prove those destinations are appropriate for your organization.

### Experiment eight: low traffic

```bash
# [MUTATING / BOUNDED]
bash lab.sh run low-traffic
```

The model refuses automatic action. Write two cases:

- one failed monthly operation transfers a billion-dollar settlement incorrectly—immediate human/automated control may be justified;
- one operation is delayed five minutes and automatically retries before user deadline—paging may add no value.

The same burn number can imply different response because user impact and recoverability differ.

### Experiment nine: policy

```bash
# [MUTATING / BOUNDED]
bash lab.sh run policy
```

Notice that reliability and security changes are “eligible through” paths, not auto-approved. Write the evidence required for each: owner, risk, canary, scope, abort, rollback, observation, and independent user verification.

### Full verification and cleanup

```bash
# [MUTATING / BOUNDED]
bash verify.sh

# [READ-ONLY]
bash lab.sh status
```

Expected final lines:

```text
verification=passed lesson=LES-0032 cases=9 assertions=24 refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only
state=absent path=/tmp/reliability-atlas-les0032-<uid>
```

If verification fails, preserve the first failure. The exit trap attempts safe cleanup. If cleanup refuses ambiguous state, do not use a broad recursive delete; inspect the exact path, owner, type, sentinel, and unexpected child.

### Lab proof ledger

| Claim | Status after a passing run |
|---|---|
| Fixture schema and relationships match model | Supported for checked-in files |
| Nine deterministic outputs match 24 assertions | Supported on recorded environment |
| Unexpected and symlink children are refused | Supported by two injected cases |
| Exact state is absent after cleanup | Supported at final check |
| Real Prometheus query is correct | Not tested |
| Real SLI represents users | Not tested |
| Stakeholders approved target/policy | Not tested |
| SLA consequence applies | Not tested |
| Learner can transfer independently | Requires ASM-0081 review |

## Production transfer

### Container transfer

Containers add boundaries, not different mathematics.

Check:

- Is the counter per process, container, pod, or logical operation?
- Do restarts reset counters, and does `rate` see enough samples?
- Are sidecars and retries double counting?
- Does a container disappear before its final samples are scraped?
- Are labels stable across rollout?
- Does host or service-mesh instrumentation observe failures the application misses?

Trap: “all containers ready” is not an SLI for checkout completion. Readiness is a control-plane condition.

### Kubernetes transfer

Map the path:

```text
client -> external load balancer -> ingress/gateway -> Service -> Pod
                                                   -> dependencies
```

Potential evidence:

- gateway request totals for public eligibility;
- application operation outcomes for correctness;
- durable state reconciliation;
- synthetic end-to-end journey;
- Kubernetes state for diagnosis, not user success.

Rollouts create mixed versions. Include controlled `version` evidence for diagnosis, but avoid turning every deployment hash into permanent SLO cardinality. Recording rules often remove `pod` and `instance`, preserve service/journey/region, and keep version only in short-lived investigative views.

Before changing a rule in a real cluster:

1. identify namespace, rule owner, evaluator, and deployment path;
2. validate syntax using the pinned provider tool;
3. unit-test counter reset, missing series, zero traffic, partial traffic, boundary threshold, and label mismatch;
4. use `kubectl diff -n <namespace> -f <reviewed-file>` where the deployment workflow permits;
5. canary or shadow-evaluate the new rule;
6. compare old/new raw numerators and denominators;
7. preserve rollback and alert inhibition;
8. verify user and routing behavior.

This is a design path, not authorization to touch a cluster.

### Public-cloud transfer

Cloud SLO products may support request-based or time-window objectives, rolling or calendar periods, provider-specific selectors, and burn alerts. Do not translate names blindly.

Review:

- provider's exact good/total filter semantics;
- metric kind, alignment, reducer, and missing-data behavior;
- ingestion delay and data correction;
- maximum alert lookback and compliance-period approximation;
- service identity and project/account scope;
- Infrastructure as Code plan/diff;
- notification-channel permissions and secrets;
- cost of metric volume, retention, query, and alerts;
- export/portability of raw evidence and SLO specification.

A provider resource proves configuration exists. It does not prove the objective is fit or the alert reaches a useful human.

### Private-cloud and virtualization transfer

For virtual machine or private-cloud platforms, users may be internal teams. Journeys can include:

- create a virtual machine within ten minutes;
- attach a volume without data corruption;
- resolve a private service name;
- live-migrate within disruption threshold;
- restore a tenant from backup within recovery objectives.

Do not make hypervisor uptime the only SLI. A healthy hypervisor with a broken control plane, exhausted address pool, invalid image, failed storage attach, or stale catalog can block the user journey.

### Data-platform transfer

Availability alone is weak for batch and streaming systems. Define:

- **freshness:** output age below a threshold;
- **completeness:** expected records/partitions represented;
- **correctness:** validated results satisfy invariants;
- **latency:** event or job completion before deadline;
- **durability:** acknowledged data survives declared failure;
- **coverage:** sources and partitions observed.

Example:

```text
good partition = complete AND validated AND published by 06:00 UTC
total partition = every scheduled tenant/date partition due today
```

An Airflow task marked successful is orchestration state, not proof the dataset is complete or correct.

### Machine-learning platform transfer

Possible journeys:

- feature retrieval returns correct version within latency threshold;
- training job starts within queue objective and produces validated artifact;
- model deployment reaches declared traffic with correct policy and rollback;
- online inference returns valid output within latency and safety constraints.

Model quality, fairness, and safety are not automatically reducible to infrastructure availability. Use domain-approved evaluation and governance alongside operational SLOs.

### SLA transfer

Before communicating contractual status, obtain:

- signed agreement and effective version;
- covered service, users, regions, tiers, and operations;
- measurement source and dispute priority;
- target and calculation period;
- planned maintenance and force-majeure language;
- exclusions and claim process;
- consequence and cap;
- authorized legal/business interpretation.

Never paste confidential contracts or customer data into this repository or an AI tool.

## Reliability, security, observability, capacity, and cost

### Reliability consequences

A well-designed SLO:

- aligns teams around user harm;
- permits deliberate risk instead of impossible perfection;
- prioritizes reliability work when evidence warrants it;
- prevents every component symptom from becoming a page;
- exposes when architecture cannot defend the requested target.

A poor SLO can be worse than none because it lends false authority to an invalid number.

### Security consequences

SLO telemetry can contain sensitive dimensions:

- tenant or customer identity;
- endpoint names revealing business operations;
- region and infrastructure topology;
- error reasons exposing internal logic;
- trace exemplars linking to request metadata.

Use controlled labels, least-privilege access, retention limits, encryption, audit logs, and sanitized incident evidence. Never put secrets, payment data, tokens, email addresses, or unbounded user identifiers in metric labels.

Error-budget policies need a critical security exception path. Security work is not automatically “feature change,” and freezing a required credential or vulnerability control can increase risk. Exceptions must remain reviewed and bounded.

### Observability consequences

SLOs require meta-observability:

- Is the SLI source being scraped?
- Is the rule evaluating successfully?
- Is data fresh?
- Did counters reset?
- Is coverage complete?
- Did cardinality or label shape change?
- Did the alert reach its route?
- Is the dashboard using the same objective version?

Monitor the monitor, but avoid infinite recursion. Use independent signals for critical blind spots: edge counts versus application counts, synthetic versus internal, configuration registry versus runtime rule.

### Capacity consequences

High load may increase queueing and latency; retries can amplify load and burn budget faster. Capacity planning should model:

- demand distribution and peak;
- service time and concurrency;
- queue length and deadlines;
- dependency limits;
- retry multiplier;
- failure-mode capacity;
- headroom needed for rollout, evacuation, or repair;
- degradation/fallback behavior.

An SLO miss may be a capacity symptom. An SLO target also imposes capacity and redundancy cost.

### Cost consequences

Costs include:

- instrumentation development and maintenance;
- time-series cardinality and retention;
- query and rule evaluation;
- synthetic traffic;
- storage of raw evidence;
- high availability and redundancy;
- engineering work to defend extra nines;
- on-call interruption from poor alert precision;
- opportunity cost of paused feature work;
- user and contractual cost of failure.

Do not optimize monitoring cost by deleting the denominator or critical cohort. Reduce unnecessary labels, aggregate safely, tier retention, and preserve the evidence needed for decisions.

### Extreme targets

At 99.999% over 30 days, time allowance is about 25.92 seconds. A complete outage can consume it faster than metric collection, rule evaluation, routing, acknowledgement, and human action.

The solution is architectural:

- isolate failure domains;
- reduce change exposure with tiny canaries;
- use redundancy and tested failover;
- bound retries and overload;
- build safe fallback;
- prevent correlated dependency failure;
- verify rollback and recovery continuously.

Paging faster cannot compensate for an objective whose entire budget disappears before detection.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| Start with available metrics | Optimizes measurement convenience, not user need | Define journey and goodness before implementation |
| Treat `2xx` as success | Correctness, partial state, latency, and durability may fail | Use terminal user/business outcome conditions |
| Ignore denominator loss | Missing bad events make SLI look healthier | Track independent coverage and unknown policy |
| Count retries as users | One harmed operation becomes several events | Preserve logical operation identity |
| Exclude incidents | Deletes the exact failures the SLO should govern | Narrow, versioned, reviewed exclusions only |
| Average percentages | Misweights groups with different volumes | Sum good and total separately |
| Average percentiles | Combined distribution cannot be recovered | Aggregate compatible histograms, then quantify |
| Use average latency | Hides long-tail users | Threshold ratios and reviewed percentiles |
| Convert no traffic to 100% | Undefined becomes falsely green | Explicit absent/unknown state and traffic signal |
| Use one short alert window | High recall, poor precision, noisy pages | Budget-significant long window plus short active window |
| Use only one long window | Slow reset and stale paging | Multi-window AND logic |
| Add `for: 1h` as a substitute | Severe outage waits the same hour and spikes can reset timer | Use burn magnitude and windows designed for budget portion |
| Copy 14.4/6 blindly | Starting values may not suit traffic, impact, or window | Derive, simulate, backtest, and review |
| Page on every SLO miss | Some misses are not urgent or actionable | Page on significant active threats; ticket slower work |
| Treat budget as permission | Users can be harmed even within allowance | Budget governs priority, not ethics or safety |
| Treat exhaustion as punishment | Hides problems and creates political exceptions | Pre-agreed non-blaming risk policy |
| Freeze every change | Blocks reliability/security fixes | Defined controlled exception paths |
| Raise target after incident | Adds cost without proving user need or feasibility | Joint evidence-based review |
| Confuse SLO and SLA | Creates unsupported legal/financial claims | Inspect explicit consequences and authorized agreement |
| Trust config existence | Deployed YAML may be wrong or inactive | Runtime rule, raw data, delivery, and outcome proof |
| Claim mastery from lab | Model repetition is not independent transfer | Unseen case, reviewer, delayed recall, production-safe evidence |

### Prevention review questions

- Can a new engineer classify ten realistic edge cases using the specification?
- Can you reconstruct the displayed ratio from raw counts?
- Can you detect when the denominator stops arriving?
- Can you prove numerator and denominator share interval and labels?
- Can you explain every exclusion to a harmed user?
- Can the on-call act before budget exhaustion?
- Does the page clear after verified recovery?
- Can reliability and security fixes proceed safely when budget is exhausted?
- Is an SLA claim traceable to the actual agreement?
- Can another team reproduce the decision without private chat history?

## Memory card and retrieval

### One-minute memory card

```text
Start with the user operation.

SLI = good eligible / all eligible
SLO = approved SLI target + window
SLA = agreement + explicit consequences

budget rate = 1 - target
allowed bad = total × budget rate
remaining = allowed - actual bad
burn = current bad ratio / budget rate

Validate population, coverage, freshness, resets, retries,
aggregation, segments, and missing data before status.

Long window = significant.
Short window = still active.
Page only when urgent, actionable, and delivered.

Budget changes priorities through policy.
It does not prove cause, authorize change, or establish SLA breach.
```

### Retrieval questions

1. Why can an application-only success ratio improve during an edge outage?
2. What is the difference between SLI specification and implementation?
3. What explicit property usually separates an SLA from an SLO?
4. Calculate the allowed bad events for 500,000 events at 99.95%.
5. Why must ratios be aggregated from numerator and denominator?
6. Why can a correct global SLI still hide serious harm?
7. What does `burn rate = 6x` mean?
8. Why pair long and short burn windows with AND?
9. What should zero traffic produce?
10. Why is a threshold latency SLI not the same as p99?
11. What does an exhausted budget permit?
12. What evidence turns an SLO dashboard into a decision system?

### Retrieval answers

1. Requests failing before application instrumentation disappear from both good and total; the observed subset can remain healthy while user reachability falls.
2. Specification defines vendor-neutral population and goodness; implementation defines concrete sources, labels, query, aggregation, and pipeline.
3. Explicit consequences of meeting or missing the covered objectives, within an agreement.
4. Budget fraction is `0.0005`; `500,000 × 0.0005 = 250 bad events`, subject to declared discrete rounding.
5. Group volumes differ. Mean percentages assigns equal group weight; `sum(good)/sum(total)` weights each event once when semantics match.
6. High-volume healthy cohorts can dominate a small fully broken cohort. Preserve important segmented views.
7. Current valid bad ratio is six times the sustainable ratio; if a fresh full-window budget burned constantly at that rate, it would exhaust in about one-sixth of the window.
8. Long selects significant consumption; short confirms current activity and improves reset after recovery.
9. Undefined/absent with a declared missing-data response, plus traffic/coverage evidence—not automatic 100%.
10. Threshold SLI is the fraction meeting a boundary; p99 is the latency value below which roughly 99% fall.
11. Whatever the approved policy says, commonly pausing user-risk-increasing change while allowing reviewed reliability and urgent security exceptions. It authorizes nothing by itself.
12. Valid user-centered measurement, approved target/window, explicit owners, actionable alerting, signed policy, executed decisions, and verified user outcomes.

### Spaced-recall schedule

- **Today:** calculate all nine fixture cases without copying output.
- **Tomorrow:** redraw the decision chain and explain unknown versus bad.
- **In seven days:** design one SLI for a batch pipeline and one for a user API.
- **In thirty days:** solve a materially different unseen case under review.
- **In ninety days:** defend target, window, alert, and policy tradeoffs from memory, then inspect current primary sources.

Reading completion is not mastery evidence.

## Complete answers

### How do I define my first SLO?

**Direct answer:** choose one critical user journey, define eligible and good events precisely, implement raw good/total plus coverage, observe representative behavior, agree an evidence-based target and window with accountable stakeholders, and sign an error-budget policy before using it for decisions.

**First-year foundation:** imagine an online shop. Users care that checkout completes correctly, not that a container is running. Count every valid checkout attempt accepted at the public boundary. Call one good only if the order commits exactly once and confirmation arrives within the chosen time. Count good and total. Compare totals with an independent source so missing telemetry is visible. After observing real patterns and discussing user/business harm, set a starting objective—for example, but not automatically, 99.9% over 28 days. Document what happens when budget is low. Review and refine.

**Senior production answer:** establish service and user ownership first. Map critical journeys and failure domains; select a small set of representative indicators across availability, latency, correctness, freshness, or durability. Write versioned specification/implementation pairs, reason-coded exclusions, missing-data and late-arrival policy, counter/reset and aggregation rules, controlled cohort views, and independent coverage. Backtest on representative periods and known incidents. Model target feasibility against dependencies, architecture, measurement resolution, detection/response time, user harm, contractual needs, and marginal cost. Have product-risk, service, SRE, and required security/legal owners approve target, rolling/calendar window, numeric rounding, and change policy with exceptions/escalation. Deploy via tested rules and shadow comparison, then measure alert quality and whether policy actions improve user outcomes. Schedule review; never equate publication with validity forever.

### Should every microservice have an SLO?

**Direct answer:** not necessarily. Start with user journeys and critical platform capabilities. Add component objectives when they support ownership, dependency planning, diagnosis, or an internal service contract.

**Foundation:** hundreds of microservice SLOs can create dashboards and pages without protecting users. One checkout journey may cross ten services. Measure checkout end to end, then use component evidence to explain failure.

**Senior answer:** maintain a tiered model: product-journey objectives for user/business risk; platform capability objectives for internal customers; component indicators for dependency budgets and diagnosis. Avoid mechanically cascading equal nines. Serial dependencies, correlated failures, fallbacks, retries, and shared infrastructure break naive allocation. Component SLOs should have consumers, decisions, owners, and manageable cardinality. Retire objectives that drive no action.

### Is 100% reliability the best target?

**Direct answer:** usually no. It leaves no error budget, can demand unbounded cost, slows safe change, and may exceed what users or dependencies require. Some safety or correctness constraints can still be non-waivable.

**Foundation:** every change has risk, and perfect measurement is impossible. If users are equally satisfied at 99.95% and 100%, spending ten times more for the final fraction may waste resources that could improve correctness or security.

**Senior answer:** separate statistical service objectives from invariants. A payment must never double-charge; that is not permission for a 0.1% duplicate rate. The availability journey may have an error budget, while safety/security/correctness controls remain hard constraints with fail-closed behavior. Choose reliability target at the user-happiness/business-harm boundary, include external commitments and systemic risk, preserve internal margin, and show marginal architecture/operational cost. Extreme objectives require prevention and isolation because response may be slower than budget exhaustion.

### How do I handle missing SLI data?

**Direct answer:** do not call it good. Detect missingness independently, quantify coverage and freshness, find the measurement failure, and apply a pre-approved policy that may mark status invalid or use a conservative bound.

**Foundation:** `0/0` is undefined. If Prometheus stops scraping, a blank graph does not mean no failures. Compare expected and observed events, check scrape and rule health, and state “unknown” until evidence returns.

**Senior answer:** classify missingness by boundary: no user traffic, upstream reachability failure, exporter failure, discovery/scrape loss, remote-write/drop, rule failure, query mismatch, late data, or retention. Preserve source freshness and coverage SLIs, independent black-box/edge evidence, and reason-coded unknown events. Policy should define fail-open versus fail-closed by decision type; release gates may fail closed while dashboards display provisional status. Backfill must not silently rewrite incident decisions—version snapshots and record revisions.

### How do I calculate error budget correctly?

**Direct answer:** preserve raw counts and units. For an event SLO, multiply total eligible events by `1 - target`, then subtract actual bad events. For time SLO, multiply eligible time by `1 - target`.

**Foundation:** 99.9% leaves 0.1%, or 0.001. For two million events, allowance is two thousand bad events. If 3,200 are bad, remaining is minus 1,200 and 160% is consumed.

**Senior answer:** first validate binary/multi-outcome classification, population completeness, deduplication, event-time window, exclusions, and objective version. Use integer raw counts and reviewed decimal/rational or discrete rounding policy. For rolling windows, recognize entries and expirations; for calendar event windows, allowance can grow with observed volume; for time slices, preserve slice resolution and weighting. Report allowed, actual, remaining, consumed fraction, and trajectory with uncertainty. Do not compare budgets with different populations or units.

### When should a burn alert page?

**Direct answer:** when a valid signal shows significant budget consumption is still active, user harm is urgent, and a qualified responder has a safe action that can improve the outcome before the deadline.

**Foundation:** use a long window to avoid paging on tiny spikes and a short window to ensure the issue is current. Both exceed the tier threshold. Slower threats become tickets.

**Senior answer:** derive tiers from objective window and budget portion, then simulate/backtest on traffic, incidents, gaps, deploys, and low-volume periods. Measure precision, recall, detection and reset. Pair SLI state with coverage and freshness; ensure inhibition/deduplication and end-to-end route delivery. Link impact, runbook, dashboard, owner, and escalation. For extreme objectives, page cannot defend the budget; invest in isolation, canary, redundancy, and automated bounded controls. Reassess any page without an urgent safe human action.

### Does an SLO miss mean an SLA breach?

**Direct answer:** no. Only the applicable agreement defines contractual scope, measurement, exclusions, period, consequence, and claim process.

**Foundation:** an internal team might target 99.95% while a customer agreement promises 99.9% using a different monthly calculation. Missing the internal target can consume margin without violating the agreement.

**Senior answer:** treat contractual interpretation as a separate controlled workflow. Preserve the signed version, covered tenant/tier/region, provider/source hierarchy, maintenance and exclusion clauses, rounding, claim period, and evidence chain. Notify authorized business/legal owners; do not publish speculative credits or breach statements. Internal SLOs should often be tighter than external commitments to preserve response margin, but they remain distinct records.

### How do error budgets influence deployment?

**Direct answer:** through a signed policy. Healthy budget supports normal reviewed change; threatened or exhausted budget shifts priority toward reliability and pauses avoidable user-risk-increasing work, with controlled reliability and security exceptions.

**Foundation:** the budget is a traffic signal agreed before conflict. It prevents a feature team and operations team from renegotiating reliability during every incident.

**Senior answer:** policy inputs include valid budget state, material incidents, measurement confidence, and exceptional risk. Outputs specify change categories, not a blind command. Reliability fixes need canary/abort/rollback; security changes use a risk-approved emergency path; contractual or safety constraints can override statistical budget. Record approvers, rationale, scope, expiry and review. Measure whether the policy reduces future user harm without causing hidden queues, risky batch releases, or political bypass.

## Product-company interview

### Scenario

You join a payments platform. Leadership asks for a 99.99% authorization SLO because a competitor advertises four nines. The current dashboard shows 99.995% HTTP success, but it measures only application requests. The edge sees 8% more attempts, payment correctness is reconciled daily, a dependency has a 99.9% objective, and one-hour p99 is averaged across pods. The team pages when five-minute error rate exceeds 0.01% for one hour. What do you do?

### Five-minute model answer

“I would not accept or reject four nines from the dashboard. I would first define the user operation: one valid authorization attempt receives a correct terminal decision within the merchant deadline, without duplicate or lost state. The current application denominator misses 8% of edge attempts, so 99.995% is an observed-subset ratio, not a valid user SLI. Daily correctness reconciliation is too late for rapid reliability decisions, and averaging pod p99 is statistically invalid.

I would preserve raw edge accepted operations, correlate logical operation IDs through retries, join or independently compare terminal authorization state, and define good as correct plus latency. I would expose good, bad, total, unknown, coverage, freshness, counter resets, and important region/merchant/client cohorts. For latency, I would use compatible histograms and either a threshold-event ratio tied to the merchant deadline or an aggregate percentile computed from the distribution—not mean pod percentiles.

Then I would backtest representative traffic and incidents. Four nines leaves a 0.01% bad budget. A complete outage exhausts a 30-day time-equivalent budget in roughly 4.32 minutes, so a one-hour `for` delay cannot defend it. I would design multi-window burn alerts: long windows for significant consumption, short windows for current activity, plus coverage/freshness alerts and low-traffic handling. I would model the 99.9% dependency, fallback, correlated failure, retries, capacity, canary, and whether end-to-end four nines is feasible.

Product, service, SRE, risk, and contractual owners would approve the target, window, measurement, rounding, and error-budget policy. I would distinguish the internal SLO from any SLA. The policy would pause avoidable risk when valid budget is threatened, while allowing reviewed reliability and urgent security exceptions. I would deploy measurement in shadow mode, reconcile old/new populations, test rules and routing, and verify user outcomes before it controls releases. If evidence shows users need four nines and architecture can support it at justified cost, we adopt it. If not, I present the tradeoff rather than manufacture a green number.”

### Why this answer is strong

- starts from the user operation rather than the requested number;
- detects denominator coverage and latency aggregation defects;
- distinguishes correctness latency from HTTP status;
- calculates the operational meaning of four nines;
- connects dependency and architecture feasibility;
- designs alerting around budget threat and actionability;
- names approval and policy ownership;
- separates SLO from SLA;
- proposes shadow validation and safe rollout;
- refuses unsupported certainty.

### Weak answer

“I would set 99.99% in Grafana, reduce the alert threshold to match, and scale Kubernetes so we meet it.”

Why it fails:

- Grafana does not define the population or approve the objective;
- lowering a threshold does not repair missing events;
- scaling may not fix correctness, edge, dependency, or retry failure;
- the one-hour delay remains incompatible with the budget;
- no policy, ownership, cost, rollback, or contractual separation exists;
- it promises an outcome without evidence.

### Answered follow-ups

**How much downtime does 99.99% allow in 30 days?**

For a time-based approximation: `30 × 24 × 60 = 43,200 minutes`; budget fraction `0.0001`; allowance `4.32 minutes`. This does not directly describe event-based authorization harm.

**Can a 99.9% dependency support a 99.99% journey?**

Not by naive serial reliance. It may if the product has cache, fallback, redundancy, asynchronous behavior, or a narrower dependency operation with stronger actual behavior. Measure end to end and test failure modes; do not multiply advertised numbers as proof.

**Why not use average latency?**

Averages hide the tail and can look good while an important minority times out. Use user-relevant threshold ratios and distribution-aware percentiles.

**Why not alert directly on remaining budget below zero?**

That detects failure after the objective is already missed and may reset poorly. Burn alerts warn on significant trajectories before full consumption. Budget status remains important for policy and reporting.

**What if correctness arrives only daily?**

The SLO may be provisional until reconciliation, or use a fast proxy plus delayed authoritative correction. Label both, monitor disagreement, and do not let the proxy silently become correctness truth. Improve terminal-event timeliness if decisions require it.

**How do you prevent SLO gaming?**

Independent population/coverage signals, controlled exclusions, versioned definitions, cross-functional approval, raw numerator/denominator access, cohort views, audit history, and outcome review. Avoid individual performance incentives tied directly to one SLO.

**How do you test an SLO query?**

Use fixture series covering healthy, boundary, above threshold, counter reset, missing series, zero traffic, label mismatch, partial scrape, duplicated source, rollout versions, and low traffic. Validate rule syntax with the pinned tool, shadow-evaluate on representative history, and reconcile raw counts.

**What would make you lower an SLO?**

Evidence that the current target materially exceeds user need, creates dependency expectations, causes disproportionate cost/toil, or drives low-value pages—plus stakeholder approval and analysis of external commitments. Never lower it merely to make a dashboard green.

**What would make you raise it?**

User or contractual harm below the current threshold, sustained measurement evidence, architecture and dependency feasibility, justified cost, operational ability to defend it, and approved policy. Actual overperformance alone is not enough.

**How do you explain error budget to an executive?**

“It is the pre-agreed amount of service imperfection compatible with our user and business goal. We spend it through failures and risk. Its policy tells us when delivery can proceed normally and when reliability must take priority. It makes the tradeoff visible; it does not excuse harm or replace judgment.”

## Independent transfer and rubric

`ASM-0081` is the actual transfer boundary. The guided fixture, this chapter, `ASM-0079`, and `ASM-0080` contain answers. Repeating them cannot prove independent competence.

### Independence gate

Before receiving the unseen case, record:

- authorization and prohibited systems;
- normal-user local environment;
- accessibility needs;
- all human, tool, AI, and reference help;
- confirmation that answered LES-0032 sections will remain closed;
- sanitization and cleanup plan.

The unseen case must materially change journeys, counts, traffic pattern, measurement defect, target/window, burn signals, and policy conflict. Renaming checkout to booking is not enough.

### Required work

Produce:

1. user and dependency map;
2. complete SLI specifications for at least two journeys;
3. raw sanitized populations with interval, source, units, coverage, and freshness;
4. at least six ranked falsifiable hypotheses;
5. correct SLI, budget, aggregation, and burn math where evidence permits;
6. missing-data and low-traffic decisions;
7. multi-window alert with actionability and routing contract;
8. error-budget policy with exceptions and owners;
9. explicit SLA conclusion or non-conclusion;
10. safe staged validation, recovery, and cleanup;
11. five-minute defense;
12. at least fifteen precise non-claims.

### Scoring

| Criterion | Points | Observable evidence |
|---|---:|---|
| Independence, authorization, integrity | 10 | unseen case, declared help, safe scope, sanitized raw evidence |
| User journey and SLI specification | 10 | complete populations, boundaries, units, coverage, freshness |
| Measurement hypotheses | 10 | six falsifiable ranked tests across real boundaries |
| SLO and budget arithmetic | 10 | correct formulas, units, windows, rounding, uncertainty |
| Aggregation and segmentation | 10 | raw weighted math plus important cohort reasoning |
| Burn and alert design | 10 | long/short AND, urgency, reset, route, actionability |
| Low traffic and missing data | 10 | impact-aware response without silent green or automatic page |
| Policy, SLA, ownership | 10 | authorized posture, exceptions, consequences, escalation, review |
| Safe validation and recovery | 10 | canary, abort, rollback, fallback, user proof, cleanup |
| Communication and proof limits | 10 | clear defense and fifteen specific non-claims |

Mastery is not awarded automatically. A qualified reviewer must inspect raw evidence, independence, safety, calculations, decisions, and explanation. A score can guide remediation; it is not a professional certification.

### Common independent failures

- choosing target before population;
- using precomputed percentages without raw counts;
- treating unknown as good;
- averaging ratios or percentiles;
- reporting burn without lookback window;
- copying threshold constants without derivation;
- designing pages with no urgent safe action;
- treating policy as a command or punishment;
- making an SLA claim without an agreement;
- omitting cleanup or proof limits.

Remediation requires a materially different case, not editing toward the model answer.

## References and review

This chapter paraphrases primary or official sources. Read them for provider details and original context; do not use a reference URL as proof that your implementation follows it.

| ID | Source | Used for | Review cadence |
|---|---|---|---|
| REF-0244 | Google, *Service Level Objectives* | SLI/SLO/SLA terminology, indicator selection, percentiles, expectations | Six months |
| REF-0245 | Google, *Implementing SLOs* | specification/implementation, target process, approval, error-budget decisions | Six months |
| REF-0246 | Google, *SLO Engineering Case Studies* | transfer across service shapes | Six months |
| REF-0247 | Google, *Example SLO Document* | documentation, authors, reviewers, approvers | Six months |
| REF-0248 | Google, *Example Error Budget Policy* | policy purpose, change posture, escalation | Six months |
| REF-0249 | Google, *Alerting on SLOs* | precision, recall, burn, multi-window alerts, low traffic | Six months |
| REF-0250 | Google, *Embracing Risk* | reliability-risk tradeoff and error-budget rationale | Six months |
| REF-0251 | Google, *Availability Table* | nines and time allowance reference | Six months |
| REF-0252 | Prometheus, *Histograms and summaries* | threshold ratios, percentiles, aggregation, histogram choice | Three months |
| REF-0253 | Prometheus, *Query functions* | current `rate`, histogram, and query semantics | Three months |
| REF-0254 | Prometheus, *Recording rules* | ratio aggregation and naming practice | Three months |
| REF-0255 | Prometheus, *Defining recording rules* | rule evaluation and validation | Three months |
| REF-0256 | OpenSLO specification | vendor-neutral SLO-as-code vocabulary | Three months |
| REF-0257 | Google Cloud, *Concepts in service monitoring* | request/time objectives, rolling/calendar windows, trajectory | Three months |
| REF-0258 | Google Cloud, *Alerting on your burn rate* | current provider burn semantics and lookback behavior | Three months |

### Review triggers

Review earlier than the scheduled date when:

- Prometheus query or native histogram behavior changes;
- OpenSLO schema/version changes;
- provider SLO or burn selector semantics change;
- product journeys, dependencies, retry behavior, or instrumentation change;
- an incident exposes missing populations or misleading segmentation;
- target, window, exclusions, rounding, policy, or SLA changes;
- alert precision, recall, detection, reset, or human load degrades;
- a learner or reviewer finds an ambiguous term, unsafe step, or unsupported claim.

### Final proof boundary

This chapter can teach a repeatable method and a bounded model. It cannot approve a real SLO, interpret a contract, authorize a release, validate production telemetry, deliver a page, prove organizational adoption, or make anyone an expert by itself.

The strongest final sentence is therefore:

> Define the user promise, prove the population, calculate with units, act through policy, and verify the user outcome—then say exactly what remains unknown.
