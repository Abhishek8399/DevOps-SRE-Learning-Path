# Local Security Notes

## Scope

The cockpit is a local training interface. It has no authentication, backend database, upload endpoint, cloud deployment, or external application API call.

Do not enter secrets, credentials, employer data, private URLs, or production incident evidence. Teach-back text is stored in browser `localStorage` only.

## Dependency evidence

Latest registry-backed evidence for the committed lockfile (2026-08-11):

- A fresh-clone `npm ci --ignore-scripts` completed and reported 18 advisories overall (2 low, 16 high).
- `npm audit --omit=dev --audit-level=moderate` now reports two high-severity runtime paths involving `next` and `sharp`; patched `postcss` and `nanoid` are constrained by reviewed overrides.
- Automatic `npm audit fix --force` was not run: npm proposes `next@16.3.0`, outside the declared dependency range, so remediation needs a reviewed compatibility/security change.

The older results below are retained as historical evidence only. Audit results remain point-in-time evidence and must be rerun after dependency changes.

Validation on 2026-08-01 produced conflicting advisory evidence:

- `npm ci` contacted the configured npm registry and reported 18 advisories: 1 low, 4 moderate, and 13 high.
- `npm audit --offline --json` reported zero advisories from local cache.

The offline result does not override the registry-backed install result because the local advisory cache may be incomplete or stale. A fresh networked `npm audit` was not run because the program is constrained to local-only operation and sending dependency metadata externally was not authorized.

The 2026-08-01 and 2026-08-02 statements describe prior lockfile states and are preserved for audit history; they are not the current status. Treat the remaining runtime advisories above as an open release/security risk until each dependency path is upgraded or the local-only exposure is explicitly accepted by review.

## Safe operation

- Bind development access to loopback only.
- Keep the committed lockfile and use `npm ci`.
- Review advisories before exposing this site beyond the local machine.
- Do not run `npm audit fix --force`; review exact dependency paths and breaking changes first.
- Rerun the registry-backed audit after dependency or lockfile changes.
- Stop the local development server when the session ends.
