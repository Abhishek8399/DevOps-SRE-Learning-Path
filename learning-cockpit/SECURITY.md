# Local Security Notes

## Scope

The cockpit is a local training interface. It has no authentication, backend database, upload endpoint, cloud deployment, or external application API call.

Do not enter secrets, credentials, employer data, private URLs, or production incident evidence. Teach-back text is stored in browser `localStorage` only.

## Dependency evidence

Current registry-backed evidence for the committed lockfile (2026-08-02):

- `npm audit --audit-level=high` completed successfully.
- npm reported `found 0 vulnerabilities`.

The conflicting 2026-08-01 results below are retained as historical evidence and no longer describe the current lockfile status. Audit results remain point-in-time evidence and must be rerun after dependency changes.

Validation on 2026-08-01 produced conflicting advisory evidence:

- `npm ci` contacted the configured npm registry and reported 18 advisories: 1 low, 4 moderate, and 13 high.
- `npm audit --offline --json` reported zero advisories from local cache.

The offline result does not override the registry-backed install result because the local advisory cache may be incomplete or stale. A fresh networked `npm audit` was not run because the program is constrained to local-only operation and sending dependency metadata externally was not authorized.

That last sentence describes the 2026-08-01 decision only. Unused Drizzle database dependencies and examples were subsequently removed, including the oldest local `esbuild` dependency chain. The 2026-08-02 registry-backed audit is the current lockfile result: zero known vulnerabilities at that point in time. Preserve the older result as history, but do not present it as the current status.

## Safe operation

- Bind development access to loopback only.
- Keep the committed lockfile and use `npm ci`.
- Review advisories before exposing this site beyond the local machine.
- Do not run `npm audit fix --force`; review exact dependency paths and breaking changes first.
- Rerun the registry-backed audit after dependency or lockfile changes.
- Stop the local development server when the session ends.
