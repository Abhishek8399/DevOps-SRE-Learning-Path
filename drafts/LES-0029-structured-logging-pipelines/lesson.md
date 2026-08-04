---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0029",
  "slug": "structured-logging-pipelines",
  "aliases": ["V04-L04", "structured-logging-pipelines"],
  "curriculumIds": ["OBS-004"],
  "route": "/book/reliability/structured-logging-pipelines",
  "order": 4,
  "volume": "04-reliability-operations",
  "title": "Structured logging pipelines: preserve events from source to decision",
  "summary": "Learn how an application event becomes a searchable record across loggers, stdout or files, journals, collectors, queues, parsers, indexes, queries, dashboards, and alerts; diagnose missing, late, duplicated, malformed, or sensitive logs from boundary evidence instead of trusting one search result.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0026", "LES-0008", "LES-0021"],
  "prerequisiteCurriculumIds": ["OBS-001", "DBG-001", "API-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The bounded teaching model requires only Bash and Python 3. Read-only journal commands require a systemd journal and the caller's existing permissions. A passing model does not prove journald, syslog, OpenTelemetry, Elastic, Splunk, or another logging runtime."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The deterministic lab is designed for WSL. A WSL distribution may not expose the same boot journal, services, cgroups, persistence, or permissions as a native Ubuntu host."
    },
    {
      "platform": "OpenTelemetry Logs",
      "version": "current official specification reviewed 2026-08-04; exact SDK and Collector artifacts pending",
      "support": "concept-only",
      "notes": "The lesson uses the stable log data model and current logging specification conceptually. No SDK, Collector, OTLP, processor, exporter, or backend execution is claimed."
    },
    {
      "platform": "Elastic and Splunk",
      "version": "current official documentation reviewed 2026-08-04; no local product stack",
      "support": "concept-only",
      "notes": "Vendor sections explain common pipeline ownership and troubleshooting concepts. Exact versions, licensing, configuration, query syntax, capacity, security, and behavior require separately reviewed runtime evidence."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "observability-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "security-engineer",
    "software-engineer-on-call",
    "technical-lead"
  ],
  "learningObjectives": [
    "Explain the complete path from application event construction through logger, local destination, collector, buffer, transport, parser, index, query, dashboard or alert, and operator decision.",
    "Distinguish an event, log record, physical line, logical event, field, schema, serialized bytes, resource identity, event identity, correlation identity, severity, outcome, and error without using the terms interchangeably.",
    "Design a versioned structured-event envelope with explicit field names, types, units, clocks, compatibility, missing-data behavior, ownership, and sensitive-data policy.",
    "Use source, receive, accepted, rejected, queued, dropped, retried, duplicated, indexed, searchable, and oldest-age evidence to locate the earliest failing logging boundary.",
    "Diagnose multiline framing, parser drift, mapping conflicts, duplicate logger propagation, at-least-once replay, queue backpressure, clock skew, late arrival, rotation, truncation, and missing query populations.",
    "Separate event time, observed time, ingest time, index time, and query evaluation time and use them to reason about freshness without sorting away evidence.",
    "Apply data minimization, redaction, injection resistance, least privilege, integrity, access auditing, retention, and deletion controls before logs become a second sensitive database.",
    "Estimate events per second, encoded bytes, queue capacity, recovery drain rate, storage copies, retention, and search cost while labeling assumptions and uncertainty.",
    "Compare journald, syslog, OpenTelemetry, Elastic, and Splunk mechanisms by pipeline boundary and state ownership instead of memorizing product screens.",
    "Plan a safe logging change with contract tests, known-input replay, canarying, coverage and freshness abort limits, reversible rollback, and separate user and monitoring recovery proof."
  ],
  "productionSignals": [
    "application events attempted, handler successes and failures, logger level/filter decisions, blocked writers, output bytes, and process restarts",
    "file or journal bytes, entry count, rotation, truncation, cursor, disk usage, rate limits, permissions, vacuum events, and boot identity",
    "collector discovered sources, received records and bytes, parse/framing errors, retry count, queue depth, queue capacity, oldest age, spill bytes, drops, and restarts",
    "transport sends, acknowledgements, timeouts, reconnects, compression ratio, rejected batches, duplicate deliveries, and destination throttling",
    "parser accepted, rejected, transformed, redacted, routed, dead-lettered, and quarantined records by schema version and failure reason",
    "index write attempts, mapping conflicts, document rejections, indexing latency, shard or bucket pressure, stored bytes, replicas, rollover, and lifecycle actions",
    "query success, latency, scanned bytes or events, result count, time range, index scope, field extraction failures, no-data state, and late-arrival behavior",
    "event time, observed time, ingest time, index time, query time, end-to-end freshness, clock offset, and oldest unprocessed event",
    "sensitive-field detections, redactions, access denials, privileged searches, export actions, retention exceptions, integrity checks, and deletion proof",
    "application, schema, parser, collector, routing, index template, retention, dashboard, alert, access-policy, and deployment change events"
  ],
  "diagrams": [
    {
      "id": "LES-0029-DIA-001",
      "title": "Event-to-decision logging path",
      "direction": "left-to-right",
      "boundaries": ["application event", "logger and handler", "stdout file or journal", "collector or forwarder", "buffer and transport", "framing parser and transform", "index and retention", "query dashboard or alert", "operator decision"],
      "evidencePoints": ["attempted event", "handler result", "local entry", "received record", "queue count and age", "accepted or rejected event", "indexed document", "query result and freshness", "verified user outcome"],
      "textAlternative": "Application code constructs an event and submits it to a logger. Filters, handlers and formatters send bytes to stdout, a file, a journal or another destination. A collector reads and buffers those bytes, transports them, frames logical events, parses and transforms fields, and sends accepted records to indexed storage. Queries feed dashboards and alerts. Every arrow can lose, delay, duplicate, reject, mutate or expose data, and the operator still needs independent user evidence before acting."
    },
    {
      "id": "LES-0029-DIA-002",
      "title": "One record and its identities",
      "direction": "hierarchical",
      "boundaries": ["event contract", "resource identity", "event class", "event occurrence", "correlation context", "body and attributes", "clocks", "severity and outcome"],
      "evidencePoints": ["schema version", "service and environment", "event name", "event ID", "trace or operation ID", "typed fields and units", "event and observed time", "declared result"],
      "textAlternative": "A record belongs to a versioned event contract. Resource fields identify the emitting service and environment. Event name identifies the class of occurrence, while an optional event ID identifies one occurrence for replay or deduplication. Trace or operation context correlates related work. Typed attributes and units carry details. Event and observed timestamps describe different clocks. Severity describes attention, while outcome describes what happened to the operation."
    },
    {
      "id": "LES-0029-DIA-003",
      "title": "Count conservation and freshness",
      "direction": "left-to-right",
      "boundaries": ["produced", "received", "queued", "accepted", "rejected", "indexed", "searchable"],
      "evidencePoints": ["counter scope and reset", "bytes and records", "queue capacity", "drop and retry", "rejection reason", "write acknowledgement", "result count", "oldest age and event-to-search delay"],
      "textAlternative": "Compare counts over the same window and scope from produced through received, queued, accepted, rejected, indexed and searchable. A difference needs an explicit bucket such as still queued, rejected, dropped or duplicated. Counts alone do not show timeliness, so carry oldest queue age and event-to-search delay beside them."
    },
    {
      "id": "LES-0029-DIA-004",
      "title": "Schema-change compatibility path",
      "direction": "top-to-bottom",
      "boundaries": ["producer version", "serialized record", "collector preservation", "parser version", "mapping or index template", "query assumptions", "dashboard meaning"],
      "evidencePoints": ["desired and running version", "raw bounded sample", "byte-preservation check", "known-input test", "mapping rejection", "field existence and type", "no-data branch"],
      "textAlternative": "A producer version chooses names, types and units, then serializes a record. A collector must preserve or deliberately transform it. A parser version interprets it, a mapping constrains stored types, queries assume fields and populations, and dashboards assign meaning. A compatible rollout proves each consumer before increasing producer exposure and retains a rollback path that understands both old and new records."
    },
    {
      "id": "LES-0029-DIA-005",
      "title": "Security retention and access boundary",
      "direction": "hierarchical",
      "boundaries": ["data minimization", "untrusted-value sanitation", "transport protection", "buffer and dead letter", "indexed storage", "search and export", "retention and deletion", "audit and incident response"],
      "evidencePoints": ["allowlist", "injection test", "encryption and identity", "capacity and access", "field protection", "query audit", "expiry proof", "exposure assessment"],
      "textAlternative": "Minimize fields before emission and sanitize untrusted values before they can forge event boundaries or fields. Protect transport identity and confidentiality. Bound and restrict buffers and rejected-event stores. Apply field and index access controls, audit searches and exports, enforce justified retention, and prove deletion. If sensitive data enters the path, stop new exposure and follow incident policy rather than merely hiding a dashboard field."
    }
  ],
  "commands": [
    {
      "id": "LES-0029-CMD-001",
      "question": "Which user, kernel, Ubuntu release, systemd version, Python version, and current directory define this investigation?",
      "risk": "read-only",
      "command": "id; uname -a; cat /etc/os-release; systemctl --version; python3 --version; pwd",
      "runFrom": "a normal Ubuntu shell before touching the lab or system logs",
      "expectedBranches": [
        {"when": "the caller is non-root and versions/path match the approved environment", "meaning": "the environment boundary is recorded", "nextEvidence": "record journal visibility and the exact target scope"},
        {"when": "the caller is root, the distribution differs, systemd is unavailable, or the path is unexpected", "meaning": "later behavior may differ or the safety boundary is wrong", "nextEvidence": "stop mutating work and correct the environment contract"}
      ],
      "proves": "only the local caller and reported software/environment identity",
      "doesNotProve": "journal persistence, log permissions, collector presence, pipeline health, or production equivalence"
    },
    {
      "id": "LES-0029-CMD-002",
      "question": "Which boots are visible to this caller, and is the incident being searched in the correct boot?",
      "risk": "read-only",
      "command": "journalctl --list-boots --no-pager",
      "runFrom": "an Ubuntu host or WSL distribution with systemd-journald and the caller's existing permissions",
      "expectedBranches": [
        {"when": "one or more boots appear", "meaning": "the caller can enumerate those journal boot ranges", "nextEvidence": "select the exact boot and time range rather than searching all history"},
        {"when": "no boots appear or permission is denied", "meaning": "the expected journal data is absent, volatile, unavailable, or unauthorized", "nextEvidence": "inspect systemd/journal availability and access policy without escalating automatically"}
      ],
      "proves": "the boot ranges visible through this journal view",
      "doesNotProve": "that every application used the journal, that old boots were retained, or that the caller sees privileged fields"
    },
    {
      "id": "LES-0029-CMD-003",
      "question": "What exact records for one local service are visible in a bounded time window, including structured fields?",
      "risk": "sampled-read-only",
      "command": "journalctl --unit=ssh.service --since '-15 min' --output=json --no-pager --lines=20",
      "runFrom": "the approved local Ubuntu host; replace the unit only with an authorized non-sensitive local service",
      "expectedBranches": [
        {"when": "JSON records appear", "meaning": "the journal returned up to twenty entries in the selected unit/time scope", "nextEvidence": "inspect field ownership, timestamps and cursor without copying sensitive values"},
        {"when": "no entries appear", "meaning": "there may be no matching events, a wrong unit/boot/window, missing journal path, or insufficient access", "nextEvidence": "check unit identity, boot and permissions; do not convert no data to zero events"},
        {"when": "the unit is absent", "meaning": "the example service does not exist in this environment", "nextEvidence": "select an explicitly approved local unit or skip the optional journal sample"}
      ],
      "proves": "only the bounded records returned to this caller for that unit and window",
      "doesNotProve": "complete service behavior, user impact, pipeline delivery beyond the journal, or absence outside the query scope"
    },
    {
      "id": "LES-0029-CMD-004",
      "question": "How much disk space does the visible journal report using?",
      "risk": "read-only",
      "command": "journalctl --disk-usage",
      "runFrom": "the approved local Ubuntu environment",
      "expectedBranches": [
        {"when": "an archived and active journal size is reported", "meaning": "journald calculated its current visible disk usage", "nextEvidence": "compare it with configured persistence, limits, filesystem headroom and retention needs"},
        {"when": "the command fails or reports no journal", "meaning": "journald, storage or permissions differ from the assumed environment", "nextEvidence": "inspect the environment contract rather than vacuuming or deleting files"}
      ],
      "proves": "journald's reported current disk usage",
      "doesNotProve": "filesystem free blocks/inodes, future growth, retained event coverage, collector storage, Elastic/Splunk capacity, or safe deletion choices"
    },
    {
      "id": "LES-0029-CMD-005",
      "question": "Are the bounded lab prerequisites, identity, fixture, and state path safe before mutation?",
      "risk": "read-only",
      "command": "bash lab.sh doctor",
      "runFrom": "drafts/LES-0029-structured-logging-pipelines/support/lab as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "doctor reports ready=true", "meaning": "the deterministic model prerequisites and current state identity passed", "nextEvidence": "run setup"},
        {"when": "doctor refuses root, a missing tool, invalid fixture, symlink, unexpected child, or foreign state", "meaning": "the wrapper cannot prove its safety contract", "nextEvidence": "preserve the refusal and correct only the named boundary"}
      ],
      "proves": "only the wrapper's local prerequisite and path checks",
      "doesNotProve": "systemd, syslog, OpenTelemetry, Elastic, Splunk, network transport, or production behavior"
    },
    {
      "id": "LES-0029-CMD-006",
      "question": "Can the lab create an owned bounded copy of the structured-log fixture?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "the LES-0029 lab directory after doctor passes",
      "expectedBranches": [
        {"when": "setup reports state=ready", "meaning": "the exact UID-owned fixture state validated", "nextEvidence": "record status before running cases"},
        {"when": "setup refuses ambiguous or concurrently created state", "meaning": "ownership or lifecycle safety is not established", "nextEvidence": "inspect and preserve the named state; do not force recursive deletion"}
      ],
      "proves": "the declared local teaching state was created or revalidated",
      "doesNotProve": "that a real application emitted logs or any collector/backend accepted them",
      "cleanup": "Run bash lab.sh cleanup; it validates the exact state descriptor and proves the path absent."
    },
    {
      "id": "LES-0029-CMD-007",
      "question": "What fixture identity and result count exist before the next case?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the LES-0029 lab directory",
      "expectedBranches": [
        {"when": "status reports state=ready and a bounded result count", "meaning": "the state descriptor and all current children validate", "nextEvidence": "run one declared case"},
        {"when": "status reports absent", "meaning": "no owned state exists", "nextEvidence": "run doctor and setup"},
        {"when": "status refuses", "meaning": "the wrapper found ambiguous or unexpected state", "nextEvidence": "preserve and inspect; do not bypass validation"}
      ],
      "proves": "the model's validated state identity and result-file count",
      "doesNotProve": "application, transport, parser, storage or query health"
    },
    {
      "id": "LES-0029-CMD-008",
      "question": "What fields, trace groupings, severities, and observation delay exist in the known-good fixture?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run baseline",
      "runFrom": "the LES-0029 lab directory after setup",
      "expectedBranches": [
        {"when": "eight records and two four-record trace groups appear", "meaning": "the checked-in baseline matches its declared event population", "nextEvidence": "compare fault cases against the same contract"},
        {"when": "validation or count fails", "meaning": "fixture, state or model differs from the reviewed case", "nextEvidence": "stop and inspect the first refusal"}
      ],
      "proves": "only deterministic grouping and delay arithmetic for eight fixture records",
      "doesNotProve": "live trace correlation, business correctness, delivery completeness, or backend search",
      "cleanup": "Run bash lab.sh cleanup after the guided sequence or rerun setup to keep a restartable state."
    },
    {
      "id": "LES-0029-CMD-009",
      "question": "Which fixture records fail the declared required-field and integer-type parser contract?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run parser-drift",
      "runFrom": "the LES-0029 lab directory after setup",
      "expectedBranches": [
        {"when": "four accepted and two rejected records appear with named reasons", "meaning": "the model located one string type and one missing field", "nextEvidence": "trace how a real system exposes rejected counts and bounded samples"},
        {"when": "a different result or refusal appears", "meaning": "the fixture/schema/model contract changed", "nextEvidence": "review the exact record and do not broaden coercion to force a pass"}
      ],
      "proves": "required-field and integer-type checks in the teaching model",
      "doesNotProve": "Elastic mapping, Splunk parsing, OpenTelemetry processing, or a production schema",
      "cleanup": "Run bash lab.sh cleanup after the guided sequence."
    },
    {
      "id": "LES-0029-CMD-010",
      "question": "Do produced, consumed, queued, and dropped fixture counts conserve, and what loss fraction follows?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run backpressure",
      "runFrom": "the LES-0029 lab directory after setup",
      "expectedBranches": [
        {"when": "40 equals 25 plus 10 plus 5 and lossFraction is 0.125", "meaning": "the declared count ledger conserves and five of forty records were dropped", "nextEvidence": "design real queue depth, oldest age, drop and recovery-rate evidence"},
        {"when": "conservation fails", "meaning": "a population is missing, duplicated or scoped differently", "nextEvidence": "do not calculate a trustworthy loss percentage until scopes reconcile"}
      ],
      "proves": "arithmetic conservation in one declarative fixture",
      "doesNotProve": "real concurrency, queue scheduling, disk durability, retry semantics or recovery throughput",
      "cleanup": "Run bash lab.sh cleanup after the guided sequence."
    },
    {
      "id": "LES-0029-CMD-011",
      "question": "Does the complete deterministic case and refusal matrix pass and leave no declared state?",
      "risk": "mutating-bounded",
      "command": "bash verify.sh",
      "runFrom": "the LES-0029 lab directory as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "verification=passed and final_state=absent appear", "meaning": "all eight model cases, declared assertions, refusals and exact cleanup passed in this environment", "nextEvidence": "keep the result limited to the deterministic model"},
        {"when": "the verifier exits non-zero", "meaning": "the first failed syntax, model, safety or cleanup assertion is evidence", "nextEvidence": "inspect that boundary; the exit handler reports cleanup failure rather than hiding it"}
      ],
      "proves": "the declared local model and wrapper lifecycle when actually run on the required environment",
      "doesNotProve": "journald, syslog, OTel, Elastic, Splunk, provider, production, learner or mastery behavior",
      "cleanup": "The verifier performs validated cleanup and proves exact final absence; if cleanup is refused, preserve the named state for inspection."
    },
    {
      "id": "LES-0029-CMD-012",
      "question": "Can the wrapper remove only its exact validated state and prove it absent?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh cleanup",
      "runFrom": "the LES-0029 lab directory",
      "expectedBranches": [
        {"when": "cleanup=passed state=absent appears", "meaning": "the exact owned lab path is absent", "nextEvidence": "none for lab cleanup"},
        {"when": "cleanup refuses owner, path, sentinel, manifest, type, child or symlink", "meaning": "the state no longer matches the removal authorization", "nextEvidence": "preserve it and inspect the named mismatch; never replace the guard with a broad delete"}
      ],
      "proves": "absence of only the declared lab state path",
      "doesNotProve": "absence of unrelated temporary files, system logs, vendor resources or learner-created independent-case resources",
      "cleanup": "This command is the cleanup operation; a refusal intentionally leaves ambiguous state untouched."
    }
  ],
  "labs": [
    {
      "id": "LES-0029-LAB-001",
      "title": "Guided structured-log pipeline reasoning model",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS normal user with Bash and Python 3; no Docker, network, ports, sudo, package installation, journald mutation, or vendor service",
      "timeMinutes": 105,
      "privilege": "normal user; wrapper and verifier refuse UID 0",
      "network": "none; all fixtures and calculations are local",
      "changes": ["one lesson-specific temporary directory", "owned fixture copies", "bounded JSON result files"],
      "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "a child is a symlink or unexpected type", "fixture schema is invalid", "a result exceeds the declared bound", "cleanup cannot validate exact ownership"],
      "recovery": "Run status. If the complete descriptor validates, run cleanup and repeat setup. Preserve refused foreign or ambiguous state for review rather than deleting it broadly.",
      "cleanupProof": "Cleanup validates exact parent, basename, real path, UID, sentinel, manifest, scenario, allowed children, types, owner and size, removes only that directory, and proves exact absence.",
      "path": "drafts/LES-0029-structured-logging-pipelines/support/lab"
    },
    {
      "id": "LES-0029-LAB-002",
      "title": "Independent log-loss and sensitive-data incident",
      "mode": "independent",
      "environment": "An instructor-provided or learner-created unseen disposable local case with materially changed framing, schema, queue, timestamp, privacy and query behavior; the guided fixture cannot satisfy independence",
      "timeMinutes": 90,
      "privilege": "normal user; no elevated operation",
      "network": "none unless the separately authorized unseen local case explicitly declares otherwise; shared, production, employer and online cloud systems are prohibited",
      "changes": ["one learner-owned sanitized response outside guarded LES-0029 state", "only resources declared by the unseen disposable case"],
      "abortConditions": ["reviewer-only answer material becomes visible", "authorization or sanitization is unclear", "state validation fails", "the learner proposes destructive shared-system action", "the evidence cannot discriminate the hypothesis"],
      "recovery": "Return to baseline evidence, narrow the hypothesis and submit a revision. Never reveal answered material before independent review.",
      "cleanupProof": "Use the unseen case's own manifest to prove every created process, port, file, queue, container, network or resource absent. Guided lab cleanup does not cover the independent response or unseen case.",
      "path": "drafts/LES-0029-structured-logging-pipelines/support/lab"
    }
  ],
  "incidents": [
    {
      "id": "LES-0029-INC-001",
      "signal": "Search results lose checkout completions after a release while application request metrics remain stable.",
      "firstThought": "A missing search result can mean no event, delayed event, rejected event, wrong scope, or broken query. Walk source-to-search counts and ages before blaming the application.",
      "safePath": "Fix user impact and time scope, compare source attempt, local write, collector receive, queue, parser accept/reject, index write and search counts, inspect a sanitized rejected sample, then contain the earliest incompatible boundary with rollback or version routing.",
      "trap": "Changing the dashboard to replace no data with zero makes the monitoring failure look like service recovery."
    },
    {
      "id": "LES-0029-INC-002",
      "signal": "One Python event appears twice after a logging configuration change.",
      "firstThought": "Duplicate display can come from two handlers, ancestor propagation, collector replay, transport retry, index replay, or query expansion; event identity and boundary counts locate which one.",
      "safePath": "Inspect logger handlers and propagate settings, attach a controlled event ID, compare local bytes, collector receipt, transport attempts, index documents and query grouping, then remove only the duplicate path and verify no loss.",
      "trap": "Deduplicating every search result by message text hides legitimate repeated events and leaves the duplicate producer active."
    },
    {
      "id": "LES-0029-INC-003",
      "signal": "Collector queue age and disk use grow during a backend slowdown, but no drop alert fires.",
      "firstThought": "No drop yet is not healthy. An oldest-age increase means evidence is becoming stale, and a full queue may change the pipeline from delayed to dropped or blocked.",
      "safePath": "Confirm user-service health, input and drain rates, queue capacity and oldest age, disk blocks and inodes, retry/backoff, downstream limits and recovery drain margin; reduce nonessential load or restore destination capacity within an approved reversible plan.",
      "trap": "Increasing the queue without a drain and retention calculation postpones the failure and can exhaust the host."
    },
    {
      "id": "LES-0029-INC-004",
      "signal": "A diagnostic search reveals authorization material and user contact fields in retained logs.",
      "firstThought": "This is a data-exposure and logging-design incident, not merely a dashboard formatting problem. Stop new sensitive emission while preserving only sanitized evidence.",
      "safePath": "Restrict access and exports, stop or roll back the offending field path, preserve sanitized metadata, identify stores/queues/dead letters/exports and access logs, involve security/privacy owners, rotate credentials when required, apply approved deletion or retention actions, and verify prevention tests.",
      "trap": "Hiding the field in the UI does not remove it from transport, buffers, indexes, replicas, snapshots or prior exports."
    }
  ],
  "assessmentIds": ["ASM-0070", "ASM-0071", "ASM-0072"],
  "referenceIds": ["REF-0199", "REF-0200", "REF-0201", "REF-0202", "REF-0203", "REF-0204", "REF-0205", "REF-0206", "REF-0207", "REF-0208", "REF-0209", "REF-0210", "REF-0211", "REF-0212", "REF-0213"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "This package is quarantined and is not loaded by the website or canonical registry.",
    "The Python fixture is a deterministic teaching model, not a logging framework, parser product, queue, journal, collector, index, query engine or representative service.",
    "No systemd journal lifecycle, syslog transport, OpenTelemetry SDK or Collector, Fluent Bit, Logstash, Elastic, Kibana, Splunk or cloud logging runtime has been executed for this lesson.",
    "Capacity calculations are declared arithmetic assumptions and cannot size a real product without measured workload, compression, indexing, replication, query and failure tests.",
    "Vendor behavior, licensing, security, versions and configuration remain subject to exact artifact and official-document review before promotion.",
    "No learner execution, independent reviewer decision, delayed recall, production transfer, formal acceptance or mastery evidence exists."
  ]
}
---

# Structured logging pipelines: preserve events from source to decision

## What you see and first thought

Imagine this incident: checkout metrics say 12,000 attempts per minute. The application says it emitted 12,000 completion records. The log collector says it received 12,000 records. Search returns only 8,000. The dashboard shows zero checkout errors and turns green.

The beginner's first thought is often, “The application stopped logging,” or “The search tool is broken.” A senior operator slows down and asks a sharper question:

> At which exact boundary does the expected event population first become smaller, later, duplicated, malformed, inaccessible, or differently defined?

That question is the heart of this chapter. A log is not born inside a search box. An application creates an event, a logging library decides whether and how to emit it, an operating-system or file destination owns bytes, a collector discovers and reads those bytes, a buffer holds them, a transport moves them, a parser decides event boundaries and fields, a storage engine indexes accepted records, a query selects a population, and a dashboard gives the result a visual meaning.

```text
user operation
      |
      v
application event -> logger -> local destination -> collector -> queue
                                                           |
                                                           v
operator decision <- dashboard/alert <- query <- index <- parser
```

When you see “no logs,” do not translate it into “nothing happened.” Translate it into a list of competing states:

- the event never occurred;
- it occurred but code never attempted a log record;
- the logger filtered it;
- a handler failed or blocked;
- the local file, stdout pipe, socket or journal never retained it;
- the collector did not discover or read it;
- the record is still queued;
- transport retried or duplicated it;
- framing split one event into several lines or merged several events;
- parsing rejected it;
- a transformation dropped or misrouted it;
- indexing rejected or delayed it;
- the query searched the wrong time, index, tenant, field or value type;
- the dashboard converted missing into zero;
- access control hid it from this caller.

That list is not pessimism. It is an evidence map. Your job is to remove possibilities using the cheapest safe discriminating observation.

A memorable rule is:

> A search result is the last page of a delivery story. Debug the story from the first missing page, not from the prettiest page.

This chapter teaches both sides of logging. The first side is reliability: completeness, timeliness, duplication, backpressure, retention and query correctness. The second side is security: logs can expose secrets, accept hostile text, be tampered with, consume disk, and become a privileged shadow database. A system is not “observable” if its logs are complete but unsafe, or safe but silently incomplete.

## Terms before commands

### Event, record, line and message

An **event** is a meaningful occurrence: “checkout completed,” “configuration reloaded,” or “authentication failed.” It exists in the domain whether or not anyone logs it.

A **log record** is a representation of an event prepared for a logging system. One event might intentionally create several records for different audiences, or no record if policy excludes it. Therefore event count and log-record count are not automatically equal.

A **physical line** is a sequence of bytes terminated by a line boundary in a stream or file. It is a transport/framing fact, not necessarily an event. A Python traceback can be one logical event printed as four physical lines. A JSON record is normally kept on one line in line-delimited streams so a collector can frame it reliably, but JSON itself does not define a multi-document stream protocol.

The **message** or **body** is the human-readable or structured payload describing the occurrence. It is not the whole record. Resource identity, timestamps, severity, trace context and typed attributes may sit beside it.

If a tool says “five lines,” ask whether it means five physical lines, five logical events, five parsed records, or five search results. Those are different populations.

### Field, type, unit, schema and version

A **field** is a named value such as `duration_ms: 420`. The name alone is incomplete. Its contract includes:

- meaning: end-to-end checkout duration or only payment duration?
- type: integer, floating point, string, boolean, array or object?
- unit: milliseconds, seconds or nanoseconds?
- required/optional status;
- allowed value domain;
- privacy classification;
- source and owner;
- behavior when unknown;
- compatibility rules.

A **schema** is the shared contract for a record class. It prevents one producer from calling a string `duration_ms` while a parser and query assume an integer. Structured logging without schema ownership becomes “JSON-shaped ambiguity.” The syntax parses, but teams still disagree about meaning.

A **schema version** identifies a compatibility contract. It should not be used as an excuse to break every consumer simultaneously. A safe evolution states whether readers accept old and new records, whether fields are additive, renamed or retyped, how long compatibility lasts, and how rollback behaves.

### Structured and unstructured logs

An **unstructured log** usually places most meaning in free text:

```text
checkout failed for order reference X after 4200 ms
```

A **structured record** gives important values stable names and types:

```json
{
  "event_name": "checkout.completed",
  "outcome": "failure",
  "duration_ms": 4200,
  "order_reference": "pseudonymized-value"
}
```

Structured does not automatically mean safe or correct. A JSON object can leak credentials, use unstable fields, carry wrong units, omit a required timestamp, or change types without notice. The advantage is that explicit fields can be validated, queried, governed and evolved deliberately.

### Serialization and framing

**Serialization** converts an in-memory record into bytes such as JSON, RFC 5424 syslog or a protocol message. **Deserialization** reconstructs a data structure from bytes.

**Framing** answers where one logical record ends and the next begins. Newline-delimited JSON uses a newline as the frame delimiter and therefore requires embedded newlines to be escaped inside the JSON string. Syslog has its own message structure plus separate transport mappings. A stream of pretty-printed JSON objects without an outer array or frame is ambiguous.

**Multiline handling** groups continuation lines, often stack traces, with their starting record. A weak rule such as “every line beginning with a date starts a new event” can break when application messages begin with date-like text or when clocks/formats change. Test start, continuation, truncation, very long event and hostile-input cases.

### Logger, handler, formatter and filter

A **logger** is the interface application code calls. In Python, loggers form a name hierarchy. A record can propagate to ancestor handlers.

A **handler** or **appender** sends accepted records to a destination. There may be a console handler, file handler, socket handler or queue handler.

A **formatter** converts the record into output bytes. A formatter failure can mean the application successfully created a record but emitted nothing useful.

A **filter** or level threshold decides which records continue. Logger and handler thresholds are separate. Duplicate handlers or propagation can duplicate output. A raised level can make records disappear even though application code still calls the logger.

### Local destination: stdout, stderr, file, journal and syslog

**stdout** and **stderr** are process byte streams. In containers they are often captured by the runtime, but that does not mean every byte reached durable storage. Blocking pipes can affect the process; nonblocking paths may drop.

A **log file** has an inode, pathname, ownership, permissions, offset, rotation and deletion lifecycle. A collector may track a file by inode plus offset. Renaming, copy-truncate rotation, rapid recreation, truncation and filesystem exhaustion affect what it reads. “The path exists” does not prove the collector follows the intended file object.

The **systemd journal** stores entries with structured fields and adds trusted metadata such as process and unit identity. Fields beginning with an underscore are generally trusted metadata added by the journal rather than arbitrary application claims. Journal visibility depends on boot, persistence, permissions, rate limits and storage policy. `journalctl` is a query client; it is not the producer or durable remote archive.

**Syslog** is a message format and family of transport conventions. RFC 5424 defines header and structured-data concepts, but format does not guarantee encryption, delivery, ordering, durable acknowledgement or sender identity. Always separate message semantics from transport semantics.

### Collector, agent, forwarder and shipper

These names describe a component that reads events and sends them onward. It may:

- discover files, sockets, journals, container streams or APIs;
- remember cursors or offsets;
- frame multiline events;
- parse and transform fields;
- add resource identity;
- buffer, batch, compress and retry;
- route by tenant, dataset or severity;
- redact or drop records;
- export to one or several destinations.

Because it owns so many decisions, “collector healthy” is too vague. Ask which receiver, processor, queue and exporter, with what accepted/rejected/dropped counts and oldest age.

### Buffer, queue, spool, backpressure and oldest age

A **buffer** temporarily holds records when adjacent stages run at different speeds. An in-memory queue is fast but may disappear on process loss. A disk spool can survive more failures but consumes filesystem capacity and needs integrity, ownership and cleanup controls.

**Backpressure** is how downstream slowness influences upstream work. A pipeline can block producers, buffer, spill to disk, sample, shed lower-value events, reject, or drop. Every policy trades application impact, evidence completeness, cost and recovery complexity.

**Queue depth** is how many records or bytes wait. **Oldest age** is how long the oldest waiting record has been delayed. Depth without rate and age can mislead: a large fast-moving queue may be acceptable; a small queue holding a critical event for thirty minutes may not be.

### Parse, transform, enrich, redact, route and index

**Parsing** converts framed bytes into fields. A parse success means the parser produced a record, not that field meanings are correct.

A **transform** changes fields or values. **Enrichment** adds context such as service, environment or region. **Redaction** removes or irreversibly masks prohibited data. **Routing** chooses a destination or dataset. Each is a mutation boundary that needs version, metrics, test input and failure behavior.

**Indexing** writes accepted records into structures optimized for later search. A storage engine may reject a record because a field type conflicts with an existing mapping, because authorization fails, because capacity is exhausted, or because an index or stream is read-only. “Sent successfully” from the collector may mean only that a network call returned, not that the event is searchable under the intended contract.

In Splunk terminology, input, parsing, indexing and search are distinct phases, and configuration belongs where its phase executes. In Elastic, ingest pipelines can transform documents before indexing, mappings constrain types, and data streams organize append-oriented time series across backing indices. The products differ, but the systems question is the same: which component owns this decision and what evidence does it expose?

### Event time, observed time, ingest time, index time and query time

**Event time** is when the source says the occurrence happened.

**Observed time** is when a collection component first observed it. OpenTelemetry's log data model keeps these concepts separate.

**Ingest time** is when a pipeline accepted or processed it. **Index time** is when storage made it part of an index or searchable structure. **Query evaluation time** is when a search interprets its time range.

The differences answer different questions:

```text
source-to-observer delay = observed_time - event_time
pipeline delay           = index_time - observed_time
end-to-search freshness  = searchable_time - event_time
```

A negative delay does not mean time travel. It suggests clock offset, timestamp parsing, timezone, unit or field-mapping error. A large positive delay may mean queueing, retransmission, offline sources, slow parsing or late replay.

### Severity, outcome and alert importance

**Severity** communicates how serious the emitter considers the record. **Outcome** states what happened to the operation: success, failure, timeout, cancelled or unknown. They are related but not identical.

An expected authentication denial may be `INFO` with outcome `failure`; it is not an application failure. A corrupted invariant may be `ERROR` even if a fallback returns success to the user. Do not calculate failure rate from severity unless that is the explicit contract.

Severity names vary. Preserve the original text when needed, normalize to a documented numeric or common scale for cross-source comparison, and never silently reinterpret a vendor's priority as your application's business outcome.

### Resource, event and correlation identity

**Resource identity** describes the entity that emitted the record: service, environment, cluster, host, process or workload. Stable fields belong here; request-specific values do not.

An **event name** identifies the record class such as `checkout.completed`. An **event ID** can identify one occurrence for deduplication or replay, but only if it is stable across retry and the destination enforces or queries that identity correctly.

A **correlation ID**, trace ID, span ID or operation ID connects related records. It is not automatically unique, secret-safe or proof of causality. Validate format, propagation, tenancy and cardinality; never put raw credentials or unrestricted user input into identity fields.

### Delivery semantics and duplicates

**At-most-once** delivery can lose a record and avoids transport retry duplication.

**At-least-once** delivery retries and can deliver the same record more than once.

**Exactly-once** is an end-to-end claim involving producer identity, transport, storage commit, replay and consumer behavior. A persistent queue or unique ID alone does not prove it. Most logging systems should be designed to tolerate duplicates and to measure them rather than promise impossible perfection.

### Missing, zero, rejected, dropped, late and duplicated

These states must remain separate:

- **zero**: a measured population exists and its numeric value is zero;
- **missing**: the expected series, field, index or result is absent;
- **rejected**: a component explicitly refused a record;
- **dropped**: a component intentionally or accidentally discarded it;
- **queued**: it has not reached the later boundary yet;
- **late**: it arrives outside the expected freshness window;
- **duplicated**: one event occurrence appears multiple times;
- **filtered**: policy intentionally excludes it;
- **unauthorized**: it may exist but this caller cannot see it.

Converting every state to zero erases the evidence you need to distinguish healthy silence from a blind monitoring system.

### Coverage, freshness and correctness

**Coverage** asks what fraction of the expected event population reached a declared boundary:

```text
accepted coverage = accepted records / expected source population
```

The numerator and denominator need the same operation, source set, time window, schema and duplicate policy. Coverage above 100 percent can reveal duplicates or mismatched counters.

**Freshness** asks how delayed evidence is. Use percentiles and oldest age, not only average delay.

**Correctness** asks whether event boundaries, fields, types, units, identity and meaning survived. A pipeline can have 100 percent count coverage and still turn milliseconds into seconds or merge two stack traces incorrectly.

### Retention, tiers and deletion

**Retention** is how long data remains. It must balance incident investigation, reliability, legal, privacy, security and cost requirements. “Keep everything” is not a safe default.

Hot, warm, cold and archive tiers describe different search latency and cost tradeoffs. Replicas improve availability but multiply stored bytes. Snapshots and exports extend the data lifetime beyond the primary index. A deletion claim must cover all authorized copies or state its limits.

## Architecture map

### Diagram 1: event to operator decision

```text
application code
  event contract + context
          |
          v
logger -> filter -> handler -> formatter
          |            |
          |            +--> handler error / block / duplicate
          v
stdout | stderr | file | journal | socket
          |
          v
collector receiver -> memory/disk queue -> exporter/transport
          |                    |
          |                    +--> retry / duplicate / drop / stale age
          v
framer -> parser -> transform -> redact -> route
          |          |             |
          + reject   + mutate      + privacy boundary
          v
index/storage -> query -> dashboard/alert -> operator
          |
          +--> retention / access / lifecycle / cost
```

The diagram has no magical “logging platform” box. Every box owns state and can fail differently. During an incident, annotate the actual product/component name under each mechanism. For example, stdout might be captured by a container runtime, a collector might be OpenTelemetry Collector or another agent, and indexed storage might be Elastic or Splunk. The mechanism remains useful even when products change.

### Diagram 2: one record's identities

```text
schema: checkout.completed/v2
|
+-- resource
|   +-- service.name = checkout
|   +-- deployment.environment = production
|
+-- event class
|   +-- event_name = checkout.completed
|   +-- outcome = failure
|
+-- occurrence identity
|   +-- event_id = stable across transport retry
|
+-- correlation
|   +-- trace_id / operation_id
|
+-- clocks
|   +-- event_time
|   +-- observed_time
|
+-- typed attributes
    +-- duration_ms = integer
    +-- dependency = bounded name
    +-- reason_code = bounded enum
```

Do not treat every field as equal. Resource identity is stable across many events; event attributes vary per occurrence. Event ID answers replay/deduplication questions; trace ID answers correlation questions. A schema version answers compatibility questions. One giant `context` string answers none of them reliably.

### Diagram 3: population ledger

```text
produced = received + source_loss_or_scope_difference

received = accepted + rejected + still_unprocessed

accepted = indexed + queued_for_index + dropped_after_parse

deliveries = unique_events + duplicate_deliveries
```

These are investigation equations, not universal vendor formulas. A real pipeline may count batches at one boundary and records at another; a restart can reset counters; sampling changes the expected population; a fan-out intentionally multiplies deliveries. Write the contract before comparing numbers.

Carry age beside count:

```text
queue_depth = 100 records
oldest_age  = 2 seconds     -> perhaps healthy throughput

queue_depth = 3 records
oldest_age  = 45 minutes    -> critical freshness failure
```

### Diagram 4: compatible schema rollout

```text
contract proposal
      |
      v
producer + parser + mapping + query test corpus
      |
      v
canary producer cohort ---> old and new consumers accept?
      |                              |
      | no                           | yes
      v                              v
abort + rollback                expand gradually
      |                              |
      +---- preserve evidence <------+
                     |
                     v
verify user + coverage + freshness + cost
```

A schema change is a distributed deployment. The code that emits the field is only one participant. If the parser, mapping, alert or dashboard is incompatible, the release is incomplete even when the producer unit tests pass.

### Diagram 5: security and retention

```text
allowlisted event fields
          |
          v
sanitize untrusted values ----> reject log injection
          |
          v
encrypt/authenticate transport
          |
          v
bounded queue/dead letter -----> restricted access + expiry
          |
          v
indexed fields/body -----------> least privilege + query audit
          |
          v
retention/tiering/deletion ----> replicas + snapshots + exports included
```

Redaction at query time is presentation control. It does not remove sensitive bytes from earlier boundaries. The earliest controlled boundary is usually the safest place to prevent durable exposure.

## Request or state path

Follow one checkout from business operation to evidence.

1. A request reaches the checkout service with an approved trace context.
2. The service completes or fails the operation. Domain state has changed before logging is considered.
3. Code constructs `checkout.completed/v2` with event time, outcome, duration in milliseconds, stable resource identity, correlation context and bounded reason code.
4. A data-minimization allowlist excludes raw payment data, credentials, full contact fields and unrestricted request bodies.
5. The logger evaluates its effective level and filters. If the record is below threshold, that is an intentional policy decision and should be represented in expected coverage.
6. One handler serializes the record as compact JSON. If an expected field is missing or has the wrong type, the formatter or validation layer follows a declared failure policy rather than silently inventing a value.
7. The handler writes to stdout or another local destination. This can block, fail, duplicate through propagation, or be lost on immediate process termination depending on buffering and flush behavior.
8. The local runtime or journal captures bytes and attaches trusted process/workload metadata. Rotation, rate limits, disk exhaustion, permissions and restart identity now matter.
9. A collector discovers the source and remembers a cursor or offset. It counts received records and bytes separately from exported batches.
10. The collector frames physical input into logical events. A multiline traceback is joined according to a versioned tested rule.
11. A buffer absorbs rate mismatch. Queue depth, capacity, oldest age, spill use, retry and drop policy define reliability.
12. Transport sends a batch. A timeout can mean the destination committed the batch but the acknowledgement was lost, producing a duplicate on retry.
13. A parser decodes JSON, validates required fields and types, normalizes a declared severity scale, and attaches schema failure reasons to bounded rejected evidence.
14. A transform enriches stable resource identity. It must not overwrite trustworthy producer fields silently or add unbounded labels/fields without cost review.
15. A privacy processor rejects or redacts prohibited fields before durable index storage. Free-text and encoded content remain harder than field-name allowlists.
16. Routing selects tenant, dataset and retention policy. A wrong route can make records “missing” to one query while present elsewhere.
17. The index mapping accepts typed fields and acknowledges the write. Mapping conflicts, authorization, read-only state, capacity and lifecycle can reject it.
18. The search engine exposes the event after an indexing delay. Event time and index time can place it outside the user's current window.
19. A query chooses time field, range, dataset, tenant, event name, outcome and deduplication policy. A field-type change can alter matching or aggregation.
20. A dashboard converts results into panels. It must show freshness and no-data distinctly from zero.
21. An alert evaluates the same population under a declared rule and routes to an owner with a safe action.
22. The operator combines log evidence with metrics, traces, configuration/deployment evidence and the actual user journey. Logs support a decision; they are not the decision by themselves.

At every step, ask four questions:

```text
What state is owned here?
What counter or age proves this boundary worked?
How can this boundary lose, delay, duplicate, reject, mutate or expose data?
What does its evidence still not prove?
```

## Failure zoom

### Failure 1: multiline stack trace explosion

Symptom: one exception becomes four or forty search events. Error counts rise, tracebacks lose context, and ingestion cost spikes.

Likely mechanism: the collector treats every newline as an event boundary. The first traceback line has timestamp and severity; continuation lines do not. A later parser sees fragments without required fields.

Evidence path:

- compare physical line count with logical event count;
- inspect a bounded sanitized raw sample before parsing;
- measure unmatched continuation lines;
- test the exact framing rule against normal messages, nested exceptions, truncation and very long events;
- confirm whether framing occurs at source, agent, heavy forwarder or indexer;
- compare accepted/rejected counts after the correction.

Unsafe move: globally merge every line that lacks a timestamp. A malformed source can then attach unrelated records to one giant event and exhaust buffers.

### Failure 2: schema drift and mapping rejection

Symptom: the producer changes `duration_ms` from integer `420` to string `"420"`. Collector receipt stays flat, parser or index rejection rises, and duration queries lose part of their population.

Evidence path:

```text
source attempted          12,000/min
collector received        12,000/min
parser accepted            8,000/min
parser rejected            4,000/min
```

The earliest measured divergence is parser validation. A sanitized rejected sample supports the type mechanism. It does not prove why the producer changed or that every rejected record has the same defect.

Safe containment: roll back the producer or route its explicit schema version through a reviewed compatibility parser. Do not let a broad coercion silently accept wrong units or hostile strings.

### Failure 3: duplicate Python records

Symptom: each application record appears twice after a logging configuration change.

Mechanisms include:

- the child logger and root logger both have handlers while propagation is true;
- two handlers point to the same destination;
- a handler is installed twice during reload;
- collector retry redelivers after an ambiguous acknowledgement;
- two collectors read the same source;
- a query joins or expands one stored event.

Use a controlled event ID and compare counts at local output, collector input, export attempts, indexed documents and query results. Fix the first duplication boundary. Do not hide all repeated message text at search time; two users can legitimately produce identical messages.

### Failure 4: queue grows without drops

Symptom: queue depth and disk use rise, but the drop counter is zero. Teams call the pipeline healthy.

Zero drops only says the loss policy has not fired yet. If oldest age grows, evidence is already stale. If the queue reaches capacity, the next behavior may be blocking the application, spilling onto the same filesystem as application data, or dropping critical events.

Calculate rates:

```text
incoming rate = 72,000 events/s
drain rate    = 60,000 events/s
backlog growth = 12,000 events/s
```

A bigger queue adds time, not throughput. Restore drain capacity, reduce nonessential volume, or apply an approved degradation policy. After recovery, drain rate must exceed incoming rate or backlog never shrinks.

### Failure 5: replay duplicates after recovery

Symptom: after a destination outage, searches show a spike larger than real traffic.

At-least-once retry can redeliver a committed batch when its acknowledgement was lost. An event ID can help identify duplicates, but deduplication needs a declared time window, storage key or query rule. It also needs collision and retention reasoning.

Keep two numbers:

- delivery attempts;
- unique event occurrences under the declared identity contract.

Do not silently deduplicate before measuring the transport problem. A duplicate is pipeline evidence.

### Failure 6: timestamp makes present data look missing

Symptom: the record is indexed now but its source timestamp is 75 seconds old, outside a narrow “last minute” dashboard window. Another record has source time three seconds in the future.

Compare event, observed, ingest and index time. A late event may be correct domain evidence delivered slowly. A future event suggests clock skew, timezone, unit or field mapping. Choose which time field drives the query and expose ingestion delay separately.

Sorting by source time can make a late replay look like it always existed. Preserve arrival evidence.

### Failure 7: sensitive data in a successful pipeline

Symptom: every event is searchable and fresh, but `authorization`, payment data or contact fields are stored.

This is not success. The pipeline amplified an application mistake across local buffers, transports, indexes, replicas, snapshots and exports.

Immediate priorities:

1. stop new exposure through rollback or a reviewed earliest-boundary filter;
2. restrict access and export while preserving sanitized metadata;
3. identify all stores and copies;
4. involve security/privacy owners and rotate credentials if required;
5. execute approved retention/deletion and verify its scope;
6. add contract tests that fail future forbidden fields.

Hiding a field in a dashboard is not remediation.

### Failure 8: no data becomes zero

Symptom: a query returns no series/documents after parser rejection, and the dashboard paints zero errors.

The dashboard has changed an epistemic state—“I have no evidence”—into a numeric claim—“I measured no errors.” Correct designs expose:

- numerator;
- denominator or expected population;
- coverage;
- freshness;
- no-data status;
- parser/index/query errors.

A green service panel without monitoring-path health is incomplete.

## Internals and state ownership

### Python logging internals

Python application code typically calls a named logger. The logger creates a `LogRecord`, checks effective level and filters, then offers the record to handlers. If propagation is enabled, ancestor handlers also receive it until a logger disables propagation. Each handler has its own level, filters, formatter, lock and destination.

This produces several operational lessons:

- application code reaching `logger.info()` does not prove a handler emitted bytes;
- a root level, child level and handler level are different thresholds;
- attaching handlers at child and root can duplicate;
- a formatter expecting absent custom fields can fail;
- handler error policy can suppress operational visibility;
- synchronous handlers can add request latency or block;
- queue handlers decouple work but introduce a queue, listener lifecycle and loss/replay policy.

Libraries should generally create named loggers and let the application own destination configuration. A library that installs global handlers surprises every host application.

### File ownership, rotation and offsets

A file collector needs more state than a pathname. Consider:

```text
/var/log/app.log -> inode 100, offset 8 MiB
```

After rename rotation, the old inode can remain open and continue receiving bytes while a new inode appears at the original path. With copy-truncate, the same pathname and inode may suddenly shrink; the collector must decide whether to reset its offset. Rapid rotation can delete a file before it is fully read. Network filesystems and Windows-mounted WSL paths can change notification, locking, permission and latency behavior.

When diagnosing file loss, record:

- resolved path;
- device and inode;
- owner/mode;
- size and modification time;
- collector cursor/offset;
- rotation mechanism and time;
- open file descriptors;
- filesystem blocks and inodes;
- read, parse and drop counters.

Do not delete a “large log file” merely because disk is low. A process may still hold the deleted inode open, space may not return, and you may destroy incident evidence. Follow the storage lesson's exact-path and ownership discipline.

### Journald state

The journal stores structured entries and trusted metadata. Important ownership distinctions include:

- application-supplied fields versus underscore-prefixed trusted fields;
- current boot versus prior boots;
- volatile versus persistent storage;
- system journal versus per-user visibility;
- journal cursor versus wall-clock time;
- source realtime versus monotonic boot time;
- rate limiting and disk policy;
- local journal versus remote forwarding.

`journalctl --output=json` exposes fields, but JSON validity does not mean every value is human-safe or that each field appears once. Query only the approved unit, boot and time range, and sanitize before sharing.

### Syslog state

RFC 5424 defines a header containing priority, version, timestamp, hostname, application name, process ID and message ID, plus structured data and an optional message. Priority combines facility and severity. This describes a message; transport is separate.

Operational questions include:

- UDP, TCP, TLS or another mapping?
- what acknowledges delivery?
- what happens on reconnect?
- maximum message length and truncation?
- sender authentication and authorization?
- certificate/hostname verification?
- ordering across connections?
- loop prevention?
- rate and denial-of-service controls?

“Uses syslog” answers none of those alone.

### OpenTelemetry log state

The OpenTelemetry logs data model separates named fields such as timestamp, observed timestamp, severity, body, resource, instrumentation scope, trace context and attributes. This helps translate between formats without pretending all formats have identical capabilities.

The logging specification distinguishes existing logging APIs from OpenTelemetry processing/export. A bridge or appender can take records from an existing library and hand them into an SDK; processors and exporters then own batching, limits and delivery behavior.

Do not assume the words “OpenTelemetry logs” prove:

- an SDK is enabled;
- context is attached correctly;
- records reach a Collector;
- the Collector preserves fields;
- exporters deliver;
- a backend indexes;
- queries use the intended time and population.

Those are separate boundaries, which is why LES-0027 remains independently gated.

### Elastic pipeline state

Elastic Common Schema provides common field names and datatypes so events from different sources can be normalized and correlated. It is a schema vocabulary, not a magic parser.

An Elasticsearch ingest pipeline can transform documents before indexing. Processors can succeed, fail, call other pipelines or create mapping conflicts. Simulation with known documents is useful before rollout, while node ingest statistics expose processor counts, failures and time. A data stream provides a logical name over append-oriented backing indices and lifecycle can roll data across storage and delete it according to policy.

Key evidence boundaries are:

```text
client/agent send
  -> ingest processor count/failure/time
  -> mapping/index response
  -> data stream/backing index
  -> refresh/search visibility
  -> query field/time/data-stream scope
```

A successful pipeline simulation does not prove sustained capacity or production data safety. A successful index response does not prove the next query uses the correct alias/data stream and time field.

### Splunk pipeline state

Splunk describes input, parsing, indexing and search phases. Different components can own those phases: a universal forwarder may mainly input and forward, while a heavy forwarder can parse before an indexer performs final indexing. Configuration must be placed where the phase actually runs.

Line breaking, timestamp recognition, character encoding, routing and some transformations happen before or during indexing; other field extractions happen at search time. If a team changes parsing configuration on a search head while parsing actually occurs on a heavy forwarder, the screen can save successfully and behavior remains unchanged.

Ask:

- which component first performs input?
- which component performs line breaking and timestamp parsing?
- where are host, source and source type assigned?
- which queue is blocked?
- where is raw data committed?
- which fields are index-time versus search-time?
- which app/config layer wins precedence?
- which index and role can the caller search?

The product name is less important than the phase owner.

### Storage and search internals

Indexed logging systems usually store raw or reconstructed event content plus searchable index structures. Fields with many unique values enlarge dictionaries, postings, columnar structures or memory, depending on the product. Full-text tokenization, analyzed versus exact fields, dynamic mapping and unbounded keys affect cost and query meaning.

A query has its own resource model:

- time range;
- event/index/tenant population;
- fields and extraction work;
- full scan versus indexed constraint;
- regex complexity;
- result cardinality;
- sort and aggregation memory;
- concurrency and timeout;
- cold-tier fetch;
- permissions and field masking.

“Logs are expensive” is not actionable. Measure events, bytes, fields, cardinality, retention, copies and query work by owner.

## Evidence table

| Observation | It supports | It does not establish | Safest next evidence |
|---|---|---|---|
| Application emission counter rises | the instrumented code path counted attempted records | handler success, local persistence, complete user population | handler error/write count and bounded local output |
| Local file or journal contains the record | bytes reached that local destination | collector read, remote delivery, indexing or search | collector receive/cursor evidence for the same identity |
| Collector received equals source attempted | no measured count divergence between those counters in matched scope | payload correctness, later queue/export success, counter completeness | queue/accepted/rejected/export counts and oldest age |
| Queue depth rises | input exceeds drain or downstream progress is blocked | drops, cause, safe capacity or user impact | input/drain rate, capacity, oldest age, disk and downstream error |
| Queue drop counter is zero | declared drop path has not counted a drop | freshness, no blocking, no hidden loss or future capacity | oldest age, source/receive conservation, process latency and capacity forecast |
| Parser rejected count rises | parser/schema boundary refuses more records | why producer changed or whether all failures share one cause | rejection reasons plus bounded sanitized raw samples and version diff |
| Index API acknowledges a batch | destination accepted according to that API response | query visibility, durability objective, correct route or absence of duplicates | index stats, refresh/search result and event identity |
| Search returns no events | none matched caller, scope and time at evaluation | zero events occurred or pipeline loss location | broaden one dimension at a time and inspect boundary/freshness evidence |
| Search returns duplicates | query result has repeated identity or content | transport duplication specifically | compare controlled event ID at each boundary and inspect query expansion |
| Dashboard is green | its current query/transform/threshold evaluated green | user health, complete data, correct population or fresh evidence | numerator, denominator, coverage, freshness, no-data state and user SLI |
| Event time is after observed time | source/mapping clock relationship is inconsistent | which clock, timezone, unit or parser is wrong | compare raw timestamp, host sync, timezone/unit and observed/index clocks |
| Sensitive field is hidden in UI | presentation does not show it | removal from source, queue, index, replica, snapshot or export | inspect schema, stored mapping/copies, access audit and approved deletion proof |
| Retention policy says fourteen days | desired lifecycle is documented | every backing store, snapshot or export expires then | observe lifecycle execution and sample exact oldest records/copies |

## Command decoders

### Decoder 1: environment identity

```bash
id; uname -a; cat /etc/os-release; systemctl --version; python3 --version; pwd
```

Read it left to right:

- `id` records numeric UID/GID and groups. Do not assume a username has or lacks journal access.
- `uname -a` records kernel and architecture. In WSL it also exposes the Microsoft-flavored kernel boundary.
- `/etc/os-release` records distribution identity; it is not the kernel.
- `systemctl --version` records systemd tooling version, not whether PID 1 is systemd or whether a journal is persistent.
- `python3 --version` bounds the deterministic model runtime.
- `pwd` prevents running a mutating lab from an unexpected copy.

If one command fails, keep its failure. Do not hide it behind `2>/dev/null` during an evidence capture.

### Decoder 2: visible journal boots

```bash
journalctl --list-boots --no-pager
```

Typical columns identify a relative boot number, boot ID, first timestamp and last timestamp. `0` is the current boot; negative values refer to earlier visible boots. Visibility may be empty in a minimal WSL/container environment or for a caller without access.

The boot ID matters because wall-clock time can repeat after clock changes and because “yesterday at 10:00” might refer to another boot. Select the boot explicitly during a serious incident.

### Decoder 3: bounded JSON journal query

```bash
journalctl --unit=ssh.service --since '-15 min' --output=json --no-pager --lines=20
```

- `--unit` scopes by systemd unit.
- `--since` bounds time.
- `--output=json` exposes structured fields; each output object is serialized on one line.
- `--lines=20` caps returned entries.
- `--no-pager` prevents an interactive pager from changing capture behavior.

The service is only an example. Do not query sensitive authentication logs merely because the command is read-only. Select an approved local unit, retain the smallest necessary sample, and sanitize values.

Useful fields can include message, priority, realtime timestamp, boot ID, PID, UID, executable, systemd unit and transport. Field availability and trust differ. Never treat an application-supplied hostname or user field as the same trust level as journal-added process metadata.

### Decoder 4: journal disk usage

```bash
journalctl --disk-usage
```

This asks journald for active and archived journal usage. It does not replace:

```bash
df -hT <journal-path>
df -i <journal-path>
```

The first command reports filesystem blocks/type for the exact path; the second reports inode availability. Journal usage also does not tell you which events can be safely removed. Retention, legal/security hold, incident evidence, persistence and forwarder state must be reviewed before vacuuming.

### Decoder 5: lab doctor

```bash
bash lab.sh doctor
```

Expected success includes:

```text
ready=true
state=absent
runtime=deterministic-model-only
```

The last field is a warning label. It prevents a successful local calculation from turning into “Elastic was tested.”

### Decoder 6: setup and status

```bash
bash lab.sh setup
bash lab.sh status
```

Setup creates only `/tmp/reliability-atlas-les0029-<UID>` after validating the fixture and using a unique candidate directory. A sentinel and manifest bind lesson, UID, state path and case ID. Status validates every allowed child before counting result files.

If status refuses an unexpected child, that refusal is success for the safety policy. Do not weaken the allowlist or run a broad recursive delete.

### Decoder 7: baseline

```bash
bash lab.sh run baseline
```

The fixture contains eight records: four for each of two trace IDs. It intentionally shows that trace correlation groups related events but does not prove the trace is complete or causally correct. Observation delay is two seconds for all baseline records, which proves only fixture arithmetic.

### Decoder 8: multiline

```bash
bash lab.sh run multiline
```

Expected:

```text
physicalLines=5
logicalEvents=2
continuationLines=3
eventLineCounts=[4,1]
```

The rule says a timestamp prefix starts an event; other lines continue the prior event. It is deliberately narrow. Real collectors require maximum size, timeout, flush, invalid-start, nested-trace and memory tests.

### Decoder 9: parser drift

```bash
bash lab.sh run parser-drift
```

Expected six inputs, four accepted, two rejected. One rejected record has string `duration_ms`; one lacks it. The result identifies fields, not values.

Do not “fix” it by converting every string to integer. First decide whether the producer or parser owns compatibility, whether the unit is still milliseconds, and what invalid strings do.

### Decoder 10: backpressure

```bash
bash lab.sh run backpressure
```

Expected:

```text
40 produced = 25 consumed + 10 queued + 5 dropped
loss fraction = 5 / 40 = 0.125 = 12.5 percent
```

The model contains no time axis. Therefore it cannot calculate queue age, concurrency or drain rate. This limitation is intentional: correct arithmetic plus honest limits is stronger than a realistic-looking fake benchmark.

### Decoder 11: other fault cases

```bash
bash lab.sh run duplicate-delivery
bash lab.sh run privacy
bash lab.sh run clock-skew
bash lab.sh run incident
```

Duplicate delivery reports six deliveries, four unique event IDs and two duplicates. It does not implement durable deduplication.

Privacy reports only forbidden field names and occurrence counts; it does not return raw values. It detects four occurrences under an exact field-name allow/deny model, not free-text or encoded secrets.

Clock skew reports delay arithmetic, including a 75-second late record and one negative delay. It cannot identify which clock is wrong.

Incident returns the earliest supported parser boundary and safe containment language. It does not convert timing into organizational root cause.

### Decoder 12: verifier and cleanup

```bash
bash verify.sh
bash lab.sh cleanup
```

The verifier runs eight cases and injects two controlled unsafe children to prove cleanup refuses them. Its exit handler removes only those exact injected entries, attempts validated cleanup, and reports cleanup failure. It never follows a state-root symlink.

Final absence means only the exact lab state is absent. It does not claim unrelated `/tmp`, journals, processes, ports or vendor resources are clean.

## Decision path

Use this when logs appear missing, late, duplicated or wrong.

```text
1. FRAME the user operation, scope, time and risk.
2. Verify user impact independently from the log pipeline.
3. Define the expected event population and schema version.
4. Fix event, observed, ingest, index and query clocks.
5. Record change events around the first symptom.
6. Compare produced and local-write evidence.
7. Compare collector received, queued, retried, dropped and oldest-age evidence.
8. Compare parser accepted, rejected, transformed, redacted and routed evidence.
9. Compare index attempts, acknowledgements, rejections and search visibility.
10. Inspect query tenant/index/time/field/type/no-data and duplicate behavior.
11. Stop at the earliest supported divergence.
12. Choose reversible containment with abort and rollback.
13. Preserve only bounded sanitized evidence.
14. Verify user recovery and monitoring recovery separately.
15. Prevent recurrence with contract, canary, capacity and security controls.
```

### Branch A: source attempted count is low

Investigate code path, logger level/filter, sampling policy, handler construction, formatter errors and process lifecycle. Do not edit the collector yet.

### Branch B: source/local is complete but collector receive is low

Investigate discovery, path/inode/cursor, journal permissions/boot, stream capture, rate limit and collector receiver errors.

### Branch C: collector receive is complete but queue age grows

Investigate downstream drain, transport acknowledgement, retry/backoff, capacity, disk blocks/inodes and destination throttle. No drop does not mean no incident.

### Branch D: receive is complete but parser/index rejection rises

Inspect rejection reasons, bounded sanitized samples, producer/parser/mapping versions and field types/units. Canary a compatible fix.

### Branch E: indexed count is complete but search is low

Inspect refresh/freshness, tenant, index/data stream, time field/range, access policy, field extraction, query joins, deduplication and late arrival.

### Branch F: search is complete but dashboard is misleading

Inspect transformations, null/no-data conversion, units, grouping, time range, denominator, freshness and panel ownership. Fix the presentation but preserve the underlying incident.

### Branch G: sensitive data is anywhere in the path

Treat it as exposure. Stop new emission, restrict access/exports, preserve sanitized metadata, identify copies, involve policy owners, rotate credentials when required, and verify approved deletion/retention actions.

## Guided Ubuntu lab

### Purpose

The lab makes eight failure concepts visible without downloading or running a monitoring product. It is intentionally small so you can inspect every line and calculation.

It teaches:

- physical lines versus logical events;
- required fields and types;
- count conservation;
- queue loss fraction;
- duplicate delivery versus unique identity;
- forbidden field detection and redaction;
- event versus observed time;
- boundary-based incident reasoning.

It does not teach vendor commands by imitation. Product acceptance requires the actual product.

### Safety contract

Run as a normal Ubuntu user. The wrapper refuses root. It creates one UID-specific directory under `/tmp`, opens no port, starts no persistent process, uses no network and installs nothing.

Before running:

```bash
cd drafts/LES-0029-structured-logging-pipelines/support/lab
bash lab.sh doctor
```

Stop if doctor refuses. A refusal is not an invitation to use `sudo`.

### Phase 1: create baseline state

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

Write down:

- records;
- trace groups;
- severity counts;
- maximum observation delay;
- every proof limit.

Prediction before fault cases: if parsing rejects two of six records while source input is unchanged, accepted coverage should be four divided by six, about 66.67 percent. Do the arithmetic before running the case.

### Phase 2: framing and parsing

```bash
bash lab.sh run multiline
bash lab.sh run parser-drift
```

For multiline, draw this mapping:

```text
physical 1 + 2 + 3 + 4 -> logical exception event
physical 5             -> logical health event
```

For parser drift, inspect rejection details. One is wrong type; one is missing. Explain why those deserve different reason codes even if both are rejected.

### Phase 3: queue and replay

```bash
bash lab.sh run backpressure
bash lab.sh run duplicate-delivery
```

Show both equations:

```text
40 = 25 + 10 + 5
6 deliveries = 4 unique events + 2 duplicate deliveries
```

Then explain why the second equation depends on a trusted event-identity contract while the first depends on aligned counters.

### Phase 4: security and clocks

```bash
bash lab.sh run privacy
bash lab.sh run clock-skew
```

The privacy result never returns values. That design reduces evidence exposure. State what it misses: free-text secrets, alternative spellings, encoded values, nested paths, false positives, access/retention and legal decisions.

For clocks, classify positive delay, large delay and negative delay. Do not name a root cause from arithmetic alone.

### Phase 5: incident and full verifier

```bash
bash lab.sh run incident
bash verify.sh
```

The incident facts support parser schema validation as the earliest measured boundary. The safe first move stops new incompatible input while preserving rejected counts and a sanitized sample. Increasing retention or restarting the UI does not address that boundary.

Expected final line:

```text
verification=passed lesson=LES-0029 cases=8 ... cleanup=passed final_state=absent runtime=deterministic-model-only
```

If WSL fails before Bash starts, record an environment blocker. Do not claim the verifier passed from Python-only or syntax checks.

### Optional read-only journal observation

Only on an approved local Ubuntu system with an appropriate non-sensitive unit:

```bash
journalctl --list-boots --no-pager
journalctl --unit=ssh.service --since '-15 min' --output=json --no-pager --lines=20
journalctl --disk-usage
```

Do not paste raw authentication records into the learning repository. Record only field names, counts, timestamps rounded or tokenized as needed, command scope and proof limits.

### Cleanup

If you ran cases individually rather than the verifier:

```bash
bash lab.sh cleanup
bash lab.sh status
```

Expected status is absent. If cleanup refuses, preserve the state and inspect the named mismatch.

## Production transfer

### From lab model to a real service

The local model teaches contracts. Production transfer requires a representative service and actual pipeline components.

Minimum transfer plan:

1. Choose one noncritical canary service and one user operation.
2. Define versioned events for start, terminal success and terminal failure, with typed units and bounded fields.
3. Establish a source attempt counter independent enough to compare with downstream receipt.
4. Configure one actual local destination and document buffering/flush behavior.
5. Configure the real collector with immutable version, minimal permissions, limits, queue and health telemetry.
6. Send known unique canary event IDs without secrets.
7. Record receive, queue, parse, reject, export, index and search evidence.
8. Inject controlled wrong type, missing field, multiline, downstream throttle, replay and prohibited-field cases.
9. Prove alerts distinguish rejection, drop, late evidence and no data.
10. Prove rollback accepts both schema versions or stops the new producer safely.
11. Measure real event sizes, compression, index overhead, query cost and recovery drain rate.
12. Verify user outcome, monitoring coverage and freshness separately.

### Ubuntu and journald transfer

For a systemd service, review:

- stdout/stderr destination and buffering;
- unit identity and restart behavior;
- application fields versus journal trusted fields;
- current and prior boot visibility;
- volatile/persistent journal configuration;
- rate limits;
- disk limits and filesystem headroom;
- collector journal cursor and permissions;
- time synchronization;
- remote-forwarding loss/retry policy.

Do not change journal retention during an incident until you understand evidence and filesystem risk. Read-only observation comes first.

### Container and Kubernetes transfer

Containers often write stdout/stderr, which a runtime stores in node-local files or another logging driver. Kubernetes does not magically centralize them. Transfer questions include:

- which runtime owns the node file and rotation?
- can the application block on stdout?
- how are multiline records framed?
- how are pod, namespace, container and restart identities attached?
- what happens when the pod disappears before collection?
- can two agents collect the same file?
- how is node disk pressure separated from application storage?
- what permissions expose other namespaces?
- how are terminated container logs retained?
- what is the queue/drop behavior during backend outage?

Never put high-cardinality request IDs into index-partition or label dimensions blindly. Keep correlation fields searchable under a measured field/index strategy.

### Elastic transfer

Review exact artifact version, license and security configuration. Use a versioned test corpus and simulate the ingest pipeline. Then canary real documents and inspect:

- processor count, failure and time;
- rejected documents and bounded failure reasons;
- mapping conflicts;
- default/final pipeline selection;
- data stream and index-template match;
- index response and refresh delay;
- lifecycle/rollover behavior;
- field mapping and query result;
- role and field/index access;
- stored size, shards, replicas and search cost.

Do not run dynamic mapping against uncontrolled production fields and hope ECS appears automatically. Map the fields you depend on and bound custom field names.

### Splunk transfer

Map the actual input, parsing, indexing and search owners. Confirm where line breaking, timestamp extraction, routing, anonymization and field extraction occur. Inspect configuration precedence on the component that owns the phase.

Use a known-input canary and verify:

- source/host/sourcetype and index routing;
- physical-to-logical event count;
- timestamp and timezone;
- raw event preservation;
- index-time versus search-time fields;
- queue and throughput age;
- role/index visibility;
- search population and freshness;
- rollback configuration bundle.

A saved search that returns expected fields is not proof that index-time parsing is correct for all sources.

### OpenTelemetry transfer

Decide whether the application uses an existing logging API with a bridge/appender or emits through an OpenTelemetry API/SDK path. Record:

- SDK and bridge versions;
- resource and instrumentation scope;
- timestamp and observed timestamp;
- severity mapping;
- trace/span context attachment;
- attribute limits and sensitive-data policy;
- processor and batch limits;
- exporter retry/queue behavior;
- Collector receiver/processor/exporter evidence;
- backend field mapping.

Do not claim log-trace correlation because both fields exist. Query known trace IDs across source and backend and prove tenant/context boundaries.

### Migration and rollback

A safe schema migration often uses expand-and-contract:

1. readers/parsers accept old and new form;
2. mapping/query/dashboard support both;
3. a producer canary emits new form;
4. rejection, coverage, freshness, security and cost gates pass;
5. rollout expands;
6. old producers retire;
7. old compatibility is removed only after retention and rollback windows.

Retyping an existing field in place is usually more dangerous than adding a clearly named new field with explicit unit and migration logic.

## Reliability, security, observability, capacity, and cost

### Reliability contract

Define a logging pipeline objective from the user/investigation need, not from “agent process up.” Example:

```text
For terminal checkout events that the versioned source counter declares eligible,
at least 99.9% become searchable in the correct tenant with valid required fields
within 60 seconds over a rolling 30-day window,
excluding explicitly approved sampling classes.
```

This still needs:

- source counter trust and reset handling;
- duplicate policy;
- planned maintenance/exclusion policy;
- critical-event classes;
- late-arrival correction;
- measurement independent enough not to fail identically;
- user-impact linkage.

Alert separately on rejection, drops, queue oldest age, source-receive divergence, index errors and no-data.

### Security and privacy

Logs combine operational power with broad exposure. Controls should cover:

- field allowlists and classification;
- secret/token/password/payment/contact/body prohibition;
- pseudonymization where correlation is needed;
- sanitation of CR, LF, delimiters and control characters to prevent log injection;
- size and nesting limits against resource exhaustion;
- authenticated and encrypted transport;
- least-privilege collector and backend identities;
- tenant/index/field access;
- query and export auditing;
- integrity/tamper evidence;
- encrypted buffers, dead letters, indexes, snapshots and archives;
- bounded retention and legal/security holds;
- approved deletion and credential rotation;
- incident response for exposed data.

Hashing an email is not automatically anonymous; a predictable small domain can be reversed by guessing. Keep raw-to-token maps outside logs under stricter control when they are required at all.

### Observability of observability

Monitor the logging path with signals that do not all depend on the same broken path. Important signals:

```text
source attempted records/bytes
handler failures and blocked duration
local destination growth/rotation/rate limit
collector received records/bytes
queue depth/capacity/oldest age/spill bytes
retry/drop/reject counts by bounded reason
export acknowledgements and latency
index rejections and freshness
known canary event search latency
query errors/no-data/access denial
```

A synthetic canary event with a non-sensitive unique ID can measure end-to-end freshness. Bound its rate, tenant and retention. The canary proves its path, not every event class.

### Capacity arithmetic

For 150 services, eight replicas each and 20 events/s per replica:

```text
emitters = 150 * 8 = 1,200
average EPS = 1,200 * 20 = 24,000
peak EPS at 3x = 72,000
peak raw bytes/s = 72,000 * 900 = 64,800,000 bytes/s = 64.8 MB/s
```

Sustained peak raw per day:

```text
64,800,000 * 86,400 = 5,598,720,000,000 bytes
                         = 5.59872 TB decimal
```

With declared planning factors:

```text
compressed + index overhead per copy
= 5.59872 TB * 0.35 * 1.25
= 2.44944 TB/day

two copies = 4.89888 TB/day
14 days    = 68.58432 TB
```

This is not vendor sizing. Real values depend on sustained versus burst rate, size distribution, JSON field names, compression, tokenization, mappings, shards/buckets, replicas, filesystem reserve, compaction, caches, lifecycle, query concurrency and growth.

Ten-minute peak outage:

```text
events = 72,000 * 600 = 43,200,000
raw bytes = 43,200,000 * 900 = 38,880,000,000 = 38.88 GB
```

Add queue metadata, frames, filesystem reserve, retry duplication and safety margin. Then calculate drain:

```text
drain backlog in 20 minutes:
43,200,000 / 1,200 = 36,000 extra events/s

required consumer while peak continues:
72,000 + 36,000 = 108,000 events/s before headroom
```

If recovered capacity returns only to 72,000 events/s, the backlog remains forever at peak input.

### Cost controls

Cost levers include:

- eliminate duplicate events and duplicate handlers;
- choose intentional event classes instead of verbose narrative at every line;
- bound field names and high-cardinality values;
- avoid indexing fields that are never searched while preserving necessary raw evidence according to product design;
- sample only explicitly low-value classes with measurable policy;
- aggregate after the raw investigation window when justified;
- tier older data;
- reduce unnecessary copies while meeting availability;
- expire data according to approved retention;
- optimize common queries and time scopes;
- control export and egress;
- review DEBUG enablement with automatic expiry.

Do not reduce cost by silently dropping the exact terminal failure events used for incident response or compliance.

### Ownership

Useful ownership split:

- application/domain team: event meaning, trigger, outcome, typed business fields;
- platform team: common envelope, local collection, transport, queue, routing and self-observability;
- observability/data team: parsing standards, indexed schema, lifecycle, query platform and cost;
- security/privacy: classification, access, integrity, retention, exposure response;
- service owner/on-call: user SLI, alert action, runbook and recovery verification.

Shared ownership does not mean unclear ownership. Each field and boundary needs one accountable decision-maker.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| “No search results means no events” | absence can occur at every pipeline boundary or access/query scope | compare boundary counts and freshness before concluding |
| “JSON means structured” | syntax can be valid while types, units, names and meaning drift | versioned schema with owner and compatibility tests |
| “INFO means success” | severity is not business outcome | separate severity from explicit outcome |
| “Collector is up” | process liveness does not prove receivers, queues, exporters or destination | per-component counters, queue age and canary freshness |
| “Zero drops means healthy” | evidence may be blocked or hours late | alert on oldest age, capacity and source-to-search coverage |
| “Retries prevent loss” | retries can duplicate and amplify backlog | declare delivery semantics, idempotency and retry budget |
| “Event ID gives exactly once” | identity without enforcement and durable commit semantics is only a field | measure duplicates and define deduplication boundary/window |
| “Bigger queue fixes the outage” | it adds buffering time, not drain throughput | capacity and recovery-rate model with disk/inode guard |
| “Coerce every type” | hides producer defects, units and hostile values | versioned compatibility with strict failure reasons |
| “Multiline is just regex” | weak rules merge unrelated events or exhaust memory | bounded tested framing with max size/time and fallback |
| “Query-time redaction is enough” | sensitive data already crossed and persisted at earlier boundaries | minimize before emission and redact before durable storage |
| “Hash means anonymous” | predictable domains can be guessed and hashes can remain identifiers | threat model, keyed/tokenized design and restricted mapping |
| “Keep all logs forever” | cost, attack surface and legal/privacy risk grow | justified tiered retention with expiry and deletion proof |
| “Delete the large file” | open deleted inode, evidence loss, collector cursor confusion | exact-path/inode/process evidence and approved rotation/remediation |
| “Sort by event time and incident is fixed” | hides late arrival and pipeline delay | preserve observed/index clocks and freshness views |
| “Dashboard green means service recovered” | no-data conversion or stale evidence can paint green | user journey plus coverage/freshness/no-data verification |
| “Change parsing on any Splunk node” | configuration acts where the pipeline phase is owned | map phase to component and verify effective config |
| “Dynamic mapping will adapt” | uncontrolled types/fields create conflicts and cost | reviewed templates/mappings and canary documents |
| “OTel field present means correlation works” | context can be wrong, missing or cross-tenant | known trace test across every hop and access boundary |
| “Read-only logs are harmless” | viewing/exporting can expose sensitive data and query load | least scope, access policy, sanitization and query budgets |

## Memory card and retrieval

### The sentence to remember

> When logs look wrong, freeze scope and clocks, compare counts and oldest age from source to search, stop at the first divergence, and never turn missing evidence into zero.

### The seven population buckets

```text
produced
received
queued
accepted
rejected
dropped
duplicated
```

Indexed and searchable are later boundaries, not synonyms for accepted.

### The five clocks

```text
event
observed
ingest
index/searchable
query evaluation
```

### The eight safety questions

1. What user operation and event class are in scope?
2. Which component owns this state or transformation?
3. Are counter populations and resets aligned?
4. How old is the oldest unprocessed evidence?
5. What can be rejected, dropped or duplicated here?
6. What sensitive or untrusted data can cross this boundary?
7. What is the reversible containment and abort condition?
8. How will user recovery and monitoring recovery be proven separately?

### One-minute retrieval drill

Without looking back, explain:

- why a line is not necessarily an event;
- why JSON is not a schema;
- why no data is not zero;
- why queue depth needs oldest age;
- why at-least-once can duplicate;
- why event time needs observed time;
- why UI redaction is too late;
- why a successful search does not prove complete logging.

If one answer feels vague, return to its term and architecture boundary before memorizing a command.

## Complete answers

### 1. What is a structured log?

**Direct answer:** A structured log is a record whose important data has stable named fields and types under a declared contract, rather than existing only inside prose.

**Foundation:** JSON is a common serialization, but JSON alone is not enough. `"duration": "fast"` and `"duration": 420` are both valid JSON. The schema must define meaning, type and unit.

**Senior answer:** Treat each event class as a versioned API. Define resource, event identity, correlation, clocks, severity, outcome, typed attributes, privacy classification, compatibility, ownership and missing behavior. Test producer, parser, mapping and query together.

### 2. Why can one exception become many events?

**Direct answer:** A stack trace contains several physical lines. A collector that frames each line as a record splits one logical exception into fragments.

**Foundation:** The first line usually has timestamp/severity; later lines continue the same event. A multiline rule groups them.

**Senior answer:** Framing is a bounded state machine, not just a convenient regex. Test ambiguous starts, truncation, timeouts, maximum bytes/lines, source interleaving and memory pressure. Emit unmatched-line and oversized-event evidence.

### 3. Where did missing logs go?

**Direct answer:** Compare produced, local, received, queued, accepted, rejected, indexed and searchable counts in the same scope. The first divergence names the failing boundary.

**Foundation:** If 12,000 are produced and received but only 8,000 accepted while 4,000 are rejected, the parser boundary accounts for the missing search population.

**Senior answer:** Also align counter resets, fan-out, sampling, duplicate policy and clocks. Carry oldest age because events may be delayed rather than lost. Use sanitized rejected samples to explain mechanism without claiming root cause too early.

### 4. Why is no data different from zero?

**Direct answer:** Zero is a measured value in an existing population. No data means the measurement or matching population is absent.

**Foundation:** Zero checkout failures among 1,000 measured attempts is useful. No failure records and no attempt records could mean no traffic or a broken pipeline.

**Senior answer:** Dashboards and alerts should expose denominator, coverage, freshness and no-data state. A fallback-to-zero is permitted only when the existence and completeness of the denominator population are independently established.

### 5. Why can retries create duplicate logs?

**Direct answer:** A destination may commit a batch while its acknowledgement is lost. The sender retries and delivers it again.

**Foundation:** At-least-once prefers possible duplicates over silent loss.

**Senior answer:** Preserve a stable event occurrence ID across retries, measure delivery attempts and unique events, define dedupe location/window and model replay. Avoid claiming exactly once without end-to-end producer, commit and consumer proof.

### 6. How do event and observed time differ?

**Direct answer:** Event time comes from the source occurrence; observed time records when the collection system saw it.

**Foundation:** Their difference shows source-to-observer delay. A record can describe an old event but arrive now.

**Senior answer:** Preserve ingest/index/searchable time too. Use delay distributions and oldest age, validate timezones/units/sync, and keep arrival order for replay investigations. A negative delay is evidence of clock or mapping inconsistency, not a specific cause.

### 7. What should never be logged?

**Direct answer:** Credentials, authorization material, private keys, payment data, session tokens and unrestricted sensitive bodies should not enter ordinary logs.

**Foundation:** A log is copied into buffers, indexes, replicas, snapshots and exports. One field can spread widely.

**Senior answer:** Use allowlisted schemas, classification, pseudonymous references where justified, untrusted-value sanitation, earliest-boundary redaction, least privilege, query/export audit, encrypted bounded storage, retention and exposure response. Query-time hiding is not deletion.

### 8. Why does queue depth need oldest age?

**Direct answer:** Depth measures amount waiting; oldest age measures how stale the worst waiting evidence is.

**Foundation:** Three events stuck for forty-five minutes can be worse than 10,000 events draining in two seconds.

**Senior answer:** Combine input/drain rates, capacity, spill/disk headroom, oldest and percentile age, retries, drops and recovery drain margin. Alert before capacity causes blocking or loss.

### 9. How do you size a log buffer?

**Direct answer:** Estimate peak event/byte rate times tolerated outage, then add framing, metadata, retry, filesystem and safety headroom and verify recovery drain rate.

**Foundation:** At 72,000 events/s and 900 bytes for ten minutes, the raw minimum is 43.2 million events or 38.88 GB.

**Senior answer:** Measure size/rate distributions, not only averages. Include queue durability, filesystem blocks/inodes, competing workloads, encryption/compression, restart recovery and a drain objective. A buffer without surplus consumer capacity only postpones failure.

### 10. What differs between Splunk and Elastic here?

**Direct answer:** Product mechanisms and vocabulary differ, but both have input, parsing/transformation, storage/indexing and search boundaries whose owners and evidence must be mapped.

**Foundation:** In Splunk, identify the component performing each pipeline phase. In Elastic, identify agent/client, ingest pipeline, mapping/index or data stream, lifecycle and query scope.

**Senior answer:** Use official versioned documentation and real runtime evidence for exact behavior. Do not transfer configuration names blindly. Transfer the mental model: record contract, phase owner, counts, age, failure policy, access, retention and proof limits.

### 11. What does journald add?

**Direct answer:** It stores structured entries and attaches system-derived metadata such as boot, process and unit identity.

**Foundation:** `journalctl` can query by unit, boot and time and can output structured fields.

**Senior answer:** Review trusted versus application fields, persistence, rate limits, storage policy, permissions, cursors, clock fields and forwarding. Journal presence is local evidence, not remote searchable delivery proof.

### 12. How do you verify recovery?

**Direct answer:** Prove the user operation recovered, then prove source-to-search coverage, freshness, rejection/drop/duplicate behavior and dashboard correctness recovered.

**Foundation:** A fixed dashboard is not enough. The service can still fail; the service can recover while the logging path stays blind.

**Senior answer:** Use a bounded known canary event and independent user SLI, reconcile populations after backlog/replay, verify late records and duplicates, observe stable resource/cost signals, keep rollback available through the observation window, and state remaining unknowns.

## Product-company interview

### Scenario

At 14:00 a checkout release changes a typed duration field. At 14:03 the log error dashboard becomes green, but on-call reports that searches contain fewer terminal events. Collector CPU is normal, queue depth is flat, and application metrics show stable request volume. A security engineer notices that rejected samples contain contact and authorization fields. How do you lead?

### Strong model answer

I would declare two possible incidents: monitoring-data integrity degradation and sensitive-data exposure. I would keep user impact unknown until an independent checkout SLI or synthetic journey establishes it.

First I fix scope and clocks: affected service/version, event class, region/tenant, event and observed time, deployment time and query evaluation time. Then I compare matched boundary populations. If application emission and collector receipt remain 12,000/min, while parser acceptance falls from 11,980 to 8,000 and rejection rises from 20 to 4,000, the earliest supported divergence is parser/schema validation. Post-change rejection is 33.33 percent and accepted coverage is 66.67 percent. The quoted duration in a sanitized rejected sample is a plausible mechanism, but I verify desired/running producer, parser and mapping versions before naming root cause.

My safest containment is to stop new incompatible records: roll back the producer or route its explicit schema version through a previously tested compatible parser. I set abort conditions on user outcomes, rejection, queue age, drops and storage pressure. I preserve bounded sanitized rejection metadata. Because prohibited fields crossed the logging boundary, I restrict search/export access, stop new emission, identify buffers/indexes/replicas/snapshots/exports, involve security/privacy owners, and rotate credentials or perform approved deletion according to policy.

I do not trust the green dashboard because it turns no data into zero. Recovery requires the checkout journey, source/receive conservation, parser rejection near expected baseline, backlog age within objective, index/search freshness, correct query population, explicit no-data behavior and stable cost/resource signals. Prevention is a versioned event API, producer-parser-mapping-query test corpus, canary rollout, forbidden-field tests, bounded dead-letter policy, coverage/freshness SLOs and rollback compatibility.

### Weak-answer warning signs

- “Restart the dashboard.”
- “The collector is healthy because CPU is normal.”
- “Accept strings everywhere.”
- “Keep the rejected events forever for debugging.”
- “Hide sensitive fields in the dashboard.”
- “The release is root cause because the times match.”
- “Green means users recovered.”
- “No queue growth means no loss.”

### Follow-up 1: What if parser rejection returns to baseline but search count stays low?

Move forward one boundary. Inspect routing, index write acknowledgements/rejections, refresh/freshness, selected data stream/index/tenant, access, time field/range and query transformations. Backlog can also still be draining.

### Follow-up 2: What if source attempted count is wrong?

Then it cannot be the authoritative denominator. Compare another independent operation count such as application request/terminal counters, transaction state or a controlled canary. Document the mismatch; do not force coverage arithmetic from an untrusted population.

### Follow-up 3: How would you explain this to leadership?

The service continued producing and the collector continued receiving records, but a release changed a field type and the parser rejected about one third of the monitored completion events. The dashboard hid missing evidence as zero. We stopped the incompatible flow, are verifying customer impact independently, and are treating sensitive fields found in rejected records under the security process. Next updates will separate user recovery, monitoring recovery and exposure scope.

### Follow-up 4: Where can AI help and where must the engineer stay accountable?

AI can cluster rejection reasons, draft schemas, generate test cases, summarize timelines and suggest queries. The engineer must verify data scope, authorization, raw evidence, semantics, sensitive-data handling, blast radius, rollback, causal claims and user recovery. An AI-generated regex or query can confidently destroy event boundaries or expose data; it earns trust only through the same known-input and safety gates.

## Independent transfer and rubric

### Unscored transfer rehearsal

The following visible scenario is for rehearsal only. It **cannot** satisfy `ASM-0072` because an independent transfer must be unseen.

A job platform writes a pretty-printed JSON exception across multiple lines. A collector is configured for one-line JSON and uses an in-memory queue. During a search-backend throttle, the queue fills and drops newest events. After restart it replays part of the input. The parser renames `job_id` to `run_id`, but one dashboard still filters `job_id`. Event timestamps come from a host clock ninety seconds slow. A debug field includes a submitted command string with embedded newline characters.

Without reopening complete answers, rehearse:

1. user and monitoring impact statement;
2. physical-line-to-logical-event diagram;
3. source-to-query boundary map;
4. at least five ranked hypotheses and rejection evidence;
5. produced/received/queued/dropped/duplicate/unique reconciliation;
6. event/observed/index/query time analysis;
7. versioned schema and query migration;
8. log-injection and sensitive-data controls;
9. queue/outage/drain sizing;
10. safe containment, abort, rollback and separate recovery proof;
11. five-minute interview response;
12. at least twelve proof limits.

### Scored independent transfer

Use a materially different unseen disposable local case supplied by an instructor or created and held back before the independence gate. Complete `ASM-0072-response-template.md`. Do not open `ASM-0070`, `ASM-0071`, this lesson's complete answers or product-company model after starting. Record all help. Keep shared, employer, production and online cloud systems out of scope.

### Reviewer rubric

| Criterion | Points | Observable evidence |
|---|---:|---|
| Independence, authorization and evidence integrity | 10 | unseen case, declared help, authorized disposable scope, sanitized raw evidence and no answer leakage or fabrication |
| Record, schema and time mental model | 10 | precise event boundaries, fields, types, units, versions, severity, clocks and correlation |
| Architecture and boundary conservation | 10 | source-to-decision ownership plus accepted, rejected, queued, dropped, duplicate and late reconciliation |
| Hypothesis and diagnostic quality | 10 | at least five ranked falsifiable hypotheses tested at discriminating boundaries |
| Framing, parsing and query correction | 10 | multiline, schema, mapping, missing-data and dashboard contracts corrected and tested |
| Delivery, backpressure and capacity | 10 | delivery semantics, queue policy, outage buffer, drain rate, retention and uncertainty |
| Security, privacy and integrity | 10 | minimization, sanitation, injection control, least privilege, audit, integrity, retention and exposure response |
| Safe rollout, recovery and cleanup | 10 | canary, abort, rollback, separate user/monitoring recovery and exact final absence |
| Reliability and operational ownership | 10 | coverage/freshness objectives, alerts, owners, runbook actions and evidence preservation |
| Communication and proof limits | 10 | clear interview response and at least twelve technically specific non-claims |

Passing a score does not automatically update mastery. Independent review, a changed delayed transfer and authorized learner-ledger update remain required.

## References and review

The draft stores fifteen versioned primary or official reference records:

- `REF-0199` and `REF-0200`: OpenTelemetry logs data model and logging specification;
- `REF-0201`: explicitly non-normative format-mapping appendix;
- `REF-0202` and `REF-0203`: Elastic Common Schema and log fields;
- `REF-0204` and `REF-0205`: Elastic ingest troubleshooting and data streams;
- `REF-0206`: Splunk configuration and pipeline phases;
- `REF-0207` and `REF-0208`: systemd journal fields and `journalctl`;
- `REF-0209` and `REF-0210`: Python logging API and cookbook;
- `REF-0211`: OWASP logging security guidance;
- `REF-0212`: RFC 5424 syslog;
- `REF-0213`: Python JSON serialization/deserialization behavior.

Review before promotion:

- current OpenTelemetry log data model, API/SDK and Collector stability;
- exact systemd/journald behavior on Ubuntu 24.04 and WSL;
- supported Elastic and Splunk versions, licensing and security posture;
- exact collector/backend artifacts, signatures, provenance and vulnerabilities;
- parser, mapping, routing, query and lifecycle configuration;
- retry, queue, duplicate, drop, dead-letter and recovery semantics;
- field/access/retention/deletion controls and legal/security review;
- lab normal-user lifecycle, adversarial cleanup and final absence;
- reader, accessibility, privacy, performance and formal instructional review.

| Review | Purpose |
|---|---|
| Before direct draft validation | schemas, duplicate keys, exact headings, command risk, assessment isolation, rubric parity and references |
| Before runtime work | immutable artifacts, licenses, configuration, identity, ports, network, resources, retention, security and rollback |
| Before canonical promotion | Ubuntu lifecycle, representative runtime, relationships, generated registries, reader, tests, build, routes, browser and formal review |
| Every six months | official specifications, product versions, commands, defaults, field schemas, security guidance and references |
| After relevant release or advisory | compatibility, migrations, vulnerabilities, licenses, rollback and proof limits |

Evidence boundary: this is mentor-authored curriculum. Reading it or running its deterministic model does not prove the learner can operate a production logging pipeline, use a vendor product, protect real sensitive data, complete an unseen case, retain the skill, pass an interview or hold a mastery level.
