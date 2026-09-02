---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0004",
  "aliases": ["V01-L04", "network-request-path"],
  "curriculumIds": ["NET-003"],
  "slug": "network-request-path",
  "route": "/book/linux/network-request-path",
  "order": 4,
  "volume": "01-linux-systems",
  "title": "Network request path: DNS, routes, TCP, TLS, HTTP, and applications",
  "summary": "Trace one request from the failing client namespace through name resolution, local routing, policy and translation, transport, TLS, HTTP intermediaries, service discovery, destination process, dependencies, and response before changing the network.",
  "domain": "connectivity",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 250,
  "prerequisiteLessonIds": ["LES-0002"],
  "prerequisiteCurriculumIds": ["LNX-002", "FND-001", "DBG-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The walkthrough performs read-only inspection of local identity, resolver configuration, loopback routing, and listening sockets; no packet or service is created."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04", "support": "supported", "notes": "The request path crosses a virtualized Windows/WSL boundary; record it and do not treat the view as a physical Linux host."},
    {"platform": "Docker container", "version": "Linux container", "support": "concept-only", "notes": "Network namespace, virtual interface, embedded DNS, port publication, proxy, and host forwarding can create distinct paths."},
    {"platform": "Kubernetes", "version": "Version-dependent", "support": "concept-only", "notes": "Pod DNS, CNI, NetworkPolicy, Service translation, EndpointSlices, sidecars, gateways, and application dependencies need cluster-specific evidence."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "kubernetes-platform-engineer"],
  "learningObjectives": [
    "Name every major request boundary from application name lookup to response consumption without collapsing them into networking.",
    "Explain IP address/prefix, route, next hop, ARP or neighbor discovery, policy, NAT, ports, sockets, TCP, TLS, HTTP, proxy, load balancer, Service, EndpointSlice, and application ownership.",
    "Distinguish resolution failure, no route, timeout, refusal, reset, TLS failure, HTTP response, and slow dependency by the last successful and first failed gate.",
    "Decode getent, resolv.conf, ip address, ip route get, ss, curl verbose timing, and openssl evidence with scope and proof limits.",
    "Start from the failing client namespace and compare a healthy peer rather than treating host or node success as equivalent.",
    "Design safe recovery, verification, and prevention across DNS, policy, transport, TLS, routing, load balancing, and application ownership."
  ],
  "productionSignals": [
    "A hostname resolves but connections time out.",
    "A connection is refused immediately on one address and succeeds on another.",
    "TCP connects but TLS fails because server name, trust, time, protocol, or termination differs.",
    "A proxy or gateway returns HTTP 502, 503, or 504 while the application appears healthy.",
    "A service works from a Kubernetes node but fails from one Pod or namespace.",
    "A direct endpoint works while a Service virtual address fails, or the reverse.",
    "The failure follows one node, zone, resolver, address family, proxy, or deployment cohort.",
    "Retries amplify connection, queue, or dependency pressure and hide the first failure."
  ],
  "diagrams": [
    {"id": "LES-0004-DIA-001", "title": "End-to-end request chain", "direction": "left-to-right", "boundaries": ["client code and deadline", "name resolution", "source namespace and route", "policy/NAT/firewall", "TCP or UDP transport", "TLS termination", "HTTP proxy/load balancer", "destination listener and application", "dependency and response"], "evidencePoints": ["operation and timer", "records and resolver", "source/address/next hop", "rule/counter/translation", "handshake state", "certificate/SNI/ALPN", "request ID/status/upstream", "socket/log/trace", "dependency span and final result"], "textAlternative": "A request leaves client code, resolves a name, selects a source and route, crosses policy or address translation, establishes transport, may negotiate TLS and traverse HTTP intermediaries, reaches a listener and application dependency, then returns along a response path."},
    {"id": "LES-0004-DIA-002", "title": "Last success and first failure", "direction": "top-to-bottom", "boundaries": ["DNS answer", "route decision", "SYN/SYN-ACK", "TLS handshake", "HTTP headers", "application handler", "dependency", "response body"], "evidencePoints": ["address/TTL", "route/source", "refusal/timeout/reset", "certificate and alert", "status and request ID", "server log/trace", "downstream latency/error", "client result"], "textAlternative": "Locate the last gate with affirmative evidence and the first gate with failure evidence; investigate their handoff instead of restarting every layer."},
    {"id": "LES-0004-DIA-003", "title": "Kubernetes Pod-to-Service path", "direction": "left-to-right", "boundaries": ["client Pod namespace", "cluster DNS", "Pod route and CNI", "egress policy", "Service virtual identity", "proxy or eBPF translation", "EndpointSlice address", "ingress policy", "destination Pod listener", "application dependency"], "evidencePoints": ["Pod identity/node", "A/AAAA/SRV answer", "source/interface/route", "selected policies", "Service ports/selectors", "dataplane state", "ready endpoints", "destination labels/policy", "ss/log/trace", "dependency evidence"], "textAlternative": "A Pod resolves a Service, routes through its CNI and egress policy, reaches virtual Service translation toward a ready EndpointSlice address, crosses destination policy, and reaches the target listener and application."}
  ],
  "commands": [
    {"id": "LES-0004-CMD-001", "question": "What addresses does the failing application-style resolver return here?", "risk": "read-only", "command": "getent ahosts HOSTNAME", "runFrom": "The failing client namespace and then a comparable healthy peer.", "expectedBranches": [{"when": "addresses differ by client", "meaning": "Resolver, search, split-DNS, cache, or configuration scope differs.", "nextEvidence": "Inspect resolv.conf, application caching, record family, and authoritative intent."}, {"when": "the expected address appears", "meaning": "Name resolution succeeded in this observation.", "nextEvidence": "Continue to source/route, policy, transport, TLS, and application gates."}], "proves": "Addresses returned through the local name-service path used by getent at that moment.", "doesNotProve": "Authoritative freshness, reachability, transport, TLS, HTTP, or application health."},
    {"id": "LES-0004-CMD-002", "question": "Which source address, interface, and next hop would Linux select?", "risk": "read-only", "command": "ip route get DESTINATION_IP", "runFrom": "The exact failing network namespace.", "expectedBranches": [{"when": "a route with src/dev/via appears", "meaning": "The local routing decision selected those fields.", "nextEvidence": "Inspect neighbor, policy, packet progression, and return path."}, {"when": "unreachable or no route appears", "meaning": "The local routing table cannot select a usable path.", "nextEvidence": "Inspect namespace interfaces, routes, policy routing, address family, and intended topology."}], "proves": "The kernel's local route lookup result for the supplied destination and current policy context.", "doesNotProve": "Packet delivery, downstream firewall, NAT, return path, listener, or application success."},
    {"id": "LES-0004-CMD-003", "question": "Which local TCP sockets are listening and on what address scope?", "risk": "read-only", "command": "ss -lntp", "runFrom": "The destination host or container namespace with authorized process visibility.", "expectedBranches": [{"when": "listener exists only on 127.0.0.1", "meaning": "Remote interface traffic cannot reach that bind address directly.", "nextEvidence": "Confirm intended bind, proxy/port publication, and service configuration."}, {"when": "expected port has no listener", "meaning": "An immediate refusal or local rejection is plausible.", "nextEvidence": "Inspect service process, startup logs, address family, and supervisor state."}], "proves": "Listening TCP socket state visible in this namespace and permitted process metadata.", "doesNotProve": "Remote reachability, backlog health, correct protocol, TLS, request handling, or another namespace."},
    {"id": "LES-0004-CMD-004", "question": "Where does an HTTPS request spend time and which protocol gate fails?", "risk": "sampled-read-only", "command": "curl -v --connect-timeout 3 --max-time 10 -o /dev/null -sS -w 'remote=%{remote_ip} code=%{http_code} dns=%{time_namelookup} connect=%{time_connect} tls=%{time_appconnect} first_byte=%{time_starttransfer} total=%{time_total}\\n' https://HOST/PATH", "runFrom": "An authorized client using the real hostname and safe idempotent endpoint; the request can create remote logs and metrics.", "expectedBranches": [{"when": "connect time is absent or timeout occurs", "meaning": "Transport did not complete within the bounded deadline.", "nextEvidence": "Compare route, packet/policy, destination listener, and healthy peer."}, {"when": "HTTP status arrives", "meaning": "DNS, transport, and any required TLS completed to the responding HTTP component.", "nextEvidence": "Identify that component, request ID, upstream route, application and dependency evidence."}], "proves": "Client-observed resolution/connection/TLS/first-byte/total timing and response status for one bounded request.", "doesNotProve": "Server-side phase causality, all users, safety of non-idempotent paths, or absence of retries/proxies."},
    {"id": "LES-0004-CMD-005", "question": "What certificate and TLS negotiation does this server name present?", "risk": "sampled-read-only", "command": "openssl s_client -connect HOST:443 -servername HOST -verify_return_error </dev/null", "runFrom": "The failing client context against an authorized endpoint; connection creates remote telemetry.", "expectedBranches": [{"when": "certificate/verification succeeds", "meaning": "This client negotiated and validated the displayed TLS path under its trust/time/configuration.", "nextEvidence": "Continue to HTTP hostname/path/authentication and application behavior."}, {"when": "verification or alert fails", "meaning": "TLS trust, identity, time, protocol, cipher, client-auth, or termination needs classification.", "nextEvidence": "Record exact alert/chain/SNI/time and compare intended policy."}], "proves": "Presented chain and negotiation visible for the specified address and SNI from this client.", "doesNotProve": "HTTP authorization, application health, all clients, safe certificate replacement, or backend TLS."},
    {"id": "LES-0004-CMD-006", "question": "What network identity and resolver configuration does this namespace use?", "risk": "read-only", "command": "ip -br address; ip route; cat /etc/resolv.conf", "runFrom": "The failing client namespace; sanitize addresses and search domains before sharing.", "expectedBranches": [{"when": "affected and healthy peers differ", "meaning": "Interface, route, resolver, node, or injected configuration may explain scope.", "nextEvidence": "Compare one boundary at a time and preserve deployment/placement identity."}, {"when": "they appear identical", "meaning": "The displayed configuration matches at this level.", "nextEvidence": "Continue to policy state, translations, transport packets, proxy and application evidence."}], "proves": "Visible interface addresses, main route table, and resolver file contents at observation time.", "doesNotProve": "All policy-routing tables, effective DNS upstream behavior, NetworkPolicy, firewall, NAT, or packet delivery."}
  ],
  "labs": [
    {"id": "LES-0004-LAB-001", "title": "Read one Ubuntu local request context", "mode": "guided", "environment": "Ubuntu 24.04, normal user", "timeMinutes": 25, "privilege": "No sudo or root; read-only observation.", "network": "No external request; only local configuration, loopback lookup/route, and socket state are read.", "changes": ["No network, service, firewall, route, DNS, file, or process mutation."], "abortConditions": ["The shell is root.", "Ubuntu 24.04 is not available.", "A required base command is missing.", "Output contains sensitive network information that cannot be kept local.", "Any step would need an external or production request."], "recovery": "No recovery is required because the walkthrough does not mutate state.", "cleanupProof": "bash lab.sh cleanup reports cleanup=not-required, mutation=none, and cleanup_proven=true.", "path": "book/labs/LES-0004-request-path-observation"}
  ],
  "incidents": [
    {"id": "LES-0004-INC-001", "signal": "Name resolution succeeds, but TCP connection times out.", "firstThought": "DNS is the last proven gate; local route, policy, translation, delivery, listener response, and return path remain open.", "safePath": "Compare failing and healthy client routes and bounded transport evidence, then observe both sides before changing policy.", "trap": "Restart DNS or declare the network down."},
    {"id": "LES-0004-INC-002", "signal": "TCP connects, but the certificate is wrong for the hostname.", "firstThought": "Address reachability exists, while SNI, routing, TLS termination, certificate selection, or deployment identity is wrong.", "safePath": "Preserve hostname/address/chain/termination evidence and correct the owned routing or certificate deployment with staged rollback.", "trap": "Disable verification or use an IP address in production."},
    {"id": "LES-0004-INC-003", "signal": "A Service works from the node but times out from one Pod.", "firstThought": "Node success does not traverse the Pod's resolver, namespace, source identity, policy, sidecar, and Service path.", "safePath": "Start inside the affected Pod, compare a healthy peer, then trace DNS, route, policies, Service, EndpointSlice, CNI, destination listener, and app.", "trap": "Restart the Pod before locating the divergent boundary."}
  ],
  "assessmentIds": ["ASM-0274", "ASM-0275", "ASM-0276"],
  "referenceIds": ["REF-1221", "REF-1222", "REF-1223", "REF-1224", "REF-1225", "REF-1226"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-09-02",
  "reviewAfter": "2027-03-02",
  "limitations": [
    "The Ubuntu walkthrough observes only local loopback and configuration state and intentionally performs no external request, capture, namespace change, route/policy mutation, listener creation, or cluster action.",
    "Exact DNS, CNI, proxy, load-balancer, TLS, firewall, NAT, service-mesh, and cloud behavior is implementation and version dependent.",
    "Socket, process, policy, and packet visibility may require separate authorization; missing evidence is not proof of absence.",
    "Formal review, browser QA, representative distributed request tracing, independently reviewed transfer, delayed recall, and mastery remain unproved."
  ]
}
---

# Network request path: DNS, routes, TCP, TLS, HTTP, and applications

## What you see and first thought

Someone says “the network is down.” Ask: **which exact request, from which process and namespace, to which hostname/address/port/path, failed at which gate?**

A user operation can cross name resolution, source-address selection, local route, neighbor resolution, virtual interfaces, firewall or NetworkPolicy, NAT, transport, TLS, proxies, load balancers, service discovery, destination listener, application queues, and dependencies. “Network” is not one box and a timeout is not one cause.

Use the memory sentence: **last success, first failure, owner at the handoff.** Preserve evidence before restarting clients, proxies, DNS, Pods, or nodes.

## Terms before commands

**Hostname and DNS:** A name is resolved into records such as A/AAAA addresses or service metadata. A successful lookup proves only what this resolver returned now.

**IP address and CIDR prefix:** An address identifies an interface or routed endpoint in a scope; a prefix describes a network range. It does not prove a service is healthy.

**Network namespace:** A separate Linux view of interfaces, addresses, routes, firewall state, and sockets. Pods and containers usually do not share the host's view.

**Route:** The kernel decision selecting destination prefix, next hop, interface, and source address. A route decision does not prove delivery or return path.

**Neighbor resolution:** ARP for IPv4 or Neighbor Discovery for IPv6 maps a directly reachable IP to link-layer delivery information. Failure can prevent the first hop.

**Port and socket:** A port is a transport-layer number. A socket is kernel state binding address, port, protocol, and process context. “Port open” is an observation, not an application guarantee.

**TCP:** A reliable ordered byte stream with connection state, acknowledgements, retransmission, flow control, and congestion control. It does not define request semantics.

**UDP:** A datagram transport without TCP's connection or retransmission semantics. DNS can use UDP or TCP; applications must supply any additional reliability they require.

**TLS:** Authentication and encryption negotiated over a transport. SNI selects a server name; trust chain, time, hostname, protocol, cipher, and optional client identity can each fail.

**HTTP:** A request/response application protocol with methods, paths, headers, status codes, and bodies. The responder can be a gateway or proxy rather than the final application.

**Proxy/load balancer/gateway:** An intermediary that accepts one connection and chooses another upstream path. It creates a new observation and ownership boundary.

**Timeout:** A deadline expired. Always name the timer: DNS, connect, TLS, request headers, first byte, body, upstream, or total.

**Connection refused:** Commonly an immediate transport rejection, often a reset because nothing accepts that address/port or policy actively rejects it.

**Reset:** An established or attempted TCP connection was aborted. Identify which endpoint or intermediary emitted it rather than guessing.

## Architecture map

```text role=diagram lines=off
client operation + total deadline
        |
resolver -> hostname -> A/AAAA/SRV -> destination address
        |
namespace -> source address -> route -> neighbor -> interface
        |
firewall / NetworkPolicy / NAT / CNI / load balancer
        |
TCP connect -> TLS (SNI, chain, ALPN) -> HTTP request
        |
proxy/gateway -> upstream connection -> listener -> application
        |
dependency -> response status/body -> client consumes result
```

The return path matters too. A SYN can reach a server while its reply is filtered, misrouted, or translated incorrectly.

## Request or state path

For `https://api.example.test/payments/42`:

1. the client parses scheme, hostname, port, method, path, and deadline;
2. its resolver configuration and cache produce addresses;
3. the client's namespace selects source address, route, and first-hop delivery;
4. policy, firewall, NAT, mesh, VPN, or proxy may transform or reject traffic;
5. TCP establishes ordered transport or fails/refuses/times out;
6. TLS uses the hostname for SNI and identity validation and negotiates protocol;
7. an HTTP component receives the request and may select an upstream;
8. the destination listener and application execute, call dependencies, and respond;
9. bytes return through transport and the client accepts or rejects the result.

Every arrow is a contract. Capture request ID or trace context when available, but remember that missing telemetry can mean the request never reached that instrumented boundary.

## Failure zoom

### DNS fails

No usable address was returned in time. Check the failing namespace, exact name, search domain, record type, resolver path, cache, upstream authority, and deadline. Do not conclude the destination is down.

### DNS succeeds, connect times out

Naming is proven narrowly. Route, neighbor, policy, NAT, delivery, listener response, congestion, and return path remain. Compare affected and healthy clients and observe both ends.

### Connection refused

An active rejection usually narrows toward wrong address/port, missing/wrong bind, service not listening, or reject policy. Verify IPv4 versus IPv6, namespace, destination translation, and listener state.

### TCP succeeds, TLS fails

Reachability exists to the terminating component. Inspect server name, presented identity/chain, trust roots, clock, protocol, ALPN, client certificate, and termination routing. Never “fix” it with insecure verification.

### HTTP 502, 503, or 504

An HTTP component answered. `502` often represents an invalid/broken upstream response, `503` unavailable/overloaded/no usable backend, and `504` an upstream deadline—but implementation matters. Identify the responder from headers, request IDs, config, and logs.

### Slow first byte

DNS/TCP/TLS may be quick while proxy queue, application queue, handler, or dependency is slow. Use aligned client timing, server logs/traces, saturation, queue age, and healthy cohorts.

## Internals and state ownership

Linux chooses routes using namespace-local state and may apply policy rules beyond the main table. A local lookup returns a planned source, interface, and next hop; it is not a packet trace.

TCP establishes state using sequence numbers and acknowledgements. Retransmissions can reflect loss, reordering, congestion, policing, path MTU, or receiver behavior. A single retransmission counter without flow, interval, and baseline is not root cause.

TLS normally starts after transport. The certificate can be valid yet wrong for the requested hostname; a correct certificate can be served by the wrong backend; mutual TLS adds client identity and authorization. Preserve SNI and termination point.

HTTP intermediaries terminate connections and create new ones. Client `200` came from the responder, but a gateway can synthesize errors before the application. End-to-end ownership requires correlation across hops.

In Kubernetes, the Pod namespace, CNI, DNS, NetworkPolicy, Service, proxy/eBPF translation, EndpointSlice readiness, target port, destination policy, sidecar, and application are separate controllers and states. Node `curl` can bypass most of them.

## Evidence table

| Gate | Evidence | Supports | Does not prove |
|---|---|---|---|
| Client | operation, URL, deadline, error, cohort | Exact symptom and timer | Downstream cause |
| DNS | `getent`, resolver config, record/time | Returned address in this context | Reachability or freshness everywhere |
| Local network | address and `ip route get` | Planned source/interface/next hop | Delivery or return path |
| Policy/path | rule/counter and both-side packet evidence | Where packets appear or stop | Application health by itself |
| TCP | connect result, socket/listener state | Transport boundary progress | TLS or HTTP success |
| TLS | SNI, chain, verify result, alert, ALPN | Negotiation and peer identity evidence | HTTP authorization/health |
| HTTP | status, headers, request ID, timing | A responder and protocol result | Final-app ownership without correlation |
| Application | listener, logs, trace, queue, dependency | Handler and downstream behavior | Client consumption or all cohorts |

Use time-synchronized evidence and state which namespace, address family, node, proxy, and revision produced it.

## Command decoders

### `getent ahosts HOSTNAME`

`getent` uses the system name-service configuration used by many Linux applications and can expose multiple address families. Results can differ from a DNS-only tool because `/etc/hosts`, NSS modules, local stubs, and policy participate. Application caches may still differ.

### `/etc/resolv.conf`

`nameserver` identifies the visible resolver endpoint, `search` expands short names, and `options` changes resolver behavior. A local stub address hides the ultimate upstream. Reading the file does not prove which cached answer an already-running application uses.

### `ip -br address` and `ip route get DESTINATION`

The address view shows interfaces and assigned addresses compactly. Route lookup shows a planned route with fields such as `via`, `dev`, and `src`. It does not send a packet, test policy at other nodes, or validate the reply.

### `ss -lntp`

`-l` selects listening sockets, `-n` avoids name conversion, `-t` selects TCP, and `-p` requests process details when permitted. `127.0.0.1:8080` is loopback-only; `0.0.0.0:8080` accepts IPv4 addresses subject to policy. Another namespace has another socket table.

### `curl -v` with bounded timers

Verbose output shows client protocol progression; `time_namelookup`, `time_connect`, `time_appconnect`, `time_starttransfer`, and `time_total` are cumulative timestamps from request start. Subtract compatible points for phase approximations. One request is not a latency distribution and can mutate remote telemetry or application state.

### `openssl s_client`

`-connect` selects the address and port, `-servername` sends SNI, and verification options report trust/identity problems. It is a diagnostic client, not an application-equivalent HTTP check.

## Decision path

1. **Frame:** exact user operation, URL/host/address/port, error, timer, client identity, namespace, cohort, start time, and recent change.
2. **Resolve:** capture system/application resolver behavior from the failing context and a healthy control.
3. **Route:** record source, address family, interface, next hop, proxy/VPN/mesh, and return-path owner.
4. **Transport:** distinguish no route, timeout, refusal, reset, and established TCP using client, destination, and when authorized packet evidence.
5. **Secure:** if TCP succeeds, inspect SNI, chain, trust, clock, protocol, ALPN, and mTLS identity.
6. **HTTP:** identify the actual responder, status, request ID, upstream selection, retry, queue, and timeout ownership.
7. **Application:** inspect listener, handler, saturation, dependencies, and correct result.
8. **Recover:** choose one reversible owned action with prediction, maximum scope, abort, rollback, and communication.
9. **Verify:** run the original safe journey plus healthy controls and observe error/latency/retry/queue stability.

Avoid shotgun restarts. Each restart clears caches, sockets, connection pools, queues, and evidence simultaneously, so even success leaves cause ambiguous.

## Guided Ubuntu lab

This walkthrough reads the local network context and loopback route. It does not call the internet, start a server, or alter DNS/routes/firewall.

```bash role=command file=book/labs/LES-0004-request-path-observation/lab.sh lines=on
bash book/labs/LES-0004-request-path-observation/lab.sh check
bash book/labs/LES-0004-request-path-observation/lab.sh observe
bash book/labs/LES-0004-request-path-observation/lab.sh cleanup
```

Decode `localhost` resolution, loopback addresses, route result for `127.0.0.1`, main routes, resolver file, and current listeners. A listener may be absent; that is state, not lab failure. Keep output local because real interfaces/search domains may be sensitive.

Success means you can explain what every field proves and why none of these local observations proves an external application works.

## Production transfer

**Kubernetes:** Start inside the affected Pod. Compare a healthy peer on the same and another node. Join labels, service account, resolver result, route, policies in both directions, Service ports/selectors, EndpointSlices, target port, CNI programming, sidecar, destination listener, and application trace.

**Cloud:** Security groups, network ACLs, route tables, NAT gateways, private endpoints, load balancer listeners/target groups, health checks, DNS views, TLS policies, and service quotas are distinct. A console “healthy” badge is one controller's opinion.

**Hybrid/private cloud:** Add VLAN/VRF, hypervisor vSwitch, distributed firewall, load balancer, routing domain, MTU, physical fabric, DNS forwarding, proxy, and asymmetric return-path ownership. Trace identities rather than device names.

**Service mesh:** The application may connect to a sidecar or node proxy, which opens another upstream connection with its own TLS, retry, timeout, pool, and telemetry. Separate client-to-proxy and proxy-to-upstream evidence.

## Reliability, security, observability, capacity, and cost

**Reliability:** Use end-to-end deadlines with smaller owned hop budgets, bounded retries with jitter, connection reuse, health/readiness semantics, failover tests, and safe degradation. A timeout without its owner creates retry storms.

**Security:** Do not weaken certificate verification, broaden firewall rules, disable NetworkPolicy, or expose listeners to test a guess. Network captures and verbose output can contain tokens, cookies, names, topology, and customer data; minimize and redact.

**Observability:** Correlate client error/latency, DNS results, connection outcomes, TLS failures, proxy status/upstream, application requests, dependencies, and network drops by time, cohort, endpoint, address family, and request ID. Missing spans are evidence about instrumentation coverage.

**Capacity:** Plan resolver QPS, connection rate, concurrent sockets, ephemeral ports, conntrack, accept queues, TLS CPU, proxy pools, load-balancer targets, bandwidth, packet rate, and application concurrency. Bytes/s alone misses connection and queue limits.

**Cost:** NAT and gateway processing, load balancers, public/private endpoints, cross-zone/region transfer, egress, logs/traces, idle failover, certificates, and engineer time all matter. Optimize only after preserving reliability and security objectives.

## Traps and prevention

### Ping is the network test

ICMP may be blocked or take another policy path. It does not test the application protocol, hostname, port, TLS, proxy, or authorization. Test the real path safely.

### DNS success means networking is fine

DNS proves naming only. Continue through route, policy, transport, TLS, HTTP, and application.

### Timeout means firewall drop

It can be loss, route, return path, slow queue, handshake, application, dependency, or a deadline smaller than healthy behavior. Name the timed stage.

### Node success proves Pod success

The node can bypass Pod DNS, namespace, identity, policy, CNI, Service translation, and sidecar. Use node results as a comparison, not a substitute.

### HTTP 503 came from the app

A gateway, mesh, load balancer, or application may emit it. Identify the responder and upstream evidence.

### Disable TLS verification temporarily

That changes the security contract and can hide misrouting or interception. Fix trust, identity, time, termination, or routing through a reviewed rollout.

## Memory card and retrieval

```text role=diagram lines=off
NAME -> SOURCE/ROUTE -> POLICY/NAT -> TCP -> TLS -> HTTP -> APP -> DEPENDENCY
                 LAST SUCCESS | FIRST FAILURE
```

Answer aloud:

1. What exactly does a successful DNS lookup prove?
2. Distinguish no route, timeout, refused, reset, TLS alert, HTTP 503, and HTTP 504.
3. Why can a node request succeed while one Pod fails?
4. What does `ip route get` not do?
5. Why is `curl` first-byte time not server CPU time?
6. Why can direct endpoint success and Service failure implicate translation without proving it?
7. What must be verified after a network mitigation?

Review tomorrow, in three days, one week, and one month by redrawing one real request path from memory.

## Complete answers

### 1. DNS success

This resolver path returned one or more records for this name at this time. It does not prove authoritative freshness, correct application cache, route, policy, reachability, listener, TLS, HTTP, or backend health.

### 2. Error boundaries

No route is a local routing decision failure. Timeout is a named deadline without completion. Refused is active transport rejection, often no listener. Reset is an abort by an endpoint/intermediary. A TLS alert occurs during secure negotiation. HTTP 503/504 mean an HTTP component responded; their exact upstream meaning depends on that component.

### 3. Node versus Pod

They can have different namespace, source address, DNS, proxy variables, route, policy, CNI path, Service translation, sidecar, and identity. Compare them to locate divergence.

### 4. Route lookup

It reports the local kernel route decision for supplied context. It does not send a packet or prove neighbor resolution, downstream policy, NAT, destination acceptance, or return path.

### 5. First byte

It is client-observed cumulative time until the first response byte. It can include proxy queue, upstream connect/TLS, application queue/compute, dependency time, buffering, and network return—not one server CPU phase.

### 6. Endpoint versus Service

When the same protocol/hostname/port and policy context are controlled, endpoint success plus Service failure focuses attention on virtual-IP translation, proxy/eBPF programming, target-port mapping, or path-specific policy. The tests often differ in destination identity, hostname, TLS, and policy, so inspect those before claiming cause.

### 7. Recovery

Verify the original user operation, correct response/data, representative latency, errors/timeouts, retry rate, queues/connections, all affected cohorts, healthy controls, and stability through the recurrence window. Confirm the mitigation preserved security and was reconciled into declared state.

## Product-company interview

Scenario: one Kubernetes Pod times out reaching a Service; node access works, other Pods work, and direct endpoint access from the affected Pod succeeds.

A strong response says the evidence focuses the investigation but does not finish it. It:

1. preserves the affected Pod and records revision, node, namespace, labels, service account, sidecar, URL, timer, and recent change;
2. compares affected and healthy Pods on same/different nodes;
3. validates DNS address/family and source route inside the affected namespace;
4. compares egress and ingress NetworkPolicy selection;
5. checks Service cluster IP, port/name/protocol/targetPort/selectors and EndpointSlice readiness;
6. controls hostname/TLS/policy differences between direct and Service tests;
7. inspects node CNI/proxy/eBPF/conntrack programming only if scope points there;
8. verifies destination arrival/listener/app and applies one reversible owned correction;
9. retests Service and user journey, then prevents drift with conformance and observability.

Weak answers restart the Pod, CoreDNS, or kube-proxy; flush conntrack; disable policy; or claim direct endpoint success proves the application and whole network are healthy.

## Independent transfer and rubric

`ASM-0276` supplies an unfamiliar client/proxy/server evidence set. Without a model answer, submit:

- environment and request identity card;
- annotated request/return path and ownership map;
- timeline naming last successful and first failed gates;
- normalized DNS, route, transport, TLS, HTTP, application, and dependency evidence with proof limits;
- four hypotheses with supporting/rejecting/missing evidence;
- one bounded recovery with prediction, authority, abort, rollback, security invariant, and user verification;
- prevention and assistance disclosure.

The reviewer scores safety/provenance, path model, evidence reasoning, recovery, and transfer. Reading a diagnosis or receiving guided solution invalidates independence; practice and retry on a fresh case.

## References and review

- `REF-1221`: Linux `ip-route(8)` for route lookup fields and scope.
- `REF-1222`: Linux `ss(8)` for socket-state inspection.
- `REF-1223`: curl upstream manual for verbose operation, timers, and bounded requests.
- `REF-1224`: OpenSSL `s_client` documentation for SNI, verification, and negotiation.
- `REF-1225`: RFC 9293 for TCP state and transport behavior.
- `REF-1226`: RFC 9110 for HTTP semantics and status ownership.

Claims are paraphrased. Local versions and platform implementation documentation govern exact output and behavior. Formal review, representative traces, browser QA, independently reviewed transfer, delayed recall, and mastery remain open.

One final rule: a working hop does not prove the next hop, and a failed hop does not authorize a broad change. Trace, compare, predict, change narrowly, and verify the user.
