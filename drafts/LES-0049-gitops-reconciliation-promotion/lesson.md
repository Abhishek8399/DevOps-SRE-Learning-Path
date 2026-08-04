---
{"schemaVersion":1,"kind":"lesson","id":"LES-0049","slug":"gitops-reconciliation-promotion","aliases":["V05-L13","gitops-reconciliation-promotion"],"curriculumIds":["GITOPS-001"],"route":"/book/infrastructure/gitops-reconciliation-promotion","order":13,"volume":"05-infrastructure-platforms","title":"GitOps: reconciliation, promotion, drift, and safe recovery","summary":"Design pull-based continuous reconciliation with immutable inputs, explicit ownership, policy gates, controlled pruning, promotion evidence, and user-verified recovery across Argo CD and Flux.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":540,"prerequisiteLessonIds":["LES-0009","LES-0024","LES-0037","LES-0041","LES-0046","LES-0048"],"prerequisiteCurriculumIds":["SCM-001","CI-001","IAC-001","K8S-001","K8S-006","K8S-008"],"testedEnvironments":[{"platform":"OpenGitOps","version":"principles v1.0.0","support":"supported","notes":"Official principles reviewed 2026-08-04."},{"platform":"Argo CD documentation","version":"stable current documentation","support":"supported","notes":"Architecture, automated sync, waves, options, tracking and HA reviewed 2026-08-04."},{"platform":"Flux documentation","version":"current documentation","support":"supported","notes":"Core concepts, sources, Kustomization, HelmRelease, image automation, repository structure and security reviewed 2026-08-04."},{"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No Argo CD/Flux/controller/sync/drift runtime evidence."}],"targetRoles":["platform-engineer","site-reliability-engineer","devops-engineer","kubernetes-engineer","release-engineer","security-engineer","technical-lead"],"learningObjectives":["Explain declarative, versioned/immutable, pull and continuous-reconciliation GitOps principles without equating Git with truth.","Trace source revision and immutable artifacts through rendering, policy, reconciliation, health and user verification.","Compare Argo CD and Flux mechanisms without inventing feature parity.","Design repository and environment ownership that avoids duplicate field managers and promotion by rebuild.","Classify drift as unauthorized change, controller/defaulted state, intentional emergency action or comparison noise.","Design safe auto-sync, self-heal, prune, dependency, wave, health, timeout and suspension behavior.","Keep secrets, repository credentials, cluster credentials and signing trust out of unsafe Git surfaces.","Recover from bad commits, stuck sync, prune risk, controller outage and Git unavailability.","Scale GitOps controllers by repositories, manifests, objects, clusters, reconciliation queues and API load.","Produce an auditable promotion record tied to commit, artifact digest, policy, rollout and user SLI."],"productionSignals":["repository URL path ref resolved commit signer and protection policy","image/chart/OCI digest SBOM provenance policy result","renderer/tool/version/input and manifest digest","Argo Application source/destination project sync revision status health operation history tracking ID","Flux source artifact digest/revision/Ready condition and Kustomization/HelmRelease observedGeneration inventory","reconciliation interval queue depth duration result retries and suspension","live object UID generation owners/field managers tracking metadata and normalized diff","prune/delete candidate count propagation/finalizer and approval","dependency/wave/hook/health timeout and blocked resource","Git/OCI/Helm source fetch latency errors authentication and cache","Kubernetes API requests latency errors and controller RBAC","user journey SLI rollback/revert commit and recovery time","break-glass change owner expiry reconciliation decision and audit timeline"],"diagrams":[{"id":"LES-0049-DIA-001","title":"GitOps evidence path","direction":"left-to-right","boundaries":["reviewed change","immutable artifact","desired-state source","reconciler","API","controllers","service","user"],"evidencePoints":["commit","digest","policy","revision","health","SLI"],"textAlternative":"A reviewed change promotes immutable artifacts into desired state, which a reconciler applies through Kubernetes to user behavior."},{"id":"LES-0049-DIA-002","title":"Argo CD component path","direction":"left-to-right","boundaries":["Git","repo server","application controller","API server","resource tree","health"],"evidencePoints":["resolved revision","render","sync","tracking","operation"],"textAlternative":"Argo CD resolves and renders source through the repository server while the application controller compares and syncs live resources."},{"id":"LES-0049-DIA-003","title":"Flux source and reconciliation graph","direction":"hierarchical","boundaries":["GitRepository or OCIRepository","artifact","Kustomization or HelmRelease","dependencies","inventory","cluster"],"evidencePoints":["artifact digest","Ready condition","observedGeneration","inventory"],"textAlternative":"Flux source controllers produce artifacts consumed by specialized reconcilers that report conditions and inventory."},{"id":"LES-0049-DIA-004","title":"Promotion without rebuild","direction":"left-to-right","boundaries":["build once","digest","development pointer","staging pointer","production pointer","user evidence"],"evidencePoints":["same digest","review","policy","SLI"],"textAlternative":"One immutable artifact digest moves through environment declarations and gates without being rebuilt."},{"id":"LES-0049-DIA-005","title":"Drift decision tree","direction":"hierarchical","boundaries":["desired render","live normalized state","manager/defaulting","authorized emergency","unauthorized mutation","comparison noise"],"evidencePoints":["field manager","audit","tracking","diff rule"],"textAlternative":"Drift is classified by ownership and cause before self-healing, preserving emergency intent and avoiding ignored real defects."},{"id":"LES-0049-DIA-006","title":"Failure and recovery loop","direction":"cyclic","boundaries":["bad source","failed reconciliation","contain/suspend","revert or forward fix","resync","rollout","user verification"],"evidencePoints":["failed revision","decision","recovery revision","health","SLI"],"textAlternative":"A bad desired state is contained, corrected in the authoritative source, reconciled and verified at the user boundary."}],"commands":[{"id":"LES-0049-CMD-001","question":"What exact Git revision and manifests are proposed?","risk":"read-only","command":"git rev-parse HEAD; git status --short; git diff --check","runFrom":"reviewed desired-state checkout","expectedBranches":[{"when":"clean exact reviewed commit","meaning":"source identity bound","nextEvidence":"render/policy"},{"when":"dirty/unexpected","meaning":"proposal not reproducible","nextEvidence":"stop"}],"proves":"local checkout identity/state","doesNotProve":"remote protection or deployment"},{"id":"LES-0049-CMD-002","question":"What Argo CD revision, sync and health state is reported?","risk":"read-only","command":"argocd app get payments --refresh -o yaml","runFrom":"approved local CLI context","expectedBranches":[{"when":"expected source/destination/revision","meaning":"application state bound","nextEvidence":"resource diff/history"},{"when":"unexpected","meaning":"wrong app/cluster/revision","nextEvidence":"stop"}],"proves":"reported Argo CD application state","doesNotProve":"correct user behavior"},{"id":"LES-0049-CMD-003","question":"What would Argo CD change?","risk":"read-only","command":"argocd app diff payments --revision COMMIT","runFrom":"approved context and immutable revision","expectedBranches":[{"when":"bounded expected diff","meaning":"proposal reviewable","nextEvidence":"policy/sync"},{"when":"delete/secret/identity surprise","meaning":"unsafe proposal","nextEvidence":"stop"}],"proves":"Argo CD reported diff","doesNotProve":"future API or rollout"},{"id":"LES-0049-CMD-004","question":"Can a bounded manual Argo sync converge?","risk":"mutating-bounded","command":"argocd app sync payments --revision COMMIT --prune=false --timeout 600","runFrom":"reviewer-owned disposable application","expectedBranches":[{"when":"sync succeeds","meaning":"one operation completed","nextEvidence":"resource/user health"},{"when":"fails","meaning":"operation boundary failed","nextEvidence":"preserve failed resource"}],"proves":"one Argo CD sync operation","doesNotProve":"user success or safe pruning","cleanup":"delete disposable application/resources through reviewed ownership and prove absence"},{"id":"LES-0049-CMD-005","question":"What Flux source artifact was fetched?","risk":"read-only","command":"flux get sources git -A; kubectl get gitrepository -A -o yaml","runFrom":"approved cluster","expectedBranches":[{"when":"expected revision/digest and Ready","meaning":"source artifact bound","nextEvidence":"consumer reconcile"},{"when":"fetch/auth/not-ready","meaning":"source boundary failed","nextEvidence":"inspect condition"}],"proves":"reported Flux source state","doesNotProve":"application apply"},{"id":"LES-0049-CMD-006","question":"What Flux reconciliation state and inventory exist?","risk":"read-only","command":"flux get kustomizations -A; kubectl get kustomization -A -o yaml","runFrom":"approved cluster","expectedBranches":[{"when":"observed generation/revision ready","meaning":"reported reconciliation current","nextEvidence":"live objects/user"},{"when":"stale/failed/suspended","meaning":"reconciliation incomplete","nextEvidence":"conditions/events"}],"proves":"reported Kustomization state","doesNotProve":"application correctness"},{"id":"LES-0049-CMD-007","question":"Can a disposable Flux reconciliation be requested and observed?","risk":"mutating-bounded","command":"flux reconcile kustomization payments --with-source --timeout=10m","runFrom":"reviewer-owned disposable namespace","expectedBranches":[{"when":"Ready at expected revision","meaning":"one source/reconcile request completed","nextEvidence":"inventory/user"},{"when":"fails","meaning":"source/build/apply/health boundary","nextEvidence":"preserve conditions"}],"proves":"one Flux reconciliation request","doesNotProve":"production promotion","cleanup":"remove disposable source/Kustomization/inventory through reviewed path and prove absence"},{"id":"LES-0049-CMD-008","question":"Has live drift changed object ownership or identity?","risk":"read-only","command":"kubectl get deployment payments -n stage -o yaml; kubectl get events -n stage --sort-by=.metadata.creationTimestamp","runFrom":"approved namespace","expectedBranches":[{"when":"tracking/field managers/audit align","meaning":"drift owner identifiable","nextEvidence":"classify before heal"},{"when":"unknown manager/identity","meaning":"ownership conflict","nextEvidence":"stop automation"}],"proves":"selected object/event state","doesNotProve":"complete audit history"},{"id":"LES-0049-CMD-009","question":"Which resources would pruning remove?","risk":"read-only","command":"argocd app resources payments --orphaned; argocd app diff payments","runFrom":"approved Argo context","expectedBranches":[{"when":"expected owned disposable removals","meaning":"prune candidates reviewable","nextEvidence":"approval"},{"when":"shared/stateful/unknown","meaning":"data/blast risk","nextEvidence":"stop"}],"proves":"reported candidates/diff","doesNotProve":"safe deletion"},{"id":"LES-0049-CMD-010","question":"Is a HelmRelease current and remediating safely?","risk":"read-only","command":"flux get helmreleases -A; kubectl get helmrelease -A -o yaml","runFrom":"approved cluster","expectedBranches":[{"when":"expected revision/conditions/remediation","meaning":"reported release state bound","nextEvidence":"Helm/user evidence"},{"when":"retry loop/failure","meaning":"release reconciliation failing","nextEvidence":"stop amplification"}],"proves":"reported Flux HelmRelease state","doesNotProve":"data compatibility"},{"id":"LES-0049-CMD-011","question":"Did recovered desired state restore the user path?","risk":"read-only","command":"kubectl get deployment,pod,service,endpointslice -n stage -o wide","runFrom":"approved namespace","expectedBranches":[{"when":"revision/readiness/endpoints align","meaning":"selected cluster layers recovered","nextEvidence":"run synthetic user transaction"},{"when":"degraded","meaning":"recovery incomplete","nextEvidence":"conditions/logs/dependencies"}],"proves":"selected Kubernetes state","doesNotProve":"user transaction"},{"id":"LES-0049-CMD-012","question":"Does the offline GitOps model cover eight cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0049 support/lab normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"model/refusals/cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic teaching model","doesNotProve":"Git Argo Flux Kubernetes or production runtime","cleanup":"verifier proves exact state absence"}],"labs":[{"id":"LES-0049-LAB-001","title":"Guided GitOps reconciliation decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no GitOps controller","timeMinutes":180,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","eight deterministic GitOps cases"],"abortConditions":["root","network","credential","cluster","repository mutation","symlink","unknown artifact"],"recovery":"Preserve first failed gate and clean exact root.","cleanupProof":"Exact inventory and absence.","path":"drafts/LES-0049-gitops-reconciliation-promotion/support/lab"},{"id":"LES-0049-LAB-002","title":"Independent Argo-or-Flux promotion and recovery transfer","mode":"independent","environment":"Reviewer-owned disposable local cluster and local Git remote","timeMinutes":240,"privilege":"namespace-scoped learner; reviewer owns controller and credentials","network":"local only","changes":["immutable synthetic release","two environment pointers","drift/bad commit/prune/source outage faults"],"abortConditions":["production","real secret","public remote","cluster-admin learner","unsigned mutable artifact","unreviewed prune","irreversible data"],"recovery":"Contain/suspend only under runbook, preserve evidence, correct source, reconcile and verify user.","cleanupProof":"Reviewer proves controller objects, applications, repository, credentials and namespaces absent.","path":"drafts/LES-0049-gitops-reconciliation-promotion/support/lab"}],"incidents":[{"id":"LES-0049-INC-001","signal":"Application is OutOfSync after a manual emergency change.","firstThought":"Classify authorized temporary break-glass versus unauthorized drift before self-heal.","safePath":"Bind audit/field manager/change expiry, preserve emergency intent, then encode source or revert deliberately.","trap":"Enable self-heal immediately."},{"id":"LES-0049-INC-002","signal":"A bad commit continuously fails reconciliation.","firstThought":"Desired state is harmful and retry may amplify API or hook load.","safePath":"Contain retries/suspend under runbook, preserve failed revision, revert or forward-fix source, then resync once.","trap":"Patch live resources while source remains bad."},{"id":"LES-0049-INC-003","signal":"Prune proposes deletion of a shared or stateful resource.","firstThought":"Tracking/ownership/repository path may be wrong; deletion has data and cross-app blast radius.","safePath":"Stop prune, bind tracking ID/owner/finalizer/data policy and repair authoritative ownership.","trap":"Approve because resource disappeared from Git."},{"id":"LES-0049-INC-004","signal":"Git source is unavailable but workloads still run.","firstThought":"Serving and reconciliation availability have separated; freeze unsafe promotion and preserve current cluster state.","safePath":"Inspect controller cache/source errors/credentials, restore source through trusted path and reconcile unchanged revision first.","trap":"Recreate desired state from live output as truth."},{"id":"LES-0049-INC-005","signal":"GitOps reports Synced/Ready but users fail.","firstThought":"Desired/live convergence and authored health checks do not prove application/dependency behavior.","safePath":"Trace rollout, endpoints, configuration/data compatibility and exact user SLI; correct source and reconcile.","trap":"Close incident on green GitOps status."}],"assessmentIds":["ASM-0130","ASM-0131","ASM-0132"],"referenceIds":["REF-0493","REF-0494","REF-0495","REF-0496","REF-0497","REF-0498","REF-0499","REF-0500","REF-0501","REF-0502","REF-0503","REF-0504","REF-0505","REF-0506","REF-0507"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No Argo CD or Flux runtime.","No real Git/OCI/controller/cluster reconciliation.","Offline model is not product evidence.","Formal review and learner evidence absent."]}
---

# GitOps: reconciliation, promotion, drift, and safe recovery

## What you see and first thought

`Synced` means a GitOps controller sees live state matching its computed desired state. It does not mean users are successful. `OutOfSync` means there is a difference, not that live state is automatically wrong. First bind source revision, rendered desired objects, live ownership and the user operation.

GitOps is not “put YAML in Git.” Its operating promise requires declarative desired state, durable version history, automated pull and continuous reconciliation. The reconciler becomes a production control plane that needs security, capacity, SLOs and recovery.

## Terms before commands

**Desired state** is the authoritative declaration after resolving source and rendering. **Reconciliation** repeatedly compares desired and live state and attempts convergence. **Sync** is an Argo CD operation; **reconcile** is common Flux terminology. **Self-heal** corrects live drift. **Prune** deletes managed resources absent from desired state. **Suspend** pauses a Flux reconciliation; it is an incident tool with ownership and expiry, not a permanent fix.

Promotion changes an environment's desired reference to an already-built immutable artifact. Rebuilding for production creates a new artifact and breaks evidence continuity.

## Architecture map

```text
source change -> review/policy -> immutable revision/artifact
                                      |
Git/OCI/Helm source -> render -> GitOps controller -> Kubernetes API
                                             |             |
                                          status        controllers
                                                            |
                                                     service -> user
```

Argo CD commonly separates API/UI, repository rendering and application reconciliation. Flux composes source, Kustomize, Helm, notification and optional image automation controllers through Kubernetes APIs. Compare mechanisms and ownership, not logos.

## Request or state path

Argo CD resolves repository URL, target revision, path and tool inputs; the repository server generates manifests; the application controller compares live objects, reports sync/health and may execute sync, hooks and pruning. Resource tracking determines which application owns an object.

Flux source controllers fetch Git/OCI/Helm inputs and publish artifacts with revision/digest status. Kustomization or HelmRelease reconcilers consume sources, apply desired state, maintain inventory and report conditions. `dependsOn`, health checks, wait and timeout express ordering and readiness contracts.

## Failure zoom

If source fetch fails, distinguish network, authentication, trust, missing revision and repository-server capacity. Workloads may keep serving while new reconciliation stops. Do not promote from an untrusted local copy.

If rendering succeeds but apply fails, inspect API/admission/ownership exactly as in Helm/Kustomize and Kubernetes lessons. A health timeout can mean a controller never observed generation, a dependency stayed unhealthy, or the health model does not understand a custom resource.

Pruning is deletion automation. Bind tracking identity, owner, namespace, finalizers, data policy and cross-application sharing. An empty or wrong source path plus automated prune can have a large blast radius; guard empty sets and require review for stateful/shared deletion.

## Internals and state ownership

Git records desired-state history, not live truth, credentials, runtime status or application data. Pin commits or immutable OCI/chart/image digests at controlled boundaries. Branches and mutable tags are moving selectors; record the resolved identity actually reconciled.

One object should have one desired-state owner. Argo tracking metadata, Flux inventory, Kubernetes managed fields, Helm release ownership and other operators can conflict. Ignoring a diff is safe only when another known controller owns that exact field and the rule cannot hide security or availability drift.

Argo sync phases/waves and Flux dependencies can order resources but do not create distributed transactions. Hooks and migrations can have side effects. Automated retries, self-heal and remediation must be idempotent and bounded.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| desired state reviewed | protected commit, reviewer, policy, resolved inputs | live application |
| artifact promoted | same immutable digest across environments | runtime compatibility |
| source ready | fetched revision/artifact digest and condition | apply success |
| synchronized | desired/live identity and controller revision | user health |
| drift safe to heal | owner/audit/field classification | every hidden change |
| prune safe | exact owned delete set plus data/finalizer review | external cleanup |
| incident recovered | corrected source, reconcile and user SLI | recurrence prevention |

## Command decoders

`argocd app diff` computes the controller's comparison; normalization and ignore rules affect it. `argocd app sync --revision` is mutating and should use an immutable reviewed revision. A sync exit status does not prove the user path.

`flux get sources git` shows reported source revision and readiness. `flux get kustomizations` or `helmreleases` shows observed reconciliation state. `flux reconcile ... --with-source` requests source and consumer work; it is not a substitute for committing the fix.

Kubernetes object YAML exposes tracking labels/annotations, owner references and managed fields. Combine this with audit/change evidence before classifying drift.

## Decision path

1. Bind environment, controller, source, destination and user journey.
2. Bind reviewed commit and immutable artifact/config dependencies.
3. Render and validate policy without exposing secrets.
4. Inventory object identity, tracking, field ownership and prune candidates.
5. Define ordering, health, timeout, retry, self-heal and deletion behavior.
6. Promote the same digest by reviewed desired-state change.
7. Observe source fetch, render, apply, reconciliation, rollout and user SLI.
8. On failure, contain amplification and preserve the failed revision.
9. Correct authoritative source by revert or compatible forward fix.
10. Reconcile once, verify user recovery and expire break-glass/suspension.

## Guided Ubuntu lab

The offline model covers mutable artifact promotion, source-auth failure, render-policy denial, ownership conflict, authorized emergency drift, bad-commit retry, unsafe prune and green-sync/user-failure. Each case requires the earliest boundary and safe next action.

It opens no repository, network or cluster and refuses root, credentials, symlinks and unknown state. It is a decision model, not an Argo CD or Flux emulator.

## Production transfer

Use a local bare Git remote, synthetic service and reviewer-owned cluster. Choose Argo CD or Flux; document the comparison. Reconcile two environment directories that point to the same immutable image digest. Prove source revision, rendered digest, policy, live inventory and user response.

Inject one manual drift, one bad commit, one source outage and one prune-risk change. Recover only through the authoritative source except a timed documented break-glass action. Verify controller cleanup, credentials and namespaces are absent.

## Reliability, security, observability, capacity, and cost

Controller SLIs include source fetch, render, compare, reconcile duration/result, queue age, API errors, stale observed generations and notification delivery. Application SLIs remain user-centered. Alert on actionable stalled/degraded state and high-risk prune, not harmless transient diff.

Protect repository and cluster credentials, signing keys and decrypted secret material. Prefer read-only source credentials and namespace-scoped destination access. Never store plaintext secrets in Git or render logs; encrypted Git data still needs key lifecycle and access/audit design.

Capacity depends on repositories, monorepo size, render tools, object count, applications, clusters, polling/webhook patterns, cache/disk, queue processors and Kubernetes API load. Cost includes redundant controllers, cache/storage, CI policy, secret tooling and operator time. Too many repositories or abstractions can increase both blast radius and cognitive cost.

## Traps and prevention

- **Trap:** Git is always truth. **Prevention:** Git is desired-state authority; observe live/user truth separately.
- **Trap:** CI pushes directly and GitOps also reconciles. **Prevention:** one deployment owner; CI changes desired state.
- **Trap:** Promote by rebuilding. **Prevention:** move the same verified digest.
- **Trap:** Self-heal every drift. **Prevention:** classify owner and break-glass intent first.
- **Trap:** Ignore noisy fields broadly. **Prevention:** exact manager/path rules with tests.
- **Trap:** Auto-prune everything. **Prevention:** tracking, empty-set, state/data and approval guards.
- **Trap:** Patch live during bad source. **Prevention:** contain then fix source; time-bound exceptions.
- **Trap:** Synced equals healthy. **Prevention:** rollout, dependency and user SLI evidence.

## Memory card and retrieval

Remember **SOURCE → ARTIFACT → RENDER → OWN → RECONCILE → USER**. GitOps improves audit and convergence only when identity and ownership remain intact across that chain.

Tomorrow answer: Why is a branch not immutable? Why can self-heal be dangerous during break-glass? What makes prune risky? Why should CI usually not hold cluster credentials? What evidence comes after Synced/Ready?

## Complete answers

**GitOps versus CI deploy?** CI should build/test/sign immutable artifacts and propose a desired-state change. A pull-based in-cluster controller can reconcile without giving each CI runner destination credentials. Some systems intentionally use push delivery, but then ownership and audit must remain explicit.

**How do I roll back?** Revert or update desired state to a known compatible artifact/config, then let the controller reconcile and verify users. If data or hooks changed irreversibly, use a compatible forward fix or governed data recovery rather than assuming Git history reverses state.

**What about emergency kubectl changes?** Use an approved, audited, time-limited break-glass process. Decide whether to suspend/self-heal, encode the intended change in source quickly, then remove the temporary divergence and prove reconciliation.

**Argo CD or Flux?** Choose from desired APIs, tenancy, source types, UI/CLI needs, Helm/Kustomize behavior, scaling, security and team ownership. Both implement reconciliation patterns; their CRDs, components and operational mechanisms differ.

## Product-company interview

**Question:** Design GitOps for 200 services across development, staging and production.

**Strong answer:** CI builds once, signs and publishes immutable artifacts. Environment declarations promote digests through reviewed PRs with policy and separation of duties. GitOps controllers have least-privilege destination access, explicit repository/application boundaries and one owner per field. Production uses sync windows or approval where risk warrants, health and user SLI gates, guarded pruning, drift/audit handling and tested controller/source outage recovery. I capacity-plan render and API load and measure reconciliation delay rather than promising instant convergence.

**Weak answer:** Install Argo CD and enable auto-sync/self-heal/prune on the main branch. It ignores immutable artifacts, tenancy, deletion risk, secret handling, scale and recovery.

## Independent transfer and rubric

The reviewer supplies an unseen repository/controller case with a mutable tag, duplicate owner, authorized emergency drift, broad ignore rule, bad commit loop, unsafe prune and green controller state despite user failure. The learner must design promotion, contain the incident and prove corrected source, live state and user recovery. `ASM-0132` keeps its solution reviewer-only.

Reading and model output do not award mastery. The evidence requires an unseen changed case, independently observed reconciliation, safe failure handling, cleanup and delayed retrieval.

## References and review

Fifteen official OpenGitOps, Argo CD and Flux sources cover principles, architecture, source artifacts, automated sync, waves/options/tracking, high availability, Kustomization, HelmRelease, image automation, repository design and security. They were reviewed 2026-08-04 and require review by 2027-02-04.

Product APIs and defaults change. Pin exact Argo CD/Flux/controller versions, Kubernetes versions and source types before using any operational command.
