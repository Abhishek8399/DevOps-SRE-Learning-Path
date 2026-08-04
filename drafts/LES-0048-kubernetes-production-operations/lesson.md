---
{"schemaVersion":1,"kind":"lesson","id":"LES-0048","slug":"kubernetes-production-operations","aliases":["V05-L12","kubernetes-production-operations"],"curriculumIds":["K8S-008"],"route":"/book/infrastructure/kubernetes-production-operations","order":12,"volume":"05-infrastructure-platforms","title":"Kubernetes production operations: upgrades, capacity, recovery, and control-plane reliability","summary":"Operate Kubernetes as a dependency graph: prove version compatibility, disruption capacity, control-plane health, tenant fairness, backup restoration, and user recovery.","domain":"infrastructure","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0032","LES-0035","LES-0041","LES-0042","LES-0043","LES-0044","LES-0045","LES-0046","LES-0047"],"prerequisiteCurriculumIds":["SRE-002","PERF-001","K8S-001","K8S-002","K8S-003","K8S-004","K8S-005","K8S-006","K8S-007"],"testedEnvironments":[{"platform":"Kubernetes documentation","version":"v1.36 current documentation","support":"supported","notes":"Official version-skew, kubeadm-upgrade, drain, disruption, autoscaling, quota, flow-control, scale, etcd, audit, logs and troubleshooting sources reviewed 2026-08-04."},{"platform":"etcd documentation","version":"v3.6","support":"supported","notes":"Official disaster-recovery guidance reviewed 2026-08-04."},{"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No upgrade, drain, capacity, etcd snapshot/restore, or failure runtime evidence."}],"targetRoles":["site-reliability-engineer","platform-engineer","kubernetes-engineer","devops-engineer","infrastructure-engineer","technical-lead","architect"],"learningObjectives":["Map Kubernetes production ownership across control plane, nodes, add-ons, workloads, data and user journeys.","Plan patch and minor upgrades from exact component versions, skew rules, deprecations and add-on compatibility.","Execute canary control-plane and node changes with abort, rollback and user-level evidence.","Calculate schedulable and serving capacity through requests, topology, disruption, surge and autoscaling delay.","Use quotas and API Priority and Fairness to contain tenant and control-plane overload.","Diagnose node, scheduler, API, controller, DNS, networking, storage and admission failures from the last proven boundary.","Design etcd backup, isolated restore and full dependency recovery against measured RPO/RTO.","Define control-plane and workload SLIs, alerts, logs, audits, runbooks and ownership.","Operate multi-tenant change windows, maintenance communication and exception governance.","Distinguish Kubernetes object recovery from application data and user recovery."],"productionSignals":["cluster/provider/region/version/support window and change ID","API server controller scheduler kubelet kube-proxy runtime CNI CSI DNS ingress admission CRD/operator versions","deprecated API usage and webhook conversion compatibility","etcd member/cluster ID revision DB size alarms leader latency snapshot hash and restore identity","API request latency errors inflight APF queues/seats/rejections by priority","controller workqueue depth latency retries leader leases and stale generations","node Ready pressure conditions allocatable requests pods taints cordon and drain state","PDB desired/current healthy disruptionsAllowed unhealthyPodEvictionPolicy","pending Pods scheduling reasons topology and volume constraints","HPA desired/current replicas metric timestamp target behavior and missing metrics","node provision/start/register/image-pull/readiness delay and spare capacity","quota usage/hard limits and tenant ownership","DNS/CNI/CSI/ingress/add-on availability and version compatibility","workload generation readiness endpoints disruption and user SLI","backup/restore UTC duration integrity application transaction RPO/RTO","audit IDs change timeline abort rollback and cleanup proof"],"diagrams":[{"id":"LES-0048-DIA-001","title":"Production dependency map","direction":"hierarchical","boundaries":["user journey","workloads","cluster services","nodes","control plane","etcd","external infrastructure"],"evidencePoints":["SLI","conditions","component versions","snapshot"],"textAlternative":"User journeys depend on workloads, cluster services, nodes, the control plane, etcd and external infrastructure, each with separate evidence."},{"id":"LES-0048-DIA-002","title":"Upgrade order and gates","direction":"left-to-right","boundaries":["inventory","compatibility","backup/restore proof","canary control plane","remaining control plane","canary node","node waves","add-ons","user verification"],"evidencePoints":["skew matrix","abort gate","versions","SLI"],"textAlternative":"An upgrade proceeds through inventory, compatibility and recovery gates before canary control-plane and node waves and user verification."},{"id":"LES-0048-DIA-003","title":"Drain capacity equation","direction":"left-to-right","boundaries":["cordon","eviction","PDB","replacement scheduling","volume attach","readiness","endpoint","user"],"evidencePoints":["disruptionsAllowed","pending reason","surge","journey"],"textAlternative":"A safe drain needs eviction permission plus enough topology-aware capacity for replacements to become serving endpoints."},{"id":"LES-0048-DIA-004","title":"Autoscaling delay chain","direction":"cyclic","boundaries":["demand","metric","HPA decision","pending Pod","node provision","image/startup","readiness","served load"],"evidencePoints":["metric age","desired replicas","provision time","queue"],"textAlternative":"Scaling reacts after demand and metrics, then may wait for scheduling, nodes, images, startup and readiness before capacity serves users."},{"id":"LES-0048-DIA-005","title":"Control-plane overload containment","direction":"hierarchical","boundaries":["clients/controllers","API Priority and Fairness","API server","admission","etcd","watchers"],"evidencePoints":["priority level","queues","rejections","latency","DB alarms"],"textAlternative":"API traffic passes fairness, admission and persistence; overload can amplify through retries and watches unless work is classified and bounded."},{"id":"LES-0048-DIA-006","title":"Recovery evidence chain","direction":"left-to-right","boundaries":["snapshot","integrity","isolated restore","cluster identity","API objects","add-ons","workloads","application data","user transaction"],"evidencePoints":["hash","revision","RPO","RTO","journey"],"textAlternative":"A snapshot becomes recovery evidence only after isolated restore, cluster and application reconstruction, and user transaction verification."}],"commands":[{"id":"LES-0048-CMD-001","question":"What exact component and API versions are in scope?","risk":"read-only","command":"kubectl version; kubectl get nodes -o wide; kubectl api-resources","runFrom":"approved cluster context","expectedBranches":[{"when":"inventory matches change record","meaning":"version baseline bound","nextEvidence":"compatibility matrix"},{"when":"unexpected skew/add-on","meaning":"upgrade scope incomplete","nextEvidence":"stop"}],"proves":"reported client/server/node/API inventory","doesNotProve":"support or compatibility"},{"id":"LES-0048-CMD-002","question":"Which deprecated APIs are still requested?","risk":"read-only","command":"kubectl get --raw /metrics","runFrom":"approved authenticated local API proxy with bounded capture","expectedBranches":[{"when":"deprecated-request metrics mapped to owners","meaning":"migration work identifiable","nextEvidence":"update clients/manifests"},{"when":"missing/unknown","meaning":"upgrade blind spot","nextEvidence":"audit/log discovery"}],"proves":"one API metrics response","doesNotProve":"all dormant clients"},{"id":"LES-0048-CMD-003","question":"Is the proposed kubeadm transition supported before mutation?","risk":"read-only","command":"sudo kubeadm upgrade plan","runFrom":"authorized disposable control-plane node","expectedBranches":[{"when":"expected target/add-ons/config","meaning":"tool plan available","nextEvidence":"human compatibility review"},{"when":"error/unexpected target","meaning":"precondition failed","nextEvidence":"stop"}],"proves":"kubeadm plan for node state","doesNotProve":"successful upgrade"},{"id":"LES-0048-CMD-004","question":"Can this node be disrupted without violating declared availability?","risk":"read-only","command":"kubectl get node NODE -o yaml; kubectl get pdb -A -o wide; kubectl get pods -A --field-selector spec.nodeName=NODE -o wide","runFrom":"approved operator context","expectedBranches":[{"when":"owners/PDB/capacity allow","meaning":"drain candidate understood","nextEvidence":"dry rehearsal/canary"},{"when":"singleton/local data/zero allowance","meaning":"unsafe disruption","nextEvidence":"add capacity/change window"}],"proves":"declared node/workload/disruption state","doesNotProve":"future replacement readiness"},{"id":"LES-0048-CMD-005","question":"Can an approved disposable node be drained?","risk":"destructive-disposable","command":"kubectl drain NODE --ignore-daemonsets --delete-emptydir-data --timeout=15m","runFrom":"reviewer-owned disposable cluster after workload/data approval","expectedBranches":[{"when":"bounded drain completes","meaning":"eligible Pods evicted","nextEvidence":"upgrade/replace and verify"},{"when":"blocked","meaning":"PDB/owner/storage/capacity boundary","nextEvidence":"stop; inspect blocker"}],"proves":"one drain attempt","doesNotProve":"user availability","cleanup":"complete reviewed node recovery, kubectl uncordon NODE, and verify every workload/user path"},{"id":"LES-0048-CMD-006","question":"Where is schedulable capacity constrained?","risk":"read-only","command":"kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory,PODS:.status.allocatable.pods; kubectl get pods -A --field-selector=status.phase=Pending -o wide","runFrom":"approved cluster","expectedBranches":[{"when":"headroom and no unexplained pending","meaning":"declared capacity visible","nextEvidence":"topology/disruption model"},{"when":"pending reasons or exhausted dimension","meaning":"capacity bottleneck","nextEvidence":"events/requests/topology"}],"proves":"reported allocatable and pending set","doesNotProve":"serving capacity"},{"id":"LES-0048-CMD-007","question":"What autoscaler decisions and metric freshness exist?","risk":"read-only","command":"kubectl get hpa -A -o wide; kubectl describe hpa -A","runFrom":"approved cluster","expectedBranches":[{"when":"fresh metrics/bounded behavior","meaning":"HPA input/output inspectable","nextEvidence":"pending/node delay"},{"when":"unknown/stale/maxed","meaning":"scaling cannot meet demand","nextEvidence":"metric and capacity path"}],"proves":"reported HPA state/events","doesNotProve":"capacity served"},{"id":"LES-0048-CMD-008","question":"Are tenants within declared resource budgets?","risk":"read-only","command":"kubectl get resourcequota,limitrange -A -o yaml","runFrom":"approved auditor context","expectedBranches":[{"when":"usage/hard/owners coherent","meaning":"budget boundary visible","nextEvidence":"fairness/user impact"},{"when":"missing/exhausted","meaning":"noisy-neighbor or admission risk","nextEvidence":"owner remediation"}],"proves":"declared namespace policy and usage","doesNotProve":"node or API fairness"},{"id":"LES-0048-CMD-009","question":"Is API flow control protecting critical work?","risk":"read-only","command":"kubectl get flowschema,prioritylevelconfiguration -o yaml","runFrom":"approved cluster auditor","expectedBranches":[{"when":"classifications/queues/rejections align","meaning":"declared APF policy visible","nextEvidence":"metrics/load evidence"},{"when":"catch-all/starvation risk","meaning":"control-plane fairness gap","nextEvidence":"review without live guess"}],"proves":"declared APF objects","doesNotProve":"behavior under load"},{"id":"LES-0048-CMD-010","question":"Is an etcd snapshot healthy enough to enter a restore drill?","risk":"read-only","command":"etcdutl snapshot status snapshot.db --write-out=table","runFrom":"offline protected snapshot copy using matching supported tool","expectedBranches":[{"when":"status/hash/revision recorded","meaning":"snapshot file structurally inspectable","nextEvidence":"isolated restore"},{"when":"invalid","meaning":"backup unusable","nextEvidence":"stop and repair pipeline"}],"proves":"offline snapshot metadata","doesNotProve":"restorable cluster/application"},{"id":"LES-0048-CMD-011","question":"Did the canary cluster change restore the user operation?","risk":"read-only","command":"kubectl get --raw='/readyz?verbose'; kubectl get nodes,pods -A -o wide","runFrom":"approved canary cluster","expectedBranches":[{"when":"control plane/nodes/workloads healthy","meaning":"selected layers report healthy","nextEvidence":"run user SLI transaction"},{"when":"degraded","meaning":"abort gate hit","nextEvidence":"preserve evidence and rollback"}],"proves":"reported readiness and object state","doesNotProve":"correct user behavior"},{"id":"LES-0048-CMD-012","question":"Does the offline operations model cover eight cases and exact cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0048 support/lab normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"model/refusals/cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic teaching model","doesNotProve":"upgrade drain autoscaling etcd or cluster runtime","cleanup":"verifier proves exact state absence"}],"labs":[{"id":"LES-0048-LAB-001","title":"Guided Kubernetes operations decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no cluster","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","eight deterministic production-operation cases"],"abortConditions":["root","network","credential","kubectl","etcd data","symlink","unknown artifact"],"recovery":"Preserve first failed gate and clean exact root.","cleanupProof":"Exact inventory and absence.","path":"drafts/LES-0048-kubernetes-production-operations/support/lab"},{"id":"LES-0048-LAB-002","title":"Independent pinned-cluster upgrade and recovery game day","mode":"independent","environment":"Reviewer-owned disposable multi-node local cluster","timeMinutes":240,"privilege":"learner follows scoped runbook; reviewer owns cluster/admin/restore","network":"local only","changes":["canary component/node change","drain/capacity fault","synthetic control-plane load","etcd snapshot/isolated restore"],"abortConditions":["production","real data","unsupported skew","unverified snapshot","quorum risk","unbounded load","user SLI breach beyond gate"],"recovery":"Abort wave, preserve timeline, use reviewed rollback/rebuild and isolated restore.","cleanupProof":"Reviewer proves cluster, snapshots, workloads, credentials and temporary evidence absent or intentionally retained.","path":"drafts/LES-0048-kubernetes-production-operations/support/lab"}],"incidents":[{"id":"LES-0048-INC-001","signal":"API errors rise after the first control-plane node upgrade.","firstThought":"Canary hit skew, admission, conversion, aggregation or etcd compatibility/latency boundary.","safePath":"Stop wave; bind component versions, audit IDs, readyz, admission/conversion and etcd evidence; rollback/rebuild only through tested path.","trap":"Upgrade remaining nodes for consistency."},{"id":"LES-0048-INC-002","signal":"Drain blocks indefinitely.","firstThought":"Eviction, PDB, controller, local data, topology or replacement capacity prevents safe disruption.","safePath":"Preserve the blocker and add/repair capacity or owner policy; do not force-delete stateful work.","trap":"Disable every PDB."},{"id":"LES-0048-INC-003","signal":"HPA requests more replicas but latency still grows.","firstThought":"Desired replicas are not yet serving capacity; inspect pending, node provision, image/startup, readiness, endpoints and downstream bottleneck.","safePath":"Shed/degrade demand and repair the slowest capacity stage.","trap":"Raise max replicas only."},{"id":"LES-0048-INC-004","signal":"API latency and controller queues rise under one tenant's automation.","firstThought":"High request rate/retries/watches are consuming control-plane fairness and etcd capacity.","safePath":"Identify user agent/priority/verb/resource, contain retry amplification, preserve critical traffic, and repair source client/policy.","trap":"Add API replicas without stopping amplification."},{"id":"LES-0048-INC-005","signal":"etcd snapshot restore starts but workloads remain unavailable.","firstThought":"Object-store recovery is only one dependency; identity, certificates, add-ons, nodes, storage and application data/user path remain.","safePath":"Follow dependency-ordered recovery, measure RPO/RTO and verify application transaction.","trap":"Declare recovery when API lists objects."}],"assessmentIds":["ASM-0127","ASM-0128","ASM-0129"],"referenceIds":["REF-0478","REF-0479","REF-0480","REF-0481","REF-0482","REF-0483","REF-0484","REF-0485","REF-0486","REF-0487","REF-0488","REF-0489","REF-0490","REF-0491","REF-0492"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No Kubernetes production runtime.","No real upgrade/drain/autoscaling/load or etcd restore.","Offline model is not cluster evidence.","Formal review and learner evidence absent."]}
---

# Kubernetes production operations: upgrades, capacity, recovery, and control-plane reliability

## What you see and first thought

A green cluster is not one green component. The API can answer while controllers lag, nodes are unschedulable, DNS fails, storage cannot attach, or users receive errors. Begin with the user operation, then find the last healthy dependency boundary.

For planned changes, “supported version” is not an upgrade plan. Inventory every control-plane, node and add-on version; check skew and deprecated APIs; prove restore; then canary. For incidents, stop the unsafe wave before trying to make versions visually consistent.

## Terms before commands

The **control plane** includes API serving, persistence, scheduling and controllers. **Version skew** is the supported difference among component versions. **Cordon** prevents new normal scheduling on a node. **Drain** requests eligible Pod evictions. A **PDB** limits voluntary disruption, not every outage.

**Schedulable capacity** can place a Pod. **Serving capacity** is Ready, in the endpoint path and successfully serving. HPA changes workload replicas; node autoscaling changes node capacity. **RPO** is acceptable data loss measured backward; **RTO** is acceptable recovery duration.

## Architecture map

```text
users -> ingress/service/DNS -> workloads -> nodes/runtime/CNI/CSI
                                 ^              |
                                 |              v
clients -> API/admission -> etcd -> controllers/scheduler
                   |
          audit, metrics, logs, traces, alerts
```

Every arrow is a dependency and evidence boundary. The cluster also depends on certificates, identity providers, load balancers, registries, storage backends and cloud/private infrastructure. Maintain an owner and rollback path for each.

## Request or state path

An ordinary API write passes transport, authentication, authorization, API Priority and Fairness, admission, persistence and watch delivery. Controllers and scheduler consume that state; kubelets and runtimes make node changes. Under overload, client retries, watch relists, webhooks and controller queues can amplify pressure on the same API and etcd they need for recovery.

An upgrade changes this graph in dependency order. API servers lead the supported component transition; other control-plane components and nodes follow within skew rules. Add-ons, CRDs, conversion/admission webhooks, clients and stored APIs have their own compatibility requirements.

## Failure zoom

During an upgrade, bind the first failing canary, exact versions and first user/control-plane symptom. Check `/readyz?verbose`, API latency/errors, admission and conversion failures, aggregated APIs, etcd leadership/latency/alarms and controller leases. Do not continue the wave merely because rollback seems harder later.

A blocked drain is useful evidence. PDB allowance may be zero; a Pod may be unmanaged, use local data, require an unavailable topology/volume, or have no spare requested capacity. `--force` and `--delete-emptydir-data` have explicit ownership and data consequences.

When HPA scales but users worsen, follow metric age → desired replicas → pending Pods → node provisioning → image pull/startup → readiness → EndpointSlice → downstream capacity. Desired replica count is a request, not throughput.

## Internals and state ownership

Kubernetes supports bounded component skew and an upgrade order; the deployment tool may be stricter. Before change, move to a current patch release in the existing minor where appropriate, review release notes/deprecations and never skip unsupported minor transitions. Test webhook equivalent matching and new fields.

Drain uses the eviction API where possible, so PDBs participate. A PDB protects a declared minimum/maximum during voluntary disruptions but cannot manufacture replicas, zones, nodes or storage. Maintenance safety is approximately: eligible replicas minus concurrent voluntary and involuntary losses must remain at least required serving replicas.

HPA commonly uses metrics relative to requests. Missing requests or metrics can prevent expected calculations. Stabilization and scaling behavior deliberately trade responsiveness for churn control. Node provisioners act later and need time for infrastructure, boot, registration, images and readiness.

API Priority and Fairness classifies requests into priority levels, queues and concurrency shares to protect important work. Quotas contain namespace resource consumption; neither replaces application rate limiting or node capacity planning.

etcd is Kubernetes' object state, not every application's durable data. Snapshot recovery changes cluster/member identity and needs matching procedures. A valid snapshot hash is not a restored service.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| upgrade supported | exact version/skew/deprecation/add-on matrix | successful change |
| control plane healthy | readyz, API SLI, etcd and controller evidence | user path |
| node drain safe | ownership, PDB, topology/storage and spare capacity | future failures |
| autoscaling effective | fresh input through serving replicas and SLI | next spike |
| tenant contained | quota and APF behavior under bounded load | application fairness |
| backup usable | integrity plus isolated restore | complete recovery |
| recovery achieved | application transaction and measured RPO/RTO | recurrence prevention |

## Command decoders

`kubectl version` reports client and API server versions, not every component. Node versions do not expose CNI, CSI, DNS, ingress, admission or operators. Build an inventory with image digests and ownership.

`kubeadm upgrade plan` is a tool-specific preflight, not authorization and not proof that workloads/add-ons tolerate the target. `kubectl drain` mutates scheduling and evicts Pods; use exact node identity, owner review, abort timing and a tested uncordon/recovery path.

`etcdutl snapshot status` reads snapshot metadata offline. Restore in an isolated environment first and follow the tool/version procedure. Never test destructive restore against the only control plane.

## Decision path

1. Bind cluster, user journeys, SLOs, owners, support window and change ID.
2. Inventory component/add-on/API versions and immutable artifacts.
3. Resolve skew, deprecations, webhook/CRD conversion and dependency compatibility.
4. Prove backup integrity and isolated restore; define RPO/RTO and rollback limitations.
5. Model serving capacity during control-plane/node/add-on disruption.
6. Establish canary, wave, observation, abort and communication gates.
7. Change one failure domain; observe control plane, workloads and users.
8. Stop on gate breach; preserve evidence before rollback/rebuild/forward fix.
9. Complete remaining waves only after soak evidence.
10. Verify versions, cleanup, user SLI, restore readiness and action follow-up.

## Guided Ubuntu lab

The offline model covers unsupported skew, deprecated API use, webhook incompatibility, drain/PDB deadlock, autoscaling delay, API retry overload, invalid snapshot and incomplete restore. Each case asks for the earliest failed boundary and safest next action.

It uses no cluster, credentials, network, etcd data or system mutation. Root, symlinks and unknown artifacts are refused. Passing it proves decision classification only.

## Production transfer

Use a reviewer-owned disposable multi-node cluster pinned to exact versions. Record the full inventory and user SLI. Create disruption-sensitive synthetic workloads, quotas, HPA and one safe API traffic generator. Take a synthetic etcd snapshot only under the cluster's documented method.

Canary a supported patch/minor or simulated component change, drain one node, inject pending capacity and bounded API pressure, then restore the snapshot into a separate cluster identity. Verify control plane, DNS/network/storage/add-ons, workloads, application data and user transaction. Never use production or unique data.

## Reliability, security, observability, capacity, and cost

Control-plane SLIs include API availability/latency, successful writes, APF queues/rejections, etcd commit/leader/space health, controller queue age and scheduler latency. Workload SLIs remain user-centered. Page on actionable symptoms with dependency context, not every Pod restart.

Secure admin credentials, snapshots, PKI, audit data and break-glass. Encrypt backups, restrict restore authority and rotate compromised trust. Upgrade supply-chain verification includes images/binaries/configuration and add-ons.

Capacity needs control-plane request rate/object/watch cardinality, etcd size/fragmentation, node resources, Pod density, IPs, storage attach limits, topology, surge and failure headroom. Cost includes spare capacity, replicated control plane, snapshot retention, test clusters, observability and engineering time; removing all headroom buys predictable incidents.

## Traps and prevention

- **Trap:** Upgrade all nodes quickly to reduce skew. **Prevention:** supported order, canary and stop gates.
- **Trap:** PDB means high availability. **Prevention:** replicas, topology, capacity and involuntary-failure design.
- **Trap:** Drain with force until empty. **Prevention:** classify owner/data/capacity blocker.
- **Trap:** HPA desired replicas equal capacity. **Prevention:** trace to endpoints and user SLI.
- **Trap:** Add control-plane replicas during retry storm. **Prevention:** stop amplification and use fairness.
- **Trap:** Snapshot succeeded, so DR works. **Prevention:** isolated restore and dependency/user proof.
- **Trap:** API objects restored, so data restored. **Prevention:** separate application data recovery.
- **Trap:** Shared cluster means equal fairness. **Prevention:** quotas, APF, ownership, SLOs and tested contention.

## Memory card and retrieval

Remember **INVENTORY → COMPATIBILITY → RECOVERY → CAPACITY → CANARY → USER**. A production change is safe only when each boundary has evidence and an owner.

Tomorrow answer: Why can a PDB block a drain yet still not guarantee availability? Why must API server versions lead an upgrade? Where does HPA capacity delay come from? What does a snapshot status not prove? Why can retries prevent recovery?

## Complete answers

**Should I force a blocked drain?** Not until you know the blocking Pod's owner, data, PDB, topology and replacement capacity. Force may bypass intended safety or delete unmanaged work; fix the capacity or schedule a reviewed exception.

**Why did autoscaling not save latency?** Scaling decisions arrive after metrics and may wait for scheduling, nodes, images, startup/readiness and downstream capacity. Protect users with headroom, shedding/degradation and faster bottleneck-specific scaling.

**What is a Kubernetes backup?** etcd captures Kubernetes API state. Application volumes, external databases, registries, identities, certificates and infrastructure may require separate, coordinated recovery. Only a full restore drill measures useful RPO/RTO.

**How do I know upgrade succeeded?** Exact target versions and no unsupported skew, stable control-plane/add-on SLIs, reconciled workloads, successful DNS/network/storage/admission paths, and the original user journeys through a defined soak window.

## Product-company interview

**Question:** Lead a 500-node cluster minor upgrade with zero planned customer downtime.

**Strong answer:** I inventory control-plane, node and add-on versions, deprecated APIs, CRDs, conversions and webhooks; validate supported skew/order; prove backup and isolated restore; model zone and drain capacity; and define user SLO abort gates. I upgrade a control-plane canary, then the remaining HA control plane, then one node pool/zone canary and bounded waves. Each gate checks API/etcd/controllers, scheduling, DNS/CNI/CSI/ingress and user transactions. I stop rather than finish the wave on breach, and communicate impact/decision/next update.

**Weak answer:** Use the managed upgrade button during low traffic. It ignores compatibility, capacity, recovery, add-ons, user proof and abort ownership.

## Independent transfer and rubric

The reviewer supplies an unseen cluster inventory with unsupported skew, deprecated API traffic, a webhook incompatibility, zero drain allowance, slow scale-up, tenant retry overload and a snapshot that has never been restored. Produce a safe plan, identify every stop gate, lead one simulated failure and defend recovery. `ASM-0129` keeps the scoring solution reviewer-only.

Mastery requires independently observed execution, not reading or model success. Evidence must include an unseen changed case, exact user verification, safe cleanup and delayed retrieval.

## References and review

Fifteen official Kubernetes and etcd sources cover skew/order, kubeadm upgrades, drains/disruption, workload/node autoscaling, quotas, API fairness, large-cluster concerns, etcd operation/recovery, auditing, logs and troubleshooting. They were reviewed 2026-08-04 and require review by 2027-02-04.

Version and deployment-tool behavior changes. Pin the exact cluster distribution, Kubernetes/etcd versions, add-ons and provider procedures before applying any command.
