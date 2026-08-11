# Containers and OCI: isolate a process, not the responsibility

An image is an immutable artifact made of layers and metadata. A container is a process launched from that image with namespaces, cgroups, mounts, capabilities, and a runtime policy. It is not a VM and it is not automatically secure.

```text
image config/layers -> runtime create -> namespaces/cgroups/mounts -> process -> user outcome
       |                  |                  |                         |
    digest           identity            limits/policy              logs/exit
```

## Image and runtime boundaries

Pin image digests where trust matters, minimize layers and packages, record provenance, and scan the artifact. At runtime verify user, root filesystem, mounts, capabilities, network, resource limits, and signal/exit behavior. A clean image scan does not prove safe runtime configuration.

## Non-root and least privilege

Run as a non-root UID, use a read-only root filesystem where possible, drop unnecessary capabilities, avoid host mounts and privileged mode, and bound CPU, memory, processes, and file descriptors. Each restriction should have an observable reason and a tested compatibility path.

## Namespaces and cgroups

Namespaces isolate views of processes, mounts, networking, users, and more. Cgroups bound and account for resource use. Neither creates a complete security boundary against every kernel or runtime flaw; keep the host and runtime patched and treat container escape as a high-severity event.

## Safe local exercise

Use a pinned, local image or existing fixture with no network, no host mounts, a temporary writable path, non-root user, read-only root, and resource ceilings. Inspect the container descriptor before start, run a harmless command, verify identity and limits, then stop and remove only the known fixture. If Docker/WSL is unavailable, inspect the Dockerfile and expected descriptor without claiming runtime evidence.

## Triage sequence

1. Identify image digest, runtime, user, mounts, capabilities, network, and limits.
2. Separate build/image defects from runtime policy and application failures.
3. Inspect exit code, signal, logs, health, cgroup pressure, and filesystem behavior.
4. Contain unsafe privilege or exposure without adding broad permissions as a shortcut.
5. Verify user outcome, cleanup, and descriptor parity after the fix.

## Interview defense

**Question:** “Why did a non-root container still access sensitive data?”

**Strong answer:** “Non-root reduces one privilege path but does not protect an exposed host mount, secret, network, capability, or application authorization flaw. I inspect mounts, namespaces, capabilities, identity, policy, and data access at every boundary.”

**Question:** “A container exits 137. What does that prove?”

**Strong answer:** “It indicates a SIGKILL-style exit commonly associated with memory pressure, but I confirm cgroup limits, kernel/runtime events, host pressure, and application logs. I do not conclude OOM from the number alone.”

## Teach-back checkpoint

Explain image versus container, namespaces versus cgroups, non-root limitations, and the evidence needed before changing a runtime restriction.
