# Linux production interview: explain the mechanism, not a memorized command

This chapter is for practising aloud after you have read the Linux lessons and used a safe local lab. It is not an employment promise or a certification score. A good interview answer is a compact incident review: establish impact, name the next evidence, explain the mechanism, choose a bounded action, and say how recovery is proved.

## The answer spine to remember

When the interviewer gives you a Linux symptom, do not begin with a command. Begin with this chain:

```text
user operation -> exact host/container/path -> time/change -> evidence -> mechanism
       -> smallest safe containment -> user-visible verification -> prevention
```

For every command you mention, say what it proves and what it does not prove. `top` can show a busy process; it cannot prove why that process is busy. `systemctl status` can show a unit state; it cannot prove that users can complete their operation. That sentence alone separates observation from conclusion.

## Scenario 1: a service is "running" but requests fail

**Question:** `systemctl status payments-api` says `active (running)`, yet users receive 502 responses. What do you do?

**Strong answer:** First I establish the failed operation, exact endpoint, affected clients, start time, recent release/configuration changes, and healthy comparison. `active (running)` means systemd still supervises a process; it does not prove the process accepts traffic, is healthy, has valid configuration, or can reach a dependency. I inspect the unit definition and recent journal entries with `systemctl cat payments-api` and `journalctl -u payments-api --since "..."`, then map the request path: listener/socket, reverse proxy upstream, application health/readiness endpoint, dependency connection, and the relevant logs or trace ID. I compare the process, port and response from the same local/network context as the proxy. I contain with the smallest reversible move—such as routing to a known-good revision or rolling back a confirmed bad release—then verify both a successful user request and stable system signals. Prevention is a meaningful readiness check, release guard, alert, ownership and runbook.

**Weak answer:** "Restart it because systemd says it is unhealthy." A restart may destroy evidence, create a new failure window, and hide a dependency or configuration fault.

**Senior follow-up:** What would make you use `systemctl restart`? A defined runbook condition, a bounded blast radius, evidence that process state is the likely cause, a rollback/containment plan, and a way to verify the user journey afterward.

## Scenario 2: high load average with low CPU use

**Question:** Load average is 40 on a 16-core host, but aggregate CPU utilisation is low. Explain your investigation.

**Strong answer:** Load average is a count of tasks runnable or in uninterruptible sleep over time; it is not CPU percentage. Low CPU plus high load makes me test blocked work, especially storage or a kernel wait path, rather than immediately adding CPU. I compare `uptime` with `vmstat 1 5` and `iostat -xz 1 5` where available, inspect process state with `ps -eo pid,stat,wchan:32,comm`, and use `pidstat` or application metrics to identify the owners of the work. `D` state is a clue that a task is waiting in an uninterruptible kernel path, often I/O; it does not identify the storage device or root cause by itself. I check latency, queue depth, filesystem errors, network storage health, saturation and recent workload changes. Containment might pause a noncritical batch producer or shed a bounded workload after confirming ownership. Recovery means queue/latency and the real user operation return to normal, not only that the one-minute load number falls.

**Weak answer:** "Load is above core count, so CPU is exhausted." Core count is context, not a diagnosis; I/O wait, runnable threads, cgroup throttling and workload shape all matter.

**Senior follow-up:** What is your capacity prevention? Define a workload-specific saturation signal—such as storage latency, queue depth or runnable pressure—measure a baseline, protect headroom, and use a tested admission/queue policy rather than a single load threshold.

## Scenario 3: a container exits 137

**Question:** A Kubernetes workload repeatedly exits 137. Node memory looks available. The application team asks for privileged mode and a much larger limit.

**Strong answer:** Exit 137 means a process received `SIGKILL`; an out-of-memory (OOM) kill is common but not the only explanation. I identify the exact container, prior termination reason, cgroup limit, working set, events, previous logs and rollout timing. I distinguish a container cgroup limit from node-wide memory pressure, probe-induced termination, explicit kill, and a sidecar or configuration change. In Linux terms, I want the cgroup and process ownership boundary, not a host-wide average. Privileged mode changes the security boundary and is unrelated to memory ownership, so I refuse it unless there is a separate approved need. I change a request/limit or application behavior only after evidence, keep the rollback small, and verify bounded workload behavior, restart count, latency and error objectives. Prevention may include memory profiling, a realistic limit based on observed working set plus headroom, load tests, and alerting before repeated OOM termination.

**Weak answer:** "Just double the limit." That may move the fault to the node, hide a leak, or allow one tenant to consume capacity needed by others.

**Senior follow-up:** Why can a successful local test be misleading? Local cgroups, traffic shape, cache warmness, kernel version, sidecars and scheduling pressure may differ. A useful test states which of those it controls and which it does not.

## Scenario 4: disk is free but writes fail

**Question:** An API fails to write uploads with `ENOSPC`; `df -hT` on the path shows plenty of free bytes. Walk through safe remediation.

**Strong answer:** `ENOSPC` says an allocation failed; it does not say which allocatable resource is unavailable. On the exact failing path I check `df -hT` for mount and data-block capacity and `df -i` for inode capacity. I map the application path through its namespace, volume, writable layer or quota, because host free space may be irrelevant. If inode usage is exhausted, many filesystem objects consumed the metadata records needed to create another file; deleting a large file may free bytes but only one inode. Before removal I identify the producer, age/retention rule, owner, legal/security constraints and safe bounded target. I remove only approved objects, recheck the exact path, retry a real authorized write, and confirm retained data and cleanup. Prevention is an inode/block/quota headroom signal, retention enforcement, cache cardinality bound and a tested cleanup procedure.

**Weak answer:** "Delete `/tmp` and restart the container." That guesses the path, may delete evidence or another workload’s data, and does not prove the failing mount has recovered.

**Senior follow-up:** What other causes still fit? Per-user/project quota, a read-only remount, overlay writable-layer limit, a full tmpfs, reserved blocks, permissions that are being reported poorly by an application, or a file descriptor/temporary-file behavior. Each needs its own evidence.

## Scenario 5: process has files deleted but disk does not recover

**Question:** You deleted a 20 GB log file and `df -h` still shows the space used. Why?

**Strong answer:** A pathname deletion removes a directory entry; it does not necessarily free file blocks while a process still holds an open file descriptor. I confirm the exact filesystem/path and use an approved inspection such as `lsof +L1` or `/proc/<pid>/fd` to find deleted-but-open files and their owning process. I do not truncate arbitrary descriptors or restart broad services blindly. I decide with the service owner whether a safe log reopen, graceful reload, controlled restart or bounded descriptor operation is appropriate, then verify the filesystem capacity and the user operation. Prevention includes log rotation that signals/reloads the owner correctly, disk headroom alerts, and a runbook that distinguishes pathname deletion from open descriptor lifetime.

**Weak answer:** "`rm` did not work, so the filesystem is corrupt." The filesystem may be behaving correctly: an open handle still owns the data.

**Senior follow-up:** What is the security concern? `/proc` and `lsof` can expose process arguments, paths and handles. Use least privilege, minimize copied output, and avoid placing sensitive production information in tickets or chat.

## Scenario 6: permission denied after a deployment

**Question:** A service that worked yesterday now gets `permission denied` opening a configuration file. How do you debug safely?

**Strong answer:** I identify the exact process identity, path and operation. Permission is not only the final file mode: each parent directory requires traversal permission, and the effective user/group, ownership, ACLs, mount options, mandatory access controls and container namespace can matter. I inspect without changing state: `id` for the execution identity, `namei -l <path>` for every path component, `stat` for owner/mode, `getfacl` where ACLs are used, and service/container security context. I compare a known-good revision and deployment diff. I do not solve it with `chmod 777` or root because that removes the security boundary instead of explaining it. I apply the smallest ownership/mode/ACL/configuration correction consistent with least privilege, then verify the intended read and an unrelated forbidden read still fails.

**Weak answer:** "Give the service sudo." A service identity with broad privilege turns a configuration mistake into a wider compromise path.

**Senior follow-up:** What does `chmod 644 file` not solve? Missing execute/traverse permission on a parent directory, wrong owner/group, ACL denial, a read-only mount, SELinux/AppArmor policy, wrong namespace path, or a process running as a different identity.

## The command map: question before command

| Question | Useful first evidence | What it can prove | What it cannot prove alone |
|---|---|---|---|
| Is systemd supervising a process? | `systemctl status unit` | unit state, recent status summary | request success or dependency health |
| What did this unit report near the failure? | `journalctl -u unit --since ...` | messages retained by the journal | complete application truth or user impact |
| Is CPU actually the limiting resource? | `vmstat 1 5`, `pidstat`, `iostat -xz 1 5` | sampled runnable/I/O/owner evidence | an exact root cause from one sample |
| Which mount owns the failing path? | `findmnt -T path`, `df -hT path` | mount and block capacity for that path | inode, quota or namespace behavior |
| Are inode records exhausted? | `df -i path` | inode capacity for that mount | which files are approved for deletion |
| Does an open deleted file retain blocks? | `lsof +L1` | observed deleted/open descriptor candidates | safe restart or retention policy |
| Which identity crosses every path component? | `id`, `namei -l path`, `stat`, `getfacl` | identity and access metadata | the correct least-privilege remediation |

## Practice method that builds recall

Choose one scenario. Spend two minutes speaking without opening the model answer. Then compare your answer against five checks:

1. Did you state a user operation, scope, time window and healthy comparison?
2. Did every command answer a specific question and include a proof limit?
3. Did you keep at least one competing mechanism alive until evidence removed it?
4. Was your containment small, reversible and authorized?
5. Did recovery include a real user operation and a prevention control?

Repeat a week later with one changed constraint: a container instead of a host, a read-only incident instead of a write incident, a shared mount instead of a local disk, or a customer symptom instead of a dashboard alert. A strong engineer adapts the reasoning chain; they do not repeat the same command list.
