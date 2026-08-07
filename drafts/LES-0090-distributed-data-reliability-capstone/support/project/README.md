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

Implemented commands are `check`, `up`, `init`, `submit`, `relay`, `consume`, `status` and `cleanup`. Batch, reconcile, fault, backup and restore remain planned and must not be represented as complete until their verifier passes.

`relay --stop-after-publish` deliberately exits 75 after Kafka acknowledges the event but before PostgreSQL marks the outbox row published. Retrying `relay` publishes the same stable event identity again. This models the unavoidable dual-write ambiguity and creates input for the idempotent-consumer stage; it does not claim Kafka transaction or exactly-once effect semantics.

The first retry did commit the outbox acknowledgement, but `psql` appended the `UPDATE 1` command tag to the returned event ID. The client correctly refused the unexpected two-line ownership receipt. Machine-facing PostgreSQL calls now use quiet tuples-only output so the receipt contains only the requested value.

`consume` performs a bounded read from the beginning of the local topic. Every record must expose partition, offset, key and a matching payload event ID. PostgreSQL records every first-seen delivery position but creates the inbox/business effect once per event ID and payload hash. Redis is updated only after that transaction and can be rebuilt by replay. This fixture deliberately avoids the phrase “exactly-once delivery”: Kafka contains duplicates while the effect is idempotent.

Cleanup will remove only these fixed containers and volumes:

```text
atlas-data-postgres
atlas-data-redis
atlas-data-kafka
atlas-data-postgres-data
atlas-data-kafka-data
```

Global Docker prune commands are forbidden.

`cleanup` first requires the exact three Compose-labeled container names, images, no-network boundary, running health and two exact labeled volumes. It refuses unknown or missing project members. Only after the descriptor matches does it run project-scoped Compose removal and prove that the project label selects no remaining container or volume.
