---
{"schemaVersion":1,"kind":"lesson","id":"LES-0064","slug":"workflow-ml-platform-reliability","aliases":["V06-L09","workflow-ml-platform-reliability"],"curriculumIds":["DMP-003"],"route":"/book/state/workflow-ml-platform-reliability","order":9,"volume":"06-state-distributed-systems","title":"Workflow and ML-platform reliability: prove every run, model, and serving decision","summary":"Operate Airflow- and MLflow-shaped platforms by tracing run identity, data intervals, idempotency, scheduling, backfills, experiment lineage, evaluation, promotion, feature parity, drift, serving rollback, notebooks, privacy, capacity, and cost.","domain":"state","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0026","LES-0061","LES-0062"],"prerequisiteCurriculumIds":["OBS-001","DST-006","DMP-001"],"testedEnvironments":[{"platform":"Official documentation","version":"Apache Airflow 3.3.0, current MLflow and Jupyter Server sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish a deployment's behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, scheduler, registry, model server, notebook kernel or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","data-engineer","machine-learning-engineer","ml-platform-engineer","data-platform-engineer","solutions-architect","technical-lead"],"learningObjectives":["Trace a scheduled data or ML outcome from business decision through DAG run, task instances, execution infrastructure, artifacts, model version, deployment and consumer result.","Distinguish a DAG definition, DAG run, logical date, data interval, task, task instance, attempt, executor, worker and metadata database.","Design partition-bound idempotent tasks with bounded retries, timeouts, deadlines and duplicate-safe external effects.","Prevent false-green DAG runs by making required outcomes visible in terminal task and trigger-rule design.","Isolate backfills and expensive training from live service-level capacity using pools, quotas, admission and explicit drain calculations.","Diagnose scheduler, DAG processor, executor, worker, triggerer, metadata database and API health independently.","Build reproducible experiment lineage across code, environment, parameters, dataset, features, metrics, artifacts and evaluation population.","Treat registered model versions as immutable identities and aliases as controlled mutable pointers, not as artifacts.","Define promotion gates using representative data, decision-specific metrics, thresholds, baseline comparisons and approval evidence.","Prevent training-serving skew by sharing feature definitions and proving online/offline freshness, transformations and point-in-time correctness.","Design observable model serving with canary or shadow evidence, reversible routing, fallback, capacity and cost controls.","Operate drift and delayed-label feedback as owned response workflows rather than dashboard-only statistics.","Treat notebooks as arbitrary-code development environments, not production schedulers, and constrain isolation, credentials, trust and reproducibility.","Connect privacy retention, access, audit and lineage across datasets, experiments, models, predictions and notebooks."],"productionSignals":["business outcome SLI and decision ID","DAG ID run ID run type logical date data interval and bundle/code version","task ID task-instance state try number trigger rule timeout deadline queue pool slots and priority","scheduler heartbeat queued/scheduled delay and task adoption","DAG processor heartbeat parse duration import errors bundle version and serialization age","executor queue worker heartbeat task start/end/exit and infrastructure identity","triggerer health deferred task count and trigger failures","metadata database availability latency connections locks storage and replication","backfill date range reprocessing behavior max active runs pool and live-workload impact","source partition/checkpoint input identity and output commit/idempotency key","experiment ID run ID code revision environment dataset digest parameters metrics and artifacts","evaluation dataset population window slices labels baseline thresholds and approval","registered-model name version digest signature dependencies tags and alias history","deployment revision model digest traffic weight request ID prediction version and fallback","online/offline feature definition version event time freshness null/range and skew","serving requests errors duration saturation queue memory CPU/GPU and cost per prediction","input/concept/performance/data-quality drift window threshold owner and action","label arrival coverage delay and feedback reconciliation","notebook user server kernel image code environment data access and execution history","principal authorization decision secret reference encryption audit and retention action"],"diagrams":[{"id":"LES-0064-DIA-001","title":"Decision-to-workflow-to-model path","direction":"left-to-right","boundaries":["business decision","DAG run","task instances","data and feature artifacts","experiment run","registered model version","deployment revision","prediction consumer"],"evidencePoints":["decision ID","run ID and interval","task attempt","artifact digest","experiment run ID","model digest","routing revision","consumer SLI"],"textAlternative":"A business outcome crosses orchestration, data, experiment, registry and serving boundaries; stable identities connect evidence across them."},{"id":"LES-0064-DIA-002","title":"Airflow-shaped control and execution planes","direction":"hierarchical","boundaries":["DAG bundle","DAG processor","metadata database","scheduler and executor","workers","triggerer","API server"],"evidencePoints":["bundle version","parse result","durable state","heartbeat","task attempt","deferred trigger","operator request"],"textAlternative":"The DAG processor parses versioned workflow code; durable state coordinates scheduler, executor, workers, triggerer and API, whose health must be checked independently."},{"id":"LES-0064-DIA-003","title":"Run and retry identity tree","direction":"hierarchical","boundaries":["DAG ID","run ID","data interval","task ID","task instance","try number","external operation","committed output"],"evidencePoints":["logical identity","bounded partition","attempt","idempotency key","output version"],"textAlternative":"Retries create attempts of one logical task instance; all attempts must converge on one partition-bound external effect."},{"id":"LES-0064-DIA-004","title":"Experiment-to-promotion evidence graph","direction":"left-to-right","boundaries":["versioned data and features","code and environment","training run","evaluation population","immutable model artifact","registered version","controlled alias","deployment"],"evidencePoints":["dataset digest","revision and dependencies","run ID","slice metrics","artifact digest","version","approval","deployment revision"],"textAlternative":"Promotion is an evidence-bearing pointer change from an immutable model version, not a copy of whichever file appears newest."},{"id":"LES-0064-DIA-005","title":"Training-serving consistency and feedback loop","direction":"cyclic","boundaries":["event and label time","offline features","training","online features","prediction","outcome label","drift and performance evaluation"],"evidencePoints":["definition version","point-in-time cutoff","freshness","model version","prediction ID","label delay","response owner"],"textAlternative":"The platform must reconcile equivalent feature definitions and delayed outcomes across training and serving while detecting data and concept change."},{"id":"LES-0064-DIA-006","title":"Shared-capacity and recovery envelope","direction":"hierarchical","boundaries":["live schedules","backfills","training jobs","evaluation","notebooks","serving","shared metadata compute and storage"],"evidencePoints":["admission","pool slots","queue age","headroom","drain time","rollback target","unit cost"],"textAlternative":"Live workflows, historical reprocessing, experiments and serving compete for dependencies; explicit isolation, recovery capacity and rollback keep one workload from consuming another's reliability."}],"commands":[{"id":"LES-0064-CMD-001","question":"Is this the supported offline boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0064 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"Airflow, MLflow, Jupyter or model-serving behavior"},{"id":"LES-0064-CMD-002","question":"Can synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state is rejected","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"platform setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0064-CMD-003","question":"Does the baseline cross every boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0064 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0064-CMD-004","question":"Is each task bound to one data interval?","risk":"read-only","command":"bash lab.sh evaluate data-interval-unbound","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=data-interval","meaning":"input/output scope can move between attempts","nextEvidence":"bind partition and event-time interval"}],"proves":"encoded interval gap","doesNotProve":"scheduler semantics"},{"id":"LES-0064-CMD-005","question":"Can a retry duplicate an external effect?","risk":"read-only","command":"bash lab.sh evaluate task-not-idempotent","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=task-idempotency","meaning":"attempts may diverge or duplicate","nextEvidence":"stable key and reconcile-before-retry"}],"proves":"encoded idempotency gap","doesNotProve":"sink transactions"},{"id":"LES-0064-CMD-006","question":"Can a leaf task hide required failure?","risk":"read-only","command":"bash lab.sh evaluate trigger-rule-false-green","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=false-green","meaning":"DAG success does not represent the business contract","nextEvidence":"redesign terminal status and tests"}],"proves":"encoded status gap","doesNotProve":"Airflow run state"},{"id":"LES-0064-CMD-007","question":"Can backfill consume live capacity?","risk":"read-only","command":"bash lab.sh evaluate backfill-live-contention","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=backfill-isolation","meaning":"historical demand can starve current intervals","nextEvidence":"pool quota admission and drain plan"}],"proves":"encoded isolation gap","doesNotProve":"pool enforcement"},{"id":"LES-0064-CMD-008","question":"Can this experiment be reproduced?","risk":"read-only","command":"bash lab.sh evaluate experiment-lineage-incomplete","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=experiment-lineage","meaning":"code data environment or artifact identity is missing","nextEvidence":"complete immutable lineage"}],"proves":"encoded lineage gap","doesNotProve":"MLflow tracking"},{"id":"LES-0064-CMD-009","question":"Is promotion an approved pointer change?","risk":"read-only","command":"bash lab.sh evaluate alias-uncontrolled","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=alias-promotion","meaning":"mutable alias lacks gate and audit","nextEvidence":"restore version and controlled promotion"}],"proves":"encoded promotion gap","doesNotProve":"registry authorization"},{"id":"LES-0064-CMD-010","question":"Are training and serving features equivalent?","risk":"read-only","command":"bash lab.sh evaluate feature-skew","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=training-serving-skew","meaning":"feature definitions or time/freshness semantics differ","nextEvidence":"paired sample reconciliation"}],"proves":"encoded parity gap","doesNotProve":"feature-store correctness"},{"id":"LES-0064-CMD-011","question":"Can serving reverse safely?","risk":"read-only","command":"bash lab.sh evaluate serving-no-rollback","runFrom":"LES-0064 support/lab","expectedBranches":[{"when":"boundary=serving-rollback","meaning":"traffic cannot return to a proven immutable version","nextEvidence":"restore reversible route and fallback"}],"proves":"encoded recovery gap","doesNotProve":"deployment rollback"},{"id":"LES-0064-CMD-012","question":"Do cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0064 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"twenty-two branches and cleanup pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"orchestrator registry notebook training evaluation serving drift load or production behavior","cleanup":"Verifier proves UID-scoped state absence."}],"labs":[{"id":"LES-0064-LAB-001","title":"Guided workflow and ML-platform boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one synthetic fixture"],"abortConditions":["root","credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0064-workflow-ml-platform-reliability/support/lab"},{"id":"LES-0064-LAB-002","title":"Independent workflow-to-serving recovery transfer","mode":"independent","environment":"Reviewer-owned disposable local orchestrator, tracking server, registry, model service and synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns faults","network":"isolated local only","changes":["synthetic workflows, experiment records, models and predictions","disposable backfill, promotion and serving state","approved faults and recovery evidence"],"abortConditions":["shared service","real credential","customer data","host network/clock mutation","unbounded backfill/training/serving","unknown ownership"],"recovery":"Preserve run/model/deployment histories and reset through the reviewer harness.","cleanupProof":"Reviewer proves processes, ports, files, volumes, metadata, artifacts and predictions absent.","path":"drafts/LES-0064-workflow-ml-platform-reliability/support/lab"}],"incidents":[{"id":"LES-0064-INC-001","signal":"A DAG run is green although a required transformation failed.","firstThought":"Terminal leaf state and trigger rules may represent cleanup completion instead of the business outcome.","safePath":"Preserve run/task/attempt graph, identify required outcomes, contain downstream publication, reconcile outputs, then redesign terminal status and tests.","trap":"Trust the green DAG badge."},{"id":"LES-0064-INC-002","signal":"A 60-day backfill makes current daily runs and the metadata database late.","firstThought":"Historical demand is sharing unreserved scheduler, pool, worker, database or downstream capacity with live work.","safePath":"Pause admission, protect live slots and database headroom, calculate backlog and drain rate, then resume bounded waves.","trap":"Add more backfill runs to finish sooner."},{"id":"LES-0064-INC-003","signal":"A model promoted yesterday behaves differently but its offline metric still looks good.","firstThought":"Evaluation population, feature parity, artifact identity, routing or delayed production labels may differ from the offline claim.","safePath":"Bind prediction to immutable model and feature versions, contain traffic, compare online/offline features and slices, roll back routing, then reconcile delayed outcomes.","trap":"Retrain immediately with the latest data."},{"id":"LES-0064-INC-004","signal":"The model alias changed but nobody can reproduce the promoted run.","firstThought":"A mutable alias moved without complete experiment lineage or controlled approval.","safePath":"Freeze alias changes, preserve audit history, restore the last verified immutable version, reconstruct code/data/environment/evaluation evidence, and repair the gate.","trap":"Copy the newest artifact into the registry again."},{"id":"LES-0064-INC-005","signal":"A shared notebook kernel exposes credentials and consumes all GPU capacity.","firstThought":"An arbitrary-code development surface crossed identity, isolation, secret and quota boundaries.","safePath":"Revoke exposed credentials without printing them, isolate and stop the kernel, preserve audit evidence, restore quotas, and move repeatable work into versioned jobs.","trap":"Restart the notebook server and reuse the same token."}],"assessmentIds":["ASM-0175","ASM-0176","ASM-0177"],"referenceIds":["REF-0718","REF-0719","REF-0720","REF-0721","REF-0722","REF-0723","REF-0724","REF-0725","REF-0726","REF-0727","REF-0728","REF-0729","REF-0730","REF-0731","REF-0732"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not Airflow, MLflow, Jupyter, a feature store, training system, model registry, deployment controller, inference server or drift platform.","Synthetic decisions do not prove scheduler, executor, metadata database, worker, registry, model, notebook, serving, security or recovery behavior.","No socket, service, DAG, task, dataset, experiment, model, prediction, notebook, GPU, backfill, training job or external resource exists.","Semantics, defaults, metrics, security controls and compatibility are version-, executor-, plugin-, storage-, model-, framework-, configuration- and topology-dependent.","Formal review, publication, representative runtime, transfer, delayed recall and learner evidence remain required."]}
---

# Workflow and ML-platform reliability: prove every run, model, and serving decision

## What you see and first thought

At 09:10 the workflow page is green. At 09:20 the recommendation service starts returning older choices. The training dashboard still shows yesterday's excellent accuracy. A backfill is running, the scheduler heartbeat is present, and the alias named `champion` now points to a different model version.

Do not begin with "restart everything" or "train another model." There are several truths here:

1. the workflow engine's truth about scheduled work;
2. the data platform's truth about inputs and committed outputs;
3. the experiment system's truth about how an artifact was produced;
4. the registry's truth about immutable versions and mutable aliases;
5. the deployment system's truth about what actually receives traffic;
6. the consumer's truth about latency, errors and decision quality.

One green surface cannot prove the others. Your first job is to bind them with stable identities:

```text
business decision / prediction ID
  -> deployment revision + immutable model digest
  -> registry model version + alias-change audit event
  -> experiment run + evaluation population
  -> code + environment + training dataset/feature versions
  -> DAG run ID + data interval
  -> task instance + try number + committed output
```

Remember this:

> Orchestration says what work was attempted. Tracking says what was recorded. Registry says what identity was named. Serving says what handled traffic. Only end-to-end evidence says whether the user received the intended result.

During an incident, ask: Which outcome is wrong? Which exact run produced it? Which task attempt committed the output? Which immutable model received the request? Which feature values did it see? Which label or business outcome later judged it? Preserve those answers before clearing tasks, moving aliases, or restarting components.

## Terms before commands

### Workflow, DAG, task, run, and task instance

A **workflow** is a repeatable coordination definition. A **DAG** is a directed acyclic graph: tasks are vertices, dependencies are directed edges, and no dependency chain loops back to itself. A DAG describes ordering and conditions; it is not one execution.

A **DAG run** is one execution of that definition. It needs stable identity such as DAG ID plus run ID, and it normally represents a bounded **data interval**. The logical date identifies the interval according to the scheduler's semantics; it is not necessarily the wall-clock time when the process started.

A **task** is the reusable definition. A **task instance** is that task in one DAG run. A retry does not create a new business operation; it creates another **attempt** or try of the same logical task instance. That difference is crucial. If each attempt inserts the same payment, sends the same message, or overwrites "latest," the workflow engine can faithfully retry and still damage the business.

### Schedule, data interval, event time, and wall-clock time

A schedule answers when a run becomes eligible. A data interval answers which logical slice of data it owns. **Event time** is when an event happened in the source domain. **Processing time** is when the platform handled it. **Wall-clock time** is the current clock observed by a process.

For a daily interval, use explicit boundaries such as `[2026-08-04T00:00Z, 2026-08-05T00:00Z)`. The start is included and the end excluded. Adjacent intervals touch without overlap. A retry tomorrow must still read that interval, not "the last 24 hours" and not "whatever is latest now."

### Idempotency, retry, timeout, and deadline

An operation is **idempotent** when repeating the same logical request converges on the same intended effect. It does not mean the code runs once. Use a stable key derived from workflow/run/task/output identity, then make the destination reject, upsert, compare-and-swap, or reconcile duplicates.

A **retry** is another attempt after a classified failure. A **timeout** limits one operation or task. A **deadline** limits the entire logical request. If five attempts may each consume the whole ten-minute deadline, the retry policy is mathematically false. Budget connection, execution, retry delay and cleanup inside one end-to-end deadline.

### Trigger rule, leaf task, false green, and required outcome

A **trigger rule** decides whether a task may run from upstream states. Cleanup often needs to run even after failure. That is useful, but a final cleanup leaf that succeeds under an "all done" rule can make a DAG appear successful even when an upstream business-critical task failed, depending on run-state semantics.

A **false green** is a control-plane success that does not represent the required business outcome. Define which terminal tasks certify publication, quality and reconciliation. Cleanup completion and business completion are separate facts.

### Scheduler, DAG processor, executor, worker, triggerer, API, and metadata database

In an Airflow-shaped architecture, the **DAG processor** reads and executes top-level DAG-definition code to build serialized definitions. The **scheduler** decides which task instances are ready. The **executor** is the scheduler's mechanism for submitting work. **Workers** execute tasks. The optional **triggerer** efficiently waits for asynchronous conditions used by deferred tasks. The **API server** serves operators and the UI. The **metadata database** durably coordinates definitions, runs, task states, variables and operational history.

"Airflow is healthy" is too vague. The API can answer while the scheduler heartbeat is stale. The scheduler can be alive while DAG parsing fails. Workers can be healthy while the metadata database is saturated. Deferred tasks can stall while ordinary tasks run. Check each boundary independently.

### Pool, slot, queue, concurrency, backfill, and drain time

A **pool** is an admission boundary that limits selected tasks against scarce capacity. A task can consume one or more pool slots. **Concurrency** limits how many runs or tasks execute at once. **Queue age** measures waiting, not execution. A **backfill** creates runs for historical intervals; it can multiply demand quickly.

Backlog drain time is approximately:

```text
drain_seconds = backlog_work_seconds / sustainable_spare_parallelism
```

Use sustainable spare capacity after protecting live work, not the fleet's theoretical maximum. If a downstream database safely supports 20 concurrent writers and live work needs 14 at peak, a backfill does not own 20. It may own at most the reviewed remainder, usually with additional headroom.

### Experiment, run, parameter, metric, artifact, and lineage

An ML **experiment** groups related trials. An experiment **run** records one training or evaluation execution. **Parameters** are inputs such as learning rate. **Metrics** are measured values tied to a population and method. **Artifacts** are files such as models, plots or reports.

**Lineage** connects code revision, environment/dependencies, data and feature versions, parameters, random seeds, run identity, metrics, artifacts and approvals. A run ID without versioned training data is an incomplete recipe. A model file without a digest, signature and dependency contract is an ambiguous executable.

### Registered model, version, alias, tag, stage, and deployment

A **registered model** is a named collection. A **model version** is an immutable identity for one model artifact and its metadata. A **tag** annotates an object. An **alias** is a mutable name that can be reassigned to a version, such as `champion`. It is a pointer, not the artifact.

Legacy lifecycle stages are version-dependent and have been deprecated in current MLflow workflows; do not design a new operating model around assumed stage behavior. Prefer immutable versions plus explicit aliases, tags, approvals and deployment records after checking the installed version.

A **deployment revision** is the exact serving configuration: model digest, runtime image, feature contract, resources, route weights and policy. Moving an alias does not prove that a deployment reconciled, that old processes stopped, or that all requests use the new model.

### Evaluation, baseline, threshold, slice, and delayed label

Evaluation asks whether a candidate is fit for one decision. A headline average is not enough. Bind the dataset version, time window, inclusion rules, label definition, slice dimensions and preprocessing. Compare against a baseline and absolute thresholds. Include operational constraints such as latency, memory, calibration, fairness or false-negative cost where relevant.

A **delayed label** arrives after prediction: fraud confirmation, churn, failure or repayment may take days or months. Until labels mature, you can observe inputs and system health, but you cannot claim current outcome quality. Track label coverage and delay explicitly.

### Feature parity, point-in-time correctness, and drift

**Training-serving skew** means training and serving compute or retrieve different feature meanings. Causes include different code, timezone/window definitions, missing-value handling, category mappings, freshness or data sources.

**Point-in-time correctness** means a training row uses only facts available at that historical decision time. Without it, future information leaks into training and offline evaluation looks unrealistically good.

**Data-quality drift** changes validity, nulls or schema. **Input drift** changes feature distributions. **Concept drift** changes the relationship between inputs and outcomes. **Performance drift** changes outcome metrics. Distribution change is evidence to investigate, not automatic proof that a model is bad.

### Notebook, server, kernel, trust, and reproducibility

A notebook server exposes documents and launches **kernels** that execute arbitrary code with the kernel process's authority. Notebook "trust" concerns whether stored output such as HTML/JavaScript is considered safe to render; it is not authentication and does not make executed code safe.

A notebook is excellent for exploration and poor as an invisible production scheduler. Hidden cell state, execution order, mutable environments and manual actions weaken reproducibility. Production work should become versioned code, declared dependencies, parameterized jobs, tests and controlled orchestration.

## Architecture map

### The end-to-end path

```text
schedule or event
    |
    v
DAG definition --parsed/serialized--> metadata database
    |                                  ^
    v                                  |
scheduler/executor --> worker attempt -+--> committed data/features
                                             |
                                             v
code + environment + dataset --> experiment run --> model artifact
                                                    |
                                                    v
                                           registered version
                                                    |
                                         reviewed alias/promotion
                                                    |
                                                    v
feature request --> deployment revision --> prediction --> outcome/label
        ^                    |                             |
        +------- parity -----+---------- feedback --------+
```

There are three planes:

- The **control plane** stores desired workflow, run, promotion and routing decisions.
- The **execution plane** runs tasks, training, evaluation and inference.
- The **evidence plane** retains logs, metrics, traces, lineage, artifacts, audits and consumer outcomes.

Do not let the execution plane invent authority. A worker process does not decide which interval it owns. A model server does not decide which version is approved. A notebook does not become a production pipeline because it ran successfully once.

### Airflow-shaped component boundaries

```text
versioned DAG bundle
        |
        v
  DAG processor ----serialized DAG----+
                                      |
operator --> API server --> metadata database <-- scheduler/executor
                         ^                 |             |
                         |                 |             v
                    audit/state        triggerer      workers
                                                       |
                                                       v
                                              external systems
```

The metadata database is coordinating state, not a bulk-data bus. Large payloads belong in durable object/table storage; pass stable references and compact metadata between tasks. Workers may run on different machines and attempts may move, so local files are not a reliable handoff unless one explicit executor topology guarantees it and you accept that coupling.

### ML evidence and serving boundaries

```text
dataset digest + feature definition + code revision + environment
                              |
                              v
                       experiment run
                    metrics + artifacts
                              |
                     representative evaluation
                              |
                              v
               immutable registered model version
                              |
                 approval + mutable alias history
                              |
                              v
 deployment revision = model digest + runtime + feature contract + route
                              |
                    prediction ID / outcome
```

An alias is convenient for human intent. A digest is stronger for forensic identity. Store both: "route used champion" explains policy, while "artifact sha256 X" explains what bytes executed.

## Request or state path

### One scheduled interval

Suppose a daily fraud-feature workflow owns `[00:00, 24:00) UTC`.

1. The scheduler creates one run with a stable run ID and that interval.
2. The scheduler evaluates dependencies and admission limits.
3. The executor submits task instance `extract`, try 1.
4. The worker reads source records using the explicit interval and source snapshot/checkpoint.
5. It writes a candidate output identified by DAG, interval, task and transformation version.
6. It validates quality and atomically publishes or upserts the one logical partition.
7. If acknowledgement is lost, try 2 first reconciles the destination by idempotency key.
8. Downstream tasks read the committed output identity, not `latest`.
9. A terminal validation task certifies required outputs; cleanup reports separately.

The interval is logical ownership. The try number is operational history. Never make output identity depend on try number unless attempts are intentionally separate candidates that one later commit selects.

### One model promotion

1. Training consumes versioned dataset and feature definitions.
2. The run records code revision, dependency lock, parameters, seeds, input digests and artifacts.
3. Evaluation uses a named, representative population and records slice metrics, baseline and thresholds.
4. A registered model version points to an immutable artifact with a digest and input/output signature.
5. Approval changes a controlled alias or promotion record with principal, reason and evidence.
6. Deployment reconciles to a revision pinned to that immutable version.
7. A bounded canary or shadow comparison collects service and decision signals.
8. Traffic expands only while gates hold. A rollback switches routing to a previously verified revision; it does not reconstruct an old model from memory.
9. Predictions record model/deployment/feature identity so delayed outcomes can be joined later.

### One notebook-to-production transition

Exploration begins in a per-user isolated kernel with least-privilege data access. When the work matters, extract functions into version control, declare dependencies, turn interactive values into parameters, create deterministic tests, package an artifact, run through the orchestrator, and track it. The notebook may remain a narrative and diagnostic client; it is no longer the authority for production execution.

## Failure zoom

### Green DAG, missing output

The transform task failed. A cleanup task used a permissive trigger rule and became the only leaf. Cleanup succeeded, so the run's aggregate terminal state looked successful. Monitoring alerted on failed tasks but auto-closed when the run became green. Publication proceeded with an old partition.

Containment: stop downstream publication, preserve the run/task graph, and identify the required outcome. Recovery: rerun only after verifying idempotency and interval binding, reconcile the output, then make a dedicated final validation task fail unless every required artifact and quality gate is present. Test upstream fail, skip and retry branches in CI.

### Retry after unknown acknowledgement

A worker writes a feature partition and times out before receiving the destination acknowledgement. Blind retry appends duplicates. The engine did what its retry policy requested; the task contract was unsafe.

Use a deterministic operation key. On retry, query the destination by that key. If the committed result matches the intended digest, declare success. If no result exists, write. If a different result exists, stop for conflict resolution. "Exactly once" is not a setting you inherit across arbitrary boundaries.

### Backfill crushes live work

Sixty historical runs each launch twenty tasks. Scheduler loops grow, metadata connections saturate, workers fill, and the warehouse throttles. Current runs miss their objective.

Pause backfill admission first. Reserve live capacity at every shared bottleneck, not only workers. Estimate remaining work, safe spare parallelism and drain time. Resume in observable waves. More workers can worsen a database bottleneck by increasing connections and writes.

### Model is correct offline and wrong online

Offline training used a seven-day UTC window and filled missing categories with `unknown`. Serving used local time, a rolling 168-hour window and an empty string. The model artifact is byte-for-byte correct; its inputs mean something else.

Capture prediction ID, model digest, feature-definition version, raw event cutoff and computed online vector. Recompute the same examples offline as of the decision time. Roll back or degrade if risk exceeds policy, then unify definitions and add paired parity tests.

### Alias moved without reproducible evidence

An authorized user moved `champion` to version 42. Version 42's artifact exists, but its dataset was "latest," its environment was not locked, and the evaluation notebook had hidden state.

Freeze further promotion, preserve audit logs, and route back to the last verified immutable version. The issue is not merely missing documentation: the evidence required to defend the decision never existed. Rebuild a candidate through the controlled workflow instead of retroactively declaring version 42 reproducible.

## Internals and state ownership

### Parsing is execution

Python DAG files are executable code. Top-level imports, database calls, network requests and dynamic generation run during parsing, potentially many times. That creates load, nondeterminism and security exposure before any task starts.

Keep top-level work deterministic and cheap. Generate stable task IDs and ordering. Pin the DAG bundle or code revision so parser and worker agree. Test import time and serialized graph shape. If parsing depends on a live service, an outage can remove or mutate workflow definitions precisely when operators need them.

### Durable orchestration state

The metadata database records coordination state. Its transaction latency, connection ceiling, storage, indexes, vacuum/maintenance and replication behavior influence scheduling. A heartbeat says a process recently wrote a signal; it does not prove progress. Measure schedule delay, parse age, queued age, state transitions and task start rate.

State repair must respect ownership. Do not edit database rows to "unstick" tasks. Use supported clear, retry, fail, mark, backfill and reconciliation operations with exact run/task scope and audit. Preserve the prior state and understand downstream effects.

### Retry state machine

Model a task instance as a state machine:

```text
none -> scheduled -> queued -> running -> success
                           |       |
                           |       +-> failed -> up_for_retry -> scheduled
                           +-> infrastructure rejection
running -> deferred -> scheduled
```

Actual states and transitions vary by version and executor. The invariant is more important: one logical task instance can have several attempts, and the external effect must be reconcilable across worker loss, timeout and duplicate delivery.

### Registry and deployment state

Separate:

- experiment run identity: how a candidate was produced;
- artifact digest: exact bytes and packaged dependencies;
- registered version: durable immutable catalog identity;
- alias: mutable policy pointer;
- deployment revision: exact runtime and route;
- prediction record: what handled one request.

If your dashboard shows only alias, forensic identity disappears after the alias moves. If it shows only digest, human intent and approval disappear. Record both.

### Feature and label state

Features have definition version, source identities, event-time cutoff, materialization time and freshness. A feature store can reduce duplication but does not automatically establish point-in-time correctness. Labels have definition, source, arrival time, corrections and coverage. Backfilled labels can change previous performance reports; record evaluation versions rather than rewriting history silently.

### Notebook authority

Kernel code runs as an operating-system and platform identity. Limit network, filesystem, data, secret, CPU, memory and accelerator access. Use short-lived workload credentials, never embed secrets in notebooks, and treat outputs as potentially sensitive. Shut down idle kernels. Audit access without logging secret values or raw sensitive features.

## Evidence table

| Question | Start with | It proves | It does not prove | Dangerous shortcut |
|---|---|---|---|---|
| Did the intended interval run? | DAG ID, run ID, run type, logical date, data interval, code bundle | One run identity and owned time slice | Correct inputs or outputs | Search logs only by today's wall clock |
| Did the required work succeed? | Complete task-instance graph, attempts, terminal rules, committed output IDs | Recorded control flow and selected effects | Business correctness by green color alone | Inspect only leaf tasks |
| Is the scheduler progressing? | Heartbeat plus scheduling delay, state-transition rate, queue age | Liveness and work movement | Worker, parser or database health | Treat one health endpoint as platform health |
| Are definitions current? | Bundle revision, parse timestamp, import error, serialized graph hash | Parser view of workflow code | Worker executes identical dependencies | Restart the scheduler |
| Is retry safe? | Logical operation ID, attempt IDs, sink idempotency/commit evidence | Duplicate handling for one operation | Every downstream side effect is safe | Increase retry count |
| Will backfill hurt live runs? | Demand per interval, bottleneck capacity, reserved live headroom, queue/drain estimate | Capacity envelope assumptions | Unknown downstream throttles | Set high parallelism and watch |
| Can the experiment be reproduced? | Code, lock/image digest, dataset/feature versions, parameters, seed, run/artifact digest | Recorded recipe and identity | Determinism on unsupported hardware or libraries | Trust the run name |
| Did evaluation support promotion? | Population, labels, slices, baseline, thresholds, uncertainty, approval | Decision-specific gate evidence | Future production quality | Quote one average metric |
| Which model served this request? | Prediction/request ID, deployment revision, artifact digest, feature version | Exact sampled serving identity | Correctness of the prediction | Look only at alias now |
| Is feature parity intact? | Raw events and paired offline/online vectors as of one decision time | Sampled transformation/freshness equivalence | All populations and future windows | Compare current rows |
| Is drift actionable? | Drift type, window, threshold, affected slice, label maturity, owner/runbook | Detection context and ownership | Causal degradation | Retrain on every alert |
| Is notebook use safe? | User/server/kernel identity, image, privileges, data/secret access, quotas, audit | Current execution envelope | Reproducibility or code safety | Share one admin token |

Use evidence with timestamps and identities, not screenshots without context. Preserve timezone, query window, filters, deployment revision and tool version. Redact values; do not remove the identifiers needed to join evidence.

### Minimum incident packet

For a workflow-to-model incident, capture:

```text
impact window and affected decision
DAG/run/interval/bundle identities
task graph, attempt states and output commits
scheduler/parser/executor/worker/triggerer/database signals
experiment/run/data/feature/code/environment identities
evaluation population, slices, thresholds and approval
model version, digest, alias audit and deployment revision
prediction/feature/label samples under privacy policy
changes, owners, containment, rollback target and validation
```

This is a correlation packet, not a command dump. Each line should answer a question.

## Command decoders

The local lesson lab is the only directly runnable command surface in this candidate. Product commands below are interpretation patterns. Airflow and MLflow CLIs and APIs change; confirm exact syntax against the installed version and use an approved read-only identity.

### `bash lab.sh doctor`

This checks the exercise boundary: Ubuntu 24.04, non-root user, Python 3, and absence of named cloud/orchestrator/registry credentials. It does not inspect your production environment. A refusal is a safety result, not a reason to delete the check.

### `bash lab.sh setup` and `status`

Setup creates only a UID-scoped directory beneath `/tmp`, a sentinel and a copied JSON fixture. Status validates owner, type, allow-listed children and fixture schema before reporting 22 cases. If the path already exists, stop and inspect it. Never replace an unknown path just to make a lab run.

### `bash lab.sh show baseline`

`show` prints the input fields. It helps you separate facts from the evaluator's decision. In production, use the same habit: capture raw run, task, model, deployment and feature evidence before interpreting it.

### `bash lab.sh evaluate trigger-rule-false-green`

Expected:

```text
case=trigger-rule-false-green decision=not-operable boundary=false-green
```

The model stops at the first unsafe boundary in a fixed order. It does not simulate an Airflow state calculation. The lesson is the investigation order: do not discuss model quality while the workflow's success signal is untrustworthy.

### `bash lab.sh evaluate experiment-lineage-incomplete`

The result means at least one required lineage category is missing in the synthetic case. In a real platform, list exactly which one: code revision, environment, data version, feature definition, parameters, seed, artifact digest or evaluation link. "MLflow run exists" is not a complete answer.

### `bash lab.sh evaluate feature-skew`

The case does not calculate statistics. It marks a contract failure. Real evidence needs paired records computed from the same raw events at the same historical cutoff with both implementations and explicit tolerances.

### `bash verify.sh`

The verifier checks all 22 branches, injects an unexpected file, proves the guard refuses it, removes that exact file, and proves the temporary root is absent. Passing establishes deterministic model behavior and cleanup only.

### Decode product health

For an approved Airflow deployment, inspect the documented health endpoint and component-specific checks, then pair them with progress signals. Decode a scheduler heartbeat like this:

- recent heartbeat: process can update metadata;
- growing scheduling delay: process is not keeping up;
- stable queued count with no starts: executor, worker, pool or downstream admission may block;
- stale serialized DAG with parser errors: scheduler may be healthy but scheduling the wrong or no graph;
- metadata database latency: every component may appear slow together.

Never publish credentials, connection values, configuration dumps or raw task environment variables.

### Decode task states

Filter by exact DAG ID, run ID and task ID. Include try number and map index where applicable. A task marked failed tells you recorded terminal state, not whether an external write partly committed. A task marked success tells you the operator returned successfully, not that a downstream consumer reconciled the result.

### Decode a backfill request

Before creating runs, calculate:

```text
historical_intervals = end_exclusive - start, divided by schedule width
tasks = intervals * average runnable tasks per interval
work_seconds = sum(expected task duration at bottleneck)
safe_spare_parallelism = bottleneck safe capacity - protected live demand - headroom
drain_time = work_seconds / safe_spare_parallelism
```

If safe spare parallelism is zero or negative, "run slowly" is still unsafe; add capacity, reschedule, reduce scope, or accept a service-level trade-off explicitly.

### Decode experiment search

Search by immutable attributes: code revision, dataset digest, feature-definition version, owner, run time and model artifact digest. Run display names are labels. Parameters and metrics must retain units and evaluation context. A metric called `accuracy=0.94` without population, label, averaging and threshold is not operational evidence.

### Decode model registry state

Read the registered version, artifact source/digest, tags, alias assignments and audit history. Resolve the alias at the incident time, not only now. A version can be registered but never deployed; an alias can move while an old deployment continues serving.

### Decode serving telemetry

Split service health from decision quality:

- service: request rate, errors, latency, saturation, queue, CPU/memory/GPU, dependency failures;
- model: prediction distribution, confidence/calibration where appropriate, feature validity/freshness, drift;
- outcome: labels, coverage, delay, slice performance and business cost.

A fast wrong answer is available but unreliable. A statistically strong model behind an overloaded service is useful offline but unavailable online.

## Decision path

### When a scheduled outcome is missing or late

1. Define the consumer deadline and exact missing interval.
2. Find the DAG run by stable identity.
3. Verify the loaded DAG bundle and parse state.
4. Inspect every required task instance and attempt, not only leaves.
5. Separate queued, running, deferred and externally committed state.
6. Check pools, concurrency, scheduler/executor/worker/triggerer and metadata database.
7. Inspect the downstream bottleneck and output idempotency key.
8. Contain duplicate publication and protect live intervals.
9. Retry, clear or backfill only the exact safe scope.
10. Reconcile output and consumer state independently.

### When a model outcome degrades

1. Define affected decision, population, window and cost.
2. Bind sampled requests to deployment revision and immutable model digest.
3. Check serving errors, latency, saturation and dependencies.
4. Validate feature schema, freshness, ranges and training-serving parity.
5. Confirm alias/promotion/deployment history.
6. Reproduce the candidate's dataset, code, environment and evaluation.
7. Separate input drift, data-quality failure, concept drift and delayed-label uncertainty.
8. Contain with traffic reduction, fallback or rollback according to policy.
9. Prove recovery with service and decision signals.
10. Repair the broken contract before retraining or promoting again.

### When to retry, rerun, backfill, roll back, or retrain

| Action | Use when | Required evidence |
|---|---|---|
| Retry task | failure is transient, attempt budget remains, effect is idempotent/reconcilable | logical key, deadline, current destination state |
| Clear/rerun exact task | operator state is wrong or repaired dependency requires controlled replay | dependency graph, downstream effects, interval |
| Backfill | historical intervals never ran or need corrected transformation | versioned code/data, isolation, drain and validation plan |
| Roll back serving | current revision creates unacceptable service or decision risk | previous immutable revision, compatible feature contract, routing proof |
| Retrain | data/concept change or corrected objective justifies a new candidate | owned hypothesis, mature labels, reproducible inputs, evaluation gates |

Restart is an infrastructure action, not a data or model correctness strategy.

## Guided Ubuntu lab

### Purpose and limits

This exercise teaches boundary order without installing heavyweight products. It makes no network connection and creates no DAG, model or service. Run it only in Ubuntu 24.04 as a normal user from:

```text
drafts/LES-0064-workflow-ml-platform-reliability/support/lab
```

### Step 1: inspect before execution

```bash
pwd
sed -n '1,240p' README.md
sed -n '1,260p' lab.sh
sed -n '1,280p' model.py
```

Confirm the absolute path is the intended repository, the state root contains your numeric UID, cleanup removes only two allow-listed files, and no network/tool invocation exists.

### Step 2: prove the guard

```bash
bash lab.sh doctor
```

Expected:

```text
doctor=pass runtime=offline-workflow-ml-platform-model
```

If it says `root`, leave the root shell. If it reports a credential, use a clean training shell; do not print the credential. If Ubuntu/version checks fail, do not edit the script to pretend support.

### Step 3: initialize and inspect

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
```

Expected status includes `cases=22 network=none`. The baseline contains every safe contract and evaluates to:

```bash
bash lab.sh evaluate baseline
```

```text
case=baseline decision=operable boundary=operable
```

"Operable" means the booleans and numeric relationships in this tiny model pass. It is not a certification.

### Step 4: walk the workflow failures

```bash
bash lab.sh evaluate unstable-run-identity
bash lab.sh evaluate data-interval-unbound
bash lab.sh evaluate task-not-idempotent
bash lab.sh evaluate retry-unbounded
bash lab.sh evaluate timeout-missing
bash lab.sh evaluate trigger-rule-false-green
bash lab.sh evaluate backfill-live-contention
bash lab.sh evaluate pool-not-enforced
bash lab.sh evaluate scheduler-health-dependent
bash lab.sh evaluate dag-parse-nondeterministic
```

Say each result aloud as cause and next evidence. Example: "This stops at data interval because attempts are not bound to one immutable input/output slice. I would capture run interval and source/output identity before retry."

### Step 5: walk the ML-platform failures

```bash
bash lab.sh evaluate training-data-unversioned
bash lab.sh evaluate experiment-lineage-incomplete
bash lab.sh evaluate evaluation-population-mismatch
bash lab.sh evaluate threshold-missing
bash lab.sh evaluate model-artifact-unpinned
bash lab.sh evaluate alias-uncontrolled
bash lab.sh evaluate feature-skew
bash lab.sh evaluate drift-unowned
bash lab.sh evaluate serving-no-rollback
bash lab.sh evaluate notebook-shared-unsafe
bash lab.sh evaluate privacy-retention-unbounded
```

For each, name containment before remediation. For alias failure: freeze movement and bind current traffic to a digest before deciding which alias should point where.

### Step 6: verify fail-closed behavior and cleanup

If you have not modified state:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=22 refusal=true cleanup=true
```

Then prove absence:

```bash
test ! -e "/tmp/reliability-atlas-les0064-workflow-ml-platform-$(id -u)"
```

No output and exit status zero mean the path is absent. Do not run manual recursive deletion.

### Retrieval exercise

Without looking, write:

1. why run ID, data interval and try number are different;
2. why a green DAG can be wrong;
3. why an alias is not a model artifact;
4. the fields required to reproduce a training run;
5. how you would prove feature parity;
6. why a notebook kernel is a security boundary.

Check against the complete answers later. Repeat after one day and one week.

## Production transfer

The independent lab must use a reviewer-owned disposable local environment. The learner should not receive production access or real data. A suitable packet includes a local orchestrator, local tracking/registry service, tiny synthetic dataset, deterministic model, versioned feature function, local inference endpoint and injected faults.

### Required transfer sequence

1. Draw control, execution and evidence planes.
2. Define user and model-quality SLIs.
3. Run one interval and bind all identities.
4. Inject a task failure after a candidate output write; reconcile and retry safely.
5. Inject a permissive terminal trigger and detect false green.
6. Calculate a bounded backfill and prove live-capacity protection.
7. Reproduce a model from code/data/environment records.
8. Reject a candidate with a mismatched evaluation population.
9. Promote an immutable version through an audited alias.
10. Inject training-serving skew and prove it with paired samples.
11. Route a bounded canary, detect degradation and roll back.
12. Reconcile delayed labels, explain drift type and trigger the owned response.
13. Prove notebook isolation and secret handling.
14. Tear down and prove processes, ports, files, volumes, metadata and artifacts absent.

### Evidence is stronger than screenshots

The reviewer should require machine-readable IDs, timestamps, digests, state transitions, calculations and cleanup results. A screenshot can support a narrative but cannot be searched, diffed or reliably joined. Remove credentials and sensitive raw values while preserving safe correlation IDs.

### Changed-constraint transfer

After recovery, the reviewer changes one major constraint: labels arrive after 45 days, GPU capacity halves, the metadata database connection ceiling drops, the feature window moves from UTC to local business time, an alias API changes, or privacy retention becomes 30 days. The learner must revise architecture, capacity, promotion, observability and recovery rather than repeating memorized commands.

## Reliability, security, observability, capacity, and cost

### Reliability objectives

Define separate objectives:

- **schedule-to-start latency**: eligible run to first required task start;
- **data freshness**: end of interval to validated output availability;
- **workflow correctness**: required intervals with complete reconciled outputs;
- **promotion correctness**: deployments backed by approved immutable versions;
- **serving availability/latency**: successful predictions within a deadline;
- **decision quality**: mature-label metric by critical slice;
- **recovery**: time to contain and restore known-good workflow or model state.

An availability SLO cannot substitute for a quality SLO. Decision quality may have delayed measurement, so use leading signals without pretending they are labels.

### Observability design

Use low-cardinality aggregate metrics and high-cardinality logs/traces safely. DAG ID, task class and state may be metric dimensions; arbitrary run IDs, request IDs and user IDs usually belong in logs or traces. Correlate:

```text
trace/request/prediction ID
  -> deployment/model/feature versions
  -> experiment/evaluation
  -> workflow run/task/output lineage
```

Alert on user impact, objective burn and actionable platform symptoms. Page for stalled current schedules, rapid error-budget burn, serving unavailability or unsafe promotion. Ticket capacity trends, parse debt, idle notebooks and slow label coverage unless urgency is justified.

### Security and privacy

Separate roles: deployment manager, DAG author, operator, data owner, model developer, approver and serving identity. DAG and notebook code can execute, so review and isolate it. Workers need only the connections required by their tasks. Model servers need inference-time dependencies, not training credentials. Promotion principals should not silently rewrite artifacts.

Use secret references and short-lived workload identity. Encrypt transport and storage, restrict artifact and dataset access, sign or attest artifacts where the threat model justifies it, and retain audit events for definition changes, manual task actions, alias moves, deployments, notebook access and privacy deletion.

Privacy spans copies: raw data, feature materializations, experiment samples, model artifacts that may memorize data, predictions, labels, notebook outputs, logs and backups. A 30-day raw-data rule is incomplete if notebooks and artifacts retain the same records forever.

### Capacity mathematics

For a scheduled task class:

```text
offered_work_seconds_per_second =
  arrivals_per_second * mean_service_seconds * slots_per_task

utilization = offered_work / effective_slot_capacity
```

Keep utilization below the point where queue age becomes unstable. Tail duration and synchronized schedules matter more than averages.

Backfill example: 1,800 task-hours remain. The reviewed bottleneck has 40 slots, live work uses 24 at peak, and 25% headroom is reserved from total capacity (10 slots). Safe backfill slots are `40 - 24 - 10 = 6`. Ideal drain time is `1,800 / 6 = 300 hours` before efficiency loss and downstream limits. A promise of "overnight" is not a plan.

Serving example:

```text
required_instances =
  peak_requests_per_second
  / (safe_requests_per_second_per_instance * target_utilization)

recovery_instances =
  peak_requests_per_second
  / remaining_instance_capacity_after_failure
```

Round up, test cold-start and model-load time, include feature-service limits, and reserve rollback capacity. GPUs do not improve a CPU-bound feature lookup.

### Cost as a reliability signal

Track cost per successful interval, training run, evaluated candidate, registered model and thousand predictions. Split compute, accelerator idle time, storage, artifacts, logs, metadata database, network transfer and failed/retried work.

Cheaper is not automatically better. Removing retention may destroy rollback. Using spot/preemptible training may be sensible when checkpoints and deadlines tolerate interruption. Scaling workers without fixing small tasks or database contention increases both cost and instability.

## Traps and prevention

### Trap 1: green means correct

**Why it fails:** DAG state summarizes task-state rules. It cannot inspect arbitrary external effects or business meaning.

**Prevention:** define required terminal outcomes; validate committed output identity, quality and consumer reconciliation; test failure/skip/cleanup branches.

### Trap 2: retry is recovery

**Why it fails:** retries can amplify overload, duplicate effects and exceed the user's deadline.

**Prevention:** classify errors; use a stable idempotency key; reconcile unknown outcomes; bound attempts, delay and total deadline; stop on deterministic or authorization failures.

### Trap 3: `latest` is a data contract

**Why it fails:** inputs move between attempts and backfills silently read different data.

**Prevention:** bind source snapshot/checkpoint and half-open interval; publish immutable outputs or atomic partition versions.

### Trap 4: more concurrency makes backfill finish faster

**Why it fails:** the bottleneck may be metadata connections, downstream writes, network, memory or API quota.

**Prevention:** identify the actual bottleneck, reserve live headroom, limit pools at the scarce resource, use waves and measure drain.

### Trap 5: scheduler heartbeat proves orchestration health

**Why it fails:** parsing, executor submission, workers, triggerer or database may be stalled.

**Prevention:** pair component liveness with progress metrics and one synthetic end-to-end canary.

### Trap 6: run ID proves reproducibility

**Why it fails:** tracking may omit code, environment, data or feature identities; sources may be mutable.

**Prevention:** require complete lineage and immutable digests before registration or promotion.

### Trap 7: one metric chooses the model

**Why it fails:** averages hide slices, business costs, calibration, latency, fairness and dataset mismatch.

**Prevention:** version the population, define absolute and relative thresholds, examine critical slices and operational limits, record approval.

### Trap 8: alias equals artifact

**Why it fails:** aliases move. Historical requests cannot be reconstructed from the current pointer.

**Prevention:** deploy and log immutable version/digest plus alias intent and audit history.

### Trap 9: distribution change means retrain

**Why it fails:** drift may be benign seasonality, instrumentation failure or an upstream schema bug. Immediate retraining can learn corrupted data.

**Prevention:** classify drift, verify data quality and label maturity, quantify decision impact, route to an owner and execute a reviewed response.

### Trap 10: notebook is just a document

**Why it fails:** its kernel executes arbitrary code, holds credentials and can consume shared capacity.

**Prevention:** per-user isolation, least privilege, quotas, short-lived identity, trusted-image policy, idle culling, output review and productionization workflow.

### Trap 11: rollback means move the alias

**Why it fails:** deployment may have copied a model, changed runtime or feature contract, or not reconciled the alias.

**Prevention:** maintain immutable deployment revisions, explicit routing state, compatibility tests, preserved prior capacity and post-rollback verification.

### Trap 12: privacy deletion ends at the source

**Why it fails:** features, experiments, artifacts, notebooks, predictions, logs and backups hold derived or copied data.

**Prevention:** keep a copy map, purpose and retention per class; implement auditable deletion or documented legal retention; test the full lifecycle.

## Memory card and retrieval

### The six-line card

```text
RUN: DAG + run + interval + bundle
ATTEMPT: task instance + try + idempotency key + committed output
MODEL: experiment + data/features + code/env + artifact digest
PROMOTE: population + slices + thresholds + approval + alias audit
SERVE: deployment revision + model/feature identity + request/outcome
RECOVER: contain -> reconcile -> reverse -> validate -> prevent
```

### The sentence to remember

> Schedule a bounded interval, make attempts converge, promote immutable evidence, serve a reversible revision, and join every prediction to its eventual outcome.

### Rapid retrieval

Cover the page and answer in 60 seconds:

1. What is the difference between logical date and execution start?
2. Why can a task succeed after an external operation actually failed?
3. What makes a backfill capacity-safe?
4. What seven identities make a model run reproducible?
5. What changes when an alias moves?
6. How do you distinguish feature skew from concept drift?
7. What does a notebook trust flag not prove?
8. Which evidence makes rollback real?

If an answer contains only a product name or command, it is incomplete. State the invariant, evidence and next safe action.

## Complete answers

### 1. Logical date versus execution start

The logical date identifies the run's scheduling/data-interval semantics. Execution start is when infrastructure actually began the run or task. A daily run may logically own Monday's data and begin Tuesday after the interval closes; it may begin Wednesday after an outage. If code filters with execution-start time, delayed runs and retries read the wrong slice. Use explicit interval boundaries from orchestration context and record timezone.

### 2. Why recorded task success can disagree with the external effect

The operator may return after receiving an acknowledgement that later proves non-durable, may validate only submission rather than completion, or may write one system and fail before another. Conversely, the external commit may succeed but the worker can die before recording task success. Therefore record an operation/idempotency key, destination commit identity and reconciliation step. Task state is one piece of evidence, not distributed transaction truth.

### 3. What makes a backfill safe

A safe backfill has exact interval/version scope; idempotent tasks; a measured bottleneck; protected live capacity and headroom at scheduler, metadata database, workers and dependencies; bounded max active runs/tasks/pool slots; calculated drain time; observability; pause criteria; validation; and a recovery/cleanup plan. It does not rely on worker count alone.

### 4. Complete reproducibility identity

At minimum retain:

1. code revision and entry point;
2. environment or image and dependency lock/digest;
3. training dataset version/snapshot and population rules;
4. feature-definition versions and point-in-time cutoffs;
5. parameters, seeds and relevant hardware/framework settings;
6. experiment run identity, metrics and evaluation method;
7. immutable model artifact digest, signature and input/output contract.

Reproducibility may still be bounded by nondeterministic kernels or hardware. State that limitation and acceptable tolerance rather than claiming bit-for-bit output without proof.

### 5. What an alias move changes

It changes a mutable name-to-version mapping in the registry. It does not mutate the model artifact. It may influence a deployment system that watches the alias, but it does not prove reconciliation, traffic shift, compatibility or rollback. Audit old/new version, principal, time, reason and evidence. Deployments should resolve and pin an immutable version/digest.

### 6. Feature skew versus concept drift

Feature skew is an implementation or data-contract mismatch: the same decision should receive equivalent features but training and serving compute different values. Prove it with paired samples from the same raw events and historical cutoff.

Concept drift means the real relationship between input and outcome changes. It requires mature labels and performance analysis, often by slice. Input distribution drift alone cannot distinguish the two. First rule out schema, freshness, transformation and instrumentation failures.

### 7. What notebook trust does not prove

Notebook trust does not authenticate a user, sandbox a kernel, validate source code, remove secrets, guarantee safe outputs, or make an execution reproducible. It primarily affects treatment of stored rich output. The kernel still executes with its process and platform permissions.

### 8. Evidence for real rollback

You need a preserved immutable previous model and runtime revision, compatible feature/input contract, available artifact and dependencies, routing mechanism, capacity, authorization, tested procedure, and success criteria. After routing, prove exact version on sampled requests, service health, dependency health and decision leading signals. Reconcile any stateful side effects; model rollback is not always data rollback.

### Why not use Airflow as a streaming engine?

Airflow is designed for finite, batch-oriented workflows; a task that never ends weakens retry, interval, completion and backfill semantics. It can orchestrate deployment or checks around a streaming system, but the stream processor should own continuous event-time state, checkpointing and recovery. This is an architectural boundary, not a claim that Airflow cannot launch a long-running process.

### Why not put large data in orchestration metadata or task messages?

Coordination stores are optimized for control state, not bulk transfer. Large payloads increase serialization, database/storage pressure, UI/API latency and failure blast radius. Store bulk data in an appropriate durable data system and pass a validated immutable reference, schema/version and checksum.

### How should drift alerts be designed?

Define feature or prediction, reference/current windows, statistic, threshold, minimum sample, critical slices, label maturity, expected seasonality, data-quality prechecks, owner, urgency and action. Alert only when the action is clear. Record model and feature versions so a deployment change is not mistaken for environmental drift.

### How do canary and shadow differ?

A canary sends a bounded portion of live traffic to a candidate and may return candidate responses, so it creates customer risk but tests the full path. Shadowing copies eligible traffic to a candidate while the established version serves the response; it reduces direct decision risk but can still expose data, consume capacity and create side effects unless the shadow path is isolated. Neither substitutes for offline evaluation or rollback.

## Product-company interview

### Question 1: A DAG is green but a table partition is missing. What do you do?

**What is being evaluated:** whether you challenge control-plane summaries and investigate end to end.

**Strong answer:** "I define the missing consumer outcome and interval, then bind the exact DAG run and bundle version. I inspect the complete task graph, try numbers and trigger rules, especially terminal cleanup tasks. I capture destination commit identities because task state cannot prove an external write. I stop downstream publication, reconcile the partition by the stable idempotency key, and retry only if the effect is safe. After recovery I add a required terminal validator and failure-branch tests so cleanup success cannot make the business outcome green."

**Weak warning signs:** "Clear the DAG," "rerun all failed tasks," or "green means the data should exist."

**Senior follow-up:** How do you prevent a rerun from duplicating an export? Explain destination uniqueness, operation ledger or compare-and-swap, ambiguous acknowledgement reconciliation, and downstream deduplication.

### Question 2: Design a safe 90-day backfill

**What is being evaluated:** capacity, correctness and change control.

**Strong answer:** "I pin transformation code, source snapshots and half-open intervals. I prove tasks are idempotent and outputs are versioned. I inventory scheduler, metadata database, executor, worker and downstream bottlenecks. From measured work per interval and protected live demand, I calculate spare parallelism and drain time. I use a dedicated pool/queue, low max-active runs, waves, pause criteria and live-SLO alerts. I validate counts, quality and consumer reconciliation per wave. I keep a rollback or superseding-output plan and do not promise duration from worker count alone."

**Senior follow-up:** What if the database is limited to 100 connections? Budget connections by workload and remember each task may open multiple connections; pool at the database boundary.

### Question 3: What does "reproducible model" mean?

**What is being evaluated:** whether you understand that a file and a metric are insufficient.

**Strong answer:** "It means I can reconstruct the intended training/evaluation process from immutable identities: code, environment, dependency versions, dataset and feature definitions, point-in-time rules, parameters, seeds, evaluation population and artifact digest. I state numerical nondeterminism and tolerance. I can link the registered version and deployment back to those records. A run name or notebook is not enough."

**Senior follow-up:** How do you handle a corrected historical dataset? Create a new dataset version and run; do not rewrite old lineage.

### Question 4: Accuracy is stable but complaints increased

**What is being evaluated:** metrics and user-journey thinking.

**Strong answer:** "I verify that labels are mature and representative, then segment by affected journey, geography, device, cohort and decision cost. I bind complaints to prediction/model/feature identities and check serving errors, latency, fallback rates, calibration and thresholds. Stable aggregate accuracy can hide a critical slice, changed prevalence or policy threshold. I compare against the correct baseline and quantify business harm before rollback or retraining."

**Senior follow-up:** What if labels take 60 days? Use leading quality/data signals and complaint outcomes for containment, while clearly labeling uncertainty until mature labels arrive.

### Question 5: How do you promote and roll back models?

**What is being evaluated:** immutable identity and progressive delivery.

**Strong answer:** "A candidate becomes an immutable registered version with artifact digest and signature. A gate checks versioned evaluation populations, critical slices, baseline and absolute thresholds, security and operational constraints. Approval is audited. A deployment revision pins the version, runtime and feature contract. I use a bounded canary or side-effect-free shadow, monitor service and decision signals, and expand gradually. Rollback routes to a preserved compatible revision and proves request-level version plus user recovery."

**Weak warning signs:** "Change production alias to latest."

### Question 6: How do you detect training-serving skew?

**Strong answer:** "I store one feature definition/version and event-time semantics, then capture safe sampled raw-event identities and online vectors. Offline, I recompute as of the original decision cutoff, including freshness, timezone, missing values and categories. I compare within declared tolerances by feature and slice. I alert on divergence and block promotion when contract tests fail."

### Question 7: An ML service has low CPU but high p99 latency

**Strong answer:** "CPU is only one resource. I split queue, feature lookup, model load, preprocessing, inference, postprocessing and network time using traces. I inspect concurrency, thread/process pools, memory pressure, accelerator utilization, batch policy, cold starts and downstream quotas. I test with bounded representative load and change the saturated boundary, not the visible host metric."

### Question 8: How would you secure a multi-tenant notebook platform?

**Strong answer:** "I treat each kernel as arbitrary code. I isolate users and workloads, use authenticated sessions and least-privilege authorization, short-lived workload identities, network/data policies, resource quotas, approved images, dependency controls, encryption, audit, idle shutdown and output/data retention. Administrative actions are separated. Repeatable production work leaves notebooks for versioned packages and orchestrated jobs."

### Question 9: When should you retrain?

**Strong answer:** "When an owned hypothesis and evidence show the current model no longer meets the decision objective, or a planned data/objective change requires a new candidate. I first rule out data-quality, feature-skew, instrumentation, routing and service faults. Retraining produces a candidate; it does not bypass reproducibility, evaluation, promotion or canary gates."

### Question 10: What would you automate and what stays human?

**Strong answer:** "Automate evidence collection, deterministic validation, idempotent reconciliation, bounded retries, threshold evaluation, progressive routing and rollback triggers with clear safeguards. Human review remains for objective and risk changes, ambiguous data/ethics impacts, exceptional access, major constraint trade-offs and incident command. Automation must expose why it acted and preserve an override/audit path."

## Independent transfer and rubric

The independent assessment is `ASM-0177`. It intentionally has no model answer. Reading this lesson or running the synthetic model cannot pass it.

### Required demonstration

Given an unfamiliar sanitized packet, the learner must:

- map the user decision through workflow, data, experiment, registry and serving;
- identify durable authorities and stable identities;
- diagnose one injected workflow or ML-serving incident;
- calculate backfill and serving capacity at the actual bottleneck;
- demonstrate duplicate-safe retry and exact interval replay;
- defend evaluation and promotion with slices and thresholds;
- prove feature parity or locate skew;
- execute controlled rollback and independent validation;
- address identity, secrets, notebooks, privacy, audit and cost;
- revise the design after a changed constraint;
- clean every disposable resource.

### Scoring interpretation

`ASM-0177` awards ten points to each of ten observable categories. A score is not mastery unless a reviewer observes the work, evidence is authentic, no safety boundary is bypassed, and delayed explanation shows retention. Any real credential, shared system, customer data, unbounded backfill/training/load, unaudited alias mutation or unknown cleanup is a stop condition, not a partial success.

### Suggested answer structure

Use:

```text
Impact:
Identities and authorities:
Timeline:
Evidence by boundary:
Competing hypotheses:
Containment:
Recovery:
Independent validation:
Capacity and cost:
Security and privacy:
Prevention:
Changed-constraint revision:
Cleanup proof:
```

This structure keeps the answer causal. Avoid narrating every command chronologically.

## References and review

The supporting records in `support/references` contain exact titles, authoritative URLs, review windows, scope and explicit limitations:

- `REF-0718` through `REF-0727`: Apache Airflow architecture, DAGs, tasks, runs, backfill, best practices, pools, health, security and audit.
- `REF-0728` through `REF-0731`: MLflow tracking, evaluation, model-registry workflow and deployment.
- `REF-0732`: Jupyter Server security.

The sources were reviewed on 2026-08-05. Airflow pages resolved to the current 3.3.0 documentation at review time; installed deployments may differ. MLflow and Jupyter behavior is version- and configuration-dependent. Recheck official documentation before using exact CLI/API syntax or security defaults.

### Final review checklist

- Can every green status be tied to a business outcome?
- Are run, interval, attempt and output identities separate?
- Are retries bounded and external effects reconcilable?
- Are backfills isolated at every shared bottleneck?
- Are parser, scheduler, executor, worker, triggerer and database health separate?
- Can every promoted model be reproduced from immutable evidence?
- Are aliases audited mutable pointers and deployments pinned?
- Are evaluation populations, slices, labels, baselines and thresholds explicit?
- Can training-serving parity be proven from paired historical samples?
- Does drift route to an owner and response?
- Are serving rollback and fallback tested?
- Are notebooks isolated as arbitrary-code surfaces?
- Does privacy retention cover every copy?
- Are costs linked to successful outcomes and failed/retried waste?

If any answer is "we assume," convert the assumption into an owner, evidence source, test and failure response. That is how a platform becomes operable.
