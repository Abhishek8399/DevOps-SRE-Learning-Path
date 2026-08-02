[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('check', 'setup', 'status', 'run', 'inject', 'scenario', 'observe', 'recover', 'verify-operation', 'cleanup')]
    [string]$Command,

    [Parameter(Position = 1)]
    [ValidateSet('baseline', 'guided', 'independent', 'operation', 'input', 'pipeline', 'errors', 'native', 'state', 'outcome')]
    [string]$Argument
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:LessonId = 'LES-0019'
$script:RootPrefix = 'reliability-atlas-LES-0019.'
$script:CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$script:CurrentSid = $script:CurrentIdentity.User
$script:CurrentSidText = $script:CurrentSid.Value
$script:TempRoot = [IO.Path]::GetFullPath($env:TEMP).TrimEnd([IO.Path]::DirectorySeparatorChar)
$script:DescriptorPath = Join-Path $script:TempRoot ("reliability-atlas-LES-0019-{0}.state.json" -f $script:CurrentSidText)
$script:SetupLockPath = Join-Path $script:TempRoot ("reliability-atlas-LES-0019-{0}.setup.lock" -f $script:CurrentSidText)
$script:FixturePath = Join-Path $PSScriptRoot 'fixtures\operation-model.json'
$script:AllowedNames = @(
    '.lesson-owner.json',
    '.cleanup-in-progress.json',
    'manifest.json',
    'operation-model.json',
    'baseline.json',
    'active-case.json',
    'recovery.json',
    'verification.json'
)
$script:Utf8NoBom = New-Object Text.UTF8Encoding($false)

function Throw-LabError {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw [InvalidOperationException]::new($Message)
}

function Test-IsElevated {
    $principal = New-Object Security.Principal.WindowsPrincipal($script:CurrentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsReparsePoint {
    param([Parameter(Mandatory = $true)][string]$Path)
    $item = Get-Item -Force -LiteralPath $Path
    return (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Get-OwnerSidText {
    param([Parameter(Mandatory = $true)][string]$Path)
    $owner = (Get-Acl -LiteralPath $Path).Owner
    if ($owner -match '^S-1-') {
        return ([Security.Principal.SecurityIdentifier]::new($owner)).Value
    }
    return ([Security.Principal.NTAccount]::new($owner).Translate([Security.Principal.SecurityIdentifier])).Value
}

function Protect-AtlasPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][bool]$IsDirectory
    )
    $acl = Get-Acl -LiteralPath $Path
    $acl.SetAccessRuleProtection($true, $false)
    foreach ($rule in @($acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]))) {
        [void]$acl.RemoveAccessRuleSpecific($rule)
    }
    $acl.SetOwner($script:CurrentSid)
    $inheritance = if ($IsDirectory) {
        [Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
    }
    else {
        [Security.AccessControl.InheritanceFlags]::None
    }
    $rule = New-Object Security.AccessControl.FileSystemAccessRule(
        $script:CurrentSid,
        [Security.AccessControl.FileSystemRights]::FullControl,
        $inheritance,
        [Security.AccessControl.PropagationFlags]::None,
        [Security.AccessControl.AccessControlType]::Allow
    )
    [void]$acl.AddAccessRule($rule)
    Set-Acl -LiteralPath $Path -AclObject $acl
}

function Assert-PrivatePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][bool]$IsDirectory,
        [Parameter(Mandatory = $true)][string]$Label
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        Throw-LabError "$Label is absent"
    }
    $item = Get-Item -Force -LiteralPath $Path
    if ($IsDirectory -ne [bool]$item.PSIsContainer) {
        Throw-LabError "$Label has the wrong filesystem kind"
    }
    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        Throw-LabError "$Label must not be a reparse point"
    }
    if ((Get-OwnerSidText -Path $Path) -ne $script:CurrentSidText) {
        Throw-LabError "$Label owner differs from the current identity"
    }
    $acl = Get-Acl -LiteralPath $Path
    if (-not $acl.AreAccessRulesProtected) {
        Throw-LabError "$Label ACL inheritance is not protected"
    }
    $rules = @($acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]))
    if ($rules.Count -ne 1) {
        Throw-LabError "$Label ACL has an unexpected rule count"
    }
    $rule = $rules[0]
    if ($rule.IdentityReference.Value -ne $script:CurrentSidText -or
        $rule.AccessControlType -ne [Security.AccessControl.AccessControlType]::Allow -or
        (($rule.FileSystemRights -band [Security.AccessControl.FileSystemRights]::FullControl) -ne [Security.AccessControl.FileSystemRights]::FullControl)) {
        Throw-LabError "$Label ACL is not current-user-only full control"
    }
}

function Assert-Environment {
    if (Test-IsElevated) {
        Throw-LabError 'run this lab from a non-elevated PowerShell process; administrator tokens are refused'
    }
    if (-not (Test-Path -LiteralPath $script:TempRoot -PathType Container)) {
        Throw-LabError 'the current user temporary directory is absent'
    }
    if (Test-IsReparsePoint -Path $script:TempRoot) {
        Throw-LabError 'the current user temporary directory must not be a reparse point'
    }
    if (-not (Test-Path -LiteralPath $script:FixturePath -PathType Leaf)) {
        Throw-LabError 'the checked-in operation model is absent'
    }
    try {
        $null = Get-Content -Raw -LiteralPath $script:FixturePath | ConvertFrom-Json
    }
    catch {
        Throw-LabError 'the checked-in operation model is not valid JSON'
    }
}

function ConvertTo-AtlasJson {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 16 -Compress)
}

function New-PrivateFileSecurity {
    $security = New-Object Security.AccessControl.FileSecurity
    $security.SetOwner($script:CurrentSid)
    $security.SetAccessRuleProtection($true, $false)
    $rule = New-Object Security.AccessControl.FileSystemAccessRule(
        $script:CurrentSid,
        [Security.AccessControl.FileSystemRights]::FullControl,
        [Security.AccessControl.AccessControlType]::Allow
    )
    [void]$security.AddAccessRule($rule)
    return $security
}

function Write-PrivateJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value,
        [switch]$CreateNew
    )
    $json = (ConvertTo-AtlasJson -Value $Value) + [Environment]::NewLine
    if ($CreateNew) {
        $stream = $null
        try {
            $security = New-PrivateFileSecurity
            $stream = New-Object IO.FileStream(
                $Path,
                [IO.FileMode]::CreateNew,
                [Security.AccessControl.FileSystemRights]::FullControl,
                [IO.FileShare]::None,
                4096,
                [IO.FileOptions]::WriteThrough,
                $security
            )
        }
        catch {
            Throw-LabError 'refusing to replace an existing or inaccessible private JSON file'
        }
        try {
            $bytes = $script:Utf8NoBom.GetBytes($json)
            [void]$stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush($true)
        }
        finally {
            $stream.Dispose()
        }
        return
    }
    [IO.File]::WriteAllText($Path, $json, $script:Utf8NoBom)
    Protect-AtlasPath -Path $Path -IsDirectory $false
}

function Assert-NoSetupLease {
    if (Test-Path -LiteralPath $script:SetupLockPath) {
        Throw-LabError 'setup ownership unavailable: an active, stale, or unexpected setup lock exists; preserve it for review'
    }
}

function Enter-SetupLease {
    $options = [IO.FileOptions]([int][IO.FileOptions]::WriteThrough -bor [int][IO.FileOptions]::DeleteOnClose)
    $stream = $null
    try {
        $security = New-PrivateFileSecurity
        $stream = New-Object IO.FileStream(
            $script:SetupLockPath,
            [IO.FileMode]::CreateNew,
            [Security.AccessControl.FileSystemRights]::FullControl,
            [IO.FileShare]::None,
            4096,
            $options,
            $security
        )
    }
    catch {
        Throw-LabError 'setup ownership unavailable: an active, stale, or unexpected setup lock exists; preserve it for review'
    }
    try {
        $record = [ordered]@{
            schemaVersion = 1
            lessonId = $script:LessonId
            ownerSid = $script:CurrentSidText
            processId = $PID
            nonce = [Guid]::NewGuid().ToString('N')
        }
        $bytes = $script:Utf8NoBom.GetBytes((ConvertTo-AtlasJson -Value $record) + [Environment]::NewLine)
        [void]$stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush($true)
        Assert-RegularPrivateFile -Path $script:SetupLockPath -Label 'setup ownership lock'
    }
    catch {
        $stream.Dispose()
        throw
    }
    return ,$stream
}

function Invoke-VerifierSetupHold {
    $value = [Environment]::GetEnvironmentVariable('RELIABILITY_ATLAS_TEST_SETUP_HOLD_MS', 'Process')
    if ([string]::IsNullOrEmpty($value)) {
        return
    }
    [int]$milliseconds = 0
    $parsed = [int]::TryParse($value, [ref]$milliseconds)
    if (-not $parsed -or $milliseconds -lt 1 -or $milliseconds -gt 5000) {
        Throw-LabError 'RELIABILITY_ATLAS_TEST_SETUP_HOLD_MS must be an integer from 1 through 5000'
    }
    Start-Sleep -Milliseconds $milliseconds
}

function Read-Json {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )
    try {
        return (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json)
    }
    catch {
        Throw-LabError "$Label is not valid JSON"
    }
}

function Assert-ExactProperties {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Label
    )
    $actual = @(($Value.PSObject.Properties.Name | Sort-Object)) -join ','
    $wanted = @(($Expected | Sort-Object)) -join ','
    if ($actual -cne $wanted) {
        Throw-LabError "$Label shape changed"
    }
}

function Get-RegisteredRootName {
    param([Parameter(Mandatory = $true)][string]$RootPath)
    $full = [IO.Path]::GetFullPath($RootPath)
    $parent = [IO.Path]::GetDirectoryName($full).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $leaf = [IO.Path]::GetFileName($full)
    if (-not $parent.Equals($script:TempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        Throw-LabError 'registered root is outside the exact temporary parent'
    }
    if ($leaf -cnotmatch '^reliability-atlas-LES-0019\.[0-9a-f]{32}$') {
        Throw-LabError 'registered root name is outside the exact lesson pattern'
    }
    return $full
}

function Assert-RootPath {
    param([Parameter(Mandatory = $true)][string]$RootPath)
    $full = Get-RegisteredRootName -RootPath $RootPath
    Assert-PrivatePath -Path $full -IsDirectory $true -Label 'registered root'
    return $full
}

function Assert-RegularPrivateFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )
    Assert-PrivatePath -Path $Path -IsDirectory $false -Label $Label
}

function Assert-NoOrphans {
    $orphans = @(Get-ChildItem -Force -LiteralPath $script:TempRoot -Directory | Where-Object {
        $_.Name -cmatch '^reliability-atlas-LES-0019\.[0-9a-f]{32}$'
    })
    if ($orphans.Count -gt 0) {
        Throw-LabError 'an unregistered LES-0019 candidate exists; preserve it for review'
    }
}

function Get-Descriptor {
    if (-not (Test-Path -LiteralPath $script:DescriptorPath)) {
        return $null
    }
    Assert-RegularPrivateFile -Path $script:DescriptorPath -Label 'state descriptor'
    $descriptor = Read-Json -Path $script:DescriptorPath -Label 'state descriptor'
    Assert-ExactProperties -Value $descriptor -Expected @('schemaVersion', 'lessonId', 'ownerSid', 'labRoot') -Label 'state descriptor'
    if ([int]$descriptor.schemaVersion -ne 1 -or
        [string]$descriptor.lessonId -cne $script:LessonId -or
        [string]$descriptor.ownerSid -cne $script:CurrentSidText) {
        Throw-LabError 'state descriptor identity changed'
    }
    $root = Get-RegisteredRootName -RootPath ([string]$descriptor.labRoot)
    if (-not (Test-Path -LiteralPath $root)) {
        return [pscustomobject]@{ Descriptor = $descriptor; Root = $root; RootAbsent = $true }
    }
    $root = Assert-RootPath -RootPath $root
    return [pscustomobject]@{ Descriptor = $descriptor; Root = $root; RootAbsent = $false }
}

function Assert-AllowedEntries {
    param([Parameter(Mandatory = $true)][string]$Root)
    foreach ($entry in @(Get-ChildItem -Force -LiteralPath $Root)) {
        if ($script:AllowedNames -cnotcontains $entry.Name) {
            Throw-LabError ("unexpected lab artifact: {0}" -f $entry.Name)
        }
        Assert-RegularPrivateFile -Path $entry.FullName -Label ("artifact {0}" -f $entry.Name)
    }
}

function Assert-Sentinel {
    param([Parameter(Mandatory = $true)][string]$Root)
    $path = Join-Path $Root '.lesson-owner.json'
    Assert-RegularPrivateFile -Path $path -Label 'lesson sentinel'
    $sentinel = Read-Json -Path $path -Label 'lesson sentinel'
    Assert-ExactProperties -Value $sentinel -Expected @('schemaVersion', 'lessonId', 'ownerSid', 'labRoot') -Label 'lesson sentinel'
    if ([int]$sentinel.schemaVersion -ne 1 -or
        [string]$sentinel.lessonId -cne $script:LessonId -or
        [string]$sentinel.ownerSid -cne $script:CurrentSidText -or
        -not ([string]$sentinel.labRoot).Equals($Root, [StringComparison]::OrdinalIgnoreCase)) {
        Throw-LabError 'lesson sentinel identity changed'
    }
}

function Assert-ManifestAndModel {
    param([Parameter(Mandatory = $true)][string]$Root)
    $manifestPath = Join-Path $Root 'manifest.json'
    $modelPath = Join-Path $Root 'operation-model.json'
    Assert-RegularPrivateFile -Path $manifestPath -Label 'manifest'
    Assert-RegularPrivateFile -Path $modelPath -Label 'installed operation model'
    $manifest = Read-Json -Path $manifestPath -Label 'manifest'
    Assert-ExactProperties -Value $manifest -Expected @('schemaVersion', 'lessonId', 'sourceSha256') -Label 'manifest'
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $script:FixturePath).Hash.ToLowerInvariant()
    $modelHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $modelPath).Hash.ToLowerInvariant()
    if ([int]$manifest.schemaVersion -ne 1 -or
        [string]$manifest.lessonId -cne $script:LessonId -or
        [string]$manifest.sourceSha256 -cne $sourceHash -or
        $modelHash -cne $sourceHash) {
        Throw-LabError 'manifest or installed operation model digest changed'
    }
    return (Read-Json -Path $modelPath -Label 'installed operation model')
}

function Assert-CleanupState {
    param([Parameter(Mandatory = $true)][string]$Root)
    Assert-AllowedEntries -Root $Root
    $markerPath = Join-Path $Root '.cleanup-in-progress.json'
    Assert-RegularPrivateFile -Path $markerPath -Label 'cleanup marker'
    $marker = Read-Json -Path $markerPath -Label 'cleanup marker'
    Assert-ExactProperties -Value $marker -Expected @('schemaVersion', 'lessonId', 'ownerSid', 'labRoot', 'phase') -Label 'cleanup marker'
    if ([int]$marker.schemaVersion -ne 1 -or
        [string]$marker.lessonId -cne $script:LessonId -or
        [string]$marker.ownerSid -cne $script:CurrentSidText -or
        [string]$marker.phase -cne 'remove-allowlisted-files' -or
        -not ([string]$marker.labRoot).Equals($Root, [StringComparison]::OrdinalIgnoreCase)) {
        Throw-LabError 'cleanup marker identity changed'
    }
}

function Get-LabState {
    $state = Get-Descriptor
    if ($null -eq $state) {
        Assert-NoOrphans
        return $null
    }
    if ($state.RootAbsent) {
        return [pscustomobject]@{ Root = $state.Root; Model = $null; Cleanup = $true; DescriptorOnly = $true }
    }
    Assert-AllowedEntries -Root $state.Root
    $cleanupPath = Join-Path $state.Root '.cleanup-in-progress.json'
    if (Test-Path -LiteralPath $cleanupPath) {
        Assert-CleanupState -Root $state.Root
        return [pscustomobject]@{ Root = $state.Root; Model = $null; Cleanup = $true }
    }
    Assert-Sentinel -Root $state.Root
    $model = Assert-ManifestAndModel -Root $state.Root
    return [pscustomobject]@{ Root = $state.Root; Model = $model; Cleanup = $false }
}

function New-LabState {
    $lease = $null
    $root = $null
    $created = $false
    $descriptorPublished = $false
    try {
        $lease = Enter-SetupLease
        Invoke-VerifierSetupHold
        if ($null -ne (Get-LabState)) {
            Throw-LabError 'registered state already exists'
        }
        $root = Join-Path $script:TempRoot ($script:RootPrefix + [Guid]::NewGuid().ToString('N'))
        [void](New-Item -ItemType Directory -Path $root -ErrorAction Stop)
        $created = $true
        Protect-AtlasPath -Path $root -IsDirectory $true
        $sentinel = [ordered]@{ schemaVersion = 1; lessonId = $script:LessonId; ownerSid = $script:CurrentSidText; labRoot = $root }
        Write-PrivateJson -Path (Join-Path $root '.lesson-owner.json') -Value $sentinel
        [IO.File]::Copy($script:FixturePath, (Join-Path $root 'operation-model.json'), $false)
        Protect-AtlasPath -Path (Join-Path $root 'operation-model.json') -IsDirectory $false
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $script:FixturePath).Hash.ToLowerInvariant()
        $manifest = [ordered]@{ schemaVersion = 1; lessonId = $script:LessonId; sourceSha256 = $hash }
        Write-PrivateJson -Path (Join-Path $root 'manifest.json') -Value $manifest
        $descriptor = [ordered]@{ schemaVersion = 1; lessonId = $script:LessonId; ownerSid = $script:CurrentSidText; labRoot = $root }
        Write-PrivateJson -Path $script:DescriptorPath -Value $descriptor -CreateNew
        $descriptorPublished = $true
        $null = Get-LabState
        Write-Output ("setup=ready root={0}" -f $root)
    }
    catch {
        $setupFailure = $_.Exception
        if ($created -and (Test-Path -LiteralPath $root -PathType Container) -and -not (Test-IsReparsePoint -Path $root)) {
            foreach ($name in @('manifest.json', 'operation-model.json', '.lesson-owner.json')) {
                $path = Join-Path $root $name
                if (Test-Path -LiteralPath $path -PathType Leaf) {
                    Remove-Item -Force -LiteralPath $path
                }
            }
            if (@(Get-ChildItem -Force -LiteralPath $root).Count -eq 0) {
                Remove-Item -Force -LiteralPath $root
            }
        }
        if ($descriptorPublished -and (Test-Path -LiteralPath $script:DescriptorPath -PathType Leaf)) {
            $published = Get-Descriptor
            if ($null -eq $published -or
                -not $published.Root.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or
                -not $published.RootAbsent) {
                Throw-LabError 'failed setup state changed before exact cleanup; preserve the descriptor and root for review'
            }
            Remove-Item -Force -LiteralPath $script:DescriptorPath
        }
        throw $setupFailure
    }
    finally {
        if ($null -ne $lease) {
            $lease.Dispose()
        }
    }
}

function Invoke-Baseline {
    $state = Get-LabState
    if ($null -eq $state -or $state.Cleanup) {
        Throw-LabError 'setup must be complete before baseline'
    }
    $path = Join-Path $state.Root 'baseline.json'
    if (Test-Path -LiteralPath $path) {
        $existing = Read-Json -Path $path -Label 'baseline'
        Write-Output (ConvertTo-AtlasJson -Value $existing)
        return
    }
    Write-PrivateJson -Path $path -Value $state.Model.baseline
    Write-Output (ConvertTo-AtlasJson -Value $state.Model.baseline)
}

function Set-ActiveCase {
    param([Parameter(Mandatory = $true)][string]$CaseName)
    $state = Get-LabState
    if ($null -eq $state -or $state.Cleanup) {
        Throw-LabError 'setup must be complete before case injection'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $state.Root 'baseline.json'))) {
        Throw-LabError 'baseline must run before case injection'
    }
    foreach ($name in @('active-case.json', 'recovery.json', 'verification.json')) {
        if (Test-Path -LiteralPath (Join-Path $state.Root $name)) {
            Throw-LabError 'a case lifecycle already exists; clean up before another case'
        }
    }
    $record = [ordered]@{ schemaVersion = 1; lessonId = $script:LessonId; case = $CaseName; phase = 'injected' }
    Write-PrivateJson -Path (Join-Path $state.Root 'active-case.json') -Value $record
    Write-Output ("incident_ready=true case={0}" -f $CaseName)
}

function Get-ActiveCase {
    param([Parameter(Mandatory = $true)]$State)
    $path = Join-Path $State.Root 'active-case.json'
    Assert-RegularPrivateFile -Path $path -Label 'active case'
    $record = Read-Json -Path $path -Label 'active case'
    Assert-ExactProperties -Value $record -Expected @('schemaVersion', 'lessonId', 'case', 'phase') -Label 'active case'
    if ([int]$record.schemaVersion -ne 1 -or [string]$record.lessonId -cne $script:LessonId -or
        @('guided', 'independent') -cnotcontains [string]$record.case -or [string]$record.phase -cne 'injected') {
        Throw-LabError 'active case identity changed'
    }
    return [string]$record.case
}

function Show-Scenario {
    $state = Get-LabState
    if ($null -eq $state -or $state.Cleanup) {
        Throw-LabError 'an active independent case is required'
    }
    $caseName = Get-ActiveCase -State $state
    if ($caseName -cne 'independent') {
        Throw-LabError 'scenario output is reserved for the independent case'
    }
    Write-Output (ConvertTo-AtlasJson -Value $state.Model.independent.scenario)
}

function Show-Observation {
    param([Parameter(Mandatory = $true)][string]$View)
    $state = Get-LabState
    if ($null -eq $state -or $state.Cleanup) {
        Throw-LabError 'an active case is required before observation'
    }
    $caseName = Get-ActiveCase -State $state
    $caseModel = $state.Model.PSObject.Properties[$caseName].Value
    $property = $caseModel.observations.PSObject.Properties[$View]
    if ($null -eq $property) {
        Throw-LabError 'the requested observation view is unavailable'
    }
    Write-Output (ConvertTo-AtlasJson -Value $property.Value)
}

function Invoke-Recovery {
    $state = Get-LabState
    if ($null -eq $state -or $state.Cleanup) {
        Throw-LabError 'an active case is required before recovery'
    }
    $caseName = Get-ActiveCase -State $state
    $path = Join-Path $state.Root 'recovery.json'
    if (Test-Path -LiteralPath $path) {
        $existing = Read-Json -Path $path -Label 'recovery record'
        Write-Output (ConvertTo-AtlasJson -Value $existing)
        return
    }
    $caseModel = $state.Model.PSObject.Properties[$caseName].Value
    Write-PrivateJson -Path $path -Value $caseModel.recovery
    Write-Output (ConvertTo-AtlasJson -Value $caseModel.recovery)
}

function Invoke-OperationVerification {
    $state = Get-LabState
    if ($null -eq $state -or $state.Cleanup) {
        Throw-LabError 'an active recovered case is required before verification'
    }
    $caseName = Get-ActiveCase -State $state
    if (-not (Test-Path -LiteralPath (Join-Path $state.Root 'recovery.json'))) {
        Throw-LabError 'recovery must complete before operation verification'
    }
    $path = Join-Path $state.Root 'verification.json'
    if (Test-Path -LiteralPath $path) {
        $existing = Read-Json -Path $path -Label 'verification record'
        Write-Output (ConvertTo-AtlasJson -Value $existing)
        return
    }
    $caseModel = $state.Model.PSObject.Properties[$caseName].Value
    Write-PrivateJson -Path $path -Value $caseModel.verification
    Write-Output (ConvertTo-AtlasJson -Value $caseModel.verification)
}

function Remove-LabState {
    $state = Get-LabState
    if ($null -eq $state) {
        Write-Output 'cleanup=already-clean cleanup_proven=true'
        return
    }
    if ($state.PSObject.Properties.Name -contains 'DescriptorOnly' -and $state.DescriptorOnly) {
        Assert-RegularPrivateFile -Path $script:DescriptorPath -Label 'state descriptor'
        Assert-NoOrphans
        Remove-Item -Force -LiteralPath $script:DescriptorPath
        Assert-NoOrphans
        Write-Output 'cleanup=completed-descriptor-only cleanup_proven=true state=absent'
        return
    }
    $markerPath = Join-Path $state.Root '.cleanup-in-progress.json'
    if (-not $state.Cleanup) {
        $marker = [ordered]@{
            schemaVersion = 1
            lessonId = $script:LessonId
            ownerSid = $script:CurrentSidText
            labRoot = $state.Root
            phase = 'remove-allowlisted-files'
        }
        Write-PrivateJson -Path $markerPath -Value $marker
        $state = Get-LabState
    }
    foreach ($name in @('verification.json', 'recovery.json', 'active-case.json', 'baseline.json', 'operation-model.json', 'manifest.json', '.lesson-owner.json')) {
        $path = Join-Path $state.Root $name
        if (Test-Path -LiteralPath $path) {
            Assert-RegularPrivateFile -Path $path -Label ("cleanup artifact {0}" -f $name)
            Remove-Item -Force -LiteralPath $path
        }
    }
    Assert-RegularPrivateFile -Path $markerPath -Label 'cleanup marker'
    Remove-Item -Force -LiteralPath $markerPath
    if (@(Get-ChildItem -Force -LiteralPath $state.Root).Count -ne 0) {
        Throw-LabError 'registered root is not empty after exact cleanup'
    }
    Remove-Item -Force -LiteralPath $state.Root
    Assert-RegularPrivateFile -Path $script:DescriptorPath -Label 'state descriptor'
    Remove-Item -Force -LiteralPath $script:DescriptorPath
    if ((Test-Path -LiteralPath $state.Root) -or (Test-Path -LiteralPath $script:DescriptorPath)) {
        Throw-LabError 'cleanup absence proof failed'
    }
    Assert-NoOrphans
    Write-Output 'cleanup=complete cleanup_proven=true state=absent'
}

function Show-Status {
    $state = Get-LabState
    if ($null -eq $state) {
        Write-Output 'state=absent'
        return
    }
    $phase = if ($state.Cleanup) { 'cleanup-in-progress' } elseif (Test-Path -LiteralPath (Join-Path $state.Root 'verification.json')) { 'verified' } elseif (Test-Path -LiteralPath (Join-Path $state.Root 'recovery.json')) { 'recovered' } elseif (Test-Path -LiteralPath (Join-Path $state.Root 'active-case.json')) { 'incident-active' } elseif (Test-Path -LiteralPath (Join-Path $state.Root 'baseline.json')) { 'baseline-ready' } else { 'ready' }
    Write-Output ("state={0} root={1} owner_sid={2} network=none elevated=false" -f $phase, $state.Root, $script:CurrentSidText)
}

function Invoke-LabCommand {
    Assert-Environment
    Assert-NoSetupLease
    switch ($Command) {
        'check' {
            $state = Get-LabState
            $value = if ($null -eq $state) { 'absent' } else { 'registered' }
            Write-Output ("environment=ready engine=Windows-PowerShell-{0} privilege=non-elevated network=none state={1}" -f $PSVersionTable.PSVersion, $value)
        }
        'setup' {
            if ($PSCmdlet.ShouldProcess($script:TempRoot, 'Create guarded LES-0019 lab state')) { New-LabState }
        }
        'status' { Show-Status }
        'run' {
            if ($Argument -cne 'baseline') { Throw-LabError 'run requires the baseline argument' }
            if ($PSCmdlet.ShouldProcess('registered LES-0019 state', 'Write deterministic baseline')) { Invoke-Baseline }
        }
        'inject' {
            if (@('guided', 'independent') -cnotcontains $Argument) { Throw-LabError 'inject requires guided or independent' }
            if ($PSCmdlet.ShouldProcess('registered LES-0019 state', ("Inject {0} case" -f $Argument))) { Set-ActiveCase -CaseName $Argument }
        }
        'scenario' { Show-Scenario }
        'observe' {
            if (@('operation', 'input', 'pipeline', 'errors', 'native', 'state', 'outcome') -cnotcontains $Argument) { Throw-LabError 'observe requires a named evidence view' }
            Show-Observation -View $Argument
        }
        'recover' {
            if ($PSCmdlet.ShouldProcess('registered LES-0019 state', 'Record bounded modeled recovery')) { Invoke-Recovery }
        }
        'verify-operation' {
            if ($PSCmdlet.ShouldProcess('registered LES-0019 state', 'Record modeled operation verification')) { Invoke-OperationVerification }
        }
        'cleanup' {
            if ($PSCmdlet.ShouldProcess('registered LES-0019 state', 'Remove only validated allowlisted state')) { Remove-LabState }
        }
    }
}

try {
    Invoke-LabCommand
    exit 0
}
catch {
    $safeMessage = [Regex]::Replace([string]$_.Exception.Message, '[\r\n]+', ' ')
    [Console]::Error.WriteLine(('lab_error={0}' -f $safeMessage))
    exit 1
}
