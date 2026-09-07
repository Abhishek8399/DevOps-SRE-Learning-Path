# LES-0055 local GCP readiness model

Run `bash lab.sh doctor`, `setup`, `list`, `show baseline`, `evaluate CASE`, `status` and `cleanup` as a normal Ubuntu 24.04 user. The fixture contains only eight booleans. It uses no organization, billing account, project, credential, Google Cloud CLI, SDK, API, Terraform provider or network.

`bash verify.sh` checks one baseline, eight first-boundary failures, hostile-state refusal and exact cleanup. It proves only deterministic lesson logic. It does not simulate IAM, VPC, Compute Engine, GKE, Cloud Run, Cloud Storage, Cloud SQL, Monitoring, KMS, quotas, backup, failover, pricing or production behavior.
