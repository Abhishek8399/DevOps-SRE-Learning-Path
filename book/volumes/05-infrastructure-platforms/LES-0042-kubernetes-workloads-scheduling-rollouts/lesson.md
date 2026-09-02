---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0042",
  "slug": "kubernetes-workloads-scheduling-rollouts",
  "aliases": ["V05-L06", "kubernetes-workloads-scheduling-rollouts"],
  "curriculumIds": ["K8S-002"],
  "route": "/book/infrastructure/kubernetes-workloads-scheduling-rollouts",
  "order": 6,
  "volume": "05-infrastructure-platforms",
  "title": "Kubernetes workloads: schedule, start, probe, roll out, disrupt, and scale safely",
  "summary": "Trace Pods and workload controllers through placement, resources, probes, rollout, disruption and autoscaling without confusing process state with user availability.",
  "domain": "infrastructure",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0012", "LES-0023", "LES-0041"],
  "prerequisiteCurriculumIds": ["LNX-003", "CTR-001", "K8S-001"],
  "testedEnvironments": [
    {"platform":"Kubernetes documentation","version":"v1.36 current documentation","support":"supported","notes":"Official workload, scheduling, resource, probe, disruption and autoscaling sources reviewed 2026-08-04."},
    {"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"Docker has no Linux engine and WSL access is denied; no Kubernetes runtime claim."},
    {"platform":"Ubuntu","version":"24.04 LTS","support":"required","notes":"A deterministic normal-user workload model is concept rehearsal only."},
    {"platform":"Cloud","version":"not used","support":"unsupported","notes":"No cloud account, credential, managed cluster or billable resource."}
  ],
  "targetRoles": ["devops-engineer","site-reliability-engineer","platform-engineer","kubernetes-engineer","application-engineer","technical-lead"],
  "learningObjectives": [
    "Distinguish Pod phase, conditions, container state, controller availability, endpoint readiness and user success.",
    "Choose Deployment, StatefulSet, Job, CronJob or DaemonSet from identity and completion semantics.",
    "Trace unscheduled intent through feasibility, scoring, binding and node execution.",
    "Explain requests, limits, QoS, CPU throttling, OOM kills and node-pressure eviction.",
    "Design startup, readiness and liveness probes around distinct questions and consequences.",
    "Diagnose Pending, image pull, crash loop, OOM, readiness and rollout failures by boundary.",
    "Plan surge, unavailability, progress deadlines, rollback and end-to-end verification.",
    "Use affinity, spread, taints, tolerations, priority and quotas without impossible placement.",
    "Reason about disruption budgets, drain, termination grace and graceful shutdown.",
    "Design HPA feedback from metrics, requests, readiness delay, stabilization and capacity."
  ],
  "productionSignals": [
    "context, namespace, workload UID, revision, generation and observedGeneration",
    "Pod phase and PodScheduled, Initialized, ContainersReady and Ready conditions",
    "container waiting/running/terminated state, reason, exit, signal, restarts and lastState",
    "scheduler queue age, FailedScheduling reason, requests, constraints and nodeName",
    "node allocatable, requested resources, pressure, taints and Lease freshness",
    "CPU request/limit/usage/throttling and memory working set/limit/OOM evidence",
    "startup/readiness/liveness outcomes, latency, timeout and thresholds",
    "desired/current/updated/available/unavailable replicas and progress conditions",
    "ReplicaSet revision, Pod template hash, maxSurge and maxUnavailable",
    "PDB healthy counts and disruptionsAllowed",
    "HPA metric, target, current/desired replicas, conditions and stabilization",
    "EndpointSlice readiness, synthetic request, latency and served revision"
  ],
  "diagrams": [
    {"id":"LES-0042-DIA-001","title":"Workload ownership to user path","direction":"top-to-bottom","boundaries":["controller","Pod","scheduler","kubelet","runtime","readiness","endpoint","user"],"evidencePoints":["owner UID","nodeName","container state","Ready","revision"],"textAlternative":"A controller creates Pod intent, scheduler binds, kubelet starts containers, readiness gates endpoints, and a user request proves behavior."},
    {"id":"LES-0042-DIA-002","title":"Independent Pod state lenses","direction":"left-to-right","boundaries":["phase","conditions","container state","lastState","events","controller","endpoint"],"evidencePoints":["Pending","PodScheduled","waiting reason","exit","availableReplicas"],"textAlternative":"Phase, conditions, container states, prior termination, events, controller status and endpoints answer different questions."},
    {"id":"LES-0042-DIA-003","title":"Scheduling path","direction":"left-to-right","boundaries":["queue","filter","score","reserve","bind","kubelet"],"evidencePoints":["requests","affinity","taint","volume topology","nodeName"],"textAlternative":"Scheduler filters infeasible nodes, scores feasible nodes and binds; kubelet work begins afterward."},
    {"id":"LES-0042-DIA-004","title":"Resource failure boundaries","direction":"hierarchical","boundaries":["request","placement","CPU limit","memory limit","node pressure","QoS","eviction"],"evidencePoints":["millicores","throttling","OOMKilled","MemoryPressure"],"textAlternative":"Requests influence placement, CPU limits throttle, memory limits can kill, and node pressure can evict."},
    {"id":"LES-0042-DIA-005","title":"Rolling update","direction":"left-to-right","boundaries":["old ReplicaSet","surge","readiness","availability","scale-down","deadline","rollback"],"evidencePoints":["revision","updated","available","surge","unavailable"],"textAlternative":"A new ReplicaSet surges within policy, waits for availability, scales down old capacity, and may stall or roll back."},
    {"id":"LES-0042-DIA-006","title":"Autoscaling feedback","direction":"cyclic","boundaries":["demand","metric","HPA","replicas","scheduler","readiness","traffic"],"evidencePoints":["current metric","target","desired replicas","Pending","Ready"],"textAlternative":"Metrics change desired replicas, but placement and readiness determine whether capacity actually serves traffic."}
  ],
  "commands": [
    {"id":"LES-0042-CMD-001","question":"Which workload and revision own these Pods?","risk":"read-only","command":"kubectl get deploy,rs,pod -n atlas-workloads -o wide","runFrom":"approved local context","expectedBranches":[{"when":"owners and revision match","meaning":"correct family selected","nextEvidence":"inspect generation"},{"when":"identity differs","meaning":"wrong lifetime","nextEvidence":"stop and bind UID"}],"proves":"reported objects","doesNotProve":"user health"},
    {"id":"LES-0042-CMD-002","question":"Is failure before or after binding?","risk":"read-only","command":"kubectl get pod POD -n atlas-workloads -o yaml; kubectl describe pod POD -n atlas-workloads","runFrom":"approved namespace","expectedBranches":[{"when":"nodeName empty","meaning":"unscheduled","nextEvidence":"read FailedScheduling"},{"when":"nodeName set","meaning":"bound","nextEvidence":"inspect node-side state"}],"proves":"binding and status","doesNotProve":"complete history"},
    {"id":"LES-0042-CMD-003","question":"What are current and previous container states?","risk":"read-only","command":"kubectl get pod POD -n atlas-workloads -o jsonpath='{.status.containerStatuses}'","runFrom":"approved namespace","expectedBranches":[{"when":"waiting","meaning":"startup blocked","nextEvidence":"decode reason"},{"when":"terminated","meaning":"lifetime ended","nextEvidence":"read lastState and logs"}],"proves":"API state summary","doesNotProve":"root cause"},
    {"id":"LES-0042-CMD-004","question":"Do requests fit feasible nodes?","risk":"read-only","command":"kubectl describe pod POD -n atlas-workloads; kubectl describe node NODE","runFrom":"approved cluster","expectedBranches":[{"when":"requests fit","meaning":"resource filter may pass","nextEvidence":"inspect other constraints"},{"when":"requests exceed allocatable","meaning":"unschedulable","nextEvidence":"right-size or add capacity"}],"proves":"declared and reported capacity","doesNotProve":"future demand"},
    {"id":"LES-0042-CMD-005","question":"Why did the previous container end?","risk":"read-only","command":"kubectl logs POD -n atlas-workloads -c CONTAINER --previous; kubectl get events -n atlas-workloads --sort-by=.metadata.creationTimestamp","runFrom":"approved namespace","expectedBranches":[{"when":"OOMKilled","meaning":"memory termination reported","nextEvidence":"inspect limits and usage"},{"when":"Unhealthy then Killing","meaning":"liveness restart","nextEvidence":"inspect probe"}],"proves":"prior logs and retained events","doesNotProve":"durable history"},
    {"id":"LES-0042-CMD-006","question":"Do three probes ask three questions?","risk":"read-only","command":"kubectl get deploy atlas-api -n atlas-workloads -o yaml","runFrom":"approved namespace","expectedBranches":[{"when":"startup readiness liveness differ","meaning":"consequences separated","nextEvidence":"measure thresholds"},{"when":"same deep dependency","meaning":"failure amplification risk","nextEvidence":"redesign"}],"proves":"declared probes","doesNotProve":"handler correctness"},
    {"id":"LES-0042-CMD-007","question":"Is the Deployment update progressing?","risk":"read-only","command":"kubectl get deployment atlas-api -n atlas-workloads -o yaml; kubectl get rs -n atlas-workloads","runFrom":"approved namespace","expectedBranches":[{"when":"available reaches desired","meaning":"controller converged","nextEvidence":"verify users"},{"when":"deadline exceeded","meaning":"new revision stalled","nextEvidence":"diagnose new Pods"}],"proves":"controller update status","doesNotProve":"correct response"},
    {"id":"LES-0042-CMD-008","question":"What changes before persistence?","risk":"mutating-bounded","command":"kubectl diff -n atlas-workloads -f deployment.yaml; kubectl apply --server-side --dry-run=server -f deployment.yaml -o yaml","runFrom":"reviewed fixture","expectedBranches":[{"when":"only intended fields","meaning":"review can continue","nextEvidence":"check capacity"},{"when":"unexpected scope","meaning":"blast radius changed","nextEvidence":"stop"}],"proves":"dry admitted object and diff","doesNotProve":"runtime","cleanup":"dry-run persists nothing"},
    {"id":"LES-0042-CMD-009","question":"May one voluntary eviction proceed?","risk":"read-only","command":"kubectl get pdb atlas-api -n atlas-workloads -o yaml","runFrom":"approved namespace","expectedBranches":[{"when":"disruptionsAllowed positive","meaning":"policy may allow eviction","nextEvidence":"confirm selector"},{"when":"zero","meaning":"eviction should block","nextEvidence":"restore health"}],"proves":"PDB status","doesNotProve":"involuntary protection"},
    {"id":"LES-0042-CMD-010","question":"Why does HPA want this count?","risk":"read-only","command":"kubectl get hpa atlas-api -n atlas-workloads -o yaml; kubectl top pod -n atlas-workloads","runFrom":"approved metrics pipeline","expectedBranches":[{"when":"metric and target align","meaning":"math inspectable","nextEvidence":"check placement"},{"when":"metric unknown","meaning":"feedback missing","nextEvidence":"repair metric contract"}],"proves":"HPA status","doesNotProve":"capacity"},
    {"id":"LES-0042-CMD-011","question":"Do hard constraints intersect to any node?","risk":"read-only","command":"kubectl get pod POD -n atlas-workloads -o yaml; kubectl get nodes --show-labels; kubectl get resourcequota -n atlas-workloads -o yaml","runFrom":"approved cluster","expectedBranches":[{"when":"one node feasible","meaning":"placement possible","nextEvidence":"read scheduler"},{"when":"none feasible","meaning":"intent impossible","nextEvidence":"remove least justified constraint"}],"proves":"declared constraints","doesNotProve":"plugin configuration"},
    {"id":"LES-0042-CMD-012","question":"Does the model cover eight boundaries and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0042 support/lab","expectedBranches":[{"when":"verification pass","meaning":"model passed","nextEvidence":"retain model-only label"},{"when":"assertion fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic model","doesNotProve":"Kubernetes runtime","cleanup":"verifier proves absence"}
  ],
  "labs": [
    {"id":"LES-0042-LAB-001","title":"Guided workload-state model","mode":"guided","environment":"Ubuntu 24.04 normal user, Bash and Python 3; no cluster","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temp root","eight deterministic cases"],"abortConditions":["root","network","kubectl","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and rerun clean.","cleanupProof":"Validate exact inventory and remove exact root.","path":"book/labs/LES-0042-kubernetes-workloads-scheduling-rollouts"},
    {"id":"LES-0042-LAB-002","title":"Independent pinned local-cluster transfer","mode":"independent","environment":"Reviewer-owned disposable cluster, preloaded image and dedicated namespace","timeMinutes":240,"privilege":"namespace-scoped learner","network":"loopback/local only","changes":["workload controllers","resource and probe faults","PDB and HPA"],"abortConditions":["wrong context","cluster-admin","external pull","hostPath","privileged","unbounded load"],"recovery":"Preserve evidence and recover through owner controller.","cleanupProof":"Reviewer proves namespace, credentials and cluster absent.","path":"book/labs/LES-0042-kubernetes-workloads-scheduling-rollouts"}
  ],
  "incidents": [
    {"id":"LES-0042-INC-001","signal":"Pending with empty nodeName.","firstThought":"No binding exists.","safePath":"Inspect scheduler reasons, requests and all hard constraints.","trap":"Restart kubelet."},
    {"id":"LES-0042-INC-002","signal":"Running but not Ready.","firstThought":"Process state is not traffic eligibility.","safePath":"Inspect conditions, readiness and endpoints.","trap":"Assume Running means serving."},
    {"id":"LES-0042-INC-003","signal":"CrashLoopBackOff grows.","firstThought":"Backoff follows repeated termination.","safePath":"Read lastState, previous logs, events, OOM and probes.","trap":"Delete the Pod."},
    {"id":"LES-0042-INC-004","signal":"ProgressDeadlineExceeded.","firstThought":"New revision failed availability in time.","safePath":"Freeze, compare revisions, diagnose new Pods, roll back by policy.","trap":"Only increase deadline."},
    {"id":"LES-0042-INC-005","signal":"HPA scales but replicas stay Pending.","firstThought":"Feedback works but capacity does not execute intent.","safePath":"Inspect math, scheduler, quota and node headroom.","trap":"Only raise maxReplicas."}
  ],
  "assessmentIds": ["ASM-0109","ASM-0110","ASM-0111"],
  "referenceIds": ["REF-0388","REF-0389","REF-0390","REF-0391","REF-0392","REF-0393","REF-0394","REF-0395","REF-0396","REF-0397","REF-0398","REF-0399","REF-0400","REF-0401","REF-0402"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": ["No cluster or real Pod ran.","The model is not scheduler, kubelet, probe, rollout, eviction or HPA evidence.","No credential, cloud, external registry, privilege or production load.","Formal review and learner evidence are absent."]
}
---

# Kubernetes workloads: schedule, start, probe, roll out, disrupt, and scale safely

## What you see and first thought

`STATUS=Running` and restart count zero do not mean users are healthy. Running is only a Pod phase: the Pod was bound and at least one container is running, starting, or restarting. It says nothing about readiness, EndpointSlices, response correctness, latency, downstream health, or served revision.

Use this chain: controller intent -> Pod -> scheduling -> node setup -> process -> startup -> readiness -> endpoint -> user operation. Every arrow can fail independently. First bind controller UID, revision and Pod UID; then ask whether `spec.nodeName` is empty; then read conditions plus every container's current and previous state; finally verify the normal user path.

## Terms before commands

**Pod** is the smallest schedulable API object and one UID is one lifetime. **Phase** is a coarse summary, not a detailed state machine. **Conditions** answer separate questions such as scheduled, initialized, containers ready and Pod ready. **Container state** is Waiting, Running or Terminated; `lastState`, reason, exit code, signal, timestamps, restart count and previous logs explain the prior lifetime.

**Request** influences placement and resource sharing. It is not a hard cap. **Limit** is an enforcement/policy ceiling: CPU normally throttles while memory can produce an OOM kill. **QoS class** is derived from requests and limits and influences node-pressure behavior, but it is not the only eviction input.

**Startup probe** protects slow initialization. **Readiness probe** controls traffic eligibility. **Liveness probe** restarts a container believed locally unrecoverable. One deep dependency check should not casually drive all three consequences.

**Deployment** manages interchangeable rolling revisions through ReplicaSets. **StatefulSet** adds stable ordinal identity and storage association. **Job** tracks finite completion, **CronJob** creates Jobs on a schedule, and **DaemonSet** targets eligible nodes. Choose from semantics, not popularity.

The Pod phase vocabulary is deliberately small. Pending includes accepted Pods whose regular containers are not yet running, both before and after scheduling. Running means bound with at least one container running, starting, or restarting. Succeeded means every container ended successfully and will not restart; Failed means every container ended and at least one failed or was not restarted; Unknown means the control plane could not obtain state.

Do not invent a phase from CLI presentation. `Terminating` and `CrashLoopBackOff` are useful displayed reasons, not extra Pod phases. Alerts and scripts must use API fields, not assumptions about a table.

Init containers run before regular application containers. A failing init can prevent application startup. Scheduling must account for the regular-container sum and applicable maximum init demand, plus Pod overhead. Sidecar semantics are version-sensitive and must be checked against the pinned cluster.

Restart and replacement are separate. Kubelet can restart a container inside one Pod UID. A controller can replace the Pod object with a new UID. The first retains Pod identity and restart history; the second creates a new lifetime whose old evidence may disappear.

Choose controllers from semantics. Deployment is for interchangeable rolling replicas. StatefulSet adds ordinal identity, ordering and storage association, but does not make a database quorum-safe. Job tracks finite completion, where retries must not duplicate external side effects. CronJob creates Jobs and needs schedule, time-zone, missed-start, concurrency and idempotency policy. DaemonSet tracks eligible-node membership and still depends on selectors, taints and update strategy.

## Architecture map

```text
Deployment -> ReplicaSet -> Pod without nodeName
                               |
                     scheduler filter/score/bind
                               |
                     kubelet -> runtime -> process
                               |
                  probes -> Ready -> EndpointSlice
                               |
                           user request
```

The Deployment controller does not choose nodes. The scheduler does not pull images. Kubelet does not decide surge. HPA changes replica intent but does not create Pods directly. Ownership, placement, execution, traffic admission and user behavior are separate loops.

## Request or state path

A Deployment template change increments generation. The Deployment controller creates or scales a new ReplicaSet. Its controller creates Pods. Scheduler filters infeasible nodes using resources, labels, affinity, taints, topology, ports and volumes; scores feasible nodes; then writes a binding. Kubelet creates sandbox and mounts, resolves images, runs init and app containers, and reports status. Readiness controls endpoint eligibility. The Deployment counts availability and scales old capacity down within surge/unavailability. Only a normal request proves the new revision works.

An apply can succeed before any child exists. A rollout can report complete while a shallow readiness probe admits broken instances. Never compress the path into “deployed.”

The Deployment envelope uses `maxSurge` and `maxUnavailable`. Rounding affects exact counts, so inspect resolved status rather than guessing. Surge consumes scheduler capacity; unavailability consumes serving redundancy. `minReadySeconds` delays when readiness counts as availability. `progressDeadlineSeconds` reports lack of progress; increasing it does not repair a bad revision.

Revision rollback is safe only while application, configuration, schema and external-state compatibility still hold. StatefulSet updates add identity and storage risk; a broken ordinal can block progress, and volume data outlives Pod replacement. Job success proves process completion under policy, not exactly-once money transfer, restorable backup or complete input processing.

## Failure zoom

Pending with empty `nodeName` points to scheduler feasibility. Pending with a node name points after binding: sandbox, CNI, image, volume, config or runtime. `CrashLoopBackOff` is restart backoff, not a root cause; inspect `lastState` and previous logs. Running/not Ready means a process exists but traffic eligibility failed. `OOMKilled` indicates a container memory termination; an `Evicted` Pod is a different node-pressure path.

Decode signals precisely. `ErrImagePull` is the immediate pull failure; `ImagePullBackOff` adds retry delay. `CreateContainerConfigError` often means required configuration cannot be resolved. A fast nonzero exit can be command, architecture, permission, filesystem, security-context or application failure. Exit 137 can follow SIGKILL but does not alone prove OOM; use terminated reason plus cgroup/kernel evidence. Exit 143 commonly follows SIGTERM and can be normal during graceful shutdown.

Readiness and liveness have different blast radii. Readiness removes normal traffic eligibility without restarting. Liveness restarts. If both call the same deep shared dependency, one dependency incident can remove all endpoints and restart all replicas. Probe period, timeout, failure threshold and success threshold form a detection/recovery control loop; choose them from observed latency and startup distributions.

Preserve early evidence. Events expire, previous logs can disappear, status is asynchronous, and replacement creates a new UID. Deleting a Pod often destroys the best causal record while recreating the same template.

## Internals and state ownership

The scheduler uses declared requests, Pod overhead, init-container rules and constraints, not future demand. Hard constraints intersect: a valid zone rule, SSD label, anti-affinity, taint and volume topology can collectively make zero nodes feasible.

Filtering removes infeasible nodes; scoring ranks feasible nodes. A score cannot rescue a failed hard requirement. Node selectors and affinity attract. Taints repel unless tolerations allow consideration; toleration is not attraction and never guarantees placement. Topology spread depends on correct selectors, keys, skew, minimum domains and consistent node labels.

Hard Pod anti-affinity can be expensive and brittle at scale. Use hard exclusion only for correctness or isolation; prefer soft spread when a preference is enough. Requests are the scheduling/accounting promise. Limits are not subtracted from allocatable in the same way, so low requests plus high real use can create legitimate scheduler admission followed by node pressure.

CPU is compressible: limit pressure throttles and increases latency, queues and probe timeouts. Memory is incompressible: limit pressure can kill a process; node pressure can evict Pods. Ephemeral storage is another schedulable/enforceable dimension. Priority and preemption govern who may displace whom; they do not create resources and require tenant policy.

For CPU, `100m` is one tenth of a CPU. A process may burst above request when idle capacity exists, subject to limits and competition. Tight limits can leave the container Running while response time expands; measure throttling with latency. Memory is not a time slice. Compare working set, RSS, cache, heap, concurrency, request, limit and node headroom before increasing a limit.

Kubelet may evict for memory, disk or inode pressure. QoS, priority, requests and actual use influence the decision, but no class is an unconditional guarantee. Preserve Evicted status and node conditions. ResourceQuota governs aggregate namespace consumption; LimitRange can default or constrain object resources. Admission rejection and scheduler rejection are different boundaries.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| scheduled | nodeName and scheduler/binding evidence | node execution |
| container restarted from OOM | lastState OOMKilled plus resource evidence | why memory grew |
| Pod Ready | current Ready condition for current UID | correct endpoint propagation |
| rollout complete | observed generation, revision and available counts | user correctness |
| one eviction allowed | correct PDB selector and disruptionsAllowed | involuntary failure safety |
| HPA active | metric, target, desired replicas and conditions | schedulability |
| recovered | normal request through current revision | recurrence prevention |

## Command decoders

`get -o wide` places the Pod quickly; YAML/JSON gives exact fields. Quote JSONPath so the shell does not consume syntax. Record UID with the name. `logs --previous` is the first place for a restarted container when retained. `describe` is useful presentation but not durable history.

`rollout status` observes controller progress; its success is not an application test. `kubectl top` depends on a metrics pipeline and is recent resource data, not profiling. HPA CPU utilization is usage divided by request; missing or misleading requests break that contract.

## Decision path

1. Bind context, namespace, owner UID, revision and Pod UID.
2. State user impact and freeze unrelated rollout/scaling changes.
3. Compare workload generation and owned children.
4. Split on nodeName: empty is placement; set is node-side.
5. Read conditions and every current/last container state.
6. Correlate events, previous logs, resources, node pressure and probes.
7. Recover through the owning controller with the smallest reversible change.
8. Verify controller, Ready endpoints, served revision and user operation.

For impossible placement, restarts change nothing. For a bad revision with healthy old capacity, pause or rollback is safer than random Pod deletion. For probe storms, preserve an external health signal and correct probe ownership through reviewed source.

## Guided Ubuntu lab

The lab is a deterministic model, not Kubernetes. It covers eight cases: excessive request, impossible constraints, image pull failure, crash loop, OOM kill, Running/not Ready, stalled rollout and HPA scale intent with no placement capacity.

```bash
cd book/labs/LES-0042-kubernetes-workloads-scheduling-rollouts
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh diagnose pending-resources
bash lab.sh verify-cases
bash lab.sh cleanup
```

It refuses root, network, kubectl, symlinks, wrong ownership and unknown artifacts. Passing proves only deterministic source and assertions, never a scheduler, kubelet, cgroup, probe, controller or cluster.

For each case, say the boundary before saying the repair. “Pending-resources is a scheduler feasibility failure because nodeName is empty and the scheduler reports insufficient memory” is stronger than “increase memory.” The latter is an action without identity, evidence, ownership or capacity analysis.

The wrong-answer test deliberately maps a pre-binding resource failure to a node-side image boundary and must reject it. Cleanup deliberately refuses an unknown artifact. These negative tests matter because a happy-path script can appear safe while accepting a false diagnosis or deleting an unowned file.

## Production transfer

A real transfer needs a reviewer-owned pinned disposable local cluster, preloaded image, namespace-scoped identity and baseline evidence. Inject one failure at a time: oversized request, impossible affinity, missing toleration, bad image, process exit, bounded memory fault, readiness failure, stalled rollout, PDB-mediated drain refusal and HPA capacity ceiling.

Every fault needs an expected signal, abort condition, recovery owner, manifest diff and user verification. No external pull, hostPath, privilege, unbounded load or unreviewed node drain. Cleanup proves namespace objects, finalizers, credentials and disposable cluster absent.

Before a drain exercise, calculate availability. A PDB selector must match the intended Pods, its desired/current healthy status must be current, and `disruptionsAllowed` must cover the planned eviction. The eviction API can return a retryable denial when the budget would be violated. Direct Pod deletion bypasses the normal voluntary-disruption contract and is not a valid way to “test the PDB.”

PDBs do not create redundancy, repair broken probes or guarantee capacity in another zone. A budget of `minAvailable: 5` on five currently healthy replicas permits no voluntary eviction. If one replica is already unready, the safe response is usually to restore health or add verified capacity, not force the drain.

Termination is a protocol. On deletion, kubelet starts graceful termination, endpoints may become not-ready, preStop hooks may run, and the process receives its termination signal according to runtime semantics. The application must stop accepting new work, finish or checkpoint bounded in-flight work, release leases safely and exit within the grace period. An excessively long grace period delays rollout/drain; a short one corrupts work.

HPA is also a protocol. For a resource metric, the controller compares current metric to target and derives a desired replica count, with tolerance and behavior policies. Missing metrics and not-yet-ready Pods receive conservative treatment so unstable startup does not create reckless scale decisions. Stabilization windows and scaling policies limit oscillation, but add response delay.

Autoscaling needs four capacities: metric capacity (fresh trustworthy signal), controller capacity (HPA can update the scale target), placement capacity (scheduler can bind the requested replicas), and serving capacity (new Pods become Ready soon enough). A green HPA with Pending Pods proves only the first two parts may be working.

Scale-to-demand design includes startup time, readiness delay, demand growth rate, per-replica safe throughput, queue tolerance and node-provisioning delay. If traffic doubles in 30 seconds and new Pods need 90 seconds to serve, HPA alone cannot meet the transient. Use headroom, faster startup, load shedding, queues or predictive/scheduled policy according to workload.

## Reliability, security, observability, capacity, and cost

Reliability depends on measured requests and meaningful probes. Under-requesting overpacks nodes and may increase throttling, retries and incidents; over-requesting strands capacity. Liveness against a shared database can restart every replica during the database outage. Readiness that merely checks “process exists” routes traffic to broken instances.

Probe design starts with consequence:

- startup asks, “Has initialization completed enough that liveness/readiness may begin?”
- readiness asks, “Should this exact Pod receive normal traffic now?”
- liveness asks, “Is this exact container locally stuck in a way a restart can repair?”

An application can be live but not ready during downstream isolation. A startup probe should cover worst credible initialization without hiding a permanent failure forever. A liveness endpoint must not depend on a shared component whose outage makes restarting harmful. If exec probes spawn expensive processes every second, the probe itself can become load.

Security settings can block startup: run-as identity, filesystem ownership, seccomp, capabilities, secrets and read-only roots. Do not cure a permission error with privilege; identify the exact boundary and grant least privilege.

Security also controls supply and placement: immutable image digests, admission policy, service-account scope, secret projection, image pull credentials, node trust and workload isolation. `ImagePullBackOff` can be a security failure, but copying a registry credential into a manifest is not a repair. Use approved secret delivery and rotate exposed credentials.

Capacity includes normal load, failover, rollout surge, disruption, daemon/system reservations and topology. PDBs and autoscalers cannot manufacture headroom. Observe controller revision, scheduling, node pressure, termination, probes, endpoints, requests and user SLO together.

Cost and reliability share the same measurement problem. Averages hide peaks, cold starts and per-zone imbalance. Select requests from representative distributions and safety policy, validate limits with load and failure, then observe utilization, throttling, OOM, latency and replica count. The cheapest stable configuration is not necessarily the smallest request; it is the one that meets reliability with understood headroom and low operational waste.

## Traps and prevention

Running is not healthy: require Ready, endpoint and user evidence. CrashLoopBackOff is not fixed by deletion: preserve prior state and change the owner. A PDB does not cover every failure: combine replicas, topology and capacity. HPA does not create nodes: alert on desired-versus-schedulable/Ready lag. Hard anti-affinity is not free resilience: prefer soft spread unless correctness requires exclusion. Rollout completion is not success: verify served revision through the normal route.

## Memory card and retrieval

Remember **OWN-SERVE**: Owner and revision; Where/nodeName; Now and last state; Scheduling constraints; Execution/image/volume/process/cgroup; Readiness/endpoints; Version through user response; Exit through safe owner recovery.

Explain from memory: Pending before versus after binding; Running versus Ready; restart versus controller replacement; CPU throttling versus OOM; voluntary disruption versus node loss; HPA desired versus schedulable Ready replicas.

## Complete answers

**Why can free host memory coexist with an unschedulable 500 MiB Pod?** Kubernetes compares requests with allocatable/requested capacity and every hard constraint. Nodes with bytes available may fail labels, taints, affinity, topology, ports or volume locality. Host `free` is not the scheduling ledger.

**Should OOMKilled always get a larger limit?** No. Bind the lifetime and determine whether the limit is wrong, allocation leaked, cache/concurrency changed, sidecars contribute, or node pressure caused another mechanism. A larger limit can move failure to the node.

**What makes rollout safe?** Reviewed diff, bounded surge/unavailability, realistic probes, enough placement headroom, progress deadline, preserved old capacity, observable revision, rollback path and normal user verification.

**Why does HPA CPU utilization need requests?** Utilization is usage divided by requested CPU. Request is the denominator and influences placement; absent or distorted requests make the feedback signal unavailable or misleading.

## Product-company interview

A release leaves old Pods Ready while new Pods alternate between Running/not Ready and OOM restarts. A strong response freezes changes, binds old/new revisions and Pod UIDs, preserves lastState/previous logs/events/memory evidence, confirms scheduling already completed, separates readiness from OOM, compares new resource/config behavior, rolls back at Deployment level if policy requires, verifies old revision users, then reproduces under bounded load and adds new-revision rollout guards. “Delete Pods and raise memory” repeats the template and tests no hypothesis.

## Independent transfer and rubric

Unseen case: six replicas, `maxUnavailable: 1`, PDB `minAvailable: 5`, required hostname anti-affinity, five eligible nodes, one node drain, new revision and HPA desired ten. Produce exact UID/revision inventory, feasible-node calculation, rollout-versus-eviction distinction, desired-versus-schedulable capacity, safe recovery and user verification.

Rubric: 20 identity/evidence, 20 placement reasoning, 20 rollout/disruption distinction, 15 autoscaling feedback, 15 recovery, 10 user verification. Only independently reviewed learner reasoning can pass.

## References and review

`REF-0388` through `REF-0402` are current official Kubernetes sources for Pods, lifecycle, controllers, Deployment, StatefulSet, Job, bin packing, resources, probes, QoS, assignment, taints, disruption, HPA and quota. Before publication, pin a cluster version, record components/runtime, execute every fault and cleanup, and review sources. Documentation plus a model is not runtime evidence.
