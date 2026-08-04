---
{"schemaVersion":1,"kind":"lesson","id":"LES-0047","slug":"kubernetes-operators-custom-resources-admission","aliases":["V05-L11","kubernetes-operators-custom-resources-admission"],"curriculumIds":["K8S-007"],"route":"/book/infrastructure/kubernetes-operators-custom-resources-admission","order":11,"volume":"05-infrastructure-platforms","title":"Kubernetes extensions: custom resources, operators, admission, and safe evolution","summary":"Decide whether Kubernetes extension is justified, design structural APIs and idempotent reconciliation, evolve stored versions, and contain webhook and finalizer failures.","domain":"infrastructure","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0020","LES-0021","LES-0041","LES-0045","LES-0046"],"prerequisiteCurriculumIds":["AUT-004","AUT-005","K8S-001","K8S-005","K8S-006"],"testedEnvironments":[{"platform":"Kubernetes documentation","version":"v1.36 current documentation","support":"supported","notes":"Official custom-resource, operator, CRD versioning, API, controller, ownership, finalizer, admission, webhook, policy and aggregation sources reviewed 2026-08-04."},{"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No API extension, controller, conversion or admission runtime evidence."}],"targetRoles":["platform-engineer","site-reliability-engineer","kubernetes-engineer","devops-engineer","software-engineer","security-engineer","technical-lead"],"learningObjectives":["Choose built-in resources, configuration, CRD plus controller, admission policy, webhook, or aggregated API from the actual lifecycle need.","Design a structural custom-resource schema with validation, defaulting, status and scale boundaries.","Implement level-triggered idempotent reconciliation with ownership, conditions, retries and bounded concurrency.","Use finalizers as deletion protocols without creating permanent deadlocks.","Evolve served and storage versions with conversion and migration evidence.","Design validating or mutating admission with narrow matching, low latency, idempotency and safe failure policy.","Prefer in-process validating admission policy when it meets the requirement.","Diagnose controller, finalizer, conversion and webhook outages without deleting safety controls blindly.","Define SLOs, capacity, security and upgrade contracts for extension control planes.","Justify operator complexity against a simpler explicit workflow."],"productionSignals":["CRD group plural scope names UID resourceVersion generation served/storage versions","OpenAPI schema defaults validation pruning and CEL decisions","custom-resource UID generation deletionTimestamp finalizers ownerReferences","controller version leader lease workqueue depth retries reconcile latency and error class","observedGeneration conditions reason message lastTransitionTime","child identity controller owner and garbage-collection policy","conversion request UID desiredAPIVersion objects response/result latency","webhook configuration UID rules selectors matchPolicy timeoutSeconds failurePolicy sideEffects reinvocationPolicy","admission request UID operation user object oldObject dryRun response patch/denial audit annotation","API request latency rejection and availability by resource/operation","extension CPU memory replicas disruption and dependency saturation","user operation and rollback/migration evidence"],"diagrams":[{"id":"LES-0047-DIA-001","title":"Extension choice tree","direction":"hierarchical","boundaries":["built-in API","configuration","CRD","controller","admission policy","webhook","aggregated API"],"evidencePoints":["new state","automation","write policy","custom storage"],"textAlternative":"Choose the smallest extension that supplies the required state, automation or admission behavior."},{"id":"LES-0047-DIA-002","title":"Custom API lifecycle","direction":"left-to-right","boundaries":["CRD schema","API request","admission","storage version","watch","controller","status"],"evidencePoints":["version","generation","resourceVersion","condition"],"textAlternative":"A custom object passes schema and admission, is stored in one version, watched by a controller and reports status."},{"id":"LES-0047-DIA-003","title":"Reconcile loop","direction":"cyclic","boundaries":["observe","compare","plan","act","report","requeue"],"evidencePoints":["UID","observedGeneration","idempotency key","retry"],"textAlternative":"The controller repeatedly observes desired and external state, makes bounded changes, records status and requeues."},{"id":"LES-0047-DIA-004","title":"Version conversion path","direction":"left-to-right","boundaries":["served version","conversion review","hub/storage shape","stored object","requested version"],"evidencePoints":["request UID","from/to","storedVersions","migration"],"textAlternative":"Clients may use different served versions while conversion and storage-version migration preserve one durable representation."},{"id":"LES-0047-DIA-005","title":"Admission dependency","direction":"left-to-right","boundaries":["API request","match","network/TLS","webhook or policy","timeout","allow/deny","persistence"],"evidencePoints":["request UID","latency","failurePolicy","reason"],"textAlternative":"A matching admission extension enters the API write path, so correctness and availability policy are inseparable."},{"id":"LES-0047-DIA-006","title":"Deletion protocol","direction":"cyclic","boundaries":["delete request","deletionTimestamp","finalizer","external cleanup","finalizer removal","garbage collection"],"evidencePoints":["UID","finalizer owner","cleanup token","absence"],"textAlternative":"Deletion becomes a protocol when finalizers require external cleanup before object removal."}],"commands":[{"id":"LES-0047-CMD-001","question":"What exact custom API contract is installed?","risk":"read-only","command":"kubectl get crd widgets.platform.example -o yaml","runFrom":"approved cluster context","expectedBranches":[{"when":"schema/scope/versions match","meaning":"declared contract bound","nextEvidence":"inspect objects"},{"when":"unexpected","meaning":"wrong extension/version","nextEvidence":"stop"}],"proves":"declared CRD","doesNotProve":"conversion/controller health"},{"id":"LES-0047-CMD-002","question":"Which versions are served, stored, and still recorded?","risk":"read-only","command":"kubectl get crd widgets.platform.example -o jsonpath='{.spec.versions} {.status.storedVersions}'","runFrom":"approved cluster","expectedBranches":[{"when":"one intended storage version","meaning":"storage contract visible","nextEvidence":"migration proof"},{"when":"old stored version remains","meaning":"migration incomplete","nextEvidence":"do not remove version"}],"proves":"CRD version declarations/status","doesNotProve":"every object rewritten"},{"id":"LES-0047-CMD-003","question":"Will an invalid object be rejected without persistence?","risk":"mutating-bounded","command":"kubectl apply --dry-run=server -f invalid-widget.yaml -o yaml","runFrom":"reviewer-owned disposable namespace","expectedBranches":[{"when":"expected schema/policy denial","meaning":"negative contract test passed","nextEvidence":"retain reason"},{"when":"accepted","meaning":"validation gap","nextEvidence":"stop"}],"proves":"one current server decision","doesNotProve":"all invalid states","cleanup":"server dry-run persists nothing; prove object absent"},{"id":"LES-0047-CMD-004","question":"Has the controller observed the current desired generation?","risk":"read-only","command":"kubectl get widget demo -n extension-lab -o jsonpath='{.metadata.uid} {.metadata.generation} {.status.observedGeneration} {.status.conditions}'","runFrom":"approved namespace","expectedBranches":[{"when":"observedGeneration current and Ready true","meaning":"reported reconciliation current","nextEvidence":"verify child/user"},{"when":"stale or degraded","meaning":"controller lag/failure","nextEvidence":"queue/log/event evidence"}],"proves":"reported object status","doesNotProve":"external truth"},{"id":"LES-0047-CMD-005","question":"Which children does this object control?","risk":"read-only","command":"kubectl get deploy,service -n extension-lab -o json","runFrom":"approved namespace","expectedBranches":[{"when":"controller owner UID matches","meaning":"ownership graph visible","nextEvidence":"check field collisions"},{"when":"missing/wrong owner","meaning":"adoption/orphan risk","nextEvidence":"stop"}],"proves":"declared owner references","doesNotProve":"safe garbage collection"},{"id":"LES-0047-CMD-006","question":"Why is deletion stuck?","risk":"read-only","command":"kubectl get widget demo -n extension-lab -o jsonpath='{.metadata.deletionTimestamp} {.metadata.finalizers} {.status.conditions}'","runFrom":"approved namespace","expectedBranches":[{"when":"owner finalizer and cleanup failing","meaning":"deletion protocol blocked","nextEvidence":"repair cleanup dependency"},{"when":"unknown finalizer","meaning":"ownership unclear","nextEvidence":"do not remove blindly"}],"proves":"reported deletion/finalizer state","doesNotProve":"external cleanup status"},{"id":"LES-0047-CMD-007","question":"Is the controller deployment available and leader election healthy?","risk":"read-only","command":"kubectl get deployment,pod,lease -n extension-system -o wide","runFrom":"approved operator namespace","expectedBranches":[{"when":"available leader and stable restarts","meaning":"basic control process present","nextEvidence":"inspect queue/errors"},{"when":"unavailable/churn","meaning":"controller control-plane failure","nextEvidence":"events/logs/resources"}],"proves":"selected Kubernetes objects","doesNotProve":"successful reconciliation"},{"id":"LES-0047-CMD-008","question":"What admission extensions can intercept this write?","risk":"read-only","command":"kubectl get validatingwebhookconfiguration,mutatingwebhookconfiguration,validatingadmissionpolicy,validatingadmissionpolicybinding -o yaml","runFrom":"approved auditor context","expectedBranches":[{"when":"narrow matches/owners visible","meaning":"candidate admission path bound","nextEvidence":"health/latency"},{"when":"broad or overlapping","meaning":"blast/loop risk","nextEvidence":"review"}],"proves":"declared admission configuration","doesNotProve":"endpoint availability"},{"id":"LES-0047-CMD-009","question":"Will the exact object pass current admission without persistence?","risk":"mutating-bounded","command":"kubectl apply --dry-run=server -f widget.yaml -o yaml","runFrom":"approved disposable scope","expectedBranches":[{"when":"accepted/defaulted","meaning":"one admission path passed","nextEvidence":"inspect mutation/diff"},{"when":"timeout/denial","meaning":"extension blocked request","nextEvidence":"bind policy/webhook UID"}],"proves":"one server admission decision","doesNotProve":"future availability","cleanup":"prove no dry-run object persisted"},{"id":"LES-0047-CMD-010","question":"What are controller and webhook failure signals?","risk":"read-only","command":"kubectl get --raw /metrics","runFrom":"approved authenticated local API proxy with bounded capture","expectedBranches":[{"when":"scoped latency/error/queue metrics available","meaning":"signal source exists","nextEvidence":"correlate request UID"},{"when":"unavailable/high cardinality","meaning":"observability gap","nextEvidence":"use events/logs/audit"}],"proves":"one metrics response","doesNotProve":"causality or safe cardinality"},{"id":"LES-0047-CMD-011","question":"Can a disposable custom object reconcile and delete cleanly?","risk":"mutating-bounded","command":"kubectl apply -f widget.yaml; kubectl delete -f widget.yaml --wait=true --timeout=5m","runFrom":"reviewer-owned disposable namespace after diff approval","expectedBranches":[{"when":"created/reconciled/deleted","meaning":"one lifecycle completed","nextEvidence":"prove children/external state absent"},{"when":"stuck","meaning":"controller/finalizer failure","nextEvidence":"preserve evidence"}],"proves":"one bounded lifecycle","doesNotProve":"upgrade or scale safety","cleanup":"reviewer verifies object, owned children and synthetic external state absent"},{"id":"LES-0047-CMD-012","question":"Does the offline extension model cover eight cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0047 support/lab normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"model/refusal/cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic teaching model","doesNotProve":"CRD controller admission or cluster runtime","cleanup":"verifier proves exact state absence"}],"labs":[{"id":"LES-0047-LAB-001","title":"Guided Kubernetes extension decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no cluster","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","eight deterministic extension cases"],"abortConditions":["root","network","credential","kubectl","symlink","unknown artifact"],"recovery":"Preserve first failed gate and clean exact root.","cleanupProof":"Exact inventory and absence.","path":"drafts/LES-0047-kubernetes-operators-custom-resources-admission/support/lab"},{"id":"LES-0047-LAB-002","title":"Independent extension lifecycle and failure transfer","mode":"independent","environment":"Reviewer-owned disposable local cluster","timeMinutes":240,"privilege":"namespace learner; reviewer owns CRD/webhook/policy","network":"local only","changes":["synthetic CRD/controller","admission policy or webhook","version/finalizer faults"],"abortConditions":["production","real external resource","cluster-admin learner","unbounded webhook","forced finalizer removal","unreviewed version removal"],"recovery":"Preserve request/object/controller evidence; reviewer executes break-glass.","cleanupProof":"CRs, children, external fixture, policies, webhooks, CRD and namespace absent.","path":"drafts/LES-0047-kubernetes-operators-custom-resources-admission/support/lab"}],"incidents":[{"id":"LES-0047-INC-001","signal":"Custom resource exists but status never observes its generation.","firstThought":"Controller watch/queue/reconcile path is stalled or status write is denied.","safePath":"Bind object/controller identities, queue, errors, RBAC and external dependency before retry.","trap":"Delete and recreate the object."},{"id":"LES-0047-INC-002","signal":"DeletionTimestamp is set for hours.","firstThought":"A finalizer owner has not completed or recorded cleanup.","safePath":"Identify finalizer owner and external state, restore controller/dependency, then prove cleanup before removal.","trap":"Patch away every finalizer."},{"id":"LES-0047-INC-003","signal":"Old API version cannot be removed.","firstThought":"Stored objects or clients still depend on it.","safePath":"Prove served/storage/conversion compatibility, rewrite stored objects and migrate clients before CRD change.","trap":"Delete the old version field."},{"id":"LES-0047-INC-004","signal":"Admission webhook times out and unrelated writes fail.","firstThought":"Broad matching plus failure policy made endpoint health an API availability dependency.","safePath":"Bind configuration/request UIDs, contain match scope, restore endpoint/TLS or use reviewed break-glass preserving controls.","trap":"Delete all webhooks."},{"id":"LES-0047-INC-005","signal":"Controller repeatedly creates duplicate external resources.","firstThought":"Reconciliation lacks stable identity/idempotency after retry or lost status.","safePath":"Stop amplification, bind object UID/idempotency key, inventory duplicates, repair source logic and reconcile safely.","trap":"Increase retry rate."}],"assessmentIds":["ASM-0124","ASM-0125","ASM-0126"],"referenceIds":["REF-0463","REF-0464","REF-0465","REF-0466","REF-0467","REF-0468","REF-0469","REF-0470","REF-0471","REF-0472","REF-0473","REF-0474","REF-0475","REF-0476","REF-0477"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No Kubernetes extension runtime.","No real controller/webhook/conversion/API storage evidence.","Offline model is not cluster evidence.","Formal review and learner evidence absent."]}
---

# Kubernetes extensions: custom resources, operators, admission, and safe evolution

## What you see and first thought

A new Kind does not mean an operator exists. A CRD lets the API store and serve a new resource. A controller supplies automation. Admission evaluates proposed writes. Start by naming which mechanism failed.

When a custom object is accepted but nothing happens, inspect the controller path. When creation is denied or times out, inspect admission. When deletion hangs, inspect the finalizer protocol. When an old version cannot disappear, inspect served, storage, conversion and client migration evidence.

## Terms before commands

A custom resource extends the Kubernetes API. A CRD defines its group, versions, names, scope and structural OpenAPI schema. `spec` normally holds desired state; `status` reports observation. `generation` changes with desired-state updates; `observedGeneration` lets a controller say which generation its status describes.

An operator combines one or more custom resources with controllers that encode domain operations. A finalizer is a key that delays deletion until its owner completes cleanup. Admission controllers run after authentication and authorization, before persistence. Mutating admission changes a proposal; validating admission accepts or rejects it.

## Architecture map

```text
client -> API schema -> admission -> storage version -> watch queue
                                                    -> controller
CR.spec -> observe -> compare -> act -> CR.status/conditions
                            |
                       owned children/external API
```

The API contract and the automation lifecycle must be independently operable. If the controller is down, reads and writes may still work while convergence stops. If a fail-closed webhook is down, matching writes can stop even when every controller is healthy.

## Request or state path

The API server validates a custom object against the CRD, applies defaulting and pruning rules, runs admission, converts to the storage version and persists it. Watches deliver changes to controllers. A controller reads from a cache, keys work, reconciles desired and actual state, writes child/external changes, then updates status.

Events are hints, not commands. Watches can close, retries duplicate work and caches can lag. Reconciliation must be level-triggered and idempotent: observe current truth and move it toward desired state safely no matter why the loop ran.

## Failure zoom

If `generation` advances but `status.observedGeneration` does not, bind the exact object UID and controller version. Check watch/list RBAC, queue depth, reconcile errors, leader election, API throttling and external dependencies. Never infer controller health from a Running Pod alone.

A deletion timestamp plus a finalizer means the API is waiting for a cleanup protocol. Find the finalizer owner and its external resource identity. Blind removal can orphan load balancers, credentials, databases or records; restore the owner or perform reviewed equivalent cleanup first.

Webhook failures require configuration UID, matching rule, selectors, endpoint/TLS health, timeout and failure policy. Broad matches and long timeouts enlarge blast radius. Exclude the webhook's own resources and dependencies to avoid self-deadlock.

## Internals and state ownership

Use a structural schema, required fields, formats, bounds and CEL validation for invariants expressible at admission time. Defaults must remain safe across versions. Unknown-field pruning and list/map semantics affect compatibility. Keep status as a subresource so users and controllers have distinct write ownership.

One CRD version is the storage version; several may be served. A conversion webhook translates objects between requested and hub/storage shapes, but conversion must not invent external side effects. Before removing an old served version, migrate clients and stored objects, prove `status.storedVersions`, and preserve round-trip data.

Owner references drive garbage collection only within allowed scope and ownership rules. Finalizers handle external cleanup. Conditions need stable types, truth status, reason, human message and transition time; `Ready=False` without observed generation is ambiguous.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| API contract valid | CRD schema plus positive/negative server tests | controller behavior |
| controller current | UID, generation/observedGeneration, conditions | external truth |
| retry safe | repeated reconcile with stable identity and no duplicate side effect | every fault |
| deletion safe | external cleanup identity, finalizer removal and absence | historical leakage |
| version migration complete | clients, conversion tests, rewritten objects, storedVersions | semantic correctness |
| admission available | scoped latency/errors and negative/positive requests | future dependency health |

## Command decoders

`kubectl get crd -o yaml` reveals scope, versions, schema, conversion and subresources. It does not prove existing objects satisfy the newest contract. `--dry-run=server` exercises the current API and admission without persistence; preserve the rejection reason and audit/request UID.

Reading `generation`, `observedGeneration` and conditions together prevents stale-green status. Listing owner references binds children to the exact UID, not only a reusable name. Metrics need controller/version/result labels with bounded cardinality; object names and error text usually do not belong in metric labels.

## Decision path

1. Ask whether built-in resources plus explicit automation solve the problem.
2. Define user, desired state, status, lifecycle and ownership before schema.
3. Make the API structural, validated, default-safe and versionable.
4. Design idempotent reconciliation, stable external identity and bounded retries.
5. Separate child ownership, external cleanup and finalizer responsibility.
6. Choose admission policy before webhook when expressiveness permits.
7. Scope matches, timeout, failure policy, side effects and break-glass.
8. Test conversion round trips and storage migration before version removal.
9. Verify API, controller, external resource and user operation separately.
10. Prove deletion and rollback leave no orphan.

## Guided Ubuntu lab

The offline model covers schema rejection, stale observed generation, duplicate external creation, stuck finalizer, conversion loss, storage-version residue, webhook timeout and admission self-deadlock. Each case has one earliest boundary and safe next action.

The fixture refuses root, network, credentials, symlinks and unknown state. Passing it proves classification logic only; it does not start Kubernetes or execute an operator.

## Production transfer

Use a reviewer-owned disposable cluster. Create a small namespaced CRD with status and one safe schema rule, a controller over a synthetic external-state fixture, and either ValidatingAdmissionPolicy or a narrowly scoped webhook. Prove create, update, retry idempotency, status freshness, deletion cleanup and negative validation.

Add a second served version and test round-trip conversion without data loss. Inject controller outage, lost status update, finalizer dependency failure and admission timeout. The reviewer owns CRD/webhook changes and cleanup.

## Reliability, security, observability, capacity, and cost

Extension components are control planes. Give controllers and webhooks replicas, requests/limits, disruption rules, leader-election behavior, bounded queues, rate limits and dependency timeouts. Define reconcile and admission SLOs from user consequences.

Use least-privilege RBAC, non-root containers, protected service-account tokens, network policy, TLS identity, image provenance and audit. A controller that can watch Secrets or create arbitrary Pods is a high-value target.

Track reconcile rate/duration/result, queue depth/age, retries, stale generations, finalizer age, conversion and admission latency/errors/rejections. Avoid per-object metric labels. Cost includes ongoing upgrades, API/storage load, on-call ownership and migration work—not only Pods.

## Traps and prevention

- **Trap:** Build an operator for a one-step install. **Prevention:** justify continuous domain reconciliation.
- **Trap:** Treat watch events as exact once. **Prevention:** level-triggered idempotency.
- **Trap:** Store truth only in status. **Prevention:** re-observe external state and use stable identity.
- **Trap:** Remove finalizers to unstick deletion. **Prevention:** prove cleanup first.
- **Trap:** Remove an old version after changing YAML. **Prevention:** client, conversion, storage migration evidence.
- **Trap:** Put slow remote calls in admission. **Prevention:** local/cacheable policy, tight timeouts and narrow matching.
- **Trap:** Fail open or closed everywhere. **Prevention:** threat-and-availability decision per rule.
- **Trap:** Let webhook intercept itself. **Prevention:** selectors/exclusions and dependency graph review.

## Memory card and retrieval

Remember **API → RECONCILE → STATUS → EVOLVE → ADMIT**. CRD stores a contract; controller drives state; status reports observation; conversion evolves versions; admission guards proposals.

Tomorrow answer: Why must reconciliation be idempotent? Why is `Ready=True` stale without observed generation? What makes finalizer removal dangerous? What evidence permits version removal? Why can a webhook become a cluster outage?

## Complete answers

**When is an operator justified?** When a long-lived domain resource needs continuous, failure-aware reconciliation and the team will own its API, upgrades, security, SLOs and on-call lifecycle. A deployment script is often better for a one-time sequence.

**Why not use admission for external validation?** Remote calls add latency, availability and consistency dependencies to API writes. Prefer schema or validating admission policy for local invariants; if a webhook is necessary, bound and cache dependencies deliberately.

**Can status be trusted?** It is a controller's report. Bind it to the current generation and verify critical external/user truth independently.

**How do you repair a stuck finalizer?** Identify its owner, inspect why cleanup failed, restore or execute the intended cleanup through approved ownership, prove external absence, then allow finalizer removal. Forced removal is a reviewed last resort, not first aid.

## Product-company interview

**Question:** Design an operator for managed databases.

**Strong answer:** I first challenge whether an operator should own creation, backup, upgrade, failover and deletion or whether an external service API should. The CRD has a small versioned spec, status subresource and conditions tied to observed generation. Reconciliation uses the CR UID as an idempotency key, re-observes provider state, bounds retries and never duplicates databases. A finalizer protects deletion with explicit retention policy. Version conversion is round-trip tested; credentials are references, not status. I define queue/reconcile/finalizer SLOs and test provider outage, lost status, controller restart, duplicate event and deletion.

**Weak answer:** Watch CRs and call the cloud API. It omits idempotency, identity, status freshness, secrets, deletion, migration, capacity and recovery.

## Independent transfer and rubric

The reviewer supplies an unseen API design with an over-broad schema, non-idempotent create, stale status, stuck finalizer, lossy conversion and fail-closed webhook. The learner must choose the minimum extension, repair the contracts, contain failures and prove positive, negative, upgrade and cleanup behavior. `ASM-0126` keeps its solution reviewer-only.

Reading and deterministic model output do not award mastery. The evidence requires an unseen changed case, observed lifecycle, defensible complexity choice and delayed retrieval.

## References and review

Fifteen current official Kubernetes sources cover custom resources, operators, CRDs, versioning, deprecation, finalizers, admission, webhooks, validating policy, controller loops, API concepts, ownership and aggregation. They were reviewed 2026-08-04 and require review by 2027-02-04.

Exact feature maturity and fields vary by Kubernetes release. Pin cluster/client versions and test the real API before using examples in an operational environment.
