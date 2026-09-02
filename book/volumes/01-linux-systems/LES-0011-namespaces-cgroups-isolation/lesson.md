---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0011",
  "aliases": ["V01-L08", "namespaces-cgroups-isolation"],
  "curriculumIds": ["LNX-007"],
  "slug": "namespaces-cgroups-isolation",
  "route": "/book/linux/namespaces-cgroups-isolation",
  "order": 8,
  "volume": "01-linux-systems",
  "title": "Linux namespaces, cgroups, and the container illusion",
  "summary": "See a container as a Linux process with selected views, resource rules, and adjacent security controls; then diagnose failures at the boundary that actually owns them.",
  "domain": "linux",
  "level": {
    "from": "intermediate",
    "to": "advanced"
  },
  "estimatedMinutes": 240,
  "prerequisiteLessonIds": ["LES-0002", "LES-0003", "LES-0004", "LES-0005"],
  "prerequisiteCurriculumIds": ["LNX-002", "LNX-003", "LNX-004", "NET-003"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS with a Linux 6.8-series kernel and cgroup v2",
      "support": "required",
      "notes": "The guided fixture runs as a normal user, mutates only a guarded /tmp directory, and performs optional read-only observation of the current process."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "Namespace and cgroup views may be owned partly by Docker Desktop or the WSL utility VM; the lab treats those differences as evidence and does not attempt host mutation."
    },
    {
      "platform": "Docker Desktop Linux containers",
      "version": "Current locally installed engine",
      "support": "concept-only",
      "notes": "Transfer commands are read-only examples. The guided lab does not require Docker, pull images, or create containers."
    },
    {
      "platform": "Local Kubernetes",
      "version": "Current supported release",
      "support": "concept-only",
      "notes": "Kubernetes diagnosis is explained, but this lesson creates no cluster or workload. Resource behavior must be verified against the installed runtime, kubelet, and kernel versions."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "cloud-infrastructure-engineer",
    "production-engineer"
  ],
  "learningObjectives": [
    "Explain a container as ordinary Linux processes whose namespace memberships change what they can see and whose cgroup memberships change how resources are accounted and controlled.",
    "Identify PID, mount, network, user, UTS, IPC, cgroup, and time namespaces and name the state each one virtualizes.",
    "Read namespace links and cgroup v2 files without treating an inode-like namespace identifier or one counter as a complete diagnosis.",
    "Distinguish accounting, relative weight, protection, throttling, and hard limits across CPU, memory, I/O, and process-count controllers.",
    "Diagnose cgroup-local out-of-memory kills and process-count exhaustion even when host-level tools appear healthy.",
    "Distinguish namespaces and cgroups from Linux capabilities, seccomp system-call filtering, Linux Security Modules, filesystem controls, and virtual-machine isolation.",
    "Trace a failure across application, container, runtime, cgroup, node, and Kubernetes control-plane evidence while preserving identity and time scope.",
    "Choose reversible remediation and prevention controls without weakening isolation or changing a systemd-managed cgroup hierarchy by hand."
  ],
  "productionSignals": [
    "A container reports PID 1, root identity, or an empty process list that disagrees with the host view.",
    "A port is listening inside a container but absent or bound differently in the host network namespace.",
    "A workload exits with status 137 while the node still reports free memory.",
    "CPU latency rises with low host utilization while the workload cgroup reports throttling.",
    "fork or thread creation returns resource temporarily unavailable while the host PID space is healthy.",
    "Kubernetes reports OOMKilled, CrashLoopBackOff, eviction, or a resource-limit event whose owner is unclear.",
    "Two processes see different mounts, hostnames, routes, users, or cgroup paths even though they share one kernel."
  ],
  "diagrams": [
    {
      "id": "LES-0011-DIA-001",
      "title": "The container illusion is assembled from Linux boundaries",
      "direction": "hierarchical",
      "boundaries": ["orchestrator and runtime", "namespace memberships", "cgroup hierarchy", "adjacent security controls", "shared host kernel", "physical or virtual machine"],
      "evidencePoints": ["runtime configuration", "/proc/PID/ns links", "/proc/PID/cgroup", "capability and seccomp status", "kernel and node events", "consumer operation"],
      "textAlternative": "A runtime starts ordinary processes in selected namespaces and cgroups, applies capabilities, seccomp, filesystem and security policy, and all those processes still execute through the host kernel."
    },
    {
      "id": "LES-0011-DIA-002",
      "title": "cgroup v2 resource policy flows down one hierarchy",
      "direction": "hierarchical",
      "boundaries": ["root cgroup", "system slice or workload parent", "pod or service cgroup", "container cgroup", "processes and threads"],
      "evidencePoints": ["cgroup.controllers", "cgroup.subtree_control", "memory.current and memory.max", "cpu.stat and cpu.max", "pids.current and pids.max"],
      "textAlternative": "Controllers are enabled from a parent for its children; each child can be constrained further but cannot escape a tighter ancestor, and counters may include descendant work."
    },
    {
      "id": "LES-0011-DIA-003",
      "title": "Cross-boundary incident diagnosis",
      "direction": "left-to-right",
      "boundaries": ["user operation", "application process", "container view", "runtime state", "cgroup evidence", "node kernel", "orchestrator decision"],
      "evidencePoints": ["request result", "PID and timestamp", "namespace identifiers", "container identity", "limit and event deltas", "OOM or scheduler evidence", "pod status and events"],
      "textAlternative": "Diagnosis begins at the failed operation, freezes workload and process identity, then joins namespace, cgroup, kernel, runtime, and orchestration evidence instead of trusting one layer."
    }
  ],
  "commands": [
    {
      "id": "LES-0011-CMD-001",
      "question": "Which process identity and namespace memberships does this shell actually have?",
      "risk": "read-only",
      "command": "printf 'pid=%s uid=%s\\n' \"$$\" \"$(id -u)\"; readlink /proc/self/ns/{mnt,pid,net,user,uts,ipc,cgroup,time} 2>/dev/null",
      "runFrom": "Ubuntu 24.04 as the normal user; missing time namespace output is a supported version or permission branch",
      "expectedBranches": [
        {
          "when": "Links such as mnt:[4026531841] are returned",
          "meaning": "The shell has one kernel namespace object for each displayed type.",
          "nextEvidence": "Compare the same links for PID 1 or the target process; equality, not the absolute number, is the useful fact."
        },
        {
          "when": "One link is absent or permission is denied",
          "meaning": "The current kernel, procfs mount, or access boundary does not expose that observation.",
          "nextEvidence": "Record the missing field and inspect from an authorized owner boundary rather than claiming the namespace is absent."
        }
      ],
      "proves": "The PID and effective UID printed by the shell and namespace-link identities visible through this procfs view at that moment.",
      "doesNotProve": "That the process is securely isolated, which process created the namespaces, what resources it may use, or whether another namespace has the same human-readable state."
    },
    {
      "id": "LES-0011-CMD-002",
      "question": "Does this shell share each namespace type with PID 1 in the current PID view?",
      "risk": "read-only",
      "command": "for n in mnt pid net user uts ipc cgroup; do printf '%-7s self=%s pid1=%s\\n' \"$n\" \"$(readlink /proc/self/ns/$n)\" \"$(readlink /proc/1/ns/$n)\"; done",
      "runFrom": "Ubuntu 24.04 where procfs permits reading both link sets",
      "expectedBranches": [
        {
          "when": "The identifiers match for a type",
          "meaning": "The two observed processes are members of the same namespace object for that type.",
          "nextEvidence": "Check other types independently; namespace membership is not all-or-nothing."
        },
        {
          "when": "The identifiers differ",
          "meaning": "The processes see different virtualized instances for that namespace type.",
          "nextEvidence": "Inspect the state owned by that type, such as routes for net or mount tables for mnt, from both authorized views."
        }
      ],
      "proves": "Same-or-different namespace membership for the displayed process pair and types.",
      "doesNotProve": "Parent-child namespace relationships, equivalent configuration, security strength, or cgroup resource limits."
    },
    {
      "id": "LES-0011-CMD-003",
      "question": "Which namespace objects and representative processes can this identity enumerate?",
      "risk": "read-only",
      "command": "lsns --output NS,TYPE,NPROCS,PID,USER,COMMAND --noheadings",
      "runFrom": "Ubuntu 24.04 with util-linux installed; sanitize command text before sharing",
      "expectedBranches": [
        {
          "when": "Rows are returned",
          "meaning": "lsns found namespace objects reachable through processes visible and readable to this identity.",
          "nextEvidence": "Filter by one target type and compare /proc/PID/ns links for the exact workload process."
        },
        {
          "when": "Rows or fields are missing",
          "meaning": "Permissions or PID visibility constrain enumeration.",
          "nextEvidence": "Move to an approved host or runtime support boundary; do not interpret absence as nonexistence."
        }
      ],
      "proves": "The namespace objects, counts, and representative processes that lsns can discover in the current view.",
      "doesNotProve": "A complete host inventory, active resource limits, or that NPROCS stayed unchanged after the sample."
    },
    {
      "id": "LES-0011-CMD-004",
      "question": "Is this environment using the unified cgroup v2 filesystem, and what path does this process report?",
      "risk": "read-only",
      "command": "findmnt -no FSTYPE,OPTIONS,TARGET /sys/fs/cgroup; cat /proc/self/cgroup",
      "runFrom": "Ubuntu 24.04 as the normal user",
      "expectedBranches": [
        {
          "when": "FSTYPE is cgroup2 and the membership line begins 0::",
          "meaning": "The visible hierarchy uses cgroup v2 and the third membership field is the path visible from this cgroup namespace.",
          "nextEvidence": "Resolve the current directory under the visible cgroup mount, then inspect only readable controller files."
        },
        {
          "when": "FSTYPE is not cgroup2 or membership has controller names",
          "meaning": "The environment is using cgroup v1 or a hybrid layout.",
          "nextEvidence": "Stop this v2-specific command path and use documentation matching the actual hierarchy."
        }
      ],
      "proves": "The filesystem type and mount options visible at /sys/fs/cgroup plus this process's reported membership record.",
      "doesNotProve": "Which orchestrator set policy, whether controllers are delegated, or the host-absolute path hidden by a cgroup namespace."
    },
    {
      "id": "LES-0011-CMD-005",
      "question": "Which controllers can this cgroup offer to children and which are enabled for immediate children?",
      "risk": "read-only",
      "command": "cg=/sys/fs/cgroup$(awk -F: '$1==\"0\" {print $3}' /proc/self/cgroup); printf 'path=%s\\n' \"$cg\"; cat \"$cg/cgroup.type\" \"$cg/cgroup.controllers\" \"$cg/cgroup.subtree_control\"",
      "runFrom": "A cgroup v2 Ubuntu view where the computed path remains under /sys/fs/cgroup; do not write controller files",
      "expectedBranches": [
        {
          "when": "Controller names appear in cgroup.controllers but not cgroup.subtree_control",
          "meaning": "The controllers are available at this node but are not enabled here for immediate child cgroups.",
          "nextEvidence": "Inspect the system manager or runtime's declared resource policy rather than enabling controllers by hand."
        },
        {
          "when": "Files are missing or unreadable",
          "meaning": "The visible namespace root, cgroup version, or delegation boundary differs from the assumed view.",
          "nextEvidence": "Return to findmnt, /proc/self/cgroup, and the runtime or systemd owner."
        }
      ],
      "proves": "The current cgroup type, available controllers, and enabled child controllers visible through the selected directory.",
      "doesNotProve": "That every controller has a configured limit, that writing is authorized, or that an ancestor imposes no tighter bound."
    },
    {
      "id": "LES-0011-CMD-006",
      "question": "What memory does this cgroup use, what is its hard ceiling, and have memory boundary events occurred?",
      "risk": "read-only",
      "command": "cat memory.current memory.max memory.events memory.events.local",
      "runFrom": "The exact cgroup v2 directory for the affected workload, not an arbitrary shell cgroup",
      "expectedBranches": [
        {
          "when": "memory.max is a number and memory.events oom_kill grows across the incident window",
          "meaning": "The hierarchy has a byte ceiling and one or more tasks in its scope were killed by a cgroup out-of-memory decision during that measured delta.",
          "nextEvidence": "Join the counter delta to process or container exit state, runtime events, workload identity, and the user-visible failure."
        },
        {
          "when": "memory.max is max and oom_kill is unchanged",
          "meaning": "This cgroup exposes no finite hard memory ceiling at this level and no new cgroup OOM kill in the sampled interval.",
          "nextEvidence": "Inspect ancestors, node pressure, application allocation failures, and other exit causes."
        }
      ],
      "proves": "Point-in-time memory usage and ceiling plus cumulative memory event counters in the selected cgroup scope.",
      "doesNotProve": "Peak usage between samples, the killed process identity, a global node OOM, memory leak ownership, or that current usage caused a past event."
    },
    {
      "id": "LES-0011-CMD-007",
      "question": "Is this cgroup receiving CPU time and being throttled by quota?",
      "risk": "sampled-read-only",
      "command": "cat cpu.max cpu.weight cpu.stat; sleep 2; cat cpu.stat",
      "runFrom": "The exact workload cgroup v2 directory; the two-second wait does not create load",
      "expectedBranches": [
        {
          "when": "nr_throttled and throttled_usec increase while latency rises",
          "meaning": "The workload was denied CPU time by quota during some periods in this sample.",
          "nextEvidence": "Calculate deltas, correlate runnable work and latency, then compare requested policy with effective ancestor limits."
        },
        {
          "when": "Counters do not increase",
          "meaning": "No new quota throttling was observed during this short sample.",
          "nextEvidence": "Sample during impact or investigate scheduling contention, I/O wait, locks, and downstream waits."
        }
      ],
      "proves": "Configured quota and relative weight plus cumulative CPU accounting and throttling deltas for the selected cgroup.",
      "doesNotProve": "Guaranteed CPU, host-wide utilization, thread-level hotspots, or that throttling is the only source of latency."
    },
    {
      "id": "LES-0011-CMD-008",
      "question": "Has this workload reached its process or thread-count boundary?",
      "risk": "read-only",
      "command": "cat pids.current pids.max pids.events",
      "runFrom": "The exact workload cgroup v2 directory",
      "expectedBranches": [
        {
          "when": "pids.current equals a numeric pids.max and the max event counter has increased",
          "meaning": "Task creation reached the configured cgroup boundary at least once.",
          "nextEvidence": "Inspect thread and process growth, owner identity, retries, and the application error at the same time before changing the limit."
        },
        {
          "when": "pids.max is max or current is far below it with no event delta",
          "meaning": "This level supplies no finite task ceiling or did not show exhaustion in the sampled window.",
          "nextEvidence": "Check ancestors, per-user limits, kernel pid_max, and application-specific pools."
        }
      ],
      "proves": "Current task count, configured task ceiling, and cumulative pids-controller limit events for the selected scope.",
      "doesNotProve": "Why tasks accumulated, which thread leaked, or whether a different RLIMIT_NPROC or host PID boundary failed."
    },
    {
      "id": "LES-0011-CMD-009",
      "question": "How much recent time did work in this cgroup lose to CPU, memory, or I/O pressure?",
      "risk": "sampled-read-only",
      "command": "for f in cpu.pressure memory.pressure io.pressure; do printf '%s\\n' \"$f\"; cat \"$f\"; done",
      "runFrom": "The exact workload cgroup v2 directory on a kernel exposing pressure stall information",
      "expectedBranches": [
        {
          "when": "some or full averages are elevated during impact",
          "meaning": "Runnable work in the cgroup spent measurable time stalled for the named resource over the displayed windows.",
          "nextEvidence": "Compare healthy and affected intervals and join pressure with controller counters and operation latency."
        },
        {
          "when": "Files are absent or averages are zero",
          "meaning": "PSI is unavailable in this view or no stall time appears in the represented windows.",
          "nextEvidence": "Do not convert missing or zero pressure into application health; inspect the other owners in the request path."
        }
      ],
      "proves": "Kernel pressure-stall averages and cumulative microseconds available for that cgroup and sample time.",
      "doesNotProve": "Which code path stalled, future capacity, exact percentile latency, or the cause of the pressure."
    },
    {
      "id": "LES-0011-CMD-010",
      "question": "Which adjacent privilege and syscall-filter states apply to this process?",
      "risk": "read-only",
      "command": "grep -E '^(CapInh|CapPrm|CapEff|CapBnd|CapAmb|NoNewPrivs|Seccomp|Seccomp_filters):' /proc/self/status",
      "runFrom": "The exact target process context when possible; self reports only the inspecting shell",
      "expectedBranches": [
        {
          "when": "Capability masks, NoNewPrivs, and Seccomp fields are printed",
          "meaning": "procfs exposes bit masks and filter state for this process.",
          "nextEvidence": "Decode masks with version-matched capability tooling and inspect the runtime policy; never infer allowed operations from UID alone."
        }
      ],
      "proves": "The process capability-set masks and kernel-reported no-new-privileges and seccomp mode visible at sampling time.",
      "doesNotProve": "Complete sandbox strength, Linux Security Module policy, filesystem permissions, namespace membership, or whether one denied syscall caused an incident."
    },
    {
      "id": "LES-0011-CMD-011",
      "question": "What resource policy did Docker declare, and what outcome did the runtime record?",
      "risk": "read-only",
      "command": "( : \"${CONTAINER_REF:?export CONTAINER_REF as one exact container ID or name}\"; docker inspect --format 'id={{.Id}} memory={{.HostConfig.Memory}} nano_cpus={{.HostConfig.NanoCpus}} pids_limit={{.HostConfig.PidsLimit}} oom_killed={{.State.OOMKilled}} exit_code={{.State.ExitCode}}' \"$CONTAINER_REF\" )",
      "runFrom": "The authorized Docker host after exporting `CONTAINER_REF` as one exact local container ID or name; an unset value fails before Docker runs",
      "expectedBranches": [
        {
          "when": "Finite limits and oom_killed=true are reported",
          "meaning": "Docker declared those limits for the container and recorded an OOM-killed terminal outcome.",
          "nextEvidence": "Correlate the exact start/finish time and PID with cgroup event deltas and application impact."
        },
        {
          "when": "Zero or null limit values are reported",
          "meaning": "Docker did not declare that finite constraint through the displayed field.",
          "nextEvidence": "Inspect effective cgroup and ancestor policy; zero does not mean the host has infinite resources."
        }
      ],
      "proves": "Selected Docker configuration fields and runtime-recorded terminal state for one identified container.",
      "doesNotProve": "The complete effective ancestor policy, kernel causal chain, current application health, or Kubernetes ownership."
    },
    {
      "id": "LES-0011-CMD-012",
      "question": "What resource declaration, last termination reason, restart count, and node placement does Kubernetes record?",
      "risk": "read-only",
      "command": "( : \"${KUBE_NAMESPACE:?export KUBE_NAMESPACE as the authorized namespace}\"; : \"${POD_NAME:?export POD_NAME as the exact pod name}\"; kubectl --namespace=\"$KUBE_NAMESPACE\" get pod \"$POD_NAME\" -o jsonpath='{.metadata.uid}{\"\\n\"}{.spec.nodeName}{\"\\n\"}{.status.containerStatuses[*].name}{\"\\n\"}{.status.containerStatuses[*].restartCount}{\"\\n\"}{.status.containerStatuses[*].lastState.terminated.reason}{\"\\n\"}{.status.containerStatuses[*].lastState.terminated.exitCode}{\"\\n\"}{.spec.containers[*].resources}{\"\\n\"}' )",
      "runFrom": "An authorized local Kubernetes context after exporting exact `KUBE_NAMESPACE` and `POD_NAME` values; either unset value fails before kubectl runs",
      "expectedBranches": [
        {
          "when": "The last reason is OOMKilled and restartCount is nonzero",
          "meaning": "The kubelet reported at least one prior container termination as OOMKilled and the container has restarted in this pod identity.",
          "nextEvidence": "Correlate the container runtime ID, timestamps, cgroup memory events, node pressure, and current replacement state."
        },
        {
          "when": "Last-state fields are empty",
          "meaning": "The current pod status has no retained prior termination in those selected fields.",
          "nextEvidence": "Inspect bounded pod events, runtime state, logs from the previous instance when available, and monitoring history."
        }
      ],
      "proves": "Selected Kubernetes desired resource fields and current API-recorded pod/container status at query time.",
      "doesNotProve": "The complete kernel decision, a memory leak, node-wide safety, or that the current container still has the same runtime identity as the terminated one."
    }
  ],
  "labs": [
    {
      "id": "LES-0011-LAB-001",
      "title": "Map the container illusion and diagnose a bounded virtual limit incident",
      "mode": "guided",
      "environment": "Normal-user Ubuntu 24.04 or WSL 2 Ubuntu 24.04; deterministic Python fixture plus optional read-only /proc and cgroup observation",
      "timeMinutes": 45,
      "privilege": "Normal user only; root and sudo are refused or unnecessary",
      "network": "No network, image pull, socket, Docker daemon, Kubernetes API, or cloud resource",
      "changes": [
        "One mode-0700 lesson-specific directory directly under /tmp",
        "One mode-0600 UID-scoped state descriptor under /tmp",
        "Small allowlisted fixture and evidence files; no resource pressure, background process, namespace creation, or cgroup write"
      ],
      "abortConditions": [
        "Any command requests root, sudo, package installation, network access, or a path outside the exact registered /tmp boundary",
        "The descriptor, root, sentinel, ownership, file type, link count, mode, canonical path, or artifact allowlist fails validation",
        "A host observation exposes information that is not approved for recording"
      ],
      "recovery": "Use only bash lab.sh recover for the virtual case and bash lab.sh cleanup for guarded state removal; never substitute a recursive delete after a refusal.",
      "cleanupProof": "Cleanup validates the byte-exact descriptor and sentinel, canonical current-UID root, and every allowlisted regular single-link artifact, removes files individually, removes the empty directory, then proves the descriptor and registered root are absent.",
      "path": "book/labs/LES-0011-namespaces-cgroups-isolation"
    }
  ],
  "incidents": [
    {
      "id": "LES-0011-INC-001",
      "signal": "A payment worker is repeatedly terminated with exit code 137 while free inside the container appears to show many gibibytes available.",
      "firstThought": "Exit 137 means SIGKILL, not automatically OOM. Freeze pod, container, process, cgroup, node, and time identity; then compare the effective memory boundary and event deltas with runtime and Kubernetes termination evidence.",
      "safePath": "Protect service capacity, preserve previous-instance evidence, read memory.current, memory.max, memory.events and ancestor or node pressure, correlate OOMKilled and timestamps, then use a reviewed rollback, traffic shift, or correctly sized limit change and verify the real payment operation.",
      "trap": "Treating host or container free output as the workload limit, or raising memory blindly, can hide a leak, move pressure to the node, increase cost, and kill unrelated workloads."
    },
    {
      "id": "LES-0011-INC-002",
      "signal": "An API reports that it listens on 127.0.0.1:8080 inside a container, yet a host-side request to 127.0.0.1:8080 is refused.",
      "firstThought": "Loopback belongs to a network namespace. Prove whether the application and client share the same network namespace and whether the runtime publishes or proxies a host endpoint.",
      "safePath": "Verify the exact process and namespace links, inspect listeners inside the workload through the authorized runtime, inspect declared port publication and the host listener separately, then test the intended consumer path without weakening network isolation.",
      "trap": "Binding the application to every interface or using host networking as a quick fix can expand exposure while leaving the runtime or service mapping defect unresolved."
    }
  ],
  "assessmentIds": ["ASM-0016", "ASM-0017", "ASM-0018"],
  "referenceIds": ["REF-0041", "REF-0042", "REF-0043", "REF-0044", "REF-0045", "REF-0046", "REF-0047", "REF-0048"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The guided fixture models namespace and cgroup evidence; it does not create a real namespace, cgroup, container, pod, resource shortage, or performance benchmark.",
    "Read-only host observations may differ under WSL, containers, cgroup namespaces, systemd delegation, kernel configuration, and access policy; absence is an evidence branch, not automatic failure.",
    "Docker and Kubernetes transfer commands require an already authorized local environment and are not executed by the lab.",
    "Kernel, runtime, systemd, and Kubernetes behavior remains version-sensitive; verify installed versions and effective ancestor policy before production decisions.",
    "Publication, lab verification, website completion state, and model-answer reveal do not demonstrate learner mastery; independent reviewed evidence is still required."
  ]
}
---

# Linux namespaces, cgroups, and the container illusion

## What you see and first thought

You open a shell in a container. It says the process is PID 1. It says the user is `root`. It shows one network interface, a short mount table, and 32 GiB of free memory. On the host, the same workload is PID 42817, runs under an unprivileged host identity, shares a machine with hundreds of processes, and has a 512 MiB memory ceiling.

None of those observations has to be false. They can all be true from different kernel views.

Here is the memory hook:

> A container is not a tiny machine hidden inside a big machine. It is an ordinary Linux process wearing selected views and living inside selected resource fences.

The **views** are primarily namespaces. The **resource fences and meters** are cgroups, short for control groups. Other controls - filesystem ownership, Linux capabilities, seccomp filters, Linux Security Modules, and runtime policy - decide what operations the process may perform. The host kernel executes every system call. A virtual machine is different because it normally has its own guest kernel.

When you see a container failure, do not ask only, "Is the host healthy?" Ask four boundary questions:

1. Which exact process or container instance failed?
2. Which namespace view produced this evidence?
3. Which cgroup and ancestor limits governed it?
4. Which kernel, runtime, or orchestrator recorded the outcome?

That habit explains two famous contradictions:

- **"The host has memory, but my container was OOM-killed."** Host availability and a cgroup-local memory ceiling are different boundaries.
- **"The app listens on localhost, but the host cannot connect."** Each network namespace has its own loopback interface and port space.

Do not jump from `137` to "memory leak." An exit status of 137 conventionally means 128 plus signal 9, `SIGKILL`. A cgroup out-of-memory kill is one reason for SIGKILL, but an operator, runtime, timeout supervisor, or node shutdown can also send it. Build a joined timeline before choosing a cause.

## Terms before commands

Every word in this chapter points to an owner. Learn the owner and the commands become easier to remember.

| Term | Everyday picture | Precise meaning | Why it matters on call |
|---|---|---|---|
| Kernel | the building manager | privileged Linux core that schedules tasks, manages memory and devices, enforces isolation, and services system calls | containers on one host share this owner |
| Process | a running program instance | an address space and execution context identified by a process ID in a PID namespace | runtime and app evidence must refer to the same instance |
| Thread or task | one execution lane | a schedulable kernel task; threads in one process share resources but have task IDs | PID limits and CPU accounting can be consumed by threads, not only process names |
| Namespace | a room with its own window | a kernel object that virtualizes one category of system state for member processes | an observation is scoped to the viewer's namespace |
| Namespace membership | which room a process stands in | association between a task and one namespace object of each supported type | compare `/proc/PID/ns` identities before comparing views |
| PID namespace | a private process-number view | virtualizes process IDs and visibility, with a namespace-init process shown as PID 1 | PID 1 inside a container is not necessarily host PID 1 |
| Mount namespace | a private map of attached filesystems | gives members a mount table and propagation relationships | a path or mount visible in one namespace may not exist in another |
| Network namespace | a private network stack view | separates interfaces, addresses, routes, sockets, port numbers, firewall state, and related network resources | `127.0.0.1` means this network namespace's loopback |
| User namespace | an identity translation boundary | maps user and group IDs between a namespace and its parent and scopes capabilities | namespace UID 0 can map to an unprivileged host UID |
| UTS namespace | a private nameplate | virtualizes hostname and Network Information Service domain name | identical hostnames do not prove identical machines; different names may share a kernel |
| IPC namespace | a private intercom | isolates System V IPC objects and POSIX message queues | shared-memory or queue evidence can disappear across this boundary |
| cgroup namespace | a cropped resource-family view | virtualizes the cgroup path shown through procfs | `/proc/self/cgroup` may show `/` even when the host path is deeper |
| Time namespace | an offset clock view | virtualizes selected monotonic and boot-time clock offsets, not every clock | cross-namespace timestamps require careful joining |
| cgroup | a family folder with meters and rules | a hierarchical grouping of tasks used for resource accounting, distribution, protection, throttling, and limits | this is where a container's effective resource boundary often lives |
| cgroup v2 | one family tree | unified cgroup interface with one hierarchy and controller files | Ubuntu 24.04 commonly uses this model; v1 commands are not interchangeable |
| Controller | a resource-specific rule engine | kernel cgroup component such as `cpu`, `memory`, `io`, `pids`, or `cpuset` | each controller exposes different semantics; not every value is a hard limit |
| Hierarchy | parent and child folders | cgroup tree in which constraints and accounting flow across ancestors and descendants | a generous child cannot escape a tight parent |
| Delegation | permission to manage one subtree | controlled transfer of cgroup-subtree administration while protecting ancestors | hand-written changes inside a systemd/runtime-owned tree can violate ownership |
| Accounting | the meter | counters or gauges describing resource use and events | observing usage does not itself impose a limit |
| Weight | share during contention | relative preference among sibling cgroups, such as `cpu.weight` | it is not a reservation and may have little effect when capacity is idle |
| Protection | preference against reclaim | controls such as `memory.low` or `memory.min` that influence which memory is reclaimed | protection is not the same as a maximum |
| Throttling | a temporary closed gate | delaying work after it exceeds a rate or high boundary, such as CPU quota | work may stay alive while tail latency rises sharply |
| Hard limit | a fence | maximum such as `memory.max` or `pids.max` whose breach triggers enforcement | the failure can occur while the host still has spare capacity |
| OOM | out of memory | inability to satisfy memory demand within a relevant allocation boundary | distinguish cgroup-local enforcement from node-wide memory exhaustion |
| Capability | one separated privilege key | a bit-granular privilege checked in relation to a user namespace | root text alone does not tell you which privileged actions are allowed |
| seccomp | system-call filter | kernel facility that evaluates system-call metadata and returns allow, error, kill, notify, or related actions | a denied syscall can look like an app defect, but seccomp is not a complete sandbox |
| LSM | Linux Security Module | kernel security framework used by controls such as AppArmor or SELinux | object-access denial is different from namespace visibility or resource exhaustion |
| Container runtime | the stage crew | software that configures root filesystem, namespaces, cgroups, credentials, capabilities, seccomp, and starts the process | runtime declared state must be joined with effective kernel state |
| OCI | Open Container Initiative | specifications for image and runtime configuration interoperability | a portable description does not remove kernel/version differences |
| Pod | Kubernetes scheduling and sharing unit | one or more containers that commonly share selected namespaces and lifecycle context | a pod is not a cgroup file and a pod phase is not a kernel verdict |
| Request | scheduler promise | resource amount Kubernetes uses mainly for placement and QoS decisions | a request is not normally a hard runtime ceiling |
| Limit | runtime ceiling declaration | maximum Kubernetes asks the runtime/kernel to enforce for a container resource | CPU limit throttles; memory limit enforcement may terminate a task |

Namespace types are independent. Two processes can share a network namespace but use different mount namespaces. A Kubernetes pod commonly gives its containers one pod network namespace while each container still has its own root filesystem view. Always compare the specific type that owns the observation.

## Architecture map

A runtime assembles a container; the kernel enforces the pieces.

```text
Kubernetes / Docker / systemd / another orchestrator
                 |
                 | desired identity, filesystem, resources, security policy
                 v
        container runtime + OCI runtime
                 |
        +--------+---------+----------------+
        |                  |                |
        v                  v                v
 namespaces           cgroup v2        adjacent controls
 what it sees         what it gets     what it may do
 PID/mount/net        CPU/memory/I/O   UID/GID + capabilities
 user/UTS/IPC         pids/cpuset      seccomp + LSM + modes
 cgroup/time          pressure/events  read-only filesystems
        \                  |                /
         +-----------------+---------------+
                           v
                    shared Linux kernel
                           v
                  VM or physical machine
```

The phrase "container boundary" is convenient but dangerously vague. Name the actual boundary:

- PID visibility is owned by a PID namespace.
- A path-to-filesystem mapping is owned by a mount namespace.
- Localhost, routes, and sockets are owned by a network namespace.
- visible UID mappings and capability scope involve a user namespace.
- CPU, memory, I/O, and task rules are owned by the cgroup hierarchy.
- a syscall denial may be seccomp.
- file access may be discretionary permissions or an LSM policy.

### The unified cgroup tree

```text
/sys/fs/cgroup                         root
|
+-- system.slice                      system services
|   `-- api.service                   service cgroup
|
`-- kubepods.slice                    Kubernetes parent
    `-- kubepods-burstable.slice      QoS parent
        `-- pod-<uid>.slice           pod boundary
            `-- <container>.scope     container tasks

ancestor memory.max = 4 GiB
pod memory.max      = 1 GiB
container memory.max= 512 MiB
effective escape    = none; the tightest applicable ancestor still wins
```

The exact names depend on systemd, the runtime, cgroup driver, and version. Never build automation by guessing a path from a pod name. Resolve runtime identity to the actual process or cgroup and validate the canonical boundary.

A cgroup namespace can make the container's `/proc/self/cgroup` path appear as `/`. That is a view translation, not proof that the process belongs to the host root cgroup.

## Request or state path

Follow one process from declared container to failed request:

```text
1. orchestrator records desired workload
2. runtime prepares filesystem and security policy
3. OCI runtime clones/joins selected namespaces
4. runtime places tasks in a cgroup subtree
5. process execs application code
6. application accepts work and asks the shared kernel for CPU, memory, I/O, sockets, tasks
7. namespace membership shapes what the process sees
8. cgroup controllers account, prioritize, throttle, reclaim, deny, or trigger OOM handling
9. runtime observes process exit and reports state
10. orchestrator may restart, replace, evict, or remove traffic
11. consumer sees success, latency, refusal, timeout, or incorrect result
```

This creates two paths that must not be collapsed:

```text
control path: desired spec -> runtime config -> kernel objects -> status -> controller decision
data path:    client -> network namespace -> socket -> app -> dependency -> durable result
```

A controller saying the desired revision was accepted proves a control-path transition. It does not prove the data path works. A cgroup file saying `memory.current=300000000` proves a point-in-time gauge in one scope. It does not prove that a request completed, that usage never peaked, or that a past OOM event belonged to the current container instance.

Identity is the join key. Record at least:

- pod UID or service unit and container/runtime ID;
- host PID and namespace identities for the relevant process;
- cgroup canonical path and important ancestor;
- process start time and container start/finish time;
- node name, boot ID, kernel, runtime, and deployment revision;
- request ID or safe synthetic operation identity;
- wall-clock window and, where possible, monotonic or cumulative counter deltas.

PIDs are reused. Container names are reused. Pod names can point to new UIDs. Counters survive individual child processes and can aggregate descendants. Never join evidence by a friendly name alone.

## Failure zoom

### Incident A: exit 137 with free host memory

A worker pod restarts. The dashboard shows 48 GiB available on the node. Inside the replacement container, `free -h` also looks generous. The previous container termination says `OOMKilled`, exit code 137.

The wrong conclusion is, "Kubernetes is lying because the node has memory."

The correct mental move is:

```text
137 -> SIGKILL outcome
     -> ask who sent or caused SIGKILL
     -> freeze old container and cgroup identity
     -> read effective memory boundary and event delta
     -> join runtime/Kubernetes/kernel timing
     -> inspect allocation growth and user impact
```

Suppose the exact container cgroup shows:

```text role=output lines=off
memory.current  532676608
memory.max      536870912
memory.events:
  low 0
  high 184
  max 27
  oom 3
  oom_kill 1
  oom_group_kill 0
```

`536870912` bytes is 512 MiB. `memory.current` is a point-in-time aggregate, not a lifetime peak. `high 184` is a cumulative count of occasions the cgroup was pushed above `memory.high` and throttled into reclaim; it is not 184 bytes or 184 processes. `max 27` counts allocation attempts that crossed `memory.max`. `oom 3` counts OOM conditions, while `oom_kill 1` says at least one task was selected and killed. These counters are cumulative. Their **delta during the exact incident window** matters more than the absolute number.

This evidence plus a matching runtime termination strongly supports a cgroup-local OOM kill. It still does not prove a leak. Legitimate working-set growth, changed concurrency, cache policy, request shape, allocator behavior, memory-backed volumes, or a limit regression can create the same boundary event.

Safe restoration may be rollback, traffic reduction, concurrency reduction, or a reviewed limit change after checking node headroom. Verification is the real user operation plus stable memory/event behavior for a stated window. Raising every limit can turn a contained failure into node-wide pressure.

### Incident B: localhost exists twice

The app logs "listening on 127.0.0.1:8080." An operator runs `curl 127.0.0.1:8080` on the host and receives `connection refused`.

Inside a distinct network namespace, `127.0.0.1` is that namespace's loopback. The host's `127.0.0.1` is a different interface. Both namespaces can bind port 8080 without collision.

Evidence path:

1. identify the exact container init or app process;
2. compare `/proc/<pid>/ns/net` with the host diagnostic shell;
3. inspect the listener from inside the authorized container/runtime boundary;
4. inspect the host listener separately;
5. inspect declared port publication, proxy, Service, and target port;
6. test the intended consumer path.

Changing the app to `0.0.0.0` may be necessary for container-interface reachability, but it is not automatically safe. `0.0.0.0` means all interfaces in **that** network namespace. Exposure still depends on runtime publishing, host firewall, Kubernetes Service, NetworkPolicy, and surrounding network controls. Use the smallest fix that restores the designed path without silently widening trust.

## Internals and state ownership

### Namespace objects, links, and lifetime

Linux exposes namespace handles through `/proc/<pid>/ns/<type>`. A link such as `net:[4026532401]` contains the namespace type and an inode-like identifier. If two accessible links for the same type have the same device/inode identity, the processes refer to the same namespace object. The numeric value has no universal semantic ranking and may differ across boots.

A namespace normally persists while a process belongs to it or while a bind mount or open file descriptor pins it. Stopping one process does not always destroy the namespace. PID namespaces are nested; a process has one PID at each visible ancestor level. The first process in a PID namespace acts as namespace init and has special signal and orphan-reaping responsibilities. If it exits, the kernel terminates remaining processes in that PID namespace.

A mount namespace copies or shares mount-table state according to propagation. `private`, `shared`, `slave`, and `unbindable` propagation determine whether later mount events cross boundaries. A different mount namespace does not copy file data: both views may still reference the same underlying filesystem object.

A user namespace maps ranges using `uid_map` and `gid_map`. UID 0 in a child namespace may map to host UID 100000 and have capabilities only relative to objects governed by that user namespace. This supports rootless containers, but user namespaces expose more kernel code to unprivileged callers and are not a complete security boundary.

### cgroup v2 topology and controller ownership

cgroup v2 uses one hierarchy. The core organizes tasks; controllers distribute resources. Key files:

- `cgroup.procs`: process IDs assigned to the cgroup from this namespace view;
- `cgroup.threads`: thread IDs for supported threaded organization;
- `cgroup.controllers`: controllers available for this cgroup to enable for children;
- `cgroup.subtree_control`: controllers enabled to govern immediate children;
- `cgroup.type`: `domain`, `domain threaded`, `domain invalid`, or `threaded` relationship;
- controller files such as `memory.current`, `cpu.max`, and `pids.max`.

Two rules protect hierarchy meaning:

1. **Top-down constraint.** A controller is available to a child only if the parent has it and enabled it for children. A child cannot escape an ancestor's tighter rule.
2. **No internal process for domain controllers.** A non-root domain cgroup that distributes domain resources to children cannot also keep ordinary member processes. Managers place workload processes in leaves and policy in parents.

Do not manually write `cgroup.subtree_control`, move PIDs, or change a file under a systemd/Kubernetes/runtime-owned hierarchy during diagnosis. The system manager owns reconciliation and may overwrite you; a misplaced task can escape intended accounting or destabilize services. Change declared policy through its approved owner, preview scope, and preserve rollback.

### Controller semantics are deliberately different

| Control | Kind | Meaning |
|---|---|---|
| `cpu.weight` | relative weight | sibling share under CPU contention; default is commonly 100 |
| `cpu.max` | bandwidth ceiling | quota and period in microseconds, or `max <period>` |
| `memory.current` | gauge | current charged memory in bytes for the cgroup and descendants |
| `memory.low` | best-effort protection | memory below boundary is protected from reclaim when possible |
| `memory.min` | hard protection | protected memory that can make OOM risk worse if overcommitted |
| `memory.high` | throttle/reclaim boundary | exceeding it causes heavy reclaim/throttling but does not directly invoke OOM kill |
| `memory.max` | hard maximum | if reclaim cannot reduce usage, cgroup OOM handling can occur |
| `memory.swap.max` | swap ceiling | maximum swap usage for the cgroup where swap accounting is enabled |
| `io.weight` | relative weight | relative I/O distribution on supported devices under contention |
| `io.max` | device-specific ceiling | maximum bytes or I/O operations per second for major:minor devices |
| `pids.max` | task ceiling | stops new process/thread creation with `EAGAIN` at the boundary |
| `cpuset.cpus` | placement set | CPUs on which tasks may execute, constrained by effective ancestors |

A request, weight, protection, throttle, and maximum answer different questions. Saying "the CPU limit is 100" without a file name, unit, and cgroup scope is not usable evidence.

### OOM boundaries

The global OOM killer responds to node-wide inability to satisfy allocations. A cgroup OOM decision occurs when a workload cannot stay within `memory.max`. Node free memory can coexist with a cgroup-local OOM. Conversely, a container with `memory.max=max` can still suffer during global node pressure.

`memory.oom.group=1` requests group treatment so a workload is not left partially alive, with exceptions such as tasks protected from OOM selection. It is policy, not a guarantee that data is consistent after termination. Application restart and reconciliation semantics remain your responsibility.

### Adjacent controls: do not call all of them namespaces

- **Capabilities** split traditional root powers into checked bits. Capability sets are inheritable, permitted, effective, bounding, and ambient. Their meaning is scoped by user namespaces.
- **seccomp** filters system calls. Mode 2 means filters are active; it does not reveal the policy from `/proc/status`, and seccomp documentation explicitly warns that filtering alone is not a sandbox.
- **NoNewPrivs** prevents `execve` from gaining privilege through mechanisms such as set-user-ID files and is commonly used before unprivileged seccomp filtering.
- **AppArmor or SELinux** uses the Linux Security Module framework to apply policy to objects and operations.
- **Filesystem modes, ACLs, read-only mounts, masked paths, and device rules** provide additional boundaries.
- **A virtual machine** normally moves the kernel boundary: guest processes call a guest kernel, while the hypervisor mediates hardware virtualization. Containers on one host call the same host kernel.

Defense in depth means these controls overlap. It does not mean one compensates perfectly for a missing other control.

## Evidence table

| Question | Command | Risk | Expected branches | Proves | Does not prove | Safest next evidence |
|---|---|---|---|---|---|---|
| Which views does this shell inhabit? | `readlink /proc/self/ns/*` on named types | read-only | links, missing type, or denied | visible namespace-link identities | security or resources | compare exact target process and owner view |
| Does target share host network view? | compare `ns/net` links | read-only | same, different, denied | membership equality for that type | routes or port correctness | inspect routes/listeners in both authorized views |
| What namespaces are enumerable? | `lsns` | read-only | rows or restricted inventory | accessible namespace/process mapping | complete host inventory | target `/proc/PID/ns` links |
| Is cgroup v2 visible? | `findmnt` plus `/proc/self/cgroup` | read-only | v2, v1/hybrid, hidden | mount type and reported membership | effective ancestor policy | exact workload cgroup path |
| What can parent delegate? | controller/type files | read-only | names, empty, denied | available/enabled child controllers | safe authorization to write | manager/runtime declared policy |
| Did memory hit a boundary? | memory gauge/max/events twice | sampled read-only | event delta or none | scoped usage, ceiling, event delta | leak or killed PID | runtime exit plus allocation evidence |
| Was CPU quota active? | `cpu.stat` twice | sampled read-only | throttling delta or none | cumulative usage and throttling | hot function or node use | workload profile, PSI, runnable demand |
| Was task creation refused? | pids files | read-only | at limit/event or not | controller state and event count | leak owner | thread/process tree and application errors |
| Is the workload stalled? | pressure files | sampled read-only | some/full values, zeros, absent | scoped stall percentages and total | source code cause | correlate resource counters and request latency |
| Which privilege filters apply? | selected `/proc/PID/status` fields | read-only | masks/modes or denied | kernel-reported process state | complete sandbox | runtime policy, audit denial, LSM context |
| What did Docker declare? | narrow `docker inspect` | read-only | finite, unset, terminal state | selected config/status | kernel causal chain | exact cgroup and timestamps |
| What did Kubernetes record? | narrow `kubectl get pod` | read-only | termination or no retained prior state | API status and desired resources | current kernel proof | runtime, cgroup, node and user-operation evidence |

Every command needs an identity label. `cat memory.events` from your login shell's cgroup does not diagnose a pod. `free -h` inside a container often reports a view of host memory rather than the effective cgroup ceiling. Scope before syntax.

## Command decoders

### Decoder 1: namespace links

```console
$ printf 'pid=%s uid=%s\n' "$$" "$(id -u)"
pid=7342 uid=1000
$ readlink /proc/self/ns/{mnt,pid,net,user,uts,ipc,cgroup}
mnt:[4026531841]
pid:[4026531836]
net:[4026532008]
user:[4026531837]
uts:[4026531838]
ipc:[4026531839]
cgroup:[4026531835]
```

`pid` is the shell's PID in its current PID namespace. `uid` is the effective numeric user identity in its user-namespace view. Each following label names a namespace type. The bracketed number identifies the kernel namespace object well enough for same-type comparison on this running system. It is not a container ID, security score, creation time, or stable cross-boot identifier.

`/proc/self` means the process reading the link. In the shell, separate `readlink` child processes evaluate `self` as themselves, but they inherit the shell's namespace memberships, so the identities are appropriate for this comparison. For an exact workload use `/proc/<host-pid>/ns/<type>` from an authorized host view.

### Decoder 2: `lsns`

```console
4026531836 pid       221     1 root     /sbin/init
4026532401 net         3 42817 100000   /usr/bin/api
```

- `NS`: namespace inode-like identifier.
- `TYPE`: namespace type.
- `NPROCS`: number of processes `lsns` associated with it in this sample and accessible view; it is a point-in-time count.
- `PID`: one representative process, not necessarily the creator or only member.
- `USER`: user associated with the representative PID as rendered through current identity databases and mappings.
- `COMMAND`: representative process command; it can contain sensitive arguments and is not a trusted identity.

The two rows do not say that all 221 processes share the second row's network namespace. Read columns within a row. Permissions and PID namespaces can hide processes.

### Decoder 3: cgroup membership and mount

```console
$ findmnt -no FSTYPE,OPTIONS,TARGET /sys/fs/cgroup
cgroup2 rw,nosuid,nodev,noexec,relatime /sys/fs/cgroup
$ cat /proc/self/cgroup
0::/user.slice/user-1000.slice/session-7.scope
```

`cgroup2` is the unified v2 filesystem. `rw` means this mount is not globally read-only, but individual files and delegation still control whether this identity can write. `nosuid`, `nodev`, and `noexec` are mount restrictions; `relatime` is timestamp behavior. The final field is the mount target.

The membership record is colon-separated:

- `0`: hierarchy identifier used for the unified hierarchy;
- empty middle field: v2 does not list per-controller memberships there;
- `/user.slice/...`: path visible from this process's cgroup namespace.

Inside a cgroup namespace the third field may be `/`. That does not mean host root membership.

### Decoder 4: controller availability

```console
$ cat cgroup.type
domain
$ cat cgroup.controllers
cpuset cpu io memory hugetlb pids rdma misc
$ cat cgroup.subtree_control
cpu memory pids
```

`domain` means this is an ordinary domain cgroup. `cgroup.controllers` lists controllers the current cgroup could make available to children under valid top-down and ownership rules. `cgroup.subtree_control` lists those currently enabled for immediate children. It does not say a finite `memory.max` exists; read the child policy and ancestors.

When writing through an authorized manager interface, syntax such as `+memory` enables and `-memory` disables for children. This lesson never writes it. The plus sign is an operation syntax, not how the read file is rendered.

### Decoder 5: memory files

```console
$ cat memory.current
524288000
$ cat memory.max
536870912
$ cat memory.events
low 0
high 184
max 27
oom 3
oom_kill 1
oom_group_kill 0
```

The first two values are bytes. Divide by 1,048,576 for mebibytes: 500 MiB current and 512 MiB maximum in this example. `memory.current` is a gauge sampled now. `memory.max` is configuration; the literal `max` would mean no finite limit at this level.

Every event number is cumulative, so take before/after readings:

- `low`: reclaim crossed a low protection boundary;
- `high`: processes were throttled and put under reclaim pressure above `memory.high`;
- `max`: allocations reached or crossed the hard maximum;
- `oom`: OOM conditions occurred in the cgroup;
- `oom_kill`: tasks were selected and killed;
- `oom_group_kill`: group kills occurred under group-OOM policy.

`memory.events` is hierarchical and can reflect descendants. `memory.events.local` reports events local to the cgroup. Fields may evolve with kernel version; decode the installed kernel documentation.

### Decoder 6: CPU quota and counters

```console
$ cat cpu.max
20000 100000
$ cat cpu.weight
100
$ cat cpu.stat
usage_usec 9420012
user_usec 7000000
system_usec 2420012
nr_periods 1600
nr_throttled 418
throttled_usec 11980000
```

`cpu.max` contains quota then period in microseconds. The workload can consume up to 20,000 microseconds of CPU time per 100,000-microsecond period: 20 percent of one CPU on average across enforcement periods. It is a ceiling, not a reservation. With multiple runnable threads, quota can be consumed in parallel and the cgroup can be throttled before wall-clock period end. `max 100000` would remove the finite quota at this level.

`cpu.weight=100` is relative sibling weight under contention, not 100 percent.

`cpu.stat` counters are cumulative:

- `usage_usec`: total CPU time charged, user plus system;
- `user_usec`: CPU time executing userspace code;
- `system_usec`: CPU time executing kernel work on behalf of tasks;
- `nr_periods`: quota enforcement periods elapsed while applicable;
- `nr_throttled`: periods in which runnable work was throttled;
- `throttled_usec`: cumulative throttled duration.

The first sample is history, not "CPU right now." Take two samples and divide counter deltas by elapsed wall time. Counter reset can indicate a new cgroup identity, reboot, or recreation; never treat a negative delta as real unthrottling.

### Decoder 7: PID controller

```console
$ cat pids.current pids.max pids.events
64
64
max 12
```

The unlabeled first line is current tasks in this cgroup scope, the second is the configured ceiling, and `max 12` is a cumulative count of rejected task-creation attempts. Keep command order in the evidence record or label each value; otherwise two bare `64` lines are ambiguous.

At this boundary `fork()` or `clone()` can fail with `EAGAIN`, often rendered "Resource temporarily unavailable." Raising `pids.max` without finding runaway thread creation can accelerate memory exhaustion. Compare task tree, thread counts, application pools, and ancestor constraints.

`pids.current` can be greater than `pids.max` if an authorized manager lowers the limit below current use or attaches tasks into the cgroup. Those organizational operations are not rejected by the controller. New `fork()` or `clone()` operations remain constrained, so interpret current, maximum, and event deltas together.

### Decoder 8: pressure stall information

```console
$ cat memory.pressure
some avg10=12.40 avg60=4.20 avg300=1.10 total=8842300
full avg10=3.10 avg60=0.80 avg300=0.20 total=1200100
```

`some` means at least some non-idle work was stalled for this resource. `full` means all non-idle work in the scoped group was simultaneously stalled, a stronger sign of lost forward progress. `avg10`, `avg60`, and `avg300` are recent percentages over approximately 10, 60, and 300 seconds. `total` is cumulative stalled microseconds.

The first read already includes prior windows. It is not an interval generated by your command. Compare aligned healthy and affected windows. Pressure says work waited; it does not name the allocation, lock, device, code function, or user impact.

### Decoder 9: privilege and seccomp status

```console
CapInh: 0000000000000000
CapPrm: 00000000a80425fb
CapEff: 00000000a80425fb
CapBnd: 00000000a80425fb
CapAmb: 0000000000000000
NoNewPrivs: 1
Seccomp: 2
Seccomp_filters: 1
```

Capability values are hexadecimal bit masks. Do not decode them from memory; use a version-matched tool such as `capsh --decode=<mask>` if already installed, because newer kernels add capabilities. `Inh`, `Prm`, `Eff`, `Bnd`, and `Amb` mean inheritable, permitted, effective, bounding, and ambient sets. A bit can be permitted but not currently effective.

`NoNewPrivs: 1` means an exec cannot grant new privilege through the normal file mechanisms. `Seccomp: 2` means filter mode, and `Seccomp_filters: 1` reports one attached filter. These fields do not show which system calls are denied. Runtime configuration, audit logs, and a minimal reproduction are safer evidence than disabling the profile.

### Decoder 10: Kubernetes status

```text
pod UID:        2d4f...f91
node:           worker-2
container:      api
restartCount:   4
last reason:    OOMKilled
last exitCode:  137
resources:      requests memory=256Mi; limits memory=512Mi
```

A request influences scheduling and QoS policy. A memory limit becomes a runtime/kernel ceiling. `restartCount=4` belongs to this pod/container status and can reset when a replacement pod receives a new UID. `lastState` is one prior state, not an unlimited incident archive. `OOMKilled` plus 137 is strong runtime/orchestrator evidence; join it to the exact cgroup event delta and time because stale counters and replacement identities can mislead.

## Decision path

Use this path instead of dumping every container command you know:

```text
user operation fails
        |
        v
freeze identity: workload UID, container ID, host PID, start time, node
        |
        v
visibility contradiction? ---- yes ---> compare specific namespace type
        |                                  inspect state in both owner views
        no
        v
resource symptom? ---------- yes ---> resolve exact cgroup + ancestors
        |                              sample gauge/config/counter deltas
        no
        v
permission/syscall symptom? - yes ---> UID map, capabilities, seccomp, LSM, files
        |
        v
join runtime + kernel + orchestrator + real operation timeline
        |
        v
smallest reversible recovery -> verify operation -> reconcile -> prevent
```

For an exit or restart incident:

1. Define impact, affected cohort, known-good cohort, and recovery objective.
2. Preserve previous-container logs and runtime state before replacement erases them.
3. Translate exit code to outcome only: 137 suggests SIGKILL; 143 suggests SIGTERM. Neither names the sender or reason.
4. Resolve exact process and cgroup identity. Check for recreation between samples.
5. Read configuration and counters twice over the relevant interval.
6. Separate local cgroup enforcement, ancestor enforcement, and node pressure.
7. Correlate Kubernetes or runtime reason and timestamps.
8. Inspect workload behavior: allocation, concurrency, queues, thread growth, cache, and recent changes.
9. Restore with the smallest approved action. Do not edit runtime-owned kernel files directly.
10. Verify the real operation, lost or duplicated work, stable counters, healthy cohorts, and rollback state.

For a connectivity contradiction, choose the namespace that owns each endpoint. `ss` inside the app namespace and `ss` on the host answer different questions. A refused connection usually means no listener at the destination after routing; a timeout can mean drop, path failure, backlog, or delayed response. Preserve the exact source and destination namespace.

When evidence is denied, say "unobserved from this identity," not "absent." Move to an authorized support boundary. Weakening seccomp, adding capabilities, joining host namespaces, or using privileged containers for convenience changes the system you are diagnosing and expands blast radius.

## Guided Ubuntu lab

The lab lives at `book/labs/LES-0011-namespaces-cgroups-isolation`. It teaches the evidence shape without risking a real OOM, fork storm, cgroup write, namespace creation, Docker image pull, or Kubernetes change.

### Safety card

| Item | Boundary |
|---|---|
| Platform | Ubuntu 24.04 or WSL 2 Ubuntu 24.04 |
| User | normal user; root is refused |
| Time | 30-45 minutes; verifier normally finishes in seconds |
| CPU/RAM | foreground Bash and Python only; no pressure generator |
| Disk | less than 256 KiB in one exact `/tmp` root and descriptor |
| Network/ports | none |
| Packages | Bash, Python 3.8+, and base tools; no automatic install |
| Mutation | allowlisted small files only; no process, namespace, cgroup, mount, socket, container, or pod mutation |
| Stop | any identity, ownership, symlink, mode, path, sentinel, descriptor, or allowlist refusal |

Start from the lab directory:

```bash
bash lab.sh check
bash lab.sh host-observe
bash lab.sh setup
bash lab.sh status
bash lab.sh baseline
bash lab.sh inject guided
bash lab.sh observe identity
bash lab.sh observe resources
bash lab.sh observe events
bash lab.sh observe operation
```

`host-observe` reads only your current process's namespace links, cgroup membership, and cgroup filesystem type. It can report `unavailable`; that is a valid environment boundary. It does not enumerate other users, inspect Docker, or modify anything.

The virtual guided baseline is:

```text
record=baseline
case=baseline
operation_success=true
namespace_view=workload-a
memory_current_bytes=268435456
memory_max_bytes=536870912
memory_oom_kill=0
cpu_nr_throttled=2
pids_current=18
pids_max=128
```

After injection, record a prediction before each observation. The guided views show a replacement process that keeps the same workload label but has a new instance ID, a finite memory limit, and an OOM-kill counter delta. Explain what each fact proves and why it still does not prove a leak.

Recover and verify the modeled operation separately:

```bash
bash lab.sh recover
bash lab.sh verify
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

A healthy verification says only the deterministic fixture returned to its known-good contract. It is not proof that Ubuntu, Docker, or Kubernetes behaved that way and it is not learner mastery.

The independent case requires fresh state:

```bash
bash lab.sh reset
bash lab.sh baseline
bash lab.sh inject transfer
```

Stop reading fixture source and do not seek a model answer. Use the same four observations, identify the first abnormal boundary, reject at least two alternatives, recover, verify, and clean up. `ASM-0018` defines the answer-isolated submission.

Run the mentor or contributor verifier only from a clean learner state:

```bash
bash verify.sh
```

The verifier exercises both lifecycles plus repeated setup, invalid input, unexpected artifact, symlink, descriptor redirection, orphan-candidate, and idempotent cleanup refusal boundaries. Its pass proves the harness contract on that environment, not independent understanding.

## Production transfer

### Docker

Docker configures namespaces and cgroups through a runtime. `docker stats` is a convenient display, but each field has scope and calculation choices. `CPU %` is a sampled utilization calculation, `MEM USAGE / LIMIT` combines a usage view and declared/effective boundary, `NET I/O` and `BLOCK I/O` are cumulative counters, and `PIDS` is a point-in-time task count. Capture container ID, timestamps, engine/runtime version, and raw effective cgroup evidence for a serious incident.

Root inside the container may be host root, mapped root in a user namespace, or constrained root with dropped capabilities. Do not infer it from the prompt. A `--privileged` container changes many boundaries at once and is not a diagnostic shortcut.

### Kubernetes

Kubernetes requests and limits have different jobs:

- the scheduler uses requests to place pods;
- kubelet and runtime translate limits to kernel controls;
- CPU limit normally causes throttling rather than process termination;
- memory limit enforcement is reactive and may produce OOM termination;
- pod QoS class (`Guaranteed`, `Burstable`, or `BestEffort`) influences eviction behavior under node pressure;
- node-pressure eviction and container-level OOM kill are different mechanisms.

Join this chain:

```text
Deployment revision -> Pod UID -> node -> container ID -> host PID
 -> namespace links -> cgroup path -> controller deltas -> kernel/runtime event
 -> pod lastState/events -> readiness -> Service endpoint -> user request
```

A CrashLoopBackOff is Kubernetes backoff around repeated container failure; it is not the process's root cause. `kubectl describe` events can expire and are not a durable audit log. Preserve bounded evidence through approved telemetry.

### systemd and private cloud

systemd organizes services into cgroups even without containers. `systemctl show <unit> -p ControlGroup` can identify its manager path; use systemd properties or unit configuration to change policy, not raw files. In a virtual machine, first decide whether the failing limit belongs to the guest service cgroup, guest kernel, VM allocation, hypervisor, or physical host. Host contention and guest-local cgroup throttling can coexist.

### CI/CD runners and data platforms

A CI job or data worker can see high host capacity while its executor cgroup is constrained. Record job/run ID, container ID, cgroup path, input size, concurrency, and exact limit. A retry after OOM can duplicate non-idempotent work. Recovery must reconcile outputs, not merely turn the job green.

## Reliability, security, observability, capacity, and cost

### Reliability

Set resource policy from measured workload behavior, service objectives, and failure modes. A memory limit needs headroom for working set, allocator behavior, bursts, page cache, and memory-backed storage. CPU limits can protect neighbors but create periodic throttling and tail latency. PID limits contain fork bombs but can block health checks or logging if set below legitimate concurrency. Test graceful shutdown, restart, and reconciliation.

### Security

Namespaces reduce visibility; cgroups constrain resources. Neither alone prevents kernel exploitation or unauthorized object access. Use non-root identity, user namespaces where appropriate, minimal capabilities, `no-new-privileges`, reviewed seccomp, AppArmor or SELinux, read-only filesystems, controlled devices, network policy, patched kernels, and least-privilege runtime sockets. Access to a container-runtime socket can be equivalent to broad host control.

Never "fix" an unexplained denial by adding `CAP_SYS_ADMIN`, privileged mode, host PID/network namespace, broad bind mounts, or an unconfined seccomp/LSM profile. First identify the denied operation and design the narrowest control.

### Observability

Export gauges, configurations, cumulative event counters, and operation signals with stable identity. For counters use deltas or rates and handle resets. Useful signals include memory working set and events, CPU usage/throttling, PSI, task count/events, restarts by reason, pod UID, container ID, node, revision, and user-journey latency/error/correctness. Dashboards must label bytes versus mebibytes, cores versus percentages, point-in-time values versus rates, and local versus hierarchical scope.

### Capacity

Resource limits do not create capacity. A 2-CPU limit on a saturated 1-CPU node cannot deliver two CPUs. Requests can over- or under-represent real demand. Model simultaneous restart, cache warmup, batch overlap, noisy neighbors, and dependency capacity. Sum of limits can exceed the node; sum of requests drives placement but does not bound every burst.

### Cost

Oversized requests strand schedulable capacity and increase node count. Oversized limits can move failure to the node. Tight limits can cause throttling, retries, restarts, missed SLOs, and duplicated work. Optimize after correctness: measure representative load, price unused reservation and failure amplification, then canary a reversible policy change.

## Traps and prevention

| Trap | Why it fails | Better rule |
|---|---|---|
| "The container is a lightweight VM" | hides shared kernel and separate mechanisms | say process + namespaces + cgroups + security controls |
| "PID 1 means host init" | PID is namespace-relative | compare PID namespace and host/runtime PID |
| "Root is root" | UID and capabilities are user-namespace scoped | inspect maps, capability sets, policy, and object ownership |
| "Host free memory proves no OOM" | cgroup maximum may be smaller | read exact cgroup limit/events and runtime outcome |
| "137 proves OOM" | it proves SIGKILL-style exit only | join OOM event delta and runtime/kernel evidence |
| "CPU below 100%, so no CPU problem" | quota throttling can occur with idle host cores | read `cpu.max`, counter deltas, PSI, runnable work, latency |
| "Raise the limit" | can move failure to parent/node and hide leak | explain demand, headroom, ancestor capacity, rollback, canary |
| "No row means no namespace" | visibility and permission can hide evidence | label unobserved scope and move to authorized boundary |
| "Same namespace ID means same container" | containers can share individual namespace types | compare every relevant type plus runtime identity |
| "Different mount namespace means copied data" | mount table and underlying storage are different concepts | trace mount source, propagation, and filesystem owner |
| "seccomp is the sandbox" | syscall filtering is one layer | combine identity, capabilities, LSM, filesystem, network, cgroup, kernel patching |
| edit cgroup files under systemd/Kubernetes | violates manager ownership and can be overwritten | change declared policy through the owning control plane |
| use privileged mode to debug | changes the boundary and expands attack surface | use narrow read-only owner-side tooling and preserve audit |
| trust friendly names | names survive recreation while PIDs/UIDs/counters change | join immutable IDs and start times |

Prevention has three layers: safe defaults, measurable runtime guardrails, and tested failure recovery. Define requests/limits from evidence, alert on event deltas and operation impact, preserve previous-instance telemetry, canary policy changes, and rehearse reconciliation after forced termination.

## Memory card and retrieval

Remember **VIEW - BUDGET - PERMISSION - OUTCOME**:

```text
VIEW        namespace: what state can this process see?
BUDGET      cgroup: what is counted, shared, throttled, protected, or capped?
PERMISSION  identity/capabilities/seccomp/LSM/filesystem: what may it do?
OUTCOME     runtime/orchestrator/user operation: what actually happened?
```

Five retrieval questions:

1. Why can PID 1 inside a container be PID 42817 on the host?
2. Why can host memory be free while `memory.events` records an OOM kill?
3. What is the difference between `cpu.weight` and `cpu.max`?
4. Why is `Seccomp: 2` not proof of a secure sandbox or the denied syscall?
5. Which identities must you join before attributing an old cgroup counter to a pod restart?

One-line rules:

- namespace identity scopes the view;
- cgroup identity scopes resource evidence;
- cumulative counters need a delta and reset awareness;
- requests place; limits govern runtime behavior;
- 137 says SIGKILL outcome, not mechanism;
- recovery is the user operation, not a greener status;
- a verified fixture is not demonstrated mastery.

Close the page and redraw the architecture map. If you label the whole box "Docker magic," reopen this chapter and name each kernel owner.

## Complete answers

Attempt the retrieval questions before reading these answers.

### 1. Why can one process have two PID numbers?

**Direct answer:** PID numbers are relative to PID namespaces. A process can be PID 1 in its container's namespace and PID 42817 in an ancestor host namespace.

**Foundation:** A PID is a name in a visibility domain, not the process's universal identity. Nested PID namespaces let ancestors see descendant processes under ancestor PID numbers while descendants cannot necessarily see ancestor processes. Runtime ID, host PID, namespace links, and process start time form a safer join.

**Senior answer:** Preserve both identities at one time. PIDs can be reused, and container restart replaces the process. Join runtime event timestamp and container ID to host PID/start time, then record namespace identifiers. Do not use `kill` or `nsenter` against a stale PID; revalidate identity immediately before any authorized operation.

### 2. Why can a cgroup OOM occur with node memory free?

**Direct answer:** `memory.max` is a local hierarchical ceiling. The kernel can fail allocation and invoke cgroup OOM handling at 512 MiB even if the node has unused memory outside that cgroup.

**Foundation:** Resource ownership is hierarchical. `free` answers a host or namespace-exposed availability question; it does not necessarily display the workload cgroup limit. `memory.current`, `memory.max`, and `memory.events` at the exact cgroup answer the local boundary question.

**Senior answer:** Require an incident-window `oom_kill` delta joined to exact runtime identity and termination timing. Inspect `memory.events.local`, ancestor limits, node pressure, `memory.peak` where available, allocation telemetry, page cache, tmpfs, concurrency, and request mix. Restore safely, then distinguish leak, legitimate demand, policy regression, and amplification.

### 3. What is weight versus quota?

**Direct answer:** `cpu.weight` decides relative share among contending siblings. `cpu.max` places an absolute bandwidth ceiling over periods.

**Foundation:** Weight is meaningful mainly when siblings compete. A higher weight does not reserve CPU. Quota can throttle a workload even while other host CPUs are idle because policy caps that cgroup.

**Senior answer:** Measure `usage_usec`, `nr_throttled`, `throttled_usec`, PSI, runnable demand, and request latency over aligned intervals. Before removing a quota, check neighbor protection and node headroom. Prefer workload efficiency, concurrency control, appropriate requests, and canaried policy over a blind unlimited setting.

### 4. Why do namespaces and cgroups not equal security isolation?

**Direct answer:** Namespaces change views and cgroups manage resources; they do not express every privilege, syscall, object-access, filesystem, network, or kernel attack boundary.

**Foundation:** A secure container combines identity, user namespaces, capabilities, seccomp, LSM policy, filesystem/mount controls, devices, network controls, cgroups, runtime ownership, and kernel maintenance. All containers on one host still share the host kernel.

**Senior answer:** Threat-model the workload and host. Minimize runtime-socket access, privileges, capabilities, host namespace sharing, writable mounts, and kernel attack surface. Use stronger VM or sandboxed-runtime isolation where tenant threat requires it. Verify negative authorization tests; configuration presence is not enforcement evidence.

### 5. Why is OOMKilled not the end of diagnosis?

**Direct answer:** It classifies a termination mechanism boundary but not why memory demand exceeded policy or whether the policy itself was wrong.

**Foundation:** Leaks, concurrency, cache, input, allocator, tmpfs, sidecars, changed limits, and ancestor pressure can produce similar outcomes. A restart may clear usage without preventing recurrence.

**Senior answer:** Separate trigger, memory-growth mechanism, configured/effective limit, enforcement, restart amplification, user/data impact, and detection. Reconcile accepted work, profile representative demand, test recovery, and encode a regression guard. Do not call limit increase the root-cause fix unless evidence supports a legitimate capacity mismatch and node safety.

### 6. How should you interpret a missing cgroup file?

**Direct answer:** As unavailable evidence in this version or view, not as proof that the controller or limit does not exist.

**Foundation:** cgroup v1, hybrid mode, namespace roots, disabled controllers, delegation, kernel configuration, and permissions change visible files. First confirm filesystem type and membership.

**Senior answer:** Record version, mount, cgroup namespace, canonical owner path, and access identity. Move to the systemd/runtime/node boundary authorized to observe effective policy. Avoid installing tools or remounting cgroups during an incident merely to match a tutorial.

### 7. Why do counters need two readings?

**Direct answer:** Event and time counters are cumulative. One absolute number cannot tell whether the event happened during the current incident.

**Foundation:** Record `t0`, values, `t1`, values, and identity. Delta equals second minus first only if the same counter object survived. A recreated cgroup can reset it.

**Senior answer:** Use telemetry that exports stable cgroup/container identity and counter-reset metadata. Align counter deltas with operation rates and latency. Preserve previous-container/node evidence because Kubernetes status and ephemeral cgroups do not form an unlimited history.

### 8. What is a complete recovery statement?

**Direct answer:** The intended user operation is correct and durable for the declared scope/window; resource counters and pressure stabilize; no healthy cohort regresses; accepted work is reconciled; rollback remains available.

**Foundation:** A new container `Running` or a zeroed counter proves only an intermediate state. The request path must be tested from the real consumer boundary.

**Senior answer:** Report restoration and causal confidence separately. For example: "Checkout recovered for the canary and zone for 15 minutes; no duplicate durable effects; memory remains below the canary envelope and no new max/OOM events occurred. Rollback remains paused. The initiating growth mechanism is still under investigation."

The full diagnostic and interview answers are in `ASM-0016` and `ASM-0017`. They expand the same reasoning with scored evidence boundaries.

## Product-company interview

**Scenario:** A Java API on Kubernetes restarted three times after a release. The pod reports `OOMKilled` and exit 137. The node dashboard stayed below 55 percent memory. The application team asks to double every pod limit immediately because checkout is failing.

Start with this sentence:

> We have confirmed repeated termination and customer impact, but not yet whether demand, policy, or an ancestor boundary changed. Node utilization does not rule out a container cgroup OOM. I will protect capacity, preserve the old-instance evidence, resolve exact identities, and test the smallest reversible recovery.

Then structure the answer:

1. Clarify affected percentage, checkout correctness, accepted-but-unfinished work, rollout cohort, start time, recovery objective, current capacity, and authority.
2. Pause rollout and preserve surviving old capacity. Avoid a restart storm.
3. Capture pod UID, container ID, node, start/finish time, image/config revision, requests/limits, QoS class, last termination, and events.
4. Resolve the old container cgroup if telemetry retains it. Compare `memory.current/peak/max`, `memory.events` deltas, `memory.stat`, pressure, and ancestor/node signals.
5. Compare new versus old revision under matched traffic. Inspect heap, non-heap/native allocations, thread count, caches, request shape, concurrency, and tmpfs usage.
6. Rank hypotheses: release memory regression; concurrency/input growth; lowered effective limit; ancestor/node pressure; stale/mismatched evidence.
7. Select recovery. If old revision is healthy, use a small rollback canary. If measured legitimate demand exceeds an incorrectly reduced limit and node headroom is proven, use a bounded policy canary. Abort on correctness loss, OOM/event growth, node pressure, healthy-cohort regression, or missing telemetry.
8. Verify checkout exactly once, backlog reconciliation, readiness, stable memory/event trajectory, restart cessation, node safety, and rollback.
9. Prevent recurrence with representative memory tests, allocation profiles, rollout gates on user success plus OOM deltas, concurrency/retry budgets, safe defaults, and retained instance identity.

**Weak answer:** "Exit 137 always means memory leak. Double the limit and restart all pods."

Why it is weak: 137 is not unique to OOM, OOMKilled does not identify the demand mechanism, node utilization is the wrong local boundary, doubling all pods changes capacity and cost fleet-wide, restart destroys evidence and may amplify load, and no user-operation or data reconciliation proves recovery.

**Follow-up: what if `oom_kill` did not increase?** Recheck identity and sampling window. The cgroup may have been removed, the counter may be from a replacement, an ancestor or global OOM may own the event, or SIGKILL may have another source. Use runtime timestamps, retained telemetry, node kernel evidence, and audit/operation records. Do not force the preferred story.

**Follow-up: would you remove the memory limit?** Not as an unbounded reaction. That can expose the node and other tenants. A bounded canary with node headroom, workload reconciliation, abort signals, and rollback may be justified while diagnosing, but the desired steady policy needs measured demand and failure containment.

**Follow-up: why can CPU throttling hurt at 20 percent node CPU?** The workload's `cpu.max` may cap it independently of node idle capacity. Bursty threads can consume quota early in a period and wait, increasing tail latency. Prove with counter deltas, PSI, runnable demand, and request timing.

`ASM-0017` contains the complete scored response, evidence table, weak-answer analysis, and additional follow-ups.

## Independent transfer and rubric

`ASM-0018` is deliberately answer-isolated. It uses the lab's `transfer` case from clean state. This lesson does not reveal that case's diagnosis, expected values, or correct remediation.

Submit:

1. sanitized environment and safety card;
2. exact lab state and virtual workload-instance identity;
3. diagram separating namespace view, cgroup policy, adjacent controls, runtime status, and modeled user operation;
4. baseline and current evidence table with field types, units, scope, proof, and proof limits;
5. two-sample reasoning for every cumulative event used;
6. at least three mechanism hypotheses and evidence rejecting at least two;
7. recovery through the supported interface and separate operation verification;
8. cleanup proof plus a following absent-state check;
9. production transfer to one Docker, Kubernetes, systemd, CI runner, or private-cloud case without claiming the fixture proves that platform;
10. disclosure of all hints or help.

Use the blank structure at `book/assessments/linux/ASM-0018-response-template.md` if it helps. It contains no diagnosis, expected values, hidden hint, score, or solution.

The 20-point rubric scores boundary/safety, mechanism model, evidence interpretation, independent diagnosis/recovery, and production transfer. A website completion mark, copied answer, fixture pass, or mentor-operated output earns no mastery. Independent learner evidence requires human or authorized review, and delayed recall remains separate.

If you inspect the fixture source or receive the answer before submission, disclose it and treat the run as guided practice. Reset later with a changed case for genuine transfer.

## References and review

| ID | Primary or official source | Why it is here |
|---|---|---|
| REF-0041 | [Linux `namespaces(7)`](https://man7.org/linux/man-pages/man7/namespaces.7.html) | namespace API, types, procfs handles, and lifetime |
| REF-0042 | [Linux `pid_namespaces(7)`](https://man7.org/linux/man-pages/man7/pid_namespaces.7.html) | PID nesting, namespace init, visibility, and signals |
| REF-0043 | [Linux kernel: Control Group v2](https://docs.kernel.org/admin-guide/cgroup-v2.html) | hierarchy, delegation, controllers, events, PSI, and semantics |
| REF-0044 | [Linux `capabilities(7)`](https://man7.org/linux/man-pages/man7/capabilities.7.html) | capability sets and user-namespace relationships |
| REF-0045 | [Linux kernel: Seccomp BPF](https://docs.kernel.org/userspace-api/seccomp_filter.html) | syscall-filter mechanism, prerequisites, and explicit sandbox limitation |
| REF-0046 | [OCI Runtime Specification: Linux configuration](https://github.com/opencontainers/runtime-spec/blob/main/config-linux.md) | runtime namespace, cgroup, device, and Linux configuration contract |
| REF-0047 | [Docker: Resource constraints](https://docs.docker.com/engine/containers/resource_constraints/) | Docker memory and CPU configuration semantics and OOM cautions |
| REF-0048 | [Kubernetes: Resource management for Pods and containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | requests, limits, CPU throttling, memory enforcement, and diagnostic transfer |

Use local installed documentation where available:

```bash
uname -r
man 7 namespaces
man 7 pid_namespaces
man 7 user_namespaces
man 7 cgroups
```

Upstream current documentation can describe fields absent from Ubuntu's installed kernel or runtime. Record the version and read the matching local interface before applying a claim.

Review by 2027-02-02, or earlier after a material Ubuntu kernel, systemd cgroup, OCI runtime, Docker, Kubernetes resource-management, structured-content, or lab-safety change. The lesson remains `substantive-draft` until subject, safety, instructional, Ubuntu/WSL, container-runtime, Kubernetes-transfer, accessibility, and independent-assessment reviews are accepted. Publication never awards mastery.
