export const mockRoles = ["SRE", "Platform engineer", "DevOps engineer", "Cloud engineer"] as const;
export const mockAreas = ["Incident response", "Reliability", "Platform design", "Delivery security", "Networking"] as const;

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
