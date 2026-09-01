# Windows and PowerShell production interview: objects, identity, and recovery before commands

Windows operations are not a collection of GUI clicks or copied PowerShell one-liners. A service can be running while the customer journey fails; a remote session can succeed while it targets the wrong host; an administrator can have rights while the process identity does not. Treat each result as evidence with a boundary.

```text
operator -> remoting trust -> host identity -> service/process -> dependency -> user operation
    |             |                |                |              |             |
credentials   WinRM/certificate   environment      account       storage/TLS    real result
```

PowerShell helps because it passes structured objects rather than text. That reduces parsing mistakes, but it does not establish authorization, target correctness, rollback safety, or customer recovery.

## Scenario 1: the Windows service is `Running`, but users receive errors

**Question:** An IIS-hosted application is failing requests. `Get-Service` says its service is `Running`. What do you do?

**Strong answer:** I treat `Running` as Service Control Manager evidence: the service process has not reported a stopped state. It is not proof that the listener, application pool, TLS binding, dependency credentials, database connection, route, or customer operation works. I first establish the affected URL, hostname, time window, recent application/configuration/certificate changes, host scope, healthy comparison, and whether the error is at the edge, IIS, application, or dependency.

I inspect the application pool/process state, Windows and application event logs around the first error, HTTP status/substatus where available, binding and certificate identity, port/listener ownership, disk and memory pressure, service account access, and dependency health. I do not restart the service as a first action: a restart can erase useful state, create a wider outage, or temporarily hide a connection, certificate, or configuration defect. If a bounded restart is authorized after evidence points there, I state the stop condition, expected postcondition, rollback/containment path, and user-journey check.

**Weak answer:** "Restart IIS." It is an action without a diagnosed mechanism, scope, or proof that users recover.

**Senior follow-up:** What can `Get-Service` prove? That the service controller has a current status for a named service. It cannot prove that the process is accepting useful work, that its worker process is healthy, or that traffic reaches it.

## Scenario 2: a remote PowerShell change targets the wrong environment

**Question:** A CI job successfully runs PowerShell remoting, but updates a staging server when production was intended. How do you prevent this class of failure?

**Strong answer:** I make environment identity a precondition, not an assumption from a hostname. Before mutation, the automation queries and verifies approved, non-sensitive facts such as machine identity, domain/tenant, subscription/project/account identity where relevant, environment tag, expected application/service instance, and change record. It compares them to an explicit allow-list and fails closed on mismatch, ambiguity, remoting redirection, or unexpected count.

I also inspect how the target was selected: CI variables, inventory, DNS, load balancer aliases, remoting configuration, jump host, credentials, and script defaults. A successful WinRM connection only proves a transport/authentication path to *some* endpoint. It does not prove the endpoint's environment or that the automation has authority to change it. I scope credentials, session configuration, Just Enough Administration roles, and firewall/remoting endpoints to the smallest intended capability, and preserve an auditable target list before execution.

**Weak answer:** "Add the production server name to the pipeline variable." A variable can be stale, overridden, misspelled, or resolve unexpectedly; it is an input, not a verified identity boundary.

**Senior follow-up:** Why prefer PowerShell objects over text parsing here? Object properties make expected identity comparisons explicit and less sensitive to localization/format changes. The safety comes from the validated contract and authorization, not from the pipeline character alone.

## Scenario 3: a certificate renewal succeeded but TLS clients still fail

**Question:** The certificate authority issued a replacement certificate, yet some clients see the old certificate or a trust error. What do you investigate?

**Strong answer:** Issuance is only one stage. I trace the full TLS serving path: client DNS/SNI hostname, edge or load balancer, reverse proxy/IIS binding, certificate store location, selected thumbprint, private-key availability, service account ACL, intermediate chain, protocol/cipher policy, cache/session behavior, and each failure domain. A new certificate in a store can be unused if the binding still selects the old thumbprint, the private key is inaccessible, or traffic terminates upstream.

I compare the observed certificate from the affected client path with the intended subject/SAN, issuer, validity period, serial/thumbprint, and chain. I avoid broadly deleting old certificates: overlapping validity can be required for rollback or other bindings. I make the smallest scoped binding correction, verify through the affected hostname/path from a controlled client, and monitor handshake/error trends. The rollout design includes inventory of every termination point, expiry alerting that leaves time to act, automated but reviewable binding validation, and a tested rollback before expiry pressure becomes an outage.

**Weak answer:** "Import the new certificate and reboot the server." That assumes the server is the termination point and that reboot changes the selected binding.

**Senior follow-up:** Does a successful HTTPS request from one host prove global certificate recovery? No. It may use a different DNS answer, cache, protocol, SNI host, route, or trust store. It is a scoped data point, not population-wide proof.

## Scenario 4: a patch causes application failures after reboot

**Question:** A Windows patch window completed, servers rebooted, and the application now fails. Operators want to uninstall every recent update immediately. What is the safe response?

**Strong answer:** I separate correlation from causation. I establish the exact host/revision set, update IDs, reboot times, application deployment/configuration changes, service dependencies, cluster membership, customer symptom, and healthy comparison. The failure may involve a patch, but it can also be a startup ordering issue, expired credential, changed certificate, unavailable dependency, disk pressure, driver/service issue, or an application state that only appears after restart.

I stop further rollout, protect capacity and quorum according to the service runbook, and inspect the first meaningful application/system event and startup dependency sequence. I choose a bounded recovery based on evidence: restart a specific component, fail over/drain a node, restore a compatible configuration, or uninstall a *proven* update on one approved canary only when vendor/support and rollback implications are understood. Uninstalling across a fleet can remove security fixes, introduce version skew, and make the actual diagnosis harder.

Prevention includes rings/canaries, known-good capacity reserve, application-aware readiness gates after reboot, approved rollback criteria, update provenance, dependency startup tests, and evidence that a staged patch actually preserves the user operation.

**Weak answer:** "The patch was last, so remove it everywhere." Sequence is a lead, not proof; fleet-wide rollback multiplies blast radius.

**Senior follow-up:** What proves patch success? Installed-update state plus reboot state plus service/dependency readiness plus a representative user operation. None alone proves safe recovery.

## Scenario 5: disk is nearly full, but deleting files is risky

**Question:** A Windows volume reaches 98% usage and an application begins failing. What is your triage?

**Strong answer:** I first locate the affected volume and the user operation, then distinguish capacity, file-count/metadata pressure where relevant, quota, reserved space, log growth, temporary artifacts, crash dumps, backups, package caches, and files held open by processes. `Get-Volume` or Explorer capacity alone does not identify ownership or whether a cleanup is safe. I collect a bounded directory/file growth view and process/service context, compare with a healthy host and recent change, and identify an explicit, approved retention policy.

I delete or archive only data that the owning policy authorizes—such as a known expired log or disposable build artifact—not "large files" by guesswork. I protect transaction logs, databases, certificate/private-key material, system component storage, active dumps required for incident evidence, and unknown application data. If immediate capacity is required, I prefer the smallest reversible and owned action, then verify free headroom, application write success, and whether growth resumes. Long-term prevention is quota/capacity alerting tied to a service owner, retention/rotation, growth-rate forecasting, and a tested expansion or failover path.

**Weak answer:** "Delete the biggest folder." Size does not prove ownership, recoverability, retention eligibility, or whether the file is open and required.

**Senior follow-up:** Why can free-space recovery fail to restore the application? The process may have already entered a bad state, a dependent volume may still be full, a file handle/permission issue may remain, or the service needs a controlled recovery. Prove the intended write path.

## Scenario 6: an administrator can access a share, but the scheduled task cannot

**Question:** A scheduled PowerShell task fails to read a network share while it works when an administrator runs it interactively. How do you reason about it?

**Strong answer:** I compare security contexts, not just permissions on the share. The scheduled task may run under a service account, virtual account, managed service account, local system identity, different logon type, non-interactive session, different profile, constrained token, or delegated credential boundary. Network access can use the machine account or fail due to double-hop/delegation behavior. A mapped drive in an interactive desktop is not a reliable automation dependency.

I identify the task's configured principal, logon type, run level, working directory, execution policy, script signing policy, network path, share and NTFS ACLs, credential delegation path, and relevant security/task events. I use least-privilege service identity, an explicit UNC path, scoped secret/identity retrieval, and a test under the exact task context. I do not solve it by granting broad share access to local administrators or embedding a reusable password in the script. The fix must preserve auditability, rotation, and the minimum permissions for the intended operation.

**Weak answer:** "Run the task as Administrator." That changes the risk boundary without proving it has the correct network identity or least privilege.

**Senior follow-up:** What does successful interactive access prove? Only that that user/session, with its current token, profile, mappings, and network path, could access the share. It does not transfer to a service identity.

## Fast decision map

| When you see this | Remember | First safe move |
|---|---|---|
| service is Running | Controller status is not customer health | Trace listener, application, dependency, and real request path |
| remoting succeeds | Transport is not environment identity | Verify approved host/environment facts before mutation |
| new certificate exists | Store presence is not active TLS binding | Observe the served certificate from the affected hostname/path |
| post-patch failures | Correlation is not causation | Stop expansion and compare exact host/update/startup evidence |
| volume nearly full | Size is not deletion authority | Identify owned retention candidates and prove the write path after cleanup |
| interactive works, task fails | User token is not service identity | Reproduce under the exact scheduled-task principal and logon boundary |

## Practice safely

Use the existing [PowerShell operations primer](/career/powershell-operations-primer) for bounded local syntax and object-pipeline practice. Do not test remoting, certificate changes, patch removal, share permissions, or service restart on an employer or personal production system merely to rehearse an answer.

For each scenario, practise: user operation; target/identity boundary; next evidence and proof limit; smallest reversible action; recovery proof; prevention. That structure makes Windows operations explainable under pressure rather than a search for a powerful command.
