---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0030",
  "slug": "alerting-dashboards-user-journeys",
  "aliases": ["V04-L05", "alerting-dashboards-user-journeys"],
  "curriculumIds": ["OBS-005"],
  "route": "/book/reliability/alerting-dashboards-user-journeys",
  "order": 5,
  "volume": "04-reliability-operations",
  "title": "Alerting and dashboards: carry a user symptom to a human decision",
  "summary": "Learn how user journeys, SLIs, rule evaluations, alert states, routing, grouping, deduplication, inhibition, silences, receivers, escalation, runbooks, dashboards, and recovery evidence form one reliability control loop; diagnose noisy, silent, stale, misleading, or unactionable monitoring without treating a green panel as truth.",
  "domain": "reliability",
  "level": {"from": "intermediate", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0026", "LES-0008"],
  "prerequisiteCurriculumIds": ["OBS-001", "SRE-002"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The bounded teaching model requires only Bash and Python 3 and refuses root. It does not contact a receiver or execute a monitoring product. Optional product commands require separately reviewed local artifacts."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The deterministic lab is designed for WSL. WSL service startup, clocks, systemd, networking and process boundaries can differ from native Ubuntu and must be recorded rather than assumed equivalent."
    },
    {
      "platform": "Prometheus and Alertmanager",
      "version": "current official documentation reviewed 2026-08-04; exact immutable artifacts pending",
      "support": "concept-only",
      "notes": "Rule, state, grouping, inhibition, silence and routing behavior is explained from official documentation. No Prometheus, promtool, Alertmanager, receiver or HA runtime execution is claimed."
    },
    {
      "platform": "Grafana",
      "version": "current official documentation reviewed 2026-08-04; exact immutable artifact pending",
      "support": "concept-only",
      "notes": "Dashboard, alert-instance, no-data, missing-series, error and recovery-threshold concepts are explained. No Grafana instance, data source, notification policy or visual acceptance has run."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "observability-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "software-engineer-on-call",
    "incident-commander",
    "technical-lead"
  ],
  "learningObjectives": [
    "Trace one user symptom from a defined journey and valid SLI population through telemetry, storage, query, rule evaluation, alert instance, state transition, notification policy, receiver, acknowledgement, escalation, runbook action, and verified recovery.",
    "Distinguish rule, evaluation, condition, alert instance, state, notification, delivery attempt, page, acknowledgement, escalation, silence, mute timing, inhibition, grouping, deduplication, resolution, incident, and root cause.",
    "Design user-journey and black-box signals that complement white-box cause signals without mixing synthetic success into real-user truth.",
    "Calculate precision, recall, false positives, misses, error-budget fraction, burn rate, window budget consumption, rule evaluation rate, alert-instance bounds, notification amplification, and page load with declared populations and units.",
    "Explain normal, pending, firing, retained-firing, resolved, no-data, missing-series, stale, partial and evaluator-error states and refuse any automatic missing-to-zero health claim.",
    "Use multiwindow multi-burn-rate reasoning to balance detection time, reset time, precision and recall while treating published thresholds as starting points rather than universal constants.",
    "Build a task-oriented dashboard hierarchy that shows user health, denominator, coverage, freshness, scope and change context before cause drilldowns.",
    "Design stable routing identity, ownership, severity, grouping, deduplication, inhibition, exact expiring silences, receiver delivery, acknowledgement, escalation and out-of-band monitoring.",
    "Test monitoring as code through syntax checks, known series, time-state assertions, missing-data cases, route and receiver failures, shadow evaluation, canary notification, rollback and cleanup.",
    "Operate alerting as a socio-technical production system with least privilege, audit, secret-safe templates, sustainable on-call load, runbook feedback and precise proof limits."
  ],
  "productionSignals": [
    "valid good and total user events, bad-event ratio, objective, remaining error budget, burn rates by window, traffic sufficiency, segment coverage and freshness",
    "black-box probe attempts, successes, failures, latency, vantage point, journey step, synthetic identity, test-data cleanup and coverage limits",
    "telemetry scrape or receive success, sample age, missing series, stale markers, query latency, query error, scanned population and data-source health",
    "rule group evaluations, duration, failures, missed iterations, active series, pending instances, firing instances, state transition time and rule version",
    "alert fingerprints, stable routing labels, annotations, ownership, severity, grouping key, inhibition match, silence match, mute timing and resolved state",
    "notification groups, unique notifications, delivery attempts, retries, timeouts, receiver acknowledgements, provider failures and end-to-end delivery delay",
    "pages, tickets, acknowledgements, escalations, time-to-human, time-to-action, manual suppressions, abandoned alerts and after-hours interruption load",
    "alert precision, recall, false-positive ratio, duplicate ratio, missed significant events, pages per incident, pages per shift and actionable-page ratio",
    "dashboard query status, denominator, coverage, freshness, scope, variable values, panel load time, data age, no-data state and change annotations",
    "rule, route, receiver, silence, dashboard, runbook, owner, SLO and deployment changes with actor, review, desired/running version and rollback state"
  ],
  "diagrams": [
    {
      "id": "LES-0030-DIA-001",
      "title": "Signal-to-human reliability control loop",
      "direction": "left-to-right",
      "boundaries": ["user journey or probe", "telemetry", "storage and query", "rule evaluation", "alert instance and state", "notification policy", "receiver and escalation", "human action", "user recovery verification"],
      "evidencePoints": ["good and total events", "coverage and freshness", "query population", "evaluation result", "fingerprint and transition", "group inhibit silence decision", "delivery and acknowledgement", "runbook action", "independent user outcome"],
      "textAlternative": "A real or synthetic user journey produces scoped events. Telemetry and storage make a query population. A rule evaluates that population and creates alert instances with states. Notification policy groups, deduplicates, inhibits, silences and routes. A receiver attempts delivery and escalation. A human takes a runbook action. Independent user evidence closes the loop. Every arrow is a failure boundary and stopping notifications is not recovery."
    },
    {
      "id": "LES-0030-DIA-002",
      "title": "Alert-instance state machine",
      "direction": "top-to-bottom",
      "boundaries": ["normal", "pending", "firing", "retained firing", "resolved", "no data", "missing series", "evaluation error"],
      "evidencePoints": ["condition result", "first breach time", "pending duration", "continued breach", "clear time", "recovery threshold", "expected population", "query status"],
      "textAlternative": "A false condition is normal. A true condition may enter pending until its required duration elapses, then firing. A cleared condition may remain firing for a configured hold before resolving. Query failure, total no data and one missing series are separate evidence states, not automatic normal values. Exact state names vary by product, so operators must inspect both evaluation and notification state."
    },
    {
      "id": "LES-0030-DIA-003",
      "title": "Long and short burn-window gate",
      "direction": "left-to-right",
      "boundaries": ["valid SLI population", "allowed bad fraction", "long-window bad ratio", "short-window bad ratio", "burn thresholds", "page or ticket", "grouped incident"],
      "evidencePoints": ["good and total", "one minus objective", "significant budget spend", "currently active burn", "both comparisons", "required response time", "one human interruption"],
      "textAlternative": "The valid good and total population yields a bad ratio. Dividing it by one minus the SLO produces burn rate. The long window asks whether budget consumption is significant; the short window asks whether it is still active. Both must cross the same selected threshold. Several policy windows can describe one incident and should not automatically create several pages."
    },
    {
      "id": "LES-0030-DIA-004",
      "title": "Notification reduction and delivery tree",
      "direction": "top-to-bottom",
      "boundaries": ["firing instances", "fingerprint deduplication", "grouping", "inhibition", "silence or mute timing", "routing tree", "receiver attempt", "acknowledgement and escalation"],
      "evidencePoints": ["instance labels", "duplicate identity", "group key", "source and target match", "owner reason expiry", "matched receiver", "delivery ID and result", "human receipt and next action"],
      "textAlternative": "Firing instances first need stable identities. Duplicate deliveries collapse by fingerprint, related alerts group into one notification, dependent alerts may be inhibited by a root alert, authorized exact matches may be silenced for a bounded time, and the route chooses a receiver. Delivery attempts, receiver acknowledgement and human acknowledgement are separate."
    },
    {
      "id": "LES-0030-DIA-005",
      "title": "Dashboard decision ladder",
      "direction": "hierarchical",
      "boundaries": ["user question", "SLI and burn", "denominator coverage freshness", "scope and change", "golden-signal causes", "dependency and resource drilldown", "logs traces profiles", "runbook decision"],
      "evidencePoints": ["what is broken", "how much and how fast", "can evidence be trusted", "where and what changed", "traffic errors latency saturation", "leading constraint", "request-level explanation", "authorized next action"],
      "textAlternative": "The first dashboard row answers whether users are succeeding and whether error budget is burning. The next row proves denominator, coverage and freshness. Scope and change markers show where and when. Cause panels show golden signals and dependencies. Logs, traces and profiles support deeper diagnosis. The dashboard ends in a runbook decision, not decorative graphs."
    },
    {
      "id": "LES-0030-DIA-006",
      "title": "Monitoring-the-monitoring-system dependency",
      "direction": "cyclic",
      "boundaries": ["service", "telemetry pipeline", "query and evaluator", "notification receiver", "primary responder", "out-of-band sentinel"],
      "evidencePoints": ["user outcome", "ingestion freshness", "evaluation heartbeat", "test delivery", "acknowledgement", "independent alarm path"],
      "textAlternative": "The service depends on telemetry, query, evaluation and notification to reach a responder. If that chain monitors only itself, one failure can hide every alert. A small independently operated sentinel or out-of-band test observes the critical alert path. The sentinel also has scope and failure limits and must not become an uncontrolled second paging system."
    }
  ],
  "commands": [
    {
      "id": "LES-0030-CMD-001",
      "question": "Which user, kernel, Ubuntu release, Python version, UTC time, and directory define this lab attempt?",
      "risk": "read-only",
      "command": "id; uname -a; cat /etc/os-release; python3 --version; date -u +%Y-%m-%dT%H:%M:%SZ; pwd",
      "runFrom": "a normal Ubuntu shell before touching the lab",
      "expectedBranches": [
        {"when": "the caller is non-root and environment matches the approved scope", "meaning": "the evidence context is recorded", "nextEvidence": "run the lab doctor"},
        {"when": "the caller is root, release differs, time is implausible, or path is unexpected", "meaning": "state ownership, timing or portability assumptions are unsafe", "nextEvidence": "stop mutation and correct the environment contract"}
      ],
      "proves": "only the caller and reported local environment identity at that moment",
      "doesNotProve": "clock synchronization, Prometheus/Grafana availability, receiver delivery, or production equivalence"
    },
    {
      "id": "LES-0030-CMD-002",
      "question": "Is promtool available locally, and what exact version would a later rule test use?",
      "risk": "read-only",
      "command": "command -v promtool; promtool --version",
      "runFrom": "an approved local environment; do not install or download anything for this check",
      "expectedBranches": [
        {"when": "a path and version appear", "meaning": "one local promtool binary is discoverable", "nextEvidence": "verify artifact provenance and compatibility before using it"},
        {"when": "command not found appears", "meaning": "the optional real rule-test tool is absent", "nextEvidence": "continue with the deterministic teaching model and record the runtime gap"}
      ],
      "proves": "only discoverability and self-reported version of one local binary",
      "doesNotProve": "artifact integrity, compatibility, rule correctness, Prometheus runtime behavior, or authorization"
    },
    {
      "id": "LES-0030-CMD-003",
      "question": "What are the allowed bad fraction and burn rate for a 99.9 percent SLO with a two percent bad ratio?",
      "risk": "read-only",
      "command": "python3 -c 'slo=0.999; bad=0.02; budget=1-slo; print(f\"budget={budget:.6f} burn_rate={bad/budget:.2f}\")'",
      "runFrom": "any approved normal-user Ubuntu directory",
      "expectedBranches": [
        {"when": "budget=0.001000 burn_rate=20.00 appears", "meaning": "the arithmetic matches the declared decimal inputs", "nextEvidence": "validate the real SLI population, units and windows"},
        {"when": "another result appears", "meaning": "input, representation or code differs", "nextEvidence": "inspect the exact expression before using the result"}
      ],
      "proves": "decimal arithmetic for two declared values",
      "doesNotProve": "SLI validity, traffic sufficiency, production burn, alert delivery, or a universal threshold"
    },
    {
      "id": "LES-0030-CMD-004",
      "question": "What evaluation-rate bound follows from 600 services, four groups, thirty seconds, and forty instances?",
      "risk": "read-only",
      "command": "python3 -c 'services=600; groups=4; interval=30; instances=40; rate=services*groups/interval; print(f\"group_evaluations_per_second={rate:.0f} max_instance_evaluations_per_second={rate*instances:.0f}\")'",
      "runFrom": "any approved normal-user Ubuntu directory",
      "expectedBranches": [
        {"when": "80 and 3200 appear", "meaning": "the declared upper-bound arithmetic is correct", "nextEvidence": "measure query cost, replicas, retries, state and receiver fan-out separately"},
        {"when": "another result appears", "meaning": "one input or unit changed", "nextEvidence": "reconcile the workload model before capacity decisions"}
      ],
      "proves": "only the supplied evaluation-count arithmetic",
      "doesNotProve": "CPU, memory, query latency, series scans, HA capacity, notification volume, or production headroom"
    },
    {
      "id": "LES-0030-CMD-005",
      "question": "Are the bounded lab prerequisites, identity, fixture, and state path safe before mutation?",
      "risk": "read-only",
      "command": "bash lab.sh doctor",
      "runFrom": "book/labs/LES-0030-alerting-dashboards-user-journeys as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "doctor reports ready=true", "meaning": "the deterministic model prerequisites and state identity passed", "nextEvidence": "run setup"},
        {"when": "doctor refuses root, missing tools, invalid fixtures or ambiguous state", "meaning": "the wrapper cannot establish its safety contract", "nextEvidence": "preserve the refusal and fix only the named boundary"}
      ],
      "proves": "only local prerequisite, fixture and path validation",
      "doesNotProve": "Prometheus, Alertmanager, Grafana, receiver, pager, cloud or production behavior"
    },
    {
      "id": "LES-0030-CMD-006",
      "question": "Can the lab create an exact UID-owned alert-lifecycle fixture state?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "the LES-0030 lab directory after doctor passes",
      "expectedBranches": [
        {"when": "setup reports state=ready", "meaning": "the exact teaching state validated", "nextEvidence": "record status before cases"},
        {"when": "setup refuses ambiguous or concurrent state", "meaning": "ownership or lifecycle safety is not established", "nextEvidence": "inspect the named state; do not force deletion"}
      ],
      "proves": "creation or revalidation of only the declared local fixture",
      "doesNotProve": "a real monitoring or notification runtime",
      "cleanup": "Run bash lab.sh cleanup; it validates the complete descriptor and proves the exact path absent."
    },
    {
      "id": "LES-0030-CMD-007",
      "question": "What fixture identity and result count exist before the next alert case?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the LES-0030 lab directory",
      "expectedBranches": [
        {"when": "status reports state=ready", "meaning": "manifest, scenario and current result children validate", "nextEvidence": "run one declared case"},
        {"when": "status reports absent", "meaning": "no owned lab state exists", "nextEvidence": "run doctor and setup"},
        {"when": "status refuses", "meaning": "unexpected or ambiguous state exists", "nextEvidence": "preserve it for review rather than bypassing validation"}
      ],
      "proves": "the wrapper's current validated state and result-file count",
      "doesNotProve": "rule accuracy, alert delivery or user health"
    },
    {
      "id": "LES-0030-CMD-008",
      "question": "How do normal, pending, firing, retained-firing, and resolved states evolve over discrete evaluations?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run state-machine",
      "runFrom": "the LES-0030 lab directory after setup",
      "expectedBranches": [
        {"when": "three transitions and finalState normal appear", "meaning": "the fixture entered pending, fired after the declared duration, then resolved after the retained-firing period", "nextEvidence": "compare exact product semantics before transfer"},
        {"when": "another state sequence appears", "meaning": "fixture, model or timing contract changed", "nextEvidence": "inspect every timestamp and condition; do not tune until the model is understood"}
      ],
      "proves": "only discrete state arithmetic in the teaching model",
      "doesNotProve": "scheduler timing, missed evaluations, product restart behavior, HA state, or notification delivery",
      "cleanup": "Run bash lab.sh cleanup after the guided sequence."
    },
    {
      "id": "LES-0030-CMD-009",
      "question": "Which long-and-short window pairs exceed their declared burn thresholds?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run burn-rate",
      "runFrom": "the LES-0030 lab directory after setup",
      "expectedBranches": [
        {"when": "fast-page, slow-page and ticket fire while recovered-spike does not", "meaning": "both windows are active for three policies and the short window rejects the recovered spike", "nextEvidence": "group policies describing the same incident"},
        {"when": "another policy set appears", "meaning": "inputs, threshold comparison or budget fraction changed", "nextEvidence": "recompute with exact decimals and matched windows"}
      ],
      "proves": "burn-rate comparisons for declared fixture values",
      "doesNotProve": "valid SLI, adequate traffic, correct objective, universal thresholds, or live rule behavior",
      "cleanup": "Run bash lab.sh cleanup after the guided sequence."
    },
    {
      "id": "LES-0030-CMD-010",
      "question": "Can the model distinguish a real zero, one missing series, total no data, and query error?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run no-data",
      "runFrom": "the LES-0030 lab directory after setup",
      "expectedBranches": [
        {"when": "four different classifications appear", "meaning": "the expected-population and query-status contract preserved four evidence states", "nextEvidence": "define production handling for each state"},
        {"when": "states collapse together", "meaning": "the monitoring contract lost information", "nextEvidence": "repair the population and failure model before allowing green status"}
      ],
      "proves": "classification over the fixed expected-series fixture",
      "doesNotProve": "dynamic discovery correctness, provider state behavior, or that missing targets should always page",
      "cleanup": "Run bash lab.sh cleanup after the guided sequence."
    },
    {
      "id": "LES-0030-CMD-011",
      "question": "Does the complete model, assertion, refusal, and cleanup matrix pass?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "the LES-0030 lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "verification=passed and final_state=absent appear", "meaning": "all eight deterministic cases, selected assertions, adversarial refusals and cleanup passed", "nextEvidence": "retain the result only as model evidence"},
        {"when": "the verifier exits non-zero", "meaning": "the first syntax, model, safety or cleanup boundary failed", "nextEvidence": "inspect that exact failure; cleanup failure is reported rather than hidden"}
      ],
      "proves": "the declared model and wrapper lifecycle when actually run in the stated environment",
      "doesNotProve": "Prometheus, Alertmanager, Grafana, a receiver, human acknowledgement, production transfer, learner skill or mastery",
      "cleanup": "The verifier validates cleanup and exact final absence; preserve any refused ambiguous state."
    },
    {
      "id": "LES-0030-CMD-012",
      "question": "Can the wrapper remove only its exact validated state and prove absence?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh cleanup",
      "runFrom": "the LES-0030 lab directory",
      "expectedBranches": [
        {"when": "cleanup=passed state=absent appears", "meaning": "the exact lesson state is absent", "nextEvidence": "none for lab cleanup"},
        {"when": "cleanup refuses path, owner, sentinel, manifest, child or symlink", "meaning": "removal authorization is not established", "nextEvidence": "preserve and inspect; never replace the guard with broad recursive deletion"}
      ],
      "proves": "absence of only the exact lesson-owned state path",
      "doesNotProve": "absence of unrelated temporary state, product resources, notification deliveries or independent-case resources",
      "cleanup": "This is the cleanup operation; refusal intentionally leaves ambiguous state untouched."
    }
  ],
  "labs": [
    {
      "id": "LES-0030-LAB-001",
      "title": "Guided alert-lifecycle and dashboard truth model",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS normal user with Bash and Python 3; no Docker, network, ports, sudo, package installation, service manager, monitoring product or receiver",
      "timeMinutes": 120,
      "privilege": "normal user; wrapper and verifier refuse UID 0",
      "network": "none; all fixtures, state transitions and calculations are local",
      "changes": ["one lesson-specific temporary directory", "owned fixture copies", "bounded JSON result files"],
      "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "a child is a symlink or unexpected type", "fixture contract is invalid", "a calculation differs from reviewed expectations", "cleanup cannot validate exact ownership"],
      "recovery": "Run status. If the complete descriptor validates, run cleanup and repeat setup. Preserve refused foreign or ambiguous state for review instead of deleting it broadly.",
      "cleanupProof": "Cleanup validates exact parent, basename, real path, UID, sentinel, manifest, scenario, allowed children, types, owner and size, removes only that directory, and proves exact absence.",
      "path": "book/labs/LES-0030-alerting-dashboards-user-journeys"
    },
    {
      "id": "LES-0030-LAB-002",
      "title": "Independent noisy-or-silent alerting incident",
      "mode": "independent",
      "environment": "An instructor-provided or learner-created unseen disposable local case with materially changed journey, state, missing-data, routing, dashboard, low-traffic and recovery behavior; the guided fixture cannot satisfy independence",
      "timeMinutes": 120,
      "privilege": "normal user; no elevated operation",
      "network": "none unless a separately reviewed unseen local harness explicitly declares loopback; production, shared, employer, email, SMS, chat, pager and online cloud systems are prohibited",
      "changes": ["one learner-owned sanitized response outside guarded LES-0030 state", "only resources declared by the unseen disposable case"],
      "abortConditions": ["reviewer-only answer material becomes visible", "authorization, accessibility or sanitization is unclear", "state validation fails", "a real receiver could be contacted", "the learner proposes broad silencing or destructive action", "evidence cannot discriminate the hypothesis"],
      "recovery": "Return to baseline evidence, narrow the hypothesis and submit a revision. Never reveal answered material before independent review.",
      "cleanupProof": "Use the unseen case's own manifest to prove every created process, port, file, queue, container, network or resource absent. Guided lab cleanup does not cover the independent case.",
      "path": "book/labs/LES-0030-alerting-dashboards-user-journeys"
    }
  ],
  "incidents": [
    {
      "id": "LES-0030-INC-001",
      "signal": "A database outage produces hundreds of child notifications while one user-journey alert and one root alert are actionable.",
      "firstThought": "Keep user impact and notification amplification as separate incidents. Reconcile instances, fingerprints, groups, suppression decisions, attempts and acknowledgements before calling every delivery a page.",
      "safePath": "Preserve root and symptom coverage, apply only exact expiring containment to redundant children, repair and test grouping/inhibition/deduplication, then prove user, evaluator and receiver recovery independently.",
      "trap": "Silencing everything makes the phone quiet but leaves both service failure and monitoring failure unknown."
    },
    {
      "id": "LES-0030-INC-002",
      "signal": "The dashboard is green because an empty result is transformed into zero after one region stops reporting.",
      "firstThought": "Green is presentation. Ask whether the query succeeded, which series were expected, which returned, how old they are, and whether the denominator is complete.",
      "safePath": "Restore or explicitly classify the missing region, expose coverage/freshness/no-data state, verify user outcomes independently, and test the missing-series branch before publishing the correction.",
      "trap": "Adding a zero fallback manufactures evidence and can disable the alert precisely when monitoring disappears."
    },
    {
      "id": "LES-0030-INC-003",
      "signal": "A threshold near normal variance flips firing and resolved every few minutes, waking on-call repeatedly.",
      "firstThought": "Flapping can come from invalid SLI population, short windows, scrape gaps, threshold placement, missing-data behavior, or true oscillation; do not start by lengthening every delay.",
      "safePath": "Plot raw numerator, denominator, coverage, freshness and state transitions; measure precision/recall and user impact; test a separate recovery threshold, windows or product fix against recorded cases; retain fast detection for severe failures.",
      "trap": "A long pending duration can hide repeated severe bursts and improve page counts only by lowering recall."
    },
    {
      "id": "LES-0030-INC-004",
      "signal": "The monitoring system stops evaluating rules, so every service dashboard freezes at its last healthy value.",
      "firstThought": "The absence of new firing alerts is not evidence of health. Check data age, evaluator heartbeat, missed evaluations, notification test and an independent observation path.",
      "safePath": "Declare monitoring coverage degraded, use independent user or black-box evidence, restore the critical evaluation/delivery path, prove backfill and state behavior, and avoid replaying an uncontrolled notification storm.",
      "trap": "Restarting the UI or refreshing the dashboard does not repair ingestion, evaluation or delivery."
    }
  ],
  "assessmentIds": ["ASM-0073", "ASM-0074", "ASM-0075"],
  "referenceIds": ["REF-0214", "REF-0215", "REF-0216", "REF-0217", "REF-0218", "REF-0219", "REF-0220", "REF-0221", "REF-0222", "REF-0223", "REF-0224", "REF-0225", "REF-0226", "REF-0227", "REF-0228"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "This chapter is canonical reading content and a live route, but publication is not formal acceptance, lab-runtime evidence, or learner mastery.",
    "The Python fixture is a deterministic teaching model, not a monitoring server, PromQL engine, rule scheduler, Alertmanager, Grafana, synthetic probe, receiver, escalation service or representative application.",
    "No Prometheus, promtool, Alertmanager, Grafana, PagerDuty, Opsgenie, email, SMS, chat, Dynatrace, Splunk, Datadog, CloudWatch or cloud-monitoring runtime has executed for this lesson.",
    "Published Google SRE burn-rate values are taught as reasoned starting points and examples, not universal policy or proof that a service's SLI and SLO are valid.",
    "Capacity calculations are declared arithmetic bounds and cannot size real rule queries, replicas, state, notifications or human load without measurement.",
    "No learner execution, independent reviewer decision, delayed recall, production transfer, formal acceptance, browser visual review or mastery evidence exists."
  ]
}
---

# Alerting and dashboards: carry a user symptom to a human decision

## What you see and first thought

It is 02:13. Your phone vibrates six times, pauses, then starts again. The dashboard is a wall of red panels: eighty application instances cannot reach the database. A database alert is firing too. Somewhere between those graphs and your phone, the same outage has become hundreds of messages.

Your first thought must not be, “How do I make the phone quiet?” Ask two questions instead:

1. **What are users unable to do?**
2. **What should one human do now that automation cannot safely do?**

Everything else serves those questions.

An alert is not “a metric above a number.” It is a control path. A user event becomes telemetry. A query selects a population. A rule evaluates it. An alert instance moves through state. Policy groups, deduplicates, inhibits, silences and routes. A receiver attempts delivery. A human acknowledges, acts and verifies recovery. If any boundary is wrong, you can receive no page during an outage, five hundred pages for one outage, or a beautiful green dashboard built from missing data.

Remember this sentence:

> A page is a request for a specific human action before a specific reliability risk becomes unacceptable.

If you cannot name the action, owner and response time, the signal may belong on a dashboard or ticket—not on a sleeping engineer's phone.

### The three truths you must keep separate

| Truth | Question | Typical evidence |
|---|---|---|
| User truth | Can the user complete the promised operation? | Valid good/total events, external journey, business terminal state |
| Monitoring truth | Is the evidence path complete and current? | Coverage, freshness, scrape/ingest/query/evaluation health |
| Notification truth | Did the right human receive one actionable message? | Fingerprint, group, route, delivery ID, acknowledgement, escalation |

These truths can disagree. Checkout may be healthy while the notification receiver is broken. Checkout may be broken while the evaluator is frozen. Notifications may stop because somebody silenced them, not because anything recovered.

### What to do in the first five minutes

1. Record the exact time, scope, alert identity, state, labels, annotations and links without copying secrets.
2. Open the user-journey signal and confirm denominator, coverage and freshness.
3. Check whether monitoring itself is evaluating and delivering.
4. Group evidence by incident, not by pod count.
5. Follow the immediate runbook action; if it does not exist, treat that as an alert-design defect.
6. Preserve state before editing rules, routes or silences.
7. Verify recovery from the user side; a resolved notification is only one boundary.

## Terms before commands

You will debug faster when every word refers to one object.

### User and reliability terms

**User journey:** A sequence that represents an outcome somebody values, such as “submit checkout and receive a durable order confirmation.” A journey includes entry, required steps, terminal success, terminal failure, deadline, scope and exclusions. “Website up” is not a journey.

**Good event:** One valid event that met the promised outcome. Define status, deadline, correctness and duplication rules. A fast HTTP 200 that commits the wrong order is not good.

**Total event:** One valid opportunity for the service to deliver the outcome. Exclude only by documented product logic. If good and total come from different populations, the ratio is fiction.

**SLI:** A measured indicator, often `good / valid total`. It is a measurement contract, not a target.

**SLO:** A target for an SLI over a window, agreed with stakeholders. `99.9% over 30 days` means an allowed bad fraction of `0.001`; it does not mean “page at 99.9% over five minutes.”

**Error budget:** The allowed bad fraction or count under the objective. For a ratio objective:

```text
allowed_bad_fraction = 1 - SLO
```

**Burn rate:** How fast the current bad ratio consumes that allowance:

```text
burn_rate = observed_bad_fraction / allowed_bad_fraction
```

Burn `1` consumes the budget exactly across the objective window if sustained. Burn `10` consumes it ten times as fast.

**Black-box signal:** Evidence observed from outside the service contract: can DNS resolve, TLS complete, login work, checkout finish? It is close to user experience but limited to its vantage point, identity, steps and test data.

**White-box signal:** Evidence from inside components: queue depth, database latency, thread pools, CPU, parser rejection. It helps explain cause but does not automatically prove user harm.

**Synthetic journey:** Controlled artificial traffic. It can detect failures when real traffic is sparse, but covers only designed paths and identities. Keep it labelled and usually separate from the real-user denominator.

### Rule and state terms

**Rule:** Versioned logic plus evaluation interval, query, condition, labels, annotations and state timing.

**Evaluation:** One scheduled attempt to execute the rule. It can succeed with values, succeed with no data, return only part of the expected population, time out, or fail.

**Condition:** The boolean decision derived from the query result. A condition has units, comparison, window and population.

**Alert instance:** One independently tracked result of a rule, commonly identified by a label set. A rule grouped by region may create three instances. One rule is not one page.

**Normal:** The condition is false under valid current evidence.

**Pending:** The condition is true, but a required persistence period has not elapsed. Pending suppresses short breaches; it also delays severe real failures.

**Firing:** The condition met its state contract. Firing still does not prove a notification reached anybody.

**Retained firing:** Some systems keep an instance firing briefly after the condition clears to prevent rapid resolve/re-fire behavior or tolerate missing samples.

**Resolved:** The condition cleared according to the evaluation contract. It does not prove the user recovered if the SLI is wrong or evidence is stale.

**Flapping:** Frequent state transitions around a boundary. Causes include real oscillation, poor threshold placement, missing samples, short windows, bad denominators and unstable dependencies.

**Recovery threshold or hysteresis:** A different boundary for returning to normal. If firing begins above 100 but recovery waits until 95 or below, values at 99 do not flap. Hysteresis reduces churn; a bad recovery threshold can hide degradation.

### Missing-evidence terms

**Value zero:** The query succeeded, returned the expected population, and the numeric result is zero. This can be healthy.

**No data:** The query succeeded but returned no data points at all. It may mean no traffic, wrong scope, target disappearance, ingestion delay or retention loss.

**Missing series:** A multi-dimensional query returned some expected series but not another. Total no data and one missing region require different responses.

**Stale:** Data exists, but its age exceeds the decision contract.

**Partial:** Some denominator or segment coverage is present but incomplete.

**Evaluation error:** The query or evaluator failed or timed out. It is not no data and never a healthy zero.

**Keep last state:** Retain the previous state during missing/error evidence. This can avoid transient noise but can also preserve a false healthy or false firing state. Pair it with an independent monitoring-path alert.

### Notification terms

**Fingerprint:** Stable identity used to recognize the same alert instance across repeated evaluations or deliveries. Exact construction is product-specific.

**Deduplication:** Prevent repeated notifications for the same identity. It does not combine different related instances.

**Grouping:** Combine several related instances into one notification while preserving affected members. Group by incident meaning—service, journey, environment, region—not volatile pod identity alone.

**Inhibition:** Suppress a target alert while a source alert is firing and their declared equal labels match. Example: suppress per-service dependency noise while a shared database-root alert fires. A broad or stale dependency model can hide simultaneous failures.

**Silence:** A bounded matcher-based decision not to notify. The underlying rule and instance may still fire. A safe silence has authorization, exact scope, reason, owner, incident, expiry and removal verification.

**Mute timing:** A scheduled notification suppression such as maintenance hours. It must not silently cover unscheduled impact or erase evidence.

**Routing tree:** Policy that maps labels to receivers and timing. Parent settings may be inherited; match order and continuation matter.

**Receiver:** The integration that accepts a notification: paging system, ticket queue, email, chat or another controlled endpoint.

**Delivery attempt:** One attempt to send a notification. Timeouts can create retries even if a receiver processed the first attempt.

**Acknowledgement:** Evidence that a receiver or human accepted a notification. Receiver acknowledgement, page acknowledgement and incident ownership are different states.

**Escalation:** Move notification or incident ownership when acknowledgement/action does not occur within policy.

**Page:** A high-interruption notification requiring immediate action. Not every notification is a page.

**Ticket:** Owned asynchronous work with a due time. Slow budget burn often belongs here.

**Runbook:** A versioned decision aid describing meaning, immediate safe checks, containment, escalation, rollback, recovery and proof limits. It is not a list of blind restart commands.

### Dashboard terms

**Dashboard:** A task-oriented view that answers a known operational question. It is not evidence merely because it is visual.

**Panel:** One visualization backed by one or more queries and transformations. Its title should name the question, scope and unit.

**Denominator:** The population against which a numerator has meaning. An error count without traffic volume can mislead.

**Coverage:** Observed valid population divided by expected valid population where an expectation exists.

**Freshness:** Age from the relevant event or observation boundary to the decision boundary.

**Change annotation:** A deployment, feature flag, configuration, dependency or traffic change shown on the same time axis. Correlation helps rank hypotheses; it is not automatic causality.

## Architecture map

### The complete path

```text
real users / controlled probes
          |
          | valid operations, good/total events, timestamps
          v
instrumentation -> collector/storage -> query/recording rule
          |                 |                 |
          | coverage        | freshness       | population + unit
          +-----------------+-----------------+
                                            |
                                            v
                                  scheduled rule evaluation
                                  /        |          \
                               values    no data      error
                                  |         |           |
                                  v         v           v
                          alert instance state machine
                          normal -> pending -> firing
                                            |
                                            v
                             notification policy boundary
                      dedupe -> group -> inhibit -> silence -> route
                                            |
                                            v
                              receiver attempt / retry / ack
                                            |
                                            v
                              human ack -> action -> escalation
                                            |
                                            v
                             independent user recovery proof
```

At each arrow ask:

- What object crosses this boundary?
- Who owns its state?
- What identifier survives?
- What counter or age proves passage?
- Can it be dropped, duplicated, delayed, suppressed or mutated?
- What would “missing” mean here?

### Symptom and cause are partners, not competitors

```text
USER SYMPTOM                                      CAUSE EVIDENCE
checkout success falls                            database latency rises
        |                                                  |
        +---- page: users need protection now              |
                                                           |
                                                           +---- dashboard/drilldown:
                                                                 why this is happening
```

Page on the user symptom when possible. Use cause signals to choose a safe action. A CPU alert with no user impact and no imminent hard limit is usually diagnostic or capacity evidence. A user symptom tells you to act even when the cause is novel.

Exceptions exist. Page on a cause when crossing a hard limit will soon cause irreversible or severe harm and there is a tested immediate action—certificate expiry, storage exhaustion, replica loss below a safety floor. Write the causal chain and time-to-harm into the alert contract.

### The dashboard ladder

```text
1. ARE USERS OK?       good/total, latency objective, journey state
2. CAN I TRUST THIS?   denominator, coverage, freshness, no-data/error
3. WHERE/WHEN?         region, tenant class, version, change markers
4. WHAT IS SATURATED?  traffic, errors, latency, saturation, queues
5. WHY?                dependencies, logs, traces, profiles, events
6. WHAT NOW?           owner, runbook, rollback, verification
```

This ordering matters at 02:13. Do not force the responder to scan forty host graphs before discovering that the denominator vanished.

### Monitor the monitoring path

```text
service -> telemetry -> query -> evaluator -> notification -> responder
   ^                                                        |
   |                                                        |
   +---------------- recovery verification -----------------+

independent sentinel -> known test signal -> known receiver -> acknowledgement
```

The independent sentinel must be smaller and operationally separate enough that the same failure is unlikely to break both paths. If it shares the same database, evaluator and receiver, it is decorative redundancy.

## Request or state path

Follow one checkout alert through the system.

### 1. Define the operation

The operation begins when an authorized checkout request is accepted. It ends in one terminal state:

- durable order committed within 2 seconds: good;
- declared product rejection such as invalid address: excluded or separately classified according to policy;
- timeout, internal failure, incorrect order, duplicate charge, or unknown terminal state: bad;
- client abandonment before server acceptance: outside the server opportunity, if agreed.

The definition must live beside the measurement. Otherwise teams silently change the denominator until graphs improve.

### 2. Produce evidence

Suppose one hour has 100,000 valid checkout opportunities and 2,000 bad outcomes:

```text
bad_fraction = 2,000 / 100,000 = 0.02 = 2%
```

For a 99.9% objective:

```text
allowed_bad_fraction = 1 - 0.999 = 0.001
burn_rate = 0.02 / 0.001 = 20
```

That is a 20x burn over the hour. But do not page yet from this arithmetic alone. Ask:

- Are good and total from the same boundary?
- Is traffic sufficient?
- Is the window complete and fresh?
- Are late events included consistently?
- Did a metric reset or label change?
- Is a high-cardinality overflow hiding `success=false`?

### 3. Evaluate two windows

The long window answers, “Has this consumed enough budget to matter?” The short window answers, “Is it still happening?”

```text
long 1h burn  = 20x  > 14.4x
short 5m burn = 18x  > 14.4x
both true -> fast page path active
```

If the long burn remains 20x but the short burn falls to 0.2x, the incident may have recovered before evaluation. Paging then has poor reset time. Keep the historical budget damage on the dashboard or ticket path, but do not necessarily wake somebody for an inactive burn.

### 4. Create alert instances

If the query groups by `service`, `journey`, `environment` and `region`, each label set can become an instance. Keep routing labels stable and bounded. Do not put request IDs, user IDs, raw URLs, exception strings or pod UIDs into paging identity.

Use annotations for human context:

- summary of user harm;
- current values and units;
- long/short windows and threshold;
- dashboard and runbook identities;
- likely first safe action;
- declared proof limits.

Annotations must also be secret-safe and injection-safe. A notification can leak data to phones, email, chat history and third-party systems.

### 5. Apply policy

Two burn policies and eighty pod alerts may all fire. The notification layer should decide:

- Is this the same fingerprint repeated?
- Which instances describe one incident?
- Is a child safely inhibited by a stable root alert?
- Is there an authorized exact silence?
- Which owner and receiver match?
- How long should grouping wait for related evidence?
- When does failure escalate?

The output should be one actionable page with affected scope, not one page per implementation object.

### 6. Deliver and acknowledge

Record notification ID, receiver, attempt, result and delay. A timeout is ambiguous: the receiver may have processed the message but failed to acknowledge. Retry can be correct, but deduplication identity must survive.

Human acknowledgement means, “I own the next action,” not “the service recovered.” If no one acknowledges within policy, escalate to a different person or incident process; do not merely resend forever.

### 7. Act and verify

The runbook may say: compare current release, route a safe percentage away from the failing region, roll back a known incompatible change, or reduce load. Every action needs authorization, abort criteria and rollback.

Recovery is layered:

1. controlled checkout and real-user SLI recover;
2. telemetry coverage and freshness recover;
3. evaluator state becomes normal for the right reason;
4. routing emits the intended resolved behavior;
5. receiver and acknowledgement path work;
6. the system remains stable through an observation window.

## Failure zoom

### Failure A: no page during a real outage

Possible boundaries:

1. The user journey is not instrumented.
2. Total events disappeared, making the ratio empty.
3. A label change moved data outside the query.
4. The query errors or times out.
5. The rule group misses evaluations.
6. The instance is stuck pending because samples intermittently disappear.
7. A broad silence or inhibition matches it.
8. The route has no receiver.
9. The receiver rejects or cannot authenticate.
10. Delivery succeeds but escalation is absent.

Do not jump straight to “the threshold is wrong.” Walk boundaries until you find the first divergence.

### Failure B: one outage creates hundreds of pages

Use population conservation:

```text
firing instances
- duplicate fingerprints collapsed
- inhibited dependent instances
- silenced exact authorized instances
= deliverable instances

deliverable instances
grouped by incident key
= intended notification groups

notification groups
+ retry attempts
= receiver deliveries
```

The equation is a ledger, not a universal implementation formula. Match the same time, environment and route. If you have 480 deliveries but no fingerprints or delivery IDs, you cannot calculate unique alerts or duplicates honestly.

### Failure C: green dashboard, missing region

Suppose expected regions are `a` and `b`, but the query returns only `a=0 errors`. A transformation fills absent values with zero. The display says global errors are zero.

The real states are:

```text
region a: value zero
region b: missing series
global population: partial
global health: unknown
```

Show this explicitly. Green should require valid denominator, expected coverage and acceptable freshness—not merely a numeric zero.

### Failure D: alert flaps

Values: `95, 101, 99, 103, 97, 94, 92`, fire above 100.

Without hysteresis: normal, firing, normal, firing, normal—four transitions.

With recovery at 95 or below: normal, firing, firing, firing, firing, normal—two transitions.

Before adding hysteresis, inspect whether 99 is actually healthy. Thresholds must derive from user harm, capacity or budget, not graph aesthetics.

### Failure E: monitoring freezes

A panel can keep the last sample and look stable after evaluation stops. Always expose data age and evaluator health. An outage in monitoring may require a separate operational incident because your confidence in every service state has degraded.

## Internals and state ownership

### Who owns what?

| State | Primary owner | Durable identity | Failure evidence |
|---|---|---|---|
| User operation | application/product | operation or terminal-event identity | missing/incorrect terminal outcomes |
| SLI population | instrumentation/query contract | service, journey, scope, version | good/total mismatch, coverage, freshness |
| Rule definition | monitoring configuration | rule/group/version | desired versus loaded definition, syntax/test result |
| Alert instance | evaluator | rule plus stable label set | active/pending/firing state and transition time |
| Suppression | notification policy | matcher/rule/silence ID | matched source/target, owner, reason, expiry |
| Notification group | routing system | group key and window | members, first/last notification time |
| Delivery attempt | receiver integration | notification and attempt ID | response, timeout, retry, latency |
| Human ownership | on-call/incident system | page/incident ID | acknowledgement, escalation, handoff |
| Recovery | service and responder | incident plus user evidence | user success, stable SLI, resolved state |

When two systems both believe they own identity, duplicates appear. When nobody owns it, alerts disappear.

### Prometheus rule concepts

Prometheus alerting rules evaluate PromQL expressions on a schedule. Each output vector element becomes an active alert for its label set. A `for` duration can keep it pending before firing. `keep_firing_for` can keep it firing after the expression stops returning it.

Important operator questions:

- What exact query and rule group version is loaded?
- What is the evaluation interval?
- Did the rule evaluation succeed?
- Did the prior evaluation finish before the next was due?
- What label set identifies each instance?
- What happens when the series disappears?
- Are labels overwriting source identity?

`for` is not a moving average. A one-minute query with `for: 1h` asks for continuous truth across evaluations; it is not equivalent to a one-hour rate. Gaps can reset pending state and miss repeated severe bursts.

### Alertmanager concepts

Alertmanager receives firing/resolved alerts and manages notification policy. Four mechanisms are easy to confuse:

- deduplication: same identity, repeated delivery;
- grouping: different related instances, one message;
- inhibition: source alert suppresses a related target;
- silence: explicit matcher suppresses notification for a bounded interval.

Routing is a tree. Every alert enters at the root, then matches child routes. Inherited configuration, match order and continuation can send to multiple receivers or the wrong owner. Missing labels can also match in surprising ways, particularly in inhibition equality. Test configuration with positive and negative cases.

Alertmanager high availability reduces some component failures, but replication, peer convergence, duplicate notification behavior and client configuration still require exact version/runtime evidence. Do not infer HA from two replicas on a diagram.

### Grafana alerting concepts

Grafana-managed rules can query supported data sources and create an alert instance for each returned series or row. Query, reduce/expression, condition, evaluation group, pending period, labels, annotations, no-data/error behavior and notification policy all matter.

No-data and error states may create separate alert instances and carry different labels. Existing silences or routes for the original rule may not automatically cover them. A “keep last state” option can reduce transient churn but requires a separate way to detect a prolonged data-source outage.

Recovery thresholds create hysteresis. Use them only with a product or capacity reason and test both entry and exit. A recovery threshold that is too low can keep an alert firing long after users recover; too high can flap.

### Dashboards are query applications

Each panel has a query, transformation, unit, visualization, thresholds, scope and permissions. Therefore dashboards can fail like software:

- incorrect query joins;
- hidden filters;
- variable default selecting one region;
- stale refresh;
- unit mismatch;
- percentile averaging;
- missing-to-zero transform;
- too many high-cardinality series;
- expensive repeated queries;
- access-controlled data omitted for on-call;
- color-only meaning inaccessible to some users.

Review dashboards as code or versioned configuration. Test known input and missing input. Keep panel descriptions and runbook links concrete.

### The human is stateful too

An on-call engineer has limited attention, memory and sleep. Each page consumes a scarce reliability resource. Track:

- pages per shift and per incident;
- after-hours pages;
- duplicate and nonactionable pages;
- time to acknowledge and act;
- escalations;
- runbook success/failure;
- alerts abandoned or auto-resolved before action;
- post-incident alert deletions and improvements.

Alert fatigue is not personal weakness. It is a systems defect caused by poor signal, unclear ownership, excessive fan-out, missing automation or unrealistic staffing.

## Evidence table

| Observation | Supports | Does not establish | Next discriminating evidence |
|---|---|---|---|
| User SLI bad ratio rises with complete fresh denominator | scoped user outcome is degrading | root cause or notification delivery | golden signals, change events, dependency evidence |
| CPU reaches 95% | one measured resource is highly utilized | user harm, saturation, or need to page | queue/latency/error/user SLI and CPU scheduling evidence |
| Rule is firing | evaluator condition/state met | receiver delivery or human action | instance fingerprint, route decision, delivery ID |
| Notification is delivered | receiver accepted one attempt | human saw it, acted, or service recovered | page acknowledgement, incident ownership, action timeline |
| Alert resolved | evaluated condition cleared | user recovery if SLI/evidence is invalid | independent journey and stable observation window |
| Dashboard shows zero | returned/transformed display is zero | complete, current, correct population | denominator, coverage, freshness, query status |
| Query returns nothing | selected query has no result | zero errors or absent users | query success, expected series, raw population, time scope |
| One region disappears | expected population is partial | region outage cause | discovery, scrape/ingest, lifecycle/change evidence |
| 480 deliveries in 15 minutes | 32 deliveries/minute in that scope | 480 unique pages or duplicate count | fingerprints, group IDs, attempt IDs, acknowledgements |
| Silence matches | notifications for matches are suppressed | condition cleared or users recovered | underlying instance state and user evidence |
| Synthetic checkout succeeds | one path/vantage/identity succeeded | all real users or states succeed | segmented real-user SLI and additional probes |
| Rule tests pass | encoded fixtures meet expected states | live data quality, routing, receiver or production safety | shadow/canary/runtime evidence |

### Evidence hierarchy during a page

Prefer evidence that is closest to the claim and independent of the suspected failure:

1. controlled or real user outcome;
2. valid SLI numerator, denominator, coverage and freshness;
3. alert instance state and rule version;
4. routing/suppression decision;
5. delivery and acknowledgement;
6. dashboard presentation;
7. unscoped screenshots or memory.

A screenshot is useful context but weak evidence without time range, variables, query, data age and source.

## Command decoders

### `id; uname -a; cat /etc/os-release; python3 --version; date -u ...; pwd`

This is one environment record, not ceremony.

- `id` shows numeric UID/GID and groups. The lab refuses UID 0 because root adds no learning value and expands blast radius.
- `uname -a` reports kernel identity. WSL and native Ubuntu can share userland but differ here.
- `/etc/os-release` reports distribution identity. It does not prove kernel or container host.
- `python3 --version` binds deterministic arithmetic to an interpreter version.
- `date -u` records the observer's UTC time. It does not prove synchronization.
- `pwd` prevents copying commands from the wrong lesson.

If any item differs, write it down. Do not say “Linux” when the exact boundary is “Ubuntu 24.04 userland on WSL 2 kernel.”

### `command -v promtool; promtool --version`

`command -v` asks the current shell how it would resolve the name. It can return an alias, function or executable path depending on shell state. `promtool --version` asks that binary for its version.

Possible outputs:

- path plus version: available, but provenance and compatibility remain open;
- command not found: optional product test unavailable; do not download automatically;
- permission denied or loader error: file exists but is not runnable in this environment;
- unexpected path: stop and inspect PATH before trusting it.

Later, a reviewed runtime could use `promtool check rules` for syntax and `promtool test rules` for known time series. A successful syntax check cannot prove semantic intent, route delivery or user relevance.

### Burn arithmetic command

```text
slo=0.999
bad=0.02
budget=1-slo = 0.001
burn=bad/budget = 20
```

Common mistakes:

- using `99.9` instead of decimal `0.999`;
- treating percentage points as percent change;
- dividing good ratio instead of bad ratio;
- comparing different windows or populations;
- rounding before the comparison;
- assuming a burn threshold is universal.

Always show formula, substitution, unit and interpretation.

### Capacity arithmetic command

```text
600 services * 4 groups / 30 seconds = 80 group evaluations/second
80 evaluations/second * 40 instances = 3,200 instance evaluations/second
```

This is an upper count bound. It omits query range, series scanned, rule complexity, evaluator replicas, state storage, retries, notification groups and human load. Capacity planning begins after this arithmetic, not ends.

### `bash lab.sh doctor`

The doctor does not mutate. It checks tools, exact fixture types, scenario contract, current state path and ownership. `ready=true` means only those checks passed.

If it refuses an unexpected child, do not rename or delete the child to make the lesson pass until you know who owns it. Refusal is a safety result.

### `bash lab.sh setup`

Setup creates a private candidate under `/tmp`, writes a sentinel, copies the scenario, writes a manifest, checks for a concurrent winner, then atomically renames the candidate to the exact UID path. An exit trap removes only a validated candidate if setup fails.

`existing=true` means an exact pre-existing state was revalidated. It does not mean a new clean run. Use status and cleanup when you need a fresh attempt.

### `bash lab.sh status`

Status validates every allowed child before counting results. A directory with the right name but wrong owner, sentinel, manifest, symlink or unexpected file is refused.

That pattern transfers directly to production automation: identity is a complete descriptor, not a convenient path string.

### `bash lab.sh run state-machine`

Read each row:

```text
atSeconds=0   breach=false state=normal
atSeconds=60  breach=true  state=pending
atSeconds=120 breach=true  state=pending
atSeconds=180 breach=true  state=firing
...
atSeconds=420 breach=false state=normal
```

The condition, evaluation time and state are separate columns. In production also record missed evaluations, restart behavior and no-data/error policy.

### `bash lab.sh run burn-rate`

The fixture reports long and short burn rates per policy. A policy fires only when both are strictly greater than the declared threshold. Equality semantics are part of the rule contract; do not swap `>` and `>=` casually.

The recovered spike has a high long-window burn but a low short-window burn. This is the memory hook: **long says significant; short says still burning**.

### `bash lab.sh run no-data`

The expected population makes four outputs possible:

- expected and returned zero: `value-zero`;
- one expected region absent: `missing-series`;
- no returned series: `no-data`;
- query status failure: `query-error`.

Without expected population, a dynamic ephemeral target may legitimately disappear. Expected-series logic needs service-discovery and lifecycle context; hard-coding every pod name is not scalable.

### `bash verify.sh`

The verifier runs syntax, eight cases, selected numeric/state assertions, unexpected-child refusal, child-symlink refusal, cleanup and final absence. Its EXIT handler attempts cleanup after failure and reports if cleanup itself cannot validate state.

Passing proves only the checked-in model and wrapper. It cannot be upgraded into a vendor-runtime claim by confident wording.

### `bash lab.sh cleanup`

Cleanup validates exact `/tmp` parent, exact UID basename, real path, directory owner, sentinel, manifest, scenario, allowed child names, file type, owner and size. Only then does it remove the exact state and prove absence.

If it refuses, the correct response is inspect—not `sudo rm -rf /tmp/reliability-*`.

## Decision path

Use this when an alert is noisy, silent or suspicious:

```text
START
  |
  v
What user operation is at risk?
  |-- undefined --> define journey; do not tune page blindly
  v
Is good/total population valid, complete and fresh?
  |-- query error ----> monitoring incident; use independent evidence
  |-- no data --------> classify no traffic vs missing pipeline
  |-- missing series -> identify expected lifecycle/scope
  |-- stale/partial --> user health unknown; restore evidence
  v
Does condition/state match known inputs and timing?
  |-- no --> rule/query/version/state-machine defect
  v
How many instances and unique fingerprints exist?
  |-- unexpected --> label/cardinality/identity defect
  v
Did grouping/dedupe/inhibition/silence produce intended groups?
  |-- no --> policy amplification or suppression defect
  v
Did the receiver deliver and human acknowledge?
  |-- no --> receiver/escalation incident
  v
Is there an immediate authorized action?
  |-- no --> downgrade to ticket/dashboard and redesign page
  v
Act with abort + rollback
  v
Verify user -> telemetry -> evaluator -> notification -> stability
```

### Hypothesis table before changing anything

| Hypothesis | Prediction | Rejecting evidence | Safe check |
|---|---|---|---|
| User journey truly failing | independent real/synthetic outcome fails | complete fresh user evidence succeeds | bounded journey plus terminal state |
| Denominator disappeared | total/coverage falls before ratio changes | total remains complete and fresh | numerator/denominator/coverage by same scope |
| Rule version drift | running definition differs from desired/tested | exact hashes and loaded rule match | read-only config/version inventory |
| Missing-data converted to zero | query empty but panel displays zero | raw query returns complete numeric zero | inspect query result before transform |
| Label explosion | active instances increase with new value | instance label sets stable | top labels and rule output count |
| Grouping key absent | many groups differ only by volatile identity | intended stable key present and grouping works | compare instance and group labels |
| Inhibition mismatch | source fires but target equal labels differ | target correctly suppressed in test | evaluate source/target/equal matchers |
| Receiver retries duplicate | same notification ID has several attempts | one attempt per notification | delivery attempt and acknowledgement ledger |

Pick the check that most strongly separates the top two hypotheses with the smallest risk.

## Guided Ubuntu lab

This lab gives you repeatable evidence without requiring a monitoring stack.

### Safety contract

- normal user only;
- no network or real receiver;
- no package install;
- no Docker, Kubernetes, systemd or cloud;
- only `/tmp/reliability-atlas-les0030-<uid>` changes;
- cleanup refuses anything outside the exact manifest.

### Phase 1: establish environment

```bash
id
uname -a
cat /etc/os-release
python3 --version
date -u +%Y-%m-%dT%H:%M:%SZ
pwd
```

Write one sentence: “I am a non-root user in ___, at UTC ___, running from ___.”

### Phase 2: create state

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Expected branches:

- `ready=true`, then `state=ready`: continue;
- root refusal `77`: return to normal user;
- missing tool `69`: record the dependency gap;
- contract refusal `78`: preserve and inspect;
- concurrent-state refusal `75`: another lifecycle won the exact path.

### Phase 3: measure alert quality

```bash
bash lab.sh run alert-quality
```

The fixture has ten significant events, twelve alerts and eight true positives:

```text
false positives = 12 - 8 = 4
missed significant events = 10 - 8 = 2
precision = 8 / 12 = 0.666667
recall = 8 / 10 = 0.8
```

Precision asks, “When we alerted, how often did it matter?” Recall asks, “When something important happened, how often did we alert?” Reducing pages by deleting rules can improve apparent precision while destroying recall. You need independently labelled significant events to measure either.

### Phase 4: walk the state machine

```bash
bash lab.sh run state-machine
```

Point to the first pending time, first firing time, first cleared evaluation and final resolution. Explain why pending duration and retained-firing duration solve different problems.

### Phase 5: evaluate burn policies

```bash
bash lab.sh run burn-rate
```

Confirm `fast-page`, `slow-page` and `ticket` fire. Confirm `recovered-spike` does not because its short window is below threshold. Then say: “These three firing policies may still be one incident and one page.”

### Phase 6: protect missing evidence

```bash
bash lab.sh run no-data
bash lab.sh run dashboard
```

For each output, name:

- expected population;
- returned population;
- query status;
- data age;
- denominator coverage;
- correct presentation state.

Do not say “zero” when the value is `null`, absent, stale or partial.

### Phase 7: reconcile notification policy

```bash
bash lab.sh run routing
```

Expected ledger:

```text
received alert deliveries = 6
unique fingerprints = 5
duplicate deliveries = 1
inhibited unique alerts = 1
silenced unique alerts = 1
deliverable unique alerts = 3
notification groups = 2
```

The model trusts fixture flags; it does not implement matcher semantics or timing. In a real system, preserve the exact route decision and matching labels.

### Phase 8: compare flapping behavior

```bash
bash lab.sh run flapping
```

The naive rule has four transitions; hysteresis has two. Now answer the senior question: what user or capacity boundary justifies recovery at 95? If you cannot answer, the lower threshold is a tuning guess.

### Phase 9: investigate the storm

```bash
bash lab.sh run incident
```

Create this short incident note:

```text
User impact:
Monitoring impact:
First supported amplification boundary:
Safe containment:
Evidence preserved:
User recovery proof:
Notification recovery proof:
Unknowns:
```

### Phase 10: verify and clean

```bash
bash verify.sh
bash lab.sh status
```

The verifier should report `final_state=absent`; status should report absent. If the verifier fails, its first failure is evidence. Do not manually erase ambiguous state.

### Lab limitations

This model does not schedule concurrently, execute PromQL, simulate scrape gaps, persist HA state, evaluate real matchers, send notifications, render dashboards, measure human response or run a representative service. Its value is conceptual precision and safe repeatability.

## Production transfer

Transfer the model by boundary, not by copying syntax.

### Prometheus and Alertmanager

Map concepts:

| Lesson concept | Prometheus/Alertmanager mechanism | Verify |
|---|---|---|
| query and condition | PromQL expression in alerting rule | exact rule file and known series |
| pending | `for` | firing time under continuous and gapped input |
| retained firing | `keep_firing_for` | clear and reappearance behavior |
| stable identity | alert labels | bounded label sets and cardinality |
| human context | annotations | secret-safe rendered notification |
| group/dedupe/route | Alertmanager route/group settings | test alerts and delivery ledger |
| inhibition | source/target/equal matchers | positive and negative matcher cases |
| silence | bounded matchers | owner/reason/expiry/audit/removal |

Before rollout:

1. pin exact artifacts and verify provenance;
2. validate rule and Alertmanager configuration;
3. unit-test rule expressions and expected alerts;
4. run shadow evaluation against representative data;
5. route canary notifications to a non-paging test receiver;
6. verify no-data, rule failure and receiver failure;
7. preserve old configuration and rollback;
8. monitor the evaluator and notification path.

### Grafana

For each dashboard panel and alert rule, record:

- data source and query;
- variables and default scope;
- reduction and condition;
- unit and display transformation;
- expected series;
- no-data/error behavior;
- evaluation interval and pending/recovery settings;
- stable labels, annotations and notification policy;
- dashboard owner, folder permissions and change history.

Test raw query results separately from visualization. A panel transformation can conceal missing values even when the alert query is correct.

### Cloud monitoring products

AWS CloudWatch, Azure Monitor, Google Cloud Monitoring, Dynatrace, Datadog and Splunk use different names and state models, but the same questions transfer:

- What exact data and dimension population is evaluated?
- How are missing data and delayed data treated?
- Is one rule one incident or many dimensions many incidents?
- What is the evaluation cadence and lookback?
- How are notifications grouped, suppressed and retried?
- Which identity and permission edits rules and channels?
- How is the monitoring system monitored independently?

Do not translate `for` blindly into “number of evaluation periods.” Verify exact provider semantics, late data, state after edits, deployment behavior and receiver integration.

### Kubernetes

Avoid paging per pod for a service-level symptom. Pods are replaceable implementation objects. Page on user impact, service-level exhaustion or cluster safety floor. Use pod/node signals for drilldown or for hard-limit alerts with an immediate action.

Kubernetes lifecycle makes expected-series logic difficult: a disappeared pod may be healthy scale-down. Use desired replica state, ownership and termination reason rather than a static list of pod names.

### Low-traffic services

One failure in ten requests is a 10% bad ratio and huge burn for a 99.9% objective. That may be correct if every request is high-value, or useless if random client retries absorb it.

Options:

- extend windows while respecting detection needs;
- combine related operations with a shared failure meaning;
- create a controlled synthetic journey;
- improve product retries, queues or fallback so single failures cause less harm;
- renegotiate an unrealistic objective with stakeholders.

Never lower the SLO only to quiet pages without a product decision.

### Synthetic journey design

Define:

- vantage point and network path;
- test identity and permissions;
- test data creation and cleanup;
- exact steps and assertions;
- timeout budget;
- frequency and load ceiling;
- safe failure behavior;
- real-versus-synthetic labels;
- coverage limits.

A successful probe can coexist with real-user failure due to geography, identity, data state, feature flags or caching. A failing probe can be a probe defect. Compare, never substitute.

## Reliability, security, observability, capacity, and cost

### Reliability of the alerting system

Define objectives for monitoring itself:

- telemetry coverage and end-to-end freshness;
- rule evaluation success and maximum delay;
- notification delivery success and latency;
- known test signal detected and acknowledged;
- configuration convergence;
- route ownership completeness;
- absence of expired silences;
- page precision/recall where ground truth exists.

Use an independent path for the critical chain. Test failure, not just heartbeat presence.

### Human reliability

A sustainable on-call design includes:

- enough trained responders for rotation and leave;
- explicit primary/secondary ownership;
- response and escalation times;
- handoff and incident-command rules;
- runbooks accessible during identity/provider failure;
- page-volume limits and review triggers;
- psychological safety and blameless learning;
- automation for repeated safe actions.

If responders routinely ignore alerts, do not demand more attention. Repair the system.

### Security

Threats include:

- attacker changes a rule to hide activity;
- broad silence suppresses security/reliability detection;
- notification template leaks tokens or user data;
- webhook secret is committed or logged;
- dashboard exposes sensitive tenant metrics;
- untrusted label text injects misleading notification content;
- weak permissions allow route hijacking;
- audit records are unavailable during investigation.

Controls:

- least-privilege roles for rule, dashboard, route, silence and receiver editing;
- review and version history;
- secrets referenced from a protected store, never embedded in examples;
- output encoding and field allowlists for templates;
- exact, expiring silences with audit and owner;
- protected break-glass process;
- data minimization and access control for dashboards;
- independent audit/export retention consistent with policy.

### Capacity

Model at least five layers:

```text
rule_group_evaluations_per_second
= services * groups * replicas / interval_seconds

instance_evaluations_per_second
<= group_evaluations_per_second * max_instances_per_group

notification_groups_per_incident
= unique deliverable instances / grouping efficiency

delivery_attempts
= notification groups * receiver fanout * retry attempts

human_interruptions
<= delivered page notifications, but require acknowledgement identity
```

For the exercise:

```text
services = 600
groups/service = 4
interval = 30 seconds
max instances/group = 40

group evaluations/s = 600 * 4 / 30 = 80
max instance evaluations/s = 80 * 40 = 3,200
```

Measure actual query duration and ensure a group finishes comfortably before its next interval. Model HA replicas, remote query latency, range scans, cardinality, state retention, receiver limits and retry storms. A notification capacity plan that ignores human capacity is incomplete.

### Cost

Costs include:

- metric and log ingestion;
- high-cardinality series;
- long-range rule queries;
- recording-rule storage;
- evaluator CPU/memory;
- dashboard query repetition;
- synthetic traffic and test data;
- paging/incident provider fees;
- responder interruption and burnout;
- outages missed by bad alerts.

Cheap monitoring that misses revenue-impacting failures is expensive. Expensive telemetry nobody uses is also waste. Tie every signal to a decision, investigation, capacity plan or compliance need.

### Alert-quality scorecard

For a review period, classify every significant event and every page:

```text
precision = true-positive alerts / all alerts
recall = significant events alerted / all significant events
duplicate ratio = duplicate deliveries / all deliveries
actionable ratio = alerts with required human action / all pages
pages per incident = total pages / incidents
```

Ground truth is hard. Postmortems, support events, deployment rollbacks and user-impact records are incomplete too. State classification uncertainty.

### Dashboard performance and accessibility

A dashboard used during incidents must:

- load within the response budget;
- avoid unbounded queries and panels;
- expose time range, timezone, variables, scope and data age;
- use text/shape as well as color;
- work at zoom and on a constrained on-call screen;
- preserve readable units and legends;
- avoid animation and decorative clutter;
- provide descriptions and keyboard-accessible links;
- separate real and synthetic signals;
- show partial/no-data/error states clearly.

Visual acceptance requires an actual browser and accessibility review. Source inspection alone cannot prove it.

## Traps and prevention

| Trap | Why it fails | Better practice |
|---|---|---|
| Page on every CPU threshold | cause may not affect users and action is unclear | page on symptom or imminent hard limit; use CPU for diagnosis |
| One page per pod | implementation cardinality becomes human load | group at service/journey/region incident scope |
| Treat no data as zero | monitoring failure becomes false health | expose no-data/error/missing/coverage/freshness states |
| Add long `for` to reduce noise | delays severe outages and gaps can reset pending | improve SLI/windows, test recall, use long+short burn windows |
| Silence everything | hides detection and does not recover users | exact expiring containment while root/symptom coverage remains |
| Inhibit from unstable dependencies | stale topology hides simultaneous incidents | use only stable, tested dependency relationships |
| Put volatile IDs in labels | cardinality and instance fan-out explode | stable bounded routing identity; details in safe annotations |
| Average percentiles | percentiles are distributions, not additive averages | aggregate source histograms or use valid global query |
| Green means healthy | color may reflect stale, partial or transformed data | require valid denominator, coverage, freshness and user outcome |
| Alert on logs alone | parser/index loss can hide incidents and text lacks denominator | pair with independent operation counters or SLI |
| Synthetic equals user truth | one path and identity cannot represent all users | label separately and compare with real-user segments |
| Notification delivered equals acknowledged | receiver acceptance is not human ownership | track page ack, escalation and incident owner |
| Alert resolved equals recovered | rule may clear for missing data or bad query | verify user, telemetry, evaluator and stability independently |
| Test syntax only | valid syntax can encode wrong meaning | known-series, state, route, receiver and failure tests |
| Tune during incident without version proof | destroys evidence and makes rollback ambiguous | capture desired/running versions; canary and preserve old config |

### Prevention checklist for every page

- user operation and risk named;
- valid numerator and denominator;
- coverage and freshness visible;
- page versus ticket justified by time-to-harm;
- immediate safe human action exists;
- stable bounded identity;
- owner and escalation defined;
- runbook tested;
- no-data/error behavior explicit;
- grouping/dedupe/inhibition tested;
- exact silence policy and expiry;
- receiver and out-of-band failure monitored;
- syntax, semantic, state and route tests pass;
- shadow/canary and rollback exist;
- dashboard supports the same decision;
- page quality reviewed after incidents.

## Memory card and retrieval

### The sentence to remember

> Symptom tells you to act; cause tells you where; policy tells one owner; user evidence tells you when you are done.

### The eight-state check

```text
ZERO      expected population returned numeric zero
NO DATA   query succeeded but returned nothing
MISSING   part of expected population disappeared
STALE     data is older than the decision limit
PARTIAL   denominator or scope is incomplete
ERROR     query/evaluator failed
FIRING    valid condition met state contract
RESOLVED  condition cleared; user recovery still needs proof
```

### The page contract: U-A-O-R-P

```text
U  User impact or imminent hard limit
A  Action a human must take now
O  Owner and escalation
R  Runbook, rollback, recovery
P  Proof limits and monitoring-path health
```

### The dashboard ladder: U-T-S-C-D-A

```text
U  User outcome
T  Trust: denominator, coverage, freshness
S  Scope: region, version, tenant class
C  Change markers
D  Diagnostic causes
A  Action and runbook
```

### Retrieval prompts

Without looking back, answer:

1. Why is a rule not an alert instance?
2. Why is a firing instance not a page?
3. Why is a delivered page not acknowledgement?
4. Why is acknowledgement not recovery?
5. What is the difference between no data and a missing series?
6. Why do multiwindow burn alerts require both windows?
7. When is cause-based paging justified?
8. What must remain active during a silence?
9. How do you calculate evaluation rate?
10. What appears in the first two dashboard rows?

If an answer is vague, revisit the matching boundary—not the entire chapter.

## Complete answers

### 1. Why not page on every abnormal metric?

**Direct answer:** Abnormal is not the same as urgent, user-harming or actionable. Page only when a human must act soon to protect users or a critical safety margin.

**Deep reasoning:** A metric can be statistically unusual while the system is healthy, or normal-looking while users fail. Pages interrupt scarce human attention. Cause metrics belong on diagnostic dashboards unless they represent an imminent hard limit with a tested action. Keep the paging path simple enough that any responder can explain it.

### 2. What is the exact difference between an alert and a notification?

**Direct answer:** An alert instance is evaluator state for one rule label set. A notification is a routed message derived from one or more instances.

**Example:** Eighty pod instances can be firing. Grouping can produce one service notification. A receiver retry can produce two delivery attempts for that one notification. The human should still receive one incident page.

### 3. Why is `for: 1h` not the same as a one-hour rate?

**Direct answer:** `for` requires the evaluated condition to remain continuously active across evaluations. A one-hour rate aggregates events over a one-hour window.

**Consequence:** Repeated severe five-minute spikes separated by a passing sample can consume large budget but never satisfy `for: 1h`. Use windowed SLI arithmetic for budget significance and test state timing separately.

### 4. What do precision and recall mean for alerts?

**Answer:** Precision is true significant alerts divided by all alerts. Recall is significant events that alerted divided by all significant events. High precision with low recall means pages usually matter, but important incidents are missed. High recall with low precision means incidents are caught but responders drown in noise.

You need a review population of both alerts and significant events. Alert history alone cannot reveal events that never alerted.

### 5. How do I handle no data?

**Answer:** First separate query error, total no data, one missing series, stale data, partial denominator and real zero. Then decide behavior from service lifecycle and risk. An ephemeral batch series can disappear normally; a checkout-region series may represent loss of monitoring or service. Never hide the state with an unconditional zero.

### 6. Why long and short burn windows?

**Answer:** The long window establishes meaningful error-budget consumption and precision. The short window confirms the bad rate is still active and improves reset time. Both crossing the same threshold prevents paging for a severe spike that already ended while retaining sensitivity to active harm.

### 7. How should simultaneous fast and slow burn alerts route?

**Answer:** They can be separate rule evidence but one incident. Group on stable service/journey/environment scope. Use the most urgent required response, include both windows in context, and avoid several human interruptions for the same burn.

### 8. When should I use inhibition?

**Answer:** Use inhibition when a stable source condition makes a target notification redundant and the matching relationship can be tested. Keep user-symptom alerts visible. Avoid large changing dependency graphs where a root guess can hide an independent simultaneous failure.

### 9. What makes a silence safe?

**Answer:** Exact matchers, authorization, named owner, incident/change reason, start and expiry, retained root and symptom coverage, audit record, verification that only intended alerts match, and removal confirmation. A silence is temporary delivery containment, not resolution.

### 10. What belongs on the first dashboard row?

**Answer:** The user journey: good/total, bad ratio, latency objective if applicable, SLO, burn and current scope. The second row proves denominator, coverage, freshness and no-data/error state. Cause details follow.

### 11. How do I prove recovery?

**Answer:** Show independent user success and stable valid SLI first. Then prove telemetry complete/current, evaluator state correct, routing/receiver delivery healthy, acknowledgement/escalation functional, resolved behavior intentional, and stability through a defined observation window. Do not use the same broken path as its only proof.

### 12. How should monitoring changes roll out?

**Answer:** Version the change, run syntax and known-input tests, replay representative history, shadow-evaluate without paging, canary to a test receiver, measure instance and notification changes, define coverage/page-volume aborts, preserve the old version, then expand gradually. Verify no-data, receiver failure and rollback behavior.

### 13. What should a runbook contain?

**Answer:** Meaning, user impact, scope, preconditions, immediate checks, hypothesis branches, authorized containment, dangerous actions, abort criteria, escalation, rollback, recovery proof, evidence preservation and known limits. Commands need expected branches; “restart service” without diagnosis and verification is not a runbook.

### 14. How do synthetics help low traffic?

**Answer:** They create repeatable black-box evidence when real events are too sparse for timely ratios. They also add load and test-data state, cover limited paths, and can disagree with users. Label and evaluate them separately, monitor the probe itself, and never let successful synthetic traffic inflate real-user success.

### 15. How do I monitor the notification system?

**Answer:** Inject a bounded known test signal, observe evaluation, route, receiver delivery and acknowledgement, and alert through an independent path when the chain exceeds its objective. Also monitor configuration convergence, evaluator failures, data freshness, receiver errors and expired silences. Avoid circular dependence on the same failed evaluator/receiver.

## Product-company interview

### Interview 1: “Design alerting for a payment API.”

**Strong structure:**

1. Define payment operations and terminal correctness states.
2. Define valid good/total populations, coverage and freshness.
3. Negotiate objectives and error-budget policy.
4. Page on user-impact burn and imminent hard limits; ticket slower risk.
5. Use cause signals for diagnosis.
6. Design state, no-data/error and low-traffic behavior.
7. Group by incident scope and preserve stable identity.
8. Define owner, runbook, receiver, acknowledgement and escalation.
9. Test, shadow, canary, rollback and monitor the monitoring path.
10. Measure page quality and improve from incidents.

**Senior answer:** “I would not begin with CPU thresholds. I would define authorization, capture, refund and status-retrieval journeys with valid terminal outcomes and separate correctness from latency. Each SLI exposes denominator, coverage and freshness. Page policies protect agreed error budgets with long and short active-burn windows, while irreversible queue, certificate or storage limits can have cause-based pages with tested actions. Rules produce bounded stable instances, and policy groups one customer incident across regions/services while retaining a root and user-symptom signal. Every page has an owner, runbook, abort, rollback and independent recovery proof. Before rollout I test known series, gaps, resets, low traffic, no data, route matching, receiver failure and resolved behavior; then shadow and canary. I also test the alert path independently and review precision, recall, duplicates, pages per incident and time to action.”

### Interview 2: “CPU is 95%. Should we page?”

**Answer:** “Not from utilization alone. I would check whether CPU is saturated—run queue, throttling, steal, latency and user SLI—and whether there is time-critical action. If users are healthy and autoscaling/capacity safely handles it, dashboard or ticket may be correct. If a hard capacity limit will cause imminent harm and the runbook has a safe action, a cause page can be justified. I would document the causal chain and validate it with load evidence.”

### Interview 3: “Our dashboard is green but customers complain.”

**Answer:** “I would distrust presentation first, not customers. I would inspect raw query status, numerator, denominator, expected segments, coverage, freshness, variables and transformations. I would compare a controlled journey and terminal business state. Common defects are missing-to-zero, wrong time range, filtered region, stale last value, ingestion/parser loss and an SLI that measures HTTP success but not business correctness. Recovery requires corrected evidence and user outcome, not recoloring.”

### Interview 4: “How do you reduce alert fatigue?”

**Answer:** “Measure it as a reliability problem. Classify true/false pages and significant missed events; track duplicates, pages per incident/shift, acknowledgements and actions. Remove or downgrade nonactionable pages, align symptoms to SLO risk, group by incident, deduplicate retries, use stable tested inhibition, make silences exact and expiring, automate safe repetitive action, and improve runbooks. I would never optimize page count alone because deleting alerts can destroy recall.”

### Interview 5: “What is the difference among grouping, dedupe, inhibition and silence?”

**Answer:** “Deduplication handles repeated delivery of the same identity. Grouping combines different related instances into one notification. Inhibition suppresses a target because a matching source alert is active. Silence is an explicit bounded matcher that mutes notifications regardless of cause. I test each separately and preserve underlying instance state and user-symptom coverage.”

### Interview 6: “Explain multiwindow multi-burn-rate alerting.”

**Answer:** “Allowed bad fraction is one minus the SLO. Divide observed bad ratio by that fraction to get burn. A long window proves significant budget consumption; a shorter window proves the burn is still active. Both must exceed the chosen threshold. Multiple threshold/window pairs cover fast severe and slower sustained incidents, but they should group into one incident. Published 14.4x/1h+5m and 6x/6h+30m values are starting examples for a 30-day objective, not universal settings.”

### Interview 7: “How do you test alerts?”

**Answer:** “Like code plus distributed control flow: syntax and schema; deterministic series with boundary/equality/gap/reset/late/no-data cases; state timing; label cardinality and annotations; routing/grouping/inhibition/silence positive and negative cases; receiver timeout/retry/ack/escalation; dashboard raw-query and transform tests; shadow evaluation; canary notification to a safe receiver; rollback; monitoring-path failure; and periodic known-signal drills. Passing unit tests does not prove production data quality or human action.”

### Interview 8: “How do you design an incident dashboard?”

**Answer:** “Top-down by decision. First: user outcome, SLO and burn. Second: denominator, coverage, freshness and missing/error state. Third: scope and changes. Fourth: traffic/errors/latency/saturation and dependencies. Fifth: links to bounded logs/traces/profiles. Every panel names unit, window and scope, supports color-independent reading, and has a description. I constrain query cost and test known, missing and stale input. The dashboard links to ownership and the runbook.”

### Interview 9: “How do you alert on a low-traffic service?”

**Answer:** “First determine the value and impact of one failure. A percentage from ten events is volatile but might still represent a critical workflow. Options are longer windows, aggregation across related operations, controlled synthetics, product resilience, or stakeholder SLO change. Synthetic results stay separate from real users and carry vantage/coverage limits. I would use counts and confidence alongside ratios and avoid a one-size threshold.”

### Interview 10: “The page provider is down. Now what?”

**Answer:** “Treat it as loss of the reliability control path. Use an independently monitored out-of-band channel and incident process, verify evaluator state and queued/failed notifications, preserve attempt evidence, restore or fail over within an authorized design, then send bounded test notifications and prove acknowledgement/escalation. Avoid replaying every historical alert into a storm. User health remains independently assessed.”

### Interview red flags

- “Green means healthy.”
- “Restart the monitoring server.”
- “Set every missing value to zero.”
- “Page on anything unusual.”
- “Add a longer delay to stop noise.”
- “Silence everything during maintenance.”
- “Two replicas means alerting is HA.”
- “Synthetic checks prove customers are fine.”
- “Alert resolved, incident closed.”

Each statement skips a boundary or manufactures proof.

## Independent transfer and rubric

### Unscored transfer rehearsal

The following visible scenario is for rehearsal only. It **cannot** satisfy `ASM-0075` because an independent transfer must be unseen.

Scenario: a scheduled batch runs once per hour. Its success series disappears after successful completion. A generic “missing series for five minutes” page wakes on-call after every run. The dashboard fills missing success with zero and shows failure. A maintenance silence suppresses the page for a month.

Reasoning outline:

1. The series lifecycle is ephemeral; disappearance may be expected.
2. The dashboard zero is invented, not an observed failure.
3. A five-minute absence rule does not model the hourly job deadline.
4. A month-long silence hides real missed runs.
5. Better evidence is an expected-completion event or timestamp, last successful terminal state, next deadline, freshness since required completion, and separate evaluator health.
6. Page only when the job misses the product deadline and a human can act; ticket slower trend or cleanup issues.
7. Replace the broad silence with a tested lifecycle-aware rule and exact short maintenance control.

Because the answer is visible, copying it proves nothing about transfer.

### Scored independent transfer

`ASM-0075` requires a materially different unseen disposable case. Before beginning:

- declare authorization and out-of-scope systems;
- record all help;
- confirm no real receiver can be contacted;
- do not open answered assessments or solution sections;
- use the blank response template;
- sanitize identities and paths;
- preserve raw evidence and cleanup proof.

The reviewer scores ten criteria at ten points each:

| Criterion | Points | Required evidence |
|---|---:|---|
| Independence, authorization and evidence integrity | 10 | unseen case, declared help, safe scope, sanitized evidence |
| User journey, SLI and objective model | 10 | precise good/total, scope, time, coverage and synthetic limits |
| Architecture and population reconciliation | 10 | signal-to-human map and count identities |
| Hypothesis and diagnostic quality | 10 | five ranked falsifiable hypotheses |
| State and missing-evidence correctness | 10 | timing plus zero/no-data/missing/stale/partial/error |
| Quality, burn and capacity reasoning | 10 | supported arithmetic with units and uncertainty |
| Routing, containment and human factors | 10 | group/dedupe/inhibit/silence/owner/runbook/expiry |
| Dashboard, security and governance | 10 | task view, access, secret and audit controls |
| Recovery, rollout and cleanup | 10 | canary/abort/rollback, separate recovery, exact absence |
| Communication and proof limits | 10 | clear interview response and twelve non-claims |

Passing does not automatically update mastery. It needs qualified review, a changed delayed transfer and authorized learner-ledger update.

## References and review

The draft stores fifteen official or primary reference records:

- `REF-0214` and `REF-0215`: Google SRE monitoring, golden-signal, dashboard, suppression and alert-testing guidance;
- `REF-0216`: Google SRE SLO burn-rate, multiwindow and low-traffic reasoning;
- `REF-0217`: Google SRE on-call actionability and human factors;
- `REF-0218` and `REF-0219`: Prometheus alerting rule semantics and rule testing;
- `REF-0220` and `REF-0221`: Alertmanager grouping, deduplication, routing, inhibition, silence and configuration;
- `REF-0222` through `REF-0225`: Grafana alerting, condition, no-data, missing-series, error and recovery-threshold behavior;
- `REF-0226` and `REF-0227`: Grafana dashboard construction and best practices;
- `REF-0228`: Prometheus black-box multi-target exporter pattern.

Review before promotion:

- exact Prometheus, promtool, Alertmanager and Grafana versions, provenance, licenses and compatibility;
- exact rule evaluation, restart, HA, no-data, missing-series and state-transition behavior;
- routing, grouping, deduplication, inhibition, silence, receiver retry, acknowledgement and escalation behavior;
- user-journey definitions, SLI populations, SLO stakeholder approval and error-budget policy;
- low-traffic and synthetic probe safety, identity, coverage, test-data cleanup and load;
- dashboard query correctness, performance, accessibility, privacy and responsive/browser behavior;
- secret management, permissions, audit, notification-template injection and sensitive-data exposure;
- normal-user Ubuntu lifecycle, adversarial refusal, interrupted setup and exact cleanup;
- independent technical, instructional, security, accessibility and SRE review.

| Review | Purpose |
|---|---|
| Before direct draft validation | schemas, duplicate keys, headings, commands, answer isolation, rubric parity and references |
| Before runtime work | immutable artifacts, licenses, configuration, identities, ports, network, resources, receivers, secrets and rollback |
| After canonical publication | optional Ubuntu and representative runtime, browser, accessibility, security, and formal review |
| Every six months | official specifications, product versions, defaults, examples, security guidance and references |
| After relevant release or incident | compatibility, migrations, state semantics, vulnerabilities, alert-quality findings and proof limits |

Evidence boundary: this is mentor-authored curriculum. Reading it or running its deterministic model does not prove the learner can design a valid SLO, operate a monitoring product, sustain on-call, respond to a production incident, complete an unseen transfer, retain the skill, pass an interview or hold a mastery level.
