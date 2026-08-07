---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0071",
  "slug": "security-foundations-threat-modeling",
  "aliases": ["V08-L01", "security-foundations-threat-modeling"],
  "curriculumIds": ["SEC-001"],
  "route": "/book/security/security-foundations-threat-modeling",
  "order": 1,
  "volume": "08-security-engineering",
  "title": "Security foundations and threat modeling: from assets to recovery",
  "summary": "Build a practical security operating model from user promises, assets, actors and trust boundaries through risk, identity, authorization, secrets, encryption, segmentation, audit, detection, incident response, recovery and owned residual risk.",
  "domain": "security",
  "level": {"from": "foundation", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0007", "LES-0011", "LES-0016"],
  "prerequisiteCurriculumIds": ["FND-001", "LNX-004", "NET-006"],
  "testedEnvironments": [
    {"platform": "Primary and official sources", "version": "OWASP, NIST, IETF, MITRE ATT&CK and CIS sources reviewed 2026-08-07", "support": "concept-only", "notes": "Sources support terminology, mechanisms and methods; they do not certify any implementation."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic security-decision model only; no attack traffic, credential or external system."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON decisions only; no package install, cryptography or network."},
    {"platform": "Representative identity, policy, key, network, logging and response systems", "version": "not available", "support": "unsupported", "notes": "No production control effectiveness, adversarial resistance, regulatory compliance or incident-readiness claim."}
  ],
  "targetRoles": ["devops-engineer", "site-reliability-engineer", "platform-engineer", "security-engineer", "cloud-engineer", "kubernetes-engineer", "software-engineer", "technical-lead"],
  "learningObjectives": [
    "Translate business and user promises into owned confidentiality, integrity, availability, authenticity, accountability and recovery requirements.",
    "Identify assets, data classifications, actors, capabilities, entry points, trust boundaries, assumptions and dependencies.",
    "Use STRIDE and attack knowledge as discovery prompts while assessing concrete likelihood, impact, uncertainty and residual risk.",
    "Separate identity proofing, authentication, workload identity, authorization, session management and audit.",
    "Design subject-action-object-context authorization, least privilege, separation of duties and bounded break-glass access.",
    "Engineer secret, certificate and key lifecycles rather than treating encryption as a checkbox.",
    "Use segmentation, egress control, secure defaults, inventory and vulnerability management as independent layers.",
    "Design logs and detections from response questions, with integrity, privacy, retention, routing and tested action.",
    "Contain incidents through independent authority, preserve evidence, scope impact and prove secure recovery.",
    "Maintain a living threat model with accountable risk decisions and explicit change, incident and time triggers."
  ],
  "productionSignals": [
    "user operation asset owner data classification and required security outcome",
    "versioned component data-flow management-plane identity-plane delivery-plane observability and backup map",
    "trust boundary actor capability entry point protocol identity authorization validation and failure behavior",
    "threat scenario prerequisites exposure existing control evidence likelihood impact uncertainty and priority",
    "risk treatment accountable owner due date exception expiry acceptance authority and review trigger",
    "identity issuer immutable subject proofing assurance authenticator session audience lifetime and revocation state",
    "authorization principal action resource tenant context policy version decision reason and enforcement point",
    "human workload and break-glass permission grants use recency wildcard conditions and separation of duties",
    "secret certificate and key identifier purpose owner version lease age storage delivery rotation revocation and destruction",
    "transport endpoints protocol policy peer identity cipher negotiation and plaintext termination boundaries",
    "segment source destination service identity port direction enforcement point default action and denied-flow evidence",
    "asset software configuration owner exposure version vulnerability exploitability patch exception and verification state",
    "security event correlation actor object decision outcome source time integrity retention and access",
    "detection query coverage threshold evaluation window alert route acknowledgement and response outcome",
    "incident timeline containment authority evidence custody affected assets recovery tests and residual uncertainty"
  ],
  "diagrams": [
    {"id": "LES-0071-DIA-001", "title": "Security reasoning chain", "direction": "left-to-right", "boundaries": ["user promise", "assets and owners", "actors and trust boundaries", "threat scenarios", "risk decisions", "requirements and controls", "evidence and response", "residual risk"], "evidencePoints": ["operation", "classification", "capability", "likelihood and impact", "owner", "test", "decision", "review trigger"], "textAlternative": "Security reasoning starts with a user or business promise and moves through assets, actors, threats, risk, testable controls and evidence to owned residual risk."},
    {"id": "LES-0071-DIA-002", "title": "Document service trust-boundary map", "direction": "left-to-right", "boundaries": ["untrusted browser", "edge", "application", "asynchronous worker", "data stores", "management plane", "backup plane"], "evidencePoints": ["identity", "authorization", "protocol", "validation", "decision log", "administrative action", "restore"], "textAlternative": "A browser crosses edge, application, worker and data-store boundaries while identity, management, delivery, observability and backup planes create additional privileged paths."},
    {"id": "LES-0071-DIA-003", "title": "Human and workload access decision", "direction": "left-to-right", "boundaries": ["identity proof", "authenticator", "issuer", "session or workload assertion", "policy", "resource", "audit"], "evidencePoints": ["assurance", "subject", "audience", "action and object", "decision", "outcome"], "textAlternative": "Proofing enrolls an identity, authentication verifies an authenticator, and the resource independently authorizes a subject action on an object in context."},
    {"id": "LES-0071-DIA-004", "title": "Defense-in-depth layers", "direction": "hierarchical", "boundaries": ["secure design", "identity and authorization", "secret and key lifecycle", "host and workload isolation", "network segmentation and egress", "data protection", "detection and response", "recovery"], "evidencePoints": ["negative test", "permission use", "rotation", "policy deny", "cipher boundary", "alert", "restore"], "textAlternative": "Independent preventive, detective, responsive and recovery layers reduce likelihood and impact without treating one control as universal protection."},
    {"id": "LES-0071-DIA-005", "title": "Security incident evidence path", "direction": "cyclic", "boundaries": ["signal", "triage", "contain", "preserve", "scope", "eradicate", "recover", "learn"], "evidencePoints": ["timeline", "authority", "custody", "affected asset", "trusted replacement", "negative and positive tests", "owner"], "textAlternative": "An incident loop validates the signal, contains through trusted authority, preserves evidence, scopes impact, restores from trusted state and feeds learning back into the model."},
    {"id": "LES-0071-DIA-006", "title": "Living threat-model review loop", "direction": "cyclic", "boundaries": ["system change", "model update", "control test", "telemetry", "incident or finding", "risk decision", "backlog and ownership"], "evidencePoints": ["diff", "assumption", "test result", "coverage", "decision", "deadline"], "textAlternative": "Architecture changes, control results and incidents trigger threat-model revision, risk ownership and tracked engineering work."}
  ],
  "commands": [
    {"id": "LES-0071-CMD-001", "question": "Which local processes and listening sockets form the observed attack surface?", "risk": "read-only", "command": "ps -eo user,pid,ppid,comm,args; ss -lntup", "runFrom": "owned Ubuntu host; expect some process details to require privilege", "expectedBranches": [{"when": "expected processes and listeners only", "meaning": "observed local surface matches one snapshot", "nextEvidence": "service configuration, owner and firewall path"}, {"when": "unexpected or unattributed listener", "meaning": "architecture or inventory is incomplete", "nextEvidence": "identify owning process before changing it"}, {"when": "permission hides process details", "meaning": "visibility is incomplete", "nextEvidence": "use approved elevated evidence path"}], "proves": "one host's visible processes and listening sockets at observation time", "doesNotProve": "external reachability, legitimacy, exploitability or historical state"},
    {"id": "LES-0071-CMD-002", "question": "Which identity and groups does this shell actually use?", "risk": "read-only", "command": "id; umask", "runFrom": "owned Ubuntu shell", "expectedBranches": [{"when": "expected UID groups and restrictive mask", "meaning": "current execution identity and creation mask are bounded", "nextEvidence": "object permissions and effective policy"}, {"when": "unexpected privileged group or permissive mask", "meaning": "least-privilege assumption needs review", "nextEvidence": "inspect grants and created objects"}], "proves": "current process credentials, supplementary groups and shell creation mask", "doesNotProve": "all effective authorization, ACLs, capabilities, sudo rights or existing-file safety"},
    {"id": "LES-0071-CMD-003", "question": "Who can traverse and read every component of a sensitive path?", "risk": "read-only", "command": "namei -l /path/to/file; stat -c '%A %a %U:%G %n' /path/to/file", "runFrom": "owned Ubuntu host after replacing the placeholder", "expectedBranches": [{"when": "path and file permissions match policy", "meaning": "basic DAC evidence is consistent", "nextEvidence": "ACL, capability and service identity"}, {"when": "parent traversal or file read is broader", "meaning": "the effective exposure may exceed the final file mode", "nextEvidence": "scope readers before repair"}, {"when": "permission denied", "meaning": "observer cannot inspect the path", "nextEvidence": "use an approved evidence role"}], "proves": "visible path-component ownership and mode bits", "doesNotProve": "ACL, SELinux/AppArmor, open descriptors, copied data or application authorization"},
    {"id": "LES-0071-CMD-004", "question": "Do ACL entries grant access beyond Unix mode shorthand?", "risk": "read-only", "command": "getfacl -p /path/to/file", "runFrom": "owned Ubuntu host with getfacl installed and placeholder replaced", "expectedBranches": [{"when": "ACL agrees with intended principals", "meaning": "visible discretionary ACL is bounded", "nextEvidence": "process and application enforcement"}, {"when": "named user group or mask is broader", "meaning": "mode-bit reading alone was incomplete", "nextEvidence": "identify owner and usage before changing"}, {"when": "tool or permission unavailable", "meaning": "ACL evidence is missing", "nextEvidence": "obtain through approved package/evidence path"}], "proves": "filesystem ACL visible to the caller", "doesNotProve": "application object authorization or absence of other copies"},
    {"id": "LES-0071-CMD-005", "question": "Under which OS identity and hardening settings does a service run?", "risk": "read-only", "command": "systemctl show SERVICE --property=User,Group,DynamicUser,NoNewPrivileges,ProtectSystem,ProtectHome,PrivateTmp,CapabilityBoundingSet", "runFrom": "owned systemd host after replacing SERVICE", "expectedBranches": [{"when": "dedicated identity and expected restrictions appear", "meaning": "declared unit sandbox is bounded", "nextEvidence": "effective process credentials and exercised negative tests"}, {"when": "root or weak defaults appear", "meaning": "impact may be unnecessarily broad", "nextEvidence": "model required privileges before hardening"}, {"when": "unit absent or access denied", "meaning": "wrong host/context or insufficient evidence", "nextEvidence": "reconcile architecture"}], "proves": "selected systemd unit properties", "doesNotProve": "effective kernel state, application safety or control bypass resistance"},
    {"id": "LES-0071-CMD-006", "question": "What certificate, names and validity does a local TLS endpoint present?", "risk": "sampled-read-only", "command": "openssl s_client -connect 127.0.0.1:8443 -servername service.local -verify_return_error </dev/null", "runFrom": "owned loopback-only test service; never substitute an unapproved target", "expectedBranches": [{"when": "chain name and validity meet local trust", "meaning": "this client observed authenticated TLS under its trust store", "nextEvidence": "termination boundary and application authorization"}, {"when": "verification fails", "meaning": "identity, chain, name, time or trust is wrong", "nextEvidence": "preserve output and inspect exact cause"}, {"when": "connection fails", "meaning": "no handshake evidence exists", "nextEvidence": "check listener and route"}], "proves": "one client handshake and presented certificate path to one endpoint", "doesNotProve": "all clients, backend hops, private-key safety or application authorization"},
    {"id": "LES-0071-CMD-007", "question": "What packet-filter policy is visible on this host?", "risk": "read-only", "command": "sudo -n nft list ruleset", "runFrom": "owned Ubuntu host with explicitly approved passwordless read-only privilege or expect refusal", "expectedBranches": [{"when": "rules print", "meaning": "a visible nftables ruleset can be reviewed", "nextEvidence": "interfaces, routing, upstream controls and observed tests"}, {"when": "sudo refuses", "meaning": "no authority was silently acquired", "nextEvidence": "use the approved operator evidence path"}, {"when": "nft unavailable", "meaning": "another enforcement system may apply", "nextEvidence": "identify the actual firewall owner"}], "proves": "visible host ruleset under the selected namespace", "doesNotProve": "cloud, hypervisor, container, upstream, eBPF or application policy, nor actual traffic outcome"},
    {"id": "LES-0071-CMD-008", "question": "Which DNS names and routes can this local test resolve without contacting public targets?", "risk": "read-only", "command": "getent hosts localhost; ip route show; ip -brief address show", "runFrom": "owned Ubuntu host", "expectedBranches": [{"when": "expected loopback address interfaces and routes", "meaning": "local addressing assumptions match one snapshot", "nextEvidence": "namespace, policy and actual connection path"}, {"when": "unexpected route or interface", "meaning": "egress or reachability assumptions are incomplete", "nextEvidence": "identify owner before modification"}], "proves": "selected resolver result, interface and route state", "doesNotProve": "firewall permission, remote reachability, DNS integrity or service identity"},
    {"id": "LES-0071-CMD-009", "question": "Can logs answer who did what to which object and what policy decided?", "risk": "sampled-read-only", "command": "journalctl --since '-15 min' --no-pager -u SERVICE", "runFrom": "owned Ubuntu host after replacing SERVICE; use least log-reading privilege", "expectedBranches": [{"when": "correlated actor action object decision and outcome exist", "meaning": "the sample supports investigation questions", "nextEvidence": "integrity, retention and end-to-end detection"}, {"when": "only status or uncorrelated text exists", "meaning": "logging coverage is insufficient", "nextEvidence": "design structured decision events"}, {"when": "access denied", "meaning": "the responder lacks evidence access", "nextEvidence": "use approved break-glass or delegated role"}], "proves": "events visible in one journal scope and time window", "doesNotProve": "event truth, completeness, integrity, remote ingestion or historical absence"},
    {"id": "LES-0071-CMD-010", "question": "Which Linux capabilities broaden a running process beyond ordinary UID checks?", "risk": "read-only", "command": "getpcaps PID; grep -E '^(Uid|Gid|Cap(Inh|Prm|Eff|Bnd|Amb)|NoNewPrivs):' /proc/PID/status", "runFrom": "owned Ubuntu host after replacing PID", "expectedBranches": [{"when": "no unnecessary effective capability", "meaning": "visible kernel authority is narrower", "nextEvidence": "namespace, seccomp, LSM and exercised behavior"}, {"when": "unexpected bit is effective or bounded", "meaning": "compromise impact may be broader", "nextEvidence": "map exact capability need before removal"}, {"when": "process exits or access denies", "meaning": "snapshot evidence is unavailable", "nextEvidence": "repeat safely with stable process identity"}], "proves": "visible capability and no-new-privileges fields for one process snapshot", "doesNotProve": "complete sandboxing, code safety or authorization"},
    {"id": "LES-0071-CMD-011", "question": "Does a local certificate file match expected names, usage and dates?", "risk": "read-only", "command": "openssl x509 -in certificate.pem -noout -subject -issuer -serial -dates -ext subjectAltName -ext keyUsage -ext extendedKeyUsage", "runFrom": "approved non-secret certificate file; never pass a private key", "expectedBranches": [{"when": "identity usage issuer and time match policy", "meaning": "parsed public certificate fields meet the stated expectation", "nextEvidence": "chain, revocation, deployment and private-key boundary"}, {"when": "field differs or parse fails", "meaning": "file cannot support the intended identity", "nextEvidence": "stop deployment and preserve identity"}], "proves": "selected public X.509 fields in one file", "doesNotProve": "private-key possession, chain acceptance, revocation or served deployment"},
    {"id": "LES-0071-CMD-012", "question": "Does the offline security model cover every decision gate and clean exactly?", "risk": "mutating-bounded", "command": "bash verify.sh", "runFrom": "LES-0071 support/lab as a normal Ubuntu 24.04 user from absent state", "expectedBranches": [{"when": "verify passes", "meaning": "36 branches, refusal and cleanup pass", "nextEvidence": "retain the model-only boundary"}, {"when": "failure", "meaning": "the lesson candidate is rejected", "nextEvidence": "preserve and repair the first failed check"}], "proves": "deterministic decision ordering and bounded local lifecycle", "doesNotProve": "real threat coverage, control effectiveness, adversarial resistance, compliance or incident readiness", "cleanup": "Verifier proves the exact UID-scoped state root is absent."}
  ],
  "labs": [
    {"id": "LES-0071-LAB-001", "title": "Guided security-decision and threat-model lab", "mode": "guided", "environment": "Ubuntu 24.04 normal user with Bash and Python 3; no security product or target", "timeMinutes": 240, "privilege": "normal user; root refused", "network": "none", "changes": ["one UID-scoped temporary root", "one copied synthetic 36-case fixture"], "abortConditions": ["root", "credential", "cloud profile", "cluster context", "Docker endpoint", "public target", "symlink", "wrong owner", "unknown artifact"], "recovery": "Preserve the first failure and remove only exact allowlisted state.", "cleanupProof": "Exact inventory followed by state-root absence.", "path": "drafts/LES-0071-security-foundations-threat-modeling/support/lab"},
    {"id": "LES-0071-LAB-002", "title": "Independent security model, injected fault and recovery", "mode": "independent", "environment": "Reviewer-owned disposable local multi-component service with synthetic data", "timeMinutes": 240, "privilege": "normal-user operator; reviewer owns fault and containment authorities", "network": "loopback or isolated local network only", "changes": ["synthetic identities policies data and telemetry", "one identity/authorization and one detection/containment fault"], "abortConditions": ["production", "public target", "real credential", "customer data", "unscoped administrator", "destructive attack tool", "unknown cleanup"], "recovery": "Contain through independent authority, preserve evidence, repair, prove intended allow and prohibited deny, then update risk ownership.", "cleanupProof": "Reviewer proves every identity, process, port, file, policy and environment absent.", "path": "drafts/LES-0071-security-foundations-threat-modeling/support/lab"}
  ],
  "incidents": [
    {"id": "LES-0071-INC-001", "signal": "An authenticated user reads another tenant's object by changing an identifier.", "firstThought": "Authentication may have succeeded while object-level authorization failed.", "safePath": "Narrowly restrict the operation, preserve subject-action-object-policy-data evidence, scope exposure, enforce server-side ownership and prove allow/deny behavior.", "trap": "Rotate passwords or block one IP and leave the object path unchanged."},
    {"id": "LES-0071-INC-002", "signal": "A workload credential accesses data outside its assigned job.", "firstThought": "Workload authentication exists, but authority is standing or insufficiently bound to job and object.", "safePath": "Stop new authority, revoke precisely through an independent plane, preserve issuance/workload/data evidence, replace with short-lived job-bound capability and test cross-job denial.", "trap": "Recreate the Pod while the same overbroad credential remains valid."},
    {"id": "LES-0071-INC-003", "signal": "A public certificate is renewed but clients fail or connect to the wrong identity.", "firstThought": "Encryption, peer identity, certificate deployment, chain, name, usage and key match are separate facts.", "safePath": "Preserve served and intended certificate identities, validate from the client path, restore known-good binding, then repair renewal and reload evidence.", "trap": "Disable certificate verification or globally weaken TLS."},
    {"id": "LES-0071-INC-004", "signal": "Security logs are missing during a suspected administrative change.", "firstThought": "Missing telemetry is uncertainty and potentially an integrity incident, not proof that no action occurred.", "safePath": "Protect remaining sources, restrict administrative authority if warranted, compare independent identity/control/data logs, bound blind spots and restore tamper-resistant collection.", "trap": "Close the incident because the dashboard shows no alert."},
    {"id": "LES-0071-INC-005", "signal": "The compromised data plane can disable the same tool used to contain it.", "firstThought": "The response path shares the failure domain and may be untrustworthy.", "safePath": "Use separately protected break-glass identity and control plane, preserve evidence, revoke data-plane authority, restore from trusted state and test the path regularly.", "trap": "Ask the suspected workload to clean and attest itself."}
  ],
  "assessmentIds": ["ASM-0196", "ASM-0197", "ASM-0198"],
  "referenceIds": ["REF-0823", "REF-0824", "REF-0825", "REF-0826", "REF-0827", "REF-0828", "REF-0829", "REF-0830", "REF-0831", "REF-0832", "REF-0833", "REF-0834", "REF-0835", "REF-0836", "REF-0837"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The deterministic lab is a reasoning model, not a scanner, identity provider, policy engine, firewall, key manager, SIEM or incident platform.",
    "No public target, credential, private key, cloud account, cluster, exploit, malware, customer data or production system is used.",
    "Commands are observation examples whose output and privilege vary by host; each claim remains bounded to its evidence.",
    "No regulatory, certification, penetration-test, adversarial-resistance or production-control-effectiveness claim is made.",
    "Formal security review, representative implementation evidence, independent transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Security foundations and threat modeling: from assets to recovery

Security becomes understandable when you stop starting with tools.

Start with a promise: **who should be able to do what, to which asset, under which conditions—and what must still be true after something goes wrong?** Everything else is evidence for or against that promise.

This lesson builds one reusable mental model for a Linux host, API, Kubernetes platform, CI system, data platform or cloud service. The product names change. The questions do not.

## What you see and first thought

### When the symptom sounds like “security”

You may see:

- a successful login followed by `403 Forbidden`;
- a successful login followed by someone else's data;
- a certificate warning;
- an unexpected listening port;
- a service running as `root`;
- an API key in a log;
- malware or a suspicious process;
- an alert for unusual downloads;
- no alert even though data was accessed;
- a critical vulnerability on a host;
- a firewall rule that says “allow any”;
- a backup that cannot be restored.

Do not compress all of these into “we were hacked.” First name the observed fact and the security property at risk.

| Observation | First useful thought | Do not conclude yet |
|---|---|---|
| Correct user receives `403` | Authentication and authorization are separate; bind the exact denied action and object | “IAM is broken” |
| User receives another tenant's object | Suspect object-level authorization and confidentiality loss | “The password was hacked” |
| TLS warning | Separate reachability, handshake, certificate chain, name, time and trust | “Encryption is off” |
| Service runs as root | Compromise impact may be broad; discover which privileges are actually required | “Change user immediately in production” |
| Secret appears in a log | Treat the value as exposed; removal does not revoke existing copies | “Deleting the line fixes it” |
| Vulnerability scanner is red | Bind finding to exact asset/version/exposure and compensating evidence | “The system is compromised” |
| No alert exists | Visibility may be absent; silence is not safety | “Nothing happened” |
| Backup job is green | A copy may exist; recovery is not proven until restore and security behavior work | “We can recover” |

### The first response pattern

Use **PACE**:

1. **Pause expansion.** Stop the unsafe operation, new grants or rollout at the narrowest trustworthy boundary.
2. **Acquire evidence.** Preserve volatile and durable records before rebuilding or deleting when safe.
3. **Contain with independent authority.** Revoke, isolate or restrict through a control plane the suspected component cannot control.
4. **Establish scope and recovery proof.** Determine known impact and blind spots; restore both intended success and prohibited failure.

“Rotate everything” is not a universal first action. Rotation is correct when authority may be exposed, but it can create an outage, destroy session context and leave the root path open. Likewise, “block the IP” is weak when identity, tokens, proxies or shared addresses matter.

> A control is not a promise. A test result is not universal proof. Missing evidence is uncertainty, not absence.

## Terms before commands

### Asset, owner and security outcome

An **asset** is anything whose loss, misuse or unavailability matters: customer data, money movement, identity, source code, deployment authority, encryption keys, service capacity, logs, backups, reputation and human safety.

An **owner** is accountable for the business consequence and risk decision. An operator may administer a database without being authorized to accept indefinite exposure of customer records.

The classic **CIA triad** describes outcomes:

- **Confidentiality:** information is disclosed only to authorized subjects.
- **Integrity:** data and behavior are complete, correct and changed only through authorized paths.
- **Availability:** the required operation is usable within an agreed time and quality.

Add **authenticity** (is this actor/object what it claims?), **accountability** (can actions be tied to responsible identities?) and **recoverability** (can trusted service be restored?). CIA is a thinking lens, not a complete control list. Encryption can support confidentiality yet damage availability if keys are lost.

### Threat, vulnerability, exposure, exploit and risk

A **threat** is a potential cause of harm. A **threat actor** can be a person, compromised workload, dependency, natural event or accidental operator. Describe capability instead of guessing motive.

A **vulnerability** is a weakness. **Exposure** is the reachable condition that lets an actor interact with it. An **exploit** is a technique that exercises a weakness. **Impact** is the consequence.

**Risk** is an informed decision about uncertain loss, commonly reasoned from likelihood and impact. A scanner severity is not your business risk. A critical library in unreachable test code and a medium authorization flaw in an internet payment API do not deserve automatic ordering.

**Inherent risk** is risk before selected controls. **Residual risk** remains after controls. Residual risk never means zero; it needs an owner, evidence, expiry or review trigger.

### Control, requirement and evidence

A **security requirement** is a testable statement about expected behavior. “Use least privilege” is advice. This is testable:

> Worker identity W may read objects listed in its current job J for five minutes; it cannot list the bucket, access another job or mint new authority.

A **control** changes likelihood or impact. Controls may:

- prevent: deny an unauthorized request;
- detect: identify a suspicious event;
- respond: revoke authority and coordinate action;
- recover: restore trusted service and data.

**Evidence** is an observation bounded by time, scope and method. A policy file proves text exists. A unit test proves represented inputs behaved in one environment. An admission record proves one decision. None alone proves the system is secure.

### Trust and trust boundary

**Trust** is willingness to accept a claim or grant authority under assumptions. It is not affection or certainty.

A **trust boundary** exists wherever one side must not automatically accept the other's data, identity, decision or control. Boundaries appear when any of these changes:

- identity or issuer;
- tenant or owner;
- process, host, namespace or account;
- network or protocol;
- privilege or administrative authority;
- persistent storage;
- third-party responsibility;
- data classification;
- build, deployment or backup control.

“Inside the network” is not one trust level. A compromised laptop, build runner and production database can share private addressing while requiring completely different authority.

### Attack surface, entry point and attack path

The **attack surface** is the set of reachable ways an actor can influence assets: APIs, ports, files, queues, identity flows, CI triggers, dependencies, support tools, admin consoles, backups and people.

An **entry point** is one interaction. An **attack path** chains conditions: steal a developer token → change workflow → obtain cloud identity → alter service policy → read data. Defending only the first public port misses management and delivery paths.

### Threat modeling and STRIDE

**Threat modeling** is structured reasoning about what can go wrong, why it matters, what you will do and how you will know. A useful model contains scope, assets, architecture, boundaries, actors, scenarios, decisions, requirements, evidence and review triggers.

STRIDE provides prompts:

- **Spoofing:** pretend to be another identity.
- **Tampering:** alter data, code, configuration or evidence.
- **Repudiation:** actions cannot be reliably attributed or disputed.
- **Information disclosure:** data reaches an unauthorized party.
- **Denial of service:** legitimate use is impaired.
- **Elevation of privilege:** obtain authority beyond the intended scope.

STRIDE does not score risk and is not a checklist of products. Ask it at each component and flow, then write concrete scenarios.

### Identity proofing, authentication and authorization

**Identification** is a claimed name. **Identity proofing** connects a real-world subject to a digital identity at enrollment. **Authentication** verifies possession/control of an authenticator and creates confidence in a subject. **Federation** lets one domain accept an assertion from another issuer.

**Authorization** evaluates whether a principal may perform an **action** on a **resource/object** under **context**. The safe unit is:

```text
subject + action + object + context -> allow or deny + reason
```

A JWT that decodes is not verified. A valid token is not authorization to every resource. A service account name is not proof of which workload holds it. An authenticated user can still exploit broken object-level authorization.

### Least privilege, separation of duties and break glass

**Least privilege** grants only required actions, resources, conditions and duration. It also asks what was actually used.

**Separation of duties** prevents one identity from creating, approving and hiding a high-consequence action. It is independent review, not merely two accounts controlled by one automation token.

**Break-glass access** is emergency authority. It should be strongly authenticated, narrowly scoped, time-bound, separately protected, automatically expired, heavily logged and reviewed. If the incident can disable break glass, it is not an independent containment path.

### Secret, key and certificate

A **secret** is information whose possession grants value or authority: password, token, API key or private key.

A **cryptographic key** has an algorithm, purpose and lifecycle. Symmetric keys encrypt and decrypt with shared secret material. An asymmetric key pair separates private operation from a distributable public key.

A **certificate** binds a public key to identity claims under an issuer and validity policy. It is normally public. The private key is secret. Replacing a certificate is not automatically rotating the private key; rotating a key is not automatically revoking every token or decrypting/re-encrypting old data.

### Encryption and hashing

**Encryption** transforms plaintext into ciphertext under a key so authorized parties can recover it. **In transit** describes protected communication between defined endpoints. **At rest** describes stored representation. Always name the plaintext boundaries: browser, proxy termination, application memory, log pipeline, database and backup restore.

A **hash** is a one-way digest used for integrity comparisons and specialized password storage designs. Encoding such as Base64 is not encryption. TLS authenticates endpoints according to certificate/trust configuration and protects the channel; it does not authorize the business operation.

### Segmentation, isolation and zero trust

**Segmentation** restricts which sources can reach which destinations and services. **Isolation** limits shared execution or resources. **Egress control** restricts outbound destinations, which matters for exfiltration and dependency compromise.

**Zero trust** means network location grants no implicit trust. Access is explicit, resource-specific, least-privilege and re-evaluated using identity and context. It does not mean “trust nobody,” buy one proxy, or eliminate availability design.

## Architecture map

### Begin with the user operation

Imagine a document service. A user uploads a private document, later retrieves it, and may create a time-limited share link.

Map the complete system:

```text
                            identity plane
                     +-----------------------+
                     | IdP -> sessions/tokens|
                     +-----------+-----------+
                                 |
untrusted       edge boundary    | app boundary         data boundary
browser ------> proxy/WAF -----> API -----> queue -----> worker
   |              |               |            |            |
   |              |               +------> metadata DB      +----> object store
   |              |                                            |
   +-- share link ----------------------------------------------+

delivery plane: source -> CI runner -> artifact -> deploy identity -> runtime
management plane: operator -> admin console/API -> policy/config/key changes
evidence plane: services -> protected collector -> detection -> responder
recovery plane: database/object backups -> restore identity -> recovery target
```

The main request path is only one part. A CI principal may alter the API. A storage administrator may bypass application checks. A backup may contain deleted documents. A log collector may receive secrets. A worker with a broad credential may ignore queue ownership.

### Annotate every flow

For every arrow record:

1. source and destination;
2. data and classification;
3. protocol and endpoint;
4. authenticating identity and issuer;
5. authorization decision and enforcement point;
6. validation and normalization;
7. encryption and plaintext termination;
8. timeout, retry and failure behavior;
9. logged decision and correlation;
10. owner and evidence source.

An unlabeled arrow hides assumptions. “API → object store” is not enough. Which workload identity? Which actions? Which bucket and prefix? Can it list? What endpoint? How long is the credential valid? What denies cross-tenant reads? Where is the decision logged? Who can change the policy?

### The security reasoning chain

```text
USER PROMISE
    |
    v
ASSET + OWNER + CLASSIFICATION
    |
    v
ACTOR + CAPABILITY + ENTRY + TRUST BOUNDARY
    |
    v
CONCRETE THREAT SCENARIO
    |
    v
LIKELIHOOD + IMPACT + UNCERTAINTY
    |
    v
AVOID / MITIGATE / TRANSFER / ACCEPT
    |
    v
TESTABLE REQUIREMENT + CONTROL OWNER
    |
    v
POSITIVE TEST + NEGATIVE TEST + TELEMETRY + RESPONSE
    |
    v
RESIDUAL RISK OWNER + REVIEW TRIGGER
```

If any link is missing, ask whether the tool choice has become detached from the business promise.

## Request or state path

### A legitimate document read

Trace one read as state transitions:

1. The user proves control of an authenticator to the identity provider.
2. The issuer creates a time-bounded session or assertion for an immutable subject.
3. The browser sends a request through a proxy. The proxy may authenticate transport or validate a token, but the application still owns business authorization.
4. The API normalizes the document identifier. Validation decides whether input is structurally acceptable; it does not decide ownership.
5. The API asks policy: may subject S perform `document.read` on object O in tenant T, given sharing and session context C?
6. The API uses its workload identity to query metadata. Database authority should be narrower than “read every row forever.”
7. If a worker is required, the queue assigns a job. The worker receives authority bound to the job and object rather than a shared bucket-wide key.
8. The object store enforces the service or capability policy.
9. Every boundary produces correlated decision evidence without logging tokens or document content.
10. The response returns only after the selected object and tenant are bound to the authorized decision.

### Authentication is not authorization

Use this table when debugging:

| Stage | Question | Typical evidence | Failure example |
|---|---|---|---|
| Proofing | Who was enrolled? | enrollment method, proofing assurance | fake identity enrolled |
| Authentication | Did the subject control an approved authenticator? | method, result, session ID | stolen/replayed credential |
| Assertion validation | Is issuer/signature/audience/time valid? | issuer, key ID, audience, expiry | token for another API accepted |
| Session | Is continued authority still valid? | age, device/context, revocation | disabled user keeps session |
| Authorization | May this action touch this object now? | policy version, decision, reason | user reads another tenant |
| Data enforcement | Did downstream authority preserve the decision? | service identity, query/object audit | service account bypasses tenant |
| Audit | Can action and outcome be reconstructed? | correlation, subject, object, outcome | only HTTP 200 recorded |

### Shared links are capabilities

A share link often behaves as a **bearer capability**: possession grants bounded authority. It may not authenticate the human holder. Therefore:

- use unguessable values generated with adequate randomness;
- store only a safe representation where possible;
- bind object and allowed method;
- choose an explicit expiry;
- support revocation;
- prevent referrer/log leakage;
- decide whether redistribution is accepted;
- rate-limit and observe use;
- never treat a link as owner identity.

### State path for a risk decision

A threat model also has state:

```text
identified -> analysed -> treatment selected -> owner assigned
           -> requirement implemented -> evidence reviewed
           -> residual risk accepted -> trigger monitored
           -> reopened after change/finding/incident/expiry
```

A spreadsheet row marked “mitigated” without test evidence is a status claim, not a demonstrated control.

## Failure zoom

### Scenario 1: cross-tenant object read

Signal: an authenticated user changes `accountId=123` to `accountId=124` and receives another customer's statement.

What probably did **not** fail: the login may be legitimate; TLS may be healthy; storage encryption may be working.

What failed: the server trusted a client-selected object or tenant without enforcing the authenticated subject's relation to that object. A broad service identity may amplify the flaw.

Safe response:

1. narrowly disable or guard the vulnerable operation;
2. preserve request, subject, session, policy, service identity, query and object evidence;
3. identify every equivalent path—API, export, cache, batch, support and direct datastore;
4. establish known and possible exposure, stating log blind spots;
5. implement server-side object policy and downstream least privilege;
6. test same-tenant allow and cross-tenant deny;
7. restore user success, detection and response routing.

### Scenario 2: compromised worker authority

Signal: object-store logs show a worker reading documents outside its queue jobs while availability dashboards stay green.

The dashboard is not wrong; it answers the wrong question. It shows service health, not confidentiality.

Contain with an independent identity/control plane. Stop new job leases or revoke the precise workload authority. Preserve token issuance, workload instance, queue lease, object access, deployment and admin changes. Recreating a container does not help if the same broad credential is mounted again.

Durable design:

```text
attested workload identity
        +
current queue lease
        +
short-lived capability {job, object, methods, expiry}
        +
object-store deny by default
        +
protected decision logs and anomaly detection
```

### Scenario 3: encryption is enabled at the wrong boundary

Suppose the browser uses TLS to a load balancer, which forwards plaintext over a shared network to the API. “HTTPS enabled” is true at one hop and misleading for the complete path.

Record every termination and re-encryption point. Identify certificate owner, peer name, trust store, protocol policy and plaintext exposure. Encryption cannot repair an authorized service exporting the wrong object, nor can it stop data copied into logs.

### Scenario 4: logs disappear during admin activity

Absence has at least four hypotheses:

- nothing happened;
- the action bypassed the instrumented path;
- collection failed;
- an actor altered or disabled evidence.

Protect logs separately from the service that creates them. Use synchronized time, controlled access, append-oriented or immutable storage appropriate to risk, retention, integrity verification and independent administrative audit. Do not log credentials or sensitive payloads merely to gain “visibility.”

### Scenario 5: the incident tool shares the failure domain

If a compromised cluster administrator can disable admission, logging and the revocation controller, the team has no trustworthy containment path inside that cluster.

Design an external or separately protected emergency authority. Exercise it. Record who can activate it, scope, duration, audit, rollback and what happens if the identity plane is degraded.

## Internals and state ownership

### Kernel and application authorization are different layers

Linux discretionary access control evaluates process credentials against object owner, group, mode bits and ACLs. Capabilities split some root powers. Namespaces change visibility; cgroups govern resources; seccomp and Linux security modules can constrain actions.

The application must still enforce tenant, account, document and workflow rules. A file owned by the API's Unix user may contain data for thousands of customers. Kernel read permission for the process says nothing about which authenticated customer may receive which row.

### Effective authority is a union of paths

For a principal, ask about:

- direct user/group grants;
- inherited roles and nested groups;
- resource policies;
- session/token scopes and conditions;
- service or workload identity;
- sudo and Linux capabilities;
- impersonation or role-assumption paths;
- CI/CD deployment authority;
- key/secret access;
- administrative and break-glass paths;
- network reachability and egress;
- cached sessions after revocation.

The visible role name may be narrow while another assumption path reaches administrator. Conversely, a wildcard can be constrained by conditions and resource denies. Evaluate the effective decision with positive and negative tests.

### Secret lifecycle

“Stored in a secret manager” covers one state. The full lifecycle is:

```text
generate -> classify -> store -> deliver -> use -> observe metadata
        -> rotate -> revoke -> remove copies -> verify denial/absence
```

Prefer short-lived identity-derived credentials over copied static secrets where the platform supports it. Never print a secret to prove it exists. Record secret identifier, version, owner, consumer, lease age and rotation outcome—not value.

After exposure:

1. assume copied value remains usable until revoked;
2. revoke or disable using a safe sequence;
3. scope observed use and possible reach;
4. rotate consumers;
5. remove from history, artifacts, caches and logs as governed;
6. prove old authority fails and replacement works;
7. repair the path that exposed it.

### Key lifecycle

For every key, record purpose, algorithm, boundary, owner, generation, activation, version, access, backup/recovery, rotation, revocation, archival and destruction.

Key availability and confidentiality pull in opposite directions. An unrecoverable storage key can turn a security control into permanent data loss. A widely copied recovery key defeats the trust boundary. Design quorum, separation of duties and restore tests appropriate to impact.

### Policy ownership and decision evidence

A policy has at least four identities:

1. source definition;
2. reviewed version;
3. deployed version;
4. version that made a specific decision.

Record the decision at the enforcement point. A repository rule proves intent; a runtime receipt ties one request to an observed policy. Keep enough context to explain allow or deny without leaking sensitive data.

## Evidence table

Security engineering becomes precise when every claim carries its boundary.

| Evidence | What it can support | What it cannot establish alone | Next correlation |
|---|---|---|---|
| Asset register with owner/classification | Declared value, accountability and handling expectation | Actual data location or correct handling | storage discovery, flows, backups |
| Architecture/data-flow diagram | Intended components, flows and trust changes at one version | Runtime truth or complete shadow paths | process, socket, config and telemetry inventory |
| Process and socket snapshot | Visible local execution and listeners at one time | External reachability, legitimacy or history | unit config, namespace, route, firewall |
| Identity authentication record | Observed authentication ceremony and asserted subject | Business entitlement to an object | session validation and authorization decision |
| Token signature/audience/time validation | Assertion was acceptable under chosen issuer policy | Holder is allowed this action or token was not stolen | subject-action-object policy and session context |
| Authorization decision log | One policy version allowed/denied one tuple | Every downstream path enforced it | service identity, query/object audit, response |
| IAM or RBAC policy source | Declared grants and denies | Effective policy, deployment or use | simulator/diff, runtime decision, access history |
| File mode and ACL | Visible discretionary filesystem policy | Application authorization, open copies or MAC policy | process credentials, LSM, negative test |
| TLS handshake | One client saw a negotiated protected channel and certificate result | Backend hops, application authorization or key safety | termination map, peer policy, app decision |
| Encryption configuration | Intended algorithm/key binding | Existing data is encrypted, key protected or restore possible | sample metadata, key audit, restore exercise |
| Firewall/network policy | Declared traffic rules | Correct attachment or observed enforcement | route/interface context and allow/deny probes |
| Vulnerability finding | Tool matched observed identity/version to knowledge at a time | Exploitability, reachability, compromise or completeness | asset, exposure, runtime and exception evidence |
| Patch deployment record | A change was attempted or declared | Every asset is fixed or behavior is healthy | inventory reconciliation, version observation, SLI |
| Application log | What one component reported | Truth, completeness, integrity or absence outside scope | identity, gateway, datastore and protected collector |
| SIEM alert | A rule matched ingested data | Incident truth, full scope or successful response | raw events, rule/version, owner acknowledgement |
| Backup success | Backup operation reported success | Restore, data integrity, key availability or isolation | clean-room restore and security verification |
| Negative authorization test | Represented prohibited action was denied | All objects, paths, identities and future versions deny | coverage map, policy identity, production canary |
| Incident timeline | Reconstructed ordered observations and decisions | Unobserved history is absent | source quality, clock alignment and stated gaps |

### Evidence strength has four dimensions

Ask:

1. **Identity:** which exact asset, principal, policy, artifact and environment?
2. **Time:** when was it observed, and how stale may it be?
3. **Scope:** which requests, hosts, tenants and paths were visible?
4. **Independence:** could the suspected component create, suppress or alter this evidence?

A production service declaring “I am uncompromised” is weak evidence if the service is suspected. An independently protected object-store audit record may be stronger. Independence is never absolute; document the authority chain.

### Logging is not detection

The flow is:

```text
event produced -> collected -> parsed -> retained -> query/rule evaluated
              -> alert created -> routed -> acknowledged -> action completed
```

Failure at any arrow creates a blind spot. A log line on disk does not mean the on-call engineer will receive an actionable signal.

## Command decoders

These commands teach evidence gathering on systems you own. A command is never a magic diagnosis. State the question before running it, preserve the relevant output, then write one sentence for “proves” and one for “does not prove.”

### 1. Processes and listening sockets

```bash
ps -eo user,pid,ppid,comm,args
ss -lntup
```

Decode `ps`:

- `-e` selects every process visible in the current PID namespace.
- `-o` chooses columns.
- `user` is the effective username shown for the process.
- `pid` is process ID; `ppid` is its parent.
- `comm` is the executable name; `args` is the command line and may be truncated or sensitive.

Decode `ss -lntup`:

- `-l` means listening sockets.
- `-n` keeps numeric addresses and ports, avoiding name-resolution confusion.
- `-t` is TCP; `-u` is UDP.
- `-p` asks for process ownership, which may be hidden without privilege.

Read the local address carefully. `127.0.0.1:8080` listens only on IPv4 loopback in that namespace. `0.0.0.0:8080` listens on all IPv4 addresses, but firewall, routing, container publication and upstream controls still decide reachability. `[::]:8080` is an IPv6 wildcard whose dual-stack behavior depends on system configuration.

If you find an unexpected listener, do not kill it immediately. Record PID, parent, executable path, unit/container, start time, owner and connection state. It might be malicious, obsolete, a monitoring sidecar or a business-critical undocumented service. Identification precedes remediation.

### 2. Current shell identity and creation mask

```bash
id
umask
```

`id` shows real/effective user identity and supplementary groups used for ordinary discretionary checks. Membership in groups such as container administration or privileged log readers may carry more authority than the name suggests.

`umask` is a bit mask removed from requested permissions when **new** filesystem objects are created. A common `0022` normally removes group/other write; `0077` removes all group/other permissions. It does not rewrite existing files, override an application's explicit post-creation change, or describe ACLs.

### 3. Path traversal and final-object modes

```bash
namei -l /path/to/file
stat -c '%A %a %U:%G %n' /path/to/file
```

`namei -l` resolves each path component and shows owner/mode. A user needs search/execute permission on directories to traverse them. A final file mode of `0600` is not useful protection if the content is copied elsewhere; and a permissive parent does not itself grant file read, though it affects discovery and traversal.

The `stat` format prints:

- `%A` symbolic permissions such as `-rw-r-----`;
- `%a` octal mode such as `640`;
- `%U:%G` owner and group;
- `%n` object name.

For a regular file, read/write/execute bits differ from directory semantics. On a directory, read lists names, write changes entries, and execute/search traverses. Sticky, setuid and setgid bits need separate interpretation.

### 4. ACLs beyond mode bits

```bash
getfacl -p /path/to/file
```

An ACL can grant named users/groups not visible in `ls -l`'s three basic classes. The ACL **mask** limits the effective permissions of named users, named groups and owning group. An entry may display `rwx` while an effective annotation shows less due to the mask.

If `getfacl` is absent, do not install packages automatically on a production host. Use an approved package path, image, management tool or alternate evidence source.

### 5. Service identity and systemd sandbox intent

```bash
systemctl show SERVICE \
  --property=User,Group,DynamicUser,NoNewPrivileges,ProtectSystem,ProtectHome,PrivateTmp,CapabilityBoundingSet
```

Replace `SERVICE` with a known unit. Important fields:

- `User`/`Group`: declared process identity;
- `DynamicUser`: whether systemd allocates a transient identity;
- `NoNewPrivileges`: prevents the process and descendants gaining privilege through exec mechanisms;
- `ProtectSystem`/`ProtectHome`: declared filesystem protections;
- `PrivateTmp`: isolated temporary directories;
- `CapabilityBoundingSet`: upper bound on capabilities the unit may acquire.

These are unit declarations. Reconcile with the running PID, effective credentials, namespaces, mounts, capabilities and negative behavior. Hardening a unit without knowing write paths can break availability, so test in a disposable or staged environment and preserve rollback.

### 6. One local TLS handshake

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername service.local \
  -verify_return_error </dev/null
```

- `-connect` selects the endpoint.
- `-servername` sends Server Name Indication and influences virtual-host certificate choice.
- `-verify_return_error` causes verification failure to matter rather than printing and continuing.
- redirecting standard input prevents an interactive wait.

Run only against an owned loopback service for this lesson. Read the verify return code, presented chain, subject alternative names, validity and negotiated protocol. A successful handshake proves one client path at one moment. It does not prove the load balancer-to-backend hop is encrypted or that the application will authorize a document read.

### 7. Host packet-filter policy

```bash
sudo -n nft list ruleset
```

`sudo -n` refuses instead of prompting for a password. This prevents an unattended command from hanging or encouraging credential entry. `nft list ruleset` requests the rules visible in the current network namespace.

Chains, hooks, priorities, connection tracking, interface matches and default policies all affect behavior. A rule that appears to allow TCP 443 may be preceded by a deny or apply to another interface. Host policy is only one layer alongside cloud security groups, hypervisor rules, container namespaces, Kubernetes policy, service mesh and application authorization.

### 8. Local addresses and routes

```bash
getent hosts localhost
ip route show
ip -brief address show
```

`getent` asks the system's configured name-service path rather than assuming only a hosts file or DNS. `ip route show` displays selected routing-table entries; `ip -brief address show` gives compact link/address state.

A route means the kernel knows a next-hop choice. It does not mean a firewall permits the flow, a remote service exists or TLS identity is correct. In containers and Kubernetes, run-from location matters because each network namespace may have different interfaces and routes.

### 9. Service journal sample

```bash
journalctl --since '-15 min' --no-pager -u SERVICE
```

- `--since` bounds the time window.
- `--no-pager` makes noninteractive output predictable.
- `-u` filters one systemd unit.

Look for structured correlation, stable subject (not secret), action, object class/reference, authorization decision/reason, workload identity and outcome. A raw HTTP status alone cannot distinguish intended and cross-tenant success. A log reader may itself have sensitive authority; access and exports require controls.

### 10. Linux capability evidence

```bash
getpcaps PID
grep -E '^(Uid|Gid|Cap(Inh|Prm|Eff|Bnd|Amb)|NoNewPrivs):' /proc/PID/status
```

Linux capabilities divide selected superuser powers. The process status sets include inherited, permitted, effective, bounding and ambient capabilities. Hexadecimal bitsets require mapping to the kernel's capability definitions. `NoNewPrivs: 1` is useful but not a complete sandbox.

Capabilities can be dangerous: network administration, raw sockets, process tracing, ownership bypass or broad discretionary-access bypass may materially expand impact. Never delete a capability from production simply because it looks powerful; prove whether the service needs it and test rollback.

### 11. Public certificate-file fields

```bash
openssl x509 -in certificate.pem -noout \
  -subject -issuer -serial -dates \
  -ext subjectAltName -ext keyUsage -ext extendedKeyUsage
```

This parses a public certificate, not a private key. Check:

- subject/issuer as identifiers, not sole authorization;
- Subject Alternative Name for service names;
- not-before/not-after with clock context;
- key usage and extended key usage for intended purpose;
- serial for lifecycle/audit correlation.

Then validate chain, trust anchor, revocation policy, deployed endpoint and key ownership. A certificate file on disk may not be the one currently served.

### 12. Offline decision model

```bash
bash verify.sh
```

The verifier runs baseline plus one negative case per gate, tests refusal of an unknown artifact and proves exact cleanup. It is intentionally deterministic. Passing means the teaching code behaves as declared—not that your host, application or organization is secure.

## Decision path

### Build a threat model in twelve passes

1. **Choose one operation.** “User retrieves a private document” is better than “model the whole cloud.”
2. **State the promise.** Only owner or an explicitly authorized share holder receives it; unauthorized attempts are denied and observable.
3. **Inventory assets and owners.** Include data, identities, policy, keys, code, logs and backups.
4. **Draw actual architecture.** Include data, identity, management, delivery, observability and recovery planes.
5. **Mark boundaries and assumptions.** Explain exactly what changes at each boundary.
6. **List actors by capability.** Anonymous user, tenant user, stolen session holder, compromised worker, developer, operator and identity administrator.
7. **Enumerate concrete scenarios.** Use STRIDE and ATT&CK as prompts, not conclusions.
8. **Assess likelihood, impact and uncertainty.** Write the evidence behind the rating.
9. **Choose treatment.** Avoid, mitigate, transfer or accept. Assign the business-capable owner.
10. **Write testable requirements.** Include behavior, scope, failure mode, evidence and lifecycle.
11. **Implement independent layers and response.** Plan prevention, detection, containment and recovery.
12. **Verify and schedule review.** Positive tests, negative tests, telemetry, response exercise, residual risk and triggers.

### A concrete threat register row

| Field | Example |
|---|---|
| Operation | Retrieve private document |
| Asset/outcome | Document content; confidentiality |
| Actor/capability | Authenticated tenant user who can alter request identifiers |
| Boundary | Browser-controlled identifier crosses into API/data authority |
| Scenario | API queries by supplied ID without binding owner tenant |
| Preconditions | Valid session and guessable/discovered identifier |
| Existing evidence | MFA and TLS; no object-decision event |
| Likelihood | Plausible: low complexity, exposed endpoint |
| Impact | High: cross-tenant disclosure and notification duties |
| Uncertainty | Historical logging cannot reconstruct every object |
| Treatment | Mitigate before release; restrict operation now |
| Requirement | Server derives tenant from verified subject and denies mismatch |
| Verification | same-tenant allow, cross-tenant deny, direct data-path deny |
| Owner/trigger | service product owner; reopen on data-path or sharing change |

Do not multiply arbitrary labels and call the result objective truth. A matrix is useful for consistency and discussion, provided uncertainty and assumptions remain visible.

### How to choose a control

For each threat ask:

- Does this control break a prerequisite, reduce reachable surface, constrain authority, make misuse visible, shorten containment, or improve recovery?
- Who operates it and who can bypass it?
- What happens when it fails or becomes unavailable?
- Which evidence proves deployment and exercised behavior?
- What new risk does it create?

Example: mTLS can authenticate workloads and protect transport. It does not decide whether worker A may read job B's object. Add job/object authorization. Short-lived credentials reduce exposure duration but can create dependency on issuer availability; define cached-session and outage behavior.

### Risk-treatment decisions

- **Avoid:** remove the risky feature/path. Example: do not support public share links.
- **Mitigate:** reduce likelihood or impact with controls.
- **Transfer/share:** use contract or insurance for part of financial consequence; technical and reputational risk usually remains.
- **Accept:** explicitly retain residual risk under accountable authority.

Acceptance needs scenario, evidence, uncertainty, business impact, owner, deadline/expiry and review triggers. “Team accepted” is weak if the team cannot own customer or regulatory consequences.

## Guided Ubuntu lab

### Safety boundary

The lab uses no target system. It creates:

```text
/tmp/reliability-atlas-les0071-security-<your-uid>/
├── .les0071
└── cases.json
```

It refuses root, common cloud/cluster/Docker authority variables, symlinks, wrong ownership and unknown files. It deletes only the exact two allowlisted files and then the exact state directory.

Enter:

```bash
cd drafts/LES-0071-security-foundations-threat-modeling/support/lab
bash lab.sh doctor
```

Expected:

```text
model=valid cases=36
doctor=pass network=none user=<your uid>
```

If the guard refuses an external-authority variable, open a clean Ubuntu shell for the lesson. Do not unset a work credential in a shell where you need it; isolation is safer than casual environment mutation.

### Setup and read the baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

The baseline returns `boundary=defensible`. That word is intentional. It does not say secure, compliant or invulnerable. It means every modeled question is true in synthetic input.

### Change one idea at a time

```bash
bash lab.sh evaluate scope-unknown
bash lab.sh evaluate boundary-unmapped
bash lab.sh evaluate object-check-missing
bash lab.sh evaluate logs-mutable-by-service
bash lab.sh evaluate containment-uses-compromised-plane
```

Expected boundaries are `scope`, `trust-boundaries`, `authorization`, `log-integrity` and `containment`.

Notice the ordering. In `object-check-missing`, authentication, TLS, storage encryption and logging remain true, yet the design stops at authorization. This prevents “we have encryption” from answering an unrelated failure.

### Prove refusal and cleanup

```bash
bash lab.sh inject-unknown
bash lab.sh status
```

Status must refuse the unknown artifact. Clear it through the explicit lab action:

```bash
bash lab.sh clear-unknown
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=36 refusal=true cleanup=true
```

### Turn the model into a real worksheet

For one local service, write answers without changing the host:

1. What user operation matters?
2. What asset and outcome are promised?
3. Which process, store and flow participate?
4. Where does identity, tenant, process, privilege or persistence change?
5. Which actor capability could violate the promise?
6. Which control makes that path harder?
7. Which event would let you detect it?
8. Which independent authority contains it?
9. Which positive and negative tests prove recovery?
10. Who owns remaining uncertainty and when is it reviewed?

Do not run probing or exploitation tools. This lesson teaches design and evidence. Later labs can use explicitly disposable, reviewer-owned targets.

## Production transfer

### Before touching production

Prepare:

- incident or change authority;
- exact account, cluster, namespace, host and service;
- known-good time window and timezone;
- read-only evidence role;
- secure evidence destination and retention;
- rollback and containment owner;
- customer/security/legal communication route;
- commands reviewed for secrets and output volume.

Do not paste tokens, private keys or sensitive payloads into a terminal transcript. Hashing a secret after displaying it is still disclosure.

### First 15 minutes of suspected unauthorized access

1. Open a timestamped incident record and name commander/technical lead/scribe as scale requires.
2. State the signal and confidence: “object audit reports worker X read object Y outside job Z.”
3. Freeze expansion: new rollout, token minting or affected operation.
4. Preserve volatile evidence that replacement would destroy.
5. Contain through separately protected authority at the smallest sufficient scope.
6. Confirm containment with a denied test or authoritative state—without replaying sensitive access.
7. Start a timeline of identity issuance, policy, workload, data access and changes.
8. State what is not observable.

Availability matters during containment, but unsafe availability is not success. Conversely, shutting down the entire company may be an avoidable second incident. Choose scope from asset impact and evidence.

### Investigation graph

```text
subject / workload identity
        |
authenticator, issuer, session, delegation
        |
gateway request and correlation
        |
application policy decision + version
        |
service identity and downstream authorization
        |
query / object / key use
        |
response outcome and customer effect
        |
deployment, config and administrator changes
```

Ask what each source knows independently. Align clocks. Preserve original event IDs and export metadata. Record transformations performed during analysis.

### Recovery is a security decision

Do not restore merely because error rate is normal. Prove:

- the compromised or excessive authority is revoked;
- replacement identity/config/code comes from trusted state;
- intended user operation succeeds;
- prohibited operation fails at each required boundary;
- data integrity and tenant isolation checks pass;
- telemetry records the test and reaches the owner;
- rollback remains possible;
- affected assets and people are addressed;
- residual uncertainty has accountable acceptance.

Backups must be isolated from the failure domain, protected by distinct authority where appropriate, and restored in exercises. Restoring vulnerable policy or compromised credentials recreates the incident.

### Communicating with leaders

Use four columns:

| Known | Unknown | Action | Decision needed |
|---|---|---|---|
| observed facts with source/time | evidence gaps and uncertainty | owner, scope and expected completion | risk or customer trade-off and accountable owner |

Avoid claiming “no data loss” when logs cannot see a path. Say: “No unauthorized reads are visible in sources A and B from time X; direct path C was not logged, so historical exposure remains uncertain.”

## Reliability, security, observability, capacity, and cost

### Reliability and security are coupled

Authentication, key, policy and logging systems can become critical dependencies. Fail-closed behavior protects assets but may block legitimate users. Fail-open behavior preserves availability but grants unsafe authority. There is no universal setting.

Design by action risk:

- low-risk read with a recent cached decision may degrade for a short bound;
- privilege elevation, new trust, money movement or key export should usually deny when authority is uncertain;
- emergency access needs separate authentication, narrow scope, expiry and audit;
- recovery must include identity/control-plane outage exercises.

Track security-control SLIs: decision availability/latency, credential issuance latency, revocation propagation, certificate time-to-expiry, audit delivery lag, detection delay, acknowledgement and containment time.

### Observability must answer decisions

Metrics show rates and states; logs show discrete events; traces connect flows; audits record security-relevant control actions. Build dashboards around questions:

- Are authorization denies rising by policy version and operation?
- Are cross-tenant negative canaries still denied?
- Is any workload using a deprecated identity?
- How old is the newest protected audit event?
- Did a test event reach the detector and responder?
- Can the team revoke a compromised identity within the target?

Avoid high-cardinality secrets or raw object IDs in metric labels. Use controlled identifiers and logs for detailed correlation.

### Capacity is part of security

Rate limits, policy engines, identity providers, KMS, log pipelines and revocation systems need capacity planning. Saturation may:

- turn authentication into outage;
- delay audit evidence;
- drop detections;
- create retry storms;
- force unsafe bypass;
- make containment too slow.

Budget peak legitimate use plus incident bursts. Bound queues, retries and timeouts. Decide whether audit backpressure blocks the operation, buffers safely or loses evidence—and make that a risk decision, not an accidental default.

### Cost is a constraint, not an excuse

Security cost includes engineering time, runtime latency, storage, log ingestion, key operations, on-call load and user friction. Optimize with risk:

- collect high-value decision evidence, not every payload;
- use lifecycle tiers for retention;
- reduce noisy detections before adding staff;
- prefer reusable platform guardrails and short-lived identity;
- measure unused privileges and controls;
- compare prevention cost with incident impact and recovery time.

Cheap but untested controls create false assurance. Expensive telemetry nobody can query creates storage cost, not response capability.

### Privacy and security can conflict

Logs useful for investigations can expose personal data. Apply minimization, purpose limitation, access control, retention, regional/contractual requirements and deletion policy. Pseudonymous identifiers can support correlation while limiting casual exposure, but they may still be personal data and require controlled re-identification.

## Traps and prevention

### Trap: security begins with a product

“Install a WAF/SIEM/vault/zero-trust product” skips the promised operation, threat and decision. The product may become an expensive control with no defined success.

**Prevention:** require every control proposal to name the threat scenario, affected asset, expected likelihood/impact change, owner, failure mode and verification.

### Trap: authentication means authorization

Strong MFA proves more about the login ceremony. It does not entitle the user to every object or action.

**Prevention:** centralize consistent decision semantics, enforce server-side subject-action-object-context policy at every path, and make cross-owner/cross-tenant negative tests release gates.

### Trap: private network means trusted

A compromised workload, administrator or CI identity may already be inside. Flat connectivity expands discovery, movement and exfiltration.

**Prevention:** authenticate workloads, authorize resources, segment by required flow, restrict egress, log decisions and test denies. Network policy is defense in depth, not object ownership.

### Trap: encryption solves confidentiality

Encryption protects specified representations and paths under key control. An authorized-but-overbroad service can decrypt and disclose; plaintext may enter memory, logs, caches or backups.

**Prevention:** map termination/plaintext boundaries, implement authorization and minimization, manage keys, protect observability, and test restore.

### Trap: a valid certificate means the service is safe

A valid chain can authenticate a name under one trust policy. It says nothing about application authorization, code integrity or business behavior.

**Prevention:** validate name, chain, usage, time and revocation as applicable, then independently authorize the operation.

### Trap: rotate after every incident without scoping

Broad rotation may cause outage and still miss sessions, derived tokens, replicas or the original weakness.

**Prevention:** identify authority type and propagation, revoke affected authority, enumerate derived/cached state, rotate consumers safely, prove old denial and repair exposure path.

### Trap: vulnerability severity equals risk

Severity lacks your exposure, asset value, exploitability, control evidence and operational impact.

**Prevention:** bind finding to exact inventory, data age, reachable path and owner. Prioritize with threat intelligence and business impact; time-bound exceptions.

### Trap: logs equal observability and detection

A service may log only status, the collector may drop events, the rule may be disabled, or the alert may route nowhere.

**Prevention:** start with investigation questions, design structured events, protect integrity, monitor pipeline freshness and inject safe test events through alert acknowledgement and action.

### Trap: deleting the suspicious workload is containment

Deletion can destroy volatile evidence; controllers may recreate the same compromised image, identity and policy.

**Prevention:** stop authority and reconciliation at trustworthy boundaries, preserve needed evidence, deny compromised identities/artifacts, then replace from known-good state.

### Trap: “zero trust” means blocking everything

Zero trust removes implicit network trust; it still needs usable, available, explicit policy. Overly broad fail-closed changes can create self-inflicted outages and emergency bypasses.

**Prevention:** classify operations by consequence, model dependencies and cached decisions, rehearse degraded modes and maintain narrow audited break glass.

### Trap: a threat model is finished

Architecture, actors, dependencies and evidence change. A stale diagram creates confidence in a system that no longer exists.

**Prevention:** tie review to new data flows, identity changes, internet exposure, privilege changes, vendors, major releases, incidents, vulnerability classes, control failures, exception expiry and a maximum calendar interval.

### Trap: compliance is security

A control catalog helps organize requirements; an audit provides scoped assurance. Neither guarantees that a specific user cannot retrieve another tenant's record today.

**Prevention:** map compliance evidence to live threat scenarios and technical tests. State the exact period, population, sampling and limitation.

### Trap: security owns all risk

Security specialists can analyze and advise, but product and business leaders own many consequences and trade-offs.

**Prevention:** assign owners who can fund remediation, change the product, accept impact and communicate externally. Give engineers clear escalation paths.

## Memory card and retrieval

### The core chain

```text
promise -> asset -> owner -> actor -> boundary -> threat
        -> risk -> requirement -> control -> evidence
        -> detect -> contain -> recover -> residual owner -> review
```

### The access equation

```text
proofing != authentication != authorization

authorize(
  subject,
  action,
  object,
  context,
  policy_version
) -> decision + reason
```

### The four evidence questions

1. Which exact identity?
2. At what time?
3. Over what scope?
4. Independent from which failure?

### The response mnemonic

**PACE:** Pause expansion, Acquire evidence, Contain independently, Establish scope and recovery proof.

### Five instant corrections

- “TLS is enabled.” → Between which endpoints, under which peer identity and trust?
- “The user is logged in.” → Which action on which object is authorized now?
- “The scanner is green.” → What was scanned, with which coverage and data time?
- “No alerts.” → Was an event produced, ingested, detected, routed and acted on?
- “Recovery succeeded.” → Did intended use work and prohibited use fail from trusted state?

### Retrieval drill

Without looking back, answer:

1. What changes at a trust boundary?
2. Why can authentication succeed while confidentiality fails?
3. What does TLS prove and not prove?
4. Which four fields make an authorization decision specific?
5. Why should containment authority be independent?
6. Which two tests are always needed after a security repair?
7. What turns residual risk into a governed decision?

If you cannot answer one in a minute, revisit its section and explain it aloud using your own service.

## Complete answers

### 1. What is a trust boundary, in practical language?

A trust boundary is a point where you must stop accepting a claim merely because the previous component supplied it. The browser supplies a document ID, but the API must not trust that the user owns it. The API supplies a tenant claim to the database, but the data layer may add independent row/prefix constraints. A CI job presents a cloud assertion, but the cloud policy verifies issuer, subject, audience and allowed repository/workflow.

Mark a boundary when identity, tenant, process, host, privilege, protocol, persistence, owner, administrator or external responsibility changes. Then name what is validated, authenticated, authorized, logged and done on failure.

### 2. What exactly is the difference between authentication and authorization?

Authentication asks: “How much confidence do I have that this request represents subject S?” Authorization asks: “May subject S perform action A on object O under context C?”

Example: a bank customer correctly completes MFA. Authentication succeeds. If the API accepts any account number in the URL and returns another customer's statement, authorization fails. More MFA cannot repair missing object ownership. Fix the server-side decision and downstream data authority.

### 3. Is an API token an identity?

A token is an assertion or capability represented by bytes. Its meaning depends on type and validation. For a signed bearer access token, the resource may validate issuer, signature, audience, time and other claims, then map a subject and scope. Possession may be enough to use it, so theft matters.

The token is not the human or workload itself. It can be replayed, delegated, over-scoped, expired, revoked or intended for another audience. Avoid logging it. Record safe identifiers and validation/decision metadata.

### 4. What does least privilege look like beyond “remove admin”?

Least privilege covers:

- principal: one human/workload, not a shared account;
- actions: exact read/write/list/approve operations;
- resources: tenant, namespace, repository, bucket prefix or object;
- conditions: source workflow, device, network, tags, job lease or approval;
- duration: short session rather than permanent grant;
- delegation: whether it can mint or assume more authority;
- separation: who can request, approve and audit;
- evidence: actual use, denials, review and revocation test.

Removing `admin` while granting `*:*` through another role is not least privilege. A narrow role never used may still be unnecessary. Review effective paths and observed legitimate use, then test a prohibited action.

### 5. If disk encryption is enabled, is stored data safe?

Disk encryption can protect media or snapshots when the decryption key is unavailable to the attacker. While the system is running, applications and privileged identities may read plaintext. Backups, replicas, exports and logs may use different keys or no encryption. Key loss can make recovery impossible.

Ask which data, at which layer, under which key, where the key lives, who can use it, where plaintext appears, how rotation/revocation works and whether a clean restore succeeds.

### 6. What should be deleted when a secret leaks?

First revoke or disable the authority safely; deleting text does not invalidate copies. Determine secret type, owner, consumers, privileges, issuance and use. Rotate consumers, invalidate derived sessions where applicable, remove exposed copies according to repository/log/artifact retention processes, and prove the old credential is denied.

Do not rewrite shared history blindly during an incident. Coordinate because destructive history rewriting can disrupt teams and still leave forks, caches and artifacts. Repair why the secret was created, delivered or logged.

### 7. What does network segmentation actually buy?

Segmentation removes unnecessary reachable paths and limits movement/exfiltration. A worker that needs object storage on 443 may not need database, identity admin and internet-anywhere access. A default-deny policy makes new flows explicit.

It does not prove workload identity, authorize a business object, fix vulnerable code or protect traffic through an allowed path. Validate policy attachment and actual allow/deny behavior from the correct namespace.

### 8. How do I know logging is sufficient?

Begin with incident questions. For unauthorized document access:

- Which human/workload identity?
- Which session, issuer and delegation?
- Which action and normalized object/tenant?
- Which policy/version decided, and why?
- Which downstream identity/query/object access occurred?
- What response/outcome reached the user?
- Which deployment/config/admin change was active?

Then inject a safe test event. Prove it is generated, collected, parsed, retained, detected, alerted, routed, acknowledged and actionable. Protect integrity and privacy. Document paths not covered.

### 9. Should security controls fail open or fail closed?

Neither universally. Decide by consequence and freshness.

New privilege, money movement, key export or cross-tenant access should normally deny when authority cannot be established. A low-risk operation may temporarily use a recent cached decision if the business explicitly accepts revocation delay and the cache is bound by identity, resource, policy version and age.

Test dependency failure. Define which operations degrade, maximum duration, monitoring, who can invoke emergency access, and how normal authority is restored without leaving a bypass.

### 10. What is defense in depth?

Defense in depth places independent controls across different prerequisites and impact paths. For a worker:

- reviewed code and secure defaults reduce defects;
- workload identity limits impersonation;
- per-job authorization limits object access;
- short credentials reduce exposure time;
- network/egress policy limits reachable destinations;
- encryption protects defined transport/storage boundaries;
- protected audit and detection reveal misuse;
- independent revocation shortens containment;
- isolated backups and tested restore reduce recovery impact.

Ten controls administered by the same compromised identity are less independent than they look. Explicitly map bypass authority and shared failure domains.

### 11. How do I distinguish a vulnerability from an incident?

A vulnerability is a weakness that may be exploitable. An incident is an event that jeopardizes or violates security policy/outcomes and requires response. A critical finding is not proof of exploitation. An unexpected data read can be an incident even without a published CVE.

For the finding, bind exact asset/version, reachability, prerequisites, exploitability, existing controls and impact. For suspected exploitation, preserve behavioral, identity, data and change evidence. Patch urgency and incident containment can proceed in parallel but answer different questions.

### 12. What proves recovery after an authorization breach?

At minimum:

1. affected authority is revoked or constrained;
2. fixed policy/code/config identity is deployed from trusted state;
3. authorized user action succeeds;
4. unauthorized cross-object/cross-tenant action fails;
5. downstream service/data policy also enforces the boundary;
6. the test produces protected decision evidence and detection reaches its owner;
7. known exposure and evidence gaps are documented;
8. rollback and containment remain available;
9. residual risk is accepted by an accountable owner;
10. the threat model and regression suite include the failure.

Normal latency and HTTP 200 are necessary availability evidence, not proof of restored confidentiality.

## Product-company interview

### The answer structure senior interviewers can trust

When asked to secure or diagnose a system, do not list products. Use:

1. **Clarify operation and consequence.**
2. **Map data/control/identity/delivery/recovery paths.**
3. **Name assets, actors, boundaries and assumptions.**
4. **Prioritize concrete threat scenarios.**
5. **Create testable requirements and independent controls.**
6. **Explain evidence, failure modes and trade-offs.**
7. **Handle incident containment and recovery.**
8. **Own residual risk and review.**

This shows systems thinking, not memorization.

### Interview question: “How would you secure a multi-tenant API?”

A strong answer begins:

> I would first define tenant-isolation promises and every access path. I would authenticate humans and workloads separately, derive stable tenant context from verified identity rather than client input, and authorize each subject-action-object tuple server-side. The API identity and datastore would have bounded tenant/resource authority, with separate time-bound support break glass. I would test same-tenant allow, cross-tenant deny, direct-path deny, stale-role deny and revocation. Decision logs would correlate subject, object, tenant, policy and outcome without payloads. Network segmentation, TLS and encryption are independent layers, not substitutes for object authorization. Recovery includes exposure scoping, trusted deployment, positive/negative proof and owned blind spots.

Then discuss cache isolation, batch/export paths, administrative boundaries, rate limiting, availability of identity/policy dependencies and migration.

### Interview question: “A certificate expired. What do you do?”

Separate:

- Is the endpoint reachable?
- Which certificate is actually served?
- Does chain validation fail, or only name/time/usage?
- Is the private key matched and protected?
- Did renewal create new material but reload fail?
- Which clients/trust stores are affected?
- Is mTLS involved on either direction?

Restore with known-good, approved material or correct deployment; do not disable verification. Confirm from client paths, monitor expiry/renewal/reload, test rotation before the emergency and preserve rollback.

### Interview question: “How do you design security logging?”

Start with response questions and high-consequence decisions. Define event schema, stable correlation, subject/action/object/context, policy/version, decision/reason and outcome. Protect time, transport, integrity, access and retention; minimize personal data and secrets. Monitor collector lag/drop. Create detection with owner, route and runbook, then inject test events end to end.

### Interview question: “What is zero trust?”

Answer:

> It is an architecture principle that removes implicit trust based on network location. Each resource access uses explicit subject/workload identity, resource/action context, least privilege and ongoing policy evaluation. It includes telemetry and revocation, while retaining availability and emergency design. A private subnet or proxy alone is not zero trust.

Give a workload example: service identity plus job-bound object authorization plus network policy, with short sessions and decision logs.

### Interview question: “How do you prioritize 10,000 vulnerabilities?”

Do not say “by CVSS only.” Normalize asset and component identity, eliminate coverage errors, then combine:

- asset criticality and data;
- production/deployment presence;
- exposure and reachable path;
- exploit prerequisites and known exploitation;
- privilege and lateral-movement potential;
- compensating-control evidence;
- remediation/rollback risk;
- scanner/database time and confidence;
- business owner and deadline.

Critical active exploitation on exposed infrastructure needs incident-style action. Lower severity authorization or identity weaknesses may outrank higher disconnected findings. Exceptions expire and reopen on new evidence.

### Interview question: “Security wants fail closed; SRE wants availability. Who wins?”

The premise is weak. The user/business owns outcomes; engineering and security quantify consequence. Classify operations and decide degraded behavior before failure. Protect high-consequence new authority with deny. Permit only explicitly accepted, bounded cached behavior for eligible operations. Instrument the control SLI, revocation freshness and user SLI. Rehearse identity/policy outage and narrow break glass. Make the trade-off an owned design, not an argument during outage.

### Signals of a weak answer

- starts with vendor names;
- treats network as identity;
- says MFA prevents authorization flaws;
- promises “100% secure”;
- omits management/CI/backup planes;
- patches before preserving evidence;
- deletes a Pod as containment;
- says no logs means no incident;
- ignores rollback and legitimate-user success;
- accepts risk without owner, expiry or trigger.

## Independent transfer and rubric

### Assignment boundary

Use assessment `ASM-0198` only on reviewer-owned disposable local infrastructure with synthetic data. The learner must not know where the two injected faults are. No public target, real credential, customer data, production system or destructive attack tool is permitted.

The learner chooses an unfamiliar multi-component service and must:

- define user promises and scope;
- inventory assets/owners/classification;
- map data, identity, management, delivery, evidence and backup planes;
- identify trust boundaries and actor capabilities;
- produce at least twelve concrete scenarios;
- prioritize risk with uncertainty and ownership;
- write at least eight testable requirements;
- implement or validate layered controls;
- design six investigation questions and detection evidence;
- diagnose one identity/authorization fault and one detection/containment fault;
- contain independently and preserve evidence;
- prove intended allow and prohibited deny;
- update the model and clean every artifact.

### Scoring

| Area | Points | Required observable evidence |
|---|---:|---|
| Scope, promises and assets | 10 | bounded operations, non-goals, classifications and accountable owners |
| Architecture and boundaries | 10 | accurate multi-plane diagram and explained trust changes |
| Threat discovery | 10 | capability-based, system-specific scenarios with meaningful coverage |
| Risk reasoning | 10 | evidence, likelihood, impact, uncertainty, treatment and trigger |
| Requirements and controls | 10 | testable behavior and independent layered design |
| Identity/authorization diagnosis | 10 | exact failed decision boundary and safe correction |
| Observability/detection | 10 | test event through protected telemetry, rule, route and action |
| Incident execution | 10 | narrow containment, preserved evidence, timeline and honest scope |
| Recovery/prevention | 10 | intended success, prohibited failure, trusted state and model update |
| Reproducibility/cleanup | 10 | machine-readable evidence and reviewer-confirmed absence |

Minimum scoring is not mastery by itself. A reviewer must confirm evidence, safety and reasoning. Any production/public target, real-secret exposure, destructive unapproved action, fabricated evidence or incomplete cleanup is a stop condition.

### What the reviewer must withhold

The independent assessment intentionally contains no model answer. The reviewer privately selects faults, expected safety boundaries and cleanup inventory. Hints reduce the evidentiary strength and must be recorded. Repeating the guided fixture is practice, not independent transfer.

### Delayed retrieval

After at least several days, the learner should receive a different architecture and explain, without notes:

- promise-to-risk chain;
- authentication versus authorization;
- encryption and plaintext boundaries;
- independent containment;
- positive and negative recovery proof;
- residual-risk ownership.

Mastery requires transfer to a changed situation, not recognition of familiar wording.

## References and review

### Primary and official sources

- `REF-0823` — [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html): decomposition, flows, boundaries, threat identification, response and maintenance.
- `REF-0824` — [NIST Cybersecurity Framework 2.0](https://www.nist.gov/publications/nist-cybersecurity-framework-csf-20): Govern, Identify, Protect, Detect, Respond and Recover outcomes.
- `REF-0825` — [NIST SP 800-30 Rev. 1, Guide for Conducting Risk Assessments](https://csrc.nist.gov/pubs/sp/800/30/r1/final): threat events, vulnerabilities, likelihood, impact and uncertainty.
- `REF-0826` — [NIST SP 800-53 Rev. 5](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final): customizable security and privacy control families; not a universal implementation checklist.
- `REF-0827` — [NIST SP 800-63 Revision 4 Digital Identity Guidelines](https://pages.nist.gov/800-63-4/): identity proofing, authentication, federation, assurance, privacy and usability.
- `REF-0828` — [RFC 9700, OAuth 2.0 Security Best Current Practice](https://www.rfc-editor.org/rfc/rfc9700): current OAuth threat and protocol guidance.
- `REF-0829` — [NIST SP 800-207, Zero Trust Architecture](https://csrc.nist.gov/pubs/sp/800/207/final): explicit resource access without implicit network-location trust.
- `REF-0830` — [NIST SP 800-207A, Cloud-Native Access Control](https://csrc.nist.gov/pubs/sp/800/207/a/final): service identities and network-tier policy in cloud-native multi-cloud systems.
- `REF-0831` — [RFC 8446, TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446): normative authenticated confidential transport behavior.
- `REF-0832` — [NIST SP 800-57 Part 1 Rev. 5](https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final): key types, protection, lifecycle and compromise; Revision 6 remained draft at review.
- `REF-0833` — [NIST SP 800-92, Guide to Computer Security Log Management](https://csrc.nist.gov/pubs/sp/800/92/final): collection, protection, storage and analysis; this 2006 final publication has an active draft revision, so age is a limitation.
- `REF-0834` — [NIST SP 800-61 Rev. 3](https://csrc.nist.gov/pubs/sp/800/61/r3/final): current incident response integrated with CSF 2.0 risk management.
- `REF-0835` — [MITRE ATT&CK Enterprise Matrix](https://attack.mitre.org/matrices/enterprise/): maintained observed adversary behaviors used as discovery/detection input, not a risk score.
- `REF-0836` — [CIS Critical Security Controls v8.1](https://www.cisecurity.org/insights/white-papers/cis-critical-security-controls-v8-1): prioritized safeguards and implementation groups.
- `REF-0837` — [OWASP Application Security Verification Standard 5.0.0](https://owasp.org/www-project-application-security-verification-standard/): versioned testable application-security requirements.

### Source-use boundary

Standards and control catalogs organize thinking. They do not prove this lesson, a local lab or a production system is secure. Implementation details change by version and environment. Verify current normative text and product documentation before production use.

### Review record

This substantive candidate was reviewed against the sources above on 2026-08-07. Re-review is due by 2027-02-07 or earlier if:

- a cited standard is revised;
- identity, OAuth, TLS or key guidance changes;
- the lesson architecture, model or assessments change;
- a new relevant threat class or incident invalidates an assumption;
- the Ubuntu/Python support contract changes;
- formal reviewer or learner evidence reveals ambiguity.

Publication does not award mastery. Representative control evidence, formal security review, independent transfer, delayed recall and learner evidence remain outside this source-only candidate.
