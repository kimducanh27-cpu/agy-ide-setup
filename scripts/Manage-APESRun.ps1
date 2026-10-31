[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('Initialize','Advance','Block','Complete','Show')][string]$Action,
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [string]$Workflow = '',
    [string]$RunId = '',
    [string]$Stage = '',
    [string]$Evidence = '',
    [string]$Reason = ''
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "ProjectPath không tồn tại: $ProjectPath" }
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$root = Join-Path $project '.apes/runs'
function Save-State($state, [string]$path) {
    $tmp = "$path.tmp"
    $state.updatedAt = [DateTime]::UtcNow.ToString('o')
    $state | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $path -Force
}
if ($Action -eq 'Initialize') {
    if ([string]::IsNullOrWhiteSpace($Workflow)) { throw 'Initialize yêu cầu -Workflow.' }
    $id = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8)
    $dir = Join-Path $root $id
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $state = [ordered]@{
        schemaVersion = 1; runId = $id; workflow = $Workflow; status = 'ACTIVE'
        currentStage = 'DISCOVERY'; completedStages = @(); checkpoints = @()
        blockedReason = $null; createdAt = [DateTime]::UtcNow.ToString('o'); updatedAt = [DateTime]::UtcNow.ToString('o')
    }
    $path = Join-Path $dir 'state.json'
    Save-State $state $path
    Write-Output "RUN_ID=$id"
    Write-Output "STATE=$path"
    exit 0
}
if ([string]::IsNullOrWhiteSpace($RunId)) { throw "$Action yêu cầu -RunId." }
$path = Join-Path (Join-Path $root $RunId) 'state.json'
if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Không tìm thấy state: $path" }
$state = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
if ($state.status -eq 'COMPLETE') { throw 'Run đã COMPLETE; không thể sửa state.' }
switch ($Action) {
    'Show' { $state | ConvertTo-Json -Depth 12; exit 0 }
    'Advance' {
        if ([string]::IsNullOrWhiteSpace($Stage) -or [string]::IsNullOrWhiteSpace($Evidence)) { throw 'Advance yêu cầu -Stage và -Evidence; evidence không được để trống.' }
        if ($state.currentStage -ne $Stage) { throw "Stage mismatch: state=$($state.currentStage), requested=$Stage" }
        $state.completedStages = @($state.completedStages) + @($Stage)
        $state.checkpoints = @($state.checkpoints) + @([ordered]@{stage=$Stage; evidence=$Evidence; recordedAt=[DateTime]::UtcNow.ToString('o')})
        $state.currentStage = 'NEXT_STAGE_PENDING'
        $state.blockedReason = $null
    }
    'Block' {
        if ([string]::IsNullOrWhiteSpace($Reason)) { throw 'Block yêu cầu -Reason.' }
        $state.status = 'BLOCKED'; $state.blockedReason = $Reason
    }
    'Complete' {
        if ([string]::IsNullOrWhiteSpace($Evidence)) { throw 'Complete yêu cầu -Evidence (bằng chứng audit cuối).' }
        $state.status = 'COMPLETE'
        $state.checkpoints = @($state.checkpoints) + @([ordered]@{stage='FINAL_AUDIT'; evidence=$Evidence; recordedAt=[DateTime]::UtcNow.ToString('o')})
    }
}
Save-State $state $path
Write-Output "STATE_UPDATED=$path"
Write-Output "STATUS=$($state.status)"
Write-Output "CURRENT_STAGE=$($state.currentStage)"
