# LES-0037 bounded Infrastructure as Code reasoning lab

This lab teaches IaC reasoning without installing a provider, opening a port or creating infrastructure. It reads one fictional JSON scenario, runs seven deterministic cases, writes only one validated UID-scoped directory under /tmp and sends no network request.

## Requirements

- Ubuntu 24.04 or WSL 2 Ubuntu 24.04
- a normal, non-root user
- Bash, Python 3 and standard GNU utilities

From this directory:

~~~bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh run graph
bash lab.sh run plan
bash lab.sh run drift
bash lab.sh run policy
bash lab.sh run partial
bash lab.sh run converge
bash lab.sh run sensitive
bash verify.sh
~~~

The verifier checks the scenario contract, graph order, action classification, drift ownership, policy denial, partial execution, convergence, sensitive storage, unexpected-entry refusal and exact cleanup.

The state path is exactly /tmp/reliability-atlas-les0037-<uid>. Cleanup validates real path, owner, sentinel, manifest, scenario and allowed children before removal. Preserve a refused state for inspection; do not bypass the guard with a broad delete.

This model is not Terraform, OpenTofu, a provider, a backend or a plan. It cannot establish target identity, API behavior, policy completeness, infrastructure safety or production outcome. Real IaC work requires separate authorization, locked dependencies, protected state, exact target identity, reviewed plan, constrained execution and post-change verification.
