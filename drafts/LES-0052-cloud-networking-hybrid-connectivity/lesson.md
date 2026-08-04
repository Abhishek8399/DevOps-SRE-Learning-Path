---
{"schemaVersion":1,"kind":"lesson","id":"LES-0052","slug":"cloud-networking-hybrid-connectivity","aliases":["V05-L16","cloud-networking-hybrid-connectivity"],"curriculumIds":["CLD-002"],"route":"/book/infrastructure/cloud-networking-hybrid-connectivity","order":16,"volume":"05-infrastructure-platforms","title":"Cloud networking and hybrid connectivity: trace the packet","summary":"Design and troubleshoot VPC/VNet addressing, routes, policy, load balancing, NAT, DNS, peering, transit, private service access, VPN/BGP and hybrid paths by proving forward and return behavior.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":540,"prerequisiteLessonIds":["LES-0009","LES-0010","LES-0011","LES-0013","LES-0014","LES-0015","LES-0016","LES-0050","LES-0051"],"prerequisiteCurriculumIds":["NET-001","NET-002","NET-003","NET-004","NET-005","NET-006","NET-007","CLD-001","IAM-001"],"testedEnvironments":[{"platform":"IETF networking standards","version":"RFC 1918, 3022, 4271, 4301, 4632 and 1034","support":"supported","notes":"Addressing, CIDR, NAT, BGP, IPsec and DNS sources reviewed 2026-08-04."},{"platform":"AWS VPC documentation","version":"current official documentation","support":"concept-only","notes":"VPC, transit and private service mechanisms reviewed 2026-08-04; no account used."},{"platform":"Microsoft Azure networking documentation","version":"current official documentation","support":"concept-only","notes":"VNet, peering and Private Link mechanisms reviewed 2026-08-04; no subscription used."},{"platform":"Google Cloud VPC documentation","version":"current official documentation","support":"concept-only","notes":"Global VPC, regional subnet, peering and Private Service Connect mechanisms reviewed 2026-08-04; no project used."},{"platform":"Ubuntu","version":"24.04 local normal-user model","support":"required","notes":"Deterministic packet-path model; not a provider network emulator."}],"targetRoles":["network-engineer","cloud-engineer","platform-engineer","site-reliability-engineer","devops-engineer","security-engineer","solutions-architect","technical-lead"],"learningObjectives":["Trace a cloud flow from name resolution through forward route, policy, translation, endpoint, application and return route.","Design non-overlapping IPv4/IPv6 address plans with growth, hybrid, service and Kubernetes ranges.","Distinguish network, subnet and route scope across AWS, Azure and Google Cloud.","Reason about longest-prefix selection, dynamic propagation, policy priority and asymmetric paths.","Separate stateful and stateless filtering, network identity and application authorization.","Explain ingress, egress, source NAT, destination NAT, port exhaustion and connection tracking.","Design DNS authority, split-horizon, forwarding and private endpoint resolution without hidden public fallback.","Compare peering, hub-and-spoke transit and mesh without assuming transitivity.","Design VPN/BGP and dedicated hybrid paths with redundant tunnels, route policy, MTU and failover.","Diagnose overlapping CIDR, missing/incorrect route, return-path, firewall, DNS, NAT, MTU and private-service incidents."],"productionSignals":["source and destination identity IP family address port protocol and user operation","DNS query name resolver search path answer TTL authority view and endpoint identity","source network subnet interface route table and longest-prefix selected next hop","dynamic route source prefix AS path local preference MED community propagation and withdrawal","forward and return path hops with zones regions tunnels and appliances","stateful security group stateless ACL distributed firewall policy priority action and log","load balancer frontend listener rule backend health source preservation and timeout","NAT mapping source tuple translated tuple allocation ports connection state and saturation","VPN tunnel IKE/IPsec state BGP neighbor routes bytes drops latency and failover","private endpoint attachment consumer/producer identity DNS binding and policy","MTU MSS fragmentation-needed or packet-too-big evidence and retransmission","flow logs packet capture application logs dependency SLI and user SLI","inter-zone inter-region egress NAT endpoint gateway appliance and dedicated-link cost units"],"diagrams":[{"id":"LES-0052-DIA-001","title":"Forward and return packet path","direction":"left-to-right","boundaries":["client resolver","edge or private endpoint","route","policy","load balancer","backend","dependency","return path"],"evidencePoints":["answer","next hop","decision","translation","health","response"],"textAlternative":"A successful connection requires name resolution, a permitted forward path, a listening healthy endpoint and a permitted symmetric or intentionally asymmetric return path."},{"id":"LES-0052-DIA-002","title":"Address-plan hierarchy","direction":"hierarchical","boundaries":["enterprise IPv4 and IPv6 plan","cloud/environment ranges","regional networks","subnets","service/pod ranges","reserved growth"],"evidencePoints":["owner","scope","overlap","summarization","utilization"],"textAlternative":"Enterprise address space is allocated into non-overlapping provider, environment, region, subnet and workload ranges with explicit owners and growth reserves."},{"id":"LES-0052-DIA-003","title":"Provider scope comparison","direction":"hierarchical","boundaries":["AWS regional VPC and zonal subnet","Azure regional VNet and regional subnet","Google global VPC and regional subnet","zonal interfaces"],"evidencePoints":["resource scope","route scope","failure domain","policy"],"textAlternative":"Provider network and subnet scopes differ, so designs translate mechanisms rather than matching names."},{"id":"LES-0052-DIA-004","title":"Hub transit versus peering mesh","direction":"hierarchical","boundaries":["spokes","direct peerings","transit hub","security appliance","hybrid gateway","shared services"],"evidencePoints":["route propagation","transitivity","blast radius","inspection","cost"],"textAlternative":"Direct peering creates pairwise paths while a transit hub centralizes routing and inspection but also adds shared control, capacity and cost boundaries."},{"id":"LES-0052-DIA-005","title":"Hybrid VPN and BGP path","direction":"left-to-right","boundaries":["on-prem prefix","edge routers","redundant tunnels","cloud gateways","dynamic routes","workload subnet"],"evidencePoints":["BGP session","advertised/accepted prefix","tunnel state","MTU","return route"],"textAlternative":"Hybrid reachability depends on redundant encrypted paths, accepted route advertisements, policy, MTU and a matching return route."},{"id":"LES-0052-DIA-006","title":"Private service access path","direction":"left-to-right","boundaries":["consumer DNS view","private endpoint","consumer policy","provider service attachment","service identity","application"],"evidencePoints":["private answer","endpoint ID","route","authorization","TLS name"],"textAlternative":"Private service access binds a consumer-side private endpoint and DNS answer to a provider service identity; private routing does not replace authentication or authorization."}],"commands":[{"id":"LES-0052-CMD-001","question":"Is the offline network case file valid JSON?","risk":"read-only","command":"python3 -m json.tool fixtures/cases.json >/dev/null","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"exit zero","meaning":"syntax valid","nextEvidence":"semantic validation"},{"when":"nonzero","meaning":"case unusable","nextEvidence":"fix first parse error"}],"proves":"JSON syntax","doesNotProve":"network correctness"},{"id":"LES-0052-CMD-002","question":"What exact flow and topology are under review?","risk":"read-only","command":"python3 model.py show fixtures/cases.json baseline","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"normalized flow prints","meaning":"source destination and controls are bound","nextEvidence":"evaluate"},{"when":"refusal","meaning":"model input invalid","nextEvidence":"inspect reason"}],"proves":"local model inputs","doesNotProve":"provider state"},{"id":"LES-0052-CMD-003","question":"Does the baseline have a complete forward and return path?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json baseline","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"decision=reachable","meaning":"all encoded boundaries pass","nextEvidence":"negative cases"},{"when":"unreachable","meaning":"first encoded boundary fails","nextEvidence":"inspect boundary"}],"proves":"deterministic baseline result","doesNotProve":"real packets"},{"id":"LES-0052-CMD-004","question":"Do address ranges overlap?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json overlapping-cidr","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=address-plan","meaning":"ambiguous connectivity rejected","nextEvidence":"renumber proxy or translation decision"}],"proves":"encoded CIDR overlap","doesNotProve":"enterprise IPAM completeness"},{"id":"LES-0052-CMD-005","question":"Which boundary catches a missing forward route?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json missing-route","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=forward-route","meaning":"no selected next hop","nextEvidence":"route scope and propagation"}],"proves":"modelled route absence","doesNotProve":"provider effective route"},{"id":"LES-0052-CMD-006","question":"Does the destination have a valid return route?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json asymmetric-return","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=return-route","meaning":"reply cannot return through valid state/path","nextEvidence":"reverse route and appliance state"}],"proves":"encoded return failure","doesNotProve":"connection tracking"},{"id":"LES-0052-CMD-007","question":"Is policy denying the selected tuple?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json firewall-deny","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=network-policy","meaning":"route exists but policy denies","nextEvidence":"exact rule priority and scope"}],"proves":"modelled policy denial","doesNotProve":"real rule evaluation"},{"id":"LES-0052-CMD-008","question":"Does private DNS resolve the intended endpoint identity?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json split-dns","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=dns-endpoint","meaning":"name view points to wrong/public endpoint","nextEvidence":"resolver authority and private zone binding"}],"proves":"encoded DNS mismatch","doesNotProve":"live resolver cache"},{"id":"LES-0052-CMD-009","question":"Can egress allocate translation state?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json nat-exhaustion","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=nat-capacity","meaning":"translation ports/state exhausted","nextEvidence":"tuple distribution and gateway capacity"}],"proves":"modelled NAT saturation","doesNotProve":"gateway limits"},{"id":"LES-0052-CMD-010","question":"Can the payload cross every MTU boundary?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json mtu-blackhole","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=mtu-path","meaning":"large packets fail despite handshake reachability","nextEvidence":"PMTUD ICMP MSS and tunnel overhead"}],"proves":"encoded MTU fault","doesNotProve":"live packet size"},{"id":"LES-0052-CMD-011","question":"Does a peering design incorrectly require transit?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json nontransitive-peering","runFrom":"LES-0052 support/lab","expectedBranches":[{"when":"boundary=transitivity","meaning":"A-B and B-C do not imply A-C","nextEvidence":"direct peer or transit mechanism"}],"proves":"modelled nontransitivity","doesNotProve":"provider feature set"},{"id":"LES-0052-CMD-012","question":"Does the guarded Ubuntu verifier cover all packet cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0052 support/lab as normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"baseline eight failures refusals and cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic local teaching model","doesNotProve":"cloud network VPN BGP DNS NAT firewall or production runtime","cleanup":"Verifier proves exact UID-scoped temporary root absent."}],"labs":[{"id":"LES-0052-LAB-001","title":"Guided packet-path decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python; no cloud account","timeMinutes":180,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one baseline and eight synthetic packet-path cases"],"abortConditions":["root","network","credential","provider CLI session","real endpoint","symlink","unknown artifact"],"recovery":"Preserve first failing boundary, correct only copied fixture and rerun.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0052-cloud-networking-hybrid-connectivity/support/lab"},{"id":"LES-0052-LAB-002","title":"Independent hybrid packet-path design and incident transfer","mode":"independent","environment":"Reviewer-owned Linux network namespaces or local simulator with synthetic prefixes only","timeMinutes":240,"privilege":"normal user where supported; reviewer owns any namespace capability","network":"isolated local only","changes":["three local segments","router/firewall/NAT/DNS model","two redundant synthetic hybrid links","fault injections"],"abortConditions":["host default route","corporate network","real VPN","provider resource","credential","public listener","unreviewed namespace privilege","persistent firewall mutation"],"recovery":"Use reviewer harness reset, preserve flow/route/policy evidence and prove host networking unchanged.","cleanupProof":"Reviewer proves namespaces/processes/temp files/routes/rules absent and original host checksums/state unchanged.","path":"drafts/LES-0052-cloud-networking-hybrid-connectivity/support/lab"}],"incidents":[{"id":"LES-0052-INC-001","signal":"Two connected networks cannot exchange routes because their private CIDRs overlap.","firstThought":"Routing cannot uniquely identify the destination; peering, VPN or transit configuration alone cannot remove address ambiguity.","safePath":"Bind both inventories and growth ranges, stop partial workarounds, choose governed renumbering or a narrowly justified proxy/translation boundary, then test return and DNS paths.","trap":"Add more-specific routes without understanding ownership."},{"id":"LES-0052-INC-002","signal":"A hybrid TCP handshake leaves one side but no reply returns.","firstThought":"Forward reachability is only half the connection; route advertisement, filtering, NAT or stateful appliance symmetry may differ in reverse.","safePath":"Trace the identical five-tuple and translated tuple hop-by-hop both ways, inspect effective routes/policy and restore a valid state-aware return path.","trap":"Open every firewall port."},{"id":"LES-0052-INC-003","signal":"Private service name resolves to a public address in one environment.","firstThought":"Resolver path, private zone association/forwarding and endpoint identity differ; routing may be correct for the wrong address.","safePath":"Bind queried name, resolver, search suffix, answer/TTL/authority, private zone attachment and endpoint identity; correct DNS without disabling TLS validation.","trap":"Hard-code an IP in hosts files."},{"id":"LES-0052-INC-004","signal":"New outbound connections fail intermittently under load while existing connections continue.","firstThought":"NAT port or connection-state exhaustion fits better than generic internet failure.","safePath":"Inspect translations, ports, destinations, connection churn and gateway capacity; reduce connection churn, distribute egress or use direct/private/IPv6 paths where designed.","trap":"Retry every request aggressively."},{"id":"LES-0052-INC-005","signal":"Small requests work across VPN but large transfers hang.","firstThought":"Tunnel overhead plus blocked fragmentation-needed/packet-too-big signals can create a path-MTU black hole.","safePath":"Compare interface/tunnel MTU, test size boundary, observe ICMP and TCP MSS/retransmissions, then correct MTU/MSS or filtering across both paths.","trap":"Increase application timeouts."}],"assessmentIds":["ASM-0139","ASM-0140","ASM-0141"],"referenceIds":["REF-0538","REF-0539","REF-0540","REF-0541","REF-0542","REF-0543","REF-0544","REF-0545","REF-0546","REF-0547","REF-0548","REF-0549","REF-0550","REF-0551","REF-0552"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No cloud account, provider CLI, corporate network, real VPN, BGP session or public listener is used.","The model is not a packet forwarder or provider network emulator.","No real route, firewall, DNS, NAT, load balancer, endpoint, tunnel, MTU or cost evidence.","Provider scopes, limits, pricing and behavior are version- and region-dependent.","Formal review, canonical publication and unseen learner evidence remain required."]}
---

# Cloud networking and hybrid connectivity: trace the packet

## What you see and first thought

When an application says “connection timed out,” do not begin by changing firewalls. Name one flow: source identity and IP, destination name and resolved IP, IP family, protocol, source/destination port, expected listener, and timestamp. Then trace the forward packet and the return packet.

Cloud networking is still networking, but control is distributed across provider objects: network/subnet scope, route tables, propagated routes, security groups or firewalls, load balancers, NAT, private endpoints, DNS views, VPN gateways and identity policy. A green object in each console does not prove those objects compose into one working path.

The durable sentence is: **DNS chooses an address; routing chooses a next hop; policy permits a tuple; translation changes a tuple; the service must listen; the return path must work.**

## Terms before commands

A **CIDR prefix** represents an address range; smaller prefix length means a larger range. **Longest-prefix match** selects the most specific applicable route before provider-specific priority rules. A **subnet** allocates addresses and attaches resources to routing/policy behavior; its geographic scope differs by provider.

Read `10.24.16.0/20` as two facts: the first 20 bits identify the network and the remaining 12 bits identify addresses inside it. That gives 4,096 mathematical addresses, but provider-reserved addresses and subnet policy reduce what a workload can actually use. Two ranges **overlap** when at least one address belongs to both. A route cannot reliably distinguish the intended owner of the same destination address on both sides of a peering or hybrid link.

A **route table** is desired routing policy. An **effective route** is the route a specific interface can actually use after local, static, propagated, peering and provider-system routes are combined. A **next hop** is the immediate forwarding target, not necessarily the final server. A **gateway** joins routing domains. A cloud **network interface** is the attachment that owns addresses and receives policy; names include ENI, NIC and virtual interface depending on provider.

**Ingress** and **egress** describe direction relative to a boundary. A **stateful** firewall can allow return traffic for an accepted connection; a **stateless** filter evaluates each direction separately. Statefulness never fixes a missing route.

**SNAT** changes the source, usually for outbound connectivity. **DNAT** changes the destination, often at an ingress or load-balancer boundary. NAT provides address translation, not application authentication. **Peering** connects two networks directly but is commonly non-transitive. A **transit hub** routes among many attachments. A **VPN** protects traffic across an untrusted path; **BGP** exchanges reachability and policy, not application health.

The **control plane** accepts objects such as routes, peers, firewall rules and endpoints. The **data plane** forwards or drops actual packets from those objects. A successful control-plane API call is therefore not packet evidence. **MTU** is the largest packet an interface/path can carry without fragmentation behavior; **MSS** is the TCP payload limit advertised by endpoints. Tunnel headers consume part of the path MTU. A **flow log** is sampled or aggregated metadata about observed decisions, not a packet capture and not an application trace.

## Architecture map

```text
client -> resolver -> destination address
   |                    |
source subnet -> effective route -> policy -> NAT/endpoint/LB -> backend
                                                        |          |
                                                    health      dependency
                                                        \__________/
                                                         return route

on premises -> routers == redundant VPN/dedicated paths == cloud transit -> VPC/VNet
```

Scope is a design input. An AWS VPC is regional and its subnet is tied to one Availability Zone. An Azure VNet and its subnets are regional and can contain zonal resources. A Google Cloud VPC is global while subnets are regional. Treating those names as equivalent produces wrong failure and route assumptions.

| Question | AWS mechanism | Azure mechanism | Google Cloud mechanism | Design warning |
|---|---|---|---|---|
| network scope | regional VPC | regional VNet | global VPC network | identical names do not imply identical failure domains |
| subnet scope | one Availability Zone | regional subnet | regional subnet | bind the interface zone and provider contract |
| pairwise private connection | VPC peering | VNet peering | VPC Network Peering | connected does not imply transitive routing or shared DNS |
| many-network hub | Transit Gateway family | hub VNet/Virtual WAN family | Network Connectivity Center family | a hub adds shared policy, capacity, quota and blast radius |
| consumer private service path | interface endpoint/PrivateLink | private endpoint/Private Link | endpoint or backend through Private Service Connect | private addressing does not replace TLS or IAM |

This table is a translation aid, not a feature-equivalence promise. Before implementation, verify current provider documentation, region, resource tier, route limits, IPv6 behavior, cross-zone/region charging and the exact data path.

## Request or state path

Start before the packet: the application chooses a hostname, resolver and address family. The resolver may use local cache, private zone, conditional forwarder, cloud resolver, on-premises authority or public DNS. Record the answer, TTL and authority.

At the source interface, determine the effective route using destination prefix, propagation and priority. Follow every next hop: local fabric, peering, transit, appliance, NAT, VPN, private endpoint or internet edge. At each policy boundary evaluate the actual tuple after any translation.

At a proxy load balancer, the client TCP connection may terminate and a new backend connection begins. At a passthrough balancer, the backend can see the original flow. Health checks use their own sources and paths; a healthy backend may still fail the user’s dependency.

Trace the reply independently. Asymmetric routing can be valid if appliances and state support it, but unexpected asymmetry often drops stateful flows. Bind both original and translated tuples.

For example, a client may start as `10.10.4.21:53144 -> 10.40.8.15:443`. An egress gateway can change it to `172.20.0.9:42001 -> 10.40.8.15:443`; a proxy load balancer can then originate a separate backend connection such as `10.40.1.7:37862 -> 10.40.8.15:8443`. Those are different state records with different timeouts and policy. Saying only "port 443 is open" loses the evidence needed to debug them.

The return journey must reverse the correct state: backend to proxy, proxy to translated client, gateway translation back to the original client tuple. A route that sends the reply through a different stateful appliance can fail even when both paths are individually routable. That is why a topology diagram without tuple transformations is incomplete.

## Failure zoom

If DNS returns no answer, wrong view or public address, routing edits are premature. If the source has no route, inspect scope and propagation. If the route exists but flow logs show deny, bind the exact rule and priority. If SYN arrives but SYN-ACK leaves elsewhere, investigate reverse route, NAT and stateful appliance symmetry.

If connection establishment succeeds but payload stalls, investigate MTU, fragmentation signals, MSS, TLS and application behavior. VPN, encapsulation and overlays reduce effective MTU. Blocking required ICMP can turn path-MTU discovery into a silent black hole.

If failure appears only under concurrency, inspect NAT ports, load-balancer connection state, ephemeral ports, conntrack, gateway throughput and DNS/query limits. Retries can amplify every one of them.

## Internals and state ownership

Do not memorize one universal route-precedence list. Longest-prefix match is the durable first question, but providers differ when route sources have the same prefix length, and some objects add route priority or policy before forwarding. Record the exact effective route at the failing interface and the provider rule that selected it. For BGP, compare what the neighbor advertised, what policy accepted, what became best and what the data plane installed. A prefix present in one of those views can be absent in the next.

Routes are declarations in provider control planes and entries in effective dataplane forwarding. Static routes, subnet routes, peering routes and BGP routes can compete. “Propagated” does not mean accepted; prefix filters, maximums, priorities and overlap rules matter. BGP session `Established` proves neighbor protocol state, not correct advertised/accepted prefixes or usable applications.

Cloud firewalls may be attached to interfaces, instances, tags, identities, subnets or hierarchical policies. Distinguish the administrator who can edit policy from the workload identity the rule targets. Record default and explicit denies, direction, statefulness, priority and logging.

Stateful policy remembers an accepted flow so the related response can be allowed without a mirror rule. It does not invent a reverse route, repair NAT state or authorize a new independent connection. Stateless policy evaluates both directions, so the return ephemeral-port range and rule order matter. Central inspection appliances add another state table; design route symmetry or explicitly prove that state is synchronized/shared.

NAT allocates translation state from source addresses and ports. Capacity depends on gateway addresses, destinations, protocols, connection reuse and timeouts. Many clients targeting the same destination tuple can exhaust a subset of available translations before bandwidth is full.

Private service access introduces consumer and producer control planes. A private endpoint places or presents an address in the consumer path while attaching to a service identity. DNS must point the service name to the correct private endpoint, and application/TLS/IAM authorization still applies.

Address planning is also state ownership. Keep an IPAM record for every allocation, owner, environment, region, purpose, routability, lifecycle and reserved growth range. Include Kubernetes Pod/Service ranges, managed-service ranges, partner networks, VPN pools and both address families. Summarizable allocations reduce route count, but an oversized allocation wastes scarce IPv4 space. Dual stack reduces some NAT pressure; it does not remove firewall, DNS, routing or application-readiness work.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| name resolves privately | resolver, answer, TTL, authority/view and endpoint ID | route or TLS works |
| route exists | effective route at exact source and selected next hop | policy or return path |
| policy allows | evaluated/logged tuple after translation and rule priority | listener or application health |
| peering connected | both sides accepted plus exchanged routes | transitive or DNS access |
| hybrid healthy | redundant tunnel/link, BGP, correct accepted prefixes and traffic | application SLI |
| NAT has capacity | allocation/port/state utilization and error counters | destination health |
| load balancer healthy | listener/rule/backend health and health-check path | real user dependency |
| MTU works | payload-size boundary, PMTUD/ICMP/MSS and retransmission evidence | every alternate path |
| incident recovered | forward/return probes, application transaction and reconciled control state | recurrence prevention |

## Command decoders

The lab commands evaluate synthetic metadata only. They intentionally follow dependency order: address plan, DNS/endpoint, forward route, transitivity, policy, NAT, MTU, return route and application. The first failure is a starting boundary, not proof that later boundaries are healthy.

In real Linux work, `ip route get <destination>` shows the local kernel’s selected route, not cloud effective routes or the remote return. `dig` shows a resolver’s answer, not connectivity. `nc` can prove a TCP connection from one context, not application correctness. `tracepath` helps infer MTU/hops but provider fabrics may hide or rate-limit responses. Packet capture needs authorization and still shows only the capture point.

Provider reachability analyzers reason from configured state; they may not model every appliance, DNS response, dynamic application or return-state behavior. Use them as one evidence source.

## Decision path

1. Define source, destination name, expected identity, address family, protocol, port, timestamp and user operation.
2. Bind resolver path, answer, TTL, authority and private/public endpoint.
3. Check address ownership and overlaps across cloud, on-premises, Kubernetes, partners and future allocations.
4. Determine source interface/subnet and effective longest-prefix route.
5. Trace every forward hop and route domain, including peering/transit and appliances.
6. Evaluate policy at each boundary using the tuple present there.
7. Record NAT/load-balancer translations and state.
8. Prove destination listener, health and dependency behavior.
9. Trace return route and reverse policy using translated tuples.
10. If size/load dependent, inspect MTU, ports, conntrack, quotas and throughput.
11. Correlate flow, DNS, tunnel/BGP, application and user evidence.
12. Fix the earliest confirmed boundary, rerun both directions and remove temporary access.

## Guided Ubuntu lab

Run `bash lab.sh doctor`, `setup`, `list`, then `evaluate baseline`. Evaluate the eight failures: overlap, missing route, asymmetric return, policy deny, split DNS, NAT exhaustion, MTU black hole and non-transitive peering.

Work from the lesson lab directory and stay a normal user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh evaluate baseline
```

`doctor` should report the local Bash/Python prerequisites and refuse credential-bearing or root execution. `setup` copies only the deterministic fixture into a UID-scoped temporary root. `list` should show exactly the declared baseline and eight failures. The baseline must end with `decision=reachable`; this proves only that every encoded field in the synthetic case passes.

Now evaluate each negative case rather than guessing from its name:

```bash
for case_name in overlapping-cidr missing-route asymmetric-return firewall-deny split-dns nat-exhaustion mtu-blackhole nontransitive-peering; do
  bash lab.sh evaluate "$case_name"
done
```

The first boundaries should be `address-plan`, `forward-route`, `return-route`, `network-policy`, `dns-endpoint`, `nat-capacity`, `mtu-path` and `transitivity`. If a different boundary appears, stop: the fixture or model has changed, and your written reasoning no longer matches the evidence. A failure at one boundary does not prove later boundaries healthy; it only identifies the earliest encoded blocker.

For each, write the exact observed tuple, first boundary, one distinguishing piece of evidence and one dangerous “fix” you refuse. Finish with `status` and `cleanup`. The harness refuses root, credential environment, symlinks and unknown state and makes no network calls.

```bash
bash lab.sh status
bash lab.sh cleanup
bash lab.sh status
```

Before cleanup, status should identify only the bounded UID-scoped lab state. After cleanup, it must report absence. If it reports an unknown file, owner, path or symlink, do not delete it manually; preserve the refusal and inspect why ownership can no longer be proved. The verifier runs the same lifecycle plus negative/refusal checks, but a passing verifier is project evidence, not proof that you can diagnose an unseen network.

## Production transfer

Use only a reviewer-owned isolated namespace or simulator. Build client, hub and service segments with synthetic documentation prefixes. Add a resolver, router/firewall/NAT model and two redundant hybrid links. Record original and translated tuples, route choices and allowed/denied policy.

Inject route withdrawal, wrong DNS view, asymmetric appliance return, NAT pressure and MTU reduction. Recover through reviewed config, verify a user-like transaction and prove the host’s original routes/firewall/listeners are unchanged. Provider-specific translation is a design review, not a cloud deployment.

## Reliability, security, observability, capacity, and cost

Reliability requires redundant paths whose gateways, tunnels, routers, power, provider edge and on-premises devices do not share the same failure. Test route withdrawal and convergence. A backup tunnel that never carries probes may be silently broken. Central transit simplifies policy but creates shared capacity and change blast radius.

Security uses least-reachability plus workload/application identity. Private address does not mean trusted, peering does not merge policies, and encryption does not authorize a peer. Restrict route and DNS administration, validate advertised prefixes, log decisions and protect management planes.

Observe DNS answer/latency/failure, effective routes and changes, policy allow/deny, flow tuples, NAT allocation, load-balancer health/connection state, tunnel/BGP status and prefixes, loss/latency/jitter/MTU, endpoint identity and user SLIs. Sampling and aggregation limit what flow logs prove.

Capacity includes addresses, routes/prefixes, peerings/attachments, firewall rules, NAT ports, connections, packets/bytes, tunnels, BGP prefixes, resolver QPS and appliance throughput. Cost includes cross-zone/region/provider transfer, NAT processing, endpoint hours/data, transit processing, load balancers, VPN/dedicated circuits, public IPs, logs and appliances.

## Traps and prevention

- **Trap:** Connected objects imply reachability. **Prevention:** prove DNS, route, policy, listener and return path.
- **Trap:** RFC 1918 addresses never overlap. **Prevention:** enterprise IPAM with owners and reserved growth.
- **Trap:** Peering is transitive. **Prevention:** verify provider contract; use explicit transit when required.
- **Trap:** Route exists, so firewall is wrong. **Prevention:** inspect first failing boundary in order.
- **Trap:** Stateful means reverse routing is unnecessary. **Prevention:** packets still need a valid state-aware return path.
- **Trap:** NAT is security. **Prevention:** enforce policy and identity separately.
- **Trap:** Private endpoint fixes DNS automatically everywhere. **Prevention:** design resolver views/forwarding and validate endpoint identity.
- **Trap:** BGP up means app works. **Prevention:** inspect exact prefixes, dataplane and user transaction.
- **Trap:** Small ping proves large TLS/HTTP works. **Prevention:** test MTU and real protocol payload safely.
- **Trap:** Mesh is most resilient. **Prevention:** compare route scale, policy, operations, blast radius and cost.

## Memory card and retrieval

Remember **NAME → ADDRESS → ROUTE → POLICY → TRANSLATE → LISTEN → RETURN → USER**.

Tomorrow answer: Why can two private networks fail to peer? Why are AWS, Azure and Google subnets not the same scope? Why does peering not imply transit or DNS? Why do existing NAT connections survive while new ones fail? Why can VPN pass small requests and hang on large ones?

## Complete answers

**How do I debug timeout?** Bind one flow, resolve the name from the failing context, find effective forward route, evaluate policy, record translations, verify listener/application, then trace the return. Branch to MTU or capacity only when size/load evidence supports it.

**Peering or transit hub?** Peering is simple for a small number of direct relationships and preserves administrative separation, but pair count and distributed policy grow and transit is commonly absent. A hub centralizes connectivity, inspection and hybrid access, but adds shared capacity, route policy, cost and blast radius. Choose from topology and operations, not fashion.

**VPN or dedicated connection?** VPN is encrypted over an underlay and often faster to provision; dedicated connectivity can offer predictable private paths/capacity but still needs routing, redundancy and sometimes encryption. Many production designs use both for resilience. Neither guarantees application availability.

**What about overlapping CIDR?** Prefer governed renumbering before connectivity. Translation or proxies can bridge constrained migrations but add DNS, identity, observability, troubleshooting and port/state complexity. Document the debt and exit.

**Does private endpoint mean secure?** It removes or reduces public network exposure for a service path. You still need correct DNS, consumer/producer authorization, TLS identity, data controls, logging and lifecycle ownership.

## Product-company interview

**Question:** Design hybrid connectivity for 100 cloud networks, two data centers and shared security services.

**Strong answer:** I start with non-overlapping IPv4/IPv6 IPAM, owners, route summarization and Kubernetes/service reserves. Pairwise mesh is operationally expensive, so I evaluate regional/global transit hubs with isolated route domains for production, nonproduction and shared services. Each data center has physically diverse edge devices and redundant VPN or dedicated links with BGP filters, prefix maximums, preference and tested withdrawal. Spokes advertise only intended prefixes; security inspection preserves symmetry and has capacity/fail-open/closed decisions. DNS uses documented conditional forwarding and private zones with independent health. I monitor accepted prefixes, route age, tunnel/link health, flows, NAT, MTU and user transactions. I model inter-zone/region/transit/egress/log cost and test a link, router, hub and DNS failure before production.

**Weak answer:** Peer every VPC and add a VPN to on-premises. It ignores non-transitivity, route scale, overlap, redundancy, DNS, inspection, capacity, cost and recovery.

## Independent transfer and rubric

`ASM-0141` is reviewer-only. The unseen case combines overlapping space, split DNS, non-transitive peering, route preference, stateful appliance asymmetry, NAT pressure and MTU behavior. The learner must trace one flow both directions and redesign connectivity across three provider mappings.

Evidence binds source/destination identity, DNS view, exact prefixes, selected routes, policy, translations, MTU, endpoint, user outcome, cost and cleanup. Reading and deterministic output do not award mastery; reviewer observation, changed-case reasoning, delayed recall and disposable runtime evidence are required.

## References and review

Fifteen IETF and current provider sources cover private addressing/CIDR, NAT, DNS, BGP, IPsec, VPC/VNet scope, peering/transit and private service access. Reviewed 2026-08-04; review due 2027-02-04.

Provider routing, limits, pricing and feature scope change. Bind provider, account/subscription/project, region, network/subnet, gateway/endpoint type, route/policy revision and price date before implementation.
