---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0021",
  "aliases": ["V03-L06", "api-contracts-serialization"],
  "curriculumIds": ["AUT-005"],
  "slug": "api-contracts-serialization",
  "route": "/book/engineering/api-contracts-serialization",
  "order": 6,
  "volume": "03-engineering-delivery",
  "title": "API contracts and serialization: make integrations survive failure and change",
  "summary": "Trace an API operation from characters and bytes through HTTP semantics, JSON parsing, runtime schemas, authorization, idempotency, state ownership, pagination, rate limits, version evolution, webhooks, observability, SDKs, tests, recovery, and verified user outcomes. Build integrations that say unknown when evidence is incomplete and remain safe under retries, duplicates, concurrency, and change.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 540,
  "prerequisiteLessonIds": ["LES-0015", "LES-0018"],
  "prerequisiteCurriculumIds": ["NET-005", "AUT-002"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "All required exercises use Bash, Python 3, and the Python standard library. The lab runs as a normal user, refuses UID 0, opens no socket, makes no network request, installs nothing, and changes only a guarded UID-scoped descriptor plus private random directory beneath /tmp."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "Run from the Ubuntu shell. Linux UID, modes, symlinks, /tmp, Bash, and Python process behavior are the tested boundary. Do not infer identical Windows filesystem, proxy, certificate-store, or process semantics."
    },
    {
      "platform": "Containers, Kubernetes, CI systems, private cloud, and public cloud",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Production transfer covers gateways, workload identity, service-to-service authorization, controllers, durable idempotency stores, SDKs, webhooks, and rollout. This lesson creates no container, cluster, account, external API, or paid resource."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "release-engineer", "security-engineer", "data-platform-engineer"],
  "learningObjectives": [
    "Trace one API operation across characters, encoded bytes, HTTP metadata, JSON parsing, runtime validation, authentication, authorization, state mutation, response, receipt, and end-to-end verification without collapsing those boundaries.",
    "Distinguish valid text, valid JSON, schema validity, business validity, and authorization; define request and response types that reject ambiguity rather than silently coercing it.",
    "Use HTTP method and status semantics, media types, content negotiation, problem details, validators, conditional requests, deadlines, and cancellation as explicit contracts rather than success folklore.",
    "Design idempotency identities, key-to-intent binding, durable receipts, reconciliation, retries, and compensation for known rejection, known commit, conflict, proven no-effect, transient failure, and unknown outcomes.",
    "Choose pagination ordering, opaque cursors, snapshot or high-water semantics, page limits, and restart behavior that remain explainable while a collection changes.",
    "Handle 429 responses with per-operation deadlines, capped attempts, backoff, jitter, concurrency limits, backpressure, fairness, and fleet retry budgets.",
    "Evolve OpenAPI and JSON Schema contracts compatibly across independent producers and consumers, and test wire behavior instead of assuming generated SDKs make change safe.",
    "Secure webhooks and service integrations with transport security, authentication, authorization, signature verification, freshness, replay deduplication, secret hygiene, and bounded observability.",
    "Debug API incidents from preserved evidence, state-owner truth, safe containment, bounded recovery, user-operation verification, and prevention tests."
  ],
  "productionSignals": [
    "A client reports timeout while the service later shows the mutation committed, creating an unknown outcome and duplicate risk.",
    "HTTP 2xx rises while user-visible operations remain incomplete because the response represents attempt acceptance rather than verified workflow completion.",
    "Validation rejections spike after a client rollout because a field changed from JSON number to string, an enum gained a value, or an unknown field policy differs.",
    "A gateway emits 415, 406, 422, 428, 409, 412, or 429 and clients flatten every non-2xx response into one retryable exception.",
    "Retry attempt rate, in-flight calls, queue age, and downstream latency rise faster than logical request rate during partial failure.",
    "Offset pagination duplicates or omits objects while writers insert or delete rows between page requests.",
    "A validly signed webhook is replayed and repeats an effect because freshness and durable event-ID claiming were not enforced.",
    "A seemingly additive schema change breaks an older consumer because it rejects unknown fields or treats unknown enum values as impossible.",
    "Logs expose authorization headers, tokens, signed URLs, request bodies, problem detail, tenant IDs, or high-cardinality operation identifiers.",
    "Client and server dashboards disagree because one counts logical operations, another counts attempts, and neither exposes oldest unknown outcome."
  ],
  "diagrams": [
    {
      "id": "LES-0021-DIA-001",
      "title": "An API operation crosses many contracts before the user gets a result",
      "direction": "left-to-right",
      "boundaries": ["human intent", "typed client model", "serialization", "HTTP request", "gateway and identity", "service validation and authorization", "state owner", "HTTP response", "client receipt", "user verification"],
      "evidencePoints": ["logical operation ID", "runtime field types", "encoded byte digest", "method media types deadline", "principal route policy", "schema and policy decision", "resource version and receipt", "status problem type headers", "durable local state", "real user outcome"],
      "textAlternative": "A human intent becomes a typed client value, encoded bytes, and an HTTP request. A gateway and service authenticate, validate, authorize, and ask an authoritative state owner to act. The response crosses back to a client receipt, but only a final state query or user journey verifies the promised operation."
    },
    {
      "id": "LES-0021-DIA-002",
      "title": "Parsing and validation are different gates",
      "direction": "top-to-bottom",
      "boundaries": ["characters", "UTF-8 bytes", "media type", "JSON grammar", "JSON value types", "schema assertions", "business invariants", "authorization", "effect"],
      "evidencePoints": ["code points", "byte count", "Content-Type", "parse location", "object array string number boolean null", "required types ranges unknown fields", "domain state and policy", "principal action resource", "receipt and version"],
      "textAlternative": "Characters are encoded to bytes and labeled with a media type. A JSON parser checks grammar and produces typed values. A schema checks structure, business rules check meaning, authorization checks whether this principal may act on this resource, and only then should a mutation reach the state owner."
    },
    {
      "id": "LES-0021-DIA-003",
      "title": "A deadline after send creates an unknown branch",
      "direction": "cyclic",
      "boundaries": ["persist intent", "send attempt with stable key", "service may commit", "client deadline", "unknown", "query owner by key", "committed or proven absent", "verify or bounded retry"],
      "evidencePoints": ["intent hash and operation ID", "attempt ID and monotonic deadline", "atomic key outcome record", "last received byte and elapsed time", "unknown ledger age", "authoritative receipt", "resource version or absence proof", "user operation and duplicate count"],
      "textAlternative": "The client records intent and sends one attempt with a stable idempotency key. If its deadline expires after transmission, the service may already have committed. The client marks unknown, asks the state owner by the same key, records commit if found, and retries only when absence is proven and budget remains."
    },
    {
      "id": "LES-0021-DIA-004",
      "title": "Pagination consistency depends on ordering and snapshot ownership",
      "direction": "left-to-right",
      "boundaries": ["query filter", "stable total order", "snapshot or high-water mark", "opaque cursor", "page response", "concurrent writes", "next page", "complete-set verification"],
      "evidencePoints": ["authorized predicate", "sort keys and tie-breaker", "snapshot version", "server-issued token", "IDs and next relation", "insert update delete timestamps", "same contract and snapshot", "count digest gaps duplicates"],
      "textAlternative": "A service applies one authorized filter and stable total order, optionally binds it to a snapshot or high-water mark, and issues an opaque cursor. Concurrent writes must not silently change what the cursor means. The client follows the next relation and reconciles IDs, duplicates, omissions, and snapshot scope."
    },
    {
      "id": "LES-0021-DIA-005",
      "title": "Webhook safety needs integrity, freshness, and effect deduplication",
      "direction": "top-to-bottom",
      "boundaries": ["provider event", "raw body and signed components", "TLS ingress", "signature verification", "timestamp window", "durable event claim", "authorized handler", "effect receipt", "acknowledgement"],
      "evidencePoints": ["event ID", "key ID algorithm exact bytes", "peer and certificate evidence", "verified signature", "age and clock policy", "unique event ownership", "tenant and action policy", "state version", "response status and redelivery"],
      "textAlternative": "A webhook receiver preserves the raw signed bytes, verifies the required signature components and key, rejects messages outside a freshness window, atomically claims the event ID, authorizes the effect, stores its receipt, and then acknowledges. A repeated valid event is acknowledged without a second effect."
    }
  ],
  "commands": [
    {
      "id": "LES-0021-CMD-001",
      "question": "How many Unicode characters and UTF-8 bytes are in the same visible value?",
      "risk": "read-only",
      "command": "python3 -c 's=\"café\"; b=s.encode(\"utf-8\"); print(\"characters=\"+str(len(s))); print(\"bytes=\"+str(len(b))); print(\"hex=\"+b.hex()); print(\"round_trip=\"+b.decode(\"utf-8\"))'",
      "runFrom": "Any Ubuntu 24.04 shell with Python 3; it uses one synthetic in-memory value",
      "expectedBranches": [
        {"when": "characters=4, bytes=5, and round_trip=café", "meaning": "The character é occupies two UTF-8 bytes while decoding reconstructs the four-character string.", "nextEvidence": "Inspect the exact bytes and declared media type at the real failing boundary."},
        {"when": "Python cannot encode or output the value", "meaning": "Interpreter, source, locale, or terminal assumptions differ from the tested environment.", "nextEvidence": "Record sys.getdefaultencoding, stdout encoding, source bytes, and exception without changing production locale."}
      ],
      "proves": "Character count, UTF-8 byte count, byte values, and round trip for this Python value.",
      "doesNotProve": "HTTP media type, normalization form, glyph appearance, remote decoding, schema validity, or safe truncation by characters."
    },
    {
      "id": "LES-0021-CMD-002",
      "question": "What JSON type did the parser actually produce?",
      "risk": "read-only",
      "command": "printf '%s\\n' '{\"replicas\":\"3\",\"enabled\":true,\"note\":null}' | python3 -c 'import json,sys; v=json.load(sys.stdin); print(\"top=\"+type(v).__name__); [print(k+\"=\"+type(v[k]).__name__) for k in sorted(v)]'",
      "runFrom": "Any supported lesson shell; input is synthetic and no file is created",
      "expectedBranches": [
        {"when": "replicas=str, enabled=bool, and note=NoneType", "meaning": "JSON grammar was valid and the runtime preserved three distinct JSON value categories.", "nextEvidence": "Compare those types with the endpoint's runtime schema and business rules."},
        {"when": "A JSON decoding error appears", "meaning": "The byte/text stream is not valid JSON under this parser.", "nextEvidence": "Preserve the parse position and a sanitized bounded sample; do not attempt schema validation yet."}
      ],
      "proves": "Parser-selected runtime types for the exact synthetic document.",
      "doesNotProve": "Schema validity, integer range, duplicate-name policy across parsers, authorization, or remote behavior."
    },
    {
      "id": "LES-0021-CMD-003",
      "question": "Does a decoded release object satisfy a strict runtime boundary?",
      "risk": "read-only",
      "command": "python3 -c 'import json; v=json.loads(\"{\\\"service\\\":\\\"api\\\",\\\"replicas\\\":3}\"); assert isinstance(v,dict) and set(v)=={\"service\",\"replicas\"}; assert isinstance(v[\"service\"],str) and v[\"service\"]; assert type(v[\"replicas\"]) is int and 1<=v[\"replicas\"]<=20; print(\"schema=accepted\")'",
      "runFrom": "Any supported lesson shell; this is an intentionally small executable contract example",
      "expectedBranches": [
        {"when": "schema=accepted", "meaning": "Required fields, unknown-field rejection, exact local types, and range passed this example.", "nextEvidence": "Apply business invariants and authorization before any effect."},
        {"when": "AssertionError occurs", "meaning": "At least one explicit local boundary is false.", "nextEvidence": "Replace assertions in production with stable typed validation errors that identify the safe field/code."}
      ],
      "proves": "The exact in-memory example satisfies the displayed handwritten checks.",
      "doesNotProve": "Conformance to a complete JSON Schema/OpenAPI document, useful diagnostics, authorization, or mutation safety."
    },
    {
      "id": "LES-0021-CMD-004",
      "question": "Can the server select a response representation the client accepts?",
      "risk": "read-only",
      "command": "python3 -c 'supported=(\"application/json\",\"application/problem+json\"); accept=(\"application/json\",); selected=next((m for m in supported if m in accept),None); print(\"selected=\"+str(selected)); print(\"status=\"+(\"200\" if selected else \"406\"))'",
      "runFrom": "Any supported lesson shell; this is a simplified exact-match negotiation model",
      "expectedBranches": [
        {"when": "selected=application/json and status=200", "meaning": "The simplified client and server sets intersect.", "nextEvidence": "Inspect the real response Content-Type and body parser behavior."},
        {"when": "selected=None and status=406", "meaning": "The simplified model found no acceptable representation.", "nextEvidence": "Compare real Accept ranges, quality values, parameters, and server negotiation policy."}
      ],
      "proves": "Set intersection in this deliberately simplified model.",
      "doesNotProve": "Complete RFC negotiation, charset behavior, gateway transformations, response schema, or that 200 represents business success."
    },
    {
      "id": "LES-0021-CMD-005",
      "question": "What stable fingerprint represents a canonical non-secret intent in this model?",
      "risk": "read-only",
      "command": "python3 -c 'import hashlib,json; v={\"service\":\"payments\",\"target\":\"2026.08.02\",\"replicas\":3}; b=json.dumps(v,sort_keys=True,separators=(\",\",\":\"),ensure_ascii=False,allow_nan=False).encode(\"utf-8\"); print(b.decode()); print(hashlib.sha256(b).hexdigest())'",
      "runFrom": "Any supported lesson shell; never include secrets in a production intent fingerprint",
      "expectedBranches": [
        {"when": "The compact sorted JSON and a 64-hex-character digest print", "meaning": "This implementation produced deterministic bytes and a SHA-256 fingerprint for the example.", "nextEvidence": "Define the exact canonicalization/version and store caller scope plus fingerprint with the idempotency record."},
        {"when": "Serialization rejects a value", "meaning": "The input contains a value outside this canonical model, such as a non-finite number.", "nextEvidence": "Reject at the input boundary instead of inventing an unstable encoding."}
      ],
      "proves": "Deterministic local serialization and digest for one allowlisted data model.",
      "doesNotProve": "Universal JSON canonicalization, secrecy, authenticity, collision impossibility, authorization, or that two identical payloads always mean one logical operation."
    },
    {
      "id": "LES-0021-CMD-006",
      "question": "Which outcomes permit retry after a mutating attempt?",
      "risk": "read-only",
      "command": "python3 -c 'states={\"rejected\":False,\"committed\":False,\"proven_absent_transient\":True,\"unknown\":False,\"conflict\":False}; [print(k+\" retry=\"+str(v).lower()) for k,v in states.items()]'",
      "runFrom": "Any supported lesson shell; the table models a policy, not a remote call",
      "expectedBranches": [
        {"when": "Only proven_absent_transient prints retry=true", "meaning": "The model requires both no-effect proof and transient classification before replay.", "nextEvidence": "Define the authoritative query, stable operation ID, attempt cap, deadline, and budget for the real integration."},
        {"when": "A team policy marks unknown or committed retryable", "meaning": "That policy risks duplicate effects unless the same identity is atomically deduplicated by the state owner.", "nextEvidence": "Review idempotency storage and timeout-after-commit tests before deployment."}
      ],
      "proves": "The displayed policy mapping for named abstract states.",
      "doesNotProve": "The current production state, that absence can be proven, or that a dependency honors idempotency."
    },
    {
      "id": "LES-0021-CMD-007",
      "question": "Would a conditional update reject a stale resource version?",
      "risk": "read-only",
      "command": "python3 -c 'current=\"v18\"; supplied=\"v17\"; print(\"current_etag=\"+current); print(\"if_match=\"+supplied); print(\"status=\"+(\"204\" if supplied==current else \"412\"))'",
      "runFrom": "Any supported lesson shell; values are synthetic",
      "expectedBranches": [
        {"when": "status=412", "meaning": "The modeled precondition prevents overwriting a resource changed since the client read v17.", "nextEvidence": "Fetch the current representation, understand the competing change, and construct a reviewed new intent."},
        {"when": "status=204", "meaning": "The supplied and current validators match in this model.", "nextEvidence": "Still verify authorization, mutation result, new version, and user outcome."}
      ],
      "proves": "One equality-based optimistic concurrency decision.",
      "doesNotProve": "Real ETag strength, atomic server enforcement, semantic merge safety, or that 204 means downstream completion."
    },
    {
      "id": "LES-0021-CMD-008",
      "question": "Did two pages contain a duplicate or omit an expected snapshot ID?",
      "risk": "read-only",
      "command": "python3 -c 'expected={\"r1\",\"r2\",\"r3\",\"r4\"}; pages=[[\"r1\",\"r2\"],[\"r2\",\"r4\"]]; flat=[x for p in pages for x in p]; print(\"duplicates=\"+str(len(flat)-len(set(flat)))); print(\"missing=\"+\",\".join(sorted(expected-set(flat))))'",
      "runFrom": "Any supported lesson shell; the expected set and pages are synthetic",
      "expectedBranches": [
        {"when": "duplicates=1 and missing=r3", "meaning": "The observed page union violates complete-once traversal for the declared four-ID snapshot.", "nextEvidence": "Inspect ordering, tie-breaker, cursor/snapshot contract, and writes between requests."},
        {"when": "duplicates=0 and missing is empty", "meaning": "The sampled IDs match the declared expected set once.", "nextEvidence": "Verify snapshot scope, authorization filters, item versions, and end-of-list evidence."}
      ],
      "proves": "Set reconciliation for the explicit synthetic expected IDs and page outputs.",
      "doesNotProve": "Why inconsistency occurred, records outside the expected snapshot, correct ordering, or a real service's cursor semantics."
    },
    {
      "id": "LES-0021-CMD-009",
      "question": "How much request amplification can the configured clients create?",
      "risk": "read-only",
      "command": "python3 -c 'logical_rps=240; retries=4; replicas=60; per_replica=100; attempts_per_operation=1+retries; print(\"max_attempt_rps=\"+str(logical_rps*attempts_per_operation)); print(\"configured_inflight=\"+str(replicas*per_replica))'",
      "runFrom": "Any supported lesson shell; values are an explicit scenario, not measured production telemetry",
      "expectedBranches": [
        {"when": "max_attempt_rps=1200 and configured_inflight=6000", "meaning": "Theoretical settings permit fivefold attempt-rate amplification and 6,000 concurrent attempts.", "nextEvidence": "Measure actual attempts per logical ID, residence-time distribution, queues, 429s, and downstream capacity."},
        {"when": "Measured values are much lower", "meaning": "The ceiling was not fully exercised during that window.", "nextEvidence": "Keep the unsafe ceiling visible while using measured rates for incident conclusions."}
      ],
      "proves": "Arithmetic from the supplied configuration assumptions.",
      "doesNotProve": "Actual traffic, latency, saturation point, safe capacity, or which component caused user impact."
    },
    {
      "id": "LES-0021-CMD-010",
      "question": "Does a problem-details body contain a bounded machine classification?",
      "risk": "read-only",
      "command": "python3 -c 'import json; p=json.loads(\"{\\\"type\\\":\\\"https://errors.example.invalid/invalid-field\\\",\\\"title\\\":\\\"Validation failed\\\",\\\"status\\\":422,\\\"code\\\":\\\"integer-required\\\"}\"); print(\"type=\"+p[\"type\"]); print(\"status=\"+str(p[\"status\"])); print(\"code=\"+p[\"code\"])'",
      "runFrom": "Any supported lesson shell; the domain is reserved as invalid and no request occurs",
      "expectedBranches": [
        {"when": "The known type, status 422, and allowlisted code print", "meaning": "The synthetic body carries both human-facing and machine-classifiable fields.", "nextEvidence": "Compare the HTTP status line, documented problem type, safe extensions, and client unknown-type fallback."},
        {"when": "A required field is missing or has another type", "meaning": "The client cannot rely on its expected problem contract.", "nextEvidence": "Preserve a bounded sanitized body and fall back to generic safe handling rather than guessing retryability."}
      ],
      "proves": "Field presence and local types for one synthetic problem object.",
      "doesNotProve": "That a remote response is authentic, sanitized, safe to log, or retryable."
    },
    {
      "id": "LES-0021-CMD-011",
      "question": "Does changing one raw webhook byte change the modeled HMAC signature?",
      "risk": "read-only",
      "command": "python3 -c 'import hashlib,hmac; key=b\"lesson-only-key\"; a=b\"event=417&state=ready\"; b=b\"event=417&state=failed\"; print(\"same_signature=\"+str(hmac.compare_digest(hmac.new(key,a,hashlib.sha256).digest(),hmac.new(key,b,hashlib.sha256).digest())).lower())'",
      "runFrom": "Any supported lesson shell; key and payloads are synthetic and must never be reused",
      "expectedBranches": [
        {"when": "same_signature=false", "meaning": "The two byte strings produce different HMAC values under this key and algorithm.", "nextEvidence": "For a real scheme, preserve exact raw signed bytes and verify required components, key identity, freshness, and event dedupe."},
        {"when": "A verification implementation compares text after parsing", "meaning": "Re-serialization can change bytes and invalidate or weaken the intended signature boundary.", "nextEvidence": "Follow the provider's exact signing specification and tested library behavior."}
      ],
      "proves": "Different HMAC-SHA-256 results for two local byte strings and one synthetic key.",
      "doesNotProve": "Provider authenticity, secret custody, algorithm negotiation, timestamp freshness, authorization, or replay prevention."
    },
    {
      "id": "LES-0021-CMD-012",
      "question": "Is the guarded LES-0021 lab clean and ready without changing the host?",
      "risk": "read-only",
      "command": "bash lab.sh check",
      "runFrom": "book/labs/LES-0021-api-contracts in an Ubuntu 24.04 normal-user shell",
      "expectedBranches": [
        {"when": "state=absent and network=none", "meaning": "No registered descriptor or matching orphan was observed for this UID and the lab declares an offline boundary.", "nextEvidence": "Read README.md, then run the explicit mutating setup only when ready."},
        {"when": "A descriptor, orphan, root identity, dependency, or ownership refusal appears", "meaning": "The preflight contract is not satisfied.", "nextEvidence": "Preserve the refusal and inspect exact identity; do not use sudo or manual wildcard cleanup."}
      ],
      "proves": "Current preflight state and required local dependency checks performed by the reviewed controller.",
      "doesNotProve": "Future filesystem state, network behavior, production APIs, security certification, answer quality, or mastery."
    }
  ],
  "labs": [
    {
      "id": "LES-0021-LAB-001",
      "title": "Guided contract boundary and safe rejection investigation",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04, Bash 5+, Python 3 standard library, normal user, no external network, no listener, no installation",
      "timeMinutes": 55,
      "privilege": "Normal user only; lab and verifier refuse effective UID 0 with status 77",
      "network": "None. The Python fixture is a deterministic offline model and opens no socket.",
      "changes": ["Creates one mode-0600 UID-scoped descriptor directly beneath /tmp", "Creates one mode-0700 random lesson directory beneath /tmp", "Installs an exact mode-0500 fixture copy and creates only allowlisted mode-0400/0600 records inside that directory"],
      "abortConditions": ["Any dependency is missing or Ubuntu boundary is not understood", "A matching orphan, symlink, wrong owner/mode/link count, changed fixture, unknown child, or lock contention is observed", "Any command requests root, installation, external network, a real endpoint, or manual deletion"],
      "recovery": "Use only `bash lab.sh recover` after reviewing observed evidence. For the guided invalid-type case the modeled recovery rejects before mutation and demonstrates a corrected typed request. Use `bash lab.sh cleanup` for exact owned-state removal.",
      "cleanupProof": "The normal-user verifier exercises guided lifecycle, refusals, exact cleanup, and final absence. Root refusal is checked separately by an authorized reviewer; neither result evaluates learner reasoning or a real API.",
      "path": "book/labs/LES-0021-api-contracts"
    },
    {
      "id": "LES-0021-LAB-002",
      "title": "Independent timeout, idempotency, pagination, rate-limit, and webhook transfer",
      "mode": "independent",
      "environment": "A clean LES-0021 lab lifecycle in Ubuntu 24.04 or WSL 2 Ubuntu 24.04; response stored outside guarded state; no fixture inspection",
      "timeMinutes": 75,
      "privilege": "Normal user only; no sudo, capability, container socket, or permission bypass",
      "network": "None. All request, service, page, limiter, and webhook observations are deterministic model records.",
      "changes": ["Uses the same guarded descriptor and private random root as the guided lab", "Creates baseline, case, recovery, and verification records only through the controller", "Learner response must be stored outside the lab-owned random root"],
      "abortConditions": ["The raw scenario was not captured before derived observation", "Fixture source, prior answer, or guided outcome was inspected during the independent attempt", "A proposed action changes operation identity, blindly retries unknown mutation, exceeds scope/budget, or lacks verification", "Controller reports any ownership, tamper, transition, or cleanup refusal"],
      "recovery": "Commit to a written prediction and bounded recovery card, reconcile through the model using the same logical idempotency key, verify the original modeled operation and duplicate count, run the verifier, and perform supported cleanup.",
      "cleanupProof": "`bash verify.sh` must finish with verification_passed=true and cleanup_proven=true; `bash lab.sh check` must then report state=absent. A human reviewer separately scores ASM-0048 evidence.",
      "path": "book/labs/LES-0021-api-contracts"
    }
  ],
  "incidents": [
    {
      "id": "LES-0021-INC-001",
      "signal": "POST attempts hit a client deadline, retries use new keys, and users see duplicate resources although the original client calls reported failure.",
      "firstThought": "The timeout is an observation at the client boundary; the effect is unknown until the authoritative owner answers. Freeze blind replay and preserve original logical identities.",
      "safePath": "Quantify user operations versus attempts, map each key to canonical intent and owner receipts, classify committed/absent/unknown/duplicate, recover a bounded cohort without new identity, verify original operations and downstream effects, then fix atomic idempotency and retry ownership.",
      "trap": "Raising timeouts, adding retries, generating another key, deleting duplicate-looking rows, or declaring all timeouts failed without state-owner evidence."
    },
    {
      "id": "LES-0021-INC-002",
      "signal": "After a compatible-looking client change, 422 and 429 rise, audit pagination misses rows, and repeated validly signed webhooks repeat downstream effects.",
      "firstThought": "Treat validation, overload, traversal consistency, and replay as separate contracts that may interact; do not hide them behind one generic API error rate.",
      "safePath": "Stop the rollout, preserve versions and safe problem codes, cap attempts/concurrency, test old/new wire contracts, reconcile a snapshot or high-water inventory, enforce webhook freshness plus durable event claim, and canary recovery with explicit abort thresholds.",
      "trap": "Calling every additive schema change compatible, doubling capacity before controlling amplification, rerunning offset pages against a moving collection, or assuming a valid signature makes delivery exactly once."
    }
  ],
  "assessmentIds": ["ASM-0046", "ASM-0047", "ASM-0048"],
  "referenceIds": ["REF-0121", "REF-0122", "REF-0123", "REF-0124", "REF-0125", "REF-0126", "REF-0127", "REF-0128"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The required lab is a deterministic offline model. It proves no behavior of a real HTTP stack, proxy, gateway, identity provider, database, queue, webhook sender, SDK, OpenAPI generator, cluster, or cloud service.",
    "The command examples use Python standard-library checks and simplified policies to expose boundaries. They are not a general JSON Schema, OpenAPI, signature, canonicalization, or rate-limiting implementation.",
    "API version support, SDK behavior, gateway limits, identity policy, signature schemes, idempotency retention, pagination consistency, pricing, and provider retry guidance vary; verify current official contracts before production use.",
    "No real token, secret, certificate, endpoint, payload, customer identifier, network call, package installation, or privileged operation belongs in the lab.",
    "Publishing or completing this lesson does not award mastery. Independent evidence, human review, repeated incidents, and production feedback remain required."
  ]
}
---

# API contracts and serialization: make integrations survive failure and change

## What you see and first thought

You see `400`, `401`, `403`, `409`, `412`, `415`, `422`, `429`, `500`, a JSON decoding exception, or the most dangerous message of all: `TimeoutError` after a mutation was sent. Your first thought should not be "the API is down." Use this instead:

> An API result is a chain of contracts. Find the first boundary whose evidence no longer supports the promise.

Suppose a deployment tool sends:

```http
POST /v1/releases HTTP/1.1
Content-Type: application/json
Accept: application/json
Idempotency-Key: release-417

{"service":"payments","replicas":"3"}
```

Several different questions are hiding inside that small request:

1. Did the client create the intended value in memory?
2. Were its characters encoded to the expected bytes?
3. Does `Content-Type` correctly describe those bytes?
4. Is the document syntactically valid JSON?
5. Are the decoded values the required types? Here, `"3"` is a string, not a number.
6. Is this API version understood?
7. Who authenticated the caller?
8. May that principal create a release for this service and tenant?
9. Did validation finish before any effect?
10. Did the authoritative state owner commit?
11. Did the response reach the client before its deadline?
12. Did the client durably record the outcome?
13. Did the user-visible release actually become healthy?

A single message cannot answer all thirteen. `JSONDecodeError` stops near question 4. Status 422 often stops near question 5 or a business rule. Status 403 speaks to authorization, not field syntax. Status 201 speaks to the server's reported processing, but may not prove readiness of a deployment created asynchronously. A timeout after question 9 might leave question 10 unknown.

When an incident begins, say these sentences aloud:

```text
User promise:          the outcome users expected
Logical operation:     one durable intent, independent of attempts
Attempt:               one request transmission
Known client evidence: what was sent/received before the deadline
Authoritative owner:   the component that can prove the effect
Current outcome:       rejected, committed, absent, conflict, or unknown
Next safe evidence:    the smallest query that separates those states
```

Do not begin by raising timeouts, adding retries, turning strings into numbers on the server, disabling certificate verification, logging the whole request, or replaying a POST with a new key. Those actions can hide the original contract failure, leak secrets, increase overload, or create duplicates.

**Memory sentence:** a response tells you about one attempt; reliability requires preserving the logical operation across attempts and verifying the real outcome.

## Terms before commands

### API, interface, contract, and implementation

An **application programming interface (API)** is a boundary through which one component requests behavior or data from another. The interface includes more than a URL. It includes operations, representations, identity, authorization, timing, errors, limits, compatibility, and state semantics.

A **contract** is the behavior callers and providers agree to rely on. Some parts are machine-described, such as an OpenAPI document or JSON Schema. Some are behavioral prose, such as "reusing the same idempotency key with the same intent returns the original outcome for 24 hours." Some are operational, such as quotas and deprecation windows.

An **implementation** is code that attempts to satisfy the contract. A server may contain a bug even when its OpenAPI file is correct. A generated SDK may compile while sending behavior that is incompatible with an older server. Documentation is evidence of intent; wire tests and state-owner observations are evidence of behavior.

### Client, server, gateway, proxy, and state owner

A **client** initiates an API request. A **server** accepts it. A **gateway** or **reverse proxy** may terminate Transport Layer Security (TLS), authenticate, route, rate-limit, transform headers, or buffer bodies before the application sees them. Lesson 15 traced that HTTP path; this chapter focuses on the contract traveling through it.

The **state owner** is the component whose atomic rules determine whether the effect exists: often a database row, queue log, object store version, or control-plane record. The HTTP handler is not automatically the owner. If it enqueues a command and returns 202, the queue and downstream reconciler now own later transitions.

### Character, code point, glyph, byte, encoding, and Unicode

A **character** is an abstract text element. Unicode assigns each encoded character a **code point**, commonly written like `U+00E9` for `é`. A **glyph** is how a font draws a character. A **byte** is eight bits of data. An **encoding** maps text to bytes and back; UTF-8 is the dominant encoding for interoperable JSON.

The visible string `café` has four Python characters but five UTF-8 bytes because `é` uses two bytes. That matters for body limits, signatures, digests, truncation, database columns measured in bytes, and offsets reported by parsers. Never truncate an arbitrary UTF-8 byte sequence and assume it still decodes.

Unicode also has **normalization**: visually similar text can have different code-point sequences, such as a precomposed `é` or `e` plus a combining accent. Do not normalize identifiers, signed bytes, passwords, or opaque tokens unless the contract explicitly requires one normalization form. "Looks the same" is not byte equality.

### Serialization and deserialization

**Serialization** converts an in-memory value into a transferable representation. **Deserialization** parses a representation into runtime values. The boundary is untrusted even inside one company. Different languages have different integer ranges, decimal behavior, timestamp types, map ordering, and null conventions.

Serialization is not validation. A Python dictionary can serialize to valid JSON while violating every business rule. Deserialization is not authorization. A well-formed object may request an action the caller may not perform.

Never use a deserializer that can construct arbitrary language objects from untrusted input. This lesson uses JSON because its data model is deliberately limited, but JSON still needs depth, size, numeric, duplicate-key, and schema limits.

### JSON grammar and value types

JavaScript Object Notation (JSON) has six value categories:

- object: name/value members inside `{}`;
- array: ordered values inside `[]`;
- string: quoted Unicode text;
- number: a JSON numeric token;
- Boolean: `true` or `false`;
- null: `null`.

JSON does not define a separate wire-level integer type; a schema can require a number with no fractional part. Runtime parsers choose language types. Large integers may exceed a JavaScript consumer's exact range. Decimals may become binary floating-point approximations. Non-finite values such as NaN and Infinity are not interoperable JSON values even though some libraries allow them by default.

An object member's absence is different from a present member with `null`, an empty string, zero, or false. Define each meaning. For updates, decide whether omitted means "leave unchanged," null means "clear," or both are invalid.

JSON object name ordering is not a semantic identity rule. Duplicate member names create interoperability trouble because parsers may keep the first, keep the last, or reject. Security-sensitive boundaries should reject duplicates or define and test a single policy.

### YAML caveats

YAML is a human-oriented data serialization language often used for Kubernetes and CI configuration. It supports a richer data model than JSON: comments, anchors, aliases, multiple scalar styles, tags, and version-dependent implicit typing. That richness creates surprises. A value that looks like a date or Boolean may be typed differently by different YAML versions or libraries. Duplicate keys may be accepted differently. Aliases can expand into large structures. Unsafe loaders in some ecosystems can construct application objects.

Use a safe loader, pin the supported YAML version/library behavior, reject duplicate keys and unknown fields when appropriate, limit aliases/depth/size, and normalize into one typed internal model. Do not sign re-serialized YAML unless an exact canonicalization contract exists. For API transport, prefer the representation the API explicitly supports; converting YAML to JSON can lose comments, anchors, tags, and some type distinctions.

### Schema, validation, constraint, and invariant

A **schema** describes allowed structure: fields, types, required members, ranges, patterns, unions, and references. **Validation** checks a candidate against rules. A **constraint** is one rule. An **invariant** must remain true across state transitions, such as "a release belongs to exactly one tenant" or "current replicas cannot exceed quota."

Validation layers should be explicit:

```text
bytes decode
  -> representation parses
  -> schema shape/types pass
  -> business invariants pass
  -> principal is authorized for this exact action/resource
  -> conditional state transition succeeds
```

A schema cannot know current quota unless it consults state, and that check may race. The state owner must enforce invariants atomically when it commits.

### OpenAPI versus JSON Schema

**OpenAPI** describes an HTTP API: paths, operations, parameters, request bodies, response statuses and content, reusable components, servers, and security schemes. Its schema objects in OpenAPI 3.1 align closely with a JSON Schema dialect, but an OpenAPI document is not merely a JSON Schema file.

**JSON Schema** describes JSON instances using a declared dialect and vocabularies. It can express structure and validation assertions independent of an HTTP operation.

Think of it this way:

```text
OpenAPI:    who calls which HTTP operation, with what parameters/body,
            and what responses/security declarations can exist?

JSON Schema: what JSON instance shapes and values satisfy this schema dialect?
```

Neither automatically enforces itself. A gateway may validate only part of a request. Application code may drift from the document. Generated clients may implement one snapshot. Contract tests compare artifacts and real behavior.

### Media type, Content-Type, Accept, and content negotiation

A **media type** labels a representation, for example `application/json` or `application/problem+json`. Request `Content-Type` says what the request body is. Response `Content-Type` says what the response body is. Request `Accept` expresses which response media ranges the client can handle.

If the request body type is unsupported, status 415 is appropriate. If the server cannot select an acceptable response representation, status 406 may apply. A missing or wrong `Content-Type` is not repaired by the bytes happening to look like JSON. Treating headers as decoration creates proxy, cache, and parser inconsistencies.

### Resource, representation, operation, attempt, and receipt

A **resource** is the conceptual target identified by a URI. A **representation** is a current or intended state encoded in a media type. A **logical operation** is one durable user intent. An **attempt** is one transmission toward that operation. A **receipt** is durable evidence that an owner accepted, rejected, or committed an operation under an identity.

A user may press "Deploy" once while a client sends three attempts. Reliability dashboards must count both. If every attempt gets a new logical ID, the server cannot know they belong to one operation.

### Safe, idempotent, and cacheable methods

In HTTP semantics, a **safe** method is intended to be read-only with respect to the target semantics. **Idempotent** means multiple identical requests have the same intended effect as one; it does not mean responses, logs, billing, or timing are identical. GET and PUT are defined with different method properties than POST, but application design still matters. A nominally idempotent method can be implemented badly, and a POST can provide application-level idempotency through a stable key.

Do not retry merely because a method name is usually idempotent. Check whether the exact operation, conditional headers, authentication, body, and dependency side effects preserve the required invariant.

### Status code and problem details

An HTTP **status code** describes how the responding server understood and handled that attempt at the protocol/application boundary. It is not a universal root cause and not always the final workflow result.

Useful distinctions include:

- 200: a representation or result is returned;
- 201: a resource was reported created;
- 202: accepted for later processing, not completed;
- 204: successful response with no content;
- 400: bad request when no more specific classification is used;
- 401: authentication credentials are missing/invalid under the challenge contract;
- 403: authenticated or otherwise understood request is not authorized;
- 404: target not found, sometimes deliberately hiding authorization detail;
- 409: conflict with current state;
- 412: a supplied precondition such as `If-Match` failed;
- 415: unsupported request media type;
- 422: understood content could not be processed under its semantic rules;
- 428: server requires a conditional request to prevent lost updates;
- 429: request rate is limited;
- 500: server encountered an unexpected condition;
- 502/503/504: intermediary or availability/deadline conditions with different boundaries.

**Problem Details** defines a standard-shaped error representation commonly labeled `application/problem+json`. Its `type` identifies the problem class, `title` summarizes it, `status` can mirror HTTP status, `detail` describes this occurrence, and `instance` can identify an occurrence. Extension fields can carry stable codes or field pointers. Clients should recognize documented problem types/codes and handle unknown ones safely. Logs should not copy unbounded detail or secret-bearing fields.

### Authentication and authorization

**Authentication (authn)** establishes an identity or principal using a credential or protocol. **Authorization (authz)** decides whether that principal may perform an action on a particular resource under current policy. TLS protects a channel and can authenticate peers; it does not by itself grant application permission.

A token may be structurally valid but expired, wrong audience, wrong issuer, revoked, or missing scope. A service account allowed to read one namespace may not deploy another. Validate identity at the trust boundary, authorize after normalized resource identity is known, and enforce tenant/resource ownership at the state owner. Never treat a client-supplied tenant field as authorization proof.

### Deadline, timeout, cancellation, retry, backoff, and jitter

A **deadline** is the latest acceptable completion time for an operation. A **timeout** is a duration applied to one phase or call. Use a monotonic clock for elapsed time so wall-clock changes do not extend a budget.

**Cancellation** tells work it is no longer wanted. It is cooperative unless the state owner guarantees rollback. The client closing a connection cannot uncommit a database transaction that already completed.

A **retry** is another attempt. **Backoff** increases delay between attempts. **Jitter** randomizes timing so many clients do not synchronize. These controls reduce pressure only if attempts are capped, deadlines remain, retryable classes are narrow, and the fleet has a retry budget. Retrying a permanent validation error wastes capacity. Retrying an unknown mutation with a new identity creates duplicates.

### Idempotency key, deduplication, and key-to-intent binding

An **idempotency key** identifies one logical operation within a documented caller or tenant scope. The service should atomically associate it with a canonical non-secret intent fingerprint and the operation outcome. Repeating the same key and same intent returns or reconciles the same outcome. Reusing the key with different intent must be rejected.

A deduplication record needs a retention window longer than legitimate retry and reconciliation paths. After expiry, the service may no longer recognize a replay. "We use UUIDs" solves key collision probability, not key stability, storage, atomicity, scope, or timeout ambiguity.

### Optimistic concurrency, ETag, If-Match, and conflict

**Optimistic concurrency control** lets a client read a version and request an update only if that version is still current. An HTTP `ETag` is a representation validator. `If-Match` can require a matching validator; mismatch can yield 412 instead of silently overwriting another actor's change.

A version conflict is not automatically retryable. Fetch current state, understand the competing change, recompute intent, and seek review if policy changed. Blindly reading and overwriting again turns conflict protection into a loop.

### Pagination, offset, cursor, ordering, and snapshot

**Pagination** divides a collection response into bounded pages. **Offset pagination** asks to skip a number of rows. Inserts or deletes before the offset shift positions, so a traversal can repeat or omit items.

A **cursor** is a server-issued continuation token. Treat it as opaque: clients store and return it without parsing. A correct cursor contract defines filter, ordering, tie-breaker, expiry, authorization scope, and what happens during writes. A **snapshot** fixes a logical view in time; a **high-water mark** can bound an append-only traversal. Cursor pagination without snapshot semantics can still see change, so document the guarantee precisely.

### Rate limit, quota, backpressure, and retry budget

A **rate limit** bounds operations over time. A **quota** may bound stored resources or usage over a longer interval. **Backpressure** slows or rejects producers when consumers cannot keep up. A **retry budget** caps additional attempts relative to useful traffic or another explicit capacity pool.

Status 429 can include `Retry-After`, but this is not permission for every replica to sleep and retry simultaneously. Respect remaining deadline, add compatible jitter, centralize retry ownership, cap concurrency, and shed or queue work according to product policy. Measure logical operations, attempts, 429s, queue age, and budget exhaustion separately.

### Webhook, signature, freshness, and replay

A **webhook** is an HTTP callback delivering an event. Delivery is commonly at least once. A **signature** can authenticate selected bytes/components and detect modification when keys and algorithms are sound. It does not prove freshness or once-only processing.

Verify the exact raw body and declared components before transformations. Check key identity and algorithm policy. Enforce a created/expires field or provider timestamp within a bounded window using a trustworthy clock. Atomically claim a durable event ID before the effect. Store the effect receipt. A repeated valid event should return the provider's accepted response without performing the effect twice.

### Compatibility, breaking change, version, and deprecation

**Backward compatibility** means a newer provider continues to work for supported older consumers. **Forward compatibility** means an older consumer can safely handle allowed newer data. Compatibility depends on actual consumer behavior, not whether a change looks additive.

Adding an optional response field can break a consumer configured to reject unknown fields. Adding an enum value can break an exhaustive switch. Tightening validation breaks old producers. Changing default, ordering, pagination, error type, precision, or timing can break behavior without changing shape.

Version only where it creates a clear compatibility contract. A URL `/v1` does not eliminate schema revisions or deprecation. Publish support windows, telemetry for old clients, migration guides, test matrices, and removal criteria. Never silently reuse a field with a new meaning.

### SDK, generated client, and adapter

A **software development kit (SDK)** packages models and client behavior. Code generation can reduce repetitive code and synchronize types with a description. It can also hide default timeouts, automatic retries, unknown-field behavior, nullable mapping, date parsing, connection pooling, telemetry, or generated breaking changes.

Wrap an SDK behind a narrow adapter. Configure deadlines, retries, headers, identity, redaction, and error translation explicitly. Pin and review generator/runtime versions. Test wire fixtures and timeout-after-effect behavior. A typed SDK model cannot replace server-side validation or authorization.

### Contract test, provider test, consumer test, and end-to-end test

A **contract test** checks observable interface behavior: representation, status, headers, errors, compatibility, and state semantics. A **provider test** verifies the provider satisfies published cases. A **consumer test** records what one consumer relies on. A schema compatibility check compares descriptions. An **end-to-end test** crosses the deployed path and verifies a user operation.

No single layer proves everything. Mocks test caller decisions but cannot prove a proxy or service. Schema validation tests shapes but not side effects. Integration tests need controlled state. Production canaries need tight blast radius and rollback/reconciliation.

## Architecture map

Here is the complete path. Read it as ownership boundaries, not as a list of products:

```text
 HUMAN / CONTROLLER
 "create release payments@2026.08.02 with 3 replicas"
             |
             | logical_operation_id=release-417
             v
+---------------- CLIENT PROCESS ----------------+
| typed model -> validation -> serialize UTF-8   |
| persist intent/key -> deadline -> send attempt |
+------------------------------------------------+
             |
             | method + URI + headers + body bytes
             v
+--------- NETWORK / GATEWAY BOUNDARY -----------+
| DNS/TCP/TLS -> proxy -> route -> size/rate     |
| authenticate principal -> correlation evidence |
+------------------------------------------------+
             |
             v
+---------------- SERVICE ------------------------+
| negotiate -> parse -> schema -> business rules |
| authorize principal/action/resource            |
| bind idempotency key to canonical intent       |
| conditional state transition                   |
+------------------------------------------------+
             |
             v
+------------- AUTHORITATIVE OWNER ---------------+
| resource version + operation outcome + receipt |
+------------------------------------------------+
             |
             | response may be delayed or lost
             v
+---------------- CLIENT AGAIN -------------------+
| classify status/problem/timeout                 |
| reconcile unknown -> durable local receipt      |
+------------------------------------------------+
             |
             v
 USER VERIFICATION: resource and real journey are correct
```

The diagram prevents three common mistakes.

First, a transport or gateway can reject before application code sees the request. Second, the HTTP connection can fail after the state owner commits. Third, a successful API resource can still fail the higher user journey: a deployment object may exist while pods never become ready.

### Contract ownership table

| Contract | Typical owner | Evidence | Common wrong conclusion |
|---|---|---|---|
| client input model | client executable | validated typed value and artifact version | type annotations validate runtime input |
| encoded request | serializer/client | media type, byte length/digest, bounded safe fixture | a printed object equals sent bytes |
| route and transport | gateway/network | sanitized access log, TLS/route ID, upstream timing | gateway 2xx proves service effect |
| identity | identity provider/gateway/service | issuer, audience, subject, credential class, decision ID | possession of any token grants access |
| schema/business rules | service | stable problem type/code, safe field pointer | valid JSON is valid request |
| idempotency | service plus durable store | key scope, intent fingerprint, stored outcome | a UUID makes retries safe |
| resource mutation | database/control plane | version, transaction/operation receipt, state query | client timeout means rollback |
| pagination snapshot | collection owner | ordering, cursor, snapshot/high-water ID | opaque cursor automatically means snapshot |
| webhook effect | receiver's state owner | verified signature/freshness, unique event claim, effect receipt | valid signature means exactly once |
| user outcome | product/system | end-to-end check and SLO signal | API response is the whole journey |

## Request or state path

Follow one create operation slowly.

### 1. Establish intent before an attempt

The caller creates a typed request:

```json
{
  "service": "payments",
  "target": "2026.08.02",
  "replicas": 3
}
```

It validates exact types and allowed ranges. It creates or loads durable logical operation ID `release-417`. It builds a canonical non-secret intent fingerprint. The idempotency record must never include a bearer token or secret payload merely to compute identity.

### 2. Serialize and label bytes

The serializer emits UTF-8 JSON bytes. It rejects non-finite numbers, unsupported types, excessive depth/size, and ambiguous values according to policy. The client sets request `Content-Type: application/json` and response `Accept` for representations it actually supports. It records byte count and perhaps a safe digest, not the secret body.

### 3. Apply one overall deadline

The operation gets an overall monotonic deadline, for example five seconds. DNS, connection, TLS, request upload, server processing, response headers, and body read consume that one budget. Nested libraries must receive the remaining time. Five layers each applying a fresh five-second timeout can turn a five-second promise into twenty-five seconds.

### 4. Cross authentication and authorization

The gateway/service validates credential issuer, audience, expiry, signature or session, and maps it to a principal. The service resolves the canonical tenant/service resource and asks policy whether that principal may create this release. Authentication failure and authorization denial are not transient load errors.

### 5. Validate before effect

The service checks media type, JSON syntax, schema, unknown fields, types, ranges, supported version, and business invariants. Prefer validation before mutation. If validation requires current state, enforce the decisive invariant again atomically with the state transition.

### 6. Bind identity to intent and commit

Inside an atomic boundary appropriate to the state owner, the service:

1. looks up caller-scope plus idempotency key;
2. if absent, stores key plus canonical intent fingerprint and pending/committed transition;
3. if present with the same fingerprint, returns or reconciles the stored outcome;
4. if present with another fingerprint, rejects key reuse;
5. commits the resource and durable operation outcome together where possible.

If resource mutation and idempotency record live in separate systems, there is a new failure window. Use a transactional owner, outbox/log pattern, or explicit reconciliation; do not call the workflow "atomic" across unsupported boundaries.

### 7. Return an attempt response

The server returns status, response `Content-Type`, resource/operation ID, version/ETag, and a bounded body or problem detail. A 201 may carry a resource location. A 202 should expose an operation that can be polled. A 204 has no response body to parse.

### 8. Handle deadline ambiguity

If the response arrives and validates, the client persists the receipt and verifies the resource. If the client deadline expires after send, it records **unknown**. It queries by the same operation/key. It does not generate a new key. Only an authoritative committed outcome or a strong documented proof of absence changes that state.

### 9. Verify the user operation

Verification compares the authoritative resource with intended service, target, replica count, tenant, and version. Then it checks the real outcome: rollout ready, policy applied, audit published, or consumer view correct. It reconciles duplicates and missing receipts. Only then does the client report operational success.

## Failure zoom

### Failure 1: valid JSON, wrong contract

```text
body bytes -> UTF-8 decode OK -> JSON grammar OK
                                   |
                                   v
                            replicas = string "3"
                                   |
                         schema requires integer
                                   |
                                   v
                       422 problem: integer-required
                       mutation attempts: zero
```

The right action is to fix the producer and issue a reviewed request. Backoff cannot change a string into an integer. Silent coercion on the server seems friendly but expands the public contract and creates ambiguous edge cases.

### Failure 2: timeout after commit

```text
client                     service                  state owner
  | POST key=release-417      |                         |
  |-------------------------->| validate + authorize    |
  |                           |------------------------>|
  |                           |          COMMIT         |
  |       deadline expires    |<------------------------|
  X                           | 201 response             |
                              |---- response lost ------X

client evidence = no timely response
owner evidence  = committed release-417
safe next step  = record receipt and verify; zero extra POST attempts
```

The network did not create the unknown outcome; the distributed ownership boundary did. A timeout cannot reverse a committed state. Reconciliation is part of the normal protocol, not an exceptional manual trick.

### Failure 3: retries become an outage multiplier

Given 240 logical operations per second and four retries, the theoretical maximum is:

```text
attempts per operation = first attempt + retries = 1 + 4 = 5
maximum attempt rate   = 240 operations/s x 5 attempts/operation
                       = 1,200 attempts/s
```

With 60 replicas and 100 allowed in-flight calls each:

```text
configured concurrent-attempt ceiling = 60 x 100 = 6,000 attempts
```

These are configuration ceilings, not proof the system reached them. Measure logical operations, attempts, residence time, in-flight, queues, 429, timeouts, and retry reasons. Still, the ceiling explains why an apparently small retry setting can overpower a dependency.

### Failure 4: offset pagination over a moving collection

```text
Initial ordered IDs:  [A, B, C, D]
GET offset=0 limit=2 -> [A, B]
new item X inserted before A
Current ordered IDs:  [X, A, B, C, D]
GET offset=2 limit=2 -> [B, C]

Result: B repeated, D not yet reached; other changes can create omissions.
```

A stable total order needs a unique tie-breaker. A cursor should bind the filter/order and, if promised, snapshot or high-water state. A client must not decode and modify opaque cursors.

### Failure 5: a valid webhook repeats an effect

An attacker or a delayed provider replays an old message with a valid signature. Signature verification passes because the bytes are authentic. Without a timestamp window, the receiver accepts stale delivery. Without durable event-ID claiming, it sends another notification or deployment.

Three checks answer different questions:

```text
signature valid?  Were the covered bytes signed by an accepted key?
fresh enough?     Is this delivery inside the allowed time window?
event unclaimed?  Has this logical event already produced the effect?
```

All three are needed. Authorization of the requested effect remains a fourth check.

## Internals and state ownership

### The client state machine

A reliable client does not throw every outcome into "success" or "error." Use explicit states:

```text
NEW
  -> VALIDATED
  -> INTENT_PERSISTED
  -> ATTEMPT_IN_FLIGHT
       |-- known rejection ----------> REJECTED (no retry unchanged)
       |-- committed receipt --------> COMMITTED
       |-- version conflict ---------> CONFLICT (re-read/re-plan)
       |-- 429 known no-effect ------> DELAY_ELIGIBLE (budget permitting)
       |-- transient proven no-effect> RETRY_ELIGIBLE (budget permitting)
       `-- deadline/connection loss -> UNKNOWN
                                      |
                                      v
                              RECONCILE AT OWNER
                               | committed -> COMMITTED
                               | absent ----> RETRY_ELIGIBLE
                               ` unknown ---> STOP / ESCALATE

COMMITTED -> VERIFY_RESOURCE -> VERIFY_USER_OPERATION -> COMPLETE
```

Never create a new key merely because state is `UNKNOWN`. That would bypass the only correlation the owner can use.

### Server-side idempotency record

A useful record contains:

| Field | Purpose |
|---|---|
| caller/tenant scope | prevents cross-principal key collisions and data leakage |
| idempotency key | stable logical operation identity |
| contract/version | preserves interpretation context |
| canonical non-secret intent fingerprint | rejects same key with changed intent |
| state | pending, committed, rejected, or explicit terminal category |
| resource/operation identity | supports reconciliation |
| response/receipt summary | permits consistent replay response without secrets |
| created/expiry time | defines deduplication horizon and capacity |
| fencing/version | coordinates concurrent attempts |

The key record and effect must be committed atomically when the state owner supports it. If a pending record can remain after a crash, another worker needs lease/fencing or a reconciliation rule. A stale worker must not overwrite a newer outcome.

### HTTP validators and lost-update prevention

Consider two operators reading version 17. Both edit different fields. Without a precondition, the later write may erase the first. With `ETag: "v17"` and `If-Match: "v17"`, the first update creates v18 and the second receives 412.

The second client must fetch v18, understand the first change, recompute its desired update, and send a new reviewed precondition. Automatically replacing `If-Match` with the latest ETag without reviewing intent defeats the protection.

### Schema evaluation and application models

At the ingress boundary, retain three distinct objects:

1. raw bytes, bounded and protected for signature/forensics where policy permits;
2. parsed generic data, still untrusted;
3. validated immutable domain model, safe for internal decision logic.

Do not pass a raw dictionary throughout the service. Normalize identifiers once, retain original safe error locations, and make impossible states unrepresentable. Reject fields the service does not understand when silent acceptance would mislead a caller; tolerate documented future fields when forward compatibility requires it. The choice is contract-specific.

### Authentication, authorization, and confused deputies

A **confused deputy** is a component with authority that is tricked into using it for an unauthorized caller. A platform service may have cluster-wide credentials while clients have tenant-level rights. If it trusts a client-supplied namespace or callback URL without policy, it becomes the deputy.

Bind authorization to normalized resource identity, caller identity, action, and current policy. Restrict outbound destinations to prevent server-side request forgery. Do not forward inbound bearer tokens to arbitrary downstream services. Prefer audience-specific short-lived credentials and least-privilege service identities.

### Pagination owner and consistency envelope

The collection owner must declare:

- the filter and authorization scope;
- stable ordering and a unique tie-breaker;
- whether each page reflects request time, one traversal snapshot, or append-only high-water behavior;
- cursor opacity, expiry, and invalidation;
- maximum/default page size;
- behavior when records update/delete;
- next/end representation and total-count semantics.

A reported total may be exact, approximate, expensive, or scoped to a snapshot. A client should reconcile stable IDs rather than trusting that `page_count * page_size` equals reality.

### Rate-limit owner and fairness

A limiter may operate per credential, tenant, IP, route, resource, or fleet. Clients need to know the relevant scope to avoid one noisy tenant exhausting everyone. Servers should expose safe guidance and metrics; clients should use admission queues, per-tenant fairness, concurrency caps, and retry budgets.

Little's Law provides a useful first estimate for a stable system:

```text
average in-flight work = arrival rate x average residence time
```

At 240 attempts/s with 0.75 s average residence, average in-flight is about 180. That is not a safe concurrency setting by itself: arrivals and latency vary, tail latency matters, retries add load, and dependency quotas bind. Measure distributions and maintain safety margin.

### Webhook state owner

The webhook receiver should atomically create a unique event claim and effect/outbox transition. If it writes "seen" before effect and crashes, it can lose the effect. If it performs the effect before writing "seen," it can duplicate after crash. One transactional owner or an outbox/inbox state machine closes the local gap; distributed downstream effects still need idempotency and reconciliation.

Return acknowledgement only according to provider retry semantics. A response can be lost, so redelivery is normal. Keep event-ID retention longer than the provider's replay/redelivery horizon, subject to privacy and capacity policy.

## Evidence table

The command is never the diagnosis. Begin with a question, collect one bounded observation, and state its proof limit.

| ID | Question | Risk | Expected branches | Proves | Does not prove |
|---|---|---|---|---|---|
| CMD-001 | characters versus UTF-8 bytes? | read-only, synthetic memory | four characters/five bytes, or environment mismatch | local encode/decode facts | media type, normalization, remote decode |
| CMD-002 | parser-produced JSON types? | read-only, stdin | object/string/bool/null, or syntax error | types for exact input | schema, authorization, mutation |
| CMD-003 | strict request boundary satisfied? | read-only, synthetic memory | accepted, or explicit assertion failure | displayed type/range checks | complete schema or business rules |
| CMD-004 | acceptable response media type? | read-only, simplified model | JSON selected, or 406 | local set intersection | full content negotiation or response meaning |
| CMD-005 | stable intent fingerprint bytes? | read-only, synthetic memory | deterministic bytes/digest, or serialization reject | one local canonical model | authentication or universal canonical JSON |
| CMD-006 | which abstract outcome is retryable? | read-only, policy model | only proven-absent transient | displayed retry mapping | actual production outcome |
| CMD-007 | stale conditional update? | read-only, synthetic values | 412 mismatch, or modeled match | version equality decision | server atomicity or merge safety |
| CMD-008 | page duplicate/omission? | read-only, synthetic sets | one duplicate/one missing, or complete set | explicit ID reconciliation | root cause or unobserved records |
| CMD-009 | retry/concurrency ceiling? | read-only, arithmetic | 1,200 attempts/s and 6,000 in-flight | math from stated settings | measured load or safe capacity |
| CMD-010 | problem body has machine class? | read-only, synthetic JSON | known type/status/code, or field failure | local field presence/types | authenticity, sanitization, retryability |
| CMD-011 | raw-body change affects HMAC? | read-only, synthetic secret | signatures differ | local bytes affect digest | real provider authenticity/freshness/replay |
| CMD-012 | lab clean and ready? | read-only, local metadata | absent, or a safety refusal | controller preflight at that instant | future state or real API behavior |

### Incident evidence ledger

In a real event, build a chronological ledger like this:

| Time | Evidence | Class | Proves | Does not prove | Next evidence |
|---|---|---|---|---|---|
| 10:00:00 UTC | client persisted operation `release-417`, artifact `client@abc123` | observation | one client intended one logical operation | request reached service | correlate the same operation/key at the gateway |
| 10:00:00.120 | gateway saw POST, key digest K, upstream bytes sent | observation | gateway forwarded that attempt | state owner committed | query the owner's idempotency/operation record |
| 10:00:00.750 | client deadline expired | observation | no complete response reached client in 750 ms | operation failed or rolled back | reconcile by the same operation/key at the state owner |
| 10:00:00.640 | owner stored key K, intent digest I, outcome committed, resource R v18 | observation | the state owner committed that logical identity | user workload became ready | query resource R and its downstream rollout state |
| 10:00:01.100 | release R query matches target and replicas | observation | authoritative resource has intended fields | downstream health is good | test readiness and the promised user journey |
| 10:00:20.000 | user journey and readiness checks pass | observation | promised operation works in tested journey/window | permanent reliability | watch SLO, errors, and rollback guardrails over the rollout window |

Always label a claim. **Observation** came from a source. **Documented contract** states promised behavior. **Calculation** follows stated inputs. **Inference** connects evidence. **Hypothesis** predicts missing evidence. **Unknown** is an honest unresolved branch.

## Command decoders

These commands are intentionally local and synthetic. Their value is learning to read fields before you touch an endpoint.

### CMD-001: characters are not bytes

Run:

```bash
python3 -c 's="café"; b=s.encode("utf-8"); print("characters="+str(len(s))); print("bytes="+str(len(b))); print("hex="+b.hex()); print("round_trip="+b.decode("utf-8"))'
```

Expected output:

```text
characters=4
bytes=5
hex=636166c3a9
round_trip=café
```

`characters=4` counts Python Unicode code points in this value. It is a point-in-time count, not bytes or display width. `bytes=5` counts the encoded octets. `hex` shows each byte as two hexadecimal digits: `63 61 66` are ASCII-compatible bytes for `caf`; `c3 a9` encodes `é`. `round_trip` proves those bytes decode under UTF-8 to the original value.

Do not infer that every visually identical string has those bytes. Normalization can differ. Do not slice a body at five bytes based on four-character UI rules. For a real incident, record the received byte count, declared media type, decoder, normalization policy, and safe digest at the exact boundary.

### CMD-002: see JSON types, not their appearance

Run:

```bash
printf '%s\n' '{"replicas":"3","enabled":true,"note":null}' |
  python3 -c 'import json,sys; v=json.load(sys.stdin); print("top="+type(v).__name__); [print(k+"="+type(v[k]).__name__) for k in sorted(v)]'
```

Expected output:

```text
top=dict
enabled=bool
note=NoneType
replicas=str
```

`dict`, `bool`, `NoneType`, and `str` are Python runtime types chosen by this parser. The important line is `replicas=str`: quotation marks are part of the JSON grammar and make `3` text. A validator requiring an integer should reject it. Do not call `int(value)` automatically at a trust boundary; strings such as whitespace, signs, decimals, huge values, or unexpected Unicode require an explicit public policy.

If parsing fails, the first failed boundary is syntax/decoding. If parsing succeeds, move to schema. Never treat parse success as authorization or effect evidence.

### CMD-003: strict boundary checks

Expected output is:

```text
schema=accepted
```

The command checks five things: top-level object, exact field set, nonempty string, exact integer type, and inclusive range 1 through 20. `type(x) is int` deliberately rejects Python Boolean values even though `bool` subclasses `int`. `set(v)==...` rejects missing and unknown fields.

Production code should not use bare assertions for untrusted input because optimized execution can remove them and the exception is not a stable client contract. Use an explicit validator that returns a bounded problem code and safe field pointer. This tiny command exposes the questions the real validator must answer.

### CMD-004: content negotiation

Expected output:

```text
selected=application/json
status=200
```

`supported` is the server's response set. `accept` is the client's supported response set. `selected` is their first exact intersection. If no value intersects, this toy model prints `selected=None` and `status=406`.

Real `Accept` syntax supports media ranges, parameters, wildcards, and quality weights. Do not copy this set-intersection algorithm into a production HTTP server. The durable lesson is directional: request `Content-Type` labels inbound body bytes; request `Accept` constrains outbound representations; response `Content-Type` labels what was actually returned.

### CMD-005: intent fingerprint

Output resembles:

```text
{"replicas":3,"service":"payments","target":"2026.08.02"}
39f...<64 hexadecimal characters total>...
```

The first line is compact JSON with sorted object names, UTF-8 text, and non-finite numbers rejected. The second is a SHA-256 digest over those exact bytes. The digest is a fingerprint, not encryption: anyone who can guess a small input space can compute the same digest. Do not include a bearer token, password, personal data, or raw secret merely to identify an operation.

A production scheme must version the canonical model. Two equivalent domain intents may serialize differently across languages. Conversely, two identical payloads can represent two legitimate distinct operations. Keep a client-issued logical ID and store caller scope plus a canonical non-secret intent fingerprint; use the fingerprint to reject key reuse with changed intent.

### CMD-006: retry policy table

Expected output:

```text
rejected retry=false
committed retry=false
proven_absent_transient retry=true
unknown retry=false
conflict retry=false
```

`rejected` needs corrected input or permission, not delay. `committed` needs receipt and verification, not another mutation. `proven_absent_transient` can retry if a stable identity, deadline, attempt cap, backoff, jitter, and fleet budget permit. `unknown` must reconcile. `conflict` must re-read and re-plan.

Some APIs atomically deduplicate a repeated unknown attempt under the same key, making resending part of their documented reconciliation mechanism. Even then, reuse the same key and obey budget. The table intentionally chooses the conservative client rule: query first.

### CMD-007: conditional update

Expected output:

```text
current_etag=v18
if_match=v17
status=412
```

The current validator differs from the version the client read. Status 412 prevents a lost update in the modeled equality rule. It does not say which actor changed the resource or whether the changes can merge. Fetch v18, show the difference, re-authorize, and produce a new intent. If a server requires conditions, 428 can tell a client it omitted the protection.

A weak ETag can be valid for cache validation but may not be appropriate for every range or concurrency claim. Follow the API's documented validator semantics.

### CMD-008: reconcile pages by stable identity

Expected output:

```text
duplicates=1
missing=r3
```

The program flattens page IDs, compares row count with unique count, and subtracts observed IDs from an explicit expected snapshot. `duplicates=1` is a count of extra occurrences, not the number of distinct IDs duplicated. `missing=r3` names the expected ID absent from both pages.

A production client may not know the full expected set. It can still enforce stable ordering, track seen IDs within a bounded traversal, record cursor/snapshot IDs, compare authoritative counts when defined, and reconcile from an append-only log or high-water mark. Beware memory growth when tracking millions of IDs; use durable partitions or streaming reconciliation rather than an unbounded in-memory set.

### CMD-009: attempt amplification

Expected output:

```text
max_attempt_rps=1200
configured_inflight=6000
```

`logical_rps=240` has units operations per second. `attempts_per_operation=5` is dimensionless. Their product is attempts per second. `replicas=60` times `per_replica=100` is an upper limit of concurrent calls. Neither is a measured counter.

Measure actual attempt rate divided by logical operation rate; call that retry amplification. Track its distribution by bounded outcome class. Measure mean and tail residence time. If 429 or tail latency rises, clients must reduce admission and retries rather than forcing the server to absorb the configured ceiling.

### CMD-010: problem details

Expected output:

```text
type=https://errors.example.invalid/invalid-field
status=422
code=integer-required
```

`type` is a URI identifying a problem class in this synthetic example; the `.invalid` domain cannot be a real service. `status` repeats the modeled HTTP status but clients should use the actual HTTP status line as protocol evidence. `code` is an extension chosen as a stable, bounded machine classifier.

Do not build retry behavior from English `title` or `detail`. Those fields can change, be localized, or echo sensitive input. Reject an unbounded body, sanitize before logging, and have a fallback for unknown problem types.

### CMD-011: webhook raw bytes

Expected output:

```text
same_signature=false
```

Hash-based message authentication code (HMAC) combines a secret key and bytes. `compare_digest` avoids a simple timing leak in comparison. The example changes `ready` to `failed`, so the computed values differ.

This is not a complete webhook verifier. A real provider defines exactly which method, target, headers, timestamp, and raw body bytes are covered and how they are encoded. Keys need rotation and least privilege. A valid signature still needs freshness, event-ID dedupe, authorization, body/schema limits, and a safe acknowledgement policy.

### CMD-012: lab preflight

From `book/labs/LES-0021-api-contracts`:

```bash
bash lab.sh check
```

Clean output:

```text
lesson=LES-0021
state=absent
network=none
```

`lesson` prevents confusing another lab's state. `state=absent` means no descriptor and no matching orphan were observed for your UID at that instant. `network=none` is the lab's design policy. A refusal about owner, mode, symlink, hard links, model bytes, orphan, or unknown file is a safety success: the controller lacks proof that broader action is safe.

## Decision path

Use this tree when an API operation fails or becomes ambiguous:

```text
START: what exact user operation and logical ID are affected?
  |
  +-- No stable logical ID? -> stop replay; construct reconciliation ledger
  |
  +-- Did client construct/validate intended typed input?
  |      no -> reject locally; fix producer; no network retry
  |
  +-- Did bytes/media type reach the intended endpoint/version?
  |      no -> preserve route/transport evidence; fix boundary
  |
  +-- Response received?
  |      |
  |      +-- 2xx -> validate response -> query resource -> verify user outcome
  |      +-- 4xx validation/auth/conflict -> classify; correct/re-authorize/re-plan
  |      +-- 429 -> known policy branch; remaining deadline and budgets?
  |      +-- 5xx -> did mutation definitely not occur?
  |      `-- problem body unknown/malformed -> safe generic failure; preserve sample
  |
  +-- No complete response after mutation may have been sent?
         -> outcome UNKNOWN
         -> query state owner by SAME logical ID/key
              |-- committed -> persist receipt; verify; DO NOT POST again
              |-- proven absent + transient + budget -> bounded retry same key
              `-- still unknown -> stop and escalate; do not invent certainty
```

### Status is an input to a decision, not the decision

A retry table might begin like this, then be narrowed by the API contract:

| Signal | Default interpretation | Automatic action |
|---|---|---|
| local schema reject | known invalid before send | none; correct input |
| 401 | authentication contract failed | refresh only through approved identity flow; never loop |
| 403 | not authorized | none; request/repair policy through owner |
| 404 | absent or hidden | contract-specific; do not infer authorization |
| 409/412 | state/version conflict | re-read, re-plan, re-authorize |
| 415/406/422 | representation/contract mismatch | correct producer or negotiation |
| 429 | rate-limited attempt | wait/requeue only within deadline and budgets |
| 500/502/503/504 | server/intermediary failure | mutation outcome may still be unknown; consult contract/owner |
| connection failure before any byte sent and proven | no remote attempt | retry may be eligible within budget |
| deadline after send | unknown | reconcile by same identity |

The phrase "proven before any byte sent" is deliberately strict. Many client libraries cannot expose that proof cleanly. Conservative unknown handling is safer for non-idempotent effects.

### Recovery card

Before changing production state, write:

```text
Actor:           authorized identity/person/service
Target:          exact operation IDs and resource versions
Preconditions:   owner evidence that selects this branch
Action:          query, receipt repair, bounded retry, or compensation
Scope:           tenant/cohort/count; never "all"
Concurrency:     explicit maximum and fairness rule
Budget:          attempts, elapsed time, retry percentage
Abort:           duplicate, unknown age, error, latency, quota thresholds
Prior state:     evidence/artifacts retained
Rollback:        how to stop new work; what cannot be rolled back
Compensation:    business reversal for committed external effects
Verification:    resource plus user operation, duplicates, omissions
Owner approval:  named team/change/incident authority
```

Rollback returns a controlled local configuration to an earlier version. Compensation creates a new effect that semantically counteracts a committed effect. They are not interchangeable. Deleting a duplicate deployment might disrupt traffic and audit history; compensation needs domain ownership.

## Guided Ubuntu lab

The lab lives at `book/labs/LES-0021-api-contracts`. It uses only Bash, Python 3, and ordinary Ubuntu tools. It opens no socket and makes no network request.

### Safety card

```text
Platform:     Ubuntu 24.04 or WSL 2 Ubuntu 24.04
Identity:     normal non-root user; UID 0 refused with status 77
Network:      none
Ports:        none
Installation: none
State:        one UID descriptor + one mode-0700 random /tmp root
Cleanup:      exact allowlisted paths only; no recursion or wildcard
Stop when:    any orphan, symlink, owner/mode/link, model, unknown-file,
              lock, dependency, or transition refusal appears
```

### Step 1: preflight and setup

```bash
cd book/labs/LES-0021-api-contracts
bash lab.sh check
bash lab.sh setup
bash lab.sh status
```

Setup output includes a random `lab_root`. The directory is mode 0700. The controller installs a mode-0500 copy of the reviewed model and records one atomic descriptor using a hard-link registration step that refuses an existing name. A repeated setup validates and reports `setup=already-present`.

If `check` reports an orphan, do not run `rm -rf /tmp/reliability-atlas-*`. Preserve exact path, owner, mode, link type, and contents. An orphan may be an interrupted setup or another process's object; the controller intentionally refuses to guess.

### Step 2: successful baseline

```bash
bash lab.sh run baseline
```

Representative fields:

```text
record=baseline
method=POST
request_content_type=application/json
request_accept=application/json
parsed_replicas_type=int
unicode_service=café-api
utf8_byte_count=64
canonical_sha256=<digest>
response_status=201
consumer_readback=valid
```

The exact byte count and digest are deterministic for the fixture. Record them rather than memorizing them. Baseline proves the model can complete a valid representation path. It does not prove the injected path or a real service.

### Step 3: guided wrong-type incident

```bash
bash lab.sh inject guided
bash lab.sh observe request
bash lab.sh observe contract
bash lab.sh observe operation
```

You should find:

```text
observed_replicas_json_type=string
required_replicas_json_type=integer
response_status=422
response_content_type=application/problem+json
problem_code=integer-required
mutation_attempts=0
authoritative_state=absent
```

Diagnosis: syntax is not the first failure. Runtime schema type is. The modeled service rejects before mutation. The same invalid request is not retryable. A corrected request is a new reviewed intent.

Now explore adjacent contracts:

```bash
bash lab.sh observe page
bash lab.sh observe limit
bash lab.sh observe webhook
```

The page is bound to snapshot `inventory-9` and contains four unique IDs across two pages. The 429 model provides `retry_after_seconds=2`, an attempt budget, and a fleet budget. The webhook model exposes signed components, timestamp age, and first-delivery state. These are separate mechanisms, not proof that the invalid request mutated.

### Step 4: recover and verify

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

For this case, "recovery" means the invalid request stays rejected and a corrected integer representation is demonstrated without pretending the old attempt succeeded. Verification reports zero duplicate effects and validates all modeled contract categories.

### Step 5: exact cleanup

```bash
bash lab.sh cleanup
bash lab.sh check
```

The cleanup validates every child before removing individual names, releases the verified lock, removes the empty root with `rmdir`, revalidates the descriptor, removes it, and proves absence. If an unknown entry exists, cleanup stops and preserves it. Convenience never outranks ownership proof.

### Independent incident

Begin clean:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Copy raw scenario output into the separate ASM-0048 response template. Before any `observe`, write three hypotheses and a predicted disconfirming observation. The scenario contains request facts such as method, media types, API version, stable key, deadline, payload, and page limit. It deliberately excludes authoritative outcome, receipt, diagnosis, recovery, duplicate count, retry eligibility, and answer key.

Then select evidence:

```bash
bash lab.sh observe request
bash lab.sh observe contract
bash lab.sh observe operation
bash lab.sh observe page
bash lab.sh observe limit
bash lab.sh observe webhook
```

Classify each line as observation, documented model fact, inference, or unknown. Write a recovery card before running:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash verify.sh
```

The verifier independently runs both lifecycles and tests answer isolation, invalid transitions, changed model bytes, unexpected files, symlink redirection, descriptor escape, orphan refusal, idempotent cleanup, and generated Python residue. It does not score your reasoning.

### Lab incident branches

**Branch A: `installed-model-differs-from-reviewed-source`.** Stop. The executed file no longer matches the repository fixture. Preserve hashes/metadata, identify the actor, and restore only by an exact reviewed install. Cleanup also refuses while integrity is unknown.

**Branch B: `unexpected-child-*`.** Stop. The controller will not delete a file it did not create and recognize. Inspect exact path, type, owner, mode, link count, and process provenance. Do not broaden cleanup.

**Branch C: `state-lock-contended`.** Another local invocation holds the workflow lock. Identify and wait for it. Removing the lock pathname does not release an open file-description lock and can create two lock objects.

**Branch D: controller interrupted.** Re-run `bash lab.sh check` and `status`. Setup registration and record transitions are designed to be inspected/resumed. Use supported cleanup only after state validates.

### What the lab proves

A passing verifier proves the reviewed local code observed deterministic transitions, refused tested unsafe states, kept independent raw input answer-isolated, removed its exact state, and left no Python bytecode cache under the lab directory. It does not prove HTTP interoperability, network timing, OpenAPI correctness, cryptographic security, production authorization, distributed atomicity, or mastery.

## Production transfer

### CI pipeline integration

A CI job that calls a deployment API adds boundaries absent from the lab:

```text
source commit -> build artifact -> runner image -> workload identity
      -> proxy/DNS/TLS -> platform API -> control-plane store
      -> asynchronous reconciler -> workload -> verification gate
```

Pin the client artifact and runtime. Validate configuration at startup. Obtain a short-lived audience-specific identity through the CI platform; do not store a long-lived token in repository variables when workload federation is available. Keep operation identity in a durable store or pipeline artifact that survives runner replacement. Treat pipeline rerun and job retry as retry owners; disable nested client replay unless designed together.

A dry-run usually proves validation and authorization only at the time it runs. State can change before apply. Use conditional versions and an approval tied to exact plan/intent digest. After apply, verify resource version and deployment health. Rollback of the client job cannot undo an accepted deployment; reconcile it.

### Kubernetes operator or controller

Controllers receive duplicate events and continually reconcile desired with observed state. Design reconciliation as idempotent convergence:

1. read desired object and generation;
2. validate and authorize through Kubernetes admission plus controller policy;
3. read authoritative external state;
4. compute a pure plan;
5. use stable operation identity derived from object UID plus generation and operation kind;
6. execute one conditional/idempotent mutation;
7. record status/condition with observed generation;
8. requeue based on classified state and rate budget.

Pod local files are not durable state. Multiple controller replicas need leader election or state-owner conditional transitions. A stale leader needs fencing. Kubernetes workqueue requeues and SDK retries must be counted with API retries. Use least-privilege Role-Based Access Control (RBAC), separate namespaces/tenants, NetworkPolicy where enforced, and secret references rather than loggable values.

### Internal developer platform

A platform API often acts with stronger authority than its users. Preserve caller identity or a trusted delegation chain for audit; do not become a confused deputy. Normalize repository, environment, tenant, and cluster identity before authorization. Restrict callback URLs and artifact sources. Bind an approval to canonical intent, not a mutable branch name.

Expose asynchronous operations explicitly:

```http
POST /v1/releases -> 202 Accepted
Location: /v1/operations/release-417

GET /v1/operations/release-417
-> pending | committed | rejected | failed | unknown-needs-reconciliation
```

Do not report `completed` merely because a queue accepted work. Include observed resource version and verification state. Keep problem types stable and redact tenant-sensitive detail.

### Private-cloud virtualization API

Virtual machine, network, and storage operations may take minutes and cross several state owners. A client timeout is especially likely. Use provider task IDs, conditional resource versions, stable request identity, and long-lived reconciliation records. Understand whether delete is asynchronous, whether names can be reused, and whether a failed task left volumes, IP allocations, or partial metadata.

Recovery must inventory dependencies before compensation. Deleting a duplicate-looking virtual machine can detach the wrong volume or erase forensic evidence. Scope by immutable IDs and ownership tags verified at the authoritative API, never by a name pattern alone.

### SDK adoption checklist

Before accepting an SDK:

- identify generated and runtime versions;
- inspect default connect/read/overall timeouts;
- inspect automatic retry methods, statuses, attempt cap, backoff, and idempotency behavior;
- test unknown response fields and enum values;
- test null versus missing and large numeric values;
- inspect authentication refresh and token logging;
- set user agent/client version and correlation without personal data;
- bound response bodies and pagination;
- expose raw status/headers safely when error translation loses evidence;
- test cancellation and timeout after committed effect;
- wrap it behind a narrow adapter so generated types do not leak across the codebase.

### Contract evolution workflow

```text
proposed description change
  -> syntax and reference validation
  -> semantic compatibility diff
  -> provider behavior tests
  -> supported consumer contract tests
  -> generated SDK diff and review
  -> old-client/new-server and new-client/old-server matrix
  -> shadow/canary traffic
  -> error/retry/duplicate/unknown guardrails
  -> staged rollout
  -> deprecation telemetry and removal review
```

A compatibility diff is a warning system, not proof. Human review asks whether defaults, business rules, ordering, authorization, problem types, and timing changed.

## Reliability, security, observability, capacity, and cost

### Reliability

Define service-level indicators (SLIs) around logical operations, not only attempts:

- verified successful logical operations / eligible logical operations;
- time from accepted intent to verified user outcome;
- oldest unknown operation age;
- duplicate effects per logical operation;
- missing/invalid receipt count;
- pagination traversal gap/duplicate rate for declared snapshots;
- webhook effects per unique event;
- validation rejects by bounded contract code;
- attempt amplification = attempts / logical operations.

An HTTP availability SLI can remain green while reconciliation is stuck. Pair protocol indicators with user journey and state correctness.

Retries consume the error budget indirectly by increasing load and recovery time. Allocate a fleet retry budget. When exhausted, shed, queue, or fail fast according to product priority. Protect reconciliation and health/read traffic from retry storms.

### Security

Threat-model each boundary:

| Boundary | Threat | Control |
|---|---|---|
| body parsing | oversized/deep input, duplicate keys, numeric edge | byte/depth/item limits, strict parser policy, runtime schema |
| identity | stolen/wrong-audience token | TLS, issuer/audience/expiry checks, short lifetime, rotation |
| authorization | cross-tenant or confused deputy | normalized target, least privilege, state-owner policy |
| idempotency store | cross-user collision/data leak | caller scope, opaque random key, access control, minimal receipt |
| errors/logs | secrets or personal data | allowlisted fields, bounded body, redaction tests, retention |
| callback/webhook | spoof, replay, server-side request forgery | destination allowlist, signature, freshness, event claim, egress controls |
| schema/version | parser or client downgrade | supported-version allowlist, explicit negotiation, rollout gates |
| SDK/supply chain | generated/runtime compromise | pin, provenance, review, scan, minimal dependency |

Never log `Authorization`, cookies, private keys, full signed URLs, client secrets, or arbitrary bodies. Idempotency keys can become sensitive correlation identifiers. Put high-cardinality IDs in access-controlled logs/traces with retention policy, not metric labels.

Problem responses should be useful without revealing stack traces, SQL, internal hosts, policy internals, or existence of protected resources. Keep detailed cause in secured telemetry linked by a safe correlation ID.

### Observability

Use structured events with a stable schema:

```text
logical_operation_id  high-cardinality, controlled logs/traces
attempt_id            one per transmission
client/server version bounded dimension
route/method          templated route, not raw URL
outcome_class         accepted/rejected/conflict/rate_limited/unknown/committed
problem_code          allowlisted bounded value
attempt_number        numeric field
elapsed_ms            histogram
request_bytes         histogram
response_bytes        histogram
retry_delay_ms        histogram
reconciliation_age_s gauge/histogram
```

Avoid tenant, resource ID, idempotency key, error message, or URL as unbounded metric labels. Trace propagation helps correlate components but is not authorization. Sample success traces if needed, retain error/unknown traces within privacy policy, and ensure sampling does not erase rare duplicate evidence.

Log both decision and proof limit: `outcome=unknown reason=deadline-after-send next=reconcile`. This is more actionable than `request failed`.

### Capacity

Capacity begins with units:

- logical operations per second;
- attempts per logical operation;
- request and response bytes;
- mean, p95, p99 residence time in seconds;
- concurrent connections/streams;
- parser CPU and memory per in-flight body;
- database transactions and idempotency records per second;
- page scan rate and page size;
- webhook event and redelivery rates;
- retention bytes for receipts, cursors, and replay cache.

Example:

```text
logical rate               240 operations/s
measured amplification     1.25 attempts/operation
attempt rate               300 attempts/s
mean residence             0.20 s
estimated average in-flight 300/s x 0.20 s = 60
p99 residence              1.80 s
mean request body          4 KiB
```

The average in-flight estimate does not size tail bursts. Load test realistic body distributions, slow dependencies, 429, timeouts after commit, page mutation, and webhook redelivery. Bound request body before buffering. Stream only when the parser and signature policy can remain safe.

Idempotency storage can be substantial. At 240 operations/s for 24 hours:

```text
records = 240 x 86,400 = 20,736,000 records/day
```

At 500 bytes of logical record payload, that is about 10.37 GB/day before indexes, replication, storage overhead, and backups. Measure real bytes and choose retention from retry/reconciliation requirements, privacy, and cost—not arbitrary deletion.

### Cost

Attempts cost gateway CPU, TLS, service CPU, database transactions, logs, traces, and egress. A fivefold retry amplification can make cost rise while useful throughput falls. High-cardinality logs and full bodies can dominate observability cost and create security risk.

Optimize after correctness boundaries exist:

1. prevent invalid requests client-side but retain server validation;
2. control retry amplification and concurrency;
3. choose bounded page sizes and fields;
4. compress only where CPU/latency/security tradeoffs are measured;
5. sample safe success telemetry while retaining correctness signals;
6. expire idempotency/replay records only after the documented horizon;
7. cache safe GET representations with correct validators and authorization scope.

A cheaper but ambiguous API is expensive during incidents. Durable operation identity and precise problem codes usually save more than they cost.

## Traps and prevention

### Trap 1: "It is valid JSON, so the request is valid"

JSON grammar proves only that a parser can construct JSON values. The endpoint still needs shape, exact types, ranges, formats, business invariants, current-state constraints, and authorization.

**Prevention:** validate in layers; return stable problem classes; test valid-wrong-type, missing, null, unknown, duplicate-name, large numeric, Unicode, depth, and size cases.

### Trap 2: silently coercing types

Turning `"3"` into `3` appears convenient. It creates an undocumented union of representations and unclear behavior for `" 3 "`, `"3.0"`, `"+3"`, `true`, huge values, and locale-specific text.

**Prevention:** publish one representation, reject ambiguity, correct producers, and add consumer/provider contract tests. If compatibility requires coercion, specify it precisely, instrument it, deprecate it, and keep server authorization unchanged.

### Trap 3: confusing Content-Type and Accept

`Content-Type` labels the body that accompanies its message. `Accept` describes response types a requester can consume. Copying `Accept` into response `Content-Type` without server selection or parsing JSON despite `text/plain` creates inconsistent intermediaries and clients.

**Prevention:** explicit supported media-type tables, integration tests through the gateway, 415/406 cases, response-parser checks, and `Vary`/caching review where negotiation affects cache keys.

### Trap 4: using a timeout as proof of failure

A timeout says a deadline elapsed before a complete observation. The server may have committed. Retrying a mutation under a new identity creates another logical operation.

**Prevention:** persist intent, use stable operation/idempotency identity, store outcome atomically, expose lookup, classify unknown, reconcile before replay, and test timeout after commit.

### Trap 5: believing "POST is non-idempotent" ends the design

HTTP does not define POST as idempotent, but a product can define application-level idempotency. Conversely, calling PUT does not guarantee a buggy service or downstream notification is effectively idempotent.

**Prevention:** state the effect invariant, identity scope, intent binding, storage, concurrency, retention, response replay, and downstream boundaries for the exact operation.

### Trap 6: new idempotency key per retry

This tells the server that every attempt is a new operation. Deduplication cannot correlate them.

**Prevention:** create the key once when durable logical intent is created; persist it; reuse it across client/process/controller retries; reject same key with different intent; expose it safely for reconciliation.

### Trap 7: stacking invisible retries

The SDK retries twice, a service mesh retries twice, a queue redelivers, a CI job retries, and an operator reruns the pipeline. Attempt multiplication becomes nonlinear and state semantics disappear.

**Prevention:** inventory every retry owner, choose one primary owner per boundary, propagate remaining deadline, cap attempts, use backoff/jitter and a fleet budget, expose attempt numbers, and disable unsafe intermediary retries for mutations.

### Trap 8: using offset pagination for mutable inventory

Offset describes a position in the collection as it exists when each query runs. Inserts and deletes move positions. Sorting only by a non-unique timestamp also lets ties reorder.

**Prevention:** stable total order with immutable tie-breaker; opaque cursor; documented snapshot/high-water semantics; bounded page size; seen-ID or authoritative reconciliation; tests with concurrent insert/update/delete.

### Trap 9: decoding opaque cursors

Clients see Base64-like text and parse it to change offsets or timestamps. The server later changes encoding or the client bypasses authorization/filter binding.

**Prevention:** store and replay cursors unchanged, never expose cursor internals as a client contract, protect integrity/confidentiality as needed, scope to caller/filter, expire explicitly, and give a restart path.

### Trap 10: signature means fresh and exactly once

A correctly signed old event remains correctly signed. Network loss causes provider redelivery. Two receiver replicas can race before either records completion.

**Prevention:** verify exact raw bytes/components and accepted key/algorithm, enforce timestamp window, atomically claim durable event ID, make effect idempotent, store receipt, and test concurrent/replayed/stale delivery.

### Trap 11: logging the body to debug

Bodies and headers can contain tokens, personal data, signed URLs, infrastructure details, and attacker-controlled text. Problem detail can echo input. Full logging also increases cost and retention obligations.

**Prevention:** safe-field allowlist, lengths/types/digests instead of values, correlation IDs, bounded excerpts only under approved policy, structured redaction before formatting, sentinel-secret tests, access controls, and retention limits.

### Trap 12: generated SDK equals compatibility

Generation makes code from one description snapshot. It does not guarantee runtime validation, server behavior, error mapping, retries, timeout semantics, unknown enums, or old-client compatibility.

**Prevention:** review generator/runtime diffs; wrap SDK; pin versions; run wire fixtures, old/new matrices, consumer/provider contracts, failure tests, and canary telemetry.

### Trap 13: additive means non-breaking

An optional field breaks strict consumers. A new enum value breaks exhaustive logic. A new default changes behavior. A response can grow beyond gateway/client limits. A new error type can become falsely retryable.

**Prevention:** maintain supported consumer behavior tests, tolerant-reader policy where appropriate, bounded unknown-enum handling, response size budgets, explicit deprecation, shadow/canary, and client-version telemetry.

### Trap 14: 429 means "sleep and try again"

Thousands of replicas may wake together. `Retry-After` can exceed the user's deadline. The same work may also be queued elsewhere. Sleeping workers retain memory and connections.

**Prevention:** one retry owner, parse documented guidance, use remaining monotonic deadline, compatible jitter, queue/backpressure, per-tenant fairness, attempt/fleet budgets, and load shedding. Verify whether the limited attempt could mutate under the provider contract.

### Trap 15: 2xx means the user is done

A 202 means accepted, a 201 may create an object whose controller later fails, and a 200 can contain stale or semantically wrong data.

**Prevention:** define the response boundary, expose operation/resource identity, poll or observe authoritative state, verify downstream/user journey, and measure verified completion separately from 2xx.

### Trap 16: retrying conflict without re-planning

A 409 or 412 is evidence that assumptions about current state are stale or incompatible. Automatically fetching a new ETag and repeating the same overwrite destroys concurrent changes.

**Prevention:** fetch current version, show semantic difference, recompute a pure plan, re-authorize and reapprove if intent changed, then submit one conditional update.

### Trap 17: treating local mocks as distributed proof

Mocks can confirm classification logic but cannot prove gateway buffering, TLS identity, database atomicity, provider retention, clock behavior, or controller concurrency.

**Prevention:** keep a test-evidence ladder: pure model, black-box client, provider contract fixture, controlled integration, deployed canary, production SLI. State what each proves and cannot prove.

## Memory card and retrieval

### Ten sentences to keep

1. Characters become bytes; bytes do not carry meaning without an encoding and media-type contract.
2. Valid JSON is not valid schema, valid business intent, or authorization.
3. `Content-Type` describes this body; `Accept` describes response representations the client accepts.
4. One user operation can have many attempts, but it must keep one durable identity.
5. A mutation timeout is unknown until the authoritative owner proves committed or absent.
6. An idempotency key must be stable, scoped, bound to intent, stored atomically, and retained long enough.
7. A cursor is only as consistent as its documented ordering and snapshot/high-water semantics.
8. A 429 retry needs remaining deadline, backoff, jitter, concurrency control, and a fleet budget.
9. A webhook signature proves neither freshness nor once-only effect.
10. A 2xx response is an attempt result; verify the resource and user operation.

### Thirty-second incident card

```text
Impact:      which logical operations/users, not merely attempts?
Versions:    client, SDK, schema/OpenAPI, gateway, service?
Wire:        method, route, media types, byte/type/size facts?
Identity:    principal, tenant, operation key, intent fingerprint?
Outcome:     rejected, conflict, rate-limited, committed, absent, unknown?
Owner:       which system can prove the effect and resource version?
Amplifier:   attempts/op, concurrency, queue age, retry owners?
Action:      scope, budget, abort, rollback/compensation, approval?
Proof:       original operation, duplicates, omissions, user journey?
```

### Retrieval practice

Close the chapter and answer without looking:

- Why can four characters require five bytes?
- Why is JSON number `3` different from JSON string `"3"`?
- What is the difference between OpenAPI and JSON Schema?
- Which header describes request bytes, and which constrains the response?
- Why might 422 be safer than coercion and retry?
- When does a client create the idempotency key, and when may it change?
- What must happen after a timeout that followed request transmission?
- Why can an opaque cursor still produce inconsistent pages?
- What three independent controls make webhook replay safer?
- Why does a valid SDK type not prove server authorization?
- How do four retries transform 240 logical operations/s?
- What does the offline verifier prove and not prove?

If an answer is vague, return to the relevant owner and diagram. Do not memorize status-code trivia without the state transition behind it.

## Complete answers

### Question 1: What is the difference between text, bytes, JSON, and a schema?

**Direct answer:** Text is a sequence of characters. An encoding such as UTF-8 maps those characters to bytes. JSON defines a grammar and a small set of value categories represented by text. A schema constrains which JSON values are allowed for one interface.

**Foundation:** The network carries bytes, not Python objects. The receiver uses metadata and a decoder to reconstruct text, then a JSON parser to produce object/array/string/number/Boolean/null values. A payload can decode and parse but still fail because a required field is missing, `replicas` is a string, or the number is outside policy. Business and authorization checks come after shape/type validation.

**Senior answer:** I treat each as a separate trust boundary with separate evidence and limits: bounded body bytes plus declared media type; strict decoding; parser limits and duplicate-key policy; dialect/versioned schema evaluation; normalization to an immutable domain model; current-state invariants; principal/action/resource authorization; and atomic state-owner enforcement. I never sign a reserialized representation unless canonicalization is part of the protocol, and I test Unicode, numeric range, null/missing, unknown fields, and cross-language round trips.

### Question 2: Is YAML just easier JSON?

**Direct answer:** No. YAML is a richer language with comments, anchors, tags, scalar styles, and version/library-dependent typing. Some JSON documents are valid YAML, but operational behavior cannot be assumed identical.

Use safe loaders, reject or bound aliases, duplicates, depth and size, pin supported behavior, and normalize into typed internal values. Do not let tags construct arbitrary objects. A CI or Kubernetes YAML document also has an application schema after YAML parsing. Quoting can change types; a visually simple value may not mean what a different loader infers.

### Question 3: OpenAPI or JSON Schema—which one validates my API?

**Direct answer:** JSON Schema describes JSON instance constraints. OpenAPI describes HTTP operations and incorporates schema objects for parameters, bodies, and responses. Neither validates runtime traffic unless a component implements and enforces it.

Use OpenAPI for the operation surface: method, path, parameters, media types, responses, and security declarations. Use its declared schema dialect consistently and understand supported JSON Schema vocabularies. Validate at provider boundaries, generate clients carefully, and test actual wire behavior. A gateway check may not enforce business rules or authorization; the state-owning service still must.

### Question 4: What should a client do with an HTTP error?

**Direct answer:** Classify it according to the documented contract, preserve safe evidence, and choose correct/re-authorize/re-plan/wait/reconcile/abort—not generic retry.

A 415 or 422 usually needs producer correction. A 401 may invoke one bounded credential refresh path; 403 needs authorization repair. A 409/412 needs current-state read and re-plan. A 429 may be delayed within deadline and budgets. A 5xx or connection loss around mutation can be unknown. Parse known problem types/codes but tolerate unknown ones safely. Always verify whether the state owner could have acted.

### Question 5: What exactly makes an idempotency key safe?

**Direct answer:** It is created once per logical operation, stable across attempts, scoped to an authenticated caller/tenant, bound to one canonical intent, atomically stored with outcome, concurrently enforced, and retained across the full retry/reconciliation horizon.

A random UUID alone is insufficient. If clients generate a new UUID for retry, there is no dedupe. If the service stores key after effect, a crash can duplicate. If the key is not bound to intent, accidental reuse can return the wrong outcome. If retention is too short, delayed replay becomes a new operation. If keys are globally visible, they can leak another caller's result. Test same-key/same-intent, same-key/different-intent, concurrent attempts, timeout after commit, store failure, and expiry.

### Question 6: What do I do after a POST timeout?

**Direct answer:** Mark the outcome unknown, persist the original operation/key, query the authoritative owner, and do not send another mutation until the owner reports committed or proves absence under the documented contract.

If committed, store/read back the receipt and verify the user operation. If proven absent and failure is transient, retry with the same logical identity within remaining deadline, attempt cap, backoff/jitter, and fleet budget. If still unknown, stop and escalate. Increasing timeout may change frequency but cannot resolve an operation that already crossed the commit boundary.

### Question 7: How should pagination work while records change?

**Direct answer:** The API must define stable total ordering, cursor/filter/auth scope, and whether traversal is snapshot, high-water, or live. The client treats cursor as opaque and verifies identities across pages.

Offset alone is position-based and drifts under insert/delete. Cursor alone is not magic: if it only contains the last timestamp and timestamps tie or rows update, gaps can remain. Use an immutable unique tie-breaker. For an inventory export that must be complete at one point, use snapshot/version semantics or read from an append-only log with a high-water mark. Define cursor expiry and restart. Bound page size and client memory. Test mutation between every page.

### Question 8: How should 429 be handled?

**Direct answer:** Apply backpressure. Parse documented `Retry-After`, compare it with the remaining operation deadline, add policy-compatible jitter, cap attempts and concurrency, enforce a fleet retry budget, and preserve fairness.

Do not let each SDK, proxy, job, and operator retry independently. Measure logical rate, attempt rate, amplification, in-flight, queue age, 429, and useful throughput. A rate-limited mutation is known no-effect only if the API contract guarantees rejection before effect. Otherwise reconcile. If waiting would exceed the user deadline, return a classified result or durably queue under the product contract.

### Question 9: How do I evolve an API without breaking clients?

**Direct answer:** Define the support window and compatibility rules, test provider behavior against supported consumer expectations, stage the change, observe client versions and contract errors, and deprecate before removal.

Check more than required fields. Unknown fields, new enums, nullability, defaults, numeric ranges, ordering, pagination, media type, problem types, auth scopes, limits, and timing can break. Run old-client/new-server and new-client/old-server tests where both are supported. Review generated SDK diffs. Shadow or canary traffic with validation/retry/duplicate/unknown guardrails. Rollback stops new exposure but accepted operations still require reconciliation.

### Question 10: How do I secure webhooks?

**Direct answer:** Use TLS, preserve exact raw input, verify the provider's required signed components with an accepted key/algorithm, enforce freshness, atomically deduplicate a durable event ID, authorize and validate the effect, store its receipt, and acknowledge according to provider semantics.

Never compare a signature with ordinary string equality when a vetted library provides constant-time verification. Do not parse then reserialize before verification unless the scheme specifies that transformation. Rotate keys with overlap and key IDs. Restrict body size and content type. Protect against server-side request forgery in any callback/fetch behavior. Redelivery is normal; design it to produce zero second effects.

### Question 11: How should observability represent API retries?

**Direct answer:** Emit one logical-operation identity and one attempt identity per transmission, with bounded outcome class, attempt number, remaining deadline, latency, safe problem code, and reconciliation state.

Metrics count logical operations and attempts separately. Track attempts per operation, oldest unknown, duplicate effects, missing receipts, 429, queue age, and verified completion. Do not put operation IDs, tenant IDs, URLs, or errors into metric labels. Controlled logs/traces may carry correlation under access and retention policy. Redaction occurs before formatting, and tests inject sentinel secrets through every error path.

### Question 12: What should API contract testing include?

**Direct answer:** Test syntax, runtime types, operation semantics, errors, compatibility, concurrency, failure timing, and verified state—not just a happy JSON fixture.

Include malformed bytes/JSON, duplicate keys, depth/size, missing/null/empty, wrong types, bounds, unknown fields/enums, media negotiation, every documented status/problem type, authentication and authorization separation, same/different idempotency intents, concurrent same key, timeout before and after commit, conditional conflict, pagination under writes, 429 and retry budget, webhook stale/replay/concurrency, secret redaction, SDK old/new matrices, and user readback. State which tests use mocks, controlled integration, or deployed canaries.

### Question 13: What does success mean for an asynchronous API?

A 202 response means the server accepted the request for processing; it does not promise completion. The response should identify an operation resource or other documented observation path. The client persists that identity, follows state transitions, handles terminal failure/unknown, and verifies the created resource and user journey. SLOs should measure accepted-to-verified latency and stuck operation age, not only 202 rate.

### Question 14: When should I use ETag and If-Match?

Use a conditional update when lost updates matter and the provider exposes a validator with appropriate semantics. Read resource and validator, calculate desired change, send `If-Match`, and handle 412 by re-reading and re-planning. Do not turn it into an automatic overwrite loop. Idempotency and conditional updates solve different problems: idempotency deduplicates one logical operation; a precondition protects the resource version it acts upon. Many robust mutations need both.

## Product-company interview

### Interview prompt

"Design a multi-tenant platform API that lets CI and Kubernetes controllers create deployment releases across private and public infrastructure. It must support 10,000 tenants, asynchronous operations, SDKs in several languages, webhook notifications, safe retries, API evolution, and incident recovery. Explain request/response contracts, state ownership, security, idempotency, pagination, rate limiting, observability, capacity, testing, rollout, and what happens when a client times out after a commit."

### Strong answer shape

I would begin with the user contract, not a framework. One authorized caller submits one release intent for a normalized tenant/service/environment and receives a durable logical operation ID. The API validates the supported media type and version, parses bounded UTF-8 JSON with defined duplicate/numeric rules, evaluates a versioned runtime schema, normalizes an immutable domain model, checks quota/business invariants, and authorizes principal/action/resource. Gateway authentication is not enough; the service and state owner enforce tenant boundaries.

For asynchronous creation, `POST /v1/releases` returns 202 with an operation location after durable acceptance, or 201 only when the resource creation contract is actually complete. Every mutation carries an idempotency key created once by the caller. The service scopes it to authenticated tenant/caller, binds it to a canonical non-secret intent fingerprint and contract version, and atomically stores the operation outcome with the resource transition when possible. Same key/same intent returns the same operation; same key/different intent is a conflict. Pending state uses leases/fencing and reconciliation so stale workers cannot commit over a new owner.

A client applies one monotonic overall deadline across DNS, connect, TLS, upload, processing, and response. If a deadline expires after send, it records unknown and queries the operation by the same identity. Committed means persist receipt and verify; proven absence plus transient classification can retry the same key within cap/budget; still unknown stops. SDK, mesh, queue, controller, CI job, and operator retries are inventoried, with one owner and a fleet retry budget.

Updates use resource versions/ETag and `If-Match` so a stale client receives 412 and must re-plan. Error responses use documented status plus bounded `application/problem+json` types/codes. English detail is not machine logic and is sanitized. Authentication uses short-lived audience-specific workload credentials. Authorization is least privilege and tied to normalized resources. Secrets never enter bodies, idempotency fingerprints, metrics, or generic logs.

Collection APIs use a stable immutable sort key plus unique tie-breaker and server-issued opaque cursor scoped to tenant, filter, order, and expiry. Inventory exports needing completeness use a snapshot or high-water contract. Page size is bounded; clients stream and checkpoint cursors. Counts declare whether exact and snapshot-scoped.

Rate limits exist per tenant, caller, route, and protected dependency. The API returns 429 with safe guidance. Clients use bounded admission queues, per-tenant fairness, concurrency caps, remaining deadline, backoff/jitter, attempt caps, and global retry budgets. Critical reconciliation reads are protected from mutation storms. Capacity models logical operations, amplification, byte sizes, service-time distribution, in-flight, database transactions, idempotency/replay retention, page scans, webhook redeliveries, and telemetry cost.

Webhooks are at least once. The receiver verifies the exact raw signed components and accepted key/algorithm, checks timestamp freshness, atomically claims tenant plus event ID, validates and authorizes the event, applies an idempotent effect/outbox, records a receipt, and acknowledges. Redelivery returns acceptance with no second effect. Key rotation, clock skew, body limits, replay retention, and destination restrictions are tested.

Observability distinguishes logical operations from attempts. Metrics use templated route, client version, status/outcome class, problem code, and histograms for request bytes, elapsed time, queue age, and reconciliation age. High-cardinality operation IDs live in secured logs/traces. Key SLIs are verified success, accepted-to-ready latency, oldest unknown, duplicates, missing receipts, amplification, validation rejects, pagination gaps, and webhook effects per unique event.

OpenAPI describes operations and schemas, while runtime validation and business/authorization rules remain service responsibilities. Compatibility gates include semantic description diff, provider tests, supported consumer contracts, generated SDK review, old/new matrices, unknown-field/enum/null/number tests, shadow mode, and canary. Deprecation uses client-version telemetry and a published support window.

Testing layers include pure validation/state-machine tests; executable client tests; provider fixtures; controlled database/gateway integration; concurrency on the same key; timeout before/after commit; store/outbox failure; 429 storms; page mutation; webhook stale/replay; secret sentinels; and end-to-end release readiness. Load tests inject slow/failing dependencies and realistic distributions.

Rollout starts with documentation and compatible readers, then shadow validation, internal tenants, low concurrency canary, and staged expansion. Abort thresholds cover validation rejects, 429, p99, amplification, unknown age, duplicate/missing receipts, and user success. Rollback stops new traffic but cannot uncommit accepted operations, so every rollback includes an operation inventory and reconciliation plan.

During an incident I freeze blind replay, preserve versions and logical identities, quantify affected user operations, classify each at the authoritative owner, cap load, repair receipts for committed work, retry only proven absent work with the same identity, compensate duplicates only with product approval, backfill audit through snapshot/high-water traversal, and verify each user operation plus duplicates and downstream effects. Root cause names the first violated contract; "the API timed out" is only a symptom.

### Weak answer

"Use REST with JSON, FastAPI, Kubernetes, Redis locks, three retries, and an API gateway. Scale pods when latency rises. Version the URL and generate SDKs from Swagger. Sign webhooks and store request IDs."

Why it is weak: it lists tools without defining contracts. "Request ID" does not state stable logical identity or intent binding. Redis lock scope, fencing, failure, and state ownership are absent. Three retries may duplicate or amplify. Scaling does not repair ambiguous commits, pagination, authz, or replay. URL versioning and generated SDKs do not prove compatibility. Signature-only webhooks replay. No capacity units, evidence, recovery, verification, test matrix, or accepted-work rollback exists.

### Follow-up questions and answers

**What if the downstream provider has no idempotency key or operation lookup?**

Then the client cannot safely guarantee automatic replay after an unknown mutation. Look for a unique conditional state predicate or provider resource identity that proves effect, serialize through a state owner able to deduplicate, redesign the integration, or require human reconciliation. Say the limitation plainly instead of marketing "exactly once."

**Can you derive operation identity from tenant plus payload hash?**

Sometimes a domain has a natural unique command, but identical payloads may be legitimate separate operations and serialization is not automatically canonical. Use an explicit client logical ID; store authenticated scope and a versioned non-secret intent fingerprint to detect mismatch. Never expose a raw secret through low-entropy hashing.

**How do you prevent hot tenants from consuming the fleet?**

Use admission control, per-tenant queues/token buckets or weighted fairness, global dependency caps, bounded work per reconciliation, and separate capacity for control/recovery reads. Measure queue age and verified outcomes per service class without leaking tenant IDs into metric labels. Apply quotas and backpressure before memory/connection exhaustion.

**What if the database commit succeeds but publishing the event fails?**

Use a transactional outbox stored with the domain commit. A separate publisher sends unsent records with stable event IDs; duplicate delivery is expected and consumers deduplicate. If the database and broker cannot share a transaction, the outbox plus reconciliation makes the gap explicit rather than pretending a dual write is atomic.

**Why are authentication and authorization separate in the design?**

Authentication tells who the principal is under a credential contract. Authorization evaluates whether that principal may perform this action on this normalized resource now. A valid platform service token may still lack tenant permission, and an overly powerful intermediary can become a confused deputy.

**How do you handle an enum value a new server sends to an old client?**

If forward compatibility is required, clients preserve or map unknown values to an explicit `unknown` branch while retaining raw safe value for diagnosis; they do not crash or silently choose a dangerous default. Test it before rollout. If consumers cannot tolerate unknown values, adding one is breaking and needs version/migration.

**Would you retry GET automatically?**

Only within an overall deadline and budget, after considering authentication, rate limit, response size, stale/cache semantics, and load. HTTP defines GET as safe/idempotent in intent, but automatic fleet retries can still cause overload, billing, or inconsistent snapshots. A retry is an operational policy, not a method-name reflex.

**How do you prove pagination completeness for 100 million objects?**

Use a state-owner snapshot or append-only high-water boundary, stable ordered partitioning, durable cursor checkpoints, per-partition counts/digests where supported, bounded duplicate tracking, and reconciliation against an authoritative manifest/log. Do not keep all IDs in one process. Record snapshot identity and rerun only failed partitions.

**What makes this an SRE answer rather than an API developer answer?**

It connects interface design to failure semantics, state ownership, overload control, measurable user outcomes, safe incident actions, rollback/compensation, and evidence limits. Reliability is not just correct request parsing; it is recoverable behavior under partial failure and change.

## Independent transfer and rubric

Complete ASM-0048 with the independent lab case. The assessment JSON contains deliverables and evidence requirements but no answer fields. The response template is deliberately blank. Store your response outside the guarded lab directory.

### Required sequence

1. Record Ubuntu/WSL, Bash, Python, UID, physical path, local changes, network boundary, and abort conditions.
2. Run clean preflight, setup, and baseline.
3. Inject `independent` and capture raw `scenario` output.
4. Confirm the raw scenario lacks derived outcome, receipt, diagnosis, recovery, duplicate, retry decision, and answer key.
5. Write a timestamped prediction and at least three competing hypotheses before any observation.
6. Draw the bytes-to-user-outcome ownership path with a text alternative.
7. Request the minimum evidence views needed to disconfirm hypotheses.
8. Build the chronological evidence ledger and contract table.
9. Design the idempotency/retry state machine and capacity calculation.
10. Write an authorized bounded recovery card with abort, rollback/compensation, and verification.
11. Run recovery, verify the original modeled operation and duplicate count, then prove cleanup.
12. Transfer the design to one real integration without claiming the model tested it.

### Reviewer rubric

| Area | Strong evidence | Points |
|---|---|---:|
| independent prediction | raw inputs first, competing outcomes, discriminating observations, fact/inference/unknown labels | 10 |
| contract depth | bytes, Unicode, JSON, schema, media, version, problems, authn/authz, outcome separated | 10 |
| idempotency/failure semantics | stable identity, intent binding, unknown reconciliation, conditional bounded retry | 10 |
| recovery/verification/safety | exact scope, authorization, budget, abort, compensation, refusal and cleanup, user proof | 10 |
| production transfer | identity, TLS/network, durable state, controller, webhook, capacity, observability, compatibility, rollout | 10 |

Maximum score is 50. Verifier success awards zero rubric points by itself. A human reviewer must evaluate original reasoning and evidence. Publication and a high score on one attempt do not establish durable mastery.

### Mastery signals

A strong learner:

- says "unknown" after ambiguous mutation instead of inventing failure;
- distinguishes one operation from many attempts;
- explains why valid JSON can be invalid input;
- uses one stable scoped idempotency key bound to intent;
- identifies the authoritative state owner and queries it;
- treats pagination as a consistency contract;
- controls retry amplification with units and fleet policy;
- separates webhook integrity, freshness, authorization, and dedupe;
- gives evidence proof limits without weakening action;
- scopes recovery and verifies the original user operation;
- knows exactly what the offline lab cannot prove.

## References and review

This lesson uses the eight registered primary standards below. The chapter paraphrases them and applies them to operational engineering; it does not reproduce long source passages.

| Reference | Primary use |
|---|---|
| REF-0121, RFC 8259 | JSON grammar/value categories, Unicode interoperability, numeric and object-name cautions |
| REF-0122, RFC 9110 | HTTP methods, statuses, representations, content negotiation, validators, conditional requests |
| REF-0123, OpenAPI 3.1.1 | operation, parameter, request/response, component, and security description |
| REF-0124, JSON Schema 2020-12 Core | dialect/vocabulary/schema/reference concepts and evaluation architecture |
| REF-0125, RFC 9457 | problem-details representation and safe machine-classifiable errors |
| REF-0126, RFC 6585 | 429 rate limiting, Retry-After context, and 428 precondition requirement |
| REF-0127, RFC 9421 | HTTP message-signature components, parameters, keys, and verification boundary |
| REF-0128, RFC 8288 | typed Web links and `next` relation framing for navigation |

### Review boundaries

- Last reviewed: 2026-08-02.
- Review after: 2027-02-02.
- At review time, recheck RFC errata/status, OpenAPI 3.1.1 and JSON Schema dialect guidance, Ubuntu Python behavior, and every lab refusal/cleanup path.
- Re-run JSON/schema validation, exact 18-heading validation, Bash syntax, Python compilation, ShellCheck, normal-user guided and independent lifecycle, root refusal, answer-isolation scan, tamper/symlink/orphan tests, final state absence, privacy/name scan, encoding scan, and generated-residue scan after any change.
- For a real provider, verify current authentication, authorization, API/version support, SDK retry defaults, idempotency retention, pagination guarantee, rate policy, webhook scheme, service limits, pricing, and deprecation notice in primary documentation before action.

### Final perspective

The strongest platform engineer is not the person who memorizes every status code. It is the person who can take a vague "API failed" report, unfold it into byte, type, identity, state, time, and ownership boundaries, preserve one logical operation through ambiguity, control amplification, and prove the user's outcome without creating a second incident.

That skill survives languages, vendors, clouds, and AI-generated clients. The syntax will change. The discipline remains: define the contract, observe the right owner, say unknown when evidence is incomplete, recover inside a budget, and verify what the user was promised.
