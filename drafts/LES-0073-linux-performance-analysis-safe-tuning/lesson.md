---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0073",
  "slug": "linux-performance-analysis-safe-tuning",
  "aliases": ["V01-L09", "linux-performance-analysis-safe-tuning"],
  "curriculumIds": ["LNX-008"],
  "route": "/book/linux/performance-analysis-safe-tuning",
  "order": 9,
  "volume": "01-linux-systems",
  "title": "Linux performance engineering: evidence, profiling, safe tuning, and rollback",
  "summary": "Diagnose Linux performance from the user outcome through resource boundaries, counters, pressure and profiles; then run one-variable tuning experiments with security review, canaries, rollback and sustained proof.",
  "domain": "linux",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0002", "LES-0003", "LES-0010", "LES-0011", "LES-0026", "LES-0072"],
  "prerequisiteCurriculumIds": ["LNX-001", "LNX-002", "LNX-003", "LNX-004", "LNX-005", "LNX-006", "LNX-007", "OBS-001", "SEC-003"],
  "testedEnvironments": [
    {"platform": "Primary, official and original-author sources", "version": "Linux kernel, Ubuntu, Linux man-pages, systemd and Brendan Gregg sources reviewed 2026-08-07", "support": "concept-only", "notes": "Sources define mechanisms and methods; they do not prove workload performance or a safe production tuning value."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic 43-case decision model only; it performs no load, profiling or host observation and changes no setting."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON evaluation only; no benchmark, perf event, trace, sysctl, cgroup or service operation."},
    {"platform": "Representative Linux service fleet", "version": "not available", "support": "unsupported", "notes": "No representative workload, statistically reviewed experiment, tuning, profile, tracing, hardening, production or performance-improvement claim."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "linux-engineer", "performance-engineer", "cloud-engineer", "kubernetes-engineer", "infrastructure-engineer", "technical-lead"],
  "learningObjectives": [
    "Translate a complaint such as slow or high load into a bounded user operation, target distribution, throughput, errors and operating constraints.",
    "Build comparable repeated baselines with exact workload, traffic, environment, cache, dependency and time identity.",
    "Apply utilization, saturation and errors to CPU, memory, storage and network at host, process and cgroup boundaries.",
    "Decode load average, CPU accounting, vmstat, PSI, process, cgroup, device and network evidence without confusing units, scopes or cumulative counters.",
    "Separate resource capacity, resource policy, inefficient work, contention, dependency wait and measurement error.",
    "Write ranked hypotheses and choose commands or experiments for their ability to distinguish them.",
    "Use perf events, on-CPU profiles, off-CPU reasoning, tracing and flame graphs with correct scope, symbol, sampling and causality limits.",
    "Bound profiler overhead, monitoring privilege, captured-data sensitivity and audit requirements.",
    "Evaluate sysctl, systemd, cgroup and TuneD changes from exact versioned semantics rather than copied values.",
    "Design a one-variable representative canary with predeclared user, resource, neighbor, security, capacity, cost and rollback gates.",
    "Compare before and after distributions honestly, including variance, delayed effects, failed hypotheses and remaining uncertainty.",
    "Operate tuning as versioned state with bounded rollout, drift detection, rollback rehearsal and reusable experiment records."
  ],
  "productionSignals": [
    "user operation route tenant region status outcome latency histogram throughput errors and timeout",
    "experiment ID owner start end workload version configuration traffic mix concurrency data size warm-up cache and dependency identity",
    "host OS kernel boot image CPU topology NUMA memory device filesystem interface firmware and virtualization identity",
    "CPU user system idle iowait steal IRQ frequency thermal run queue context switches pressure throttling and machine errors",
    "memory available working set anonymous file cache slab faults reclaim swap pressure cgroup events OOM and hardware errors",
    "storage exact path mount filesystem device mapper physical device throughput utilization queue depth latency writeback flush and errors",
    "network request path interface speed utilization queue drops retransmits backlog latency softirq and driver errors",
    "process PID start time executable digest threads states CPU memory faults I/O descriptors context switches and wait channel",
    "cgroup path controllers cpu.max cpu.stat memory current high max events io stat max pressure and systemd unit properties",
    "counter source unit type scope sample interval reset wrap scaling collection delay and known limitation",
    "profile kernel tool event frequency duration process cgroup CPU call graph symbols lost samples multiplex ratio and overhead",
    "hypothesis predicted evidence disconfirming evidence confidence owner and next experiment",
    "tunable exact source version current default proposed value mechanism affected boundary compatibility and security impact",
    "canary population load representation stop thresholds rollback identity and observation duration",
    "before after sample counts distributions effect size variance errors neighbor security capacity cost and delayed regression",
    "rollout batch convergence drift exception expiry knowledge record and review trigger"
  ],
  "diagrams": [
    {"id": "LES-0073-DIA-001", "title": "User outcome to Linux resource path", "direction": "left-to-right", "boundaries": ["client operation", "service queue", "process and threads", "cgroup policy", "kernel scheduler and memory", "filesystem device and network", "dependency"], "evidencePoints": ["latency throughput errors", "queue wait", "states and stacks", "throttling and pressure", "CPU faults reclaim", "latency drops retransmits", "downstream time"], "textAlternative": "A slow operation crosses application queues, processes, resource policy, kernel subsystems, devices, network and dependencies; evidence must locate the waiting boundary."},
    {"id": "LES-0073-DIA-002", "title": "USE resource matrix", "direction": "top-to-bottom", "boundaries": ["CPU", "memory", "storage", "network", "utilization", "saturation", "errors"], "evidencePoints": ["busy and entitlement", "working set and limits", "device work", "link work", "run queue and throttling", "pressure reclaim queues", "faults drops failures"], "textAlternative": "For every resource, check utilization, saturation and errors at the correct host, process, cgroup or device boundary."},
    {"id": "LES-0073-DIA-003", "title": "Counter evidence contract", "direction": "left-to-right", "boundaries": ["kernel event", "accounting or sampling", "counter or gauge", "collector interval", "derived rate", "interpretation"], "evidencePoints": ["event semantics", "collection mechanism", "unit and scope", "timestamps", "delta reset scaling", "limitation"], "textAlternative": "A displayed number is interpreted only after its event, collection, type, unit, scope, interval, derivation and limitations are known."},
    {"id": "LES-0073-DIA-004", "title": "Hypothesis to profile ladder", "direction": "top-to-bottom", "boundaries": ["user symptom", "broad resource evidence", "process and cgroup scope", "on-CPU or off-CPU question", "profile or trace", "code or policy mechanism"], "evidencePoints": ["distribution", "USE", "identity", "task state", "samples events overhead", "disconfirming test"], "textAlternative": "Narrow from the user symptom to a resource and task boundary before selecting an on-CPU profile, off-CPU analysis or specific trace."},
    {"id": "LES-0073-DIA-005", "title": "Safe tuning experiment loop", "direction": "cyclic", "boundaries": ["objective and baseline", "hypothesis", "one versioned change", "representative canary", "gates", "compare and soak", "expand or rollback"], "evidencePoints": ["identity", "prediction", "semantics", "load", "user resource neighbor security", "distribution and delayed effects", "convergence"], "textAlternative": "A tuning change is one reversible variable tested against a comparable baseline in a representative canary before expansion or rollback."},
    {"id": "LES-0073-DIA-006", "title": "Performance security reliability trade-off", "direction": "cyclic", "boundaries": ["performance outcome", "security boundary", "reliability and recovery"], "evidencePoints": ["latency throughput efficiency", "privilege data exposure isolation", "errors capacity rollback"], "textAlternative": "A change is acceptable only when measured performance improves without unowned security or reliability regression and recovery remains available."}
  ],
  "commands": [
    {"id": "LES-0073-CMD-001", "question": "What exact Linux and CPU topology am I measuring?", "risk": "read-only", "command": "uname -a; lscpu", "runFrom": "owned Ubuntu host", "expectedBranches": [{"when": "identity matches experiment", "meaning": "kernel and visible CPU topology are comparable inputs", "nextEvidence": "virtualization, frequency, NUMA and workload identity"}, {"when": "identity differs", "meaning": "before and after may not be comparable", "nextEvidence": "stop and reconcile environment"}], "proves": "reported kernel and CPU topology at observation time", "doesNotProve": "effective firmware, stable frequency, thermal state or workload equivalence"},
    {"id": "LES-0073-CMD-002", "question": "How much runnable or uninterruptible demand is summarized now?", "risk": "read-only", "command": "uptime; cat /proc/loadavg", "runFrom": "owned Ubuntu host", "expectedBranches": [{"when": "load is low relative to CPUs", "meaning": "aggregate demand is currently modest", "nextEvidence": "user latency and scoped resource policy"}, {"when": "load is high", "meaning": "runnable or uninterruptible tasks may be accumulating", "nextEvidence": "task states, CPU run queue, I/O waits and cgroup scope"}], "proves": "load averages and immediate runnable/total task summary", "doesNotProve": "CPU utilization, root cause, per-service saturation or historical incident state"},
    {"id": "LES-0073-CMD-003", "question": "Which CPU, memory, scheduling and I/O counters change over short intervals?", "risk": "sampled-read-only", "command": "vmstat -w 1 5", "runFrom": "owned low-risk observation window", "expectedBranches": [{"when": "run queue and CPU busy rise", "meaning": "CPU demand hypothesis strengthens", "nextEvidence": "per-CPU, process and cgroup evidence"}, {"when": "blocked tasks, swap or I/O wait rise", "meaning": "memory or I/O wait hypothesis strengthens", "nextEvidence": "PSI, process states and exact device path"}], "proves": "five one-second samples of selected aggregate counters", "doesNotProve": "which process caused them, latency distribution or causality"},
    {"id": "LES-0073-CMD-004", "question": "Are tasks losing productive time to CPU, memory or I/O contention?", "risk": "read-only", "command": "printf 'CPU pressure\\n'; cat /proc/pressure/cpu; printf 'Memory pressure\\n'; cat /proc/pressure/memory; printf 'I/O pressure\\n'; cat /proc/pressure/io", "runFrom": "owned Linux host with PSI", "expectedBranches": [{"when": "some or full deltas rise", "meaning": "tasks experienced resource stalls under PSI semantics", "nextEvidence": "align with user window and cgroup pressure"}, {"when": "values stay flat", "meaning": "that observed scope shows little stall growth", "nextEvidence": "check workload locality, policy and other waits"}], "proves": "current aggregate PSI fields and totals", "doesNotProve": "causal process, past window without deltas or user impact"},
    {"id": "LES-0073-CMD-005", "question": "Which threads and task states consume or wait during the symptom?", "risk": "sampled-read-only", "command": "pidstat -u -r -d -w -p 1234 1 5", "runFrom": "owned process after replacing 1234 with a verified PID and start identity", "expectedBranches": [{"when": "CPU or context-switch activity concentrates", "meaning": "process or thread demand is visible", "nextEvidence": "thread view and scoped profile"}, {"when": "I/O or faults dominate", "meaning": "wait or memory hypotheses strengthen", "nextEvidence": "exact device, mappings, pressure and events"}], "proves": "sampled process accounting exposed by installed pidstat", "doesNotProve": "kernel causality, dependency time, complete threads or correctness of an unverified PID"},
    {"id": "LES-0073-CMD-006", "question": "Is the workload limited or pressured by its cgroup rather than the host?", "risk": "read-only", "command": "systemctl show example.service -p ControlGroup -p CPUQuotaPerSecUSec -p MemoryCurrent -p MemoryMax", "runFrom": "owned systemd service after replacing example.service with a verified unit", "expectedBranches": [{"when": "finite policy or pressure exists", "meaning": "service-local entitlement may own saturation", "nextEvidence": "read matching cgroup cpu.stat, memory.events and pressure deltas"}, {"when": "no relevant limit", "meaning": "this policy view does not explain the symptom", "nextEvidence": "continue resource and application hypotheses"}], "proves": "systemd-reported properties for the selected unit", "doesNotProve": "runtime demand, all controller files, Kubernetes policy or causal throttling"},
    {"id": "LES-0073-CMD-007", "question": "Which exact block device is busy, queued or slow?", "risk": "sampled-read-only", "command": "iostat -xz 1 5", "runFrom": "owned Ubuntu host after path-to-device mapping", "expectedBranches": [{"when": "latency and queue grow with workload", "meaning": "device saturation hypothesis strengthens", "nextEvidence": "filesystem, mapper, process I/O and error evidence"}, {"when": "device stays healthy", "meaning": "storage is less supported as the current bottleneck", "nextEvidence": "do not tune writeback from folklore"}], "proves": "sampled device counters calculated by installed iostat", "doesNotProve": "application I/O ownership, durability, filesystem latency or storage-array internals"},
    {"id": "LES-0073-CMD-008", "question": "Are network queues, drops or errors visible on the request path?", "risk": "read-only", "command": "ss -s; ip -s link", "runFrom": "owned network namespace", "expectedBranches": [{"when": "drops, errors or large socket states appear", "meaning": "network hypothesis needs scoped path evidence", "nextEvidence": "interface queues, retransmits, namespaces and peers"}, {"when": "counters appear quiet", "meaning": "this snapshot does not support local interface failure", "nextEvidence": "align deltas and inspect the complete path"}], "proves": "local namespace socket summary and interface counters", "doesNotProve": "end-to-end latency, remote hops or cause without interval deltas"},
    {"id": "LES-0073-CMD-009", "question": "Which performance events accumulate for one verified process interval?", "risk": "sampled-read-only", "command": "perf stat -p 1234 -- sleep 10", "runFrom": "approved scoped observation after replacing 1234 with a verified PID", "expectedBranches": [{"when": "events are available and scaled well", "meaning": "counts support a CPU mechanism hypothesis", "nextEvidence": "repeat and compare with workload output"}, {"when": "unsupported, multiplexed heavily or denied", "meaning": "the evidence is incomplete", "nextEvidence": "record limitation; do not escalate privilege casually"}], "proves": "perf event counts for selected PID and interval under available permissions", "doesNotProve": "hot code paths, user latency causality or correctness when PID identity changes"},
    {"id": "LES-0073-CMD-010", "question": "Where do bounded on-CPU samples land for the verified process?", "risk": "mutating-bounded", "command": "perf record -F 99 -g -p 1234 -o /tmp/les0073-perf.data -- sleep 15", "runFrom": "approved synthetic or representative canary after replacing 1234 with a verified PID", "expectedBranches": [{"when": "symbols and stacks resolve with low loss", "meaning": "sample distribution can guide code hypotheses", "nextEvidence": "perf report plus source and disconfirming test"}, {"when": "unknown stacks, loss or overhead is high", "meaning": "profile quality is insufficient", "nextEvidence": "fix scope/symbols or choose another method"}], "proves": "a bounded local perf.data sample artifact for selected scope", "doesNotProve": "off-CPU time, inherent waste, complete calls or safe optimization", "cleanup": "rm -- /tmp/les0073-perf.data"},
    {"id": "LES-0073-CMD-011", "question": "What functions and call paths dominate the reviewed sample artifact?", "risk": "read-only", "command": "perf report --stdio -i /tmp/les0073-perf.data", "runFrom": "same trusted environment that created the bounded artifact", "expectedBranches": [{"when": "expected symbols dominate", "meaning": "sampled on-CPU paths support a code hypothesis", "nextEvidence": "source review and controlled change"}, {"when": "kernel, unknown or unexpected paths dominate", "meaning": "scope, symbols or hypothesis needs correction", "nextEvidence": "validate build IDs, call graph and event"}], "proves": "reported distribution of recorded samples", "doesNotProve": "wall-clock contribution, causality or improvement from changing a wide frame"},
    {"id": "LES-0073-CMD-012", "question": "What tuning profile and selected VM values are currently declared?", "risk": "read-only", "command": "tuned-adm active 2>/dev/null || true; sysctl vm.swappiness vm.dirty_ratio vm.dirty_background_ratio", "runFrom": "owned Ubuntu host", "expectedBranches": [{"when": "known expected values", "meaning": "declared tuning identity matches experiment", "nextEvidence": "effective behavior and versioned source semantics"}, {"when": "unexpected or unavailable", "meaning": "configuration drift or tool absence exists", "nextEvidence": "inventory package/profile/config ownership before mutation"}], "proves": "reported active TuneD profile when available and selected sysctl values", "doesNotProve": "why values were chosen, workload benefit, complete profile contents or safe alternatives"}
  ],
  "labs": [
    {"id": "LES-0073-LAB-001", "title": "Guided performance experiment decision model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; no host observation or tuning", "timeMinutes": 240, "privilege": "normal user; root refused", "network": "none", "changes": ["one UID-scoped temporary root", "one copied synthetic 43-case fixture"], "abortConditions": ["root", "credential", "cloud profile", "cluster context", "Docker endpoint", "public target", "symlink", "wrong owner", "unknown artifact"], "recovery": "Preserve first failure and remove only exact allowlisted state.", "cleanupProof": "Exact inventory followed by state-root absence.", "path": "drafts/LES-0073-linux-performance-analysis-safe-tuning/support/lab"},
    {"id": "LES-0073-LAB-002", "title": "Independent unfamiliar performance regression and rollback", "mode": "independent", "environment": "Reviewer-owned disposable local Linux runtime with synthetic data and bounded workload", "timeMinutes": 240, "privilege": "normal-user analyst; reviewer retains privileged mutation, load and hidden-fault authority", "network": "loopback or isolated local network only", "changes": ["synthetic workload and evidence", "reviewer-approved one-variable canary", "four hidden interpretation, causality, security and recovery faults"], "abortConditions": ["production", "public target", "real credential", "customer data", "unapproved root or persistent tuning", "unbounded load or profile", "unknown rollback or cleanup"], "recovery": "Trigger predeclared stop, restore exact prior state, prove user and security behavior and preserve experiment evidence.", "cleanupProof": "Reviewer proves every file, process, port, setting and disposable environment absent.", "path": "drafts/LES-0073-linux-performance-analysis-safe-tuning/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0073-INC-001", "signal": "API p99 rises while host CPU remains below 40%, but service cgroup throttling and CPU pressure grow.", "firstThought": "Host headroom does not disprove workload-local CPU saturation.", "safePath": "Align user and cgroup deltas, validate process scope, canary one quota or code change and check neighbor/security gates.", "trap": "Declare CPU healthy from host average or raise every fleet quota."},
    {"id": "LES-0073-INC-002", "signal": "Load average is high with low CPU busy and many tasks in uninterruptible sleep.", "firstThought": "Load includes more than runnable CPU demand; identify task states and exact I/O/dependency boundary.", "safePath": "Map D-state tasks, PSI, process I/O, filesystem/device path and errors before changing schedulers or VM values.", "trap": "Add CPUs because load exceeds CPU count."},
    {"id": "LES-0073-INC-003", "signal": "A perf flame graph shows a wide function and the team rewrites it, but user latency does not improve.", "firstThought": "Sample frequency was confused with causal wall time or avoidable work.", "safePath": "Validate event/scope/symbols/overhead, check off-CPU paths and design a disconfirming controlled experiment.", "trap": "Optimize the widest frame without user or wait evidence."},
    {"id": "LES-0073-INC-004", "signal": "A throughput tuning profile improves a benchmark but increases production tail latency and power.", "firstThought": "The benchmark, workload objective or canary gates were incomplete.", "safePath": "Stop rollout, restore prior profile, validate delayed/user/neighbor/power evidence and redesign the representative experiment.", "trap": "Keep the profile because average throughput improved."},
    {"id": "LES-0073-INC-005", "signal": "Disabling a sandbox or broadening perf privileges appears to reduce overhead.", "firstThought": "A performance claim created security exposure and needs independent threat and measurement review.", "safePath": "Restore the control unless an approved bounded alternative exists, measure actual overhead, use least privilege and protect profile artifacts.", "trap": "Accept an unquantified security regression as a tuning optimization."}
  ],
  "assessmentIds": ["ASM-0202", "ASM-0203", "ASM-0204"],
  "referenceIds": ["REF-0853", "REF-0854", "REF-0855", "REF-0856", "REF-0857", "REF-0858", "REF-0859", "REF-0860", "REF-0861", "REF-0862", "REF-0863", "REF-0864", "REF-0865", "REF-0866", "REF-0867"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline lab is a decision model, not a benchmark, load generator, profiler, tracer, tuner or host-hardening tool.",
    "No host, sysctl, cgroup, systemd unit, package, profile, service, container, Kubernetes cluster, cloud resource or production system is inspected or changed.",
    "Counters, tools, events, privileges and tunables are kernel, hardware, distribution and version dependent; commands require exact environment and risk review.",
    "No statistically reviewed performance improvement, production safety, security-control overhead, capacity result or causal claim is made.",
    "Formal technical, performance, security and instructional review, representative experiments, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Linux performance engineering: evidence, profiling, safe tuning, and rollback

## What you see and first thought

### “The server is slow” is not yet a technical problem

When someone says “CPU is high,” “load is 20,” or “the server is slow,” resist the urge to open `top` and start tuning. Those phrases do not tell you:

- which user or batch operation is failing;
- whether latency, throughput, errors or cost changed;
- which population is affected;
- when it began;
- what workload and software version ran;
- which resource boundary owns the delay.

Your first move is to translate the complaint into an observable outcome:

> Checkout p99 rose from 220 ms to 1.1 s for the India region between 14:05 and 14:19 while throughput remained near 1,800 requests/s and timeout rate rose from 0.1% to 2.4%.

Now you have a window, operation, distribution, load and failure signal. Linux evidence can be aligned to that statement.

### The sentence that prevents most bad tuning

> Do not change a setting until you can state what mechanism it changes, what evidence predicts improvement, what else it can harm and how you will reverse it.

A sysctl copied from a blog is not expertise. A large dashboard is not causality. A benchmark improvement is not automatically a user improvement. Senior performance work is the discipline of making fewer, sharper claims.

### What to think when host CPU looks low

Do not conclude “not CPU.” Ask:

- Is one core saturated while the average hides it?
- Is the service single-threaded or lock-bound?
- Is the process restricted by `cpu.max`, systemd `CPUQuota=` or Kubernetes CPU limit?
- Is steal time reducing virtual CPU availability?
- Is frequency reduced by power or thermal policy?
- Are runnable tasks waiting even though other CPUs are idle because of affinity, cpuset or NUMA placement?

Capacity exists at a boundary. Eight visible CPUs on the host do not give a service eight CPUs if policy grants two.

### What to think when load average is high

Load average is not CPU percentage. It summarizes tasks that are runnable plus tasks in uninterruptible sleep. A high value can reflect CPU queues, storage waits or other kernel waits. Compare it with CPU count, task states, run queue, PSI, exact process/cgroup and device evidence.

The useful response is:

> Load tells me demand or uninterruptible wait is accumulating. I need to identify which tasks, which boundary and which resource before proposing capacity or tuning.

### What to think when memory is “almost full”

Linux uses otherwise idle memory for caches. A low `free` number alone is not a memory incident. Ask about available memory, workload working set, reclaim, faults, swap activity, memory PSI, cgroup `memory.high` or `memory.max` events, OOM evidence and user latency.

Do not drop caches to make a dashboard look empty. Cache is often the reason storage-backed work is fast.

### What to think when a flame graph has a wide frame

A wide frame means many selected samples included that stack path. It does not automatically mean:

- the function is wasteful;
- it caused wall-clock latency;
- it is safe to remove;
- an optimization will improve the user operation;
- waiting work was measured.

First validate event, scope, time, symbols, call graph, lost samples, overhead and workload. If the service spends wall time asleep on locks, I/O or dependencies, an on-CPU flame graph can faithfully show only the minority of time when it was executing.

### The operating promise

This chapter teaches a loop:

1. define the user outcome and experiment identity;
2. establish a comparable repeated baseline;
3. locate utilization, saturation and errors at the right boundary;
4. form competing hypotheses;
5. profile or trace only to distinguish them;
6. change one reversible variable;
7. canary against predeclared gates;
8. compare, soak, expand or roll back;
9. preserve the result and monitor drift.

## Terms before commands

### Performance

Performance is observed behavior under stated conditions. It is not a single number. Common dimensions are latency, throughput, concurrency, errors, resource efficiency, capacity, power and cost.

Always attach a workload and environment. “This host is fast” is incomplete. “Version A serves 2,000 equivalent requests/s with p99 below 250 ms on host class H under conditions C” is testable.

### Latency distribution and percentiles

Latency is elapsed time for an operation. Requests vary, so preserve a distribution. p50 is the value at or below which roughly half the observations fall; p99 is the value at or below which roughly 99% fall. Percentiles are not individual request IDs and cannot be averaged naively across differently weighted populations.

Tail latency matters because queues, retries, pauses and shared dependencies often hurt a minority severely before the average moves much.

### Throughput

Throughput is completed work per unit time: requests/s, jobs/minute, bytes/s or transactions/s. State whether failed work counts. Higher throughput with higher timeout or retry rate may be less useful work.

### Concurrency

Concurrency is work in progress. It is not throughput. If arrivals exceed completions, concurrency and queues grow. Little's Law relates long-run averages under stable conditions:

```text
average work in system = arrival/completion rate × average time in system
```

Use it as a consistency tool, not as permission to ignore burstiness or unstable queues.

### Utilization

Utilization describes how busy or occupied a resource is during a window. Meaning depends on the resource:

- CPU: fraction of scheduled time doing selected work;
- link: traffic relative to effective link capacity;
- device: fraction of time with I/O in progress, whose interpretation depends on device parallelism;
- memory: occupancy is not identical to busyness because reclaimability and policy matter.

At 100% utilization, some resources may still accept parallel work; others queue sharply. Therefore utilization alone is not saturation.

### Saturation

Saturation is demand waiting beyond immediate service: runnable tasks, throttled time, storage queues, socket backlog, allocator/reclaim stalls or PSI stall time. It connects more directly to delay.

A resource can be highly utilized without harmful saturation. A cgroup can be saturated while its host is underutilized.

### Errors

Errors include failed requests, timeouts, retransmissions, device errors, filesystem errors, OOM kills, machine-check events and collector failures. Performance analysis that ignores errors can celebrate a system that became “fast” by dropping work.

### USE method

USE means check **utilization, saturation and errors** for every relevant resource. It is a coverage method that helps you avoid staring at one favorite metric. It is not a proof that a resource caused the user symptom.

### Baseline

A baseline is a set of repeated observations under recorded conditions used for comparison. It includes workload, software, environment, policy, warm-up/cache, dependencies, time and sample method. Yesterday's production window may not be comparable if request mix or host class changed.

### Benchmark

A benchmark is a workload designed to measure selected behavior. A microbenchmark isolates a narrow mechanism; a representative benchmark approximates real traffic and dependencies. Neither is production automatically. State what it omits.

### Counter, gauge, histogram and profile

- A **counter** normally increases until reset or wrap. Compare deltas over time.
- A **gauge** represents a value at observation time.
- A **histogram** counts observations in value buckets and can preserve a distribution.
- A **profile** samples or records where selected events occur across code or stacks.

Treating cumulative `throttled_usec` as a current percentage is a type error.

### Scope and boundary

Scope says whose behavior a number represents: host, CPU, NUMA node, namespace, process, thread, cgroup, device, interface, container or service. The boundary also defines policy. A host counter cannot automatically explain a container.

### CPU time states

Linux tools often derive CPU percentages from `/proc/stat` deltas:

- **user**: non-kernel execution;
- **nice**: user execution with adjusted nice priority;
- **system**: kernel execution;
- **idle**: idle task time;
- **iowait**: accounting category associated with idle time while I/O is outstanding; not a direct device-latency meter;
- **irq/softirq**: interrupt work;
- **steal**: virtual CPU time taken by the hypervisor for other work;
- **guest**: virtual CPU guest execution accounting.

These are sampled/accounted views with limitations, not perfect continuous truth.

### Load average

The 1, 5 and 15 minute values are exponentially damped summaries, not literal averages of CPU percentage. Linux includes runnable and uninterruptible tasks. Interpret relative to CPU availability and task state, then narrow.

### Pressure Stall Information

PSI reports time tasks lose because CPU, memory or I/O resources are contended:

- `some`: at least some work is stalled;
- `full`: all non-idle work in the scope is stalled simultaneously, with documented resource-specific details;
- `avg10/60/300`: recent percentages over rolling windows;
- `total`: cumulative stall microseconds.

Use deltas and align windows. PSI tells you delay existed, not which line of application code caused it.

### Working set, reclaim and swap

The working set is memory actively needed over a useful interval. Reclaim recovers pages; file-backed cache may be dropped and reread. Swap moves eligible anonymous pages to storage. Swap configured or used is not alone proof of a current incident; active swap-in/out plus pressure and latency is stronger evidence.

### Page fault

A minor fault resolves without reading the page from storage, such as mapping an already available page or copy-on-write. A major fault requires I/O. Fault counts need process, interval and workload context.

### Cgroup resource policy

Cgroup v2 organizes processes and distributes or limits resources:

- weights influence proportional sharing under contention;
- limits cap consumption;
- protections defend selected memory;
- allocations reserve finite resources where supported.

`cpu.max`, `memory.high/max` and `io.max` can create local policy saturation. Policy is not physical host capacity.

### On-CPU and off-CPU

On-CPU analysis asks where a task executes while scheduled. Off-CPU analysis asks why it is not executing: sleep, lock, I/O, timer, scheduler wait or dependency. Choose based on the wall-time hypothesis.

### Sampling, tracing and instrumentation

Sampling observes a subset of events periodically or probabilistically and estimates frequency. Tracing records selected events, often with timestamps and fields. Instrumentation adds explicit measurement points. Each has coverage, overhead, privilege and data risks.

### Flame graph

A flame graph visualizes aggregated stacks. Vertical position is stack depth; horizontal width represents sample frequency, not chronological time. The x-axis ordering is usually arranged for aggregation. Differential and off-CPU variants answer different questions.

### Tuning

Tuning changes resource policy or subsystem behavior to improve a named outcome under constraints. It is not “setting larger numbers.” A tunable can trade latency for throughput, memory for I/O, power for speed, isolation for sharing or security for access.

### Canary, stop condition, rollback and soak

A canary is a small representative population that receives the change first. Stop conditions are written before seeing the result. Rollback restores exact prior state. Soak is sustained observation long enough to reveal delayed or phase-dependent effects.

## Architecture map

### The real request and resource path

```text
User request
  |
  v
load balancer -> service queue -> process -> thread/runtime
                                      |
                                      v
                               cgroup/systemd policy
                                      |
                         +------------+------------+
                         |            |            |
                         v            v            v
                    CPU/scheduler  memory/VM   filesystem/VFS
                         |            |            |
                         +------------+-----+------+
                                            |
                                      block device
                                            |
                  network <-> dependency <--+
```

A user can wait before the process runs, inside code, behind a lock, under a cgroup throttle, during reclaim, in a filesystem/device queue, on network retransmission or at a dependency. “Linux is slow” skips the path you must locate.

### USE matrix

| Resource | Utilization | Saturation | Errors |
|---|---|---|---|
| CPU | busy time, entitlement consumed, per-CPU balance | runnable queue, scheduler delay, cgroup throttling, CPU PSI | machine/thermal events, failed perf collection |
| Memory | working set, cache, cgroup current versus policy | reclaim, swap-in/out, memory PSI, `memory.high` events | OOM, allocation failures, ECC/RAS events |
| Storage | bytes/ops, device work, filesystem activity | queue depth, await/latency, I/O PSI, writeback stalls | device, transport, filesystem and timeout errors |
| Network | bytes/packets relative to effective link/path capacity | qdisc/socket backlog, softirq pressure, dependency queue | drops, retransmits, interface/driver/protocol errors |

The matrix is a question generator. Values are meaningful only after exact scope and semantics.

### Counter pipeline

```text
Kernel/hardware event
      -> accounting or sampling
      -> /proc, cgroupfs, tracefs, perf event
      -> tool collection interval
      -> delta/rate/percentage/histogram
      -> dashboard or report
      -> human claim
```

At every arrow, ask what can be lost, delayed, reset, scaled, aggregated or denied. The displayed percentage is several transformations away from reality.

### Hypothesis ladder

```text
User regression
  -> resource class from USE
  -> process/thread/cgroup/device boundary
  -> execution or wait question
  -> scoped counter/profile/trace
  -> predicted mechanism
  -> one-variable experiment
```

Jumping directly from “p99 is bad” to “change swappiness” skips every useful rung.

### Experiment loop

```text
Objective -> Comparable baseline -> Hypothesis -> One change
    ^                                             |
    |                                             v
Knowledge <- Soak <- Compare <- Canary and gates
    |                         |             |
    +------ expand -----------+             +-> rollback
```

The rollback branch is part of the architecture, not a failure to plan for success.

### Trade-off triangle

```text
                 Performance
               /             \
       efficiency             latency/throughput
             /                   \
       Security --------------- Reliability
 privilege, data,            capacity, errors,
 isolation, audit            recovery, neighbors
```

A change that wins only one corner is not production-ready. Disabling a sandbox may reduce measured overhead and still be the wrong decision. Raising every quota may help one tenant and break neighbors.

## Request or state path

### Path 1: establish the user truth

Begin outside Linux:

1. identify the operation and affected population;
2. record latency distribution, throughput and errors;
3. mark the exact regression window;
4. bind release, configuration, traffic mix and dependencies;
5. ask whether the measurement path itself changed.

If the dashboard changed histogram buckets during the release, the apparent p99 movement may be measurement drift. If traffic shifted from small reads to large writes, the same throughput number is not equivalent work.

### Path 2: establish experiment identity

Create an experiment record before collecting dozens of screenshots:

| Identity | Examples |
|---|---|
| workload | image or binary digest, config revision, feature flags, runtime |
| demand | route/job, request mix, rate, concurrency, payload/data set |
| environment | host class, kernel, CPU/NUMA, memory, devices, network |
| policy | systemd unit, cgroup path, quotas/weights/limits, hardening profile |
| dependencies | endpoints, versions, cache/database state, network path |
| method | tools/versions, intervals, clocks, warm-up, sample count |

Two windows that differ materially are observations, but not a controlled before/after pair.

### Path 3: broad USE scan

Use broad, low-overhead evidence to choose the next layer:

```text
user latency/throughput/errors
       |
       +-> CPU: busy + run queue/throttle/PSI + errors
       +-> memory: working set + reclaim/PSI + OOM/errors
       +-> storage: work + queue/latency/PSI + errors
       +-> network: traffic + queue/drop/retransmit + errors
```

Do not collect every possible metric. Ask which resource hypothesis gains or loses probability.

### Path 4: bind the owner

Suppose host CPU is 35%, service CPU is near 200%, `cpu.stat` throttled time rises and service-local CPU PSI rises. The likely owner is not physical CPU capacity; it is workload demand versus cgroup entitlement.

Suppose host I/O PSI rises, many relevant threads are in D state, exact mapped device latency/queue grows and filesystem errors appear. Now the storage path deserves priority.

The owner can be:

- application work or algorithm;
- concurrency/lock design;
- process/thread placement;
- cgroup or systemd policy;
- kernel subsystem;
- device or network;
- dependency;
- measurement/collection.

### Path 5: type the counter

For each important number, write:

```text
name:
source:
unit:
counter/gauge/histogram/sample:
scope:
start/end timestamps:
reset/wrap/scaling behavior:
known limitation:
```

Example: `throttled_usec` is a cumulative microsecond counter for a cgroup. To compare two intervals, subtract start from end and divide or relate it to the window and demand. The absolute total since cgroup creation is not “current throttle percent.”

### Path 6: form competing hypotheses

A useful hypothesis predicts evidence:

> If CPU quota causes the tail regression, then under equivalent load the affected cgroup will show increasing throttled time and CPU pressure aligned with p99; a representative canary with additional entitlement should reduce those signals and p99 without changing code.

Disconfirming evidence matters:

> If throttling remains unchanged or p99 does not respond while dependency time dominates, quota is insufficient as the primary cause.

Maintain alternatives so one attractive graph does not become a story.

### Path 7: profile or trace

Choose the method from the question:

- “Which code consumes scheduled CPU?” → on-CPU samples.
- “Why is the task asleep?” → off-CPU/wait or event evidence.
- “How often did this hardware/software event occur?” → perf stat/events.
- “Which exact kernel event and latency path occurred?” → bounded tracepoint/ftrace/BPF-style tracing.
- “Which request waited at which application span?” → application trace/instrumentation.

Validate permissions, scope, PID start identity, cgroup, event availability, symbols, call graphs, lost samples, multiplex scaling, clock and overhead.

### Path 8: design the change

An approved change record states:

- exact current and proposed value/version;
- source semantics for this kernel/distribution/tool version;
- mechanism and predicted evidence;
- one variable;
- representative canary;
- resource and security blast radius;
- user, neighbor and system stop gates;
- exact rollback;
- observation/soak duration.

### Path 9: compare and decide

Compare distributions under equivalent demand. Record sample count, central tendency, tail, errors, throughput, resource signals and variation. Do not report only the metric that improved.

Then:

- **expand** if the predicted mechanism and user outcome improve with no unacceptable regression;
- **rollback** if a gate breaches;
- **hold** if evidence is noisy or incomplete;
- **reject hypothesis** if the response contradicts it.

Negative results are valuable knowledge when preserved honestly.

## Failure zoom

### Incident 1: low host CPU, high service latency

**Signal:** API p99 increases sevenfold. Host CPU averages 35%. The systemd service has `CPUQuota=200%`; cgroup throttling and CPU pressure increase.

**First thought:** host headroom and service entitlement are different. The service may be saturated at its two-CPU boundary.

**Evidence path:**

1. verify service PID/start time, unit and cgroup;
2. align latency, throughput and errors with `cpu.stat` deltas;
3. check service-local pressure and per-thread CPU/run state;
4. inspect whether one thread, lock or code path owns demand;
5. compare a representative one-variable quota or code canary.

**Safe remediation:** grant measured canary headroom if policy is causal, or reduce confirmed CPU work. Protect host reserve and neighbors.

**Trap:** “CPU is only 35%, so add cache or blame storage.”

### Incident 2: high load, idle CPU

**Signal:** load average is 24 on an 8-vCPU host, but CPU is often idle. Many service threads show D state and I/O PSI rises.

**First thought:** load includes uninterruptible tasks; it is not 300% CPU utilization.

**Evidence path:**

- list relevant task states and wait channels carefully;
- map application path to filesystem, mapper and physical/virtual device;
- measure device queue/latency and process I/O over the same interval;
- inspect filesystem/device/kernel errors and dependency storage;
- distinguish writeback, direct I/O, remote storage and blocked kernel paths.

**Safe remediation:** address the verified storage/dependency mechanism, control demand or fail over through a tested path. Preserve data/durability promises.

**Trap:** add CPUs or change scheduler values because load exceeds CPU count.

### Incident 3: the wide flame-graph frame

**Signal:** a function occupies 45% of an on-CPU flame graph. A rewrite ships, but wall latency is unchanged.

**First thought:** the profile may accurately show scheduled CPU while the user waits elsewhere.

**Questions:**

- Was the event CPU cycles, wall-clock sampling or something else?
- Did the profile cover the affected process, cgroup and window?
- Were stacks and symbols valid?
- Were samples lost or multiplexed?
- Did profiling add material overhead?
- Is the service mostly sleeping on locks, I/O or dependencies?
- Is the wide function necessary work whose removal changes correctness?

**Safe path:** measure wall-time decomposition, off-CPU reasons and request spans; write a prediction; test an isolated change.

**Trap:** width equals waste.

### Incident 4: TuneD benchmark win, production tail loss

**Signal:** a throughput profile improves a synthetic benchmark by 12%, then production p99 and power consumption rise.

**First thought:** the optimized objective and production objective differ, or the benchmark/canary omitted important phases.

TuneD profiles can change multiple CPU, scheduler, disk, VM and network assumptions. They are starting points, not proof.

**Safe path:**

1. halt expansion on the predeclared tail/power gate;
2. restore the prior profile and verify recovery;
3. inspect exact profile version and settings;
4. identify which mechanism helped throughput and which hurt latency/power;
5. create narrower one-variable experiments with representative traffic.

**Trap:** keep the profile because one benchmark average is green.

### Incident 5: performance versus hardening

**Signal:** a team reports lower latency after weakening a sandbox or granting broad perf privilege.

**First thought:** measurement or execution authority changed the threat boundary. Quantify the benefit and assess whether a safer mechanism exists.

Profiling can expose execution paths and sensitive behavior. Disabling isolation can expand kernel, filesystem, namespace or network authority.

**Safe path:** restore the control if the change is unapproved; reproduce on disposable infrastructure; measure overhead with and without one exact control; use bounded capability such as approved `CAP_PERFMON` rather than broad `CAP_SYS_ADMIN` where supported; restrict profile artifacts; seek architectural alternatives.

**Trap:** security is “overhead,” therefore any performance improvement justifies removal.

## Internals and state ownership

### Who owns a displayed CPU percentage?

Tools usually read cumulative CPU-time fields from `/proc/stat` at two times, calculate deltas and express categories as a fraction of total delta. The kernel documentation notes that accounting can miss behavior between timer observations. Virtualization, CPU hotplug and tool formulas add context.

Therefore record:

- tool and version;
- sampling interval;
- CPU set and topology;
- host versus namespace/cgroup;
- guest/steal treatment;
- first sample semantics.

The first `vmstat` row often represents since-boot averages rather than the later interval rows. Read the tool manual for the installed version.

### Scheduler and run-queue ownership

Runnable threads wait for CPUs allowed by affinity, cpusets and scheduling policy. A host may have idle CPUs unavailable to the task. Per-CPU imbalance, single-thread limits, real-time tasks and virtualization can alter service time.

CPU utilization asks how much scheduled execution occurred. Run queue, scheduler delay, throttling and CPU PSI ask whether demand waited.

### Cgroup v2 ownership

Cgroup v2's hierarchy distributes policy:

- `cpu.weight` changes proportional share under contention;
- `cpu.max` caps bandwidth within a period;
- `cpu.stat` exposes usage and, when applicable, throttling fields;
- `memory.current` reports charged memory;
- `memory.high` applies a throttling/reclaim boundary;
- `memory.max` is a hard limit;
- `memory.events` records boundary events;
- `io.max` and weights shape device access;
- resource-specific `*.pressure` exposes scoped PSI.

Parent policy constrains children. Moving a process does not necessarily move every historical resource charge. Read the effective cgroup path and controller state rather than assuming a container label defines ownership.

### Systemd ownership

Systemd units map high-level properties to cgroups. `CPUWeight=` is relative under contention; `CPUQuota=` is a bandwidth cap. `MemoryHigh=` and `MemoryMax=` have different semantics. Runtime properties may differ from persistent unit configuration.

Before changing:

1. record unit, drop-ins and effective properties;
2. understand whether orchestration will reconcile them;
3. identify parent slice constraints;
4. capture prior persistent and runtime state;
5. test exact rollback.

### Memory ownership

Memory evidence spans:

- process mappings and resident/proportional sets;
- anonymous versus file-backed pages;
- page cache and reclaimable slab;
- cgroup charges and limits;
- NUMA locality;
- swap and faults;
- kernel reserves;
- device-backed or shared memory;
- hardware health.

`MemAvailable` is an estimate of memory available for new work without swapping, not a guarantee. RSS can double-count shared pages across processes; PSS apportions shared pages but costs more to collect. Cache can be productive.

### PSI ownership

System PSI in `/proc/pressure` aggregates the host scope. Cgroup v2 can expose pressure for tasks charged to that cgroup. The `total` value is cumulative microseconds; compute deltas. `avg10` is responsive but smoothed, so a brief spike can be visible in total before it meaningfully changes the average.

CPU `full` at system level has special documented semantics and historically reports zero for compatibility. Do not generalize one resource's `full` interpretation to all scopes.

### Storage ownership

An application path may map through:

```text
file -> mount -> filesystem -> logical volume/device mapper
     -> virtual disk -> host/storage network -> physical media
```

`iostat` device names do not automatically identify the user file. Device utilization on parallel storage is not a universal “percent capacity.” `await` combines queue and service components under tool semantics; it is not proof of application latency.

### Network ownership

Network behavior can live in another namespace, veth, bridge, overlay, physical NIC, load balancer or dependency. Interface counters are cumulative and may include drops at different layers. TCP retransmission signals loss or path behavior but not the failing hop by itself.

Tie the socket and namespace to the process, map the path, take interval deltas and preserve peer evidence.

### Perf-event ownership

`perf_event_open` selects event, PID/thread, CPU, inheritance, group and sampling behavior. Hardware support varies. More events than available counters can cause multiplexing; tools may scale counts. Access is governed by kernel security policy and capabilities.

A profile artifact needs:

- kernel and perf versions;
- build IDs and symbols;
- event and frequency/period;
- PID start identity, CPU/cgroup and time;
- call-graph method;
- sample/lost counts and scaling;
- observed overhead;
- data classification and retention.

### ftrace and BPF ownership

Tracefs exposes kernel tracers and events. BPF can attach programs to rich execution points. These are powerful and version-dependent; selection, privilege, verifier behavior, buffer loss and overhead matter. Broad trace collection can create both availability and confidentiality risk.

Use the narrowest event/filter/duration that distinguishes the hypothesis. Always define disable/cleanup and prove tracing is off afterward.

### Tuning-state ownership

A tunable can be set through:

- kernel command line;
- sysctl configuration and runtime writes;
- sysfs;
- systemd unit/slice properties;
- TuneD or another agent;
- container/orchestrator resource policy;
- application configuration.

If two owners reconcile the same setting, a manual change may disappear or create drift. The authoritative owner, desired value and rollback must be known before mutation.

## Evidence table

### Evidence is useful only within its boundary

| Signal | Question answered | Strong interpretation | Does not prove |
|---|---|---|---|
| user latency histogram | How long did named operations take? | tail or distribution changed for recorded population/window | Linux root cause |
| throughput plus errors | How much useful work completed? | completion rate and failure behavior under stated demand | latency safety or unused capacity |
| `/proc/loadavg` | Is runnable/uninterruptible demand summarized? | demand/wait accumulation relative to available CPUs | CPU percentage or causal resource |
| CPU time deltas | Where was accounted CPU time spent? | user/kernel/idle/steal categories for scope/window | scheduler delay or perfect continuous accounting |
| run queue/scheduler delay | Did runnable work wait? | CPU saturation at observed scheduling boundary | inefficient code path |
| cgroup `cpu.stat` deltas | Did usage/throttling grow? | policy-limited execution occurred in interval | user impact without alignment |
| CPU PSI | Did tasks lose time waiting for CPU? | partial stall growth in scope | which function caused demand |
| `MemAvailable` | What memory might be available without swapping? | kernel estimate for host snapshot | process working set or absence of pressure |
| memory PSI/reclaim/swap deltas | Did memory contention delay work? | active reclaim or stall behavior in interval | exact allocation owner without process/cgroup evidence |
| cgroup `memory.events` | Did policy thresholds/events occur? | scoped high/max/OOM-type event counts grew | host-wide memory shortage |
| device throughput/utilization | What work did a named device perform? | device activity during interval | application ownership or universal capacity percent |
| queue/await/latency | Did I/O wait accumulate? | device-path saturation hypothesis strengthens | filesystem, array or application cause alone |
| device/filesystem errors | Did storage operations fail? | observed failure at stated layer | that every timeout comes from that layer |
| interface bytes/packets | How much local link work occurred? | traffic delta for named namespace/interface | end-to-end capacity |
| drops/retransmits/backlog | Was network demand lost or queued? | path/queue hypothesis strengthens | failing hop without path evidence |
| `pidstat`/`/proc/PID` | What did a verified process do? | scoped CPU, memory, I/O, faults and switches | causal request without correlation |
| `perf stat` | Which selected events accumulated? | counts/rates for event, PID/CPU and interval | hot stacks or user causality |
| `perf record/report` | Where did selected samples land? | frequency across resolved stack paths | off-CPU time, waste or improvement |
| ftrace/tracepoint/BPF event | Did selected kernel events occur? | timestamped event evidence under filter | untraced paths or zero overhead |
| canary before/after | How did outcome respond to one change? | causal support under comparable conditions | fleet or long-term generalization |
| rollback test | Can prior state be restored? | observed recovery in tested path | every failure mode |

### Evidence strength ladder

From weaker to stronger for a causal performance claim:

1. an unaligned snapshot;
2. an aligned correlation;
3. a mechanism-consistent profile/trace;
4. a one-variable representative experiment;
5. repeated response and rollback;
6. sustained behavior across relevant phases and populations.

No single rung eliminates uncertainty. The ladder makes the claim proportional to evidence.

### Required counter annotation

Before a number enters a decision record, attach:

- source and tool version;
- kernel/hardware support;
- unit and type;
- scope and identity;
- collection start/end;
- interval or delta formula;
- reset/wrap/scaling behavior;
- missing/lost sample state;
- known limitations.

“CPU 80” is not evidence. “Service cgroup CPU usage increased 7.8 CPU-seconds during a 10-second window while throttled time increased 2.1 seconds under equivalent request load” can be reviewed.

### Evidence quality failure is a result

If perf lacks permission, the event is unsupported, symbols are unknown, a collector restarted or scanner-like extraction fails, record **unknown/incomplete**. Never translate missing performance evidence into zero saturation, zero events or healthy.

## Command decoders

### 1. `uname -a; lscpu` — bind the environment

Ask: **Am I comparing the same kernel and effective CPU topology?**

Decode `lscpu` fields:

- CPU(s): visible logical processors, not guaranteed service entitlement;
- core/socket/thread topology: affects parallelism and shared execution resources;
- NUMA nodes and CPU lists: placement can affect memory latency;
- hypervisor/vendor/model: affects counters and steal behavior;
- online/offline lists: capacity may differ from expected inventory.

Record output with host/image identity. Do not infer stable frequency, firmware or thermal state from it.

### 2. `uptime; cat /proc/loadavg` — read demand, not CPU percent

The three load values summarize recent runnable plus uninterruptible task demand. The fraction such as `3/812` reports currently runnable scheduling entities over total; the final number is the last created PID under proc semantics.

Interpret:

- load 8 on eight CPUs may be comfortable or saturated depending on task mix and policy;
- load 2 can still be severe for a one-CPU quota;
- high load plus idle CPU suggests uninterruptible waits, affinity/policy or uneven placement;
- a 15-minute value can remain elevated after recovery.

Next inspect states, run queues, PSI and cgroup entitlement.

### 3. `vmstat -w 1 5` — interval motion

Common columns:

- `r` runnable tasks;
- `b` tasks blocked in uninterruptible sleep;
- `swpd/free/buff/cache` memory views;
- `si/so` swap-in/out per interval;
- `bi/bo` blocks received/sent according to tool units;
- `in/cs` interrupts and context switches;
- `us/sy/id/wa/st` CPU categories.

The first row often represents since-boot averages; later rows represent requested intervals. One-second samples show motion but can miss subsecond bursts. Use them to choose a narrower question.

### 4. `/proc/pressure/{cpu,memory,io}` — lost productive time

Read `some`, `full`, three rolling percentages and cumulative `total` microseconds. Take two snapshots to calculate total growth. Compare host and cgroup scope when available.

High memory `full` can indicate all non-idle work in scope is stalled; CPU full has documented system-level special behavior. A zero average does not rule out a brief total increase.

### 5. `pidstat ... -p 1234 1 5` — process movement

Replace 1234 only after verifying PID and start time. Options request CPU, memory/page-fault, I/O and context-switch views. Exact columns depend on installed sysstat version.

Look for:

- CPU concentrated in one process/thread;
- major versus minor fault activity;
- read/write rates aligned to the operation;
- voluntary switches suggesting sleeps/waits;
- non-voluntary switches suggesting preemption.

PID reuse can attach a correct command to the wrong process. Preserve executable/cgroup/start identity.

### 6. `systemctl show example.service ...` — policy view

Replace the unit name. `ControlGroup` identifies the unit's cgroup path. CPU quota and memory properties expose selected systemd policy/accounting.

Then read the actual cgroup files for interval events. Parent slice limits can constrain the unit. A property displayed as infinity or unavailable does not prove unrestricted access at every ancestor.

### 7. `iostat -xz 1 5` — exact-device activity

Map the application path to the device before interpreting. Extended columns vary by sysstat version and device. Common concepts are reads/writes per second, bandwidth, request size, queue, await and utilization.

Do not use `%util=100` as a universal maximum for modern parallel devices. Align latency/queue with process I/O, filesystem path and errors.

### 8. `ss -s; ip -s link` — namespace-local network evidence

`ss -s` summarizes socket states. `ip -s link` shows interface packet/byte/error/drop counters. Both reflect the current network namespace.

Take deltas. Map veth/bridge/overlay/physical paths. Local quiet counters do not clear a remote load balancer, dependency or another namespace.

### 9. `perf stat -p 1234 -- sleep 10` — event counts

After PID verification, perf attaches selected default events for ten seconds. Interpret:

- event support and permission messages;
- enabled/running time and scaling;
- cycles, instructions and derived IPC only for the observed event conditions;
- context switches, faults and migrations where available.

IPC is not a universal quality score. Workload phase, CPU model, frequency and event multiplexing matter.

### 10. `perf record ...` — bounded sampled artifact

`-F 99` requests sample frequency, `-g` call graphs, `-p` process scope, `-o` output identity and `sleep 15` bounds duration. Confirm PID start identity before execution.

Measure overhead with and without profiling. Record lost samples and symbol/build-ID quality. The command creates sensitive `/tmp/les0073-perf.data` and must be cleaned exactly after approved analysis.

### 11. `perf report --stdio` — sample distribution

The report aggregates the recorded events. “Overhead” is share of selected samples under report rules. Children/self, call graph mode, unresolved symbols and DSOs change interpretation.

Use it to select source or wait hypotheses. Do not call a function wasteful because it is wide.

### 12. `tuned-adm active; sysctl ...` — declared tuning identity

TuneD may be absent, inactive or managed elsewhere. An active profile can include many plugins and settings; inspect its exact installed version and content. The sysctl command reads selected VM values only.

Do not mutate from this output. Kernel documentation warns that settings such as cache dropping, dirty thresholds, compaction and reserves can create latency, I/O, OOM or recovery effects. The next artifact is a reviewed experiment plan.
