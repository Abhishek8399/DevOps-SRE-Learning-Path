---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0016",
  "aliases": ["V02-L05", "tls-pki-mtls-rotation"],
  "curriculumIds": ["NET-006"],
  "slug": "tls-pki-mtls-rotation",
  "route": "/book/connectivity/tls-pki-mtls-rotation",
  "order": 5,
  "volume": "02-connectivity",
  "title": "TLS, PKI, mTLS, trust, and rotation: prove which identity boundary failed",
  "summary": "Build a durable mental model of TLS and X.509, trace SNI and ALPN through every termination leg, distinguish encryption from authentication and authorization, diagnose chain, name, time, purpose, policy, and mTLS failures, and rotate certificates or trust anchors without gambling on downtime.",
  "domain": "connectivity",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 480,
  "prerequisiteLessonIds": ["LES-0014", "LES-0015"],
  "prerequisiteCurriculumIds": ["NET-004", "NET-005"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "Host observations are read-only and run as a normal user. The required lab uses Bash and Python 3.8 or newer, deterministic public certificate metadata, a guarded UID-scoped directory under /tmp, no generated key, no real listener, no network traffic, no trust-store change, and no clock or crypto-policy mutation."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The offline lab is supported. Windows, WSL, browsers, JVMs, containers, and language runtimes can use different trust stores and clocks; evidence must name the exact verifier rather than assuming one machine has one trust decision."
    },
    {
      "platform": "Containers, Kubernetes, proxies, load balancers, private cloud, and public cloud",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Production transfer covers termination, re-encryption, secrets, CertificateSigningRequests, ingress, meshes, managed load balancers, private PKI, rotation, and ownership. The lesson creates no container, cluster, cloud resource, certificate, key, trust anchor, listener, or external connection."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "security-platform-engineer", "network-reliability-engineer", "cloud-infrastructure-engineer", "private-cloud-engineer"],
  "learningObjectives": [
    "Explain the security goals TLS provides, the metadata and endpoint risks it does not remove, and why a successful TLS handshake still does not prove application authorization or correctness.",
    "Trace a TLS 1.3 handshake through ClientHello, SNI, version and algorithm negotiation, key exchange, certificate authentication, Finished messages, ALPN, protected records, resumption, and application traffic.",
    "Decode X.509 leaf, intermediate, root, subject alternative name, issuer, subject, serial, validity, public key, signature, basic constraints, key usage, extended key usage, policies, and critical extensions.",
    "Separate peer-presented chain material, client path construction, configured trust anchors, service-identity matching, time, purpose, revocation policy, and application authorization into independently testable decisions.",
    "Model mTLS as two directional authentication decisions and map certificate identity into least-privilege authorization without treating every certificate from a trusted CA as equivalent.",
    "Locate TLS termination and re-encryption across applications, sidecars, ingress proxies, load balancers, Kubernetes, virtual machines, private cloud, and managed services with explicit owners and evidence points.",
    "Design and execute certificate renewal and CA rotation using inventory, trust-first ordering, overlap, canaries, reload evidence, rollback, fleet coverage, and removal proof.",
    "Diagnose handshake failures and latency using exact phase, alert, verifier, endpoint cohort, chain, identity, clock, policy, and application evidence while protecting private keys and preserving incident state."
  ],
  "productionSignals": [
    "TCP connects, but the client fails before any HTTP status with unknown CA, unable to get local issuer, bad certificate, expired, not yet valid, or hostname mismatch.",
    "A certificate works in a browser but fails in Java, Go, a container, a sidecar, WSL, or a minimal VM image.",
    "Only one load-balancer address, availability zone, proxy pod, or rollout cohort presents the old certificate or an incomplete chain.",
    "SNI selects the wrong virtual service or default certificate even though DNS and the destination port are correct.",
    "TLS succeeds, but ALPN selects an unexpected protocol or no application protocol, and the HTTP behavior differs.",
    "Server authentication works, but mTLS fails because the client certificate is absent, expired, issued by an untrusted CA, has the wrong purpose, or maps to denied authorization.",
    "A certificate or CA rotation reports successful deployment while old processes still use cached trust, old certificates, long-lived connections, or session state.",
    "Handshake CPU, latency, bytes, failure rate, or connection churn rises after an algorithm, chain-length, proxy, retry, or keepalive change."
  ],
  "diagrams": [
    {
      "id": "LES-0016-DIA-001",
      "title": "One user operation can cross several separately terminated TLS legs",
      "direction": "left-to-right",
      "boundaries": ["client reference identity", "DNS and TCP", "edge TLS terminator", "edge authorization and HTTP routing", "proxy-to-service TLS", "service identity and optional client identity", "application authorization", "dependency TLS leg", "business result"],
      "evidencePoints": ["requested name and SNI", "destination and connect result", "served certificate and negotiated policy", "principal and route", "new ClientHello and trust store", "server and client path results", "authorization decision", "dependency verifier and certificate", "correct response and side effect"],
      "textAlternative": "A client resolves a reference name and opens TCP to an edge that terminates TLS. The edge may create a separate TLS connection to a service, and the service may create another to a dependency. Each leg has its own client, server, SNI, certificates, trust stores, policies, clocks, owners, and failure signals."
    },
    {
      "id": "LES-0016-DIA-002",
      "title": "TLS 1.3 establishes shared keys and authenticates the transcript before application data",
      "direction": "top-to-bottom",
      "boundaries": ["ClientHello with supported versions, groups, key share, SNI, and ALPN", "ServerHello with selected version and key share", "encrypted handshake parameters", "server certificate and proof of private-key possession", "optional client certificate and proof", "Finished transcript authentication", "protected application records"],
      "evidencePoints": ["client offer", "server selection", "selected ALPN and certificate request", "chain and CertificateVerify", "client chain and CertificateVerify", "Finished verification", "application protocol outcome"],
      "textAlternative": "The client offers capabilities and an ephemeral key share. The server selects compatible parameters and proves its certificate key participated in the authenticated transcript. If requested, the client also presents and proves a certificate. Finished messages authenticate the handshake; only then does ordinary protected application data flow."
    },
    {
      "id": "LES-0016-DIA-003",
      "title": "The peer presents material; the verifier constructs and accepts or rejects a path",
      "direction": "hierarchical",
      "boundaries": ["reference identity chosen by client", "leaf certificate presented by server", "intermediate certificate material", "locally configured trust anchor", "time, purpose, constraints, algorithm, policy, and revocation inputs", "application authorization"],
      "evidencePoints": ["DNS-ID or IP-ID", "SAN, public key, issuer, validity, EKU", "CA subject, constraints, signature", "trust-store source and version", "validation error and clock", "mapped principal and decision"],
      "textAlternative": "The server sends a leaf and usually intermediates. The client uses that material plus its local trust anchors to build and validate a certification path, then separately matches the requested identity. A valid path authenticates an identity under policy; the application still decides what that identity may do."
    },
    {
      "id": "LES-0016-DIA-004",
      "title": "Trust-anchor rotation is an ordered compatibility migration",
      "direction": "left-to-right",
      "boundaries": ["inventory A credentials and verifiers", "distribute trust A plus B", "prove applications loaded dual trust", "canary B-signed credentials", "roll presentation and issuance", "stop A issuance and find stragglers", "canary removal of A trust", "B-only steady state"],
      "evidencePoints": ["fleet denominator and owners", "bundle digest or generation", "active B-path verification", "issuer and endpoint cohort", "user SLO and mTLS authorization", "maximum lifetime and offline clients", "deliberate A-only rejection", "old-key disposition and audit"],
      "textAlternative": "Verifiers must accept both old and new trust before presenters switch to new credentials. After new issuance and presentation reach all required systems and old credentials have disappeared, old trust is removed gradually. Rollback remains possible while overlap exists."
    },
    {
      "id": "LES-0016-DIA-005",
      "title": "mTLS contains two authentication directions and a separate authorization decision",
      "direction": "cyclic",
      "boundaries": ["client verifies server identity", "server requests client certificate", "client proves possession of client private key", "server validates client path and purpose", "server maps certificate identity to principal", "policy authorizes or denies operation"],
      "evidencePoints": ["server SAN and serverAuth", "acceptable issuer and signature algorithms", "client SAN or approved identity claim", "clientAuth and trust store", "mapping rule and normalized principal", "resource, action, reason, and audit event"],
      "textAlternative": "In mutual TLS, the client first authenticates the server. The server also validates the client's certificate and proof of key possession. That authenticated certificate identity must be mapped to a principal, after which an authorization policy independently allows or denies the requested action."
    }
  ],
  "commands": [
    {
      "id": "LES-0016-CMD-001",
      "question": "Which platform, identity, namespace, clock, OpenSSL build, and trust directories define this observation?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -sr; id; readlink /proc/self/ns/net; date -u --iso-8601=seconds; openssl version -a; openssl version -d",
      "runFrom": "The exact Ubuntu 24.04 or WSL Ubuntu shell used by the failing client",
      "expectedBranches": [
        {"when": "The platform, normal-user identity, UTC time, namespace, and OpenSSL details print", "meaning": "The verifier context and local wall clock are recorded.", "nextEvidence": "Identify the application's actual TLS library and trust store; OpenSSL may not be that application."},
        {"when": "A tool is absent, time is implausible, or the context differs", "meaning": "The lesson assumptions do not match this verifier.", "nextEvidence": "Preserve the difference; do not install, elevate, or change the clock during incident evidence collection."}
      ],
      "proves": "The displayed shell context, clock reading, and OpenSSL build at sample time.",
      "doesNotProve": "Which TLS library, crypto policy, clock source, trust store, or network namespace the affected application actually uses."
    },
    {
      "id": "LES-0016-CMD-002",
      "question": "What certificate material does one authorized endpoint present, and does strict verification accept it for the intended name?",
      "risk": "sampled-read-only",
      "command": ": \"${TLS_HOST:?set TLS_HOST to one approved DNS name without scheme or port}\"; case \"$TLS_HOST\" in ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*) printf '%s\\n' 'refusing: TLS_HOST must be one approved DNS name without scheme, path, port, whitespace, or shell metacharacters' >&2; exit 64;; esac; if [ \"${#TLS_HOST}\" -gt 253 ]; then printf '%s\\n' 'refusing: TLS_HOST exceeds the DNS name length boundary' >&2; exit 64; fi; openssl s_client -connect \"${TLS_HOST}:443\" -servername \"$TLS_HOST\" -verify_hostname \"$TLS_HOST\" -verify_return_error -showcerts -brief </dev/null",
      "runFrom": "Only from an approved client to an endpoint you own after exporting TLS_HOST as its reviewed DNS name; the syntax preflight cannot prove ownership or authorization, so record the resolved destination IP separately",
      "expectedBranches": [
        {"when": "Verification succeeds and negotiated parameters print", "meaning": "This OpenSSL verifier accepted a path and name for this sampled endpoint under its selected trust source.", "nextEvidence": "Verify the real application, every endpoint cohort, ALPN, mTLS if required, and the actual runtime trust context."},
        {"when": "Verification fails or the handshake ends", "meaning": "The exact error localizes a TLS phase or validation decision.", "nextEvidence": "Preserve all peer-sent certificates and separate path, name, time, purpose, algorithm, client-auth, and policy branches."}
      ],
      "proves": "One active TLS test from one client context to one endpoint with SNI, hostname checking, and fatal certificate verification requested.",
      "doesNotProve": "Fleet consistency, browser or JVM behavior, application authorization, endpoint ownership, revocation freshness, or business correctness."
    },
    {
      "id": "LES-0016-CMD-003",
      "question": "What public identity, validity, purpose, constraints, and fingerprints are encoded in a certificate file?",
      "risk": "read-only",
      "command": ": \"${PUBLIC_CERT_PATH:?set PUBLIC_CERT_PATH to one reviewed public-certificate file}\"; if [ ! -f \"$PUBLIC_CERT_PATH\" ] || [ ! -r \"$PUBLIC_CERT_PATH\" ] || [ -L \"$PUBLIC_CERT_PATH\" ]; then printf '%s\\n' 'refusing: PUBLIC_CERT_PATH must be one readable non-symlink regular file' >&2; exit 66; fi; openssl x509 -in \"$PUBLIC_CERT_PATH\" -noout -subject -issuer -serial -dates -fingerprint -sha256 -ext subjectAltName -ext basicConstraints -ext keyUsage -ext extendedKeyUsage",
      "runFrom": "A reviewed public certificate file only after exporting PUBLIC_CERT_PATH as its exact path; the preflight rejects missing, unreadable, non-regular, and symbolic-link paths, but you must still prove the file contains public certificate material rather than a private key",
      "expectedBranches": [
        {"when": "The certificate parses and requested fields print", "meaning": "Those public fields are present and readable in that certificate.", "nextEvidence": "Validate the full path, reference identity, time, purpose, critical extensions, and trust policy rather than reading fields in isolation."},
        {"when": "Parsing or an extension lookup fails", "meaning": "The file format, object type, or requested extension differs.", "nextEvidence": "Confirm file provenance and encoding without renaming random files or exposing adjacent secret material."}
      ],
      "proves": "The public metadata OpenSSL decoded from that one file.",
      "doesNotProve": "Private-key possession, path validity, trust, endpoint deployment, revocation status, application acceptance, or authorization."
    },
    {
      "id": "LES-0016-CMD-004",
      "question": "Can a leaf build to the explicitly selected trust anchors using supplied intermediate material?",
      "risk": "read-only",
      "command": ": \"${TLS_HOST:?set TLS_HOST to one approved DNS name without scheme or port}\"; : \"${ROOTS_PEM:?set ROOTS_PEM to the reviewed trust-anchor bundle}\"; : \"${INTERMEDIATES_PEM:?set INTERMEDIATES_PEM to the reviewed intermediate bundle}\"; : \"${LEAF_CERT_PATH:?set LEAF_CERT_PATH to the reviewed leaf certificate}\"; case \"$TLS_HOST\" in ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*) printf '%s\\n' 'refusing: TLS_HOST is not a bounded DNS-name operand' >&2; exit 64;; esac; for candidate_path in \"$ROOTS_PEM\" \"$INTERMEDIATES_PEM\" \"$LEAF_CERT_PATH\"; do if [ ! -f \"$candidate_path\" ] || [ ! -r \"$candidate_path\" ] || [ -L \"$candidate_path\" ]; then printf 'refusing: certificate input is not a readable non-symlink regular file: %s\\n' \"$candidate_path\" >&2; exit 66; fi; done; openssl verify -show_chain -purpose sslserver -verify_hostname \"$TLS_HOST\" -CAfile \"$ROOTS_PEM\" -untrusted \"$INTERMEDIATES_PEM\" \"$LEAF_CERT_PATH\"",
      "runFrom": "An offline diagnostic directory containing public certificates only after exporting TLS_HOST, ROOTS_PEM, INTERMEDIATES_PEM, and LEAF_CERT_PATH to reviewed values; use a purpose and identity that match the real operation",
      "expectedBranches": [
        {"when": "The leaf reports OK and a chain prints", "meaning": "OpenSSL built an accepted path under these explicit files, purpose, name, and current validation time.", "nextEvidence": "Compare these files with what the peer sends and what the real application loads."},
        {"when": "Verification fails", "meaning": "The error identifies a rejected path-building or validation condition in this controlled context.", "nextEvidence": "Inspect the reported depth and reason, then test one changed variable at a time."}
      ],
      "proves": "Offline path acceptance for one tool version, time, identity, purpose, leaf, intermediate set, and trust-anchor set.",
      "doesNotProve": "That a server presents the same chain, another library builds the same path, revocation information is fresh, or the live application works."
    },
    {
      "id": "LES-0016-CMD-005",
      "question": "Does changing only SNI select a different virtual service or certificate on an approved shared endpoint?",
      "risk": "sampled-read-only",
      "command": ": \"${TLS_CONNECT_ENDPOINT:?set TLS_CONNECT_ENDPOINT to an approved IPv4:443 or [IPv6]:443 endpoint}\"; : \"${TLS_SERVICE_NAME:?set TLS_SERVICE_NAME to the reviewed DNS service name}\"; if ! printf '%s\\n' \"$TLS_CONNECT_ENDPOINT\" | grep -Eq '^(([0-9]{1,3}\\.){3}[0-9]{1,3}|\\[[0-9A-Fa-f:]+\\]):443$'; then printf '%s\\n' 'refusing: TLS_CONNECT_ENDPOINT must be a single IP endpoint ending in :443' >&2; exit 64; fi; case \"$TLS_SERVICE_NAME\" in ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*) printf '%s\\n' 'refusing: TLS_SERVICE_NAME must be one bounded DNS-name operand' >&2; exit 64;; esac; openssl s_client -connect \"$TLS_CONNECT_ENDPOINT\" -servername \"$TLS_SERVICE_NAME\" -verify_hostname \"$TLS_SERVICE_NAME\" -verify_return_error -brief </dev/null",
      "runFrom": "An authorized test client after exporting one approved TLS_CONNECT_ENDPOINT and its expected TLS_SERVICE_NAME; the preflight checks operand shape, not address ownership or change authorization",
      "expectedBranches": [
        {"when": "The intended certificate and path verify", "meaning": "That endpoint selected certificate material suitable for the given SNI and reference name.", "nextEvidence": "Compare the failing client's SNI and endpoint cohort, then test the full application protocol."},
        {"when": "A default certificate, unrecognized name, reset, or verification error appears", "meaning": "Virtual-host selection or its certificate configuration is a leading boundary.", "nextEvidence": "Inspect listener and proxy configuration through the owning team; do not bypass identity checks."}
      ],
      "proves": "The TLS behavior of one IP/name combination at one time.",
      "doesNotProve": "DNS correctness, behavior of other load-balancer nodes, HTTP Host routing, client support, or application health."
    },
    {
      "id": "LES-0016-CMD-006",
      "question": "Which application protocol does the endpoint select through ALPN?",
      "risk": "sampled-read-only",
      "command": ": \"${TLS_HOST:?set TLS_HOST to one approved DNS name without scheme or port}\"; case \"$TLS_HOST\" in ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*) printf '%s\\n' 'refusing: TLS_HOST must be one bounded DNS-name operand' >&2; exit 64;; esac; openssl s_client -connect \"${TLS_HOST}:443\" -servername \"$TLS_HOST\" -alpn 'h2,http/1.1' -verify_hostname \"$TLS_HOST\" -verify_return_error -brief </dev/null",
      "runFrom": "An approved endpoint with a documented ALPN contract after exporting TLS_HOST as its exact reviewed DNS name",
      "expectedBranches": [
        {"when": "The expected protocol is selected", "meaning": "The client offer and server policy agreed on that application protocol for this connection.", "nextEvidence": "Use a client that actually speaks it and verify the real operation."},
        {"when": "A different protocol or no ALPN is selected", "meaning": "TLS may still be protected, but application-protocol negotiation differs from expectation.", "nextEvidence": "Compare listener policy, client offer, proxy behavior, and application fallback."}
      ],
      "proves": "One ALPN negotiation outcome under the displayed TLS connection.",
      "doesNotProve": "Correct HTTP semantics, routing, authorization, backend protocol, or performance."
    },
    {
      "id": "LES-0016-CMD-007",
      "question": "What system trust-store links and package ownership are visible without changing trust?",
      "risk": "read-only",
      "command": "find /etc/ssl/certs -maxdepth 1 -type l -printf '%f -> %l\\n' | sed -n '1,20p'; dpkg-query -S /etc/ssl/certs/ca-certificates.crt 2>/dev/null || true",
      "runFrom": "The affected Ubuntu filesystem; output is intentionally bounded and does not enumerate private key locations",
      "expectedBranches": [
        {"when": "Certificate links and ca-certificates ownership print", "meaning": "The OS-level trust directory and bundle package are visible.", "nextEvidence": "Determine whether the affected runtime uses this bundle, a language-specific store, or an injected bundle."},
        {"when": "Paths or ownership differ", "meaning": "This image or runtime has a different trust-store layout.", "nextEvidence": "Use version-matched runtime documentation; do not copy a broad trust bundle blindly."}
      ],
      "proves": "A bounded view of OS certificate links and package ownership in this filesystem.",
      "doesNotProve": "That an application loaded this store, which anchors it accepts, whether a process reloaded, or whether private trust was added elsewhere."
    },
    {
      "id": "LES-0016-CMD-008",
      "question": "Is the local clock synchronized enough for certificate validity decisions?",
      "risk": "read-only",
      "command": "date -u --iso-8601=seconds; timedatectl show -p NTPSynchronized -p TimeUSec -p RTCTimeUSec 2>/dev/null || true",
      "runFrom": "The exact client or server host that rejected a certificate",
      "expectedBranches": [
        {"when": "UTC time is plausible and synchronization reports yes", "meaning": "Gross clock error is less likely for this sample.", "nextEvidence": "Compare numeric time with certificate notBefore/notAfter and trusted fleet time telemetry."},
        {"when": "Synchronization is false, unavailable, or time is implausible", "meaning": "Clock ownership is a real branch or evidence is incomplete.", "nextEvidence": "Escalate to the time-service owner; do not manually set a production clock as a diagnostic shortcut."}
      ],
      "proves": "The host's reported time and available synchronization properties at sample time.",
      "doesNotProve": "Historical time during failure, monotonic-clock behavior, upstream source correctness, or the clock inside another VM, container, browser, or appliance."
    },
    {
      "id": "LES-0016-CMD-009",
      "question": "Which process owns a local TLS listener in this namespace?",
      "risk": "read-only",
      "command": "ss -ltnp 'sport = :443'",
      "runFrom": "The exact Linux network namespace expected to terminate TLS; process details may be permission-limited",
      "expectedBranches": [
        {"when": "A listener and process are visible", "meaning": "A socket is listening on the shown address and port in this namespace.", "nextEvidence": "Map that process to certificate source, reload mechanism, virtual hosts, and downstream TLS legs."},
        {"when": "No listener or no process name appears", "meaning": "TLS may terminate elsewhere or visibility is restricted.", "nextEvidence": "Follow the traffic architecture instead of assuming the application owns port 443."}
      ],
      "proves": "A point-in-time listener view within one namespace and permission context.",
      "doesNotProve": "That the listener speaks TLS correctly, which certificate it serves, remote reachability, every endpoint, or application readiness."
    },
    {
      "id": "LES-0016-CMD-010",
      "question": "If direct Secret access is already authorized, which object identity, version, type, and data-key names can kubectl render without writing values to stdout?",
      "risk": "read-only",
      "command": ": \"${KUBE_NAMESPACE:?set KUBE_NAMESPACE to the authorized namespace}\"; : \"${TLS_SECRET_NAME:?set TLS_SECRET_NAME to the exact reviewed Secret name}\"; case \"$KUBE_NAMESPACE\" in -*|*-|*[!a-z0-9-]*) printf '%s\\n' 'refusing: KUBE_NAMESPACE must be one lowercase DNS-label operand' >&2; exit 64;; esac; case \"$TLS_SECRET_NAME\" in [-.]*|*[-.]|*..*|*.-*|*-.*|*[!a-z0-9.-]*) printf '%s\\n' 'refusing: TLS_SECRET_NAME must be one lowercase DNS-subdomain operand' >&2; exit 64;; esac; if [ \"${#KUBE_NAMESPACE}\" -gt 63 ] || [ \"${#TLS_SECRET_NAME}\" -gt 253 ]; then printf '%s\\n' 'refusing: Kubernetes name exceeds its length boundary' >&2; exit 64; fi; kubectl -n \"$KUBE_NAMESPACE\" get secret \"$TLS_SECRET_NAME\" -o go-template='name={{.metadata.name}}{{\"\\n\"}}resourceVersion={{.metadata.resourceVersion}}{{\"\\n\"}}type={{.type}}{{\"\\n\"}}keys={{range $k,$v := .data}}{{$k}} {{end}}{{\"\\n\"}}'",
      "runFrom": "Only after existing RBAC permission to get this exact Secret is confirmed and KUBE_NAMESPACE plus TLS_SECRET_NAME are exported to reviewed values; prefer an exported non-secret generation, public fingerprint, or expiry metric because this API GET returns the complete Secret object, including data, to the kubectl client even though the template suppresses values on stdout",
      "expectedBranches": [
        {"when": "Name, resource version, type, and expected data-key names print", "meaning": "kubectl rendered only those selected fields to stdout, but its client-side process received the complete Secret API response, including data bytes.", "nextEvidence": "Prove which workload consumed and reloaded that generation using approved non-secret telemetry."},
        {"when": "Access is denied or the object differs", "meaning": "No certificate-content evidence was collected, or the delivery object is not as assumed.", "nextEvidence": "Use the authorized owner and actual delivery mechanism; do not broaden permissions or print Secret data."}
      ],
      "proves": "The selected metadata and data-key names rendered for one Secret object at one resource version; the template limits stdout, not what the API returns to kubectl.",
      "doesNotProve": "That Secret values never entered client memory or other authorized observability, certificate contents, private-key validity, workload mount freshness, process reload, endpoint presentation, or trust."
    },
    {
      "id": "LES-0016-CMD-011",
      "question": "Which modeled TLS boundary diverged without creating keys, traffic, listeners, or trust changes?",
      "risk": "mutating-bounded",
      "command": "bash lab.sh setup && bash lab.sh run baseline && bash lab.sh inject guided && bash lab.sh observe inputs",
      "runFrom": "book/labs/LES-0016-tls-trust-path as a normal user on Ubuntu 24.04 or supported WSL Ubuntu",
      "expectedBranches": [
        {"when": "Guarded setup and raw inputs succeed", "meaning": "The deterministic case is ready and only raw operation inputs have been exposed.", "nextEvidence": "Write three hypotheses before observing handshake, certificate, trust, rotation, and ownership views."},
        {"when": "Any guard refuses", "meaning": "The lab cannot prove its mutation boundary in this context.", "nextEvidence": "Stop and inspect the refusal; never add sudo, weaken guards, or manually delete guessed paths."}
      ],
      "proves": "The guarded modeled-lab lifecycle reached the hypothesis checkpoint.",
      "doesNotProve": "Any real TLS endpoint condition, production diagnosis, learner mastery, or safe production change.",
      "cleanup": "After recovery and verification, run bash lab.sh cleanup and then bash lab.sh check; require state=absent."
    }
  ],
  "labs": [
    {
      "id": "LES-0016-LAB-001",
      "title": "Locate a modeled certificate-presentation failure using public metadata only",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with Bash and Python 3.8 or newer",
      "timeMinutes": 75,
      "privilege": "Normal user only; root is refused before mutation",
      "network": "None; deterministic offline TLS and PKI evidence only",
      "changes": ["One validated UID-scoped state descriptor under /tmp", "One validated private lesson directory under /tmp", "Small allowlisted public-metadata records; no certificate or key is generated"],
      "abortConditions": ["Effective UID is zero", "/tmp is not a real root-owned sticky directory", "A state path, owner, mode, link count, manifest, immutable fixture, or artifact check fails", "A dependency is absent or an orphan candidate exists"],
      "recovery": "Use the modeled recovery only after writing a hypothesis and evidence table; then verify the original operation separately and clean up through the guarded command.",
      "cleanupProof": "Cleanup revalidates every allowlisted artifact, removes only named files, removes the exact empty registered root and descriptor, and check proves state=absent.",
      "path": "book/labs/LES-0016-tls-trust-path"
    },
    {
      "id": "LES-0016-LAB-002",
      "title": "Independent trust-rotation failure localization with answer-isolated evidence",
      "mode": "independent",
      "environment": "A clean normal-user Ubuntu 24.04 or supported WSL 2 Ubuntu shell",
      "timeMinutes": 100,
      "privilege": "Normal user only; no sudo, key generation, trust edit, clock change, listener, packet capture, runtime socket, cluster credential, or cloud account",
      "network": "None; raw deterministic inputs are available before derived observations",
      "changes": ["The same guarded lab-owned state boundary", "A neutral case identifier and immutable modeled public metadata", "Learner notes stored outside lab state and never read by scripts"],
      "abortConditions": ["Any guard refuses", "A second case or baseline is requested", "An unexpected artifact or symlink appears", "The learner has not written pre-observation hypotheses"],
      "recovery": "Select an owner-correct modeled action with trust overlap and rollback only after diagnosis; run a separate verification and guarded cleanup.",
      "cleanupProof": "The verifier exercises both cases, invalid transitions, root refusal, artifact and model tampering, symlink and out-of-scope descriptor refusal, raw-input ordering, answer isolation, and final absence.",
      "path": "book/labs/LES-0016-tls-trust-path"
    }
  ],
  "incidents": [
    {
      "id": "LES-0016-INC-001",
      "signal": "After an edge renewal, some JVM clients reject the server path while browsers succeed; the leaf name and dates are correct, but affected endpoints present no intermediate.",
      "firstThought": "Treat the peer-sent list, client path builder, local trust anchors, caches, endpoint cohorts, and runtime stores as separate owners; browser success does not certify server-chain completeness.",
      "safePath": "Capture strict fresh-client evidence by endpoint, verify the leaf with explicit root and intermediate inputs, confirm the exact termination configuration, canary a leaf-plus-intermediate bundle while retaining the previous version, and verify real transactions across runtime families and endpoint cohorts.",
      "trap": "Disabling verification, importing the leaf everywhere, restarting every client, sending the root as a substitute for the missing intermediate, or declaring success from one browser."
    },
    {
      "id": "LES-0016-INC-002",
      "signal": "A private-CA migration moves every server to B-signed certificates while only 68% of client processes have loaded the A-plus-B bundle; new handshakes fail for the remaining cohort while long-lived connections continue.",
      "firstThought": "This is a distributed compatibility and reload problem: existing connections already have keys, while new connections require the current presenter and verifier generations to overlap.",
      "safePath": "Stop rollout, preserve issuer and bundle-generation coverage, route or restore a compatible A-signed presenter where possible, finish and actively prove dual-trust adoption, then resume B canaries; retain rollback until old issuance and credentials are provably gone before removing A trust.",
      "trap": "Adding retries, restarting all clients simultaneously, removing A trust on a calendar date, or weakening mTLS because the deployment tool reported certificate success."
    }
  ],
  "assessmentIds": ["ASM-0031", "ASM-0032", "ASM-0033"],
  "referenceIds": ["REF-0081", "REF-0082", "REF-0083", "REF-0084", "REF-0085", "REF-0086", "REF-0087", "REF-0088"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The required lab is a deterministic public-metadata model. It generates no certificate or key and cannot prove behavior of the learner's TLS library, trust store, proxy, Kubernetes cluster, load balancer, cloud, private CA, clock, or production application.",
    "Read-only TLS probes still create network traffic and handshakes; they require endpoint ownership, scope approval, rate limits, and data-handling rules and are not executed by the required lab.",
    "The lesson does not authorize private-key access, certificate issuance, trust-store mutation, system crypto-policy change, clock change, packet capture, proxy reload, Kubernetes mutation, or cloud control-plane action.",
    "TLS and algorithm guidance evolves. Production profiles must use current standards, vendor support, compliance constraints, client compatibility evidence, and security review rather than copying example names or values.",
    "Revocation mechanisms have reachability, freshness, privacy, soft-fail, and ecosystem limits. This lesson does not claim one universal revocation behavior or replace an organization's incident and credential-compromise policy.",
    "Publishing or completing this chapter does not award mastery; independent incident evidence and human review remain required."
  ]
}
---

# TLS, PKI, mTLS, trust, and rotation: prove which identity boundary failed

If a client says `certificate verify failed`, do not translate it to "the certificate is bad." That sentence is too small for the system you are debugging. A verifier has rejected one decision in a chain of decisions: it may not know the issuer, the server may have omitted an intermediate, the requested name may not match, the clock may be outside the validity window, the certificate may have the wrong purpose, an algorithm may violate policy, or an mTLS peer may be authenticated but unauthorized.

The durable habit is this:

> Name the exact TLS leg, the exact verifier, and the exact failed decision. Then change the owner of that decision, not every certificate-shaped thing nearby.

This chapter starts before cryptography and ends after rotation. You will learn enough vocabulary to read real evidence, enough internals to reason about failure phases, and enough operational discipline to keep a renewal from becoming an outage. The required lab remains entirely local and offline. It contains no real certificate, no private key, no listener, no packet, and no trust-store edit.

## What you see and first thought

A ticket arrives:

```text
Checkout workers cannot call https://payments.service.internal.
TCP connects. No HTTP status appears.
Java says: PKIX path building failed.
Chrome works. The certificate was renewed this morning.
Restarting a worker sometimes helps.
```

A hurried response is usually one of these:

- "The certificate expired."
- "Java has an old cache. Restart all pods."
- "Add the certificate to the trust store."
- "Use insecure mode until traffic settles."
- "It works in my browser, so networking is fine."

Each statement jumps across missing evidence. Start by expanding the operation:

```text
application
  -> resolves payments.service.internal
  -> opens TCP to one destination IP and port
  -> sends ClientHello with SNI and capability offers
  -> receives one endpoint cohort's TLS response
  -> validates that cohort's certificate path and service identity
  -> completes or rejects the handshake
  -> negotiates an application protocol through ALPN
  -> sends an HTTP request
  -> receives and validates a business response
```

The absence of an HTTP status matters. HTTP may never have existed for the failed attempt. A TCP connection proves that a transport path reached something accepting connections. It does not prove the correct virtual service answered, certificate validation succeeded, mTLS accepted the client, ALPN selected the expected protocol, HTTP routing worked, or the application was authorized.

Capture a failure card before changing anything:

| Field | Example | Why it matters |
|---|---|---|
| User operation | create payment authorization | Recovery must restore this, not merely a handshake. |
| Client | checkout worker build 2026.08.1, JVM 21 | TLS libraries and stores differ. |
| Client context | pod UID, node, namespace, process start | Trust and sessions can be process-scoped. |
| Reference identity | `payments.service.internal` | This is what certificate identifiers must match. |
| Destination | `10.24.7.19:443` | Endpoint cohorts can differ behind one name. |
| SNI | `payments.service.internal` | The terminator may select a certificate from it. |
| Phase | certificate validation | Separates TCP, TLS negotiation, authentication, and HTTP. |
| Exact error | path building: issuer unavailable | Preserve library wording and error class. |
| Time | UTC plus clock source | Validity checks are time-dependent. |
| Affected fraction | 38%, grouped by client and endpoint | Partial failure usually reveals skew. |
| Last known good | before renewal generation 1842 | Creates a comparison, not proof of causality. |

First thought: renewal is a strong change correlation, not yet root cause. Split the world along two axes. Which clients fail? Which server endpoints fail? A client-correlated distribution points toward store, cache, library, clock, or policy differences. An endpoint-correlated distribution points toward certificate deployment, chain packaging, SNI, reload, or proxy skew. Both can coexist.

Never weaken validation as a diagnostic shortcut. `--insecure`, `-k`, `verify=false`, a trust-all callback, or accepting every client certificate changes the security contract and can make an attacker look like recovery. Preserve authentication while you investigate.

## Terms before commands

**TLS** is a protocol for establishing a protected channel over a reliable ordered transport. In normal deployments it aims to provide confidentiality, integrity, and peer authentication. TLS does not hide destination IPs, connection timing, traffic volume, or necessarily the service name. It does not decide whether an authenticated caller may refund a payment. It does not prove that a response is correct.

**Plaintext** is application data before TLS record protection at a sending endpoint or after deprotection at a receiving endpoint. A TLS terminator necessarily sees plaintext for that leg. "Encrypted in transit" therefore requires a boundary statement: encrypted between which two endpoints, with whom able to terminate it?

**Handshake** is the exchange that negotiates protocol parameters, establishes shared keying material, authenticates the transcript and peers as required, and transitions to protected application records.

**Record layer** frames and protects data using traffic keys established by the handshake. TLS protects records, while application protocols define messages such as HTTP requests inside the protected stream.

**Cipher suite** in TLS 1.3 names record-protection algorithms, including an authenticated-encryption algorithm and hash. Key exchange groups and certificate signature algorithms are negotiated separately. This is why reading an old TLS 1.2 cipher-suite name as a TLS 1.3 policy is misleading.

**AEAD**, authenticated encryption with associated data, provides confidentiality and detects unauthorized modification for protected records under the traffic key. It does not authenticate a DNS name by itself; certificate or PSK authentication and identity verification do that.

**Key exchange** lets peers derive shared secrets. Ephemeral Diffie-Hellman groups are commonly used so compromise of a long-term certificate key later does not automatically reveal previously captured session traffic. That property is called **forward secrecy**, subject to implementation and key-erasure assumptions.

**Digital signature** lets a peer prove possession of a private key and binds handshake context to that key. Encryption and signing are different operations. In TLS 1.3, a certificate key generally authenticates the handshake; it is not simply used to encrypt all application bytes.

**Private key** is secret cryptographic material. Anyone who obtains a service private key may impersonate that service within applicable protocol, certificate, and trust conditions. A CA private key is more dangerous because it may issue many accepted identities. Never print, commit, paste, copy casually, or place private keys into diagnostic bundles.

**Public key** can be shared. A certificate contains a public key and signed metadata. A public-key fingerprint is not a secret, though it can still reveal inventory information.

**Certificate** is a signed data structure binding a public key to identifiers and attributes for a validity interval and permitted uses. A certificate is not a secret. Its corresponding private key is.

**X.509** is the certificate format family used by most TLS PKI. **PKIX** is the Internet profile and validation framework applied to X.509 certificates.

**Leaf** or **end-entity certificate** is the certificate presented for the service or client identity. It normally has CA capability disabled.

**Intermediate CA certificate** represents a CA authorized, within constraints, to sign other certificates. Organizations keep root keys away from daily issuance and use constrained intermediates to reduce exposure and separate environments or purposes.

**Root certificate** is often self-signed, but self-signature is not what makes it trusted. A verifier's local configuration makes a certificate a **trust anchor**. A root sent by an unknown server does not become trusted through confidence or proximity.

**Presented chain** is the ordered certificate material the peer sends. **Certification path** is what the verifier constructs from the leaf through candidate CA certificates to a locally trusted anchor. Those are not identical. The verifier may use local intermediates, caches, or alternate paths, and different libraries can choose differently.

**Subject** identifies the certificate subject in an X.500-style name. **Issuer** names the signer. Matching issuer text to subject text helps find candidates but does not verify a signature or constraints.

**Subject Alternative Name**, or **SAN**, carries service identities such as DNS names or IP addresses. Modern service-identity verification uses the appropriate SAN identifier for the client's reference identity. Do not rely on the legacy Common Name as a universal hostname fallback.

**Reference identity** is the name or IP address the client intended to reach before looking at the certificate. The client compares this expected identity with presented identifiers. Using whatever name appears in the certificate as the expectation reverses the trust decision.

**Validity window** is bounded by `notBefore` and `notAfter`. Both the certificate time and verifier clock matter. Renewal before expiry does not invalidate an older certificate; overlap can be deliberate. Expiry is only one validation branch.

**Serial number** distinguishes certificates from one issuer and participates in revocation handling and inventory. It is not a globally unique service identity.

**Basic constraints** say whether a certificate may act as a CA and can restrict path length. **Key usage** constrains cryptographic operations. **Extended key usage**, or **EKU**, indicates purposes such as TLS server or client authentication. A valid signature does not override an incompatible purpose.

**Critical extension** must be understood and processed according to policy or validation fails. Ignoring an unknown critical constraint would silently weaken what the issuer required.

**Trust store** is the verifier's configured set of anchors and sometimes related material. One laptop can have separate OS, browser, JVM, Python, container-image, service-mesh, and application-specific stores. Say "the Java process trust store at generation X," not "the server's trust."

**SNI**, Server Name Indication, is a ClientHello extension that tells a shared TLS endpoint which server name the client wants. It is available before HTTP routing and commonly selects a virtual host and certificate. SNI selection and certificate hostname verification use related names but are separate decisions.

**ALPN**, Application-Layer Protocol Negotiation, lets peers agree during TLS on a protocol such as HTTP/2 or HTTP/1.1. TLS can succeed while application-protocol negotiation or subsequent semantics fail.

**mTLS**, mutual TLS, adds client-certificate authentication to the usual server-authenticated channel. It does not mean both sides use the same CA, certificate, identity format, or authorization policy.

**Authentication** answers which identity was proven under a trust policy. **Authorization** answers whether that identity may perform an action on a resource. **Accounting or audit** records what decision and action occurred. A certificate accepted from a broad CA is not permission to become an administrator.

**Renewal** issues a new certificate, often under the same hierarchy and identity. **Key rotation** changes private/public key material. **Intermediate rotation** changes an issuing CA. **Root rotation** changes verifier trust anchors. These operations have different blast radii and rollout order.

**Revocation** communicates that a certificate should no longer be accepted before natural expiry. CRLs and OCSP are common mechanisms, but actual behavior depends on client policy, reachability, caching, stapling, freshness, and soft-fail or hard-fail choices. Do not claim universal immediate revocation.

## Architecture map

The most important architecture diagram is not a padlock. It is a series of independently terminated legs:

```text
 User / client process
   expected identity: checkout.example.test
   trust owner: client platform team
          |
          | TLS leg A
          | SNI=checkout.example.test
          v
 Edge load balancer / ingress
   presents: public service certificate
   terminates: leg A plaintext
   route owner: edge team
          |
          | TLS leg B
          | client identity=edge-gateway
          | server identity=checkout.prod.svc
          v
 Service sidecar or application
   verifies edge client certificate
   maps identity -> workload principal
   authorization owner: service team
          |
          | TLS leg C
          | server identity=ledger.database.internal
          v
 Database proxy / dependency
```

Text alternative: a client authenticates an edge on leg A. The edge decrypts and routes HTTP, then becomes a new TLS client on leg B. A service may authenticate both the edge and itself through mTLS. It can create a third TLS connection to a dependency. Each leg has different keys, certificates, trust anchors, clocks, session state, logs, capacity, and owners.

Make a leg inventory during design and incidents:

| Leg | TLS client | TLS server | Reference identity | SNI | Server trust owner | Client cert? | Termination owner |
|---|---|---|---|---|---|---|---|
| A | external client | edge listener | checkout name | checkout name | client/OS | no | edge platform |
| B | edge proxy | service proxy | service DNS name | service DNS name | mesh/platform | yes | service platform |
| C | application | database proxy | database name | database name | data platform | maybe | data platform |

This table prevents a classic mistake: inspecting the application pod's certificate when TLS actually terminated at the load balancer. It also prevents calling leg A secure and silently assuming leg B is encrypted.

Now add the control planes:

```text
 issuance plane                 distribution plane             runtime plane

 root CA key (offline/HSM)      certificate object/version     process listener
        |                                |                           |
 issuing intermediate           secret agent / volume / API    selected cert for SNI
        |                                |                           |
 CSR + identity policy          file ownership and modes       reload generation
        |                                |                           |
 signed leaf + chain bundle ---> workload / proxy config -----> observed handshake

 trust publisher --------------> verifier trust bundle -------> path decision
 inventory / expiry -----------> telemetry -------------------> alert and rollback gate
```

Text alternative: issuance decides what identity and purpose are signed. Distribution transports public certificates and secret keys under access controls. A runtime must actually load the intended generation. Separately, trust publishers distribute anchors to verifiers, which must reload them. Deployment success at one plane does not prove the next plane consumed it.

Assign owners explicitly:

- identity owner approves names and workload identity semantics;
- CA owner protects signing keys and issuance policy;
- secret-distribution owner transports the leaf private key and bundle;
- terminator owner selects certificate by listener and SNI and reloads it;
- trust-store owner controls accepted anchors and policies;
- application owner maps authenticated identity to authorization;
- time owner maintains clock synchronization;
- service owner defines SLO, verification, and rollback;
- incident commander coordinates changes without merging evidence scopes.

If two teams both say "security owns certificates," the system has no operational owner. Write down the concrete object and action each team owns.

## Request or state path

Follow a fresh TLS 1.3 connection. Details vary by mode and implementation, but this sequence gives you stable evidence boundaries.

```text
Client                                                    Server

resolve reference name
open TCP connection  -----------------------------------> accept TCP

ClientHello
  supported_versions
  supported_groups + key_share
  signature_algorithms
  cipher suites
  server_name (SNI)
  ALPN offers              -------------------------------->

                                      select virtual service and policy
                                      ServerHello + selected key_share
                           <---------------------------------

                     [handshake messages now encrypted]
                                      EncryptedExtensions
                                      selected ALPN
                                      CertificateRequest?  (mTLS)
                                      Certificate chain
                                      CertificateVerify
                                      Finished
                           <---------------------------------

validate server path, name, time, purpose, policy

client Certificate? + CertificateVerify? + Finished ----->
                                      validate client path and purpose
                                      map identity and authorize later

protected application data <=============================>
```

Text alternative: the initial ClientHello advertises capabilities and intent. The server selects compatible protocol and key-exchange parameters. Later handshake messages are encrypted in TLS 1.3. The server presents a certificate chain and signs the handshake transcript. With mTLS it requests equivalent proof from the client. Each side verifies Finished before application records flow.

### ClientHello is an offer, not the outcome

The client can offer versions, key-exchange groups, signature algorithms, TLS 1.3 cipher suites, SNI, and ALPN. A packet or trace showing an offered value does not prove the server selected it. Record both offer and selection.

SNI is routing input. If the client connects by IP and omits the intended server name, a shared endpoint may return a default certificate. `curl https://10.0.0.8` and a request to `https://payments.service.internal` are not equivalent even when DNS maps the latter to that address.

### Key exchange creates traffic secrets

TLS 1.3 commonly combines ephemeral key exchange with a transcript-bound key schedule. Neither peer sends the resulting traffic key on the wire. An observer sees public key shares and derives nothing without the required private ephemeral secret. Negotiation must resist downgrade and tampering; the Finished messages authenticate the transcript.

Do not describe this as "the server encrypts a session key with its certificate." That old simplification is wrong for the normal TLS 1.3 handshake and hides forward secrecy. Say: peers use negotiated key exchange to derive shared traffic secrets, and certificate signatures authenticate the handshake.

### Server authentication is several checks

The server sends a leaf and usually intermediate certificates. The client:

1. parses certificates and critical extensions;
2. finds candidate issuer certificates;
3. verifies signatures and CA constraints along a candidate path;
4. ends at a locally accepted trust anchor;
5. checks certificate validity against its clock;
6. checks intended purpose and algorithm policy;
7. applies configured revocation and policy behavior;
8. matches its reference identity against appropriate SAN identifiers;
9. verifies CertificateVerify and Finished transcript proofs.

Libraries may order internal work differently. The reasoning categories remain useful. "Certificate valid" must name which of these checks, which verifier, which inputs, and which time.

### mTLS adds the reverse identity decision

When the server requests a client certificate, the client selects a usable identity based on acceptable issuers, signature algorithms, local policy, and available key access. It sends certificate material and proves private-key possession. The server validates the client path and purpose using its own trust store.

Then comes authorization. Suppose the certificate identifies `spiffe://prod/checkout/worker` or another approved workload identity. A policy may permit `POST /authorize` but deny certificate administration. Authentication supplies a principal; policy supplies permissions.

### Finished is not business success

A successful handshake shows that the peers derived compatible keys and accepted the handshake under their policies. It does not prove:

- HTTP Host or path routing;
- application authentication such as a token;
- mTLS identity-to-principal mapping correctness;
- authorization for the requested resource;
- dependency health;
- response correctness or durable side effects;
- performance under representative concurrency;
- future connections to another endpoint cohort.

Always end verification with the real user operation and correctness checks.

### Resumption and long-lived connections change rollout evidence

TLS resumption can reduce handshake work using previously established state. Long-lived HTTP/2 or database connections may not perform a new handshake for hours. After a certificate rollout, those connections can remain healthy while every fresh connection fails. Conversely, restarting all clients creates a handshake surge and exposes a compatibility error simultaneously.

Test at least three paths when relevant:

- a fresh connection with no helpful intermediate or session cache;
- a resumed or reused connection path;
- the full application operation through every TLS leg.

Rotation telemetry must distinguish new handshakes from existing connections. "Traffic is still flowing" is not proof that the new credential works.

## Failure zoom

Use the first trustworthy failure, not the loudest downstream alert. A dashboard may collapse ten mechanisms into `SSL_ERROR`. Put the attempt into one phase:

| Phase | Typical evidence | Leading owners | Not yet involved |
|---|---|---|---|
| Name and route | resolution error, wrong destination | DNS, client config, routing | TLS peer validation |
| TCP establishment | refused, reset, timeout | listener, path, policy, transport state | TLS messages if no connection formed |
| ClientHello handling | protocol version, no shared group/cipher/signature, unrecognized name | client offer, server policy, SNI route | certificate path may not be evaluated |
| Server certificate validation | unknown issuer, missing issuer, expired, not yet valid, name mismatch, wrong purpose | served chain, verifier path builder, trust, clock, policy | HTTP request |
| Client certificate selection | no suitable certificate, key unavailable | client identity store, acceptable issuers, signature policy | server authorization |
| Client certificate validation | unknown client CA, bad certificate, wrong client purpose | server trust, client chain, clock, policy | application operation |
| Finished or protected records | decrypt error, bad record, transcript failure | TLS state, middlebox, implementation | normal HTTP semantics may not exist |
| Application after TLS | HTTP status, authorization denial, protocol error | ALPN, proxy routing, identity mapping, application | TLS may already be healthy |

An alert name is evidence from one peer. TLS alert reporting is not always symmetric or specific. A peer can send a broad alert while its own log contains the useful validation reason. A library wrapper can replace a precise reason with `connection reset`. Correlate both endpoints by time, connection identity, endpoint cohort, and direction; never infer the server's decision solely from the client's wording.

### Validation is an AND gate

Think of acceptance as a set of gates that all must pass:

```text
parse
  AND build a candidate path
  AND verify every signature
  AND honor CA constraints and critical extensions
  AND end at an accepted local anchor
  AND pass notBefore/notAfter against verifier time
  AND pass purpose, algorithm, and policy
  AND satisfy configured revocation behavior
  AND match the client's reference identity
  AND verify handshake proof
  = accepted server identity for this connection
```

Ten green checks do not cancel one red check. A certificate can be correctly signed and expired. It can be current and have the wrong SAN. It can match the SAN and chain to an untrusted root. It can pass every certificate check and still map to a principal with no application permission.

### Missing intermediate versus untrusted root

These failures sound similar but have different owners.

A **missing intermediate** means the server did not supply path-building material that a clean client needs. The client may trust the correct root but cannot connect the leaf's signature to it. Correct the served chain at the terminator. Do not install the leaf as a root.

An **untrusted root** means the path reaches an anchor the verifier does not accept. If this is a private service, the trust-distribution owner may need to deliver the approved private anchor to that specific verifier population. If the endpoint unexpectedly moved to another hierarchy, presentation or issuance may be wrong. Adding an unknown root broadly is not incident recovery; it is a security-boundary change requiring review.

A root is normally omitted from the server's certificate list because trust is local. Sending it wastes bytes and cannot convince a client that did not already trust it. The server normally sends the leaf and necessary intermediates in usable order.

### Name failure versus SNI failure

SNI asks the endpoint to select a virtual service. Hostname or service-identity verification asks whether the selected certificate authenticates the name the client intended.

Four useful combinations exist:

| SNI selection | Identity match | Meaning |
|---|---|---|
| expected | passes | Correct certificate selected and accepted for the expected name under this path. |
| expected | fails | Virtual host may be correct, but certificate identifiers do not cover the reference identity. |
| default/wrong | fails | Client omitted/wrong SNI or endpoint routing is wrong; default certificate exposes the mismatch. |
| wrong | appears to pass | A broad wildcard or shared certificate may hide routing error; verify HTTP route and endpoint ownership. |

Do not "fix" a name mismatch by changing the client to whatever name the certificate contains unless that new identity is the intended service contract. Do not use IP address as the URL and expect a DNS SAN to match it. DNS identifiers and IP identifiers are different reference categories.

### Time failure

A certificate is accepted only within its validity window under the verifier's clock and policy. `notBefore` prevents premature use; `notAfter` ends normal acceptance. Common mechanisms are:

- certificate genuinely expired because renewal or reload failed;
- new certificate issued with a future `notBefore` and deployed too early;
- client or server clock skew;
- process, VM, appliance, or container uses a different time boundary than inspected;
- long-lived connection hides expiry until reconnect;
- endpoint cohorts serve different generations;
- monitoring checks a repository object, while runtime serves another file.

Record numeric UTC times. "Valid for 90 days" is incomplete without issuance, activation, expiry, remaining lifetime, renewal start, and worst-case distribution/reload time. Do not manually change a production clock to make a certificate pass; clock steps can damage logs, leases, databases, and distributed algorithms.

### Purpose and algorithm failure

A certificate issued for client authentication is not automatically valid as a server certificate. Basic constraints, key usage, EKU, name constraints, and policy can restrict use. Separately, the certificate signature algorithm, public-key type, key size, TLS signature schemes, supported groups, and security-level policy must be compatible with both endpoints.

Do not respond to `no shared cipher` by enabling every old protocol and cipher. Capture client offers and server policy, confirm version-specific terminology, consult current standards and vendor support, then make the narrowest compatible security-reviewed change. Security policy is a compatibility contract and must be tested before rollout.

### Revocation is not magic deletion

Revocation asks clients to reject a certificate before its expiry. A CRL is a signed list published by a CA. OCSP asks or receives status for a certificate. Stapling can let a server provide a CA-authorized status response. Each ecosystem defines whether it checks, caches, hard-fails, soft-fails, or ignores unavailable status.

Therefore:

- `revoked at CA` does not prove every client has learned it;
- `OCSP responder reachable` does not prove the application checks it;
- `no revocation error` does not prove good status was freshly verified;
- hard failure can create an availability dependency on status infrastructure;
- soft failure can preserve availability while accepting an uncertain credential;
- short-lived certificates reduce exposure but demand highly reliable automated issuance and renewal.

Design compromise response using several controls: revoke where supported, remove authorization for the identity, rotate keys and certificates, stop affected issuance, narrow network access, invalidate sessions where applicable, and observe active fingerprints. State the residual risk.

### Deep incident 1: the browser works

At 08:05 UTC, an ingress controller loads leaf certificate generation 1842 for `payments.service.internal`. The leaf SAN is correct, its dates are valid, and it was signed by `Payments Intermediate 2026`. The configured file contains only the leaf. At 08:11, 38% of Java workers fail path building. Browsers and some restarted workers succeed.

Do not conclude that Java is broken. Build a two-dimensional evidence matrix:

| Client cohort | Endpoint cohort | Fresh path result | Peer-sent count | Local intermediate state |
|---|---|---|---:|---|
| Java image A | ingress pod 1 | fail | 1 | root only |
| Java image A | ingress pod 2 | fail | 1 | root only |
| Browser B | ingress pod 1 | pass | 1 | cached/local intermediate available |
| clean OpenSSL | ingress pod 1 | fail | 1 | explicit root only |
| clean OpenSSL + reviewed intermediate input | ingress pod 1 | pass | 1 | intermediate supplied offline |

What does this establish? TCP and SNI reach an intended endpoint. The endpoint sends only a leaf. A clean verifier with the intended root cannot build a path. Supplying the reviewed intermediate completes a valid path in a controlled test. Browser success is explained without making browser behavior the server contract.

The smallest safe correction belongs to the terminator: serve leaf plus the required intermediate bundle. Keep the root in verifier trust, not as a substitute chain element. Canary the corrected bundle on one ingress cohort, retain generation 1841 for rollback, and probe from clean Java, Go, OpenSSL, and representative platform clients. Verify the full payment transaction, not only `Verify return code: 0`. Watch handshake errors, latency, CPU, endpoint fingerprint/chain length, and business success.

The prevention change belongs before deployment: validate the exact served bundle from a clean controlled trust store, enforce leaf-to-intermediate linkage and CA constraints, and require active endpoint probes after reload. Inventory must connect issuance artifact, distribution version, proxy reload generation, served fingerprint, and client trust families.

### Deep incident 2: rotation completed, traffic failed

A private-cloud team migrates root CA A to root CA B. At 13:00, configuration management reports that the A+B trust bundle was delivered to all hosts. At 13:15, every service endpoint switches to B-signed leaves. New connections fail from 32% of processes; long-lived connections work. Process telemetry later shows only 68% loaded the new trust generation. Some JVMs read trust only at start, some sidecars missed a rollout, and a disaster-recovery VM group was absent from inventory.

The root cause is not "certificate expired." Presentation moved before verifier adoption was proven. File delivery was mistaken for runtime reload. Existing connections did not revalidate the new certificate, so aggregate traffic hid the broken fresh path.

Safe incident action:

1. freeze further presentation and old-trust removal;
2. group failure by client trust generation and server issuer generation;
3. restore or route to an A-signed compatible presenter for affected paths while both hierarchies remain controlled;
4. finish A+B distribution and restart/reload only the owner-scoped cohorts through normal disruption controls;
5. actively prove a B-signed canary path from every verifier family;
6. resume B presentation by failure-domain canary;
7. verify new, resumed, long-lived, mTLS, authorization, and business paths;
8. stop A issuance and discover old credentials;
9. remove A trust only after evidence covers maximum credential, connection, ticket, cache, offline-client, and disaster-recovery windows.

A calendar date is not removal proof. The proof is inventory coverage plus deliberate testing: B identities succeed and an A-only test identity fails in a canary verifier after old trust removal.

## Internals and state ownership

You do not need to implement cryptography to operate TLS, but you must know which state belongs where.

### TLS 1.3 negotiation has separate algorithm families

A TLS 1.3 policy includes at least:

- supported protocol versions;
- key-exchange groups and client/server key shares;
- handshake signature algorithms;
- certificate signature compatibility;
- TLS 1.3 cipher suites for AEAD and hash;
- certificate and trust policy;
- SNI and ALPN behavior;
- resumption and early-data policy.

In TLS 1.2, cipher-suite names often bundled key exchange, authentication, encryption, and hashing. In TLS 1.3 those choices are more separate. When someone says "enable the cipher," ask which protocol version and which family actually failed.

### Certificate signatures and handshake signatures differ

The issuer signs the certificate. During the handshake, the server signs transcript context using the leaf's private key through CertificateVerify. A client must be able to validate both the certificate's issuance path and the handshake signature under compatible algorithms. A certificate file can parse correctly while the runtime cannot use its key or negotiate a supported handshake signature.

Possession matters. Deploying a public certificate without its matching private key cannot authenticate the server. Do not expose the key to compare it. Within the authorized secret boundary, tooling can derive the public key from the private key and compare a digest with the certificate's public key. That operation should be automated by the certificate platform, audited, and designed never to print private bytes.

### Certificate encoding is not the security property

DER is a binary encoding. PEM wraps encoded objects in labeled text boundaries. A `.pem` file may contain a certificate, chain, private key, request, or several objects; the extension does not prove content. A PKCS#12 container can carry certificates and private keys, often protected by a password. Java key stores and platform stores add their own formats and semantics.

Never fix a parse error by renaming a file or pasting all objects together. Determine the consumer's required object types, ordering, encoding, password source, ownership, file modes, atomic replacement behavior, and reload semantics.

### Path construction is a search constrained by policy

The peer's leaf names an issuer and contains a signature. The verifier searches supplied and local CA material for issuer candidates, validates signatures and constraints, and tries to reach a configured trust anchor. Cross-signing can create more than one candidate path. Libraries may choose paths differently based on available intermediates and anchors.

A path is not accepted just because it is a list:

```text
leaf: payments.service.internal
  issuer -> Payments Intermediate 2026

intermediate: Payments Intermediate 2026
  CA=true, constrained purpose/path
  issuer -> Corporate Root B

local trust anchor: Corporate Root B
```

At each edge verify the cryptographic signature. At each CA enforce basic constraints and key usage. Apply name constraints, policies, critical extensions, validity, algorithm rules, and maximum path rules. Apply leaf purpose and reference-identity checks. The trust anchor's acceptance is local policy, not a property sent by the server.

### SAN matching is not substring matching

A client begins with a reference DNS name or IP address. It matches against the corresponding identifier type according to service-identity rules. A wildcard has constrained meaning; it is not a regular expression and should not be stretched across arbitrary labels. Case and internationalized-name handling follow protocol rules, not shell intuition. An IP literal requires an IP identifier, not a DNS name that happens to resolve to that IP.

Avoid certificates covering unrelated environments or huge namespaces. Broad identity makes routing mistakes harder to detect and increases compromise blast radius. Prefer clear, narrow names managed by an ownership system.

### Trust state lives inside running consumers

A file can contain A+B while a running process still uses A. Common reload behaviors include:

- read trust and certificate only at process start;
- watch a symlink or file and reload atomically;
- receive configuration through a proxy control plane;
- poll an API or secret agent;
- load per connection;
- retain sessions or connection pools after reload;
- reject in-place file changes but accept a versioned path;
- reload certificate but not trust, or the reverse.

Measure runtime generation. Useful non-secret signals are trust-bundle digest/version, served leaf fingerprint, issuer, serial, expiry seconds, chain length, config generation, reload success timestamp, and process start time. Never log private-key bytes, passphrases, Secret values, or full authentication credentials.

### mTLS identity must be normalized safely

A server may receive subject, SAN, URI, DNS, or another certificate claim. Define one approved identity source and normalization rule. Reject ambiguity. Do not trust a caller-controlled forwarded certificate header unless a trusted proxy strips incoming versions, terminates and validates mTLS, constructs the header itself, protects the hop, and the application authenticates that proxy.

Then apply authorization:

```text
authenticated identity = workload checkout in production
requested action        = POST /payment-authorizations
resource                = merchant account 314
policy context          = environment, tenant, risk state
decision                = allow or deny with reason
```

A shared client certificate makes attribution, rotation, revocation, and least privilege difficult. Prefer workload-scoped identities and short automated lifetimes where infrastructure reliability can support them.

### 0-RTT and resumption need explicit application policy

TLS resumption improves latency and reduces expensive full handshakes. TLS 1.3 early data can send application bytes before the full new handshake completes, but it has replay considerations. Do not enable 0-RTT for non-idempotent operations such as creating a payment merely to save latency. The application protocol and deployment must define replay-safe use.

Session tickets and keys are also operational state. Rotation can affect resumption rates, CPU, latency, and cross-node behavior. Ticket-key sharing expands compromise scope; per-node keys reduce sharing but affect resumption across load balancing. Treat the choice as security and capacity design, not a hidden default.

### Private-key custody is a production boundary

Minimum rules:

- generate and store root keys offline or in an approved hardened signer;
- use constrained intermediates for online issuance;
- give leaf keys only to the exact termination scope that needs them;
- prefer non-exportable keys or managed key handles when architecture supports them;
- encrypt transport and backups, enforce least privilege, and audit access;
- never place keys in Git, images, ConfigMaps, logs, command arguments, tickets, or chat;
- rotate immediately under a rehearsed compromise process;
- verify backups and disaster recovery without multiplying uncontrolled copies;
- dispose of retired material under policy and preserve non-secret audit evidence.

File mode `0600` is useful but not sufficient. Root on a host, container escape, memory disclosure, debugging endpoints, backup operators, and control-plane access can still expose a key. Map the real threat and trust boundary.

## Evidence table

Evidence is useful only when it names scope and limitation.

| Evidence | Unit/scope | What it proves | What it cannot prove | Next comparison |
|---|---|---|---|---|
| TCP connect succeeded | one client to one IP:port at time T | A TCP connection formed to something. | Correct TLS virtual service, certificate, HTTP, or all endpoints. | SNI-aware strict handshake. |
| ClientHello offers TLS 1.3 | one attempted connection | Client offered that version. | Server selected it or handshake completed. | ServerHello/connection summary. |
| Peer sent one certificate | one endpoint sample | One certificate appeared in peer Certificate material. | Clean path construction or fleet consistency. | Expected intermediate and other cohorts. |
| Leaf SAN contains expected DNS-ID | one certificate | Identifier is encoded in that leaf. | Trusted path, time, purpose, or endpoint deployment. | Strict path and name validation. |
| Leaf has 21 days remaining | verifier clock, seconds/days | Expiry headroom under that clock. | Renewal health, reload, issuer lifetime, or other endpoints. | Renewal and fleet coverage. |
| `verify` reports OK | explicit files/tool/time/purpose/name | That controlled validation accepted. | Live presentation, another runtime, revocation freshness, or app success. | Real runtime and endpoint. |
| Browser succeeds | one browser profile/path | That browser accepted and used a path. | Server chain completeness or Java/Go trust. | Fresh clean client with explicit trust. |
| Secret resourceVersion changed | one Kubernetes object | API object metadata changed. | Mount projection, process reload, key match, or served cert. | Runtime generation and active probe. |
| Served fingerprint is new | one endpoint cohort | That cohort presents the new leaf. | Other cohorts, trust adoption, or correct transaction. | Coverage denominator and business probe. |
| Trust generation A+B is loaded | reporting process population | Those reporters claim/load that generation. | Offline/non-reporting clients or identity correctness. | Active B-signed verification. |
| Existing HTTP/2 streams work | established connections | Existing protected/application state still works. | Fresh handshake after rotation. | Force a bounded fresh connection. |
| Handshake p99 rose 80 ms | defined metric window | Tail handshake time increased in that scope. | CPU, network, revocation, or chain cause. | Phase timing and resource correlation. |
| mTLS path validates | one client/server pair | Both certificate-validation directions passed under policy. | Requested action is authorized. | Identity mapping and audit decision. |
| 403 after TLS | application response | Application/proxy denied an operation after a usable protocol exchange. | Why policy denied without decision logs. | Principal/resource/reason audit. |

Keep counts and rates separate. `2,000 handshakes` is a count. `2,000 handshakes/second` is a rate. `0.4% failures` needs numerator, denominator, interval, and grouping. `30 days remaining` is a duration under a clock, not an availability prediction.

A strong incident table includes a healthy comparison differing by one dimension. Compare the same client against two endpoints, or two runtime stores against the same endpoint. Changing name, endpoint, client, time, and tool simultaneously creates an anecdote, not a controlled comparison.

## Command decoders

Commands are questions encoded as syntax. Run them only inside their stated authorization boundary.

### Decode the context command

```bash
cat /etc/os-release
uname -sr
id
readlink /proc/self/ns/net
date -u --iso-8601=seconds
openssl version -a
openssl version -d
```

`cat /etc/os-release` identifies the userspace distribution. `uname -sr` identifies kernel name and release. `id` proves effective identity; the required lab refuses UID 0. `/proc/self/ns/net` names the shell's network namespace object. `date -u` avoids local timezone ambiguity. `openssl version -a` prints build/platform details; `-d` prints OpenSSL's configured directory.

This does not tell you that Java uses OpenSSL. A JVM commonly uses its own TLS provider and configured trust store. Go may use system roots but behavior depends on build and platform. A browser may ship distinct behavior. First discover the application's library and configuration through its supported diagnostics.

### Decode strict `s_client`

```bash
openssl s_client \
: "${TLS_HOST:?set TLS_HOST to one approved DNS name without scheme or port}"
case "$TLS_HOST" in
  ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*)
    printf '%s\n' 'refusing: TLS_HOST is not a bounded DNS-name operand' >&2
    exit 64
    ;;
esac
[ "${#TLS_HOST}" -le 253 ] || { printf '%s\n' 'refusing: TLS_HOST is too long' >&2; exit 64; }
  -connect "${TLS_HOST}:443" \
  -servername "$TLS_HOST" \
  -verify_hostname "$TLS_HOST" \
  -verify_return_error \
  -showcerts \
  -brief </dev/null
```

- `-connect` selects the transport destination.
- `-servername` sends SNI for virtual-service selection.
- `-verify_hostname` tells OpenSSL which reference DNS identity to match.
- `-verify_return_error` makes a verification error terminate instead of continuing.
- `-showcerts` displays the certificate list the peer sent; it is not a verified chain.
- `-brief` limits connection summary output.
- `</dev/null` prevents an interactive session from waiting for input.

The fatal flag matters. OpenSSL documentation warns that `s_client` is a test tool and otherwise may continue after verification errors. Seeing a handshake after `verify error` is not application-grade acceptance.

If using a private CA, select the approved trust input explicitly, for example a reviewed `-CAfile`, rather than depending on whichever store the diagnostic shell happens to use. Never use `-CAfile` to point at a private key. Never paste the output if it includes sensitive application data from an interactive session.

### Decode certificate inspection

```bash
openssl x509 -in "$PUBLIC_CERT_PATH" -noout \
: "${PUBLIC_CERT_PATH:?set PUBLIC_CERT_PATH to one reviewed public-certificate file}"
if [ ! -f "$PUBLIC_CERT_PATH" ] || [ ! -r "$PUBLIC_CERT_PATH" ] || [ -L "$PUBLIC_CERT_PATH" ]; then
  printf '%s\n' 'refusing: PUBLIC_CERT_PATH must be one readable non-symlink regular file' >&2
  exit 66
fi

  -subject -issuer -serial -dates -fingerprint -sha256 \
  -ext subjectAltName \
  -ext basicConstraints \
  -ext keyUsage \
  -ext extendedKeyUsage
```

`x509` parses one certificate. `-noout` suppresses re-emitting its encoded body. Subject and issuer are labels, not validation. Serial and SHA-256 fingerprint are useful inventory keys when paired with issuer. Dates use the certificate validity window. Extension output exposes identity, CA capability, operations, and purpose.

A fingerprint proves that two observed public certificate encodings match under that digest. It does not prove ownership of the private key or trust. Do not shorten fingerprints so aggressively that collisions in your inventory become plausible.

### Decode offline path verification

```bash
openssl verify -show_chain \
  -purpose sslserver \
: "${TLS_HOST:?set TLS_HOST to one approved DNS name without scheme or port}"
: "${ROOTS_PEM:?set ROOTS_PEM to the reviewed trust-anchor bundle}"
: "${INTERMEDIATES_PEM:?set INTERMEDIATES_PEM to the reviewed intermediate bundle}"
: "${LEAF_CERT_PATH:?set LEAF_CERT_PATH to the reviewed leaf certificate}"
case "$TLS_HOST" in
  ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*)
    printf '%s\n' 'refusing: TLS_HOST is not a bounded DNS-name operand' >&2
    exit 64
    ;;
esac
for candidate_path in "$ROOTS_PEM" "$INTERMEDIATES_PEM" "$LEAF_CERT_PATH"; do
  if [ ! -f "$candidate_path" ] || [ ! -r "$candidate_path" ] || [ -L "$candidate_path" ]; then
    printf 'refusing: certificate input is not a readable non-symlink regular file: %s\n' "$candidate_path" >&2
    exit 66
  fi
done
  -verify_hostname "$TLS_HOST" \
  -CAfile "$ROOTS_PEM" \
  -untrusted "$INTERMEDIATES_PEM" \
  "$LEAF_CERT_PATH"
```

`-CAfile` supplies trust anchors for this controlled test. `-untrusted` supplies intermediate candidates; its unfortunate name means they are not anchors, not that they are malicious. `-purpose sslserver` applies server-certificate purpose. `-verify_hostname` applies service identity. `-show_chain` shows the built result.

Keep files public-certificate-only. A successful result is conditional on this OpenSSL version, validation time, inputs, purpose, name, and policy. Compare those inputs with the live server and application.

### Decode SNI versus destination

```bash
openssl s_client \
  -connect "$TLS_CONNECT_ENDPOINT" \
  -servername "$TLS_SERVICE_NAME" \
  -verify_hostname "$TLS_SERVICE_NAME" \
: "${TLS_CONNECT_ENDPOINT:?set TLS_CONNECT_ENDPOINT to an approved IPv4:443 or [IPv6]:443 endpoint}"
: "${TLS_SERVICE_NAME:?set TLS_SERVICE_NAME to the reviewed DNS service name}"
if ! printf '%s\n' "$TLS_CONNECT_ENDPOINT" | grep -Eq '^(([0-9]{1,3}\.){3}[0-9]{1,3}|\[[0-9A-Fa-f:]+\]):443$'; then
  printf '%s\n' 'refusing: TLS_CONNECT_ENDPOINT must be a single IP endpoint ending in :443' >&2
  exit 64
fi
case "$TLS_SERVICE_NAME" in
  ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*) printf '%s\n' 'refusing: TLS_SERVICE_NAME is not a bounded DNS-name operand' >&2; exit 64 ;;
esac
  -verify_return_error -brief </dev/null
```

The destination IP answers "where did TCP go?" SNI answers "which TLS virtual service did the client request?" `-verify_hostname` answers "which service identity must the certificate authenticate?" They can be intentionally different fields but must match the architecture contract. Preserve all three.

### Decode ALPN

```bash
openssl s_client -connect "${TLS_HOST}:443" \
  -servername "$TLS_HOST" \
  -alpn 'h2,http/1.1' \
  -verify_hostname "$TLS_HOST" \
: "${TLS_HOST:?set TLS_HOST to one approved DNS name without scheme or port}"
case "$TLS_HOST" in
  ''|-*|.*|*..*|*-|*[!A-Za-z0-9.-]*) printf '%s\n' 'refusing: TLS_HOST is not a bounded DNS-name operand' >&2; exit 64 ;;
esac
  -verify_return_error -brief </dev/null
```

The comma-separated ALPN argument is the client's ordered offer. The server selects at most one supported protocol for the connection. Do not send HTTP/1.1 bytes blindly after `h2` was selected; use a client that implements the negotiated protocol. ALPN success is an agreement label, not proof of correct application behavior.

### Decode time

```bash
date -u --iso-8601=seconds
timedatectl show -p NTPSynchronized -p TimeUSec -p RTCTimeUSec
```

UTC removes display ambiguity. `NTPSynchronized=yes` is supporting evidence, not mathematical proof that every historic sample was correct. Compare actual numeric timestamps with `notBefore` and `notAfter`; avoid prose such as "looks current."

### Decode safe Kubernetes metadata

The lesson command's Go template writes a Secret name, resource version, type, and data-key **names** to stdout, not values. That is an output filter, not a metadata-only API request: `kubectl get secret` needs RBAC `get` permission for the Secret and the API response gives the kubectl client the complete object, including `.data`. Prefer a controller, workload, or inventory system that exports a non-secret generation, public certificate fingerprint, issuer, serial, or expiry metric. Use the direct Secret GET only inside an explicitly authorized secret-handling boundary. Secret data are base64-encoded, not safely encrypted merely because they look unreadable. Never run a generic YAML dump of a TLS Secret for convenience, never paste it into a ticket, and never store decoded content in the repository.

A changed `resourceVersion` is control-plane evidence. Prove mount/update and process reload separately. Some projected volumes update asynchronously. Some applications follow symlinks; others keep an old file descriptor or read once at start. A load balancer may use a control-plane object without any pod filesystem.

### Decode the lab command

```bash
bash lab.sh setup && \
bash lab.sh run baseline && \
bash lab.sh inject guided && \
bash lab.sh observe inputs
```

`&&` runs the next command only when the previous one succeeds. Setup creates one guarded root under `/tmp`. Baseline writes known-good deterministic evidence. Injection selects a neutral case. `observe inputs` exposes only raw operation inputs so you can commit hypotheses before derived views. The lab does not use OpenSSL because its purpose is reasoning, not key generation.

## Decision path

Use this order during an incident.

```text
1. Is the failed operation precisely named?
   no -> capture client, name, endpoint, time, phase, error, affected fraction
   yes
    |
2. Did TCP establish to the intended endpoint?
   no -> return to DNS, routing, listener, policy, and transport evidence
   yes
    |
3. Was a compatible ClientHello/ServerHello negotiated?
   no -> compare SNI, versions, groups, signatures, ciphers, endpoint policy
   yes
    |
4. Did server-certificate validation pass?
   no -> split presented path / anchor / name / time / purpose / algorithm / revocation
   yes
    |
5. Was a client certificate requested and accepted?
   no when required -> split selection / key access / presented chain / server trust / purpose
   yes or not required
    |
6. Did Finished complete and ALPN select the intended protocol?
   no -> handshake/record/protocol evidence
   yes
    |
7. Was authenticated identity mapped and authorized?
   no -> identity normalization and policy decision evidence
   yes
    |
8. Did the complete business operation succeed correctly?
   no -> HTTP/application/dependency path
   yes -> verify scope, cohorts, time window, headroom, and recurrence controls
```

For certificate-validation failure, use a second tree:

```text
Can the certificate be parsed?
  -> Is the peer presenting the intended leaf for this SNI?
  -> Does the leaf identify the client's reference name/IP?
  -> Is verifier time inside the leaf and CA validity windows?
  -> Are required intermediate candidates available?
  -> Do signatures and CA constraints form a candidate path?
  -> Does it end at an anchor accepted by this exact verifier?
  -> Are purpose, algorithm, critical extensions, and policy accepted?
  -> What revocation behavior was actually applied?
  -> Did CertificateVerify and Finished prove the handshake?
```

At each node, write:

```text
Observation:
Owner and scope:
Timestamp and unit:
Healthy comparison:
What this proves:
What this cannot prove:
Next disconfirming test:
```

Choose remediation only after locating the first abnormal owner. Examples:

- wrong SNI -> correct client/proxy virtual-host contract, not trust;
- missing intermediate -> correct served bundle, not every client store;
- private root absent from intended verifier -> reviewed narrow trust distribution, not insecure mode;
- expired leaf still served -> correct issuance/distribution/reload and canary, not clock;
- clock skew -> repair time service under change control, not certificate dates;
- wrong EKU -> reissue from correct profile, not broad validation bypass;
- mTLS identity authenticated but denied -> correct authorization policy if intended, not CA trust;
- CA migration misordered -> restore overlap and prove trust adoption before new presentation.

Every change needs a rollback that remains valid. If you remove the old root before validating B, "put it back" may require redistributing trust to already broken clients. Preserve rollback during overlap.

## Guided Ubuntu lab

The required lab lives at:

```text
book/labs/LES-0016-tls-trust-path
```

It teaches evidence order with deterministic public metadata. It does **not** create a certificate, private key, CA, listener, socket, network request, trust-store entry, clock change, container, or cluster resource.

### Safety contract

- run as a normal user; UID 0 is refused;
- use Ubuntu 24.04 or supported WSL Ubuntu;
- require Bash, Python 3.8+, and base filesystem tools already present;
- mutate only one registered mode-`0700` child of `/tmp` and one UID-scoped mode-`0600` descriptor;
- use a fixed artifact allowlist and immutable copied model;
- refuse symbolic links, unexpected files, wrong owners/modes/link counts, orphan roots, invalid lifecycle transitions, and arbitrary paths;
- clean up by revalidation and explicit file deletion, never recursive removal.

Preflight:

```bash
cd book/labs/LES-0016-tls-trust-path
bash lab.sh check
```

Expect `environment=ready`, `privilege=normal-user`, `network=none`, and `state=absent`. If a guard refuses, stop. Do not use sudo or manually remove a guessed directory.

Create known-good state:

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

Select the guided incident and read raw inputs only:

```bash
bash lab.sh inject guided
bash lab.sh observe inputs
```

Before any derived view, write:

```text
Exact failed operation:
Client and server roles:
Reference identity and SNI:
Failed phase and first error:
Client-auth expectation:
Verifier clock:
Hypothesis 1 and disconfirming evidence:
Hypothesis 2 and disconfirming evidence:
Hypothesis 3 and disconfirming evidence:
```

Then inspect one boundary at a time:

```bash
bash lab.sh observe handshake
bash lab.sh observe certificate
bash lab.sh observe trust
bash lab.sh observe rotation
bash lab.sh observe ownership
```

Do not diagnose from one attractive field. For each view record field units, owner, scope, baseline, proves, does-not-prove, and next comparison. `presented_certificates=1` is a count. `leaf_seconds_remaining=1209600` is a duration. `trust_adoption_percent=100` is a modeled fleet percentage. They cannot be subtracted from one another.

After selecting the first abnormal owner, run modeled recovery and separate operation verification:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

`recover` records that a modeled configuration action completed. It is not proof of service health. `verify-operation` checks a fresh modeled handshake, path, name, client-auth expectation, application correctness, and cohort coverage separately.

Finally validate lab integrity:

```bash
bash verify.sh
```

The verifier exercises guided and independent lifecycles plus refusal boundaries. It deliberately does not print the independent values or diagnosis. A passing verifier proves script contract behavior in this environment, not your diagnosis and not production safety.

### Guided reasoning target

Build a path diagram using only observed fields:

```text
reference name
   -> SNI-selected endpoint cohort
   -> peer-presented leaf
   -> issuer candidate(s)
   -> locally configured anchor
   -> time / name / purpose / policy gates
   -> TLS Finished
   -> ALPN
   -> application result
```

Your incident note must answer:

1. What is the last known-good boundary?
2. What is the first abnormal boundary?
3. Which owner can change it?
4. What tempting evidence is insufficient?
5. What smallest recovery preserves authentication?
6. What is the rollback trigger and action?
7. How will a fresh client prove recovery?
8. How will the real operation prove correctness?

## Production transfer

The mental model stays stable while implementation changes.

### Linux process and reverse proxy

A process may terminate TLS directly, or a local reverse proxy may own the listener. Use namespace-scoped socket evidence and architecture configuration to locate termination. Then find certificate source and reload behavior through supported process documentation. Do not assume sending `SIGHUP` reloads safely; signals are application-specific public interfaces, and an incorrect signal can terminate a process.

Prefer versioned certificate material plus an atomic reference switch over rewriting a file in place. The terminator should validate a new bundle and key match before activation, retain the previous generation, expose the active public fingerprint, and roll back automatically or operationally on failed health gates. File ownership must allow the serving process to read the key and exclude unrelated users.

### Containers

A container image has its own filesystem and may carry a stale trust bundle. A bind mount, projected secret, or sidecar may deliver newer material, but the application must reload it. Minimal images often omit anchors or diagnostic tools deliberately. Do not install tools into a running production container as your first response; use existing telemetry or an approved ephemeral diagnostic workflow and preserve namespace scope.

Container replacement can refresh trust but also creates connection and handshake surges. Respect disruption budgets, readiness, termination grace, connection draining, and downstream capacity. Verify that the new image has the intended store before broad rollout.

### Kubernetes

Map at least these objects and controllers:

- Ingress or Gateway listener and the controller that implements it;
- TLS Secret or external secret/certificate provider;
- certificate issuance controller and CertificateSigningRequest workflow where used;
- Service and EndpointSlice routing after edge termination;
- sidecar or service-mesh control plane for workload mTLS;
- workload-mounted trust bundles and reload mechanism;
- kube-apiserver, kubelet, etcd, webhook, and front-proxy certificate relationships for cluster PKI;
- RBAC principals allowed to read or modify certificate and trust objects.

Kubernetes Secret data are base64-encoded values, not automatically safe to display. Limit access, enable encryption-at-rest controls appropriate to the cluster, avoid environment-variable exposure, use audit logs, and never commit manifests containing real key bytes.

Kubernetes itself uses both server and client certificates. Kubelet client rotation is one managed example, but do not generalize its behavior to every workload certificate. A CertificateSigningRequest being Approved or Issued does not prove a pod mounted the result, a process reloaded it, a proxy serves it, or clients trust it.

CA rotation across a cluster is especially sensitive because control-plane components verify each other in different directions. Official Kubernetes guidance uses trust overlap and ordered component updates. Follow version-specific documentation, backups, HA assumptions, and rollback; a single-control-plane environment has different availability properties.

### Service mesh

A sidecar or node proxy can terminate workload mTLS, so the application may see plaintext on loopback while the network leg is protected. Identify identity issuance, proxy trust domain, certificate lifetime, rotation cadence, control-plane availability, policy enforcement point, and whether traffic can bypass the proxy.

Mesh `mTLS=strict` is a configuration intent. Prove active proxy identity, policy, telemetry, and packet path. A misconfigured port, host-network workload, excluded range, ambient data-plane boundary, or plaintext egress can change reality. Also separate transport authentication from application token and authorization policy.

### Load balancer and cloud-managed certificate

A managed certificate status such as Issued or Active is control-plane evidence. Verify listener attachment, SNI certificate selection, endpoint rollout, chain presentation, policy, and real connection. Managed services can rotate certificates or intermediates; clients with pinned leafs or narrow unexpected stores can break even when public PKI is healthy.

Do not pin a leaf certificate as a substitute for proper identity and path validation unless the protocol and lifecycle are intentionally designed for pinning. Leaf renewal then becomes a coordinated trust change. If pinning is required, use a reviewed backup-pin and recovery strategy and understand lockout risk.

### Private cloud and virtualization

Inventory hypervisor managers, API endpoints, image registries, storage controllers, load balancers, monitoring agents, guest templates, and automation clients. Appliances may have independent clocks, stores, firmware constraints, certificate formats, and restart behavior. A vendor GUI showing a new certificate does not prove every clustered node serves it.

For VM templates, do not bake short-lived leaf keys into a reusable image. Generate or provision workload identity at deployment under an approved enrollment flow. Duplicated private keys create indistinguishable identities and enlarge compromise scope.

### CI/CD and infrastructure as code

Version non-secret intent and references, not private keys. A safe pipeline can:

1. lint public certificate identity, purpose, validity, chain, and policy;
2. check key match inside an isolated secret-aware step without logging material;
3. publish an immutable secret version to an approved store;
4. update a canary reference;
5. probe fresh TLS and the real application;
6. compare SLO and security gates;
7. expand gradually;
8. preserve and test rollback;
9. record active fingerprints and ownership;
10. remove old material after overlap evidence.

Pipeline logs, artifacts, caches, pull-request diffs, and command traces are common leak paths. Secret masking is not proof that arbitrary transformations cannot expose a key. Design steps so secret bytes never enter general logs.

## Reliability, security, observability, capacity, and cost

TLS is not a decorative security layer. It is a distributed production subsystem.

### Reliability

Define service objectives for the whole operation and leading TLS signals. Useful measures include:

- fresh-handshake success rate by client and endpoint cohort;
- handshake latency distribution, not average only;
- failure count and rate by phase and normalized reason;
- certificate expiry and renewal lead-time coverage;
- active served-fingerprint coverage across endpoints;
- trust-bundle generation coverage across verifiers;
- certificate and trust reload success and age;
- mTLS authentication versus authorization failures;
- session resumption and connection reuse rates;
- real application success and correctness.

Availability math must include dependencies. If every fresh connection requires an online revocation response and that check hard-fails, status infrastructure joins the request path. If certificate renewal depends on one issuer and the certificate lifetime is short, the issuer's outage budget and renewal retry policy influence service risk. Short lifetimes reduce some credential exposure but tighten automation reliability requirements.

### Security

State the security goal and residual metadata:

- confidentiality: protected application content between each leg's endpoints;
- integrity: unauthorized record changes are detected;
- authentication: intended server and optionally client identities are verified;
- forward secrecy: prior sessions resist later long-term key compromise under applicable key exchange and erasure assumptions;
- authorization: separately enforced based on authenticated principal and context;
- residual exposure: IPs, timing, volume, endpoint terminators, logs, and data at each endpoint.

Use current TLS standards and security policy. Disable obsolete versions and algorithms according to current authoritative guidance and client evidence, but do not copy a fixed cipher list from a book forever. Requirements change. Maintain a compatibility test matrix and an exception lifecycle.

### Observability

Good telemetry is high-cardinality enough to find skew but bounded enough to operate safely. Candidate dimensions include:

- TLS leg and termination service;
- client application/runtime family;
- server endpoint cohort, zone, proxy generation;
- negotiated TLS version, ALPN, and approved algorithm category;
- failure phase and normalized alert/reason;
- leaf issuer, expiry bucket, and truncated inventory token with collision-safe design;
- served chain length;
- trust-bundle generation;
- client-certificate requested/present/accepted state;
- authenticated principal category and authorization result, with privacy review.

Never label metrics with full certificates, private keys, raw tokens, arbitrary subjects, or unbounded SAN sets. Logs must not expose Secret contents or client personal identity unnecessarily. Use access control and retention appropriate to security telemetry.

Alert on actionability:

- renewal has not completed by an evidence-based lead-time threshold;
- any endpoint serves an unexpected fingerprint or chain length;
- trust adoption stalls below the rollout gate;
- fresh-handshake errors consume error budget;
- clock offset threatens minimum certificate headroom;
- issuer/CA service cannot meet the remaining renewal window;
- mTLS denial changes sharply by identity or policy generation;
- handshake CPU or latency approaches tested capacity.

An expiry alert alone is insufficient. A certificate can renew successfully and fail to deploy, deploy and fail to reload, reload on only some endpoints, or present a chain clients reject.

### Capacity

A full handshake consumes network round trips, asymmetric signature operations, key exchange, certificate bytes, path validation, memory, and application scheduling. Resumption changes the cost profile. Estimate rather than guess:

```text
new handshake CPU cores required
  approximately handshake_rate_per_second
              * cpu_seconds_per_handshake
              / target_utilization
```

If a proxy receives 8,000 new handshakes/s, measured CPU cost is 0.0007 core-seconds per handshake, and target crypto-worker utilization is 60%:

```text
8,000 handshakes/s * 0.0007 core-s/handshake = 5.6 cores
5.6 / 0.60 = 9.33 cores of planned CPU capacity
```

This is an illustrative average model, not a sizing answer. Measure p95/p99 costs by algorithm, certificate chain, resumption, hardware, runtime, and concurrency. Add failure-domain capacity, deployment surge, retry amplification, cold caches, revocation latency, and safety margin.

Certificate chain size affects handshake bytes and fragmentation risk. Longer chains and large keys can increase transfer and parsing. A restart wave can destroy connection reuse and create a handshake storm. Control rollout concurrency and watch downstream as well as the terminator.

Use Little's Law carefully for concurrent handshakes:

```text
average handshakes in progress
  = handshake arrivals/second * average handshake seconds
```

At 4,000/s and 0.08 s average, about 320 handshakes are in progress under stable assumptions. Tail latency, bursts, timeouts, and retries can make the required queue and worker capacity much larger.

### Cost

Costs include:

- managed CA, HSM, secret manager, load balancer, and certificate automation charges;
- CPU for handshakes and encrypted records;
- network bytes from chains, status information, retries, and telemetry;
- storage and retention for audit events and inventories;
- engineering/on-call time for manual renewal and outages;
- compliance controls and key ceremonies;
- duplicated capacity required for safe canaries and failure recovery.

The cheapest certificate service is not cheapest if manual distribution creates outages. The shortest lifetime is not safest if automation cannot renew within failure scenarios. The broadest wildcard reduces object count but increases blast radius. Compare total risk-adjusted lifecycle cost.

### Zero-downtime rotation runbook skeleton

```text
PREPARE
  inventory every presenter, verifier, identity, owner, store, reload, and lifetime
  protect new signing/key material
  validate algorithms, chain, SAN, purpose, and compatibility

TRUST FIRST
  distribute old+new trust to every verifier
  prove runtime load with generation telemetry and active new-chain probes

PRESENT GRADUALLY
  issue new credentials
  canary by endpoint and verifier failure domain
  keep old trust and rollback credential available
  verify fresh + resumed + mTLS + authorization + business operation

CONVERGE
  expand within SLO/security gates
  stop old issuance
  discover and replace every old credential

REMOVE OLD TRUST
  wait for evidence-based overlap, including offline and DR consumers
  canary old-anchor removal
  prove new path succeeds and old-only test identity fails
  expand, audit, and retire old key material under policy
```

Zero downtime is demonstrated by controlled overlap and operation evidence. It is never guaranteed by the word `renew` in a command.

## Traps and prevention

### Trap: "The certificate is valid"

Valid according to whom, for which name, purpose, time, path, trust store, algorithm policy, and revocation behavior? Replace the sentence with a bounded claim:

> OpenSSL 3.6 on client image A, using trust bundle generation 42, accepted the peer-sent leaf plus intermediate for DNS identity `payments.service.internal`, server purpose, and client time 2026-08-02T11:04:00Z against endpoint 10.24.7.19.

That claim can be compared and reproduced. It still does not prove the Java worker or business operation succeeds.

### Trap: trusting browser success

Browsers can use different roots, caches, path-building rules, network paths, proxy settings, and endpoint addresses. Browser success is one useful sample, never a universal certificate test. Prevent the trap with controlled clean-client probes for every supported runtime family and endpoint cohort.

### Trap: using `curl -k` or a trust-all callback

This removes the authentication decision and can turn interception into apparent success. It also changes which handshake branch executes. Prevent it through code review, policy checks, safe runbooks, and diagnostic commands that use explicit trust and fatal verification.

### Trap: adding the leaf to every trust store

A leaf is an identity credential, not usually the intended long-lived anchor. Trusting it directly couples every renewal to trust distribution and can bypass hierarchy constraints. Correct a missing intermediate at the presenter. Distribute a private root only to intended verifiers after identity and blast-radius review.

### Trap: sending the root to fix the chain

The root does not become trusted because the peer sends it. Sending it adds bytes and can confuse operators while the required intermediate is still absent. Build the served bundle from leaf and issuer intermediates; keep anchors under verifier policy.

### Trap: checking only expiry

Expiry is easy to graph, so teams make it the whole lifecycle. Certificates also fail through SAN, path, purpose, key mismatch, algorithm policy, distribution, reload, SNI, trust, clock, and partial rollout. Prevent this with a synthetic fresh handshake and application probe in addition to inventory alerts.

### Trap: overwriting certificate files in place

A process may read one file before another is complete, retain old file descriptors, or see a key/certificate mismatch. Use immutable versions, validate inside the secret boundary, atomically switch a reference, invoke a supported reload, verify active generation, and retain the prior version.

### Trap: restarting everything

Mass restart destroys comparison evidence, drops connections, creates handshake load, and can expose a broken fresh path across the whole fleet. Restart only a bounded cohort when reload behavior requires it, respecting availability controls and observing downstream capacity.

### Trap: assuming Secret update equals endpoint update

A control-plane object can update while mounts, sidecars, controllers, proxies, or processes remain stale. Export non-secret generation through every stage: issuance artifact, Secret resource version, projected version, process reload generation, served fingerprint, and active probe result.

### Trap: rotating issuer before trust

A new issuer is useless to clients that do not trust its path. Use trust-first overlap, actively prove runtime adoption, then canary presentation. Keep old trust until old credentials and recovery paths are gone.

### Trap: keeping dual trust forever

Overlap accepts identities from both hierarchies and increases the trusted attack surface. It is a migration state with explicit entry, observation, deadline, removal gates, and exception ownership. Remove old trust only after evidence, but do remove it.

### Trap: treating mTLS as authorization

A trusted CA may issue many client certificates. Without narrow identity extraction and policy, every accepted certificate can become over-privileged. Define trust domains, allowed identity forms, purpose, principal mapping, resource/action policy, denial reason, and audit.

### Trap: forwarding identity in an unprotected header

If clients can inject `X-Client-Cert` or a similar header, they may impersonate identities. A trusted proxy must remove inbound versions, authenticate mTLS, create a normalized assertion, protect and authenticate the backend hop, and the application must accept assertions only from that proxy boundary.

### Trap: logging secrets during diagnosis

Shell tracing, CI debug output, process arguments, Kubernetes YAML, core dumps, and support bundles can leak keys or passphrases. Collect public certificate metadata and fingerprints. Design secret-aware diagnostics that prove key match without emitting private data. Rotate any exposed key; deletion from a log does not undo disclosure.

### Trap: hardcoding today's algorithm list forever

Security knowledge, standards, client ecosystems, and compliance requirements change. Store policy as versioned configuration with owners, review dates, supported-client evidence, canary tests, and exception expiry. Check the current status and updates of the referenced standards before production changes.

### Prevention system

A durable certificate platform has four loops:

```text
ISSUE
  approved identity -> constrained profile -> protected signer -> public chain + secret key handle

DELIVER
  immutable version -> least-privilege destination -> atomic activation -> supported reload

PROVE
  active fingerprint + full served chain + trust generation + fresh handshake + real transaction

ROTATE
  lead-time alert -> trust-first overlap -> canary -> rollout -> old-use discovery -> old-trust removal
```

Each loop has an owner, SLO, audit trail, rollback, and game day. Manual calendar reminders are backup signals, not the primary renewal system.

## Memory card and retrieval

```text
TLS MEMORY CARD

One user operation may cross many TLS legs.
Name the leg, client, server, terminator, SNI, reference identity,
presented chain, trust store, clock, purpose, client-auth policy, and owner.

TLS gives a protected channel:
  confidentiality + integrity + authenticated peer(s) under policy.
It does not prove authorization, application correctness, or hidden metadata.

TLS 1.3:
  ClientHello offer
  -> ServerHello selection + shared key derivation
  -> encrypted handshake parameters
  -> certificate + CertificateVerify
  -> optional client certificate proof
  -> Finished
  -> protected application records.

Peer presents material; verifier builds a path.
Leaf identifies endpoint. Intermediate signs under constraints.
Local anchor creates trust. SAN matches the reference identity.
Time + purpose + constraints + algorithms + policy all matter.

SNI selects a TLS virtual service.
SAN verification authenticates the intended service name.
ALPN selects the application protocol.
These are separate decisions.

mTLS = server authentication + client authentication.
Authorization remains separate.

ROTATION ORDER
  inventory
  -> distribute old+new trust
  -> prove runtime adoption
  -> canary new presentation
  -> roll and verify
  -> stop old issuance and find stragglers
  -> canary removal of old trust
  -> prove old-only rejection and new success.

Never print keys. Never bypass verification to call an outage fixed.
Verify fresh handshake + resumed/reused path + real operation + all cohorts.
```

### Retrieval drills

Answer aloud before reading the complete answers.

1. What three security goals does TLS target, and what important goals remain outside TLS?
2. Why can a browser succeed when a Java service fails against the same DNS name?
3. What should a TLS server normally present, and why does it normally omit the root?
4. What is the difference among destination address, SNI, reference identity, and HTTP Host?
5. In TLS 1.3, what does a cipher suite name and what is negotiated separately?
6. What must a verifier check beyond certificate dates and signature?
7. What does mutual TLS prove, and what decision follows it?
8. What is the safe order for a private root-CA migration?
9. Why is revocation not guaranteed to become immediate universal rejection?
10. Why can old connections work while new handshakes fail after rotation?
11. What non-secret signals prove certificate and trust rollout progress?
12. What must a recovery verification include?

Review after ten minutes, one day, three days, one week, and one month. At each review, redraw the multi-leg architecture and the rotation sequence from memory. Explain one failure without starting from `openssl`.

## Complete answers

### 1. TLS goals and limits

TLS aims to provide confidentiality for protected content between the endpoints of one TLS leg, integrity so unauthorized modification is detected, and authentication of the server plus optional authentication of the client under configured policy. Forward secrecy can protect prior sessions against later long-term key compromise when appropriate ephemeral key exchange and key handling are used.

TLS does not hide every metadata signal such as destination IP, timing, and volume. A terminator sees plaintext for its leg. TLS does not decide application authorization, validate business correctness, guarantee endpoint availability, prevent a compromised endpoint from reading data, or prove that later TLS legs are protected. State the exact endpoints and remaining controls.

### 2. Browser versus Java

They may use different trust anchors, intermediate caches, path-building algorithms, revocation behavior, protocol support, proxies, DNS results, and server endpoints. A browser may build a path using locally available intermediate material even when the server omitted it, while a fresh JVM with only the root cannot. Or the browser may reach a healthy load-balancer node while Java reaches a stale one. Compare controlled client and endpoint dimensions; browser success proves only that browser's sampled operation.

### 3. What the server presents

A server normally presents its leaf followed by intermediate CA certificates needed for clients to build toward a configured anchor. It normally omits the root because the verifier decides trust locally. An untrusted root sent by the peer remains untrusted, and a trusted client already has its anchor. Sending the root adds bytes and does not replace a missing intermediate.

### 4. Destination, SNI, reference identity, and Host

The destination IP and port locate the TCP endpoint. SNI in ClientHello requests a TLS virtual service and commonly selects a certificate. The reference identity is the name or IP the client intended and must validate against certificate identifiers. HTTP Host or `:authority` routes the application request after TLS. They often contain related names but occur at different layers and can diverge through proxies; preserve each value.

### 5. TLS 1.3 cipher suites

A TLS 1.3 cipher suite primarily identifies record AEAD protection and an associated hash. Key-exchange groups, key shares, signature algorithms, and certificate types are negotiated or validated through separate mechanisms. Do not interpret a TLS 1.2 all-in-one cipher name model as TLS 1.3 configuration.

### 6. Full validation

A verifier parses the certificate and critical extensions; builds a path using peer and local CA material; verifies signatures; enforces CA, key usage, path, name-constraint, purpose, algorithm, and policy constraints; reaches a locally accepted anchor; checks validity against its clock; applies configured revocation behavior; matches the reference identifier to appropriate SAN identifiers; and verifies handshake proofs. Exact behavior is library and policy dependent, so record the verifier and inputs.

### 7. mTLS and authorization

mTLS can prove that the server and client each possess a private key corresponding to a certificate accepted under the other side's validation policy, for the tested connection. The authenticated client identity must then be normalized and mapped to a principal. Authorization independently decides whether that principal may perform an action on a resource. A certificate from a trusted CA is not universal permission.

### 8. Root migration order

Inventory all presenters and verifiers. Establish the new hierarchy safely. Distribute old-plus-new trust to every verifier and actively prove the running applications loaded it. Then canary new-signed credentials while retaining old trust and rollback. Roll presentation and issuance under SLO/security gates. Stop old issuance, find and replace every old credential, account for long-lived and offline state, then canary removal of old trust. Prove new success and old-only rejection before expansion.

### 9. Revocation limits

Clients vary in whether and how they consult CRLs, OCSP, stapled status, caches, or platform services. Responses have freshness windows. Network failure can be treated as hard failure, soft failure, or no check. Offline clients may not receive status. Therefore a CA revocation event is important control-plane evidence, not proof of instant fleet-wide rejection. Combine revocation with key rotation, authorization denial, inventory, network controls, session response, and measured client behavior.

### 10. Existing versus new connections

An established connection already negotiated keys and authenticated the peer under earlier state. It may carry many requests without a new handshake. A fresh connection must use the currently presented certificate and currently loaded trust. If those generations are incompatible, new connections fail while established traffic masks the outage. Verify fresh, resumed/reused, and long-lived paths during rotation.

### 11. Rollout signals

Useful public signals include issuance generation, leaf issuer/serial/fingerprint, expiry seconds, served chain length, endpoint cohort, Secret or configuration version, process reload generation and time, trust-bundle digest/version, fresh verification outcome, handshake failure phase, and fleet numerator/denominator. These prove stages only within their scope. Never expose private keys, passphrases, Secret data, or arbitrary certificate identity in high-cardinality logs.

### 12. Recovery verification

Verify the original client operation with correct response and side effects. Include strict path, reference-identity, time, purpose, algorithm, and configured revocation policy; mTLS client identity and authorization if used; expected ALPN; fresh and resumed/reused paths; all endpoint and verifier cohorts; handshake latency/error and capacity headroom; downstream effects; rollback triggers; and a time window long enough to cover normal renewal, connection, and traffic behavior. A successful configuration API call or one handshake is not recovery.

## Product-company interview

### Question: A service says `x509: certificate signed by unknown authority`. Walk me through diagnosis.

> I first name the failed TLS leg and verifier, because the same application may terminate or initiate several connections. I capture reference identity, SNI, destination, UTC time, endpoint cohort, client runtime/store generation, and exact phase. I inspect the peer-sent list with strict verification and compare a failing and healthy client or endpoint one dimension at a time. I determine whether the leaf's issuer intermediate is absent, whether a candidate path validates with explicit reviewed inputs, and whether the real verifier accepts the intended anchor, name, purpose, time, and algorithms. I do not add arbitrary roots or disable validation. A missing intermediate is corrected at the presenter; missing approved private trust is corrected narrowly at the verifier; unexpected issuer presentation is rolled back at the terminator. I canary, preserve the old generation, verify fresh handshakes and real transactions across cohorts, then add chain and trust-adoption tests to renewal automation.

### Question: Design mTLS between an ingress and backend services.

> I draw each directed verification decision. The ingress verifies the backend's server identity; the backend verifies the ingress's client identity. I define narrow identities, separate serverAuth and clientAuth profiles, constrained issuers, short automated lifetimes supported by reliable renewal, and explicit trust domains. The backend maps the authenticated client SAN or approved identity field to a principal and applies least-privilege authorization per action and resource. Keys remain in the proxy or approved key service, never forwarded as headers or logged. If identity is propagated, the trusted ingress strips caller-supplied headers, emits a protected signed or hop-authenticated assertion, and the backend accepts it only from that ingress. I test expiry, missing client cert, wrong identity, denied action, CA outage, clock skew, rotation overlap, long-lived connections, and failover while observing authentication separately from authorization.

### Question: How do you rotate a root CA without downtime?

> I treat it as a compatibility migration. I inventory every verifier and presenter, including offline and disaster-recovery consumers, stores, reload semantics, certificate lifetimes, and owners. I establish the new hierarchy under protected key controls, distribute an old-plus-new bundle first, and prove active application adoption with generation telemetry and new-chain probes. Then I canary new-signed server and client credentials while old trust and rollback credentials remain available. I expand by failure domain under handshake, latency, authorization, and user-operation gates. After stopping old issuance, I prove old credentials are absent beyond the maximum credential, connection, ticket, cache, and offline windows. I canary old-anchor removal and deliberately show that a test old-only identity fails while new production operations succeed. Dual trust is temporary because it enlarges trust; rollback is preserved until removal gates pass.

### Question: The certificate expires in seven days. Is that an incident?

> Seven days is neither universally safe nor automatically an incident. I compare remaining lifetime with the renewal SLO, issuer availability, approval and issuance duration, distribution and reload time, canary duration, failure-domain rollout, weekends/on-call coverage, rollback, and safety margin. I inspect whether renewal has started, whether the new artifact passes identity/chain/purpose policy, and whether any endpoint already serves it. I alert based on time-to-action and pipeline stage, not one fixed number. If the remaining window cannot cover worst-case recovery, I declare operational risk early. I do not extend expiry or weaken validation; I repair the blocked lifecycle stage and verify the served result.

### Question: How would you measure TLS capacity?

> I split full, resumed, and reused connections. I measure new handshakes per second, concurrent handshakes, CPU seconds per handshake by algorithm and runtime, certificate-chain bytes, network RTT, validation or status latency, session-resumption rate, connection lifetime, handshake p50/p95/p99, error phases, and crypto-worker queueing. I model steady state and failure surges: deploy restarts, zone loss, retry amplification, cold caches, and resumption-key changes. I size each terminator and downstream leg with failure-domain headroom and test in a disposable environment using the supported client mix. Success means user SLO and security policy hold under load, not merely that a port accepts connections.

### Question: What would you do if a private key is exposed?

> I treat it as credential compromise, stop further exposure, preserve audit evidence without copying the key, identify the exact key, certificate, identity, endpoints, access logs, backups, and scope, and activate the security incident process. I issue a replacement key and certificate through the approved signer, distribute and canary it, remove the compromised credential from every terminator, and use revocation where supported. I also revoke or deny the identity at authorization and network layers where appropriate, assess sessions and impersonation evidence, rotate related credentials if scope is uncertain, and verify active fingerprints. I do not assume deleting the file or expiring the certificate removes copies. Prevention addresses least privilege, non-exportability, secret scanning, logging, backups, and rehearsed emergency rotation.

Weak interview answers sound decisive but collapse boundaries: "restart NGINX," "update cacerts," "use the newest cipher," or "cert-manager handles it." Strong answers name the operation, owners, evidence, uncertainty, least-risk change, rollback, and proof.

## Independent transfer and rubric

Use the independent lab case without inspecting the fixture source:

```bash
cd book/labs/LES-0016-tls-trust-path
bash lab.sh check
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh observe inputs
```

Write your operation statement and three competing hypotheses now. Then collect:

```bash
bash lab.sh observe handshake
bash lab.sh observe certificate
bash lab.sh observe trust
bash lab.sh observe rotation
bash lab.sh observe ownership
```

Do not read `fixtures/tls_trust_model.py` before submitting. This is an open local repository, so the file cannot be made secret honestly. Answer isolation means normal commands and the verifier do not print a diagnosis or solution key, and the independent model copy is immutable during the lifecycle.

Deliver:

1. exact user operation, phase, client/server direction, endpoint, SNI, reference identity, client-auth expectation, clock, and error;
2. multi-leg architecture with termination, presentation, trust, identity mapping, authorization, and application owners;
3. evidence table with unit, scope, time, baseline, proves, does-not-prove, and disconfirming test;
4. at least three independently testable mechanisms;
5. first abnormal and last known-good boundaries;
6. certificate/trust inventory containing public metadata only;
7. smallest safe owner-correct recovery with prerequisite, canary, approval, blast radius, and rollback;
8. fresh, resumed/reused, mTLS/authorization, cohort, and full-operation verification;
9. prevention plan covering issue, delivery, reload, proof, rotation, clocks, telemetry, capacity, cost, and game days;
10. a five-minute incident briefing suitable for engineering and incident command.

After committing the diagnosis:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
bash verify.sh
```

### Rubric: 30 points

| Area | 0 points | 1-2 points | 3 points |
|---|---|---|---|
| Operation and phase | vague SSL issue | partial endpoint or error | exact roles, endpoint, phase, identity, clock, and error |
| Architecture | one encrypted box | some proxies named | every TLS leg, terminator, verifier, trust, and owner mapped |
| TLS mechanics | encryption slogans | mostly correct steps | offer, selection, key exchange, authentication, Finished, ALPN separated |
| PKI | expiry only | leaf/CA basics | path construction, constraints, SAN, purpose, anchor, and policy correct |
| mTLS | both sides secure | two certs mentioned | both directions plus identity mapping and authorization separated |
| Evidence | values copied | comparisons present | unit, scope, baseline, proof limit, and disconfirming test for every claim |
| Alternatives | one guess | two mechanisms | three or more independent mechanisms tested without anchoring |
| Remediation | bypass or restart | bounded change | owner-correct canary preserving authentication and key safety |
| Rollback/verification | config succeeded | handshake checked | valid rollback plus fresh/reused/cohort/business proof and window |
| Prevention/communication | generic automation | several controls | lifecycle, capacity, cost, ownership, risks, and clear briefing |

Scores 0-14 repeat the foundation and guided incident. Scores 15-21 show runbook-level reasoning under review. Scores 22-26 show strong supervised production transfer. Scores 27-30 show strong evidence on this scenario, not universal mastery or independent production authority.

Assessment `ASM-0033` is reviewer-only and intentionally contains no model diagnosis. A human reviewer should challenge your path, unsafe assumptions, rollback, and evidence limitations.

## References and review

Primary sources linked by the structured content registry:

- `REF-0081`: RFC 9846, the current TLS 1.3 specification as reviewed on 2026-08-02. It obsoletes RFC 8446 and is the source for handshake, authentication, key schedule, record protection, and resumption behavior.
- `REF-0082`: RFC 5280, the PKIX certificate and CRL profile for certification paths, constraints, extensions, and revocation-list structure.
- `REF-0083`: RFC 9525, current service-identity guidance for matching a client-selected reference identifier to certificate identities.
- `REF-0084`: RFC 6066, the server_name/SNI extension definition; consult its current update relationships when implementing policy.
- `REF-0085`: RFC 7301, ALPN protocol negotiation.
- `REF-0086`: RFC 9325 / BCP 195, TLS deployment recommendations. The RFC Editor lists later updates, so check current status before production policy changes.
- `REF-0087`: OpenSSL 3.6 `s_client` documentation, including strict verification flags and the warning that the test client can otherwise continue after verification errors.
- `REF-0088`: official Kubernetes CA-rotation documentation, used as a concrete trust-overlap and ordered-rollout example rather than a universal command recipe.

Review policy:

- prefer current RFC Editor status and version-matched vendor/runtime documentation over memorized protocol advice;
- recheck TLS specifications and BCP updates before algorithm, version, revocation, or identity-policy changes;
- revalidate OpenSSL flags against the installed major/minor version;
- revalidate Kubernetes procedures against the exact cluster and component versions, HA topology, PKI mode, and official documentation;
- review by `2027-02-02`, or sooner after a source, platform, security policy, lab guard, or schema changes;
- treat every hostname and address as illustrative/reserved and every live probe as requiring ownership and approval;
- never turn lesson examples into private-key handling instructions or production mutations without the owning platform's reviewed runbook;
- never infer mastery from publication, reading, quiz score, or verifier success.

Final retrieval prompt:

> A padlock is the end of several decisions, not the beginning of an explanation. Name the TLS leg and verifier. Preserve the reference identity, SNI, endpoint, time, presented material, trust generation, purpose, and exact failed phase. Change only the owner of the failed gate, keep authentication intact, preserve rollback through overlap, and verify a fresh connection plus the real user operation across every cohort.
