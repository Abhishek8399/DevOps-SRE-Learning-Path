# Cloud production interview: draw the responsibility and failure boundary before naming a service

Cloud interviews reward the same judgment as on-premises work, with more shared boundaries. A provider status page, a green virtual machine (VM), a successful DNS answer, and a healthy application journey are different facts.

```text
organization/account -> identity policy -> network path -> compute/runtime -> data -> user journey
        |                    |                 |                 |          |
   governance/cost       authorization      routing/TLS       capacity    backup/restore
```

For every answer, say who owns each boundary: your team, the platform team, the cloud provider, or an external dependency. “Managed” changes work; it does not erase responsibility for configuration, access, data, recovery objectives or customer outcome.

## Scenario 1: an application has DNS but cannot reach a private database

**Question:** A workload resolves a database hostname to the expected private address, but connections time out. What is your path?

**Strong answer:** Name resolution proves a resolver returned an address; it does not prove route, return route, security rule, listener, TLS or database authorization. I establish source identity and subnet, destination address/port, affected population/time, healthy comparison and recent network/IAM changes. I trace route selection, subnet route tables, security groups/firewalls, network ACLs, private endpoint or proxy behavior, source/destination policy, DNS split-horizon behavior, TLS expectation and database listener/connection limits. I use approved flow/connection logs or a bounded test from the affected identity before changing rules. I make the narrowest reversible policy/route correction only after evidence, then verify an authorized application transaction and monitor errors/latency. Prevention includes documented dependency paths, least-privilege rules, connection/runbook ownership and a synthetic journey probe.

**Weak answer:** "DNS works, so open the firewall." A broad rule may not address an asymmetric route, wrong identity, listener limit or TLS/authentication failure, while expanding attack surface.

**Senior follow-up:** What can a successful TCP connection still fail to prove? TLS identity/trust, database authentication/authorization, query latency, connection-pool health, application transaction success or return-path behavior under load.

## Scenario 2: an autoscaling group adds instances but the service is slower

**Question:** Compute autoscaling reacts to CPU, yet p99 latency rises and errors increase. Why can scaling make things worse?

**Strong answer:** New instances increase demand on shared dependencies: database connections, cache churn, queue consumers, API limits, load-balancer target registration, image/bootstrap dependencies and network address capacity. I verify metric integrity, policy target, cooldown/stabilization, instance readiness, actual traffic distribution and downstream saturation. CPU can be low while queues, I/O, locks, connection pools or a rate-limited provider dependency are constrained. I contain by reducing a known amplifier, pausing a release, capping concurrency or shedding noncritical work with an approved scope. Recovery means user latency/error objectives and downstream health recover, not merely that instance count rises. Prevention is dependency-aware capacity testing, warm-up/readiness design, quotas, backpressure and a capacity model that includes the narrowest shared boundary.

**Weak answer:** "Increase maximum instances." That can turn a downstream bottleneck into a larger outage and higher cost.

**Senior follow-up:** What cost question belongs in this answer? Unit cost under healthy and degraded load, idle/warm capacity cost, retry-amplified spend, quota consumption, and the cost of the recovery path—not only hourly instance price.

## Scenario 3: an IAM policy change fixes access but creates a security risk

**Question:** A deployment fails with access denied. An engineer proposes granting administrator permissions to the CI identity.

**Strong answer:** I identify the exact principal, assumed role/service identity, requested action, resource, region/account scope, policy evaluation result and deployment operation. “Access denied” is useful evidence, but it does not justify broad privilege. I inspect identity policy, resource policy, permission boundary, organization policy, session conditions, key/secret access and the trust relationship. I add the smallest action/resource/condition permission compatible with the declared deployment contract, test it in the approved environment, and verify that an unrelated privileged action remains denied. I use short-lived identity and auditable federation rather than long-lived shared keys. Prevention is a reviewed permission model, policy tests, scoped deployment roles, access-denied telemetry and a break-glass process with expiry.

**Weak answer:** "Give admin now and tighten it later." Later rarely arrives, and the pipeline becomes a high-value compromise path.

**Senior follow-up:** What is the difference between authentication and authorization here? Authentication establishes the principal; authorization evaluates whether that principal may perform this action on this resource under current conditions. Both can fail independently.

## Scenario 4: a regional incident threatens a stateful service

**Question:** A product team says it has multi-zone compute and therefore can survive a regional failure. Challenge the design.

**Strong answer:** Availability zones are failure domains within a region; they do not create regional recovery by themselves. I map control plane, data plane, DNS/traffic management, identity, secrets/keys, databases, object storage, queues, third-party dependencies, deployment artifacts and operations access by scope. I ask for declared recovery point objective (RPO), recovery time objective (RTO), replicated data semantics, promotion/fencing, runbook, authority, communication and last restore/failover test. A standby that cannot be promoted safely or a backup that cannot be restored in time is not recovery. I avoid claiming a design is highly available until the user journey, data consistency and operational steps have been tested against the stated failure.

**Weak answer:** "Use another region." That is a location, not a recovery design; it omits data, routing, identity, capacity, cost and control-plane assumptions.

**Senior follow-up:** Why does failover need fencing? Without a reliable way to stop or isolate the old writer, split-brain can create conflicting data updates even if traffic is moved successfully.

## Scenario 5: object storage contains backups but restore fails

**Question:** A backup job reports success and objects exist in storage, but a restore exercise cannot recover the application. What did the backup prove?

**Strong answer:** It proved that the job wrote some object according to its success condition. It did not prove completeness, integrity, encryption/key access, application consistency, retention, discoverability, permissions, compatible software version, dependency order or recovery time. I preserve the failed restore evidence and identify the authoritative data set, manifest, restore target, identity/key path, versions, required schemas and dependent services. I repair the recovery procedure in an isolated environment, measure achieved RPO/RTO, document gaps and assign ownership. I do not overwrite the original evidence or claim a backup is healthy because storage bytes exist. Prevention is scheduled restore testing, immutable/versioned backup metadata, retention and access reviews, recovery runbooks and alerts on restore—not only backup—failure.

**Weak answer:** "Retry the copy command." The failure may be logical, cryptographic, authorization-related or application-consistency-related rather than transport.

**Senior follow-up:** How can encryption affect recovery? Data may be unreadable if key policy, key region, key rotation history, grants or the recovery identity is unavailable even when the storage object is intact.

## Scenario 6: a cloud bill spikes during an incident

**Question:** Cost increases sharply during a reliability incident. Leadership asks you to turn off expensive resources immediately.

**Strong answer:** I separate the cost symptom from the customer-risk decision. I identify the cost driver by account/project, service, region, tag/allocation, time window and usage metric: retry traffic, egress, autoscaling, logging cardinality, snapshots, data transfer, serverless invocations or an unbounded queue may be involved. I verify whether the spend is an intentional containment action, an amplifier, or a measurement/attribution issue. I do not cut a recovery dependency without assessing user impact, data risk and rollback. I choose a bounded reversible cost control—such as stopping a known retry loop, sampling nonessential telemetry, capping noncritical scaling or reducing retention only under an approved policy—and verify both service health and cost metric. Prevention is budgets with context, unit economics, cardinality/egress controls, incident cost runbooks and ownership.

**Weak answer:** "Turn off logs to save money." That can remove the evidence needed to restore safely and investigate security exposure.

**Senior follow-up:** What makes a cost optimization safe? It has an owner, expected savings, affected boundary, customer/reliability/security guardrails, rollback, verification window and a decision record.

## Cloud answer checklist

| Say this | Why it matters |
|---|---|
| "This signal proves X, not Y." | stops managed-service assumptions from becoming conclusions |
| "The identity/resource/region boundary is…" | narrows permission and blast-radius reasoning |
| "The user path crosses…" | connects cloud primitives to customer outcome |
| "The data recovery contract is RPO/RTO with a tested restore." | distinguishes stored bytes from recoverability |
| "This containment is reversible and scoped to…" | avoids broad policy, routing or cost changes |
| "Ownership after the incident is…" | makes prevention operational rather than aspirational |

## Practice transfer

Re-answer each scenario with one provider translation: AWS account/VPC/IAM, Azure subscription/VNet/Entra/RBAC, or GCP project/VPC/IAM. Keep the mechanism constant and state exactly where provider terminology changes the evidence source. Do not pretend that a local diagram is cloud runtime evidence; it is preparation for a reviewed, approved environment.
