# Postmortem 0001: verifier accepted an empty load step until the SLO reader failed

Date: 2026-08-07. Environment: local Ubuntu 24.04 WSL capstone validation. Production/customer impact: none.

## Summary

The end-to-end verifier completed unit tests, API checks, backup and restore, then failed because the SLO input contained zero records. The load utility defined `main()` but did not call it. The process therefore exited with code zero and empty stdout. The next stage correctly refused an empty sample, but the verifier initially hid captured stderr inside a generic subprocess exception.

## Impact

CAP-001 validation was delayed. No external service, learner record, production state or customer request was affected. The event revealed a false-green boundary: process success was treated as artifact success.

## Timeline

- Load utility executed with a valid loopback target and returned code zero.
- Verifier wrote empty stdout to the sample path.
- SLO utility refused the empty input.
- First error report exposed only the command and return code.
- Verifier subprocess handling was changed to report captured stdout/stderr.
- Rerun identified `input contains no request records`.
- Missing module entry-point call was added.
- Full verifier then passed healthy and latency-fault SLO calculations.

## Contributing conditions

- The load module had no direct test that executes it as a program.
- The verifier checked subprocess exit status but not non-empty/conserved record count before writing the artifact.
- Captured diagnostic streams were not attached to the first raised error.

No individual action alone explains the event. Python correctly loaded definitions and exited successfully; the pipeline's acceptance contract was incomplete.

## Corrective actions

- Completed: invoke `main()` under the standard module entry-point guard.
- Completed: include stdout/stderr in failed captured-subprocess diagnostics.
- Completed: SLO reader continues to refuse empty input.
- Completed: verifier checks 40 healthy and 20 delayed records explicitly before SLO calculation.
- Required before publication: add a separately maintained CLI contract test around process invocation and malformed-output branches.

## Learning

Exit code zero means the process completed its own code path; it does not prove the expected artifact exists or contains conserved work. Pipeline gates must validate outputs, counts and meaning—not only command status.
