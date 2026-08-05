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

At 10:05 a dashboard says the new model is healthy. Every Pod is `Ready`. The model registry says `champion`. Aggregate evaluation improved. At 10:12, users in one language begin receiving poor answers, time to first token triples for long prompts, and two GPUs run out of memory.

The tempting conclusion is, “Kubernetes is healthy, so the model must be fine.” That sentence mixes four different truths:

- **Process truth:** the server started and answered a health probe.
- **platform truth:** Kubernetes placed the workload and the device plugin allocated a GPU.
- **model truth:** a specific artifact produced outputs on a specific evaluation set.
- **user truth:** the operation completed correctly, safely, on time and at acceptable cost.

Only the last truth defines success. The other three are evidence that helps explain it.

When this happens in production, remember:

> A model is not the release. A model name is not an identity. A healthy endpoint is not a healthy outcome.

Your first safe move is not to tune batching or add GPUs. Stop increasing exposure. Preserve request, route and release evidence. Determine which immutable artifact set produced affected requests. Protect users through a tested fallback or previous compatible release. Then diagnose the first failed boundary.

Use this order:

1. **Outcome:** Which user operation is harmed, for whom, since when and by how much?
2. **Identity:** Which exact release served those requests?
3. **Exposure:** Which cohort and traffic decision selected it?
4. **Stage:** Did failure occur at gateway, queue, scheduler, runtime, output validation or downstream use?
5. **Capacity:** Were deadlines, memory and concurrency admitted honestly?
6. **Recovery:** Is the old release actually warm, compatible and routable?

This chapter treats classic machine-learning prediction and LLM generation as related but different workloads. Both need lineage, evaluation, promotion and outcomes. LLMs add variable input/output lengths, nondeterminism, expensive prefill and decode phases, KV-cache pressure, streaming, content-sensitive telemetry and token economics. The operating discipline is the same: join identity to evidence before changing state.

## Terms before commands

Read these terms as production handles, not exam definitions.

### MLOps and LLMOps

**MLOps** is the engineering system that builds, evaluates, releases, operates and retires machine-learning behavior. It connects data engineering, software delivery and production operations.

**LLMOps** applies that system to language-model applications. It must version more than model weights: tokenizer, prompt, sampling parameters, retrieval corpus and index, tools, policies, output schema and sometimes adapters. It must also operate streaming latency, token work, KV cache and nondeterministic output.

Neither term means “install a model registry.” A platform is useful only when it makes safe behavior repeatable and unsafe behavior difficult.

### Artifact, version, digest, tag and alias

An **artifact** is stored content: a dataset snapshot, model weights, tokenizer files, prompt template, evaluation set, container image or policy bundle.

A **version** is an immutable identity assigned to one artifact state. A **digest** is content-derived identity such as a cryptographic hash. If the bytes change, the digest changes.

A **tag** is descriptive metadata. A **mutable alias** such as `champion` or `production` points to a version and may later move. Aliases are useful control-plane handles, but they are poor forensic identities.

Think of an alias as a railway sign and a digest as the train's serial number. “The production train” can mean a different train tomorrow. An incident report needs the serial number and the time the sign moved.

### Release manifest

A **release manifest** is the join record for everything that can change behavior:

```text
release
├── source commit + build/pipeline run
├── training data + labels + feature code/schema
├── model weights + format + signature + tokenizer
├── prompt + parameters + retrieval index + policy
├── image digest + runtime libraries + hardware contract
├── evaluation data + scorer + thresholds + results
└── approval + route + deployment receipt + rollback target
```

The manifest need not be one product. It must be one queryable contract. If an engineer cannot move from a request ID to this set, reproducibility is a hope rather than an operational property.

### Registry and promotion

A **registry** stores versions, metadata and lifecycle pointers. Registration says, “This artifact is known.” **Promotion** says, “An authorized process accepts this version for a declared environment and exposure.” Registration is not approval. An alias mutation is not proof that every replica loaded the new artifact.

Promotion should be a compare-and-set decision: the approver sees the evaluated immutable candidate and expected current target, then the system records who moved what, from which version to which version, and why.

### Model signature and compatibility

A **model signature** describes accepted inputs and produced outputs: names, types, shapes and constraints. Compatibility also includes tokenizer vocabulary and special tokens, feature order and transformations, prompt variables, output schema, runtime libraries, accelerator capability and downstream interpretation.

Two artifacts can load successfully and still be semantically incompatible. A tokenizer mismatch may generate legal tensors with wrong meaning. That is more dangerous than a clean startup failure.

### Batch, online, asynchronous and streaming inference

- **Batch inference** processes a bounded dataset or time partition. Throughput and completion deadline dominate; individual responses need not return immediately.
- **Synchronous online inference** keeps the client waiting. End-to-end deadlines, tail latency and cancellation are first-class.
- **Asynchronous online inference** accepts work, returns an operation ID and completes later. Queue durability, idempotency, status and result retention matter.
- **Streaming inference** sends partial output before completion. Time to first token and time per output token matter separately; disconnect and cancellation must reclaim work.

Choose from the consumer contract. Do not choose streaming merely because the server supports it.

### Gateway, admission and scheduling

A **model gateway** authenticates callers, authorizes operations, resolves routes and versions, enforces tenant quotas and budgets, attaches trace identity, controls retries and may provide fallbacks. It is a policy boundary, not merely a reverse proxy.

**Admission control** answers, “Can this request still finish within its deadline and resource budget?” A queue accepting a request is not the same as a system capable of completing it.

**Scheduling** decides where and when admitted work runs. Kubernetes schedules Pods against advertised resources. The model runtime schedules requests into batches and accelerator work. These are different schedulers with different evidence.

### GPU allocation, memory and useful capacity

A Kubernetes device plugin advertises devices and reports health. The scheduler allocates an extended resource such as `nvidia.com/gpu`. That proves placement and allocation, not:

- that weights plus runtime workspace fit;
- that enough memory remains for KV cache and peak batches;
- that the driver, firmware and runtime combination is compatible;
- that the device is delivering expected throughput;
- or that completed outputs are useful.

**Useful capacity** is work that meets quality and deadline requirements per unit of constrained resource. A busy GPU generating abandoned or invalid output is expensive failure, not high utilization.

### Prefill, decode, TTFT, TPOT and KV cache

For an autoregressive LLM, **prefill** processes input tokens and builds attention state. **Decode** generates output tokens iteratively. **Time to first token (TTFT)** includes gateway, queue, prefill and initial decode work. **Time per output token (TPOT)** describes generation cadence after the first token. **End-to-end latency** includes the full request and downstream validation.

The **key-value cache**, or **KV cache**, stores attention state so generation does not recompute the whole prefix each step. It consumes accelerator memory based on model architecture, precision, sequence lengths and concurrency. A **prefix cache** may reuse compatible prefix state across requests. Its key must include every identity that changes the computed prefix and every isolation boundary. A cache hit is a performance fact, not a correctness fact.

### Shadow, canary, A/B test and rollback

**Shadowing** copies representative requests to a candidate without using candidate output for the user. It tests serving behavior but needs privacy controls and does not prove interactive user outcomes.

A **canary** gives a small, identified cohort real candidate behavior. It is a safety mechanism only when allocation, minimum evidence, gates, abort rules and rollback are predeclared.

An **A/B test** estimates outcome differences between intentionally allocated variants. It is an experiment, not automatically a safety rollout.

**Rollback** restores a previous compatible release and reconciles mutable state. “The old YAML exists” is not rollback readiness. Weights may be cold, caches incompatible, schemas changed or the old route untested.

### Drift

**Data drift** changes input distributions. **Feature drift** changes computed features. **Concept drift** changes the relationship between inputs and desired outcomes. **Behavior drift** changes model outputs. **Calibration drift** changes whether confidence matches observed correctness. **system-performance drift** changes latency, errors or resource use. **Cost drift** changes spend per useful outcome.

These can imitate one another. A telemetry schema change can look like data drift. Delayed labels can look like falling quality. Queue saturation can change which requests time out and therefore which outcomes are observed. Drift is a diagnostic signal, never automatic authority to retrain and promote.

### Tokens and unit economics

A **token** is a tokenizer-defined unit, not a word. Changing tokenizer can change token count and model input identity.

Track input tokens, output tokens, cached tokens where meaningful, requests, retries, GPU-seconds and completed useful outcomes. Cost per request is often misleading because requests vary in length and retries. Prefer:

```text
cost per useful outcome = total attributable serving cost / verified useful outcomes
tokens per useful outcome = (input tokens + output tokens) / verified useful outcomes
```

Both require a defensible definition of “useful.”

## Architecture map

There are three connected planes.

```text
BUILD AND EVIDENCE PLANE
source ─► data/features ─► train/build ─► immutable artifacts ─► evaluation
  │             │               │               │                    │
  └─────────────┴───────────────┴───────────────┴────► RELEASE MANIFEST
                                                           │ approval
                                                           ▼
CONTROL PLANE
registry version ─► alias decision ─► deployment spec ─► route weights
       │                  │                 │                  │
       └──────────────── audit / desired state ───────────────┘
                                                           │ reconcile
                                                           ▼
DATA PLANE
client ─► gateway ─► admission ─► queue/runtime scheduler ─► model ─► output
   │          │            │               │                    │        │
   └ request/tenant/trace/release identity ─┴────────────────────┴────────┘
                                                                          │
                                                                          ▼
                                                           independently observed outcome
```

The **build and evidence plane** creates candidates and proof. The **control plane** decides desired versions and traffic. The **data plane** serves requests. An operator must compare desired state with observed state:

- Registry alias says what control intended.
- Deployment status says what controller reconciled.
- Loaded-artifact checksum says what a replica actually holds.
- Per-request release identity says what handled this request.
- Product outcome says whether the operation succeeded.

Never collapse those into one “model version” label.

### Ownership map

Ownership should follow control:

| Boundary | Typical owner | Must provide |
|---|---|---|
| Dataset and labels | data or product team | snapshot, schema, time range, consent, quality and deletion |
| Model and evaluation | ML team | artifact, signature, evaluation, slices, limitations |
| Build and registry | ML platform | immutable storage, lineage, access and audit |
| Deployment and GPU nodes | platform team | placement, compatibility, capacity and rollback mechanisms |
| Gateway and tenant policy | platform/security | identity, authorization, budgets, routing and audit |
| User SLO and release decision | service owner | outcome gates, exposure, incident ownership |

Shared ownership is not permission to leave gaps. For each artifact and transition, name one authority, one observer and one recovery owner.

## Request or state path

Trace two paths. The release path explains **what could run**. The request path explains **what did run**.

### Release path

1. A training or packaging job starts from a source commit and pinned environment.
2. It reads a versioned data snapshot, label policy and feature transformation.
3. It writes an immutable model artifact, signature, tokenizer and dependency description.
4. For an LLM application, it also binds prompt, model parameters, retrieval/index and policy versions.
5. A reproducible evaluator runs a versioned dataset and scorer set. Results are retained by critical slice, not only aggregate.
6. A policy gate compares candidate with incumbent and absolute safety/SLO thresholds.
7. An authorized actor records approval against the candidate digest.
8. The artifact is registered. A mutable alias may select it, but the deployment resolves and records the immutable identity.
9. A deployment controller creates replicas using an image digest and hardware/runtime contract.
10. Each replica loads the artifact, verifies checksum and compatibility, warms required state, then becomes eligible for traffic.
11. Routing gives the release a declared cohort and weight.
12. Promotion occurs only after observed quality, safety, reliability and cost gates pass.

If any arrow is missing, “reproducible release” is unproven.

### Online request path

```text
caller
  │ credentials + tenant + deadline + operation
  ▼
gateway
  │ authn/authz, limits, route, immutable release decision
  ▼
admission
  │ remaining deadline >= estimated queue + service + safety margin?
  ▼
runtime queue
  │ priority/fairness, cancellation, batch formation
  ▼
model runtime
  │ load identity, prefill, KV allocation, decode
  ▼
post-processing
  │ schema, policy, citations/grounding, truncation, finish reason
  ▼
client and downstream operation
  │
  ▼
independent user outcome
```

Carry one request ID and trace ID end to end. Attach tenant and operation at the controlled edge. Attach resolved release, model, prompt and policy versions at the component that actually knows them. Record route decision separately from backend observation so a stale label cannot forge attribution.

### Deadlines and cancellation

Suppose the caller allows 2,000 ms. At admission:

```text
remaining budget
= original deadline
- gateway elapsed
- observed queue age
- estimated service tail
- response/validation margin
```

If the result is negative, reject or degrade before expensive work begins. Do not reset the deadline on each retry. For streaming clients, detect disconnects and cancel queued or decoding work. Otherwise the user leaves while the GPU continues spending.

### Batch path

Batch inference adds dataset partitions, checkpoints, retries and output publication:

```text
input snapshot ─► partition plan ─► attempts ─► staged outputs
       │                │              │              │
       └─ release ID ───┴─ idempotency ┴─ validation ─┴► atomic publish
```

Retries must not duplicate externally visible results. Publish only after completeness, schema and quality checks. A completed compute job is not a complete business result.

## Failure zoom

Use the symptom to select a boundary, then ask for discriminating evidence.

| Symptom | First suspicion | Evidence that separates causes | Unsafe shortcut |
|---|---|---|---|
| Outputs changed “without deployment” | mutable alias, prompt, retrieval index or policy changed | request release IDs, alias audit, loaded digests, cache keys | restart everything |
| Pod `Ready` but answers fail | readiness excludes semantic compatibility | model/tokenizer/prompt/signature identities, golden request | trust HTTP 200 |
| GPU allocated but OOM | memory admission omitted weights/cache/workspace/batch peak | device profile, allocated and peak bytes, batch/sequence distribution | add identical replicas |
| p50 healthy, users wait | queue or tail cohort hidden | p95/p99 queue, TTFT, TPOT by release/length/tenant | optimize average |
| Throughput rose, cost exploded | more tokens, retries or invalid outcomes | tokens, GPU-seconds, useful outcomes, cache and retry rates | celebrate utilization |
| Canary looks healthy | no release attribution or too little evidence | route receipts, per-request version, sample/exposure, paired gates | ramp by elapsed time |
| Drift alert fires | telemetry, population, labels, behavior or system changed | schema/coverage, as-of slices, delayed labels, serving metrics | auto-retrain |
| Rollback misses objective | previous release cold or incompatible | load/warm time, route and schema compatibility, recovery exercise | keep old YAML only |

### Failure is often a join failure

Many incidents are not caused by a bad algorithm. They happen because evidence cannot be joined:

- evaluation knows model version but not prompt version;
- serving metrics know model name but not release;
- product outcomes know user and time but not route cohort;
- GPU metrics know Pod but not request lengths;
- costs know cluster totals but not useful outcomes.

The first platform improvement is often identity propagation, not a smarter model.

### Preserve before changing

Before restarting or moving an alias, retain:

- affected request and trace IDs;
- route decision, cohort and traffic weights;
- resolved release and loaded artifact digests;
- prompt, policy, retrieval and cache identities;
- evaluation and approval receipts;
- queue, latency, token, GPU memory and restart evidence;
- user-impact samples with privacy controls;
- event, observation and deployment times.

Then make the smallest reversible containment. A fast rollback with destroyed evidence creates the next incident.

## Internals and state ownership

### Artifact and registry internals

Large datasets and model files do not fit normal source-control workflows. A common pattern stores a small metadata record in Git and content in an artifact store. The metadata contains a content identity and storage reference. Reproducibility requires both:

```text
source revision
  └── tracked metadata ─► expected digest ─► artifact bytes
                                         └► checksum verification
```

A path such as `datasets/current` or a storage URI alone is not a version. A timestamp alone is weak because clocks, overwrites and copying can make it ambiguous. Preserve schema, selection query or manifest, time boundaries and label policy as well as bytes.

A registry adds names, versions, tags and aliases. Keep these distinctions:

- **artifact store** owns bytes and integrity;
- **registry** owns logical model/version records and metadata;
- **promotion service** owns authorization to change environment selection;
- **deployer** owns reconciliation from selection to replicas;
- **server** owns proof of what it loaded.

Do not grant a training job permission to overwrite production aliases merely because it can register artifacts.

### Immutable manifest, mutable configuration

Immutable identity should cover every behavior-changing field. Some tools allow metadata or model configuration to change after version creation. Treat that mutability explicitly. Either:

1. include the resolved configuration digest in a separate immutable release manifest; or
2. create a new version when behavior changes.

The rule is operational, not tool-specific: the same release ID must never silently produce different behavior.

### Serving control plane and data plane

The control plane watches desired state and creates or updates serving resources. It can report `Ready` when infrastructure conditions pass. The data plane accepts inference traffic. Control-plane convergence can lag; replicas can hold different versions during rollout.

Record at least:

- desired release and route generation;
- replica name, node and startup generation;
- loaded model checksum and tokenizer/runtime identity;
- readiness time and warm-state evidence;
- request-time backend and release identity.

A deployment is converged only when observed replicas and routes match desired immutable state under the declared rollout policy.

### Kubernetes and GPU ownership

Kubernetes represents vendor devices as extended resources after a device plugin registers with the kubelet. The scheduler reasons about advertised quantities, node selectors, affinity, taints and other Pod constraints. It does not reason about model quality or arbitrary GPU-memory fractions.

For a whole GPU request, the common contract is a limit such as:

```yaml
resources:
  limits:
    nvidia.com/gpu: 1
```

This is an illustrative shape, not a command to apply. Exact resource names and sharing behavior come from the installed vendor stack.

GPU memory usually contains several owners:

```text
usable device memory
- model weights
- runtime/CUDA context and kernels
- temporary workspace
- KV cache
- active batch tensors
- fragmentation and safety margin
= remaining admission headroom
```

Measure peak behavior under representative sequence lengths and concurrency. An arithmetic estimate is an admission hypothesis; a pinned load test provides observed evidence.

### MIG and device sharing

Multi-Instance GPU can partition supported devices into isolated profiles. Changing geometry is node-level infrastructure work and can stop GPU workloads or require reboot. A Pod requesting a profile must land where that exact resource is advertised.

MIG, time slicing and runtime multiplexing solve different problems. Do not say “fractional GPU” without naming:

- isolation boundary;
- memory guarantee;
- compute sharing behavior;
- health and failure domain;
- advertised resource name;
- workload compatibility;
- reconfiguration procedure.

### Runtime scheduler, batching and head-of-line blocking

The model runtime sees requests after Kubernetes has scheduled the Pod. It may combine compatible work into **dynamic batches** to raise throughput. Waiting briefly can produce a fuller batch; waiting too long destroys latency.

LLM workloads vary by input and requested output length. A long prefill can delay short interactive requests. Decode iterations may mix sequences whose completion times differ. Good scheduling therefore needs:

- queue age and deadline;
- tenant or priority class;
- input and maximum output tokens;
- current KV-cache demand;
- cancellation state;
- fairness and starvation limits;
- batch wait and size caps.

More batching is not universally better. Optimize a declared frontier: useful throughput subject to tail-latency, fairness, quality and cost limits.

### KV and prefix cache ownership

KV cache belongs to a running model/runtime instance and is usually ephemeral. It is not a source of truth. Prefix caching reuses computed state when the prefix and all behavior-changing identities are compatible.

A safe logical cache key may include:

```text
tenant/isolation boundary
+ model and tokenizer digest
+ prompt/system-instruction version
+ policy and adapter version
+ exact normalized prefix tokens
+ runtime cache format/version
```

Never include sensitive raw content in metrics labels or cache logs. Hashing can still enable correlation or dictionary attacks; treat derived identifiers according to the original data classification.

### Gateway policy

At the gateway, separate:

- authentication: who is calling;
- authorization: which operation/model/data class is allowed;
- quota: how much over a long window;
- rate: arrival per short window;
- concurrency: simultaneous admitted work;
- token limits: maximum input/output or estimated work;
- route: which compatible release or pool;
- deadline: how long the entire operation may live;
- retry: which failures are safe and within the original budget.

A request that passes authentication can still be rejected for capacity or policy. Return an explicit bounded failure rather than queueing indefinitely.

### Telemetry ownership and privacy

The platform should define a versioned telemetry schema. For every span or metric, specify producer, units, aggregation and retention. GenAI conventions evolve, so record the schema version and keep an internal compatibility layer.

Prompt and completion content is often sensitive. Default telemetry should work without capturing content. If content samples are necessary for quality review, use separate access, explicit sampling, redaction, retention and deletion. Never put request IDs, user IDs or prompt text into unbounded metric labels.

### Outcome and label ownership

The inference platform can observe requests, tokens and runtime errors. It usually cannot declare the business outcome. The product domain owns what “correct,” “safe” and “useful” mean and when labels mature.

Join late outcomes to request and release identity without rewriting history. A model may look healthy today because fraud, chargeback, resolution or user-return labels arrive weeks later. Record both event time and availability time.

## Evidence table

Use this table during reviews and incidents.

| Evidence | What it proves | What it does not prove |
|---|---|---|
| Dataset snapshot digest | Exact tracked bytes matched the identifier | lawful origin, representativeness or correct labels |
| Source commit and pipeline run | Which code and execution claimed to build the artifact | hermetic build or absence of undeclared inputs |
| Model artifact digest | Byte identity | semantic quality, safe serialization or runtime compatibility |
| Signature validation | Input/output structure matched declared constraints | business correctness |
| Registry version | Artifact is recorded under an identity | approval or deployment |
| Alias history | Mutable pointer changed at a recorded time | which version every request used |
| Image digest | Exact OCI image manifest identity | vulnerability-free or hardware-compatible runtime |
| Offline aggregate metric | Performance on declared evaluation examples | critical-slice safety or live benefit |
| Sliced evaluation | Performance on represented cohorts | behavior on missing or future cohorts |
| Pod readiness | Probe condition passed | correct loaded model, answer quality or SLO |
| GPU allocation | Scheduler/device stack assigned advertised resource | memory fit, utilization or useful throughput |
| GPU utilization | Device engines were busy in the measured window | useful work or efficient cost |
| Queue depth | Number of waiting requests at observation | deadline feasibility without age/service distribution |
| Queue age | Waiting time of queued work | remaining completion time without service tail |
| TTFT | Delay until first generated token | completion time or answer quality |
| TPOT | Generation cadence after first token | queue/prefill delay or total useful outcome |
| End-to-end latency | Client-observed completion duration | correctness or stage cause |
| Prefix-cache hit | Compatible key lookup reused stored state according to implementation | tenant safety or output correctness |
| HTTP success | Transport completed with an accepted status | semantic validity or user success |
| Canary traffic weight | Intended proportional routing configuration | exact realized cohort or unbiased allocation |
| Per-request release label | Backend reported an immutable release for that request | truthful label unless independently checked |
| Product outcome | Declared downstream result occurred | model causality without design and confounder control |
| Drift score | Measured distribution or behavior changed under one detector | why, user harm or permission to retrain |
| Cost per request | Attributed spend divided by request count | cost per useful result |
| Rollback manifest | Previous desired state exists | it can load, route and recover inside objective |

The pattern is deliberate: every useful signal has a boundary. Senior engineering begins where the dashboard label ends.

## Command decoders

The local lab is a reasoning instrument. It will not download a model or touch Docker, Kubernetes or a GPU.

### `bash lab.sh doctor`

**Question:** Is this a safe place to run the model?

It refuses root, missing Python, common AI credentials, `KUBECONFIG`, symlinked state and wrong ownership. A pass proves only local prerequisites and fixture validity.

### `bash lab.sh setup`

Creates one private directory under `/tmp` for the current UID, writes an ownership sentinel and copies the synthetic fixture. It refuses an existing state instead of overwriting it. Always finish with `bash lab.sh cleanup`.

### `bash lab.sh status`

Validates ownership and exact inventory, then reports the case count. If an unknown artifact exists, status refuses. That is a lesson: automation must not clean up what it cannot prove it owns.

### `bash lab.sh show baseline`

Prints the fully resolved baseline state. Read it before evaluating failures. The fixture stores defaults plus a small override for each case, which makes the first changed assumption visible.

### `bash lab.sh evaluate data-alias-only`

Expected:

```text
case=data-alias-only boundary=data-identity
```

It demonstrates that a friendly dataset name cannot reproduce training bytes. Next evidence is a snapshot and digest, then schema, time and label provenance.

### `bash lab.sh evaluate mutable-model-alias`

Expected boundary: `model-identity`. Record alias history **and** the resolved immutable version/digest at approval, deployment and request time.

### `bash lab.sh evaluate aggregate-eval-only`

Expected boundary: `evaluation-slices`. A higher overall score cannot compensate for an unmeasured or regressed critical population.

### `bash lab.sh evaluate gpu-memory-overcommitted`

The fixture asks for 86 GiB against an 80 GiB modelled budget. Expected boundary: `gpu-memory`. It demonstrates arithmetic ordering only. It does not prove a real device has 80 usable GiB or that an 80-GiB estimate is safe.

### `bash lab.sh evaluate queue-deadline-missed`

The model evaluates:

```text
queue age + observed service p99 <= request deadline
1,400 ms + 800 ms > 2,000 ms
```

Expected boundary: `queue-deadline`. A real admission controller also needs elapsed gateway time, uncertainty and safety margin.

### `bash lab.sh evaluate tenant-budget-unbound`

Expected boundary: `gateway-budget`. Authentication without per-tenant rate, concurrency and work limits allows one valid caller to exhaust shared capacity.

### `bash lab.sh evaluate canary-version-unlabeled`

Expected boundary: `canary-attribution`. If metrics cannot distinguish immutable releases, there is no measurable canary—only mixed traffic.

### `bash lab.sh evaluate drift-auto-retrain`

Expected boundary: `drift-response`. Detection has observation authority. Retraining and promotion require separate classification, evaluation and approval authority.

### `bash verify.sh`

From absent state, the verifier checks all 30 cases, injects an unknown artifact to prove refusal, removes only that controlled test artifact and proves the lab root is absent.

Do not edit expected boundaries merely to make verification green. A failing branch means the teaching contract and implementation disagree.

## Decision path

Use this path when designing, releasing or debugging.

```text
Is the user operation, harm and fallback defined?
  no ─► stop: operation-contract
  yes
   │
Is every behavior-changing input immutable and joined?
  no ─► stop: release identity
  yes
   │
Did representative, chronological, sliced evaluation pass?
  no ─► reject candidate
  yes
   │
Does serving mode match deadline, durability and interaction?
  no ─► redesign interface
  yes
   │
Can gateway admit this tenant within work and deadline budgets?
  no ─► shed, defer, degrade or route safely
  yes
   │
Do device, memory, queue, cache and batch envelopes fit?
  no ─► change capacity or admission before exposure
  yes
   │
Can traffic be attributed and rollback meet its objective?
  no ─► do not canary
  yes
   │
Do quality + safety + SLO + cost gates pass at current exposure?
  no ─► stop, rollback, reconcile, diagnose
  yes ─► ramp one bounded step and observe again
```

### Choosing serving mode

Ask in this order:

1. Does a human or synchronous service need the answer now?
2. Is partial output valuable and safe?
3. Can the operation be retried idempotently?
4. What is the maximum completion deadline?
5. Can work be grouped without violating per-item latency or data isolation?

Choose batch for large bounded sets with a completion window. Choose asynchronous work for expensive operations that outlive a client connection. Choose synchronous online for bounded immediate decisions. Add streaming only when early output improves the operation and cancellation is engineered.

### Promotion is an AND gate

Represent promotion as:

```text
promote =
  identity_complete
  AND evaluation_passed
  AND critical_slices_passed
  AND security_and_privacy_passed
  AND reliability_SLO_passed
  AND capacity_envelope_passed
  AND unit_cost_passed
  AND rollback_ready
  AND authorized
```

Do not average failed gates into a composite score. A serious safety regression cannot be canceled by cheaper tokens.

### Scale, optimize or reject

- **Scale** when demand is legitimate, work is useful, the bottleneck is measured and replicas or hardware reduce it inside cost limits.
- **Optimize** when work can be reduced without violating quality or isolation: smaller proven model, quantization, bounded batching, prefix reuse, shorter context, speculative methods or better routing.
- **Shed/defer** when the remaining deadline or tenant budget cannot support the work.
- **Reject the release** when identity, evaluation, security, compatibility or recovery evidence fails.

The most expensive option is scaling an unidentified or harmful release.

## Guided Ubuntu lab

### What this lab is for

This lab makes you practise the **order of refusal**. It is intentionally small enough to inspect completely. There is no hidden model server and no Internet access. You will see how one missing control stops a release decision before later evidence is considered.

### Prerequisites and safe location

Use Ubuntu 24.04 as a normal user. From the repository root:

```bash
cd drafts/LES-0068-mlops-llmops-production-lifecycle/support/lab
pwd
id
command -v bash
command -v python3
```

Decode:

- `pwd` must end in this lesson's `support/lab` directory.
- `id` must not report UID 0.
- `command -v` proves command resolution only; it does not prove a compatible version.
- Do not export cloud, model-provider or Kubernetes credentials for this lab.

If your path is wrong, stop. The cleanup contract is intentionally tied to one UID-scoped `/tmp` directory.

### Step 1: inspect before execution

```bash
sed -n '1,240p' lab.sh
sed -n '1,260p' model.py
python3 -m json.tool fixtures/cases.json >/dev/null
```

You should be able to locate:

- root and credential refusal;
- the exact state path;
- sentinel and ownership checks;
- the allowlisted inventory;
- the ordered `boundary` function;
- the baseline plus per-case overrides.

Redirecting `json.tool` output to `/dev/null` still parses the file; success proves syntax only.

### Step 2: run the doctor

```bash
bash lab.sh doctor
```

Expected shape:

```text
model=valid cases=30
doctor=pass network=none user=<your-uid>
```

If it refuses a credential or endpoint, use a clean subshell rather than printing or copying the secret:

```bash
env -u OPENAI_API_KEY \
    -u ANTHROPIC_API_KEY \
    -u GOOGLE_API_KEY \
    -u AZURE_OPENAI_ENDPOINT \
    -u KUBECONFIG \
    bash lab.sh doctor
```

This removes variables only for that command. It does not delete credentials from your shell or disk.

### Step 3: create bounded state

```bash
bash lab.sh setup
bash lab.sh status
```

Expected status includes `cases=30`. Setup uses `umask 077`, so other users should not gain access through the created directory. It refuses an existing directory because overwriting uncertain state would weaken ownership.

### Step 4: establish the good path

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

Read the JSON from `show`. The baseline is “operable” only inside the toy contract. It does not claim that a production system is ready.

### Step 5: break identity in layers

```bash
bash lab.sh evaluate release-manifest-incomplete
bash lab.sh evaluate data-alias-only
bash lab.sh evaluate data-digest-mismatch
bash lab.sh evaluate mutable-model-alias
bash lab.sh evaluate prompt-unversioned
bash lab.sh evaluate tokenizer-mismatch
```

Notice that each case changes one assumption. In a real incident, multiple controls may fail. Diagnose the earliest boundary because later metrics may be attached to the wrong release.

Write this sentence in your own words:

> An alias tells me which version a control plane intended to select at a time; a resolved digest tells me which immutable content I am claiming.

### Step 6: challenge evaluation

```bash
bash lab.sh evaluate evaluation-dataset-unversioned
bash lab.sh evaluate scorer-unversioned
bash lab.sh evaluate aggregate-eval-only
bash lab.sh evaluate future-leakage
```

For each branch, say what must be versioned:

- examples, labels and time range;
- preprocessing;
- scorer code/configuration and any evaluator model;
- random seeds or repeated-run policy where relevant;
- slice membership and threshold;
- incumbent baseline.

An LLM judge is another model-based measurement instrument. It needs version, prompt, calibration and disagreement evidence. It cannot be the sole authority for a high-impact release.

### Step 7: challenge the serving path

```bash
bash lab.sh evaluate serving-mode-mismatch
bash lab.sh evaluate gateway-auth-missing
bash lab.sh evaluate tenant-budget-unbound
bash lab.sh evaluate retry-deadline-reset
```

Explain why these are distinct:

- authentication says who;
- authorization says allowed operation;
- budgets bound how much;
- a single deadline bounds how long;
- idempotency bounds repeated effects.

### Step 8: calculate GPU and queue admission

```bash
bash lab.sh show gpu-memory-overcommitted
bash lab.sh evaluate gpu-memory-overcommitted
bash lab.sh evaluate gpu-device-unhealthy
bash lab.sh evaluate gpu-profile-mismatch
bash lab.sh show queue-deadline-missed
bash lab.sh evaluate queue-deadline-missed
bash lab.sh evaluate batch-head-of-line
```

The two arithmetic checks are:

```text
memory admission: 86 GiB requested > 80 GiB budget
deadline admission: 1,400 ms queue age + 800 ms service p99 > 2,000 ms deadline
```

In production, add uncertainty and safety margin. A p99 from yesterday is not a promise for the next request.

### Step 9: challenge cache, canary and rollback

```bash
bash lab.sh evaluate cache-tenant-unbound
bash lab.sh evaluate canary-version-unlabeled
bash lab.sh evaluate canary-sample-too-small
bash lab.sh evaluate rollback-cold-too-slow
```

A traffic weight is a desired ratio, not sample evidence. A minimum count is also not enough by itself; the observation window must cover representative workload and label maturity.

### Step 10: challenge monitoring and economics

```bash
bash lab.sh evaluate drift-auto-retrain
bash lab.sh evaluate label-delay-ignored
bash lab.sh evaluate telemetry-content-unsafe
bash lab.sh evaluate unit-cost-unmeasured
bash lab.sh evaluate telemetry-cardinality-unbounded
```

For telemetry, prefer bounded dimensions such as release, model family, route and operation. Put request-level identities in traces or logs with controlled retention, not metric labels.

### Step 11: prove refusal and cleanup

```bash
bash verify.sh
test ! -e "/tmp/reliability-atlas-les0068-mlops-$(id -u)"
```

Expected:

```text
verify=pass cases=30 refusal=true cleanup=true
```

If verification stops, preserve the first error. You may run `bash lab.sh cleanup` only when the state contains exactly the allowlisted sentinel and fixture. Never replace cleanup with a broad recursive delete.

### What you should be able to explain

Without looking back, explain:

1. why a model alias and a model digest are different;
2. why `Ready` and GPU allocation do not prove user success;
3. how queue age can make a new request impossible before execution;
4. why canary metrics need immutable release attribution;
5. why a drift alert cannot own retraining authority.

## Production transfer

The offline lab teaches logic. Production skill requires a disposable representative environment owned by a reviewer.

### Transfer topology

Use local-only components where possible:

```text
synthetic client
   │ short/long requests, tenants, deadlines, cancellations
   ▼
local gateway simulator
   │ auth, quota, route, immutable release labels
   ├──────────────► incumbent service
   └──────────────► candidate service
                         │
                    CPU model simulator
                    or approved local model runtime
                         │
                   metrics/traces/logs
                         ▼
                 local outcome evaluator
```

A GPU is optional for learning the release system. If no compatible local GPU exists, simulate service-time and memory envelopes honestly. Do not call the result a GPU benchmark.

### Required experiments

Run these under a reviewer-authored harness:

1. **Identity test:** move a mutable alias and prove existing and new replicas report exact resolved digests.
2. **Compatibility test:** inject tokenizer or schema mismatch and prove traffic never reaches an ineligible replica.
3. **Queue test:** mix short and long requests; show queue age, TTFT, cancellation and admission behavior.
4. **Tenant test:** overload one tenant; prove other tenants retain their declared service.
5. **Canary test:** allocate a deterministic cohort, compare per-release quality/SLO/cost, stop on a failed gate.
6. **Rollback test:** remove candidate traffic, restore compatible incumbent, reconcile caches and prove user postconditions inside objective.
7. **Drift test:** inject telemetry schema change separately from population and outcome change; classify them correctly.
8. **Economics test:** calculate tokens or predictions, constrained-resource seconds and cost per useful outcome.

### Bad-canary incident

Suppose the candidate is ready and receives 10% traffic. HTTP errors remain flat, but one critical cohort regresses, p95 TTFT crosses SLO and useful-outcome cost doubles.

Respond:

1. Stop further ramp; preserve current route generation.
2. Verify request-level release attribution from both gateway and backend.
3. Route candidate cohort to the known compatible incumbent.
4. Confirm incumbent is warm and outcome/SLO recovery is observed.
5. Reconcile candidate queues and caches; do not strand billable work.
6. Compare exact release deltas: data, model, tokenizer, prompt, retrieval, policy, image and runtime.
7. Identify why offline, slice, latency or economic gates allowed exposure.
8. Correct the earliest failed control and rehearse again.

### Evidence package

The final review packet should include:

- architecture and authority diagram;
- immutable release manifests for incumbent and candidate;
- registry and alias audit;
- evaluation dataset/scorer identities and sliced results;
- traffic allocation and sample calculations;
- request-stage latency and resource distributions;
- device/runtime compatibility and memory model;
- tenant-budget and cancellation evidence;
- incident timeline and containment receipts;
- rollback time and independent outcome recovery;
- unit economics and residual uncertainty;
- exact cleanup proof.

Do not include real secrets, customer prompts or unrestricted production exports.

## Reliability, security, observability, capacity, and cost

### Reliability

Define separate SLOs for:

- availability of the user operation;
- semantic success or acceptable-quality rate;
- latency appropriate to mode: batch deadline, synchronous total, streaming TTFT and TPOT;
- freshness of model, features or retrieval corpus;
- rollback/recovery time;
- outcome-label coverage and delay.

Health probes should test the smallest safe conditions. Startup may verify artifact integrity and compatibility. Readiness may require model loaded and warmed. Liveness should detect irrecoverable process failure without restarting slow-but-progressing work. Do not put expensive inference into every probe.

### Security

Protect:

- artifact provenance and integrity;
- registry promotion permissions;
- model serialization and dependency loading;
- gateway authentication and authorization;
- tenant isolation in queues and caches;
- prompt, context, output and trace confidentiality;
- administrative model/gateway/GPU APIs;
- audit records and rollback artifacts.

Use least privilege. Training may write candidate artifacts, evaluation may write results, promotion may move a controlled pointer, deployment may read approved artifacts, and serving should not mutate registry state.

### Observability

At minimum correlate:

```text
request + tenant + operation + trace
route decision + release + model + prompt + policy
queue + batch + runtime + device
input/output token counts + finish/cancel reason
quality/safety signal + delayed user outcome
```

Collect stage distributions, not only averages. Server metrics explain request metrics: queue depth, running/waiting requests, KV-cache use, preemptions and token throughput help explain TTFT and TPOT.

Keep content capture opt-in and separate from baseline observability. Record dropped spans and sampling policy because missing telemetry can bias conclusions.

### Capacity

Capacity is multidimensional:

- requests per second;
- input and output tokens per second;
- concurrent sequences;
- input/output length distribution;
- model-weight and KV-cache memory;
- queue wait and deadline;
- CPU preprocessing, network and storage;
- cold-load and warmup time;
- device health and failure domains.

Little's Law provides a useful consistency check for a stable system:

```text
average concurrency ≈ arrival rate × average time in system
```

If 20 requests/s spend 2 s in the system, average concurrency is about 40. Tail and burst admission still need separate modelling.

For a canary, budget duplicate shadow work explicitly. Shadowing 100% traffic can nearly double inference work even though users see one answer.

### Cost

Calculate at multiple levels:

```text
GPU window cost = GPU count × hours × cost per GPU-hour
cost per 1,000 tokens = attributable cost / tokens × 1,000
cost per useful outcome = attributable cost / verified useful outcomes
cache value = avoided measured work - cache/storage/coordination cost
```

Example from ASM-0188:

- 10 minutes on one $3.60/GPU-hour device costs `10/60 × 3.60 = $0.60`.
- 120,000 input plus 30,000 output tokens equals 150,000.
- 80 useful outcomes means `150,000/80 = 1,875` tokens per useful outcome.
- GPU cost per useful outcome is `$0.60/80 = $0.0075`.

This is only GPU cost for the stated window. Real attribution may include idle reservation, CPU, memory, storage, networking, gateways, telemetry and engineering overhead.

### Trade-off matrix

| Change | Possible benefit | New risk | Required gate |
|---|---|---|---|
| Larger batch | throughput | wait and head-of-line blocking | tail latency and fairness |
| Longer context | information coverage | prefill, memory and spend | sliced quality per token/cost |
| Prefix cache | lower repeated prefill | stale identity or tenant leakage | immutable key and isolation tests |
| Quantization | smaller/faster model | quality or compatibility loss | representative quality and runtime evidence |
| More replicas | capacity and fault tolerance | cost, load time and shared bottleneck | measured bottleneck and unit economics |
| Scale to zero | idle savings | cold rollback/start latency | recovery objective |
| MIG partition | isolation and packing | profile fit and disruptive reconfiguration | compatibility and node procedure |
| Automatic retraining | freshness | feedback loop and unsafe promotion | classified drift plus normal release gate |

## Traps and prevention

### Trap: “The model version is champion”

**Why it fails:** `champion` is a mutable alias.

**Prevent:** record immutable version and digest in the release manifest, deployment status and request telemetry; audit alias changes.

### Trap: “The image tag is pinned”

**Why it fails:** a tag can move.

**Prevent:** deploy by image digest and retain the build/provenance link. A digest proves bytes, not security; scan and review separately.

### Trap: “Accuracy improved”

**Why it fails:** metric, data, scorer, slice, threshold and uncertainty are omitted.

**Prevent:** version the evaluation system, compare incumbent and candidate on representative chronological slices, and retain raw results.

### Trap: “Ready means correct”

**Why it fails:** readiness usually checks process or dependency state.

**Prevent:** verify loaded digests and compatibility at startup, use bounded golden checks where safe, and gate on live user evidence.

### Trap: “One GPU means the model fits”

**Why it fails:** device count does not express usable memory or runtime peaks.

**Prevent:** pin profile and compatibility; budget weights, workspace, cache, batch, fragmentation and margin; load-test representative lengths.

### Trap: “Increase batch size”

**Why it fails:** throughput can improve while interactive tail latency and fairness collapse.

**Prevent:** cap batch wait and size by operation; monitor queue age, TTFT, TPOT, cancellations and useful throughput.

### Trap: “Retry on another backend”

**Why it fails:** retries reset deadlines, duplicate billing/work and multiply overload.

**Prevent:** one operation ID, one end-to-end deadline, retry budget, cancellation, idempotency and external-state reconciliation.

### Trap: “Cache by prompt”

**Why it fails:** prompt aliases move; model, tokenizer, policy and tenant can differ.

**Prevent:** key on immutable computational identity plus isolation boundary; test invalidation and cross-tenant refusal.

### Trap: “Ten percent canary”

**Why it fails:** percentage does not state cohort, realized sample, duration, label maturity or release attribution.

**Prevent:** predeclare allocation, sample/time gates, critical slices, abort conditions and exact route/backend identity.

### Trap: “Rollback is one command”

**Why it fails:** previous weights can be cold and state or schema can be incompatible.

**Prevent:** retain a proven target, test warm/load time, use expand-contract compatibility, reconcile queues/caches and verify user postconditions.

### Trap: “Drift means retrain”

**Why it fails:** measurement, population, label, system and cost changes can mimic concept drift.

**Prevent:** classify drift, validate telemetry, wait for mature outcomes where required, then submit a new candidate through normal gates.

### Trap: “Do not log prompts, so privacy is solved”

**Why it fails:** outputs, tokenized content, embeddings, traces, cache keys and review samples may still leak information.

**Prevent:** perform end-to-end data classification, minimization, access, retention and deletion design; keep content out of metric labels.

### Trap: “GPU utilization is high, so efficiency is high”

**Why it fails:** the GPU may generate unused, timed-out or low-quality tokens.

**Prevent:** connect resource work to completed useful outcomes and compare a quality/SLO-constrained cost frontier.

## Memory card and retrieval

Remember:

```text
OUTCOME -> MANIFEST -> EVALUATE -> ADMIT -> SERVE -> ATTRIBUTE
        -> GATE -> RAMP -> OBSERVE -> ROLLBACK -> LEARN
```

- The model is one artifact; the release is the complete behavior.
- A version is immutable; an alias is a movable pointer.
- Registration is not approval; approval is not deployment; deployment is not request proof.
- `Ready` is process evidence, not answer evidence.
- GPU allocation is not memory fit or useful capacity.
- Kubernetes schedules Pods; the runtime schedules requests.
- Queue age spends the user's deadline before inference begins.
- TTFT includes waiting and prefill; TPOT describes decode cadence.
- Larger batches trade latency and fairness for throughput.
- Prefix caches require immutable computational identity and tenant isolation.
- A canary needs attributed requests, representative exposure and conjunctive gates.
- Rollback must be warm or loadable, compatible, routable and rehearsed.
- Drift describes change; it does not explain cause or authorize retraining.
- Count useful outcomes, not only requests, tokens or utilization.

Retrieval drill: close the chapter and reconstruct the eleven-word chain. For each arrow, name:

1. the authority that changes state;
2. the observer that measures it;
3. one signal that can lie by omission;
4. the rollback or refusal path.

If you cannot distinguish desired alias, loaded digest and request-time release, return to the architecture map.

## Complete answers

### What exactly must be versioned for an ML or LLM release?

Version every input that can change output, execution, safety or interpretation:

- source commit, build definition and dependency lock;
- training dataset snapshot, labels, time boundaries, feature code and schema;
- model weights, serialization format, signature and tokenizer;
- prompt template, rendering rules, model parameters and output schema;
- retrieval corpus, chunking, embedding, index and reranker;
- adapters, tools and policy bundle;
- container image digest, runtime libraries and hardware compatibility;
- evaluation dataset, scorer implementations/configuration, thresholds and results;
- approval, deployment and route generation.

Put their immutable identities into one release manifest. A mutable alias can select that release, but must never replace its identity. At request time record the resolved release, because control-plane intent and replica state can temporarily differ.

### Why is a model registry not enough?

A registry answers, “Which artifacts and metadata are known?” It does not automatically prove:

- training data provenance;
- reproducible build inputs;
- evaluation quality;
- authorization to promote;
- which image and runtime loaded the artifact;
- which replicas converged;
- which release served a request;
- or whether users benefited.

Use the registry as one system of record inside a larger release chain. Separate permissions for registering candidates, approving them, moving environment pointers and deploying. Audit mutable aliases. Verify loaded checksums and request attribution independently.

### How do I evaluate a classic ML model versus an LLM application?

Both need a versioned representative dataset, an incumbent baseline, chronological separation where time matters, critical slices, uncertainty and business error costs.

Classic classification may use confusion matrices, precision, recall, calibration and task-specific cost. Regression may use absolute/squared errors and residual slices. These metrics are still insufficient if the live operation or data path differs.

LLM evaluation must bind the entire application release. Preserve raw outputs and finish reasons. Use deterministic checks for schema, grounded facts, citations, policy and tool behavior where possible. Use human-reviewed rubrics for subjective properties. If a model judge is used, version its model, prompt and configuration; measure agreement and bias. Repeat stochastic runs where variance matters. Never reduce safety to one average judge score.

The release gate should compare candidate to absolute requirements and the incumbent. A candidate that improves average quality but violates one protected slice is not ready.

### How do I choose batch or online serving?

Start with the consumer:

- If thousands of records may complete by 06:00 and no caller waits, use batch.
- If a service needs an answer inside 200 ms, use synchronous online.
- If work may take minutes and the caller can poll or receive an event, use asynchronous online.
- If partial output is valuable before completion, use streaming.

Then add recovery properties. Batch needs checkpoints and atomic output publication. Asynchronous work needs durable operation identity and idempotency. Synchronous work needs strict admission and one deadline. Streaming needs disconnect propagation, cancellation and partial-output semantics.

Do not expose a synchronous API over an unbounded queue. That converts overload into invisible waiting.

### Why can a GPU Pod be scheduled and still fail with OOM?

Kubernetes sees an advertised extended resource. It usually allocates a device or profile, not a continuously enforceable model-memory budget.

At runtime, memory is consumed by weights, contexts, kernels, workspace, KV cache, active batches and fragmentation. Sequence lengths and concurrency change peaks. A different quantization or runtime version changes the envelope. Device health can change after scheduling.

Diagnose by binding Pod, node, device/profile, driver/runtime, model digest, memory components, batch and sequence distribution. Stop restart loops. Reduce admitted concurrency/context/cache, choose a smaller proven model/profile, or move to compatible capacity. Verify useful throughput and quality after the change.

### How do batching and KV cache affect latency?

Batching amortizes accelerator work across requests, often improving tokens per second. Forming the batch requires waiting, and long requests can delay short ones. The correct knob depends on operation deadlines and length distribution.

KV cache avoids recomputing prior attention state during decode. More concurrent or longer sequences consume more cache. Near capacity, the runtime may queue, preempt, evict or recompute, which can increase TTFT or TPOT. Prefix caching can save repeated prefill, but only for compatible exact prefixes under safe identity and isolation.

Watch queue age, running/waiting requests, batch composition, prompt/output lengths, KV use/evictions, TTFT, TPOT, cancellations and useful throughput together. An isolated utilization graph cannot select the right policy.

### What should a model gateway enforce?

At the trust boundary it should:

1. authenticate caller and workload identity;
2. authorize operation, model class and data sensitivity;
3. enforce tenant rate, quota, concurrency and token/work budgets;
4. validate request schema and declared size;
5. carry one operation ID, trace and original deadline;
6. resolve an eligible immutable release or pool;
7. record route decision and policy version;
8. retry only safe failures within the same deadline and effect budget;
9. provide explicit fallback, degradation or rejection;
10. produce an auditable response identity without leaking content.

The gateway should not silently rewrite a request into a cheaper model when semantics differ. Fallback is a product contract, not a traffic trick.

### How do I run a safe model canary?

Before exposure:

- pin candidate and incumbent manifests;
- prove both can serve and rollback compatibility is current;
- define deterministic allocation and exclusions;
- state minimum sample, duration and label-maturity requirements;
- define quality, critical-slice, safety, SLO, capacity and cost gates;
- attach release identity at route and backend;
- test abort and kill switch.

Begin with shadow traffic when safe and useful, then a small real cohort. Compare rates using denominators, not raw counts. Check for allocation bias and novelty. Ramp one bounded step only after all gates pass. Stop immediately on a material safety or user-harm signal even if the sample is below the planned minimum; minimum sample prevents promotion, not containment.

### How do I design rollback?

Choose a previous release that is still compatible with current request, feature, retrieval and output contracts. Measure:

- artifact availability and checksum;
- model load and warm time;
- replica and device capacity;
- route propagation;
- cache compatibility/invalidation;
- queued and in-flight request handling;
- downstream schema/state compatibility;
- user postcondition recovery.

Keep it warm when the recovery objective is shorter than cold load. Roll back traffic, not history: preserve candidate artifacts, route decisions and evidence. Reconcile in-flight work so retries do not duplicate billable or external effects. Verify recovery from user signals independently of the deploy command.

### What do I do when drift is detected?

First verify the measurement:

1. Did schema, units, sampling, logging or population identity change?
2. Is the comparison window appropriate and seasonally comparable?
3. Are labels mature and coverage stable?
4. Did feature computation or serving behavior change?
5. Did user behavior or the desired concept change?
6. Did latency, routing or timeouts alter observed examples?
7. Did costs change because token lengths, retries or prices changed?

Classify the drift. Protect users with fallback or bounded policy when impact is known. If a new model is justified, create a versioned candidate and run the same evaluation, approval and progressive-release system. Never let the detector mutate the production alias directly.

### How should I calculate LLM serving economics?

Pick the constrained-resource window and outcome:

```text
total tokens = input + output
GPU cost = allocated or attributable GPU-hours × rate
token intensity = total tokens / useful outcomes
resource intensity = GPU-seconds / useful outcomes
unit cost = total attributable cost / useful outcomes
```

Slice by model/release, operation, tenant class and request length. Include retries, abandoned streams and invalid outputs because they consume resources. Report reserved idle capacity separately from marginal work. Compare candidates only while quality, safety and latency requirements are held.

Optimization order:

1. remove invalid and duplicate work;
2. enforce limits and cancellation;
3. reduce unnecessary context/output;
4. improve cache or batching within isolation/SLO gates;
5. select smaller or optimized models only after quality evaluation;
6. scale hardware for legitimate remaining demand.

### How do I monitor LLM serving without leaking data?

Begin content-free:

- request/trace/tenant pseudonymous identity;
- operation and immutable release;
- route, queue, batch, model and device stages;
- input/output token counts;
- TTFT, TPOT, total latency, status and finish/cancel reason;
- cache and runtime saturation;
- policy result and product outcome reference.

Keep cardinality bounded in metrics. Use traces/logs for request-level evidence with access and retention controls. If content review is required, sample into a separate governed store with minimization, redaction, explicit purpose, reviewer access, deletion and audit. Record telemetry schema version and sampling/drop behavior so absence is not mistaken for health.

## Product-company interview

### Design an MLOps platform for a payment risk model

Start with the authorization decision, latency SLO, false-approve and false-decline costs, fallback and regulatory slices. Version training data/labels by event and maturity time, feature definitions, model/signature and evaluation. Build an immutable manifest and separate registration from approval.

Serve online behind authenticated tenant-aware admission. Log serving features safely to measure training-serving skew. Canary on deterministic cohorts with loss, calibration, critical-slice, latency and outcome gates. Keep a compatible incumbent within rollback objective. Monitor delayed fraud/chargeback labels, feature freshness, drift classes and cost per correctly handled decision. Never auto-promote a retrain from drift alone.

### Design a multi-tenant internal LLM gateway

Authenticate workload identities and authorize allowed model/data classes. Enforce per-tenant rate, concurrency, input/output token and spending budgets. Carry one deadline and trace. Route only to compatible, approved immutable releases.

Use fair admission and separate interactive from batch capacity. Preserve model/prompt/policy and backend identity. Bound retries and propagate cancellation. Protect cache keys by tenant and immutable computational identity. Observe queue, TTFT, TPOT, tokens, outcomes and cost without capturing content by default. Provide declared fallback and kill switches. Audit every policy and route change.

### The candidate is 8% faster and 20% cheaper. Do you promote?

Not yet. Ask:

- Faster for which latency: p50, p99, TTFT, TPOT or total?
- Cheaper per request, token or useful outcome?
- Are quality and safety non-inferior by critical slice?
- Are evaluation set, scorer and incumbent versions identical?
- Is live allocation attributable and representative?
- Does memory, queue and failure behavior fit?
- Is rollback warm and compatible?

Promotion is an AND gate. Performance and price cannot compensate for an unsafe cohort or missing lineage.

### Why is average GPU utilization a weak autoscaling signal?

It mixes prefill and decode, useful and abandoned work, short and long requests, and possibly multiple models. High utilization may coexist with unacceptable queue age; low utilization may occur while one memory-bound model cannot admit more sequences.

Use a capacity model combining admitted work, queue age, token arrival, running/waiting requests, KV pressure, TTFT/TPOT and useful throughput. Scaling also has load/warm delay, so predict or retain headroom for that lead time. Apply maximum capacity and cost budgets.

### How would you debug a p99 TTFT regression?

First bind affected operation, tenant, release and time. Decompose gateway time, queue age and prefill. Compare request-length distribution, arrival bursts, routing, batch wait, running/waiting requests, KV pressure/preemption, device profile/health, runtime version and competing workloads. Check whether retries or a cold rollout amplify load.

Contain by stopping the ramp, preserving evidence, protecting interactive capacity and routing to the previous compatible release. Do not tune decode parameters if the regression is queue wait.

### A prompt-only change caused an incident. Why did normal CI miss it?

Likely the prompt was treated as text rather than executable release configuration. It may have changed token length, tool behavior, output schema or protected-slice quality while the model and image remained constant.

Make prompt templates immutable versions. Bind rendering logic, model parameters, schema, policy and evaluator identities. Run representative evaluation and token/cost analysis for prompt changes. Release through the same shadow/canary/rollback gates as code or model changes.

### Explain canary versus shadow to a senior interviewer

Shadow duplicates real inputs to a candidate but discards candidate effects. It is useful for compatibility, latency and offline comparison, but increases cost and privacy exposure and cannot fully measure user response.

Canary exposes an identified real cohort to candidate effects. It can measure user outcomes but has blast radius. Both need immutable attribution. Use shadow first when it reduces uncertainty safely, then canary with bounded allocation, conjunctive gates and rollback.

### How would you prevent one team from exhausting shared LLM capacity?

Use authenticated tenant identity, declared priority and per-tenant long-window quota, short-window rate, concurrency and token/work limits. Reserve capacity for critical operations, use fair scheduling and bound queue age. Expose budget and rejection telemetry. Prevent identity spoofing and cache leakage. Provide asynchronous or smaller-model fallback only when product semantics allow it.

Do not rely on global autoscaling alone: one tenant can make scaling chase unbounded demand and cost.

### What is the hardest MLOps reliability problem?

Maintaining trustworthy identity across delayed, distributed evidence. The build system knows one set of inputs, the registry has mutable pointers, replicas converge over time, gateways route by policy, labels arrive later and costs live elsewhere. Without a stable release/request join, evaluation, incident response, rollback and learning all become guesswork.

The durable solution is not one dashboard. It is immutable manifests, request-time attribution, versioned telemetry, explicit authorities, independently observed outcomes and rehearsed recovery.

## Independent transfer and rubric

The learner receives an unfamiliar sanitized system containing release manifests, registry history, evaluation results, deployment and route state, synthetic requests, GPU profiles, runtime telemetry, delayed outcomes and cost records. The reviewer injects one bad canary, tail-latency or unit-cost failure.

The learner must:

1. define the user operation, SLO, harm, fallback and non-model baseline;
2. reconstruct every immutable release input and identify mutable pointers;
3. find the first missing identity or incompatible artifact;
4. audit evaluation chronology, scorer versions, slices, uncertainty and error costs;
5. defend serving mode and trace one request through the gateway and runtime;
6. calculate deadline and GPU-memory admission;
7. explain GPU allocation versus useful capacity;
8. inspect queue, batch, KV-cache, TTFT, TPOT and cancellation evidence;
9. calculate canary rates and unit economics;
10. contain the incident and prove rollback from user outcomes;
11. classify a drift signal without granting it promotion authority;
12. revise the design after a hardware, residency, tenant, latency, safety or budget constraint changes;
13. prove exact cleanup and state residual uncertainty.

Scoring:

- **90-100:** complete identity, correct calculations, representative evaluation, safe admission, attributed canary, reversible recovery, honest uncertainty and outcome-linked economics.
- **75-89:** safe decision and recovery with minor evidence, slice or capacity gaps.
- **60-74:** useful architecture but one major identity, evaluation, tenant, GPU, rollout, drift or recovery boundary is weak.
- **Below 60:** treats aliases as versions, readiness as correctness, allocation as capacity, drift as authority or utilization as value.

Automatic failure: real credentials/customer data, shared production mutation, unrestricted cluster/GPU access, external model calls, unbounded load, hidden evaluator changes, fabricated evidence, unauthorized promotion or missing teardown.

The detailed reviewer-only contract is `ASM-0189`. It intentionally contains no answer-derived fields. Reading this chapter or passing the deterministic lab does not award mastery.

## References and review

- [Google Rules of Machine Learning](https://developers.google.com/machine-learning/guides/rules-of-ml/) - end-to-end pipeline discipline, freshness, chronological evaluation and measured training-serving skew.
- [DVC `add` documentation](https://dvc.org/doc/command-reference/add) - versioned metadata and content-addressed handling for large data artifacts.
- [Open Container Initiative overview](https://opencontainers.org/about/overview/) - image manifests, configuration, layers and content-addressable identity.
- [MLflow Model Registry workflows](https://mlflow.org/docs/latest/ml/model-registry/workflow/) - versions, tags, aliases, environment separation and promotion workflows.
- [MLflow prompt creation and versioning](https://mlflow.org/docs/latest/genai/prompt-registry/create-and-edit-prompts/) - immutable prompt-template versions, comparison and associated configuration.
- [MLflow classic model evaluation](https://mlflow.org/docs/latest/ml/evaluation/) - task metrics, artifacts, baseline comparison and validation thresholds.
- [MLflow LLM and agent evaluation](https://mlflow.org/docs/latest/genai/eval-monitor/) - evaluation datasets, prediction functions, scorers, traces and production monitoring.
- [KServe introduction](https://kserve.github.io/website/docs/intro) - serving control/data planes, inference resources, health, scaling and model-serving patterns.
- [KServe LLM canary rollout](https://kserve.github.io/website/docs/next/model-serving/generative-inference/llmisvc/canary-rollout) - version-sensitive weighted rollout, readiness, ramp, promotion and rollback mechanics.
- [Kubernetes GPU scheduling](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/) - vendor device plugins, extended resources and GPU request/limit constraints.
- [Kubernetes Device Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/) - device registration, allocation, health and topology.
- [NVIDIA GPU Operator with MIG](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html) - GPU partition profiles and disruptive reconfiguration lifecycle.
- [vLLM metrics](https://docs.vllm.ai/en/stable/design/metrics/) - request and server metrics including queue, TTFT, TPOT, KV cache and token work.
- [Kubernetes Gateway API Inference Extension](https://gateway-api-inference-extension.sigs.k8s.io/guides/) - inference-aware routing and scheduling integration.
- [OpenTelemetry GenAI Semantic Conventions](https://github.com/open-telemetry/semantic-conventions-genai) - versioned conventions for GenAI spans, metrics and events.

Source review was performed on 2026-08-05. Product APIs, next-channel documentation, hardware support, metric names and semantic conventions can change. Pin versions and verify local behavior before implementation.

This candidate still requires formal technical, instructional, security and source review; a representative model-serving runtime; measured fault, workload and recovery evidence; independent transfer; delayed recall; and publication review. The offline model proves only deterministic evidence ordering.
