---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0038",
  "slug": "terraform-opentofu-language-plan",
  "aliases": ["V05-L02", "terraform-opentofu-language-plan"],
  "curriculumIds": ["TFM-001"],
  "route": "/book/infrastructure/terraform-opentofu-language-plan",
  "order": 2,
  "volume": "05-infrastructure-platforms",
  "title": "Terraform and OpenTofu language: read the graph before the plan changes anything",
  "summary": "Learn HCL as a typed declarative language, trace values and dependency edges, preserve instance identity, validate contracts, test plan-known behavior, inspect saved plans and compare Terraform with OpenTofu in a provider-free local lab that never applies.",
  "domain": "infrastructure",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0037"],
  "prerequisiteCurriculumIds": ["IAC-001"],
  "testedEnvironments": [
    {"platform": "Terraform", "version": "1.15.8 windows_amd64", "support": "supported", "notes": "Checksum-matched standalone CLI executed fmt, backend-disabled init, validate, two plan-only native tests, a saved provider-free plan, JSON show, graph and negative-variable refusal in a disposable Windows directory; no apply, state or external provider was used."},
    {"platform": "OpenTofu", "version": "1.12.1 windows_amd64", "support": "supported", "notes": "Checksum-matched standalone CLI executed the same provider-free workflow and semantic checks; archive signatures were not independently verified, so checksum equality is not a complete provenance claim."},
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The intended learner workflow is a normal-user Bash wrapper using a separately checksum-verified CLI. WSL startup is currently blocked, so the complete Ubuntu lifecycle remains unproved."},
    {"platform": "Cloud and remote infrastructure", "version": "not used", "support": "unsupported", "notes": "The lesson supplies no cloud provider, credential, remote backend or apply permission."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead"],
  "learningObjectives": [
    "Read HCL blocks, arguments and expressions without confusing file order with dependency order.",
    "Model inputs with exact primitive and structural types, validation rules and stable defaults.",
    "Transform collections with locals, for expressions and functions while preserving understandable data flow.",
    "Explain resource addresses, count indices, for_each keys and the replacement risk of unstable identity.",
    "Derive implicit graph edges from references and justify rare explicit depends_on relationships.",
    "Separate configuration validation, native tests, speculative plans, saved plans, machine-readable plans and apply authorization.",
    "Distinguish plan-known, sensitive and unknown-after-apply values and explain their policy consequences.",
    "Review a plan by address, action, before/after value, unknowns and downstream consequence rather than action totals alone.",
    "Compare shared Terraform/OpenTofu concepts while checking product version, syntax and behavior instead of assuming interchangeability.",
    "Run and clean a provider-free local workflow without credentials, provider downloads, remote state or apply."
  ],
  "productionSignals": [
    "CLI product, exact version, platform, archive digest and provenance evidence",
    "configuration revision, module root, working directory and formatting result",
    "required_version, required_providers, dependency lock and module source identity",
    "variable source, precedence, type, sensitivity, validation and unknown status",
    "resource and module addresses including for_each keys or count indices",
    "implicit and explicit graph edges, cycles, parallel branches and unknown nodes",
    "test file, run name, command mode, assertions, mocks or overrides and result",
    "backend-disabled or backend identity, workspace, target and credential boundary",
    "plan configuration/state/prior-state identities, digest, timestamp and creator",
    "resource action, replacement reason, before/after values and after-unknown map",
    "policy decision, exception, reviewer, approval and exact saved-plan binding",
    "post-execution state, remote object and user-outcome evidence when apply is separately authorized"
  ],
  "diagrams": [
    {"id": "LES-0038-DIA-001", "title": "HCL evaluation to proposed actions", "direction": "left-to-right", "boundaries": ["files", "blocks", "expressions", "typed values", "instances", "graph", "plan"], "evidencePoints": ["revision", "type", "address", "edge", "action"], "textAlternative": "Configuration files are parsed as one module; expressions produce typed values, meta-arguments expand instances, references form graph edges and the engine proposes actions in a plan."},
    {"id": "LES-0038-DIA-002", "title": "Value knowledge states", "direction": "hierarchical", "boundaries": ["known configuration value", "sensitive known value", "unknown until provider action", "computed output"], "evidencePoints": ["type", "sensitive mark", "after_unknown", "test boundary"], "textAlternative": "A value may be known during planning, known but redacted as sensitive, or unknown until execution. Derived outputs inherit those knowledge limits."},
    {"id": "LES-0038-DIA-003", "title": "Instance identity expansion", "direction": "top-to-bottom", "boundaries": ["resource block", "count indices", "for_each keys", "resource addresses", "remote bindings"], "evidencePoints": ["index", "stable key", "address change", "replacement risk"], "textAlternative": "One resource block expands into instances. Count assigns positional indices while for_each assigns caller-chosen keys; changing identity can alter state bindings even if attributes look similar."},
    {"id": "LES-0038-DIA-004", "title": "Implicit dependency graph", "direction": "hierarchical", "boundaries": ["variables", "locals", "service instances", "catalog", "outputs"], "evidencePoints": ["reference", "edge", "ready node", "parallel walk"], "textAlternative": "Variable values feed locals; service instances can be evaluated in parallel; the catalog references all service instances and outputs depend on the catalog, forming order without file-position rules."},
    {"id": "LES-0038-DIA-005", "title": "Validation layers", "direction": "left-to-right", "boundaries": ["fmt", "init", "validate", "test", "plan", "policy and review", "authorized apply", "verification"], "evidencePoints": ["exit code", "dependency identity", "assertion", "artifact digest", "decision", "user result"], "textAlternative": "Each validation layer answers a narrower question. Passing earlier layers permits investigation of later layers but never proves safe execution or user success."},
    {"id": "LES-0038-DIA-006", "title": "Terraform and OpenTofu comparison boundary", "direction": "cyclic", "boundaries": ["shared HCL history", "Terraform version", "OpenTofu version", "provider registry", "state and plan formats", "verified behavior"], "evidencePoints": ["product", "version", "documentation", "test", "migration decision"], "textAlternative": "The products share historical concepts but evolve independently. Compatibility is a versioned claim tested across language, providers, state, plans and operational workflow."}
  ],
  "commands": [
    {"id": "LES-0038-CMD-001", "question": "Which identity and directory bound this run?", "risk": "read-only", "command": "id; uname -a; cat /etc/os-release; date -u +%Y-%m-%dT%H:%M:%SZ; pwd", "runFrom": "a normal Ubuntu shell", "expectedBranches": [{"when": "UID is non-root and the path is the approved lab", "meaning": "the host boundary is recorded", "nextEvidence": "verify CLI identity"}, {"when": "UID is zero or the directory is unexpected", "meaning": "the learner contract is not met", "nextEvidence": "stop before initialization"}], "proves": "reported host identity and path at one time", "doesNotProve": "CLI provenance or target safety"},
    {"id": "LES-0038-CMD-002", "question": "Which IaC product and version will interpret the configuration?", "risk": "read-only", "command": "terraform version -json", "runFrom": "a shell where the separately verified Terraform CLI is on PATH", "expectedBranches": [{"when": "the approved product and version appear", "meaning": "the interpreter identity matches the exercise", "nextEvidence": "compare its binary digest to the approved manifest"}, {"when": "the command is absent, outdated or unexpected", "meaning": "results are not comparable", "nextEvidence": "stop and resolve the tool boundary"}], "proves": "self-reported product version and platform", "doesNotProve": "archive signature, binary integrity or configuration safety"},
    {"id": "LES-0038-CMD-003", "question": "Is canonical formatting already satisfied?", "risk": "read-only", "command": "terraform fmt -check -diff -recursive", "runFrom": "a disposable copy of the LES-0038 fixtures", "expectedBranches": [{"when": "exit code is zero with no diff", "meaning": "recognized files match formatter output", "nextEvidence": "initialize without a backend"}, {"when": "a diff appears", "meaning": "format is noncanonical", "nextEvidence": "review and intentionally format source"}], "proves": "formatter parity for recognized files", "doesNotProve": "valid types, graph or safe plan"},
    {"id": "LES-0038-CMD-004", "question": "Can the module initialize without a backend or external provider?", "risk": "mutating-bounded", "command": "CHECKPOINT_DISABLE=1 TF_IN_AUTOMATION=1 terraform init -backend=false -input=false", "runFrom": "the validated disposable lab state", "expectedBranches": [{"when": "the built-in terraform provider is reported", "meaning": "no external provider package is required", "nextEvidence": "inspect initialization artifacts and validate"}, {"when": "a provider or module download is requested", "meaning": "the offline contract changed", "nextEvidence": "abort and inspect dependencies"}], "proves": "initialization behavior for this module and CLI run", "doesNotProve": "backend, registry or cloud access safety elsewhere", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0038-CMD-005", "question": "Is the configuration structurally and semantically valid for this CLI?", "risk": "read-only", "command": "terraform validate", "runFrom": "the initialized disposable lab state", "expectedBranches": [{"when": "Success appears", "meaning": "the CLI accepts the module structure and references", "nextEvidence": "run tests"}, {"when": "the first diagnostic appears", "meaning": "the configuration contract is broken", "nextEvidence": "fix the earliest causal diagnostic"}], "proves": "selected CLI validation for the initialized module", "doesNotProve": "valid runtime inputs, provider permission or safe changes"},
    {"id": "LES-0038-CMD-006", "question": "Do plan-known invariants survive default and changed inputs?", "risk": "mutating-bounded", "command": "terraform test -no-color", "runFrom": "the initialized disposable lab state", "expectedBranches": [{"when": "two plan runs pass", "meaning": "the encoded known-value assertions hold", "nextEvidence": "create a saved plan"}, {"when": "an unknown-condition diagnostic appears", "meaning": "the assertion depends on an apply-time value", "nextEvidence": "assert an input, local or known instance key instead of applying"}], "proves": "native plan-test results for encoded cases", "doesNotProve": "apply behavior, provider API or complete requirements", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0038-CMD-007", "question": "What exact actions does the valid changed input propose?", "risk": "mutating-bounded", "command": "terraform plan -input=false -lock=false -refresh=false -var-file=valid.tfvars -out=review.tfplan -no-color", "runFrom": "the initialized provider-free disposable state", "expectedBranches": [{"when": "three creates and zero changes or deletes appear", "meaning": "the built-in fixture proposal matches the reviewed case", "nextEvidence": "inspect JSON by address and unknown values"}, {"when": "counts or identities differ", "meaning": "source, variables, CLI or prior artifacts differ", "nextEvidence": "stop and compare exact inputs"}], "proves": "a saved plan proposal for exact local inputs", "doesNotProve": "authorization, apply success or production outcome", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0038-CMD-008", "question": "Which plan fields are known, sensitive or unknown?", "risk": "read-only", "command": "terraform show -json review.tfplan | python3 -m json.tool | sed -n '1,160p'", "runFrom": "the disposable state containing the saved plan", "expectedBranches": [{"when": "resource_changes and after_unknown appear", "meaning": "machine-readable consequence data is available", "nextEvidence": "map every address and action"}, {"when": "JSON decoding fails", "meaning": "artifact/product/version identity may be wrong", "nextEvidence": "preserve the artifact and verify its creator"}], "proves": "selected decoded fields from that artifact", "doesNotProve": "safe storage, policy completeness or future execution"},
    {"id": "LES-0038-CMD-009", "question": "Which references created ordering edges?", "risk": "read-only", "command": "terraform graph -type=plan -plan=review.tfplan | sed -n '1,120p'", "runFrom": "the disposable state containing the saved plan", "expectedBranches": [{"when": "service and catalog nodes with edges appear", "meaning": "the graph encodes reference-derived order", "nextEvidence": "explain each edge from source"}, {"when": "a cycle diagnostic appears", "meaning": "no complete traversal is possible", "nextEvidence": "remove circular ownership rather than forcing order"}], "proves": "the CLI's DOT graph for the saved plan", "doesNotProve": "runtime readiness or business dependency"},
    {"id": "LES-0038-CMD-010", "question": "Do invalid boundary values fail before any apply?", "risk": "read-only", "command": "terraform plan -input=false -lock=false -refresh=false -var-file=invalid.tfvars -no-color", "runFrom": "the initialized disposable state", "expectedBranches": [{"when": "environment and service validation diagnostics appear with nonzero exit", "meaning": "invalid values are rejected during planning", "nextEvidence": "keep the negative case as a regression"}, {"when": "a plan succeeds", "meaning": "the validation contract or variable source changed", "nextEvidence": "stop and inspect precedence and types"}], "proves": "negative-input rejection for encoded rules", "doesNotProve": "all unsafe values are rejected"},
    {"id": "LES-0038-CMD-011", "question": "Does OpenTofu produce the same reviewed semantics for this bounded case?", "risk": "mutating-bounded", "command": "tofu test -no-color; tofu plan -input=false -lock=false -refresh=false -var-file=valid.tfvars -out=review-tofu.tfplan -no-color", "runFrom": "a separate disposable copy initialized by the checksum-verified OpenTofu CLI", "expectedBranches": [{"when": "two tests pass and three creates appear", "meaning": "this narrow case has semantic parity", "nextEvidence": "compare JSON addresses, actions and unknowns"}, {"when": "syntax, test or plan differs", "meaning": "product/version compatibility is disproved for this case", "nextEvidence": "retain both outputs and consult versioned documentation"}], "proves": "bounded behavior for two exact product versions", "doesNotProve": "general state, provider, module or migration compatibility", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0038-CMD-012", "question": "Does the guarded lifecycle pass and remove every lesson artifact?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "the LES-0038 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "the checked lifecycle and cleanup passed", "nextEvidence": "retain the product/version/digest proof boundary"}, {"when": "the first assertion or cleanup fails", "meaning": "the lifecycle is not accepted", "nextEvidence": "preserve state and inspect the first failure"}], "proves": "the checked wrapper behavior on that host and run", "doesNotProve": "cloud/provider behavior, safe apply or learner mastery", "cleanup": "the verifier must prove exact absence"}
  ],
  "labs": [
    {"id": "LES-0038-LAB-001", "title": "Guided provider-free language, tests, graph and saved-plan inspection", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash, Python 3 and a separately checksum-verified Terraform or OpenTofu CLI", "timeMinutes": 210, "privilege": "normal user; wrapper refuses UID 0", "network": "none after separately authorized tool acquisition; no provider, module, backend or checkpoint access", "changes": ["one exact UID-scoped temporary directory", "local initialization metadata", "one saved plan plus JSON and DOT views"], "abortConditions": ["root", "unverified CLI", "unexpected download", "provider requirement", "backend request", "credential", "apply command", "ambiguous state or symlink"], "recovery": "Preserve the first diagnostic and only clean state that passes ownership and manifest validation.", "cleanupProof": "Validate exact path, UID, sentinel, CLI binding and allowed entries; remove only the lesson directory and prove absence.", "path": "drafts/LES-0038-terraform-opentofu-language-plan/support/lab"},
    {"id": "LES-0038-LAB-002", "title": "Independent typed-module and plan-review transfer", "mode": "independent", "environment": "Reviewer-held unfamiliar provider-free configuration with different collection shapes, instance identities, unknowns and negative cases", "timeMinutes": 240, "privilege": "normal user; no provider credentials or apply authority", "network": "none", "changes": ["one reviewer-owned disposable module copy", "format, test, plan, JSON and graph evidence only"], "abortConditions": ["lesson answer access", "real provider", "remote backend", "credentials", "apply", "unstable unexplained identity", "missing cleanup proof"], "recovery": "Return to the last known configuration and compare value knowledge, addresses, edges and actions before retry.", "cleanupProof": "Reviewer manifest proves plan, metadata and working directory absent without touching unrelated files.", "path": "drafts/LES-0038-terraform-opentofu-language-plan/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0038-INC-001", "signal": "Reordering a list changes many count-indexed resource addresses.", "firstThought": "Positional identity shifted even though business objects may be the same.", "safePath": "Stop, map indices to remote IDs, redesign with stable for_each keys or reviewed moved declarations, and require a replacement-free plan.", "trap": "Approve because only list order changed."},
    {"id": "LES-0038-INC-002", "signal": "A native plan test cannot evaluate an output assertion.", "firstThought": "The assertion depends on a value unknown until apply, not necessarily a product defect.", "safePath": "Inspect value provenance and after_unknown; assert plan-known inputs, locals or keys, or use a separately authorized apply test in a disposable environment.", "trap": "Change the test to apply against a real environment."},
    {"id": "LES-0038-INC-003", "signal": "A plan shows no explicit dependency between two files written in a desired order.", "firstThought": "File order is irrelevant; only references and explicit edges govern graph order.", "safePath": "Trace data references, add a real missing dependency only when an ordering relationship exists, and verify the graph.", "trap": "Rename files with numeric prefixes."},
    {"id": "LES-0038-INC-004", "signal": "Policy reads action counts but misses a dangerous unknown privilege value.", "firstThought": "Aggregate counts discarded address, value and after-unknown evidence.", "safePath": "Inspect machine-readable changes by address and sensitive/unknown map; fail closed or require accountable review for high-consequence unknowns.", "trap": "Approve because there are zero deletes."},
    {"id": "LES-0038-INC-005", "signal": "Terraform accepts a module that OpenTofu rejects after an upgrade.", "firstThought": "Shared ancestry is not a compatibility guarantee; language or test behavior diverged by version.", "safePath": "Pin both versions, preserve minimal reproduction and docs, compare provider/module constraints and choose an explicit supported product boundary.", "trap": "Rename the binary and assume identical state and plan behavior."}
  ],
  "assessmentIds": ["ASM-0097", "ASM-0098", "ASM-0099"],
  "referenceIds": ["REF-0319", "REF-0320", "REF-0324", "REF-0325", "REF-0327", "REF-0330", "REF-0334", "REF-0335", "REF-0336", "REF-0337", "REF-0338", "REF-0339", "REF-0340", "REF-0341", "REF-0342"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "The provider-free terraform_data fixture exercises language and plan mechanics, not cloud or infrastructure behavior.",
    "No apply occurs, so computed outputs, state persistence, update, replacement and destroy behavior are not runtime-tested.",
    "The Windows dual-CLI run validates exact versions only; the declared Ubuntu wrapper lifecycle remains blocked by WSL startup failure.",
    "Archive checksums matched manifests downloaded over HTTPS, but signatures and the complete distribution trust chain were not independently verified.",
    "Terraform and OpenTofu compatibility must be re-established for every chosen version, provider, module, backend and state migration.",
    "No formal technical, security, instructional or accessibility review and no learner transfer evidence exists."
  ]
}
---

# Terraform and OpenTofu language: read the graph before the plan changes anything

## What you see and first thought

You open a directory and see `main.tf`, `variables.tf`, `outputs.tf`, perhaps a `.terraform.lock.hcl`, and a pull request that says “add two instances.” The beginner reads top to bottom and imagines a script. The operator asks a different set of questions:

- Which CLI product and exact version will evaluate this module?
- Where do values come from, and which precedence rule won?
- Which resource instance addresses exist after `count` or `for_each` expansion?
- Which references create dependency edges?
- What is known during planning, and what remains unknown until execution?
- Which plan artifact was reviewed, and can it contain sensitive material?
- Is any command allowed to apply, or is this exercise plan-only?

The lasting model is:

~~~text
HCL text is not an ordered shell script.
It is input to an evaluator that builds typed values, instances and a graph.
The plan is a proposal produced from that graph and its other exact inputs.
~~~

In this lesson, the fixture creates no infrastructure. `terraform_data` belongs to a built-in provider, so initialization needs no external provider package. Both tested CLIs proposed three local logical creates, wrote a saved plan, exposed JSON and DOT views, and rejected deliberately invalid variables. Neither CLI applied. Therefore no state file or remote object existed.

That narrow boundary matters. A successful `validate` means the selected CLI accepts the module. A passing plan test means encoded assertions held for selected inputs. A saved plan means the engine calculated proposed actions. None means “production is safe.”

When a plan surprises you, do not start with `apply` or `depends_on`. Start with identity and data flow: product/version, module root, variable source, instance address, reference edge, before/after value, unknown marker, and state/target boundary. The plan usually becomes understandable once those are explicit.

## Terms before commands

**HCL** is the configuration syntax family used by Terraform and OpenTofu. In a `.tf` file, a **block** has a type and labels; an **argument** assigns an expression to a name.

~~~hcl
resource "terraform_data" "service" {
  for_each = local.normalized_services
  input    = each.value
}
~~~

`resource` is the block type. `terraform_data` and `service` are labels. `for_each` and `input` are arguments. `local.normalized_services` and `each.value` are expressions.

A **module** is one directory of configuration evaluated together. Splitting it into `main.tf`, `variables.tf`, and `outputs.tf` helps humans; filenames do not impose execution order.

A **value** has a type. Primitive types are string, number and bool. Collection and structural types include list, set, map, tuple and object. A list is ordered; a set is unique and unordered; a tuple can contain fixed positions of different types; an object has named attributes. Conversions can happen, but relying on surprising implicit conversion makes interfaces fragile.

An **input variable** is a module parameter. A **local value** names an internal expression. An **output** exposes a module result. A **data source** reads an external object through a provider. A **resource** declares managed lifecycle intent.

A **provider** translates resource and data-source operations into an external API or local mechanism. Its schema determines which arguments are required, optional, computed, sensitive or replacement-causing. The `terraform_data` fixture is built in; that convenience is not representative of a cloud provider.

A **resource address** names one configuration instance, such as `terraform_data.service["api"]`. It is an ownership identity, not merely display text.

`count` creates numeric instances such as `[0]`. `for_each` creates keyed instances such as `["api"]`. Stable business keys usually survive reordering better than indices.

A **known value** can be evaluated during planning. An **unknown value** is typed but cannot be calculated until an action returns data. **Sensitive** controls presentation; it does not necessarily remove the value from plan or state storage.

**Plan**, **test**, **policy**, **approval** and **apply** are different gates. Never collapse them into “Terraform passed.”

## Architecture map

The evaluator treats all `.tf` files in one root module as a single configuration:

~~~text
source revision + CLI/version + variables + dependency selections
                              |
                              v
                    parse blocks/expressions
                              |
                              v
              evaluate types, locals and instances
                              |
                              v
             construct graph from references and edges
                              |
              +---------------+----------------+
              |                                |
        prior state                     provider refresh
              |                                |
              +---------------+----------------+
                              v
                   proposed plan artifact
                              |
                    policy / human review
                              |
                  separately authorized apply
                              |
             state + remote + user verification
~~~

The lab intentionally removes the state and remote branches. With no prior state, no backend, no external provider, and `-refresh=false`, it isolates configuration evaluation and planning.

The fixture's data flow is:

~~~text
var.environment -----+
                     +--> local.normalized_services --> service["api"] --+
var.services --------+                             \--> service["worker"]-+--> catalog --> output
~~~

The catalog references `terraform_data.service`, so the evaluator adds edges from both service instances to the catalog. The output references catalog attributes, adding another dependency. Moving the catalog block earlier in the file changes no edge.

There are four important trust boundaries:

1. **Source boundary:** who can modify configuration, tests and dependency constraints?
2. **Interpreter boundary:** which Terraform or OpenTofu binary, provider packages and modules execute?
3. **Target boundary:** which backend, workspace, account, region and identity can be read or changed?
4. **Decision boundary:** who may approve and apply which exact plan?

The lesson proves only a small source/interpreter case. A production architecture must make all four observable and least privileged.

## Request or state path

Follow one value: `services.api.port`.

1. `valid.tfvars` assigns the number `8080` to the `port` attribute of key `api`.
2. The variable type requires a map whose values are objects containing `port`, `replicas`, and `labels`.
3. Variable validation requires an unprivileged port from 1024 through 65535.
4. A `for` expression constructs `local.normalized_services`, adding an identity and sorting the label set into a stable list.
5. `for_each` expands one instance at address `terraform_data.service["api"]`.
6. `each.value` becomes the resource's `input`; therefore the port is known during planning.
7. The resource's `output` is computed by its lifecycle and remains unknown until apply, even though it will normally echo input.
8. `terraform_data.catalog` references the whole service resource map. That reference creates dependency edges.
9. `output.service_summary.ports.api` references `resource.output.port`, so it is also unknown during planning.

This explains the first test failure encountered while authoring the lab. The initial test asserted `output.service_summary.environment == "practice"` during a plan-only run. Terraform correctly refused: that output flowed through a computed resource output. The safe correction asserted `var.environment`, `local.total_replicas`, and the known set of resource instance keys. We did not change the test to apply.

The lesson is broader than this fixture. In a cloud resource, an ID, assigned address or provider default may be unknown. Policy must either reason from known inputs, defer an assertion, use mocks deliberately, or fail closed for high-consequence unknowns. Treating unknown as empty or harmless is a production defect.

## Failure zoom

### Failure: list reordering creates replacement noise

With `count`, address `[0]` means position zero, not “the API.” Insert a new item at the start and every later position can describe a different business object. State still binds old indices to remote IDs, so the plan may update or replace multiple objects. Stable `for_each` keys make identity explicit. They do not solve everything: renaming a key is still an address change requiring a reviewed move.

### Failure: validation passes but runtime input fails

`terraform validate` checks configuration independent of a specific full runtime input set. Variable validation tied to a `.tfvars` value is normally evaluated during plan. Therefore `validate` can pass while `plan -var-file=invalid.tfvars` fails. That is correct layering, not contradiction.

### Failure: output is unknown in a plan test

Unknown means the engine cannot produce the value before an action. It does not mean null, empty or secret. A test that needs an apply-time property must run in a truly disposable authorized environment or use an honest mock/override. Do not apply merely to make a test green.

### Failure: explicit dependency hides a missing contract

`depends_on` can order nodes but does not pass data or prove readiness. If service configuration needs a database endpoint, reference the endpoint; that supplies both data and an edge. An explicit edge is appropriate for a real side-effect relationship not represented by data, but broad module-level edges often make more values unknown and reduce concurrency.

### Failure: two products are assumed interchangeable

Terraform and OpenTofu share language ancestry, but releases, features, registries, provider selection, state encryption, tests and operational details evolve separately. Passing the same provider-free fixture on Terraform 1.15.8 and OpenTofu 1.12.1 proves only that fixture's observed semantics.

## Internals and state ownership

Parsing converts source into configuration structures. Expression evaluation produces typed values and reference traversals. Meta-arguments then expand blocks into instances. Graph construction attaches provider configuration, dependencies, current state and proposed changes to nodes.

Consider these identities:

| Syntax | Instance identity | Operational consequence |
|---|---|---|
| `count = 2` | `[0]`, `[1]` | position is identity; insertion/reorder can remap objects |
| `for_each = toset(["api", "worker"])` | `["api"]`, `["worker"]` | values become stable keys, but set elements must be plan-known |
| `for_each = var.services` | map keys | key is lifecycle identity; attribute changes stay within an instance |
| module `for_each` | `module.name["key"]` | every contained address inherits module instance identity |

Providers expose schemas. An argument can be required, optional, computed, sensitive, force replacement, or a nested collection. The plan is therefore not calculated from HCL alone; provider schema and logic matter. Pinning only the CLI while allowing provider drift does not produce repeatability.

The dependency lock file records selected provider packages and checksums, not every remote module selection. Version constraints describe acceptable ranges; the lock records a selection. Review both. A checksum match says bytes equal the recorded digest; it does not by itself prove who produced the first trusted digest.

State ownership begins once apply binds an address to an object. This lesson never crosses that boundary. A saved plan still contains configuration and proposed value data and should be treated as sensitive. It is also product/version coupled: use the creating CLI to inspect and apply it, and replan if relevant inputs change.

## Evidence table

| Evidence | It supports | It does not establish |
|---|---|---|
| CLI `version -json` | self-reported product/version/platform | trusted archive or untampered binary |
| archive SHA-256 equals official manifest line | downloaded archive bytes match the manifest | signature identity or secure first trust |
| `fmt -check` exit 0 | canonical formatting for recognized files | semantic validity |
| backend-disabled `init` reports built-in provider | no external provider was needed in that run | general offline behavior |
| `validate` success | module accepted by selected initialized CLI | valid tfvars or safe plan |
| two plan-only tests pass | encoded known-value invariants hold | computed output or apply behavior |
| invalid tfvars return nonzero | those validation rules reject that case | complete input safety |
| saved plan says 3 add, 0 change, 0 destroy | proposed actions for exact inputs | authorization or successful execution |
| JSON has three create action arrays | machine-readable action classification | harmless changes or secret-free artifact |
| `after_unknown` marks output fields | those values are not known during plan | that unknown values are safe |
| graph contains service-to-catalog edges | evaluator derived ordering for that plan | application readiness |
| no `terraform.tfstate` after plan-only workflow | no local state file was created there | no remote effect from other tools or paths |

Good evidence names time, path, product, version and input. “The plan is green” is not evidence because color and totals discard identity and consequence.

## Command decoders

`terraform fmt -check -diff -recursive`

- `fmt` invokes the canonical formatter.
- `-check` refuses to rewrite and returns nonzero when changes are needed.
- `-diff` shows the proposed formatting difference.
- `-recursive` includes child module directories.

`terraform init -backend=false -input=false`

- `init` prepares the working directory and dependencies.
- `-backend=false` skips backend configuration; it does not globally disable every network path.
- `-input=false` forbids interactive questions, appropriate for automation.
- `CHECKPOINT_DISABLE=1` disables Terraform checkpoint/version checks; provider installation still needs its own controlled mirror and lock strategy when providers exist.

`terraform plan -input=false -lock=false -refresh=false -var-file=valid.tfvars -out=review.tfplan`

- `-lock=false` is acceptable only because this lesson has no state. It is dangerous as a generic production habit.
- `-refresh=false` removes remote observation only because there is no remote provider. In production it can hide drift.
- `-var-file` names one explicit input source. Environment variables, auto files and command-line variables have precedence rules that must be inventoried.
- `-out` writes an opaque saved plan for exact review. Protect it like state.

`terraform show -json review.tfplan`

Machine-readable output is for structured consumers. Read `resource_changes[].address`, `change.actions`, `before`, `after`, `after_unknown`, and sensitive markings. Pin the JSON format version expectations in automation and fail closed on unsupported versions.

`terraform graph -type=plan -plan=review.tfplan`

DOT output reveals evaluator edges. It can be large. Use it to explain a suspicious dependency, not as decorative proof that architecture is correct.

## Decision path

Use this path for every module change:

1. **Bound the interpreter.** Record Terraform or OpenTofu, exact version, platform, binary digest and trust source.
2. **Bound the module.** Record repository revision, root directory, files, module sources and dependency locks.
3. **Bound inputs.** List variable sources and precedence, types, validations, sensitive values and unknowns.
4. **Expand identity.** Write every affected module/resource address. Challenge positional `count` and key renames.
5. **Trace values.** Follow high-consequence network, identity, encryption, data and capacity values through variables, locals, expressions and provider arguments.
6. **Trace graph edges.** Prefer references that carry real data. Justify each explicit dependency.
7. **Run narrow gates.** Format, initialize under controlled dependency rules, validate and test positive plus negative cases.
8. **Create a complete plan.** Avoid targets and stale observations in normal review. Bind the artifact to source, inputs, state and target.
9. **Inspect consequences.** Review every action, replacement, deletion, unknown, sensitive field and downstream effect.
10. **Compare policy and human judgment.** Policy handles repeatable constraints; accountable reviewers handle context and exceptions.
11. **Apply only with separate authority.** The plan-only lesson grants none.
12. **Verify if applied.** Reconcile state, remote objects, users, data, security, capacity, cost and a fresh full plan.

If any identity is ambiguous, stop. More flags do not repair a missing boundary.

## Guided Ubuntu lab

The lab objective is not “deploy something.” It is to explain how exact source becomes typed instances, graph edges, known and unknown values, tests, and a saved proposal.

### Prerequisites and safety

- Ubuntu 24.04, normal user, Bash, Python 3 and standard GNU tools.
- A separately acquired, checksum-verified Terraform or OpenTofu binary whose exact version is approved for the exercise.
- No credentials in the shell and no provider or remote backend configuration.
- Work only through the guarded wrapper once it is present and validated.
- Abort on a download request, provider requirement, backend prompt, credential lookup or any `apply` command.

The checked-in configuration contains only the built-in `terraform_data` resource. Read it before execution. Predict two service instance addresses, one catalog address, and service-to-catalog edges.

### What each file teaches

`main.tf` defines typed variables and validations. A `for` expression normalizes services. `for_each` converts map keys into stable instance addresses. The catalog references the resource map, making its dependency implicit. Outputs deliberately pass through computed resource outputs, so they demonstrate unknown values.

`tests/language.tftest.hcl` has two plan-only runs. It asserts variable values, locals, and instance keys that are known during planning. It deliberately does not assert `terraform_data.output`, because no apply is authorized.

`valid.tfvars` changes replicas and labels while preserving keys. `invalid.tfvars` violates environment, port, replica and label rules. A good lab includes both a success path and a meaningful refusal.

### Workflow

~~~bash
bash lab.sh doctor terraform
bash lab.sh setup terraform
bash lab.sh run fmt
bash lab.sh run init
bash lab.sh run validate
bash lab.sh run test
bash lab.sh run plan
bash lab.sh run inspect
bash lab.sh run graph
bash lab.sh run negative
bash verify.sh terraform
~~~

Repeat in a separate clean state with `tofu`. Never reuse one product's opaque plan artifact with the other.

Expected semantic results:

- canonical formatting;
- built-in provider initialization and no external provider lock entry;
- valid configuration;
- two passing plan runs;
- three create proposals, zero update and zero delete;
- resource addresses for `service["api"]`, `service["worker"]`, and `catalog`;
- known input objects but unknown computed outputs;
- both invalid-variable messages and a nonzero negative-plan exit;
- no state file;
- exact cleanup and absence.

If the wrapper is unavailable, do not improvise commands against another repository or environment. The Windows mentor validation recorded the same narrow workflow with Terraform 1.15.8 and OpenTofu 1.12.1 in separate disposable directories; Ubuntu lifecycle evidence remains a separate gate.

## Production transfer

The fixture removes providers, state and apply so you can see the language. Production adds all of them.

Before accepting a real module, construct an interface sheet:

| Boundary | Questions |
|---|---|
| CLI | Which product/version/platform? How was it obtained and pinned? |
| module | Which source revision and root? What versions are supported? |
| provider | Which source, version, checksum, aliases and credentials? |
| variables | Which sources and precedence? Which validations and sensitive values? |
| identity | Which addresses exist? Are keys stable across releases? |
| graph | Which edges are implicit or explicit? What can run concurrently? |
| state | Which backend/workspace/lineage/lock? Who can read or write? |
| target | Which tenant/account/region/project and principal? |
| plan | Which digest, state serial and actions? What is unknown? |
| decision | Which policy, exception, reviewer and approval? |
| verification | Which user, data, security, capacity and cost signals? |

Choose variable types as API contracts. `any` moves errors later. A giant untyped map hides interface changes. Overly rigid objects make evolution difficult. Use optional attributes deliberately, document null semantics, and test old plus new callers.

Choose identity before attributes. If a fleet is keyed by immutable service ID, use that ID as `for_each` key and keep mutable display names inside values. Do not include mutable attributes in keys merely to make them unique.

Keep modules cohesive. A module should own one lifecycle and blast-radius boundary. A module that manages network, database, identities, application and dashboards couples permissions, state locking and releases. But thousands of tiny modules create version and dependency overhead. Split by ownership and change consequence, not arbitrary resource count.

## Reliability, security, observability, capacity, and cost

**Reliability:** A correct graph avoids racing dependencies, but graph completion is not service readiness. Provider “created” can precede application health. Define post-apply checks. Protect state locking and recovery. Use stable addresses, complete plans and controlled concurrency. Treat partial apply as normal failure semantics.

**Security:** Configuration, providers and modules are executable supply-chain inputs. Protect source, pin versions, review lock changes and use controlled mirrors. Runners need ephemeral, short-lived, least-privilege identity. State and plans can contain secrets. Separate plan and apply authority where consequence justifies it. Never print environment variables or raw state into logs.

**Observability:** Record run ID, source digest, CLI/provider/module versions, target identity, state serial, plan digest, action inventory, policy outcome, approver, duration, first error, partial results and verification. Metrics without identity are misleading. Redact values while retaining address and decision context.

**Capacity and performance:** Large graphs consume memory and provider/API concurrency. High `-parallelism` can trigger throttling; low parallelism can stretch maintenance windows. State size, refresh volume and lock duration matter. Split boundaries only after measuring ownership and contention. Targeted plans are incident tools, not routine performance shortcuts.

**Cost:** A create count is not a price. Unknown sizes, transfer, requests, licenses, retention and discounts matter. Estimate before approval, set budgets and detect post-apply cost drift. Also count engineering cost: module maintenance, upgrades, policy, test time and recovery complexity.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| Read files as scripts | file order does not define execution | trace references and graph edges |
| Use `count` for named objects | position becomes identity | prefer stable `for_each` keys |
| Rename a key casually | address ownership changes | reviewed moved/refactor declaration |
| Treat `validate` as a plan | no full runtime input or action calculation | run positive/negative tests and plan |
| Test computed outputs in plan mode | value is unknown until apply | assert plan-known values or authorized disposable apply |
| Add `depends_on` everywhere | hides contracts and reduces parallelism | carry real data references; add only real side-effect edges |
| Use `-target` routinely | produces an intentionally incomplete graph | full plan by default; targeted incident use followed by full reconciliation |
| Use `-refresh=false` in production review | can hide drift | refresh fully unless an explicit incident decision says otherwise |
| Commit a saved plan | may expose sensitive values and becomes stale | protected short-lived artifact storage |
| Trust redaction as encryption | sensitive marks affect display | encrypt and restrict state/plan storage |
| Assume Terraform equals OpenTofu | products evolve independently | pin and test both exact stacks |
| Apply to see whether a test passes | turns uncertainty into side effects | stop at plan or use an authorized disposable environment |

The prevention habit is simple: name the address, edge, value knowledge state and evidence gate before choosing a command.

## Memory card and retrieval

Remember **B-V-I-G-P**:

~~~text
B - Blocks describe constructs; files do not sequence them.
V - Values are typed, sourced, known, sensitive or unknown.
I - Instances have addresses; keys are lifecycle identity.
G - Graph edges come from references or justified explicit dependencies.
P - Plan is a proposal, not permission or proof of outcome.
~~~

Retrieval prompts:

1. Why does moving a block between files not change order?
2. What is the operational difference between list, set and map?
3. Why can a resource input be known while its output is unknown?
4. How does `for_each` affect state identity?
5. What does `validate` prove that `plan` does not, and vice versa?
6. Why is a saved plan sensitive and short lived?
7. When is `depends_on` justified?
8. What did the dual-CLI lab prove—and what did it not prove?

Answer without looking, then draw the value-to-instance-to-graph path for a different object.

## Complete answers

1. A root module is evaluated as one configuration. Order comes from expression references and explicit dependency edges, not filename or block position.

2. A list is ordered and duplicate-permitting; a set is unique and unordered; a map uses explicit string keys. When collections drive instances, indices or keys become identity. Choose a structure that matches stable ownership, not merely convenient input syntax.

3. Configuration can supply `input` completely during planning. A resource's `output` is computed by its lifecycle and therefore may be unknown until execution. Any downstream expression inherits the unknown.

4. `for_each` expands one block into addresses keyed by map/set keys. Attribute changes under an existing key usually update that instance. Removing or renaming a key removes one address and adds another unless a supported move preserves ownership.

5. `validate` checks internal configuration validity for an initialized module. `plan` evaluates concrete inputs, prior state and provider observations to propose actions. Neither grants authorization or proves the result.

6. A plan can contain configuration, state-derived data, sensitive provider values and intended changes. It is coupled to exact inputs and becomes stale when they change. Store it encrypted with restricted access, short retention and a digest-bound approval.

7. Use `depends_on` for a real ordering relationship not expressed by consumed data—for example, a policy must exist before an operation though no attribute is referenced. Prefer data references; broad explicit edges increase unknowns and reduce parallelism.

8. Exact Terraform 1.15.8 and OpenTofu 1.12.1 binaries, whose archive hashes matched downloaded official manifests, both formatted, initialized with a built-in provider, validated, passed two plan tests, proposed the same three logical creates, exposed JSON/DOT views and rejected invalid inputs. It did not verify signatures, Ubuntu wrapper behavior, external providers, backends, state, apply, remote resources, general compatibility or production safety.

## Product-company interview

**Explain how Terraform decides order.**

It builds a directed graph. References create implicit edges; explicit `depends_on` adds edges where a real relationship has no data reference. Nodes whose dependencies are complete can run concurrently. File order is irrelevant. I review cycles, broad module dependencies, replacement/destroy ordering and provider readiness separately from application readiness.

**`count` or `for_each`?**

I choose based on lifecycle identity. `count` is suitable for truly fungible positional instances. For named objects, stable `for_each` keys avoid remapping when collections reorder. Keys must be known during planning and should not contain mutable attributes or secrets. A key rename is still an ownership change.

**What is an unknown value?**

It is a typed value whose final content is unavailable during planning, often because a provider computes it during apply. It propagates through expressions. Policy and tests must distinguish unknown from null or empty and fail closed where consequence requires a known decision.

**How do you review machine-readable plan JSON?**

First bind format/product/version and artifact identity. Then inspect each address, action array, before/after, `after_unknown`, sensitivity metadata, replacement paths and proposed outputs. I never approve from totals alone, and I treat the artifact as sensitive.

**Can Terraform and OpenTofu share configuration and state?**

Some configurations share syntax and provider concepts, but compatibility is version-, feature-, provider-, backend- and state-format-specific. I pin both sides, read their migration guidance, test a disposable copy, back up state, prohibit concurrent writers and maintain an explicit product boundary. Shared ancestry is not a blanket guarantee.

Senior follow-ups: How would you evolve an object variable compatibly? When would a module-level `depends_on` be harmful? How would you test a replacement guard? How would you prevent a CI policy from treating unknown privilege as allowed? What evidence makes a saved-plan approval replay-safe?

## Independent transfer and rubric

Complete ASM-0099 on a reviewer-held provider-free module with different types, instance identities and unknown values. No model answer is available.

Required evidence:

- exact product/version/digest and trust limitation;
- module and variable-source boundary;
- type table and two negative validations;
- instance-address inventory with identity rationale;
- expression/value flow including known, sensitive and unknown;
- graph edges and explicit-dependency review;
- formatting, initialization, validation and plan-only tests;
- saved plan identity plus address/action/unknown review;
- Terraform/OpenTofu semantic comparison without cross-reading opaque plans;
- no provider, backend, credential, apply, state or network proof;
- exact cleanup and delayed reassessment.

Rubric, 100 points:

| Dimension | Points | Full-credit evidence |
|---|---:|---|
| Boundary and provenance | 10 | Exact CLI, digest, module, inputs and trust limits. |
| Type design | 10 | Precise types, null/default semantics and negative cases. |
| Instance identity | 10 | Addresses and stable-key trade-offs are correct. |
| Expression flow | 8 | Variables, locals, functions and transformations traced. |
| Knowledge state | 10 | Known, sensitive and unknown values classified correctly. |
| Graph reasoning | 10 | Every material edge and parallel branch explained. |
| Tests and validation | 10 | Layered positive and negative evidence with proof limits. |
| Plan review | 10 | Actions, values, unknowns and consequences reviewed by address. |
| Product comparison | 8 | Exact-version parity and differences handled honestly. |
| Safety and cleanup | 8 | No apply/credential/backend/provider; exact absence proven. |
| Communication | 6 | Decision, uncertainty and next evidence are concise and defensible. |

Passing one fixture does not establish production authority or mastery. Require a second unseen module after a delay.

## References and review

Reference records reuse REF-0319, REF-0320, REF-0324, REF-0325, REF-0327 and REF-0330 from the IaC foundation package and add REF-0334 through REF-0342 for resources, variables, locals, expressions, `for_each`, lifecycle, validation and OpenTofu language/testing.

Review after a material Terraform or OpenTofu language, testing, plan JSON, built-in provider or compatibility change. Review sooner after unstable instance identity, surprise replacement, dependency cycle, unknown-value policy bypass, plan leak, provider/module compromise or unsafe product migration.

Final review questions:

- Can every important value be traced to one source and precedence rule?
- Are types narrow enough to fail early but evolvable?
- Are instance keys stable business identities?
- Does every explicit dependency represent a real relationship?
- Are unknown and sensitive values handled deliberately?
- Do tests assert the correct phase without unauthorized apply?
- Is the saved plan bound to exact inputs and protected?
- Are Terraform/OpenTofu claims tied to exact versions and evidence?
- Is target/apply authority absent from this lesson and explicit in production?
- Does cleanup prove only lesson-owned artifacts are gone?

Scheduled review date: 2027-02-04.
