# Service-level objectives and alert contract

## User operations

The service has two user journeys: list items and create one item exactly once under a repeated idempotency key. Health and metrics endpoints are operator operations; they are not counted as successful user requests.

## Candidate objectives

| SLI | Candidate objective | Measurement |
|---|---|---|
| request availability | 99% of valid user requests return an intended 2xx/4xx result | good events divided by valid events over 30 rolling days |
| request latency | 95% of valid user requests finish within 250 ms | histogram per route over 30 rolling days |
| create correctness | a repeated key plus identical body returns one item; changed body conflicts | transaction and independent reconciliation |
| recoverability | latest eligible backup restores to a separate ready database within the declared exercise RTO | timed restore drill plus integrity and count checks |

A validation error caused by the caller is not an availability failure. A storage 503, proxy 502/504, connection failure or deadline breach is. A 200 response with the wrong item is a correctness failure even if availability and latency look healthy.

## Error-budget calculation

For a request-based 99% objective:

```text
error budget ratio = 1 - 0.99 = 0.01
allowed bad events at 1,000,000 eligible requests = 1,000,000 * 0.01 = 10,000
observed failure ratio = bad events / eligible events
burn rate = observed failure ratio / 0.01
```

A burn rate of 1 consumes budget at exactly the planned rate. A burn rate of 14.4 sustained for one hour consumes roughly 2% of a 30-day budget:

```text
14.4 * (1 hour / 720 hours) = 0.02
```

The local `ops/slo.py` calculation uses a bounded sample, not a 30-day production window. It demonstrates arithmetic and detects the deterministic latency fault; it cannot validate the target or represent real traffic.

## Alert policy

- Page only on fast, material user-visible budget consumption.
- Ticket on sustained readiness or latency risk that still allows a safe response window.
- Use internal CPU, locks, disk and container metrics for diagnosis, not duplicate symptom pages.
- Monitor the monitoring path; a missing scrape is not evidence that the service is healthy.
- Every alert links to an action and a stopping condition.

Prometheus evaluates the included rules. No Alertmanager or receiver is configured, so this capstone does not claim notification delivery.

## Review questions

Before adopting these numbers, ask what users actually need, how eligible events are defined, whether low traffic distorts rates, how planned maintenance is handled, whether correctness is independently measured, and what action the error budget changes. A convenient metric is not automatically a useful SLI.
