---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0067",
  "slug": "aiops-evidence-safe-automation",
  "aliases": ["V07-L02", "aiops-evidence-safe-automation"],
  "curriculumIds": ["AIO-002"],
  "route": "/book/ai/aiops-evidence-safe-automation",
  "order": 2,
  "volume": "07-ai-engineering",
  "title": "AIOps with evidence: anomalies, correlation, forecasting, and safe automation",
  "summary": "Turn telemetry into operational decision support without confusing unusual with harmful, simultaneous with causal, or a model recommendation with authority.",
  "domain": "ai",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0026", "LES-0030", "LES-0032", "LES-0066"],
  "prerequisiteCurriculumIds": ["OBS-001", "SRE-003", "AIO-001"],
  "testedEnvironments": [
    {"platform": "Primary and official sources", "version": "Google SRE, Prometheus, OpenTelemetry, SciPy, scikit-learn and research sources reviewed 2026-08-05", "support": "concept-only", "notes": "Source review does not establish detector, forecast or remediation behavior."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic evidence and authority model only."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON decisions; no statistics package, model, backend, API, network or production action."}
  ],
  "targetRoles": ["site-reliability-engineer", "platform-engineer", "devops-engineer", "observability-engineer", "machine-learning-engineer", "ml-platform-engineer", "security-engineer", "incident-commander", "technical-lead"],
  "learningObjectives": [
    "Define the operational decision, user-impact contract, action, cost and non-AI baseline before selecting anomaly technology.",
    "Preserve telemetry entity, service, version, environment, event time, observed time and collection lineage.",
    "Explain static, seasonal, trend, robust and multivariate baselines and their failure modes.",
    "Distinguish outlier detection, novelty detection, change detection, classification, clustering and forecasting.",
    "Build time-ordered representative evaluation without leakage or score-inflating point adjustment.",
    "Calculate precision, recall, alert load, review capacity, deduplication ratio, forecast error and actionable lead time.",
    "Turn raw alerts into stable fingerprints, bounded groups and incident candidates without hiding distinct failures.",
    "Use topology, deployment, configuration and trace evidence to rank hypotheses while refusing unsupported causal claims.",
    "Explain what feature attribution and correlation show and what they cannot prove.",
    "Create feedback labels that preserve incident, decision, reviewer and model-version identity rather than learning from button clicks blindly.",
    "Design automation as a least-privilege idempotent control loop with approval, budgets, postconditions, rollback and kill switch.",
    "Operate detector drift, telemetry changes, capacity, privacy, cost and failure modes as a production service."
  ],
  "productionSignals": [
    "user operation SLI SLO impact and action",
    "signal name unit temporality aggregation resolution",
    "service resource instance region zone tenant version",
    "event time observed time ingest time and clock quality",
    "missing delayed duplicate reset and sampling indicators",
    "baseline window season trend residual and robust scale",
    "detector feature version score threshold and reason",
    "label source incident interval reviewer confidence and availability delay",
    "evaluation split period population slice and contamination",
    "TP FP FN precision recall alert-event delay and coverage",
    "raw alert fingerprint group incident and suppression reason",
    "topology and dependency graph version",
    "deployment configuration feature-flag and traffic-shift events",
    "correlated candidates lag direction confounders and tests",
    "forecast horizon interval error coverage and action deadline",
    "human decision override reason feedback lineage",
    "automation proposal policy approval identity idempotency receipt postcondition",
    "run step retry effect deadline and cost budgets",
    "model data schema topology and threshold drift",
    "privacy class minimization retention deletion and access",
    "pipeline lag drop rate saturation queue and fallback",
    "cost per useful incident and avoided user-impact minute",
    "rollback version reconciliation kill switch and residual risk"
  ],
  "diagrams": [
    {"id": "LES-0067-DIA-001", "title": "AIOps operational decision chain", "direction": "left-to-right", "boundaries": ["user operation", "telemetry contract", "baseline and detector", "event and incident decision", "human authority", "bounded action", "user outcome"], "evidencePoints": ["SLI", "identity and time", "score and threshold", "fingerprint and group", "decision", "receipt", "postcondition"], "textAlternative": "AIOps converts trustworthy telemetry into a proposal; accountable authority and independently observed outcomes remain outside the model."},
    {"id": "LES-0067-DIA-002", "title": "Time-series evidence decomposition", "direction": "hierarchical", "boundaries": ["observed value", "level", "trend", "seasonality", "known events", "residual", "anomaly decision"], "evidencePoints": ["window", "period", "calendar", "change", "missingness", "robust scale", "threshold"], "textAlternative": "An observed value is compared with expected components and data-quality evidence before a residual becomes an operational anomaly."},
    {"id": "LES-0067-DIA-003", "title": "Alert to incident reduction path", "direction": "left-to-right", "boundaries": ["signal observations", "raw alerts", "stable fingerprints", "bounded grouping", "topology and changes", "incident candidate", "routing"], "evidencePoints": ["series identity", "threshold interval", "dedup key", "window", "graph version", "hypotheses", "owner"], "textAlternative": "Repeated signal violations become deduplicated alerts and bounded incident candidates without discarding identity or timing."},
    {"id": "LES-0067-DIA-004", "title": "Probable cause evidence ladder", "direction": "hierarchical", "boundaries": ["coincidence", "time order", "topology path", "change association", "mechanism evidence", "intervention or counterfactual", "verified cause"], "evidencePoints": ["lag", "event time", "dependency version", "deployment ID", "trace and logs", "controlled change", "outcome"], "textAlternative": "Correlation starts a hypothesis; increasingly independent evidence and safe tests are needed before calling something causal."},
    {"id": "LES-0067-DIA-005", "title": "Forecast to action window", "direction": "left-to-right", "boundaries": ["history cutoff", "forecast origin", "horizon", "prediction interval", "capacity threshold", "decision lead", "action completion"], "evidencePoints": ["training window", "as-of time", "error", "coverage", "threshold crossing", "approval time", "postcondition"], "textAlternative": "A forecast is useful only when its uncertainty leaves enough time to approve and complete a safe capacity action."},
    {"id": "LES-0067-DIA-006", "title": "Safe remediation control loop", "direction": "cyclic", "boundaries": ["detected symptom", "evidence package", "proposed action", "policy and approval", "idempotent execution", "postcondition", "continue stop or rollback"], "evidencePoints": ["incident ID", "versions", "scope", "authority", "operation key", "receipt", "SLO and rollback"], "textAlternative": "Detection never directly owns production; a bounded external control loop authorizes, executes, verifies and can stop or reverse effects."}
  ],
  "commands": [
    {"id": "LES-0067-CMD-001", "question": "Is the offline model safe?", "risk": "read-only", "command": "bash lab.sh doctor", "runFrom": "LES-0067 support/lab as normal Ubuntu 24.04 user", "expectedBranches": [{"when": "doctor=pass", "meaning": "guards and fixture pass", "nextEvidence": "setup"}, {"when": "lab=fail", "meaning": "a boundary failed", "nextEvidence": "correct without bypass"}], "proves": "local preconditions", "doesNotProve": "AIOps behavior"},
    {"id": "LES-0067-CMD-002", "question": "Can bounded state initialize?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "setup=pass", "meaning": "owned state validates", "nextEvidence": "baseline"}, {"when": "failure", "meaning": "guard failed", "nextEvidence": "preserve first error"}], "proves": "bounded initialization", "doesNotProve": "telemetry setup", "cleanup": "Run bash lab.sh cleanup."},
    {"id": "LES-0067-CMD-003", "question": "Does the complete evidence path operate?", "risk": "read-only", "command": "bash lab.sh evaluate baseline", "runFrom": "LES-0067 support/lab after setup", "expectedBranches": [{"when": "boundary=operable", "meaning": "all modeled contracts pass", "nextEvidence": "negative cases"}], "proves": "fixture decision order", "doesNotProve": "production readiness"},
    {"id": "LES-0067-CMD-004", "question": "Is telemetry identity usable?", "risk": "read-only", "command": "bash lab.sh evaluate telemetry-identity-missing", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=telemetry-identity", "meaning": "population identity is incomplete", "nextEvidence": "repair resource and version labels"}], "proves": "identity gate", "doesNotProve": "telemetry truth"},
    {"id": "LES-0067-CMD-005", "question": "Was seasonality modeled?", "risk": "read-only", "command": "bash lab.sh evaluate seasonality-ignored", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=seasonality", "meaning": "expected periodic behavior can look anomalous", "nextEvidence": "declare period and calendar"}], "proves": "baseline gap", "doesNotProve": "best algorithm"},
    {"id": "LES-0067-CMD-006", "question": "Does the evaluation leak future data?", "risk": "read-only", "command": "bash lab.sh evaluate future-leakage", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=time-split", "meaning": "offline score cannot support rollout", "nextEvidence": "rolling-origin split"}], "proves": "evaluation gap", "doesNotProve": "online quality"},
    {"id": "LES-0067-CMD-007", "question": "Can humans absorb the output?", "risk": "read-only", "command": "bash lab.sh evaluate review-capacity-exceeded", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=review-capacity", "meaning": "alert arrival exceeds review capacity", "nextEvidence": "reduce or route load"}], "proves": "operational capacity gap", "doesNotProve": "alert usefulness"},
    {"id": "LES-0067-CMD-008", "question": "Is deduplication identity stable?", "risk": "read-only", "command": "bash lab.sh evaluate unstable-dedup-key", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=deduplication", "meaning": "events may merge or fan out incorrectly", "nextEvidence": "define stable fingerprint"}], "proves": "dedup gap", "doesNotProve": "one incident"},
    {"id": "LES-0067-CMD-009", "question": "Is correlation being called cause?", "risk": "read-only", "command": "bash lab.sh evaluate correlation-claimed-cause", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=causal-claim", "meaning": "ranking overclaims evidence", "nextEvidence": "state hypothesis and test"}], "proves": "causal-language gap", "doesNotProve": "true cause"},
    {"id": "LES-0067-CMD-010", "question": "Is forecast lead actionable?", "risk": "read-only", "command": "bash lab.sh evaluate forecast-too-late", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=forecast-lead", "meaning": "prediction arrives after action deadline", "nextEvidence": "change horizon or operation"}], "proves": "decision-timing gap", "doesNotProve": "forecast accuracy"},
    {"id": "LES-0067-CMD-011", "question": "Is automation least privilege?", "risk": "read-only", "command": "bash lab.sh evaluate automation-overprivileged", "runFrom": "LES-0067 support/lab", "expectedBranches": [{"when": "boundary=automation-authority", "meaning": "effect scope is unsafe", "nextEvidence": "reduce permission and require policy"}], "proves": "authority gap", "doesNotProve": "safe remediation"},
    {"id": "LES-0067-CMD-012", "question": "Do every branch and cleanup pass?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "LES-0067 support/lab from absent state", "expectedBranches": [{"when": "verify=pass", "meaning": "29 branches and cleanup pass", "nextEvidence": "retain limitations"}, {"when": "failure", "meaning": "candidate rejected", "nextEvidence": "preserve first failure"}], "proves": "teaching lifecycle", "doesNotProve": "detector forecast correlation incident platform or production automation", "cleanup": "Verifier proves state absence."}
  ],
  "labs": [
    {"id": "LES-0067-LAB-001", "title": "Guided AIOps evidence and authority model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python", "timeMinutes": 240, "privilege": "normal user; root refused", "network": "none", "changes": ["UID-scoped temporary root", "synthetic fixture"], "abortConditions": ["root", "credential", "endpoint", "symlink", "wrong owner", "unknown artifact"], "recovery": "Preserve first failure; change only copied fixture or candidate code.", "cleanupProof": "Exact inventory and root absence.", "path": "drafts/LES-0067-aiops-evidence-safe-automation/support/lab"},
    {"id": "LES-0067-LAB-002", "title": "Independent AIOps incident and adoption transfer", "mode": "independent", "environment": "Reviewer-owned disposable local telemetry generator or sanitized packet", "timeMinutes": 240, "privilege": "normal user; reviewer owns faults", "network": "isolated local only or none", "changes": ["synthetic telemetry labels topology changes and action proposals", "bounded local state"], "abortConditions": ["shared service", "real credential", "customer data", "external effect", "unbounded load or action", "unknown cleanup"], "recovery": "Preserve evidence and reset through reviewer harness.", "cleanupProof": "Reviewer proves processes, files, ports, caches and synthetic records absent.", "path": "drafts/LES-0067-aiops-evidence-safe-automation/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0067-INC-001", "signal": "A detector pages every weekday traffic peak.", "firstThought": "Expected seasonality is missing from the baseline.", "safePath": "Protect user-impact alerting, bind series/time/calendar, contain noisy routing and repair evaluation.", "trap": "Raise a global threshold until pages stop."},
    {"id": "LES-0067-INC-002", "signal": "Hundreds of alerts become one incident and hide a second outage.", "firstThought": "Grouping scope or window crossed distinct identities.", "safePath": "Preserve raw alerts, split by stable fingerprint/topology/time and verify both user journeys.", "trap": "Assume fewer incidents means better correlation."},
    {"id": "LES-0067-INC-003", "signal": "A probable-cause engine blames the last deployment.", "firstThought": "Temporal association is a hypothesis, not causality.", "safePath": "Check event time, topology, unaffected controls, traces, mechanism and reversible test.", "trap": "Rollback every nearby deployment automatically."},
    {"id": "LES-0067-INC-004", "signal": "Disk forecast is accurate but arrives after procurement lead time.", "firstThought": "Forecast horizon does not meet the operational action window.", "safePath": "Bind threshold, interval, lead time and action duration; choose an earlier useful forecast or fallback.", "trap": "Report lower forecast error without changing the decision."},
    {"id": "LES-0067-INC-005", "signal": "Automated restart multiplies failures during partial recovery.", "firstThought": "Detector noise crossed non-idempotent broad authority without state reconciliation.", "safePath": "Stop automation, preserve action identities, reconcile targets, rollback and restore bounded approval.", "trap": "Increase cooldown and leave authority unchanged."}
  ],
  "assessmentIds": ["ASM-0184", "ASM-0185", "ASM-0186"],
  "referenceIds": ["REF-0763", "REF-0764", "REF-0765", "REF-0766", "REF-0767", "REF-0768", "REF-0769", "REF-0770", "REF-0771", "REF-0772", "REF-0773", "REF-0774", "REF-0775", "REF-0776", "REF-0777"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-05",
  "reviewAfter": "2027-02-05",
  "limitations": [
    "Offline model is not a detector, parser, forecast, graph, incident platform, remediation controller or benchmark.",
    "Synthetic decisions cannot prove telemetry quality, model quality, causal inference, explanation faithfulness, automation safety or user benefit.",
    "No telemetry backend, model package, socket, credential, production target or external effect exists.",
    "Algorithms, products, versions, defaults and interfaces change; operational thresholds require local evidence.",
    "Formal review, publication, representative runtime, independent transfer, delayed recall and learner evidence remain required."
  ]
}
---

# AIOps with evidence: anomalies, correlation, forecasting, and safe automation

## What you see and first thought

At 02:10, an AIOps console says:

```text
ANOMALY 0.97
probable cause: checkout deployment
recommended action: restart checkout pods
confidence: high
```

It looks decisive. A senior operator slows down.

Ask what each line actually means. Anomaly score `0.97` may mean only that this feature vector looks unlike a model's reference data. “Probable cause” may mean the deployment occurred near the signal and sits near the service in a possibly stale dependency graph. “Recommended” is generated advice, not authorization. “High confidence” may be an uncalibrated score whose scale is meaningful only for this detector version.

Use this mental model:

> AIOps is an evidence-compression and decision-support system. It may help a human find signal sooner. It does not turn correlation into cause or prediction into production authority.

Start with the user. Are checkouts failing, slow or incorrect? Which region, tenant, version and operation? Is intervention urgent? What safe action could follow? If there is no user-impact contract or operational decision, “unusual” is merely an observation.

Two symmetric failures matter:

- a **false positive** interrupts responders or triggers harmful action when no actionable incident exists;
- a **false negative** hides or delays an incident that users are experiencing.

An AIOps system can also create a third failure: it can merge, rank or explain evidence so persuasively that the team stops investigating. Treat every output as a versioned hypothesis with provenance.

## Terms before commands

### AIOps

**AIOps** is the use of statistical, machine-learning or AI-assisted methods in IT operations. Common tasks include anomaly detection, event enrichment, alert deduplication, incident grouping, probable-cause ranking, forecasting, summarization and bounded remediation. The label does not identify one algorithm and does not guarantee intelligence, autonomy or reliability.

### Observation, event, alert, incident and cause

These words name different states:

- An **observation** is a measured value or record: CPU 92%, one log line, one span.
- An **event** is a meaningful occurrence: deployment completed, leader changed, certificate expires.
- An **alert** is a rule or model decision intended for a destination.
- An **incident** is coordinated work around actual or credible impact.
- A **cause** is a mechanism whose correction meaningfully prevents or removes the failure.

Ten thousand observations may create one alert. Fifty alerts may belong to one incident. Two simultaneous incidents may look like one. A change near an incident may be innocent. Never use these nouns interchangeably.

### Point, contextual and collective anomalies

A **point anomaly** is unusual by itself, such as a negative request count. A **contextual anomaly** is unusual only in context: 4,000 requests/s may be normal at noon and strange at 03:00. A **collective anomaly** is a sequence or relationship that is abnormal although individual points look ordinary, such as steadily increasing retry rate paired with falling useful throughput.

The detector must match the failure you need to see. A point threshold cannot reliably express every seasonal, sequential or multivariate failure.

### Outlier detection, novelty detection and change detection

**Outlier detection** assumes the analyzed data may already contain abnormal samples and tries to identify them. **Novelty detection** learns from data intended to represent normal behavior, then judges new samples; contaminated “normal” training data changes that boundary. **Change detection** asks whether the generating behavior shifted, not whether one point is extreme.

These are different questions. A deploy that permanently doubles legitimate traffic is a change. It may initially look novel without being harmful.

### Baseline, level, trend, seasonality and residual

A **baseline** is the expected comparison for a specific population and time. It may contain:

- **level**: typical magnitude;
- **trend**: longer movement, such as gradual growth;
- **seasonality**: repeating daily, weekly or calendar pattern;
- **known events**: launches, maintenance, holidays or traffic shifts;
- **residual**: what remains after expected components.

A global average is usually a weak baseline. Tuesday 10:00 in one region may need comparison with previous Tuesdays for the same service, version and workload class.

### Median and median absolute deviation

The **median** is the middle ordered value. It resists one extreme point better than the mean. The **median absolute deviation**, or MAD, is:

```text
median_value = median(x)
absolute_deviation_i = abs(x_i - median_value)
MAD = median(absolute_deviation_i)
```

A transparent robust score is often written approximately as:

```text
robust_z = 0.6745 * (x - median) / MAD
```

The constant makes the scale comparable with standard deviation under particular normal-distribution assumptions. It does not make the data normal. If MAD is zero, division is undefined; the system needs an explicit constant-series policy. Missing values, counters, resets and low sample counts also need handling before arithmetic.

### Feature, score, threshold and contamination

A **feature** is an input value derived from evidence, such as error ratio, latency residual or deployment age. An **anomaly score** is the detector's ranking value. A **threshold** converts a score into a decision. **Contamination** is an assumed or estimated abnormal proportion used by some methods to define that cutoff.

Scores from two detector versions may not be comparable. A threshold is an operational policy because it controls false-positive and false-negative cost.

### Precision, recall and alert load

For a labeled evaluation:

```text
precision = TP / (TP + FP)
recall    = TP / (TP + FN)
F1        = 2 * precision * recall / (precision + recall)
```

Precision asks: of the events called actionable, how many were actionable? Recall asks: of the actionable events, how many were found? F1 balances the two numerically but does not know that missing a payment outage may cost more than reviewing a harmless spike.

Operational load matters too:

```text
review_utilization = incoming review candidates / sustainable reviewer capacity
```

A 95%-precision system producing 1,000 candidates per hour can still be unusable.

### Event time, observed time and ingest time

**Event time** is when the source says an event occurred. **Observed time** is when the collector saw it. **Ingest time** is when storage accepted it. Clock error, buffering, retries and backfill separate them.

If a deployment event arrives immediately but application logs arrive eight minutes late, ingest-time correlation can reverse the apparent order. Preserve all relevant clocks and uncertainty.

### Fingerprint, deduplication, grouping and inhibition

A **fingerprint** is a stable identity for equivalent alerts, often derived from carefully selected labels. **Deduplication** suppresses repeated delivery of the same alert identity. **Grouping** packages related alerts for joint handling. **Inhibition** suppresses one alert when another known condition explains why it should not notify.

Do not include volatile values such as timestamp or random pod UID in a service-level fingerprint; they create one identity per occurrence. Do not omit region, tenant or operation when those distinguish separate impact; that can merge unrelated incidents.

### Correlation, lag, topology and causality

**Correlation** means values vary together under a chosen method and window. **Lag** describes displacement in time. A **topology graph** represents believed dependencies at a particular version. **Causality** is a stronger mechanism claim: changing the cause, under relevant conditions, changes the effect.

Correlation may result from a shared dependency, shared traffic, instrumentation, a third variable or coincidence. A topology edge may be stale or represent permitted communication rather than the runtime path for affected requests.

Say “ranked cause candidate” until mechanism evidence and a safe test support stronger language.

### Forecast, horizon, interval and lead time

A **forecast origin** is the latest observation available when prediction occurs. The **horizon** is how far ahead. A **prediction interval** expresses a model-dependent uncertainty range. **Lead time** is the time between a useful decision and the deadline by which action must finish.

For capacity automation:

```text
usable_lead = predicted_threshold_time
            - now
            - approval_time
            - action_duration
            - safety_margin
```

If usable lead is not positive, an accurate forecast is operationally late.

### Explanation and evidence

A feature-attribution explanation describes how inputs influenced a model output under that explanation method. It is not proof that those features caused the production event. An explanation can be faithful to a bad model, unstable under small changes or unintelligible to the responder.

Useful evidence includes exact features, units, windows, baseline, score, threshold, missingness, nearby changes, topology version and counterexamples—not only a colored importance chart.

### Feedback, label delay and drift

**Feedback** is an observed review or outcome linked to the exact candidate and versions. “Dismissed” is not automatically “false positive”; the responder may be busy, the incident may be duplicate, or impact may have ended.

**Label delay** is time until outcome truth is available. **Data drift** changes input distribution. **Concept drift** changes the relationship between inputs and the operational label. **Policy drift** changes what the organization considers urgent or safe. Monitor them separately.

### Safe automation

Automation is a production control system. A detector proposes; deterministic code checks identity and policy; an authenticated authority approves; a least-privilege executor uses an idempotency key; independent observation verifies the postcondition; a deadline, effect budget, kill switch and rollback bound failure.

“Human in the loop” is meaningful only if that human has time, context, competence and power to refuse.

## Architecture map

### The complete decision path

```text
user operation / SLI / action contract
              |
              v
telemetry source -> identity + clocks + quality -> feature version
              |                                |
              v                                v
      simple baseline -----------------> detector / forecast
                                               |
                                    score + uncertainty + lineage
                                               |
                             fingerprint -> group -> hypotheses
                                               |
                         policy + human authority + effect budget
                                               |
                             idempotent action -> postcondition
                                               |
                              user outcome + reviewed feedback
```

Each arrow is a contract. If telemetry identity is wrong, the algorithm receives a fictional population. If time is wrong, order is fictional. If labels are wrong, evaluation rewards the wrong behavior. If authority is broad, one bad hypothesis becomes a production incident.

### Detection and paging are separate

```text
many observations -> detector candidates -> diagnostic dashboard
                                      |
                            user-impact/SLO gate
                                      |
                       urgent + actionable + owned?
                           /                    \
                         no                      yes
                  record or ticket              page
```

Detection can be broad and experimental. Paging must remain simple, explainable and tied to user impact or imminent exhaustion. An anomaly may enrich an existing SLO alert without being allowed to wake a human by itself.

### Alert reduction without evidence loss

```text
signal observations
       |
       v
raw alerts --immutable source IDs-->
       |
stable fingerprint -> exact deduplication
       |
bounded time + topology + impact grouping
       |
incident candidate + attached change evidence
       |
owner route + visible suppressed/split records
```

The reduction ratio is not the success metric. Compressing 500 alerts into one wrong incident is worse than presenting five correct groups. Measure whether groups preserve distinct incidents, owners, affected populations and timelines.

### Correlation is an evidence join

```text
incident interval + affected identity
       |          |          |          |
    traces      topology   changes     logs/metrics
       \          |          |          /
        candidate mechanism + counterexamples
                         |
                  safe test or observation
                         |
                 supported / rejected / unknown
```

A correlation engine should return joined evidence and uncertainty, not a theatrical root-cause sentence.

### Forecast is a timed decision

```text
history available at origin
       -> rolling-origin forecast
       -> horizon + prediction interval
       -> threshold-crossing range
       -> approval + action + margin
       -> completed capacity before risk
```

Forecast accuracy is necessary but insufficient. The horizon must match the action. A seven-day disk forecast cannot support procurement that needs six weeks, though it may support cleanup or traffic-control decisions.

### Automation remains outside detection

```text
detector output
  -> evidence package
  -> typed proposal
  -> current-state validation
  -> deterministic policy
  -> approval when required
  -> least-privilege idempotent executor
  -> system postcondition
  -> user-path postcondition
  -> stop / continue / rollback
```

The model has no credential. The executor cannot widen its own scope. A successful command is not the terminal condition; verified recovery or safe refusal is.

## Request or state path

### Path 1: one metric becomes one candidate

Trace a latency detector:

1. The source emits a histogram for service, operation, region and version.
2. Collection preserves unit, temporality, bucket boundaries, resource identity and event time.
3. Quality checks find gaps, resets, duplicates, clock error and scrape delay.
4. A feature builder calculates a declared percentile or bucket ratio for a fixed window.
5. The baseline selects comparable history and excludes no data using future knowledge.
6. The detector version emits score, threshold decision and explanation inputs.
7. Persistence policy requires enough duration or repeated windows to avoid a one-point page.
8. User-impact evidence decides whether this becomes diagnostic evidence, a ticket or a page.

If step 2 merged canary and stable versions, a sophisticated detector at step 6 only analyzes corrupted identity more confidently.

### Path 2: logs become templates and counts

Raw logs contain variable request IDs, durations, users and addresses. A parser may convert:

```text
payment request 91ae failed after 312 ms
payment request 44bc failed after 287 ms
```

into a template such as:

```text
payment request <*> failed after <*> ms
```

Now the system can count a stable event type. But parsing is another model or rule set. Under-parsing merges different failures; over-parsing creates one template per line. Store the raw record ID, parser version, template ID and extracted parameters. Evaluate parsing accuracy on representative software versions before anomaly detection uses template counts.

### Path 3: alerts become an incident candidate

```text
raw alert
 -> normalize labels without destroying source record
 -> calculate versioned stable fingerprint
 -> deduplicate exact repeats
 -> group inside bounded time + topology + impact scope
 -> attach deployments/config/traffic/security events
 -> rank cause candidates
 -> route to one accountable owner
 -> preserve suppressed and split evidence
```

The raw alert remains immutable. Every transformation records input IDs, rule or model version and reason. A responder must be able to answer, “Which alerts were hidden, and why?”

### Path 4: a cause candidate becomes a tested hypothesis

Suppose checkout latency and database connection wait rise together after a frontend deployment. The evidence supports several hypotheses:

- the deployment increased database calls;
- traffic increased and stressed both;
- a network fault slowed database calls and extended frontend work;
- telemetry delay made unrelated events appear aligned;
- the database was already degrading and the deploy was coincidental.

Join affected traces to actual database spans, compare unaffected operations and regions, inspect connection-pool saturation, verify deployment event time, and review the code/config diff. A scoped rollback may be a useful diagnostic intervention only if safe, authorized and reversible. If rollback changes neither symptom nor mechanism evidence, reduce that hypothesis rather than inventing certainty.

### Path 5: forecast becomes a capacity decision

At each forecast origin, train or update using only observations available then. Predict a horizon matching procurement, provisioning or migration lead. Emit point forecast plus interval. Convert threshold crossing into an action deadline with approval, execution and safety margin. Compare against a seasonal-naive baseline and measure errors by relevant service and horizon.

Do not train on the future, evaluate only calm periods, or report average error when underprediction near exhaustion is the costly case.

### Path 6: proposal becomes a bounded effect

The detector does not restart a pod. It creates an evidence package and action proposal. External code validates target identity and current state, evaluates deterministic policy, checks incident ownership and budgets, and requests approval where required. The executor uses a narrow operation such as “restart one named unhealthy replica only if replacement capacity is ready,” not a generic cluster shell.

After execution, verify both the system postcondition and the user operation. If either fails or uncertainty grows, stop and rollback or escalate.

## Failure zoom

### The “perfect” false correlation

At 10:02 a checkout deployment finishes. At 10:03 checkout latency rises, payment timeouts rise and database CPU rises. The correlation engine ranks the checkout deployment first with score 0.94. The team rolls back. Nothing improves.

The evidence later shows:

- a marketing event increased traffic at 10:00;
- telemetry from one region arrived three minutes late;
- the topology graph still showed a database path removed two releases earlier;
- the affected requests used a payment provider, not the ranked database;
- retry amplification raised database CPU as a downstream side effect;
- the rollback consumed attention while connection pools continued saturating.

The deployment and incident were genuinely close in observed time. That did not establish event order, runtime path or mechanism.

### Where the reasoning first failed

The first unsafe boundary was not the rollback command. The system promoted association to cause before validating identity and clocks:

```text
same dashboard window
   -> assumed same event time
   -> assumed stale graph edge was active
   -> assumed earlier event caused later metric
   -> hid alternative shared-traffic explanation
   -> produced one confident label
   -> operator treated ranking as authority
```

Fixing only the final approval would reduce impact but leave poor diagnosis. Fixing only the correlation model would leave broad authority. Reliable design repairs both evidence and effect boundaries.

### Containment

During the incident:

1. Stop autonomous or repeated remediation and preserve action receipts.
2. Restore symptom-first user-impact alerts and the normal incident command path.
3. Preserve raw telemetry, event/observed/ingest clocks, detector features, model/threshold, group membership, topology version and change records.
4. Mark the cause ranking as unverified and expose alternative candidates.
5. Reconcile current deployment and replica state before any further action.
6. Use the smallest reversible mitigation supported by direct evidence.
7. Verify recovery with the affected user operation, not the anomaly score.

### Recovery and prevention

Rebuild the timeline using source event time plus clock-quality and arrival-delay evidence. Reconstruct actual request paths from traces for affected and unaffected populations. Compare traffic, retries and saturation. Test the deployment hypothesis against its diff and a safe control. Then update labels with reviewer identity, confidence and evidence—not merely “rollback clicked.”

Prevention connects:

- versioned telemetry and topology contracts;
- time-safe evaluation;
- counterexample requirements for cause ranking;
- uncertainty and “unknown” output;
- independent user-impact paging;
- least-privilege actions;
- rollout shadowing and kill switch;
- incident review of both missed and harmful recommendations.

## Internals and state ownership

### Define the task before choosing a detector

“Find anomalies” is not an operational task. A usable contract says:

```text
population: checkout create-order in each production region
decision interval: every 1 minute
harm: sustained user-visible failures or imminent capacity exhaustion
output: evidence-enriched incident candidate, not a page by itself
abstain: missing identity, late data, unseen version, insufficient history
baseline: SLO burn alert plus static saturation guard
action: human triage; no production mutation
```

This tells you which labels, windows, error costs and failure-safe behavior matter.

### Telemetry quality comes before model quality

Validate:

- semantic name, unit, type and aggregation;
- counter reset versus actual decline;
- cumulative versus delta temporality;
- sampling and dropped records;
- event, observed and ingest time;
- clock uncertainty and collection lag;
- stable service, operation, region, zone, tenant and version identity;
- missingness and cardinality changes;
- instrumentation and collector version.

A gap filled with zero can look like recovery. A counter reset can look like a negative anomaly. Delayed backfill can create a false spike. A renamed service can look like one service disappeared and another appeared. The detector cannot repair semantics it never received.

### Transparent baselines first

Start with the least complex baseline that can represent the operation:

1. static safety threshold for hard limits;
2. previous comparable period or seasonal-naive value;
3. rolling median and MAD for robust local residuals;
4. decomposition into level, trend, seasonality and residual;
5. multivariate or learned detector only when simpler methods fail a declared requirement.

This order provides a benchmark and an escape route. If a learned detector cannot beat a seasonal-naive baseline on cost and lead time, complexity has not earned production ownership.

#### Worked MAD example

Reference residuals are:

```text
[-2, -1, -1, 0, 0, 1, 1, 2, 20]
```

The median is 0. Absolute deviations are `[2,1,1,0,0,1,1,2,20]`; sorted, their median is 1. For a new residual of 6:

```text
robust_z = 0.6745 * 6 / 1 = 4.047
```

That is unusual relative to this reference. It is not automatically user impact. You still need population identity, persistence, error cost and operational context. If the reference were all zero, MAD would be zero and the formula must not be used blindly.

### Univariate and multivariate detectors

A **univariate** detector analyzes one series. It is easier to explain and operate but misses relationship failures. A **multivariate** detector evaluates several features jointly and may notice that CPU 70% is ordinary and throughput 100/s is ordinary, yet that combination is unusual for this service.

Multivariate models also increase risk:

- feature units and scaling matter;
- missing one feature may shift the score;
- high dimensionality can make distances less meaningful;
- topology and workload changes alter relationships;
- explanations can be unstable;
- one leaked future feature can inflate evaluation.

Pin the exact ordered feature contract and preprocessing. Log missingness and per-feature contribution. Provide a safe fallback when the contract changes.

### Streaming state

A streaming detector owns more than model parameters. It owns window contents, update position, warm-up state, seasonal state, threshold, feature schema and model version. A restart without restoring compatible state may relearn during an incident and treat the incident as normal. Duplicated or out-of-order observations can update state twice or backwards.

Define:

- event ordering and allowed lateness;
- checkpoint identity and compatibility;
- update-before-score or score-before-update semantics;
- warm-up and cold-start behavior;
- incident contamination policy;
- replay and backfill isolation;
- reset, rollback and state migration.

### Time-safe evaluation

Random row splitting usually leaks future patterns into the past. Use rolling origins:

```text
train [1..100] -> test [101..110]
train [1..110] -> test [111..120]
train [1..120] -> test [121..130]
```

At each origin, features, baselines and labels must use only data available then. Preserve label availability time: if incident truth arrived two days later, an online model at the original moment did not possess it.

Evaluate by incident and time range, not just points. A detector that hits one point in a two-hour incident should not automatically receive credit for the entire interval. Measure:

- event precision and recall;
- time to detect;
- duration coverage;
- duplicate pages per incident;
- false pages per on-call shift;
- missed user-impact minutes;
- review workload;
- recovery improvement or harm.

Always compare a random or simple baseline where appropriate. Suspiciously perfect results demand a leakage and scoring audit.

### Thresholds are economic and safety policy

Suppose 100 evaluated incident candidates produce `TP=18`, `FP=12` and `FN=2`:

```text
precision = 18 / 30 = 0.60
recall    = 18 / 20 = 0.90
F1        = 2 * 0.60 * 0.90 / 1.50 = 0.72
```

Whether to use it depends on cost. Twelve false candidates may be tolerable in a weekly report and disastrous as midnight pages. Two misses may be unacceptable if both are payment outages. Evaluate severity, region, operation and action separately. Thresholds belong in versioned reviewed configuration with rollback.

### Persistence, hysteresis and cooldown

**Persistence** requires a condition to last long enough. **Hysteresis** uses different enter and exit thresholds so state does not flap. **Cooldown** limits repeat action after a decision.

They solve different problems. Persistence rejects brief noise. Hysteresis stabilizes boundary crossings. Cooldown limits repetition. None proves correctness; a long false signal can persist, and cooldown can suppress a second real incident.

### Deduplication and grouping

Create a fingerprint from stable fields that mean “same notification,” for example:

```text
alert rule + service + operation + region + severity contract
```

Keep volatile instance identity as evidence even if it is excluded from a service-level fingerprint. Group only inside a bounded window and declared relationship. Track:

```text
dedup_ratio = raw alert deliveries / unique alert fingerprints
group_ratio = unique fingerprints / incident candidates
```

High ratios show compression, not correctness. Audit split incidents, merged incidents, hidden critical alerts, routing accuracy and time saved.

### Topology and change evidence

Topology may come from configuration, service discovery, traces, network flow or ownership metadata. Each source answers a different question:

- configuration says what should connect;
- discovery says what endpoints are registered;
- traces say what sampled requests traversed;
- network flow says what communicated;
- ownership says who is accountable.

Version the graph and record edge source, direction, confidence and observation interval. Join deployments, feature flags, configuration, certificate, routing, quota and maintenance events using exact target and event time. “Recent change” is useful only after defining recent relative to mechanism delay.

### Probable-cause ranking

A good ranking record contains:

- incident and affected population;
- candidate component or change identity;
- supporting signals and lags;
- topology path and version;
- contradicting evidence and unaffected controls;
- possible confounders;
- mechanism statement;
- safe next test;
- calibrated score or ordinal rank;
- explicit unknown option.

Never train “the action humans took” as unquestioned cause truth. Humans often choose the safest hypothesis under pressure and may never prove it.

### Forecasts

Choose horizon from the action:

- minutes for automatic load shedding;
- hours for storage cleanup or fleet scaling;
- weeks for quota, procurement or migration.

Measure error per horizon and costly direction. Mean absolute error is easy to interpret; root mean squared error penalizes larger misses more; percentage errors misbehave near zero. Prediction-interval coverage asks whether the observed value falls inside the declared interval at the promised rate. None replaces threshold-crossing and lead-time evaluation.

### Explanation is a model diagnostic

Feature attribution can show which inputs moved a model score relative to its reference. Verify:

- exact model and feature vector;
- reference/background population;
- stability under small reasonable changes;
- consistency with direct evidence;
- comprehensibility to the responder;
- absence of sensitive values;
- whether the explanation changes a decision safely.

Do not say “CPU caused the incident because SHAP was highest.” Say “CPU was the largest attributed input for detector version X on this candidate; traces and saturation evidence do or do not support the mechanism.”

### Feedback is a governed dataset

Capture incident ID, candidate ID, original evidence, detector/threshold/group versions, reviewer identity and role, decision, reason, confidence, later outcome and label-available time. Permit correction and disagreement. Separate:

- true incident versus actionable page;
- correct grouping versus correct cause;
- useful explanation versus correct model;
- safe recommendation versus executed action;
- successful execution versus recovered user outcome.

Otherwise one “thumbs up” trains several unrelated truths.

### Automation is a reconciled state machine

Define states such as:

```text
proposed -> validated -> authorized -> executing
         -> verified-success
         -> verified-no-effect
         -> rollback-required
         -> refused
         -> expired
```

Use an immutable action ID and idempotency key. Before retry, read the target and determine whether the intended effect already occurred. Bound total deadline, targets, concurrency, retries and irreversible effects. Keep the detector identity separate from executor identity. Log approval and policy decisions without sensitive payloads.

## Evidence table

| Evidence | What it can support | What it cannot prove alone |
|---|---|---|
| User-journey SLI by operation and region | observed impact for that measured journey | cause or every user |
| Metric name, unit, temporality and resource labels | interpreted series identity | source correctness or completeness |
| Event, observed and ingest timestamps | ordering and pipeline-delay analysis | perfectly synchronized clocks |
| Missingness, resets, duplicates and collector lag | telemetry-quality failure | application health |
| Median, MAD, season and residual | transparent baseline comparison | harmful incident |
| Detector version, features, score and threshold | why this version classified the candidate | calibrated probability or causality |
| Incident labels with reviewer and availability time | supervised evaluation target with provenance | universal objective truth |
| Rolling-origin evaluation | past-to-future performance on tested periods | future production distribution |
| TP, FP and FN by severity slice | precision/recall and error pattern | business acceptability without cost |
| Raw alert and fingerprint | deduplication decision lineage | common incident |
| Group membership and window | why events were bundled | shared root cause |
| Topology edge with source/version | believed or observed relationship | affected runtime path for every request |
| Deployment/configuration event | exact nearby change | that the change caused impact |
| Trace and log mechanism evidence | request-level support for a hypothesis | all traffic when sampled or incomplete |
| Unaffected control population | evidence against broad hypotheses | absence of localized effect |
| Feature attribution | model-input influence under a method | physical or organizational cause |
| Forecast horizon, interval and coverage | predicted range and tested uncertainty | action will finish in time |
| Human decision and later outcome | reviewed usefulness and delayed truth | error-free reviewer |
| Policy decision, approval and executor receipt | authorized attempted effect | recovered user outcome |
| Independent postcondition | observed state after action | durable prevention |

The senior habit is to complete both columns. It prevents “we have data” from becoming “we have proof.”

## Command decoders

### `bash lab.sh doctor`

Read: “Can this bounded teaching model run without root, credentials, endpoints or unsafe state?” A pass proves only local guards and fixture structure. A refusal is a safety result; do not export credentials or disable the check.

### `bash lab.sh setup`

Creates a UID-scoped directory under `/tmp` containing one sentinel and one synthetic JSON fixture. It does not install a model or telemetry service. If state already exists, inspect it; do not delete an unfamiliar directory.

### `bash lab.sh status`

Counts validated cases only after ownership, sentinel and exact-inventory checks. `cases=29` means the teaching fixture is present. It says nothing about production coverage.

### `bash lab.sh evaluate baseline`

Expected:

```text
case=baseline decision=operable boundary=operable
```

This means every Boolean and capacity condition in one synthetic record passes in declared order. It is a control case, not evidence that AIOps should be deployed.

### `bash lab.sh evaluate seasonality-ignored`

Expected boundary `seasonality`. Think: the current value may be perfectly normal for this hour, weekday, launch or billing cycle. Repair the comparison population before tuning the threshold.

### `bash lab.sh evaluate future-leakage`

Expected boundary `time-split`. Future data, labels, global normalization or randomly mixed rows can make offline performance impossible online. Reconstruct what was knowable at every forecast origin.

### `bash lab.sh evaluate review-capacity-exceeded`

The fixture has twelve candidates per hour and capacity for eight. Utilization is:

```text
12 / 8 = 1.5 = 150%
```

Even if candidates are individually plausible, backlog grows by four per hour. Reduce arrivals, improve routing or add sustainable reviewed capacity; never conceal overload by dropping evidence silently.

### `bash lab.sh evaluate unstable-dedup-key`

Expected boundary `deduplication`. Inspect which stable fields define equivalence and which dimensions must remain to separate incidents. Test both repeat collapse and “must not merge” pairs.

### `bash lab.sh evaluate correlation-claimed-cause`

Expected boundary `causal-claim`. Rewrite the output as a hypothesis with support, contradiction, confounders and a safe next test. Changing the label from “root cause” to “candidate” is an operational control.

### `bash lab.sh evaluate forecast-too-late`

Expected boundary `forecast-lead`. Bind predicted threshold range to approval, procurement/provisioning, execution and verification duration. A precise late forecast is not useful.

### `bash lab.sh evaluate automation-overprivileged`

Expected boundary `automation-authority`. Narrow action, target, identity, condition, time and concurrency. Approval does not compensate for a generic admin shell.

### `bash verify.sh`

Runs all 29 ordered cases, deliberately inserts an unknown artifact to prove refusal, removes it through the reviewed path, cleans owned state and proves absence. It does not run algorithms or production changes.

## Decision path

### When a value looks strange

```text
Is a user operation failing or a hard boundary approaching?
  no  -> diagnostic observation; do not page from novelty alone
  yes -> bind service/operation/region/version and exact interval
          |
          v
Are identity, units, clocks, gaps, resets and delay trustworthy?
  no  -> telemetry incident; preserve raw data and repair the path
  yes -> compare static safety and simple seasonal/robust baseline
          |
          v
Does a more complex detector beat the baseline on sliced cost and lead?
  no  -> keep the simpler control
  yes -> shadow, explain limits, canary and monitor drift
```

### When many alerts arrive

1. Preserve raw source alerts.
2. Normalize through a versioned mapping.
3. Deduplicate only exact stable fingerprint repeats.
4. Group inside bounded time, identity, topology and impact.
5. Show suppressed and split decisions.
6. Route by accountable ownership.
7. Measure missed merges and harmful merges against reviewed incidents.

If review arrivals exceed capacity, containment is an operational load decision. Protect urgent user-impact pages, degrade enrichment before detection, queue lower urgency work with age limits and expose backlog.

### When a “root cause” is suggested

Ask in order:

1. Are event clocks and observation delays known?
2. Does the affected request path traverse the candidate?
3. Did the candidate state change before the effect under source time?
4. Is there a plausible mechanism?
5. Do unaffected controls contradict it?
6. Could traffic, dependencies or instrumentation explain both?
7. What safe reversible observation or intervention distinguishes hypotheses?
8. What evidence would make the answer remain unknown?

Do not force a winner. “Unknown, investigate these three candidates” can be the most reliable output.

### When a forecast suggests action

```text
forecast origin and history valid?
 -> horizon matches action?
 -> interval coverage acceptable?
 -> costly underprediction measured?
 -> threshold crossing leaves approval + execution + margin?
 -> fallback exists if forecast service fails?
 -> authorized action is bounded and reversible?
```

If any answer is no, the forecast may stay informational but must not own the action.

### When automation is proposed

Begin at advisory-only. Progress through automation levels only with evidence:

| Level | Effect | Required evidence |
|---|---|---|
| observe | dashboard candidate | telemetry and evaluation lineage |
| advise | ranked evidence and runbook | calibrated usefulness and uncertainty |
| prepare | generate exact proposed diff/action | deterministic policy and current-state validation |
| approve | human or external authority authorizes | identity, consequence, rollback and veto |
| execute bounded | narrow idempotent operation | least privilege, budgets, receipt and kill switch |
| reconcile | verify state and user outcome | independent postconditions and stop conditions |

Never jump from an offline score to autonomous production mutation.

## Guided Ubuntu lab

### Purpose and limits

This lab teaches decision order. It contains synthetic Boolean contracts and two capacity integers. It deliberately does not compute MAD, train a forest, parse a log, forecast a series, query telemetry or execute remediation. That limitation is a feature: you can inspect every branch before later replacing a boundary with representative evidence.

Run only as a normal Ubuntu 24.04 user. Do not export API keys, cloud endpoints or `KUBECONFIG`. The guard refuses them because this lab needs none.

### Step 1: enter the exact directory

From the repository:

```bash
cd drafts/LES-0067-aiops-evidence-safe-automation/support/lab
pwd
```

The final path must end in `support/lab` for LES-0067. Directory identity matters because cleanup is deliberately narrow.

### Step 2: inspect safety

```bash
bash lab.sh doctor
```

Expected:

```text
fixture=valid cases=29
doctor=pass network=none user=<your numeric UID>
```

If it refuses root, a credential, endpoint, symlink or prior unowned state, stop. The lesson never requires bypassing that boundary.

### Step 3: create bounded copied state

```bash
bash lab.sh setup
bash lab.sh status
```

The setup uses restrictive permissions and copies the synthetic fixture into a UID-specific `/tmp` directory. Status verifies exact inventory and reports 29 cases. Run `setup` only once until cleanup.

### Step 4: establish the control

```bash
bash lab.sh evaluate baseline
```

Explain aloud: “Every modeled prerequisite passes, so the deterministic model reaches operable. This proves the rule order only.”

### Step 5: break the evidence chain

Run:

```bash
bash lab.sh evaluate telemetry-identity-missing
bash lab.sh evaluate seasonality-ignored
bash lab.sh evaluate future-leakage
```

For each result, answer:

1. What is the first failed boundary?
2. What false conclusion might an operator draw?
3. What evidence would repair it?
4. What remains unproved afterward?

Expected reasoning:

- Missing identity can merge different services, versions or regions.
- Ignored seasonality can page on normal periodic demand.
- Future leakage creates an offline score unavailable at decision time.

### Step 6: see human capacity as system capacity

```bash
bash lab.sh evaluate review-capacity-exceeded
```

The case supplies 12 candidates per hour and capacity for 8. Net backlog grows at 4 per hour. After a six-hour shift, the ideal backlog is 24 candidates if rates remain fixed. Real review variability makes this only a lower-bound scenario.

Do not “fix” overload by suppressing unknown alerts invisibly. Protect high-confidence user-impact pages, preserve queued evidence, expose age and loss, and revise thresholds or routing through reviewed data.

### Step 7: separate compression from correctness

```bash
bash lab.sh evaluate unstable-dedup-key
bash lab.sh evaluate unbounded-group-window
bash lab.sh evaluate stale-topology
```

A stable fingerprint, bounded group window and current topology are three different contracts. Passing one cannot compensate for another. Write one example pair that must merge and one pair that must remain separate.

### Step 8: refuse a causal shortcut

```bash
bash lab.sh evaluate correlation-claimed-cause
bash lab.sh evaluate cause-not-tested
```

The first rejects causal language. The second rejects an untested candidate even after the language is corrected. A safe output includes support, contradiction, confounders and next evidence.

### Step 9: connect forecast to action

```bash
bash lab.sh evaluate forecast-no-interval
bash lab.sh evaluate forecast-too-late
```

A point forecast hides uncertainty. An interval still has no operational value if it arrives after the action window. Describe the target threshold, horizon, approval duration, action duration and margin.

### Step 10: bound automation

```bash
bash lab.sh evaluate automation-overprivileged
bash lab.sh evaluate action-not-idempotent
bash lab.sh evaluate rollback-untested
```

These stop at authority, repeated effect and recovery respectively. A read-only proposal can be useful even when execution is refused.

### Step 11: prove all branches and cleanup

First return to absent state:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=29 refusal=true cleanup=true
```

The verifier inserts an unknown file, proves normal status refuses it, removes it only through the reviewed helper and proves final absence. Verify separately:

```bash
test ! -e "/tmp/reliability-atlas-les0067-aiops-$(id -u)"
```

Success proves only the bounded teaching lifecycle.

### Independent extension without unsafe effects

Copy `cases.json` to a separate disposable directory and design three new records:

- a missing-scrape interval mistakenly filled with zero;
- two regional incidents wrongly merged by a global fingerprint;
- a correct forecast whose lower-bound threshold crossing leaves insufficient action time.

Predict the first boundary before running anything. Do not weaken the fixture schema or guard. A reviewer should compare your reasoning, not merely the terminal text.

## Production transfer

### Start with one narrow decision

Choose a high-volume, well-instrumented, low-authority use case. A good first system might rank diagnostic evidence for an already-fired SLO alert. A poor first system automatically restarts arbitrary workloads based on unsupervised novelty.

Write an adoption record:

- operation and owner;
- current baseline and toil;
- user harm and error costs;
- data population and exclusions;
- label source and delay;
- permitted output and abstention;
- explicit forbidden actions;
- evaluation and review gates;
- rollback and retirement criteria.

### Build an evaluation corpus

Use sanitized historical intervals with exact service/version/topology/change identity. Include normal peaks, maintenance, telemetry gaps, cold starts, deploys, regional faults, partial outages and multiple simultaneous incidents. Keep a final held-out time period and an unseen reviewer-created transfer set.

Labels need source and confidence. Incident tickets are imperfect: detection may begin before declaration, impact may differ by region, and the recorded “root cause” may be a contributing factor. Preserve disagreement instead of forcing false certainty.

### Separate evaluation layers

Evaluate each transformation:

1. telemetry contract and missingness;
2. log-template or feature extraction;
3. anomaly candidate;
4. deduplication;
5. incident grouping;
6. cause-candidate ranking;
7. forecast;
8. action proposal;
9. policy and approval;
10. execution and postcondition;
11. user outcome.

An end-to-end score cannot tell you which layer failed. A perfect detector cannot rescue a grouping algorithm that hides the critical region.

### Roll out in evidence stages

Use:

```text
offline replay
 -> shadow with no notification
 -> responder-visible diagnostic panel
 -> optional recommendation
 -> low-risk canary routing
 -> prepared but unexecuted action
 -> approved bounded action
 -> narrowly autonomous reversible action
```

Every transition has a gate and rollback. Compare against the previous operational process, including mean time to detect, time to useful hypothesis, pages per shift, missed impact, review time and harmful action.

### Run the AIOps service like production

The AIOps path has its own dependencies and SLOs:

- telemetry intake freshness and loss;
- feature and parser lag;
- model/threshold availability;
- grouping queue age;
- topology and change-feed freshness;
- inference latency and saturation;
- incident-platform delivery;
- policy and executor availability;
- feedback and label lag.

If enrichment fails, preserve simple user-impact alerting. The safe degradation path is usually less clever and more direct.

## Reliability, security, observability, capacity, and cost

### Reliability

Define service objectives per stage. A detector availability SLO is not enough. Measure whether user-impact alerts still reach responders during model, topology or feature-store failure. Make duplicate delivery safe. Checkpoint streaming state compatibly. Use version manifests and deterministic rollback. Test cold start, missing features, delayed data, reordered events, stale graph, partial dependency failure and backpressure.

Avoid a circular dependency where AIOps is required to diagnose the observability platform that supplies AIOps. Keep an independent minimal monitor for telemetry freshness, alert delivery and automation kill state.

### Security

Telemetry and incident records reveal architecture, vulnerabilities, customer identifiers and operational response. Apply least privilege separately to raw telemetry, model features, incident data, policy and executor. Treat logs and generated summaries as untrusted content. Validate every output before rendering or executing. Protect model, parser, feature, topology and threshold supply chains.

The detector must never inherit executor credentials. Use narrowly scoped service identities, network boundaries, approval identity, tamper-evident audit and break-glass procedures. Test negative authorization: wrong tenant, stale incident, widened target, expired proposal, replayed action and unauthorized rollback.

### Privacy

Minimize before collection and again before feature construction. Hashing an identifier may still leave linkable personal data. Embeddings, templates, incident summaries, traces, feedback and explanation artifacts can retain sensitive content. Define purpose, access, residency, retention, deletion and backup propagation for every copy.

Do not send raw employer, customer or credential-bearing data to a model or external service for this course. Synthetic or properly sanitized evidence remains the default.

### Observability

Observe the decision chain, not just CPU:

- input records, loss, lag and schema versions;
- feature availability and distributions;
- baseline and detector versions;
- scores, thresholds, abstentions and reasons;
- candidates, fingerprints, groups and suppression;
- graph/change versions and cause ranks;
- forecast origin, horizon, interval and error after truth arrives;
- human decisions, disagreement and label delay;
- proposals, policy denials, approvals, actions and postconditions;
- drift, rollback and kill-switch state.

Control cardinality and sensitive values. Join through opaque stable IDs rather than logging entire prompts, incident bodies or credentials.

### Capacity

Model each queue:

```text
net_drain = processing_rate - arrival_rate
drain_time = backlog / net_drain, only when net_drain > 0
```

Size burst buffers, retained replay, feature state, inference, grouping, reviewer capacity and executor concurrency. Include incident storms when telemetry and model demand rise exactly as dependencies degrade. Apply admission control: preserve user-impact alerting, then essential enrichment, and shed experimental explanations first.

### Cost

Count:

- telemetry ingestion and retention;
- high-cardinality features;
- feature and model computation;
- topology/change storage;
- model or API calls;
- incident-platform traffic;
- human review and interrupted time;
- false remediation and missed-impact cost;
- dual-run, replay and rollback capacity.

Prefer outcome-linked units such as cost per correctly grouped actionable incident, cost per useful cause hypothesis, or cost per avoided impact minute. “Cost per inference” can fall while total operational cost rises.

## Traps and prevention

### Trap: unusual means broken

**Why it fails:** legitimate launches, seasonality and topology changes are unusual.

**Prevention:** bind user impact, context and action. Permit diagnostic novelty without paging.

### Trap: choose a complex detector before a baseline

**Why it fails:** complexity hides whether the problem needed a model and removes an easy fallback.

**Prevention:** benchmark static, seasonal-naive and robust rules first; demand sliced operational improvement.

### Trap: random train/test rows

**Why it fails:** future patterns and repeated incident points leak into training.

**Prevention:** rolling-origin splits, incident-level separation and label-availability time.

### Trap: count one detected point as the whole incident

**Why it fails:** score inflation can reward late or random hits.

**Prevention:** event-aware precision/recall, detection delay, duration coverage and simple/random baselines.

### Trap: optimize alert reduction

**Why it fails:** wrong deduplication or grouping can hide independent incidents.

**Prevention:** must-merge and must-not-merge test pairs; audit raw-to-group lineage.

### Trap: latest change is root cause

**Why it fails:** busy systems always have nearby changes; clocks, traffic and shared dependencies confound.

**Prevention:** rank hypotheses with topology, traces, controls, mechanism and safe tests.

### Trap: explanation proves causality

**Why it fails:** attribution explains a model response under assumptions.

**Prevention:** label it model evidence and validate against independent operational evidence.

### Trap: average forecast error is enough

**Why it fails:** horizon, interval, underprediction near capacity and action lead determine usefulness.

**Prevention:** evaluate per horizon and costly direction; connect threshold range to completion deadline.

### Trap: every click is a label

**Why it fails:** acknowledgement, dismissal, duplication and mitigation are different meanings.

**Prevention:** governed feedback schema, reviewer confidence, delayed outcome and correction.

### Trap: confidence authorizes automation

**Why it fails:** model confidence does not authenticate intent or bound blast radius.

**Prevention:** deterministic policy, least privilege, approval, idempotency, budgets, postconditions, kill switch and rollback.

## Memory card and retrieval

Remember:

```text
IMPACT -> IDENTITY -> TIME -> BASELINE -> EVALUATE
       -> REDUCE -> HYPOTHESIZE -> FORECAST -> AUTHORIZE -> VERIFY
```

- Unusual is not automatically harmful.
- Event time is not observed time.
- A score is not a probability unless calibrated as one.
- Thresholds encode operational cost.
- Deduplication removes repeats; grouping proposes relationships.
- Fewer alerts do not guarantee better incidents.
- Correlation ranks a hypothesis; mechanism evidence supports cause.
- Feature attribution explains a model, not production reality.
- A forecast is useful only before the action deadline.
- Feedback needs identity, meaning and delayed truth.
- The detector proposes; external authority decides.
- Execution success is not user recovery.

Retrieval drill: close the chapter and reconstruct the ten-word chain. Then explain one counterexample for each arrow. If you cannot state what a signal does **not** prove, return to the evidence table.

## Complete answers

### What should I do when an anomaly detector fires?

Begin with the affected user operation and a trustworthy simple symptom signal. Bind service, operation, region, tenant where authorized, version and interval. Check units, missing samples, resets, event versus observed time and collector delay. Compare the current value with a static safety boundary and a transparent seasonal or robust baseline. Record detector version, features, score and threshold, but do not let the score outrank direct user impact.

If impact is real, preserve the candidate as evidence inside the incident. If impact is absent, decide whether the anomaly is an early capacity signal, a diagnostic record, a telemetry fault or benign change. Route based on urgency and actionability. Never page merely because “something seems strange,” and never auto-remediate without independent policy and authority.

### Which anomaly algorithm should I use?

Choose from the task, not popularity:

- Use hard thresholds for invariant safety limits.
- Use seasonal-naive comparisons for stable repeating demand.
- Use rolling median/MAD for a transparent robust local baseline.
- Use change detection for persistent regime shifts.
- Use novelty detection only when normal training data is credible.
- Use outlier detection when the reference may contain anomalies and its assumptions fit.
- Use multivariate methods when relationships add proven value beyond simpler features.

Compare every candidate to the simplest credible baseline on representative time slices, incident-level metrics, delay, reviewer load, runtime cost and failure behavior. If the complex method does not materially improve the operational decision, choose the simpler one.

### How do I evaluate rare operational anomalies?

Accuracy can be misleading. If only 1 of 1,000 intervals contains an incident, predicting “normal” always gives 99.9% accuracy and finds nothing. Use precision and recall with severity-specific costs, plus detection delay, incident coverage, duplicate pages and false pages per shift.

Keep chronological splits. Prevent the same incident, software version or future normalization statistics from appearing on both sides. Preserve label-availability time. Test normal peaks, missing data, deploys, maintenance, regional faults and simultaneous incidents. Include a simple and, where meaningful, random baseline. Evaluate abstention as an outcome rather than forcing every interval into normal or anomaly.

### How should alert deduplication work?

Define equivalence explicitly. A fingerprint uses stable dimensions required to mean the same notification. Deduplicate repeated deliveries of that identity while retaining count, first/last time, source IDs and changed evidence. Do not place volatile timestamp or random instance ID in a service-level key. Do not remove region, operation, tenant or severity when those define separate impact.

Grouping is separate. It may combine different fingerprints inside a bounded time and topology scope into an incident candidate. Evaluate must-merge and must-not-merge examples. Always make suppressed, merged and split lineage inspectable.

### How can I identify root cause with AIOps?

You usually cannot identify root cause from correlation alone. Use the system to rank hypotheses. Require correct clocks, affected identity, current topology, exact change events, trace paths, mechanism evidence, unaffected controls, contradictions and confounders. Offer a safe discriminating test.

Call the output “cause candidate” until evidence supports a mechanism. Preserve “unknown.” A rollback that improves the symptom supports the change hypothesis but may still leave shared or contributing factors; a rollback that does not improve it is evidence against that hypothesis. The incident review, not a single rank, establishes the defensible causal story.

### When is a forecast operationally useful?

The forecast origin must use only available history. The horizon must match the action duration. Report intervals, not only a point. Evaluate per horizon and costly direction, especially underprediction near exhaustion. Calculate:

```text
usable_lead = earliest credible threshold crossing
            - now - approval - action - safety margin
```

If usable lead is nonpositive, choose an earlier forecast, a faster action or a static safety fallback. Also define what happens when the forecast pipeline is late, missing or drifting.

### What does an explanation prove?

It can explain how features contributed to a model output under the chosen method and reference population. It can help debug leakage, surprising dependence or unstable features. It does not prove the production cause, model correctness or action safety.

Bind explanation to model, feature vector, background/reference data and method version. Test stability and compare with direct evidence. Show raw units and windows. Phrase the result precisely: “queue residual contributed most to this score,” not “the queue caused the outage.”

### How do I make automated remediation safe?

First make advisory output useful. Then constrain the effect outside the model:

1. exact incident, target and current-state identity;
2. typed narrow action;
3. deterministic preconditions and deny-by-default policy;
4. least-privilege executor distinct from detector;
5. authenticated approval for material risk;
6. immutable operation and idempotency keys;
7. total deadline, concurrency, retry and effect budgets;
8. state reconciliation before retry;
9. system and user postconditions;
10. kill switch, tested rollback and escalation.

Automate only actions whose preconditions and outcomes are observable. If the system cannot tell whether the first action happened, it is not ready to retry.

## Product-company interview

### Design AIOps for a global payment platform

Start with payment authorization outcomes per operation, region, issuer class and version; do not begin with an algorithm. Preserve metric semantics and event time. Keep SLO burn alerting independent. Establish seasonal-naive and robust baselines, then evaluate candidate detectors on held-out incidents, normal peaks and telemetry failures with cost-weighted precision/recall and delay.

Use stable alert fingerprints and bounded region/topology grouping. Attach deployments, routes, dependency health and traces as evidence. Rank cause candidates with contradictions and unknown. Roll out offline, shadow and diagnostic-only. Any action remains typed, least privilege, approved, idempotent and verified against authorization success—not detector score.

### A vendor claims 99% anomaly-detection accuracy. What do you ask?

Ask the prevalence, unit of scoring, label source, time split, point adjustment, leakage controls, populations, incidents, false positives per shift, false negatives by severity, detection delay, abstention, simple/random baseline, threshold selection, unseen versions, missing-data cases and runtime cost. Ask whether 99% is accuracy, precision, recall, F1, ROC area or a proprietary score.

Then request reproducible evaluation on your sanitized held-out operations. A vendor benchmark cannot establish your user harm, telemetry semantics or workflow capacity.

### The correlator reduced 10,000 alerts to 20 incidents. Is it successful?

The reduction ratio is 500:1, but success is unknown. Measure distinct real incidents preserved, harmful merges, missed merges, owner routing, critical-alert visibility, detection and triage delay, responder effort and user outcome. Inspect raw-to-group lineage and topology/window versions. One hidden regional outage can outweigh thousands of correct duplicate collapses.

### A deployment has the highest cause score. Do you roll it back?

Not from rank alone. Verify source event time, affected request path, diff and mechanism; inspect traffic and shared dependencies; compare unaffected populations; establish rollback safety and current compatibility. If impact is severe and rollback is the safest reversible mitigation, incident authority may choose it while explicitly treating diagnosis as uncertain. Verify outcome and update the hypothesis from evidence.

### Design predictive disk-capacity operations

Define the exhaustion threshold including filesystem reserve, maintenance/rebuild demand and growth. Preserve exact filesystem or volume identity and counters. Compare trend and seasonal-naive forecasts using rolling origins. Report intervals and underprediction near threshold. Choose horizon longer than approval plus provision/migrate plus validation plus margin. Keep hard fullness alerts and safe admission control as independent fallback. Automate only bounded cleanup or scaling actions with ownership, exclusions, idempotency and rollback.

### How do you prevent the AIOps platform becoming a single point of failure?

Keep simple symptom/SLO alerting independent. Isolate ingestion, feature, inference, grouping and execution failures. Persist versioned state and replay safely. Apply backpressure and priorities so enrichment sheds before paging. Monitor freshness and loss from outside the platform. Maintain fallback routing, manual runbooks and a tested kill switch. Never require the failed AIOps path to authorize its own recovery.

## Independent transfer and rubric

The learner receives an unseen sanitized telemetry, incident, topology, change, detector, forecast, feedback and action packet. They must define the operation and costs, reconstruct source and observation time, find the first invalid evidence boundary, calculate evaluation and capacity measures, split wrongly grouped incidents, challenge one causal rank, decide whether one forecast is actionable, contain one unsafe automated effect, prove recovery independently and revise the design after a major topology, workload, label, privacy, authority or action-lead constraint changes.

- **90–100:** complete identities and clocks, honest time-safe evaluation, correct calculations, preserved alert/incident lineage, restrained causal claims, actionable uncertainty and bounded reversible automation.
- **75–89:** safe operational plan with minor evidence, slice or calculation gaps.
- **60–74:** useful concepts but one major telemetry, evaluation, grouping, causality, forecast or authority boundary is weak.
- **below 60:** treats unusual as harmful, score as probability, correlation as cause, compression as correctness or model output as authority.

Automatic failure: real credentials or customer data, shared service, unrestricted shell/network/admin action, unbounded load or loop, hidden suppression, fabricated label/evidence, unauthorized effect or missing teardown. Reading and the offline model do not award mastery.

## References and review

- [Google SRE: Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) and [Monitoring Systems with Advanced Analytics](https://sre.google/workbook/monitoring/) — symptom-first alerting, purposeful diagnostics, change evidence and monitoring delay.
- [Prometheus alerting practices](https://prometheus.io/docs/practices/alerting/) and [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) — actionable symptoms, routing, grouping, deduplication, inhibition and silences.
- [OpenTelemetry Logs Data Model](https://opentelemetry.io/docs/specs/otel/logs/data-model/) and [Resource Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/resource/) — event/observed time, trace context and resource identity.
- [SciPy median absolute deviation](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.median_abs_deviation.html) — robust dispersion definition and behavior.
- [scikit-learn outlier and novelty detection](https://scikit-learn.org/stable/modules/outlier_detection.html) and [model evaluation](https://scikit-learn.org/stable/modules/model_evaluation.html) — algorithm settings, assumptions and classification metrics.
- [Robust Random Cut Forest](https://proceedings.mlr.press/v48/guha16.html) — primary streaming anomaly-detection research.
- [Towards a Rigorous Evaluation of Time-series Anomaly Detection](https://arxiv.org/abs/2109.05257) — evidence against score-inflating evaluation shortcuts.
- [Drain log parsing](https://pinjiahe.github.io/publication/2017-ICWS) — primary-author streaming log-template research.
- [A Unified Approach to Interpreting Model Predictions](https://papers.neurips.cc/paper_files/paper/2017/hash/8a20a8621978632d76c43dfd28b67767-Abstract.html) — feature-attribution foundations and their proper model-level scope.
- [Time series cross-validation](https://otexts.com/fpp3/tscv.html) — rolling-origin forecast evaluation.
- [Google SRE: The Evolution of Automation](https://sre.google/sre-book/automation-at-google/) — production automation as engineered control software.

Algorithms, product interfaces and defaults remain version-dependent. Research results and vendor scores are not universal operational guarantees. The offline model proves only deterministic evidence ordering. Publication requires technical, instructional, security and source review; mastery requires representative runtime, independent transfer and delayed recall.
