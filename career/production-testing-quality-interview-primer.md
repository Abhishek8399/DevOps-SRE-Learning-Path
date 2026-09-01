# Production testing and quality interview: test the decision, not just the code path

A green test suite proves only the contracts it actually exercised. Production engineering begins when you can state the missing contract, the environment boundary, and the evidence needed before a change reaches users.

```text
intent -> unit contract -> integration boundary -> deployment gate -> user journey -> production evidence
  |             |                 |                    |                  |              |
logic        local behavior     real dependency     safe rollout       customer path   unknowns remain
```

## Scenario 1: the pipeline is green, but the release breaks old clients

**Question:** Every unit test passed, but an older client fails after deployment. What was missing?

**Strong answer:** Unit tests proved local implementation behavior, not the API compatibility contract. I identify the affected client/version and compare the exact request/response, error, pagination, authentication, serialization, default, and ordering semantics. I add consumer-driven or versioned contract tests that run the supported client shapes against the provider before rollout. The test must include tolerated unknown fields, missing versus null values, enums, error payloads, and asynchronous events where those are part of the contract.

I restore or gate a compatible behavior first, then define an explicit deprecation path with adoption telemetry and owner. A schema that validates on the server is not enough: generated clients, strict decoders, signed payloads, caches, and downstream consumers can still break.

**Weak answer:** "Add more unit tests." More tests at the same boundary do not prove a client can consume the release.

**Senior follow-up:** What proves compatibility? A representative supported consumer exchange under the intended deployment contract. It does not prove every unofficial or uninstrumented client is safe.

## Scenario 2: an integration test is flaky only in CI

**Question:** A test fails intermittently in CI but rarely locally. Engineers want to retry it automatically. What do you do?

**Strong answer:** I treat flakiness as evidence of an uncontrolled dependency, timing assumption, shared state, ordering race, resource limit, or environment mismatch. I preserve the failed run's inputs, logs, timing, seed, image/dependency versions, worker identity, and isolation boundary. Then I attempt deterministic reproduction by controlling time, random seed, ordering, network behavior, temp paths, and test data ownership.

I separate a true product race from an unreliable test harness. Retrying may be a temporary containment to protect delivery, but it must report the retry and cannot convert an intermittent failure into a quality pass. The durable fix is isolated data, explicit readiness, deterministic clocks/fixtures, bounded timeouts, cleanup verification, and failure artifacts that allow the next engineer to distinguish environment loss from assertion failure.

**Weak answer:** "Retry three times and ignore it if it passes." That hides a possible concurrency defect and erodes trust in every green build.

**Senior follow-up:** When can a test be quarantined? Only with an owner, scope, expiry, visible signal, risk assessment, and replacement/recovery plan. Quarantine is an exception record, not deletion of evidence.

## Scenario 3: a load test says the platform can handle more traffic

**Question:** A load test reports 10,000 requests per second. Can you use that number for capacity approval?

**Strong answer:** Not until I understand the workload and measurement. I verify request mix, payload size, cache state, authentication, write/read ratio, connection reuse, concurrency, warm-up, duration, arrival pattern, data cardinality, dependency behavior, error policy, hardware/topology, and the user-facing latency distribution. A short warm-cache benchmark can measure a very different system from a sustained production peak.

I report throughput with saturation signals: p50/p95/p99 latency, errors by cause, queue depth/age, CPU throttling, memory/GC, disk/network behavior, connection pools, downstream limits, and recovery after load stops. I identify the knee—where extra demand causes disproportionate delay or errors—and leave a safety margin rather than advertising the highest observed number. Capacity approval also needs failure-mode tests: slow dependency, partial region loss, cache miss amplification, retry behavior, and data growth.

**Weak answer:** "The average response time was low." Averages can look healthy while the customers with tail latency or errors are harmed.

**Senior follow-up:** Does a successful test prove production capacity? No. It proves the stated fixture, workload, duration, and instrumentation. It is input to a capacity model, not a universal guarantee.

## Scenario 4: a deployment rollback passed but data is now incompatible

**Question:** The application image rolled back cleanly after errors, but writes made during the release are unreadable by the old version. What should have been tested?

**Strong answer:** Release rollback and data rollback are separate contracts. Before deployment, I map schema, event, feature-flag, cache, and API compatibility in both directions: old app with new data, new app with old data, and mixed fleet behavior. I use expand/contract migration patterns where possible: add compatible structures first, deploy code that understands both shapes, backfill with observability and controls, remove old behavior only after adoption and recovery windows.

The rollout gate verifies a representative write and read through both compatible versions when a rollback promise exists. If irreversible data work is necessary, the release plan states that rollback is not an option after a defined point and provides a forward-fix, restore, or reconciliation plan with ownership. I do not call a container rollback successful when the customer's durable state became unusable.

**Weak answer:** "Images are immutable, so rollback is safe." Image immutability says nothing about external state that changed while that image ran.

**Senior follow-up:** What is the smallest safe rollback test? A bounded environment with the real version pair and representative data transition, followed by an explicit user-operation check and cleanup/reconciliation proof.

## Scenario 5: dependency upgrade passes tests but fails after release

**Question:** A library upgrade passed the test suite, then fails on a production-only code path. How do you harden the process?

**Strong answer:** I first identify the resolved dependency graph, lockfile, runtime version, platform/image, transitive change, feature path, and whether the build used the same artifact that was released. "Version X was installed" is insufficient when resolution, optional dependencies, native modules, environment flags, and caches differ.

I pin and review dependency resolution, generate an SBOM or equivalent inventory where appropriate, test the built artifact in a production-like boundary, and add coverage for the affected compatibility path. I distinguish a vulnerability or compatibility fix from permission to upgrade everything: broad upgrades expand the diagnosis and rollback surface. Release metadata records source revision, dependency lock/artifact digest, test results, and rollback route so an incident can reproduce what actually changed.

**Weak answer:** "Use the latest version everywhere." Freshness can be valuable, but uncontrolled resolution turns a small change into an unknown bundle.

**Senior follow-up:** What does a lockfile prove? The intended resolved graph for the supported tooling and platform. It does not prove a registry artifact is safe, that runtime behavior is compatible, or that every deployment used it.

## Scenario 6: reproducing an incident risks touching customer data

**Question:** A severe defect appears only with a customer's traffic pattern. How do you reproduce it without copying sensitive production data into a test environment?

**Strong answer:** I start with the minimum evidence required: request shape, timing, sizes, state transition, dependency response class, configuration/version, and observed failure—not unrestricted records. I preserve approved, access-controlled incident evidence and use synthetic, anonymized, tokenized, or privacy-reviewed fixtures that retain the causal properties needed for the hypothesis. I validate that anonymization does not create false confidence by changing cardinality, ordering, referential relationships, or edge conditions that drive the bug.

The reproduction environment has a defined data owner, retention, access boundary, no production credentials, no external customer effects, and cleanup verification. If a safe representative fixture cannot be built, I state that limitation and use bounded production observation with approvals rather than widening data access. The goal is a testable causal hypothesis, not maximum data collection.

**Weak answer:** "Copy the production database to staging." That expands privacy, security, retention, access, and accidental-effect risk without proving the copy is needed.

**Senior follow-up:** What proves an incident reproduction? The controlled fixture produces the observed failure, the changed condition removes it, plausible alternatives are tested or documented, and the result stays within the stated proof boundary.

## Fast decision map

| Symptom | Remember | First safe move |
|---|---|---|
| green tests, broken clients | Provider code is not the whole contract | Compare exact client/provider semantics and gate compatibility |
| flaky CI test | Retry is not diagnosis | Preserve inputs and reproduce under controlled conditions |
| impressive throughput number | Throughput is not capacity | Inspect workload, tails, saturation, and recovery |
| image rollback | Compute rollback is not data rollback | Test both version/data directions before promising rollback |
| dependency regression | Installed version is not release identity | Trace lockfile, artifact, runtime, and affected path |
| production-only bug | More customer data is not better evidence | Build a minimum safe fixture with a clear privacy boundary |

## Practice

For every test result, ask: **what exact decision does this evidence authorize, and what does it still not prove?** That one habit turns testing from a checkbox into a reliable engineering control.
