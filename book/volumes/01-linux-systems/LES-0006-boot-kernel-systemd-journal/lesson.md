---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0006",
  "aliases": ["V01-L06", "boot-kernel-systemd-journal"],
  "curriculumIds": ["LNX-005"],
  "slug": "boot-kernel-systemd-journal",
  "route": "/book/linux/boot-kernel-systemd-journal",
  "order": 6,
  "volume": "01-linux-systems",
  "title": "Boot, kernel handoff, systemd, and the journal",
  "summary": "Trace one boot from firmware toward a service-readiness boundary, read systemd state without confusing active with ready, and use boot-scoped journal evidence before changing anything.",
  "domain": "linux",
  "level": {
    "from": "foundation",
    "to": "advanced"
  },
  "estimatedMinutes": 180,
  "prerequisiteLessonIds": ["LES-0002"],
  "prerequisiteCurriculumIds": ["LNX-002"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS with systemd as PID 1",
      "support": "required",
      "notes": "The guided lab is read-only and uses commands shipped by systemd, procps, and the base operating system."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 with systemd enabled",
      "support": "supported",
      "notes": "Firmware, boot loader, initramfs, and some kernel ownership belong to the Windows and WSL platform, so those stages are concept-only from inside the distribution."
    },
    {
      "platform": "Docker container",
      "version": "Any local image",
      "support": "concept-only",
      "notes": "A normal application container does not boot its own kernel and usually does not run systemd as PID 1. Use it to learn namespace boundaries, not host boot behavior."
    },
    {
      "platform": "Disposable Ubuntu virtual machine",
      "version": "24.04 LTS",
      "support": "concept-only",
      "notes": "Required for any future exercise that changes bootloader entries, initramfs, kernel parameters, system units, mounts, or recovery targets; that mutation harness is planned but not runtime-verified in this lesson."
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
    "Draw the ownership handoff from firmware or hypervisor through the boot loader, kernel, initramfs, root filesystem, PID 1, and service dependencies, then identify the separate user-visible readiness check required to close the path.",
    "Explain the difference between kernel space, userspace, PID 1, a systemd unit, a systemd job, a target, and a running process.",
    "Separate unit load state, active state, substate, result, exit status, restart count, listener state, readiness, and end-to-end health.",
    "Use boot ID and monotonic timestamps to correlate kernel, systemd, service, and readiness evidence without being misled by wall-clock correction.",
    "Interpret systemd-analyze time and critical-chain without treating either output as automatic root cause.",
    "Choose bounded journal filters by boot, unit, kernel source, priority, and time window instead of dumping unbounded logs.",
    "Recognize when a container or WSL shell cannot observe or own a host boot stage.",
    "Plan a rollback-aware boot investigation that preserves evidence and confines mutation to a disposable VM or reviewed fleet mechanism."
  ],
  "productionSignals": [
    "A VM is reachable much later than its normal boot-to-ready baseline.",
    "systemctl reports a service active while the load balancer or synthetic request reports unhealthy.",
    "A service waits for network-online.target, a mount, device, secret, or dependency until a timeout expires.",
    "A machine boots the wrong kernel or only succeeds through a previous boot entry.",
    "The current boot looks clean but the failure occurred during the previous boot.",
    "Clock skew or clock correction makes journal wall-clock timestamps appear out of order.",
    "A service repeatedly activates and exits while a restart policy hides each short failure."
  ],
  "diagrams": [
    {
      "id": "LES-0006-DIA-001",
      "title": "Boot ownership handoff",
      "direction": "left-to-right",
      "boundaries": ["firmware or hypervisor", "boot loader", "kernel and initramfs", "real root filesystem", "systemd PID 1", "service and dependencies", "consumer readiness"],
      "evidencePoints": ["firmware or console events", "selected boot entry", "kernel command line and messages", "boot ID", "systemd job timing", "unit state and journal", "real request result"],
      "textAlternative": "Control passes from platform firmware to a selected boot entry, then to the kernel and temporary early userspace, the real root filesystem, systemd as PID 1, dependent services, and finally the consumer-facing readiness boundary."
    },
    {
      "id": "LES-0006-DIA-002",
      "title": "Active is not the same as ready",
      "direction": "left-to-right",
      "boundaries": ["unit file loaded", "systemd activation job", "main process", "listening socket", "application readiness", "load balancer admission", "user request"],
      "evidencePoints": ["LoadState", "ActiveState and SubState", "ExecMainStatus", "ss listener", "readiness response", "health-check state", "synthetic transaction"],
      "textAlternative": "A unit can load and activate before its process listens, dependencies work, the readiness check passes, the load balancer admits it, and a real user request succeeds."
    },
    {
      "id": "LES-0006-DIA-003",
      "title": "Boot-scoped evidence join",
      "direction": "hierarchical",
      "boundaries": ["boot identity", "kernel events", "systemd jobs", "unit events", "application signals", "consumer signals"],
      "evidencePoints": ["_BOOT_ID", "short-monotonic timestamp", "kernel release", "unit name and invocation", "request ID", "readiness timestamp"],
      "textAlternative": "The boot ID anchors evidence from the kernel and systemd journal; monotonic time orders events within that boot, while unit, invocation, and request identifiers narrow each downstream layer."
    }
  ],
  "commands": [
    {
      "id": "LES-0006-CMD-001",
      "question": "Which kernel, boot, and PID 1 does this shell actually observe?",
      "risk": "read-only",
      "command": "printf 'pid1='; ps -p 1 -o comm=; printf 'kernel='; uname -r; printf 'boot_id='; cat /proc/sys/kernel/random/boot_id",
      "runFrom": "Ubuntu 24.04 as the normal user",
      "expectedBranches": [
        {
          "when": "PID 1 is systemd and a boot ID is printed",
          "meaning": "This environment exposes a systemd-managed boot and a kernel-generated identity for the current boot.",
          "nextEvidence": "Record the values, then measure this boot with systemd-analyze and scoped journal queries."
        },
        {
          "when": "PID 1 is not systemd",
          "meaning": "The shell may be inside a container, a non-systemd distribution, or a constrained environment.",
          "nextEvidence": "Identify the virtualization or namespace boundary before using systemd commands or making host claims."
        }
      ],
      "proves": "The command name at PID 1, the running kernel release string, and the boot ID visible in this process namespace.",
      "doesNotProve": "Which firmware or boot loader ran, whether the selected kernel is intended, or whether any application is ready."
    },
    {
      "id": "LES-0006-CMD-002",
      "question": "What command line did the running kernel receive?",
      "risk": "read-only",
      "command": "cat /proc/cmdline",
      "runFrom": "The affected Ubuntu boot in a local terminal; inspect before recording because kernel parameters can contain sensitive identifiers or misplaced credentials",
      "expectedBranches": [
        {
          "when": "A single line of parameters is printed",
          "meaning": "These are the arguments exposed by the running kernel for this boot.",
          "nextEvidence": "Inspect locally first. If the line contains a credential or sensitive identifier, do not copy it; stop evidence capture and follow the applicable secret-response process. Otherwise compare only relevant parameters with the intended boot entry and a healthy machine; do not edit them on a production host."
        }
      ],
      "proves": "The current kernel's exposed command-line string.",
      "doesNotProve": "Why each parameter was selected, whether the boot loader configuration on disk matches it, or whether a parameter caused the incident."
    },
    {
      "id": "LES-0006-CMD-003",
      "question": "How did systemd divide the measured boot into firmware, loader, kernel, initrd, and userspace phases?",
      "risk": "read-only",
      "command": "systemd-analyze time",
      "runFrom": "Ubuntu 24.04 where PID 1 is systemd",
      "expectedBranches": [
        {
          "when": "Phase durations and a target completion time are printed",
          "meaning": "systemd has timing data for the phases available on this platform.",
          "nextEvidence": "Use critical-chain and user-visible readiness timing to locate the first meaningful delay."
        },
        {
          "when": "The command reports that the system has not been booted with systemd or lacks timing data",
          "meaning": "This environment cannot support that systemd boot claim.",
          "nextEvidence": "Return to PID 1 and virtualization-boundary evidence."
        }
      ],
      "proves": "systemd's measured phase durations for the current boot where those phases are observable.",
      "doesNotProve": "A root cause, the slowest causal unit, or the moment a real user request succeeded."
    },
    {
      "id": "LES-0006-CMD-004",
      "question": "Which time-critical dependency path led to the default target?",
      "risk": "read-only",
      "command": "systemd-analyze critical-chain --no-pager",
      "runFrom": "Ubuntu 24.04 where PID 1 is systemd",
      "expectedBranches": [
        {
          "when": "A tree with activation timestamps and +durations is printed",
          "meaning": "The output shows one time-critical ordering chain derived from recorded unit activation data.",
          "nextEvidence": "Inspect the dependencies, unit properties, and journal around the first abnormal gap."
        }
      ],
      "proves": "The displayed units and timing relationships on the calculated critical chain for this boot.",
      "doesNotProve": "That the unit with the longest duration consumed CPU, that parallel units are irrelevant, or that disabling any unit is safe. Timed-out jobs and device units that never entered activating may be absent from the graph."
    },
    {
      "id": "LES-0006-CMD-005",
      "question": "Which systemd units are currently in the failed state?",
      "risk": "read-only",
      "command": "systemctl --failed --no-pager",
      "runFrom": "Ubuntu 24.04 where PID 1 is systemd",
      "expectedBranches": [
        {
          "when": "Zero failed units are listed",
          "meaning": "No loaded unit is currently classified failed by this manager.",
          "nextEvidence": "Continue with the specific service, dependency, listener, readiness, and previous-boot evidence; zero failed units is not end-to-end health."
        },
        {
          "when": "One or more units are listed",
          "meaning": "systemd retains a failed state for those units.",
          "nextEvidence": "Inspect structured properties and the boot-scoped journal before resetting state or restarting anything."
        }
      ],
      "proves": "The units systemd currently exposes in failed state.",
      "doesNotProve": "That unlisted services are ready or that a listed failure caused the user-visible symptom."
    },
    {
      "id": "LES-0006-CMD-006",
      "question": "What exact lifecycle state and last result does systemd hold for one unit?",
      "risk": "read-only",
      "command": "systemctl show <unit> --no-pager -p LoadState -p ActiveState -p SubState -p Result -p ExecMainCode -p ExecMainStatus -p NRestarts",
      "runFrom": "Ubuntu 24.04 after replacing <unit> with a reviewed unit name",
      "expectedBranches": [
        {
          "when": "LoadState=loaded and ActiveState=active",
          "meaning": "The unit definition loaded and the manager currently classifies it active; SubState and readiness evidence still matter.",
          "nextEvidence": "Inspect SubState, main process, listener, logs, and a real readiness operation."
        },
        {
          "when": "LoadState=not-found, ActiveState=failed, Result is non-success, or NRestarts grows",
          "meaning": "The manager exposes a configuration, lifecycle, result, or restart-loop branch.",
          "nextEvidence": "Use systemctl cat, dependency inspection, and the unit's current-boot journal without mutating state."
        }
      ],
      "proves": "The selected unit properties returned by the current systemd manager.",
      "doesNotProve": "Application readiness, service ownership of the expected socket, dependency health, or the complete causal history."
    },
    {
      "id": "LES-0006-CMD-007",
      "question": "What did this unit and its manager report during the current boot?",
      "risk": "read-only",
      "command": "journalctl -b -u <unit> -o short-monotonic -n 100 --no-pager",
      "runFrom": "The affected Ubuntu boot after replacing <unit>; normal user if authorized, otherwise through the reviewed read-only support path",
      "expectedBranches": [
        {
          "when": "Entries appear with monotonic timestamps",
          "meaning": "The journal returned up to 100 accessible events associated with that unit in the stated current-boot window.",
          "nextEvidence": "Locate the first error or abnormal delay, then inspect the owning dependency or operation."
        },
        {
          "when": "No entries appear or access is denied",
          "meaning": "The query found no accessible match; this is not proof that no event occurred.",
          "nextEvidence": "Verify unit name, boot, time window, journal persistence, and authorized read access without broadening permissions casually."
        }
      ],
      "proves": "The newest 100 accessible matching journal entries for the stated boot, unit, and output mode.",
      "doesNotProve": "That the application logged every failure, that omitted entries do not exist, or that temporal order alone establishes causation."
    },
    {
      "id": "LES-0006-CMD-008",
      "question": "What warning-or-higher kernel messages are retained for this boot?",
      "risk": "read-only",
      "command": "journalctl -k -b -p warning -n 100 --no-pager",
      "runFrom": "The affected Ubuntu boot through an identity authorized to read kernel journal entries",
      "expectedBranches": [
        {
          "when": "Device, filesystem, driver, security, or resource warnings appear",
          "meaning": "The kernel emitted retained messages at the selected priorities during this boot.",
          "nextEvidence": "Correlate the first relevant event with device state, systemd waits, and the service timeline."
        },
        {
          "when": "No entries appear",
          "meaning": "No accessible retained kernel event matched this priority and line-limited query.",
          "nextEvidence": "Adjust scope only for a stated hypothesis; absence here does not prove the kernel path was healthy."
        }
      ],
      "proves": "The newest 100 accessible retained current-boot kernel entries at warning priority 4 or a more important priority 0 through 3.",
      "doesNotProve": "That lower-priority events are irrelevant, that the journal retained the entire early boot, or that a matching warning caused the service failure."
    },
    {
      "id": "LES-0006-CMD-009",
      "question": "Is this the expected Ubuntu and systemd baseline before interpreting later output?",
      "risk": "read-only",
      "command": "cat /etc/os-release; systemd --version",
      "runFrom": "The exact Ubuntu shell being investigated",
      "expectedBranches": [
        {
          "when": "Ubuntu 24.04 and systemd 255 are reported",
          "meaning": "The shell matches the required lesson baseline.",
          "nextEvidence": "Continue with PID 1 and boot identity; version match alone does not prove the environment owns a complete boot."
        },
        {
          "when": "Another distribution, release, or systemd version appears",
          "meaning": "Flags, field values, defaults, and boot ownership may differ from the tested baseline.",
          "nextEvidence": "Record the exact versions and consult their local manuals before transferring a conclusion."
        }
      ],
      "proves": "The operating-system release metadata and installed systemd version exposed in this shell.",
      "doesNotProve": "That systemd is PID 1, that this is a full virtual-machine boot, or that every documented feature is enabled."
    },
    {
      "id": "LES-0006-CMD-010",
      "question": "Which boot journals are retained and accessible to this identity?",
      "risk": "read-only",
      "command": "journalctl --list-boots --no-pager",
      "runFrom": "The affected Ubuntu system through the same approved identity used for incident evidence",
      "expectedBranches": [
        {
          "when": "Multiple boot IDs and time ranges appear",
          "meaning": "The journal can query those listed retained boots.",
          "nextEvidence": "Select the incident boot by ID or verified relative offset before reading its events."
        },
        {
          "when": "Only the current boot appears, no rows appear, or access is restricted",
          "meaning": "Earlier boot evidence is not accessible through this query; retention, volatile storage, age, or permissions may explain it.",
          "nextEvidence": "Check approved retention and platform-console sources without claiming that an earlier event never occurred."
        }
      ],
      "proves": "The boot IDs and first-to-last retained journal timestamps accessible to the caller.",
      "doesNotProve": "That every real boot is listed, that each boot is complete, or why a previous boot is absent."
    },
    {
      "id": "LES-0006-CMD-011",
      "question": "Does this namespace expose the journald receiver socket independently of the service's active state?",
      "risk": "read-only",
      "command": "ss -xa | grep -F '/run/systemd/journal/socket'; stat -Lc 'type=%F uid=%u gid=%g mode=%a modified=%y path=%n' /run/systemd/journal/socket",
      "runFrom": "Ubuntu 24.04 after confirming systemd-journald.service is the reviewed local unit; no sudo",
      "expectedBranches": [
        {
          "when": "ss lists the path and stat reports a socket with numeric owner, mode, and timestamp",
          "meaning": "This network and mount namespace reports the UNIX-domain datagram endpoint path plus its filesystem metadata.",
          "nextEvidence": "Compare with a bounded journal query; a socket alone still does not prove ingestion, persistence, or an application user journey."
        },
        {
          "when": "The path is absent, grep returns no match, or stat fails",
          "meaning": "The expected local receiver endpoint is not observable from this namespace or environment.",
          "nextEvidence": "Recheck unit state, socket units, namespace ownership, and environment support without creating or restarting anything."
        }
      ],
      "proves": "Whether the current namespace reports the expected UNIX-domain socket endpoint path and the path's type, numeric ownership, permissions, and modification time.",
      "doesNotProve": "That journald can accept and persist a new message, that every journal is readable, or that an unrelated application is ready."
    },
    {
      "id": "LES-0006-CMD-012",
      "question": "Which unit-file fragments and drop-ins define the reviewed unit?",
      "risk": "read-only",
      "command": "systemctl cat <unit> --no-pager",
      "runFrom": "A local Ubuntu 24.04 terminal after replacing <unit> with the exact reviewed unit name; inspect before recording because unit fragments can contain Environment= secrets or internal URLs",
      "expectedBranches": [
        {
          "when": "One or more source paths and unit fragments are printed",
          "meaning": "These are the on-disk fragments systemctl found for the unit, in displayed precedence order.",
          "nextEvidence": "Inspect locally. If any fragment contains a credential, token, or sensitive internal URL, do not copy it; stop evidence capture and follow the applicable secret-response process. Otherwise compare the relevant directives with explicit systemctl show properties and loaded manager state."
        },
        {
          "when": "No files are printed or the unit is not found",
          "meaning": "The name may be wrong, inaccessible, generated, or transient, or the unit may not exist in this manager.",
          "nextEvidence": "Verify exact unit identity and LoadState; do not create a file to make the command succeed."
        }
      ],
      "proves": "The unit source fragments and drop-ins that systemctl can display for that exact name.",
      "doesNotProve": "That the manager reloaded a recent edit, that the unit is active or ready, or that a displayed directive caused the incident."
    }
  ],
  "labs": [
    {
      "id": "LES-0006-LAB-001",
      "title": "Read one boot as a causal timeline",
      "mode": "guided",
      "environment": "Ubuntu 24.04 with systemd as PID 1, at least 1 vCPU, 1 GiB RAM, 1 GiB free disk, procps, systemd, iproute2, grep, and coreutils; WSL 2 is observation-only with the documented boundary",
      "timeMinutes": 25,
      "privilege": "Normal user; no sudo. If journal access is restricted, record that branch instead of changing groups or permissions.",
      "network": "None",
      "changes": ["No lesson-owned persistent state or long-running process; commands read release files, procfs, systemd manager metadata, local socket metadata, and bounded journal views"],
      "abortConditions": [
        "Stop the systemd-specific path if PID 1 is not systemd.",
        "Stop if a copied command differs from the lesson or contains a mutating systemctl verb.",
        "Do not continue by adding sudo, changing journal permissions, resetting failed units, restarting services, editing unit files, or changing boot configuration.",
        "Do not paste unsanitized employer, hostname, address, username, token, or production data into learning evidence."
      ],
      "recovery": "No recovery is expected because the lab is read-only. If any command was changed into a mutating form, stop and document the exact change before doing anything else.",
      "cleanupProof": "The lesson defines no owned path, unit, socket, mount, package, or long-running process to remove. Verify that you ran only the documented read-only commands; ordinary command processes and access or audit records may exist."
    }
  ],
  "incidents": [
    {
      "id": "LES-0006-INC-001",
      "signal": "The service is active, but the load balancer marks the instance unhealthy for seven minutes after boot.",
      "firstThought": "Active is the systemd manager's lifecycle state, not proof of listening, readiness, dependency health, load-balancer admission, or a successful user request.",
      "safePath": "Anchor the timeline with boot ID, inspect unit properties and current-boot monotonic logs, verify socket ownership, run the exact readiness operation from the relevant boundary, and find the first disagreement before changing state.",
      "trap": "Increasing the health-check grace period or restarting the unit. Either can hide the boundary without explaining why ready lags active."
    },
    {
      "id": "LES-0006-INC-002",
      "signal": "After a kernel rollout, some virtual machines wait on a device or mount and miss the boot-to-ready objective.",
      "firstThought": "Treat rollout cohort, kernel version, boot ID, device discovery, mount ownership, systemd dependency ordering, and readiness as one comparable timeline.",
      "safePath": "Pause the rollout, preserve previous-boot and affected-boot evidence, compare with healthy controls, restore through reviewed instance replacement or validated rollback, and reproduce boot mutation only in a disposable VM.",
      "trap": "Editing bootloader entries interactively across the fleet, removing the dependency, or raising the timeout without proving whether the device is required."
    }
  ],
  "assessmentIds": ["ASM-0001", "ASM-0002", "ASM-0003"],
  "referenceIds": ["REF-0001", "REF-0002", "REF-0003", "REF-0004", "REF-0005", "REF-0006", "REF-0007", "REF-0008"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The guided lab observes an already-running system and does not reproduce firmware, bootloader, initramfs, failed-root, or emergency-target recovery.",
    "Firmware and bootloader details differ across physical servers, cloud platforms, hypervisors, architectures, secure-boot policies, and image pipelines.",
    "The guided lab stops at the journald socket boundary; it neither sends a journal event nor proves application readiness, so independent transfer requires a separate reviewed localhost readiness operation.",
    "WSL 2 and containers intentionally hide or share boot stages, so evidence collected there cannot be generalized to a full virtual machine boot.",
    "No boot or systemd mutation is authorized by this lesson; those exercises require the planned disposable-VM harness and separate recovery verification.",
    "Publication and reading do not demonstrate learner mastery; ASM-0003 requires independently produced and reviewed evidence."
  ]
}
---

# Boot, kernel handoff, systemd, and the journal

## What you see and first thought

Hey Abhishek, when someone says, "the server booted slowly" or "the service is active but unavailable," do not let those words collapse the whole machine into one box. Your first job is to name two endpoints:

1. **Where did the timing start?** Power-on, virtual-machine (VM) start, kernel start, process identifier 1 (PID 1) start, unit activation, or deployment?
2. **What counts as finished?** Login prompt, target reached, process running, port listening, readiness passing, load balancer admission, or a real user request succeeding?

Without those endpoints, "boot took seven minutes" is not measurable. A VM can finish kernel startup quickly and then wait in userspace. A service can become `active` while its dependency is unusable. A load balancer can keep an instance out of rotation after the process starts. The first visible symptom is usually downstream from the first failure.

Use this memory sentence:

> Boot is a chain of ownership handoffs. Find the last healthy handoff, the first unhealthy handoff, and the evidence that crosses them.

Your default move is read-only: record the boot identity, kernel, PID 1, phase timing, unit state, journal window, and real readiness result. A reboot destroys the very timeline you need, so it is a recovery action with evidence cost, not a harmless diagnostic command.

## Terms before commands

### Firmware or virtual platform

On physical hardware, firmware such as the Unified Extensible Firmware Interface (UEFI) initializes enough platform state to select a boot path. In a virtual machine, the hypervisor and virtual firmware present a virtual central processing unit (CPU), memory, disks, timers, and devices. From an ordinary Ubuntu shell you usually see the result, not every event inside this stage.

### Boot loader and boot entry

The boot loader selects a kernel image, an initial RAM filesystem, and a kernel command line. The GNU Grand Unified Bootloader (GRUB) is common on Ubuntu, but cloud images and architectures can use different mechanisms. A boot entry is a choice; it is not the running kernel. `uname -r` tells you what is running now, while `/proc/cmdline` shows arguments exposed by that running kernel.

### Kernel space and userspace

The kernel owns scheduling, virtual memory, device drivers, filesystems, networking, security hooks, and system calls. Userspace contains ordinary processes such as systemd, application services, shells, and agents. Userspace asks the kernel to perform privileged operations through system calls. A userspace process failing does not mean the kernel crashed; a kernel-owned device wait can still delay a userspace unit.

### Initramfs and the real root filesystem

The initramfs is a temporary early-userspace filesystem loaded into memory. It contains tools and drivers needed to discover storage, unlock encryption, assemble volumes, or mount the real root filesystem. After the real root is ready, control switches into it. A failure here can occur before the normal root filesystem and its complete logs are available.

### PID 1 and systemd

PID 1 is the first userspace process created by the kernel in the system's initial PID namespace. On Ubuntu 24.04 this is normally systemd. It has special responsibilities: it creates and supervises units, reaps orphaned child processes, and coordinates shutdown. Inside a container, PID 1 may be the application or a tiny init, while the container still shares the host kernel.

### Unit, job, and target

A **unit** is a systemd-managed object such as a service, socket, mount, device, timer, path, slice, or target. A **job** is a pending operation such as starting or stopping a unit. A **target** groups units and expresses a synchronization milestone; it is not itself a health check. When `multi-user.target` becomes active, its own start job has reached the manager-defined activation point. That does not prove every unit pulled into the wider transaction succeeded, every wanted service stayed healthy, or any customer journey worked.

### Dependency and ordering

`Wants=` and `Requires=` are pull-in relationships, not readiness checks. `Wants=` is weak: failure of the wanted unit does not by itself fail the wanting unit. `Requires=` is stronger: the required unit is started with this unit and deactivation of the required unit stops the requiring unit; start-failure propagation also depends on ordering such as `After=`. Separately, `After=` and `Before=` express ordering. Pull-in does not automatically create ordering, and ordering does not automatically pull a unit in. This is an interview favorite because confusing the axes creates services that start in the wrong sequence, stop unexpectedly, or wait on something they never needed.

### Journal, boot ID, and clocks

`systemd-journald` stores structured events with fields such as unit, PID, priority, and boot ID. The kernel generates a new boot ID for each boot. **Realtime** is wall-clock time and can jump when corrected. **Monotonic time** starts at boot and moves forward while the system runs. During boot diagnosis, boot ID answers "which boot?" and monotonic time answers "what order and elapsed gap inside that boot?"

### Active, ready, and healthy

`ActiveState=active` is systemd manager state. Ready means the application has completed whatever initialization its readiness contract requires. Healthy is a broader consumer claim: the correct request works through the relevant network, proxy, application, and dependency path. Never use these three words as synonyms.

## Architecture map

Read this left to right. Every arrow is an ownership handoff and a possible failure boundary.

```text
physical host or VM platform
        |
        | chooses a boot path and exposes devices
        v
firmware / virtual firmware
        |
        | selects boot entry
        v
boot loader ---- kernel image + initramfs + command line
        |
        v
Linux kernel ---- CPU, memory, drivers, scheduler, filesystems, network
        |
        | starts early userspace and discovers real root
        v
initramfs -------- unlock / assemble / find / mount root
        |
        | executes init on the real root filesystem
        v
systemd (PID 1) -- builds jobs from units and dependencies
        |
        +--> device and mount units
        +--> network and identity dependencies
        +--> application.service
                 |
                 +--> process exists
                 +--> socket listens
                 +--> readiness passes
                 +--> load balancer admits
                 `--> user request succeeds
```

Now zoom in on the dangerous assumption:

```text
systemctl says active
        |
        | proves manager lifecycle state
        v
main process exists ----X----> user can pay successfully
        |                         ^
        +--> port?                |
        +--> correct config?      |
        +--> database reachable?  |
        +--> readiness correct? --+
        +--> proxy route correct?
```

The crossed arrow is wisdom worth remembering: **process-manager success is not user-journey success**.

## Request or state path

A production boot investigation becomes manageable when you write one row per boundary.

| Boundary | Owner | State or operation | Useful evidence | What success still does not prove |
|---|---|---|---|---|
| Platform start | firmware, hypervisor, or cloud control plane | CPU, memory, boot device, console | platform event or serial console | kernel selected or root mounted |
| Boot selection | boot loader or image pipeline | kernel, initramfs, command line | boot entry plus `/proc/cmdline` after boot | parameter correctness or driver success |
| Kernel start | Linux kernel | hardware, drivers, scheduler, filesystems | kernel release and boot-scoped kernel messages | userspace dependency readiness |
| Early userspace | initramfs tooling | root discovery, encryption, RAID or LVM | early console and retained boot messages | real-root services started |
| Service manager | systemd PID 1 | unit jobs, dependencies, ordering, supervision | `systemd-analyze`, unit properties, journal | application readiness |
| Application | service process | config, listener, workers, dependency clients | application logs, socket, readiness | load balancer admission or full journey |
| Consumer path | proxy, load balancer, client, dependencies | real request and response | health check or synthetic transaction | every feature and failure mode is healthy |

When you investigate, do not jump randomly between rows. Start from the failed consumer boundary, find the last success, then move one boundary toward the source. If a load balancer fails but a local readiness request succeeds, inspect listener binding, proxy path, policy, and health-check definition. If the local readiness request also fails, move into the application and its dependencies. If the application has not started because a mount job is waiting, move toward systemd, kernel, and device ownership.

## Failure zoom

### Symptom: the machine never reaches a normal login or application target

Possible families include a wrong boot entry, missing root device, failed unlock, initramfs driver gap, failed Redundant Array of Independent Disks (RAID) assembly, Logical Volume Manager (LVM) discovery, filesystem failure, emergency target, or a systemd dependency that never completes. The safest evidence may be serial console or a previous-boot journal rather than a Secure Shell (SSH) session that does not exist yet.

### Symptom: userspace dominates systemd-analyze time

Think dependency wait, device or mount activation, network-online semantics, service timeout, retry loop, or intentionally slow initialization. Do not say "systemd is slow." systemd is coordinating work; the delayed owner may be a device, unit, script, or dependency contract.

### Symptom: the service is active but requests fail

Think wrong binding address, listener not yet created, readiness contract missing, application worker failure, dependency outage, proxy mismatch, or a short restart loop. Read structured unit properties, not only the colored status summary, and test the request from the same boundary as the failure.

### Symptom: current logs look healthy after a reboot

The reboot created a new boot ID and possibly removed volatile evidence. Query the previous boot with `-b -1` only after confirming that previous-boot journal data exists and refers to the incident. Record `journalctl --list-boots --no-pager`. An offset is relative to the journals available on that machine, not a universal boot number.

### Symptom: timestamps move backward or appear inconsistent

Early wall-clock time can be wrong and then corrected by time synchronization. Use `short-monotonic` inside one boot to reason about order and elapsed gaps. Use wall clock to correlate across systems only after confirming synchronization, timezone, and clock quality.

## Internals and state ownership

### What the kernel actually hands to PID 1

After the kernel initializes enough state and obtains a root filesystem, it starts the init program. Kernel command-line parameters can influence kernel subsystems and the init selection. Once systemd runs, the machine has crossed into normal userspace, but kernel-owned operations continue underneath every process: system calls, device I/O, page allocation, socket operations, and permission enforcement.

This is why a userspace unit can wait in `activating` while the actual delay is a device unit or filesystem mount. systemd owns the job state; the kernel or hardware may own the operation being awaited.

### How systemd builds work

systemd loads unit definitions from vendor, runtime, and administrator locations, applies drop-ins, resolves dependencies, and builds a transaction of jobs. Many jobs run in parallel. An ordering edge says one job must reach the required ordering point before another proceeds. It does not say the earlier unit is healthy forever.

The practical states are separate axes:

| Field | Question it answers | Common values | Important caution |
|---|---|---|---|
| `LoadState` | Could systemd load the unit definition? | `loaded`, `not-found`, `error`, `masked` | Loaded does not mean started. |
| `ActiveState` | What broad lifecycle state does the manager hold? | `inactive`, `activating`, `active`, `deactivating`, `failed` | Active does not mean ready. |
| `SubState` | What more specific state applies to this unit type? | `running`, `exited`, `dead`, `failed`, `start-pre` | Interpret it with unit type and configuration. |
| `Result` | How did systemd classify the most recent service run? | `success`, `exit-code`, `signal`, `timeout`, `oom-kill` | A current active state can coexist with an earlier failure after restart. |
| `ExecMainCode` | What kind of wait result describes the main process? | exited, killed, dumped, often exposed numerically | Decode this before treating `ExecMainStatus` as an exit code. |
| `ExecMainStatus` | Which exit status or signal was recorded for the main process? | numeric code | Its meaning depends on `ExecMainCode`, lifecycle, and service type. |
| `NRestarts` | How many automatic restarts has the manager counted? | integer | A rising count can hide a crash loop behind brief active periods. |

`systemctl status` is excellent for a human snapshot, but it combines selected properties with a short log tail. During an incident, use `systemctl show` when you need explicit fields that can be compared and recorded without color or prose ambiguity.

### Why critical-chain is evidence, not a verdict

`systemd-analyze critical-chain` calculates a time-critical path from recorded activation data. A unit shown with `+45s` took 45 seconds between its activation start and completion for ordering purposes. It may have used CPU, slept, retried, waited on a device, or waited on another external condition. Parallel units off the displayed chain may still hurt application readiness. The default target may also complete before or after the user-visible milestone you care about.

There is another sharp edge: the graph is built from jobs with usable activation timestamps. A job that timed out, or a device unit that never entered the `activating` state, may be missing even when it matters to the incident. Treat an absent node as "not displayed by this calculation," not "proved irrelevant." Confirm with failed-unit state, unit properties, boot-scoped journal evidence, and the owning device or dependency.

### How journald turns messages into structured events

Journal entries can include message text plus trusted fields added by the journal such as process ID, user identifier (UID), unit, boot ID, transport, and timestamps. Query filters narrow the event set. `-b` selects a boot, `-u` selects unit-associated events, `-k` selects kernel messages, `-p` selects priorities, `--since` selects time, and `-n` bounds lines.

No log system is omniscient. An application may omit context, rate limiting can suppress messages, storage can be volatile, permissions can hide entries, and a crash can occur before buffers flush. "No matching journal entry" means the query returned none you could access; it does not mean the event never happened.

## Evidence table

| Observation | First interpretation | Safest next evidence | Do not conclude yet |
|---|---|---|---|
| PID 1 is not systemd | environment boundary differs | virtualization and namespace identity | systemd is broken |
| Kernel phase is normal, userspace phase is high | delay is mainly after kernel handoff | critical chain plus readiness timeline | one listed unit is guilty |
| Unit is `activating` | activation has not reached its completion point | SubState, dependencies, journal, owning operation | process is simply slow |
| Unit is `active (exited)` | the configured start action completed and no long-running main process is required | unit type, `RemainAfterExit`, downstream state | application process is running |
| `NRestarts` increases | automatic restart policy is being exercised | exit result, signal, logs, cgroup or kernel evidence | restart policy fixed the problem |
| No failed units | manager has no current loaded unit in failed state | service readiness and consumer path | system is healthy |
| Previous boot has a device timeout | kernel emitted a timeout event in that boot | dependency timing and healthy comparison | timeout caused the outage |
| Local request passes, load balancer fails | application may be locally ready | binding, network path, policy, health-check definition | load balancer is wrong |

The command cards on this page follow a strict sentence pattern: **question -> branch -> meaning -> next evidence -> proof boundary**. Use that pattern in interviews and incidents. It prevents command dumping and shows senior judgment.

## Command decoders

### Decoder 1: `systemd-analyze time`

Example teaching output:

```console
Startup finished in 6.812s (firmware) + 2.041s (loader) + 4.233s (kernel) + 1.508s (initrd) + 17.942s (userspace) = 32.538s
graphical.target reached after 17.601s in userspace.
```

| Field | Plain meaning | SRE use | Common misread |
|---|---|---|---|
| `firmware` | time reported before boot loader handoff | compare platform or firmware regression cohorts | the Linux kernel spent this time |
| `loader` | boot loader phase where measurable | identify boot selection or loader delay | every platform reports it accurately |
| `kernel` | kernel phase before initrd or userspace handoff as measured | compare driver and early-kernel change | all device work ended here |
| `initrd` | temporary early-userspace phase | investigate root discovery, unlock, storage assembly | the real root filesystem was fully usable throughout |
| `userspace` | elapsed normal-userspace initialization until systemd reports all system services spawned | investigate unit graph and dependency waits | every service finished initialization, the disk became idle, or systemd itself consumed that much CPU |
| `reached after` | a separate timestamp for when the named target became active | compare a consistent manager milestone | every wider transaction job succeeded or the application passed readiness then |

### Decoder 2: `systemd-analyze critical-chain`

```console
graphical.target @17.601s
`-multi-user.target @17.600s
  `-api.service @10.214s +7.381s
    `-network-online.target @10.201s
      `-systemd-networkd-wait-online.service @2.119s +8.066s
```

`@10.214s` means the unit reached its activation point about 10.214 seconds after userspace timing began. `+7.381s` is its activation duration. Indentation shows the displayed time-critical relationship. It does not mean `api.service` used a CPU for 7.381 seconds. It may have waited on another process or resource.

### Decoder 3: structured unit properties

```console
LoadState=loaded
ActiveState=active
SubState=running
Result=success
ExecMainCode=1
ExecMainStatus=0
NRestarts=4
```

Do not stop at the comforting words `active` and `success`. `ExecMainCode` tells you whether `ExecMainStatus` represents an exit status or a signal; never decode the status number alone. `NRestarts=4` means the manager has performed four automatic restarts, not necessarily four failures because the configured restart policy may also restart clean exits. Ask when those restarts occurred, what ended each invocation, whether readiness failed during them, and whether the count is still rising.

### Decoder 4: monotonic journal output

```console
[   10.217483] host systemd[1]: Starting api.service...
[   25.224091] host api[1842]: dependency connection timed out
[   25.226410] host systemd[1]: api.service: Main process exited, status=1/FAILURE
```

The bracketed value is time since boot on a monotonic axis for display. The 15-second gap is worth investigating. It does not by itself prove the dependency caused the exit; the application message, unit result, dependency telemetry, and repeated behavior strengthen or reject that hypothesis.

### Decoder 5: journal priorities

The journal uses syslog priority numbers from `0` through `7`: `0 emerg`, `1 alert`, `2 crit`, `3 err`, `4 warning`, `5 notice`, `6 info`, and `7 debug`. A smaller number is more important. With one value, `-p warning` includes warning priority 4 and all more-important priorities 0 through 3. A written range includes only its endpoints and the priorities between them, so a careless range can exclude a level you intended to inspect.

This is why the lab uses `-p warning`, not a reversed-looking range. The filter proves only which retained entries matched; it does not make every matching warning causal.

## Decision path

Use this sequence during an on-call boot or startup incident:

1. **Define the failed milestone.** Write the exact consumer operation and the expected boot-to-ready objective.
2. **Freeze identity.** Record machine or instance cohort, boot ID, kernel release, PID 1, image or rollout version, and timezone.
3. **Preserve before mutation.** Save bounded current-boot and, when relevant, previous-boot evidence through the approved support path.
4. **Split the phase.** Use platform timing and `systemd-analyze time` to decide where to zoom, not whom to blame.
5. **Find the first divergence.** Compare affected and healthy timelines; look for the earliest different device, job, timeout, result, or readiness event.
6. **Inspect one owner at a time.** Kernel or device, systemd dependency, service process, listener, readiness, proxy, or downstream dependency.
7. **Choose the lowest-risk recovery.** Prefer rollout pause, replacement, traffic removal, or tested rollback over interactive fleet-wide boot edits.
8. **Verify the real milestone.** A recovery is complete only when the consumer operation and reliability objective recover.
9. **Prevent the same class.** Add boot-to-ready measurement, canaries, explicit dependencies, bounded timeouts, evidence retention, and rollback criteria.

```text
consumer check fails
      |
      v
process absent? -- yes --> unit load/result/logs --> dependency/kernel owner
      |
      no
      v
listener absent? -- yes --> binding/startup/readiness initialization
      |
      no
      v
local readiness fails? -- yes --> application + downstream dependency
      |
      no
      v
remote health fails --> route / policy / proxy / health-check definition
```

At every arrow, say what the prior observation proved. That habit is what turns a command user into a reliable production diagnostician.

## Guided Ubuntu lab

This lab is intentionally read-only. Run it in Ubuntu 24.04. Do not add `sudo`, restart a unit, reset failed state, or edit anything.

### Lab contract before you type

| Item | Required baseline | Why it matters |
|---|---|---|
| Compute | 1 virtual CPU and 1 GiB memory are sufficient | the lab observes state; it does not load-test the machine |
| Disk | 1 GiB free is recommended; the lab writes no lesson files | low host capacity should not be confused with a boot lesson result |
| Packages | `systemd`, `procps`, `iproute2`, `grep`, and `coreutils` already installed | the lab never installs or downloads dependencies |
| Ports and network | no port is opened and no external network is used | every check stays in the current local namespace |
| Privilege | normal user, no `sudo` | restricted journal output is a valid evidence branch |
| Evidence artifact | a sanitized table of command, observation, meaning, and next proof in your approved notes | raw hostnames, addresses, usernames, tokens, and employer data do not belong in the repository |

Expected variation is part of the exercise: WSL may omit firmware or loader timing, journals may be permission-limited, and a long-running machine may have no recent journald startup event. Stop if PID 1 is not systemd. Do not install packages, enable systemd, change groups, or modify WSL boot settings to force a preferred answer.

### Step 0: preflight the environment boundary

```bash
cat /etc/os-release
systemd --version
printf 'pid1='; ps -p 1 -o comm=
printf 'kernel='; uname -r
printf 'boot_id='; cat /proc/sys/kernel/random/boot_id
journalctl --list-boots --no-pager
```

Expected reasoning:

- If PID 1 is `systemd`, continue.
- If PID 1 is not `systemd`, stop the systemd-specific path. You have learned something important about the environment; you have not failed the lab.
- Record the boot ID once. Every later journal statement must refer to that same boot.
- Record the Ubuntu and systemd versions. If they differ from the tested baseline, use the local manuals for those versions.
- Sanitize the evidence table; do not copy raw machine identity or unrelated journal content into Git.

### Step 1: read the broad boot phases

```bash
systemd-analyze time
```

Write one sentence: "For this boot, the largest reported phase is ___, but this output does not identify ___." Do not copy numbers without interpretation.

### Step 2: inspect the time-critical chain

```bash
systemd-analyze critical-chain --no-pager
```

Choose one `@time` and one `+duration`. Explain both symbols. Then name one parallel unit or user-visible milestone the command might not represent.

### Step 3: check manager-visible failures

```bash
systemctl --failed --no-pager
```

If zero units fail, write: "No current failed units does not prove readiness because ___." If units fail, do not reset or restart them. Pick one only if it is safe to inspect and contains no employer-sensitive naming.


Decode the columns before interpreting the row: `UNIT` is the exact object name, `LOAD` says whether its definition loaded, `ACTIVE` is the broad lifecycle state, `SUB` is the unit-type-specific state, and `DESCRIPTION` is human-facing text rather than an identity. A failed row is a lead, not proof of customer impact or root cause.
### Step 4: inspect a known local unit without changing it

Ubuntu systems normally include `systemd-journald.service`. Confirm its name first, then read explicit fields:

```bash
systemctl show systemd-journald.service --no-pager \
  -p LoadState -p ActiveState -p SubState -p Result -p ExecMainCode -p ExecMainStatus -p NRestarts
systemctl cat systemd-journald.service --no-pager
```

Now explain each returned field. `active` must never be your final sentence. Read unit fragments locally before recording them: even a read-only `systemctl cat` can reveal literal `Environment=` values or internal URLs. If you see a credential or sensitive value, stop evidence capture, do not copy it, and follow the applicable secret-response process.

### Step 5: read a bounded unit timeline

```bash
journalctl -b -u systemd-journald.service \
  -o short-monotonic -n 100 --no-pager
```

No output can be a valid branch if no retained event matches or your identity cannot read it. State the query boundaries: current boot, one unit, newest 100 matching lines, monotonic display, no pager. During a live incident you can add a reviewed wall-clock window such as `--since '-15 min'`, but that window is wrong for learning boot events on a machine that started hours ago.

### Step 6: compare manager state with a separate local endpoint

A service manager saying `active` is one boundary. The expected local receiver socket is another. Inspect it without sending a message:

```bash
ss -xa | grep -F '/run/systemd/journal/socket'
stat -Lc 'type=%F uid=%u gid=%g mode=%a modified=%y path=%n' /run/systemd/journal/socket
```

If both commands succeed, you have evidence that this namespace reports the journald UNIX-domain datagram endpoint path and its filesystem ownership. You still have not proved that a new message can be ingested and persisted, or that any application is ready. If either command fails, keep the failure as evidence; do not create the socket or restart the service.

### Step 7: read bounded kernel warnings

```bash
journalctl -k -b -p warning -n 100 --no-pager
```

If access is denied, record the permission boundary. Do not change group membership or use an unreviewed privilege escalation just to make the lab green. If warnings appear, choose one and explain what extra evidence would be required before calling it causal.

### Step 8: close the read-only boundary honestly

Compare what you ran with the documented command list. Shell history is a convenience, not proof: it may be disabled, truncated, or incomplete. Your cleanup statement should say:

> This lesson defined no owned path, unit, socket, mount, package, or long-running process to remove. I ran only the documented read-only commands. Ordinary command processes and normal access or audit records may exist.

Success is not "all output matched the screenshot." Success is a correct boundary-aware explanation of the output your environment actually produced.

## Production transfer

### Virtual machines

A virtual machine (VM) has a virtual firmware and boot path, its own guest kernel, and normally its own systemd. You can measure boot-to-ready meaningfully, but platform events and console evidence still live outside the guest. Join cloud or hypervisor instance identity with the guest boot ID.

### Containers

A normal container starts a process; it does not boot a private kernel. PID 1 inside the container is PID 1 only in that PID namespace. Host `journalctl -k` describes the shared host kernel, and systemd may run only on the host. If a pod starts slowly, investigate image pull, scheduling, volumes, network, init containers, application startup, and readiness rather than calling it a kernel boot.

### Kubernetes

Kubernetes adds a separate reconciliation path. A **pod** is Kubernetes' smallest scheduled workload; an **init container** performs ordered setup before the application; a **readiness probe** decides whether traffic should be sent; an **EndpointSlice** records ready network endpoints; and a **Service or ingress** provides routing. The path is: node ready, pod scheduled, image available, volumes attached, init containers complete, application container started, readiness probe passes, EndpointSlice updated, Service or ingress routes, request succeeds. Map systemd lessons to the node's `kubelet` service where appropriate, but do not confuse pod readiness with systemd `ActiveState`.

### Fleet operations

At scale, one machine is a sample. Add cohort dimensions: image, kernel, architecture, zone, instance type, device model, rollout wave, and configuration version. Look for the first repeatable divergence. A canary rollback decision based on boot-to-ready service-level objective (SLO) impact is safer than interactive edits across hundreds of hosts.

### Incident communication

A strong update sounds like this:

> "The affected cohort boots the new kernel successfully, but a required device becomes available 90 seconds later than the healthy cohort. systemd waits on the corresponding mount, so the API stays activating and misses boot-to-ready. We paused the rollout, removed affected instances from service, preserved two boot journals, and are validating rollback on the canary group."

Here, API means application programming interface: the request boundary used by another program. That update separates observation, interpretation, customer impact, action, and next proof.

## Reliability, security, observability, capacity, and cost

### Reliability

Define a boot-to-ready service-level indicator (SLI): the measured time from an agreed start to a consumer-ready result. Set an SLO as the target for that indicator. Track the distribution, not only the average. A few seven-minute boots can violate recovery objectives even when the median is healthy. Test rollback and previous-kernel availability before rollout.

### Security

Boot configuration, Secure Boot, kernel parameters, initramfs contents, unit files, credentials, and journal access are security boundaries. Do not solve diagnosis by disabling signature enforcement, weakening unit sandboxing, granting broad journal groups, or running every inspection as root. Preserve least privilege and auditability.

### Observability

Attach boot ID, kernel version, image version, unit invocation, and deployment cohort to events and metrics. Retain enough previous-boot evidence for the recovery objective. Bound log queries to control noise and accidental exposure. Never paste production logs with tokens or customer data into this book.

### Capacity

Boot storms create simultaneous CPU, disk, network, Domain Name System (DNS), secret-service, and package-repository demand. A dependency that handles steady state can collapse when a whole fleet restarts. Model concurrent recovery, backoff, jitter, and dependency quotas.

### Cost

Slow readiness keeps paid capacity unavailable, can trigger extra autoscaling, and lengthens maintenance windows. Excessive journal retention also consumes disk, while insufficient retention increases incident time. Choose retention and telemetry according to recovery objectives, privacy, and investigation value.

## Traps and prevention

| Trap | Why it fails | Better operating rule |
|---|---|---|
| Reboot first | destroys current volatile state and creates a new boot ID | preserve bounded evidence, then recover with an explicit evidence-cost decision |
| Blame the longest `blame` row | parallel work and external waits distort causality | use critical path, dependencies, logs, and readiness timeline |
| Treat `active` as healthy | manager state ends before consumer success | verify listener, readiness, admission, and real request |
| Add `After=network-online.target` everywhere | target semantics depend on network stack and can serialize boot unnecessarily | define the exact network condition the service needs and handle retry explicitly |
| Increase a timeout | hides which operation violates the time budget | identify owner, expected latency, abort behavior, and recovery contract |
| Disable a failing unit | can remove a required security, storage, or network function | prove requirement and blast radius in a disposable VM first |
| Use unbounded `journalctl` | creates noise, pager confusion, and data exposure | scope boot, unit or kernel, time, priority, lines, and output mode |
| Trust wall clock blindly | time correction can reorder early events | use boot ID and monotonic time within one boot |
| Debug host boot from an app container | container shares or hides host stages | move to the namespace and control plane that owns the stage |

Prevention is an engineered path: canary boot, automatic boot-to-ready measurement, defined rollback threshold, previous-boot evidence retention, dependency contract tests, and a disposable recovery lab.

## Memory card and retrieval

### The seven-stage picture

Say this without looking:

```text
platform -> boot entry -> kernel/initramfs -> real root -> PID 1 -> service/readiness -> user request
```

### The five questions

1. Which boot and kernel am I observing?
2. Which phase owns the delay?
3. Which job, dependency, or operation is first abnormal?
4. What does systemd state prove, and what user boundary remains?
5. What evidence will a recovery destroy?

### One-line rules

- Boot timing narrows a phase; it does not name root cause.
- Requirement and ordering are different relationships.
- Active is not ready; ready is not the complete user journey.
- Boot ID identifies the boot; monotonic time orders it.
- A reboot is a mutation with evidence cost.

Close the page and redraw the chain. If you cannot place a command at one boundary and state what it proves, revisit that section before running more commands.

## Complete answers

The answered diagnostic and interview records below are part of the lesson contract. First answer aloud in your own words. Then reveal the full answer and compare your causal chain, evidence boundaries, recovery safety, and prevention controls. Memorizing the prose is not the goal; rebuilding the reasoning is.

A complete answer always contains:

1. the direct conclusion;
2. the foundation that makes it true;
3. the evidence sequence;
4. what each signal cannot prove;
5. the safe production decision;
6. the weak answer and why it is dangerous.

## Product-company interview

Senior interviewers rarely care that you remember a `journalctl` flag in isolation. They want to hear whether you can control uncertainty and blast radius.

For a boot incident, structure your answer like this:

```text
customer impact and recovery objective
  -> affected cohort and exact boot identity
  -> last healthy / first unhealthy boundary
  -> competing hypotheses
  -> evidence that separates them
  -> reversible restoration with rollback
  -> verification at consumer boundary
  -> prevention and measurable guardrail
```

The advanced interview assessment asks you to handle a kernel rollout, a device timeout, misleading active state, and a missed load-balancer objective together. A strong answer crosses layers without pretending that temporal correlation is causation.

## Independent transfer and rubric

The independent task is deliberately answer-isolated. It gives deliverables and observable scoring criteria, not a model solution. Perform it only on a disposable Ubuntu 24.04 VM and choose a service other than the guided lab's `systemd-journald.service`. The readiness operation must stay on approved localhost scope, require no credential, and cause no business side effect. The task is read-only, but the VM requirement teaches the correct future boundary for boot recovery work.

Reading this lesson, revealing answered questions, or marking the page finished never changes mastery. Mastery requires your own sanitized boot-ID-scoped evidence, a causal explanation, a safe local readiness check different from guided practice, and human review against ASM-0003.

If you need the model answer while performing the independent task, stop and return to guided practice. That is not failure; it is honest evidence that transfer is not independent yet.

## References and review

This chapter is anchored to the Linux kernel administrator documentation and the systemd 255 manuals matching the Ubuntu 24.04 baseline. The reference cards preserve exact source ownership, version context, relevance, and review dates.

Use the local manual pages to check the version actually installed on your machine:

```bash
systemd --version
man systemd-analyze
man systemctl
man journalctl
```

`man` is local and offline once packages are installed. A newer upstream manual may document options your Ubuntu version does not have, so always connect a command to the installed version. The external reference links are provenance for maintainers; this lesson and guided lab do not require network access.

Review is due by 2027-02-02 or earlier if Ubuntu 24.04 systemd behavior, the structured-content contract, lab safety rules, or the reader changes materially. The chapter remains a substantive draft until subject, safety, instructional, renderer, and disposable-VM recovery reviews are complete.
