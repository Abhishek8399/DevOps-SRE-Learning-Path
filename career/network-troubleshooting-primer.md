# Network troubleshooting: follow the request path

“The service is down” is a symptom. A request crosses naming, routing, transport, encryption, proxy, and application boundaries; find the first boundary where healthy evidence disappears.

```text
name -> address -> route -> TCP -> TLS -> HTTP/proxy -> application -> dependency
 |        |         |       |      |        |              |              |
DNS     answer    next-hop  state  trust   status       logs/SLI        outcome
```

## Test one layer at a time

Resolve the name and record all answers and TTL. Check the selected route and source address. Test TCP reachability and connection timing. Inspect TLS identity, SNI, trust, and clock. Then inspect HTTP status, headers, redirects, proxy behavior, and application logs. A successful lower-layer probe does not prove the next layer.

## Selective failures are clues

One client, region, address family, payload size, or HTTP method failing narrows the search. Compare IPv4/IPv6, direct/proxy paths, small/large responses, and both directions. Consider MTU, asymmetric routing, stateful middleboxes, connection pools, DNS caches, and proxy limits before changing application code.

## Safe commands

Use read-only evidence such as `getent hosts`, `dig`, `ip route get`, `ss -tn`, `curl -v --max-time`, and `openssl s_client` against a disposable or approved endpoint. Record command, timestamp, source context, and result. Avoid packet capture or firewall changes unless the exercise explicitly scopes them.

## Safe local exercise

Run a local HTTP server and query it by loopback name and address. Compare a good path with a wrong port, missing name, and delayed response. Record DNS, route, socket, TLS (if enabled), HTTP, and application evidence. Stop the fixture and confirm the port is released.

## Triage sequence

1. Define the user operation, source, destination, time window, and exact symptom.
2. Compare a known-good control path and resolve naming first.
3. Walk route, transport, TLS, proxy, HTTP, and application boundaries in order.
4. Preserve timing and IDs; do not infer packet loss from one timeout.
5. Change the smallest scoped control, then verify the complete user journey.

## Interview defense

**Question:** “DNS resolves and ping works, but HTTPS fails. What next?”

**Strong answer:** “Ping is weak evidence. I check TCP connection timing, destination port, route/source, TLS SNI/SAN/trust/clock, proxy behavior, and HTTP response with a verbose bounded client. I compare from the affected source and preserve evidence before changing policy.”

**Question:** “Small responses work but large ones time out. Why?”

**Strong answer:** “I investigate MTU and fragmentation, tunnel overhead, proxy/body limits, buffering, congestion, and asymmetric paths. I compare payload sizes and both directions, then validate the complete request after the smallest safe fix.”

## Teach-back checkpoint

Draw the request path and explain what each of DNS, route, TCP, TLS, HTTP, and application evidence proves—and what it cannot prove.
