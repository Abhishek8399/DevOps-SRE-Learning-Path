---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0026",
  "slug": "observability-foundations",
  "aliases": ["V04-L01", "observability-foundations"],
  "curriculumIds": ["OBS-001"],
  "route": "/book/reliability/observability-foundations",
  "order": 1,
  "volume": "04-reliability-operations",
  "title": "Observability foundations: turn telemetry into trustworthy operational evidence",
  "summary": "Learn how metrics, logs, traces, events, and profiles become evidence; how instrumentation, clocks, context, collectors, queues, sampling, cardinality, retention, privacy, and cost can distort that evidence; and how an operator moves from a user symptom to a bounded, testable explanation without confusing a dashboard with reality.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0008"],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "Local command cards use procfs, coreutils, Bash, and Python 3 without network access."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "Process, clock, and journal visibility can differ from a full Linux host and must be stated."},
    {"platform": "systemd journal", "version": "system-provided", "support": "supported", "notes": "The journal command has an explicit no-journal or insufficient-visibility branch."},
    {"platform": "OpenTelemetry", "version": "reviewed 2026-08-02", "support": "concept-only", "notes": "No SDK, Collector, or backend is installed or executed by this lesson."},
    {"platform": "Prometheus", "version": "reviewed 2026-08-02", "support": "concept-only", "notes": "Metric semantics are taught without requiring a Prometheus server."}
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "observability-engineer",
    "software-engineer-on-call",
    "technical-lead",
    "incident-commander"
  ],
  "learningObjectives": [
    "Separate the real system, emitted telemetry, collection pipeline, stored representation, query, visualization, alert, and human decision into distinct evidence boundaries.",
    "Define metrics, logs, traces, events, and profiles by the questions each can and cannot answer alone.",
    "Explain instrumentation as an intentional measurement contract rather than a magical product property.",
    "Distinguish wall time from monotonic duration and reason about skew, precision, ordering, and propagation delay.",
    "Use stable context to join evidence without claiming correlation proves causation.",
    "Trace telemetry through receivers, processors, queues, exporters, networks, and storage, identifying loss, duplication, delay, reordering, and backpressure.",
    "Calculate label-set cardinality and redesign telemetry before unbounded dimensions exhaust capacity.",
    "Explain head, tail, probabilistic, and deterministic sampling and what sampled evidence cannot prove.",
    "Choose retention and aggregation using operational value, incident horizon, legal needs, privacy exposure, and cost.",
    "Apply RED, USE, and golden signals as question prompts rather than rigid dashboard templates.",
    "Design dashboards and queries that preserve scope, denominator, distribution, cohort, freshness, and missing-data meaning.",
    "Recognize telemetry gaps and transition safely toward OpenTelemetry, Prometheus, structured logging, and SLO-based operations."
  ],
  "productionSignals": [
    "user-visible success and failure rate at a named service boundary",
    "request rate with explicit operation, protocol, and status scope",
    "latency distribution with units, buckets, and observation window",
    "resource utilization and saturation with a named capacity limit",
    "structured error events carrying bounded service and operation context",
    "trace coverage, propagation continuity, and representative sampling rate",
    "collector accepted, dropped, refused, retried, queued, and exported item counts",
    "telemetry arrival delay and last-successful-sample age",
    "active time-series count and label cardinality growth",
    "ingestion volume, storage growth, retention age, and query cost",
    "clock offset, timestamp rejection, and out-of-order sample counts",
    "dashboard, query, rule, instrumentation, and schema change history"
  ],
  "diagrams": [
    {
      "id": "LES-0026-DIA-001",
      "title": "The evidence path from operation to decision",
      "direction": "left-to-right",
      "boundaries": ["real workload", "instrumentation", "collection", "transport", "storage", "query", "visualization and alert", "human decision"],
      "evidencePoints": ["emission count", "queue depth", "drop count", "ingest lag", "query scope", "data freshness"],
      "textAlternative": "A user operation crosses an application boundary. Instrumentation creates telemetry, a collector receives and processes it, transport and storage retain a representation, a query selects and aggregates it, and a dashboard or alert presents it to a human. Each arrow can lose, delay, duplicate, reorder, or transform evidence."
    },
    {
      "id": "LES-0026-DIA-002",
      "title": "Five complementary signal families",
      "direction": "hierarchical",
      "boundaries": ["metrics", "logs", "traces", "events", "profiles", "system behavior"],
      "evidencePoints": ["trend", "record detail", "request path", "state transition", "code cost"],
      "textAlternative": "System behavior sits at the center. Metrics summarize repeated observations, logs preserve contextual records, traces connect work across boundaries, events describe meaningful state changes, and profiles attribute resource consumption to code paths. No signal is the system itself and no signal answers every question."
    },
    {
      "id": "LES-0026-DIA-003",
      "title": "Context joins records but does not prove causality",
      "direction": "top-to-bottom",
      "boundaries": ["client", "gateway", "service", "queue", "worker", "database"],
      "evidencePoints": ["trace identifier", "span identifier", "request identifier", "operation", "tenant class", "deployment version"],
      "textAlternative": "A trace identifier can connect client, gateway, service, queue, worker, and database records. Parent-child span identifiers express reported relationships. Shared identifiers make a join possible, but timing, control flow, and counterfactual evidence are still needed before claiming causation."
    },
    {
      "id": "LES-0026-DIA-004",
      "title": "Telemetry pipeline pressure and loss boundaries",
      "direction": "cyclic",
      "boundaries": ["producer buffer", "receiver", "processor", "export queue", "network", "backend ingest"],
      "evidencePoints": ["accepted", "refused", "queued", "retried", "dropped", "exported"],
      "textAlternative": "Producers send telemetry to a receiver, processors transform it, an export queue absorbs temporary mismatch, and exporters cross the network to backend ingest. Slow consumers cause queue growth and retry feedback. A full finite queue forces refusal or dropping; an unbounded queue converts pressure into resource exhaustion."
    },
    {
      "id": "LES-0026-DIA-005",
      "title": "Cardinality multiplies across dimensions",
      "direction": "left-to-right",
      "boundaries": ["metric name", "label dimensions", "active series", "ingestion", "memory and storage", "query fan-out"],
      "evidencePoints": ["unique values per label", "active combinations", "churn", "samples per series", "retention"],
      "textAlternative": "A metric with method, route, status, region, instance, and customer labels creates one time series for each observed combination. The possible series count is the product of dimension sizes, bounded by combinations that occur. Request IDs and user IDs produce near one-series-per-request growth."
    },
    {
      "id": "LES-0026-DIA-006",
      "title": "Recovery proof ladder",
      "direction": "hierarchical",
      "boundaries": ["process", "dependency", "service objective", "representative user journey", "sustained observation window"],
      "evidencePoints": ["running", "reachable", "correct response", "healthy distribution", "no measurement gap", "no recurrence"],
      "textAlternative": "A running process is the lowest rung, then dependency reachability, correct service response, representative user-journey success, and sustained health across a meaningful window. Each rung adds evidence. One green process or successful request does not prove the higher rungs."
    }
  ],
  "commands": [
    {
      "id": "LES-0026-CMD-001",
      "question": "Which local tools needed by this lesson are available?",
      "risk": "read-only",
      "command": "for c in bash python3 date awk sed sort uniq wc head tail ps journalctl; do if command -v \"$c\" >/dev/null 2>&1; then printf 'present=%s path=%s\\n' \"$c\" \"$(command -v \"$c\")\"; else printf 'missing=%s\\n' \"$c\"; fi; done",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "all tools report present", "meaning": "the bounded examples can run locally", "nextEvidence": "continue with LES-0026-CMD-002"},
        {"when": "one or more tools report missing", "meaning": "that example is unavailable, not that the observed system is unhealthy", "nextEvidence": "use the conceptual decoder or install only through an approved local process"}
      ],
      "proves": "command discovery resolved an executable for each item marked present",
      "doesNotProve": "tool correctness, privilege, systemd availability, or any production state"
    },
    {
      "id": "LES-0026-CMD-002",
      "question": "What do wall-clock time and host uptime report now?",
      "risk": "read-only",
      "command": "printf 'wall_time='; date --iso-8601=ns; awk '{printf \"uptime_seconds=%s idle_seconds=%s\\n\", $1, $2}' /proc/uptime",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "both records print", "meaning": "the host exposes a civil timestamp and monotonic-since-boot counters", "nextEvidence": "compare semantics, not numeric origins"},
        {"when": "a read fails", "meaning": "the environment differs or access failed", "nextEvidence": "record the error and inspect the local environment before interpreting absence"}
      ],
      "proves": "the values returned by the local clock and procfs at this read",
      "doesNotProve": "clock synchronization, event ordering on another host, or application duration correctness"
    },
    {
      "id": "LES-0026-CMD-003",
      "question": "What cumulative CPU counters does Linux expose?",
      "risk": "read-only",
      "command": "awk 'NR==1 {print \"cpu_fields user nice system idle iowait irq softirq steal guest guest_nice\"; print \"cpu_values\", $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' /proc/stat",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "a cpu row prints", "meaning": "cumulative scheduler-accounting counters are available", "nextEvidence": "take a later sample and calculate deltas"},
        {"when": "fields are absent or differ", "meaning": "kernel or environment semantics differ", "nextEvidence": "read the installed procfs documentation before positional interpretation"}
      ],
      "proves": "one bounded read of aggregate cumulative CPU counters",
      "doesNotProve": "instantaneous utilization, a responsible process, or user-visible impact"
    },
    {
      "id": "LES-0026-CMD-004",
      "question": "What changed across a one-second CPU observation window?",
      "risk": "sampled-read-only",
      "command": "python3 -c \"import time; read=lambda:list(map(int,open('/proc/stat').readline().split()[1:9])); a=read(); time.sleep(1); b=read(); d=[y-x for x,y in zip(a,b)]; total=sum(d); idle=sum(d[3:5]); print(f'window_ticks={total} busy_ticks={total-idle} busy_percent={100*(total-idle)/total if total else 0:.2f}')\"",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "window_ticks is positive", "meaning": "two cumulative samples produced a bounded interval", "nextEvidence": "interpret busy_percent only for that host and window"},
        {"when": "window_ticks is zero or execution fails", "meaning": "the interval or source is unusable", "nextEvidence": "do not divide or infer load; validate the source and repeat deliberately"}
      ],
      "proves": "aggregate CPU-accounting change during approximately one local second",
      "doesNotProve": "root cause, per-process cost, saturation, or representative long-term behavior"
    },
    {
      "id": "LES-0026-CMD-005",
      "question": "Which bounded memory counters describe current host state?",
      "risk": "read-only",
      "command": "awk '/^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree|Dirty|Writeback):/ {print}' /proc/meminfo",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "MemAvailable remains substantial", "meaning": "the kernel estimates memory is available for new applications without swapping, including reclaimable cache", "nextEvidence": "check pressure and workload behavior before declaring health"},
        {"when": "MemAvailable is low or Dirty and Writeback grow", "meaning": "reclaim or writeback pressure may exist", "nextEvidence": "sample over time and correlate with latency and memory-pressure evidence"}
      ],
      "proves": "selected kernel memory counters at one read",
      "doesNotProve": "a leak, an out-of-memory event, application health, or future capacity"
    },
    {
      "id": "LES-0026-CMD-006",
      "question": "Which processes are visible and how are core process fields encoded?",
      "risk": "read-only",
      "command": "ps -eo pid,ppid,stat,etimes,comm --sort=-etimes | head -n 6",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "rows print", "meaning": "the caller can inspect visible process identity, parent, state, elapsed time, and command name", "nextEvidence": "select a relevant PID only after defining the incident question"},
        {"when": "expected processes are absent", "meaning": "namespace, permissions, lifecycle, or filters may hide them", "nextEvidence": "validate execution boundary rather than equating absence with termination"}
      ],
      "proves": "a bounded process-table view available to the current caller",
      "doesNotProve": "process correctness, resource ownership, container identity, or service health"
    },
    {
      "id": "LES-0026-CMD-007",
      "question": "Can the current environment expose five recent journal records?",
      "risk": "read-only",
      "command": "journalctl --no-pager -n 5 -o short-iso-precise",
      "runFrom": "any Ubuntu directory as a normal user; do not add sudo merely to make output appear",
      "expectedBranches": [
        {"when": "records print", "meaning": "the caller can read some current journal scope", "nextEvidence": "decode timestamp, host, process or unit, PID, and message"},
        {"when": "no entries, permission text, or no journal is returned", "meaning": "visibility or systemd availability is limited", "nextEvidence": "record the limitation; do not infer that no events occurred"}
      ],
      "proves": "only the bounded journal records visible to this caller at query time",
      "doesNotProve": "complete event history, absence of errors, correct retention, or causal ordering across hosts"
    },
    {
      "id": "LES-0026-CMD-008",
      "question": "How does a bounded structured-log stream become counts by operation and status?",
      "risk": "read-only",
      "command": "printf '%s\\n' 'op=checkout status=ok latency_ms=42' 'op=checkout status=error latency_ms=310' 'op=search status=ok latency_ms=18' | awk '{op=\"\"; st=\"\"; for(i=1;i<=NF;i++){split($i,a,\"=\"); if(a[1]==\"op\")op=a[2]; if(a[1]==\"status\")st=a[2]} key=op SUBSEP st; count[key]++; ops[key]=op; statuses[key]=st} END{for(k in count) printf \"op=%s status=%s count=%d\\n\",ops[k],statuses[k],count[k]}' | sort",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "three grouped counts appear", "meaning": "keys allowed deterministic aggregation", "nextEvidence": "compare the total grouped count with the three input records"},
        {"when": "parsing differs or a key is blank", "meaning": "the parser and record contract disagree", "nextEvidence": "inspect raw records before trusting the aggregate"}
      ],
      "proves": "the stated parser grouped the three supplied records",
      "doesNotProve": "production log completeness, stable schema, accurate timestamps, or service reliability"
    },
    {
      "id": "LES-0026-CMD-009",
      "question": "How quickly can metric label dimensions multiply into possible time series?",
      "risk": "read-only",
      "command": "python3 -c \"from math import prod; dims={'method':5,'route':80,'status':6,'region':4,'instance':50}; bounded=prod(dims.values()); observations=100000; print(*(f'{k}={v}' for k,v in dims.items())); print('bounded_cartesian_max=',bounded); print('modeled_observations=',observations); print('modeled_new_request_id_series=',observations); print('abstract_cartesian_schema_max=',bounded*observations)\"",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "bounded_cartesian_max prints 480000", "meaning": "the five bounded dimensions have a 480,000-combination schema ceiling", "nextEvidence": "measure which combinations are actually active"},
        {"when": "modeled_new_request_id_series prints 100000", "meaning": "100,000 one-label-set-per-request observations create 100,000 new series in this model", "nextEvidence": "measure creation rate and churn, then remove request identity from metric labels"},
        {"when": "abstract_cartesian_schema_max prints 48000000000", "meaning": "48 billion is only the unconstrained schema ceiling if every request ID could combine with every bounded combination", "nextEvidence": "do not report this ceiling as the modeled observed series count"}
      ],
      "proves": "the supplied bounded ceiling, modeled one-series-per-observation count, and abstract unconstrained schema ceiling",
      "doesNotProve": "actual active combinations, backend limits, compression, retention, query fan-out, or billable cost"
    },
    {
      "id": "LES-0026-CMD-010",
      "question": "How can deterministic sampling keep the same identifiers across services?",
      "risk": "read-only",
      "command": "python3 -c \"import hashlib; ids=['trace-a','trace-b','trace-c','trace-d','trace-e']; rate=20; [(lambda n:print(t,'bucket=',n%100,'keep=',n%100<rate))(int(hashlib.sha256(t.encode()).hexdigest()[:8],16)) for t in ids]\"",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "the same ID always gets the same bucket", "meaning": "hash-based choice is stable across components sharing the rule", "nextEvidence": "record algorithm, seed or salt, threshold, and effective rate"},
        {"when": "few or no five-item examples are kept", "meaning": "small samples vary despite a 20 percent target", "nextEvidence": "evaluate a large representative population, not five IDs"}
      ],
      "proves": "deterministic decisions for five synthetic identifiers under one algorithm",
      "doesNotProve": "representativeness, unbiased errors, privacy, or end-to-end trace completeness"
    },
    {
      "id": "LES-0026-CMD-011",
      "question": "Why can an average hide a harmful latency tail?",
      "risk": "read-only",
      "command": "python3 -c \"xs=[10]*95+[1000]*5; xs.sort(); q=lambda p:xs[min(len(xs)-1,max(0,int(p*len(xs)+0.999999)-1))]; print('count=',len(xs),'mean_ms=',sum(xs)/len(xs),'p50_ms=',q(.50),'p95_ms=',q(.95),'p99_ms=',q(.99),'max_ms=',max(xs)); bounds=[10,50,100,500,1000]; print('cumulative_buckets=',[(b,sum(x<=b for x in xs)) for b in bounds])\"",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "mean is far below p99 and maximum", "meaning": "a minority tail is diluted by many fast observations", "nextEvidence": "retain a distribution and inspect user-relevant percentiles"},
        {"when": "p95 remains low while p99 is high", "meaning": "percentile choice changes which cohort is visible", "nextEvidence": "tie the chosen threshold to an explicit objective"}
      ],
      "proves": "summary statistics and cumulative bucket counts for exactly 100 synthetic observations",
      "doesNotProve": "a production percentile, bucket suitability, causation, or future latency"
    },
    {
      "id": "LES-0026-CMD-012",
      "question": "What can and cannot be learned by joining synthetic records on a trace identifier?",
      "risk": "read-only",
      "command": "python3 -c \"records=[('t1','gateway','ok',5),('t1','api','error',40),('t1','db','timeout',35),('t2','gateway','ok',4),('t2','api','ok',8)]; from collections import defaultdict; g=defaultdict(list); [g[t].append((s,st,ms)) for t,s,st,ms in records]; [print(t,'path=',v,'reported_total_ms=',sum(x[2] for x in v)) for t,v in sorted(g.items())]\"",
      "runFrom": "any Ubuntu directory as a normal user",
      "expectedBranches": [
        {"when": "t1 records appear together", "meaning": "a shared key permits a bounded join", "nextEvidence": "inspect parentage, timestamp semantics, missing spans, and actual control flow"},
        {"when": "reported durations sum to a value", "meaning": "arithmetic succeeded", "nextEvidence": "do not call the sum end-to-end latency because spans may overlap"}
      ],
      "proves": "records sharing each supplied identifier were grouped",
      "doesNotProve": "identity, authenticity, complete propagation, causal parentage, or end-to-end duration"
    }
  ],
  "labs": [
    {
      "id": "LES-0026-LAB-001",
      "title": "Build and interrogate a bounded local telemetry path",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with Bash, Python 3 standard library, coreutils, procfs, and the checked-in book/labs/LES-0026-observability-foundations materials",
      "timeMinutes": 150,
      "privilege": "Normal user only; no sudo, root, Docker socket, host service change, credential, or administrative API",
      "network": "No network access is required or permitted by the exercise",
      "changes": ["Setup creates one random exact private directory below /tmp plus a per-UID state directory and bounded JSON evidence", "The deterministic model creates guided and missing-signal artifacts for metrics, logs, traces, events, profiles, counters, cardinality, retention, privacy, and evidence limits", "No package, daemon, port, provider, production endpoint, credential, or system configuration is created or changed"],
      "abortConditions": ["The reviewed lab controller or sentinel is absent, has an unexpected digest, or resolves outside the canonical lesson lab directory", "Any step asks for sudo, a token, network access, package installation, Docker access, or a writable system path", "A proposed cleanup uses a wildcard, recursive deletion of an unresolved path, or a path outside the exact lab-owned directory"],
      "recovery": "Stop the producer and collector model, preserve non-sensitive status output, and use only the reviewed status and cleanup operations once the lab artifact exists. If path, owner, mode, or sentinel validation fails, preserve the directory and repair the invariant before cleanup; never delete by pattern.",
      "cleanupProof": "The reviewed verifier exercises dry-run non-mutation, exact allowlist cleanup, unexpected-child refusal, foreign-state preservation, replacement-race preservation, idempotent cleanup, and final state=absent with orphan_count=0. A pass proves the encoded local lifecycle only, not production behavior or learner mastery.",
      "path": "book/labs/LES-0026-observability-foundations"
    },
    {
      "id": "LES-0026-LAB-002",
      "title": "Design an evidence plan for a telemetry-gap incident",
      "mode": "independent",
      "environment": "Provider-free written and in-memory exercise on Ubuntu 24.04 or WSL 2 Ubuntu 24.04",
      "timeMinutes": 180,
      "privilege": "Normal user only; no backend administration, production access, credential, or service mutation",
      "network": "No network access is required or permitted",
      "changes": ["Only learner-authored answers in a separately chosen response location", "Optional copies of the synthetic Python commands operate in memory unless the learner deliberately records output", "No collector, backend, dashboard, alert, cloud resource, or production system is changed"],
      "abortConditions": ["A proposed test sends customer or secret data to a telemetry system", "A proposed validation mutates a production collector, retention rule, sampling policy, alert, or dashboard", "The learner cannot state scope, expected evidence, proof limit, abort threshold, and cleanup for a proposed command"],
      "recovery": "Stop before any out-of-scope action. Mark the answer as an untested proposal and replace it with read-only evidence or a disposable, explicitly authorized future experiment.",
      "cleanupProof": "A reviewer compares the chosen response location before and after and verifies no backend, service, or provider mutation was authorized. There is no automated answer grader or hidden production proof channel for this independent exercise.",
      "path": "book/labs/LES-0026-observability-foundations"
    }
  ],
  "incidents": [
    {
      "id": "LES-0026-INC-001",
      "signal": "An aggregate dashboard is green while one region, route, tenant class, or client journey is failing.",
      "firstThought": "Do not argue with the user report using an average. Confirm scope, denominator, distribution, cohort, freshness, and whether the failing path is represented.",
      "safePath": "Capture a representative operation; split success and latency by bounded dimensions; compare edge and service views; verify instrumentation, collection, ingest, and query freshness; repair the service or the measurement path separately; prove recovery for the affected cohort over a meaningful window.",
      "trap": "Adding an unbounded customer or request identifier as a metric label, widening the time window until the spike disappears, or declaring recovery from one global average."
    },
    {
      "id": "LES-0026-INC-002",
      "signal": "Active series, ingestion, memory, and query latency surge after a telemetry release while request traffic is stable.",
      "firstThought": "Suspect label cardinality or churn before scaling the backend. Find the new metric, label, unique-value rate, and deployment cohort.",
      "safePath": "Stop or limit the offending instrumentation rollout; preserve schema and series-count evidence; remove or bound request-like labels; move identities to logs or traces; canary the corrected schema; prove series creation and ingestion return toward baseline without losing required coverage.",
      "trap": "Increasing retention or backend capacity first, deleting all telemetry, or relabeling sensitive identifiers without considering privacy and query behavior."
    },
    {
      "id": "LES-0026-INC-003",
      "signal": "Application health appears normal but collector queues, retries, refused items, or dropped-item counters are rising and recent data is missing.",
      "firstThought": "Treat the telemetry pipeline as a finite production system. Missing evidence may be pipeline failure, not service health.",
      "safePath": "Freeze unrelated telemetry changes; compare emitted, accepted, processed, exported, ingested, and query-visible counts; inspect queue occupancy, consumer latency, retry age, limits, and backend response; reduce nonessential load or restore the bottleneck under an approved plan; verify freshness and loss counters across the full path.",
      "trap": "Making queues unbounded, retrying forever, interpreting an empty dashboard as zero, or restarting every collector before preserving loss and pressure evidence."
    },
    {
      "id": "LES-0026-INC-004",
      "signal": "Logs and spans for one request appear out of order or cannot be joined across hosts and asynchronous work.",
      "firstThought": "Separate event time, observed time, export time, ingest time, and query time. Check propagation and clock assumptions before constructing a causal story.",
      "safePath": "Validate trace-context format and hop-by-hop propagation; inspect parent and link relationships; compare host clock offset and monotonic local durations; account for buffering and batch delay; identify missing or sampled spans; state uncertainty; repair propagation or clock health and validate with a controlled request.",
      "trap": "Sorting wall-clock timestamps and calling that causal order, trusting a trace identifier as authentication, or adding durations from overlapping spans as end-to-end latency."
    }
  ],
  "assessmentIds": ["ASM-0061", "ASM-0062", "ASM-0063"],
  "referenceIds": ["REF-0164", "REF-0165", "REF-0166", "REF-0167", "REF-0168", "REF-0169", "REF-0170", "REF-0171", "REF-0172"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "No OpenTelemetry SDK or Collector, Prometheus server, log or trace backend, continuous profiler, Linux perf deployment, dashboard service, or alert manager was installed or executed while authoring this lesson. The canonical lab executed bounded deterministic Python cProfile call-count evidence, which does not prove production profiler behavior.",
    "OpenTelemetry events and profiles were evolving on the review date. Their maturity, data model, SDK coverage, and interoperability must be verified against current official documentation before production adoption.",
    "The command cards read local procfs and journal state or process fixed synthetic data. They do not reproduce a distributed service, backend semantics, collector failure, production load, customer traffic, or provider billing.",
    "The canonical lab verifier passed from `book/labs/LES-0026-observability-foundations` on Ubuntu 24.04 on 2026-08-02, including root refusal, thirteen restart boundaries, ownership-preservation checks, and final absence. That pass proves only the encoded local model and lifecycle, not production behavior, formal chapter acceptance, learner execution, or mastery.",
    "Journal visibility varies by init system, permissions, namespace, retention, boot, and WSL configuration. Empty output cannot prove that no event occurred.",
    "Timestamps and correlation identifiers are reported evidence, not trusted identity, authentication, causal proof, or a total ordering across hosts.",
    "Cardinality, sampling, retention, and cost examples are deliberately small models. Actual limits, compression, pricing, query behavior, and privacy obligations depend on the selected systems and organization.",
    "The independent exercise has no automated answer grader or controlled production environment. A qualified reviewer must score transfer evidence; publication or reading progress does not award mastery."
  ]
}
---

# Observability foundations: turn telemetry into trustworthy operational evidence

## What you see and first thought

It is 02:13. A payment user reports, “Checkout spins for twenty seconds and then fails.” The service dashboard is green. CPU is 31 percent. The error-rate panel says 0.2 percent. The last visible error log is twenty minutes old. A trace search returns nothing for the request identifier.

The inexperienced response is, “Monitoring shows everything is healthy.” The experienced response is, “We have a user symptom and several measurement claims. Before trusting any of them, I need their scope, time, denominator, freshness, and path from emission to query.” That sentence is the doorway into observability.

Start with the user operation, not the favorite tool. Name the operation precisely: one checkout attempt, from a particular client class, through a particular edge and service path, during a bounded interval. Ask what success means at the user boundary. A process can be running while requests fail. A request can return HTTP 200 while its business operation is rejected. A global error rate can be low while one region or payment method is entirely broken. A trace can be absent because nothing was emitted, because context was lost, because sampling omitted it, because a collector dropped it, because retention expired it, or because the query is wrong.

Use this mental chain whenever evidence looks convenient:

```text
real operation
    |
    v
instrumentation emits a record
    |
    v
producer buffer -> collector receiver -> processor -> export queue
    |                                      |
    |                                      +-> filter / batch / sample / drop
    v
network -> backend ingest -> store or index -> query
                                              |
                                              v
                                     dashboard or alert
                                              |
                                              v
                                      operator decision
```

Every arrow is a boundary. At each boundary ask four questions: what entered, what left, what changed, and how would we know? A dashboard is the last rendering of a long evidence path. It is not a window directly into reality. It can be correct for its query and still irrelevant to the failing cohort. It can render stale data. It can convert missing values to zero. It can average away a tail. It can select only healthy instances. It can depend on telemetry that stopped flowing.

This does not mean “never trust dashboards.” It means trust them proportionally to the evidence behind them. A good dashboard accelerates reasoning because its scope, units, freshness, and provenance are clear. A bad dashboard merely makes an unsupported claim attractive.

### The first six moves

When a production symptom arrives, make these moves in order:

1. **Anchor the user impact.** What exact operation failed? For whom? From where? When did it start? Is the outcome wrong, slow, unavailable, or unsafe? Capture one non-sensitive correlation clue if policy allows it.
2. **Bound time with uncertainty.** Record the user-reported interval, local timezone, and possible clock error. Do not assume two machines agree merely because their timestamps have the same format.
3. **Check the outside boundary.** Use a safe representative probe or trusted user-journey signal. Internal resource panels are supporting evidence, not substitutes for the user outcome.
4. **Interrogate the measurement path.** Is data fresh? Are collectors accepting and exporting? Is ingest current? Does the query include the affected region, version, route, or client? How is missing data displayed?
5. **Compare independent signals.** A latency distribution, error event, dependency span, deployment event, and saturation signal that align are stronger than five panels derived from one broken exporter.
6. **State the smallest defensible claim.** Say “the query shows no matching stored traces for this identifier between 02:10 and 02:20” rather than “the request never happened.” The first statement is evidence. The second silently crosses several unproved boundaries.

### The recurring incident thought

Whenever you see **green aggregate, real complaint**, think: *cohort and denominator*. Split by a bounded dimension that represents a plausible failure boundary—region, operation, response class, dependency, deployment version, or client type. Do not put customer IDs or request IDs into metric labels just to find one user; that changes an incident into a cardinality incident. Use appropriately controlled logs or traces for high-detail identity.

Whenever you see **empty panel**, think: *zero, no event, or no evidence path?* Confirm whether the query language distinguishes an empty result from a numeric zero. Inspect last-sample age. Check collector acceptance, drops, export failures, ingest delay, retention, filters, sampling, and query selectors. “No data” is a branching point, never a diagnosis.

Whenever you see **high average latency**, think: *distribution and population*. An average can rise because every request became slightly slower or because a small cohort became catastrophically slow. Those require different actions. Ask for count, histogram boundaries, percentiles, maximum where meaningful, and cohort splits. Also ask whether timeouts are excluded from the latency population; a “fast” latency panel that omits failed requests can improve during an outage.

Whenever you see **a shared trace identifier**, think: *join key, not identity and not causality*. A header can be malformed, spoofed, duplicated, truncated, or not propagated. A trace graph reports instrumentation relationships. It does not authenticate the caller. Even a correctly joined sequence shows association and reported parentage; causal diagnosis still needs mechanism and evidence that alternative explanations do not fit.

Whenever you see **collector queue growth**, think: *producer-consumer mismatch with a finite budget*. Increasing the queue buys time; it does not create throughput. An unbounded queue postpones drops by consuming memory or disk until the collector itself fails. Track accepted, refused, processed, exported, retried, queued, and dropped items, plus the age of the oldest item. Protect the application first: telemetry should not be allowed to exhaust the service it measures.

The goal is not to memorize product screens. It is to build a durable evidence discipline. Products change. The mechanism remains: a system changes state; instrumentation observes a chosen part of that state; telemetry crosses lossy and transformative boundaries; a query constructs a view; a human decides. A strong SRE can point to every boundary, explain what each record proves, and say plainly what remains unknown.

## Terms before commands

Words matter because teams often use “monitoring,” “observability,” and “telemetry” as if they were interchangeable. They are connected, but they name different things.

**The system** is the real workload and its environment: clients, services, queues, kernels, networks, databases, configuration, people, and external dependencies. The system continues to behave even when every dashboard is broken.

**An observation** is a measurement or record about a selected property of the system. It is partial. Reading a CPU counter observes scheduler accounting; it does not directly observe checkout success.

**Instrumentation** is the code, configuration, probes, agents, or runtime hooks that decide what to observe and how to encode it. Instrumentation defines names, units, timestamps, attributes, boundaries, error classification, and context propagation. Automatic instrumentation reduces manual work, but it still makes choices. It cannot know every business success condition.

**Telemetry** is the emitted data: metric points, log records, spans, events, profiles, and their resource or context fields. Telemetry is evidence produced by an instrumented system; it is not the underlying state itself.

**Collection** is the path that receives, buffers, batches, enriches, filters, samples, retries, and exports telemetry. A collector may be an agent beside the workload, a gateway shared by many workloads, a library exporter, or several stages. Collection has its own health and capacity.

**A backend** ingests and stores or indexes telemetry and provides query behavior. Different backends make different consistency, retention, aggregation, indexing, and missing-data choices. A query result is a computation over the backend’s available representation, not a replay of perfect reality.

**Monitoring** is the deliberate use of observations to detect and communicate known conditions: an objective is being violated, a queue is nearing a limit, a certificate will expire, or a user journey fails. Monitoring asks predesigned questions continuously. It includes signals, queries, dashboards, alerts, ownership, and response.

**Observability** is the practical ability to investigate system behavior from available external evidence, including questions that were not fully anticipated. It is not a count of dashboards and not a product license. A system is more observable when an operator can distinguish plausible states, follow boundaries, and test explanations without unsafe guesswork. Rich data without stable semantics is not useful observability.

**Black-box monitoring** observes a system from a consumer boundary and judges externally visible behavior without depending on internal implementation state. A regional checkout probe asking whether TLS, HTTP, and the business assertion succeed is black-box evidence for that exact path. **White-box monitoring** uses internal knowledge and exported state—request counters, queue depth, pool wait, process memory, or collector drops—to explain what components report. Black-box evidence detects user symptoms that never reach application instrumentation; white-box evidence helps localize mechanisms. Neither is automatically complete.

**An SDK**, or software development kit, is a set of libraries and tools used by application code to create and export telemetry. An in-process telemetry SDK may own instruments, context, aggregation, buffers, sampling, and export scheduling, so its overhead and failure behavior are part of application design.

**eBPF**, extended Berkeley Packet Filter, is a Linux kernel facility that can run verified programs at supported kernel or application hooks and expose selected events with controlled maps and helpers. eBPF-based instrumentation can observe boundaries without editing application source, but permissions, kernel support, hook coverage, overhead, encryption, and business semantics limit what it proves.

**A cgroup**, or control group, is a Linux kernel mechanism for grouping processes so resources can be accounted, prioritized, and limited. Host memory can look available while a process group or container is near its cgroup memory limit; always name the resource boundary.

**Metric temporality** states how values relate across collection intervals. A cumulative stream reports values since a start or reset point; a delta stream reports change since the previous collection interval. Temporality is separate from instrument type. A counter can be exported cumulatively or as deltas, and producer, collector, and backend must agree or rates and resets become wrong.

**An SLI** is a defined service-level indicator for a user-relevant condition, and **an SLO** is its target over a window. The **error budget** is the unreliability permitted by that target: a 99.9 percent event-based SLO permits 0.1 percent of eligible events to be bad under its exact definition. **Burn rate** is the speed at which that budget is being consumed relative to spending it evenly across the SLO window. A high burn rate signals urgency, but only if the SLI denominator, window, freshness, and missing-data policy are trustworthy.

### Five signal families

**A metric** is a numeric observation associated with a name, time, and bounded set of dimensions. Metrics are efficient for trends, rates, thresholds, and aggregation across many events. They intentionally discard per-event detail. In a Prometheus-style model, a metric name plus one exact label set identifies a time series. Every distinct observed label combination creates another series.

Metric instruments have semantics:

- A **counter** accumulates occurrences or quantity and normally moves upward until its process restarts or the counter resets. Examples are completed requests, failed exports, or bytes sent. The raw total “1,284,901 requests” says little by itself. The change over a defined interval is useful. A rate is approximately `(later counter - earlier counter) / elapsed time`. Query systems must detect resets; treating a restart from 10,000 to 20 as a negative workload rate is wrong.
- A **gauge** represents a value that can rise or fall, such as queue depth, temperature, current connections, or configured capacity. Taking a rate of every gauge is not automatically meaningful. A gauge sampled every minute can miss a ten-second spike.
- A **histogram** counts observations into buckets and usually records total count and sum. It preserves a controlled approximation of a distribution. Classic histogram buckets can be summed only when boundaries, units, and observation semantics align. Compatible Prometheus native-histogram schemas can aggregate across resolutions under the deployed version's rules; that is not permission to combine incompatible schemas or meanings. Bucket or schema design remains an engineering decision.
- A **summary or precomputed quantile** may report values such as p95 from one process and window. Quantiles are order statistics: p99 is a value at or below which approximately 99 percent of observations fall under a declared method and window. Quantiles generally cannot be averaged to obtain a global quantile. Two instances with different traffic volumes and distributions make “average of p99” misleading.

An **average** is `sum / count`. It is useful, but it compresses shape. Ninety-five requests at 10 ms and five at 1,000 ms have a 59.5 ms mean. That mean describes none of the five harmed users and none of the common 10 ms experience. Always pair a mean with count and distribution when tails matter.

**A log record** is a timestamped contextual record produced for a meaningful occurrence. Structured logs encode named fields such as `service`, `operation`, `status`, `error_type`, `trace_id`, and `duration_ms`; free text relies on human phrasing and fragile parsing. Logs are strong for detailed explanation and rare-event context. They become weak when severity is inconsistent, schemas drift, timestamps are ambiguous, secrets leak, or high-volume debug records overwhelm retention. One error may generate records at the gateway, service, client, and retry layer; counting log lines is not automatically counting failures.

**A trace** represents related work across one operation. A **span** reports one timed operation with a trace identifier, its own span identifier, optional parent or link relationships, attributes, events, status, and resource identity. Traces help answer “where did this observed operation spend time?” and “which reported boundary returned an error?” They do not automatically capture work before context extraction, after context loss, inside uninstrumented code, or in a sampled-out branch. Spans can overlap, so summing all span durations usually overstates end-to-end duration.

**An event** records a meaningful state transition at a point in time: deployment started, leader changed, configuration loaded, circuit opened, autoscaler acted, or certificate rotated. Some systems model events as structured logs; some attach events to spans; some expose a separate event signal. OpenTelemetry event modeling was still evolving on the review date. Treat the concept as durable but verify current signal maturity and SDK behavior before choosing an implementation.

**A profile** statistically attributes resource consumption to code locations over an interval: CPU samples, allocated bytes, lock wait, or other supported events. Profiles answer “which code paths consumed this resource?” more directly than a host utilization metric. A sampled CPU profile is not a complete execution trace, and profiling overhead, kernel permissions, symbols, workload representativeness, and sampling frequency shape what appears. OpenTelemetry profile support was also evolving on the review date; verify current status rather than assuming universal interoperability.

These signals complement one another:

```text
question                                      strongest starting signal
Is the failure rate changing?                 metric trend with denominator
What did this component report for one case?  structured log record
Where did one operation cross boundaries?     trace with propagated context
What changed near the onset?                  deployment/configuration event
Which code path consumed CPU?                 representative profile
```

“Strongest starting signal” does not mean “sufficient proof.” A metric spike sends you toward a cohort; a trace proposes a path; logs reveal reported conditions; an event offers a temporal hypothesis; a profile locates cost. The explanation emerges when mechanism and independent evidence agree.

### Time is a field with provenance

**Wall-clock time** maps an instant to a civil timestamp such as `2026-08-02T02:13:04.123+05:30`. It is needed to compare records with calendars and other machines, but it can jump when synchronized or corrected. **Monotonic time** moves forward from an arbitrary local origin and is suitable for measuring duration on one running host or process. It cannot be compared directly between hosts and usually resets at reboot.

Do not say “the timestamp” when a telemetry path has several:

- **Event time**: when the instrumented producer says the event occurred.
- **Observed time**: when an observer or agent saw it, useful when the source timestamp is absent or suspect.
- **Export time**: when a batch left a producer or collector.
- **Ingest time**: when the backend accepted it.
- **Index or availability time**: when the backend made it queryable.
- **Query time**: when the operator requested and rendered the result.

Their differences expose buffering and delay. `ingest_time - event_time` may include producer buffering, clock offset, network delay, retry, and backend processing; it is not pure network latency. A record can appear after a later event because batches differ. Clock synchronization reduces uncertainty but never turns wall-clock sorting into a guaranteed distributed causal order.

**Context** is metadata carried with work: trace and span identifiers, operation name, resource identity, deployment version, tenant class, region, or request class. **Correlation** means evidence shares a joinable value or temporal relationship. **Causation** means a mechanism made an outcome occur. Correlation narrows a search; it does not complete it. Trace context is also not authentication. Never grant access or trust a caller because it supplied a plausible trace identifier.

**Cardinality** is the number of distinct values or combinations in a data set. For metrics, active-series cardinality grows with each observed label-set combination. **Churn** is creation and disappearance of series over time. Even if only 100,000 series are active at once, millions of short-lived request-ID series can punish indexes, memory, caches, storage, and queries.

**Sampling** keeps a subset of observations. Head sampling decides near the start, before the final outcome is known. Tail sampling waits for more of the trace, which can preserve errors or slow operations but requires buffering and a complete enough decision window. Probabilistic sampling chooses according to a target probability. Deterministic sampling hashes a stable key so cooperating services make consistent choices. Sampling rate is part of the evidence. A sampled trace can prove that the retained operation was reported; it cannot prove omitted operations behaved the same.

**Retention** is how long evidence remains queryable under a tier or policy. **Aggregation** reduces detail, often retaining long-term counts or distributions after raw records expire. **Redaction** removes or transforms sensitive content. These are not storage chores added later; they are measurement design. Keeping everything indefinitely increases exposure and cost. Keeping too little destroys the ability to investigate incidents discovered days later.

Finally, three operating heuristics organize questions:

- **RED** asks for request **Rate**, **Errors**, and **Duration** at a service boundary.
- **USE** asks for resource **Utilization**, **Saturation**, and **Errors** at each constrained resource.
- The **four golden signals** ask about **latency**, **traffic**, **errors**, and **saturation**.

They overlap because they are lenses, not competing religions. RED begins with service work; USE walks resource queues and limits; golden signals connect user symptoms and capacity. None defines business success for you. None excuses missing denominators, ambiguous units, stale data, or an unverified telemetry path.

## Architecture map

Observability architecture is easiest to understand as two coupled systems. The **workload plane** performs user work. The **telemetry plane** measures and transports selected evidence about that work. The telemetry plane must fail safely: losing evidence is serious, but an exporter must not consume all application memory, block request threads indefinitely, or expose customer data merely to preserve telemetry.

```text
WORKLOAD PLANE

client -> edge -> API -> queue -> worker -> database
            |       |       |        |          |
            +-------+-------+--------+----------+
                            instrumentation

TELEMETRY PLANE

SDK / agent / probe
        |
   local finite buffer
        |
 receiver -> processors -> export queue -> exporter
                 |                              |
          enrich/filter/batch                  network
                                                |
                                          backend ingest
                                                |
                                  store / index / aggregate
                                                |
                                      query / rule engine
                                                |
                              dashboard / alert / notebook
                                                |
                                        human or automation
```

The two planes share resources. An application SDK consumes CPU and memory. An agent reads host state. A collector uses sockets, buffers, and disk. A backend competes for storage and query capacity. Therefore, “observability is down” can be both an evidence problem and a production-risk problem. Design explicit resource limits and degradation behavior.

### Instrumentation boundary

Instrumentation begins with a semantic contract. For `checkout.completed`, define the operation boundary, what “completed” means, whether retries count as attempts or outcomes, the unit of duration, error classification, permitted dimensions, timestamp source, and versioning rules. Without this contract, teams can emit identically named metrics that count different things.

Library instrumentation sees code-level operations. Runtime or eBPF-style instrumentation may see calls without business meaning. Host agents see processes and resources. Synthetic probes see an external journey. Each viewpoint is valuable because each has a different blind spot. Automatic discovery cannot decide that an approved-but-not-settled payment is a business failure.

### Collection boundary

A **receiver** accepts a protocol and signal. A **processor** may batch, filter, transform, enrich, sample, limit memory, or route. An **exporter** translates and sends to a destination. In an agent deployment, collection sits close to each workload and can attach local resource identity. In a gateway deployment, many producers share centralized processing and policy. Real systems often combine them.

The path must account for backpressure. Let producers emit at rate `P` items per second and the downstream path sustain `C`. If `P > C`, backlog grows at roughly `P - C` until traffic falls or capacity changes. A queue of `Q` free slots buys approximately `Q / (P - C)` seconds under a steady mismatch. This arithmetic is a planning approximation, not a promise: item sizes, bursts, retry storms, and multiple signals change the result.

At capacity, the implementation must choose: block producers, refuse new items, drop old or new items, spill to bounded disk, reduce detail, or shed a priority class. Every choice has consequences. Blocking can harm the application. Dropping creates blind spots. Disk queues extend recovery but add I/O and corruption or privacy concerns. The safe design makes the policy visible through counters and protects higher-priority workload health.

### Backend and query boundary

Ingest validates and transforms incoming data. Storage may be append-only blocks, columnar segments, indexes, object storage, or several tiers. Metrics backends usually optimize label and time selection. Log backends may index selected fields and scan the rest. Trace backends may index summary fields while fetching complete traces from another store. Profiles may aggregate stack samples.

The backend decides when data becomes queryable, what late data does, how duplicates are treated, when raw detail expires, and whether queries read a consistent snapshot. A successful export acknowledgement can mean “accepted into an ingest queue,” not “durably stored and visible.” Write down acknowledgement semantics before using exported counts as proof of durable retention.

A **query** has a selector, time range, aggregation, grouping, join rules, and missing-data behavior. A **dashboard** adds variables, transformations, units, axes, refresh intervals, and visual defaults. An **alert rule** adds an evaluation interval, lookback, threshold, duration, missing-data policy, labels, routing, and inhibition. Each layer can change meaning.

For every critical panel or alert, be able to answer:

```text
Which user or resource boundary does it represent?
What exact numerator and denominator are used?
Which dimensions are selected or grouped away?
What units and timestamp semantics apply?
How late can data arrive?
How is an empty result rendered?
Which instrumentation and pipeline versions feed it?
Who owns the response and what safe action follows?
```

### Architecture is an evidence graph

Do not draw observability as “apps -> vendor.” Draw named boundaries and evidence points. Put emitted items before the buffer, accepted and refused items at the receiver, processed and dropped items after each transforming processor, queue occupancy and oldest age before export, success and failure at the exporter, ingest and rejection at the backend, and last-visible timestamps at query. Otherwise the most important question—*where did the evidence disappear?*—cannot be answered.

Independent paths matter. If application metrics, application logs, and traces all travel through the same collector, credential, network route, and backend, three empty screens are one failure mode, not three independent confirmations. A small outside-in probe or separate control-plane signal can reveal that shared blind spot.

## Request or state path

Follow one checkout operation. The purpose is not to produce the maximum number of records. It is to preserve enough context and semantics to answer bounded questions at every transition.

```text
1 client sends POST /checkout
2 edge accepts connection and routes request
3 API validates request and starts business operation
4 API writes work to queue
5 worker authorizes payment
6 worker writes durable order state
7 API or status channel reports outcome to client
```

At step 1, a client or edge can create a trace identifier. That identifier must be validated as untrusted input. Each service creates its own span identifier and reports a parent or link relationship where the model fits. An asynchronous queue often needs a **link** or explicit message context rather than pretending the worker’s span is a synchronous child in continuous call-stack time.

### Evidence at each operation boundary

At the edge, count accepted requests and classify responses from the client-visible perspective. Record duration with a monotonic clock inside one process. Keep route templates such as `/orders/{order_id}`, never raw paths containing an identifier as a metric label. A structured access log can retain an approved request or trace identifier for a limited period. The edge cannot prove the order was durably created merely because it sent HTTP 200.

At the API, distinguish attempts from completed business outcomes. Count validation rejection separately from dependency failure. Report a duration distribution. Attach bounded fields: operation, outcome class, deployment version, region, and perhaps caller class. Do not attach email, card data, authorization tokens, full URLs, raw payloads, or unbounded identifiers to metrics.

At the queue, observe publish attempts, accepted messages, rejection, age, depth, consumer lag, redelivery, dead-letter movement, and capacity. Queue depth is a gauge; published and consumed totals are counters; message age is a distribution or bounded maximum. A low depth can mean consumers are keeping up, producers stopped, data is missing, or messages are being dropped. Pair it with rates and error evidence.

At the worker, connect message context to a new span or linked trace, then report authorization and order-state outcomes. Retries require careful semantics. One business checkout can create three authorization attempts. A counter named `checkout_failures_total` is ambiguous if the first two attempts fail and the third succeeds. Prefer explicit `authorization_attempts_total{outcome=...}` plus a separately defined final business-outcome measure.

At the database boundary, measure operation class and result without recording raw statements that contain sensitive values. A client span can report elapsed time and timeout. Database-native telemetry can independently report lock wait, query class, connections, and saturation. A client timeout correlated with a server lock wait is a strong lead. It is not causal proof until scope and timing match and competing paths are excluded.

Finally, close the loop at the client-visible outcome. Reliability is experienced at boundaries. A completed internal span is weak recovery evidence if the user still receives a timeout. A synthetic journey is useful only if it represents the relevant route, authentication class, geography, dependency behavior, and business assertion.

### One operation, many times

Suppose an API records event time 02:13:00.100, exports at 02:13:02.000, the backend ingests at 02:13:03.200, indexes at 02:13:08.000, and an operator queries at 02:13:10.000. The record is about ten seconds old when seen. A dashboard evaluating “last five seconds” might omit it even though the operation happened. A later refresh may appear to rewrite history.

For duration inside the API, use a monotonic start and end. If the wall clock is corrected backward mid-request, subtracting civil timestamps could produce a negative duration. The emitted span may include wall-clock start for correlation and a duration measured monotonically. Across processes, you cannot subtract arbitrary monotonic clocks. Distributed critical-path reasoning uses reported span relationships, clock-error awareness, and backend correction heuristics; it is never made exact merely by displaying a waterfall.

### Correlation without overclaiming

A trace identifier should be random enough to avoid accidental collision and handled according to the tracing standard. It should be propagated only across intended trust boundaries, and sensitive baggage should not ride along casually. A request identifier used by an application may not be a trace identifier. If a message fans out, one input can legitimately lead to multiple linked operations. If messages batch, one worker span can relate to several producer contexts.

The evidence statement should sound like this: “These edge, API, and worker records report the same trace identifier; their span relationships and times are consistent with this path; the queue publish record is present; one expected consumer record is absent.” It should not sound like this: “The queue caused the failure because all records have the same trace ID.” Shared context established a join and located a gap. Mechanism still needs proof.

### Close the path with reconciliation

Counts at adjacent stages expose loss or semantic mismatch. Over a controlled window, compare API-enqueued outcomes, queue-accepted counts, worker-received counts, and final outcomes. Exact equality may be wrong when windows cut across in-flight work, retries duplicate delivery, batching delays export, or definitions differ. Reconciliation therefore declares a window, expected lag, retry semantics, and acceptable difference.

This is recurring operational wisdom: before making more dashboards, make the state path countable. If a team cannot say how one user operation becomes attempts, messages, retries, and outcomes, no observability product can repair the ambiguity afterward.

## Failure zoom

Zoom into four failure shapes. Each begins with a symptom and ends with a proof boundary, not a heroic command.

### Shape one: aggregate green, cohort red

The global checkout success rate is 99.9 percent, but all requests from one region fail. The global denominator is one million; the affected region contributes 500. Its complete failure adds only 0.05 percentage points globally. The panel is arithmetically correct and operationally misleading.

First split by existing bounded dimensions that correspond to architecture: region, route template, deployment version, dependency outcome, client class. Compare numerator and denominator. Confirm the failing region is not absent due to telemetry loss. Then trace one representative request and compare edge, API, and dependency evidence.

Do not add `customer_id` as a metric label. That creates unbounded time-series growth and may expose identity. Use logs or traces under access controls for individual correlation, while metrics preserve bounded cohorts. Recovery requires the affected cohort’s success and latency to remain healthy over a meaningful window, with pipeline freshness confirmed.

### Shape two: cardinality explosion

A release adds `request_id` and raw `path` to every request metric. Traffic is unchanged, but active series, ingestion bytes, memory, storage, and query time climb. Existing dashboards become slow, and the telemetry backend starts rejecting samples.

Think multiplicatively. If method has 5 values, templated route 80, status 6, region 4, and instance 50, the upper bound is `5 x 80 x 6 x 4 x 50 = 480,000` combinations for one metric. Actual active combinations may be lower. Add 100,000 new request identifiers per minute and the bounded model disappears. Series churn continues even after old requests go inactive.

The safe response is to stop or limit the instrumentation rollout, identify the metric and label responsible, preserve before-and-after schema evidence, and remove or transform the unbounded dimension. Keep route templates in metrics; put request identity in controlled logs or traces. Canary the new schema and verify series creation rate, active series, ingestion, and query latency. Scaling the backend can be a temporary containment measure, but it does not correct an unbounded data model.

### Shape three: collector pressure becomes a blind spot

The application appears healthy, but collector export latency and retries rise. Queue occupancy reaches 100 percent. Dropped-item counters increase. Dashboards show flat lines and then gaps.

The pipeline is a queueing system. Producers emit faster than the downstream consumer can sustain, or the consumer is temporarily unavailable. A finite queue absorbs a bounded burst. Once full, some implementation must refuse, drop, spill, or block. An unbounded queue is not reliability; it moves the failure into memory, disk, restart time, or privacy exposure.

Compare counts at each boundary: emitted if available, receiver accepted and refused, processor input and output, processor drops, queued, retried, exported, backend ingested, and query-visible. Also compare oldest-item age. Counters should be interpreted as deltas across a window and reset-aware. A collector restart can reset `dropped_total`; a naive negative rate is not miraculous recovery.

Contain safely. Preserve pipeline evidence. Reduce nonessential high-volume telemetry or restore the backend bottleneck according to an approved plan. Protect application resources. After export recovers, prove that queue age falls, drops stop increasing, ingest becomes fresh, and representative signals are queryable. You cannot reconstruct telemetry already dropped unless another independent source retained it.

### Shape four: time and context tell a false story

A trace waterfall shows the database span beginning before the API span. Logs from the worker appear earlier than queue publication. An operator concludes that the backend reordered requests.

First label the times. Were they producer event times, observer times, or ingest times? Are hosts synchronized, and what is the measured offset? Were records buffered or batched? Were durations measured monotonically? Are spans reported as parent-child, links, or merely joined by a search field? Is any expected span absent because of sampling or propagation loss?

Sort order in a UI is presentation, not causality. A wall clock can step. Backend ingestion can reorder late batches. Async work can overlap. A trace ID can be copied without correct parentage. Use local monotonic durations, declared context relationships, queue sequence or durable-state evidence where available, and clock-health signals. State uncertainty explicitly.

Repair the faulty clock, propagation, or query assumption one boundary at a time. Send a controlled non-sensitive operation and observe emission, collection, ingest, and query. Recovery means the known relationship is consistently represented within declared clock and pipeline uncertainty. It does not mean every historical record has become correctly ordered.

### The invariant across all four shapes

Never let absence travel across an unproved boundary. “No query result” means only that the query returned no stored matching result. It may originate in no real event, no instrumentation, failed emission, buffer eviction, filter, sampling, receiver refusal, processor drop, export failure, ingest rejection, retention, indexing delay, access control, wrong time range, wrong selector, or UI transformation. Walk backward until evidence closes the gap.

## Internals and state ownership

Observability becomes operationally reliable when every piece of state has an owner, a capacity model, and a recovery contract.

### Producer and SDK state

An in-process SDK owns instrument registration, aggregation state, context, buffers, export scheduling, and often retry behavior. A counter may live in memory and restart at process start. A histogram holds bucket counts until collection or cumulative export. A batching span processor holds completed spans awaiting export. If the process crashes before flush, buffered records may vanish.

The application team owns semantic correctness: operation names, business outcomes, error classification, units, allowed attributes, context boundaries, and instrumentation tests. The platform team may provide libraries and defaults, but it cannot infer every business contract. Shared conventions need versioning because renaming a metric or changing a unit can silently break queries and objectives.

Instrumentation also owns overhead. Measure added CPU, allocation, lock contention, payload size, and request-path blocking. Configure finite limits. Decide what happens when export is slow. For most services, preserving user work outranks preserving every debug span. That policy must be deliberate and visible, not discovered during an outage.

### Collector state

A collector owns receiver listeners, decoding, resource detection, processor state, batching, queues, exporter connections, retry schedules, credentials, and sometimes disk-backed persistence. A memory limiter may intentionally refuse or drop data to protect the process. A batch processor trades latency for efficiency. A tail sampler must retain trace fragments until it can decide, so incomplete traces, high arrival rate, and long decision windows consume memory.

Collector self-telemetry is part of the production design. For each signal and pipeline, observe accepted, refused, processed, filtered, sampled, dropped, queued, retried, exported, and failed counts; queue capacity and occupancy; oldest age; process CPU and memory; receiver and exporter latency; configuration identity; and restart count. Use distinct names for intentional filtering and resource-induced dropping. Otherwise a cost policy looks identical to data loss.

An agent owner handles node-local reachability and identity. A gateway owner handles shared capacity, tenancy, policy, and failure domains. When both exist, make ownership at the hop explicit. “Platform owns telemetry” is too vague during an incident in which the application exporter succeeds but the regional gateway rejects.

### Backend state

The backend owns ingest queues, validation, tenancy, indexes, blocks or segments, compaction, aggregation, retention, caches, query scheduling, and access control. Metric storage tracks series metadata and samples. Log indexing tracks selected fields and retained records. Trace storage may separate searchable attributes from full payloads. Profiles store stack identities and sample weights.

Backend capacity has several dimensions: items or bytes per second, active series, series churn, label-value count, index growth, stored bytes, retention, concurrent queries, scanned bytes, and tail latency. A traffic-flat cardinality explosion can be more damaging than a traffic spike because it stresses metadata and indexes. A broad regex query can overload a healthy ingest system. Separate ingest SLOs from query SLOs.

Retention ownership includes legal and privacy review. Logs and traces can contain identifiers, query parameters, database statements, headers, stack locals, and payload fragments. Redact near the source when possible, allowlist fields, restrict access, audit queries, encrypt transport and storage, and define deletion. Hashing is not automatic anonymization: a stable hash can remain linkable and may be reversible for small input domains.

### Query, dashboard, and alert state

Queries are code. They need review, tests against known fixtures, ownership, and change history. A rate query must declare reset behavior and observation window. An error ratio must use compatible numerator and denominator scopes. A percentile must state population and window. A join must state key uniqueness and missing-side behavior. A panel must expose units and freshness.

Dashboards own defaults that can alter meaning: selected environment, variable expansion, timezone, refresh interval, downsampling, gap filling, axis truncation, and transformations. Alerts add evaluation delay and state. If a rule evaluates every minute over a five-minute rate and requires ten minutes above threshold, detection time is not “one minute.” Late data and pending duration matter.

Alert ownership includes a human contract: actionable symptom, severity, receiver, runbook, safe first action, and resolution condition. An alert without an owner is stored noise. An alert on an internal cause may wake people when no user is harmed; an alert on a user symptom should page while diagnostic cause signals enrich the response.

### Schema, sampling, and policy ownership

Telemetry schema is an API. Establish naming, unit, type, attribute allowlists, cardinality budgets, stability level, deprecation, and version compatibility. Reject or quarantine invalid data deliberately. Changing a counter into a gauge under the same name corrupts historical interpretation. Changing seconds to milliseconds without changing metadata can create thousandfold alarms.

Sampling policy has an owner because it changes inference. Record effective rate by signal, service, tenant class, and outcome if policy varies. Head sampling is cheap but may omit rare failures. Tail sampling can prioritize errors but may bias latency and error analysis if the query assumes uniform selection. Preserve unsampled aggregate counters when trace sampling is used so population rates remain measurable.

Retention policy maps evidence value to time. Keep enough raw detail for the discovery and incident-review horizon; retain aggregates longer where useful; delete sensitive detail sooner where required. Capacity and cost owners should expose ingestion and storage by service and signal without turning chargeback into an incentive to disable critical evidence silently.

Ownership closes a common gap: the application owns meaning, the platform owns safe transport, backend teams own durable query behavior, service teams own decision use, and security and privacy owners govern data. Shared responsibility is not ownerless responsibility.

## Evidence table

Use the following table while investigating. “Can support” is intentionally weaker than “proves.” Every item assumes known scope and freshness.

| Evidence | Can support | Cannot prove alone | Check before trusting |
|---|---|---|---|
| Counter increase | occurrences or quantity accumulated in a scope | current rate, unique events, success, or cause | resets, duplicates, start value, labels, window |
| Gauge sample | reported value at one sample time | behavior between samples or future capacity | scrape interval, staleness, unit, missing-data rule |
| Histogram | approximate distribution over declared buckets | exact individual values or detail finer than buckets | boundaries, cumulative semantics, count, population |
| Quantile | estimated rank value for one population/window | global quantile by averaging instance quantiles | algorithm, error, window, count, sampling |
| Structured log | one component reported fields for one occurrence | objective truth, uniqueness, causal chain, completeness | schema, severity, time source, redaction, drops |
| Trace/span | reported work and relationships for retained context | authentication, full population, causal proof | sampling, propagation, missing spans, clock error |
| Event | reported state change near a time | that the change caused a symptom | source, event/ingest time, deployment scope |
| Profile | sampled resource attribution to code paths | full execution history or user impact | sample event, symbols, permissions, overhead, workload |
| Empty query | no stored result matched this query now | no event occurred or service is healthy | emission through query path, retention, access, selector |
| Green dashboard | query result met displayed thresholds | every cohort is healthy or data is fresh | denominator, grouping, gaps, last sample, source path |
| Collector export success | exporter received a success under its protocol | durable storage or query visibility | acknowledgement semantics, ingest lag, backend rejection |
| One successful probe | one operation succeeded from one vantage point | sustained recovery or all user paths healthy | representativeness, repetition, cohort, telemetry freshness |

### Build an evidence ledger

During an incident, maintain a short ledger with five columns: timestamp of observation, claim, source and query, proof limit, next discriminating evidence. For example:

```text
02:16 query: checkout errors in region=r2 = 100% over 5m
source: service counter rate, backend B, query version 7
proves: stored samples matching this selector form the stated ratio
does not prove: edge impact, cause, or completeness during collector loss
next: compare edge ratio and collector freshness for r2
```

This discipline prevents a screenshot from becoming folklore. It also makes handoff precise. Another engineer can reproduce the query and see what uncertainty remains. Record configuration or deployment events on the same ledger, but never place them in the causal column merely because they occurred first.

Choose the next signal by information gain. If two hypotheses predict the same CPU graph, more CPU panels do not distinguish them. If one predicts collector drops and the other predicts no application emission, receiver counters discriminate. If one predicts only region r2 and the other all regions, a bounded cohort split discriminates. Good observability reduces plausible states; it does not maximize bytes collected.

### Evidence independence

Two values are independent only to the extent that their failure paths differ. A log-derived metric and the underlying logs share instrumentation and collection. A dashboard and alert using the same query share everything except presentation. A host probe and a user synthetic may offer stronger independence, but they can still share DNS or network boundaries.

When severity is high, seek evidence from different vantage points: outside-in user outcome, service instrumentation, dependency-native state, operating-system resource state, telemetry-pipeline health, and change history. Agreement strengthens a hypothesis. Disagreement is valuable: it locates a boundary or exposes incompatible definitions.

## Command decoders

These commands are local teaching probes for Ubuntu 24.04. They are bounded and read-only or sampled-read-only. They do not install a backend, modify a service, or prove production behavior. Run a card only when its question is relevant. Preserve errors as evidence; do not add `sudo` just to force output.

### LES-0026-CMD-001 — preflight the local evidence tools

```bash
for c in bash python3 date awk sed sort uniq wc head tail ps journalctl; do if command -v "$c" >/dev/null 2>&1; then printf 'present=%s path=%s\n' "$c" "$(command -v "$c")"; else printf 'missing=%s\n' "$c"; fi; done
```

`command -v` asks the current shell how a name resolves. Redirection hides lookup noise; the explicit branch prints `present` or `missing`. `path` is the executable or shell resolution returned in this environment. A missing tool means the associated exercise is unavailable. It does not mean the host is unhealthy and does not authorize package installation. A present path proves resolution only—not version, correctness, permission, or systemd availability.

### LES-0026-CMD-002 — separate civil time from uptime

```bash
printf 'wall_time='; date --iso-8601=ns; awk '{printf "uptime_seconds=%s idle_seconds=%s\n", $1, $2}' /proc/uptime
```

`wall_time` is a timezone-bearing civil timestamp from the local system clock. `uptime_seconds` is elapsed monotonic-style time since boot as exposed by procfs. `idle_seconds` aggregates CPU idle time and can exceed uptime on multicore systems because several CPUs can be idle simultaneously. Do not subtract uptime from a timestamp on another host. This one read does not prove synchronization. For a distributed incident, also obtain approved clock-offset evidence and identify event, ingest, and query times.

### LES-0026-CMD-003 — read cumulative CPU accounting

```bash
awk 'NR==1 {print "cpu_fields user nice system idle iowait irq softirq steal guest guest_nice"; print "cpu_values", $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' /proc/stat
```

The first `cpu` row aggregates logical CPUs. Fields are cumulative scheduler ticks since boot: user work, lower-priority user work, kernel work, idle, I/O wait accounting, hardware interrupt work, software interrupt work, stolen virtual CPU time, and guest fields. Under current Linux `/proc/stat` accounting semantics, guest and guest-nice are already included in user and nice, so adding every displayed field would double-count them. Verify the running kernel's exact field semantics. One cumulative sample cannot reveal utilization or prove a responsible process, saturation, or user impact.

### LES-0026-CMD-004 — calculate a reset-local CPU interval

```bash
python3 -c "import time; read=lambda:list(map(int,open('/proc/stat').readline().split()[1:9])); a=read(); time.sleep(1); b=read(); d=[y-x for x,y in zip(a,b)]; total=sum(d); idle=sum(d[3:5]); print(f'window_ticks={total} busy_ticks={total-idle} busy_percent={100*(total-idle)/total if total else 0:.2f}')"
```

`a` and `b` are cumulative snapshots of the first eight counters, user through steal. Excluding guest and guest-nice prevents double-counting because they are included in user and nice. `d` contains per-field deltas. `window_ticks` is total accounted CPU time across logical CPUs during approximately one second; `busy_ticks` subtracts idle and I/O-wait fields under this teaching convention; `busy_percent` is their ratio. Different tools may classify I/O wait differently, so name the convention. The sleep defines a tiny, nonrepresentative window. A high result does not prove saturation: runnable-queue pressure, throttling, per-CPU imbalance, and user latency need separate evidence.

### LES-0026-CMD-005 — decode selected memory counters

```bash
awk '/^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree|Dirty|Writeback):/ {print}' /proc/meminfo
```

Values are normally in KiB as printed. `MemTotal` is usable physical memory known to the kernel. `MemFree` is entirely unused memory, which is intentionally often small on a healthy Linux host. `MemAvailable` estimates memory that can be supplied to new work without heavy swapping, considering reclaimable caches. `Buffers` and `Cached` describe kernel cache categories. `SwapTotal` and `SwapFree` bound configured swap. `Dirty` is memory awaiting writeback; `Writeback` is currently being written.

Do not diagnose a leak from low `MemFree`. Sample trends, inspect memory pressure, reclaim, swapping, cgroup limits, and responsible processes. Host `MemAvailable` can be healthy while a container is near its cgroup limit. This command proves only selected host counters visible at one read.

### LES-0026-CMD-006 — read a bounded process view

```bash
ps -eo pid,ppid,stat,etimes,comm --sort=-etimes | head -n 6
```

`PID` is the process identifier in the caller’s namespace. `PPID` is the visible parent. `STAT` begins with a process state such as running, sleeping, uninterruptible sleep, stopped, or zombie, followed by modifiers; consult the installed `ps` manual for the exact legend. `ETIMES` is elapsed whole seconds since start. `COMMAND` is a short executable name, not a trusted identity and not the full arguments. Sorting selects oldest visible processes, and `head` bounds output.

Absence can mean a different PID namespace, permission, lifecycle, or simply that the process is not among five rows. A running state does not prove useful service, correctness, readiness, or user success.

### LES-0026-CMD-007 — ask the journal a bounded question

```bash
journalctl --no-pager -n 5 -o short-iso-precise
```

`--no-pager` prevents an interactive pager. `-n 5` limits the returned tail. `-o short-iso-precise` requests precise ISO-style timestamps plus journal context. Depending on systemd version and record, output includes event timestamp, host, process or unit identity, PID, and message. The visible scope depends on boot, storage, namespace, filters, and permissions.

If WSL or another environment has no readable journal, preserve that result. Do not infer “no errors.” If entries appear, their timestamp is usually producer/journal event time, not export, index, or query time. A message is what a component reported; validate it against state and other signals.

### LES-0026-CMD-008 — aggregate three structured records

```bash
printf '%s\n' 'op=checkout status=ok latency_ms=42' 'op=checkout status=error latency_ms=310' 'op=search status=ok latency_ms=18' | awk '{op=""; st=""; for(i=1;i<=NF;i++){split($i,a,"="); if(a[1]=="op")op=a[2]; if(a[1]=="status")st=a[2]} key=op SUBSEP st; count[key]++; ops[key]=op; statuses[key]=st} END{for(k in count) printf "op=%s status=%s count=%d\n",ops[k],statuses[k],count[k]}' | sort
```

`printf` supplies exactly three synthetic records. The `awk` loop splits whitespace fields at `=`, extracts `op` and `status`, and joins them with AWK's internal `SUBSEP` only as an array key. Separate arrays preserve the readable field values, and `sort` makes the three output rows deterministic. Sum the displayed `count` values: they should reconcile to three. A blank field would reveal parser-schema disagreement.

This tiny exercise teaches why named fields beat prose for aggregation, but it also reveals fragility. Values containing spaces or `=` would break this simplistic parser. Real structured logging should use a defined encoder such as JSON, schema validation, safe escaping, and tested consumers. The result proves only grouping of supplied records, not completeness or production reliability.

### LES-0026-CMD-009 — calculate a cardinality upper bound

```bash
python3 -c "from math import prod; dims={'method':5,'route':80,'status':6,'region':4,'instance':50}; bounded=prod(dims.values()); observations=100000; print(*(f'{k}={v}' for k,v in dims.items())); print('bounded_cartesian_max=',bounded); print('modeled_observations=',observations); print('modeled_new_request_id_series=',observations); print('abstract_cartesian_schema_max=',bounded*observations)"
```

Each dictionary value is a hypothetical bounded dimension size. Their product, `bounded_cartesian_max=480000`, is the schema ceiling for those five dimensions; only combinations actually observed create series. The model then assumes 100,000 observations whose request IDs are unique and whose other labels form one label set per request, so `modeled_new_request_id_series=100000`. It separately prints `abstract_cartesian_schema_max=48000000000`: 48 billion is the mathematical ceiling if every request ID could combine independently with every bounded combination, not the modeled observed count.

The arithmetic does not predict actual active series or backend cost. Observed combinations, sample frequency, churn, compression, metadata layout, replicas, retention, and queries matter. Use the bounded and abstract ceilings to challenge schema design, but report measured series and creation rate from a canary. Put high-detail identity in access-controlled logs or traces.

### LES-0026-CMD-010 — model deterministic sampling

```bash
python3 -c "import hashlib; ids=['trace-a','trace-b','trace-c','trace-d','trace-e']; rate=20; [(lambda n:print(t,'bucket=',n%100,'keep=',n%100<rate))(int(hashlib.sha256(t.encode()).hexdigest()[:8],16)) for t in ids]"
```

SHA-256 maps each fixed synthetic identifier to a repeatable integer; modulo 100 creates a bucket; buckets below 20 are kept. Cooperating services using the exact same key, algorithm, salt policy, and threshold can make consistent decisions. Five items are too few to demonstrate a 20 percent population rate; zero or several may be retained.

Determinism preserves decision consistency, not representativeness. IDs may be nonuniform. Errors may correlate with identifiers or routes. Sampling can expose linkability and must not use secret values casually. Record effective rates and preserve unsampled aggregate counters so retained traces are not mistaken for the entire population.

### LES-0026-CMD-011 — expose the hidden tail

```bash
python3 -c "xs=[10]*95+[1000]*5; xs.sort(); q=lambda p:xs[min(len(xs)-1,max(0,int(p*len(xs)+0.999999)-1))]; print('count=',len(xs),'mean_ms=',sum(xs)/len(xs),'p50_ms=',q(.50),'p95_ms=',q(.95),'p99_ms=',q(.99),'max_ms=',max(xs)); bounds=[10,50,100,500,1000]; print('cumulative_buckets=',[(b,sum(x<=b for x in xs)) for b in bounds])"
```

`count` is the denominator. `mean_ms` is sum divided by count. `p50`, `p95`, and `p99` use a simple nearest-rank teaching function; production libraries can use different estimators and approximations. Here the 95th ordered observation is 10 ms and the 99th is 1,000 ms. Because five observations tie at 1,000 ms and none are above it, do not paraphrase this sample as “one percent exceeds or equals p99.” Generally, p99 places about 99 percent at or below the reported value and about 1 percent above, subject to ties and estimator rules.

This fixed population proves arithmetic only. Classic histograms require aligned boundaries and semantics; compatible native-histogram schemas may aggregate across resolutions under the deployed version's rules. Both require explicit units and inclusion rules for failures and timeouts.

### LES-0026-CMD-012 — join records without inventing causality

```bash
python3 -c "records=[('t1','gateway','ok',5),('t1','api','error',40),('t1','db','timeout',35),('t2','gateway','ok',4),('t2','api','ok',8)]; from collections import defaultdict; g=defaultdict(list); [g[t].append((s,st,ms)) for t,s,st,ms in records]; [print(t,'path=',v,'reported_total_ms=',sum(x[2] for x in v)) for t,v in sorted(g.items())]"
```

Each tuple is trace ID, component, reported status, and reported duration. The dictionary groups by trace ID. This proves a join on the supplied key. It does not prove that IDs are authentic, spans are complete, records are ordered, or the database caused the API error. `reported_total_ms` is intentionally dangerous: overlapping component work means summed durations need not equal end-to-end latency.

The next evidence would be parent or link relationships, wall-clock uncertainty, monotonic local durations, propagation coverage, missing-span policy, and component-native state. Correlation tells you where to look; mechanism tells you what to believe.

## Decision path

Use one decision tree when a panel, alert, trace search, or user report disagrees with another signal:

```text
Is there credible user or objective impact?
  |-- no/unknown -> validate outside-in signal and measurement freshness
  `-- yes
       |
       v
Can scope be bounded by operation, cohort, and time?
  |-- no -> improve symptom definition before broad mutation
  `-- yes
       |
       v
Is telemetry fresh and complete enough for this claim?
  |-- no/unknown -> walk emission through query; protect workload; restore evidence
  `-- yes
       |
       v
Which boundary first changes from expected to unexpected?
       |
       v
Collect one discriminating independent signal
       |
       v
Apply one reversible containment or correction
       |
       v
Prove affected journey + objective + pipeline freshness over time
```

### If the dashboard is green but users fail

Freeze the argument, not the system. Record the dashboard query, time range, variables, freshness, and screenshot only as context. Capture the affected operation, cohort, and user-visible outcome. Check whether the global denominator dilutes the cohort. Split only on bounded existing dimensions. Compare edge and internal boundaries. Validate that the affected cohort emits telemetry and survives collection.

If an outside-in journey fails while service metrics remain green, possible branches include missing route coverage, business failures classified as success, an edge failure before service instrumentation, stale service data, or a synthetic that uses a different path. Choose evidence that distinguishes these. Do not restart services because two screens disagree.

### If telemetry disappears

Begin at both ends. At the producer, is instrumentation registered and did emission counters change? At the query, is time, tenant, environment, service identity, and access correct? Walk inward:

```text
emitted?
  -> entered producer buffer?
  -> accepted by receiver?
  -> passed processors?
  -> queued?
  -> export acknowledged?
  -> backend ingested?
  -> indexed or stored?
  -> retained?
  -> matched query?
  -> rendered without gap filling?
```

At every step compare a counter delta or record ID under a bounded test. If the producer never emitted, fix instrumentation or the trigger. If the receiver refused, inspect protocol, limits, and identity. If a processor output is smaller, distinguish intentional filter or sampling from drop. If export succeeded but ingest did not, understand acknowledgement and tenant routing. If data is stored but the query misses it, test selector and event-time window.

### If the telemetry system is hurting the workload

Protect user work. Symptoms include exporter threads blocking, memory growth from queues, disk pressure from retry buffers, network saturation, collector CPU spikes, or backend queries exhausting shared resources. Confirm resource ownership and limits. Reduce nonessential debug volume or sampling detail under an approved policy; do not silently remove objective-critical signals. Bound queues rather than expanding them without a capacity equation. Separate collector failure domains. Capture what evidence becomes unavailable during containment.

Recovery has two axes: the workload no longer suffers, and required telemetry resumes within freshness and loss budgets. One without the other leaves risk.

### If a change is temporally correlated

A deployment, feature flag, collector configuration, schema, sampling, dashboard, or query change near onset is a strong hypothesis generator. Establish exact rollout scope and times, including clock uncertainty. Compare affected and unaffected cohorts. Identify a mechanism: for example, new label creates series churn, new filter removes error spans, new code changes business-success classification, or new exporter blocks request threads.

A rollback is both mitigation and experiment only if the relevant variable changes cleanly and observations are reliable. Recovery after rollback increases confidence but does not prove exclusivity; load or a dependency may also have changed. Preserve the hypothesis ledger and test prevention later.

### Dashboard and query questions

For rates, inspect the raw counter, reset handling, window, and grouping. Very short windows are noisy; very long windows hide onset. For ratios, confirm numerator is a subset of denominator with identical scope. For latency, confirm the distribution population includes failures and timeouts as intended. For gauges, inspect sample age and capacity limit. For joins, confirm key uniqueness and behavior when one side is missing.

Prefer panels that make disagreement visible: request count beside error ratio, quantiles beside histogram or objective threshold, utilization beside saturation and capacity, current value beside last-sample age, service outcomes beside collector loss. A dashboard should help an operator ask the next question; it should not impersonate a final diagnosis.

### Recovery proof

Climb the proof ladder. The process is running. Dependencies are reachable. A correct representative response succeeds. The affected cohort’s rate, error, and latency distribution recover. Resource saturation clears. Telemetry is fresh, and drops no longer increase. Health persists across a window long enough to cover previous recurrence, retries, queue drain, and alert evaluation.

Write the boundary: “Region r2 checkout success exceeded the objective for 30 minutes across both edge and service counters; representative journeys passed; collector queue age returned below 10 seconds; no new drops were recorded.” Do not write “dashboard green, resolved.”

## Guided Ubuntu lab

There are two learning modes. The first is the bounded local evidence model for `LES-0026-LAB-001`; the second is independent reasoning for `LES-0026-LAB-002`. The canonical runtime target is `book/labs/LES-0026-observability-foundations`. Inspect its `README.md`, `lab.sh`, controller, model, configuration, and verifier before running commands.

### Guided lab contract

The lab uses Bash and the Python 3 standard library on Ubuntu 24.04. It needs no network, container runtime, package installation, credential, port, daemon, or `sudo`. It creates a random owned root below `/tmp` and a per-UID state directory, validates types, modes, device and inode identity, and binds reviewed executable-source digests. Its deterministic model writes bounded evidence for metrics, logs, traces, events, a Python call-count profile, pipeline counters, cardinality, retention, privacy, manifests, and proof limits.

The controller refuses root execution, existing or foreign state, unregistered roots, unexpected children, changed source digests, unsafe types or modes, and identity changes at cleanup. Cleanup is nonrecursive and allowlisted. It quarantines a validated target name, rechecks the opened inode, preserves a cooperative replacement, and proves final absence. This narrows the modeled race surface; it does not claim filesystem-wide atomic deletion against every adversary.

Use this reviewed lifecycle from the canonical directory:

1. **[READ-ONLY]** Run `bash lab.sh check`. Continue only when it reports `state=absent` and `orphan_count=0`. A present state belongs to an earlier run or foreign object; inspect rather than overwrite it.
2. **[READ-ONLY]** Preview setup with `LAB_DRY_RUN=1 bash lab.sh setup`, then repeat **[READ-ONLY]** `bash lab.sh check`. The preview must report no mutation.
3. **[MUTATING]** Run `bash lab.sh setup`, then **[READ-ONLY]** `bash lab.sh status`. Setup creates only the registered, bound lab lifecycle described above.
4. **[MUTATING]** Run `bash lab.sh run guided`, then **[READ-ONLY]** `bash lab.sh inspect-signals guided`. The known fixture has eight requests; metrics aggregate them, logs retain redacted records, events mark changes and symptoms, and the profile exposes deterministic Python call counts. Each trace has three modeled spans: a `request.total` root plus sequential sibling phases `queue.wait` at offset zero and `service.handle` at `startOffsetMs=queue_ms`. They are not parent and child.
5. Pause and predict sequence order versus ingest order. Run **[READ-ONLY]** `bash lab.sh inspect-ordering`. It proves all eight fixture sequences are present while sequence 2 arrives later in ingest order; that demonstrates modeled reordering without loss. The fixture names its own injected delay, but production ordering alone would not prove buffering, retry, transport, collector pressure, or clock error.
6. **[MUTATING]** Run `bash lab.sh verify-guided`; verification writes bound evidence records. Read the proof limits: shared synthetic keys correlate records, but `correlation_is_causality=false` and `production_causality_proven=false` remain true.
7. **[MUTATING]** Run `bash lab.sh run missing-signal`, then **[READ-ONLY]** `bash lab.sh inspect-signals missing-signal`. Eight metric and log records but six exported trace rows establish only that two expected rows are absent; `cause_determined=false`. Pause and write a falsifiable hypothesis in private notes. Only then **[MUTATING]** record one allowed category with `bash lab.sh record-hypothesis delayed`; this writes a bound attempt record. The category is an example, not a scored answer. Allowed values are `not-produced`, `sampled`, `dropped`, `delayed`, `query-scope`, and `correlation-defect`.
8. Only after the attempt record, **[MUTATING]** run `bash lab.sh inspect-pipeline missing-signal`; the reveal writes bound records. Running it before `record-hypothesis` refuses with exit 64 and `pipeline-reveal-requires-hypothesis-attempt`. After the gate, fixture-bound evidence reports produced eight, exported six, dropped two, sequences 3 and 7, and modeled reason `export_queue_full`. Then **[MUTATING]** run `bash lab.sh verify-operation`; verification writes bound evidence records. These results explain the deterministic walkthrough only and do not prove W3C propagation, vendor behavior, production causality, or mastery.
9. **[READ-ONLY]** Preview cleanup with `LAB_DRY_RUN=1 bash lab.sh cleanup`, then run **[READ-ONLY]** `bash lab.sh status`. Next run **[DESTRUCTIVE: exact registered lab lifecycle only]** `bash lab.sh cleanup`, followed by the final **[READ-ONLY]** `bash lab.sh check`. Final evidence is `cleanup_proven=true`, `state=absent`, `orphan_count=0`, and `state_recovery_count=0`.

Maintainers additionally run `bash verify.sh`. It first validates that the canonical platform is Ubuntu 24.04, then checks Bash syntax, ShellCheck, Python AST parsing, JSON configuration, root guards, deterministic outputs, corrected sibling-span topology, the real event-time-versus-ingest-time ordering exercise, hypothesis-before-reveal, evidence bindings, dry-run non-mutation, pre-existing and concurrent-run preservation, unexpected-child refusal, cooperative replacement preservation, all thirteen durable interruption/resume boundaries, exact allowlisted restartable cleanup, and final absence. Do not claim that the verifier passed in your environment until its output says `verification_passed=true`.

The crucial observation is reconciliation. Suppose 100 operations are generated, the receiver accepts 100, a policy intentionally filters 10, a sampler keeps 20 of the remaining 90 for trace detail, and the exporter drops 2 after queue exhaustion. Different signals should not all show 18 without explanation. An unsampled request counter may still show 100; trace storage may show 18; a policy counter should show 10 filtered; sampler decision counters should show kept and omitted; drop counters should show 2. A trustworthy system explains the arithmetic.

### Questions to answer during the guided design

For every stage, write:

- What state does this component own?
- What is its finite capacity and unit?
- Which count enters and leaves?
- Which transformation is intentional?
- Which loss is unintentional?
- Which timestamp is present?
- How can a later query distinguish zero from missing?
- What does a successful acknowledgement mean?
- What exact cleanup proof is required?

If any answer is “the tool handles it,” the design is incomplete. The product may implement the mechanism, but the operator still needs its semantics.

### Independent lab: telemetry-gap incident design

For `LES-0026-LAB-002`, imagine this evidence at 09:05:

```text
user journey failures:       increasing in region r2
service request metric:      no samples after 09:01 in r2
service logs:                visible through 09:04, no matching errors
trace search:                no matching traces after 09:00
collector receiver accepted: increasing
collector export failures:   increasing
collector queue occupancy:   96%
backend ingest age:          4 minutes
deployment event:            service release at 08:58
collector config event:      exporter endpoint change at 09:00
```

Produce an evidence plan, not a guess. Rank at least three hypotheses. Separate user-service failure from telemetry-pipeline failure; both may exist. For each hypothesis, choose one read-only discriminating observation, expected branches, proof limit, and safe next step. Design a containment that protects user work and evidence. Define recovery at the user boundary and telemetry boundary. Explain why the nearby service deployment is not automatically causal and why the collector configuration change is not proven causal merely by timing.

### Lab proof boundary

The checked-in canonical lab has a reviewed interface and is colocated with this lesson. This text does not itself claim a learner run or maintainer pass. Preserve actual command output. Automated verification can prove encoded local invariants—deterministic counts, initial ambiguity, manifest binding, modeled export loss, refusal, and cleanup—not conceptual mastery, production safety, W3C trace-context compliance, collector or vendor behavior, causality, or interview readiness. Independent reasoning still requires qualified review.

## Production transfer

Moving from local concepts to production is not “install a collector everywhere.” Begin with a service-level evidence contract and a staged rollout.

### Stage one: name the user operation

Choose one critical journey. Define successful outcome, acceptable latency distribution, traffic unit, error classes, and scope. Map the architectural path and owners. Identify which current signals measure the outside boundary and which only measure internal causes. If success is ambiguous, resolve that before instrumenting.

### Stage two: design signal contracts

For metrics, select counters for attempts and outcomes, histograms for duration, gauges for real current state, and explicit capacity or saturation signals. Define units and allowed bounded attributes. Estimate cardinality before rollout. Preserve count and sum with histograms. Specify reset and staleness behavior.

For logs, define a structured schema, severity meaning, event and observed timestamps, service and deployment identity, operation, outcome, safe error classification, and optional trace context. Allowlist fields. Redact at source. Decide which events deserve records and which repeated conditions belong in metrics.

For traces, define service and operation naming, ingress extraction, egress injection, async links, error status, essential attributes, and sampling. Test broken propagation and uninstrumented dependencies. Treat incoming context as untrusted. For events, record deployments, configuration, feature flags, autoscaling, failovers, and operator changes with ownership. For profiles, define a bounded, authorized capture policy and sensitive-symbol handling.

### Stage three: adopt OpenTelemetry deliberately

OpenTelemetry provides vendor-neutral APIs, SDKs, semantic conventions, protocols, and a Collector ecosystem for several signals. Use it to reduce proprietary coupling, not to avoid design. On the reviewed date, traces, metrics, and logs were the mature center of adoption, while event and profile support was evolving. Verify current maturity and language-specific SDK behavior.

Start with one service and one operation. Pin compatible library versions. Decide resource identity centrally. Test emitted names, units, attributes, propagation, and exporter failure behavior. Deploy an agent or gateway topology based on failure domains and policy. Configure finite queues, memory protection, timeouts, retries, and self-telemetry. Canary under representative load. Confirm the application remains safe when the collector or backend is unavailable.

Do not dual-emit indefinitely without reconciliation. During migration, compare old and new counters over declared windows, accounting for scope and reset. Compare trace coverage and latency overhead. Record schema mapping and deprecation. A new pipeline is ready only when queries, alerts, retention, access, and incident ownership exist—not merely when data appears.

### Stage four: use Prometheus-style metrics safely

Prometheus teaches a durable pull-oriented metric model: metric name plus labels identifies a series; counters, gauges, histograms, and summaries carry semantics; query functions convert cumulative values into rates and distributions. Whether the exact backend is Prometheus, preserve those principles.

Expose bounded labels, stable units, and target identity. Scrape interval and timeout are part of resolution. Observe scrape success and sample age. A missing target is not zero traffic. Write recording rules for expensive stable expressions, but retain source semantics and test rule changes. For classic histograms, align bucket boundaries and semantics before aggregation. Compatible native-histogram schemas can aggregate across resolutions under current Prometheus rules; verify exact deployed-version behavior.

Avoid placing pod UID, raw URL, exception message, customer, email, request ID, session ID, SQL text, or arbitrary user input in labels. Some instance identity is naturally cardinal, but it still needs capacity and lifecycle planning. Aggregate away instance only when the question permits it; instance grouping can reveal one bad replica.

### Stage five: make logging a controlled evidence product

Replace ad hoc strings gradually. Define event names and fields. Include enough context to explain a decision without copying secrets or payloads. Use severity for operator significance, not developer emotion. Validate serialization and maximum size. Bound stack traces and repeated messages. Track dropped records and ingestion lag.

Set retention by value and sensitivity. High-volume debug logs may live briefly; security audit evidence may have separate controls; incident-critical structured outcomes may require a defined investigation horizon. Restrict query access and audit it. Test that redaction survives error paths, because exception handlers are common leak points.

### Stage six: connect signals to SLOs

An SLI measures a user-relevant condition. An SLO sets a target over a window. Observability supplies evidence, but an SLO is not “whatever metric already exists.” Define eligible events, good events, exclusions, time window, and missing-data policy. Preserve the raw numerator and denominator and monitor their collection path.

Use burn-rate alerts to identify when error budget is consumed too quickly across short and long windows. Page on credible user risk; use diagnostic alerts and dashboards for causes. If SLI telemetry disappears, that is not perfect reliability. Decide conservatively how unknown intervals are treated and alert on evidence freshness separately.

### Stage seven: rehearse failure and migration

In a safe environment, make exporters slow, reject records, break context propagation, reset counters, send out-of-order timestamps, create a bounded label spike, and query across retention boundaries. Confirm self-telemetry reveals each failure. Exercise rollback of instrumentation and collector configuration. Measure recovery time and permanent data loss.

Production transfer is complete only when service teams can answer user-impact questions, platform teams can operate the measurement path, security teams accept the data handling, and incident responders can distinguish service failure from telemetry failure under pressure.

## Reliability, security, observability, capacity, and cost

These concerns cannot be optimized independently. A decision that improves one can damage another. Use an explicit trade-off record.

### Reliability

The telemetry plane needs objectives for acceptance, export, freshness, query availability, and loss. Critical alerts need a path that does not share every dependency with the workload being watched. Collectors need bounded queues, failure isolation, controlled rollout, configuration validation, and rollback. Backends need ingest and query capacity, tested retention, backup or regeneration strategy where appropriate, and incident ownership.

But telemetry reliability is subordinate to workload safety. An in-process exporter that blocks forever can turn backend failure into user failure. A disk buffer that fills the application filesystem can create `ENOSPC`. A cardinality spike can harm a shared backend and blind unrelated teams. Set resource budgets and choose explicit shedding priorities.

### Security and privacy

Telemetry often crosses more trust boundaries than application data because it is copied to agents, gateways, backends, archives, notebooks, tickets, and chat. Minimize at emission. Allowlist attributes. Do not collect secrets “for debugging later.” Apply transport security, strong workload and collector identity, tenant isolation, least-privilege queries, audit, and retention deletion.

Trace context is not authorization. Baggage can propagate broadly and should not contain secrets or sensitive identity. Log injection can forge apparent lines or fields if untrusted input is not encoded safely. High-cardinality labels can become a denial-of-service vector. Query interfaces can leak across tenants or make expensive broad scans. Treat instrumentation and collector configuration as production code with review.

When incident responders need more detail, use time-bounded, approved diagnostic elevation with explicit scope, owner, expiry, and data handling. “Temporary debug logging” has a habit of becoming permanent exposure.

### Observability quality

Quality is the ability to answer important questions correctly and quickly, not ingestion volume. Measure coverage of critical operations, schema validity, context propagation, freshness, drop rate, query correctness, dashboard ownership, alert actionability, and incident outcomes. Track telemetry changes alongside service changes.

Unknown must remain visible. A gap should render as a gap with last-sample age, not a green zero. Sampling rates should travel with analysis. Filters should have counters. Derived signals should link to source definitions. Operators should be able to move from a high-level symptom to rawer evidence without losing time and scope.

### Capacity

Capacity begins with rates and sizes. A rough ingest estimate is:

```text
ingest_bytes_per_second
  = events_per_second x average_encoded_bytes x replication_or_overhead_factor

stored_bytes
  = ingest_bytes_per_second x retained_seconds x storage_efficiency_factor
```

These are estimates, not invoices. Compression, index metadata, replicas, compaction, object overhead, and tiering change them. Metrics need a series model: active series times samples per second plus series churn and metadata. Traces need spans per request times requests per second times sampling rate. Logs need events per request plus background events. Profiles need sampling frequency, stack size, target count, and duration.

Capacity also includes collector queue seconds, network egress, backend ingest partitions, index write rate, query concurrency, scanned bytes, cache behavior, and retention deletion throughput. Plan for burst and recovery: after a backend outage, live traffic plus retry backlog can exceed normal capacity and prolong the incident.

### Cost

Cost follows the entire lifecycle: instrumentation overhead, agent and collector compute, network transfer, ingest, indexing, hot storage, archive, query scan, dashboard refresh, support, and incident time. A low storage price can hide expensive indexing or egress. A high-cardinality label can increase both ingestion and query fan-out without adding decision value.

Optimize by value: remove duplicate low-value records; sample high-volume detail with known bias; retain aggregates longer than raw detail; route security and audit data under separate requirements; choose dashboard refresh rates deliberately; prevent broad expensive queries; and expose service-level usage. Never optimize by silently deleting the only user-outcome SLI.

### The trade-off review

Before a telemetry policy change, record:

| Question | Required answer |
|---|---|
| Reliability | What failure does this prevent, and what new blind spot appears? |
| Security | Which sensitive fields or trust boundaries change? |
| Observability | Which operational questions become easier or impossible? |
| Capacity | What are rate, burst, queue, cardinality, and retention effects? |
| Cost | Which lifecycle components change and who owns the budget? |
| Validation | What canary, reconciliation, rollback, and recovery proof will run? |

A sound design might keep unsampled counters for SLOs, sample most successful traces, retain all error traces within a privacy policy, retain raw logs briefly, preserve aggregates longer, and alert on collector loss. The exact answer varies. The explicit reasoning is non-negotiable.

## Traps and prevention

### Trap: “no data means zero”

Prevention: preserve empty results and staleness as separate states. Alert on last-successful-sample age and collection failure. Test dashboards with missing series. Teach responders to walk emission through query before clearing an incident.

### Trap: treating a dashboard as reality

Prevention: expose query, scope, units, denominator, grouping, source, and freshness. Review panels as code. Compare with a user boundary and at least one signal whose failure path differs.

### Trap: using an average for a tail-sensitive objective

Prevention: retain count and distribution. Choose histogram buckets around objectives. Inspect p50, p95, p99, maximum where meaningful, failures, and timeouts. Never average quantiles across instances as if that produced the global quantile.

### Trap: forgetting counter resets

Prevention: use reset-aware rate functions and a window appropriate to scrape interval. Examine process restart and target identity. Keep attempt and outcome definitions stable. A falling cumulative value normally indicates reset, replacement, or bad data—not negative requests.

### Trap: metric labels as a search index

Prevention: estimate Cartesian combinations and churn before rollout; enforce allowlists and budgets; alert on series creation. Use route templates and bounded classes. Put unique lookup keys in controlled logs or traces. Reject arbitrary user input in labels.

### Trap: sampling without inference rules

Prevention: publish policy, key, decision point, effective rate, and bias. Keep unsampled aggregate metrics for population claims. Tail sampling that retains errors is excellent for diagnosis but cannot serve as an unbiased error-rate denominator without weighting and policy knowledge.

### Trap: correlation as authentication or causality

Prevention: validate trace headers as untrusted data, enforce real authentication separately, and use parent or link semantics. Require timing, mechanism, scope, and discriminating evidence before a causal claim. Use “consistent with” when evidence is associative.

### Trap: wall-clock subtraction for local duration

Prevention: measure local elapsed time with a monotonic clock. Emit civil timestamps for correlation with explicit timezone and precision. Observe clock offset. Separate event, observed, export, ingest, index, and query times. Never compare monotonic values from different hosts.

### Trap: unbounded queues and retries

Prevention: calculate queue seconds, set memory and disk limits, expose oldest age, use backoff with bounded age or attempts, and define shedding priority. Test backend outage. Protect workload resources before telemetry completeness.

### Trap: treating export success as durable queryability

Prevention: document acknowledgement semantics. Observe backend ingest and rejection separately from exporter success. Measure event-to-query delay and last-visible timestamp. Reconcile representative records through storage and query.

### Trap: logging everything during an incident

Prevention: use approved time-bounded diagnostic elevation, field allowlists, redaction, sampling, rate limits, access control, and automatic expiry. Measure added load. Never print secrets, tokens, payloads, or personal data for convenience.

### Trap: alerts without a user action

Prevention: page on credible user risk or urgent objective consumption. Make cause signals diagnostic unless immediate action exists. Every page has an owner, safe first move, runbook, severity, missing-data policy, and recovery condition. Remove or redesign unactionable noise.

### Trap: one green request equals recovery

Prevention: use the recovery proof ladder. Validate affected cohort and business outcome, distribution and saturation, pipeline freshness, queue drain, and a sustained window. Check that the mitigation did not merely hide evidence.

### Prevention as tests

Encode important boundaries. Unit-test metric names, types, units, and labels. Contract-test log fields and redaction. Integration-test context through synchronous and asynchronous hops. Load-test instrumentation overhead and cardinality. Failure-test collector unavailability, queue exhaustion, retries, sampling, and late data. Query-test resets, empty series, timezones, cohorts, and histogram math. Review alert rules against fixtures. Rehearse rollback.

An observability review should reject “we will watch it” as a safety plan. Watching is useful only when the signal can distinguish failure, the path is healthy, an owner responds, and recovery can be proved.

## Memory card and retrieval

### The pocket model

```text
Reality is not telemetry.
Telemetry is not stored data.
Stored data is not a query result.
A query result is not a diagnosis.

operation -> emit -> buffer -> receive -> process -> queue -> export
          -> ingest -> store/index -> query -> dashboard/alert -> decision

At every arrow: count in, count out, transform, delay, loss, owner.
```

### Five signals in one sentence each

- **Metrics** efficiently summarize population change and distributions but discard individual detail.
- **Logs** retain contextual records but are reported claims that can be duplicated, dropped, malformed, or sensitive.
- **Traces** connect reported work across boundaries but depend on propagation and sampling and do not prove causality.
- **Events** mark meaningful changes but “before” does not mean “because.”
- **Profiles** attribute sampled resource consumption to code paths but do not show the full user journey.

### Metric memory

```text
counter -> cumulative, derive reset-aware change or rate
gauge -> current reported level, can rise or fall
histogram -> count observations in buckets, preserve distribution
quantile -> rank estimate for one population and window
average -> sum/count, may hide the tail

series identity = metric name + exact label set
possible combinations ~= product of dimension sizes
```

When tempted to add a label, ask: Is its value set bounded? Does it represent a decision-useful cohort? What is the combination and churn budget? Is it sensitive? Could a controlled log or trace field answer the unique lookup instead?

### Time memory

```text
wall clock: calendar correlation, can jump, compare with offset uncertainty
monotonic: local duration, arbitrary origin, never compare across hosts

event -> observed -> export -> ingest -> index -> query
```

The arrows are not guaranteed to be short or ordered across records. Measure delay by stage. Do not call event-to-ingest difference “network latency.”

### Missing-signal memory

Say: “No matching stored result was returned.” Then check:

```text
no event?
not instrumented?
not emitted?
buffered or evicted?
filtered?
sampled?
refused or dropped?
export failed?
ingest rejected or delayed?
retention expired?
access denied?
wrong time, tenant, selector, or UI transform?
```

### RED, USE, and golden signals

```text
RED: request Rate, Errors, Duration
USE: resource Utilization, Saturation, Errors
Golden: latency, traffic, errors, saturation
```

Begin outside-in with user success. Use RED to characterize service work. Use USE to walk constrained resources. Use change events, traces, logs, and profiles to discriminate causes. Return outside-in to prove recovery.

### Retrieval practice

Without looking back, draw the evidence path and name one failure at every arrow. Explain counter reset, histogram, and cardinality multiplication aloud. Given an empty trace search, list six non-service explanations. Given a trace ID, say why it is neither authentication nor causality. Given a green average, ask for denominator, distribution, cohort, and freshness.

Repeat after one day, one week, and one month. During a real incident review, map the actual evidence path and note where the team guessed. Durable expertise comes from retrieving and applying the model under different systems, not from rereading product terminology.

## Complete answers

### Question 1: What is the practical difference between monitoring and observability?

Monitoring continuously evaluates questions chosen in advance: Is checkout success below the objective? Is a queue nearing capacity? Did a certificate enter its renewal window? It combines telemetry, queries, rules, dashboards, alerts, owners, and response. Good monitoring detects known risk quickly.

Observability is the ability to distinguish and investigate system states from available external evidence, including an unfamiliar failure. It depends on meaningful instrumentation, context, signal coverage, a trustworthy collection and query path, and operators who reason about proof limits. It is not a vendor feature switch.

The two reinforce one another. Monitoring tells you that the checkout SLI is burning budget. Observability lets you split the affected cohort, follow representative work, compare dependency behavior, examine change events, and test whether queue saturation or telemetry loss explains the symptom. A system with no alerts can have rich telemetry but poor operations. A system with hundreds of static alerts can have monitoring noise and poor observability.

### Question 2: Why can “no telemetry” never be interpreted immediately as “nothing happened”?

Because the observation has crossed a chain of optional and lossy stages. The event may not have occurred, but it may also have occurred outside instrumentation, failed before emission, remained in a buffer, been filtered or sampled, been refused or dropped by a collector, failed export, been rejected or delayed at ingest, expired under retention, been hidden by access control, or missed a wrong query.

The safe statement stays at the known boundary: “This query returned no matching stored records for tenant T and event-time window W at query time Q.” Next, walk backward. Check query selectors and access, last-visible time, retention, backend ingest, exporter success, queue and drop counters, processor policy, receiver acceptance, producer emission, and an independent workload signal. Only when the path is closed can absence support a stronger claim.

### Question 3: How should counters, gauges, histograms, and quantiles be interpreted?

A counter accumulates a quantity and normally increases until reset. Its raw value is anchored to an arbitrary process lifetime. To understand current activity, calculate reset-aware change or rate across a declared window. Always name what one increment means. Retries can make attempt counters larger than business operations; duplicate instrumentation can double count.

A gauge reports a current value that can rise or fall, such as queue depth or active connections. Its sample is not a continuous recording. A brief spike between scrapes can disappear. Pair a queue-depth gauge with enqueue and dequeue rates, oldest age, capacity, and errors so low depth is not misread when producers have stopped.

A histogram retains a controlled distribution by counting observations in buckets, normally with total count and sum. Classic cumulative bucket `le="0.5" = 900` means 900 observations were no greater than 0.5 in the declared unit. Classic boundaries, units, and meanings must align before summing. Compatible native-histogram schemas may aggregate across resolutions under current Prometheus behavior, which must be verified for the deployed version. Neither form reveals more precision than its encoded resolution supports.

A quantile describes rank in one population and window. Under a stated estimator, p99 near 1 second means about 99 percent of the population is at or below that value and about 1 percent is above it. Discrete samples, ties, interpolation, and approximation can change the exact counts, so it never means every hundredth request or that values equal to the threshold belong to the upper tail. Instance quantiles generally cannot be averaged into a global quantile. Preserve count and population scope.

An average remains useful for capacity and total work, but it can hide minority harm. Use CMD-011’s population: ninety-five 10 ms requests and five 1,000 ms requests have a 59.5 ms mean. The mean is not the common experience or the tail. Ask the operational question first, then choose summary and distribution.

### Question 4: Why is cardinality a reliability problem rather than only a cost problem?

Every unique metric label set becomes a time series. Active-series metadata consumes memory. New-series churn stresses indexes, caches, write paths, compaction, and retention. Queries fan out across series and label values. A single unbounded label can make ingest reject data and make dashboards time out, hiding unrelated incidents on a shared backend.

Cardinality grows by combinations, not by counting labels. Five methods, eighty routes, six statuses, four regions, and fifty instances have a 480,000-combination upper bound per metric. Actual combinations may be lower, but a request ID or raw URL produces continuous new values and churn. Adding a second unbounded label makes the problem worse.

Prevent it at instrumentation. Use templated routes, outcome classes, bounded deployment versions, and meaningful resource identities. Estimate combinations and peak churn; canary; enforce per-tenant limits and label allowlists; observe top metric and label contributors. Put individual lookup keys in logs or traces with retention and access controls. Backend scaling may contain impact temporarily, but it does not turn an unbounded schema into a safe one.

### Question 5: What exactly does sampling change in an incident investigation?

Sampling changes which detailed observations survive. Head sampling decides before outcome, so a rare failure may be omitted. Tail sampling waits for trace information and can retain errors or slow operations, but it needs memory, a decision window, coherent routing, and policy. Probabilistic sampling approaches a target over a large suitable population. Deterministic hash sampling makes the same key receive the same decision across cooperating services.

A retained trace proves only what retained spans report. It cannot show that unretained requests behaved similarly. If tail policy keeps all errors and one percent of successes, the trace store’s error fraction is deliberately biased and cannot be used directly as service error rate. Use unsampled counters with a known denominator for population claims. Record sampling probability or effective policy where analysis needs weighting.

Sampling is not the same as loss. Intentional sampling has a defined policy and counters. Queue overflow is unplanned loss. Both produce missing detail, but operational meaning differs. A sound pipeline distinguishes received, intentionally omitted, and dropped items. It also verifies that trace fragments reach the decision point; otherwise “tail sampling” may keep incomplete traces.

### Question 6: How do clocks and timestamps mislead distributed debugging?

Wall clocks can differ between hosts, be corrected, or jump. Buffers and batch exporters make records arrive later and out of order. Backends may index late records after earlier queries. Therefore, sorting event timestamps is not a guaranteed causal order, and sorting ingest timestamps is merely arrival order.

Use a monotonic clock for duration within one process. Use timezone-bearing wall time for cross-system correlation, accompanied by clock-offset evidence and precision. Do not compare monotonic values across hosts. Label event time, observed time, export time, ingest time, index availability, and query time. Their differences contain several effects; for example, event-to-ingest includes source clock error, buffering, network, retry, and backend work.

Trace parentage and asynchronous links express reported relationships, but clock uncertainty can distort waterfalls. Queue sequence, partition offsets, database commit ordering, or application workflow state can offer domain-specific ordering. State the scope: a partition sequence does not globally order all partitions. When exact order cannot be proved, report intervals and uncertainty instead of inventing precision.

### Question 7: Why does trace context link evidence without proving identity or cause?

Trace context carries identifiers and flags so components can report related work. A receiving service can create a span with a parent reference; async work can use links. This makes a distributed evidence graph possible. It does not authenticate the sender. Headers can be supplied by an untrusted client, duplicated, malformed, or propagated across an unintended boundary. Authorization must use security identity and policy, never a trace ID.

Context also does not prove causality. Two records sharing a trace ID are correlated under the reporting system. A reported parent relationship adds structural evidence, but instrumentation can be incomplete or wrong. To claim that a database lock caused user latency, show a plausible mechanism, matching scope and timing, lock-wait evidence, request dependency behavior, and preferably a discriminating change or comparison. Say “consistent with” until the causal burden is met.

Protect context. Validate format, regenerate at trust boundaries when required, avoid secrets or sensitive baggage, and prevent cardinality by keeping IDs out of metric labels. Observe propagation coverage: the fraction of representative operations whose expected service boundaries share valid context. Missing propagation is both an observability gap and a clue, not proof that work did not occur.

### Question 8: How should a finite telemetry pipeline behave under backpressure?

It must protect the workload, expose degradation, and make loss policy explicit. Producers at rate `P` and consumers at sustained rate `C` create backlog when `P > C`. A queue buys finite time. Once full, the design blocks, refuses, drops, spills, or sheds a lower-priority class. None is free.

Blocking can extend request latency or deadlock an application. Refusal lets a producer decide, but retry can amplify load. Dropping loses evidence. Disk persistence survives longer outages but consumes I/O, storage, recovery time, and privacy budget. Unbounded queues eventually convert downstream failure into process or filesystem failure.

Instrument every boundary with reset-aware counts, queue occupancy and capacity, oldest age, retry age, and exporter/backend responses. Distinguish intentional filter and sampling from capacity drops. Use bounded backoff and jitter, and avoid infinite retry of data older than its value horizon. During containment, preserve objective-critical signals, reduce nonessential detail under policy, and record the blind spot. Recovery requires queue drain, fresh query-visible evidence, and stable workload health.

### Question 9: How should retention, cost, and privacy be decided together?

Begin with operational questions and discovery horizon. How long after an event are incidents typically discovered? Which raw detail is needed to investigate? Which aggregates support capacity and SLO history? Which security or audit records have separate obligations? Then classify sensitivity and access.

Estimate lifecycle cost: emission overhead, transport, ingest, index, storage tiers, replicas, compaction, query scan, egress, and human support. Keep high-value aggregates longer than raw detail when appropriate. Sample high-volume successful traces with known inference limits. Retain error detail only as privacy policy permits. Delete debug data quickly. Avoid duplicating identical records across systems without a use case.

Minimize at source. Allowlist fields, redact before export, encrypt, isolate tenants, audit access, and enforce deletion. Hashing does not automatically anonymize. A stable customer hash may remain personal and linkable. Longer retention increases both incident value and breach exposure. The approved policy should name owner, purpose, horizon, legal basis where applicable, and validation that deletion and redaction occur.

### Question 10: What makes a dashboard operationally trustworthy?

It begins at a named user or resource boundary. Each panel states question, selector, numerator, denominator, aggregation, dimensions, units, window, timestamp semantics, refresh, source, and freshness. Distribution panels retain count and objective thresholds. Missing data renders distinctly from zero. Cohort controls default safely and do not silently exclude the affected environment.

It includes telemetry-path health: last sample, scrape or receiver success, collector drops, ingest delay, and query errors. It places symptoms before causes: success, error, latency, and traffic before CPU or database internals. It links change events without presenting temporal correlation as proof. It has ownership, version history, and tested queries.

A dashboard is not trustworthy forever. Instrumentation, schemas, fleets, and objectives change. Review it after incidents and migrations. Remove panels that no longer answer a decision. Test counters through restart, gaps, late data, zero traffic, high cardinality, and partial cohorts. The proof is not beauty; it is whether an operator can make a correct bounded decision quickly.

## Product-company interview

Strong interviews test reasoning under ambiguity. Speak in boundaries and proof, not tool slogans. A useful structure is: clarify impact, map path, form ranked hypotheses, choose discriminating evidence, contain safely, prove recovery, and prevent recurrence.

### Scenario 1: “The dashboard is green, but customers complain. What do you do?”

Answer: “I trust the complaint as a symptom and treat the dashboard as one scoped query. I first define the failed operation, cohort, time, and user-visible success condition. Then I inspect the panel’s numerator, denominator, grouping, time window, freshness, and missing-data behavior. I compare an outside-in or edge signal with service evidence and split by bounded architecture dimensions such as region, route template, version, and status class.

“I also validate the measurement path: producer emission, collector acceptance and drops, ingest delay, and query scope. I select one representative request for controlled log or trace lookup without adding unique IDs to metric labels. Recent deployments are hypotheses, not causes. I contain the earliest proven failing boundary with a reversible action. I declare recovery only after the affected cohort’s business outcome and latency distribution stay healthy, telemetry is fresh, and the failure does not recur over a meaningful window.”

Why this is strong: it separates symptom from dashboard, protects cardinality, tests measurement, chooses bounded evidence, and closes recovery. A weak answer lists Grafana, Splunk, or Datadog screens without defining what they measure.

### Scenario 2: “How would you design observability for a new checkout service?”

Answer from the user boundary inward. Define eligible checkouts and successful business outcomes. Establish request attempts, final outcomes, and duration distribution with bounded attributes. Add queue acceptance, age, depth, capacity, redelivery, and dead-letter signals. Instrument dependencies with stable operation names and safe error classes. Add structured logs for decisions and failures, trace context across synchronous calls and async links, deployment and configuration events, and authorized profiles for resource questions.

Then design the telemetry path: finite SDK buffers, agent or gateway topology, receivers, processors, bounded queues, exporters, backend tenancy, retention, access, and self-telemetry. Estimate label combinations, bytes, trace rate, burst, and query load. Define sampling and retention with privacy. Build RED at service boundaries, USE for constrained resources, outside-in journey checks, SLI and SLO rules, burn alerts, and runbooks. Test schema, redaction, propagation, collector outage, counter resets, missing data, cardinality, rollback, and end-to-end freshness.

State trade-offs. “I would keep unsampled outcome counters for SLO math, retain distributions, sample successful traces under a known policy, preserve critical errors as allowed, and avoid request identity in metric labels. I would canary overhead and prove the application degrades safely if telemetry is unavailable.”

### Scenario 3: “A collector queue is full. Should we increase it?”

Answer: “Possibly as a short containment, but not before calculating the mismatch and resource risk. I need producer rate, sustainable consumer rate, current capacity and unit, occupancy, oldest age, retry behavior, item size, disk or memory budget, downstream response, and drop counters. If production exceeds consumption by 5,000 items per second, another 500,000 slots buy only about 100 seconds under steady assumptions.”

Then identify whether the cause is a burst, backend outage, network failure, expensive processor, cardinality or payload increase, or capacity regression. Protect the workload. Restore the bottleneck or reduce nonessential telemetry under approved priority. Bound retries. Expanding a queue can be useful to absorb an expected burst, but an unbounded queue converts loss into resource exhaustion and a larger recovery backlog.

Recovery evidence includes stable application latency, no new unplanned drops, falling occupancy and oldest age, successful ingest, fresh query results, and reconciliation of permanent loss. “Queue not full” alone can mean producers stopped.

### Scenario 4: “Why not put trace IDs in Prometheus labels?”

Answer: a time series is identified by its metric name and exact labels. Trace IDs are nearly unique per operation, so the system creates near one series per request instead of aggregating a bounded population. This drives series churn, metadata, memory, ingest, storage, and query fan-out. It may also expose a linkable identifier.

Metrics answer population questions using bounded dimensions. Logs and traces answer individual lookup questions under appropriate access and retention. If exemplars are supported in the chosen system, they may link selected metric observations to traces without turning every ID into a label; verify exact product semantics and sampling. The general design rule remains: unique identity is not a metric dimension.

### Scenario 5: “A trace proves the database caused latency, correct?”

Answer: “It is evidence consistent with that hypothesis, not automatic causal proof.” Check that the trace is complete enough, context propagated correctly, sampling policy is known, parent or link relationships fit the control flow, durations use valid clock semantics, and spans do not merely overlap. Compare database-native lock, query, connection, or saturation evidence; compare unaffected cohorts; inspect retries and client timeout; and test a reversible mitigation when safe.

A trace identifier is neither authentication nor causal authority. The strongest phrasing names the observation: “Retained requests in cohort C report database client spans occupying most of their critical path, and database-native lock wait rises in the same scope.” Then name the next discriminating evidence.

### Scenario 6: “How would you reduce observability cost by 40 percent?”

Do not begin with a global sampling percentage. Inventory cost and decision value by service, signal, field, series, index, retention tier, and query. Protect user-outcome SLIs, critical alerts, audit obligations, and incident-discovery horizon. Remove duplicate and unused telemetry; bound labels; stop indexing fields that are never searched; sample high-volume successful detail with documented bias; retain raw detail briefly and useful aggregates longer; reduce needless dashboard refresh and broad scans; route cold data to a suitable tier.

Canary each policy. Reconcile population counters, trace coverage, diagnostic success, ingest, storage, and query latency. Alert on telemetry loss. Review privacy because removing sensitive unused fields improves both cost and exposure. State what questions become impossible after reduction. A cost target met by destroying incident evidence is deferred operational cost, not efficiency.

### What the interviewer is listening for

They are listening for scope, semantics, systems thinking, safety, and intellectual honesty. Name the user boundary before infrastructure. Distinguish evidence from inference. Quantify rates, queues, distributions, and cardinality. Handle clocks and sampling. Protect security and workload health. Choose a reversible discriminating step. End with sustained proof and prevention.

If you do not know a product-specific default, say so and explain how you would verify it using the exact version’s official documentation and a bounded test. That is stronger than inventing certainty. Durable SRE judgment is the ability to operate safely when the screen is unfamiliar.

## Independent transfer and rubric

Complete this without copying the chapter. The objective is to transfer the evidence model to a system not used in the examples.

### Transfer scenario

At 14:20, a video-processing platform reports these facts:

```text
customer jobs completed per minute: down 35% globally
API accepted-job counter: normal
queue depth: low
worker CPU average: 28%
worker completion logs: no records for version v43 after 14:12
trace search for v43: sparse results, mostly successful
collector accepted spans: normal
collector processor filtered spans: up sharply
collector export errors: zero
backend ingest delay: 20 seconds
deployment v43: began 14:08 in one worker pool
sampling policy change: began 14:10 for all worker traces
```

Produce a one-page incident plan containing:

1. A precise impact claim and at least two uncertainties.
2. A workload path from job acceptance to durable completion.
3. A telemetry path from emission through dashboard.
4. Four ranked hypotheses, including at least one service hypothesis and one measurement hypothesis.
5. One discriminating read-only observation per hypothesis, with expected branches.
6. A safe containment that does not rely on an unproved cause.
7. A cardinality-safe evidence plan for version v43.
8. A statement about what sparse successful traces can and cannot prove under changed sampling.
9. A recovery definition covering user outcome, backlog, affected cohort, and telemetry freshness.
10. One prevention test and one policy or ownership change.

### Evidence contract and answer-isolation gate

This is a prompt, not a worked example. Do not publish or compare a scenario-specific diagnosis, ranked hypothesis list, containment, recovery answer, or prevention answer before independent submission. Once a learner has seen any solution to this case, it can be used for practice but not as unseen evidence for `ASM-0063`.

Before investigating, timestamp an evidence contract that states the operation, population, time, user-success definition, workload boundary, telemetry boundary, allowed evidence, unavailable evidence, one reversible action limit, abort conditions, cleanup proof, and what would invalidate independence. Label every later statement as observation, documented contract, calculation, inference, hypothesis, or unknown.

The submission is invalid if it uses the guided LES-0026 lab or its known missing-signal walkthrough, reuses this prompt after seeing an answer, touches an unowned or production target, captures no baseline, changes multiple causal variables, fabricates output, hides help, omits cleanup, or submits raw private identity or path data. `ASM-0063` instead requires an unseen disposable case supplied by an instructor or created and owned by the learner under explicit local authorization.

A qualified reviewer receives the sanitized evidence only after the attempt. The reviewer checks chronology, independence, authorization, raw-evidence integrity, alternative hypotheses, proof limits, safety, recovery, and cleanup against the rubric. The reviewer may request a fresh unseen case; neither reading completion nor a plausible narrative awards mastery.

### Scoring rubric

Score each dimension from 0 to 3. A total below 20 of 30 is not sufficient transfer. Any safety-critical zero prevents progression regardless of total.

| Dimension | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| Impact | repeats a dashboard | names a symptom only | bounds operation and time | bounds outcome, cohort, denominator, and uncertainty |
| Workload path | absent | generic components | key states present | ownership, retries, and durable boundary explicit |
| Telemetry path | treats dashboard as source | names collector | maps several stages | maps emission through query with loss evidence |
| Hypotheses | one cause asserted | several unranked guesses | service and telemetry branches | ranked, mechanism-based, independently testable |
| Evidence | broad commands | related but nondiscriminating | expected branches given | source, scope, branches, proof limit, and next step |
| Metrics math | absent or wrong | names RED/USE only | denominator and distribution | resets, cardinality, sampling, and missing data handled |
| Time/context | timestamp sorting as cause | mentions skew | distinguishes local duration | times, propagation, links, trust, and uncertainty handled |
| Safety | risky mutation or secret use | vague caution | bounded read-first path | reversible containment, abort, rollback, and privacy |
| Recovery | one green signal | internal health only | user outcome plus time | cohort, distribution, capacity, freshness, and recurrence |
| Prevention | “add monitoring” | generic alert | one concrete test | schema/pipeline failure test plus ownership and policy |

### Mastery evidence

Reading and self-scoring are not mastery. The guided LES-0026 lab teaches the mechanism but cannot satisfy independent transfer because its scenario and missing-signal answer are published. For `ASM-0063`, a qualified reviewer must assign or approve a fresh unseen disposable local case that the learner owns and is authorized to change. Present only sanitized evidence after the attempt, defend why each observation discriminates hypotheses, and explain what would change your mind. Repeat with another unseen architecture after a delay.

Mastery is demonstrated when you can identify a measurement failure while a service failure is also plausible, avoid unsafe certainty, quantify the relevant mechanism, choose minimal evidence, and close recovery at both user and telemetry boundaries.

## References and review

The reference identifiers below point to canonical registry records stored with this lesson. Official and primary sources are preferred because signal models and products evolve.

- **REF-0164 — OpenTelemetry Signals.** Vendor-neutral signal taxonomy for traces, metrics, logs, baggage, and developing event and profile concepts. It supports the five-family map, but current maturity must be rechecked because the documentation is living.
- **REF-0165 — Google SRE, Monitoring Distributed Systems.** Primary SRE treatment of black-box and white-box monitoring, symptoms and causes, actionable alerting, and latency, traffic, errors, and saturation. Principles are durable; examples come from the 2016 SRE book.
- **REF-0166 — W3C Trace Context Recommendation.** Normative baseline for `traceparent`, `tracestate`, propagation, validation, privacy, and security. It supports interoperable context; it does not turn trace identifiers into authentication or causal proof.
- **REF-0167 — Prometheus Metric Types.** Official semantics for counters, gauges, histograms, and summaries. Native histogram behavior and server support evolve, so exact production examples must be checked against the deployed version.
- **REF-0168 — systemd `journalctl` manual.** Primary command semantics for bounded, filtered, time-aware journal queries. Options and visibility are systemd-version and permission dependent; compare with the installed `man journalctl`.
- **REF-0169 — Linux Perf events and tool security.** Primary Linux kernel guidance for the data that `perf_events` can expose, the `CAP_PERFMON` and `perf_event_paranoid` access controls, and relevant file-descriptor and memory limits. It supports least-privilege profiling and scope-aware interpretation; it is not a complete `perf record` tutorial, and this chapter’s lab instead uses bounded Python call counts.
- **REF-0170 — OpenTelemetry Collector Architecture.** Official receiver, processor, exporter, pipeline, fan-out, and deployment-model concepts. Component maturity and exact configuration vary by Collector distribution and release.
- **REF-0171 — Azure Well-Architected observability guidance.** Primary architecture guidance on collection detail, storage and processing cost, retention, access, classification, and sensitive-data scrubbing. Its principles transfer; Azure-specific implementation guidance is not treated as provider-neutral fact.
- **REF-0172 — Linux kernel, The `/proc` Filesystem.** Primary kernel documentation for the procfs fields used by the Ubuntu command cards, including uptime and combined CPU idle accounting, `/proc/stat`, and `/proc/meminfo` fields such as `MemAvailable`, `Dirty`, and `Writeback`. Exact fields and accounting semantics remain kernel-version dependent.

### Review checklist

On or before `2027-02-02`, a reviewer should:

1. Verify current OpenTelemetry signal maturity, semantic conventions, context guidance, Collector pipeline behavior, and supported components.
2. Verify Prometheus metric and histogram semantics against the versions used by any examples or labs.
3. Compare procfs field semantics with REF-0172 and the running kernel, then compare the journal command with Ubuntu 24.04’s installed manual and test WSL’s no-journal branch.
4. Re-run schema and lesson-standard validation; confirm exactly 12 command records, 2 labs, 4 incidents, 6 diagrams, 3 assessments, and 9 references.
5. Run the canonical lab’s `bash verify.sh` as a normal Ubuntu user and preserve the actual result; do not convert an unrun design into a pass claim.
6. Recheck every command for bounded scope, units, environment assumptions, and explicit `proves` and `doesNotProve` statements.
7. Recheck privacy language, retention assumptions, and cost examples against current organizational and legal policy.
8. Have an independent reviewer score the transfer scenario and challenge at least one causal claim and one missing-data claim.

### Final proof boundary

This lesson teaches a reasoning system and supplies bounded local evidence. It does not prove that a particular production application is observable, that a provider retains every record, that a collector never loses data, that a sampled trace represents all requests, or that a learner can lead an incident. Product behavior requires exact-version tests. Production claims require source, scope, time, and independent evidence. Mastery requires successful guided execution, independently reviewed transfer, delayed retrieval, and safe performance in unfamiliar systems.

Keep the final sentence available during every incident: **the absence of visible evidence is a question about both the workload and the evidence path; walk the boundaries before you declare the cause.**
