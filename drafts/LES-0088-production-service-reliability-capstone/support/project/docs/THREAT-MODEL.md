# Threat model

## Assets and trust boundaries

Assets are item state, idempotency semantics, SQLite snapshots, local private key, image identity, telemetry integrity and operator evidence. Trust changes at the loopback client, TLS proxy, HTTP application, database file, metrics scrape, build runner and backup directory.

## Material threats and controls

| Threat | Failure mechanism | Present control | Residual risk |
|---|---|---|---|
| untrusted network exposure | training server receives hostile traffic | host ports bind only to loopback; docs forbid Internet use | another local process can connect |
| oversized or malformed input | memory/parse pressure or ambiguous state | content length, 16 KiB default limit, exact JSON shape and type checks | standard-library parser is not production hardened |
| SQL injection | input changes query structure | parameter binding and fixed statements | application logic flaws remain possible |
| duplicate create | timeout retry repeats a write | key, request hash and item insert share one immediate transaction | key retention is unbounded in this fixture |
| secret leakage | private key or IDs enter image/log/metrics | generated cert excluded from Git/build; no secrets; bounded labels | proxy access logs still expose local request metadata |
| container privilege | compromise writes image or gains capabilities | UID 10001, read-only root, all capabilities dropped, no-new-privileges | kernel and runtime remain shared |
| telemetry denial/cost | unbounded labels create series | route templates and bounded method/status dimensions | in-process metric memory has no tenant isolation |
| backup tamper | corrupt snapshot is trusted | SHA-256 manifest, byte/count checks, SQLite integrity check, new restore target | manifest and backup share one local trust domain |
| supply-chain drift | tag changes silently | Python, NGINX and Prometheus OCI indexes pinned by digest | pinned versions require deliberate security updates |
| unsafe cleanup | wrong path destroys evidence | exact project root, no symlinks, allowlisted cert names, unknown-artifact refusal | Docker volume removal still requires operator scope awareness |

## Explicit non-controls

There is no authentication, authorization, rate-limiting identity, WAF, external PKI, secrets manager, SBOM/signature gate, vulnerability scanner, encrypted database, multi-tenant isolation or audit backend. Those omissions make public or sensitive use unacceptable; they are future-stage learning work, not hidden assumptions.

## Security review gate

Before any broader exposure: replace the training server, define identities and authorization, use managed secrets and PKI, threat-model the real data, scan and sign artifacts, establish patch ownership, test abuse cases, constrain egress, retain privacy-reviewed audit evidence and obtain formal approval. A passing local scan would still not grant production authority.
