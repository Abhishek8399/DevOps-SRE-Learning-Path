# Distributed data reliability capstone project

This project is an unpublished local teaching fixture. It is not a production deployment.

The first implementation boundary provides three digest-pinned, fixed-name, network-isolated services:

- PostgreSQL 18.4 owns transactional orders, idempotency, outbox, inbox/effects and restore tests.
- Apache Kafka 4.3.1 owns a retained local event log and consumer offsets.
- Redis 8.6.5 is an intentionally disposable bounded cache.

No service publishes a host port and the Compose services do not share a Docker network. Project tooling enters each fixed container with `docker exec`. This makes the local data paths visible and prevents accidental external connectivity; it is not a production service topology.

Redis runs explicitly as its image UID/GID 999:1000. The first runtime attempt let the root entrypoint try to change tmpfs ownership after all capabilities had been dropped; Redis then could not read its startup RDB path and exited. Setting the final user makes ownership a creation-time property and retains the no-capability boundary.

The first order submission also falsified an API-memory assumption: PostgreSQL has `jsonb_array_length` but no `jsonb_object_length`. The function now counts `jsonb_object_keys` explicitly before enforcing the six-field database boundary. The failed statement created no order or outbox row.

The local PostgreSQL instance uses trust authentication only because it has no network namespace connectivity and no host port. Reusing that setting in any reachable environment is unsafe.

Implemented commands are `check`, `up`, `init`, `submit`, `relay`, `inject-poison`, `seed-backlog`, `backlog`, `consume`, `reconcile`, `backup`, `restore`, `replay-restore`, `status` and `cleanup`. They are a local learning control surface, not a production operator or a substitute for managed backup, multi-zone replication or tested organizational recovery procedures.

`relay --stop-after-publish` deliberately exits 75 after Kafka acknowledges the event but before PostgreSQL marks the outbox row published. Retrying `relay` publishes the same stable event identity again. This models the unavoidable dual-write ambiguity and creates input for the idempotent-consumer stage; it does not claim Kafka transaction or exactly-once effect semantics.

The first retry did commit the outbox acknowledgement, but `psql` appended the `UPDATE 1` command tag to the returned event ID. The client correctly refused the unexpected two-line ownership receipt. Machine-facing PostgreSQL calls now use quiet tuples-only output so the receipt contains only the requested value.

`consume` performs a bounded read from the beginning of the local topic. Every record must expose partition, offset, key and a matching payload event ID. PostgreSQL records every first-seen delivery position but creates the inbox/business effect once per event ID and payload hash. Redis is updated only after that transaction and can be rebuilt by replay. This fixture deliberately avoids the phrase "exactly-once delivery": Kafka contains duplicates while the effect is idempotent.

`inject-poison` publishes one synthetic JSON object with an unsupported event schema/type. `consume` records only its partition, offset, stable event ID, payload hash and reason code in quarantine, then continues. The raw payload is not copied into the quarantine table or logs. Quarantine is containment, not resolution: review, compatibility decision, corrected producer and governed replay still need an operator.

`seed-backlog --count 9 --partition 0` constructs valid source orders whose Kafka keys map to one selected partition, commits their outbox rows and deliberately leaves them unconsumed. `backlog` reports each partition's log end offset, next processed offset and lag, plus total lag and the dominant partition's share. This makes the difference between queue depth and skew visible: adding consumers cannot parallelize one Kafka partition.

`reconcile` compares source and fact row counts, monetary control totals, missing/orphan rows, value mismatches, unpublished outbox rows and quarantine. Every run writes a small lineage receipt to `atlas.pipeline_runs` with named input/output datasets, metrics and pass/fail status. A failed gate exits 4; it is evidence that data is not yet trustworthy, not permission to edit the metric.

`backup` creates a PostgreSQL logical dump and a manifest containing its SHA-256 digest, byte count, source counts, Kafka high watermarks and explicit local objectives. Both files live under ignored `.runtime/` and must contain synthetic lab data only. `restore` verifies those controls before loading the dump into a new `atlas_restore` database; it refuses to replace that database or the active `atlas` database. `replay-restore` flushes only the disposable lab cache, replays retained Kafka records into the isolated database, reconstructs the cache and requires full source/fact reconciliation. Snapshot equality proves zero row loss at the recorded backup boundary; it does not promise continuous zero-RPO recovery.

Cleanup will remove only these fixed containers and volumes:

```text
atlas-data-postgres
atlas-data-redis
atlas-data-kafka
atlas-data-postgres-data
atlas-data-kafka-data
```

Global Docker prune commands are forbidden.

`cleanup` first requires the exact three Compose-labeled container names, images, no-network boundary, running health and two exact labeled volumes. It also permits only `atlas.sql`, `manifest.json` and `restore.json` beneath the ignored runtime directory. It refuses unknown or missing project members. Only after the descriptor matches does it run project-scoped Compose removal, removes those exact local artifacts and proves that the project label selects no remaining container or volume.

A minimal recovery rehearsal is:

```text
python datactl.py up
python datactl.py init
python datactl.py seed-backlog --count 6 --partition 1
python datactl.py backup
python datactl.py restore
python datactl.py replay-restore
python datactl.py cleanup
```

Read every receipt. A command returning zero is necessary but the counts, hashes, offsets, reconciliation controls and cleanup proof explain what actually succeeded.
