---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0041",
  "slug": "kubernetes-control-plane-reconciliation",
  "aliases": ["V05-L05", "kubernetes-control-plane-reconciliation"],
  "curriculumIds": ["K8S-001"],
  "route": "/book/infrastructure/kubernetes-control-plane-reconciliation",
  "order": 5,
  "volume": "05-infrastructure-platforms",
  "title": "Kubernetes control plane and reconciliation: follow an object from intent to running state",
  "summary": "Trace one Kubernetes object through API discovery, authentication, authorization, admission, persistence, watches, controllers, scheduling, kubelet convergence, status, ownership, deletion and evidence-driven recovery.",
  "domain": "infrastructure",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0004", "LES-0009", "LES-0023"],
  "prerequisiteCurriculumIds": ["NET-003", "SCM-001", "CTR-001"],
  "testedEnvironments": [
    {"platform": "Kubernetes documentation", "version": "v1.36 current documentation", "support": "supported", "notes": "Official architecture, API, controller, scheduler, node, lease, ownership, finalizer, apply, flow-control and debugging sources were reviewed on 2026-08-04."},
    {"platform": "Local Kubernetes cluster", "version": "not available", "support": "required", "notes": "Docker Desktop exposes client 29.6.2 but no Linux engine; WSL enumeration is access-denied. No cluster API or component behavior is claimed."},
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "A normal-user deterministic control-loop model is planned for concept rehearsal, but WSL cannot currently start. A model is never Kubernetes runtime evidence."},
    {"platform": "Cloud", "version": "not used", "support": "unsupported", "notes": "No managed cluster, credential, cloud account, billable object or external endpoint is authorized."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "kubernetes-engineer", "infrastructure-engineer", "security-engineer", "technical-lead"],
  "learningObjectives": [
    "Explain the API server, etcd, controller manager, scheduler, kubelet, container runtime, kube-proxy and DNS boundaries without calling Kubernetes one monolithic process.",
    "Trace a write through discovery, authentication, authorization, admission, validation, persistence and watch delivery.",
    "Read apiVersion, kind, metadata, spec and status as an object contract and distinguish desired state from observations.",
    "Explain resourceVersion, generation, observedGeneration, UID, ownerReferences, finalizers and managedFields at their correct boundaries.",
    "Model reconciliation as level-triggered compare-and-act logic that must be idempotent and retry-safe.",
    "Trace Deployment to ReplicaSet to Pod ownership and distinguish controller creation from scheduler binding and kubelet execution.",
    "Diagnose Pending or stalled objects using conditions, events, controller evidence, scheduler decisions, node leases and component health.",
    "Use watches correctly: list then watch, handle compaction and relist, and never treat an event stream as durable state.",
    "Design safe deletion and recovery around ownership, garbage collection, finalizers and single-writer field ownership.",
    "Transfer the control-loop model to local clusters, managed control planes, custom controllers and product-company interviews."
  ],
  "productionSignals": [
    "cluster identity, server version, API discovery result, context, user and namespace",
    "request verb, group, version, resource, subresource, name and field manager",
    "authentication identity, authorization decision, admission result and audit ID",
    "object UID, generation, resourceVersion, creation/deletion timestamp and finalizers",
    "spec digest, status conditions, observedGeneration and controller revision",
    "ownerReferences, controller flag, blockOwnerDeletion and garbage-collection policy",
    "watch start resourceVersion, bookmark, relist reason, compaction and event latency",
    "controller work-queue depth, retries, reconcile duration, error and leader lease",
    "unscheduled Pod count, scheduler queue, filter/plugin reason, nominated and bound node",
    "node Ready condition, Lease renew time, kubelet/runtime health and Pod phase/conditions",
    "API request rate, latency, errors, inflight limits, flow schema and priority level",
    "etcd leader, quorum health, commit/apply latency, database size and backup/restore evidence",
    "service readiness, workload availability, user journey and error-budget impact",
    "rollback revision, cleanup inventory and remaining dependent/finalizer state"
  ],
  "diagrams": [
    {"id": "LES-0041-DIA-001", "title": "Kubernetes API write path", "direction": "left-to-right", "boundaries": ["client", "API discovery", "authentication", "authorization", "admission", "validation", "etcd persistence", "watch delivery"], "evidencePoints": ["context", "identity", "verb/resource", "audit ID", "UID", "resourceVersion"], "textAlternative": "A client discovers an API and sends a request to the API server, which authenticates identity, authorizes the action, runs admission and validation, persists accepted state in etcd, and publishes the new resource version to watchers."},
    {"id": "LES-0041-DIA-002", "title": "Object contract", "direction": "hierarchical", "boundaries": ["type metadata", "object metadata", "spec", "status", "conditions", "field ownership"], "evidencePoints": ["apiVersion", "kind", "UID", "generation", "observedGeneration", "managedFields"], "textAlternative": "Type metadata selects an API schema; object metadata identifies an instance and its lifecycle; spec declares intent; controllers and node agents report observations through status and conditions while managed fields record field ownership."},
    {"id": "LES-0041-DIA-003", "title": "List-watch-reconcile loop", "direction": "cyclic", "boundaries": ["list snapshot", "resource version", "watch events", "work queue", "reconcile", "API write", "relist"], "evidencePoints": ["RV", "event type", "key", "retry", "generation", "condition"], "textAlternative": "A controller lists objects to establish current state and resource version, watches later changes, queues object keys, reads current state, performs idempotent reconciliation, writes status or children, and relists after watch expiry or compaction."},
    {"id": "LES-0041-DIA-004", "title": "Deployment ownership chain", "direction": "top-to-bottom", "boundaries": ["Deployment", "Deployment controller", "ReplicaSet", "ReplicaSet controller", "Pod"], "evidencePoints": ["selector", "template hash", "owner UID", "replicas", "available"], "textAlternative": "The Deployment controller creates and scales ReplicaSets; a ReplicaSet controller creates Pods. Owner references connect exact UIDs and enable garbage collection. The scheduler and kubelet act later on each Pod."},
    {"id": "LES-0041-DIA-005", "title": "Pod placement and execution", "direction": "left-to-right", "boundaries": ["unscheduled Pod", "scheduler queue", "filter", "score", "binding", "kubelet", "runtime", "status"], "evidencePoints": ["requests", "constraints", "reason", "nodeName", "container ID", "conditions"], "textAlternative": "The scheduler observes a Pod without nodeName, filters feasible nodes, scores them and records a binding. The selected node's kubelet asks the runtime to converge containers and reports Pod status through the API."},
    {"id": "LES-0041-DIA-006", "title": "Deletion with finalization", "direction": "left-to-right", "boundaries": ["delete request", "deletion timestamp", "finalizers", "controller cleanup", "finalizer removal", "object removal", "dependent collection"], "evidencePoints": ["UID precondition", "policy", "timestamp", "finalizer", "dependent owner"], "textAlternative": "Deletion can first set a deletion timestamp while finalizers remain. Responsible controllers complete external cleanup and remove only their finalizer; the API object is then removed and dependents follow the selected garbage-collection policy."}
  ],
  "commands": [
    {"id": "LES-0041-CMD-001", "question": "Which client, context, server and identity bound this cluster investigation?", "risk": "read-only", "command": "kubectl version; kubectl config current-context; kubectl auth whoami", "runFrom": "an approved normal-user shell with a dedicated local-cluster kubeconfig", "expectedBranches": [{"when": "client/server/context/identity match the lab manifest", "meaning": "cluster and caller boundary is known", "nextEvidence": "prove namespace and authorization"}, {"when": "context, server or identity differs", "meaning": "the blast radius is unapproved", "nextEvidence": "stop before any object request"}], "proves": "reported client/server/context/identity reachable through this kubeconfig", "doesNotProve": "cluster health, kubeconfig secrecy or authorization for later verbs"},
    {"id": "LES-0041-CMD-002", "question": "Can this identity perform only the required namespace actions?", "risk": "read-only", "command": "kubectl auth can-i create deployments.apps -n atlas-lab; kubectl auth can-i delete nodes", "runFrom": "the approved local cluster context", "expectedBranches": [{"when": "namespaced create is yes and node delete is no", "meaning": "the expected authorization boundary appears", "nextEvidence": "inspect API discovery"}, {"when": "cluster-scoped destructive action is allowed", "meaning": "identity is overprivileged", "nextEvidence": "stop and reduce RBAC"}], "proves": "authorization answers for exact identity, verb, resource and namespace", "doesNotProve": "admission acceptance or absence of other privileges"},
    {"id": "LES-0041-CMD-003", "question": "Which served API version and resource will accept this object?", "risk": "read-only", "command": "kubectl api-resources --api-group=apps -o wide; kubectl explain deployment.spec", "runFrom": "the approved local cluster", "expectedBranches": [{"when": "apps/v1 deployments and expected fields are served", "meaning": "discovery supports the manifest contract", "nextEvidence": "server-side dry-run"}, {"when": "resource/version is absent or deprecated", "meaning": "manifest is incompatible", "nextEvidence": "stop and migrate before apply"}], "proves": "current API discovery and OpenAPI-derived explanation", "doesNotProve": "admission success, controller health or safe values"},
    {"id": "LES-0041-CMD-004", "question": "Will the API accept, default and validate the proposed object without persisting it?", "risk": "mutating-bounded", "command": "kubectl apply --server-side --dry-run=server --field-manager=atlas-lesson -f deployment.yaml -o yaml", "runFrom": "the approved fixture directory and namespace", "expectedBranches": [{"when": "server returns the expected defaulted object", "meaning": "authentication, authorization, admission and schema validation accepted this dry request", "nextEvidence": "review scope/diff then persist"}, {"when": "forbidden, denied or invalid appears", "meaning": "an API boundary rejected the request", "nextEvidence": "fix that first causal boundary"}], "proves": "server-side dry-run response for exact request", "doesNotProve": "persistence, controller reconciliation, scheduling or runtime health", "cleanup": "verify the named object remains absent because server-side dry-run must not persist it"},
    {"id": "LES-0041-CMD-005", "question": "What exact object identity, desired generation and current observations exist?", "risk": "read-only", "command": "kubectl get deployment atlas-api -n atlas-lab -o yaml", "runFrom": "the approved local cluster", "expectedBranches": [{"when": "UID, generation, resourceVersion, spec and status are present", "meaning": "one current API snapshot is inspectable", "nextEvidence": "compare observedGeneration and conditions"}, {"when": "not found or unexpected UID appears", "meaning": "wrong namespace/name or recreated identity", "nextEvidence": "stop and bind the correct object"}], "proves": "one API-server representation at one resourceVersion", "doesNotProve": "a consistent multi-object snapshot or current user health"},
    {"id": "LES-0041-CMD-006", "question": "Has the Deployment controller observed the current desired generation?", "risk": "read-only", "command": "kubectl get deployment atlas-api -n atlas-lab -o jsonpath='{.metadata.generation}'; kubectl get deployment atlas-api -n atlas-lab -o jsonpath='{.status.observedGeneration}'; kubectl get deployment atlas-api -n atlas-lab -o jsonpath='{.status.conditions}'", "runFrom": "the approved local cluster", "expectedBranches": [{"when": "observedGeneration equals generation and conditions are healthy", "meaning": "controller status covers current intent", "nextEvidence": "trace owned ReplicaSet and Pods"}, {"when": "observedGeneration lags or condition reason is unhealthy", "meaning": "reconciliation is stalled or failing", "nextEvidence": "inspect controller events/logs and dependencies"}], "proves": "reported controller observation and conditions", "doesNotProve": "all Pods, service traffic or users are healthy"},
    {"id": "LES-0041-CMD-007", "question": "Can the reviewed intent be persisted under one explicit field manager?", "risk": "mutating-bounded", "command": "kubectl apply --server-side --field-manager=atlas-lesson -n atlas-lab -f deployment.yaml", "runFrom": "the dedicated disposable local cluster after dry-run review", "expectedBranches": [{"when": "one Deployment is created or configured", "meaning": "the API persisted the accepted desired object", "nextEvidence": "record UID, generation, resourceVersion and audit ID"}, {"when": "conflict, denial or validation failure appears", "meaning": "field ownership or policy rejected persistence", "nextEvidence": "stop without forcing conflicts"}], "proves": "accepted persistence of exact object fields for this manager", "doesNotProve": "controller, scheduler, kubelet or application convergence", "cleanup": "bash lab.sh cleanup-cluster"},
    {"id": "LES-0041-CMD-008", "question": "Which exact owners connect Deployment, ReplicaSet and Pod?", "risk": "read-only", "command": "kubectl get deployment,replicaset,pod -n atlas-lab -o custom-columns=KIND:.kind,NAME:.metadata.name,UID:.metadata.uid,OWNER_KIND:.metadata.ownerReferences[0].kind,OWNER_UID:.metadata.ownerReferences[0].uid,NODE:.spec.nodeName", "runFrom": "the approved namespace", "expectedBranches": [{"when": "Deployment owns ReplicaSet and ReplicaSet owns Pod by UID", "meaning": "the expected controller chain exists", "nextEvidence": "compare selectors, generations and status"}, {"when": "owner is absent or UID differs", "meaning": "object may be orphaned, adopted or recreated", "nextEvidence": "inspect full metadata before deletion"}], "proves": "reported ownership edges and placement fields", "doesNotProve": "controller intent, garbage-collection safety or workload health"},
    {"id": "LES-0041-CMD-009", "question": "What changed after a known resource version?", "risk": "read-only", "command": "kubectl get pods -n atlas-lab --watch-only --output-watch-events --resource-version=RESOURCE_VERSION", "runFrom": "a bounded terminal after first listing and recording resourceVersion", "expectedBranches": [{"when": "ADDED, MODIFIED, DELETED or BOOKMARK events advance versions", "meaning": "changes after the starting point are being delivered", "nextEvidence": "re-read current objects before acting"}, {"when": "too old resource version or stream closes", "meaning": "watch history is unavailable or connection ended", "nextEvidence": "relist and restart from returned version"}], "proves": "events delivered by that watch after the requested version", "doesNotProve": "a durable complete history or current multi-object state"},
    {"id": "LES-0041-CMD-010", "question": "Is a Pending Pod blocked before or after scheduling?", "risk": "read-only", "command": "kubectl get pod atlas-api-POD -n atlas-lab -o wide; kubectl describe pod atlas-api-POD -n atlas-lab; kubectl get events -n atlas-lab --sort-by=.metadata.creationTimestamp", "runFrom": "the approved namespace", "expectedBranches": [{"when": "nodeName is empty with FailedScheduling reason", "meaning": "scheduler placement is blocked", "nextEvidence": "inspect requests, constraints and feasible nodes"}, {"when": "nodeName exists with runtime/image/mount event", "meaning": "placement happened and node-side convergence is blocked", "nextEvidence": "inspect kubelet/runtime/storage evidence"}], "proves": "current Pod fields and retained events", "doesNotProve": "complete historical causality or component health"},
    {"id": "LES-0041-CMD-011", "question": "Are control-plane and node liveness observations current?", "risk": "read-only", "command": "kubectl get --raw='/readyz?verbose'; kubectl get nodes -o wide; kubectl get leases -A", "runFrom": "an approved cluster-operator context; local-cluster use only in this lesson", "expectedBranches": [{"when": "API readiness, node Ready and lease renewals are current", "meaning": "reported liveness paths are available", "nextEvidence": "inspect specific controller/scheduler queues"}, {"when": "readiness fails or lease is stale", "meaning": "control-plane or node heartbeat path is degraded", "nextEvidence": "contain changes and inspect component-specific logs/metrics"}], "proves": "reported readiness, node conditions and lease objects", "doesNotProve": "etcd recovery readiness, application health or every controller loop"},
    {"id": "LES-0041-CMD-012", "question": "Does the deterministic control-loop model exercise stall, diagnosis, recovery and cleanup?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "the LES-0041 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "the model's guarded lifecycle passed", "nextEvidence": "retain the explicit non-Kubernetes boundary"}, {"when": "first assertion fails", "meaning": "the model candidate is rejected", "nextEvidence": "preserve the first causal state/event artifact"}], "proves": "deterministic model behavior for exact code and run", "doesNotProve": "any Kubernetes API, component, cluster or learner mastery", "cleanup": "the verifier proves exact absence"}
  ],
  "labs": [
    {"id": "LES-0041-LAB-001", "title": "Guided deterministic object lifecycle and reconciliation model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; no Kubernetes binary or cluster", "timeMinutes": 180, "privilege": "normal user; wrapper refuses UID 0", "network": "none", "changes": ["one exact UID-scoped temporary directory", "deterministic JSON objects, audit events and controller queue state", "one injected stalled-controller state and recovery"], "abortConditions": ["root", "network", "kubectl use", "external process", "symlink", "wrong owner", "unknown fixture or state transition"], "recovery": "Preserve the first invalid state, reset only through the guarded model transition and rerun from a clean setup.", "cleanupProof": "Validate exact root, UID, sentinel, event hash, allowed inventory and absence of symlinks; remove the one exact directory and prove absence.", "path": "drafts/LES-0041-kubernetes-control-plane-reconciliation/support/lab"},
    {"id": "LES-0041-LAB-002", "title": "Independent local-cluster object-path transfer", "mode": "independent", "environment": "Reviewer-provisioned pinned disposable local Kubernetes cluster with dedicated kubeconfig and namespace", "timeMinutes": 240, "privilege": "normal user; namespace-scoped learner identity; reviewer owns cluster lifecycle", "network": "loopback/local cluster only; no cloud or external registry after approved image preload", "changes": ["one dedicated namespace", "one Deployment ownership chain", "one scheduler/controller fault", "watch and cleanup evidence"], "abortConditions": ["wrong context", "cluster-admin learner identity", "external endpoint", "image pull", "hostPath", "privileged workload", "cluster-scoped mutation", "unreviewed finalizer force-removal"], "recovery": "Stop new writes, preserve object/audit/component evidence, restore the fault through its owning component, reconcile or delete the namespace under reviewer control.", "cleanupProof": "Reviewer proves namespace objects, finalizers, dependents, kubeconfig and disposable cluster absent while unrelated host state remains.", "path": "drafts/LES-0041-kubernetes-control-plane-reconciliation/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0041-INC-001", "signal": "A Deployment generation increases but observedGeneration remains old.", "firstThought": "The responsible controller has not processed current intent or cannot report status.", "safePath": "Confirm object UID/generation, controller leader/queue/errors, API watch continuity and dependent objects; repair the controller path before editing status.", "trap": "Patch observedGeneration manually."},
    {"id": "LES-0041-INC-002", "signal": "A Pod is Pending with no nodeName.", "firstThought": "Scheduling has not produced a binding.", "safePath": "Read FailedScheduling events, requests, selectors, affinity, taints, topology and feasible-node capacity; change intent or capacity deliberately.", "trap": "Restart kubelet on random nodes."},
    {"id": "LES-0041-INC-003", "signal": "A Pod has nodeName but never becomes Ready.", "firstThought": "Scheduling completed; node-side runtime, image, mount, sandbox, process or readiness convergence is failing.", "safePath": "Inspect Pod conditions/events, node readiness/lease, kubelet/runtime and container state; keep scheduler diagnosis separate.", "trap": "Blame the scheduler because the Pod is Pending or not Ready."},
    {"id": "LES-0041-INC-004", "signal": "An object remains Terminating.", "firstThought": "A finalizer, dependent or unavailable cleanup controller is retaining it.", "safePath": "Read deletionTimestamp, finalizers, owner graph and responsible controller; repair cleanup or external dependency and remove only an owned finalizer with evidence.", "trap": "Delete finalizers blindly."},
    {"id": "LES-0041-INC-005", "signal": "Controllers and clients lose watches or report too-old resource versions.", "firstThought": "The watch window compacted, the API path is overloaded or clients are not relisting correctly.", "safePath": "Measure API/etcd health and client retry behavior; relist current state, restart watch from returned version and bound backoff.", "trap": "Assume missed watch events are a durable audit gap that can be replayed forever."}
  ],
  "assessmentIds": ["ASM-0106", "ASM-0107", "ASM-0108"],
  "referenceIds": ["REF-0373", "REF-0374", "REF-0375", "REF-0376", "REF-0377", "REF-0378", "REF-0379", "REF-0380", "REF-0381", "REF-0382", "REF-0383", "REF-0384", "REF-0385", "REF-0386", "REF-0387"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "No Kubernetes cluster or kubectl server interaction ran because Docker's Linux engine is unavailable and WSL access is denied.",
    "The deterministic model is concept rehearsal and cannot prove Kubernetes API, etcd, controller, scheduler, kubelet, runtime or network behavior.",
    "No cluster credential, cloud resource, external registry, privileged workload, host mount or production service is used.",
    "Formal technical/security/instructional/accessibility review, independent learner transfer and mastery evidence remain absent."
  ]
}
---

# Kubernetes control plane and reconciliation: follow an object from intent to running state

## What you see and first thought

You run `kubectl get pods` and see one Pod stuck in `Pending`. A weak response is “Kubernetes is not scheduling it.” A strong first thought is:

> Pending is a broad observation. First ask whether the Pod has a `spec.nodeName`. Empty means no binding yet; a node name means scheduling already happened and node-side convergence is now the likely boundary.

Kubernetes becomes understandable when you stop imagining it as one intelligent machine. It is a set of independent control loops communicating through an API and persisted objects.

```text
you declare intent
      |
      v
API server -> persisted object -> watch events
                                 |     |       |
                                 v     v       v
                           controller scheduler kubelet
                                 |     |       |
                                 +-- API writes-+
                                          |
                                          v
                                   observed status
```

The system is asynchronous. A successful `kubectl apply` means the API accepted and persisted a request. It does not mean a controller created children, the scheduler bound a Pod, the kubelet started containers, readiness passed, a Service has endpoints or users succeeded.

When an object looks stuck, place it on this path:

| Observation | First boundary | Evidence |
|---|---|---|
| `Forbidden` | authorization | identity, verb, group/resource, namespace, RBAC decision |
| admission denial | mutation/validation policy | webhook/plugin name, audit ID, denial message |
| generation rises, observedGeneration lags | controller reconciliation | controller leader, watches, queue, errors, children |
| Pod nodeName empty | scheduling | scheduler events, requests, constraints, feasible nodes |
| nodeName set, container waiting | kubelet/runtime | node condition/lease, Pod events, runtime/image/mount |
| Terminating persists | finalization/ownership | deletionTimestamp, finalizers, owner graph, cleanup controller |
| controllers lose watches | API/etcd/client watch path | resourceVersion, compaction, relist, API latency/flow control |

The memorable rule is:

> Read the object as a conversation between intent and observers. Metadata tells you identity and concurrency; spec tells you requested state; status and events tell you which loop has—and has not—made progress.

## Terms before commands

**Cluster.** A set of control-plane and node components cooperating through Kubernetes APIs. A managed service may hide control-plane hosts, but it does not remove API, persistence, controller or failure boundaries.

**Control plane.** Components that expose and reconcile cluster state: API server, etcd, scheduler, controller managers and related services. “Control plane healthy” is not one boolean; each dependency and loop has separate health.

**API server.** The front door for Kubernetes API requests. It handles discovery, authentication, authorization, admission, schema/defaulting/validation, persistence coordination and watch delivery. Other core components normally communicate through the API rather than writing etcd directly.

**etcd.** A consistent distributed key-value store used for Kubernetes API data. It is control-plane state, not application volume storage. Quorum, latency, database growth, compaction, defragmentation, encryption and backup/restore matter. Never treat an etcd snapshot as a complete application backup.

**Object.** A versioned API resource instance, such as a Deployment, Pod, Node or Lease. Its type is group/version/kind; its REST identity is group/version/resource, namespace and name.

**apiVersion and kind.** `apiVersion` selects API group/version; `kind` names the schema kind. Resources can be served at several versions while storage uses another version. Deprecation and conversion make version awareness an operational requirement.

**metadata.name and namespace.** Human-facing object location. Names are usually unique for a resource type in a namespace. Some resources, such as Nodes, are cluster-scoped. Namespace is an API scope, not automatically a hard security or network boundary.

**UID.** Server-assigned identity for one object lifetime. Delete and recreate the same name and the UID changes. Owner references use UIDs so a new object with an old name is not silently the old owner.

**resourceVersion.** An opaque concurrency and change-tracking token associated with persisted state. Clients use it for watches and conditional updates. Do not parse it as time or assume numeric meaning across systems.

**generation.** A sequence representing changes to desired-state fields, commonly `spec`. Exact behavior is resource-specific. Controllers often copy the latest processed generation into `status.observedGeneration`.

**observedGeneration.** A controller's statement about which desired generation its status describes. A healthy-looking condition attached to an old observed generation may be stale.

**spec.** Desired state accepted by the resource schema. Not every object has the same spec semantics, and some API resources are primarily observations.

**status.** Current observations written by authorized controllers or agents, often through a status subresource. Status is not desired configuration. Users should not patch it to make dashboards green.

**condition.** A typed observation with status, reason, message, transition time and often observed generation. Conditions are more useful than one phase string, but their semantics belong to the API type.

**Controller.** A control loop that watches desired/current objects and acts to reduce difference. It should be level-triggered: reading current state must be enough to decide, even if individual watch events were missed.

**Reconciliation.** Compare desired and observed state, take idempotent action, and report status. It is asynchronous and repeated. “Eventually consistent” does not mean “eventually correct regardless of broken dependencies.”

**Watch.** A stream of changes after a resource version. Watches reduce polling but are not durable audit logs. Connections end, versions compact and clients must relist.

**Informer/cache/work queue.** Common controller machinery: list/watch populates a local cache; event handlers enqueue object keys; workers read current state and reconcile; failures are retried with backoff. Cached data can lag.

**Controller manager.** A process hosting many built-in controllers. Only an elected leader should actively run a given replicated controller-manager instance.

**Scheduler.** Watches for Pods lacking `spec.nodeName`, filters feasible nodes, scores candidates and records a binding. It does not start containers.

**Kubelet.** Node agent that observes Pods assigned to its node and works through the container runtime and other plugins to realize them. It reports Pod and Node observations to the API.

**Container runtime and CRI.** The runtime executes containers and sandboxes; kubelet calls it through the Container Runtime Interface. Kubernetes removed the old dockershim integration; Docker-built OCI images can still run through compliant runtimes.

**CNI, CSI and kube-proxy.** Adjacent plugin/agent boundaries for networking, storage and Service implementation. They matter later, but do not collapse into “the kubelet.”

**Owner reference.** Metadata pointing from a dependent to an owner's group/version/kind/name/UID. One owner reference may be marked controller. Garbage collection uses ownership, not labels alone.

**Finalizer.** A key preventing final object removal until responsible cleanup finishes. A delete request sets `deletionTimestamp`; controllers remove only finalizers they own after cleanup.

**Field manager and managedFields.** Server-side apply tracks which manager owns fields. A conflict is useful evidence that two actors claim the same field. `--force-conflicts` transfers ownership and can overwrite another manager; it requires review.

**Lease.** A lightweight object used for node heartbeats and leader election. A current Lease supports a liveness claim for that mechanism, not full component correctness.

**Event.** A best-effort, limited-retention API object describing something noteworthy. Events help diagnosis but are not a complete audit trail and may be aggregated.

## Architecture map

```text
CLIENT
  |
  | HTTPS request + credentials + object
  v
+-------------------- kube-apiserver --------------------+
| discovery -> authentication -> authorization            |
| -> mutating admission -> validation -> validating       |
| admission -> persistence -> response/watch              |
+--------------------------+------------------------------+
                           |
                           v
                     etcd quorum/state
                           |
              list/watch via API server
       +-------------------+------------------+
       |                   |                  |
       v                   v                  v
 controller manager     scheduler          kubelet
 creates/updates        binds Pods         runs assigned Pods
       |                   |                  |
       +-------------------+------------------+
                           |
                           v
                  API status and events
```

### API server is the coordination boundary

The API server is not merely a YAML upload endpoint. It defines concurrency, schema, authorization and extension boundaries. Clients discover served resources, send REST requests and receive representations. API server replicas can scale horizontally because durable API state lives in etcd; caches and in-flight work still create operational limits.

Admission runs after authentication and authorization but before persistence. Mutating admission may default or alter an object; validation then checks the resulting form; validating admission may allow or deny. A dry-run request can exercise server processing without persistence only where participating admission supports dry run safely.

### etcd is necessary but not sufficient

If etcd loses quorum, the API cannot safely persist changes. Slow commits raise API write latency and stall reconciliation. Yet an etcd member being reachable does not prove API availability, controller progress or workload health. Backup must capture a supported snapshot, encryption material and restoration procedure, then be rehearsed. Application databases and volumes need separate protection.

### Controllers do not issue remote commands to “fix servers”

A Deployment controller reads Deployment and ReplicaSet objects and writes desired ReplicaSet state. A ReplicaSet controller creates/deletes Pods. The scheduler binds unscheduled Pods. The kubelet on the selected node realizes containers. Each loop observes through the API and records results. This decoupling gives retries and recovery but produces intermediate states that operators must interpret.

### Nodes are autonomous failure domains

Each Node object describes identity, capacity, allocatable resources, conditions and addresses. Kubelet renews a Lease more frequently than full Node status. The node controller interprets missing heartbeats and may mark status unknown, add taints and eventually drive Pod eviction according to policy. Network partitions create uncertainty: a workload may still run while the control plane cannot observe it.

### High availability is multiple quorum and leadership problems

API servers can be load balanced, etcd requires quorum, controller managers and schedulers use leader election, and nodes operate independently. Three control-plane hosts do not guarantee resilience if all share one power domain, load balancer, certificate failure or etcd latency bottleneck. Map failure domains and test failover.

## Request or state path

Follow one `kubectl apply -f deployment.yaml`.

**1. Client chooses a cluster.** Kubeconfig merges clusters, users and contexts. Current context supplies server, credentials and default namespace unless flags override them. Bind the exact kubeconfig and context before mutation; a familiar namespace name can exist in many clusters.

**2. Discovery maps type.** The client discovers served API groups/resources and schema information. `apps/v1 Deployment` maps to a namespaced `deployments` resource. Discovery can be cached, so version skew and stale cache are possible.

**3. Request reaches HTTPS endpoint.** TLS authenticates the server and protects transport. Proxies/load balancers may sit in the path. A timeout does not prove the request was not persisted; use audit ID, conditional reads and object identity before retry.

**4. Authentication establishes user.** Certificates, tokens or other configured mechanisms establish user and groups. Service accounts authenticate workloads. Authentication answers “who”; it does not answer “may they do this?”

**5. Authorization evaluates attributes.** The authorizer evaluates verb, API group, resource/subresource, namespace and name (or non-resource URL). RBAC is common, but other modes exist. `kubectl auth can-i` is a targeted query, not proof of least privilege across every verb/resource.

**6. Admission and validation run.** Mutating admission can add defaults or sidecars; schema/defaulting/validation checks the object; validating admission can reject policy violations. Webhooks introduce network, certificate, latency and failure-policy dependencies. Record which admission changed or rejected the request.

**7. Persistence assigns concurrency metadata.** The API server writes accepted state to etcd. New objects receive UID and resourceVersion. Updates use concurrency rules; server-side apply calculates field ownership and can report conflicts. The response proves accepted persistence, not downstream convergence.

**8. Watches deliver change.** Deployment controllers receive or eventually discover the object via list/watch. A correct controller does not depend on seeing every event; it uses an event as a prompt to reread current state.

**9. Deployment controller reconciles.** It compares desired rollout state with ReplicaSets, creates a new ReplicaSet when the Pod template changes, and adjusts replica counts. It records Deployment status/conditions and observed generation.

**10. ReplicaSet controller creates Pods.** Each Pod gets an owner reference to the ReplicaSet UID. Labels and selector connect membership, while owner reference connects lifecycle ownership. Bad overlapping selectors can create adoption surprises.

**11. Scheduler binds each Pod.** It observes Pods without nodeName, checks requests and constraints against nodes, filters, scores and writes a binding. The chosen nodeName is the decisive boundary. Scheduling success does not create containers.

**12. Kubelet converges on the node.** It observes the assigned Pod, prepares sandbox/network/volumes, asks the runtime to pull or use images and start containers, runs probes and reports status. Failures appear as container states, conditions and events.

**13. Higher layers decide availability.** A Deployment may report available replicas after readiness conditions and timing rules. A Service selector/EndpointSlice path and actual user traffic add further boundaries. Never end the trace at `Running`.

## Failure zoom

### API write timeout: unknown outcome

A client timeout means the response was not received. The request may have failed before persistence, succeeded but lost its response, or be delayed. Retrying a create with generated names or non-idempotent admission can duplicate intent. Read by deterministic name, UID expectations and audit ID. Use idempotent apply/conditional operations.

### Generation advances but controller does not

If metadata generation is 12 and status observedGeneration is 10, status may describe old intent. Check:

- the object UID was not recreated;
- the responsible controller has a current leader Lease;
- list/watch is healthy and resource type served;
- work queue depth/retries/errors;
- API write authorization and rate limiting;
- child objects and conflicts;
- controller logs tied to namespace/name/UID.

Do not patch status. Restore the observing loop.

### Pending before scheduling

Empty nodeName plus `FailedScheduling` means no binding. Read the scheduler's reason. Typical constraints include insufficient requested CPU/memory, node selectors, required affinity, taints without tolerations, topology spread, volume topology or extended resources. Usage metrics do not decide placement; requests and constraints do.

### Bound but not running

With nodeName set, move to node path: Node Ready and Lease, kubelet, runtime, image credentials, sandbox/CNI, mounts/CSI, security context and container state. Restarting scheduler is irrelevant. A Pod phase alone compresses detail; read conditions and containerStatuses.

### Terminating is a cleanup workflow

Deletion with a timestamp and finalizers is not necessarily stuck. Identify each finalizer's owner and external obligation. If the controller is gone, restore it when possible. Removing a finalizer manually can leak cloud resources, storage, DNS or other dependents. Use UID preconditions and a documented exceptional recovery.

### Watch failures are expected; retry storms are not

Watches close for network changes, server timeouts or compaction. Robust clients relist and restart from a current version with backoff. A controller that reconnects from an ancient version forever can overload the API. A controller that treats events as commands can miss state. Measure watch duration, relists, 410 responses, queue depth and reconcile latency.

## Internals and state ownership

### List then watch

A controller first lists a collection and receives objects plus a collection resourceVersion. It then watches changes after that point. This closes the conceptual gap between initial snapshot and later events. When the requested history is too old, the server may return HTTP 410 Gone; the client must relist.

Watch events normally include `ADDED`, `MODIFIED`, `DELETED`, and optionally `BOOKMARK` or error forms. They signal that cached knowledge may change. Always reconcile from current state.

### Optimistic concurrency

Two clients may read the same resourceVersion and attempt incompatible updates. APIs use resource versions and patch/apply semantics to prevent silent lost updates. On conflict, reread, recompute and retry with bounds. Do not fetch once then retry the same stale full-object update indefinitely.

### Server-side apply and field ownership

Server-side apply sends declarative intent with a field manager. The API tracks field ownership in `managedFields`. When another manager owns a field and your desired value conflicts, the API can reject rather than silently steal it. Treat conflict as an ownership-design signal. Separate controllers should own separate fields or resources.

`--force-conflicts` intentionally transfers field ownership. It is not a generic error-recovery flag.

### Reconcile current levels, not event edges

A correct loop resembles:

```text
key arrives
  -> read desired object
  -> read owned dependents/external observation
  -> if deleting: finalize owned external state
  -> else calculate desired children/actions
  -> perform idempotent changes
  -> write status for the observed generation
  -> retry transient failures with bounded backoff
```

If the same key appears ten times, one current reconciliation can be enough. Work queues commonly coalesce keys. Status writes themselves can generate events, so controllers must avoid writing identical status repeatedly.

### Ownership and garbage collection

Owner references form lifecycle edges using exact UID. Foreground deletion can hold the owner while dependents are removed; background deletion can remove the owner and let garbage collection remove dependents asynchronously; orphan policy removes ownership links and retains dependents. Scope rules constrain valid owner relationships. Inspect propagation policy before deletion.

Labels select and group; they do not replace owner UIDs. A ReplicaSet selector may match a Pod, but owner reference identifies controller ownership.

### Finalizers split intent from completion

Once deletionTimestamp is set, normal mutation becomes constrained and the object awaits finalizers. Each controller completes its cleanup and removes its own key. Finalizers are unordered shared state, so designs must not assume a global cleanup sequence without separate coordination.

### Status is an API, not a log

Status should summarize current observation with stable condition types/reasons, observed generation and useful identifiers. Events and logs carry episodic detail. Large or rapidly changing status burdens etcd and API watches. Controllers should patch only owned status fields and avoid hot loops.

### Leader election prevents duplicate active loops, not every duplicate side effect

Scheduler and controller-manager replicas use Leases for leader election. During transition, old and new leaders may briefly overlap in uncertainty. Reconciliation and external operations must remain idempotent. Leader election is not a substitute for external idempotency keys.

### Scheduler and kubelet own different writes

The scheduler owns placement/binding. Kubelet owns node-local execution observations and Pod status. Controllers own higher-level children and status. Humans or GitOps managers own reviewed spec fields. Keeping these boundaries visible prevents “fixes” such as manually setting nodeName or editing controller status.

## Evidence table

| Question | Primary evidence | Healthy interpretation | Unsafe interpretation |
|---|---|---|---|
| Which cluster and caller? | server URL/version, context, auth identity | exact approved local cluster and user | namespace name alone proves safety |
| Is action allowed? | SubjectAccessReview / `auth can-i` | exact verb/resource/scope decision | one yes means least privilege |
| Is API served? | discovery and OpenAPI schema | intended group/version/resource available | manifest file implies server support |
| Was request accepted? | API response, audit ID, UID/resourceVersion | exact request persisted or dry-run accepted | apply output means workload ready |
| Which intent is current? | UID, spec, generation, manager | desired object identity and revision bound | name alone identifies one lifetime |
| Has controller processed it? | observedGeneration, conditions, children, controller metrics | status describes current generation | Available from an old generation is current |
| Was Pod scheduled? | spec.nodeName and scheduler event | binding exists or exact reason blocks it | Pending always means scheduler |
| Is node path alive? | Node conditions, Lease, kubelet/runtime evidence | current heartbeat and node observations | Ready means every Pod works |
| Did container start? | containerStatuses, runtime ID, events | node agent/runtime advanced | Running means ready and correct |
| Is ownership sound? | ownerReference UID and controller flag | exact owner chain | labels are lifecycle ownership |
| Why is deletion pending? | deletionTimestamp, finalizers, dependents | known cleanup is in progress | finalizer is garbage to remove |
| Is watch current? | list RV, watch RV, bookmarks/relist | client can rebuild current cache | event stream is durable history |
| Is API saturated? | latency/errors/inflight/APF/etcd metrics | bounded demand and healthy persistence | controllers are simply slow |
| Are users healthy? | Service endpoints, request golden signals, journey | workload outcome meets objective | Kubernetes object status proves business success |

Evidence has time and scope. A `kubectl get` response is one API snapshot, not a distributed transaction across all resources. Events expire and may aggregate. Cached controller observations lag. Tie every artifact to cluster, namespace, name, UID, resourceVersion and UTC time.

Prefer structured output:

```bash
kubectl get pod example -n atlas-lab -o json > pod.json
```

Then extract exact fields with a reviewed query. Do not depend on column layout, color or a screenshot when machine evidence is needed. Sanitize tokens, annotations, environment values and Secrets before sharing.

## Command decoders

### `kubectl version`

The client version tells you which command behavior and serializers are in use; server version identifies the reached API server. Compatibility has a supported skew policy, not an assumption that all versions interoperate. A server response proves an API path exists now; it does not prove all control-plane components share that version or are healthy.

### `kubectl config current-context`

A context references a cluster, user and optional namespace. Inspect the resolved server and identity source, not just context name:

```bash
kubectl config view --minify --raw=false
```

Keep `--raw=false`; raw output can expose credential material. Environment variables and `--kubeconfig` may select different files. Automation should use a dedicated kubeconfig path and fail closed on an unexpected server fingerprint.

### `kubectl auth can-i`

This sends or simulates an authorization review for a precise action. Include namespace and resource subresource where relevant:

```bash
kubectl auth can-i update deployments/scale -n atlas-lab
```

An answer can depend on current RBAC and impersonation permissions. Test required positive actions and dangerous negative actions. A finite list cannot prove no other privilege exists; enumerate and review policy separately.

### `kubectl api-resources` and `kubectl explain`

Discovery lists resource names, API groups, namespaced scope, kinds and verbs. `explain` uses the server schema known to the client. These are compatibility evidence. They do not prove admission acceptance or semantic safety. Use explicit `apiVersion` in manifests and track deprecations before cluster upgrades.

### Server-side dry run

```bash
kubectl apply --server-side --dry-run=server +  --field-manager=atlas-lesson -f deployment.yaml -o yaml
```

The API runs much of the normal request path without persistence and returns defaulted/mutated representation. Admission webhooks must correctly declare dry-run behavior. External side effects from broken admission implementations are still a risk. Diff the response with reviewed intent and protect secret output.

### `kubectl get -o yaml/json`

Read:

- `metadata.uid`: one lifetime;
- `metadata.resourceVersion`: concurrency/watch token;
- `metadata.generation`: desired revision where supported;
- `metadata.managedFields`: field manager ownership;
- `spec`: requested state;
- `status.observedGeneration`: controller coverage;
- `status.conditions`: typed observations;
- `deletionTimestamp/finalizers`: deletion workflow.

`managedFields` can be large. Query only what you need, but retain the full sanitized object for complex ownership incidents.

### `kubectl describe`

Describe combines selected object fields and related events into human-oriented output. It is excellent orientation and poor canonical machine data. Events are bounded-retention, timestamps can represent first/last occurrence, and sorting does not create causal proof. Confirm hypotheses with object JSON, audit, component logs and metrics.

### Watch commands

A proper watcher lists first, records collection resourceVersion and watches from it. `kubectl get --watch` is useful observation but a terminal session closing does not mean the controller missed permanent truth. Handle `410 Gone` by relisting. Bound watch time in scripts and avoid thousands of independent watchers where shared informers can serve many reconcilers.

### `kubectl get events --sort-by`

Sorting by creation timestamp makes reading easier. Events can be updated/aggregated, clocks differ and retention is limited. Use involved object UID, reason, reporting controller and series/count. Never use events instead of audit logs for security attribution.

### `kubectl get --raw='/readyz?verbose'`

This addresses an API server health endpoint through current credentials. Output can identify failing checks, but authorization and endpoint behavior vary. One replica's readiness behind a load balancer may not represent every replica. Pair with request metrics, load-balancer targets and etcd health.

### Node and Lease

`kubectl get nodes` displays summarized conditions. Full Node JSON contains condition transition/heartbeat data, capacity and allocatable. Node Lease renew time is a frequent heartbeat. A current Lease plus `Ready=True` still does not prove image pulls, disks, CNI, CSI or a particular container are healthy.

## Decision path

```text
START: object does not converge
 |
 +-- Exact cluster, identity, namespace, name and UID known?
 |      no -> stop; bind context and object lifetime
 |      yes
 |
 +-- Request rejected?
 |      authn -> identity/credential path
 |      authz -> verb/resource/scope/RBAC path
 |      admission/schema -> policy/default/validation path
 |      timeout -> outcome unknown; read/audit before retry
 |      accepted
 |
 +-- generation == observedGeneration?
 |      no -> responsible controller/watch/queue/write path
 |      yes
 |
 +-- expected dependent objects exist with owner UIDs?
 |      no -> controller/selector/ownership path
 |      yes
 |
 +-- Pod has nodeName?
 |      no -> scheduler constraints/capacity path
 |      yes
 |
 +-- node/kubelet/runtime advanced container state?
 |      no -> node lease, kubelet, runtime, image, network, volume
 |      yes
 |
 +-- readiness, Service endpoints and user journey healthy?
        no -> workload/network/dependency/application path
        yes -> convergence succeeded; verify steady state
```

For Terminating objects, branch before ordinary reconcile diagnosis: inspect deletion timestamp, grace period, finalizers, owner/dependent graph and responsible cleanup controller. For API-wide symptoms, contain writes and inspect API latency/errors, priority/fairness, admission latency and etcd quorum before blaming every workload controller.

Recovery follows ownership. Repair the component or desired object that owns the failing state. Do not edit status, nodeName, managed children or finalizers merely because those fields reveal the symptom.

## Guided Ubuntu lab

The current guided lab is a deterministic teaching model, not a Kubernetes cluster. That limitation is intentional and printed by every run. It lets you rehearse the object state machine while Docker and WSL are unavailable; promotion still requires an actual pinned local cluster.

### Modeled boundaries

```text
client request -> API validation/persistence -> Deployment queue
-> ReplicaSet creation -> Pod creation -> scheduler binding
-> kubelet report -> Deployment observedGeneration/Available
```

Every state transition increments an opaque model resource version, appends an audit/event record and validates invariants. The model refuses out-of-order steps, unknown actors, UID changes, manual status edits, external paths, root and network.

### Step 1: understand the limitation

```bash
cd drafts/LES-0041-kubernetes-control-plane-reconciliation/support/lab
sed -n '1,240p' README.md
bash lab.sh doctor
```

Expected output includes `runtime=kubernetes-model-only`. If you need real cluster evidence, stop and provision the separately reviewed local-cluster lab; do not relabel model output.

### Step 2: create exact state

```bash
bash lab.sh setup
bash lab.sh status
```

Setup creates one UID-scoped root under `/tmp`, copies fixed input and creates a sentinel. It does not create Kubernetes processes, sockets, namespaces or containers.

### Step 3: submit intent

```bash
bash lab.sh submit
bash lab.sh inspect
```

Submission records a Deployment-like object with UID, generation 1, resourceVersion and spec replicas 2. Status observed generation remains 0. Explain why API acceptance and desired state are not convergence.

### Step 4: run controller and scheduler loops

```bash
bash lab.sh reconcile
bash lab.sh schedule
bash lab.sh inspect
```

Reconcile creates one ReplicaSet-like object and two Pod-like objects with exact owner UIDs. Schedule binds each Pod to a modeled feasible node. Trace every owner and show where nodeName first appears.

### Step 5: node convergence and availability

```bash
bash lab.sh kubelet
bash lab.sh inspect
```

The kubelet step changes assigned Pods to Ready and reports runtime IDs. A controller status pass then advances observed generation and available replicas. The model deliberately requires this extra controller observation.

### Step 6: inject a stalled controller

```bash
bash lab.sh update
bash lab.sh inject-controller-stall
bash lab.sh diagnose
```

Generation advances to 2 while observedGeneration remains 1 and controller queue contains the object. Diagnose from the object and queue, not from a memorized error string. The scheduler and kubelet cannot create the missing ReplicaSet generation.

### Step 7: recover the owner

```bash
bash lab.sh recover
bash lab.sh verify-state
```

Recovery restores controller processing, reconciles the new generation and re-establishes matching observed generation and ready replicas. The verifier checks UID continuity and resource-version monotonicity.

### Step 8: full verifier and cleanup

```bash
bash verify.sh
```

The verifier checks syntax, fixture digest, setup idempotence, invalid transition refusals, full lifecycle, stalled state, diagnosis, recovery, unexpected-entry cleanup refusal and final absence. These are model invariants only.

## Production transfer

### Local cluster before managed cluster

Use a pinned, disposable local cluster to observe real API behavior before cloud-specific layers. Record:

- Kubernetes server and client versions;
- cluster tool and node image digests;
- container runtime and CNI;
- API endpoint and dedicated kubeconfig;
- preload image digests so no external pull occurs;
- namespace and RBAC boundaries;
- host CPU/memory/disk budgets;
- deterministic teardown.

A local cluster proves real Kubernetes semantics within its implementation. It does not prove managed control-plane behavior, multi-zone etcd, cloud load balancers, CSI, IAM integration or production scale.

### Manifest delivery

Store declarative objects in Git, validate schema/policy, render packaging separately, perform server-side dry-run, diff exact live ownership and apply through one field manager. Promote immutable image digests. Avoid a pipeline that both patches and applies the same fields through several tools.

Use server-side apply conflicts to discover ownership overlap. Define managers such as:

```text
platform-bootstrap -> namespace baseline and quotas
application-delivery -> Deployment/Service application fields
autoscaler -> scale subresource
controllers -> status and owned children
operators -> custom-resource children and status
```

This is conceptual; exact managed fields depend on schemas and manager behavior. Review before forcing ownership.

### Control-plane observability

Monitor at least:

- API requests by verb/resource/code, latency and inflight;
- authentication/authorization/admission rejection and latency;
- API Priority and Fairness queues/rejections;
- etcd leader, quorum, request/commit/apply latency, database size and alarms;
- scheduler pending queue, attempts, plugin latency and unschedulable reasons;
- controller work queues, retries, reconcile duration/errors and leader changes;
- node Ready/Lease freshness and kubelet/runtime errors;
- object-state metrics such as unavailable replicas and stuck finalizers;
- audit correlation for mutating requests.

Cardinality matters. Namespace/name/UID on every metric can overwhelm telemetry. Keep high-cardinality identity in logs/traces/audit and use bounded dimensions in metrics.

### API availability and fairness

An overloaded API can starve controllers, creating cluster-wide convergence lag. API Priority and Fairness classifies requests into priority levels and flow schemas, queues bounded concurrency and can reject excess demand. Misconfiguration can privilege noisy automation over critical controllers.

Protect:

- system and leader-election traffic;
- node heartbeats;
- controller list/watch;
- interactive break-glass diagnosis;
- batch automation with bounded client rate and backoff.

Do not solve API overload by adding aggressive client retries. Retry storms amplify it.

### etcd operations

Run an odd-numbered quorum across independent failure domains where architecture supports it. Protect peer/client certificates and encryption keys. Monitor space quota and alarms. Compaction removes old history; defragmentation reclaims backend file space but is an operational action with latency consequence. Use supported snapshot tooling, validate snapshot status, store encrypted copies off the failure domain and rehearse restoration of the control plane.

Restoring etcd rewinds API state. Nodes and external systems may have progressed. Recovery must reconcile certificates, encryption configuration, admission dependencies, controllers, leases, workloads, cloud resources and application data. Define control-plane RPO/RTO separately from application RPO/RTO.

### Controller design

Custom or platform controllers should:

- watch narrowly and share informers;
- reconcile from current state;
- use deterministic names and owner references;
- perform idempotent external operations with stable idempotency keys;
- bound concurrency and retries;
- distinguish terminal invalid spec from transient dependency failure;
- update status/conditions only when meaning changes;
- honor deletion and remove only their finalizer;
- expose queue, retry, reconcile and external-call metrics;
- support versioned schema migration.

Test lost responses, duplicate events, watch restart, leader transition, stale cache, partial external success, finalization interruption and API conflict.

### Safe troubleshooting

Use namespace-scoped read-only identity first. Capture object JSON and relevant events. Escalate to component logs/metrics only as needed. `kubectl exec`, ephemeral containers, node debug and direct runtime tools cross stronger boundaries; require authorization, audit, containment and cleanup.

Never edit etcd directly. Never delete/recreate control-plane state as an exploratory step. Never force-delete stateful Pods or remove finalizers until external/data consequences are understood.

## Reliability, security, observability, capacity, and cost

### Reliability

Kubernetes reliability is control-loop latency plus workload outcome. Define objectives for API read/write availability, admission latency, scheduling latency, controller convergence, node heartbeat detection and workload rollout—not only API process uptime.

Design for partial failure:

- API response loss after persistence;
- controller leader transition;
- etcd member or zone failure;
- node partition while workloads continue;
- admission dependency outage;
- registry/image pull outage;
- CNI/CSI degradation;
- watch compaction and client relist.

Reconciliation reduces manual repair only when desired state is safe, controllers are idempotent and ownership is clear. It can also automate a bad specification across the fleet.

### Security

Every request passes identity, authorization and admission boundaries. Apply least privilege:

- short-lived credentials and workload identity;
- dedicated kubeconfigs, strict file modes and no shared admin context;
- namespace-scoped roles where possible;
- separate read, deploy and cluster-admin duties;
- admission policies for privileged workloads, host namespaces/mounts and image provenance;
- API audit with protected retention;
- encryption at rest with controlled keys;
- NetworkPolicy and runtime hardening in later chapters;
- restricted controller service accounts and external credentials.

`kubectl get -o yaml` can expose annotations, environment references and Secret data. Kubernetes Secrets are base64-encoded API objects, not automatically encrypted end to end. Treat output and etcd backups as sensitive.

### Observability

Correlate:

```text
change revision -> field manager -> API audit ID
-> object UID/generation/resourceVersion
-> controller reconcile and child UIDs
-> scheduler decision and node
-> kubelet/runtime/container identity
-> service endpoint revision
-> user request outcome
```

Use conditions for current semantics, events for bounded human clues, logs for detailed execution, metrics for trends and audit for API attribution. No single stream replaces the others.

Detect silent stalls:

- age of generation minus observedGeneration match;
- oldest controller queue item;
- unscheduled Pod age by reason;
- terminating object age by finalizer;
- stale Node Lease;
- unavailable desired replicas;
- watch relist/410 rate;
- API error/latency by priority.

### Capacity

Cluster capacity includes API/etcd/control-loop capacity and node workload capacity. Object count, watch fan-out, event churn, large Secrets/ConfigMaps, rapid status writes and abusive list requests load the control plane. Pod count and scheduling constraints load scheduler and kubelets.

Clients should paginate large lists, use watches, share caches, specify resource versions correctly and bound QPS/burst. Controllers should not relist the world on every event. Adding API replicas cannot compensate for slow etcd or admission.

Node allocatable is capacity after system reservations, not raw machine capacity. Scheduler uses requests and constraints, not live utilization, for normal placement. Later workload chapters cover requests, limits, eviction and autoscaling.

### Cost

Managed control planes, worker nodes, load balancers, storage, telemetry, image traffic and idle redundancy cost money. Local clusters reduce learning cost but not production requirements. Overly many tiny clusters increase upgrade, policy and observability toil; one huge cluster increases blast radius and multi-tenancy complexity.

Choose cluster boundaries from trust, failure domain, regulatory, scale and organizational ownership. Cost optimization must preserve quorum, availability, capacity headroom and recovery evidence.

## Traps and prevention

| Trap | Failure | Prevention |
|---|---|---|
| Treat Kubernetes as one daemon | wrong component is restarted/debugged | place symptom on API/controller/scheduler/node path |
| Trust `apply configured` | persistence is confused with convergence | follow generation, owners, placement, readiness and users |
| Use object name as identity | delete/recreate lifetime is missed | bind namespace/name and UID |
| Parse resourceVersion as timestamp | relies on opaque implementation | use only documented concurrency/watch semantics |
| Treat events as durable audit | retention/aggregation loses history | use audit/logs and persistent telemetry |
| Patch status manually | hides broken observer | repair responsible controller |
| Set nodeName manually | bypasses scheduler policy | fix requests/constraints/capacity |
| Delete Pending Pods repeatedly | recreates same unsatisfied intent | diagnose scheduler reason |
| Remove finalizers blindly | leaks external resources/data | restore owner and complete cleanup |
| Force server-side conflicts | steals another manager's fields | redesign ownership or approve transfer |
| Retry API timeout blindly | duplicates unknown-outcome operation | read object/audit and use idempotent identity |
| Watch without relist | misses compacted history | list, watch, handle 410 and backoff |
| Full-list poll rapidly | overloads API/etcd | paginate, watch and share caches |
| Give CI cluster-admin | compromise becomes cluster compromise | narrow namespace/verb/resource identity |
| Store admin kubeconfig in repo | leaks durable authority | external short-lived credentials and strict storage |
| Equate Ready node with healthy workload | hides runtime/plugin/app failure | inspect Pod and user path |
| Back up etcd only | application data remains unprotected | separate control-plane and data recovery |
| Test only happy reconciliation | duplicate/partial/watch failures remain | inject lost responses, conflicts and leader changes |

### Force is a last-resort data decision

`kubectl delete --force --grace-period=0`, finalizer removal and field-conflict forcing change safety semantics. Before using them, state:

- which identity and object lifetime;
- which controller/agent is unavailable;
- whether process or external resource may still exist;
- data consistency consequence;
- owner/dependent graph;
- rollback or forward-recovery path;
- approval and audit;
- post-action reconciliation and user validation.

Force is not “make Kubernetes try harder.”

### YAML is not the system

A manifest is client intent. The server defaults and mutates it; controllers create children; managers own fields; status evolves. Store manifests, but diagnose live API objects and their ownership. Do not edit generated ReplicaSets or Pods when a Deployment owns them; change the owning template.

## Memory card and retrieval

Remember **A-C-S-K-U**:

```text
A - API accepts and persists intent
C - Controllers create and reconcile owned state
S - Scheduler selects and binds a node
K - Kubelet and runtime converge the assigned Pod
U - User-facing checks prove the outcome
```

Remember metadata:

```text
name      = human location
UID       = one lifetime
RV        = opaque concurrency/watch token
generation = desired-state revision
observedGeneration = controller coverage
ownerReferences = lifecycle graph
finalizers = deletion obligations
managedFields = field ownership
```

Fast diagnosis:

```text
request rejected? -> authn/authz/admission/schema
accepted but generation unobserved? -> controller
children absent/wrong? -> owner controller
Pod no nodeName? -> scheduler
nodeName set? -> kubelet/runtime/plugins/app
Terminating? -> finalizer/dependents
all green? -> verify Service and users
```

Retrieval questions:

1. Why can apply succeed while no Pod exists?
2. Why is UID more trustworthy than name for ownership?
3. What does observedGeneration protect you from assuming?
4. Why must a controller relist after an old resourceVersion?
5. Which component sets nodeName, and which starts containers?
6. Why can removing a finalizer lose external resources?
7. Why does etcd backup not restore application data?

## Complete answers

### What happens after `kubectl apply`?

The client selects a context and discovers the resource API, sends an authenticated HTTPS request, and the API server authenticates, authorizes, runs admission/defaulting/validation and persists accepted state in etcd. The response contains object identity and concurrency metadata. Watchers discover the change. For a Deployment, its controller creates or updates a ReplicaSet; the ReplicaSet controller creates Pods; the scheduler binds each unscheduled Pod; the selected node's kubelet asks runtime/network/storage components to realize it and reports status. Higher controllers update conditions. Service endpoints and user checks finally prove availability. Each step is asynchronous and independently fallible.

### Why are spec and status separate?

Spec is declared intent and status is observation. This separation allows a user or delivery manager to state what should exist while authorized controllers report what they have observed. It supports retries, competing failure domains and clear ownership. If users rewrite status to look healthy, the feedback loop loses its signal. Use generation and observedGeneration to connect status to the desired revision.

### What is resourceVersion?

It is an opaque token representing persisted resource state for concurrency and watch semantics. A client can list and then watch changes after a returned version or use it to detect update conflicts. It is not a wall-clock timestamp, globally portable sequence or durable event ID. When history is compacted, clients relist instead of demanding infinite replay.

### Why do controllers use watches if they must reread state?

Watches efficiently notify clients that something changed. They are prompts, not commands. Connections close and events can be coalesced or missed outside retained history. A level-triggered reconciler enqueues the object key, reads current desired and observed state, and calculates what is needed now. This makes duplicate and missing event edges survivable.

### What is the difference between generation and resourceVersion?

ResourceVersion changes with persisted updates and supports concurrency/watch behavior. Generation commonly advances when desired-state fields change, according to the resource strategy. Status updates may change resourceVersion without changing generation. A controller reports observedGeneration to say which desired revision its status covers.

### Why can a Pod remain Pending after scheduling?

Pod phase may remain Pending while containers have not started even when `spec.nodeName` is set. Scheduling means placement/binding. Node-side sandbox creation, image pull, volume mount, CNI, runtime or container startup may still be incomplete or failing. Check nodeName first, then conditions, containerStatuses and events.

### Who creates a Pod for a Deployment?

Not the Deployment controller directly in the usual chain. The Deployment controller owns and manages ReplicaSets. The ReplicaSet controller creates Pods to satisfy replicas. Owner references record Deployment-to-ReplicaSet and ReplicaSet-to-Pod lifecycles. Scheduler later binds Pods; kubelet later runs them.

### What does a finalizer do?

It records an outstanding deletion obligation. When deletion is requested, Kubernetes sets deletionTimestamp and retains the object while finalizers exist. Each responsible controller completes its external or dependent cleanup and removes only its own finalizer. Removing a finalizer without cleanup can orphan resources or data.

### What does server-side apply conflict mean?

Another field manager owns a field whose live value conflicts with your desired value. The refusal prevents silent ownership theft. Inspect managedFields, decide which actor should own the field, change ownership boundaries or explicitly transfer with reviewed force. Repeatedly forcing conflicts can create controller fights.

### What is etcd's role?

It stores Kubernetes API state with strong consistency based on quorum. The API server mediates normal access. etcd health affects API writes, reads and watch history. It does not schedule Pods or run containers, and it does not store application volume contents. Protect its certificates, encryption keys, snapshots, quorum and operational latency.

### How do you diagnose a stuck controller?

Bind cluster/object UID and compare generation with observedGeneration. Inspect conditions and owned children. Identify the responsible controller and its leader Lease. Check API list/watch access, queue depth/age, retries, reconcile errors/latency, field conflicts, admission and etcd/API health. Repair the controller or dependency; do not patch status or manually create children unless executing a documented ownership migration.

### Why is a green Pod not enough?

`Running` means at least one container is running or starting under Pod phase semantics, not that readiness is true, dependencies work, Service endpoints are correct or user transactions succeed. Verify Pod conditions, readiness, EndpointSlices, request golden signals and a representative user journey.

## Product-company interview

### Trace a Deployment from YAML to a running request

A senior answer names the boundaries in order: kubeconfig/context; discovery; TLS; authentication; authorization; mutating admission; schema/defaulting/validation; validating admission; etcd persistence with UID/RV; Deployment controller; ReplicaSet owner; ReplicaSet controller; Pod objects; scheduler filters/scores/binding; node kubelet; CRI runtime plus CNI/CSI; probes and status; EndpointSlice/Service path; application dependency and user response. At every step state the evidence and failure class.

Weak answer: “kubectl sends YAML to the master, and Kubernetes schedules containers.” It collapses security, persistence, ownership and node execution and cannot guide an incident.

### Design an HA control plane

Use multiple API servers behind a resilient load balancer, an odd etcd quorum distributed across failure domains, replicated scheduler/controller managers with leader election, redundant PKI/DNS/network paths and monitored admission dependencies. Define version-skew and upgrade order, etcd snapshot/restore, encryption-key recovery, capacity, APF and SLOs. Test zone/member/API/leader failures and restore. Explain correlated risks: three hosts in one rack or one load balancer are not HA.

### A Deployment is available but users receive 503

Confirm current generation/observedGeneration and available condition, then leave the Deployment abstraction. Check ready Pods, EndpointSlices/Service selectors, proxy/data-plane programming, ingress/gateway/load balancer, application logs, dependency health and request traces. Compare rollout revision and user errors. Stop rollout and roll back authoritative spec if correlated. Availability condition is one controller contract, not end-to-end success.

### All Pods are Pending after a release

First split by nodeName. Empty nodeName: inspect FailedScheduling reasons, resource requests, selectors, affinities, taints/tolerations, topology, volumes and node allocatable. Set nodeName: inspect kubelet/runtime/image/CNI/CSI/security. Compare what changed in the template. Avoid deleting Pods repeatedly; the controller recreates identical intent.

### An object has been Terminating for two hours

Capture UID, deletion timestamp, grace period, finalizers, owners/dependents and related events/audit. Map each finalizer to its controller and external resource. Restore the controller or dependency, verify cleanup and allow it to remove its key. Manual removal is an approved exceptional action only after proving external/data consequences and recording residual remediation.

### Build a custom controller

Use a versioned CRD with structural schema, clear spec/status contract and conditions. List/watch through shared informer, queue keys, reconcile current level, use deterministic children with owner references, idempotent external calls and bounded retries, handle deletion with an owned finalizer, use status subresource and observed generation, leader election, least-privileged service account and metrics. Test duplicate/missed events, conflicts, lost response, partial success, watch relist, leadership change, upgrade conversion and cleanup.

### Explain API overload from a bad controller

A faulty controller may full-list frequently, create too many watches, hot-loop status updates or retry without backoff. This consumes API concurrency and etcd IO, delaying critical controllers and heartbeats. Contain or scale down the offender, use APF to protect system flows, inspect request metrics/audit/user agent, then repair shared informers, pagination, change suppression and rate limits. Adding retries worsens overload.

### How would you recover etcd?

Freeze writes and automation, establish quorum and current member state, preserve evidence, identify a verified snapshot and encryption/certificate material, follow supported version-specific restore into an isolated/rebuilt control plane, validate API objects and admission/controllers, then reconcile nodes/external resources/application data. Test this before incidents. An etcd restore changes cluster API history; it is not simply copying a file back.

### Why can AI not replace the operator in this incident?

Tools can summarize objects and suggest common branches, but accountable engineering still requires binding the correct cluster, judging ownership and data consequence, choosing when not to force deletion, balancing user impact against recovery risk, coordinating teams and validating reality. The durable skill is evidence-based systems judgment. AI is an accelerator inside guarded authority, not the source of truth or approval.

## Independent transfer and rubric

The reviewer provides a pinned disposable local cluster with unfamiliar names and one scenario combining:

- a valid API write;
- a controller whose observedGeneration lags;
- one ReplicaSet with a tempting but wrong label match;
- one Pod unscheduled by a constraint;
- one bound Pod blocked in node-side convergence;
- one object held by a legitimate finalizer;
- one watch requiring relist;
- a shallow health signal that disagrees with a user journey.

The learner receives no answer key and must deliver:

1. cluster/client/context/identity and authorization boundary;
2. object table with namespace, name, UID, generation, observedGeneration and resourceVersion;
3. request-path and component map;
4. exact owner/dependent graph;
5. classification of API, controller, scheduler, kubelet and finalizer symptoms;
6. watch/relist evidence without treating events as audit history;
7. smallest safe recovery in ownership order;
8. status, field-manager and finalizer non-interference explanation;
9. API/etcd/controller/node/service/user observability plan;
10. rollback and exact namespace/cluster cleanup;
11. five-minute incident briefing;
12. delayed case with changed names, constraints and failure order.

Scoring:

| Criterion | Points | Full-credit evidence |
|---|---:|---|
| Cluster and caller identity | 8 | exact endpoint/version/context/user/namespace and safe RBAC |
| API request path | 10 | authn/authz/admission/validation/persistence separated |
| Object metadata reasoning | 10 | UID/RV/generation/observedGeneration used correctly |
| Ownership graph | 8 | exact UID edges and garbage-collection consequences |
| Controller diagnosis | 10 | lag tied to leader/watch/queue/reconcile evidence |
| Scheduler diagnosis | 8 | empty nodeName and constraint evidence |
| Node diagnosis | 8 | bound Pod traced through Lease/kubelet/runtime/plugins |
| Watch correctness | 8 | list/watch/compaction/relist and evidence limits |
| Finalizer safety | 8 | responsible owner and external cleanup preserved |
| Recovery and rollback | 8 | smallest owner-correct change and desired-state rollback |
| Observability and user proof | 6 | API through user evidence correlated |
| Security and cleanup | 4 | no overprivilege/secret leak and exact absence |
| Communication/transfer | 4 | clear uncertainty and changed-case retention |
| **Total** | **100** | **80 passes; any context/force/data safety breach fails; 90 demonstrates advanced transfer** |

Automatic failure: wrong cluster mutation, cluster-admin learner identity, manual status patch, manual nodeName, blind finalizer removal, etcd edit, unapproved image pull, privileged/host-mounted workload, fabricated output or missing cleanup.

## References and review

Primary sources reviewed 2026-08-04:

1. [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/) — control-plane and node component responsibilities.
2. [Kubernetes API Concepts](https://kubernetes.io/docs/reference/using-api/api-concepts/) — resources, versions, concurrency, list/watch and API behavior.
3. [Objects in Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/) — metadata, spec, status and object intent.
4. [Controllers](https://kubernetes.io/docs/concepts/architecture/controller/) — control-loop and desired/current-state model.
5. [Kubernetes Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) — unscheduled Pods, filtering and scoring.
6. [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/) — Node objects, conditions and controller behavior.
7. [Leases](https://kubernetes.io/docs/concepts/architecture/leases/) — node heartbeat and leader-election uses.
8. [Owners and Dependents](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/) — UID ownership and garbage collection.
9. [Finalizers](https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/) — deletion timestamps and cleanup keys.
10. [Server-Side Apply](https://kubernetes.io/docs/reference/using-api/server-side-apply/) — field managers, managed fields and conflicts.
11. [API Priority and Fairness](https://kubernetes.io/docs/concepts/cluster-administration/flow-control/) — request classification, queuing and concurrency.
12. [Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) — mutating/validating admission placement and behavior.
13. [Kubernetes Deprecation Policy](https://kubernetes.io/docs/reference/using-api/deprecation-policy/) — API lifecycle and removal policy.
14. [etcd data model](https://etcd.io/docs/v3.6/learning/data_model/) — revisions, key-value history and watch model.
15. [Troubleshooting Clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/) — component-oriented cluster diagnosis.

Review limits:

- Current Kubernetes documentation presents v1.36 as current; no v1.36 cluster was run.
- The model uses Kubernetes-shaped records but imports no Kubernetes library and opens no API connection.
- No claim is made for etcd quorum, API admission, RBAC, scheduler plugins, kubelet, CRI, CNI, CSI, Service routing or managed control planes.
- The independent local-cluster exercise remains reviewer-held and unexecuted.
- Publication and answer access never establish production authority or learner mastery.

Promotion requires a pinned local-cluster supply chain; dedicated kubeconfig/RBAC; namespace and cluster lifecycle guards; real API/list-watch/controller/scheduler/kubelet/finalizer faults; exact cleanup; formal technical/security/instructional/accessibility review; and unseen learner transfer.
