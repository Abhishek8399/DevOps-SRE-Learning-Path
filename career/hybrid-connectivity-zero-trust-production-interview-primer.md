# Hybrid connectivity and zero trust: trace both the packet path and the authorization path

Hybrid outages often produce misleading half-truths: DNS resolves, a tunnel says up, a route exists, or a user is authenticated. None of those alone proves that an authorized application request can cross every path and return safely.

```text
workload identity -> DNS -> route -> tunnel/private link -> policy/NAT -> endpoint -> authorization -> return path
       |              |       |               |                  |             |              |               |
     caller         name    next hop         encryption         allowed flow  listener       permitted       symmetric
```

Trace the data plane and the identity/policy plane separately. A valid packet can be unauthorized; a valid identity can have no route.

## Scenario 1: the tunnel is up but the private API times out

**Question:** A site-to-site tunnel reports established, DNS resolves a private API address, but an application connection times out. What do you check?

**Strong answer:** Tunnel state proves a negotiated control/encapsulation relationship at that boundary, and DNS proves a resolver returned an address. Neither proves that the source subnet is selected, routed, encrypted, allowed, delivered to a listener, or returned symmetrically. I establish the source workload identity/address/route table, destination prefix/address/port, affected population, healthy comparison, route advertisements/propagation, tunnel selectors, security policies, NAT behavior, MTU/encapsulation overhead, endpoint listener and return route. I use approved flow/tunnel counters or a bounded connection test from the affected identity, then locate the first divergence from a healthy path. I correct the narrowest route/selector/policy/endpoint boundary through the owning change process and verify an authorized application transaction, not merely an ICMP result. Prevention is an explicit dependency path, route/prefix inventory, bidirectional probes, change correlation and a runbook that defines which team owns each boundary.

**Weak answer:** “The VPN is green, so restart the application.” A green tunnel can carry no relevant traffic because of selectors, routes, policy, NAT, MTU, endpoint or return-path failure.

**Senior follow-up:** Why is the return path essential? A connection needs traffic in both directions. Asymmetric routing may send replies through a firewall/NAT that lacks state or a path that is not permitted.

## Scenario 2: on-premises clients reach cloud services but cloud workloads cannot reach on-premises

**Question:** Connectivity works in one direction only. Is this just a firewall rule?

**Strong answer:** A firewall rule is one hypothesis. I map each direction independently: source address after any NAT, route selection, transit/tunnel attachment, prefix advertisement, policy at each boundary, destination listener and reverse route. One direction may be hidden by source NAT, while the reverse direction requires an unadvertised or overlapping prefix. Cloud route tables, on-premises routing domains, transit propagation, security groups/ACLs, firewall state and return-address expectations can all differ. I verify the exact five-tuple and translations at approved boundaries rather than testing from an arbitrary bastion. I avoid adding broad allow rules or default routes; those can expose unrelated networks. I apply a least-privilege route/policy correction and verify the intended application operation in both directions. Prevention is non-overlapping address planning, route ownership, directional synthetic checks, explicit NAT documentation and automated detection of missing expected prefixes.

**Weak answer:** “Open all ports between the networks.” That can create a lateral-movement path while still failing if routing, NAT or the endpoint listener is wrong.

**Senior follow-up:** Why are overlapping CIDRs dangerous? Two locations can claim the same address range, so a route cannot reliably name one destination. NAT/proxy designs may mitigate a constrained case, but they add identity, logging and return-path complexity.

## Scenario 3: private DNS returns the wrong answer for only some users

**Question:** Some applications resolve `db.internal.example` to a private address and others to a public or stale address. Where do you investigate?

**Strong answer:** I identify the exact source resolver path, search suffixes, resolver configuration, DNS view/zone authority, cache/TTL, forwarding rules, split-horizon policy, record type, response and timestamp for affected and healthy clients. A hostname is not an endpoint until resolver context is known. I check whether a workload uses a node-local cache, container resolver, VPN-provided DNS, cloud private zone association, conditional forwarder or stale local configuration. I do not flush caches globally or lower TTL blindly; that can create a resolver thundering herd and erase evidence. I correct zone association/forwarding/record ownership through the appropriate control plane, then verify fresh resolution from each affected network and an authorized connection to the expected identity. Prevention is documented namespace ownership, split-DNS tests by source network, bounded TTL change policy, resolver telemetry and record lifecycle review.

**Weak answer:** “DNS is intermittent.” DNS behavior is often deterministic for a given resolver/view/cache; the missing detail is which resolver and policy served which client.

**Senior follow-up:** What does a short TTL not guarantee? That every cache honors it, that an authoritative change propagated instantly, that a client uses the intended resolver, or that the returned endpoint is healthy and authorized.

## Scenario 4: use identity-aware access without turning identity into a network shortcut

**Question:** A team says zero trust means “no VPN; authenticate every user.” Is that sufficient?

**Strong answer:** Authentication is necessary but incomplete. Zero-trust design continuously evaluates a request against authenticated workload/user identity, device/workload posture where applicable, authorization policy, target sensitivity, context, session/token lifetime, network path and audit evidence. I define the protected resource and action first, then choose enforcement points such as an identity-aware proxy, service mesh authorization, application authorization, private endpoint or firewall policy. I do not treat network location as the only trust signal, and I do not treat an identity token as permission to reach every service. The policy must be least privilege, explicit about service-to-service identity, revocation, key/certificate rotation, workload bootstrap, logging/privacy, outage behavior and break-glass authority. I verify denied and allowed paths, token expiry/revocation, policy change rollback and user/service outcome. Prevention is policy-as-code review, narrow audiences/scopes, strong workload identity, continuous inventory and a tested identity-provider outage mode.

**Weak answer:** “Once SSO succeeds, users can access the private network.” That expands authentication into broad authorization and leaves workload identity, target policy, audit and revocation undefined.

**Senior follow-up:** What should fail closed versus fail open during an identity outage? Decide per action and safety impact. A high-risk privileged action normally fails closed; an availability-critical low-risk read may have a bounded approved degraded mode. The decision must be deliberate and tested.

## Scenario 5: MTU-like failures after adding encryption or overlay networking

**Question:** Small requests work across a new private path, but larger uploads stall or fail. What is your method?

**Strong answer:** I suspect a path maximum transmission unit (MTU) or fragmentation/packet-too-big handling issue, but verify it. Encapsulation/encryption/overlays add headers, reducing payload room. I identify interface and path MTUs, tunnel/overlay overhead, TCP maximum segment size (MSS) behavior, ICMP filtering, protocol/payload threshold, retransmissions and a healthy comparison. I use an approved bounded size test or packet/flow evidence where authorized; I do not simply set every interface to the same lower number. I correct the specific path with compatible MTU/MSS/policy settings and verify multiple payload sizes, directions and real application behavior. Prevention is an MTU budget in the connectivity design, change tests through every encapsulation layer, monitored retransmission/fragmentation signals and no blanket filtering of control messages required for path adaptation.

**Weak answer:** “Increase the application timeout.” It may hide a retransmission black hole, increase resource retention and leave users with slow failures.

**Senior follow-up:** Why can ping be misleading here? Default ICMP payloads may be far smaller than the application’s packets, and ICMP behavior may use a different policy/path from TCP traffic.

## Scenario 6: emergency access to a private environment

**Question:** During an outage, an engineer requests a broad VPN route and administrator credentials to investigate a private service. How do you respond?

**Strong answer:** I begin with the evidence needed and the smallest authorized access path that can collect it. I record incident purpose, target environment/resource, requester identity, approver, duration, permitted actions, data-handling limits, session/audit mechanism and revocation condition. I prefer read-only telemetry, a scoped bastion/proxy, just-in-time role, target-specific route and time-bounded session over broad network reachability or shared administrator credentials. If a higher privilege is necessary, use the documented break-glass workflow with independent authorization and immutable audit, then reconcile all actions and remove access on completion. I do not allow urgency to erase tenant, customer, production or compliance boundaries. Prevention is rehearsed emergency paths, auditable JIT access, clear on-call authority, health signals that reduce invasive access, and regular review of stale routes/roles.

**Weak answer:** “Give temporary admin; we will clean it later.” Unscoped temporary access often becomes invisible permanent access and can create a second security incident.

**Senior follow-up:** What is the difference between authentication and authorization evidence? Authentication supports who presented an identity; authorization supports whether that identity was allowed to perform a particular action on a particular resource under a policy at that time.

## Hybrid-connectivity answer map

1. Name source identity/address, destination identity/address/port, time and affected population.
2. Resolve name, route, tunnel/transit, policy/NAT, endpoint and return path independently.
3. Compare a healthy path before changing a broad policy.
4. Keep identity, authorization and network reachability as separate contracts.
5. Make access and remediation least-privilege, time-bounded and auditable.
6. Verify an authorized end-to-end user operation in both directions.

The durable habit: **a private path is trustworthy only when the right identity can perform the right action over the intended route, and you can prove it without opening every route.**
