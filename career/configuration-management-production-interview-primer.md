# Configuration management production interview: converge deliberately, not blindly

Ansible and similar tools can make a fleet look calm while changing thousands of machines. That is useful only when the operator can answer three questions before the run: **which machines, which exact state, and what happens if only some machines get there?**

```text
approved intent -> inventory and trust boundary -> rendered inputs -> bounded batch
       |                       |                       |                 |
       v                       v                       v                 v
  reviewed change         right targets            predicted diff     service health
       \________________________ evidence and stop conditions __________________/
```

The playbook is not the authority by itself. Inventory, variable sources, credentials, host identity, service ownership, rollout limits, telemetry, and rollback decisions all participate in the change. A successful task only proves the tool received a success response; it does not automatically prove that users are safe.

## Scenario 1: the play says `changed` on every run

**Question:** A configuration play reports `changed` for every host every time it runs. The team calls that normal because the service stays up. What do you investigate?

**Strong answer:** I treat repeated change as a failed convergence claim until I understand it. First I isolate one disposable host and identify the first task that changes on the second run. I inspect whether the task is a purpose-built module, template rendering, package operation, command/shell task, timestamp, random value, generated ordering, ownership/mode, newline, or a handler notification. A shell command may succeed while making an unobservable side effect, so `changed` is not proof that desired state moved.

I make the desired state explicit, preferably with an idempotent module. If a command is genuinely needed, I define a narrow observable condition such as an expected file content, version, or service query instead of writing a broad `changed_when: true` or `changed_when: false`. I run syntax validation, check mode where the modules support it, a bounded normal run, then a second normal run. The expected evidence is `changed` on the first convergence and `ok` on the second, plus a service-level health check. I also check whether the task falsely suppresses change, because an invisible configuration change can prevent a required handler reload.

**Weak answer:** "Ignore it; Ansible is noisy." Repeated mutation can restart services, invalidate caches, create audit noise, hide real drift, and make a safe rolling change look permanently active.

**Senior follow-up:** Why is check mode not enough? It predicts behavior through each module's implementation and available facts. It may not execute a command, reach a protected dependency, or expose a later handler effect. It is a valuable proposal review, not evidence that a running service is healthy.

## Scenario 2: the rendered configuration contains the wrong secret or endpoint

**Question:** A deployment used the production database endpoint in a test environment. No host was compromised, but the playbook had the expected environment variables. How do you diagnose and prevent recurrence?

**Strong answer:** I stop the rollout and preserve the evidence needed to explain the rendered result without printing secret values. I establish the target inventory group, limit, extra variables, role defaults, role variables, group variables, host variables, inventory plugin output, environment injection, CI variables, and any included or vaulted files. Configuration management has precedence rules; "the variable exists" does not prove which definition won.

I compare the final rendered non-sensitive configuration against an environment contract: expected hostname pattern, account or subscription identity, region, tenant, port, and approved secret reference. I avoid logging credentials, tokens, whole variable dumps, or decrypted vault content. If the right value is secret, the play should generally receive a reference or short-lived identity and resolve it through an approved boundary; a masked CI log does not remove a value from process memory, task output, artifacts, backups, or stateful external systems.

The prevention is structural: a separate, reviewed inventory per environment; explicit and documented override policy; required environment identity assertions before mutation; secret references rather than plaintext; `no_log` only where it reduces exposure without hiding essential audit evidence; and a preflight that fails closed when target identity and rendered non-secret contract disagree. I add a test fixture that intentionally supplies conflicting values so the chosen precedence is visible and rejected.

**Weak answer:** "Put the production value in a lower-precedence file." That depends on people remembering precedence and does not prove the host, credentials, or rendered configuration belong to the intended environment.

**Senior follow-up:** What is the proof limit of a redacted run log? It can show the play reached a task and that redaction was attempted. It cannot prove a secret never reached a remote process, cached artifact, terminal scrollback, or unauthorized reader.

## Scenario 3: a rolling change succeeds on half the fleet and then health degrades

**Question:** A play uses `serial: 25%`. The first two batches succeed, but the third batch has elevated errors after a notified service restart. Operators want to continue because most hosts are already updated. What do you do?

**Strong answer:** I stop expansion immediately; partial rollout is a state to understand, not an argument to continue. I name the batch membership, service capacity, customer impact, configuration version, task and handler sequence, and the health signal that crossed its threshold. A handler often runs at the end of a play or batch, so I confirm whether the configuration was written but not activated, activated on some hosts only, or combined with another deployment.

I use the smallest safe blast radius: preserve the successful and failing batch evidence, remove unhealthy hosts from traffic only through the service owner's approved mechanism, and decide whether the safer recovery is to complete forward, restore the previous known-good configuration, or hold a mixed state temporarily. That decision depends on schema compatibility, protocol compatibility, data migration state, capacity headroom, reversibility, and customer impact. I do not assume an Ansible rollback exists merely because the old template exists; a restart, one-way migration, cache invalidation, or coupled application release can make rollback harmful.

Before the next batch, I require explicit gates: host-level process readiness, dependency health, representative user operation, error/latency budget, capacity reserve, and a time-bounded stop condition. The playbook should encode a bounded `serial` batch, maximum failure policy, deliberate handler timing, and an observable post-change check. The runbook should state who may override a gate and how the next operator identifies the exact configuration version.

**Weak answer:** "Retry the failed hosts, then continue." A retry can hide a non-deterministic failure, increase load, or convert a partially contained outage into fleet-wide impact.

**Senior follow-up:** When is a mixed fleet acceptable? Only when compatibility and capacity are explicitly designed for it, the duration is bounded, ownership is clear, and monitoring proves the user operation remains safe. Mixed state is not automatically resilience.

## Scenario 4: an urgent bootstrap asks you to bypass SSH host-key verification

**Question:** New hosts must be configured quickly after a capacity event. The bootstrap fails because host keys are unknown, and someone proposes disabling host-key verification globally. What is your response?

**Strong answer:** I do not turn an identity failure into a blanket trust decision. SSH host-key verification answers whether the controller is speaking to the expected machine, not merely whether a TCP connection exists. During provisioning, keys can be unknown for a legitimate reason, but that reason needs a bounded enrollment path.

I first establish the authoritative source of host identity: provisioning system, hardware/VM identity, protected console, signed inventory, approved certificate authority, or a one-time out-of-band enrollment record. I limit the target set to the new hosts, validate network and account boundaries, and enroll or verify keys through the approved process. If the organization has a narrowly authorized temporary exception, I scope it to exact hosts and time, record the owner and expiry, monitor it, then remove it after identity is pinned. I never silently accept changed keys; an unexpected key can represent reprovisioning, DNS/IP reuse, a stale inventory entry, or interception.

I also separate bootstrap credentials from steady-state access. Short-lived bootstrap identity, least privilege, no broad `become`, and an auditable transition to managed access reduce the chance that a capacity event creates a permanent back door. A controller's ability to connect is not proof that the new host belongs in the production fleet; membership requires the inventory and service registration checks too.

**Weak answer:** "Use `StrictHostKeyChecking=no` so automation can work." That removes the signal that the controller may be connecting to the wrong system, precisely when provisioning and DNS are changing quickly.

**Senior follow-up:** What if the host key changed after a rebuild? Treat it as a new identity event. Verify the rebuild through the authoritative provisioning path, remove only the old, exact trusted identity under review, enroll the new one, and record why the previous key was expected to disappear.

## Scenario 5: an incident change caused drift from the playbook

**Question:** During an incident, an engineer changes a timeout directly on several hosts. The next scheduled run will revert it. What is the correct response?

**Strong answer:** I separate emergency containment from the desired long-term state. I identify the exact hosts, change, actor, reason, incident timeline, customer effect, expiration, and whether the emergency setting is still needed. I verify the real service behavior before allowing automatic convergence: a blind run can remove a containment control before the underlying fault is understood, while leaving uncontrolled drift can make recovery unpredictable.

Then I choose deliberately among three outcomes. If the emergency setting should become the desired state, I make it a reviewed, versioned change with owner, scope, rollback condition, and test. If it should end, I stage a bounded rollback and verify the user operation. If the answer is uncertain, I pause the affected automation scope, set an explicit expiry/decision owner, and avoid allowing an unattended scheduler to decide production policy by accident.

I reconcile configuration management after the incident rather than treating it as an enemy. The incident record should capture the break-glass path, evidence, and what must be codified or removed. Preventive controls include audited emergency access, temporary-change TTLs, inventory tags or maintenance windows that are hard to misuse, drift reporting that distinguishes expected emergency changes from unknown changes, and clear ownership of the service contract.

**Weak answer:** "Configuration as code is the source of truth, so let the scheduled play fix it." Code expresses intent, but it cannot infer whether an incident containment remains necessary at this minute.

**Senior follow-up:** Does a clean post-run report prove no drift? No. It proves the tool observed or enforced the state it was configured to manage at that time. Unmanaged settings, ignored paths, failed facts, hidden dependencies, and later manual changes can remain.

## Scenario 6: choose Ansible convergence or an immutable image

**Question:** A platform team wants every change delivered through immutable images. An operations team says Ansible is required for all systems. How do you make the design decision?

**Strong answer:** I reject the false universal choice. Images and configuration management solve different parts of the lifecycle. Immutable images are strong for reducing machine variance, making application/runtime versions explicit, supporting rapid replacement, and testing a known artifact before it reaches a fleet. Convergent configuration management is strong for carefully managed shared infrastructure, host enrollment, policy/configuration reconciliation, legacy estates, and controlled changes where replacing a host is not yet practical.

I start from the workload contract: how state is stored, how a node is replaced, update frequency, boot time, identity and certificate lifecycle, patch urgency, data durability, failure domain, rollback time, audit needs, and the operational team that owns the system. A database node with local data, a long-lived network appliance, a stateless worker, and a CI runner may need different strategies. The safe architecture can use both: build a tested image, boot it through a trusted path, apply only minimal identity/environment configuration, and use declarative controls to detect or repair limited drift.

The key is to avoid two controllers fighting. Define ownership: image owns base OS/packages; a role owns a narrow configuration namespace; application deployment owns application version; a secret system owns secret material; an orchestrator owns membership and traffic. Make the boundaries testable. A playbook that constantly rewrites image-owned packages, or an image that bakes environment-specific secrets, creates ambiguity and poor rollback.

**Weak answer:** "Immutable is modern, so it is always better" or "Ansible is what we know, so use it everywhere." Both answers optimize team familiarity over the workload's failure and recovery characteristics.

**Senior follow-up:** How do you prove the hybrid design is safe? Test the full replacement and rollback path: create a new artifact, enroll identity, apply the bounded configuration, verify a user operation, remove or drain the old node, and prove that a failed rollout can return to a known-good state without losing data or bypassing trust controls.

## Answer map: the sentence to remember

| When you see this | Think this first | First safe move |
|---|---|---|
| `changed` forever | The system may not have a fixed point | Find the first repeat-changing task on one safe host |
| wrong endpoint or credential | A precedence or identity boundary selected the wrong input | Stop, compare rendered non-secret contract to intended environment |
| partial batch failure | The fleet is now a mixed-state recovery problem | Stop expansion; use health and compatibility evidence to choose recovery |
| unknown or changed SSH key | Transport works, but machine identity is unproven | Verify through the authoritative enrollment path; never disable trust globally |
| incident drift | Automation cannot decide whether containment should end | Pause affected convergence; assign owner, expiry, and deliberate reconciliation |
| image versus playbook debate | Ownership boundaries matter more than tool loyalty | Map replacement, state, rollback, and each controller's namespace |

## Practice without touching a real fleet

Use the existing [Ansible primer](/career/ansible-primer) for the disposable localhost exercise. For each scenario above, write a five-sentence answer:

1. name the user operation or asset at risk;
2. name the first evidence you need and its proof limit;
3. state the smallest safe stop or containment action;
4. state the condition that permits the next mutation; and
5. name one prevention control.

Do not run a privileged play, SSH command, or production inventory merely to practise an interview answer. The skill being trained is evidence-based decision making; execution should happen only inside an approved, bounded environment.
