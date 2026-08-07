# LES-0090 draft status

Status: **source-locked implementation-active quarantined capstone; relay/consumer/analytics/recovery, assessments, manuscript, review and publication pending**

This quarantined directory reserves `LES-0090` / `V11-L03` / `CAP-003` for the distributed data reliability capstone. Its working route is `/book/capstones/distributed-data-reliability-capstone`, volume `11-capstones`, order 3 and domain `capstone-engineering`.

The planned local product follows one order from a transactional API through an atomic outbox, retained event log, idempotent materialization, disposable cache, analytical batch/replay output, data-quality gates, lineage receipts, SLO/capacity evidence and state-class recovery. It must make duplicates, poison records, backlog, partition skew, consumer crash windows, stale cache, schema incompatibility and restore/replay boundaries observable.

The twenty-record primary/official source lock passes the direct reference schema. The first implementation checkpoint pins PostgreSQL 18.4, Redis 8.6.5 and Apache Kafka 4.3.1 by observed Linux/amd64 repository digest. Compose validation passes. All three fixed-name services reached healthy with `network=none`, no host ports and declared CPU/memory ceilings.

Five Python contract tests pass. One synthetic order created one PostgreSQL order and one atomic outbox row. An identical retry returned the same order/event identities with `replayed=true`. The same idempotency key with a changed amount raised `idempotency_conflict` and left counts at one order/one event. Descriptor-gated cleanup removed exactly three containers and two labeled volumes, and independent label queries returned no remainder.

Two corrected failures are retained: Redis initially exited because a root entrypoint could not change tmpfs ownership after capabilities were dropped, so the verified image UID/GID is now explicit; the first PostgreSQL function called a nonexistent `jsonb_object_length`, so it now counts `jsonb_object_keys` and the failed statement is known to have created no order/outbox state.

Relay publication, crash-window duplication, idempotent consumption, offset/effect ownership, Redis cache convergence, poison quarantine, backlog/skew, analytical quality/lineage, backup/restore/replay, full verifier, assessments and manuscript remain unimplemented. No production environment, cloud account, real credential/data, accepted SLO/RPO/RTO, learner result or mastery is claimed.

Publication remains blocked by the complete source lock, guarded project, three assessments, exact-structure manuscript, direct and canonical gates, representative local failure/recovery evidence, formal multidisciplinary review and reviewer-owned independent transfer.
