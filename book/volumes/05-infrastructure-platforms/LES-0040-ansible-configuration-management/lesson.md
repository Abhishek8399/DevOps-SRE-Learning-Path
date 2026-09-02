---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0040",
  "slug": "ansible-configuration-management",
  "aliases": ["V05-L04", "ansible-configuration-management"],
  "curriculumIds": ["CFG-001"],
  "route": "/book/infrastructure/ansible-configuration-management",
  "order": 4,
  "volume": "05-infrastructure-platforms",
  "title": "Ansible configuration management: make change predictable, convergent, and reviewable",
  "summary": "Build a precise mental model of inventory, playbooks, roles, variables, handlers, check mode, idempotence, rolling execution, failure containment, secrets, testing, drift repair, and production-safe configuration change.",
  "domain": "infrastructure",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0009", "LES-0011", "LES-0017", "LES-0039"],
  "prerequisiteCurriculumIds": ["LNX-004", "AUT-001", "SCM-001", "TFM-002"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The learner lifecycle targets a normal Ubuntu user with ansible-core, Bash and Python 3. WSL startup is currently blocked by host error 0x80070569, so runtime claims are intentionally withheld."},
    {"platform": "Windows", "version": "11", "support": "unsupported", "notes": "Windows may host the repository and browser, but the bounded lesson controller is Ubuntu. Native Windows is not claimed as an Ansible controller environment."},
    {"platform": "Docker Desktop", "version": "29.6.2 client observed", "support": "unsupported", "notes": "The Linux engine was unavailable during authoring. This lesson does not require a container and makes no container-runtime claim."},
    {"platform": "Cloud infrastructure", "version": "not used", "support": "unsupported", "notes": "No cloud account, credential, managed service, remote inventory, or billable object is used."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead"],
  "learningObjectives": [
    "Explain Ansible controller, inventory, host pattern, play, task, module, plugin, role, collection and managed-node boundaries.",
    "Trace one change through variable resolution, connection, module execution, handler notification and independent verification.",
    "Write deterministic, idempotent tasks that model desired state instead of hiding imperative scripts.",
    "Predict variable precedence deliberately and reject ambiguous configuration ownership.",
    "Use check mode and diff mode as bounded prediction evidence without confusing them with execution proof.",
    "Design handlers, failure semantics and rolling batches so failed change is contained and recoverable.",
    "Separate control-plane secrets from ordinary variables and prevent plaintext exposure.",
    "Test syntax, inventory, static policy, convergence, drift detection, repair and cleanup.",
    "Diagnose unreachable, failed, changed, skipped and rescued outcomes from causal evidence.",
    "Transfer the model to dynamic inventory, privilege escalation, heterogeneous fleets, CI and large rollouts."
  ],
  "productionSignals": [
    "controller identity, ansible-core version, Python interpreter and configuration file",
    "repository revision, playbook path, role or collection version and dependency lock",
    "inventory source, inventory plugin, host pattern, resolved host set and limit expression",
    "host identity, connection plugin, remote user, interpreter discovery result and become identity",
    "variable name, winning source, precedence class, value provenance and sensitivity",
    "play serial, strategy, forks, throttle, order, batch membership and rollout wave",
    "task name, module FQCN, arguments with secrets redacted, result state and duration",
    "changed, failed, unreachable, skipped, rescued and ignored counts per host",
    "handler notification topic, deduplicated listener, flush point and restart outcome",
    "check-mode prediction, diff redaction, apply result, second-run change count and drift-repair result",
    "application health, dependency health, user journey, error budget and rollback trigger",
    "cleanup manifest, residual files, temporary secret lifetime and audit record"
  ],
  "diagrams": [
    {"id": "LES-0040-DIA-001", "title": "Ansible control path", "direction": "left-to-right", "boundaries": ["operator or CI", "controller", "inventory and variables", "connection plugin", "managed node", "module result", "verification"], "evidencePoints": ["revision", "host set", "user", "module", "result", "health"], "textAlternative": "An operator starts an immutable repository revision on a controller. Inventory resolves targets and variables, a connection plugin reaches each node, modules enforce desired state, results return, and independent health checks verify the service."},
    {"id": "LES-0040-DIA-002", "title": "Compilation from intent to task graph", "direction": "top-to-bottom", "boundaries": ["configuration discovery", "inventory parse", "play selection", "variable merge", "role expansion", "task graph", "execution batches"], "evidencePoints": ["config", "source", "pattern", "winner", "task", "serial"], "textAlternative": "Before changing a host, Ansible discovers configuration, parses inventory, chooses plays, merges variables, expands roles and includes, then schedules the resulting task graph into batches."},
    {"id": "LES-0040-DIA-003", "title": "Convergence loop", "direction": "cyclic", "boundaries": ["desired state", "observe current state", "compare", "change if different", "report", "re-observe"], "evidencePoints": ["before", "after", "changed", "second run"], "textAlternative": "An idempotent module observes current state, compares it with desired state, changes only a difference, reports honestly, and produces zero changes when immediately repeated without external drift."},
    {"id": "LES-0040-DIA-004", "title": "Variable ownership ladder", "direction": "hierarchical", "boundaries": ["role defaults", "inventory variables", "play variables", "role parameters", "task variables", "extra variables"], "evidencePoints": ["name", "source", "precedence", "winner", "owner"], "textAlternative": "Several variable sources can define one name; higher-precedence sources override lower ones, but maintainable design minimizes collisions and records which layer is authorized to own each decision."},
    {"id": "LES-0040-DIA-005", "title": "Rolling failure containment", "direction": "left-to-right", "boundaries": ["load balancer", "batch one", "health gate", "batch two", "abort threshold", "rollback"], "evidencePoints": ["serial", "failed hosts", "health", "error rate", "abort"], "textAlternative": "A rollout removes a small batch from service, changes and verifies it, returns healthy nodes, and advances only while host and user-facing health stay inside explicit thresholds."},
    {"id": "LES-0040-DIA-006", "title": "Secret exposure surfaces", "direction": "hierarchical", "boundaries": ["secret source", "controller memory", "temporary file", "transport", "managed process", "logs and artifacts"], "evidencePoints": ["identity", "encryption", "permission", "redaction", "lifetime"], "textAlternative": "Vault encryption protects a secret at rest in the repository, but its decrypted value still crosses controller memory, transport and possibly a managed file or process; every surface needs least privilege, redaction and bounded lifetime."}
  ],
  "commands": [
    {"id": "LES-0040-CMD-001", "question": "Am I a normal Ubuntu user inside the approved lesson boundary?", "risk": "read-only", "command": "bash lab.sh doctor", "runFrom": "the LES-0040 support/lab directory on Ubuntu 24.04", "expectedBranches": [{"when": "doctor=pass and uid is nonzero", "meaning": "controller boundary and tools are present", "nextEvidence": "inspect exact Ansible identity"}, {"when": "root, missing tool or wrong platform appears", "meaning": "lab boundary is invalid", "nextEvidence": "stop without creating state"}], "proves": "reported host, identity and executable availability", "doesNotProve": "Ansible correctness or production safety"},
    {"id": "LES-0040-CMD-002", "question": "Which Ansible binary, configuration and Python interpret this run?", "risk": "read-only", "command": "ansible-playbook --version; ansible-config dump --only-changed", "runFrom": "the guarded controller directory", "expectedBranches": [{"when": "expected executable, Python and local configuration appear", "meaning": "controller identity is inspectable", "nextEvidence": "resolve inventory"}, {"when": "unexpected config or executable appears", "meaning": "behavior may be controlled elsewhere", "nextEvidence": "stop and resolve discovery"}], "proves": "self-reported controller identity and changed settings", "doesNotProve": "binary provenance or remote interpreter identity"},
    {"id": "LES-0040-CMD-003", "question": "Which exact hosts and groups does the inventory produce?", "risk": "read-only", "command": "ansible-inventory -i fixtures/inventory.ini --graph; ansible-inventory -i fixtures/inventory.ini --host les0040-local", "runFrom": "the lesson lab directory", "expectedBranches": [{"when": "only les0040-local with local connection appears", "meaning": "bounded host set is correct", "nextEvidence": "inspect syntax and task graph"}, {"when": "another host, plugin or connection appears", "meaning": "target scope escaped", "nextEvidence": "abort before execution"}], "proves": "inventory output for exact sources", "doesNotProve": "reachability, authorization or safe variables"},
    {"id": "LES-0040-CMD-004", "question": "Can the playbook and referenced role be parsed?", "risk": "read-only", "command": "ansible-playbook -i fixtures/inventory.ini fixtures/playbook.yml --syntax-check", "runFrom": "the lesson lab directory", "expectedBranches": [{"when": "syntax check succeeds", "meaning": "YAML and Ansible structure parse", "nextEvidence": "list hosts and tasks"}, {"when": "parser, lookup or role error appears", "meaning": "execution graph cannot be built", "nextEvidence": "fix first causal error"}], "proves": "parser acceptance for available dependencies", "doesNotProve": "module behavior, idempotence or safe execution"},
    {"id": "LES-0040-CMD-005", "question": "What host set and task order will this play select?", "risk": "read-only", "command": "ansible-playbook -i fixtures/inventory.ini fixtures/playbook.yml --list-hosts --list-tasks", "runFrom": "the lesson lab directory", "expectedBranches": [{"when": "one local host and expected role tasks appear", "meaning": "selection matches fixture contract", "nextEvidence": "run prediction"}, {"when": "zero, many or unexpected tasks appear", "meaning": "pattern, include or tag behavior differs", "nextEvidence": "stop before mutation"}], "proves": "statically expanded selection visible to Ansible", "doesNotProve": "conditional runtime branches or changes"},
    {"id": "LES-0040-CMD-006", "question": "What would initial convergence change without changing it now?", "risk": "read-only", "command": "bash lab.sh check-initial", "runFrom": "the guarded fixture after setup", "expectedBranches": [{"when": "three managed files are predicted and the root remains sentinel-only", "meaning": "check mode predicted delta without applying it", "nextEvidence": "review diff then apply"}, {"when": "prediction fails or writes a managed file", "meaning": "check support or boundary failed", "nextEvidence": "stop and preserve output"}], "proves": "check prediction and non-mutation assertions for this fixture", "doesNotProve": "future apply success or general check fidelity"},
    {"id": "LES-0040-CMD-007", "question": "Can intended configuration converge once?", "risk": "mutating-bounded", "command": "bash lab.sh apply-initial", "runFrom": "the guarded normal-user lab", "expectedBranches": [{"when": "bounded files, modes and marker match with no failure", "meaning": "initial local convergence succeeded", "nextEvidence": "repeat unchanged"}, {"when": "unexpected path, task or recap appears", "meaning": "contract is violated", "nextEvidence": "freeze and inspect first failure"}], "proves": "bounded local-file convergence for exact fixture", "doesNotProve": "remote service safety or fleet rollout", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0040-CMD-008", "question": "Is the role actually idempotent after convergence?", "risk": "mutating-bounded", "command": "bash lab.sh apply-steady", "runFrom": "the already converged guarded lab", "expectedBranches": [{"when": "changed=0, failed=0 and unreachable=0", "meaning": "exact fixture reached a fixed point", "nextEvidence": "inject controlled drift"}, {"when": "changed is nonzero", "meaning": "a task keeps rewriting or reports inaccurately", "nextEvidence": "find first changing task"}], "proves": "second-run idempotence on one exact host and state", "doesNotProve": "all inputs or external systems are idempotent", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0040-CMD-009", "question": "Can prediction identify drift without repairing it?", "risk": "mutating-bounded", "command": "bash lab.sh inject-drift; bash lab.sh check-drift", "runFrom": "the converged disposable lab", "expectedBranches": [{"when": "check predicts correction and drift remains", "meaning": "desired/current difference is observable without repair", "nextEvidence": "approve bounded repair"}, {"when": "no change is predicted or drift disappears", "meaning": "ownership, check support or guard is wrong", "nextEvidence": "stop and inspect"}], "proves": "controlled drift detection and check non-mutation", "doesNotProve": "cause, production policy or service impact", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0040-CMD-010", "question": "Can the same role repair drift and reconverge?", "risk": "mutating-bounded", "command": "bash lab.sh repair", "runFrom": "the guarded drifted fixture", "expectedBranches": [{"when": "one bounded correction occurs and files verify", "meaning": "declared state repaired controlled drift", "nextEvidence": "run steady state again"}, {"when": "extra changes or failure appears", "meaning": "drift affected more than expected", "nextEvidence": "stop and compare manifests"}], "proves": "bounded repair for injected file drift", "doesNotProve": "automatic production repair is authorized", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0040-CMD-011", "question": "How would a production rollout bound each failure domain?", "risk": "read-only", "command": "ansible-playbook -i inventory/production.yml site.yml --limit 'payments:&canary' --check --diff", "runFrom": "an approved production-change review; illustrative only", "expectedBranches": [{"when": "canary set and redacted diff match approval", "meaning": "prediction is reviewable", "nextEvidence": "schedule serialized execution with health gates"}, {"when": "host set, secrets or diff are unexpected", "meaning": "scope or confidentiality is unsafe", "nextEvidence": "cancel before apply"}], "proves": "prediction from exact inventory and revision", "doesNotProve": "successful execution or healthy users"},
    {"id": "LES-0040-CMD-012", "question": "Does the local lifecycle fail closed and remove artifacts?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "the LES-0040 support/lab directory as a normal Ubuntu user", "expectedBranches": [{"when": "verification=pass and state_absent=true appear", "meaning": "static checks, convergence, drift, repair and cleanup passed", "nextEvidence": "retain exact version and boundary"}, {"when": "first assertion fails", "meaning": "candidate is not accepted", "nextEvidence": "preserve first causal artifact"}], "proves": "guarded lifecycle on that exact run", "doesNotProve": "production readiness, distributed rollout or mastery", "cleanup": "verifier proves exact absence"}
  ],
  "labs": [
    {"id": "LES-0040-LAB-001", "title": "Guided local convergence, drift and repair drill", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash, Python 3 and ansible-core", "timeMinutes": 240, "privilege": "normal user; wrapper refuses UID 0; no become", "network": "none; localhost connection and built-in modules only", "changes": ["one exact UID-scoped controller directory under /tmp", "one exact UID-scoped managed directory under /tmp", "deterministic configuration, payload and handler marker files"], "abortConditions": ["root", "non-Ubuntu controller", "network endpoint", "remote host", "external collection", "shell or command module", "become", "symlink", "wrong owner", "unexpected entry"], "recovery": "Stop at the first failing assertion, retain bounded controller evidence, and use cleanup only after manifest validation.", "cleanupProof": "Validate resolved paths, UID, sentinels, owners, allowed inventory and absence of symlinks; remove the two exact directories and prove absence.", "path": "book/labs/LES-0040-ansible-configuration-management"},
    {"id": "LES-0040-LAB-002", "title": "Independent canary configuration rollout transfer", "mode": "independent", "environment": "Reviewer-held unfamiliar local multi-host simulation with one unsafe override, one non-idempotent task and one failing health gate", "timeMinutes": 240, "privilege": "normal user; no become, SSH, credential or external target", "network": "none", "changes": ["reviewer-owned disposable inventory and roles", "host-selection proof, repaired task graph, convergence evidence, rollback decision and cleanup record"], "abortConditions": ["lesson answer access", "unbounded host pattern", "plaintext secret", "ignored failure", "changed_when false hiding mutation", "real remote host", "missing cleanup proof"], "recovery": "Contain the failing batch, distinguish task failure from health failure, restore prior desired state and reconverge.", "cleanupProof": "Reviewer manifest proves every simulated host root and controller artifact absent.", "path": "book/labs/LES-0040-ansible-configuration-management"}
  ],
  "incidents": [
    {"id": "LES-0040-INC-001", "signal": "A play succeeds on most hosts but some are unreachable.", "firstThought": "The controller could not establish or maintain the transport boundary; this is not a module-state failure.", "safePath": "Freeze expansion, inspect host set, DNS or address, plugin, identity, authentication and network path, then retry only proven targets.", "trap": "Treat unreachable as application failure or rerun the whole fleet blindly."},
    {"id": "LES-0040-INC-002", "signal": "Every steady run reports changed for the same task.", "firstThought": "The task does not reach a fixed point or its change reporting is dishonest.", "safePath": "Capture before and after evidence, inspect module semantics, unstable inputs, timestamps, ordering and custom changed_when logic, then repair the first perpetual writer.", "trap": "Set changed_when false to make the recap green."},
    {"id": "LES-0040-INC-003", "signal": "A template changes but the expected service restart never occurs.", "firstThought": "Notification or handler semantics are wrong, delayed, skipped by failure, mismatched by topic, or flushed at the wrong point.", "safePath": "Trace changed flag, notify topic, listener, play scope, failure path and flush point; verify service independently.", "trap": "Add an unconditional restart after every task."},
    {"id": "LES-0040-INC-004", "signal": "A variable is safe in one environment and dangerous in another.", "firstThought": "A higher-precedence source, duplicate ownership or inventory topology changed the winner.", "safePath": "Dump inventory and relevant variables with secrets redacted, identify every source and precedence class, establish one owner, validate permitted values and add an environment test.", "trap": "Add another extra-var override because it wins."},
    {"id": "LES-0040-INC-005", "signal": "The play recap is green but user errors rise after rollout.", "firstThought": "Task success proves module execution, not service correctness or user success.", "safePath": "Stop batches, evaluate user gates, remove unhealthy nodes, roll back desired state, reconverge and preserve evidence.", "trap": "Continue because failed equals zero."}
  ],
  "assessmentIds": ["ASM-0103", "ASM-0104", "ASM-0105"],
  "referenceIds": ["REF-0358", "REF-0359", "REF-0360", "REF-0361", "REF-0362", "REF-0363", "REF-0364", "REF-0365", "REF-0366", "REF-0367", "REF-0368", "REF-0369", "REF-0370", "REF-0371", "REF-0372"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": [
    "The normal-user Ubuntu lifecycle is authored but runtime-unproved because WSL startup fails before id and the Docker Linux engine is unavailable.",
    "The localhost fixture does not prove SSH, privilege escalation, service managers, dynamic inventory, external collections, Automation Controller or fleet rollout.",
    "No real secret, credential, remote endpoint, production inventory, cloud resource or billable object is used.",
    "Publication and automated checks do not establish independent learner competence or production authorization."
  ]
}
---

# Ansible configuration management: make change predictable, convergent, and reviewable

## What you see and first thought

You enter an incident and read: “The Ansible job was green, but half the API nodes now return 503.” Your first useful thought is not *rerun the playbook*. It is:

> A green recap proves that Ansible completed the task graph it was given. It does not prove that the right hosts were selected, the winning variables were safe, the service became healthy, or users succeeded.

Configuration management is not “run commands on many servers.” It is the disciplined conversion of reviewed intent into observable state across a changing fleet. An expert answers six questions before trusting a run:

1. Which controller and repository revision produced it?
2. Which inventory sources produced which exact host set?
3. Which values won variable resolution, and who owns them?
4. Which identity changed each node, through which connection and privilege boundary?
5. What did each module observe, change, skip or fail?
6. What independent evidence says the service and user journey are healthy?

Keep this mental picture:

```text
reviewed intent
    |
    v
controller --inventory--> exact hosts
    |                         |
    +--variables--------------+
    |                         v
    +--task graph--transport--> managed state
                                  |
                                  v
                         independent health proof
```

Ansible is agentless in the usual SSH-based Linux model: the controller does not require a permanent Ansible daemon on every managed node. “Agentless” does not mean “dependencyless.” The controller still needs inventory, credentials, a connection plugin and usually compatible Python on each Linux node. Specialized devices use other transports. Say what the environment actually uses.

Recognize these recurring incident shapes:

| What you see | First hypothesis | Evidence before action |
|---|---|---|
| `UNREACHABLE!` | transport, identity or target resolution failed | resolved host, address, plugin, user, authentication, route |
| `FAILED!` | a task reached the node but could not satisfy its contract | first failed task, redacted arguments, module result, node state |
| every run says `changed` | state never reaches a fixed point, or reporting lies | before/after content, inputs, module semantics |
| config changed, service did not reload | handler notification or execution broke | changed flag, notify topic, handler, flush, service state |
| recap green, users fail | execution and service outcome diverged | health, logs, latency/errors, dependency and user journey |

The operational rule is: **select narrowly, predict honestly, change in bounded batches, verify independently, and preserve a way back.**

## Terms before commands

These terms form one system. Learn their boundaries, not isolated definitions.

**Controller.** The machine or execution environment running `ansible-playbook`. It owns configuration discovery, inventory parsing, variable assembly, task scheduling, connection initiation and result collection. A laptop, CI runner or automation controller may fill this role. Different `ansible.cfg`, collections, Python versions or environment variables can produce a different run from the same YAML.

**Managed node.** A target whose state Ansible observes or changes. It need not run an Ansible agent. Ordinary Linux modules over SSH normally need a remote shell and Python, although `raw` and specialized connection plugins differ. A reachable node can still be unsuitable because the wrong interpreter or privilege identity was selected.

**Inventory.** A source describing hosts, groups and inventory variables. Static INI or YAML is one form; inventory plugins can discover dynamic systems. Inventory is executable scope, not a contact list. A mistaken group relationship or plugin filter widens blast radius before task one.

**Resolved inventory.** The actual host, group and variable graph Ansible constructs from its sources. Inspect the graph. A filename alone does not prove membership.

**Host pattern.** The expression in `hosts:` or `--limit` selecting from resolved inventory. Patterns support unions, intersections and exclusions. `all:!retired:&payments` is a set operation. Preview it with `--list-hosts`.

**Play.** A mapping between a host pattern and ordered work, plus controls such as `serial`, `strategy`, `become`, variables and failure thresholds. A play defines a rollout boundary.

**Task.** One named unit in the task graph. A good name states the desired outcome: “API configuration matches reviewed template,” not merely “copy file.”

**Module.** Code performing a unit of work and returning structured fields such as `changed`, `failed`, `msg`, `rc` and sometimes a diff. Built-ins such as `ansible.builtin.file`, `copy`, `template`, `package` and `service` model common states. Prefer a fully qualified collection name where ambiguity matters.

**Plugin.** Code extending controller behavior. Connection, inventory, callback, lookup, filter, strategy, cache and become are examples. Modules usually perform target work; plugins shape discovery, scheduling, connection, transformation or display.

**Collection.** A distributable namespace of roles, modules and plugins, addressed like `namespace.collection.content`. Pin and review third-party versions; installing a collection adds executable supply-chain material.

**Role.** A conventional package of defaults, variables, tasks, handlers, templates, files and metadata. A role should own one cohesive capability with a clear input contract. A directory named `role` is not automatically reusable; hidden globals and unconditional restarts still make it fragile.

**Variable.** Data used while building and executing the play. Sources include inventory, facts, plays, roles, tasks, registered results and extra vars. Precedence selects the winner when names collide. Precedence is behavior, not a trivia puzzle.

**Fact.** Data gathered from or assigned to a host, such as OS family or interfaces. Gathering improves decisions but costs time and may expose attributes. Collect only what is needed and validate before branching.

**Template.** Usually Jinja-rendered text generated from variables. A template is a small program. Current timestamps, unordered data or controller-specific values can create perpetual changes.

**Handler.** A task normally deferred until notified by a changed task. Repeated notifications of one handler are deduplicated within the relevant scope. Handlers suit expensive reactions such as reloads, but “notified” does not mean “executed successfully.”

**Idempotence.** Reapplying identical desired state to identical current state produces no additional material change. The first run may change; an immediate second run should report `changed=0`. It is a property of the task, inputs and environment—not a magic property of a module name.

**Convergence.** Movement from current state toward declared desired state. An idempotent role can converge perfectly to a dangerous value, so review and health gates remain necessary.

**Drift.** Difference between current managed state and authorized desired state. Drift may be accidental, malicious, emergency work or a competing controller. Before automatic repair, confirm Ansible still owns the object.

**Check mode.** Prediction requested with `--check`. Supporting modules estimate whether they would change. Others skip, partially predict or consult live systems. It is evidence, not a transaction or guarantee.

**Diff mode.** Before/after detail requested with `--diff`. It assists review but may expose secrets. Redaction and artifact controls are safety requirements.

**Recap states.** `ok` means no reported change; `changed` means a reported transition; `failed` means task failure; `unreachable` means transport failure; `skipped` means omitted by a condition or mode; `rescued` means a block entered rescue; `ignored` means policy continued after failure. None alone proves user health.

**Privilege escalation.** `become` changes identity after connection and expands blast radius. State remote user, method, target user and smallest task scope. Do not make an entire play root because one file needs privilege.

**Control plane and data plane.** Inventory, repository, credentials, controller and job metadata form the configuration control plane. Application processes, files and traffic form the managed data plane. A healthy control plane can still produce an unhealthy service.

## Architecture map

Read the diagram left to right as an evidence chain:

```text
+---------------- CONTROL PLANE ----------------+
| Git revision -+                               |
| inventory ----+--> controller/task graph      |
| variables ----+          |                    |
| credentials --+          | connection plugin  |
+--------------------------+--------------------+
                           v
         +------------ MANAGED FLEET -----------+
         | batch A       batch B       batch C  |
         | node 1        node 3        node 5   |
         | node 2        node 4        node 6   |
         +-----+------------+------------+-------+
               +------ service health ---+
                           |
                           v
                   user-journey evidence
```

Every arrow is a failure boundary:

- Git to controller: was the reviewed commit checked out, and were dependencies pinned?
- Inventory to host set: did plugins parse, cache and filter as expected?
- Variables to task graph: which source won, and was the result validated?
- Controller to node: which name resolved to which address, user, plugin and interpreter?
- Task to state: did the module report honestly and change atomically enough?
- State to service: did validation and activation happen at the correct time?
- Service to user: did correctness, errors and latency remain inside objectives?

The controller behavior is more than `site.yml`. Executable, ansible-core and Python versions, configuration, environment, inventory, installed collections, callback plugins and arguments form one execution envelope. Capture them together.

Configuration discovery is security-sensitive. Ansible avoids automatically loading configuration from a world-writable current directory because another user could control plugin or module paths. Do not weaken permissions to bypass that guard. Move to a correctly owned path and make the selected configuration explicit in CI.

Inventory expresses topology and policy:

```text
all
+-- production
|   +-- payments
|   |   +-- payments_canary
|   |   +-- payments_stable
|   +-- observability
+-- staging
```

A host can belong to multiple groups. Group variables merge according to Ansible rules. If `payments`, `production` and a child define generic `port`, reasoning is fragile. Prefer `payments_api_listen_port`, assign one owner and validate the final value.

Dynamic inventory is not automatically current or safe. API calls fail, caches stale, tags lie and broad queries discover too much. Record plugin configuration, cache age, returned count and exact selection.

Execution is scheduled. The default linear strategy generally advances all hosts in a current batch through each task. `forks` bounds controller workers; `serial` partitions a play into batches; `throttle` caps concurrency for a task or block; `run_once` changes selection; `delegate_to` changes execution location. They solve different problems.

Desired file state is not business intent:

```text
file state -> process state -> service state -> user outcome
```

A template module can prove bytes match its render. It cannot alone prove syntax, loaded configuration, dependency health or successful payments. Each layer needs independent evidence.

## Request or state path

Trace one realistic change: raise an API worker limit on twelve nodes.

**1. Establish immutable input.** Begin with a reviewed repository revision, not whatever happens to be in a runner workspace. Record commit, playbook, role version, collection lock, inventory source and approval. A successful prior pipeline does not authenticate a different checkout.

**2. Discover controller configuration.**

```bash
ansible-playbook --version
ansible-config dump --only-changed
```

The version output normally exposes active configuration, module and collection paths, executable, ansible-core and Python details. An unexpected path means a different runtime hypothesis. Changed settings are useful evidence, but environment and command arguments also affect behavior.

**3. Resolve inventory.**

```bash
ansible-inventory -i inventory/production.yml --graph
ansible-playbook -i inventory/production.yml site.yml +  --limit 'payments:&canary' --list-hosts
```

The graph explains membership. `--list-hosts` answers the operational question: which exact nodes are selected after pattern and limit evaluation? Compare identities and count with approval. Zero hosts is a failure, not a harmless green run.

**4. Build the task graph.**

```bash
ansible-playbook -i inventory/production.yml site.yml --syntax-check
ansible-playbook -i inventory/production.yml site.yml +  --limit 'payments:&canary' --list-tasks
```

Syntax acceptance proves parsing and available references. Dynamic includes, runtime conditionals, template expressions and module behavior may remain untested.

**5. Resolve and validate values.** Suppose role defaults say 8 workers, production inventory says 16, the play says 24 and CI passes `-e payments_api_workers=64`. Extra vars win, but winning does not make 64 safe:

```yaml
- name: Worker count is inside the reviewed envelope
  ansible.builtin.assert:
    that:
      - payments_api_workers | int >= 4
      - payments_api_workers | int <= 32
    fail_msg: "payments_api_workers must be between 4 and 32"
```

The cure is not another stronger override. Reduce duplicate definitions, establish ownership and validate the resolved boundary value.

**6. Connect and discover the interpreter.** For SSH-managed Linux, the controller resolves an address, chooses connection and remote user, authenticates, may escalate privilege, stages or streams module code, chooses Python and executes. Failure before module logic can originate in DNS, route, host key, credential, account, remote temporary directory, interpreter or become policy.

```text
UNREACHABLE -> transport did not produce a usable task channel
FAILED      -> task ran far enough to return failure
```

Do not debug package state while transport is unreachable. Do not rotate SSH keys because template validation failed.

**7. Predict.** Run check and diff on a canary. Review target count, predicted changes, unsupported tasks and sensitive output. Check mode does not reserve state, prevent drift between prediction and apply, or guarantee the apply result. Revision, inventory and inputs must remain identical for the prediction to stay relevant.

**8. Change one batch.** Remove a canary from the load balancer, drain connections, apply the role, activate only when changed and verify readiness. `forks=1` is not a rolling deployment; it limits worker concurrency but does not create service gates or rollback.

**9. Interpret structured results.** Capture task, host, module, changed/failed/unreachable, redacted message, return code and duration. Start with the first causal failure. Later skipped handlers or dependency errors may be symptoms.

**10. Verify outside Ansible.** Prove configuration syntax, loaded revision, process readiness, dependencies, load-balancer health, golden signals and a representative user journey. Return a node to traffic, observe a soak window, then advance.

**11. Reconverge.** An immediate second run should show zero changes. If not, find the perpetual writer. Rollbacks must update authoritative desired state and reconverge; manually reverting a node while Git still declares the broken value guarantees recurrence.

## Failure zoom

### Unreachable is not failed

`UNREACHABLE` usually means the connection plugin could not establish a usable channel. Evidence can include DNS failure, timeout, host-key mismatch, authentication rejection, proxy failure or remote-temp permission problems.

```text
prove selected host -> resolved address -> route and port
-> identity and authentication -> shell, temp path and interpreter
```

Rerunning the whole play may duplicate work on healthy nodes while the target stays untouched. Restore connectivity, determine whether prior tasks partially ran, then retry only the exact host if safe.

### Failed is a contract violation, not necessarily a broken host

A module fails because arguments, permissions, dependencies, validation or current state violate its contract. Read the first failed task and structured result. Broad `ignore_errors: true` destroys the stop signal and often obscures the root cause.

Use `failed_when` only for a documented semantic contract:

```yaml
- name: Query whether migration is required
  ansible.builtin.command:
    cmd: /usr/local/bin/migration-status
  register: migration_status
  changed_when: false
  failed_when: migration_status.rc not in [0, 1]
```

This is honest only if the command is observational and return codes 0 and 1 have documented meanings. `failed_when: false` on mutation is evidence destruction.

### Perpetual change is a defect

Common causes:

- a template includes current time or unordered input;
- `command` or `shell` mutates without a state guard;
- two roles compete for one file;
- a handler alters an input used by its notifier;
- custom `changed_when` labels every probe changed;
- an API returns unstable normalized state.

Debug the first changing task on run two. Compare hashes or structured state before and after. False change triggers needless handlers and ruins drift signal. False `ok` is worse: state changed while automation denied it.

### Handler gaps create delayed surprises

Handlers normally run after ordinary tasks in the relevant play section. If a later task fails first, changed configuration may remain on disk while the old process stays active. `force_handlers` changes this behavior but can be unsafe if prerequisites failed.

A deliberate activation path is:

1. render using a validation command where supported;
2. notify a clearly named topic;
3. flush at an explicit boundary only when downstream work requires it;
4. verify process and service health;
5. stop or roll back when the gate fails.

Notifications are deduplicated, which prevents restart storms. Do not treat them as an event queue.

### Variable collisions are incidents

Generic `port`, `user`, `version` and `environment` collide easily. Use role-prefixed names, genuinely safe defaults, required-input assertions, type/range validation and explicit role parameters. Do not permanently mask a bad inventory value with `-e`; correct the authorized source.

### Green automation can produce a red service

A service module succeeds when the service manager accepts an operation. The process can crash later, bind incorrectly or return bad data. Use four gates:

```text
automation: expected hosts/tasks, no unexplained failures
configuration: syntax and loaded revision correct
service: readiness, dependencies and golden signals healthy
user: representative journey succeeds
```

Only their combination permits the next batch.

## Internals and state ownership

For an ordinary Linux task, the controller conceptually:

1. schedules the next host/task according to strategy, batch and throttle;
2. resolves variables and templates task arguments;
3. selects action plugin and module;
4. opens or reuses a connection;
5. transfers or pipelines module code and arguments;
6. executes as the selected remote and become identity;
7. receives structured results;
8. evaluates `failed_when` and `changed_when`;
9. records handler notifications;
10. emits callback output and recap.

Implementation differs by module, transport and target. The key question is: **where did this expression evaluate, and where did this operation run?** Lookups commonly access controller context; modules usually act on the target; delegation changes the target context.

Ansible is usually stateless compared with Terraform state, but the estate is not. Inventory and fact caches, job artifacts, target files, packages, accounts, services and external APIs hold durable state. Repository declares desired state, inventory declares scope, and managed systems hold current state. If another controller owns an object, Ansible must not compete for it.

Idempotence is a fixed-point property. Let `F(desired, current)` describe the resulting state:

```text
current1 = F(desired, current0)
current2 = F(desired, current1)
current2 = current1
```

The second equality is the practical test. Also inspect underlying state because reporting can lie. Change a repository, variable, fact, clock-dependent template or external response and the input boundary changes.

Variable precedence is a merge algorithm and an ownership-smell detector. Configuration, command options, playbook keywords, variables and direct assignment are not one simplistic ladder; variables themselves have documented ordering, with extra vars especially strong. Use the exact version documentation.

Operationally:

1. find every definition of a critical name;
2. classify each source;
3. determine the exact-run winner;
4. decide which source should own it;
5. remove or rename competitors;
6. validate before mutation.

A precedence win is never authorization.

Role boundaries should follow ownership and lifecycle. A `payments_api` role can own a service account contract, package/config inputs, deterministic templates, activation handler, readiness interface and supported OS matrix. It should not secretly own load balancing, databases and firewalls unless those share authority and lifecycle. Keep cross-role orchestration visible in a thin playbook.

Static imports are generally expanded during parsing and improve list visibility. Dynamic includes evaluate during execution and may depend on facts. Use them only when needed and test every branch.

Strategy changes failure timing. Linear coordinates hosts task by task within a batch. Free strategy lets fast hosts advance independently and can violate assumptions that all nodes completed step one before any begins step two. Choose using ordering, dependency load, replica availability, abort threshold and rollback unit.

Vault encrypts selected data at rest, not everywhere. Decrypted values can appear in controller memory, temporary payloads, transport, target files, process environments, callbacks and artifacts. Use external or encrypted sources, least-privileged retrieval, `no_log: true`, strict file modes, short-lived credentials and failure-path leak tests. `no_log` reduces ordinary output; it cannot erase secrets printed by external processes or unsafe plugins.

## Evidence table

Use this table during design reviews and incidents. “Green” means a narrow claim passed, not that the whole system is healthy.

| Question | Primary evidence | Healthy branch | Dangerous branch | Next move |
|---|---|---|---|---|
| Which runtime is active? | `ansible-playbook --version`, changed config | approved core/Python/config paths | unexpected executable, config or collection path | stop; bind immutable environment |
| What can be targeted? | inventory graph and plugin source | expected groups and host count | unknown source, stale cache, unexpected host | stop before play execution |
| What will be targeted? | `--list-hosts` with exact limit | approved identities, nonzero count | all fleet, empty set or excluded canary | fix pattern and review again |
| What work is visible? | syntax and `--list-tasks` | expected roles/tasks | unknown role, missing task, dynamic gap | resolve dependency/branch |
| Which values won? | inventory output, debug with redaction, assertions | one owner and valid value | collision, unsafe override, missing value | fix owner; do not add another override |
| Can nodes be reached? | connection result and exact identity | intended user/plugin/interpreter | unreachable, wrong account or proxy | diagnose transport only |
| What would change? | check and redacted diff | bounded expected changes | unsupported prediction, secret diff, surprise delete | cancel and repair design |
| What changed? | structured module results and artifact hashes | expected nodes/objects only | first causal failure, perpetual change | contain batch and inspect |
| Did activation occur? | notify/listen evidence, handler result | one required reload/restart | missing, repeated or unconditional activation | repair handler boundary |
| Did state converge? | immediate second run plus state digest | `changed=0`, state unchanged | same task changes again | fix first non-idempotent task |
| Is drift observable? | controlled mutation plus check | predicted correction, no check mutation | drift missed or prediction mutates | reject automation until fixed |
| Is service healthy? | readiness, dependency, golden signals | gate inside objective | errors, saturation or stale revision | abort rollout; rollback |
| Are users healthy? | synthetic or representative journey | correct outcome and latency | recap green but journey fails | treat as incident |
| Are secrets contained? | redaction tests and artifact scan | synthetic secret absent | value in output/file/process args | revoke, rotate and repair surface |
| Did cleanup work? | exact manifest and path absence | bounded artifacts absent | unknown file, symlink, wrong owner | refuse broad deletion; investigate |

Three disciplines make the table useful:

1. **Correlate evidence.** Attach controller run ID, revision, inventory snapshot and batch to logs and metrics. “Ansible ran near 14:00” is too weak.
2. **Preserve the first causal error.** Callback output after a failure is often secondary noise. Retain the first failing host/task/result before retry.
3. **State the negative proof boundary.** A syntax check does not prove execution; check mode does not prove apply; module success does not prove service health.

## Command decoders

### `ansible-playbook --version`

Read every line. You are looking for:

- ansible-core version, because module and keyword behavior evolve;
- configuration file path, because discovery changes defaults and plugins;
- module and collection search locations, because name resolution and supply chain depend on them;
- executable location, because a shell alias or virtual environment may differ;
- Python version and library path, because controller plugins execute there.

It does not authenticate the binary. Pair it with a locked environment, package provenance and an immutable runner image or verified virtual environment.

### `ansible-config dump --only-changed`

This shows configuration values differing from defaults and often their origin. Look for inventory, forks, strategy, callback, host-key checking, remote temp paths, interpreter settings, privilege behavior, fact/cache plugins and plugin paths. An empty result means “no changed settings visible to this command,” not “no environment or argument influence.”

Never publish raw config output without reviewing secrets. Better: extract a safe allow-list into the run record.

### `ansible-inventory --graph`

The graph shows host/group relationships:

```text
@all:
  |--@ungrouped:
  |--@lab:
  |  |--les0040-local
```

It helps catch nesting mistakes and surprising membership. It does not show every winning variable. Use `--host NAME` or `--list` carefully, because output may contain sensitive inventory data. The lesson fixture permits exactly one host with `ansible_connection=local`; any second host is a hard failure.

### `--syntax-check`

This checks YAML/Ansible parsing and resolves available roles or static imports. It catches malformed structure and unknown actions early. It generally does not contact targets, render every runtime branch, prove variables exist in every host, execute validators or establish idempotence.

Treat “syntax passed” like compilation of one layer, not a test suite.

### `--list-hosts` and `--list-tasks`

`--list-hosts` is a blast-radius preview. Always run it with the exact inventory, playbook, tags and limit intended for execution. `--list-tasks` previews statically visible tasks and tags. Dynamic includes may not be expanded because their path or condition is runtime data.

If a production job does not preserve its resolved host list, you cannot later prove what it meant to target.

### `--check --diff`

Typical recap:

```text
PLAY RECAP
api-01 : ok=8 changed=2 unreachable=0 failed=0 skipped=1 rescued=0 ignored=0
```

In check mode, `changed=2` means two tasks predicted change according to their module support and available observations. It does not mean two changes were applied. Verify target state stayed untouched. Diff may show content; suppress or redact secret-bearing tasks.

Some tasks need explicit `check_mode: false` to gather essential data, but that can mutate if the chosen module is not observational. Document every exception. Never advertise the entire run as non-mutating merely because the CLI included `--check`.

### Recap counters

`ok` counts successful task results that did not report change. `changed` counts results reporting change; it does not count changed files or guarantee accurate reporting. `unreachable` is transport failure. `failed` is task failure not neutralized by policy. `rescued` and `ignored` reveal failures that did not stop the play. `skipped` may be expected or may expose a false condition.

A recap aggregates. It hides order and causality. Search backward for the first unexpected result.

### `-vvv` and deeper verbosity

Verbosity can expose connection selection, interpreter discovery and module detail, which is valuable in a bounded diagnostic. It can also expose arguments, paths, infrastructure names and secrets. Use the lowest level that answers the question, capture to a restricted incident artifact, sanitize before sharing and delete according to retention policy.

### `--limit`

`--limit` intersects selection at runtime. It is a safety belt, not the inventory model. Quote patterns so the shell does not reinterpret special characters. Preview the exact expression. A typo producing zero hosts can return a job that appears operationally harmless while required change never happened; make zero selection fatal in wrappers.

### `serial`, `forks` and `throttle`

- `serial`: size or percentage of hosts admitted to the current play batch.
- `forks`: maximum controller workers across eligible work.
- `throttle`: a tighter concurrency cap on a task or block.

If `serial: 2` and `forks: 20`, only two hosts belong to the batch, though tasks within it can run concurrently. A delegated database migration may still need `run_once` and an external lock; serial alone does not prevent one execution per batch.

### `changed_when` and `failed_when`

These expressions reinterpret module results. Use them to encode documented semantics, not to obtain a green dashboard. For a read-only command, `changed_when: false` is sensible. For mutation, calculate change from reliable before/after evidence or use a state-aware module.

Multiple YAML-list conditions in `failed_when` are commonly combined as logical AND. If failure should occur when any condition is true, write an explicit OR expression. Parenthesize complex conditions and test every branch.

## Decision path

```text
START: configuration change or Ansible alert
 |
 +-- Can you bind controller version, config, revision and dependencies?
 |      no -> stop; runtime is not reproducible
 |      yes
 |
 +-- Does resolved inventory + pattern equal approved hosts?
 |      no -> stop; blast radius is unknown or wrong
 |      yes
 |
 +-- Are critical variables single-owner and validated?
 |      no -> stop; repair source ownership
 |      yes
 |
 +-- Do syntax, static policy and task/host previews pass?
 |      no -> fix first causal error
 |      yes
 |
 +-- Does check mode predict only approved changes with safe output?
 |      no -> cancel; investigate unsupported/surprising delta
 |      yes
 |
 +-- Apply smallest canary batch
 |      unreachable -> contain; diagnose transport
 |      failed      -> contain; diagnose first task
 |      success
 |
 +-- Configuration, process, service and user gates healthy?
 |      no -> stop waves; roll back authoritative intent; reconverge
 |      yes
 |
 +-- Second run changed=0?
        no -> fix convergence before scaling
        yes -> advance next bounded wave and repeat gates
```

During an incident, freeze scope before changing anything. Record the exact failed batch. Ask whether a retry is safe: did the failed task partially mutate, is the module idempotent, did a handler remain pending, and did later tasks run on other hosts? Retry only the smallest proven set.

When drift appears, decide ownership:

- If Ansible is authoritative and drift is unauthorized, predict then repair.
- If emergency work was authorized, first encode it in desired state or explicitly approve reversion.
- If another controller owns the object, remove overlapping ownership rather than starting a configuration war.
- If the current state is unknown, preserve evidence and use a read-only observation before repair.

Rollback is also desired-state management. Revert the repository or select a reviewed prior artifact, predict the reverse delta, apply to the failed batch and verify service/user outcomes. Restoring a config file manually while leaving the declared version broken is not a completed rollback.

## Guided Ubuntu lab

This lab makes the state machine visible without SSH, root, containers, cloud or internet. Ansible uses its local connection against one inventory host, but still performs inventory resolution, role expansion, templating, result reporting, handler notification, check prediction and convergence.

### Safety boundary

The wrapper accepts only:

- a normal user on Ubuntu 24.04;
- exact controller root `/tmp/reliability-atlas-les0040-controller-$UID`;
- exact managed root `/tmp/reliability-atlas-les0040-managed-$UID`;
- one localhost inventory identity;
- built-in modules and no external collection;
- no `become`, network URL, remote connection, shell or command module;
- exact sentinel, owner and allowed-entry manifests.

If any guard fails, stop. Do not use `sudo`. The cleanup function refuses unknown paths, symlinks, owners and entries rather than turning a variable into a broad recursive delete.

### Step 1: inspect before setup

```bash
cd book/labs/LES-0040-ansible-configuration-management
sed -n '1,240p' README.md
bash lab.sh doctor
```

Expected: `doctor=pass`, nonzero UID, Ubuntu identification, Bash/Python/ansible-core availability. This proves only the controller prerequisites. If WSL fails before a shell with host error `0x80070569`, repair the Windows logon-right/WSL host issue; the lesson must not claim a Linux run.

### Step 2: create bounded roots

```bash
bash lab.sh setup
bash lab.sh status
```

Setup copies reviewed fixtures into the exact controller directory and creates one sentinel in each exact root. The managed root contains no managed configuration yet. This pre-created directory lets file modules make an honest non-mutating check-mode prediction; both before and after checks must show only the sentinel. Repeating setup must be safe and must reject unexpected entries.

### Step 3: prove inventory and graph

```bash
bash lab.sh inventory
bash lab.sh preflight
```

Read the host graph, variable output, syntax result, host list and task list. You should see only `les0040-local`, local connection, explicit `/usr/bin/python3` and the managed role tasks. A surprising host is not “just local testing”; it means the contract escaped.

### Step 4: predict initial convergence

```bash
bash lab.sh check-initial
```

The run predicts deterministic config, payload and reload-marker files. After the command, the guard proves the managed root still contains only its sentinel. This tests non-mutation for these exact built-in tasks; it does not certify every Ansible module.

### Step 5: apply then prove fixed point

```bash
bash lab.sh apply-initial
bash lab.sh verify-state
bash lab.sh apply-steady
```

The initial apply must create only expected files and modes. The config task notifies the reload topic, so a handler writes one marker. `apply-steady` must report zero changes. Open the run outputs and find the first-run recap, handler and second-run recap.

### Step 6: inject and predict drift

```bash
bash lab.sh inject-drift
bash lab.sh check-drift
```

Injection replaces only the managed configuration with a known invalid lesson value. Check mode must predict correction, while a digest assertion proves the invalid file remains. You now have direct evidence that prediction was non-mutating for this path.

### Step 7: repair and reconverge

```bash
bash lab.sh repair
bash lab.sh verify-state
bash lab.sh apply-steady
```

Repair should change the configuration and activate the handler. The next run must return to zero changes. If more than the expected objects change, treat that as an ownership or fixture defect.

### Step 8: complete verifier and cleanup

```bash
bash verify.sh
```

The verifier starts clean, exercises doctor, setup idempotence, static guards, inventory, syntax, check non-mutation, first convergence, second-run idempotence, drift prediction, repair, malicious unexpected-entry refusal, exact cleanup and final absence. `verification=pass` proves only that exact run and tool version.

Manual cleanup, if the verifier stopped:

```bash
bash lab.sh cleanup
```

Read every refusal. Do not bypass it with a broad `rm -rf). An unexpected entry is evidence worth understanding.

## Production transfer

The local lab teaches semantics, not topology. Production adds remote identity, credentials, privilege, heterogeneous platforms, shared dependencies, real traffic and concurrent controllers. Transfer the model deliberately.

### Inventory design

Separate dimensions instead of encoding everything in hostnames. Useful groups describe environment, region, service, lifecycle and rollout ring. Prefer intersections:

```text
payments:&production:&us_east:&canary
```

Keep retired/quarantined nodes explicitly excluded. Dynamic plugins should use read-only identities, narrow queries, bounded caching and count validation. Snapshot the resolved target list into the job record so incident responders can reproduce scope even after tags change.

Do not store connection secrets in inventory plaintext. Inventory is frequently printed during debugging. Reference encrypted or external secret material using an approved mechanism.

### Role and collection engineering

A production role needs:

- namespaced, documented inputs with types and examples;
- assertions for required values and operating envelopes;
- supported OS, version and architecture matrix;
- FQCN modules;
- deterministic templates and stable ordering;
- configuration validation before replacement;
- handlers tied only to real change;
- check-mode behavior documented per task;
- no hidden network downloads;
- explicit dependency and collection versions;
- convergence tests and upgrade/rollback cases.

Package reusable content into collections when it needs namespacing, versioning and distribution. Pin dependencies in a reviewed requirements artifact. Build them in CI, verify the artifact and promote the same bytes rather than resolving “latest” in production.

### Privilege design

Connect as an attributable low-privilege automation identity. Escalate only tasks that require it. Avoid passwordless unrestricted sudo. Permit exact commands or controlled service/file operations when possible, protect become credentials and capture target identity in audit logs.

Temporary module files and remote temp directories are part of the threat model. Ensure only intended identities can read them, use pipelining only after compatibility/security review, and do not place sensitive controller projects in shared writable directories.

### Rolling service change

A safe pattern for each batch is:

```text
select exact nodes
  -> remove/drain from traffic
  -> capture baseline
  -> apply validated configuration
  -> activate changed service
  -> local readiness
  -> dependency and synthetic journey
  -> return to traffic
  -> soak and compare golden signals
  -> advance or rollback
```

Choose `serial` from redundancy and error-budget risk, not a fashionable percentage. If the service tolerates one unavailable replica, a batch of two is already unsafe. Respect availability zone, shard, leader/follower and quorum boundaries. Ansible inventory groups can express them, but the playbook must use them.

Use `any_errors_fatal` or `max_fail_percentage` only after rehearsing exact semantics. A host failure threshold is not a user-health threshold. External monitoring must be able to abort the rollout even when every Ansible task says OK.

### Blocks, rescue and always

Blocks group tasks and error handling:

```yaml
- name: Change one service node
  block:
    - name: Install reviewed configuration
      ansible.builtin.template:
        src: api.conf.j2
        dest: /etc/api/api.conf
        mode: "0640"
        validate: /usr/local/bin/api-config-check %s
      notify: Reload API

    - name: Activate required handlers now
      ansible.builtin.meta: flush_handlers

    - name: Readiness reaches healthy state
      ansible.builtin.uri:
        url: http://127.0.0.1:8080/ready
        status_code: 200
  rescue:
    - name: Preserve failure evidence
      ansible.builtin.debug:
        msg: "Batch failed; evidence retained and expansion stopped"
  always:
    - name: Record batch completion state
      ansible.builtin.debug:
        var: inventory_hostname
```

This is illustrative, not a complete rollback. Rescue runs after a catchable task failure, not every transport or parser failure. An `always` section also runs after success, so it must be safe and idempotent. Do not automatically return an unhealthy node to traffic in `always`.

### Continuous configuration and drift

Decide whether runs are scheduled detection, automatic repair or approval-gated repair. Automatic correction is appropriate only when:

- ownership is exclusive;
- desired state is current and reviewed;
- repair is idempotent and low risk;
- emergency overrides have a documented pause mechanism;
- conflict loops are detected;
- service health can halt remediation.

Measure drift by object and age, not only job failure. A high steady change count means either frequent unauthorized drift or non-idempotence; both deserve action.

### CI/CD gates

A practical pipeline proceeds:

1. YAML/JSON/schema validation;
2. `ansible-lint` under a pinned version and reviewed profile;
3. syntax check with required roles/collections installed from locks;
4. inventory policy tests using synthetic inventory;
5. unit-like tests for filters/templates;
6. ephemeral convergence test;
7. second-run idempotence;
8. controlled drift and repair test;
9. secret leak scan with synthetic canary values;
10. artifact signing/promotion;
11. production check prediction on exact canary;
12. approval, serialized rollout and health gates.

Lint is policy evidence, not runtime proof. Ignore rules narrowly with justification and expiration; never disable an entire profile to pass one legacy task.

## Reliability, security, observability, capacity, and cost

### Reliability

Reliability begins with a known target set and deterministic desired state. Design every role for:

- convergence and honest change reporting;
- bounded batches aligned with failure domains;
- explicit timeouts and retries only for transient operations;
- configuration validation before activation;
- handler execution at deliberate boundaries;
- health gates outside Ansible;
- rollback of authoritative intent;
- coexistence rules with other controllers.

Retries are dangerous when operations are not idempotent. Before retrying, ask whether the previous attempt may have succeeded without returning a result. Use a state query or idempotency key where external APIs support them.

### Security

Threats include malicious inventory/plugins, compromised dependencies, overbroad SSH keys, unrestricted become, secret leakage, unsafe templates and controller compromise. Controls:

- immutable, least-privileged controller;
- signed or verified source and pinned dependencies;
- protected branch and review;
- explicit plugin/collection allow-list;
- SSH host-key verification appropriate to the environment;
- dedicated automation identities and narrow sudo;
- encrypted/external secrets and redaction tests;
- no controller project in world-writable directories;
- restricted job artifacts and retention;
- audit correlation from commit to node and user.

Never pass secrets as ordinary command-line extra vars. Process listings, shell history and CI logs can expose them. Prefer a protected vars file descriptor, vault identity or approved secret integration, and test that failure messages remain redacted.

### Observability

The most useful run record contains:

```text
run_id, revision, controller_image, ansible_core, python
config_digest, collection_lock_digest
inventory_source_digest, resolved_host_set_digest
play, task, role, module_fqcn, host, batch, attempt
started_at, duration, status, changed
handler_notifications, activation_result
service_health_before_after, user_gate, rollback_decision
```

Avoid hostnames or task names as the only join key. Correlate run and revision into service deployment metadata. Callback plugins can export events, but review their secret handling and failure behavior. An observability plugin must not make the configuration run fail open or leak protected arguments.

Track:

- success/failure/unreachable rates by role and environment;
- time to first causal failure;
- changed-host and changed-task distributions;
- steady-run change count;
- handler activation and failure;
- rollout duration and queue delay;
- drift age and repair latency;
- rollback rate;
- service SLO impact by revision.

Alert on outcomes requiring action, not every skipped task. A sudden rise in unreachable may mean network or credential failure. A gradual rise in changed-on-steady may mean drift or non-deterministic input.

### Capacity and performance

Controller CPU, memory, file descriptors, SSH connections and Python processes bound throughput. Managed nodes and dependencies also have limits. Increasing `forks` can create authentication storms, saturate package mirrors, overload APIs or restart too many replicas.

Model:

```text
eligible hosts = current serial batch
parallel tasks = min(eligible hosts, forks, task throttle, dependency limit)
safe parallel mutation <= redundancy and shared-dependency budget
```

Gathering all facts on thousands of nodes can dominate runtime. Gather only required subsets or use a carefully invalidated cache. Persistent connections reduce overhead but extend credential/session lifetime and create stale-connection cases. Benchmark representative inventories and protect shared services with throttles.

### Cost

Ansible software may be open source, but operations are not free. Cost includes controller/automation-platform capacity, engineer review, collection maintenance, secrets, logging retention, test environments, failed rollout impact and toil from noisy non-idempotent runs.

Optimize by reducing unnecessary fact gathering, perpetual changes, redundant restarts and full-fleet runs. Do not trade away safety evidence merely to shorten duration. A five-minute canary soak can be cheaper than a five-hour outage.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| Start with `shell` for everything | hides state model, weak check mode, fragile quoting | choose state-aware module; wrap imperative tools only with explicit guards |
| Put `become: true` on the whole play | turns every task into privileged mutation | escalate the smallest block/task with narrow policy |
| Use `hosts: all` and trust inventory | a plugin or group error becomes fleet-wide | preview exact host set; require limit and batch |
| Add `ignore_errors: true` | continues from unknown partial state | model expected codes; rescue deliberately; stop unknown failures |
| Force `changed_when: false` | hides mutation and skips handlers/auditing | derive change honestly or replace task |
| Embed timestamps in templates | every run rewrites and restarts | keep generated output deterministic; store metadata elsewhere |
| Put secrets in extra vars | arguments leak to process/log history | use vault/secret integration and redaction |
| Assume Vault solves secret handling | only protects selected at-rest content | protect every decrypted surface and test failures |
| Trust check mode as dry-run guarantee | unsupported modules and live observations differ | inventory support, assert non-mutation, stage/canary |
| Trust recap as service health | module contract stops below user outcome | independent configuration, service and journey gates |
| Run unlimited parallelism | overwhelms nodes, dependencies and failure budget | align serial/forks/throttle with capacity and redundancy |
| Mix several tools on one file | controllers fight and drift never settles | declare exclusive field/object ownership |
| Use latest collections | behavior changes without reviewed source change | pin, verify, test and promote immutable artifacts |
| Debug with maximum verbosity in shared CI | leaks secrets and sensitive topology | least verbosity, restricted artifacts, sanitization |
| Retry whole fleet after one host fails | repeats unknown changes and widens incident | establish partial state; limit to exact safe targets |
| Return nodes in `always` | unhealthy nodes rejoin after failed change | health-gated return; leave failed node drained |
| Hide dynamic includes everywhere | preflight cannot reveal real graph | prefer static structure; test runtime branches |
| Treat zero selected hosts as success | required change silently did nothing | wrapper asserts nonzero expected set |
| Manual rollback without Git rollback | next convergence reinstalls failure | revert authoritative desired state and reconverge |

### Shell and command are not forbidden; they are expensive

Sometimes no purpose-built module exists. Before using an imperative command, define:

- exact executable path and arguments;
- current-state observation;
- change predicate;
- success/failure return codes;
- idempotency or safe retry behavior;
- check-mode behavior;
- timeout;
- secret surfaces;
- rollback and cleanup.

Prefer `command.argv` over a shell string when shell features are unnecessary. If shell syntax is required, quote inputs, reject untrusted data and state the shell. Never pipe downloaded content into a privileged shell.

### Do not make tests lie

A test that suppresses change, mocks away inventory or never performs a second run can pass a broken role. The minimum realistic sequence is: clean converge, second converge, controlled drift, check prediction, repair, second converge and cleanup. Add failure injection for handlers, validation and unavailable dependencies.

## Memory card and retrieval

Remember **SCOPE**:

```text
S - Select exact hosts and identity
C - Calculate winning variables and predicted change
O - Operate in bounded batches with explicit ownership
P - Prove convergence, process/service health and user outcome
E - Exit safely: rollback intent, preserve evidence, clean artifacts
```

Remember these contrast pairs:

- inventory source is not resolved host set;
- reachable is not authorized;
- syntax-valid is not executable-safe;
- check prediction is not apply proof;
- changed is not improved;
- idempotent is not correct;
- handler notified is not handler succeeded;
- task green is not service green;
- Vault-encrypted is not secret-contained;
- rollback file is not rollback desired state.

Five-minute retrieval drill:

1. Draw controller, inventory, connection, node, service and user.
2. Explain `unreachable` versus `failed`.
3. Explain why second-run `changed=0` matters.
4. Name three places a decrypted secret can leak.
5. Describe a one-node canary with two independent health gates.
6. Explain why `forks=1` is not a rollout strategy.
7. Explain how you would find a variable winner without adding another override.

One-line incident response:

> Freeze expansion, bind the execution envelope and exact host set, preserve the first causal result, determine partial state, repair or roll back authoritative intent on the smallest batch, then verify users before advancing.

## Complete answers

### Why does Ansible report no agent but still require Python?

“Agentless” means no persistent Ansible service must run on a normal Linux target. The controller connects, sends or pipelines temporary module logic, executes it and receives a result. Most modules are Python programs and therefore need a discovered compatible interpreter. Network appliances, Windows targets and `raw` use other mechanisms. The expert answer names the specific connection and module family rather than repeating “Ansible is agentless.”

### What exactly makes a task idempotent?

The task observes current state, compares it with a stable desired state, changes only a difference and reports that change honestly. After convergence, repeating with the same inputs produces no material transition and `changed=false`. A `copy` task is normally idempotent because it compares content and attributes. A script appending a line on every run is not. Adding `changed_when: false` only hides the evidence; it does not change behavior.

### Is check mode a dry run?

It is better described as module-by-module prediction. Supporting modules often predict well; unsupported tasks may skip or provide incomplete results, and some explicitly forced tasks may execute. External state can change between check and apply. Use check mode with exact host preview, redacted diff, non-mutation assertions, staging and canary execution. Never promise transaction-level dry-run semantics.

### Why did a handler not run?

Work backward:

1. Did the notifying task actually report `changed=true`?
2. Did `notify` match the handler name or a `listen` topic?
3. Was the handler defined in the same play scope and loaded?
4. Did a later failure stop normal handler execution?
5. Was the handler flushed earlier, or never reached?
6. Was the host unreachable or removed from active hosts?
7. Did the handler run but the service later fail?

Do not add an unconditional restart until these are answered.

### How do I know which variable won?

Search every definition, understand the documented precedence category for the exact ansible-core version, inspect resolved inventory/host data with secrets protected and add a temporary safe assertion or debug of a non-secret value. Then remove duplicate ownership. The lasting fix is not “remember extra vars win”; it is “one layer owns each critical decision.”

### What is the difference between `forks`, `serial` and `throttle`?

`serial` decides how many hosts enter the current play batch. `forks` limits controller worker concurrency across eligible work. `throttle` places a smaller concurrency ceiling on a task or block. None supplies a service health gate. A safe rollout combines batch selection, dependency capacity, drain/return, health verification and abort logic.

### When should I use `shell`?

Only when shell language is genuinely needed and no state-aware module or safe API exists. Define exact input validation, current-state test, changed semantics, return codes, timeout, check behavior, secret handling and safe retry. Prefer `ansible.builtin.command` with `argv` when pipes, redirection, expansion and shell built-ins are unnecessary.

### How should secrets be stored?

Use an approved external secret system or encrypted Vault data, fetched by a least-privileged identity. Keep plaintext out of Git and command lines. Redact tasks, restrict target file modes, control temporary paths and artifact retention, use short-lived credentials, and test failures using a synthetic canary secret. Encryption at rest is one layer; follow the decrypted value end to end.

### What should happen when one node fails in a rolling update?

Stop admission of new batches. Keep the failed node drained. Determine whether it is unreachable, task-failed or service-unhealthy. Establish partial state and whether retry is idempotent. Repair or roll back authoritative intent on that node/batch, reconverge, verify service and user gates, then decide whether evidence permits continuing. Do not rerun all nodes automatically.

### How do Ansible and Terraform divide ownership?

Terraform usually owns infrastructure object lifecycle and explicit address-to-object state: networks, instances, managed services and identity resources. Ansible commonly owns operating-system and application configuration after a target exists. The exact boundary is organizational. Avoid both tools managing the same field or object. Pass explicit outputs such as addresses into inventory, preserve ordering, and design decommissioning so Ansible does not configure an object Terraform is deleting.

### Why can a successful task still cause an outage?

Module success proves its narrow contract. A template may write valid bytes that encode a bad capacity limit. A service manager may accept restart before the process crashes. A health endpoint may be shallow while a dependency path fails. Configuration automation must be coupled to configuration validation, deep service checks, golden signals and representative user journeys.

### Should production drift be repaired automatically?

Only when ownership is exclusive, desired state is current, change is low risk and idempotent, emergency overrides can pause repair, conflict loops are detected, and service health can stop action. High-risk drift should generate evidence and approval rather than immediate mutation. Never allow two controllers to fight faster.

## Product-company interview

### Design question: manage 20,000 heterogeneous Linux nodes

A strong answer starts with boundaries:

1. Partition inventory by environment, region, service, OS and rollout ring; use dynamic plugins with narrow read-only queries and cache-age/count controls.
2. Build signed immutable execution images containing pinned ansible-core, Python and collections.
3. Use namespaced roles with platform-specific task files selected by validated facts.
4. Run static, convergence, idempotence, drift and rollback tests against supported OS matrices.
5. Schedule by failure domain with serial batches, controller shards and dependency throttles.
6. Use dedicated low-privilege identities and task-scoped escalation.
7. Export structured run events correlated to revision, host, batch and service signals.
8. Stop progression from both automation failures and independent SLO/user gates.
9. Keep audit, evidence retention and emergency pause/rollback paths.

State the trade-off: controller sharding improves throughput and isolation but creates scheduling, inventory-consistency and duplicate-run risks. Use a central job ownership/locking model and idempotent roles.

### Troubleshooting question: 500 of 5,000 nodes are unreachable

Do not immediately retry. Compare failed nodes by region, subnet, OS image, connection route, credential group and controller shard. Confirm they were intentionally selected. Inspect the first transport error and distinguish DNS, TCP timeout, host key, authentication, proxy, remote temp and interpreter stages. Compare a healthy and unhealthy node using read-only connection diagnostics. Protect the remaining fleet from repeated authentication storms. Restore the shared boundary, prove whether any tasks ran, then retry only the exact safe set.

### Reliability question: every run changes one template

Capture generated content and input provenance across two runs. Diff bytes. Look for timestamps, randomized/unordered structures, facts that fluctuate, different line endings, controller-specific paths, competing roles and changed custom filters. Verify mode/owner too. Fix deterministic rendering or exclusive ownership; never mute `changed_when`. Add a clean-first-run and zero-change-second-run test plus drift repair.

### Security question: how would you use Vault?

Explain that Vault encrypts data at rest and is not a complete secret system. Keep vault password or identity external to Git, retrieve with least privilege, avoid CLI plaintext, use `no_log`, restrict target files, prevent debug/callback/artifact leakage and rotate credentials. Prefer short-lived dynamic secrets for production where possible. Test error paths with a fake recognizable value. Separate developers who edit encrypted references from identities allowed to decrypt production values.

### Rollout question: configuration is good on canary but breaks batch two

Stop batch three. Preserve exact target lists, variables, facts and results for canary and batch two. Compare dimensions—zone, OS, package version, hardware, dependency shard—and confirm the same artifact/revision ran. Drain affected nodes, assess error-budget/user impact, and choose rollback or fix based on recovery time and safety. Revert authoritative desired state for the affected cohort, reconverge, verify, and add the missing compatibility case to preproduction tests.

### Systems question: why not replace Ansible with shell scripts?

Shell can be appropriate for small bounded operations, but Ansible provides inventory resolution, structured modules/results, idempotent state primitives, variable/role composition, handlers, batching and extensibility. These create reviewable semantics across many nodes. Ansible can still become an opaque shell dispatcher if abused. The value comes from explicit desired state, scopes, validation and evidence—not the YAML file extension.

### Architecture question: where should application deployment end and configuration begin?

Prefer immutable application artifacts and images built once. Use deployment orchestration to select version and manage traffic; use configuration management for host prerequisites and bounded runtime configuration that cannot be baked safely. Keep secrets external. Avoid rebuilding artifacts per environment. The boundary should minimize mutable surface and give each field one owner. Kubernetes workloads may shift much of this to declarative manifests/operators, while Ansible still configures nodes or external systems.

### Behavioral question: describe an incident you would lead

Use a structured answer: user impact and detection; exact scope; first hypothesis; evidence that changed the hypothesis; containment; smallest recovery; validation at automation/service/user levels; root cause; contributing conditions; prevention with owner/date; and what was intentionally not claimed. Emphasize decisions under uncertainty, communication and learning—not heroics.

### Coding question: what is wrong with this task?

```yaml
- shell: "echo {{ api_key }} >> /etc/api/env"
  become: true
  ignore_errors: true
  changed_when: false
```

It exposes an unquoted secret through templating/process/log paths, appends on every run, requires broad privilege, hides errors, lies about changes, lacks mode/ownership/validation and may duplicate entries. Replace it with a purpose-built secret/config delivery mechanism, encrypted/external retrieval, `no_log`, deterministic template or line state, strict permissions, validation, narrow become and handler/health verification. Rotate the exposed key.

## Independent transfer and rubric

The reviewer provides an unfamiliar local-only simulation. It contains:

- three inventory hosts representing canary and stable batches;
- one unsafe higher-precedence override;
- one timestamp-driven template;
- one handler-topic mismatch;
- one simulated health gate failure;
- no real SSH endpoint, secret, root requirement or external collection.

The learner must not read model answers. Deliver:

1. execution-envelope and resolved-host evidence;
2. a variable-source/owner map;
3. first causal defect analysis;
4. minimal patch restoring deterministic convergence;
5. initial and second-run recaps;
6. controlled drift prediction and repair;
7. rollout/abort/rollback decision;
8. secret-surface review;
9. exact cleanup proof;
10. a five-minute verbal incident briefing.

Scoring:

| Criterion | Points | Full-credit evidence |
|---|---:|---|
| Controller and dependency identity | 8 | exact version, Python, config and source revision |
| Inventory and selection safety | 10 | graph, host list, limits and zero/unexpected-host guard |
| Variable ownership | 10 | every critical source, winner, authorized owner and validation |
| Root-cause analysis | 10 | first defect distinguished from symptoms |
| Minimal implementation | 10 | narrow readable patch without hidden overrides |
| Idempotence and drift | 10 | first change, second zero, drift prediction, repair, second zero |
| Handler and activation | 8 | correct notification/listener and health boundary |
| Failure containment | 10 | batches, abort threshold and failed node handling |
| Security | 8 | no secret exposure, least privilege and artifact controls |
| Observability | 6 | correlated run/task/service/user evidence |
| Recovery and cleanup | 5 | authoritative rollback and exact artifact absence |
| Communication | 5 | concise impact, evidence, decision, uncertainty and next action |
| **Total** | **100** | **80 passes; no critical safety miss; 90 demonstrates advanced transfer** |

Automatic failure conditions are: real remote target, root execution, plaintext secret, unbounded recursive deletion, ignored unknown failure, hidden mutation, unapproved external dependency or fabricated evidence.

Mastery requires both artifact quality and explanation. A learner who copies a passing role but cannot explain the host set, variable winner, fixed point and rollback has not demonstrated independent competence.

## References and review

Primary references, reviewed 2026-08-04:

1. [Ansible getting started and concepts](https://docs.ansible.com/ansible/latest/getting_started/index.html) — controller and managed-node orientation.
2. [Playbook introduction](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html) — plays, tasks and execution.
3. [Inventory introduction](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) — hosts, groups, variables and patterns.
4. [Variable precedence](https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html) — configuration, options, keywords, variables and direct assignment.
5. [Handlers](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html) — notification, deduplication, order and flush behavior.
6. [Check and diff modes](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html) — prediction support and limitations.
7. [Controlling execution with strategies](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_strategies.html) — linear/free, forks, serial, throttle and ordering.
8. [Error handling](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_error_handling.html) — failure, unreachable hosts, handlers and thresholds.
9. [Interpreter discovery](https://docs.ansible.com/ansible/latest/reference_appendices/interpreter_discovery.html) — automatic and explicit Python selection.
10. [Configuration settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) — discovery, settings and world-writable-directory warning.
11. [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html) — encrypting variables and files at rest.
12. [Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html) — role structure, use and dependencies.
13. [Collections](https://docs.ansible.com/ansible/latest/collections_guide/index.html) — namespaced distributable content.
14. [Testing strategies](https://docs.ansible.com/ansible/latest/reference_appendices/test_strategies.html) — integration and check-mode test direction.
15. [Ansible Lint documentation](https://ansible.readthedocs.io/projects/lint/) — static policy and profiles.

Review limitations:

- The official sources were checked for current accessibility, but this draft remains quarantined until full promotion review.
- The Ubuntu wrapper is authored but runtime-unproved because WSL cannot start and the Docker Linux engine was unavailable.
- The lab uses localhost, built-in modules and user-owned files. It does not prove SSH, become, service managers, dynamic inventory, Automation Controller, external collections or fleet behavior.
- No cloud resource, credential, external service, production inventory or billable object is used.
- LES-0040 is learning content, not authorization to operate production.

Promotion requires schema and relationship validation; Bash/Python/YAML/static checks; a normal-user Ubuntu lifecycle; cleanup/refusal-path evidence; technical, security, instructional and accessibility review; and independent learner transfer. Until then, it is not canonical and not mastery evidence.
