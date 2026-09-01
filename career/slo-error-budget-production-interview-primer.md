# SLO and error-budget production interview: measure the user promise before the dashboard

An SLO is not a percentage decoration. It is an explicit reliability promise about a user journey, a valid population, a measurement method, and a decision that changes when the promise is at risk.

```text
user journey -> valid events -> indicator -> objective/window -> error budget -> engineering decision
      |              |             |              |                  |                |
   customer       coverage       good/total       target/time       remaining       release/repair
```

## Scenario 1: a service reports 99.99% availability while users cannot finish checkout

**Question:** The service-level dashboard is green, but customers see checkout failures. What is wrong with the SLO?

**Strong answer:** I first ask what customer operation the indicator represents. A process, endpoint, or infrastructure availability metric can be healthy while DNS, TLS, identity, payment, inventory, queue, or browser flow fails. I define the journey boundary, valid attempts, successful outcome, exclusions, ownership, time window, and instrumentation coverage. Then I compare the SLI with a scoped user-path probe and failure evidence.

I do not simply add every dependency error to one number; that can make the indicator impossible to interpret. I create a journey-level objective where customer completion is the intended promise and retain component indicators for diagnosis. The release/incident policy must say what happens when coverage is missing or the journey SLI degrades.

**Weak answer:** "Increase the target to 99.999%." A more precise percentage cannot fix an indicator that measures the wrong outcome.

**Senior follow-up:** What does a successful synthetic check prove? That its designed path, location, identity, and timing succeeded. It does not prove every user segment, client behavior, or dependency population.

## Scenario 2: the error budget burns quickly after a small release

**Question:** A canary release uses only 2% traffic, but consumes a large fraction of the monthly error budget. What do you do?

**Strong answer:** I stop expansion and verify the arithmetic before deciding. I establish the SLI numerator/denominator, traffic share, error classification, time window, baseline, confidence/volume, and whether the canary population differs from normal traffic. A small cohort can reveal a severe regression, but low traffic can also make a percentage noisy.

I apply the predeclared release gate: pause, roll back, or contain based on burn rate, absolute bad events, customer impact, and reversibility. I do not wait for the monthly objective to be fully exhausted if a short-window burn shows that continuation predicts breach. Recovery is verified through the affected user journey and stable error/burn evidence, not merely a successful rollback job.

**Weak answer:** "Two percent cannot matter." Customer harm and projected budget consumption are not proportional to a comforting traffic label.

**Senior follow-up:** Why use multiple burn windows? A short window detects acute harm quickly; a longer window reduces noise and shows sustained degradation. Neither replaces judgment about impact and sample size.

## Scenario 3: traffic is low, so one error appears catastrophic

**Question:** A critical internal service receives only a few requests overnight. One failure makes its availability SLI collapse. How do you design an alert?

**Strong answer:** I separate the objective from paging policy. The event is real and may matter greatly, but a percentage based on one request has weak statistical stability. I define whether every request is critical, add an absolute bad-event condition or synthetic/transactional coverage where safe, and use a window/threshold that detects meaningful risk without teaching responders to ignore pages.

I make the denominator and coverage visible. Suppressing low traffic entirely can hide a service that never receives a real request; treating every single failure as a full outage can create noise. The alert route, severity, runbook, owner, and expected response should match the actual user/operational risk.

**Weak answer:** "Ignore alerts below 100 requests." Low volume does not make a payment, backup, compliance, or control-plane operation unimportant.

**Senior follow-up:** What is the proof limit of a low-traffic availability percentage? It describes the observed small sample, not the reliability of all possible future demand or unobserved paths.

## Scenario 4: missing telemetry makes the SLI look healthy

**Question:** A logging/metrics pipeline drops events during an outage. The error rate falls because failures are no longer measured. What controls do you need?

**Strong answer:** I treat observability coverage as part of the reliability system. I monitor event volume, ingestion delay, cardinality/drop behavior, source health, sampling, clock/order assumptions, and comparison with independent signals such as edge status, synthetic checks, traces, or dependency metrics. A missing denominator can create false green, so the SLO policy must define whether unknown coverage freezes release, creates a distinct alert, or marks the SLI invalid.

I do not silently replace missing values with success or zero error. The dashboard should distinguish "good," "bad," and "not measured." I restore measurement through a bounded operational path, then assess the unobserved interval with honest uncertainty rather than inventing a clean history.

**Weak answer:** "The metric says zero errors, so close the incident." Zero observed errors can mean zero observation.

**Senior follow-up:** Can redundant telemetry prove full coverage? It reduces a single blind spot, but each signal has collection, identity, sampling, and path limits. State those limits explicitly.

## Scenario 5: error budget policy blocks every feature release

**Question:** A product team says the SRE team uses the error budget as a veto. How do you make the policy useful rather than adversarial?

**Strong answer:** The budget is a shared risk-allocation mechanism, not an SRE scorecard. I make the objective, error classes, ownership, review cadence, and policy visible before an incident. The policy distinguishes normal release, increased caution, freeze/repair priority, emergency change, and exception path. It also recognizes that reliability work, product work, security remediation, and customer obligations compete for finite capacity.

When the budget is low, I recommend bounded options: smaller canary, reversible feature flag, targeted reliability fix, reduced scope, delayed noncritical launch, or an owned exception with risk, authority, expiry, compensating controls, and follow-up. I measure whether the policy improves customer reliability and delivery predictability, not whether it produces more blocked tickets.

**Weak answer:** "The budget is zero, so no changes." Some changes are required to restore reliability or address security; policy needs safe exception and recovery paths.

**Senior follow-up:** Who owns the SLO? The service/product owners own the customer promise and trade-offs with the reliability partners; one team should not unilaterally redefine the user's acceptable harm.

## Scenario 6: the team wants to declare an SLO met after recovery

**Question:** An incident is fixed, but the reporting window still includes its errors. Can the team mark the SLO green again?

**Strong answer:** I preserve the measurement truth. Recovery means the current user path is healthy; it does not erase observed bad events from the agreed window. I report both: present operational state and remaining budget/window result. If the measurement was invalid due to a defined instrumentation failure, I follow the predeclared invalid-data policy and document the decision; I do not rewrite history because the result is inconvenient.

I use the incident to check whether the objective, alert, runbook, capacity, dependency contract, or release gate needs improvement. The aim is not a permanently green chart; it is a trustworthy decision system that makes customer harm visible and guides the next safe action.

**Weak answer:** "Reset the dashboard after the fix." That removes the information used to judge trend, budget, and effectiveness.

**Senior follow-up:** When may an SLO definition change? Through a reviewed, versioned decision that explains the old/new contract, migration/continuity, owner, and effect on historical interpretation—not during an incident to improve a number.

## Fast decision map

| Signal | Remember | First safe move |
|---|---|---|
| green component, failed customers | Availability is not the user journey | Define the journey SLI and trace its missing boundary |
| rapid canary burn | Budget is a release signal | Pause expansion; check projected burn and impact |
| low traffic percentage spike | Objective and page policy differ | Use absolute events, safe coverage, and stated risk |
| telemetry disappears | Unknown is not good | Mark coverage invalid and use independent evidence |
| delivery conflict | Budget is shared risk allocation | Offer bounded release/repair/exception choices |
| recovery complete | Current health is not erased history | Report current state and retained window truth separately |

## Practice

For any SLO answer, name the user journey, valid population, good/bad definition, coverage proof limit, budget decision, and exception owner. If you cannot name those, you have a metric—not yet a reliability objective.
