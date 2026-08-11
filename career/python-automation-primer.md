# Python for DevOps: automate decisions, not surprises

Good automation is a small, typed, observable program with explicit scope, dry-run behavior, and a safe failure mode. Python is useful because it can join files, processes, APIs, and structured data without hiding the decision logic.

```text
input/config -> validate -> observe -> decide -> bounded effect -> verify
      |           |          |          |            |             |
   untrusted    types      context    policy       timeout       evidence
```

## Boundaries first

Parse arguments and environment values at the edge. Validate paths, identifiers, allowed hosts, and mutually exclusive options before opening files or calling APIs. Use `pathlib`, structured JSON, explicit timeouts, and a non-zero exit code for failure. Never log tokens, headers, or whole untrusted payloads.

## Subprocesses and APIs

Use `subprocess.run` with an argument list, timeout, captured output, and deliberate environment; avoid shell interpolation. For HTTP, set connect/read timeouts, validate status and content type, bound response size, retry only safe operations, and include a request ID. A successful HTTP response is not proof that the business operation completed.

## Idempotency and dry runs

An automation tool should say what it would change, make one bounded change, and verify the result. Use stable identifiers, compare desired/current state, and support `--dry-run` where mutation exists. Write checkpoints or receipts so a rerun can resume without duplicating effects.

## Testing and packaging

Keep pure parsing and decision functions separate from effects. Unit-test malformed input, empty results, timeouts, partial failures, and redaction. Pin dependencies, generate a lock or hash record appropriate to the project, and make the command reproducible from a clean environment.

## Safe local exercise

Write a Python script that reads a local JSON inventory, validates required fields, reports drift against a desired fixture, and in `--dry-run` mode proposes changes without writing. Add one controlled write to a temporary directory, verify its checksum, and test malformed JSON, missing keys, and timeout-like failure. Remove only the temporary directory.

## Triage sequence

1. Capture command, arguments, version, input identity, and scope.
2. Reproduce with a sanitized fixture and dry run.
3. Separate parsing, decision, effect, and verification failures.
4. Stop on ambiguous or partial effects; inspect receipts before retrying.
5. Verify the user-visible outcome and preserve structured evidence.

## Interview defense

**Question:** “How do you make a Python automation script production-safe?”

**Strong answer:** “Validate inputs at the boundary, use typed pure decision logic, explicit timeouts and bounded retries, least-privilege effects, dry-run and idempotency, structured redacted logging, non-zero failures, tests for partial states, pinned dependencies, and post-effect verification.”

**Question:** “The API returned 200 but the resource is missing. What do you do?”

**Strong answer:** “I distinguish transport success from business completion, use the operation/request ID, query the authoritative state, inspect asynchronous status, and reconcile before retrying. I do not blindly create a duplicate.”

## Teach-back checkpoint

Design a safe command-line tool. Name its input validation, dry-run output, timeout, retry policy, idempotency key, redaction rule, exit codes, verification query, and cleanup boundary.
