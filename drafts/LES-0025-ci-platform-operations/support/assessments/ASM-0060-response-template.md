# ASM-0060 independent response template

This is a blank evidence structure, not an answer key. It contains no provider verdict, queue diagnosis, recovery choice, platform recommendation, or model solution. A qualified reviewer scores original work against `ASM-0060.json`.

## Independence and authorization gate

- Attempt time and timezone:
- Attempt identifier:
- Prior LES-0025 sections, answered assessments, examples, help, or other learner responses seen:
- Help received after starting:
- Chosen pipeline or illustrative definition:
- Why I am authorized to inspect it:
- Real provider execution / reviewed definition only / no execution:
- Sensitive material sanitized, if any:
- I did not read `ASM-0058.json` or `ASM-0059.json` after this gate: yes / no
- If no, reviewer decision on whether this attempt remains independent:

| Environment field | Evidence |
|---|---|
| Ubuntu version and native or WSL boundary | |
| Effective user and groups | |
| Physical repository path or not applicable | |
| Local tools used | |
| External network boundary | |
| Privilege boundary | |
| Files or state expected before work | |
| Abort conditions | |
| Before-state evidence | |
| Expected after state | |

## Blocked gate, if applicable

Exact blocker:

```text

```

Why I stopped without installing, elevating, authenticating, contacting a service, weakening a control, or changing the source material:

## Scope and unknowns

| Field | Exact non-sensitive value or unknown | Source | Proof limit |
|---|---|---|---|
| provider or illustrative definition | | | |
| organization, instance, project, repository or folder scope | | | |
| event type and trust class | | | |
| source revision | | | |
| pipeline entry identity | | | |
| resolved reusable dependency identities | | | |
| provider execution evidence | | | |
| authorization boundary | | | |

Unknowns I will not infer:

## First predictions before derived investigation

- Timestamp:
- Initial system boundary:
- Initial state owner:
- Minimum next observation:
- Observation that would disconfirm the first hypothesis:

| Hypothesis | Predicted evidence | Disconfirming evidence | State owner | Read-only check | Mutation or privacy risk | Status |
|---|---|---|---|---|---|---|
| H1 | | | | | | untested |
| H2 | | | | | | untested |
| H3 | | | | | | untested |
| H4, optional | | | | | | untested |

## Architecture map

```text

```

Text alternative:

## State ownership and identity map

| Identity or state | Exact value | Owner | Mutable? | Persists across attempt? | What it identifies | What it does not identify |
|---|---|---|---|---|---|---|
| event and actor trust | | | | | | |
| full source revision | | | | | | |
| pipeline entry revision | | | | | | |
| reusable dependency identity | | | | | | |
| logical run | | | | | | |
| run attempt | | | | | | |
| job and attempt | | | | | | |
| worker, agent and image | | | | | | |
| executor or runtime | | | | | | |
| workspace and process boundary | | | | | | |
| provider permission profile | | | | | | |
| external identity subject | | | | | | |
| cache key, object and source | | | | | | |
| artifact digest and receipt | | | | | | |
| environment policy decision | | | | | | |
| target operation | | | | | | |
| runtime revision | | | | | | |
| user operation | | | | | | |

## Portability contracts

### Build job

| Contract field | Intended behavior | Evidence | Unknown or semantic risk |
|---|---|---|---|
| event and trust | | | |
| source | | | |
| resolved configuration | | | |
| graph dependencies and conditions | | | |
| scope, trust pool and selectors | | | |
| image and toolchain | | | |
| shell and failure behavior | | | |
| effective authority | | | |
| inputs and cache | | | |
| artifact and other outputs | | | |
| timeout | | | |
| retry | | | |
| cancellation | | | |
| concurrency | | | |
| environment or external effect | | | |
| evidence and user relevance | | | |

### Test job

| Contract field | Intended behavior | Evidence | Unknown or semantic risk |
|---|---|---|---|
| event and trust | | | |
| source | | | |
| resolved configuration | | | |
| graph dependencies and conditions | | | |
| scope, trust pool and selectors | | | |
| image and toolchain | | | |
| shell and failure behavior | | | |
| effective authority | | | |
| inputs and cache | | | |
| artifact and other outputs | | | |
| timeout | | | |
| retry | | | |
| cancellation | | | |
| concurrency | | | |
| environment or external effect | | | |
| evidence and user relevance | | | |

## Four-provider mapping

| Mechanism | GitHub Actions | GitLab CI/CD | Jenkins | Azure Pipelines | Evidence or unknown |
|---|---|---|---|---|---|
| configuration entry | | | | | |
| reusable dependency | | | | | |
| administrative scope | | | | | |
| trust or protection | | | | | |
| selector and worker match | | | | | |
| hosted or self-hosted lifecycle | | | | | |
| effective permission path | | | | | |
| cache | | | | | |
| artifact handoff | | | | | |
| concurrency and cancellation | | | | | |
| environment or protected transition | | | | | |
| important semantic difference | | | | | |

Which rows are reviewed definitions rather than executed evidence?

## Queue incident

### Timeline and scope

| Time or window | Provider and class | Observation | Source and freshness | Unit or denominator | Proof limit |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |
| | | | | | |

### Decision branches

| Branch | Evidence read | Result | Inference | Next safest evidence |
|---|---|---|---|---|
| job not ready | | | | |
| eligible intersection empty | | | | |
| eligible but unavailable | | | | |
| assigned but bootstrap blocked | | | | |
| service time abnormal | | | | |

### Diagnosis and containment

- Current impact:
- First violated contract supported by evidence:
- Root mechanism supported by evidence:
- Contributing conditions:
- Known unknowns:
- Safe containment:
- Why containment does not weaken trust:
- Evidence that would change the diagnosis:

## Upgrade runbook

| Field | Decision and evidence |
|---|---|
| component and current inventory | |
| exact candidate identity | |
| compatibility and security review | |
| rollback, restore or roll-forward boundary | |
| isolated canary scope and authority | |
| representative success cases | |
| failure, timeout, cancellation and security cases | |
| metrics, windows and minimum samples | |
| abort thresholds | |
| drain and in-flight-work policy | |
| capacity headroom | |
| bounded rollout waves | |
| recovery proof | |
| exception owner and expiry | |

## Security review

| Boundary | Current or assumed state | Risk | Required evidence | Proposed control | Proof limit |
|---|---|---|---|---|---|
| event and code trust | | | | | |
| worker persistence and isolation | | | | | |
| provider token | | | | | |
| external workload identity | | | | | |
| local credentials and identity endpoints | | | | | |
| network and runtime sockets | | | | | |
| reusable configuration and extensions | | | | | |
| cache writers and consumers | | | | | |
| artifact publication and retrieval | | | | | |
| logs, test results and retained workspaces | | | | | |

## Reliability, observability, capacity, and cost

### Service-level card

- Service population:
- Indicator numerator:
- Indicator denominator:
- Objective and window:
- Exclusions:
- Data source:
- Collection freshness requirement:
- Missing-data behavior:
- Minimum sample:
- Owner and response:

### Telemetry and capacity

| Signal | Unit | Dimensions | Window and sample | Decision supported | Does not prove |
|---|---|---|---|---|---|
| ready arrivals | | | | | |
| ready-to-assigned latency | | | | | |
| oldest ready queue age | | | | | |
| eligible free slots | | | | | |
| provisioning and destruction | | | | | |
| service-time distribution | | | | | |
| retry and cancellation amplification | | | | | |
| artifact outcome | | | | | |
| reference workflow or user outcome | | | | | |

Autoscaling bounds and headroom:

Metric-cardinality decision:

### Cost comparison

| Cost area | Hosted model | Self-hosted model | Missing evidence |
|---|---|---|---|
| execution capacity | | | |
| storage and network | | | |
| licensing or premium features | | | |
| idle headroom | | | |
| fleet and controller engineering | | | |
| patching, backup and upgrade | | | |
| security and incidents | | | |
| developer wait and failed work | | | |

Proposed cost-per-useful-result definition:

## Migration and recovery

| Phase | Scope and authority | Evidence | Abort or rollback boundary | Completion proof |
|---|---|---|---|---|
| inventory | | | | |
| semantic equivalence design | | | | |
| shadow build and test | | | | |
| artifact comparison | | | | |
| cohort cutover | | | | |
| target-operation reconciliation | | | | |
| user verification | | | | |
| old authority retirement | | | | |

Stable logical operation identity and retry owner:

Immutable artifact handoff:

## Chronological evidence appendix

Classify each row as observation, documented contract, calculation, inference, hypothesis, or unknown.

| Time or window | Class | Source and exact identity | Command or evidence | Unit | Proves | Does not prove | Next evidence |
|---|---|---|---|---|---|---|---|
| | | | | | | | |
| | | | | | | | |
| | | | | | | | |

Before-state evidence:

```text

```

After-state evidence:

```text

```

Why the prescribed work did or did not change local state:

## Proof-limit register

| Claim not established | Why current evidence cannot establish it | Next authorized evidence, if appropriate |
|---|---|---|
| provider execution | | |
| provider syntax acceptance | | |
| selector truth | | |
| worker isolation or integrity | | |
| effective authority | | |
| cache compatibility | | |
| artifact correctness or safety | | |
| cancellation of child or external effects | | |
| target desired and observed state | | |
| user recovery | | |
| behavior after provider or plugin change | | |
| learner or professional mastery | | |

## Final self-review

- [ ] I disclosed prior exposure and recorded predictions before derived investigation.
- [ ] I stayed within authorization and did not install, elevate, authenticate, register, deploy, or inspect secrets.
- [ ] I kept event, source, configuration, run, attempt, job, worker, cache, artifact, environment, target, and user identities separate.
- [ ] I labeled reviewed definitions and did not invent provider execution.
- [ ] I used at least three falsifiable hypotheses and preserved raw evidence.
- [ ] I separated readiness, eligibility, availability, bootstrap, and service time.
- [ ] I did not weaken trust to restore availability.
- [ ] I defined exact upgrade, rollback or roll-forward, drain, abort, and recovery boundaries.
- [ ] I defined service evidence, qualified capacity, total cost, and metric freshness.
- [ ] I stated proof limits and did not claim that completion awards mastery.

Reviewer notes and decision:
