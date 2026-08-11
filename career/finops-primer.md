# FinOps: optimize cost without breaking the contract

Cost is an engineering signal. A cheaper system that misses its SLO, weakens security, or creates operator toil is not an optimization; it is deferred failure.

```text
usage + rate + allocation -> cost/unit economics -> decision -> safe change -> verify SLO/cost
     |          |                 |                  |              |
 measured    source trust       owner            hypothesis       outcome
```

## Start with trustworthy semantics

Know whether a number is list price, usage, invoice, amortized commitment, forecast, or estimate. Record currency, time zone, units, discounts, shared costs, credits, and missing data. Never compare two totals until their dimensions and time windows match.

## Allocate fairly

Attribute direct cost to a service or team; allocate shared control planes, support, and platform capacity with a documented rule. Unknown or unallocated cost must stay visible. A percentage split that does not conserve the source total is not a trustworthy report.

## Unit economics and SLO safety

Choose a useful unit such as cost per successful checkout, build, request, or GB processed. Optimize waste first: idle capacity, overprovisioning, storage retention, excessive telemetry, and unnecessary data transfer. Test each change against latency, availability, recovery, security, and operator effort.

## Commitments and reversibility

Reservations or commitments trade flexibility for lower rates. Verify utilization, ownership, term, exit risk, and demand confidence before buying. Prefer reversible experiments and staged rightsizing; never reduce redundancy solely because a monthly graph looks high.

## Safe local exercise

Use a synthetic CSV of usage, rates, tags, and shared costs. Normalize units, calculate totals and cost per successful operation, reconcile allocated totals to source, and flag unknowns. Model one rightsizing change with an SLO guard and rollback threshold. Use no provider billing data.

## Triage sequence

1. Confirm source, period, currency, unit, and data completeness.
2. Separate price/rate change, usage change, allocation error, and forecast error.
3. Identify the user/SLO and security constraints before proposing savings.
4. Choose a bounded reversible action and expected evidence.
5. Verify realized cost, service health, capacity headroom, and operator load.

## Interview defense

**Question:** “How would you reduce cloud cost by 20%?”

**Strong answer:** “First I establish trustworthy spend and unit economics, then identify idle or overprovisioned capacity, retention and transfer waste, and commitment opportunities. Each change has an SLO/security/capacity guard, owner, rollback, and realized-savings verification. I do not promise a percentage before seeing the data.”

**Question:** “Why can chargeback damage engineering?”

**Strong answer:** “Poor allocation can penalize teams for shared or unknown cost and encourage unsafe capacity cuts. I publish allocation semantics, keep unallocated spend visible, pair cost with reliability and usage units, and review incentives with platform and product owners.”

## Teach-back checkpoint

Design one cost report. State the source and units, allocation rule, unit metric, unknown treatment, SLO guard, reversible change, and evidence proving savings did not move risk elsewhere.
