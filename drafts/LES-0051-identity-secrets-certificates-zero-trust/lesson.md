---
{"schemaVersion":1,"kind":"lesson","id":"LES-0051","slug":"identity-secrets-certificates-zero-trust","aliases":["V05-L15","identity-secrets-certificates-zero-trust"],"curriculumIds":["IAM-001"],"route":"/book/infrastructure/identity-secrets-certificates-zero-trust","order":15,"volume":"05-infrastructure-platforms","title":"Identity, secrets, certificates, keys, and zero trust","summary":"Trace human and workload identity from proof through federation, token validation, authorization, secret and key lifecycle, certificate trust, audit, revocation, and zero-trust policy decisions.","domain":"infrastructure","level":{"from":"foundation","to":"expert"},"estimatedMinutes":540,"prerequisiteLessonIds":["LES-0012","LES-0015","LES-0045","LES-0050"],"prerequisiteCurriculumIds":["LNX-004","NET-006","K8S-005","CLD-001"],"testedEnvironments":[{"platform":"NIST digital identity and zero trust guidance","version":"SP 800-63B-4 final and SP 800-207 final","support":"supported","notes":"Reviewed 2026-08-04."},{"platform":"IETF and OpenID specifications","version":"RFC 9700, RFC 8446, RFC 5280, RFC 8555 and OpenID Connect Core","support":"supported","notes":"Protocol and PKI sources reviewed 2026-08-04."},{"platform":"AWS Azure Google Cloud Kubernetes SPIFFE Vault guidance","version":"current official documentation","support":"concept-only","notes":"Federation, workload identity and credential lifecycle sources reviewed 2026-08-04; no credentials used."},{"platform":"Ubuntu","version":"24.04 local normal-user model","support":"required","notes":"Deterministic identity decision model; not an identity provider, CA, KMS or secrets manager."}],"targetRoles":["platform-engineer","site-reliability-engineer","devops-engineer","cloud-engineer","security-engineer","kubernetes-engineer","solutions-architect","technical-lead"],"learningObjectives":["Separate identification, identity proofing, authentication, federation, token issuance, authorization and audit.","Distinguish users, groups, roles, policies, sessions, service accounts and workload identities.","Validate issuer, subject, audience, time, signature, nonce and authorization context without treating JWT decoding as verification.","Prefer short-lived federated credentials over copied long-lived keys and design safe break-glass.","Apply least privilege with explicit resource/action/condition scope and negative tests.","Design secret discovery, storage, delivery, rotation, revocation and leak response.","Explain private keys, public keys, certificates, trust anchors, chains, names, validity and revocation.","Separate encryption keys from certificates and manage key generation, use, rotation, recovery and destruction.","Apply zero-trust decisions per resource and session rather than trusting network location.","Diagnose denials and compromises from identity-chain evidence without weakening controls blindly."],"productionSignals":["principal immutable ID type issuer tenant and lifecycle owner","authentication method assurance device/session context and MFA result","federation issuer metadata JWKS trust audience subject mapping and token exchange","token ID hash only issuance expiry not-before audience scope session and revocation state","authorization request principal action resource condition policy version decision and reason","role assumption or impersonation chain source identity session tags and duration","secret identifier version lease age consumer delivery path rotation and revocation without value","certificate serial issuer subject alternative names chain usage validity and revocation status","key identifier purpose algorithm boundary version rotation state and cryptographic operation audit","break-glass approver scope duration session recording and automatic expiry","identity/control-plane availability latency throttling cache age and fail-closed/degraded decision","denied and allowed user/workload transactions correlated to audit and user SLI"],"diagrams":[{"id":"LES-0051-DIA-001","title":"Identity decision path","direction":"left-to-right","boundaries":["subject","authenticator","identity provider","token or assertion","policy engine","resource","audit"],"evidencePoints":["assurance","issuer","claims","decision","outcome"],"textAlternative":"A subject proves identity to an issuer; a resource validates the assertion and independently authorizes one action before recording the outcome."},{"id":"LES-0051-DIA-002","title":"Human and workload federation","direction":"hierarchical","boundaries":["enterprise IdP","human session","CI OIDC issuer","runtime workload identity","security token service","target roles"],"evidencePoints":["immutable subject","audience","conditions","session duration","delegation chain"],"textAlternative":"Humans and workloads use distinct trusted issuers and short-lived exchanges into narrowly scoped target roles."},{"id":"LES-0051-DIA-003","title":"Authorization evaluation","direction":"left-to-right","boundaries":["principal","action","resource","context","allow and deny policies","decision"],"evidencePoints":["effective policy","explicit deny","condition","reason"],"textAlternative":"Authorization evaluates a specific principal-action-resource-context tuple, including inherited and explicit denies."},{"id":"LES-0051-DIA-004","title":"Secret lifecycle","direction":"cyclic","boundaries":["create","store","deliver","use","observe","rotate","revoke","destroy"],"evidencePoints":["version","lease","consumer","audit","absence"],"textAlternative":"A secret is controlled across creation, delivery, use, rotation, revocation and verified removal rather than merely encrypted at rest."},{"id":"LES-0051-DIA-005","title":"Certificate trust path","direction":"hierarchical","boundaries":["trust anchor","intermediate CA","leaf certificate","name and usage","private key holder","TLS peer"],"evidencePoints":["chain","SAN","validity","key usage","revocation"],"textAlternative":"A relying party validates a leaf certificate through name, usage, time and chain constraints to a configured trust anchor while the private key remains separate."},{"id":"LES-0051-DIA-006","title":"Zero-trust session loop","direction":"cyclic","boundaries":["request","subject/device/workload context","policy decision","least-privilege session","telemetry","re-evaluation","revocation"],"evidencePoints":["resource","risk","session age","behavior","deny"],"textAlternative":"Access is a resource-specific, time-bounded decision that is observed and re-evaluated rather than inherited from network location."}],"commands":[{"id":"LES-0051-CMD-001","question":"Is the offline identity case valid JSON?","risk":"read-only","command":"python3 -m json.tool fixtures/cases.json >/dev/null","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"exit zero","meaning":"syntax is valid","nextEvidence":"shape and semantic validation"},{"when":"nonzero","meaning":"case cannot be trusted","nextEvidence":"fix first parse error"}],"proves":"JSON syntax","doesNotProve":"identity safety"},{"id":"LES-0051-CMD-002","question":"Which principal, issuer, audience, action and resource are under review?","risk":"read-only","command":"python3 model.py show fixtures/cases.json baseline","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"normalized tuple prints","meaning":"decision inputs are bound","nextEvidence":"evaluate"},{"when":"refusal","meaning":"input contract invalid","nextEvidence":"inspect reason"}],"proves":"model input identity","doesNotProve":"real token or policy"},{"id":"LES-0051-CMD-003","question":"Does the baseline satisfy token and least-privilege constraints?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json baseline","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"decision=allow","meaning":"encoded checks pass","nextEvidence":"negative cases"},{"when":"decision=deny","meaning":"one encoded boundary fails","nextEvidence":"first reason"}],"proves":"deterministic policy result","doesNotProve":"provider authorization"},{"id":"LES-0051-CMD-004","question":"Would an expired token be rejected?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json expired-token","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at token-time","meaning":"expiry guard works","nextEvidence":"clock and refresh behavior"}],"proves":"encoded expiry denial","doesNotProve":"real verifier clock"},{"id":"LES-0051-CMD-005","question":"Would a token for another audience be rejected?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json wrong-audience","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at audience","meaning":"confused-deputy guard works","nextEvidence":"issuer and subject mapping"}],"proves":"encoded audience denial","doesNotProve":"real exchange configuration"},{"id":"LES-0051-CMD-006","question":"Is the requested permission broader than the workload contract?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json overbroad-role","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at authorization-scope","meaning":"least-privilege negative test works","nextEvidence":"narrow resource/action"}],"proves":"encoded scope denial","doesNotProve":"all escalation paths"},{"id":"LES-0051-CMD-007","question":"Can a leaked static credential remain accepted?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json leaked-static-secret","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at credential-lifecycle","meaning":"static/leaked credential is refused","nextEvidence":"revoke and trace consumers"}],"proves":"encoded leak response","doesNotProve":"secret removed from history"},{"id":"LES-0051-CMD-008","question":"Is an expired certificate caught before handshake trust?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json stale-certificate","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at certificate-validity","meaning":"validity guard works","nextEvidence":"chain name usage and renewal"}],"proves":"encoded certificate-time denial","doesNotProve":"X.509 path validation"},{"id":"LES-0051-CMD-009","question":"Does disabled identity override a still-valid session?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json revoked-identity","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at identity-lifecycle","meaning":"revocation state wins","nextEvidence":"session/token invalidation latency"}],"proves":"encoded identity denial","doesNotProve":"real propagation"},{"id":"LES-0051-CMD-010","question":"What happens after a signing or encryption key compromise?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json key-compromise","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"deny at key-state","meaning":"compromised key is refused","nextEvidence":"rotate trust and bound affected data/tokens"}],"proves":"encoded key-state denial","doesNotProve":"cryptographic containment"},{"id":"LES-0051-CMD-011","question":"Can identity-control-plane loss degrade safely?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json identity-outage","runFrom":"LES-0051 support/lab","expectedBranches":[{"when":"bounded existing session only","meaning":"encoded policy separates existing from new access","nextEvidence":"cache age and revocation risk"}],"proves":"modelled outage decision","doesNotProve":"IdP or resource behavior"},{"id":"LES-0051-CMD-012","question":"Does the guarded Ubuntu verifier cover eight cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0051 support/lab as normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"cases refusals and cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic local teaching model","doesNotProve":"IdP OAuth OIDC PKI KMS secrets manager or production runtime","cleanup":"Verifier proves exact UID-scoped temporary root absent."}],"labs":[{"id":"LES-0051-LAB-001","title":"Guided identity-chain decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python; no real credential","timeMinutes":180,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","eight synthetic identity cases with no secret values"],"abortConditions":["root","network","credential environment","real token","private key","cloud session","symlink","unknown artifact"],"recovery":"Preserve first failed boundary, correct only copied synthetic case and rerun.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0051-identity-secrets-certificates-zero-trust/support/lab"},{"id":"LES-0051-LAB-002","title":"Independent federation and credential-lifecycle transfer","mode":"independent","environment":"Reviewer-owned local identity simulator and disposable synthetic service","timeMinutes":240,"privilege":"normal user; reviewer owns trust configuration","network":"loopback only","changes":["synthetic issuer and workload subjects","short-lived sessions","least-privilege policy","synthetic certificate and secret metadata"],"abortConditions":["real identity","real secret","public endpoint","production","long-lived copied key","unscoped administrator","unreviewed trust anchor"],"recovery":"Revoke synthetic identity/session, rotate disposable material, prove denied old access and allowed replacement under narrower policy.","cleanupProof":"Reviewer proves identities, policies, sessions, certificate/key metadata, secrets and process state absent.","path":"drafts/LES-0051-identity-secrets-certificates-zero-trust/support/lab"}],"incidents":[{"id":"LES-0051-INC-001","signal":"A deployment gets access denied after successful login or token exchange.","firstThought":"Authentication succeeded but action/resource/condition authorization may fail; bind the exact tuple and effective policy.","safePath":"Inspect immutable principal, issuer/audience, delegation chain, action, resource, conditions, inherited deny and decision reason; correct the narrow mismatch.","trap":"Grant administrator access until it works."},{"id":"LES-0051-INC-002","signal":"A static credential appears in a repository or log.","firstThought":"Treat it as compromised regardless of deletion; copies may exist in history, caches, artifacts and consumers.","safePath":"Revoke/disable first when safe, identify use and blast radius from audit, rotate consumers, remove exposure, validate old denial and prevent recurrence.","trap":"Delete the visible line and call it fixed."},{"id":"LES-0051-INC-003","signal":"TLS fails after a certificate renewal.","firstThought":"Separate certificate, private key, chain, SAN, usage, trust anchor, file reload and clock; renewal success does not prove deployment.","safePath":"Bind served leaf/chain and key match, validate names/time/usage/trust from the client path, restore known-good material or redeploy correctly.","trap":"Disable certificate verification."},{"id":"LES-0051-INC-004","signal":"A signing or encryption key is suspected compromised.","firstThought":"Rotation alone does not invalidate already issued tokens or repair data encrypted under the old key.","safePath":"Stop new use, preserve audit, identify key purpose/version and affected artifacts/data, revoke trust or sessions, rotate and rewrap/reissue where designed, validate recovery.","trap":"Create a new key but leave old trust active indefinitely."},{"id":"LES-0051-INC-005","signal":"Identity provider outage blocks new sessions while existing sessions continue.","firstThought":"Authentication/control-plane availability, cached authorization and resource data plane have separated; revocation freshness is now a risk.","safePath":"Apply documented bounded cached-session policy, deny risky elevation/new trust, monitor age and user impact, restore issuer/JWKS path, then revalidate sessions.","trap":"Fail open for every request."}],"assessmentIds":["ASM-0136","ASM-0137","ASM-0138"],"referenceIds":["REF-0523","REF-0524","REF-0525","REF-0526","REF-0527","REF-0528","REF-0529","REF-0530","REF-0531","REF-0532","REF-0533","REF-0534","REF-0535","REF-0536","REF-0537"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No real identity, authenticator, token, private key, certificate, secret, provider account or credential is used.","The local model is not an IdP, policy engine, CA, KMS or secrets manager.","No OAuth/OIDC exchange, TLS handshake, certificate path, key operation, rotation or revocation runtime evidence.","Provider identity behavior and standards profiles are version-dependent.","Formal review, canonical publication and unseen learner evidence remain required."]}
---

# Identity, secrets, certificates, keys, and zero trust

## What you see and first thought

When access fails, “IAM issue” is too vague. Ask: **Who is the subject, who proved it, what assertion was issued, who validated it, and which exact action on which resource was denied?** Authentication establishes confidence in an identity. Authorization decides whether that identity may perform one action in one context. A valid token can still be correctly denied.

Identity is a production dependency and a security boundary. If it is too permissive, compromise spreads. If it is unavailable or misconfigured, healthy applications become unreachable. The senior habit is to preserve the denial reason and narrow the mismatch—not grant broad access until the symptom disappears.

## Terms before commands

**Identification** names a claimed subject. **Identity proofing** connects a real-world subject to a digital identity. **Authentication** verifies control of an authenticator. **Federation** lets one trusted authority assert identity to another system. **Authorization** evaluates principal, action, resource and context against policy. **Accounting/audit** records decisions and actions.

A **credential** proves or helps obtain identity. An **authenticator** can be something known, possessed or inherent. A **token/assertion** is an issuer’s time-bounded statement. A **role** is a permission set or assumable identity; a **session** is one temporary use. **Impersonation/delegation** creates a chain that audit must preserve.

A **secret** is confidential material used by a system. A **key** is cryptographic material with a defined purpose. A **certificate** binds a public key to names and constraints through an issuer signature; it contains no private key. A **trust anchor** is a configured root of validation, not a certificate that is trusted because it merely exists.

## Architecture map

```text
human/workload -> authenticator or ambient identity -> trusted issuer
                                                   |
                                          signed assertion/token
                                                   |
resource <- policy decision <- validate signature/issuer/audience/time/subject
   |                 |
 user outcome     audit/delegation chain

secret manager/CA/KMS -> short-lived lease/certificate/key handle -> workload
```

Separate human and workload identity. Humans need lifecycle, MFA, device/session context and controlled elevation. Workloads need non-human immutable subjects, attestation and automatic short-lived credentials. A shared administrator token is neither.

## Request or state path

For OIDC login, a client redirects to an authorization server, the subject authenticates, the client validates state/nonce and exchanges an authorization code, then validates an ID token’s issuer, audience, signature and time. OAuth access tokens authorize protected API access; an ID token tells a client about authentication. They are not interchangeable.

For workload federation, the workload obtains an assertion from its runtime or CI issuer, presents it to a security token service, and receives a short-lived target credential under mapping and condition rules. Bind issuer, tenant, immutable subject, audience and job/workload attributes. An issuer URL alone may represent many tenants.

At the resource, authentication ends before authorization begins. Evaluate the exact principal, requested action, canonical resource, conditions, inherited policy, permission boundary and explicit deny. Record the effective decision and delegation chain without logging bearer tokens or secret values.

## Failure zoom

Classify failure at the earliest boundary: authenticator rejected; issuer unavailable; metadata/JWKS unreachable; signature or trust chain invalid; issuer/audience/nonce/time wrong; subject mapping ambiguous; token exchange denied; session expired; action/resource/condition denied; credential revoked; downstream application failed.

For TLS, separate DNS/connectivity, protocol negotiation, certificate delivery, private-key possession, path construction, trust anchor, SAN name, validity, key usage, revocation and application authorization. “Certificate error” is a symptom family.

For leaks, assume the value was copied. Deleting a line does not revoke it. Git history, CI logs, artifacts, images, caches and developer machines may retain it. Revoke and investigate use before relying on cleanup.

## Internals and state ownership

JWT text is base64url-encoded, not encrypted by default. Decoding reveals claims; it does not verify the signature, trusted issuer, intended audience, validity, replay defenses or authorization. Verifiers need an allow-listed algorithm and trusted key source, exact issuer/audience checks, clock policy, and application-specific claim rules.

Least privilege means minimum action, resource, condition and duration for the workload—not choosing the smallest prebuilt role name. Test allowed and denied paths. Protect who can edit trust mappings and policies; permission to change authorization can be more powerful than permission to use a resource.

Secrets need inventory, ownership, creation, encrypted storage, access policy, delivery, memory/file handling, lease/expiry, rotation, revocation, consumer rollout and verified removal. Dynamic or short-lived credentials reduce the window and rotation burden, but issuer availability and revocation behavior become dependencies.

Key management defines purpose, algorithm, boundary, generation, import/export, use, version, rotation, backup/recovery, compromise and destruction. Encryption rotation may require rewrapping data; signing-key rotation requires verifier trust overlap and expiry of old artifacts. Never conflate key rotation with certificate renewal.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| subject authenticated | issuer, immutable subject, assurance and session time | action allowed |
| token valid | signature, algorithm, issuer, audience, time and replay context | least privilege |
| access least privilege | exact allowed tuple plus meaningful negative tests | no escalation elsewhere |
| federation safe | trusted issuer/tenant, unique subject mapping, audience and conditions | issuer never compromised |
| secret rotated | new version used, old revoked and old path denied | value absent from every historical copy |
| certificate trusted | served leaf/chain, SAN, usage, time and trust path | private key uncompromised |
| key rotated | new version active, old use/trust bounded, affected data/artifacts handled | no prior misuse |
| break-glass controlled | approval, named subject, narrow scope, expiry and session audit | every emergency decision correct |
| zero trust applied | resource-specific continuous policy and telemetry | zero risk |

## Command decoders

The lab uses only synthetic metadata. `show` binds the case without printing secrets. `evaluate` returns the earliest decision boundary. Cases cover time, audience, authorization scope, credential leak, certificate validity, identity lifecycle, key state and identity-service outage.

In real systems, never paste bearer tokens into general decoders or tickets. Record a one-way identifier or safe claims supplied by an approved tool. `openssl x509 -noout -text` can inspect a public certificate, but `openssl` output does not prove which certificate a remote peer serves or whether the application reloaded it. Provider “simulate policy” tools model selected policy semantics and are not runtime allow evidence.

## Decision path

1. Bind subject type and immutable identity; never authorize mutable display names alone.
2. Bind trust authority, tenant, authenticator/attestation assurance and lifecycle owner.
3. Bind token/assertion purpose, issuer, audience, subject, time, signature key and replay controls.
4. Trace every federation or impersonation hop and preserve source identity.
5. Evaluate the exact action/resource/context against effective allow and deny policy.
6. Prefer short-lived sessions; constrain creation of long-lived credentials.
7. Inventory secret, certificate and key consumers before rotation.
8. Design renewal/rotation with overlap, rollback, revocation and old-path negative tests.
9. Monitor success, denial, latency, issuance, expiry, stale trust, unusual use and audit gaps.
10. For compromise, stop new use, bound blast radius, revoke trust/sessions, recover and validate.
11. For outages, distinguish new authentication from existing bounded sessions and risky elevation.
12. Verify the user/workload transaction; green identity control planes do not prove application success.

## Guided Ubuntu lab

Run `bash lab.sh doctor`, `bash lab.sh setup`, `bash lab.sh list`, then evaluate each case. For every denial, state the subject, assertion, decision boundary, safe next evidence and action you refuse. The fixture contains no token, password, certificate or key bytes.

The verifier refuses root, credential-shaped environment variables, symlinks and unknown state. It creates one UID-scoped `/tmp` directory and proves cleanup. It is a reasoning model, not a cryptographic or provider test.

## Production transfer

In a reviewer-owned loopback simulator, configure separate human and workload issuers, unique immutable subjects, audience-bound short-lived sessions and an API with two resources. Demonstrate one allowed action and meaningful denials for wrong audience, wrong tenant, overbroad resource and expired session.

Add synthetic secret metadata, a disposable test certificate chain and a key-version record without real organizational material. Rotate each, prove new use, deny old use, preserve audit and remove the environment. Inject issuer/JWKS outage and show the documented difference between existing low-risk sessions, new sessions and elevation.

## Reliability, security, observability, capacity, and cost

Identity reliability includes issuer, metadata/JWKS, token exchange, policy engine, secret/CA/KMS and audit paths. Cache only within documented freshness and revocation risk. Retry boundedly; authentication storms can amplify an outage. Design emergency access that does not depend entirely on the failed system but is narrow, protected and tested.

Security requires phishing-resistant authentication where risk warrants, short-lived workload identity, unique subjects, exact audiences, narrow roles, explicit denies, protected policy administration, non-exportable keys where appropriate, automatic renewal and tested revocation. Network location alone grants no trust.

Observe decision latency/result/reason, issuer and audience, session age, delegation chain, unusual principals/actions, secret lease age, certificate expiry/renewal/reload, key version use, denied old credentials and audit delivery. Never put raw secrets, tokens or private keys in logs.

Capacity covers login/token rates, JWKS refresh, policy evaluation, CA issuance, KMS operations, secret reads, audit volume and recovery bursts. Cost includes premium identity controls, HSM/KMS operations, secret versions, CA infrastructure, logs, support and operator time. Reducing static credentials often lowers long-term incident and rotation cost.

## Traps and prevention

- **Trap:** Authenticated means authorized. **Prevention:** evaluate exact action/resource/context separately.
- **Trap:** Decoded JWT means valid. **Prevention:** verify signature, issuer, audience, time and purpose.
- **Trap:** Email/name is immutable identity. **Prevention:** map stable non-reusable subject IDs.
- **Trap:** One workload role for everything. **Prevention:** workload-specific subjects and negative tests.
- **Trap:** Secret encrypted at rest is solved. **Prevention:** control delivery, use, rotation, revocation and leak response.
- **Trap:** Certificate contains the private key. **Prevention:** track certificate and key as separate coupled artifacts.
- **Trap:** Renewed means deployed. **Prevention:** inspect what every endpoint actually serves and reloads.
- **Trap:** Rotate key and forget old artifacts/data. **Prevention:** handle verifier trust, sessions and encrypted data explicitly.
- **Trap:** Private network is trusted. **Prevention:** resource-specific identity and authorization every session.
- **Trap:** Fix denial with administrator. **Prevention:** preserve reason and narrow the tuple.

## Memory card and retrieval

Remember **SUBJECT → PROOF → ISSUER → ASSERTION → POLICY → RESOURCE → AUDIT**. For credentials remember **CREATE → DELIVER → USE → ROTATE → REVOKE → PROVE OLD DENIAL**.

Tomorrow explain: authentication versus authorization; ID token versus access token; decoding versus validating JWT; secret versus key versus certificate; why audience matters; why rotation is incomplete without revocation; and why zero trust does not mean trust nobody.

## Complete answers

**Why prefer federation?** It exchanges a trusted existing identity for short-lived target credentials, reducing copied keys and centralizing lifecycle. It adds issuer, mapping and token-service dependencies, so audience, immutable subjects, tenant conditions, audit correlation and outage policy matter.

**What is least privilege?** The minimum action on the minimum resource under the required conditions for the necessary duration, with negative tests. It is not merely selecting a role whose name sounds small.

**What is zero trust?** No implicit trust based only on location or ownership. Protect resources through explicit subject/device/workload context, least privilege, time-bounded sessions, telemetry and re-evaluation. It is an architecture principle, not a product or a rule to block everything.

**How do I rotate safely?** Inventory consumers, issue new version, distribute and observe adoption, keep only deliberate overlap, revoke old use, prove old denial, remove historical delivery paths and preserve audit. For keys/certificates, account for verifier trust, data/artifacts and reload behavior.

**What do I do after a leak?** Revoke first when operationally safe, identify exposed scope and observed use, rotate consumers, invalidate dependent sessions/artifacts, remove copies, verify old denial and fix the source path. Never repeat the value in the incident record.

## Product-company interview

**Question:** Design CI-to-cloud authentication for hundreds of repositories without static cloud keys.

**Strong answer:** Trust the CI platform’s OIDC issuer only under exact issuer, audience and immutable organization/repository/workflow/ref conditions. Exchange the job assertion for a short-lived workload-specific target role. Separate production environments and approval, restrict action/resource/conditions and session duration, preserve the source subject and run in audit, protect who can edit trust policy, and test wrong repository, branch, audience and fork denials. Monitor exchange/denial anomalies and keep a narrow audited break-glass path. No credential is printed or persisted in artifacts.

**Weak answer:** Store one administrator key in the CI secret store and rotate it yearly. It creates a long-lived shared blast radius and weak attribution.

## Independent transfer and rubric

`ASM-0138` gives the reviewer-only changed case. The learner designs human and workload identity, federation, least privilege, secret/certificate/key lifecycle and zero-trust session policy, then responds to a denial, leak, stale certificate, key compromise and issuer outage.

Evidence binds immutable subjects, trust, audience, effective policy, session duration, safe metadata, audit, old-path denial and exact cleanup. Reading or passing the model does not award mastery; unseen change, reviewer observation, delayed recall and later real disposable protocol runtime are required.

## References and review

Fifteen primary or official sources cover authentication assurance, federation, OAuth/OIDC security, TLS/PKI/ACME, key and secret lifecycle, SPIFFE, Kubernetes service accounts, provider workload federation and zero trust. Reviewed 2026-08-04; review due 2027-02-04.

Identity defaults and attacks evolve. Bind standard revision, provider, issuer, tenant, library, algorithm policy and platform version before implementation. The next security and provider chapters deepen policy, KMS, secret managers and incident runtime.
