# PowerShell for operations: preserve objects and intent

PowerShell pipelines pass objects, not just text. That makes filtering and reporting reliable, but only if you understand properties, remoting boundaries, error behavior, and the difference between formatting and data.

```text
Get-* -> select/filter objects -> validate -> bounded action -> verify -> Export-* evidence
  |            |                    |            |             |
 source      shape              scope         mutation       result
```

## Objects versus display

`Format-Table` and `Format-List` are for the screen; they should not feed automation. Select explicit properties, sort deterministically, and export structured JSON/CSV when another tool consumes the result. Confirm property names and types before filtering.

## Errors and native commands

PowerShell cmdlets often use non-terminating errors; use `-ErrorAction Stop` when failure must stop the operation and handle the exception with context. Native commands have their own exit codes and streams. Check `$LASTEXITCODE` and preserve stderr rather than assuming a returned string means success.

## Remoting and scope

Remoting crosses an identity, network, serialization, and authorization boundary. Validate the target list, session configuration, credential scope, timeout, and returned object type. Prefer `-WhatIf` and `-Confirm` where supported; never pipe an unreviewed broad result into `Remove-*` or `Set-*`.

## Safe local exercise

Create a temporary directory and files. Use `Get-ChildItem`, explicit property selection, filtering, and `Measure-Object` to report size and count. Use `-WhatIf` for a cleanup command, inspect the exact paths, then remove only the fixture directory. Test a missing path with terminating error handling.

## Triage sequence

1. Capture PowerShell version, current location, target parameters, and identity.
2. Inspect object properties and types before writing filters.
3. Separate display formatting from structured evidence.
4. Check terminating/non-terminating errors, native exit codes, and remoting scope.
5. Verify the bounded result and preserve output without secrets.

## Interview defense

**Question:** “Why did a PowerShell script delete the wrong files?”

**Strong answer:** “The pipeline used an ambiguous path or display text, lacked explicit scope and `-WhatIf`, and did not inspect object properties. I resolve absolute fixture paths, select exact properties, preview the action, enforce a stop condition, and verify the result.”

**Question:** “How do you make PowerShell automation portable?”

**Strong answer:** “Use cmdlets and explicit objects where available, detect platform/version differences, handle native exit codes, avoid provider-specific assumptions, parameterize paths, and test under the target PowerShell edition with bounded fixtures.”

## Teach-back checkpoint

Explain why formatted output is not data, how non-terminating errors can hide failure, and what checks must happen before a remote mutating command.
