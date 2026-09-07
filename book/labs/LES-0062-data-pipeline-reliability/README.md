# LES-0062 offline data-pipeline boundary model

This deterministic model evaluates declared data-pipeline boundaries. It is not Spark, Flink, Beam, a scheduler, broker, state backend, checkpoint store, data lake, catalog, lineage service, quality engine, external sink, or benchmark. It opens no socket and creates no job, dataset, checkpoint, stream, table, quality result, lineage event, external effect, load, or external resource.

From Ubuntu 24.04 as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate baseline
bash lab.sh evaluate sink-not-idempotent
bash verify.sh
```

The wrapper uses one exact UID-scoped directory under `/tmp`. It refuses root, credential hints, symlinks, wrong ownership, unexpected entries, unsupported OS versions, and pre-existing state. The verifier covers every encoded decision branch, refusal, and exact cleanup.
