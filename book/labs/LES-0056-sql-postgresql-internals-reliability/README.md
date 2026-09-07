# LES-0056 local PostgreSQL evidence lab

This lab runs one ephemeral PostgreSQL 18.4 container on an internal-only Docker network. It publishes no host port, uses an OCI-pinned official image, refuses root and cloud/database credentials, stores its generated lab password only under an exact UID-scoped temporary directory, and keeps database files on container tmpfs.

From Ubuntu 24.04 run `bash lab.sh doctor`, `setup`, `status`, `plan-before`, `add-index`, `plan-after`, `lock-wait`, `deadlock`, `connections`, `backup-restore` and `cleanup`. Run `bash verify.sh` for the complete lifecycle.

Docker access is effectively host-root authority. Inspect the scripts and exact Compose project name before execution. The lab proves only this disposable topology and dataset; it does not prove production sizing, storage durability, replication, failover or learner mastery.
