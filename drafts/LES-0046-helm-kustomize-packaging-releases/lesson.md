---
{"schemaVersion":1,"kind":"lesson","id":"LES-0046","slug":"helm-kustomize-packaging-releases","aliases":["V05-L10","helm-kustomize-packaging-releases"],"curriculumIds":["K8S-006"],"route":"/book/infrastructure/helm-kustomize-packaging-releases","order":10,"volume":"05-infrastructure-platforms","title":"Helm and Kustomize: packaging, rendering, releases, and safe change","summary":"Choose deliberately between parameterized packages and declarative overlays, render deterministically, inspect the exact diff, and treat release success as a chain from source to users.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":540,"prerequisiteLessonIds":["LES-0009","LES-0024","LES-0041","LES-0042","LES-0045"],"prerequisiteCurriculumIds":["SCM-001","CIC-001","K8S-001","K8S-002","K8S-005"],"testedEnvironments":[{"platform":"Helm documentation","version":"current documentation","support":"supported","notes":"Chart, template, values, hooks, tests, lint, template, upgrade, rollback, provenance, and registry sources reviewed 2026-08-04."},{"platform":"Kubernetes documentation","version":"current documentation","support":"supported","notes":"Kustomize task and reference sources reviewed 2026-08-04."},{"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No API, rollout, Helm release, or Kustomize apply runtime evidence."}],"targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","kubernetes-engineer","release-engineer","technical-lead"],"learningObjectives":["Choose Helm, Kustomize, or a bounded combination from reuse and ownership requirements.","Trace a change through sources, values or overlays, rendering, API admission, reconciliation, rollout, user verification, and release history.","Explain chart structure, values precedence, templates, dependencies, hooks, tests, OCI distribution and provenance boundaries.","Explain Kustomize resources, bases, overlays, components, patches, replacements, generators and name transformations.","Detect type drift, selector drift, generated-name propagation, duplicate ownership and nondeterministic output before apply.","Design safe install, upgrade, rollback, timeout and cleanup procedures.","Distinguish render, lint, schema, server validation, diff, rollout, service and user evidence.","Diagnose partial upgrades, hook failures, CRD ordering, immutable-field failures and rollback incompatibility.","Protect secrets and credentials across values, manifests, release storage and CI logs.","Produce an auditable release packet tied to source, inputs, renderer and observed outcome."],"productionSignals":["source commit and dependency digests","chart name/version/appVersion and lock digest","values files/order/schema/type and secret source","Kustomization resources/components/patches/replacements/generators","renderer product/version/flags and output digest","object identity API version kind namespace name and ownership labels","client and server validation/admission results","normalized diff and immutable-field changes","Helm release name namespace revision status/history","hook type weight delete policy Job outcome and side effects","controller generation observedGeneration conditions rollout status","Service endpoints readiness user journey SLI and error budget","rollback target image/config/schema compatibility","cleanup inventory and generated/retained state"],"diagrams":[{"id":"LES-0046-DIA-001","title":"Change evidence chain","direction":"left-to-right","boundaries":["source","inputs","renderer","API","controllers","workload","service","user"],"evidencePoints":["commit","input digest","render digest","admission","conditions","journey"],"textAlternative":"A release travels from reviewed source and inputs through rendering, API admission, reconciliation, workload and service behavior to the user operation."},{"id":"LES-0046-DIA-002","title":"Helm package and release state","direction":"left-to-right","boundaries":["Chart.yaml","templates","values","dependencies","render","release record","cluster objects"],"evidencePoints":["chart version","lock digest","revision","status"],"textAlternative":"Helm combines chart metadata, templates, ordered values and locked dependencies into manifests and records a named release revision separately from Kubernetes objects."},{"id":"LES-0046-DIA-003","title":"Kustomize composition graph","direction":"hierarchical","boundaries":["base resources","components","overlay","patches","replacements","generators","rendered objects"],"evidencePoints":["resource identity","patch target","generated hash","output digest"],"textAlternative":"A Kustomize overlay composes resources and optional components, then applies transformations, patches, replacements and generators to produce objects."},{"id":"LES-0046-DIA-004","title":"Validation ladder","direction":"top-to-bottom","boundaries":["syntax","schema","render","policy","diff","rollout","service","user"],"evidencePoints":["lint","schema result","server dry-run","diff","conditions","SLI"],"textAlternative":"Each validation level catches a different class of failure; success below never proves success above."},{"id":"LES-0046-DIA-005","title":"Upgrade and rollback state machine","direction":"left-to-right","boundaries":["pending","rendered","submitted","reconciling","healthy","failed","rollback","verified"],"evidencePoints":["revision","timeout","conditions","rollback target","user check"],"textAlternative":"An upgrade can fail after rendering or submission; rollback is a new change that must reconcile and restore the user operation."},{"id":"LES-0046-DIA-006","title":"Ownership boundary","direction":"hierarchical","boundaries":["package owner","environment owner","policy owner","application owner","data owner","incident commander"],"evidencePoints":["source of truth","approval","rollback authority","compatibility decision"],"textAlternative":"Package, environment, policy, application and data ownership must be explicit because a tool cannot resolve conflicting intent or safe rollback alone."}],"commands":[{"id":"LES-0046-CMD-001","question":"Is the chart structurally valid?","risk":"read-only","command":"helm lint ./chart --values environments/stage-values.yaml --strict","runFrom":"reviewed source checkout","expectedBranches":[{"when":"passes","meaning":"chart lint checks passed","nextEvidence":"render exact inputs"},{"when":"fails","meaning":"chart structure/template/value issue","nextEvidence":"fix source"}],"proves":"Helm lint result","doesNotProve":"API acceptance or runtime"},{"id":"LES-0046-CMD-002","question":"What exact Helm manifests will these inputs render?","risk":"read-only","command":"helm template payments ./chart --namespace stage --values environments/common.yaml --values environments/stage.yaml --set-string image.tag=abc123 > rendered.yaml","runFrom":"reviewed checkout with no secrets in values","expectedBranches":[{"when":"stable reviewed output","meaning":"client render captured","nextEvidence":"schema/policy/diff"},{"when":"unexpected object/value","meaning":"input or template defect","nextEvidence":"stop"}],"proves":"client-side render for exact arguments","doesNotProve":"server defaults, admission or rollout"},{"id":"LES-0046-CMD-003","question":"Do values satisfy the chart contract?","risk":"read-only","command":"helm lint ./chart --values environments/stage.yaml --strict","runFrom":"reviewed checkout","expectedBranches":[{"when":"schema/type validation passes","meaning":"declared contract satisfied","nextEvidence":"inspect semantics"},{"when":"type/key failure","meaning":"values contract broken","nextEvidence":"repair inputs/schema"}],"proves":"implemented chart validation","doesNotProve":"business correctness"},{"id":"LES-0046-CMD-004","question":"What release state already exists?","risk":"read-only","command":"helm status payments -n stage; helm history payments -n stage --max 10","runFrom":"approved cluster context","expectedBranches":[{"when":"expected owner/revision","meaning":"upgrade baseline bound","nextEvidence":"inspect diff"},{"when":"missing/unexpected","meaning":"identity or history mismatch","nextEvidence":"stop"}],"proves":"reported Helm release state","doesNotProve":"all live-object drift"},{"id":"LES-0046-CMD-005","question":"Can a bounded upgrade converge?","risk":"mutating-bounded","command":"helm upgrade --install payments ./chart -n stage --create-namespace --values environments/stage.yaml --atomic --wait --timeout 10m","runFrom":"reviewer-owned disposable namespace after diff approval","expectedBranches":[{"when":"healthy revision","meaning":"Helm wait criteria completed","nextEvidence":"service/user checks"},{"when":"failure/rollback","meaning":"upgrade did not meet wait contract","nextEvidence":"preserve history/events"}],"proves":"one bounded release attempt and Helm wait outcome","doesNotProve":"user journey or data compatibility","cleanup":"helm uninstall payments -n stage; verify release and owned disposable objects absent"},{"id":"LES-0046-CMD-006","question":"Can the chosen revision be restored?","risk":"mutating-bounded","command":"helm rollback payments 3 -n stage --wait --timeout 10m --cleanup-on-fail","runFrom":"approved incident procedure after compatibility review","expectedBranches":[{"when":"revision healthy","meaning":"rollback command and wait completed","nextEvidence":"verify schema/data/user"},{"when":"fails","meaning":"old desired state cannot safely converge","nextEvidence":"contain and use forward fix"}],"proves":"one rollback attempt","doesNotProve":"data reversal or user recovery","cleanup":"retain required audit/history; remove only disposable release under owner approval"},{"id":"LES-0046-CMD-007","question":"Do chart tests pass after rollout?","risk":"mutating-bounded","command":"helm test payments -n stage --logs --timeout 5m","runFrom":"disposable or approved test-capable release","expectedBranches":[{"when":"test Pods succeed","meaning":"authored chart tests passed","nextEvidence":"user-path SLI"},{"when":"fail","meaning":"test contract failed","nextEvidence":"preserve Pod logs/events"}],"proves":"declared Helm test hooks","doesNotProve":"complete production behavior","cleanup":"delete retained test resources according to reviewed hook/test policy"},{"id":"LES-0046-CMD-008","question":"What exact Kustomize objects render?","risk":"read-only","command":"kubectl kustomize overlays/stage > rendered.yaml","runFrom":"reviewed source checkout","expectedBranches":[{"when":"stable expected objects","meaning":"overlay rendered","nextEvidence":"validate identities and diff"},{"when":"collision/patch error","meaning":"composition invalid","nextEvidence":"repair overlay"}],"proves":"local Kustomize render","doesNotProve":"API acceptance"},{"id":"LES-0046-CMD-009","question":"Will the rendered proposal pass the API without persistence?","risk":"mutating-bounded","command":"kubectl apply --dry-run=server -n stage -f rendered.yaml -o yaml","runFrom":"approved disposable namespace","expectedBranches":[{"when":"accepted","meaning":"current API/admission accepts proposal","nextEvidence":"diff"},{"when":"denied","meaning":"schema/admission/authorization failure","nextEvidence":"fix source"}],"proves":"server dry-run decision","doesNotProve":"controller rollout","cleanup":"prove dry-run created no object"},{"id":"LES-0046-CMD-010","question":"What live changes would this overlay request?","risk":"read-only","command":"kubectl diff -k overlays/stage","runFrom":"approved cluster context","expectedBranches":[{"when":"expected bounded diff","meaning":"reviewable proposal","nextEvidence":"approve change"},{"when":"delete/identity/selector surprise","meaning":"unsafe change","nextEvidence":"stop"}],"proves":"client/server reported diff","doesNotProve":"future controller behavior"},{"id":"LES-0046-CMD-011","question":"Did Kubernetes reconcile the new generation?","risk":"read-only","command":"kubectl get deployment/payments -n stage -o wide; kubectl get pod,service,endpointslice -n stage -o wide","runFrom":"approved namespace","expectedBranches":[{"when":"observed generation/readiness/endpoints align","meaning":"workload and service evidence improved","nextEvidence":"user journey"},{"when":"timeout/degraded","meaning":"rollout failed or stalled","nextEvidence":"events/logs/conditions"}],"proves":"selected controller and object state","doesNotProve":"correct user behavior"},{"id":"LES-0046-CMD-012","question":"Does the offline release model cover eight failure cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0046 support/lab on Ubuntu 24.04 as a normal user","expectedBranches":[{"when":"verification passes","meaning":"model decisions/refusals/cleanup passed","nextEvidence":"retain model-only boundary"},{"when":"failure","meaning":"candidate fixture rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic teaching model","doesNotProve":"Helm Kustomize Kubernetes or production runtime","cleanup":"verifier proves exact state absence"}],"labs":[{"id":"LES-0046-LAB-001","title":"Guided packaging and release decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no Helm, Kustomize or cluster required","timeMinutes":180,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","eight deterministic release cases"],"abortConditions":["root","network","credential","cluster access","symlink","unknown artifact"],"recovery":"Preserve first failed gate, clean exact root, and rerun.","cleanupProof":"Exact inventory and state-root absence.","path":"drafts/LES-0046-helm-kustomize-packaging-releases/support/lab"},{"id":"LES-0046-LAB-002","title":"Independent package-versus-overlay release transfer","mode":"independent","environment":"Reviewer-owned disposable local cluster","timeMinutes":240,"privilege":"namespace-scoped learner; reviewer owns policy and cleanup","network":"local only","changes":["one Helm release","one equivalent Kustomize overlay","synthetic application and failure injection"],"abortConditions":["production context","real secret","cluster-admin","unreviewed CRD/hook","persistent data migration","unbounded namespace"],"recovery":"Preserve render/diff/history/events, then use reviewed rollback or forward fix.","cleanupProof":"Reviewer proves namespace, release, hooks, generated objects and temporary evidence absent or intentionally retained.","path":"drafts/LES-0046-helm-kustomize-packaging-releases/support/lab"}],"incidents":[{"id":"LES-0046-INC-001","signal":"helm template succeeds but API rejects an object.","firstThought":"Client rendering did not exercise current server schema, authorization or admission.","safePath":"Bind renderer/input digest and inspect server dry-run denial before any apply.","trap":"Assume a valid render is deployable."},{"id":"LES-0046-INC-002","signal":"Upgrade times out and release is failed or rolled back.","firstThought":"Find the first object/controller/hook that missed its wait contract.","safePath":"Freeze inputs, preserve history/events/conditions, classify workload versus hook versus API failure, then choose compatible rollback or forward fix.","trap":"Repeatedly rerun upgrade."},{"id":"LES-0046-INC-003","signal":"Kustomize overlay changes a selector or object name.","firstThought":"Identity transformation may orphan or replace resources.","safePath":"Inspect normalized render and diff, generated-name references, immutable fields and ownership before apply.","trap":"Trust a small patch file."},{"id":"LES-0046-INC-004","signal":"A pre-upgrade hook changed data, then the workload failed.","firstThought":"Hook side effect may not be reversed by release rollback.","safePath":"Bind hook Job/image/input/output, stop retries, consult data owner and recovery contract, then recover deliberately.","trap":"Assume Helm rollback undoes database work."},{"id":"LES-0046-INC-005","signal":"Rollback reports success but users still fail.","firstThought":"Helm state and workload readiness do not prove downstream/data/user compatibility.","safePath":"Verify image/config/schema/dependencies/endpoints and the exact user journey; forward-fix if old code cannot read new data.","trap":"Close incident on command exit zero."}],"assessmentIds":["ASM-0121","ASM-0122","ASM-0123"],"referenceIds":["REF-0448","REF-0449","REF-0450","REF-0451","REF-0452","REF-0453","REF-0454","REF-0455","REF-0456","REF-0457","REF-0458","REF-0459","REF-0460","REF-0461","REF-0462"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No Helm/Kustomize binary runtime.","No Kubernetes API, release, hook, CRD, rollout or rollback runtime.","The offline model is not product or cluster evidence.","Formal review and learner evidence absent."]}
---

# Helm and Kustomize: packaging, rendering, releases, and safe change

## What you see and first thought

When a deployment fails, do not begin with “Helm is broken” or “the overlay is wrong.” First locate the failure in the change path. Did source selection fail? Did values have the wrong type? Did rendering produce the wrong object? Did the API reject it? Did a controller accept it but fail to reconcile it? Did Pods become Ready while the user journey still failed?

Keep this sentence in memory: **rendered YAML is a proposal, not a successful release**. Helm and Kustomize can produce syntactically convincing manifests that are unsafe, rejected, stalled, or operationally wrong.

## Terms before commands

A **manifest** is a Kubernetes API-object declaration. **Rendering** produces manifests from higher-level inputs. A **package** gives a reusable application a versioned structure and parameter contract. A **release** is one named Helm installation in one namespace, with revision history. A **base** is reusable Kustomize resource composition; an **overlay** specializes it for an environment. A **patch** changes selected fields. A **generator** creates ConfigMaps or Secrets and normally adds a content hash to the name.

Helm uses Go templates plus ordered values. Kustomize transforms ordinary YAML without a template language. Neither approach owns the truth automatically: your Git workflow, release records, live objects, controllers and application state can disagree.

## Architecture map

```text
reviewed source + locked dependencies + environment inputs
                         |
                 Helm or Kustomize
                         |
                 deterministic render
                         |
        schema -> policy -> server dry-run -> diff
                         |
                      apply
                         |
 API -> admission -> controllers -> Pods -> Service -> user
                         |
             release history + telemetry
```

Helm is usually strongest when a reusable application needs a distributable version, explicit values contract, dependencies, release history and install/upgrade lifecycle. Kustomize is usually strongest when the organization owns concrete manifests and wants declarative environment composition with small, inspectable transformations. A combination can work—such as upstream Helm rendering followed by controlled policy—but avoid two tools silently owning the same fields.

## Request or state path

For Helm, bind the chart source, `Chart.yaml` version, locked dependencies, renderer version, release name/namespace, ordered values files, `--set` inputs and secret mechanism. Later values override earlier values; scalar/list/map type changes can produce surprising templates. `appVersion` describes the packaged application but does not control chart ordering by itself.

The client renders templates, then sends objects to the Kubernetes API. Helm stores release information so `status`, `history`, `upgrade` and `rollback` reason about revisions. Kubernetes controllers—not Helm—perform most convergence. `--wait` observes selected readiness conditions; it is not an end-user test.

Kustomize begins at a `kustomization.yaml`, loads declared resources and components, applies name/label/image transformations, generators, replacements and patches, then emits objects. Bases should express common truth; overlays should contain small environment differences. If an overlay is mostly a copy of the base, reuse has already failed.

## Failure zoom

A values failure can be a missing key, wrong type, unintended precedence, unsafe default or unescaped string. Use `--set-string` when a value must remain text; otherwise values such as leading-zero identifiers can be misinterpreted. Add `values.schema.json` so the contract fails before a cluster change.

A Kustomize patch can match no object, too many objects, or the wrong object after name/namespace transformations. Selector changes are especially dangerous because Deployments may reject immutable selectors or disconnect existing Pods and Services. Always review the full rendered identity set, not only the small patch.

Hooks run at lifecycle points and can be ordered by weight. They may create Jobs or mutate external state. Hook failure policies and deletion policies affect availability and cleanup. A data migration performed by a pre-upgrade hook does not become reversible because Helm can restore an older manifest revision.

CRDs add another lifecycle boundary. Installing a CRD and using its custom resources involves API discovery, conversion and compatibility. Treat CRD upgrades, deletion and rollback as platform changes with an owner; never assume an ordinary chart rollback reverses stored custom-resource data.

## Internals and state ownership

`Chart.yaml`, `values.yaml`, templates, optional JSON Schema, dependency metadata and a dependency lock form a Helm chart contract. Templates should quote strings deliberately, fail required invariants, avoid nondeterminism, and use named helpers without hiding resource ownership. Pin dependencies and record their digests. OCI registries distribute charts, while provenance verification answers who signed a package and whether bytes changed; it does not prove the package is secure or suitable.

Kustomize’s resource graph is intentionally YAML-centered. Components express optional reusable behavior. Replacements copy a value from a source field into target fields. Generators make configuration objects and update known references to hashed names, enabling configuration-triggered rollouts. Disabling the name suffix trades convenient stability for weaker automatic rollout signaling and potential ownership collisions.

One field needs one authoritative source. If Helm templates set replicas while an overlay, HPA and operator also change replicas, drift becomes permanent. Decide which layer owns package defaults, environment policy, runtime autoscaling and emergency overrides.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| source is reproducible | commit, dependency lock/digests, renderer version | safe behavior |
| values are valid | schema/lint result and ordered inputs | semantic correctness |
| render is stable | exact command and output digest | API acceptance |
| API accepts proposal | server dry-run/admission result | reconciliation |
| live change is bounded | normalized diff and object identities | rollout success |
| rollout completed | generation, conditions, Pods and endpoints | user success |
| Helm rollback completed | new revision/history and conditions | data compatibility |
| incident recovered | original user operation and SLI | future prevention |

This ladder stops false certainty. Each rung proves only its own boundary.

## Command decoders

`helm lint` evaluates chart conventions and rendered templates, and `--strict` converts warnings into failures. It is useful but not a Kubernetes server. `helm template` renders locally; it cannot know current admission policy, API discovery or live drift. Preserve the output digest without committing rendered secrets.

In `helm upgrade`, `--install` creates when the named release is absent. `--atomic` requests rollback on failed upgrade and implies waiting, while `--wait` and `--timeout` define bounded observation. This reduces partial-release duration, but cannot reverse external side effects or incompatible data migrations.

`kubectl kustomize` renders an overlay locally. `kubectl apply --dry-run=server` contacts the API and runs server validation/admission without persistence. `kubectl diff -k` compares the proposed overlay with live objects; examine deletes, recreations, identity changes and ownership conflicts. Exit status can represent differences, so CI must distinguish “diff found” from execution failure.

## Decision path

1. Bind cluster, namespace, application owner and user operation.
2. Bind source commit, package/dependency digests and exact renderer version.
3. Record ordered values or base/overlay/component inputs; exclude plaintext secrets.
4. Validate syntax, schema, template rules and deterministic render.
5. Inventory object identities and ownership; reject collisions and duplicate field owners.
6. Run policy and server dry-run in the approved scope.
7. Review the normalized live diff, immutable fields, deletion and replacement risk.
8. Define rollout, timeout, abort, rollback/forward-fix and data-compatibility gates.
9. Apply once; observe revision, events, generations, conditions, Pods and endpoints.
10. Verify the exact user operation and SLI, then prove cleanup or intentional retention.

## Guided Ubuntu lab

The local lab is deliberately not a fake Helm implementation. It models eight decisions: values type drift, rendered-name collision, selector drift, hook side effect, CRD ordering, partial upgrade, rollback incompatibility and overlay ownership conflict. Each case has one earliest failed boundary and one safe next action. Giving a later symptom as the root boundary must fail.

Run `bash lab.sh doctor`, then `bash lab.sh setup`, `bash lab.sh list`, one `bash lab.sh diagnose CASE`, and finally `bash verify.sh`. The harness refuses root, symlinks, unexpected files and state outside its exact UID-scoped `/tmp` directory. Its success proves only that the teaching decisions and lifecycle are deterministic.

## Production transfer

In a reviewer-owned disposable cluster, package the same synthetic service once as a Helm chart and once as a Kustomize base plus two small overlays. Record source, inputs and render digests. Introduce a wrong values type and a selector-changing patch; prove both are stopped before apply. Then perform one safe upgrade, one bounded failure and a reviewed rollback.

Compare authoring cost, discoverability, reuse, diff clarity, release history, policy integration and ownership. The answer need not select one universal winner. It must explain why the chosen tool matches who publishes the application, who owns environments, how many consumers exist and how releases are recovered.

## Reliability, security, observability, capacity, and cost

Reliability requires bounded timeouts, rollout gates, PodDisruptionBudget awareness, dependency ordering and a user-level verification. Security requires verified sources, pinned dependencies, protected values, no secret material in render logs, namespace-scoped credentials, policy validation and least-privilege hooks. A signed chart improves origin/integrity confidence, not runtime safety.

Observability connects release revision and source version to controller conditions, events, logs, metrics, traces and user SLIs. Avoid labels whose chart/revision values explode metric cardinality. Capacity review must include resource requests/limits, replicas, HPA ownership, surge/unavailable settings, quota and the temporary peak during rollout.

Cost comes from retained history, registry artifacts, CI rendering, test Jobs, surge capacity, duplicate environments and operational complexity. The cheapest template today may be expensive if every team forks it. Conversely, a highly abstract chart can hide intent and slow incidents. Optimize the whole ownership lifecycle.

## Traps and prevention

- **Trap:** `helm template` passed, so deploy. **Prevention:** validation ladder through user evidence.
- **Trap:** Put every environment difference in `--set`. **Prevention:** versioned, reviewed values with a schema; reserve CLI overrides for controlled cases.
- **Trap:** Store credentials in values or rendered artifacts. **Prevention:** approved secret delivery, redaction, access limits and retention rules.
- **Trap:** Use `latest` dependencies or images. **Prevention:** immutable version/digest plus recorded lock.
- **Trap:** Add many Helm conditions until one chart becomes every application. **Prevention:** stable contract, composition and separate packages when lifecycles diverge.
- **Trap:** Copy bases into overlays. **Prevention:** small transformations and explicit components.
- **Trap:** Let hooks perform irreversible work automatically. **Prevention:** idempotency, compatibility, backups, approval and tested recovery.
- **Trap:** Call rollback safe because the CLI returned zero. **Prevention:** data/dependency compatibility and original user-operation proof.

## Memory card and retrieval

Remember **SOURCE → RENDER → SERVER → DIFF → ROLLOUT → USER**. Helm answers “how do I package and operate a named release?” Kustomize answers “how do I compose and transform concrete resources?” They overlap at manifest generation, but their state and ownership models differ.

Ask tomorrow: Why is render not release? What is the difference between chart version and app version? Why can a hook make rollback unsafe? When does a hashed ConfigMap name help? What evidence comes after `rollout status`?

## Complete answers

**Should every team use Helm?** No. Use it when packaging, parameters, dependency distribution and release history solve a real ownership problem. For internally owned manifests with modest environment differences, Kustomize can be clearer.

**Can Kustomize replace Helm release history?** It renders resources but does not provide Helm’s named release revision model. Git history and deployment controllers may supply a different audit/reconciliation model.

**Why did rollback not repair users?** Old manifests may be incompatible with a changed database, external API, CRD or irreversible hook effect. Readiness may also be green while the actual journey fails.

**What should be committed?** Source manifests/templates, schemas, lockfiles and non-secret environment inputs. Generated output may be retained as a reviewed artifact when governance needs it, but avoid duplicate sources of truth and never retain plaintext secrets.

## Product-company interview

**Question:** You maintain one application deployed by forty teams. Choose Helm or Kustomize.

**Strong answer:** I first separate publisher and consumer ownership. A versioned Helm chart is attractive when the platform publishes a stable configuration contract, dependency bundle and upgrade lifecycle to many consumers. I would use JSON Schema, locked dependencies, immutable images, provenance, render/policy/server validation and release telemetry. If teams own the manifests and differences are small policy overlays, Kustomize may keep intent more visible. I would test upgrade/rollback and prevent consumers from patching fields owned by controllers.

**Weak answer:** Helm because it is industry standard. This ignores ownership, reuse, failure recovery, data compatibility and security.

**Senior follow-up:** A pre-upgrade migration succeeded but the new Pods failed. I freeze retries, preserve the hook Job and release evidence, determine whether the migration is backward compatible, bring in the data owner, and choose an old-compatible rollout or forward fix. I do not blindly rollback code against changed data.

## Independent transfer and rubric

The reviewer supplies an unseen chart, overlay and failure sequence. Produce an evidence packet containing source/input/render identities; choose the ownership model; detect one values type defect and one patch/identity defect; explain a hook or CRD lifecycle hazard; plan a bounded upgrade; recover from partial failure; and prove user operation plus cleanup. The hidden rubric is in `ASM-0123`; this chapter deliberately does not reveal its model solution.

Reading or running the deterministic model never awards mastery. Mastery requires an independently observed changed case, defensible trade-offs, safe execution and delayed retrieval.

## References and review

The reference records use official Helm and Kubernetes documentation for chart structure, templates, values, functions, hooks, tests, lint, rendering, upgrade, rollback, provenance, registries and Kustomize configuration management. They were reviewed on 2026-08-04 and require review by 2027-02-04 because command flags and version behavior can change.

Product documentation establishes supported behavior, not a universal production design. Validate exact client and server versions, plugins, admission policy, controller behavior and organizational release rules before use.
