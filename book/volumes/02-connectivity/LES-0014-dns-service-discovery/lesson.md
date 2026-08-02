---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0014",
  "aliases": ["V02-L03", "dns-service-discovery"],
  "curriculumIds": ["NET-004"],
  "slug": "dns-service-discovery",
  "route": "/book/connectivity/dns-service-discovery",
  "order": 3,
  "volume": "02-connectivity",
  "title": "DNS and service discovery: follow the name, the cache, and the authority",
  "summary": "Trace a name from application input through NSS, a stub resolver, recursive caches, delegation, authoritative data, transport, and service-discovery policy; then diagnose stale answers, negative caching, search-path amplification, split-horizon differences, truncation, and Kubernetes DNS failures without guessing.",
  "domain": "connectivity",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 420,
  "prerequisiteLessonIds": ["LES-0012", "LES-0013"],
  "prerequisiteCurriculumIds": ["NET-001", "NET-002", "NET-003"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "Host commands are read-only and must run as a normal user. The required lab uses Bash and Python 3.8 or newer, deterministic offline evidence, and a guarded UID-scoped directory under /tmp; it sends no DNS packet and changes no resolver configuration."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The offline lab is supported. WSL may receive resolver configuration from Windows and has its own Linux network boundary, so record the exact shell, namespace, resolv.conf target, and resolver process before comparing Windows and Linux results."
    },
    {
      "platform": "Containers, Kubernetes, private cloud, and public cloud",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "The lesson transfers the evidence model to container namespaces, Kubernetes Services, CoreDNS, node-local caches, private zones, and managed resolvers. It creates no cluster or cloud resource and requires no online cloud account."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "network-reliability-engineer", "cloud-infrastructure-engineer", "private-cloud-engineer"],
  "learningObjectives": [
    "Distinguish an application name, NSS lookup, stub resolver, recursive resolver, cache, delegation, authoritative server, zone, record set, and returned endpoint.",
    "Trace forward and reverse DNS questions while preserving query name, type, class, response code, flags, authority, answer source, TTL, transport, and observation time.",
    "Decode A, AAAA, CNAME, NS, SOA, MX, TXT, PTR, and SRV records without assuming that a record proves application reachability or service health.",
    "Reason about positive and negative caching, TTL countdown, propagation windows, stale data, retry amplification, and cache capacity using explicit units and assumptions.",
    "Explain resolver search lists and ndots behavior, including how short or partially qualified names can multiply queries and leak names across policy boundaries.",
    "Separate UDP loss, EDNS size negotiation, truncation, TCP fallback, DNSSEC validation, policy filtering, and application timeout into testable hypotheses.",
    "Transfer the model to split-horizon DNS, Kubernetes service discovery, headless Services, EndpointSlices, pod resolver configuration, and layered caches.",
    "Design safe incident mitigation, rollback, verification, observability, security controls, and prevention around the boundary that owns the failed lookup."
  ],
  "productionSignals": [
    "An application reports host not found while dig returns an address from the same machine.",
    "A deployment changed an endpoint, but only some clients continue to use the old address.",
    "A newly created name remains NXDOMAIN for minutes after the authoritative record exists.",
    "Short Kubernetes service names are slow while fully qualified names resolve quickly.",
    "Small DNS answers work but large TXT, DNSSEC, or multi-address answers time out.",
    "The same name returns private addresses inside one network and public addresses elsewhere.",
    "A resolver returns SERVFAIL even though the authoritative server contains the requested record.",
    "DNS query rate and latency rise after a search-domain, retry, autoscaling, or cache change."
  ],
  "diagrams": [
    {
      "id": "LES-0014-DIA-001",
      "title": "One application lookup crosses separately owned DNS boundaries",
      "direction": "left-to-right",
      "boundaries": ["application input", "language or libc resolver", "NSS policy and hosts file", "local stub", "recursive resolver and cache", "root and parent delegation", "authoritative zone", "returned record set", "application connection"],
      "evidencePoints": ["exact name and API", "search expansion", "nsswitch order", "resolv.conf and stub address", "cache status and TTL", "referral and glue", "AA flag and SOA serial", "answer type and remaining TTL", "selected address and transport outcome"],
      "textAlternative": "An application gives a name to a resolver API; local NSS and search rules may change the questions before a stub asks a recursive cache, which follows delegations to an authoritative zone and returns records that the application may reorder or use for a later connection."
    },
    {
      "id": "LES-0014-DIA-002",
      "title": "DNS authority is a delegated tree, not one global database server",
      "direction": "hierarchical",
      "boundaries": ["root zone", "top-level parent zone", "example zone delegation", "service subdomain", "record set at a name"],
      "evidencePoints": ["root hints", "NS referral", "delegation NS and glue", "authoritative answer", "A AAAA CNAME SRV TXT or other RRset"],
      "textAlternative": "The DNS namespace is a tree. A parent delegates a child zone using NS records; an authoritative server for that child answers for record sets below its zone boundary, while recursive resolvers cache referrals and answers."
    },
    {
      "id": "LES-0014-DIA-003",
      "title": "A cached answer moves through time",
      "direction": "left-to-right",
      "boundaries": ["authority publishes data", "recursive cache stores it", "remaining TTL counts down", "record changes at authority", "old cache remains valid", "TTL reaches zero", "cache refreshes"],
      "evidencePoints": ["publish timestamp", "original TTL", "answer age", "change timestamp", "old versus new value", "expiry timestamp", "fresh query source"],
      "textAlternative": "A resolver may legitimately return an older value until the cached record's TTL expires; changing authoritative data does not invalidate every distributed cache immediately. Negative answers can also be cached."
    },
    {
      "id": "LES-0014-DIA-004",
      "title": "Kubernetes service discovery adds policy and cache layers",
      "direction": "left-to-right",
      "boundaries": ["pod application", "pod resolv.conf search and ndots", "cluster DNS Service", "CoreDNS or equivalent", "Service and EndpointSlice data", "optional node cache", "upstream private or public resolver"],
      "evidencePoints": ["query name and type", "expanded candidate names", "DNS service IP", "plugin metrics and logs", "service kind and endpoint readiness", "cache hit and TTL", "forwarding response code and latency"],
      "textAlternative": "A pod may expand a name through search suffixes before querying the cluster DNS virtual IP; the DNS server synthesizes service records from Kubernetes objects or forwards external names, and optional caches add another TTL and failure boundary."
    }
  ],
  "commands": [
    {
      "id": "LES-0014-CMD-001",
      "question": "Which host, user, namespace, resolver files, and tools define this observation?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -sr; id; readlink /proc/self/ns/net; readlink -f /etc/resolv.conf; command -v getent resolvectl dig",
      "runFrom": "The exact Ubuntu 24.04 or WSL Ubuntu shell where the failing application runs",
      "expectedBranches": [
        {"when": "Identity and namespace are expected and resolver tools are visible", "meaning": "The observation boundary and available tools are known.", "nextEvidence": "Record resolver configuration and the exact lookup API used by the application."},
        {"when": "The file target, namespace, tool set, or platform differs", "meaning": "This shell does not match the assumed evidence boundary.", "nextEvidence": "Preserve the difference; do not install or rewrite configuration merely to match the lesson."}
      ],
      "proves": "The displayed local platform, effective identity, namespace link, resolv.conf target, and command visibility at that instant.",
      "doesNotProve": "Which resolver the application used, whether a query left the host, whether an answer is correct, or whether a returned endpoint is reachable."
    },
    {
      "id": "LES-0014-CMD-002",
      "question": "What name-service order, search list, nameserver addresses, and resolver options affect normal applications?",
      "risk": "read-only",
      "command": "grep -E '^[[:space:]]*hosts:' /etc/nsswitch.conf; grep -E '^[[:space:]]*(search|domain|nameserver|options)[[:space:]]' /etc/resolv.conf",
      "runFrom": "The same filesystem and network namespace as the affected process",
      "expectedBranches": [
        {"when": "hosts includes files and dns or resolve, with search and options visible", "meaning": "The configured lookup order and DNS client policy are available for interpretation.", "nextEvidence": "Decode hosts-file precedence, search suffixes, ndots, attempts, timeout, and the actual application API."},
        {"when": "Entries differ, are generated, or are absent", "meaning": "Another NSS module or resolver manager may own lookup behavior.", "nextEvidence": "Inspect the file target and resolver manager without editing either one."}
      ],
      "proves": "The selected configuration lines visible to this process context.",
      "doesNotProve": "That every language runtime follows glibc NSS, that configuration was unchanged during the incident, or which candidate name produced the answer."
    },
    {
      "id": "LES-0014-CMD-003",
      "question": "What addresses does the operating-system lookup path return to a normal application?",
      "risk": "sampled-read-only",
      "command": "getent ahosts api.example.test",
      "runFrom": "Replace only with an authorized name; run beside the affected application when possible",
      "expectedBranches": [
        {"when": "One or more address and socket-type rows return", "meaning": "The NSS-backed lookup path returned those addresses for this sample.", "nextEvidence": "Record ordering and compare the application's selected address and connection attempt."},
        {"when": "No row returns or the command exits nonzero", "meaning": "This NSS lookup did not produce an address.", "nextEvidence": "Capture exit status, exact name, hosts/NSS policy, and direct DNS evidence separately."}
      ],
      "proves": "The result of one NSS-backed address lookup in this process context.",
      "doesNotProve": "That DNS itself failed or succeeded, that the application uses getaddrinfo-compatible behavior, or that an address accepts traffic."
    },
    {
      "id": "LES-0014-CMD-004",
      "question": "What does the local resolver manager know about links, scopes, servers, and domains?",
      "risk": "read-only",
      "command": "if command -v resolvectl >/dev/null 2>&1; then resolvectl status; else printf 'resolvectl unavailable; inspect the active resolver manager instead\\n'; fi",
      "runFrom": "The affected Ubuntu or WSL host as a normal user",
      "expectedBranches": [
        {"when": "Global and per-link DNS servers, domains, and protocols print", "meaning": "The manager exposes routing and resolver choices by link.", "nextEvidence": "Match the queried suffix and interface to the server that should receive it."},
        {"when": "The tool or service is absent", "meaning": "systemd-resolved is not the visible manager in this context.", "nextEvidence": "Use the platform's actual resolver configuration; absence is not a DNS failure."}
      ],
      "proves": "The resolver manager's current reported configuration when available.",
      "doesNotProve": "Application API behavior, a completed query, upstream authority, cache freshness, or endpoint health."
    },
    {
      "id": "LES-0014-CMD-005",
      "question": "What answer, flags, response code, server, and remaining TTL does one DNS server return?",
      "risk": "sampled-read-only",
      "command": "if command -v dig >/dev/null 2>&1; then dig api.example.test A; else printf 'dig unavailable; skip rather than install during diagnosis\\n'; fi",
      "runFrom": "Only for an authorized or deliberately reserved test name; this may send a DNS query to the configured resolver",
      "expectedBranches": [
        {"when": "NOERROR and an answer RRset return", "meaning": "The selected resolver returned data with the shown flags and remaining TTL.", "nextEvidence": "Check authority, alias chain, AAAA, client selection, cache source, and endpoint operation."},
        {"when": "NXDOMAIN, NOERROR without the requested type, SERVFAIL, REFUSED, or timeout occurs", "meaning": "These are different result classes and must not be collapsed into DNS down.", "nextEvidence": "Follow the response-specific decision path and compare authoritative versus recursive evidence."}
      ],
      "proves": "One DNS transaction's displayed response from the selected server when dig ran.",
      "doesNotProve": "What NSS or the application returned, global consistency, future cache state, or service reachability."
    },
    {
      "id": "LES-0014-CMD-006",
      "question": "Do address-family or alias-chain results differ?",
      "risk": "sampled-read-only",
      "command": "dig api.example.test A; dig api.example.test AAAA; dig api.example.test CNAME",
      "runFrom": "An authorized diagnostic shell with dig already installed",
      "expectedBranches": [
        {"when": "A, AAAA, or CNAME data differs from expectation", "meaning": "The record type or alias chain narrows the mismatch.", "nextEvidence": "Query each alias target and authority, then inspect application address-family selection."},
        {"when": "Expected records return", "meaning": "These record types are available in this sample.", "nextEvidence": "Test the actual selected endpoint and preserve TTL and resolver source."}
      ],
      "proves": "Displayed RRsets for three explicit query types.",
      "doesNotProve": "That asking for CNAME reveals every synthesized or flattened provider behavior, nor that every client prefers the same address."
    },
    {
      "id": "LES-0014-CMD-007",
      "question": "Does the same authorized DNS question succeed over TCP?",
      "risk": "sampled-read-only",
      "command": "dig +tcp api.example.test A",
      "runFrom": "The same client and resolver target used for the failing UDP-based sample",
      "expectedBranches": [
        {"when": "TCP succeeds while the comparable default query times out or truncates", "meaning": "Transport handling, size, fragmentation, policy, or fallback is now a leading boundary.", "nextEvidence": "Inspect TC, EDNS size, UDP path, TCP port 53 policy, and resolver fallback behavior."},
        {"when": "Both paths fail or both succeed", "meaning": "Transport comparison did not isolate a TCP-only recovery.", "nextEvidence": "Compare response codes, server identity, timings, and authoritative data."}
      ],
      "proves": "The result of one explicit DNS-over-TCP query.",
      "doesNotProve": "Why UDP differed, that every resolver falls back correctly, or that encrypted DNS was involved."
    },
    {
      "id": "LES-0014-CMD-008",
      "question": "How does an advertised EDNS UDP payload size affect the response?",
      "risk": "sampled-read-only",
      "command": "dig +bufsize=1232 api.example.test TXT",
      "runFrom": "Only for an authorized name and resolver; compare with the same question and timestamp",
      "expectedBranches": [
        {"when": "The answer succeeds or returns TC with a bounded size", "meaning": "The responder handled the advertised EDNS size and may require TCP for the full answer.", "nextEvidence": "Compare TCP and UDP outcomes and inspect path MTU or filtering only with authorization."},
        {"when": "The query times out or returns an error", "meaning": "EDNS negotiation, transport, policy, authority, or the name itself may differ.", "nextEvidence": "Use controlled comparisons; do not claim fragmentation from timeout alone."}
      ],
      "proves": "One response behavior for one advertised EDNS UDP payload size.",
      "doesNotProve": "The actual path MTU, packet loss location, universal safe buffer size, or server capacity."
    },
    {
      "id": "LES-0014-CMD-009",
      "question": "What evidence accompanies a negative answer?",
      "risk": "sampled-read-only",
      "command": "dig definitely-absent.example.test A +noall +comments +authority",
      "runFrom": "Use only a deliberately reserved absent name in a zone you own; never probe arbitrary names",
      "expectedBranches": [
        {"when": "NXDOMAIN with an SOA in authority returns", "meaning": "The resolver reports that the name does not exist and supplies negative-caching context.", "nextEvidence": "Record SOA fields, remaining negative TTL, authority, and whether the name was later created."},
        {"when": "NOERROR without A, another code, or timeout returns", "meaning": "The result is not the same as NXDOMAIN.", "nextEvidence": "Distinguish nonexistent name, existing name without type, policy refusal, validation failure, and transport failure."}
      ],
      "proves": "The displayed negative or alternative response class and authority section for one query.",
      "doesNotProve": "That every resolver holds the same negative cache, when all caches expire, or that the authoritative configuration is correct."
    },
    {
      "id": "LES-0014-CMD-010",
      "question": "Where does delegation lead for a zone you are authorized to inspect?",
      "risk": "sampled-read-only",
      "command": "dig example.test NS; dig example.test SOA",
      "runFrom": "An authorized domain; compare recursive output with direct authority queries when server addresses are known",
      "expectedBranches": [
        {"when": "NS and SOA data agree with the intended zone", "meaning": "The queried resolver currently exposes the expected delegation and zone metadata.", "nextEvidence": "Query each authoritative server directly and compare serials and target RRsets."},
        {"when": "Delegation, authority, or serials differ", "meaning": "Parent-child delegation or authoritative synchronization may be inconsistent.", "nextEvidence": "Separate registrar or parent data, child apex data, and each authoritative server before changing records."}
      ],
      "proves": "The selected resolver's current NS and SOA response data.",
      "doesNotProve": "That the parent delegation agrees, every authoritative server is reachable, zone content is synchronized, or DNSSEC validates."
    },
    {
      "id": "LES-0014-CMD-011",
      "question": "Is a DNS listener visible in this exact namespace?",
      "risk": "read-only",
      "command": "ss -lunp 'sport = :53'; ss -ltnp 'sport = :53'",
      "runFrom": "The namespace expected to host a local stub or DNS server; process names may be permission-limited",
      "expectedBranches": [
        {"when": "UDP, TCP, or both listeners appear", "meaning": "A socket is bound on port 53 in this namespace for the shown transport and address scope.", "nextEvidence": "Match the address to resolv.conf and test an authorized query over both transports."},
        {"when": "No listener appears", "meaning": "No visible port-53 listener exists here at sample time.", "nextEvidence": "Check whether resolv.conf points to a remote server or whether the expected service runs in another namespace."}
      ],
      "proves": "A point-in-time socket-table view for local port 53.",
      "doesNotProve": "Resolver correctness, recursive ability, authority, policy, upstream reachability, or query capacity."
    },
    {
      "id": "LES-0014-CMD-012",
      "question": "What bounded sample of DNS policy is visible to one exact Kubernetes container?",
      "risk": "mutating-bounded",
      "command": "( : \"${KUBE_NAMESPACE:?export KUBE_NAMESPACE as the authorized namespace}\"; : \"${POD_NAME:?export POD_NAME as the exact pod name}\"; : \"${POD_CONTAINER:?export POD_CONTAINER as the exact container name}\"; kubectl --namespace=\"$KUBE_NAMESPACE\" exec \"$POD_NAME\" --container=\"$POD_CONTAINER\" -- head -n 80 -- /etc/resolv.conf )",
      "runFrom": "Only with existing pod-exec authorization in a non-production or approved namespace after exporting exact `KUBE_NAMESPACE`, `POD_NAME`, and `POD_CONTAINER` values; this starts one remote `head` process, reads at most 80 lines, and creates Kubernetes API, audit-when-enabled, and transient container-runtime/process evidence even though it does not modify the file",
      "expectedBranches": [
        {"when": "A cluster DNS IP, search domains, and options print within the 80-line sample", "meaning": "The selected container's resolver file was sampled through a successful remote exec.", "nextEvidence": "Count candidate queries from name dots, ndots, search entries, address types, and retry behavior."},
        {"when": "Authorization is denied or the pod is unavailable", "meaning": "No evidence was collected and access boundaries worked as configured.", "nextEvidence": "Use approved workload diagnostics or deployment specifications; do not broaden permissions for convenience."}
      ],
      "proves": "At most 80 lines from the resolver file visible inside that exact container at that moment, plus successful authorization and creation of the sampled remote process.",
      "doesNotProve": "That the file has no later lines, that Kubernetes auditing is enabled or retained, CoreDNS health, another container's policy, application runtime caching, actual query sequence, or endpoint readiness.",
      "cleanup": "The remote `head` process exits after reading at most 80 lines and kubectl closes the exec stream; no persistent workload object or file is created, while API, audit-when-enabled, and runtime evidence follows the platform's retention policy."
    }
  ],
  "labs": [
    {
      "id": "LES-0014-LAB-001",
      "title": "Trace modeled resolver, cache, authority, and transport evidence without sending a packet",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with Bash and Python 3.8 or newer",
      "timeMinutes": 60,
      "privilege": "Normal user only; root is refused",
      "network": "None; deterministic offline DNS model only",
      "changes": ["One validated UID-scoped state descriptor under /tmp", "One validated private lesson directory under /tmp", "Small allowlisted evidence records inside that directory"],
      "abortConditions": ["Effective UID is zero", "/tmp is not a real root-owned sticky directory", "A state path, owner, mode, link count, manifest, fixture digest, or allowlisted artifact check fails", "A required dependency is absent"],
      "recovery": "Use bash lab.sh recover only after writing a hypothesis, then bash lab.sh verify-operation and bash lab.sh cleanup; never recursively remove a discovered path.",
      "cleanupProof": "Cleanup validates every registered artifact, removes only its allowlist, removes the exact empty registered root and descriptor, and check proves state=absent.",
      "path": "book/labs/LES-0014-dns-path"
    },
    {
      "id": "LES-0014-LAB-002",
      "title": "Independent DNS failure localization with answer-isolated raw inputs",
      "mode": "independent",
      "environment": "A clean normal-user Ubuntu 24.04 or supported WSL 2 Ubuntu shell",
      "timeMinutes": 80,
      "privilege": "Normal user only; no sudo, packet capture, resolver edit, cluster credential, or runtime socket",
      "network": "None; the independent case uses deterministic virtual evidence and exposes raw inputs before derived observations",
      "changes": ["The same guarded lab-owned state boundary", "A neutral independent case identifier", "Learner notes stored outside lab state and never read by verifier"],
      "abortConditions": ["Any guard refuses", "A second active case is requested", "An unexpected artifact appears", "The learner has not stated the exact failed lookup and evidence scope"],
      "recovery": "Choose the modeled recovery only after a diagnosis and disconfirming test; verify the original operation separately, then use guarded cleanup.",
      "cleanupProof": "The verifier exercises guided and independent lifecycles, root and invalid-state refusal, tamper and symlink refusal, answer isolation, and final absence.",
      "path": "book/labs/LES-0014-dns-path"
    }
  ],
  "incidents": [
    {
      "id": "LES-0014-INC-001",
      "signal": "A payment API moved from 10.20.4.18 to 10.20.7.31; new resolver queries return the new address, but a subset of long-running workers still connects to the old one until each process restarts.",
      "firstThought": "Separate authoritative truth, recursive cache TTL, operating-system cache, and application or connection-pool retention; a correct dig answer does not prove the process refreshed its own stored address.",
      "safePath": "Preserve old and new answers with timestamps and TTLs, compare getent and application telemetry in affected processes, determine refresh behavior, keep the old endpoint draining for the planned overlap, and use a bounded process recycle or configuration fix only at the proven owner; verify real transactions and both endpoint populations.",
      "trap": "Flushing every recursive cache, dropping the old endpoint immediately, or declaring DNS fixed because one dig command shows the new record."
    },
    {
      "id": "LES-0014-INC-002",
      "signal": "Kubernetes pods intermittently report DNS timeout after a rollout; fully qualified service names are faster, query rate multiplied, and large external responses fail more often than small internal answers.",
      "firstThought": "Treat search and ndots expansion, A and AAAA parallelism, retries, CoreDNS capacity, upstream latency, EDNS response size, truncation, and TCP fallback as separate measurable boundaries.",
      "safePath": "Capture one pod's resolver policy and exact application names, compute candidate queries per operation, compare FQDN and short-name latency, inspect DNS response-code and duration distributions, verify UDP and TCP behavior with authorized probes, bound retries, and roll back the resolver or workload change if user errors improve without moving pressure downstream.",
      "trap": "Scaling CoreDNS blindly, lowering every TTL, disabling AAAA globally, or adding retries before proving whether amplification, transport, upstream authority, or application caching owns the failure."
    }
  ],
  "assessmentIds": ["ASM-0025", "ASM-0026", "ASM-0027"],
  "referenceIds": ["REF-0065", "REF-0066", "REF-0067", "REF-0068", "REF-0069", "REF-0070", "REF-0071", "REF-0072"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The required lab is a deterministic model and does not prove behavior of the learner's resolver, network, Kubernetes cluster, cloud private zone, authoritative server, or production application.",
    "Read-only commands are snapshots whose output, permissions, resolver stack, cache ownership, and namespace scope vary by platform and runtime.",
    "Packet capture, cache flush, resolver restart, DNS record mutation, cluster changes, firewall changes, and DNSSEC key operations require separate authorization and are deliberately not performed.",
    "Capacity examples teach dimensional reasoning; production sizing needs measured arrival distributions, cache-hit ratios, answer sizes, retry policies, failure domains, and safety margins.",
    "Publishing or completing this lesson does not award mastery; independent transfer evidence and human review remain required."
  ]
}
---

# DNS and service discovery: follow the name, the cache, and the authority

## What you see and first thought

You see `Temporary failure in name resolution`, `Name or service not known`, `NXDOMAIN`, `SERVFAIL`, or a five-second pause before a request begins. The tempting sentence is, "DNS is down." That sentence is too large to guide you. DNS is not one box and a hostname is not an IP address stored in a universal phone book.

Use this first thought instead:

> Preserve the exact name, query type, lookup API, client scope, resolver that answered, response code, remaining TTL, transport, and timestamp. Then find the first boundary where expected evidence changes.

That sentence prevents three common mistakes. First, it stops you testing `dig` when the application used an NSS-aware API and `/etc/hosts` won. Second, it stops you treating an old cached answer as proof that the authority is still wrong. Third, it stops you treating a returned address as proof that TCP, TLS, or the application behind that address works.

Think of resolution as a supply chain. The application supplies a name. Local policy may expand or replace it. A recursive resolver supplies an answer from cache or seeks authority. The application then chooses an address and starts a different network operation. A failure label can hide any of those transitions.

Write an incident fact in this shape:

```text
At 14:03:12 UTC, process checkout-worker in pod checkout-7b9f asked its normal
resolver API for A/AAAA addresses for payments.default. The call exceeded its
2 s deadline. From the same container, the effective search list and ndots
policy would expand that input into several candidate names. No conclusion yet
exists about CoreDNS, upstream authority, or endpoint reachability.
```

That is useful because it states what failed and what remains unknown. "DNS outage" does neither.

## Terms before commands

**Name** means a label sequence in the DNS tree, such as `api.example.net.`. The trailing dot represents the root and makes the printed name absolute. Without that dot, resolver software may treat the input as relative and append search suffixes.

**Label** is one component between dots. In `api.prod.example.net.`, `api`, `prod`, `example`, and `net` are labels. The order reads from most specific on the left toward the root on the right.

**Zone** is an administrative slice of the DNS namespace. A zone is not automatically the same as a domain name or a server. `example.net.` can be delegated as a zone, and several authoritative servers can serve copies of its data.

**Delegation** is the parent zone saying, "Ask these name servers for that child zone." NS records express the delegation. Address records called glue may accompany it when the name-server names need addresses that would otherwise create a lookup loop.

**Authoritative server** serves source data for a zone and can mark an answer authoritative. It does not normally search the whole DNS tree for clients. **Recursive resolver** accepts a client's recursive request, follows referrals or uses caches, and returns a final response. One product can perform several roles, but the roles remain different.

**Stub resolver** is the client-side component that sends a query to a configured recursive resolver. On Linux, an application may call a libc routine such as `getaddrinfo`; the Name Service Switch can consult files, systemd-resolved, DNS, or other sources according to `/etc/nsswitch.conf`. A direct DNS tool can bypass part of this path.

**Resource record**, abbreviated RR, is typed DNS data. Records with the same owner name, type, and class form an **RRset**. Operationally, treat the set as the cache and DNSSEC unit; do not expect independent TTL behavior for individual addresses in one coherent set.

Common record types:

| Type | Meaning | What it does not prove |
|---|---|---|
| A | IPv4 address | That the host listens or the address is healthy |
| AAAA | IPv6 address | That the client has a working IPv6 path |
| CNAME | Canonical-name alias | That the target has an address or application |
| NS | Authoritative name-server name for a zone or delegation | That every server is reachable or synchronized |
| SOA | Zone authority and maintenance metadata | That all replicas loaded the same serial |
| MX | Mail exchanger preference and name | That SMTP accepts the message |
| TXT | Arbitrary text chunks used by many protocols | That an application interprets them safely |
| PTR | Reverse-tree name associated with an address | A guaranteed inverse of every forward record |
| SRV | Service target and port with priority and weight | That the selected target is healthy |

**TTL**, time to live, is a cache lifetime in seconds supplied with DNS data. A recursive response commonly shows remaining TTL, not necessarily the authority's original value. TTL is not propagation delay by itself and not a health-check interval.

**Positive cache** holds data such as an A RRset. **Negative cache** holds knowledge that a name does not exist or that a type is absent, based on negative-response rules and SOA data. Creating a record after an NXDOMAIN response does not instantly erase every cached negative answer.

**NXDOMAIN** means the queried name does not exist according to the answering chain. **NODATA** is informal operational language for a successful `NOERROR` response where the name exists but the requested type has no answer. **SERVFAIL** means the server could not complete the request; validation failure, upstream failure, or internal failure are possibilities. **REFUSED** means policy declined the operation. A timeout is no response before the client's deadline; it is not a DNS response code.

**EDNS** extends DNS signaling, including advertising a UDP payload size larger than the original classic limit. **TC**, the truncated flag, tells the client that a response was shortened. DNS uses both UDP and TCP; TCP is not only for zone transfers. Modern implementations need TCP for ordinary queries whose answers do not fit or when policy requires it.

**DNSSEC** adds origin authentication and integrity for DNS data through a chain of signed delegations to a configured trust anchor. It does not encrypt names or answers, does not make an endpoint healthy, and does not prove that the organization owning a signed name is trustworthy in every business sense.

**Split-horizon** or split-view DNS means policy intentionally returns different data based on client context, such as corporate versus public networks. Different answers can be correct. The investigation must preserve which view and resolver produced each answer.

**Service discovery** maps a stable service identity to changing connection targets, sometimes with port, weight, or readiness semantics. DNS is a discovery mechanism, not a complete health system. Kubernetes uses DNS names for Services, but the Service and EndpointSlice controllers, cluster DNS, proxies or data plane, and backing applications own different parts of success.

## Architecture map

Here is the complete path worth memorizing:

```text
application name
      |
      v
runtime cache / resolver API
      |
      v
NSS policy ---> /etc/hosts
      |
      v
stub resolver + search/ndots
      |
      v
local resolver manager or cluster DNS virtual IP
      |
      v
recursive resolver/cache
   | cache hit                         | cache miss
   v                                   v
return remaining TTL       root -> parent -> child authority
      |                                   |
      +-------------------+---------------+
                          v
                   answer / negative / error
                          |
                          v
                application selects endpoint
                          |
                          v
                  TCP/UDP/TLS/application
```

Text alternative: the application does not necessarily query an authoritative server. Its resolver path can first use a runtime cache, NSS, a hosts file, search expansion, a local stub, and a recursive cache. Only a cache miss needs delegation. After resolution, connection success belongs to a later transport and application path.

Mark the ownership at every arrow. The application team owns the input name, deadline, runtime cache, and address selection. The host platform owns NSS and local resolver configuration. The network or platform team may own recursive resolvers. Domain owners control delegation and authoritative data. Security teams may add filtering or validation policy. In Kubernetes, controllers and cluster DNS synthesize records from API objects. No single dashboard automatically represents all of these.

The authority tree is equally important:

```text
.  root
|
+-- net. parent knows NS for example.net.
    |
    +-- example.net. authority knows SOA and service.example.net.
        |
        +-- service.example.net. A 192.0.2.20
```

Text alternative: each parent directs the resolver toward the child authority. The final A record lives at the child authority, not at the root or parent. A broken delegation can prevent reaching perfectly correct child data.

An SRE asks four scopes before changing anything:

1. **Name scope:** exact bytes, absolute or relative, query types, aliases, and search candidates.
2. **Resolver scope:** application cache, NSS, stub, recursive server, view, namespace, and policy.
3. **Authority scope:** zone cut, parent delegation, authoritative server, serial, signature, and RRset.
4. **Use scope:** address selected, port, route, transport, TLS identity, and application outcome.

## Request or state path

Suppose a pod calls `https://payments:8443`. The application may ask `getaddrinfo("payments")` for both IPv6 and IPv4 candidates. If the pod has search domains `shop.svc.cluster.local`, `svc.cluster.local`, and `cluster.local` with `ndots:5`, the single-label input has fewer than five dots. Resolver behavior can try expanded names before the absolute form:

```text
payments.shop.svc.cluster.local.
payments.svc.cluster.local.
payments.cluster.local.
payments.
```

The actual sequence and parallel A/AAAA behavior depend on the resolver implementation. Do not memorize one packet count as universal. Compute a bound from the observed client policy and then measure.

For a successful cluster Service lookup, CoreDNS or an equivalent server watches Kubernetes API data and synthesizes an answer for the Service name. A normal ClusterIP Service commonly resolves to the virtual IP. A headless Service can return addresses associated with ready endpoints according to Kubernetes DNS rules. The application then selects an address. kube-proxy, eBPF data plane, a service mesh, or another implementation owns later traffic forwarding. DNS success does not prove EndpointSlice readiness or packet delivery.

For an external name, cluster DNS may forward to an upstream recursive resolver. That resolver checks its cache. On a miss it follows referrals: root provides the top-level nameservers, the top-level authority provides the child delegation, and a child authority supplies the answer. Each response may be cached according to its TTL and policy.

A DNS message contains more than an answer:

```text
header: transaction ID, QR, opcode, AA, TC, RD, RA, AD, CD, RCODE, counts
question: query name, query type, query class
answer: requested or alias RRsets
authority: delegation or SOA context
additional: useful related records and EDNS option data
```

`RD` says recursion was desired. `RA` says recursion is available at that server. `AA` says the responding server considers the answer authoritative for the relevant data. `AD` can indicate authenticated data from a validating resolver, but its trust meaning depends on the secure channel and resolver relationship. Never read one flag without knowing which server set it.

Caching changes state over time. If an authority publishes address A with TTL 300 at 10:00 and a resolver caches it at 10:02, the resolver can reuse it until roughly 10:07 based on its stored lifetime. If the authority changes to address B at 10:03, seeing A from that cache at 10:04 may be expected. If a process caches A forever despite TTL expiry, that process owns a separate defect.

Negative caching is a first-class state. A client asks for a name before deployment creates it. The resolver receives NXDOMAIN and caches that result. Deployment then creates the record, yet that resolver continues returning NXDOMAIN until the negative entry expires. Repeated retries can all hit the same valid negative cache; more retries do not accelerate expiry.

## Failure zoom

Start with the exact outcome because each outcome points differently.

| Outcome | First boundary | Next evidence |
|---|---|---|
| `getent` succeeds, application fails | runtime, API, container, cache, or selected family differs | capture application name, API result, runtime cache, namespace |
| `dig` succeeds, `getent` fails | NSS or local resolver path differs | inspect nsswitch, hosts, resolv.conf, manager |
| NXDOMAIN | name or delegation says name absent | compare absolute name, authority, negative TTL, creation time |
| NOERROR with no requested type | name exists but requested RRset absent | inspect aliases and requested type |
| SERVFAIL | resolver could not complete or validate | compare resolver logs/metrics and direct authority evidence |
| REFUSED | policy declined the query | identify view, ACL, recursion, or zone-transfer policy |
| timeout | no decisive response before deadline | compare server reachability, UDP/TCP, load, retry, packet size |
| stale address | cache or application retained older data | record TTL, age, cache layers, process refresh behavior |
| correct address, failed request | DNS phase completed | continue through route, transport, TLS, and application |

### Failure pattern: a newly created name still returns NXDOMAIN

Timeline is the decisive evidence:

```text
09:00 resolver asks for deploy-42.example.net -> NXDOMAIN, negative TTL 300
09:01 automation creates deploy-42 A record at authority
09:02 same resolver asks -> cached NXDOMAIN can still be valid
09:05 negative lifetime reaches expiry
09:05+ next query can fetch the new positive RRset
```

Do not flush the organization's caches first. Confirm the name is absolute, inspect the SOA supplied with the negative response, query every authority directly, and compare a recursive resolver that did and did not cache the miss. The safe rollout pattern is to create names before clients need them, wait the negative-cache window when practical, and then enable traffic.

### Failure pattern: large answers fail

Small A answers work. A DNSSEC-signed response, TXT set, or address-rich answer times out. Possibilities include an advertised EDNS size that leads to IP fragmentation, a path that drops fragments, a firewall that mishandles EDNS, a truncated UDP response without successful TCP fallback, TCP port 53 policy, or server overload. Timeout alone proves none of them.

Use controlled pairs: same client, server, name, type, and time; vary only transport or advertised size. Record `TC`, response size, flags, and latency. If `dig +tcp` works while the comparable UDP path fails, transport handling becomes a strong lead. It still does not locate the loss without authorized path evidence.

### Failure pattern: different clients get different answers

Possible causes include expected split-horizon policy, resolver cache age, geolocation or traffic steering, inconsistent authoritative replicas, different search suffixes, hosts-file overrides, or application caches. First label the client location, resolver address, view, ECS or policy context if applicable, exact query, and time. "DNS inconsistency" is not a mechanism.

### Failure pattern: short Kubernetes names are slow

Count the candidates. A partially qualified external-looking name with fewer dots than `ndots` can be tried through several cluster search suffixes before its absolute form. Each candidate may generate A and AAAA questions and retries. If an application performs 2 address types across 4 candidates with 2 attempts, an upper-bound teaching estimate is:

```text
2 types * 4 candidates * 2 attempts = 16 DNS transactions per logical lookup
```

Implementations can parallelize, stop early, cache, or behave differently, so this is a hypothesis budget, not a captured fact. Use fully qualified names where the contract calls for them, tune only with workload evidence, and avoid globally changing `ndots` without understanding service-name behavior.

## Internals and state ownership

DNS is a distributed, cached database whose consistency is deliberately time-bounded rather than instantaneous. The authority controls source data and TTL. Recursive resolvers decide when to retrieve and cache within protocol and policy boundaries. Clients may add caches of their own. This is why "propagation" is too vague: data can be correct at authority while old positive or negative state remains elsewhere.

### Delegation and glue

A parent zone delegates a child with NS records. If the nameserver for `example.net` is `ns1.example.net`, a resolver would need data from `example.net` to find the server responsible for `example.net`. The parent can include glue address records to break that dependency. Glue supports reaching the child authority; it is not an authoritative answer for every use of that host name.

Diagnose delegation by comparing:

- the parent-side NS referral;
- necessary glue addresses;
- the child apex NS RRset;
- each authoritative server's SOA serial and answer;
- reachability over UDP and TCP;
- DNSSEC DS and DNSKEY relationships where validation applies.

### Alias chains

A CNAME states that an owner name aliases another canonical name. Resolution then needs data for the target. Long or cyclic alias chains add queries and failure points. At an alias owner, DNS rules restrict coexistence with other data. Managed DNS products may expose flattening behavior at zone apexes; treat that as provider behavior, not ordinary CNAME semantics.

An application may cache the final address, the alias, or both. During migration, changing only the target RRset may leave several TTL layers. Preserve the full chain and TTLs at each hop.

### Resolver libraries and NSS

`dig` constructs DNS queries. `getent ahosts` exercises the host's NSS-backed lookup path. An application may use its language runtime, an asynchronous DNS library, a service mesh sidecar, or a hardcoded resolver. Therefore:

```text
dig success != application resolution success
getent success != application selected a healthy address
DNS answer success != connection success
```

Some runtimes cache indefinitely or use their own TTL rules. Some clients race IPv6 and IPv4. Some proxies resolve only at startup. The application owner must expose the input name, returned candidates, chosen address, cache age, and refresh event without logging sensitive names indiscriminately.

### UDP, TCP, EDNS, and truncation

DNS commonly starts over UDP because it avoids connection setup, but UDP provides no delivery guarantee. EDNS lets participants advertise capabilities such as larger UDP payloads. Larger does not always mean safer: an oversized datagram may fragment along the IP path, and fragments may be lost or filtered. Conservative deployed sizes exist, but production selection must match actual platform and current authoritative guidance.

When a response cannot fit, a server can set `TC`, and the client should retry appropriately using TCP. TCP can also be selected initially. Both server and network policy must support it. Capacity planning therefore includes UDP packet rate, TCP connections, connection reuse, memory, query concurrency, and fallback bursts.

### DNSSEC trust boundary

DNSSEC validation follows signatures and delegation records toward a configured trust anchor. A **secure** answer validates. An **insecure** delegation can be legitimate when a zone is unsigned. A **bogus** result means validation failed and often surfaces as SERVFAIL to a normal client. Check time synchronization, signature validity intervals, DS/DNSKEY agreement, algorithm support, and which resolver validated.

DNSSEC protects authenticity and integrity of DNS data in its validation chain. It does not hide query names, authorize application users, encrypt transport, validate TLS certificates, or guarantee endpoint availability. Do not disable validation globally to make an incident disappear; repair the chain or use a bounded, reviewed exception with an expiry and rollback.

### Kubernetes ownership

Kubernetes DNS records are derived from API objects. A ClusterIP Service name can resolve even when no ready endpoint can serve a request. A headless Service can expose endpoint addresses, but readiness and publication policies matter. Pod-specific names and records depend on supported fields and cluster-domain policy. The source-of-truth path is:

```text
Service / EndpointSlice / Pod state
              |
              v
cluster DNS watch and synthesis
              |
              v
DNS Service address and data plane
              |
              v
pod resolver search and cache
              |
              v
application selection and connection
```

Text alternative: Kubernetes API state feeds cluster DNS; a pod reaches the DNS server through cluster networking, applies its resolver policy, and the application uses the answer. A failure at one layer does not prove another layer failed.

## Evidence table

| Evidence | Scope and units | Proves | Does not prove |
|---|---|---|---|
| Exact application error and duration | one operation, timestamp, milliseconds | what the caller observed | DNS server root cause |
| `/etc/nsswitch.conf` | one filesystem context | configured NSS order | runtime actually used it |
| `/etc/resolv.conf` | one filesystem context | visible servers/search/options | resolver manager internals or query success |
| `getent ahosts name` | one NSS sample | returned address candidates | direct DNS result or reachability |
| `dig name A` | one server transaction | response, flags, sections, TTL | application result or global truth |
| `dig +tcp` comparison | one explicit transport | TCP transaction outcome | UDP loss location |
| Authority queries | one server at one time | that server's data and serial | every replica or parent agreement |
| Resolver cache metrics | one resolver process | hit, miss, eviction, size distributions | application cache state |
| Response-code rate | resolver or authority, queries/s | NXDOMAIN/SERVFAIL/REFUSED trend | which client input caused every response |
| DNS duration histogram | chosen boundary, seconds | latency distribution | application time remaining after DNS |
| Kubernetes Service | one API object | desired discovery identity and virtual IP mode | ready backends or successful traffic |
| EndpointSlice | namespace/service scope | published endpoint addresses and conditions | cluster DNS served a fresh answer |

Evidence becomes useful when it includes scope and time. A screenshot of `dig` without the queried server, timestamp, and exact client location is weak. A cache-hit ratio without query volume is weak. A P50 duration without P99 and timeout rate can hide user pain.

During incidents, capture the least sensitive evidence needed. Internal names, tenant identifiers, resolver logs, and packet captures can expose architecture and user activity. Redact at collection boundaries and define retention. Observability is not permission to collect every query forever.

## Command decoders

### Decode the baseline command

`cat /etc/os-release` identifies the user-space distribution. `uname -sr` shows kernel name and release. `id` prevents accidentally treating a root-only observation as normal behavior. `/proc/self/ns/net` identifies the current network namespace link. `readlink -f /etc/resolv.conf` reveals whether the file points to a generated stub or another target. `command -v` checks availability without installing anything.

If `/etc/resolv.conf` points to a loopback-like stub address, that does not mean all authority lives locally. A daemon may listen locally and forward based on per-link policy. In WSL, generated configuration may lead through the Windows host boundary. Record rather than rewrite.

### Decode NSS and resolver policy

The `hosts:` line in `/etc/nsswitch.conf` is an ordered policy. Tokens such as `files`, `dns`, or `resolve` select modules. Bracketed actions can change whether lookup continues after a status. Do not reduce the line to "DNS enabled."

In `/etc/resolv.conf`:

- `nameserver` lists resolver addresses available to the stub;
- `search` lists suffixes for relative names;
- `domain` is a legacy single-domain form;
- `options ndots:n` influences when a name is first tried as absolute versus through search;
- timeout and attempts affect client delay and amplification.

A trailing dot makes a DNS name absolute in conventional textual form. When testing a suspected search problem, compare `service` with `service.namespace.svc.cluster.local.` and preserve both results.

### Decode `getent ahosts`

Rows show address results associated with socket types. Duplicate-looking addresses can be separate STREAM, DGRAM, and RAW entries; count addresses deliberately rather than counting lines. Exit status matters. Empty output can come from lookup failure or policy, but it is not a DNS RCODE display.

Use `getent` because it resembles the standard host database path more closely than `dig`. Still confirm the application language and runtime. Java, Go, Python, proxies, and static binaries can choose different resolver implementations depending on build and configuration.

### Decode `dig`

Read from top to bottom:

1. **status** is the RCODE such as NOERROR, NXDOMAIN, SERVFAIL, or REFUSED.
2. **flags** include QR, AA, TC, RD, RA, AD, and CD; interpret them relative to the queried server.
3. **QUESTION** preserves exact name, type, and class.
4. **ANSWER** contains returned RRsets or aliases.
5. **AUTHORITY** can contain referrals or the SOA supporting negative caching.
6. **ADDITIONAL** can contain related addresses and EDNS metadata.
7. **Query time** is the tool's observed transaction duration, not end-user application latency.
8. **SERVER** identifies the selected resolver endpoint.
9. **WHEN** and message size make comparisons reproducible.

`+short` is convenient but discards much of the evidence you need during an incident. Use full output first. Save secrets and internal names carefully.

### Decode SOA

An SOA record includes the primary master name, responsible party mailbox encoding, serial, refresh, retry, expire, and minimum fields. Serial comparisons help find lagging authoritative replicas, but the serial format itself is administrator policy. Refresh and retry guide secondary behavior. Negative caching uses SOA-related rules from RFC 2308; do not assume the field called minimum always has only its historical meaning.

### Decode SRV

SRV RDATA has priority, weight, port, and target. Clients prefer lower numeric priority. Weight supports probabilistic selection among equal-priority records; it is not a percentage health guarantee. The target is a name whose address must also resolve. Capacity and health require application-aware behavior beyond the record.

### Decode resolver-manager output

`resolvectl status` can show per-link servers, protocols, and routing domains. A `~` route-only domain can route matching DNS traffic without acting as a suffix for ordinary name expansion. A default-route link may receive other names. Field availability varies; use version-matched documentation and preserve the exact output.

### Decode port 53 listeners

`ss -lunp 'sport = :53'` inspects UDP listeners; `ss -ltnp` inspects TCP. A stub may bind only a loopback address. A production authoritative server should support transports according to applicable standards and deployment policy. Process information can be hidden from an unprivileged user. Absence of a local listener is expected when resolv.conf points directly to a remote resolver.

## Decision path

Use this decision tree without skipping the first line:

```text
What exact operation failed?
|
+-- application did not obtain a name result
|   |
|   +-- getent differs from application -> runtime/API/cache/namespace
|   |
|   +-- getent differs from dig -> NSS/hosts/stub/search policy
|   |
|   +-- dig receives NXDOMAIN -> exact name/delegation/negative cache
|   |
|   +-- dig receives SERVFAIL -> validation/upstream/server execution
|   |
|   +-- dig times out -> resolver path/load/transport/deadline
|
+-- application obtained an unexpected address
|   |
|   +-- authority differs -> zone/delegation/replica problem
|   +-- recursive differs -> positive or negative cache/view/policy
|   +-- only process differs -> runtime cache or refresh problem
|
+-- application obtained expected address
    |
    +-- DNS phase is not the current failure; continue transport path
```

For NXDOMAIN, ask:

1. Was the queried name exactly what the application intended?
2. Was it absolute, or did search expansion produce another name?
3. Does the name itself not exist, or does only the requested type not exist?
4. Which resolver returned the negative response and with what remaining TTL?
5. What do every authoritative server and the parent delegation say?
6. Was the record created after a cached negative response?

For SERVFAIL, ask:

1. Does another recursive resolver with the same policy fail?
2. Can the recursive resolver reach all required authorities over UDP and TCP?
3. Do authoritative servers agree on data and serial?
4. If DNSSEC applies, is the answer secure, insecure, or bogus?
5. Are clock, DS, DNSKEY, RRSIG validity, and supported algorithms consistent?
6. Is the resolver overloaded, rate-limited, or failing an upstream plugin?

For timeout, build controlled comparisons. Change only one variable: resolver, transport, record type, absolute versus relative name, or client location. Do not spray arbitrary public resolvers; that can bypass enterprise policy and leak private names.

Remediation order is evidence-driven:

1. Reduce user harm without destroying evidence: retain the old endpoint during TTL overlap, roll back a bad resolver policy, or remove an unhealthy DNS replica through approved controls.
2. Correct the owning boundary: record, delegation, cache policy, runtime refresh, search name, transport policy, or capacity.
3. Verify the original application operation, not just `dig`.
4. Verify negative cases, alternate address families, UDP and TCP when relevant, and multiple failure domains.
5. Observe long enough to cross cache lifetimes and rollout windows.
6. Add prevention tied to the mechanism.

## Guided Ubuntu lab

The required lab is `book/labs/LES-0014-dns-path`. It does not send DNS traffic. A Python model emits deterministic virtual evidence so you can practice reasoning even on an airplane or a clean Ubuntu installation.

From the lab directory, run:

```bash
bash lab.sh check
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject guided
bash lab.sh observe operation
bash lab.sh observe resolver
bash lab.sh observe cache
bash lab.sh observe authority
bash lab.sh observe transport
```

Before observation, state your failed operation: "The modeled checkout client asks its normal resolver for `payments.service.test` A data before a 1200 ms deadline." Then read each view.

The guided case is designed so the authority has current data while one recursive cache retains an older positive RRset within its remaining TTL. The application is routed to that resolver. Your evidence chain should say:

1. The application's lookup succeeds syntactically but returns the previous address.
2. Resolver identity matters; a different resolver's result does not describe this client.
3. The cached record's stored value and remaining TTL explain why this resolver can return old data.
4. The authority serial and current RRset show that source data changed.
5. UDP/TCP are healthy in the model, so transport tuning is unsupported.
6. The bounded recovery preserves overlap and advances modeled time to cache expiry rather than deleting unrelated state.

Then run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

`verify-operation` checks the original modeled lookup and selected endpoint. `cleanup` removes only validated lab-owned artifacts. If a guard refuses, stop and inspect; do not use recursive deletion.

For the independent case, clean and set up again. Run `bash lab.sh inject independent`, then `bash lab.sh scenario` before observations. The `scenario` output contains raw inputs only: resolver policy, query name, search list, `ndots`, record types, attempts, response sizes, and transport outcomes. It deliberately omits derived query count, diagnosis, and recovery. Make your prediction first, then gather the five observation views.

The independent answer belongs in your own notes, not in lab state. Compare it with the deliverables in ASM-0027 only after you finish. Publishing the verifier pass proves safety and deterministic lifecycle behavior, not DNS mastery.

## Production transfer

### Containers

Always identify the namespace and filesystem context. The host's `/etc/resolv.conf` may differ from a container's generated file. A container runtime can inject a DNS proxy address. A service mesh may resolve names itself or intercept traffic after resolution. Capture evidence inside the affected container when authorized, and compare it with node evidence without assuming they share state.

Minimal transfer bundle:

```text
container identity and image version
network namespace identity
exact /etc/resolv.conf and nsswitch view
application runtime and resolver mode
exact query names/types and timestamps
resolver endpoint and response distribution
selected address and subsequent connection result
```

### Kubernetes

Use the fully qualified service form to reason precisely: `<service>.<namespace>.svc.<cluster-domain>.` The actual cluster domain is configurable; do not hardcode `cluster.local` into an application contract without knowing the platform.

A normal Service and a headless Service have different discovery semantics. For a normal Service, DNS can return a stable virtual IP even when endpoints are missing. For a headless Service, answers can represent endpoint addresses subject to publication and readiness rules. Stateful workloads can receive stable pod-related identities when correctly configured, but DNS identity is not storage durability or leader election.

When cluster DNS is slow, split the path:

- pod stub and runtime caching;
- search and `ndots` amplification;
- DNS Service virtual IP/data plane;
- CoreDNS instance CPU, memory, concurrency, plugin duration, cache, errors, and restarts;
- API watch freshness for Service and EndpointSlice objects;
- node-local cache if deployed;
- upstream recursive latency, responses, and transport;
- authoritative data.

Scaling CoreDNS can help actual server saturation. It cannot fix an invalid name, a poisoned application cache, broken parent delegation, or UDP fragmentation upstream. Reducing `ndots` can reduce expansion for some names but can change how legitimate short service names resolve. Treat it as an application and platform contract change.

### Private cloud and split horizon

Private zones often exist only through approved resolvers reachable from specific networks. Querying a public resolver and receiving NXDOMAIN may be correct public-view behavior. Conversely, forwarding private names to public DNS can leak architecture. Resolver routing domains, conditional forwarders, virtual-network links, and source network decide the view.

Compare views deliberately:

```text
client location -> configured resolver -> policy/view -> authoritative source -> answer
```

Do not use `8.8.8.8` or another public resolver as a universal diagnostic bypass. It changes trust, policy, view, audit, and data-leak boundaries.

### Cloud managed DNS

Managed zones still have delegation, TTL, record, quota, and resolver-path concerns. Provider health dashboards cannot show application runtime caches. Infrastructure as code can prevent manual drift but can also deploy a wrong zone or record quickly. Use plan/diff, explicit zone identifiers, ownership validation, canaries, staged TTL planning, and rollback data. This lesson requires no cloud account; the reasoning transfers locally.

## Reliability, security, observability, capacity, and cost

### Reliability

Define DNS SLIs at the user-relevant boundary:

- successful lookup ratio by response class and expected negative class;
- lookup duration distribution, not just average;
- stale or incorrect answer rate when measurable through synthetic contracts;
- resolver availability by failure domain;
- cache hit/miss/eviction behavior;
- application failures attributed to name resolution versus connection phases.

NXDOMAIN is not always an error. A security product or application can intentionally query absent names. Separate expected from unexpected negatives. Likewise, a resolver returning NOERROR quickly can still return an unusable endpoint; use synthetic application operations for end-to-end reliability.

Redundancy requires independent failure thinking. Two resolver IPs backed by the same process, node, rack, control plane, or upstream are not two independent paths. Authoritative zones need multiple reachable servers and consistent data. Test UDP and TCP. Plan cache behavior during authority outages rather than assuming caches are permanent.

### Security

DNS data can influence where credentials and traffic go. Protect record-change authorization, delegation, registrar accounts, API tokens, and audit trails. Use least privilege and multi-party review for high-impact zones. Monitor unauthorized changes and dangling aliases that could enable takeover.

DNSSEC authenticates DNS data when correctly chained and validated; it is not encryption. Plain DNS exposes query metadata to observers. Encrypted DNS transports can protect a hop but may conflict with enterprise routing, filtering, or split-view policy; architecture must define which resolver is trusted and why.

Treat query logs as sensitive. They can reveal users, tenants, internal services, incident activity, and software inventory. Minimize fields, control access, aggregate when possible, and expire raw data. Never paste an unredacted production DNS capture into public tools.

Search suffixes can leak a short internal name to unintended zones if candidates fall through. Use absolute names for external dependencies and deliberate namespace conventions. Prevent open recursion on authoritative infrastructure unless recursion is an explicit protected service.

### Observability

At recursive resolvers, useful signals include queries per second, response-code rates, cache hits/misses, evictions, request duration histograms, inflight requests, UDP truncation, TCP use, upstream duration, timeouts, and per-plugin failures. At authorities, include query volume, response size, RCODE, transport, zone load state, serial consistency, and signature health.

High-cardinality query names can overload metrics and expose data. Aggregate by approved suffix, response type, resolver instance, transport, and tenant boundary. Use sampled, access-controlled logs for individual investigations.

Correlate phases:

```text
request_start
  dns_start -> dns_done
  connect_start -> connect_done
  tls_start -> tls_done
  request_sent -> response_done
```

Without phase timing, a five-second HTTP failure can be wrongly assigned to DNS. Without the exact selected address, a correct DNS answer cannot be tied to the subsequent transport failure.

### Capacity

Little's Law gives a first estimate for concurrent work:

```text
inflight queries ~= arrival rate (queries/s) * average residence time (s)
```

If a resolver sees 12,000 queries/s and average service time is 0.020 s, average inflight work is about 240 queries. That is not a safe capacity number. Tail latency, bursts, retries, cache misses, TCP fallback, worker limits, and upstream stalls shape peaks.

Search amplification changes arrival rate. Suppose 2,000 logical application lookups/s each cause an average of 5 DNS transactions because of search candidates and address types. The resolver receives roughly 10,000 queries/s before retries. Two attempts during an outage can approach 20,000 query attempts/s. The best correction may be a qualified application name, not twice the server fleet.

Cache effectiveness:

```text
miss rate = total query rate * (1 - cache hit ratio)
```

At 10,000 queries/s with a 90% hit ratio, roughly 1,000 queries/s proceed to upstream work. If the hit ratio falls to 40% after a TTL or cache-size change, upstream demand becomes roughly 6,000 queries/s, a sixfold increase. This arithmetic assumes the reported hit ratio uses compatible definitions and windows.

TTL is a reliability and freshness budget. A long TTL lowers query and authority load and can preserve service through brief outages, but retains old data longer. A short TTL enables faster planned change but increases query load and sensitivity to resolver or authority failure. Choose TTL from change requirements, failure tolerance, query volume, and rollback plan—not habit.

Negative-cache capacity matters during deployment typos or generated-name storms. Random nonexistent labels defeat cache reuse and can hammer authority. Rate-limit abusive clients, fix generators, and preserve enough logging to identify the pattern without retaining sensitive names indefinitely.

### Cost

DNS cost includes managed query charges, resolver and authority compute, cross-network forwarding, logs, observability cardinality, incident labor, and downstream connection waste from wrong answers. Lower TTL can raise billable query volume. More retries can multiply both DNS and application load. An extra caching layer can reduce upstream cost but adds staleness and debugging boundaries. Optimize only after measuring the complete path.

## Traps and prevention

**Trap: `dig` works, therefore the application is wrong.** It may be, but first prove both used the same name, resolver, search policy, namespace, query type, and cache. Prevention: expose application resolver telemetry and provide an NSS-aware runbook.

**Trap: flush all caches.** This destroys evidence, creates a miss storm, and may move load to an already unhealthy authority. Prevention: identify the exact cache and entry; use planned TTL overlap and bounded eviction only with approval.

**Trap: lower TTL during the incident and expect old caches to notice.** Existing cached data keeps the previous TTL. Prevention: lower TTL at least one old-TTL window before a planned migration, verify, change records, then restore a reviewed value.

**Trap: increase retries.** Retries can turn a partial resolver slowdown into saturation. Prevention: bounded attempts, jitter, deadline budgets, caching, and load shedding; measure attempts per logical lookup.

**Trap: query a public resolver for a private name.** This changes the DNS view and can leak internal data. Prevention: approved diagnostic resolvers, conditional forwarding documentation, and split-view test cases.

**Trap: disable DNSSEC validation because SERVFAIL disappears.** That converts an integrity failure into accepted unvalidated data. Prevention: monitor signature lifetimes, DS/DNSKEY rollovers, clocks, algorithms, and validation status; use staged key rollovers.

**Trap: allow UDP but block TCP port 53.** Ordinary large responses can need TCP. Prevention: test both transports and reflect standards in firewall policy and capacity.

**Trap: call every different answer inconsistent.** Split horizon, steering, and cache age can make differences intentional. Prevention: record client, resolver, view, answer source, TTL, and timestamp.

**Trap: make Kubernetes DNS responsible for endpoint health.** A Service record can exist without usable backends. Prevention: alert separately on resolution, EndpointSlice readiness, connection, TLS, and application success.

**Trap: store unlimited per-name metrics.** Cardinality and privacy costs become an incident. Prevention: controlled labels, aggregation, sampling, retention, and access review.

**Trap: use short names everywhere.** Search expansion creates ambiguity and load. Prevention: define when service-local short names are allowed and when absolute names are mandatory.

## Memory card and retrieval

Remember **N-C-A-T-U**:

```text
N - Name: exact input, absolute/relative, type, search candidates
C - Client: API, NSS, namespace, runtime cache, deadline
A - Answerer: resolver identity, view, cache/authority, RCODE, TTL
T - Transport: UDP/TCP, EDNS, TC, timing, response size
U - Use: selected endpoint, connection, TLS, application result
```

When someone says "DNS is down," respond in your head: **Which N-C-A-T-U boundary changed?**

Retrieval prompts:

1. Why can `dig` succeed while an application fails? Because they may use different APIs, NSS, caches, search rules, namespaces, types, or resolver endpoints.
2. What does NXDOMAIN mean? The queried name is reported nonexistent; it is not the same as an existing name without the requested type, SERVFAIL, or timeout.
3. Why can a new record still look absent? A negative answer may remain cached until its permitted lifetime expires.
4. What does TTL control? Cache reuse lifetime for data; not connection health and not universal propagation time.
5. Why does TCP port 53 matter? DNS uses TCP for ordinary queries including fallback after truncation and other valid cases.
6. What does DNSSEC not do? It does not encrypt DNS, validate application health, or replace TLS authorization.
7. Why can a Kubernetes Service resolve with zero healthy backends? DNS identity and endpoint readiness are separate control-plane facts.
8. What is the safest first production action? Preserve exact operation and scoped evidence before changing caches, records, retries, or resolver fleets.

Five-minute drill: take any hostname-related incident and write one line for each N-C-A-T-U letter. If a line is unknown, that is your next evidence request. Do not fill unknowns with assumptions.

## Complete answers

### Why does an application fail when `dig` works?

Direct answer: `dig` proves only its own DNS transaction. A normal application may consult `/etc/hosts`, another NSS module, a local stub, a language runtime cache, a sidecar, or another network namespace. It may ask A and AAAA, apply a search list, choose a different address, or time out within a smaller deadline.

Strong investigation: record the exact application input and resolver API; inspect the process/container resolver configuration; compare `getent ahosts` with full `dig` output to the configured server; capture the returned candidates and chosen address; then test the connection phase separately. The result is a boundary, not a blame statement.

### What should I do when old and new addresses appear?

Direct answer: identify which layer supplies each answer and whether its TTL or refresh policy still permits it. Query each authority directly, then the affected recursive resolver, then the OS path, then the application process. Put timestamps and remaining TTLs beside every value.

Safe recovery: retain the old endpoint for the planned cache overlap when possible. If one authoritative replica is stale, remove or repair that replica through its managed control plane. If a runtime holds addresses beyond policy, use a bounded refresh or rolling recycle and fix its cache contract. Verify real operations through both endpoint populations until old use reaches zero.

### How should TTL be chosen for migration?

Direct answer: from the maximum tolerable stale window, normal and failure query volume, resolver/authority capacity, rollback needs, and client-cache behavior. Lower the TTL before the migration by at least the previous TTL plus a verification margin. Confirm authoritative replicas serve the lower value. Make the data change, observe old and new traffic, then restore a sustainable TTL.

Example: the record currently has TTL 3600 s and migration begins at 18:00. Changing TTL to 60 at 17:55 does not affect entries cached earlier for an hour. Lower it well before 17:00, verify, and preserve the old endpoint long enough for clients that do not honor DNS TTL perfectly.

### How do I distinguish NXDOMAIN and NODATA?

NXDOMAIN says the queried name does not exist. NOERROR with an empty answer for the requested type can mean the name exists but lacks that type, perhaps with SOA context. This distinction changes cache and remediation reasoning. Creating an A record fixes missing A data at an existing name; correcting a mistyped or undelegated name fixes a different problem.

### What should I do with SERVFAIL?

Treat it as a resolver execution or validation failure, not as absent data. Compare a controlled query to each authority and through the recursive path. Inspect resolver logs and metrics, upstream timeouts, authority reachability over UDP and TCP, delegation consistency, and DNSSEC status. Do not replace SERVFAIL with an invented answer or disable validation globally.

### How do search lists and `ndots` cause load?

They turn one application string into multiple DNS candidate questions. Address families and retries multiply them again. Compute an upper bound from the actual resolver file, then measure query logs or metrics at a safe aggregation level. Prefer absolute external names and explicit service naming contracts. Change resolver policy only after testing every legitimate short-name path.

### What proves DNS recovery?

Not a single `dig`. Recovery requires the original application lookup and transaction to succeed within its deadline, from affected client scopes, through expected resolver views, across long enough time to cover important cache lifetimes. Response-code and latency distributions should normalize, wrong-endpoint traffic should drain, retry volume should remain bounded, and UDP/TCP plus alternate failure domains should behave as designed.

### How would a senior engineer explain cache staleness?

"The authority changed at 10:03, but resolver R1 cached the previous RRset at 10:02 with 300 seconds remaining. R1 could legitimately return the old address until approximately 10:07. Resolver R2 missed after the change and returned the new value. The application used R1, so R2's fresh answer did not describe the failing path. We retained the old endpoint through the overlap, verified R1's TTL countdown, and fixed the deployment process to lower TTL in advance and measure application-level old-address traffic."

## Product-company interview

### Question: Design reliable service discovery for a high-volume payment platform

A strong answer begins with requirements: naming ownership, regional and private views, endpoint churn, freshness target, QPS, tail-latency SLO, failure domains, compliance, and whether clients need port/weight metadata. Separate the control plane that publishes endpoints from the data plane that resolves and connects.

Use delegated zones with audited infrastructure-as-code changes, multiple authoritative failure domains, protected registrar and DNS APIs, and DNSSEC where the trust model requires it. Provide recursive resolvers close to workloads with bounded caching, independent capacity, UDP and TCP support, safe forwarding for private zones, and controlled telemetry. In Kubernetes, use standard Service names, EndpointSlices, cluster DNS replicas, topology-aware capacity where justified, and optional node-local caching only after modeling staleness and failure behavior.

Clients need absolute-name contracts for external dependencies, bounded resolver and operation deadlines, controlled retries with jitter, connection pooling, address refresh, and graceful handling of multiple A/AAAA answers. Migrations use pre-lowered TTL, old/new endpoint overlap, canaries, real transaction verification, and rollback. SLIs include expected lookup success, response-code distribution, P99 resolution time, cache behavior, stale-answer synthetic tests, endpoint readiness, and full transaction success. Logs are sampled and access-controlled because names are sensitive.

The trade-off statement matters: longer TTL reduces cost and authority dependence but extends staleness; shorter TTL improves change responsiveness but increases query load and outage sensitivity. More caches reduce upstream work but add state boundaries. The design chooses values from measured workload and recovery objectives rather than defaults.

### Question: DNS latency rose after moving workloads to Kubernetes. What do you do?

State the exact symptom and compare pre/post distributions. Capture one affected pod's resolver file, runtime, input names, query types, and deadlines. Calculate the possible search/ndots amplification. Compare absolute and short forms, but do not treat the experiment as a production fix.

Then inspect DNS Service reachability, per-instance query rate, CPU throttling, memory, restarts, inflight work, duration histograms, RCODE, cache hits, plugin timing, upstream timing, and TCP fallback. Correlate with Service and EndpointSlice watch freshness. Compare a healthy namespace or node. If query amplification from partially qualified names is proven, fix the application name contract or narrowly tune pod DNS policy after compatibility tests. If CoreDNS capacity is proven, scale with failure-domain and cache-warmup awareness. If upstream large answers fail, repair UDP/TCP/EDNS path policy. Verify the original transaction and observe retry volume.

### Question: How do you roll over an endpoint without DNS downtime?

Inventory all cache layers and current TTL. Lower the authoritative TTL far enough in advance for the old value to age out. Verify every authority serves the planned value. Bring up the new endpoint and prove health before publishing it. Publish old and new addresses when client behavior supports that strategy, or change the target while keeping the old endpoint available. Measure which address applications actually use. Roll back the record if errors rise, but keep both endpoints during the cache window. After old traffic drains and rollback risk falls, remove the old endpoint and restore a sustainable TTL.

### Question: Does DNSSEC make service discovery secure?

It secures only part of the chain. DNSSEC lets a validating resolver authenticate DNS data and detect modification when a trust chain exists. The application must trust the validating resolver and the path to it. DNSSEC does not encrypt queries, prove the endpoint is healthy, authenticate an HTTP user, or replace TLS hostname verification and authorization. Secure service discovery combines protected publication, DNSSEC where appropriate, trusted resolver transport, TLS identity, least privilege, audit, and application health verification.

## Independent transfer and rubric

Use ASM-0027 only after completing the answer-isolated lab case. Your response must stand alone. Include:

1. exact failed operation, client, namespace, name, types, deadline, and timestamp;
2. candidate names derived from the supplied search list and `ndots` policy;
3. an upper-bound transaction calculation with assumptions;
4. a table separating application, stub, recursive cache, authority, transport, and endpoint evidence;
5. at least two plausible hypotheses and one disconfirming test for each;
6. interpretation of RCODE, flags, TTL, authority, response size, and TCP comparison;
7. the smallest bounded recovery with owner, blast radius, abort condition, and rollback;
8. verification of the original operation plus resolver and downstream guardrails;
9. one Kubernetes or private-cloud transfer and its changed evidence boundary;
10. prevention covering naming contracts, cache planning, observability, security, capacity, and runbooks.

The independent model must not print a diagnosis or computed answer. `bash lab.sh scenario` exposes raw inputs so you can make a prediction. Observation views remain evidence, not an answer key. The verifier checks output shape, lifecycle, refusal, answer isolation, and cleanup; it cannot judge whether your reasoning is correct.

Self-score only for feedback. A human reviewer must examine the evidence before crediting mastery. A strong response avoids "DNS down," never equates an address with a healthy service, distinguishes NXDOMAIN from timeout and SERVFAIL, explains cache time with units, preserves policy boundaries, and verifies the real user operation.

Passing commands is not mastery. Mastery means you can transfer the reasoning to a new runtime, resolver stack, Kubernetes cluster, private zone, or product design and explain what each piece of evidence proves and cannot prove.

## References and review

This lesson uses eight primary or official sources:

- REF-0065: RFC 1034, DNS concepts, hierarchy, zones, resolvers, recursion, delegation, and caching.
- REF-0066: RFC 1035, DNS message and resource-record implementation details.
- REF-0067: RFC 2308, negative caching and SOA-based negative response behavior.
- REF-0068: RFC 6891, EDNS extension mechanisms and UDP payload signaling.
- REF-0069: RFC 7766, DNS transport over TCP implementation requirements.
- REF-0070: RFC 4033, DNSSEC introduction and security boundaries.
- REF-0071: Linux `resolv.conf(5)`, resolver search, nameserver, timeout, attempts, and `ndots` configuration.
- REF-0072: Kubernetes DNS for Services and Pods, supported service and pod discovery behavior.

The RFCs have updates and operational practice continues to evolve. The reference records capture the reviewed source and review date, but production changes must use current platform documentation and standards. Kubernetes behavior can vary with cluster domain, DNS implementation, feature state, and version.

Review this lesson again by 2027-02-02 or sooner if Ubuntu resolver defaults, Kubernetes DNS behavior, DNS transport guidance, or the content schema changes. Review must include technical accuracy, local lab safety, normal-user Ubuntu verification, answer isolation, links, accessibility of text diagrams, privacy language, and an expert check of DNSSEC and Kubernetes claims.

Publication status is `substantive-draft`. It means the chapter is complete enough for rigorous learning and review; it does not mean the learner demonstrated mastery or that the examples authorize a production change.
