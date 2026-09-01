---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0035",
  "slug": "capacity-performance-scaling",
  "aliases": ["V04-L10", "capacity-performance-scaling"],
  "curriculumIds": ["PERF-001"],
  "route": "/book/reliability/capacity-performance-scaling",
  "order": 10,
  "volume": "04-reliability-operations",
  "title": "Capacity and performance engineering: find the knee before users do",
  "summary": "Turn demand, service time, concurrency, queueing, percentiles, saturation, headroom and cost into safe capacity decisions, reproducible load tests, scaling controls and overload plans.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0003", "LES-0007", "LES-0026", "LES-0032", "LES-0033"],
  "prerequisiteCurriculumIds": ["LNX-003", "FND-001", "OBS-001", "SRE-002", "SRE-003"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The bounded model uses Bash and Python 3 as a normal user, creates one UID-scoped temporary directory, opens no port, sends no network request, and generates no sustained host load."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "The model is designed for WSL, but clock, filesystem, scheduler, CPU allocation, memory accounting and cleanup behavior must be observed rather than assumed."},
    {"platform": "Production, Kubernetes, cloud, database and data systems", "version": "concept-only", "support": "concept-only", "notes": "Commands and formulas teach transfer boundaries only. They do not authorize load tests, scaling, quota changes, traffic replay or cost commitments."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "performance-engineer", "production-engineer", "software-engineer", "systems-architect", "technical-lead"],
  "learningObjectives": [
    "Distinguish demand, throughput, service time, response time, concurrency, utilization, saturation, queue depth, queue age and headroom.",
    "Read distributions and percentiles without averaging away tails, population shifts, coordinated omission or dropped work.",
    "Use utilization, Little's Law and queueing intuition while stating stability, stationarity and measurement assumptions.",
    "Identify the bottleneck and system knee using user outcomes, resource demand, wait time, pressure, queue growth and errors.",
    "Design safe load, stress, spike, soak, breakpoint and scalability tests with representative data, aborts and recovery proof.",
    "Build a demand forecast from baseline, seasonality, events, growth, uncertainty, failure reserve and provisioning lead time.",
    "Compare vertical, horizontal, partition, cache, batch, asynchronous and demand-control scaling choices.",
    "Design autoscaling signals, targets, bounds, stabilization, readiness, warm-up, cooldown and failure behavior.",
    "Protect an overloaded service using admission control, bounded queues, load shedding, degradation, retry budgets and fairness.",
    "Defend a capacity plan through assumptions, sensitivity, cost, rollback, risk, evidence freshness and verification."
  ],
  "productionSignals": [
    "offered, accepted, rejected, completed and retried operations by journey, tenant, region, version and priority",
    "throughput, goodput, error, timeout, cancellation and abandonment with explicit population and interval",
    "latency histogram and p50, p90, p95, p99, p99.9 with sample count, bucket bounds and dropped-work coverage",
    "service time, wait time, end-to-end response time and queue age rather than one latency aggregate",
    "in-flight concurrency, worker occupancy, connection pools, thread pools, goroutines, event loops and admission tokens",
    "CPU demand, throttling, run queue, pressure stalls, memory working set, reclaim, OOM, I/O latency and network constraints",
    "queue arrivals, departures, depth, oldest age, capacity, priority, redrive, expiry and consumer lag",
    "replicas, ready capacity, placement, warm-up, startup, termination, disruption, autoscaler recommendation and actual action",
    "dependency quotas, latency, capacity, rate limits, retry amplification and failure reserve",
    "baseline, seasonality, event uplift, growth rate, uncertainty band, forecast horizon and provisioning lead time",
    "load-generator offered schedule, achieved load, client saturation, data realism, coordinated omission and abort state",
    "unit cost, marginal cost, idle reserve, reserved or committed capacity, budget and efficiency by useful operation"
  ],
  "diagrams": [
    {"id": "LES-0035-DIA-001", "title": "Demand-to-user outcome path", "direction": "left-to-right", "boundaries": ["offered demand", "admission", "queue", "service", "dependency", "completion", "user outcome"], "evidencePoints": ["offered rate", "accepted and shed", "age and depth", "service time and saturation", "quota and latency", "goodput", "journey SLI"], "textAlternative": "Demand is accepted or rejected, waits in a queue, consumes service and dependency capacity, completes or fails, and becomes a user outcome. Each boundary can limit goodput."},
    {"id": "LES-0035-DIA-002", "title": "Performance knee", "direction": "top-to-bottom", "boundaries": ["linear region", "contention begins", "knee", "unstable queue", "collapse"], "evidencePoints": ["throughput follows load", "tail rises", "maximum safe goodput", "arrival exceeds completion", "timeouts and retries"], "textAlternative": "As offered load rises, throughput initially tracks demand. Contention raises tail latency. At the knee, useful throughput stops scaling; beyond it queues grow and retries can cause collapse."},
    {"id": "LES-0035-DIA-003", "title": "Little's Law measurement triangle", "direction": "cyclic", "boundaries": ["average concurrency L", "throughput lambda", "average time W"], "evidencePoints": ["in-flight population", "completed rate", "time in system"], "textAlternative": "For a stable measured system over the same boundary and interval, average concurrency equals throughput multiplied by average time in system. Any two quantities estimate the third."},
    {"id": "LES-0035-DIA-004", "title": "Capacity forecast envelope", "direction": "top-to-bottom", "boundaries": ["baseline", "seasonality", "growth", "planned event", "uncertainty", "failure reserve", "required ready capacity"], "evidencePoints": ["recent peak", "calendar pattern", "trend model", "business input", "prediction interval", "N minus failure", "lead-time date"], "textAlternative": "A capacity requirement combines measured baseline, seasonality, growth and event uplift, then adds uncertainty and failure reserve before provisioning lead time expires."},
    {"id": "LES-0035-DIA-005", "title": "Autoscaling control loop", "direction": "cyclic", "boundaries": ["demand", "signal", "measurement delay", "decision", "provision", "warm-up", "ready capacity", "outcome"], "evidencePoints": ["arrival or queue age", "metric freshness", "controller interval", "desired replicas", "quota and scheduler", "readiness", "serving replicas", "latency and errors"], "textAlternative": "Demand changes a scaling signal. Delayed measurement drives a bounded controller decision. Provisioning and warm-up delay ready capacity, which changes user outcomes and the next signal."},
    {"id": "LES-0035-DIA-006", "title": "Safe performance test lifecycle", "direction": "left-to-right", "boundaries": ["question", "model", "environment", "calibration", "ramp", "abort", "recovery", "analysis"], "evidencePoints": ["decision hypothesis", "workload mix", "isolation and authorization", "generator headroom", "staged load", "safety thresholds", "state reconciliation", "reproducible report"], "textAlternative": "A performance test starts with a decision question and representative model, validates isolation and generator capacity, ramps gradually with aborts, proves recovery, and produces an assumption-bound report."}
  ],
  "commands": [
    {"id": "LES-0035-CMD-001", "question": "What identity, kernel, Ubuntu release, CPU allocation, clock and path define this observation?", "risk": "read-only", "command": "id; uname -a; cat /etc/os-release; nproc; date -u +%Y-%m-%dT%H:%M:%SZ; pwd", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "UID is non-root and values are plausible", "meaning": "observation context is recorded", "nextEvidence": "inspect CPU and memory boundaries"}, {"when": "UID is zero or context differs", "meaning": "the environment is outside the lab contract", "nextEvidence": "stop or record the difference"}], "proves": "self-reported local context at one instant", "doesNotProve": "dedicated capacity, stable clocks, production equivalence or performance"},
    {"id": "LES-0035-CMD-002", "question": "How many CPUs are visible and what scheduler/load evidence exists?", "risk": "read-only", "command": "nproc; lscpu; uptime; cat /proc/loadavg", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "load is small relative to visible CPUs", "meaning": "run-queue pressure may be low at this instant", "nextEvidence": "inspect service demand and pressure"}, {"when": "load is sustained above CPU capacity", "meaning": "runnable or uninterruptible work is accumulating", "nextEvidence": "separate CPU demand from I/O wait and cgroup limits"}], "proves": "reported topology and load samples", "doesNotProve": "bottleneck, service capacity, latency or future headroom"},
    {"id": "LES-0035-CMD-003", "question": "Are tasks stalled on CPU, memory or I/O?", "risk": "read-only", "command": "free -h; for f in /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io; do printf '%s\n' $f; cat $f; done", "runFrom": "a normal Ubuntu shell with PSI", "expectedBranches": [{"when": "some or full pressure rises", "meaning": "tasks lost runnable time to resource contention", "nextEvidence": "correlate deltas with workload and latency"}, {"when": "files are absent or pressure is low", "meaning": "kernel support differs or this sample shows little stall", "nextEvidence": "record support and use cgroup/service evidence"}], "proves": "kernel PSI counters and memory summary for the observed boundary", "doesNotProve": "cause, per-service attribution, absence of short spikes or safe capacity"},
    {"id": "LES-0035-CMD-004", "question": "What cgroup ceilings can make host headroom irrelevant?", "risk": "read-only", "command": "cat /proc/self/cgroup; test -r /sys/fs/cgroup/cpu.max && cat /sys/fs/cgroup/cpu.max; test -r /sys/fs/cgroup/memory.max && cat /sys/fs/cgroup/memory.max", "runFrom": "the target process namespace or representative shell", "expectedBranches": [{"when": "finite ceilings appear", "meaning": "the workload can saturate before the host", "nextEvidence": "compare demand, throttling and memory events inside that cgroup"}, {"when": "max or files differ", "meaning": "unlimited or another cgroup version/layout may apply", "nextEvidence": "map the actual hierarchy"}], "proves": "visible self-cgroup mapping and selected ceilings", "doesNotProve": "effective placement, throttling history, requests, application limit or capacity"},
    {"id": "LES-0035-CMD-005", "question": "Does the fictional capacity scenario satisfy its exact contract?", "risk": "read-only", "command": "python3 fixtures/capacity_model.py validate-scenario fixtures/scenario.json", "runFrom": "the LES-0035 support/lab directory", "expectedBranches": [{"when": "valid=true appears", "meaning": "units, populations, curves and forecasts satisfy model invariants", "nextEvidence": "run setup"}, {"when": "an error appears", "meaning": "the fixture cannot support conclusions", "nextEvidence": "preserve the first error and create no state"}], "proves": "only deterministic scenario conformance", "doesNotProve": "production realism, safe load, forecast accuracy or bottleneck truth"},
    {"id": "LES-0035-CMD-006", "question": "Can the lab create its exact private normal-user state?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "the LES-0035 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "state=ready appears", "meaning": "UID-scoped synthetic state validates", "nextEvidence": "run baseline"}, {"when": "refused=true appears", "meaning": "identity, ownership, path or fixture is unsafe", "nextEvidence": "preserve ambiguous state"}], "proves": "bounded state creation under wrapper checks", "doesNotProve": "performance, cleanup, capacity or mastery", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0035-CMD-007", "question": "Are offered load, accepted work and goodput being confused?", "risk": "mutating-bounded", "command": "bash lab.sh run baseline", "runFrom": "validated LES-0035 state", "expectedBranches": [{"when": "offered=1200 accepted=1100 goodput=1040 appears", "meaning": "admission, failure and useful completion are distinct", "nextEvidence": "inspect loss and latency populations"}, {"when": "counts differ", "meaning": "fixture or rules changed", "nextEvidence": "reconcile every operation state"}], "proves": "fictional operation accounting", "doesNotProve": "production demand or capacity", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0035-CMD-008", "question": "Where does useful throughput stop scaling and tail latency accelerate?", "risk": "mutating-bounded", "command": "bash lab.sh run curve", "runFrom": "validated LES-0035 state", "expectedBranches": [{"when": "kneeRps=900 and collapseRps=1200 appear", "meaning": "the encoded curve has a safe-region boundary and collapse region", "nextEvidence": "inspect bottleneck and abort threshold"}, {"when": "no knee appears", "meaning": "range may be too small or metric insensitive", "nextEvidence": "extend only in an authorized isolated test"}], "proves": "the knee selected by fixture rules", "doesNotProve": "production maximum, safe target or sole bottleneck", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0035-CMD-009", "question": "Do throughput, time and concurrency agree under Little's Law?", "risk": "mutating-bounded", "command": "bash lab.sh run queue", "runFrom": "validated LES-0035 state", "expectedBranches": [{"when": "estimatedConcurrency=180 observedConcurrency=184 appears", "meaning": "the stable-window values are approximately coherent", "nextEvidence": "state measurement and stationarity error"}, {"when": "gap is large", "meaning": "boundaries, averages, drops or stability assumptions differ", "nextEvidence": "do not force the formula; fix definitions"}], "proves": "arithmetic consistency for one fictional stable interval", "doesNotProve": "Poisson arrivals, causality, tail latency or future stability", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0035-CMD-010", "question": "What ready capacity is required before provisioning lead time expires?", "risk": "mutating-bounded", "command": "bash lab.sh run forecast", "runFrom": "validated LES-0035 state", "expectedBranches": [{"when": "requiredRps=1800 and requiredReplicas=12 appear", "meaning": "growth, event uplift, uncertainty and failure reserve were combined", "nextEvidence": "challenge assumptions and sensitivity"}, {"when": "requirement exceeds quota or budget", "meaning": "the plan is infeasible as written", "nextEvidence": "escalate early and redesign demand or architecture"}], "proves": "fixture forecast arithmetic and rounding", "doesNotProve": "future demand, cost approval, quota, provisioning or readiness", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0035-CMD-011", "question": "Will the autoscaler react before the queue violates its age objective?", "risk": "mutating-bounded", "command": "bash lab.sh run autoscale", "runFrom": "validated LES-0035 state", "expectedBranches": [{"when": "reactionSeconds=105 and safe=false appear", "meaning": "measurement, decision, provisioning and warm-up lag exceed the encoded buffer", "nextEvidence": "raise minimum ready capacity or use predictive/demand control"}, {"when": "safe=true appears", "meaning": "the modeled buffer covers the modeled delay", "nextEvidence": "test missing metrics, quota, oscillation and failure reserve"}], "proves": "control-loop timing for fictional values", "doesNotProve": "Kubernetes, cloud or production autoscaling behavior", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0035-CMD-012", "question": "Did every case and safety guard pass and leave no state?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "the LES-0035 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "checked fixture cases and cleanup passed", "nextEvidence": "preserve environment and proof limits"}, {"when": "an assertion or cleanup fails", "meaning": "the first failure is evidence", "nextEvidence": "stop and inspect guarded state"}], "proves": "checked-in deterministic lifecycle behavior for that run", "doesNotProve": "real performance, capacity, load safety, production transfer or mastery", "cleanup": "the verifier must prove exact absence"}
  ],
  "labs": [
    {"id": "LES-0035-LAB-001", "title": "Guided workload, knee, queue, forecast and autoscaling model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; offline deterministic data only", "timeMinutes": 180, "privilege": "normal user; wrapper and verifier refuse UID 0", "network": "none; no listener, target service, packet, provider or load generator", "changes": ["one UID-scoped private temporary directory", "owned scenario, manifest and one replaceable result"], "abortConditions": ["root", "ambiguous path or owner", "symlink or unexpected entry", "fixture validation failure", "cleanup refusal", "model output presented as real capacity"], "recovery": "Run status; clean only state that passes descriptor checks; preserve refused state.", "cleanupProof": "Validate parent, basename, real path, UID, sentinel, manifest and children; remove only that directory; prove absence.", "path": "drafts/LES-0035-capacity-performance-scaling/support/lab"},
    {"id": "LES-0035-LAB-002", "title": "Independent capacity plan and safe performance-test defense", "mode": "independent", "environment": "A reviewer-held materially different scenario with demand history, workload mix, resource data, latency distributions, dependency constraints, cost and failure reserve", "timeMinutes": 240, "privilege": "normal user; no production load, scaling, quota, traffic replay or spend authority", "network": "none unless an approved unseen harness explicitly permits bounded loopback", "changes": ["one sanitized analysis and test plan", "only declared unseen-case resources"], "abortConditions": ["answer access", "unclear authorization", "real customer data", "unbounded load", "missing abort or recovery proof", "unsupported forecast certainty"], "recovery": "Return to the last valid boundary and preserve uncertainty without revealing answers.", "cleanupProof": "Reviewer manifest proves all allowed unseen resources absent.", "path": "drafts/LES-0035-capacity-performance-scaling/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0035-INC-001", "signal": "CPU averages 45 percent while p99 latency and queue age explode.", "firstThought": "Average host CPU can hide one hot shard, throttled cgroup, lock, pool, dependency or I/O bottleneck.", "safePath": "Trace demand and wait by boundary; inspect per-instance distribution, pressure, throttling and queue age.", "trap": "Scale CPU blindly and leave the bottleneck unchanged."},
    {"id": "LES-0035-INC-002", "signal": "Load test reaches target RPS with good average latency, but production times out.", "firstThought": "The generator may omit burstiness, tails, data skew, retries, think time, failures or coordinated omission.", "safePath": "Validate offered load and population; compare distributions, mix, state, generator headroom and failure behavior.", "trap": "Treat achieved request count as workload realism."},
    {"id": "LES-0035-INC-003", "signal": "Autoscaling adds replicas only after queues exceed the user deadline.", "firstThought": "Signal and ready-capacity delay exceed the remaining buffer.", "safePath": "Measure every control-loop delay; raise minimum reserve, scale on leading demand, reduce warm-up or shed load.", "trap": "Increase max replicas when time, quota or readiness is the constraint."},
    {"id": "LES-0035-INC-004", "signal": "A forecast says twelve replicas, but one-zone failure leaves only eight ready.", "firstThought": "Nominal capacity was confused with failure-domain ready capacity.", "safePath": "Apply placement, disruption, maintenance, failover and dependency reserve before rounding.", "trap": "Call idle reserve waste without pricing availability risk."},
    {"id": "LES-0035-INC-005", "signal": "A soak test passes for two hours and the service fails after nine.", "firstThought": "Leak, compaction, rollover, cache churn, quota or background-cycle duration exceeded the test window.", "safePath": "Model time-dependent state, monitor slopes, run long enough for cycles and prove recovery.", "trap": "Extrapolate a short stable interval indefinitely."}
  ],
  "assessmentIds": ["ASM-0088", "ASM-0089", "ASM-0090"],
  "referenceIds": ["REF-0289", "REF-0290", "REF-0291", "REF-0292", "REF-0293", "REF-0294", "REF-0295", "REF-0296", "REF-0297", "REF-0298", "REF-0299", "REF-0300", "REF-0301", "REF-0302", "REF-0303"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": ["All load and capacity cases are fictional or bounded local models.", "No production load generation or capacity change is authorized.", "Forecasts remain conditional on assumptions and measurement validity.", "Autoscaling cannot replace overload protection or architecture review.", "Reading and automation do not establish mastery."]
}
---

# Capacity and performance engineering: find the knee before users do

## What you see and first thought

Traffic grows 30 percent, p99 latency doubles, and someone says, “CPU is only 45 percent; add replicas anyway.”

Your first thought should be: **which boundary limits useful work, where does waiting begin, and how close are we to the point where added demand creates queues faster than the system can drain them?**

Capacity is not the number of servers. It is the maximum useful workload a defined system can sustain while meeting correctness, latency, availability and recovery objectives under stated conditions.

```text
demand -> admission -> waiting -> service -> dependencies -> useful completion
             |            |          |
           shed          queue     resource demand
```

Start at the user operation. Count offered work, accepted work and successful useful completion separately. Then locate service time, waiting time, saturation and failure reserve. A quiet average can coexist with a burning tail.

Use this sequence: define workload and objectives; measure baseline and distributions; increase demand in controlled steps; find the knee and bottleneck; model growth, uncertainty and failure reserve; choose scaling plus overload protection; verify cost, recovery and user outcome.

Do not run an unapproved test against production. Read-only traffic still consumes CPU, pools, quotas, caches and human response capacity.

## Terms before commands

**Demand** or offered load is work arriving at a boundary: requests per second, jobs per minute, bytes per second or concurrent sessions. **Accepted load** passes admission. **Throughput** is completed work per time. **Goodput** is completed work that is correct, timely and useful. Retried, duplicated or late work can raise throughput without helping users.

**Service time** is active processing time at a component. **Wait time** is time queued for a resource. **Response time** is wait plus service across the chosen boundary. Always say which boundary.

**Concurrency** is work simultaneously in the system. A thread count is not automatically concurrency: blocked, idle and runnable work differ.

**Utilization** is busy fraction over an interval. **Saturation** means demand cannot receive immediate service and waits, rejects or loses work. CPU can be below 100 percent while a lock, one core, shard, connection pool, quota or dependency is saturated.

**Queue depth** counts waiting items. **Queue age** measures how long work waited. Age often maps more directly to a user deadline.

**Headroom** is usable capacity minus expected demand under a defined objective. **Failure reserve** is capacity retained for loss of a node, zone, dependency path or maintenance event.

A **percentile p99** is a value at or below which about 99 percent of observations fall for that population and window. It says nothing about the worst one percent, causality or another population. Averaging instance percentiles is generally invalid; aggregate distributions or histograms.

The **performance knee** is where added load causes disproportionate latency, queueing or errors and little extra goodput. Beyond a stable maximum, arrival rate exceeds departure rate and backlog grows.

**Little's Law** is `L = λW`: average items in a stable system equal average throughput times average time in system. Units and boundaries must match. At 600 completed requests/s and 0.3 s, expected average concurrency is 180.

**Scalability** describes response to resource or workload change. **Efficiency** asks useful output per resource or cost. Doubling replicas for 20 percent more goodput scales poorly.

A **load test** checks expected demand; **stress** explores beyond it; **spike** changes demand quickly; **soak** exposes time-dependent degradation; **breakpoint** finds objective loss or collapse.

**Coordinated omission** happens when a closed-loop generator waits for a slow response before sending later work, so it stops sampling periods when users would still arrive. Preserve the offered schedule.

## Architecture map

Capacity lives across a chain, not inside one graph:

```text
clients / jobs -> edge admission -> load balancer -> service replicas
                       |                                 |
                    shed                           CPU / memory
                                                         |
                                    pool / queue -> database / dependency
                                         |
                                   async queue -> consumers

metrics -> forecast or autoscaler -> scheduler/provider -> ready capacity
```

The data plane performs work. The control plane observes delayed signals and changes capacity. The business plane changes demand through launches, campaigns, tenants and schedules. The failure plane removes capacity through faults, disruption and maintenance.

Map ownership for every limit: client concurrency, edge rate limit, load-balancer connections, service workers, cgroup CPU/memory, queue retention, database connections, storage IOPS, dependency quotas, autoscaler bounds, node supply, zone placement and spending authority.

Attach proof:

- journey latency and correctness at the user boundary;
- offered, accepted, rejected and completed rates at admission;
- wait/service split at pools and dependencies;
- pressure and throttling inside the workload boundary;
- queue age and drain rate for asynchronous work;
- desired, provisioned, ready and serving capacity for scaling;
- quota, placement, cost and lead time for supply.

No single utilization number describes this architecture. The bottleneck can move after one component scales.

## Request or state path

A synchronous request spends its deadline across many states:

```text
client scheduling
 -> network and edge admission
 -> load-balancer wait
 -> service queue
 -> CPU runnable wait
 -> application service
 -> connection-pool wait
 -> dependency queue and service
 -> serialization and response
```

Measure end-to-end response time and, where possible, split wait from service. Adding workers can reduce one queue while exhausting a database pool. Increasing timeouts can hide rejects while retaining work until every concurrency slot is occupied.

For asynchronous work:

```text
arrival rate λ -> durable queue -> consumer service rate μ -> completion
                         |
                    age / depth / expiry / redrive
```

If sustained `λ > μ`, depth grows roughly by `(λ - μ) × time`. More important: oldest age approaches a deadline even while depth looks modest. Partition skew means the global queue can look healthy while one key is stuck.

Retries create a second workload. Track original operations and attempts. An attempt ratio of 3 means the system performs three requests for one user operation. Capacity planning on request count without operation identity can provision for amplification instead of preventing it.

For batch, the objective may be completion by a deadline. Capacity must cover total work, parallel efficiency, stragglers, retries and the available processing window. A cluster that can process a day of work in 24 hours has no recovery margin.

## Failure zoom

Picture a curve:

| Offered RPS | Goodput | p99 | Queue age | Errors | Meaning |
|---:|---:|---:|---:|---:|---|
| 300 | 298 | 90 ms | 0 | 0.2% | Linear region |
| 600 | 594 | 120 ms | 5 ms | 0.5% | Healthy but not proof of reserve |
| 900 | 870 | 260 ms | 80 ms | Rising | Knee: contention changes response |
| 1,050 | 900 | 850 ms | 600 ms | Rising | Added load mostly waits |
| 1,200 | 820 | 4.8 s | 3.7 s | Rising sharply | Collapse: timeouts and retries reduce goodput |

The bottleneck is not simply the resource with the highest percentage. It is the constrained resource or serialized path whose additional demand causes waiting and limits useful completion. Evidence should show:

1. its demand rises with workload;
2. its wait, pressure or rejects appear near the knee;
3. downstream idle or blocked behavior fits the mechanism;
4. changing that resource changes the curve under comparable conditions;
5. the bottleneck may move afterward.

Common failure mechanisms:

- one hot shard or lock serializes work while fleet CPU averages low;
- CPU quota throttles a cgroup while the host is idle;
- connection-pool wait dominates database query service time;
- memory reclaim or garbage collection creates tail pauses before OOM;
- storage latency raises service time and therefore concurrency;
- retries multiply work when latency crosses client deadlines;
- autoscaling reacts after measurement, scheduling and warm-up delay;
- load generator saturates, making target throughput look like server capacity;
- caching changes workload mix between cold start, steady state and eviction.

At the knee, prefer explicit admission or degradation over unlimited queues. A bounded rejection is usually easier to recover from than a system that accepts work it cannot finish before the user deadline.

## Internals and state ownership

Capacity equations are boundary contracts.

For each request class `i`, estimate resource demand:

```text
CPU cores required ≈ Σ(arrival_rate_i × CPU_seconds_per_operation_i)
IOPS required      ≈ Σ(arrival_rate_i × IO_operations_per_operation_i)
bandwidth required ≈ Σ(arrival_rate_i × bytes_per_operation_i)
```

Then divide by a reviewed target utilization, not by 100 percent. The target preserves latency, burst, control-loop and failure margin. It is workload- and architecture-specific.

Little's Law checks coherence:

```text
L = λW
180 concurrent ≈ 600 completed/s × 0.300 s
```

Use long-run averages over the same stable population and boundary. It does not calculate percentiles, require Poisson arrivals, or promise stability. A large discrepancy often reveals mixed units, omitted failures, open versus closed workload, measurement gaps or a changing backlog.

Queues become nonlinear as utilization approaches a bottleneck's effective limit because small service-time variation creates waits. Do not convert a simple queueing formula into certainty about a distributed service. Use it to ask why latency accelerates before 100 percent.

Own these states explicitly:

- workload specification and version;
- test dataset, cache state and dependency mode;
- generator capacity, clocks and offered schedule;
- target build, configuration, topology and resource ceilings;
- raw observations and histogram boundaries;
- abort, rollback, recovery and reconciliation status;
- forecast assumptions, owner, freshness and decision date;
- capacity allocation, quota, placement, cost and decommission plan.

A result without those states is not reproducible. A forecast without an owner and refresh trigger becomes stale policy.

## Evidence table

| Question | Evidence that helps | What it still does not prove |
|---|---|---|
| What demand arrived? | Offered schedule, client operations, business event, tenant and request-class mix | That the target received or accepted it |
| What useful work completed? | Correct, within-deadline operation outcomes | Maximum capacity or absence of silent loss |
| Where did time go? | End-to-end histogram plus queue, pool, service and dependency spans | Causality if clocks, sampling or populations differ |
| Is a resource saturated? | Wait/pressure/throttle/reject evidence paired with demand | That it is the first or only bottleneck |
| Where is the knee? | Repeated staged curve of offered load, goodput, tail, queues and errors | Production equivalence outside tested conditions |
| Will demand grow? | Clean history, calendar/event inputs, model, uncertainty and backtest | Future truth |
| Will scaling arrive in time? | Metric freshness, controller interval, scheduling, image, startup and readiness timing | Quota or dependency capacity unless included |
| Did scaling help? | Comparable before/after curve and user objective | Good efficiency or no shifted bottleneck |
| Is reserve sufficient? | Failure-domain simulation, disruption and recovery measurement | Every correlated failure |
| Is the plan affordable? | Unit and marginal cost per useful operation, commitment and egress | Budget approval or business value |

Preserve distributions with counts and units. A p99 derived from 50 samples is unstable; a histogram whose top bucket ends below timeouts hides the tail; a dashboard that excludes failed requests can improve while users suffer.

Segment carefully: endpoint, tenant, payload size, cache hit/miss, region, version, priority and dependency mode. Too little segmentation hides skew. Too much creates sparse, expensive evidence. Start from decisions.

Forecast evidence should include training interval, exclusions, backtest error, prediction interval, planned events, growth assumptions, lead time and invalidation triggers. Use multiple scenarios:

- expected;
- high but plausible;
- launch or event;
- one failure domain unavailable;
- dependency degraded;
- delayed provisioning.

The number presented to leadership should be a range with a decision date, not a fake precise point.

## Command decoders

Read commands as questions, not rituals.

`uptime` reports load averages for roughly one, five and fifteen minutes plus uptime and users. Linux load includes runnable tasks and tasks in uninterruptible sleep. Divide by CPUs only as a rough context; cgroup quotas, I/O wait and topology can invalidate the interpretation.

`nproc` reports processing units available to the current process. It can differ from physical cores and from another container. `lscpu` describes visible topology, not guaranteed compute.

`/proc/pressure/*` reports fractions of time tasks were stalled by CPU, memory or I/O pressure. `some` means at least some work stalled; `full` means all non-idle work stalled for supported resources. Use counter deltas and workload correlation; one snapshot cannot identify the owner.

`cpu.max` in cgroup v2 contains quota and period or `max`. A quota of 200000 over a period of 100000 is two CPUs of runtime, even if the host exposes more cores. `memory.max` is a hard ceiling; `memory.high` can cause reclaim pressure before it.

The model commands intentionally do not create load:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh run curve
bash lab.sh run queue
bash lab.sh run forecast
bash lab.sh run autoscale
bash lab.sh verify
```

`baseline` separates offered, accepted and useful completion. `curve` finds the encoded knee from goodput, p99, queue and errors. `queue` checks unit-consistent averages. `forecast` combines scenarios and rounds capacity. `autoscale` sums measurement, controller, supply and readiness delays. The verifier checks all cases and exact cleanup.

These outputs prove only the fictional rules. They deliberately avoid claiming a benchmark.

## Decision path

Use this decision tree:

```text
Is the user objective and workload population defined?
  no -> stop; capacity has no meaningful unit
  yes
   |
   v
Can offered, accepted and useful completed work be separated?
  no -> repair measurement before forecasting
  yes
   |
   v
Does backlog remain bounded at the observed peak?
  no -> arrival exceeds effective service; shed, degrade or add proven capacity
  yes
   |
   v
Where does wait/pressure/rejection grow first near the knee?
  unknown -> controlled staged test and boundary instrumentation
  known
   |
   v
Can that bottleneck scale independently?
  yes -> test vertical/horizontal/partition/cache choice and shifted bottleneck
  no  -> redesign serialized state, dependency contract or demand
   |
   v
Will ready capacity arrive before the user or queue deadline?
  no -> minimum reserve, predictive signal, faster warm-up and overload control
  yes -> validate quota, oscillation, failure reserve, cost and recovery
```

During an incident, first protect goodput: stop retry amplification, shed low-priority work, degrade expensive features, cap queues and reserve resources for recovery. Scaling is useful only if the constrained resource is replicated, supply exists, warm-up is fast enough and dependencies can absorb it.

For planning, provision before lead time:

```text
decision date = required-ready date - procurement/provisioning lead time - validation margin
```

If the decision date has passed, escalate the risk rather than hiding it in an optimistic forecast.

## Guided Ubuntu lab

This lab performs arithmetic and decision checks over synthetic observations. It generates no CPU, memory, disk or network load.

### Lab A — find a fictional performance knee

1. Inspect boundaries:

   ```bash
   pwd
   sed -n '1,260p' lab.sh
   sed -n '1,320p' fixtures/capacity_model.py
   python3 -m json.tool fixtures/scenario.json >/dev/null
   ```

2. Record normal-user context and read-only host observations:

   ```bash
   id
   nproc
   uptime
   free -h
   test -r /proc/pressure/cpu && cat /proc/pressure/cpu
   ```

   These describe this shell. Do not compare them directly with the fictional curve.

3. Create guarded synthetic state:

   ```bash
   bash lab.sh doctor
   bash lab.sh setup
   bash lab.sh status
   ```

4. Separate workload states and find the knee:

   ```bash
   bash lab.sh run baseline
   bash lab.sh run curve
   ```

   Explain why 1,200 offered RPS is not 1,200 capacity. State the safe tested region and why the knee is not a universal maximum.

5. Check queue arithmetic and forecast:

   ```bash
   bash lab.sh run queue
   bash lab.sh run forecast
   ```

   Recalculate units on paper. Challenge growth, event uplift, uncertainty, per-replica capacity and failure reserve.

6. Test control-loop timing:

   ```bash
   bash lab.sh run autoscale
   ```

   If reaction exceeds the queue buffer, identify which delays can be reduced and which require ready reserve or shedding.

7. Verify and clean:

   ```bash
   bash lab.sh verify
   bash lab.sh status
   ```

   Expected final state is absent.

### Lab B — independent plan

Use `ASM-0090-response-template.md` on a held-back workload. Produce workload specification, baseline, percentile and queue interpretation, bottleneck hypothesis, safe test design, forecast range, scaling choice, overload plan, cost model and verification. No model answer is available.

Abort if the case points at real production, customer data, employer endpoints, paid services or an unbounded generator. The reviewer judges evidence and assumptions, not confidence of tone.

## Production transfer

Before a real performance test, obtain explicit target, time, traffic, data, security, cost and incident authority. Define observers, abort owner and communication path. A test in a shared staging system can still harm other teams.

Workload fidelity includes:

- open versus closed arrival model;
- request classes and proportions;
- payload size and cardinality;
- cache warm/cold and hit ratio;
- authentication and session behavior;
- read/write ratio and data skew;
- retries, timeouts, cancellations and think time;
- burst, seasonality and concurrency;
- background work, compaction and scheduled jobs;
- dependency modes and failure behavior.

Calibrate the generator. Its CPU, sockets, ephemeral ports, connection pools, network and clock must retain headroom. Measure offered schedule independently from target responses. Use multiple generators only when aggregation, synchronization and identity remain correct.

Ramp in stages with steady windows and explicit aborts: user error/latency, queue age, correctness, resource pressure, dependency protection, cost and operator safety. Abort is a tested action, not a sentence in a document.

After the run, stop new work, drain or cancel according to policy, reconcile data, restore flags and limits, verify user paths, remove test identities and prove no state remains. Preserve raw results, versions and decision notes.

For Kubernetes, replicas are not ready capacity. Account for pending pods, node supply, topology spread, disruption budgets, image pulls, initialization, readiness, sidecars, CPU requests/limits, throttling and HPA metric semantics. An HPA is an intermittent control loop; missing metrics, stabilization and scale policy matter.

For databases, scale the limiting dimension: CPU, cache, locks, connections, IOPS, log/replication, storage growth or hot partitions. Adding application replicas can amplify database pressure.

For cloud, include quotas, regional stock, API rate limits, reservation lead time, egress and failure-domain capacity. Never assume an autoscaler can create unavailable supply.

## Reliability, security, observability, capacity, and cost

**Reliability:** define capacity against SLOs and correctness, not crash avoidance. Hold reserve for failures, deploys, maintenance and forecast error. Test graceful degradation, shedding and recovery near—not only below—the knee.

**Security:** load tools are dual-use. Restrict targets, credentials, source addresses, request shapes and data. Prevent tests from becoming denial of service, fraud, account lockout, audit flood or secret exposure. Rate limits and WAFs are part of the observed system; bypass requires explicit authority.

**Observability:** instrument offered and completed populations, distributions, wait/service splits, pressure, queue age and control-loop state. Monitor the test harness itself. Avoid high-cardinality labels and telemetry volume that alter the result. Record sampling and dropped observations.

**Capacity:** forecast by failure domain and dependency, not only fleet total. Ready capacity is the minimum usable capacity after placement, health and disruption. Update the model after architecture, workload, code, data, infrastructure or business changes.

**Cost:** use cost per useful operation and marginal cost at the objective. Include idle reserve, licenses, data transfer, observability, warm pools and operator time. Lowest utilization cost can conflict with reliability. Make the trade explicit.

**Sustainability:** scaling out indefinitely consumes energy and operational complexity. Reduce resource demand per operation, remove wasteful retries, batch compatible work, improve cache correctness and retire unused reserve when risk falls.

**People:** performance tests can page teams and create stressful failures. Schedule, communicate, staff and stop safely. No engineer should be surprised by a deliberate overload event.

## Traps and prevention

| Trap | Failure | Better move |
|---|---|---|
| CPU below 100 percent means headroom | Other resources or one partition can saturate first. | Find wait, pressure and goodput knee by boundary. |
| Average latency is good | A small slow population can violate the journey. | Keep distributions, errors and dropped work in population. |
| Average the instance p99s | Percentiles are not algebraically composable. | Aggregate compatible histograms or raw observations. |
| Target RPS equals achieved capacity | Generator, admission, errors or lateness reduce goodput. | Separate offered, accepted, completed and useful work. |
| Queue depth is stable, so safe | Age can rise with skew or changing item cost. | Monitor age, arrivals, departures, partitions and deadlines. |
| Scale at 90 percent CPU | Reaction may arrive after queue deadline; CPU may not be bottleneck. | Model signal and ready-capacity delay; keep reserve and shedding. |
| More replicas always help | Shared dependency, lock or quota can worsen. | Scale the bottleneck and retest the whole curve. |
| Add connections to fix pool wait | Database concurrency and lock pressure may collapse. | Bound concurrency and improve service demand or partitioning. |
| Short test proves soak | Leaks and cycles may need hours or days. | Cover rollover/compaction/expiry cycles and slopes. |
| Benchmark data is production data | Mix, skew, cache and failure behavior differ. | Version workload assumptions and compare distributions. |
| Forecast is one number | Uncertainty and events are hidden. | Publish scenarios, range, lead time and invalidation trigger. |
| Spare capacity is waste | Failure and rollout consume it. | Price reserve against objective and failure model. |
| Autoscaling replaces planning | Quota, delay and dependencies remain. | Plan minimum, maximum, supply and overload behavior. |
| Load test is harmless read traffic | Reads consume shared state and can trigger side effects. | Authorize, isolate, cap, abort and reconcile. |

Prevent recurrence with continuous capacity review: demand and capacity dashboards, versioned benchmarks, release-performance gates, forecast refresh, quota alarms, failure-domain reserve, tested shedding and a clear capacity-risk owner.

## Memory card and retrieval

Remember **KNEES**:

```text
K — Know workload, boundary, units and user objective
N — Name offered, accepted, goodput, wait, service and distribution
E — Expose the knee, bottleneck, queue and failure reserve
E — Estimate growth, uncertainty, lead time and cost
S — Scale the constraint, shed overload and verify recovery
```

When someone says, “We handle 1,200 RPS,” ask:

- offered, accepted or useful completion?
- which request mix and dataset?
- what p99, errors and queue age?
- how long was the test?
- what failure domain was unavailable?
- where was the knee?
- what was generator headroom?
- which version, limits and dependencies?

Retrieval prompts:

1. Why can 45 percent fleet CPU coexist with saturation?
2. At 500 operations/s and 240 ms average time, what concurrency does Little's Law estimate?
3. Why can p99 improve when the service is dropping users?
4. What four delays make an autoscaler late?
5. What distinguishes throughput from goodput?
6. Why must a capacity forecast include a decision date?

Answer without looking, then compare below. Repeat with new numbers after one day and one week.

## Complete answers

1. **Low average CPU with saturation:** one core, shard, lock, pool, cgroup quota, memory reclaim, storage, network or dependency can constrain work. Fleet averaging can hide hot instances. Saturation evidence is waiting, pressure, rejects and a flattened goodput curve at the exact boundary.

2. **Little's Law:** convert 240 ms to 0.240 s. `L = 500/s × 0.240 s = 120` average operations in the measured system. This is an average consistency estimate for a stable boundary, not a p99 prediction or worker recommendation.

3. **Misleading p99:** if overloaded requests are rejected before entering the measured handler, the remaining accepted population may be faster. If timeouts, failures or missing telemetry are excluded, p99 can improve while completion and user experience worsen. Pair latency with offered population, goodput, errors and coverage.

4. **Autoscaler delay:** metric observation and export; controller sampling/stabilization and decision; provisioning/scheduling or node supply; application startup, warm-up and readiness. Add traffic propagation and connection warm-up where relevant. Compare total delay with queue and user deadline.

5. **Throughput versus goodput:** throughput counts completed attempts or work items. Goodput counts correct, non-duplicated, within-objective operations useful to users. Retries and late completions can inflate throughput.

6. **Decision date:** capacity takes time to buy, reserve, quota, deploy, warm and validate. Required-ready date minus lead time and validation margin tells when action must be approved. A correct forecast delivered after that date cannot prevent the shortage.

Senior rule: **scale only after naming the constrained resource and the user objective; protect overload even when scaling exists; and attach every number to workload, boundary, interval, units, assumptions and uncertainty.**

## Product-company interview

**How would you capacity-plan a service?**

Start with user journeys and workload units, not instances. Establish offered/accepted/goodput history, request mix, seasonality, events and growth. Benchmark resource demand and find the objective-constrained knee under representative conditions. Forecast scenarios with uncertainty, apply failure-domain reserve and provisioning lead time, then choose vertical, horizontal, partition, cache or demand-control changes. Validate dependency and quota capacity, cost per useful operation, overload behavior and recovery. Refresh when workload, code, data or architecture changes.

**CPU is 60 percent. Do we have 40 percent headroom?**

No. CPU may not be the bottleneck, averaging hides skew, quotas differ from visible cores, and latency often becomes nonlinear before 100 percent. I would inspect per-instance distribution, throttling, PSI, run queue, locks, pools, I/O, dependencies, queue age, goodput and the tested performance curve. Headroom is relative to an objective and failure model.

**Explain Little's Law without misusing it.**

For the same stable boundary and interval, average number in the system equals average completion rate times average time in the system. It checks measurement coherence and estimates concurrency. Match units and include the same population. It does not predict percentiles, find the bottleneck, guarantee stability or justify a queue size by itself.

**How do you design a safe load test?**

Name the decision and objective, obtain authority, version workload and target, isolate or bound impact, protect data, calibrate generators, ramp gradually, observe clients/target/dependencies, set automatic and human aborts, preserve offered load and distributions, test recovery, reconcile state and publish limitations. I would not begin by selecting a tool.

**Why did HPA fail even though max replicas was high?**

Maximum is only a ceiling. The signal may lag, requests may be missing, stabilization may delay action, nodes or quota may be unavailable, pods may warm slowly, readiness may lie, or a shared dependency may be the bottleneck. Sum time to ready capacity and compare it with the workload buffer; keep minimum reserve and shedding.

**Vertical or horizontal scaling?**

Vertical scaling can be simple and improve locality but may require restart, hit a machine ceiling and increase failure impact. Horizontal scaling improves aggregate capacity and fault distribution only when state, partitioning and dependencies allow parallelism. Measure both through the bottleneck, operational risk, cost and recovery.

## Independent transfer and rubric

Complete `ASM-0090` on a reviewer-held scenario. No answer key is available.

Required evidence:

- workload boundary, operation classes, units and user objectives;
- offered, accepted, rejected, completed and goodput populations;
- latency distribution with errors, dropped work and coverage;
- resource-demand and wait/service evidence;
- performance curve and justified knee;
- Little's Law calculation with stability and boundary caveats;
- bottleneck hypothesis, alternative and discriminating test;
- expected/high/event/failure demand forecast with uncertainty;
- failure-domain reserve, quota, lead time and decision date;
- vertical/horizontal/partition/cache/demand-control tradeoff;
- autoscaling timing, bounds, missing-signal and oscillation analysis;
- load-test authorization, data, generator, ramp, abort, recovery and cleanup;
- cost per useful operation and sensitivity;
- overload and rollback plan.

Rubric, 100 points:

| Dimension | Points | Full-credit evidence |
|---|---:|---|
| Workload and objective | 10 | Exact boundaries, units, mix, user outcomes and exclusions. |
| Measurement integrity | 10 | Populations, distributions, coverage, clocks and generator evidence. |
| Curve and bottleneck | 10 | Repeated knee evidence, wait/pressure mechanism and alternative. |
| Queueing reasoning | 8 | Correct units and stable-boundary limitations. |
| Forecast | 10 | Baseline, seasonality, events, growth, uncertainty and backtest. |
| Reserve and lead time | 8 | Failure-domain capacity, quota, decision date and readiness. |
| Scaling design | 10 | Constraint-specific tradeoff and shifted-bottleneck verification. |
| Autoscaling control | 8 | Signal, delay, bounds, stabilization and failure modes. |
| Safe test design | 10 | Authority, realism, calibration, ramp, abort, recovery and cleanup. |
| Overload/recovery | 6 | Admission, shedding, degradation, retries and reconciliation. |
| Cost and sensitivity | 5 | Unit/marginal cost, reserve trade and changed-assumption result. |
| Communication | 5 | Range, uncertainty, decision, owner and review date. |

Passing proves one reviewed artifact met this rubric. It does not prove production authority or mastery.

## References and review

Reference records `REF-0289` through `REF-0303` anchor this chapter in primary or official material:

- Google SRE guidance on cascading failures, overload, capacity planning, load balancing and reliability testing;
- Linux kernel PSI documentation for resource-stall semantics;
- Kubernetes resource management, metrics and horizontal autoscaling control-loop behavior;
- AWS and Google Cloud performance/capacity architecture guidance;
- Prometheus histogram and quantile semantics;
- the original Little's Law relationship and tail-latency research where applicable.

Source vocabulary differs. “Capacity,” “load,” “utilization,” “queue” and “latency” can use different boundaries. This lesson states the boundary and does not merge incompatible formulas.

Review checklist:

- Are user objective, operation and units explicit?
- Are offered, accepted and goodput populations separate?
- Are errors, rejected and missing observations retained?
- Are percentiles derived from a valid distribution with counts?
- Is queue age visible alongside depth?
- Does bottleneck evidence include waiting and an intervention?
- Is the load generator measured and unsaturated?
- Are workload, data, cache and dependency states versioned?
- Are abort and recovery exercised?
- Does the forecast show uncertainty, reserve, lead time and decision date?
- Can scaling reach ready capacity before the buffer expires?
- Are dependency quota, failure domains and cost included?
- Is overload controlled if scaling fails?
- Is the plan owned and scheduled for refresh?

Re-review after meaningful changes to workload, code, runtime, topology, dependency, quota, cost model, SLO, forecast error or source guidance. Reading and model output remain study evidence only.
