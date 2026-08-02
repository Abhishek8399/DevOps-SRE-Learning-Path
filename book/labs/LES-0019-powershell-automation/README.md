# LES-0019 PowerShell safe operational automation lab

This offline lab makes PowerShell's easy-to-miss boundaries visible: objects
versus formatting text, success and error streams, nonterminating versus
terminating errors, native exit status versus PowerShell exceptions, typed
parameter validation, postcondition verification, and guarded cleanup.

The model is deterministic. It does not call a service, start a helper, inspect
another process, install software, request a credential, or contact a network.
A passing verifier proves the checked lifecycle and refusal cases only. It does
not prove PowerShell skill, production safety, or mastery.

## Why this lab uses Windows PowerShell 5.1

The tested workstation has Windows PowerShell 5.1 and Ubuntu 24.04 under WSL,
but does not have PowerShell 7 (`pwsh`) installed in Windows or Ubuntu. Installing
a runtime would require a networked host change, so this lab deliberately uses
the runtime already present. From Ubuntu, `powershell.exe` crosses into the
Windows process, identity, path, ACL, and temporary-directory boundary. The
lesson calls out that transfer explicitly; it does not pretend Windows
PowerShell is a native Ubuntu process.

## Environment and blast radius

| Property | Contract |
|---|---|
| Runtime | Windows PowerShell 5.1 Desktop edition |
| Privilege | non-elevated current user; an administrator token is refused |
| Network | none |
| Remote systems | none |
| Temporary state | one transient current-SID setup lock, one current-SID descriptor, and one random registered directory below the current user's `%TEMP%` |
| Privacy | ACL inheritance is removed; one allow rule grants only the current SID full control |
| Cleanup | exact allowlisted regular files, then the exact empty registered directory and descriptor; the kernel removes the setup lock when its exclusive handle closes; no recursion or wildcard deletion |

Stop when a guard refuses. Do not run the lab as Administrator, change an ACL,
edit the descriptor, or recursively delete a discovered path. A refusal is an
important result: the script cannot prove ownership safely.

Setup creates the current-SID lock with atomic `CreateNew`, a current-user-only
ACL, exclusive sharing, and `DeleteOnClose` before it reads or publishes state.
A simultaneous setup is refused. An existing lock of any kind is treated as
active, stale, or unexpected: the lab preserves it and refuses every command
rather than guessing that it is safe to inspect, mutate, or remove state.

## Files

```text
LES-0019-powershell-automation/
|-- README.md
|-- lab.ps1
|-- verify.ps1
`-- fixtures/
    `-- operation-model.json
```

## Native Windows PowerShell preflight

Open a normal, non-administrator Windows PowerShell window in this directory:

```powershell
$PSVersionTable.PSVersion
[Security.Principal.WindowsPrincipal]::new(
  [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

powershell.exe -NoLogo -NoProfile -NonInteractive `
  -ExecutionPolicy Bypass -File .\lab.ps1 check
```

The version begins with `5.1`, the role check is `False`, and `check` includes:

```text
environment=ready engine=Windows-PowerShell-5.1... privilege=non-elevated network=none state=absent
```

`-ExecutionPolicy Bypass` applies only to this child process. It does not change
machine or user execution policy. The scripts are checked-in local content;
review them before running.

## Ubuntu or WSL bridge preflight

From WSL Ubuntu in this lab directory, do not install `pwsh`. Invoke the Windows
host executable and convert the script path explicitly:

```bash
pwd -P
id
test -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
LAB_PS1="$(wslpath -w ./lab.ps1)"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass \
  -File "$LAB_PS1" check
```

The Bash variables and `wslpath` run in Ubuntu. `lab.ps1` then runs as a Windows
process. Its `%TEMP%`, access-control lists, user SID, path separators, and
process exit code are Windows evidence. Do not label them Linux UID, mode-bit,
or `/tmp` evidence.

## Guided case

```powershell
.\lab.ps1 setup
.\lab.ps1 run baseline
.\lab.ps1 inject guided
.\lab.ps1 observe operation
.\lab.ps1 observe input
.\lab.ps1 observe pipeline
.\lab.ps1 observe errors
.\lab.ps1 observe native
.\lab.ps1 observe state
.\lab.ps1 observe outcome
```

Explain each boundary before recovery:

- an environment or external value began as `System.String`, not an integer;
- `Out-String` replaced structured objects with formatting text;
- a nonterminating error wrote an error record but did not enter `catch`;
- native status 7 did not automatically become a PowerShell exception;
- a later native command could overwrite `$LASTEXITCODE`;
- exit 0 did not prove records or target state.

Then execute the deterministic modeled recovery and verify the original
operation:

```powershell
.\lab.ps1 recover
.\lab.ps1 verify-operation
.\lab.ps1 status
.\lab.ps1 cleanup
.\lab.ps1 check
```

## Independent case

Start clean, capture raw input, and write a prediction before asking for derived
views:

```powershell
.\lab.ps1 setup
.\lab.ps1 run baseline
.\lab.ps1 inject independent
.\lab.ps1 scenario
```

The scenario intentionally omits the authoritative outcome, diagnosis, retry
decision, and recovery. In notes outside the guarded lab directory, record the
promised postcondition, state owners, at least three hypotheses, a
disconfirming check for each, and whether another effect is currently safe.

Then request only the evidence needed:

```powershell
.\lab.ps1 observe operation
.\lab.ps1 observe input
.\lab.ps1 observe pipeline
.\lab.ps1 observe errors
.\lab.ps1 observe native
.\lab.ps1 observe state
.\lab.ps1 observe outcome
```

Complete ASM-0042 before recovery. Then:

```powershell
.\lab.ps1 recover
.\lab.ps1 verify-operation
.\lab.ps1 cleanup
```

## WhatIf and confirmation semantics

The controller declares `SupportsShouldProcess`. A dry run plans a mutation and
must leave no registered state:

```powershell
.\lab.ps1 setup -WhatIf
.\lab.ps1 check
```

`-WhatIf` is useful only when every mutating path honors `ShouldProcess` and
when hidden callees do not mutate outside that contract. It is a planning
signal, not a transaction or proof that production permissions will allow the
real action.

## Full verifier

From a clean, non-elevated Windows PowerShell process:

```powershell
powershell.exe -NoLogo -NoProfile -NonInteractive `
  -ExecutionPolicy Bypass -File .\verify.ps1
```

The verifier runs guided and independent lifecycles, verifies `-WhatIf`, starts
two bounded setup processes and proves one owner plus one refused contender, tests
preservation of an unexpected setup lock, tests idempotent cleanup, forces refusal
for an unexpected file, modifies and restores
the installed model, redirects and restores the descriptor while protecting an
external target, simulates an interrupted cleanup phase, resumes cleanup, and
proves final absence. Expected final fields include:

```text
verification_passed=true
engine=Windows-PowerShell-5.1
cases=guided,independent
interruption=cleanup-resume-tested
answer_isolation=raw-independent-scenario-without-derived-diagnosis-or-recovery
network_mutation=none
cleanup_proven=true
```

Elevation refusal is implemented by `lab.ps1`. It is not tested by asking the
learner to launch an elevated process. A reviewer who already has an isolated
elevated test environment may run `lab.ps1 check` and record the expected
nonzero refusal; no learner should elevate merely to produce that evidence.

If interruption occurs during a verifier tamper drill, its `finally` block
attempts to restore the exact saved descriptor and model and preserves otherwise
valid registered state. A forced process kill cannot run `finally`. The cleanup
marker makes exact cleanup resumable; run `lab.ps1 cleanup`, then `lab.ps1 check`.
If any guard refuses, preserve the state and investigate instead of bypassing it.
A lock normally disappears even when its owning process terminates because the
kernel closes the delete-on-close handle. If the exact lock pathname survives,
treat it as stale or unexpected evidence; the lab intentionally will not delete it.

## Production transfer worksheet

| Local modeled field | Production replacement |
|---|---|
| Windows PowerShell engine | exact `powershell` or `pwsh` path, edition, version, language mode, module path, host |
| current SID | service identity, managed identity, runner account, container user, Kubernetes service account |
| object pipeline | exact input and output .NET types before formatting, serialization, and remoting |
| error record | stream, error category, fully qualified error ID, invocation info, terminating policy |
| native status | executable path, argument list, immediate status, bounded streams, timeout and process-tree result |
| operation ID | durable business identity shared across controller and target attempts |
| state readback | authoritative API resource version, receipt, observable user outcome |
| local ACL state | approved production state store, access policy, concurrency protocol, retention, audit evidence |

Real remoting, credentials, modules, package installation, services, registry
changes, scheduled tasks, cloud resources, CI jobs, and Kubernetes objects are
outside this lab. Each needs explicit authorization, a reviewed plan or diff,
least privilege, bounded scope, abort thresholds, rollback or compensation, and
verification at the real state owner.
