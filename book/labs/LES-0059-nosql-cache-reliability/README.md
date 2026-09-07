# LES-0059 offline data and cache boundary model

This deterministic model reviews declared architecture conditions. It is not Redis, Valkey, Memcached, MongoDB, Cassandra, DynamoDB, a database benchmark, a cache, a network, a serializer, a persistence engine, or a consistency checker. It opens no socket and creates no external resource.

From Ubuntu 24.04 as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate baseline
bash lab.sh evaluate hot-key
bash verify.sh
```

The wrapper uses one exact UID-scoped directory under `/tmp`. It refuses root, credential hints, symlinks, wrong ownership, unexpected entries, unsupported OS versions, and pre-existing state. The verifier covers every decision branch, refusal, and exact cleanup.
