# Resilience: survive pressure without amplifying it

Resilience is the ability to keep the most important user outcomes within an acceptable contract while parts of the system are slow, unavailable, or overloaded.

```text
traffic -> admission -> bounded work -> dependency -> response
            |             |               |
         reject early   queue limit    timeout/bulkhead
```

## Capacity is a relationship

Capacity is not a single CPU percentage. It is the relationship between arrival rate, service time, concurrency, queueing, dependency limits, and the user’s latency objective. Find the performance knee where small demand increases cause disproportionate queue growth. Scale before that knee, and verify the bottleneck moved rather than merely shifting downstream.

## Timeouts, retries, and deadlines

Every request should have a deadline that is shorter than the caller’s patience. A timeout without cancellation leaves work running. Retries multiply traffic; bound attempts, add jitter, carry the original deadline, and retry only safe or idempotent operations. A retry budget protects a struggling dependency from a feedback loop.

## Bulkheads and graceful degradation

Separate pools for tenants, endpoints, or dependencies prevent one failure from consuming every thread and connection. Degrade optional features explicitly: serve cached recommendations, disable expensive enrichment, or return a pending state. Never silently return false success when the user needs to know that work is incomplete.

## Load shedding and backpressure

Rejecting work early with a clear response can preserve the core journey. Bound queues by memory, age, or work count; alert on oldest work and drain time. A queue that accepts everything can convert a brief overload into a long outage.

## Safe local exercise

Use a small local HTTP service and a client with a fixed concurrency limit. Add an artificial delay, then compare unbounded retries with bounded deadlines and jitter. Record request rate at the dependency, queue age, completion rate, and user-visible latency. Restore the original fixture and remove generated data.

## Triage sequence

1. Identify the failing journey and the first saturated boundary.
2. Measure arrival rate, service time, concurrency, queue age, timeouts, retries, and dependency capacity.
3. Stop amplification: disable unsafe retries, shed optional work, and bound admission.
4. Protect the dependency with bulkheads, circuit state, or a lower concurrency ceiling.
5. Restore gradually and verify backlog drain, freshness, and user success.

## Interview defense

**Question:** “Why did adding retries make the outage worse?”

**Strong answer:** “Each timed-out request created more work, so arrival rate exceeded service capacity and the dependency spent resources on doomed attempts. I would propagate deadlines, use bounded jittered retries only where safe, add a retry budget, and protect the dependency with admission and bulkheads.”

**Question:** “How do you choose autoscaling signals?”

**Strong answer:** “Use a signal close to the user objective—queue age, work latency, or concurrency—alongside resource saturation and downstream limits. Validate scale-up delay, cooldown, oscillation, and cost, then test the performance knee rather than assuming CPU predicts service capacity.”

## Teach-back checkpoint

Draw a request path and mark the deadline, queue limit, bulkhead, retry budget, degradation point, and recovery signal. Explain what happens when the dependency is slow but not fully down.
