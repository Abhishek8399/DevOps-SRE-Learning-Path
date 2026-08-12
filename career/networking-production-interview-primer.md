# Networking production interview: locate the first boundary that loses healthy evidence

Networking is easiest to explain as a request path, not as a bag of commands.

```text
name -> address -> route/source -> neighbor/NAT -> TCP -> TLS -> HTTP/proxy -> application
 |         |            |              |           |      |        |              |
DNS      record       next hop      state table  socket  trust   policy        user result
```

A timeout does not prove packet loss. A DNS answer does not prove a route. A TCP handshake does not prove TLS, HTTP, authorization or a useful response. Say that explicitly before proposing a change.

## Scenario 1: one region cannot reach an API

**Question:** Clients in one region time out calling an API; all other regions are healthy. What is your first path?

**Strong answer:** I define the exact client region/network, address family, hostname/address, destination port, request class, time window and healthy-region control. I compare DNS answers/TTL, selected route and source address, NAT/egress identity, firewall/security policy, TCP connection timing, TLS identity and HTTP/proxy behavior. The regional split suggests an edge, route, resolver, egress, load-balancer or dependency boundary; it does not prove the API itself is down. I collect approved evidence at both sides where possible and make the smallest reversible routing/traffic/policy change only after a hypothesis is supported. Recovery is a successful user request from the affected boundary plus stable errors/latency, and prevention is regional journey monitoring and ownership of the failed boundary.

**Weak answer:** "Restart the API because users time out." A healthy region is evidence against a global application failure and should change the order of investigation.

**Senior follow-up:** Why compare address families? IPv4 and IPv6 can resolve, route, NAT and fail independently; a client preference can make only one population appear broken.

## Scenario 2: small responses work, large responses fail

**Question:** Tiny HTTPS responses are reliable but larger ones stall through a private path. How do you reason about it?

**Strong answer:** I make payload threshold, direction, tunnel/encapsulation, client type and route explicit. I test a bounded size matrix and compare direct/proxied and healthy paths. Then I investigate path maximum transmission unit (MTU), fragmentation/PMTUD behavior, ICMP filtering, TCP retransmissions, proxy/request-body/response-buffer limits, compression and asymmetric return path. I do not assert "MTU" from a symptom alone; I seek packet/connection/proxy evidence that changes with size. I apply a scoped reversible correction only after proving the owning boundary, then verify both small and large complete requests. Prevention includes documented effective MTU after encapsulation, synthetic payload tests and safe change review for tunnels/load balancers.

**Weak answer:** "Increase the HTTP timeout." A longer timeout can hide retransmission or buffering failure while consuming more client and server resources.

**Senior follow-up:** Why can a ping test mislead? It may use a different payload, protocol, policy, address family or path than the HTTPS request, and ICMP can be handled differently.

## Scenario 3: connections grow until new requests fail

**Question:** New connections occasionally fail while CPU is low. Socket dashboards show a large TIME_WAIT count. What do you do?

**Strong answer:** I identify which host/process/port owns the sockets, whether connections are outbound or inbound, ephemeral-port range, connection rate, destination distribution, reuse/pooling behavior, NAT/load-balancer state and error code. TIME_WAIT is part of TCP’s orderly close behavior and protects against delayed segments; its presence is not automatically a bug. I inspect `ss` or equivalent socket evidence, application connection lifecycle, file descriptor limits and upstream behavior before tuning kernel values. I contain with correct connection reuse/pooling, bounded retries, rate/concurrency control or scoped capacity only if evidence supports it. Recovery is new authorized connections succeeding at normal rates and no hidden retry amplification. Prevention is connection-rate/capacity modelling, client lifecycle tests and alerting on errors plus resource headroom rather than one state count.

**Weak answer:** "Set a random sysctl to remove TIME_WAIT." Kernel tuning can change correctness and risk; it does not repair an application opening a new connection for every request.

**Senior follow-up:** What other resource can look similar? File descriptor exhaustion, NAT port/state exhaustion, load-balancer connection limits, DNS-driven uneven destination use or a remote accept backlog.

## Scenario 4: DNS changes do not take effect

**Question:** You changed a service record, but some clients still call the old endpoint. What do you check?

**Strong answer:** I identify the exact resolver chain and client population: application cache, OS stub, local resolver, recursive resolver, authoritative zone, TTL, negative cache, split-horizon view and connection pooling. DNS is distributed cached data, not an instantaneous switch. I compare answers and TTL from affected and healthy sources without assuming one `dig` result represents all clients. I also check whether clients pin an existing connection or proxy upstream independently of DNS. I choose a migration plan with overlap, health/readiness, old endpoint drain, TTL lead time and rollback. Recovery means the intended affected clients complete requests to the correct healthy target; prevention is ownership of records/views, documented cache behavior and controlled cutover tests.

**Weak answer:** "Flush every DNS cache." That is broad, often impossible, and ignores application/proxy connection reuse and split-horizon configuration.

**Senior follow-up:** What does TTL guarantee? It tells a compliant cache how long it may reuse an answer after receiving it; it does not force every application/cache to refresh simultaneously or reveal all prior caching behavior.

## Scenario 5: TLS fails after certificate rotation

**Question:** After a certificate rotation, some clients fail TLS while browser tests look fine. How do you investigate?

**Strong answer:** I compare affected client versions/trust stores, hostname/SNI, resolved edge, certificate chain, key algorithm, validity window, clock, protocol/cipher support, termination point and any mutual TLS requirement. A browser success from one machine proves that one client/path trusts one served chain; it does not prove compatibility for older clients, API consumers, other regions or all edge nodes. I inspect the exact handshake error and served certificate from affected boundaries, verify deployment propagation and retain the prior safe certificate/rollback path where policy allows. I avoid disabling certificate verification or broadening protocol support as a quick fix. Recovery is a successful handshake and real request from the affected client class; prevention is staged rotation, chain/expiry/clock monitoring, compatibility matrix and owned certificate inventory.

**Weak answer:** "Turn off TLS verification temporarily." That changes the trust boundary and can convert an availability incident into a security incident.

**Senior follow-up:** Why can intermediate certificates matter? A server may present a leaf that looks correct but omit a needed chain issuer; clients with different cached roots/intermediates can behave differently.

## Scenario 6: a load balancer marks healthy backends but returns 502/503

**Question:** Load-balancer health checks are green, yet user requests fail intermittently. What are the missing boundaries?

**Strong answer:** A health check is one request shape from one checker identity to one target criterion. I compare health-check protocol/path/host/header/TLS/source with the real client route, listener/rule selection, target group membership, connection reuse, timeouts, body limits, proxy headers, application dependencies and error distribution. I correlate failing requests with target, revision, zone, route and dependency. I do not merely weaken health checks or deregister all targets. I contain by isolating a proven bad revision/target/route or reducing traffic with a reversible decision, then verify user success and healthy capacity. Prevention is health checks that represent the correct readiness boundary, separate dependency/black-box observability, safe draining and a runbook for target/routing evidence.

**Weak answer:** "Green health checks mean the application is fine." They mean the configured checker observed its configured success condition.

**Senior follow-up:** When is a dependency appropriate in readiness? Only when failing that dependency means the instance truly cannot serve the traffic it would receive, and the failure behavior will not create a restart/withdrawal storm that worsens the dependency incident.

## Speak the evidence ladder

| Layer | Safe question | Proof limit |
|---|---|---|
| DNS | What answer and TTL did this resolver/client receive? | not packet reachability |
| Routing | Which source, next hop and return path are selected? | not port/listener authorization |
| Transport | Did the intended socket establish and transfer as expected? | not TLS/HTTP/application success |
| TLS | Does this client trust the served identity for this hostname/time? | not authorization or business success |
| HTTP/proxy | Did the expected route/status/header/body behavior occur? | not downstream data correctness |
| User journey | Did the scoped real operation complete? | not all populations or future capacity |

## Practice transfer

For each scenario, say one healthy control path and one changed constraint: another region, IPv6, a proxy, a container namespace, a private endpoint, a different client trust store or a high connection rate. The purpose is not to memorize `curl`, `ss`, `ip route` or `openssl`; it is to know what question each tool can answer before you run it.
