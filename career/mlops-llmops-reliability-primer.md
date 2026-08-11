# MLOps and LLMOps reliability: operate the whole decision pipeline

An ML service is not reliable because a model has a good score. Reliability includes data freshness, feature and training lineage, evaluation validity, serving latency, safety policy, cost, and the ability to stop or revert a bad decision.

```text
source -> data/feature contract -> train/evaluate -> registry
  |             |                      |              |
quality      freshness             reproducibility   approval
                                                        v
                         gateway -> canary -> serving -> user outcome
                            |          |          |          |
                       policy/cost   SLI      drift      feedback
```

## Make artifacts and authority explicit

Version the source snapshot, schema, transformation code, features, model, tokenizer, prompt/retrieval settings, policy, container, runtime, evaluation set, and deployment configuration. A registry alias such as “production” needs an owner, approval record, immutable target, and rollback or forward-repair procedure. Rebuilding from “latest data” is not reproducibility.

For LLM systems, add prompt templates, retrieved documents or index version, safety policy, tool permissions, token limits, and model/provider identity. Never send sensitive training or prompt data to an unapproved service just to improve a demo.

## Evaluate what users actually experience

Separate offline quality from production indicators. Offline evaluation can test accuracy, ranking, safety, and regression sets; production must also measure correctness proxies, error rate, latency (including time-to-first-token and time-per-token), queue age, fallback rate, token usage, and cost per successful outcome. Delayed labels and feedback loops make “no incidents yet” weak evidence.

## Serving and resource economics

Batch, online, asynchronous, and streaming paths have different deadlines and retry behavior. Admission control should bound request size, concurrency, tokens, GPU memory, and tenant budget. Batching and caching can improve throughput but may increase tail latency, staleness, privacy exposure, or fairness problems. A GPU shortage is a capacity incident; queueing and backpressure are part of the service contract.

## Safe local exercise

Build a tiny model-service simulator using a deterministic function or stub. Give each request a model version, prompt/config hash, latency, token estimate, and outcome label. Introduce a bad candidate that increases latency or returns an invalid result. Route a deterministic cohort, apply an abort threshold, and record the artifact, evaluation evidence, rollback limitation, and cost delta. If no model runtime or GPU exists, keep it a simulator and say exactly what remains unproven.

## Triage sequence

1. Identify the user outcome, model/config/prompt/retrieval versions, tenant, and request class.
2. Separate data/feature freshness, evaluator/regression, gateway admission, queue/resource, serving, and dependency failures.
3. Freeze promotion or reduce exposure; preserve the exact manifests and representative inputs safely.
4. Roll back an immutable alias or roll forward with reconciliation when state or feedback cannot be undone.
5. Verify quality, latency, safety, privacy, and unit economics—not only process health.

## Interview defense

**Question:** “What makes an ML platform production-ready?”

**Strong answer:** “It has immutable lineage from data through model and runtime, representative evaluation with a promotion owner, versioned serving and policy contracts, bounded admission and resource budgets, user-outcome SLIs, drift and delayed-label handling, privacy controls, canary/rollback or forward-repair, and a tested recovery path. A high offline metric alone is not readiness.”

**Question:** “How would you control GPU cost?”

**Strong answer:** “Measure cost per successful outcome and queue/latency by tenant, then improve utilization with appropriate batching, caching, quantization or model choice only after correctness and tail-latency baselines. Keep admission limits, fairness, headroom, and a rollback threshold; cheaper wrong answers are not savings.”

**Question:** “Why did the model canary look healthy but users complained?”

**Strong answer:** “The sampled metric may not represent the affected cohort or delayed quality dimension. I compare request mix, retrieval/prompt/config versions, safety and correctness signals, fallback behavior, latency, and feedback, then freeze exposure and preserve the exact candidate inputs for analysis.”

## Teach-back checkpoint

Design a multi-tenant model gateway. Name the immutable artifacts, evaluation gates, admission limits, GPU/CPU signals, user SLIs, privacy boundary, canary cohort, abort owner, rollback limitation, and evidence needed before calling the release safe.
