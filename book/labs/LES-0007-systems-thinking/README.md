# LES-0007 lab: see a system as flow, queues, and limits

Abhishek, this lab teaches one habit that separates reactive operators from strong
SREs:

> When a service becomes slow, do not stare only at CPU. Ask: how fast is work
> arriving, how fast can the system finish it, and where is unfinished work
> waiting?

You will run three deterministic profiles. They use **virtual milliseconds** in a
small Python model. The model finishes almost immediately and creates no real
load. Its purpose is to make the relationships visible and repeatable; it is not
a benchmark of your laptop.

## The picture to keep in your head

```text
                         bounded waiting area
                      queue_capacity = 3 jobs
                                |
                                v
producer --> offered work --> [ Q | Q | Q ] --> worker(s) --> completed work
                  |                                    |
                  | queue and workers are full         | each worker needs
                  +-------- backpressure <--------------+ service_ms per job
                         work waits upstream

       offered rate                     nominal service capacity
       1000 / arrival_ms                workers * 1000 / service_ms
```

Imagine a restaurant. Customers are the jobs, chairs are the bounded queue, and
cooks are the workers.

- If customers arrive more slowly than cooks finish, there is no line.
- If customers arrive faster than cooks finish, the chairs fill.
- Once every chair is occupied, new customers cannot enter the waiting area.
  They wait outside. In this lab that upstream delay is **backpressure**.
- Adding cooks can restore capacity, but only if the kitchen, database, network,
  or another dependency is not the next bottleneck.

The queue is deliberately bounded. An unbounded queue can hide overload for a
while, consume memory, and turn a small traffic spike into a long latency
incident. A bounded queue makes the overload decision explicit: wait upstream,
reject, retry later, or shed low-priority work.

## The terms, in plain language

| Term | What it means here | The question it answers |
|---|---|---|
| Job | One unit of requested work | What are we trying to finish? |
| `arrival_ms` | Virtual time between offered jobs | How quickly is demand arriving? |
| `service_ms` | Time one worker spends on one job | How expensive is one job? |
| Worker | One independent service slot | How much work can run concurrently? |
| Queue | Admitted jobs waiting for a worker | Where is accepted work waiting? |
| Queue capacity | Maximum admitted waiting jobs | How much waiting do we permit? |
| Wait time | `started_at - admitted_at` | How long did an admitted job sit in the queue? |
| Admission delay | `admitted_at - offered_at` | How long was work held upstream by backpressure? |
| Completion latency | `completed_at - offered_at` | How long did the caller wait end to end? |
| Throughput | Completed jobs per elapsed second | How fast did this finite run actually finish? |
| Backpressure | Delaying admission when queue and workers are full | Did overload propagate to the producer? |

Three timestamps matter. Do not merge them mentally:

```text
offered_at ---- admission delay ---- admitted_at ---- queue wait ---- started_at
                                                                      |
                                                               service time
                                                                      |
                                                                      v
                                                                 completed_at

completion latency = admission delay + queue wait + service time
```

A dashboard that shows only queue wait can look deceptively healthy when work is
being delayed before admission. A strong incident investigation follows the
whole path.

## Capacity math before you run anything

The model reports two rates:

```text
offered_rate_per_s   = 1000 / arrival_ms
nominal_capacity_per_s = workers * 1000 / service_ms
```

Read them as a comparison, not as magic numbers:

- offered rate below capacity: the system should normally drain work;
- offered rate above capacity: unfinished work must accumulate somewhere;
- offered rate equal to capacity: there is no spare capacity for jitter, retries,
  pauses, or a slower dependency.

Real systems are noisy. A service operated exactly at its theoretical capacity
is fragile. Production headroom is an engineering decision informed by latency
objectives, traffic bursts, failure modes, and cost.

## The three profiles

| Profile | Jobs | Workers | Arrival | Service | Offered rate | Nominal capacity | Expected lesson |
|---|---:|---:|---:|---:|---:|---:|---|
| `stable` | 12 | 1 | 400 ms | 300 ms | 2.500/s | 3.333/s | Capacity is ahead of demand; no queue forms. |
| `saturated` | 12 | 1 | 100 ms | 300 ms | 10.000/s | Demand outruns service; the bounded queue fills and backpressure appears. |
| `recovered` | 12 | 3 | 100 ms | 300 ms | 10.000/s | Three workers match offered demand in this ideal model; the queue drains. |

These profiles are intentionally small and fixed. Repeating a profile gives the
same answer, which lets the verifier distinguish a code change from timing noise.

## Safety contract

Run this from Ubuntu 24.04 or Ubuntu 24.04 on WSL2 as a normal, non-root user.
You need Bash, Python 3.8 or newer, and standard Ubuntu tools.

This lab:

- does not use `sudo`;
- does not need Docker;
- does not access the network or open a port;
- does not install a package;
- does not change the system clock;
- does not create child workers or stress host resources;
- does not write outside one lesson-specific `/tmp` directory and one
  lesson-specific state descriptor;
- never uses recursive deletion.

`setup` refuses root. It also checks that `/tmp` is a real, root-owned, sticky
directory. Every destructive step validates the recorded path, owner, file type,
link count, sentinel, and allowed artifact names before removing an exact path.

## Run the lifecycle

From this directory:

```bash
bash lab.sh check
bash lab.sh setup
bash lab.sh status
```

Run the profiles in learning order:

```bash
bash lab.sh run stable
bash lab.sh run saturated
bash lab.sh run recovered
```

Check what has been recorded:

```bash
bash lab.sh status
```

Then remove the complete lab state:

```bash
bash lab.sh cleanup
```

You do not run a Dockerfile first. `lab.sh` is the entry point.

Each profile may be recorded only once in a lab state. That protects the evidence
from accidental overwrite. To start a clean attempt:

```bash
bash lab.sh reset
```

`reset` performs a validated cleanup and creates a new empty lab state.

## Decode the profile output

Every `run` emits the same fields in the same order.

| Field | How to read it |
|---|---|
| `profile` | The selected scenario: stable, saturated, or recovered. |
| `jobs` | Work offered to the system. |
| `completed` | Work that reached completion. It must equal `jobs`; otherwise ask where work was lost or abandoned. |
| `workers` | Concurrent service slots in this model. |
| `arrival_ms` | Time between offered jobs. A smaller number means faster demand. |
| `service_ms` | Time one worker needs per job. A larger number means slower service. |
| `elapsed_ms` | Virtual time from the first offer until the last completion. |
| `throughput_per_s` | `completed * 1000 / elapsed_ms` for this finite run. |
| `max_queue` | Largest number of admitted jobs waiting at once. |
| `mean_wait_ms` | Average admitted queue wait. A mean can hide a bad tail. |
| `p95_wait_ms` | Nearest-rank 95th percentile of admitted queue wait. |
| `queue_capacity` | Hard bound on admitted waiting jobs; always 3 in these profiles. |
| `offered_rate_per_s` | Ideal offered demand from the configured arrival interval. |
| `nominal_capacity_per_s` | Ideal worker capacity from worker count and service time. |
| `backpressure_jobs` | Jobs whose admission was delayed because workers and queue were full. |
| `producer_blocked_ms` | Total virtual milliseconds during which at least one offered job remained upstream. |
| `max_admission_delay_ms` | Worst delay between offer and admission. |
| `mean_completion_latency_ms` | Average end-to-end time from offer to completion. |
| `p95_completion_latency_ms` | 95th-percentile end-to-end completion latency. |

The fixed results are:

| Signal | Stable | Saturated | Recovered |
|---|---:|---:|---:|
| `completed` | 12 | 12 | 12 |
| `elapsed_ms` | 4700 | 3600 | 1400 |
| `throughput_per_s` | 2.553 | 3.333 | 8.571 |
| `max_queue` | 0 | 3 | 0 |
| `mean_wait_ms` | 0.000 | 691.667 | 0.000 |
| `p95_wait_ms` | 0 | 900 | 0 |
| `backpressure_jobs` | 0 | 7 | 0 |
| `producer_blocked_ms` | 0 | 1900 | 0 |
| `max_admission_delay_ms` | 0 | 1300 | 0 |
| `mean_completion_latency_ms` | 300.000 | 1400.000 | 300.000 |
| `p95_completion_latency_ms` | 300 | 2500 | 300 |

A subtle point: the stable batch has a larger `elapsed_ms` than the saturated
batch because stable jobs are intentionally offered farther apart. That does
**not** mean saturation is better. The user-facing evidence is completion
latency: 300 ms stable versus 1400 ms mean and 2500 ms p95 when saturated.

Likewise, recovered throughput is 8.571/s rather than exactly 10/s because a
finite measurement includes the final 300 ms service tail. The nominal rate
describes steady-state capacity; finite-run throughput describes this exact
sample. Good SREs state the measurement window before comparing rates.

## What each run should teach you

### 1. Stable: no queue is evidence, not proof of infinite capacity

```bash
bash lab.sh run stable
```

The producer offers 2.500 jobs/s and the worker can nominally finish 3.333
jobs/s. Each job finishes before the next arrives. Therefore:

```text
max_queue=0
backpressure_jobs=0
mean_completion_latency_ms=300.000
```

Say it this way during an incident:

> Current demand is below observed service capacity, and no queue is forming in
> this window. I still need to check traffic trend, downstream limits, and
> headroom before declaring the service safe.

### 2. Saturated: throughput plateaus while latency explodes

```bash
bash lab.sh run saturated
```

Demand becomes 10 jobs/s but one worker still offers only 3.333 jobs/s. The
three waiting slots fill. Seven jobs experience admission backpressure.

```text
max_queue=3
backpressure_jobs=7
max_admission_delay_ms=1300
p95_completion_latency_ms=2500
```

Notice the system completes all 12 jobs. Completion alone does not mean health.
Users waited much longer. During overload, throughput often flattens near the
bottleneck while latency and queueing rise first.

Use this mental alarm:

> Arrival rate is greater than service capacity. The queue is full, so new work
> must wait upstream, be rejected, or be shed. I should protect the dependency
> and reduce demand or increase safe capacity before retries amplify the event.

### 3. Recovered: more concurrency removes this bottleneck

```bash
bash lab.sh run recovered
```

Three workers provide a nominal 10 jobs/s, equal to offered demand in this
perfect model. The queue disappears and completion latency returns to service
time.

```text
workers=3
max_queue=0
backpressure_jobs=0
mean_completion_latency_ms=300.000
```

Do not turn this into "always add workers." Ask what those workers call. If all
three contend for one database connection pool, lock, disk, or rate-limited API,
you have moved the queue instead of removing it.

## The incident decision path

```text
Is user latency rising?
        |
        v
Is unfinished work or queue depth rising?
        |
   +----+----+
   |         |
  yes        no
   |         |
Compare      Look for slow service, retries, lock contention,
arrival      network delay, dependency latency, GC, or bad work
with safe    even if the local queue is not growing.
capacity
   |
   +-- offered < capacity --> inspect burstiness, tail service time,
   |                          hidden downstream queues, and measurement window
   |
   +-- offered > capacity --> bound the queue; apply backpressure or load
                              shedding; reduce demand; add safe capacity;
                              stop retry amplification
```

During a real production event, collect correlated evidence:

1. request or job arrival rate;
2. completion throughput;
3. in-flight work and queue depth;
4. queue age, mean latency, and tail latency;
5. error, timeout, rejection, and retry rates;
6. worker utilization and saturation;
7. dependency latency and its concurrency limits;
8. the exact deployment or traffic change preceding the symptom.

CPU is one signal in that list, not the diagnosis.

## Status contract

A ready lab reports these fields:

```text
lesson_id=LES-0007
state=ready
lab_root=/tmp/devops-sre-LES-0007-systems-thinking.XXXXXXXX
profiles_completed=none
execution=virtual-time-bounded
queue_capacity=3
profiles_available=stable,saturated,recovered
```

`profiles_completed` changes in fixed learning order as summaries are recorded.
The random eight-character suffix isolates concurrent users and avoids a shared
predictable directory. The state descriptor records the exact root; the script
never discovers deletion targets with a broad wildcard.

## Failure, abort, and recovery branches

| What you see | What it means | Safe action |
|---|---|---|
| `run this lab from a normal non-root Ubuntu shell` | Root execution is intentionally blocked. | Leave the root shell and run as your normal Ubuntu user. |
| `lab state is absent` | `setup` has not created the isolated state, or it was already cleaned. | Run `bash lab.sh setup`. |
| `PROFILE was already recorded` | The immutable summary prevents accidental overwrite. | Read it with `status`, or use `bash lab.sh reset` for a fresh attempt. |
| `artifact manifest content changed` or `queue model copy changed` | Evidence no longer matches the trusted lesson source. | Use `bash lab.sh reset`; known owned artifacts can be cleaned despite content tamper. |
| `unexpected artifact blocks safe operation` | The lab root contains a name the exact manifest does not authorize. | Identify who owns it. Remove it only if you can prove it is yours, then retry cleanup. |
| Sentinel, owner, link, type, mode, path, or state validation fails | A safety boundary changed, so automated removal is unsafe. | Stop. Inspect with `ls -la`, `stat`, and `cat`; do not bypass validation or use recursive deletion. |
| `lab root changed during cleanup` | A race added content after validation. The script restores the sentinel when safe. | Inspect the exact root, resolve the new artifact, and retry. |
| Interrupted run leaves a partial known summary | The known file may fail deterministic validation. | `bash lab.sh reset` validates ownership/type and recreates clean state. |

A refusal is a successful safety behavior. The script chooses to leave evidence
behind rather than guess that an unfamiliar file is disposable.

## Exact artifact manifest

The state descriptor is:

```text
/tmp/devops-sre-LES-0007-systems-thinking-<uid>.state
```

It contains only a version, lesson ID, owner UID, and exact lab root.

Inside the random lab root, only these names are allowed:

| Artifact | Created by | Required | Mode |
|---|---|---:|---:|
| `.les-0007-sentinel` | `setup` | yes | `0600` |
| `artifact-manifest.tsv` | `setup` | yes | `0600` |
| `queue_model.py` | `setup` | yes | `0500` |
| `stable.summary` | `run stable` | no | `0600` |
| `saturated.summary` | `run saturated` | no | `0600` |
| `recovered.summary` | `run recovered` | no | `0600` |

Cleanup validates the descriptor and root identity, checks every directory entry
against that exact list, removes only those exact regular single-link files,
removes the sentinel last, removes the now-empty directory with `rmdir`, and
removes the descriptor last. It then proves both paths are absent.

## Run the verifier

The verifier intentionally creates and removes its own disposable states. It
refuses to start if a learner state is already active, so it cannot silently
replace your work.

```bash
bash verify.sh
```

A passing result ends with:

```text
verification_passed=true
profiles=stable,saturated,recovered
refusals=repeat-run,manifest-tamper,unexpected-artifact
cleanup_proven=true
```

It proves:

- check, setup, status, all profiles, reset, and cleanup work;
- every deterministic field and its order match the contract;
- all offered jobs complete and queue depth never exceeds capacity;
- a repeated profile cannot overwrite its summary;
- known manifest tamper is detected and recoverable with reset;
- an unexpected artifact makes cleanup refuse without deleting it;
- verifier-owned evidence can be removed by exact validated path;
- final cleanup leaves neither state descriptor nor lab root.

## What this lab proves--and what it does not

It proves that you can reason about a finite deterministic queue:

```text
demand -> admission -> bounded waiting -> service -> completion
```

It does not measure kernel scheduling, Python performance, real network
backpressure, production percentiles, or the safe worker count of an application.
Those require workload-specific instrumentation and controlled experiments.

The durable skill is the reasoning:

> Find the unit of work. Measure arrival and completion. Locate every place work
> can wait. Bound waiting. Compare demand with safe capacity. Protect downstream
> dependencies. Verify that recovery improves user latency without losing work.
