---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0002",
  "aliases": ["V01-L02", "processes-signals-systemd"],
  "curriculumIds": ["LNX-002"],
  "slug": "processes-signals-systemd",
  "route": "/book/linux/processes-signals-systemd",
  "order": 2,
  "volume": "01-linux-systems",
  "title": "Processes, signals, exit codes, and systemd",
  "summary": "Trace a service from systemd configuration to processes, threads, descriptors, sockets, logs, termination state, and the user-visible operation before deciding whether a restart is safe.",
  "domain": "linux",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 210,
  "prerequisiteLessonIds": ["LES-0001"],
  "prerequisiteCurriculumIds": ["LNX-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The guided process lab is non-root, local-only, and uses procps plus base GNU utilities."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04", "support": "supported", "notes": "The process lab works, but system services are observable only when systemd is enabled and running as PID 1."},
    {"platform": "Docker container", "version": "Any local Linux container", "support": "concept-only", "notes": "PID, mount, user, and cgroup namespaces change what the shell can see; a container usually does not run the host systemd."},
    {"platform": "Disposable Ubuntu virtual machine", "version": "24.04 LTS", "support": "supported", "notes": "Use a disposable VM for exercises that edit system units, limits, restart policy, or production-like supervision."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer"],
  "learningObjectives": [
    "Distinguish a program, process, thread, PID, parent, process group, service unit, and user-visible service operation.",
    "Read process identity, state, age, ownership, descriptors, sockets, unit properties, journal events, and termination results without turning one clue into a conclusion.",
    "Explain SIGTERM, SIGKILL, exit status, zombie state, uninterruptible sleep, restart policy, and PID reuse at an operationally useful depth.",
    "Build a time-ordered incident path from the first failure through supervision, process state, dependency evidence, and an end-to-end check.",
    "Choose a bounded recovery that preserves evidence and verify the operation after process-level recovery.",
    "Transfer the model to containers and Kubernetes without confusing a namespace-local PID, container restart, Pod readiness, and customer availability."
  ],
  "productionSignals": [
    "A process exists but the API is unavailable.",
    "A systemd service restarts repeatedly or reports failed.",
    "A deployment reports a signal-shaped termination status.",
    "SIGTERM is delivered but graceful shutdown does not complete.",
    "A process remains in D state after a termination request.",
    "Descriptor count grows until opens or accepts fail.",
    "The unit is active while no expected socket listens or the readiness operation fails.",
    "Zombie count grows under a long-running parent."
  ],
  "diagrams": [
    {"id": "LES-0002-DIA-001", "title": "Service ownership and evidence path", "direction": "top-to-bottom", "boundaries": ["unit configuration", "systemd manager", "main process", "threads and children", "descriptors and sockets", "dependencies", "user operation"], "evidencePoints": ["systemctl cat and show", "MainPID and invocation", "ps and procfs", "descriptor and socket views", "journal", "readiness and real request"], "textAlternative": "A systemd unit describes desired behavior; the manager creates a main process, which owns threads, children, descriptors, and sockets, calls dependencies, and must complete a real user operation."},
    {"id": "LES-0002-DIA-002", "title": "Graceful termination timeline", "direction": "left-to-right", "boundaries": ["stop requested", "SIGTERM delivered", "traffic drained", "state flushed", "process exits", "parent reaps", "supervisor records result"], "evidencePoints": ["request actor", "signal disposition", "listener state", "application log", "exit status", "zombie absence", "Result and ExecMainStatus"], "textAlternative": "A graceful stop is a sequence: request, signal delivery, drain, cleanup, exit, parent wait, and supervisor result; each stage has separate evidence."},
    {"id": "LES-0002-DIA-003", "title": "Running is not serving", "direction": "left-to-right", "boundaries": ["PID exists", "thread can run", "socket listens", "dependency works", "readiness passes", "traffic admitted", "user operation succeeds"], "evidencePoints": ["procfs", "process state", "ss", "dependency probe", "health result", "load-balancer state", "synthetic transaction"], "textAlternative": "A PID can exist before its threads progress, socket listens, dependencies work, readiness passes, traffic is admitted, and the real user operation succeeds."}
  ],
  "commands": [
    {"id": "LES-0002-CMD-001", "question": "Which processes exist, who owns them, how are they related, and what state are they in?", "risk": "read-only", "command": "ps -eo pid,ppid,user,stat,nlwp,etime,%cpu,%mem,cmd --sort=ppid,pid", "runFrom": "The affected Ubuntu process namespace as the normal diagnostic user", "expectedBranches": [{"when": "The expected PID is absent", "meaning": "It exited or is outside this PID namespace.", "nextEvidence": "Confirm namespace and supervisor state, then distinguish stopped from never started using logs and exit metadata."}, {"when": "The PID exists with S or R state", "meaning": "It is sleeping interruptibly or runnable at this instant; neither state proves readiness.", "nextEvidence": "Inspect the socket, unit result, dependencies, and the real operation."}, {"when": "The PID is D or Z", "meaning": "D indicates an uninterruptible kernel wait; Z indicates a terminated child awaiting collection by its parent.", "nextEvidence": "For D, inspect wait channel and backing I/O; for Z, identify the PPID and parent reaping behavior."}], "proves": "A point-in-time process-table view visible in this PID namespace, including reported ancestry, credentials, state, thread count, age, and sampled percentages.", "doesNotProve": "Historical state, application readiness, why a task waits, or whether the displayed command line is complete and trustworthy."},
    {"id": "LES-0002-CMD-002", "question": "What does the service manager believe about this unit and its last main process?", "risk": "read-only", "command": "systemctl show UNIT.service -p LoadState -p ActiveState -p SubState -p Result -p MainPID -p ExecMainCode -p ExecMainStatus -p NRestarts -p Restart -p TimeoutStopUSec", "runFrom": "Ubuntu with systemd as PID 1; replace UNIT.service with an approved exact unit", "expectedBranches": [{"when": "ActiveState is active and MainPID is nonzero", "meaning": "systemd currently tracks an active unit and main process.", "nextEvidence": "Verify the expected listener, readiness operation, dependencies, and request path."}, {"when": "Result, ExecMainCode, or ExecMainStatus indicates failure", "meaning": "systemd retained termination metadata for the last operation.", "nextEvidence": "Join it with bounded journal, coredump, kernel, and deployment evidence before changing restart policy."}, {"when": "NRestarts rises", "meaning": "The manager is repeatedly restarting according to policy.", "nextEvidence": "Measure cadence, identify the first exit, and inspect Restart plus start-rate limits."}], "proves": "Selected current and retained unit-manager properties from the observed systemd instance.", "doesNotProve": "Customer availability, the root cause of exit, or that a restart was initiated by systemd rather than another actor."},
    {"id": "LES-0002-CMD-003", "question": "Which files, pipes, devices, and sockets does the exact process currently reference?", "risk": "read-only", "command": "printf 'fd_count='; find /proc/PID/fd -mindepth 1 -maxdepth 1 -printf . 2>/dev/null | wc -c; ls -l /proc/PID/fd 2>/dev/null | sed -n '1,12p'", "runFrom": "The process PID namespace; replace PID only after confirming owner and start time", "expectedBranches": [{"when": "Permission is denied", "meaning": "Kernel ptrace policy, credentials, or namespace boundaries limit observation.", "nextEvidence": "Use the approved diagnostic identity or supervisor telemetry; do not weaken host security controls ad hoc."}, {"when": "The count is high but stable", "meaning": "The process owns many descriptors, which may be expected capacity.", "nextEvidence": "Compare against limits, healthy peers, workload, and a time series."}, {"when": "The count grows with repeated work", "meaning": "A descriptor leak becomes plausible.", "nextEvidence": "Classify descriptor targets, correlate opens and closes, and inspect application ownership."}], "proves": "A current count and sample of descriptor links exposed for that PID.", "doesNotProve": "A leak from one sample, socket health, descriptor ownership inside the application, or future exhaustion."},
    {"id": "LES-0002-CMD-004", "question": "Is the expected TCP listener present, and which visible process owns it?", "risk": "read-only", "command": "ss -lntp", "runFrom": "The same network namespace as the service or an explicitly named comparison namespace", "expectedBranches": [{"when": "The expected address and port are absent", "meaning": "No visible TCP socket is listening on that endpoint in this namespace.", "nextEvidence": "Inspect bind errors, startup state, configuration, address family, and the namespace where the process actually runs."}, {"when": "A listener exists", "meaning": "The kernel has a listening socket at that local endpoint.", "nextEvidence": "Run the approved readiness and real-operation checks from their actual consumer boundaries."}], "proves": "Listening TCP sockets visible in this network namespace and process attribution when permissions permit.", "doesNotProve": "Application readiness, routing from another namespace, TLS correctness, dependency health, or successful user work."},
    {"id": "LES-0002-CMD-005", "question": "What happened around this unit in a bounded incident window?", "risk": "read-only", "command": "journalctl -u UNIT.service --since '-15 min' -o short-monotonic --no-pager -n 200", "runFrom": "The systemd host with an approved exact unit and incident-aligned window", "expectedBranches": [{"when": "A first exit or error precedes restart messages", "meaning": "The ordering identifies an earlier event than the supervisor reaction.", "nextEvidence": "Correlate its invocation, PID, deploy, dependency, kernel, and application identifiers."}, {"when": "No relevant entries are visible", "meaning": "The identity may lack access, the unit may log elsewhere, retention may be absent, or the window may be wrong.", "nextEvidence": "State the evidence gap and inspect approved application, runtime, or centralized telemetry."}], "proves": "Accessible journal entries associated with the selected unit and bounded by the requested output rules.", "doesNotProve": "Complete logging, causal attribution, correct clocks across machines, or events removed before collection."},
    {"id": "LES-0002-CMD-006", "question": "How can an approved lab request SIGTERM only after revalidating the exact disposable process?", "risk": "mutating-bounded", "command": "kill -s SIGTERM LAB_PID", "runFrom": "Only inside the LES-0002 guided lab after its UID, start-time, fixture-path, and token checks pass", "expectedBranches": [{"when": "The fixture records term_received and exits", "meaning": "The signal reached the fixture handler and its graceful exit path completed.", "nextEvidence": "Verify process absence, termination record, and guarded cleanup."}, {"when": "Identity differs or the process remains", "meaning": "The target is unsafe or graceful termination did not complete within the lab budget.", "nextEvidence": "Stop and retain the refusal; never broaden the target or substitute a real PID."}], "proves": "Only when run through the lab harness, the checked fixture received a graceful termination request.", "doesNotProve": "That an arbitrary production service handles SIGTERM correctly or that user-visible service recovered.", "cleanup": "Run bash lab.sh cleanup, then bash lab.sh check and require state=absent plus process_candidates=0."}
  ],
  "labs": [
    {"id": "LES-0002-LAB-001", "title": "Observe and gracefully terminate an identity-checked process", "mode": "guided", "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 as a normal user", "timeMinutes": 25, "privilege": "Normal user only; the harness refuses UID 0", "network": "No network access, DNS lookup, or listening socket", "changes": ["One mode-0700 lesson root and UID-scoped state descriptor under /tmp", "One local background Bash process with a unique token", "Small synthetic event and identity files"], "abortConditions": ["Any path, owner, mode, sentinel, PID, start-time, or token mismatch", "Any unexpected file under the lesson root", "A missing required command or unsupported Ubuntu version", "Any temptation to substitute a real service PID or sudo"], "recovery": "Use bash lab.sh cleanup; it signals only a process whose UID, start time, and unique command token still match, then removes an allowlisted flat artifact set.", "cleanupProof": "bash lab.sh check must report state=absent and process_candidates=0 after cleanup.", "path": "book/labs/LES-0002-process-lifecycle"},
    {"id": "LES-0002-LAB-002", "title": "Independent service-lifecycle evidence packet", "mode": "independent", "environment": "Disposable Ubuntu 24.04 virtual machine with systemd as PID 1", "timeMinutes": 60, "privilege": "Read-only observation as a normal user; use approved elevation only to read explicitly authorized unit evidence", "network": "Localhost-only health operation with no credential and no business side effect", "changes": ["A learner-owned sanitized worksheet outside production", "Ordinary short-lived diagnostic command processes and permitted audit records"], "abortConditions": ["The target is production or employer infrastructure", "The operation requires a credential or creates business data", "Diagnosis would require unit, kernel, limit, firewall, or restart-policy mutation", "Evidence exposes identifiers or secrets"], "recovery": "No service mutation is authorized; stop commands and retain a sanitized evidence gap if access is insufficient.", "cleanupProof": "Confirm no learner-created long-running process, socket, unit, timer, or temporary lab path exists; disclose unavoidable diagnostic and audit records."}
  ],
  "incidents": [
    {"id": "LES-0002-INC-001", "signal": "The payment API is unavailable, systemctl reports activating, and the restart counter rises every 30 seconds.", "firstThought": "Treat the restart as a supervisor reaction, not the root cause. Preserve the first failing invocation and identify whether it exits, times out, is killed, or never becomes ready.", "safePath": "Freeze the timeline, bound journal evidence, read unit properties and process state, verify listener and readiness separately, correlate dependencies and deployment, then choose rollback, replacement, or bounded restart with explicit success criteria.", "trap": "Running restart or kill -9 repeatedly. That destroys short-lived evidence, may interrupt cleanup, increases load, and can keep the same fault inside a faster loop."},
    {"id": "LES-0002-INC-002", "signal": "A worker remains visible after SIGKILL and ps shows D state.", "firstThought": "SIGKILL cannot run application cleanup, but it cannot make a task leave an uninterruptible kernel wait immediately. Investigate the kernel-owned wait and backing resource.", "safePath": "Record PID identity and start time, inspect state and wait channel, correlate storage or network-filesystem health and blocked peers, and escalate through the owning platform recovery path.", "trap": "Repeating kill -9 or declaring the kernel broken without proving the wait boundary."}
  ],
  "assessmentIds": ["ASM-0262", "ASM-0263", "ASM-0264"],
  "referenceIds": ["REF-1200", "REF-1201", "REF-1202"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-09-02",
  "reviewAfter": "2027-03-02",
  "limitations": [
    "The guided lab demonstrates process identity, signals, and cleanup but does not mutate systemd units or create D-state tasks.",
    "Process and journal visibility depends on credentials, ptrace policy, namespaces, and retention.",
    "Exact systemd fields and defaults must be checked against the deployed systemd version and unit configuration.",
    "The independent exercise requires human review; reading model answers or running the guided lab does not award mastery."
  ]
}
---

# Processes, signals, exit codes, and systemd

## What you see and first thought

You see `service unavailable`, a missing worker, a rising restart count, exit code `137`, or a teammate saying, “Just restart it.” Pause there.

Your first question is not **Which kill command should I run?** It is:

> Which layer first stopped delivering useful work, and what evidence will the next action erase?

A restart can restore service. It can also delete short-lived process state, rotate the useful log window, replace a PID, close descriptors that reveal the dependency, and start a new instance with the same defect. Recovery and diagnosis are different jobs. During a severe incident you may recover first, but do it deliberately: preserve minimum evidence, name the success test, choose the smallest reversible action, and verify the user operation.

Remember: **A PID proves existence in one namespace. It does not prove progress, readiness, reachability, or successful work.**

## Terms before commands

**Program:** executable instructions stored on disk. It is potential work. Replacing the file does not replace a process already executing mapped code.

**Process:** a kernel-managed execution context created from a program. It has a process identifier, credentials, virtual memory, signal state, descriptor table, and one or more threads.

**Thread:** one schedulable execution path. Threads share most process resources but have separate scheduling state and stacks. One stuck thread can harm a process even when process-wide averages look normal.

**PID (process identifier):** a number unique only while that process exists inside one PID namespace. Linux can reuse it after exit. A stored PID without owner, start time, and identity evidence is unsafe.

**PPID (parent process identifier):** the PID of the process that created this process. The parent may be a shell, systemd, container runtime, or application worker manager.

**PID namespace:** an isolation boundary that gives processes a particular view of process IDs. PID 1 in a container can be an application while host PID 1 is systemd.

**Process group and session:** kernel groupings used for job control and signal delivery. Some signal commands can target an entire process group, which is why copied kill commands are dangerous.

**Process state:** a point-in-time scheduler clue. Common values are `R` runnable, `S` interruptible sleep, `D` uninterruptible sleep, `T` stopped, and `Z` zombie. Extra characters in `STAT` are modifiers.

**Signal:** an asynchronous kernel-delivered notification with a default action. A process can handle, block, or ignore many signals. `SIGKILL` and `SIGSTOP` cannot be caught, blocked, or ignored.

**SIGTERM:** signal 15, normally a graceful termination request. The application can drain traffic, flush state, close resources, and exit. It is a request, not proof that cleanup is correct.

**SIGKILL:** signal 9, forced termination without application handling. It does not mean instant disappearance when a task is stuck in an uninterruptible kernel wait.

**Exit code and wait status:** a process can exit normally with a code or because of a signal. Shells commonly expose `128 + signal number`, so 137 is consistent with signal 9 and 143 with signal 15. That arithmetic does not identify who sent it or why.

**Zombie:** a child that terminated but whose parent has not collected its wait status. It consumes a process-table slot, not live-worker memory. Killing it is meaningless; it is already dead. Fix or replace the parent that fails to reap it.

**File descriptor:** a small integer referring to an open file description, pipe, socket, device, or other kernel object. Descriptors 0, 1, and 2 conventionally represent standard input, output, and error.

**systemd unit:** a named object managed by systemd. A `.service` unit declares execution, dependencies, credentials, limits, restart behavior, and timeouts. The unit is configuration plus manager state; it is not the process itself.

**Liveness, readiness, and user operation:** liveness asks whether something should restart, readiness asks whether it should receive traffic, and a user operation proves one valuable transaction from a named boundary.

## Architecture map

```text role=diagram lines=off
unit file / generated configuration / drop-ins
                    |
                    v
          systemd manager (host PID 1)
                    |
             creates and supervises
                    v
       main process ---- helper processes
           |   |
           |   +---- threads scheduled by kernel
           |
           +-------- descriptors ---- files / pipes / sockets / devices
           |
           +-------- outbound calls ---- DNS / database / queue / API
           |
           v
       local listener -> readiness -> traffic admission -> user operation

Join keys: boot ID, unit, invocation, PID + start time, request ID, time window
```

The unit says what should happen. The process table says what exists now. The request result says whether the service delivered value. Keep desired state, runtime state, and delivered value separate.

## Request or state path

Trace one lifecycle in order:

1. Unit definition and drop-ins produce effective configuration.
2. systemd schedules a start job after dependency and ordering rules.
3. The manager creates a process with configured identity, environment, limits, namespaces, and descriptors.
4. The program initializes, creates threads or children, opens files, and binds sockets.
5. It connects to dependencies and establishes internal readiness.
6. A readiness check succeeds from a named boundary.
7. A proxy or load balancer admits traffic.
8. A real user operation succeeds.
9. During stop, the manager sends the configured signal and waits for the stop timeout.
10. The process exits; its parent collects termination status; systemd records the result and may restart by policy.

When tools disagree, ask whether they observe different stages, times, namespaces, or identities. `systemctl` can be right that a unit is active while the user is also right that checkout fails.

## Failure zoom

```text role=diagram lines=off
new process -> initializes -> fails readiness -> exits or is killed
     ^                                      |
     |                                      v
     +------ restart delay <- systemd records result
```

Four hypotheses produce the same headline:

- **Application crash:** find the first application error, exit status, and core-dump evidence.
- **External termination:** a controller, operator, deployment system, or memory controller sends a signal. Exit 137 alone is not an out-of-memory verdict.
- **Dependency or startup timeout:** the process lives but never becomes ready, then supervision times out.
- **Restart-policy defect:** a clean short-lived program is modeled as a daemon, or retries are too aggressive.

The first failure matters more than the twentieth restart. Later attempts add connection storms, lock contention, repeated recovery, and rate-limit errors.

## Internals and state ownership

Linux schedules threads. A process may have one accept thread, worker threads, garbage collection, and waiters. Process-level averages can hide a hot or blocked thread.

`R` means running or runnable, so the thread may be executing or queued. `S` is usually a normal interruptible wait. `D` is an uninterruptible kernel wait, commonly but not exclusively around I/O; ordinary signal handling waits for that kernel operation. `Z` means execution ended and the parent still owns collection of wait status.

Descriptors connect userspace intent to kernel objects. `/proc/PID/fd/N` is a live kernel view. One high count does not prove a leak. Compare counts over equal workload windows, classify targets, read limits, and compare healthy peers.

systemd owns manager state:

- `LoadState`: whether it loaded a valid unit definition.
- `ActiveState`: coarse lifecycle such as active, activating, inactive, or failed.
- `SubState`: type-specific detail.
- `Result`: category of the last operation.
- `ExecMainCode`: how the main process terminated.
- `ExecMainStatus`: exit code or signal-related status, interpreted with `ExecMainCode`.
- `NRestarts`: automatic restarts known to the manager.
- `Restart`: restart policy; start-rate limits separately bound repeated activation.

Use selected `systemctl show` properties for automation. Human-oriented `systemctl status` remains useful orientation but is deliberately incomplete.

## Evidence table

| Question | Command | Risk | Useful branches | Proves | Does not prove |
|---|---|---|---|---|---|
| What process tree and states exist now? | `ps -eo pid,ppid,user,stat,nlwp,etime,%cpu,%mem,cmd` | Read-only | absent; R/S; D; Z | Visible point-in-time metadata | History or service health |
| What does systemd retain? | `systemctl show UNIT.service ...` | Read-only | active; failed; restarting | Selected manager properties | User-visible readiness |
| What resources does the PID reference? | `find /proc/PID/fd ...` | Read-only | denied; stable; growing | Visible descriptor count | A leak from one sample |
| Is a listener present here? | `ss -lntp` | Read-only | absent; present; owner hidden | Namespace-local listener state | A successful request |
| What happened in the incident window? | `journalctl -u UNIT.service ...` | Read-only | first error; gap; restart sequence | Accessible bounded unit events | Complete causal history |

Independent layers make evidence stronger. A rising `NRestarts`, changing main PIDs, matching exit metadata, and the same first application error form a better case than one log line.

## Command decoders

Ask: **What exists in this PID namespace right now?**

```bash role=command lines=on
ps -eo pid,ppid,user,stat,nlwp,etime,%cpu,%mem,cmd --sort=ppid,pid
```

```text role=output lines=off
  PID  PPID USER     STAT NLWP     ELAPSED %CPU %MEM CMD
    1     0 root     Ss      1    01:12:14  0.0  0.1 /sbin/init
 2410     1 api      Ssl    18       03:42  2.4  1.8 /opt/api/server
 2418  2410 api      D       1       03:41  0.0  0.2 /opt/api/worker
```

- `PID` is namespace-local; `PPID` is the current parent.
- `USER` is a display name derived from credentials; policy uses numeric identity.
- `STAT` begins with the primary state. Later characters are modifiers.
- `NLWP` is the current thread count.
- `ELAPSED` is wall-clock age, not CPU time.
- `%CPU` is sampled/accounted utilization, not causal proof.
- `%MEM` uses visible physical memory; cgroup limits need separate evidence.
- `CMD` can be truncated, altered, or sensitive. Do not publish it blindly.

The `D` worker points to a kernel wait, not automatically “disk.” Ask which wait channel and backing resource it owns.

Ask next: **What does the manager know?**

```bash role=command lines=on
systemctl show api.service \
  -p LoadState -p ActiveState -p SubState -p Result -p MainPID \
  -p ExecMainCode -p ExecMainStatus -p NRestarts -p Restart -p TimeoutStopUSec
```

```text role=output lines=off
LoadState=loaded
ActiveState=activating
SubState=auto-restart
Result=exit-code
MainPID=0
ExecMainCode=1
ExecMainStatus=2
NRestarts=7
Restart=on-failure
TimeoutStopUSec=1min 30s
```

`MainPID=0` means no current main process in this branch. `ExecMainCode=1` identifies a normal-exit category and `ExecMainStatus=2` is the program's nonzero exit value. Interpret them together. `NRestarts=7` is a cumulative manager counter, not a rate. `TimeoutStopUSec` is configured duration, not proof the last stop used it.

Ask: **Does this process approach a descriptor limit?**

```bash role=command lines=on
grep -i 'open files' /proc/2410/limits
printf 'fd_count='
find /proc/2410/fd -mindepth 1 -maxdepth 1 -printf . 2>/dev/null | wc -c
```

```text role=output lines=off
Max open files            1024                 524288               files
fd_count=986
```

The first number is the soft limit; the second is the hard limit. Being close is not causality. Confirm failed `open` or `accept` operations and a growing count.

Finally ask the service question:

```bash role=command lines=on
ss -lntp
curl --fail --silent --show-error --max-time 2 http://127.0.0.1:8080/ready
```

For `ss`, `-l` means listening, `-n` numeric, `-t` TCP, and `-p` process attribution when permitted. The curl command is valid only for an approved, credential-free, side-effect-free localhost endpoint. Readiness still does not prove a complete business transaction.

## Decision path

```text role=diagram lines=off
User operation failing?
  |
  +-- no -> record the observation boundary; do not manufacture an incident
  |
  +-- yes -> preserve time, scope, deploy, unit, PID/start, request evidence
               |
               +-- process absent? -> manager + first exit + start failure
               +-- process present, no listener? -> init + bind + namespace
               +-- listener present, readiness fails? -> app + dependencies
               +-- readiness passes, user fails? -> proxy + TLS + data path

Before mutation: hypothesis -> expected result -> abort -> rollback -> success test
After mutation: process -> readiness -> traffic admission -> real operation
```

For urgent recovery, preserve a small evidence packet: UTC window, unit properties, bounded logs, PID plus start time, deployment identity, listener/readiness state, and one failing request identifier. Replacing one unhealthy instance behind healthy capacity is often safer than experimenting on the fleet.

## Guided Ubuntu lab

This lab creates one uniquely tagged non-root Bash process. It never uses Docker, systemd mutation, sudo, a network, or a real service PID.

From `book/labs/LES-0002-process-lifecycle`:

```bash role=command file=book/labs/LES-0002-process-lifecycle/lab.sh lines=on
bash lab.sh check
bash lab.sh setup
bash lab.sh inject
bash lab.sh observe
bash lab.sh status
bash lab.sh terminate
bash lab.sh cleanup
bash lab.sh check
```

Before `terminate`, predict: owner UID, PID start ticks, and token will match; SIGTERM will create a `term_received` event; the process will disappear; cleanup will remove only allowlisted artifacts; final check will report absent state and zero candidates.

If any invariant fails, stop. A refusal is successful safety behavior. Never substitute sudo or broad `pkill`.

## Production transfer

**Container:** PID 1 may be the application. If it does not forward signals or reap children, shutdown and zombie behavior changes. Inspect entrypoint, stop signal, timeout, runtime events, and namespace boundaries.

**Kubernetes:** a container restart, Pod replacement, readiness failure, Service endpoint removal, and failed user request are separate events. Termination includes pre-stop behavior, signal delivery, grace period, endpoint propagation, draining, and disruption constraints. `Running` is not readiness.

**Cloud or private VM:** systemd state belongs to the guest; replacement, health checks, disks, interfaces, and console logs may belong to the platform. Join instance identity and boot ID with invocation and request evidence.

**Fleet:** encode unit configuration, health semantics, restart bounds, dashboards, alerts, and rollback in reviewed automation. Canary changes and retain cohort dimensions.

## Reliability, security, observability, capacity, and cost

**Reliability:** restart loops consume CPU, reopen connections, repeat migrations, flood dependencies, and reset caches. Backoff limits damage but does not repair the first failure.

**Security:** arguments and environments may contain secrets. Prefer metadata and approved redaction. Never paste `/proc/PID/environ` or full journal payloads into tickets without review. Do not weaken ptrace or credential controls to simplify diagnosis.

**Observability:** record starts, ready transitions, graceful-stop duration, forced terminations, exit category, restart rate, descriptor utilization, dependency timeouts, and user-operation success. Attach bounded unit, version, deployment, instance, namespace, and invocation dimensions.

**Capacity:** PIDs, threads, descriptors, sockets, memory, CPU, and pools have limits. Track approach rate, allocation failures, saturation, queueing, workload, and service impact together.

**Cost:** blind scaling can multiply a crash loop and downstream load. Long termination grace uses overlapping capacity; short grace loses work. Measure drain behavior and choose a budget.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| PID exists, so service is healthy | Existence is earlier than readiness | Measure readiness and the user operation |
| `kill -9` first | Skips cleanup and destroys evidence | Preserve identity; try bounded graceful termination |
| Exit 137 means OOM | It does not identify the sender | Correlate cgroup, kernel, runtime, and audit evidence |
| D state ignores SIGKILL | Kernel wait delays completion | Diagnose wait channel and owned resource |
| Kill the zombie | The child is already dead | Repair the parent reaping failure |
| One descriptor count proves a leak | It is one capacity sample | Compare time series, types, limits, errors, peers |
| Parse `systemctl status` prose | It is incomplete and human-oriented | Query explicit properties and verify readiness |
| Restart until green | It erases evidence and amplifies load | Bound retries, preserve first failure, define rollback |

## Memory card and retrieval

Remember **E-S-C-A-P-E**:

- **E**nd-user operation: what fails from which boundary?
- **S**upervisor: what unit or controller wants to exist?
- **C**urrent identity: namespace, PID, owner, start time, invocation.
- **A**ctual state: threads, descriptors, sockets, dependencies, logs.
- **P**reserve then act: what will mutation erase, and what is rollback?
- **E**nd-to-end verify: readiness, admission, and real operation.

Questions:

1. Why can a running process represent an unavailable service?
2. What does 137 narrow, and what remains unknown?
3. Why can a process remain in D after SIGKILL?
4. What owns a zombie's remaining cleanup?
5. Which identifiers make a stored PID safe enough to target in this lab?
6. Which evidence separates systemd state from customer success?

## Complete answers

**1. Running but unavailable:** a PID proves only that an execution context exists. It may be blocked, initializing, listening on the wrong address, failing dependencies, excluded from traffic, or returning errors. Trace MainPID and state through listener, readiness, admission, and a real operation.

**2. Exit 137:** it is consistent with signal 9 in common reporting. Identify the actor through cgroup memory events, kernel OOM evidence, orchestrator/runtime reason, deployment termination, and audit timestamps. Never label OOM from the number alone.

**3. D after SIGKILL:** application cleanup cannot run, but the kernel cannot complete termination until the uninterruptible wait returns. Preserve PID/start identity, inspect wait evidence, correlate filesystem, device, or network-filesystem ownership, and recover that platform boundary.

**4. Zombie ownership:** the parent must collect the terminated child's wait status. Inspect PPID, quantify accumulation and PID pressure, fix the wait logic or supervisor, and replace the faulty parent through a controlled path.

**5. Safe lab PID:** current UID, exact `/proc/PID` ownership, recorded kernel start-time ticks, and a unique command token checked immediately before signaling. This is a bounded lab control, not universal production authorization.

**6. systemd versus customer:** manager properties explain manager state; `ss` explains a local socket; readiness explains traffic eligibility; a synthetic or real operation explains delivered service. Keep the four claims separate.

## Product-company interview

**Scenario:** A payment API on 200 Ubuntu VMs restarts after a rollout. Half show exit 137. `systemctl status` alternates between active and auto-restart, CPU is normal, and the load balancer removes instances.

**Strong opening:** “I will define customer impact and freeze a timeline. Exit 137 narrows termination to SIGKILL-like reporting but does not prove OOM. I will compare rollout cohorts, preserve the first failing invocation, and separate termination, systemd policy, readiness, and traffic admission.”

Sample affected instances, not all 200. Record boot ID, unit properties, PID/start identity, bounded journal, platform events, cgroup memory events and limits, kernel OOM evidence, deployment termination records, and readiness history. Compare the first divergence with healthy controls.

If evidence ties failure to the rollout and prior capacity is safe, pause and roll back through the deployment mechanism. Preserve a representative when policy permits. Verify with payment-safe synthetic success, stable readiness, declining restarts, dependency health, and restored error-budget burn.

Prevent recurrence with canary gates on restart rate and user-operation SLI, structured termination actor/reason, measured memory limits, bounded restart backoff, graceful shutdown testing, and reviewed rollback criteria.

**Weak answer:** “137 is OOM, so add memory and restart everything.” It invents the sender, changes capacity without a measured boundary, erases evidence, and lacks rollback or user verification.

**Follow-up — cgroup memory events are zero:** OOM is less likely in that cgroup, not disproved everywhere. Verify cgroup identity, host OOM evidence, controller/operator termination, and runtime state. State gaps.

**Follow-up — one process is D:** remove the instance from traffic, preserve kernel-wait evidence, identify its backing resource and cohort, and use platform replacement or storage recovery. More signals add no value.

**Follow-up — rollback unavailable:** stop rollout, protect healthy capacity, reduce unsafe concurrency, and use the smallest tested mitigation with abort and success signals. Do not improvise on 200 hosts.

## Independent transfer and rubric

On a disposable Ubuntu 24.04 VM, choose a noncritical local systemd service other than `systemd-journald.service` and a credential-free, side-effect-free localhost readiness operation. Do not edit units, restart services, change limits, or contact production.

Produce an environment card; an ownership diagram; bounded timestamped evidence with proof limits; an explanation of normal exit, signal termination, D, and Z branches; a proposed recovery with rollback and success checks; and cleanup-boundary plus assistance disclosure.

Rubric: boundary and safety 4 points; process/systemd model 4; evidence interpretation 4; independent hypothesis testing 4; production transfer and verification 4. A reviewer must inspect original evidence. Reading time and button clicks never award mastery.

## References and review

- `REF-1200`: Linux man-pages `signal(7)`.
- `REF-1201`: Linux man-pages `proc_pid_stat(5)` and `waitpid(2)`.
- `REF-1202`: systemd manuals for service management, property inspection, and journal filtering.

Review by 2027-03-02 or earlier if Ubuntu, procps, systemd output, lab behavior, or the reader contract changes. Re-run schema, parser, lab, route, search, state-migration, and accessibility checks before raising status.
