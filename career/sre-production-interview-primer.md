# SRE production interview: turn user harm into an evidence-led recovery decision

Site Reliability Engineering is not “watch dashboards and restart things.” It is the discipline of making reliability promises explicit, detecting meaningful risk, reducing customer harm safely, and learning enough to prevent recurrence.

```text
user journey -> SLI evidence -> SLO/error-budget policy -> alert/incident -> containment -> recovery -> learning
      |              |                   |                    |                |              |
 population       quality               decision             authority      verification     prevention
```

The key habit: every metric, alert and change has a proof boundary. A green chart proves something about its query and data; it never proves every user is healthy.

## Scenario 1: the alert is noisy but a real outage is possible

**Question:** An alert fires repeatedly, teams mute it, and one day it coincides with a customer outage. How do you repair the system without simply lowering sensitivity?

**Strong answer:** I reconstruct the alert’s intended user risk, query population, window, threshold, data completeness, routing, owner and historical outcomes. I compare firing events with customer impact, incident timelines and healthy controls. Noise can arise from a poorly chosen SLI, missing denominator, short window, expected maintenance, aggregation hiding a subset, telemetry loss or an unowned dependency. I do not mute first and call it solved. I create a policy that distinguishes page-worthy burn/impact from ticket/investigation signals, adds inhibition/deduplication only when it preserves meaningful risk, and tests the alert against historical or synthetic cases. Recovery is not “fewer pages”; it is the right owner receiving actionable evidence in time to protect users. Prevention includes alert review cadence, ownership, runbooks and telemetry-health monitoring.

**Weak answer:** "Raise the threshold." That can turn alert fatigue into silent customer harm.

**Senior follow-up:** What makes an alert actionable? A named owner can understand the affected user/service boundary, take a safe decision, and verify a useful outcome within the required response time.

## Scenario 2: a service is within SLO but customers complain

**Question:** The monthly availability SLO is met, yet an important customer journey fails for a subset of users. What do you challenge?

**Strong answer:** I challenge the SLI contract before discounting the report. I define the journey, population, success event, excluded traffic, region/tenant/device path, time window and data pipeline. The SLO may aggregate away a critical subset, treat missing telemetry as success, use an unrepresentative availability proxy, or have a window too broad for urgent harm. I compare black-box journey evidence with service/dependency/client telemetry and establish a healthy control. I contain the affected path based on evidence, then amend the SLI/alert/objective policy with owners and review. A met SLO is not an excuse to ignore a valid customer outcome; it is evidence that the existing measurement contract is incomplete for that risk.

**Weak answer:** "The SLO is green, so the issue is outside SRE." SLOs are product agreements that need correction when they fail to represent important user value.

**Senior follow-up:** When should one customer get a separate SLO? When their contractual or architectural journey is materially distinct and the business has agreed to own/operate that promise, not merely because they are loud.

## Scenario 3: retries amplify a dependency slowdown

**Question:** A dependency slows down. Errors rise, every caller retries, and load grows. Lead the recovery.

**Strong answer:** I quantify the original request rate, timeout, retry count/distribution, deadline budget, queue depth, dependency capacity and customer operation. Retries are additional load; a retry multiplier can turn a partial dependency slowdown into a wider outage. I preserve a timeline and identify whether requests are idempotent and whether any retry is still useful before deadline expiry. I contain with bounded timeouts, retry budgets, exponential backoff plus jitter, concurrency/admission limits, circuit behavior, queue shedding or graceful degradation according to the service contract. I avoid an unbounded global retry disable without understanding critical flows. Recovery is reduced customer harm, normal dependency saturation and controlled queue/backlog, not merely a lower error chart. Prevention is owned client policy, load/failure tests, idempotency design and multi-layer retry coordination.

**Weak answer:** "Add more retries for reliability." More retries can consume the exact capacity needed for recovery.

**Senior follow-up:** Why do timeouts matter before retries? A retry after the caller’s useful deadline can create work that cannot help the user while adding load and ambiguous side effects.

## Scenario 4: capacity looks fine until the queue grows

**Question:** CPU and memory dashboards are calm, but queue age and user latency increase. What is your capacity model?

**Strong answer:** CPU and memory are resources, not universal service capacity. I map arrival rate, service-time distribution, concurrency, queue length/age, dependency throughput, error/retry rate and the user latency objective. If arrivals exceed effective completion rate, a queue can grow even while a host appears underutilized because the constrained boundary may be a database lock, remote API, disk, connection pool, partition, serial worker or admission policy. I compare current values with baseline and planned headroom, then contain by reducing input, increasing only the proven bottleneck, prioritizing critical work or shedding safely. Recovery includes draining backlog at a safe rate and confirming no hidden data/integrity loss. Prevention is capacity testing with realistic request cost/variance, queue SLOs, dependency limits, forecast and a documented overload policy.

**Weak answer:** "Scale the workers." More workers can overload a serial downstream dependency and make queue latency worse.

**Senior follow-up:** What does a queue age SLI add beyond queue depth? Age expresses how long real work waits; a small queue with one very old critical item and a large queue of fresh bulk work can have different user risk.

## Scenario 5: incident commander needs a decision with incomplete evidence

**Question:** During an incident, two senior engineers disagree: one wants failover, the other wants to roll back a release. How do you lead?

**Strong answer:** I state customer impact, time pressure, decision authority, known facts, competing hypotheses, evidence gaps and irreversible risks. I ask each proposal to name the mechanism it addresses, expected benefit, blast radius, rollback/fencing requirement, time to execute and verification. I select the smallest reversible action that reduces the most likely customer harm while preserving options, or escalate to the named decider if authority is missing. I maintain an incident timeline and communication cadence without turning the call into a debate club. A failover can create data consistency/split-brain risk; a rollback can be incompatible with a migration or unrelated to a regional dependency. Recovery is verified by the affected journey and system/data checks. Afterward, the post-incident review should improve evidence, authority/runbooks and design—not assign blame for reasonable uncertainty.

**Weak answer:** "Let the loudest senior engineer decide." Expertise matters, but incident decisions need explicit authority, evidence and recorded trade-offs.

**Senior follow-up:** What do you tell executives? Impact, scope, current containment, decision/owner, known/unknown facts, customer guidance and the next update time—without invented root cause or recovery promise.

## Scenario 6: backup exists but recovery objective is missed

**Question:** A restore technically succeeds, but it takes longer than the declared RTO and loses more data than the stated RPO. Is disaster recovery (DR) working?

**Strong answer:** No. A successful restore step is useful evidence, but DR is a tested ability to recover the agreed service and data boundary within agreed objectives. I define the authoritative data, backup point, consistency model, restore target, identity/key/dependency prerequisites, DNS/traffic cutover, capacity, operator runbook and measurement start/end. I measure achieved RPO and RTO against the contract, document gaps and prioritize the narrowest limiting boundary. I do not claim recovery because storage objects exist or a database starts. Prevention may include more frequent/consistent backups, automated/parallel restore stages, pre-provisioned recovery capacity, runbook drills, dependency mapping and a business-approved revision of unrealistic objectives.

**Weak answer:** "The restore command returned zero, so DR passed." A command exit status does not prove data completeness, application consistency, user journey, time objective or operational readiness.

**Senior follow-up:** Why must DR be exercised separately from a live incident? An incident is an uncontrolled, high-pressure event. A deliberate exercise can measure objectives, expose assumptions and improve the runbook without adding avoidable customer harm.

## Your SRE answer card

| If asked about… | Start by naming… | End by proving… |
|---|---|---|
| Alerting | user risk, query/window/data/owner | right action reaches right owner in time |
| SLO | population, success event, exclusions | journey outcome and policy decision are meaningful |
| Incident | impact, authority, hypotheses, options | scoped user recovery and prevention ownership |
| Capacity | arrival, completion, queue/latency, bottleneck | sustained safe throughput and backlog recovery |
| Resilience | deadline, retry/idempotency, isolation | reduced amplification and controlled degradation |
| DR | authoritative state, RPO/RTO, dependencies | tested service/data recovery within contract |

## Practice transfer

Choose an answer and remove one dashboard from the story. Explain what you would observe next and why. Then change a constraint: a paid customer, a data-writing operation, regional partial failure, a missing telemetry pipeline, or an on-call engineer with no deploy authority. Senior SRE reasoning survives missing signals because it makes uncertainty and authority visible.
