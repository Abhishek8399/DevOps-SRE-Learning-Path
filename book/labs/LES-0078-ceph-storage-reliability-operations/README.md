# Guarded Ceph evidence model

This normal-user Ubuntu lab evaluates a finite synthetic Ceph request, placement, durability, recovery and client-outcome path. It does not install or invoke Ceph, read a keyring, contact a monitor, create a pool or object, change CRUSH/OSD state, perform I/O, inject failure, repair data or upgrade anything.

Run `bash lab.sh doctor`, `bash lab.sh inventory-tools`, `bash lab.sh setup`, `bash lab.sh status`, `bash lab.sh show baseline` and `bash lab.sh evaluate baseline`. Compare `stale-client-map`, `crush-correlated-domain`, `active-degraded`, `fullest-osd-at-full-ratio` and `clean-user-slo-failed`. Run `bash verify.sh` from absent state for all 56 decisions, refusal and cleanup.

The only mutation is `/tmp/reliability-atlas-les0078-ceph-<uid>` with a sentinel and copied JSON fixture. Cleanup removes only exact allowlisted files. Unknown artifacts cause refusal until the verifier deliberately removes its own test artifact.

`operable-within-model` means all encoded Boolean predicates pass. It proves no cluster, storage medium, durability, performance, recovery or user behavior.
