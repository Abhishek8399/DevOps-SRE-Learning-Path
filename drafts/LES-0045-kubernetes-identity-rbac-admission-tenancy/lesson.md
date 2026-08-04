---
{
  "schemaVersion":1,"kind":"lesson","id":"LES-0045","slug":"kubernetes-identity-rbac-admission-tenancy","aliases":["V05-L09","kubernetes-identity-rbac-admission-tenancy"],"curriculumIds":["K8S-005"],"route":"/book/infrastructure/kubernetes-identity-rbac-admission-tenancy","order":9,"volume":"05-infrastructure-platforms","title":"Kubernetes security: identity, RBAC, secrets, admission, and tenant boundaries","summary":"Trace a caller and workload through authentication, authorization, service accounts, token projection, secrets, security contexts, admission policy, Pod Security and multi-tenant isolation.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0011","LES-0016","LES-0041","LES-0042","LES-0043"],"prerequisiteCurriculumIds":["LNX-004","NET-006","K8S-001","K8S-002","K8S-003"],
  "testedEnvironments":[{"platform":"Kubernetes documentation","version":"v1.36 current documentation","support":"supported","notes":"Official authentication, authorization, RBAC, service-account, Secret, security-context, Pod Security, admission, tenancy and checklist sources reviewed 2026-08-04."},{"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No Docker Linux engine or WSL access; no API security runtime claim."},{"platform":"Cloud","version":"not used","support":"unsupported","notes":"No cloud IAM, workload identity federation, key vault, credential or managed policy."}],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","kubernetes-engineer","security-engineer","infrastructure-engineer","technical-lead"],
  "learningObjectives":["Separate authentication, authorization, admission and runtime enforcement.","Model Kubernetes subjects, service accounts, groups, verbs, API groups, resources, subresources and scopes.","Design least-privilege Roles/ClusterRoles and bindings without wildcard or privilege-escalation traps.","Explain projected service-account tokens, audiences, expiration and automount boundaries.","Handle Secrets as sensitive API data rather than encrypted-by-default magic.","Design securityContext using non-root identity, capabilities, seccomp, privilege escalation and filesystem controls.","Apply Pod Security Admission labels and understand enforce/audit/warn version behavior.","Diagnose admission webhook and policy failures without bypassing controls.","Design namespace/cluster multi-tenancy with quotas, network, nodes, data and control-plane isolation.","Verify allowed and denied actions, workload behavior, audit evidence and revocation."],
  "productionSignals":["API server/context/caller username UID groups and credential source","verb API group resource subresource namespace name and non-resource URL","authorization decision authorizer reason Role/ClusterRole and binding UID","SelfSubjectAccessReview and SelfSubjectRulesReview results with scope limits","service-account UID token audience expiration bound-object and automount","Secret UID type resourceVersion encryption-at-rest configuration and access audit","Pod runAs user/group fsGroup capabilities seccomp privileged allowPrivilegeEscalation readOnlyRootFilesystem","namespace Pod Security enforce/audit/warn labels and pinned versions","admission controller/webhook/policy name operation match timeout failurePolicy mutation validation reason and audit annotation","network policy quota limit range node isolation runtime sandbox and storage boundaries","audit ID stage user source response status objectRef and policy decision","revocation time token lifetime cached authorization and observed denied result","user operation and tenant cross-boundary negative tests"],
  "diagrams":[
    {"id":"LES-0045-DIA-001","title":"API security gates","direction":"left-to-right","boundaries":["TLS endpoint","authentication","authorization","mutation","validation","persistence","runtime"],"evidencePoints":["identity","verb/resource","authorizer","webhook","audit ID"],"textAlternative":"A request reaches TLS, establishes identity, receives an authorization decision, passes mutating and validating admission, persists, then runtime controls apply."},
    {"id":"LES-0045-DIA-002","title":"RBAC relationship graph","direction":"hierarchical","boundaries":["subject","RoleBinding or ClusterRoleBinding","Role or ClusterRole","rules","API action"],"evidencePoints":["subject kind/name/namespace","roleRef","verbs","resources","resourceNames"],"textAlternative":"Bindings connect subjects to role rules; namespace and cluster scope determine reach."},
    {"id":"LES-0045-DIA-003","title":"Workload identity token path","direction":"left-to-right","boundaries":["Pod","service account","TokenRequest","projected token","audience","API or external verifier","expiration"],"evidencePoints":["SA UID","aud","exp","bound object"],"textAlternative":"A Pod obtains a short-lived projected token bound to a service account and audience; verifiers validate claims and expiration."},
    {"id":"LES-0045-DIA-004","title":"Pod runtime security layers","direction":"top-to-bottom","boundaries":["admission policy","Pod security context","container security context","runtime","kernel","filesystem/device/network"],"evidencePoints":["runAsNonRoot","capabilities","seccomp","privileged","mounts"],"textAlternative":"Admission constrains declared security settings, while runtime and kernel enforce identities, capabilities, seccomp and resource access."},
    {"id":"LES-0045-DIA-005","title":"Admission webhook safety","direction":"left-to-right","boundaries":["request match","API server call","webhook TLS","timeout","mutation/denial","failure policy","reinvocation"],"evidencePoints":["configuration UID","operation","latency","reason","audit"],"textAlternative":"A matching API request invokes an admission endpoint whose availability, timeout, failure policy and response affect API writes."},
    {"id":"LES-0045-DIA-006","title":"Tenant isolation stack","direction":"hierarchical","boundaries":["identity/RBAC","admission","quota","network","runtime/node","storage/secrets","observability","support"],"evidencePoints":["negative test","resource limit","deny decision","separate key/node"],"textAlternative":"Tenant isolation is layered; namespaces alone do not isolate every control-plane, network, node, storage or operational boundary."}
  ],
  "commands":[
    {"id":"LES-0045-CMD-001","question":"Who is the current caller and which context/server is in scope?","risk":"read-only","command":"kubectl config current-context; kubectl auth whoami; kubectl version","runFrom":"approved kubeconfig","expectedBranches":[{"when":"server/context/identity match","meaning":"caller boundary known","nextEvidence":"test exact authorization"},{"when":"unexpected","meaning":"blast radius unapproved","nextEvidence":"stop"}],"proves":"reported current identity/context","doesNotProve":"credential security or permissions"},
    {"id":"LES-0045-CMD-002","question":"May this subject perform the exact action?","risk":"read-only","command":"kubectl auth can-i create deployments.apps -n tenant-a --as=system:serviceaccount:tenant-a:builder","runFrom":"approved reviewer identity with impersonation permission","expectedBranches":[{"when":"yes","meaning":"authorization allows exact action","nextEvidence":"trace rules and admission"},{"when":"no","meaning":"authorization blocks it","nextEvidence":"inspect binding/rules"}],"proves":"authorization answer for tuple","doesNotProve":"admission or all privileges"},
    {"id":"LES-0045-CMD-003","question":"Which bindings and rules grant access?","risk":"read-only","command":"kubectl get role,rolebinding -n tenant-a -o yaml; kubectl get clusterrole,clusterrolebinding -o yaml","runFrom":"approved auditor context","expectedBranches":[{"when":"least rules and exact binding found","meaning":"grant path identified","nextEvidence":"check escalation verbs"},{"when":"wildcards/broad group found","meaning":"overprivilege risk","nextEvidence":"reduce deliberately"}],"proves":"declared RBAC graph","doesNotProve":"only effective authorizer"},
    {"id":"LES-0045-CMD-004","question":"Can the workload token be short-lived and audience-bound?","risk":"mutating-bounded","command":"kubectl create token builder -n tenant-a --audience=atlas-api --duration=10m","runFrom":"reviewer-owned disposable namespace","expectedBranches":[{"when":"token returned","meaning":"TokenRequest issued credential","nextEvidence":"decode offline and verify audience/expiry without logging token"},{"when":"denied","meaning":"caller lacks token creation or policy blocks","nextEvidence":"stop"}],"proves":"one token issuance","doesNotProve":"safe storage or external acceptance","cleanup":"do not persist or print token; wait for expiry and delete disposable namespace"},
    {"id":"LES-0045-CMD-005","question":"Does the Pod unnecessarily automount API credentials?","risk":"read-only","command":"kubectl get pod APP -n tenant-a -o yaml; kubectl get serviceaccount APP -n tenant-a -o yaml","runFrom":"approved namespace","expectedBranches":[{"when":"automount false for no-API workload","meaning":"credential exposure reduced","nextEvidence":"verify app still works"},{"when":"token mounted without need","meaning":"avoidable credential exists","nextEvidence":"change source and rollout"}],"proves":"declared Pod/SA automount","doesNotProve":"absence of other credentials"},
    {"id":"LES-0045-CMD-006","question":"What Secret metadata and access path exist without revealing values?","risk":"read-only","command":"kubectl get secret APP -n tenant-a -o jsonpath='{.metadata.uid} {.type} {.metadata.resourceVersion}'","runFrom":"approved metadata-only auditor","expectedBranches":[{"when":"identity/type match","meaning":"Secret object bound","nextEvidence":"inspect authorized consumers/audit"},{"when":"unexpected lifetime/type","meaning":"wrong secret","nextEvidence":"stop"}],"proves":"metadata only","doesNotProve":"value correctness or encryption"},
    {"id":"LES-0045-CMD-007","question":"Does the Pod request least-privilege runtime controls?","risk":"read-only","command":"kubectl get pod APP -n tenant-a -o jsonpath='{.spec.securityContext} {.spec.containers[*].securityContext}'","runFrom":"approved namespace","expectedBranches":[{"when":"non-root seccomp drop capabilities no escalation","meaning":"declared baseline visible","nextEvidence":"verify runtime"},{"when":"privileged host namespaces or broad caps","meaning":"escape/blast risk","nextEvidence":"stop and redesign"}],"proves":"declared contexts","doesNotProve":"kernel enforcement"},
    {"id":"LES-0045-CMD-008","question":"Which Pod Security policy mode/version applies?","risk":"read-only","command":"kubectl get namespace tenant-a --show-labels","runFrom":"approved cluster","expectedBranches":[{"when":"enforce/audit/warn levels and versions pinned","meaning":"namespace policy contract visible","nextEvidence":"server dry-run negative test"},{"when":"absent/latest only","meaning":"policy gap/version drift","nextEvidence":"review migration"}],"proves":"namespace labels","doesNotProve":"all admission policy"},
    {"id":"LES-0045-CMD-009","question":"Will admission reject a privileged Pod without persistence?","risk":"mutating-bounded","command":"kubectl apply --dry-run=server -n tenant-a -f forbidden-pod.yaml -o yaml","runFrom":"reviewed disposable fixture","expectedBranches":[{"when":"denied with expected policy reason","meaning":"server admission negative test passed","nextEvidence":"retain audit ID"},{"when":"accepted","meaning":"enforcement gap","nextEvidence":"stop before real apply"}],"proves":"one server dry-run admission decision","doesNotProve":"runtime or every bypass","cleanup":"server dry-run persists nothing; prove object absent"},
    {"id":"LES-0045-CMD-010","question":"Are admission webhooks healthy and narrowly scoped?","risk":"read-only","command":"kubectl get mutatingwebhookconfiguration,validatingwebhookconfiguration -o yaml","runFrom":"approved operator context","expectedBranches":[{"when":"selectors/rules/timeouts/failure policies bounded","meaning":"declared blast radius inspectable","nextEvidence":"measure latency/errors"},{"when":"broad match or unsafe fail-open/closed","meaning":"availability/security risk","nextEvidence":"review owner"}],"proves":"webhook config","doesNotProve":"endpoint health"},
    {"id":"LES-0045-CMD-011","question":"Can tenant A cross a denied tenant boundary?","risk":"read-only","command":"kubectl auth can-i get secrets -n tenant-b --as=system:serviceaccount:tenant-a:app; kubectl auth can-i create pods -n tenant-b --as=system:serviceaccount:tenant-a:app","runFrom":"approved reviewer context","expectedBranches":[{"when":"both no","meaning":"two authorization negatives pass","nextEvidence":"test network/storage boundaries"},{"when":"yes","meaning":"tenant escape grant","nextEvidence":"contain and trace binding"}],"proves":"two authorization decisions","doesNotProve":"full tenant isolation"},
    {"id":"LES-0045-CMD-012","question":"Does the deterministic security-gate model cover eight cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0045 support/lab normal Ubuntu user","expectedBranches":[{"when":"verification pass","meaning":"model/refusals/cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first case"}],"proves":"deterministic model","doesNotProve":"API RBAC secret admission runtime or tenancy","cleanup":"verifier proves exact absence"}
  ],
  "labs":[{"id":"LES-0045-LAB-001","title":"Guided API security decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no cluster","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped root","eight deterministic decisions"],"abortConditions":["root","network","kubectl","credential","symlink","unknown artifact"],"recovery":"Preserve first failed gate and rerun clean.","cleanupProof":"Exact inventory and absence.","path":"drafts/LES-0045-kubernetes-identity-rbac-admission-tenancy/support/lab"},{"id":"LES-0045-LAB-002","title":"Independent pinned local-cluster tenant transfer","mode":"independent","environment":"Reviewer-owned disposable cluster and two namespaces","timeMinutes":240,"privilege":"namespace learner; reviewer controls cluster policy","network":"local only","changes":["service accounts/RBAC","Pod Security/admission","secret/token and cross-tenant negative tests"],"abortConditions":["cluster-admin learner","real secret","external identity","privileged Pod","host access","webhook outage without rollback"],"recovery":"Preserve audit/decision evidence and recover through policy owner.","cleanupProof":"Reviewer proves bindings, tokens, secrets, policies, namespaces and cluster absent.","path":"drafts/LES-0045-kubernetes-identity-rbac-admission-tenancy/support/lab"}],
  "incidents":[{"id":"LES-0045-INC-001","signal":"API returns Unauthorized.","firstThought":"Authentication did not establish an acceptable identity.","safePath":"Bind server/context, credential type/expiry/audience and audit evidence without exposing token.","trap":"Add RBAC."},{"id":"LES-0045-INC-002","signal":"API returns Forbidden.","firstThought":"Identity exists but authorization denied exact action.","safePath":"Record subject/verb/group/resource/subresource/scope and trace minimal binding.","trap":"Grant cluster-admin."},{"id":"LES-0045-INC-003","signal":"Dry-run denied by admission.","firstThought":"Authorization passed but object policy rejected request.","safePath":"Read policy/webhook condition and correct manifest; do not bypass.","trap":"Disable admission globally."},{"id":"LES-0045-INC-004","signal":"Webhook latency blocks API writes.","firstThought":"Admission dependency is in write path with timeout/failure policy consequences.","safePath":"Contain matching requests, inspect endpoint/cert/latency and use reviewed rollback/break-glass.","trap":"Delete all webhooks."},{"id":"LES-0045-INC-005","signal":"Tenant service account can read another namespace Secret.","firstThought":"Authorization boundary is breached and credential/data exposure possible.","safePath":"Contain token/workload, trace binding/group aggregation, audit access, revoke/rotate and negative-test repair.","trap":"Only delete one Pod."}],
  "assessmentIds":["ASM-0118","ASM-0119","ASM-0120"],"referenceIds":["REF-0433","REF-0434","REF-0435","REF-0436","REF-0437","REF-0438","REF-0439","REF-0440","REF-0441","REF-0442","REF-0443","REF-0444","REF-0445","REF-0446","REF-0447"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No cluster/API security runtime.","Model is not authorization/admission evidence.","No real token/secret/cloud identity.","Formal review and learner evidence absent."]
}
---

# Kubernetes security: identity, RBAC, secrets, admission, and tenant boundaries

## What you see and first thought

`Unauthorized` means acceptable identity was not established. `Forbidden` means identity exists but the action was not authorized. An admission denial comes after authorization and rejects the proposed object. Start at the exact gate; do not “fix RBAC” for every denial.

## Terms before commands

Authentication establishes user/group identity. Authorization evaluates an action tuple. Admission mutates or validates create/update/delete/connect requests. Runtime controls enforce the resulting Pod on a node. RBAC connects subjects through bindings to role rules. Service accounts are namespaced workload identities. Secrets are base64-encoded API data, not automatically encrypted or safely exposed.

## Architecture map

```text
request -> authenticate -> authorize -> mutate -> validate -> persist
              |              |           |          |
           identity        RBAC       defaults     policy
                                                   |
                                        kubelet/runtime/kernel
```

Each gate has its own owner, logs, failure and rollback. TLS transport is necessary but separate from all four.

## Request or state path

The API server authenticates credentials into username/groups. Authorizers evaluate verb, API group, resource, subresource, namespace/name or non-resource URL. Mutating admission may change the object; validating admission can reject it. Persistence records accepted state and audit stages. Scheduler/kubelet/runtime later enforce node-side security.

Projected service-account tokens come from TokenRequest, can be audience/expiry/bound-object scoped and rotate. Legacy long-lived Secret tokens have different risk. Workloads that do not call the API should disable automount.

## Failure zoom

Unauthorized: verify endpoint/context, credential expiry, issuer/audience and authenticator. Forbidden: record exact tuple and trace role/binding, including groups and aggregated ClusterRoles. Admission denial: identify controller/policy/webhook and condition. Runtime permission: inspect securityContext, image identity, filesystem/capabilities/seccomp—not RBAC.

Webhook timeout/CA/endpoint failures can halt API writes depending on failurePolicy. Preserve the configuration UID and matching rules; broad emergency deletion can remove unrelated security controls.

## Internals and state ownership

Role is namespace-scoped; ClusterRole is cluster-scoped rules that can also be bound inside a namespace. RoleBinding grants within its namespace; ClusterRoleBinding grants cluster-wide. Wildcards, bind/escalate/impersonate, token creation, Secrets, pods/exec and workload creation are sensitive escalation paths.

RBAC is additive; there is no deny rule. Least privilege requires exact verbs/resources/scopes and negative tests. `kubectl auth can-i` is useful for a tuple but not complete proof of effective permissions or application need.

Pod Security Admission uses namespace labels for enforce, audit and warn levels/versions. Pin versions for controlled migration. SecurityContext controls user/group, privilege escalation, capabilities, seccomp, read-only root and more, but support/enforcement depends on OS/runtime.

Secrets need encryption at rest configuration, strict API RBAC, limited mounts, rotation and audit. A user who can create a Pod in a namespace may be able to consume Secrets indirectly; threat-model workload creation.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| authenticated | audit/caller identity | authorization |
| exact action allowed | subject/action/scope decision | admission |
| admission enforced | negative server dry-run denial | all bypasses |
| token bounded | issuer/audience/expiry/bound object | safe handling |
| Pod hardened | declared and runtime-observed controls | tenant isolation |
| tenant isolated | identity, network, quota, node, storage and negative tests | organizational governance |

## Command decoders

Never print tokens or Secret `.data`. Metadata, audit IDs and authorization reviews usually suffice. Impersonation flags require powerful permission and belong to reviewer/auditor workflows. `can-i --list` can be incomplete and should not replace exact negative tests.

Server dry-run exercises authorization and admission without persistence. Confirm the object remains absent. Audit logs may contain sensitive request data; sanitize and limit access.

## Decision path

1. Bind server/context/caller and audit ID.
2. Classify authentication, authorization, admission or runtime.
3. Record exact action/object/namespace and identity.
4. Trace minimal grant or policy owner.
5. Preserve tokens/Secrets without exposing values.
6. Contain compromised identity/workload and rotate where required.
7. Correct source policy with bounded rollback.
8. Verify allowed and denied actions plus user operation.
9. Prove revocation and cleanup.

## Guided Ubuntu lab

The model will cover eight decisions: expired audience token, missing RoleBinding, wildcard overgrant, token automount exposure, Secret metadata leak, Pod Security denial, webhook timeout policy and cross-tenant escape. It uses no cluster, credential or network. Wrong-gate answers and unknown cleanup must refuse.

## Production transfer

Use a reviewer-owned disposable cluster with two namespaces. Create minimal service accounts/RBAC, short-lived projected tokens, Pod Security labels, one validating policy/webhook fixture and synthetic Secrets. Prove allowed work, denied Secret access, denied cross-tenant actions, denied privileged Pod, runtime non-root controls and revocation.

No real secrets, external identity, cluster-admin learner, host namespaces, privilege or production webhook. Reviewer owns break-glass and exact cleanup.

## Reliability, security, observability, capacity, and cost

Admission is a reliability dependency in the API write path. Bound timeouts, narrow matching, redundant endpoints and tested failure policy. Security needs layered identity, RBAC, admission, runtime, network, storage and audit controls; namespaces alone are organizational scopes, not complete hard tenancy.

Observe authentication failures, authorization denies, admission latency/errors/denials, privileged requests, Secret access, token issuance, policy violations and cross-tenant attempts without logging credentials. Cost includes policy operations, audit retention and isolated nodes/clusters for strong tenants.

## Traps and prevention

Do not grant cluster-admin for Forbidden. Do not put Secret values in Git or logs. Do not assume base64 is encryption. Do not use wildcard RBAC casually. Do not disable admission globally. Do not rely on namespace alone. Do not use privileged Pods to fix permissions. Do not create long-lived tokens when projected tokens work.

## Memory card and retrieval

Remember **I-A-A-R**: Identity, Authorization tuple, Admission decision, Runtime enforcement. Then add Secret handling and Tenant negative tests. Explain user versus service account, Role versus ClusterRole, RoleBinding versus ClusterRoleBinding, authentication versus authorization, admission versus runtime, warn/audit versus enforce.

## Complete answers

**Why is Forbidden not authentication failure?** The API has an identity and denies the exact action. Record tuple and trace authorizer/RBAC.

**Are Secrets encrypted?** Not merely because they are Secret objects or base64 encoded. Verify encryption-at-rest configuration, keys, RBAC, transport, mounts and rotation.

**Does namespace provide tenant isolation?** Only one scope layer. Strong tenancy also needs identity/RBAC, admission, quota, network, runtime/node, storage, secrets, observability and operational boundaries.

## Product-company interview

A tenant service account reads another namespace Secret. Strong response: declare breach, bind token/SA/bindings/audit access, contain workload/token, trace RoleBinding/ClusterRoleBinding/group aggregation and escalation, determine accessed data, rotate affected secrets, apply least-privilege correction, prove allowed workload plus cross-tenant denies and add continuous authorization/audit detection. Deleting one Pod is insufficient.

## Independent transfer and rubric

Unseen cluster: expired token causes Unauthorized, a broad group binding causes Secret access, a Pod Security dry-run denial is legitimate, and a webhook timeout blocks unrelated writes. Produce gate classification, exact identities/action tuples, containment, safe webhook recovery, revocation and positive/negative tests.

Rubric: 15 classification, 15 identity/token, 15 RBAC graph/escalation, 10 Secret response, 15 admission/webhook, 10 runtime security, 10 tenancy, 10 recovery/verification. Reviewer-observed unseen evidence only.

## References and review

`REF-0433` through `REF-0447` are current official Kubernetes sources. Before publication, pin cluster/authenticator/authorizer/admission/runtime versions, execute allowed and denied cases, prove revocation and cleanup, and complete security/formal/learner review. A deterministic model is not security enforcement evidence.
