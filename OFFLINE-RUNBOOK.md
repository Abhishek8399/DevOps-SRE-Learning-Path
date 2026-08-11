# Offline local runbook

Reliability Atlas is designed to run on loopback without a cloud account, analytics service, database, or external font. The repository is the durable source; the browser is only the reading interface.

## First setup while dependencies are available

From the repository root:

```bash
cd learning-cockpit
npm ci
npm run validate:content
npm run audit:runtime
```

`npm ci` needs the package tarballs available through your normal npm cache or registry. After it succeeds, the application itself does not need internet access.

The audit command may need registry metadata the first time. Its result is point-in-time dependency evidence; it does not send application content or learner notes anywhere.

## Start locally

From the repository root:

```bash
./startlearning.sh
```

On Windows, run `startlearning.cmd`. Both bind to `127.0.0.1:3000`; stop with `Ctrl+C`. If the port is occupied, stop the old development process or use the app directly with another port:

```bash
cd learning-cockpit
npm run dev -- --hostname 127.0.0.1 --port 3001
```

`npm run start:dev -- --hostname 127.0.0.1 --port 3000` is an equivalent explicit alias. Do not use `npm start dev`: `npm start` is the production server command and does not mean “start development.”

## Disconnected check

After dependencies are installed, disconnect the network and run the start command. Reading, navigation, local search, lesson rendering, margin notes, bookmarks, and evidence export should remain local. The first start may still run repository validation; that validation reads files and does not call a cloud service.

If startup fails, classify the failure before changing files:

| Symptom | Safe next check |
| --- | --- |
| `node` or `npm` missing | Install the required Node version; do not copy `node_modules` from an unrelated project. |
| `node_modules` missing | Run `npm ci` when the package cache/registry is available. |
| Port already in use | Identify the owning process and use a different loopback port. |
| Validation failure | Read the first reported file/link/schema error; do not bypass validation. |
| Browser cannot connect | Confirm the terminal process is still running and use the printed loopback URL. |
| WSL/Docker unavailable | Use the shell-only lessons or clearly labelled simulations; do not claim container/VM evidence. |

## What “offline” does and does not mean

Offline means the reader has no runtime dependency on cloud services or external telemetry. It does not mean a fresh machine can install packages without either a network or a populated package cache. Preserve `package-lock.json` and the installed dependency cache if a fully disconnected rebuild is required.

## Reset without deleting the repository

Stop the dev server first. Browser-local notes and bookmarks can be cleared from the browser’s site data; this does not change Git content. To rebuild dependencies, remove only `learning-cockpit/node_modules` and rerun `npm ci` when package sources are available. Never use a broad recursive delete from the repository root.

On Windows, if `npm ci` reports `ENOTEMPTY`, `EBUSY`, or `EPERM` inside `node_modules`, close every Node/dev-server process and editor task using the folder, then run:

```bat
cd C:\Users\ajha\Repos\DevOps-SRE-Learning-Path\learning-cockpit
rmdir /s /q node_modules
npm ci
```

This removes generated dependencies only. Keep `package.json` and `package-lock.json`; they are the reproducible inputs.
