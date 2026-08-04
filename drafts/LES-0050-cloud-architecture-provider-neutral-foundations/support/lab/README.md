# LES-0050 local architecture model

This normal-user Ubuntu 24.04 lab evaluates a small provider-neutral architecture contract. It creates one UID-scoped directory under `/tmp`, uses no network, cloud CLI, credentials, account, subscription, project, provider API, paid resource, container or privileged operation.

Run:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh show
bash lab.sh evaluate
bash lab.sh scenario zone-loss
bash lab.sh cleanup
```

Available scenarios are `zone-loss`, `quota-exhaustion`, `api-throttle`, `managed-region-outage`, `policy-denial`, `capacity-shortage`, `cost-anomaly`, and `shared-dependency`.

For maintainer verification, run `bash verify.sh`. A passing result proves deterministic model behavior, refusal of unknown state, and exact cleanup only. It does not prove any AWS, Azure, Google Cloud, quota, location, managed-service, failover, backup, restore, security, cost or production behavior.
