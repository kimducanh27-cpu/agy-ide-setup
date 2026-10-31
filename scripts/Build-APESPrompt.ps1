[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('quick-fix','standard-feature','full-project','deep-research','hard-review')][string]$Workflow,
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [Parameter(Mandatory=$true)][string]$Goal,
    [ValidateSet('Auto','ManualCheckpoint')][string]$Mode = 'Auto',
    [string]$OutputPath = ''
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$catalogPath = Join-Path $repoRoot 'config/workflows.json'
$templatePath = Join-Path $repoRoot 'templates/engine/BASE-PROMPT-VI.md'
if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "ProjectPath không tồn tại: $ProjectPath" }
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$catalog = Get-Content -LiteralPath $catalogPath -Raw | ConvertFrom-Json
$item = @($catalog.workflows | Where-Object { $_.id -eq $Workflow }) | Select-Object -First 1
if ($null -eq $item) { throw "Workflow không tồn tại trong catalog: $Workflow" }
$stages = ($item.stages | ForEach-Object { "- $_" }) -join "`n"
$gateLines = foreach ($stage in $item.stages) {
    $checks = @($item.gates.$stage)
    "### $stage"
    foreach ($check in $checks) { "- [ ] $check" }
}
$gates = $gateLines -join "`n"
$template = Get-Content -LiteralPath $templatePath -Raw
$replacements = @{
    '{{PROJECT_PATH}}' = $project
    '{{GOAL}}' = $Goal
    '{{WORKFLOW_NAME}}' = $item.name
    '{{WORKFLOW_DESCRIPTION}}' = $item.description
    '{{RISK}}' = $item.risk
    '{{APPROVAL_REQUIRED}}' = [string]$item.approvalRequired
    '{{MAX_REPAIR_ROUNDS}}' = [string]$item.maxRepairRounds
    '{{MODE}}' = $Mode
    '{{STAGES}}' = $stages
    '{{GATES}}' = $gates
}
foreach ($key in $replacements.Keys) { $template = $template.Replace($key, [string]$replacements[$key]) }
if ($OutputPath) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Set-Content -LiteralPath $OutputPath -Value $template -Encoding UTF8
    Write-Host "Prompt đã được tạo: $OutputPath"
} else { Write-Output $template }
