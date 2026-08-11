# CI runner platforms: make delivery compute trustworthy

CI is a production platform for engineering work. A green pipeline is only useful when the runner was trusted, the inputs were controlled, the artifact is identifiable, and the result can be reproduced.

```text
commit -> scheduler/queue -> trusted runner -> build/test/scan -> artifact
   |          |                  |                    |            |
identity   fairness          isolation             evidence      digest
                                      |
                              cache + workspace lifecycle
```

## Separate control and execution planes

The control plane accepts events, authenticates callers, schedules jobs, stores metadata, and applies policy. The execution plane supplies workers, tools, network access, credentials, workspace, cache, and artifact upload. A control-plane green status does not prove the worker had the expected image, permissions, clock, disk, or dependency versions.

## Runner trust and isolation

Treat a runner as a short-lived host with a capability set. Define which repositories, tenants, networks, registries, secrets, and devices it can reach. Prefer ephemeral workers for untrusted or mixed workloads; scrub workspaces and caches, pin toolchains, and prevent a job from escaping through a host socket, privileged container, broad cloud credential, or mutable shared directory.

Caches improve speed but widen trust. Key them by lockfile/toolchain/platform and scope them to the least privilege that works. Never cache secrets or allow an untrusted job to influence a trusted release cache.

## Queue and capacity reasoning

Track queue age, admission rate, service time, concurrency, failure rate, worker startup time, and artifact throughput. Autoscaling workers cannot fix a registry bottleneck, quota, image-pull storm, exhausted IP range, or serial approval gate. Reserve capacity for urgent security/recovery work and use fair-queue or tenant budgets to prevent starvation.

## Safe local exercise

Model a queue with a small script: jobs have tenant, priority, duration, required label, and artifact size. Add two worker classes, a failing worker, a cache hit, and a registry outage. Record queue age, fairness, retries, and the point where adding workers stops helping. Then write the runner trust boundary, cleanup steps, artifact identity, and secret-handling policy. Label this as a scheduler model unless a real CI service is exercised.

## Triage sequence

1. Identify event, repository/ref, job, tenant, runner class, artifact, and user impact.
2. Check admission/authentication, queue/fairness, worker health and image, workspace/cache, network/dependencies, and artifact publication.
3. Distinguish a job failure from runner contamination, flaky dependency, capacity starvation, or control-plane delay.
4. Quarantine a suspect runner/cache, preserve logs and artifact metadata, and avoid rerunning a security-sensitive job blindly.
5. Reproduce on a clean worker, publish or revoke artifacts deliberately, and verify the downstream deployment/user path.

## Interview defense

**Question:** “How do you secure CI runners?”

**Strong answer:** “I separate control and execution planes, use least-privilege identities and ephemeral isolation, scope network and repository access, pin toolchains and artifact identities, protect caches and logs from secret leakage, scrub workspaces, and quarantine suspect workers. I verify provenance rather than trusting a green status.”

**Question:** “Why did adding runners not reduce queue time?”

**Strong answer:** “I check the bottleneck and queue class: admission, labels, worker startup, image pulls, registry, quotas, serial gates, dependency latency, or artifact upload. More workers help only when the constrained resource is worker execution capacity.”

**Question:** “How do you handle a flaky test?”

**Strong answer:** “Preserve the exact job, worker, commit, environment, logs, and dependency versions; classify deterministic versus timing/resource/environment failure; quarantine only with an owner and expiry; and fix or reproduce on a clean runner. Retrying until green is not reliability evidence.”

## Teach-back checkpoint

Design a multi-tenant runner platform. Name the trust boundary, worker lifecycle, queue signals, fairness rule, cache scope, artifact/provenance proof, secret boundary, capacity bottleneck, and response to a compromised runner.
