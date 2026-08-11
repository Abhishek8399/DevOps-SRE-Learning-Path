# Local lab engineering: learn production thinking without production blast radius

A local lab is not “a command playground.” It is a small, bounded system where you can create a failure, observe it, recover it, and prove what happened.

```text
learner -> declared hypothesis -> disposable boundary -> controlled fault
   ^                                               |
   |                                               v
teach-back <- evidence record <- observe <- recover + verify
```

## Boundary first

Declare what the lab may touch before running it: workspace path, ports, networks, volumes, CPU/memory limits, credentials (ideally none), and cleanup command. Prefer a non-root container or disposable VM. Never use a lab command that can silently target the host, a production kube-context, or a real cloud account.

Keep these scopes distinct:

* **Process scope:** a script or service on Ubuntu; fastest, but closest to the host.
* **Container scope:** isolated filesystem, network, and cgroups; excellent for repeatable application failures.
* **VM scope:** its own kernel, systemd, firewall, and disks; needed for host-sensitive lessons.
* **Cluster scope:** multiple workloads and controllers; useful for scheduling, networking, and reconciliation, but expensive in complexity.

Isolation is not magic. A bind mount, privileged flag, host network, Docker socket, or broad kubeconfig can cross the boundary. Inspect the actual command and effective identity before trusting the label “local.”

## Reproducibility contract

Every lab should state prerequisites, pinned or recorded versions, setup, expected healthy evidence, fault injection, expected symptom, collection commands, recovery, teardown, and a reset path. Capture commands and outputs in a dated evidence note. A green exit code is not enough: verify the user-visible behavior and the absence of leftover containers, volumes, processes, routes, and files.

## Safe local exercise

Build a tiny service lab with a health endpoint and a bounded temporary directory. Run it as a non-root user, set CPU/memory limits, disable unnecessary network access, and write a `runbook.md` containing:

```text
scope -> setup -> healthy proof -> fault -> observation -> remediation -> recovery proof -> teardown
```

Inject one reversible fault such as filling the bounded directory or stopping the process. Record `id`, `df -hT`, `df -i`, process identity, open files, logs, and the service response. Recover, rerun the health check, and prove cleanup. If Docker or WSL is unavailable, perform the same exercise with a clearly labeled shell-only simulation; do not claim container evidence.

## Evidence beats narration

For each claim, write the exact observation that would prove it:

* “The service is healthy” → a successful request plus dependency and log evidence.
* “The lab is isolated” → effective identity, mounts, network mode, limits, and target path.
* “The fix worked” → the original symptom is gone after the same reproduction, not merely a successful command.
* “Cleanup completed” → no owned process/container/volume remains and the workspace is unchanged outside the declared scope.

## Triage when a lab behaves strangely

1. Stop the fault injector and record the current state.
2. Check whether the command reached the intended boundary and identity.
3. Separate tool failure from service failure: runtime, image, mount, network, process, then application.
4. Recover or reset using the documented path; do not improvise destructive cleanup.
5. Compare the post-reset state with the healthy baseline and update the runbook.

## Interview defense

**Question:** “How do you make a local lab trustworthy?”

**Strong answer:** “I define the blast radius, use a disposable boundary with least privilege, record versions and prerequisites, make the fault deterministic and reversible, collect evidence before and after remediation, verify the user outcome, and test teardown/reset. I label simulations honestly when the real runtime is unavailable.”

**Question:** “Why did a container command affect the host?”

**Strong answer:** “I inspect bind mounts, privileged mode, host networking, Docker-socket access, effective UID, and the target path. Isolation is a configuration claim that must be verified, not inferred from the word container.”

## Teach-back checkpoint

Design a lab for an ENOSPC or failed-service incident. State its boundary, identity, allowed resources, healthy proof, fault, evidence commands, recovery proof, and teardown. Explain exactly which conclusions would remain unproven if the runtime were replaced by a simulation.
