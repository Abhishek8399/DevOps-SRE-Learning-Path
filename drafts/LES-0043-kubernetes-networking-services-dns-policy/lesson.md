---
{
  "schemaVersion":1,"kind":"lesson","id":"LES-0043","slug":"kubernetes-networking-services-dns-policy","aliases":["V05-L07","kubernetes-networking-services-dns-policy"],"curriculumIds":["K8S-003"],"route":"/book/infrastructure/kubernetes-networking-services-dns-policy","order":7,"volume":"05-infrastructure-platforms",
  "title":"Kubernetes networking: trace Pods, Services, DNS, gateways, and policy hop by hop",
  "summary":"Trace a request through Pod networking, Service and EndpointSlice selection, DNS, node dataplanes, ingress or Gateway API, NetworkPolicy and the return path using boundary-specific evidence.",
  "domain":"infrastructure","level":{"from":"intermediate","to":"advanced"},"estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0004","LES-0013","LES-0014","LES-0015","LES-0016","LES-0041","LES-0042"],"prerequisiteCurriculumIds":["NET-003","NET-004","NET-005","NET-006","K8S-001","K8S-002"],
  "testedEnvironments":[
    {"platform":"Kubernetes documentation","version":"v1.36 current documentation","support":"supported","notes":"Official Service, EndpointSlice, DNS, Ingress, Gateway, NetworkPolicy, virtual-IP, topology and debugging sources reviewed 2026-08-04."},
    {"platform":"Gateway API documentation","version":"current documentation","support":"supported","notes":"API roles, GatewayClass, Gateway, routes and attachment reviewed 2026-08-04."},
    {"platform":"CNI specification","version":"current specification","support":"supported","notes":"Plugin invocation and result boundary reviewed 2026-08-04."},
    {"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No Linux Docker engine and WSL access denied; no real packet or policy evidence."},
    {"platform":"Cloud","version":"not used","support":"unsupported","notes":"No managed load balancer, public IP, DNS zone, credential or billable object."}
  ],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","kubernetes-engineer","network-engineer","security-engineer","technical-lead"],
  "learningObjectives":[
    "Trace Pod-to-Pod, Pod-to-Service, ingress-to-Service and response traffic through exact identities and hops.",
    "Separate the Kubernetes network model, CNI plugin, Service dataplane, DNS and application listener boundaries.",
    "Explain Service selectors, ports, targetPorts, EndpointSlices, readiness and session affinity.",
    "Diagnose DNS search paths, ndots, service records, headless Services and stale or missing answers.",
    "Compare ClusterIP, NodePort, LoadBalancer, ExternalName and headless Services without inventing portability.",
    "Distinguish Ingress resources/controllers from Gateway API roles, listeners, routes and attachment.",
    "Reason about NetworkPolicy additive isolation, ingress/egress direction, peers, ports and plugin enforcement.",
    "Use packet, socket, API, DNS and user evidence without relying on ping as a universal test.",
    "Diagnose selector mismatch, wrong targetPort, unready endpoints, DNS failure, policy denial and asymmetric return paths.",
    "Design observable, least-privilege, topology-aware service paths and verify them from user request to backend revision."
  ],
  "productionSignals":["context namespace source/destination Pod UIDs and node names","source/destination IP family addresses ports protocol and SNI/Host","Service UID type clusterIP ports targetPorts selectors and traffic policies","EndpointSlice addressType endpoints readiness serving terminating nodeName zone and targetRef UID","DNS query name type search list ndots server answer TTL latency and response code","Pod route table interfaces addresses neighbors sockets and conntrack evidence","CNI configuration/plugin result and node dataplane mode/version","kube-proxy or replacement health rules programming latency and sync errors","IngressClass/controller or GatewayClass/Gateway/listener/route attachment and conditions","NetworkPolicy selected Pods policyTypes peers ports and plugin decision logs","load-balancer health checks source ranges external/internal policy and address","HTTP/TLS request status latency headers certificate served backend revision and retries","drops retransmits resets timeouts MTU fragmentation and asymmetric route evidence","cleanup inventory finalizers cloud artifacts addresses routes and policies"],
  "diagrams":[
    {"id":"LES-0043-DIA-001","title":"Pod-to-Service request path","direction":"left-to-right","boundaries":["source process","Pod socket","veth","node dataplane","Service VIP","EndpointSlice","destination Pod","return path"],"evidencePoints":["5-tuple","route","VIP","endpoint UID","node","response"],"textAlternative":"A source process emits a five-tuple through the Pod and node dataplane; Service selection maps the virtual address to a ready endpoint and return traffic must reach the source."},
    {"id":"LES-0043-DIA-002","title":"Name to endpoint chain","direction":"left-to-right","boundaries":["application name","resolver search","CoreDNS","Service record","ClusterIP or Pod records","EndpointSlice"],"evidencePoints":["qname","qtype","rcode","answer","TTL","endpoint readiness"],"textAlternative":"A short name is expanded by resolver rules, answered by cluster DNS, resolved to a Service virtual IP or headless Pod addresses, then connected through endpoint state."},
    {"id":"LES-0043-DIA-003","title":"Service object contract","direction":"hierarchical","boundaries":["selector","port","targetPort","EndpointSlice","readiness","traffic policy","session affinity"],"evidencePoints":["labels","named port","addressType","conditions","node locality"],"textAlternative":"Service selector and port mapping produce EndpointSlices; readiness and traffic policy determine eligible destinations."},
    {"id":"LES-0043-DIA-004","title":"North-south routing","direction":"left-to-right","boundaries":["client","DNS","external address","load balancer","Gateway or Ingress controller","listener","route","Service","Pod"],"evidencePoints":["A/AAAA","SNI","Host","status","route condition","backend revision"],"textAlternative":"An external client resolves an address, reaches a load balancer and data-plane controller, matches listener and route, then reaches a Service and Pod."},
    {"id":"LES-0043-DIA-005","title":"NetworkPolicy decision","direction":"top-to-bottom","boundaries":["source identity","source egress isolation","egress rule","destination ingress rule","destination isolation","port protocol"],"evidencePoints":["namespace labels","Pod labels","ipBlock","policyTypes","deny log"],"textAlternative":"A connection must satisfy applicable source egress and destination ingress policy; policies are additive within each direction and only enforced by supporting networking implementations."},
    {"id":"LES-0043-DIA-006","title":"Layered failure localization","direction":"top-to-bottom","boundaries":["DNS","route","transport","TLS","HTTP","Service","endpoint","application"],"evidencePoints":["rcode","SYN","reset","certificate","status","VIP","targetPort","revision"],"textAlternative":"Each layer has a discriminating probe; success at one boundary narrows but never proves later boundaries."}
  ],
  "commands":[
    {"id":"LES-0043-CMD-001","question":"Which source and destination identities define this flow?","risk":"read-only","command":"kubectl get pod -n atlas-net -o wide; kubectl get service,endpointslice -n atlas-net -o wide","runFrom":"approved local context","expectedBranches":[{"when":"UIDs IPs nodes and endpoint targets match","meaning":"flow identity is bound","nextEvidence":"resolve name and ports"},{"when":"identity differs","meaning":"wrong lifetime or namespace","nextEvidence":"stop before mutation"}],"proves":"reported object/IP mapping","doesNotProve":"connectivity"},
    {"id":"LES-0043-CMD-002","question":"What exact DNS query and answer does the workload receive?","risk":"read-only","command":"kubectl exec -n atlas-net SOURCE -- getent hosts atlas-api.atlas-net.svc.cluster.local","runFrom":"approved source Pod with preloaded diagnostic binary","expectedBranches":[{"when":"expected address returned","meaning":"resolver path answered","nextEvidence":"connect to exact port"},{"when":"no answer","meaning":"name/resolver/DNS path failed","nextEvidence":"inspect resolv.conf and DNS"}],"proves":"one in-Pod resolver result","doesNotProve":"Service reachability"},
    {"id":"LES-0043-CMD-003","question":"Do Service selectors create the expected ready endpoints?","risk":"read-only","command":"kubectl get service atlas-api -n atlas-net -o yaml; kubectl get endpointslice -n atlas-net -l kubernetes.io/service-name=atlas-api -o yaml","runFrom":"approved namespace","expectedBranches":[{"when":"targetRef UIDs ports and ready conditions match","meaning":"Service has eligible backends","nextEvidence":"test VIP and direct endpoint"},{"when":"empty or unready","meaning":"selection/readiness is broken","nextEvidence":"compare labels and probes"}],"proves":"API endpoint membership","doesNotProve":"dataplane programming"},
    {"id":"LES-0043-CMD-004","question":"Is port mapping correct from Service port to container listener?","risk":"read-only","command":"kubectl get service atlas-api -n atlas-net -o jsonpath='{.spec.ports}'; kubectl get pod POD -n atlas-net -o jsonpath='{.spec.containers[*].ports}'","runFrom":"approved namespace","expectedBranches":[{"when":"targetPort resolves to listening application port","meaning":"declaration aligns","nextEvidence":"inspect socket and connect"},{"when":"name/number differs","meaning":"traffic targets wrong port","nextEvidence":"fix owner manifest"}],"proves":"declared mapping","doesNotProve":"process is listening"},
    {"id":"LES-0043-CMD-005","question":"Can the source reach direct Pod IP and Service VIP separately?","risk":"read-only","command":"kubectl exec -n atlas-net SOURCE -- sh -c 'curl -fsS --max-time 3 http://POD_IP:8080/ready; curl -fsS --max-time 3 http://SERVICE_IP:80/ready'","runFrom":"approved diagnostic Pod","expectedBranches":[{"when":"Pod works VIP fails","meaning":"application path works but Service dataplane fails","nextEvidence":"inspect EndpointSlice and node dataplane"},{"when":"both fail","meaning":"common route policy listener or application boundary","nextEvidence":"inspect sockets and policy"}],"proves":"two bounded application connections","doesNotProve":"external route or all endpoints"},
    {"id":"LES-0043-CMD-006","question":"What resolver configuration expands short names?","risk":"read-only","command":"kubectl exec -n atlas-net SOURCE -- cat /etc/resolv.conf; kubectl get configmap coredns -n kube-system -o yaml","runFrom":"approved cluster operator context","expectedBranches":[{"when":"nameserver search and ndots match cluster domain","meaning":"client-side DNS contract is visible","nextEvidence":"query FQDN and short name"},{"when":"unexpected resolver path","meaning":"Pod DNS policy/config changed","nextEvidence":"trace configuration owner"}],"proves":"reported resolver and CoreDNS config","doesNotProve":"DNS availability or correctness"},
    {"id":"LES-0043-CMD-007","question":"Is NetworkPolicy selecting and allowing the intended flow?","risk":"read-only","command":"kubectl get networkpolicy -n atlas-net -o yaml; kubectl get pod -n atlas-net --show-labels","runFrom":"approved namespace","expectedBranches":[{"when":"source egress and destination ingress both allow port/protocol","meaning":"declared policy permits flow","nextEvidence":"test and inspect plugin decision"},{"when":"one direction lacks allowance","meaning":"declared isolation denies flow","nextEvidence":"change least-privilege rule"}],"proves":"policy declarations and labels","doesNotProve":"plugin enforcement"},
    {"id":"LES-0043-CMD-008","question":"Are Gateway listeners and routes accepted and attached?","risk":"read-only","command":"kubectl get gateway,httproute -n atlas-net -o yaml","runFrom":"approved namespace","expectedBranches":[{"when":"Accepted and ResolvedRefs are true with correct parents","meaning":"control-plane attachment succeeded","nextEvidence":"test listener address Host and path"},{"when":"false or absent","meaning":"class listener reference or policy blocked attachment","nextEvidence":"read condition reason"}],"proves":"Gateway API status","doesNotProve":"data-plane traffic"},
    {"id":"LES-0043-CMD-009","question":"What does a real HTTP/TLS request prove at the external boundary?","risk":"read-only","command":"curl --fail-with-body --connect-timeout 3 --max-time 8 --resolve app.example.test:443:ADDRESS https://app.example.test/version","runFrom":"approved local client and test certificate trust","expectedBranches":[{"when":"expected certificate status and revision return","meaning":"one complete request succeeded","nextEvidence":"repeat across backends"},{"when":"DNS bypass works but normal name fails","meaning":"external DNS boundary is isolated","nextEvidence":"repair record/resolver"}],"proves":"one TLS/HTTP route and revision","doesNotProve":"all clients/endpoints"},
    {"id":"LES-0043-CMD-010","question":"What sockets and routes exist inside the destination Pod?","risk":"read-only","command":"kubectl exec -n atlas-net DEST -- sh -c 'ip address; ip route; ss -lntup'","runFrom":"approved diagnostic image or ephemeral container","expectedBranches":[{"when":"expected address route and listener exist","meaning":"Pod network namespace and process socket align","nextEvidence":"inspect packet path"},{"when":"listener only on loopback or wrong port","meaning":"Service cannot reach it","nextEvidence":"fix application bind"}],"proves":"one namespace network/socket view","doesNotProve":"node or external reachability"},
    {"id":"LES-0043-CMD-011","question":"Where do transport attempts stop?","risk":"read-only","command":"kubectl exec -n atlas-net SOURCE -- sh -c 'curl -sv --connect-timeout 3 --max-time 8 http://atlas-api:80/version 2>&1'","runFrom":"approved source Pod","expectedBranches":[{"when":"name resolves then connection times out","meaning":"DNS succeeded and transport/data path lacks response","nextEvidence":"compare direct endpoint and policy"},{"when":"connection refused","meaning":"destination actively rejected or no listener","nextEvidence":"inspect listener/targetPort"}],"proves":"client-visible resolution/connect/TLS/HTTP sequence","doesNotProve":"packet-drop owner alone"},
    {"id":"LES-0043-CMD-012","question":"Does the deterministic network-path model localize seven failures and clean up exactly?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0043 support/lab as normal Ubuntu user","expectedBranches":[{"when":"verification pass","meaning":"model cases/refusals/cleanup passed","nextEvidence":"retain model-only label"},{"when":"assertion fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic model source/run","doesNotProve":"CNI DNS Service policy Gateway or packets","cleanup":"verifier proves exact absence"}
  ],
  "labs":[
    {"id":"LES-0043-LAB-001","title":"Guided request-path localization model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no cluster","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temp root","seven deterministic failure paths"],"abortConditions":["root","network","kubectl","socket","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failed hop, correct model state, rerun clean.","cleanupProof":"Validate exact inventory and remove exact root.","path":"drafts/LES-0043-kubernetes-networking-services-dns-policy/support/lab"},
    {"id":"LES-0043-LAB-002","title":"Independent pinned local-cluster service-path transfer","mode":"independent","environment":"Reviewer-owned disposable cluster with preloaded diagnostics and dedicated namespaces","timeMinutes":240,"privilege":"namespace-scoped learner; reviewer owns nodes","network":"local cluster only","changes":["two services","DNS/selector/port/policy faults","Gateway route","packet evidence"],"abortConditions":["wrong context","cluster-admin","external endpoint","host network","privileged capture","unreviewed node rules","public load balancer"],"recovery":"Preserve hop evidence and repair only owning manifest/controller.","cleanupProof":"Reviewer proves namespaces, policies, routes, addresses, credentials and cluster absent.","path":"drafts/LES-0043-kubernetes-networking-services-dns-policy/support/lab"}
  ],
  "incidents":[
    {"id":"LES-0043-INC-001","signal":"Service name resolves but connection times out.","firstThought":"DNS completed; transport, Service dataplane, policy, endpoint or return path remains.","safePath":"Bind five-tuple, compare direct endpoint and VIP, inspect EndpointSlice, policy, node/dataplane and return route.","trap":"Restart CoreDNS."},
    {"id":"LES-0043-INC-002","signal":"Service has no EndpointSlices with ready addresses.","firstThought":"Selector/readiness/port publication is broken before VIP forwarding.","safePath":"Compare Service selector to current Pod labels/UIDs and readiness; correct owner.","trap":"Edit EndpointSlice by hand."},
    {"id":"LES-0043-INC-003","signal":"Pod IP works but ClusterIP fails.","firstThought":"Application/listener and one Pod path work; investigate Service mapping and dataplane.","safePath":"Verify targetPort/EndpointSlice then node proxy or replacement programming and policy.","trap":"Change application code first."},
    {"id":"LES-0043-INC-004","signal":"Same-node clients work but cross-node clients fail.","firstThought":"Overlay/routing/MTU/firewall/return path differs across nodes.","safePath":"Compare exact five-tuple, routes, encapsulation, MTU, node firewall and CNI health on both paths.","trap":"Assume Service selector because one path works."},
    {"id":"LES-0043-INC-005","signal":"Gateway route Accepted is false or ResolvedRefs false.","firstThought":"Control-plane attachment/reference failed before data-plane traffic.","safePath":"Read parent/listener/hostname/namespace/reference-grant/class conditions and controller events.","trap":"Debug backend Pods before route attachment."}
  ],
  "assessmentIds":["ASM-0112","ASM-0113","ASM-0114"],"referenceIds":["REF-0403","REF-0404","REF-0405","REF-0406","REF-0407","REF-0408","REF-0409","REF-0410","REF-0411","REF-0412","REF-0413","REF-0414","REF-0415","REF-0416","REF-0417"],
  "contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04",
  "limitations":["No cluster, packet, DNS, Service, CNI, policy or Gateway runtime executed.","The model is not network runtime evidence.","No public address, cloud load balancer, credential, privileged capture or production traffic.","Formal review and learner evidence absent."]
}
---

# Kubernetes networking: trace Pods, Services, DNS, gateways, and policy hop by hop

## What you see and first thought

The client says “connection timed out.” Do not answer “Kubernetes networking is broken.” First write the exact source identity, destination name/IP, port, protocol and time. Then locate the last proven hop.

```text
name -> DNS answer -> route -> TCP/UDP -> TLS -> HTTP
                    -> Service VIP -> EndpointSlice -> Pod listener -> response
```

If DNS returned an address, restarting DNS is not the first action. If direct Pod IP works but ClusterIP fails, the application is less likely than Service mapping or dataplane. If same-node works and cross-node fails, compare overlay/routing/MTU/firewall and the return path.

## Terms before commands

**Kubernetes network model** expects each Pod to have a cluster-unique address and Pod-to-Pod communication without application-visible NAT in the basic model. An implementation must realize this; Kubernetes does not mandate one overlay, router or dataplane.

**CNI** is the runtime/plugin contract used to configure container network interfaces. A CNI plugin can allocate addresses and program network state, but Services and NetworkPolicy may be implemented by related or separate components.

**Service** is a stable API abstraction over changing backends. `ClusterIP` is normally virtual. `NodePort` exposes a port on nodes. `LoadBalancer` asks an integration to provision or connect external load balancing. `ExternalName` returns DNS alias behavior. A headless Service has no ClusterIP and publishes endpoint addresses through DNS.

**EndpointSlice** represents backend addresses, ports, address family, conditions, topology and target references. Service selector/controller behavior normally manages slices; operators should not hand-edit generated slices.

**kube-proxy or replacement** implements Service virtual-IP forwarding, often through iptables, IPVS, nftables or eBPF depending on environment. Do not invent the mode—inspect the actual cluster.

**CoreDNS** commonly serves cluster DNS, but a Pod first uses its resolver configuration: nameserver, search list and `ndots`. A short name can generate several queries. DNS success proves name-to-address, not connection success.

**Ingress** is an API resource for HTTP(S) routing that requires an Ingress controller. **Gateway API** separates infrastructure and application roles through GatewayClass, Gateway, listeners and route resources. Creating either resource without a controller does not create a dataplane.

**NetworkPolicy** declares allowed ingress/egress for selected Pods. Policies are additive within a direction; a flow must satisfy applicable source egress and destination ingress. Enforcement depends on the network implementation.

## Architecture map

```text
client -> DNS -> external address -> Gateway/Ingress dataplane
                                      |
                                      v
source Pod -> Service ClusterIP -> EndpointSlice -> destination Pod:targetPort
     |              |                     |                 |
 resolver       node dataplane       ready target       listener
     +----------- NetworkPolicy in both directions --------+
```

Control-plane objects describe intent. Data-plane programs carry packets. An Accepted route condition proves attachment intent, not that packets reached the backend. A ready endpoint proves API eligibility, not that node rules are programmed.

## Request or state path

A Pod resolves `atlas-api.atlas-net.svc.cluster.local`. Cluster DNS returns the Service ClusterIP, or Pod addresses for a headless Service. The source process opens a connection to a destination port. The Pod route sends traffic through its interface to node networking. The Service dataplane selects an eligible EndpointSlice address and maps Service port to targetPort. NetworkPolicy may allow or deny source egress and destination ingress. The destination process must listen on the target address/port, reply, and the return path must reach the source.

For north-south traffic, external DNS and address allocation precede a load balancer or controller dataplane. TLS SNI and HTTP Host/path select a listener and route. The route references a Service; namespace attachment and reference rules may constrain it. Then the internal Service path begins.

Every object has identity and asynchronous status. Bind Service UID, EndpointSlice targetRef UID, controller class, route parents and backend revision before changing anything.

## Failure zoom

`NXDOMAIN` means the queried name does not exist according to the responder; timeout means no timely response; `SERVFAIL` means the server could not complete the query. They are different branches. Inspect the actual qname produced after search/ndots expansion.

Connection refused usually means an active rejection or no listener on the reached address/port. Timeout can be drop, route, policy, broken return path or silent application. TLS alerts occur after transport. HTTP 404/503 occur later still and may come from the gateway, Service backend or application—identify the responder.

Empty endpoints: compare Service selectors with Pod labels and readiness. Wrong targetPort: compare named/numeric Service target to container listener. Pod IP works/VIP fails: inspect Service/EndpointSlice and dataplane. Same-node works/cross-node fails: compare node routes, overlay, MTU, firewall and CNI agent health. One direction works: inspect directional policy and asymmetric return routing.

## Internals and state ownership

Services select Pods by labels when a selector exists; controllers create EndpointSlices. Labels express membership, not identity, so use targetRef UID when proving which Pod lifetime is selected. Readiness normally influences endpoint readiness. Terminating and serving conditions matter during graceful transitions.

`port` is the Service-facing port; `targetPort` is backend destination and may reference a named Pod port. `nodePort` is distinct. Mixing them produces a healthy-looking Service with traffic sent to a closed port.

Service IPs are virtual and usually not bound to one interface. Packet capture and `ip address` may not show the VIP as a local address. Inspect the cluster's real proxy/dataplane implementation. Session affinity, internal/external traffic policy and topology hints change endpoint selection and source-IP behavior; they are not universal load-balancer guarantees.

DNS search can amplify queries. With high `ndots`, a dotted external-looking name may first be tried with several cluster search suffixes. Prefer fully qualified names when appropriate, measure DNS latency/rcode, and understand caching/TTL. Headless Service answers bypass ClusterIP selection but still depend on endpoint publication and client-side behavior.

NetworkPolicy is not ordered firewall syntax. Selecting a Pod for ingress isolation means only unioned allowed ingress remains; egress is separate. Namespace selectors match namespace labels, Pod selectors match Pods in their namespace context, and `ipBlock` has implementation/topology caveats around address translation. Test allowed and denied cases.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| DNS works | exact qname/type/server/rcode/answer/latency | connection |
| Service selects backend | selector, slice, targetRef UID, ready port | dataplane programmed |
| Pod listens | socket bound to reachable address/targetPort | policy and route |
| policy allows | selected source/destination and both directional rules | plugin enforcement |
| Gateway attached | Accepted/ResolvedRefs and controller/class | packet forwarding |
| internal path works | request to normal Service path and backend revision | external path |
| user recovered | normal DNS/TLS/HTTP operation with expected revision | recurrence prevention |

## Command decoders

`getent hosts` uses the workload's normal resolver path; a DNS-specific tool may bypass some application behavior. Inspect `/etc/resolv.conf` for search and ndots. Use FQDN and short name to isolate expansion.

`curl -v` exposes resolution, connect, TLS and HTTP stages. Always bound connect and total time. `--resolve` bypasses DNS while preserving SNI/Host, which isolates DNS from later stages. It is a diagnostic override, not a production fix.

Ping uses ICMP and is neither guaranteed nor equivalent to TCP/UDP application traffic. A blocked ping does not prove a Service port is broken; a successful ping does not test the Service VIP or application.

`ip route`, `ip address` and `ss` show one namespace. Node dataplane inspection may require reviewer privileges; do not run broad packet capture or alter host rules as a learner. Capture only approved interfaces/filters and sanitize payloads.

## Decision path

1. Bind context, time, source/destination UIDs, nodes, five-tuple and intended user operation.
2. Resolve the exact name and record responder, rcode, answer and latency.
3. Inspect Service UID, port/targetPort, selector and EndpointSlices.
4. Compare direct endpoint with Service VIP using the same application request.
5. Inspect destination listener and readiness.
6. Evaluate source egress and destination ingress policy.
7. Compare node-local and cross-node routes/dataplane when paths differ.
8. For north-south, inspect address, listener, route attachment, TLS and Host/path.
9. Repair the smallest owning config/controller and verify normal user path.
10. Prove cleanup and preserve evidence/guardrails.

## Guided Ubuntu lab

The lab is a deterministic path model, not networking. Seven cases encode DNS absence, empty endpoints, wrong targetPort, policy denial, VIP-only failure, cross-node/MTU failure and rejected Gateway route. Each case includes hop evidence and expected boundary.

```bash
cd drafts/LES-0043-kubernetes-networking-services-dns-policy/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh diagnose service-no-endpoints
bash lab.sh verify-cases
bash lab.sh cleanup
```

It refuses root, network, sockets, kubectl, symlinks, wrong ownership and unknown artifacts. A wrong-boundary test and cleanup-refusal test must fail safely. Passing proves model assertions only.

## Production transfer

Use a reviewer-owned pinned disposable cluster with preloaded images and dedicated namespaces. Baseline CNI, Service dataplane, DNS, Gateway controller, nodes, IP families, MTU and policy support. The learner identity is namespace-scoped; reviewer owns node inspection.

Build two services and one client. Verify Pod IP, ClusterIP, headless DNS and revision response. Inject one fault at a time: selector mismatch, wrong targetPort, readiness removal, DNS policy/search error, egress denial, ingress denial, cross-node MTU/path issue and rejected route. For each, predict evidence, observe, recover through source, and verify allowed plus denied controls.

No public LoadBalancer, external registry, host networking, privileged Pod, unbounded capture or manual node-rule change. Cleanup inventories namespaces, policies, routes, controller-created objects, addresses, finalizers and credentials.

## Reliability, security, observability, capacity, and cost

Reliability requires endpoint readiness, graceful termination and topology/capacity awareness. Local traffic policies can preserve source IP or reduce cross-node hops but may cause imbalance or drops where no local endpoint exists. Topology-aware routing is a hint-driven optimization, not a universal failover guarantee.

Security uses default-deny plus explicit DNS, dependency and egress rules only after observing required flows. NetworkPolicy is one layer, not identity-aware encryption, L7 authorization or host firewall replacement. Gateway separation of infrastructure and application roles reduces unsafe shared ownership when RBAC and reference policy are correct.

Observe DNS qps/latency/errors/cache, Service programming latency, endpoints, dataplane drops, policy decisions, connections/retransmits, gateway requests/TLS, backend revision and user SLO. Capacity includes DNS replicas/cache, conntrack, NAT ports, rule scale, gateway connections, bandwidth, packets per second and cross-zone cost.

Cloud LoadBalancer types can allocate billable/public resources. This local book never creates them. In production, require internal/public intent, source restrictions, health-check behavior, cleanup and cost ownership before applying.

## Traps and prevention

Do not restart CoreDNS after a successful answer. Do not hand-edit EndpointSlices generated from selectors. Do not treat ping as an application probe. Do not assume a toleration or NetworkPolicy implementation. Do not add `0.0.0.0/0` egress to “fix” policy. Do not edit iptables on a managed node before identifying the owning controller. Do not call an Ingress/Gateway resource a dataplane without a controller and Accepted status.

Prevent regressions with selector/port schema tests, positive and negative policy tests, route attachment checks, synthetic requests carrying served revision, DNS SLOs, graceful endpoint termination tests and exact environment/version records.

## Memory card and retrieval

Remember **NAME-PATH**: Name/resolver; Address/VIP; Membership/EndpointSlice; Egress policy; Port mapping; Application listener; Transport/node path; HTTP/TLS/user proof.

Explain from memory why these pairs differ: DNS answer versus connection, Service versus EndpointSlice, port versus targetPort, Pod IP versus ClusterIP, Ingress resource versus controller, Accepted route versus working dataplane, declared policy versus enforced decision, same-node versus cross-node.

## Complete answers

**Why can DNS work while the Service fails?** DNS usually returns the stable Service address. Endpoint membership, targetPort, dataplane programming, policy, listener and return path happen afterward. Prove the answer, then compare direct endpoint and VIP.

**Why can Pod IP work but ClusterIP fail?** The application listener and one Pod route are proven, while Service mapping/dataplane remains. Inspect selector, EndpointSlice readiness/port and the actual proxy or eBPF implementation before changing the app.

**Does a NetworkPolicy allow rule override a deny rule?** Policies are additive, not ordered allow/deny firewall rules. Once a Pod is isolated in a direction, traffic must match at least one applicable allowed rule for that direction, and the opposite endpoint's direction must also permit it.

**Why might cross-node fail while same-node works?** Overlay encapsulation, routes, MTU, node firewall, CNI agent, underlay reachability or asymmetric return can differ. Compare the exact flow on both node pairs.

## Product-company interview

Scenario: DNS resolves the ClusterIP. One same-node client succeeds, another node times out. EndpointSlices show ready Pods on both nodes. A strong answer binds UIDs/five-tuples, proves DNS complete, compares direct endpoint and VIP from both sources, inspects NetworkPolicy both directions, node routes/CNI health/MTU/firewall and return path, preserves packet/drop evidence under reviewer scope, repairs the owning dataplane/config, then verifies normal user requests across nodes and adds a cross-node synthetic.

Weak answer: restart CoreDNS and kube-proxy everywhere. DNS already succeeded; broad restarts destroy evidence and availability without identifying why paths differ.

## Independent transfer and rubric

Unseen transfer: a Gateway route is Accepted, external TLS works but returns 503; internal Service name resolves; one EndpointSlice uses the wrong named port; a default-deny policy also blocks one source namespace. Produce identity/route evidence, isolate gateway versus Service versus policy, recover least privilege, verify allowed/denied paths and clean up.

Rubric: 15 identity and five-tuple, 15 layer/hop localization, 15 Service/EndpointSlice, 10 DNS, 15 policy direction, 10 Gateway attachment/data plane, 10 safe recovery, 10 user and negative verification. Only reviewer-observed unseen work counts.

## References and review

`REF-0403` through `REF-0417` contain current official Kubernetes, Gateway API, CNI and IETF sources. Networking behavior depends on Kubernetes version, IP family, CNI, proxy replacement, DNS and gateway implementation. Before publication, pin them, run all faults, capture bounded evidence, prove cleanup and review source dates. Documentation and a model are not packet-path evidence.
