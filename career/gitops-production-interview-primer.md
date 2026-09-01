# GitOps production interview: the repository is intent, not a magic rollback button

GitOps makes desired state reviewable and repeatable. It does not make a bad commit safe, prove a controller applied it, or guarantee that a reconciled object delivers a healthy user journey.

```text
reviewed intent -> repository revision -> reconciler -> cluster state -> workload -> user outcome
       |                  |                |              |             |             |
     policy             promotion        trust/drift      admission     readiness    customer proof
```

## Scenario 1: a Git commit is merged, but the change never reaches the cluster

**Question:** The pull request is approved and merged, but the production behavior is unchanged. What do you inspect?

**Strong answer:** I trace the chain instead of assuming merge equals deployment. I establish the exact repository revision, branch/environment mapping, promotion artifact, reconciler source reference, last fetch/reconcile time, authentication/trust status, rendered manifest, admission result, namespace/cluster context, workload revision, and user path. A controller can be healthy while watching the wrong branch, path, revision, cluster, or tenant.

I avoid forcing a broad sync before identifying the mismatch. A force action can overwrite a legitimate emergency containment or apply unrelated queued changes. I correct the proven source/ref/rendering/authentication issue, reconcile the smallest intended scope, then verify both object state and the customer operation. Prevention is explicit revision/status visibility, environment identity assertions, drift/reconcile alerts, and a release record that binds source revision to rendered artifact and deployed revision.

**Weak answer:** "Click sync again." A manual sync can hide why automated reconciliation lost the desired state and may broaden the blast radius.

**Senior follow-up:** What does `Synced` prove? It proves a controller's comparison of selected desired and observed objects under its configuration. It does not prove workload readiness, routing, dependencies, or user success.

## Scenario 2: manual emergency change conflicts with reconciliation

**Question:** During an incident, an engineer changes a live object directly. The controller reverts it. What is the safe response?

**Strong answer:** I separate emergency containment from desired state. I identify the exact object/field, owner, reason, user impact, incident timeline, controller policy, and whether the change is still necessary. I do not disable GitOps globally or repeatedly fight reconciliation. I pause or scope reconciliation only through the approved, auditable mechanism, with an expiry and owner, then decide whether to codify the emergency change, stage its rollback, or hold it while evidence is incomplete.

The reconciliation design must make break-glass visible: a controlled exception, maintenance marker, decision record, and later convergence review. After recovery, I verify the real user path and reconcile code/live state deliberately. A clean Git diff does not make an expired containment safe to remove automatically.

**Weak answer:** "Git is the source of truth, so let it overwrite the live change." Code cannot infer whether an active incident containment is still needed.

**Senior follow-up:** What makes a manual change acceptable? Explicit authority, exact scope, time bound, audit trail, risk/rollback plan, and a clear path back to reviewed desired state.

## Scenario 3: promotion deploys the wrong image

**Question:** A production environment references a tag that was rebuilt after staging validation. What must change?

**Strong answer:** I bind promotion to immutable artifact identity, not a mutable name. A tag is a pointer that can move; an image digest identifies exact content for a registry/repository scope. The release record ties source revision, build inputs, dependency resolution, artifact digest, provenance/signature verification where applicable, environment approval, rendered manifest, and deployed workload revision.

I stop promotion if the digest cannot be traced to the reviewed artifact. I do not "rebuild the same tag" and call it equivalent. Recovery selects the last known-good immutable identity and verifies the workload and user operation. Prevention includes protected promotion paths, tag immutability or policy, provenance verification, admission controls, artifact retention, and a test that detects a changed tag/digest binding.

**Weak answer:** "The tag is `release-42`, so it is the tested release." Human-readable tags are useful labels; they are not immutable evidence.

**Senior follow-up:** Does a signed artifact guarantee it is authorized for production? No. Signature authentication proves who signed under a trust policy; authorization still needs allowed identity, policy, environment, vulnerability/exception state, and release decision.

## Scenario 4: a secret is committed to the desired-state repository

**Question:** A plaintext credential appears in a GitOps repository. What is your incident response?

**Strong answer:** I treat it as potential exposure to every reader, clone, cache, CI log, controller, backup, and downstream system that could access the revision. I restrict access according to the security process, preserve audit evidence, identify secret owner/scope/expiry and repository/artifact distribution, rotate or revoke through the owning identity system, and assess deployment impact. Removing the line from the current branch does not remove prior revisions or copied artifacts.

The corrective design keeps secret material out of normal manifests and logs. It uses an approved secret-management/injection boundary, least-privilege controller identity, environment-scoped references, policy checks, and clear rotation/reconciliation behavior. Encryption in Git may reduce exposure for a defined key/access boundary, but it does not remove lifecycle, authorization, plaintext-at-runtime, or controller-memory risks.

**Weak answer:** "Force-push history and it is solved." History rewriting can disrupt investigation and does not revoke copied or deployed credentials.

**Senior follow-up:** What proves rotation is complete? The old credential is invalid at its authority, dependent workloads use the replacement successfully, and access/distribution assessment is owned. A repository scan alone cannot prove absence from all copies.

## Scenario 5: a reconciler outage causes drift during a release

**Question:** The GitOps controller is unavailable while teams continue to merge changes. How do you manage the risk?

**Strong answer:** I establish whether the control plane is unavailable, delayed, partitioned, unauthorized, overloaded, or merely reporting stale status; then I identify the queue of unapplied revisions and the live state at each environment. I pause automatic promotion where applying a backlog later could create an unsafe bundle. A controller outage is a delivery-state incident: the repository may advance while production remains unchanged.

I recover the controller through its own runbook and trust boundaries, validate its selected sources/credentials/cluster context, then reconcile in a bounded, ordered manner with health gates. I do not apply every pending revision blindly. If a manual emergency path is used, it gets the same scoped authority, audit, and later reconciliation described for drift. Prevention includes controller HA/capacity, alerting on staleness and reconcile errors, dependency-aware promotion, and tested recovery that proves live/repository state alignment.

**Weak answer:** "Keep merging; it will catch up later." Catch-up can combine changes that were never validated together and hide which revision caused harm.

**Senior follow-up:** What is an acceptable reconciliation lag? A product-specific contract based on change criticality, environment, risk, and recovery needs—not a universal controller default.

## Scenario 6: rollback restores manifests but customers still fail

**Question:** Git revert restores the previous deployment manifest, but customers still see errors. What did rollback miss?

**Strong answer:** Git rollback restores selected desired state; it does not reverse database migrations, external side effects, caches, traffic routing, feature flags, secret rotation, queued work, client compatibility, or dependency state. I identify the deployed revision, data/event/configuration transitions, live traffic and endpoints, and the user operation. Then I choose a compatible forward fix, bounded rollback, data recovery, or controlled degradation based on reversibility and ownership.

The release design separates reversible compute changes from stateful transitions. It uses compatible migration patterns, explicit rollback limits, staged traffic, post-deploy user checks, and a documented recovery route. I call rollback successful only after the defined user operation and stability gates recover—not because Git shows the old commit.

**Weak answer:** "Revert the commit and close the incident." The desired manifest may be old while the system's durable state is new.

**Senior follow-up:** What is the best rollback prevention? Design every release around state compatibility, bounded blast radius, observable gates, and a tested forward/recovery plan before the incident exists.

## Fast decision map

| Signal | Remember | First safe move |
|---|---|---|
| merged but unchanged | Merge is not reconciliation | Trace revision, source/ref, render, controller, object, and user path |
| emergency drift | Desired state cannot infer incident policy | Create an owned, expiring reconciliation exception |
| tag promotion | Tag is not immutable release identity | Bind approval to artifact digest and provenance |
| secret in repository | Removal is not rotation | Contain, assess scope, rotate/revoke, then redesign boundary |
| controller outage | Repository advance is not deployment | Pause unsafe promotion and recover/reconcile in order |
| revert but users fail | Manifest rollback is not system rollback | Trace data, routing, flags, dependencies, and user outcome |

## Practice

For a GitOps incident, state the intended revision, observed live revision, controller proof limit, owner of each mutable boundary, smallest safe reconciliation, and user-facing recovery proof. That makes GitOps an operational system instead of a deployment slogan.
