# eBPF and kernel observability: see the boundary without guessing

eBPF lets a controlled program observe or act at kernel hooks without rebuilding the kernel. It is powerful because it can see scheduler, syscall, network, and storage context that application logs miss; it is dangerous when probe cost, permissions, data sensitivity, and version compatibility are ignored.

```text
user journey -> process/thread -> syscall -> kernel subsystem -> device/network
      |             |             |              |                |
    SLO        PID/cgroup      latency       queue/state       packet/IO
                               |
                     probe -> map/ring buffer -> aggregate -> evidence
```

## What a probe actually tells you

Choose the hook and population deliberately: process, thread, PID namespace, cgroup, device, socket, or interface. A syscall count is not user latency. A TCP retransmission is not automatically an application bug. A scheduler delay can be host contention, cgroup policy, lock contention, or a blocked dependency. Preserve timestamps, identity, kernel/runtime version, and sampling/aggregation rules.

Probe overhead and cardinality are production concerns. Prefer bounded histograms and aggregates, exclude secrets and payloads, cap map/ring-buffer size, and define an unload/rollback path. Loading a probe may require elevated capabilities; “read-only intent” does not mean harmless authority.

## Safe local exercise

If Ubuntu and an approved tool such as `bpftrace` or BCC are available, observe only your own process or cgroup: count `openat` calls, record a bounded syscall-latency histogram, or trace TCP connect outcomes. Start with a short duration, no payload capture, and a cleanup command. If eBPF tooling or kernel support is unavailable, use `/proc`, `strace` on a disposable process, or a documented synthetic trace and label it a substitute; do not claim kernel-hook evidence.

## Triage sequence

1. Define the user symptom and affected process/cgroup/device boundary.
2. Establish baseline and probe scope, version, permissions, sampling, and overhead.
3. Correlate kernel evidence with application logs, traces, queues, and resource limits.
4. Stop or narrow a probe if cost, privacy, or system impact increases.
5. Fix the mechanism, unload the probe, and verify the user journey and resource behavior again.

## Interview defense

**Question:** “When would you use eBPF?”

**Strong answer:** “When application telemetry cannot explain a boundary such as scheduler delay, syscall latency, socket behavior, or block I/O. I define the population and hook, bound overhead/cardinality, protect data, correlate with user SLIs and existing telemetry, and keep a tested unload path. A probe is evidence, not the diagnosis by itself.”

**Question:** “Why can a syscall trace mislead you?”

**Strong answer:** “It may capture the wrong process or namespace, include retries/framework noise, omit queueing outside the hook, or add overhead. I verify identity and timestamps, compare a baseline, aggregate safely, and correlate with the full request path.”

## Teach-back checkpoint

Design a short kernel-observability investigation for high API latency. Name the user SLI, hook, scope, evidence fields, privacy/overhead limits, correlation signals, stop condition, and proof that the remediation improved the user journey.
