---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0037",
  "slug": "infrastructure-as-code-foundations",
  "aliases": ["V05-L01", "infrastructure-as-code-foundations"],
  "curriculumIds": ["IAC-001"],
  "route": "/book/infrastructure/infrastructure-as-code-foundations",
  "order": 1,
  "volume": "05-infrastructure-platforms",
  "title": "Infrastructure as Code: turn infrastructure change into reviewable evidence",
  "summary": "Build the tool-neutral IaC mental model: desired configuration, dependency graph, remote objects, state bindings, refresh, plan, policy, approval, apply, partial failure, drift, import, refactor, verification and recovery.",
  "domain": "infrastructure",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0009", "LES-0021", "LES-0024"],
  "prerequisiteCurriculumIds": ["SCM-001", "AUT-005", "CI-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The bounded lab uses Bash and Python 3 as a normal user, makes no provider or network call, creates one exact UID-scoped temporary directory and models only fictional resources."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "Designed for the same normal-user contract; filesystem ownership and Windows-mounted repository behavior must be recorded."},
    {"platform": "Terraform and OpenTofu", "version": "concept-only", "support": "concept-only", "notes": "Commands are introduced as mappings only. No provider initialization, credential use, remote state, plan or apply is authorized by this lesson."},
    {"platform": "Cloud, Kubernetes and private infrastructure", "version": "concept-only", "support": "concept-only", "notes": "No configuration grants permission to inspect or change an account, cluster, hypervisor, network, DNS, identity, database or production system."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "infrastructure-engineer", "cloud-engineer", "production-engineer", "security-engineer", "technical-lead"],
  "learningObjectives": [
    "Explain infrastructure as a managed change system rather than a directory of configuration files.",
    "Separate desired configuration, remote reality, state bindings, refreshed observations, proposed plan and verified outcome.",
    "Build a dependency graph from references and justify the few cases that need explicit ordering.",
    "Read create, update, replace, delete, import, forget and no-op actions through availability, data and identity risk.",
    "Explain convergence and why repeated execution is not automatically safe or idempotent.",
    "Detect and classify drift without assuming that configuration, state or provider observation is universal truth.",
    "Protect state, plans, provider plugins, credentials and execution authority as sensitive supply-chain assets.",
    "Design validation, tests, policy, review, approval, rollout, abort, recovery and post-apply verification gates.",
    "Recover from partial execution without blindly rerunning, editing state or recreating stable resources.",
    "Defend environment, module, import, refactor and ownership boundaries with explicit trade-offs and evidence."
  ],
  "productionSignals": [
    "configuration revision, module source and dependency lock identity",
    "provider and tool versions with checksum or provenance evidence",
    "workspace, backend, account, project, subscription, region and tenant identity",
    "state serial, lineage, lock owner, lock age, storage version and encryption/access evidence",
    "refresh coverage, observation timestamp, unknown values and provider read failures",
    "plan artifact digest, configuration digest, prior-state digest and intended target boundary",
    "action counts and identities by create, read, update, replace, delete, import, forget and no-op",
    "policy decisions, exemptions, expiry, approver and evidence",
    "apply start/end, actor, exact plan, per-resource result, failure and partial-state persistence",
    "drift identity, source, first observed time, business owner and disposition",
    "post-change health, user SLI, security, cost, capacity and data-integrity checks",
    "rollback or roll-forward decision, reconciliation status and cleanup proof"
  ],
  "diagrams": [
    {"id": "LES-0037-DIA-001", "title": "The six IaC evidence layers", "direction": "left-to-right", "boundaries": ["configuration", "graph", "prior state", "remote observation", "plan", "verified outcome"], "evidencePoints": ["commit", "edges", "lineage", "refresh", "actions", "user checks"], "textAlternative": "Versioned configuration and prior state are combined with current remote observations to build a dependency graph and proposed plan; authorized execution creates a new state snapshot and must be verified against user outcomes."},
    {"id": "LES-0037-DIA-002", "title": "Desired, state and remote reality are different", "direction": "cyclic", "boundaries": ["desired configuration", "state bindings and cached attributes", "remote objects"], "evidencePoints": ["declared address", "remote identity", "refreshed attributes"], "textAlternative": "Configuration states intent, state maps addresses to remote object identities, and the provider observes remote reality. A plan compares these imperfect views; none alone proves the complete system."},
    {"id": "LES-0037-DIA-003", "title": "Dependency graph and change order", "direction": "hierarchical", "boundaries": ["network", "database", "service", "DNS", "monitoring"], "evidencePoints": ["implicit reference", "explicit edge", "parallel nodes", "destroy reversal"], "textAlternative": "References create graph edges. Independent resources can change in parallel; dependants wait for dependencies, and deletion normally reverses creation order."},
    {"id": "LES-0037-DIA-004", "title": "Governed plan-to-apply chain", "direction": "left-to-right", "boundaries": ["format", "validate", "test", "plan", "policy", "review", "approval", "apply exact artifact", "verify"], "evidencePoints": ["exit code", "test result", "digest", "decision", "actor", "run", "SLI"], "textAlternative": "A change progresses through syntax, semantic validation, tests, a saved reviewed plan, policy and human approval before the exact artifact is applied and user outcomes are verified."},
    {"id": "LES-0037-DIA-005", "title": "Partial failure and recovery", "direction": "cyclic", "boundaries": ["apply starts", "some resources succeed", "one fails", "state persists", "inspect", "repair or reconcile", "new plan"], "evidencePoints": ["resource result", "remote identity", "state serial", "first error", "new observation"], "textAlternative": "An apply may change some remote objects before failure. The tool records what it can; responders preserve evidence, inspect remote and state identity, repair the cause, produce a new plan and verify rather than assuming transaction rollback."},
    {"id": "LES-0037-DIA-006", "title": "Drift decision loop", "direction": "cyclic", "boundaries": ["detect difference", "classify source", "assess urgency", "adopt", "revert", "change desired", "verify"], "evidencePoints": ["who/when", "reason", "owner", "import", "plan", "post-check"], "textAlternative": "A difference between desired and observed state is classified before action. Approved emergency change may be adopted into code; unauthorized drift may be reverted; a changed business requirement updates desired configuration. Every path ends in reviewed convergence and verification."}
  ],
  "commands": [
    {"id": "LES-0037-CMD-001", "question": "What identity and directory bound this observation?", "risk": "read-only", "command": "id; uname -a; cat /etc/os-release; date -u +%Y-%m-%dT%H:%M:%SZ; pwd", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "UID is non-root and context matches", "meaning": "the local observation boundary is recorded", "nextEvidence": "inspect repository state"}, {"when": "UID is zero or the environment differs", "meaning": "the lab contract is not met", "nextEvidence": "stop or record the difference"}], "proves": "reported identity, kernel, release, time and path at one instant", "doesNotProve": "provider identity, remote target or permission safety"},
    {"id": "LES-0037-CMD-002", "question": "What source change would be reviewed?", "risk": "read-only", "command": "git status --short; git diff --check; git diff --stat", "runFrom": "the authorized lesson repository", "expectedBranches": [{"when": "only expected paths appear", "meaning": "the candidate source boundary is inspectable", "nextEvidence": "read the full diff"}, {"when": "unrelated or sensitive paths appear", "meaning": "the change boundary is contaminated", "nextEvidence": "stop and separate ownership"}], "proves": "selected working-tree and whitespace facts", "doesNotProve": "correct plan, safe target or approval"},
    {"id": "LES-0037-CMD-003", "question": "Does the fictional IaC scenario satisfy its contract?", "risk": "read-only", "command": "python3 fixtures/iac_model.py validate-scenario fixtures/scenario.json", "runFrom": "the LES-0037 support/lab directory", "expectedBranches": [{"when": "valid=true appears", "meaning": "the fixture satisfies model invariants", "nextEvidence": "run setup"}, {"when": "an error appears", "meaning": "no model conclusion is valid", "nextEvidence": "preserve the first error and create no state"}], "proves": "checked-in fixture conformance", "doesNotProve": "Terraform, OpenTofu, provider or production behavior"},
    {"id": "LES-0037-CMD-004", "question": "Can the lab create its exact private state?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "the LES-0037 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "state=ready appears", "meaning": "UID-scoped synthetic state validates", "nextEvidence": "run graph"}, {"when": "refused=true appears", "meaning": "identity, ownership, path or fixture is unsafe", "nextEvidence": "preserve ambiguous state"}], "proves": "bounded state creation under wrapper checks", "doesNotProve": "remote backend, lock or infrastructure behavior", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-005", "question": "Can dependencies be ordered without a cycle?", "risk": "mutating-bounded", "command": "bash lab.sh run graph", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "order=network,database,service and cycle=false appear", "meaning": "the fixture graph has a valid order", "nextEvidence": "inspect plan"}, {"when": "cycle=true appears", "meaning": "no safe complete order exists", "nextEvidence": "redesign dependency ownership"}], "proves": "fixture graph ordering", "doesNotProve": "provider-discovered edges or runtime readiness", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-006", "question": "What actions reconcile desired and current objects?", "risk": "mutating-bounded", "command": "bash lab.sh run plan", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "create=1 update=1 delete=1 noOp=1 appears", "meaning": "the fixture classifies four planned actions", "nextEvidence": "review every identity and consequence"}, {"when": "counts differ", "meaning": "input or planner behavior changed", "nextEvidence": "inspect the full action set"}], "proves": "fictional comparison and action counts", "doesNotProve": "real plan safety, completeness or provider accuracy", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-007", "question": "Which difference is drift and who owns it?", "risk": "mutating-bounded", "command": "bash lab.sh run drift", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "drifted=1 source=out-of-band appears", "meaning": "one fixture object differs through a declared external change", "nextEvidence": "choose adopt, revert or change intent"}, {"when": "drifted=0 appears", "meaning": "the modeled views converge", "nextEvidence": "retain observation limits"}], "proves": "fixture drift classification", "doesNotProve": "actor identity, authorization or complete remote observation", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-008", "question": "Does policy reject a dangerous candidate before execution?", "risk": "mutating-bounded", "command": "bash lab.sh run policy", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "denied=1 reason=public-database appears", "meaning": "the encoded policy blocks one candidate", "nextEvidence": "repair design or obtain governed exception"}, {"when": "denied=0 appears", "meaning": "the selected rules allow the fixture", "nextEvidence": "continue independent security review"}], "proves": "fixture policy result", "doesNotProve": "complete security, compliance or business approval", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-009", "question": "What remains after a mid-apply failure?", "risk": "mutating-bounded", "command": "bash lab.sh run partial", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "succeeded=1 failed=1 blocked=1 appears", "meaning": "the modeled apply is partial rather than transactional", "nextEvidence": "preserve state and build a new plan"}, {"when": "all succeed", "meaning": "this failure path was not exercised", "nextEvidence": "do not claim recovery evidence"}], "proves": "fictional partial-execution accounting", "doesNotProve": "real provider rollback or state durability", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-010", "question": "Does the desired model converge after successful reconciliation?", "risk": "mutating-bounded", "command": "bash lab.sh run converge", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "firstChanges=3 secondChanges=0 converged=true appears", "meaning": "the fixture reaches a no-change second plan", "nextEvidence": "verify user and security outcomes"}, {"when": "secondChanges exceeds zero", "meaning": "the model is unstable or nondeterministic", "nextEvidence": "stop repeated execution"}], "proves": "fixture convergence", "doesNotProve": "semantic correctness, availability or provider idempotency", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-011", "question": "Are display redaction and stored sensitivity distinguished?", "risk": "mutating-bounded", "command": "bash lab.sh run sensitive", "runFrom": "validated LES-0037 state", "expectedBranches": [{"when": "displayRedacted=true stateContainsSensitive=true appears", "meaning": "UI masking does not remove sensitive state", "nextEvidence": "protect state and plan access"}, {"when": "stateContainsSensitive=false appears", "meaning": "the selected fixture stores no sensitive value", "nextEvidence": "inspect other providers and derived values"}], "proves": "fixture redaction/storage distinction", "doesNotProve": "encryption, log safety or absence of secrets", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0037-CMD-012", "question": "Do all model cases and cleanup guards pass?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "the LES-0037 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "checked cases and cleanup passed", "nextEvidence": "preserve proof limits"}, {"when": "an assertion or cleanup fails", "meaning": "the first failure is evidence", "nextEvidence": "stop and inspect guarded state"}], "proves": "checked-in deterministic lifecycle behavior for that run", "doesNotProve": "provider, remote backend, infrastructure, production or mastery", "cleanup": "the verifier must prove exact absence"}
  ],
  "labs": [
    {"id": "LES-0037-LAB-001", "title": "Guided graph, plan, drift, policy and partial-failure model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; offline deterministic data only", "timeMinutes": 180, "privilege": "normal user; wrapper and verifier refuse UID 0", "network": "none", "changes": ["one exact UID-scoped temporary directory", "owned scenario, manifest and one replaceable result"], "abortConditions": ["root", "ambiguous owner or path", "symlink", "unexpected entry", "fixture failure", "model presented as a real plan"], "recovery": "Run status and clean only state that passes descriptor checks.", "cleanupProof": "Validate real path, UID, sentinel, manifest and allowed children; remove exact state and prove absence.", "path": "book/labs/LES-0037-infrastructure-as-code-foundations"},
    {"id": "LES-0037-LAB-002", "title": "Independent IaC change-system design and plan review", "mode": "independent", "environment": "Reviewer-held unfamiliar sanitized system with configuration, state, drift, policy, approval and partial-failure evidence", "timeMinutes": 240, "privilege": "normal user; no provider credentials or infrastructure authority", "network": "none unless an approved disposable harness is separately supplied", "changes": ["one sanitized design and evidence report", "only declared unseen-case state"], "abortConditions": ["answer access", "unclear target", "credentials", "real account", "unreviewed apply", "missing recovery proof"], "recovery": "Return to the last verified evidence boundary and retain uncertainty.", "cleanupProof": "Reviewer manifest proves all allowed resources and secrets absent.", "path": "book/labs/LES-0037-infrastructure-as-code-foundations"}
  ],
  "incidents": [
    {"id": "LES-0037-INC-001", "signal": "A plan proposes replacing a database after a variable rename.", "firstThought": "A configuration address or identity changed; replacement may be an ownership/refactor problem, not desired infrastructure change.", "safePath": "Stop, inspect address/state/remote identity, use a reviewed moved/import mechanism where valid, and prove data protection before any apply.", "trap": "Approve because the plan is syntactically valid."},
    {"id": "LES-0037-INC-002", "signal": "Apply fails after creating the network but before the service.", "firstThought": "IaC execution is partially committed; remote reality and state may have advanced.", "safePath": "Preserve first error and state serial, inspect exact remote bindings, repair the cause, create a fresh full plan and verify reconciliation.", "trap": "Assume automatic rollback or delete the state file."},
    {"id": "LES-0037-INC-003", "signal": "A no-change configuration suddenly plans a firewall update.", "firstThought": "Provider refresh, version change, API default or out-of-band drift changed the comparison.", "safePath": "Pin identities, inspect refreshed values and actor audit, classify the drift and choose adopt, revert or update intent.", "trap": "Apply automatically to make the dashboard green."},
    {"id": "LES-0037-INC-004", "signal": "Two pipelines operate on the same state and one loses changes.", "firstThought": "State locking or ownership segmentation failed; serialized intent was not enforced.", "safePath": "Stop both, retain snapshots and lock evidence, identify the latest valid lineage, reconcile remote objects and restore single-writer operation.", "trap": "Force-unlock immediately and rerun both."},
    {"id": "LES-0037-INC-005", "signal": "A plan artifact exposes a secret despite sensitive output masking.", "firstThought": "Display redaction is not storage encryption; plans and state can contain provider inputs and derived sensitive values.", "safePath": "Restrict and revoke access, rotate exposed credentials, preserve audit evidence, remove the source and harden backend/artifact retention.", "trap": "Assume a sensitive label encrypted the value."}
  ],
  "assessmentIds": ["ASM-0094", "ASM-0095", "ASM-0096"],
  "referenceIds": ["REF-0319", "REF-0320", "REF-0321", "REF-0322", "REF-0323", "REF-0324", "REF-0325", "REF-0326", "REF-0327", "REF-0328", "REF-0329", "REF-0330", "REF-0331", "REF-0332", "REF-0333"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": ["The lab is a deterministic fictional planner, not Terraform or OpenTofu.", "No provider, backend, credential, remote API or infrastructure is used.", "A plan is proposed action, not correctness, approval or outcome.", "Reading and automation do not establish mastery."]
}
---

# Infrastructure as Code: turn infrastructure change into reviewable evidence

## What you see and first thought

A pull request changes one line. The generated plan says one resource will be replaced. The resource is a production database.

Your first thought should not be, "the pipeline is green." It should be: **which real object does this address own, why did identity change, what data or availability is destroyed by replacement, which exact state and provider observation produced this plan, and who is authorized to accept that consequence?**

Infrastructure as Code, or IaC, is a change-control system expressed through machine-readable configuration. The valuable part is not that a file can create a server. The value is that intent, dependency, proposed change, policy, approval, execution and outcome can become repeatable evidence.

~~~text
weak story:
  file -> command -> infrastructure

production story:
  reviewed intent
    + pinned tools/providers/modules
    + protected state and target identity
    + refreshed remote observation
    -> proposed plan
    -> policy + human decision
    -> authorized execution
    -> state/reality reconciliation
    -> user, security, data, capacity and cost verification
~~~

Whenever you see a plan, ask what exact configuration, state snapshot, target, provider version and observation time created it. A plan without that identity can become stale before approval. A successful apply says the tool completed its operations; it does not say users can connect, data is correct, access is least privilege or cost is acceptable.

The practical habit is simple: never jump from code to apply. Move through identity, comparison, consequence, authority and verification.

## Terms before commands

**Infrastructure** is the resources and control settings that support a system: networks, compute, storage, identities, databases, DNS, observability, policies, queues and platforms. Not every operational fact belongs in IaC. Short-lived runtime data, secrets and application business records need their own owners.

**Desired configuration** declares what the tool should manage. It is intent, not remote truth. **Remote reality** is what provider APIs currently expose. **State** maps configuration addresses to remote object identities and caches attributes needed for comparison. State is operationally sensitive and necessary for stateful declarative tools; it is not a substitute for source control or complete inventory.

A **resource address** is the configuration identity of one managed instance. A **remote ID** is the provider identity of the actual object. Stable ownership needs a one-to-one binding. Accidentally binding one object twice or changing an address without a refactor mechanism can propose duplication or destruction.

A **provider** translates tool operations into a remote API. It has versioned behavior, schemas, defaults, retry logic and credentials. Pinning the CLI while allowing the provider to float does not create reproducibility.

A **module** packages configuration behind an input/output contract. A module is not automatically safe because it is reusable. Its source, version, nested dependencies, provider expectations, upgrade path and ownership belong in review.

A **dependency graph** contains resources as nodes and ordering relationships as directed edges. References usually create implicit edges. Explicit depends-on is for real hidden dependencies, not for forcing a preferred visual order. A cycle means no valid complete ordering exists.

**Refresh** observes remote attributes and updates the comparison view. A read can fail, be eventually consistent or omit facts. **Plan** is a proposed set of actions derived from configuration, prior state, provider logic and current observations. It is not an executed outcome.

**Apply** asks the provider to carry out actions. It is usually not one database transaction. Some resources may succeed before another fails. Recovery starts from the new evidence boundary, not from the assumption that nothing happened.

**Convergence** means repeated reconciliation reaches a no-change result for the same intent and stable environment. **Idempotency** describes an operation's effect under repetition. IaC can aim for convergence while individual provider calls, provisioners or external scripts remain non-idempotent.

**Drift** is a difference among intended, recorded and observed state. Drift can come from emergency action, another controller, provider defaults, version changes, manual edits or incomplete ownership. "Drift" does not automatically mean "revert."

**Import** adopts an existing remote object into a configuration address. **Forget** removes the binding without deleting the remote object. **Move/refactor** changes the configuration address while preserving ownership. These are identity operations and deserve the same review as create/delete.

A **saved plan** is an artifact containing a proposal for particular inputs. A **policy** evaluates selected facts against an organizational rule. An **approval** is an accountable decision. None can silently substitute for the others.

## Architecture map

~~~text
source repository
  configuration + modules + lock files + tests + policy
        |
        v
CI identity -> format -> validate -> tests -> initialize locked dependencies
        |
        v
protected backend <-> state snapshot + lock + lineage
        |                         |
        +---- provider refresh ---+---- remote APIs / objects
                                  |
                                  v
                         saved plan artifact
                                  |
                         policy + peer review
                                  |
                         environment approval
                                  |
                           apply exact plan
                                  |
                   state update + remote outcome
                                  |
              user/security/data/cost verification
~~~

There are four trust planes:

- the source plane controls configuration, modules, policy, locks and reviews;
- the execution plane controls runners, tools, providers, credentials and network reachability;
- the state plane controls bindings, snapshots, locks and sensitive attributes;
- the target plane contains real infrastructure, service quotas and provider behavior.

A repository approval without protected execution identity is incomplete. A secure runner using unreviewed modules is incomplete. Encrypted state without a tested restore and lock policy is incomplete. Treat the chain as one production system.

Environment separation must identify the target explicitly. A folder named production does not prove the provider account is production. Record account, project or subscription identity; region; tenant; backend; workspace; state lineage; and credential principal before planning.

The architecture should enforce a narrow path: source changes through review, plans are bound to exact inputs, only approved automation can change the target, and every change creates evidence that can be connected to user impact.

## Request or state path

Follow one configuration change:

~~~text
t0 developer changes desired service replicas from 2 to 3
t1 formatter and static validation pass
t2 tests evaluate variables, graph and policy candidates
t3 runner initializes exact CLI, provider and module identities
t4 backend grants lock for state lineage L at serial 41
t5 provider refresh observes network N, service S and database D
t6 planner compares desired + state bindings + observed attributes
t7 saved plan P proposes update service S only
t8 policy allows P; peer and environment owner approve digest P
t9 executor reacquires correct lock and applies exact P
t10 provider updates S; state serial becomes 42
t11 probes show three ready instances and user SLI remains healthy
t12 cost and security checks match expected boundaries
~~~

The plan is tied to inputs at t6. If state serial, configuration, provider version, variable values or remote objects change before t9, regenerate and review. Do not approve a screenshot and apply a different live plan.

Unknown values matter. An address or network endpoint may be known only after creation. A plan can show "known after apply" rather than a final value. Policy and review must decide whether the unknown is acceptable or whether the design needs a stronger boundary.

Destroy normally reverses dependencies: remove dependants before their dependencies. Runtime readiness is different from graph completion. An API returning "created" does not guarantee a database accepts connections, DNS has propagated or a load balancer is healthy. Post-apply verification covers that gap.

State movement is another path. Suppose module.app.server becomes module.service.server. The desired remote object did not change, but the configuration address did. Without a supported move declaration or reviewed state operation, a planner can interpret the old address as an orphan to delete and the new address as an object to create. Identity preservation must be explicit.

An import path begins with existing remote reality. First write the intended configuration and ownership boundary, then bind the exact remote ID to one address, refresh, and review a full plan. Import success does not prove the source exactly describes every existing attribute.

## Failure zoom

Imagine desired configuration contains network, database and service. The network creates successfully. Database creation fails on quota. The service is blocked by the graph.

~~~text
remote reality: network exists; database absent; service absent
state:          network binding recorded; database failure recorded in run evidence
source:         still declares all three
result:         partial change, not rollback
~~~

Blindly deleting state makes the network invisible to the tool while it still exists. Blindly rerunning may be safe for the network if the binding persisted, but unsafe if the provider created the object and state write failed. Inspect the provider console or API only with authority, compare exact remote identity, restore state from controlled snapshots where necessary, and produce a new plan.

Now consider drift: an operator opens a firewall during an incident, intending a 30-minute exception. The IaC system detects it later. Three valid dispositions exist:

1. **Revert** because the change was unauthorized or temporary and the safe configuration remains correct.
2. **Adopt** by encoding and reviewing the emergency change if it has become approved intent.
3. **Redesign** because another controller legitimately owns that field and IaC should stop fighting it.

Automatic apply can turn detection into an outage. Classification precedes convergence.

Replacement is another failure boundary. A rename can appear as delete old plus create new even when the desired object is logically unchanged. Use reviewed address-move constructs or import where supported, and prove the plan contains identity-preserving behavior before execution.

Plan staleness creates a quieter failure. A reviewer approves a plan based on state serial 41. Another pipeline produces serial 42. If the executor silently recalculates rather than applying the saved artifact, the approved and executed changes differ. Bind approval to plan digest and reject incompatible state or input changes.

## Internals and state ownership

Stateful declarative tools need a binding table:

~~~text
configuration address          remote object ID
module.network.vpc             net-7281
module.database.primary        db-4402
module.service.app[0]          vm-9011
~~~

The binding answers, "which object do I manage?" Cached attributes help calculate differences and dependencies. State can contain values returned by providers, including secrets even when the terminal masks them. Protect confidentiality, integrity, availability, version history and access logs. Do not commit state to ordinary source control.

Locking serializes writers; it does not make a change correct. A stale lock can represent a crashed executor or an active slow operation. Before force-unlocking, identify owner, run, target, state serial and whether the process still exists. Two concurrent applies can overwrite state or race remote changes.

The dependency graph is built from references, resource instances, provider configuration and state-only orphans. Independent nodes may run concurrently. Concurrency accelerates change but widens the number of in-flight partial outcomes. Lower parallelism is containment, not a correctness proof.

Lifecycle controls can prevent deletion, ignore selected changes or create a replacement before deleting the old object. Each changes operational semantics:

- prevent-destroy protects only paths that pass through that configuration and tool;
- ignore-changes hides a difference from reconciliation and can conceal security drift;
- create-before-destroy needs quota, unique names, routing and data compatibility;
- replace-trigger rules can cause large cascades if identity is broad.

Targeted apply is an emergency scalpel. It can omit graph changes needed for a coherent full configuration. After any targeted action, run and review a complete plan. It is not the normal workflow.

Outputs create contracts between ownership boundaries. Publishing a subnet ID is clearer than allowing every application team to read the network state. Remote-state data access can reveal the whole snapshot even when only one output is needed, depending on the tool and backend. Prefer narrow, authenticated interfaces where sensitivity or ownership requires it.

## Evidence table

| Question | Evidence that helps | What it still does not prove |
|---|---|---|
| Which target will change? | Account/project/subscription, region, tenant, backend, workspace and principal | That every provider alias or child module uses the same target |
| Which source created the plan? | Commit, clean diff, module and provider locks, variable artifact digest | That remote observations remain unchanged |
| Which objects are owned? | State lineage/serial and address-to-remote-ID bindings | That state is complete, current or uncompromised |
| What changed remotely? | Provider refresh with timestamp and per-object read results | That eventually consistent or inaccessible fields are correct |
| What will happen? | Saved plan with every action, unknown and replacement reason | That execution will succeed or produce the desired user outcome |
| Is policy satisfied? | Versioned rule result, input digest, exemption and reviewer | That the rule set is complete or business risk is accepted |
| Was the exact plan applied? | Plan digest, run ID, actor, lock, target and per-action results | That no external actor changed the target concurrently |
| Did execution converge? | Fresh full plan with zero changes after successful observation | That service, data, security, capacity and cost are correct |
| Is drift understood? | Audit actor/time, provider observation and ownership decision | That automatic revert is safe |
| Can state recover? | Versioned encrypted snapshot, access controls and tested restore | That remote objects and business data also recover |

Preserve the first provider error, but look backward. Quota failure can be caused by wrong region. Authorization denial can reveal wrong principal. A replacement can be caused by address change. The last line is a symptom until the input and identity chain is traced.

Evidence artifacts need retention and access policy. Saved plans and state-derived JSON may include sensitive values. Logs can contain environment variables or provider responses. Redact presentation, restrict raw artifacts, expire them deliberately and rotate any credential that appears.

Aggregate counts are a starting point only. "One to add, one to change, one to destroy" does not tell you whether the deletion is an unused metric or the root encryption key. Review the address, remote identity, replacement reason and downstream dependency of every dangerous action.

Unknown and deferred values deserve their own list. If a firewall rule, IAM principal or DNS target is unknown until apply, policy may be unable to judge the final object. Change architecture, stage the dependency, or create a postcondition and abort path instead of treating unknown as harmless.

## Command decoders

git status --short identifies modified, staged and untracked paths; it does not show the full change. git diff --check catches whitespace errors and conflict markers; it does not validate infrastructure. git diff --stat shows size, not risk. A one-line identity change may be more dangerous than a thousand-line generated file.

In Terraform/OpenTofu workflows, format normalizes source, validate checks syntax and internal consistency, and test can execute declared module tests. None is authorization to apply. Initialization resolves modules, providers and backend; it can make network requests and process credentials, so it is not a harmless parser step.

A plan usually refreshes remote objects, evaluates configuration and proposes actions. Detailed exit codes can distinguish no-change, change and error in automation, but only when the exact documented flags are used and the wrapper preserves the native exit code. Human-readable output should not be parsed as a stable API when machine-readable formats exist.

Machine-readable plan JSON is powerful and sensitive. It enables policy, cost and custom review, but can expose values and internal structure. Version the consumer against a documented compatibility format and protect the artifact like state-derived data.

Apply a saved plan when the workflow claims review parity. Running apply without a saved artifact often creates a fresh plan at execution time. That may be acceptable in a tightly coupled low-risk workflow, but it is not equivalent to approving an earlier output.

The fictional commands make no provider call:

~~~bash
bash lab.sh setup
bash lab.sh run graph
bash lab.sh run plan
bash lab.sh run drift
bash lab.sh run policy
bash lab.sh run partial
bash lab.sh run converge
bash lab.sh run sensitive
bash verify.sh
~~~

graph performs topological ordering. plan compares desired resources with fixture current objects. drift classifies an out-of-band difference. policy rejects a public database candidate. partial shows non-transactional progress. converge demonstrates a no-change second comparison. sensitive separates terminal masking from stored content.

## Decision path

Use this plan-review path:

~~~text
Are target identity, credentials, backend and state lineage explicit?
  no -> stop before initialization or refresh
  yes
   |
   v
Are source, modules, providers, variables and policy inputs pinned?
  no -> make the input closure reproducible
  yes
   |
   v
Did refresh complete for the intended scope?
  no -> plan contains observation uncertainty; investigate
  yes
   |
   v
Does every create/update/replace/delete/import/forget have an owner and consequence?
  no -> do not approve aggregate counts
  yes
   |
   v
Are data, availability, identity, security, quota and cost risks covered?
  no -> add design/test/rollback evidence
  yes
   |
   v
Did policy and accountable humans approve this exact plan digest?
  no -> do not apply
  yes -> staged execution with abort and communication
   |
   v
Do state, remote objects and user outcomes verify afterward?
  no -> contain, reconcile and create a fresh plan
  yes -> retain evidence and monitor
~~~

For deletion or replacement, ask: is the object stateful; is data backed up and restore tested; can create-before-destroy work; is name uniqueness available; will dependants reconnect; can rollback recreate identity; what is the user impact window?

For drift, identify ownership before action. If an autoscaler owns replica count, IaC may intentionally ignore that field. If an attacker opened a firewall, immediate containment may precede code review. The rule is not "code always wins"; the rule is "approved ownership and safety decide, then code and reality are reconciled."

When pressure demands a target-only run, state the broken invariant that makes full reconciliation unsafe, the exact resource boundary, who approves, and how a complete plan will follow. A target flag is not a debugging shortcut for poorly understood graphs.

## Guided Ubuntu lab

This lab performs deterministic graph and plan reasoning. It creates no infrastructure and needs no Terraform or OpenTofu binary.

### Lab A - establish the boundary

1. Read the wrapper, model and fixture:

   ~~~bash
   pwd
   sed -n '1,300p' lab.sh
   sed -n '1,420p' fixtures/iac_model.py
   python3 -m json.tool fixtures/scenario.json >/dev/null
   ~~~

2. Record normal-user identity and repository state:

   ~~~bash
   id
   uname -a
   git status --short
   git diff --check
   ~~~

3. Validate inputs and create guarded state:

   ~~~bash
   bash lab.sh doctor
   python3 fixtures/iac_model.py validate-scenario fixtures/scenario.json
   bash lab.sh setup
   bash lab.sh status
   ~~~

### Lab B - reason from graph to recovery

1. Produce the graph and explain why network is first:

   ~~~bash
   bash lab.sh run graph
   ~~~

2. Read the action counts, then inspect the fixture and name every object:

   ~~~bash
   bash lab.sh run plan
   ~~~

   Explain why aggregate create/update/delete counts are insufficient for approval.

3. Classify drift and policy:

   ~~~bash
   bash lab.sh run drift
   bash lab.sh run policy
   ~~~

   Decide whether the drift should be adopted, reverted or transferred to another owner. Explain why policy pass cannot prove security.

4. Model partial failure:

   ~~~bash
   bash lab.sh run partial
   ~~~

   Draw remote reality and state after the first success and second failure. Do not say rollback unless evidence shows rollback.

5. Test convergence and sensitive storage:

   ~~~bash
   bash lab.sh run converge
   bash lab.sh run sensitive
   ~~~

   Explain why zero changes is necessary but not sufficient, and why masked display does not protect state.

6. Verify and prove cleanup:

   ~~~bash
   bash verify.sh
   bash lab.sh status
   ~~~

   Final state must be absent. Preserve any refused state for review rather than deleting around the guard.

### Lab C - independent plan review

Complete ASM-0096 using a reviewer-held scenario with different resources, graph, drift, policy and partial-failure behavior. Produce a plan review and recovery decision without provider access. No answer key is available.

Abort if any step requests real credentials, initializes an unknown provider, reaches a remote backend, targets an account, generates cost or proposes apply. This lesson authorizes only the checked-in fictional model.

## Production transfer

In a team workflow, separate plan and apply identities. A pull-request pipeline can validate and create a plan with read-oriented permissions; an environment-controlled executor applies an approved exact artifact with short-lived least privilege. The same principal should not silently write source, approve, and apply high-risk production changes.

Pin the CLI, provider and module source. Verify checksums or provenance supported by the ecosystem. Treat third-party providers and modules as executable supply chain. Review upgrade notes and generate a plan in a representative lower environment before changing production tooling.

Backends need encryption, access control, locking, versioning, audit logs, durability and tested recovery. Keep credentials outside backend configuration and command-line history. Avoid exporting full state to broad CI artifacts. Break-glass state operations require peer review, exact snapshots and reconciliation.

Design modules around ownership and lifecycle, not merely directory reuse. A module should have a narrow purpose, typed inputs, documented outputs, version compatibility, examples, tests, upgrade guidance and an owner. Deep generic modules can hide critical actions and couple unrelated teams.

Environment strategy can use directories, stacks, workspaces or separate repositories. The label matters less than isolation of state, credentials, quotas, approval and blast radius. Never use one shared state merely to avoid wiring explicit outputs between independently owned systems.

Apply in stages when blast radius warrants: canary account, region, cluster, shard or resource class. Define abort conditions from user SLI, correctness, security, cost and provider errors. A rollback can be impossible after data deletion, schema change or identity replacement; prepare roll-forward and restore paths.

After apply, verify provider state and the user journey. Check DNS, routes, TLS, identity, readiness, data integrity, telemetry, alerts, capacity, quotas and cost signals appropriate to the change. Then run a fresh full plan. Zero drift plus failed users is still a failed change.

For Terraform and OpenTofu, share the conceptual workflow but verify product and version semantics separately. Language compatibility, state encryption, test features, provider locks and backend behavior can differ. Never use a feature name from one project as evidence for the other.

For Kubernetes, distinguish infrastructure provisioning from the cluster reconciliation controllers that continue changing objects. Decide which controller owns each field. For cloud, include organization policy, quotas and shared-responsibility controls. For private cloud, include hypervisor, storage, network and hardware lifecycles that may not be represented by one provider.

## Reliability, security, observability, capacity, and cost

**Reliability:** reduce batch size, preserve stable identities, stage changes and plan for partial execution. Protect state availability and restore. Test provider throttling, timeouts and stale observations. Do not rely on rollback for destructive change.

**Security:** state and plans may contain secrets. Runners and providers have powerful credentials. Use short-lived identity, least privilege, protected branches, reviewed modules, dependency locks, isolated execution, policy, audit and break-glass controls. Sensitive labels mask display; they do not guarantee encryption.

**Observability:** record run, actor, target, source, plan digest, state serial, action identity, first error, duration, provider throttling and post-change checks. Avoid labels containing resource secrets or unbounded addresses. Connect change events to incidents and SLOs.

**Capacity:** an IaC change can consume quotas, IP addresses, names, capacity reservations and API rate limits. Create-before-destroy temporarily needs both old and new capacity. Parallelism can overload provider APIs or dependencies. Model the narrowest quota before approval.

**Cost:** show estimated recurring and one-time cost, data transfer, licenses, retained storage and temporary replacement overlap. A policy threshold should have currency, horizon, assumptions, owner and exception workflow. Estimate is not invoice truth.

**Data:** deletion protection in configuration does not replace backup, retention, replication or restore testing. Replacing a stateful object can change identity and destroy data. Tie destructive actions to the later DR and data-lifecycle contracts.

**People:** infrastructure code is an interface between platform teams, service owners, security and finance. Clear ownership reduces emergency console changes. Review cognitive load and recovery instructions, not only abstraction elegance.

## Traps and prevention

| Trap | Failure | Better move |
|---|---|---|
| Configuration is the source of truth | It does not contain remote identity, live attributes or every operational fact. | Treat source as desired intent and reconcile with protected state and observations. |
| State is just a cache | Losing bindings can cause duplicate creation or destructive proposals. | Protect, version, lock, audit and test state recovery. |
| Plan passed, so change is safe | Plan cannot prove business correctness, future API success or user health. | Review identities/consequences, stage, abort and verify outcomes. |
| Apply is transactional | Providers can commit some actions before failure. | Preserve evidence and reconcile from a fresh full plan. |
| Rerun fixes partial failure | The failed operation may have succeeded remotely before response loss. | Inspect state and remote identity before retry. |
| Drift must be auto-reverted | Emergency or another controller may own the change. | Classify source, authorization and ownership first. |
| Manual changes are always wrong | Break-glass action may be necessary. | Time-bound, audit, then adopt or revert through review. |
| depends-on fixes readiness | Graph completion does not prove application readiness. | Use real readiness and post-change verification. |
| Ignore changes removes noise | It can hide security or operational drift. | Limit fields and document the alternate owner. |
| Targeted apply is faster normal workflow | It can omit coherent graph changes. | Use only for governed recovery and follow with a full plan. |
| Sensitive means encrypted | It often masks CLI display only. | Protect raw state, plans, logs and backend credentials. |
| Workspaces equal hard isolation | Credentials and backend policy may still be shared. | Isolate state and authority according to blast radius. |
| One giant state simplifies dependencies | It couples ownership, locks and blast radius. | Segment by lifecycle and ownership; publish explicit contracts. |
| Modules should hide every detail | Excess abstraction obscures risk and upgrades. | Prefer narrow modules with typed contracts and visible consequences. |
| Provider upgrade is routine | Defaults, schemas and diff behavior can change. | Pin, review release notes, test, plan and stage. |
| Zero-change plan proves healthy | Users or data can be broken while config converges. | Verify service, security, data, capacity and cost separately. |

Prevention is a change system, not a checklist pasted into a pull request. Enforce target identity, dependency locks, clean source, validation and tests before planning. Bind policy and approvals to the saved plan. Restrict apply authority. Detect drift continuously but reconcile through ownership. Test state restore and partial-failure runbooks.

Keep generated evidence small enough to review. Thousands of unrelated actions hide the dangerous one. Split states and deployments by ownership and lifecycle, reduce batch size and require additional review for replacement, deletion, public access, privilege or high cost.

## Memory card and retrieval

Remember **C-S-R-P-A-V**:

~~~text
C - Configuration: reviewed desired intent
S - State: protected address-to-object bindings
R - Reality: refreshed provider observations
P - Plan: proposed actions and unknowns
A - Apply: authorized partial-capable execution
V - Verify: state, remote and user outcomes converge
~~~

When someone says, "It is in Terraform," ask:

- which configuration revision and module/provider versions?
- which account, region, backend, workspace, lineage and serial?
- which exact remote object IDs?
- did refresh cover the target?
- what creates, replaces and deletes?
- which plan digest was approved and applied?
- what happened after the first failure?
- did users, data, security and cost verify?

Retrieval prompts:

1. Why are configuration, state and remote reality different?
2. What does a plan prove and not prove?
3. Why can an apply be partially successful?
4. When should drift be adopted instead of reverted?
5. Why is a sensitive value still dangerous in state?
6. What proves convergence, and why is it insufficient?
7. When is explicit dependency appropriate?
8. Why can resource renaming propose destruction?

Answer without looking. Then draw the six-layer diagram and explain one incident using it. Repeat after one day and one week with different resource names.

## Complete answers

1. **Three different jobs:** configuration declares desired management intent; state binds configuration addresses to remote object IDs and caches attributes; provider reads describe remote reality at a time. A plan combines them. Source can be correct while state is stale; state can be intact while reality drifted; provider observation can be partial.

2. **A plan proves a proposal for exact inputs.** It shows the tool's calculated actions, unknowns and replacement reasons for a configuration, state, provider version, variables and observation. It does not prove approval, future API success, service health, data correctness, least privilege or cost accuracy.

3. **Remote APIs are not one shared transaction.** The tool may create a network, persist its binding, then fail to create a database. Some providers have rollback for individual services, but the whole graph usually has partial outcomes. Preserve state and inspect before retry.

4. **Adopt approved intent.** If a break-glass change is still required and has accountable approval, encode it and review rather than automatically undoing it. Revert unauthorized or expired drift. Transfer ownership when another controller legitimately manages the attribute.

5. **Masking is presentation.** Providers can store raw or derived secret values in state and plans so later comparisons work. Anyone with artifact access may read them. Encrypt, restrict, audit and minimize; rotate on exposure.

6. **A fresh full no-change plan demonstrates model convergence for observed scope.** It is insufficient because application health, data integrity, security behavior and cost may lie outside the provider diff. Verify user journeys and operational signals.

7. **Use explicit dependency for a real ordering relationship not expressed by data reference.** Examples include a policy that must exist before a resource even though no attribute is consumed. Do not add edges merely to sequence logs; excess edges reduce parallelism and can create cycles.

8. **Address is ownership identity.** Removing old address and adding new address looks like delete one managed instance and create another unless a moved/refactor or import declaration preserves the remote binding. Review identity operations before apply.

Senior rule: **never review IaC as text alone. Review the ownership map, target, graph, plan consequences, execution authority, partial-failure path and user verification as one change system.**

## Product-company interview

**What is Infrastructure as Code?**

IaC is a governed method for expressing infrastructure intent in versioned machine-readable configuration and reconciling it through repeatable tooling. A production system includes dependency and module identity, state/bindings, provider observations, plan, policy, approval, execution, audit, verification and recovery. Automation without reviewable intent and evidence is scripting, not necessarily safe IaC.

**Is Terraform state the source of truth?**

It is the tool's critical ownership and attribute record, not universal truth. Configuration is desired intent; provider APIs expose remote reality; state maps the two. I protect and version state, serialize writers, refresh carefully and reconcile differences. I never casually edit or delete state.

**How do you review a plan?**

Confirm target and input identity first. Read every action by resource identity, not only totals. Focus on replace/delete, unknowns, privilege/network/data changes, quota, cost and graph cascades. Check policy and exemptions, rollback/roll-forward and post-checks. Approve the exact saved plan digest and replan if inputs change.

**What do you do after partial apply failure?**

Stop concurrent writers, preserve first error, run ID, state serial and plan. Determine which remote operations succeeded and whether their bindings persisted. Fix the root condition such as quota or authorization, reconcile ambiguous objects through supported state/import mechanisms, generate a new full plan, review it and verify user outcomes. I do not assume rollback or blindly rerun.

**How do you handle drift?**

Detect with complete observations and audit context. Classify actor, reason, urgency and owner. Revert unauthorized or expired drift, adopt approved desired change into code, or change ownership when another controller manages the attribute. Track time to disposition and prevent repeated conflict.

**How would you secure an IaC pipeline?**

Protected source and reviews; pinned and verified CLI/providers/modules; isolated ephemeral runner; short-lived least-privilege target identity; separate plan/apply authority; protected encrypted locked state with versioning and audit; policy and scoped exceptions; exact plan artifact binding; environment approval; controlled network; secret-safe logs; staged apply; post-change verification; tested state and incident recovery.

**Declarative versus imperative?**

Declarative configuration states desired relationships and lets an engine calculate reconciliation, which improves comparison and convergence. Imperative code specifies steps and can express complex orchestration. Real systems combine them. I choose based on ownership, observability, failure recovery, testability and side effects, and I do not hide unsafe imperative scripts inside a declarative wrapper.

**How do you split state?**

By ownership, lifecycle, sensitivity, blast radius, lock contention and failure domain. A network platform and application deployment may publish explicit outputs rather than share one state. Too many states create dependency coordination; one giant state couples permissions and outages. I document the contract and recovery path.

**Why not automatically apply every merged change?**

Low-risk environments may use automatic apply when target identity, policy, testing and rollback are strong. High-risk replacements, deletions, privilege and data changes need an accountable decision. I design tiered automation from consequence, not one universal manual or automatic rule.

## Independent transfer and rubric

Complete ASM-0096 on a materially different reviewer-held change. No model answer is available.

Required evidence:

- system boundary, owners, user objective and excluded resources;
- exact source, tool, provider, module, variable, policy, target and state identities;
- desired/state/remote comparison with address-to-object ownership;
- dependency graph, implicit and explicit edges, parallelism and cycle analysis;
- plan review covering every action, unknown, replacement and deletion;
- security, data, availability, quota, capacity and cost consequences;
- drift source and adopt/revert/transfer decision;
- state locking, storage, access, snapshot and recovery design;
- partial-apply timeline, ambiguous outcome and reconciliation plan;
- policy, exception, human approval and separation-of-duties design;
- staged execution, abort, rollback/roll-forward and communication;
- post-change provider and user verification plus fresh full plan;
- alternatives, proof limits and review trigger.

Rubric, 100 points:

| Dimension | Points | Full-credit evidence |
|---|---:|---|
| Boundary and ownership | 8 | Exact managed scope, owners, objectives and exclusions. |
| Input and target identity | 10 | Source, tool, provider, module, variables, backend, target, principal and state. |
| State model | 10 | Correct address/remote binding, lineage, locking, sensitivity and recovery. |
| Dependency graph | 8 | Valid edges, cycle reasoning, parallelism and destroy implications. |
| Plan review | 10 | Every action, unknown, replacement, deletion and consequence is explained. |
| Drift decision | 8 | Source, authorization, owner and adopt/revert/transfer choice. |
| Policy and security | 10 | Supply chain, credentials, state/plan protection, policy and exceptions. |
| Partial-failure recovery | 10 | Preserves evidence, resolves ambiguity and creates a fresh reviewed plan. |
| Execution safety | 8 | Stages, approvals, abort, rollback/roll-forward and communication. |
| Verification | 8 | Provider, state, user, data, security, capacity and cost evidence. |
| Trade-offs | 4 | Alternatives, module/state boundaries and costs are explicit. |
| Communication | 6 | Decision, uncertainty, owner, proof limits and review trigger are clear. |

Passing one reviewed artifact does not prove production authority or mastery. Require remediation and delayed reassessment on a second unseen system.

## References and review

Reference records REF-0319 through REF-0333 anchor this lesson in official OpenTofu, Terraform, AWS and NIST material:

- configuration language, resources, data, variables, outputs and dependency graph;
- state purpose, backends, locking, security, import, refactor and drift;
- planning, machine-readable output, testing, provider/module locks and sensitive data;
- organizational IaC, configuration management and DevSecOps governance.

Product behavior changes. OpenTofu and Terraform share historical concepts but are separate projects with version-specific language and feature differences. This lesson teaches a common mental model and never assumes cross-tool compatibility without explicit version evidence.

Review checklist:

- Are managed boundary, owner and user objective explicit?
- Are source, dependency and target identities pinned?
- Is state protected, locked, versioned, recoverable and least privilege?
- Does the plan use complete current observations or state its gaps?
- Is every replacement/delete/import/forget action understood?
- Are unknown values and provider defaults acceptable?
- Are module/provider supply-chain risks reviewed?
- Do policy and exceptions bind to exact inputs?
- Is the exact approved plan applied by authorized identity?
- Are partial failure and ambiguous remote outcomes recoverable?
- Is drift classified before convergence?
- Are post-apply user, security, data, capacity and cost checks defined?
- Does a fresh full plan follow targeted or emergency action?
- Are raw state, plans and logs retained safely?
- Are rollback, roll-forward and state recovery tested?

Review after material changes to cited tool behavior, or sooner after a destructive plan, state incident, concurrent writer, secret exposure, provider/module compromise, partial apply, unresolved drift or failed recovery. Scheduled review date: 2027-02-04.
