---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0034",
  "slug": "causal-analysis-post-incident-learning",
  "aliases": ["V04-L09", "causal-analysis-post-incident-learning"],
  "curriculumIds": ["SRE-004"],
  "route": "/book/reliability/causal-analysis-post-incident-learning",
  "order": 9,
  "volume": "04-reliability-operations",
  "title": "Causal analysis and post-incident learning: turn evidence into reduced risk",
  "summary": "Reconstruct what happened from imperfect evidence, distinguish triggers from contributing conditions and failed defenses, test causal claims with counterfactuals, write blameless but accountable reviews, and prove that corrective work reduced risk.",
  "domain": "reliability",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0007", "LES-0008", "LES-0026", "LES-0033"],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001", "OBS-001", "SRE-003"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The planned bounded model uses Bash and Python 3 as a normal user, creates one UID-scoped temporary directory, opens no port, and contacts no production, cloud, identity, notification, evidence, or incident system."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04 LTS", "support": "supported", "notes": "The planned model is designed for WSL, but startup, identity, ownership, clock, filesystem, and cleanup behavior must be observed rather than assumed."},
    {"platform": "Production, cloud, Kubernetes, data, security, safety, and regulated systems", "version": "concept-only", "support": "concept-only", "notes": "The chapter teaches transfer boundaries. It does not analyze a real incident, handle private evidence, determine legal responsibility, or authorize corrective change."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "software-engineer-on-call", "observability-engineer", "security-engineer", "technical-lead", "engineering-manager", "incident-commander", "systems-architect"],
  "learningObjectives": [
    "Distinguish chronology, correlation, trigger, proximate mechanism, contributing condition, latent condition, failed defense, and a supported causal claim.",
    "Reconcile clocks and sources into a timeline that preserves conflicts, missing intervals, and the difference between system time and knowledge time.",
    "Build a causal graph that explains how conditions combined to produce user impact instead of stopping at one person, change, or component.",
    "Test causal links with falsifiable predictions, controls, reproduction, mechanism evidence, alternatives, counterfactuals, and explicit confidence.",
    "Choose among timeline analysis, Five Whys, change analysis, fault trees, barrier analysis, and causal graphs according to their limits.",
    "Write a blameless but accountable review with impact, response, decisions, mechanisms, unknowns, lessons, and reviewable actions.",
    "Analyze human action through local rationality, interface, workload, permissions, incentives, training, review, automation, and recovery design.",
    "Design balanced controls across prevention, containment, detection, mitigation, recovery, coordination, and organizational learning.",
    "Give each action a risk, owner, priority, due date, acceptance test, rollback, and verification path.",
    "Prove action effectiveness through tests, exercises, telemetry, recurrence analysis, near-miss review, and cross-system adoption."
  ],
  "productionSignals": [
    "user-impact interval, journey, population, correctness, latency, durability, business effect, and estimation method",
    "event, observation, and ingestion timestamps with timezone, source clock, synchronization quality, retention, and transformation history",
    "deployment, configuration, flag, schema, traffic, capacity, dependency, identity, certificate, policy, and manual change records",
    "raw metrics, logs, traces, events, profiles, queue state, data reconciliation, audit records, and telemetry coverage gaps",
    "incident roles, decisions, actions, expected and actual results, communications, handoffs, mitigation, recovery, and closure",
    "fact, inference, assumption, hypothesis, confidence, confirming and rejecting evidence, alternative explanation, and unknown",
    "trigger, mechanism, propagation, contributing and latent conditions, failed barriers, recovery constraints, and luck",
    "counterfactual intervention, controlled assumptions, predicted outcome, test result, and external-validity limit",
    "review owner, reviewers, access class, disagreements, approval, publication audience, and review date",
    "action risk type, owner, priority, due date, design, acceptance, rollback, verification, completion, and supersession",
    "repeat-incident signature, near miss, detection gap, mitigation time, severity trend, action effectiveness, and adoption",
    "psychological safety, participation, dissent, fatigue, authority gradient, local knowledge, and evidence-withholding risk"
  ],
  "diagrams": [
    {"id": "LES-0034-DIA-001", "title": "Evidence-to-learning pipeline", "direction": "left-to-right", "boundaries": ["raw sources", "provenance and clocks", "verified timeline", "causal hypotheses", "tests and counterfactuals", "reviewed graph", "actions", "verification", "organizational learning"], "evidencePoints": ["immutable artifact", "source metadata", "confidence and conflict", "predictions", "confirm and reject", "mechanism links", "owner and test", "risk-reduction result", "recurrence and adoption"], "textAlternative": "Raw evidence is preserved with provenance, reconciled into a timeline, and used to generate hypotheses. Tests strengthen or weaken causal links. Reviewers accept a graph, choose actions, verify risk reduction, and spread learning."},
    {"id": "LES-0034-DIA-002", "title": "Trigger is not the whole cause", "direction": "hierarchical", "boundaries": ["latent conditions", "trigger", "proximate mechanism", "propagation", "failed defenses", "user impact", "recovery constraints"], "evidencePoints": ["pre-existing state", "change or demand", "resource or logic behavior", "dependency and retry path", "missing containment", "journey evidence", "rollback and data limits"], "textAlternative": "A trigger activates a mechanism inside pre-existing conditions. Failure propagates while defenses fail or are absent, producing user impact. Recovery constraints determine duration. Removing only the trigger can leave the mechanism and defenses unchanged."},
    {"id": "LES-0034-DIA-003", "title": "Causal graph for a queue collapse", "direction": "left-to-right", "boundaries": ["synchronous enrichment", "timeout budget", "retry amplification", "worker saturation", "shared queue", "checkout failure", "duplicate-risk recovery"], "evidencePoints": ["release diff", "trace duration", "attempt ratio", "CPU and concurrency", "queue age", "journey SLI", "transaction reconciliation"], "textAlternative": "A synchronous call exceeded a deadline. Retries amplified work until workers saturated. A shared queue spread delay, causing checkout failures. Missing idempotency proof constrained replay. Each arrow requires evidence."},
    {"id": "LES-0034-DIA-004", "title": "Counterfactual evidence ladder", "direction": "top-to-bottom", "boundaries": ["plausible story", "temporal order", "association", "mechanism", "controlled comparison", "safe reproduction", "intervention", "residual uncertainty"], "evidencePoints": ["narrative", "timeline", "covariation", "code or protocol", "control cohort", "fixture", "changed outcome", "external-validity limit"], "textAlternative": "Confidence grows from a plausible story through timing, association, mechanism, control, reproduction, and intervention. Even intervention retains uncertainty because production interactions may differ."},
    {"id": "LES-0034-DIA-005", "title": "Balanced action portfolio", "direction": "hierarchical", "boundaries": ["prevent", "contain", "detect", "mitigate", "recover", "coordinate", "learn"], "evidencePoints": ["defect test", "blast-radius test", "detection replay", "relief drill", "restore proof", "handoff exercise", "closure and recurrence review"], "textAlternative": "A balanced portfolio prevents some triggers, contains spread, detects impact, speeds mitigation, proves recovery, improves coordination, and verifies learning. Each point needs its own acceptance evidence."},
    {"id": "LES-0034-DIA-006", "title": "Review feedback loop", "direction": "cyclic", "boundaries": ["incident", "review", "prioritize", "implement", "verify", "exercise", "measure recurrence", "update standards"], "evidencePoints": ["incident record", "approved graph", "risk decision", "change record", "acceptance", "game day", "signature trend", "golden path or policy"], "textAlternative": "An incident produces a reviewed explanation and actions. Implemented controls are verified and exercised. Recurrence evidence shows whether risk changed. Successful controls become standards and new incidents restart the loop."}
  ],
  "commands": [
    {"id": "LES-0034-CMD-001", "question": "Which identity, kernel, Ubuntu release, Python version, UTC clock, and path define this attempt?", "risk": "read-only", "command": "id; uname -a; cat /etc/os-release; python3 --version; date -u +%Y-%m-%dT%H:%M:%SZ; pwd", "runFrom": "a normal Ubuntu shell before the bounded lab", "expectedBranches": [{"when": "UID is non-root and environment matches", "meaning": "local context is recorded", "nextEvidence": "validate the fictional evidence manifest"}, {"when": "UID is zero, dependency is absent, time is implausible, or path is wrong", "meaning": "the boundary is unsafe or incomplete", "nextEvidence": "stop and correct or record the mismatch"}], "proves": "only self-reported local context at that instant", "doesNotProve": "clock synchronization, evidence authenticity, production equivalence, or authority"},
    {"id": "LES-0034-CMD-002", "question": "Does the fictional evidence bundle satisfy its exact contract?", "risk": "read-only", "command": "python3 fixtures/causal_model.py validate-scenario fixtures/scenario.json", "runFrom": "book/labs/LES-0034-causal-analysis-post-incident-learning", "expectedBranches": [{"when": "scenario_valid=true appears", "meaning": "sources, clocks, links, actions, and outcomes satisfy the model", "nextEvidence": "run doctor and setup"}, {"when": "refused=true or an error appears", "meaning": "the fixture or model is invalid", "nextEvidence": "preserve the first error and create no state"}], "proves": "only conformance to the deterministic validator", "doesNotProve": "truth, authenticity, causality, completeness, or privacy fitness"},
    {"id": "LES-0034-CMD-003", "question": "Can the lab create its exact private normal-user state?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "book/labs/LES-0034-causal-analysis-post-incident-learning as a normal Ubuntu user", "expectedBranches": [{"when": "state=ready appears", "meaning": "the UID-scoped descriptor validates", "nextEvidence": "inspect status and run timeline"}, {"when": "refused=true appears", "meaning": "identity, path, owner, symlink, or fixture is unsafe", "nextEvidence": "preserve ambiguous state"}], "proves": "bounded state creation under the wrapper contract", "doesNotProve": "causal correctness, cleanup, independence, or mastery", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-004", "question": "What exact state and result count exist?", "risk": "read-only", "command": "bash lab.sh status", "runFrom": "book/labs/LES-0034-causal-analysis-post-incident-learning", "expectedBranches": [{"when": "state=absent appears", "meaning": "expected state is absent", "nextEvidence": "setup only for intended practice"}, {"when": "state=ready appears", "meaning": "descriptor and children validate", "nextEvidence": "compare result count"}, {"when": "refused=true appears", "meaning": "state is ambiguous", "nextEvidence": "preserve it; do not delete broadly"}], "proves": "only encoded state validity", "doesNotProve": "semantic truth, cleanup, or mastery"},
    {"id": "LES-0034-CMD-005", "question": "How do source clock offsets change event ordering?", "risk": "mutating-bounded", "command": "bash lab.sh run timeline", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "rawOrderConflict=true appears", "meaning": "raw strings cannot be safely sorted before correction", "nextEvidence": "retain raw and normalized times with uncertainty"}, {"when": "no conflict appears", "meaning": "inputs changed or align", "nextEvidence": "still state precision and gaps"}], "proves": "normalization over fictional offsets", "doesNotProve": "actual clock accuracy or authentic ordering", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-006", "question": "Which statements are facts, inferences, hypotheses, assumptions, or unsupported?", "risk": "mutating-bounded", "command": "bash lab.sh run claims", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "unsupported=2 appears", "meaning": "two claims exceed cited evidence", "nextEvidence": "remove or qualify them"}, {"when": "classification differs", "meaning": "claims or rules changed", "nextEvidence": "inspect provenance and logical support"}], "proves": "classification under model rules", "doesNotProve": "natural-language truth or complete detection", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-007", "question": "Is the graph acyclic and which links lack evidence?", "risk": "mutating-bounded", "command": "bash lab.sh run graph", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "acyclic=true and unsupportedLinks=1 appear", "meaning": "one plausible arrow remains unverified", "nextEvidence": "keep the unknown and design a test"}, {"when": "a cycle appears", "meaning": "graph identities or direction are inconsistent", "nextEvidence": "repair structure before interpretation"}], "proves": "graph structure and evidence references", "doesNotProve": "causation, necessity, sufficiency, or completeness", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-008", "question": "Which counterfactuals isolate one variable?", "risk": "mutating-bounded", "command": "bash lab.sh run counterfactual", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "testable=3 and confounded=1 appear", "meaning": "three interventions isolate a declared control", "nextEvidence": "prioritize safe high-information tests"}, {"when": "counts change", "meaning": "interventions changed", "nextEvidence": "review every changed variable"}], "proves": "counterfactual shape under the fixture", "doesNotProve": "production safety or generalization", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-009", "question": "Why does one Five Whys chain miss parallel conditions?", "risk": "mutating-bounded", "command": "bash lab.sh run methods", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "linearCoverage is below graphCoverage", "meaning": "one chain follows one branch", "nextEvidence": "expand and test the graph"}, {"when": "coverage matches", "meaning": "the case may be linear", "nextEvidence": "still inspect alternatives and barriers"}], "proves": "method coverage for fictional nodes", "doesNotProve": "that Five Whys is always weak or graphs are automatically correct", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-010", "question": "Which actions are owned, testable, proportionate, and tied to risk?", "risk": "mutating-bounded", "command": "bash lab.sh run actions", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "accepted=5 and rejected=3 appear", "meaning": "vague training, monitor-everything, and permanent-freeze items fail", "nextEvidence": "review risk, cost, owner, and acceptance"}, {"when": "counts change", "meaning": "actions or gates changed", "nextEvidence": "inspect each criterion"}], "proves": "action-shape checks", "doesNotProve": "implementation, effectiveness, priority, or commitment", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-011", "question": "Did closed actions reduce the targeted failure mode?", "risk": "mutating-bounded", "command": "bash lab.sh run verification", "runFrom": "validated LES-0034 state", "expectedBranches": [{"when": "verifiedEffective=4, ineffective=1, and overdue=1 appear", "meaning": "ticket closure and risk reduction diverge", "nextEvidence": "reopen ineffective work and escalate overdue risk"}, {"when": "all appear complete", "meaning": "status may still be self-reported", "nextEvidence": "inspect artifacts and recurrence"}], "proves": "fixture status versus acceptance evidence", "doesNotProve": "zero recurrence or durable adoption", "cleanup": "bash lab.sh cleanup"},
    {"id": "LES-0034-CMD-012", "question": "Did the complete exercise pass and leave no state?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "book/labs/LES-0034-causal-analysis-post-incident-learning as a normal user", "expectedBranches": [{"when": "verification=passed and final_state=absent appear", "meaning": "fixture, assertions, refusals, and cleanup passed", "nextEvidence": "preserve environment and result with limits"}, {"when": "a command fails or cleanup refuses", "meaning": "the first failure is evidence", "nextEvidence": "stop and inspect status"}], "proves": "only checked-in lifecycle behavior for that run", "doesNotProve": "real causality, evidence handling, independent review, or mastery", "cleanup": "the verifier must prove exact absence"}
  ],
  "labs": [
    {"id": "LES-0034-LAB-001", "title": "Guided evidence, causal-graph, action, and verification model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; no network, Docker, sudo, provider, production, organization, identity, evidence, or incident system", "timeMinutes": 180, "privilege": "normal user; wrapper and verifier refuse UID 0", "network": "none; all evidence is fictional local data", "changes": ["one lesson-specific private temporary directory", "owned fixture and manifest", "at most seven JSON results"], "abortConditions": ["caller is root", "state identity or ownership is ambiguous", "fixture provenance fails", "a child is a symlink", "assertions differ", "cleanup cannot validate ownership", "model output is proposed as real causality"], "recovery": "Run status. If the descriptor validates, run cleanup and repeat setup. Preserve refused state.", "cleanupProof": "Validate exact parent, basename, real path, UID, sentinel, manifest, scenario, children, types, and owners; remove only that directory; prove absence.", "path": "book/labs/LES-0034-causal-analysis-post-incident-learning"},
    {"id": "LES-0034-LAB-002", "title": "Independent post-incident analysis and action defense", "mode": "independent", "environment": "A held-back materially different disposable case with conflicting clocks, incomplete telemetry, alternative explanations, human and technical conditions, action tradeoffs, recurrence evidence, and privacy constraints", "timeMinutes": 210, "privilege": "normal user; no production, evidence-custody, legal, security, communication, or change authority", "network": "none unless a reviewed unseen harness declares loopback; real employer, cloud, incident, identity, and customer systems are prohibited", "changes": ["one sanitized response", "only unseen-case resources"], "abortConditions": ["answers are visible", "authorization or sanitization is unclear", "real evidence could be exposed", "causal certainty exceeds evidence", "an action lacks acceptance", "cleanup cannot be proven"], "recovery": "Return to provenance and the last supported claim; expose gaps; do not reveal answers.", "cleanupProof": "Use the unseen manifest to prove every allowed resource absent.", "path": "book/labs/LES-0034-causal-analysis-post-incident-learning"}
  ],
  "incidents": [
    {"id": "LES-0034-INC-001", "signal": "A deployment completed eight minutes before an outage and is called the root cause.", "firstThought": "Timing makes it a candidate trigger, not a complete explanation.", "safePath": "Compare cohorts, inspect mechanism, trace propagation and defenses, test alternatives, and state confidence.", "trap": "After-this-therefore-because reasoning misses interactions."},
    {"id": "LES-0034-INC-002", "signal": "Logs place retries before latency while traces place latency first.", "firstThought": "Sources may have different clocks, delays, or populations.", "safePath": "Preserve raw event, observation, and ingest times; reconcile offsets and uncertainty from independent anchors.", "trap": "Normalization without provenance turns an assumption into fact."},
    {"id": "LES-0034-INC-003", "signal": "Five Whys ends at an engineer skipping a checklist; training is the only action.", "firstThought": "The chain selected a person branch and stopped before system defenses.", "safePath": "Expand a graph, examine local rationality and barriers, then design system and skill controls.", "trap": "Training alone rarely limits blast radius and can suppress evidence."},
    {"id": "LES-0034-INC-004", "signal": "Twenty actions are closed but the original failure still reproduces.", "firstThought": "Administrative completion is not risk-reduction proof.", "safePath": "Evaluate acceptance tests, replay the mechanism, reopen ineffective work, and report residual risk.", "trap": "Counting tickets rewards output while failure remains."},
    {"id": "LES-0034-INC-005", "signal": "A security review contains customer identifiers, tokens, and exploit details in a broad document.", "firstThought": "Learning does not override privacy, custody, secret, legal, or need-to-know controls.", "safePath": "Restrict the source, rotate secrets through approved paths, create sanitized versions, and record withheld categories.", "trap": "Open sharing can create a second incident; total secrecy can prevent learning."}
  ],
  "assessmentIds": ["ASM-0085", "ASM-0086", "ASM-0087"],
  "referenceIds": ["REF-0274", "REF-0275", "REF-0276", "REF-0277", "REF-0278", "REF-0279", "REF-0280", "REF-0281", "REF-0282", "REF-0283", "REF-0284", "REF-0285", "REF-0286", "REF-0287", "REF-0288"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-04",
  "reviewAfter": "2027-02-04",
  "limitations": ["All scenarios and evidence are fictional.", "No real review, private evidence, forensic artifact, production change, action closure, or recurrence was observed.", "The model can validate structure but cannot prove real causation.", "Security, safety, fraud, privacy, employment, regulatory, and legal investigations require specialized governance.", "Blameless analysis does not excuse intentional misconduct or remove accountability.", "Reading or automation does not establish independent judgment or mastery."]
}
---

# Causal analysis and post-incident learning: turn evidence into reduced risk

## What you see and first thought

The outage is over. Someone writes:

```text
Root cause: engineer deployed bad version 7.42.
Action: remind everyone to follow the checklist.
```

It feels complete because it names a person, a change, and an action. It is usually the beginning of analysis.

Your first thought should be: **what combination of conditions allowed this change to reach users, spread, escape detection, resist mitigation, and remain possible tomorrow?**

A post-incident review earns its cost only when it changes future risk. Use this chain:

```text
preserve evidence -> reconcile clocks -> quantify impact -> classify claims
 -> build and test causal links -> choose controls -> verify controls
 -> measure recurrence and spread learning
```

Do not delay active mitigation to complete analysis. Preserve evidence safely during response; analyze after recovery without rewriting uncertainty out of history.

## Terms before commands

**Chronology** orders events after clock reconciliation. It is necessary for causality but insufficient: breakfast also happened before the outage.

**Correlation** means observations vary together. Causation, shared causes, selection, measurement error, or coincidence can all produce it.

**Trigger** activates an existing failure path. **Proximate mechanism** is the immediate behavior producing the next effect. **Contributing conditions** make failure likelier, larger, harder to detect, or slower to recover. **Latent conditions** existed before visible harm.

A **defense** or **barrier** prevents, contains, detects, mitigates, or helps recover. Barrier analysis asks what worked, failed, or was absent.

A **causal claim** predicts that changing one factor changes an outcome through a mechanism under stated conditions. A **counterfactual** exposes this prediction by asking what would happen under a controlled intervention.

A **confounder** influences both exposure and outcome. A **control cohort** lacks the candidate exposure but must still be comparable.

**Reproduction** recreates behavior under controlled conditions. It proves possibility in that fixture, not necessarily production history or sole cause.

A **causal graph** uses nodes for conditions and directed links for influence. Every arrow needs evidence, alternatives, confidence, and a test.

**Five Whys** prompts deeper questions but one linear chain can hide parallel paths and stop unfairly at a person. **Fault trees** model AND/OR combinations. **Change analysis** compares state. **Barrier analysis** reviews defenses.

**Local rationality** asks why an action made sense with the information, goals, tools, workload, and incentives available then. It improves design without erasing accountability.

**Blameless** analysis avoids moral judgment in technical learning. It does not mean factless, consequence-free, or unable to route deliberate misconduct to a separate authorized process.

An **acceptance test** is observable proof that a control exists and reduces named risk. Ticket closure is not such a test. A **recurrence signature** identifies the same mechanism or impact family across incidents and near misses.

## Architecture map

```text
sources -> provenance -> normalized timeline -> causal graph -> actions
  |           |               |                   |            |
raw data   clocks/access   facts + gaps        tested links  owners/tests
  |                                                            |
  +--------------- governed review record ---------------------+
                                                               |
replay / exercise / telemetry <- verified controls <- implementation
             |
             +-> recurrence trend -> platform standards
```

Three trust boundaries matter: evidence trust, reasoning trust, and action trust. Protect sensitive originals; share sanitized mechanisms and controls at the widest safe level.

## Request or state path

Keep both system time and knowledge time:

```text
SYSTEM TIME                         KNOWLEDGE TIME
02:05 first user fails             02:11 alert observes failures
02:08 retries rise                 02:13 on-call sees retry panel
02:10 dependency slows             02:18 trace query reveals latency
02:32 bypass applied               02:35 journey confirms relief
```

Judging a 02:12 decision with evidence first available at 02:18 is hindsight bias.

Each entry needs raw event, observed, and ingest times; source; precision; fact; interpretation; confidence; and non-claim. Each graph link needs a prediction, confirming and rejecting evidence, alternatives, and current status.

## Failure zoom

"The deploy caused it" confuses temporal proximity with a complete mechanism. "The engineer made a mistake" describes an action but not why one action could create broad sustained harm. "Five Whys found the root" may mean the analyst followed one chosen branch. "We reproduced it" proves fixture possibility, not production history. "All actions are done" may only mean tickets closed. "Blameless means nobody is accountable" misunderstands learning and ownership.

Whenever a sentence sounds final, ask: what evidence would reject it, what alternative fits, and what boundary remains unknown?

## Internals and state ownership

Preserve an evidence ledger with source, owner, collection, access class, clock, retention, transformations, query, interval, and limitations. Keep raw timestamps; add normalized time, offset, uncertainty, and method rather than overwriting history.

Classify claims:

| Type | Example | Support |
|---|---|---|
| Fact | Version 7.42 reached west at 02:01Z. | Deployment audit. |
| Inference | West was exposed first. | Records plus clock bounds. |
| Hypothesis | Enrichment latency saturated workers. | Prediction and test. |
| Assumption | Clocks differ by under two seconds. | Explicit temporary basis. |
| Decision | Disable enrichment. | Authority and tradeoff. |
| Unknown | Whether retry preceded latency. | Preserved gap. |

Build a graph with trigger, pre-existing state, mechanism, propagation, user impact, defenses, detection delays, recovery constraints, and luck. Choose analysis methods for the question instead of following a ritual.

For human actions, ask what the person saw, expected, optimized, and was authorized to do. Examine interface feedback, fatigue, interruption, training recency, documentation, staffing, incentives, and authority gradients. Route intentional misconduct separately through due process.

Design controls across prevention, containment, detection, mitigation, recovery, coordination, and learning. Prioritize expected risk reduction, reach, confidence, time, cost, new failure modes, operational burden, and opportunity cost.

An action is effective only after implementation, acceptance, rollback review, replay or exercise, outcome telemetry, recurrence review, and useful propagation to similar systems.

## Evidence table

Use a ledger before prose. It stops an attractive story from becoming truth merely because it was written first.

| Question | Strong evidence | Weak or misleading evidence | Operator move |
|---|---|---|---|
| When did impact begin? | Journey SLI, failed transaction records, trace samples, client telemetry | Alert creation time, first chat message | State an interval and uncertainty. |
| What changed? | Immutable deployment or configuration audit with actor, digest and rollout cohort | Memory, ticket status, latest file contents | Link the exact artifact and affected population. |
| Did the change cause impact? | Exposure comparison, mechanism evidence, rollback or replay outcome | It happened just before | Predict what should differ, then test it. |
| How did failure spread? | Queue age, retries, dependency spans, saturation and topology | One host CPU graph | Trace work and shared resources across boundaries. |
| Why did defenses fail? | Alert evaluation, failover records, runbook execution, capacity limits | Monitoring failed | Name the barrier, expected behavior, observed behavior and design gap. |
| Why did a person act? | Information visible then, interface state, policy, workload, access and goals | Hindsight about what they should have known | Reconstruct local rationality; improve the system around the action. |
| Did recovery succeed? | User journey, correctness or durability reconciliation, backlog drain | Green process health | Verify service and data, not merely components. |
| Did an action reduce risk? | Acceptance test, exercise, telemetry and recurrence window | Merged pull request or closed ticket | Keep implementation and effectiveness separate. |

A usable evidence entry records `claim_id`, claim type, source URI or artifact, collection time, event-time range, timezone, clock uncertainty, owner, access class, transformation, confirming result, rejecting result, limitation and reviewer. Make preserved evidence tamper-evident when policy requires it. Never copy secrets or unnecessary personal data into a broadly shared review.

Confidence is not a decorative percentage. Use a small vocabulary—confirmed, strongly supported, plausible, weak, rejected, unknown—and define it. A claim can be strongly supported yet incomplete. Conflicting sources stay visible until reconciled; one is not silently discarded.

The timeline needs two clocks:

- **System time** asks when an event happened: request began, deployment reached a cohort, queue crossed a threshold.
- **Knowledge time** asks when responders could reasonably know it: telemetry arrived, an alert fired, an operator saw the page.

That distinction prevents hindsight bias. If a fact became visible at 02:19, it cannot justify a 02:11 decision.

## Command decoders

The local lab is a reasoning simulator, not a production postmortem system. It uses synthetic JSON and deterministic Python so every conclusion can be inspected. Run it from the lesson lab directory as a normal user.

```bash
bash lab.sh setup
```

`setup` creates only `/tmp/reliability-atlas-les0034-$(id -u)`, copies bounded fixtures there, records ownership and a version marker, and refuses root, symlinks, unexpected state or foreign ownership. It opens no port and contacts no network.

```bash
bash lab.sh run timeline
```

Read `rawOrderConflict=true` as a warning: lexical ordering of raw timestamps disagrees with normalized event time. Do not hand-sort away the conflict; retain source time, offset, normalized time and uncertainty.

```bash
bash lab.sh run claims
```

`unsupported=2` means two claims have no cited evidence capable of supporting their stated strength. It does not prove those claims false. Downgrade them to hypotheses or unknowns, then seek evidence that could confirm or reject them.

```bash
bash lab.sh run graph
```

Expect an acyclic graph with supported and unsupported links counted separately. A diagram arrow is a causal claim. If it has no mechanism or evidence, draw it as tentative instead of laundering it through visual confidence.

```bash
bash lab.sh run counterfactual
```

The simulator reports `testable=3` and `confounded=1`. A counterfactual is useful only when the intervention, held conditions, observable prediction and falsifier are defined. If disabling retries also changes traffic or timeout behavior, the comparison is confounded.

```bash
bash lab.sh run methods
```

The output demonstrates that a linear Five Whys chain covers fewer simultaneous conditions than a causal graph. This is not a ban on Five Whys. A linear method fits a narrow mechanism, while coupled failures need branching methods.

```bash
bash lab.sh run actions
```

Expect five accepted and three rejected proposals. Be careful and retrain everyone fail because they lack a bounded risk, system change, owner, test and verification signal. An accepted action is specific enough for another reviewer to decide whether it worked.

```bash
bash lab.sh run verification
```

`verifiedEffective=4 ineffective=1 overdue=1` separates shipped, tested and effective. An ineffective action is evidence to revise the defense, not a reason to edit the success criterion after the fact.

```bash
bash lab.sh verify
```

This runs deterministic assertions across all seven cases and safety checks. A pass proves the fixture behaves as designed on this machine; it does not prove a real incident conclusion.

```bash
bash lab.sh status
bash lab.sh cleanup
```

`status` prints explicit state. `cleanup` removes only the guarded UID-scoped lab directory after marker, type, path, ownership and symlink checks. Keep real evidence according to organizational retention policy; this cleanup applies only to synthetic fixtures.

## Decision path

When an incident review begins, use this path:

```text
Bound user impact -> preserve evidence and provenance
        |
        v
Reconcile clocks -> system-time + knowledge-time timelines
        |
        v
Classify facts / inferences / hypotheses / unknowns
        |
        v
Build branching causal graph
        |
        v
Challenge every arrow: mechanism, prediction, evidence, falsifier
        |
        v
Test safe alternatives and counterfactuals
        |
        v
Choose layered controls -> assign acceptance + effectiveness tests
        |
        v
Review recurrence, near misses and cross-system adoption
```

If clocks are not comparable, record offsets and uncertainty and use ranges or partial ordering. If a link is weak, mark it tentative rather than hiding it. Stop and escalate when evidence collection could alter a volatile system, violate privacy or legal hold, expose secrets, interfere with a security investigation, affect safety or require production change authority.

Use a review gate before publication. The incident commander or technical lead verifies operational facts; service and dependency owners check mechanisms; security, privacy and legal reviewers handle sensitive material; an independent reviewer challenges the graph; action owners accept scope and tests. Preserve disagreements instead of forcing false consensus.

## Guided Ubuntu lab

### Lab A — reconstruct and challenge a synthetic queue collapse

**Purpose:** experience the difference between an ordered story and a defensible causal model.

1. Enter the lab directory and inspect before execution:

   ```bash
   pwd
   sed -n '1,240p' lab.sh
   sed -n '1,280p' incident_model.py
   find fixtures -maxdepth 2 -type f -print | sort
   ```

   `pwd` confirms scope. `sed` lets you review code. `find` inventories bounded inputs. Do not execute an unfamiliar incident tool merely because a runbook says so.

2. Create the guarded state and check it:

   ```bash
   bash lab.sh setup
   bash lab.sh status
   ```

   Expected meaning: state exists, is owned by your UID, carries the correct marker and contains fixtures. If setup refuses root or unexpected state, fix the environment; do not bypass the guard.

3. Reconstruct time:

   ```bash
   bash lab.sh run timeline
   ```

   Write down which event appears first in raw text, which occurs first after normalization and the uncertainty overlap. The correct answer can be a partial order: A preceded C, while A versus B remains unresolved.

4. Audit claims and graph:

   ```bash
   bash lab.sh run claims
   bash lab.sh run graph
   ```

   For each unsupported item, change the wording from fact to hypothesis. For each arrow, say the mechanism in one sentence. If you cannot, it is an association, not yet a causal link.

5. Test alternatives:

   ```bash
   bash lab.sh run counterfactual
   bash lab.sh run methods
   ```

   Compare at least two explanations: retry amplification and worker regression. State one prediction that differs. A useful test discriminates between explanations; merely collecting another graph may not.

6. Design and verify actions:

   ```bash
   bash lab.sh run actions
   bash lab.sh run verification
   bash lab.sh verify
   ```

   Notice how a control can pass an implementation test yet fail the outcome test. Record that honestly.

7. Clean only synthetic state:

   ```bash
   bash lab.sh cleanup
   bash lab.sh status
   ```

**Expected evidence:** command output for seven cases, one revised claim table, one causal graph with confidence and one action whose effectiveness can be tested.

**Failure interpretation:** fixture assertion failure means the local lesson model differs from its contract. It says nothing by itself about Python, Linux or a production incident. Inspect the first failed assertion, input file and actual output.

**Cleanup:** `bash lab.sh cleanup`; never adapt its deletion path to production evidence stores.

### Lab B — write a review from evidence, not hindsight

Use `support/assessments/ASM-0086-production-analysis-template.md`. Complete it without looking at the answered version first.

1. Bound impact and uncertainty.
2. Create paired system-time and knowledge-time rows.
3. Label every statement fact, inference, hypothesis, assumption, decision or unknown.
4. Draw at least one branching graph containing trigger, mechanism, propagation, failed barrier, impact, recovery constraint and a luck edge.
5. Challenge two links with alternative explanations and falsifiers.
6. Propose controls in at least four defense categories.
7. Give every accepted action an owner role, due logic, acceptance test, rollback, telemetry, effectiveness review and propagation scope.
8. Run a pre-publication review for privacy, security, legal, fairness and unsupported blame.

The answered assessment is a model, not the only correct prose. The rubric rewards traceability and uncertainty. It does not reward certainty unsupported by evidence.

## Production transfer

The local model transfers as a reasoning pattern, not as tooling. Production sources may include Kubernetes events, cloud audit logs, feature-flag history, CI/CD attestations, service meshes, databases, client telemetry, ticket and chat exports, identity systems, physical devices and vendor records. Each has different retention, delay, mutability, clock, permissions and privacy constraints.

Before collection, define the incident identifier, custodian, time range, systems, allowed data classes, legal or security hold, destination, encryption, retention and access review. Prefer references to controlled evidence over copying sensitive payloads into Markdown. Redact through an approved process while retaining a restricted original when policy requires it.

For Kubernetes, a pod restart timestamp can show when container state changed, not why. For a cloud deployment, control-plane success shows intent accepted, not that every data-plane replica served the new version. For a database, recovered connectivity does not prove transactional correctness. For CI/CD, a green rollout job does not prove the customer path or rollback safety.

In distributed systems, reconcile:

- wall clock versus monotonic duration;
- producer time versus collector ingestion time;
- sampling and dropped telemetry;
- retries that create many attempts for one operation;
- asynchronous queues that separate request from effect;
- eventual consistency and late data;
- deployment cohorts and mixed versions;
- client, edge, service, dependency and data boundaries.

Translate a causal claim into an operational test. If retry amplification saturated workers, attempt-to-operation ratio should rise before or with concurrency, a no-retry cohort should avoid amplification under comparable load, and reducing retries should reduce work without merely hiding failed operations. Check negative effects: availability, latency, correctness and upstream load.

Close an incident only after service restoration and correctness or durability checks. Close the review only when unknowns and actions have owners. Close an action only after acceptance. Mark it effective only after its specified verification window. These are different state machines.

## Reliability, security, observability, capacity, and cost

**Reliability:** a review is a feedback controller. The incident supplies an error signal; analysis estimates mechanisms; actions change controls; verification observes the new system. Without outcome feedback, the organization has a document factory, not learning. Track repeat signatures, time to detect, time to mitigate, blast radius, correctness loss, defense activation and recovery burden.

**Security and privacy:** evidence often contains customer identifiers, authentication material, topology and employee actions. Apply least privilege, purpose limitation, retention, encryption and audit. Do not paste tokens, full payloads or unnecessary names into a broad review. A blameless review does not override investigations, regulatory duties or due process.

**Observability:** telemetry quality belongs in the causal graph. Missing correlation IDs, ambiguous units, sampling, aggregation, mutable dashboards, silent collection failure and unsynchronized clocks can distort learning. Improve decision-quality signals, not log volume. Record which future decision each new signal enables.

**Capacity:** failures emerge from demand, concurrency, queues, quotas, memory, connections, retries and dependency budgets. Test realistic bursts, skew and degraded dependencies. Averages hide saturation. Capacity actions need a model, headroom objective, load test, failure threshold and cost guardrail.

**Cost:** more replicas, retention, telemetry, duplicated infrastructure, testing and staffing carry cost and complexity. Prioritize expected risk reduction and reach. Idempotency, bounded retries, progressive delivery and explicit ownership may beat indiscriminate overprovisioning. Record opportunity cost and new failure modes.

**Organization:** measure review quality, action aging, verification, recurrence and adoption without turning metrics into quotas. A zero-incident target suppresses reporting. Psychological safety is operational infrastructure: people must reveal weak signals and mistakes while remaining accountable for honest participation and corrective work.

## Traps and prevention

| Trap | Why it fails | Better design |
|---|---|---|
| Root cause equals last change | Timing is not mechanism; latent conditions remain. | Graph trigger, conditions, propagation, barriers and recovery. |
| Five Whys as mandatory ritual | A single chain erases interacting causes and makes the stopping point arbitrary. | Use it for narrow mechanisms; use graphs, barriers or fault trees for branching systems. |
| Human error as endpoint | It explains neither local rationality nor system susceptibility. | Study interface, information, workload, authorization, review and recovery. |
| Blameless means no accountability | Avoids ownership and can hide misconduct. | Remove scapegoating while assigning actions, standards and due process. |
| Alert time equals impact time | Detection is often delayed and ingestion can reorder evidence. | Bound impact from journey evidence; retain knowledge time separately. |
| Dashboard screenshot as raw evidence | Query, range, aggregation and source may be lost. | Preserve query, source, interval, export and provenance. |
| Correlation presented as cause | A common driver or coincidence can explain both signals. | State mechanism, predictions, alternatives, controls and falsifier. |
| Rollback proves the release | Rollback may change traffic, caches, load and dependencies simultaneously. | Treat it as supporting evidence with confounders; seek cohort and mechanism evidence. |
| Action is add monitoring | No future decision or acceptance criterion. | Name signal, condition, routing, owner, runbook, false-positive budget and test. |
| Ticket closed equals risk reduced | Implementation may not activate or change outcomes. | Separate delivery, acceptance and effectiveness states. |
| Training as default fix | Memory decays and the unsafe path remains available. | Prefer constraints and feedback; use training for residual judgment. |
| Review published immediately | Unsupported claims, secrets or unfair naming become durable. | Require technical, independent and access-sensitive review. |
| Perfect certainty required | Learning stalls while evidence decays. | Publish confidence and unknowns; update with version history. |
| Review count as performance target | Incentivizes trivial reports or suppressed incidents. | Measure risk learning and recurrence with qualitative review. |

Prevention has layers. Make safe actions easy; constrain dangerous states; contain blast radius; detect customer impact and precursor signals; provide reversible mitigation; preserve audit-quality evidence; rehearse recovery; and propagate validated controls to structurally similar services.

## Memory card and retrieval

Remember **TRACE**:

```text
T — Time: system time, knowledge time, offsets and uncertainty
R — Records: provenance, access, transformations and missing evidence
A — Arrows: every causal link needs mechanism, prediction and challenge
C — Controls: prevention through learning, with rollback and side effects
E — Effectiveness: acceptance, exercise, telemetry, recurrence and adoption
```

When someone says, The deploy caused it, answer: That is a useful hypothesis. Which cohort was exposed, what mechanism do we predict, what differed in the control, what did rollback change besides version, and what evidence would reject the claim?

When someone says, The operator made a mistake, answer: What did the interface show at that moment, what goal were they optimizing, which safeguards allowed one action to propagate, and how would another qualified person behave under the same conditions?

Retrieval prompts:

1. Why can `02:03Z` occur before `02:02Z` in the evidence table?
2. What is the difference between a trigger and a causal mechanism?
3. What makes an arrow in a causal graph defensible?
4. Why is rollback evidence useful but not automatically conclusive?
5. How can a review be blameless and still accountable?
6. What evidence promotes a shipped action to an effective action?

Answer aloud from memory, then compare with the next section. Revisit after one day, one week and one month using a fresh scenario.

## Complete answers

1. **Clock order:** timestamps come from different clocks and pipelines. Offset, drift, timezone parsing, batching and ingestion delay can reverse apparent order. Preserve raw values, normalize with a documented method, add uncertainty bounds and use partial ordering when intervals overlap.

2. **Trigger versus mechanism:** a trigger changes conditions—deployment, demand spike, credential expiry. The mechanism is how state turns into failure—timeout causes retry amplification, amplification consumes concurrency, saturation ages a shared queue. Removing the trigger may restore service while leaving the vulnerable mechanism intact.

3. **Defensible arrow:** it has a precise source and destination state, temporal compatibility, a plausible technical or organizational mechanism, cited evidence, a prediction, a potential falsifier, alternatives considered, confidence and scope. Reproduction or intervention strengthens it but never eliminates external-validity limits.

4. **Rollback:** improvement after rollback supports a release-related hypothesis because an intervention changed the outcome. But rollback may also drain traffic, reset caches, restart workers, alter flags or coincide with dependency recovery. Compare cohorts and mechanisms and list confounders.

5. **Blameless accountability:** explain actions through the information and constraints present at the time, avoid humiliation and hindsight, and improve system conditions. Still require truthful participation, explicit decision ownership, policy review, corrective work and separate due process for intentional misconduct.

6. **Effective action:** it was implemented, passed acceptance, had rollback and side effects reviewed, survived a replay or exercise, changed the intended telemetry during a defined window, did not create unacceptable harm, and reduced recurrence or blast radius. Similar exposed systems adopted it where justified.

The central lesson: a post-incident review is not a courtroom verdict or a polished chronology. It is a versioned engineering argument about how risk became harm and how evidence will show that risk is now lower.

## Product-company interview

**Question: Walk me through a postmortem you led.**

A strong answer is structured: impact and customer journey; detection and mitigation; evidence and uncertainty; causal graph; difficult tradeoff; actions across defense layers; verification; recurrence and organizational learning. Say what you personally decided without claiming sole credit. Never reveal confidential identifiers.

Example answer:

> A rollout cohort showed increased checkout latency, but deployment timing alone was insufficient. We reconciled edge, service and queue clocks, found retry amplification behind a synchronous dependency call, and showed that a matched unexposed cohort did not saturate. The graph also exposed missing retry budgets, a shared queue and weak journey alerting. We restored service by disabling the feature, reconciled transactions, then added bounded retries, queue isolation, progressive delivery and a journey SLO alert. Each action had an acceptance test; a later game day verified containment and the following review window showed no repeat signature. One dependency-ordering question remained uncertain, so we improved correlation and retained that claim as plausible, not fact.

**Question: Why not just use Five Whys?**

It is useful for drilling into one narrow mechanism and accessible in facilitation. It becomes misleading when multiple conditions combine, branches reconverge, or the stopping point reflects authority rather than evidence. Use a timeline plus causal graph, fault tree or barrier analysis, and use Five Whys inside selected branches.

**Question: How do you avoid blame without avoiding responsibility?**

Explain local rationality and system design, neutral fact labels, independent review, dissent and privacy. Then name accountability mechanisms: decision logs, action owners, standards, acceptance tests, review dates and due process. Blame asks whom to punish; engineering accountability asks who will own the next verified reduction in risk.

**Question: How do you know corrective actions worked?**

Separate implementation from effectiveness. Define the risk and predicted observable change before work begins; run unit, integration, load, failure or game-day tests; monitor leading and outcome signals; inspect near misses and repeats during a specified window; check side effects; extend the control to similar systems. If the criterion fails, reopen or supersede the action.

**Question: What would make you delay publication?**

Materially wrong impact, unsupported personal attribution, active security or legal investigation, exposed secrets or personal data, unreviewed safety claims, or action owners who have not accepted commitments. Do not delay merely to make the narrative flattering; publish bounded unknowns with version history.

## Independent transfer and rubric

Complete `ASM-0087` without opening an answer key because none is supplied. Choose a fresh domain such as certificate expiry, Kubernetes admission outage, database failover, payment duplication, CI supply-chain compromise, physical cooling failure or data-pipeline corruption.

Submit:

- impact statement with estimation and uncertainty;
- evidence inventory with provenance, access and clock quality;
- system-time and knowledge-time timeline;
- claims ledger with fact, inference, hypothesis and unknown labels;
- branching causal graph with at least eight supported or explicitly tentative links;
- two alternative explanations and discriminating tests;
- one counterfactual with assumptions, intervention, prediction and falsifier;
- controls in at least four defense layers;
- three action records with acceptance, rollback, telemetry and effectiveness review;
- privacy, security, legal and fairness publication check;
- 90-day recurrence and cross-system adoption plan.

Rubric, 100 points:

| Dimension | Points | Full-credit evidence |
|---|---:|---|
| Impact and scope | 10 | User journey, population, interval, correctness or business effect, method and uncertainty. |
| Evidence integrity | 12 | Provenance, access, clocks, transformations, gaps and retained conflicts. |
| Timeline | 10 | System and knowledge time, normalized ranges and no invented order. |
| Claim discipline | 10 | Types, citations, confidence, alternatives and unknowns. |
| Causal model | 18 | Branching mechanisms, conditions, barriers, recovery and luck; every arrow reviewed. |
| Tests and counterfactual | 12 | Discriminating predictions, safe method, confounders and falsifiers. |
| Human and organizational analysis | 8 | Local rationality, interface, workload, authority and due-process boundary. |
| Controls and actions | 10 | Layered controls, owners, priority, tests, rollback and side effects. |
| Effectiveness and adoption | 6 | Exercise, telemetry, recurrence window and similar-system scope. |
| Communication and safety | 4 | Clear uncertainty, neutral language and publication or access review. |

Passing this artifact means the submission met this rubric in this scenario. It does not award professional mastery. Mastery requires repeated performance across unfamiliar incidents, review by practitioners, responsible production execution and durable outcomes.

## References and review

The companion reference records `REF-0274` through `REF-0288` preserve title, publisher, URL, retrieval date, usage and limits. Start with the original sources instead of repeating phrases detached from context.

Key anchors include Google SRE guidance on postmortem culture and worked examples; Google guidance on effective troubleshooting and lessons learned; AWS Well-Architected operational RCA practice; Microsoft incident-management design guidance; NIST guidance relevant to incident handling and security evidence; CISA incident-response material; and established human-factors, safety and systems-analysis sources. These sources use different terms and scopes. This lesson synthesizes them; it does not claim they are interchangeable.

Review checklist:

- Are impact and recovery verified at user and data boundaries?
- Can each factual statement reach preserved evidence?
- Are raw time, normalized time, offset and uncertainty visible?
- Could responders have known each fact at decision time?
- Does every causal arrow name a mechanism and confidence?
- Were alternatives and rejecting evidence actively sought?
- Are human actions explained without humiliation or evasion?
- Are security, privacy, legal, safety and access boundaries respected?
- Do actions target demonstrated risks across multiple defense layers?
- Are implementation, acceptance and effectiveness separate?
- Is there a recurrence window and a path to similar systems?
- Are unknowns, dissent and later revisions preserved?

Re-review this chapter when reference guidance, organizational incident policy, evidence systems, privacy or security obligations, or lesson schemas change. Re-run the lab after Python or shell changes. A rendered page is readable evidence, not mastery; only assessed transfer and responsible operational performance support that claim.
