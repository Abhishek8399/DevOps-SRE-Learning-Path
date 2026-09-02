---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0036",
  "slug": "resilience-patterns-failure-isolation",
  "aliases": ["V04-L11", "resilience-patterns-failure-isolation"],
  "curriculumIds": ["RES-001"],
  "route": "/book/reliability/resilience-patterns-failure-isolation",
  "order": 11,
  "volume": "04-reliability-operations",
  "title": "Resilience patterns: stop one slow dependency becoming everybody's outage",
  "summary": "Design deadline budgets, bounded retries, jitter, idempotency, circuit breakers, bulkheads, backpressure, admission, shedding, rate limits, bounded queues and degradation as one measurable failure-containment system.",
  "domain": "reliability",
  "level": {"from": "intermediate", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0013", "LES-0021", "LES-0026", "LES-0032", "LES-0035"],
  "prerequisiteCurriculumIds": ["NET-003", "DST-003", "OBS-001", "SRE-002", "PERF-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The bounded lab uses Bash and Python 3 as a normal user, opens no port, sends no network request, creates one exact UID-scoped temporary directory and models only fictional events."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "Designed for WSL with the same normal-user contract; filesystem ownership, clocks and process boundaries must be observed."},
    {"platform": "Production, Kubernetes, cloud and data services", "version": "concept-only", "support": "concept-only", "notes": "No command authorizes traffic, retry, timeout, circuit, queue, scaling, rate-limit or degradation changes."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "software-engineer", "systems-architect", "technical-lead"],
  "learningObjectives": [
    "Trace a deadline through client, network, service, queue and dependency budgets without allowing hidden timeout inversions.",
    "Decide whether an operation is safe to retry using failure class, remaining budget, attempt cost and idempotency semantics.",
    "Calculate retry amplification and design total retry budgets with exponential backoff and randomized jitter.",
    "Design idempotency keys, durable outcome records, conflict behavior, expiry and reconciliation for side-effecting operations.",
    "Explain circuit-breaker states, probes, rolling evidence and why a breaker is not dependency health truth.",
    "Partition concurrency and queues with bulkheads so one tenant, feature or dependency cannot consume every worker.",
    "Apply backpressure, admission control, rate limits, load shedding and graceful degradation at the cheapest useful boundary.",
    "Choose queue capacity and policy from deadlines, drain rate, priority, fairness, memory and recovery rather than convenience.",
    "Observe attempts, outcomes, budgets, breaker states, rejection reasons and degraded responses without hiding user impact.",
    "Defend a resilience design through correctness, availability, latency, capacity, security, cost, recovery and failure tests."
  ],
  "productionSignals": [
    "end-to-end deadline, remaining budget and timeout reason by hop and journey",
    "original operations, total attempts, retries, hedges and retry amplification ratio",
    "attempt outcome by failure class: refused, connect, TLS, timeout, reset, 4xx, 5xx, cancelled and unknown",
    "idempotency key outcome: first execution, replay, in-progress, conflict, expired and reconciliation failure",
    "circuit state, rolling sample count, failure/slow ratio, open reason, rejected calls and probe result",
    "concurrency in use and rejected by bulkhead, tenant, priority, dependency and workload class",
    "queue depth, oldest age, arrival, departure, capacity, expiry, priority and redrive",
    "rate-limit tokens, refill, decision, scope, Retry-After and limiter-store health",
    "admitted, shed, degraded and completed goodput with reason and user population",
    "dependency latency, quota, saturation and recovery correlated with caller behavior",
    "client cancellation propagation, orphan work and work completed after user deadline",
    "recovery drain rate, breaker convergence, backlog reconciliation and post-failure error-budget impact"
  ],
  "diagrams": [
    {"id": "LES-0036-DIA-001", "title": "One request, one end-to-end deadline", "direction": "left-to-right", "boundaries": ["client budget", "edge", "service queue", "service work", "dependency", "response"], "evidencePoints": ["deadline header", "remaining time", "queue age", "service time", "attempt budget", "user outcome"], "textAlternative": "A finite client deadline is reduced by network, queue and service time. Each downstream attempt receives only a bounded share of the remaining budget, and cancellation returns upstream."},
    {"id": "LES-0036-DIA-002", "title": "Retry amplification tree", "direction": "hierarchical", "boundaries": ["user operation", "gateway attempts", "service attempts", "database attempts"], "evidencePoints": ["original operations", "attempt count", "retry reason", "remaining deadline"], "textAlternative": "When three layers each allow three total attempts, one user operation can produce up to twenty-seven database attempts. A total budget across layers prevents multiplicative amplification."},
    {"id": "LES-0036-DIA-003", "title": "Idempotent operation state machine", "direction": "cyclic", "boundaries": ["absent", "in progress", "succeeded", "failed retryable", "conflict", "expired"], "evidencePoints": ["key", "request fingerprint", "owner", "stored outcome", "expiry", "reconciliation"], "textAlternative": "A unique key and request fingerprint claim an operation. Replays return the stored outcome, conflicting payloads are rejected, uncertain work is reconciled, and expiry follows the business duplicate window."},
    {"id": "LES-0036-DIA-004", "title": "Circuit breaker control state", "direction": "cyclic", "boundaries": ["closed", "open", "half open", "closed or open"], "evidencePoints": ["rolling failures", "cheap rejection", "limited probes", "recovery evidence"], "textAlternative": "Closed calls collect rolling evidence. A threshold opens the circuit for a bounded interval. Limited half-open probes decide whether to close or reopen; the breaker never proves global dependency health."},
    {"id": "LES-0036-DIA-005", "title": "Bulkhead and overload boundaries", "direction": "top-to-bottom", "boundaries": ["admission", "priority lanes", "bounded queues", "worker pools", "dependency pools", "shed or degrade"], "evidencePoints": ["tokens", "tenant share", "oldest age", "occupancy", "connection limit", "reason"], "textAlternative": "Work is admitted into isolated priority and tenant lanes with bounded queues and concurrency. Exhaustion in one lane cannot consume every worker; excess work is rejected or degraded deliberately."},
    {"id": "LES-0036-DIA-006", "title": "Failure and recovery test loop", "direction": "cyclic", "boundaries": ["baseline", "inject latency or error", "contain", "abort", "dependency recovery", "drain and reconcile", "verify"], "evidencePoints": ["user SLI", "attempt ratio", "isolation", "safety threshold", "probe convergence", "backlog age", "correctness"], "textAlternative": "A controlled test establishes baseline, injects a bounded dependency fault, observes containment, aborts safely, restores the dependency, drains and reconciles state, then verifies user and correctness outcomes."}
  ],
  "commands": [
    {"id": "LES-0036-CMD-001", "question": "What identity and environment bound this observation?", "risk": "read-only", "command": "id; uname -a; cat /etc/os-release; date -u +%Y-%m-%dT%H:%M:%SZ; pwd", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "UID is non-root and context matches", "meaning": "the observation boundary is recorded", "nextEvidence": "inspect network and process limits"}, {"when": "UID is zero or environment differs", "meaning": "the lab contract is not met", "nextEvidence": "stop or record the difference"}], "proves": "reported identity, kernel, release, time and path at one instant", "doesNotProve": "production equivalence or resilience"},
    {"id": "LES-0036-CMD-002", "question": "Which socket and descriptor ceilings can masquerade as dependency failure?", "risk": "read-only", "command": "ulimit -n; cat /proc/sys/net/core/somaxconn; cat /proc/sys/net/ipv4/ip_local_port_range", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "finite limits appear", "meaning": "caller resources can fail before the dependency", "nextEvidence": "correlate usage and refusal"}, {"when": "files differ", "meaning": "platform support or namespace differs", "nextEvidence": "record actual boundary"}], "proves": "selected visible ceilings", "doesNotProve": "current exhaustion, ownership or root cause"},
    {"id": "LES-0036-CMD-003", "question": "Are local sockets accumulating in connection states?", "risk": "read-only", "command": "ss -s; ss -tan", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "SYN-SENT, ESTAB or TIME-WAIT populations are elevated", "meaning": "connection behavior deserves correlation", "nextEvidence": "group by destination and process safely"}, {"when": "counts are low", "meaning": "this sample shows little socket accumulation", "nextEvidence": "inspect attempts, queues and dependency evidence"}], "proves": "socket-table snapshot visible to the caller", "doesNotProve": "dependency health, failure cause or future behavior"},
    {"id": "LES-0036-CMD-004", "question": "Does the fictional resilience scenario satisfy its contract?", "risk": "read-only", "command": "python3 fixtures/resilience_model.py validate-scenario fixtures/scenario.json", "runFrom": "book/labs/LES-0036-resilience-patterns-failure-isolation", "expectedBranches": [{"when": "valid=true appears", "meaning": "units and policy inputs satisfy model invariants", "nextEvidence": "run setup"}, {"when": "an error appears", "meaning": "the fixture cannot support conclusions", "nextEvidence": "preserve first error and create no state"}], "proves": "deterministic fixture conformance", "doesNotProve": "production policy, dependency behavior or safety"},
    {"id": "LES-0036-CMD-005", "question": "Can the lab create its exact private state?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "book/labs/LES-0036-resilience-patterns-failure-isolation as a normal Ubuntu user", "expectedBranches": [{"when": "state=ready appears", "meaning": "UID-scoped synthetic state validates", "nextEvidence": "run deadline"}, {"when": "refused=true appears", "meaning": "identity, ownership, path or fixture is unsafe", "nextEvidence": "preserve ambiguous state"}], "proves": "bounded state creation under wrapper checks", "doesNotProve": "network or production behavior", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-006", "question": "Does every hop fit inside one deadline?", "risk": "mutating-bounded", "command": "bash lab.sh run deadline", "runFrom": "validated LES-0036 state", "expectedBranches": [{"when": "remainingMs=120 and valid=true appear", "meaning": "encoded budgets fit with guard time", "nextEvidence": "test cancellation and tails"}, {"when": "valid=false appears", "meaning": "nested work outlives the user budget", "nextEvidence": "reduce hops or fail earlier"}], "proves": "fixture deadline arithmetic", "doesNotProve": "real timer or cancellation behavior", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-007", "question": "How much work can layered retries amplify?", "risk": "mutating-bounded", "command": "bash lab.sh run retries", "runFrom": "validated LES-0036 state", "expectedBranches": [{"when": "unboundedAttempts=27 and budgetedAttempts=4 appear", "meaning": "layered local policies multiply while a total budget caps work", "nextEvidence": "place ownership at one layer"}, {"when": "values differ", "meaning": "policy or fixture changed", "nextEvidence": "recalculate original and attempts"}], "proves": "worst-case encoded attempt count", "doesNotProve": "actual attempt distribution or retry safety", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-008", "question": "Does jitter spread clients instead of synchronizing them?", "risk": "mutating-bounded", "command": "bash lab.sh run jitter", "runFrom": "validated LES-0036 state", "expectedBranches": [{"when": "uniqueSlots=8 and synchronized=false appear", "meaning": "deterministic sample spreads retries", "nextEvidence": "inspect randomization and cap"}, {"when": "synchronized=true appears", "meaning": "clients can create a retry wave", "nextEvidence": "add randomized bounded delay"}], "proves": "distribution of fictional retry slots", "doesNotProve": "production client randomness or fairness", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-009", "question": "Do duplicate requests create only one side effect?", "risk": "mutating-bounded", "command": "bash lab.sh run idempotency", "runFrom": "validated LES-0036 state", "expectedBranches": [{"when": "requests=4 sideEffects=1 conflicts=1 appears", "meaning": "same-key replays reuse outcome and changed payload conflicts", "nextEvidence": "test crash and expiry"}, {"when": "sideEffects exceeds one", "meaning": "duplicate suppression failed", "nextEvidence": "stop side-effecting retries"}], "proves": "fictional state-machine result", "doesNotProve": "database atomicity, durability or business semantics", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-010", "question": "Does the breaker reject cheaply and probe recovery cautiously?", "risk": "mutating-bounded", "command": "bash lab.sh run circuit", "runFrom": "validated LES-0036 state", "expectedBranches": [{"when": "opened=true probes=2 finalState=closed appears", "meaning": "encoded rolling failure and probe policy converges", "nextEvidence": "test false open and flapping"}, {"when": "final state remains open", "meaning": "recovery evidence is insufficient", "nextEvidence": "keep degradation and inspect dependency"}], "proves": "fictional breaker transitions", "doesNotProve": "global dependency health or correct production thresholds", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-011", "question": "Does one workload preserve capacity for another?", "risk": "mutating-bounded", "command": "bash lab.sh run bulkhead", "runFrom": "validated LES-0036 state", "expectedBranches": [{"when": "bulkheadProtected=true sharedProtected=false appears", "meaning": "isolated capacity contains the noisy class in the fixture", "nextEvidence": "challenge stranded-capacity and fairness costs"}, {"when": "bulkheadProtected=false appears", "meaning": "partition or priority policy fails", "nextEvidence": "redesign admission and reserves"}], "proves": "fixture allocation result", "doesNotProve": "production fairness or optimal pool sizes", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0036-CMD-012", "question": "Do all policy cases and cleanup guards pass?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "book/labs/LES-0036-resilience-patterns-failure-isolation as a normal Ubuntu user", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "checked cases and cleanup passed", "nextEvidence": "preserve proof limits"}, {"when": "an assertion or cleanup fails", "meaning": "the first failure is evidence", "nextEvidence": "stop and inspect guarded state"}], "proves": "checked-in deterministic lifecycle behavior for that run", "doesNotProve": "real network, service, provider, production or mastery", "cleanup": "the verifier must prove exact absence"}
  ],
  "labs": [
    {"id": "LES-0036-LAB-001", "title": "Guided deadline, retry, idempotency and isolation model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; offline deterministic data only", "timeMinutes": 180, "privilege": "normal user; wrapper and verifier refuse UID 0", "network": "none", "changes": ["one exact UID-scoped temporary directory", "owned scenario, manifest and one replaceable result"], "abortConditions": ["root", "ambiguous owner or path", "symlink", "unexpected entry", "fixture failure", "model presented as production truth"], "recovery": "Run status and clean only state that passes descriptor checks.", "cleanupProof": "Validate real path, UID, sentinel, manifest and allowed children; remove exact state and prove absence.", "path": "book/labs/LES-0036-resilience-patterns-failure-isolation"},
    {"id": "LES-0036-LAB-002", "title": "Independent cascading-failure containment design", "mode": "independent", "environment": "Reviewer-held unfamiliar scenario with deadlines, failures, side effects, workload classes and recovery evidence", "timeMinutes": 240, "privilege": "normal user; no production traffic or configuration authority", "network": "none unless an approved unseen harness permits bounded loopback", "changes": ["one sanitized design and evidence report", "only declared unseen-case state"], "abortConditions": ["answer access", "unclear authorization", "unbounded traffic", "real customer data", "missing recovery proof"], "recovery": "Return to the last valid boundary and retain uncertainty.", "cleanupProof": "Reviewer manifest proves all allowed resources absent.", "path": "book/labs/LES-0036-resilience-patterns-failure-isolation"}
  ],
  "incidents": [
    {"id": "LES-0036-INC-001", "signal": "A dependency slows and caller traffic triples.", "firstThought": "Retries may be multiplying original work before the dependency can recover.", "safePath": "Separate operations from attempts, stop unsafe retries, shed cheaply and preserve critical goodput.", "trap": "Increase retries because errors are transient."},
    {"id": "LES-0036-INC-002", "signal": "Client times out but the payment completes twice.", "firstThought": "Timeout is uncertainty, not failure; the side effect lacks a complete idempotency and reconciliation contract.", "safePath": "Stop blind replay, query durable outcome, reconcile, then repair key and transaction semantics.", "trap": "Retry every timeout with a new key."},
    {"id": "LES-0036-INC-003", "signal": "Circuit is open while dependency dashboard is green.", "firstThought": "The breaker reports this caller's rolling experience and policy, not universal dependency health.", "safePath": "Inspect caller path, sample size, thresholds, probes, DNS/network and cohort differences.", "trap": "Force-close globally without containment."},
    {"id": "LES-0036-INC-004", "signal": "Bulk work fills a shared queue and interactive traffic misses deadlines.", "firstThought": "Shared admission and workers let cheap low-priority volume consume scarce deadline capacity.", "safePath": "Partition lanes, bound age, reserve interactive concurrency and shed expired bulk work.", "trap": "Make the shared queue larger."},
    {"id": "LES-0036-INC-005", "signal": "Dependency recovers but callers keep it overloaded.", "firstThought": "Synchronized retries, backlog drain and aggressive half-open probes can create a recovery storm.", "safePath": "Ramp probes, jitter retries, pace drain, enforce budgets and verify stable recovery.", "trap": "Release every queued request immediately."}
  ],
  "assessmentIds": ["ASM-0091", "ASM-0092", "ASM-0093"],
  "referenceIds": ["REF-0304", "REF-0305", "REF-0306", "REF-0307", "REF-0308", "REF-0309", "REF-0310", "REF-0311", "REF-0312", "REF-0313", "REF-0314", "REF-0315", "REF-0316", "REF-0317", "REF-0318"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": ["All cases are fictional or bounded local models.", "No production traffic or policy change is authorized.", "Resilience controls can reduce availability or violate correctness when misapplied.", "Reading and automation do not establish mastery."]
}
---

# Resilience patterns: stop one slow dependency becoming everybody's outage

## What you see and first thought

A dependency becomes slow. Error rate rises. Three teams independently increase retries. Traffic at the struggling dependency jumps even though user demand did not change.

Your first thought should be: **how much original work arrived, how many attempts did we manufacture, which deadlines are already impossible, and which boundary can reject the cheapest work before shared capacity disappears?**

Resilience is not “never fail.” It is the ability to keep one fault inside a known boundary, preserve the most valuable correct work, recover without a second storm, and explain the trade-off with evidence.

```text
one user operation
  -> attempt 1 times out
  -> retry at gateway
      -> service retries
          -> database client retries
             = many attempts for one intention
```

Whenever you see timeouts plus rising request rate, compare operations with attempts. A timeout says the caller stopped waiting; it does not say the remote work stopped or failed. For side effects, that distinction is the difference between safe recovery and duplicate money movement.

Use this order: protect correctness; propagate one end-to-end deadline; classify the failure; bound attempts globally; add random delay; isolate scarce resources; reject or degrade before collapse; observe recovery; reconcile uncertain outcomes.

## Terms before commands

**Deadline** is an absolute latest completion time for the whole operation. **Timeout** is how long one wait is allowed. A 500 ms timeout at every hop can exceed a 500 ms user deadline because queues, connection setup and nested calls consume time too.

**Cancellation** tells downstream work the caller no longer needs the result. It saves capacity only if every layer propagates and honors it. Work may be non-cancellable after a transaction commits.

An **attempt** is one execution try. An **operation** is the user's logical intention. Reliability math must count both. If 100 operations cause 240 attempts, the attempt amplification ratio is 2.4.

A **retry budget** caps retries relative to original operations, remaining deadline, concurrency or error budget. “Three retries per layer” is not a total budget: three layers with three total attempts each can create 27 leaf attempts.

**Backoff** increases delay between attempts. **Jitter** randomizes it so many clients do not wake together. Backoff without jitter can produce synchronized waves.

An operation is **idempotent** when repeating the same logical request has the intended effect once. HTTP method labels alone do not prove business idempotency. A payment request needs a stable key, request fingerprint, atomic claim, durable outcome, replay behavior, conflict rule, expiry and reconciliation.

A **circuit breaker** uses local rolling evidence to stop calls temporarily. Closed allows calls, open rejects cheaply, and half-open permits limited probes. It is a caller-protection state machine, not a global dependency health oracle.

A **bulkhead** partitions a scarce resource such as threads, connections, queue slots or tokens. It trades some pooling efficiency for failure isolation.

**Backpressure** makes a producer slow or stop when the consumer cannot keep up. **Admission control** decides whether work may enter. **Load shedding** deliberately rejects work the system cannot serve safely. **Graceful degradation** returns a cheaper but explicitly valid result.

A **rate limit** bounds work over time. It differs from concurrency: 100 RPS of 10 ms work averages one concurrent request, while 100 RPS of 2 s work averages 200. You often need both.

## Architecture map

```text
caller deadline and retry budget
            |
            v
edge admission -- rate limit -- priority / tenant policy
            |
       bounded queue
            |
     service bulkheads
       /          \
critical pool   optional pool
     |               |
dependency client: timeout -> retry policy -> circuit -> connection pool
     |
idempotency store / durable outcome / reconciliation

signals -> policy owner -> controlled configuration -> verification
```

The data plane carries user work. The resilience plane decides how long to wait, whether to retry, which work enters, and what to sacrifice. The correctness plane records side effects and outcomes. The control plane changes policies. Treat all four as production code.

Map limits at every hop:

- absolute deadline and cancellation propagation;
- connection, request and idle timeouts;
- total attempt and hedge budget;
- worker and connection concurrency;
- queue capacity, age and expiry;
- per-tenant and per-priority admission;
- dependency quota and circuit scope;
- idempotency ownership and retention;
- degraded-response contract;
- recovery probe and backlog-drain rate.

The safest rejection usually happens upstream, before expensive authentication, parsing, allocation, locking or dependency calls. But upstream policy needs downstream evidence; otherwise it may shed the wrong population.

## Request or state path

Follow one checkout operation:

```text
t=0 ms    client sets absolute deadline t=800
t=40      edge finishes auth; remaining 760
t=90      service leaves queue; remaining 710
t=210     inventory completes; remaining 590
t=230     payment attempt starts with 350 ms cap
t=580     payment timeout; remaining 220
t=580     outcome is UNKNOWN, not failed
t=620     durable lookup says committed
t=660     stored success returns to caller
```

The payment attempt cannot receive the entire original 800 ms after 230 ms has already passed. Reserve time to translate the result, persist outcome and return it. Use an absolute deadline where possible so clock time is not re-expanded at each hop.

For a read-only dependency, a timeout before any response may be retryable if the remaining deadline, retry budget and overload state allow it. For a charge, “no response” means uncertain. Repeating without the same idempotency key can duplicate the side effect.

State ownership matters:

- the caller owns the user deadline and cancellation intent;
- one designated layer owns the total retry policy;
- the receiving service owns admission and overload protection;
- the side-effect service owns atomic idempotency and durable outcome;
- the dependency client owns circuit and connection-pool state;
- operators own safe defaults, rollout, observation and rollback.

## Failure zoom

Assume 1,000 operations/s. Gateway, service and database client each allow two retries, meaning three total attempts at each layer. If every attempt reaches the next layer during a common failure:

```text
gateway attempts       = 3
service attempts       = 3 x 3 = 9
database attempts      = 3 x 3 x 3 = 27
leaf offered load      = 27,000 attempts/s
```

The dependency was already struggling at 1,000 operations/s. Local retry policies turn recovery into collapse.

Now add synchronized exponential backoff. Ten thousand clients fail at the same moment, wait exactly 100 ms, then retry together. Doubling to 200 and 400 ms creates waves, not relief. Full jitter chooses a random delay inside the current cap, spreading arrivals.

Next, imagine every retry waits in an unbounded queue. Memory rises, oldest age exceeds the user deadline, but workers still execute expired work. Users retry, so the queue stores work nobody wants. A larger queue increased failure duration.

Containment:

```text
original operations: 1000/s
total retry allowance: 10% of originals
admission: reserve critical lane
queue: bounded by age and memory
breaker: reject optional dependency cheaply
degradation: omit recommendation, preserve checkout
recovery: limited probes + paced backlog drain
```

The right policy depends on correctness and value. Shedding an optional recommendation is different from shedding a payment authorization. “Available” is not useful if the answer is wrong.

## Internals and state ownership

Timeouts must be ordered. If an upstream proxy times out at 300 ms while the service continues a 2 s dependency call, work becomes orphaned. A useful invariant is:

```text
downstream attempt timeout
  < caller remaining deadline
  - response/cleanup guard
```

Retry decisions need a matrix, not a boolean:

| Condition | Default thought |
|---|---|
| caller cancelled | stop unless a correctness obligation requires completion |
| deadline exhausted | do not retry |
| invalid request or authorization denied | do not retry |
| overload rejection with guidance | retry only within global budget and delay |
| connect failure before send | may retry if operation semantics and budget permit |
| timeout after send | outcome may be unknown; require idempotency or lookup |
| explicit transient server failure | bounded retry may help |
| permanent or semantic conflict | return or reconcile; do not loop |

An idempotency record should bind key to principal, operation type and request fingerprint. The first execution atomically claims it. A matching replay returns the stored status or result. A changed payload with the same key is a conflict. “In progress” needs lease, fencing or reconciliation so a crashed owner cannot leave the key ambiguous forever. Expiry must exceed the business duplicate window, not merely a cache TTL chosen for convenience.

Circuit-breaker thresholds require minimum sample counts and rolling windows. Ten failures out of ten can justify protection; one failure out of one usually cannot. Half-open concurrency must be small, or every caller probes simultaneously. Scope matters: global breakers can hide a healthy region because one region failed; per-host breakers can route everyone to the last host.

Bulkheads can partition:

- interactive and batch workers;
- tenant or priority tokens;
- dependency connection pools;
- read and write paths;
- regions, shards or failure domains.

Over-partitioning strands capacity. Use borrowing rules only when the protected reserve remains enforceable.

## Evidence table

When the service is failing, do not collect random dashboards. Start with a question and ask what evidence can answer it.

| Question | Evidence that helps | What it still does not prove |
|---|---|---|
| Did demand increase? | Original operations by journey, tenant and region | That the dependency received the same number of attempts |
| Did retries amplify work? | Original-operation count beside attempts, retries and hedges | Which layer created the extra attempts unless ownership is labeled |
| Is the deadline coherent? | Start time, absolute deadline, remaining budget and completion or cancellation at each hop | That every downstream component actually stopped work |
| Is the failure transient? | Connect, TLS, refusal, reset, status, timeout and dependency recovery evidence | That a retry is safe for this operation |
| Did idempotency work? | Key, principal, request fingerprint, claim state, stored outcome and side-effect count | That expiry and crash recovery are correct for every business case |
| Did the breaker protect callers? | Rolling sample count, threshold, open reason, cheap rejects and probe results | That the dependency was globally unhealthy |
| Did the bulkhead contain impact? | Occupancy, wait, rejection and goodput for each isolated lane | That the partition sizes are fair or cost-optimal |
| Is a queue safe? | Arrival, departure, oldest age, expiry, memory and deadline distribution | That queued work will remain valuable when executed |
| Did shedding preserve value? | Admitted, shed, degraded and completed-goodput populations by priority | That the priority policy is ethically or commercially correct |
| Did recovery finish? | Probe convergence, retry ratio, backlog drain, reconciliation and user SLI | That the same policy handles another failure mode |

An error rate without a denominator is not enough. Five hundred dependency errors may mean 500 of 1,000 operations or 500 of 27,000 amplified attempts. Both are serious, but the control action differs.

Preserve these relationships:

~~~text
operation_id -> attempt_id -> parent_attempt_id
             -> deadline -> remaining_budget
             -> idempotency_key -> request_fingerprint
             -> admission_decision -> queue_lane
             -> circuit_state -> dependency_outcome
             -> user_outcome -> reconciliation_outcome
~~~

Do not put raw idempotency keys, payment identifiers, tokens or customer data into metrics. Use bounded labels and protected traces or logs. High-cardinality identifiers can move an incident from the dependency to the telemetry system.

## Command decoders

Read each command as a question.

The identity command records who and where you are. UID 0 means root; this lab refuses root because elevated privilege is unnecessary. uname and os-release describe the visible kernel and distribution. They do not prove production equivalence.

The file-descriptor command, ulimit -n, shows the calling shell's soft open-file limit. Network sockets are file descriptors on Linux, so a caller can fail locally even when the remote dependency is healthy. A limit does not show current use. Pair it with process-level descriptor counts and socket evidence only on systems you are authorized to inspect.

somaxconn is a ceiling related to the listen backlog. It does not equal the active backlog of every socket. ip_local_port_range shows the local ephemeral source-port range visible in that network namespace. Neither value alone proves exhaustion.

ss -s summarizes sockets; ss -tan lists TCP sockets numerically. Interpret states carefully:

- SYN-SENT can mean connection attempts awaiting completion;
- ESTAB means TCP is established, not that the application is healthy;
- TIME-WAIT is normal protection after connection close, but large churn can expose a connection-management problem;
- a snapshot is not a rate, cause or owner.

The lab commands are deliberately offline:

~~~bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh run deadline
bash lab.sh run retries
bash lab.sh run jitter
bash lab.sh run idempotency
bash lab.sh run circuit
bash lab.sh run bulkhead
bash verify.sh
~~~

deadline subtracts queue, work, dependency and guard allocations from one end-to-end budget. retries compares multiplicative layer-local attempts with one global allowance. jitter measures spread across deterministic slots. idempotency applies repeated and conflicting requests to a fictional state machine. circuit evaluates rolling failures, cheap rejection and limited recovery probes. bulkhead compares a shared pool with reserved critical capacity.

The outputs are claims about checked-in fixture arithmetic only. They do not exercise real clocks, databases, sockets, concurrent races, proxies or production policies.

## Decision path

Use this sequence when a dependency slows:

~~~text
Is user correctness at risk?
  yes -> stop blind side-effect retries; look up or reconcile outcome
  no
   |
   v
Is one end-to-end deadline present and still usable?
  no -> fail or degrade now; do not start work that cannot finish
  yes
   |
   v
Is the failure classified and retryable for this operation?
  no -> return the correct terminal or reconciliation path
  yes
   |
   v
Is one global retry owner inside remaining budget and overload policy?
  no -> do not retry
  yes -> bounded attempt + exponential backoff + jitter
   |
   v
Is shared capacity approaching saturation?
  yes -> admission, bulkhead, bounded queue, shed or degrade
  no  -> continue observing user outcome and attempt ratio
   |
   v
Has the dependency recovered stably?
  no -> limited probes and protected critical path
  yes -> paced drain, reconcile uncertain work, verify SLI and close incident
~~~

During an incident, make the cheapest reversible containment change at the narrowest correct boundary. Turning off retries for one optional call is usually safer than force-closing every circuit. Rejecting expired work before it enters a database is cheaper than letting it consume locks and returning too late.

Do not confuse a response code with a policy. A 429 or 503 can carry retry guidance, but the caller still checks deadline, idempotency, budget and jitter. Retry-After is not permission to create an unlimited retry wave.

For side effects, the decision path has one extra branch:

~~~text
Was the request definitely not sent?
  maybe -> outcome unknown
            |
            +-> query by stable operation key
            +-> return stored success/failure if terminal
            +-> wait or reconcile if in progress
            +-> never create a new logical key merely to retry
~~~

## Guided Ubuntu lab

This lab models policy decisions. It opens no port, sends no network request and touches no service. Run it from book/labs/LES-0036-resilience-patterns-failure-isolation as a normal Ubuntu 24.04 user.

### Lab A - inspect before execution

1. Confirm the directory and read the safety boundary:

   ~~~bash
   pwd
   sed -n '1,280p' lab.sh
   sed -n '1,360p' fixtures/resilience_model.py
   python3 -m json.tool fixtures/scenario.json >/dev/null
   ~~~

2. Record your environment:

   ~~~bash
   id
   uname -a
   cat /etc/os-release
   date -u +%Y-%m-%dT%H:%M:%SZ
   ~~~

   If id reports uid=0, stop. Root is neither required nor accepted.

3. Ask the wrapper whether state is absent and inputs are valid:

   ~~~bash
   bash lab.sh doctor
   python3 fixtures/resilience_model.py validate-scenario fixtures/scenario.json
   ~~~

   valid=true proves fixture conformance, not production safety.

### Lab B - reason through containment

1. Create the exact UID-scoped state and inspect it:

   ~~~bash
   bash lab.sh setup
   bash lab.sh status
   ~~~

2. Check the deadline:

   ~~~bash
   bash lab.sh run deadline
   ~~~

   Recalculate the 800 ms budget yourself. Explain why the 120 ms remainder is a guard, not spare time automatically granted to another retry.

3. Compare retry ownership:

   ~~~bash
   bash lab.sh run retries
   bash lab.sh run jitter
   ~~~

   Draw the 3 x 3 x 3 tree. Then explain why four total attempts can still be too many when the deadline is almost gone or the dependency is overloaded.

4. Protect correctness:

   ~~~bash
   bash lab.sh run idempotency
   ~~~

   Identify the first request, matching replays and changed-payload conflict. Describe what additional transaction or compare-and-set guarantee a real datastore must supply.

5. Contain capacity and recover:

   ~~~bash
   bash lab.sh run circuit
   bash lab.sh run bulkhead
   ~~~

   Explain why two half-open probes are evidence only for that breaker scope. Compare critical goodput under the shared and partitioned pools.

6. Run the verifier and prove absence:

   ~~~bash
   bash verify.sh
   bash lab.sh status
   ~~~

   The final line must say state_absent=true, and status must report state=absent. If cleanup refuses, preserve the directory for inspection; never bypass the guard with a broad delete.

### Lab C - independent design

Complete ASM-0093 on a reviewer-held system. You receive only the user journey, dependency behavior, side-effect rules, workload classes and failure observations. Produce deadline arithmetic, retry matrix, idempotency state, admission and isolation design, recovery test and proof limits. The answer is intentionally unavailable.

Abort if the exercise points to production, customer data, paid infrastructure, unbounded traffic or a target without explicit authorization.

## Production transfer

Local arithmetic is the beginning. A production policy must survive real timing, concurrency, deployment and partial failure.

For HTTP and gRPC, propagate an absolute deadline or correctly reduced remaining timeout. Account for connection establishment, TLS, proxy queues, service queues, dependency work, serialization and return guard. Test cancellation: a caller disappearing should stop cancellable downstream work, while committed correctness obligations continue to reconciliation.

For Kubernetes:

- distinguish application timeouts from ingress, service-mesh and load-balancer timeouts;
- inspect pod and node cgroup limits before blaming a dependency;
- isolate critical and batch workloads with explicit concurrency, queue and topology policy;
- remember that a per-pod circuit multiplied by thousands of pods can create thousands of probes;
- roll policy changes gradually and retain a fast rollback;
- ensure readiness does not send traffic to an instance whose dependency pools are still cold.

For queues and streams, backpressure means the producer responds to consumer capacity. Bound oldest age and total retention, not only item count. Expired work should be rejected or dead-lettered according to business semantics. A dead-letter queue is not cleanup; every item needs ownership, replay rules, poison-message handling and reconciliation.

For databases and side effects, place idempotency beside the transaction that owns the effect. A cache-only key can disappear while the committed row remains. Bind the key to caller and payload, atomically claim it, store the terminal result, reject conflicts and test crash points before and after commit.

For rate limiting, define scope: process, pod, user, tenant, API key, route, region or global. A local token bucket can permit fleet-size times the intended global rate. A centralized limiter can become a critical dependency. Choose failure-open or failure-closed by abuse, correctness and availability risk, then observe the choice.

Before a real failure test, define authorization, target, traffic, data, blast radius, abort owner, rollback, communications and recovery proof. Begin with one bounded cohort. Inject one failure at a time, verify containment, restore, pace backlog drain and reconcile state before expanding.

## Reliability, security, observability, capacity, and cost

**Reliability:** timeouts, retries, breakers and queues are coupled. A longer timeout occupies concurrency; more retries create attempts; a larger queue creates waiting; an aggressive breaker rejects healthy outliers. Design and test the system, not isolated knobs.

**Correctness:** never trade duplicate or contradictory side effects for a greener availability graph. Unknown outcomes require durable lookup and reconciliation. Degradation must return an explicitly valid product state, not stale or fabricated success.

**Security:** admission and rate limits protect both reliability and abuse boundaries. Partition by trusted identity only after authentication cost is understood. Do not let attackers create unbounded idempotency records, high-cardinality telemetry, expensive retries or global limiter pressure. Keys need entropy, scope, authorization and protected retention.

**Observability:** expose original operations, attempts, retry reasons, remaining deadline, admission decision, circuit state, queue age, bulkhead occupancy and user goodput. Keep cardinality bounded. Alert on user impact and amplification, not every individual breaker transition.

**Capacity:** reserve concurrency for critical work and for recovery. A breaker reduces new dependency load but can move pressure to fallback storage or caches. Degradation has its own capacity model. Test the system with one failure domain lost and with delayed recovery.

**Cost:** retries, hedges, duplicate writes, oversized queues, retained idempotency records and fallback traffic all cost money. Cost per successful user operation is more useful than cost per request when attempts multiply.

**People:** overload policies encode business priority. Product, security, legal and operations owners must agree what may be delayed, degraded or rejected. Engineers should not invent that hierarchy during an incident.

## Traps and prevention

| Trap | Why it fails | Better move |
|---|---|---|
| Every timeout deserves a retry | The remote outcome may be unknown, and repeated work may amplify overload or duplicate a side effect. | Classify phase and semantics; use the same operation key and a global budget. |
| Three retries is small | At several layers, local attempt limits multiply. | Count leaf attempts per original operation and give one layer ownership. |
| Exponential backoff solves retry storms | Identical clients still wake in synchronized waves. | Add bounded randomized jitter and enforce a retry budget. |
| A longer timeout improves availability | It occupies scarce concurrency and can outlive the user deadline. | Propagate one deadline and reserve return/cleanup time. |
| A circuit breaker heals the dependency | It only protects one caller scope using local evidence. | Pair it with dependency evidence, degradation, limited probes and recovery verification. |
| Force-close the breaker during incident | A full caller fleet may stampede a recovering dependency. | Use bounded half-open probes and gradual convergence. |
| A bigger queue absorbs bursts | Old work can expire, consume memory and extend recovery. | Bound count and age; shed before work becomes worthless. |
| Rate limit equals concurrency limit | Slow requests can occupy all workers at a modest rate. | Bound both rate and in-flight work. |
| Shared pools maximize efficiency | One noisy tenant or optional feature can consume every slot. | Reserve critical capacity and measure stranded-capacity trade-offs. |
| Bulkheads must never share capacity | Rigid partitions can waste capacity during normal operation. | Permit controlled borrowing while preserving enforceable reserves. |
| HTTP POST is never retryable | Business semantics, not the method label alone, decide safety. | Add durable idempotency and replay behavior where appropriate. |
| HTTP PUT is automatically safe | A nominally idempotent method can trigger non-idempotent downstream effects. | Test the complete operation contract and side effects. |
| The idempotency key can live in cache | Cache loss can forget a completed durable effect. | Couple the claim and outcome to the authoritative transaction boundary. |
| Return success from a fallback | A stale or partial answer may violate correctness. | Name degradation explicitly and preserve product semantics. |
| Retry-After guarantees safe retry | Many clients may still synchronize, deadlines may expire, and the operation may be unsafe. | Apply jitter, remaining deadline, idempotency and global-budget checks. |
| Recovery means errors stopped | Backlog, duplicates, stale circuits and reconciliation may remain. | Pace drain and verify user, attempt, queue and correctness recovery. |

Prevention is a maintained contract: timeout hierarchy tests, one retry owner, idempotency crash tests, queue-age alarms, bulkhead saturation tests, rate-limit scope review, controlled fault exercises and a runbook that includes recovery rather than only containment.

## Memory card and retrieval

Remember **D-R-I-P** when a dependency is hurting:

~~~text
D - Deadline: one finite end-to-end clock; cancel impossible work
R - Retries: classify, budget globally, back off and jitter
I - Isolate: idempotency for correctness; bulkheads for capacity
P - Protect: admission, bounded queues, shed/degrade, probe and recover
~~~

Keep this sentence in your head: **a timeout is uncertainty, a retry is new load, a queue is stored waiting, and a breaker is local self-protection.**

Answer these without looking:

1. Three layers each allow three total attempts. How many leaf attempts can one operation create?
2. Why does exponential backoff without jitter still create a storm?
3. What must a real idempotency record bind together?
4. Why can a green dependency dashboard coexist with an open circuit?
5. What is the difference between rate and concurrency?
6. When does a queue make an outage longer?
7. What evidence proves a bulkhead protected critical work?
8. What must be verified after the dependency recovers?

Repeat after one day and one week using a different system. Retrieval, not rereading alone, builds durable recall.

## Complete answers

1. **Twenty-seven leaf attempts.** Three gateway attempts can each create three service attempts, and each of those can create three dependency attempts: 3 x 3 x 3. The bound assumes every layer reaches its maximum. The operational lesson is to count attempts per original operation and centralize the total budget.

2. **Deterministic delays preserve synchronization.** Clients that fail together sleep for the same 100, 200 and 400 ms and wake together. Jitter randomizes each bounded delay so arrivals spread. It reduces correlation; it does not make unsafe retries safe.

3. **Identity, intention and outcome.** Bind the key to authenticated principal or tenant, operation type and canonical request fingerprint. Store claim state, ownership or fencing, terminal result, side-effect reference, timestamps and expiry. Matching replay returns the stored outcome; a changed payload conflicts. Expiry follows the business duplicate window, and uncertain states have reconciliation.

4. **They describe different populations.** A circuit sees one caller's route, DNS answer, region, network, time window and thresholds. The dependency dashboard may aggregate other healthy callers or exclude the failing path. Inspect sample size, failure classes, path and probes before changing policy.

5. **Rate measures starts over time; concurrency measures simultaneous in-flight work.** By Little's Law intuition, concurrency is approximately rate multiplied by average time for a stable boundary. One hundred requests per second taking two seconds need about 200 in flight. Limiting only rate can still exhaust workers when latency rises.

6. **When wait exceeds usefulness or capacity.** If arrival exceeds departure, oldest age rises. Expired work consumes memory and later service time, users create replacements, and recovery must drain stale backlog. Bound count and age, reject before expensive work, and cancel what no longer has value.

7. **Compare populations during the same disturbance.** Show optional or noisy-lane saturation and rejection while critical-lane concurrency remains inside its reserve and critical goodput, latency and correctness meet the stated objective. A configured pool size alone proves no protection.

8. **Stable recovery and correctness.** Verify limited probes converge, original-to-attempt ratio returns to baseline, queues drain at a controlled rate, no retry wave appears, circuits close by scope, degraded paths restore, uncertain side effects reconcile, user SLIs recover and the error-budget impact is recorded.

Senior rule: **do not ask whether retries or breakers are good. Ask which user operation, failure class, correctness contract, remaining deadline, scarce resource and recovery path they serve.**

## Product-company interview

**A downstream service times out. Would you retry?**

I would first classify the operation and the failure point. For a safe read with enough remaining deadline, no overload signal and an available global retry budget, one bounded retry with exponential backoff and jitter may improve success. For a side effect after the request may have been sent, the outcome is unknown; I use a stable idempotency key and durable outcome lookup or reconciliation. I also verify that one layer owns retries so attempts do not multiply.

**How do you choose timeouts?**

Start from the user journey's end-to-end deadline and measured latency distribution, including network, queue, service, dependency and return guard. Allocate downstream attempt budgets inside the remaining time, account for connection setup and false-timeout tolerance, and propagate cancellation. Validate under normal tails, dependency delay and overload. I do not copy the same timeout to every hop.

**Explain a circuit breaker and its failure modes.**

A breaker is a caller-side state machine. Closed calls collect rolling evidence; enough failures or slow calls open it for cheap rejection; half-open permits limited probes; success closes it and failure reopens it. Failure modes include tiny samples, thresholds that flap, global scope hiding healthy cohorts, per-instance probe storms, stale state, expensive fallbacks and manual force-close stampedes. It protects capacity; it does not heal or universally diagnose the dependency.

**How would you prevent retry amplification?**

Label original operations and attempts, calculate maximum leaf amplification, make one layer the retry owner, cap retries as a fraction of original traffic or a token budget, require remaining deadline and retryable semantics, use exponential backoff with jitter, honor overload rejection cautiously, and disable or reduce retries during shared overload. I would alert on attempt ratio and recovery waves.

**How do you make a payment API idempotent?**

Require a high-entropy operation key scoped to the authenticated principal. Canonicalize and fingerprint the request. Atomically claim the key with the payment transaction or a durable state machine, store terminal outcome and payment reference, return the same result for matching replays, reject changed payloads, and reconcile in-progress or unknown states after crashes. Retain the record beyond the allowed client replay and business duplicate window.

**Bulkhead versus rate limit?**

A bulkhead reserves a scarce in-flight resource or queue lane so failure in one class cannot consume all capacity. A rate limit controls admissions per time interval. They solve different dimensions: slow work can exhaust concurrency below a rate limit, while brief fast bursts can exceed a downstream rate despite available workers. I often combine per-tenant rate, global concurrency, critical reserve and bounded queue age.

**What does graceful degradation mean?**

It means deliberately serving a cheaper, explicitly correct product mode: for example, checkout without recommendations, not a fabricated payment success. The contract defines trigger, eligible users, data freshness, security behavior, observability, capacity of the fallback, restoration and reconciliation. It is tested before incidents.

**The dependency recovered, but the incident continues. Why?**

Callers may release synchronized retries, breakers may probe too aggressively, connection pools may reconnect together, and queued work may drain faster than the dependency's recovered capacity. I would pace probes and drain, retain critical admission, jitter retries, expire worthless work, reconcile side effects and watch attempt ratio, queue age, dependency saturation and user goodput until stable.

## Independent transfer and rubric

Complete ASM-0093 on a materially different reviewer-held system. No model answer is available to the learner.

Required evidence:

- user journey, correctness objective, deadline and cancellation boundary;
- operation-versus-attempt accounting and maximum amplification;
- failure classification and retry decision matrix;
- total retry ownership, budget, backoff, jitter and overload behavior;
- idempotency state machine, atomicity boundary, conflict, expiry and reconciliation;
- circuit scope, rolling evidence, minimum sample, open interval and probe policy;
- rate and concurrency limits, bulkhead reserves, borrowing and fairness;
- queue count, age, memory, expiry, priority and drain policy;
- admission, shedding and degraded-response contract;
- safe baseline, bounded fault, abort, rollback, recovery and cleanup plan;
- operations, attempts, deadline, rejection, isolation, correctness and recovery telemetry;
- security, cost, capacity and stakeholder trade-offs;
- proof limits and at least two plausible alternative failure explanations.

Rubric, 100 points:

| Dimension | Points | Full-credit evidence |
|---|---:|---|
| Journey and correctness | 8 | Exact user intention, success semantics, side effects and exclusions. |
| Deadline path | 8 | End-to-end budget, per-hop arithmetic, cancellation and guard time. |
| Failure classification | 8 | Connect/send/response/semantic/overload distinctions and unknown outcomes. |
| Retry control | 10 | One owner, amplification math, global budget, backoff, jitter and stop rules. |
| Idempotency | 12 | Principal, fingerprint, atomic claim, outcomes, conflicts, expiry and reconciliation. |
| Circuit design | 8 | Scope, sample, window, thresholds, probes, fallback and false-open analysis. |
| Isolation and fairness | 10 | Rate, concurrency, bulkheads, reserves, tenant policy and borrowing limits. |
| Queue and overload | 10 | Age/count bounds, admission, shedding, degradation and recovery drain. |
| Observability | 8 | Correlated operations, attempts, budgets, states, rejects and user goodput. |
| Test and recovery safety | 8 | Authority, bounded injection, abort, rollback, reconciliation and cleanup. |
| Security, capacity and cost | 5 | Abuse, retention, fallback capacity and cost per successful operation. |
| Communication | 5 | Assumptions, alternatives, proof limits, owner and review trigger. |

Passing one review proves only that one artifact met this rubric. Mastery requires delayed reassessment on a second unseen system and safe supervised production transfer.

## References and review

Reference records REF-0304 through REF-0318 anchor this lesson in primary standards and official engineering guidance:

- Google SRE guidance on cascading failures, overload and reliable service behavior;
- AWS Builders' Library guidance on timeouts, retries, backoff, jitter and overload control;
- gRPC guidance on deadlines, cancellation, retry and throttling;
- IETF HTTP semantics and status-code guidance for idempotency, Retry-After and 429;
- Envoy circuit-breaking and overload-manager behavior;
- Microsoft architecture patterns for transient faults, circuit breakers, bulkheads and retry storms.

These sources use different scopes. HTTP method idempotency is not the same as business side-effect idempotency. A proxy breaker is not every client library's state machine. A provider pattern is design guidance, not a production default. This chapter states the boundary before transferring a rule.

Review checklist:

- Is one end-to-end deadline propagated and reduced at every hop?
- Can cancellation stop work that is no longer useful?
- Are operations and attempts measured separately?
- Is retry ownership singular and globally bounded?
- Are retries gated by failure class, semantics, remaining time and overload?
- Does random jitter prevent synchronized retry waves?
- Are side effects protected by durable atomic idempotency and reconciliation?
- Are circuit scope, sample count, thresholds and probes explicit?
- Are critical concurrency and queue capacity isolated from noisy work?
- Are rate, concurrency, queue age and dependency quota all visible?
- Is shedding ordered by an approved product and fairness policy?
- Is degraded output explicitly correct, secure and observable?
- Does the recovery plan pace probes and backlog drain?
- Are uncertain outcomes reconciled after recovery?
- Are policy rollout, rollback, ownership and review triggers recorded?

Review this lesson after material changes to cited standards or implementations, or sooner after any retry storm, duplicate side effect, breaker stampede, isolation failure, queue collapse or unsafe degradation incident. The scheduled review date is 2027-02-04.
