# DevOps/SRE Learning Cockpit

An offline-first visual practice dashboard for Abhishek's evidence-driven DevOps and SRE program. It turns the current lesson into several learning formats instead of duplicating the written notes.

## Purpose

The cockpit trains four different kinds of recall:

- **See the system:** architecture, request path, state, and failure-flow diagrams.
- **Break the system:** choose-the-next-move incident decisions with immediate reasoning feedback.
- **Read the field manual:** retain the complete explanation, signal map, safe-recovery path, and lab instructions for each completed topic.
- **Recall the system:** compact flashcards that require an answer before reveal.
- **Teach and defend:** Feynman notes and product-company interview drills.

The dashboard never raises mastery by itself. The repository ledger remains the evidence source of truth.

## Ready lessons

Volume 1 currently contains five substantial Linux foundation lessons:

1. Filesystems, blocks, inodes, and ENOSPC.
2. Processes, signals, exit codes, and systemd.
3. CPU, load, memory pressure, swap, and OOM.
4. DNS, routing, TCP, TLS, HTTP, and sockets.
5. Identity, permissions, traversal, and least privilege.

`Ready to study` describes content availability, not demonstrated mastery. The progress ledger remains authoritative.

## Local use

Prerequisite: Node.js 22.13 or newer. The validated local version is Node.js 26.4.0.

```bash
npm ci
npm run dev
```

Open `http://127.0.0.1:3000` in a local browser. No cloud deployment, account, credential, or external API is required.

On Windows, double-click `start-learning.cmd`. It installs locked dependencies on the first run, starts the loopback-only development server, and opens the site. Keep its command window open while learning; press `Ctrl+C` there to stop the server.

```text
start-learning.cmd
```

## Device-local data

Teach-back notes are stored only in browser `localStorage` under `devops-sre-teachback`. They are not sent to a server and are not competency evidence until submitted and reviewed.

Clear that browser key to reset the note. Do not enter employer information, credentials, secrets, or production data.

## Validation

```bash
npm run lint
npm run build
npm audit
```

The lockfile is committed for reproducible installation. Review audit findings rather than running `npm audit fix --force`, which may introduce breaking dependency changes.

---

## Implementation

- React 19 and vinext
- Device-local browser storage only
- No authentication, database, upload, or server-side persistence
- No external application API calls
- `.openai/hosting.json` contains no D1 or R2 bindings and is retained only for the starter build plugin
