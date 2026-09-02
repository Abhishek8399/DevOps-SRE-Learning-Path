---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0025",
  "aliases": ["V03-L10", "ci-platform-operations"],
  "curriculumIds": ["CI-002"],
  "slug": "ci-platform-operations",
  "route": "/book/engineering/ci-platform-operations",
  "order": 10,
  "volume": "03-engineering-delivery",
  "title": "CI platform operations: run GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines safely",
  "summary": "Operate continuous-integration platforms by separating provider syntax from the invariant release mechanism: an event selects reviewed configuration and source identities, a control plane expands a job graph, a scheduler matches work to a qualified trust pool, an execution plane runs attempts, and evidence leaves through artifacts and telemetry. Compare GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines without pretending that similar YAML means identical security, scheduling, retry, approval, cache, or upgrade behavior.",
  "domain": "engineering",
  "level": {"from": "intermediate", "to": "advanced"},
  "estimatedMinutes": 570,
  "prerequisiteLessonIds": ["LES-0024"],
  "prerequisiteCurriculumIds": ["CI-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The manual exercises use Bash, Git, coreutils, procfs, findutils, and Python 3 standard library as a normal user. The bounded practical lab additionally creates exact guarded state below /tmp and runs two purpose-built local CI teaching engines. It installs nothing, opens no port, contacts no provider, passes only an allowlisted environment to child processes, declares no secret input, and makes no cloud or hosted-CI change. This does not prove that same-UID host or filesystem credentials are absent."},
    {"platform": "Windows Subsystem for Linux (WSL 2) Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "Run commands inside Ubuntu. Filesystem, process, user, and networking behavior are Linux-side observations; do not infer native Windows agent behavior from them."},
    {"platform": "GitHub Actions", "version": "provider concepts reviewed 2026-08-02", "support": "concept-only", "notes": "Workflow, reusable-workflow, permission, environment, hosted-runner, self-hosted-runner, group, and label concepts are compared. No GitHub workflow or runner was created or executed for this lesson."},
    {"platform": "GitLab CI/CD", "version": "provider concepts reviewed 2026-08-02", "support": "concept-only", "notes": "Pipeline configuration, include, runner, tag, protected-runner, executor, artifact, cache, and resource-group concepts are compared. No GitLab pipeline or runner was created or executed for this lesson."},
    {"platform": "Jenkins", "version": "provider concepts reviewed 2026-08-02", "support": "concept-only", "notes": "Pipeline, controller, agent, node label, executor, shared-library, credential, plugin, and upgrade concepts are compared. No Jenkins controller, agent, plugin, or job was created or executed for this lesson."},
    {"platform": "Azure Pipelines", "version": "provider concepts reviewed 2026-08-02", "support": "concept-only", "notes": "YAML pipeline, template, stage, environment, approval and check, pool, agent capability, and demand concepts are compared. No Azure DevOps organization, pipeline, environment, service connection, or agent was created or executed for this lesson."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "release-engineer", "build-engineer", "security-engineer", "cloud-infrastructure-engineer"],
  "learningObjectives": [
    "Map GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines onto one control-plane, scheduler, execution-plane, evidence-store, and environment model while preserving their meaningful differences.",
    "Port pipeline intent without blindly translating keywords: identify event, configuration identity, job graph, selector, execution image, permissions, dependency inputs, artifacts, cache, environment, concurrency, retry, timeout, and evidence contracts.",
    "Explain how GitHub runner groups and labels, GitLab runner tags, Jenkins node labels and executors, and Azure agent pools plus capability demands affect eligibility but do not by themselves prove runner integrity.",
    "Design hosted, persistent self-hosted, and ephemeral self-hosted runner pools around workload trust, network reachability, credentials, operating-system lifecycle, isolation, capacity, cost, and forensic requirements.",
    "Protect reusable pipeline code and dependency identities across reusable workflows, includes or components, Jenkins shared libraries and plugins, and Azure templates.",
    "Diagnose queue growth by separating arrival rate, eligible capacity, service time, concurrency limits, selector mismatch, offline workers, provisioning delay, and downstream throttling.",
    "Operate runner and controller upgrades through inventory, compatibility review, canary pools, drain, rollback or roll-forward criteria, and evidence rather than fleet-wide replacement by hope.",
    "Define least-privilege event and job permissions, isolate untrusted change execution from deployment authority, prevent secret exfiltration, and preserve useful audit evidence without logging secrets.",
    "Build observability that joins pipeline definition, source revision, logical run, attempt, job, queue, worker, workspace, artifact, environment, approval, and user outcome identities.",
    "Operate two purpose-built local CI teaching engines, compare green results and declared contract fields, and state exactly which permission, concurrency, timeout, and vendor behaviors remain untested."
  ],
  "productionSignals": [
    "Jobs remain queued although workers are online because no worker satisfies every selector, pool, protection, capability, architecture, or trust requirement.",
    "Queue age rises while worker utilization appears low because dashboards aggregate eligible and ineligible pools.",
    "A reusable workflow, included configuration, shared library, template, action, task, plugin, or executor image changes without a reviewed immutable identity.",
    "Untrusted pull-request or merge-request code reaches persistent self-hosted workers that also hold deployment credentials, writable shared caches, sensitive network routes, or later trusted jobs.",
    "A runner or agent upgrade changes shell, toolchain, container, filesystem, certificate, proxy, or cleanup behavior and many unrelated repositories fail together.",
    "A Jenkins plugin or controller upgrade changes Pipeline behavior, dependency compatibility, credential binding, or restart requirements.",
    "A pipeline is green on one provider but the port silently lost a permission boundary, timeout, required dependency, approval, concurrency lock, artifact transfer, or cancellation rule.",
    "A cache is treated as release evidence, or an artifact is re-built on each platform instead of promoting one immutable identity.",
    "A job retry creates duplicate external effects because a new attempt is confused with a new logical operation.",
    "Platform status is healthy while a repository, organization, project, folder, pool, runner group, executor class, or environment is unavailable to the affected workload.",
    "Hosted runner spend grows because over-sized machines mask dependency, test-sharding, cache, or queue-design problems; self-hosted spend grows because idle capacity and operator toil are omitted.",
    "Logs, annotations, archived workspaces, artifacts, caches, or debug traces expose tokens, credentials, event payloads, internal addresses, or personally identifiable information."
  ],
  "diagrams": [
    {
      "id": "LES-0025-DIA-001",
      "title": "Four providers implement one pipeline mechanism with different contracts",
      "direction": "top-to-bottom",
      "boundaries": ["event and reviewed configuration", "provider control plane", "job-graph expansion and policy", "scheduler and eligibility", "runner or agent execution plane", "artifact cache and log stores", "environment authorization and deployment target"],
      "evidencePoints": ["event identity and trust", "source and configuration revisions", "expanded jobs dependencies and conditions", "selector and eligible worker count", "worker image version workspace and attempt", "artifact digest cache key and log stream", "approval policy principal operation and user result"],
      "textAlternative": "GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines use different vocabulary, but each accepts an event and configuration, expands work in a control plane, schedules eligible jobs onto an execution plane, and records outputs. Portability requires preserving the contracts across every boundary, not merely translating YAML keys."
    },
    {
      "id": "LES-0025-DIA-002",
      "title": "A job dispatch succeeds only when every eligibility predicate intersects",
      "direction": "left-to-right",
      "boundaries": ["queued job requirements", "administrative scope", "trust and protection class", "pool group or executor", "labels tags or demands", "online capacity and concurrency", "selected worker and isolated attempt"],
      "evidencePoints": ["job and queue timestamps", "repository project folder or organization scope", "event trust and protected ref", "pool group executor and architecture", "requested and advertised selectors", "online busy disabled and quota state", "worker attempt workspace and tool versions"],
      "textAlternative": "A queued job is eligible only where administrative access, trust class, execution pool, all required selectors, online capacity, and concurrency allowance overlap. Seeing ten online workers proves nothing if the intersection for this job is empty."
    },
    {
      "id": "LES-0025-DIA-003",
      "title": "Self-hosted worker risk follows code credentials network and residue",
      "direction": "left-to-right",
      "boundaries": ["event trust", "reviewed or untrusted code", "worker process", "workspace and host", "credential and identity source", "network and control-plane reach", "cache artifact and later workload"],
      "evidencePoints": ["fork branch tag and actor", "source action task template and library revisions", "worker image and service identity", "cleanup mount process and persistence state", "token claims scope and expiry", "allowed destinations and administrative APIs", "write ownership content digest and subsequent consumer"],
      "textAlternative": "Code enters a worker and can influence its workspace, processes, credentials, network, caches, artifacts, and later jobs. The safe design minimizes trust mixing, privilege, reachability, persistence, and reusable writable state, and prefers a fresh worker for each untrusted attempt."
    },
    {
      "id": "LES-0025-DIA-004",
      "title": "Runner and controller upgrades are staged state transitions",
      "direction": "cyclic",
      "boundaries": ["inventory and compatibility", "pinned candidate", "isolated canary pool", "representative synthetic and real jobs", "observe and compare", "promote hold or roll back", "drain replace and verify", "documented fleet state"],
      "evidencePoints": ["versions dependencies and owners", "binary image plugin and configuration digests", "canary selectors and zero production authority", "shell container artifact cache network and credential cases", "failure queue latency security and cost deltas", "decision owner threshold and evidence", "in-flight attempts cleanup and capacity", "worker inventory controller revision and exception register"],
      "textAlternative": "An upgrade begins with inventory and a pinned candidate, proceeds through an isolated canary pool and representative jobs, and advances only after measured comparison. Workers are drained and replaced in bounded waves, verified, and recorded; rollback or roll-forward follows explicit compatibility and security criteria."
    },
    {
      "id": "LES-0025-DIA-005",
      "title": "Queue incidents branch by eligibility capacity and service time",
      "direction": "hierarchical",
      "boundaries": ["queue-age alert", "scope and freshness check", "eligible-worker intersection", "online and healthy state", "busy quota or lock state", "service-time and dependency state", "containment and recovery proof"],
      "evidencePoints": ["oldest and percentile queue age by class", "provider region project repository pool and event", "selectors trust scope and architecture", "heartbeat version errors disk memory and certificate", "running jobs quotas concurrency and environment locks", "job duration external latency retry and provisioning", "accepted jobs user outcome backlog slope and exception expiry"],
      "textAlternative": "When queue age alerts, first verify the affected scope and telemetry freshness. Determine whether any worker is eligible, then whether eligible workers are healthy, available, or blocked. If capacity exists, examine service time and dependencies. Recovery is a falling backlog and successful representative work, not merely an online icon."
    }
  ],
  "commands": [
    {
      "id": "LES-0025-CMD-001",
      "question": "Are the local tools used by this lesson available without installing anything?",
      "risk": "read-only",
      "command": "for tool in bash git python3 sha256sum awk find sort nproc getconf; do command -v \"$tool\" >/dev/null && echo \"$tool=present\" || echo \"$tool=missing\"; done",
      "runFrom": "Any Ubuntu 24.04 shell as a normal user",
      "expectedBranches": [
        {"when": "Every tool reports present", "meaning": "The bounded local commands have their expected executables.", "nextEvidence": "Record tool versions and continue without installing or elevating."},
        {"when": "One or more tools report missing", "meaning": "This environment does not match the tested tool boundary.", "nextEvidence": "Stop the affected exercise; do not install software implicitly. Use an approved disposable Ubuntu environment or review the command conceptually."}
      ],
      "proves": "Whether this shell can resolve the named executables at one instant.",
      "doesNotProve": "Tool correctness, version compatibility, provider access, runner health, or administrative permission."
    },
    {
      "id": "LES-0025-CMD-002",
      "question": "What Linux kernel architecture and userspace word size does this local execution context expose?",
      "risk": "read-only",
      "command": "uname -srm; printf 'userspace_bits='; getconf LONG_BIT",
      "runFrom": "The exact Ubuntu shell that will run the local model",
      "expectedBranches": [
        {"when": "Linux, a kernel release, a machine architecture, and userspace_bits=64 print", "meaning": "The shell reports a 64-bit Linux userspace on the displayed architecture.", "nextEvidence": "Compare the real job's requested architecture and runner image; do not translate x86_64, amd64, and a provider label by assumption."},
        {"when": "A different operating system, architecture, or word size prints", "meaning": "The local execution boundary differs from the tested example.", "nextEvidence": "Re-evaluate binary, container-image, action, task, plugin, and toolchain compatibility before execution."}
      ],
      "proves": "Kernel and userspace properties reported inside this execution context.",
      "doesNotProve": "Physical host architecture, nested virtualization, container-image compatibility, provider label accuracy, or worker integrity."
    },
    {
      "id": "LES-0025-CMD-003",
      "question": "How many processing units are available to this shell's scheduling boundary?",
      "risk": "read-only",
      "command": "printf 'available_processing_units='; nproc",
      "runFrom": "The exact Ubuntu process boundary being investigated",
      "expectedBranches": [
        {"when": "A positive integer prints", "meaning": "GNU nproc reports that many processing units available to the current process.", "nextEvidence": "Inspect cgroup CPU quota, throttling, workload parallelism, and observed service time before sizing a worker."}
      ],
      "proves": "The processing-unit count reported to this process by nproc.",
      "doesNotProve": "Dedicated cores, CPU speed, absence of contention, quota headroom, or pipeline throughput."
    },
    {
      "id": "LES-0025-CMD-004",
      "question": "What memory totals does this Linux boundary report?",
      "risk": "read-only",
      "command": "awk '/^(MemTotal|MemAvailable|SwapTotal|SwapFree):/ {print $1, $2, $3}' /proc/meminfo",
      "runFrom": "The exact Ubuntu host, virtual machine, container, or WSL boundary being investigated",
      "expectedBranches": [
        {"when": "MemTotal, MemAvailable, SwapTotal, and SwapFree rows print", "meaning": "The kernel exposes current aggregate memory fields in kibibytes for this boundary.", "nextEvidence": "Inspect cgroup memory limits, pressure, out-of-memory events, per-process usage, and job timestamps."},
        {"when": "Rows are absent or /proc is unavailable", "meaning": "The expected Linux procfs evidence source is absent or restricted.", "nextEvidence": "Stop using this decoder and use the execution environment's authoritative resource interface."}
      ],
      "proves": "Four fields read from procfs at one instant.",
      "doesNotProve": "A job's peak memory, cgroup limit, reclaim cost, memory pressure history, or cause of termination."
    },
    {
      "id": "LES-0025-CMD-005",
      "question": "Does the current workspace filesystem have both block and inode headroom?",
      "risk": "read-only",
      "command": "df -hT .; df -i .",
      "runFrom": "The exact runner or local workspace path being investigated",
      "expectedBranches": [
        {"when": "Both block Use% and inode IUse% have headroom", "meaning": "The mounted filesystem reports free data blocks and free inode entries at this instant.", "nextEvidence": "Check quotas, reserved space, temporary mounts, container layers, deleted-open files, and the exact failing path."},
        {"when": "Block Use% is near 100 percent", "meaning": "The mount may lack data-block capacity.", "nextEvidence": "Preserve evidence, identify bounded owners and growth, then follow approved retention or expansion procedures."},
        {"when": "IUse% is near 100 percent while blocks remain", "meaning": "The mount may be unable to allocate metadata for another file.", "nextEvidence": "Count files by bounded directory and owner; do not blindly delete unrelated workspace or system paths."},
        {"when": "The inode fields contain a dash, negative number, or other non-filesystem accounting value", "meaning": "This interface is not exposing conventional inode accounting for the mount, which can occur on a Windows-backed 9p or DrvFS path in WSL.", "nextEvidence": "Do not infer inode headroom or exhaustion. Read the authoritative interface for the exact Linux, container, virtual-disk, or Windows-backed filesystem where the write failed."}
      ],
      "proves": "Filesystem type and the block and inode fields emitted by df for the mount containing the current directory; field meaning still depends on filesystem support.",
      "doesNotProve": "Writable permission, quota headroom, another mount's state, storage latency, file ownership, or why a job failed."
    },
    {
      "id": "LES-0025-CMD-006",
      "question": "Which local repository and source object am I actually reviewing?",
      "risk": "read-only",
      "command": "git rev-parse --show-toplevel && git rev-parse --verify HEAD",
      "runFrom": "A reviewed local Git worktree",
      "expectedBranches": [
        {"when": "An absolute root and a full object ID print", "meaning": "Git resolved the current worktree and HEAD identity.", "nextEvidence": "Record the pipeline definition, reusable dependency, submodule, lockfile, and builder identities separately."},
        {"when": "Git reports that this is not a repository or HEAD is ambiguous", "meaning": "The intended source boundary is not established.", "nextEvidence": "Stop and locate the intended worktree; do not fetch, clone, or change branches implicitly."}
      ],
      "proves": "The local Git root and HEAD object selected at that instant.",
      "doesNotProve": "Workspace cleanliness, remote state, code review, signature trust, provider configuration snapshot, or built bytes."
    },
    {
      "id": "LES-0025-CMD-007",
      "question": "What tracked and visible untracked state exists outside HEAD?",
      "risk": "read-only",
      "command": "git --no-optional-locks status --short --untracked-files=all",
      "runFrom": "The exact local or runner worktree after repository identity is established",
      "expectedBranches": [
        {"when": "No rows print", "meaning": "Git reports no tracked change or visible untracked path under this configuration.", "nextEvidence": "Inspect ignored files, external mounts, generated inputs, running processes, and cleanup policy before claiming a clean worker."},
        {"when": "Rows print", "meaning": "The displayed paths differ from HEAD or are visible untracked state.", "nextEvidence": "Preserve the list and determine which attempt created or consumed each path before cleanup."}
      ],
      "proves": "Git porcelain status for this worktree at one instant.",
      "doesNotProve": "Absence of ignored files, secrets, external state, hostile processes, cache contamination, or host compromise."
    },
    {
      "id": "LES-0025-CMD-008",
      "question": "Can one exact reusable dependency identity be fingerprinted locally?",
      "risk": "read-only",
      "command": "printf '%s' 'kind=reusable-config|source=reviewed-repository|revision=0123456789abcdef|path=ci/build.yml' | sha256sum",
      "runFrom": "Any supported lesson shell; the tuple is synthetic and contains no credential",
      "expectedBranches": [
        {"when": "A 64-hex-character digest and a dash print", "meaning": "sha256sum fingerprinted the exact in-memory byte tuple read from standard input.", "nextEvidence": "For a real dependency, verify that the provider resolves an immutable revision and preserves the fetched content identity in run evidence."}
      ],
      "proves": "The SHA-256 digest of the displayed synthetic byte sequence.",
      "doesNotProve": "Repository authenticity, review, provider resolution, dependency safety, or what configuration a real run used."
    },
    {
      "id": "LES-0025-CMD-009",
      "question": "Does any modeled worker satisfy every requirement of a queued job?",
      "risk": "read-only",
      "command": "python3 -c \"job={'linux','x64','trusted'}; workers={'r1':{'linux','arm64','trusted'},'r2':{'linux','x64','untrusted'},'r3':{'linux','x64','trusted'}}; print('requirements='+','.join(sorted(job))); [print(n,'eligible='+str(job <= s).lower(),'missing='+(','.join(sorted(job-s)) or '-')) for n,s in workers.items()]\"",
      "runFrom": "Any supported lesson shell; this is an in-memory scheduling model",
      "expectedBranches": [
        {"when": "Only r3 reports eligible=true", "meaning": "Only r3's modeled attributes are a superset of all job requirements.", "nextEvidence": "On a real platform, also inspect administrative access, protection, online state, concurrency, quota, version, and health."},
        {"when": "Python fails before printing the model", "meaning": "The tested interpreter boundary is unavailable or the command was altered.", "nextEvidence": "Do not infer scheduling behavior; compare against the checked-in command and record the interpreter error."}
      ],
      "proves": "Set-inclusion results for one synthetic job and three synthetic workers.",
      "doesNotProve": "Provider scheduling order, real runner eligibility, label truth, protection, health, capacity, or isolation."
    },
    {
      "id": "LES-0025-CMD-010",
      "question": "What is the critical-path duration of a small dependency graph?",
      "risk": "read-only",
      "command": "python3 -c \"d={'build':4,'unit':3,'scan':6,'package':2}; n={'build':[],'unit':['build'],'scan':['build'],'package':['unit','scan']}; e={}; [(e.__setitem__(j,d[j]+max([e[x] for x in n[j]] or [0]))) for j in d]; print('earliest_finish='+','.join(f'{k}:{v}' for k,v in e.items())); print('critical_path_minutes='+str(e['package']))\"",
      "runFrom": "Any supported lesson shell; the graph and durations are synthetic",
      "expectedBranches": [
        {"when": "package finishes at 12 and critical_path_minutes=12", "meaning": "The scan branch, not the unit branch, controls earliest package completion in this model.", "nextEvidence": "Compare real queue time, provisioning, retries, fan-out limits, dependency latency, and duration distributions before optimizing."}
      ],
      "proves": "Earliest-finish arithmetic for the displayed four-node acyclic model.",
      "doesNotProve": "A real pipeline's critical path, duration predictability, provider parallelism, capacity, or user lead time."
    },
    {
      "id": "LES-0025-CMD-011",
      "question": "Which modeled job permissions exceed an explicit least-privilege contract?",
      "risk": "read-only",
      "command": "python3 -c \"allowed={'test':{'contents:read'},'deploy':{'contents:read','id-token:write'}}; actual={'test':{'contents:read','packages:write'},'deploy':{'contents:read','id-token:write'}}; [print(j,'excess='+(','.join(sorted(actual[j]-allowed[j])) or '-'),'missing='+(','.join(sorted(allowed[j]-actual[j])) or '-')) for j in allowed]\"",
      "runFrom": "Any supported lesson shell; permission names and sets are synthetic",
      "expectedBranches": [
        {"when": "test shows excess=packages:write and deploy shows no excess or missing value", "meaning": "The modeled test job has unnecessary write authority while the deploy model equals its stated contract.", "nextEvidence": "Inspect event-specific effective permissions, token claims, environment policy, external role, and API audit records in the real system."}
      ],
      "proves": "Set differences between two synthetic expected and actual permission maps.",
      "doesNotProve": "A provider token's effective authority, credential exposure, external authorization, safe code, or absence of privilege escalation."
    },
    {
      "id": "LES-0025-CMD-012",
      "question": "Which common provider pipeline-definition files are visible near this repository root?",
      "risk": "read-only",
      "command": "find . -maxdepth 4 -type f \\( -name 'Jenkinsfile' -o -name '.gitlab-ci.yml' -o -path '*/.github/workflows/*.yml' -o -path '*/.github/workflows/*.yaml' -o -name 'azure-pipelines.yml' -o -name 'azure-pipelines.yaml' \\) -print | sort",
      "runFrom": "The established root of a reviewed repository; maxdepth intentionally bounds traversal",
      "expectedBranches": [
        {"when": "One or more paths print", "meaning": "Files with common provider naming patterns exist inside the displayed bounded scope.", "nextEvidence": "Read repository documentation and provider configuration to find entry points, generated configuration, external includes, multibranch definitions, and UI-owned settings."},
        {"when": "No paths print", "meaning": "No matching file was found within four levels under this directory.", "nextEvidence": "Do not conclude that no pipeline exists; inspect repository policy and provider-side configuration without broad or networked discovery."}
      ],
      "proves": "A bounded local filename and path-pattern search.",
      "doesNotProve": "Which pipeline is active, syntax validity, provider configuration, external templates, UI-defined jobs, review, or execution history."
    }
  ],
  "labs": [
    {
      "id": "LES-0025-LAB-001",
      "title": "Run two offline CI teaching engines and detect green output with declared-field drift",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with Bash, Python 3 standard library, coreutils, and the checked-in book/labs/LES-0025-ci-platform-operations controller, engines, job program, and JSON fixtures",
      "timeMinutes": 150,
      "privilege": "Normal user only; no sudo, root, Docker socket, provider token, service connection, credential, or administrative API",
      "network": "No network access is required or permitted by the exercise",
      "changes": ["Setup creates one exact per-UID state directory and one random private lab root below /tmp", "Two typed local schedulers create allowlisted build, artifact-store, and test workspaces plus digest-bound JSON evidence", "No service, package, port, provider, Docker socket, credential, cloud resource, production endpoint, or hosted-CI configuration is created or changed"],
      "abortConditions": ["The controller reports root execution, lock contention, a changed reviewed-source digest, invalid type, owner or mode, an unexpected path, or a record mismatch", "Any proposed command asks for sudo, a token, login, package installation, network access, secret, Docker socket, provider mutation, or writable system path", "The current directory is not the reviewed book/labs/LES-0025-ci-platform-operations directory"],
      "recovery": "Stop new engine runs, preserve non-sensitive refusal output, and use only bash lab.sh status followed by bash lab.sh cleanup from the reviewed source. If cleanup refuses an unexpected path or altered source, preserve state and restore the exact invariant before retrying; never delete by name pattern.",
      "cleanupProof": "bash verify.sh exercises the green mismatch, corrected contract, pre-existing-state preservation, unexpected-child refusal, exact nonrecursive allowlist cleanup, idempotent cleanup, and final state=absent with orphan_count=0. This proves the encoded local lifecycle, not provider cleanup or learner mastery.",
      "path": "book/labs/LES-0025-ci-platform-operations"
    },
    {
      "id": "LES-0025-LAB-002",
      "title": "Port an execution contract and lead a runner-upgrade incident review",
      "mode": "independent",
      "environment": "Provider-free written and in-memory exercise on Ubuntu 24.04 or WSL 2 Ubuntu 24.04",
      "timeMinutes": 180,
      "privilege": "Normal user only; no administrative access, hosted provider access, runner registration, plugin change, or credential",
      "network": "No network access is required or permitted",
      "changes": ["Only learner-authored answers in a separately chosen response location", "Optional copies of the synthetic Python models operate only in memory unless the learner deliberately records output", "No actual pipeline, runner, controller, plugin, environment, cloud resource, or deployment is changed"],
      "abortConditions": ["A proposed test would run untrusted code on a persistent worker", "A proposed validation needs a real secret, production endpoint, hosted-provider mutation, plugin installation, or fleet upgrade", "The learner cannot state source, scope, expected evidence, abort threshold, and cleanup for a proposed command"],
      "recovery": "Stop before any out-of-scope action. Mark the answer as an untested proposal and replace it with read-only evidence or a disposable, explicitly authorized future test plan.",
      "cleanupProof": "A reviewer compares the chosen response location before and after and verifies no provider or service mutation was authorized. There is no automated answer-grading verifier, isolated vendor platform, or hidden proof channel for this independent exercise; the guided engineering verifier does not score this submission.",
      "path": "book/labs/LES-0025-ci-platform-operations"
    }
  ],
  "incidents": [
    {
      "id": "LES-0025-INC-001",
      "signal": "Jobs for one workload class remain queued while the platform dashboard shows many runners or agents online.",
      "firstThought": "Do not add capacity yet. Ask whether any online worker lies inside the exact intersection of administrative scope, trust class, pool or group, required labels or tags or demands, architecture, protection, version, health, and available concurrency.",
      "safePath": "Freeze unrelated changes; capture queue age and job requirements; enumerate eligible workers rather than all workers; inspect heartbeats, busy state, quotas, concurrency locks, provisioning errors, and recent selector or policy changes; canary one reversible correction; prove recovery with accepted representative jobs and a falling backlog.",
      "trap": "Restarting every worker, removing selectors, routing protected jobs to an untrusted pool, or scaling a pool that is ineligible for the queued work."
    },
    {
      "id": "LES-0025-INC-002",
      "signal": "Many repositories begin failing after a runner image, agent binary, Jenkins plugin, controller, reusable workflow, included configuration, task, action, or shared-library change.",
      "firstThought": "Treat this as a shared-platform change until evidence narrows it; do not ask every application team to patch around the same new failure independently.",
      "safePath": "Identify the first failing shared identity and affected cohort; stop rollout; preserve successful and failing run evidence; route a representative job to the previous pinned pool or definition when safe; compare shell, tool, certificate, proxy, container, plugin dependency, permission, and workspace behavior; roll back or roll forward under an owned compatibility decision; expire any emergency pin deliberately.",
      "trap": "Fleet-wide reinstall, unbounded retry, silently floating to another version, disabling certificate or permission checks, or declaring recovery from one green trivial job."
    },
    {
      "id": "LES-0025-INC-003",
      "signal": "Untrusted change code executed on a self-hosted worker that can reach internal services or later runs trusted deployment work.",
      "firstThought": "Assume the worker, workspace, processes, writable caches, accessible credentials, and reachable trust paths may be compromised; job failure or workspace deletion is not containment.",
      "safePath": "Stop scheduling into the affected trust pool; revoke or expire exposed credentials and sessions through owners; isolate the worker without destroying evidence; identify event, code, worker image, attempts, network reach, caches, artifacts, and later jobs; rebuild from a trusted immutable image rather than cleaning in place; validate separation before restoring capacity.",
      "trap": "Reusing the worker after git clean, printing tokens for investigation, deleting evidence immediately, or assuming a container boundary protected the host and sibling workloads."
    },
    {
      "id": "LES-0025-INC-004",
      "signal": "A pipeline port is green on a second provider but deployment behavior, permissions, artifact identity, or cancellation differs from the original.",
      "firstThought": "A successful syntax translation proves only that some jobs ran. Reconstruct the execution contract field by field and identify the missing semantic rather than treating provider names as equivalents.",
      "safePath": "Compare trigger trust, configuration snapshot, source identity, dependencies, conditions, selectors, image, shell, permissions, reusable dependencies, cache key, artifact handoff, concurrency, timeout, retry, environment checks, and receipts; introduce one failing contract test per discovered gap; keep production authority off until equivalence evidence is reviewed.",
      "trap": "Copying YAML keywords mechanically, granting broad permissions to make the port pass, rebuilding the artifact, or calling two provider dashboards equivalent evidence."
    }
  ],
  "assessmentIds": ["ASM-0058", "ASM-0059", "ASM-0060"],
  "referenceIds": ["REF-0153", "REF-0154", "REF-0155", "REF-0156", "REF-0157", "REF-0158", "REF-0159", "REF-0160", "REF-0161", "REF-0162", "REF-0163"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "No GitHub Actions, GitLab CI/CD, Jenkins, or Azure Pipelines workflow was executed while authoring this lesson; provider examples remain reviewed definitions and concept mappings.",
    "The bounded lab executes the same portable build-and-test operation on two purpose-built local teaching engines. It observes artifact and graph output and compares declared permission, concurrency, timeout, secret, and network fields. Those declarations are not behaviorally enforced by the model, and provider-platform acceptance remains pending.",
    "The embedded Python and shell exercises model set matching, dependency timing, permission differences, artifact handoff, and local evidence only. They do not reproduce GitHub, GitLab, Jenkins, or Azure schedulers, isolation, permissions, outages, retries, approvals, or billing.",
    "Provider features, defaults, hosted images, task and action versions, plugin dependencies, interfaces, security guidance, and licensing can change. Verify current official documentation and the exact organization configuration before production use.",
    "YAML and Pipeline examples are illustrative and deliberately omit organization-specific identities, credentials, endpoints, runners, service connections, deployment commands, and secrets.",
    "Self-hosted isolation claims require platform, operating-system, hypervisor or container runtime, network, credential, and threat-model evidence. Ephemeral naming or workspace cleanup alone is not proof of isolation.",
    "The guided dual-engine lifecycle has an automated engineering verifier, but the independent exercise has no answer-grading verifier, hidden tests, or controlled provider environment. A qualified reviewer must score the reasoning and must not infer mastery from publication or reading progress.",
    "The canonical assessment and reference records are registry-backed, but publication does not prove provider execution, formal review, independently scored transfer, delayed recall, or mastery."
  ]
}
---

# CI platform operations: run GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines safely

## What you see and first thought

The dashboard says **47 jobs queued**. Eleven runners are online. The natural reaction is, “We need more runners.” Pause there.

The useful first question is not “How many runners exist?” It is:

> **How many healthy, available workers are eligible for this exact job, at this exact moment, under this exact trust policy?**

That one sentence changes the incident. Ten Linux workers do not help an `arm64` job. Ten untrusted workers do not help a protected deployment. Ten agents in another pool do not help this project. Ten online workers with zero free executors do not provide capacity. Ten workers advertising an old tool capability may be rejected by a new demand. A platform-wide green status page does not prove that the intersection for your workload is non-empty.

Now imagine a different screen. A pipeline ported from GitHub Actions to GitLab is green. It looks like success. Yet the original job had read-only repository permission, used a reviewed reusable workflow, cancelled older branch runs, uploaded one immutable artifact, and required a protected environment. The port uses a floating include, a broadly privileged token, no concurrency guard, a cache in place of an artifact, and an ordinary runner. Similar YAML has hidden a different system.

Whenever you meet a CI platform, hold two ideas at once:

1. **The mechanism is portable.** An event and exact configuration create a graph; a scheduler finds an eligible execution environment; an attempt runs; evidence and artifacts leave the worker; authorization controls external effects.
2. **The contract is provider-specific.** Defaults, selectors, permissions, reusable code, cancellation, retries, approvals, caches, artifacts, upgrades, and administrative scope are not interchangeable just because the screen uses the words “pipeline” and “runner.”

This lesson compares GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines. The aim is not to crown a winner. The aim is to make you the engineer who can enter any of them, locate state ownership, translate intent, detect a broken trust boundary, and prove what happened.

### The five questions to carry into every CI incident

Ask them in this order:

1. **What exact event, source revision, and pipeline-definition revision created this run?**
2. **What job is waiting or failing, and what dependencies and conditions put it in that state?**
3. **Which workers are actually eligible, healthy, available, and trusted for that job?**
4. **What authority, network, workspace, cache, and reusable code can that attempt influence?**
5. **What evidence proves recovery for the user-facing delivery path, not merely for the dashboard?**

If evidence is missing, say “unknown.” Unknown is an operational state. It is far safer than filling a blank with a confident story.

### What this chapter will and will not do

It will give you a provider-neutral architecture, a provider mapping, command decoders, portable contract examples, queue and upgrade incident paths, and local exercises. It will not log in to a provider, register a worker, install Jenkins, create a token, or pretend that an in-memory Python model is a real scheduler. The difference between a model and a production proof is repeated deliberately because advanced engineering begins with honest evidence boundaries.

## Terms before commands

Read these terms as working tools, not vocabulary to memorize.

### Short forms and platform words used in this chapter

| Term | Meaning here |
|---|---|
| API | **Application programming interface**: a machine-facing contract used to read or change another system's state. |
| ARM64 and x64 | Common provider architecture labels. ARM64 is the 64-bit Arm architecture family; x64 usually means the 64-bit x86 architecture family. Verify the exact provider and binary contract rather than assuming label equivalence. |
| CD | **Continuous delivery** means keeping a change releasable through automation and controlled decisions. **Continuous deployment** means qualifying changes advance automatically. State which meaning you intend. |
| CPU and GPU | **Central processing unit** and **graphics processing unit**. A visible count does not prove dedicated capacity or performance. |
| DNS | **Domain Name System**, which maps names to records used to locate services. |
| OCI | **Open Container Initiative**, whose specifications include standard container image and runtime formats. |
| OIDC | **OpenID Connect**, an identity layer commonly used for short-lived workload federation. |
| OS | **Operating system**, such as Linux, Windows, or macOS. |
| p50 and p95 | The 50th and 95th percentiles. p50 is the median observation; p95 is the value at or below which 95 percent of observations fall for the stated population and window. |
| SHA-256 | **Secure Hash Algorithm 256-bit**, used here to demonstrate content fingerprints; a digest alone does not prove trust or safety. |
| UI | **User interface**, such as a provider web console. It is one view of control-plane state. |
| WSL | **Windows Subsystem for Linux**, the Windows feature that provides a Linux execution environment. |
| YAML | A human-readable data-serialization format commonly used for pipeline definitions. Similar-looking YAML does not guarantee equal provider behavior. |
### Continuous integration platform

A **continuous integration (CI) platform** accepts delivery events, selects pipeline configuration, expands work into jobs, applies policy, schedules attempts, stores evidence, and exposes control interfaces. It may also coordinate deployment, but “CI platform” does not mean that every deployment decision belongs inside the same product.

The platform is a distributed system. A web page is only one view of it.

### Control plane and execution plane

The **control plane** owns desired and recorded orchestration state: the run, graph, conditions, queue, policy decisions, worker registration, logs metadata, and API view. The **execution plane** is where build and test code actually runs: a GitHub runner, GitLab Runner executor, Jenkins agent executor, or Azure Pipelines agent.

This separation matters during failure. If the dashboard cannot update, a worker process may still be running. If a worker loses contact after an external API accepted a request, the controller may report a timeout while the effect exists. Stopping a control-plane record does not automatically stop every child process or reverse an external side effect.

### Pipeline, workflow, run, job, and attempt

- A **pipeline definition** or **workflow definition** is configuration plus referenced reusable code.
- A **logical run** is one orchestration instance created for an event and configuration snapshot.
- A **job** is a graph node with dependencies, conditions, environment requirements, and authority.
- An **attempt** is one execution of a job or run. Retry creates another attempt; it does not erase the first attempt's external effects.
- A **step** is an ordered unit within a job. Steps commonly share one workspace and job credential context, so a malicious early step can affect later steps.

Do not use “build 812” as the only identity. Record provider, organization or instance, repository or project or folder, pipeline, logical run, attempt, job, and worker.

### Runner, agent, executor, node, and worker

These words overlap but are not exact synonyms:

- **GitHub Actions:** a runner application executes one assigned job. GitHub-hosted and self-hosted models differ. Runner groups control access; labels express selection dimensions.
- **GitLab CI/CD:** GitLab Runner is the agent software. An **executor** defines how it runs jobs, such as shell, Docker, or Kubernetes. Tags participate in matching; protection and scope also matter.
- **Jenkins:** the controller schedules Pipeline work onto **nodes**. An **agent** connects a node to the controller. A node can expose one or more **executors**, allowing concurrent workspaces or tasks depending on configuration. Labels select nodes.
- **Azure Pipelines:** an **agent** belongs to a pool. A job targets a pool and may declare **demands** that must match advertised agent capabilities. Microsoft-hosted and self-hosted agents have different lifecycle responsibilities.

In this lesson, **worker** means the execution resource generically. When behavior is provider-specific, the provider term is used.

### Hosted, self-hosted, persistent, and ephemeral

A **hosted worker** is supplied and lifecycle-managed by the provider under its published contract. It reduces fleet operations but does not remove security design, dependency pinning, egress, cost, or evidence work.

A **self-hosted worker** is operated in an environment you control. That grants network and toolchain flexibility while making you responsible for patching, registration secrets, images, isolation, scaling, logs, certificates, proxies, cleanup, and incident response.

A **persistent worker** survives multiple jobs. It can reduce provisioning time and preserve caches, but residue can cross attempts: files, processes, mounts, credentials, sockets, containers, compiler state, or hostile persistence.

An **ephemeral worker** is registered or provisioned for a bounded lifetime, ideally one job, then destroyed. “Ephemeral” is a lifecycle claim, not an isolation proof. If it shares a host kernel, privileged socket, writable image, identity source, network path, or cache with another trust class, risk remains.

### Selector, label, tag, capability, and demand

A **selector** is the generic requirement a job uses to narrow eligible workers.

- GitHub jobs can select using `runs-on` labels and, where configured, runner groups.
- GitLab jobs use tags; the runner must satisfy the tag requirements and also be allowed for the project and ref type.
- Jenkins uses node labels and label expressions; available executors and node state still determine dispatch.
- Azure Pipelines uses pools plus capabilities and demands; a self-hosted agent advertises system and user capabilities.

Selectors answer **where work is allowed to run**. They do not prove that the label is truthful, the image is patched, the workspace is clean, or the worker is safe.

### Administrative scope and trust class

**Administrative scope** answers which repositories, projects, folders, organizations, or groups may use a worker or reusable definition. **Trust class** answers what kind of code and authority may meet there.

Useful trust classes include:

- untrusted fork or external contribution validation;
- ordinary branch build;
- protected branch release build;
- production deployment;
- privileged infrastructure administration.

Do not collapse them into a single “linux” pool. Operating system is not a trust boundary.

### Configuration snapshot and reusable dependency

A run must be explainable using the pipeline configuration it actually resolved. That includes more than the repository’s visible YAML:

- GitHub reusable workflows and actions;
- GitLab includes, components, and templates;
- Jenkins Shared Libraries, plugins, controller configuration, and job definitions;
- Azure YAML templates, tasks, variable groups, environments, service connections, and checks.

A **reusable dependency** is executable delivery logic. Pin it, review it, control who can change it, and preserve the resolved identity. A floating branch or mutable version can make yesterday’s rerun execute today’s logic.

### Cache and artifact

A **cache** is an optimization. It may be missing, stale, evicted, restored by a fallback key, or written by another attempt depending on policy. Correctness must not depend on a cache being present.

An **artifact** is an output intended for later consumption or evidence. A release artifact needs immutable content identity, controlled writers, retention, and traceability. “Uploaded successfully” does not prove safety or authenticity.

If deleting a thing should only make the next build slower, it behaves like a cache. If deleting or replacing it changes what you release, audit, or promote, it needs artifact-grade controls.

### Concurrency, capacity, utilization, and queue age

- **Concurrency** is the number of attempts allowed to execute simultaneously under a worker, pool, organization, licensing, quota, or pipeline rule.
- **Capacity** is useful work the eligible execution system can complete per unit time under actual job mix.
- **Utilization** is occupied capacity divided by available capacity for a carefully defined pool and window.
- **Queue age** is time from ready-for-dispatch until accepted by an eligible worker. Do not mix approval wait, dependency wait, scheduled start, and runner queue without labeling them.

One busy hour does not justify permanent capacity. One low average does not refute a painful p95 queue. Partition by trust class, architecture, workload size, and time window.

### Drain, canary, rollback, and roll-forward

To **drain** a worker means stop accepting new work while allowing or deliberately handling in-flight work. A **canary pool** receives a small, selected workload on the candidate version. **Rollback** returns to a prior known-compatible identity. **Roll-forward** applies a corrected newer identity when rollback is unsafe, unsupported, or would restore a known vulnerability.

The plan needs decision criteria before rollout, not during panic.

### SLI, SLO, SLA, and error budget

- A **service-level indicator (SLI)** is a measured behavior, such as the fraction of ready jobs accepted within two minutes.
- A **service-level objective (SLO)** is the target for that indicator over a window.
- A **service-level agreement (SLA)** is an external commitment with business or contractual consequences; it is not merely another dashboard threshold.
- An **error budget** is the allowed unreliability implied by an SLO. It helps decide when feature velocity must yield to reliability work.

For CI platforms, useful SLIs include configuration-evaluation success, queue age, job-start success, log availability, artifact upload success, runner registration health, and successful representative end-to-end workflows. A single global success rate can hide a completely broken protected pool.

## Architecture map

Start with the invariant system, then map provider names onto it.

```text
                 CONTROL PLANE

 event ---> config resolver ---> graph + policy ---> scheduler / queue
   |             |                    |                   |
   |             |                    |                   +--> eligibility evidence
   |             |                    +--> jobs, needs, conditions, permissions
   |             +--> exact YAML / Jenkinsfile / templates / libraries / plugins
   +--> actor, ref, source revision, trust, event payload identity

                                      assignment
                                          |
                                          v
                 EXECUTION PLANE

              worker registration ---> job attempt
                     |                        |
              image/version/labels           +--> workspace + processes
              pool/trust/network             +--> job credential / workload identity
                                              +--> cache read/write
                                              +--> artifact + logs + test evidence
                                              +--> external side effects

                                          |
                                          v
                 DELIVERY / EVIDENCE PLANE

             artifact store ---> policy / approval ---> environment / deploy target
                    |                    |                         |
              immutable digest      principal + intent       runtime + user evidence
```

Text alternative: an event and exact configuration enter a control plane. The platform resolves a dependency graph and permissions, then a scheduler matches each ready job to an eligible worker. The worker runs an attempt with a workspace, process tree, credential, network, caches, and output channels. Artifacts, policy, approvals, deployment targets, telemetry, and user results continue beyond the job boundary.

### Provider vocabulary map

| Mechanism | GitHub Actions | GitLab CI/CD | Jenkins | Azure Pipelines | Operational question |
|---|---|---|---|---|---|
| Entry configuration | workflow YAML under `.github/workflows` | `.gitlab-ci.yml` plus includes | `Jenkinsfile`, job configuration, Shared Libraries | YAML pipeline plus templates, or classic UI definition | Which exact resolved configuration did this run use? |
| Control-plane unit | workflow run | pipeline | build or Pipeline run | pipeline run | Which logical run and attempt are we observing? |
| Graph work unit | job | job | stage/step/node allocation within Pipeline | stage, job, step | Which dependencies and conditions made it ready, skipped, or blocked? |
| Generic worker | runner | GitLab Runner plus executor | agent/node plus executor | agent | Which software, host/image, trust pool, and workspace ran the attempt? |
| Selection | `runs-on`, labels, runner group | tags, scope, protected status, executor | label expression, node state, executor availability | pool, capabilities, demands | Is the eligible intersection empty? |
| Reusable logic | reusable workflow, action | include, component, template | Shared Library, plugin, shared job code | YAML template, task, extension | Is every executable dependency reviewed and immutably identified? |
| Optimized reuse | cache | cache | cache plugin or external mechanism; workspace reuse is not a safe cache contract | pipeline cache | Can it disappear without changing correctness? |
| Output handoff | artifact | artifact | archived artifact or external repository | pipeline/build artifact | Is content immutable, attributable, retained, and verified by consumers? |
| Protected transition | environment protection and deployment controls | protected environments and deployment controls | authorization, input/gate/plugin or external policy | environments plus approvals and checks | Is authorization outside untrusted job control and bound to immutable intent? |
| Concurrency control | workflow/job concurrency and platform limits | resource groups plus instance/group/project limits | executors, throttling/lock mechanisms, queue policy | pool parallelism, exclusive lock/checks, pipeline controls | What serializes work, and what happens on cancellation? |

This table is a map, not a compatibility promise. For example, a GitHub label, GitLab tag, Jenkins label, and Azure capability all help select workers, but their administrative scope, truth source, expression semantics, and protection rules differ.

### State ownership map

| State | Usual owner | Evidence to capture | Common false assumption |
|---|---|---|---|
| Event and actor | source/provider event service | event type, actor, ref, payload or delivery identity, trust class | “A branch name proves the source and trust.” |
| Resolved pipeline | provider control plane | pipeline revision, resolved includes/templates/libraries/actions/tasks/plugins | “The current file is what the old run used.” |
| Job graph | provider control plane | jobs, dependency edges, conditions, skipped/cancelled reasons | “File order equals execution order.” |
| Queue | scheduler/control plane | ready timestamp, requirements, eligible workers, assignment timestamp | “Online runner count equals capacity.” |
| Worker registration | platform and fleet controller | worker ID, pool/group, labels/tags/capabilities, version, heartbeat | “Registered means healthy and safe.” |
| Workspace/process state | execution environment | image digest, attempt, paths, mounts, process tree, cleanup result | “The provider cleaned everything.” |
| Job credential | provider and external identity owner | effective permissions, claims, scope, expiry, audit decision | “The YAML permission line is the entire authority.” |
| Cache | cache service and namespace policy | exact key, restore key, hit source, writer, content check where available | “A hit means correct dependencies.” |
| Artifact | artifact repository | subject digest, producer, upload receipt, retention, readback | “A tag or filename is immutable.” |
| Environment gate | environment/policy owner | policy version, reviewer or principal, approved digest and intent, time | “Green CI authorizes production.” |
| External effect | target system | stable operation ID, desired state, accepted/completed state, user result | “Job timeout means nothing changed.” |

### The platform is part of the software supply chain

CI is not a neutral courier. It can read source, create artifacts, sign evidence, retrieve secrets, assume external roles, alter infrastructure, and deploy production. Therefore:

- pipeline configuration is code;
- reusable workflow and template repositories are privileged dependencies;
- runner images and agent binaries are build inputs;
- Jenkins plugins and Azure/GitHub marketplace tasks or actions are executable supply-chain dependencies;
- controller configuration, organization policy, runner groups, protected resources, and service connections are production configuration;
- logs, caches, artifacts, and workspaces are data stores with retention and access policy.

The blast radius of a shared template can exceed the blast radius of an application change because hundreds of repositories consume it. Review and rollout should match that reality.

## Request or state path

Trace one branch update without skipping identities.

### 1. The event enters

A push, pull request, merge request, schedule, manual dispatch, API call, upstream pipeline, or repository event arrives. Record:

- provider and organization or instance;
- repository/project/folder;
- event type and delivery identity;
- actor and trust classification;
- full source revision and ref;
- whether code comes from a fork or external contributor;
- time as observed by the event owner.

The event name is security input. A pull request from an untrusted fork and a protected-branch push must not inherit the same credentials and network merely because both execute tests.

### 2. Configuration is selected and expanded

The control plane selects an entry definition and resolves reusable dependencies. Preserve both source and pipeline identities. They may differ: a protected default-branch workflow can evaluate code from another revision; an included template can live in another repository; a Jenkins Shared Library can be configured outside the `Jenkinsfile`; an Azure environment check can be owned outside YAML.

Expansion creates jobs, dependencies, matrix variants, conditions, environment references, permissions, timeouts, and concurrency keys. A configuration error can fail before any worker is involved. That distinction prevents pointless runner restarts.

### 3. Jobs become ready

A job is not queue-ready merely because the run exists. Dependencies must reach qualifying states, conditions must evaluate, approvals or manual rules may apply, and concurrency controls may block it. Label timestamps explicitly:

```text
event_received
configuration_evaluated
job_created
dependencies_satisfied
job_ready_for_worker
worker_assigned
attempt_started
attempt_finished
artifact_available
environment_authorized
external_operation_accepted
user_verification_complete
```

If you call the entire interval “queue time,” you cannot tell whether to fix graph design, approval policy, scheduler capacity, provisioning, or the job itself.

### 4. The scheduler computes eligibility

Conceptually, eligibility is an intersection:

```text
eligible(job) =
    workers_allowed_by_administrative_scope
  ∩ workers_allowed_for_event_trust_and_ref_protection
  ∩ workers_in_requested_pool_group_or_executor_class
  ∩ workers_satisfying_all_required_labels_tags_or_demands
  ∩ workers_with_compatible_architecture_and_runtime
  ∩ workers_online_healthy_and_enabled
  ∩ workers_with_free_concurrency_under_quota
```

The real providers do not necessarily calculate in this textual order. The equation is a diagnostic model: enumerate each predicate and find the first one that empties the set.

### 5. A worker accepts one attempt

Capture worker identity and version, image or host identity, executor type, workspace path, attempt number, selected shell, environment, effective credential source, network class, and time. Then source and reusable code are acquired according to platform behavior.

This is where configuration becomes arbitrary code. Every action, task, plugin step, package script, test hook, build tool, and repository script now runs with some combination of:

- filesystem access;
- process execution;
- job token or credential access;
- network reachability;
- cache and artifact access;
- host or container control interfaces;
- access to later steps through shared workspace state.

The security boundary must be designed before the code arrives.

### 6. Inputs are restored and work runs

The job may restore a cache, download upstream artifacts, fetch packages, start service containers, compile, test, scan, or package. Record the immutable identities of meaningful inputs. A green outcome is interpretable only when you can reconstruct what ran.

On persistent workers, begin from a fresh, owned workspace or prove cleanup. `git --no-optional-locks status` avoids Git's optional background index refresh and is one evidence source, not a host-integrity check. It does not see ignored files, hostile processes, modified tools outside the repository, mounted sockets, or credentials already copied elsewhere.

### 7. Outputs leave the worker

Logs stream during execution; test results, annotations, caches, artifacts, provenance, and coverage may upload. Each output has a different trust and retention purpose.

Ask:

- Who could write it?
- What immutable run, job, attempt, source, configuration, and worker identify the producer?
- Is upload completion acknowledged?
- Can another run overwrite or shadow it?
- Can untrusted code poison a namespace later read by trusted work?
- Is sensitive content filtered before upload?
- What proves that a consumer read the expected digest?

### 8. Environment authorization and external effects continue

Deployment permission may depend on an environment, protected ref, approval, check, service connection, credential binding, or external policy. Keep the authorization owner outside the code being authorized where the provider supports it.

The deployment target owns the external operation. If the job times out after target acceptance, query the target by a stable operation or release identity. Do not infer absence from the CI job state and do not replay blindly.

### 9. Recovery is proved across the path

A recovered CI platform accepts representative work from each affected trust and architecture class, runs it on the intended pool, produces and retrieves evidence, and reduces the backlog. A recovered delivery path additionally promotes the expected immutable artifact, observes the target state, and verifies a real user operation over a defined window.

## Failure zoom

### Incident A: online workers, zero eligible workers

The alert says queue age exceeded ten minutes for protected releases. The fleet page shows eleven online workers and 18 percent overall utilization. That evidence is compatible with an empty eligible set.

```text
protected release job
  requires: linux + x64 + release-tools + trusted-prod
  scope: payments repository
  ref: protected main

workers online:
  r01-r04  linux + x64 + release-tools + untrusted       rejected: trust class
  r05-r07  linux + arm64 + release-tools + trusted-prod  rejected: architecture
  r08-r10  linux + x64 + trusted-prod                    rejected: missing release-tools
  r11      linux + x64 + release-tools + trusted-prod    rejected: repository access removed

eligible intersection = empty
```

Adding ten more workers cloned from `r01` adds zero protected-release capacity. Removing `trusted-prod` makes the queue move by destroying the intended boundary. The safe correction is to restore a qualified worker or correct the mistaken scope or selector under review, canary it, and prove that the protected job lands only in the intended pool.

#### Provider-specific places to look

- **GitHub Actions:** inspect the job's `runs-on`, runner group access, repository or organization assignment, labels, runner status, and concurrency. Default self-hosted labels commonly describe `self-hosted`, operating system, and architecture, but custom labels and group access still matter. A label is not an attestation.
- **GitLab CI/CD:** inspect every job tag, runner scope, whether untagged jobs are allowed, runner protection, project enablement, executor, online or paused state, and concurrency. A runner must satisfy the job's tag requirements; seeing one shared runner tag is not enough.
- **Jenkins:** inspect the Pipeline's label expression, node online and temporarily-offline causes, executor count, queue blockage reason, folder or job authorization, cloud provisioning, and any lock or throttle. A connected agent can have all executors busy or no matching label.
- **Azure Pipelines:** inspect the pool, demands, agent capabilities, enabled or online state, parallel-job allowance, environment checks, and exclusive locks. On self-hosted agents, newly installed software may not appear as a capability until the agent process is restarted; restarting is a controlled change, not the first diagnostic command.

#### Contain before correcting

During pressure, teams often broaden selectors or permissions. That changes the blast radius while evidence is weakest. Prefer these bounded controls:

1. pause the affected promotion path if jobs could land on an unsafe pool;
2. preserve job requirements, queue reason, eligible-worker inventory, and recent configuration changes;
3. canary one corrected worker or selector with no broader authority than required;
4. send a representative non-destructive job;
5. confirm assignment, execution image, credential class, output path, and backlog slope;
6. restore capacity in waves and expire temporary exceptions.

### Incident B: the shared dependency moved

At 10:02, builds in 68 repositories begin failing with `command not found`. Application commits are unrelated. At 09:58, a shared runner image tag was updated. At 09:59, a reusable template's default branch also changed. Which caused the outage?

Do not choose from timing alone. Preserve identities:

```text
successful cohort:
  runner_image_digest = sha256:old
  reusable_config_revision = 2f8...
  agent_version = A
  task/action/plugin set = S1

failing cohort:
  runner_image_digest = sha256:new
  reusable_config_revision = 9bd...
  agent_version = A
  task/action/plugin set = S1
```

If old and new variables changed together, route a representative workload through controlled combinations. Do not mutate production attempts to create a science experiment. Use an isolated canary without production credentials:

```text
old image + old config -> control
new image + old config -> tests image change
old image + new config -> tests config change
new image + new config -> observes interaction
```

Each cell needs the same source revision, inputs, architecture, and expected assertions. This is why immutable image and configuration identities are operational features, not paperwork.

### Incident C: untrusted code met a trusted worker

A fork pull request ran on a persistent self-hosted worker. That worker can reach an internal package registry and later runs protected deployment jobs. The pull request failed before tests.

Failure does not reduce the security concern. Arbitrary code may have run before the failing step. Treat the potential exposure path as:

```text
untrusted source
    |
    +--> workspace residue / modified tool / background process
    +--> job token and environment
    +--> metadata or workload-identity endpoint
    +--> writable cache or artifact namespace
    +--> Docker or container-runtime socket
    +--> internal network and service discovery
    +--> credentials left for a later trusted job
```

Contain the pool. Revoke or let short-lived credentials expire under owner control. Preserve worker, job, process, network, cache, and artifact evidence. Rebuild from a trusted immutable image; do not clean a potentially compromised host back into service. Investigate later jobs that used the same state or consumed its writable outputs.

The best prevention is architectural: do not let untrusted contributions reach persistent workers with internal access or later trusted authority. Use a dedicated trust pool with minimal network and credentials, preferably a fresh execution resource per job. For public repositories, official GitHub guidance specifically warns that forked pull requests can execute dangerous code on self-hosted runners. Equivalent threat reasoning applies across providers.

### Incident D: a plugin or platform upgrade breaks the fleet

Jenkins makes the shared-dependency problem unusually visible because controller core, plugins, Shared Libraries, agents, Java runtime, and job definitions interact. A plugin upgrade can introduce dependency requirements, change Pipeline behavior, require a restart, or make rollback difficult if stored configuration migrated.

The safe lifecycle is:

```text
inventory -> compatibility review -> backup and restore proof -> pinned test controller
          -> representative job suite -> canary users -> bounded rollout
          -> verify -> retain or retire rollback path
```

Do not equate plugin-file restoration with rollback. The controller may have written newer configuration or data. Document whether the supported recovery is rollback, controller restore, or roll-forward.

Other providers hide more of the control plane, but the dependency problem remains. A hosted image changes. An action or task release moves. A template's default branch changes. An agent auto-update introduces new behavior. The response pattern—identify, canary, compare, bound, verify—still applies.

### Incident E: cancellation did not cancel the effect

A developer pushes commit B shortly after commit A. The platform cancels A's older run. A's deployment step had already sent an accepted request, but its worker stopped before recording the operation ID. B starts and sends another deployment.

You now have two logical release intents unless the target enforces idempotency or supersession.

CI cancellation means the platform requested a state transition for an attempt. It does not prove:

- a child process stopped;
- a service container stopped;
- an application programming interface (API) request was rejected;
- a deployment controller abandoned accepted work;
- a database migration reversed;
- a message was not published;
- a cloud resource was not created.

Persist stable release intent before the external call. Bind the artifact digest and target. Send a stable idempotency or operation key when supported. On timeout or cancellation, query the target state owner. Allow a new run to supersede only under a defined policy, and reconcile the old operation.

### Failure tree: queued is a symptom, not a diagnosis

```text
job not running
|
+-- not ready
|   +-- dependency incomplete/failed/skipped
|   +-- condition false or evaluation error
|   +-- approval/manual gate waiting
|   +-- concurrency/resource/environment lock
|
+-- ready, eligible set empty
|   +-- wrong pool/group/scope
|   +-- missing label/tag/capability/demand
|   +-- architecture/runtime mismatch
|   +-- protected/unprotected trust mismatch
|
+-- eligible workers exist, none available
|   +-- offline/disabled/unhealthy/expired registration
|   +-- every executor busy
|   +-- organization/provider quota reached
|   +-- autoscaler provisioning slow or failing
|
+-- assigned, attempt not starting
|   +-- image pull or bootstrap failure
|   +-- workspace/disk/inode/permission failure
|   +-- certificate/proxy/DNS/control-plane connectivity
|   +-- agent version or protocol mismatch
|
+-- attempt starts, service time explodes
    +-- dependency latency/outage/throttle
    +-- cache miss or poison recovery
    +-- test contention/flakiness/retry amplification
    +-- CPU/memory/storage/network saturation
```

Every branch has different owners and containment. Restarting runners destroys useful state and touches only a few branches.

## Internals and state ownership

### Scheduler matching is a set problem plus a queue policy

The in-memory command later demonstrates set inclusion: job requirements must be a subset of worker attributes. Real scheduling adds administrative and dynamic state.

Suppose a ready job requires `{linux, x64, gpu, protected}`. A worker advertises `{linux, x64, gpu, protected}`. It can still be ineligible because:

- its group is unavailable to the repository;
- its runner is disabled, paused, or not assigned to the project;
- the job originates from a ref the worker may not serve;
- the worker is offline or its registration has expired;
- no executor or concurrency slot is available;
- a provider quota is exhausted;
- another exclusive lock owns the resource;
- a policy denies that event or environment;
- the labels are stale and the tool is absent.

Then, among eligible workers, a scheduler chooses according to provider policy and availability. Do not assume first-in-first-out globally. Fairness, repository weights, shared versus specific runners, provisioning delay, priority, resource groups, and concurrency rules can affect order.

### Queue mathematics without pretending the workload is simple

Use a basic relationship as a reasoning aid:

```text
offered_work_per_minute = arrival_rate_jobs_per_minute x mean_service_minutes
required_parallel_capacity ~= offered_work_per_minute / target_utilization
```

If 3 eligible jobs arrive per minute, mean worker occupancy is 4 minutes, and target utilization is 0.70:

```text
offered work = 3 x 4 = 12 concurrent-worker-minutes per minute
rough capacity = 12 / 0.70 = 17.14, so at least 18 equivalent slots
```

This is not a capacity plan. CI service times are often heavy-tailed; workloads need different architectures and trust pools; matrix fan-out creates bursts; licenses and quotas intervene; autoscalers have cold-start delay; retries amplify arrival rate; and external dependencies correlate failures. Use percentiles, arrival distributions, class-specific pools, observed saturation, and a queueing or simulation model appropriate to the risk.

Watch **backlog slope**:

```text
backlog_change ~= arrivals - successful_dispatches_or_completions
```

If backlog is still rising after recovery, capacity or service rate still trails demand. If it falls only because jobs were cancelled, user work may remain incomplete.

### GitHub Actions internals that change operations

#### Workflow and reusable-workflow boundary

Workflow files live under `.github/workflows`. A job can call a reusable workflow or steps can call actions. Treat every referenced action and reusable workflow as executable code. Pin high-trust dependencies to immutable revisions where possible, review update automation, and preserve resolved identities.

Permission analysis must include:

- event type, especially fork contribution behavior;
- workflow- and job-level token permissions;
- secrets availability and inheritance;
- environment protection;
- reusable workflow caller and callee boundaries;
- OpenID Connect (OIDC) token claims and external trust policy;
- runner network and local credential sources.

Setting `contents: read` does not constrain a cloud role assumed later. The effective authority is the union of every credential path the code can reach.

#### Runner groups and labels

Runner groups provide an access boundary; labels describe selection attributes. Use groups for administrative and trust separation and labels for capabilities. A string like `prod` should not be your only production boundary if any repository can attach or target it.

Hosted runners normally provide a fresh provider-managed virtual environment under the service contract. Self-hosted lifecycle, patching, isolation, registration, and cleanup remain your responsibility. An autoscaled self-hosted runner should be registered just in time, accept a bounded workload, stream evidence externally, and be destroyed from a trusted controller. Preserve enough metadata to investigate without retaining a compromised writable disk indefinitely.

#### Concurrency and cancellation

Concurrency can prevent overlapping work and optionally cancel an in-progress run. Design the group key around the resource being protected: branch validation, environment, release train, or stateful target. A key that is too broad serializes unrelated work; one that is too narrow permits races.

Cancellation is cooperative across platform and process boundaries. External operations still need stable identity and reconciliation.

### GitLab CI/CD internals that change operations

#### Configuration includes are run dependencies

GitLab can combine local and external configuration through includes. The resolved configuration is a dependency snapshot for the pipeline. Exact immutable revisions reduce drift; protected ownership limits who can change shared logic. Understand when a job retry reuses an existing pipeline configuration and when creating a new pipeline resolves dependencies again. Do not describe all reruns as identical.

Jobs form stages and can use explicit `needs` relationships. `needs` can shorten the critical path by starting a job as soon as required predecessors finish rather than waiting for an entire stage. That speed changes artifact and failure assumptions: specify which upstream outputs each job needs.

#### Runner scope, tags, protection, and executors

GitLab Runner accepts jobs through an executor. Shell, Docker, and Kubernetes executors create very different isolation, image, workspace, networking, and cleanup boundaries. Naming a runner `docker` does not prove its Docker daemon is isolated; access to a privileged or shared daemon may expose the host and other builds.

Tags filter matching. Scope and protection restrict use. Build a diagnostic row for every requirement:

| Requirement | Job asks | Runner advertises or allows | Result |
|---|---|---|---|
| Project, group, or instance scope | project A | runner enabled for group B only | reject |
| Tags | `linux`, `x64`, `trusted` | `linux`, `x64` | reject |
| Organization release trust contract | `protected-release` tag and approved dedicated scope | general runner lacks the required tag or approved scope | reject by the explicit selector or organization policy |
| Executor or runtime | container build need | shell executor | may be semantically wrong even if matched |
| Availability | ready | paused or concurrency full | wait |

GitLab's **Protected** runner setting limits that protected runner to jobs on protected branches or protected tags. It does not, by itself, mean every unprotected runner is automatically ineligible for a protected-ref job. If your organization requires protected work to use a dedicated runner class, encode and audit that requirement with runner scope, a dedicated job tag such as `protected-release`, protected-runner configuration, and project policy. Diagnose the complete contract rather than inventing a reverse matching rule.

`resource_group` can serialize jobs that act on the same resource. It is not a substitute for target-side idempotency or durable locking, because external work can outlive the CI attempt.

### Jenkins internals that change operations

#### Controller, queue, nodes, agents, and executors

The Jenkins controller owns job configuration, Pipeline orchestration, queue state, plugin behavior, credentials integration, and much operational metadata. Agents execute allocated work. Avoid running ordinary builds on the controller: it expands attack surface and resource contention around the state owner.

A node can have multiple executors. More executors increase concurrency but also workspace overlap risk, CPU, memory, and storage contention, and noisy-neighbor effects. Executor count is not a harmless throughput knob. Measure job profile and isolate workloads that assume exclusive host state.

Pipeline durability behavior, controller storage, backup, and restore matter. A restarted controller may resume Pipeline state differently from a stateless hosted control plane. Test controller restart, agent disconnect, and artifact or log behavior in an approved environment.

#### Shared Libraries and trust

Jenkins Shared Libraries can centralize safe patterns, but library trust is a privilege boundary. A globally trusted library can access powerful internal APIs; write access to its source can therefore become broad Jenkins authority. Use the least-trusted library mode that supports the requirement, protect the source repository, pin reviewed versions, and separate library maintainers from casual application change where risk warrants it.

Library code should expose small, reviewed interfaces rather than hiding an entire deployment system behind magic. The calling `Jenkinsfile` should make authority, artifact identity, target, timeout, and expected evidence visible.

#### Plugins and upgrades

Plugins execute inside the controller and extend security-sensitive behavior. Maintain:

- controller core, Java, agent, plugin, and operating-system inventory;
- plugin dependency graph and reason for installation;
- security advisory ownership;
- pinned update candidate and compatibility test results;
- backup plus restore proof;
- canary controller or representative test environment;
- restart and downtime plan;
- rollback or roll-forward boundary;
- removal plan for unused plugins.

Latest is not a reproducible configuration. Never upgrade accumulates known vulnerabilities and incompatibility. Safe operation lives between those failures.

### Azure Pipelines internals that change operations

#### Pools, capabilities, and demands

An Azure Pipelines agent belongs to a pool. A job selects a pool and can declare demands. Self-hosted agents advertise system capabilities and optional user capabilities. Capabilities can reveal environment data, so do not put secrets in them. If software is installed after the agent starts, the advertised capability may remain stale until a controlled restart.

Diagnose in this sequence:

1. Does the pipeline target the expected pool?
2. Does the project have permission to use it?
3. Which demands did the expanded job produce?
4. Which enabled online agents satisfy all demands?
5. Do those agents have a free slot and available parallel-job entitlement?
6. Are environment checks or exclusive locks blocking later stages instead?

#### Templates, tasks, service connections, and environments

YAML templates are executable configuration dependencies. Pin and protect their repositories. Built-in and marketplace tasks are executable dependencies too; control allowed tasks, extensions, and versions based on your governance model.

A service connection links pipeline identity to an external target. Narrow who may use and administer it, limit the external credential, prefer short-lived workload federation where supported, and avoid granting every pipeline blanket access.

Azure environment approvals and checks are resource-owned controls. That is valuable because pipeline authors should not be able to remove the gate that authorizes their own unreviewed code. Preserve which check ran, which resource it protected, who decided, and which immutable release intent was authorized.

### Worker lifecycle: the state machine operators actually own

```text
unregistered
  -> provisioned from trusted immutable image
  -> patched and baseline-verified
  -> registered in one scoped trust pool
  -> ready
  -> assigned one job
  -> running
  -> evidence flushed
  -> drained
  -> destroyed (ephemeral) OR sanitized and re-verified (persistent)
```

Every arrow can fail. Build telemetry around transitions:

- provisioning duration and error;
- image digest and age;
- registration age and authentication failure;
- heartbeat freshness;
- assignment latency;
- job and attempt identity;
- disk, inode, memory, CPU, and process pressure;
- cleanup or sanitization result;
- destruction confirmation;
- orphaned worker count.

For ephemeral workers, distinguish job finished from resource destroyed. For persistent workers, distinguish workspace deleted from host re-established as trustworthy.

### Reusable pipeline code needs a release process

Treat a shared workflow, template, or library repository like a product:

1. define a small public interface with typed or validated inputs;
2. deny dangerous combinations at the boundary;
3. keep least privilege inside each reusable unit;
4. test success, failure, cancellation, timeout, and malicious input paths;
5. publish immutable releases;
6. canary consumers;
7. record compatibility and deprecation windows;
8. automate update proposals without auto-merging high-risk changes;
9. measure consumer versions and exceptions;
10. retain a bounded rollback or roll-forward path.

A shared template that accepts an arbitrary shell string, secret name, and production target is not a safe abstraction. It is a remote execution interface. Constrain inputs to approved operations.



## Evidence table

Use this table during design reviews, migrations, and incidents. “Where to read” names a conceptual source; exact interfaces change by provider and version.

| Question | Minimum evidence | Where to read | Branches and next action | Does not prove |
|---|---|---|---|---|
| What created the run? | provider, scope, event, actor, full source revision, ref, delivery or run ID | event record and run metadata | If event or source is unknown, stop artifact or deployment claims | code review, pipeline identity, safe actor |
| What configuration ran? | entry definition revision and resolved reusable dependencies | expanded configuration, run snapshot, library/action/task/plugin inventory | If floating or unavailable, mark reproducibility gap and contain high-trust effects | semantic correctness or safe dependency |
| Why is the job not ready? | dependency states, condition result, approval or manual state, concurrency lock | graph, timeline, and control-plane reason | Resolve graph, gate, or lock owner before worker work | that later dispatch will succeed |
| Which workers are eligible? | administrative scope, trust or protection, pool or group, all selectors, architecture and runtime | scheduler reason plus worker inventory | Empty set: correct one predicate or restore qualified pool; do not broaden trust | health, free capacity, honest labels |
| Are eligible workers available? | heartbeat, enabled state, busy executors, quotas, locks, provisioning | worker or fleet control plane and quota metrics | Offline: repair lifecycle; busy: reduce service time or add qualified capacity | workspace integrity or job success |
| What ran the attempt? | attempt, worker ID, agent version, image or host identity, executor, workspace | job metadata and fleet inventory | Missing identity: evidence defect; do not call build reproducible | host integrity or clean process state |
| What authority existed? | event-specific job token permissions, secrets, OIDC claims, external policy, service connection, local credentials | run config, identity policy, audit log, worker baseline | Excess authority: contain token path and split trust pool or job | that code did not steal it |
| Was workspace input closed? | clean source identity, submodules, ignored/generated policy, cache/artifact inputs, toolchain identity | checkout logs, Git evidence, manifest, image digest | Unexplained input: reproduce in fresh isolated worker | hermeticity from Git status alone |
| What cache was restored? | exact key, fallback key, namespace, writer trust, hit or miss, integrity check | cache service receipt and job log | Untrusted writer or incomplete key: bypass or invalidate bounded namespace | build correctness or artifact identity |
| What artifact was produced? | content digest, size, producer run/job/attempt, source/config/builder identity, upload receipt | artifact repository and provenance record | Mismatch or mutable reference: stop promotion and trace substitution | functional safety or vulnerability absence |
| Did reusable logic change? | old/new immutable identities, diff, owner, canary result | source repository, plugin/task inventory, rollout record | Correlated failures: halt rollout and compare controlled cohorts | causality from timing alone |
| Why did queue grow? | arrival rate, ready queue-age percentiles, eligible capacity, service-time distribution, retry/cancel counts | scheduler and fleet telemetry | Empty eligibility, capacity saturation, and longer service time need different fixes | user impact without delivery correlation |
| Did cancellation finish? | platform cancel acknowledgement, worker process state, external operation state, target reconciliation | run timeline, worker, target control plane | Unknown external state: query by stable operation identity before retry | reversal of durable effects |
| Did upgrade recover? | old/new identities, representative cohort, backlog slope, failure and latency deltas, security result | rollout system and provider metrics | One green probe: continue bounded verification | whole-fleet compatibility |
| Is the platform reliable for users? | SLI by trust/workload class, delivery lead time, artifact availability, representative user verification | joined run, artifact, deployment, and service telemetry | Global green with broken class: keep incident scoped and open | contractual SLA unless defined |

### Evidence identity envelope

For every important job, aim to join this envelope without storing secrets:

```text
provider_scope
event_id + event_type + actor_trust
source_revision + ref
pipeline_entry_revision + resolved_dependency_identities
logical_run_id + run_attempt
job_id + job_attempt + graph_dependencies
ready_at + assigned_at + started_at + finished_at
worker_id + pool_or_group + executor + image_digest + agent_version
permission_profile_id + external_identity_subject
cache_key + cache_source
artifact_digest + artifact_receipt
environment + policy_decision_id + external_operation_id
runtime_revision + user_verification_result
```

Do not place raw tokens, secret values, full sensitive event payloads, signed URLs, or unrestricted command-line arguments in that envelope. Join through stable non-secret identifiers and controlled access.

### Telemetry freshness is evidence too

A dashboard value needs:

- source;
- query;
- unit;
- aggregation;
- dimensions;
- time window;
- sample count;
- last successful collection time;
- missing-data behavior.

“Queue p95 = 40 seconds” can be dangerously incomplete. P95 over which job class, region, provider, pool, architecture, event trust, and window? Were cancelled jobs omitted? Did collection stop during the outage? How many observations exist? Display freshness next to the value.

## Command decoders

These commands are local evidence exercises. Read the **command contract** before the sample: question, scope, risk, output grammar, proof, and proof limit. Samples are representative; your exact kernel release, paths, object IDs, resource values, and filenames will differ.

### Decoder 1: tool preflight

```bash
for tool in bash git python3 sha256sum awk find sort nproc getconf; do
  command -v "$tool" >/dev/null && echo "$tool=present" || echo "$tool=missing"
done
```

Representative output:

```text
bash=present
git=present
python3=present
sha256sum=present
awk=present
find=present
sort=present
nproc=present
getconf=present
```

Line by line:

- `for tool in ...` iterates a fixed list. It does not search the network or install anything.
- `command -v "$tool"` asks the current shell how it resolves a command name.
- `>/dev/null` hides the resolved path because this check only branches on exit status.
- `&&` runs the present branch after exit status zero.
- `||` runs the missing branch if resolution fails.

This proves name resolution under the current `PATH`. It does not prove that `python3` is the version used by a hosted runner, that a binary has not been replaced, or that a provider exists. If anything is missing, stop the affected local exercise. Installation is not an implicit step.

### Decoder 2: kernel, architecture, and userspace word size

```bash
uname -srm
printf 'userspace_bits='
getconf LONG_BIT
```

Representative output:

```text
Linux 6.8.0-65-generic x86_64
userspace_bits=64
```

- `uname -srm` requests kernel name (`-s`), kernel release (`-r`), and machine hardware name (`-m`).
- `x86_64` is a kernel architecture name. Providers and container registries may say `x64` or `amd64`; map only through an explicit contract.
- `getconf LONG_BIT` asks the userspace configuration interface whether long integers are 32 or 64 bits.

Inside a container or WSL, these values describe the visible execution boundary. They do not prove the physical host, emulation behavior, or availability of every architecture-specific dependency.

### Decoder 3: processing units

```bash
printf 'available_processing_units='
nproc
```

Representative output:

```text
available_processing_units=8
```

`nproc` reports processing units available to the current process, which may reflect affinity or control-group restrictions. It is not a benchmark. Eight visible units can be throttled, shared, slow, or poorly used by a serial build. For a runner incident, join it with central processing unit (CPU) quota and throttling, pressure, run queue, per-process usage, job concurrency, and service-time evidence.

### Decoder 4: memory fields

```bash
awk '/^(MemTotal|MemAvailable|SwapTotal|SwapFree):/ {print $1, $2, $3}' /proc/meminfo
```

Representative output:

```text
MemTotal: 16342940 kB
MemAvailable: 11842024 kB
SwapTotal: 4194304 kB
SwapFree: 4194304 kB
```

The regular expression selects exactly four line prefixes. In the action, `$1`, `$2`, and `$3` print the field name, number, and unit.

- `MemTotal` is the kernel's total usable memory view, not necessarily installed physical memory.
- `MemAvailable` estimates memory available for new work without swapping heavily; it is more useful than simply subtracting free memory.
- `SwapTotal` and `SwapFree` describe configured swap.
- `kB` is the procfs unit label; use the kernel interface definition when exact conversion matters.

In a container, a control-group limit can be smaller than host-like `/proc/meminfo` values. Always inspect the applicable control-group interface and out-of-memory events before concluding that a job had 16 GB available.

### Decoder 5: filesystem blocks and inodes

```bash
df -hT .
df -i .
```

Representative output:

```text
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdc       ext4  251G   44G  195G  19% /
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/sdc      16384000 324911 16059089    2% /
```

For `df -hT .`:

- `df` reports allocation for the filesystem containing `.`; it does not total a directory.
- `-h` formats block quantities for humans.
- `-T` adds filesystem type.
- `Size`, `Used`, `Avail`, and `Use%` describe block allocation from this caller's view.
- `Mounted on` locates the filesystem boundary.

For `df -i .`:

- `-i` switches from blocks to inode counts.
- `IUsed`, `IFree`, and `IUse%` describe inode allocation.

A Windows-backed path mounted through WSL can expose a 9P file-sharing-protocol mount or a DrvFS Windows-drive filesystem whose `df -i` fields are synthetic or unusable. Values such as a dash or negative `IUsed` are not evidence of inode headroom or exhaustion. Run the command against the exact failing Linux or container path and use that filesystem's authoritative interface.

A workspace can receive `No space left on device` with block headroom if real inode accounting is exhausted. It can also fail despite both having headroom because of quota, another mount, reserved space, a container layer, permissions, or a temporary path. Run against the exact failing path when safe.

### Decoder 6: repository and source identity

```bash
git rev-parse --show-toplevel
git rev-parse --verify HEAD
```

Representative output:

```text
/home/learner/work/service
8a7b2af3608feaf01f3ed2a0fd93d36edb710f50
```

- `rev-parse --show-toplevel` resolves the root of the current worktree.
- `rev-parse --verify HEAD` requires `HEAD` to resolve and prints its full object ID.

This prevents investigating the wrong clone or describing a short branch name as an immutable source. It still does not prove that the workspace is clean, the commit is reviewed, the remote agrees, or the pipeline used this revision.

### Decoder 7: visible worktree state without optional index refresh

```bash
git --no-optional-locks status --short --untracked-files=all
```

Representative output:

```text
 M src/build.sh
?? out/generated.json
```

The two-character prefix is compact status:

- the first column represents index or staged state;
- the second represents worktree state;
- ` M` means a tracked file is modified in the worktree but not staged;
- `??` means an untracked path;
- `--untracked-files=all` lists individual untracked files rather than collapsing directories.

No output means Git sees no tracked change or visible untracked path under its current rules. Ignored files, external mounts, background processes, modified compilers, leaked credentials, and hostile host state remain outside this proof.

### Decoder 8: immutable dependency fingerprint model

```bash
printf '%s' 'kind=reusable-config|source=reviewed-repository|revision=0123456789abcdef|path=ci/build.yml' | sha256sum
```

Representative output:

```text
2fb54be65e61ad583ec0914cb6a3bcb1934d50951559eb8ffb4daa9dc96c46ca  -
```

- `printf '%s'` emits exactly the string, without an automatic newline.
- The pipe sends those bytes to `sha256sum` through standard input.
- The 64 hexadecimal characters encode a Secure Hash Algorithm 256-bit (SHA-256) digest.
- `-` means standard input, not a file path.

This models an identity envelope. It does not fetch a reusable workflow or prove that a provider pinned it. In production, preserve the actual resolved repository, immutable revision, path, and content or provider receipt.

### Decoder 9: worker eligibility model

```bash
python3 -c "job={'linux','x64','trusted'}; workers={'r1':{'linux','arm64','trusted'},'r2':{'linux','x64','untrusted'},'r3':{'linux','x64','trusted'}}; print('requirements='+','.join(sorted(job))); [print(n,'eligible='+str(job <= s).lower(),'missing='+(','.join(sorted(job-s)) or '-')) for n,s in workers.items()]"
```

Expected output:

```text
requirements=linux,trusted,x64
r1 eligible=false missing=x64
r2 eligible=false missing=trusted
r3 eligible=true missing=-
```

The model uses Python sets:

- `job <= s` asks whether every job requirement is contained in worker set `s`;
- `job-s` computes missing requirements;
- `sorted` gives stable display order;
- `or '-'` makes an empty missing set visible.

The result says only `r3` satisfies the synthetic attributes. A real provider adds group or project permission, protection, enabled state, health, free concurrency, quota, and scheduling policy. Never cite this model as proof that a real runner is eligible.

### Decoder 10: critical-path model

```bash
python3 -c "d={'build':4,'unit':3,'scan':6,'package':2}; n={'build':[],'unit':['build'],'scan':['build'],'package':['unit','scan']}; e={}; [(e.__setitem__(j,d[j]+max([e[x] for x in n[j]] or [0]))) for j in d]; print('earliest_finish='+','.join(f'{k}:{v}' for k,v in e.items())); print('critical_path_minutes='+str(e['package']))"
```

Expected output:

```text
earliest_finish=build:4,unit:7,scan:10,package:12
critical_path_minutes=12
```

The model assumes dictionary insertion order is topological order. `build` finishes at 4. `unit` and `scan` start after build and finish at 7 and 10. `package` waits for the later predecessor, then takes 2, so it finishes at 12.

Optimizing `unit` from 3 minutes to 1 does not reduce the 12-minute path because `scan` still controls the fan-in. But real durations vary and jobs also wait for workers. Measure distributions and queue or provisioning time. Do not turn a four-node deterministic example into a production estimate.

### Decoder 11: permission-difference model

```bash
python3 -c "allowed={'test':{'contents:read'},'deploy':{'contents:read','id-token:write'}}; actual={'test':{'contents:read','packages:write'},'deploy':{'contents:read','id-token:write'}}; [print(j,'excess='+(','.join(sorted(actual[j]-allowed[j])) or '-'),'missing='+(','.join(sorted(allowed[j]-actual[j])) or '-')) for j in allowed]"
```

Expected output:

```text
test excess=packages:write missing=-
deploy excess=- missing=-
```

This is policy as set difference:

- `actual - allowed` is excess authority;
- `allowed - actual` is authority missing from the intended contract.

The test job has modeled package-write permission it does not need. The deployment job matches its small modeled set. Real effective authority also includes secrets, inherited permissions, local credentials, external trust policies, service connections, network-accessible identity endpoints, and administrator capabilities.

### Decoder 12: bounded pipeline-definition discovery

```bash
find . -maxdepth 4 -type f \
  \( -name 'Jenkinsfile' \
  -o -name '.gitlab-ci.yml' \
  -o -path '*/.github/workflows/*.yml' \
  -o -path '*/.github/workflows/*.yaml' \
  -o -name 'azure-pipelines.yml' \
  -o -name 'azure-pipelines.yaml' \) \
  -print | sort
```

Representative output:

```text
./.github/workflows/ci.yml
./Jenkinsfile
./azure-pipelines.yml
```

- `.` bounds the root to the current directory.
- `-maxdepth 4` avoids an unbounded recursive walk.
- `-type f` selects regular files.
- escaped parentheses group alternatives.
- `-name` matches a basename; `-path` matches the path seen by `find`.
- `-o` means logical OR.
- `sort` makes output stable for review.

No output does not prove there is no pipeline. A Jenkins job can be configured outside the repository; GitLab configuration may be named or generated differently; Azure can use user-interface definitions; providers can reference external repositories. Use repository documentation and authorized provider metadata next.



## Decision path

### When a job is waiting

Use this order. Each step narrows state ownership before you mutate anything.

```text
1. Is the run and job identity correct?
   no  -> locate the intended provider/scope/run; stop
   yes ->

2. Is the job ready for worker assignment?
   no  -> inspect dependencies, conditions, manual gates, approvals, locks
   yes ->

3. Does at least one worker satisfy scope + trust + pool + every selector?
   no  -> restore a qualified worker or correct one mistaken predicate
   yes ->

4. Is an eligible worker online, healthy, enabled, and free under quota?
   no  -> repair lifecycle, drain bad worker, or add qualified capacity
   yes ->

5. Was the assignment accepted and did bootstrap start?
   no  -> inspect control-plane connectivity, registration, image, workspace,
          disk/inodes, certificates, proxy, DNS, and protocol compatibility
   yes ->

6. Is service time normal for this workload class?
   no  -> inspect dependency latency, cache behavior, resource pressure,
          retries, tests, and external throttles
   yes -> check telemetry freshness and whether the alert scope is wrong
```

At every branch, record a hypothesis before the next command:

```text
Because <evidence>, I think <state owner or mechanism> is failing.
If true, <specific observation> should appear.
I will read <bounded evidence source>.
This action changes <nothing or named state>.
I will stop if <abort condition>.
```

This turns debugging from command roulette into a falsifiable investigation.

### When choosing a CI platform

Do not start with a feature checklist. Begin with constraints and operating model.

| Decision dimension | Questions that expose the real trade-off |
|---|---|
| Existing control plane | Where do source, identity, policy, artifacts, tickets, and deployment targets already live? What integration removes rather than adds operational state? |
| Workload trust | Will public contributions, proprietary builds, production deployments, and privileged infrastructure work share a platform? Can pools and administration be separated? |
| Execution needs | Hosted Linux only, or also Windows, macOS, graphics processing units, special hardware, private network, large memory, or licensed tools? |
| Isolation | Is a fresh virtual machine required per attempt? Is container-level isolation enough for the threat model? Who proves destruction? |
| Reusable code | Who owns shared workflows, templates, libraries, actions, tasks, and plugins? How are releases pinned, tested, canaried, and deprecated? |
| Identity | Can jobs obtain short-lived, claim-bound credentials? Can environment authorization stay outside untrusted pipeline code? |
| Availability | What control-plane availability is supplied? What parts must the team back up and restore? How is provider or region failure handled? |
| Scale | Arrival bursts, service-time distributions, matrix fan-out, trust-specific capacity, quotas, cold-start delay, and geographic needs? |
| Observability | Can run, attempt, queue, worker, permission, artifact, environment, and user outcome evidence be joined and exported? |
| Upgrades | Who upgrades control plane, agents, images, plugins, tasks, and integrations? Can a candidate be pinned and canaried? |
| Cost | Hosted minutes, machine classes, storage, egress, licenses, idle self-hosted capacity, fleet engineering, patching, and incident toil? |
| Portability | Which mechanism contracts are provider-neutral, and which policies, extensions, or interfaces create justified lock-in? |
| Governance | Data residency, retention, audit, change approval, segregation of duties, extension allowlists, and compliance evidence? |

A managed provider may be the reliable choice when the team should not own controller availability. Jenkins may be justified when control, plugins, unusual execution environments, or established investment outweigh controller and plugin operations. Self-hosted runners may be necessary for private resources or specialized hardware. None is automatically “enterprise” or “simple.” The right answer follows constraints and the team's ability to operate the resulting state.

### The portability contract

Before translating syntax, complete one row per job.

| Field | Contract question | Example answer |
|---|---|---|
| Event | Which event and trust class may create the run? | reviewed branch push and internal pull request; fork event uses separate untrusted pool |
| Source | Which full source revision is checked out? | provider event revision, not moving branch head |
| Configuration | Which entry file and reusable dependency revisions execute? | reviewed entry plus exact template/action/library identities |
| Graph | What must succeed, fail, skip, or complete before this job? | test and scan need build; package needs both successful |
| Selector | Which scope, trust pool, OS, architecture, and capabilities are required? | untrusted Linux x64 pool; no internal route |
| Image/toolchain | Which immutable execution identity and tools exist? | image digest plus lockfile and compiler version |
| Shell | Which shell and failure semantics apply? | Bash with `set -euo pipefail` where scripts support it |
| Permission | What provider token, secret, workload identity, and local credential can code reach? | source read only; no package write; no cloud role |
| Inputs | Which artifact, cache, package, submodule, and generated inputs exist? | build artifact by digest; dependency cache optional |
| Outputs | Which result, log, test evidence, and artifact must upload? | test report and immutable package with receipt |
| Timeout | What deadline applies, and what state remains unknown at expiry? | 15-minute job; external calls use shorter bounded deadline and operation ID |
| Retry | Which failures are safe to retry, under what stable logical identity? | one retry for proven transient download; never blind-retry deployment |
| Cancellation | What receives cancellation, how is process exit confirmed, and how are external effects reconciled? | process group terminated; target queried by release intent |
| Concurrency | Which resource must serialize or supersede? | one deployment intent per environment and artifact digest |
| Environment | Which resource-owned approval or policy authorizes which immutable intent? | production check binds artifact digest and policy result |
| Evidence | What identifiers and user outcome close the run? | joined envelope plus runtime digest and user transaction |

If a field is blank, the port is incomplete even if every provider parser accepts it.

### Four illustrative definitions of one small graph

These definitions are **review material, not executed labs**. They demonstrate `build -> test` and artifact handoff. They are not production-ready: action, image, task, plugin, and tool identities need organization-approved immutable pins; each platform needs current syntax validation; none deploys anything.

#### GitHub Actions shape

```yaml role=configuration file=.github/workflows/portable-ci.yml lines=on
name: portable-ci

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4 # Replace with an approved immutable revision.
      - name: Build deterministic sample
        shell: bash
        run: |
          set -euo pipefail
          mkdir -p dist
          printf '%s\n' 'portable-output-v1' > dist/output.txt
          sha256sum dist/output.txt
      - uses: actions/upload-artifact@v4 # Replace with an approved immutable revision.
        with:
          name: build-output
          path: dist/output.txt
          if-no-files-found: error

  test:
    needs: build
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/download-artifact@v4 # Replace with an approved immutable revision.
        with:
          name: build-output
          path: dist
      - shell: bash
        run: test "$(cat dist/output.txt)" = 'portable-output-v1'
```

What to review: event filters and fork behavior; top-level read-only token; exact action revisions; hosted image identity and drift; artifact retention and digest evidence; concurrency; shell defaults; and whether the `test` job needs source at all. It intentionally does not check out source in `test` because its contract only consumes the artifact.

#### GitLab CI/CD shape

```yaml role=configuration file=.gitlab-ci.yml lines=on
stages: [build, test]

default:
  image: ubuntu:24.04 # Replace the mutable tag with an approved digest.

build:
  stage: build
  script:
    - set -eu
    - mkdir -p dist
    - printf '%s\n' 'portable-output-v1' > dist/output.txt
    - sha256sum dist/output.txt
  artifacts:
    name: "build-output-$CI_COMMIT_SHA"
    paths:
      - dist/output.txt
    expire_in: 7 days

test:
  stage: test
  needs:
    - job: build
      artifacts: true
  script:
    - test "$(cat dist/output.txt)" = 'portable-output-v1'
```

What to review: exact image digest; runner tags, scope, executor, and protection; pipeline source and rules; token permissions; include identities; artifact access and retention; whether shell behavior supports the script; `needs` artifact semantics; resource groups; and cancellation behavior.

#### Jenkins Declarative Pipeline shape

```groovy role=configuration file=Jenkinsfile lines=on
pipeline {
  agent none
  options {
    timeout(time: 20, unit: 'MINUTES')
    disableConcurrentBuilds()
  }
  stages {
    stage('Build') {
      agent { label 'linux && x64 && untrusted' }
      steps {
        sh '''
          set -eu
          mkdir -p dist
          printf '%s\n' 'portable-output-v1' > dist/output.txt
          sha256sum dist/output.txt
        '''
        stash name: 'build-output', includes: 'dist/output.txt', useDefaultExcludes: true
      }
    }
    stage('Test') {
      agent { label 'linux && x64 && untrusted' }
      steps {
        unstash 'build-output'
        sh '''test "$(cat dist/output.txt)" = 'portable-output-v1' '''
      }
    }
  }
}
```

What to review: Jenkins core and plugin versions that provide each step; controller durability and stash storage; node-label truth; worker isolation; workspace behavior; Shared Library identity; job and folder authorization; credentials; timeout and concurrency semantics; artifact retention; and whether `stash` is appropriate at the artifact size. For a release artifact, use an immutable artifact repository rather than treating controller-local stash as the final system of record.

#### Azure Pipelines shape

This illustrative definition is scoped to **Azure DevOps Services with a GitHub repository**. YAML `pr` triggers apply to GitHub and Bitbucket Cloud repositories; Azure Repos Git pull-request validation is configured through branch-policy build validation instead. `PublishPipelineArtifact@1` and `DownloadPipelineArtifact@2` are Azure DevOps Services tasks and are not supported on Azure DevOps Server. A Server installation needs its supported artifact mechanism and a separately reviewed definition; do not copy this example across products unchanged.

```yaml role=configuration file=azure-pipelines.yml lines=on
# Scope: Azure DevOps Services with a GitHub repository
trigger:
  branches:
    include: [main]

pr:
  branches:
    include: [main]

jobs:
  - job: Build
    timeoutInMinutes: 10
    pool:
      vmImage: ubuntu-latest
    steps:
      - checkout: self
        persistCredentials: false
      - bash: |
          set -euo pipefail
          mkdir -p dist
          printf '%s\n' 'portable-output-v1' > dist/output.txt
          sha256sum dist/output.txt
        displayName: Build deterministic sample
      - task: PublishPipelineArtifact@1
        inputs:
          targetPath: dist/output.txt
          artifact: build-output

  - job: Test
    dependsOn: Build
    timeoutInMinutes: 10
    pool:
      vmImage: ubuntu-latest
    steps:
      - checkout: none
      - task: DownloadPipelineArtifact@2
        inputs:
          artifactName: build-output
          targetPath: dist
      - bash: test "$(cat dist/output.txt)" = 'portable-output-v1'
        displayName: Verify artifact content
```

What to review: Services versus Server product scope; GitHub pull-request trigger ownership; hosted image drift; task version governance; repository checkout permission; template identity; agent pool access; capabilities and demands for self-hosted use; artifact retention; parallel-job quota; environment checks; service connections; and cancellation or retry behavior.

### What these examples establish—and what they do not

They make the same intended graph visible: build exact bytes, transfer an output, and test that output on a dependent job. They do **not** establish provider semantic equivalence because these four provider definitions were not run and because defaults differ. A valid portability test must execute at least two controlled engines with:

- pinned engine and dependency versions;
- the same source and expected output;
- captured expanded configuration;
- worker and image identities;
- graph and timing evidence;
- artifact content digest and readback;
- failure, cancellation, timeout, and retry cases;
- permission and secret-negative tests;
- cleanup proof;
- a reviewer who compares evidence rather than screenshots.

The bounded lab later in this section supplies two purpose-built local engines, exact reviewed input digests, artifact readback, one declared permission/concurrency/timeout mismatch, guarded cleanup, and deterministic verification. It compares those declaration strings but does not enforce their behavior. That closes a narrow local execution gap while leaving provider execution explicitly unverified.

## Guided Ubuntu lab

### Purpose and safety boundary

This manual evidence pass teaches how to collect local worker evidence and reason about matching, graph timing, and permissions. It does not install or run a CI engine. Its prescribed computations are read-only or in memory. After it, the bounded dual-engine lab documented at `book/labs/LES-0025-ci-platform-operations/README.md` executes two purpose-built teaching schedulers inside guarded `/tmp` state.

Use Ubuntu 24.04 or WSL 2 Ubuntu 24.04 as a normal user. Do not use `sudo`. Do not paste a provider token. Do not register a runner. Do not connect to a Docker socket. Do not run the exercise in a production runner workspace.

Abort if:

- the directory is not one you are allowed to inspect;
- a command differs materially from the displayed command;
- any command requests a login, package install, token, network, elevated privilege, or writable system path;
- output unexpectedly contains a secret—stop, do not paste it into an answer, and follow the secret owner's incident process.

### Part 0: write the investigation contract

Before commands, state:

```text
Question: Can this Ubuntu shell run the provider-free evidence models safely?
Expected evidence: named tools resolve; local execution properties print;
                   in-memory models return deterministic results.
Changes: no prescribed command writes a file or contacts a provider.
Abort: missing tool, wrong directory, privilege/network/token request.
Proof limit: no result proves a real provider, runner, or pipeline behavior.
```

If you cannot say what a command proves, do not run it yet.

### Part 1: establish a before state

If you are in an intended Git worktree, run:

```bash
git rev-parse --show-toplevel
git rev-parse --verify HEAD
git --no-optional-locks status --short --untracked-files=all
```

Copy the output to your learning journal if you use one. Do not expect an empty status: existing changes may be legitimate work owned by someone else. Your cleanup comparison is before versus after, not empty versus non-empty.

If the directory is not a Git repository, record `not_applicable=not_in_git_worktree`; do not initialize one just for this lab.

### Part 2: preflight and execution boundary

Run Decoder 1, then:

```bash
uname -srm
printf 'userspace_bits='; getconf LONG_BIT
printf 'available_processing_units='; nproc
awk '/^(MemTotal|MemAvailable|SwapTotal|SwapFree):/ {print $1, $2, $3}' /proc/meminfo
df -hT .
df -i .
```

For each output, write two sentences:

1. “This proves ...” using the narrow proof from the decoder.
2. “This does not prove ...” naming one production uncertainty.

Example:

```text
available_processing_units=8 proves nproc reported eight processing units to this process.
It does not prove eight dedicated physical cores or that a build will scale to eight workers.
```

### Part 3: inspect only bounded local definition names

From an authorized repository root, run Decoder 12. Classify every matching path:

| Path | Provider shape | Entry or reusable dependency? | External dependencies still unknown |
|---|---|---|---|
| example: `.github/workflows/ci.yml` | GitHub Actions | candidate entry | actions, called workflows, environment policy, organization defaults |

Do not claim a matching filename is active. If no file appears, state exactly: “No common filename matched within depth four.” Then list provider-side or generated definitions as unknown, not absent.

### Part 4: test eligibility reasoning

Run Decoder 9. Confirm that only `r3` is eligible. Now reason through these changes **before** altering the command:

1. If the job drops `trusted`, which workers become eligible?
2. If `r2` changes `untrusted` to `trusted`, what security question remains?
3. If `r3` is offline, is the eligible set empty or merely unavailable?
4. If ten copies of `r1` are added, does x64 capacity improve?

Answers:

1. `r2` and `r3` satisfy `{linux, x64}`; `r1` still lacks `x64`.
2. The model now matches, but you must prove who authorized the attribute, worker integrity, administrative scope, health, network, credentials, and free capacity. Editing a label is not creating trust.
3. Its static attributes still match, but available eligible capacity becomes zero. Distinguish eligibility from availability.
4. No. More ARM64 workers do not serve a job requiring x64.

Optional in-memory variation:

```bash
python3 -c "job={'linux','x64'}; workers={'r1':{'linux','arm64','trusted'},'r2':{'linux','x64','untrusted'},'r3':{'linux','x64','trusted'}}; [print(n, job <= s) for n,s in workers.items()]"
```

It should print `False`, `True`, `True` in insertion order. This remains a set model, not a provider test.

### Part 5: find the modeled critical path

Before Decoder 10, draw:

```text
build(4) ---> unit(3) ---+
       \                 +--> package(2)
        +--> scan(6) ----+
```

Predict the finish time. Then run the command. The answer is 12 minutes: build 4, then the longer parallel branch scan 6 reaches minute 10, then package 2.

Now answer:

- If build queue wait is 5 minutes, what is end-to-end earliest finish from ready time? **17 minutes**, assuming every later job has zero queue and durations stay fixed.
- If scan is split into two truly parallel 3-minute jobs and package needs both, what new risks appear? **Additional scheduling demand, fan-out quota, two artifact or result identities, fan-in conditions, and correlated dependency behavior.** The ideal compute path may fall, but queueing may rise.
- Does speeding unit from 3 to 1 minute help this graph? **Not the critical path while scan remains 6.** It may reduce resource consumption, which can still improve shared queue capacity.

### Part 6: find excess modeled permission

Run Decoder 11. It flags `packages:write` on the test job.

Create a real-world permission review table without copying secrets:

| Job | Required operation | Provider token | External identity | Local worker authority | Excess or unknown |
|---|---|---|---|---|---|
| test | read source, upload test result | expected source read and result write | none expected | untrusted pool, no internal route | verify artifact write scope; local credential sources unknown |
| deploy | read artifact, request target reconcile | minimal metadata read | short-lived target-specific role | trusted ephemeral pool | verify subject, audience, expiry, target resource |

The table forces you to inspect more than a YAML `permissions` block.

### Part 7: lead the queue incident on paper

Scenario:

```text
14:00 release jobs begin queueing.
14:03 general Linux runner utilization is 22%.
14:05 protected runner group shows one worker online.
14:06 that worker advertises linux and x64 but not release-tools.
13:55 its image rollout changed the advertised capabilities.
```

Write the incident response:

1. **Scope:** protected release jobs requiring `release-tools`; general CI is not proven affected.
2. **Hypothesis:** image rollout or capability discovery removed the required selector from the only administratively eligible worker.
3. **Read-only evidence:** expanded job selectors, group access, worker heartbeat/version/image, advertised capabilities, old/new fleet inventory, queue reason, recent rollout record.
4. **Containment:** halt image rollout and keep jobs from falling into a less-trusted pool.
5. **Canary:** create or restore one approved old-image worker in the same protected scope, with no permission broadening; send a non-destructive representative job.
6. **Recovery proof:** assignment to expected worker identity, capability readback, job result, artifact evidence, falling protected backlog, and no trust-policy exception.
7. **Prevention:** pre-registration capability assertion, canary pool, protected-class synthetic job, selector contract test, and rollback decision record.

Do not write “restart all runners.” It is neither a diagnosis nor a bounded correction.

### Part 8: after state and cleanup proof

If Part 1 ran in Git, repeat:

```bash
git --no-optional-locks status --short --untracked-files=all
```

Compare it with the before output. Equality is evidence that the prescribed lab did not change Git-visible worktree state. It does not cover shell history, access times, ignored files, processes, or a separately chosen journal.

Your lab evidence should contain:

- environment description and date;
- exact commands and non-sensitive output;
- before and after Git status comparison or `not_applicable`;
- four eligibility answers;
- critical-path answers;
- permission table;
- queue-incident hypothesis, evidence, containment, correction, and proof limits.

Reading the answer key is not completion. You need to produce your own evidence and explain why each command cannot prove a hosted-platform claim.

### Automated dual-engine lab: a green port can still be unsafe

Open the LES-0025 bounded lab at `book/labs/LES-0025-ci-platform-operations/README.md` and follow its command path. The first local engine expands explicit `needs` edges. The second expands ordered stages. Both call the same typed portable job program, publish the same bytes, download them into the dependent job, and finish green.

The first stage-shaped port deliberately declares `packages:write`, parallel same-ref execution, and a zero pipeline-timeout field. `bash lab.sh compare` must report equal observed artifact and graph fields while `encoded_comparison_equal=false`. The model does not grant that permission, launch concurrent attempts, or remove the controller's safety timeout. `bash lab.sh recover` runs the corrected fixture; `bash lab.sh verify-operation` then proves equality only for the observed local output and encoded declarations.

Run the engineering verifier from clean state:

```bash
bash verify.sh
```

The verifier proves deterministic behavior, record digest binding, minimal child environments, negative-case observation, guarded refusal, exact cleanup, and final absence for the checked-in local implementation. It does not prove GitHub Actions, GitLab CI/CD, Jenkins, or Azure Pipelines behavior. Treat the local engines as an executable mental model and use the provider portability matrix when transferring the questions to a real authorized platform.



## Production transfer

### Build a CI platform as a product, not a shared server

A production CI platform needs an explicit service contract. Application teams are customers, but they also execute arbitrary code inside the service. That makes the relationship different from an ordinary internal API.

Publish:

- supported event types, repository or project scopes, and trust classes;
- available worker pools, architectures, images, capabilities, and network classes;
- image and agent release cadence;
- supported reusable workflows, templates, libraries, actions, tasks, and plugins;
- artifact and cache limits, retention, and ownership;
- default permissions and approved identity patterns;
- availability and support objectives by workload class;
- maintenance windows and deprecation policy;
- incident contact, escalation, and evidence requirements;
- exception process with owner and expiry;
- cost attribution and capacity expectations.

Do not promise “any tool on any runner.” That produces unreproducible pets. Offer reviewed execution images and a path for proposing additions. Let unusual workloads use a dedicated bounded pool when their threat, license, hardware, or lifecycle differs.

### Reference production topology

```text
                      source providers
                            |
                     event validation
                            |
             +--------------+---------------+
             |        CI control plane       |
             | graph / policy / queue / audit|
             +------+---------------+---------+
                    |               |
          untrusted validation      protected release
                    |               |
        +-----------v------+   +----v----------------+
        | ephemeral pool U |   | ephemeral pool R    |
        | no prod identity |   | reviewed refs only  |
        | restricted egress|   | short-lived identity|
        +-----------+------+   +----+----------------+
                    |               |
                    +-------+-------+
                            |
              immutable artifact repository
                            |
                 independent policy / approval
                            |
                    deployment controller
                            |
                       target runtime
                            |
                 telemetry + user verification
```

Text alternative: one control plane schedules untrusted and protected work into separate execution pools. The untrusted pool has restricted egress and no production identity. The protected pool accepts reviewed refs and receives only short-lived, target-specific identity. Both publish through a controlled artifact repository; independent policy authorizes an immutable artifact before a deployment controller changes runtime state. Telemetry verifies the user result.

Separation may require distinct organizations, instances, accounts, subscriptions, networks, clusters, hypervisors, or controllers depending on threat model. A different label on the same writable host is weak separation.

### Runner or agent image release runbook

#### Before rollout

1. **Inventory:** current agent binary, base operating system, image digest, installed tools, certificates, proxy, container runtime, bootstrap, cleanup, labels or capabilities, pool access, and owners.
2. **Threat and compatibility review:** security fixes, removed packages, shell behavior, architecture, provider minimum version, action/task/plugin requirements, filesystem permissions, network, and license constraints.
3. **Reproducible candidate:** build a pinned image through a reviewed pipeline; record inputs, digest, vulnerability evidence, and signing or provenance policy.
4. **Rollback boundary:** retain the previous known-compatible image and registration path where safe; document when a security fix makes rollback unacceptable.
5. **Representative suite:** test checkout, submodules, caches, artifacts, containers, large files, language toolchains, cancellation, timeout, signal handling, secret-negative cases, workload identity, proxy, certificates, and cleanup.

#### Canary

Create a separate selector and administrative scope. The canary should have no production authority until compatibility is demonstrated. Route opted-in representative repositories rather than silently changing every consumer.

Compare candidate against control:

- assignment and bootstrap success;
- queue and provisioning time;
- job success by workload class;
- p50, p95, and tail service time with sample counts;
- CPU, memory, storage, inode, and network behavior;
- cache and artifact correctness;
- tool and certificate errors;
- cancellation and orphan-process behavior;
- cleanup and destruction result;
- security findings;
- cost per successful job.

A faster candidate that leaks credentials or intermittently corrupts artifacts fails.

#### Bounded rollout

Move one wave at a time. Maintain enough old qualified capacity to avoid a self-created queue incident. Drain before replacement:

```text
mark no-new-work -> list in-flight attempts -> wait or handle by policy
-> flush evidence -> revoke registration -> destroy or rebuild
-> register candidate -> run synthetic -> admit selected work
```

Never terminate in-flight deployment attempts without reconciling external state.

#### Recovery proof

Success requires more than worker online state:

- representative jobs from each supported trust, architecture, and toolchain class are accepted;
- expected worker and image identities appear;
- artifacts upload and read back by digest;
- queue backlog falls without unsafe rerouting;
- failure, latency, and cost stay within rollout thresholds;
- old registrations and orphan resources are removed;
- exception and rollback state are documented.

### Jenkins controller and plugin change runbook

The controller owns durable orchestration state, so add these controls:

1. export core, Java, plugin, dependency, Shared Library, configuration-as-code, credential-provider, and agent compatibility inventory;
2. read security and upgrade guidance for the exact versions;
3. prove backup restoration on an isolated controller, including jobs, credentials references, build metadata, and Pipeline resumption appropriate to policy;
4. clone representative configuration without production credentials;
5. install the exact plugin set and core candidate, not a floating “latest compatible” result without recording resolution;
6. run representative Pipelines including restart, agent disconnect, stash/artifact, input, timeout, and failure cases;
7. canary selected folders or a parallel controller where architecture allows;
8. schedule change and restart with communication, freeze boundary, abort threshold, and owners;
9. verify queue, Pipeline resumption, authentication, authorization, agents, webhooks, artifacts, logs, and backup health;
10. keep or retire rollback material under a deliberate data-compatibility decision.

A plugin rollback may not be safe after configuration migration. The runbook must name restore or roll-forward when file-level downgrade is unsupported.

### Provider migration playbook

Migration is not YAML translation. Use six workstreams.

#### 1. Inventory the old contract

For every pipeline, record events, configuration dependencies, jobs, selectors, images, permissions, secrets and external identity, artifacts, caches, environments, concurrency, retry, timeout, cancellation, notifications, evidence, and owners. Include UI or administrator-owned settings.

#### 2. Classify coupling

Mark each dependency:

- portable mechanism: Git source identity, shell script with explicit interpreter, OCI artifact digest, external policy API;
- replaceable adapter: artifact upload step, provider annotation, test-report publisher;
- provider policy: environment check, protected resource, runner group;
- deep coupling: plugin-specific step, proprietary expression semantics, user-interface job, mutable marketplace extension.

Coupling is not automatically bad. Hidden coupling is bad. Keep justified provider features behind a small, tested interface.

#### 3. Define equivalence tests

Test the behavior that matters:

- trusted and untrusted event separation;
- exact source and configuration identities;
- graph dependency and skipped/failure semantics;
- artifact bytes and digest;
- cache miss correctness;
- least privilege and secret absence in untrusted jobs;
- timeout, cancellation, retry, and duplicate-effect handling;
- concurrency against the same target;
- approval binding and audit receipt;
- log, test result, and retention evidence;
- user-visible deployment verification.

#### 4. Dual-run without double effects

Run build and test on both providers using the same source. Do not let both perform uncoordinated deployment or publish the same mutable release name. Give the shadow path a non-production artifact namespace and no target write permission. Compare artifacts and evidence; if deterministic output is expected, compare content digests. If nondeterminism is legitimate, identify and normalize only the allowed dimensions.

#### 5. Cut over by workload class

Start with low-risk, representative repositories. Keep the old path available under a time-bounded rollback decision, but prevent two control planes from racing. Observe queue, success, latency, artifact, security, and support load. Expand in cohorts.

#### 6. Retire old authority

Disable triggers, revoke credentials and service connections, remove runner registrations, archive required evidence, end cache/artifact writes, update runbooks, and confirm billing or infrastructure cleanup. A migration is not complete while an abandoned CI controller retains production credentials.

### Production incident timeline template

```text
T0 signal and freshness:
T1 user/workload impact and affected trust classes:
T2 last known good run/config/worker/artifact identities:
T3 recent shared changes:
T4 first falsifiable hypothesis:
T5 containment and blast-radius consequence:
T6 read-only evidence and result:
T7 bounded correction/canary and abort threshold:
T8 recovery evidence including backlog slope:
T9 external effect and user verification:
T10 temporary exception owner/expiry:
T11 prevention action, owner, due date, verification:
```

Use timestamps from source systems and label clock uncertainty. Do not rewrite the timeline later to make the diagnosis look linear. Failed hypotheses are valuable evidence when preserved without blame.

## Reliability, security, observability, capacity, and cost

### Reliability: define the service by usable work

A CI platform is reliable when supported workloads can turn reviewed changes into trustworthy evidence within useful time. Define indicators by class.

Example queue SLI:

```text
numerator   = ready jobs assigned to an eligible worker within 120 seconds
              during the window

denominator = all supported jobs that became ready during the window,
              excluding only pre-declared non-service events
```

Partition by untrusted Linux, protected release, Windows, macOS, GPU, or other meaningful class. A 99.9 percent global result can hide 0 percent for the protected release pool if that class is small.

Other indicators:

- configuration evaluation success;
- runner provisioning success and time;
- job-start success after assignment;
- log stream availability and completeness;
- artifact upload and readback success;
- control-plane API and webhook acceptance;
- cache service availability, measured separately from build correctness;
- successful reference pipeline end to end;
- mean time to acknowledge and restore platform incidents.

An SLO must name target, window, exclusions, data source, missing-data handling, and owner. Error-budget policy should constrain risky platform rollout when reliability is already below target.

Design for degraded operation. If cache fails, builds should be slower rather than wrong. If one specialized pool fails, unaffected pools should continue. If artifact storage fails, do not report release success. If approval service is unavailable, fail closed for production rather than bypassing the gate.

### Security: code is hostile until trust is established

#### Event and code trust

Separate public fork, internal branch, protected release, and production administration paths. Review which provider events expose secrets or privileged tokens. Never rely on contributor intent.

#### Worker boundary

Prefer fresh execution environments. Deny privileged container runtime access unless a dedicated threat model and isolation design justify it. Restrict network egress and internal routes by workload. Remove long-lived local credentials. Patch base images and agent binaries. Prove destruction or sanitization.

#### Identity

Use short-lived workload identity with exact issuer, audience, subject, repository or project, ref, workflow, environment, and time claims as supported. External policy should grant only named actions on named resources. Record the decision without recording the token. Job-level provider permission is only one layer.

#### Reusable dependencies

Pin and review actions, tasks, templates, includes, Shared Libraries, plugins, images, packages, and installers. Protect maintainers and release process. Use an allowlist where appropriate. Detect drift and consumer versions.

#### Secrets and logs

Do not pass secrets on command lines where process listings or debug output can expose them. Masking is a last line, not a guarantee: encoded, transformed, split, or short secret fragments may evade filters. Avoid uploading entire workspaces. Review artifacts and test reports for sensitive data. Use synthetic credentials in negative tests.

#### Supply-chain outputs

Identify artifact bytes by digest. Preserve producer identity and approved build inputs. Separate untrusted cache writers from trusted consumers. Sign or attest according to policy, but remember that a signature proves an identity made a statement; it does not prove the artifact is safe.

### Observability: follow one operation across planes

Instrument the control plane and execution fleet, then join them.

Control-plane metrics:

- events accepted and rejected by type;
- configuration evaluation duration and failure;
- ready jobs and oldest queue age by class;
- eligible-worker count at dispatch time where available;
- assignment rate and scheduler errors;
- cancellation, retry, skip, and timeout counts;
- concurrency and quota saturation;
- artifact and log service errors;
- environment check wait and failure.

Execution metrics:

- registered, online, busy, draining, and orphaned workers;
- provisioning and destruction duration;
- agent version and image age distribution;
- bootstrap and checkout failure;
- CPU, memory, pressure, storage blocks, inodes, input/output, and network;
- process and container leakage after job;
- cache restore/save time and hit source;
- artifact upload bytes, duration, and failure;
- credential or identity issuance error without secret values.

Use bounded cardinality in metrics. A raw commit SHA, run ID, or repository path can explode time-series count. Keep high-cardinality correlation in logs or traces with retention and access control, and aggregate metrics by controlled classes.

Alerts should be actionable:

```text
Signal: p95 ready-to-assigned > 120 seconds for protected-linux-x64
Window: 15 minutes, minimum 30 jobs
Corroboration: oldest queue age rising and eligible free slots < 2
Freshness: last scheduler sample < 2 minutes old
Owner: CI platform on-call
Runbook: queue incident decision path
```

Avoid “runner offline” alerts for ephemeral workers unless the lifecycle controller expected that worker to exist. Alert on failure to replace capacity or finish destruction, not normal churn.

### Capacity: size the eligible pool, not the fleet total

Create workload classes by trust, architecture, resource profile, and toolchain. For each, measure:

- arrivals per interval and burst distribution;
- ready queue age percentiles;
- service-time distribution, not only mean;
- worker provisioning and teardown time;
- matrix fan-out and fan-in;
- retry and cancellation amplification;
- external dependency saturation;
- pool concurrency, quotas, and license limits;
- idle reserve required for failure and rollout;
- cost per successful job and per artifact.

Autoscaling loop:

```text
ready demand by class
  -> subtract healthy free eligible slots
  -> account for starting workers and cold-start time
  -> request bounded additional capacity
  -> register with one trust scope
  -> verify synthetic readiness
  -> accept jobs
  -> drain on idle policy
  -> destroy and confirm
```

Guard against runaway scale when jobs are unschedulable because of a missing label; scaling the wrong template multiplies cost without serving demand. Cap each loop, expose why capacity was requested, and alert on old pending workers.

Keep headroom for fleet rollout and failures. If normal operation uses 100 percent of a protected pool, draining one worker creates an incident. Headroom is reliability capacity, not waste, but quantify it.

### Cost: compare total service cost, not minute price

Hosted cost can include:

- billed minutes or larger-machine multipliers;
- artifact, cache, and log storage;
- network egress;
- premium parallelism, operating systems, or hardware;
- idle time inside billed jobs;
- provider and extension licensing.

Self-hosted cost can include:

- compute, storage, network, and orchestration;
- idle reserve and failed provisioning;
- image engineering, patching, certificates, proxies, and registrations;
- autoscaler and fleet-control development;
- security monitoring and incident response;
- controller operations, backup, restore, and upgrades;
- on-call toil and application-team wait time;
- software licenses and specialized hardware.

Useful unit economics:

```text
cost_per_successful_job = total class cost / successful useful jobs
cost_per_verified_artifact = total build path cost / accepted immutable artifacts
waste_ratio = cancelled + superseded + duplicate + failed-retry compute / total compute
```

Define each numerator carefully. A cancelled job may still provide useful early feedback; a green job may produce no reusable result. Pair cost with reliability and lead time. The cheapest minute is not economical if developers wait hours or operators spend nights repairing it.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| Count every online worker as capacity | ignores scope, trust, selectors, architecture, health, quota, and busy state | report eligible free slots per workload class |
| Remove a selector to clear queue | may route code into wrong trust or tool boundary | restore qualified capacity or correct the exact mistaken predicate under review |
| Treat labels or tags as attestations | mutable strings do not prove image, tool, patch, or isolation state | bind registration to trusted provisioning and verify baseline evidence |
| Share persistent workers across fork and deployment jobs | untrusted code can persist, poison outputs, or steal later authority | separate trust pools and use fresh low-reach workers for untrusted events |
| Give every job a broad token | compromise in an ordinary test becomes package, source, or environment compromise | explicit job permissions and separate short-lived external identity |
| Put secrets in capabilities, labels, variables, or command lines | metadata and process/log surfaces can expose them | non-secret selectors; approved secret store; file or standard-input patterns where supported |
| Float reusable code, images, tasks, actions, or plugins | old runs cannot be reconstructed and shared changes create fleet-wide incidents | immutable release identities, controlled update proposals, canary consumers |
| Call cache an artifact | fallback, eviction, shared writers, and mutability break release identity | correctness without cache; immutable artifact store and digest handoff |
| Rebuild on every provider or environment | tested bytes differ from released bytes | build once and promote the same digest |
| Retry every failure | duplicates external effects and amplifies outages | classify errors, stable operation identity, absence proof, budget and backoff |
| Assume cancellation reversed work | accepted external requests and durable effects outlive attempts | target-side reconciliation and idempotent release intent |
| Increase Jenkins executors until queue falls | creates host contention and workspace interference | profile jobs, isolate workloads, add measured qualified capacity |
| Upgrade an entire fleet at once | one incompatibility becomes organization-wide failure | pinned candidate, representative suite, canary pool, drain waves, rollback decision |
| Restart first | destroys volatile evidence and may duplicate or interrupt work | read control-plane, worker, and external state first; mutate one bounded component |
| Optimize global mean duration | hides critical path, tail, queue, and broken workload classes | dependency graph plus class-specific percentiles and user lead time |
| Alert on expected ephemeral churn | pages operators for healthy lifecycle | alert on unavailable class capacity, failed registration, and failed destruction |
| Migrate syntax and declare equivalence | permissions, graph, artifact, approval, and cancellation semantics drift | field-by-field portability contract and negative equivalence tests |
| Store every identifier as a metric label | unbounded cardinality harms telemetry cost and reliability | controlled metric dimensions; high-cardinality joins in protected logs or traces |
| Keep old CI authority after migration | abandoned credentials and triggers remain attack paths | revoke, deregister, archive, verify billing and state retirement |

### Prevention review: five gates before production authority

A pipeline should not receive production authority until reviewers can answer:

1. **Identity:** Which immutable source, configuration dependencies, builder, and artifact will be authorized?
2. **Trust:** Which event/code class and worker isolation boundary execute it?
3. **Authority:** Which exact provider and external permissions exist, for how long, on which resources?
4. **Failure:** What happens on timeout, cancellation, retry, worker loss, controller loss, and partial external acceptance?
5. **Evidence:** Which independent target and user signals prove success or recovery?

A missing answer is a design gap. A screenshot is not a substitute.

## Memory card and retrieval

### One-minute memory card

```text
CI PLATFORM = CONTROL PLANE + SCHEDULER + EXECUTION PLANE + EVIDENCE STORES

First identities:
  event | source | resolved config | run/attempt | job/attempt
  worker/image | permission | cache | artifact digest | environment operation

Queued job:
  ready? -> eligible intersection non-empty? -> healthy/free/quota?
  -> assigned/bootstrap? -> normal service time?

Selectors:
  GitHub group + labels
  GitLab scope/protection + tags + executor
  Jenkins node labels + executors
  Azure pool + capabilities/demands

Trust rule:
  untrusted code never shares persistent privileged state

Port rule:
  translate the execution contract, not the YAML keywords

Upgrade rule:
  inventory -> pin -> canary -> compare -> drain waves -> verify

Recovery rule:
  correct worker + correct artifact + falling backlog + target/user evidence
```

### Retrieval prompts

Answer without looking, then check the complete answers later.

1. Why can eleven online workers provide zero capacity for one job?
2. What is the difference between eligibility and availability?
3. Why is an ephemeral label not proof of isolation?
4. What state can survive cancellation?
5. Which identities must a reproducible run preserve beyond source revision?
6. Why are a GitHub label, GitLab tag, Jenkins label, and Azure capability not exact equivalents?
7. What makes a reusable workflow, include, Shared Library, template, action, task, or plugin security-sensitive?
8. Why is a cache hit not proof of correctness?
9. When does adding workers fail to improve queue age?
10. What must a runner-image canary test?
11. Why might a Jenkins plugin downgrade not be a safe rollback?
12. How do you dual-run two providers without duplicate production effects?
13. What proves a queue incident recovered?
14. Which telemetry should be a metric dimension, and which identity belongs in logs or traces?
15. What evidence separates a permission declaration from effective authority?

### Spaced retrieval schedule

- **After ten minutes:** redraw the control-plane and execution-plane map.
- **Tomorrow:** reproduce the queue decision path and four provider selector mappings.
- **After three days:** solve the empty-intersection and shared-upgrade incidents without notes.
- **After one week:** fill the portability contract for a pipeline you know.
- **After two weeks:** explain the architecture aloud in five minutes, including proof limits.
- **After one month:** review a real non-sensitive pipeline and identify one reliability, security, observability, capacity, and cost gap.

Memory follows retrieval and application, not rereading alone.



## Complete answers

These answers explain the reasoning, not merely the conclusion. Attempt each retrieval prompt first.

### 1. Why can eleven online workers provide zero capacity for one job?

“Online” answers only whether a worker currently communicates with its control plane under some registration. A job needs the intersection of several predicates:

- the repository, project, folder, or organization may use the worker;
- the event and ref satisfy the worker's trust or protection policy;
- the job targets its pool, group, or executor class;
- every required label, tag, capability, demand, operating system, and architecture matches;
- the worker version and runtime are compatible;
- it is enabled and healthy;
- an executor or concurrency slot is free;
- organization, provider, license, and environment quotas allow dispatch.

If each of eleven workers fails at least one required predicate, the eligible set is empty. Adding more copies of an ineligible worker changes the fleet count but not capacity for that job. The correct diagnostic reports *eligible free slots for this workload class*, not total online workers.

### 2. What is the difference between eligibility and availability?

**Eligibility** is whether a worker is permitted and technically suitable for a job. It depends mostly on scope, trust, pool, selectors, architecture, and runtime contract.

**Availability** is whether an eligible worker can accept work now. It depends on online and healthy state, free executors, quotas, locks, and provisioning.

A trusted Linux x64 worker with the correct tools can be eligible but unavailable because it is busy. An idle Linux ARM64 worker is available in a general sense but ineligible for an x64 job. This distinction tells you whether to repair matching or capacity.

### 3. Why is an ephemeral label not proof of isolation?

“Ephemeral” should describe lifecycle: a registration or compute resource is bounded and destroyed. A label is a mutable scheduling string. Neither proves what shares the kernel, hypervisor, container daemon, network, identity endpoint, cache, base image, storage, or fleet controller.

A one-job container mounted to a privileged host Docker socket can be short-lived and still control a persistent host. A fresh virtual machine created from a compromised writable image is fresh but untrustworthy. Isolation proof needs architecture and observation: trusted image digest, hypervisor or runtime boundary, unique identity, restricted network, no privileged shared socket, controlled writable outputs, destruction receipt, and a threat model.

### 4. What state can survive cancellation?

Potentially:

- child or detached processes;
- service containers or virtual machines;
- files and credentials on persistent storage;
- cache and artifact uploads already accepted;
- package publications;
- messages sent to queues;
- deployment operations accepted by a controller;
- database migrations and writes;
- infrastructure API changes;
- external sessions or short-lived credentials until expiry;
- logs and audit records.

Cancellation changes a CI attempt's desired state. It is not a transaction that rolls back every system the attempt contacted. Use stable operation identity, target-side idempotency, process-group handling, timeouts, and reconciliation with each state owner.

### 5. Which identities must a reproducible run preserve beyond source revision?

At minimum: event type and delivery identity; actor trust; entry pipeline revision; resolved reusable workflow, include, template, Shared Library, action, task, plugin, image, package, lockfile, submodule, and toolchain identities; logical run and attempt; job graph and conditions; job attempt; worker, agent version, executor, host or image digest, architecture, and workspace; effective permission profile and external identity subject; cache key and source; artifact digest and upload receipt; policy and approval decision; environment; external operation; and runtime readback.

Not every provider exposes all of these perfectly. Missing identity is an evidence limitation to manage, not permission to substitute the current default branch or a mutable tag.

### 6. Why are a GitHub label, GitLab tag, Jenkins label, and Azure capability not exact equivalents?

They all participate in selection, but their surrounding contracts differ.

- GitHub combines `runs-on` labels with runner groups and repository or organization access.
- GitLab combines job tags with runner scope, protected-runner behavior, executor, and runner configuration.
- Jenkins evaluates node labels or expressions and then needs an online node with an available executor under controller policy.
- Azure selects a pool and matches demands against agent capabilities, plus permissions and parallel-job constraints.

Their syntax, ownership, expression rules, administrative scope, automatic attributes, update behavior, and protection semantics differ. Translate the intended worker contract, then implement it with each provider's controls.

### 7. What makes reusable pipeline code security-sensitive?

It executes inside jobs or the control plane and can influence source checkout, commands, credentials, artifacts, deployments, and evidence. A one-line application change may call hundreds of lines maintained elsewhere.

A trusted Jenkins Shared Library can access privileged internal APIs. A GitHub action can read the job environment and token. A GitLab include can alter job scripts, images, rules, and artifacts. An Azure template or task can change permissions and external calls. A Jenkins plugin executes in the controller process.

Therefore protect maintainers, pin releases, review changes, constrain inputs, test malicious and failure cases, canary consumers, record resolved identity, and control deprecation. Shared logic often has organization-wide blast radius.

### 8. Why is a cache hit not proof of correctness?

A hit says a cache service found an entry under a key or fallback rule. It does not prove that:

- the key included lockfile, toolchain, platform, architecture, job, policy, and other compatibility inputs;
- only trusted jobs could write the namespace;
- the content is complete or uncorrupted;
- the restore was actually consumed;
- the build output is correct;
- the entry matches the current source;
- a released artifact has immutable identity.

Build correctness must survive a cold cache. Treat cache as performance state and artifacts as controlled outputs.

### 9. When does adding workers fail to improve queue age?

Adding workers fails when they are ineligible; quotas or locks cap concurrency elsewhere; jobs are not ready because dependencies or approvals wait; provisioning time exceeds bursts; service time is dominated by an external dependency; a serial critical path remains; a license limits parallelism; the scheduler or control plane is unhealthy; or retries and matrix fan-out increase demand faster than capacity.

Before scaling, partition queue time, enumerate eligibility, measure free qualified slots and service-time distribution, and identify the bottleneck. Scale the constrained class, not the visible fleet.

### 10. What must a runner-image canary test?

It needs representative success and failure paths:

- checkout, submodules, large files, and permissions;
- shells, language toolchains, compilers, package managers, and certificates;
- container and service dependencies under the real isolation policy;
- cache restore and save, artifact upload and readback;
- test results, logs, annotations, and encoding;
- timeout, cancellation, signals, child-process cleanup, and worker destruction;
- workload identity and explicit secret-negative cases;
- proxy, Domain Name System (DNS), network, and external dependency behavior;
- CPU, memory, storage blocks and inodes, input/output, and service-time distributions;
- old versus new image identity and cost;
- every supported trust, architecture, and workload class.

A hello-world job only proves a narrow interpreter path.

### 11. Why might a Jenkins plugin downgrade not be a safe rollback?

A newer plugin or controller can migrate configuration, credentials metadata, job state, or stored data into a form the older version cannot read. Dependencies may also have moved forward. Replacing one plugin file can leave an incompatible graph or partially migrated state.

Before upgrade, determine the vendor-supported rollback boundary and prove backup restoration. The safe recovery may be full controller restore or roll-forward to a corrected release. Document it before the change and protect backup confidentiality because controller state is sensitive.

### 12. How do you dual-run two providers without duplicate production effects?

Give the shadow provider the same source and build/test intent but no production-write authority. Publish into a separate non-production namespace or compare outputs without overwriting release names. Ensure only one provider owns deployment serialization and external release intent. Use immutable artifact identities and distinguish shadow runs in evidence.

Compare expanded configuration, graph, worker/image, permissions, artifact digest, failure behavior, queue, and logs. Test production authorization later in a disposable target or through a reviewed cutover—not by letting both providers race against production.

### 13. What proves a queue incident recovered?

Evidence should show:

- telemetry is fresh;
- representative jobs in every affected class become ready and are assigned within objective;
- assignments use the intended worker, image, trust pool, and permissions;
- attempts start and complete;
- artifacts or required evidence upload and read back;
- oldest and percentile queue age fall;
- backlog slope is negative until normal;
- no unsafe selector or permission exception remains;
- external release and user operations succeed if the incident affected delivery.

An online icon or one trivial green job is insufficient.

### 14. Which telemetry should be a metric dimension, and which identity belongs in logs or traces?

Metrics work best with bounded dimensions needed for aggregate decisions: provider region, controlled workload class, pool, architecture, trust class, result category, error class, and version cohort with limited values.

Repository names can already be high-cardinality at scale; commit SHAs, run IDs, job IDs, worker IDs, artifact digests, actor identities, and operation IDs are usually inappropriate as metric labels. Put them in access-controlled structured logs, traces, or event stores and join them during investigation. Apply retention and privacy policy. A small controlled inventory metric for image versions may be safe; an unbounded digest per run is not.

### 15. What evidence separates a permission declaration from effective authority?

A YAML declaration is one input. Effective authority requires:

- event-specific provider token permissions after defaults and inheritance;
- which secrets became available and to which steps or reusable calls;
- OIDC token claims and the external trust policy decision;
- service-connection or credential binding and target-side role;
- credentials already present on the worker, in files, environment, metadata services, keychains, or container runtime;
- network reachability to sensitive endpoints;
- administrator or controller APIs reachable through plugins or libraries;
- audit records showing which principal invoked which resource operation.

A job with source read-only permission can still be powerful if a long-lived cloud key sits on the host. Review the entire credential and network path.

### Additional worked question: “All tests are green. Why not deploy?”

Green tests prove only that the executed assertions returned qualifying results under the observed inputs and environment. Before deployment ask whether the run used reviewed source and pipeline code, a trusted isolated worker, closed inputs, expected test selection, an immutable artifact, required security and policy evidence, correct target compatibility, safe migration, and a digest-bound authorization. Then verify the target and user result.

The answer is not “never trust CI.” It is “interpret green within its evidence contract.”

### Additional worked question: “Should we use hosted or self-hosted runners?”

Use hosted execution when provider-supported images, networks, hardware, data policy, performance, and cost meet requirements and the team benefits from not owning fleet lifecycle. Use self-hosted execution when private connectivity, specialized hardware or licensing, custom images, control, or economics justify owning patching, isolation, scaling, registration, destruction, monitoring, and incidents.

Often the design is hybrid: hosted or low-reach ephemeral pools for ordinary validation, narrowly scoped self-hosted pools for special workloads, and a separate protected deployment path. Choose per workload class rather than by ideology.

## Product-company interview

Interviewers at mature product companies look for boundaries, trade-offs, and proof. State assumptions, draw the path, identify state owners, choose a bounded action, and name what would change your mind.

### Question 1: Design CI for 500 repositories and 2,000 engineers

A strong answer begins with workload classification rather than a giant shared pool.

1. Clarify languages, operating systems, public contributions, release criticality, private-network needs, hardware, arrival bursts, service times, compliance, regions, recovery goals, and current source/identity/artifact systems.
2. Draw provider control plane, reusable-configuration service, isolated execution pools, artifact and cache services, identity broker, environment policy, deployment controller, and observability joins.
3. Separate untrusted, ordinary internal, protected release, and privileged infrastructure trust classes. Prefer ephemeral workers and immutable images.
4. Define a platform API: supported images, reusable jobs, artifact contract, permissions, SLOs, deprecation, exception expiry, and support.
5. Scale each eligible class from queue and service-time data. Bound autoscaling and preserve headroom.
6. Release runner images and shared templates through canaries and cohorts.
7. Use short-lived workload identity and target-side policy. Build once and promote by digest.
8. Measure ready-to-assigned, start success, artifact success, reference-pipeline outcome, cost per successful job, and delivery/user evidence.
9. Plan provider/control-plane outage, artifact outage, identity outage, compromised worker, and shared-template rollback or roll-forward.

A weak answer says “Kubernetes runners with autoscaling” without discussing trust, state, quotas, or operations.

Follow-up: “Why not one pool?” Because selector convenience does not isolate code, credentials, networks, caches, or persistent hosts. One compromise could cross every delivery boundary.

### Question 2: Queue time jumped from one minute to twenty. What do you do?

Start with scope and freshness: which provider, region, project class, trust pool, architecture, and time window? Confirm jobs are ready rather than waiting on dependencies or approvals.

Then compare:

- arrivals and matrix fan-out;
- retry or cancellation amplification;
- ready queue age and backlog slope;
- eligible workers for sample queued jobs;
- online, healthy, enabled, busy, and provisioning workers;
- quotas, locks, and concurrency limits;
- service-time distribution and external dependency latency;
- recent runner image, label/tag/capability, policy, template, or provider changes.

Contain unsafe routing, halt a bad rollout, or reduce nonessential demand according to evidence. Canary one correction. Prove recovery with representative job assignment and falling backlog.

Do not begin by restarting the fleet or buying capacity; both can erase evidence or scale the wrong class.

### Question 3: How would you safely run public pull requests?

Assume repository code and dependencies are hostile. Use a dedicated low-trust execution boundary, preferably a fresh virtual machine or strongly isolated resource per job. Provide no production secrets or broad source token, restrict network and internal routes, avoid privileged runtime sockets, separate cache/artifact write namespaces, cap resources and time, validate uploaded content, and destroy the worker.

Do not later run a trusted job on that persistent host. Keep approval or label commands from untrusted actors from silently granting a privileged rerun. Review provider-specific fork-event behavior. Preserve non-secret evidence and monitor abuse.

If tests need private dependencies, use a narrowly scoped read-only broker or curated mirror designed for untrusted consumption rather than placing broad registry credentials on the worker.

### Question 4: Migrate from Jenkins to a hosted provider

Inventory Jenkins beyond `Jenkinsfile`: job and folder configuration, Shared Libraries, plugins, credentials, agents, labels, stashes/artifacts, triggers, parameters, approvals, locks, notifications, controller state, and UI-defined behavior.

Extract the portability contract. Move build logic into testable repository scripts where that improves portability, but keep policy in appropriate resource-owned controls. Build equivalent definitions with pinned dependencies. Dual-run build/test without production authority; compare artifact and failure behavior. Migrate in cohorts. Establish one deployment owner at cutover. Revoke old Jenkins credentials, agents, webhooks, and triggers; archive required evidence and retire controller state safely.

Do not reproduce every plugin. Ask which capability is still required and prefer provider-native or external standard mechanisms when their operational cost is lower.

### Question 5: A runner was compromised. What is your response?

Contain scheduling into its trust pool. Treat worker, processes, workspace, caches, artifacts, credentials, registrations, and reachable services as potentially affected. Coordinate credential revocation or expiry without printing values. Isolate the resource while preserving evidence. Trace all jobs before and after suspected compromise, outputs consumed by trusted paths, network calls, and external operations.

Destroy and rebuild from trusted immutable provisioning after evidence capture; do not clean in place. Validate image and registration control, restore capacity in a clean pool, and prove representative work. Address root architecture: trust mixing, persistent state, excessive network, long-lived credentials, mutable image, privileged socket, or weak monitoring.

### Question 6: How do you upgrade Jenkins plugins safely?

Maintain inventory and dependency reasons. Review exact core, Java, plugin compatibility and security guidance. Prove controller backup restore. Test the pinned candidate set on isolated representative configuration. Exercise Pipeline resumption, restart, agents, credentials integrations, artifacts, libraries, and failure paths. Canary where possible. Schedule a bounded rollout with freeze, downtime, abort, restore or roll-forward plan, and owners. Verify the full platform and remove unused plugins.

Explain that downgrade may not reverse data migration. “Take a backup” is incomplete until restoration is proved.

### Question 7: How do you compare GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines?

Map them to the same architecture, then compare responsibility.

- Hosted providers usually own more control-plane availability and upgrades; Jenkins operators own controller, storage, plugins, backup, and recovery.
- Every platform still requires pipeline-code governance, identity, worker trust, artifact policy, evidence, and cost management.
- GitHub uses workflows/actions and runner groups/labels; GitLab uses pipeline includes and runners/tags/executors; Jenkins uses Pipelines, Shared Libraries, plugins, nodes/agents/executors; Azure uses YAML/templates/tasks, pools/capabilities/demands, service connections, and resource-owned checks.
- Execution options, private networking, hardware, governance, integration, pricing, and organizational skills determine fit.

Recommend only after requirements. Avoid claiming one product is universally more secure; configuration and operating model dominate many risks.

### Question 8: Improve CI speed without reducing confidence

Measure event-to-feedback by phases: configuration, dependency wait, queue, provisioning, checkout, cache, build, test, artifact, and result publication. Draw the job graph and critical path. Optimize the controlling path first.

Possible actions: remove duplicate work; make dependencies explicit; shard a truly parallel long test with correct fan-in; improve deterministic dependency caching while keeping cold-cache correctness; prebuild immutable images; right-size workers; reduce checkout safely; schedule by workload; add qualified capacity; and cancel superseded validation while reconciling external effects.

Guardrails: same test selection or an explicit risk decision, identical artifact contract, flake rate, cache poison controls, tail latency, cost per successful result, and no privilege expansion.

### Question 9: Define an SLO for CI

Choose a user-relevant event. Example: “For protected Linux x64 jobs that become ready, 99.5 percent will be assigned to an eligible worker within two minutes over 28 days.” Define ready and assigned timestamps, supported hours if any, minimum sample and missing data, exclusions, dimensions, and owner.

Pair with configuration-evaluation, job-start, artifact, and reference-workflow indicators. Use error budget to constrain risky fleet and shared-template rollout. Do not call a dashboard threshold an SLA unless it is an external agreement.

### Question 10: Tell me about a production incident

Use an evidence-driven structure:

- user and delivery impact;
- first reliable signal and its limitation;
- architecture and state owner;
- hypotheses considered and evidence that rejected them;
- safe containment and its cost;
- smallest correction and rollback boundary;
- recovery proof across platform and user path;
- root contributing conditions, not a single human error;
- prevention with owner, deadline, and verification;
- what you would change in detection or design.

If using a real story, protect confidential names and values. Strong ownership includes uncertainty and lessons, not hero language.

### Interview follow-up drill

For any design answer, expect:

- What fails if the controller is unavailable?
- Where are secrets and who can read them?
- How do forks differ from protected branches?
- What is the blast radius of shared configuration?
- How do you roll back after data migration?
- Which metric tells you the system is actually recovered?
- What costs dominate at ten times load?
- Which claim is an assumption, and how would you test it?

If you can answer those with a diagram, identities, evidence, and a bounded action, you are reasoning like a platform operator rather than reciting product features.

## Independent transfer and rubric

### Assignment

Choose one non-sensitive pipeline you are authorized to review. Do not change it. If no such pipeline exists, use the four illustrative definitions in this lesson and clearly mark provider behavior as unexecuted.

Produce an operations dossier with seven parts.

#### Part A: architecture and state

Draw event, configuration resolver, graph, scheduler, worker pool, workspace, identity, cache, artifact store, policy, environment, deployment target, telemetry, and user path. Mark control and execution planes. Name the state owner at each boundary.

#### Part B: execution contract

Complete every portability-contract field for at least `build` and `test`, plus `deploy` if it exists. Unknown values must remain unknown with a proposed read-only evidence source.

#### Part C: provider comparison

Map the pipeline to GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines. For each, identify entry configuration, reusable dependencies, selector mechanism, hosted or self-hosted boundary, permission mechanism, artifact handoff, concurrency, and environment control. Do not claim execution unless you actually ran it in an authorized lab and preserved evidence.

#### Part D: queue incident

Given this signal—“jobs queued, workers online”—write three competing hypotheses. For each, name predicted evidence, one bounded read-only check, and a result that would falsify it. Select containment that does not weaken trust.

#### Part E: upgrade plan

Choose a runner image/agent upgrade or Jenkins plugin/controller change. Provide inventory, candidate identity, compatibility suite, canary scope, metrics, abort threshold, drain process, rollback or roll-forward boundary, recovery proof, and exception expiry.

#### Part F: reliability and economics

Define one queue SLI and objective with exact population and window. Propose capacity telemetry and a bounded autoscaling rule. Compare hosted and self-hosted cost categories without inventing prices.

#### Part G: proof limits

List at least ten statements your evidence cannot establish. Include provider execution, worker isolation, effective authority, artifact safety, cancellation of external effects, user recovery, and current provider behavior where applicable.

### Constraints

- No cloud, provider, runner, controller, plugin, pipeline, environment, or credential mutation.
- No secret value, private endpoint, personally identifiable information, or confidential source in the submission.
- No `sudo`, installation, broad recursive search, or unapproved network access.
- Local commands must include purpose, path/scope, risk, expected branches, proof, and proof limit.
- Screenshots may support orientation but cannot replace machine-readable identity or text evidence.
- Any real organization detail must be sanitized without changing the technical mechanism.

### Deliverable outline

```text
1. Scope, assumptions, and authorization
2. Architecture diagram plus text alternative
3. State ownership and identity table
4. Two or three job execution contracts
5. Four-provider portability matrix
6. Queue incident hypotheses and decision tree
7. Upgrade runbook
8. SLI/SLO, capacity, observability, security, and cost analysis
9. Local command evidence and before/after state
10. Proof limits and unanswered questions
```

### Rubric: 100 points

| Area | Points | Full-credit evidence | Critical miss |
|---|---:|---|---|
| Independent reasoning, scope, and evidence integrity | 10 | prior exposure and hypotheses recorded first; authorization, raw non-sensitive evidence, and unknowns preserved | copies answer material, invents provider execution, or bypasses scope |
| Architecture and control or execution boundaries | 10 | event, resolved configuration, graph, scheduler, worker, workspace, identity, stores, target, telemetry, user result, and text alternative | treats a dashboard or worker as the whole system |
| State ownership and immutable identity | 10 | source, reusable config, run/attempt, worker/image, permission, cache, artifact, environment and target operation separated | uses a branch, tag, run number, or green icon as immutable release proof |
| Provider mapping and portability contract | 10 | typed contract plus accurate four-provider mechanisms and material differences; unexecuted claims labeled | claims mechanical keyword translation is equivalent |
| Queue incident diagnosis | 10 | falsifiable readiness, eligibility, availability, provisioning and service-time hypotheses with class-specific evidence | weakens trust or restarts/scales without evidence |
| Security and trust boundaries | 10 | event trust, worker persistence, effective authority, network, reusable dependencies, caches, artifacts and outputs evaluated | exposes a secret or routes untrusted code to privileged persistent state |
| Upgrade and change operations | 10 | inventory, immutable candidate, canary, representative tests, drain, thresholds, bounded waves, rollback/forward evidence | fleet-wide unbounded change or unsupported downgrade assumed safe |
| Reliability, observability, capacity, and cost | 10 | defined fresh SLI/SLO, eligible-class capacity, scaling bounds, controlled dimensions and total-cost trade-off | hides a broken class with global averages or invents price/evidence |
| Migration, recovery, and external effects | 10 | dual-run without duplicate authority, one immutable artifact, stable operation reconciliation, cohort cutover, revocation, target/user proof | blindly retries unknown effects or leaves two production writers |
| Communication and proof limits | 10 | concise diagrams and senior explanation, assumptions, unknowns, chronological evidence and at least twelve narrow limits | claims production proof or mastery from local model, screenshot or page completion |

Reviewer outcome:

- **Ready for the next supervised exercise:** at least 80 points, no critical miss, all constraints followed, and the learner explains two reviewer-selected branches without notes.
- **Revise:** any critical miss, safety violation, unsupported provider claim, or score below 80. The reviewer identifies evidence to add; reading the answer key does not change the outcome.

This rubric is a learning gate, not a claim of professional mastery. Publication, page completion, or a self-reported score does not award mastery.

### Assessments

- `ASM-0058`: terminology, architecture, selectors, identities, caches versus artifacts, and proof limits.
- `ASM-0059`: queue, compromised-worker, shared-dependency, upgrade, cancellation, and migration scenarios.
- `ASM-0060`: the independent operations dossier and oral defense using the rubric above.

The canonical records exist at `book/assessments/engineering/ASM-0058.json`, `ASM-0059.json`, and `ASM-0060.json`, with the independent response template beside them. They pass schema and cross-record validation and are loaded through the generated canonical registry. `ASM-0060` still requires a qualified reviewer; the guided engineering verifier does not grade the learner's reasoning.

### Reviewer calibration questions

Use these to distinguish memorization from transfer:

1. Change the incident from Linux x64 to a protected ARM64 job. Which evidence dimensions change?
2. Make the worker eligible but all executors busy. Which branch of the decision path changes?
3. Let a cancelled attempt publish a package. How does the recovery plan change?
4. Move a permission from provider token to a host credential. Why does the YAML review miss it?
5. Make a template immutable but malicious. What did pinning prove and what did it not prove?

A strong learner updates the model without discarding the invariant architecture.

## References and review

This chapter uses primary provider documentation for behavior that can change. The lesson remains provider-neutral where a stronger universal claim would be unsafe. Before production use, check the exact current product edition, plan, instance version, runner/agent version, plugin/task/action version, administrator configuration, and official security guidance.

### Reference registry

| ID | Primary source | Canonical URL | Used for | Review caution |
|---|---|---|---|---|
| `REF-0153` | GitHub Docs, workflow syntax for GitHub Actions | `https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax` | events, jobs, dependencies, permissions, `runs-on`, environments, concurrency, timeout syntax concepts | syntax and defaults evolve; repository and organization policy can narrow behavior |
| `REF-0154` | GitHub Docs, managing access to self-hosted runners and self-hosted runner security guidance | `https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/manage-access` | runner groups, labels, administrative access, public-fork risk, self-hosted responsibility | plan availability and user-interface paths can change; labels are not attestations |
| `REF-0155` | GitLab Docs, CI/CD YAML syntax reference | `https://docs.gitlab.com/ci/yaml/` | includes, jobs, `needs`, artifacts, cache, resource groups, rules and configuration behavior | GitLab version and tier matter; expanded config must be inspected for the actual instance |
| `REF-0156` | GitLab Docs, configure runners | `https://docs.gitlab.com/ci/runners/configure_runners/` | tag matching, protected-runner direction, protected branches and tags, runner security configuration | organization-specific dedicated-runner requirements still need explicit tags, scope and policy |
| `REF-0157` | Jenkins Documentation, Pipeline Shared Libraries | `https://www.jenkins.io/doc/book/pipeline/shared-libraries/` | trusted versus untrusted libraries, source control, versions, privilege implications | behavior depends on Jenkins core, plugins, sandbox, and administrator configuration |
| `REF-0158` | Jenkins Documentation, managing plugins | `https://www.jenkins.io/doc/book/managing/plugins/` | plugin installation, dependencies, updates, controller operations and restart considerations | exact compatibility and recovery require release-specific upgrade guides and backups |
| `REF-0159` | Microsoft Learn, Azure Pipelines agents | `https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents` | Microsoft-hosted and self-hosted agents, pools, capabilities, demands, lifecycle | service behavior, hosted images, agent versions, and organization policy change |
| `REF-0160` | Microsoft Learn, approvals and checks | `https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals` | resource-owned checks, approvals, exclusive lock and protected transitions | check availability and semantics depend on resource type and service version |
| `REF-0161` | Microsoft Learn, `pr` definition | `https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/pr` | repository support boundary for YAML pull-request triggers | Azure Repos Git uses branch-policy build validation rather than this YAML trigger |
| `REF-0162` | Microsoft Learn, Publish Pipeline Artifacts v1 task | `https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-pipeline-artifact-v1` | publish-task syntax and Azure DevOps Services-only boundary | Azure DevOps Server requires a supported alternative |
| `REF-0163` | Microsoft Learn, Download Pipeline Artifacts v2 task | `https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/download-pipeline-artifact-v2` | download-task syntax and Azure DevOps Services-only boundary | artifact authorization, retention, and integrity still require organization evidence |

The canonical schema records `book/references/REF-0153.json` through `REF-0163.json` mirror this table, pass schema and cross-record validation, and are loaded through the generated canonical reference registry.

### Review method

On every scheduled review:

1. open each canonical source directly, not a search-result summary;
2. record page title, publisher, access date, and relevant product/version scope;
3. compare claims about selectors, configuration snapshots, permissions, self-hosted security, reusable code, agents, plugins, and approvals;
4. check whether syntax examples still validate under current official tooling;
5. inspect security advisories and upgrade guidance separately from feature documentation;
6. update lesson claims narrowly and preserve historical limitations;
7. run schema, link, heading, command, and website build checks;
8. require technical review for any change that expands authority or changes incident guidance.

### Current verification boundary

As of the lesson review date:

- provider documentation was used to review conceptual mappings;
- local shell and Python models are designed for Ubuntu 24.04 boundaries;
- two purpose-built local CI teaching engines execute the same typed build-and-test operation, compare observed output plus declared-field drift, run a corrected fixture, and pass deterministic lifecycle verification without claiming behavioral enforcement;
- the four pipeline definitions were not executed;
- no hosted provider, Jenkins controller, runner, agent, plugin, token, service connection, environment, or deployment was created;
- two-vendor-platform execution acceptance is unmet; the local teaching engines are not substitutes for GitHub, GitLab, Jenkins, or Azure execution;
- assessment and reference records are canonical, schema-validated, and registry-backed;
- the guided lab has an engineering verifier, while independent reasoning still requires a qualified reviewer and later transfer evidence.

### Definition of done for future formal acceptance

The chapter can move beyond substantive-draft status only when all of these are true:

- metadata validates and all IDs resolve;
- exact eighteen section headings remain in canonical order;
- commands pass static safety checks and execute in the declared local environments;
- at least two local CI engines run the same pinned operation, compare observed artifacts and declared fields, and keep behavioral-equivalence claims separate;
- the remaining provider definitions pass current official syntax or review mechanisms;
- success, failure, selector mismatch, cache miss, artifact handoff, timeout, cancellation, and permission-negative cases are captured;
- setup, abort, recovery, cleanup, and cleanup proof are independently verified;
- artifact digests and expanded configuration identities can be compared;
- assessments and response templates exist and a reviewer can apply the rubric;
- official references resolve and claims receive technical review;
- website rendering, dark mode, diagrams, code wrapping, navigation, and search are verified;
- no personal name, secret, private endpoint, credential, or unsupported mastery claim appears.

Until then, use the published chapter as a deep operations draft and practice guide. Do not use it as evidence that any provider setup, production control, or learner mastery has been verified.


“Runner online” is a component signal. “One trivial job green” is a probe. Neither alone is service recovery.
