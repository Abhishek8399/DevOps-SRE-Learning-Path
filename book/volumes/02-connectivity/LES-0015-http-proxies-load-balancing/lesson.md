---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0015",
  "aliases": ["V02-L04", "http-proxies-load-balancing"],
  "curriculumIds": ["NET-005"],
  "slug": "http-proxies-load-balancing",
  "route": "/book/connectivity/http-proxies-load-balancing",
  "order": 4,
  "volume": "02-connectivity",
  "title": "HTTP, proxies, caching, and load balancing: follow the request, not the green light",
  "summary": "Trace one HTTP operation through semantics, version translation, trusted proxies, cache selection, routing, health, retries, deadlines, connection pools, queues, overload, rollout, rollback, and end-to-end verification without mistaking a status code or green probe for root cause.",
  "domain": "connectivity",
  "level": {
    "from": "foundation",
    "to": "advanced"
  },
  "estimatedMinutes": 420,
  "prerequisiteLessonIds": ["LES-0013", "LES-0014"],
  "prerequisiteCurriculumIds": ["NET-003", "NET-004"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "Host observations are read-only and require an explicitly authorized endpoint. The required lab runs as a normal user with Bash and Python 3.8 or newer, deterministic virtual evidence, one guarded UID-scoped directory under /tmp, no real listener or HTTP request, no package installation, and no network, proxy, firewall, or kernel mutation."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The offline lab is supported. A service bound inside WSL and a service bound on Windows occupy different process and network boundaries; interpret localhost, socket, and proxy evidence in the exact environment where the client ran."
    },
    {
      "platform": "Containers, Kubernetes, on-premises load balancers, private cloud, and public cloud",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Transfer sections map HTTP and capacity principles to these platforms. The lesson does not create a container, cluster, load balancer, DNS record, cloud resource, certificate, security rule, or paid service."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "private-cloud-engineer",
    "network-reliability-engineer",
    "data-platform-engineer"
  ],
  "learningObjectives": [
    "Explain an HTTP operation as method, target, fields, content, representation, status, and application contract while keeping semantics separate from HTTP/1.1, HTTP/2, and HTTP/3 framing and transport.",
    "Use method safety, idempotency, conditional requests, and application idempotency keys to decide whether an automatic retry is eligible rather than assuming every read or error is replay-safe.",
    "Distinguish forward and reverse proxies, L4 connection distribution, L7 request routing, original requests, upstream attempts, health probes, connection pools, streams, pending queues, and origin work by owner and unit.",
    "Design and diagnose cache eligibility, cache keys, Cache-Control, Vary, freshness, Age, validators, Authorization handling, invalidation, and tenant isolation before optimizing hit rate.",
    "Interpret status codes, response issuers, hop-by-hop and end-to-end fields, forwarding identity, request IDs, and trace context without trusting unverified client input or leaking sensitive data.",
    "Estimate origin demand and in-flight work from original rate, cache miss fraction, attempt amplification, service time, failure distribution, and safety headroom while stating assumptions and tail-risk limits.",
    "Diagnose pool exhaustion, queue growth, overload, retry storms, false health, uneven routing, stale or incorrect responses, and version-boundary failures using the first healthy-input and abnormal-output method.",
    "Plan bounded mitigation, canary rollout, drain, rollback, recovery verification, alerting, security, and prevention for local, container, Kubernetes, load-balancer, and cloud request paths."
  ],
  "productionSignals": [
    "A client receives 502, 503, or 504, but the origin process is running and every target is green.",
    "Direct origin requests work while the same method and target fail through a reverse proxy or load balancer.",
    "One tenant receives another tenant's otherwise valid 200 response from a shared cache.",
    "Original request rate is flat while upstream attempt rate, connection churn, queue wait, and dependency load rise sharply.",
    "A rollout changes connection reuse, HTTP version, health behavior, header normalization, cache policy, or retry semantics without changing application code.",
    "The proxy connection pool and pending queue are full even though host CPU and the number of healthy backends look normal.",
    "A cache has a high hit ratio but serves stale, variant-wrong, authorization-unsafe, or semantically incorrect representations.",
    "A Kubernetes Service or cloud load balancer reaches some endpoints, yet locality, readiness, affinity, drain, or zone failure makes the user path uneven."
  ],
  "diagrams": [
    {
      "id": "LES-0015-DIA-001",
      "title": "One user request becomes work at several independently owned boundaries",
      "direction": "left-to-right",
      "boundaries": ["client operation", "transport and TLS edge", "trusted identity normalization", "L7 routing and policy", "cache lookup", "upstream pool and pending queue", "origin worker and dependency", "response and client validation"],
      "evidencePoints": ["method, target, deadline", "connection and protocol version", "authenticated identity and forwarding chain", "route, retries, status issuer", "key, hit, age, validator", "acquire time, active connections, streams, queue", "service time, saturation, side effect", "status, fields, representation correctness"],
      "textAlternative": "A client operation crosses transport, trust, proxy policy, cache, connection-pool, queue, origin, and dependency boundaries before the client can validate the response; each boundary owns different evidence and can fail while adjacent boundaries remain healthy."
    },
    {
      "id": "LES-0015-DIA-002",
      "title": "Original demand can branch into cache service or amplified origin attempts",
      "direction": "top-to-bottom",
      "boundaries": ["original requests", "cache eligibility and lookup", "fresh reusable response", "miss or required validation", "one or more upstream attempts", "bounded pool and queue", "origin completion or overload"],
      "evidencePoints": ["requests per second", "eligible fraction and key", "hit ratio and Age", "validator and conditional status", "attempts per original", "concurrency and wait", "success, latency, cancellation, saturation"],
      "textAlternative": "Original request rate splits into cache hits and origin-bound misses; retries can multiply each miss into several attempts, so origin demand depends on miss fraction and average attempts rather than client requests alone."
    },
    {
      "id": "LES-0015-DIA-003",
      "title": "Health, routing, capacity, and correctness are separate questions",
      "direction": "hierarchical",
      "boundaries": ["process alive", "endpoint eligible for new traffic", "request admitted", "upstream resource acquired", "application and dependency complete", "correct representation or side effect returned", "user objective met"],
      "evidencePoints": ["liveness", "readiness and drain", "rate limit and load shed", "pool and queue", "service and dependency time", "status and content contract", "journey SLI"],
      "textAlternative": "A green liveness probe sits near the beginning of the path; it cannot prove routing eligibility, resource headroom, dependency completion, representation correctness, or the user's objective."
    },
    {
      "id": "LES-0015-DIA-004",
      "title": "A deadline is a shrinking budget, not a fresh timeout at every hop",
      "direction": "left-to-right",
      "boundaries": ["client overall deadline", "edge parsing and authentication", "proxy queue", "connection acquisition", "upstream processing", "dependency", "response transit"],
      "evidencePoints": ["remaining budget", "phase latency", "queue wait", "pool acquire time", "per-attempt time", "cancellation", "client-observed total"],
      "textAlternative": "Each phase consumes part of one overall deadline; giving every hop a new full timeout can let abandoned work continue and multiply latency and load beyond the caller's useful budget."
    }
  ],
  "commands": [
    {
      "id": "LES-0015-CMD-001",
      "question": "Which operating system, identity, tools, and network namespace define this observation?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -sr; id; readlink /proc/self/ns/net; command -v curl ss python3 bash",
      "runFrom": "The exact Ubuntu 24.04 or WSL 2 Ubuntu shell where the client operation occurs",
      "expectedBranches": [
        { "when": "The expected release, normal-user identity, namespace link, and tools appear", "meaning": "The observation baseline for this shell is known.", "nextEvidence": "Record whether the application or proxy shares this namespace and whether the target is explicitly authorized." },
        { "when": "Platform, privilege, namespace, or tools differ", "meaning": "The evidence boundary is different from the lesson baseline.", "nextEvidence": "Stop the required lab when a dependency or identity check fails; do not elevate or install automatically." }
      ],
      "proves": "The displayed platform, kernel, effective identity, current process namespace link, and command visibility at that moment.",
      "doesNotProve": "That a proxy or origin shares this namespace, that an endpoint is authorized or reachable, or that an HTTP operation succeeds."
    },
    {
      "id": "LES-0015-CMD-002",
      "question": "Which response status and fields does one authorized local operation return?",
      "risk": "sampled-read-only",
      "command": "curl --silent --show-error --dump-header - --output /dev/null --max-time 3 http://127.0.0.1:18080/health",
      "runFrom": "Only against an explicitly owned loopback test endpoint whose health contract permits GET",
      "expectedBranches": [
        { "when": "A response arrives", "meaning": "One HTTP operation returned a status line and response fields within three seconds.", "nextEvidence": "Identify the status issuer, decode fields, and test the actual user operation rather than promoting health to full readiness." },
        { "when": "Connect, timeout, protocol, or HTTP failure occurs", "meaning": "The operation failed at or after a client-visible boundary.", "nextEvidence": "Preserve stderr and exit status, then separate DNS, connect, TLS, proxy, pool, origin, and application phases." }
      ],
      "proves": "One client's response metadata for one authorized request under one deadline.",
      "doesNotProve": "Every endpoint, sustained capacity, body correctness, remote routing, cache safety, or root cause."
    },
    {
      "id": "LES-0015-CMD-003",
      "question": "Where did the client spend time during one HTTP request?",
      "risk": "sampled-read-only",
      "command": "curl --silent --show-error --output /dev/null --connect-timeout 1 --max-time 3 --write-out 'code=%{http_code} connect=%{time_connect} starttransfer=%{time_starttransfer} total=%{time_total}\\n' http://127.0.0.1:18080/health",
      "runFrom": "The same authorized client and loopback endpoint; preserve curl version because available timing fields vary",
      "expectedBranches": [
        { "when": "Connect is small but start-transfer is large", "meaning": "Transport establishment finished early and most visible wait occurred before first response bytes.", "nextEvidence": "Inspect proxy queue, pool acquire, origin processing, dependency, buffering, and remaining deadline." },
        { "when": "Connect or total reaches its bound", "meaning": "The client exhausted a configured phase or overall time budget.", "nextEvidence": "Correlate the same request at the preceding boundary; do not infer which hop was silent from client timing alone." }
      ],
      "proves": "Client-observed phase timestamps as defined by this curl build for one operation.",
      "doesNotProve": "Server-side phase ownership, DNS time when an IP literal is used, queue cause, or latency distribution."
    },
    {
      "id": "LES-0015-CMD-004",
      "question": "What request and response framing does curl expose for one sanitized local request?",
      "risk": "sampled-read-only",
      "command": "curl --verbose --max-time 3 http://127.0.0.1:18080/health --output /dev/null",
      "runFrom": "Only against an owned endpoint with no credential, token, cookie, personal data, or production hostname",
      "expectedBranches": [
        { "when": "Request and response lines are shown", "meaning": "The client emitted and received the displayed protocol metadata.", "nextEvidence": "Sanitize before sharing; correlate with proxy logs by a safe request identifier." },
        { "when": "No response metadata appears", "meaning": "The request failed before that output became available or curl did not run.", "nextEvidence": "Use exit status and phase timing to choose the previous boundary." }
      ],
      "proves": "What this client reports sending and receiving for one operation.",
      "doesNotProve": "What every intermediary forwarded, whether fields were normalized, or application correctness."
    },
    {
      "id": "LES-0015-CMD-005",
      "question": "Does a HEAD operation follow the endpoint's documented contract?",
      "risk": "sampled-read-only",
      "command": "curl --silent --show-error --head --max-time 3 http://127.0.0.1:18080/resource",
      "runFrom": "Only when the owned endpoint documents HEAD or generic HTTP semantics are intentionally being tested",
      "expectedBranches": [
        { "when": "HEAD returns expected metadata without response content", "meaning": "The endpoint implemented this HEAD sample consistently with its contract.", "nextEvidence": "Do not treat it as proof that GET content or downstream side effects are correct." },
        { "when": "HEAD differs or is unsupported", "meaning": "Implementation or route policy differs for HEAD.", "nextEvidence": "Use the documented method; do not turn a monitoring convenience into an undocumented requirement." }
      ],
      "proves": "One HEAD response and its selected representation metadata.",
      "doesNotProve": "GET body correctness, cache safety, application readiness, or that HEAD is cheaper internally."
    },
    {
      "id": "LES-0015-CMD-006",
      "question": "Will the server or cache validate a known representation instead of transferring it again?",
      "risk": "sampled-read-only",
      "command": "curl --silent --show-error --dump-header - --output /dev/null --max-time 3 --header 'If-None-Match: \"reviewed-etag\"' http://127.0.0.1:18080/resource",
      "runFrom": "An owned endpoint using an ETag copied from that same resource and authorization context; replace the teaching placeholder deliberately",
      "expectedBranches": [
        { "when": "304 Not Modified returns", "meaning": "The selected representation's validator matched under this request context and no response content was needed.", "nextEvidence": "Check which cache or origin validated it, Age and Vary behavior, and whether the stored representation is correct." },
        { "when": "200 or another status returns", "meaning": "The validator did not produce a 304 for this selection or another condition took precedence.", "nextEvidence": "Compare ETag, target, authorization context, Vary fields, freshness, and issuer." }
      ],
      "proves": "The outcome of one conditional request using the supplied validator.",
      "doesNotProve": "That the stored body is safe, every variant uses that validator, or all caches honor policy correctly."
    },
    {
      "id": "LES-0015-CMD-007",
      "question": "What happens when this request asks caches to validate before reuse?",
      "risk": "sampled-read-only",
      "command": "curl --silent --show-error --dump-header - --output /dev/null --max-time 3 --header 'Cache-Control: no-cache' http://127.0.0.1:18080/resource",
      "runFrom": "An owned endpoint; understand that no-cache permits storage and requires validation rather than meaning never store",
      "expectedBranches": [
        { "when": "A validated response or revalidation evidence appears", "meaning": "The participating cache handled the request directive for this operation.", "nextEvidence": "Identify cache status, validator, response directives, and issuer." },
        { "when": "Behavior does not change", "meaning": "No cache participated, policy overrode the request, or evidence is insufficient.", "nextEvidence": "Inspect trusted cache telemetry and response directives instead of repeating requests blindly." }
      ],
      "proves": "One response after a client cache request directive.",
      "doesNotProve": "Cache bypass, no storage, origin execution, freshness correctness, or tenant isolation."
    },
    {
      "id": "LES-0015-CMD-008",
      "question": "Which established TCP connections and queues are visible for an owned proxy process?",
      "risk": "sampled-read-only",
      "command": "ss -ntp state established",
      "runFrom": "The proxy's network namespace with authorization; process and endpoint details can be sensitive and permission-limited",
      "expectedBranches": [
        { "when": "Connections and queue values are visible", "meaning": "The namespace exposes sampled established transport state.", "nextEvidence": "Group by owner and destination; correlate active and idle pool connections, HTTP/2 streams, waiters, and request rate." },
        { "when": "No matching connection appears", "meaning": "The sample, namespace, permission, protocol, or timing may differ.", "nextEvidence": "Verify process namespace and application pool telemetry; absence is not proof of no traffic." }
      ],
      "proves": "Visible established TCP sockets and permitted process details at sample time.",
      "doesNotProve": "HTTP requests per connection, stream count, pool membership, user success, or historical saturation."
    },
    {
      "id": "LES-0015-CMD-009",
      "question": "What protocol socket summary is visible in this namespace?",
      "risk": "read-only",
      "command": "cat /proc/net/sockstat; cat /proc/net/sockstat6",
      "runFrom": "The investigated Linux network namespace",
      "expectedBranches": [
        { "when": "Socket or memory counts rise with the incident", "meaning": "Kernel-visible transport population or memory changed in this scope.", "nextEvidence": "Map the population to proxy pool, client churn, process descriptors, cgroup memory, and protocol behavior." },
        { "when": "Counts remain stable", "meaning": "This summary shows no sustained change during the samples.", "nextEvidence": "Check request-level streams, queues, caches, another namespace, and shorter bursts." }
      ],
      "proves": "Sampled kernel protocol socket counters in the visible namespace.",
      "doesNotProve": "Per-request ownership, HTTP/2 stream concurrency, pool wait, leak identity, or safe tuning."
    },
    {
      "id": "LES-0015-CMD-010",
      "question": "How many descriptors does the current shell hold and what limits apply to it?",
      "risk": "read-only",
      "command": "ulimit -Sn; ulimit -Hn; find /proc/$$/fd -mindepth 1 -maxdepth 1 -printf '.' | wc -c",
      "runFrom": "The current shell; inspect another process only with authorization and its actual service launch context",
      "expectedBranches": [
        { "when": "Usage is near the soft limit", "meaning": "Descriptor headroom may be a local process boundary.", "nextEvidence": "Measure the actual proxy PID, classify descriptor types, and correlate allocation errors." },
        { "when": "Headroom is large", "meaning": "This shell's descriptor limit is not exhausted.", "nextEvidence": "Do not transfer the conclusion to the proxy; check its process, cgroup, pool, and queue boundaries." }
      ],
      "proves": "The current shell's configured descriptor limits and a racy count of its descriptor entries.",
      "doesNotProve": "Proxy limits, socket-only count, system-wide file-table headroom, or absence of a brief peak."
    },
    {
      "id": "LES-0015-CMD-011",
      "question": "Can one owned hostname be forced to one loopback address without changing DNS?",
      "risk": "sampled-read-only",
      "command": "curl --silent --show-error --dump-header - --output /dev/null --max-time 3 --resolve service.test:18080:127.0.0.1 http://service.test:18080/health",
      "runFrom": "An owned loopback test service that expects the service.test authority; never substitute a production host casually",
      "expectedBranches": [
        { "when": "The operation succeeds", "meaning": "This client used the supplied address mapping and completed one HTTP operation with the specified authority.", "nextEvidence": "Compare with the normal DNS path if DNS or virtual-host routing is the tested variable." },
        { "when": "It fails", "meaning": "DNS was bypassed, but transport, authority routing, proxy, or application behavior still failed.", "nextEvidence": "Preserve phase, status, and listener evidence; do not declare DNS causal." }
      ],
      "proves": "One request outcome with curl's per-command name-to-address override.",
      "doesNotProve": "System DNS correctness, other clients, TLS name validation for HTTPS, production routing, or capacity."
    },
    {
      "id": "LES-0015-CMD-012",
      "question": "Can the deterministic lesson exercise both incidents and every guard from clean state?",
      "risk": "mutating-bounded",
      "cleanup": "The verifier invokes guarded cleanup for each case and refusal test; the final `bash lab.sh check` must report `state=absent`. If any guard refuses, stop and inspect rather than deleting state manually.",
      "command": "bash lab.sh check; bash verify.sh; bash lab.sh check",
      "runFrom": "book/labs/LES-0015-http-path as a normal non-root Ubuntu 24.04 or WSL 2 Ubuntu user",
      "expectedBranches": [
        { "when": "The verifier reports verification_passed=true and final check reports state=absent", "meaning": "The deterministic model lifecycle, prediction gate, refusal tests, both cases, and cleanup passed in this environment.", "nextEvidence": "Complete the independent reasoning artifact; script success does not award mastery." },
        { "when": "Any guard refuses or a test fails", "meaning": "The lab contract or environment is not proven.", "nextEvidence": "Stop and inspect the first failure; never use sudo, manual state edits, or broad deletion to force success." }
      ],
      "proves": "Only the tested offline model behavior, guard boundaries, and cleanup in this run.",
      "doesNotProve": "A real HTTP server, proxy, cache, Kubernetes Service, cloud load balancer, production capacity, or learner mastery."
    }
  ],
  "labs": [
    {
      "id": "LES-0015-LAB-001",
      "title": "Diagnose a modeled retry, pool, queue, and health incident without generating traffic",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with Bash and Python 3.8 or newer",
      "timeMinutes": 60,
      "privilege": "Normal user only; root is refused",
      "network": "None; deterministic virtual HTTP evidence only",
      "changes": ["One validated UID-scoped descriptor directly under /tmp", "One validated private lesson directory directly under /tmp", "Small immutable or guarded allowlisted records inside that directory"],
      "abortConditions": ["Effective UID is zero", "/tmp is not a real root-owned sticky directory", "A dependency is missing", "Any path, owner, link count, mode, manifest, fixture, record, artifact allowlist, or lifecycle check refuses"],
      "recovery": "Use only bash lab.sh recover after evidence-based diagnosis, then bash lab.sh verify-operation and bash lab.sh cleanup; never edit or recursively delete discovered state.",
      "cleanupProof": "Cleanup revalidates the descriptor, exact root, sentinel, manifest, fixture, records, owners, modes, links, and allowlist before deleting exact files and the empty root; a following check reports state=absent.",
      "path": "book/labs/LES-0015-http-path"
    },
    {
      "id": "LES-0015-LAB-002",
      "title": "Independent HTTP correctness and capacity localization with answer-isolated evidence",
      "mode": "independent",
      "environment": "A clean normal-user Ubuntu 24.04 or supported WSL 2 Ubuntu shell",
      "timeMinutes": 90,
      "privilege": "Normal user only; no sudo, capabilities, namespace entry, runtime socket, or service mutation",
      "network": "None; the independent case does not create or contact an endpoint",
      "changes": ["The same guarded lesson state boundary", "A neutral independent case identifier", "Learner notes outside lab state and never read by the verifier"],
      "abortConditions": ["Any guard refuses", "Scenario predictions were not written before observe", "Fixture source or another answer was read before submission", "A second case or unsupported path is attempted"],
      "recovery": "Choose the supported modeled recovery only after ranking mechanisms and locating the first divergence; verify both contexts and capacity separately before cleanup.",
      "cleanupProof": "The verifier exercises guided and independent cases, the scenario-before-observation contract, invalid transitions, unexpected artifact, changed model, symlink descriptor, out-of-scope descriptor, orphan refusal, final absence, and no network mutation.",
      "path": "book/labs/LES-0015-http-path"
    }
  ],
  "incidents": [
    {
      "id": "LES-0015-INC-001",
      "signal": "After a proxy policy rollout, original traffic remains 900 requests per second but upstream attempts reach 2,250 per second; the upstream pool and pending queue are full, reuse falls, 503 rises, and every backend still passes /live.",
      "firstThought": "Treat original requests, retries, connections, queue entries, health operations, and origin work as different units; find which changed policy multiplied attempts or increased residence time before changing capacity.",
      "safePath": "Preserve the rollout diff and time-aligned user, proxy, pool, queue, origin, dependency, and health evidence; compute 2.5 attempts per original; bound retries and admission; roll back the suspect policy through the approved path; verify the same operation, attempt ratio, latency, pool and queue headroom, and dependency health.",
      "trap": "Increasing pool, queue, timeout, and retry limits together because the proxy is saturated, thereby moving unbounded work into the origin and erasing the causal signal."
    },
    {
      "id": "LES-0015-INC-002",
      "signal": "A tenant receives HTTP 200 quickly, but the account representation belongs to a different tenant; the response is a shared-cache hit, the key records only scheme, authority, and target, Vary names only content encoding, and origin capacity is healthy.",
      "firstThought": "Availability is not correctness. Treat this as a possible data-integrity and confidentiality incident, stop unsafe reuse at the cache boundary, preserve sanitized evidence, and test representation selection across security contexts.",
      "safePath": "Disable or bypass the affected shared-cache route through an approved narrow change; invalidate exposed entries with reviewed scope; verify authentication and authorization; inspect Cache-Control, Vary, key dimensions, forwarding trust, and origin metadata; replay both contexts; rotate or notify only under the incident policy; restore caching only after negative isolation tests.",
      "trap": "Calling the 200 response healthy, purging one URL without repairing key policy, adding an untrusted client header to the key, or hiding the issue because latency and hit rate look excellent."
    }
  ],
  "assessmentIds": ["ASM-0028", "ASM-0029", "ASM-0030"],
  "referenceIds": ["REF-0073", "REF-0074", "REF-0075", "REF-0076", "REF-0077", "REF-0078", "REF-0079", "REF-0080"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The required lab is a deterministic offline model. It does not create a socket, send HTTP, operate a proxy or cache, measure an Ubuntu TCP stack, or prove behavior of Kubernetes, a load balancer, a cloud service, or production traffic.",
    "HTTP fields, proxy metrics, retry conditions, cache behavior, health semantics, protocol support, and command output vary by implementation and version; verify against the deployed product's official documentation and configuration.",
    "The lesson does not teach TLS and PKI internals, DNS internals, packet capture, eBPF, vendor-specific load-balancer administration, production cache purge, or cluster mutation; those require separate lessons and authorization.",
    "Capacity examples teach dimensional reasoning rather than product limits. Real sizing requires measured distributions, failure testing, safety margins, dependency budgets, and reviewed rollback plans.",
    "Completing, reading, or publishing the lesson does not award mastery; independent artifacts, delayed recall, unfamiliar transfer, and human review remain required."
  ]
}
---

# HTTP, proxies, caching, and load balancing: follow the request, not the green light

## What you see and first thought

A dashboard says all targets are healthy. The caller says checkout returns `503`. Another engineer says the origin works when called directly. The proxy pool is full. Someone proposes four immediate changes: increase the pool, increase the queue, add two retries, and make the timeout longer.

Pause there. Those four changes alter four different state budgets at once. If the service recovers, you will not know which mechanism mattered. If the origin collapses, you will have amplified the incident. Your first job is not to make every number larger. Your first job is to preserve the exact user operation and follow it until healthy input becomes abnormal output.

Keep this sentence:

> HTTP success is not “a port opened” or “a green target.” It is the correct operation, for the correct identity, producing the correct representation or side effect inside the promised deadline.

Write these facts before opening a dashboard:

1. Who made the request, from which client and security context?
2. What method, scheme, authority, path, query, fields, and content formed the operation?
3. What overall deadline and retry contract applied?
4. Which intermediary issued the observed status?
5. Was the response served from cache, generated by an origin, or synthesized by a proxy?
6. Was the result merely available, or also correct for this identity and business operation?
7. Did all clients fail, one protocol version fail, one zone fail, or one route fail?
8. Which configuration or deployment changed before the first bad sample?

The word “HTTP” often hides an entire architecture. A client may speak HTTP/3 over QUIC to an edge, the edge may speak HTTP/2 to a reverse proxy, and the proxy may reuse HTTP/1.1 connections to an origin. The semantics can remain one GET operation even though framing, transport connections, multiplexing, and failure signals change at each hop.

### Status codes are clues with issuers

A client-observed `503` means the response says the service is temporarily unable to handle the request. It does not tell you which component created that response. An edge, reverse proxy, application, maintenance layer, or service mesh can issue it. A `504` usually points to a gateway waiting too long for an upstream response, but you still need the gateway's timeout phase and logs. A `502` says a gateway or proxy could not use the upstream response, but not whether the cause was connection reset, invalid framing, protocol translation, or another failure.

A `200` is not sacred. A fast `200` containing another tenant's data is a security incident. A `200` with a stale price can be a correctness incident. A `200` from `/live` says only that the probe's narrow success condition passed.

### The learning contract

This chapter moves from a raw HTTP message to a multi-hop production path. Commands are decoded rather than presented as magic. The required lab is offline and deterministic so it cannot accidentally hit a real endpoint or generate a retry storm. That safety means the lab proves reasoning mechanics, not production behavior. Mastery still requires later real-system evidence in an authorized disposable environment.

## Terms before commands

**HTTP** is an application-layer protocol with defined semantics for requests and responses. Semantics answer questions such as “What does GET mean?”, “May this operation be retried?”, “What does 304 mean?”, and “Which response metadata describes the selected representation?” Wire framing answers a different question: how those semantics are encoded and carried by HTTP/1.1, HTTP/2, or HTTP/3.

**Request method** states the requested action semantics. Common methods include GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, and TRACE. PATCH is defined separately from the core semantics specification and is not inherently idempotent.

**Request target** identifies what the request applies to. In ordinary origin requests it is commonly a path plus optional query. Proxies can use other forms. Do not casually rewrite paths, queries, or authorities; they participate in routing, signatures, cache keys, and authorization.

**Field** is HTTP's modern term for named metadata commonly called a header. Fields carry representation metadata, cache policy, conditional validators, authorization credentials, content negotiation, forwarding information, and connection behavior. Field names are case-insensitive, but field values have field-specific parsing rules; blindly joining duplicates with commas is unsafe for fields whose grammar does not permit it.

**Content** is the sequence of octets in a message after framing is removed. It is not always the same as the selected representation: a response can carry a partial range, an encoded form, or no content at all. HEAD describes what a corresponding GET would have returned without transferring response content. `204 No Content` has its own semantics.

**Representation** is information reflecting the current or desired state of a resource in a form selected for the request. Media type, content encoding, language, and validators help describe it. Two requests for the same path can legitimately select different representations.

**Origin server** is the authoritative server for a target resource. In practice an application tier may act as the origin even when it depends on databases and other services.

**Intermediary** is a component between user agent and origin: proxy, gateway, tunnel, cache, or similar participant. An intermediary can forward, transform, reject, retry, cache, or synthesize a response according to its contract.

**Forward proxy** acts on behalf of clients toward destinations. Corporate egress proxies and explicit browser proxies are examples. The destination may see the proxy as its peer.

**Reverse proxy** acts on behalf of one or more origins toward clients. It may terminate TLS, authenticate, route, balance, cache, retry, rate-limit, compress, or observe requests. The client may believe it is speaking directly to the service authority.

**L4 load balancer** makes decisions mainly from transport and network properties such as source and destination address and port. It owns connections or flow mappings, not necessarily HTTP message semantics.

**L7 load balancer** parses HTTP and can route by authority, path, method, fields, or other request properties. That power makes it an owner of parsing security, header trust, retries, caching, status generation, and request-level observability.

**Safe method** is intended to be read-only from the user's requested semantics. GET, HEAD, OPTIONS, and TRACE are defined as safe. Logging and billing can still happen internally, but a crawler following GET links must not trigger destructive business actions.

**Idempotent method** has the same intended effect when the same request is applied once or several times. Safe methods plus PUT and DELETE are idempotent by HTTP semantics. Idempotent does not mean the responses are byte-identical, the operation is free, or infinite automatic retries are safe.

**Application idempotency key** is a client-chosen operation identity that a server durably uses to deduplicate replays and return the original outcome. It is essential for many retryable state-changing POST operations. A field without atomic server-side storage and conflict rules is only a label, not idempotency.

**Cache** stores responses so later requests might be satisfied without forwarding a new request to the origin. A private cache serves one user agent; a shared cache serves multiple users. Shared caches cross security contexts and demand stricter eligibility and key design.

**Cache key** selects stored responses. The primary key includes request method and target URI in HTTP caching semantics, while implementations add selected fields and policy dimensions. If representation or authorization depends on a dimension absent from the key or `Vary` handling, a correct response can be returned to the wrong request.

**Freshness** is whether a stored response may be reused without contacting the origin. Freshness lifetime comes from explicit directives or, where permitted, heuristics. `Age` communicates an estimate of how long a response has been resident along the cache path; it is not creation time or proof of correctness.

**Validator** lets a recipient ask whether its stored representation is still current. An entity tag in `ETag` is an opaque validator; `Last-Modified` can be used as a date validator. A matching conditional GET can return `304 Not Modified`, allowing reuse of stored content.

**`Cache-Control: no-store`** requests that caches not store the message. **`no-cache`** allows storage but requires successful validation before reuse. **`private`** restricts a response to private caches. These are not synonyms.

**`Vary`** tells caches which request fields participated in selecting the representation. `Vary: Accept-Encoding` separates compressed variants. If tenant or authorization context selects data, casually adding a spoofable tenant field to `Vary` is not enough; authentication, cache eligibility, and key trust must be designed together.

**Health check** is one synthetic operation. Liveness asks whether restart is justified. Readiness asks whether new traffic should be routed. Startup protects slow initialization. A deep external journey checks user experience but may be too coupled to control routing safely.

**Connection pool** is a bounded set of upstream transport connections managed for reuse. **Pending queue** holds requests waiting for connection or dispatch capacity. HTTP/2 can multiplex several streams on one connection, so connection count and request concurrency are different units.

**Deadline** is the latest useful completion time for an operation. A **timeout** is one mechanism for enforcing a phase or overall deadline. Each hop should consume the same shrinking budget, not start an independent full timeout that lets abandoned work continue.

**Retry** is another attempt for one original operation. Original-request rate and upstream-attempt rate must be separate metrics. **Retry amplification** is attempts divided by originals. At 2.5 attempts per original, the system adds 150% extra attempt load.

**Backpressure** makes overload visible upstream so senders slow or stop. **Load shedding** rejects work deliberately when capacity or remaining deadline is insufficient. A bounded early rejection is often more reliable than accepting work into an unbounded queue.

## Architecture map

Use this map before choosing commands:

```text
user intent
  |
  |  method + target + identity + deadline + idempotency contract
  v
client HTTP implementation
  |
  |  DNS -> transport -> TLS -> HTTP/1.1, HTTP/2, or HTTP/3
  v
[L4 edge / connection distribution]
  |
  v
[trusted L7 edge]
  |-- normalize framing
  |-- authenticate / authorize
  |-- replace untrusted forwarding identity
  |-- create bounded request correlation
  |-- route / rate-limit / retry policy
  v
[cache lookup]
  |                 \
  | fresh safe hit   \ miss or validation
  v                   v
response          [upstream connection pool]
                        |
                        | idle connection, new connection, or wait
                        v
                  [bounded pending queue]
                        |
                        v
                  [origin worker]
                        |
                        v
                  [database / service / queue]
                        |
                        v
                  status + fields + content
                        |
                        v
client validates identity, representation, side effect, and deadline
```

Text alternative: one operation crosses a client, connection distribution, trusted HTTP policy, cache, pool, queue, origin, and dependency. A cache hit can return before origin work. A miss can create one or more upstream attempts. The final result is successful only after the client validates the correct contract.

### Control plane and data plane

The **data plane** handles each live connection and request. It parses messages, performs lookups, chooses an endpoint, acquires a connection, queues work, forwards bytes, and returns a response.

The **control plane** supplies configuration and desired state: routes, backend membership, health thresholds, certificates, retry rules, cache policy, pool limits, endpoint weights, and rollout versions. A control-plane change can break the data plane without any application deployment. Preserve both configuration version and runtime observation during an incident.

### Ownership card

| Boundary | Owns | Strong evidence | Common false conclusion |
|---|---|---|---|
| Client | method, deadline, retry policy, validation | exit status, phase timing, sanitized trace | “Timeout means server was down” |
| L4 balancer | flow distribution and transport state | flow/connection counters, target mapping | “TCP connect proves HTTP health” |
| L7 edge | parsing, trust, routes, policy, status synthesis | request and attempt logs, route/config version | “503 came from the app” |
| Cache | eligibility, key, freshness, validator, stored response | hit/miss, key dimensions, Age, policy | “High hit rate means healthy” |
| Pool | upstream connections and waiters | active/idle, streams, acquire time, rejects | “More connections always fix it” |
| Origin | application execution and response | route latency, errors, saturation, logs | “200 means correct tenant” |
| Dependency | downstream work and state | query/service latency, capacity, correctness | “Proxy timeout is a proxy bug” |
| Orchestrator | endpoint eligibility and lifecycle | readiness, EndpointSlice, drain, rollout | “Ready means full journey healthy” |

### L4 and L7 can both exist

A cloud or data-center edge may distribute TCP or QUIC flows to L7 gateways. Those gateways then distribute HTTP requests to application endpoints. With HTTP/2, one client connection can carry many concurrent requests; one L4 choice may therefore pin considerable request load to one gateway. The gateway can redistribute upstream requests independently. Diagnose both distributions instead of saying “the load balancer.”

## Request or state path

Follow one operation in order.

### 1. Client constructs semantics

Suppose the operation is:

```text
GET /v1/account/summary HTTP/1.1
Host: api.example.test
Authorization: Bearer <redacted>
Accept: application/json
```

The method says retrieval. The authority and target identify the resource. Authorization establishes a security context when validated by the service. `Accept` can select a representation. The client also has an overall deadline even though it is not shown here. Never paste real credentials into a lesson, terminal history, issue, or trace.

### 2. Wire version carries the operation

HTTP/1.1 uses a textual message syntax and relies on correct message framing. Persistent connections can carry sequential operations; pipelining exists but is uncommon in many deployments. Conflicting or ambiguous length framing across two parsers can enable request smuggling, so trusted edges must reject ambiguity rather than “fixing” it differently downstream.

HTTP/2 represents fields in frames and multiplexes streams over a connection. Stream concurrency avoids HTTP/1.1 application-level head-of-line blocking between requests, but all streams still share the underlying TCP connection; packet loss can delay TCP delivery for that connection. HTTP/2 also has stream and connection flow control. A low connection count can hide very high stream and request concurrency.

HTTP/3 carries HTTP over QUIC. Independent QUIC streams reduce transport head-of-line coupling across streams, and connection identifiers can support connection migration behavior. It still does not remove application queues, origin limits, bad retries, cache mistakes, or dependency latency. An edge may terminate HTTP/3 and use HTTP/2 or HTTP/1.1 upstream.

The durable rule is:

```text
semantics may remain the same
framing + transport + connection ownership may change at every hop
```

### 3. Trusted edge normalizes identity and framing

The public edge is a trust boundary. A client can send `X-Forwarded-For`, `Forwarded`, `X-Request-ID`, or a tenant-looking field. Those values are input, not truth. The trusted edge should remove or replace fields whose authority begins there, then append a well-defined proxy chain where required. Downstream services should trust forwarding identity only from authenticated or network-controlled proxy peers.

Request IDs support correlation, not authorization. Generate one when missing, validate length and character set when accepting one, prevent header/log injection, and cap propagation. Trace context has similar trust and cardinality concerns. Never put credentials, full payment data, or unbounded user input into identifiers or metric labels.

### 4. Proxy selects route and policy

The proxy chooses a virtual host and route from normalized authority, path, method, and configured policy. It may authenticate, authorize, rate-limit, rewrite, redirect, retry, mirror, or reject. Record the route name and configuration version. A path rewrite error can send a correct request to a healthy but wrong origin.

### 5. Cache decides whether reuse is legal

The cache asks:

1. Is this method and response eligible for storage and reuse?
2. Does a stored key match the target and all required selection dimensions?
3. Is the entry fresh?
4. If stale, is a validator available and is validation required or allowed?
5. Do request directives, response directives, Authorization rules, and shared/private policy permit reuse?
6. Does the stored representation belong to this request's security and content-negotiation context?

A hit that fails question 6 is worse than a miss.

### 6. Proxy acquires upstream capacity

On a miss or validation, the proxy selects an endpoint, then reuses an idle connection, opens one within bounds, or waits. With HTTP/2 it may allocate a new stream on an existing connection subject to concurrent-stream and flow-control limits. Measure pool acquire time separately from origin response time.

If the pending queue is full, the proxy may reject. That early rejection can protect the origin. If the queue is huge, the request may wait beyond its useful deadline. A queue is not free capacity; it is stored waiting time plus memory and bookkeeping.

### 7. Origin and dependency execute

The origin authenticates or consumes trusted identity, authorizes the resource, runs application logic, and calls dependencies. A request can be idempotent at HTTP semantics but still meet a broken implementation. For POST payment creation, an idempotency key needs atomic storage of key, normalized request identity, operation state, and final outcome. Reusing a key with different content should be rejected by contract.

### 8. Response travels back

The response status has an issuer. Fields describe the representation, cache policy, validators, retry advice, and proxy handling. Hop-by-hop fields apply only to one connection and must not be forwarded as end-to-end metadata. The cache may store a permitted response. The client finally validates status, content type, schema, identity, business state, and elapsed time.

## Failure zoom

### Incident A: green health, full pool, rising 503

At 10:00 a proxy policy rollout begins. Incoming rate remains 900 original requests/s. Upstream attempts rise to 2,250/s. The 256-connection pool is fully in use, 512 pending slots are full, pool acquisition p95 is 505 ms, and reuse falls from 91% to 28%. Eight `/live` probes pass. The origin's measured sustainable rate for this scenario is 1,600 attempts/s.

Start with dimensions:

```text
attempt amplification = upstream attempts / original requests
                      = 2250 / 900
                      = 2.5 attempts per original

extra attempt load = 2250 - 900
                   = 1350 attempts/s
```

That calculation proves amplification at the measured boundary. It does not yet prove retries caused it; hedging, redirects, internal fan-out, or duplicate clients could also increase attempts. Compare the policy diff and classify attempt outcomes.

Now estimate in-flight work. If mean upstream residence reaches 450 ms:

```text
L approximately equals rate x time
L approximately equals 2250 attempts/s x 0.450 s
L approximately equals 1012.5 attempts in flight
```

A 256-connection HTTP/1.1 pool cannot carry that concurrency without waiting. If HTTP/2 is used, connections and streams differ, so use stream capacity and actual service behavior. The equation is an estimate under consistent boundaries and a sufficiently stable interval; it does not model tail distribution or burst shape.

Why can liveness remain green? Probe traffic is low, `/live` may do almost no work, a reserved health pool may exist, or probe deadlines may differ. A process can answer one lightweight route while checkout waits behind pool, worker, or dependency saturation.

The safe mitigation is to control added demand: roll back the suspect retry/reuse configuration, cap attempts with a retry budget, cancel abandoned work, and shed excess original requests before they enter a useless queue. Increasing pool size might help only if the origin has measured capacity and the pool was the causal bottleneck. Here origin attempts already exceed the stated capacity, so a larger pool can worsen it.

Recovery proof requires more than a falling 503 count:

- the same user operation succeeds with correct content;
- original rate and upstream attempt rate separate cleanly;
- amplification returns inside the declared retry budget;
- pool and pending queue regain sustained headroom;
- p95 and p99 stay inside the end-to-end deadline;
- origin and dependency saturation do not worsen;
- no duplicate state-changing effect appears;
- an unaffected route remains healthy;
- queues continue draining after the first green minute.

### Incident B: fast 200, wrong tenant

A tenant B request for `/v1/account/summary` returns in 7 ms with status `200`, but the representation contains tenant A's account label. Cache telemetry says `hit`; the key dimensions are scheme, authority, and target; `Vary` includes only `Accept-Encoding`; the response was marked shared-cache eligible for 300 seconds; Authorization was present.

Protect data first. Disable shared reuse for the affected route through the narrow approved policy, preserve sanitized key and response metadata, and start the security incident process. Do not celebrate the hit rate. Do not merely purge one object: the policy can repopulate it incorrectly on the next request.

Possible mechanisms include:

- missing authenticated tenant or authorization partition in cache policy;
- origin incorrectly marking a personalized response public;
- a proxy trusting a client-supplied tenant field;
- `Vary` or key normalization differing between lookup and storage;
- host or path normalization collision;
- cache poisoning through ambiguous parsing;
- application authorization failure even without cache.

The evidence that a cache served the response plus healthy origin capacity makes pool exhaustion weak. It does not by itself select among the cache and identity mechanisms. Trace the stored response provenance, authenticated context, trusted fields, key computation, response policy, and negative cross-tenant tests.

Recovery needs both tenant A and tenant B requests to return their own representation, repeated in both population orders, with unsafe shared hits absent. Verify unauthorized access remains denied. Restore caching only after a reviewed key and eligibility design, versioned rollout, and rollback test.

## Internals and state ownership

### HTTP methods: safety and idempotency are contracts

| Method | Safe | Idempotent | Typical cache status | Operational warning |
|---|---:|---:|---|---|
| GET | yes | yes | cacheable unless policy prevents it | Never put destructive action behind GET |
| HEAD | yes | yes | response can update stored GET metadata under rules | It can still execute expensive origin logic |
| POST | no | no by default | only when explicit freshness and keying permit | Use application idempotency for replayable creation |
| PUT | no | yes | responses are not generally reused like GET | Repetition may produce different audit timestamps |
| DELETE | no | yes | invalidates relevant cached responses | Repeated response codes can differ while effect is same |
| OPTIONS | yes | yes | usually operational rather than cached | Does not prove the real method is authorized or healthy |

Safety describes requested semantics. Idempotency describes intended effect. Neither promises zero logs, identical status codes, no cost, or flawless implementation. A retry policy also needs evidence that no response bytes or side effect created ambiguity, enough deadline remains, the failure is plausibly transient, and retry load fits a budget.

### Status classes and high-value codes

`1xx` is informational. `2xx` indicates successful handling of the requested semantics. `3xx` directs further action or indicates cached validation. `4xx` says the request or client-facing condition prevents fulfillment. `5xx` says the server side failed to fulfill an apparently valid request. These classes do not name a physical machine.

- `200 OK`: successful semantics with a representation where applicable.
- `201 Created`: one or more resources created; inspect `Location` where used.
- `202 Accepted`: accepted for processing, not completed.
- `204 No Content`: successfully handled with no response content.
- `206 Partial Content`: selected range response under range semantics.
- `301` and `308`: permanent redirection; `308` preserves method semantics.
- `302` and `307`: temporary redirection; `307` preserves method semantics.
- `303 See Other`: directs retrieval of another resource, commonly with GET.
- `304 Not Modified`: conditional request validator matched; reuse stored representation metadata according to caching rules. It is not a normal 200 body.
- `400 Bad Request`: request invalid at the issuer; inspect parser and policy.
- `401 Unauthorized`: authentication credentials are missing or unsuitable; the name is historically confusing.
- `403 Forbidden`: issuer understood but refuses authorization.
- `404 Not Found`: target not found or deliberately not disclosed.
- `409 Conflict`: current resource state conflicts with request.
- `412 Precondition Failed`: a conditional request precondition evaluated false.
- `429 Too Many Requests`: rate control; `Retry-After` may guide timing.
- `500 Internal Server Error`: generic server-side failure.
- `502 Bad Gateway`: gateway/proxy could not obtain a usable upstream response.
- `503 Service Unavailable`: temporary inability; can include `Retry-After`.
- `504 Gateway Timeout`: gateway/proxy exceeded an upstream response wait.

Always record who issued the status and whether a body or structured field contains safe additional detail.

### End-to-end and hop-by-hop fields

End-to-end fields describe the request, response, or representation across intermediaries unless a field's semantics say otherwise. Hop-by-hop fields describe one transport connection and must be consumed at that hop. In HTTP/1.1, `Connection` names additional connection-specific fields. Proxies must parse and remove them correctly. HTTP/2 and HTTP/3 reject connection-specific field use because their stream model differs.

A proxy should not forward `Connection`, `Keep-Alive`, `Proxy-Authenticate`, `Proxy-Authorization`, `TE` except the narrowly permitted use, `Trailer`, `Transfer-Encoding`, or `Upgrade` as ordinary end-to-end metadata. Product behavior must follow the applicable specification and version.

### Cache decision mechanics

Think of cache reuse as a proof obligation:

```text
eligible
AND key matches correct request dimensions
AND stored response selected for this request
AND fresh OR successfully validated OR explicitly allowed stale
AND request/response directives permit reuse
AND security context permits this cache to serve it
```

A cache key must preserve distinctions that change the representation. Scheme, authority, path, query normalization, method, content negotiation, authenticated identity, tenant, locale, and feature version may matter. Do not blindly include every field: that destroys hit rate, exposes sensitive values, and creates unbounded cardinality. Design a small trusted partitioning model.

`Vary` makes selected request fields part of response selection. `Vary: *` prevents ordinary reuse. Validators do not make a bad key safe; they validate a selected stored response, so the correct variant must already be chosen.

Invalidation is hard because copies exist at browser, edge, regional, and service caches. Prefer versioned immutable resources where possible. For mutable data, define TTL, purge scope, propagation time, failure behavior, and owner. A successful purge command is not proof that every copy is gone.

### Load balancing and affinity

Round robin is simple but ignores differing in-flight work. Least-request or least-connection policies can adapt to load but depend on accurate local state and can chase short-term noise. Weighted policies support heterogeneous capacity. Consistent hashing can reduce remapping and improve cache locality, but hotspots remain possible. Randomized choices can perform well at scale with less coordination.

Affinity sends related work to the same endpoint, often by cookie, source, or consistent key. Use it only for a stated reason such as unavoidable local session state or cache locality. It can create uneven load, complicate failover, and hide missing shared state. Prefer stateless application behavior when it actually meets requirements.

### Health and lifecycle

Health is not boolean truth about an entire service. It is a decision input for one controller.

```text
startup passes -> endpoint may begin readiness evaluation
readiness passes -> new traffic may be routed
readiness fails -> stop new traffic, preserve bounded drain
liveness fails -> restart may be justified
external journey fails -> alert humans; do not automatically eject all replicas
```

Use consecutive success and failure thresholds to reduce flapping. Add slow start so a cold endpoint is not immediately flooded. During rollout, mark not ready, wait for routing propagation, drain in-flight requests within a limit, then terminate. Long-lived connections, WebSockets, HTTP/2 streams, and load-balancer state require explicit drain behavior.

A readiness probe that depends deeply on one shared database can remove every application endpoint during a database incident, making recovery harder. A probe that checks only process existence can route traffic to a saturated or uninitialized worker. Choose the narrow capability needed for safe new traffic and observe deep journeys separately.

### Pool and queue ownership

Pools are commonly partitioned by upstream authority, endpoint, protocol, TLS identity, tenant class, or proxy worker. A dashboard summing them can hide one exhausted shard. Measure:

- active, idle, opening, closing, and failed connections;
- active HTTP/2 streams and configured stream concurrency;
- connection reuse and creation rate;
- acquire latency and timeout;
- pending queue current, maximum, rejection, and wait;
- cancellations before and after dispatch;
- destination distribution and endpoint churn.

A high connection count can be healthy reuse. A low count can carry enormous HTTP/2 concurrency. A full pool is evidence of no idle capacity at that instant, not proof that the limit should rise.

### Deadlines, retries, and overload

Use one end-to-end deadline:

```text
remaining = overall deadline - elapsed
per-attempt budget < remaining
queue wait + connect + request + response must fit remaining
```

When the client times out, propagate cancellation so proxy, origin, and dependency stop useless work when safe. Retry only when enough budget remains. Use bounded exponential backoff with jitter for failures where waiting is useful. A retry budget caps extra attempts relative to original traffic. Hedging deliberately overlaps attempts to reduce tail latency and therefore needs even tighter eligibility and cost controls.

Overload control order is usually: admission control, per-tenant fairness, bounded queue, load shedding, graceful degradation, and retry suppression. A circuit breaker can stop calls to an unhealthy dependency, but a global breaker can turn a partial failure into broad denial if scoped poorly.

## Evidence table

| Evidence | Proves | Does not prove | Next discriminating check |
|---|---|---|---|
| Client `503` | One response carried 503 to this client | Issuer or root cause | Correlation ID, Via/Proxy-Status where safe, proxy and origin logs |
| Direct origin `200` | One bypass path completed | Proxy causal, same identity, or production safety | Compare exact method, target, fields, body, deadline, and route |
| All targets healthy | Probe contract passed | User journey, pool headroom, dependency correctness | Real route SLI and readiness semantics |
| Cache `hit` | Cache says it reused stored state | Correct variant, freshness, authorization safety | Key, Vary, Age, directives, validator, two-context negative test |
| `Age: 42` | Response's current-age estimate was conveyed | Creation time or correctness | Date, freshness lifetime, cache chain, validator |
| Pool 256/256 | No idle slot in sampled pool | Limit too small or origin slow | Acquire time, service time, reuse, streams, partition, cancellations |
| Queue 512/512 | Configured pending capacity consumed | Waiting work still useful | Oldest wait, remaining deadline, rejects, cancellation propagation |
| Attempt ratio 2.5 | 2.5 attempts/original at that boundary | Retry cause or effect correctness | Attempt reason, config diff, client retries, redirects, fan-out |
| HTTP/2 one connection | One transport connection visible | Low concurrency | Active streams, request rate, flow-control stalls |
| Readiness false | Controller input says endpoint ineligible | Process dead or every balancer updated | Endpoint state, propagation, drain, direct authorized probe |
| Correct `200` for two tenants | Tested contexts received expected content | Every tenant or cache order | Reverse order, concurrency, expiry, unauthorized context |
| Rollback command succeeds | Control plane accepted change | Data plane recovered | Config version on all instances and exact user operation |

Counters require two timestamped samples and a delta. Gauges require an instant and scope. Histograms require boundaries and distributions. Logs require clock alignment and request correlation. Never compare requests/s with connections, or cumulative retry totals with queue depth.

## Command decoders

### Decode curl before trusting it

`--silent` hides progress. `--show-error` keeps errors visible. `--dump-header -` writes response status and fields to standard output. `--output /dev/null` discards response content; that means the command cannot validate body correctness. `--max-time 3` bounds the full operation at approximately three seconds as curl implements it. `--connect-timeout 1` bounds connection establishment, not the entire HTTP response.

`--write-out` prints client-measured values after the operation. `time_connect` concerns transport connection completion. `time_starttransfer` includes time until the first response byte as curl defines it. Subtracting fields can estimate phases, but connection reuse, redirects, proxying, TLS, DNS, curl version, and protocol can change interpretation. Always record the command and version.

`--verbose` can reveal Authorization, cookies, hosts, addresses, and response data. Use only sanitized local tests. In production, prefer approved telemetry and redaction. Never paste a verbose trace containing secrets into chat or a ticket.

`--head` sends HEAD, not “GET but download nothing.” An application can route HEAD differently. Use `--output /dev/null` with GET when you need GET semantics without retaining content, and separately validate content when correctness matters.

`--resolve host:port:address` changes name resolution only for that curl invocation. It preserves the URL authority, which affects virtual-host routing and, with HTTPS, certificate name validation. It is a diagnostic isolation tool, not proof that DNS is broken.

### Decode cache fields

`Cache-Control` can appear in requests and responses. Read directives in their exact context. `max-age=60` on a response gives a freshness lifetime relative to response timing rules; it does not guarantee every cache stores it. `s-maxage` applies to shared caches. `must-revalidate` constrains stale reuse. Product-specific cache-status fields can help, but they are not universal.

`ETag` values are opaque. Do not infer a checksum or version format. Strong and weak validators have different comparison behavior. Copy the value exactly within the same authorization and representation context. `If-None-Match` commonly supports conditional GET; `If-Match` can protect state changes from overwriting an unexpected version.

`Vary` describes request fields used in selecting a response. It is not a general authorization policy. If `Authorization` or authenticated tenant affects the body, start by preventing shared storage unless a reviewed design explicitly isolates it.

### Decode socket evidence

`ss -ntp state established` asks for numeric TCP established sockets and process details when permitted. `Recv-Q` and `Send-Q` for established sockets refer to queued bytes, not an HTTP request queue. A proxy's application pool and pending work live in its own process metrics.

`/proc/net/sockstat` summarizes kernel socket state. It does not expose HTTP/2 streams, cache entries, L7 retries, or route queues. Use it when the hypothesis is transport resource pressure, then move back to the request boundary.

The descriptor command uses `$$`, the current shell PID. It intentionally proves only the shell's boundary. To inspect a service, first identify the authorized PID and launch context; containers and systemd can apply different limits.

### Exit status matters

After a safe diagnostic, capture the status immediately:

```bash
curl --silent --show-error --max-time 3 http://127.0.0.1:18080/health
printf 'curl_exit=%s\n' "$?"
```

Run these as two literal lines. `$?` is the exit status of the immediately preceding command; another command overwrites it. An HTTP `503` and curl exit behavior depend on whether `--fail` or `--fail-with-body` is used. Record HTTP status and process exit status separately.

## Decision path

Use this incident path:

```text
1. Define exact operation, context, deadline, and expected result
                         |
                         v
2. Did the client receive a response?
        | no                               | yes
        v                                  v
   phase DNS/connect/TLS/queue       identify status issuer
                                           |
                                           v
3. Is the result semantically correct for this identity?
        | no                               | yes
        v                                  v
   protect data/state first          examine latency/SLO and scope
        |                                  |
        v                                  v
4. Where is last healthy input -> first abnormal output?
                         |
                         v
5. Cache hit or origin-bound miss/validation?
        | hit                              | origin-bound
        v                                  v
   key/freshness/context             retries/deadline/pool/queue
                                           |
                                           v
6. Is demand amplified or service time elevated?
                         |
                         v
7. Smallest owner-specific mitigation with abort + rollback
                         |
                         v
8. Replay identical operation; verify correctness + headroom + cohorts
```

### Branch: no response

Separate DNS, transport, TLS, and HTTP. LES-0013 owns TCP/UDP exhaustion; LES-0014 owns DNS. Do not skip them because the proxy dashboard is convenient. Ask whether the edge saw the request. If not, move toward the client. If yes, preserve the edge outcome and move forward.

### Branch: response but wrong result

Correctness outranks availability. For cross-tenant or authorization mistakes, stop unsafe serving, preserve sanitized evidence, notify the security incident owner, and avoid broad purge or restart that destroys provenance. Determine whether the wrong representation came from cache, routing, origin, or dependency.

### Branch: proxy-generated 502/503/504

Identify route and upstream cluster, then compare:

- original rate versus attempt rate;
- eligible retries and reasons;
- total and per-attempt deadlines;
- pool active/idle/opening and stream concurrency;
- queue depth, wait, rejects, and cancellations;
- endpoint health and distribution;
- upstream connect, first-byte, response, and reset outcomes;
- origin and dependency service time;
- rollout configuration by instance.

### Branch: cache hit

Do not contact the origin first. Validate the cache result: key, selected variant, security context, freshness, Age, response directives, validator, storage provenance, and current policy version. Test both positive reuse and negative isolation.

### Branch: one zone or cohort

Group by zone, endpoint, proxy version, protocol, client, and route. Global averages hide skew. Check whether affinity or long-lived HTTP/2 connections pin traffic. During failover, surviving zones receive redistributed originals plus retries and reconnections; calculate that distribution explicitly.

## Guided Ubuntu lab

The required lab lives at `book/labs/LES-0015-http-path`. It creates no listener and sends no request. A deterministic Python model prints fixed HTTP-path evidence through a guarded Bash interface.

### Environment card

- Platform: Ubuntu 24.04 or WSL 2 Ubuntu 24.04.
- Identity: normal non-root user; root is refused before mutation.
- Tools: Bash, Python 3.8+, and base Ubuntu utilities already present.
- Network: none; no DNS, socket, HTTP, proxy, container, cluster, or cloud call.
- Disk: under 256 KiB in one exact private `/tmp` directory and one UID descriptor.
- Cost: zero paid resources.
- Cleanup: guarded exact files only; no recursive removal.
- Stop: any guard refusal, missing dependency, unexpected artifact, changed owner/mode/link, or uncertainty about state.

### Preflight

```bash
cd book/labs/LES-0015-http-path
bash lab.sh check
```

Expected clean evidence includes:

```text
lesson_id=LES-0015
environment=ready
privilege=normal-user
network=none
execution=deterministic_http_model
state=absent
```

Do not use `sudo` if refused. A refusal is evidence that the safety boundary worked.

### Setup and baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

Decode each field. `*_per_second` is a rate, `*_percent` is a ratio scaled to 100, `*_ms` is milliseconds, pool and queue values are counts, and status is an HTTP code. The baseline is virtual evidence, not host telemetry.

### Select guided case and predict

```bash
bash lab.sh inject guided
bash lab.sh scenario
```

`scenario` intentionally shows operation inputs without incident observations. Before continuing, write:

```text
Method safety and idempotency:
Expected result and deadline:
Possible status issuers:
Expected cache path:
Expected request-to-attempt ratio:
Top three failure owners:
First observation and why:
```

Only then observe:

```bash
bash lab.sh observe operation
bash lab.sh observe proxy
bash lab.sh observe cache
bash lab.sh observe pools
bash lab.sh observe health
```

For each view record owner, unit, baseline, what it proves, what it cannot prove, and the next disconfirming check. Calculate attempt amplification. Estimate in-flight upstream work using a stated service-time assumption. Reject at least two hypotheses.

### Recover, verify, and clean

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

Recovery records an approved case-specific model transition. It does not prove recovery; `verify-operation` separately checks status, application correctness, two contexts, unsafe shared-hit absence, attempt budget, pool headroom, and queue headroom. Final `state=absent` proves guarded cleanup for this run.

### Run the verifier

From clean state:

```bash
bash verify.sh
```

The verifier exercises both cases and refusal boundaries. It deliberately does not score the learner's diagnosis. If it fails, inspect the first error. Never manually edit the state descriptor or delete a guessed `/tmp` path.

## Production transfer

### Containers

A container does not erase HTTP ownership. The application container, sidecar, node proxy, ingress gateway, and external load balancer can each own a different pool, queue, retry, health, and timeout. `localhost` inside one network namespace is not the host or another pod. Inspect the exact namespace and configuration version.

Container CPU throttling can increase service time without high host CPU. Memory limits can shrink cache or pool headroom. File-descriptor limits can constrain connections. Connect LES-0011 isolation evidence and LES-0013 socket evidence to HTTP metrics; do not tune the host because one container queue is full.

### Kubernetes

A Service provides a stable virtual access point to a changing set of endpoints. EndpointSlices represent backend addresses. The data-plane implementation can use kernel rules, proxies, or provider integrations; inspect the actual cluster rather than assuming one mechanism. A Service usually distributes transport flows, while an ingress controller or Gateway performs HTTP routing.

Readiness should remove a pod from eligible endpoints for new traffic. Removal is not necessarily instantaneous at every balancer. Pre-stop behavior, readiness transition, endpoint propagation, termination grace, and application drain must be coordinated. Existing keepalive connections may keep reaching an endpoint unless the proxy actively drains.

Kubernetes session affinity can bias flows by client identity. It does not create application session durability. During pod loss, affinity remaps and local state can disappear. Prefer externalized or client-carried state only when its consistency and security model are clear.

Useful read-only evidence in an authorized namespace includes Service selectors, EndpointSlices, pod readiness, rollout revision, per-pod request rate, gateway route, and proxy metrics. Before any mutation, use namespace scoping, `kubectl diff` where applicable, rollout history, declared abort criteria, and a rollback plan. This lesson does not run those commands.

### On-premises and private cloud

A hardware or software load balancer may have separate virtual-server, pool, member, connection, NAT, SSL, and HTTP profiles. Ask which layer each profile controls. A member can be green on one monitor while an L7 policy rejects the real authority or path. Connection mirroring and failover state have capacity and correctness trade-offs; test actual failure, not only configuration presence.

### Public cloud

Managed load balancers still expose finite quotas, health semantics, idle timeouts, target draining, zone distribution, TLS policies, headers, and logs. Provider names and limits change; consult current official documentation before design or incident change. Size for failure distribution and cost. Cross-zone traffic, data processing, logs, and cache egress can carry cost even when compute looks unchanged.

### CI/CD and platform engineering

Treat routes, retry policy, cache rules, health checks, pool limits, and timeouts as versioned production code. Validate syntax and semantics, test representative methods and identities, scan for unsafe header trust, and promote immutable artifacts. A platform golden path should provide safe defaults: bounded deadlines, retries off for unsafe methods, private caching for authenticated responses, sanitized correlation, meaningful readiness, drain hooks, and dashboards separating requests from attempts.

Do not make the platform hide every decision. Application teams must declare idempotency, cache eligibility, representation dimensions, dependency budget, and health contract. Guardrails can reject missing or unsafe declarations.

## Reliability, security, observability, capacity, and cost

### Reliability

Reliability is the probability that the correct user operation completes within its contract. Build around bounded resources:

- one propagated overall deadline;
- smaller phase budgets;
- retry eligibility plus budget and jitter;
- connection and stream limits;
- bounded pending queues;
- per-tenant admission and fairness;
- cancellation propagation;
- load shedding before dependency collapse;
- graceful drain and rollback;
- cache fallback only where stale reuse is explicitly safe.

Do not align every timeout to the same value. If client, edge, proxy, and origin all expire at 30 seconds, they can race and produce ambiguous resets while work continues. The caller's budget should be largest only when it truly owns the overall deadline, and inner phases must leave time to return a response.

### Security

At every HTTP boundary:

- reject ambiguous HTTP/1.1 framing;
- normalize once and preserve a consistent parsed request;
- remove connection-specific fields correctly;
- replace untrusted forwarding identity at the trusted edge;
- authenticate before protected routing and caching;
- authorize the actual resource after rewrites;
- limit field count, size, and parsing work;
- prevent CRLF and log injection;
- keep secrets and personal data out of traces, metrics, cache keys, and URLs;
- partition or disable shared caching for personalized responses;
- validate redirect targets and host/authority handling;
- bound request bodies and decompression;
- protect admin and health routes from public exposure;
- preserve audit trails without copying sensitive payloads.

Request smuggling occurs when two participants disagree about message boundaries, allowing bytes one parser treats as one request to be treated differently downstream. Defense requires specification-compliant parsing, rejection of ambiguity, consistent normalization, patched implementations, and protocol-boundary testing. Do not “test” smuggling against systems without explicit authorization.

### Observability

Separate these measurements:

- original client operations;
- proxy attempts and retry reasons;
- status by issuer, route, method, protocol, zone, and safe cohort;
- end-to-end, queue, pool-acquire, connect, first-byte, and origin latency;
- cache eligible, hit, miss, stale, validation, bypass, and error;
- pool active, idle, opening, streams, reuse, waiters, and rejects;
- health transitions, ejects, re-entry, and drain duration;
- cancellations and work completed after caller abandonment;
- origin and dependency saturation;
- correct business outcome and tenant-isolation canary.

Use bounded labels. Raw URL, user ID, request ID, tenant ID, and error text can create unbounded metric cardinality and expose data. Put high-cardinality correlation in protected logs or traces with sampling and retention controls; metrics use normalized route and approved cohorts.

A request ID joins events only when every hop logs it faithfully and safely. It does not prove causal order, authenticity, or that two retries had identical content. Traces add parent-child timing but can be sampled or missing. Combine evidence.

### Capacity

A useful origin-demand model is:

```text
origin attempt rate
  = original request rate
  x origin-bound fraction
  x average attempts per origin-bound request
```

If 20,000 original requests/s have an 80% safe cache hit ratio and misses average 1.1 attempts:

```text
origin-bound fraction = 1 - 0.80 = 0.20
origin rate = 20,000 x 0.20 x 1.1 = 4,400 attempts/s
```

At 50 ms mean residence:

```text
estimated in-flight attempts = 4,400/s x 0.050 s = 220
```

Now model failure. If hit ratio drops to zero, average attempts reach 2.4, and residence grows to 300 ms:

```text
origin rate = 20,000 x 1.0 x 2.4 = 48,000 attempts/s
estimated in flight = 48,000/s x 0.300 s = 14,400
```

That is 65 times the healthy concurrency estimate, not merely 2.4 times. Retries and slower service multiply. This is why cache failure, retry policy, and service time belong in one capacity model.

For one-zone loss, redistribute by the actual routing policy. In a balanced three-zone design losing one zone, each survivor might move from roughly one-third to one-half of total traffic, a 1.5x increase before retries and reconnections. Uneven clients, affinity, warm caches, and dependency locality can make it worse.

Use p95 and p99 residence, burst distributions, pool partitions, maximum concurrent streams, connection creation limits, descriptor and memory budgets, and safety headroom. Little's Law is a relationship, not a promise that averages size tails safely.

### Cost

Caching can reduce origin compute and egress but adds storage, invalidation, security review, and operational risk. More connections consume memory, descriptors, NAT state, and load-balancer capacity. More retries consume bandwidth and paid requests. Detailed logs and traces consume telemetry budget. Cross-zone balancing can improve resilience while increasing data-transfer cost.

State assumptions and compare at least two designs. A simple non-cached authenticated route with enough origin capacity can be cheaper than operating a complex cache safely at modest scale. Optimize only after correctness and measured demand.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| “All health checks pass” | Probe is one narrow operation | Define liveness, readiness, startup, and user journey separately |
| “503 means app down” | Intermediary can synthesize it | Record status issuer and route/config version |
| Cache every GET | GET can be personalized or sensitive | Explicit eligibility, private/no-store defaults, isolation tests |
| `no-cache` means no storage | It means validate before reuse | Teach directive semantics and test cache behavior |
| Trust client `X-Forwarded-For` | Client can spoof identity | Strip at trusted edge, append controlled chain, trust peers explicitly |
| Retry every 5xx | Amplifies load and duplicates effects | Eligibility, overall deadline, budget, backoff, idempotency |
| Increase pool and queue together | Hides owner and moves overload | One hypothesis, one bounded change, origin headroom proof |
| Very long queue prevents rejects | Stores work past useful deadline | Bound by wait budget and shed early |
| Connections equal concurrency | HTTP/2 multiplexes streams | Measure streams, requests, and connections separately |
| Sticky sessions solve state | They hide local state and skew load | Prefer designed state ownership; test remapping |
| Restart all proxies | Destroys evidence and state together | Canary, isolate cohort, preserve config and telemetry |
| Successful rollout means recovery | Control plane is not user result | Replay exact operation and monitor residual queues |
| Request IDs prove causality | They can be spoofed, reused, or missing | Generate at trust edge and correlate with timestamps/traces |
| Purge one bad cache object | Broken policy repopulates it | Disable unsafe route, repair policy, invalidate reviewed scope |
| Optimize hit ratio first | High hit ratio can serve wrong data | Make correctness and isolation primary SLIs |

A prevention control must target the mechanism. If retries amplified failure, add a retry budget and failure-load canary. If cache context leaked, add deny-by-default shared-cache policy and cross-context negative tests. “Watch more carefully” is not a control.

## Memory card and retrieval

### Memory card

**Problem:** A user-facing HTTP failure can be created by any intermediary, resource budget, or semantic mistake.

**One-sentence model:** Preserve the exact operation, then follow original request, trust, route, cache, attempt, pool, queue, origin, dependency, and response until the first semantic or capacity divergence.

**Mechanism:** HTTP semantics ride over version-specific framing; proxies can transform and multiply work; caches reuse state; pools and queues bound upstream work; health controls eligibility; deadlines bound usefulness.

**Calculation:** `origin attempts = originals × miss fraction × attempts per miss`; `in-flight approximately equals rate × residence time` at one consistent boundary.

**Failure story:** A retry rollout turns 900 original requests/s into 2,250 attempts/s, fills a pool and queue, and returns 503 while liveness remains green.

**Security story:** A shared cache omits tenant context and returns a fast 200 containing the wrong tenant's response.

**Trade-off:** Caching, retries, affinity, large pools, and large queues can improve a narrow happy path while increasing correctness, overload, skew, and operational risk.

**Retrieval prompt:** Which boundary first changed healthy input into abnormal output, and what evidence excludes the adjacent boundaries?

### Retrieval questions

1. What is the difference between HTTP semantics and HTTP version framing?
2. How do safety and idempotency differ, and why is neither permission for unlimited retry?
3. Why must original requests and upstream attempts be separate metrics?
4. What does `no-cache` mean compared with `no-store` and `private`?
5. Why can a full connection pool be a symptom rather than the root cause?
6. What must be trusted before using forwarding identity for authorization?
7. Why can every readiness or liveness target be green during user failure?
8. Calculate origin attempts for 5,000 originals/s, 60% hit ratio, and 1.25 attempts per miss.
9. Name the recovery evidence for a cross-tenant cache incident.

Review same session, then after 1, 3, 7, 14, 30, 60, and 90 days. Extend only when the explanation is correct without notes and transfers to a changed scenario.

## Complete answers

### 1. Semantics versus framing

Semantics define the meaning of method, target, fields, status, and representation. HTTP/1.1, HTTP/2, and HTTP/3 encode and transport those semantics differently. HTTP/1.1 has textual message framing over TCP. HTTP/2 uses binary frames and multiplexed streams over TCP. HTTP/3 maps HTTP to QUIC streams. An edge can translate versions while forwarding the same logical GET, so version evidence and operation evidence must both be preserved.

### 2. Safety, idempotency, and retry

A safe method asks for read-only semantics. An idempotent method has the same intended effect when repeated. GET is both; PUT and DELETE are idempotent but not safe; POST is neither by default. Retry also requires a transient eligible failure, remaining overall deadline, capacity budget, cancellation behavior, and implementation correctness. A POST can become replay-safe only through an application contract such as durable idempotency with conflict detection.

### 3. Originals versus attempts

An original is one caller operation. A proxy may emit multiple attempts because of retry or hedging, and a cache hit may emit none. If both are called “requests,” an incident hides amplification. The ratio `attempts/originals` says how much upstream demand the path creates. Measure reasons and outcomes so redirects or internal fan-out are not mislabeled retries.

### 4. Cache directives

`no-store` asks caches not to store the message. `no-cache` permits storage but requires validation before reuse. `private` permits a private cache but prevents reuse by shared caches. These directives interact with method, response status, explicit freshness, Authorization, and implementation policy. Verify the actual cache rather than infer behavior from one field.

### 5. Full pool as symptom

A pool becomes full when acquisition demand exceeds released capacity. Causes include higher original traffic, retry amplification, lower cache hit rate, longer origin service time, lost reuse, one hot partition, leaked streams, slow cancellation, or an undersized limit. Increasing it is justified only when the origin and dependencies have measured headroom and the limit itself is causal. Otherwise it lets more overload through.

### 6. Forwarding trust

The immediate peer must be an authenticated or network-controlled trusted proxy. The public edge must strip or replace client-provided identity fields, construct a documented chain, and constrain parsing. Downstream services should accept identity only from approved proxy peers and still authenticate and authorize the resource. Client address and trace data are sensitive and must be minimized.

### 7. Green health during failure

A probe may use a lightweight path, reserved capacity, different timeout, no authentication, no cache, or no dependency. It samples periodically and can miss bursts. Liveness asks whether restarting helps, not whether checkout has headroom. Readiness asks whether new traffic is safe, but its chosen contract can still omit user correctness. Pair it with request-level and journey SLIs.

### 8. Capacity answer

Miss fraction is `1 - 0.60 = 0.40`. Origin-bound originals are `5,000 × 0.40 = 2,000/s`. At 1.25 attempts per miss, origin attempts are `2,000 × 1.25 = 2,500/s`. This is an average estimate. Sizing also needs burst and latency distribution, pool partitions, failure redistribution, stream behavior, and headroom.

### 9. Cross-tenant recovery proof

First stop unsafe shared reuse and preserve sanitized evidence. After the policy repair and reviewed invalidation, request as tenant A and B in both population orders, then repeat across expiry and validator paths. Each must receive its own authorized representation; unauthorized contexts must remain denied; unsafe shared hits must be absent; origin and cache metadata must show the intended policy. Monitor for recurrence and follow the security notification process. A purge success alone is insufficient.

## Product-company interview

**Question:** “Our API is behind an L4 load balancer, an L7 gateway, and Kubernetes. During a zone drain, p99 rises, 504 increases, all pods stay ready, cache hit ratio falls from 80% to 20%, and attempts per original rise from 1.05 to 2.2. Design the investigation and safe response.”

A strong answer sounds like this:

> I would preserve the exact user operation and treat zone drain, cache loss, retry amplification, and slower service as interacting multipliers. First I would verify scope by client protocol, route, zone, gateway version, and identity, then identify who issues 504. I would calculate origin demand before and during the drain. If original rate is R, healthy origin demand is roughly R × 0.20 × 1.05; incident demand is R × 0.80 × 2.2, about 8.38 times larger before service-time growth. I would inspect cache eligibility and warmth, gateway retry reasons and deadlines, pool and queue acquisition, endpoint distribution, readiness propagation, drain state, origin latency, and dependency saturation. Green readiness does not prove headroom. I would stop the amplification through the narrow approved retry or drain rollback, rate-limit or shed work that cannot meet deadlines, and avoid enlarging pools unless origin capacity is proven. The rollback trigger is worse correctness, success, latency, or downstream saturation. Recovery requires the same user journey, expected cache policy, attempts inside budget, balanced surviving zones, pool and queue headroom, drained old endpoints, and no duplicate side effects. The permanent fix includes a zone-loss canary with cold-cache and retry behavior, explicit cache warming or fallback where safe, bounded retry budget, and rollout abort thresholds.

Follow-up answers:

- **Why not disable readiness?** Because it would route to endpoints without a safe eligibility signal and hide lifecycle bugs. Correct the readiness contract or drain coordination at its owner.
- **Would you add affinity?** Only if a measured cache-locality or state requirement outweighs skew and failover risk. It is not a general cure for cold caches.
- **How do HTTP/2 connections affect the drain?** One long-lived connection carries many streams. L4 and L7 drain must stop new streams or requests, allow bounded in-flight work, and eventually close the connection without abrupt duplication.
- **What if the request is POST?** Automatic retry requires an application idempotency contract with durable deduplication. Otherwise mitigate without replaying ambiguous operations and reconcile uncertain outcomes.
- **What would you alert on?** User outcome and latency, attempt ratio, queue wait/rejects, pool acquire, cache correctness and hit/miss, zone distribution, origin saturation, and work completing after caller cancellation. Each alert needs an owner and runbook.

Interviewers are testing whether you keep units and owners separate, calculate compounding demand, protect correctness, and prove recovery. Naming products without this reasoning is not advanced engineering.

## Independent transfer and rubric

Use ASM-0030 and the lab's independent case only after completing the guided case. Start clean:

```bash
bash lab.sh check
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Stop. Write predictions before any `observe`. The scenario exposes operation inputs and constraints, not incident evidence. Reading the fixture source or someone else's answer before submission invalidates the independence claim; disclose it and retry later with a changed exercise.

Then use only supported views. Your deliverable must include:

1. exact operation, method semantics, contexts, expected response, and deadline;
2. request-path and trust-boundary diagram;
3. prediction ledger made before observation;
4. baseline and incident evidence with units and proof limits;
5. at least three ranked mechanisms and two evidence-based rejections;
6. first healthy-input and abnormal-output boundary;
7. original, miss, attempt, concurrency, pool, and queue math;
8. confidentiality and correctness assessment for both contexts;
9. bounded recovery, approval, abort condition, and rollback;
10. same-operation verification in both context orders;
11. cleanup proof and assistance disclosure;
12. Kubernetes or load-balancer transfer with ownership and uncertainty.

The reviewer scores five areas from 0 to 4: safe independence, HTTP/proxy mental model, cache/identity security, evidence and capacity diagnosis, and recovery/production transfer. A 20/20 script run is impossible because the script does not grade reasoning. Any data-leak dismissal, unsafe retry, uncontrolled load, state tampering, or false production claim requires remediation regardless of total.

Publication remains `substantive-draft`. Reading this chapter is L1-L2 evidence. Correct guided work can support L2-L3. L4 requires unfamiliar diagnosis and design under changed constraints. L5 requires later teach-back and transfer on separated occasions.

## References and review

Primary references:

- REF-0073: [RFC 9110, HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110) for methods, status, fields, representations, conditional requests, and intermediaries.
- REF-0074: [RFC 9111, HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111) for keys, freshness, directives, validation, and shared caches.
- REF-0075: [RFC 9112, HTTP/1.1](https://www.rfc-editor.org/rfc/rfc9112) for textual syntax, framing, persistence, and parsing security.
- REF-0076: [RFC 9113, HTTP/2](https://www.rfc-editor.org/rfc/rfc9113) for frames, streams, multiplexing, flow control, and connection-field restrictions.
- REF-0077: [RFC 9114, HTTP/3](https://www.rfc-editor.org/rfc/rfc9114) for HTTP over QUIC and stream behavior.
- REF-0078: [RFC 7239, Forwarded](https://www.rfc-editor.org/rfc/rfc7239) for standardized forwarding information and its privacy/security limits.
- REF-0079: [RFC 9209, Proxy-Status](https://www.rfc-editor.org/rfc/rfc9209) for structured intermediary status and disclosure constraints.
- REF-0080: [Kubernetes Service documentation](https://kubernetes.io/docs/concepts/services-networking/service/) for Service, EndpointSlice, traffic policy, and session affinity transfer.

Review boundaries:

- HTTP specifications are stable primary sources, but deployed proxy behavior and metrics are implementation- and version-specific.
- Kubernetes documentation is continuously maintained; verify the target cluster version and implementation.
- Vendor retry, cache, health, pool, header, protocol, and timeout defaults must be checked in that product's current official documentation.
- No external source can prove your production behavior. Use configuration, tests, telemetry, and controlled failure evidence.

Delayed review schedule: same session, 1 day, 3 days, 7 days, 14 days, 30 days, 60 days, and 90 days. On each review, answer one cache-correctness scenario and one overload-capacity scenario without notes. Mastery remains unawarded until reviewed evidence demonstrates safe transfer.
