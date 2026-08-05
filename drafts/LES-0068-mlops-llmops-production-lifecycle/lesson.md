---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0068",
  "slug": "mlops-llmops-production-lifecycle",
  "aliases": ["V07-L03", "mlops-llmops-production-lifecycle"],
  "curriculumIds": ["AIO-003"],
  "route": "/book/ai/mlops-llmops-production-lifecycle",
  "order": 3,
  "volume": "07-ai-engineering",
  "title": "MLOps and LLMOps: versioned releases, reliable serving, and measurable economics",
  "summary": "Operate a model as one versioned production system whose data, code, model, prompt, evaluation, serving runtime, traffic, telemetry and rollback evidence stay connected.",
  "domain": "ai",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0042", "LES-0064", "LES-0066"],
  "prerequisiteCurriculumIds": ["AIO-001", "DMP-003", "K8S-002", "REL-001"],
  "testedEnvironments": [
    {"platform": "Primary and official sources", "version": "Google, DVC, OCI, MLflow, KServe, Kubernetes, NVIDIA, vLLM, Gateway API Inference Extension and OpenTelemetry sources reviewed 2026-08-05", "support": "concept-only", "notes": "Source review does not establish any deployed model-system behavior."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic release-evidence model only."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON decisions; no model package, GPU, socket, cluster, registry, gateway, API or production effect."}
  ],
  "targetRoles": ["site-reliability-engineer", "platform-engineer", "devops-engineer", "machine-learning-engineer", "ml-platform-engineer", "data-engineer", "security-engineer", "solutions-architect", "technical-lead"],
  "learningObjectives": [
    "Define the user operation, correctness and latency SLOs, harm boundary, fallback and non-model baseline before choosing serving technology.",
    "Create one immutable release manifest joining source, data, features, model, tokenizer, prompt, retrieval, policy, image and runtime identities.",
    "Separate an immutable artifact version from a mutable registry alias and prove exactly what is running.",
    "Design reproducible evaluation gates for classic ML and nondeterministic LLM systems without hiding slices, uncertainty or evaluator versions.",
    "Choose batch, synchronous online, asynchronous online or streaming inference from the consumer contract.",
    "Trace a request through authentication, gateway, admission, queue, scheduler, model runtime, post-processing and outcome observation.",
    "Explain GPU discovery, device plugins, placement, memory admission, partitioning, topology and why an allocated GPU is not proof of useful capacity.",
    "Reason about dynamic batching, prefill, decode, KV cache, prefix cache, cancellation, deadlines and head-of-line blocking.",
    "Design a model gateway that preserves tenant, request, model, prompt, policy and cost identity while enforcing bounded authority.",
    "Release with shadow, canary and progressive exposure using paired quality, reliability, safety and economics gates.",
    "Detect data, feature, concept, behavior, calibration, performance and cost drift without treating automatic retraining as a default remedy.",
    "Calculate latency, throughput, utilization, token, GPU-hour, cache and unit-cost evidence and use it for admission, scaling and rollback."
  ],
  "productionSignals": [
    "user operation SLI SLO error budget harm and fallback",
    "release ID source commit pipeline run approver and deployment receipt",
    "training dataset snapshot label window feature code and schema digest",
    "model artifact digest format signature tokenizer and dependency identities",
    "prompt template version model parameters retrieval index and policy version",
    "evaluation dataset scorer version slice threshold uncertainty and result",
    "registry model version immutable artifact and mutable alias history",
    "container image digest runtime libraries driver firmware and compatibility",
    "request tenant operation trace model prompt policy and release identity",
    "gateway authentication authorization quota rate concurrency and route decision",
    "queue depth age admission result cancellation deadline and retry identity",
    "batch size wait time padded tokens prefill tokens decode tokens and finish reason",
    "time to first token time per output token end-to-end latency and error",
    "GPU device profile memory requested allocated used utilization and health",
    "KV cache capacity use eviction prefix query hit and tenant isolation",
    "replica ready loaded model checksum warm state and traffic weight",
    "shadow or canary cohort exposure quality safety SLO and cost comparison",
    "input feature prediction output label and user outcome with event times",
    "data feature concept behavior calibration performance and cost drift",
    "rollback target compatibility alias route cache state and recovery postcondition",
    "requests predictions tokens useful outcomes GPU-seconds energy and cost",
    "telemetry sampling redaction retention access cardinality and dropped spans"
  ],
  "diagrams": [
    {"id": "LES-0068-DIA-001", "title": "Immutable AI release identity graph", "direction": "hierarchical", "boundaries": ["release manifest", "source and pipeline", "data and features", "model and tokenizer", "prompt retrieval and policy", "image and runtime", "evaluation and approval"], "evidencePoints": ["release ID", "commit and run", "snapshot digests", "artifact digests", "configuration versions", "image digest", "gate receipt"], "textAlternative": "One release manifest joins every immutable input and approval needed to explain and reproduce a prediction."},
    {"id": "LES-0068-DIA-002", "title": "Online inference request path", "direction": "left-to-right", "boundaries": ["client", "gateway", "admission", "queue and scheduler", "model runtime", "post-processing", "outcome"], "evidencePoints": ["request and tenant", "route and policy", "budget", "queue age", "release identity", "schema and safety", "SLI"], "textAlternative": "A request crosses policy, capacity and model boundaries before its output becomes an observed user outcome."},
    {"id": "LES-0068-DIA-003", "title": "GPU capacity and scheduling stack", "direction": "top-to-bottom", "boundaries": ["workload request", "Kubernetes scheduler", "node and device plugin", "GPU or partition", "runtime memory", "KV cache and batch", "useful tokens"], "evidencePoints": ["extended resource", "placement", "health and topology", "device profile", "allocated versus used bytes", "cache pressure", "throughput"], "textAlternative": "Kubernetes allocates an advertised device, while the serving runtime must still fit weights, cache and batches and produce useful work."},
    {"id": "LES-0068-DIA-004", "title": "Progressive model release loop", "direction": "cyclic", "boundaries": ["offline gate", "shadow", "small canary", "measured ramp", "promotion", "continuous observation", "rollback"], "evidencePoints": ["evaluation receipt", "paired requests", "cohort identity", "quality and SLO deltas", "traffic weights", "outcomes", "previous compatible release"], "textAlternative": "Exposure expands only while quality, safety, reliability and cost gates pass, with a warm compatible rollback target."},
    {"id": "LES-0068-DIA-005", "title": "Drift diagnosis ladder", "direction": "hierarchical", "boundaries": ["telemetry validity", "population and schema", "features", "labels and concept", "model behavior", "system performance", "economics"], "evidencePoints": ["coverage", "slice and time", "training-serving comparison", "delayed outcomes", "calibration", "queue and GPU", "unit cost"], "textAlternative": "Drift is classified by evidence before changing a model; telemetry and serving faults can imitate model decay."},
    {"id": "LES-0068-DIA-006", "title": "Latency and cost budget", "direction": "left-to-right", "boundaries": ["gateway", "queue", "prefill", "first token", "decode", "post-process", "outcome"], "evidencePoints": ["milliseconds", "wait budget", "input tokens", "TTFT", "TPOT and output tokens", "validation", "useful result and cost"], "textAlternative": "End-to-end latency and cost are decomposed into owned stages so optimization does not merely move waiting or spend elsewhere."}
  ],
  "commands": [
    {"id": "LES-0068-CMD-001", "question": "Is the offline model safe?", "risk": "read-only", "command": "bash lab.sh doctor", "runFrom": "LES-0068 support/lab as normal Ubuntu 24.04 user", "expectedBranches": [{"when": "doctor=pass", "meaning": "guards and fixture pass", "nextEvidence": "setup"}, {"when": "lab=fail", "meaning": "a boundary failed", "nextEvidence": "correct without bypass"}], "proves": "local preconditions", "doesNotProve": "MLOps or LLMOps behavior"},
    {"id": "LES-0068-CMD-002", "question": "Can bounded release state initialize?", "risk": "mutating-bounded", "command": "bash lab.sh setup", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "setup=pass", "meaning": "owned state validates", "nextEvidence": "baseline"}, {"when": "failure", "meaning": "guard failed", "nextEvidence": "preserve first error"}], "proves": "bounded initialization", "doesNotProve": "registry or serving setup", "cleanup": "Run bash lab.sh cleanup."},
    {"id": "LES-0068-CMD-003", "question": "Does the complete release path operate?", "risk": "read-only", "command": "bash lab.sh evaluate baseline", "runFrom": "LES-0068 support/lab after setup", "expectedBranches": [{"when": "boundary=operable", "meaning": "all modeled contracts pass", "nextEvidence": "negative cases"}], "proves": "fixture decision order", "doesNotProve": "production readiness"},
    {"id": "LES-0068-CMD-004", "question": "Is the data snapshot immutable?", "risk": "read-only", "command": "bash lab.sh evaluate data-alias-only", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=data-identity", "meaning": "training input cannot be reproduced", "nextEvidence": "bind snapshot and digest"}], "proves": "data identity gap", "doesNotProve": "data correctness"},
    {"id": "LES-0068-CMD-005", "question": "Does the release pin the model artifact?", "risk": "read-only", "command": "bash lab.sh evaluate mutable-model-alias", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=model-identity", "meaning": "alias can resolve differently later", "nextEvidence": "record immutable version and digest"}], "proves": "model identity gap", "doesNotProve": "model quality"},
    {"id": "LES-0068-CMD-006", "question": "Does evaluation represent production?", "risk": "read-only", "command": "bash lab.sh evaluate aggregate-eval-only", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=evaluation-slices", "meaning": "aggregate score hides critical cohorts", "nextEvidence": "add sliced gates and uncertainty"}], "proves": "evaluation gap", "doesNotProve": "online benefit"},
    {"id": "LES-0068-CMD-007", "question": "Does GPU memory fit?", "risk": "read-only", "command": "bash lab.sh evaluate gpu-memory-overcommitted", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=gpu-memory", "meaning": "weights cache and workspace exceed budget", "nextEvidence": "change model runtime cache or placement"}], "proves": "memory admission gap", "doesNotProve": "GPU throughput"},
    {"id": "LES-0068-CMD-008", "question": "Can the queue meet the deadline?", "risk": "read-only", "command": "bash lab.sh evaluate queue-deadline-missed", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=queue-deadline", "meaning": "oldest request cannot finish in budget", "nextEvidence": "shed route scale or degrade"}], "proves": "deadline gap", "doesNotProve": "runtime latency distribution"},
    {"id": "LES-0068-CMD-009", "question": "Is the gateway enforcing tenant budgets?", "risk": "read-only", "command": "bash lab.sh evaluate tenant-budget-unbound", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=gateway-budget", "meaning": "one tenant can consume shared capacity", "nextEvidence": "bind auth quota concurrency and token limits"}], "proves": "admission gap", "doesNotProve": "fair scheduling"},
    {"id": "LES-0068-CMD-010", "question": "Can the canary be attributed?", "risk": "read-only", "command": "bash lab.sh evaluate canary-version-unlabeled", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=canary-attribution", "meaning": "metrics cannot distinguish releases", "nextEvidence": "add immutable release labels and paired cohorts"}], "proves": "rollout evidence gap", "doesNotProve": "canary quality"},
    {"id": "LES-0068-CMD-011", "question": "Is drift classified before retraining?", "risk": "read-only", "command": "bash lab.sh evaluate drift-auto-retrain", "runFrom": "LES-0068 support/lab", "expectedBranches": [{"when": "boundary=drift-response", "meaning": "retraining is unauthorized and diagnosis is incomplete", "nextEvidence": "classify telemetry data concept behavior and system change"}], "proves": "drift-control gap", "doesNotProve": "true concept drift"},
    {"id": "LES-0068-CMD-012", "question": "Do every branch and cleanup pass?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "LES-0068 support/lab from absent state", "expectedBranches": [{"when": "verify=pass", "meaning": "all branches and cleanup pass", "nextEvidence": "retain limitations"}, {"when": "failure", "meaning": "candidate rejected", "nextEvidence": "preserve first failure"}], "proves": "teaching lifecycle", "doesNotProve": "model registry serving gateway GPU scheduler evaluator telemetry or production behavior", "cleanup": "Verifier proves state absence."}
  ],
  "labs": [
    {"id": "LES-0068-LAB-001", "title": "Guided model-release and serving evidence model", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python", "timeMinutes": 240, "privilege": "normal user; root refused", "network": "none", "changes": ["UID-scoped temporary root", "synthetic release fixture"], "abortConditions": ["root", "credential", "endpoint", "symlink", "wrong owner", "unknown artifact"], "recovery": "Preserve first failure; change only copied fixture or candidate code.", "cleanupProof": "Exact inventory and root absence.", "path": "drafts/LES-0068-mlops-llmops-production-lifecycle/support/lab"},
    {"id": "LES-0068-LAB-002", "title": "Independent bad-canary and cost-spike transfer", "mode": "independent", "environment": "Reviewer-owned disposable local model simulator and synthetic traffic", "timeMinutes": 240, "privilege": "normal user; reviewer owns faults", "network": "isolated local only or none", "changes": ["synthetic releases requests labels and telemetry", "bounded local state"], "abortConditions": ["shared service", "real credential", "customer data", "real GPU mutation", "external effect", "unbounded load", "unknown cleanup"], "recovery": "Preserve release and request lineage and reset through reviewer harness.", "cleanupProof": "Reviewer proves processes, files, ports, caches and synthetic records absent.", "path": "drafts/LES-0068-mlops-llmops-production-lifecycle/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0068-INC-001", "signal": "The production alias still says champion, but outputs changed after a registry update.", "firstThought": "A mutable alias was treated as immutable deployment identity.", "safePath": "Freeze promotion, resolve running digest and release manifest, restore the known compatible version, and audit alias history.", "trap": "Rename the alias and assume replicas changed together."},
    {"id": "LES-0068-INC-002", "signal": "A model Pod has a GPU but is repeatedly out of memory.", "firstThought": "Device allocation is not memory admission; weights, runtime workspace, KV cache and batch peaks exceed the usable device profile.", "safePath": "Stop retry churn, bind device/profile/runtime/model identities, measure memory components, reduce admitted work or move to a proven profile.", "trap": "Increase replica count on identical devices."},
    {"id": "LES-0068-INC-003", "signal": "Average latency is healthy while interactive users wait tens of seconds.", "firstThought": "Queue age, TTFT or long-request head-of-line blocking is hidden by an end-to-end average.", "safePath": "Slice by operation, tenant, release, input/output length and stage; enforce deadlines and admission while protecting interactive capacity.", "trap": "Increase batch size globally for throughput."},
    {"id": "LES-0068-INC-004", "signal": "The canary passes HTTP health checks but produces worse answers at higher cost.", "firstThought": "Transport health is not model quality, safety or economic health.", "safePath": "Stop exposure, preserve paired cohort evidence, route to the previous release, reconcile caches, and diagnose exact model/prompt/data/runtime deltas.", "trap": "Wait for Kubernetes readiness to fail."},
    {"id": "LES-0068-INC-005", "signal": "A drift alarm starts an automatic retraining loop during a telemetry schema change.", "firstThought": "Monitoring drift may be an instrumentation or population-identity failure, and retraining changes production without diagnosis.", "safePath": "Disable the loop, preserve as-of telemetry, classify drift, repair measurement, re-evaluate a versioned candidate, and require promotion gates.", "trap": "Train more frequently until the alarm clears."}
  ],
  "assessmentIds": ["ASM-0187", "ASM-0188", "ASM-0189"],
  "referenceIds": ["REF-0778", "REF-0779", "REF-0780", "REF-0781", "REF-0782", "REF-0783", "REF-0784", "REF-0785", "REF-0786", "REF-0787", "REF-0788", "REF-0789", "REF-0790", "REF-0791", "REF-0792"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-05",
  "reviewAfter": "2027-02-05",
  "limitations": [
    "The offline model is not a registry, evaluator, model server, GPU scheduler, gateway, telemetry backend or benchmark.",
    "Synthetic decisions cannot prove model quality, reproducibility, serving correctness, GPU capacity, routing fairness, drift or user benefit.",
    "No model, dataset, GPU, socket, cluster, registry, deployment, request, credential, production target or external effect exists.",
    "Products, APIs, defaults, metrics, hardware compatibility and semantic conventions change; exact behavior requires pinned local evidence.",
    "Formal review, publication, representative runtime, independent transfer, delayed recall and learner evidence remain required."
  ]
}
---

# MLOps and LLMOps: versioned releases, reliable serving, and measurable economics

## What you see and first thought

This candidate is being authored. The first rule is already fixed: when an AI endpoint changes, do not ask only, “Which model name is deployed?” Ask which complete release produced the request and whether the user outcome changed.

## Terms before commands

The terms will be defined before the learner runs tools.

## Architecture map

The architecture will connect immutable artifacts, mutable control-plane pointers, request-time data-plane state and independently observed outcomes.

## Request or state path

The chapter will trace both a release path and one online inference request.

## Failure zoom

Failures will be separated into identity, evaluation, serving, scheduling, rollout, drift and economics boundaries.

## Internals and state ownership

Ownership will distinguish registries, deployers, gateways, schedulers, runtimes, telemetry and product teams.

## Evidence table

Every signal will state what it proves and what it cannot prove.

## Command decoders

The offline commands will decode one decision boundary at a time.

## Decision path

The decision path will stop at the first unsupported production claim.

## Guided Ubuntu lab

The lab will remain local, guarded and disposable.

## Production transfer

Production transfer will require real representative evidence under reviewer control.

## Reliability, security, observability, capacity, and cost

These properties will be evaluated together rather than as separate appendices.

## Traps and prevention

The chapter will turn common shortcuts into preventive controls.

## Memory card and retrieval

The memory card will compress the operating model without replacing evidence.

## Complete answers

Worked answers will explain each inference from first principles.

## Product-company interview

Interview material will test production judgment rather than vocabulary.

## Independent transfer and rubric

The independent task will contain no model answer.

## References and review

Fifteen primary or official sources will be linked to the claims they support.
