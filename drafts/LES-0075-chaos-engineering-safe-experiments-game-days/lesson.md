---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0075",
  "slug": "chaos-engineering-safe-experiments-game-days",
  "aliases": ["V04-L13", "chaos-engineering-safe-experiments-game-days"],
  "curriculumIds": ["CHAOS-001"],
  "route": "/book/reliability/chaos-engineering-safe-experiments-game-days",
  "order": 13,
  "volume": "04-reliability-operations",
  "title": "Chaos engineering: design safe experiments, game days, and durable learning",
  "summary": "Turn a reliability uncertainty into a falsifiable, observable and progressively bounded experiment with independent abort, proven recovery, honest inference and owned improvement.",
  "domain": "reliability",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0030", "LES-0032", "LES-0033"],
  "prerequisiteCurriculumIds": ["OBS-005", "SRE-002", "SRE-003"],
  "testedEnvironments": [
    {"platform":"Primary and official documentation","version":"Chaos Principles, AWS, Microsoft, Google, Kubernetes, Chaos Mesh and Chaos Toolkit sources reviewed 2026-08-07","support":"concept-only","notes":"Sources define principles and product semantics; they do not prove a specific system is safe or resilient."},
    {"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic 47-case decision model; no fault or infrastructure action."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON classification only; no socket, process signal, load or external process."},
    {"platform":"Representative resilience experiment","version":"not available","support":"unsupported","notes":"No real target, intervention, control, user traffic, recovery or production result."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "cloud-engineer", "kubernetes-engineer", "security-engineer", "infrastructure-engineer", "technical-lead", "architect"],
  "learningObjectives": [
    "Distinguish chaos engineering, resilience testing, fault injection, drills, game days, load tests and incident reproduction.",
    "Choose an experiment from a decision-changing uncertainty, critical flow, failure evidence and residual risk.",
    "Define measurable steady state, a comparable control and a falsifiable fault-mechanism-outcome hypothesis.",
    "Bind a realistic failure mechanism to exact target identities and known shared failure domains.",
    "Progress blast radius across environment, target count, duration, concurrency, traffic, tenant and data boundaries.",
    "Separate author, approver, executor and independent stop authority with least privilege.",
    "Design independent continuous probes, guardrails, abort thresholds, rollback actions and recovery checks.",
    "Protect business correctness, data, security, capacity, dependencies and people before injection.",
    "Execute with preflight evidence, actual-effect proof, frozen criteria, incident conversion and exact journals.",
    "Classify results as supported, disproved or inconclusive without overstating confidence.",
    "Turn findings into owned corrections, retests and cheaper regression checks where appropriate.",
    "Design cross-functional game days and state explicit conditions under which chaos must not run."
  ],
  "productionSignals": [
    "experiment ID revision digest author owner approver executor stop authority and decision",
    "critical flow operation population promise SLI SLO correctness and security invariant",
    "steady-state signal numerator denominator threshold window exclusions and missing-data rule",
    "control and treatment version config topology traffic tenant and selection method",
    "fault type layer mechanism parameter duration concurrency and expected effect",
    "target selector resolved immutable identities count namespace account region and owner",
    "blast-radius ceiling dependency reach data reach and worst-case user impact",
    "experiment identity permissions target capabilities approval and break-glass audit",
    "baseline and control health capacity quota quorum disruption budget and dependency consent",
    "guardrail source freshness threshold evaluation interval stop latency and owner",
    "action accepted started effect-observed stopped rollback-attempted and recovery timestamps",
    "user errors latency success correctness duplicates backlog saturation and security signals",
    "incident declaration command communication support report and customer-impact timeline",
    "hypothesis result supported disproved inconclusive confounders coverage and uncertainty",
    "recovery invariants reconciliation soak residual effects and cleanup inventory",
    "finding risk owner due date acceptance test retest outcome regression and recurrence"
  ],
  "diagrams": [
    {"id":"LES-0075-DIA-001","title":"Uncertainty to durable learning loop","direction":"cyclic","boundaries":["uncertainty","flow and promise","hypothesis","safety review","experiment","evidence","improvement","retest"],"evidencePoints":["decision","SLI","prediction","approval","journal","result","owner","verification"],"textAlternative":"A useful experiment starts with uncertainty and ends only after an owned improvement is retested."},
    {"id":"LES-0075-DIA-002","title":"Control, treatment and intervention","direction":"left-to-right","boundaries":["eligible population","assignment","control","treatment","fault effect","output comparison"],"evidencePoints":["selection","equivalence","target ID","effect probe","steady state"],"textAlternative":"Comparable control and treatment populations differ by the bounded intervention and are compared through output evidence."},
    {"id":"LES-0075-DIA-003","title":"Blast-radius envelope","direction":"hierarchical","boundaries":["organization","environment","service","tenant","target","duration and concurrency","data and dependencies"],"evidencePoints":["approval","account","owner","population","identity","timer","reach"],"textAlternative":"Blast radius is multidimensional and must be bounded across environment, targets, time, concurrency, users, data and dependencies."},
    {"id":"LES-0075-DIA-004","title":"Independent safety control plane","direction":"left-to-right","boundaries":["independent probes","guard evaluation","abort decision","stop authority","fault controller","recovery validation"],"evidencePoints":["fresh signal","threshold","audit","cessation","correct state"],"textAlternative":"Independent probes and authority stop injection without depending solely on the path being impaired, then separate checks prove recovery."},
    {"id":"LES-0075-DIA-005","title":"Experiment execution state machine","direction":"left-to-right","boundaries":["draft","review","dry run","preflight","inject canary","observe","abort or complete","rollback","recover","classify"],"evidencePoints":["revision","approval","targets","baseline","effect","guards","stop","actions","invariants","result"],"textAlternative":"Execution advances through evidence gates and any missing or unsafe state causes refusal or incident conversion."},
    {"id":"LES-0075-DIA-006","title":"Game-day people and evidence path","direction":"cyclic","boundaries":["facilitator","service team","incident command","dependencies","support and business","observer","review","action owners"],"evidencePoints":["scenario","response","decisions","handoffs","reports","timeline","findings","retest"],"textAlternative":"A game day exercises technical systems, roles, communications and decisions, producing owned improvements and retests."}
  ],
  "commands": [
    {"id":"LES-0075-CMD-001","question":"Is this a safe offline learning shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0075 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"normal-user, source and authority guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a named guard failed","nextEvidence":"correct without bypass"}],"proves":"local model prerequisites","doesNotProve":"experiment safety"},
    {"id":"LES-0075-CMD-002","question":"Can exact synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0075 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped state copy exists","nextEvidence":"status"},{"when":"refusal","meaning":"ownership or identity is unsafe","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"fault readiness","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0075-CMD-003","question":"How many reviewed cases are loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"cases=47","meaning":"expected fixture inventory is active","nextEvidence":"list"},{"when":"another count or refusal","meaning":"fixture drift","nextEvidence":"stop"}],"proves":"fixture count and state identity","doesNotProve":"real failure coverage"},
    {"id":"LES-0075-CMD-004","question":"Which cases can be compared?","risk":"read-only","command":"bash lab.sh list","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"47 unique names print","meaning":"case inventory is visible","nextEvidence":"show one case"}],"proves":"synthetic case names","doesNotProve":"scenario completeness"},
    {"id":"LES-0075-CMD-005","question":"What fields make the baseline defensible in this model?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"candidate inputs are inspectable","nextEvidence":"evaluate"}],"proves":"synthetic values","doesNotProve":"their truth in a system"},
    {"id":"LES-0075-CMD-006","question":"Does the baseline cross all encoded gates?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"boundary=defensible-within-model","meaning":"all predicates pass","nextEvidence":"compare failures"}],"proves":"deterministic baseline classification","doesNotProve":"resilience"},
    {"id":"LES-0075-CMD-007","question":"Can an unresolved selector authorize injection?","risk":"read-only","command":"bash lab.sh evaluate selector-not-resolved","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"boundary=target-inventory","meaning":"actual targets are unknown","nextEvidence":"resolve immutable inventory"}],"proves":"encoded scope gate","doesNotProve":"selector runtime"},
    {"id":"LES-0075-CMD-008","question":"Can an unrehearsed abort protect users?","risk":"read-only","command":"bash lab.sh evaluate abort-never-rehearsed","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"boundary=abort-tested","meaning":"declared abort lacks proof","nextEvidence":"rehearse stop and cessation"}],"proves":"encoded abort gate","doesNotProve":"real stop latency"},
    {"id":"LES-0075-CMD-009","question":"What if stop depends on the impaired path?","risk":"read-only","command":"bash lab.sh evaluate stop-uses-failed-control-plane","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"boundary=independent-stop","meaning":"correlated stop path blocks injection","nextEvidence":"independent authority and channel"}],"proves":"encoded independence gate","doesNotProve":"control-plane behavior"},
    {"id":"LES-0075-CMD-010","question":"Does green tooling prove the fault applied?","risk":"read-only","command":"bash lab.sh evaluate tool-green-fault-not-applied","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"boundary=fault-applied","meaning":"independent effect evidence is absent","nextEvidence":"target effect probe"}],"proves":"encoded false-green gate","doesNotProve":"tool behavior"},
    {"id":"LES-0075-CMD-011","question":"Does rollback execution prove recovery?","risk":"read-only","command":"bash lab.sh evaluate rollback-ran-state-still-wrong","runFrom":"LES-0075 support/lab after setup","expectedBranches":[{"when":"boundary=correct-state-restored","meaning":"recovery invariants failed","nextEvidence":"incident, reconcile and validate"}],"proves":"encoded recovery boundary","doesNotProve":"application correctness"},
    {"id":"LES-0075-CMD-012","question":"Do every decision, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0075 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"47 decisions, refusal and cleanup pass","nextEvidence":"retain model-only limit"},{"when":"failure","meaning":"candidate evidence rejected","nextEvidence":"preserve first failure"}],"proves":"offline model lifecycle","doesNotProve":"fault injection, experiment, game day or resilience","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0075-LAB-001","title":"Guided experiment evidence-gate model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no fault mechanism","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic 47-case fixture"],"abortConditions":["root","credential","cloud profile","cluster context","Docker endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0075-chaos-engineering-safe-experiments-game-days/support/lab"},
    {"id":"LES-0075-LAB-002","title":"Independent unfamiliar controlled resilience experiment","mode":"independent","environment":"Reviewer-owned disposable local infrastructure with synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns hidden faults and stop authority","network":"loopback or isolated local only","changes":["bounded synthetic intervention","five hidden experiment defects","tabletop incident response"],"abortConditions":["production","public target","real credential","customer data","external cloud","uncontrolled load or fault","unknown authority or cleanup"],"recovery":"Stop, preserve evidence, restore the disposable baseline and prove exact absence.","cleanupProof":"Reviewer proves every process, port, file, identity, rule and target absent.","path":"drafts/LES-0075-chaos-engineering-safe-experiments-game-days/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0075-INC-001","signal":"Selector resolves to targets outside approved scope.","firstThought":"Intended labels are not an execution boundary.","safePath":"Refuse start, preserve inventory, correct identity and repeat review.","trap":"Run because the percentage is small."},
    {"id":"LES-0075-INC-002","signal":"Experiment tool completes but no independent fault effect appears.","firstThought":"Orchestration status is not intervention evidence.","safePath":"Classify inconclusive, do not claim resilience, repair observability or mechanism safely.","trap":"Call the hypothesis supported."},
    {"id":"LES-0075-INC-003","signal":"Abort alarm fires but injection continues.","firstThought":"Guard observation and stop execution are disconnected or correlated.","safePath":"Use independent stop, convert to incident command, recover and preserve audit evidence.","trap":"Wait for configured duration."},
    {"id":"LES-0075-INC-004","signal":"Rollback runs but duplicate business effects continue.","firstThought":"Reversal of infrastructure did not restore correct state.","safePath":"Contain side effects, reconcile domain state, validate invariants and soak.","trap":"Declare recovered when pods are Ready."},
    {"id":"LES-0075-INC-005","signal":"A real dependency incident begins during the experiment.","firstThought":"Attribution and operational priority changed.","safePath":"Stop injection, declare or join incident command, preserve experiment context and serve recovery.","trap":"Finish the experiment for clean data."}
  ],
  "assessmentIds": ["ASM-0208", "ASM-0209", "ASM-0210"],
  "referenceIds": ["REF-0883", "REF-0884", "REF-0885", "REF-0886", "REF-0887", "REF-0888", "REF-0889", "REF-0890", "REF-0891", "REF-0892", "REF-0893", "REF-0894", "REF-0895", "REF-0896", "REF-0897"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline lab is a decision model, not a fault-injection or resilience system.",
    "No process, service, network, load, container, cluster, cloud resource, credential or production target is inspected or changed.",
    "Experiment behavior depends on exact tool, version, topology, workload, failure and organization.",
    "No real steady state, control, intervention, abort, rollback, recovery, game day or production-safety claim is made.",
    "Formal reliability, security, data and instructional review, representative exercises, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Chaos engineering: design safe experiments, game days, and durable learning

## What you see and first thought

### The sentence that should slow you down

Someone says, "Let us kill random pods in production and see what happens."

Your first thought should not be a tool name. It should be:

> What uncertainty will this change into evidence, which user promise are we protecting, and how will we stop independently before the experiment becomes the incident?

Killing a pod is an action. Chaos engineering is the complete learning system around a controlled variable. Without a falsifiable hypothesis, exact target, measurable output, safety envelope, recovery proof and owned improvement, the team is merely creating failure.

### The memorable model

Think of a chaos experiment like a medical trial on a live system:

- the **question** must matter;
- the **control** shows what happened without the intervention;
- the **treatment** receives one bounded variable;
- the **vital signs** are user and correctness outputs;
- the **dose** is target count, intensity, duration and concurrency;
- the **stopping rule** is decided before the result;
- the **recovery** must be proved, not assumed;
- the **finding** changes treatment only after review.

The comparison is not perfect—software is not a patient—but it keeps the scientific and safety responsibilities together.

### A false-green experiment

Imagine a checkout team terminates two application pods. The experiment controller reports `Completed`. Kubernetes creates replacements. CPU stays low.

At the same time:

- eligible checkout success falls from 99.95% to 96%;
- one retry path submits payment authorization twice;
- the replacement pods become Ready before their caches and dependency pools are usable;
- an unrelated deployment changes the same service;
- the abort alarm is delayed by the telemetry path being tested;
- the rollback recreates pods but does not reconcile payments.

The tool completed its workflow. The resilience hypothesis failed. Correct recovery is still unfinished.

Whenever you see a green experiment status, ask four separate questions:

1. Did the intended fault actually affect only the approved targets?
2. Did the user-facing and correctness hypothesis hold?
3. Did every abort and safety control behave as designed?
4. Did the system return to correct state with no residual effect?

### Why teams get this wrong

Fault injection is visible and exciting. Scientific design, authorization, data reconciliation and follow-up work are quieter. Teams therefore optimize the visible action:

```text
tool installed -> fault executed -> dashboard screenshot -> "chaos complete"
```

The useful path is longer:

```text
important uncertainty
  -> measurable promise
  -> falsifiable prediction
  -> exact scope and safety
  -> controlled intervention
  -> independent evidence
  -> honest inference
  -> owned correction
  -> retest
```

If the loop stops at a screenshot, the organization bought risk but did not buy learning.

### What this lesson will and will not do

This lesson teaches how to design, refuse, execute, analyze and operationalize controlled resilience experiments and game days. Its local lab evaluates decision order only. It does not send a signal, consume CPU, add latency, kill a process, change a route, delete a pod or call a cloud API.

That restraint is intentional. A beginner should first learn the contract that makes an intervention defensible. A real experiment belongs only in reviewer-owned disposable infrastructure until system-specific evidence supports broader scope.

## Terms before commands

### Chaos engineering

**Chaos engineering** is disciplined experimentation on a system to reduce uncertainty about its behavior under turbulent conditions. It attempts to disprove a prediction about observable system output while controlling risk.

It is not synonymous with random destruction, outage rehearsal or a particular product.

### Resilience

**Resilience** is the system and organization's ability to sustain or recover an acceptable service under disruption. It includes technical mechanisms, capacity, data correctness, security, people, decisions and recovery.

An experiment can provide evidence about one resilience claim. It cannot prove resilience against every fault.

### Fault injection

**Fault injection** deliberately introduces a condition: terminate a process, add latency, drop packets, exhaust a bounded resource, return an error or make a dependency unavailable.

Fault injection is a mechanism. It becomes a chaos experiment only when surrounded by hypothesis, observation, safety, comparison, analysis and learning.

### Resilience test, experiment, drill and game day

- A **resilience test** checks a known expected behavior, often with a deterministic pass/fail result.
- An **experiment** evaluates a falsifiable hypothesis under a controlled variable and may produce an unexpected or inconclusive result.
- A **drill** practices a known procedure such as failover, restore or escalation.
- A **tabletop** walks people through decisions without performing every technical action.
- A **game day** exercises a wider scenario across systems, roles, procedures and communication.

A game day may contain experiments and drills. Calling an uncontrolled production action a game day does not make it safe.

### Uncertainty and decision

An **uncertainty** is a meaningful gap in what the team knows: "Will checkout stay correct if one availability-zone dependency becomes unreachable?"

The experiment should name the **decision** its evidence may change: approve an architecture, remove a fallback, change a timeout, add capacity, revise a runbook or block release.

If no decision can change, ask whether a lower-risk observation or review is enough.

### Critical flow

A **critical flow** is a named user or business operation across dependencies. "Checkout" is still broad. A stronger contract is:

> An eligible authenticated customer creates one order, receives one durable payment outcome and can retrieve the same order.

This exposes availability, latency and correctness—not merely pod health.

### Steady state

In chaos engineering, **steady state** is a measurable output pattern representing acceptable normal behavior for the experiment. It does not mean the system never changes or every metric is flat.

A usable steady-state signal has:

- population and operation;
- numerator and denominator or numerical definition;
- threshold or tolerance;
- evaluation window;
- exclusions;
- missing-data behavior;
- source, freshness and owner.

"Healthy" has none of these. "At least 99.9% of eligible synthetic checkouts complete once within 800 ms over each rolling five-minute window; missing probe data aborts" is falsifiable.

### Hypothesis

A **hypothesis** predicts what the bounded system will do under a named fault because a named mechanism should respond.

Use this structure:

> If **fault F** affects **target T** under **workload W**, then **mechanism M** will keep **output O** within **tolerance B** and restore **condition R** within **time D**.

The hypothesis must be able to fail. "The system is resilient" is not operationally falsifiable.

### Control and treatment

The **control** is a comparable population or interval without the intervention. The **treatment** receives the experiment variable.

They should match in software, configuration, topology, traffic, tenant mix and time as closely as practical. Differences are **confounders**: alternative explanations for the observed outcome.

A control improves attribution. It does not magically prove causality if selection is biased or dependencies differ.

### Intervention, action and effect

The **intervention** is the controlled change. A tool may report an **action** accepted or completed. The independent **effect** is what actually happened at the target: a process exited, packets were delayed, a dependency call failed or a target became unavailable.

Action status is not effect evidence.

### Target and selector

A **target** is the exact object that may be affected. A **selector** is a rule that resolves targets, such as labels or tags.

Selectors can drift and dynamic systems can add targets. Preserve the resolved immutable identities immediately before authorization. "The selector should match one pod" is not an inventory.

### Blast radius

**Blast radius** is the maximum reachable harm. It is multidimensional:

- environment and account;
- service and dependency;
- target count or percentage;
- tenant, user and traffic;
- duration and concurrency;
- geographic or failure domain;
- data and external side effects;
- identity and control plane;
- human and support impact.

Reducing one dimension does not bound the others. One database target can hold all customer state.

### Guardrail, abort, stop, rollback and recovery

A **guardrail** continuously evaluates a safety signal.

An **abort condition** decides that injection must end. A **stop path** applies that decision to the fault mechanism. A **rollback** attempts to reverse experiment-created changes. **Recovery** is the separately observed return of correct user, data, security and operational state.

```text
threshold crossed -> abort decision -> injection stopped
                                      -> rollback attempted
                                      -> recovery verified
```

Each arrow can fail. Treat them as separate evidence.

### Independent safety path

A safety path is **independent** when observation, authority and stop execution do not depend only on the component being impaired.

If the experiment delays the Kubernetes API and the only stop button requires that API, the stop path is correlated. Independence is architectural and must be rehearsed.

### Supported, disproved and inconclusive

- **Supported within scope**: evidence did not disprove the hypothesis under the recorded version, target, workload, duration and coverage.
- **Disproved**: a relevant output crossed the predefined tolerance or recovery condition failed.
- **Inconclusive**: the fault did not apply, probes failed, control was not comparable, a concurrent event destroyed attribution or evidence was incomplete.

"Supported" never means universally proven. "Inconclusive" is honest and can reveal an observability or safety defect.

### Game-day roles

Important roles include experiment lead, service owner, facilitator, executor, independent stop authority, incident commander, recorder, dependency owners, security/data reviewers, communications owner and customer support.

One person may hold several roles in a small disposable exercise. Start, stop and high-blast-radius approval should not collapse silently into one unreviewed identity.

## Architecture map

### View 1: uncertainty to durable learning

```text
[uncertainty] -> [flow and promise] -> [hypothesis]
      ^                                  |
      |                                  v
[verified improvement] <- [finding] <- [controlled run]
      |                                  |
      +------------- [retest] <----------+
```

The loop begins with a question and ends with a verified change. A passed experiment may become a regression check. A failed experiment creates work. An inconclusive experiment repairs evidence or design. None ends at injection.

### View 2: control and treatment

```text
             eligible population
                    |
          comparable assignment
             /             \
       [control]        [treatment]
           |                |
    observe output     bounded fault
           |                |
           +---- compare ---+
```

Record how assignment occurred. Random assignment may be impossible for stateful topology; matched cohorts can be used, but differences must remain visible.

### View 3: blast-radius envelope

```text
organization / business window
  environment / account / cluster
    service / dependency / tenant
      exact target identities
        duration + concurrency + intensity
          data + external side effects
```

Every inner boundary sits inside outer authority. A namespace selector does not authorize the cluster, a cluster permission does not authorize customer impact, and technical ownership does not authorize regulatory risk.

### View 4: independent safety control plane

```text
user + correctness + security probes
                |
                v
      guard evaluator / timer
                |
         abort decision
           /          \
          v            v
 independent stop   incident command
          |
          v
 fault cessation -> rollback -> recovery invariants
```

The guard must define stale or missing telemetry behavior. "No data" during an experiment is unsafe evidence, not automatic success.

### View 5: execution state machine

```text
draft -> peer review -> dry run -> preflight
                                  |
                                  v
                            smallest canary
                                  |
                  +---------------+---------------+
                  |                               |
              within bounds                 abort / incident
                  |                               |
                  +----------> rollback <---------+
                                  |
                         recovery + cleanup
                                  |
                     classify + own findings
```

State transitions require evidence. A deadline, missing approval, target change or unhealthy baseline moves to refusal, not "best effort."

### View 6: game-day organization

```text
facilitator -> scenario and injects -> service responders
     |                                  |
     v                                  v
observer/recorder <- decisions <- incident command
     |                                  |
     +-> dependencies / security / support / business
                      |
                      v
              review -> owners -> retest
```

The facilitator controls scenario information. Incident command controls response. The safety officer retains stop authority. The observer records without steering unless safety requires it.

### Read the boundaries together

The scientific plane asks whether the hypothesis is discriminating. The safety plane asks whether harm remains acceptable and stoppable. The organizational plane asks whether people can detect, decide, communicate and recover. A mature program requires all three.

## Request or state path

### Before the run

The path starts before any tool command:

1. A service owner names an uncertainty and the decision it may change.
2. Architecture and incident evidence identify a realistic failure mode.
3. The team binds a critical flow and correct-state invariants.
4. Steady-state tolerances and a control are defined.
5. The hypothesis names fault, target, mechanism, outcome and recovery deadline.
6. The experiment definition resolves targets and maximum blast radius.
7. Security, data, capacity, dependency and business reviewers assess residual risk.
8. Independent probes, abort, stop, rollback and recovery are rehearsed.
9. Roles and communication are scheduled.
10. Approval is bound to the reviewed experiment version.

### At preflight

Immediately before injection, conditions may differ from review. Reconfirm:

```text
revision -> authority -> resolved targets -> baseline -> control
         -> capacity -> dependencies -> telemetry -> abort/stop
         -> rollback/recovery -> conflicting changes -> go/no-go
```

If labels now resolve a new target, an alarm is stale, capacity headroom disappeared or an incident has begun, the approved experiment is no longer the same experiment.

### During the intervention

Execution produces two evidence streams:

- **action evidence** from the controller: requested, accepted, started, stopped and rollback attempted;
- **system evidence** from independent observation: actual target effect, user output, correctness, security, capacity and recovery.

Use synchronized timestamps and a correlation identifier. Continuously evaluate guards. Do not wait for the planned end if a stop condition is true.

### When a guard crosses

The state path becomes:

```text
deviation detected
  -> abort declared
  -> injection stop requested
  -> cessation independently observed
  -> rollback attempted
  -> incident command if impact is unexpected or persists
  -> correct state reconciled and validated
```

Experiment completion loses priority to user and data recovery. The team must not continue "for clean results."

### After injection ends

Ending the variable is not the end of the experiment. Validate:

- target and infrastructure state;
- critical user flow;
- correctness and authorization invariants;
- queue or retry backlog;
- duplicate or deferred side effects;
- capacity and dependency recovery;
- security/audit state;
- sustained soak;
- exact artifact and permission cleanup.

Then classify the hypothesis with limitations. Preserve raw evidence. Assign actions and a retest. Only a later verified correction closes the learning loop.

### The confidence boundary

An experiment result has coordinates:

```text
confidence claim =
  experiment version
  + system version/config
  + exact targets
  + workload/population
  + fault parameters
  + duration
  + evidence coverage
  + observed outcome
```

Change the coordinates and confidence must be reconsidered. Repeating experiments is valuable because systems drift, not because injected-fault count is a goal.

## Failure zoom

### Failure 1: the hypothesis cannot lose

**Signal:** "The system should remain resilient."

**Why it fails:** resilient has no population, output, tolerance or time. Any result can be explained as success after the fact.

**Safe response:** rewrite before execution:

> If one of four checkout workers becomes unavailable for at most 90 seconds under 20 synthetic requests per second, retry budgets and load balancing will keep eligible checkout success at or above 99.5%, create no duplicate payment identity, and restore four serving workers within five minutes.

Now success, failure and missing evidence are distinguishable.

### Failure 2: infrastructure health hides user failure

**Signal:** CPU, pod count and host availability stay green while checkout errors rise.

**Mechanism:** infrastructure signals describe resources, not necessarily the service promise. Readiness can be shallow; retries can hide dependency errors while amplifying side effects; an average can hide one tenant or tail.

**Safe response:** pair component mechanism signals with user journey, correctness, security and backlog outputs. Abort on the promise, not only the machinery.

### Failure 3: a selector expands scope

**Signal:** `app=checkout` matches a migration worker or shared payment adapter.

**Mechanism:** labels and tags are mutable metadata. Controllers create new objects. A percentage may select any member of the resolved population.

**Safe response:** resolve and preserve exact UIDs, owners, versions and state roles; enforce allowlisted namespace/account and maximum count; re-resolve at preflight; refuse any difference.

### Failure 4: control and treatment are not comparable

**Signal:** treatment has a new binary, receives premium customers or sits in a different zone from control.

**Mechanism:** an observed difference can come from release, workload, topology or dependency rather than the fault.

**Safe response:** match cohorts, randomize when safe, stratify by important dimensions, freeze changes and record residual confounders. If attribution remains weak, classify the result as inconclusive.

### Failure 5: the tool says completed but the fault never applied

**Signal:** API accepted an action but target effect is absent.

**Mechanism:** permission, agent, selector, version or controller failure can be hidden behind orchestration status. Some actions are asynchronous.

**Safe response:** require an independent effect probe: target process generation changes, measured latency is injected, exact route is blocked, or chosen target becomes unavailable. If the effect is unproved, the resilience hypothesis was not tested.

### Failure 6: the abort observes through the failed path

**Signal:** the guard alarm stops updating when the experiment impairs telemetry or its control plane.

**Mechanism:** observation and stop share a dependency with the target. Missing data is misread as healthy. A stop request cannot reach the controller.

**Safe response:** use an external synthetic probe, independent clock/dead-man timer, separately authorized stop and maximum fault duration. Rehearse both threshold detection and independently observed cessation.

### Failure 7: rollback is not recovery

**Signal:** deleted pods return but duplicate transactions, stale routes or backlog remain.

**Mechanism:** rollback reverses the injected configuration or resource action. The intervention may have triggered durable side effects beyond it.

**Safe response:** define domain recovery checks: one outcome per idempotency key, balanced ledger, drained queue, correct authorization, restored capacity, no injected rule, and stable flow during soak.

### Failure 8: a known failure is injected

**Signal:** existing evidence already proves the service has no spare capacity or fallback.

**Mechanism:** the experiment adds predictable harm rather than discriminating uncertainty.

**Safe response:** repair the known gap, validate it with a lower-risk deterministic test, then experiment on what remains uncertain. Chaos is not a substitute for unfinished engineering.

### Failure 9: a real incident overlaps the experiment

**Signal:** dependency latency rises in control and treatment, or an unrelated alert begins.

**Mechanism:** experiment impact and real failure interact; attribution collapses; responders may mistake injected symptoms for the incident.

**Safe response:** stop injection, preserve the experiment timeline and enter incident command. Communicate the experiment as a possible contributor. User recovery outranks study completion.

### Failure 10: automation repeats stale risk

**Signal:** a scheduled experiment continues after ownership, target topology or abort semantics change.

**Mechanism:** experiment code is operational code. Its permissions, selectors, dependencies and assumptions drift.

**Safe response:** bind approvals to versions; expire reviews; preflight every run; disable schedules on ownership/config drift; treat experiments as maintained regression assets with tests and retirement criteria.

### Failure 11: the team celebrates injection volume

**Signal:** program dashboards count pods killed or experiments run.

**Mechanism:** activity becomes the goal. Teams avoid safe aborts or inconclusive classification because those look like failure.

**Safe response:** measure decision value, safe refusal/abort, evidence quality, finding closure, retest, recurrence and reduced uncertainty. A cancelled unsafe experiment is a safety-system success.

### Failure 12: game day becomes theater

**Signal:** participants know every inject, follow a perfect script and produce no actions.

**Mechanism:** the event demonstrates a rehearsed happy path instead of testing detection, roles, communication and decisions.

**Safe response:** preserve a safety envelope but vary hidden details, absent roles, ambiguous signals and dependency communication. Score response evidence and learning, not dramatic completion.

## Internals and state ownership

### The experiment is a distributed control system

Even a simple experiment has interacting components:

```text
author/repository -> reviewer/approval -> scheduler/executor
                                      -> discovery/selector
                                      -> fault provider/agent
independent probes -> guard evaluator -> stop controller
system under test -> telemetry/effects -> journal/review
```

Each component has state, identity, failure modes and clocks. Treat the experiment platform like production automation.

### Experiment definition state

The versioned definition owns:

- question and decision;
- hypothesis and steady-state specification;
- target policy and maximum scope;
- fault type and parameters;
- probes and guard thresholds;
- abort and rollback actions;
- roles, approvals and expiry;
- recovery and cleanup checks.

Approval should bind to the exact revision or digest. Editing a selector or duration after approval creates a new experiment.

### Discovery and target state

Selectors are evaluated against changing inventory. Preserve both:

- **policy**: what may be selected;
- **resolution**: what was selected at a timestamp.

For Kubernetes, names can be recreated; UID binds the object incarnation. For cloud resources, bind account, region and resource identifier. For processes, PID alone can be reused; bind process start identity. The exact mechanism depends on the platform.

### Fault-controller state

The controller may hold action status, schedules, target handles, timers, agents and rollback configuration. Its "completed" state reflects its workflow semantics, not the service hypothesis.

Ask:

- Is action execution synchronous or asynchronous?
- What happens if the controller restarts?
- Does deletion or pause reverse the fault?
- Is duration enforced at target, agent or controller?
- Are partial target successes reported?
- Can rollback run after lost connectivity?
- Which artifacts or permissions remain?

Official tool documentation is necessary, but a versioned disposable rehearsal is the evidence for your configuration.

### Probe and telemetry state

A probe has source, query, sampling interval, aggregation, freshness, population and failure behavior. Continuous guards need reliable time.

A five-minute rolling error rate evaluated every minute can permit several minutes of harm. A delayed metrics pipeline lengthens stop latency. An average can conceal a small cohort. Record:

```text
maximum exposure time approximately =
  signal delay
  + evaluation interval
  + alarm transition delay
  + decision delay
  + stop propagation
  + fault cessation delay
```

Measure the components in a rehearsal.

### Authority state

Separate identities:

- author can propose but not necessarily run;
- reviewer approves a defined envelope;
- executor can start only approved experiments;
- fault identity changes only approved targets;
- stop authority can terminate independently;
- observer reads evidence;
- cleanup identity removes only experiment-owned artifacts.

Broad administrative access makes experimentation easier but expands compromise and error blast radius. Least privilege is part of experimental validity because it enforces scope.

### Business and data state

Faults can outlive infrastructure through:

- duplicate or reordered messages;
- partially committed transactions;
- stale caches or search indexes;
- retried external calls;
- expired leases;
- lost in-flight work;
- security lockouts;
- backlog and recovery overload.

The domain owner defines correctness and reconciliation. A chaos tool cannot infer whether two payment authorizations represent harm.

### Human state

People have roles, information and cognitive load. Game-day state includes:

- who knows the scenario;
- who can reveal injects;
- who can stop;
- who declares an incident;
- communication channels;
- handoff and decision logs;
- fatigue and availability;
- observer notes.

Do not surprise an on-call team with an unannounced production fault. Realism does not require withholding safety authority or organizational consent.

### Evidence ownership

The recorder preserves raw facts. The service owner interprets application behavior. Security and data owners validate their invariants. The facilitator owns scenario delivery. A reviewer challenges inference and limitations.

Separate:

- observed fact;
- calculated value;
- causal inference;
- assumption;
- unknown.

This prevents "fault happened before error" from becoming an unreviewed causal claim.

### Cleanup state

Cleanup inventories experiment definitions, schedules, agents, rules, temporary resources, credentials, telemetry annotations, synthetic data and local artifacts. Unknown state causes refusal.

Absence must be checked from the authoritative boundary. Deleting a local file does not prove a remote network rule is gone. The local lab can prove only its two allowlisted files and directory are absent.

## Evidence table

| Evidence | It supports | It does not support |
|---|---|---|
| reviewed experiment revision | intended question, scope and controls | runtime target resolution or safe outcome |
| selector resolution with immutable IDs | visible target set at that time | future dynamic members or business authorization |
| baseline steady-state pass | covered preconditions before start | future stability or hidden signals |
| comparable control | contemporaneous behavior without treatment | absence of all confounders |
| controller action accepted | provider accepted a request | actual fault effect |
| independent effect probe | named effect reached covered targets | every downstream effect |
| user-flow synthetic | sampled operation behavior | all users or data |
| correctness invariant | covered domain property | untested invariants |
| component metrics | mechanism and resource behavior | complete user promise |
| guard alarm transition | query crossed configured rule | stop execution or recovery |
| stop receipt | controller processed a stop | cessation at every target |
| rollback log | reversal actions attempted | correct state |
| recovery and reconciliation tests | named state and flow recovered | no later latent effect |
| soak window | stability during that window | indefinite future behavior |
| supported hypothesis | no disproof within exact scope | universal resilience |
| disproved hypothesis | relevant expected behavior failed | root cause by itself |
| inconclusive result | evidence or attribution was insufficient | hypothesis supported or disproved |
| owned action and passing retest | scoped correction changed repeated outcome | every related failure prevented |

### Evidence priority

Prefer evidence closest to the claim. If the claim is "customers can complete checkout once," use checkout and transaction invariants. CPU helps explain mechanism but cannot substitute.

### Negative evidence matters

Refusal, abort, missing effect and failed cleanup are valuable results. They show the safety or evidence system prevented an unsupported claim. Preserve them instead of rerunning until green.

### Confidence wording

Say:

> Under version X, synthetic workload W and one selected target for 90 seconds, the observed flow stayed within tolerance and recovered by five minutes. The test did not cover zone loss, real payment provider behavior or peak traffic.

Do not say:

> Checkout is chaos tested and resilient.

## Command decoders

### Command 1: `bash lab.sh doctor`

**Question:** Is this shell powerless enough for the teaching model?

`bash` invokes the shell explicitly. `lab.sh` is the repository wrapper. `doctor` checks normal user, Python, source files, absence of cloud/cluster/Docker authority variables and safe state identity.

Expected:

```text
model=valid cases=47 gates=46
doctor=pass network=none user=<uid>
```

This proves only local preconditions. It does not inspect whether the host has other credentials outside the process environment.

### Command 2: `bash lab.sh setup`

Creates one `/tmp/reliability-atlas-les0075-chaos-<uid>` directory with mode constrained by `umask 077`, a sentinel and a copied fixture.

If state exists, setup refuses. It does not overwrite or "repair" unknown state.

### Command 3: `bash lab.sh status`

Status verifies ownership, sentinel, no symlink and exact allowlisted inventory before counting cases. Expected includes `cases=47`.

Directory existence alone is not trusted state.

### Command 4: `bash lab.sh list`

Lists case names from validated JSON. It does not discover real experiments, tools or targets.

### Command 5: `bash lab.sh show baseline`

Prints merged synthetic fields for one case. Read every true value as a claim requiring provenance in production. The model does not generate that provenance.

### Command 6: `bash lab.sh evaluate baseline`

Expected boundary is `defensible-within-model`. That phrase is deliberately narrower than "safe" or "resilient." All encoded booleans passed; completeness of the model and truth of a real environment remain unproved.

### Command 7: `bash lab.sh evaluate selector-not-resolved`

Expected:

```text
case=selector-not-resolved boundary=target-inventory expected=target-inventory
```

The model stops at the first missing gate. Later approvals cannot repair unknown target scope.

### Command 8: `bash lab.sh evaluate abort-never-rehearsed`

An abort rule on paper is not operational evidence. The next proof is a safe rehearsal showing detection, decision, stop propagation and cessation within the exposure budget.

### Command 9: `bash lab.sh evaluate stop-uses-failed-control-plane`

This case distinguishes a stop command from an independent stop path. A second UI backed by the same API is not independent.

### Command 10: `bash lab.sh evaluate tool-green-fault-not-applied`

The classifier requires `fault_application_observed=true`. In a real exercise, choose an effect probe that is safe, direct and independent of the controller's status.

### Command 11: `bash lab.sh evaluate rollback-ran-state-still-wrong`

This case reaches `correct-state-restored` only after rollback was defined, tested and attempted. It teaches sequence: good rollback logs cannot overrule failed business invariants.

### Command 12: `bash verify.sh`

The verifier:

1. starts from absent state;
2. validates 47 cases and 46 gates;
3. evaluates every case;
4. asserts important boundaries;
5. injects an unknown local artifact;
6. proves status refuses it;
7. removes only that known test artifact;
8. performs allowlisted cleanup;
9. proves state absence.

Expected:

```text
verify=pass cases=47 refusal=true cleanup=true
```

The verifier never injects a system fault. Its value is deterministic decision and cleanup behavior.

## Decision path

Chaos engineering is a sequence of decisions, not a sequence of failure-injection commands. A strong operator can explain every decision before granting the executor authority to change a target.

### The go/no-go path

Use this order. Do not skip ahead because a tool is ready.

```text
1. Question
   What uncertainty could change a design or operating decision?
        |
        v
2. Steady state
   Which user-visible or business invariant must remain true?
        |
        v
3. Hypothesis
   Under one named condition, what exact behavior do we predict?
        |
        v
4. Scope
   Which immutable targets, one environment, one tenant, and one time window?
        |
        v
5. Authority
   Who may approve, execute, abort, recover, and declare recovery?
        |
        v
6. Observability
   Can we see baseline, fault application, user impact, saturation, and recovery?
        |
        v
7. Safety
   Is exposure bounded? Are stop and recovery paths tested and independent enough?
        |
        v
8. Execute progressively
   Smallest useful scope first; expand only while every gate remains true.
        |
        v
9. Classify evidence
   Inconclusive, contradicted, supported-within-scope, or unsafe/aborted?
        |
        v
10. Change the system
    Owner, due date, verification, regression experiment, and retained evidence.
```

The important habit is to ask, “What decision becomes different after this experiment?” If the honest answer is “none,” do not create risk merely to produce activity.

### Gate A: is this actually an experiment?

Proceed only when all five statements are true:

| Check | Good evidence | Refuse when |
|---|---|---|
| Uncertainty | a specific unknown about real system behavior | the outcome is already known from an open incident or failed test |
| Falsifiable prediction | observable conditions could prove the prediction wrong | wording such as “the platform should be resilient” |
| Decision consumer | a named owner will use the result | the result is only for a demonstration |
| Measurable invariant | a user/business signal has a query and owner | only pod count or tool status is observed |
| Controlled comparison | baseline and experiment windows are comparable | unrelated releases or load changes dominate the window |

A known defect belongs in the delivery backlog. A chaos experiment is not a dramatic way to rediscover it.

### Gate B: can the target be bounded?

Resolve selectors to immutable inventory before approval. Record exact object identity, environment, region or zone, tenant boundary, replicas affected, dependency direction, and maximum concurrent targets.

Suppose a label selector currently resolves to two pods. “Selector matches two pods” is not enough. Autoscaling or a deployment can change membership between approval and execution. A defensible control either snapshots and signs the resolved target set, locks execution to immutable identifiers, or re-resolves immediately before execution and requires renewed approval when the set differs.

Calculate a simple exposure envelope:

```text
maximum_exposure =
  maximum_targets
  x maximum_duration
  x maximum_traffic_fraction
```

This is not a universal risk score. It forces the team to name three dimensions hidden by “small blast radius.”

Refuse when the executor can reach production broadly, shared dependencies cannot be excluded, or identity is less precise than the potential damage.

### Gate C: can humans and automation stop safely?

An abort rule needs five fields:

1. **Signal:** the exact query or event.
2. **Threshold:** a numeric or categorical boundary.
3. **Window:** how long the condition must hold.
4. **Decision owner:** who is accountable for the stop.
5. **Actuation path:** how the experiment is halted and how cessation is confirmed.

Example:

```text
If checkout good-event ratio falls below 99.0% for two consecutive
one-minute windows, the safety controller stops new fault actions within
30 seconds. The abort owner confirms cessation using an independent
effect probe. The recovery owner then validates business invariants.
```

That statement is testable. “Stop if errors get high” is not.

The stop path should not share the exact failure domain being tested. If the experiment removes network access to a cluster API, a stop mechanism that requires only that API is fragile. Independence can come from a separate control account, out-of-band management plane, pre-expiring action, local watchdog, or automatically bounded duration. No mechanism is perfectly independent; record remaining correlation explicitly.

### Gate D: is recovery proved rather than assumed?

Keep these moments separate:

```text
fault command ended
        !=
rollback command completed
        !=
service recovered correctly
```

Recovery must be declared from invariants: correct transactions, bounded latency, queue age falling, replica convergence, data consistency, and no hidden retry storm. A green rollback task proves only that the task returned success.

Before execution, require:

- a recovery owner;
- a written procedure or automated recovery action;
- a rehearsal at a safer scope;
- credentials and dependencies available during the planned failure;
- a maximum recovery deadline;
- escalation when recovery misses that deadline;
- a way to detect delayed damage after the session.

If recovery has never been tested, the planned experiment may be a recovery rehearsal at a disposable scope—not a production fault.

### Gate E: is the organization ready now?

Technical controls do not cancel bad timing. Refuse or postpone during:

- an active incident or unresolved degradation;
- a major release, migration, financial close, or business peak;
- insufficient on-call coverage;
- missing service, abort, or recovery owner;
- observability maintenance that blinds a required signal;
- a security event or access-control uncertainty;
- material configuration drift since approval.

“Approved last Tuesday” is not a permanent license. Readiness is rechecked immediately before execution.

### Choose the smallest experiment that answers the question

| Uncertainty | First useful experiment | Bad first move |
|---|---|---|
| Can traffic leave an unhealthy replica? | remove one disposable backend from service in staging or canary | terminate half the production fleet |
| Does a client honor timeout and retry budgets? | introduce bounded latency in a test dependency path | add unbounded packet loss across a namespace |
| Can the team restore from backup? | isolated restore and invariant validation | corrupt the live primary |
| Does zone failover preserve the user journey? | tabletop, pre-production, then one bounded canary path | region-wide production isolation |
| Will an alert reach the responder? | synthetic signal through the notification path | break the customer service |
| Can a queue consumer recover after pause? | pause one canary consumer with a queue-age abort | stop all consumers during peak load |

The first experiment should maximize information gained per unit of exposure, not maximize drama.

### Progressive execution checkpoints

```text
T-30m  readiness review and target snapshot
T-10m  clean baseline and no conflicting change
T-0    approval token issued for exact plan digest
T+1m   fault application independently observed
T+2m   first invariant and guardrail review
T+5m   continue, hold, abort, or recover
T+n    fault expires or is stopped
R+0    recovery begins
R+n    invariants restored and observation window starts
Close  evidence sealed; actions assigned
```

At every hold, “continue” is a new decision. Silence is not consent.

### Classify the result honestly

| Outcome | Meaning | Next move |
|---|---|---|
| Supported within scope | predicted behavior occurred, signals were trustworthy, and recovery met its bound | retain evidence; consider one carefully larger scope |
| Contradicted | the system behaved differently from the prediction | reduce risk, create corrective work, rerun after change |
| Inconclusive | target, fault, baseline, telemetry, or confounder was uncertain | repair the design; do not claim resilience |
| Unsafe or aborted | a guardrail fired, scope drifted, control failed, or unplanned harm appeared | stop, recover, and handle as an incident if needed |

Do not say “passed chaos.” A supported result has a scope, time, version, load profile, topology, and known limitations. Change any of those and confidence decays.

### Decision record

Preserve the question, decision consumer, plan digest, approvals, resolved targets, exclusions, baseline, hypothesis, invariants, fault evidence, guardrail events, synchronized timeline, recovery proof, result classification, limitations, action owner, due date, and verification. This turns an exciting afternoon into durable engineering knowledge.

## Guided Ubuntu lab

This lab teaches the decision model locally. It does **not** inject latency, kill a process, alter networking, consume disk, call a cloud API, or touch Docker or Kubernetes. Run it as a normal Ubuntu user.

### What you will practise

The fixture contains 47 synthetic cases. Each removes or changes one piece of evidence: target resolution, ownership, hypothesis, business steady state, abort rehearsal, recovery proof, fault observation, evidence integrity, or another gate. The evaluator reports the first boundary that prevents a defensible experiment.

That first-boundary rule matters. When target inventory is unknown, later approvals cannot rescue the plan. Production review should also address the earliest unsafe assumption first.

### Step 0: enter the lesson directory

From the repository root:

```bash
cd drafts/LES-0075-chaos-engineering-safe-experiments-game-days/lab
pwd
```

Read `pwd`. It should end with this lesson's `/lab` directory. Do not paste commands into an unknown working directory.

### Step 1: inspect before execution

```bash
sed -n '1,240p' README.md
sed -n '1,280p' lab.sh
sed -n '1,260p' verify.sh
```

`sed -n '1,240p'` means “print lines 1 through 240 without editing.” Review for network calls, privileged commands, broad deletion, and hidden dependencies. You should find none.

Validate script syntax:

```bash
bash -n lab.sh
bash -n verify.sh
```

`bash -n` parses shell syntax without running the script body. A silent exit with code zero means valid syntax; it does not prove runtime behavior.

Optional, when ShellCheck is installed:

```bash
shellcheck lab.sh verify.sh
```

ShellCheck finds common quoting, expansion, and portability errors. It cannot prove business correctness.

### Step 2: inspect the safety model

```bash
bash lab.sh model
bash lab.sh doctor
```

Expected model output:

```text
model=valid cases=47 gates=46
```

Doctor should report a normal user identity, no required network, and satisfied commands. If it refuses because a credential-shaped environment variable is exported, open a fresh shell or unset only that named variable after confirming it is not needed. Never print the value.

### Step 3: create isolated state

```bash
bash lab.sh setup
bash lab.sh status
```

Setup uses:

```text
/tmp/reliability-atlas-les0075-chaos-<your numeric uid>
```

The numeric user ID prevents two users from sharing state. A sentinel gives cleanup positive proof that the directory belongs to this lab. Unknown files cause refusal because cleanup must not broaden its deletion target merely to succeed.

Run setup again:

```bash
bash lab.sh setup
```

It should refuse existing state. Idempotence does not always mean silently succeeding. For safety-sensitive setup, refusing ambiguous pre-existing state is correct behavior.

### Step 4: establish the good boundary

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

Read every field from `show`. Expected:

```text
case=baseline boundary=defensible-within-model expected=defensible-within-model
```

Do not translate that into “production safe.” It means only that every gate represented by this finite fixture is true.

Write three facts the model cannot prove. Examples:

- real target inventory is accurate at execution time;
- a production abort signal has adequate freshness;
- recovery restores customer and data invariants;
- required humans understand their roles;
- the fault mechanism has no undocumented behavior.

### Step 5: follow the first unsafe assumption

```bash
bash lab.sh evaluate selector-not-resolved
bash lab.sh show selector-not-resolved
```

The boundary is `target-inventory`. Later positive fields cannot justify executing against an unresolved selector.

Ask:

1. What immutable inventory should be recorded?
2. What can drift between approval and execution?
3. What component must refuse that drift?

A defensible answer records exact resource identities, compares approved and current target digests, and refuses or renews approval on difference.

### Step 6: distinguish a stop rule from stop capability

```bash
bash lab.sh evaluate abort-never-rehearsed
bash lab.sh evaluate stop-uses-failed-control-plane
bash lab.sh show stop-uses-failed-control-plane
```

The first case says the rule was never rehearsed. The second says the stop path shares the tested failure domain:

- **not rehearsed:** no evidence proves detection-to-cessation meets its time bound;
- **correlated:** the stop control may vanish because of the same injected condition.

For a real experiment, diagram both paths. If they share DNS, identity, cluster API, network, region, or operator workstation, record that correlation.

### Step 7: prove the intervention happened

```bash
bash lab.sh evaluate tool-green-fault-not-applied
bash lab.sh show tool-green-fault-not-applied
```

A controller may return success when the target disappeared, an agent rejected the action, the wrong path changed, or the effect was too small. Require a safe independent effect probe:

- observed latency on the exact path;
- process identity and start time before and after termination;
- reachability from a controlled second vantage point;
- replica membership or power state from a second plane.

The executor's own status is not independent evidence.

### Step 8: separate rollback from recovery

```bash
bash lab.sh evaluate rollback-ran-state-still-wrong
bash lab.sh show rollback-ran-state-still-wrong
```

The rollback ran, yet the boundary is `correct-state-restored`. In production, validate successful user operations, error and latency recovery, queue age, retry volume, data consistency, replica and route convergence, and a clean delayed-impact observation window.

Rollback is an action. Recovery is an evidenced state.

### Step 9: compare different boundaries

```bash
bash lab.sh list
bash lab.sh evaluate vague-hypothesis
bash lab.sh evaluate component-only-steady-state
bash lab.sh evaluate conflicting-change-active
bash lab.sh evaluate evidence-not-tamper-evident
bash lab.sh evaluate known-failure-not-experiment
```

For each result, write:

```text
first unsafe assumption:
evidence needed:
owner who can produce it:
refusal or remediation:
```

This worksheet trains the same motion used in a production approval review.

### Step 10: run the complete verifier

Clean your state, then let the verifier test the full lifecycle:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected:

```text
verify=pass cases=47 refusal=true cleanup=true
```

The verifier also creates an unknown artifact and proves cleanup refuses it. A negative-path test is more valuable than a script that proves only its happy path.

Confirm absence:

```bash
bash lab.sh status
```

If status reports unexpected inventory, inspect the exact per-user path. Do not run a broad recursive deletion.

### Proof boundary

The lab proves that this repository's finite model:

- validates an expected number of cases and gates;
- maps every case to its expected first boundary;
- refuses symlinked, unowned, unsentinelled, or unknown state;
- removes only allowlisted local files;
- has no declared network or privilege dependency.

It cannot prove any real chaos tool, cloud control, Kubernetes target, business SLI, recovery procedure, human role, or production environment. Transfer requires new evidence.

## Production transfer

The local lesson becomes production practice only when the organization builds a governed experiment system around real services.

### Build a resilience-question backlog

Start with evidence, not a catalog of faults:

- incidents and near misses;
- architecture assumptions;
- SLO misses and error-budget burn;
- dependency maps and critical user journeys;
- recovery procedures never exercised;
- changes in traffic, topology, data volume, or ownership;
- security, audit, and business-continuity controls.

“Test node failure” is an action. “Can checkout preserve its good-event ratio when one zone loses stateless workers, without duplicate payment authorization?” is a decision-bearing question.

Prioritize customer consequence, uncertainty, likelihood, age of evidence, recovery complexity, and containment feasibility. A score structures review; it does not replace business judgment.

### Treat the experiment definition as controlled code

A production specification needs fields like these:

```yaml
id: EXP-2026-042
question: Can checkout route around one unhealthy canary backend?
decision_consumer: checkout-platform-owner
service_version: sha256:...
environment: production-canary
targets:
  immutable_ids: [...]
  maximum_concurrent: 1
  exclusions: [...]
steady_state:
  business_query: ...
  threshold: ...
  freshness_seconds: 30
hypothesis: ...
fault:
  mechanism: ...
  maximum_duration_seconds: 120
abort:
  signal: ...
  threshold: ...
  window: ...
  deadline_seconds: 30
recovery:
  owner: ...
  procedure_version: ...
  deadline_seconds: 300
approvals: [...]
evidence_retention: ...
```

The schema differs by organization, but reviews, versioning, immutable digests, and policy checks should not. Approval applies to the reviewed digest. A changed target, threshold, mechanism, or duration invalidates it.

### Separate planes and privileges

```text
author/reviewer plane
        |
        v
policy + approval plane ----> append-only audit evidence
        |
 short-lived scoped authority
        v
execution plane -----------> target plane
        |
        +-------------------> effect telemetry

independent safety plane ---> stop / expiry / recovery escalation
```

Apply least privilege:

- an author does not silently self-approve high-risk production work;
- the executor can perform only approved actions on approved resources;
- credentials are short-lived and bound to environment and target;
- stop authority remains simple and preferably outside the injected failure domain;
- evidence cannot be rewritten by the same principal that executed the experiment;
- emergency access is audited and expires.

Never place cloud keys, kubeconfigs, bearer tokens, private endpoints, or credentials in the plan, transcript, manuscript, or CI log.

### Establish a promotion ladder

```text
reasoning review
 -> tabletop
 -> simulator or component test
 -> disposable local environment
 -> integration environment
 -> production-like staging
 -> one production canary or tenant
 -> bounded production slice
 -> broader scope only when justified
```

Promotion is not automatic. Some questions can be answered fully before production. Others need production because of unique topology, scale, data gravity, or human response paths. Document why production evidence is necessary and why the proposed scope is the smallest capable of answering the question.

### Resolve and freeze targets just in time

Immediately before execution:

1. resolve selectors;
2. compare exact inventory with approval;
3. verify ownership, environment, region, tenant, and exclusions;
4. confirm maximum concurrent targets;
5. confirm no topology or release drift;
6. produce a target digest;
7. require renewed approval on material difference.

The execution layer enforces scope. A dashboard warning is not an enforcement boundary.

### Prove observability before injecting

Preflight must verify:

- baseline queries return enough fresh samples;
- business and technical signals can be interpreted together;
- alert routing reaches the expected responder;
- clocks are synchronized;
- trace, log, metric, event, deployment, and experiment identifiers correlate;
- dashboards do not aggregate away the canary or tenant;
- queries survive the proposed failure;
- evidence retention and access are configured.

If the experiment can break telemetry, add an outside vantage point. Missing telemetry during a fault is not evidence of no impact.

### Execute with a live control loop

| Role | Responsibility |
|---|---|
| Experiment lead | maintains the timeline and enforces holds |
| Service owner | interprets system and business behavior |
| Executor | performs only approved actions |
| Safety or abort owner | watches guardrails and can stop without debate |
| Recovery owner | restores and validates correct state |
| Incident commander | takes over if the exercise becomes an incident |
| Scribe | records decisions, timestamps, evidence, and deviations |

One person may fill several roles only when risk and workload allow it. The executor must not be the only observer, abort authority, recovery operator, scribe, and success judge.

At each checkpoint announce:

```text
current target and scope
fault state
steady-state result
guardrail state
remaining duration
continue / hold / abort / recover
decision owner and timestamp
```

### Know when a game day becomes an incident

Predeclare handoff conditions:

- impact escapes approved scope;
- a customer-facing abort threshold is crossed;
- recovery exceeds its deadline;
- data correctness is uncertain;
- control or observability is lost;
- an unrelated incident begins;
- security boundaries may have been crossed.

Then stop calling the event an experiment. Activate incident response, prioritize restoration, protect evidence, and never extend the fault merely to finish the script.

### Close with durable learning

The review must:

- reconstruct one synchronized timeline;
- separate injected conditions from unrelated contributors;
- classify the result honestly;
- record scope and validity limitations;
- create corrective actions with owners and deadlines;
- define verification evidence;
- schedule a regression experiment;
- update runbooks, architecture, alerts, capacity models, and training;
- retire experiments whose question is obsolete.

The output is not “we completed a game day.” The output is a changed decision, a stronger control, or explicitly reduced uncertainty.

### Regression and confidence decay

An old successful result does not certify a service forever. Confidence decays when service versions, dependencies, topology, traffic, data volume, alert queries, ownership, recovery tools, or credentials change—or when an incident contradicts the model.

Automate low-risk regression experiments only after they have deterministic scope, stable signals, enforced aborts, safe cleanup, and an accountable owner. Continuous chaos without continuing ownership becomes unattended production change.

## Reliability, security, observability, capacity, and cost

Chaos engineering touches every operating discipline. A technically correct fault can still be a bad experiment when one of these dimensions is ignored.

### Reliability: test promises, not components

A service exists to complete user work. Its steady state should therefore begin with a service-level indicator:

```text
good-event ratio =
  events meeting the user promise
  / all eligible events
```

Examples include successful authorized payments without duplication, searches returning a valid result within a latency bound, or accepted jobs completing before a deadline. CPU, pod readiness, and replica count explain behavior; they are not the promise.

Connect the experiment to SLO policy. A production experiment consumes some risk capacity even if it creates no incident. Define a separate experiment exposure budget so “error budget remains” is not treated as unlimited permission. When the service is already burning budget rapidly, adding controlled failure usually reduces learning quality and increases harm.

Test degraded modes as first-class behavior:

- load shedding before collapse;
- bounded retries with jitter and budgets;
- queues with visible age and backpressure;
- stale or read-only modes with explicit semantics;
- circuit breakers that recover without synchronized storms;
- failover that preserves correctness, not only availability;
- restoration from backup, not merely successful backup jobs.

The strongest reliability finding is often not “redundancy worked.” It is “the user promise remained true, saturation stayed bounded, and state converged within the recovery objective.”

### Security: a fault injector is privileged automation

Treat the executor as a sensitive production system. It may terminate workloads, alter routes, throttle resources, or revoke access. Compromise or misconfiguration can resemble a destructive insider.

Required controls include:

- deny-by-default policy and explicit environment allowlists;
- immutable target scope and maximum concurrency;
- short-lived workload identity instead of stored keys;
- separation of author, approver, executor, and auditor where risk warrants it;
- signed or digest-bound plans;
- append-only audit events;
- protected stop and recovery authority;
- egress and API restrictions;
- dependency and artifact provenance;
- secret redaction from commands, logs, evidence, and screenshots.

Also model security behavior under stress. Failures can cause fail-open authorization, bypassed validation, overly broad emergency access, missing audit records, or plaintext fallback. A service that stays available by violating confidentiality or integrity has failed.

Do not inject into a control whose security consequence is not understood. For example, disabling identity infrastructure can create cached authorization, break-glass, or token-refresh behavior that persists after the fault ends.

### Observability: create an evidence chain

One dashboard is not enough. Build five layers:

| Layer | Question |
|---|---|
| Baseline | Was the system healthy and stable before the intervention? |
| Application | Did the intended fault actually reach the intended target? |
| User effect | Did the critical journey preserve its promise? |
| Guardrails | Did any safety, security, data, or capacity boundary fire? |
| Recovery | Did state return to correct behavior and remain there? |

Every signal needs an owner, unit, source, query, window, freshness limit, expected cardinality, and missing-data rule. “No data” must never silently evaluate as “healthy.”

Use a shared experiment identifier in controller events, deployment annotations, logs, traces, and timeline notes where supported. Synchronize clocks. Preserve raw evidence or immutable query references, not just screenshots whose query and time range cannot be reproduced.

Beware observer effect. Extra tracing, packet capture, or high-cardinality labels can change latency and resource use. Verify telemetry overhead at the proposed scale.

### Capacity: degraded systems have different demand

Failure changes both supply and demand. Losing one of four equal workers does not merely remove 25 percent of capacity. Retries, rebalancing, cache misses, failover connections, leader election, compaction, recovery jobs, and operator queries can add load.

Reason about headroom:

```text
degraded_utilization =
  (normal_demand + failure_amplification + recovery_demand)
  / remaining_healthy_capacity
```

If normal demand is 600 requests per second, failure amplification adds 120, recovery adds 80, and remaining capacity is 800, degraded utilization is 100 percent. A design that appeared to have 25 percent spare capacity has none during recovery.

Measure:

- request and retry rate;
- queue depth and oldest-item age;
- concurrency and connection pools;
- CPU throttling, memory pressure, disk and network saturation;
- cache hit rate and warm-up duration;
- autoscaler detection and provisioning delay;
- failover and data-rebuild bandwidth;
- downstream rate limits.

Choose aborts before the nonlinear knee, not at total exhaustion. A latency curve often rises sharply before utilization reaches a nominal 100 percent.

### Cost: bound both direct and indirect spend

A safe experiment still has economic impact:

- temporary duplicate capacity;
- telemetry ingestion and high-cardinality storage;
- cross-zone or cross-region transfer;
- restored databases and snapshots;
- vendor chaos-tool execution;
- staff preparation, exercise, and review time;
- customer credits or lost transactions if containment fails;
- recovery compute and backlog processing.

Estimate an upper bound:

```text
experiment_cost_ceiling =
  temporary_resources
  + telemetry
  + data_transfer
  + recovery
  + expected_business_exposure
```

Cost is a guardrail, not a reason to hide risk. A smaller well-designed experiment can answer the same question for less money and less exposure. Conversely, skipping recovery validation to save temporary infrastructure may preserve an expensive unknown.

### Cross-cutting decision example

Consider removing one canary payment worker:

| Dimension | Precondition | Abort or refusal |
|---|---|---|
| Reliability | duplicate-free payment success SLI is fresh | good-event ratio crosses agreed boundary |
| Security | executor can affect only the immutable canary ID | scope or identity digest differs |
| Observability | fault effect and user path have separate evidence | either signal is stale or missing |
| Capacity | remaining pool handles modeled retries and recovery | queue age or saturation crosses early threshold |
| Cost | telemetry and temporary headroom fit the approved ceiling | spend or data-transfer alarm exceeds bound |

This is systems thinking: the same action is safe or unsafe depending on the evidence and controls around it.

## Traps and prevention

### Trap 1: begin with the tool

“We installed a chaos platform; what can we kill?” reverses the problem.

**Prevention:** maintain a resilience-question backlog sourced from incidents, SLOs, recovery gaps, and architecture assumptions. Choose a mechanism only after the question and smallest valid intervention are clear.

### Trap 2: write a vague hypothesis

“The service should survive” cannot be falsified because `survive` has no metric, window, load, or correctness condition.

**Prevention:** use condition, prediction, invariant, bound, and time:

```text
Given <baseline and load>, when <bounded condition>,
we predict <observable user behavior> remains within <threshold>
for <window>, and correct state returns within <recovery bound>.
```

### Trap 3: watch only component health

All pods may be Ready while customers receive stale, duplicate, unauthorized, or slow responses.

**Prevention:** put the critical user journey first; use infrastructure signals to explain its behavior.

### Trap 4: trust a selector

A familiar label can select more resources tomorrow because of autoscaling, deployment changes, or a typo.

**Prevention:** resolve to immutable inventory just in time, compare the approved digest, enforce concurrency, and refuse drift.

### Trap 5: confuse a stop command with a stop system

An untested button using the same failed API is comfort, not control.

**Prevention:** specify signal-to-cessation time, rehearse it, independently observe cessation, and map correlated dependencies.

### Trap 6: choose abort thresholds during the run

Moving a threshold after seeing impact biases the result and prolongs harm.

**Prevention:** approve numeric thresholds, windows, missing-data behavior, and decision authority beforehand. A stricter emergency stop is always allowed.

### Trap 7: equate rollback with recovery

Automation reports success while queues, routes, leases, or data remain wrong.

**Prevention:** declare recovery only from business, correctness, saturation, and convergence invariants over an observation window.

### Trap 8: test a known failure

The team already knows a backup cannot restore, yet schedules a destructive production test.

**Prevention:** repair the known defect first. Use an isolated recovery rehearsal to validate the fix.

### Trap 9: start in production for realism

Production has realism and consequence. It is not automatically the best first evidence source.

**Prevention:** climb the promotion ladder and document which uncertainty remains unanswered at each safer stage.

### Trap 10: make the game day a surprise

Surprise can evaluate human response but can also create unsafe confusion, violate change policy, and corrupt evidence.

**Prevention:** use planned learning game days first. Run unannounced exercises only under an explicitly governed program with trained leaders, safe stop authority, and stakeholder consent.

### Trap 11: measure success by faults injected

Counting terminated pods rewards activity and larger blast radius.

**Prevention:** measure decision-changing findings, verified corrections, reduced recovery time, closed evidence gaps, and safe repeatability.

### Trap 12: automate a stale experiment forever

Targets, owners, thresholds, and architecture change while a scheduled job retains old authority.

**Prevention:** add evidence expiry, owner attestation, plan digest checks, change-triggered review, and an automatic disabled state when preconditions drift.

### Trap 13: infer causality from coincident graphs

Latency rose during the experiment, therefore the injected condition caused it.

**Prevention:** preserve comparable baseline, change events, target-effect evidence, timestamps, and confounders. Classify as inconclusive when causality is not supportable.

### Trap 14: hide a real incident inside the exercise

Teams keep following the game-day script after scope escapes or recovery fails.

**Prevention:** predeclare incident handoff. The incident commander supersedes the experiment lead, and restoration outranks completion.

### Trap 15: publish sensitive evidence

Experiment output exposes internal addresses, tenant identifiers, credentials, or security controls.

**Prevention:** classify evidence, redact secrets at source, use restricted stores, minimize retained sensitive fields, and audit access.

## Memory card and retrieval

Remember this sentence:

> Ask a decision-bearing question, bind the target and exposure, watch the user promise, stop independently, prove recovery, and preserve learning.

Use the mnemonic **Q-B-W-S-R-L**:

| Letter | Recall prompt |
|---|---|
| Q — Question | What uncertainty changes a decision? |
| B — Bound | What exact target, duration, authority, and blast radius? |
| W — Watch | Which business invariant, effect probe, and guardrail? |
| S — Stop | Who stops, through what path, within what time? |
| R — Recover | What evidence proves correct state returned? |
| L — Learn | What changed, who owns it, and how will it be verified? |

### Thirty-second production card

```text
Before:
  known question? fresh baseline? immutable target?
  approved scope? independent stop? rehearsed recovery?

During:
  fault actually applied? user promise intact?
  guards fresh? scope unchanged? next hold decision?

After:
  fault ceased? rollback ran? correct state restored?
  evidence sealed? actions owned? regression scheduled?
```

### Symptom-to-first-check card

| What you see | First check | Why |
|---|---|---|
| Controller says success; no service change | independent effect probe | the intervention may not have happened |
| Business SLI drops but pods look healthy | user-path traces and correctness | component health does not define success |
| Stop command sent; impact continues | cessation evidence and control dependencies | intent is not actuation |
| Rollback job green; queue age rises | recovery invariants | rollback is not recovery |
| Different targets than review | target digest and selector resolution | approval scope has drifted |
| Metrics disappear | missing-data policy and outside vantage point | absence may mean blindness |
| Result changes between runs | load, version, topology, and confounders | the comparison may be invalid |

### Retrieval practice

Without looking back, answer:

1. Why is a known defect usually not a chaos experiment?
2. Why does the target need immutable identity?
3. Name the three unequal states: fault ended, rollback completed, and what?
4. What must be independent of the executor's success report?
5. When must a game day become an incident?
6. What does “supported within scope” deliberately avoid claiming?

If an answer is weak, return to the corresponding Q-B-W-S-R-L row, not to a random tool tutorial.

## Complete answers

### 1. What is chaos engineering, and how is it different from fault injection?

Fault injection is an action: terminate a process, add latency, block a route, exhaust a quota, or revoke a permission. Chaos engineering is the controlled evidence loop around an intervention.

A chaos experiment starts with an uncertainty that matters to a decision. It defines a measurable steady state, a falsifiable hypothesis, an exact target and intervention, comparison evidence, bounded exposure, independent guardrails, abort and recovery, then classifies and preserves the result. Fault injection without that loop may be testing, demonstration, or uncontrolled change.

The distinction matters because a tool can report “Completed” while the wrong target was selected, the intended effect never occurred, customers failed, or state remained corrupt. The action report proves only a narrow controller fact.

### 2. How do a resilience test, drill, tabletop, game day, and chaos experiment differ?

- A **test** verifies a known expectation and normally has a predetermined assertion.
- A **drill** rehearses a known procedure, such as restoring a backup or failing over a database.
- A **tabletop** walks humans through a scenario without changing the real system.
- A **game day** coordinates people, systems, communications, and decisions across a planned scenario.
- A **chaos experiment** evaluates a falsifiable hypothesis under a controlled condition.

They can be combined. A game day might contain a tabletop, an alert drill, a recovery test, and one bounded chaos experiment. Calling the entire event “chaos” must not blur which evidence came from which activity.

### 3. Why must the hypothesis be falsifiable?

A statement such as “the platform remains healthy” cannot tell an operator what observation disproves it. Healthy for whom? Which operation? At what load? Over which window? What latency, correctness, security, and recovery bounds apply?

A falsifiable form is:

```text
Given normal canary traffic and a healthy baseline,
when one immutable checkout backend becomes unreachable for at most 120 seconds,
the load balancer removes it within 15 seconds,
eligible checkout success remains at or above 99.0%,
duplicate authorizations remain zero,
and all backlogs return within tolerance in five minutes.
```

Each clause has a possible contradicting observation. That lets the team learn instead of reinterpret the goal after seeing the graphs.

### 4. What is steady state, and why is average CPU not enough?

Steady state is a measurable description of the important behavior before, during, and after the condition. It usually includes user outcome, correctness, security, saturation, and recovery—not one static infrastructure number.

Average node CPU can stay low because requests are failing before useful work begins. It can also hide one overloaded node behind many idle nodes. A payment service can report healthy CPU while creating duplicate attempts.

A stronger checkout steady state includes eligible-request population, success ratio, latency percentile, duplicate-payment invariant, authorization correctness, queue age, saturation, missing-data behavior, and time windows. CPU is supporting evidence that helps explain the outcome.

### 5. Why use a control population?

A contemporaneous control helps distinguish the intervention from workload changes, dependency incidents, deployments, or market events occurring at the same time.

For example, keep one equivalent canary cohort untreated while another receives bounded latency. Compare versions, configuration, traffic composition, topology, tenant mix, and starting health. If both cohorts degrade, the injected condition may not be the cause.

A control improves attribution but does not guarantee causality. Hidden selection bias and shared dependencies can affect both groups. Record those limitations. When a true control is impossible, explain why and use the strongest available baseline rather than pretending before/after comparison is equivalent.

### 6. Why is a dynamic selector unsafe as the approval boundary?

Selectors express a rule, not a fixed inventory. Their members can change because of label drift, autoscaling, deployment, namespace reuse, or operator error. Approval for “two checkout pods” can silently become authority over payment adapters or migration jobs.

Resolve the selector immediately before execution. Preserve immutable identities, count, environment, region, owner, and exclusions. Compute a digest and compare it with the approved target set. The executor must refuse or request renewed approval when membership changes.

The important control is enforcement. A reviewer noticing a broad selector in a dashboard is weaker than an executor identity and policy that cannot affect anything else.

### 7. What makes blast radius truly bounded?

Blast radius has multiple axes:

- exact number and identity of targets;
- traffic or tenant fraction;
- region, zone, namespace, account, and failure domain;
- duration and automatic expiry;
- concurrency and rate of interventions;
- data class and side-effect potential;
- dependency propagation;
- authority available to the executor;
- recovery capacity and time.

“Only 10 percent” can still be unsafe if it includes all quorum members in one zone or a high-value tenant. Define worst credible behavior, not only intended behavior. Use synthetic traffic and data when real exposure adds no necessary learning. Start with the smallest scope that can produce an observable answer.

### 8. What makes an abort mechanism credible?

A credible abort mechanism has a signal, threshold, window, missing-data rule, decision owner, maximum detection-to-cessation time, actuation path, and independent proof that injection stopped.

It is rehearsed before the higher-risk run. The rehearsal measures the complete chain:

```text
condition occurs
 -> probe observes it
 -> rule evaluates
 -> stop is authorized
 -> executor ceases new actions
 -> existing effect expires or reverses
 -> independent probe confirms cessation
```

A button is not credible if it uses the same cluster API, identity provider, DNS, network, region, or workstation that the experiment can impair. Perfect independence may be impossible; name and mitigate correlation.

### 9. Why are rollback and recovery different?

Rollback is an attempted reversal: recreate a pod, restore a route, remove a latency rule, or revert configuration. Recovery is the observed return of correct system behavior.

A recreated process can have cold caches, lost leases, stale routes, unprocessed queues, duplicated side effects, or inconsistent data. Therefore a rollback log proves only that an action was attempted or completed according to its tool.

Recovery requires separate evidence: the critical user journey succeeds, correctness and security invariants hold, saturation and retries subside, backlogs drain, topology converges, and an observation window finds no delayed damage. Recovery also needs an accountable declarer and deadline.

### 10. When should a planned exercise become an incident?

Convert immediately when unplanned customer, data, security, or availability impact appears; scope escapes; control or telemetry is lost; an abort threshold fires; recovery misses its bound; or an unrelated incident begins.

The incident commander then owns priorities. Stop the intervention through the safest available path, preserve evidence without delaying restoration, halt conflicting change, communicate impact, and follow normal severity and escalation procedures. The experiment script is no longer the authority.

This boundary protects teams from sunk-cost thinking: “We already started, so let us finish the scenario.” Once reality exceeds the approved envelope, restoration and safety outrank learning.

### 11. When is an inconclusive result useful?

Inconclusive means the evidence cannot support or contradict the hypothesis. The target may have drifted, the fault may not have applied, baseline may be unstable, telemetry may be missing, or a concurrent change may dominate.

It is useful when the team records the exact inference failure and improves it: add an independent effect probe, freeze deployments, repair signal freshness, establish a comparable control, or make target binding deterministic. The next run can then produce stronger evidence.

It is not acceptable to relabel inconclusive as success because no obvious outage occurred. Lack of trustworthy observation is uncertainty, not resilience.

### 12. Why should a known failure usually not be injected?

Chaos engineering is valuable when uncertainty justifies controlled exposure. If evidence already shows the system violates a safety, correctness, or SLO boundary, deliberately reproducing customer harm yields little new information.

Create and prioritize corrective work. Validate the repair with the lowest-risk useful method: unit or component test, isolated restoration, synthetic nonproduction traffic, or a disposable environment. A later bounded experiment can test the corrected mechanism and interaction.

An exception may exist for an explicitly governed response drill in isolated infrastructure, where the purpose is to rehearse people or recovery—not to rediscover the defect.

### 13. How should data correctness be protected during an experiment?

Name the domain invariant before injection: one authorization per idempotency key, no acknowledged write lost, balances conserved, ordering preserved, or replicated state converges.

Prefer synthetic identities and data. Bound the tenant, partition, write volume, retention, and downstream consumers. Confirm backups or snapshots are restorable when relevant, but do not treat backup completion as recovery proof. Prepare reconciliation queries using stable business identity, not timestamp-only guesses.

Continuously watch duplicates, missing records, unauthorized transitions, dead letters, replication lag, and checksum or ledger invariants. Any unexpected correctness effect triggers incident handling. After rollback, reconcile, drain, validate, soak, and preserve audit evidence.

### 14. What does least privilege look like for a chaos executor?

The executor receives a short-lived identity able to inspect and apply only the approved action against exact approved resources. It cannot enumerate or mutate unrelated environments, change its own policy, alter evidence, or grant itself more access.

Approval and execution are separated where risk warrants it. The plan digest, target digest, time window, maximum concurrency, and action type are policy inputs. Stop authority is separately reachable. Every call is attributable and retained in protected audit evidence.

`cluster-admin`, subscription owner, or unrestricted SSH may be convenient, but they convert a selector or script bug into platform-wide blast radius. Convenience is not a safety argument.

### 15. How do you design a useful game day?

Begin with two or three learning objectives grounded in real risk. Define the systems, critical flows, roles, dependency owners, support communications, scenario boundaries, stop conditions, and incident handoff. Conduct a tabletop first so basic confusion does not consume the live window.

Use a planned timeline with holds, but allow the system and participants to reveal gaps. The exercise lead controls progression; the safety owner can stop without debate; the scribe captures decisions; service and dependency owners interpret evidence; incident command takes over on real impact.

Debrief system behavior, procedure, tooling, authority, communications, and assumptions. A game day succeeds when it safely reveals and closes important gaps—even if the hypothesis is contradicted or an abort works. Completing every scripted fault is not the goal.

### 16. Diagnose the checkout experiment described in the diagnostic assessment

The proposal is not defensible. “The platform remains healthy” is not falsifiable. Average node CPU is not the checkout promise, and controller `Completed` proves only controller state. The actual label resolves to checkout, payment-adapter, and migration pods, so the authorized target is already false. A concurrent deployment destroys attribution. Cluster-wide authority violates least privilege. The stop path is correlated with the impaired Kubernetes API. The abort was not rehearsed. Support cannot report hidden customer impact. Recreating pods reverses infrastructure but does not reconcile duplicate payment attempts.

Once checkout errors and duplicate payment attempts rise, stop the experiment and enter incident command. Use an independent authorized path to cease injection, freeze conflicting change, preserve the exact plan, resolved inventory, action receipts, deployment events, telemetry, and transaction evidence. Contain retry or consumer behavior that creates further duplicates without destroying reconciliation evidence. Establish one authoritative payment outcome by business identity and idempotency records. Reconcile side effects, validate the full checkout and payment flow, prove queues and saturation recover, and confirm experiment artifacts are gone.

Redesign around a critical flow: one authorized checkout produces one durable, nonduplicated payment outcome. Define eligible population, success and latency tolerances, duplicate invariant, queue and capacity bounds, and a recovery deadline. Name a realistic fault and mitigation mechanism. Freeze unrelated change or create equivalent control and treatment cohorts.

Begin in disposable nonproduction with synthetic data, then one canary target. Resolve immutable identities and bind approval to the target and plan digests. Give the executor narrow temporary authority. Watch user, correctness, security, component, and capacity signals continuously from paths that survive the fault. Rehearse abort, prove cessation, test rollback, and separately validate recovery. Inform on-call, dependency owners, and support. Expand only when evidence at the smaller scope justifies it.

Do not run when baseline is unhealthy, a known defect already violates the promise, target or authority is ambiguous, a concurrent critical change exists, observability or independent stop is unavailable, capacity is insufficient, recovery is unproved, key roles are absent, or residual risk exceeds learning value.

### 17. What exactly can a successful experiment claim?

It can claim that under the recorded version, topology, target set, fault mechanism, load, time window, telemetry coverage, and controls, the observed behavior supported the stated hypothesis and recovery bounds.

It cannot prove universal resilience, every tenant, every fault intensity, every correlated dependency, future versions, or effects outside the observation window. The experiment might also have blind spots that survived review.

Use “supported within scope” and list limitations. This language is not timid; it is scientifically honest and tells future engineers when evidence must be renewed.

### 18. Should successful experiments be automated continuously?

Only some. Stable deterministic assertions may become component, integration, recovery, or deployment regression tests. Repeated low-risk chaos experiments may be useful where interactions and topology keep changing.

Automation requires maintained ownership, exact dynamic targeting, policy enforcement, stable business signals, rehearsed abort, safe automatic expiry, cleanup, evidence retention, change-triggered review, and automatic disablement when preconditions drift.

If nobody is accountable for the question or reviews the evidence, a recurring experiment is merely privileged unattended change. Retire it or convert it into a cheaper test.

## Product-company interview

### Scenario 1: leadership asks you to “prove the platform is resilient”

**Weak answer:** Install a chaos tool, terminate random pods, and show that Kubernetes restarts them.

**Senior answer:** I would first turn “resilient” into a decision and a bounded service promise. Which critical journey, failure mode, load, correctness invariant, and recovery objective matter? I would derive a realistic uncertainty from incidents or architecture, define a falsifiable hypothesis and comparable control, then choose the smallest intervention that can answer it. Exact targets, least privilege, fresh independent user signals, rehearsed abort, recovery validation, and incident handoff are preconditions. A supported result is limited to the recorded version, scope, fault, and evidence; it is not universal proof.

### Scenario 2: a Kubernetes chaos tool reports Completed, but customers saw errors

**Senior answer:** Tool completion is a controller fact, not service success. I inspect the resolved target inventory, independent fault-effect probe, experiment and deployment timeline, user SLI, correctness and security signals, abort events, and recovery evidence. Customer impact outside the approved bound converts the run into an incident. I stop through the safest independent path, preserve evidence, restore and reconcile, then classify the hypothesis as contradicted or the run as unsafe—not successful. I correct target, observability, abort, and recovery controls before any rerun.

### Scenario 3: design a production experiment for losing one availability zone

**Senior answer:** I do not begin by blocking a zone. I map the user flow, state authority, zonal and regional shared dependencies, quorum, load balancers, identity, DNS, telemetry, and remaining capacity including retry and recovery amplification. I test routing and recovery mechanisms at component and staging levels first. If production evidence remains necessary, I use a representative canary cohort and the smallest zonal slice, exact immutable targets, a contemporaneous control, short automatic expiry, independent outside-region guardrails, predeclared customer and capacity aborts, and proven writer safety. I stage scope only after each hold. I refuse if headroom, telemetry, stop, recovery, or dependency-owner consent is missing.

### Scenario 4: how would you run a payment-service game day?

**Senior answer:** The primary promise is correct money movement, not pod availability. I define idempotency, authorization, ledger conservation, duplicate and missing-event invariants plus latency and queue bounds. Synthetic identities and data are preferred. Security, fraud, database, queue, customer-support, platform, and incident-response owners participate. We tabletop the scenario and rehearse stop and reconciliation first. A bounded exercise proves the intervention effect independently, watches every invariant continuously, converts any unexpected correctness effect to an incident, then validates rollback, reconciliation, backlog drain, sustained flow, and cleanup. Findings receive owners, acceptance evidence, and a retest.

### Scenario 5: a team wants a weekly automated random-failure job

**Senior answer:** Randomness and frequency do not create learning. I ask which maintained uncertainties the job addresses and which decision consumes each result. For every retained experiment, the target resolver, plan digest, policy, business signals, automatic expiry, abort, recovery, evidence, and owner must remain current. Material architecture or ownership drift disables execution. Stable known expectations should become cheaper deterministic regression tests. If there is no question, review, or action loop, I remove the recurring privileged change.

### Scenario 6: an abort alarm uses the monitoring system being disrupted

**Senior answer:** That is a correlated safety path. I model the observation, evaluation, authorization, actuation, and confirmation dependencies. I add an outside vantage point or separately hosted safety controller, plus a duration-bound action or local expiry that does not require the impaired monitoring plane. I define missing telemetry as stop rather than healthy, rehearse detection-to-cessation time, and independently prove the effect ended. If sufficient independence cannot be achieved, I move the experiment to a safer environment or refuse it.

### Scenario 7: the hypothesis is disproved, but the abort and recovery work perfectly

**Senior answer:** That can be a valuable, safely controlled experiment. I preserve the unchanged hypothesis, exact scope, observations, and limitations; create corrective work for the failed mechanism; recognize the safety system as supported only within its tested scope; and validate the repair with an acceptance test and rerun. I do not call the service resilient or call the game day a failure. The scientific result is contradiction; the operational result is controlled learning.

### Scenario 8: a recovery action finishes, but queue age continues to climb

**Senior answer:** The rollback completed; the service did not recover. I stop expansion, inspect producers, consumers, retries, poison messages, leases, downstream throttles, and remaining capacity. If the queue or user guardrail crossed its boundary, incident command owns restoration. I may add consumers only within safe downstream capacity, isolate duplicate-producing paths, and reconcile domain effects. Recovery is declared after queue age trends toward baseline, user and correctness invariants pass, saturation remains bounded, and the soak window is clean.

### What interviewers are evaluating

Strong answers:

- start with uncertainty, user promise, and the decision;
- distinguish tool action from independent system evidence;
- resolve actual targets and model failure domains;
- bind authority and exposure;
- make abort, incident conversion, and recovery explicit;
- protect data and security during degradation;
- reason about retries, headroom, and cost;
- classify evidence without overclaiming;
- convert learning into owned verified change.

Listing tools is not systems thinking. Interviewers want to hear how you prevent an experiment from becoming an uncontrolled incident and how you know what the result means.

## Independent transfer and rubric

### Reviewer-owned challenge

On reviewer-owned disposable local infrastructure with synthetic data and no public or production target, design and execute an unfamiliar controlled resilience experiment and associated tabletop or game-day response.

The reviewer secretly injects one target-scope expansion, one misleading steady-state or green-tool signal, one correlated abort or rollback dependency, one persistent correctness or security effect, and one organizational communication or authority failure. You must detect, contain, and explain the conditions without accessing answer material.

No solution, expected boundary, case mapping, hidden fixture, or model answer is provided here. The reviewer retains stop authority, scoring, and cleanup confirmation.

### Safety boundary

- Use only reviewer-owned disposable local infrastructure and synthetic identities and data.
- Do not use production, a public endpoint, an external cloud resource, a real credential, a customer record, uncontrolled load, or a host-wide fault.
- Refuse unknown artifacts, ambiguous authority, missing required telemetry, target drift, or unsafe cleanup.
- Do not alter the hypothesis, thresholds, target policy, or success criteria after observing the result.
- Convert any unexpected user, correctness, data, or security effect into incident handling.

### Required evidence

Submit:

1. named uncertainty, decision, critical flow, user, correctness and security promise, and explicit no-run conditions;
2. architecture, dependency, failure-domain, state-authority, and experiment-control map;
3. versioned falsifiable hypothesis naming fault, target, mitigation, quantified tolerance, and recovery deadline;
4. steady-state specification with populations, windows, thresholds, missing-data behavior, and comparable control;
5. failure-mode rationale and exact pre-run target inventory with immutable identities;
6. safety plan covering environment, synthetic data, blast radius, duration, concurrency, capacity, privilege, and approvals;
7. independent observability, guardrail, abort, stop, rollback, recovery, reconciliation, and exact cleanup design;
8. role and communication plan covering service owner, experiment lead, stop authority, incident command, recorder, dependency owners, and support;
9. dry-run and preflight evidence for baseline, control, target, authority, telemetry, capacity, and recovery readiness;
10. timestamped execution journal proving actual intervention effect and continuous guard evaluation;
11. evidence detecting and safely handling all reviewer-injected conditions;
12. unchanged hypothesis evaluation classified as supported, contradicted, or inconclusive with limitations;
13. rollback attempt plus separate correct-state, backlog, security, soak, and cleanup evidence;
14. blameless review with prioritized findings, owners, acceptance tests, retest plan, and regression decision.

### Scoring rubric

| Criterion | Points | Observable evidence |
|---|---:|---|
| Purpose, flow, and refusal | 10 | decision-changing uncertainty, promises, risk, and no-run boundaries |
| Hypothesis and steady state | 10 | falsifiable mechanism/outcome statement with quantified tolerances |
| Control and attribution | 10 | comparable cohorts, visible confounders, and bounded limitations |
| Target and fault scope | 10 | realistic fault plus exact target, duration, concurrency, and identity |
| Safety and authority | 10 | isolation, synthetic data, least privilege, approvals, and independent stop |
| Guardrails and recovery | 10 | rehearsed probes, abort, rollback, reconciliation, soak, and cleanup |
| Execution evidence | 10 | preflight, actual effect, timestamps, observations, and safe defect handling |
| Inference quality | 10 | supported, contradicted, or inconclusive without moving criteria |
| Organization and incident response | 10 | roles, communications, dependencies, support, and incident conversion |
| Learning and prevention | 10 | owned findings, acceptance tests, retest or regression, and residual risk |

Mastery requires reviewer-observed evidence, 80/100 or higher, no safety-gate failure, and no zero in target scope, safety and authority, guardrails and recovery, or execution evidence. A written claim without its artifact receives no evidence credit.

## References and review

### Primary sources

- **REF-0883** — [Principles of Chaos Engineering](https://principlesofchaos.org/). Used for steady state, falsifiable hypotheses, realistic variables, continuous experimentation, and minimized blast radius.
- **REF-0884** — [AWS Well-Architected: test resiliency using chaos engineering](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_testing_resiliency_failure_injection_resiliency.html). Used for failure selection, user-facing steady state, hypothesis, scope, stop, restoration, and evidence.
- **REF-0885** — [AWS Well-Architected: conduct game days regularly](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_testing_resiliency_game_days_resiliency.html). Used for people, process, technology, stakeholder communication, and follow-through.
- **REF-0886** — [AWS Fault Injection Service stop conditions](https://docs.aws.amazon.com/fis/latest/userguide/stop-conditions.html). Used for alarm-backed stop semantics and the boundary between stopping injection and proving recovery.
- **REF-0887** — [What is Azure Chaos Studio?](https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-overview). Used for target, scenario, report, game-day, and continuous-validation concepts.
- **REF-0888** — [Permissions and security in Azure Chaos Studio](https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-permissions-security). Used for execution identity, target capability, start permission, and least privilege.
- **REF-0889** — [Google Cloud: perform testing for recovery from failures](https://docs.cloud.google.com/architecture/framework/reliability/perform-testing-for-recovery-from-failures). Used for recovery-path exercises and operational readiness.
- **REF-0890** — [Google SRE: Testing for Reliability](https://sre.google/sre-book/testing-reliability/). Used for evidence-bounded confidence, system testing, production testing, stress, canaries, and disaster testing.
- **REF-0891** — [Google SRE: Emergency Response](https://sre.google/sre-book/emergency-response/). Used for preparedness, test-induced emergencies, incident roles, and recovery practice.
- **REF-0892** — [Google SRE Workbook: Canarying Releases](https://sre.google/workbook/canarying-releases/). Used for control/treatment comparison, representative cohorts, selection bias, and rollback decisions.
- **REF-0893** — [Kubernetes disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/). Used for voluntary and involuntary disruption semantics and PodDisruptionBudget limitations.
- **REF-0894** — [Chaos Mesh: define the scope of chaos experiments](https://chaos-mesh.org/docs/2.6.7/define-chaos-experiment-scope/). Used for namespace, label, selector, and target-scope mechanics.
- **REF-0895** — [Chaos Mesh: run a chaos experiment](https://chaos-mesh.org/docs/2.6.7/run-a-chaos-experiment/). Used for one-time execution, duration, pause/delete, and restoration semantics.
- **REF-0896** — [Chaos Toolkit experiment API](https://chaostoolkit.org/reference/api/experiment/). Used for steady-state hypotheses, probes, actions, tolerances, controls, secrets, and rollback.
- **REF-0897** — [Chaos Toolkit execution flow](https://chaostoolkit.org/reference/tutorials/run-flow/). Used for execution order, continuous probes, deviation, rollback, and the recovery-proof boundary.

### Review method and limitations

All 15 references are primary community, project, provider, or first-party SRE sources locked for this lesson on 2026-08-07. Provider-neutral claims were triangulated across sources. Kubernetes, AWS FIS, Azure Chaos Studio, Chaos Mesh, and Chaos Toolkit behavior remains scoped to the cited product and version documentation.

Provider features, tool semantics, and documentation can change. Review after 2027-02-07 or sooner when architecture, tooling, regulation, or cited guidance changes. This lesson does not replace organizational change, security, privacy, legal, data, incident, or business-continuity authority.

The local lab is intentionally a no-fault decision model. It proves deterministic gate classification, refusal behavior, and bounded cleanup for its fixtures. It does not prove a real experiment, production resilience, tool safety, organizational readiness, or learner mastery. Only reviewer-observed evidence from a separate bounded exercise can support those claims.
