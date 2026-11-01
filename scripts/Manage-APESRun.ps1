[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('Initialize','Advance','Block','Resume','Complete','Show')][string]$Action,
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [string]$Workflow = '',
    [string]$RunId = '',
    [string]$Stage = '',
    [string]$Evidence = '',
    [string]$Reason = '',
    [switch]$ApprovalConfirmed
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "ProjectPath không tồn tại: $ProjectPath" }
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$root = Join-Path $project '.apes/runs'
$catalogPath = Join-Path $repoRoot 'config/workflows.json'
$catalog = Get-Content -LiteralPath $catalogPath -Raw | ConvertFrom-Json

function Save-State($state, [string]$path) {
    $tmp = "$path.tmp"
    $state.updatedAt = [DateTime]::UtcNow.ToString('o')
    $state | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $path -Force
}

if ($Action -eq 'Initialize') {
    if ([string]::IsNullOrWhiteSpace($Workflow)) { throw 'Initialize yêu cầu -Workflow.' }
    $definition = @($catalog.workflows | Where-Object { $_.id -eq $Workflow }) | Select-Object -First 1
    if ($null -eq $definition) { throw "Workflow không tồn tại: $Workflow" }
    $id = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8)
    $dir = Join-Path $root $id
    if (Test-Path -LiteralPath $dir) { throw "Run ID đã tồn tại, từ chối ghi đè: $id" }
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $state = [ordered]@{
        schemaVersion = 1; runId = $id; workflow = $Workflow; status = 'ACTIVE'
        currentStage = [string]$definition.stages[0]; stageIndex = 0
        completedStages = @(); checkpoints = @(); blockedReason = $null
        createdAt = [DateTime]::UtcNow.ToString('o'); updatedAt = [DateTime]::UtcNow.ToString('o')
    }
    $path = Join-Path $dir 'state.json'
    Save-State $state $path
    Write-Output "RUN_ID=$id"
    Write-Output "STATE=$path"
    Write-Output "CURRENT_STAGE=$($state.currentStage)"
    exit 0
}

if ([string]::IsNullOrWhiteSpace($RunId)) { throw "$Action yêu cầu -RunId." }
if ($RunId -notmatch '^[0-9]{8}T[0-9]{6}Z-[a-f0-9]{8}$') { throw 'RunId không đúng định dạng APES; từ chối đường dẫn không an toàn.' }
$path = Join-Path (Join-Path $root $RunId) 'state.json'
if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Không tìm thấy state: $path" }
$state = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
$definition = @($catalog.workflows | Where-Object { $_.id -eq $state.workflow }) | Select-Object -First 1
if ($null -eq $definition) { throw "Workflow definition không còn tồn tại: $($state.workflow)" }

if ($Action -eq 'Show') { $state | ConvertTo-Json -Depth 12; exit 0 }
if ($Action -eq 'Resume') {
    if ($state.status -ne 'BLOCKED') { throw 'Chỉ run BLOCKED mới được Resume.' }
    if ([string]::IsNullOrWhiteSpace($Reason)) { throw 'Resume yêu cầu -Reason ghi rõ điều kiện blocker đã được xử lý.' }
    $state.status = 'ACTIVE'
    $state.blockedReason = $null
    Save-State $state $path
    Write-Output "STATUS=$($state.status)"
    Write-Output "CURRENT_STAGE=$($state.currentStage)"
    exit 0
}
if ($state.status -eq 'COMPLETE') { throw 'Run đã COMPLETE; không thể sửa state.' }
if ($Action -ne 'Block' -and $state.status -eq 'BLOCKED') { throw 'Run đang BLOCKED; dùng -Action Resume sau khi blocker được xử lý.' }

switch ($Action) {
    'Advance' {
        if ([string]::IsNullOrWhiteSpace($Stage) -or [string]::IsNullOrWhiteSpace($Evidence)) { throw 'Advance yêu cầu -Stage và -Evidence; evidence không được để trống.' }
        if ($state.currentStage -ne $Stage) { throw "Stage mismatch: state=$($state.currentStage), requested=$Stage" }
        if ([int]$state.stageIndex -lt 0 -or [int]$state.stageIndex -ge $definition.stages.Count -or [string]$definition.stages[[int]$state.stageIndex] -ne $Stage) { throw 'Run state stage/index không khớp workflow catalog; từ chối chuyển bước.' }
        if ($Stage -eq 'APPROVAL' -and -not $ApprovalConfirmed) { throw 'APPROVAL gate cần -ApprovalConfirmed sau khi người dùng đã duyệt rõ ràng.' }
        $state.completedStages = @($state.completedStages) + @($Stage)
        $state.checkpoints = @($state.checkpoints) + @([ordered]@{stage=$Stage; evidence=$Evidence; recordedAt=[DateTime]::UtcNow.ToString('o')})
        $nextIndex = [int]$state.stageIndex + 1
        if ($nextIndex -lt $definition.stages.Count) {
            $state.stageIndex = $nextIndex
            $state.currentStage = [string]$definition.stages[$nextIndex]
        } else {
            $state.currentStage = 'READY_TO_COMPLETE'
        }
        $state.blockedReason = $null
    }
    'Block' {
        if ([string]::IsNullOrWhiteSpace($Reason)) { throw 'Block yêu cầu -Reason.' }
        $state.status = 'BLOCKED'
        $state.blockedReason = $Reason
    }
    'Complete' {
        if ($state.currentStage -ne 'READY_TO_COMPLETE') { throw 'Chỉ hoàn tất sau khi đã Advance qua toàn bộ stages của workflow.' }
        if ([string]::IsNullOrWhiteSpace($Evidence)) { throw 'Complete yêu cầu -Evidence (bằng chứng audit cuối).' }
        $state.status = 'COMPLETE'
        $state.checkpoints = @($state.checkpoints) + @([ordered]@{stage='FINAL_AUDIT'; evidence=$Evidence; recordedAt=[DateTime]::UtcNow.ToString('o')})
    }
}

Save-State $state $path
Write-Output "STATE_UPDATED=$path"
Write-Output "STATUS=$($state.status)"
Write-Output "CURRENT_STAGE=$($state.currentStage)"
