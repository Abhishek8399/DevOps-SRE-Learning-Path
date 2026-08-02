# LES-0023 lab: inspect the container contract safely

This lab makes a container's real boundaries visible: one cached image, one exact container, host-kernel processes, namespaces, cgroups, a read-only image-root view, two bounded tmpfs mounts, PID 1 signal behavior, health state, logs, and lifecycle cleanup.

It never pulls or builds. It uses only this exact image if it is already cached:

```text
busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662
```

If Docker Desktop, Ubuntu WSL integration, or that digest is unavailable, stop. `verify.sh` reports `runtime_verification=blocked` after static Bash checks. Do not install, start, reconfigure, sign in, or pull during an independent attempt.

## Environment card

| Item | Contract |
|---|---|
| Platform | Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with an already-operational Docker Desktop Linux engine |
| Identity | Normal user only; lab and verifier refuse effective UID 0 with exit 77 |
| Image | Exact pinned BusyBox digest above, already cached; every run uses `--pull=never` |
| External network | None; container uses `--network none`, publishes no port, and the controller makes no registry request |
| Host/daemon changes | One labeled container named `reliability-atlas-les0023-u<uid>` plus four possible mode-0600 `/tmp/reliability-atlas-LES-0023-<uid>.*` records |
| Container access | User `65534:65534`, privileged false, all capabilities dropped, no-new-privileges, no bind/device/socket mounts |
| Filesystem | Read-only root filesystem; `/run` 1 MiB tmpfs and `/work` 4 MiB tmpfs, both nosuid/nodev/noexec |
| Limits | 64 MiB memory and equal memory+swap ceiling, 0.25 CPU, 64 PIDs |
| Lifecycle | Restart policy `no`; three-second Docker stop timeout; shell PID 1 handles TERM/INT |
| Cleanup | Exact ID/name/image/label/config validation, exact `docker container rm --force`, exact local files; no wildcard/prune/system cleanup |

The Docker API controls daemon-managed processes, mounts, images, networks, and potentially the host VM. Treat Docker access as privileged even though this exercise creates a tightly constrained container. Never use this lab against a remote or production context. Check `docker context show` outside the lab if you are uncertain; stop rather than switching contexts during an assessment.

## What setup creates

```text
Ubuntu normal-user controller
  |
  +-- /tmp/reliability-atlas-LES-0023-<uid>.state
  |       lesson, UID, exact container ID/name, random instance token,
  |       exact image reference and local image ID
  |
  +-- optional .case / .recovery / .verification records
  |
  `-- Docker Desktop Linux daemon
          |
          `-- one exact labeled container
                image: cached digest only
                user: 65534:65534
                network: none; ports: zero
                rootfs: read-only
                writable: /run and /work tmpfs only
                caps: drop ALL; no-new-privileges
                limits: memory/CPU/PIDs
                PID 1: BusyBox sh signal-aware loop
```

The state descriptor is created through a random candidate and atomic hard-link registration, so an existing predictable pathname is never followed. Every action reloads the descriptor and compares the live container ID, image ID/reference, random label, UID label, security envelope, limits, mounts, ports, namespace modes, and health command. A same-name container is not enough.

## Preflight

From this directory:

```bash
bash lab.sh check
```

Ready output:

```text
lesson=LES-0023
runtime=ready
state=absent
image_cached=true
network=none
```

Blocked messages are deliberate:

- `docker-daemon-unavailable...`: Docker Desktop Linux engine or WSL integration is not available.
- `pinned-busybox-image-not-cached...`: the only permitted image is absent; the lab will not pull.
- `unregistered-container-name...`: a container already owns the deterministic name; the lab will not replace it.
- `unregistered-or-stale-local-artifact...`: local state exists without a valid registered lifecycle; preserve it and investigate.

Do not run `docker system prune`, `docker container prune`, wildcard removal, or manual `/tmp` deletion. Those commands have a larger target than this lesson can prove it owns.

## Guided exercise: running is not healthy

### 1. Create the hardened container

```bash
bash lab.sh setup
bash lab.sh status
```

Setup refuses any pull with `--pull=never`. The process writes `/run/ready`, emits `event=start pid=1 uid=65534`, and loops. Docker's health command checks only whether the marker exists.

### 2. Inspect every owner

```bash
bash lab.sh observe image
bash lab.sh observe runtime
bash lab.sh observe filesystem
bash lab.sh observe limits
bash lab.sh observe process
bash lab.sh observe network
bash lab.sh observe health
bash lab.sh observe logs
```

Read the scopes:

- `image` comes from the daemon's local content metadata: image ID, architecture, OS, rootfs type and layer count. It does not prove registry trust or currently running configuration.
- `runtime` comes from this container record: state, exit, OOM flag, command and host config.
- `filesystem` shows graph-driver name, read-only root flag, tmpfs policy and `docker diff`. Tmpfs changes are mounts, not image-layer changes.
- `limits` shows configured bytes, nano-CPUs and PID cap, then cgroup-v2 files when available. Configuration is not usage.
- `process` shows host-visible process IDs through Docker. Inside PID 1 is namespaced; host PID is different.
- `network` proves mode `none`, zero published ports and the container's visible interface counters. It does not prove the daemon/host has no network.
- `health` reports the probe predicate. It does not prove user work.
- `logs` are captured stdout/stderr evidence, not durable business state.

### 3. Inject a shallow-health failure

```bash
bash lab.sh inject guided
bash lab.sh status
bash lab.sh observe health
bash lab.sh observe process
```

The controller removes only `/run/ready` from the bounded tmpfs. Docker eventually reports unhealthy while the workload remains running. Remember:

```text
running = PID 1 currently exists
healthy = configured probe currently passes
ready   = orchestrator-specific decision to receive traffic
useful  = real user work is progressing correctly
```

These states are related but not identical. Docker Engine records health; it does not automatically restart an unhealthy container under restart policy `no`.

### 4. Recover, verify, clean

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
```

Verification proves the container returned running/healthy, runs as UID 65534, refuses a root-filesystem write, permits and removes one exact `/work` tmpfs probe, retains network `none`, and emitted the expected PID 1 start event. Cleanup revalidates ownership before forcing removal; `--force` is bounded to the exact ID/name profile and exists to stop the controlled process, not as a generic production recommendation.

## Independent exercise: PID 1 and graceful stop

Start clean:

```bash
bash lab.sh setup
bash lab.sh inject independent
bash lab.sh scenario
```

Copy the raw scenario into `ASM-0054-response-template.md` before any observation. It contains configured inputs but no derived state, exit, received-signal, health, diagnosis, recovery, or outcome.

Write at least three hypotheses. Examples of hypothesis **forms**, not answers:

1. the intended PID 1 handled the stop contract;
2. a wrapper swallowed or failed to forward the signal;
3. the grace window expired and the runtime escalated.

Predict how state, exit code, logs, process table, OOM flag and restart count would distinguish them. Then collect the minimum views:

```bash
bash lab.sh observe runtime
bash lab.sh observe process
bash lab.sh observe health
bash lab.sh observe logs
bash lab.sh observe filesystem
bash lab.sh observe limits
```

Write a bounded recovery card before:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash verify.sh
```

The full verifier runs both cases and also tests invalid transitions, descriptor tampering, a symlink toward an external canary, a foreign same-name container, answer isolation, idempotent cleanup, and final absence. It never pulls.

## Evidence questions

1. Why is the container a group of host-kernel processes rather than a VM?
2. Which identifiers name an image reference, content, a container, a process, and a user job?
3. Why can the container be running but unhealthy?
4. Why does the health probe not prove useful work?
5. What special responsibilities does PID 1 have for signals and orphaned children?
6. Why does shell-form `ENTRYPOINT` often create a signal-forwarding problem?
7. What belongs to immutable layers, the container writable layer, tmpfs and a volume?
8. Why can a read-only root filesystem still support temporary work?
9. What do memory/CPU/PID settings limit, and what do they not measure?
10. Why is a digest different from a signature, SBOM, provenance and scan?
11. Why is Docker socket access a large privilege boundary?
12. What exactly does cleanup prove?

Complete explanations are in LES-0023. The independent assessment still requires a reviewer.

## Runtime-blocked path

If `bash verify.sh` prints:

```text
static_verification=passed
runtime_verification=blocked
reason=docker-daemon-unavailable
network_pull_attempted=false
cleanup_proven=not-exercised
```

or `reason=pinned-busybox-image-not-cached`, that is an honest gate result. Static Bash syntax passed, but no runtime or cleanup claim exists. Record it and stop. Later, outside the independent assessment, an authorized owner may decide how Docker/image prerequisites are provisioned. This lab never tells you to pull.

## Scope limits

Even a fully passing run proves only this local Docker daemon observed one constrained BusyBox container and the tested transitions. It does not prove the cached image is trustworthy, Docker Desktop is secure, seccomp rules are identical everywhere, the host kernel has no vulnerability, overlay performance matches production, a volume is durable, Kubernetes behavior is identical, or the learner has mastery.
