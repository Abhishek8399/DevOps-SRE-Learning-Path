# Product-company readiness audit: prove judgment across unfamiliar systems

Product companies do not need someone who remembers the most commands. They need an engineer who can enter an unfamiliar system, find the failing boundary, reduce user harm safely, and leave the system easier for the next operator.

This audit is a practice system, not a readiness certificate. You pass a practice case only for the evidence you produced in that case. A different system, scale, team, or failure can change the result.

```text
DIAGNOSE -> BUILD -> OPERATE -> EXPLAIN -> TRANSFER
    |          |         |          |           |
 evidence    tests     recovery   trade-offs   changed case
```

## The five gates

| Gate | Demonstration | Immediate failure condition |
|---|---|---|
| Diagnose | Bound impact, map the request, form alternatives, choose discriminating evidence | Guesses a component from one symptom |
| Build | Implement a small maintainable change with tests and explicit errors | Copies a solution without explaining its contract |
| Operate | Contain safely, preserve evidence, verify user recovery, clean up | Restarts/deletes/scales before bounding impact |
| Explain | Describe mechanism, decision, proof limit and remaining risk | Lists tools or reports “green” without user proof |
| Transfer | Solve a changed scenario without hidden answers | Repeats memorized steps after the boundary changes |

A high score in four gates cannot hide a safety failure in the fifth. Root on a shared host, real credentials in a lab, destructive cloud changes, fabricated metrics, or unapproved production mutation ends the attempt.

## Company emphasis without skipping the foundation

The supplied profiles share the five gates but emphasize different systems:

| Role family | Deepen after shared foundation | Defensible local evidence |
|---|---|---|
| Apple | Data/ML platforms, hybrid batch/stream operations, tiered stores, zero-downtime delivery | Pipeline replay/recovery, data contract, serving SLO, guarded automation |
| Experian | AWS operations, SLOs, observability, incident response, DR | Provider-neutral AWS model, alert/runbook, restore evidence, incident timeline |
| Mastercard | AWS/EKS, Kubernetes production operations, automation, on-call | Platform capstone, rollout/rollback, capacity/IP diagnosis, RCA |
| Cisco | Private cloud, virtualization, networking, storage control planes | KVM/OpenStack/Ceph/OVN architecture and bounded failure simulation |
| Visa | Payments/data reliability, security, distributed operations | State/consistency analysis, audit boundary, resilient data-flow design |
| GitLab | CI compute, Kubernetes, automation, developer platforms | Runner queue/isolation model, golden path, artifact provenance, upgrade plan |
| NVIDIA | On-prem Kubernetes, CI fleets, compute scheduling, Python/Go, databases | Scheduling/capacity case, CI worker lifecycle, observable automation |
| Arm | Infrastructure, virtualization, Kubernetes and delivery foundations | Reproducible platform design, workload isolation, safe lifecycle operations |
| ADP | AWS, Linux/Windows, IaC, configuration management, networking, databases | Terraform plan review, Ansible idempotency, hybrid request-path diagnosis |

These are emphasis choices, not nine separate careers. Linux, networking, code, delivery, observability, incidents, security, and communication remain common dependencies.

## Run one ninety-minute audit loop

Choose an unseen scenario from `/practice/interview` or ask a reviewer to change one capstone constraint. Do not reveal the answer first.

### Minute 0–10: establish the contract

Write:

- user operation and visible impact;
- affected and healthy populations;
- start time and recent change window;
- safety boundary and mutation authority;
- recovery condition.

“Pods are failing” is not impact. “Checkout POST requests in region A return 503 for version B while reads and region C remain healthy” is bounded enough to investigate.

### Minute 10–30: make a system map

```text
client -> name -> route -> policy -> listener -> workload -> dependency -> state
                         ^ control plane ^
source -> CI -> artifact -> desired state -> reconciler -> telemetry
```

Name identity at every boundary: request ID, hostname, IP/port, certificate, workload revision, artifact digest, configuration version, database/queue authority, and time source. Then write at least three hypotheses and one observation that would weaken each one.

### Minute 30–50: collect or specify evidence

Use commands and queries only when you can predict their useful branches. For every check state:

```text
question -> command/query -> expected branches -> meaning -> next evidence -> proof limit
```

For example, `df -hT PATH` answers block allocation for the filesystem backing that resolved path. It does not answer inode exhaustion, quota, another mount namespace, application retention, or host-wide capacity. `df -i PATH` answers inode allocation on that filesystem; it does not identify which producer created the objects.

### Minute 50–65: contain and recover

Choose the smallest reversible action supported by evidence. Name blast radius, approver, abort condition, rollback, and observation window. Recovery must include the original user operation and dependency stability—not only process, Pod, pipeline, or deployment status.

### Minute 65–80: prevent recurrence

Connect the prevention to the mechanism. “Add monitoring” is incomplete. Define signal, population, threshold/window, missing-data behavior, owner, response, test, and expected risk reduction. A post-incident action passes only when its control works and later evidence shows the mechanism is reduced.

### Minute 80–90: explain and transfer

Give a two-minute answer using:

```text
impact -> scope -> evidence -> mechanism -> containment -> recovery -> prevention -> limit
```

Then change one boundary: ten times traffic, a regional failure, stale telemetry, non-reversible schema, compromised credential, or a shared multi-tenant dependency. Solve again without copying the first action.

## Scoring rubric

Score each dimension 0–3 only after preserving the response.

| Dimension | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| Scope | component guess | vague impact | bounded user/system scope | includes healthy comparison and uncertainty |
| Evidence | command dump | relevant check | predicted branches and proof limit | alternatives actively discriminated |
| Mechanism | symptom repeated | single guess | causal path | state, timing and amplification explained |
| Safety | unsafe mutation | caution only | bounded reversible action | authority, abort, rollback and evidence preservation |
| Recovery | component green | partial service check | user journey verified | stability window and downstream correctness |
| Prevention | generic alert | plausible task | mechanism-linked tested control | owner, effectiveness and residual risk |
| Communication | tool list | chronological dump | concise decision narrative | audience-aware uncertainty and trade-off |
| Transfer | repeats answer | notices change | adapts investigation | redesigns model and names new evidence |

Maximum is 24. A score of 18 with no zero is a useful practice threshold, not professional certification. Require a reviewer for any readiness statement. Repeat after at least seven days with a changed scenario; immediate repetition mostly measures memory.

## Evidence packet

Keep one folder per attempt containing:

- scenario and hidden changed constraint;
- timestamped response before answer reveal;
- system map and hypotheses;
- command/query contracts;
- containment and recovery decision;
- reviewer rubric with disagreements;
- corrected answer;
- delayed-transfer result;
- links to authentic project evidence when referenced.

Never store credentials, customer data, employer-internal details, interview recordings without consent, or claims you cannot disclose. Browser-local completion markers are reading conveniences and are not this packet.

## Detailed interview answers

### What makes someone senior if AI can generate commands?

Senior judgment appears before and after the command: selecting the right boundary, recognizing incomplete evidence, understanding state and authority, controlling blast radius, deciding when not to mutate, verifying the customer operation, and accepting residual risk explicitly. AI can propose hypotheses quickly; the engineer remains accountable for evidence quality and consequences.

### Do I need real cloud resources to pass?

No for learning mechanisms; yes for claims about provider runtime behavior. A local model can prove your reasoning, contracts, tests, and safe automation. It cannot prove IAM propagation, managed-control-plane behavior, quotas, regional failure, billing, or production scale. State that boundary and use official/provider evidence only when authorized later.

### When should I apply for a role?

Apply when the shared foundation is defensible, one target emphasis has deep project evidence, and you can complete unfamiliar diagnose-operate-explain-transfer loops safely. Do not wait for every product keyword. Also do not treat reading percentage as readiness: use reviewed evidence packets and honest portfolio claims.

### What is the next action after a weak result?

Fix the earliest failed gate. If scope was vague, practise user-journey framing. If evidence was a command dump, write expected branches. If recovery was component-only, add end-to-end verification. If transfer failed, change constraints and rebuild the causal model. Re-reading everything is slower than repairing the exact reasoning gap.
