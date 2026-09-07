# LES-0063 guarded offline lab

This lab is a deterministic architecture-boundary model for lakehouse and table reliability. It teaches where to look first when catalog state, snapshots, manifests, schema/partition evolution, concurrent writes, retention, compaction, query plans, workload isolation, authorization, or audit evidence is unsafe.

It does **not** start Trino, Iceberg, a catalog, metastore, object store, query engine, compactor, data service, network listener, dataset, table, snapshot, manifest, data file, delete file, query, benchmark, or external resource. Its output is teaching evidence only.

## Supported environment

- Ubuntu 24.04
- normal user; UID 0 is refused
- Bash and Python 3 standard library
- no network or credentials
- state limited to `/tmp/reliability-atlas-les0063-lakehouse-table-<uid>`

## Guided lifecycle

From this directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh evaluate orphan-cleanup-races-writer
bash lab.sh evaluate small-files
bash lab.sh evaluate scan-budget-exceeded
bash lab.sh cleanup
```

Run the complete bounded verifier only when its UID-scoped state path is absent:

```bash
bash verify.sh
```

Expected final line:

```text
verify=pass cases=20 refusal=true cleanup=true
```

## Safety and recovery

Stop if `doctor` refuses the environment, if the state path already exists, or if any unknown artifact appears. Do not bypass guards. Preserve the first error, inspect the exact UID-scoped path, and use `bash lab.sh cleanup` only after the inventory is valid. The verifier injects one unknown file, proves operations fail closed, removes only that exact file, and proves final state absence.
