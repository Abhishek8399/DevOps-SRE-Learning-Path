---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0028",
  "slug": "prometheus-promql-grafana",
  "aliases": ["V04-L03", "prometheus-promql-grafana"],
  "curriculumIds": ["OBS-003"],
  "route": "/book/reliability/prometheus-promql-grafana",
  "order": 3,
  "volume": "04-reliability-operations",
  "title": "Prometheus, PromQL, and Grafana: turn measurements into trustworthy decisions",
  "summary": "Learn the complete path from instrumentation and scrape discovery through Prometheus time-series identity, storage, PromQL evaluation, recording and alerting rules, and Grafana panels; diagnose missing, misleading, expensive, or stale metrics without treating a green target or attractive dashboard as proof of service health.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0026", "LES-0008"],
  "prerequisiteCurriculumIds": ["OBS-001", "DBG-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The bounded teaching model requires only Bash and Python 3 from Ubuntu. A passing model does not prove Prometheus or Grafana runtime behavior."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "Run from the Linux filesystem when possible. Windows-mounted paths can change filesystem latency and permissions, but they do not change PromQL semantics."
    },
    {
      "platform": "Prometheus",
      "version": "3.13.2 distroless linux/amd64 manifest pinned; runtime pending",
      "support": "concept-only",
      "notes": "Native histogram, feature-flag, storage, and command behavior are version-sensitive. No exact Prometheus runtime claim is made until a reviewed immutable artifact executes."
    },
    {
      "platform": "Grafana",
      "version": "13.1.1 Ubuntu linux/amd64 manifest pinned; runtime pending",
      "support": "concept-only",
      "notes": "Dashboard schema and provisioning behavior evolve. The checked-in dashboard review fixture is a teaching contract, not Grafana acceptance."
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
    "technical-lead"
  ],
  "learningObjectives": [
    "Explain how one application observation becomes a labeled time series sample and travels through discovery, scraping, relabeling, ingestion, storage, query evaluation, rules, and a dashboard.",
    "Distinguish a metric name, label, label set, series, sample, target, scrape, range vector, instant vector, evaluation timestamp, step, and lookback window without using the terms interchangeably.",
    "Choose counters, gauges, classic histograms, native histograms, and summaries from the question and aggregation requirement rather than from habit.",
    "Write and explain PromQL for rates, ratios, aggregation, vector matching, histogram quantiles, absence, and saturation while preserving the labels needed for diagnosis.",
    "Recognize counter resets, stale series, missing targets, scrape gaps, aggregation mistakes, many-to-many joins, denominator errors, and averages of averages.",
    "Design bounded labels and estimate how target count, metric count, label combinations, scrape interval, and retention affect samples, memory, disk, network, and query cost.",
    "Separate recording rules from alerting rules, test them with known input, and explain pending, firing, resolved, inhibition, silence, notification, and user-impact evidence.",
    "Design Grafana dashboards that answer operator questions, expose units and scope, distinguish no data from zero, and link summary views to diagnostic evidence.",
    "Troubleshoot from user symptom to earliest failing measurement boundary instead of editing a dashboard until the graph looks plausible.",
    "Plan a safe metrics change with schema review, canarying, cost limits, rule tests, rollback, and proof that the real user journey recovered."
  ],
  "productionSignals": [
    "service request, error, and duration measurements with stable operation and outcome labels",
    "target discovery count, scrape attempts, scrape duration, sample count, body size, and scrape failures",
    "series created, active series, head samples, ingestion rate, out-of-order or rejected samples, and label cardinality",
    "write-ahead log growth, block creation, compaction duration, retention, disk headroom, and corruption indicators",
    "query count, latency, concurrency, samples touched, time range, step, timeout, and result cardinality",
    "rule evaluation duration, failures, missed iterations, output series, pending alerts, firing alerts, and notification delivery",
    "dashboard query errors, panel no-data state, freshness, time range, variable scope, unit, and refresh interval",
    "configuration, target, instrumentation, rule, dashboard, retention, and deployment change events"
  ],
  "diagrams": [
    {
      "id": "LES-0028-DIA-001",
      "title": "Observation-to-decision metrics path",
      "direction": "left-to-right",
      "boundaries": ["application or exporter", "service discovery", "Prometheus scraper", "relabel and ingest", "TSDB", "PromQL and rules", "Grafana or Alertmanager", "operator decision"],
      "evidencePoints": ["exposed sample", "discovered target", "scrape response", "accepted series", "stored sample", "query result", "panel or alert state", "verified user outcome"],
      "textAlternative": "An application or exporter exposes measurements. Discovery produces candidate targets. Prometheus scrapes an endpoint, applies relabeling and ingestion rules, and stores accepted samples in its time-series database. PromQL evaluates stored samples for ad-hoc queries and rules. Grafana visualizes query results and Alertmanager routes notifications. An operator still needs independent user and system evidence before changing production."
    },
    {
      "id": "LES-0028-DIA-002",
      "title": "Time-series identity and cardinality multiplication",
      "direction": "hierarchical",
      "boundaries": ["metric name", "label keys", "label values", "unique label sets", "time series", "samples over time"],
      "evidencePoints": ["bounded value domains", "series per target", "targets", "scrape interval", "retention", "samples and bytes"],
      "textAlternative": "A time series is identified by one metric name plus one exact set of label key-value pairs. Every new value or value combination can create another series. Series count multiplies across dimensions and targets; each active series then receives samples at the scrape interval for the retention period."
    },
    {
      "id": "LES-0028-DIA-003",
      "title": "PromQL evaluation shapes",
      "direction": "top-to-bottom",
      "boundaries": ["evaluation timestamp", "selector", "instant or range vector", "functions", "aggregation or binary matching", "result labels and values"],
      "evidencePoints": ["time range", "step", "lookback", "window", "matching labels", "result cardinality", "warnings"] ,
      "textAlternative": "PromQL starts at an evaluation timestamp. A selector chooses series and returns the latest eligible sample as an instant vector or multiple samples as a range vector. Functions transform values, while aggregation and binary operators combine series using explicit label rules. The result has a new label set whose meaning must be reviewed before it is graphed or alerted on."
    },
    {
      "id": "LES-0028-DIA-004",
      "title": "Rule and alert state path",
      "direction": "left-to-right",
      "boundaries": ["stored samples", "rule group evaluation", "recorded series or alert expression", "pending", "firing", "Alertmanager routing", "notification", "human action"],
      "evidencePoints": ["evaluation time", "query result", "for duration", "labels", "annotations", "route", "delivery result", "runbook action"] ,
      "textAlternative": "A rule group periodically evaluates stored samples. A recording rule writes a derived series. An alerting rule creates an alert instance for every resulting label set, optionally keeps it pending for a configured duration, then marks it firing. Alertmanager groups, inhibits, silences, and routes alerts. Notification receipt is not the same as service impact or recovery."
    },
    {
      "id": "LES-0028-DIA-005",
      "title": "Dashboard question hierarchy",
      "direction": "hierarchical",
      "boundaries": ["user journey", "service outcome", "dependency and resource saturation", "instance or component detail", "logs and traces", "change evidence"],
      "evidencePoints": ["scope", "time", "unit", "threshold", "freshness", "drill-down link", "owner"] ,
      "textAlternative": "A useful dashboard begins with the user journey and service outcome, then narrows to dependency and resource saturation, individual components, correlated logs or traces, and recent changes. Every panel states its scope, time window, unit, freshness, and question; a wall of unrelated graphs reverses this hierarchy and increases cognitive load."
    }
  ],
  "commands": [
    {
      "id": "LES-0028-CMD-001",
      "question": "Are Bash and Python available, is the caller non-root, and is the bounded lab path safe before any state is created?",
      "risk": "read-only",
      "command": "bash lab.sh doctor",
      "runFrom": "drafts/LES-0028-prometheus-promql-grafana/support/lab as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "doctor reports ready=true", "meaning": "the local teaching-model prerequisites and path checks passed", "nextEvidence": "create the bounded state with LES-0028-CMD-002"},
        {"when": "doctor refuses root, a missing tool, unsafe path, or existing foreign state", "meaning": "the declared safety contract is not satisfied", "nextEvidence": "stop and correct only the reported prerequisite; never bypass the refusal"}
      ],
      "proves": "only the wrapper's current prerequisite, identity, and path checks",
      "doesNotProve": "Prometheus, PromQL, Grafana, Alertmanager, Docker, or production behavior"
    },
    {
      "id": "LES-0028-CMD-002",
      "question": "Can the lab create an owned, bounded copy of the deterministic metric fixture?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "the LES-0028 support/lab directory after doctor passes",
      "expectedBranches": [
        {"when": "setup reports state=ready and an exact state path", "meaning": "the owned fixture and sentinel were created", "nextEvidence": "inspect the baseline with LES-0028-CMD-003"},
        {"when": "setup refuses existing, replaced, or invalid state", "meaning": "ownership or lifecycle evidence is ambiguous", "nextEvidence": "use status; clean up only if the full descriptor validates"}
      ],
      "proves": "bounded local teaching state was created by this fixture",
      "doesNotProve": "that any real monitoring server accepted or queried samples",
      "cleanup": "Run bash lab.sh cleanup; cleanup validates the exact parent, prefix, owner, sentinel, manifest, and child types before removing only the lab state."
    },
    {
      "id": "LES-0028-CMD-003",
      "question": "What series, labels, time range, reset markers, and dashboard contracts exist before analysis?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "status reports state=ready with bounded counts", "meaning": "the fixture descriptor and owned files validate", "nextEvidence": "calculate a counter rate with LES-0028-CMD-004"},
        {"when": "status reports absent", "meaning": "no owned lab state exists", "nextEvidence": "run setup if the exercise has not begun"},
        {"when": "status refuses invalid or foreign state", "meaning": "cleanup and analysis cannot safely trust the path", "nextEvidence": "preserve evidence and inspect the exact reported mismatch without recursive deletion"}
      ],
      "proves": "the validated teaching fixture's declared baseline",
      "doesNotProve": "live target discovery, scrape success, current production state, or causality"
    },
    {
      "id": "LES-0028-CMD-004",
      "question": "What per-second successful-request rate does a counter window show after handling a reset?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run counter-rate",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "the result reports a positive reset-adjusted rate", "meaning": "the model detected the reset and summed non-negative increases across the window", "nextEvidence": "compare numerator and denominator before calculating an error ratio"},
        {"when": "the result refuses too few, unordered, or invalid samples", "meaning": "the window cannot support the requested rate", "nextEvidence": "repair the fixture contract rather than inventing a rate"}
      ],
      "proves": "the deterministic model's arithmetic for the checked input window",
      "doesNotProve": "exact Prometheus extrapolation, scrape timing, production traffic, or user success",
      "cleanup": "No extra resource is created beyond an atomically replaced bounded result file removed by lab cleanup."
    },
    {
      "id": "LES-0028-CMD-005",
      "question": "Which labels survive a ratio, and can numerator and denominator match one-to-one?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run vector-match",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "match=one-to-one and denominators are non-zero", "meaning": "the selected service and operation label sets can form the intended ratio", "nextEvidence": "review result scope and missing outcomes"},
        {"when": "many-to-many, missing denominator, or zero denominator is reported", "meaning": "the expression is ambiguous or undefined", "nextEvidence": "aggregate explicitly to one row per intended matching key before division"}
      ],
      "proves": "label-set compatibility in the bounded fixture",
      "doesNotProve": "that a syntactically similar production query has the same label universe",
      "cleanup": "The bounded result is removed with lab cleanup."
    },
    {
      "id": "LES-0028-CMD-006",
      "question": "What can the configured histogram buckets prove about an SLO threshold and a percentile?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run histogram",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "cumulative buckets are monotonic and include +Inf", "meaning": "threshold counts and a bounded interpolation can be computed", "nextEvidence": "state the bucket-width uncertainty and compare with the exact SLO threshold"},
        {"when": "buckets decrease, boundaries differ, or +Inf is missing", "meaning": "the distribution contract is invalid or incomplete", "nextEvidence": "stop aggregation and repair instrumentation or fixture data"}
      ],
      "proves": "bounded threshold and interpolation behavior for the supplied cumulative buckets",
      "doesNotProve": "the exact latency of individual requests or quantile accuracy outside bucket resolution",
      "cleanup": "The bounded result is removed with lab cleanup."
    },
    {
      "id": "LES-0028-CMD-007",
      "question": "How many series can the proposed label domains create before targets and replicas multiply them?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run cardinality",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "all domains are bounded and the computed budget is below the fixture limit", "meaning": "the proposal fits this declared local budget", "nextEvidence": "compare predicted and observed series after a canary"},
        {"when": "a domain is unbounded or the budget is exceeded", "meaning": "the design can create uncontrolled cost or instability", "nextEvidence": "remove or bucket the unbounded dimension before rollout"}
      ],
      "proves": "a worst-case combinatorial estimate from declared domains",
      "doesNotProve": "actual active series, compression, churn, query cost, or production capacity",
      "cleanup": "The bounded result is removed with lab cleanup."
    },
    {
      "id": "LES-0028-CMD-008",
      "question": "Does the synthetic alert remain pending long enough, fire only for sustained impact, and resolve after recovery?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run alert-state",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "the timeline matches inactive to pending to firing to resolved", "meaning": "the model rule and for-duration match the declared sequence", "nextEvidence": "verify ownership, user impact, annotations, and routing separately"},
        {"when": "the state changes too early, too late, or never resolves", "meaning": "the threshold, evaluation interval, missing-data policy, or state logic is defective", "nextEvidence": "repair the rule contract and repeat the deterministic test"}
      ],
      "proves": "the model's alert-state transition for known inputs",
      "doesNotProve": "Prometheus rule-engine behavior, Alertmanager delivery, paging quality, or production impact",
      "cleanup": "The bounded result is removed with lab cleanup."
    },
    {
      "id": "LES-0028-CMD-009",
      "question": "Does the dashboard contract state a question, unit, scope, freshness, no-data behavior, and drill-down for every panel?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run dashboard-contract",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "every required field is present and query identifiers resolve", "meaning": "the reviewable teaching contract is internally complete", "nextEvidence": "execute the queries and perform real visual and operator-task review in an exact Grafana runtime"},
        {"when": "a unit, scope, no-data rule, link, owner, or query is missing", "meaning": "the panel can mislead or strand an operator", "nextEvidence": "repair the contract before visual polish"}
      ],
      "proves": "static completeness of the bounded dashboard teaching contract",
      "doesNotProve": "Grafana schema acceptance, rendering, accessibility, query correctness, or operational usefulness",
      "cleanup": "The bounded result is removed with lab cleanup."
    },
    {
      "id": "LES-0028-CMD-010",
      "question": "Can the learner locate the earliest boundary changed by a high-cardinality label incident?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run incident",
      "runFrom": "the LES-0028 support/lab directory after setup",
      "expectedBranches": [
        {"when": "the answer identifies series identity growth before blaming Grafana", "meaning": "the investigation follows the data path and distinguishes symptom from cause", "nextEvidence": "run the independent transfer without opening its reviewer-only rubric"},
        {"when": "the answer changes retention or dashboard refresh first", "meaning": "the mitigation does not stop new-series creation and may worsen load", "nextEvidence": "return to metric and label-set evidence at ingestion"}
      ],
      "proves": "only the deterministic incident model result and submitted explanation",
      "doesNotProve": "learner mastery, production readiness, or an independently reviewed transfer",
      "cleanup": "The bounded response file is removed with lab cleanup."
    },
    {
      "id": "LES-0028-CMD-011",
      "question": "Did every model case pass and did cleanup remove only the exact owned state?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "the LES-0028 support/lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "verification reports all cases passed and final_state=absent", "meaning": "the checked deterministic contracts and lifecycle passed on that environment", "nextEvidence": "retain the transcript while preserving the runtime and mastery boundaries"},
        {"when": "any case or absence proof fails", "meaning": "the draft lab is not acceptable", "nextEvidence": "inspect the first failing assertion and do not publish or widen claims"}
      ],
      "proves": "the exact static, deterministic, refusal, lifecycle, and cleanup checks printed by this verifier",
      "doesNotProve": "Prometheus, Grafana, Alertmanager, browser, provider, production, or learner mastery",
      "cleanup": "The verifier calls the same validated cleanup path and fails unless final state is absent."
    }
  ],
  "labs": [
    {
      "id": "LES-0028-LAB-001",
      "title": "Guided metrics semantics and PromQL reasoning model",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS normal user with Bash and Python 3; no Docker, network, ports, sudo, or package installation",
      "timeMinutes": 90,
      "privilege": "normal user; the wrapper refuses UID 0",
      "network": "none; all fixtures are local and deterministic",
      "changes": ["one lesson-specific temporary directory", "owned fixture copies", "bounded JSON result files"],
      "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "a child is a symlink or unexpected type", "fixture schema is invalid", "a result would exceed the declared bound"],
      "recovery": "Run status. If and only if the complete descriptor validates, run cleanup and repeat setup. Preserve refused foreign or ambiguous state for review.",
      "cleanupProof": "Cleanup validates parent, basename prefix, real path, UID, sentinel, manifest, and child types, removes only the owned directory, and proves exact absence.",
      "path": "drafts/LES-0028-prometheus-promql-grafana/support/lab"
    },
    {
      "id": "LES-0028-LAB-002",
      "title": "Independent missing-signal and cardinality incident",
      "mode": "independent",
      "environment": "An instructor-provided or learner-created unseen disposable local case with a changed label universe, counter reset, missing series, distribution metric, and ambiguous dashboard panel; the guided fixture alone does not satisfy independence",
      "timeMinutes": 75,
      "privilege": "normal user; no elevated operation",
      "network": "none unless the separately authorized unseen local case explicitly declares otherwise; shared, production, employer, and online cloud systems remain prohibited",
      "changes": ["one learner-owned sanitized response outside the guarded LES-0028 lab state", "only resources declared by the unseen disposable case"],
      "abortConditions": ["reviewer-only answer material is visible", "state validation fails", "the learner proposes destructive host or production action", "the evidence cannot distinguish the proposed hypothesis"],
      "recovery": "Return to baseline evidence and submit a revised hypothesis. Do not reveal the answer-isolated assessment solution before independent review.",
      "cleanupProof": "Use the unseen case's own manifest to prove exact absence of every resource it created. Guided lab cleanup covers only its declared state and never claims to remove the learner response.",
      "path": "drafts/LES-0028-prometheus-promql-grafana/support/lab"
    }
  ],
  "incidents": [
    {
      "id": "LES-0028-INC-001",
      "signal": "Grafana panels show no data immediately after a deployment, but the service still answers requests.",
      "firstThought": "No data is a measurement-path symptom, not zero traffic and not proof that the service is down. Find the earliest boundary where an expected series disappears.",
      "safePath": "Confirm user impact and scope, inspect deployment and instrumentation changes, target discovery, scrape health and body, relabel drops, ingestion rejection, direct PromQL selection, query time and labels, then Grafana data source and panel scope.",
      "trap": "Changing panel time range, converting null to zero, or restarting Grafana can hide the symptom while the measurement path remains broken."
    },
    {
      "id": "LES-0028-INC-002",
      "signal": "Prometheus memory and query latency rise sharply after a new request_id label is deployed.",
      "firstThought": "An unbounded value in a series identity creates churn and multiplicative active-series cost; Grafana is a consumer of that cost, not the origin.",
      "safePath": "Stop or roll back the offending instrumentation cohort, measure new-series and active-series change, preserve user-impact metrics, remove the unbounded label, verify ingestion and query recovery, and decide how retained historical series will age out.",
      "trap": "Increasing memory, shortening dashboard ranges, or reducing refresh frequency may delay failure but does not stop series creation."
    },
    {
      "id": "LES-0028-INC-003",
      "signal": "An error-rate alert fires even though successful and failed request counters look individually reasonable.",
      "firstThought": "A ratio can be wrong when numerator and denominator use different label scopes, windows, reset behavior, or traffic populations.",
      "safePath": "Inspect raw series and labels, use reset-aware rates, aggregate numerator and denominator to the same matching key, exclude or define missing outcomes explicitly, test zero traffic, and replay the rule with known input.",
      "trap": "Raising the threshold or adding a longer for-duration suppresses evidence without proving that the arithmetic or population is correct."
    },
    {
      "id": "LES-0028-INC-004",
      "signal": "A dashboard reports p95 latency below the objective while users report sustained slowness.",
      "firstThought": "A percentile is conditional on the measured population, bucket layout, aggregation, window, and retained labels; it can be numerically correct and operationally irrelevant.",
      "safePath": "Verify the user journey and scope, histogram type and units, bucket boundaries, rate window, aggregation labels, excluded failures and timeouts, traffic weighting, scrape gaps, and direct request evidence such as traces or logs.",
      "trap": "Averaging per-instance quantiles or trusting a green threshold line discards distribution and population information."
    }
  ],
  "assessmentIds": ["ASM-0067", "ASM-0068", "ASM-0069"],
  "referenceIds": ["REF-0167", "REF-0185", "REF-0186", "REF-0187", "REF-0188", "REF-0189", "REF-0190", "REF-0191", "REF-0192", "REF-0193", "REF-0194", "REF-0195", "REF-0196", "REF-0197", "REF-0198"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-10",
  "reviewAfter": "2027-02-10",
  "limitations": [
    "The current package is quarantined and is not loaded by the website or canonical registry.",
    "The bounded lab is a deterministic teaching model and does not implement the Prometheus query engine, TSDB, scraper, rule engine, Alertmanager, or Grafana renderer.",
    "Exact Linux/amd64 image manifests are recorded for Prometheus 3.13.2, Alertmanager 0.33.1, Grafana 13.1.1 and Python 3.12.13, but offline availability, product configuration validation, runtime lifecycle evidence and browser review are pending.",
    "Official current documentation was reviewed, but feature flags, native histogram behavior, configuration schema, dashboard schema, and release support remain version-sensitive.",
    "No project artifact, model answer, passing verifier, reading-progress state, or mentor-generated output changes learner competency or proves mastery."
  ]
}
---

# Prometheus, PromQL, and Grafana: turn measurements into trustworthy decisions

## What you see and first thought

You are on call. A dashboard that normally shows request traffic now has one blank panel, one red panel, and one reassuring green panel. The service owner asks, “Is Prometheus broken, is Grafana broken, or is the application broken?”

Do not choose one yet. The first useful thought is:

> A graph is the end of a measurement path. I need to identify the question, the expected series, the evaluation time, and the earliest boundary where evidence diverges.

That sentence protects you from five common mistakes:

1. **No data is not zero.** Zero is a valid numeric observation. No data means the query produced no eligible series or samples for that evaluation.
2. **A green target is not a healthy service.** It says the configured scrape request succeeded according to the target state. The application can still return errors to users or expose meaningless metrics.
3. **A graph is not the database.** Grafana asks a data source a query. Its time range, step, variables, transformations, and no-data settings can change what you see.
4. **A valid PromQL expression is not necessarily a valid question.** The engine can correctly calculate a ratio across the wrong population.
5. **A page is not proof of impact.** An alert is a rule state. Confirm the user journey and blast radius independently.

Use FRAME immediately:

- **Frame:** Which user operation is affected? Which regions, tenants, versions, or endpoints? When did the symptom start? What changed?
- **Retrieve:** What series should exist? Which target should expose it? What labels and units define it? What is the newest sample timestamp?
- **Analyze:** Could the break be instrumentation, discovery, scrape transport, relabeling, ingestion, storage, query semantics, rule state, data-source configuration, or visualization?
- **Make:** Choose the smallest reversible evidence-gathering move. A direct selector is safer and more informative than restarting the monitoring stack.
- **Evaluate:** Did the evidence confirm the prediction? After mitigation, verify both the measurement path and the real user operation.

The compact path is:

```text
user operation
  -> application measurement
  -> /metrics exposition
  -> discovered target
  -> scrape response
  -> accepted labeled series
  -> stored timestamped sample
  -> PromQL evaluation
  -> recording or alert rule
  -> Grafana panel or Alertmanager route
  -> human decision
```

When a panel looks wrong, walk left. When a production change is proposed, walk right and state how you will verify the real outcome.

## Terms before commands

### Observation, metric, series, and sample

An **observation** is one measured event or state: a request completed in 240 milliseconds, a queue contains 17 messages, or a process used 384 MiB of memory.

A **metric** is a named measurement family with a defined meaning and unit, such as `http_requests_total` or `http_request_duration_seconds`. A metric name alone does not identify one stored stream.

A **label** is a key-value dimension attached to a metric, such as `method="GET"` or `status="500"`. Labels make aggregation and filtering powerful, but every unique label set creates another identity.

A **time series** is one metric name plus one exact label set. These are different series:

```text
http_requests_total{service="checkout",method="GET",status="200"}
http_requests_total{service="checkout",method="GET",status="500"}
```

A **sample** is a value associated with a timestamp inside one series. A series is the identity; samples are its history.

The memorable model is:

```text
metric name + complete label set = series identity
series identity + timestamp + value = sample
```

### Cardinality and churn

**Cardinality** is the number of distinct series in a set. If a metric has 3 methods, 6 status groups, 4 regions, 20 instances, and 2 versions, the theoretical maximum is:

```text
3 x 6 x 4 x 20 x 2 = 2,880 series
```

Not every combination must occur, so this is a budget estimate, not an observed count. Add `user_id`, `request_id`, a raw URL, an email address, or another unbounded value and the series count can grow with traffic. That ongoing creation and disappearance of identities is **churn**.

Cardinality costs are not just disk bytes. Active series occupy memory; samples use network, write-ahead log, storage, and compaction work; index entries make selectors and joins more expensive; recording rules can create still more series.

### Target, discovery, scrape, and exporter

A **target** is an endpoint Prometheus intends to scrape. **Service discovery** produces candidate targets and metadata. **Relabeling** can keep, drop, or rewrite target labels before scraping, and metric relabeling can change or drop samples after scraping.

A **scrape** is Prometheus fetching an exposition endpoint at an interval. A successful HTTP response is only one boundary. The body can be empty, malformed, unexpectedly large, missing a metric, or semantically wrong.

An **exporter** translates another system's state into Prometheus exposition format. It owns a translation boundary. The exporter can be healthy while the observed dependency is inaccessible or stale.

### Counter and reset

A **counter** represents a cumulative total that normally increases and may reset when a process restarts. Raw counter values are usually not comparable across replicas or restarts. The operational question is often a rate over a window.

For example, `rate(http_requests_total[5m])` estimates average per-second increase over the selected window and accounts for counter resets. A visible decrease in a raw counter is not “negative traffic”; it is evidence of a reset, replacement, or invalid instrument.

### Gauge

A **gauge** represents a value that may rise or fall: queue depth, temperature, active requests, or free bytes. Applying counter-only reasoning to a gauge invents reset semantics that do not exist. A current gauge value is also not necessarily representative of the whole incident window.

### Histogram, bucket, summary, and quantile

A **distribution** describes many observations such as request durations. A classic Prometheus **histogram** exposes cumulative bucket counters ending in `_bucket`, plus `_count` and `_sum`. The `le` label means “less than or equal to this upper boundary.” The `+Inf` bucket counts all observations.

A **native histogram** stores a histogram sample as one series with a dynamic bucket representation. Availability and exact behavior are version-sensitive.

A **summary** calculates configured quantiles in the instrumented process. Those quantiles generally cannot be meaningfully aggregated across replicas. Never average p95 values from multiple instances and call the result a service p95.

A **quantile** answers a rank question. p95 is the value at or below which about 95 percent of observations fall. It does not say the slowest 5 percent are close to that value, does not identify which users were slow, and does not prove the measured population includes timeouts or failures.

### Instant vector, range vector, scalar, and string

PromQL works with typed shapes:

- An **instant vector** contains zero or more series, with one eligible sample per series at an evaluation timestamp.
- A **range vector** contains zero or more series, with a window of samples per series, such as `[5m]`.
- A **scalar** is one floating-point value.
- A **string** exists in the language model but is rarely central to operational queries.

`http_requests_total` is an instant-vector selector. `http_requests_total[5m]` is a range-vector selector. `rate()` consumes a counter range vector and returns an instant vector.

### Evaluation time, query range, step, lookback, and window

An **instant query** evaluates an expression once at a specified time. A **range query** evaluates the same expression repeatedly between start and end times. **Step** is the spacing between evaluation timestamps; it is not the scrape interval and not the range window.

The **range window** in `[5m]` tells a function which historical samples to consider at each evaluation. The **lookback** determines how far an instant selector may search for the latest eligible sample. These clocks can interact with scrape gaps and make a line appear continuous or disappear. Always record dashboard range, query step, scrape interval, rule evaluation interval, and function window separately.

### Aggregation and vector matching

Aggregation such as `sum by (service)` combines multiple series and produces new label sets. Labels not kept by `by` are discarded. `without` names labels to remove and preserves the rest.

Binary operations between vectors do not join rows by position. They match label sets. One-to-one, many-to-one, and one-to-many relationships require deliberate keys and, when necessary, explicit modifiers. Unexpected many-to-many matching is not a cosmetic error; it means the intended population is ambiguous.

### Recording rule and alerting rule

A **recording rule** periodically evaluates PromQL and stores the result as a new series. It can make repeated dashboard queries faster and centralize a reviewed definition. It also consumes storage, can hide source-label mistakes, and creates dependency ordering.

An **alerting rule** periodically evaluates PromQL and creates alert instances from resulting label sets. `for` can require a condition to remain active before firing. Rule evaluation, alert state, Alertmanager routing, and notification delivery are separate boundaries.

### Grafana dashboard, panel, data source, variable, and transformation

A Grafana **data source** defines how Grafana reaches a query system such as Prometheus. A **dashboard** contains panels and controls. A **panel** issues queries and visualizes results. A **variable** changes query scope. A **transformation** changes returned data before visualization.

At 02:00, the panel title must tell the operator the question. The unit, scope, time range, freshness, threshold meaning, no-data behavior, and drill-down must be visible or quickly discoverable. Attractive layout is secondary to decision quality.

## Architecture map

### The complete path

```text
 DATA PLANE: application request

 client -> load balancer -> service -> dependency
                         |          |
                         |          +-- dependency measurements
                         +------------- request measurements

 MEASUREMENT PLANE

 app/exporter --exposition--> target endpoint
      ^                            |
      |                            v
 instrumentation             Prometheus scrape
                                   |
                         target + metric relabeling
                                   |
                                   v
                        Head memory + WAL
                                   |
                         immutable TSDB blocks
                                   |
                    +--------------+--------------+
                    |                             |
               PromQL/API                   rule groups
                    |                       /          \
                 Grafana             recorded series  alerts
                    |                                  |
              operator view                       Alertmanager
                                                       |
                                                  notification
```

There are two important separations.

First, the application request path can fail while the monitoring path succeeds. A target can expose metrics perfectly while every checkout fails because a database is unavailable. Second, the monitoring path can fail while the application succeeds. Losing metrics does not automatically mean losing service.

### Control plane and data plane

Prometheus configuration, discovery rules, scrape jobs, relabeling, rule files, retention flags, and Grafana provisioning are control-plane inputs. Exposed samples, scrape responses, stored samples, query results, and alert instances are data-plane evidence.

A committed configuration proves desired text. It does not prove the running process loaded it, discovered the target, accepted the sample, evaluated the intended rule, or served the dashboard version you reviewed.

### State ownership

| Component | State it owns | Important failure | Evidence boundary |
|---|---|---|---|
| Application/client library | instrument definitions and current cumulative process state | wrong type, unit, label, missing outcome | direct exposition and code/config version |
| Exporter | translated dependency state | stale cache, partial permissions, wrong mapping | exporter self-metrics plus dependency evidence |
| Discovery | candidate targets and metadata | missing or duplicate target | discovered-target view and discovery logs |
| Scraper | schedule and last scrape outcome | timeout, parse error, oversized response | target status, scrape metrics, bounded response inspection |
| Relabeling | target and sample selection | silent drop or identity rewrite | rendered config and before/after label evidence |
| TSDB Head and WAL | recent samples and crash-recovery log | memory pressure, disk pressure, rejected data | ingestion and storage self-metrics, logs, filesystem evidence |
| Immutable blocks/index | retained history and label index | corruption, compaction backlog, retention surprise | block, compaction, disk, query and log evidence |
| PromQL engine | evaluation and result shape | expensive selector, wrong match, timeout | exact expression, time, step, warnings, result labels |
| Rule manager | periodic derived series and alert states | slow or failed evaluation, missed interval | rule health, last evaluation, errors, output series |
| Alertmanager | grouping, inhibition, silences, routing, notifications | suppressed or misrouted alert | alert state, routing tree, silence/inhibition, receiver result |
| Grafana | data-source config, dashboard definitions, variables, transformations | stale scope, wrong unit, no-data masking | provisioned version, inspector, query request/result, panel config |

### Why pull changes the failure model

In the common Prometheus model, the server pulls a target. This lets the server control cadence and observe target availability, but it also means network reachability is from Prometheus to the target, not from the user or target to Prometheus. Firewalls, DNS, service discovery, proxies, network policies, and TLS identities must be reasoned about from the scraper's namespace.

Pull does not make data loss impossible. A slow scrape can time out. A target can restart between scrapes. Short-lived work can disappear before observation. Remote write, federation, agents, and push gateways introduce additional queues and ownership boundaries that must be taught separately rather than assumed.

## Request or state path

Follow one counter from code to a dashboard.

### 1. Define the measurement contract

Suppose the user journey is “submit payment” and the question is “What fraction of completed attempts failed by stable failure class?” A useful metric contract might include:

```text
payment_attempts_total{
  service="payments",
  operation="submit",
  outcome="success|failure",
  failure_class="none|validation|dependency|internal"
}
```

The labels are bounded. There is no customer ID, card number, request ID, email, raw exception, or raw URL. The unit is attempts. The counter increments exactly once when the operation reaches a defined terminal outcome. Abandoned or timed-out work needs an explicit definition rather than silent exclusion.

Before code is deployed, review:

- What event increments the metric?
- Can retries count twice?
- Which outcomes are mutually exclusive?
- Can every attempt reach a terminal outcome?
- Which label values are bounded by code or schema?
- Does any label expose personal, secret, regulated, or attacker-controlled data?
- What user and system evidence will validate the metric?

### 2. Expose samples

An instance maintains cumulative counter state and exposes it. A simplified exposition could look like:

```text
# HELP payment_attempts_total Completed payment attempts by outcome.
# TYPE payment_attempts_total counter
payment_attempts_total{service="payments",operation="submit",outcome="success",failure_class="none"} 12842
payment_attempts_total{service="payments",operation="submit",outcome="failure",failure_class="dependency"} 73
```

The HELP text and TYPE declaration help humans and tools, but they do not verify the implementation. The values are cumulative for that process identity and can reset on restart.

### 3. Discover and scrape the target

Discovery produces an address and metadata. Target relabeling decides whether to keep it and what target labels such as `job` and `instance` become. Prometheus performs an HTTP scrape. Metric relabeling may then keep, drop, or rewrite individual samples before ingestion.

Ask four different questions:

1. Was the target discovered?
2. Was the scrape request successful and recent?
3. Did the response contain the expected family and label set?
4. Was the sample accepted under the identity the query expects?

One green `up` result does not answer all four.

### 4. Store recent and historical samples

Accepted samples enter the in-memory Head and are protected for crash recovery by the write-ahead log. Prometheus later writes persistent blocks and compacts blocks. The label index makes selectors possible.

This is why series count matters even at a modest sample rate. Every active identity has memory and index overhead. Churn creates index and compaction work. Retention controls historical availability, not current Head capacity by itself.

### 5. Evaluate the error ratio

A service-level failure ratio needs reset-aware rates and the same population in numerator and denominator:

```promql
sum by (service, operation) (
  rate(payment_attempts_total{outcome="failure"}[5m])
)
/
sum by (service, operation) (
  rate(payment_attempts_total[5m])
)
```

Read it from the inside out:

- Each selector chooses counter series.
- `[5m]` provides a sample window at each evaluation time.
- `rate()` produces estimated attempts per second per input series and handles resets.
- `sum by (service, operation)` creates one numerator and denominator series per kept key.
- Division matches those label sets.

The result is a fraction, not a percentage. Multiply by 100 only when the consumer expects percent and make the unit explicit. Define zero traffic and missing outcomes before alerting.

### 6. Record, alert, and visualize

A recording rule can store the reviewed ratio or its numerator and denominator. Keeping numerator and denominator separately often preserves more diagnostic value and avoids hiding a zero denominator.

An alerting rule can compare the ratio with a threshold and require a sustained `for` duration. The rule should include ownership, severity, a concise impact statement, dashboard and runbook links, and labels stable enough for grouping.

Grafana queries the same recorded series or expression. A useful panel states:

```text
Question: What fraction of completed payment attempts failed in each operation?
Unit: percent
Scope: production, selected region, all active versions
Window: five-minute rate evaluated over dashboard range
No data: measurement path unavailable; never convert to zero
Drill-down: numerator, denominator, outcome classes, deploy events, traces
```

### 7. Verify the decision

If a mitigation is applied, verify:

- the user operation succeeds from an appropriate vantage point;
- failure numerator falls for the intended population;
- total traffic denominator remains plausible;
- target and scrape freshness recover;
- no new series, ingestion, storage, or query saturation was introduced;
- alerts resolve for the expected reason;
- the dashboard has current data and the exact intended scope.

Metrics support a decision. They do not replace verification of the real operation.

## Failure zoom

### Failure family 1: the expected series does not exist

Start at the leftmost owned boundary:

```text
instrument absent
  -> instrument exists but code path never executes
  -> exposition omits it
  -> target not discovered
  -> scrape fails
  -> relabel drops it
  -> ingestion rejects it
  -> query selects wrong name or labels
  -> query time has no eligible sample
  -> Grafana variable or transformation hides it
```

The safest discriminating sequence is direct and narrow: confirm the real operation, inspect the target's bounded exposition, inspect target/discovery state, run a direct selector with explicit time and labels, then inspect Grafana's actual request. Restarting components destroys useful state and tests several hypotheses at once.

### Failure family 2: the series exists but means the wrong thing

This is more dangerous because dashboards stay green. Examples:

- A counter increments at request start, so cancelled work looks successful.
- Retries increment attempts but the denominator is called users.
- Duration seconds are displayed as milliseconds.
- `status` changes from a bounded class to raw error text.
- One version emits `result="ok"`; another emits `outcome="success"`.
- A histogram omits timeouts because only completed requests are observed.
- A gauge is summed across replicas even though each reports the same cluster-wide value.

Validate semantics with controlled operations and another evidence source. A plausible number is not validation.

### Failure family 3: the query changes the population

PromQL can silently remove labels during aggregation. A numerator grouped by service and region will not match a denominator grouped only by service. Filtering `status=~"5.."` in one side and all terminal outcomes in the other may or may not match the stated question. Many-to-one matching can duplicate a value when group modifiers are used carelessly.

Before trusting a ratio, print the numerator and denominator separately with their result labels. State in words which events each side counts.

### Failure family 4: counter resets and scrape gaps

Subtracting the first raw counter value from the last fails across resets. `rate()` is designed for counters, but it still needs enough samples and a window appropriate to the scrape interval. A window barely larger than one scrape interval is fragile. A very long window can hide a fast incident.

Scrape gaps also change which samples are eligible. A line can disappear because no sample is within lookback. A range function can have too few points. Graph interpolation by the client must not be mistaken for stored data.

### Failure family 5: cardinality incident

The trigger is usually a new label or newly unbounded value. The causal chain can be:

```text
new label values
  -> active series and churn increase
  -> client/export payload grows
  -> scrapes slow or time out
  -> Prometheus Head memory and WAL grow
  -> compaction/query work rises
  -> rule evaluations miss intervals
  -> dashboards time out
  -> alerts become late or absent
```

The user-visible symptom may be “Grafana slow,” but the first bad assumption is the series schema. Roll back or disable the offending instrumentation safely before buying capacity.

### Failure family 6: histogram and percentile error

Classic buckets are cumulative. To aggregate classic histograms for a quantile, preserve `le` until `histogram_quantile()` evaluates the aggregate. Bucket boundaries must be compatible. The estimate is limited by bucket layout and interpolation assumptions.

Summaries expose precomputed per-instance quantiles. Adding or averaging those quantiles is statistically invalid because the underlying distributions and request counts are lost.

Prefer direct threshold ratios for threshold SLO questions. If the objective is “99 percent below 300 ms,” a correctly placed 300 ms bucket can answer the threshold question more directly than a p99 estimate.

### Failure family 7: alert state and delivery diverge

An alert expression can be correct while the alert is pending. It can fire while Alertmanager inhibits it. It can reach Alertmanager but fail receiver delivery. A silence can be intentional or stale. A notification can arrive after impact has ended. Each transition has its own timestamp and owner.

Never respond to “we received no page” with “there was no alert” until you inspect rule state, Alertmanager state, route, inhibition, silence, and receiver evidence separately.

### Failure family 8: dashboard tells the wrong story

A dashboard may use the wrong data source, tenant, environment variable, time zone, range, step, unit, transformation, or null handling. It can repeat a panel for hundreds of label values and create a query storm. It can show an average that hides the failing cohort.

Use Grafana query inspection to capture the exact request and response, but verify important results directly against the data source. The dashboard is a client with configuration, not an authority.

## Internals and state ownership

### Scrape scheduling and timestamps

Prometheus schedules scrapes per target. The scrape interval is the intended cadence, not a guarantee that every scrape completes exactly on that boundary. Scrape duration, timeouts, scheduling work, network latency, and target behavior affect sample timing.

Prometheus normally assigns scrape timestamps. Targets can expose explicit timestamps in some formats, but accepting producer clocks changes the failure model: skew, duplicates, and out-of-order data become producer concerns. Treat time ownership as an explicit contract.

### Staleness

Time-series systems need to stop returning an old series after a target disappears or a label set is no longer exposed. Prometheus uses staleness handling so an instant selector eventually stops returning obsolete data. That is why an instant query at two nearby timestamps can have different series membership even if no value visibly fell to zero.

Operational lesson: absence, zero, and stale are three different states. Define how dashboards and alerts handle each one.

### Head, WAL, blocks, and index

Recent samples live in the Head. The write-ahead log supports recovery after a crash. Persistent data is organized into blocks that contain chunks, metadata, and an index; background compaction combines blocks. Deletion markers and retention have their own lifecycle.

The local TSDB is a single-node database, not an automatically replicated durable service. High availability commonly uses independent Prometheus replicas and a separate query or long-term-storage layer, which introduces deduplication and consistency trade-offs.

Never place production TSDB storage on an unsupported filesystem merely because it mounts successfully. Filesystem semantics, latency, locking, and crash behavior matter.

### PromQL evaluation

At one evaluation timestamp, selectors find eligible series and samples. Range queries repeat that evaluation at every step. Functions operate on sample windows; aggregation rewrites label sets; binary operators match series by labels.

Query cost roughly grows with the number of series selected, samples touched across the time window, number of evaluation steps, and work performed by functions and joins. A dashboard with many panels, variables, long ranges, and small steps can produce a fan-out of expensive queries.

Review the query as a data-processing plan:

```text
selector breadth
  x active series
  x samples per window
  x evaluation steps
  x panels and repeated variables
  x concurrent users
```

This is a reasoning model, not an exact capacity formula.

### Recording-rule execution

Rules are organized into groups and evaluated periodically. Rules in a group execute sequentially for the same evaluation time. A slow group can miss later scheduled evaluations. A recording rule writes a new series whose labels and name become a public data contract for dashboards and alerts.

Use `promtool check rules` for syntax and `promtool test rules` with known input for behavior. Syntax success does not prove label correctness, user relevance, acceptable cost, or live configuration loading.

### Alert lifecycle

For every result label set, an alerting rule can create an instance. Without `for`, it can fire immediately. With `for`, it stays pending while the expression remains active for the required duration. Missing evaluations and missing series need explicit consideration. `keep_firing_for` can keep an alert firing after the expression clears; this is version-sensitive configuration and should be justified.

Prometheus sends alert state to Alertmanager. Alertmanager owns grouping, wait timing, inhibition, silences, routing, and notification receivers. Labels determine routing and grouping; annotations carry human context. Putting changing values into labels can continuously create new alert identities.

### Grafana execution

Grafana stores or provisions data-source and dashboard definitions, expands variables, chooses a time range and query step, sends requests, applies transformations, and renders panels. Provisioned files can be version controlled, but UI edits can be overwritten depending on provisioning settings.

The reliable workflow is:

```text
question -> reviewed query -> tested result labels/units
         -> versioned panel contract -> provisioned dashboard
         -> rendered review -> operator task test
```

A screenshot cannot establish query correctness. A passing JSON parse cannot establish accessibility or on-call usefulness.

## Evidence table

| Question | Evidence | Risk | Useful branches | Proves | Does not prove |
|---|---|---|---|---|---|
| Is the real operation failing? | user-journey probe, service response, business outcome | Read-only when using an approved probe | affected, unaffected, ambiguous | observed outcome from that vantage point | global impact or root cause |
| Is the target discovered? | Prometheus target/discovery state | Read-only | absent, present once, duplicated | current discovery result | successful scrape or metric presence |
| Did the scrape succeed recently? | target status plus scrape timestamp/duration/error | Read-only | success/fresh, failed, stale | scraper outcome for that target | metric semantics or service health |
| Does the endpoint expose the expected series? | bounded direct exposition inspection | Read-only but may expose sensitive labels | present, absent, malformed, oversized | endpoint response at that moment | ingestion or historical presence |
| Was the series accepted? | direct PromQL selector and ingestion rejection evidence | Read-only | expected identity, rewritten identity, no result | query-visible accepted series | correctness of the value |
| Is a counter rate meaningful? | raw counter window, reset and scrape evidence | Read-only | sufficient samples, reset, gap, too few samples | conditions supporting interpretation | exact event count between scrapes |
| Does a ratio compare the same population? | separate numerator/denominator result labels | Read-only | one-to-one, missing, zero, many-to-many | matching shape and visible populations | business correctness of instrumentation |
| Is cardinality bounded? | schema domains, observed active/new series, top label values | Read-only | bounded, unexpectedly large, unbounded | current evidence and design limits | future traffic or exact capacity |
| Did a rule load and evaluate? | config/rule validation, runtime rule health and output | Validation may be bounded mutation | parsed, loaded, evaluated, failed, missed | each observed boundary separately | paging or user impact |
| Why did no notification arrive? | rule state, Alertmanager alert, route, silence, inhibition, receiver result | Read-only | never fired, suppressed, misrouted, delivery failed | inspected transition | service health or human action |
| Is a panel trustworthy? | exact query request/result, variables, transformations, unit and no-data config | Read-only | correct, stale, scoped wrong, transformed wrong | client behavior reviewed | full dashboard accessibility or usefulness |
| Has cleanup completed? | descriptor validation and exact path/process/port absence | Bounded mutation | absent, owned-removable, refused | declared local resource absence | unrelated host cleanliness |

The evidence order matters. Start close to the question and trace boundaries. Do not begin with the most complicated tool simply because it is familiar.

## Command decoders

The commands in this draft use a bounded model so the arithmetic and reasoning are inspectable without downloading a monitoring stack. Where real Prometheus commands are shown, they are examples to run only against an approved local endpoint.

### Decoder 1: `bash lab.sh doctor`

```text
bash        execute with Bash, not whatever interactive shell happens to be active
lab.sh      the lesson-owned lifecycle wrapper
doctor      read-only prerequisite and safety inspection
```

Expected fields include UID, Bash path, Python path/version, repository-relative fixture identity, and whether owned state is absent. `ready=true` means only those checks passed.

### Decoder 2: direct selector

```promql
payment_attempts_total{service="payments",operation="submit"}
```

- The metric name narrows the family.
- Braces contain label matchers.
- `=` is exact matching. Regex matchers should be bounded and justified.
- An instant query returns one latest eligible sample per matching series at the evaluation timestamp.

Inspect all returned labels. An unexpected `instance`, `version`, `outcome`, or tenant label changes result cardinality and later vector matching.

### Decoder 3: counter rate

```promql
sum by (service, operation) (
  rate(payment_attempts_total[5m])
)
```

- `[5m]` creates a five-minute range vector at each evaluation.
- `rate()` calculates average per-second counter increase and adjusts for resets.
- `sum by (...)` aggregates replicas and outcomes while retaining the named labels.
- The result unit is attempts per second.

Trap: applying `sum` before `rate` can hide resets from individual series. Calculate a reset-aware rate per original counter series first, then aggregate.

### Decoder 4: error ratio

```promql
sum by (service, operation) (rate(payment_attempts_total{outcome="failure"}[5m]))
/
sum by (service, operation) (rate(payment_attempts_total[5m]))
```

The division matches the retained labels. Inspect zero denominators and missing series. If failures are absent because the client library does not initialize a zero-valued labeled series, the numerator may be absent rather than zero.

### Decoder 5: saturation ratio

```promql
sum by (service) (work_in_progress)
/
sum by (service) (work_limit)
```

Both gauges must describe compatible scope and unit. If every replica exposes the same cluster-wide limit, summing it multiplies the denominator incorrectly. Metric semantics come before syntax.

### Decoder 6: classic histogram threshold

```promql
sum by (service) (
  rate(http_request_duration_seconds_bucket{le="0.3"}[5m])
)
/
sum by (service) (
  rate(http_request_duration_seconds_count[5m])
)
```

This estimates the fraction of recorded requests at or below 0.3 seconds. It directly matches a 300 ms threshold question if the instrument observes the intended population. It says nothing about requests never recorded.

### Decoder 7: classic histogram p95

```promql
histogram_quantile(
  0.95,
  sum by (service, le) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

- `0.95` is the requested quantile rank.
- Classic buckets are counters, so use `rate()`.
- Preserve `le` while aggregating.
- The output unit matches the observation unit, here seconds.
- The value is interpolated within bucket resolution; it is not an exact request duration.

### Decoder 8: absence

```promql
absent(up{job="payments"})
```

`absent()` can support missing-series detection, but absence might result from discovery, relabeling, scrape failure, query scope, or an intentionally removed service. Pair it with ownership and deployment state. Avoid paging on every ephemeral instance disappearance when the user journey remains healthy.

### Decoder 9: rule syntax validation

```bash
# [READ-ONLY]
promtool check rules rules.yml
```

`promtool` is the Prometheus command-line utility. `check rules` parses and validates the rule-file syntax. An exit status of zero proves that exact utility accepted that file. It does not prove the running server loaded it or that the rule answer is correct.

### Decoder 10: deterministic rule test

```bash
# [READ-ONLY]
promtool test rules rules.test.yml
```

The test file supplies known input series, evaluation times, and expected expression or alert results. Test reset, zero-traffic, missing-series, threshold-edge, pending, firing, and recovery branches. The test is only as good as its cases and label expectations.

### Decoder 11: query API evidence

```bash
# [READ-ONLY]
curl --fail --silent --show-error --get \
  --data-urlencode 'query=sum(rate(payment_attempts_total[5m]))' \
  --data-urlencode 'time=2026-08-04T09:30:00Z' \
  http://127.0.0.1:9090/api/v1/query
```

- `--get` encodes data as query parameters.
- `--data-urlencode` protects PromQL characters.
- `time` makes the evaluation instant explicit.
- `--fail` rejects HTTP error status, but a successful HTTP response can still contain an API-level error payload that must be parsed.
- Loopback scope does not provide authentication or authorization by itself. Do not expose an unsecured administrative endpoint on an untrusted network.

## Decision path

### When a panel is blank

```text
1. State the panel question and expected series.
2. Confirm the real user operation and impact.
3. Fix evaluation time, dashboard range, variables, and data source.
4. Run the simplest direct selector.
5. If absent, inspect target discovery and scrape freshness.
6. Inspect bounded exposition for the exact metric and labels.
7. Inspect relabeling and ingestion rejection.
8. If direct query works, inspect Grafana request, step, transformation, and no-data handling.
9. Mitigate at the earliest failing owned boundary.
10. Verify user outcome and every downstream evidence boundary.
```

### When a query is slow

Do not immediately add a recording rule. First identify selector breadth, time range, step, number of series, samples touched, joins, regex matchers, subqueries, panel repeats, and concurrency. Reduce unnecessary work while preserving the question.

A recording rule is appropriate when a reviewed expression is reused, the output label contract is stable, evaluation cost fits a rule group, and added series/storage are acceptable. It is not a substitute for uncontrolled source cardinality.

### When an alert is noisy

Separate these possibilities:

- The underlying condition is genuinely frequent.
- The metric or ratio is wrong.
- The threshold is not tied to user impact.
- The time window is too sensitive.
- Missing data changes state unexpectedly.
- Labels create many duplicate alert instances.
- Alertmanager grouping or routing is wrong.
- The runbook has no safe action.

Fix the first false assumption. Longer `for` durations and broad silences can reduce notifications while preserving a defective signal.

### When cardinality rises

Protect the monitoring service and preserve critical user-outcome signals. Identify the metric families, label names, top/new values, deployment cohort, and series creation rate. Roll back or disable the offending instrumentation through a bounded change. Do not delete TSDB data as first response; that destroys evidence and does not stop ingestion.

After containment, verify active/new series trajectory, scrape size and duration, Head memory, WAL/disk, query/rule latency, and user outcome. Retained historical series may remain until blocks expire or are compacted; explain that recovery curve.

### Before changing production

Use this safe-change card:

| Item | Required statement |
|---|---|
| Scope | exact service, metric families, jobs, rules, dashboards, tenants, and environments |
| Prediction | observable values and labels expected after the change |
| Abort | user impact, series growth, scrape duration, memory, disk, query, or rule threshold |
| Rollback | exact code/config/dashboard version and action |
| Evidence | direct query, runtime config/rule state, target state, user journey, and system resource signals |
| Ownership | application, observability platform, and on-call decision owners |
| Cost | active series, samples, storage, query, and egress estimate |

## Guided Ubuntu lab

### Purpose and boundary

The guided lab teaches semantics before tooling. It uses deterministic local fixtures to make counter resets, vector matching, cumulative buckets, cardinality multiplication, alert states, and dashboard contracts visible. It does not claim to be Prometheus, PromQL, Grafana, or Alertmanager.

Environment card:

| Item | Contract |
|---|---|
| Tested target | Ubuntu 24.04 LTS, normal user |
| Time | about 90 minutes |
| Required | Bash and Python 3 |
| Not required | Docker, network, ports, sudo, package install |
| CPU/RAM/disk | one short Python process; bounded JSON; less than 5 MiB state |
| Changes | one UID-owned temporary directory and bounded result files |
| Abort | root caller, ambiguous state, symlink, unexpected child, invalid fixture, failed assertion |
| Recovery | status, then descriptor-gated cleanup only when ownership fully validates |

Run from:

```text
drafts/LES-0028-prometheus-promql-grafana/support/lab
```

#### Step 1: preflight

```bash
# [READ-ONLY]
bash lab.sh doctor
```

Prediction: it reports the caller and tools, refuses root, performs no install, and creates no state.

#### Step 2: setup

```bash
# [MUTATING / BOUNDED]
bash lab.sh setup
bash lab.sh status
```

Prediction: setup creates one exact owned state directory. Status reports bounded fixture counts, time range, labels, and sentinel identity.

#### Step 3: counter reset reasoning

Before running the case, answer: If a counter window is `100, 130, 9, 29`, is the total increase `-71`, `20`, or something else? What assumption does each answer make?

```bash
# [MUTATING / BOUNDED]
bash lab.sh run counter-rate
```

The model treats a decrease as a reset and adds increases from each monotonic segment. Compare its declared algorithm with real Prometheus `rate()` only as a conceptual bridge; exact extrapolation is outside the fixture.

#### Step 4: ratio and vector matching

```bash
# [MUTATING / BOUNDED]
bash lab.sh run vector-match
```

Inspect numerator and denominator labels before the ratio. Explain why matching by service plus operation is valid or invalid. State the result unit and the zero-traffic policy.

#### Step 5: histogram reasoning

```bash
# [MUTATING / BOUNDED]
bash lab.sh run histogram
```

Check that cumulative counts never decrease and `+Inf` equals `_count`. Calculate the fraction at the SLO threshold. Then identify the bucket containing p95 and state the interpolation uncertainty.

#### Step 6: cardinality budget

```bash
# [MUTATING / BOUNDED]
bash lab.sh run cardinality
```

The output distinguishes bounded domain multiplication from observed series. Remove the unbounded request identifier and recompute the budget on paper. Do not claim an exact byte cost from a series-count estimate.

#### Step 7: alert state

```bash
# [MUTATING / BOUNDED]
bash lab.sh run alert-state
```

Trace inactive, pending, firing, and resolved transitions. State how evaluation interval and `for` duration interact. Then list the additional evidence needed to prove that an on-call notification was routed and received.

#### Step 8: dashboard contract

```bash
# [MUTATING / BOUNDED]
bash lab.sh run dashboard-contract
```

Each panel must declare a question, query identifier, unit, scope, freshness, no-data behavior, owner, and drill-down. Static completeness is necessary but insufficient; exact Grafana acceptance and operator-task review remain pending.

#### Step 9: guided incident

```bash
# [MUTATING / BOUNDED]
bash lab.sh run incident
```

Use FRAME. Write impact, facts, assumptions, at least three hypotheses, confirming/rejecting evidence, smallest safe mitigation, abort criteria, rollback, and verification. Do not open the answer-isolated transfer record.

#### Step 10: verify and clean

```bash
# [MUTATING / BOUNDED]
bash verify.sh
```

Expected final evidence is a case count, refusal results, `cleanup=passed`, and `final_state=absent`. A pass is mentor project evidence for that exact fixture and environment only.

## Production transfer

### Containers

Inside containers, `localhost` refers to the container's network namespace. A Prometheus container scraping `localhost:8080` targets itself, not another service or the Windows host. Use explicit service discovery and network identity. Avoid publishing Prometheus or Grafana administrative interfaces broadly.

Container restarts reset process counters and can replace instance identities. Queries should handle reset semantics and aggregate at the service boundary where appropriate. Do not erase pod or instance labels before you have a drill-down path.

### Kubernetes

Kubernetes adds discovery labels, relabeling, Services, endpoints, pods, namespaces, network policy, service accounts, and multi-tenant boundaries. A ServiceMonitor or PodMonitor is a custom-resource contract used by an operator; its presence is not proof that the generated Prometheus configuration includes the intended target.

Troubleshoot in order:

```text
custom resource selected
  -> operator reconciled configuration
  -> target discovered
  -> network/TLS/auth allowed
  -> scrape accepted
  -> expected series and labels ingested
  -> query/rule/panel scope correct
```

Limit discovery and query permissions. Metrics can expose infrastructure names, tenant identifiers, URLs, and business volumes even without obvious secrets.

### Cloud and managed services

Managed Prometheus-compatible services can change ingestion topology, authentication, tenancy, quotas, retention, remote-write behavior, query limits, and cost. “Prometheus compatible” does not mean identical feature flags, storage internals, APIs, alerting, or failure behavior.

Before adoption, map:

- who owns scraping and buffering;
- how identity and tenant boundaries are enforced;
- which labels are added or removed;
- ingestion and query quotas;
- retention and durability;
- high availability and deduplication;
- egress and active-series pricing;
- supported PromQL and histogram features;
- outage and backfill behavior;
- export, migration, and rollback paths.

No online cloud resource is required by this lesson.

### High availability and long-term storage

Two independent Prometheus replicas can reduce scrape and query unavailability, but they create duplicate series that a query layer may deduplicate. Deduplication depends on external labels and replica identity. A misconfigured external label can merge unrelated data or fail to deduplicate duplicates.

Remote write and long-term systems add queues, shards, retries, backpressure, out-of-order handling, tenancy, consistency, and cost. Monitor the monitoring path with signals that remain available when one layer is degraded, and retain a minimal local diagnostic path.

### Migration

For a metric or rule rename, use an overlap window:

1. Define old and new semantic contracts.
2. Emit both in a bounded canary if cost permits.
3. Compare series, values, labels, missing cases, and query results.
4. Update recording rules, alerts, dashboards, runbooks, and consumers.
5. Observe through the longest relevant rule and retention window.
6. Remove the old path with a documented rollback boundary.

Changing every producer and consumer at once makes rollback and comparison harder.

## Reliability, security, observability, capacity, and cost

Use OPERATES.

### Outcomes and constraints

Metrics exist to answer operational and product questions. Start with user journeys, reliability objectives, incident decisions, capacity decisions, and compliance constraints. “Collect everything” is not a requirement; it is an unbounded cost and privacy proposal.

### Path and topology

Draw scrape direction, discovery ownership, network and trust boundaries, TSDB placement, query clients, rule evaluation, Alertmanager routing, and dashboard users. Identify which components share a failure domain. A monitoring system on the same failing cluster may become unavailable when you need it most.

### Execution and state

Know where counters live, who assigns timestamps, where buffers exist, how recent samples survive a crash, when blocks become immutable, how rules schedule, and where dashboards are stored. Define desired versus running configuration evidence.

### Reliability and recovery

Set objectives for scrape freshness, critical-series availability, query success/latency, rule evaluation, alert delivery, and dashboard availability. Back up or regenerate configuration and dashboards. Test TSDB snapshot and restore according to the exact version and architecture; file copies of a live mutable store are not automatically coherent.

### Access and security

Protect scrape endpoints, query APIs, administrative lifecycle endpoints, Grafana editing, data sources, alert routes, and provisioning repositories. Use least privilege and TLS where trust boundaries require it. Do not place credentials in labels, annotations, dashboard JSON, URLs, or example output.

Treat label and annotation values as untrusted input. They can contain personal data, secrets, maliciously large values, or content unsafe for downstream templates. Allowlist stable dimensions and redact before ingestion when possible.

### Telemetry and operations

Prometheus, Alertmanager, and Grafana need their own health and workload evidence. Track discovery, scrape, ingestion, active series, Head memory, WAL/disk, compaction, query, rule, remote-write, alert, notification, and dashboard/data-source signals. Avoid a single self-referential alert path with no external check.

### Economics and capacity

Estimate:

```text
active series ~= targets x series per target
samples per second ~= active series / scrape interval seconds
retained samples ~= samples per second x retention seconds
```

This is a planning approximation. Storage bytes depend on sample type, compression, churn, labels, index, WAL, blocks, compaction, and implementation. Query cost depends on selected series, samples, steps, operators, concurrency, and cache behavior.

Control cost at the source:

- bounded metric and label contracts;
- only useful targets and series;
- scrape intervals matched to decision latency;
- retention matched to investigation and reporting needs;
- recording rules for reviewed repeated work;
- dashboard ranges, steps, refresh, and repeats bounded;
- separate high-cost exploratory analytics from paging paths.

### Safe change

Version-control instrumentation schemas, scrape configuration, rules, and provisioned dashboards. Validate syntax, unit-test expressions, canary changes, compare old and new results, watch cardinality and cost, define abort thresholds, and keep exact rollback artifacts. Reload success must be followed by runtime evidence.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| “`up == 1`, so the service is healthy” | `up` describes scrape success, not the user operation | pair scrape health with user-outcome indicators |
| Treating no data as zero | hides a broken measurement path | expose no-data state and alert on critical telemetry gaps separately |
| Graphing raw counters | restarts and replica age dominate the line | use reset-aware rates for event throughput |
| `rate(sum(counter)[5m])` | aggregation can hide individual resets | apply `rate` per original series, then aggregate |
| Averaging per-instance p95 | quantiles do not retain distributions or weights | aggregate histogram buckets or native histograms, then calculate |
| Adding `request_id` as a label | every request can create a series | put correlation identifiers in logs/traces, not metric identity |
| Using raw path as `route` | path parameters create unbounded values | instrument a normalized route template |
| Recording every dashboard expression | adds opaque dependencies and series cost | record stable, reviewed, reused expressions with ownership |
| Raising an alert threshold first | suppresses symptom without validating signal | replay known inputs and connect threshold to user impact |
| Broad silences during incidents | can hide unrelated failures | scope silence labels and duration narrowly; retain audit trail |
| Restarting Prometheus for no data | destroys state and tests many hypotheses | use direct selector, target, exposition, and ingestion evidence first |
| Deleting TSDB data for cardinality | destroys evidence and does not stop new ingestion | stop offending source, then plan retention/recovery |
| Trusting dashboard screenshots | screenshot omits query, labels, time, and transformations | inspect exact request/result and provisioned definition |
| Small dashboard step means better detail | creates more evaluations than source resolution supports | relate step to scrape interval, range, and question |
| One monitoring stack in one failure domain | outage removes both service and evidence | design independent or degraded diagnostic paths |

Prevention reviews should ask:

1. What question does this metric, rule, or panel answer?
2. Who owns the instrumentation and its schema?
3. Are all label value domains bounded and non-sensitive?
4. What are unit, type, timestamp, and reset semantics?
5. What user outcomes are missing from the population?
6. What is the active-series and sample-rate budget?
7. How will known-input tests cover reset, missing, zero, edge, and recovery?
8. How will the change be canaried, aborted, rolled back, and verified?

## Memory card and retrieval

### Compact memory card

**Problem:** Turn changing system measurements into evidence that supports safe operational decisions.

**Mental model:** A panel is the last reader of a path; trust it only after series identity, timestamps, query population, rule state, and visualization scope are understood.

**Internals:** Prometheus discovers and scrapes targets, stores labeled samples in a local TSDB, evaluates PromQL and rule groups, and exposes results to clients such as Grafana and Alertmanager.

**Practical example:** Calculate reset-aware request rates per original series, aggregate numerator and denominator to the same service/operation keys, divide, and keep no-data distinct from zero.

**Failure story:** A new `request_id` label creates unbounded series, increasing Head memory, WAL, query latency, missed rule evaluations, and blank dashboards.

**Security/reliability risk:** Metrics can leak sensitive labels, and a shared monitoring failure domain can remove incident evidence.

**Trade-off:** More dimensions improve slicing until identity growth, cost, privacy, and cognitive load outweigh decision value.

**Retrieval question:** When a Grafana panel is blank, how do you locate the earliest failing boundary without treating absence as zero?

### Retrieval questions

1. What exactly identifies a Prometheus time series?
2. Why is `rate(sum(counter)[5m])` usually unsafe across independently resetting replicas?
3. How are scrape interval, query step, range window, rule interval, and lookback different?
4. Why can a target be green while users fail?
5. Why is averaging p95 values across instances invalid?
6. What evidence distinguishes a missing instrument from a Grafana scope problem?
7. How does an unbounded label propagate into query and alert failures?

Suggested review schedule: same session, then 1, 3, 7, 14, 30, 60, and 90 days. Extend only after accurate explanation and unfamiliar transfer.

## Complete answers

### 1. What identifies a time series?

**Direct answer:** One metric name plus one complete set of label key-value pairs.

**Foundation:** The metric name describes the measurement family. Labels describe a particular member. Changing any label value creates a different identity with its own samples. A sample adds a timestamp and value to that identity.

**Senior answer:** Treat series identity as a schema and capacity contract. Every bounded dimension enables useful aggregation and multiplies possible identities; every unbounded or attacker-controlled dimension can create churn, cost, privacy exposure, and monitoring instability. Review schema before deployment and compare predicted with observed series in a canary.

### 2. Why rate before sum?

**Direct answer:** Each original counter can reset independently. Calculate its reset-aware rate first, then aggregate the resulting rates.

**Foundation:** If two replicas are summed first, one can reset while the other increases. The combined line may hide the decrease, so a later rate cannot reliably recognize the reset boundary.

**Senior answer:** Preserve original counter identity through the reset-aware function. Then aggregate to the user or service boundary. Validate scrape gaps, window size, ephemeral replica churn, and result labels; rate correctness does not repair a semantically wrong event definition.

### 3. How do the time controls differ?

**Direct answer:** Scrape interval controls collection cadence; range window selects historical samples per evaluation; step spaces evaluations across a range query; rule interval schedules rule evaluation; lookback controls eligibility for instant selectors.

**Foundation:** A dashboard might evaluate every 30 seconds using a five-minute window over samples scraped every 15 seconds. Those are three different clocks.

**Senior answer:** Record all clocks during incidents. Misalignment can create too few samples, stale-looking continuity, disappearance, delayed alerts, or excessive query work. Choose them from detection latency, signal variability, cost, and failure tolerance rather than copying defaults.

### 4. Why can `up` mislead?

**Direct answer:** `up` says Prometheus successfully scraped the target. It does not say the user operation succeeded or the metric semantics are correct.

**Foundation:** The metrics endpoint can return 200 while the business endpoint returns 500. Conversely, the service can work while Prometheus cannot reach the metrics endpoint.

**Senior answer:** Use scrape health as monitoring-path evidence and a service-level indicator as user-outcome evidence. Design alerts and dashboards so failure of either path is visible without conflating them.

### 5. Why not average p95?

**Direct answer:** A per-instance p95 does not contain the underlying distribution or request count, so averaging quantiles cannot produce the fleet quantile.

**Foundation:** One instance might handle ten requests and another ten thousand. Their p95 values cannot be weighted correctly without more information, and even a weighted average is not the combined rank statistic.

**Senior answer:** Aggregate compatible histogram distributions and calculate the quantile afterward, or use a threshold ratio that directly matches the objective. Preserve bucket boundaries and relevant scope labels. State interpolation error and missing-population risk.

### 6. How do you locate a missing metric?

**Direct answer:** Start with the expected instrument and walk the path: exposition, discovery, scrape, relabeling, ingestion, direct query, then Grafana.

**Foundation:** At each boundary ask what exact evidence would exist if it worked. Stop at the first divergence.

**Senior answer:** Fix time and label scope, compare desired and running configuration, preserve change evidence, use a narrow direct selector and bounded exposition inspection, and avoid restarts. Mitigate at the earliest owned boundary and verify both the measurement path and user journey.

### 7. How does an unbounded label cause an incident?

**Direct answer:** Each new value can create a new series, multiplying memory, network, storage, index, compaction, query, rule, and dashboard work.

**Foundation:** A request ID changes for every request. Putting it in a label turns every request into a new identity instead of another sample in a bounded series.

**Senior answer:** Contain at the source by rolling back or disabling the label, preserve essential outcome metrics, and monitor new/active series, scrape size, Head/WAL/disk, query and rule latency, and recovery. Capacity increases alone preserve the faulty schema.

## Product-company interview

### Scenario

At 10:05, checkout latency and errors rise in one region. At 10:08, the regional Grafana dashboard becomes slow and two panels show no data. Prometheus target health is mostly green. A release at 09:55 added `customer_id` and `request_id` labels to a request counter “to improve debugging.” The monitoring team proposes doubling Prometheus memory; the application team proposes restarting Grafana.

How do you lead the diagnosis and mitigation?

### Strong model answer

I would declare two related but unproven impacts: checkout degradation and monitoring degradation. I would establish the affected user operation, region, versions, and start time using an approved user-journey signal independent of the failing dashboard.

My leading hypothesis is a cardinality/churn incident triggered by the instrumentation change, because both new labels have large or unbounded domains and the timeline fits. I would not treat it as fact until I compare new/active series, scrape response size and duration, Head memory, WAL/disk, ingestion, query latency, rule evaluation, and deployment cohorts. I would query the affected metric narrowly and inspect label values without exposing customer data in logs or incident channels.

The safest mitigation is to stop new-series creation: roll back the instrumentation release or disable those labels in a bounded cohort while preserving the core bounded request/error/duration signals. Abort if the rollback worsens checkout or removes all user-outcome evidence. I would not restart Grafana because it is downstream, and I would not first double memory because that buys time without stopping growth.

After mitigation, I would verify the checkout journey, new-series rate, active-series trajectory, scrape freshness and duration, Prometheus memory/WAL/disk, query and rule latency, panel freshness, and alert state. Historical series may remain until retention and compaction remove them, so recovery can lag. I would preserve incident evidence and review whether any PII entered metrics storage.

Prevention includes a metric schema review, bounded-label allowlist, canary cardinality budget, sensitive-data checks, instrumentation rollback switch, series-growth alerts with actionable runbooks, dashboard fallbacks, and independent service-level monitoring.

### Weak-answer warning signs

- “Restart Grafana and Prometheus” without tracing the data path.
- “Increase memory” without stopping new series.
- Copying label values into the incident channel and leaking customer identifiers.
- Deleting TSDB blocks before preserving evidence.
- Treating green `up` as healthy checkout.
- Claiming the labels are root cause solely from timing without measuring series growth.
- Declaring recovery when the dashboard loads, without checking the user journey.

### Follow-up 1: What if active series stop rising but memory stays high?

Recent series and Head structures may remain resident; historical blocks and indexes remain until retention/compaction; queries or caches may still consume memory. I would inspect the actual memory categories and recovery trend rather than promise an immediate drop. A restart might eventually be considered only with redundancy, current state evidence, rollback, and clear benefit, not as an unexplained ritual.

### Follow-up 2: Why not drop the labels with metric relabeling?

Dropping the entire offending metric family at ingestion can protect Prometheus quickly but loses the core metric. Dropping only a label merges formerly distinct samples into the same series identity, which can create duplicate/conflicting samples within one scrape and is not automatically safe. Fixing instrumentation at the source preserves a deliberate schema. A temporary ingestion control needs exact behavior testing and an exit plan.

### Follow-up 3: How would you estimate the budget before rollout?

List bounded label domains, multiply plausible combinations across targets and replicas, estimate samples per second from scrape interval, and compare with a measured canary. Include churn, histogram expansion, rules, retention, queries, and redundancy. Treat the calculation as a capacity hypothesis, then enforce abort thresholds from observed series and resource signals.

### Follow-up 4: How would you explain this to management?

The release attached unique customer and request values to monitoring identities. That caused the monitoring database to create a rapidly growing number of records, degrading both observability and incident response. We stopped the source of growth, verified checkout and monitoring recovery, are checking data exposure, and are adding pre-release limits and rollback controls. I would separate confirmed impact, remaining uncertainty, and next update time.

## Independent transfer and rubric

### Unscored transfer rehearsal

The following visible scenario helps you rehearse the reasoning shape. Because it is published here, it **cannot** satisfy the unseen-case requirement for `ASM-0069` and cannot prove independent transfer.

A batch-processing platform exposes:

```text
job_duration_seconds{job_name,team,cluster,run_id,quantile}
job_completed_total{job_name,team,cluster,status}
```

The first metric is a summary with per-process quantiles and an unbounded `run_id`. Jobs move between two clusters during failover. A dashboard averages `quantile="0.95"` by team. An alert divides failed completions by successful completions, converts missing results to zero, and pages when the value exceeds 0.05 for one minute. During a cluster failover, the panel turns green while operators report many jobs stuck and no completion metrics arrive.

Without opening the complete-answer sections again, use this rehearsal to produce:

1. A plain-language statement of impact, facts, assumptions, and confidence.
2. A diagram of the job, metric, scrape, query, rule, dashboard, and notification path.
3. At least five ranked hypotheses and evidence that would reject each one.
4. A corrected metric schema for duration, completion, in-progress work, and stable ownership.
5. Correct PromQL sketches for failure fraction, throughput, saturation, and a defensible latency view.
6. Explicit zero-traffic and missing-data behavior.
7. A bounded-label and capacity budget.
8. A safe rollout, abort, rollback, and recovery-verification plan.
9. Security/privacy analysis for current labels.
10. A five-minute interview explanation.

### Scored independent transfer

For `ASM-0069`, use a materially different unseen disposable local case supplied by an instructor or created and held back by the learner before the independence gate. Record all help, keep the case away from shared and production systems, and use `ASM-0069-response-template.md`. The assessment record intentionally contains no model answer or answer-derived evidence. Work on the visible rehearsal above may improve understanding, but it is never accepted as evidence that the unseen transfer was independent.

### Reviewer rubric

| Criterion | Points | Observable evidence |
|---|---:|---|
| Independence, authorization and evidence integrity | 10 | proves the case was unseen and authorized, declares help, preserves raw sanitized evidence, and prevents answer leakage or fabrication |
| Measurement and series mental model | 10 | defines types, units, labels, series, samples, timestamps, resets, populations, and missing states precisely |
| Architecture and boundary evidence | 10 | maps the complete source-to-decision path with state owners, failures, evidence, and unknowns |
| PromQL and arithmetic correctness | 10 | makes rates, aggregation, ratios, matching, histograms, absence, and time controls answer declared questions |
| Hypothesis and diagnostic quality | 10 | ranks and tests at least four falsifiable hypotheses with discriminating evidence |
| Alert and dashboard decision quality | 10 | tests rules and defines alert ownership, state, runbook, panel questions, units, no-data behavior, and drill-down |
| Cardinality, capacity and cost | 10 | bounds domains, active series, sample rate, retention, and query work without fabricated precision |
| Security and privacy | 10 | minimizes sensitive or untrusted data, protects endpoints and evidence, and applies least privilege |
| Safe recovery and cleanup | 10 | uses reversible containment with abort and rollback, verifies user and monitoring recovery separately, and proves exact cleanup |
| Communication and proof limits | 10 | gives a clear interview response and at least twelve technically specific proof limits |

Passing a score does not update mastery automatically. Independent review, delayed recall, and a changed transfer are still required.

## References and review

Primary references are stored as versioned records in the draft support directory. This lesson reuses `REF-0167` for metric types and adds `REF-0185` through `REF-0198` for the Prometheus data model, instrumentation and naming, querying, operators/functions, histograms, storage, configuration, rules and tests, HTTP API, and Grafana provisioning/dashboard practice.

Version-sensitive claims to recheck before promotion:

- current supported Prometheus and Grafana releases;
- native histogram stability, schema, and PromQL behavior;
- feature-flag requirements;
- command-line and configuration fields;
- rule-group and Alertmanager state behavior;
- Grafana dashboard and provisioning schema;
- image digests, signatures, provenance, licenses, and vulnerability disposition.

Review schedule:

| Review | Purpose |
|---|---|
| Before draft validation | schema, exact headings, commands, safety labels, links, and answer isolation |
| Before runtime work | immutable artifacts, supported versions, configs, network, identity, resources, and cleanup |
| Before canonical promotion | direct schemas, runtime lifecycle, reader, build, route, browser, security, and independent editorial review |
| Every six months | official documentation, versions, commands, feature flags, and references |
| After relevant release or advisory | compatibility, security, migrations, and rollback guidance |

Evidence boundary: this file is mentor-authored curriculum. Reading it, running its deterministic model, revealing answers, or passing automated checks does not prove learner competence or production readiness.
