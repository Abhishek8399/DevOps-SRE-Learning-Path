[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:PowerShellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$script:LabScript = Join-Path $PSScriptRoot 'lab.ps1'
$script:FixturePath = Join-Path $PSScriptRoot 'fixtures\operation-model.json'
$script:CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$script:CurrentSid = $script:CurrentIdentity.User
$script:CurrentSidText = $script:CurrentSid.Value
$script:TempRoot = [IO.Path]::GetFullPath($env:TEMP).TrimEnd([IO.Path]::DirectorySeparatorChar)
$script:DescriptorPath = Join-Path $script:TempRoot ("reliability-atlas-LES-0019-{0}.state.json" -f $script:CurrentSidText)
$script:SetupLockPath = Join-Path $script:TempRoot ("reliability-atlas-LES-0019-{0}.setup.lock" -f $script:CurrentSidText)
$script:Utf8NoBom = New-Object Text.UTF8Encoding($false)
$script:UnexpectedPath = $null
$script:ExternalRoot = $null
$script:SavedDescriptorBytes = $null
$script:SavedModelBytes = $null
$script:SetupLockFixturePresent = $false
$script:SetupLockFixtureContent = $null
$script:ConcurrentSetupProcess = $null

function Fail-Verification {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw [InvalidOperationException]::new($Message)
}

function Protect-Path {
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
    $inheritance = if ($IsDirectory) { [Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit' } else { [Security.AccessControl.InheritanceFlags]::None }
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

function Invoke-Lab {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    $savedPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& $script:PowerShellExe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $script:LabScript @Arguments 2>&1)
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $savedPreference
    }
    return [pscustomobject]@{ Code = $code; Text = ($output | Out-String).Trim() }
}

function Assert-Success {
    param([string[]]$Arguments, [string]$Contains)
    $result = Invoke-Lab -Arguments $Arguments
    if ($result.Code -ne 0) { Fail-Verification ("command failed: {0}; output={1}" -f ($Arguments -join ' '), $result.Text) }
    if ($Contains -and $result.Text -notlike ("*{0}*" -f $Contains)) { Fail-Verification ("command output lacked '{0}': {1}" -f $Contains, $result.Text) }
    return $result.Text
}

function Assert-Failure {
    param([string[]]$Arguments, [string]$Label)
    $result = Invoke-Lab -Arguments $Arguments
    if ($result.Code -eq 0) { Fail-Verification ("expected refusal for {0}; output={1}" -f $Label, $result.Text) }
    return $result.Text
}

function Get-RootFromDescriptor {
    $descriptor = Get-Content -Raw -LiteralPath $script:DescriptorPath | ConvertFrom-Json
    return [string]$descriptor.labRoot
}

$principal = New-Object Security.Principal.WindowsPrincipal($script:CurrentIdentity)
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Fail-Verification 'run the verifier from a non-elevated PowerShell process'
}
if (-not (Test-Path -LiteralPath $script:PowerShellExe -PathType Leaf)) { Fail-Verification 'Windows PowerShell 5.1 executable is absent' }
if (-not (Test-Path -LiteralPath $script:LabScript -PathType Leaf)) { Fail-Verification 'lab.ps1 is absent' }
if (-not (Test-Path -LiteralPath $script:FixturePath -PathType Leaf)) { Fail-Verification 'operation model is absent' }

try {
    Assert-Success -Arguments @('check') -Contains 'state=absent' | Out-Null

    Assert-Success -Arguments @('setup', '-WhatIf') -Contains 'What if:' | Out-Null
    Assert-Success -Arguments @('check') -Contains 'state=absent' | Out-Null

    $staleLockContent = "verifier-owned unexpected setup lock; preserve`r`n"
    $script:SetupLockFixtureContent = $staleLockContent
    [IO.File]::WriteAllText($script:SetupLockPath, $staleLockContent, $script:Utf8NoBom)
    $script:SetupLockFixturePresent = $true
    Protect-Path -Path $script:SetupLockPath -IsDirectory $false
    $staleCheck = Assert-Failure -Arguments @('check') -Label 'stale setup lock check'
    $staleSetup = Assert-Failure -Arguments @('setup') -Label 'stale setup lock setup'
    foreach ($value in @($staleCheck, $staleSetup)) {
        if ($value -notlike '*setup ownership unavailable*') {
            Fail-Verification ("stale setup lock refusal lacked ownership message: {0}" -f $value)
        }
    }
    if ((Get-Content -Raw -LiteralPath $script:SetupLockPath) -cne $staleLockContent) {
        Fail-Verification 'stale setup lock changed during refusal'
    }
    if (Test-Path -LiteralPath $script:DescriptorPath) {
        Fail-Verification 'stale setup lock refusal published a descriptor'
    }
    Remove-Item -Force -LiteralPath $script:SetupLockPath
    $script:SetupLockFixturePresent = $false
    $script:SetupLockFixtureContent = $null

    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $script:PowerShellExe
    $startInfo.Arguments = ('-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{0}" setup' -f $script:LabScript.Replace('"', '\"'))
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.EnvironmentVariables['RELIABILITY_ATLAS_TEST_SETUP_HOLD_MS'] = '4000'
    $script:ConcurrentSetupProcess = New-Object Diagnostics.Process
    $script:ConcurrentSetupProcess.StartInfo = $startInfo
    [void]$script:ConcurrentSetupProcess.Start()

    $lockDeadline = [DateTime]::UtcNow.AddSeconds(5)
    while (-not (Test-Path -LiteralPath $script:SetupLockPath -PathType Leaf) -and
        -not $script:ConcurrentSetupProcess.HasExited -and
        [DateTime]::UtcNow -lt $lockDeadline) {
        Start-Sleep -Milliseconds 25
    }
    if (-not (Test-Path -LiteralPath $script:SetupLockPath -PathType Leaf)) {
        Fail-Verification 'concurrent setup did not acquire its ownership lock within five seconds'
    }
    $contender = Invoke-Lab -Arguments @('setup')
    if ($contender.Code -eq 0 -or $contender.Text -notlike '*setup ownership unavailable*') {
        Fail-Verification ("concurrent setup contender was not refused safely: {0}" -f $contender.Text)
    }
    if (-not $script:ConcurrentSetupProcess.WaitForExit(10000)) {
        $script:ConcurrentSetupProcess.Kill()
        $script:ConcurrentSetupProcess.WaitForExit()
        Fail-Verification 'setup owner exceeded the bounded ten-second completion wait'
    }
    $ownerOutput = $script:ConcurrentSetupProcess.StandardOutput.ReadToEnd().Trim()
    $ownerError = $script:ConcurrentSetupProcess.StandardError.ReadToEnd().Trim()
    $ownerCode = $script:ConcurrentSetupProcess.ExitCode
    $script:ConcurrentSetupProcess.Dispose()
    $script:ConcurrentSetupProcess = $null
    if ($ownerCode -ne 0 -or $ownerOutput -notlike '*setup=ready*') {
        Fail-Verification ("setup owner failed: code={0}; output={1}; error={2}" -f $ownerCode, $ownerOutput, $ownerError)
    }
    if (Test-Path -LiteralPath $script:SetupLockPath) {
        Fail-Verification 'setup ownership lock survived owner completion'
    }
    $registeredRoots = @(Get-ChildItem -Force -LiteralPath $script:TempRoot -Directory | Where-Object {
        $_.Name -cmatch '^reliability-atlas-LES-0019\.[0-9a-f]{32}$'
    })
    if ($registeredRoots.Count -ne 1) {
        Fail-Verification ("concurrent setup produced {0} candidate roots instead of one" -f $registeredRoots.Count)
    }
    Assert-Success -Arguments @('status') -Contains 'state=ready' | Out-Null
    Assert-Success -Arguments @('cleanup') -Contains 'cleanup_proven=true' | Out-Null
    Assert-Success -Arguments @('check') -Contains 'state=absent' | Out-Null

    Assert-Success -Arguments @('setup') -Contains 'setup=ready' | Out-Null
    Assert-Success -Arguments @('run', 'baseline') -Contains 'ops-ps-1900' | Out-Null
    Assert-Success -Arguments @('inject', 'guided') -Contains 'case=guided' | Out-Null
    foreach ($view in @('operation', 'input', 'pipeline', 'errors', 'native', 'state', 'outcome')) {
        Assert-Success -Arguments @('observe', $view) -Contains '{' | Out-Null
    }
    Assert-Success -Arguments @('recover') -Contains 'publishedRecordCount' | Out-Null
    Assert-Success -Arguments @('verify-operation') -Contains 'postcondition' | Out-Null
    Assert-Success -Arguments @('status') -Contains 'state=verified' | Out-Null
    Assert-Success -Arguments @('cleanup') -Contains 'cleanup_proven=true' | Out-Null
    Assert-Success -Arguments @('cleanup') -Contains 'cleanup=already-clean' | Out-Null

    Assert-Success -Arguments @('setup') -Contains 'setup=ready' | Out-Null
    Assert-Success -Arguments @('run', 'baseline') -Contains 'ops-ps-1900' | Out-Null
    Assert-Success -Arguments @('inject', 'independent') -Contains 'case=independent' | Out-Null
    $scenario = Assert-Success -Arguments @('scenario') -Contains 'ops-ps-1902'
    foreach ($forbidden in @('classification', 'firstFailedBoundary', 'retryEligible', 'requiredNextDecision', 'recovery', 'authoritativeReplicaCount')) {
        if ($scenario -match [Regex]::Escape($forbidden)) { Fail-Verification ("independent scenario leaked field: {0}" -f $forbidden) }
    }
    foreach ($view in @('operation', 'input', 'pipeline', 'errors', 'native', 'state', 'outcome')) {
        Assert-Success -Arguments @('observe', $view) -Contains '{' | Out-Null
    }
    Assert-Success -Arguments @('recover') -Contains 'publishedRecordCount' | Out-Null
    Assert-Success -Arguments @('verify-operation') -Contains 'ops-ps-1902' | Out-Null
    Assert-Success -Arguments @('cleanup') -Contains 'state=absent' | Out-Null

    Assert-Success -Arguments @('setup') -Contains 'setup=ready' | Out-Null
    Assert-Success -Arguments @('run', 'baseline') -Contains 'ops-ps-1900' | Out-Null
    $root = Get-RootFromDescriptor
    $script:UnexpectedPath = Join-Path $root 'unexpected.txt'
    [IO.File]::WriteAllText($script:UnexpectedPath, "must survive refusal`r`n", $script:Utf8NoBom)
    Assert-Failure -Arguments @('status') -Label 'unexpected artifact status' | Out-Null
    Assert-Failure -Arguments @('cleanup') -Label 'unexpected artifact cleanup' | Out-Null
    if (-not (Test-Path -LiteralPath $script:UnexpectedPath -PathType Leaf)) { Fail-Verification 'unexpected artifact was changed during refusal' }
    Remove-Item -Force -LiteralPath $script:UnexpectedPath
    $script:UnexpectedPath = $null

    $modelPath = Join-Path $root 'operation-model.json'
    $script:SavedModelBytes = [IO.File]::ReadAllBytes($modelPath)
    [IO.File]::AppendAllText($modelPath, " `r`n", $script:Utf8NoBom)
    Assert-Failure -Arguments @('status') -Label 'model tamper status' | Out-Null
    [IO.File]::WriteAllBytes($modelPath, $script:SavedModelBytes)
    $script:SavedModelBytes = $null
    Assert-Success -Arguments @('status') -Contains 'state=baseline-ready' | Out-Null

    $script:SavedDescriptorBytes = [IO.File]::ReadAllBytes($script:DescriptorPath)
    $script:ExternalRoot = Join-Path $script:TempRoot ("reliability-atlas-LES-0019-external.{0}" -f [Guid]::NewGuid().ToString('N'))
    [void](New-Item -ItemType Directory -Path $script:ExternalRoot)
    $externalTarget = Join-Path $script:ExternalRoot 'must-survive.txt'
    [IO.File]::WriteAllText($externalTarget, "must survive descriptor refusal`r`n", $script:Utf8NoBom)
    $badDescriptor = [ordered]@{ schemaVersion = 1; lessonId = 'LES-0019'; ownerSid = $script:CurrentSidText; labRoot = $script:ExternalRoot }
    [IO.File]::WriteAllText($script:DescriptorPath, (($badDescriptor | ConvertTo-Json -Compress) + [Environment]::NewLine), $script:Utf8NoBom)
    Assert-Failure -Arguments @('status') -Label 'descriptor redirection status' | Out-Null
    Assert-Failure -Arguments @('cleanup') -Label 'descriptor redirection cleanup' | Out-Null
    if ((Get-Content -Raw -LiteralPath $externalTarget) -cne "must survive descriptor refusal`r`n") { Fail-Verification 'external target changed during descriptor refusal' }
    [IO.File]::WriteAllBytes($script:DescriptorPath, $script:SavedDescriptorBytes)
    $script:SavedDescriptorBytes = $null
    Remove-Item -Force -LiteralPath $externalTarget
    Remove-Item -Force -LiteralPath $script:ExternalRoot
    $script:ExternalRoot = $null

    $marker = [ordered]@{ schemaVersion = 1; lessonId = 'LES-0019'; ownerSid = $script:CurrentSidText; labRoot = $root; phase = 'remove-allowlisted-files' }
    $markerPath = Join-Path $root '.cleanup-in-progress.json'
    [IO.File]::WriteAllText($markerPath, (($marker | ConvertTo-Json -Compress) + [Environment]::NewLine), $script:Utf8NoBom)
    Protect-Path -Path $markerPath -IsDirectory $false
    Remove-Item -Force -LiteralPath (Join-Path $root 'baseline.json')
    Assert-Success -Arguments @('cleanup') -Contains 'cleanup_proven=true' | Out-Null
    Assert-Success -Arguments @('check') -Contains 'state=absent' | Out-Null

    Write-Output 'verification_passed=true'
    Write-Output 'engine=Windows-PowerShell-5.1'
    Write-Output 'cases=guided,independent'
    Write-Output 'refusals=whatif,setup-contention,stale-setup-lock,unexpected-artifact,model-tamper,descriptor-redirection'
    Write-Output 'elevation_refusal=implemented-reviewer-test-only'
    Write-Output 'setup_concurrency=one-owner-one-contender-refused-one-root'
    Write-Output 'interruption=cleanup-resume-tested'
    Write-Output 'answer_isolation=raw-independent-scenario-without-derived-diagnosis-or-recovery'
    Write-Output 'network_mutation=none'
    Write-Output 'host_mutation=acl-protected-current-user-temp-state-only'
    Write-Output 'cleanup_proven=true'
}
finally {
    if ($null -ne $script:ConcurrentSetupProcess) {
        try {
            if (-not $script:ConcurrentSetupProcess.HasExited) {
                $script:ConcurrentSetupProcess.Kill()
                $script:ConcurrentSetupProcess.WaitForExit()
            }
        }
        finally {
            $script:ConcurrentSetupProcess.Dispose()
            $script:ConcurrentSetupProcess = $null
        }
    }
    if ($script:SetupLockFixturePresent -and (Test-Path -LiteralPath $script:SetupLockPath -PathType Leaf)) {
        try {
            $lockItem = Get-Item -Force -LiteralPath $script:SetupLockPath
            $lockOwner = (Get-Acl -LiteralPath $script:SetupLockPath).Owner
            if ($lockOwner -notmatch '^S-1-') {
                $lockOwner = ([Security.Principal.NTAccount]::new($lockOwner).Translate([Security.Principal.SecurityIdentifier])).Value
            }
            $lockContent = Get-Content -Raw -LiteralPath $script:SetupLockPath
            if (($lockItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
                $lockOwner -eq $script:CurrentSidText -and
                $lockContent -ceq $script:SetupLockFixtureContent) {
                Remove-Item -Force -LiteralPath $script:SetupLockPath
            }
            else {
                [Console]::Error.WriteLine('verifier_cleanup_warning=setup lock fixture identity changed; preserving it for review')
            }
        }
        catch {
            [Console]::Error.WriteLine('verifier_cleanup_warning=setup lock fixture identity changed; preserving it for review')
        }
    }
    if ($null -ne $script:SavedDescriptorBytes -and (Test-Path -LiteralPath $script:DescriptorPath -PathType Leaf)) {
        [IO.File]::WriteAllBytes($script:DescriptorPath, $script:SavedDescriptorBytes)
    }
    if ($null -ne $script:SavedModelBytes -and (Test-Path -LiteralPath $script:DescriptorPath -PathType Leaf)) {
        try {
            $root = Get-RootFromDescriptor
            $modelPath = Join-Path $root 'operation-model.json'
            if (Test-Path -LiteralPath $modelPath -PathType Leaf) {
                [IO.File]::WriteAllBytes($modelPath, $script:SavedModelBytes)
            }
        }
        catch {
            $warning = [Regex]::Replace([string]$_.Exception.Message, '[\r\n]+', ' ')
            [Console]::Error.WriteLine(('verifier_cleanup_warning={0}' -f $warning))
        }
    }
    if ($script:UnexpectedPath -and (Test-Path -LiteralPath $script:UnexpectedPath -PathType Leaf)) {
        Remove-Item -Force -LiteralPath $script:UnexpectedPath
    }
    if ($script:ExternalRoot -and (Test-Path -LiteralPath $script:ExternalRoot -PathType Container)) {
        $target = Join-Path $script:ExternalRoot 'must-survive.txt'
        if (Test-Path -LiteralPath $target -PathType Leaf) { Remove-Item -Force -LiteralPath $target }
        if (@(Get-ChildItem -Force -LiteralPath $script:ExternalRoot).Count -eq 0) { Remove-Item -Force -LiteralPath $script:ExternalRoot }
    }
}
