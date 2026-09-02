# LES-0002 lab: process identity and graceful termination

This guided lab creates one synthetic Bash process, observes it, sends SIGTERM
only after matching UID, PID start ticks, script path, and a unique token, then
proves cleanup. It never touches systemd or a real service.

## Safety contract

- Ubuntu 24.04 or WSL 2 Ubuntu 24.04; normal user only.
- No sudo, package installation, network, DNS, socket, container, or real data.
- One mode-0700 random root and one UID-scoped state descriptor under `/tmp`.
- One background process created from `fixtures/signal-target.sh`.
- Cleanup accepts only a flat allowlist of regular, current-user, single-link
  files. Unexpected paths, links, owners, modes, or identities cause refusal.
- A matching PID alone is insufficient: owner, kernel start ticks, fixture path,
  and unique token must all match immediately before signaling.
- Cleanup uses exact paths and `rmdir`; it never recursively deletes.

Like any same-user script, this cannot defeat every malicious race from another
process running as the same UID. Use only in the documented local environment.

## Run

```bash
bash lab.sh check
bash lab.sh setup
bash lab.sh inject
bash lab.sh observe
bash lab.sh status
```

Write your prediction before termination:

```text
identity: UID + PID + start ticks + fixture path + token should match
signal: SIGTERM
expected event: term_received
expected state: process absent, termination recorded
abort: any refusal or identity mismatch
cleanup: exact allowlisted artifacts only
proof: following check reports state=absent and process_candidates=0
```

Then run:

```bash
bash lab.sh terminate
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

The final check is a point-in-time proof for this lesson's descriptor and
current-UID candidate prefix. It does not prove that no unrelated process or
future path exists.

## Commands

| Command | Classification | Effect |
|---|---|---|
| `bash lab.sh check` | Read-only | Validate environment and state boundary. |
| `bash lab.sh setup` | Bounded mutation | Create private state and sentinel. |
| `bash lab.sh inject` | Bounded mutation | Start one tagged fixture process. |
| `bash lab.sh observe` | Read-only | Show process fields after identity match. |
| `bash lab.sh status` | Read-only | Report ready, running, or terminated state. |
| `bash lab.sh terminate` | Bounded destructive action | SIGTERM only the matched fixture. |
| `bash lab.sh cleanup` | Bounded destructive cleanup | Stop a matched fixture and remove exact artifacts. |
| `bash lab.sh reset` | Bounded cleanup and setup | Recreate a clean lesson state. |
| `bash verify.sh` | Engineering verification | Exercise the supported lifecycle. |

Run `bash verify.sh` only from absent state. It refuses to overwrite active
learner evidence.
