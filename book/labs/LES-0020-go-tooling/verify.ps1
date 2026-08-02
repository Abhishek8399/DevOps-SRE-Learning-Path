[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$LabScript = [IO.Path]::Combine($ScriptRoot, 'lab.ps1')
$PowerShellExe = (Get-Process -Id $PID).Path
$Token = [guid]::NewGuid().ToString('N')
$TempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$StateHome = [IO.Path]::Combine($TempRoot, 'reliability-atlas-LES-0020-state.' + $Token)
$ExpectedRoot = [IO.Path]::Combine($TempRoot, 'reliability-atlas-LES-0020.' + $Token)
$BuildRoot = [IO.Path]::Combine($TempRoot, 'reliability-atlas-LES-0020-build.' + $Token)
$ExternalRoot = [IO.Path]::Combine($TempRoot, 'reliability-atlas-LES-0020-verifier.' + [guid]::NewGuid().ToString('N'))
$OldStateHome = $env:RELIABILITY_ATLAS_STATE_HOME
$OldVerifyMode = $env:RELIABILITY_ATLAS_VERIFY_MODE
$OldForceElevated = $env:RELIABILITY_ATLAS_FORCE_ELEVATED
$OldUseCallerWorkdir = $env:RELIABILITY_ATLAS_USE_CALLER_GO_WORKDIR
$OldProxy = $env:GOPROXY
$OldSum = $env:GOSUMDB
$OldCache = $env:GOCACHE
$OldTmp = $env:GOTMPDIR

function Fail {
    param([string]$Message)
    throw "verification_error=$Message"
}

function Invoke-Lab {
    param([string[]]$Arguments)
    $previousErrorPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $lines = & $PowerShellExe -NoProfile -ExecutionPolicy Bypass -File $LabScript @Arguments 2>&1
        $status = $LASTEXITCODE
        return [pscustomobject]@{
            Status = $status
            Output = (($lines | ForEach-Object { $_.ToString() }) -join "`n")
        }
    } finally {
        $ErrorActionPreference = $previousErrorPreference
    }
}

function Assert-Success {
    param([object]$Result, [string]$Label)
    if ($Result.Status -ne 0) {
        Fail "$Label failed with status $($Result.Status): $($Result.Output)"
    }
    return $Result.Output
}

function Assert-Failure {
    param([object]$Result, [string]$Label)
    if ($Result.Status -eq 0) {
        Fail "$Label unexpectedly succeeded: $($Result.Output)"
    }
    return $Result.Output
}

function Assert-Contains {
    param([string]$Value, [string]$Expected, [string]$Label)
    if (-not $Value.Contains($Expected)) {
        Fail "$Label did not contain $Expected"
    }
}

function Assert-NotContains {
    param([string]$Value, [string]$Forbidden, [string]$Label)
    if ($Value.IndexOf($Forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        Fail "$Label exposed forbidden text $Forbidden"
    }
}

function Invoke-Go {
    param([string[]]$Arguments)
    Push-Location $ScriptRoot
    try {
        $lines = & go @Arguments 2>&1
        $status = $LASTEXITCODE
        return [pscustomobject]@{
            Status = $status
            Output = (($lines | ForEach-Object { $_.ToString() }) -join "`n")
        }
    } finally {
        Pop-Location
    }
}

function Remove-BuildRoot {
    if (-not (Test-Path -LiteralPath $BuildRoot)) {
        return
    }
    $expectedName = 'reliability-atlas-LES-0020-build.' + $Token
    if (([IO.Path]::GetFileName($BuildRoot) -ne $expectedName) -or
        (-not $BuildRoot.StartsWith($TempRoot + '\', [StringComparison]::OrdinalIgnoreCase))) {
        Fail 'verifier build root identity failed'
    }
    foreach ($item in @((Get-Item -LiteralPath $BuildRoot -Force)) + @(Get-ChildItem -LiteralPath $BuildRoot -Force -Recurse)) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            Fail 'verifier build root contains a reparse point'
        }
        $full = [IO.Path]::GetFullPath($item.FullName)
        if ((-not $full.Equals($BuildRoot, [StringComparison]::OrdinalIgnoreCase)) -and
            (-not $full.StartsWith($BuildRoot + '\', [StringComparison]::OrdinalIgnoreCase))) {
            Fail 'verifier build content escaped its root'
        }
    }
    [IO.Directory]::Delete($BuildRoot, $true)
}

function Restore-Environment {
    $env:RELIABILITY_ATLAS_STATE_HOME = $OldStateHome
    $env:RELIABILITY_ATLAS_VERIFY_MODE = $OldVerifyMode
    $env:RELIABILITY_ATLAS_FORCE_ELEVATED = $OldForceElevated
    $env:RELIABILITY_ATLAS_USE_CALLER_GO_WORKDIR = $OldUseCallerWorkdir
    $env:GOPROXY = $OldProxy
    $env:GOSUMDB = $OldSum
    $env:GOCACHE = $OldCache
    $env:GOTMPDIR = $OldTmp
}

[IO.Directory]::CreateDirectory($StateHome) | Out-Null
[IO.Directory]::CreateDirectory([IO.Path]::Combine($BuildRoot, 'gocache')) | Out-Null
[IO.Directory]::CreateDirectory([IO.Path]::Combine($BuildRoot, 'tmp')) | Out-Null
$env:RELIABILITY_ATLAS_STATE_HOME = $StateHome
$env:RELIABILITY_ATLAS_VERIFY_MODE = '1'
$env:RELIABILITY_ATLAS_FORCE_ELEVATED = $null
$env:RELIABILITY_ATLAS_USE_CALLER_GO_WORKDIR = '1'
$env:GOPROXY = 'off'
$env:GOSUMDB = 'off'
$env:GOCACHE = [IO.Path]::Combine($BuildRoot, 'gocache')
$env:GOTMPDIR = [IO.Path]::Combine($BuildRoot, 'tmp')

try {
    $goVersion = Assert-Success (Invoke-Go @('version')) 'go version'
    if ($goVersion -notmatch 'go version go1\.22(?:\.| )') {
        Fail "tested baseline requires Go 1.22.x; observed: $goVersion"
    }

    $initial = Assert-Success (Invoke-Lab @('check')) 'initial check'
    Assert-Contains $initial 'state=absent' 'initial check'

    $setup = Assert-Success (Invoke-Lab @('setup')) 'setup'
    Assert-Contains $setup 'setup=complete' 'setup'
    Assert-Contains $setup $ExpectedRoot 'setup root'
    $setupAgain = Assert-Success (Invoke-Lab @('setup')) 'repeated setup'
    Assert-Contains $setupAgain 'setup=already-present' 'repeated setup'

    Push-Location $ScriptRoot
    try {
        $formatFiles = & gofmt -l .
        if ($LASTEXITCODE -ne 0) {
            Fail 'gofmt inspection failed'
        }
    } finally {
        Pop-Location
    }
    if (($formatFiles | Measure-Object).Count -ne 0) {
        Fail "gofmt changes required: $($formatFiles -join ', ')"
    }

    Assert-Success (Invoke-Go @('test', '-count=1', './...')) 'go test' | Out-Null
    Assert-Success (Invoke-Go @('vet', './...')) 'go vet' | Out-Null

    $binary = [IO.Path]::Combine($BuildRoot, 'opsmodel.exe')
    Assert-Success (Invoke-Go @('build', '-trimpath', '-buildvcs=false', '-o', $binary, './cmd/opsmodel')) 'go build' | Out-Null
    if (-not (Test-Path -LiteralPath $binary -PathType Leaf)) {
        Fail 'current-target binary is absent'
    }
    $metadata = Assert-Success (Invoke-Go @('version', '-m', $binary)) 'go version -m'
    Assert-Contains $metadata 'example.com/reliability-atlas/les0020' 'build metadata'

    $baseline = Assert-Success (Invoke-Lab @('baseline')) 'guided baseline'
    Assert-Contains $baseline '"operation_success":true' 'guided baseline'
    $guidedSelect = Assert-Success (Invoke-Lab @('inject', 'guided')) 'guided selection'
    Assert-Contains $guidedSelect '"case":"guided"' 'guided selection'
    $guidedScenario = Assert-Success (Invoke-Lab @('scenario')) 'guided scenario'
    Assert-Contains $guidedScenario '"reported_results":2' 'guided scenario'
    foreach ($view in @('contract', 'runtime', 'state', 'outcome')) {
        $observation = Assert-Success (Invoke-Lab @('observe', $view)) "guided observe $view"
        Assert-Contains $observation ('"view":"' + $view + '"') "guided observe $view"
    }
    $guidedRecovery = Assert-Success (Invoke-Lab @('recover')) 'guided recovery'
    Assert-Contains $guidedRecovery '"recovery":"created"' 'guided recovery'
    $guidedRecoveryAgain = Assert-Success (Invoke-Lab @('recover')) 'guided repeated recovery'
    Assert-Contains $guidedRecoveryAgain '"recovery":"already-complete"' 'guided repeated recovery'
    $guidedVerify = Assert-Success (Invoke-Lab @('verify')) 'guided verify'
    Assert-Contains $guidedVerify '"operation_success":true' 'guided verify'
    $guidedVerifyAgain = Assert-Success (Invoke-Lab @('verify')) 'guided repeated verify'
    Assert-Contains $guidedVerifyAgain '"verification":"already-complete"' 'guided repeated verify'
    $guidedStatus = Assert-Success (Invoke-Lab @('status')) 'guided status'
    Assert-Contains $guidedStatus 'verification=complete' 'guided status'
    $guidedCleanup = Assert-Success (Invoke-Lab @('cleanup')) 'guided cleanup'
    Assert-Contains $guidedCleanup 'cleanup_proven=true' 'guided cleanup'
    Assert-Contains (Assert-Success (Invoke-Lab @('check')) 'guided absence') 'state=absent' 'guided absence'

    Assert-Success (Invoke-Lab @('setup')) 'independent setup' | Out-Null
    Assert-Success (Invoke-Lab @('baseline')) 'independent baseline' | Out-Null
    Assert-Success (Invoke-Lab @('inject', 'independent')) 'independent selection' | Out-Null
    $raw = Assert-Success (Invoke-Lab @('scenario')) 'independent raw scenario'
    foreach ($required in @('op-network-417', 'client_deadline_ms', 'request_write_started', 'response_received')) {
        Assert-Contains $raw $required 'independent raw scenario'
    }
    foreach ($forbidden in @('authoritative', 'committed', 'no_effect', 'diagnosis', 'root_cause', 'recovery', 'retry_allowed', 'answer_key', 'duplicate_effects')) {
        Assert-NotContains $raw $forbidden 'independent raw scenario'
    }
    foreach ($view in @('contract', 'runtime', 'state', 'outcome')) {
        Assert-Success (Invoke-Lab @('observe', $view)) "independent observe $view" | Out-Null
    }
    $independentRecovery = Assert-Success (Invoke-Lab @('recover')) 'independent recovery'
    Assert-Contains $independentRecovery '"recovery":"created"' 'independent recovery'
    $independentRecoveryAgain = Assert-Success (Invoke-Lab @('recover')) 'independent repeated recovery'
    Assert-Contains $independentRecoveryAgain '"recovery":"already-complete"' 'independent repeated recovery'
    $independentVerify = Assert-Success (Invoke-Lab @('verify')) 'independent verify'
    Assert-Contains $independentVerify '"duplicate_receipts":0' 'independent verify'

    $foreign = [IO.Path]::Combine($ExpectedRoot, 'foreign.txt')
    [IO.File]::WriteAllText($foreign, "must-survive-refusal`n", (New-Object Text.UTF8Encoding($false)))
    $unexpectedFailure = Assert-Failure (Invoke-Lab @('cleanup')) 'unexpected artifact cleanup refusal'
    Assert-Contains $unexpectedFailure 'unexpected top-level artifact' 'unexpected artifact refusal'
    if (-not (Test-Path -LiteralPath $foreign -PathType Leaf)) {
        Fail 'unexpected artifact was deleted during refusal'
    }
    Remove-Item -LiteralPath $foreign -Force

    $manifestPath = [IO.Path]::Combine($ExpectedRoot, 'manifest.json')
    $savedManifest = [IO.File]::ReadAllBytes($manifestPath)
    try {
        $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
        $manifest.source_hash = ('0' * 64)
        [IO.File]::WriteAllText($manifestPath, (($manifest | ConvertTo-Json) + "`n"), (New-Object Text.UTF8Encoding($false)))
        $tamperFailure = Assert-Failure (Invoke-Lab @('status')) 'manifest tamper refusal'
        Assert-Contains $tamperFailure 'source or recorded source identity changed' 'manifest tamper refusal'
    } finally {
        [IO.File]::WriteAllBytes($manifestPath, $savedManifest)
    }
    Assert-Success (Invoke-Lab @('status')) 'restored manifest status' | Out-Null

    [IO.Directory]::CreateDirectory($ExternalRoot) | Out-Null
    $sentinel = [IO.Path]::Combine($ExternalRoot, 'must-survive.txt')
    [IO.File]::WriteAllText($sentinel, "must-survive`n", (New-Object Text.UTF8Encoding($false)))
    $descriptorPath = [IO.Path]::Combine($StateHome, 'session.json')
    $savedDescriptor = [IO.File]::ReadAllBytes($descriptorPath)
    try {
        $descriptor = Get-Content -Raw -LiteralPath $descriptorPath | ConvertFrom-Json
        $descriptor.lab_root = $ExternalRoot
        [IO.File]::WriteAllText($descriptorPath, (($descriptor | ConvertTo-Json) + "`n"), (New-Object Text.UTF8Encoding($false)))
        $descriptorFailure = Assert-Failure (Invoke-Lab @('cleanup')) 'descriptor boundary refusal'
        Assert-Contains $descriptorFailure 'outside the derived state boundary' 'descriptor boundary refusal'
        if (-not (Test-Path -LiteralPath $sentinel -PathType Leaf)) {
            Fail 'external sentinel changed during descriptor refusal'
        }
    } finally {
        [IO.File]::WriteAllBytes($descriptorPath, $savedDescriptor)
    }
    Assert-Success (Invoke-Lab @('cleanup')) 'descriptor restored cleanup' | Out-Null
    Remove-Item -LiteralPath $sentinel -Force
    [IO.Directory]::Delete($ExternalRoot, $false)

    $env:RELIABILITY_ATLAS_FORCE_ELEVATED = '1'
    $elevatedRefusal = Invoke-Lab @('check')
    if ($elevatedRefusal.Status -ne 77) {
        Fail "forced elevated guard returned $($elevatedRefusal.Status)"
    }
    Assert-Contains $elevatedRefusal.Output 'lab_refusal=elevated-session' 'forced elevated guard'
    $env:RELIABILITY_ATLAS_FORCE_ELEVATED = $null

    $finalCheck = Assert-Success (Invoke-Lab @('check')) 'final check'
    Assert-Contains $finalCheck 'state=absent' 'final check'
    $repeatCleanup = Assert-Success (Invoke-Lab @('cleanup')) 'idempotent cleanup'
    Assert-Contains $repeatCleanup 'cleanup=already-clean' 'idempotent cleanup'
    if (Test-Path -LiteralPath $ExpectedRoot) {
        Fail 'registered root remains after cleanup'
    }
    if ((Get-ChildItem -LiteralPath $StateHome -Force | Measure-Object).Count -ne 0) {
        Fail 'state home is not empty after cleanup'
    }
    Remove-BuildRoot
    if (Test-Path -LiteralPath $BuildRoot) { Fail 'verifier build root remains after cleanup' }
    [IO.Directory]::Delete($StateHome, $false)

    Write-Output 'verification_passed=true'
    Write-Output 'go_baseline=go1.22.x-windows-amd64'
    Write-Output 'gates=gofmt,go-test,go-vet,go-build,build-metadata'
    Write-Output 'cases=guided,independent'
    Write-Output 'idempotency=recover,verify,setup,cleanup'
    Write-Output 'refusals=unexpected-artifact,manifest-tamper,out-of-scope-descriptor,elevated-guard'
    Write-Output 'answer_isolation=raw-independent-input-has-no-derived-outcome-diagnosis-or-recovery'
    Write-Output 'network=disabled'
    Write-Output 'cleanup_proven=true'
} finally {
    $env:RELIABILITY_ATLAS_FORCE_ELEVATED = $null
    if (Test-Path -LiteralPath $StateHome) {
        try {
            $cleanup = Invoke-Lab @('cleanup')
            if (($cleanup.Status -eq 0) -and ((Get-ChildItem -LiteralPath $StateHome -Force | Measure-Object).Count -eq 0)) {
                [IO.Directory]::Delete($StateHome, $false)
            }
        } catch {
        }
    }
    if (Test-Path -LiteralPath $ExternalRoot) {
        $sentinel = [IO.Path]::Combine($ExternalRoot, 'must-survive.txt')
        if (Test-Path -LiteralPath $sentinel -PathType Leaf) {
            Remove-Item -LiteralPath $sentinel -Force
        }
        if ((Get-ChildItem -LiteralPath $ExternalRoot -Force | Measure-Object).Count -eq 0) {
            [IO.Directory]::Delete($ExternalRoot, $false)
        }
    }
    if (Test-Path -LiteralPath $BuildRoot) {
        try {
            Remove-BuildRoot
        } catch {
        }
    }
    Restore-Environment
}
