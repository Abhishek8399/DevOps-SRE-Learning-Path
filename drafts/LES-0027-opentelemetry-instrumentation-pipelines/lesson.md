---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0027",
  "slug": "opentelemetry-instrumentation-pipelines",
  "aliases": ["V04-L02", "opentelemetry-instrumentation-pipelines"],
  "curriculumIds": ["OBS-002"],
  "route": "/book/reliability/opentelemetry-instrumentation-pipelines",
  "order": 2,
  "volume": "04-reliability-operations",
  "title": "OpenTelemetry instrumentation pipelines: preserve meaning from code to backend",
  "summary": "Learn how an operation becomes telemetry through OpenTelemetry APIs, SDKs, propagators, OTLP, agent and gateway Collectors, processors, queues, retries, sampling, and storage boundaries; diagnose broken parentage, configured-but-disabled pipelines, loss, pressure, and biased sampling without treating a green Collector as proof that useful evidence arrived.",
  "domain": "reliability",
  "level": {"from": "intermediate", "to": "advanced"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0026", "LES-0018"],
  "prerequisiteCurriculumIds": ["OBS-001", "AUT-002"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The normal-user static and full offline runtime paths passed on 2026-08-07, including exact dependency checks, three Collector binary validations, five containers, per-hop evidence, a gateway outage, sampling, and exact cleanup."
    },
    {
      "platform": "WSL 2 Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "Docker Desktop integration, host networking, filesystem performance, clocks, and process boundaries can differ from a native Linux host and must be recorded."
    },
    {
      "platform": "Docker Engine and Compose plugin",
      "version": "Engine 29.6.2 and Compose 5.3.1",
      "support": "supported",
      "notes": "The intended fixture requires an available daemon and pinned local image digests. No production or cross-platform behavior follows from one local execution."
    },
    {
      "platform": "OpenTelemetry Collector",
      "version": "Collector Contrib 0.157.0, digest pinned",
      "support": "supported",
      "notes": "The exact local agent/gateway configuration and telemetry path passed on Ubuntu 24.04 before the controller's interruption-safe lock hardening. The current source tree still requires a complete rerun. This does not establish other distributions, versions, components, backends, or production behavior."
    },
    {
      "platform": "OpenTelemetry Python",
      "version": "SDK/API/exporter 1.44.0 and semantic conventions 0.65b0",
      "support": "supported",
      "notes": "The fourteen-wheel hash-pinned Python 3.12 set passed the local fixture before the controller's interruption-safe lock hardening. The current source tree still requires a complete rerun. Signal maturity, packages, conventions, and behavior still require version-specific review before production adoption."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "observability-engineer",
    "software-engineer-on-call",
    "cloud-infrastructure-engineer",
    "technical-lead",
    "incident-commander"
  ],
  "learningObjectives": [
    "Distinguish the OpenTelemetry API, SDK, instrumentation library, semantic conventions, context propagator, OTLP protocol, Collector, and observability backend by ownership and failure behavior.",
    "Trace one operation from application code through span creation, context injection, carrier transport, extraction, export, Collector pipelines, and a local sink without assuming that configuration text means runtime enablement.",
    "Parse and validate W3C trace context, preserve parentage across synchronous and asynchronous boundaries, and treat baggage as untrusted distributed input rather than an authorization channel.",
    "Explain why receivers, processors, exporters, and service pipelines form an ordered runtime graph and why a component declared in configuration can still be unused.",
    "Compare head, parent-based, and tail sampling by decision location, completeness, bias, failure modes, resource cost, and what each retained set cannot prove.",
    "Reason quantitatively about finite batches, queues, retries, backoff, backpressure, refusal, dropping, duplication, and recovery backlog.",
    "Use application, SDK, agent, gateway, network, backend, and query evidence to locate the earliest failing boundary while preserving proof limits.",
    "Design a safe instrumentation rollout with schema review, bounded attributes, privacy controls, overhead budgets, canaries, rollback, and telemetry-pipeline self-observation.",
    "Diagnose broken async context, an enabled-looking but inactive Collector path, sampler-policy conflicts, and instrumentation-driven latency or data exposure.",
    "Separate artifact publication, fixture execution, representative production evidence, independent learner transfer, and mastery."
  ],
  "productionSignals": [
    "application operations started, completed, failed, and abandoned by stable operation name",
    "trace and span identifiers present, valid, and continuous at each owned boundary",
    "new-root rate, orphan-span rate, link usage, and parentage discontinuity by bounded service and transport",
    "SDK records generated, sampled, queued, exported, failed, and dropped with known units",
    "Collector receiver accepted and refused items by signal and receiver",
    "processor accepted, filtered, transformed, errored, and dropped items by bounded pipeline",
    "exporter sent, failed, retried, and permanently dropped items",
    "batch size, flush reason, flush age, queue occupancy, queue capacity, oldest age, and retry backoff",
    "Collector process CPU, memory, file descriptor, restart, and readiness state",
    "OTLP connection, TLS, authentication, payload, response status, and retry classification",
    "backend ingest count, ingest delay, retention, indexing, query scope, and last visible record age",
    "head decision rate, parent decision inheritance, tail pending-trace count, decision latency, eviction, and policy result",
    "instrumentation overhead for request latency, CPU, allocations, memory, payload size, and dependency calls",
    "attribute and baggage cardinality, byte volume, sensitive-field findings, and schema-version adoption",
    "deployment, configuration, sampler, semantic-convention, SDK, Collector, and backend change events"
  ],
  "diagrams": [
    {
      "id": "LES-0027-DIA-001",
      "title": "Operation-to-sink OpenTelemetry path",
      "direction": "left-to-right",
      "boundaries": ["application API and instrumentation", "language SDK", "OTLP exporter", "agent Collector", "gateway Collector", "local sink or backend"],
      "evidencePoints": ["operation count", "span creation", "SDK export result", "agent receive and send", "gateway receive and send", "sink ingest and query freshness"],
      "textAlternative": "Application code or instrumentation calls the OpenTelemetry API. The configured SDK creates and processes telemetry, an OTLP exporter transmits it, a node-local or workload-local agent Collector receives it, a gateway Collector applies shared policy and exports it, and a sink stores or displays it. Every arrow has its own protocol, queue, timeout, retry, loss, identity, and ownership evidence."
    },
    {
      "id": "LES-0027-DIA-002",
      "title": "W3C context crosses a carrier and a trust boundary",
      "direction": "left-to-right",
      "boundaries": ["upstream active context", "inject", "HTTP headers or message properties", "trust and validation boundary", "extract", "downstream context and span"],
      "evidencePoints": ["traceparent syntax", "trace identifier", "parent span identifier", "trace flags", "tracestate policy", "baggage allowlist and size"],
      "textAlternative": "An upstream propagator injects trace context into a carrier such as HTTP headers or message properties. The carrier crosses a boundary where data is untrusted and must be validated. A downstream propagator extracts a remote parent and creates a child span, or records a new root with an explicit reason if context is absent or invalid. Baggage travels separately and must never grant authorization."
    },
    {
      "id": "LES-0027-DIA-003",
      "title": "Collector configuration is not the enabled runtime graph",
      "direction": "hierarchical",
      "boundaries": ["declared receivers", "declared processors", "declared exporters", "service pipelines", "ordered component instances", "extensions and connectors"],
      "evidencePoints": ["configuration parse", "component creation", "pipeline membership", "startup logs", "receiver acceptance", "exporter completion"],
      "textAlternative": "Receivers, processors, and exporters can be declared at the top level, but only service pipelines enable and order them for a signal. A traces pipeline names a receiver list, an ordered processor list, and an exporter list. Startup success proves only accepted configuration and running components; runtime counters and sink evidence are needed to prove flow."
    },
    {
      "id": "LES-0027-DIA-004",
      "title": "Sampling decisions occur at different boundaries",
      "direction": "top-to-bottom",
      "boundaries": ["root-span head decision", "parent decision inheritance", "distributed child spans", "Collector trace assembly", "tail policy decision", "retained or dropped trace"],
      "evidencePoints": ["sampling probability", "sampled flag", "parent-based branch", "complete-trace wait", "decision timeout", "eviction and policy result"],
      "textAlternative": "Head sampling decides near root-span creation before the final outcome is known. Parent-based sampling propagates that decision to descendants when context survives. Tail sampling waits at a Collector or backend for enough spans to evaluate a policy, which consumes memory and time and requires compatible routing so spans of one trace meet at the decision point."
    },
    {
      "id": "LES-0027-DIA-005",
      "title": "Finite pipeline pressure and loss state machine",
      "direction": "cyclic",
      "boundaries": ["record production", "batch buffer", "sending queue", "export attempt", "retry and backoff", "permanent success or loss"],
      "evidencePoints": ["arrival rate", "batch age and size", "queue capacity and occupancy", "consumer rate", "retryable result", "drop or acknowledgement"],
      "textAlternative": "Records enter a finite batch buffer, flush into a finite sending queue, and face export attempts. Retryable failures return records after backoff while production continues. If sustained arrival exceeds consumption, occupancy and oldest age rise until the queue refuses or drops work, or an unbounded design exhausts the Collector. Recovery must drain the backlog without starving current traffic."
    },
    {
      "id": "LES-0027-DIA-006",
      "title": "Safe rollout ladder for instrumentation and pipelines",
      "direction": "hierarchical",
      "boundaries": ["schema and threat review", "local bounded proof", "shadow or disabled export", "small canary", "progressive cohorts", "steady-state ownership and rollback"],
      "evidencePoints": ["attribute allowlist", "functional correctness", "overhead delta", "pipeline loss", "backend usability", "abort and rollback proof"],
      "textAlternative": "A rollout starts with an operation and data contract, privacy and cardinality review, then local bounded proof. It advances through shadow or disabled export, a small canary, and progressive cohorts only while application outcomes, resource overhead, telemetry loss, and backend usefulness remain within budgets. Every rung has an owner, abort condition, rollback action, and sustained recovery check."
    }
  ],
  "commands": [
    {
      "id": "LES-0027-CMD-001",
      "question": "Are the normal-user Ubuntu, Docker, Compose, curl, and Python prerequisites visible before any lab mutation?",
      "risk": "read-only",
      "command": "bash lab.sh doctor",
      "runFrom": "drafts/LES-0027-opentelemetry-instrumentation-pipelines/support/lab as a normal Ubuntu user",
      "expectedBranches": [
        {"when": "every required prerequisite is reported ready", "meaning": "the wrapper found the declared local tools and can continue to lock and configuration checks", "nextEvidence": "inspect the exact image locks with LES-0027-CMD-002"},
        {"when": "Docker is unavailable, integration is disabled, a tool is missing, or the caller is root", "meaning": "the local prerequisite contract is not satisfied", "nextEvidence": "stop; repair only the owned local prerequisite and repeat doctor without bypassing refusal"}
      ],
      "proves": "only the prerequisite checks actually reported by the draft wrapper at that moment",
      "doesNotProve": "image availability, Collector validity, service health, OTLP flow, cleanup, or production compatibility"
    },
    {
      "id": "LES-0027-CMD-002",
      "question": "Which exact image references are locked, and do locally cached images resolve to those digests?",
      "risk": "read-only",
      "command": "bash lab.sh doctor | sed -n '/lock/p;/digest/p;/image/p'",
      "runFrom": "drafts/LES-0027-opentelemetry-instrumentation-pipelines/support/lab as a normal Ubuntu user after reading the lock file",
      "expectedBranches": [
        {"when": "locked references and matching local content digests are reported", "meaning": "the intended immutable image content is locally addressable", "nextEvidence": "render and validate configuration with LES-0027-CMD-003"},
        {"when": "a digest is absent, mutable-only, mismatched, or its cached content ID differs", "meaning": "offline setup cannot prove the intended artifact identity", "nextEvidence": "do not substitute latest; review the lock and use the explicit prepare path only under approved network policy, then re-run doctor"}
      ],
      "proves": "the wrapper's bounded lock and local-image comparison output",
      "doesNotProve": "image provenance, signature trust, absence of vulnerabilities, runtime compatibility, or that a container has started"
    },
    {
      "id": "LES-0027-CMD-003",
      "question": "Does Compose render the intended topology, and does the locked Collector accept the exact configuration before services start?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh validate-configs",
      "runFrom": "drafts/LES-0027-opentelemetry-instrumentation-pipelines/support/lab as a normal Ubuntu user after doctor reports complete locks and verified artifacts",
      "expectedBranches": [
        {"when": "Compose rendering and Collector validation both pass", "meaning": "the current inputs are syntactically acceptable to those exact local tools", "nextEvidence": "run offline setup and then prove runtime pipeline membership"},
        {"when": "rendering or validation fails", "meaning": "the topology, variable substitution, component name, option, or exact-version contract is invalid", "nextEvidence": "stop before startup and repair the smallest owned configuration defect"}
      ],
      "proves": "resolved Compose acceptance plus successful start/attach, exited state, zero exit, timestamps, exact removal, and specific absence for each configuration under the digest-pinned Collector",
      "doesNotProve": "component enablement, receiver reachability, telemetry flow, exporter success, or backend visibility",
      "cleanup": "The wrapper removes each exact temporary validation container by immutable ID in a guaranteed cleanup path; no persistent lab lifecycle is created. Confirm with bash lab.sh status if the command is interrupted."
    },
    {
      "id": "LES-0027-CMD-004",
      "question": "Is a candidate traceparent syntactically valid, and what do its four fields mean?",
      "risk": "read-only",
      "command": "python3 -c \"import re,sys; v='00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01'; m=re.fullmatch(r'([0-9a-f]{2})-([0-9a-f]{32})-([0-9a-f]{16})-([0-9a-f]{2})',v); ok=bool(m and m[2]!='0'*32 and m[3]!='0'*16 and m[1]!='ff'); print('valid=',ok); print('version=',m[1] if m else 'unparsed','trace_id=',m[2] if m else 'unparsed','parent_id=',m[3] if m else 'unparsed','flags=',m[4] if m else 'unparsed'); sys.exit(0 if ok else 2)\"",
      "runFrom": "any Ubuntu directory as a normal user; replace only the literal candidate with sanitized test data",
      "expectedBranches": [
        {"when": "valid=True and four fields print", "meaning": "the sample satisfies the deliberately bounded version-00 syntax and nonzero checks", "nextEvidence": "inspect trusted-boundary propagation and child parentage; syntax is not authenticity"},
        {"when": "valid=False or the command exits 2", "meaning": "the candidate is missing, malformed, forbidden-version, or uses an all-zero required identifier under this parser", "nextEvidence": "record invalid context and follow the local policy for starting a new trace without trusting its values"}
      ],
      "proves": "only the stated parser's result for one sanitized candidate",
      "doesNotProve": "request authenticity, authorization, causal truth, upstream sampling intent, tracestate validity, or conformance for every future Trace Context version"
    },
    {
      "id": "LES-0027-CMD-005",
      "question": "Can the locked fixture start without pulling images or publishing any host port?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup",
      "runFrom": "drafts/LES-0027-opentelemetry-instrumentation-pipelines/support/lab as a normal Ubuntu user after doctor passes",
      "expectedBranches": [
        {"when": "setup reports the exact owned resources ready and runtime_pull_policy=never", "meaning": "the local locked containers and internal network reached the fixture's declared readiness checks without a runtime pull", "nextEvidence": "record the lifecycle token and send one fixed request with LES-0027-CMD-006"},
        {"when": "an image is absent, a digest differs, an unexpected resource exists, or readiness fails", "meaning": "the offline lifecycle cannot safely continue", "nextEvidence": "stop, preserve diagnostics, and run token-guarded cleanup; never silently pull or take over an unowned resource"}
      ],
      "proves": "only successful creation and readiness of resources named by the wrapper if actual output reports them",
      "doesNotProve": "production topology, external network isolation, end-to-end telemetry completeness, performance, security, or cleanup",
      "cleanup": "Read the lifecycle token from setup or status, run bash lab.sh cleanup --expect-token TOKEN from the same directory, and confirm final absence with bash lab.sh status."
    },
    {
      "id": "LES-0027-CMD-006",
      "question": "What workload and telemetry records does one fixed baseline operation create?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run baseline",
      "runFrom": "the prepared fixture directory while the owned local stack is ready",
      "expectedBranches": [
        {"when": "the fixed operation succeeds and a correlated trace reaches the local sink", "meaning": "this one operation crossed the fixture's workload and encoded telemetry path", "nextEvidence": "compare every parent-child edge and Collector boundary rather than stopping at one trace view"},
        {"when": "the operation succeeds but telemetry is absent or partial", "meaning": "workload success and evidence delivery diverged", "nextEvidence": "walk SDK, agent, gateway, sink, and query counters in order"},
        {"when": "the operation fails", "meaning": "the workload path itself is unhealthy or unavailable", "nextEvidence": "bound the first failing workload boundary before interpreting telemetry completeness"}
      ],
      "proves": "only the recorded outcome and telemetry for the wrapper's fixed local operation",
      "doesNotProve": "all-request coverage, production correctness, representative load, sampling fairness, or causation",
      "cleanup": "The request mutates only fixture-owned ephemeral records; remove them with bash lab.sh cleanup --expect-token TOKEN using the token returned by setup or status."
    },
    {
      "id": "LES-0027-CMD-007",
      "question": "Did the synchronous and asynchronous spans preserve the intended parent, or did a worker start a new root?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the prepared fixture directory after exactly one baseline request",
      "expectedBranches": [
        {"when": "one trace identifier is shared and every expected parent or link matches the operation map", "meaning": "the fixture's reported context continuity is consistent with its intended graph", "nextEvidence": "check that no expected span is missing and that the sink did not merge unrelated records"},
        {"when": "the worker has a different trace identifier or no intended parent or link", "meaning": "context was absent, invalid, overwritten, or not extracted at that carrier boundary", "nextEvidence": "compare inject output, serialized carrier, trust-boundary validation, extract output, and worker span start"}
      ],
      "proves": "only the parentage fields and fixture records visible in the current status output",
      "doesNotProve": "causality, complete production propagation, message authenticity, or that another operation cannot collide through bad instrumentation"
    },
    {
      "id": "LES-0027-CMD-008",
      "question": "Which current-run records bind the fixed operation to aligned SDK, agent, gateway, and sink measurements?",
      "risk": "read-only",
      "command": "bash lab.sh status",
      "runFrom": "the prepared fixture directory after a bounded operation",
      "expectedBranches": [
        {"when": "the operation identity, direct parent fields, evidence hashes, bounded gateway lines, counter units, process-start identities, freshness, and 3-span deltas reconcile", "meaning": "the encoded local operation crossed the measured SDK, agent, gateway, and debug-sink boundaries", "nextEvidence": "compare the raw before/after snapshots and preserve the explicit backend and production exclusions"},
        {"when": "a record is missing, stale, hash-invalid, bound to changed resources, crosses an unexpected reset, or fails exact reconciliation", "meaning": "the runtime evidence contract is invalid", "nextEvidence": "stop, preserve bounded diagnostics, and repair the earliest binding failure without inventing counter values"}
      ],
      "proves": "the exact record identities, direct parentage, aligned process-bound SDK/Collector counters, bounded gateway evidence lines, units, freshness, and local debug-sink visibility printed by status",
      "doesNotProve": "backend ingest, indexing, retention, arbitrary queue behavior, production delivery guarantees, provider behavior, or correctness of unobserved records"
    },
    {
      "id": "LES-0027-CMD-009",
      "question": "Does the runtime evidence audit accept only five records with aligned per-hop counters, units, process resets, freshness, queue, retry, and sampling evidence?",
      "risk": "sampled-read-only",
      "command": "bash lab.sh verify-operation --expect-token TOKEN_FROM_SETUP_OR_STATUS",
      "runFrom": "the prepared fixture directory after all five guided records and before cleanup",
      "expectedBranches": [
        {"when": "runtime_verification_passed=true and every named delta and relationship matches", "meaning": "only the encoded local operations, windows, units, resets, queue/retry experiment, sampling comparison, and invariants passed", "nextEvidence": "review the stored snapshots and exclusions; a passing fixture is still not backend or production evidence"},
        {"when": "a required record is absent or an action, digest, time, resource, network, source, workload, parent, metric, reset, queue, retry, or sampling binding differs", "meaning": "the audit fails closed at that boundary", "nextEvidence": "preserve the bounded failure and correct the earliest owned mismatch"},
        {"when": "the command reports success without all five records or converts an absent/negative/stale measurement into success", "meaning": "the verifier is overclaiming", "nextEvidence": "reject the result and retain raw before-and-after evidence"}
      ],
      "proves": "the checked-in local five-record evidence contract when the command returns success",
      "doesNotProve": "backend ingest, Collector-wide health, all signal types, production delivery guarantees, absence of every race, or learner mastery"
    },
    {
      "id": "LES-0027-CMD-010",
      "question": "Can the fixture expose a dropped async carrier context and then restore propagation without changing an unrelated boundary?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh run broken-context; broken_status=$?; bash lab.sh recover-context; exit \"$broken_status\"",
      "runFrom": "the prepared fixture directory after a clean baseline; expect the fault demonstration to return its documented result",
      "expectedBranches": [
        {"when": "the broken run shows a worker new root and recovery restores the configured carrier path", "meaning": "the fixture demonstrated and removed its owned context fault", "nextEvidence": "compare the exact carrier and parentage records before claiming the mechanism"},
        {"when": "parentage does not change, recovery refuses, or another invariant changes", "meaning": "the intended fault was not isolated or ownership changed", "nextEvidence": "abort further mutation, preserve evidence, and clean the fixture"}
      ],
      "proves": "only the behavior of the fixture's named context-fault and recovery controls",
      "doesNotProve": "that all production new roots share this cause, that context is trustworthy, or that recovery fixed unrelated pipeline loss",
      "cleanup": "The recovery command must restore the owned context configuration; bash lab.sh cleanup --expect-token TOKEN removes the full fixture after token verification."
    },
    {
      "id": "LES-0027-CMD-011",
      "question": "Can a bounded gateway stop produce measured queue occupancy, retry, drain, and exact post-restart reconciliation?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh interrupt-gateway",
      "runFrom": "the prepared fixture directory only; the wrapper must identify the exact owned gateway and enforce a finite request count and timeout",
      "expectedBranches": [
        {"when": "four requests succeed, both agent queues become nonzero, retry records appear, only the gateway process restarts, all twelve spans reach its new process, queues drain, and refusal/drop remain zero", "meaning": "the exact local bounded queue/retry path bridged this measured interruption", "nextEvidence": "retain the peak, capacity, observed age lower bound, retry records, reset identity, drain, and explicit non-production limits"},
        {"when": "an identifier is absent, ownership cannot be proven, restoration fails, or a request loses context", "meaning": "the bounded interruption did not produce valid recovery evidence", "nextEvidence": "stop generation, preserve current-window diagnostics, restore the exact owned gateway, and clean up without claiming drain or loss"}
      ],
      "proves": "exact-resource control, four bounded workload outcomes, measured agent queue occupancy/capacity, bounded retry records, observed residence lower bound, gateway-only reset, twelve-span drain, zero measured refusal/drop, and debug-sink visibility",
      "doesNotProve": "durable buffering, queue saturation, arbitrary outage tolerance, process-crash survival, production behavior, or exactly-once delivery",
      "cleanup": "The wrapper must resume its exact gateway even on interruption; finish with bash lab.sh cleanup --expect-token TOKEN and final-absence status."
    },
    {
      "id": "LES-0027-CMD-012",
      "question": "How do the fixture's sampling modes change retained evidence, and is every owned resource absent afterward?",
      "risk": "destructive-disposable",
      "command": "bash lab.sh compare-sampling; bash lab.sh cleanup --expect-token TOKEN; bash lab.sh status",
      "runFrom": "the prepared fixture directory after other guided observations are complete; replace TOKEN with the exact lifecycle token returned by setup or status and inspect the comparison result before accepting cleanup",
      "expectedBranches": [
        {"when": "sampling comparison reports the documented retained sets and status proves final absence", "meaning": "the fixture completed its bounded comparison and cleanup evidence", "nextEvidence": "explain decision location and bias; do not infer unsampled outcomes from retained traces"},
        {"when": "comparison fails but cleanup succeeds", "meaning": "the sampling claim is unproven while lifecycle recovery is proven for this attempt", "nextEvidence": "preserve the failure and repair only the owned comparison before repeating"},
        {"when": "cleanup or final absence fails", "meaning": "owned resources or ambiguous state remain", "nextEvidence": "treat this as a blocker; use the wrapper's exact ownership record and refusal rules, never broad deletion"}
      ],
      "proves": "only the comparison output and final-absence checks that actually complete",
      "doesNotProve": "production sampling quality, unbiased incident evidence, backend behavior, formal acceptance, or mastery",
      "cleanup": "This command invokes the dedicated cleanup; no broad Docker prune, volume prune, network prune, or filesystem deletion is authorized."
    }
  ],
  "labs": [
    {
      "id": "LES-0027-LAB-001",
      "title": "Trace one operation through an SDK, agent Collector, gateway Collector, and local sink",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with a working Docker daemon, Compose plugin, Bash, Python 3, curl, and all exact locked images already cached",
      "timeMinutes": 120,
      "privilege": "normal user only; no sudo; the wrapper must refuse root and refuse resources it cannot prove it owns",
      "network": "setup and operation use only the fixture's internal Docker network through validated container IDs; no host port is published; artifact acquisition is a separate explicit prepare step",
      "changes": ["creates uniquely named fixture-owned containers", "creates one uniquely named fixture-owned Docker network", "creates only fixture-owned ephemeral records and a guarded local ownership descriptor", "temporarily changes only fixture-owned propagation, gateway, and sampling controls"],
      "abortConditions": ["the caller is root", "an image lock is mutable-only, absent, or mismatched", "a project resource already exists without matching ownership", "Compose rendering or exact Collector validation fails", "a command selects more than the exact owned resource", "a timeout, unexpected external address, secret-like value, or cleanup refusal appears"],
      "recovery": "Stop request generation, restore the exact owned gateway and context controls, collect bounded diagnostics, and invoke the dedicated idempotent cleanup. Never use global prune or delete by a broad name pattern.",
      "cleanupProof": "The ownership descriptor, exact containers, exact network, fixture records, and temporary state are absent; pre-existing and concurrent foreign resources remain; repeated cleanup is safe; status reports no owned residue."
    },
    {
      "id": "LES-0027-LAB-002",
      "title": "Independently locate broken async context and a configured-but-disabled Collector path",
      "mode": "independent",
      "environment": "a fresh instructor-approved disposable clone or generated local fixture based on the LES-0027 support contract, never the already-solved guided instance",
      "timeMinutes": 180,
      "privilege": "normal user with Docker access; no sudo, no production target, and no unowned resource mutation",
      "network": "fixture-internal traffic only through validated container identities after exact dependencies are locally available; no published port or hidden package/image acquisition",
      "changes": ["creates only uniquely owned disposable fixture resources", "permits one declared reversible action after baseline evidence", "records a sanitized evidence bundle and independent chronology"],
      "abortConditions": ["the learner has seen a solution to the exact scenario", "target ownership or independence is ambiguous", "baseline or raw evidence is missing", "more than one causal variable would change", "a secret, personal identifier, external destination, or unbounded load appears", "cleanup cannot prove exact ownership"],
      "recovery": "Return the exact changed variable to its baseline, stop bounded load, restore every owned component, reconcile user and telemetry outcomes, and invoke dedicated cleanup. A reviewer may require a fresh unseen case if independence was lost.",
      "cleanupProof": "Sanitized before-and-after evidence shows restoration; exact owned resources are absent; unrelated resources are unchanged; the learner declares all assistance; an authorized reviewer verifies chronology and cleanup without receiving secrets."
    }
  ],
  "incidents": [
    {
      "id": "LES-0027-INC-001",
      "signal": "HTTP spans share the expected trace, but every async worker operation begins a new trace root after a queue boundary.",
      "firstThought": "The queue is dropping trace context.",
      "safePath": "Bound one message and compare the active producer context, injected carrier keys, serialized message properties, broker preservation, consumer extraction result, and worker span start. Validate syntax and trust policy. Distinguish an intentionally linked batch or fan-out span from accidental parent loss before changing propagation.",
      "trap": "Adding a trace ID manually to logs or forcing the worker's parent from an unvalidated payload can hide the instrumentation defect, create false relationships, and turn attacker-controlled context into trusted state."
    },
    {
      "id": "LES-0027-INC-002",
      "signal": "Application export reports success and both Collectors are ready, but the backend query is empty.",
      "firstThought": "The backend is down.",
      "safePath": "Use one fixed operation and walk the earliest boundary: SDK generation and sample decision, exporter result, agent receiver delta, ordered processors, agent exporter delta, gateway receiver delta, gateway pipeline membership, gateway exporter delta, sink ingest, ingest delay, tenant, time range, and query. Treat declared components and readiness as separate from enabled flow.",
      "trap": "Restarting every Collector destroys counters and timing while a receiver or exporter that is declared but absent from service.pipelines remains disabled after restart."
    },
    {
      "id": "LES-0027-INC-003",
      "signal": "High-value error traces are missing after head sampling was introduced in applications and tail sampling was enabled across several gateway replicas.",
      "firstThought": "Increase the tail-sampling percentage.",
      "safePath": "Map every sampling decision and sampled flag, verify parent-based inheritance, identify whether unsampled roots ever reach the gateway, and prove whether all spans for a trace are consistently routed to one tail decision point. Inspect pending traces, decision timeout, late spans, memory, eviction, policy order, and error population counters outside traces.",
      "trap": "Tail sampling cannot recover spans discarded at the head, and sharding spans of one trace across independent tail samplers makes each decision from an incomplete view. Retained error traces cannot measure the true error rate."
    },
    {
      "id": "LES-0027-INC-004",
      "signal": "After an instrumentation rollout, application p99 latency and CPU increase while baggage and span attributes contain raw customer and payment-like values.",
      "firstThought": "Telemetry volume is the expected price of better observability.",
      "safePath": "Pause promotion at the affected cohort. Compare canary and control user outcomes, CPU, allocations, payload size, span and attribute count, export blocking, queue pressure, processor cost, and backend ingest. Apply the approved rollback or disable path. Preserve sanitized schema evidence, notify the security or privacy owner, and follow incident policy for possible sensitive-data exposure without copying values into tickets.",
      "trap": "Raising queue limits or sampling away traces does not remove unsafe baggage already propagated, does not bound synchronous instrumentation overhead, and can retain sensitive values longer."
    }
  ],
  "assessmentIds": ["ASM-0064", "ASM-0065", "ASM-0066"],
  "referenceIds": ["REF-0166", "REF-0170", "REF-0173", "REF-0174", "REF-0175", "REF-0176", "REF-0177", "REF-0178", "REF-0179", "REF-0180", "REF-0181", "REF-0182", "REF-0183", "REF-0184"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-10",
  "reviewAfter": "2027-02-10",
  "limitations": [
    "This file is quarantined under drafts and is not canonical content, a live route, or an accepted chapter.",
    "The telemetry runtime path passed its verifier on 2026-08-07, before the controller's interruption-safe lock hardening. The current source tree requires a new complete runtime run. Any passing evidence applies only to the pinned fixture, synthetic operations, bounded faults, debug sink, and recorded host; prose must not be generalized into backend or production evidence.",
    "A local Docker fixture cannot establish Kubernetes, managed Collector, service mesh, cloud backend, vendor backend, production scale, cross-region, TLS, identity-provider, storage, retention, or failure-domain behavior.",
    "The traceparent parser is intentionally bounded to selected version-00 checks and does not replace the complete W3C processing model or current library conformance.",
    "Collector component names, defaults, feature gates, metric names, and configuration options evolve; exact behavior must be checked against the pinned distribution and current official documentation.",
    "OpenTelemetry Python signal maturity, packages, semantic conventions, exporters, and environment variables evolve; the exact locked versions and status pages govern implementation.",
    "Debug exporters and local sinks can expose payloads and are teaching-only. They are not safe production defaults and must receive sanitized fixture data only.",
    "A retained trace is a sampled report, not a denominator, complete history, authenticity proof, or causal proof.",
    "Publication, command output, fixture verification, self-scoring, and answer reveal do not establish learner transfer, delayed recall, incident leadership, or mastery."
  ]
}
---

# OpenTelemetry instrumentation pipelines: preserve meaning from code to backend

This chapter is a quarantined authoring draft. It is written so the idea can be reviewed, but nothing in `drafts/` is a published chapter or live reader route. The pinned telemetry path completed a normal-user Ubuntu runtime on 2026-08-07. The controller was subsequently hardened so an abruptly terminated operation cannot strand cleanup behind a stale sentinel; that current revision still requires the complete runtime verifier. Treat the commands below as procedures, and accept runtime claims only from a verifier receipt whose source hashes match the checked-out tree.

If LES-0026 gave you the mental model that a dashboard is the last page of a long evidence journey, this chapter opens the middle of that journey. OpenTelemetry is not one server and not a magic switch. It is a set of contracts that lets code describe work, carry context across boundaries, encode telemetry, move it through pipelines, and hand it to a destination. Your real SRE skill is preserving the meaning of the operation while each boundary is allowed to fail.

## What you see and first thought

Picture a familiar incident. A payment request succeeds at the API, a worker later completes the transaction, and the customer gets a receipt. The trace screen, however, shows two unrelated traces. The API trace ends at the queue. The worker trace starts from nowhere. A nearby Collector dashboard is green. There are no exporter errors. The fastest thought is, “OpenTelemetry is broken.” That thought is too large to test.

OpenTelemetry has several independently owned boundaries. Application code may never create a span. A span may be created but not recorded. A recorded span may be unsampled. An SDK batch may still hold it. An exporter may reject it. An agent Collector may receive it but filter it. A gateway may be healthy while the traces pipeline is absent from `service.pipelines`. A backend may ingest it under another tenant. A query may ask the wrong time range. One visible gap therefore creates two paths to investigate: the workload path and the telemetry path.

Use this sentence when pressure rises:

> A green component tells me that one component answered one health question. It does not tell me that the intended operation produced valid telemetry, crossed every configured runtime pipeline, arrived in the correct destination, or remained queryable.

Start with a bounded claim. “For operation `checkout.submit` in canary version 43 between 14:10 and 14:20 UTC, the application success counter increased by 120, the agent accepted-span counter increased by 120, the gateway accepted-span counter did not change, and no matching sink records are visible as of 14:22.” This claim names an operation, cohort, interval, sources, and freshness. It does not invent a cause.

Now split the system:

```text
WORKLOAD PATH
client -> API -> queue -> worker -> payment dependency -> durable result

TELEMETRY PATH
instrumentation -> SDK -> exporter -> agent Collector -> gateway Collector
                -> local sink/backend -> ingest/index -> query -> screen

CONTEXT PATH
active span -> inject -> carrier -> validate/extract -> downstream span
```

The three paths interact, but they are not the same. A payment can succeed while telemetry fails. Telemetry can arrive for a failed payment. Context can join records that merely report a relationship; it does not authenticate the request or prove why latency occurred.

### Four incident reflexes worth memorizing

1. If synchronous spans connect but a worker starts a new root, inspect the carrier boundary before the Collector. Collectors move reported spans; they cannot recreate context that the producer never injected or the consumer never extracted.
2. If a Collector is healthy but the backend is empty, compare configured components with enabled service pipelines, then walk receive, process, export, ingest, and query deltas.
3. If error traces disappear after sampling changes, map where each decision occurs. A tail sampler cannot recover spans already discarded by head sampling.
4. If instrumentation increases user latency or carries unsafe values, stop the rollout. Observability must not damage or expose the system it is meant to explain.

### What this chapter will make you able to say

By the end, you should be able to explain an OpenTelemetry path without hiding behind product names. You should be able to say which object owns a span, where context crosses a trust boundary, which Collector components are merely declared, how pipeline order changes data, why a queue buys time but not throughput, what sampling removes from your claims, and what exact evidence would make you change your diagnosis.

You are not expected to memorize every Collector key or SDK environment variable. Those change. You are expected to retain the durable model: **operation, context, record, decision, transport, pipeline, destination, query, proof boundary**.

## Terms before commands

Before touching a terminal, give each moving part one job. Product documentation often places these words close together, which makes newcomers treat them as synonyms. They are not.

### Telemetry, instrumentation, and observability

**Telemetry** is recorded information about a running system: measurements, structured events, traces, logs, or profiles. Telemetry is a report. The real request, process, queue, and customer outcome exist independently of that report.

**Instrumentation** is the code or mechanism that observes an operation and creates telemetry. It includes where an operation begins and ends, what name it receives, which attributes are attached, how errors are represented, how context is injected or extracted, and how much work the measurement performs. Good instrumentation is a data contract, not “add a library and hope.”

**Observability** is an operational property: can an engineer ask useful questions about internal behavior using available external evidence? Installing OpenTelemetry can improve the evidence path, but it does not automatically make a system observable. Bad operation names, missing outcomes, unbounded attributes, broken context, biased sampling, or an unowned pipeline can produce large volumes of useless telemetry.

### OpenTelemetry API, SDK, and instrumentation library

The **API** is the interface application and library code calls. For tracing, code asks for a tracer, starts a span, attaches bounded attributes or events, records an exception according to the language convention, and ends the span. The API lets libraries instrument themselves without selecting a vendor destination.

The **SDK** is the implementation configured by the application owner. It decides whether to record and sample, creates span processors, batches records, exports them, owns buffers and worker threads, and exposes resource identity. An API call can exist with no configured SDK; in that case it may behave as a no-op. That is why “the code contains `start_span`” is not flow evidence.

An **instrumentation library** applies the API to a framework or dependency. Auto-instrumentation may wrap HTTP clients, servers, database drivers, or messaging libraries. Manual instrumentation covers the business operations and unusual boundaries the library cannot infer. Auto-instrumentation saves work but does not understand your durable business success definition.

**Resource attributes** describe the entity producing telemetry, such as a stable service name, version, or deployment environment. **Span attributes** describe a specific operation. A resource attribute should not change per request. A span attribute can, but still needs a bounded schema and privacy review.

### Span, trace, parent, link, event, status, and kind

A **span** is a reported interval of one operation. It normally has a trace identifier, its own span identifier, a name, start and end timestamps, attributes, events, a status representation, and a relationship to a parent or links. A span is not the request itself. It is what the instrumentation and SDK recorded about that request.

A **trace** is the set of spans that report related work under one trace identifier. A trace is not automatically complete. Spans can be missing through instrumentation gaps, context loss, sampling, late arrival, pipeline loss, retention, or query scope.

A **parent** is the reported causal predecessor in a tree-like relationship. A server span commonly uses the remote client span as its parent. A worker processing one message may use the producer span as a remote parent if the model and semantic convention call for it.

A **link** is a relationship that is not expressed as one direct parent. Links matter for fan-in, fan-out, batching, retries, and operations influenced by several messages. Forcing every asynchronous relationship into a parent-child tree can misrepresent control flow.

A span **event** is a timestamped occurrence attached to a span, such as a retry or exception. It is not the same as a standalone event signal. A span **status** is a limited reported result, not a copy of every protocol status. A span **kind** reports the role at a boundary, such as client, server, producer, consumer, or internal; exact semantic use must follow the current convention for that operation.

### Context and propagation

**Context** is the in-process mechanism that associates the current operation with execution. In synchronous code, a language runtime may keep context across function calls. Threads, tasks, callbacks, process boundaries, and message queues can break that association unless the instrumentation handles them correctly.

**Propagation** serializes selected context into a **carrier** and reconstructs it on the other side. A carrier is the transport-specific container: HTTP headers, message properties, RPC metadata, or another approved field set.

**Inject** means writing context fields to the carrier. **Extract** means parsing carrier fields into a remote context. Extraction is a trust boundary because carrier values can be missing, malformed, oversized, duplicated, forged, or supplied by an untrusted client.

The W3C `traceparent` field for version 00 has four hyphen-separated fields:

```text
00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^ ^^
|  |                                |                +-- trace flags
|  |                                +------------------- upstream parent span ID
|  +---------------------------------------------------- trace ID
+------------------------------------------------------- version
```

The trace ID is 16 bytes rendered as 32 lowercase hexadecimal characters. The parent ID is 8 bytes rendered as 16 lowercase hexadecimal characters. All-zero identifiers are invalid. The lowest bit of the flags field represents the sampled flag in version 00. The flag is a propagation hint and reported decision, not a promise that every downstream span will arrive.

`tracestate` carries vendor-specific tracing state under a separate grammar and size policy. **Baggage** carries application-defined key-value context. Baggage is especially dangerous when people treat it like a convenient distributed variable store. It may cross service and organization boundaries, expand every request, create cardinality, enter logs or spans, and expose sensitive data. Never use a trace ID, tracestate member, or baggage value as authentication, authorization, tenant trust, payment approval, or data-access authority.

### OTLP, exporter, receiver, processor, and Collector

**OTLP**, the OpenTelemetry Protocol, defines how telemetry is encoded and transported between components. It has protocol mappings such as gRPC and HTTP. Endpoints, paths, compression, TLS, authentication, timeouts, and retry behavior depend on the exact client and deployment. “Both use OTLP” does not prove they use the same transport, port, security policy, or signal endpoint.

An **exporter** sends telemetry out of a process or Collector. Export success usually means the next boundary accepted the request according to that protocol. It does not prove durable backend storage or query visibility.

A Collector **receiver** accepts data. A **processor** transforms, batches, filters, samples, enriches, deletes, or otherwise handles data. An **exporter** sends it onward. A **connector** can join pipelines by acting as an exporter to one and a receiver to another. An **extension** provides supporting capabilities such as health or authentication but does not automatically sit in a telemetry pipeline.

The **Collector** is a separately operated telemetry service composed from those components. A **distribution** is a built binary or image containing a chosen component set. A configuration copied from another distribution can fail because the component is absent or uses another version. Always validate against the exact binary or image you will run.

### Agent and gateway deployment patterns

An **agent Collector** runs close to the workload: as a host agent, daemon, sidecar, or local service. It can reduce application destination complexity, enrich from local context, and buffer a small interruption. Its failure domain is close to the workload, and many instances must be managed.

A **gateway Collector** runs as a shared service. It centralizes routing, policy, tail sampling, credentials, or export to backends. It creates a shared capacity and availability boundary. A common design exports from application to agent, then agent to gateway. This is a pattern, not a universal requirement.

### Configured, instantiated, enabled, ready, and flowing

These words form a proof ladder:

- **Configured**: text declares a component or option.
- **Valid**: the exact parser accepts the configuration.
- **Instantiated**: the process created the component.
- **Enabled**: a service pipeline or extension references it in the runtime graph.
- **Ready**: the component's chosen readiness check passes.
- **Flowing**: bounded telemetry enters and leaves the intended component.
- **Durable and queryable**: the destination retains it under the expected tenant, time, and query.

A receiver declared under `receivers:` but absent from every `service.pipelines.<signal>.receivers` list is not enabled for that signal. This one distinction explains many “healthy but empty” incidents.

### Batch, queue, retry, backpressure, and loss

A **batch processor** groups records before export. Batching can improve network and backend efficiency, but it adds residence time and memory. It flushes because of size, time, shutdown, or implementation-specific conditions.

A **sending queue** holds export work when the exporter cannot consume immediately. Capacity must name a unit: requests, batches, items, bytes, or another implementation-defined measure. Never compare queue capacity with span arrival rate until units are reconciled.

A **retry** repeats an operation after a retryable result. Correct retry behavior has a finite attempt or elapsed-time budget, backoff, jitter, and a permanent-failure branch. Retrying forever is not durability; it is delayed exhaustion.

**Backpressure** is the effect of a downstream consumer limiting upstream production or acceptance. Some telemetry paths cannot safely push pressure back into user requests, so they use finite buffers and eventually drop. That trade-off protects the application but creates missing evidence. The loss must be observable.

If arrival rate is `lambda`, sustainable consumer rate is `mu`, and `lambda > mu`, backlog grows approximately at `lambda - mu` items per second. With `Q` free item slots, the simplified time to full is:

```text
time_to_full_seconds = Q / (lambda - mu)
```

This is a planning approximation. Variable record size, batching, concurrent consumers, retries, limits, and burstiness can invalidate it. Still, it forces the right question: a larger queue buys time; it does not repair a sustained throughput deficit.

### Sampling terms

**Head sampling** decides near the start of a root span, before the final outcome is known. It is cheap and scalable, but a simple probabilistic decision can discard the very rare error later needed.

**Parent-based sampling** lets a downstream span inherit the upstream sampled decision, usually with separate rules for remote or local sampled and unsampled parents. It keeps a distributed trace more internally consistent when propagation works. It also carries an upstream decision across trust and policy boundaries, so organizations need an explicit rule.

**Tail sampling** waits until a Collector or backend has enough of a trace to decide using attributes, status, latency, or another policy. It can retain interesting outcomes, but it consumes memory, delays export, depends on trace completeness, and needs consistent routing so spans of one trace reach the same decision point.

**Sampling probability** is not observed coverage unless implementation, root population, parent decisions, errors, retries, and pipeline loss are known. Traces are usually the wrong denominator for SLI error-rate math. Keep unsampled population counters for outcomes whenever the design requires reliable rates.

### Semantic conventions and schema stability

**Semantic conventions** define common names and meanings for operations, attributes, metrics, and resources. They improve interoperability only when producer and consumer agree on the convention and stability level. A renamed HTTP route attribute can break dashboards even though export remains healthy.

Treat telemetry schema like an API. Name an owner, version changes, bound cardinality, test redaction, announce deprecations, canary consumers, and keep rollback. “It is only observability data” is not a reason to skip change control; alerts, SLOs, incident queries, and cost models depend on it.

### Self-telemetry and the measurement paradox

**Self-telemetry** is evidence about the instrumentation and pipeline themselves: generated, sampled, accepted, refused, filtered, queued, retried, sent, failed, dropped, ingest delay, and query freshness. Without self-telemetry, absence at the screen is ambiguous.

But self-telemetry also travels through systems that can fail. A Collector can stop reporting its own drop counter when it crashes. That is why important pipeline health needs both inside evidence and outside checks: process state, scrape freshness, synthetic flow, destination freshness, and change history.

The durable rule is simple: **measure the measurement path, and keep an independent way to detect when that measurement goes silent.**

## Architecture map

The easiest way to understand OpenTelemetry architecture is to follow ownership, not logos. Ask who creates meaning, who transports it, who is allowed to transform it, and who can prove it arrived.

### Diagram 1: API to SDK to two Collector tiers

```text
REAL OPERATION
    |
    v
+---------------- application process ----------------+
| business code / framework                            |
|        |                                              |
|        v                                              |
| OpenTelemetry API <- manual + library instrumentation|
|        |                                              |
|        v                                              |
| SDK: resource -> sampler -> processor -> finite batch |
|        |                                              |
|        v                                              |
| OTLP exporter                                         |
+--------|----------------------------------------------+
         | OTLP request: protocol + endpoint + identity
         v
+---------------- agent Collector ---------------------+
| receiver -> ordered processors -> exporter queue     |
+--------|----------------------------------------------+
         | OTLP request: another independent boundary
         v
+---------------- gateway Collector -------------------+
| receiver -> policy/processors -> exporter queue      |
+--------|----------------------------------------------+
         |
         v
local sink / backend ingest -> storage/index -> query
```

The API owns the vocabulary visible to instrumented code. The SDK owns recording, sampling, processing, and in-process export. The application team usually owns the operation boundary and attribute meaning even if a platform team supplies defaults. The agent owner controls the first external receiver and local buffering. The gateway owner controls shared policy and destination credentials. The backend owner controls ingestion, retention, indexing, and query.

Notice that there are two OTLP requests. The application exporter can succeed because the agent accepted a batch while the agent-to-gateway export later fails. If you only alert on application export errors, you miss that gap. If the agent reports successful export, the gateway may still filter the records. “OTLP succeeded” is incomplete unless you name which hop and what success means there.

An agent-plus-gateway topology adds hops for a reason: local discovery, isolation of application credentials, centralized policy, load distribution, or tail sampling. It also adds queues, versions, capacity limits, and failure domains. A single Collector can be better for a small system. Architecture is a trade-off, not a maturity badge.

### Diagram 2: context propagation is a data and trust path

```text
producer process                                  consumer process

active span                                             no context yet
 trace=T                                                |
 span=P                                                 |
    |                                                   |
    v                                                   |
[ propagator.inject ]                                   |
    | writes traceparent/tracestate/baggage             |
    v                                                   |
+---------------------- carrier ------------------------+
| HTTP headers or message properties                    |
| values can be absent, forged, duplicated, or oversized|
+----------------------|--------------------------------+
                       v
              [ trust-policy validation ]
                       |
                       v
              [ propagator.extract ]
                       |
              valid remote parent P ?
                    /         \
                  yes          no
                  /             \
       create child C        create new root R
       trace=T parent=P      record reason/metric
```

Injection happens while the producer's context is active. If a callback runs later after the context was detached, the propagator can faithfully inject “nothing.” The queue or network is then innocent. Conversely, correct injection does not prove the carrier preserves the field. Some message libraries require properties to be explicitly copied; retries can rebuild a message without metadata.

At extraction, syntax comes before trust. A valid external trace ID may be accepted for correlation under policy, but it must never authorize access. Some organizations restart traces at an ingress boundary and keep a safe link to external context. Others continue the trace but discard unapproved tracestate and baggage. The correct choice depends on threat model and interoperability requirements.

For asynchronous work, parent-child is not always the most faithful model. Suppose one worker batch processes 100 messages. Making the batch span a child of one message falsely privileges that message. A batch span with links to bounded message contexts may describe the relationship better. The convention and backend must support the intended analysis; otherwise record the limitation.

### Diagram 3: declared components versus enabled pipelines

```text
top-level declarations

receivers:                  processors:              exporters:
  otlp/app                    memory_limiter            otlp/gateway
  otlp/unused                 batch                     debug/review
                              filter/noise

                    declarations do not create flow
                                  |
                                  v
service:
  pipelines:
    traces/app:
      receivers:  [otlp/app]
      processors: [memory_limiter, filter/noise, batch]
      exporters:  [otlp/gateway]

runtime order for traces/app

otlp/app -> memory_limiter -> filter/noise -> batch -> otlp/gateway

otlp/unused and debug/review remain declared but are not in this graph.
```

The example is conceptual, not configuration guaranteed for a particular release. What matters is the graph. A top-level component declaration gives a named configuration. A service pipeline selects component instances and fixes processor order for a signal. Reordering processors can change both data and safety. A memory limiter placed after a memory-expensive processor cannot protect that earlier work. A redaction processor placed after a debug exporter cannot undo exposure already sent.

Pipeline names are local configuration identities; they do not travel with each span unless you deliberately add bounded evidence. Component instances can be reused by several pipelines, which couples capacity and failure. A slow exporter can affect all pipelines that share its queue or resources depending on implementation.

### Control plane, data plane, and evidence plane

The **control plane** is configuration, deployment, feature flags, credentials, and ownership. It answers what should be running. The **data plane** is actual telemetry traffic and processing. It answers what crossed. The **evidence plane** is how you observe both: startup logs, internal metrics, outside probes, sink records, configuration hashes, and change events.

During an incident, operators often inspect only the control plane: “the YAML contains the exporter.” Or only the data plane endpoint: “port 4317 accepts a connection.” A strong diagnosis joins all three:

```text
declared intent -> exact deployed configuration -> enabled runtime graph
               -> bounded input -> per-boundary deltas -> destination record
```

Each arrow needs evidence. A configuration repository is not the deployed configuration. A running process is not the enabled graph. An accepted connection is not a valid OTLP export. A backend record is not proof that every record arrived.

### Where to put policy

Put a rule at the earliest boundary that has enough trustworthy information and an owner who can operate it safely. Examples:

- Stable business operation naming belongs close to application code because only that owner knows the operation.
- Secret or sensitive-value exclusion belongs at instrumentation, before data leaves process memory. A downstream redactor is defense in depth, not permission to emit unsafe data.
- Host metadata enrichment may belong at an agent that can discover it without giving every application broad access.
- Tenant routing and backend credentials often belong at a gateway, but the gateway must not infer tenant authority from untrusted baggage.
- Tail sampling belongs where enough spans of a trace can meet under a consistent policy and bounded memory.

Centralization increases consistency but also blast radius. Decentralization improves isolation but creates version and policy drift. The architecture review should name which failure you prefer and how you detect it.

## Request or state path

Follow one fictional but realistic operation: an API accepts a checkout, places a message on a queue, and a worker finalizes payment. We will track workload state, context state, telemetry state, and ownership separately.

### Step 0: define success before instrumentation

The user operation is not “a span exists.” Define it in business terms:

```text
eligible population: checkout submissions accepted by API version v43
success: one durable payment outcome and one durable order confirmation
failure: terminal rejection, timeout without durable result, or duplicate charge
time boundary: API acceptance through durable completion
```

This definition gives you an unsampled denominator and outcome source. Tracing will explain selected paths; it must not replace the durable outcome record.

### Step 1: inbound extraction and server span

At the API ingress, framework instrumentation reads an approved carrier. It validates the context according to the propagator and trust policy. If valid and allowed, it creates a server span with the remote parent. If absent or invalid, it creates a new root and increments a bounded reason metric such as `context_start_total{reason="missing"}` or `reason="invalid"`. The exact metric name is a design example, not an OpenTelemetry standard.

The span name should represent a stable operation or route template, not a raw URL containing order IDs. Attributes should use the current semantic convention and a reviewed application schema. Never attach card numbers, authorization headers, raw message bodies, customer email, access tokens, or unconstrained error text.

State now exists in several places:

- the real request and its business state;
- active in-process context;
- an SDK span object that may be recording or non-recording;
- process memory owned by a processor or batcher;
- perhaps no external telemetry yet.

If the process crashes before export, a reported operation may never leave memory. That is a telemetry loss question, separate from whether business state committed.

### Step 2: queue message production

The API creates a producer span or message-operation span according to the current messaging convention. While that span's context is active, the propagator injects approved fields into message properties. The application then publishes the payload and properties.

There is an important ordering question: did injection occur before the exact serialized message was built? A trace header added to an in-memory object after the client library already copied properties changes nothing on the wire. Instrument the actual carrier passed to the library, or use supported instrumentation.

Message publication can retry. Decide whether retries remain attempts inside one logical operation, separate child spans, or events. Preserve an attempt number as a bounded integer, not a unique retry ID in metric labels. If a retry rebuilds the carrier, ensure propagation repeats from the intended context.

### Step 3: SDK processing and application export

When spans end, the SDK's processor handles them. A simple processor may export synchronously; a batch processor normally queues and exports asynchronously. Synchronous export can directly add user latency and amplify backend failures. Asynchronous batching protects the request path but creates memory, shutdown, and loss boundaries.

At this point ask:

- Was the span recording?
- What sampler decision applied at the root?
- Did a parent-based decision inherit an upstream flag?
- Was the span handed to the processor?
- Did the batch flush because of size, time, or shutdown?
- Was the queue full?
- Did exporter success mean accepted by the agent?

A graceful shutdown may flush within a deadline. A forced process exit may not. Never extend shutdown indefinitely for telemetry if doing so violates service recovery or orchestrator deadlines. Define a finite flush budget and measure lost records.

### Step 4: agent receive, process, and export

The agent's OTLP receiver decodes a request and attributes it to the protocol boundary. Accepted means the receiver admitted data according to that component. It may still encounter a memory limiter, filter, transformation, batch, or exporter failure.

Processor order is observable behavior. For example:

```text
receive 120 spans
  -> memory limiter refuses 0
  -> filter removes 20 known noise spans
  -> transform rejects 2 malformed records
  -> batch exports 98
```

If the agent exporter reports 98 accepted by the gateway, that can reconcile. If the gateway receives 96, units, retry duplication, scrape intervals, resets, and timing must be checked before declaring two lost. Counters may count requests at one component and items at another.

### Step 5: context survives the queue independently of telemetry export

The worker receives the message even if the API's span export failed. It reads the carrier properties and extracts context. If extraction succeeds, it starts a consumer or processing span with the intended remote relationship. If it starts a new root, inspect the context path:

```text
producer active context
 -> injection called
 -> property serialized
 -> broker retained property
 -> consumer received property
 -> policy allowed field
 -> extraction succeeded
 -> extracted context made current
 -> worker span created before context detached
```

The Collector is absent from this chain. It receives spans after creation. Restarting it cannot repair parentage already encoded in the spans.

### Step 6: gateway policy and tail decision

The gateway receives agent exports. A traces pipeline may apply shared transformations or tail sampling. Tail sampling needs a trace assembly state keyed by trace ID. The gateway waits until a decision condition or timeout, evaluates ordered policies, then releases or drops the trace.

If gateway replicas receive arbitrary spans, spans from one trace can split. Each replica sees an incomplete trace and may make a different decision. A routing layer or compatible architecture must co-locate trace fragments for the decision window. Consistent routing itself becomes a capacity and availability boundary.

Late spans can arrive after a tail decision. The exact component decides whether to drop, forward, or handle them another way. Do not invent a default; inspect the pinned component's documentation and metrics. Tail pending count, decision latency, timeout, eviction, memory, and late-span evidence belong in the operating contract.

### Step 7: backend ingest, indexing, and query

Gateway export success is the beginning of backend ownership. A backend may accept a request, persist later, index selected fields, enforce tenant or retention policy, and expose data to queries after delay. Separate:

```text
transport accepted -> ingest admitted -> durable write -> indexed -> queryable
```

Not every backend exposes every stage. Where proof is unavailable, say so. Use a synthetic canary record with sanitized fixed attributes and a bounded freshness SLO if organizational policy allows. Alert on last successful end-to-end visibility, not only Collector process readiness.

Query scope can manufacture absence. Check tenant, environment, service identity, operation name, trace ID syntax, time basis, ingest delay, retention, and filters. A trace that began at 14:19 on a skewed host may not appear in a narrow event-time window even though ingest occurred at 14:21.

### Step 8: close the operation and the evidence contract

Recovery is not “the trace appeared.” Close both paths:

- the user operation completes correctly for the affected cohort;
- no duplicate or abandoned durable state remains;
- queue backlog and oldest age recover;
- context continuity is restored for new controlled operations;
- SDK, agent, gateway, and sink counts reconcile within documented semantics;
- ingest and query freshness return to budget;
- no unsafe attributes or baggage remain in newly emitted data;
- the condition does not recur over a meaningful window.

If records were permanently lost, say which interval and population are unknowable. Do not backfill synthetic spans as if they were original evidence.

## Failure zoom

The four incidents in the metadata are not trivia questions. They are patterns that teach where reasoning usually goes wrong.

### Incident 1: the worker becomes a new root

**Symptom:** API and producer spans share trace `T1`. The worker span reports trace `T9` with no remote parent.

**Tempting conclusion:** the message broker removed the trace header.

That is one hypothesis, not the conclusion. Rank mechanism-based hypotheses:

1. Injection ran with no active producer context.
2. Injection wrote to an object other than the serialized carrier.
3. Broker or client policy removed the property.
4. Consumer received it but extraction was not configured for that propagator.
5. Extraction rejected malformed or disallowed context.
6. Extracted context existed but was not made current when the worker span started.
7. The workload is batch or fan-in and the intended relationship should be links rather than a parent.

Use one sanitized message in a disposable target. At each boundary, record only presence, syntax class, a safe hash if approved, and parentage—not raw baggage or customer data. Expected branches matter. If injection output is absent, the broker is downstream of the first proven gap. If the consumer carrier contains a valid context but the worker starts a new root, focus on extraction and scope. If the worker reports a link by design, the graph may be correct while the query assumes a tree.

The safe remediation is at the earliest owned failing boundary: run injection while the intended context is active, preserve approved carrier properties, configure the correct propagator, make extracted context active for span creation, or model links deliberately. Re-run one operation and prove both correct workload outcome and parentage. Do not copy IDs manually between spans.

### Incident 2: every component is green, the backend is empty

**Symptom:** application export has no reported error, agent readiness is green, gateway readiness is green, and a backend search returns no records.

“Green” questions might be:

- process answers the health endpoint;
- configuration parsed;
- receiver port is listening;
- exporter object initialized.

None asks whether a trace crossed. Walk one operation with deltas:

| Boundary | Observation | If it changes | If it does not |
|---|---|---|---|
| application operation | fixed request outcome and operation counter | workload ran | fix workload scope first |
| SDK/exporter | generated, sampled, export result | SDK handed off | inspect SDK config and sample decision |
| agent receiver | accepted item delta | first OTLP hop reached agent | inspect endpoint, protocol, identity, network |
| agent exporter | sent/failure/drop delta | agent attempted next hop | inspect pipeline membership and processors |
| gateway receiver | accepted/refused delta | second hop arrived | inspect agent exporter response and gateway listener |
| gateway exporter | sent/failure/drop delta | gateway sent onward | inspect ordered processors and exporter |
| sink ingest | admitted record delta | destination saw input | inspect export contract and tenant |
| query | exact fixed record visible with freshness | query path works | inspect indexing delay, time, retention, filters |

A classic root cause is a receiver or exporter declared but not referenced by a service pipeline. The process starts cleanly because unused declarations are syntactically valid. Restarting reproduces the same disabled graph. The prevention is a configuration test that renders the exact deployment, validates with the exact distribution, asserts required pipeline membership and order, sends a bounded canary, and checks destination freshness.

### Incident 3: error traces disappear under mixed sampling

**Symptom:** application head sampling keeps ten percent. The gateway tail sampler says it retains errors and slow traces. Only a fraction of known errors appear.

The key logic is irreversible:

```text
root created
  |
  +-- head drops -> no recorded/exported trace reaches tail sampler
  |
  +-- head keeps -> spans may reach tail sampler
                     |
                     +-- complete enough -> policy decision
                     +-- split/late/evicted -> incomplete decision
```

The tail sampler cannot select a trace it never receives. Parent-based sampling also means an upstream unsampled flag can suppress descendants, depending on configuration. If different services use different samplers or ignore parent decisions, traces become partial and biased.

Now add multiple tail-sampler replicas. Without trace-aware routing, service A's spans reach gateway 1 and service B's spans reach gateway 2. Each waits, times out, and decides from half a trace. Increasing the retention percentage does not repair assembly.

Use unsampled outcome counters to establish the real error population. Then measure root decision counts, sampled flags, spans reaching the gateway, traces pending, policy matches, timeouts, eviction, late spans, and per-trace routing. Decide deliberately between head-only, parent-based head, tail, or a composed design whose limitations are understood. Never calculate error rate from retained error-biased traces.

### Incident 4: observability harms the service and leaks data

**Symptom:** after enabling instrumentation in ten percent of instances, p99 rises 18 percent, CPU rises 12 percent, and a review finds raw customer fields in baggage and span attributes.

Treat this as two incidents: workload regression and potential data exposure. Stop progression at the canary. Use the approved disable or rollback path. Compare canary versus control for user outcomes, latency distribution, CPU, allocation, memory, payload bytes, spans per operation, attributes per span, synchronous callbacks, batch behavior, and export pressure. One average CPU graph is not enough.

Do not paste raw telemetry into chat, tickets, or assessment evidence. Record field names, classification, location, count, retention scope, and a sanitized fingerprint under incident policy. Notify the data-security owner. Remove unsafe values at instrumentation, rotate credentials only if evidence indicates exposure, and follow deletion or retention procedures for already exported data.

Why queues are not the complete fix: a larger SDK queue can reduce immediate drops, but it consumes application memory and can make shutdown slower. Sampling can reduce volume, but unsafe fields remain unsafe in every retained record and baggage still propagates before sampling depending on implementation. The long-term fix is a reviewed schema allowlist, baggage policy, overhead budget, canary test, and kill switch.

### Failure combinations are normal

Do not assume only one failure. A deployment can break context while a Collector policy simultaneously filters the new operation name. A backend outage can fill a queue while an application rollout increases span volume. Build hypotheses that can coexist, and choose observations that distinguish boundaries without erasing another failure's evidence.

## Internals and state ownership

When a pipeline fails, ask “who owns the bytes right now?” That question prevents blind restarts.

### Application and SDK state

The application owns active context and span lifecycle. Instrumentation owns operation boundaries and attribute meaning. The SDK owns sampler configuration, resource identity, processors, in-memory batches, exporter clients, and shutdown behavior. Platform defaults do not remove application ownership of sensitive fields or business semantics.

In-process state can be lost on crash. A batch processor usually trades request isolation and throughput efficiency against a finite loss window. If the application exporter blocks, it may consume request threads or SDK workers depending on design. Measure overhead from the user boundary.

### Carrier and transport state

The producer owns injection into the exact carrier. The messaging or HTTP library owns serialization and transport. Intermediaries may enforce header size, allowlists, or transformations. The consumer owns extraction and scope activation. Security owns the trust policy for external context and baggage.

Do not assume a trace ID proves that two records concern the same authenticated principal. IDs can be guessed, copied, or maliciously supplied. Treat them as correlation material with privacy implications.

### Collector state

The Collector process owns component instances, pipeline graph, in-memory queues, optional persistent queues, retry timers, processor state, credentials, and internal telemetry. Exact ownership depends on the distribution and configuration.

An in-memory queue disappears with process loss. A persistent queue may survive process restart but creates disk capacity, permissions, corruption, encryption, and lifecycle obligations. Persistence does not imply exactly-once delivery. If an export outcome is ambiguous, retry can duplicate data unless the downstream protocol or backend deduplicates according to a known contract.

The gateway's shared policy has broad blast radius. A filter expression error can remove every trace for a service. A transformation can rename fields used by alerts. Tail sampling can accumulate large state. Configuration rollout therefore needs versioned artifacts, static validation, bounded end-to-end tests, canaries, and immediate rollback.

### Backend and query state

The destination owns admitted payloads, tenant mapping, durable storage, retention, indexing, access control, aggregation, and query. The pipeline owner must understand enough of this contract to interpret exporter success and data freshness. If the backend offers only “accepted,” do not relabel it “durably stored.”

Queries create derived state through caches, saved searches, dashboards, recording rules, and alerts. A dashboard can remain green from stale data. Always expose data timestamp or age when freshness matters.

### Ownership matrix

| State or decision | Primary owner | Durable? | Main failure | Minimum evidence |
|---|---|---:|---|---|
| operation name and boundary | application team | in code/config | unstable names or wrong lifecycle | schema review and controlled operation |
| active context | application/runtime | no | task/thread scope loss | inject/extract and parentage evidence |
| carrier fields | producer, transport, consumer | transport-dependent | removed, malformed, forged, oversized | bounded carrier boundary checks |
| SDK sample decision | application/platform config | maybe logged/metric | biased or inconsistent policy | root/parent decision counts and config version |
| SDK batch and queue | application process | usually no | memory pressure, drop, shutdown loss | queue, drop, flush, overhead metrics |
| agent pipeline | node/workload platform | config plus runtime | disabled path, local exhaustion | deployed config, runtime graph, deltas |
| gateway policy | observability platform | config plus runtime state | shared filtering, tail eviction, outage | canary, policy result, capacity, loss |
| export retry | exporter/Collector | memory or disk | storm, expiry, duplication | attempt, result class, age, final loss |
| backend record | backend team | contract-dependent | tenant, ingest, retention, index delay | ingest acknowledgement and query freshness |
| dashboard result | dashboard owner | cached/derived | stale or wrong scope | query text, time, tenant, freshness |

### Shutdown and restart ownership

Restart is a mutation, not a diagnostic. Before restarting an application or Collector, capture:

- exact process and deployment identity;
- configuration or artifact version;
- queue occupancy and oldest age;
- retry state and permanent drop counters;
- recent startup and exporter errors;
- destination freshness;
- whether another owner is changing the target;
- what in-memory evidence restart destroys;
- rollback and post-restart recovery conditions.

If a queue is full because the backend is unavailable, restart can discard the backlog and make the queue graph look healthy. That is not recovery. Recovery means new and queued records follow the declared policy, permanent loss is quantified, and user workloads remain healthy.

## Evidence table

Use this table as a field checklist. Each row asks one bounded question and explicitly limits the inference.

| Question | Preferred evidence | Useful branch | Does not prove |
|---|---|---|---|
| Did the real operation occur? | durable business outcome plus request counter | outcome changes or does not | telemetry creation |
| Did instrumentation create a span? | SDK generated/ended count and controlled test | created, no-op, or exception | span left process |
| Was the root sampled? | sampler decision and sampled flag with config version | keep/drop by branch | representative population |
| Was context injected? | sanitized carrier presence and valid syntax after inject | present/absent/invalid | carrier transport or trust |
| Did the carrier survive? | compare producer serialization with consumer properties | preserved/removed/changed | extraction or parent activation |
| Did extraction work? | extraction result class and downstream parentage | remote parent/new root/link | authenticity or causality |
| Did SDK export? | bounded exporter result, queue, and drop delta | accepted/retry/permanent failure | agent processing or durability |
| Did agent receive? | accepted/refused item delta for exact receiver | input/no input/refusal | processor or export outcome |
| Did a processor alter data? | before/after counts and policy match by bounded pipeline | retained/filtered/error | intended business correctness |
| Did agent send to gateway? | exporter sent/failed/retried/drop delta | sent/retry/loss | gateway accepted unless reconciled |
| Did gateway enable the path? | deployed config plus runtime pipeline/startup evidence | member/not member | data flow until bounded input |
| Did tail sampling see a full trace? | routed span count, pending state, timeout, eviction, late span | complete/partial/unknown | unsampled root population |
| Did destination ingest? | destination-side admission and timestamp | admitted/refused/delayed | durable retention unless contract says so |
| Is the record queryable? | exact sanitized canary query with ingest age | visible/stale/absent | all records visible |
| Is absence meaningful? | producer plus every boundary's freshness and loss evidence | workload absent/pipeline gap/query gap | causality without more evidence |
| Did rollout harm users? | canary/control outcomes and resource distributions | within/over budget | long-term safety from short window |

### Observation, calculation, inference, and hypothesis

Label incident notes so confidence is visible:

- **Observation:** `gateway_receiver_accepted_spans` did not change between two timestamped scrapes for one fixed request.
- **Documented contract:** agent exporter success means the gateway accepted the OTLP request according to the pinned protocol implementation.
- **Calculation:** agent export increased by 12 items while gateway receive increased by 0 in the aligned interval.
- **Inference:** the earliest demonstrated gap is between agent exporter accounting and gateway receiver accounting, subject to unit, reset, and scrape alignment.
- **Hypothesis:** the agent uses the wrong gateway endpoint.
- **Unknown:** whether a middle proxy accepted and discarded the request.

This vocabulary is not bureaucracy. It stops a calculation from becoming an invented fact.

### Reconciliation rules

Before subtracting counters:

1. Confirm both counters count the same unit—spans, requests, batches, bytes, or traces.
2. Check monotonicity and resets.
3. Align scrape and flush windows; asynchronous batches can cross boundaries after the request.
4. Account for intentional filters, sampling, duplication, retry, and fan-out.
5. Include refused and dropped paths.
6. Record uncertainty if a component does not expose a stage.

A useful invariant may look like:

```text
received_items
= intentionally_filtered
+ processing_failed
+ exported_items
+ queued_at_end
+ permanently_dropped
+ unexplained_difference
```

The exact terms vary. The value of the equation is that unexplained difference remains visible instead of being waved away.

## Command decoders

The metadata contains twelve command records. This section teaches how to read them. Do not run the draft fixture until its support README, locks, and verifier are complete. Output shown here is illustrative shape, not captured execution.

### Command 1: preflight is a stop/go contract

`bash lab.sh doctor` should answer whether the caller and local environment satisfy the fixture contract. Decode each line as a separate prerequisite: operating system, normal-user identity, required command path, Docker client, daemon reachability, Compose plugin, required ports, lock completeness, local image identity, configuration render, and exact Collector validation where implemented.

If Docker Desktop is open but the Ubuntu client cannot reach its daemon, the correct conclusion is “this Ubuntu context cannot currently reach the configured daemon,” not “Docker is broken.” Check WSL integration, Docker context, socket visibility, and client output without installing another daemon blindly.

A doctor pass is not setup. It should not create containers or pull images. If preflight mutates the environment, it becomes harder to distinguish discovery from preparation.

### Command 2: digest locks define content, tags select names

An image tag such as `collector:1.2` is a mutable name unless the registry policy guarantees otherwise. A digest identifies content. A robust lock uses an immutable digest and records the intended platform where needed. Local inspection should compare the lock with the image content Docker resolves, not merely show a familiar tag.

Branches:

- Matching digest: local content identity matches the lock. Signature, provenance, vulnerability, and suitability are still separate checks.
- Missing image: offline setup must fail. Pull only through an explicit approved prepare step.
- Mutable-only or mismatched value: the package is not ready for offline execution or promotion.
- Platform mismatch: an image can be locked yet unusable on the current architecture.

Never replace a missing digest with `latest` to “make the lab work.” That converts a reproducible proof into an unknown download.

### Command 3: render first, validate with the exact binary

Compose rendering resolves variables, merges files, expands defaults, and shows the topology Docker will receive. Inspect service names, image digests, networks, ports, mounts, read-only flags, capabilities, health checks, and environment. Redact secrets; the fixture should use no real secret.

Collector validation must use the exact locked distribution because component availability and configuration evolve. Static acceptance proves syntax and recognized components. It cannot prove a receiver is reachable, a pipeline is enabled, or an exporter can authenticate.

The guarded interface for this stage is `bash lab.sh validate-configs`. The current digest-pinned Collector Contrib 0.157.0 path passed for all three configurations. Acceptance requires more than exit zero: the verifier observes start/attach, an exited process, nonzero timestamps, exit code zero, exact container removal, and a specific Docker not-found result. This remains configuration evidence, not flow evidence.

### Command 4: parse traceparent without trusting it

The Python one-liner demonstrates four version-00 checks:

- exactly four lowercase hexadecimal fields of the expected lengths;
- trace ID is not all zero;
- parent ID is not all zero;
- version is not the forbidden `ff` value.

It deliberately does not implement the full future-version processing model, duplicate header handling, `tracestate`, size policy, or organizational trust policy. That is why the result says “valid under this bounded parser,” not “safe.” Production code should use a conforming maintained propagator rather than a homemade regular expression.

### Command 5: setup must be offline and ownership-safe

`bash lab.sh setup` expresses an important lifecycle split. The wrapper, not a learner-supplied flag, must enforce and report `runtime_pull_policy=never`:

```text
prepare: optional, explicit, networked/cache-populating, policy-controlled
setup:   offline, deterministic, exact local locks only
```

If setup needs a missing image, it fails. It must not surprise the learner with a registry download. Before creation, it checks exact names and guarded ownership. If a matching name already exists without the fixture's ownership record, it refuses instead of deleting or adopting it.

Readiness means the fixture's declared local endpoints answered within a timeout. It does not mean parentage or pipeline flow works. Cleanup remains required even when setup fails halfway.

### Command 6: one fixed request creates a denominator of one

`bash lab.sh run baseline` sends one sanitized request through the exact validated service A container and assigns a fixture-controlled operation identity. No host port is published. The current draft records:

- workload response and one operation identifier;
- source, queued-worker, and downstream trace/span relationship fields;
- the bounded in-process carrier keys and joined-context result;
- an evidence binding to current container identities, configuration/source/artifact hashes, and operation timestamps;
- bounded, sanitized gateway evidence lines for the operation and trace identifiers;
- SDK ended/export-success counters, agent receive/process/export counters, gateway receive/process/export counters, debug-sink visibility, units, timestamps, freshness, and process-start reset identities.

With one operation, “one expected trace” is understandable. It is still possible to create multiple spans, retries, or duplicate exports. Current-window identifier visibility is partial evidence, not accepted/exported/sink reconciliation. The wrapper must state its invariant rather than assume one request equals one span.

### Command 7: compare relationships, not a pretty waterfall

Status should show a sanitized graph:

```text
span=api       trace=T parent=remote-or-none
span=producer  trace=T parent=api
span=consumer  trace=T parent=producer-or-link=T/P
span=payment   trace=T parent=consumer
```

Check trace ID continuity and each expected parent or link. A waterfall can visually join spans after a query or clock transformation, so inspect identifiers and semantic roles. Duration overlap does not prove parentage. Parentage does not prove the parent caused latency.

If the worker is a new root, return to carrier evidence. If all relationships match but a span is missing, investigate instrumentation lifecycle, sampling, and export.

### Command 8: status separates bound evidence from missing evidence

The current status interface exposes evidence-record hashes, sanitized relationship fields, resource/configuration bindings, bounded gateway evidence, baseline source/SDK/agent/gateway/sink deltas, units, freshness, process-reset boundaries, and the outage experiment's refusal/retry/drop values. It reports completion only when all five recognized records are present and each one revalidates against the active lifecycle.

Reason from the earliest gap: agent accepted without agent sent points toward the agent processor, queue, or exporter; agent sent without gateway accepted points toward transport, listener, protocol, or identity; gateway accepted without gateway sent points toward the enabled processor/exporter path. The fixture demonstrates that reasoning for one synthetic path only. Avoid streaming unbounded logs, and use synthetic data because debug exporters may copy complete telemetry payloads into logs.

### Command 9: deltas need aligned windows and reset handling

`bash lab.sh verify-operation --expect-token TOKEN` requires all five records. It revalidates action, time, lifecycle, state/root identities, locks, Compose, configs, service sources, stable resources, network, workload IDs, bounded evidence hashes, direct parentage, per-hop deltas, queue/retry/drain, and deterministic sampling. A normal operation may not cross a process start. The outage must cross exactly the gateway process start, so its new-process gateway counters are compared from zero while unchanged service and agent counters remain deltas.

The verifier's invariants are code, not universal truth. Review them. If it asserts accepted equals sink count, confirm there is no intentional filter, batching still in flight, retry duplication, or signal fan-out. A passing verifier proves only its encoded model on that exact run.

### Command 10: fault and recovery are separate outcomes

The broken-context action should change exactly one owned boundary, for example disabling propagation of approved carrier properties in the fixture. The resulting worker new root is expected evidence, not a test failure if the lab contract says so. `recover-context` must restore from an ownership-checked baseline, not overwrite arbitrary files.

The shell command stores the first exit status and invokes recovery. Review the wrapper's documented status convention; an expected incident may return zero because it successfully demonstrated the fault, or a specific nonzero code. Do not assume. Most important, verify recovery even if the fault action fails.

### Command 11: a queue interruption teaches capacity, not heroics

`bash lab.sh interrupt-gateway` selects the exact fixture gateway, stops it through an owned mechanism, sends four requests with timeouts, forces both SDKs to flush, samples the two agent queues, captures bounded retry-sender records, restores the gateway in `finally`, and reconciles the resulting twelve spans. Record the exact evidence:

```text
request_count = 4
gateway stop-control timeout = 3 seconds (not outage duration)
agent queue capacity and peak occupancy = measured queue items
retry attempts = bounded retry-log records
oldest queue residence = controller-observed lower bound in seconds
gateway-only process reset = validated from process start identity
post-restart gateway receive/process/export = 12 spans
agent queues after recovery = 0 items
refused and dropped = measured 0 spans for this window
backend ingest and production behavior = not proven
```

The exact agent config uses one-span batches and one exporter consumer so queue items have a declared one-span meaning during this experiment. Docker's `stop --time 3` remains a graceful-stop timeout, not the outage duration. The observed residence value is a lower bound from the first completed outage request to proven drain, not an internal oldest-item metric. Never generalize this bounded result to arbitrary outage duration, saturation, process crashes, or durable delivery.

### Command 12: sampling comparison ends with cleanup

The comparison should use a small known population with known success, error, and latency attributes, then report which records each fixture policy retained. It must not claim statistical performance from a tiny deterministic set. The point is decision location and bias.

Cleanup runs regardless of comparison status. Final absence is part of the command's evidence, not housekeeping. Status must prove that exact containers, network, state, and operation records are absent while unrelated resources remain. Do not use `docker system prune`, `docker container prune`, `docker volume prune`, or broad filesystem deletion.

## Decision path

An incident decision path should help you act when the screen is unfamiliar. It must be ordered enough to protect evidence and flexible enough to follow what you find.

### 1. Protect the user and bound authority

First ask whether telemetry work is harming the application. Look for latency, CPU, memory, thread, connection, disk, and network pressure; unsafe payloads; or a shared gateway failure affecting many services. If user impact is active, apply the approved reversible containment with the smallest blast radius: stop a canary rollout, disable one instrumentation feature through its owned switch, reduce nonessential telemetry under policy, or fail open at the telemetry boundary if the design permits.

Do not restart, scale, edit policy, or increase queues until you know the target, owner, rollback, and evidence that action destroys. Do not copy raw spans if they may contain secrets or personal data. Establish the allowed incident scope.

### 2. Write the evidence contract

In two minutes, write:

~~~text
operation:
population/cohort:
user-success definition:
time window and timezone:
workload boundary:
telemetry boundary:
known change:
available evidence:
unavailable evidence:
one allowed reversible action:
abort conditions:
recovery proof:
~~~

This turns “tracing is broken” into a testable claim. Include the telemetry freshness budget. If backend ingest normally lags two minutes, absence after ten seconds is not yet a delivery failure.

### 3. Prove the workload path independently

Use the durable outcome source and bounded request evidence. Branch:

- **Workload failed and telemetry is present:** use telemetry to localize the workload failure while checking its sampling and completeness limits.
- **Workload failed and telemetry is absent:** investigate both paths. Do not let the telemetry incident hide user impact.
- **Workload succeeded and telemetry is absent:** the first known failure is in measurement or query, not the business outcome.
- **Workload outcome is unknown:** restore an independent outcome source before claiming either health or failure.

### 4. Pick one fixed operation

A controlled fixed operation is easier to reconcile than a ten-minute production aggregate. Give it sanitized stable attributes and capture event time, observed time, and ingest time where available. Do not put its unique identity in metric labels. Use a trace or log lookup under access policy.

### 5. Walk producer to destination

At each boundary ask four questions:

1. What entered?
2. What intentionally changed?
3. What left or remains queued?
4. What failed, was refused, retried, or dropped?

Stop at the earliest boundary where observations diverge from the contract. Downstream emptiness is then an effect. Continue far enough to detect a simultaneous failure, but do not mutate every layer.

### 6. If parentage breaks, leave the Collector alone at first

Compare active context, injection, serialized carrier, received carrier, extraction, scope activation, and span creation. Validate W3C syntax and trust policy. Decide whether a parent or links correctly represent the work. The Collector can filter or lose a span, but it cannot rewrite an already-created new root into the child that instrumentation failed to create.

### 7. If components are green but flow is absent, compare graph to text

Confirm exact deployed configuration, exact binary or image, service pipeline membership, processor order, startup component identities, and bounded receive/export deltas. Readiness is only one observation. A configured-but-disabled receiver is a control-plane defect whose data-plane symptom is zero receive.

### 8. If retained traces disagree with outcome counters, map sampling

### Diagram 4: sampling location changes what can be known

~~~text
known root population from unsampled outcome counter
                         |
                         v
                 head decision at root
                   /               \
              discard             record/export
                |                      |
       invisible to tail               v
                              parent decision carried?
                                 /             \
                              yes               broken/mixed
                               |                    |
                         coherent branch       partial traces
                               \                    /
                                v                  v
                         trace-aware routing to tail
                                      |
                           collect until decision/timeout
                              /          |          \
                         retain        discard      evict/late
~~~

Write down every decision:

- root sampler and probability or rule;
- parent-based branches for remote and local parents;
- whether unrecorded or unsampled spans are exported;
- gateway routing key and number of decision shards;
- tail wait, policy order, memory limit, timeout, and late-span behavior;
- destination or query sampling.

Then state the claim limit. A tail policy that keeps every received error trace still cannot estimate the true error rate if head sampling discarded roots or if known errors never reached the decision point.

### 9. If queues rise, calculate the mismatch

Name units before arithmetic. Suppose a queue has 200,000 free span slots, new spans arrive at 18,000 per second, and sustainable export is 13,000 per second:

~~~text
net growth = 18,000 - 13,000 = 5,000 spans/second
time to full = 200,000 / 5,000 = 40 seconds
~~~

Doubling free space buys another 40 seconds under those simplified conditions. It does not restore equilibrium. Identify whether arrival changed, consumer capacity fell, retries consume throughput, payloads grew, or processing became more expensive. Protect the application, restore consumer rate or reduce approved nonessential load, and monitor oldest age as well as occupancy.

### 10. Choose one discriminating change

Prefer read-only evidence. If a mutation is necessary, change one owned variable with a baseline and rollback:

- add the existing receiver to the exact traces pipeline;
- restore an approved carrier propagation hook;
- route one canary trace consistently to one tail decision shard;
- roll back one instrumentation release;
- correct one endpoint or tenant in a canary.

State expected branches before acting. “If this hypothesis is correct, agent export succeeds and gateway receive increases for the fixed operation; if it does not, restore the baseline and inspect transport identity.” This prevents success from being declared merely because something changed.

### 11. Prove recovery at every affected boundary

Recovery must cover:

- correct user outcome and latency distribution;
- affected cohort and unaffected control;
- queue occupancy, oldest age, retry, and permanent loss;
- new context continuity or intended links;
- receive, process, export, and sink reconciliation;
- data freshness and correct query scope;
- restored security and schema policy;
- sustained non-recurrence;
- exact rollback or cleanup state.

If evidence was lost, quantify the gap and record what future questions cannot be answered. Honesty about missing evidence is a reliability behavior.

### 12. Prevent the mechanism, not the screenshot

A prevention action should fail before production:

- contract test for inject, carrier serialization, extraction, and relationship;
- exact-distribution Collector configuration validation;
- assertion that required component instances belong to required service pipelines in the right order;
- bounded end-to-end canary with freshness and count reconciliation;
- sampler-policy compatibility and trace-routing test;
- outage and queue-capacity test with permanent-loss evidence;
- attribute and baggage schema and privacy test;
- canary overhead budget and automatic rollback.

Assign an owner and review date. “Add a dashboard” is not prevention if the same path can still fail silently.

## Guided Ubuntu lab

This chapter defines two lab records. The first is a guided mechanism lab. The second is an answer-isolated transfer. They are not interchangeable. Repeating a known fault proves practice, not unfamiliar diagnosis.

The support bundle lives beside this lesson under `support/lab/`. It remains noncanonical until promotion. A prior controller revision passed the bounded Ubuntu 24.04 runtime, context break/recovery, per-hop reconciliation, queue/retry/drain fault, deterministic sampling, token-guarded cleanup, and final zero resources. The current controller adds crash-safe kernel locking and stronger source/config/resource evidence; its fourteen Linux tests and full runtime must be rerun before publication. The passwordless-sudo root branch was unavailable and remains explicitly unclaimed. Read its README, `STATUS.md`, and locks before running commands.

### Safety card

The intended boundary is deliberately narrow:

| Item | Allowed |
|---|---|
| caller | normal Ubuntu user with authorized access to the local Docker daemon |
| target | uniquely named LES-0027 disposable resources only |
| application traffic | fixture-internal Docker networking through validated container IDs; no host port |
| data | fixed synthetic values only |
| setup pulls | forbidden; setup uses `--pull never` |
| preparation | separate explicit path, only if network and registry access are approved |
| privilege | no sudo; root must be refused |
| broad cleanup | forbidden |
| production or company target | forbidden |

Abort if ownership is ambiguous, a digest lock is incomplete or mismatched, an external address appears, a real secret or personal value appears, a host port appears, or cleanup cannot prove its exact target.

### Lab 1: guided end-to-end path

#### Stage A: read before you create

From the lab directory, read the README, the lock file, Compose model, Collector configurations, fixture source, `lab.sh`, and `verify.sh`. This is not busywork. The wrapper is executable authority. You should know which containers, internal network, files, and state it may create before giving it Docker access.

Record:

~~~text
date and timezone:
Ubuntu version:
native or WSL:
Docker client version:
daemon/server version:
Compose version:
locked image references:
expected owned resource prefix:
expected published host ports: none
baseline status:
~~~

Do not store a username, home path, corporate path, registry credential, token, or machine-specific private value in Git.

#### Stage B: establish final absence before setup

Run:

~~~bash
bash lab.sh status
bash lab.sh model
~~~

The expected safe baseline is “no LES-0027 owned runtime.” If status reports resources, determine whether they are from your earlier attempt and match the ownership descriptor. If ownership cannot be proven, stop. Cleanup must never infer ownership from a broad name prefix alone.

The read-only model reports that OpenTelemetry and the Collector were not executed, makes no network request or filesystem mutation, and demonstrates only the encoded joined, broken, recovered, gateway-queue, and sampling states. A model result is not runtime evidence.

#### Stage C: preflight and locks

Run:

~~~bash
bash lab.sh doctor
~~~

Decode every prerequisite as taught in commands 1 through 3. If a locked digest, image, or wheel cache is absent or mismatched, the correct result is a closed failure. That protects reproducibility.

The separate preparation interface is:

~~~bash
bash lab.sh prepare --allow-network-downloads
~~~

Preparation is a maintainer-only interface that may access an image registry and populate the local cache. It is not automatically authorized by this lesson. Use it only when network use, registry policy, image source, and lock update procedure are approved. Afterward, inspect exact digests and repeat doctor. Never continue because a tag happens to exist.

When reviewed immutable artifacts are locally available, run:

~~~bash
bash lab.sh validate-configs
~~~

This command renders the resolved Compose model and asks the exact Collector image to validate its configuration. The current locked image passed all three files, including exact temporary-container removal and absence. Static support-file checks remain weaker and are not a substitute.

#### Stage D: offline setup

Run only after doctor passes:

~~~bash
bash lab.sh setup
bash lab.sh status
~~~

Capture actual output. Do not replace it with the examples in this chapter. Confirm that setup reports `runtime_pull_policy=never`, returns a lifecycle token, creates five exact owned containers and one internal network, publishes zero host ports, reaches health/readiness checks, and configures no external destination.

Setup success proves only the declared local readiness conditions. It does not prove OTLP flow or parentage.

#### Stage E: establish a clean operation

Run:

~~~bash
bash lab.sh run baseline
bash lab.sh status
bash lab.sh verify-operation --expect-token TOKEN_FROM_SETUP_OR_STATUS
~~~

Your notebook should contain two paths.

Workload:

~~~text
fixed request -> API outcome -> bounded queued work -> worker/downstream response
~~~

Telemetry:

~~~text
SDK ended/exported -> agent received/processed/exported -> gateway received/processed/exported
                   -> bounded debug-sink visibility; backend ingest remains unproven
~~~

For the context path, draw the actual reported spans and write each trace ID, span ID, parent span ID or link, span kind, and operation name using only the fixture's sanitized identities. Explain why sharing a trace ID is correlation and why the parent or link expresses the intended reported relationship.

For the Collector path, verify the baseline equation `3 source-ended = 3 SDK-exported = 3 agent-received/processed/exported = 3 gateway-received/processed/exported = 3 debug-sink-visible`. Check that units are spans, the freshness window is bounded, process identities are unchanged, and refusal/drop deltas are zero. These are measured fixture values, not assumptions about a different pipeline.

#### Stage F: decode a carrier

Run command card 4's local Python parser with the supplied synthetic `traceparent`, then test these sanitized branches one at a time:

- correct version-00 shape;
- all-zero trace ID;
- all-zero parent ID;
- wrong field length;
- uppercase hexadecimal;
- forbidden `ff` version.

For each, predict the result before running. Then explain why syntactic validity does not establish trust, authentication, or authorization. Do not turn this teaching parser into production propagation code.

#### Stage G: break and recover context

After preserving the clean baseline, run:

~~~bash
bash lab.sh run broken-context
bash lab.sh status
bash lab.sh recover-context
bash lab.sh verify-operation --expect-token TOKEN_FROM_SETUP_OR_STATUS
~~~

The support contract should change one owned propagation boundary. Your job is to prove where continuity first changes. Compare producer active context, injected carrier, consumer carrier, extraction result, and worker relationship. Do not stop at “two trace IDs.”

Recovery is demonstrated only when a new fixed operation preserves request-to-worker and worker-to-downstream parentage, all three spans reconcile through the measured pipeline, and the workload outcome remains correct. The operation lock and absence of published ingress exclude concurrent lab requests, but this still proves only the synthetic fixture.

#### Stage H: interrupt the exact gateway

Run only through the guarded wrapper:

~~~bash
bash lab.sh interrupt-gateway
~~~

Do not use a manual `docker pause` against a guessed name. The wrapper proves ownership, enforces four operations, measures agent queue/retry state, and restores through `finally`. It accepts only a gateway process restart, exactly twelve post-restart gateway spans, zero final queue, and zero refusal/drop.

Use these equations to interpret the measured peak and drain, while keeping the fixture's limited observation window explicit:

~~~text
net queue growth = producer arrival rate - sustainable export rate
observed headroom = capacity - peak occupancy
drain rate = sustainable export rate - new arrival rate after recovery
estimated drain time = queued backlog / drain rate
~~~

The fixture measures capacity, peak occupancy, zero final occupancy, retry records, a residence lower bound, and zero refusal/drop, but it does not run long enough to estimate representative arrival or sustainable export rates. Write those rate-based calculations as `not calculable from this bounded run`. An empty queue alone could mean loss; the twelve-span post-restart reconciliation is what distinguishes drain here.

#### Stage I: compare sampling decisions

Run:

~~~bash
bash lab.sh compare-sampling
~~~

The current fixture compares deterministic parent-based head sampling ratios `1.0` and `0.25` across 32 successful local operations per run. It binds sampled operation/trace identifiers to each ratio's current gateway log window and restores `1.0` afterward. It does not execute tail sampling. Build a table with ratio, request count, successful workload count, source sampled count, gateway-visible sampled count, deterministic-ID comparison, and restored ratio. Answer:

1. Which decision happened before outcome was known?
2. Did unsampled requests still succeed?
3. Did every recorded child respect the propagated parent decision?
4. Which workload-side request count supplies the denominator outside trace retention?
5. Why does current-window gateway visibility still not prove backend ingest or retention?
6. What outcome question becomes impossible from retained traces alone?

This comparison demonstrates deterministic head-sampling mechanics and propagated decisions. It does not validate tail sampling, statistical representativeness, a production sampling percentage, or a cost model.

#### Stage J: cleanup is a graded operation

Run:

~~~bash
bash lab.sh cleanup --expect-token TOKEN
bash lab.sh status
~~~

Replace `TOKEN` with the exact lifecycle token returned by setup or status. Then run the same token-checked cleanup again and status again. Idempotence means the second cleanup remains safe and final absence stays true. Verify that pre-existing and concurrently created foreign resources, if the verifier uses controlled sentinels, remain untouched.

Do not substitute broad Docker prune. If owned residue remains, the lab is not complete even if all telemetry questions were answered.

### Lab 1 evidence pack

Preserve a sanitized local report containing:

- evidence contract and authorization;
- exact support artifact revision and lock identities;
- environment and normal-user proof;
- initial absence;
- doctor branches;
- setup output;
- one baseline workload, context, and telemetry map;
- traceparent predictions and results;
- broken-context observation and recovery;
- gateway interruption capacity calculation and reconciliation;
- sampling comparison and proof limits;
- cleanup, repeat cleanup, and final absence;
- every unexpected result and every source of help.

This is guided evidence. It can show that you followed and explained a known mechanism. It cannot satisfy ASM-0066.

### Lab 2: independent transfer without a published answer

The independent lab uses a fresh disposable variant assigned or approved after you have not seen its solution. It contains an async carrier context loss while an unrelated Collector policy changes. You do not know in advance which observed gap belongs to which change.

Before opening diagnostics, timestamp an evidence contract. Capture a baseline. Rank at least four hypotheses, including context injection or extraction, enabled pipeline membership or order, sampling, and destination/query scope. For each hypothesis, name one read-only observation, expected branches, proof limit, and next step. You may change at most one authorized variable after baseline evidence.

The deliverable must contain:

1. a precise impact claim and uncertainties;
2. workload, context, and telemetry maps;
3. exact configuration-to-runtime graph comparison;
4. a boundary reconciliation table with units and timing;
5. ranked independent hypotheses;
6. one discriminating observation per hypothesis;
7. one safe containment that does not depend on an unproved cause;
8. one reversible remediation with rollback;
9. user, context, pipeline, freshness, and cleanup recovery proof;
10. prevention tests and named ownership;
11. assistance disclosure and sanitized raw evidence.

No scenario-specific diagnosis or answer is published here. Once you have seen a solution, that case becomes practice and a reviewer must provide a new one. A plausible story is not transfer evidence.

## Production transfer

The local fixture is a microscope. Production is an ecosystem: many languages, versions, tenants, networks, deployment units, credentials, retention rules, and teams. Transfer the reasoning model, not the fixture topology.

### Start with an instrumentation contract

For each important operation, review:

| Contract field | Question |
|---|---|
| operation boundary | Where does user or system work begin, commit, fail, retry, and end? |
| stable name | Will the name aggregate across identities rather than explode per request? |
| success and error | Which durable outcome defines correctness? |
| relationship | Parent, link, or separate trace—and why? |
| resource identity | Which stable service, version, environment, and instance fields are required? |
| attributes | Which bounded fields answer an operational question? |
| prohibited data | Which secret, personal, payment, payload, or free-text fields must never emit? |
| event policy | Which state transitions or exceptions add value without duplicating logs? |
| sampling | Which decision occurs where, and what denominator remains unsampled? |
| overhead budget | What p50, p99, CPU, memory, allocation, payload, and shutdown change is allowed? |
| owner | Who approves schema, investigates loss, and rolls back? |

Auto-instrumentation should pass the same review. “Automatic” describes how hooks are installed, not how semantics, safety, or cost become correct.

### Diagram 5: finite queue and retry state machine

~~~text
                     producer rate lambda
                              |
                              v
                     [ finite batch ]
                       size/time flush
                              |
                              v
                    [ finite send queue ] <---------+
                     occupancy + oldest age         |
                         |                          |
                         v                          |
                    export attempt                  |
                   /      |       \                 |
             success  retryable   permanent         |
                |        |          failure         |
                v        v             |            |
          acknowledge  backoff --------+------------+
                         |              |
                         | budget ends  v
                         +--------> permanent drop

If lambda > sustainable consumer rate mu:
queue grows -> age grows -> capacity ends -> refuse/drop or resource exhaustion
~~~

### Diagram 6: rollout one proof boundary at a time

~~~text
1. schema + threat model
   owner, operation, attributes, baggage, cardinality, trust
                         |
                         v
2. bounded local proof
   correct lifecycle, propagation, no-op/error branches, cleanup
                         |
                         v
3. shadow / disabled destination
   render config, overhead and payload review, no production decisions
                         |
                         v
4. tiny canary
   user outcomes + SDK + Collector + backend + privacy + cost
                         |
                         v
5. progressive cohorts
   explicit gates, sustained windows, rollback at every step
                         |
                         v
6. steady operation
   SLO, capacity, change control, drills, ownership, review dates
~~~

Every rung has four fields: entry evidence, abort threshold, rollback command or deployment action, and recovery evidence. If the rollback is “figure it out during the incident,” the rollout is not ready.

### Deployment pattern choices

**Direct application to gateway:** fewer hops and simpler local operation. Applications hold destination configuration and possibly credentials, and a shared gateway outage is immediately visible to every exporter.

**Application to local agent to gateway:** local endpoint stability, enrichment, and short buffering. More components, per-host or per-workload resource cost, another queue, and version drift.

**Sidecar Collector:** strong workload-local isolation and configuration, but high instance count and duplicated resource overhead. Lifecycle ordering matters; the application can exit before sidecar flush or vice versa.

**Node agent or daemon:** amortized overhead and host context, but multi-tenant isolation, noisy neighbors, host upgrades, and local endpoint policy become important.

**Central gateways:** shared routing, credentials, transformations, and tail sampling. They need load balancing, failure-domain separation, capacity reservation, safe config rollout, and trace-aware routing where required.

Choose a pattern using workload isolation, latency, credentials, failure domains, throughput, policy, operability, and cost. Do not copy a “reference architecture” without naming why each hop exists.

### Kubernetes transfer

In Kubernetes, map every layer:

- application Pod and SDK;
- sidecar, node agent, or direct Service endpoint;
- Service selection and endpoint readiness;
- NetworkPolicy and DNS;
- gateway Deployment or StatefulSet;
- Pod disruption, rolling update, resource limits, topology spread, and autoscaling;
- configuration source and rollout hash;
- workload identity, secret mount, and TLS trust;
- persistent queue storage, if any;
- backend egress and tenant.

Use namespace-scoped read evidence first. A Pod Ready condition does not prove its traces pipeline flows. A Service with endpoints does not prove OTLP protocol compatibility. Resource limits can turn a backlog into OOM restart and silent in-memory loss.

Before a change, use rendered manifests, schema checks, policy checks, and `kubectl diff` in the exact namespace. Define rollback to a known ReplicaSet or Git revision. Do not test queue exhaustion against a shared production Collector.

### VM and bare-metal transfer

On a VM, the agent may run as a systemd service. Map unit ordering, environment files, credential permissions, configuration path, binary distribution, filesystem queue, ulimit, restart policy, and journal visibility. A restart loop can repeatedly discard in-memory batches while the unit eventually appears active.

Capture `systemctl status`, the exact unit and drop-ins, configuration hash, process command line, listening sockets, resource limits, and bounded logs under authorization. Do not add sudo merely to make evidence visible; follow the operational access model.

### Protocol, TLS, and identity

Production OTLP must name:

- gRPC or HTTP mapping;
- endpoint, port, and path;
- DNS ownership and failure behavior;
- client and server TLS requirements;
- trust roots and certificate rotation;
- client identity or token mechanism;
- authorization and tenant mapping;
- compression and maximum message size;
- timeout and retry classifications;
- proxy or load-balancer behavior;
- allowed egress and data region.

A TLS handshake proves a cryptographic session to an identity under the presented trust chain. It does not prove OTLP authorization, tenant correctness, or ingest. An HTTP 200 or gRPC success proves only the documented request boundary. Keep destination-side evidence.

Never place credentials in Collector configuration committed to Git, command output, span attributes, baggage, or debug logs. Use the organization's secret delivery and rotation system with least privilege. The Collector that can export every service's telemetry is a high-value boundary.

### Version and schema upgrades

Upgrade API, SDK, instrumentation packages, Collector distribution, components, semantic conventions, and backend support as separate compatibility concerns. Pin exact artifacts. Read migration and security notes. Validate the exact rendered configuration. Compare telemetry schema before and after.

A safe upgrade canary checks:

- operation and resource names;
- attribute additions, removals, and stability levels;
- parentage and baggage policy;
- span count per operation;
- metric name, type, unit, labels, and temporality;
- OTLP protocol behavior;
- Collector component startup and pipeline order;
- accepted, dropped, retried, and freshness deltas;
- backend query and alert compatibility;
- application and Collector overhead.

Parallel dual export can compare destinations but doubles traffic and may expose data to an unauthorized sink. Treat fan-out as a security and capacity change.

### Tail sampling at scale

Estimate tail state before enabling it. Let:

~~~text
R = new traces per second reaching the sampler
W = decision wait in seconds
S = average in-memory bytes per pending trace, including overhead
H = safety factor for burst and uneven trace size
~~~

A first approximation is:

~~~text
pending traces ~= R * W
memory bytes ~= R * W * S * H
~~~

This is not a sizing guarantee. Long traces, late spans, high span counts, policy work, garbage collection, and implementation overhead matter. Load-test the exact distribution with representative sanitized shapes. Observe eviction and decision latency. Route all needed spans for one trace consistently while avoiding one hot trace or tenant becoming a denial of service.

### Production acceptance evidence

Before relying on the pipeline, require:

1. exact version and artifact provenance;
2. reviewed operation and data schema;
3. configuration validation and enabled-graph assertion;
4. context interoperability tests for every transport;
5. representative throughput, burst, outage, and recovery tests;
6. application overhead and fail-open or fail-closed behavior;
7. security, privacy, tenancy, retention, and deletion review;
8. end-to-end canary and freshness objective;
9. self-telemetry plus an outside silence detector;
10. runbook, ownership, on-call routing, rollback, and disaster behavior.

One local Docker pass supplies none of this automatically. It only teaches how to ask for it.

## Reliability, security, observability, capacity, and cost

OpenTelemetry is part of the production system even when the business can continue without it. It consumes resources, crosses trust boundaries, stores data, and determines what operators can know during failure.

### Reliability: design degradation explicitly

Decide what happens when each telemetry boundary fails:

| Failure | Application policy question | Pipeline policy question |
|---|---|---|
| SDK queue full | drop telemetry, block, or shed detail? | how is loss counted outside the failing queue? |
| agent unavailable | retry for how long and with what memory? | is another local endpoint safe or does failover duplicate? |
| gateway unavailable | can agents buffer without harming hosts? | how is capacity distributed across failure domains? |
| backend throttles | which responses are retryable? | when does backlog expire or become permanent loss? |
| configuration invalid | does deployment fail before traffic? | can last known good remain active? |
| credentials expire | can telemetry fail without user outage? | how are rotation and rollback tested? |
| disk queue corrupt/full | does process start, quarantine, or drop? | who owns recovery and secure deletion? |

“Fail open” usually means the user operation continues when telemetry fails. That protects availability but reduces incident evidence and can hide policy violations. “Fail closed” may be required for a narrow audit boundary but can turn the observability system into a user-facing dependency. Make the choice per operation and regulatory contract; do not inherit an accidental library default.

Use redundancy across real failure domains. Two gateway replicas on one node do not protect node loss. Two replicas behind a load balancer can still share a bad configuration. Capacity redundancy, configuration canarying, credential separation, and destination health are distinct.

A bounded retry budget prevents an outage from becoming an infinite storm. Jitter avoids synchronized retries. Oldest age tells you whether the queue contains increasingly stale evidence even when occupancy is flat. Permanent drops need a counter, a time boundary, a reason, and an operational response.

Exactly-once telemetry is usually not a safe assumption. A sender can time out after the receiver accepted a request. Retrying may duplicate. If duplicates matter, understand downstream identifiers and deduplication contracts; never claim them from a trace ID alone.

### Define a telemetry pipeline SLO carefully

Possible service-level indicators include:

- proportion of eligible canary records queryable within a freshness threshold;
- accepted-to-exported reconciliation excluding documented filters;
- permanent drop ratio by signal and priority;
- context-continuity ratio for controlled operations;
- Collector availability and queue-age budget;
- configuration rollout success without application regression.

The denominator must be independent enough to detect telemetry silence. If both numerator and denominator are emitted by the same failed SDK, the ratio can remain perfect at zero traffic. A synthetic canary or workload-side outcome counter provides another boundary.

An example objective might say: “99.9 percent of approved synthetic canary traces emitted by production gateways are queryable in the correct tenant within five minutes over 30 days, excluding declared maintenance.” That still says nothing about all application traces, semantic correctness, or privacy. SLO wording must name its narrow contract.

### Security: telemetry is a data exfiltration path

Threats include:

- untrusted `traceparent`, `tracestate`, or baggage manipulating correlation or policy;
- secrets, tokens, customer data, payment data, query text, or payloads entering attributes;
- debug exporters copying full records into broadly readable logs;
- a shared Collector credential granting excessive tenant access;
- unauthenticated OTLP receivers accepting spoofed or high-volume data;
- high-cardinality attributes causing memory or billing denial of service;
- malicious spans exploiting processor or backend parsers;
- cross-tenant routing or query mistakes;
- retained telemetry outliving the business need;
- incident evidence itself leaking data.

Controls begin at instrumentation:

1. allowlist fields; do not rely only on denylist redaction;
2. bound length and cardinality;
3. classify data and document purpose;
4. prohibit credentials and raw payloads;
5. restrict baggage keys and total size;
6. validate untrusted context and separate it from authorization;
7. use workload identity and least-privilege exporter credentials;
8. encrypt transport and storage according to policy;
9. isolate tenants and environments;
10. restrict debug output and operator access;
11. audit schema and configuration changes;
12. define retention and deletion behavior.

Hashing is not automatic anonymization. A stable hash can remain a personal or linkable identifier and can create high cardinality. Salting, key management, collision, reversibility, and policy still matter.

### Observability of the observability path

Observe each stage with bounded dimensions:

**Application SDK**

- span operations started and ended;
- sample decision counts;
- processor queue size and capacity where exposed;
- export attempt/result and timeout;
- dropped records;
- flush and shutdown duration;
- application overhead.

**Collector**

- receiver accepted and refused;
- processor accepted, filtered, errored, and dropped;
- exporter sent, failed, retried, and dropped;
- queue occupancy, capacity, and oldest age;
- process CPU, memory, file descriptors, restarts, and uptime;
- configuration and build identity;
- tail pending, policy decisions, timeout, eviction, and late records.

**Destination and query**

- ingest admission and delay;
- storage or indexing backlog;
- retention and rejection;
- query latency and errors;
- newest event and ingest timestamp;
- synthetic canary freshness.

Avoid labels such as trace ID, span ID, request ID, raw endpoint, customer ID, error message, or arbitrary attribute key. Use stable service, signal, component type, pipeline identity, bounded result class, and environment where needed.

Build alerts from user and evidence impact. A transient retry with empty queue may need no page. Rising oldest age near the diagnostic horizon, permanent loss of critical telemetry, or canary freshness failure during user impact may. The runbook should state first read-only checks and proof limits.

### Capacity: bytes and work matter, not only item count

Estimate at every tier:

~~~text
operations_per_second
* spans_per_operation
* average_encoded_bytes_per_span
= trace_payload_bytes_per_second before protocol overhead
~~~

Then account for:

- burst factor and diurnal peaks;
- attributes, events, links, and resource size;
- compression ratio and CPU;
- batch size and request overhead;
- retry amplification;
- fan-out to multiple destinations;
- head and tail retention;
- queue residence;
- tail pending state;
- replicas and uneven load;
- backend indexing amplification;
- retention duration.

Example: 8,000 operations per second, 12 spans per operation, and 1,100 encoded bytes per span is roughly 105.6 MB/s before protocol, compression, retry, or fan-out:

~~~text
8,000 * 12 * 1,100 = 105,600,000 bytes/second
~~~

If you dual-export, that outbound payload can approach twice the base. If retries add 20 percent attempts, network work grows again. This simple model is not a bill; it tells you which measurements to obtain.

CPU-heavy transformations and tail policies can become the limit before network. Load-test realistic record shapes and policy complexity. A count-only synthetic payload with two tiny attributes underestimates a production schema with events and links.

Autoscaling can help sustainable capacity but may break trace-aware routing or discard in-memory tail state during scale-down. Scale on multiple signals: arrival, queue age, CPU, memory, pending traces, export latency, and destination condition. Define safe scale-down drain.

### Cost: pay for decisions, not unexamined volume

Model cost by stage:

~~~text
instrumentation overhead
+ application-to-agent transport
+ agent and gateway compute/memory/disk
+ cross-zone or cross-region network
+ backend ingest
+ indexing
+ retention and replication
+ query and dashboard work
+ incident and governance labor
~~~

Reduce cost in this order:

1. remove unsafe, duplicate, and unused fields;
2. stabilize operation names and bound cardinality;
3. stop collecting telemetry that supports no decision;
4. aggregate population metrics appropriately;
5. choose head or tail sampling with explicit bias;
6. tier retention by diagnostic horizon and obligation;
7. limit indexing to fields that need search;
8. control dashboard refresh and broad queries;
9. compress and batch within latency and CPU budgets;
10. review fan-out and data-region choices.

Do not optimize by deleting the only user-outcome denominator, error-budget evidence, security audit requirement, or incident-discovery horizon. State which questions become impossible after a policy change. Cost is part of reliability because an unaffordable evidence path will be cut during pressure.

### A worked overload decision

Suppose a gateway receives 50,000 spans/s, exports 42,000 spans/s, has 4,000,000 free span-equivalent queue slots, and average payload doubles after a schema change.

The item-count approximation gives:

~~~text
net item growth = 8,000 spans/s
item time to full = 4,000,000 / 8,000 = 500 seconds
~~~

But doubled payload means memory or bytes may exhaust before item capacity. Inspect both. Hypotheses include backend throttling, exporter regression, heavier processor work, larger payloads, and true workload increase. Safe containment may roll back the schema change if its user and privacy effects are understood, or reduce approved noncritical detail. Merely doubling item slots can worsen memory pressure.

Recovery requires user outcomes healthy, incoming and outgoing rates in equilibrium, oldest age falling to budget, no new permanent drops, backlog drained or loss quantified, and the schema/capacity model corrected.

## Traps and prevention

### Trap 1: “The Collector is healthy, so tracing works”

Health normally answers process or component readiness. Prevent the mistake with a bounded end-to-end canary and per-boundary receive, process, export, ingest, and query freshness evidence.

### Trap 2: declaring a component and assuming it is enabled

A receiver, processor, or exporter outside `service.pipelines` may be unused. Prevent this with exact-distribution validation plus a structural assertion for required pipeline membership and order.

### Trap 3: restarting before capturing volatile state

Restart can clear queues, retry timers, pending tail traces, counters, and the configuration instance that failed. Capture ownership, version, queue, drop, error, and freshness evidence first. Restart only with a hypothesis and recovery plan.

### Trap 4: manually copying trace IDs

Manually forcing IDs can create false parentage, invalid context, collisions, or trust problems. Use a conforming propagator, an approved carrier, and the intended parent or link model. Treat IDs as correlation, never authority.

### Trap 5: believing valid traceparent means trusted request

Syntax only says fields fit a grammar. Authenticate and authorize through the real security system. Apply ingress context and baggage policy separately.

### Trap 6: putting identity into metric labels

Trace, request, order, user, and session IDs create near one time series per operation. Metrics answer population questions with bounded dimensions. Use authorized trace or log lookup for individual records.

### Trap 7: using traces as the error-rate denominator

Head, parent, tail, pipeline, and backend sampling bias the retained set. Keep unsampled outcome counters or durable business totals for rates; use traces to explain selected examples.

### Trap 8: assuming tail sampling can recover head-dropped traces

A later decision cannot select data never sent. Map the full sampling chain and preserve a route by which candidate traces reach one compatible decision point.

### Trap 9: scaling tail samplers without trace-aware routing

Random span distribution fragments traces across independent decision state. Test routing, rebalance, scale-down drain, hot keys, failover, and late spans under the exact architecture.

### Trap 10: growing queues as the permanent fix

A queue absorbs a burst or outage window. It cannot solve sustained arrival above consumption. Calculate time to full, memory and disk limits, retry amplification, and drain. Repair throughput or approved volume policy.

### Trap 11: unbounded retry

Retries consume queue, network, CPU, and downstream capacity. Use result classification, exponential backoff, jitter, elapsed-time or attempt budget, and permanent-loss evidence.

### Trap 12: redacting only at the gateway

Unsafe values have already crossed process, network, agent, and perhaps debug logs. Exclude at instrumentation. Use downstream redaction as defense in depth and test that it precedes every exporter.

### Trap 13: treating baggage as free metadata

Baggage propagates broadly, adds bytes, may enter telemetry, and accepts untrusted input. Keep a tiny allowlist, size limit, hop policy, and explicit purpose. Never place a credential or authorization claim in it.

### Trap 14: enabling debug exporters in production

Debug output can contain full telemetry and overwhelm logs. Use only synthetic data in a bounded disposable target. Production troubleshooting should use approved sampling and access controls.

### Trap 15: comparing counters with different units

One counter may count OTLP requests and another spans. Batch, fan-out, filters, and retries break naive equality. Document units, resets, and interval alignment before reconciliation.

### Trap 16: measuring only average overhead

Average CPU can look small while p99 request latency, allocation pauses, or shutdown time regresses. Compare distributions and canary/control cohorts under representative load.

### Trap 17: hiding missing evidence with “zero”

Unavailable, stale, reset, filtered, and true zero are different states. Store freshness and source status. If evidence is absent, keep the unknown visible.

### Trap 18: calling a local fixture production proof

A deterministic Docker model teaches mechanisms. It does not establish real SDK, Collector, backend, Kubernetes, scale, identity, TLS, storage, privacy, or provider behavior unless each is actually exercised under an accepted contract.

### Prevention stack

Use layers rather than one heroic check:

~~~text
code review:
  operation lifecycle, schema, sensitive-data allowlist, bounded cardinality

unit/contract tests:
  span lifecycle, error path, inject/carrier/extract, parent/link

build validation:
  exact dependency lock, exact Collector distribution, rendered config

integration:
  bounded OTLP flow, required pipeline membership/order, destination canary

performance/security:
  overhead budget, payload review, baggage, credentials, attack limits

rollout:
  canary/control, explicit gates, kill switch, rollback proof

operations:
  self-telemetry, outside freshness, capacity, runbook, drills, ownership
~~~

No layer proves the next one. Together they make silent failure less likely and recovery faster.

## Memory card and retrieval

The chapter is large. Keep a small mental card and repeatedly reconstruct the detail.

### The nine-word pipeline

**Operation → context → record → decision → transport → pipeline → destination → query → proof.**

If you are lost, point to the word where evidence stops.

### The configured-versus-flowing ladder

**Declared, valid, instantiated, enabled, ready, flowing, durable, queryable.**

Never jump from the first or fifth word to the eighth.

### The context handshake

**Active → inject → carrier → validate → extract → activate → child or link.**

When a worker is a new root, walk this handshake. Do not restart the Collector first.

### The pressure formula

**Growth = arrival − consumption. Time = free capacity ÷ growth.**

Always name units. A larger queue buys time, not throughput.

### The sampling truth

**Head decides early. Parent carries. Tail waits. Dropped upstream is gone. Retained is biased.**

Keep an unsampled outcome denominator.

### The security sentence

**Context correlates; identity authenticates; policy authorizes. Never swap them.**

### The recovery ladder

**User outcome → relationship → pipeline reconciliation → freshness → sustained window → cleanup.**

One visible trace is not recovery.

### Sixty-second retrieval

Without looking back, answer:

1. What is the difference between API and SDK?
2. Why can a declared receiver be inactive?
3. Which seven context steps cross an async boundary?
4. Why can tail sampling not recover head-dropped errors?
5. What does a full queue mean only after units are known?
6. Why is exporter success not backend durability?
7. Which evidence detects a telemetry path that reports nothing?
8. What must cleanup prove?

If an answer is vague, return to the relevant boundary, not the whole chapter.

### Five-minute drawing drill

On blank paper, draw:

1. one workload path;
2. the parallel telemetry path;
3. the carrier trust boundary;
4. an agent and gateway pipeline;
5. the queue and retry loop;
6. head and tail decision locations;
7. a safe rollout ladder.

Add one owner, one loss signal, and one “does not prove” statement at each boundary. This drill builds systems thinking faster than memorizing configuration syntax.

### Delayed retrieval schedule

- After one day: reconstruct the nine-word pipeline and explain configured versus enabled.
- After three days: solve the new-root incident without notes.
- After seven days: calculate a queue time-to-full and sampling memory estimate.
- After fourteen days: design an instrumentation rollout for another architecture.
- After thirty days: take a fresh answer-isolated incident under review.

Reading confidence is not recall. Retrieval under a new scenario is the evidence that the model stayed with you.

## Complete answers

These are complete teaching answers to the chapter's guided questions. Read them after attempting retrieval. They do not answer ASM-0066's unseen case.

### 1. What is the difference between the OpenTelemetry API and SDK?

The API is the stable interface instrumentation calls. It lets code obtain a tracer or meter, start and end operations, access context, and attach allowed information without choosing a destination. A reusable library can depend on the API and remain vendor-neutral.

The SDK is the configured implementation in the application process. It owns resource identity, recording behavior, sampler decisions, processors, finite batching, exporters, shutdown, and much of the self-telemetry. If code calls the API but no SDK provider is installed and configured, the call may be a no-op. If the SDK exists but the root sampler drops the operation, the span may be non-recording or not exported according to the exact implementation.

This separation matters operationally. “Instrumentation code executed” proves only an API path. To prove delivery, you still need SDK decision and export evidence, agent receive, Collector processing, destination ingest, and query freshness. It also matters for ownership: application teams define business semantics; platform teams may supply SDK defaults; neither can assume the other made sensitive fields safe.

### 2. What does traceparent contain, and why is valid not the same as trusted?

For W3C Trace Context version 00, `traceparent` contains version, trace ID, parent span ID, and trace flags. In the common rendered form, those are 2, 32, 16, and 2 lowercase hexadecimal characters separated by hyphens. The trace and parent identifiers cannot be all zero. The sampled bit in flags reports an upstream sampling decision or hint according to the processing model.

Parsing proves syntax under a specified version. It does not prove who created the value, whether it describes the real authenticated request, whether the parent actually caused the work, or whether baggage is safe. An external client can supply a syntactically correct identifier. Authentication must come from the security protocol and identity system. Authorization must come from policy. Context is correlation material.

At an ingress boundary, validate duplicates, size, version, characters, zero values, and local policy using a conforming propagator. Decide whether to continue, restart with a link, or reject context without rejecting the user request. Strip unapproved tracestate and baggage. Never use a trace ID or baggage key to choose tenant authority or approve payment.

### 3. A queue worker starts a new root. How do you diagnose it?

First prove the intended relationship. One message processed by one consumer can often be represented by a remote parent; fan-in or batches may require links. Do not label a correct link model “broken.”

Then walk the context handshake with one sanitized disposable message:

1. Was the intended producer span active when injection ran?
2. Did the propagator write an approved `traceparent` to the exact carrier later serialized?
3. Did the client library serialize that carrier on every retry?
4. Did the broker or intermediary preserve the property?
5. Did the consumer receive the same approved field?
6. Did extraction accept it under syntax and trust policy?
7. Was the extracted context made current before the worker span was created?
8. Did the worker report the intended parent or links?

Expected branches locate the earliest gap. No injected field points to producer context or carrier use. Field present at producer but absent at consumer points to serialization, transport, or policy. Valid extracted context but a new worker root points to scope activation or span creation. This path does not include the Collector; it moves spans after relationships are encoded.

Remediate one owned boundary, restore baseline if the result differs, and prove a new controlled operation has the correct durable outcome and reported relationship. Add a contract test across the exact queue client and consumer. Do not manually copy IDs or trust carrier values for authorization.

### 4. How can a Collector be healthy while a pipeline is disabled?

Collector configuration has two layers. Top-level declarations define named receiver, processor, exporter, connector, or extension configurations. The `service` section selects which telemetry pipelines and extensions run. A receiver can be perfectly valid yet absent from every traces pipeline. The process starts, the health extension answers, and another pipeline may flow; the intended receiver remains inactive.

Prove the state in stages:

- exact deployed config matches the reviewed artifact;
- exact Collector distribution accepts it;
- required component instance appears in the intended `service.pipelines.traces` graph;
- startup evidence shows that component instantiated;
- one fixed input changes its receiver counter;
- ordered processors account for intentional changes;
- exporter and destination evidence reconcile.

The smallest fix is to add the correct existing instance to the correct pipeline in the correct order, after review and canary. A restart without configuration change reproduces the defect and destroys useful counters. Prevention is a structural pipeline assertion plus an end-to-end canary, not only YAML syntax validation.

### 5. Compare head, parent-based, and tail sampling

Head sampling decides near root creation, before final latency or error is known. It is cheap because dropped roots avoid most downstream trace work. A simple probability can represent common traffic, but rare later errors may be absent.

Parent-based sampling uses the upstream sampled state to choose a branch for child spans. It improves trace consistency when context survives. It requires an explicit policy for remote sampled and unsampled parents, trusted versus untrusted ingress, and services whose local needs differ.

Tail sampling waits for spans at a Collector or backend, assembles a trace for a decision window, and evaluates outcome, latency, attributes, or policies. It can retain received errors or slow traces, but consumes memory and time. It can evict, time out, see late spans, or decide from fragments if replicas lack trace-aware routing.

Combining them needs honesty. A ten-percent head sampler means roughly ninety percent of eligible roots never reach the tail decision, subject to exact policy and parent branches. The tail sampler cannot recover those. Retained traces are biased and cannot supply a reliable error denominator. Keep unsampled outcome metrics or durable totals. Size tail state from trace arrival, decision wait, record size, burst, and policy cost, then test the exact system.

### 6. A queue is filling. Should you make it larger?

Maybe as a temporary, reviewed burst or outage buffer, but first establish unit, arrival rate, sustainable consumer rate, free capacity, oldest age, average bytes, memory or disk budget, retries, and destination condition.

If arrival is 18,000 spans/s, sustainable export is 13,000 spans/s, and 200,000 span slots remain, net growth is 5,000 spans/s and the simplified time to full is 40 seconds. Another 200,000 slots buys about 40 more seconds. It does not repair the 5,000 spans/s throughput deficit. If average record size doubled, bytes may exhaust before item slots.

Contain by protecting the workload, stopping unbounded generation, restoring downstream capacity, rolling back a costly processor or schema change when proven, or reducing approved noncritical detail. Bound retries and preserve critical evidence according to policy. Do not restart merely to empty the graph; that may discard records.

Recovery means arrival and consumption return to a sustainable relationship, occupancy and oldest age fall, no new permanent drops occur, backlog drains or loss is quantified, destination freshness recovers, and application outcomes stay healthy. Update capacity and outage models afterward.

### 7. Application export succeeds, both Collectors are ready, and the backend is empty. What next?

Do not collapse the chain into “backend problem.” Select one fixed operation with an independent workload outcome. Capture aligned before and after evidence:

1. SDK generated, sample decision, processor handoff, queue, and exporter result.
2. Agent receiver accepted/refused.
3. Agent ordered processor input, intentional filters, errors, and output.
4. Agent exporter sent, retry, failure, and permanent drop.
5. Gateway receiver accepted/refused.
6. Gateway pipeline membership and processor results.
7. Gateway exporter result.
8. Destination admission, tenant, and ingest delay.
9. Query tenant, environment, operation, time, retention, and freshness.

Check units and resets before subtracting. Application export success may mean only agent acceptance. Agent export success may mean only gateway protocol acceptance. Gateway success may precede durable backend storage. A ready Collector can have the wrong pipeline.

The first non-reconciling boundary narrows the next hypotheses. If agent receives but gateway does not, inspect agent export endpoint, protocol, TLS, identity, network, and gateway listener. If gateway receives but sends nothing, inspect pipeline membership, ordered filters, sampling, queue, and exporter. If destination admits but query is empty, inspect tenant, indexing, time, retention, and query. Mutate only after defining expected branches and rollback.

### 8. How should baggage be used safely?

Baggage is distributed application context propagated across boundaries. It is useful only when a small approved value must be available downstream for a clear purpose. Because it rides with requests, it adds bytes at every hop, can cross trust domains, may enter logs or spans, and can be supplied by an external actor.

Use a strict allowlist of keys, bounded values and total size, explicit ingress and egress policy, and documentation of who consumes each key. Drop unknown keys. Never place passwords, tokens, card or health data, raw customer identity, arbitrary query strings, or authorization claims in baggage. Never use baggage to decide tenant access or security privilege.

Even safe-looking values can create cardinality if copied into metrics or span attributes. Decide separately whether a baggage key should become telemetry. A downstream redactor is not enough because the value already crossed earlier boundaries. Test propagation, stripping, size limits, privacy, and overhead.

### 9. How do you roll out instrumentation without damaging production?

Begin with operation semantics and a threat model. Define stable names, lifecycle, relationships, bounded attributes, prohibited fields, baggage, sampling, ownership, overhead budget, and rollback.

Prove behavior locally with no-op, success, error, retry, cancellation, async context, and shutdown branches. Pin dependencies. Validate exact Collector configuration and required runtime graph. Test end-to-end with synthetic data and no real secret.

Canary a very small cohort against a control. Compare user success, p50 and tail latency, CPU, allocation, memory, thread and connection use, payload bytes, span count, SDK drops, Collector pressure, destination freshness, schema, privacy, and cost. Use explicit thresholds and a kill switch. Do not advance based on one quiet window.

Expand in progressive cohorts while monitoring change events and compatibility. Keep last known good artifacts. At steady state, assign on-call ownership, pipeline SLOs, capacity review, security review, upgrade tests, and failure drills. An instrumentation rollout is a production change, not dashboard decoration.

### 10. What is complete recovery from an OpenTelemetry incident?

Recovery spans more than telemetry. First, the affected user operation must produce correct durable outcomes at an acceptable latency for the affected cohort, with no hidden duplicate or abandoned work.

Second, context relationships for new controlled operations must match the intended parent or link model. Third, SDK, agent, gateway, and destination stages must reconcile under known units, filters, sampling, retries, and asynchronous timing. Queue occupancy and oldest age must recover; permanent loss must be quantified.

Fourth, the correct tenant query must show fresh sanitized canary evidence within budget. Fifth, unsafe attributes or baggage must no longer emit, credentials and policy must be correct, and any retained exposure must follow incident handling. Sixth, health must persist through a meaningful observation window and a normal deployment or restart boundary where relevant. Finally, rollback or cleanup state must be exact and owned.

If the incident permanently destroyed evidence, recovery can still be operationally complete, but the record must say which interval and questions remain unknowable. Never manufacture replacement spans.

### 11. Why is “no trace found” ambiguous?

The operation may not have occurred. Instrumentation may be no-op. The sampler may have dropped the root. Context loss may put the operation under another trace. An SDK batch may still hold it. A queue may drop it. A processor may intentionally filter it. An exporter may fail. The destination may ingest under another tenant, delay indexing, expire it, or reject it. The query may use the wrong identity or time.

Absence becomes useful evidence only when the producer and evidence path are measured. Pair an independent workload outcome with generated/sample/export counters, per-boundary Collector evidence, destination ingest, and query freshness. If a component's own self-telemetry is silent, use an outside process or canary. “Unknown” is more accurate than zero when the measurement source failed.

### 12. What can the LES-0027 local package prove?

While the package remains quarantined, the passing runtime proves only the pinned local fixture: its chosen Python SDK, two agents, gateway, exact configurations, synthetic operations, internal network, debug sink, bounded faults, evidence bindings, sampling comparison, and cleanup. The separate model still performs no OpenTelemetry execution.

The 2026-08-07 normal-user offline run used the reviewed immutable locks and verified cache. A future run must revalidate those exact bytes and all gates; historical success does not make changed artifacts equivalent.

It still cannot prove production application correctness, Kubernetes behavior, managed backends, cross-region transport, TLS and identity, real scale, all sampling policies, privacy compliance, provider durability, learner transfer, delayed recall, or mastery. Each claim needs representative evidence and accepted review. Keeping this boundary explicit is part of engineering accuracy.

## Product-company interview

Senior interviewers are not looking for a list of OpenTelemetry components. They are listening for boundary thinking, quantified trade-offs, safe incident action, and honest proof limits.

Use this answer shape:

1. define the user operation and success;
2. draw workload, context, and telemetry paths;
3. name ownership and failure domains;
4. quantify capacity or sampling where relevant;
5. begin with read evidence;
6. choose one reversible action with expected branches;
7. close with recovery, prevention, and what remains unproved.

### Scenario 1: “Design tracing for an asynchronous payment platform”

A strong answer begins with durable payment correctness, not a Collector diagram.

“I would define eligible payment operations, durable success, terminal failure, timeout, duplicate prevention, and latency from acceptance to settlement. I would keep unsampled outcome counters or durable business totals as the denominator. Traces explain selected paths; they do not decide payment correctness.

“At ingress I would validate approved W3C context without using it for authentication or authorization. I would create stable server and producer operations under the current semantic conventions, inject approved context into exact message properties, and create a consumer parent or links according to single-message, fan-out, or batch semantics. I would prohibit payment data, tokens, raw payloads, and customer identity in attributes or baggage.

“The SDK would batch asynchronously with finite memory and a fail-open policy that protects payment latency while counting drops. Applications would export to a local agent where that operational model is justified, then to failure-domain-separated gateways. Required service pipeline membership, redaction order, queues, credentials, and exporters would be tested against the exact distribution.

“I would use head or tail sampling only after modeling error visibility, trace-aware routing, pending memory, and cost. Unsampled outcome metrics remain the denominator. Rollout would be canary versus control with p99, CPU, memory, span count, payload, drop, ingest freshness, privacy, and rollback gates. Recovery and SLOs cover both payment outcome and evidence freshness.”

This answer connects business truth, context, pipeline, security, capacity, and operation.

### Scenario 2: “The Collector is healthy but traces vanished. What do you do?”

“I would not restart first. I would define one affected operation, cohort, interval, expected freshness, and independent user outcome. Then I would capture exact deployed configuration and change events.

“For one sanitized fixed operation I would compare SDK generation and sampling, application export, agent receiver, agent processors, agent exporter, gateway receiver, enabled traces pipeline and order, gateway processors, gateway exporter, destination ingest, tenant, indexing delay, and exact query. I would reconcile units, resets, filters, batching, retries, and fan-out.

“The earliest non-changing boundary ranks the next hypotheses. If a component is declared but absent from service pipelines, I would canary the minimal pipeline membership fix after exact validation. If transport is the gap, I would inspect protocol, endpoint, TLS, identity, and response. If ingest changed but query did not, I would inspect tenant, time, retention, and indexing.

“Recovery means the user outcome is healthy, controlled traces traverse every expected boundary, freshness returns, queues drain, permanent loss is quantified, and the condition stays healthy. Prevention is an enabled-graph assertion and end-to-end canary, not another process-health alert.”

### Scenario 3: “Would you use head sampling or tail sampling?”

Do not answer with one universal choice.

“I would first define the decisions tracing must support, volume and burst, acceptable overhead, rare-event need, trace length, privacy, and cost. Head sampling is cheap and decides before outcome, so it can miss rare later errors. Parent-based branches improve distributed consistency but require an ingress trust policy. Tail sampling can retain received slow or error traces but needs trace-aware routing, memory for pending traces, decision delay, late-span and eviction policy, and more operational capacity.

“I would keep unsampled outcome metrics regardless. If I combine head and tail, I would explicitly state that tail cannot recover head-dropped traces and quantify candidate coverage. I would size pending memory as trace arrival times decision wait times average pending bytes times a burst factor, then test representative shapes. The decision comes from required diagnostic value and budgets, not from which feature sounds more advanced.”

### Scenario 4: “A worker starts a new trace after a queue. How do you fix it?”

“First I confirm whether parent or links are the intended async relationship. For one sanitized message I walk active producer context, injection, exact serialized carrier, broker preservation, consumer carrier, extraction validation, context activation, and worker span start. A Collector is downstream of span creation, so I do not restart it to fix parentage.

“If injection is absent, I repair producer scope or carrier use. If the property disappears in transport, I repair the approved client or broker property contract. If extraction succeeds but the worker is a root, I repair consumer scope activation. I do not manually assign IDs, and I never trust context for authorization. I add an end-to-end carrier contract test including retry and batch branches, then prove workload correctness and new relationship continuity.”

### Scenario 5: “Telemetry cost must fall by 40 percent”

“I would inventory cost and decision value by service, operation, signal, attribute, destination, retention, index, and query. I would protect user-outcome SLIs, alert inputs, security or audit obligations, and the incident horizon.

“First I remove unsafe, duplicate, unused, and unbounded data. I stabilize operation names and attribute cardinality. Then I aggregate population questions into metrics, stop indexing unused fields, sample high-volume successful trace detail under a documented policy, retain raw detail for the useful diagnostic window, and reduce unnecessary fan-out and broad queries.

“Every change is canaried. I compare diagnostic success, outcome denominator, trace coverage and bias, ingest bytes, storage, query latency, pipeline resource use, and privacy. I state which investigations become impossible. A 40 percent bill reduction that destroys error-budget or incident evidence is not an engineering success.”

### Scenario 6: “The gateway queue is full. Increase it?”

“Possibly for an expected bounded burst, but first I need the queue unit, capacity, occupancy, oldest age, arrival and sustainable export rates, payload bytes, retry work, destination result, memory or disk headroom, and application impact. If arrival exceeds export by 5,000 spans per second and 500,000 free slots remain, that is roughly 100 seconds under simplified steady assumptions.

“A larger queue buys time, not throughput, and can move failure to memory or disk. I would protect the workload, stop unbounded generation, restore the consumer bottleneck or roll back a proven volume or processor regression, bound retry, and record permanent drops. Recovery requires equilibrium, falling age, backlog drain, destination freshness, no new loss, and healthy user outcomes. I would update capacity, outage, and alert thresholds afterward.”

### Scenario 7: “Can trace context be used to enforce tenant access?”

“No. Trace context is untrusted correlation data. A syntactically valid external trace ID or baggage tenant key does not authenticate a caller or authorize a tenant. I use the identity protocol and policy engine for access. I validate context grammar and size, apply ingress continuation policy, strip unapproved tracestate and baggage, and keep identifiers out of authorization.

“Exporter credentials and backend tenant mapping use least-privilege workload identity. I test cross-tenant isolation, route policy, debug-output restrictions, and incident access. If telemetry suggests a tenant mismatch, I treat it as evidence to investigate, not authority to move or reveal data.”

### What weak answers sound like

Weak answers say “deploy a DaemonSet,” “use 10 percent sampling,” “increase the queue,” or “restart the Collector” without operation, evidence, capacity, security, or recovery. They list Grafana, Jaeger, Datadog, Splunk, or another product as if a product name answers semantics.

If you do not remember a version-specific component name or default, say so: “I would verify the exact distribution and version against its official documentation and run a bounded validation.” That is stronger than invented certainty. Durable senior judgment is knowing what must remain true when products change.

## Independent transfer and rubric

ASM-0066 is an evidence exercise, not another worked example. Its purpose is to find out whether you can use the model when you do not know the fault.

### Transfer contract

An instructor supplies, or approves creation of, an unfamiliar disposable non-production system with:

- more than one process;
- at least one asynchronous carrier;
- independently versioned application instrumentation and Collector configuration;
- a measurable operation-to-query path;
- at least one unrelated but plausible change;
- a hidden fault manifest.

The case must not be the guided LES-0027 fixture, ASM-0064, ASM-0065, or a scenario whose answer you have seen. If prior exposure makes the mechanism obvious, disclose it and request a fresh case.

### Independence gate

Before opening derived dashboards, comments, or solution material, timestamp:

~~~text
case provenance and owner:
why it is unseen:
prior related exposure:
help already received:
non-production authorization:
exact environment and numeric UID/GID:
allowed reads:
one allowed reversible mutation:
forbidden systems and operations:
expected files/processes/ports/containers:
network boundary:
secret and privacy boundary:
abort conditions:
rollback:
cleanup and final-absence proof:
~~~

Preserve private identity locally, but sanitize submitted names and personal or employer path segments while keeping numeric privilege, process, network, and filesystem boundaries. If sanitization removes the evidence needed to verify scope, arrange a private reviewer rather than publishing sensitive data.

### Required investigation

Map the user operation and telemetry path before diagnosis. State expected healthy operation, span and link topology, resource identity, instrumentation scope, context carriers, Collector runtime graph, OTLP hops, sampling decisions, queues, destination, and query.

Capture a comparable raw baseline. Write at least four falsifiable hypotheses before changing the case:

1. application instrumentation or propagation;
2. SDK or sampling;
3. Collector configuration or policy;
4. transport, backend, or query.

For every hypothesis, write predicted evidence, disconfirming evidence, source, unit, window, proof limit, and next safe observation. Keep the unrelated change alive until evidence rejects it. Temporal proximity is not causation.

Activate only the instructor-approved bounded case state. Build a chronological ledger. Label each entry observation, documented contract, calculation, inference, hypothesis, or unknown. Walk every carrier and every receive, process, queue, retry, export, ingest, and query boundary. Use one authorized reversible change only after evidence discriminates it.

Recovery must independently prove:

- correct user outcome over a declared sample and window;
- expected parent or link topology;
- correct resource, service, and instrumentation-scope identity;
- source-to-query reconciliation under stated units and sampling;
- queue and freshness recovery;
- overhead within the case budget;
- prohibited-field absence;
- exact rollback and final cleanup;
- remaining unknowns and permanent evidence gaps.

Then propose how the design would transfer to production without claiming that the disposable case proves production.

### Submission packet

The complete submission includes:

1. independence, authorization, and sanitation record;
2. architecture and ownership map;
3. versioned instrumentation, resource, scope, and semantic-convention contract;
4. expected synchronous, async, retry, batch, parent, and link topology;
5. source-to-query invariant table;
6. raw sanitized baseline;
7. pre-recorded hypothesis table;
8. case activation record;
9. chronological evidence and hypothesis updates;
10. carrier and trust analysis;
11. effective Collector graph and canary evidence;
12. sampling and trace-routing analysis;
13. queue, retry, persistence, backpressure, capacity, and loss worksheet;
14. security and privacy review;
15. controlled recovery and final-absence proof;
16. production rollout and rollback proposal;
17. concise incident handoff and five-minute interview answer;
18. at least twelve narrow proof-limit statements.

### Reviewer rubric

ASM-0066 assigns ten points to each dimension:

| Dimension | What strong observable evidence contains |
|---|---|
| independence, authorization, integrity | gate before investigation, unseen owned case, disclosed help, raw sanitized evidence, no answer access |
| architecture, ownership, baseline | user and source-to-query paths, versions, trust, loss, invariants, comparable baseline |
| instrumentation, resources, conventions | manual/automatic/library ownership, duplicate/missing reasoning, resource and scope identity, exact convention status |
| propagation, relationships, trust | inject/extract at every carrier, invalid branches, parent/link semantics, baggage controls, identity separation |
| Collector and end-to-end diagnosis | effective pinned config, configured versus enabled, canary at every hop, competing hypotheses |
| sampling and routing | head/tail populations, parent decisions, coherent routing, late/partial evidence, bias limits |
| reliability and capacity | items and bytes, queues, retries, age, persistence, shedding, freshness, loss, failure modes |
| security and privacy | synthetic tests, least privilege, transport/storage policy, bounded diagnostics, sanitized submission |
| overhead, cost, rollout | formulas and uncertainty, canary gates, one-class changes, abort and rollback |
| recovery and communication | user/topology/pipeline/privacy/cleanup proof, fair alternatives, concise handoff, twelve limits |

A numeric total does not override a broken independence, authorization, safety, evidence-integrity, or cleanup gate. Only an independent qualified reviewer may score the attempt and decide whether the evidence is sufficient. The reviewer may require another unseen case.

### Answer-isolation rule

No diagnosis, ranked hypothesis outcome, exact remediation, fault manifest, or scenario-specific recovery answer appears here. Do not ask an AI, colleague, instructor, or search engine to solve the active case while claiming independent evidence. Allowed help must be declared and may convert the attempt into guided practice.

Reading this rubric can improve your process. It cannot award mastery. Mastery requires repeated safe performance on unfamiliar systems after delay, with review and honest limits.

## References and review

The reference registry records live in the draft support package until promotion. This lesson cites identifiers only so canonical URLs, ownership, review dates, and claim scope remain controlled by those records.

- **REF-0166 — W3C Trace Context Recommendation.** Normative source for `traceparent`, `tracestate`, processing, privacy, and security. It supports interoperable context syntax and handling; it does not make a trace identifier authentication, authorization, or causal proof.
- **REF-0170 — OpenTelemetry Collector Architecture.** Official architecture for receivers, processors, exporters, extensions, connectors, pipelines, and deployment patterns. Component availability and configuration depend on the exact distribution and release.
- **REF-0173 — OpenTelemetry Specification 1.59.0.** Specification overview for API, SDK, data, context, and signal contracts at the review date. Individual language and signal maturity still governs implementation.
- **REF-0174 — OpenTelemetry Python status and maturity.** Official Python language status. At review, traces and metrics were listed Stable, logs Development, and Python 3.10 or newer supported; verify the current page and exact packages before use.
- **REF-0175 — Manual instrumentation for OpenTelemetry Python.** Official Python guidance for providers, tracers, spans, attributes, events, status, exceptions, and context. It is not a production schema or overhead guarantee.
- **REF-0176 — OpenTelemetry Python exporters.** Official Python export and batching guidance, including OTLP setup. Exact package names, environment variables, defaults, and protocol support must match the locked version.
- **REF-0177 — Python SDK context propagation.** Official inject and extract guidance for carriers. It supports propagation mechanics; transport-specific serialization, trust, parent/link semantics, and baggage policy remain application responsibilities.
- **REF-0178 — OpenTelemetry baggage concepts and security.** Official concept source for distributed baggage and its propagation risk. It supports strict minimization and trust boundaries; organizational privacy and authorization policies still govern use.
- **REF-0179 — OTLP Specification 1.11.0.** Normative protocol source for traces, metrics, logs, and developing profiles at review. Protocol acknowledgement, retry, partial success, and transport semantics do not automatically prove durable backend storage.
- **REF-0180 — Collector configuration and service pipelines.** Official configuration guide for named components and pipeline enablement. Examples are living documentation and must be validated against the exact distribution.
- **REF-0181 — Collector resiliency.** Official guidance for queues, retries, persistent buffering, scaling, and failure behavior. It supports bounded resilience design; it does not guarantee no loss or exactly-once delivery.
- **REF-0182 — OpenTelemetry sampling concepts.** Official overview of head and tail sampling and related trade-offs. Exact sampler and processor behavior depends on implementation, routing, policy, and version.
- **REF-0183 — Semantic Conventions 1.43.0.** Official semantic-convention release at review. The umbrella version does not imply every individual convention is stable; record the exact convention and stability used.
- **REF-0184 — Collector troubleshooting.** Official troubleshooting techniques for configuration, internal telemetry, local exporters, and live diagnostics. Debug methods can expose payloads or add load and need a bounded synthetic-data policy.

### Assessment map

- **ASM-0064** is the complete-answer diagnostic case: broken context after an asynchronous queue plus a configured-but-disabled traces pipeline.
- **ASM-0065** is the complete-answer production design: payment-path instrumentation, agent and gateway pipeline, sampling, security, capacity, cost, and rollout.
- **ASM-0066** is the reviewer-only independent transfer. It contains no model answer and cannot use this chapter's known guided case.

Answered assessments teach reasoning and permit comparison. They do not count as unseen transfer after their answers are read.

### Review checklist

On or before 2027-02-07, or earlier after a material release, a reviewer should:

1. Confirm exactly 18 required level-two sections in the required order.
2. Confirm exactly six diagram records, twelve command records, two lab records, four incident records, three assessments, and fourteen references.
3. Validate the front matter against the lesson schema without publishing the draft.
4. Validate ASM-0064 and ASM-0065 as full-answer records and ASM-0066 as answer-isolated with forbidden answer fields absent.
5. Recheck REF-0166 and REF-0170, then every REF-0173 through REF-0184 registry record, canonical URL, current version, maturity, claim scope, and review window.
6. Verify current OpenTelemetry specification, Python status, Python package and exporter guidance, OTLP, Collector configuration and resiliency, sampling, Semantic Conventions, and troubleshooting behavior.
7. Compare every command with the actual support interface, risk class, namespace, expected branches, cleanup, `proves`, and `doesNotProve`.
8. Confirm absent or mismatched locked artifacts fail closed. Do not convert a model pass into OpenTelemetry execution evidence.
9. Re-run exact-image configuration validation and both explicit verifier modes on the normal-user offline lifecycle. Preserve actual output and failures.
10. Confirm root refusal where passwordless sudo is available, exact ownership, foreign-resource refusal, zero host ports, internal-network scope, no setup downloads, bounded timeouts, guaranteed recovery, repeated cleanup, and final absence.
11. Review the traceparent parser against W3C version processing and keep it labeled as a bounded teaching parser.
12. Review parent-versus-link guidance against current messaging conventions and at least one representative transport.
13. Review baggage, attributes, debug output, receiver binding, credentials, tenant routing, evidence sanitation, retention, and deletion with security and privacy owners.
14. Review head, parent, and tail sampling claims against the exact implementations, including routing, pending state, timeout, late spans, eviction, and upstream population.
15. Recalculate queue and tail-state examples, verify units, and test representative payload shapes before production guidance is accepted.
16. Run project content, schema, reader, lint, typecheck, build, route, asset, 404, privacy, secret, residue, and source-hygiene gates on the exact promotion candidate.
17. Obtain independent technical, instructional, safety, accessibility, and mastery-integrity review.
18. Keep formal acceptance, learner evidence, delayed recall, production evidence, and provider proof separate from publication.

### Final proof boundary

This quarantined lesson teaches how meaning can survive—or fail to survive—from instrumentation to query. Its metadata and prose do not establish that the current support code runs. The image digests and fourteen-wheel dependency set are exact and complete; a prior controller revision completed the bounded Ubuntu runtime, but the current interruption-safe lock revision must pass the full verifier before canonical promotion. The deterministic model remains explanation evidence, never a substitute for that runtime receipt.

If a later reviewer supplies immutable artifacts and records a successful normal-user offline execution, that result remains local and version-bound. Production claims require representative applications, transports, Collector distributions, security, scale, destinations, failures, and independent evidence. Learner mastery requires answer-isolated transfer, qualified review, delayed retrieval, and safe performance in unfamiliar systems.

Keep this sentence beside every trace screen:

> A trace is a sampled report carried through fallible boundaries; preserve the operation's meaning, measure every handoff, and never claim more than the evidence path can prove.
