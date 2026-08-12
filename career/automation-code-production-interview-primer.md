# Automation code production interview: make every effect explainable

Python, Shell, and Go are useful in platform work because they can turn an operational decision into a repeatable action. They are dangerous for the same reason: a short loop can create a wide blast radius.

```text
input -> validation -> decision -> approved effect -> observed result -> durable record
  |          |            |              |                  |              |
untrusted  fail closed  policy/owner   narrow scope       reconcile       audit/retry
```

The language is secondary. A production automation answer should explain data ownership, validation, idempotency, timeout/retry behavior, credentials, concurrency, effect reconciliation, and the proof limit of its logs.

## Scenario 1: a cleanup job deleted the wrong objects

**Question:** A nightly Python cleanup selected objects with a broad prefix and removed current customer data. How would you design it safely?

**Strong answer:** I do not let a human-readable name be the only deletion authority. I define an owned-object contract: stable identifier, explicit environment, owner, creation record, retention policy, lifecycle state, and deletion approval where the risk requires it. The job first lists candidates, validates every field against that contract, produces a reviewable dry-run record, and refuses unknown or ambiguous objects. A prefix is only a discovery hint; it is not permission.

For mutation, I scope requests to exact IDs, bound the batch, use an idempotent delete if the provider supports it, and record request identity plus observed postcondition. I rate-limit and stop on unexpected response classes rather than continuing after partial authorization or schema errors. A retention window, protected labels, and a two-person or time-delayed approval may be appropriate for high-value data. Tests include empty input, similarly named foreign objects, malformed timestamps, pagination, a failed delete, a delayed delete, and a rerun after interruption.

**Weak answer:** "Add a confirmation prompt." A prompt is easy to bypass in scheduled automation and does not make object selection correct.

**Senior follow-up:** How do you test destructive code without deleting real data? Use a bounded fixture or fake client that asserts exact request IDs and records effects. The fixture proves the contract implementation, not a provider's production behavior.

## Scenario 2: retries created duplicate tickets and notifications

**Question:** An API sometimes times out after accepting a request. Your script retries and creates duplicate incident tickets. What changes?

**Strong answer:** I distinguish an unknown result from a failed request. A timeout means the client did not learn the outcome; it does not prove the server did nothing. For a create operation, I use an idempotency key derived from a stable operation identity, store that key and the intended payload before sending, and have the receiving system return the existing result for the same key. If the API has no idempotency contract, I query through a narrow correlation identifier before retrying and make uncertainty visible rather than issuing blind creates.

Retries need a bounded attempt count, deadline, exponential backoff with jitter, retryable-error classification, and a concurrency limit. I do not retry validation failures, authorization failures, or every HTTP 4xx/5xx equally. I also prevent retry storms: a failing dependency plus hundreds of workers can turn recovery into overload. The final record says succeeded, definitively failed, or unknown/requires reconciliation; it never lies by calling an unknown effect a failure.

**Weak answer:** "Retry three times in a `try/except` block." Count alone does not handle duplicate side effects, backpressure, deadline, or a server that completed the first request.

**Senior follow-up:** Is a database unique constraint enough? It can be a valuable last line of defense, but the caller still needs a stable operation key, safe response handling, and a reconciliation path when its own network view is incomplete.

## Scenario 3: a script works interactively but fails in CI

**Question:** An engineer's Bash script works on a laptop but acts on the wrong account in CI. How do you diagnose and harden it?

**Strong answer:** I compare the execution contract, not just the command. I inspect working directory, shell, interpreter version, PATH, locale, time zone, inherited environment, credential source, configuration files, network boundary, filesystem permissions, and CI checkout/ref state. Interactive shells often have aliases, profiles, cached credentials, and current-directory assumptions that CI deliberately lacks.

The fix is explicitness: strict shell mode where appropriate, quoted variables, an absolute or repository-derived working directory, declared interpreter/dependency versions, explicit required variables with safe error messages, and an identity preflight that prints non-sensitive account/project/environment facts before mutation. I avoid parsing human-oriented command output when a structured API/JSON output exists. I pass data between commands with deliberate formats, not whitespace splitting; filenames and values can contain spaces, newlines, or option-like characters.

I create a clean-environment test that removes optional local configuration and runs the same entrypoint CI uses. The script should fail closed when it cannot establish the intended account or scope. A successful CI job still needs a postcondition for the user operation; a green shell exit code proves only the process exited zero.

**Weak answer:** "Install the missing tool in CI." That may fix one symptom while leaving wrong identity, hidden inputs, or unsafe parsing untouched.

**Senior follow-up:** Why avoid `eval` for generated arguments? It reinterprets data as code, creating injection and quoting failures. Use argument arrays in languages that support them, or structured inputs and fixed command forms.

## Scenario 4: concurrent runs race over the same operation

**Question:** Two scheduled automation runs both see an unhealthy resource and attempt remediation. One makes the situation worse. What is the design?

**Strong answer:** I define the operation's ownership and serialization boundary before adding a lock. The lock key should represent the resource or customer operation, not the whole world and not a random process-local file. The lock must have an owner identity, expiry or lease semantics, renewal behavior where justified, an observable record, and a recovery procedure for a crashed owner. A stale lock is evidence to investigate, not automatically permission to take over.

The remediation must also be safe if the lock fails or a lease expires at the wrong moment. I use compare-and-set/version checks, provider-side idempotency, and post-effect reconciliation. For example, before scaling or restarting, I re-read the current version/state and refuse if another actor changed it. I record the decision inputs, operation ID, actor, start/end time, and observed result. Tests simulate two contenders, owner crash, lease expiry, delayed response, changed resource version, and cleanup of the coordination record.

**Weak answer:** "Use a global mutex." A global lock reduces availability and does not establish whether the owner still has authority or whether the remote state changed.

**Senior follow-up:** When should an automation refuse to steal a lock? When ownership cannot be proven absent, the operation is not safely idempotent, the resource is high-impact, or the runbook does not authorize takeover. Escalation can be safer than progress.

## Scenario 5: automation logs a token and the team wants to delete the logs

**Question:** A debugging path printed an access token. What is your response?

**Strong answer:** I treat it as potential credential exposure, not a formatting bug. I contain access according to the logging system's controls, preserve enough audit evidence for incident investigation, identify the token owner, scopes, lifetime, log destinations, retention, artifact copies, and readers, then rotate or revoke through the owning identity system. Deleting the visible line does not revoke copies, terminal history, build artifacts, backups, or downstream indexing.

The code fix removes secrets from command arguments, exceptions, structured fields, debug dumps, and diagnostic representations. It accepts secret references or short-lived workload identity rather than long-lived literals. Redaction is defense in depth: it should be centrally tested, but it does not replace least-privilege access, short expiry, rotation, artifact retention policy, or code review. I add regression tests for failure paths because errors often serialize the inputs that success paths do not.

**Weak answer:** "Mark the variable secret in CI." Masking may reduce display in one UI, but it does not guarantee absence from process lists, child environments, artifacts, or third-party tools.

**Senior follow-up:** What do you tell stakeholders? State the known scope, containment action, rotation status, evidence still being reviewed, and next update time. Do not claim the secret is safe merely because one log search found nothing.

## Scenario 6: a successful automation run did not restore the user journey

**Question:** A remediation tool reports success after restarting workers, but customers still receive errors. What did the automation miss?

**Strong answer:** It measured an implementation effect, not the user outcome. I trace the request path: client, edge, identity, service, queue, datastore, and dependency boundaries. A worker process can be running while it has no traffic, bad credentials, a stale configuration, an exhausted connection pool, or an incompatible downstream dependency. I add a bounded, non-destructive verification that represents the intended user operation and has clear ownership, test data, privacy controls, and a proof limit.

The automation records preconditions, action, expected result, actual result, and reconciliation result separately. If the user check fails, the run exits into a clearly named degraded or unknown state and does not repeat the same restart indefinitely. That record becomes useful incident evidence: it tells the next operator what changed, what was observed, and which layer is still unproven. Prevention includes service-level indicators, health checks designed around real dependencies, canary scope, and a circuit or stop condition around repeated remediation.

**Weak answer:** "The command returned zero, so the incident is resolved." Process exit status is a transport signal from one component, not a customer-impact verdict.

**Senior follow-up:** Can a synthetic check replace real telemetry? No. It covers one designed path at one time. Combine it with service metrics, logs, traces, dependency evidence, and an understanding of its blind spots.

## Answer map

| Symptom | The sentence to remember | First safe action |
|---|---|---|
| broad cleanup selector | Discovery is not deletion authority | Validate exact owned IDs and dry-run candidate set |
| request timeout | Unknown is not failed | Reconcile using an idempotency/correlation key before retry |
| local-only success | The environment is an input | Prove identity, paths, versions, and required variables in a clean run |
| two remediation runs | A lock is not authority by itself | Establish owner, resource version, and safe takeover policy |
| secret in output | Redaction is not rotation | Contain, revoke/rotate, then fix every success and error path |
| exit zero but users fail | Component success is not user success | Verify a bounded representative user operation |

## Practice

For each scenario, answer in this order: scope at risk; required evidence; evidence proof limit; smallest safe effect; reconciliation; prevention. Avoid practising by invoking real credentials, destructive APIs, or production endpoints. Good automation is quiet because it refuses ambiguity, not because it hides it.
