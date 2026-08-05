# LES-0056 draft status

Status: **quarantined substantive candidate - not canonical, accepted, or mastery evidence**

The candidate contains one H1 and the exact 18-section structure, six diagrams, twelve command contracts, two labs, five incidents, three assessments and fifteen current primary or official references. It teaches relational contracts, SQL, plans, indexes, MVCC, isolation, locks, deadlocks, pools, vacuum, WAL, replication, backup, restore, security, observability, capacity, cost and production incident reasoning.

The bounded lab uses one OCI-pinned PostgreSQL 18.4 official image on an internal-only Compose network with no host port or durable volume. It refuses root, credential-bearing environments and unsafe state; creates only an exact UID-scoped project and temporary root; models a plan change, lock wait, deadlock, ordinary-slot exhaustion and logical restore; and requires exact cleanup.

The lab does not represent production data, traffic, hardware, persistence, TLS, a pooler, standby, archive, failover or point-in-time recovery. A logical dump plus count checks is not full business or RTO proof. Docker access is privileged host authority. Formal review, publication, reviewer transfer, delayed recall and learner evidence remain required.
