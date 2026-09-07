# LES-0061 offline distributed-workflow boundary model

This deterministic model evaluates declared workflow boundaries. It is not a workflow engine, database, broker, CDC relay, transaction coordinator, payment system, external API, or benchmark. It opens no socket and creates no workflow, transaction, message, effect, account, external resource, or production claim.

From Ubuntu 24.04 as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate baseline
bash lab.sh evaluate state-outbox-split
bash verify.sh
```

The wrapper uses one exact UID-scoped directory under `/tmp`. It refuses root, credential hints, symlinks, wrong ownership, unexpected entries, unsupported OS versions, and pre-existing state. The verifier covers every encoded decision branch, refusal, and exact cleanup.
