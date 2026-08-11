# API contracts: make callers and operators safer

An API is a contract between independent systems. Reliability comes from explicit semantics, compatibility rules, bounded behavior, and evidence—not from a tidy JSON example alone.

```text
caller -> auth/validation -> handler -> state/dependency -> response/event
   |          |                |             |                  |
 contract   policy          timeout       idempotency        status
```

## Semantics before shape

Define resource identity, ownership, authorization, validation, side effects, consistency, and failure behavior before fields. Use HTTP methods and status codes consistently, but document asynchronous operations with an operation ID and status endpoint rather than pretending a queued job is complete.

## Compatibility

Prefer additive fields, tolerant readers, explicit enum evolution, and versioned breaking changes. Removing a field, changing meaning, tightening validation, or changing default pagination can break old clients silently. Contract tests should cover status, headers, error shape, and important invariants.

## Idempotency and retries

State-changing requests need an idempotency key or a documented non-retryable contract. Store the key with the resulting effect and reject conflicting reuse. Set deadlines, bound request size and pagination, and return a correlation ID without leaking internals.

## Security and observability

Authenticate the caller, authorize the resource and action, validate tenant scope, redact secrets and personal data, and log decisions with controlled identifiers. Metrics should distinguish route, method, status class, and latency without putting unbounded request IDs into labels.

## Safe local exercise

Create a local contract document for an asynchronous job API. Define request/response/error JSON, idempotency behavior, pagination limits, timeout, and versioning rules. Write fixture tests for duplicate keys, malformed input, unauthorized tenant, unknown enum, and operation polling. No external service is required.

## Triage sequence

1. Capture method, route, caller, request ID, version, status, latency, and dependency timing.
2. Separate transport, authentication, authorization, validation, handler, and downstream failures.
3. Check idempotency and operation state before retrying a mutation.
4. Protect the service with size, concurrency, rate, and deadline limits.
5. Verify the user-visible state and contract compatibility after recovery.

## Interview defense

**Question:** “A client retries a POST and creates two resources. What changes?”

**Strong answer:** “Define an idempotency key scoped to the operation and caller, persist it atomically with the effect, return the original result on replay, reject conflicting payload reuse, and document deadline/retry behavior.”

**Question:** “How do you evolve an API without breaking consumers?”

**Strong answer:** “Measure actual usage, prefer additive changes and tolerant readers, version breaking semantics, contract-test old clients, publish deprecation and migration windows, and monitor errors after promotion.”

## Teach-back checkpoint

Design one asynchronous API. State its identity, auth boundary, idempotency key, error contract, timeout, pagination limit, compatibility rule, and evidence proving the operation completed.
