# Testing and debugging: turn uncertainty into a smaller search

Tests provide evidence at a boundary; debugging explains a failure’s first bad assumption. Neither a green unit test nor a long log proves the whole system works.

```text
failure -> reproduce -> isolate boundary -> inspect evidence -> smallest fix -> regression -> package/release
   |          |              |                  |                 |             |
 symptom   fixture        scope              facts             diff          proof
```

## Test boundaries

Unit tests protect pure logic quickly. Integration tests protect real interfaces and serialization. System tests protect user journeys. Contract tests protect independent callers. Choose the smallest test that can disprove the suspected cause, then add the broader regression when the boundary is understood.

## Reproducibility and dependencies

Record source revision, runtime/tool versions, dependency lock/hash, environment, inputs, and expected output. A package lock improves repeatability but does not prove supply-chain trust; verify provenance, licenses, vulnerability treatment, and transitive changes according to risk.

## Debug unfamiliar systems

Start at the first meaningful error, trace data backward, and distinguish missing input, wrong type, empty result, timeout, permission, and stale state. Add focused diagnostics with redaction. Avoid broad exception swallowing and avoid changing multiple variables before a hypothesis is tested.

## Packaging and release evidence

Build from a clean workspace, produce an immutable artifact and manifest, test the artifact—not only the source tree—and compare checksums or digests. Record what was generated and how a fresh environment can reproduce or verify it.

## Safe local exercise

Create a small parser with a known failing fixture. Add a unit test for the pure parser, an integration test for file encoding, and a system assertion for the user-visible result. Package it in a temporary environment, tamper with an input, and prove the test and checksum gates fail. Delete fixtures.

## Triage sequence

1. Capture revision, command, environment, input, first error, and expected result.
2. Reproduce with the smallest sanitized fixture.
3. Isolate parsing, dependency, interface, state, timing, and packaging boundaries.
4. Apply one fix, add the regression, and rerun the artifact path.
5. Verify clean-build, integrity, security, and user outcome.

## Interview defense

**Question:** “A test passes locally but fails in CI. What do you compare?”

**Strong answer:** “Revision, lockfile, runtime/tool versions, locale/timezone, filesystem, environment variables, network/dependency availability, parallelism, and generated artifacts. I reproduce in the CI-like environment and classify environment versus code failure before changing the test.”

**Question:** “How do you debug an empty database result?”

**Strong answer:** “Check filters and types progressively, log safe query inputs, verify data and time window, inspect null/enum/unit mismatches, and fail with context rather than indexing an empty result or silently continuing.”

## Teach-back checkpoint

Design a test pyramid for one service. State each boundary, fixture, failure it can disprove, reproducibility record, artifact integrity check, and the evidence required before release.
