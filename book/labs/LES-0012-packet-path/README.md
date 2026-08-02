# LES-0012 offline packet-path lab

This lab turns Ethernet, IP, CIDR, routing, next-hop neighbor resolution, stateful translation, return paths, and MTU into one inspectable packet story. It is intentionally a deterministic virtual model. It does not inspect or change the host network, and it sends no packets.

A successful run proves that the implemented model and its guarded lifecycle behaved as declared. It does not prove that a real host, router, firewall, NAT device, tunnel, Kubernetes cluster, or cloud network behaves the same way. It also does not award mastery.

## Safety contract

| Boundary | Enforced behavior |
|---|---|
| Supported shell | Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS |
| Identity | Normal user only; effective UID 0 is refused |
| Network | No socket, packet, DNS lookup, or external request |
| Host networking | No interface, address, route, neighbor, firewall, namespace, sysctl, or forwarding change |
| Packages | No installation and no package-manager call |
| Processes | No service, daemon, sleep, or background worker |
| Writable scope | One UID-scoped descriptor and one random lesson-prefixed private directory directly under `/tmp` |
| Evidence | Allowlisted regular files only; immutable records are created with no-clobber semantics |
| Integrity | Realpath, owner, mode, type, link count, sentinel, manifest, SHA-256, output grammar, and lifecycle are checked |
| Cleanup | Exact-file removal only after all guards pass; no recursive deletion |
| Stop rule | Preserve the first refusal. Do not weaken permissions, repair a descriptor, follow a symlink, or delete a guessed path |

The descriptor is:

```text
/tmp/reliability-atlas-LES-0012-<uid>.state
```

The private root matches:

```text
/tmp/reliability-atlas-LES-0012.<eight-random-characters>
```

The root must resolve to itself, be owned by the current UID, and have mode `0700`. Every artifact must be a single-link regular file owned by that UID with its declared mode. The copied model must match both its recorded SHA-256 digest and the repository fixture.

These controls reduce the chance of deleting the wrong path. They are a local teaching boundary, not a claim of resistance to a hostile user who controls the same account.

## Prerequisites

From the repository root, use a normal Ubuntu shell:

```bash
id
cat /etc/os-release
command -v bash python3 sha256sum
bash book/labs/LES-0012-packet-path/lab.sh check
```

Expected preflight facts:

- `id -u` is not `0`;
- Bash, Python 3.8 or newer, and the small set of core utilities are already present;
- `environment=ready`;
- `network=none`;
- `host_mutation=none`;
- a fresh attempt reports `state=absent`.

If a dependency is absent, stop. This lab never installs it.

## The model you are investigating

Treat each record as if it came from several adjacent virtual boundaries:

```text
process
  -> source namespace and interface
  -> policy rule and route table
  -> longest-prefix result
  -> selected next hop and neighbor state
  -> stateful edge and translated tuple
  -> destination
  -> independent return route
  -> reverse state
  -> effective MTU
  -> complete user operation
```

The words “virtual” and “modeled” matter. A row such as `neighbor_state=reachable` is fixture evidence, not a live `ip neigh` observation. A route result proves only the model’s route decision. Operation success requires the modeled forward path, return path, state, and size contract together.

## Guided lifecycle

Run each command separately so the first failure remains visible.

### 1. Create and inspect guarded state

```bash
bash book/labs/LES-0012-packet-path/lab.sh setup
bash book/labs/LES-0012-packet-path/lab.sh status
```

`setup` creates only the descriptor, private root, sentinel, manifest, and read-only model copy. `status` validates all present artifacts before reporting lifecycle state.

### 2. Read supplied facts, then freeze your prediction

Reveal only the selected case's supplied inputs:

```bash
bash book/labs/LES-0012-packet-path/lab.sh scenario guided
```

This command writes one immutable `scenario.input` record. It exposes the operation, source CIDR, destination, raw policy and route entries, configured translation and return-route entries, application response size, planned largest TCP payload, header sizes, link MTU, and encapsulation overhead. It deliberately does **not** expose the winning route, next hop, neighbor result, translated tuple, return result, effective MTU, packet result, or operation result. The verifier independently rejects those derived keys and result values in scenario output.

Now write your prediction outside the guarded lab directory. The harness records that an external prediction is required, but it cannot honestly prove what you wrote. Preserve this order:

- the source address, prefix, network, broadcast address, and whether the destination is on-link;
- every expected matching route, the longest prefix, route type, metric, next hop, and interface;
- whether the neighbor target is the final destination or a gateway;
- original and translated tuples;
- the separate return route and reverse-state owner;
- `largest IP packet = planned TCP payload + TCP header + IP header`;
- `effective inner IP MTU = underlay link MTU - encapsulation overhead`;
- `encapsulated size = largest IP packet + encapsulation overhead`;
- `MTU headroom = underlay link MTU - encapsulated size`;
- predicted route, neighbor, translation, return, MTU, and complete operation results.

Injection must match the recorded scenario. A second scenario, a baseline before scenario selection, and a different injected case are refused.

### 3. Reveal the healthy baseline, then rank hypotheses

After the prediction exists externally, record and inspect the immutable healthy comparison:

```bash
bash book/labs/LES-0012-packet-path/lab.sh run baseline
bash book/labs/LES-0012-packet-path/lab.sh observe addresses
bash book/labs/LES-0012-packet-path/lab.sh observe routes
bash book/labs/LES-0012-packet-path/lab.sh observe path
```

Baseline observation is allowed only after the scenario and baseline records exist. Running either immutable record twice is refused. Compare the revealed baseline with your timestamped prediction; do not silently rewrite the prediction.

Use at least three mechanisms, for example:

- route policy selected a rejecting route;
- the selected next hop cannot be resolved;
- the forward path works but the return route or reverse translation state does not;
- the packet exceeds an effective MTU;
- the operation failed outside the modeled network boundaries.

For each mechanism, write one predicted supporting observation and one predicted rejecting observation. Do not use the error message as a root cause.

### 4. Inject the guided case

```bash
bash book/labs/LES-0012-packet-path/lab.sh inject guided
bash book/labs/LES-0012-packet-path/lab.sh observe addresses
bash book/labs/LES-0012-packet-path/lab.sh observe routes
bash book/labs/LES-0012-packet-path/lab.sh observe path
```

Compare baseline and incident in order:

1. Did the source identity or prefix change?
2. Which rule and table were selected?
3. List every candidate prefix and apply longest-prefix match.
4. Read route type before assuming that an entry forwards.
5. Only after a forwarding result exists, identify the exact next-hop neighbor.
6. Trace the tuple through translation.
7. Draw the reply independently.
8. Calculate largest emitted IP packet, effective inner IP MTU, encapsulated size, and signed headroom; then compare them.
9. Name the first boundary whose input is healthy and output is abnormal.

### 5. Use only bounded virtual probes

The probes emit a fixed finite record and send zero packets:

```bash
bash book/labs/LES-0012-packet-path/lab.sh probe neighbor
bash book/labs/LES-0012-packet-path/lab.sh probe return
bash book/labs/LES-0012-packet-path/lab.sh probe mtu
```

`neighbor` samples the selected next-hop boundary. `return` samples the reply route and reverse-state owner. `mtu` shows small and large inner IP packet sizes, their encapsulated sizes, underlay MTU, overhead, effective inner MTU, signed large-packet headroom, and feedback state. A probe is useful only when its result can distinguish hypotheses.

### 6. Recover and verify the operation

After recording your diagnosis:

```bash
bash book/labs/LES-0012-packet-path/lab.sh recover
bash book/labs/LES-0012-packet-path/lab.sh verify-operation
bash book/labs/LES-0012-packet-path/lab.sh status
```

Recovery restores a known-good virtual contract. It does not certify that the learner named the cause correctly. Verification is stronger than checking one route: it requires modeled forward delivery, return delivery, translation and reverse state, MTU fit, and operation success.

Recovery output keeps application bytes separate from segment and packet sizes. Verify `inner packet = largest TCP payload + TCP header + IP header`, `effective inner MTU = underlay MTU - overhead`, `encapsulated packet = inner packet + overhead`, and `headroom = underlay MTU - encapsulated packet`. If recovery changes segmentation, the unchanged application response can be emitted as several smaller packets. Exact independent values remain hidden until the supported recovery command runs.

### 7. Prove cleanup

```bash
bash book/labs/LES-0012-packet-path/lab.sh cleanup
bash book/labs/LES-0012-packet-path/lab.sh check
```

Retain both `cleanup_proven=true` and the following `state=absent`. Cleanup refuses an unexpected artifact, symlink, hard link, changed mode, changed hash, changed manifest, changed sentinel, invalid descriptor, or out-of-scope root. Never replace a refusal with `rm -rf`.

## Independent attempt

Start only from clean state:

```bash
bash book/labs/LES-0012-packet-path/lab.sh check
bash book/labs/LES-0012-packet-path/lab.sh setup
bash book/labs/LES-0012-packet-path/lab.sh scenario independent
bash book/labs/LES-0012-packet-path/lab.sh run baseline
bash book/labs/LES-0012-packet-path/lab.sh inject independent
```

Write and preserve the independent prediction after `scenario independent` and before `run baseline`. Then use the same `observe` and bounded `probe` commands, followed by `recover`, `verify-operation`, `cleanup`, and `check`.

The independent case contains a changed topology. This directory intentionally contains no independent diagnosis and no model answer. Do not inspect the fixture or verifier before submitting your own reasoning. The learner response template contains prompts only. Disclose accidental source exposure or outside assistance.

Your evidence should include:

- calculations written before each observation;
- all matching prefixes, not only the winner;
- proof of whether a next-hop lookup was reached;
- both forward and return tuple paths;
- application bytes, segmentation, header, emitted-packet, encapsulation, effective-MTU, and signed-headroom arithmetic;
- at least three mechanisms and two evidence-based rejections;
- the first abnormal boundary;
- supported recovery and operation verification;
- cleanup proof and remaining uncertainty;
- one transfer to a real environment with owner, approval, rollback, observability, capacity, and security boundaries.

## Command and field decoder

### `scenario guided|independent`

| Field | Supplied meaning | Deliberately not revealed |
|---|---|---|
| `source_cidr` and `destination_address` | Inputs for subnet and route reasoning | On-link result, network, or broadcast calculation |
| `policy_rules` and `route_entries` | Raw virtual policy and route configuration | Selected table, winning prefix, route result, next hop, or interface |
| `translation_config` and `return_route_entries` | Configured stateful and reply-path inputs | Created mapping, translated tuple, reverse state, or return result |
| `application_response_bytes` | Bytes the modeled application must deliver | Segment count or emitted packet size |
| `planned_largest_tcp_segment_payload_bytes` | Sender's pre-recovery largest TCP payload input | Whether that size crosses the tunnel |
| `ip_header_bytes` and `tcp_header_bytes` | Header inputs for packet arithmetic | Derived packet size |
| `underlay_link_mtu` and `encapsulation_overhead_bytes` | Inputs for effective-MTU arithmetic | Effective MTU, encapsulated size, headroom, or fit result |
| `pmtud_feedback_status=unobserved` | Feedback has not yet been observed | Present, missing, allowed, or blocked feedback |

### `observe addresses`

| Field | Meaning | Does not prove |
|---|---|---|
| `namespace` | Virtual identity boundary for the record | Host or container namespace identity |
| `source_address` | Modeled source IP | Source selection on a real packet |
| `prefix_length` and `subnet_mask` | Network/host bit boundary | Correct address-plan intent |
| `network_address` and `broadcast_address` | Calculated IPv4 subnet bounds | Route selection |
| `gateway_on_link` | The gateway belongs to the source prefix | Neighbor reachability |
| `destination_on_link` | Whether direct neighbor resolution is expected | End-to-end delivery |
| `interface_mtu` | Configured virtual link MTU | Effective path MTU |

### `observe routes`

| Field | Meaning | Does not prove |
|---|---|---|
| `policy_rule` | Rule context that selected a table | That the selected table forwards |
| `candidate_routes` | Every modeled matching prefix and type | Which candidate wins until prefixes are compared |
| `winning_prefix` | Longest matching prefix | A usable route; inspect type |
| `route_type` | Forwarding or rejecting action | Neighbor, firewall, NAT, or return success |
| `route_metric` | Tie-breaking preference within applicable candidates | Permission or reachability |
| `next_hop` | Link-local target after route selection | A resolved link-layer address |
| `route_result` | `selected` for a usable selected route or `rejected` for a rejecting winner | Packet traversal |

### `observe path`

| Field | Meaning | Does not prove |
|---|---|---|
| `neighbor_target` | IP whose link identity is needed on the selected link | Final service identity when a gateway is used |
| `neighbor_state` | Virtual reachability state for that target | Current delivery |
| `original_tuple` and `translated_tuple` | Identity before and after stateful translation | Return-path compatibility |
| `forward_result` | Modeled request-direction result | Reply delivery |
| `return_route` and `reverse_state` | Modeled reply routing and mapping state | Full operation success |
| `application_response_bytes` | Total modeled application response | One packet or wire size |
| `tcp_segment_count` | Number of modeled TCP segments for the response | Real segmentation or offload behavior |
| `largest_tcp_segment_payload_bytes` | Largest application portion in one emitted TCP segment | Total application response |
| `ip_header_bytes` and `tcp_header_bytes` | Header contribution to each modeled packet | Headers in every real environment |
| `largest_emitted_ip_packet_bytes` | Largest TCP payload plus TCP and IP headers | Encapsulated wire size |
| `underlay_link_mtu` minus `encapsulation_overhead_bytes` | Arithmetic inputs for the inner path | Correct production configuration |
| `effective_inner_ip_mtu` and `largest_encapsulated_packet_bytes` | Inner limit and outer size after overhead | Every real-path MTU |
| `mtu_headroom_bytes` | Signed `underlay MTU - encapsulated size`; negative means excess | Cause without correlated feedback and delivery evidence |
| `control_feedback` | Whether modeled size feedback is present | Why a real control message is absent |
| `operation_success` | Combined virtual user outcome | Production health or mastery |

## State transitions and refusals

```text
absent
  -> setup
ready
  -> scenario guided|independent exactly once
scenario-recorded
  -> write and preserve prediction outside the lab root
  -> run baseline
baseline-recorded
  -> inject exactly the recorded case
case-active
  -> observe and bounded probe
  -> recover exactly once
recovered
  -> verify-operation exactly once
verified
  -> cleanup
absent
```

Out-of-order, repeated, malformed, or non-allowlisted operations fail closed. `reset` is available only when the registered state still passes every identity and integrity guard. It performs guarded cleanup followed by setup; it is not a bypass for corrupted state.

## Automated verification

Run this only from clean lab state as a normal user:

```bash
bash book/labs/LES-0012-packet-path/verify.sh
```

The verifier exercises both scenarios and cases, proves scenario output excludes derived answer/result fields, checks packet and MTU equations before and after recovery, tests ordering and immutable records, and covers invalid inputs, tampering, unexpected artifacts, symlink and hard-link refusal, orphan-root refusal, cleanup idempotence, answer isolation, and absence proof. It never uses sudo, opens a socket, or mutates host networking.

If verification refuses because learner state exists, preserve or finish that attempt first. The verifier must never erase learner work.
