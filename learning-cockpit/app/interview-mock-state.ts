export const mockRoles = ["SRE", "Platform engineer", "DevOps engineer", "Cloud engineer", "Infrastructure engineer", "Data platform engineer", "Engineering lead", "Systems architect"] as const;
export const mockAreas = ["Incident response", "Reliability", "Platform design", "Delivery security", "Networking", "Data systems", "Private cloud", "System design"] as const;

export type MockRole = (typeof mockRoles)[number];
export type MockArea = (typeof mockAreas)[number];

export type MockQuestion = Readonly<{
  id: string;
  role: MockRole;
  areas: readonly MockArea[];
  prompt: string;
  evaluator: string;
  strongAnswer: string;
  followUps: readonly string[];
}>;

export const mockQuestions: readonly MockQuestion[] = [
  {
    id: "sre-user-journey",
    role: "SRE",
    areas: ["Incident response", "Reliability"],
    prompt: "A service-level objective is green, but users in one region cannot complete checkout. Lead the first fifteen minutes.",
    evaluator: "Whether you start with user impact and evidence boundaries instead of trusting an aggregate dashboard.",
    strongAnswer: "State the affected journey, region, time window, and business impact. Compare regional black-box probes with service, dependency, and telemetry-pipeline signals. Preserve an incident timeline, contain the user path with the smallest reversible action, and verify recovery with a real regional journey. Then repair the SLI, alert, ownership, and runbook that allowed the blind spot.",
    followUps: ["Which missing-telemetry case could make the aggregate look healthy?", "What must be true before you change routing?"],
  },
  {
    id: "sre-error-budget",
    role: "SRE",
    areas: ["Reliability", "Delivery security"],
    prompt: "A team wants to release while its error budget is nearly exhausted. How do you make the decision and communicate it?",
    evaluator: "Whether you connect policy, risk, current evidence, reversibility, and customer impact.",
    strongAnswer: "Confirm the SLI population, objective window, burn rate, data completeness, and release risk. Apply the agreed policy rather than inventing a personal rule. If release proceeds, scope it, define rollback and user-impact signals, assign an owner, and record the exception. If it pauses, explain the customer-risk rationale and the evidence required to resume.",
    followUps: ["How can an invalid denominator distort the budget?", "What release guard would you automate next time?"],
  },
  {
    id: "sre-incident-command",
    role: "SRE",
    areas: ["Incident response", "Reliability"],
    prompt: "A checkout incident spans two regions. Error rate is falling after traffic reduction, but support still reports payment failures and two teams want to make different production changes. Lead the next ten minutes.",
    evaluator: "Whether you establish a safe decision system: user impact, role clarity, evidence discipline, mutation control, communication and customer-boundary recovery.",
    strongAnswer: "State the affected customer operation, regions, cohorts, start time, current error and latency evidence, known mitigation, and the next update time. Assign or confirm an incident commander, technical lead, communications owner and scribe; one person may hold more than one role only if the responsibilities stay visible. Freeze uncoordinated production changes long enough to create a single mutation queue. Ask each proposed change for its hypothesis, target, expected outcome, risk, rollback or abort condition, authority and confirming evidence. Prefer the smallest authorized reversible containment that protects checkout without hiding the investigation. Treat falling aggregate error as a clue, not closure: compare affected cohorts, payment outcomes, backlog and retries, then verify a safe end-to-end transaction and watch for delayed failures. Communicate what is known, unknown, changed and next, without inventing an ETA or root cause. Preserve the timeline and decision log for the review.",
    followUps: ["What should make you keep the incident open after the main alert turns green?", "How do you prevent the incident commander from becoming the only debugger or approver?"],
  },
  {
    id: "platform-golden-path",
    role: "Platform engineer",
    areas: ["Platform design", "Delivery security"],
    prompt: "Developers bypass your deployment platform because it feels slower than their scripts. What do you investigate before redesigning it?",
    evaluator: "Whether you treat a platform as a product with measurable user outcomes and safe boundaries.",
    strongAnswer: "Map the developer journey and measure where time, uncertainty, or missing capability causes bypass. Separate mandatory safety controls from accidental friction. Compare the scripted path and platform path for inputs, ownership, auditability, rollback, and support cost. Improve the golden path with a small tested change, publish its contract, and measure adoption plus delivery and reliability outcomes.",
    followUps: ["Which control must not be removed just to improve adoption?", "How would you detect a harmful self-service action?"],
  },
  {
    id: "platform-kubernetes",
    role: "Platform engineer",
    areas: ["Platform design", "Incident response"],
    prompt: "A namespace repeatedly enters CrashLoopBackOff after a configuration rollout. How do you separate application, platform, and policy causes?",
    evaluator: "Whether you reason from desired state through admission, scheduling, runtime, and observable user effect.",
    strongAnswer: "Start with the exact workload revision, affected pods, events, configuration identity, and recent changes. Check admission and policy decisions, resolved configuration, image and command, scheduling, resource limits, probes, and logs from the failing container. Compare a known-good revision, roll back only with a clear boundary, and verify readiness plus the user operation. Capture the owning team and prevention control rather than assigning blame from one symptom.",
    followUps: ["What does a ready Pod not prove?", "What evidence distinguishes a bad Secret mount from an OOM kill?"],
  },
  {
    id: "devops-supply-chain",
    role: "DevOps engineer",
    areas: ["Delivery security", "Reliability"],
    prompt: "A pipeline is fast but uses mutable tags, shared credentials, and an unreviewed deployment script. What would you change first?",
    evaluator: "Whether you prioritize trust boundaries and reversible delivery rather than adding tools blindly.",
    strongAnswer: "Draw the build-to-production trust path. Replace mutable inputs with pinned source and artifact identities, use short-lived least-privilege credentials, protect deployment approvals and environments, and make artifact provenance and rollback discoverable. Add controls incrementally with failure tests so the pipeline still delivers safely, then monitor lead time, failed changes, and bypass attempts.",
    followUps: ["Which identity should authorize production deployment?", "Why is an SBOM useful but insufficient on its own?"],
  },
  {
    id: "cloud-networking",
    role: "Cloud engineer",
    areas: ["Networking", "Incident response"],
    prompt: "A private workload can resolve a database hostname but times out on the connection. Give your evidence-driven path.",
    evaluator: "Whether you separate name resolution from the packet and authorization paths.",
    strongAnswer: "Confirm the exact source identity, destination address and port, affected paths, and time window. Resolution only proves a name answer. Trace route selection and return path, security groups or firewalls, network ACLs, private endpoint or proxy behavior, TLS expectations, database listener and authentication. Use safe comparison traffic and flow or connection evidence before a scoped reversible change; verify an authorized application transaction after recovery.",
    followUps: ["What can a successful TCP handshake still fail to prove?", "How does asymmetric routing change your evidence plan?"],
  },
  {
    id: "sre-data-freshness",
    role: "SRE",
    areas: ["Reliability", "Data systems"],
    prompt: "A dashboard job is green, but finance reports that daily revenue is twelve percent low. Lead the investigation without corrupting the published data.",
    evaluator: "Whether you separate scheduler/process success from data correctness, preserve evidence, and make replay or backfill safe.",
    strongAnswer: "Freeze or clearly label the suspect publication according to its contract, then capture the run, code, configuration, input partitions, row counts, checksums, interval semantics and a healthy comparison. Trace source completeness, schema changes, filters, joins, deduplication and atomic publish boundaries. Reproduce the smallest affected interval in an isolated path, repair the identified contract, and backfill only with explicit identity and reconciliation. Verify the result against an independent authoritative control, not the same derived table.",
    followUps: ["Why does a successful scheduler state not prove correct output?", "What makes a replay safe for an external side effect?"],
  },
  {
    id: "platform-policy-exception",
    role: "Platform engineer",
    areas: ["Platform design", "Delivery security"],
    prompt: "A revenue-critical team is blocked by a new admission policy and asks you to disable it globally. How do you decide?",
    evaluator: "Whether you keep a security boundary explicit while offering a bounded, operationally realistic recovery path.",
    strongAnswer: "Identify the exact policy revision, rejected object, intended invariant, workload need, affected scope, owner and deadline. Determine whether the policy is wrong or the workload violates a real boundary. Prefer the smallest reversible correction: fix configuration, create a scoped approved exception with expiry and compensating controls, or roll back only the defective policy revision. Verify both the service journey and the security control after the change. Improve dry-run coverage, error messages, compatibility tests and exception lifecycle so urgency does not become permanent broad access.",
    followUps: ["What fields make an exception auditable?", "Why is global enforcement-off a dangerous diagnostic action?"],
  },
  {
    id: "devops-migration-release",
    role: "DevOps engineer",
    areas: ["Delivery security", "Reliability"],
    prompt: "A canary release includes a database migration. Error rate is low, but p99 latency and connection saturation rise. Promote, roll back, or do something else?",
    evaluator: "Whether you reason about compatibility, database authority, progressive-delivery evidence, and the limits of rollback.",
    strongAnswer: "Pause promotion and establish whether the latency and pool saturation are a release-induced risk to the user journey. Map schema/data change type, old/new code compatibility, write behavior, migration locks, backfill, feature flags, connection budget and restore boundary. Avoid a blind database restore because it can erase valid writes. Use the smallest compatible action—such as traffic hold, feature disable, connection/concurrency containment, or a forward-compatible correction—then verify transactions, data integrity and sustained canary metrics. Prevention is expand/contract design, migration rehearsal, explicit gates and a documented roll-forward versus rollback decision.",
    followUps: ["When is rolling application code back unsafe?", "What signal proves a canary should not be promoted even with low errors?"],
  },
  {
    id: "cloud-eks-capacity",
    role: "Cloud engineer",
    areas: ["Reliability", "System design"],
    prompt: "An EKS deployment has many Pending Pods after a traffic increase. Give the order of evidence before adding nodes.",
    evaluator: "Whether you distinguish scheduler constraints, allocatable capacity, network IPs, quotas, node lifecycle and downstream capacity.",
    strongAnswer: "Read the scheduler event and Pod requirements first: requests, constraints, taints, volume topology, policy and quotas. Then compare allocatable node resources, node readiness, node-group limits, EC2 quotas, subnet/pod IP capacity and CNI readiness. New nodes cannot fix a selector, volume zone, IP exhaustion or impossible request. After a bounded correction, verify Pods schedule and become ready, then verify the load-balanced user operation and dependency capacity. Build a capacity model for requests, pod IPs, storage and bootstrap time rather than CPU alone.",
    followUps: ["Why can a node have low CPU and still reject a Pod?", "What does a ready Pod not prove about user traffic?"],
  },
  {
    id: "infrastructure-host-contention",
    role: "Infrastructure engineer",
    areas: ["Private cloud", "Incident response"],
    prompt: "Several VMs on one host show high latency while cluster averages look normal. How do you investigate and contain it?",
    evaluator: "Whether you recognize a host as a shared resource boundary and avoid turning live migration into a second incident.",
    strongAnswer: "Compare affected and healthy hosts for scheduler delay, memory pressure, storage tail latency, network drops, placement, recent migrations, backup load and hardware health. Correlate those observations with tenant transaction latency; cluster averages can hide one saturated host. Contain a known amplifier or place the host in maintenance only after checking migration, storage and network headroom. Do not evacuate every VM blindly. Verify tenant journeys and normalized host contention over time, then improve placement, capacity headroom and noisy-neighbor detection.",
    followUps: ["Why can more vCPUs worsen the issue?", "What is the difference between host maintenance success and workload success?"],
  },
  {
    id: "data-stream-replay",
    role: "Data platform engineer",
    areas: ["Data systems", "Reliability"],
    prompt: "A streaming job restarts and customers receive duplicate notifications. Explain the crash window and safe remediation.",
    evaluator: "Whether you distinguish checkpoint state from end-to-end effects and design idempotent recovery with reconciliation.",
    strongAnswer: "Map source identity/offsets, checkpoint completion, operator state, sink commit, notification side effect, idempotency key and retry path. A correctly restored checkpoint does not make an external side effect exactly once. Preserve the affected range, stop unsafe additional delivery if authorized, and use durable idempotency or an inbox/outbox record to identify and reconcile duplicates. Replay only a bounded interval after proving the sink rejects already-applied effects. Verify authoritative business state and user effects, then test crash points and reconciliation as part of the pipeline contract.",
    followUps: ["What does exactly-once mean without naming a source and sink?", "Why is an unbounded replay unsafe when identity is uncertain?"],
  },
  {
    id: "lead-incident-decision",
    role: "Engineering lead",
    areas: ["Incident response", "Reliability"],
    prompt: "Two teams disagree during a customer-impacting incident: one wants an immediate rollback and one wants to keep investigating. How do you lead the next decision without becoming the bottleneck?",
    evaluator: "Whether you create shared evidence, decision ownership, safe momentum, and clear communication under uncertainty.",
    strongAnswer: "Name the user impact, decision deadline, current evidence, unknowns, and authority for the next change. Assign a small investigation split: one person validates rollback safety and expected recovery, another tests the competing hypothesis, while an incident commander keeps a single mutation queue and status cadence. Prefer the smallest reversible containment when its benefit outweighs the uncertainty; do not let a debate become a hidden freeze. Record the decision, owner, abort condition, and customer-facing verification. After stabilization, review why the team lacked a pre-agreed rollback or evidence path rather than judging people from hindsight.",
    followUps: ["What makes a rollback unsafe even when a release was recent?", "How do you communicate uncertainty to non-technical stakeholders without losing trust?"],
  },
  {
    id: "lead-reliability-prioritization",
    role: "Engineering lead",
    areas: ["Reliability", "Platform design"],
    prompt: "Your team has a full reliability backlog, delivery commitments, and recurring on-call pain. How do you choose the next quarter's work?",
    evaluator: "Whether you use outcomes, evidence, ownership, and capacity honestly instead of ranking work by whoever is loudest.",
    strongAnswer: "I build a transparent view of user impact, incident recurrence, error-budget risk, toil load, security/compliance obligations, operational ownership, dependency sequencing and effort/uncertainty. I distinguish urgent risk reduction from strategic capability and from unbounded requests. I reserve capacity for interrupts, make trade-offs explicit with product and platform partners, and choose work with a measurable outcome: fewer unsafe pages, shorter recovery time, a protected critical journey, or removal of a recurring manual source. Each initiative gets an owner, baseline, decision date, safety/rollback boundary and evidence of completion. I revisit the plan when assumptions change; a roadmap is a controlled hypothesis, not a promise that ignores production reality.",
    followUps: ["Why is toil reduction not automatically the highest-priority work?", "What evidence would show that a reliability investment actually worked?"],
  },
  {
    id: "architect-multi-region-consistency",
    role: "Systems architect",
    areas: ["System design", "Reliability"],
    prompt: "Design a multi-region order service that must stay available during a regional outage but must never silently duplicate a customer order. What do you establish before choosing a topology?",
    evaluator: "Whether you begin with operation-level correctness and failure assumptions rather than naming an architecture pattern.",
    strongAnswer: "Start with the order contract: identity, duplicate semantics, payment/inventory side effects, acceptable stale reads, RPO/RTO, regional failure assumptions, legal/data boundaries, traffic shape and recovery authority. Separate the customer intention from execution attempts using durable idempotency and reconciliation. Then compare active-passive, single-writer with failover, partitioned ownership, and active-active designs against write latency, conflict resolution, fencing, replication lag, cost and operational complexity. Define how a region is declared unavailable, how the old writer is fenced, how traffic shifts, how ambiguous operations reconcile, and which user journeys prove recovery. I select the smallest design that meets the documented guarantees and test regional loss, delayed replication, duplicate submissions and failback before claiming the guarantee.",
    followUps: ["Why is a globally replicated database not a complete answer?", "What must failover prove beyond a DNS or load-balancer change?"],
  },
  {
    id: "architect-platform-boundaries",
    role: "Systems architect",
    areas: ["System design", "Platform design"],
    prompt: "Several product teams want a shared internal platform, but their workloads have different security and lifecycle needs. How do you design the boundaries?",
    evaluator: "Whether you treat platform capabilities, tenancy, policy, lifecycle and adoption as explicit contracts rather than one large cluster or portal.",
    strongAnswer: "I begin with the supported user journeys and classify what is truly common: identity, build provenance, deployment interface, observability, policy and lifecycle. I map tenant trust, data classification, resource isolation, regulatory boundaries, operational support tier and recovery objectives. The platform exposes versioned self-service contracts with validated inputs, least-privilege defaults, quotas, audit, asynchronous status and an exception path; it does not silently turn every team into an administrator. I choose isolation boundaries appropriate to the risk—namespace, account/project, cluster, network, key or control plane—and make their limits clear. I measure adoption, time to safe capability, support load, reliability and cost, then evolve the product with migration tooling instead of forcing a one-time rewrite.",
    followUps: ["When is a separate cluster or account justified over a namespace boundary?", "How do you prevent the exception path from becoming the real platform API?"],
  },
];

export function questionsForRole(role: MockRole): readonly MockQuestion[] {
  return mockQuestions.filter((question) => question.role === role);
}

export function questionsForRoleAndArea(role: MockRole, area: MockArea): readonly MockQuestion[] {
  const exact = questionsForRole(role).filter((question) => question.areas.includes(area));
  return exact.length > 0 ? exact : questionsForRole(role);
}

export function formatMockDuration(totalSeconds: number): string {
  const seconds = Math.max(0, Math.floor(totalSeconds));
  return `${String(Math.floor(seconds / 60)).padStart(2, "0")}:${String(seconds % 60).padStart(2, "0")}`;
}

export function mockEvidenceMarkdown(input: Readonly<{
  role: MockRole;
  area: MockArea;
  question: MockQuestion;
  response: string;
  confidence: number;
  elapsedSeconds: number;
  exportedAt: string;
}>): string {
  const response = input.response.replace(/\r\n?/g, "\n").trim().slice(0, 12_000);
  return [
    "# Local mock interview record",
    "",
    `- Role focus: ${input.role}`,
    `- Skill focus: ${input.area}`,
    `- Question ID: ${input.question.id}`,
    `- Elapsed time: ${formatMockDuration(input.elapsedSeconds)}`,
    `- Self-reported confidence: ${input.confidence}/5`,
    `- Exported: ${input.exportedAt}`,
    "- Boundary: private practice record; it is not a score, verified skill, hiring signal, or mastery evidence.",
    "",
    "## Prompt",
    "",
    input.question.prompt,
    "",
    "## Your response",
    "",
    response || "(No response recorded.)",
    "",
  ].join("\n");
}
