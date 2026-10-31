[CmdletBinding()]
param(
    [ValidateSet('Project','Global','All')][string]$Scope = 'Project',
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$checks = 0

function Test-ImpeccableInstall([string]$Root,[string]$Label) {
    $manifest = Join-Path $Root 'SKILL.md'
    $script:checks++
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        Write-Host "FAIL  $Label skill manifest" -ForegroundColor Red
        $script:failures.Add("$Label skill manifest missing")
        return
    }

    $raw = Get-Content -LiteralPath $manifest -Raw
    $nameOk = $raw -match '(?m)^name:\s*impeccable\s*$'
    $versionMatch = [regex]::Match($raw, '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\s*$')
    $files = @(
        'scripts\impeccable.cmd',
        'scripts\engine-checksums.txt',
        'reference\craft-floor.md',
        'reference\critique.md',
        'reference\audit.md',
        'LICENSE'
    )
    $missing = @($files | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Root $_) -PathType Leaf) })
    if ($nameOk -and $versionMatch.Success -and $missing.Count -eq 0) {
        Write-Host "PASS  $Label Impeccable skill v$($versionMatch.Groups[1].Value)" -ForegroundColor Green
    } else {
        Write-Host "FAIL  $Label Impeccable skill integrity" -ForegroundColor Red
        $script:failures.Add("$Label Impeccable skill invalid; missing files: $($missing -join ', ')")
    }
}

Write-Host 'APES optional Impeccable validation' -ForegroundColor Cyan
if ($Scope -in @('Project','All')) {
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        throw "Không tìm thấy workspace: $ProjectPath"
    }
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    Test-ImpeccableInstall (Join-Path $project '.agent\skills\impeccable') 'Workspace'
}
if ($Scope -in @('Global','All')) {
    Test-ImpeccableInstall (Join-Path $HOME '.gemini\config\skills\impeccable') 'Global'
}

Write-Host "Checks: $checks | Failures: $($failures.Count)" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}
Write-Host 'All Impeccable installation checks passed. This validates files/metadata, not visual quality or hook availability.' -ForegroundColor Green
