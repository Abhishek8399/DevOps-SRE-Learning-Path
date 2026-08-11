# DevOps, SRE, and Platform Interview Playbook

This is a practice aid, not a promise of employment or interview readiness. Use it after attempting the question aloud. A polished paragraph that was never reasoned through is not evidence.

## The answer shape interviewers can trust

For an incident or design question, use **IMPACT → SCOPE → EVIDENCE → MECHANISM → CONTAINMENT → RECOVERY → PREVENTION**.

1. **Impact:** Who is failing, what user operation is broken, and since when?
2. **Scope:** Region, tenant, version, dependency, request class, and healthy comparison.
3. **Evidence:** Name the next command, query, dashboard, trace, packet, or log and what it can and cannot prove.
4. **Mechanism:** Connect the evidence to a causal mechanism; keep competing hypotheses visible.
5. **Containment:** Choose the smallest reversible action that reduces customer harm.
6. **Recovery:** Verify both infrastructure health and the real user journey.
7. **Prevention:** Remove the mechanism, improve detection, document ownership, and test the control.

Weak answers jump from symptom to restart, deletion, privilege escalation, or “scale it up.” Strong answers control blast radius and explain proof limits.

## Scenario 1 — ENOSPC with free disk

**Question:** An upload container reports `ENOSPC`, but the host has 200 GB free. What do you do?

**Strong answer:** I first establish the exact failing path, container, mount, time window, and customer impact. I inspect `df -hT <path>` for block capacity and `df -i <path>` for inode capacity, then check quota, writable-layer limits, and the container’s mount namespace. If inodes are exhausted, many small files—not one large file—are consuming filesystem objects. I identify the producer and retention policy before removing only approved data, then repeat the upload and verify inode/block recovery. I do not conclude that host free space is relevant until I map the container path to its actual backing filesystem.

**Weak-answer warning:** “Delete the largest file and restart.” That may delete evidence, free one inode, and leave the producer creating files.

**Senior follow-up:** How do you prevent recurrence? Alert on inode and block headroom for the exact mount, bound cache cardinality, enforce retention, and test cleanup under the same mount and identity used by the service.

## Scenario 2 — selective large-response failure

**Question:** Small HTTPS responses work across a routed boundary; large responses fail. How do you debug it?

**Strong answer:** I compare affected and healthy paths by payload threshold, direction, client, route, and time. I trace DNS, route choice, MTU, TCP retransmission, PMTUD/ICMP behavior, TLS termination, proxy buffering, load-balancer limits, and NAT state. I capture evidence at both sides of the boundary or use a bounded synthetic request, then test the smallest reversible control path. A mitigation might temporarily adjust a verified MTU or proxy limit for a narrow scope, followed by success/error and latency verification.

**Weak-answer warning:** “The firewall is dropping packets.” That names a component without proving it.

**Senior follow-up:** What would disprove an MTU hypothesis? Equal-sized failures on a same-host loopback path, no retransmissions or fragmentation symptoms, and a proxy error with complete packets arriving at the backend.

## Scenario 3 — green availability, failed customers

**Question:** The global availability dashboard is green, but one region reports failed checkouts.

**Strong answer:** I define the checkout journey and its valid population before trusting the aggregate. I compare regional black-box probes with gateway, service, dependency, and client-side signals; check missing telemetry, sampling, label cardinality, clock skew, and aggregation windows; and establish a healthy-region comparison. I contain traffic or disable the faulty route only if the evidence supports it. Recovery means a successful customer transaction, not merely green CPU or API metrics. Prevention is a journey SLI, regional alert, telemetry-health signal, owner, and runbook.

**Weak-answer warning:** “The dashboard is green, so the report is probably user error.”

**Senior follow-up:** What does a green SLI prove? Only that the selected query, population, window, and data pipeline met its objective; it says nothing about excluded or missing traffic.

## Scenario 4 — Kubernetes pods restart with healthy nodes

**Question:** Pods exit 137 while node CPU and memory look healthy. The team proposes privileged mode and larger limits.

**Strong answer:** Exit 137 is a symptom of SIGKILL, commonly but not exclusively an OOM kill. I identify the killed process and cgroup, compare container working-set and limit evidence, inspect pod events and previous logs, and distinguish node pressure from a container limit. I check ephemeral storage, probes, sidecars, and rollout timing. I restore with a scoped limit or workload correction only after evidence, and I refuse privilege escalation because it changes security boundaries without addressing memory ownership.

**Weak-answer warning:** “Increase limits until it stops.” That can move failure to the node or hide a leak.

**Senior follow-up:** How do you validate? Reproduce under a bounded load, observe cgroup pressure and restart counters, verify latency/error objectives, and retain a rollback path.

## Scenario 5 — Terraform plan wants replacement

**Question:** A harmless-looking Terraform change proposes replacing a stateful database.

**Strong answer:** I stop before apply. I inspect the plan, resource lifecycle rules, provider version, state address, configuration drift, and immutable arguments. I compare the intended change with the remote object and review whether a moved block, import, lifecycle guard, or provider upgrade explains the replacement. I run `terraform fmt`, `validate`, and a targeted plan, then obtain an approved backup/restore and rollback plan before any destructive action.

**Weak-answer warning:** “Apply with `-auto-approve` because the diff is small.” A small diff can have a large blast radius.

**Senior follow-up:** What proves the backup is useful? A recent restore test into an isolated target with measured RPO/RTO—not the existence of a backup object.

## Scenario 6 — retry storm

**Question:** A dependency slows down and every service begins retrying, making it worse.

**Strong answer:** I quantify request rate, timeout, retry multiplier, queue depth, and dependency capacity. I stop amplification with bounded deadlines, exponential backoff with jitter, retry budgets, idempotency, circuit breaking, admission limits, and graceful degradation. I preserve a healthy comparison and verify customer impact after each scoped change. Prevention includes ownership of retry policy and a load test that exercises dependency slowdown.

**Weak-answer warning:** “Add more retries for reliability.” Retries are load, not free resilience.

**Senior follow-up:** When should a request not retry? When the operation is non-idempotent, the deadline is nearly exhausted, the error is permanent, or the dependency has signaled overload.

## Scenario 7 — secrets or tokens in logs

**Question:** A log search reveals bearer tokens and payment data.

**Strong answer:** I treat it as a security incident: restrict access and retention, preserve an audit trail, rotate or revoke exposed credentials, identify the affected population and destinations, and stop further emission with a tested redaction or schema change. I verify redaction at source, transport, index, export, backup, and query layers; then review notification and regulatory obligations with the security owner.

**Weak-answer warning:** “Delete the log index.” That may destroy evidence and leave copies in exports or backups.

**Senior follow-up:** What is the proof boundary of a redaction unit test? It proves the tested inputs and code path, not every producer, format, downstream copy, or historical record.

## Scenario 8 — platform engineering design

**Question:** Design an internal developer platform for many product teams.

**Strong answer:** I start with a painful, measurable developer journey and define the platform product’s users, golden path, ownership, reliability targets, security boundaries, and escape hatches. I provide self-service templates and APIs with policy guardrails, observable workflows, versioned contracts, safe upgrades, cost attribution, and support/runbook paths. I measure lead time, failed changes, recovery time, adoption, toil, and satisfaction without forcing every team into one architecture.

**Weak-answer warning:** “Build a portal with every tool.” A catalog is not a platform product unless it reliably removes user toil.

**Senior follow-up:** How do you avoid platform capture? Publish an explicit contract, support migration and exit paths, measure outcomes, and treat the platform as a service with a roadmap and error budget.

## Five-minute practice rubric

Score each answer from 0–2:

| Dimension | 0 | 1 | 2 |
|---|---|---|---|
| Impact and scope | jumps to a tool | names some scope | states user impact, boundary, time, and comparison |
| Evidence | command dumping | one useful check | predicts evidence and its proof limit |
| Causality | correlation as cause | one hypothesis | mechanism plus alternatives and disproof |
| Safety | broad/destructive change | vague caution | reversible, approved, bounded containment |
| Recovery | “looks green” | partial check | user journey plus system verification |
| Prevention | generic monitoring | one alert | mechanism removal, ownership, test, and runbook |

Do not call a score mastery. Repeat the same scenario later with a changed boundary and have another engineer review the evidence.
