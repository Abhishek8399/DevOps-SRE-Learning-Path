[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Action = 'help',

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Remaining = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$LessonId = 'LES-0020'
$ScriptRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$DescriptorName = 'session.json'
$RootPrefix = 'reliability-atlas-LES-0020.'
$AllowedTopFiles = @('manifest.json', 'baseline.json', 'case.json', 'receipt.json', 'verification.json', 'cpu.pprof')
$AllowedTopDirectories = @('gocache', 'tmp', 'bin')
$AllowedBinFiles = @('opsmodel', 'opsmodel.exe', 'opsmodel-linux-amd64', 'opsmodel-linux-amd64.exe', 'model.test', 'model.test.exe')

function Write-ErrorLine {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Fail {
    param([string]$Message)
    throw $Message
}

function Test-IsElevated {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-NormalUser {
    if (($env:RELIABILITY_ATLAS_VERIFY_MODE -eq '1') -and ($env:RELIABILITY_ATLAS_FORCE_ELEVATED -eq '1')) {
        Write-ErrorLine 'lab_refusal=elevated-session'
        exit 77
    }
    if (Test-IsElevated) {
        Write-ErrorLine 'lab_refusal=elevated-session'
        exit 77
    }
}

function Get-CanonicalTemp {
    return [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
}

function Assert-UnderTemp {
    param([string]$Path)
    $temp = Get-CanonicalTemp
    $full = [IO.Path]::GetFullPath($Path)
    $prefix = $temp + [IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        Fail "path is outside the current user temporary directory: $full"
    }
    return $full
}

function Assert-NoReparse {
    param([string]$Path, [string]$Label)
    $item = Get-Item -LiteralPath $Path -Force
    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        Fail "$Label is a reparse point: $Path"
    }
}

function Assert-OwnedByCurrentIdentity {
    param([string]$Path, [string]$Label)
    $owner = (Get-Acl -LiteralPath $Path).Owner
    $current = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    if (-not $owner.Equals($current, [StringComparison]::OrdinalIgnoreCase)) {
        Fail "$Label owner mismatch: expected $current"
    }
}

function Get-StateContext {
    if ([string]::IsNullOrWhiteSpace($env:RELIABILITY_ATLAS_STATE_HOME)) {
        Fail 'RELIABILITY_ATLAS_STATE_HOME must name a fresh LES-0020 state directory under the current user temporary directory'
    }
    $stateHome = Assert-UnderTemp $env:RELIABILITY_ATLAS_STATE_HOME
    $name = [IO.Path]::GetFileName($stateHome)
    if ($name -notmatch '^reliability-atlas-LES-0020-state\.([a-f0-9]{32})$') {
        Fail 'RELIABILITY_ATLAS_STATE_HOME has an invalid lesson-specific name'
    }
    $token = $Matches[1]
    $root = Assert-UnderTemp ([IO.Path]::Combine((Get-CanonicalTemp), $RootPrefix + $token))
    return [pscustomobject]@{
        StateHome = $stateHome
        Token = $token
        Root = $root
        Descriptor = [IO.Path]::Combine($stateHome, $DescriptorName)
    }
}

function Write-Utf8Atomic {
    param([string]$Path, [string]$Text)
    $parent = [IO.Path]::GetDirectoryName($Path)
    $candidate = [IO.Path]::Combine($parent, '.' + [IO.Path]::GetFileName($Path) + '.' + [guid]::NewGuid().ToString('N') + '.tmp')
    $encoding = New-Object Text.UTF8Encoding($false)
    try {
        [IO.File]::WriteAllText($candidate, $Text, $encoding)
        Move-Item -LiteralPath $candidate -Destination $Path
    } finally {
        if (Test-Path -LiteralPath $candidate) {
            Remove-Item -LiteralPath $candidate -Force
        }
    }
}

function Get-SourceHash {
    $relativeFiles = @(
        'go.mod',
        'cmd\opsmodel\main.go',
        'internal\model\model.go',
        'internal\model\model_test.go'
    )
    $rows = foreach ($relative in $relativeFiles) {
        $path = [IO.Path]::Combine($ScriptRoot, $relative)
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            Fail "required source is missing: $relative"
        }
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        $relative.Replace('\', '/') + '=' + $hash
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes(($rows -join "`n"))
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

function Read-JsonFile {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Fail "$Label is missing"
    }
    Assert-NoReparse $Path $Label
    try {
        return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    } catch {
        Fail "$Label is not valid JSON"
    }
}

function Assert-ExactPropertySet {
    param([object]$Object, [string[]]$Expected, [string]$Label)
    $actual = @($Object.PSObject.Properties.Name | Sort-Object)
    $wanted = @($Expected | Sort-Object)
    if (($actual -join ',') -ne ($wanted -join ',')) {
        Fail "$Label property set is invalid"
    }
}

function Assert-StateHome {
    param([object]$Context, [bool]$Create)
    if (-not (Test-Path -LiteralPath $Context.StateHome)) {
        if (-not $Create) {
            return $false
        }
        [IO.Directory]::CreateDirectory($Context.StateHome) | Out-Null
    }
    if (-not (Test-Path -LiteralPath $Context.StateHome -PathType Container)) {
        Fail 'state home is not a directory'
    }
    Assert-NoReparse $Context.StateHome 'state home'
    Assert-OwnedByCurrentIdentity $Context.StateHome 'state home'
    return $true
}

function Assert-Tree {
    param([string]$Root, [bool]$DeepCacheScan = $false)
    $allowedTop = @($AllowedTopFiles + $AllowedTopDirectories)
    foreach ($item in Get-ChildItem -LiteralPath $Root -Force) {
        if ($allowedTop -notcontains $item.Name) {
            Fail "unexpected top-level artifact: $($item.Name)"
        }
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            Fail "artifact is a reparse point: $($item.FullName)"
        }
        Assert-OwnedByCurrentIdentity $item.FullName "artifact $($item.Name)"
    }
    foreach ($name in $AllowedTopFiles) {
        $path = [IO.Path]::Combine($Root, $name)
        if (Test-Path -LiteralPath $path) {
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                Fail "expected regular file: $name"
            }
            Assert-NoReparse $path $name
        }
    }
    foreach ($name in $AllowedTopDirectories) {
        $path = [IO.Path]::Combine($Root, $name)
        if (Test-Path -LiteralPath $path) {
            if (-not (Test-Path -LiteralPath $path -PathType Container)) {
                Fail "expected directory: $name"
            }
            Assert-NoReparse $path $name
        }
    }
    $bin = [IO.Path]::Combine($Root, 'bin')
    if (Test-Path -LiteralPath $bin -PathType Container) {
        foreach ($item in Get-ChildItem -LiteralPath $bin -Force) {
            if ($AllowedBinFiles -notcontains $item.Name) {
                Fail "unexpected bin artifact: $($item.Name)"
            }
            if (-not (Test-Path -LiteralPath $item.FullName -PathType Leaf)) {
                Fail "bin artifact is not a file: $($item.Name)"
            }
            Assert-NoReparse $item.FullName 'bin artifact'
        }
    }
    if ($DeepCacheScan) { foreach ($treeName in @('gocache', 'tmp')) {
        $tree = [IO.Path]::Combine($Root, $treeName)
        if (Test-Path -LiteralPath $tree -PathType Container) {
            foreach ($item in Get-ChildItem -LiteralPath $tree -Force -Recurse) {
                $full = [IO.Path]::GetFullPath($item.FullName)
                $prefix = [IO.Path]::GetFullPath($tree).TrimEnd('\') + '\'
                if (-not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
                    Fail "$treeName content escaped its root"
                }
                if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                    Fail "$treeName contains a reparse point"
                }
            }
        }
    } }
}

function Get-ValidatedSession {
    param([object]$Context)
    if (-not (Assert-StateHome $Context $false)) {
        Fail 'state home is absent'
    }
    $descriptor = Read-JsonFile $Context.Descriptor 'session descriptor'
    Assert-ExactPropertySet $descriptor @('state_version', 'lesson_id', 'owner_sid', 'lab_root', 'source_hash') 'session descriptor'
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    if (($descriptor.state_version -ne 1) -or ($descriptor.lesson_id -ne $LessonId) -or ($descriptor.owner_sid -ne $sid)) {
        Fail 'session descriptor identity is invalid'
    }
    $descriptorRoot = [IO.Path]::GetFullPath([string]$descriptor.lab_root)
    if (-not $descriptorRoot.Equals($Context.Root, [StringComparison]::OrdinalIgnoreCase)) {
        Fail 'session descriptor root is outside the derived state boundary'
    }
    if (-not (Test-Path -LiteralPath $Context.Root -PathType Container)) {
        Fail 'registered lab root is absent'
    }
    Assert-NoReparse $Context.Root 'lab root'
    Assert-OwnedByCurrentIdentity $Context.Root 'lab root'
    Assert-Tree $Context.Root

    $manifestPath = [IO.Path]::Combine($Context.Root, 'manifest.json')
    $manifest = Read-JsonFile $manifestPath 'manifest'
    Assert-ExactPropertySet $manifest @('schema_version', 'lesson_id', 'token', 'source_hash') 'manifest'
    if (($manifest.schema_version -ne 1) -or ($manifest.lesson_id -ne $LessonId) -or ($manifest.token -ne $Context.Token)) {
        Fail 'manifest identity is invalid'
    }
    $expectedHash = Get-SourceHash
    if (($manifest.source_hash -ne $expectedHash) -or ($descriptor.source_hash -ne $expectedHash)) {
        Fail 'source or recorded source identity changed'
    }
    return [pscustomobject]@{
        Root = $Context.Root
        Descriptor = $descriptor
        Manifest = $manifest
    }
}

function Invoke-GoModel {
    param([string[]]$Arguments, [string]$Root)
    $oldProxy = $env:GOPROXY
    $oldSum = $env:GOSUMDB
    $oldCache = $env:GOCACHE
    $oldTmp = $env:GOTMPDIR
    $cachePath = [IO.Path]::Combine($Root, 'gocache')
    $temporaryPath = [IO.Path]::Combine($Root, 'tmp')
    $verifierBinary = $null
    if (($env:RELIABILITY_ATLAS_VERIFY_MODE -eq '1') -and ($env:RELIABILITY_ATLAS_USE_CALLER_GO_WORKDIR -eq '1')) {
        $context = Get-StateContext
        $buildRoot = Assert-UnderTemp ([IO.Path]::Combine((Get-CanonicalTemp), 'reliability-atlas-LES-0020-build.' + $context.Token))
        $expectedCache = [IO.Path]::Combine($buildRoot, 'gocache')
        $expectedTmp = [IO.Path]::Combine($buildRoot, 'tmp')
        $cachePath = [IO.Path]::GetFullPath($env:GOCACHE)
        $temporaryPath = [IO.Path]::GetFullPath($env:GOTMPDIR)
        if ((-not $cachePath.Equals($expectedCache, [StringComparison]::OrdinalIgnoreCase)) -or
            (-not $temporaryPath.Equals($expectedTmp, [StringComparison]::OrdinalIgnoreCase))) {
            Fail 'verifier Go working directories are outside the derived build boundary'
        }
        foreach ($path in @($buildRoot, $cachePath, $temporaryPath)) {
            if (-not (Test-Path -LiteralPath $path -PathType Container)) {
                Fail 'verifier Go working directory is absent'
            }
            Assert-NoReparse $path 'verifier Go working directory'
            Assert-OwnedByCurrentIdentity $path 'verifier Go working directory'
        }
        $verifierBinary = [IO.Path]::Combine($buildRoot, 'opsmodel.exe')
        if (-not (Test-Path -LiteralPath $verifierBinary -PathType Leaf)) {
            Fail 'verified prebuilt Go model is absent'
        }
        Assert-NoReparse $verifierBinary 'verified prebuilt Go model'
    }
    try {
        $env:GOPROXY = 'off'
        $env:GOSUMDB = 'off'
        $env:GOCACHE = $cachePath
        $env:GOTMPDIR = $temporaryPath
        Push-Location $ScriptRoot
        try {
            if ($null -ne $verifierBinary) {
                $output = & $verifierBinary @Arguments
            } else {
                $output = & go run ./cmd/opsmodel @Arguments
            }
            if ($LASTEXITCODE -ne 0) {
                Fail "Go model failed with exit code $LASTEXITCODE"
            }
            return ($output -join "`n")
        } finally {
            Pop-Location
        }
    } finally {
        $env:GOPROXY = $oldProxy
        $env:GOSUMDB = $oldSum
        $env:GOCACHE = $oldCache
        $env:GOTMPDIR = $oldTmp
    }
}

function Get-SelectedCase {
    param([string]$Root)
    $selection = Read-JsonFile ([IO.Path]::Combine($Root, 'case.json')) 'case selection'
    Assert-ExactPropertySet $selection @('record', 'case') 'case selection'
    if (($selection.record -ne 'case_selection') -or (($selection.case -ne 'guided') -and ($selection.case -ne 'independent'))) {
        Fail 'case selection is invalid'
    }
    return [string]$selection.case
}

function Assert-ArgumentCount {
    param([int]$Expected)
    if ($Remaining.Count -ne $Expected) {
        Fail "action $Action expects $Expected argument(s)"
    }
}

function Show-Status {
    param([object]$Session)
    $baseline = if (Test-Path -LiteralPath ([IO.Path]::Combine($Session.Root, 'baseline.json'))) { 'complete' } else { 'pending' }
    $case = if (Test-Path -LiteralPath ([IO.Path]::Combine($Session.Root, 'case.json'))) { Get-SelectedCase $Session.Root } else { 'none' }
    $receipt = if (Test-Path -LiteralPath ([IO.Path]::Combine($Session.Root, 'receipt.json'))) { 'present' } else { 'absent' }
    $verification = if (Test-Path -LiteralPath ([IO.Path]::Combine($Session.Root, 'verification.json'))) { 'complete' } else { 'absent' }
    Write-Output 'state=ready'
    Write-Output "lab_root=$($Session.Root)"
    Write-Output "baseline=$baseline"
    Write-Output "case=$case"
    Write-Output "receipt=$receipt"
    Write-Output "verification=$verification"
}

function Remove-VerifiedTree {
    param([object]$Session)
    Assert-Tree $Session.Root $true

    foreach ($name in $AllowedTopFiles) {
        $path = [IO.Path]::Combine($Session.Root, $name)
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
        }
    }
    foreach ($name in @('bin', 'tmp', 'gocache')) {
        $path = [IO.Path]::Combine($Session.Root, $name)
        if (Test-Path -LiteralPath $path) {
            Assert-NoReparse $path $name
            [IO.Directory]::Delete($path, $true)
        }
    }
    if ((Get-ChildItem -LiteralPath $Session.Root -Force | Measure-Object).Count -ne 0) {
        Fail 'lab root is not empty after exact allowlisted cleanup'
    }
    [IO.Directory]::Delete($Session.Root, $false)
}

Assert-NormalUser

try {
    $context = Get-StateContext
    switch ($Action.ToLowerInvariant()) {
        'help' {
            Assert-ArgumentCount 0
            Write-Output 'usage=lab.ps1 check|setup|root|status|baseline|inject guided|independent|scenario|observe contract|runtime|state|outcome|recover|verify|cleanup'
        }
        'check' {
            Assert-ArgumentCount 0
            $stateExists = Assert-StateHome $context $false
            $descriptorExists = $stateExists -and (Test-Path -LiteralPath $context.Descriptor)
            $rootExists = Test-Path -LiteralPath $context.Root
            if (-not $descriptorExists -and -not $rootExists) {
                Write-Output 'state=absent'
            } elseif (-not $descriptorExists -and $rootExists) {
                Fail 'orphan lab root exists without its descriptor'
            } else {
                $session = Get-ValidatedSession $context
                Show-Status $session
            }
        }
        'setup' {
            Assert-ArgumentCount 0
            Assert-StateHome $context $true | Out-Null
            if (Test-Path -LiteralPath $context.Descriptor) {
                $session = Get-ValidatedSession $context
                Write-Output 'setup=already-present'
                Write-Output "lab_root=$($session.Root)"
                break
            }
            if (Test-Path -LiteralPath $context.Root) {
                Fail 'derived lab root already exists without a valid descriptor'
            }

            [IO.Directory]::CreateDirectory($context.Root) | Out-Null
            foreach ($directory in @('gocache', 'tmp', 'bin')) {
                [IO.Directory]::CreateDirectory([IO.Path]::Combine($context.Root, $directory)) | Out-Null
            }
            $sourceHash = Get-SourceHash
            $manifest = [ordered]@{
                schema_version = 1
                lesson_id = $LessonId
                token = $context.Token
                source_hash = $sourceHash
            } | ConvertTo-Json
            Write-Utf8Atomic ([IO.Path]::Combine($context.Root, 'manifest.json')) ($manifest + "`n")

            $descriptor = [ordered]@{
                state_version = 1
                lesson_id = $LessonId
                owner_sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                lab_root = $context.Root
                source_hash = $sourceHash
            } | ConvertTo-Json
            Write-Utf8Atomic $context.Descriptor ($descriptor + "`n")
            $session = Get-ValidatedSession $context
            Write-Output 'setup=complete'
            Write-Output "lab_root=$($session.Root)"
        }
        'root' {
            Assert-ArgumentCount 0
            $session = Get-ValidatedSession $context
            Write-Output $session.Root
        }
        'status' {
            Assert-ArgumentCount 0
            $session = Get-ValidatedSession $context
            Show-Status $session
        }
        'baseline' {
            Assert-ArgumentCount 0
            $session = Get-ValidatedSession $context
            Invoke-GoModel @('baseline', '-root', $session.Root) $session.Root
        }
        'inject' {
            Assert-ArgumentCount 1
            $session = Get-ValidatedSession $context
            if (-not (Test-Path -LiteralPath ([IO.Path]::Combine($session.Root, 'baseline.json')))) {
                Fail 'baseline must run before case selection'
            }
            $caseName = $Remaining[0].ToLowerInvariant()
            if (($caseName -ne 'guided') -and ($caseName -ne 'independent')) {
                Fail 'case must be guided or independent'
            }
            Invoke-GoModel @('select', '-root', $session.Root, '-case', $caseName) $session.Root
        }
        'scenario' {
            Assert-ArgumentCount 0
            $session = Get-ValidatedSession $context
            $caseName = Get-SelectedCase $session.Root
            Invoke-GoModel @('scenario', '-case', $caseName) $session.Root
        }
        'observe' {
            Assert-ArgumentCount 1
            $session = Get-ValidatedSession $context
            $view = $Remaining[0].ToLowerInvariant()
            if (@('contract', 'runtime', 'state', 'outcome') -notcontains $view) {
                Fail 'view must be contract, runtime, state, or outcome'
            }
            $caseName = Get-SelectedCase $session.Root
            Invoke-GoModel @('observe', '-case', $caseName, '-view', $view) $session.Root
        }
        'recover' {
            Assert-ArgumentCount 0
            $session = Get-ValidatedSession $context
            $caseName = Get-SelectedCase $session.Root
            Invoke-GoModel @('recover', '-root', $session.Root, '-case', $caseName) $session.Root
        }
        'verify' {
            Assert-ArgumentCount 0
            $session = Get-ValidatedSession $context
            $caseName = Get-SelectedCase $session.Root
            Invoke-GoModel @('verify', '-root', $session.Root, '-case', $caseName) $session.Root
        }
        'cleanup' {
            Assert-ArgumentCount 0
            $stateExists = Assert-StateHome $context $false
            $descriptorExists = $stateExists -and (Test-Path -LiteralPath $context.Descriptor)
            $rootExists = Test-Path -LiteralPath $context.Root
            if (-not $descriptorExists -and -not $rootExists) {
                Write-Output 'cleanup=already-clean'
                Write-Output 'cleanup_proven=true'
                break
            }
            if (-not $descriptorExists) {
                Fail 'cleanup refused because the derived root lacks a valid descriptor'
            }
            $session = Get-ValidatedSession $context
            Remove-VerifiedTree $session
            Remove-Item -LiteralPath $context.Descriptor -Force
            if ((Test-Path -LiteralPath $context.Root) -or (Test-Path -LiteralPath $context.Descriptor)) {
                Fail 'cleanup absence proof failed'
            }
            Write-Output 'cleanup=complete'
            Write-Output 'cleanup_proven=true'
        }
        default {
            Fail "unknown action: $Action"
        }
    }
} catch {
    Write-ErrorLine "lab_error=$($_.Exception.Message)"
    exit 1
}
