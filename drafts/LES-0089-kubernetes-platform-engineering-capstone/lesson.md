---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0089",
  "slug":"kubernetes-platform-engineering-capstone",
  "aliases":["V11-L02","kubernetes-platform-engineering-capstone"],
  "curriculumIds":["CAP-002"],
  "route":"/book/capstones/kubernetes-platform-engineering-capstone",
  "order":2,
  "volume":"11-capstones",
  "title":"Kubernetes platform engineering capstone: build a safe local developer platform",
  "summary":"Integrate Kubernetes control planes, multi-tenancy, policy, GitOps-shaped reconciliation, golden paths, SLOs, capacity, release rollback, recovery, security, cost and platform product judgment in one disposable local system.",
  "domain":"capstone-engineering",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0088"],
  "prerequisiteCurriculumIds":["IAC-001","K8S-001","K8S-002","K8S-003","K8S-004","K8S-005","K8S-006","K8S-007","K8S-008","GITOPS-001","PLT-001","PLT-002","PLT-003","PLT-004","SRE-001","SEC-002"],
  "testedEnvironments":[
    {"platform":"Ubuntu","version":"24.04 WSL with Python 3.12.3","support":"required","notes":"Bash syntax, Python compilation, twelve tests and the guarded absent-to-absent verifier pass as a normal user."},
    {"platform":"Docker Desktop","version":"29.6.2 with Linux containers","support":"required","notes":"Runs the pinned kind nodes and builds the non-root workload; API and NodePort remain loopback-only."},
    {"platform":"Kubernetes in Docker","version":"kind v0.31.0 with Kubernetes v1.35.0","support":"required","notes":"Three nodes, native CEL admission, Pod Security, RBAC, quota, rollout, drift, rollback and namespaced reconstruction pass."},
    {"platform":"Production, cloud or organizational environment","version":"not present in the tested boundary","support":"unsupported","notes":"No cloud account, production endpoint, real credential, CNI enforcement proof, accepted SLO, in-place cluster upgrade, etcd restore, application-data restore or learner mastery is accessed or claimed."}
  ],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","kubernetes-engineer","cloud-engineer","infrastructure-engineer","production-engineer","security-engineer","technical-lead","staff-engineer","solutions-architect"],
  "learningObjectives":[
    "Trace developer intent through generation, Git identity, reconciliation, API access, admission, controllers, scheduling, readiness and the user path.",
    "Distinguish namespace scope from identity, network, compute, storage, secret and control-plane isolation.",
    "Design a narrow versioned golden path that fails closed, exposes ownership and supports governed exceptions.",
    "Prove RBAC, CEL, Pod Security and quota with independent allow and deny evidence.",
    "Explain the four OpenGitOps principles and identify the limits of a small local reconciler.",
    "Diagnose competing field managers and restore committed desired state without hiding ownership.",
    "Run a bounded failed rollout, choose rollback safely and verify the user operation.",
    "Define platform, deployment and service SLIs and interpret a bounded error budget without claiming production capacity.",
    "Separate Git reconstruction, control-plane recovery, application-data restore and cluster replacement.",
    "Defend platform product, security, reliability, upgrade, capacity, cost and developer-experience trade-offs truthfully."
  ],
  "productionSignals":[
    "A portal reports success while the generated object was never admitted.",
    "A developer has namespace write access but admission rejects missing ownership or security controls.",
    "Pods are Pending while cluster CPU averages look low because requests cannot fit available nodes.",
    "A namespace is described as secure tenancy without proven RBAC, network, storage or secret boundaries.",
    "A manual replica change keeps returning because another field manager owns desired state.",
    "The reconciler is green but reads a mutable branch or unprotected source.",
    "A bad image rollout stalls while the previous ReplicaSet remains available.",
    "Policy objects exist but unsafe server-side dry-run requests are accepted.",
    "A quota denial is treated as application failure or solved by deleting unrelated workloads.",
    "Green Pods are used as proof that the user operation works.",
    "A kind cluster recreation is presented as an in-place production Kubernetes upgrade.",
    "Git reconstruction is presented as recovery for application data or etcd state."
  ],
  "diagrams":[
    {"id":"LES-0089-DIA-001","title":"Developer intent to user operation","direction":"left-to-right","boundaries":["ServiceRequest","generator","Git commit","reconciler","API server","controllers","nodes","Service path"],"evidencePoints":["contract result","generated diff","commit and hash","diff/apply receipt","authorization and admission","rollout state","Pod readiness","user response"],"textAlternative":"Developer intent becomes generated state, a Git revision and reconciled API objects before controllers, nodes and the Service path can serve a user request."},
    {"id":"LES-0089-DIA-002","title":"Kubernetes API decision path","direction":"left-to-right","boundaries":["transport","authentication","authorization","mutation/defaulting","validation","quota","storage"],"evidencePoints":["TLS/API reachability","user identity","RBAC reason","effective object","policy message","used versus hard","resource version"],"textAlternative":"An API request is authenticated, authorized, defaulted or mutated, validated, checked against quota and only then persisted."},
    {"id":"LES-0089-DIA-003","title":"Tenant defense in depth","direction":"hierarchical","boundaries":["organization identity","namespace RBAC","admission and Pod posture","network","compute quota","storage and secrets","node/control-plane"],"evidencePoints":["short-lived principal","allow/deny tests","negative fixtures","packet tests","usage and denial","encryption/access","audit and saturation"],"textAlternative":"Tenant isolation is layered across identity, RBAC, admission, network, compute, storage, secrets, nodes and the control plane; namespaces provide scope but not every layer."},
    {"id":"LES-0089-DIA-004","title":"Reconciliation and field ownership","direction":"cyclic","boundaries":["committed desired state","resolved revision","server-side diff","field manager","actual state","receipt"],"evidencePoints":["Git history","full commit","drift","managed fields/conflict","resource state","source hash and outcome"],"textAlternative":"A reconciler repeatedly resolves committed desired state, observes drift, acts as a declared field manager and records the result; competing writers create visible conflict."},
    {"id":"LES-0089-DIA-005","title":"Release and rollback","direction":"left-to-right","boundaries":["current ReplicaSet","new Pod template","surge candidate","readiness gate","promotion or rollback","user validation"],"evidencePoints":["available baseline","image/config identity","candidate events","probe result","revision decision","external operation"],"textAlternative":"The existing ReplicaSet remains while a bounded candidate attempts readiness; evidence chooses promotion, rollback or roll forward before user validation."},
    {"id":"LES-0089-DIA-006","title":"Recovery state classes","direction":"hierarchical","boundaries":["Git declarations","Kubernetes API state","application durable data","external resources","artifacts and identity"],"evidencePoints":["commit reconciliation","etcd snapshot/restore","database or volume recovery","provider reconciliation","registry, signatures and keys"],"textAlternative":"Git, etcd, application backups, external inventories and artifact stores protect different state and require different recovery evidence."}
  ],
  "commands":[
    {"id":"LES-0089-CMD-001","question":"Does the complete platform lifecycle pass and clean itself?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"support/project as a normal Ubuntu user with no atlas-platform cluster","expectedBranches":[{"when":"verify=pass and cleanup=pass","meaning":"the declared tests, cluster, policy, workload, faults, SLO arithmetic, reconstruction and exact cleanup passed","nextEvidence":"read individual receipts and proof limits"},{"when":"the first stage fails","meaning":"the candidate is rejected at that boundary","nextEvidence":"preserve the first error; cleanup trap removes named runtime resources"}],"proves":"the recorded absent-to-absent local lifecycle","doesNotProve":"production readiness, CNI policy enforcement, in-place upgrade, data restore or learner mastery","cleanup":"Verifier deletes the named cluster, project state and workload image while retaining verified tool/node caches."},
    {"id":"LES-0089-CMD-002","question":"Is the kind binary the reviewed artifact?","risk":"mutating-bounded","command":"bash tools/install-kind.sh","runFrom":"support/project as a normal x86_64 Ubuntu user","expectedBranches":[{"when":"checksum=pass","meaning":"the project-local v0.31.0 binary matches the locked SHA-256","nextEvidence":"inspect version and node image pairing"},{"when":"TLS, download or checksum fails","meaning":"the tool is unavailable or untrusted","nextEvidence":"stop; do not execute or bypass verification"}],"proves":"one binary checksum and version","doesNotProve":"the binary is vulnerability-free or appropriate forever","cleanup":"A verified binary remains only under project .tools; remove that exact file separately if cache retention is unwanted."},
    {"id":"LES-0089-CMD-003","question":"Can the loopback-only three-node cluster reach Ready?","risk":"mutating-bounded","command":"bash cluster/create.sh","runFrom":"support/project after verified kind installation and Docker availability","expectedBranches":[{"when":"three nodes are Ready at v1.35.0","meaning":"the pinned local control plane and workers bootstrapped","nextEvidence":"inspect API readiness and component ownership"},{"when":"image, node or wait fails","meaning":"cluster bootstrap is incomplete","nextEvidence":"export kind logs and run exact cleanup before retry"}],"proves":"one local kind cluster and node readiness","doesNotProve":"HA, failure-domain independence or production capacity","cleanup":"Run bash cluster/cleanup.sh and prove cluster/state absence."},
    {"id":"LES-0089-CMD-004","question":"Do platform controls apply and make the intended RBAC decisions?","risk":"mutating-bounded","command":"bash platform/bootstrap.sh","runFrom":"support/project with the project kubeconfig created","expectedBranches":[{"when":"bootstrap-pass and RBAC yes/no/no","meaning":"base resources applied and three scoped decisions match policy","nextEvidence":"run independent admission denials"},{"when":"apply or decision fails","meaning":"policy shape or authorization contract differs","nextEvidence":"inspect the first API status and exact Role/Binding"}],"proves":"declared base and three authorization decisions","doesNotProve":"network, storage, node or every tenant isolation path","cleanup":"Deleting the disposable cluster removes these resources."},
    {"id":"LES-0089-CMD-005","question":"Does developer intent satisfy the narrow platform API?","risk":"read-only","command":"python3 platformctl.py check --request requests/payments-api.json","runFrom":"support/project","expectedBranches":[{"when":"request=valid","meaning":"all required fields and local invariants pass","nextEvidence":"generate and review desired state"},{"when":"request=rejected","meaning":"input is malformed or unsupported","nextEvidence":"correct the named source field; do not patch live YAML"}],"proves":"local contract validation for this request","doesNotProve":"Kubernetes API acceptance or runtime success"},
    {"id":"LES-0089-CMD-006","question":"Are committed outputs deterministic from the request?","risk":"mutating-bounded","command":"python3 platformctl.py generate --request requests/payments-api.json --output /tmp/payments-api.yaml --catalog-output /tmp/payments-api.json","runFrom":"support/project after creating a private temporary directory","expectedBranches":[{"when":"generated=pass and cmp matches committed files","meaning":"request and generator reproduce desired/catalog state","nextEvidence":"review Git diff and commit identity"},{"when":"output differs","meaning":"request, generator or committed output drifted","nextEvidence":"review semantic changes; never overwrite blindly"}],"proves":"deterministic generated bytes for current inputs","doesNotProve":"policy acceptance, rollout or portal usability","cleanup":"Remove only the two named temporary files and verified empty temporary directory."},
    {"id":"LES-0089-CMD-007","question":"Can the non-root workload image build and enter every node?","risk":"mutating-bounded","command":"bash workload/build-load.sh","runFrom":"support/project after cluster creation","expectedBranches":[{"when":"build-load-pass and user=10001:10001","meaning":"Docker checks pass and the local tag is loaded on all kind nodes","nextEvidence":"reconcile the committed Deployment"},{"when":"build or load fails","meaning":"image input, Docker or node import failed","nextEvidence":"preserve the first build/load error"}],"proves":"one local image build and kind-node import","doesNotProve":"signature, vulnerability policy, registry behavior or runtime readiness","cleanup":"Cluster cleanup removes nodes and the exact project image tag."},
    {"id":"LES-0089-CMD-008","question":"Does one immutable Git revision reconcile to the API?","risk":"mutating-bounded","command":"python3 ops/reconcile.py --source drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/team-a/payments-api.yaml --revision HEAD","runFrom":"support/project after the desired file is committed and platform controls exist","expectedBranches":[{"when":"reconcile=pass with full commit, drift and SHA","meaning":"committed content was diffed/applied and receipt recorded","nextEvidence":"wait for rollout and user operation"},{"when":"source, diff, conflict or admission fails","meaning":"identity, ownership or API contract rejected reconciliation","nextEvidence":"inspect commit/path and first server status"}],"proves":"bounded Git-bound server-side reconciliation","doesNotProve":"remote pull, continuous controller HA, prune safety or Flux equivalence","cleanup":"Deleting the disposable cluster and .state removes applied runtime and receipt."},
    {"id":"LES-0089-CMD-009","question":"Did the committed release become user-visible?","risk":"read-only","command":"kubectl --kubeconfig .state/kubeconfig rollout status deployment/payments-api -n team-a --timeout=120s && curl -fsS http://127.0.0.1:18080/version","runFrom":"support/project after reconciliation","expectedBranches":[{"when":"rollout succeeds and version is 1.0.0","meaning":"Deployment availability and one external read path pass","nextEvidence":"measure a bounded window and correctness"},{"when":"rollout or curl fails","meaning":"controller readiness or data path is incomplete","nextEvidence":"trace ReplicaSet, Pod, events, EndpointSlice and handler"}],"proves":"one rollout and loopback user operation","doesNotProve":"all operations, long-window availability or production ingress"},
    {"id":"LES-0089-CMD-010","question":"Do three independent unsafe requests fail for the intended reason?","risk":"mutating-bounded","command":"bash ops/verify-denials.sh","runFrom":"support/project with platform controls active","expectedBranches":[{"when":"three denial=pass receipts appear","meaning":"CEL owner, Pod Security and quota independently reject server dry-runs","nextEvidence":"inspect allowed safe path separately"},{"when":"accepted or wrong message","meaning":"the control is ineffective or a different boundary failed","nextEvidence":"stop promotion and inspect binding, namespace labels or quota"}],"proves":"three mechanism-specific server denials with no created resources","doesNotProve":"all bypasses, network policy enforcement or runtime containment","cleanup":"Server dry-run creates no persisted fixture."},
    {"id":"LES-0089-CMD-011","question":"Can the platform correct drift and recover a bad release?","risk":"mutating-bounded","command":"bash ops/verify-drift.sh && bash ops/verify-rollback.sh","runFrom":"support/project with payments-api healthy at two replicas","expectedBranches":[{"when":"drift and rollback tests pass","meaning":"replica drift returns to Git and an unavailable image returns to 1.0.0 with user probe","nextEvidence":"inspect managed fields and compatibility boundary"},{"when":"either fails","meaning":"ownership or rollback safety is lost","nextEvidence":"recovery traps restore baseline; inspect first conflict/event"}],"proves":"two bounded recovery behaviors","doesNotProve":"stateful rollback, cluster rollback or arbitrary field ownership","cleanup":"Both scripts restore the known workload baseline or run recovery traps."},
    {"id":"LES-0089-CMD-012","question":"Can namespaced declarations reconstruct after loss?","risk":"mutating-bounded","command":"bash ops/verify-reconstruction.sh","runFrom":"support/project with a healthy disposable team-a workload","expectedBranches":[{"when":"reconstruction=pass and data_restore=not-exercised","meaning":"namespace, controls and committed workload return and user probe converges","nextEvidence":"design separate etcd and application-data restore tests"},{"when":"delete, reconcile, rollout or probe fails","meaning":"declarative recovery is incomplete","nextEvidence":"recovery trap reapplies state; preserve first failed boundary"}],"proves":"namespaced desired-state reconstruction in one cluster","doesNotProve":"etcd, volume, database, external resource or production disaster recovery","cleanup":"Final cluster cleanup removes all reconstructed runtime resources."}
  ],
  "labs":[
    {"id":"LES-0089-LAB-001","title":"Guided local platform build, policy, release and recovery lifecycle","mode":"guided","environment":"Ubuntu 24.04 WSL, Docker Desktop 29.6.2, kubectl and project-local kind v0.31.0/Kubernetes v1.35.0","timeMinutes":240,"privilege":"normal user; no sudo, cloud, production endpoint or real credential","network":"loopback Kubernetes API and NodePort; external access only for missing locked tools/images","changes":["project-local verified kind binary and cache","three named kind node containers","project kubeconfig and evidence","tenant/policy/workload resources","project workload image"],"abortConditions":["root execution","pre-existing atlas-platform cluster","non-loopback API or port","default cloud context","checksum mismatch","credential or real data","unknown cleanup target","failed recovery invariant"],"recovery":"Stop at the first failed boundary; traps delete only the named cluster/state/image, while manual investigation preserves logs before exact cleanup.","cleanupProof":"Verifier reports cluster, state and workload image absent; verified kind binary and node-image cache remain intentionally.","path":"drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project"},
    {"id":"LES-0089-LAB-002","title":"Independent reviewer-owned platform product and hidden-fault defense","mode":"independent","environment":"Fresh clone, reviewer-selected second service/tenant requirement and two hidden faults","timeMinutes":240,"privilege":"normal user plus independent reviewer; no answer key, elevated host authority, cloud credential or production target","network":"loopback and named project Docker network only after pinned artifacts are present","changes":["new versioned request and generated state","reviewer-selected policy or control-loop faults","bounded release and recovery evidence","product/readiness/incident artifacts"],"abortConditions":["guided answer reuse","default or production context","broad admin grant","policy disabled without reviewed break-glass","unbounded load","secret exposure","unsafe restore","unproven cleanup","mastery or production claim"],"recovery":"Reviewer stops unsafe work; learner preserves evidence, restores the last known committed local state and validates the user operation before continuing.","cleanupProof":"Reviewer verifies exact cluster/state/image absence and signs that no credential, real data, external mutation or answer key remains.","path":"drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project"}
  ],
  "incidents":[
    {"id":"LES-0089-INC-001","signal":"Authorized team-a Deployment is rejected for missing owner.","firstThought":"The request passed RBAC and failed admission; this is not general cluster unavailability.","safePath":"Preserve status, correct the versioned request, regenerate, commit, reconcile and validate rollout plus user path.","trap":"Grant cluster-admin or disable policy."},
    {"id":"LES-0089-INC-002","signal":"Pods remain Pending while dashboard CPU is low.","firstThought":"Aggregate utilization can be low while requests do not fit due to fragmentation, quota, taints or topology.","safePath":"Read scheduler events, requests, node allocatable, quota, taints and topology before changing capacity.","trap":"Remove requests or add replicas blindly."},
    {"id":"LES-0089-INC-003","signal":"A manual scale to one replica returns to two.","firstThought":"A reconciler owns replicas; this is expected drift correction or a competing-controller conflict.","safePath":"Inspect managed fields and Git receipt, choose one owner, then change desired state at its source.","trap":"Repeatedly scale or force conflicts without ownership."},
    {"id":"LES-0089-INC-004","signal":"New ReplicaSet cannot pull its image while the old version serves.","firstThought":"The candidate artifact is unavailable; the rolling strategy is containing impact.","safePath":"Freeze change, inspect image identity/event, choose compatible rollback or corrected roll forward, then verify the user operation.","trap":"Delete the old ReplicaSet or every Pod."},
    {"id":"LES-0089-INC-005","signal":"Deployment is Available but first NodePort probe resets after namespace reconstruction.","firstThought":"Controller readiness and the exact data path can converge at different times.","safePath":"Use bounded read-only probes with deadlines, inspect EndpointSlices and fail after a declared window.","trap":"Remove the user check or retry non-idempotent writes blindly."},
    {"id":"LES-0089-INC-006","signal":"Team namespace is deleted and Git declarations are intact.","firstThought":"Git can reconstruct declared objects but not application data, etcd-only state or external resources.","safePath":"Reapply tenant controls, reconcile fixed revision, wait for rollout and user path; invoke separate data/control-plane recovery if required.","trap":"Call Git a complete backup or restore unknown data in place."}
  ],
  "assessmentIds":["ASM-0250","ASM-0251","ASM-0252"],
  "referenceIds":["REF-1120","REF-1121","REF-1122","REF-1123","REF-1124","REF-1125","REF-1126","REF-1127","REF-1128","REF-1129","REF-1130","REF-1131","REF-1132","REF-1133","REF-1134","REF-1135","REF-1136","REF-1137","REF-1138","REF-1139"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "Three kind nodes share one laptop kernel, Docker daemon, disk, power and failure domain; they do not prove zone or control-plane high availability.",
    "Kubernetes v1.35.0 is paired with kind v0.31.0 but is not the current 1.35 patch on the review date; reproduction and patch currency are separate duties.",
    "The default kind CNI provides connectivity, but this project does not prove NetworkPolicy enforcement with negative packet tests.",
    "The small reconciler reads committed local Git and corrects drift; it is not a remote, in-cluster, highly available Flux or Argo CD controller.",
    "The local workload tag is tied to a build receipt and loaded into nodes but is not signed, registry-promoted or admitted by digest/provenance.",
    "The 100-request window and local reconstruction times are regression evidence only, not production capacity, SLO, RPO or RTO.",
    "No etcd snapshot restore, CSI/volume recovery, database recovery, secret delivery, external DNS/load balancer reconciliation or in-place cluster upgrade is performed.",
    "The user-test file is a protocol; no independent participant result, formal review, delayed recall, publication or mastery evidence is claimed."
  ]
}
---

# Kubernetes platform engineering capstone: build a safe local developer platform

## What you see and first thought

You open a ticket that says, “Deployment blocked; platform is down.” The nodes are Ready. The existing service answers HTTP 200. The developer is allowed to create Deployments in their namespace. The API still rejects the new object. Someone proposes cluster-admin. Someone else proposes disabling policy “just for the incident.”

Pause and translate the noise into one sentence:

> One identity attempted one API operation on one object in one namespace, and a named control rejected it before persistence.

That sentence protects you from the most common platform mistake: treating every failure as a cluster failure. A platform is a chain of control and data paths. The earliest failed boundary owns the next question.

Use this memory path:

```text
request rejected before Git     -> platform API or request contract
Git revision cannot be read     -> source/reconciler boundary
API says unauthorized           -> authentication
API says forbidden              -> authorization/RBAC
API names policy or quota       -> admission
object exists, Pod Pending      -> scheduler/capacity/topology
Pod Running, not Ready          -> workload or dependency readiness
endpoints exist, user fails     -> Service/network/handler path
manual change keeps returning   -> controller ownership/reconciliation
```

Whenever you see “Kubernetes is broken,” ask: **which operation, which owner, which evidence, which scope?** Ready nodes prove kubelets recently reported health. They do not prove admission, scheduling capacity, DNS, a Service selector or a payment operation. A green portal proves even less about the data path.

This capstone builds one local platform so those boundaries become visible. You will create a typed service request, deterministic manifests, tenant controls, a committed-state reconciler, a secure workload and bounded failures. The goal is not memorizing `kubectl`. The goal is learning where truth lives and choosing the smallest reversible action.

## Terms before commands

**Platform** means a supported product that reduces repeated developer work through stable interfaces, automation and guardrails. It is not synonymous with a cluster, portal or operations team.

**Control plane** is the path that receives intent and drives state toward it. Kubernetes API server, etcd, scheduler and controllers are control-plane components. The local generator and reconciler are also control-plane-like platform components.

**Data plane** is where the application request runs: NodePort, Service, EndpointSlice, Pod network and process. A healthy control plane can manage an unhealthy service; a healthy service can briefly survive a broken platform control surface.

**Desired state** says what should exist. **Actual state** is what exists now. **Reconciliation** repeatedly compares them and acts toward desired state.

**Golden path** is the easiest supported route for a common job. It supplies safe defaults and useful feedback. It is not a prison; unsupported needs require a visible exception or extension contract.

**Tenant** is a team or workload group sharing infrastructure under isolation policy. A **namespace** provides naming and authorization scope. It does not by itself isolate network, node kernel, storage backend, secrets or control-plane capacity.

**Authentication** answers “who are you?” **Authorization** answers “may that identity perform this verb on this resource in this scope?” **Admission** evaluates or changes an authorized request before persistence. **Quota** is an admission-time aggregate budget.

**Pod Security Admission** applies the Pod Security Standards through namespace labels. A **ValidatingAdmissionPolicy** runs CEL expressions inside the API server. A policy definition does nothing until a binding selects requests and an actual negative test proves rejection.

**Request** is the scheduler’s capacity promise and relative CPU share. **Limit** is a runtime ceiling. Quota totals declarations; it does not measure real performance.

**Field manager** records who last managed fields through server-side apply or subresources. Two managers changing the same field create a conflict or control-loop fight.

**GitOps** requires declarative state, versioned immutable history, automatic pull and continuous reconciliation. A repository plus a CI `kubectl apply` step satisfies only part of that definition.

**Rollback** returns executable/configuration state to a compatible earlier version. **Restore** reconstructs data or control-plane state. **Reconstruction** recreates declarations from source. These actions solve different losses.

## Architecture map

Think of the platform as three connected products.

The **developer interface** begins at `requests/payments-api.json`. It deliberately asks for fewer concepts than Kubernetes: service identity, tenant, owner, image, replicas, port, resource quantities and local exposure. `platformctl.py` validates every field, rejects unknowns and produces two artifacts. The Kubernetes manifest is executable desired state. The catalog record is discovery state: who owns this service, where its runbook lives, what lifecycle it has and which local objective it uses.

The **platform control plane** begins with a Git revision. `ops/reconcile.py` does not trust the working-tree file. It resolves `HEAD` to a full forty-character commit and reads the allowlisted path through `git show`. It calculates a SHA-256, asks Kubernetes for a server-side diff and applies with the field manager `atlas-reconciler`. Its receipt joins source identity to the attempted cluster state.

The **Kubernetes control plane** then owns a different sequence:

```text
client TLS request
  -> API server authentication
  -> RBAC authorization
  -> defaulting / mutation
  -> CEL, Pod Security and other validation
  -> ResourceQuota admission
  -> etcd persistence
  -> Deployment controller creates ReplicaSet
  -> scheduler binds Pod to node
  -> kubelet asks containerd to run image
  -> readiness creates usable EndpointSlice membership
```

Do not compress that diagram into “apply YAML.” Every arrow has a different owner and different evidence. A 403 is not a scheduler problem. A Pending Pod proves the object was already admitted and stored. An empty EndpointSlice is not fixed by changing RBAC. This dependency order saves time because it prevents you debugging a later stage that never received the object.

Finally, the **service data path** enters through `127.0.0.1:18080`. kind maps the host loopback port into the control-plane node container. Kubernetes NodePort handling selects the Service. The Service selector finds Pods through EndpointSlices. The request crosses the Pod network and reaches the Python handler. The successful `/version` output contains 1.0.0.

Why two workers? They make placement visible. The two ready Pods landed on different workers with different synthetic zone labels. That proves the topology-spread preference under that run. It does not prove failure-domain independence: both workers are Docker containers on one host.

Why one control-plane node? A local single control plane keeps the lab bounded. It also forces honest language. If that container fails, this cluster loses API availability. Production design must decide whether the provider or operator supplies multiple control-plane members, etcd quorum, endpoint failover, backups and tested recovery.

The security map is layered. The project kubeconfig keeps local authority separate from a default context. RBAC limits what a tenant identity can ask. CEL validates owner, service labels, replicas, image tag, resources and security context. Restricted Pod Security adds a broader Pod posture. Quota limits declared aggregate use. The generated security context runs as non-root, prevents privilege escalation, makes root read-only, drops capabilities and applies RuntimeDefault seccomp. Each layer covers a different question.

The architecture’s most important interface is not a REST endpoint. It is the **ownership boundary**. The request owns user intent. The generator owns repetitive manifest fields. Git owns version history. The reconciler owns generated server-side fields. Kubernetes controllers own derived objects. Application teams own handler correctness and declared resource needs. Platform teams own safe defaults, policy, upgrade and support. When two owners silently manage the same field, the architecture is already in conflict.

## Request or state path

Follow one change: the payments team wants two replicas of image `atlas-platform-demo:1.0.0`.

First, JSON crosses the platform API boundary. The validator checks root fields exactly. If a caller adds `privileged`, validation rejects it as unknown. This is more important than it looks. A permissive parser that silently discards unknown safety-related input creates a false mental model: the developer thinks they requested one system while the platform created another.

The contract allows only `team-a` and `team-b`. This is not because two strings are an enterprise tenancy model. It creates a visible trust boundary for the exercise. A request for `kube-system` fails before Kubernetes, so developer intent cannot select a control-plane namespace.

The generator then produces a ServiceAccount, Deployment, Service, NetworkPolicy and—when replicas exceed one—PodDisruptionBudget. It also produces catalog metadata. The Deployment carries two kinds of labels:

- application labels drive selectors and operational discovery;
- platform labels drive ownership and policy.

Confusing them can break either traffic or governance. Changing a selector label can orphan Pods. Missing an ownership label can make an otherwise valid object unacceptable.

The generated Deployment sets `maxUnavailable: 0` and `maxSurge: 1`. During a normal two-replica update, Kubernetes may create one extra candidate and should not intentionally remove an available old Pod before replacement readiness. This reduces rollout risk but requires surge capacity. If workers have no spare requested CPU or memory, the safer strategy can stall. Reliability settings always consume capacity somewhere.

The file is committed. That moment converts mutable working intent into a versioned identity. The reconciler’s source path is restricted under this capstone’s `desired/` directory and traversal is rejected. `git show COMMIT:path` returns the content. The SHA receipt protects against a misleading claim such as “we deployed c2f456b” when a different file was read from disk.

At the API server, identity and admission separate cleanly. The tested developer ServiceAccount can create Deployments in team-a. It cannot read Secrets there and cannot create Deployments in team-b. Those are three decisions, not a general statement that “RBAC works.”

The CEL policy sees authorized tenant Deployments. It requires ownership and service labels, no more than five replicas, no `latest` image, CPU/memory requests and limits, and the declared security controls. Restricted Pod Security evaluates the resulting Pod template when Pods are created. ResourceQuota compares aggregate requested resources with hard tenant limits. A workload may pass CEL yet fail quota; that is defense in depth, not inconsistent policy.

After persistence, the Deployment controller creates a ReplicaSet. The scheduler sees each Pod’s requests, node allocatable capacity, taints, selectors, affinity and topology rules. A LimitRange may default resources on objects that omit them, but the CEL contract refuses omission for Deployments. This redundancy is intentional: defaults protect raw objects while the golden path makes resource intent explicit.

The kubelet runs the already-loaded image because `imagePullPolicy: Never` prevents a registry lookup. That is a local reproducibility choice, not a production promotion model. Production should promote immutable registry identities and authorize them with provenance/signature policy.

Readiness eventually adds Pod IPs to an EndpointSlice. Only then should the Service send traffic. During namespace reconstruction, Deployment rollout reported success just before the first host NodePort request reset. The next bounded probe succeeded. That observation teaches a mature rule: controller conditions and your exact user path can converge at slightly different times. Validate both, and make retries safe, finite and operation-aware.

State exists in different places throughout this path:

- request JSON and generator code in Git;
- generated declaration and catalog record in Git;
- desired Kubernetes objects in etcd;
- derived ReplicaSets, Pods and EndpointSlices in etcd;
- image layers inside Docker/kind node containerd;
- in-memory request counters inside the Pod;
- receipts under project `.state`.

Deleting a namespace removes several categories but not Git or cached images. Reconciliation can reconstruct declared objects. It cannot reconstruct in-memory metrics or a database that was never backed up. Always name the state you are recovering.

## Failure zoom

### Failure 1: “I am allowed, so why was I denied?”

The unsafe Deployment reaches authorization successfully. Then CEL rejects it because the owner label is absent. The HTTP status and message are valuable: they identify the policy and violated contract.

Do not confuse this with a paradox. RBAC and admission answer different questions:

```text
RBAC: may this identity create a Deployment in team-a? yes
CEL: does this authorized Deployment satisfy the workload contract? no
result: no object is persisted
```

Granting cluster-admin changes the first answer from yes to a broader yes. It does not make the object safe and may not bypass admission at all. Disabling admission fixes the symptom by removing the guardrail—the equivalent of removing a smoke detector because it is loud.

### Failure 2: privilege is denied independently

The privileged Pod does not match the Deployment-only CEL policy. Restricted Pod Security still rejects it. This is deliberate. A single policy engine should not be the only layer between a typo and host-level risk.

When debugging, read the exact rejection owner. “Policy denied it” is too vague. CEL, Pod Security, an external webhook and ResourceQuota have different configuration, availability and exception paths.

### Failure 3: individually valid, collectively too large

The over-quota Pod has non-root identity, seccomp, read-only root and resource declarations. Its three-CPU request exceeds team-a’s two-CPU aggregate request budget. ResourceQuota rejects it.

This is not a security-context failure and not proof that nodes lack three CPUs. Quota is an organizational fairness boundary. Node capacity is a scheduler boundary. Both might reject the same demand for different reasons.

### Failure 4: manual scale fights desired state

`kubectl scale` changes replicas from two to one and records its own field manager. The reconciler’s server-side diff initially failed with a field conflict. That first implementation failure taught more than a silent overwrite would: two actors claimed the same field.

The fixture now explicitly uses `--force-conflicts` in both diff and apply because the platform contract owns generated replicas. That choice is bounded and documented. In production, indiscriminate force can overwrite a human emergency change, HPA output or another controller. Decide whether Git, HPA, an operator or a human owns replicas. If ownership changes during an incident, record when and how it returns.

### Failure 5: bad image, healthy old service

The rollback fixture changes the image to a tag that does not exist inside kind. The candidate cannot start because `imagePullPolicy: Never` forbids an external pull. The old ReplicaSet keeps serving due to rolling settings and available capacity. Rollout status times out, then `rollout undo` restores the earlier template and `/version` verifies 1.0.0.

Do not delete the old ReplicaSet while investigating. It is your live rollback asset. Do not describe this as proof that every rollout is safe. A new database schema, irreversible job or destructive configuration can make the old executable incompatible.

### Failure 6: reconstruction and transient data-path reset

The exercise deletes team-a, recreates platform controls and reconciles the service. Kubernetes reports Deployment rollout success. The first NodePort probe once reset; the next succeeded. The verifier now retries only read-only `GET /version`, at most thirty times, with a two-second request deadline and one-second interval.

This is not “retry until green.” The retry is bounded, operation-safe and records attempt count. A POST that might have committed cannot be treated the same way. For writes, use an idempotency identity and reconcile outcome before retry.

The recovery receipt says `data_restore=not-exercised`. That phrase prevents a dangerous portfolio claim. Recreating YAML is infrastructure reconstruction. It is not database recovery, etcd restore or regional disaster recovery.

## Internals and state ownership

### API server: gate and serialization boundary

The API server is not a passive YAML database. It authenticates, authorizes, defaults, validates, admits and serializes versioned resources. Clients usually send JSON over HTTPS; YAML is a client representation. Server-side dry-run executes much of the admission path without persistence, which is why the three negative fixtures are stronger than a local linter.

ResourceVersion is an optimistic-concurrency identity for an object’s stored state. ManagedFields record managers and operations. Neither replaces Git history. Git explains intended declarations and review. The API explains effective stored state after defaulting and mutation.

### etcd: control-plane state, not application backup

etcd stores Kubernetes API objects. If etcd is lost, Deployments, Secrets, CRDs, RBAC and many dynamic objects may be lost even when Git contains some declarations. An etcd snapshot/restore must consider membership, revision changes, watcher behavior, encryption configuration and component compatibility. Restoring etcd does not restore bytes in a database volume or external queue.

This lab avoids an etcd restore because a meaningful exercise needs snapshot tooling, controlled control-plane failure, compatible restore and post-restore reconciliation. The book gives the design boundary without fabricating execution evidence.

### Controllers: derived state owners

The Deployment controller does not run containers. It creates and scales ReplicaSets. ReplicaSets create Pods. Service controllers and endpoint controllers maintain related state. Each controller is an eventually consistent loop. Conditions are observations, not atomic promises that every downstream data path updated simultaneously.

Finalizers block deletion until a controller completes cleanup. If namespace deletion hangs, deleting finalizers blindly can leak external resources or violate cleanup. Identify the responsible controller and external effect first.

### Scheduler: declared demand and fit

The scheduler works from Pod requests, constraints and current cluster state. It does not benchmark the application. A 50m CPU request means 0.05 CPU for scheduling/share purposes, not “this service needs exactly five percent.” If a team under-requests, Pods fit but compete and throttle under load. If it over-requests, safe capacity sits unused and scheduling may fail despite low real utilization.

Topology spread with `ScheduleAnyway` is a preference under skew constraints, not an availability guarantee. In the verified run, Pods landed on two labeled workers. If one worker were unavailable and the other had capacity, scheduling could converge differently.

### Kubelet and container runtime

The kubelet watches assigned Pods, asks containerd to prepare images and containers, executes probes and reports status. `imagePullPolicy: Never` means “use a matching local image or fail.” That makes the lab deterministic after `kind load`. It is unsuitable for fleet promotion unless an image distribution process guarantees presence.

Container UID 10001, read-only root, dropped capabilities and seccomp reduce privilege. They do not create a separate kernel or protect against a compromised host/Docker daemon. kind nodes themselves are privileged containers.

### Service and EndpointSlice

A Service selector is a query over Pod labels. EndpointSlices hold selected addresses and readiness. A ClusterIP or NodePort can exist with no endpoints. Therefore inspect:

```text
Service selector
  -> matching Pod labels
  -> EndpointSlice addresses/readiness
  -> node dataplane rules
  -> Pod listener and handler
```

NetworkPolicy is separate. Kubernetes defines the object, but a compatible CNI must enforce it. This fixture renders a policy and states the intended flow, yet does not run a negative packet test against an enforcing CNI. An object accepted by the API is declaration evidence, not enforcement evidence.

### Platform state and product state

The request schema is a public interface even inside one company. Version it. The generator is a compiler: deterministic output, validation and migration matter. The catalog is operational product state; stale owner/runbook data increases incident time.

The platform team owns the contract and generated controls. Application teams own accurate resource needs, service behavior and business recovery. Security owns policy objectives with platform implementation partnership. SRE owns or reviews objectives and incident systems. Shared ownership without a decision owner becomes no ownership.

## Evidence table

Use evidence as a scoped sentence: **signal → proves → does not prove → next evidence**.

| Signal | What it proves | What it does not prove | Next evidence |
|---|---|---|---|
| kind binary SHA matches lock | Those bytes match the recorded artifact | Project safety or future currency | Version, source review, isolated execution |
| Three nodes show Ready | Kubelets reported Ready for this cluster | HA, spare capacity or workloads | API readyz, node allocatable, failures |
| API `/readyz` succeeds | This control-plane endpoint is ready now | Every controller/add-on or service | Component status and workload path |
| `auth can-i` says yes | One identity/verb/resource/scope is authorized | Admission or runtime success | Server dry-run/apply |
| `auth can-i` says no for Secrets | That exact read is denied | Secrets cannot leak another way | Broader RBAC/escalation and audit review |
| CEL owner denial | That validation rejected that request | Other expressions or runtime safety | Independent negative fixtures |
| Pod Security denial | Namespace Pod posture rejected privilege | Node hardening or webhook health | Runtime and host evidence |
| Quota denial | Aggregate declared request exceeds policy | Node is physically full | Quota usage, requests, allocatable |
| Deployment object exists | API admitted and stored desired state | Pod creation or readiness | ReplicaSet, Pods, events |
| Pod Pending | Accepted Pod has not bound/run | Root cause without event | Scheduler event, requests, taints |
| Pod Running | Container process is running | Ready or correct | Probe, logs, user operation |
| Pod Ready | Kubelet probe currently succeeds | Entire Service path or SLO | EndpointSlice and external probe |
| EndpointSlice has ready IPs | Service has selected ready endpoints | NodePort/ingress or handler correctness | In-cluster and external requests |
| `/version` returns 1.0.0 | One external read path reached expected handler | Writes, authorization or time-window health | Representative operations and probes |
| Git full commit + content SHA | Reconciler read identified desired bytes | Commit trust/signature or cluster convergence | Protected source and apply receipt |
| Server-side diff reports drift | Actual/effective state differs in managed fields | Why or which writer without details | ManagedFields and events |
| Reconcile restores replicas | Declared owner corrected that bounded field | Every field or controller safety | Ownership matrix and repeated observation |
| Rollout undo restores probe | Prior stateless template is viable now | Stateful/schema rollback | Compatibility and data tests |
| 100/100 probes, p95 12.881 ms | One bounded local window met declared thresholds | Production capacity/SLO | Representative sustained/failure load |
| Namespace reconstruction passes | Declared tenant/workload state can return locally | etcd or application-data recovery | Snapshot/restore and business reconciliation |
| Cleanup says absent | Named runtime resources are gone | Shared cache vulnerability or host cleanliness | Exact cache/update policy |

Notice how many green signals still need a “does not prove” column. Senior engineering is not pessimism; it is precise confidence. You can act quickly because you know exactly how far each signal reaches.

Evidence also decays. The source-review date, Kubernetes patch level, image digest and policy version are recorded because a six-month-old pass does not prove current security or API compatibility. Schedule review rather than pretending immutable evidence is timeless.

During incidents, preserve the smallest packet that can reconstruct reasoning: user operation, time window, source/image/config identity, API status, event chain, managed fields, readiness, endpoints and external response. Collecting every log without a question increases search cost and can leak secrets.

## Command decoders

### `bash verify.sh`

`bash` explicitly selects the shell, so executable-bit differences on Windows-backed files do not matter. The script uses `set -euo pipefail`:

- `-e` stops on an unhandled nonzero command;
- `-u` stops on an unset variable;
- `-o pipefail` makes a pipeline fail when an earlier stage fails.

Those settings exposed a real nuance: `kubectl auth can-i` prints `no` and returns exit status 1. A pipeline that greps for `no` still fails under pipefail. The corrected bootstrap captures both text and status. This is why strict mode helps only when you understand command contracts.

The verifier refuses root and a pre-existing named cluster. It uses an EXIT trap for exact cleanup. A refusal is not failure to automate; it prevents the verifier from taking ownership of a cluster it did not create.

### `kind create cluster --image … --config … --kubeconfig … --wait 180s`

`--image` selects the node image by tag and digest. `--config` supplies loopback networking, three nodes, zone labels and port mapping. `--kubeconfig` writes credentials into project state instead of changing the default config. `--wait` bounds control-plane readiness.

Node Ready is printed after creation. If the wait fails, preserve kind logs before deletion. Increasing the timeout without evidence can turn an image, Docker-resource or kubeadm failure into wasted time.

### `kubectl apply --server-side --field-manager=atlas-platform -k platform/base`

`--server-side` asks the API server to merge fields and record ownership. `--field-manager` names the owner. `-k` renders the Kustomize directory rather than applying one file. Server-side apply can surface conflicts between managers; that visibility is useful.

The reconciler adds `--force-conflicts` because its contract declares ownership of generated fields. Treat force as a transfer of ownership, not a generic fix. Before using it elsewhere, inspect `metadata.managedFields` and decide which controller should win.

### `kubectl auth can-i VERB RESOURCE --as=IDENTITY -n NAMESPACE`

This sends a self-subject-style authorization review for the impersonated identity. `--as` requires the caller to have impersonation privilege; the local admin kubeconfig does. `-n` sets the namespace. Always include verb, resource and scope in your conclusion. “The user has access” is too broad.

### `kubectl apply --dry-run=server -f failures/unsafe-deployment.yaml`

`--dry-run=server` sends the object through API validation, defaulting and admission but requests no persistence. That makes it suitable for negative policy evidence. It still contacts and can load the API/control plane, so “dry-run” does not mean “offline” or “zero impact.”

`--dry-run=client` was attempted without a cluster. `kubectl apply` still needed API discovery and failed at localhost:8080. Kustomize rendering and Python generator tests are offline gates; definitive Kubernetes schema/admission validation belongs to a server.

### `kubectl rollout status deployment/payments-api -n team-a --timeout=120s`

This watches the Deployment controller’s rollout condition until success or a two-minute bound. It does not make an HTTP request to your user operation. Follow it with the external probe. `rollout undo` restores a prior Pod template revision; inspect history and compatibility before using it.

### `kubectl get events --sort-by=.metadata.creationTimestamp`

Sorting by creation time helps reconstruct the controller sequence. Events are best-effort and retained for a limited time; absence does not prove an event never happened. Capture them early, then correlate with object conditions, logs and audit evidence.

### `kubectl get … -o jsonpath='{.spec.replicas}'`

`-o jsonpath` extracts a field for assertions. Empty output can mean missing field, wrong path, wrong object or command failure. Do not use a blank string as proof without checking exit status and object identity.

### `curl -fsS --max-time 2 http://127.0.0.1:18080/version`

`-f` makes HTTP 4xx/5xx return nonzero. `-sS` hides progress but prints errors. `--max-time 2` bounds the entire request. The loopback address prevents external traffic. This GET is safe to retry in the bounded reconstruction loop. A write would require different semantics.

### `python3 ops/measure_slo.py probe --requests 100 --concurrency 5 …`

The tool caps requests at 500 and concurrency at 20, validates an HTTP loopback URL and writes JSON Lines atomically. Concurrency five means up to five worker threads, not five requests per second. The tool measures the laptop, kind networking and service together; it is a regression sample, not a benchmark certificate.

### `bash cluster/cleanup.sh`

Cleanup deletes only `atlas-platform`, project `.state` and `atlas-platform-demo:1.0.0`. It rejects a symlinked state path and verifies node-container absence. It does not run `docker system prune` because shared caches and unrelated resources are outside scope.

## Decision path

Start with the user operation and move in dependency order.

### 1. Did the platform request validate?

If `platformctl.py` rejects input, Kubernetes is not involved. Fix the versioned request or decide whether the contract needs a reviewed extension. Do not bypass the generator with manual YAML while still claiming golden-path ownership.

If generation differs from committed output, stop. Determine whether the request changed, generator changed or committed state is stale. Review semantic differences before updating.

### 2. Can the reconciler identify source?

Require a full commit, allowlisted path and content SHA. A missing path or uncommitted desired file is a source-state problem. Do not point the reconciler at an arbitrary working-tree path to “get it deployed”; that removes the evidence chain.

### 3. Can the API be reached with the intended kubeconfig?

Use an explicit project kubeconfig. If API reachability fails, inspect the cluster lifecycle and listener. Do not edit Deployment probes—the object path has not been reached.

The session observed a diagnostic quoting error that fell back to a stale default cloud context and attempted DNS resolution. No mutation occurred, but the lesson is serious: context identity is part of every dangerous command. In production, print sanitized cluster/server identity and require an environment guard before apply/delete.

### 4. Did authentication or authorization reject?

Unauthorized usually means missing/invalid identity. Forbidden means authenticated identity lacks permission. Capture the API status and `auth can-i` for exact verb/resource/scope. Fix the Role/Binding only when the intended responsibility requires it. Cluster-admin is not a diagnostic.

### 5. Did admission reject?

Map the message:

- owner/resources/security/replicas/image → CEL workload contract;
- restricted-policy message → Pod Security;
- exceeded quota → tenant budget;
- webhook timeout/failure → external admission availability and failure policy.

Correct user intent for a valid rejection. If a known-good object is rejected due to policy regression, freeze broader rollout, restore the last reviewed policy revision or use a pre-approved break-glass path. Preserve fail-closed protection unless the risk decision explicitly justifies otherwise.

### 6. Was the object stored but no Pod became Ready?

Inspect Deployment condition, ReplicaSet, Pod phase and events. Pending means scheduler/capacity/topology/image preconditions. Waiting states such as ImagePullBackOff belong to image distribution/identity. CrashLoopBackOff belongs to process startup, dependency or probe behavior. Do not treat phase labels as root causes; they are branches.

### 7. Are endpoints and user operation healthy?

Compare Service selector, Pod labels and EndpointSlice readiness. Test in-cluster and external boundaries separately. If rollout is Available but the external path is still converging, a bounded read-only retry can be correct. If the bound is breached, investigate dataplane rules and endpoint propagation.

### 8. Is this observation, mitigation, reconciliation, rollback or restore?

Choose by mechanism:

- **Observe** when evidence is insufficient and waiting has a fixed question/window.
- **Mitigate** when you can reduce user impact without hiding evidence, such as stopping promotion.
- **Reconcile** when committed state is correct and actual state drifted.
- **Rollback** when a prior executable/configuration remains compatible.
- **Roll forward** when data/API compatibility makes rollback unsafe.
- **Reconstruct** when declarations were lost and source is authoritative.
- **Restore** when data/control-plane state is lost or damaged and a verified recovery point plus accepted loss boundary exists.

### 9. When is recovery complete?

Not when the command exits zero. Require the intended revision, policy health, available Pods, correct endpoints, representative user operation, telemetry visibility and an observation window. Communicate remaining uncertainty and follow-up owners.

At five minutes, report impact, affected scope, known-good baseline, last change, evidence preserved and immediate containment. At fifteen, report hypotheses tested, rejected explanations, current mechanism and recovery options. At thirty, report user state, selected decision, risks, validation, observation and next update. Leadership is making uncertainty actionable, not sounding certain.

## Guided Ubuntu lab

This lab runs a real disposable Kubernetes API and real containers. Read each script before execution. Use Ubuntu 24.04 as a normal user. Docker Desktop must be running. Do not use a work or cloud kubeconfig.

Work from:

```bash
cd /path/to/DevOps-SRE-Learning-Path/drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project
```

### Step 0: prove the boundary

```bash
id
docker info --format 'server={{.ServerVersion}}'
kubectl version --client
git rev-parse --show-toplevel
```

Abort if UID is 0, Docker is unavailable, the path is outside this repository, or any command would target a default cluster. The project stores its own kubeconfig later.

Read `toolchain.env`. The kind version, Linux binary SHA and node-image digest are separate identities. A tag tells you a name. A digest/checksum tells you exact content. Neither proves vulnerability absence.

### Step 1: install kind locally

```bash
bash tools/install-kind.sh
```

Expected final branch:

```text
kind_install=pass version=v0.31.0 checksum=pass path=.../.tools/bin/kind
```

If WSL DNS cannot resolve the download host, the script uses the pinned Python container’s TLS stack, then still verifies SHA-256. It never uses `sudo` or writes into `/usr/local/bin`.

### Step 2: inspect and create the cluster

Open `cluster/kind.yaml`. Find:

- API address 127.0.0.1;
- host port 18080 mapping to node port 30080;
- one control plane and two workers;
- synthetic zone labels on workers.

Then:

```bash
bash cluster/create.sh
bash cluster/status.sh
```

Expected: three Ready nodes at v1.35.0 and API `readyz` output `ok`. Draw the boundary around all three node containers and write “one laptop failure domain.” This prevents you later calling the topology multi-zone.

### Step 3: bootstrap tenancy and policy

Read `platform/base/`, then:

```bash
bash platform/bootstrap.sh
```

Expected:

```text
rbac=pass same_tenant=yes secrets=no cross_tenant=no
platform=bootstrap-pass namespaces=2 policy=cel rbac=least-privilege quota=present
```

Now answer: why does team-a Deployment creation succeed while Secret reads fail? The Role contains workload verbs but not Secrets. Why does team-b creation fail? RoleBindings are namespace-scoped and team-b does not bind the team-a identity.

Inspect quota:

```bash
kubectl --kubeconfig .state/kubeconfig describe resourcequota tenant-budget -n team-a
```

Used values are current admitted declarations. Hard values are policy ceilings. They are not node metrics.

### Step 4: inspect the developer request

```bash
python3 platformctl.py check --request requests/payments-api.json
python3 -m unittest discover -s tests -v
```

Expected: request valid and twelve tests pass. Copy the request to a temporary file and add `"privileged": true` under spec. Check it. Expected rejection says the field is unknown. Remove the temporary file afterward.

Generate to a private temporary directory and compare:

```bash
tmpdir="$(mktemp -d)"
python3 platformctl.py generate \
  --request requests/payments-api.json \
  --output "$tmpdir/payments-api.yaml" \
  --catalog-output "$tmpdir/payments-api.json"
cmp "$tmpdir/payments-api.yaml" desired/team-a/payments-api.yaml
cmp "$tmpdir/payments-api.json" catalog/payments-api.json
rm -f "$tmpdir/payments-api.yaml" "$tmpdir/payments-api.json"
rmdir "$tmpdir"
```

`cmp` prints nothing on equality and returns zero. The exact cleanup avoids broad temporary-directory deletion.

### Step 5: build and load the workload

```bash
bash workload/build-load.sh
```

Expected: Dockerfile checks report no warning, the image user is 10001:10001, and the image loads into all three nodes. Explain why load is needed: `imagePullPolicy: Never` tells kubelet not to contact a registry.

### Step 6: reconcile committed desired state

The desired file must be committed. Run:

```bash
python3 ops/reconcile.py \
  --source drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/team-a/payments-api.yaml \
  --revision HEAD
```

Expected receipt includes a twelve-character commit prefix, `drift=true` on first creation and a SHA-256. Open `.state/reconcile-receipt.json`. Match the full commit with `git rev-parse HEAD`. The receipt’s apply output should name ServiceAccount, Deployment, Service, NetworkPolicy and PDB.

### Step 7: validate rollout and the user path

```bash
kubectl --kubeconfig .state/kubeconfig rollout status deployment/payments-api -n team-a --timeout=120s
kubectl --kubeconfig .state/kubeconfig get pods -n team-a -o wide
kubectl --kubeconfig .state/kubeconfig get endpointslice -n team-a
curl -fsS http://127.0.0.1:18080/version
```

Expected: two ready Pods, normally one on each worker, ready endpoints and `{"version": "1.0.0"}`. If both Pods land together, inspect topology labels and events; `ScheduleAnyway` does not make distribution absolute.

### Step 8: prove policy with safe negative tests

```bash
bash ops/verify-denials.sh
```

Expected: CEL owner, Pod Security and quota denials pass and `resources_created=none`. Open each file under `failures/`. The over-quota Pod is otherwise restricted. That separation proves quota, not another earlier rejection.

### Step 9: watch control loops fail and recover

```bash
bash ops/verify-drift.sh
bash ops/verify-rollback.sh
```

The drift script records replicas one and then two after reconciliation. Inspect managed fields:

```bash
kubectl --kubeconfig .state/kubeconfig get deployment payments-api -n team-a -o yaml
```

Find `managedFields` and managers. Do not memorize the large YAML; find who owns `spec.replicas` and why a conflict appeared.

The rollback script uses an unavailable image, expects rollout failure, restores the earlier revision and checks the user path. Write down why this is safe for the stateless fixture and what database migration could make it unsafe.

### Step 10: calculate a bounded SLO window

```bash
python3 ops/measure_slo.py probe \
  --requests 100 --concurrency 5 --output .state/probes.jsonl
python3 ops/measure_slo.py evaluate \
  --input .state/probes.jsonl --availability 0.99 --latency-ms 200
```

In the verified run, 100/100 eligible requests succeeded and p95 was 12.881 ms. On another machine, latency will differ. At 99%, one failure is the fractional budget for 100 events:

```text
allowed bad events = 100 × (1 - 0.99) = 1
budget consumption = observed failures / 1
```

This tiny sample is educational and sensitive to one failure. Do not turn it into a production promise.

### Step 11: reconstruct declarations

```bash
bash ops/verify-reconstruction.sh
```

The script deletes only team-a, proves absence, reapplies controls, reconciles the commit, waits for rollout and retries the read-only user probe within a fixed bound. Expected receipt says `data_restore=not-exercised`. Explain which missing states Git could not recover.

### Step 12: clean and prove absence

```bash
bash cluster/cleanup.sh
```

Expected:

```text
cleanup=pass cluster=absent state=absent workload_image=absent tool_and_node_cache=retained
```

If cleanup refuses a symlink or unknown path, stop and inspect. Never replace the script with a global Docker prune.

After learning each stage, run the integrated `bash verify.sh` from an absent cluster. Its pass is the reproducibility receipt for the complete local boundary. It is not permission to skip understanding the stages.

## Production transfer

Transfer the **reasoning**, not the topology.

### Cluster lifecycle

kind’s correct production transfer is disposable test clusters and reproducible manifests. A production cluster needs supported control-plane architecture, multiple failure domains where required, etcd management, node-image lifecycle, CNI, CSI, DNS, load-balancer integration, audit, telemetry and an upgrade owner.

On the source-review date, Kubernetes maintains 1.36, 1.35 and 1.34 branches. This fixture uses the kind-published 1.35.0 image, while later 1.35 patches exist. Reproduction needs the exact image; security/bug currency needs a reviewed update. Record both facts instead of choosing one.

Before upgrading:

1. inventory API groups/versions, CRDs, webhooks, controllers, CNI, CSI, ingress/Gateway, autoscaling, node OS/runtime and clients;
2. measure deprecated API use rather than only scanning YAML;
3. check supported component skew and required upgrade order;
4. validate stored objects and manifests against the target;
5. test backups, restore, capacity and rollback/roll-forward;
6. stage through a failure domain or candidate cluster;
7. validate platform and user SLIs;
8. observe before destroying the previous recovery path.

kind recommends disposal/recreation as its update strategy. Do not put “upgraded Kubernetes” on a resume because you recreated this lab. The honest claim is: “Built a digest-pinned local platform and designed a production upgrade plan using skew, deprecation, add-on, capacity and recovery gates.”

### Identity and multi-tenancy

Replace static admin kubeconfig use with organizational federation and short-lived identities. Separate human, CI and controller principals. Test privilege escalation paths: creating RoleBindings, impersonation, token creation, workload identity, exec/port-forward and indirect Secret access.

Namespaces are suitable for many soft multi-tenant organizational boundaries when defense layers match the threat model. Hostile tenants may require stronger node pools, runtime classes, virtual clusters or separate clusters/accounts. Decide from kernel, control-plane, network, data and compliance risk—not a generic “one cluster versus many” slogan.

Install and prove an enforcing CNI before claiming NetworkPolicy. Start with observed flows, DNS and required platform paths. Default deny without accurate dependencies creates outages; allow-all with policy objects creates theater. Test permitted and denied packets both directions.

### GitOps and delivery

Move from the small reconciler to a maintained controller such as Flux or Argo CD when requirements include remote pull, source authentication, continuous watch, inventory/prune, dependency ordering, health, notifications and controller HA. Protect branches and tags. Decide whether source signatures, artifact provenance and admission should be required.

Separate CI from CD:

- CI tests source and produces immutable artifacts plus provenance;
- promotion changes environment desired state to an already-built identity;
- GitOps controllers pull/reconcile;
- runtime validation decides whether users are healthy.

Do not rebuild per environment. Do not store plaintext secrets in Git. Use encrypted secret workflows or external secret delivery with rotation and outage behavior tested.

### Golden path and portal

The platform API should be stable before the portal. A Backstage template or custom UI can collect inputs and show status, but it must not become a privileged opaque deployment proxy. Return the generated diff, policy errors, operation identity and runbook link.

Version templates and generated contracts. When a baseline changes, decide whether existing services automatically inherit it, receive a migration pull request or remain pinned. A secure new-service template does not fix thousands of old services.

Test with real users. Measure time to safe outcome, rejection comprehension, support contacts, escape-hatch demand, change failure and adoption. A launch announcement and page views are not developer-experience evidence.

### State and recovery

Maintain separate inventories:

- protected Git and artifact registry;
- etcd snapshot and encryption material;
- application database/volume snapshots;
- external DNS, load balancer, key and identity state.

Set RPO and RTO from business impact. Restore into isolation, validate engine integrity and business invariants, reconcile cross-system references and require authorized cutover. A namespace reconstruction time on one laptop is not a production RTO.

### Observability and operations

Collect API request/admission latency and rejection reasons, workqueue depth, scheduler and kubelet health, node pressure, controller reconciliation, rollout success, platform task latency and external user operations. Protect cardinality: service, tenant and reason can be bounded; object UID, request ID and commit per metric label can explode.

Page on actionable user/platform impact. Ticket on approaching deprecation, quota trend and template drift. Monitor the monitoring path. Define incident roles, break-glass identity, evidence preservation and policy recovery before the first outage.

Production readiness is a decision record with evidence and unresolved risk. The project’s review correctly says **not approved for production**. That honesty makes the portfolio stronger, not weaker.

## Reliability, security, observability, capacity, and cost

These are not five review checkboxes. Each changes the others.

### Reliability

Define three service levels:

1. **Platform request SLI:** valid self-service requests that produce accepted desired state within a bound.
2. **Deployment SLI:** accepted changes that converge to the intended available revision within a bound.
3. **Application SLI:** eligible user operations that are correct and within latency.

If you combine them, ownership disappears. A generator can succeed while a bad image fails. A Deployment can be available while a payment write is incorrect. An application can keep serving while the portal is down.

For an availability objective `O` and `N` eligible events:

```text
allowed bad events = N × (1 - O)
availability = good / eligible
budget consumed = bad / allowed bad
```

At N=100 and O=0.99, one failure consumes the whole small-window budget. Production often uses longer windows and multi-window burn alerts because short samples are volatile. Always define exclusions before seeing results. Excluding an incident after it happens is not SLO engineering.

PDB, multiple replicas and rolling settings protect particular failure modes. PDB covers voluntary disruptions, not node crash, application deadlock or insufficient capacity. Two replicas on one physical host do not survive host loss. Reliability language must include failure domain.

### Security

Threat-model the interfaces:

- untrusted developer input into generator;
- Git contributor into desired state;
- reconciler credential into cluster;
- tenant workload into shared API/node/network/storage;
- host user into Docker and kubeconfig;
- artifact source into runtime.

Strict input rejects ambiguity. Protected Git provides review/history. Scoped RBAC reduces identity blast radius. Admission enforces object invariants. Pod security reduces runtime privilege. Quota reduces one resource-abuse path. Network and storage policies protect other paths. Signed provenance can connect source/build/artifact; digest alone provides identity but no authorization verdict.

Emergency access should be predesigned: short-lived, approved, logged, narrow and revoked. “Disable policy during incidents” is dangerous because incidents are when rushed changes and compromised identities are most costly.

Secrets never belong in command output or evidence bundles. Kubernetes Secret is an API object, not automatically an external vault. Consider etcd encryption, RBAC, kubelet/node exposure, projection, rotation and application reload.

### Observability

Observe control and data planes:

- generator validation successes/rejections by bounded reason;
- Git source and reconciler health, lag, drift, conflicts and apply duration;
- API request rate/latency/errors and admission latency/failures;
- scheduler pending reasons and queue;
- node/kubelet/runtime pressure;
- Deployment convergence and unavailable duration;
- endpoints and external user operations;
- platform task completion and support demand.

Use logs for high-cardinality context, traces for a bounded causal path and metrics for aggregatable behavior. Put request/trace IDs in exemplars or logs, not metric labels. Audit who changed RBAC/policy and who used break glass.

Monitor monitoring health. A silent alerting system during an outage produces no page and can be misread as health. Independent external probes and telemetry-pipeline alerts reduce this blind spot.

### Capacity and performance

Start with demand: requests per second, concurrency, payload, dependency latency and work per request. Then map application resources, replicas and queues. Platform capacity adds API/control-plane calls, controller workqueues, admission latency, DNS, CNI, CSI and telemetry.

Budget:

```text
steady workload
+ peak factor
+ one failure-domain loss
+ rollout maxSurge
+ system daemons and add-ons
+ fragmentation and safety reserve
```

Quota without capacity planning only distributes scarcity. Autoscaling without correct requests and spare nodes changes desired replicas but may leave Pods Pending. Horizontal scaling can overload a shared database. Vertical scaling can increase restart cost. Choose based on the bottleneck.

The local probe used concurrency five and 100 requests. It cannot find saturation. A representative capacity test would ramp gradually, measure user latency/errors and every bottleneck, hold steady, inject a failure, test recovery and stop before unsafe host pressure.

### Cost and platform economics

Cost includes control-plane/worker baseline, network, storage, registry, telemetry, backups, security/upgrade labor, on-call and developer waiting. Unit economics—cost per active service, successful deployment or user transaction—connect spending to value better than a total cluster bill.

High utilization is not automatically efficient. A cluster at 95% requested capacity may lack rollout or failover headroom and impose incident cost. Retained node-image cache consumes disk but saves repeated cold downloads; the project states this trade-off explicitly.

A golden path should show cost-driving choices before deployment: replicas, requests, storage class, retention and cross-zone traffic. It should not force every developer to interpret raw provider billing.

Finally, platform value has an opportunity cost. Building a custom portal, controller or policy engine creates lifecycle ownership. Prefer maintained components when they meet the need. Build only the narrow differentiated interface, and measure whether it actually reduces safe delivery time and operational toil.

## Traps and prevention

### Trap: “Namespace equals secure tenancy”

Prevention: write an isolation matrix for identity/RBAC, network, compute, storage, secrets, nodes, control plane, audit and blast radius. Test each required boundary.

### Trap: shared admin kubeconfig for speed

Prevention: federated short-lived identities, scoped roles, separate human/controller principals, access review and narrow audited break glass.

### Trap: arbitrary YAML as self-service

Prevention: a small versioned contract for the supported job, safe defaults, precise errors, reviewable generated output and a governed advanced path.

### Trap: portal first, capability later

Prevention: stabilize APIs, ownership and workflows first. Add a portal when it improves discovery and operation rather than hiding unstable automation.

### Trap: repository plus CI is called GitOps

Prevention: test all four principles: declarative, versioned/immutable, pulled automatically and continuously reconciled. State which principle is only modeled.

### Trap: working-tree state deployed under a commit claim

Prevention: resolve full commit, read content from Git, hash it and record the source path. Protect source and review permissions.

### Trap: multiple controllers own replicas

Prevention: field-ownership matrix. Decide among Git, HPA, operator and human. Make emergency ownership transfer explicit and time-bounded.

### Trap: `--force-conflicts` as a universal repair

Prevention: inspect managed fields, choose the rightful owner, predict overwritten fields and use force only inside that declared scope.

### Trap: policy object existence equals enforcement

Prevention: server-side negative tests for each mechanism, plus runtime/packet tests where admission cannot prove behavior.

### Trap: policy disabled during incidents

Prevention: pre-reviewed recovery paths and break-glass identity. Recover the policy to a known revision rather than admitting arbitrary changes.

### Trap: NetworkPolicy accepted means packets are blocked

Prevention: verify CNI support and test allowed/denied ingress and egress. Keep DNS, monitoring and control paths explicit.

### Trap: limits without requests

Prevention: measure demand, set requests, examine fit/throttling and revise. Autoscaling still needs capacity and correct signals.

### Trap: quota is capacity

Prevention: compare tenant declarations with physical allocatable, fragmentation, surge and failure reserve. Quota distributes policy; it does not create resources.

### Trap: Pod Running means service healthy

Prevention: readiness, EndpointSlice, representative external operation, time window and correctness.

### Trap: liveness checks dependencies

Prevention: keep liveness narrow enough to detect a stuck process. Use readiness for required serving dependencies so a shared dependency outage does not trigger restart storms.

### Trap: HPA will solve every load problem

Prevention: identify bottleneck, metrics lag, startup time, node capacity, dependency limits and downscale behavior. Test under failure.

### Trap: delete Pods before evidence

Prevention: capture events, conditions, logs, identity, requests, node and endpoints first. Delete later as a bounded controller/recovery test if justified.

### Trap: rollback always safe

Prevention: compatibility receipt across schema, configuration, API and data. Maintain roll-forward for irreversible state.

### Trap: Git is a backup

Prevention: state inventory. Git declarations, etcd objects, application data, external resources, artifacts and keys each need recovery.

### Trap: local reconstruction time becomes RTO

Prevention: label local measurements, test representative scale/failure and obtain business-approved RPO/RTO separately.

### Trap: kind nodes are zones

Prevention: name the shared host/kernel/Docker/power failure domain. Use real independent failure domains for availability claims.

### Trap: pinned equals secure forever

Prevention: pin for reproduction; schedule update/vulnerability/license review and promote a new reviewed identity.

### Trap: more platform features mean more value

Prevention: track safe task success, lead time, adoption, support toil, change failure and user trust. Remove or simplify unused capabilities.

### Trap: broad cleanup

Prevention: fixed names, verified absolute boundaries, symlink refusal, allowlisted deletion and post-cleanup absence checks. Never use a global prune as a lab shortcut.

### Trap: interview answer lists tools

Prevention: begin with user operation, control/data paths, state, failure domains, evidence, trade-offs and recovery. Name tools only after the mechanism and requirements are clear.

## Memory card and retrieval

Keep this card:

```text
Intent before YAML.
Identity before permission.
Permission before admission.
Admission before scheduling.
Scheduling before runtime.
Readiness before traffic.
User operation before “healthy.”
Owner before force.
Compatibility before rollback.
State class before restore.
Evidence before claim.
```

Answer aloud without looking:

1. Why can `auth can-i` say yes while the API rejects the object?
2. What does a namespace isolate, and what does it not isolate by itself?
3. Why are ResourceQuota and LimitRange both useful?
4. What is the difference between CPU request and CPU limit?
5. What does Pod Ready prove beyond Pod Running?
6. Why can Deployment Available precede success on an external user path?
7. What are the four OpenGitOps principles?
8. Why is CI running `kubectl apply` not continuous reconciliation?
9. What does a field-manager conflict tell you?
10. When is `--force-conflicts` justified in this fixture, and why is it risky elsewhere?
11. Why does a server-side dry-run provide stronger policy evidence than local YAML parsing?
12. Why does accepted NetworkPolicy YAML not prove blocked traffic?
13. What did the bad-image rollback exercise prove?
14. What could make the same rollback unsafe?
15. Which state can Git reconstruct after namespace deletion?
16. Which state requires etcd or application-data recovery instead?
17. With 100 eligible events and a 99% objective, how many failures consume the fractional budget?
18. Why is p95 12.881 ms not a production capacity result?
19. What should a platform team measure besides adoption?
20. What evidence is required before calling this platform production-ready?

Use spaced retrieval:

- today: answer all twenty and run one guided stage;
- tomorrow: draw the API decision and recovery-state diagrams from memory;
- in one week: diagnose one reviewer-changed failure without the decision path;
- in one month: defend tenancy, GitOps, upgrade and recovery trade-offs for an unfamiliar company scenario.

Reading fluency feels like knowledge but disappears under incident pressure. Retrieval plus changed conditions builds durable judgment.

## Complete answers

### 1. Why can authorization say yes while the object is rejected?

Authorization asks whether the identity may perform a verb on a resource in a scope. Admission then evaluates the authorized object against policy, defaults and aggregate constraints. In the fixture, team-a’s developer may create Deployments, but CEL rejects one missing `platform.atlas.dev/owner`. Both decisions are correct.

### 2. What does a namespace isolate?

A namespace scopes names and many namespaced API resources, Roles, RoleBindings, quotas and policy selection. It does not create a separate kernel, node, network, storage backend, API server or etcd. It does not automatically block packets or Secret access. Tenant design must layer identity, authorization, admission, network, compute, storage, secrets, node and control-plane protections.

### 3. Why ResourceQuota and LimitRange?

ResourceQuota caps aggregate namespace declarations such as total requested CPU, memory, Pods and Services. LimitRange supplies or constrains per-container/Pod defaults and bounds. Without defaults, quota that requires requests can reject omissions; without aggregate quota, individually reasonable workloads can collectively consume the tenant budget. They complement each other.

### 4. CPU request versus limit

The request is used for scheduler fit and relative CPU sharing. The limit is enforced at runtime through cgroup quota and can cause throttling. A request is not a measurement, and a limit does not reserve capacity. Under-requesting improves apparent bin packing but risks contention; over-requesting strands capacity.

### 5. Ready beyond Running

Running means the Pod has at least one running container or is in the running phase. Ready means configured readiness conditions currently allow it to receive Service traffic. Readiness can test a listener or required dependencies. It still does not prove every user operation, correctness or a time-window objective.

### 6. Available before the external path

Deployment availability derives from ready replicas and timing. EndpointSlice updates, node dataplane rules, load balancer/ingress and DNS can converge afterward. The lab observed one immediate NodePort reset after reconstruction, then success on the next bounded attempt. Therefore validate the exact user path after controller conditions.

### 7. Four OpenGitOps principles

Desired state is declarative; it is stored with versioning, immutability and history; software agents automatically pull it; agents continuously observe actual state and attempt reconciliation. Tools vary, but omitting pull or continuous reconcile changes the operating model.

### 8. Why CI apply is not continuous reconciliation

CI pushes when a pipeline event runs. If a human changes or deletes a resource later, no agent necessarily notices. A reconciler repeatedly compares source with actual state and corrects drift. CI remains valuable for build/test/artifact creation; it is not automatically the runtime owner.

### 9. Meaning of field-manager conflict

Two managers claim incompatible ownership or values for the same field. The conflict is a design signal: decide who owns the field. For replicas, candidates include Git, HPA, an operator and a human. Repeatedly forcing without that decision creates controller fighting and unstable state.

### 10. When force is justified here

The generator contract explicitly owns generated Deployment replicas, and the drift test intentionally gives `kubectl scale` temporary ownership. The reconciler force-takes that field to demonstrate recovery. Elsewhere, force can overwrite HPA or incident mitigation. Inspect managed fields, scope the owner and document recovery before using it.

### 11. Why server-side dry-run is stronger

Local parsing can catch syntax and generator rules. Server dry-run contacts the real API version and executes defaulting, schema validation and configured admission without persistence. It can therefore prove that CEL, Pod Security or quota rejected the test. It still does not prove runtime containment or a network packet decision.

### 12. Why NetworkPolicy YAML is not packet proof

The API accepts the standard resource regardless of whether the installed CNI enforces it. Selector mistakes and additive rules can also produce unexpected flows. Evidence needs a compatible enforcing implementation plus allowed and denied packet tests for ingress, egress, DNS and platform dependencies. This fixture explicitly leaves that gap open.

### 13. What the bad-image rollback proved

An unavailable candidate image failed to become ready; the rolling strategy kept the old service available; Kubernetes restored the prior Pod template; the external version probe returned 1.0.0. This proves a bounded stateless image rollback under current capacity and compatibility.

### 14. What makes rollback unsafe?

Irreversible or backward-incompatible database schema, changed message format, destructive background job, incompatible configuration, expired credentials, external side effects or a removed artifact. Use expand/contract migrations and preserve a roll-forward option. Never infer data compatibility from Pod readiness.

### 15. What Git reconstructs

Git can reconstruct the declarations actually stored there: namespaces, RBAC, quota, policy and workload objects in this exercise. A reconciler re-creates them. Git also supplies history and review evidence. It cannot reconstruct mutations or dynamic objects that were never declared/recorded.

### 16. What needs other recovery?

etcd-only API state needs control-plane snapshot/restore or deliberate regeneration. Database rows and persistent-volume data need application-consistent backups. External DNS, load balancers, keys and identities need inventories and provider reconciliation. Image registries and signing keys are separate dependencies. Recovery order and compatibility matter.

### 17. Error-budget arithmetic

At 100 eligible events and 99% objective:

```text
100 × (1 - 0.99) = 1 allowed failed event
```

One observed failure consumes 1/1 = 100% of the fractional budget; two consume 200%. Small samples are coarse. Do not hide this by rounding availability without showing counts.

### 18. Why local p95 is not production capacity

It measures one laptop, warm image, tiny Python service, loopback NodePort, 100 requests and concurrency five. It does not include representative payloads, dependencies, sustained traffic, saturation, noisy tenants, failure domains, ingress/TLS, telemetry overhead or production hardware. Use it as a regression baseline only.

### 19. What to measure besides adoption

Safe self-service completion, lead time to first deployment, rejection comprehension, change failure, rollback/recovery time, support contacts, toil, exception demand, deprecation compliance, platform and user SLOs, cost per useful outcome and trust. Adoption can rise because use is mandatory while experience remains poor.

### 20. Production-readiness evidence

At minimum: supported topology and failure domains; current patch/update process; identity/RBAC escalation review; enforcing network/storage/secret boundaries; signed supply chain; maintained GitOps controller; API/audit/telemetry/on-call; representative load and capacity reserve; upgrade rehearsal; etcd and application-data restore; external resource reconciliation; independent security/reliability review; real developer usability tests; cost/support/deprecation model; and closed or accepted residual risks. This local project intentionally fails several of those gates.

## Product-company interview

These are not trivia questions. A strong answer exposes how you model a system, choose evidence and protect the user operation. Use this shape:

```text
Clarify the user operation and objective.
Map request path, control path, state and ownership.
Name the most dangerous failure modes.
Choose evidence that separates those failures.
Restore safely, then prevent recurrence.
State trade-offs and what remains unproved.
```

### Scenario 1: design an internal developer platform

**Prompt:** Hundreds of teams deploy services differently. Design a Kubernetes platform that improves speed without removing team autonomy.

**Strong answer:** Identify common jobs: bootstrap, deploy, observe, scale, recover, obtain a secret and retire a service. Define a small versioned service contract for those repeated needs. The platform validates the contract and emits reviewed primitives while retaining an escape path for workloads that genuinely do not fit. Separate platform control plane from workload data planes. Use SSO-backed identities, namespace-scoped roles, admission, quota, secure defaults and declarative delivery. Make ownership visible in every object.

The golden path must include feedback, not only generation. A rejection should identify the field and correction. Measure safe task completion, lead time, support demand and change failure—not YAML or cluster count. Roll out with representative design partners, publish compatibility/deprecation policy and operate the platform as a product with an SLO and support model.

**Follow-up:** Avoid a giant abstraction exposing every Kubernetes field, mandatory adoption before usability evidence, and a central team owning every application incident.

### Scenario 2: authorization succeeds but deployment fails

**Prompt:** A developer says, “RBAC says yes, but Kubernetes rejected my Deployment.”

**Strong answer:** Preserve the API response and identity. The authorization check establishes authorization only. Then inspect server dry-run, admission warnings, namespace Pod Security labels, ValidatingAdmissionPolicy bindings, quotas and LimitRanges. Here, an authorized request missing the owner label is rejected by CEL. Satisfy the contract; do not broaden RBAC or disable policy.

**Follow-up:** Prevent recurrence with contract tests, actionable errors, allowed/denied policy fixtures and staged policy rollout.

### Scenario 3: multi-tenancy threat model

**Prompt:** Is one namespace per team sufficient isolation?

**Strong answer:** No. A namespace is administrative scope, not a complete security boundary. Map identity, authorization, admission, secrets, network, storage, nodes, runtime, control plane and external services. Accidental interference, malicious tenants, regulated data and hostile code require different controls. Apply least privilege, default-deny networking with an enforcing CNI, hardened workloads, storage boundaries, secret brokerage, audit, quotas and possibly dedicated nodes or clusters.

**Follow-up:** Choose separate clusters when blast radius, trust, compliance, upgrade independence or noisy-neighbor requirements outweigh fleet complexity and cost.

### Scenario 4: Git says three replicas, production has eight

**Prompt:** Reconciliation reports a field conflict during a traffic spike.

**Strong answer:** Do not force immediately. Inspect managed fields and decide whether Git, HPA, an operator or the incident commander should own replicas. If eight is an authorized mitigation, suspend or patch the declarative owner through an audited, time-bounded process. If it is unauthorized drift and Git is the owner, reconcile and record the receipt. Remove ambiguous ownership so controllers do not fight.

**Follow-up:** Convergence is insufficient: a system can converge to malicious or mistaken desired state. Source integrity, review, authorization and artifact identity make it safe.

### Scenario 5: progressive delivery with a database change

**Prompt:** How would you make zero-downtime deployment credible?

**Strong answer:** Treat application and data compatibility as one release. Use expand/contract: add backward-compatible schema, deploy code supporting both forms, migrate and verify data, shift traffic using readiness and user-operation metrics, then remove the old form later. Define abort thresholds and preserve artifacts. Kubernetes rollback restores a Pod template; it cannot undo destructive writes.

**Follow-up:** Promotion needs candidate health, representative success/latency, dependency saturation, error-budget policy, schema compatibility, canary comparison and an observation window.

### Scenario 6: platform control plane is unavailable

**Prompt:** The portal and generator are down. Should running applications fail?

**Strong answer:** Normally no. Keep the platform control plane off the synchronous serving path. Existing Pods, Services and routing should continue; new changes may pause safely. Identify exceptions such as short-lived credential issuance or mesh control dependencies and design cached or bounded behavior. Give control and workload planes separate SLOs and failure tests.

**Follow-up:** Protect current traffic, freeze unsafe changes, recover source/identity/reconciliation, validate drift, then reopen self-service.

### Scenario 7: noisy neighbor and pending Pods

**Prompt:** Tenant B cannot schedule while Tenant A is within quota.

**Strong answer:** Quota is not physical capacity. Check requests, node allocatable, scheduler events, affinity, taints, topology, fragmentation and rollout surge. Tenant A can be within quota while requested shapes no longer fit. Protect failure reserve, use realistic requests, apply priority/preemption only by policy, autoscale nodes where available and test bin-packing under maintenance and zone loss.

**Follow-up:** Lowering every request hides demand, increases contention and makes eviction or throttling more likely.

### Scenario 8: NetworkPolicy exists but traffic still flows

**Prompt:** Security found cross-namespace connectivity despite default-deny YAML.

**Strong answer:** Confirm selectors, namespace and direction; then confirm the CNI implements policy for that traffic. Inspect additive policies, host networking, node-local paths and existing connections. Run allowed and denied packet tests. API acceptance proves stored intent, not dataplane enforcement.

**Follow-up:** Publish supported semantics, required DNS/telemetry exceptions, conformance tests and known bypass paths.

### Scenario 9: cluster API latency suddenly rises

**Prompt:** Workloads serve normally, but deployments and autoscaling lag.

**Strong answer:** Separate data-plane from control-plane health. Examine API latency/error by verb and resource, inflight requests, admission webhook latency, etcd latency/space, controller and scheduler queues, client retry storms and audit volume. Protect the API with priority/fairness and bounded clients. If a webhook fails, use its documented failure policy and recovery path rather than disabling admission globally.

**Follow-up:** Existing traffic may be healthy while rollout, failover and scaling capability is degraded. Reduced resilience is itself an incident.

### Scenario 10: reconstruct a deleted namespace

**Prompt:** Git recreated all objects, so is disaster recovery complete?

**Strong answer:** Only declaration recovery is proven. Inventory Git objects, etcd-only state, persistent data, external DNS/load balancers/identities, artifacts, keys and observability history. Restore in dependency order and validate a representative operation plus data correctness. State measured recovery time and whether it meets an approved RTO. This fixture reconstructs stateless declarations and explicitly does not restore application data.

**Follow-up:** Backups are not recovery evidence until restores, credentials, dependency order and compatibility are exercised.

### Scenario 11: upgrade a shared Kubernetes fleet

**Prompt:** Plan an upgrade without promising “no impact.”

**Strong answer:** Build version-skew and API-deprecation inventories; test manifests, policies, CNI, CSI, ingress, observability and operators against the target. Upgrade a disposable representative environment, then a low-risk cohort. Verify control plane, nodes, disruption budgets, scheduling and user journeys at every gate. Preserve drain capacity and define freeze/abort criteria. A control-plane rollback may be unsupported, so compatibility and roll-forward matter.

**Follow-up:** This lab proves behavior only for its pinned kind/Kubernetes versions. It does not exercise a production control-plane or etcd upgrade.

### Scenario 12: secure the software supply chain

**Prompt:** An image uses a non-latest tag. Is that sufficient?

**Strong answer:** No; a tag can be overwritten. Build reviewed source in an isolated pipeline, create SBOM and provenance, scan and sign the digest, admit trusted identities/digests, restrict registries, protect builders and signing keys, record deployed identity, and support revocation and patch promotion. Runtime hardening limits impact but cannot repair a compromised artifact.

**Follow-up:** Pinning improves reproduction and review but pins age. Automation must propose and verify updates.

### Scenario 13: design platform observability

**Prompt:** What dashboard would you build first?

**Strong answer:** Start with journeys: request accepted/rejected, generation success, reconciliation lag/failure, deployment readiness, external operation and recovery. Each view needs rate, errors, duration and saturation where meaningful, split by tenant/version without sensitive labels. Link alerts to runbooks and source revisions. Audit privileged actions and policy exceptions.

**Follow-up:** Alert on actionable symptoms tied to objectives, group related signals, use duration or multi-window burn where appropriate, and review every page outcome.

### Scenario 14: global service and regional failure

**Prompt:** Design for a region loss.

**Strong answer:** Begin with business RTO/RPO and consistency needs. Choose active/active or active/passive per stateful component. Keep independent failure domains, replicated artifacts/configuration, tested traffic steering, dependency inventories and failover capacity. Replication lag limits RPO; DNS and client caching affect RTO. Exercise partial failures and prevent split brain.

**Follow-up:** Kubernetes schedules inside clusters. It does not decide global data consistency, business failover policy or external dependency recovery.

### Scenario 15: reduce platform cost safely

**Prompt:** Leadership asks for 30 percent savings.

**Strong answer:** Attribute cost to useful workloads and shared services, then examine idle requests, workload shape, storage lifecycle, network egress, logging cardinality and duplicated tooling. Change one dimension with SLO and saturation guardrails. Rightsize from representative percentiles plus burst/failure reserve; use interruptible capacity only for tolerant work. Do not turn missing headroom into hidden availability risk.

**Follow-up:** Prefer a business-aligned unit such as cost per successful transaction or completed job, accompanied by reliability and demand context.

### Scenario 16: platform migration strategy

**Prompt:** Migrate hundreds of services from bespoke pipelines to the golden path.

**Strong answer:** Inventory patterns and risks, select representative cohorts, provide compatibility adapters and an automated assessment, then migrate in reversible stages. Run old and new delivery paths only long enough to compare outcomes. Publish ownership, exceptions and retirement dates. Measure developer success and production outcomes; repository conversion alone is not completion.

**Follow-up:** For a blocked team, identify the missing capability or justified exception, price its support cost, assign an owner and review date, and do not silently weaken the common contract.

## Independent transfer and rubric

The guided project proves that the repository contains a reproducible teaching fixture. It does **not** prove that you can transfer the reasoning to an unfamiliar system. That boundary protects you in interviews and protects a production team from false confidence.

### Your independent assignment

A reviewer selects a second service and tenant, changes at least one requirement after you begin, and injects two unfamiliar failures. You may use official documentation and normal engineering tools. You may not rename the sample, replay its transcript or request a model answer. Start from a fresh clone and create your own evidence packet.

Deliver:

1. A product brief naming users, job, non-goals, support tiers and measurable outcomes.
2. A receipt containing full source revision, tool versions, checksums, image digests and explicit kubeconfig/context.
3. A new ServiceRequest contract instance, deterministic desired state and catalog entry.
4. Architecture, decision, state-ownership and failure-domain maps.
5. A tenant threat model with proved and unproved boundaries.
6. Fresh-clone test, creation, policy, reconciliation and exact-cleanup transcripts.
7. Same-tenant allow plus cross-tenant, Secret and unsafe-workload denials.
8. An immutable Git source, desired hash, actual drift, field-manager analysis and reconciliation result.
9. A failed candidate, compatibility decision, recovery action, user-path validation and observation window.
10. An SLI packet with eligible events, objective, exclusions, counts, latency percentile and claim boundary.
11. A reviewer-selected recovery exercise separating declaration, API/etcd and application-data state.
12. Production-readiness, capacity/cost, upgrade, usability and ten-minute design-defense records.

Before each mutation, write expected effect, blast radius, abort condition and recovery. Every command must record time, exit status and target context. A causal statement needs reinforcing evidence or a hypothesis label; falsify at least one plausible hypothesis. Never include a credential or real customer data.

### How the reviewer scores it

Each dimension is worth ten points:

| Dimension | What observable success looks like |
|---|---|
| Product judgment | Representative user need becomes a coherent supported path, non-goals and outcomes. |
| Reproducibility and identity | A fresh clone reproduces from immutable source, tool and artifact identities. |
| Platform API and experience | The contract is safe, versioned, deterministic and understandable when it rejects input. |
| Kubernetes systems reasoning | You trace API, admission, controllers, scheduler, kubelet, network and readiness for unfamiliar faults. |
| Security and tenancy | Least privilege and independent denials are proved; gaps and host risk stay explicit. |
| GitOps and delivery | Immutable source is reconciled; ownership conflicts and failed delivery are handled safely. |
| SRE and capacity | SLIs and budget arithmetic are correct; bounded local data is not inflated into capacity claims. |
| Upgrade and recovery | Compatibility, state classes, rollback/roll-forward and restore boundaries are executable. |
| Incident leadership | Impact is scoped, evidence preserved, a hypothesis falsified and the user path validated. |
| Defense and truthful limits | Trade-offs, costs, residual risks and production blockers survive reviewer challenge. |

Score interpretation:

- **90–100:** strong capstone evidence, provided every critical safety condition passes;
- **75–89:** capable but gaps require targeted remediation and another review;
- **60–74:** partial transfer; repeat the failed dimensions with changed conditions;
- **below 60:** return to the relevant foundation and guided stages.

A high numeric score cannot cancel a critical failure. Critical failures include touching an unintended/default cloud context, exposing a secret, using broad cleanup, fabricating evidence, performing an unbounded mutation, claiming untested data restore, or representing local measurements as production results.

### What mastery means here

Mastery is awarded only after reviewer-observed independent work with artifact links and signed criteria. Reading this chapter, passing the guided verifier, or receiving an AI explanation is preparation—not mastery. If independent user testing did not occur, label it planned. If a network boundary was not packet-tested on an enforcing CNI, label it unproved. If data was not restored, do not claim DR.

When a dimension fails, write a small remediation loop: misconception, evidence that exposed it, focused practice, changed retest and reviewer result. This creates durable engineering judgment rather than a one-time score.

## References and review

Primary sources were reviewed on **2026-08-07**. The structured records beside this manuscript preserve organization, URL, version/date, topic scope, usage policy and review deadline. They support mechanism claims; they do not certify this teaching platform for production.

### Tool and cluster identity

- **REF-1120 — kind v0.31.0 release:** pins the local cluster tool, published node-image digest and compatibility boundary.
- **REF-1121 — kind configuration:** supports the multi-node config, API bind-address and host port mapping mechanics.
- **REF-1122 — Kubernetes components:** supports the API server, etcd, scheduler, controller-manager, kubelet and proxy ownership model.

### Identity, tenancy and policy

- **REF-1123 — Controlling access to the Kubernetes API:** supports the authentication, authorization and admission sequence.
- **REF-1124 — Using RBAC authorization:** supports Role, RoleBinding and least-privilege behavior.
- **REF-1125 — Namespaces:** supports namespaced scope while avoiding the false claim that a namespace alone is isolation.
- **REF-1126 — Resource quotas:** supports aggregate namespace constraint behavior.
- **REF-1127 — Limit ranges:** supports per-object defaults and min/max constraints.
- **REF-1128 — Network policies:** supports selector/additive semantics and the requirement for an enforcing network implementation.
- **REF-1129 — Pod Security namespace labels:** supports Restricted enforcement through namespace labels.
- **REF-1130 — Validating Admission Policy:** supports native CEL admission policy and binding behavior.

### Workloads, disruption and lifecycle

- **REF-1131 — Deployments:** supports rollout status, availability and rollback mechanics.
- **REF-1132 — Specifying a disruption budget:** supports voluntary-disruption constraints and their limits.
- **REF-1133 — Upgrading kubeadm clusters:** supplies a staged upgrade model; this capstone does not execute kubeadm upgrade.
- **REF-1134 — Version skew policy:** supports compatibility checks among Kubernetes components and clients.
- **REF-1135 — etcd disaster recovery:** supports snapshot integrity, revision considerations and restore mechanics; no etcd restore is executed here.

### Declarative delivery and platform product

- **REF-1136 — Declarative management with Kustomize:** supports deterministic composition and the offline render gate.
- **REF-1137 — GitOps Principles v1.0.0:** supplies declarative, versioned/immutable, pull and continuous-reconciliation criteria.
- **REF-1138 — Flux installation:** identifies the production-class controller path; the teaching reconciler is not represented as Flux.
- **REF-1139 — Backstage Software Templates:** provides an example of a software-template/golden-path interface; this capstone does not deploy Backstage.

### Claim boundary and next review

Re-review fast-moving tool, image, policy, security and compatibility sources by their structured record deadlines, and immediately after a pinned-version change. Before operational use, also review the exact CNI, CSI, ingress, identity provider, GitOps controller, registry, runtime, operating system and managed-service documentation for that environment.

The strongest statements this chapter supports are:

- the pinned local fixture was reproducibly built, tested, failed, reconciled, recovered and removed;
- the observed API decisions and user operations match the recorded environment;
- the architecture explains which controller or state owner produced each observed transition.

It does **not** support claims of production readiness, hostile-tenant isolation, packet-level NetworkPolicy enforcement, application-data recovery, control-plane upgrade safety, multi-zone availability, sustained capacity, independent usability or personal mastery. Those require the evidence gates named in this chapter.

Final retrieval: given any platform symptom, say aloud **user operation, path, state, owner, evidence, reversible action, validation, prevention and proof limit**. That sequence—not memorized YAML—is the durable platform-engineering skill.
