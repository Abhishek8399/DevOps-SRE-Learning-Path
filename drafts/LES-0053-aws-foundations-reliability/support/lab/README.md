# LES-0053 local AWS readiness model

Run `bash lab.sh doctor`, `setup`, `list`, `show baseline`, `evaluate CASE`, `status` and `cleanup` as a normal Ubuntu 24.04 user. The fixture contains only eight boolean readiness controls. It opens no socket, changes no host or cloud resource, and uses no AWS account, credential, CLI, SDK, API or Terraform provider.

`bash verify.sh` checks one operable baseline, eight first-boundary failures, unknown-state refusal and exact cleanup. A pass is deterministic reasoning evidence only. It does not prove AWS identity, networking, compute, storage, database, key, telemetry, quota, failover, recovery, pricing or production behavior.

The independent exercise is a reviewer-owned offline architecture review. It must use sanitized requirements and a pre-generated plan text only; no `terraform apply` or provider operation is permitted.

