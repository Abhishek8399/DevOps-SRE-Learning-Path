# LES-0036 bounded resilience reasoning lab

This lab teaches failure-containment reasoning without starting a service or generating traffic. It reads one fictional JSON scenario, runs six deterministic policy models, writes only one validated UID-scoped directory under /tmp, opens no port and sends no network request.

## Requirements

- Ubuntu 24.04 or WSL 2 Ubuntu 24.04
- a normal, non-root user
- Bash, Python 3 and standard GNU utilities

From this directory:

~~~bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh run deadline
bash lab.sh run retries
bash lab.sh run jitter
bash lab.sh run idempotency
bash lab.sh run circuit
bash lab.sh run bulkhead
bash verify.sh
~~~

The verifier checks the scenario contract, exact state lifecycle, deadline arithmetic, retry amplification, jitter spread, idempotency replay and conflict behavior, breaker recovery, bulkhead containment, unexpected-entry refusal and cleanup absence.

The state path is exactly /tmp/reliability-atlas-les0036-<uid>. Cleanup validates the real path, owner, sentinel, manifest, scenario and allowed children before removal. If validation refuses a state, preserve it and inspect it; do not bypass the guard with a broad manual deletion.

This model does not test real clocks, concurrency, sockets, databases, proxies, Kubernetes or a dependency. Its values are fictional. A production experiment requires explicit authorization, one bounded cohort, baseline, abort and rollback owners, user and correctness telemetry, paced recovery, reconciliation and cleanup proof.
