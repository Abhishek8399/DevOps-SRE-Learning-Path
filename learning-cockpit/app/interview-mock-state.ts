export const mockRoles = ["SRE", "Platform engineer", "DevOps engineer", "Cloud engineer", "Infrastructure engineer", "Data platform engineer", "Engineering lead", "Systems architect"] as const;
export const mockAreas = ["Incident response", "Reliability", "Platform design", "Delivery security", "Networking", "Data systems", "Private cloud", "System design"] as const;

export type MockRole = (typeof mockRoles)[number];
export type MockArea = (typeof mockAreas)[number];
export type MockDifficulty = "Intermediate" | "Advanced" | "Expert";
export type MockExpectedLevel = "Mid-level" | "Senior" | "Lead" | "Architect";

type MockQuestionGuidance = Readonly<{
  topic: string;
  difficulty: MockDifficulty;
  expectedLevel: MockExpectedLevel;
  weakAnswerWarnings: readonly string[];
  deeperExplanation: string;
  productionExample: string;
}>;

export type MockQuestion = Readonly<{
  id: string;
  role: MockRole;
  areas: readonly MockArea[];
  prompt: string;
  evaluator: string;
  strongAnswer: string;
  followUps: readonly string[];
}> & MockQuestionGuidance;

type MockQuestionCore = Omit<MockQuestion, keyof MockQuestionGuidance>;

const mockQuestionCores = [
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
] as const satisfies readonly MockQuestionCore[];

type MockQuestionId = (typeof mockQuestionCores)[number]["id"];

const mockQuestionGuidance = {
  "sre-user-journey": {
    topic: "Regional SLI blind spots",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Treats a green aggregate SLO as proof that users are healthy.", "Changes global routing before checking capacity, state, and rollback boundaries."],
    deeperExplanation: "An SLO is a deliberately chosen measurement, not reality itself. Slice the journey by region and cohort, then test whether telemetry loss or aggregation has removed affected requests from the denominator before trusting the green result.",
    productionExample: "A regional payment dependency can fail while a global availability ratio stays above target because healthy regions dominate the denominator or failed client attempts never reach server telemetry.",
  },
  "sre-error-budget": {
    topic: "Error-budget release governance",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Uses the budget as an automatic deploy/no-deploy switch without checking data validity.", "Makes an exception without an owner, expiry, rollback trigger, or customer-risk statement."],
    deeperExplanation: "The budget converts an agreed reliability objective into consumable risk. A senior answer validates the measurement and burn horizon, then applies policy with explicit exception authority instead of treating one dashboard number as a universal law.",
    productionExample: "A low-traffic service may show a dramatic short-window burn from a few errors; the release decision should combine multi-window burn, sample size, change risk, and rollback speed.",
  },
  "sre-incident-command": {
    topic: "Multi-region incident command",
    difficulty: "Expert",
    expectedLevel: "Lead",
    weakAnswerWarnings: ["Lets multiple teams mutate production concurrently without one decision queue.", "Declares recovery when the main alert clears but payment outcomes remain unverified."],
    deeperExplanation: "Incident command is a coordination system, not the title of the fastest debugger. It protects decision quality by separating command, investigation, communication, and recording while maintaining one visible mutation history.",
    productionExample: "Traffic reduction can lower request errors while queued payment retries continue failing; customer-boundary verification and backlog observation are required before closure.",
  },
  "platform-golden-path": {
    topic: "Golden-path adoption and platform product design",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Blames developers or mandates adoption without measuring their journey.", "Removes safety controls without separating essential policy from accidental friction."],
    deeperExplanation: "A golden path wins when it is the easiest safe route for a supported job. Measure time-to-capability, failure recovery, support load, bypass reasons, and unsupported needs; adoption alone can rise while outcomes worsen.",
    productionExample: "Teams may bypass a portal because its deployment status is opaque even when execution speed is acceptable; exposing asynchronous status and actionable failure ownership can remove the real friction.",
  },
  "platform-kubernetes": {
    topic: "Kubernetes rollout failure isolation",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Reads only current container logs and ignores events, previous logs, and rollout identity.", "Restarts Pods repeatedly without distinguishing configuration, policy, scheduling, and runtime causes."],
    deeperExplanation: "CrashLoopBackOff is backoff behavior after repeated container termination, not a root cause. Trace desired revision through admission, scheduling, mounts, runtime exit, probes, and Service endpoints, preserving the failed identity for comparison.",
    productionExample: "A Secret key rename can let admission and scheduling succeed but make the process exit immediately; `kubectl describe`, resolved Pod configuration, and previous logs separate this from OOM termination.",
  },
  "devops-supply-chain": {
    topic: "Delivery supply-chain trust",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Adds a scanner while leaving mutable artifact identity and broad credentials unchanged.", "Assumes an SBOM proves the artifact is authorized or uncompromised."],
    deeperExplanation: "Trust must bind source, workflow, builder, artifact digest, authorization, and deployment evidence. Each control answers a different question; inventory, provenance, signature verification, and policy are complementary rather than interchangeable.",
    productionExample: "A correctly scanned image referenced by a mutable tag can be replaced after approval; digest-bound promotion prevents the reviewed and deployed subjects from silently diverging.",
  },
  "cloud-networking": {
    topic: "Private cloud connection timeouts",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Stops after DNS resolution and concludes the network path is healthy.", "Opens broad firewall access before proving direction, return path, listener, and identity."],
    deeperExplanation: "A connection crosses independent authorities: name resolution, route selection, stateful policy, translation, listener, TLS, and application authorization. Test the exact source/destination tuple and preserve directionality.",
    productionExample: "A private endpoint name may resolve correctly while a subnet route or return security rule drops SYN-ACK traffic, producing a timeout rather than a DNS error.",
  },
  "sre-data-freshness": {
    topic: "Data correctness versus job success",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Treats scheduler success as proof of complete and correct data.", "Backfills directly into the published destination without isolated reproduction or idempotent reconciliation."],
    deeperExplanation: "Pipeline availability and data correctness are different service properties. Establish authoritative interval, schema, row-count, completeness, lineage, and publication contracts before changing or replaying state.",
    productionExample: "A left join can silently become an inner join after a filter change, producing a green task with fewer revenue rows; an independent source-total control catches the semantic loss.",
  },
  "platform-policy-exception": {
    topic: "Admission-policy exception safety",
    difficulty: "Expert",
    expectedLevel: "Lead",
    weakAnswerWarnings: ["Disables enforcement globally to restore one workload.", "Creates an exception without scope, owner, expiry, compensating controls, or audit evidence."],
    deeperExplanation: "Policy is a production dependency with versions and failure modes. The response must preserve the invariant where possible, distinguish a defective rule from a violating workload, and make temporary authority expire safely.",
    productionExample: "A policy rollout that rejects a newly required safe field may need revision rollback, while a privileged-container request needs a narrow time-bound exception or workload redesign—not global enforcement removal.",
  },
  "devops-migration-release": {
    topic: "Progressive delivery with data migration",
    difficulty: "Expert",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Promotes because error rate is low while ignoring latency and saturation.", "Assumes application rollback also reverses schema changes and valid writes safely."],
    deeperExplanation: "A release with persistent data changes has asymmetric reversibility. Expand/contract compatibility, write ownership, backfill load, connection budgets, and roll-forward paths must be designed before rollout rather than improvised during failure.",
    productionExample: "Adding a populated column or index can hold locks and exhaust connections even when requests eventually succeed; pausing exposure and containing migration concurrency protects the service.",
  },
  "cloud-eks-capacity": {
    topic: "EKS scheduling and multidimensional capacity",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Adds nodes before reading scheduler events and Pod constraints.", "Models capacity only as CPU while ignoring IPs, quotas, topology, storage, and bootstrap time."],
    deeperExplanation: "Pending means the scheduler has not found an admissible placement. Capacity is the intersection of requests, constraints, allocatable resources, network addresses, volumes, quotas, policy, and autoscaler reachability.",
    productionExample: "Nodes can show low CPU while a Pod remains Pending because its requested memory, required zone, taint tolerance, or subnet IP supply makes every candidate infeasible.",
  },
  "infrastructure-host-contention": {
    topic: "Private-cloud noisy-neighbor diagnosis",
    difficulty: "Advanced",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Uses cluster averages that hide a single saturated failure domain.", "Evacuates all VMs without checking destination, storage, and network headroom."],
    deeperExplanation: "A VM observes virtual resources while the hypervisor schedules shared physical CPU, memory, storage, and network. Correlate guest symptoms with host-level contention and placement before choosing containment.",
    productionExample: "A backup workload can saturate one datastore queue, increasing tail latency for colocated VMs while fleet-wide CPU and latency averages remain normal.",
  },
  "data-stream-replay": {
    topic: "Streaming replay and side-effect identity",
    difficulty: "Expert",
    expectedLevel: "Senior",
    weakAnswerWarnings: ["Claims exactly-once without naming the source, checkpoint, sink, and external effect boundary.", "Replays an unbounded range before proving durable idempotency and reconciliation."],
    deeperExplanation: "Checkpoint consistency governs captured processing state, but an external notification may commit outside that transaction. End-to-end safety requires stable event/effect identity and a durable record of what was applied.",
    productionExample: "A worker can send a notification and crash before checkpoint completion; after restart the event is processed again unless the notification effect is keyed and reconciled.",
  },
  "lead-incident-decision": {
    topic: "Incident decision leadership",
    difficulty: "Expert",
    expectedLevel: "Lead",
    weakAnswerWarnings: ["Personally approves and investigates every action, becoming the bottleneck.", "Allows debate without a decision deadline, parallel evidence tasks, or one mutation owner."],
    deeperExplanation: "Leadership under uncertainty creates a decision structure that lets specialists work in parallel while production changes remain serialized and reversible. The leader owns clarity and escalation, not every command.",
    productionExample: "One investigator can validate database rollback safety while another checks dependency health; the incident commander chooses from timestamped evidence and keeps stakeholders updated.",
  },
  "lead-reliability-prioritization": {
    topic: "Reliability portfolio prioritization",
    difficulty: "Expert",
    expectedLevel: "Lead",
    weakAnswerWarnings: ["Ranks work only by incident count, executive urgency, or engineering preference.", "Commits all capacity to roadmap work and pretends interrupts will not occur."],
    deeperExplanation: "A reliability portfolio balances user risk, mandatory obligations, recurring operational load, strategic leverage, dependencies, and uncertainty. Each investment needs a baseline and an outcome measure, not just completion of tickets.",
    productionExample: "Automating a noisy but harmless task may save hours, while fixing one silent checkout-corruption path protects more user value; transparent criteria make that trade-off defensible.",
  },
  "architect-multi-region-consistency": {
    topic: "Multi-region order correctness",
    difficulty: "Expert",
    expectedLevel: "Architect",
    weakAnswerWarnings: ["Names active-active or a global database before defining operation semantics and failure assumptions.", "Describes failover without fencing the old writer or reconciling ambiguous attempts."],
    deeperExplanation: "Architecture begins with invariants and failure semantics. Availability, latency, consistency, duplicate handling, data locality, and recovery authority constrain the topology; no replication product removes those trade-offs.",
    productionExample: "During a partition, two regions accepting the same order key can duplicate payment unless ownership, idempotency, and conflict handling are explicit and tested through failback.",
  },
  "architect-platform-boundaries": {
    topic: "Multi-tenant platform boundaries",
    difficulty: "Expert",
    expectedLevel: "Architect",
    weakAnswerWarnings: ["Equates a shared platform with one shared cluster for every workload.", "Designs only the portal UI and leaves tenancy, lifecycle, support, and exception authority implicit."],
    deeperExplanation: "A platform is a portfolio of versioned capabilities with different trust and failure boundaries. Isolation choices should follow workload risk and operational ownership, while migration paths keep the product evolvable.",
    productionExample: "Low-risk stateless services may share namespace-based controls, while regulated data or independent upgrade requirements can justify separate accounts, clusters, keys, or control planes.",
  },
} satisfies Record<MockQuestionId, MockQuestionGuidance>;

export const mockQuestions: readonly MockQuestion[] = mockQuestionCores.map((question) => ({
  ...question,
  ...mockQuestionGuidance[question.id],
}));

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
