---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0039",
  "slug": "terraform-opentofu-modules-state-recovery",
  "aliases": ["V05-L03", "terraform-opentofu-modules-state-recovery"],
  "curriculumIds": ["TFM-002"],
  "route": "/book/infrastructure/terraform-opentofu-modules-state-recovery",
  "order": 3,
  "volume": "05-infrastructure-platforms",
  "title": "Terraform and OpenTofu modules and state: preserve ownership before changing structure",
  "summary": "Design composable modules, reason from state lineage and serial, respect locks, secure backend metadata, adopt existing objects, refactor addresses without recreation, and recover a bounded local state deliberately instead of improvising on production ownership.",
  "domain": "infrastructure",
  "level": {"from": "intermediate", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0038"],
  "prerequisiteCurriculumIds": ["TFM-001"],
  "testedEnvironments": [
    {"platform": "Terraform", "version": "1.15.8 windows_amd64", "support": "supported", "notes": "A checksum-matched standalone CLI passed the isolated built-in-provider create, move-only refactor, identity/lineage/serial continuity, corruption refusal, protected restore, zero-change convergence and exact cleanup path. This does not prove an external provider or remote backend."},
    {"platform": "OpenTofu", "version": "1.12.1 windows_amd64", "support": "supported", "notes": "A separately checksum-matched standalone CLI passed the same bounded semantics in a clean state directory. This proves only the exact fixture and does not establish cross-product state interoperability."},
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The learner lifecycle targets a normal Ubuntu user, but WSL startup is blocked by host logon error 0x80070569; wrapper lifecycle, root refusal and cleanup remain unproved on Ubuntu."},
    {"platform": "Cloud and remote infrastructure", "version": "not used", "support": "unsupported", "notes": "No cloud provider, credential, remote backend, registry module or remote resource is authorized."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead"],
  "learningObjectives": [
    "Design module boundaries around cohesive lifecycle, ownership and blast radius instead of file reuse alone.",
    "Write explicit typed module inputs, outputs, assumptions, guarantees, version constraints and provider ownership rules.",
    "Explain state as address-to-object bindings plus cached attributes, provider identity, lineage and monotonically increasing serial.",
    "Distinguish a backend, state snapshot, workspace, lock and saved plan, including where sensitive metadata can persist.",
    "Diagnose lock contention and prove owner liveness before considering force-unlock.",
    "Adopt an existing object with configuration-driven import while preserving one address to one remote object.",
    "Refactor resource and module addresses with moved declarations and reject unintended recreation.",
    "Recognize drift, stale observation, state loss, state corruption and wrong-state selection as different failure classes.",
    "Back up, validate, restore and reconverge state without hand-editing JSON or bypassing lineage and serial safeguards.",
    "Run a provider-free local apply/refactor/corruption-recovery lifecycle with exact cleanup and no cloud access."
  ],
  "productionSignals": [
    "CLI product, version, platform, binary digest and configuration revision",
    "root module path, child module source, resolved version and dependency identity",
    "module call path, resource instance address, provider address and remote object ID",
    "backend type, backend configuration identity, workspace and target environment",
    "state lineage, serial, Terraform/OpenTofu version, state digest and backup timestamp",
    "lock ID, operation, actor, process or run ID, acquisition time and liveness evidence",
    "plan digest, prior-state lineage/serial, configuration digest and proposed address actions",
    "import destination, provider import identifier, pre-import evidence and post-import plan",
    "moved from/to addresses, supported version window and replacement-free plan evidence",
    "state pull/restore provenance, destination lineage/serial and protected backup inventory",
    "remote object observation, drift ownership and destructive consequence",
    "post-change binding map, fresh full plan, service/user result and audit record"
  ],
  "diagrams": [
    {"id": "LES-0039-DIA-001", "title": "Module composition and ownership", "direction": "hierarchical", "boundaries": ["root module", "network contract", "service contract", "data contract", "provider configurations", "state partitions"], "evidencePoints": ["input", "output", "address", "owner", "blast radius"], "textAlternative": "A thin root module composes cohesive child modules by passing outputs into typed inputs; provider and state ownership remain explicit rather than hidden inside deeply nested modules."},
    {"id": "LES-0039-DIA-002", "title": "Four-way reconciliation", "direction": "cyclic", "boundaries": ["configuration", "selected state", "provider observation", "proposed plan", "verified outcome"], "evidencePoints": ["revision", "lineage", "serial", "remote ID", "action"], "textAlternative": "The engine compares desired configuration, selected state bindings and current provider observations to propose a plan; execution writes a newer state and operators separately verify the real outcome."},
    {"id": "LES-0039-DIA-003", "title": "Single-writer state path", "direction": "left-to-right", "boundaries": ["run request", "backend", "lock", "read snapshot", "provider action", "write snapshot", "unlock"], "evidencePoints": ["lock ID", "actor", "lineage", "serial", "write result"], "textAlternative": "A mutating run acquires the backend lock before reading state, performs approved work, writes the next snapshot and releases the lock; a second writer must wait or fail."},
    {"id": "LES-0039-DIA-004", "title": "Address-preserving refactor", "direction": "left-to-right", "boundaries": ["old configuration address", "old state binding", "moved declaration", "new module address", "same object ID"], "evidencePoints": ["from", "to", "plan action", "object ID", "fresh plan"], "textAlternative": "A moved declaration tells the engine that an object at the old address now belongs at the new module address, preserving the same object instead of interpreting the rename as destroy and create."},
    {"id": "LES-0039-DIA-005", "title": "Import adoption boundary", "direction": "top-to-bottom", "boundaries": ["existing remote object", "verified identifier", "resource configuration", "import destination", "state binding", "convergence plan"], "evidencePoints": ["ownership approval", "ID", "address", "attributes", "actions"], "textAlternative": "Import adopts one existing object into one configured address; it does not discover intent, create safe configuration or prove that the resulting plan is non-destructive."},
    {"id": "LES-0039-DIA-006", "title": "State recovery decision path", "direction": "hierarchical", "boundaries": ["freeze writers", "identify target", "preserve evidence", "validate candidates", "restore under lock", "refresh and reconcile", "verify users"], "evidencePoints": ["owner", "lineage", "serial", "digest", "remote IDs", "approval"], "textAlternative": "Recovery first freezes writers and proves the target, then preserves evidence, validates lineage and serial of candidate backups, restores through supported tooling, reviews a fresh plan and verifies real objects and users."}
  ],
  "commands": [
    {"id": "LES-0039-CMD-001", "question": "Which operator, host and root module bound this investigation?", "risk": "read-only", "command": "id; uname -a; date -u +%Y-%m-%dT%H:%M:%SZ; pwd", "runFrom": "a normal Ubuntu shell in the approved lab", "expectedBranches": [{"when": "UID is non-root and path is approved", "meaning": "the host boundary is recorded", "nextEvidence": "bind CLI identity"}, {"when": "UID is zero or path differs", "meaning": "the exercise boundary is invalid", "nextEvidence": "stop before state access"}], "proves": "reported execution identity and directory", "doesNotProve": "backend, state or CLI integrity"},
    {"id": "LES-0039-CMD-002", "question": "Which exact engine will read and write this state?", "risk": "read-only", "command": "terraform version -json", "runFrom": "a shell with the separately verified CLI", "expectedBranches": [{"when": "approved product/version/platform appears", "meaning": "interpreter identity matches the case", "nextEvidence": "verify binary digest"}, {"when": "identity differs", "meaning": "state compatibility is unreviewed", "nextEvidence": "stop and resolve version policy"}], "proves": "self-reported CLI identity", "doesNotProve": "binary provenance or state compatibility"},
    {"id": "LES-0039-CMD-003", "question": "Which module sources and providers can initialization install?", "risk": "mutating-bounded", "command": "CHECKPOINT_DISABLE=1 TF_IN_AUTOMATION=1 terraform init -input=false", "runFrom": "the guarded provider-free disposable root", "expectedBranches": [{"when": "only local child module and built-in provider appear", "meaning": "the fixture dependency boundary holds", "nextEvidence": "validate and inspect empty state"}, {"when": "network download or external provider appears", "meaning": "fixture contract changed", "nextEvidence": "abort before plan or apply"}], "proves": "observed initialization dependencies for this root", "doesNotProve": "general offline or backend safety", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0039-CMD-004", "question": "What bindings exist in the selected state?", "risk": "read-only", "command": "terraform state list; terraform show -json | python3 -m json.tool | sed -n '1,180p'", "runFrom": "the guarded initialized state", "expectedBranches": [{"when": "expected addresses and JSON values appear", "meaning": "the selected snapshot can be decoded", "nextEvidence": "record lineage, serial and digest"}, {"when": "empty, corrupt or unexpected addresses appear", "meaning": "selection or state integrity is wrong", "nextEvidence": "freeze changes and identify the correct target"}], "proves": "CLI-decoded selected snapshot", "doesNotProve": "current remote reality or safe ownership"},
    {"id": "LES-0039-CMD-005", "question": "What are the state lineage, serial and exact protected digest?", "risk": "read-only", "command": "terraform state pull > state.pull.json; python3 guard.py inspect-state state.pull.json", "runFrom": "the guarded disposable state", "expectedBranches": [{"when": "expected lineage, serial, addresses and digest print", "meaning": "a candidate snapshot is identified", "nextEvidence": "protect it before mutation"}, {"when": "schema or address checks fail", "meaning": "the snapshot is not the expected candidate", "nextEvidence": "preserve and investigate; do not push"}], "proves": "selected snapshot identity under the guard's narrow model", "doesNotProve": "complete semantic validity or remote correctness"},
    {"id": "LES-0039-CMD-006", "question": "Does the initial provider-free configuration converge into local state?", "risk": "mutating-bounded", "command": "terraform apply -input=false -auto-approve -no-color", "runFrom": "the guarded fixture after exact plan approval", "expectedBranches": [{"when": "two built-in terraform_data objects are added", "meaning": "local state bindings were created", "nextEvidence": "inspect addresses and save backup"}, {"when": "any external provider, destroy or unexpected action appears", "meaning": "the bounded contract is violated", "nextEvidence": "abort and preserve evidence"}], "proves": "state-only apply behavior for the built-in fixture", "doesNotProve": "cloud apply safety or infrastructure behavior", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0039-CMD-007", "question": "Will moving objects into a child module preserve their bindings?", "risk": "mutating-bounded", "command": "terraform plan -input=false -out=refactor.tfplan -no-color; terraform show -json refactor.tfplan | python3 guard.py inspect-refactor-plan", "runFrom": "the guarded v2 refactor configuration with moved blocks", "expectedBranches": [{"when": "two move-only address changes and zero create/update/delete appear", "meaning": "the reviewed refactor preserves bindings", "nextEvidence": "apply only the saved refactor plan"}, {"when": "create, delete or replacement appears", "meaning": "address history is incomplete or identity changed", "nextEvidence": "stop and repair moves"}], "proves": "proposal semantics for exact source, state and CLI", "doesNotProve": "execution success or all consumers upgraded", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0039-CMD-008", "question": "Is the state lock owned by a live writer?", "risk": "read-only", "command": "ps -fp ${LOCK_PID:?}; date -u; sed -n '1,120p' .terraform.tfstate.lock.info", "runFrom": "an approved state directory after a lock diagnostic", "expectedBranches": [{"when": "live matching writer/run exists", "meaning": "contention is legitimate", "nextEvidence": "wait or coordinate cancellation"}, {"when": "owner is absent and backend confirms no run", "meaning": "a stale-lock hypothesis is plausible", "nextEvidence": "use backend-specific reviewed recovery with exact lock ID"}], "proves": "selected local process and lock metadata observations", "doesNotProve": "remote lock ownership or safe force-unlock"},
    {"id": "LES-0039-CMD-009", "question": "Does a deliberately corrupted local snapshot fail closed?", "risk": "mutating-bounded", "command": "cp terraform.tfstate protected.tfstate; printf '{broken' > terraform.tfstate; terraform state list", "runFrom": "only the disposable guarded lab after backup validation", "expectedBranches": [{"when": "state decoding fails nonzero", "meaning": "the CLI refused malformed state", "nextEvidence": "restore the validated protected snapshot"}, {"when": "state list succeeds", "meaning": "the corruption injection or target is wrong", "nextEvidence": "stop and identify files"}], "proves": "malformed-state refusal for the selected disposable file", "doesNotProve": "production recovery readiness", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0039-CMD-010", "question": "Does the validated backup restore exact bindings and convergence?", "risk": "mutating-bounded", "command": "cp protected.tfstate terraform.tfstate; terraform state list; terraform plan -input=false -detailed-exitcode -no-color", "runFrom": "the frozen disposable lab after digest/lineage/serial validation", "expectedBranches": [{"when": "expected module addresses return and plan exits zero", "meaning": "this bounded state recovered and converged", "nextEvidence": "verify IDs and cleanup"}, {"when": "addresses differ or plan exits two/error", "meaning": "restore or configuration is incomplete", "nextEvidence": "keep writers frozen and reconcile evidence"}], "proves": "bounded restore and plan result for exact fixture", "doesNotProve": "remote objects or application data recovered", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0039-CMD-011", "question": "What would configuration-driven import adopt?", "risk": "read-only", "command": "terraform plan -input=false -generate-config-out=generated-import.tf -no-color", "runFrom": "a separately authorized disposable import rehearsal with no credentials in this lesson", "expectedBranches": [{"when": "one import destination and reviewed generated attributes appear", "meaning": "the adoption proposal is inspectable", "nextEvidence": "normalize configuration and review destructive actions"}, {"when": "lookup or schema fails", "meaning": "identifier/provider/configuration is incomplete", "nextEvidence": "stop without modifying state"}], "proves": "import proposal for that provider/version/identifier", "doesNotProve": "ownership, configuration correctness or safe apply"},
    {"id": "LES-0039-CMD-012", "question": "Does the complete guarded lifecycle clean every state artifact?", "risk": "mutating-bounded", "command": "bash verify.sh terraform", "runFrom": "the LES-0039 support/lab directory as a normal Ubuntu user; use tofu only for a separate clean lifecycle", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "checked create/refactor/corrupt/restore/cleanup paths passed", "nextEvidence": "retain product/version/digest boundary"}, {"when": "first assertion fails", "meaning": "the lifecycle is not accepted", "nextEvidence": "preserve the first causal artifact"}], "proves": "guarded lifecycle on that host and run", "doesNotProve": "remote backend, provider, production recovery or learner mastery", "cleanup": "the verifier must prove exact absence"}
  ],
  "labs": [
    {"id": "LES-0039-LAB-001", "title": "Guided local module, state, refactor and recovery drill", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash, Python 3 and a separately checksum-verified Terraform or OpenTofu CLI", "timeMinutes": 240, "privilege": "normal user; wrapper refuses UID 0", "network": "none after separately authorized tool acquisition; local modules, local backend and built-in provider only", "changes": ["one exact UID-scoped temporary directory", "provider-free local state containing two logical objects", "protected backup, moved-address plan, corruption injection and exact restore"], "abortConditions": ["root", "unverified CLI", "network request", "external provider", "remote backend", "credential", "unexpected address/action", "symlink", "wrong owner or state lineage"], "recovery": "Freeze the fixture, preserve first failure, and restore only a guard-validated state copy.", "cleanupProof": "Validate path, UID, sentinel, CLI binding, allowed entries and state inventory; remove only the lesson directory and prove absence.", "path": "drafts/LES-0039-terraform-opentofu-modules-state-recovery/support/lab"},
    {"id": "LES-0039-LAB-002", "title": "Independent module-upgrade and state-incident transfer", "mode": "independent", "environment": "Reviewer-held unfamiliar provider-free module history with changed addresses, competing state candidates and one safe recovery path", "timeMinutes": 240, "privilege": "normal user; no provider credentials or remote backend authority", "network": "none", "changes": ["one reviewer-owned disposable module/state fixture", "plan, address map, recovery decision and cleanup evidence"], "abortConditions": ["lesson answer access", "manual JSON editing", "force-unlock", "state push", "real provider", "credential", "unreviewed create/delete", "missing cleanup proof"], "recovery": "Preserve all candidates, justify target/lineage/serial and use supported tooling inside the disposable boundary.", "cleanupProof": "Reviewer manifest proves state, backups, locks, plans and directory absent without touching unrelated files.", "path": "drafts/LES-0039-terraform-opentofu-modules-state-recovery/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0039-INC-001", "signal": "A module extraction proposes destroy and create for unchanged infrastructure.", "firstThought": "Resource addresses changed; the engine cannot infer logical continuity.", "safePath": "Stop, map old/new addresses and remote IDs, add supported moved declarations, and require a replacement-free full plan.", "trap": "Apply because only files moved."},
    {"id": "LES-0039-INC-002", "signal": "A pipeline reports that state is locked.", "firstThought": "Another writer may be protecting the only current snapshot.", "safePath": "Identify backend, lock ID, actor/run and liveness; wait or coordinate cancellation; force-unlock only a proven stale lock you own.", "trap": "Disable locking or force-unlock immediately."},
    {"id": "LES-0039-INC-003", "signal": "State appears empty and the plan wants to recreate everything.", "firstThought": "Wrong backend/workspace/key or lost state is more likely than universal drift.", "safePath": "Freeze execution, verify target identity, inventory backups by lineage/serial/digest, compare remote IDs and recover deliberately.", "trap": "Apply to repopulate state."},
    {"id": "LES-0039-INC-004", "signal": "Import succeeds but the next plan changes or deletes the adopted object.", "firstThought": "Import established a binding; it did not create accurate desired configuration.", "safePath": "Review provider schema, observed attributes, ownership and lifecycle intent; correct configuration before any change approval.", "trap": "Assume imported means fully managed and converged."},
    {"id": "LES-0039-INC-005", "signal": "A saved backup has a lower serial than current state after an outage.", "firstThought": "Restoring it may replay stale ownership and forget newer changes.", "safePath": "Keep writers frozen, compare lineage/serial and remote changes, prefer backend history, and use an approved reconciliation plan rather than forced overwrite.", "trap": "Push the oldest known-good file with force."}
  ],
  "assessmentIds": ["ASM-0100", "ASM-0101", "ASM-0102"],
  "referenceIds": ["REF-0343", "REF-0344", "REF-0345", "REF-0346", "REF-0347", "REF-0348", "REF-0349", "REF-0350", "REF-0351", "REF-0352", "REF-0353", "REF-0354", "REF-0355", "REF-0356", "REF-0357"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "The fixture uses built-in terraform_data objects and local state, not a cloud provider or durable remote infrastructure.",
    "Local state recovery does not prove remote backend locking, versioning, replication, encryption, access control or disaster recovery.",
    "Import is taught as a provider-bound production workflow but is not executed without a reviewed external provider and object.",
    "Force-unlock and state push are deliberately not automated; both require separate backend-specific evidence and authority.",
    "Terraform and OpenTofu state, plan, module and encryption compatibility must be proven for selected versions rather than inferred.",
    "No formal technical, security, instructional or accessibility review and no learner transfer evidence exists."
  ]
}
---

# Terraform and OpenTofu modules and state: preserve ownership before changing structure

## What you see and first thought

You move two resource blocks from `main.tf` into `modules/service/main.tf`. Nothing about the real service changed. The pull request looks tidy. Then the plan proposes two destroys and two creates.

Your first thought should not be, "Terraform is confused." The engine is being exact. The old address might be `terraform_data.api`; the new address is `module.service.terraform_data.api`. Without an explicit history connecting those addresses, they are different ownership records. A human recognizes the same idea; state recognizes exact addresses.

That gives you the senior operator's first rule for this chapter:

> Refactoring configuration is also migrating ownership identity. Preserve the binding before approving the new structure.

When a state incident appears, resist the fastest-looking command. `-lock=false`, `force-unlock`, `state rm`, `state push -force`, and manual JSON editing are not troubleshooting shortcuts. Each can disable or rewrite the system that prevents two configurations or two writers from claiming the same object.

Start with six questions:

1. Which product and version are running?
2. Which root module, backend, workspace and state key were selected?
3. What are the state's lineage, serial, digest and complete address-to-object bindings?
4. Is a lock held, and is its owner still alive?
5. Which configuration change, import, move or remote mutation preceded the symptom?
6. What user, data, security and availability consequence follows from each proposed action?

If the plan wants to create an entire environment, do not celebrate an easy rebuild. An empty or wrong state can make existing infrastructure look absent. Applying can create duplicates, collide with names, overwrite policy, or transfer traffic in ways the plan cannot understand. Freeze writers and prove state selection first.

The local lab deliberately creates real state but no real infrastructure. The built-in `terraform_data` resource lets the engine store two logical object bindings. You will move those bindings into a child module, corrupt only a protected disposable copy, restore it, and prove convergence. That is enough to expose state mechanics without a cloud account.

## Terms before commands

**Root module** means the configuration directory from which you run `plan` or `apply`. Every configuration has one. It sets the operational boundary: backend, provider configurations, child-module calls and top-level inputs.

**Child module** means a module called by another module. A child module is not a subprocess or independently deployed service. Its resources become nodes in the caller's combined graph, with addresses prefixed by the module call path.

**Module source** identifies where child-module code comes from. A relative path such as `./modules/service` is local. Registry, Git and archive sources can cause network retrieval. Source identity and version are supply-chain inputs, not decoration.

**Module contract** is the typed set of inputs, outputs, preconditions, postconditions, supported versions, provider requirements and lifecycle promises a caller may rely upon. A README alone is not enforcement; encode important assumptions where the tool can validate them.

**Composition** means a thin root module connects focused child modules by passing outputs to inputs. A network module can produce subnet IDs; a service module consumes them. Composition keeps dependencies visible and avoids a deeply nested module secretly creating everything it needs.

**Resource address** is the configuration identity of a resource instance, such as `module.service.terraform_data.component["api"]`. It includes module path, resource type/name and any instance key. State bindings are keyed by these addresses.

**Remote object ID** is the provider-specific identity of the real object. For this local fixture it is only a generated identifier inside built-in state. In production it could be a database ID, instance ID or policy identifier.

**State snapshot** is the engine's persisted ownership database at a point in time. It maps addresses to object identities and cached attributes and retains provider-related metadata. It is not merely a cache you can delete safely.

**Lineage** is an identifier that distinguishes independently created state histories. Two snapshots with different lineage are not automatically versions of the same state, even if their addresses look similar.

**Serial** is a monotonically increasing snapshot revision within a lineage. A higher serial normally means a later accepted state write. It does not prove correctness, but restoring a lower serial can forget later ownership changes.

**Backend** decides where state is stored and how operations interact with it. Backends are built into the CLI; providers are separate plugins that manage resource types. Some backends support locking, some do not, and their durability/security behavior differs.

**Workspace** selects one state instance within a backend configuration. CLI workspaces are not a universal environment-isolation strategy. Identical configuration plus a different workspace can target a different state while sharing code and credentials.

**Lock** is a single-writer coordination record for operations that may write state. A lock protects integrity; it is not proof that the owner is healthy. Lock failure should stop the run.

**Lock ID** is a backend-generated unique value used by force-unlock workflows. Possessing it is not authorization. You still need proof that the original writer is gone and will not resume.

**Import** creates a state binding between an existing remote object and a configured resource address. Import does not reverse-engineer full intent, prove ownership or guarantee the next plan is safe.

**Moved declaration** records that an existing address should be treated as a new address. It is versioned migration history. It prevents address-only refactors from becoming object replacement, within the product/version rules that support the move.

**Removed declaration** records that an address leaves management, optionally without destroying the object when supported/configured. Forgetting ownership is not deleting the remote object; another system must explicitly assume responsibility.

**Drift** is a difference between the last known state/configuration and a current provider observation. It may be intentional, unauthorized, provider-computed, or caused by incomplete observation. Drift is not the same as lost state.

**State recovery** means re-establishing trustworthy bindings and a safe next decision after state loss, corruption, failed persistence or selection error. File replacement is only one possible step; real recovery also reconciles remote objects and user outcomes.

**Sensitive** means presentation may be redacted. It does not mean a value is absent from state, plans, logs, backups or backend metadata. State must be treated as a high-value security asset.

## Architecture map

The useful design is not "one module per folder." Think in ownership and failure boundaries:

```text
                        ROOT MODULE
             target + backend + provider owners
                              |
          +-------------------+-------------------+
          |                   |                   |
          v                   v                   v
   module.network      module.data         module.service
   owns network        owns durable data   owns runtime units
          |                   |                   ^
          +---- outputs ------+------ inputs -----+

 State A: network bindings   State B: data bindings   State C: service bindings
 Lock A protects A           Lock B protects B        Lock C protects C
```

This does not demand three states. It makes the decision explicit. Resources that change together, share permissions, share recovery objectives and must be planned atomically may belong together. Resources with radically different permissions, data risk, change frequency or recovery ownership often deserve separate roots and state.

A module boundary and a state boundary solve different problems:

| Boundary | Primary job | Failure if overused | Failure if underused |
|---|---|---|---|
| child module | abstraction and reuse inside a graph | indirection, deep nesting, hidden ownership | repeated inconsistent logic |
| root module | composition and execution target | many tiny pipelines and coordination | one enormous blast radius |
| state partition | ownership, lock and recovery unit | cross-state coupling and eventual consistency | contention, broad credentials and dangerous recovery |
| repository/package | source lifecycle and versioning | dependency sprawl | coupled releases and unclear consumers |

The root should usually own provider configurations and pass provider instances deliberately. A reusable child module declares what provider source and minimum version it needs, but should not quietly own credentials or invent environment selection. That keeps trust decisions with the caller.

Prefer a shallow composition tree. A `service` module that secretly creates a network, identity system, database and monitoring stack is convenient only until another service must share one of them or a security team needs separate approval. Pass dependencies through typed object inputs and return small, stable outputs.

An output is an interface, not an export of the entire state. Expose what a consumer requires: perhaps `{id, cidr}` rather than every provider attribute. This reduces coupling, disclosure and change propagation. Marking an output sensitive affects display but does not secure the state that stores it.

Module versioning is migration policy. A new release that renames an internal address without a moved declaration can destroy consumer infrastructure. Removing historical moved declarations can break users upgrading from older releases. Deprecate inputs/outputs gradually, document supported upgrade paths, test from previous versions, and treat address history like a database schema migration.

## Request or state path

A mutating run crosses more boundaries than the terminal suggests:

```text
operator / pipeline
        |
        | source revision + variables + selected target
        v
Terraform/OpenTofu CLI ---- loads modules and providers
        |
        | backend configuration
        v
selected backend + workspace + state key
        |
        +---- acquire one writer lock ---- second writer waits/fails
        |
        +---- read lineage L, serial N, address bindings
        |
        +---- providers observe remote objects
        |
        +---- graph proposes actions
        |
        +---- approved execution changes remote objects
        |
        +---- write lineage L, serial N+1
        |
        +---- release lock
        v
fresh plan + remote checks + user verification
```

The backend is selected before resource evaluation. That is why backend configuration has special restrictions and why credentials embedded through backend arguments can persist in `.terraform` metadata or saved plans. A copied plan can contain a captured backend configuration and prior state. Protect it like state.

Every run needs a target tuple:

```text
product/version
+ configuration revision and root path
+ backend type/config identity
+ workspace/state key
+ account/project/subscription/region or local boundary
+ execution identity
+ state lineage/serial
```

If any element is unknown, "the plan looks right" is not enough. A correct plan against the wrong state is still a wrong operation.

State locking narrows concurrency, not authorization. It prevents cooperative writers using the same lock implementation from proceeding concurrently. It cannot stop another tool, a second backend key, a manual console change, a process using `-lock=false`, or an attacker with direct storage access.

The safest ordinary sequence is:

1. pin source and dependencies;
2. prove target identity;
3. acquire the supported lock;
4. read the newest trusted state;
5. refresh observations where appropriate;
6. generate a complete plan;
7. bind approval to that exact plan and target;
8. apply without changing inputs;
9. persist the next state before declaring success;
10. verify bindings, real objects, application behavior and a fresh plan.

If the provider action succeeds but state persistence fails, the remote object and state disagree. That is not a harmless failed pipeline. Preserve the recovery state the CLI emits, prevent another run, identify the real object, and reconcile through supported state operations with review.

## Failure zoom

### Wrong state selected

Signal: the plan wants to create many objects known to exist, or destroy objects belonging to another environment. Causes include wrong workspace, backend key, directory, environment variables, credentials or a newly initialized empty backend.

Immediate response: stop all writes. Record the target tuple. Do not apply to "repair" state. Compare known remote IDs, backend history, lineage and serial to locate the correct ownership database.

### Legitimate lock contention

Signal: the CLI cannot acquire a lock and shows another operation. The other run may be slow, waiting for a provider API or in approval.

Immediate response: find the run in the pipeline/backend, identify actor and start time, and wait or coordinate a safe cancellation. Never disable locking to run beside it.

### Stale lock

Signal: lock exists but the owning run and process are conclusively gone. Network partitions complicate this: the writer might resume.

Immediate response: prove backend and lock ID, prove owner absence across systems, understand whether leases expire, and obtain incident/change approval. Force-unlock only that exact proven stale lock. Then inspect state before any new write.

### Address refactor without migration

Signal: moves between files/modules or `count` to `for_each` produce replacement. The configuration identity changed even if remote attributes did not.

Immediate response: map old address, new address and remote ID. Add explicit moved history or use a reviewed supported migration. Require no unintended create/delete in the new full plan.

### Import creates dangerous follow-up plan

Signal: import proposes or completes a binding, then plan wants to modify or delete the object. Import learned identity and provider-readable attributes; it did not learn your desired intent.

Immediate response: review every configurable attribute, defaults, lifecycle and dependencies. Confirm the organization authorizes this configuration to own the object. Adjust code until the proposal matches intent.

### State corruption

Signal: JSON cannot decode, checksum/version validation fails, or the CLI reports unsupported state. Do not hand-edit the only copy.

Immediate response: freeze writers, preserve the corrupt bytes and storage/audit evidence, inventory backend versions and backups, validate candidates with the correct product/version, then restore through the backend's supported process.

### State loss

Signal: no trustworthy state is available but remote objects exist. This is different from corrupt bytes because the ownership map is missing.

Immediate response: restore backend versions or validated backups first. If none exists, reconstruct inventory and import objects one by one with reviewed configuration. A blanket create is not recovery.

### Partial write after remote success

Signal: provider says creation/update succeeded but backend write failed. Retrying may duplicate an object or conflict.

Immediate response: stop writers, retain local recovery state, query the provider with the same identity, and decide whether to push recovered state, import, or roll forward. Never assume an error exit means no remote effect.

## Internals and state ownership

State exists because configuration addresses are not remote identities. `module.database.aws_db_instance.main` says what the configuration calls an object; the provider might identify it with an opaque ID. State binds the two and retains attributes needed to calculate future changes.

A simplified snapshot conceptually contains:

```json
{
  "lineage": "history-identity",
  "serial": 17,
  "terraform_version": "selected-engine-version",
  "resources": [
    {
      "module": "module.service",
      "type": "example_resource",
      "name": "api",
      "provider": "provider-address",
      "instances": [
        {"index_key": "blue", "attributes": {"id": "remote-object-id"}}
      ]
    }
  ]
}
```

Do not build automation by depending on this internal shape. Use documented CLI JSON views and state subcommands. The internal format can evolve, and direct editing bypasses semantic, backup, lineage and serial safeguards.

The one-to-one rule is fundamental: one configured resource instance should bind to one remote object, and one remote object should not be claimed by multiple addresses. Violating it can make two configurations fight, alternate changes, or destroy an object another owner still needs.

State refresh updates cached observations; it does not decide whether drift was authorized. A plan may propose restoring configuration, accepting provider-normalized values, or replacing an object. Ownership and business intent remain human/policy decisions.

Lineage prevents accidentally treating unrelated histories as versions of each other. Serial prevents an older snapshot from casually overwriting a newer one. `state push` implementations usually check both, but force options can bypass safeguards. That is precisely why forced push belongs in a controlled recovery procedure, not a runbook's first page.

Local state typically lives as plaintext and may include sensitive attributes. Remote storage can improve collaboration and may offer access control, encryption, versioning, audit and locking, but "remote" guarantees none of those automatically. Evaluate the exact backend:

- Does it lock, and what are failure/lease semantics?
- Is state encrypted in transit and at rest?
- Who can read, write, delete, restore and list versions?
- Are accesses audited and alerts actionable?
- Are versions immutable or deletable by the same principal?
- What is the backup RPO and tested restore RTO?
- Can the runner retrieve state without exposing it in logs/artifacts?
- What happens when a write to the backend fails after provider success?

OpenTofu adds product-specific state and plan encryption capabilities. Encryption protects confidentiality at rest under its documented threat model; it does not prevent deletion, corruption, stale replay, an authorized runner reading plaintext, or key loss. Key backup and rotation become part of state recovery. Terraform and OpenTofu product behavior must be evaluated separately.

## Evidence table

Read every signal with a proof boundary. Senior engineers are careful about what evidence cannot establish.

| Evidence | What it proves | What it does not prove | Next action |
|---|---|---|---|
| `version -json` names product/version/platform | identity reported by that binary | trusted download or state compatibility | compare binary digest and approved manifest |
| `init` resolves one local child module | dependency observed in this root | future sources stay local | inspect source changes and lock data |
| `state list` prints expected addresses | selected state decodes and contains bindings | remote objects exist or are healthy | inspect IDs and provider observations |
| state has lineage L and serial 8 | identity/revision recorded in that snapshot | it is newest or correct target | compare backend history and audit |
| state digest matches protected backup | bytes match that backup | snapshot is semantically correct | validate addresses, lineage, serial, product |
| lock metadata names pipeline run 912 | lock record claims that owner | owner is alive or safe to interrupt | query runner/backend liveness |
| plan shows address moves only | exact proposal preserves binding identity | apply succeeds or all consumers upgraded | bind approval to saved plan and verify |
| import plan shows one object | provider can propose one adoption | desired configuration is accurate | inspect next actions/attributes and ownership |
| no changes after restore | selected code/state/observations converge | users, data and all external systems recovered | run service/data/security verification |
| state is encrypted | bytes at rest are unreadable without key under design | availability, integrity, anti-replay or runner secrecy | test backup/key recovery and access audit |
| backend supports locking | implementation offers a lock mechanism | every writer uses it or lock is correctly scoped | test contention and prohibit bypass |
| backend retains versions | older snapshots can exist | attacker/operator cannot delete them | separate delete/restore privileges and test |

A plan action summary loses critical context. "0 to destroy" sounds safe, but an in-place update could revoke access, rotate a key, change a network route or overwrite data. Review address, provider, before/after values, unknowns, replacement reasons, dependencies and user consequence.

For a refactor, build this table before approval:

| Old address | New address | Remote ID | Mechanism | Expected plan |
|---|---|---|---|---|
| `terraform_data.api` | `module.service.terraform_data.component["api"]` | captured from state | `moved` | address move, no create/delete |
| `terraform_data.worker` | `module.service.terraform_data.component["worker"]` | captured from state | `moved` | address move, no create/delete |

For a recovery, build a candidate table:

| Candidate | Lineage | Serial | Digest | Source/time | Concern |
|---|---:|---:|---|---|---|
| current backend | L | 14 | A | backend now | corrupt decode |
| version history | L | 13 | B | backend before failed run | may omit remote success |
| pipeline backup | L | 12 | C | earlier apply | definitely older |
| laptop file | X | 22 | D | unknown workspace | wrong lineage; reject |

Do not automatically choose the highest serial from an untrusted source or the newest timestamp from a laptop. Establish provenance, target, lineage, operation history and remote reality together.

## Command decoders

### `terraform init -input=false`

- `init` configures the backend and installs modules/providers. It can access networks depending on sources and CLI settings.
- `-input=false` refuses interactive questions; automation should fail instead of guessing.
- Backend configuration may be cached beneath `.terraform` and captured by plans. Do not put secrets in configuration or command history.
- Changing backend or module source normally requires reinitialization. Read whether the command proposes migration, reconfiguration or dependency upgrade.
- `-upgrade` deliberately broadens selected versions within constraints; never add it casually to every pipeline run.

### `terraform state list`

- Lists addresses in the selected state; it does not list every real provider object.
- Empty output can mean genuinely empty state, wrong target, lost state or no managed objects.
- It is read-only from the operator's perspective but may contact a remote backend and expose sensitive identifiers in terminal logs.

### `terraform state pull`

- Reads current state and emits raw state to standard output.
- Redirecting it creates a sensitive plaintext copy. Set a restrictive umask and protected path first.
- The CLI may upgrade the representation to one compatible with the current version, so a pull is not necessarily a byte-for-byte backend export.
- Never paste state into tickets or chat. Inventory and delete controlled copies through policy.

### `terraform show -json`

- Produces a documented machine-readable view of current state or a saved plan.
- JSON can expose values hidden in human display. Treat output as sensitive.
- It is better for automation than parsing colorized prose, but schemas are versioned and consumers must validate expected fields.

### `terraform plan -detailed-exitcode`

- Exit `0` means success with no changes.
- Exit `2` means success with proposed changes.
- Exit `1` means an error.
- Many scripts incorrectly treat any nonzero as failure and lose the change branch. Capture the exit code explicitly.
- A zero plan is scoped to exact source, inputs, selected state and observations at that time.

### `moved { from = ... to = ... }`

- `from` names historical address; `to` names current address.
- During planning the engine looks for the old binding and treats it as the new address.
- A moved declaration does not change a remote object merely because the address changes.
- Moves have type, module and version constraints. Verify exact product documentation.
- In reusable modules, retaining move history lets older consumers upgrade safely. Removing it can be a breaking release.

### `import { to = ... id = ... }`

- `to` is the destination address that will own the object.
- `id` or newer identity mechanisms are provider/resource-specific.
- The destination resource configuration must exist or be generated and reviewed.
- Configuration-driven import is visible in plan, but state changes occur only during the authorized execution stage.
- Importing the same object into two addresses violates one-to-one ownership even if the provider permits it.

### `terraform force-unlock LOCK_ID`

- Targets a lock, not infrastructure.
- It is safe only after proving the lock belongs to your dead operation and cannot resume.
- Local state generally cannot be unlocked by another process through this command; backend behavior differs.
- `-force` removes confirmation, not risk.

### `terraform state push`

- Writes an entire state snapshot and can overwrite remote ownership data.
- Lineage and serial checks prevent some mistakes, not all semantic errors.
- A force flag bypasses critical safeguards.
- Prefer backend version restore or supported configuration-driven operations. If push is unavoidable, require frozen writers, protected before/after snapshots, exact peer approval and remote reconciliation.

### `terraform state mv`, `rm`, and `replace-provider`

- These are supported advanced state operations and normally create backups.
- Prefer versioned configuration-driven `moved`, `removed` and `import` history when it fits, because reviewers and future runs can see the migration.
- `rm` forgets an object; it does not delete it. The next plan may try to create a replacement.
- `replace-provider` rewrites provider ownership addresses and needs version/provider compatibility review.
- Never pipe generated addresses into mutation without reviewing the complete set.

## Decision path

Use this order when state looks wrong:

```text
Does the proposal contain an unexpected create/delete or state error?
  |
  +-- no --> continue full consequence and user review
  |
  +-- yes --> freeze writers; record exact target tuple
               |
               +-- lock exists? --> prove owner/run liveness
               |                    +-- alive: wait/cancel cooperatively
               |                    +-- dead: reviewed exact unlock path
               |
               +-- state decodes? --> record lineage/serial/digest/addresses
               |                    compare remote IDs and config history
               |
               +-- state missing/corrupt? --> preserve evidence and candidates
               |                            validate backend history/backups
               |
               +-- only addresses changed? --> moved/import/removed design
               |
               +-- remote drift? --> identify owner and desired authority
               |
               +-- recover under one lock --> fresh full plan --> verify users
```

Detailed workflow:

1. **Stop expansion.** Pause pipelines and humans targeting the same backend key. Do not create parallel recovery teams that both write.
2. **Record identity.** Capture product/version, root revision, backend/workspace/key, execution identity and incident timestamp.
3. **Preserve artifacts.** Retain error output, lock metadata, saved plans, recovery state, backend audit and remote operation IDs in protected storage.
4. **Check active owner.** Determine whether a writer is alive, paused, partitioned or completed remotely. Coordinate instead of unlocking blindly.
5. **Inventory state candidates.** Record provenance, lineage, serial, digest, addresses and timestamps without overwriting anything.
6. **Inventory remote reality.** With read-only provider access, map real object IDs, last changes, health, data and security state.
7. **Classify.** Wrong target, stale lock, corrupt snapshot, lost snapshot, address refactor, import gap, drift or partial persistence require different fixes.
8. **Choose the least-changing repair.** Correct target selection before restore; moved declaration before recreation; backend version restore before forced state push; verified import before duplicate creation.
9. **Review the repair itself.** A state-only change can have the same blast radius as infrastructure change because it alters future ownership.
10. **Execute once under lock.** Bind operator, approval and artifacts. Stop on any unexpected address, serial or remote result.
11. **Reconcile.** Confirm state bindings, provider IDs, data integrity, security controls and application behavior.
12. **Prove convergence.** A fresh full plan should be understood. Zero change helps but does not replace user verification.
13. **Repair the system.** Fix module migration tests, backend controls, backup drills, alerting and runbooks that allowed the incident.

When an address changes, first ask whether this is the same logical object. If yes, preserve identity with moved history. If ownership moves between separate state files, plan both sides as a transaction-like operational sequence: protect both states, ensure only one owns the object at each step, and define interruption recovery. There is no magical atomic transaction across two backends.

When state is lost, prefer restoration over mass import because a trustworthy snapshot contains provider/address metadata and many attributes. If restoration is impossible, import deliberately per object. After each batch, review a full plan and ensure no object is double-owned.

## Guided Ubuntu lab

This lab creates only local state and built-in `terraform_data` records. It has no external provider, network, credential or remote backend. Even so, treat the state as sensitive operational material and stay inside the wrapper.

### Preconditions

- Ubuntu 24.04 normal user; UID 0 is refused.
- Bash, Python 3 and either checksum-approved Terraform 1.15.8 or OpenTofu 1.12.1.
- No provider credentials in the environment.
- No network after separately authorized CLI acquisition.
- Start in `drafts/LES-0039-terraform-opentofu-modules-state-recovery/support/lab`.

### Phase 1: doctor and setup

```bash
bash lab.sh doctor terraform
bash lab.sh setup terraform
bash lab.sh status
```

Read every reported boundary: UID-scoped `/tmp` path, sentinel, product, CLI path, version and SHA-256. Setup copies only the reviewed v1 local fixture; `stage-v2` introduces the reviewed local child module later. The wrapper refuses symlinks, unexpected children, external provider declarations, remote backends and unbound binaries. To use OpenTofu, replace `terraform` with `tofu` and begin from a clean lifecycle; never alternate products against one state.

### Phase 2: initialize and create bounded state

```bash
bash lab.sh run init
bash lab.sh run plan-v1
bash lab.sh run apply-v1
bash lab.sh run inspect-v1
```

The v1 plan must contain exactly two creates and no updates/deletes. Apply is allowed only because the built-in records create no external infrastructure. Inspect should show two root addresses, one lineage and a serial. `stage-v2` preserves this validated v1 snapshot so the guard can compare both object IDs, lineage and serial after the move. The protected recovery copy and digest are created later by `backup`.

Explain aloud:

- Configuration supplies two root addresses.
- The built-in provider assigns state IDs.
- The state, not the `.tf` file, binds addresses to those IDs.
- The backup is sensitive even though this fixture has no secrets.

### Phase 3: refactor into a child module

```bash
bash lab.sh run stage-v2
bash lab.sh run plan-refactor
bash lab.sh run apply-refactor
bash lab.sh run inspect-v2
```

V2 calls a local `service` module using stable keys and includes two moved declarations from root addresses to module addresses. The guarded plan must show move-only semantics with zero create/update/delete. After apply, state lists the module addresses with the same two IDs.

If you remove a moved declaration and see recreation, stop. That is the lesson working. Do not apply the bad plan.

### Phase 4: inject corruption and restore

```bash
bash lab.sh run backup
bash lab.sh run corrupt
bash lab.sh run prove-refusal
bash lab.sh run restore
bash lab.sh run converge
```

The wrapper validates the current snapshot, creates a protected copy, records its digest, and then writes malformed content only to the disposable live state. `state list` must fail. Restore first validates backup lineage, addresses, IDs and digest, copies it back, then requires a no-change plan.

This proves only a local file recovery. A remote backend restore also needs backend versions, lock ownership, access controls, audit, writer freeze and remote reconciliation.

### Phase 5: cleanup

```bash
bash lab.sh cleanup
bash lab.sh status
```

Cleanup revalidates exact path, parent, UID, sentinel, CLI binding and allowed inventory. It destroys no infrastructure because none exists. It removes only the lesson directory and proves absence. If validation fails, it refuses recursive removal and leaves evidence for inspection.

### Questions to answer while running

1. Why did file movement change the address even though attributes stayed equal?
2. Which bytes identify lineage, serial and object IDs?
3. What did the moved declarations change in the plan?
4. Why is a digest necessary but insufficient for backup trust?
5. Why would `state push -force` be an unsafe generic restore step?
6. What additional evidence would a real database recovery require?

## Production transfer

The production version is mainly governance around the same mechanics.

### Module engineering standard

- One clear purpose and lifecycle boundary per reusable module.
- Typed inputs with validation; small outputs with documented meaning.
- Root owns provider configurations, credentials and environment target.
- Minimum compatible versions in reusable modules; controlled upper bounds and lock files in roots according to product policy.
- Local or immutable versioned source; no floating default branches for production.
- Shallow composition and dependency inversion.
- Tests for defaults, changed constraints, invalid values and upgrade paths.
- Chained moved declarations retained across supported upgrade windows.
- Changelog identifies address, input/output and provider-breaking changes.
- Consumer inventory tells maintainers which versions and state roots exist.

### Backend engineering standard

- Unique, reviewable key per ownership boundary and environment.
- State read/write/delete/restore privileges separated where possible.
- Locking enabled and bypass prohibited in ordinary workflows.
- Encryption and transport controls verified, with key recovery tested.
- Immutable/versioned backup with protected retention and deletion controls.
- Audit logs for read, write, delete, restore and permission changes.
- Monitoring for lock age, failed persistence, access anomalies and version deletion.
- Tested restore procedure with measured RPO/RTO and representative object reconciliation.
- Runner avoids printing state, plans or backend credentials.

### Refactor release

1. Inventory every consumer and supported starting version.
2. Map old addresses to new addresses and remote IDs.
3. Add moved history before or with the structural change.
4. Test upgrades from each supported previous module version.
5. Review a refreshed full plan against protected non-production state.
6. Canary one low-risk consumer where organizational policy permits.
7. Roll forward in controlled batches with state backup and service checks.
8. Retain moved history until every supported upgrade path no longer requires it—and treat removal as breaking.

### Import/adoption release

1. Establish legal/technical owner and change authority.
2. Back up destination state and prove one-to-one ownership.
3. Record exact provider/version and import identifier semantics.
4. Write or generate configuration, then remove provider defaults you do not intend.
5. Plan the import and all follow-on changes together.
6. Review data, availability, policy, identity, network and cost consequences.
7. Execute under lock, verify the binding and immediately run a fresh full plan.
8. Update asset inventory and remove competing automation/manual ownership.

### Recovery release

Declare recovery complete only when:

- one state lineage and newest reconciled serial are authoritative;
- exact addresses map to the correct provider IDs;
- there is no active competing writer;
- backend durability, versioning, lock and encryption controls work;
- real objects and data are present and healthy;
- security/identity/network controls match intended policy;
- service-level and user-journey checks pass;
- a fresh plan has no unexplained action;
- evidence, timeline and corrective actions are preserved.

## Reliability, security, observability, capacity, and cost

**Reliability:** state is part of the control plane. Losing it may not immediately stop serving traffic, but it can make the next change destructive or impossible. Give state a service owner, availability target, recovery objectives, runbook, backup verification and incident severity model. Measure restore time using a realistic state size and object inventory, not an empty demo.

State partitions define failure domains. One state for thousands of unrelated objects creates broad lock contention, long plans and high recovery blast radius. Hundreds of tiny states create cross-state dependencies, coordination gaps and operational overhead. Partition by cohesive lifecycle, permission boundary, change rate, team ownership and recovery need—not an arbitrary resource count.

**Security:** state often contains resource attributes, identities, endpoints and secrets. Restrict read as strongly as write. A read-only state leak can expose credentials or architecture. Protect saved plans, pull files, backups, `.terraform` metadata, CI artifacts, debug logs and support bundles. Redaction in terminal output is not storage encryption.

Backend credentials should come from short-lived runner identity or protected environment integration, not source or `-backend-config` values that may be copied into metadata and plan files. Separate ordinary plan/apply permission from state restore/delete and encryption-key administration. Alert on unusual pulls, forced unlocks, state pushes, version deletion and policy bypass.

**Observability:** useful signals include lock acquisition latency, lock age, plan/apply duration, state read/write failures, serial changes, state size, address count, provider request failures, backup version creation, restore tests and unexplained plan actions. Correlate them with source revision, pipeline run, actor, backend key and state lineage without logging sensitive values.

A lock-age alert needs context. Long applies can be legitimate. Route it with owner/run metadata and a liveness check, not an automation that force-unlocks. A failed state write after provider success is an incident-worthy signal because control-plane ownership may now disagree with reality.

**Capacity:** large state increases refresh, graph, serialization, transfer and lock-hold time. Deep modules do not themselves reduce state size. Measure resources/instances, JSON size, provider API requests, plan latency, memory, concurrency and lock wait. Split only after mapping atomic change and cross-state dependencies.

State backends have quotas, object-size limits, rate limits, consistency behavior and retention limits. Include these in capacity planning. A backup system that silently stops versioning at quota is not a backup.

**Cost:** module reuse can reduce engineering effort but may spread expensive defaults at scale. Backend storage is usually cheap; audit, version retention, KMS, runners and engineering response cost more. Do not disable versioning or locking to save trivial cost. Track cost per environment, module version and major resource output, while recognizing that tags/labels in configuration do not guarantee billing allocation.

**OpenTofu/Terraform boundary:** shared concepts do not imply identical encryption, backend, import, testing, state schema or compatibility behavior. Pick a supported product per root, pin versions, test upgrades on copies, and never alternate binaries against production state merely because both parse the configuration.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| "State is only a cache" | deletes ownership mapping and can propose duplicates | treat state as protected control-plane data |
| commit state to Git | leaks sensitive values and lacks safe locking | secured backend plus ignored local artifacts |
| disable locks in CI | permits concurrent writers and stale snapshots | fail closed; repair contention/throughput |
| force-unlock on first error | may release a live writer | prove exact owner death and backend scope |
| restore oldest known-good backup | forgets newer bindings/remote changes | compare lineage, serial, audit and remote reality |
| edit JSON by hand | bypasses schema and semantic safeguards | supported state/configuration operations |
| `state push -force` as runbook step one | bypasses lineage/serial protection | backend restore or reviewed reconciliation first |
| import then immediately apply | configuration may not match adopted reality | inspect attributes and full follow-up plan |
| remove/import same object in parallel | creates zero-owner or double-owner window | single coordinated migration with freeze/recovery |
| move files without `moved` | changes addresses and proposes recreation | versioned address migration map |
| remove old moved blocks quickly | breaks consumers skipping versions | retain chained history through support window |
| module owns its provider credentials | hides target and prevents caller control | root-owned provider configuration |
| floating module Git branch | source changes without reviewed version bump | immutable commit/tag and checksum/provenance policy |
| one giant module | hides dependencies and couples lifecycles | cohesive modules composed by thin root |
| module for every resource | indirection without abstraction | module only for meaningful contract/lifecycle |
| output entire resource objects | leaks attributes and couples consumers | minimal typed stable outputs |
| remote backend assumed secure | remote only describes location | verify lock, access, encryption, versions, audit |
| encrypted state assumed recoverable | lost key or deleted bytes remain fatal | state and key backups with restore drills |
| zero-change plan equals healthy system | plan is not user/data verification | service, data, security and journey checks |
| alternate Terraform/OpenTofu on one state | unproved cross-product compatibility | controlled migration rehearsal and support decision |

Prevention belongs in automation:

- reject tracked `terraform.tfstate`, `.terraform`, plan and pulled-state artifacts;
- require a generated inventory of root/backend/workspace ownership;
- validate module sources and versions;
- run upgrade/refactor tests from supported previous releases;
- reject unexplained create/delete during a declared refactor;
- enforce one apply per state key and prohibit `-lock=false`;
- require exceptional approval for force-unlock, state mutation and restore;
- scan logs/artifacts for state-shaped data without printing matches;
- test backend version restore and encryption-key recovery;
- require post-change fresh plan plus service verification.

## Memory card and retrieval

Remember **BIND** when a state incident starts:

- **B — Boundary:** product, root, backend, workspace/key, identity.
- **I — Integrity:** lock owner, lineage, serial, digest, backup provenance.
- **N — Name mapping:** address to provider ID, old to new, one to one.
- **D — Decision:** least-changing repair, reviewed execution, user verification.

Remember the sentence:

> Configuration says what should exist; state says which configured address owns which object; the provider says what it sees now; the plan proposes how to reconcile them.

Sixty-second recall:

1. Why is state necessary? It maps configuration addresses to remote identities and retains metadata needed for planning.
2. What does a lock protect? Cooperative single-writer state integrity.
3. When can you force-unlock? Only a proven stale lock owned by a dead operation, with exact backend/lock evidence and approval.
4. What does import do? Establishes one state binding; it does not create trustworthy intent.
5. What does `moved` do? Preserves binding identity across supported address refactors.
6. Why not restore any backup? Wrong lineage or lower serial can overwrite another history or forget newer changes.
7. What proves recovery? Correct bindings and remote IDs, fresh understood plan, real data/security/service/user verification.

Retrieval drills:

- Draw configuration, state, provider and plan without notes.
- Given five addresses, identify module path, resource identity and instance key.
- Explain why a moved block is a database migration for ownership.
- Explain the difference between wrong state, drift, corrupt state and lost state.
- Defend why force-unlock is evidence-driven rather than time-driven.
- Design module/state partitions for network, database and service layers.
- Give a restore plan that mentions writer freeze, lineage, serial, backup provenance, remote reconciliation and users.

## Complete answers

### Why did extracting resources into a module propose replacement?

Because full resource addresses changed. `terraform_data.api` and `module.service.terraform_data.api` are different state keys. The engine cannot infer that a human considers them the same object. Without explicit migration history, the old address is absent from configuration and the new address has no binding, so destroy/create is a rational proposal. Map old/new addresses and IDs, add supported moved declarations, and require a new full plan containing only address moves.

### What is state, in practical terms?

State is a versioned ownership database and observation cache. It binds exact configuration instance addresses to provider-specific object identities, records provider association and cached attributes, and carries lineage/serial metadata. It enables the engine to distinguish create, update and delete. It can contain sensitive data and is a critical control-plane asset.

### What are lineage and serial?

Lineage distinguishes independent state histories. Serial orders snapshots inside one lineage. Before restore, confirm both. A different lineage may be another environment; a lower serial may omit later successful work. Neither field alone proves semantic correctness, so also compare provenance, addresses, operation audit and real provider IDs.

### Why is lock failure a useful refusal?

It prevents a second cooperating writer from reading an old snapshot and later overwriting the first writer's newer result. The safe response is to identify the lock owner and coordinate, not bypass it. Locking is scoped to the backend/key and cannot stop unrelated tools or wrong-key runs.

### When is force-unlock justified?

Only when the exact lock belongs to your operation, the operation and any remote execution are conclusively dead, it cannot resume after a partition, the target/backend/lock ID are verified, state has been inspected, and responsible approval exists. Then unlock that one lock and generate a fresh plan. Age alone is insufficient.

### What does import not do?

It does not prove organizational ownership, generate perfect configuration, understand business intent, remove another owner's claim, validate lifecycle safety or guarantee convergence. It binds an existing provider object to a configured address. The next plan may still be destructive, so adoption needs an ownership inventory and complete review.

### Why prefer moved declarations over ad-hoc `state mv`?

Moved declarations preserve migration intent in versioned configuration and apply consistently for consumers upgrading from historical addresses. CLI state moves can be appropriate for exceptional/cross-state operations but are operator-side mutations whose history is easier to lose. The correct choice depends on product/version and migration shape.

### How should modules be divided?

Group resources that express one meaningful abstraction and cohesive lifecycle. Keep root composition shallow. Pass dependencies as typed inputs, expose minimal outputs, let the root own providers, and align state partitions with change atomicity, permission, blast radius and recovery. Do not use a module merely to hide every resource block.

### How do you recover corrupt state?

Freeze writers; record target and lock; preserve corrupt bytes and audit; inventory backend versions/backups by provenance, lineage, serial and digest; inspect remote object IDs; select the least-stale correct candidate; restore using backend-supported tooling under one lock; run a fresh plan; reconcile any action since the backup; verify data, security, service and users. Never edit the only copy.

### What if provider action succeeded but state write failed?

Assume remote side effects may exist. Stop subsequent runs, retain CLI recovery state, query provider operation/object evidence with the same identity, and reconcile the binding. Depending on facts, restore/push the recovery snapshot with strict review, import the created object, or roll forward. Blind retry can duplicate or conflict.

### Does encryption solve state security?

It helps confidentiality at rest when correctly implemented and keys are protected. It does not prevent authorized runners from reading values, deletion, corruption, stale replay, wrong-state use, insecure logs, or key loss. Access control, audit, versioning, backups, key recovery and minimized secrets remain necessary.

### Does a no-change plan prove success?

It proves that the selected configuration, state and observed provider attributes produced no proposed changes at that time. It does not prove users can transact, data is complete, security policy is effective, backups are restorable, or another system is healthy. Pair it with system-specific verification.

## Product-company interview

**Question: Design Terraform/OpenTofu state for 200 teams.**

A strong answer begins with ownership rather than naming buckets. Define root/state units by cohesive lifecycle, permissions, blast radius, change rate and recovery objectives. Use a backend with locking, encryption, versioning, audit and tested restore; separate plan/apply from restore/delete privileges; federate short-lived runner identity; inventory every root, key, owner and module version. Enforce one writer per key, immutable source/dependency review, plan-policy-approval binding, state/plan artifact protection, and post-change verification. Measure lock wait, failed persistence, state size/serial changes and recovery drills. Avoid one global state and avoid cross-state cycles.

**Question: A pipeline is locked for 45 minutes. What do you do?**

Identify exact backend/key, lock ID, operation, actor and pipeline run. Check runner/backend liveness and provider operation status. If alive or uncertain, wait or coordinate cancellation. If conclusively dead and unable to resume, preserve state/audit, obtain approval, force-unlock only that lock, inspect current state and generate a fresh full plan. I never disable locking or infer staleness from elapsed time alone.

**Question: How do you refactor a production resource into a module without recreation?**

Inventory every old address, new address and remote ID. Add the child module and explicit moved declarations supported by the pinned product version. Test upgrade from all supported old module versions using protected state copies. Require a refreshed plan with move-only address changes and no create/update/delete unless separately intended. Apply the exact reviewed plan under lock, verify IDs unchanged, run service checks and retain migration history.

**Question: State is gone but infrastructure exists. Recover it.**

Freeze writers and verify this is not merely wrong workspace/backend selection. Search backend version history and protected backups, validating target, lineage, serial, digest and provenance. Compare candidates with audit and real object IDs. Restore the newest correct reconciled snapshot through supported backend mechanisms. If no trustworthy snapshot exists, reconstruct configuration/inventory and import in reviewed batches, ensuring one-to-one ownership. After each stage, review a full plan and verify data, security and users.

**Question: Why not store state in Git?**

Git does not provide operation-scoped state locking and state can expose sensitive attributes. Merge semantics are wrong for a single-writer ownership database, and clones/history multiply disclosure and deletion problems. Use a backend with controlled reads/writes, locking, encryption, versions and audit. Keep state, plans and backend metadata out of source.

**Question: How do Terraform and OpenTofu affect your design?**

I treat them as separate products with shared ancestry. I pin core/provider/module versions, record the product that owns each root, test state/plan/module/backend behavior before migration, and never alternate binaries on production state. OpenTofu-specific encryption or import features and Terraform-specific version behavior are adopted only with exact documentation and recovery tests.

**Question: When should state be split?**

When ownership, permissions, change/recovery lifecycle, scale or lock contention make independent control valuable. I map dependencies first because splitting removes atomic planning across the boundary and can introduce stale output coupling. I avoid cycles, prefer stable contract publication, and design failure recovery for both sides.

**Question: What is your module quality bar?**

Cohesive purpose, typed validated inputs, minimal stable outputs, caller-owned providers, pinned/compatible dependencies, shallow composition, tests for normal/invalid/upgrade behavior, security defaults, documented operational signals, moved history, changelog, consumer inventory and reproducible examples. A module that merely hides complexity without a stable contract is not automatically useful.

## Independent transfer and rubric

Your reviewer supplies an unfamiliar provider-free case with:

- one root module and two child modules;
- six existing state bindings;
- a proposed module split and `count` to `for_each` change;
- two state candidates with the same lineage but different serials;
- one unrelated candidate with a different lineage;
- a lock record whose owner status requires evidence;
- one intentional drift and one partial-persistence clue;
- no cloud credentials and no permission to force-unlock or push state.

Produce, without lesson answers:

1. execution target tuple and freeze plan;
2. module contract/ownership diagram;
3. old/new address-to-object migration table;
4. lock owner/liveness decision;
5. candidate state provenance/lineage/serial/digest table;
6. classification of drift, refactor and partial persistence;
7. least-changing recovery sequence with abort conditions;
8. proposed plan assertions and evidence limits;
9. security, backup and observability improvements;
10. cleanup proof and a five-minute executive incident explanation.

Scoring is performed through `ASM-0102` without exposing its answer record. Required gates:

- 90/100 overall;
- no unsafe force-unlock, lock bypass, manual JSON edit or state force-push;
- exact target, lineage, serial and address reasoning;
- one-to-one ownership maintained through every step;
- no unreviewed create/delete;
- recovery verifies remote identity and user/system outcome;
- delayed recall after at least seven days uses a changed case.

Project-generated artifacts, including this chapter and lab output, are not learner evidence. Mastery requires the learner to diagnose and defend an unseen transfer under review.

## References and review

This chapter is grounded in primary, product-specific documentation reviewed on 2026-08-04:

1. `REF-0343` — Terraform: creating reusable modules.
2. `REF-0344` — Terraform: module composition and dependency inversion.
3. `REF-0345` — Terraform: state purpose, ownership and format boundary.
4. `REF-0346` — Terraform: backend configuration and credential persistence warning.
5. `REF-0347` — Terraform: state locking and force-unlock caution.
6. `REF-0348` — Terraform: configuration-driven module/resource refactoring.
7. `REF-0349` — Terraform: configuration-driven import.
8. `REF-0350` — Terraform: state subcommands and mandatory backups.
9. `REF-0351` — Terraform: state pull behavior and version conversion.
10. `REF-0352` — Terraform: refactoring and cross-state migration guidance.
11. `REF-0353` — OpenTofu: modules and root/child boundaries.
12. `REF-0354` — OpenTofu: backend storage, locking and dangerous push boundary.
13. `REF-0355` — OpenTofu: state locking and exact force-unlock conditions.
14. `REF-0356` — OpenTofu: state and plan encryption threat model and recovery risks.
15. `REF-0357` — OpenTofu: refactoring and moved declarations.

Review the exact version documentation before a production change. Provider import identifiers and type-change support are provider-specific. Backend locking, versioning, encryption, consistency and recovery differ. Revalidate this chapter by 2027-02-04 or sooner if Terraform/OpenTofu state, backend, import, encryption or module behavior changes.

Promotion requires direct schema/relationship checks, rubric parity, checksum-bound dual-CLI execution of the guarded state/refactor/recovery fixture, Ubuntu lifecycle and refusal evidence, complete canonical regressions, formal technical/security/instructional/accessibility review, and unseen learner transfer. Until then this remains quarantined and awards no mastery.
