# LES-0054 local Azure readiness model

Run `bash lab.sh doctor`, `setup`, `list`, `show baseline`, `evaluate CASE`, `status` and `cleanup` as a normal Ubuntu 24.04 user. The fixture contains only eight booleans. It uses no tenant, subscription, credential, Azure CLI, PowerShell module, SDK, API, provider or network.

`bash verify.sh` checks one baseline, eight first-boundary failures, unknown-state refusal and exact cleanup. It proves only deterministic lesson logic.

