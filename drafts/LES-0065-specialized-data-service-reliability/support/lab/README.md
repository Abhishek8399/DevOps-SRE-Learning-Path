# LES-0065 guarded offline lab

This deterministic model teaches the first unsafe boundary across Cassandra-shaped partition/replica/storage maintenance, vector-search identity/recall/indexing/distribution, and data-catalog freshness/lineage/access.

It does **not** start Cassandra, Qdrant, OpenMetadata, a database, vector index, catalog, search engine, service, socket, dataset, query, backup, repair or external resource. Its output is teaching evidence only.

## Supported environment

- Ubuntu 24.04
- normal user; UID 0 is refused
- Bash and Python 3 standard library
- no network or credentials
- state limited to `/tmp/reliability-atlas-les0065-specialized-data-<uid>`

## Guided lifecycle

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate repair-window-missed
bash lab.sh evaluate recall-baseline-missing
bash lab.sh evaluate catalog-ingestion-stale
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=23 refusal=true cleanup=true
```

Stop on any guard failure. Do not bypass ownership, sentinel, symlink, unknown-artifact, credential or environment checks. Cleanup removes only the exact allow-listed files after validating the UID-scoped inventory.
