# Local Security Notes

## Scope

The cockpit is a local training interface. It has no authentication, backend database, upload endpoint, cloud deployment, or external application API call.

Do not enter secrets, credentials, employer data, private URLs, or production incident evidence. Teach-back text is stored in browser `localStorage` only.

## Dependency evidence

Latest registry-backed evidence for the committed lockfile (2026-09-07):

- A Git-only temporary clone completed `npm ci`, installed 492 package artifacts, applied the documented Windows Vinext compatibility patch, and passed content, type, lint, production-build, and asset-budget checks. The guarded temporary clone was removed afterward.
- npm warned that sharp, unrs-resolver, workerd, and nested esbuild declare install scripts without explicit npm script-approval configuration. The clean build passed, but their install behavior still requires an independent review.
- `npm audit --omit=dev --audit-level=moderate` reports zero production vulnerabilities at the recorded time.
- `npm run audit:dependencies` reports 655 locked packages, fifteen reviewed license expressions, registry-only resolved sources, integrity or explicit bundling, and five known install-script package paths. This is deterministic change detection, not a legal opinion or live vulnerability result.
- Automatic `npm audit fix` and `npm audit fix --force` were not run. Future advisories require exact-path analysis, compatibility testing, and a reviewed lockfile change.

The older results below are retained as historical evidence only. Audit results remain point-in-time evidence and must be rerun after dependency changes.

Validation on 2026-08-01 produced conflicting advisory evidence:

- `npm ci` contacted the configured npm registry and reported 18 advisories: 1 low, 4 moderate, and 13 high.
- `npm audit --offline --json` reported zero advisories from local cache.

The offline result does not override the registry-backed install result because the local advisory cache may be incomplete or stale. A fresh networked `npm audit` was not run because the program is constrained to local-only operation and sending dependency metadata externally was not authorized.

The 2026-08-01, 2026-08-02, and pre-upgrade 2026-08-11 statements describe prior lockfile states and are preserved for audit history; they are not the current status. Rerun the audit after future dependency changes.

## Safe operation

- Bind development access to loopback only.
- Keep the committed lockfile and use `npm ci`.
- Review advisories before exposing this site beyond the local machine.
- Do not run `npm audit fix --force`; review exact dependency paths and breaking changes first.
- Rerun the registry-backed audit after dependency or lockfile changes.
- Stop the local development server when the session ends.
