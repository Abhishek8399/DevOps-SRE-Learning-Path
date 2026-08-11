# Hybrid connectivity: make every boundary explicit

Private connectivity is not automatically trusted connectivity. A reliable design names the route, identity, policy, failure owner, and observable proof at every boundary.

```text
workload -> subnet -> firewall/policy -> tunnel/private link -> route domain -> service
    |          |            |                   |                  |            |
 identity   source       allow/deny         encryption          next hop      response
```

## The operator model

For every flow, record source identity and address, destination identity and address, protocol/port, route selected, policy decision, encryption boundary, and return path. If one field is unknown, say “unknown”; do not call the path healthy from a single successful probe.

## VPN, private link, and transit

A site-to-site VPN joins routed networks through encrypted tunnels but still depends on underlay reachability, selectors, MTU, routing, and tunnel health. A private-link pattern publishes a specific service privately without exposing an entire network; it changes DNS, identity, and ownership boundaries. A transit hub centralizes routing and inspection but can become a blast-radius and capacity boundary. Choose based on required reachability, isolation, operations, and failure containment—not brand names.

## Zero-trust decisions

Zero trust means each request is authenticated and authorized using context; it does not mean “deny everything and hope.” Separate network reachability from application authorization. A reachable port proves only that packets can arrive. The service still needs identity, audience, action, resource, tenant, expiry, and audit checks.

## Failure reasoning

Selective failure is valuable evidence. If small responses work but large ones fail, inspect MTU, fragmentation, tunnel overhead, and middlebox behavior. If one direction works, inspect asymmetric routing, stateful firewalls, and return routes. If IP works but the name fails, inspect split DNS and search-domain ownership. If a tunnel is “up” but users fail, prove the complete request path.

## Safe local exercise

Use a disposable network namespace pair and a loopback HTTP server. Add an explicit route, inspect both route tables, and use a documented read-only policy model to classify the flow. Change only the fixture namespace, capture the before/after route and response evidence, then delete the namespaces. No host firewall or production route may be changed.

## Interview defense

**Question:** “A private service works from one subnet but not another. What is your order?”

**Strong answer:** “I compare source identity, DNS answer, route selection, tunnel/private-link state, policy decision, MTU, and return path from both subnets. I test a known-safe endpoint and correlate flow logs with service logs. I change the smallest scoped control only after identifying the first boundary where evidence diverges.”

**Question:** “Does a VPN make a network zero trust?”

**Strong answer:** “No. It encrypts and routes selected traffic. Authorization still belongs to identity-aware policy at the service boundary, with least privilege, expiry, audit, segmentation, and independent revocation.”

## Teach-back checkpoint

Draw one request path across a private link or VPN. Label the route, identity, policy, encryption, owner, and return path. Then explain what evidence would distinguish DNS failure, route failure, policy denial, MTU trouble, and application rejection.
