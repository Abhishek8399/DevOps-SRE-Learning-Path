# Dependency remediation record

This record is for maintainers of the local learning cockpit. It is not a claim that the application is safe for public exposure.

## Current decision

The committed `learning-cockpit/package.json` constrains two transitive packages to patched versions:

```json
"overrides": {
  "postcss": "8.5.26",
  "nanoid": "3.3.18"
}
```

The override was installed in a disposable clean clone. `npm ls` showed the expected versions, content validation passed, and `npm run build` passed.

## Remaining risk

The production-only audit still reports high-severity paths through `next@16.2.6` and `sharp@0.34.5`. npm proposes a Next.js upgrade outside the currently declared range; that is not an acceptable unattended fix.

Until reviewed:

- bind the dev server to loopback only;
- do not expose the cockpit to the internet or untrusted users;
- do not enable image/server-action features merely to test them;
- keep the lockfile and rerun the production audit after dependency changes.

## Safe upgrade procedure

1. Read the exact advisory and affected code path.
2. Create a disposable branch/clone and update one dependency family at a time.
3. Run `npm ci`, `npm ls`, content validation, typecheck, lint, reader tests, schema tests, and production build.
4. Exercise loopback routes and local evidence export; check for changed security boundaries.
5. Compare bundle/runtime behavior and document rollback before merging.
6. Rerun `npm run audit:runtime` (equivalent to `npm audit --omit=dev --audit-level=moderate`) and record unresolved advisories explicitly.

Never use `npm audit fix --force` as a substitute for compatibility review.
