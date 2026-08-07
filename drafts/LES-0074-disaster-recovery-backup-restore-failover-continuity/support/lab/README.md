# LES-0074 local recovery decision lab

This is an offline evidence-gate model, not a backup, restore, failover or disaster-recovery tool. It creates one UID-scoped directory under `/tmp`, copies synthetic JSON, evaluates 45 deterministic cases, refuses unknown artifacts and removes only its two allowlisted files.

It does **not** inspect or alter a host, service, database, route, DNS record, cloud resource, container, Kubernetes cluster, backup, credential or production system. It generates no load and opens no network connection or port.

## Safe start

Use Ubuntu 24.04 as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Inspect the defensible baseline and common recovery traps:

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh evaluate replica-called-backup
bash lab.sh evaluate wal-or-incremental-chain-gap
bash lab.sh evaluate application-correctness-unchecked
bash lab.sh evaluate old-primary-can-still-write
bash lab.sh evaluate failback-unplanned
```

The model teaches that replication propagates corruption and deletion, a successful backup job is not a usable restore, database recovery depends on a complete chain, restored bytes need application and security validation, RPO/RTO require measured outcomes, failover needs single-writer fencing, and failback is a separate controlled migration.

Prove the complete lifecycle:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=45 refusal=true cleanup=true
```

Passing proves only this local model's decision ordering and cleanup. Real recovery evidence requires owned business targets, representative isolated infrastructure, authentic backup chains, protected keys and credentials, restore correctness, measured data loss and elapsed time, authorized failover/failback, security review and user-flow validation.
