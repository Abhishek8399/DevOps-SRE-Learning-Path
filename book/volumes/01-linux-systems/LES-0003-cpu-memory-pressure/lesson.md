---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0003",
  "aliases": ["V01-L03", "cpu-memory-pressure"],
  "curriculumIds": ["LNX-003"],
  "slug": "cpu-memory-pressure",
  "route": "/book/linux/cpu-memory-pressure",
  "order": 3,
  "volume": "01-linux-systems",
  "title": "CPU, load, memory pressure, swap, and OOM",
  "summary": "Read resource evidence as a time- and scope-bound story: distinguish utilization from saturation, free memory from available capacity, swap occupancy from active thrashing, host health from cgroup limits, and exit 137 from a proven OOM cause.",
  "domain": "linux",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 240,
  "prerequisiteLessonIds": ["LES-0002"],
  "prerequisiteCurriculumIds": ["LNX-002"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The walkthrough is normal-user and read-only; procps supplies uptime, vmstat, free, and ps."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04", "support": "supported", "notes": "Commands work, but CPUs, memory, pressure, swap, kernel logs, and cgroups belong to the WSL virtualized boundary rather than Windows."},
    {"platform": "Docker container", "version": "Linux container with cgroup v2", "support": "concept-only", "notes": "Host procfs may remain visible while CPU and memory eligibility are constrained by a container cgroup; inspect both scopes."},
    {"platform": "Kubernetes", "version": "Version-dependent", "support": "concept-only", "notes": "Pod metrics and termination status require exact Pod/container lifetime, node, runtime, and cgroup correlation."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer"],
  "learningObjectives": [
    "Explain CPU execution, runnable queues, Linux load average, utilization, saturation, latency, and pressure without treating them as interchangeable percentages.",
    "Decode every operationally important field in uptime, vmstat, free, PSI, ps, and cgroup v2 CPU and memory interfaces.",
    "Explain virtual memory, pages, anonymous memory, page cache, reclaim, working set, RSS, swap, page faults, and OOM as connected mechanisms.",
    "Separate host capacity from a process, container, or service cgroup boundary and align gauges, rates, counters, identities, and time windows.",
    "Diagnose exit 137 as a SIGKILL-shaped outcome while keeping cgroup OOM, host OOM, eviction, supervisor escalation, and manual kill as competing causes.",
    "Choose reversible recovery and size resources from measured demand, headroom, failure-domain capacity, service objectives, and cost rather than arbitrary percentages."
  ],
  "productionSignals": [
    "Latency rises while CPU utilization is high, low, or uneven across cores.",
    "Load average exceeds visible CPU count while CPUs still report idle time.",
    "MemFree is small although MemAvailable remains healthy.",
    "Swap is occupied but current swap-in and swap-out rates are near zero.",
    "Memory or I/O PSI rises before an application is killed.",
    "A container exits 137 while the node appears healthy.",
    "cgroup CPU throttling rises while host CPU remains idle.",
    "Working set, queue depth, garbage-collection time, or request size grows with traffic."
  ],
  "diagrams": [
    {"id": "LES-0003-DIA-001", "title": "Work to user outcome", "direction": "left-to-right", "boundaries": ["request arrivals", "application queues", "runnable or blocked tasks", "CPU scheduler", "memory allocation and reclaim", "dependencies", "response"], "evidencePoints": ["request rate and concurrency", "queue age", "vmstat r and b", "CPU time and PSI", "MemAvailable and memory PSI", "dependency latency", "user SLI"], "textAlternative": "Requests become queued work; threads are runnable or blocked; the scheduler grants CPU; memory allocation may reclaim or swap; dependencies complete; only the final response establishes user success."},
    {"id": "LES-0003-DIA-002", "title": "Host and cgroup resource boundaries", "direction": "hierarchical", "boundaries": ["physical or virtual host", "cgroup hierarchy", "service or container cgroup", "processes and threads"], "evidencePoints": ["host CPU and MemAvailable", "effective cpu.max and cpuset", "memory.current and memory.max", "cpu.stat and memory.events", "per-cgroup PSI", "PID and start time"], "textAlternative": "The host owns physical capacity; cgroup ancestors distribute it; a service cgroup constrains eligible CPU and memory; processes consume within that boundary, so a healthy host does not prove a healthy cgroup."},
    {"id": "LES-0003-DIA-003", "title": "Memory allocation outcome", "direction": "top-to-bottom", "boundaries": ["allocation request", "free page or reclaim", "page cache or anonymous page", "swap or writeback", "limit or global pressure", "allocation success, ENOMEM, or OOM victim"], "evidencePoints": ["memory.current", "memory.stat", "MemAvailable", "si and so rates", "memory.pressure", "memory.events delta", "kernel and runtime reason"], "textAlternative": "An allocation can use a free page, trigger reclaim, evict cache, swap anonymous pages, stall at a cgroup or host boundary, succeed, return an error, or lead an OOM killer to terminate a victim."}
  ],
  "commands": [
    {"id": "LES-0003-CMD-001", "question": "How many CPUs are visible, and what load populations were averaged?", "risk": "read-only", "command": "nproc; uptime; cat /proc/loadavg", "runFrom": "A normal-user shell in the exact host or namespace being diagnosed.", "expectedBranches": [{"when": "load is low relative to eligible CPUs", "meaning": "The averaged runnable-plus-D population is small for this view.", "nextEvidence": "Check user latency and cgroup constraints before calling it healthy."}, {"when": "load exceeds visible CPUs", "meaning": "Runnable or D-state population was elevated; CPU saturation is only one hypothesis.", "nextEvidence": "Use interval vmstat, task states, PSI, and cgroup eligibility."}], "proves": "Visible CPU count and the kernel load figures in this scope at this time.", "doesNotProve": "CPU saturation, a universal threshold, root cause, or user impact."},
    {"id": "LES-0003-CMD-002", "question": "What changes across short CPU, queue, swap, and I/O intervals?", "risk": "sampled-read-only", "command": "vmstat -y 1 5", "runFrom": "A normal-user Ubuntu shell during a timestamped symptom window.", "expectedBranches": [{"when": "r and CPU pressure rise with low id", "meaning": "Runnable demand is competing for eligible CPU.", "nextEvidence": "Inspect per-core use, cgroup quota/throttle, hot threads, and workload."}, {"when": "b or I/O pressure rises while id remains", "meaning": "Tasks are blocked rather than consuming available CPU.", "nextEvidence": "Inspect task state/wchan and the relevant storage or kernel dependency."}, {"when": "si and so stay active with memory pressure", "meaning": "Pages are moving through swap during the interval.", "nextEvidence": "Correlate latency, working set, reclaim, and workload before calling thrashing."}], "proves": "A bounded series of visible process, memory, swap, I/O, interrupt, context-switch, and CPU-accounting samples.", "doesNotProve": "Which process caused a field, device latency, application health, or historical peak."},
    {"id": "LES-0003-CMD-003", "question": "How much memory is immediately unused versus estimated available without swapping?", "risk": "read-only", "command": "free -h; grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SReclaimable|SwapTotal|SwapFree):' /proc/meminfo", "runFrom": "The same host or VM scope as the symptom.", "expectedBranches": [{"when": "free is low but available is healthy", "meaning": "Linux is using memory including reclaimable cache; low free alone is not pressure.", "nextEvidence": "Check PSI, reclaim activity, application latency, and cgroup headroom."}, {"when": "available falls and memory PSI or swap activity rises", "meaning": "Allocations increasingly require reclaim or stalls.", "nextEvidence": "Find workload and cgroup contributors, trends, and allocation failures."}], "proves": "Current host memory accounting fields and the kernel's MemAvailable estimate.", "doesNotProve": "Per-cgroup headroom, future allocation success, a leak, or an OOM cause."},
    {"id": "LES-0003-CMD-004", "question": "Are tasks losing useful time to CPU, memory, or I/O scarcity?", "risk": "read-only", "command": "cat /proc/pressure/cpu; cat /proc/pressure/memory; cat /proc/pressure/io", "runFrom": "A Linux host with PSI enabled; use equivalent cgroup files for workload scope.", "expectedBranches": [{"when": "some increases but full remains small", "meaning": "At least some tasks stalled while other work could still progress.", "nextEvidence": "Correlate total deltas and latency for the affected workload."}, {"when": "memory or I/O full rises during impact", "meaning": "All non-idle work in that scope was stalled together for part of the interval.", "nextEvidence": "Locate reclaim, swap, writeback, or I/O ownership and protect the user path."}], "proves": "Kernel-accounted stall ratios and cumulative stall time for the selected scope.", "doesNotProve": "A universal bad threshold, the responsible workload, or user impact without correlation."},
    {"id": "LES-0003-CMD-005", "question": "Which visible processes are large or active, and what states are they in?", "risk": "read-only", "command": "ps -eo pid,ppid,stat,ni,psr,pcpu,pmem,rss,vsz,comm --sort=-rss | head -n 20", "runFrom": "The relevant PID namespace; redact command names where required.", "expectedBranches": [{"when": "one RSS is large", "meaning": "That process has many resident pages in this snapshot.", "nextEvidence": "Compare its trend, mappings, cgroup charge, workload, and healthy peers."}, {"when": "many tasks show R or D", "meaning": "Visible runnable or uninterruptible-wait population is elevated.", "nextEvidence": "Inspect eligibility, threads, wait channels, PSI, and dependencies."}], "proves": "Visible point-in-time process metadata and approximate memory/accounting fields.", "doesNotProve": "Private ownership of every page, a leak, peak use, or service health."},
    {"id": "LES-0003-CMD-006", "question": "What CPU and memory boundaries and events apply to this exact process?", "risk": "read-only", "command": "cat /proc/PID/cgroup; cat /sys/fs/cgroup/PATH/cpu.max /sys/fs/cgroup/PATH/cpu.stat /sys/fs/cgroup/PATH/memory.current /sys/fs/cgroup/PATH/memory.max /sys/fs/cgroup/PATH/memory.events", "runFrom": "Replace PID and PATH only after identifying the exact process lifetime and cgroup v2 mount.", "expectedBranches": [{"when": "nr_throttled and throttled_usec increase", "meaning": "The cgroup exhausted CPU quota in sampled periods.", "nextEvidence": "Compare effective quota, demand, user latency, and ancestor limits."}, {"when": "oom_kill increases for the incident lifetime", "meaning": "An OOM killer terminated a process charged to this cgroup.", "nextEvidence": "Join runtime reason, victim identity, memory composition, workload, and host evidence."}, {"when": "files are absent or access is denied", "meaning": "The assumed cgroup version, path, lifetime, or permission boundary is incomplete.", "nextEvidence": "Inspect mountinfo, service/runtime metadata, and record the visibility gap."}], "proves": "Readable configuration and cumulative counters for the identified cgroup at read time.", "doesNotProve": "The event time without before/after values, application cause, ancestor state, or that exit 137 was OOM."}
  ],
  "labs": [
    {"id": "LES-0003-LAB-001", "title": "Read CPU and memory evidence on Ubuntu", "mode": "guided", "environment": "Ubuntu 24.04, normal user, procps installed", "timeMinutes": 20, "privilege": "No sudo or root; read-only observation only.", "network": "No network access.", "changes": ["No persistent or runtime mutation; vmstat waits for three one-second intervals."], "abortConditions": ["The shell is root.", "The platform is not Ubuntu.", "A required procps command is missing.", "The learner is tempted to generate artificial pressure on a shared machine."], "recovery": "No recovery is required because the walkthrough does not mutate state.", "cleanupProof": "bash lab.sh cleanup reports cleanup=not-required, mutation=none, and cleanup_proven=true.", "path": "book/labs/LES-0003-resource-pressure"}
  ],
  "incidents": [
    {"id": "LES-0003-INC-001", "signal": "Load is 18 on an eight-CPU VM while CPU idle is 62 percent.", "firstThought": "Load and CPU percentage measure different things; blocked work, eligibility, and timing remain open.", "safePath": "Align scope and time, read interval r/b and CPU fields, task states, PSI, cgroup quota, then the blocked dependency and user SLI.", "trap": "Scale CPU from load alone."},
    {"id": "LES-0003-INC-002", "signal": "MemFree is small and swap contains 3 GiB.", "firstThought": "Cache use and old swap occupancy may be normal; pressure requires current reclaim/stall and service evidence.", "safePath": "Read MemAvailable, vmstat si/so intervals, PSI, cgroup headroom, working-set trend, allocation errors, and latency.", "trap": "Drop caches or disable swap as the first action."},
    {"id": "LES-0003-INC-003", "signal": "A container exits 137 on a node with apparently free memory.", "firstThought": "SIGKILL-like termination is plausible, while cgroup OOM, host OOM, eviction, grace-timeout escalation, and an operator remain competing actors.", "safePath": "Preserve exact container lifetime, compare runtime reason with cgroup event deltas, host kernel/pressure evidence, deployment events, workload memory, and user impact.", "trap": "Declare OOM and double all limits from exit code alone."}
  ],
  "assessmentIds": ["ASM-0265", "ASM-0266", "ASM-0267"],
  "referenceIds": ["REF-1203", "REF-1204", "REF-1205", "REF-1206", "REF-1207", "REF-1208"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-09-02",
  "reviewAfter": "2027-03-02",
  "limitations": [
    "The guided walkthrough observes naturally occurring state and intentionally creates no pressure, allocation failure, swap activity, cgroup throttling, or OOM.",
    "Example output is illustrative; kernel, procps, virtualization, container runtime, and cgroup configuration change visible fields.",
    "No universal utilization, load, PSI, memory, or swap threshold is prescribed; objectives and workload behavior define acceptable limits.",
    "Formal technical review, real-browser QA, representative service testing, independent learner transfer, delayed recall, and mastery remain unproved."
  ]
}
---

# CPU, load, memory pressure, swap, and OOM

## What you see and first thought

The page says **CPU 95%**, **load 18**, **free memory 2%**, or **exit 137**. These look like diagnoses because dashboards place them in large type. They are not diagnoses. They are observations made by a particular collector, for a particular scope, over a particular window.

Keep this habit: **resource numbers describe where work spent time; the user journey tells you whether that time mattered.** Start with the failing operation and timestamp. Then ask what was runnable, what was blocked, which CPUs it could use, which memory boundary charged it, and what changed.

- 95% CPU can be healthy throughput if latency and queues remain within objectives.
- 40% host CPU can coexist with a container that is fully CPU-throttled.
- 2% `MemFree` can be healthy because Linux uses otherwise idle RAM as reclaimable cache.
- exit 137 is consistent with SIGKILL; it does not name the sender or prove out-of-memory.

Do not ask only, “Is the number high?” Ask, “Compared with which capacity, for how long, under what workload, and with what user consequence?”

## Terms before commands

**CPU and core:** A logical CPU is one execution context exposed to Linux. A physical core may expose multiple logical CPUs. `nproc` reports processing units available to the current process, which can differ from host inventory under affinity or container constraints.

**Task and thread:** Linux schedules tasks. User-facing tools may call them processes or threads. A multithreaded process can have one hot thread while its process-wide percentage hides the bottleneck.

**Runnable and run queue:** A runnable task is executing or eligible and waiting for CPU. Queueing means demand arrived faster than eligible CPU service for at least part of the interval.

**Utilization:** The share of measured CPU time assigned to categories such as user, system, idle, I/O wait, or steal. High utilization does not automatically mean harmful saturation.

**Saturation:** Demand exceeds immediately available service capacity, so work queues or stalls. Queue age and user latency often reveal saturation better than utilization alone.

**Load average:** Linux averages the number of runnable tasks plus tasks in uninterruptible sleep over approximately 1, 5, and 15 minutes. It is a population, not a percentage and not “CPU usage.”

**User and system time:** `us` accounts non-kernel execution; `sy` accounts kernel execution. High system time suggests kernel work but does not identify whether it is networking, filesystem, memory management, drivers, or another path.

**I/O wait:** `wa` is CPU-time accounting for idle time while the system has outstanding I/O. It does not name a slow disk, identify a process, or prove storage is the root cause.

**Steal:** `st` is time a virtual CPU wanted to run but the hypervisor scheduled something else. It matters in virtualized environments and needs platform correlation.

**Context switch:** The scheduler changes the running task. Context switches are necessary; an elevated rate becomes useful only with workload, runnable queues, lock behavior, and latency.

**Virtual memory and page:** Each process sees a virtual address space. The kernel maps fixed-size virtual pages to physical frames, shared file-backed pages, swap, or no resident page yet.

**Anonymous memory:** Heap, stack, and other non-file-backed mappings. Reclaiming anonymous pages may require swap if they must be preserved.

**Page cache:** RAM holding file data to avoid slower storage reads. Cache is useful work and is partly reclaimable, so treating all used RAM as unavailable is wrong.

**RSS:** Resident Set Size approximates pages resident for a process. Shared pages can be counted in multiple processes, so adding RSS values can overcount physical memory.

**Working set:** Pages a workload actively needs over a relevant window. This operational concept is more useful for sizing than one RSS snapshot.

**Reclaim:** Kernel work to free reusable memory, such as evicting clean cache or writing dirty pages. Reclaim can succeed while imposing latency.

**Swap occupancy and activity:** Occupancy is how much swap contains now. `si` and `so` are current movement rates. Old cold pages can remain in swap with no present pressure.

**Page fault:** A mapping requires kernel handling. A minor fault usually needs no storage read; a major fault requires I/O. A fault is not automatically an error.

**Pressure Stall Information (PSI):** Kernel accounting of time tasks are delayed by CPU, memory, or I/O scarcity. `some` means at least one task stalled; `full` means all non-idle tasks in scope stalled together. Averages are ratios over windows; `total` is cumulative microseconds.

**cgroup:** A hierarchical control group accounts and controls resources for a service, container, or other workload. Host availability does not override a smaller cgroup limit.

**OOM:** Out of memory is a decision state when an allocation cannot be satisfied under the relevant policy and boundary. The kernel may select a victim, an allocation may fail, or another controller may act.

## Architecture map

```text role=diagram lines=off
request rate x service time -> concurrency -> application queue
                                      |
                         threads become runnable or blocked
                         /                            \\
           eligible CPU + scheduler            kernel/dependency wait
              |             |                         |
          execution      run queue                 D state
              \\             |                         /
               memory allocation -> reclaim -> swap/writeback
                       |              |
                cgroup boundary    host boundary
                       \\              /
                  success, ENOMEM, throttle, or OOM kill
                                  |
                     readiness + response + user SLI
```

There are three nested questions:

1. **Demand:** how much work arrived, with what size, concurrency, and deadline?
2. **Resource service:** where did tasks execute, queue, reclaim, throttle, or wait?
3. **Outcome:** did the requested operation complete correctly and on time?

The host owns hardware or VM capacity. The cgroup hierarchy owns eligibility and limits. The process owns allocations and work. The service owns queues and behavior. The product owns the user objective.

## Request or state path

Imagine 100 checkout requests arrive each second and each request needs 20 milliseconds of CPU. Average CPU demand is roughly two CPU-seconds per second, but that average hides bursts, uneven threads, garbage collection, kernel work, and dependency waits.

```text role=diagram lines=off
arrival -> accepted -> queued -> runnable -> scheduled -> executing
       -> memory allocated -> dependency wait -> response -> acknowledged outcome
```

At every arrow, record request/trace ID, version/cohort, node and boot identity, container and cgroup lifetime, PID plus start time, and timestamp plus sampling interval.

Classify each measurement:

- a **gauge** describes a current value, such as `memory.current`;
- a **counter** accumulates, such as `oom_kill` or `throttled_usec`;
- a **rate** is a counter difference divided by elapsed time;
- an **average** compresses a window, such as load or PSI `avg10`;
- a **distribution** preserves variation, such as latency percentiles.

Never compare a five-minute load average with a one-second CPU sample as if they describe the same interval. Never use a cumulative OOM counter without a before/after delta for the exact cgroup lifetime.

## Failure zoom

### High CPU and rising latency

If runnable queue, CPU pressure, and latency rise together while idle approaches zero in the eligible scope, CPU saturation is plausible. Find whether demand, code path, garbage collection, kernel work, interrupts, or throttling changed. Adding CPU may restore capacity, but it does not remove an algorithmic regression or unbounded request cost.

### High load and idle CPU

Load includes D-state tasks. Tasks may wait for a filesystem, block device, network filesystem, memory reclaim, or another kernel path while CPUs remain idle. Eligibility can also be narrower than inventory: affinity, cpuset, or quota can strand capacity.

### Low free memory

Linux deliberately fills RAM with useful cache. Read `MemAvailable`, pressure, reclaim activity, allocation failures, and service behavior. Dropping caches makes the system re-read data and can worsen latency; it is not routine remediation.

### Swap is used

Swap occupancy may represent cold pages moved long ago. Active `si`/`so`, memory PSI, page-fault latency, working-set churn, and user impact distinguish harmless occupancy from damaging churn. Disabling swap can remove a safety margin and cause earlier OOM.

### Exit 137

Many shells and runtimes encode signal termination as 128 plus signal number; 137 is therefore SIGKILL-shaped. SIGKILL cannot be caught for graceful cleanup. The sender could be a cgroup OOM killer, host OOM killer, runtime after grace expiry, supervisor, deployment controller, or authorized human. Preserve evidence before restart and prove the actor.

## Internals and state ownership

### Scheduling and CPU accounting

Each CPU runs one task at a time. The scheduler chooses among eligible runnable tasks. Eligibility can be narrowed by affinity, cpusets, real-time policy, or cgroup bandwidth. A host can show idle CPUs while a quota-constrained service queues.

CPU fields divide accounted time; they do not directly measure queue delay. One saturated core can limit a serial stage on a 32-CPU host while aggregate use looks small. Check per-thread and per-CPU evidence when the application implies a single executor, event loop, lock owner, or shard.

In cgroup v2, `cpu.max` expresses quota and period. `max 100000` means no bandwidth ceiling at that level; `200000 100000` permits two CPU-seconds per 100-millisecond period in simplified capacity terms. Ancestors and cpusets can narrow effective capacity. `cpu.stat` counters such as `nr_throttled` and `throttled_usec` require deltas and workload correlation.

### Load, R, and D

`/proc/loadavg` includes tasks runnable in state R and tasks waiting in uninterruptible state D. The 1/5/15-minute values are exponentially smoothed history. Divide by eligible CPU only as orientation, never as a utilization formula.

R says a task can run; it does not say how long it waited. D says the task is inside a kernel wait that ordinary signal handling cannot interrupt; it does not mean “disk” specifically. Inspect wait channel, stack where authorized, device/dependency telemetry, and the first time-correlated failure.

### Memory allocation and reclaim

Virtual address reservation is not resident physical memory. Pages become resident as touched. The kernel balances anonymous pages, page cache, slabs, dirty data, writeback, and reclaim under policy.

`MemFree` is immediately unused RAM. `MemAvailable` estimates memory usable for new applications without swapping, considering reclaimable cache and that not every slab page is reclaimable. It is an estimate, not a guarantee.

In cgroup v2:

- `memory.current` is charged current use for the cgroup subtree.
- `memory.max` is the hard boundary or `max`.
- `memory.high` applies throttling and direct reclaim pressure; crossing it does not itself invoke OOM.
- `memory.peak` records a lifetime peak where supported, with reset semantics that require care.
- `memory.events` contains cumulative `low`, `high`, `max`, `oom`, `oom_kill`, and group-kill events; hierarchical and local variants differ.
- `memory.stat` decomposes charges and must be parsed by key, not fixed line number.

An OOM event answers “the boundary could not satisfy allocation under policy.” It does not answer why demand grew. Causes can include a leak, unbounded cache or queue, larger payload, concurrency, runtime heap policy, missing headroom, ancestor pressure, or unsafe packing.

## Evidence table

| Question | Evidence | Scope and time | Useful branch | Proves | Does not prove |
|---|---|---|---|---|---|
| Is useful work failing? | latency, errors, throughput, queue age | user journey and incident window | objective breached or healthy | measured product outcome | resource cause |
| How much CPU is eligible? | `nproc`, affinity, cpuset, `cpu.max` | process and ancestor cgroups | inventory, quota, or restriction | visible/effective configuration | actual demand |
| Is CPU work queueing? | vmstat `r`, CPU PSI, run-queue latency | interval and correct scope | sustained correlated rise | runnable competition/stall | offending code |
| Is work blocked? | vmstat `b`, STAT `D`, I/O PSI, wchan | PID namespace and interval | blocked cohort grows | kernel-wait population | device or dependency cause |
| Is memory pressure active? | MemAvailable, memory PSI, reclaim/swap rates | host and cgroup intervals | stalls and churn rise | observed scarcity effects | leak or future OOM |
| Did this cgroup OOM-kill? | `memory.events` before/after | exact cgroup lifetime | `oom_kill` delta | OOM victim charged here | demand cause or safe sizing |
| Why did 137 occur? | runtime reason, cgroup/host events, audit/deploy timeline | exact container and timestamp | one actor corroborated | supported termination actor | prevention without workload evidence |

If dashboard, kernel, runtime, and user timeline disagree, keep the disagreement visible. It may reveal stale labels, reused container names, collector gaps, or scope mismatch.

## Command decoders

### CPU count and load

```bash role=command lines=on
nproc
uptime
cat /proc/loadavg
```

```text role=output lines=off
8
 14:32:10 up 12 days,  4:18,  2 users,  load average: 1.20, 2.40, 3.10
1.20 2.40 3.10 3/842 49120
```

`nproc` says eight processing units are available to this process view. `uptime` shows current time, time since boot, logged-in sessions, then 1/5/15-minute load. `/proc/loadavg` repeats those values. `3/842` means three scheduling entities currently runnable out of 842 existing in that view; `49120` is the most recently created PID. Values can change between commands.

Load 1.20 is not 120% CPU. On eight eligible CPUs it is modest queue/wait population, but interval evidence and user behavior still determine whether a latency-sensitive thread is blocked.

### vmstat, field by field

```bash role=command lines=on
vmstat -y 1 5
```

```text role=output lines=off
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0 131072 702144  90112 4200000   0    0     4    18 1200 2400 12  4 83  1  0
 9  0 131072 690000  90112 4210000   0    0     0    24 5800 9100 71 11 18  0  0
```

`-y` omits the first CPU/rate row whose values otherwise average since boot. Process and memory columns are snapshots; subsequent rate fields describe each one-second interval.

- `r`: runnable tasks, executing or waiting for CPU.
- `b`: tasks blocked waiting for I/O completion.
- `swpd`: swap occupied now, in the selected unit.
- `free`: idle memory, not MemAvailable.
- `buff`: kernel buffers.
- `cache`: page cache.
- `si`/`so`: memory swapped in/out per second. Movement matters more than occupancy.
- `bi`/`bo`: KiB received from/sent to block devices per second in current procps semantics.
- `in`: interrupts per second, including the clock.
- `cs`: context switches per second.
- `us`: user-space CPU time percentage.
- `sy`: kernel CPU time percentage.
- `id`: idle CPU time percentage.
- `wa`: I/O-wait accounting percentage.
- `st`: virtual CPU time taken by the hypervisor.

The second sample suggests runnable competition: `r=9` with eight CPUs, low idle, and high user time. It still does not prove harmful saturation. Correlate multiple samples with CPU PSI, queue age, and latency.

### free and overlapping memory accounting

```bash role=command lines=on
free -h
```

```text role=output lines=off
               total        used        free      shared  buff/cache   available
Mem:            15Gi        9Gi       680Mi       220Mi       5.3Gi       5.6Gi
Swap:          4.0Gi       128Mi       3.9Gi
```

- `total` is usable physical memory.
- `used` is calculated from total minus available in current procps.
- `free` is unused now.
- `shared` is mostly tmpfs-backed memory.
- `buff/cache` combines buffers and cache; categories overlap with deeper kernel accounting.
- `available` is the kernel estimate for starting new applications without swapping.
- the Swap row shows capacity and occupancy, not current I/O activity.

This system has only 680 MiB immediately unused but an estimated 5.6 GiB available. “Memory is 96% full” would discard the reclaimable-cache model.

### Pressure Stall Information

```bash role=command lines=on
cat /proc/pressure/cpu
cat /proc/pressure/memory
cat /proc/pressure/io
```

```text role=output lines=off
some avg10=2.40 avg60=1.20 avg300=0.70 total=9283312
full avg10=0.00 avg60=0.00 avg300=0.00 total=0
```

`avg10=2.40` means tasks experienced that resource's defined `some` stall state for an average 2.40% of wall time over the recent 10-second window. It is not “2.4% resource utilization.” `total` is cumulative microseconds since the accounting lifetime began; take deltas to compare intervals.

CPU `full` is not useful as ordinary system-wide CPU saturation evidence. Memory or I/O `full` is severe in meaning because all non-idle work in scope stalled together, but no universal threshold fits every service. Establish thresholds from user objectives and workload behavior.

### Process snapshot

```bash role=command lines=on
ps -eo pid,ppid,stat,ni,psr,pcpu,pmem,rss,vsz,comm --sort=-rss | head -n 20
```

`NI` is nice value; `PSR` is the processor field at the snapshot; `%CPU` and `%MEM` are tool-defined ratios; `RSS` and `VSZ` are KiB here. `VSZ` is virtual address space, not resident RAM. A high RSS process is a lead, not a leak verdict. Compare start identity, workload-normalized trend, private/shared mappings, cgroup charge, and healthy peers.

### cgroup v2 without guessing the path

```bash role=command lines=on
cat /proc/SELF_PID/cgroup
findmnt -t cgroup2
```

Replace `SELF_PID` with the exact process PID. A typical `0::/system.slice/api.service` line identifies its unified hierarchy path. Join it to the cgroup2 mount only after checking namespace and permissions. Read `cpu.max`, `cpu.stat`, `memory.current`, `memory.max`, `memory.events`, `memory.stat`, and the three pressure files. Counter deltas need two timestamps; a value of five does not mean five events occurred during this incident.

## Decision path

```text role=diagram lines=off
User operation outside objective?
  |
  +-- no -> record resource observation; do not invent an incident
  |
  +-- yes -> align time + host + cgroup + process + workload
               |
               +-- runnable queue + CPU PSI + low eligible idle?
               |      -> CPU demand, quota, affinity, hot thread, regression
               |
               +-- D/b + I/O PSI + available CPU?
               |      -> wait channel, storage/filesystem/kernel dependency
               |
               +-- low available + memory PSI + reclaim/swap activity?
               |      -> working set, cache/queue, allocation, ancestor pressure
               |
               +-- exit 137?
                      -> runtime reason + cgroup delta + host OOM + actor timeline

Before change: preserve -> hypothesis -> expected signal -> abort -> rollback
After change: resource pressure -> queue -> readiness -> real operation -> soak
```

Safe recoveries differ by evidence:

- roll back a new version when cohort and timing support regression;
- shed or queue less work when demand exceeds safe capacity;
- cap concurrency or cache when growth is unbounded;
- replace one unhealthy instance through the platform when redundancy is proven;
- raise a limit only after measured working set and node capacity support it;
- scale only after checking whether each replica multiplies cache, connections, or downstream load.

## Guided Ubuntu lab

This lesson intentionally uses observation, not artificial pressure. On Ubuntu, open `book/labs/LES-0003-resource-pressure` and run:

```bash role=command file=book/labs/LES-0003-resource-pressure/lab.sh lines=on
bash lab.sh check
bash lab.sh observe
bash lab.sh cleanup
```

Before reading output, draw six columns: signal, value, unit, scope/window, proves, and does not prove. Record:

1. visible CPU count and all load windows;
2. each important `vmstat` field across interval rows;
3. free, available, cache, swap occupancy, and swap activity;
4. PSI `some`, `full`, averaging windows, and totals;
5. process states and the largest visible RSS values;
6. any visibility gap caused by permissions, WSL, containers, or absent PSI.

A quiet system is a valid result. Do not install a stress tool or manufacture an OOM. Cleanup proves only that this walkthrough created no state.

## Production transfer

**Bare metal or VM:** inventory, NUMA topology, hypervisor steal, noisy neighbors, storage, kernel version, and boot identity matter. A VM's “host” metrics are still guest-level unless correlated with the virtualization platform.

**systemd service:** systemd usually places services into cgroups. Use the unit's actual ControlGroup and invocation identity. A restart creates a new process lifetime while cumulative cgroup behavior may depend on unit lifecycle.

**Container:** `/proc/meminfo` and host CPU views can look generous while `memory.max`, `cpu.max`, ancestors, and cpusets are tight. Container percentages depend on collector normalization. Prefer raw boundaries and counter deltas.

**Kubernetes:** requests influence scheduling; limits influence runtime enforcement. A Pod can be OOM-killed inside its cgroup on a healthy node. Node pressure and eviction are separate mechanisms. Preserve Pod UID, container ID, previous termination state, node, cgroup, runtime, and timestamps.

**Managed runtimes and native services:** heap is not total RSS. Include native allocations, stacks, mapped files, allocator behavior, runtime metadata, page-cache charges, socket buffers, and child processes where relevant. Tune only after the accounting boundary is clear.

## Reliability, security, observability, capacity, and cost

**Reliability:** operate from user objectives. Queue age, deadline misses, throttling, pressure, restarts, and success rate usually tell a stronger story than CPU or memory percentage. Preserve headroom for failover, rollout overlap, recovery, and spikes.

**Security:** command lines, cgroup paths, hostnames, and kernel logs may disclose infrastructure or customer identity. Redact before sharing. Do not grant root, expose host procfs, use privileged containers, or weaken isolation just to simplify metrics.

**Observability:** collect raw gauges and monotonic counters with host, boot, cgroup, container, process-start, version, and workload identity. Bound cardinality. Retain termination reason and previous-container evidence. Alert on user impact and fast-burn risk, then attach resource evidence.

**Capacity:** derive concurrency from arrival rate and service time, measure peak working set under representative load, add explicit safety/failure headroom, and verify placement. A limit safe per replica can be unsafe when every replica coexists during rollout.

**Performance:** find the knee where more demand produces disproportionate queueing and latency. Average utilization hides bursts and tail latency. Profile after locating the saturated stage and controlling workload.

**Cost:** unused headroom buys resilience; excessive headroom wastes money. High limits reduce scheduling density; low limits create throttling and restarts. Optimize cost per successful user operation while respecting SLO and recovery capacity.

## Traps and prevention

| Trap | Why it fails | Better habit |
|---|---|---|
| Load 8 means 100% on eight CPUs | Load is runnable-plus-D population, not utilization | Join load, eligible CPU, vmstat, PSI, and latency |
| Low `free` means OOM is near | Cache uses RAM productively | Read MemAvailable, pressure, reclaim, and limits |
| Swap used means thrashing now | Occupancy can be old and cold | Inspect interval si/so, PSI, faults, and latency |
| 137 means OOM | It identifies no sender | Correlate runtime, cgroup deltas, host kernel, and actor |
| Node has memory, so Pod cannot OOM | A cgroup has an independent boundary | Read exact container current/max/events |
| High CPU is bad | Useful throughput can consume CPU safely | Look for queueing, deadlines, errors, and headroom |
| Drop caches to free memory | It destroys useful cache and hides cause | Find reclaim pressure and workload ownership |
| Double all limits | It changes placement and failure capacity | Size from distributions, headroom, and canary evidence |
| One screenshot proves cause | It is a point-in-time, scope-limited sample | Preserve aligned intervals and compare cohorts |

## Memory card and retrieval

Remember **S-C-O-P-E**:

- **S — Service outcome:** which user operation is slow or failing?
- **C — Capacity boundary:** host, eligible CPUs, cgroup, quota, limit, ancestor.
- **O — Observed work:** runnable, blocked, reclaiming, swapping, throttled, killed.
- **P — Period and provenance:** timestamp, interval, counter delta, identity, collector.
- **E — Evidence-led action:** preserve, predict, change one thing, rollback, verify.

Try these from memory:

1. Why can load be high while CPU idle is high?
2. Why is `MemAvailable` usually more useful than `MemFree`?
3. What is the difference between swap occupancy and swap activity?
4. What do PSI `some`, `full`, `avg10`, and `total` mean?
5. What does exit 137 directly tell you, and what remains unknown?
6. Why can a container OOM while its node appears healthy?
7. When is raising a memory limit a correct remediation?
8. What evidence shows recovery rather than mere restart?

## Complete answers

**1. High load with idle CPU:** load counts runnable tasks and tasks in uninterruptible sleep. D-state work can inflate load while CPUs wait idle. Affinity, cpusets, or quota can also leave host CPUs idle while a workload cannot use them. Align the window and inspect vmstat r/b, task states/wchan, PSI, and cgroup eligibility.

**2. Available versus free:** `MemFree` is immediately unused RAM. Linux uses spare RAM for cache. `MemAvailable` estimates what can serve new applications without swapping after considering reclaimable pages and constraints. It is an estimate and says nothing directly about a smaller cgroup limit.

**3. Swap occupancy versus activity:** occupancy is bytes currently stored in swap; it may be cold pages moved earlier. Activity is movement during the interval, shown by `si` and `so`. Repeated movement plus pressure and latency can indicate harmful churn; occupancy alone cannot.

**4. PSI fields:** `some` means at least one task in scope stalled. `full` means all non-idle tasks stalled simultaneously for memory or I/O; CPU full has special system-level semantics. `avg10` is the recent ten-second stall-time ratio, not utilization. `total` is cumulative microseconds and needs deltas.

**5. Exit 137:** common reporting makes it consistent with 128 plus SIGKILL. It does not identify the sender. Check exact-lifetime runtime reason, cgroup `memory.events` deltas, host OOM evidence, eviction/supervisor/deployment actions, and audit timing.

**6. Container OOM on healthy node:** its memory cgroup can reach `memory.max` and fail reclaim while the node has available memory. Prove it with the exact cgroup's event delta and runtime reason, not node percentage.

**7. Raising a limit:** it is correct when representative testing shows bounded legitimate working-set distribution plus headroom exceeds the old limit, placement and failover remain safe, cost is accepted, and a canary plus rollback verifies it. It is not a substitute for fixing unbounded growth.

**8. Recovery evidence:** show the resource symptom changed as predicted, then verify queue age, readiness, success rate, latency, and a real safe operation across a representative soak. A new PID or green Pod phase proves lifecycle, not delivered service.

## Product-company interview

**Scenario:** Checkout containers exit 137 during peaks. Node dashboards stay below 50% memory, and the proposal is to double every limit and replica count.

**Strong opening:** “I will preserve the exact terminated-container evidence and user timeline. Exit 137 is SIGKILL-shaped, not an OOM verdict, and host memory is not cgroup headroom. I will distinguish cgroup OOM, host OOM, eviction, and another kill actor before changing capacity.”

Bound checkout impact, zones, cohorts, restarts, rollout state, and safe capacity. Record Pod UID, container ID, image digest, node, prior termination reason/time, events, QoS, requests, and limits. For the exact cgroup, compare current/peak/max, `memory.events` deltas, composition, pressure, and ancestors. Join host MemAvailable, PSI, kernel events, runtime metadata, deployment/audit actions, and application allocation behavior.

If a new version causes unbounded growth and rollback is compatible, pause and roll back. If demand is legitimate and bounded, size from working-set distributions plus safety and failover headroom; prove node placement and downstream capacity. If traffic is unsafe, shed optional work or bound concurrency. Canary one change and verify checkout success, latency, restarts, pressure, headroom, and soak.

**Weak answer:** “137 always means OOM, so double limits.” It invents cause, ignores cgroups, may halve placement density, can move failure to the node, and lacks rollback or user validation.

**Follow-up — `oom_kill` did not increase:** verify cgroup identity/lifetime and local versus hierarchical events. Then inspect host OOM, eviction, grace-timeout escalation, controller, supervisor, and audit evidence. Missing telemetry is uncertainty, not proof.

**Follow-up — raising limits stops restarts:** that is mitigation evidence, not root-cause proof. Determine whether legitimate demand, cache, queue, heap, native memory, or leak consumed the additional space, and whether fleet capacity remains safe.

**Follow-up — CPU is also throttled:** calculate effective quota and throttling deltas, then test whether reduced CPU progress extends request lifetime and memory concurrency. Resource interactions can form a feedback loop; change one bounded variable and observe the user path.

## Independent transfer and rubric

On a disposable Ubuntu machine, perform the read-only walkthrough in one quiet window and one naturally busier window. Do not generate load, allocate artificial memory, change swap, edit cgroups, use sudo, or run against production.

Produce an environment card; architecture diagram; timestamped field-by-field evidence table; comparison of utilization, queueing, pressure, available memory, swap occupancy/activity, host/cgroup scope, gauges, counters, and rates; a hypothetical exit-137 decision; cleanup statement; redaction record; limitations; and assistance disclosure.

Rubric: safety/provenance 4 points; CPU/load model 4; memory/cgroup model 4; evidence-led decision 4; production/user transfer 4. A reviewer must inspect original evidence and reasoning. Reading completion, copied commands, project tests, or AI assistance do not establish mastery.

## References and review

- `REF-1203`: Linux `proc_loadavg(5)` semantics.
- `REF-1204`: procps-ng `vmstat(8)` field and first-report semantics.
- `REF-1205`: `free(1)` and `/proc/meminfo` memory accounting.
- `REF-1206`: Linux kernel Pressure Stall Information.
- `REF-1207`: Linux cgroup v2 CPU and memory interfaces.
- `REF-1208`: Linux per-process status and memory fields.

Review by 2027-03-02 or earlier if Linux, procps, cgroup v2, PSI, Ubuntu, container-runtime behavior, legacy compatibility, or reader parsing changes. Re-run schema, references, route/search/state compatibility, command syntax, lab static checks, reader tests, typecheck, lint, and build. Run the walkthrough on Ubuntu separately; a Windows syntax check is not Ubuntu runtime evidence.
