---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0008",
  "aliases": ["V00-L02", "evidence-driven-troubleshooting"],
  "curriculumIds": ["DBG-001"],
  "slug": "evidence-driven-troubleshooting",
  "route": "/book/start/evidence-driven-troubleshooting",
  "order": 2,
  "volume": "00-start-safely",
  "title": "Evidence-driven troubleshooting: FRAME, hypotheses, and safe moves",
  "summary": "Learn to turn an ambiguous symptom into a bounded incident model, collect proof from the first abnormal boundary, test competing hypotheses safely, restore the real operation, and encode prevention without pretending uncertainty is gone.",
  "domain": "foundations",
  "level": {
    "from": "foundation",
    "to": "expert"
  },
  "estimatedMinutes": 240,
  "prerequisiteLessonIds": ["LES-0007"],
  "prerequisiteCurriculumIds": ["FND-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The guided incident runs as a normal non-root user with Bash, Python 3.8 or newer, and the base utilities checked by the lab. It uses deterministic foreground virtual-model evidence, a private lesson-owned temporary root, and no install, sudo, network, port, container, sleep, background worker, or real resource pressure."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The same guarded lifecycle and deterministic model are supported. Shell wall-clock duration may vary, but modeled evidence is virtual and must not be described as host or production performance."
    },
    {
      "platform": "Production, containers, Kubernetes, cloud, private cloud, CI/CD, and data platforms",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Transfer sections map FRAME to real incident boundaries but create no external account, cluster, virtual machine, paid resource, credential, or production change."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "data-platform-engineer",
    "incident-commander",
    "technical-lead"
  ],
  "learningObjectives": [
    "Frame an incident around one failed user or workload operation, its scope, impact, recovery target, constraints, and decision authority.",
    "Keep supplied facts, local observations, assumptions, bounded inferences, hypotheses, unknowns, and unverified claims visibly separate.",
    "Draw the request or state path, identify the owner of every transition, and locate the first observed abnormal boundary instead of chasing the loudest symptom.",
    "Build at least three competing mechanism hypotheses and name evidence that would support, weaken, or reject each one.",
    "Use baseline, cohort, revision, timeline, and outcome comparisons without confusing aggregation, correlation, or missing data with causation.",
    "Design a bounded informative experiment with a prediction, authorization boundary, maximum scope, success, abort, rollback, and preserved evidence.",
    "Separate mitigation, restoration, verification, causal analysis, and prevention so a restarted process is never mistaken for recovered service.",
    "Communicate confidence and uncertainty precisely, preserve sanitized evidence, and turn the established mechanism into a tested preventive control."
  ],
  "productionSignals": [
    "A deployment finished shortly before errors began, but affected and healthy cohorts have not yet been compared.",
    "A process, pod, unit, controller, or pipeline is reported running or successful while the user operation still fails.",
    "One error string names a dependency, but aggregate dependency dashboards appear normal.",
    "CPU, memory, or disk looks normal while latency, failures, queue age, or missing outcomes rise.",
    "Retries, restarts, replacements, or reconciliation attempts increase after the first failure and may amplify it.",
    "A regional or fleet average hides severe impact in one zone, tenant, revision, endpoint, request shape, or priority class.",
    "A mitigation improves one component signal without proving durable results, backlog reconciliation, or the real user journey.",
    "The team has many commands and dashboards but cannot say which question each signal answers or what would falsify the top hypothesis."
  ],
  "diagrams": [
    {
      "id": "LES-0008-DIA-001",
      "title": "Operation, evidence, and decision boundaries",
      "direction": "left-to-right",
      "boundaries": ["user intent", "admission", "work handoff", "application", "dependency", "published result", "user verification"],
      "evidencePoints": ["operation ID", "revision and cohort", "accepted state", "stage timestamp and result", "dependency request and outcome", "durable result identity", "real operation success"],
      "textAlternative": "One operation moves from user intent through admission, a handoff, application work, a dependency, and a published result back to the user; correlated evidence at each boundary exposes the first transition whose output differs from a healthy comparison."
    },
    {
      "id": "LES-0008-DIA-002",
      "title": "FRAME is a controlled learning loop",
      "direction": "cyclic",
      "boundaries": ["Frame", "Retrieve", "Analyze", "Make a safe move", "Evaluate and encode"],
      "evidencePoints": ["impact and recovery target", "facts and proof limits", "ranked falsifiable hypotheses", "prediction and control envelope", "user verification and prevention test"],
      "textAlternative": "FRAME begins by defining the failed operation and constraints, retrieves bounded evidence, analyzes competing mechanisms, makes one predicted reversible move, and evaluates restoration and prevention; new evidence can return the engineer to any earlier stage."
    },
    {
      "id": "LES-0008-DIA-003",
      "title": "Symptom, mechanism, amplification, and recovery",
      "direction": "top-to-bottom",
      "boundaries": ["trigger or precondition", "first abnormal mechanism", "amplification", "failed operation", "mitigation", "restoration", "prevention verification"],
      "evidencePoints": ["change identity", "first divergent state", "retry or replacement rate", "user-impact indicator", "control action", "real-operation result", "reproduction or guard test"],
      "textAlternative": "A trigger or precondition reaches the first abnormal mechanism, may be amplified by retries or replacement, and causes user impact; mitigation stops harm, restoration proves the operation, and a later test verifies the preventive control."
    }
  ],
  "commands": [
    {
      "id": "LES-0008-CMD-001",
      "question": "Which release, kernel, working directory, effective identity, and selected non-mutating dependencies will define this evidence boundary?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -sr; pwd; id; command -v bash basename cat cmp dirname find grep id mktemp python3 realpath stat",
      "runFrom": "The exact Ubuntu 24.04 or WSL 2 Ubuntu shell that will run the lesson, before setup",
      "expectedBranches": [
        {
          "when": "Ubuntu 24.04 is visible, the effective UID is nonzero, the repository root is intended, and every displayed command resolves",
          "meaning": "The observed shell matches the stated platform, identity, location, and selected non-mutating dependency preconditions.",
          "nextEvidence": "Run the guarded lab check for the complete dependency set; displayed command presence does not prove compatible behavior or safe state."
        },
        {
          "when": "The release differs, UID is zero, location is wrong, or a displayed command does not resolve",
          "meaning": "The tested environment or a selected dependency is absent.",
          "nextEvidence": "Stop, record the mismatch, and change to the supported normal-user environment; this lesson never installs or bypasses a refusal."
        }
      ],
      "proves": "The displayed release metadata, kernel, shell directory, effective identity and group data, and selected PATH resolutions at that moment.",
      "doesNotProve": "Binary provenance, compatible versions, safe temporary-directory state, lab readiness, production health, or learner understanding."
    },
    {
      "id": "LES-0008-CMD-002",
      "question": "Does the harness accept the current environment and registered state without changing anything?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh check",
      "runFrom": "Repository root as the same normal user",
      "expectedBranches": [
        {
          "when": "The check reports a ready environment and absent or strictly valid registered state",
          "meaning": "Implemented dependency, UID, temporary-root, fixture, descriptor, identity, and applicable state guards accepted.",
          "nextEvidence": "If absent, write the baseline prediction before setup; if present, inspect status and continue only the recorded lifecycle."
        },
        {
          "when": "The check refuses",
          "meaning": "A required environment or state invariant is not satisfied.",
          "nextEvidence": "Preserve the first refusal and stop; never edit a descriptor or delete an unknown path to force progress."
        }
      ],
      "proves": "Only that the current implementation's read-only preflight and applicable strict state validation accepted this moment.",
      "doesNotProve": "That later mutation will succeed, an unregistered similar path belongs to the lab, the incident cause is known, or refusal is safe to override."
    },
    {
      "id": "LES-0008-CMD-003",
      "question": "Can the lab create or recognize one private, identity-guarded workspace?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh setup",
      "runFrom": "Repository root after an accepted check, as the same normal user",
      "expectedBranches": [
        {
          "when": "Setup reports complete or already present and identifies one lesson-prefixed root",
          "meaning": "The harness created or strictly recognized its private descriptor, root, sentinel, manifest, model and allowlisted initial state.",
          "nextEvidence": "Run status and record that baseline is pending before generating it."
        },
        {
          "when": "Setup refuses",
          "meaning": "The harness cannot prove safe ownership or construct the declared workspace.",
          "nextEvidence": "Stop and retain the diagnostic; use neither recursive deletion nor manual state repair."
        }
      ],
      "proves": "That setup's implemented guards accepted and its declared lesson-owned resources now exist or were already strictly valid.",
      "doesNotProve": "That a baseline or case ran, the fixture represents production, every filesystem attack is impossible, or cleanup can be skipped.",
      "cleanup": "Finish with the guarded cleanup command and its built-in absence proof."
    },
    {
      "id": "LES-0008-CMD-004",
      "question": "What does the same modeled operation look like before any incident is injected?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh run baseline",
      "runFrom": "The guarded ready workspace before any case is active",
      "expectedBranches": [
        {
          "when": "The baseline is recorded and the modeled operation succeeds",
          "meaning": "The fixture stored one immutable healthy comparison using its fixed virtual evidence contract.",
          "nextEvidence": "Decode every baseline field and write expected guided-case changes before injection."
        },
        {
          "when": "Baseline already exists or validation refuses",
          "meaning": "The one-run order or immutable state contract is not satisfied.",
          "nextEvidence": "Inspect status; use guarded reset only if its exact recovery contract accepts the state."
        }
      ],
      "proves": "The versioned model's healthy result for this workspace and baseline profile.",
      "doesNotProve": "Host performance, production capacity, absence of every latent fault, or that later observations use the same scope unless identities are compared.",
      "cleanup": "The baseline is a small immutable allowlisted artifact removed only by guarded cleanup or reset."
    },
    {
      "id": "LES-0008-CMD-005",
      "question": "Can the guided ambiguous case be activated without editing or revealing the state manually?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh inject guided",
      "runFrom": "The same workspace after one valid baseline and before any other active case",
      "expectedBranches": [
        {
          "when": "The guided case becomes active",
          "meaning": "One immutable case record is registered; the supported observation and probe interfaces can now expose bounded evidence.",
          "nextEvidence": "Write facts versus assumptions from the symptom output before probing a favored component."
        },
        {
          "when": "A case is active, baseline is missing, or validation refuses",
          "meaning": "The one-case lifecycle or guarded artifact contract is not satisfied.",
          "nextEvidence": "Preserve status and the refusal; do not inject another case or edit state."
        }
      ],
      "proves": "That the harness activated its versioned guided case after applicable guards passed.",
      "doesNotProve": "The incident mechanism, which hypothesis ranks first, that a production system behaves the same way, or that injection itself is learner evidence.",
      "cleanup": "Recovery and operation verification precede final guarded cleanup; a second case requires reset."
    },
    {
      "id": "LES-0008-CMD-006",
      "question": "What do the symptom, timeline, path, and change views report before a component probe?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh observe symptoms && bash book/labs/LES-0008-frame-troubleshooting/lab.sh observe timeline && bash book/labs/LES-0008-frame-troubleshooting/lab.sh observe path && bash book/labs/LES-0008-frame-troubleshooting/lab.sh observe changes",
      "runFrom": "The same active guided-case workspace",
      "expectedBranches": [
        {
          "when": "All four deterministic views complete in order",
          "meaning": "The harness exposed its bounded current symptoms, ordered events, state path, and recorded changes without storing a new observation artifact.",
          "nextEvidence": "Classify each field and build three hypotheses that the targeted probes can discriminate."
        },
        {
          "when": "Any view refuses or the command chain stops",
          "meaning": "The required baseline, active case, model, or strict state contract did not pass for that view.",
          "nextEvidence": "Retain the first nonzero branch and run status; later views did not execute after the failed `&&`."
        }
      ],
      "proves": "The exact deterministic view outputs produced by the active case and that each preceding command exited successfully before the next began.",
      "doesNotProve": "That every output field is causal, that a missing signal means healthy behavior, host elapsed performance, or a final diagnosis."
    },
    {
      "id": "LES-0008-CMD-007",
      "question": "How do application, dependency, and queue evidence differ for the same active case?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh probe app-only && bash book/labs/LES-0008-frame-troubleshooting/lab.sh probe dependency-only && bash book/labs/LES-0008-frame-troubleshooting/lab.sh probe queue",
      "runFrom": "The same active guided-case workspace after writing competing hypotheses",
      "expectedBranches": [
        {
          "when": "All three deterministic probes complete in order",
          "meaning": "The fixture exposed evidence from three owner boundaries without changing the modeled case.",
          "nextEvidence": "Use the differences to support or reject mechanisms, then choose whether either bounded experiment is justified."
        },
        {
          "when": "A probe refuses and the chain stops",
          "meaning": "A lifecycle or strict state requirement was not satisfied; later probes did not execute.",
          "nextEvidence": "Keep the first failure and inspect status rather than substituting manual file inspection."
        }
      ],
      "proves": "Only the versioned application, dependency, and queue views for the active modeled case and successful command ordering.",
      "doesNotProve": "That the named boundary is the root cause, that its owner should be paged, that production telemetry is complete, or that a change is safe."
    },
    {
      "id": "LES-0008-CMD-008",
      "question": "Does disabling modeled retry behavior change the signals predicted by the retry-amplification hypothesis?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh experiment retry-off",
      "runFrom": "An active case after a written prediction, with no conflicting completed experiment order",
      "expectedBranches": [
        {
          "when": "The retry-off experiment is accepted and one immutable result is recorded",
          "meaning": "The model applied its bounded retry-control counterfactual and returned the fixed evidence contract.",
          "nextEvidence": "Compare predicted and observed attempt, queue, dependency, and operation outcomes; say supported or weakened, not proved."
        },
        {
          "when": "The experiment already exists, order is invalid, or validation refuses",
          "meaning": "The immutable experiment or lifecycle contract prevents this mutation.",
          "nextEvidence": "Preserve the refusal and status; do not edit or replace the result."
        }
      ],
      "proves": "The deterministic result of the versioned retry-off counterfactual for this active case.",
      "doesNotProve": "That production retries caused the first fault, that disabling retries is safe for durable work, or that the host performed faster.",
      "cleanup": "The immutable experiment result is allowlisted and removed only by guarded cleanup or reset."
    },
    {
      "id": "LES-0008-CMD-009",
      "question": "Does the modeled known-good worker counterfactual change the signals predicted by a worker-cohort hypothesis?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh experiment known-good-workers",
      "runFrom": "An active case after a written prediction and any required earlier experiment ordering",
      "expectedBranches": [
        {
          "when": "The known-good-workers experiment is accepted and one immutable result is recorded",
          "meaning": "The model substituted its bounded known-good worker cohort and returned comparable evidence.",
          "nextEvidence": "Compare the first changed boundary and user outcome while checking whether dependency or queue pressure moved elsewhere."
        },
        {
          "when": "The experiment already exists, order is invalid, or validation refuses",
          "meaning": "The immutable experiment or lifecycle contract prevents this mutation.",
          "nextEvidence": "Retain the exact refusal; never rewrite an experiment artifact to fit the hypothesis."
        }
      ],
      "proves": "The deterministic result of the versioned known-good worker counterfactual for this active case.",
      "doesNotProve": "That real workers are identical, a rollback is production-safe, shared dependencies have headroom, or final causality is established.",
      "cleanup": "The immutable result remains inside the validated root until guarded cleanup or reset."
    },
    {
      "id": "LES-0008-CMD-010",
      "question": "Can the supported recovery path restore the modeled case after evidence is preserved?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh recover",
      "runFrom": "The same active case after required observations and any chosen experiment",
      "expectedBranches": [
        {
          "when": "Recovery is recorded complete",
          "meaning": "The model applied its supported restoration transition and stored one immutable recovery result.",
          "nextEvidence": "Run verify-operation; recovery state is not yet end-to-end proof."
        },
        {
          "when": "Recovery is premature, already recorded, or strict validation refuses",
          "meaning": "The required lifecycle or state contract is not satisfied.",
          "nextEvidence": "Keep the refusal and inspect status; never fabricate a recovery result."
        }
      ],
      "proves": "Only that the supported modeled recovery transition completed under its implemented guards.",
      "doesNotProve": "That the real operation works, backlog is reconciled, causal analysis is complete, or the same action is safe in production.",
      "cleanup": "Recovery writes one immutable allowlisted artifact removed by guarded cleanup or reset."
    },
    {
      "id": "LES-0008-CMD-011",
      "question": "Does the real modeled operation succeed after recovery, and what lifecycle state is now registered?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh verify-operation && bash book/labs/LES-0008-frame-troubleshooting/lab.sh status",
      "runFrom": "The recovered workspace before cleanup",
      "expectedBranches": [
        {
          "when": "Operation verification completes and status reports baseline recorded, one active case, recovery complete, and operation verification complete",
          "meaning": "The modeled user operation passed its versioned verification and strict status validation recognized the completed lifecycle.",
          "nextEvidence": "Explain proof limits, preserve the FRAME record, then run guarded cleanup."
        },
        {
          "when": "Operation verification refuses or fails",
          "meaning": "Status does not execute after the failed `&&`; the real modeled outcome is not verified.",
          "nextEvidence": "Preserve the first failure and do not claim recovery; inspect supported evidence without editing state."
        }
      ],
      "proves": "The modeled operation's fixed post-recovery assertion and, only if it passed, the strict registered status fields at that moment.",
      "doesNotProve": "Production recovery, long-term stability, root cause, learner mastery, or that cleanup has occurred.",
      "cleanup": "The verification artifact and all other allowlisted state still require guarded cleanup."
    },
    {
      "id": "LES-0008-CMD-012",
      "question": "Can the harness remove only its validated resources and then report clean absent state?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/lab.sh cleanup && bash book/labs/LES-0008-frame-troubleshooting/lab.sh check",
      "runFrom": "Repository root after the learning evidence has been sanitized and retained separately",
      "expectedBranches": [
        {
          "when": "Cleanup reports `cleanup=complete`, `state=absent`, `cleanup_proof_scope=descriptor-and-owned-candidates-at-check`, and `cleanup_proven=true`, then the following check reports absent state",
          "meaning": "Guarded cleanup removed the exact registered descriptor and root after accepting only allowlisted current-UID regular single-link artifacts with no unknown names; its final point-in-time scan found no matching canonical current-UID-owned candidate.",
          "nextEvidence": "Retain the explicitly scoped cleanup proof with the FRAME report, not the random local path, and do not claim protection against later path creation."
        },
        {
          "when": "Cleanup refuses or fails",
          "meaning": "The `&&` prevents the check; descriptor, root, sentinel, owner, type, link, allowlisted-name, exact removal, or point-in-time absence proof did not satisfy cleanup.",
          "nextEvidence": "Stop and preserve the refusal for review; never use broad or recursive manual deletion."
        }
      ],
      "proves": "At that check, the exact registered descriptor and root were absent and the implemented candidate scan found no matching canonical current-UID-owned lesson root; the chained check independently observed absent registered state.",
      "doesNotProve": "Future absence after another process creates a path, absence of differently owned or noncanonical paths, semantic validity of removed model or lifecycle content, safety of unrelated paths, evidence sanitization, or learner understanding.",
      "cleanup": "This is the final guarded cleanup action itself; its four-field scoped proof and `&&`-chained read-only check must follow."
    },
    {
      "id": "LES-0008-CMD-013",
      "question": "Does the lab's separate clean-state verifier accept its supported lifecycle and refusal invariants?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0008-frame-troubleshooting/verify.sh",
      "runFrom": "Repository root from clean absent state, as a normal user, for harness verification rather than the learner incident sequence",
      "expectedBranches": [
        {
          "when": "The verifier completes and proves cleanup",
          "meaning": "Its implemented positive, negative, lifecycle, artifact, recovery, operation, cleanup, unregistered-root refusal, and scoped learner-README answer-isolation assertions passed in this environment.",
          "nextEvidence": "Retain the summary only as engineering QA evidence; the static answer-isolation scan covers a named spoiler list in the learner README, and learner reasoning still requires a separate submission."
        },
        {
          "when": "The verifier stops at an assertion or refusal",
          "meaning": "A tested harness invariant did not hold or the environment was not clean and supported.",
          "nextEvidence": "Preserve the first failure and inspect only the exact registered state; do not weaken a guard."
        }
      ],
      "proves": "That the verifier's encoded assertions passed in the named local environment for that run, including preservation on unregistered-root refusal and absence of its listed transfer spoiler strings in the learner README.",
      "doesNotProve": "Complete shell safety, freedom from every race or filesystem attack, absence of every possible answer leak outside the scoped README pattern scan, production equivalence, content acceptance, or learner mastery.",
      "cleanup": "The verifier must trap and prove removal of any workspace it creates; a failed cleanup requires exact-state review."
    }
  ],
  "labs": [
    {
      "id": "LES-0008-LAB-001",
      "title": "FRAME an ambiguous incident and verify recovery",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS; normal non-root user; Bash, Python 3.8 or newer, and checked base utilities; root-owned sticky /tmp; deterministic foreground virtual-time model; no installation, sudo, network, port, Docker, Kubernetes, background worker, sleep, or real CPU, memory, disk, queue, or dependency pressure",
      "timeMinutes": 70,
      "privilege": "Normal non-root user only; the harness refuses effective UID 0 and never invokes sudo",
      "network": "None; the fixture performs no socket, name-resolution, download, login, external request, telemetry export, or cloud operation",
      "changes": [
        "Creates one private lesson-prefixed random directory under /tmp and one private UID-scoped state descriptor after strict path, type, owner, mode, link, realpath and sentinel validation.",
        "Copies one reviewed deterministic model and writes an exact manifest, sentinel, immutable baseline, one immutable active-case record, allowlisted experiment results, recovery result, and operation-verification result as the lifecycle advances.",
        "Runs foreground Bash and Python processes only; observation and probe views are deterministic model output and are not stored as new artifacts."
      ],
      "abortConditions": [
        "Effective UID is zero, Ubuntu or required tools are unsupported, Python is older than 3.8, /tmp is not the required real root-owned sticky directory, or the reviewed model is missing or replaced.",
        "The UID descriptor, root, sentinel, owner, mode, type, link count, real path, basename prefix, manifest, copied model, immutable record, allowlist, field order, value invariant, or lifecycle order differs from the applicable contract.",
        "Any known entry becomes a symbolic link or unsafe hard link, an unknown entry appears, a registered path escapes the exact lesson prefix, or a second case is requested without guarded reset.",
        "A supported command returns nonzero, modeled verification fails, cleanup cannot prove its scoped point-in-time descriptor/root/candidate absence, or output differs from the versioned deterministic contract."
      ],
      "recovery": "Use `status` when strict state remains valid. `recover` changes the modeled incident only after the required lifecycle and never substitutes for `verify-operation`. `reset` performs guarded cleanup followed by fresh setup and is the only supported way to start a different case; it refuses unsafe identity or unknown artifacts. If cleanup or reset refuses, stop and preserve the diagnostic rather than editing state or deleting recursively.",
      "cleanupProof": "`cleanup` requires the exact mode-0600 current-UID regular single-link descriptor and its exact lesson, UID, and root identity; the canonical mode-0700 current-UID non-symlink root; and the exact mode-0600 current-UID regular single-link sentinel identity. Every remaining root entry must have an allowlisted name and be a current-UID regular non-symlink single-link file; unknown names refuse cleanup. Recovery-tolerant cleanup deliberately does not require artifact modes, copied-model or manifest bytes, or lifecycle-summary semantics to remain valid. It removes exact allowlisted candidates individually, removes the sentinel last, removes the empty root and descriptor, proves those exact paths absent, and performs a point-in-time scan for matching canonical current-UID-owned lesson-root candidates. Success includes `cleanup_proof_scope=descriptor-and-owned-candidates-at-check`; this does not prevent a later process from creating a new path. A following `check` independently reports absent registered state. `verify.sh` is engineering QA and does not replace learner cleanup.",
      "path": "book/labs/LES-0008-frame-troubleshooting"
    }
  ],
  "incidents": [
    {
      "id": "LES-0008-INC-001",
      "signal": "Six minutes after a release, 12 percent of report exports fail only in cohort B. Processes remain active, fleet CPU and downstream p95 look normal, one timeout appears in application logs, and retry attempts triple.",
      "firstThought": "This is an affected-versus-healthy path comparison, not permission to call the deployment or dependency the cause; find the first revision, configuration, route, attempt, state, or outcome transition that differs.",
      "safePath": "Freeze rollout through the approved control; preserve one failed B and one successful A timeline; separate original requests from attempts; rank release/configuration skew, partial dependency path, and retry amplification; begin read-only; if evidence supports the release boundary, request a bounded rollback canary with integrity, success, abort, and rollback-forward criteria; verify a real export, retries, backlog, dependency, and healthy cohort.",
      "trap": "Restarting and rolling back because the deploy happened first can erase volatile evidence, amplify retries, widen blast radius, and still leave a shared dependency or bad configuration outside the binary unchanged."
    },
    {
      "id": "LES-0008-INC-002",
      "signal": "A platform controller accepts a new revision, but instances in one zone fail readiness and are replaced repeatedly while existing instances still serve some checkout traffic and shared identity errors rise slightly at regional scope.",
      "firstThought": "Separate control-plane acceptance from data-plane checkout, protect surviving capacity, and treat replacement retries as a possible amplifier across a shared failure domain.",
      "safePath": "Establish incident roles; pause rollout and boundedly control replacement amplification through approved mechanisms; compare old/new in-zone and new across zones; trace configuration, identity, readiness, route, and checkout; choose a zonal rollback canary or pretested dependency recovery from the first divergence; verify ready capacity, correct routing, exactly-once checkout, dependency recovery, and no healthy-zone regression.",
      "trap": "Replacing more instances or coupling every checkout to the controller can turn a partial convergence problem into a serving outage and overload the shared service needed for recovery."
    }
  ],
  "assessmentIds": ["ASM-0007", "ASM-0008", "ASM-0009"],
  "referenceIds": ["REF-0017", "REF-0018", "REF-0019", "REF-0020", "REF-0021", "REF-0022", "REF-0023", "REF-0024"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2026-11-02",
  "limitations": [
    "The guided fixture is a deterministic foreground virtual model, not an operating-system, network, dependency, scheduler, queue, benchmark, or production service measurement.",
    "The chapter teaches a reusable reasoning loop but does not replace subject knowledge; a correct method still needs accurate Linux, network, application, data, security, and platform mechanisms from later lessons.",
    "FRAME is a repository teaching mnemonic, not an industry standard, automated root-cause engine, or guarantee that evidence is complete.",
    "Observation and probe views are intentionally bounded. Real incidents can have missing, delayed, sampled, aggregated, corrupted, sensitive, or mutually inconsistent telemetry.",
    "A successful experiment or rollback can support a mechanism and restore a cohort without proving a single root cause, global safety, long-term stability, or prevention effectiveness.",
    "Incident roles, authorization, change controls, data handling, retention, security response, and communications vary by organization; production actions require the owning process and approver.",
    "No published answer, completed guided case, verifier pass, bookmark, reading marker, or generated worksheet establishes learner mastery; original sanitized transfer evidence and authorized review remain required."
  ]
}
---

# Evidence-driven troubleshooting: FRAME, hypotheses, and safe moves

## What you see and first thought

The moment an incident becomes noisy, the room starts offering verbs: restart, roll back, scale, fail over, clear, delete, disable. A senior engineer does not win by choosing a verb fastest. The senior move is to define what is failing, find the earliest boundary where reality diverges from expectation, and choose the smallest action that either teaches something important or restores the operation safely.

Suppose a deployment completed at 09:50. At 10:04, users report missing exports. CPU is normal. Every process is `active`. One log line says `dependency timeout`. Retry traffic is rising. Which statement is the diagnosis?

None of them.

They are clues with different owners and proof limits:

- deploy time is correlation until a mechanism connects it to failure;
- `active` is service-manager state, not export success;
- normal fleet CPU describes a sampled resource over a population, not every wait boundary;
- a timeout tells you a deadline expired at the recording component, not why;
- retries can be a response to failure and an amplifier of failure;
- missing exports describe a user outcome, but not the first broken transition.

When you see that mixture, hold this sentence:

> The alarm names an investigation. It does not grant a diagnosis. I will define the failed operation, compare affected and healthy paths, and locate the first abnormal boundary before changing state.

### The five moves you should remember

FRAME means:

1. **Frame** the operation, impact, scope, recovery target, constraints, and authority.
2. **Retrieve** evidence from the path, with sources, times, units, identities, and proof limits.
3. **Analyze** competing mechanisms that can be supported or rejected.
4. **Make a safe move** with prediction, authorization, bounded scope, abort, and rollback.
5. **Evaluate and encode** the real recovery, remaining uncertainty, causal chain, and tested prevention.

This is a loop, not a waterfall. New evidence can force you back to framing because the affected cohort was wrong. A failed experiment can send you back to hypothesis ranking. A successful mitigation can expose a second failure. A recovered component can still leave queued, duplicated, stale, or unpublished work.

### What good troubleshooting sounds like

Weak:

> The deploy caused it. Restart and roll back.

Strong:

> Facts: export failures began after the deploy and currently cluster in revision B. That timing supports a release-related hypothesis but does not prove it. I will compare one failed B export with one successful A export across configuration, route, attempts, dependency outcome, publication, and user retrieval. If the first divergence is tied to B, I will request a bounded rollback canary. Success is a correct export without increased dependency errors; abort on integrity mismatch, worse success, or wider impact. Then I will verify the cohort and reconcile retries and backlog.

The strong version is not longer for decoration. It makes the decision inspectable. Another engineer can challenge the evidence, see what is unknown, and stop the move if its control envelope breaks.

### First principle: restore and learn are related, not identical

During a high-impact incident, safe restoration can take priority over complete causality. You may roll back a canary because evidence shows it is the safest tested restoration even though the exact defective line is unknown. Record that honestly:

- **restoration evidence:** the canary operation recovered after rollback;
- **causal confidence:** a release-related mechanism is stronger, exact defect unresolved;
- **next work:** compare code, configuration, schema, identity, and dependency interaction;
- **prevention evidence:** not yet available until the new guard is tested.

Do not delay recovery while seeking philosophical certainty. Do not call recovery proof a root-cause analysis.

## Terms before commands

### Incident, operation, expected behavior, and impact

An **incident** is an event that requires a coordinated response because a service, workload, security boundary, data obligation, delivery system, or business outcome is outside an acceptable condition. The word does not require a particular severity system.

The **operation** is the exact thing an initiator wants completed: publish one export, authenticate one request, deploy one revision, reconcile one object, restore one database, or finish one build. “The app is down” is too vague. “A customer cannot retrieve a requested export within five minutes” is an operation and expectation you can trace.

**Expected behavior** is the observable contract for that operation. **Impact** is the consequence of deviation: failed checkouts, delayed jobs, unauthorized access, stale policy, duplicate payment, missed recovery objective, blocked delivery, or excessive cost.

On call, define these first because a component can look unhealthy without user impact, and user impact can exist while every component dashboard looks green.

### Scope, cohort, population, interval, and namespace

**Scope** states what evidence or action covers: which environment, region, zone, host, namespace, service, tenant, endpoint, release, request shape, or priority class.

A **cohort** is a selected group sharing a useful attribute, such as revision B, one zone, or one tenant. A **population** is the complete group represented by a statistic. A **time interval** is the start and end over which a rate, count, or sample was measured. A **namespace** is the boundary that gives a name or resource its meaning, such as one process namespace, mount namespace, Kubernetes namespace, cloud account, or database schema.

If one zone is failing and two are healthy, a regional average can hide the incident. If a command runs inside a container, it may describe the container's mount or process namespace rather than the host. Always attach scope to evidence.

### Symptom, signal, telemetry, and evidence

A **symptom** is observed undesirable behavior, usually close to the consumer: requests fail, builds stall, or results are missing.

A **signal** is a measurable indication: a count, event, state, duration, sample, trace span, or log record. **Telemetry** is instrumented data emitted or collected to observe a system. A metric, log, trace, event, or profile becomes **evidence** only when you can explain its source, identity, scope, time semantics, units, integrity, and the question it helps answer.

More telemetry is not automatically stronger evidence. Ten dashboards that aggregate the wrong cohort can mislead more efficiently than one correlated request timeline.

### Fact, local observation, documented claim, and unverified claim

A **supplied fact** is a statement given by a trusted incident source, but you should still record who supplied it and its scope. A **local observation** is what a named command or experiment returned in a named environment. A **documented claim** comes from an identified manual, specification, source file, or upstream record. An **unverified claim** has not yet been supported by the needed source or experiment.

Good wording:

> The affected-cohort query returned 120 failures from 1,000 attempts between 10:00 and 10:05 UTC.

Weak wording:

> Twelve percent of everything is broken.

The first preserves query scope and time. The second quietly expands a bounded observation into a universal claim.

### Assumption, inference, hypothesis, and unknown

An **assumption** is treated as true temporarily but is not verified. An **inference** is a conclusion supported by named evidence within limits. A **hypothesis** is a falsifiable explanation. An **unknown** is a material unanswered question.

Example:

- fact: failures are observed in cohort B;
- assumption: cohort labels match the effective binary and configuration;
- inference: the current impact is associated with that cohort;
- hypothesis: cohort B selects an invalid dependency configuration;
- unknown: whether every failed request used the same endpoint.

These labels prevent a team from repeating an assumption until it sounds like a fact.

### Mechanism, cause, contributing condition, and causal chain

A **mechanism** explains how state or behavior changes: a connection pool is fully occupied, a resolver returns a stale address, a policy denies an identity, a queue consumer stops advancing, or an incompatible schema rejects a message.

A **cause** is a condition in the supported causal chain. A **contributing condition** increases likelihood or impact without necessarily initiating the failure. A **trigger** starts the observed chain. A **causal chain** connects them to the failed operation using evidence, not only timing:

```text
condition or trigger
  -> first abnormal mechanism
  -> propagation or amplification
  -> failed operation
  -> user impact
```

Real incidents often have several necessary conditions. “Root cause” can become misleading when it encourages one noun and hides weak containment, missing validation, correlated dependencies, or unsafe feedback. Prefer an explicit chain and state which arrows remain inferred.

### Correlation, causation, temporal order, and counterfactual

**Correlation** means two observations vary together. **Temporal order** means one was observed before another. **Causation** requires a supported mechanism showing that one condition helps produce another under the stated circumstances.

A **counterfactual** asks what would happen if one relevant condition differed. A canary rollback can be a bounded counterfactual: same request shape and environment, older revision. If it recovers, release-related confidence rises. Differences besides revision still matter, so the result is not universal proof.

### Baseline, healthy comparison, invariant, and change

A **baseline** is a recorded reference condition with scope and time. “Normal” without a date, population, and workload is not a baseline. A **healthy comparison** is a currently successful path chosen to reduce irrelevant differences. An **invariant** is a condition intended always to hold, such as accepted work being accounted for or a published artifact matching its manifest. A **change** is any relevant difference in code, configuration, data, identity, dependency, infrastructure, traffic, or operator action.

The best comparison is not always yesterday. During a partial failure, one successful request from the same minute, tenant, operation, and host class may be more informative.

### First abnormal boundary and first meaningful failure

A **boundary** is a handoff where ownership, representation, identity, or state changes. The **first observed abnormal boundary** is the earliest transition where a healthy or expected input is followed by abnormal output, wait, error, state, or correctness compared with a matched reference.

This is not automatically the root cause. Telemetry before it may be missing. But it is a precise place to investigate next and a better handoff than “the database looks slow.”

The **first meaningful failure** in a traceback or event chain is the earliest failure that explains why later lines became possible. The loudest final exception is often only where propagation became visible.

### Falsifiability, discriminating evidence, and negative result

A hypothesis is **falsifiable** when an observation could weaken or reject it. **Discriminating evidence** produces different predictions for competing hypotheses.

Hypothesis: all workers are CPU-saturated. Prediction: affected workers show sustained runnable demand and CPU limitation aligned with slow work. If workers instead spend the interval waiting on one dependency while CPU and throttling are low, the pure CPU hypothesis weakens.

A **negative result** is useful when a well-designed test rejects a mechanism. Do not hide it. It reduces the search space and prevents the next engineer repeating the same unsafe guess.

### Experiment, prediction, canary, control envelope, and abort

An **experiment** deliberately changes or observes a bounded condition to distinguish hypotheses. A **prediction** states the expected result before execution. A **canary** limits a change to a small representative cohort. The **control envelope** includes target, identity, maximum scope, duration, authorization, preserved evidence, monitoring, success, abort, and recovery.

An **abort condition** is an observed threshold that stops or reverses the experiment: worse user success, data-integrity mismatch, unexpected scope, dependency saturation, missing telemetry, timeout, or rollback failure.

An uncontrolled change asks, “Did it get better?” A safe experiment asks, “Which exact observation supports or rejects this mechanism, and how do we stop if harm grows?”

### Mitigation, remediation, restoration, recovery, and verification

**Mitigation** reduces immediate harm: pause rollout, shed optional work, isolate a cohort, or apply a tested failover. **Remediation** changes the underlying defect or condition. **Restoration** returns the required operation to an acceptable state. **Recovery** includes restoration plus reconciliation of backlog, retries, stale state, partial work, and dependencies. **Verification** checks the expected outcome at every important boundary, including the real consumer operation.

Restarting a process is a change. It is not verification. A green component check is evidence at that component. It is not a checkout, export, deployment, or restore test.

### Rollback, roll forward, reversibility, and blast radius

A **rollback** returns to a previously accepted state. A **roll forward** applies a new corrective state. Neither is automatically safe: database or message schemas, irreversible side effects, security revocation, and data written by the new version can make an old version incompatible.

**Reversibility** means the action can be undone within known limits. **Blast radius** is the maximum scope of harm. A good first move minimizes blast radius while preserving enough signal to learn.

### Confidence, calibration, and uncertainty

**Confidence** is your assessed probability that a claim is correct, not your enthusiasm. **Calibration** means 70-percent claims are right roughly 70 percent of the time across many decisions. One incident cannot prove calibration, but recording confidence before and after evidence exposes overconfidence and teaches how information changed the decision.

Say:

> I am 60 percent confident the cohort configuration owns the first divergence. The most important missing evidence is the effective endpoint and identity selected by a failed and successful request.

That is more operationally useful than “probably config.”

### Prevention, detection, toil, and encoded learning

**Prevention** changes likelihood, containment, or impact. **Detection** reduces time to discover and localize. **Toil** is manual, repetitive operational work that scales poorly and has limited enduring value. **Encoded learning** turns incident knowledge into a validated guard, test, runbook, alert, rollback path, ownership rule, or design decision.

“Monitor more” is incomplete. Name the missing signal, boundary, owner, threshold or comparison, response, test, and how false positives or cost are controlled.

## Architecture map

### Diagram one: follow the operation, not the loudest dashboard

```text
direction: left to right

[consumer intent]
      | operation_id=E42
      v
[admission] -- accepted/rejected, revision, cohort
      |
      v
[handoff or queue] -- enqueue/dequeue, age, attempt lineage
      |
      v
[application] -- start/finish, config identity, exit/result
      |
      v
[dependency] -- selected target, request ID, latency, outcome
      |
      v
[published state] -- object/version/checksum/durable result
      |
      v
[consumer verification] -- correct operation outcome

At every arrow: owner + identity + timestamp + result + proof limit
```

Read this as a chain of state claims. If admission says accepted but the handoff has no item, investigate that transition. If application work completes but no result is published, a green process and successful dependency are still insufficient. If published state exists but the consumer cannot retrieve it, follow the remaining path instead of restarting the worker.

The first abnormal boundary is found by comparing one affected path with a healthy path using the same operation definition and aligned interval.

### Diagram two: FRAME converts uncertainty into controlled learning

```text
                          new evidence changes scope
                         +----------------------------+
                         |                            |
                         v                            |
[FRAME] -> operation, impact, recovery target, constraints
    |
    v
[RETRIEVE] -> facts + source + scope + time + proves / not-proves
    |
    v
[ANALYZE] -> H1, H2, H3 + mechanism + falsification
    |
    v
[MAKE SAFE MOVE] -> prediction + authority + canary + abort + rollback
    |
    v
[EVALUATE / ENCODE] -> real operation + reconciliation + causal status
    |                                  + prevention test
    +------------ unresolved -----------> back to retrieve/analyze
```

Notice what is absent: “run every command you know.” Retrieval is question-driven. Analysis requires alternatives. Mutation happens only after a prediction and safety boundary. Evaluation includes user verification and remaining uncertainty.

### Diagram three: do not collapse trigger, mechanism, and amplification

```text
revision or condition changes
          |
          v
first abnormal mechanism
  e.g. wrong identity target
          |
          +-------------------+
          |                   |
          v                   v
original attempts fail   replacement/retry loop
          |                   |
          +---------+---------+
                    v
             dependency pressure
                    |
                    v
          more waits and failures
                    |
                    v
          user operation unavailable

mitigation: contain amplification / preserve useful capacity
restoration: complete the real operation
prevention: validate target + bound feedback + test the guard
```

The deployment can be the trigger, an identity selection can be the first abnormal mechanism, and immediate retries can be the amplifier. Naming only “identity outage” or “bad deploy” loses the system behavior you need to prevent recurrence.

## Request or state path

### Start with one operation identity

Use one synthetic example throughout this lesson: export operation `E42`.

The customer asks for an export. The API accepts it. A handoff records work. A worker reads effective configuration, calls a dependency, creates an artifact, publishes its identity, and the customer retrieves it.

```text
E42 requested
  -> E42 accepted
  -> job J77 enqueued, original_operation=E42, attempt=1
  -> worker W-B12 starts revision=B, config=C9
  -> dependency call D31 targets endpoint=P2
  -> artifact A88 created with checksum H4
  -> publication record points E42 -> A88
  -> customer retrieves A88 and validates expected content
```

Every arrow can fail in several ways:

- the transition never occurs;
- it occurs late;
- it occurs twice;
- it records the wrong identity;
- it reports success before durable state exists;
- it crosses a trust boundary without the required identity;
- telemetry is lost even though work succeeds;
- work is correct internally but unavailable to the consumer.

The troubleshooting question is not “Which component is red?” It is “For this operation, where is the first expected transition absent, late, duplicate, rejected, or incorrect compared with a healthy operation?”

### Separate original operation from attempts

Retries create multiple attempts for one intent:

```text
operation E42
  +-> attempt 1 -> timeout
  +-> attempt 2 -> timeout
  `-> attempt 3 -> completed
```

If a metric counts attempts but another counts original operations, comparing them as if they share one population creates false arithmetic. You can have three requests and one customer operation. You can have an application timeout after a dependency committed a result, making a retry dangerous unless the operation is idempotent.

Always ask:

- What is the unit: user operation, request, attempt, job, message, or durable effect?
- Which outcomes are mutually exclusive?
- Can an attempt time out while the effect completes?
- Where is idempotency or deduplication state owned?
- Are retries immediate, bounded, delayed, or persistent?
- Does cancellation reach the dependency?

### Build a transition ledger

| Stage | State owner | Identity to preserve | Healthy evidence | Abnormal evidence | Proof limit |
|---|---|---|---|---|---|
| request | consumer or edge | operation ID, tenant, request shape | intent accepted once | rejection, duplicate, wrong route | acceptance is not completion |
| admission | API or controller | operation and revision | accepted/rejected reason | silent loss, unbounded admission | component response is not durable state |
| handoff | queue, database, or scheduler | job/message/object ID | enqueue and later dequeue reconcile | missing, old, duplicate, poison work | depth alone is not mechanism |
| execution | worker/process | attempt, revision, config | start, finish, exit, result | blocked, crash, wrong config | running is not useful completion |
| dependency | downstream owner | call ID, selected endpoint, identity | outcome inside budget | timeout, denial, quota, stale data | client error text is not owner proof |
| publication | storage/catalog/response | artifact/version/checksum | durable correct result | absent, stale, partial, wrong pointer | object existence is not consumer access |
| verification | consumer journey | operation and expected result | result retrieved and correct | unavailable, duplicate, corrupt | one canary is not fleet proof |

This ledger gives teams a common language. An application engineer can own execution, a data team the dependency, and a platform team routing, while everyone still reasons over one operation identity.

### Align time without pretending every clock is identical

Three time concepts matter:

- **wall time** maps an event to a calendar and timezone, useful for cross-system timelines;
- **monotonic time** measures elapsed duration without being moved backward by wall-clock corrections inside one clock domain;
- **logical order** uses sequence, revision, offset, or causal identifiers when clocks cannot be compared safely.

Do not subtract wall timestamps from unsynchronized hosts and call the result exact latency. Do not compare a five-minute average with a one-second event without stating that mismatch. Do not assume log display order is execution order when collectors buffer or reorder events.

In the lab, modeled timing is deterministic virtual evidence. It teaches transition relationships. The shell's elapsed wall time is separate and variable. Neither is a production benchmark.

### Compare along two useful axes

During a partial rollout:

1. compare **old versus new inside the affected environment** to test revision or cohort differences;
2. compare **the same revision across affected and healthy environments** to test environment or route differences.

```text
                         healthy zone       affected zone
old revision                  A                   B
new revision                  C                   D

B vs D: revision/cohort signal while zone is similar
C vs D: zonal/environment signal while revision is similar
A vs C: healthy-zone rollout behavior
A vs D: maximum difference, but many variables changed
```

This is not a randomized scientific trial. It is an operational comparison that reduces ambiguity. Record remaining differences instead of claiming every variable is controlled.

### Trace control path and data path separately

A controller may report:

```text
desired revision accepted -> reconciliation started -> replacement created
```

The user path may report:

```text
checkout routed -> identity wait -> deadline -> failed response
```

Both can be true. Controller acceptance proves a control-path transition. It does not prove readiness or the checkout. A busy controller can actively amplify a failure by creating more clients that retry the same dependency.

For every control action, ask which data-path evidence closes the loop.

## Failure zoom

### Red herring one: the recent deployment

Recent changes deserve attention because systems change for reasons. They do not deserve automatic conviction.

Deployment timing can mean:

- the binary contains a defect;
- configuration delivered with it is wrong;
- new instances choose a different route or identity;
- rollout increased concurrency and exposed an existing limit;
- cache warming or connection establishment changed load;
- an unrelated dependency failed at the same time;
- monitoring changed and only detection is new.

The safe use of deploy evidence is to identify revision cohorts, state changes, and a counterfactual comparison. “It started after deployment” is a hypothesis prior, not a complete causal chain.

### Red herring two: normal CPU

Low or normal CPU rejects only some forms of CPU saturation for the observed population and interval. Work can wait on:

- a lock, semaphore, connection pool, rate limit, or queue permit;
- disk, network, name resolution, identity, or another service;
- a single busy core hidden by host-wide average;
- cgroup throttling hidden by host capacity;
- retry timers, backoff, scheduling, or paused work;
- wrong state that fails quickly without consuming CPU.

CPU is evidence about CPU. Do not ask it to diagnose every subsystem.

### Red herring three: one error string

`dependency timeout` means a deadline expired according to the component that emitted the event. It may reflect:

- dependency service time;
- queueing before the dependency;
- DNS, connect, TLS, proxy, or pool wait included in the budget;
- an incorrect timeout value;
- a canceled response whose effect still completed;
- logging that maps several failures to one message;
- time measured from a different boundary than assumed.

Correlate endpoint, attempt, phase durations, dependency-side identity, outcome, and deadline. Never page a team only because its name appears in another component's string.

### Red herring four: healthy aggregate

An average can be mathematically correct and operationally useless. If 90 percent of traffic is healthy and 10 percent entirely fails, regional success is 90 percent while one critical tenant may see zero.

Slice only by attributes safe and useful for diagnosis. High-cardinality dimensions and sensitive identities have cost and privacy consequences. Prefer a bounded query and documented retention over permanently attaching customer identifiers to every metric.

### Red herring five: restart success

A restart can:

- clear corrupt process-local state;
- move work to another host or endpoint;
- reload corrected configuration;
- temporarily reset a leak or exhausted pool;
- erase volatile evidence;
- duplicate in-flight work;
- synchronize load and retries;
- hide a recurring defect until the next peak.

If a restart restores service, record exactly what state changed and which alternatives remain. “Restart fixed it” is a restoration observation, not prevention.

### Missing evidence is not healthy evidence

No errors can mean no errors occurred. It can also mean:

- the code path did not emit them;
- the collector failed;
- sampling dropped them;
- a query filter excluded the affected cohort;
- timestamps fell outside the window;
- cardinality limits aggregated them;
- authorization prevented collection;
- the process died before flushing.

Treat telemetry availability as its own state path: emitted, buffered, transported, processed, stored, queried, displayed.

### How a second incident is created

Suppose new instances fail identity initialization. A controller replaces them immediately. Every replacement downloads configuration and requests identity again. The identity dependency sees more traffic, becomes slower, and causes more failures.

```text
small partial fault
  -> replacements
  -> synchronized retries
  -> shared dependency pressure
  -> more readiness failures
  -> fewer serving instances
  -> larger user impact
```

The original mechanism and feedback amplifier need different controls. Fixing the dependency without bounding retries can prolong recovery. Stopping all replacement without protecting capacity can preserve broken instances. FRAME forces the trade-off into the open.

### Confidence should move with evidence

Example progression:

| Moment | Claim | Confidence | Why |
|---|---|---:|---|
| alert | release-related mechanism | 35% | timing only |
| cohort comparison | release or configuration path | 65% | failures isolated to B with matched workload |
| effective-state comparison | wrong endpoint selection | 85% | first divergence precedes dependency failures |
| canary correction | endpoint config restores canary | 92% | bounded counterfactual supports mechanism |
| prevention test | validation rejects bad target | 95% for recurrence control | guard reproduced and blocked the condition |

These numbers are estimates, not measurement. Their value is in showing which evidence changed the decision and what uncertainty remains.

## Internals and state ownership

### Evidence exists because something owns state

A signal is produced from state owned somewhere:

| Evidence | Typical owner | State behavior | Common trap |
|---|---|---|---|
| process status | kernel and service manager | current lifecycle state plus recorded result | `running` treated as correct work |
| metric counter | instrumented process or collector | cumulative until reset within its label set | counter compared as a gauge or across restart |
| gauge | instrument or scrape target | point-in-time observation | missed peak treated as absence |
| log event | emitting code and pipeline | discrete record, possibly buffered or reordered | message text treated as cause |
| trace span | instrumented boundary and backend | sampled timing and attributes for one path | missing span treated as no execution |
| queue depth | queue implementation | current or sampled waiting population | depth treated as arrival rate or cause |
| configuration | file, API, store, cache, environment | desired, distributed, loaded, and active versions may differ | repository value treated as effective value |
| durable result | database, object store, filesystem, broker | committed state with its own consistency semantics | client timeout treated as failed effect |

Ask who can author, cache, reset, drop, reorder, or aggregate the signal. That owner defines the proof boundary.

### Desired, distributed, loaded, and active configuration differ

A common troubleshooting failure is inspecting the source-of-truth file and assuming a process uses it.

```text
desired config C10
  -> distribution record says C10 sent
  -> host cache still holds C9
  -> process started with C9
  -> runtime override selects endpoint P2
```

Four values can coexist. Evidence should name:

- desired revision;
- distribution acknowledgement;
- file or object checksum;
- process start time and effective environment;
- runtime-reported active revision;
- selected endpoint or behavior.

The first mismatch is a boundary. The authoring system may be healthy while distribution is stale; the file may be correct while a process has not reloaded; the process may load correctly while runtime discovery overrides it.

### Metrics need type, reset, labels, and window

A **counter** normally increases until reset. Derive a rate over an interval and handle reset. A **gauge** can rise and fall. A histogram or summary represents a distribution according to its implementation and aggregation. A percentile is not additive and can hide separate populations.

Before interpreting a chart, ask:

- counter, gauge, cumulative bucket, event count, or sampled value?
- raw value, rate, average, sum, maximum, or percentile?
- scrape interval and query range?
- label set and aggregation?
- process restart or reset?
- missing samples and interpolation?
- units: bytes, seconds, milliseconds, count, ratio, or percent?

If these are unknown, the chart can suggest where to retrieve evidence, but it cannot carry a precise conclusion.

### Logs need event identity and security boundaries

Useful incident logs include time source, severity, operation or trace identity, component, revision, event name, outcome, and safe context. They avoid secrets, tokens, raw credentials, full payment data, or unbounded personal identifiers.

Logs can be attacked or corrupted. Untrusted text can forge line breaks or fields. Clock skew can reorder events. Rotation and retention can remove evidence. Access controls and sanitization matter because an incident does not suspend privacy or security.

Preserve a bounded sanitized excerpt and the query. Do not paste an entire production log into a public repository or AI tool.

### Traces correlate a path, but instrumentation can be partial

A trace can connect client, proxy, application, and dependency spans for one sampled operation. It helps separate queue wait, execution, and dependency time when the instrumentation boundaries are correct.

A trace does not automatically include work that crossed an asynchronous queue, lost context, ran unsampled, or failed before instrumentation. Span status may reflect library conventions rather than business correctness. Always connect the trace to the durable result and user outcome.

### Shell exit status is evidence too

A diagnostic command can print plausible output and still fail. In a Bash pipeline, status normally follows the last command unless `pipefail` changes it. Each pipeline element has an entry in `PIPESTATUS` immediately after execution.

This matters when a search command finds no match and a formatter still exits zero. If your evidence script ignores status, “nothing printed” can mean no match, unreadable input, wrong path, or a swallowed earlier failure.

The lab uses strict lifecycle checks and command chains with `&&` so a later view does not run after an earlier failure. In production, preserve the first meaningful nonzero result before another command overwrites `$?` or `PIPESTATUS`.

### Volatile and durable evidence need different handling

Process memory, open descriptors, transient queues, and in-memory caches may disappear on restart. Durable logs, objects, database rows, and controller records can survive but may be delayed or incomplete.

Before mutation:

1. identify volatile evidence that will be lost;
2. collect only what policy permits;
3. sanitize and checksum retained evidence where useful;
4. record source, time, scope, and collection command;
5. avoid delaying urgent restoration for low-value data.

Evidence preservation is a risk decision, not a reason to leave customers harmed indefinitely.

### Incident roles prevent one person becoming the bottleneck

For a material incident, separate at least these functions according to organizational practice:

- incident command owns priorities and decisions;
- operations executes controlled changes;
- communications updates stakeholders;
- subject-matter experts investigate mechanisms;
- scribe or timeline ownership preserves decisions and evidence.

One person may hold several roles in a small event. The key is explicit ownership. Ten engineers silently running commands in parallel can overwrite state, duplicate tests, and destroy the comparison needed for diagnosis.

### The lab owns a synthetic state machine, not a real service

The LES-0008 lab writes immutable lifecycle records beneath one validated private temporary root. Its Bash harness owns safety and state transitions. Its Python fixture owns deterministic virtual incident evidence. Observation and probe commands compute views and do not create new observation artifacts. Experiments, recovery, and operation verification create allowlisted immutable records.

That design teaches:

- baseline before change;
- one case per workspace;
- evidence from different owners;
- predictions before experiments;
- supported recovery versus real-operation verification;
- exact cleanup.

It deliberately does not teach host load, real dependency timing, network failure, process scheduling, or production incident authority.

## Evidence table

An evidence table is the point where troubleshooting stops being a memory contest. It gives every observation a job. A useful row answers six questions: what did we ask, what exactly did we observe, where and when did it apply, what can it prove, what can it not prove, and what decision changes next?

| Question | Evidence and boundary | Classification | Supports | Does not establish | Next discriminating step |
|---|---|---|---|---|---|
| Is the customer operation actually failing? | 8 of 20 guided synthetic checkouts succeed; 12 time out; p95 is 980 ms for that fixed virtual record | fact from the modeled client boundary | material operation impact in this fixture | component cause, fleet percentage, or real-world SLO impact | compare the same operation at app, dependency, and queue boundaries |
| Did the application revision change? | app revision changes from `app-2026.08.1` to `app-2026.08.2` before guided symptoms | fact from change and timeline views | the release belongs in the candidate change set | that the release caused the incident or which release-associated state matters | compare matched boundaries and counterfactual predictions |
| Is the app execution boundary slow? | app-only p95 is 30 ms in baseline and guided case despite the revision change | fact from app probe | a direct app-execution-latency mechanism is weakened for this modeled case | that release `.2` is unrelated; it could alter retries, routing, initialization, or another boundary | compare dependency, retry, and effective-state evidence |
| Is the dependency boundary different? | dependency p95 changes from 50 ms to 700 ms | fact from matched modeled records | dependency path is the first measured latency divergence | the dependency service itself is defective; client routing, identity, network, or quota can live at that boundary | correlate endpoint/config and run a bounded counterfactual |
| Are retries involved? | dependency calls rise from 20 to 44 while there are still 20 original requests | fact plus bounded inference | additional attempts amplify dependency work | retries created the first abnormal latency | predict and run `retry-off` |
| Did the recent event cause the incident? | event precedes symptoms in the timeline | correlation | event belongs in the candidate change set | mechanism or causality | find a changed state and a matched unaffected comparison |
| Did retry removal fix the mechanism? | retry-off lowers calls to 20 and p95 to 760 ms, but failures remain | experiment result | retries amplify cost and tail latency | retry policy is the originating mechanism or production-safe remediation | retain retry control as an amplifier finding; continue at dependency boundary |
| Is service recovered? | recovery summary returns 20/20 at 120 ms | fixture recovery evidence | modeled known-good values were restored | the user operation was executed after restoration or lost work is reconciled | run `verify-operation`, then check `lost_work` |
| Is cleanup safe and complete? | cleanup prints `cleanup=complete`, `state=absent`, `cleanup_proof_scope=descriptor-and-owned-candidates-at-check`, `cleanup_proven=true`, and check reports absence | harness lifecycle evidence | at that check, the exact descriptor/root are absent and no matching canonical current-UID-owned candidate was found | future absence, differently owned/noncanonical paths, or safety of arbitrary `/tmp` content | stop; preserve only sanitized learner notes |

The words in the classification column matter:

- A **fact** is a supplied or observed record stated within its exact boundary.
- An **inference** is a reasoned interpretation. Say which facts produce it.
- An **assumption** fills a gap temporarily. Mark it so the team does not inherit it as truth.
- A **hypothesis** proposes a mechanism and must name a result that would weaken it.
- An **unknown** is a missing value that may change a decision.

Here is a strong incident note:

```text
FACT F1: Guided client record has 20 operations, 8 successes, 12 timeouts.
FACT F2: App-only p95 is 30 ms; dependency-only p95 is 700 ms.
FACT F3: Dependency calls are 44 for 20 operations.
INFERENCE I1: The first measured latency divergence is after app execution and at the dependency path.
HYPOTHESIS H1: A dependency-path condition originates the delay; retries amplify attempts.
ASSUMPTION A1: App-only and dependency-only probes represent the same modeled case and scope.
UNKNOWN U1: Which sub-boundary inside dependency access diverged in a real system.
FALSIFIER: If matched dependency timing stays at baseline while app or queue timing diverges first, H1 weakens.
```

Compare it with this weak note:

```text
Dependency is down because timeout errors increased after deployment.
```

The weak version merges a client symptom, a timeline correlation, and an unproved owner accusation. It gives the next engineer no proof boundary and no falsifier.

### Evidence quality is more than quantity

Twenty dashboards that aggregate the same metric are one evidence family, not twenty independent confirmations. Prefer diversity that tests the causal path:

1. a user-operation outcome;
2. state from the owner of each transition;
3. a matched healthy comparison;
4. effective change evidence, not only desired configuration;
5. a bounded counterfactual whose prediction differs between hypotheses;
6. recovery and reconciliation evidence.

Evidence becomes weaker when its scope, identity, unit, time window, query, sampling, or retention is unknown. Write `not_collected` or `unknown`; never silently convert either value to zero, normal, or healthy.

## Command decoders

Every command card in this lesson begins with a question because commands are instruments, not rituals. Read the field names before the numbers. A number without its unit and population is an attractive way to be wrong.

### Decode environment and preflight

`cat /etc/os-release` identifies the userspace release metadata. `uname -sr` reports kernel name and release; under WSL, that kernel identity can differ from the distribution identity. `pwd` establishes where relative lab paths resolve. `id` establishes the effective UID and groups. `command -v` asks the shell how each required command resolves.

None of these commands proves a binary is trustworthy or compatible. That is why `lab.sh check` follows. A check refusal is a result: it preserves the boundary instead of guessing. Do not use `sudo`, edit the descriptor, or delete a path to manufacture a pass.

### Decode status as a state machine

After setup, status has a stable ordered contract:

```text
lesson_id=LES-0008
state=ready
lab_root=/tmp/devops-sre-LES-0008-frame-troubleshooting.XXXXXXXX
baseline=pending
active_case=none
experiments_completed=none
recovery=pending
operation_verification=pending
execution=virtual-time-bounded
cases_available=guided,changed,transfer
```

- `lesson_id` prevents another exercise from being mistaken for this state.
- `state=ready` means implemented integrity and lifecycle checks accepted; it does not mean an incident is recovered.
- `lab_root` is a random, private, validated root. It is evidence, not an invitation to copy a deletion command.
- `baseline` tells whether the one immutable known-good record exists.
- `active_case` enforces one case per workspace so evidence cannot be mixed.
- `experiments_completed` records only the supported counterfactuals in a fixed order.
- `recovery` records whether fixture known-good state was restored.
- `operation_verification` stays separate because applying recovery is not proving customer success.
- `execution=virtual-time-bounded` says values come from a deterministic model, not measured host performance.
- `cases_available` describes supported inputs, not completed learning.

After a complete guided run, `baseline`, `recovery`, and `operation_verification` should be complete or recorded; `active_case` remains `guided` until cleanup. That retained identity lets verification be attributed to the same case.

### Decode the baseline record

```text
record=baseline
case=baseline
requests=20
successes=20
timeouts=0
p95_latency_ms=120
app_p95_ms=30
dependency_p95_ms=50
max_queue=0
dependency_calls=20
retries=0
worker_limit=4
app_revision=app-2026.08.1
config_revision=cfg-001
```

`requests=20` is the fixed number of original virtual operations. It is not traffic rate. `successes` and `timeouts` are outcomes for that record; confirm their relationship instead of assuming every implementation makes categories exclusive. `p95_latency_ms=120` is the nearest fixed virtual tail value chosen by this fixture. With only 20 deterministic records it is not a production population estimate.

`app_p95_ms` and `dependency_p95_ms` measure modeled sub-boundaries. Do not add them blindly to total latency: boundaries can overlap, exclude queueing, or use different populations. `max_queue` is the maximum modeled waiting count, not arrival rate. `dependency_calls=20` and `retries=0` show one dependency attempt per original operation. `worker_limit=4` is the modeled concurrency control, not host CPU count. Revision fields let later evidence prove sameness or change.

### Decode observation views

The symptom view answers, "What did the operation experience?"

```text
record=observation
case=guided
view=symptoms
requests=20
successes=8
timeouts=12
p95_latency_ms=980
error=upstream_timeout
```

The error is emitted at the surface. It names a boundary impression, not an owner or root cause.

The timeline view orders `baseline_at`, `event_at`, `symptom_at`, and `followup_at`, then gives an observation. Order helps build candidates; order alone is not causality. In a real incident, record timezone, synchronization uncertainty, query window, and whether timestamps are event time or ingestion time.

The path view reports `gateway_p95_ms`, `app_only_p95_ms`, `dependency_p95_ms`, `max_queue`, and `dependency_calls`. In the guided case, app-only remains 30 ms while dependency reaches 700 ms and calls reach 44. The first useful measured divergence is therefore at the dependency path. "At the dependency path" is intentionally narrower and safer than "the dependency team caused it."

The changes view compares before and after values for application revision, worker limit, retry limit, and configuration revision. A changed field is a candidate input to a mechanism. An unchanged field narrows some hypotheses but does not prove the whole component unchanged.

### Decode the three probes

All probes include `record`, `case`, `probe`, `requests`, `successes`, `p95_latency_ms`, `max_queue`, and `conclusion_hint`.

- `app-only` isolates modeled application execution from the downstream call. A healthy result weakens an app-execution latency hypothesis for this case.
- `dependency-only` asks the modeled dependency path directly. A slow result supports locating the first divergence there; it still does not tell whether service, client, route, name resolution, identity, proxy, quota, or network caused it in production.
- `queue` retrieves waiting behavior. Queue growth can be a symptom of insufficient service rate, excessive arrival rate, unfair scheduling, a blocked consumer, or retries. Queue depth alone is not its mechanism.

`conclusion_hint` is teaching support, not an answer to paste into an incident review. Your causal statement still needs facts and limitations.

### Decode experiments as counterfactual evidence

An experiment record includes requests, successes, timeouts, p95, dependency calls, maximum queue, worker limit, and a textual result. Compare it to the written prediction made before execution.

For guided `retry-off`, calls fall from 44 to 20 and p95 falls from 980 to 760 ms, but the dependency problem remains. That supports two separate statements:

1. retries amplified work and tail latency;
2. retries were not the first abnormal mechanism in the model.

For guided `known-good-workers`, there is no material latency recovery. That weakens a worker-limit mechanism. In the changed case, the exact same experiment restores 20/20, 120 ms, and queue zero because worker limit changed from four to one. This is why experts repeat the reasoning method, not the previous answer.

### Decode recovery, verification, and cleanup

Recovery emits the action and modeled before/after outcome. `lost_work=0` is explicit reconciliation evidence for the fixture. Real recovery can require checking duplicate effects, abandoned jobs, missing messages, stale caches, or partial writes.

Verification then executes the named `synthetic_checkout` contract and reports `recovery_verified=true`. Only this modeled operation is verified. A production service may require several journeys, regions, tenants, and a sustained window.

Finally, cleanup must report all three fields:

```text
cleanup=complete
state=absent
cleanup_proof_scope=descriptor-and-owned-candidates-at-check
cleanup_proven=true
```

The proof scope is deliberate. Cleanup strictly proves descriptor, canonical root, and sentinel identity; refuses unknown names; accepts only allowlisted current-UID regular non-symlink single-link candidates; removes exact names; and scans for matching canonical current-UID-owned candidates at the final check. Its recovery-tolerant path does not validate copied-model bytes, manifest bytes, lifecycle-summary semantics, or every artifact mode before removal. The result is point-in-time evidence, not a promise that another process cannot create a new path later and not a statement about differently owned or noncanonical paths. The second `check` is an independent read of absent registered state. Do not infer cleanup from "the command returned quickly."

## Decision path

FRAME is useful during a real incident only if it changes decisions. Use this compact worksheet from `book/frameworks/FRAME.md`, then expand the fields whose uncertainty can change risk.

```text
F - FRAME
Operation and expected result:
Impact, scope, start, and known-good comparison:
Recovery target and deadline:
Authority, safety, privacy, and cost constraints:

R - RETRIEVE
Facts with source/scope/time:
Assumptions and unknowns:
Request/state path and first observed abnormal boundary:
Evidence each source proves / does not prove:

A - ANALYZE
H1 mechanism / prediction / falsifier:
H2 mechanism / prediction / falsifier:
H3 mechanism / prediction / falsifier:
Amplifiers and competing explanations:

M - MAKE A SAFE MOVE
Exact target and owner:
Prediction:
Maximum scope and duration:
Success / abort / rollback:
Evidence to preserve:

E - EVALUATE AND ENCODE
Real-operation verification:
Lost, duplicate, delayed, or corrupt work check:
Causal status and remaining unknowns:
Preventive control, owner, and verification test:
Cleanup proof:
```

### Step 1: declare the operation and recovery target

"The API is down" is too broad. Prefer:

```text
Operation: tenant cohort B submits report export and retrieves a correct artifact.
Expected: accepted once, completed within 120 s, artifact checksum matches input snapshot.
Impact: 62% of cohort B operations time out; cohort A is healthy; onset 14:06 UTC.
Recovery target: restore new operations within 20 min and reconcile every accepted operation.
Constraints: no unreviewed database writes; canary at 1%; preserve one failed trace; no secrets in notes.
```

This makes a restart testable. If the process becomes green but exports remain missing, the operation is not recovered.

### Step 2: find the first abnormal boundary

Walk from intent to result. At each boundary compare the same identity with a healthy cohort:

```text
expected input -> observed input -> expected output -> observed output
```

Stop at the earliest supported divergence, not the loudest downstream alarm. If admission is healthy, handoff is healthy, worker start is healthy, and dependency access is the first slow boundary, downstream timeout logs are consequences of that delay. If telemetry is missing at a boundary, the conclusion is "not yet located," not "the next component is guilty."

### Step 3: construct competing mechanisms

For the guided case:

| Rank | Mechanism hypothesis | Predicted evidence | Evidence that weakens it |
|---:|---|---|---|
| H1 | dependency-path delay originates the failure; retries amplify it | app-only stays near baseline, dependency-only is slow, retry-off reduces calls but does not restore baseline | dependency-only stays healthy or worker canary fully restores |
| H2 | application execution became slow after release | app-only diverges with revision `.2`; dependency-only remains near baseline | app-only remains 30 ms despite the `.1` to `.2` revision change; this weakens app-execution latency but does not erase release correlation |
| H3 | reduced worker concurrency creates queueing | worker limit falls, queue grows, known-good worker canary restores | worker limit unchanged, queue small, canary has no material effect |

The hypotheses share a symptom but predict different boundaries. This is the heart of evidence-driven troubleshooting.

### Step 4: choose the move by information value and risk

A good next move either restores safely or strongly separates hypotheses. Score it informally:

```text
decision value = expected discrimination or restoration
                 --------------------------------------
                 blast radius + irreversibility + lost evidence + delay
```

This is not financial mathematics. It reminds you that an easily reversible one-percent canary with a clear prediction is usually better than a fleet restart whose result fits five mechanisms.

Before any production mutation, state:

- exact resource, selector, cohort, namespace, region, revision, and owner;
- authorization and reviewers required;
- maximum requests, hosts, pods, tenants, duration, and spend;
- signals watched from user and component boundaries;
- success threshold;
- abort threshold and who calls it;
- rollback procedure and how rollback itself is verified;
- volatile evidence that will be destroyed;
- data integrity and security checks.

### Step 5: restore first when impact demands it, but preserve causal honesty

Severity changes how long you can investigate before mitigation. It does not change what evidence means. During severe impact, you may roll back a bounded cohort because the risk-adjusted restoration value is high. Say:

```text
Rollback restored checkout for the canary. This supports a release-path mechanism.
It does not yet distinguish binary, effective configuration, initialization,
or environment interaction. Investigation continues after fleet restoration.
```

### Step 6: verify from outside inward

Verification order:

1. real or representative user operation succeeds;
2. result is correct and durable;
3. accepted work reconciles with completed, delayed, duplicate, failed, and unknown work;
4. capacity and queues trend toward a stable operating range;
5. errors and latency stay healthy for a stated window and cohorts;
6. mitigation has not weakened security, durability, or another service;
7. rollback remains available until confidence justifies closing it.

### Step 7: encode prevention at the mechanism and amplifier

"Monitor more" is not enough. A strong action maps evidence to a control:

```text
Mechanism: effective endpoint may select an invalid identity target.
Control: validate the effective target before readiness and reject invalid revisions.
Verification: test deploy containing invalid target never becomes ready.

Amplifier: immediate unbounded retry creates 2.2 attempts per operation.
Control: bounded exponential backoff, jitter, attempt budget, and circuit policy.
Verification: fault test keeps dependency attempts and queue age within budget.
```

Owners, deadlines, rollout risk, and measurable completion criteria turn lessons into engineering.

## Guided Ubuntu lab

This lab is already a runnable deterministic fixture when you invoke its commands; you do not build a Docker image or start a server. It uses short Bash and Python foreground processes and a guarded private root under `/tmp`. No socket, port, package installation, background process, `sudo`, or cloud resource is involved.

Run from the repository root in Ubuntu 24.04 or WSL 2 Ubuntu 24.04 as a normal user. Do not paste an employer path, username, random lab-root suffix, or secret into a submission.

### 0. Read the safety contract

Expected mutation is under 256 KiB in one lesson-owned root plus one UID-scoped descriptor. CPU and memory use are ordinary short command use. The harness refuses root, unknown arguments, unsafe ownership, links, unexpected artifacts, state mixing, and unsupported order. A refusal is a safe result.

Never manually run `rm -rf` against the printed root. Cleanup proves identity and removes an exact allowlist with `rmdir`.

### 1. Establish the execution boundary

Run command cards 001 and 002. If the environment differs or check refuses, stop. A safe note looks like:

```text
Observed: Ubuntu 24.04 userspace; normal non-root UID; repository root; dependencies resolve.
Preflight: accepted by lab check; state absent.
Limit: this proves current preconditions only, not later lifecycle success.
```

### 2. Write a baseline prediction, then set up

Before generating output, predict:

```text
I expect one fixed baseline of 20/20 successes, zero timeouts,
120 ms modeled p95, no queue, 20 dependency calls, four workers,
and revisions app-2026.08.1 / cfg-001.
If output differs or order is refused, I will stop and inspect status.
```

Run setup, status, and command card 004. Decode the baseline rather than merely seeing green. The modeled equality `dependency_calls=requests` means one dependency call per operation in this fixture; it is not a universal SRE invariant.

### 3. Frame before injection

Use this starter and complete it yourself:

```text
Operation: synthetic checkout completes inside the fixture contract.
Impact: not yet observed.
Scope: one versioned guided virtual case, not host or production.
Known good: baseline record above.
Facts: baseline values and accepted lifecycle.
Assumptions: guided case will keep the same operation and comparison contract.
Top hypotheses before evidence: app execution, dependency path, worker queue.
First useful evidence: compare symptoms, path, changes, and owner probes.
Recovery target: return to baseline and verify synthetic_checkout with lost_work=0.
```

Then activate command card 005. Injection selects an immutable record; it does not reveal the mechanism.

### 4. Retrieve broad evidence before favoring a component

Run command card 006. Record only what the views show:

```text
F1: guided symptoms are 8 successes and 12 timeouts out of 20; p95 is 980 ms.
F2: the surface error is upstream_timeout.
F3: app revision changes from app-2026.08.1 to app-2026.08.2 before symptoms; this is correlation, not mechanism proof.
F4: app-only path remains 30 ms while dependency path is 700 ms; this weakens direct app-execution latency, not the revision fact.
F5: dependency calls are 44 for 20 original operations; max queue is 3.
```

Do not write "dependency outage" yet. The evidence localizes a boundary, not a real implementation sub-cause.

Run command card 007. The probes are deliberately separated so you practice asking an owner-specific question. Now write:

```text
I1: The first useful measured latency divergence is at dependency access,
because app-only remains at baseline while dependency-only is slow.
H1: A dependency-path condition originates the delay and retries amplify it.
H2: App execution regression is weakened by app-only evidence.
H3: Worker-limit queueing is possible but weak because worker limit is unchanged
and queue is much smaller than the changed-case signature described later.
Unknown: the real-world sub-boundary (service, route, TLS, identity, quota, pool,
network, or client timeout) is outside this fixture.
```

### 5. Predict the retry counterfactual

Before command card 008:

```text
Prediction if H1 is right:
- dependency calls fall from 44 toward 20;
- p95 improves because amplification decreases;
- the operation does not fully return to 20/20 or 120 ms because the
  originating dependency-path delay remains.
Abort in production: any canary error, integrity loss, queue-age breach, or
retry-dependent durable operation with uncertain outcome.
Rollback: restore reviewed retry policy to the exact canary and verify.
```

The fixed result is 20 dependency calls and 760 ms p95 while the dependency problem remains. Mark the prediction supported. Do not write "retries were root cause." They were an amplifier.

Optionally predict and run command card 009. Guided known-good workers produce no material latency recovery. That weakens a worker-limit mechanism in this case. The same command will be decisive in `changed`; a command has no permanent interpretation apart from its current evidence.

### 6. Restore and prove the operation

Run command card 010. Expected recovery fields include:

```text
record=recovery
case=guided
action=restore_fixture_known_good
requests=20
successes=20
timeouts=0
p95_latency_ms=120
dependency_calls=20
max_queue=0
worker_limit=4
lost_work=0
```

This proves the fixture recovery record, not yet the separate operation. Run command card 011. Verification must name `operation=synthetic_checkout`, show 20/20, zero timeouts, 120 ms, `lost_work=0`, and `recovery_verified=true`.

Now the correct conclusion is:

```text
The guided fixture is restored and its modeled checkout is verified.
The evidence supports a dependency-path originating condition with retry
amplification. The fixture does not identify a production dependency sub-cause.
```

### 7. Clean up and prove absence

Run command card 012. Look for `cleanup=complete`, `state=absent`, `cleanup_proof_scope=descriptor-and-owned-candidates-at-check`, and `cleanup_proven=true`; the following check must independently report absent registered state. Interpret this as a point-in-time descriptor/root/owned-candidate proof, not protection against future path creation. If cleanup refuses because identity is unsafe or an unknown artifact exists, stop. Preservation is safer than deleting what the harness cannot prove it owns.

### 8. Verifier versus learner evidence

From clean state, command card 013 tests lifecycle contracts, all cases, refusal paths, tamper recovery, symlink safety, cleanup, and unregistered-root detection by `check`, `setup`, and `cleanup` while preserving that candidate across refusal. It also performs a scoped static scan of the learner README for a named list of known transfer-answer spoilers. That scan does not inspect every repository file, recognize every paraphrase, or prove universal answer isolation. A pass is engineering QA evidence about the encoded fixture and pattern list. It is not evidence that you can independently frame an unfamiliar incident. Do not place `verification_passed=true` or `answer_isolation=passed` in a mastery ledger.

### 9. Changed case after a fresh reset

When you later run `changed`, evidence changes: dependency remains 50 ms; app path reaches 780 ms; queue reaches 12; worker limit changes four to one. Known-good workers restore 20/20 and 120 ms. If you paste the guided conclusion, you fail the central lesson. Reuse FRAME, not an answer.

## Production transfer

The fixture changes, but the reasoning survives. Translate each lab noun to the system you operate; never translate deterministic values into production thresholds.

### Linux host or virtual machine

Operation path:

```text
client -> socket/listener -> service manager -> process -> kernel resource
       -> filesystem/network/dependency -> durable result -> client
```

Useful owner evidence can include service-manager state, process start identity, exit status, cgroup limits, pressure stall information, socket state, filesystem blocks and inodes, mount identity, kernel logs, dependency timing, and one real operation. `systemctl active` proves lifecycle state, not correctness. `df -hT` proves allocated block use for one mounted filesystem; `df -i` proves inode availability. Neither alone proves which path the application writes or whether deleted-open files retain blocks.

Safe experiments might target one canary service instance, one route, or one read-only diagnostic. A fleet restart is a large mutation with evidence loss and synchronized load risk.

### Containers and Kubernetes

Operation path:

```text
client -> load balancer -> Service/route -> endpoint -> pod sandbox
       -> application -> dependency -> persistent state -> client

control path: desired workload -> scheduler -> node -> runtime -> readiness -> endpoint publication
```

Separate desired replicas, created pods, scheduled pods, containers started, readiness, endpoint publication, and successful traffic. `Running` is a phase; it is not a user journey. A readiness failure can originate in application initialization, identity, configuration, DNS, network policy, an unavailable dependency, or a probe that is too strict.

Compare revision, zone, node, image digest, effective config checksum, service account, and request shape. Before changing anything, scope namespace and selector, inspect intended versus live objects, prefer a diff, preserve events and previous logs, define rollback, and verify through the service rather than `kubectl get pods` alone.

### CI/CD and software delivery

Operation path:

```text
commit -> trigger -> runner allocation -> checkout -> dependency retrieval
       -> build/test -> artifact publication -> deployment -> operation verification
```

A green pipeline can publish the wrong artifact or deploy to the wrong environment. A failed job can reflect code, agent image, credentials, path, cache, dependency availability, quota, or policy. First compare the last known-good run using commit, pipeline config revision, runner image, tool versions, variables' presence (never secret values), working directory, cache key, artifact digest, and external service result.

Re-running a flaky job may restore delivery while destroying the only transient evidence. Preserve the first failure, then make a bounded rerun whose hypothesis and changed variables are explicit.

### Cloud and private-cloud platforms

Operation path crosses control plane and data plane. An API accepting a desired change proves neither resource readiness nor workload reachability. Use operation IDs, resource version, activity or audit events, quota, scheduler or placement decisions, network and identity paths, health checks, and a real workload operation.

Never experiment in production by broadly changing firewall rules, IAM roles, encryption, or public exposure. Least-privilege canaries, pre-approved rollback, cost ceilings, and auditability are part of correctness. In private cloud, include hypervisor, storage, overlay network, image, host maintenance, anti-affinity, and failure-domain placement as separate owners.

### Data and ML platforms

Operation path:

```text
source event -> ingestion -> durable offset/checkpoint -> transform
             -> partition/table/model artifact -> catalog/publication -> consumer
```

"Job succeeded" is not enough. Verify input completeness, watermark or offset, schema, partition publication, row or object counts with known limitations, data-quality invariants, duplication, late data, consumer visibility, and lineage. Retrying a non-idempotent stage can duplicate financial or analytical effects. A fast recovery that loses checkpoint state can be worse than a visible delay.

For ML, separate infrastructure availability from model correctness: feature freshness, training data version, model identity, serving revision, drift, evaluation, and decision outcomes have different owners.

### Observability tooling

Prometheus, Grafana, CloudWatch, Splunk, Dynatrace, traces, and logs are retrieval interfaces. The tool name is not the skill. For every query record:

- data source and owner;
- exact scope and label filters;
- event time and query window;
- unit and aggregation;
- absent-data behavior;
- sampling and retention;
- query or dashboard revision;
- sensitive attributes and access boundary;
- conclusion and proof limit.

If two tools disagree, compare definitions before choosing a favorite. They may count different events, clocks, populations, or aggregation windows.

## Reliability, security, observability, capacity, and cost

Expert troubleshooting balances all five dimensions. Optimizing only time-to-green can create the next outage.

### Reliability

Tie incident impact to a service-level indicator representing the user operation: success, latency, correctness, freshness, durability, or availability. An SLO supplies a decision context, not a root cause. Error-budget policy can guide release pace and escalation, but every severe operation failure deserves safe restoration even if a monthly average looks healthy.

Design for failure domains, graceful degradation, bounded queues, backpressure, idempotency, timeouts, cancellation, load shedding, rollback, backups, and tested recovery. Each mechanism needs an invariant and a verification method.

### Security

Incident pressure is not permission to weaken trust boundaries. Never paste credentials, tokens, payment data, personal identifiers, private keys, or unrestricted production logs into notes, repositories, chat, or AI tools. Redact deliberately; do not rely on scrolling past secrets.

Preserve least privilege, audit logs, separation of duties, and change authorization. Emergency access should be time-bounded, attributed, reviewed, and revoked. A fix that restores availability by granting wildcard IAM, opening a public port, disabling TLS verification, or bypassing validation trades one incident for a security event.

Also treat evidence as potentially hostile: escape log content, prevent spreadsheet formula injection, validate file type and ownership, and preserve chain of custody when an event may be security-relevant.

### Observability

Instrument the user journey and the boundaries needed for causal discrimination. Favor stable operation IDs, revision/config identity, safe cohort labels, explicit outcomes, queue age, attempt count, and stage duration. Monitor telemetry delivery itself.

An alert should be actionable: meaningful user or risk signal, clear owner, urgency, deduplication, runbook entry point, and safe first evidence. Avoid paging on a component metric with no known user or safety consequence. Avoid hiding real impact behind a composite score nobody can decode.

### Capacity

Capacity is not only CPU and memory. It includes workers, threads, file descriptors, connections, queue slots, IOPS, bandwidth, dependency quotas, partitions, scheduler capacity, and human on-call attention.

Use conservation reasoning:

```text
arrivals - completed - rejected = change in queued or in-flight work
```

The units and time window must match. Retries increase attempts even when original arrival rate is constant. Adding workers can reduce one queue while saturating a database. A capacity move needs downstream headroom evidence and an abort threshold.

### Cost

Troubleshooting actions consume compute, storage, network egress, observability ingestion, licenses, and engineer time. High-cardinality labels and debug logs can create large bills or expose sensitive data. Unlimited scaling can transform a dependency fault into cost amplification.

Cost is a constraint, not a reason to accept unsafe service. State the maximum experiment duration and resource increase. Prefer a canary that learns quickly, then remove temporary diagnostics and verify cost returns to baseline.

### The joint decision

Suppose adding workers may restore throughput. Ask all five questions:

| Dimension | Required question |
|---|---|
| reliability | will this restore the operation or overload the next boundary? |
| security | do new workers receive correct least-privilege identity and secrets? |
| observability | can we separate canary outcomes, attempts, queue, and dependency pressure? |
| capacity | which downstream bottleneck and quota absorb the concurrency? |
| cost | what is the maximum scale, duration, and rollback trigger? |

A senior answer connects these constraints before issuing the command.

## Traps and prevention

| Trap | Why it feels attractive | Why it fails | Durable prevention |
|---|---|---|---|
| blame the recent deploy | timing gives a simple story | many variables or unrelated events share time | cohort comparisons, effective-state identity, canary rollback evidence |
| restart first | quick and familiar | destroys volatile evidence, duplicates work, synchronizes load, fits many mechanisms | preserve high-value evidence, bounded restart criteria, post-restart causal work |
| trust `Running`, green, or accepted | control plane offers a clear status | lifecycle is not business correctness | real-operation synthetic checks and result reconciliation |
| treat missing telemetry as zero | dashboards draw an empty region | collection/query failure is indistinguishable without health evidence | telemetry pipeline indicators and explicit `unknown`/`not_collected` |
| read fleet averages | one number is easy to share | affected cohorts disappear inside healthy volume | bounded revision/zone/tenant/request-shape slicing with privacy controls |
| use one hypothesis | reduces cognitive load | every result is interpreted to fit it | require two or three mechanism alternatives and falsifiers |
| change many variables | seems faster | success cannot be attributed and rollback is unclear | single bounded canary or factorial plan with explicit controls |
| call mitigation root cause | service is green | recurrence mechanism remains unknown | separate restoration status, causal status, and preventive action |
| retry everything | hides transient faults | amplifies load and can duplicate effects | idempotency, attempt budgets, backoff, jitter, cancellation, circuit/load shedding |
| add capacity blindly | treats all queues as shortage | moves bottleneck and raises cost | measure arrival/service/queue, verify downstream headroom, cap experiment |
| paste raw evidence | preserves context quickly | leaks secrets or regulated data | sanitized extracts, access controls, retention, approved evidence store |
| write "human error" | creates a short cause | ignores enabling system and control design | analyze interfaces, validation, review, feedback, workload, and recovery design |
| close at first green | pressure to end incident | backlog, duplicates, corruption, or recurrence remains | sustained operation verification, reconciliation, prevention owner and test |

Prevention is strongest close to the first abnormal mechanism. Alerts nearer user impact improve detection; guards nearer the invalid state prevent the incident. Often you need both.

## Memory card and retrieval

When an alert fires, remember this sentence:

> Name the operation, walk the path, find the first divergence, predict one safe move, and prove the result.

The pocket card:

```text
FRAME
F  Failed operation, impact, scope, known good, recovery target, constraints
R  Facts by owner and boundary; mark assumptions, unknowns, and proof limits
A  At least two mechanisms; first divergence; prediction and falsifier
M  Smallest authorized move; exact target; success, abort, rollback, evidence
E  User operation; correctness; lost/duplicate work; cause status; prevention

Never equate:
alarm = cause
correlation = mechanism
missing = healthy
running = working
rollback success = exact root cause
mitigation = prevention
fixture pass = learner mastery
```

Retrieval schedule:

- after 10 minutes, reconstruct FRAME without looking;
- tomorrow, explain the guided and changed cases aloud and state why their identical error has different mechanisms;
- in one week, apply the blank worksheet to an incident from a different domain;
- in one month, run the isolated transfer assessment without lesson answers or fixture source;
- during real work, add one proof-limit sentence to every material evidence claim.

If you forget a command but remember the decision path, documentation can recover the syntax. If you memorize commands without the path, you will execute confidently against the wrong boundary.

## Complete answers

Use these answers after attempting the retrieval prompts. They model the depth expected; they are not evidence that you performed the reasoning independently.

### 1. Why can a service be running while the user operation fails?

**Direct answer:** `running` describes a lifecycle state at a process or control-plane boundary. It does not prove the process loaded correct configuration, became ready, received traffic, completed dependencies, wrote a correct durable result, or returned it to the user.

**Reasoning:** A service manager usually observes whether a process exists and perhaps whether it exited. Kubernetes phase and controller status similarly describe parts of desired-state convergence. The operation crosses more boundaries. A live process can wait forever on a connection pool, reject every request for missing identity, route to the wrong endpoint, write corrupt output, or respond success before publication. Verification must begin with the actual operation and correlate each transition.

**Senior nuance:** Lifecycle is still useful evidence. An unexpected restart time, exit code, or readiness transition can constrain hypotheses. The mistake is not reading status; it is asking status to prove more than its owner can know.

### 2. Why is the first abnormal boundary more useful than the loudest error?

**Direct answer:** Downstream failures propagate and often create many alarms. The first boundary where matched healthy input produces abnormal output is closest to the mechanism currently supported by evidence.

**Reasoning:** If a dependency access delay begins first, application deadlines, queue growth, proxy errors, and customer timeouts can all follow. Fixing only the proxy error cannot remove the delay. Walking the state path prevents consequence chasing. "First observed" remains important: missing instrumentation can mean an earlier mechanism exists but is not yet visible.

**Senior nuance:** There can be multiple initiating conditions and feedback loops. Build a causal graph rather than forcing one root. Separate trigger, preconditions, mechanism, propagation, amplification, detection, containment, and impact.

### 3. Why did retry-off improve guided latency without fixing the incident?

**Direct answer:** Retries created extra dependency attempts after the original delay. Removing them reduced amplification, so calls fell from 44 to 20 and p95 improved, but the first dependency-path delay remained.

**Reasoning:** Original operations and attempts are different units. Twenty operations can generate 44 calls. Extra attempts compete for the same constrained path and consume more of each deadline. An improvement after retry removal supports an amplification relationship; remaining failure rejects the claim that retries alone originated the fault.

**Senior nuance:** Disabling retries in production can lose required work or expose transient failures. The safe control depends on idempotency, deadlines, durable handoff, backoff, jitter, retry budget, circuit behavior, and reconciliation.

### 4. Does a successful rollback prove a deployment was the root cause?

**Direct answer:** It proves restoration for the observed rollback scope and strengthens a release-path hypothesis. It does not by itself identify code, configuration, schema, identity, routing, initialization, capacity interaction, or environment as the exact mechanism.

**Reasoning:** Rollback changes several variables at once. It can also restart processes, move cohorts, flush caches, and change load. Many mechanisms predict improvement. Compare effective states and use narrower tests after restoration.

**Senior nuance:** During high impact, broad discrimination may be less valuable than safe restoration. Causal honesty lets you restore quickly without freezing an oversimplified story into the post-incident record.

### 5. What should an abort condition contain?

**Direct answer:** A measurable signal, threshold, scope, observation window, decision owner, and immediate recovery action.

**Example:** "Abort the one-percent zonal rollback canary if checkout success drops below the current cohort by more than two percentage points for two consecutive one-minute windows, if any duplicate durable charge appears, if identity error rate exceeds the agreed capacity ceiling, or if telemetry is lost. The operations lead aborts; route the canary back through the reviewed release mechanism and verify the original operation."

**Senior nuance:** Thresholds must account for sample size and delay. A one-request canary cannot support a precise percentage. Integrity or security failures often require immediate abort without waiting for a statistical window.

### 6. How do you know recovery is complete?

**Direct answer:** The real operation succeeds correctly and durably for the declared scopes and window; accepted work is reconciled; queues and amplification stabilize; no new security, integrity, capacity, or healthy-cohort regression appears; and rollback remains understood.

**Reasoning:** A configuration update or green dashboard is an intermediate transition. Reconcile operation identities into completed, delayed, rejected, duplicate, corrupt, and unknown outcomes. Verify from outside the system, then use component evidence to explain stability.

**Senior nuance:** Restoration, incident closure, and prevention completion can occur at different times. Communicate each status separately.

### 7. What if evidence is missing?

**Direct answer:** Mark it missing, determine whether the collection path failed, and reduce confidence. Missing is not zero, healthy, or proof that the operation never occurred.

**Reasoning:** Instrumentation, sampling, buffering, transport, storage, retention, permissions, query filters, and dashboards can each lose evidence. Use another safe owner boundary, retrieve telemetry health, or choose an experiment whose result remains interpretable despite the gap.

**Senior nuance:** Do not delay urgent restoration indefinitely for perfect telemetry. State the decision made under uncertainty and add the missing boundary as a prevention item with an acceptance test.

### 8. What makes an incident update strong?

```text
14:18 UTC - Checkout success is 91% in zone B; zones A/C remain above 99.9%.
The new cohort fails readiness after identity access; the exact mechanism is not established.
Further rollout is paused through the approved control. Old serving capacity is preserved.
We are comparing old/new in-zone and new cross-zone; top hypotheses are effective
identity configuration, zonal identity path, and replacement/retry amplification.
No data-integrity loss is observed; this remains under verification.
Next decision: bounded restoration canary after the first divergent state is confirmed.
Next update: 14:28 UTC. Incident lead: role-name; operations: role-name.
```

It separates impact, facts, uncertainty, actions, constraints, hypotheses, owners, and time. It avoids speculation disguised as certainty.

## Product-company interview

**Scenario:** Ten minutes after a platform rollout, checkout success falls from 99.95% to 91% in one availability zone while regional success stays above 98%. New instances there fail readiness and are repeatedly replaced; older instances still serve some traffic. CPU is low, a shared identity service shows a small regional error increase, replacement immediately retries configuration and identity, and the controller reports the desired revision accepted.

### The first 90 seconds

Say the summary before commands:

```text
We have severe zonal checkout impact after a rollout, partial old capacity remains,
and mechanism is unknown. Controller acceptance is control-path evidence, not
checkout success. I will freeze expansion, protect surviving capacity and evidence,
control only authorized amplification, and compare revision versus zone.
```

Define a checkout as success only when the customer receives the correct durable result once. Establish incident lead, operations, communications, subject experts, scribe, authority, next update, and integrity/security constraints.

### First five minutes

1. Pause further rollout through the approved reversible control; do not terminate old instances.
2. Record affected zone, cohorts, operation indicator, onset, release/config identities, readiness reasons, replacement rate, and dependency attempts.
3. Protect one failed new instance's permissible volatile evidence before replacement destroys it.
4. Bound replacement/retry amplification using a preapproved control only if doing so preserves required capacity and work.
5. Draw control and data paths separately.

The controller's `accepted` status proves the desired revision crossed its API boundary. Low CPU weakens CPU saturation for measured instances but says nothing about waiting. A small regional identity error can conceal a large zonal/cohort rate. Replacement rate proves a feedback loop only after call lineage shows each replacement produces calls.

### Next fifteen minutes

Build the two-axis matrix:

| Comparison | Main question |
|---|---|
| old vs new inside affected zone | does revision/cohort/effective state discriminate? |
| new affected-zone vs new healthy-zone | does zone/path/environment discriminate? |
| failed readiness vs successful checkout path | where is the first transition different? |

For each, correlate instance/revision/config identity, configuration retrieval, selected identity endpoint, identity result and timing, readiness rule and reason, route membership, checkout operation, durable effect, retry lineage, and replacement decision.

Rank mechanisms:

- H1: new revision or its effective configuration is incompatible with the zonal path;
- H2: partial zonal identity access is the initiating condition;
- H3: immediate retries and replacement amplify a smaller fault until convergence fails.

These can coexist. Evidence should locate the first abnormal transition and quantify amplification.

### Safest restoration decision

If the revision/effective state discriminates and compatibility is established, request one zonal rollback canary while rollout stays paused and old capacity stays serving. Predict readiness, intended routing, and checkout recovery without rising identity pressure. Abort on worse checkout, incorrect or duplicate durable effect, identity saturation, unintended route membership, healthy-zone regression, missing evidence, or timeout. Retain rollback-forward through the reviewed release system.

If identity access diverges first across revisions, a code rollback may add churn without helping. Use the pretested identity failover, traffic control, or degraded mode appropriate to the system. Never invent a bypass during the interview.

### Recovery verification

Verify in this order: configuration and identity convergence, readiness, intended route membership, exactly-once checkout with correct durable effect, zonal success and tail latency, replacement and retry normalization, identity capacity, old and new cohort stability, backlog reconciliation, and healthy-zone non-regression for a stated window.

### Causal follow-up and prevention

After restoration, establish trigger, preconditions, first abnormal mechanism, amplification, failed containment, detection gap, customer/data impact, and response effects. Prevention may include representative zonal canaries, effective config identity, readiness reasons, zonal user-journey rollout gates, last-known-good preservation, bounded backoff/jitter/attempt budgets, dependency protection, and failure-injection tests.

**Weak answer:** "Rollback the region, restart everything, and scale identity."

It expands blast radius, discards useful capacity and evidence, can amplify calls, ignores integrity and authority, and contains no discriminating comparison, prediction, abort, rollback, or operation verification.

**Follow-up: what if old instances have a critical vulnerability?** Availability and security objectives now conflict. Bring security into command, quantify exploitability/exposure, use the designed restricted or fail-closed mode, and choose the smallest authorized action meeting both constraints. Do not preserve vulnerable capacity silently.

**Follow-up: would you bypass readiness?** No. First learn what readiness protects. Bypass can route users into known-bad instances. A degraded mode must already be designed, authorized, observable, and tested.

The full scored version, evidence boundaries, and detailed model responses are in `book/assessments/foundations/ASM-0008.json`. `book/assessments/foundations/ASM-0007.json` supplies a smaller report-export diagnostic.

## Independent transfer and rubric

`book/assessments/foundations/ASM-0009.json` is the answer-isolated transfer assessment. It uses only `inject transfer` from clean state. Do not inspect fixture source, guided/changed answers, another learner's diagnosis, or request a model solution before submission. If you receive help, disclose it.

This section intentionally contains no transfer-case diagnosis. That absence protects the assessment.

Submit:

1. sanitized environment and safety card;
2. completed FRAME worksheet;
3. owner/state-path diagram with first observed abnormal boundary;
4. facts/observations/assumptions/inferences/hypotheses/unknowns table;
5. time-ordered commands, predictions, outputs, units, status, and refusals;
6. three ranked mechanisms and evidence rejecting at least two;
7. at most one justified experiment with its full control envelope, or a reason not to experiment;
8. supported recovery, operation verification, reconciliation, and causal limits;
9. guarded cleanup plus absence evidence;
10. production transfer to a different environment.

The 20-point rubric gives four points each for safety/lifecycle, evidence integrity, path localization, hypothesis/experiment quality, and evaluation/prevention/transfer/independence. A fixture pass, website completion state, copied answer, or mentor-operated command is not mastery. Only reviewed original learner evidence can satisfy the assessment boundary, and later delayed recall remains separate.

## References and review

This lesson paraphrases primary or official material and adapts it to the local deterministic lab. Product names describe transferable boundaries, not endorsements or proof of production compatibility.

| ID | Official source | Use in this lesson |
|---|---|---|
| REF-0017 | [Google SRE Book: Effective Troubleshooting](https://sre.google/sre-book/effective-troubleshooting/) | systematic diagnosis, hypotheses, and examining what changed |
| REF-0018 | [Google SRE Workbook: Monitoring](https://sre.google/workbook/monitoring/) | user-facing signals, monitoring design, and alert usefulness |
| REF-0019 | [Google SRE Workbook: Incident Response](https://sre.google/workbook/incident-response/) | incident roles, response structure, and operational learning |
| REF-0020 | [Google SRE Book: Managing Incidents](https://sre.google/sre-book/managing-incidents/) | command, communications, operations, and structured coordination |
| REF-0021 | [OpenTelemetry: Signals](https://opentelemetry.io/docs/concepts/signals/) | logs, metrics, traces, and signal boundaries |
| REF-0022 | [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) | safe logging, sensitive data, integrity, and operational use |
| REF-0023 | [GNU Bash Manual: Pipelines](https://www.gnu.org/software/bash/manual/html_node/Pipelines.html) | pipeline exit status and shell evidence handling |
| REF-0024 | [Python documentation: `time` module](https://docs.python.org/3/library/time.html) | wall, monotonic, and elapsed-time semantics |

Reference metadata, review dates, and usage notes are stored in `book/references/`. The content status is `substantive-draft`: commands and fixture contracts need the repository gates and environment matrix; conceptual claims need scheduled source review; learner mastery always requires separate reviewed evidence.

When reviewing this lesson, verify:

- every command still matches the guarded interface and exact field order;
- Ubuntu 24.04 and WSL behavior remain in the release matrix;
- official sources still support the paraphrased claim;
- security, privacy, cost, and blast-radius limits remain explicit;
- answer isolation for ASM-0009 remains intact;
- no fixture, verifier, website state, or model answer is presented as learner mastery.
