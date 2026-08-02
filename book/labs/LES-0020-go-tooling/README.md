# LES-0020 Go infrastructure tooling lab

This is an offline deterministic evidence lab for the lesson "Go infrastructure tooling: bounded concurrency, explicit contracts, and trustworthy outcomes."

It is not a cloud emulator. It opens no socket, installs no package, uses no administrator permission, and makes no production claim.

## Tested boundary

Runtime-tested on:

- Windows 11
- Windows PowerShell 5.1
- Go 1.22.0 windows/amd64

The available WSL Ubuntu 24.04 environment does not contain Go. The Go module is designed to be portable, and the lesson contains Ubuntu commands, but this repository does not claim the lab passed on Ubuntu yet.

## Files

~~~text
LES-0020-go-tooling/
|-- go.mod
|-- lab.ps1
|-- verify.ps1
|-- cmd/opsmodel/main.go
`-- internal/model/
    |-- model.go
    `-- model_test.go
~~~

The model uses only the Go standard library. go.sum is intentionally absent because the module has no third-party dependency.

## Safety contract

The controller requires RELIABILITY_ATLAS_STATE_HOME to be a fresh absolute directory under the current user's temporary directory with this exact shape:

~~~text
reliability-atlas-LES-0020-state.<32 lowercase hexadecimal characters>
~~~

The same token derives exactly one lab root:

~~~text
reliability-atlas-LES-0020.<same token>
~~~

The controller:

- refuses an elevated Windows token;
- refuses state outside the current user's temporary directory;
- refuses reparse points;
- records the current Windows SID;
- records a digest over go.mod and Go source;
- allowlists top-level artifacts;
- refuses cleanup on an unexpected artifact or changed identity;
- removes only the verified model files and guarded cache/bin/temp trees beneath the registered root;
- verifies the registered root and descriptor are absent.

The Go model independently validates the root shape and canonical temp containment. Its JSON publisher uses a same-directory private candidate, file synchronization, strict readback, a writer-lock directory, and rename. These are useful local mechanisms, not a claim of distributed locking or cross-platform crash durability.

## Start a clean session

Run from this directory in normal Windows PowerShell:

~~~powershell
$stateHome = Join-Path ([IO.Path]::GetTempPath()) ('reliability-atlas-LES-0020-state.' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stateHome | Out-Null
$env:RELIABILITY_ATLAS_STATE_HOME = $stateHome

.\lab.ps1 check
.\lab.ps1 setup
.\lab.ps1 status
~~~

Do not run as Administrator.

## Guided path

~~~powershell
.\lab.ps1 baseline
.\lab.ps1 inject guided
.\lab.ps1 scenario
.\lab.ps1 observe contract
.\lab.ps1 observe runtime
.\lab.ps1 observe state
.\lab.ps1 observe outcome
.\lab.ps1 recover
.\lab.ps1 recover
.\lab.ps1 verify
.\lab.ps1 status
.\lab.ps1 cleanup
.\lab.ps1 check
~~~

The second recover must report already-complete. It reads the existing receipt and refuses conflicting content.

## Independent path

Use book/assessments/engineering/ASM-0045-response-template.md outside lab-owned state.

Start clean, then capture scenario before observe:

~~~powershell
.\lab.ps1 setup
.\lab.ps1 baseline
.\lab.ps1 inject independent
.\lab.ps1 scenario
~~~

The raw scenario contains only request and client-observed facts. It does not contain authoritative outcome, diagnosis, recovery, retry permission, duplicate result, or answer key.

Write predictions first. Then request selected observe views, recover by stable operation identity, verify, and clean up.

## Complete verification

~~~powershell
.\verify.ps1
~~~

The verifier compiles the model once and reuses one randomly named, verifier-owned Go build-cache directory under the current user's temp directory across refusal cases. It removes that cache root in its final cleanup block, including when a verification assertion fails.

The verifier checks:

- exact Go 1.22.x baseline;
- gofmt;
- go test with uncached test results;
- go vet;
- current-target build and embedded module metadata;
- guided and independent lifecycle;
- setup, recovery, verification, and cleanup idempotency;
- raw independent answer isolation;
- unexpected-artifact cleanup refusal;
- manifest tamper refusal;
- out-of-scope descriptor refusal while an external sentinel survives;
- the elevated-guard branch;
- final state absence.

It does not silently run go test -race. On some Windows Go installations that gate requires a supported C toolchain. Run it separately, record pass, failure, or unsupported status, and do not convert unsupported into passed.

## Manual Go gates

After setup, obtain the root:

~~~powershell
$env:ATLAS_RUN_ROOT = (.\lab.ps1 root)
$env:GOPROXY = 'off'
$env:GOSUMDB = 'off'
$env:GOCACHE = Join-Path $env:ATLAS_RUN_ROOT 'gocache'
$env:GOTMPDIR = Join-Path $env:ATLAS_RUN_ROOT 'tmp'

go test -count=1 ./...
go vet ./...
go build -trimpath -buildvcs=false -o (Join-Path $env:ATLAS_RUN_ROOT 'bin\opsmodel.exe') ./cmd/opsmodel
go version -m (Join-Path $env:ATLAS_RUN_ROOT 'bin\opsmodel.exe')
~~~

Restore any environment values you changed when finished. lab.ps1 restores values that it changes internally; manual shell assignments remain your responsibility.

## What a pass means

A passing verifier proves the checked local Go and PowerShell behavior under the recorded environment. It does not prove:

- Ubuntu or container runtime behavior;
- a real HTTP, TLS, proxy, Kubernetes, or cloud API;
- distributed idempotency;
- cross-process filesystem safety against every hostile race;
- absence of all data races;
- security certification;
- learner mastery.
