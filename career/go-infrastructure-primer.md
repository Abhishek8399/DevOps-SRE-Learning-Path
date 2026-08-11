# Go for infrastructure: make concurrency cancellable

Go is valuable for infrastructure tools because a small static binary can coordinate network calls and concurrent work. Its operational quality depends less on syntax than on bounded concurrency, cancellation, clear errors, and observable state.

```text
command -> context/deadline -> worker pool -> API/filesystem -> verified result
   |            |                  |              |                |
 flags       cancel             bounded        timeout          evidence
```

## Context and cancellation

Pass `context.Context` through every operation that can block. Set deadlines at the boundary, propagate cancellation to goroutines, and ensure workers exit when the parent is done. A goroutine leak becomes a file descriptor, connection, memory, or shutdown problem.

## Bounded concurrency

Use a fixed worker pool or semaphore rather than spawning one goroutine per host or object without limit. Bound queues, collect errors, and decide whether one failure cancels the batch or the tool reports partial success. Preserve stable identifiers so a rerun can reconcile rather than duplicate effects.

## Errors and APIs

Wrap errors with operation and target context while preserving the cause for inspection. Distinguish timeout, cancellation, authorization, not-found, conflict, and server errors. For HTTP clients, configure transport timeouts, response-size limits, retries only for safe operations, and redacted structured logs.

## Safe local exercise

Build a small Go command that reads a local JSON inventory, uses a bounded worker pool to inspect fixture files, honors a timeout, and emits a summary plus per-target errors. Cancel it midway, prove workers exit, and rerun without duplicate output. Do not call external systems.

## Triage sequence

1. Record binary version, flags, target count, deadline, and concurrency limit.
2. Reproduce with a small fixture and race-safe deterministic inputs.
3. Inspect goroutine, connection, file-descriptor, queue, and error behavior.
4. Stop or cancel the batch on unsafe partial effects; preserve per-target receipts.
5. Verify cleanup, repeatability, and exit status for automation callers.

## Interview defense

**Question:** “Why did a Go controller leak goroutines?”

**Strong answer:** “A blocking operation or channel path ignored context cancellation, so workers outlived the request. I trace ownership, add deadlines and select-on-context paths, bound queues, close resources, and test cancellation and repeated reconciliation.”

**Question:** “How do you handle partial failure across 1,000 targets?”

**Strong answer:** “Bound concurrency, preserve stable target IDs and per-target results, classify retryable versus terminal errors, honor a global deadline, and return a non-zero status when the contract is not satisfied. I never hide failures behind one aggregate success.”

## Teach-back checkpoint

Design a concurrent infrastructure command. State its deadline, worker limit, cancellation path, queue bound, error classes, retry policy, partial-success contract, and cleanup proof.
