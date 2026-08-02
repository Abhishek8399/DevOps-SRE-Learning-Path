---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0007",
  "aliases": ["V00-L01", "systems-thinking"],
  "curriculumIds": ["FND-001"],
  "slug": "systems-thinking",
  "route": "/book/start/systems-thinking",
  "order": 1,
  "volume": "00-start-safely",
  "title": "Systems thinking: state, queues, dependencies, and failure domains",
  "summary": "Learn to see a production system as work crossing owned boundaries, then distinguish latency, throughput, queueing, saturation, feedback, and failure domains before changing anything.",
  "domain": "foundations",
  "level": {
    "from": "foundation",
    "to": "expert"
  },
  "estimatedMinutes": 210,
  "prerequisiteLessonIds": [],
  "prerequisiteCurriculumIds": [],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The guided experiment runs as a normal non-root user with Bash, Python 3.8 or newer, and the exact base utilities named in CMD-002. It uses no external package, network, port, container, mount, or privileged operation."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The same deterministic virtual-time experiment is supported. The model does not use host sleep or scheduling time, so the versioned profile summaries should match exactly while the shell command's wall-clock duration can vary."
    },
    {
      "platform": "Docker, Kubernetes, cloud, and private-cloud systems",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Production transfer explains queues, controllers, control planes, data planes, and failure domains without creating any container, cluster, account, virtual machine, or paid resource."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "cloud-infrastructure-engineer",
    "production-engineer",
    "data-platform-engineer",
    "technical-lead"
  ],
  "learningObjectives": [
    "Draw a system as work moving through explicit components, interfaces, dependencies, queues, state transitions, and consumer-visible outcomes.",
    "Separate latency, queue wait, service time, throughput, offered load, concurrency, utilization, saturation, capacity, and backlog without treating them as synonyms.",
    "Identify which owner holds each state and which evidence point can confirm a transition across a boundary.",
    "Explain how backpressure, load shedding, retries, and feedback loops can stabilize or destabilize a system.",
    "Distinguish a control-plane report from data-plane behavior and a component symptom from the first abnormal boundary.",
    "Use a bounded local experiment to compare stable, saturated, and recovered queue behavior while stating measurement limitations.",
    "Reason about failure domains, blast radius, headroom, and safe recovery before proposing scaling or restart actions.",
    "Communicate an incident hypothesis as facts, inference, uncertainty, safest next evidence, restoration, verification, and prevention."
  ],
  "productionSignals": [
    "Request latency rises while central processing unit use remains low.",
    "A queue depth or oldest-item age grows even though every process is running.",
    "Incoming work exceeds completed work and the difference accumulates over time.",
    "Adding frontend replicas increases pressure on a slower database, API, or storage dependency.",
    "Retries multiply traffic after a partial failure and make recovery slower.",
    "A controller reports the desired state accepted while the user-facing data path remains unavailable.",
    "One zone, rack, node pool, tenant, partition, or dependency fails and impact spreads beyond its intended boundary.",
    "Average latency looks normal while a small but important tail of requests becomes extremely slow."
  ],
  "diagrams": [
    {
      "id": "LES-0007-DIA-001",
      "title": "Work and evidence across system boundaries",
      "direction": "left-to-right",
      "boundaries": ["consumer intent", "admission", "queue", "worker", "dependency", "outcome", "feedback"],
      "evidencePoints": ["request or job ID", "accepted or rejected count", "queue depth and age", "start and finish timestamps", "dependency latency and result", "consumer-visible result", "controller or autoscaler decision"],
      "textAlternative": "A work item moves from a consumer through admission, a queue, a worker, and a dependency to an outcome; evidence at every boundary shows whether the item advanced, waited, failed, or was rejected, while feedback can change future admission or capacity."
    },
    {
      "id": "LES-0007-DIA-002",
      "title": "Stable queue, growing queue, and recovery",
      "direction": "top-to-bottom",
      "boundaries": ["arrival process", "waiting queue", "worker capacity", "completion stream"],
      "evidencePoints": ["arrival interval", "queued item count", "oldest-item age", "active workers", "service duration", "completion rate", "queue-wait percentiles"],
      "textAlternative": "When service capacity stays above offered load, waiting remains bounded; when offered load stays above capacity, backlog and queue wait grow; recovery requires admitted load below effective capacity long enough to drain existing work."
    },
    {
      "id": "LES-0007-DIA-003",
      "title": "Control loop and failure-domain boundaries",
      "direction": "cyclic",
      "boundaries": ["desired state", "controller observation", "decision", "data-plane change", "consumer result", "failure domain"],
      "evidencePoints": ["configuration revision", "reconcile timestamp", "decision reason", "ready capacity", "real operation result", "zone or tenant label"],
      "textAlternative": "A controller compares desired and observed state, decides, and changes the data plane; consumer results feed later decisions, while explicit failure-domain labels show whether one fault is contained or correlated across the system."
    }
  ],
  "commands": [
    {
      "id": "LES-0007-CMD-001",
      "question": "Which operating-system baseline and user identity will produce this experiment's evidence?",
      "risk": "read-only",
      "command": "cat /etc/os-release; printf 'uid=%s\\n' \"$(id -u)\"; uname -sr",
      "runFrom": "The exact Ubuntu 24.04 or WSL 2 Ubuntu shell used for the lesson",
      "expectedBranches": [
        {
          "when": "Ubuntu 24.04 is reported and uid is not 0",
          "meaning": "The environment matches the tested release and the lab will run as a normal user.",
          "nextEvidence": "Check every required command before setup."
        },
        {
          "when": "The release differs or uid is 0",
          "meaning": "Output or safety behavior can differ, or the shell has more privilege than the host lab permits.",
          "nextEvidence": "Record the version difference, or stop and open a normal non-root Ubuntu shell."
        }
      ],
      "proves": "The release metadata, numeric effective user ID, kernel name, and kernel release visible to this shell.",
      "doesNotProve": "That dependencies exist, the harness accepts /tmp, the host is otherwise healthy, or the learner understands the model."
    },
    {
      "id": "LES-0007-CMD-002",
      "question": "Are all required local commands already available before any setup?",
      "risk": "read-only",
      "command": "command -v bash basename cat chmod cmp dirname find grep id install mktemp python3 realpath rmdir rm stat",
      "runFrom": "The same normal-user Ubuntu shell",
      "expectedBranches": [
        {
          "when": "A path is printed for every command and the exit status is zero",
          "meaning": "Every executable required by the versioned harness is discoverable through this shell's current PATH.",
          "nextEvidence": "Run the guarded check because presence does not prove compatible Python, identity, /tmp, fixture, or state behavior."
        },
        {
          "when": "One or more commands are missing or the exit status is nonzero",
          "meaning": "The experiment has an unmet dependency.",
          "nextEvidence": "Stop. Review the missing-command-to-package mapping separately; this lesson never installs automatically."
        }
      ],
      "proves": "Whether this shell can resolve each named command through its current PATH.",
      "doesNotProve": "The command version, provenance, behavior, or whether another shell, container, or host resolves the same executable."
    },
    {
      "id": "LES-0007-CMD-003",
      "question": "Does the lab accept this normal-user environment and current lesson state without mutation?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh check",
      "runFrom": "Repository root in the normal-user Ubuntu shell",
      "expectedBranches": [
        {
          "when": "environment=ready and state=absent are reported",
          "meaning": "The required tools, Python 3.8 or newer, normal-user identity, root-owned sticky /tmp, source fixture, and absence of a UID-scoped state descriptor passed.",
          "nextEvidence": "Make a prediction, then run setup."
        },
        {
          "when": "environment=ready and state=ready are reported",
          "meaning": "A previously created workspace passed strict state and artifact validation.",
          "nextEvidence": "Read profiles_completed and continue only the intended lifecycle."
        },
        {
          "when": "The check refuses",
          "meaning": "A dependency, privilege, /tmp, fixture, state, path, identity, artifact, or summary precondition is not satisfied.",
          "nextEvidence": "Follow the exact refusal message; never bypass guards or delete an unknown path."
        }
      ],
      "proves": "That the implemented preflight and any applicable strict state checks accepted the current environment at that moment.",
      "doesNotProve": "That Ubuntu release metadata was checked by the harness, that later mutation must succeed, or that a refusal is safe to override."
    },
    {
      "id": "LES-0007-CMD-004",
      "question": "Can the lab create one private, identity-guarded workspace?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh setup",
      "runFrom": "Repository root after a successful absent-state check, as the same normal user",
      "expectedBranches": [
        {
          "when": "setup=complete, state=ready, and a lesson-prefixed lab_root are reported",
          "meaning": "The harness created a mode-0700 workspace, private state descriptor and sentinel, exact manifest, and reviewed model copy.",
          "nextEvidence": "Run status and confirm the lesson ID, path prefix, empty completion list, execution mode, and profile contract."
        },
        {
          "when": "setup=already-present is reported",
          "meaning": "An existing workspace passed strict validation and setup made no replacement.",
          "nextEvidence": "Run status and continue only the intended lifecycle."
        },
        {
          "when": "Setup refuses",
          "meaning": "The harness cannot safely create or recognize the intended workspace.",
          "nextEvidence": "Stop and preserve the refusal; never substitute recursive manual deletion."
        }
      ],
      "proves": "That setup passed its implemented guards and created or strictly recognized the declared lesson-owned resources.",
      "doesNotProve": "That profiles have run, the filesystem is trustworthy beyond the checked boundary, or cleanup will later succeed.",
      "cleanup": "After the exercises, run the guarded lab.sh cleanup and retain its cleanup_proven=true result."
    },
    {
      "id": "LES-0007-CMD-005",
      "question": "What does the bounded queue model report when nominal service capacity exceeds offered load?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh run stable",
      "runFrom": "Repository root after setup, as the owning normal user",
      "expectedBranches": [
        {
          "when": "The exact 19-key stable summary is reported with completed=12, max_queue=0, and no backpressure",
          "meaning": "The version-1 deterministic profile completed all work without waiting or admission delay.",
          "nextEvidence": "Compare offered_rate_per_s=2.500 with nominal_capacity_per_s=3.333 and explain the finite-batch limitation."
        },
        {
          "when": "The profile already exists, output differs, or validation refuses",
          "meaning": "The intended one-run lifecycle or deterministic state contract is not satisfied.",
          "nextEvidence": "Keep the refusal, inspect status, and use guarded reset only when its narrower cleanup identity contract accepts the state."
        }
      ],
      "proves": "The simulator's exact configured inputs and virtual-time results for one stable-profile run.",
      "doesNotProve": "Host wall-clock performance, scheduler behavior, a universal throughput limit, or production capacity.",
      "cleanup": "The profile writes one private summary inside the validated workspace; final cleanup removes only allowlisted, identity-checked artifacts."
    },
    {
      "id": "LES-0007-CMD-006",
      "question": "What changes when offered load remains above one worker's nominal service capacity?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh run saturated",
      "runFrom": "The same guarded workspace after the stable profile",
      "expectedBranches": [
        {
          "when": "The exact saturated summary reports completed=12, max_queue=3, backpressure_jobs=7, and higher wait and completion latency",
          "meaning": "The finite batch drained, but the bounded queue filled and offered work waited outside admission because one worker could not match the offered rate.",
          "nextEvidence": "Separate admission delay, queue wait, service time, and offered-to-completion latency before comparing recovery."
        },
        {
          "when": "The profile already exists, output differs, or validation refuses",
          "meaning": "The one-run order, deterministic fixture, or guarded artifact contract is not satisfied.",
          "nextEvidence": "Stop further profiles and preserve status; do not edit a summary to force the expected result."
        }
      ],
      "proves": "The exact queue, backpressure, and virtual-time behavior of the versioned finite saturated profile.",
      "doesNotProve": "That high host CPU must accompany saturation, every production queue behaves identically, or added workers are safe.",
      "cleanup": "The profile has fixed jobs, virtual-time bounds, queue capacity, key order, and values; guarded cleanup removes only validated, allowlisted artifacts."
    },
    {
      "id": "LES-0007-CMD-007",
      "question": "What does the model report when worker capacity matches the same offered rate?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh run recovered",
      "runFrom": "The same guarded workspace after the saturated profile",
      "expectedBranches": [
        {
          "when": "The exact recovered summary reports three workers, completed=12, max_queue=0, and no backpressure",
          "meaning": "Within this deterministic model, nominal capacity equal to the offered rate prevents waiting for the configured spacing.",
          "nextEvidence": "Compare all 19 fields; in production, inspect shared dependency capacity before adding workers."
        },
        {
          "when": "The profile already exists, output differs, or validation refuses",
          "meaning": "The intended one-run order, fixture, or artifact contract is not satisfied.",
          "nextEvidence": "Inspect the exact refusal and status; do not infer host load from this virtual-time model."
        }
      ],
      "proves": "The exact outcome of the versioned recovered profile under its configured inputs.",
      "doesNotProve": "That production scaling has no cost, downstream dependencies accept more concurrency, or an existing production backlog is gone.",
      "cleanup": "Use the same guarded final cleanup and retain its built-in absence proof."
    },
    {
      "id": "LES-0007-CMD-008",
      "question": "Which guarded workspace and profile summaries does the harness currently recognize?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh status",
      "runFrom": "Repository root while a setup state exists for the same normal user",
      "expectedBranches": [
        {
          "when": "The seven status fields are reported and profiles_completed matches the intended run order",
          "meaning": "Strict validation passed and the harness summarized its lesson ID, canonical root, completed profiles, virtual execution mode, queue capacity, and available profiles.",
          "nextEvidence": "Continue only the missing profile or proceed to guarded cleanup."
        },
        {
          "when": "Status refuses that state is absent",
          "meaning": "No UID-scoped state descriptor is available for status to load.",
          "nextEvidence": "Run the read-only check to distinguish a clean absent state from an environment refusal."
        },
        {
          "when": "Status refuses strict validation",
          "meaning": "The registered state, root identity, sentinel, allowlist, known artifact, mode, link count, model copy, or summary differs from the strict contract.",
          "nextEvidence": "Stop and preserve the exact refusal; use reset only if its documented cleanup identity checks can safely recover known-file drift."
        }
      ],
      "proves": "The seven-field summary printed after strict state and artifact validation at that moment.",
      "doesNotProve": "Learner mastery, host performance, or the absence of unrelated processes or files elsewhere."
    },
    {
      "id": "LES-0007-CMD-009",
      "question": "Can the harness remove only the exact lesson-owned resources accepted by its cleanup identity checks?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh cleanup",
      "runFrom": "Repository root after recording the intended profile evidence, as the owning normal user",
      "expectedBranches": [
        {
          "when": "cleanup=complete, state=absent, and cleanup_proven=true are reported",
          "meaning": "The harness removed each allowlisted single-link regular file, the validated root, and its state descriptor, then checked both recorded paths were absent.",
          "nextEvidence": "Run the read-only check and retain its state=absent line as a second lifecycle observation."
        },
        {
          "when": "cleanup=already-clean, state=absent, and cleanup_proven=true are reported",
          "meaning": "No UID-scoped state descriptor existed, so there was no registered target to remove.",
          "nextEvidence": "Do not infer anything about an unregistered path; close only the registered lifecycle."
        },
        {
          "when": "Cleanup refuses",
          "meaning": "Root or sentinel identity, the artifact allowlist, file type, ownership, or hard-link safety cannot be proven.",
          "nextEvidence": "Stop. Do not use rm -rf; preserve the refusal for reviewed recovery."
        }
      ],
      "proves": "For a registered state, the guarded cleanup completed and its exact recorded root and state descriptor were absent at the final check.",
      "doesNotProve": "That shell history, operating-system audit records, caches, or unrelated temporary paths are absent.",
      "cleanup": "The same command is idempotent when the UID-scoped state descriptor is already absent."
    },
    {
      "id": "LES-0007-CMD-010",
      "question": "Does the read-only preflight now observe no registered lesson state for this user?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh check",
      "runFrom": "Repository root immediately after cleanup",
      "expectedBranches": [
        {
          "when": "environment=ready and state=absent are reported",
          "meaning": "No UID-scoped state descriptor exists and the environment remains acceptable.",
          "nextEvidence": "Retain cleanup_proven=true plus this state=absent observation and close the learner lab."
        },
        {
          "when": "Check refuses or reports state=ready",
          "meaning": "The environment or registered lifecycle does not match the expected post-cleanup state.",
          "nextEvidence": "Stop and inspect the exact output; do not manually remove an unverified path."
        }
      ],
      "proves": "The absence of the UID-scoped state descriptor at this later check, plus current environment acceptance.",
      "doesNotProve": "The identity of an unregistered directory; the preceding guarded cleanup is the proof for its recorded root."
    },
    {
      "id": "LES-0007-CMD-011",
      "question": "Can the clean-state verifier exercise the entire harness contract, including safe refusals and cleanup?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/verify.sh",
      "runFrom": "Repository root only after the learner state is clean; the verifier refuses an active UID-scoped lesson state",
      "expectedBranches": [
        {
          "when": "verification_passed=true, the three profiles, three refusal cases, and cleanup_proven=true are reported",
          "meaning": "The verifier created isolated lesson state, checked deterministic outputs and repeat-run refusal, tested recovery from manifest tamper, tested refusal on an unexpected artifact, and cleaned its resources.",
          "nextEvidence": "Treat this as harness verification; learner interpretation still requires the assessments."
        },
        {
          "when": "The verifier refuses or exits nonzero",
          "meaning": "A lifecycle, deterministic-output, safety-refusal, or cleanup assertion failed.",
          "nextEvidence": "Preserve the first verification_error and do not weaken the guard to make the test pass."
        }
      ],
      "proves": "That the verifier's implemented clean-state lifecycle, deterministic profile, refusal, reset, and cleanup assertions passed on this environment.",
      "doesNotProve": "Learner mastery, production capacity, or the safety of manually deleting a refused target.",
      "cleanup": "The verifier installs traps and exercises guarded cleanup; confirm its final cleanup_proven=true. If it reports an error, follow the first diagnostic rather than deleting paths broadly."
    },
    {
      "id": "LES-0007-CMD-012",
      "question": "Can a recoverable known-artifact drift or interrupted run return to a new guarded setup?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0007-systems-thinking/lab.sh reset",
      "runFrom": "Repository root only when the UID-scoped state descriptor, root, sentinel identity, and every current entry still satisfy reset's cleanup identity and allowlist checks",
      "expectedBranches": [
        {
          "when": "Cleanup output, setup=complete, state=ready, a new lab_root, and reset=complete are reported",
          "meaning": "Reset removed the recognized allowlisted workspace through cleanup mode and created a new strict workspace.",
          "nextEvidence": "Run status, confirm profiles_completed=none, and rerun only the intended sequence."
        },
        {
          "when": "Reset refuses",
          "meaning": "The state descriptor, root, sentinel, artifact allowlist, type, owner, or hard-link identity cannot be safely recovered automatically.",
          "nextEvidence": "Stop and preserve the refusal; never weaken path, ownership, sentinel, or link checks."
        }
      ],
      "proves": "That the harness's narrower cleanup identity checks accepted the old state and setup created a new strictly validated workspace.",
      "doesNotProve": "That reset is appropriate during a production incident or safe for a path outside this exact lab.",
      "cleanup": "After reset, complete the intended profiles or run guarded cleanup; retain cleanup_proven=true."
    }
  ],
  "labs": [
    {
      "id": "LES-0007-LAB-001",
      "title": "See stable, saturated, and recovered queue behavior",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or Windows Subsystem for Linux (WSL 2) Ubuntu 24.04; normal non-root user; root-owned sticky /tmp; Bash, basename, cat, chmod, cmp, dirname, find, grep, id, install, mktemp, Python 3.8 or newer, realpath, rmdir, rm, and stat; no ports, Docker, Kubernetes, cloud account, external network, host sleep, or package installation",
      "timeMinutes": 40,
      "privilege": "Normal non-root user only; the harness refuses uid 0 and never invokes sudo",
      "network": "None; the simulator performs no socket operation, name lookup, download, or external request",
      "changes": [
        "Creates one mode-0700 lesson-prefixed temporary directory beneath /tmp and one mode-0600 UID-scoped state descriptor after path, owner, type, link, mode, and sentinel checks.",
        "Copies one reviewed deterministic queue-model fixture and writes a private sentinel, exact manifest, and up to three small key-value summary files.",
        "Runs one foreground Python process per profile; it advances integer virtual milliseconds in memory and exits without worker children, sockets, sleeps, or generated host load."
      ],
      "abortConditions": [
        "The shell runs as uid 0, a required command is missing, Python is older than 3.8, /tmp is not a real root-owned sticky directory, or the source fixture is missing, replaced, or a symbolic link.",
        "The state descriptor, root, sentinel identity, artifact allowlist, file type, owner, real path, basename prefix, hard-link count, required mode, manifest content, or copied model differs from the applicable strict contract.",
        "A path resolves outside the exact lesson prefix under /tmp, any owned entry becomes a symbolic link, or an unknown artifact appears.",
        "A profile violates its fixed job, worker, queue-capacity, virtual-time, ordered-key, or result-value invariants, or the foreground simulator returns nonzero."
      ],
      "recovery": "Run status first when strict validation still passes. Reset deliberately uses a narrower cleanup contract for allowlisted regular single-link files, so it can recover some known-file content or mode drift, but it still requires a valid UID-scoped state descriptor, canonical owned mode-0700 root, exact private sentinel identity, and no unknown or unsafe entry. If reset refuses, stop; preserve the diagnostic and never substitute recursive deletion or broad signaling.",
      "cleanupProof": "lab.sh cleanup validates the registered identity and allowlisted entries, removes only known resources, checks the exact recorded root and UID-scoped state descriptor are absent, and emits cleanup_proven=true. A following lab.sh check can observe state=absent. verify.sh is a separate mutating clean-state harness verifier, not a present/absent subcommand and not a prerequisite for learner cleanup.",
      "path": "book/labs/LES-0007-systems-thinking"
    }
  ],
  "incidents": [
    {
      "id": "LES-0007-INC-001",
      "signal": "Payment requests slow from 180 ms to 14 s, worker CPU stays near 35 percent, the accepted-work rate remains 900 per second, completions fall to 520 per second, and oldest queued work reaches six minutes.",
      "firstThought": "This is a flow imbalance, not proof of a CPU problem: work enters faster than it completes, so locate the first queue or dependency whose effective service capacity fell.",
      "safePath": "Define the user operation and recovery target; freeze the affected cohort; compare accepted, completed, rejected, retry, queue-depth, oldest-age, worker-concurrency, and downstream latency signals on one timeline; protect the dependency with admission control or a reviewed traffic reduction; restore completion rate above admitted rate; verify backlog age drains and a real payment succeeds.",
      "trap": "Adding frontend replicas or retries because CPU is low can admit even more work, overload the shared dependency, lengthen recovery, and hide the first failure."
    },
    {
      "id": "LES-0007-INC-002",
      "signal": "A platform controller accepts a rollout, repeatedly creates replacements, and reports reconciliation active, while ready capacity falls across two zones and each failed replacement triggers immediate retries against the same image and secret services.",
      "firstThought": "Separate control-plane activity from data-plane readiness and treat the retry loop as a feedback amplifier that may cross failure domains.",
      "safePath": "Pause the rollout through the approved reversible mechanism; preserve revision, reconcile reason, retry rate, per-zone ready capacity, dependency errors, and consumer results; compare one affected and one healthy boundary; restore the last verified revision or remove the triggering fault; resume with bounded backoff, jitter, canary scope, and a readiness-based rollback threshold.",
      "trap": "A busy controller is not a healthy platform. Increasing reconcile frequency or replacing more instances can coordinate a larger outage and exhaust shared dependencies."
    }
  ],
  "assessmentIds": ["ASM-0004", "ASM-0005", "ASM-0006"],
  "referenceIds": ["REF-0009", "REF-0010", "REF-0011", "REF-0012", "REF-0013", "REF-0014", "REF-0015", "REF-0016"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2026-11-02",
  "limitations": [
    "The guided lab is a bounded user-space simulator, not a benchmark of the kernel, Python, storage, a real message broker, or any production service.",
    "Finite profiles begin with an empty queue and have no warm-up interval, so measured throughput and percentiles illustrate relationships rather than steady-state capacity.",
    "Profile timestamps are deterministic virtual milliseconds rather than host wall or monotonic time; they teach relationships but cannot measure real scheduler, runtime, network, or storage latency.",
    "The chapter introduces an operational queue relationship but does not teach formal queueing distributions, stochastic proofs, or capacity forecasting.",
    "Provider-specific autoscalers, brokers, controllers, and billing models remain later lessons; examples here are mechanism-first and provider-neutral.",
    "No content publication, answer reveal, completed profile, bookmark, or reading marker is learner mastery; independent evidence and authorized review remain required."
  ]
}
---

# Systems thinking: state, queues, dependencies, and failure domains

## What you see and first thought

When a system becomes slow, the loudest graph is often not the owner of the problem. A frontend can show long request latency while its central processing unit (CPU) is quiet. A worker can be running while work waits for minutes. A controller can say it accepted the desired state while users still cannot complete the operation.

Your first sentence should therefore not be "scale it," "restart it," or "CPU looks fine." Say:

> Work is failing to cross one or more boundaries at the expected rate. I will map the work path, find where state is owned, and locate the first abnormal transition before changing capacity or retry behavior.

That sentence is systems thinking. You stop treating the visible component as an isolated box and start treating the service as a chain of owned states, rates, queues, dependencies, and feedback.

### Read these signals as relationships

| What you see | Where your mind should go | What it does not prove |
|---|---|---|
| latency rises | separate queue wait, service time, dependency time, and network time | the slowest-looking process is causal |
| queue depth rises | compare admitted rate with completed rate and oldest-item age | the queue software is broken |
| CPU is low | look for waiting, locks, connection pools, quotas, remote dependencies, and admission limits | spare CPU means spare service capacity |
| replicas increase but throughput does not | find the shared bottleneck and effective concurrency limit | autoscaling failed |
| retries rise after errors | test whether feedback is amplifying offered load | retries improve availability |
| control plane says accepted | inspect actual data-plane state and a consumer operation | the requested outcome exists |
| average latency is normal | inspect percentiles, errors, drops, and affected cohorts | every user is healthy |

Keep three labels separate:

- A **fact** is directly observed within a stated boundary and time window.
- An **inference** is a conclusion supported by facts but still limited.
- A **hypothesis** is a testable explanation that may be wrong.

"Completions fell from 900 to 520 per second" can be a fact. "The queue is growing because admitted work now exceeds completions" is a bounded inference if both rates share the same boundary and interval. "The database pool is the bottleneck" is a hypothesis until dependency and pool evidence separates it from other owners.

## Terms before commands

### System, component, boundary, and interface

A **system** is a set of parts whose interaction produces an outcome. A **component** is one part, such as an application programming interface (API), queue, worker, database, controller, or load balancer. A **boundary** is where ownership or behavior changes. An **interface** is the contract used to cross that boundary: a function call, file, queue message, network request, command, or desired-state record.

On call, name the boundary precisely. "The service is slow" is vague. "The API accepted job `J`, but the worker queue did not record it within two seconds" identifies an operation, two owners, and a missing transition.

### Work item, path, state, and transition

A **work item** is one unit the system must handle: a request, payment, build, pod reconciliation, backup block, log batch, or database query. Its **path** is the ordered set of boundaries it must cross. **State** is what an owner currently records about the item. A **transition** is a change such as `created -> admitted -> queued -> running -> complete`.

State never floats in the air. Ask who owns it, where it is stored, when it changed, and which identifier connects it to the next owner.

### Dependency and critical path

A **dependency** is another component or resource required for an operation. The **critical path** is the sequence of work that determines the operation's completion time. A dependency can be healthy in general but slow for one tenant, region, query, identity, or request shape.

Temporal order helps you trace a path, but "A happened before B" does not prove A caused B.

### Queue and backlog

A **queue** holds admitted work that has not yet begun service. A **backlog** is unfinished work, which may include queued and in-progress items depending on the metric definition. Queue depth is a count. **Oldest-item age** is elapsed time, usually seconds. The same depth can mean very different risk when items are tiny versus expensive or when new work has different priority.

### Arrival rate, offered load, service rate, and throughput

**Arrival rate** is how many work items arrive per time unit. **Offered load** includes all work presented to the system, including work that may later be rejected or retried. **Service rate** is how quickly one worker or service resource can complete work under stated conditions. **Throughput** is the observed completion rate across a defined boundary and interval.

Rates need units and boundaries: "520 completed payments per second at the worker-output boundary during the last five minutes" is useful. "Throughput is 520" is not.

### Latency, queue wait, and service time

**Latency** is elapsed time between two named points. **Queue wait** is time from admission into a queue until service starts. **Service time** is time spent actively handling the item within the chosen service boundary. End-to-end latency can also include network, dependency, retry, serialization, and scheduling time.

Always name clock, start, end, unit, and population before comparing latency.

### Concurrency and parallelism

**Concurrency** is the number of work items in progress or allowed to overlap. **Parallelism** is work actually executing at the same instant on separate execution resources. A service may permit 100 concurrent requests while only 8 operations execute in parallel and the rest wait for a pool or dependency.

More concurrency can raise throughput until a shared limit is reached. Beyond that point it can increase contention, memory use, queueing, timeouts, and downstream overload.

### Utilization and saturation

**Utilization** is the fraction of a resource's available time or capacity being used over an interval. **Saturation** means demand exceeds the resource's immediately available service capacity, so work waits, is rejected, or times out.

CPU utilization is only one resource signal. A system can be saturated on a connection pool, worker permit, disk queue, external quota, lock, partition, or single-threaded dependency while total CPU remains low.

### Capacity, bottleneck, and headroom

**Capacity** is the sustainable work rate that meets a stated correctness and latency objective under stated conditions. A **bottleneck** is the constraining resource or stage for that workload now. **Headroom** is intentional safe capacity above expected demand for bursts, failures, recovery, and measurement error.

Capacity is not one permanent number. Payload, cache state, dependencies, failure mode, data distribution, software revision, and reliability objective all matter.

### Backpressure, admission control, and load shedding

**Backpressure** tells an upstream producer to slow down because downstream capacity is constrained. **Admission control** decides whether new work may enter. **Load shedding** deliberately rejects or degrades lower-priority work to preserve a more important path.

These are reliability mechanisms when explicit and measured. An unbounded queue is not backpressure; it delays failure while consuming time and resources.

### Feedback loop, retry, and cascading failure

A **feedback loop** uses observed results to change future input or capacity. Autoscaling is a feedback loop. So are retries. A stabilizing loop reduces the error between desired and observed behavior. A destabilizing loop reacts too strongly, too quickly, or to the wrong signal.

A **cascading failure** occurs when distress in one component increases pressure or failure in others. Immediate synchronized retries can turn a partial dependency failure into system-wide overload.

### Control plane and data plane

The **control plane** decides or records desired behavior: deploy, schedule, scale, route, or reconcile. The **data plane** performs user or workload operations. A successful control-plane request proves the decision was accepted at that boundary. It does not prove a ready workload, routed endpoint, readable object, completed payment, or healthy user journey.

### Failure domain and blast radius

A **failure domain** is a set of resources likely to fail together, such as one process, host, rack, zone, account, dependency, certificate authority, or deployment cohort. **Blast radius** is the scope of impact from a fault or change.

Redundancy helps only when replicas do not share the same hidden failure domain. Three replicas in one node pool using one credential and one database are not independent against those failures.

### Telemetry, evidence, counters, gauges, and percentiles

**Telemetry** is recorded information about behavior: metrics, logs, traces, events, profiles, and state. Evidence is telemetry interpreted with identity, boundary, unit, timestamp, and limitations.

A **counter** accumulates events until reset. A **gauge** reports a current or sampled value such as queue depth. A **rate** is change per time. A **percentile** is a position in a measured population: the 95th percentile queue wait means 95 percent of observed waits were at or below that value under the stated calculation. It does not identify one universal request or predict the future.

`p95` is shorthand for the 95th percentile; `p99` means the 99th percentile. Always ask which population, time window, units, exclusions, and calculation produced a percentile before comparing it.

### Steady state, transient, and the operational queue relationship

A **steady state** is an interval where workload and service behavior are stable enough that averages describe the same process. A **transient** is a change period such as a burst, rollout, failover, or backlog drain.

For a stable boundary, average work in the system is approximately throughput multiplied by average time in the system. This is often written `L = lambda * W`, where `L` is average work in the chosen boundary, `lambda` is completion rate, and `W` is average time. Do not apply it blindly during an unstable backlog, across mismatched populations, or with different time windows.

## Architecture map

### Diagram one: follow one work item and one identifier

```text
[consumer intent]
       |
       | request_id=R42
       v
[admission] --rejected/dropped--> [explicit outcome]
       |
       | accepted counter
       v
[queue] -- depth / oldest age / enqueue time
       |
       | dequeue time
       v
[worker] -- start / finish / result
       |
       | dependency_call_id=D9
       v
[dependency] -- latency / error / quota
       |
       v
[consumer-visible outcome]
       |
       `---- feedback: retries, scaling, rate limits, alerts
```

Read left to right. Each box owns state. Each arrow needs a join key or timestamp. If `R42` was accepted but never appears in the queue, the missing boundary is different from a job that entered the queue and waited for six minutes.

### Diagram two: capacity is a rate relationship

```text
arrivals                 waiting work                service
  every 100 ms ----->  [1][2][3]  ----->  one worker: 300 ms/item
  10 items/s                                  3.333 items/s capacity

offered rate > effective capacity
          |
          v
queue depth grows -> oldest age grows -> latency grows -> timeouts/retries

recovery requires:
admitted rate < effective capacity
          |
          v
new work completes AND old backlog drains
```

Finishing a finite batch does not mean the profile was stable. If arrivals stop, even an overloaded worker may eventually drain the queue. Production systems often continue receiving work, so recovery needs enough spare capacity for both current arrivals and accumulated backlog.

### Diagram three: control decisions can amplify a fault

```text
desired replicas
       |
       v
[controller] -- decision --> [data-plane workers]
      ^                           |
      | observed ready state      | user work
      |                           v
      +---------------------- [consumer result]

fault in shared dependency
       |
       +-> workers fail readiness
       +-> controller creates replacements
       +-> replacements retry dependency
       `-> dependency pressure increases

failure domains to label:
[zone A] [zone B] [shared identity] [shared database] [rollout cohort]
```

The controller may be operating exactly as configured while the combined loop is unsafe. Systems thinking asks whether the signal, delay, retry policy, and failure domains make the loop stabilizing or amplifying.

## Request or state path

Use one state path before reaching for commands:

```text
created -> admitted -> queued -> running -> dependency wait
                                           |
                                           +-> complete
                                           +-> failed
                                           +-> timed out
                                           `-> retry scheduled
```

For every arrow, fill in five fields:

| Field | Exact question |
|---|---|
| identity | Which request, job, tenant, revision, or cohort is this? |
| owner | Which component writes the current state? |
| time | Which clock and timestamp mark entry and exit? |
| evidence | Which counter, event, trace span, state record, or real operation proves the transition? |
| failure branch | What happens on rejection, timeout, cancellation, duplicate, or partial success? |

Now add rates:

1. How much work is offered?
2. How much is admitted?
3. How much starts service?
4. How much completes correctly?
5. How much fails, expires, is dropped, or is retried?
6. How much unfinished work exists, and how old is the oldest useful item?

If 900 jobs per second are admitted but only 520 complete, unfinished work grows by roughly 380 per second while those rates persist and definitions align. That arithmetic does not identify the bottleneck. It tells you why waiting and recovery risk are growing.

State paths also expose false health. A deployment can be accepted, an instance can be running, and a port can be listening while readiness, routing, dependency access, or the real operation still fails. Each word belongs to a different boundary.

## Failure zoom

### Stable does not mean idle

Suppose a worker can complete 25 items per second and receives 15 per second. Utilization may be substantial, but the queue can remain bounded because effective capacity exceeds admitted load. Short bursts can still create temporary waiting.

### Saturated does not require high total CPU

Now suppose the same stage receives 50 items per second but completes 10 because one connection pool permits only ten concurrent dependency calls. The machine can show low total CPU while work waits on the pool. Scaling only the frontend increases admissions without changing the shared pool or dependency.

### Recovery is a separate phase

Reducing admissions from 50 to 8 while capacity is 10 creates only 2 items per second of drain headroom. A backlog of 36,000 items would need about five hours to drain if service behavior stays constant:

```text
drain rate = completion rate - new admitted rate
           = 10/s - 8/s
           = 2/s

drain time = backlog / drain rate
           = 36,000 / 2/s
           = 18,000 seconds
           = 5 hours
```

That estimate needs caveats: old work may expire, work cost may vary, capacity may change, and admitting new work may deserve priority. Still, it prevents the weak claim that "the graph stopped rising, so the incident is over."

### Feedback can create the second incident

If clients time out after five seconds and immediately retry, one original operation can produce several attempts. Those attempts consume capacity, increase waiting, and create more timeouts. Recovery may require a retry budget, exponential backoff, random delay called jitter, admission control, or temporary shedding - not more identical pressure.

### Tail latency protects the affected minority from averages

An average combines fast and slow observations. Ninety-five requests at 100 milliseconds and five requests at 20 seconds produce an average near 1.095 seconds. That average hides five severe failures. Percentiles, affected cohorts, error outcomes, and the real user operation make the tail visible.

## Internals and state ownership

Systems become debuggable when every state has an owner and every copy is treated as a possibly delayed view.

| State | Primary owner | Useful evidence | Staleness or ambiguity |
|---|---|---|---|
| work accepted | admission component | accepted/rejected counters and durable receipt | client timeout may hide a successful accept |
| queue depth | queue or broker | current depth and partition breakdown | one gauge may race with arrivals and completions |
| oldest-item age | queue plus item timestamp | age by priority or partition | bad producer clocks can corrupt timestamp-based age |
| running work | worker or scheduler | in-flight count and start events | process existence is not useful progress |
| completion | result owner | durable status and consumer operation | logging success before commit creates false completion |
| retry state | client, worker, or queue policy | attempt number, backoff, next attempt | retries without an operation ID look like new work |
| desired state | control plane | revision and accepted configuration | accepted does not mean applied |
| ready state | data-plane readiness owner | ready capacity and reason | readiness can be too shallow or cached |
| consumer outcome | client or synthetic journey | correct response and side effect | one synthetic may miss another cohort |

### Queue implementations differ; the reasoning survives

An in-memory language queue, a process pool, a database work table, a message broker, and a Kubernetes controller work queue have different durability, ordering, delivery, retry, and visibility behavior. Do not assume one tool's semantics apply to another.

The reusable questions are:

- What constitutes admission?
- Where is unfinished work stored?
- Can an item appear more than once?
- Can work be lost, reordered, delayed, or expired?
- Who acknowledges completion?
- What happens if a worker dies after the side effect but before acknowledgement?
- Which metric proves useful progress rather than motion?

### Control-plane truth and data-plane truth coexist

A controller's state is not fake; it answers a control-plane question. A successful user operation is not a substitute for controller evidence; it answers a data-plane question. Senior diagnosis keeps both and connects them through revision, instance, endpoint, time, and cohort.

## Evidence table

| Question | Command or evidence | Risk | Expected branches | Proves | Does not prove |
|---|---|---|---|---|---|
| Which baseline am I using? | `cat /etc/os-release`, `id -u`, `uname -sr` | read-only | tested Ubuntu/non-root or stop/record variance | shell-visible release, identity, kernel | lab dependencies or understanding |
| Are dependencies present? | `command -v ...` | read-only | all paths or named missing command | current PATH resolution | compatible version or provenance |
| Is the boundary safe? | `lab.sh check` | read-only | accepted or explicit refusal | preflight result | future run success |
| What resources exist? | `lab.sh setup` then `status` | bounded mutation plus read | valid guarded state or refusal | harness-owned state | arbitrary filesystem safety |
| Is the profile stable here? | `lab.sh run stable` | bounded mutation | bounded wait or unexpected variation | one finite result | production capacity |
| Does overload create waiting? | `lab.sh run saturated` | bounded mutation | queue/wait rise or bounded abort | one controlled relationship | bottleneck of a real system |
| Does service capacity improve it? | `lab.sh run recovered` | bounded mutation | wait falls or hypothesis rejected | one controlled comparison | downstream safety of scaling |
| Is pre-cleanup state exact? | `lab.sh status` | read-only | strict summary or refusal | registered state and exact profile summaries passed strict validation | learner mastery |
| Was registered cleanup exact? | `lab.sh cleanup` then `lab.sh check` | bounded mutation then read-only | `cleanup_proven=true` and later `state=absent`, or stop | exact recorded root/state absence plus later descriptor absence | absence of audit records or unregistered paths |
| Does the full harness safety contract pass? | clean-state `verify.sh` | bounded mutation | profiles/refusals/cleanup pass or first error | implemented lifecycle and refusal assertions | learner understanding or production capacity |

During production incidents, replace simulator commands with real evidence at the same conceptual boundaries. Keep the sentence structure: question, observation, meaning, limitation, safest next evidence.

## Command decoders

### Decoder one: baseline and dependency checks

Illustrative paths; exact installation paths can differ:

```console
PRETTY_NAME="Ubuntu 24.04.2 LTS"
uid=1000
Linux 6.8.0-64-generic
/usr/bin/bash
/usr/bin/basename
/usr/bin/cat
/usr/bin/chmod
/usr/bin/cmp
/usr/bin/dirname
/usr/bin/find
/usr/bin/grep
/usr/bin/id
/usr/bin/install
/usr/bin/mktemp
/usr/bin/python3
/usr/bin/realpath
/usr/bin/rmdir
/usr/bin/rm
/usr/bin/stat
```

`PRETTY_NAME` is human-readable release metadata, not a cryptographic identity. `uid=1000` means the effective numeric user returned by `id -u` is not root; the number can differ. `Linux` is the kernel name, and the following string is the running kernel release visible here. The kernel is the operating-system core that owns process, memory, device, filesystem, and network mechanisms. `PATH` is the shell's ordered list of directories searched for command names; each absolute path is the executable found for that name in this shell.

If `python3` prints no path and the combined command returns nonzero, stop. Ubuntu maps it to the `python3` package, but package installation is a separate networked, privileged decision and is not part of this lab.

Bash coordinates the lifecycle. Python 3 runs the deterministic model. The remaining base utilities inspect and guard path, file, owner, mode, link-count, content, installation, and cleanup boundaries. You do not need to memorize this list; remember the rule: prove the exact dependency set before mutation, and let `check` explain any refusal.

### Decoder two: guarded status

Expected output immediately after setup; the random suffix changes:

```console
lesson_id=LES-0007
state=ready
lab_root=/tmp/devops-sre-LES-0007-systems-thinking.XXXXXXXX
profiles_completed=none
execution=virtual-time-bounded
queue_capacity=3
profiles_available=stable,saturated,recovered
```

| Field | Type and unit | Meaning | Trap |
|---|---|---|---|
| `lesson_id` | stable identifier | lesson contract the harness recognized | matching text is not authorization to manage another path |
| `state` | categorical text | lifecycle state recognized after the harness revalidates its guarded files | `ready` is lab readiness, not learner mastery or a promise about a later command |
| `lab_root` | canonical temporary path | exact registered workspace, including a random setup suffix | never copy the sample path into a manual cleanup command |
| `profiles_completed` | `none` or ordered comma-separated names | valid summaries currently committed; after all runs it is `stable,saturated,recovered` | availability and completion are different fields |
| `execution` | categorical text | this harness advances bounded virtual time | it does not measure host wall-clock performance |
| `queue_capacity` | waiting jobs | fixed bounded queue size used by every profile | active service is excluded |
| `profiles_available` | ordered comma-separated names | valid arguments accepted by `run` | a listed profile has not necessarily run |

The concise status is printed only after internal checks of the state descriptor, canonical path, owner, required modes, link counts, sentinel identity, artifact allowlist, manifest content, copied model, and recorded summaries. Those guards are the mechanism; the seven output fields are a human summary, not a substitute for them.

### Decoder three: stable profile

Expected version-1 virtual-time output:

```console
profile=stable
jobs=12
completed=12
workers=1
arrival_ms=400
service_ms=300
elapsed_ms=4700
throughput_per_s=2.553
max_queue=0
mean_wait_ms=0.000
p95_wait_ms=0
queue_capacity=3
offered_rate_per_s=2.500
nominal_capacity_per_s=3.333
backpressure_jobs=0
producer_blocked_ms=0
max_admission_delay_ms=0
mean_completion_latency_ms=300.000
p95_completion_latency_ms=300
```

`jobs` is a fixed count, not a rate. `completed` is the count that crossed the completion boundary. `workers` is configured concurrency. `arrival_ms` is the virtual interval between offered jobs, so 400 milliseconds corresponds to 2.5 offered items per second. `service_ms` is virtual service time per job. One worker has nominal capacity `1 * 1000 / 300 = 3.333` items per second under this simplified model.

`elapsed_ms` is virtual time from the first offer at zero through the last completion. `throughput_per_s` is completed divided by that finite interval. It differs from offered rate because the first job is offered at zero, the last still needs service, and the batch has no warm-up or steady-state window.

`queue_capacity=3` is the maximum waiting count, excluding active service. `max_queue=0` says this profile admitted work directly to the idle worker. `mean_wait_ms` averages admitted-to-service-start time. `p95_wait_ms` uses nearest rank over only 12 jobs. Here every offered-to-completed latency is 300 virtual milliseconds because no job waits before the one fixed service stage.

### Decoder four: saturated profile

```console
profile=saturated
jobs=12
completed=12
workers=1
arrival_ms=100
service_ms=300
elapsed_ms=3600
throughput_per_s=3.333
max_queue=3
mean_wait_ms=691.667
p95_wait_ms=900
queue_capacity=3
offered_rate_per_s=10.000
nominal_capacity_per_s=3.333
backpressure_jobs=7
producer_blocked_ms=1900
max_admission_delay_ms=1300
mean_completion_latency_ms=1400.000
p95_completion_latency_ms=2500
```

The offered rate is about three times nominal capacity while offers continue. The bounded waiting queue reaches its capacity of three. After that, seven jobs experience admission backpressure: they have been offered but cannot yet enter the full queue. `producer_blocked_ms=1900` is the number of virtual milliseconds during which at least one offered job is pending outside admission; it is not the sum of every job's delay. `max_admission_delay_ms=1300` is the worst offered-to-admitted delay.

`mean_wait_ms` measures only admitted-to-service-start waiting. Completion latency measures offered-to-completed time and therefore includes admission delay, queue wait, and service. The profile completes all 12 jobs only because offers form a finite batch. Low host central processing unit (CPU) use is expected because the model advances virtual integer time without sleeping or generating host load. Production workers can also wait on network responses, locks, pools, storage, quotas, or other owners.

### Decoder five: recovered profile

```console
profile=recovered
jobs=12
completed=12
workers=3
arrival_ms=100
service_ms=300
elapsed_ms=1400
throughput_per_s=8.571
max_queue=0
mean_wait_ms=0.000
p95_wait_ms=0
queue_capacity=3
offered_rate_per_s=10.000
nominal_capacity_per_s=10.000
backpressure_jobs=0
producer_blocked_ms=0
max_admission_delay_ms=0
mean_completion_latency_ms=300.000
p95_completion_latency_ms=300
```

The profile keeps the saturated offered rate and service time but changes worker count from one to three. Nominal capacity now matches offered rate, and deterministic spacing lets each offered job enter service without a waiting queue or admission delay. Throughput over the finite window is 8.571 rather than 10 because the last offered job still needs 300 virtual milliseconds to finish.

In production, this comparison is only the start. Three workers may create three times the dependency concurrency, exceed a quota, contend on one lock, consume more memory, or increase cost. Effective capacity is what the complete path sustains, not the sum of worker labels.

### Decoder six: interpret combinations, not isolated fields

| Signal combination | Strong first interpretation | Safest next evidence |
|---|---|---|
| offered rate rises, throughput matches, wait stable | current path absorbed the load | headroom, dependency utilization, and tail latency |
| offered rate exceeds throughput, depth and oldest age rise | unfinished work is accumulating | first stage where start/completion rate diverges |
| depth falls but oldest age rises | new work may be prioritized while old work starves | age distribution by priority or partition |
| workers rise, throughput flat, dependency latency rises | shared dependency may constrain useful work | connection pool, quota, dependency rate and errors |
| errors fall but queue age remains high | new failures improved while backlog recovery continues | drain rate, expiry, consumer correctness |
| average stable, p95 or p99 rises | a tail cohort is degrading | request shape, tenant, zone, partition, and trace comparison |

Each profile begins with an empty queue and has no warm-up period. The first and last jobs therefore see different finite-batch boundaries from a long-running steady system. Version-1 outputs use deterministic virtual milliseconds, so a value mismatch is evidence of a changed model, fixture, interpreter behavior, or corrupted result - not ordinary host jitter.

Virtual time is a teaching coordinate, not the machine's realtime or monotonic clock. Never place these profile milliseconds beside production timestamps as if they came from the same clock.

## Decision path

Use this sequence whenever a system is slow, overloaded, or reporting conflicting health:

1. **Define the real operation.** Name the consumer, expected result, reliability objective, and current impact.
2. **Draw the path.** Put admission, queues, workers, dependencies, durable state, control plane, and consumer outcome in order.
3. **Freeze identity and interval.** Record revision, cohort, zone, tenant, request or job ID, and a shared time window.
4. **Measure conservation of work.** Compare offered, admitted, started, completed, failed, dropped, expired, cancelled, and retried work.
5. **Find the first abnormal transition.** Look for the earliest boundary where rate, wait, errors, or state diverge from a healthy comparison.
6. **Test competing hypotheses safely.** State what each observation proves and what would disprove the hypothesis.
7. **Control amplification.** Bound retries, admission, concurrency, and rollout scope before they expand the fault.
8. **Restore reversibly.** Prefer a traffic reduction, rollout pause, known-good revision, or reviewed capacity change with rollback.
9. **Verify useful recovery.** Prove the consumer operation, completion rate, tail latency, errors, and backlog age recover.
10. **Prevent recurrence.** Add explicit capacity objectives, backpressure, canaries, failure-domain tests, and actionable signals.

```text
user operation unhealthy
          |
          v
offered > admitted? -- yes --> rejection / policy / quota boundary
          |
          no
          v
admitted > started? -- yes --> queue / scheduler / worker capacity
          |
          no
          v
started > completed? -- yes --> worker / dependency / timeout / correctness
          |
          no
          v
completion healthy but user fails --> result publication / route / consumer boundary
```

At every branch, keep failure and recovery separate. The action that stops new damage may not drain old backlog. The action that drains backlog may be unsafe until a dependency recovers.

## Guided Ubuntu lab

This lab makes one relationship visible: queue waiting and admission backpressure change when offered load crosses effective service capacity. It does not benchmark your laptop. The Python model advances integer virtual milliseconds and writes deterministic summaries; it does not sleep, open a socket, spawn worker children, or create host central processing unit (CPU), memory, disk, or network pressure.

### Environment card before typing

| Item | Required boundary |
|---|---|
| operating system | Ubuntu 24.04 or Windows Subsystem for Linux (WSL 2) Ubuntu 24.04 |
| privilege | normal non-root user; never add `sudo` |
| temporary filesystem | `/tmp` must be a real, root-owned directory with the sticky bit; the sticky bit limits who may remove another user's entries |
| commands | Bash, `basename`, `cat`, `chmod`, `cmp`, `dirname`, `find`, `grep`, `id`, `install`, `mktemp`, Python 3.8 or newer, `realpath`, `rmdir`, `rm`, and `stat` |
| compute and disk | only a foreground virtual-time calculation and small text artifacts; the harness does not enforce a CPU, memory, or byte-capacity threshold |
| network and ports | none |
| changed resources | one guarded `/tmp/devops-sre-LES-0007-systems-thinking.XXXXXXXX` directory, one UID-scoped state descriptor, one copied model, one manifest, one sentinel, and up to three summaries |
| forbidden actions | package installation, manual clock change, Docker, Kubernetes, cloud, `rm -rf`, broad process signaling, or manual editing of lab artifacts |

Windows Subsystem for Linux (WSL 2) runs an Ubuntu userspace inside a lightweight virtual machine on Windows. Run every command in the Ubuntu shell, not PowerShell or Command Prompt. A **user identifier (UID)** is Linux's numeric identity for a user; the harness uses it to keep each user's state descriptor separate.

A **state descriptor** is a private mode-0600 file that records the exact guarded workspace for later lifecycle commands. A **sentinel** is a private identity file whose expected lesson ID, version, and owner help prove that the root is the one setup created. A **manifest** is the exact allowlist of artifact names and expected roles. None of these checks makes an arbitrary path safe to delete.

Start in the repository root: the directory whose immediate child is `book/`. If `pwd` does not show that repository, change directory before continuing. Do not paste the illustrative random `lab_root` into a cleanup command; the harness reads its own registered path.

### Step zero: check before setup

```bash
# [READ-ONLY]
cat /etc/os-release
printf 'uid=%s\n' "$(id -u)"
uname -sr
command -v bash basename cat chmod cmp dirname find grep id install mktemp python3 realpath rmdir rm stat
bash book/labs/LES-0007-systems-thinking/lab.sh check
```

The first three commands establish release, identity, and kernel context. `command -v` asks the shell which executable its current `PATH` would resolve for each required name. The harness check then verifies a normal user, a root-owned sticky `/tmp`, Python 3.8 or newer, the source model type, and any existing lesson state. It does not itself parse Ubuntu release metadata, which is why you recorded that separately.

For a clean start, the final command should include these lines:

```console
lesson_id=LES-0007
environment=ready
execution=virtual-time-bounded
privilege=normal-user
state=absent
next_command=bash lab.sh setup
```

`state=absent` means this UID has no registered lesson state descriptor. It does not prove that every similarly named unregistered path on the machine is safe. Stop on any refusal. A missing dependency or unsafe state is a valid result; do not install automatically or bypass a guard.

### Step one: predict, then create the guarded workspace

Before setup, write three predictions:

- stable: will any job queue or face admission delay, and why?
- saturated: which values should rise even though all 12 jobs eventually complete?
- recovered: what changes when workers rise from one to three, and what production risk could that create?

Then run:

```bash
# [MUTATING-BOUNDED]
bash book/labs/LES-0007-systems-thinking/lab.sh setup

# [READ-ONLY]
bash book/labs/LES-0007-systems-thinking/lab.sh status
```

A new setup reports `setup=complete`, `state=ready`, a lesson-prefixed `lab_root`, and the next command. Status then prints the exact seven-field contract decoded earlier. Confirm `lesson_id=LES-0007`, `profiles_completed=none`, `execution=virtual-time-bounded`, `queue_capacity=3`, and `profiles_available=stable,saturated,recovered`. Confirm the random root matches the exact `/tmp/devops-sre-LES-0007-systems-thinking.XXXXXXXX` shape. Do not edit the descriptor, sentinel, manifest, copied model, or summaries.

Status prints a concise summary only after strict internal validation. It does not print owner, sentinel, manifest, or byte fields. Do not invent those fields when describing your evidence.

### Step two: observe the stable profile

```bash
# [MUTATING-BOUNDED]
bash book/labs/LES-0007-systems-thinking/lab.sh run stable
```

Record configuration and result fields separately:

| Configuration | Results |
|---|---|
| jobs, workers, arrival interval, service time, queue capacity, offered rate, nominal capacity | completed count, elapsed virtual time, finite throughput, maximum queue, queue wait, backpressure, admission delay, completion latency |

Explain why nominal capacity of 3.333 jobs per virtual second exceeds offered rate of 2.500. Then explain why a 12-job empty-queue batch does not prove sustainable production capacity. A second `run stable` must refuse because summaries are single-record evidence; do not repeat it merely to obtain a preferred screenshot.

### Step three: create bounded saturation

```bash
# [MUTATING-BOUNDED]
bash book/labs/LES-0007-systems-thinking/lab.sh run saturated
```

Do not call the profile healthy merely because `completed=12`, and do not call the harness failed merely because waiting rose. Saturation is the intended bounded condition. Compare:

- `offered_rate_per_s=10.000` with `nominal_capacity_per_s=3.333`;
- `max_queue=3` with `queue_capacity=3`;
- mean and p95 admitted-to-start wait with stable;
- `backpressure_jobs=7` and `max_admission_delay_ms=1300`;
- mean and p95 offered-to-completion latency;
- finite completion after offers stop with the behavior of continuous arrivals.

Here **backpressure** means the full waiting queue delays admission of already offered work. `producer_blocked_ms` counts virtual time during which at least one offered job remains pending outside admission; it is not the sum of every job's delay. If the simulator produces an unknown key or value, returns nonzero, or any guard refuses, stop and preserve the first diagnostic.

### Step four: test a capacity hypothesis

```bash
# [MUTATING-BOUNDED]
bash book/labs/LES-0007-systems-thinking/lab.sh run recovered
```

The hypothesis is: for the same offered spacing and service time, three independent workers provide nominal capacity equal to the offered rate, preventing queue wait and producer backpressure in this deterministic model. If the output matches, say "supports under this model," not "proves scaling fixes production."

Now name at least three ways a production result could differ: a shared dependency limit, memory pressure, connection limit, lock contention, quota, uneven work cost, cost growth, or a correlated failure domain.

### Step five: verify the recorded lifecycle state

```bash
# [READ-ONLY]
bash book/labs/LES-0007-systems-thinking/lab.sh status
```

Success at this point includes `profiles_completed=stable,saturated,recovered`. Before printing that line, status strictly validates the state descriptor, canonical root, sentinel, artifact allowlist, required modes, single-link ownership, exact manifest, copied model, and every recorded 19-key summary.

If strict status refuses because a known artifact's content or mode changed, do not edit it back by hand. `reset` can recover only when its narrower cleanup identity contract still proves the UID-scoped descriptor, canonical root, exact sentinel, allowlisted names, regular-file type, owner, and single-link identity. If reset refuses, stop.

### Step six: clean up and prove the registered absence

```bash
# [MUTATING-BOUNDED]
bash book/labs/LES-0007-systems-thinking/lab.sh cleanup

# [READ-ONLY]
bash book/labs/LES-0007-systems-thinking/lab.sh check
```

A completed cleanup reports:

```console
cleanup=complete
state=absent
cleanup_proven=true
```

Cleanup does not use recursive deletion. It removes each allowlisted regular single-link owned file, removes the validated empty root with `rmdir`, removes the validated state descriptor, and then checks that both exact recorded paths are absent. The following read-only check should again report `environment=ready` and `state=absent`.

Never replace a cleanup refusal with `rm -rf`. A refusal means the harness cannot prove that the target is exactly within its authorized identity boundary.

### Optional step seven: verify the harness itself from a clean state

`verify.sh` is not a `present` or `absent` checker. It is a separate mutating harness test, and it refuses to start while learner state exists. Run it only after step six if you want to validate the lab implementation:

```bash
# [MUTATING-BOUNDED]
bash book/labs/LES-0007-systems-thinking/verify.sh
```

It creates isolated lesson state, checks all three exact profiles, confirms a repeated profile refuses, exercises reset after a controlled manifest tamper, confirms cleanup refuses an unexpected verifier-owned artifact, removes that artifact safely, and proves final cleanup. Its success footer is:

```console
verification_passed=true
profiles=stable,saturated,recovered
refusals=repeat-run,manifest-tamper,unexpected-artifact
cleanup_proven=true
```

This proves the implemented harness assertions on this environment, not your understanding of systems thinking.

Your sanitized learning evidence should contain the three predictions, the three key-value summaries, one comparison table, one limitation, `cleanup_proven=true`, and the later `state=absent`. Do not include usernames, exact random host paths, employer data, credentials, or unrelated system output.
## Production transfer

### Containers

A container does not remove queues; it changes boundaries. The application may queue in its process, the container runtime may wait for CPU, a proxy may queue connections, and a dependency may enforce a quota. Container CPU percentage alone cannot prove useful capacity. Compare Linux control-group (cgroup) limits, request concurrency, dependency time, queue age, and completion rate.

### Kubernetes

Kubernetes uses controllers: control loops that compare desired and observed state. A Deployment can request replicas, the scheduler can place Pods, and readiness can decide whether endpoints receive traffic. Those are distinct transitions. A controller work queue can retry failed reconciliation, so backoff and idempotent behavior matter.

Do not say "Kubernetes says it is running, so the service is healthy." Connect desired revision, Pod identity, readiness, endpoint publication, routed request, and dependency result.

### Cloud and private cloud

Managed queues, load balancers, autoscalers, virtual-machine schedulers, storage systems, and image services all expose control-plane and data-plane signals. Provider dashboards may aggregate across zones or hide a hot partition. Label region, zone, host, tenant, partition, and shared dependency before claiming redundancy.

Autoscaling is a delayed feedback loop. Scaling on CPU can miss queue age or dependency saturation. Scaling on queue depth without accounting for job cost can overreact. Every scaling policy needs signal semantics, delay, bounds, cooldown behavior, dependency capacity, rollback, and cost review.

### CI/CD and platform engineering

A build queue is a production queue. Pending jobs, runner slots, artifact downloads, test duration, dependency services, and promotion gates form one path. More runners help only if runner capacity is the bottleneck. A shared package registry, license server, test database, or deployment approval can constrain throughput.

A platform team should publish the capacity and failure contract of its golden path: admission limits, expected wait, priorities, cancellation, retry, isolation, observability, and who owns recovery.

### Data and machine-learning platforms

Batch partitions, stream records, model-training jobs, notebook sessions, and feature pipelines are work items. Throughput can look healthy while event-time lag or oldest unprocessed data grows. Completion count without correctness, freshness, or checkpoint durability is motion, not useful progress.

## Reliability, security, observability, capacity, and cost

| Dimension | Design questions | Useful controls |
|---|---|---|
| reliability | What happens when arrivals exceed capacity or a worker dies mid-item? | bounded queues, deadlines, backpressure, idempotency, retry budgets, graceful degradation |
| security | Can one tenant fill shared capacity, inject poison work, or read another tenant's payload? | authentication, authorization, quotas, isolation, validation, encryption, audit |
| observability | Can we follow one item and reconcile all work outcomes? | IDs, accepted/started/completed/failed counters, depth, age, wait, service time, drops, retries |
| capacity | What rate meets the latency and correctness objective during bursts and failures? | load profiles, headroom, per-stage limits, bottleneck tests, drain-time estimates |
| cost | What does idle headroom, queue retention, retry traffic, and emergency scaling cost? | budgets, right-sized buffers, priority, retention, efficient batching, reviewed autoscaling |

### Reliability consequences

An unbounded queue converts overload into growing latency and memory or storage risk. A bounded queue forces an explicit choice: apply backpressure, reject, degrade, or prioritize. That choice should be visible to callers and measured.

Retries need deadlines, a maximum attempt budget, backoff, jitter, and idempotency. **Idempotency** means repeating an operation with the same identity does not create unintended additional effects. It is not automatic; the system must design and verify it.

### Security consequences

Queue payloads can contain sensitive data. Do not place secrets or unrestricted production content in learning evidence. Production systems need access control, tenant isolation, retention, deletion, and audit rules.

Overload is also a security boundary. One tenant or unauthenticated source can consume shared worker, memory, connection, or dependency capacity. Quotas and admission control protect availability, but their failure behavior must not leak other tenants' state.

### Observability consequences

At minimum, measure:

- offered, admitted, rejected, started, completed, failed, expired, cancelled, and retried rates;
- depth and oldest useful item age by priority or partition;
- queue wait, service time, dependency time, and end-to-end latency distributions;
- active concurrency, configured limits, and dependency quotas;
- revision, zone, tenant, and failure-domain labels with bounded cardinality.

**Cardinality** is the number of distinct label combinations. Putting raw request IDs into metric labels can make a metrics system expensive or unusable. Keep high-cardinality identities in traces or logs with safe retention, not unlimited metric labels.

### Capacity and cost consequences

Headroom buys resilience but costs money. Too little headroom creates queueing and slow recovery. Too much unmeasured headroom hides inefficiency. Choose it from burst size, failure capacity, rollout overlap, recovery objective, and uncertainty - not a universal percentage.

Scaling workers can shift cost and bottlenecks into databases, APIs, storage, networks, or licenses. The cheapest correct design may shed low-value work, batch it, cache safely, schedule it later, or improve service time instead of multiplying concurrency.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| "CPU is low, so add traffic" | another resource can be saturated | measure the full work path and queue age |
| "The queue has 10,000 items, so it is bad" | item cost and normal throughput are unknown | add oldest age, arrival/completion rates, priority, and objective |
| "Every job eventually completed, so capacity is enough" | finite arrivals let an unstable queue drain later | test sustained relationship and declare the window |
| "Add workers" | shared dependencies may become the bottleneck | inspect dependency capacity and canary bounded concurrency |
| "Retry immediately" | retries amplify offered load | budgets, backoff, jitter, deadlines, and idempotency |
| "Average latency recovered" | a tail cohort may still fail | percentiles, errors, cohorts, and real operations |
| "Controller accepted it" | control-plane acceptance is not data-plane readiness | verify applied state and consumer outcome |
| "Three replicas means high availability" | replicas can share one failure domain | map zone, host, identity, dependency, and rollout correlation |
| "Restart to clear the queue" | restart can lose state and evidence or duplicate work | preserve identity and use the owned recovery procedure |
| "The backlog stopped growing, so recovery is over" | old work may drain too slowly or be expired | completion correctness, oldest age, and drain objective |
| "Use the queue equation on any dashboard" | mismatched windows or transient state invalidate the inference | align boundary, population, interval, and stability |

Prevention is a system property:

1. explicit admission and bounded queue behavior;
2. end-to-end work accounting;
3. deadlines and retry budgets;
4. capacity objectives with failure headroom;
5. failure-domain-aware placement and canaries;
6. reversible rollout and load-shedding controls;
7. recovery verification at the consumer boundary;
8. regular overload and backlog-drain exercises.

## Memory card and retrieval

### The seven-stage picture

Say this without looking:

```text
work -> admission -> queue -> service -> dependency -> outcome -> feedback
```

### The five on-call questions

1. What exact useful operation is failing?
2. Where is each state owned, and how do I join one work item across boundaries?
3. How do offered, admitted, started, completed, failed, and retried rates compare?
4. Which queue, wait, limit, or dependency is first abnormal?
5. What reversible action stops amplification, and what proves recovery?

### One-line rules

- Low CPU does not mean spare system capacity.
- Queue depth is a count; queue age is time; neither is root cause alone.
- Stable requires offered work below effective capacity over the relevant interval.
- Recovery must handle new arrivals and old backlog.
- Control-plane success is not data-plane success.
- Retries are load.
- Redundancy without independent failure domains is correlated risk.
- Reading or completing this page is not mastery.

### Retrieval prompts

Answer aloud before opening the next section:

1. Why can latency rise while CPU stays low?
2. What is the difference between offered load and throughput?
3. When can adding workers make an incident worse?
4. What evidence separates control-plane acceptance from data-plane success?
5. What must recover after a backlog stops growing?

## Complete answers

### Answer one: low CPU and high latency

**Direct:** Work can wait on a queue, pool, lock, quota, storage device, network response, or remote dependency without consuming much CPU.

**Foundation:** CPU is one service resource. End-to-end latency includes queue wait and time owned by other components. Saturation means demand exceeds immediately available capacity at some boundary; it does not require every CPU to be busy.

**Senior production answer:** I would align admitted, started, and completed rates with queue depth and oldest age, then decompose latency into queue, service, and dependency portions by cohort. I would protect the constrained dependency before adding concurrency and verify recovery with the real operation plus backlog drain.

### Answer two: offered load and throughput

**Direct:** Offered load is work presented to the system; throughput is work completed across a defined boundary per time.

**Foundation:** Some offered work can be rejected, queued, expired, failed, cancelled, or retried. Therefore offered rate can rise while useful completion rate stays flat.

**Senior production answer:** I would reconcile offered, admitted, started, completed, failed, and retried counters over the same interval and identity scope. If admitted exceeds useful completion, I would estimate backlog growth, locate the first divergence, and include correctness rather than counting only responses.

### Answer three: workers can amplify a fault

**Direct:** More workers increase concurrency against shared dependencies and can exceed pools, quotas, locks, memory, or downstream capacity.

**Foundation:** Worker count is potential concurrency, not guaranteed useful throughput. The bottleneck can move.

**Senior production answer:** I would canary a bounded concurrency change only after measuring the dependency, preserve rollback, and watch completion rate, tail latency, errors, queue age, resource limits, and cost. If throughput stays flat while dependency distress rises, I would reverse the change and control admissions.

### Answer four: control plane versus data plane

**Direct:** A control-plane acknowledgement proves a decision was accepted; a data-plane operation proves whether the intended workload result is actually available.

**Foundation:** The system still has to reconcile, schedule, start, become ready, route, access dependencies, and complete the user operation.

**Senior production answer:** I would join desired revision, reconcile result, instance identity, ready capacity, endpoint publication, and a representative consumer transaction. I would compare healthy and affected failure domains and avoid calling the rollout complete from controller activity alone.

### Answer five: backlog recovery

**Direct:** Useful completion must exceed new admitted work long enough for old useful backlog and oldest-item age to fall within the recovery objective.

**Foundation:** A flat queue means inflow and outflow may merely be equal. Existing work can remain late.

**Senior production answer:** I would track drain rate, oldest useful age, expiry, priority, duplicates, and correctness. I would estimate drain time, protect live traffic, decide how stale work is handled, and close the incident only after the real operation and backlog objective recover.

These answers are guidance, not learner evidence. Reconstruct the reasoning on an unfamiliar system rather than memorizing sentences.

## Product-company interview

### Scenario

A payments platform accepts 900 jobs per second. After a routine rollout, useful completions fall to 520 per second, p95 latency reaches 14 seconds, oldest queued work reaches six minutes, and worker CPU remains 35 percent. An autoscaler adds API replicas, retry traffic rises, and a shared dependency reports longer waits. Explain diagnosis, safe restoration, verification, and prevention.

### Strong answer structure

```text
impact and recovery objective
  -> exact work path and state owners
  -> offered/admitted/started/completed/retried conservation
  -> first abnormal queue or dependency boundary
  -> control retry and admission amplification
  -> reversible rollback or traffic reduction
  -> real payment plus backlog-drain verification
  -> capacity, canary, retry, and failure-domain prevention
```

A strong model answer begins by saying low CPU does not exclude saturation. It calculates that unfinished work grows by roughly 380 jobs per second while the aligned rates persist. It treats the shared dependency and any worker concurrency limit as hypotheses, then asks for queue wait, service time, dependency latency, pool or quota, error, retry, and cohort evidence.

For restoration, it pauses the rollout, bounds retries, and protects the dependency through the approved reversible control. It chooses a known-good revision or reviewed admission reduction rather than blindly adding replicas. It verifies a representative payment, useful completion above admitted load during drain, falling oldest age and tail latency, correct outcomes, and no hidden failed cohort.

Prevention includes a canary tied to useful throughput and queue age, explicit retry budgets, backoff and jitter, dependency-aware concurrency, overload tests, failure-domain labels, a backlog-drain objective, and rollback thresholds.

### Weak answer and why it is dangerous

> CPU is only 35 percent, so double every replica and retry until the queue clears.

This confuses host CPU with system capacity. It can increase admitted work and dependency concurrency, amplify retries, extend queue wait, raise cost, and turn a partial failure into a cascade. It also offers no evidence boundary, rollback, correctness check, or drain-time estimate.

### Answered follow-ups

- **What if queue depth falls but oldest age rises?** New or high-priority work may be passing while old work starves. Inspect age by priority, partition, and cohort.
- **What if rollback restores throughput but retries remain high?** Client or worker retry state can outlive the original fault. Bound attempts and verify unique operations, not raw requests.
- **What if one zone is healthy?** Compare revision, workload, dependency path, quota, and shared identities; use the healthy zone as evidence, not unlimited failover capacity.
- **What if adding workers improves throughput?** Keep the change bounded, prove dependency and cost headroom, and verify that tail latency and errors do not move elsewhere.
- **When is load shedding acceptable?** When the service has an explicit priority and correctness contract, the shed outcome is visible, and preserving critical work is safer than uncontrolled collapse.

The complete structured interview record is `ASM-0005`. Reveal it only after giving your own answer.

## Independent transfer and rubric

`ASM-0006` is deliberately answer-isolated. It presents an unfamiliar system with different names, rates, and failure boundaries from the guided simulator. No model answer, diagnosis, hidden hint, or reviewer solution belongs in this lesson, its search data, the lab, or client state.

Required learner deliverables:

1. a system map showing work, state owners, queues, dependencies, control plane, data plane, feedback, and failure domains;
2. a table separating facts, inferences, hypotheses, and unknowns;
3. aligned offered, admitted, started, completed, failed, and retried evidence;
4. two competing hypotheses and evidence that would reject each;
5. the safest reversible restoration with scope and rollback;
6. consumer-level recovery and backlog verification;
7. one reliability, one security, one observability, one capacity, and one cost consequence;
8. sanitized evidence and explicit cleanup proof where a local artifact is used.

The rubric scores system model, mechanism accuracy, evidence boundaries, rate and queue reasoning, hypothesis quality, safety, recovery verification, production transfer, communication, and independence. Reading this chapter, copying its phrasing, running the guided profiles, or marking the page finished never awards mastery. An authorized reviewer must evaluate original evidence under the assessment rubric.

If you need a model answer while attempting the transfer, return to the guided lesson and try a later unfamiliar prompt. That is honest learning evidence, not failure.

## References and review

This lesson uses eight primary or first-party technical records. URLs live only in the reference registry; the chapter body names IDs and scope so provenance remains centralized:

| Reference ID | Scope used here |
|---|---|
| `REF-0009` | Python bounded-queue and synchronization semantics contrasted with the lab's deterministic single-process deque model |
| `REF-0010` | Python realtime and monotonic clock semantics contrasted with the simulator's deliberately synthetic virtual time |
| `REF-0011` | Monitoring terminology and the relationship between latency, traffic, errors, and saturation |
| `REF-0012` | Overload handling, admission, graceful degradation, and capacity protection |
| `REF-0013` | Retry amplification and cascading-failure prevention |
| `REF-0014` | Kubernetes controller and reconciliation concepts |
| `REF-0015` | Kubernetes control-plane and worker-node architecture |
| `REF-0016` | Queue backlog signals, scaling trade-offs, and recovery reasoning |

The runtime baseline is Ubuntu 24.04 with the exact locally installed Bash and Python 3 versions. The guided lab requires no external network after the repository and dependencies are present.

Review this lesson by 2026-11-02, or earlier if the lab interface, schema, Ubuntu baseline, Python timing behavior, referenced controller architecture, or overload guidance changes materially. Review must include content accuracy, command safety, clean setup and cleanup, stable/saturated/recovered behavior, assessment answer isolation, reference backlinks, route/search/state integration, and a reminder that publication is not mastery.

The current status is `substantive-draft`. That means the chapter is available for study and engineering review. It does not mean the chapter is accepted, the lab ran on every supported environment, or any learner demonstrated independent transfer.
