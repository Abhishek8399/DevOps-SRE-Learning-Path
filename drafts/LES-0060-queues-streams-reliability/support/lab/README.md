# LES-0060 offline queue and stream boundary model

This deterministic model evaluates declared messaging boundaries. It is not Apache Kafka, RabbitMQ, NATS, a broker, a producer, a consumer, a network, a persistence engine, a transaction coordinator, or a benchmark. It opens no socket and creates no topic, queue, stream, partition, message, offset, external effect, or external resource.

From Ubuntu 24.04 as a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate baseline
bash lab.sh evaluate effect-before-checkpoint
bash verify.sh
```

The wrapper uses one exact UID-scoped directory under `/tmp`. It refuses root, credential hints, symlinks, wrong ownership, unexpected entries, unsupported OS versions, and pre-existing state. The verifier covers every encoded decision branch, refusal, and exact cleanup.
