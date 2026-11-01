[CmdletBinding()]
param(
    [ValidateSet('Project','Global','All')][string]$Scope = 'Project',
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$checks = 0

function Test-MattSkillsInstall([string]$AgentRoot,[string]$Label) {
    $markerPath = Join-Path $AgentRoot 'matt-skills.json'
    $skillsRoot = Join-Path $AgentRoot 'skills'

    $script:checks++
    if (-not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
        Write-Host "SKIP  $Label has no matt-skills.json (not installed there)" -ForegroundColor Yellow
        return
    }

    try {
        $marker = Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "FAIL  $Label marker is not valid JSON" -ForegroundColor Red
        $script:failures.Add("$Label matt-skills.json is not valid JSON")
        return
    }

    $expected = @($marker.skills)
    $script:checks++
    if ($expected.Count -eq 0) {
        Write-Host "FAIL  $Label marker lists no skills" -ForegroundColor Red
        $script:failures.Add("$Label marker lists no skills")
        return
    }

    $missing = @()
    $invalid = @()
    foreach ($name in $expected) {
        $manifest = Join-Path $skillsRoot (Join-Path $name 'SKILL.md')
        if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
            $missing += $name
            continue
        }
        $text = Get-Content -LiteralPath $manifest -Raw
        # The folder name and the frontmatter name must agree, otherwise Antigravity
        # registers a skill under one name and the marker tracks another.
        $nameOk = $text -match ('(?m)^name:\s*["'']?' + [regex]::Escape($name) + '["'']?\s*$')
        $descOk = $text -match '(?m)^description:\s*\S'
        if (-not ($nameOk -and $descOk)) { $invalid += $name }
    }

    $script:checks++
    if ($missing.Count -eq 0 -and $invalid.Count -eq 0) {
        Write-Host "PASS  ${Label}: $($expected.Count) mattpocock skills valid (ref $($marker.ref.Substring(0,7)), set $($marker.set))" -ForegroundColor Green
    } else {
        Write-Host "FAIL  $Label mattpocock skills incomplete or invalid" -ForegroundColor Red
        foreach ($name in $missing) { $script:failures.Add("$Label missing skill: $name") }
        foreach ($name in $invalid) { $script:failures.Add("$Label invalid skill frontmatter: $name") }
    }
}

Write-Host 'APES optional mattpocock/skills validation' -ForegroundColor Cyan

if ($Scope -in @('Project', 'All')) {
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        throw "Workspace not found: $ProjectPath"
    }
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    Test-MattSkillsInstall (Join-Path $project '.agents') 'Workspace'
}
if ($Scope -in @('Global', 'All')) {
    Test-MattSkillsInstall (Join-Path $HOME '.gemini/config') 'Global'
}

Write-Host "Checks: $checks | Failures: $($failures.Count)" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}
Write-Host 'All mattpocock/skills checks passed. This validates presence and metadata, not skill quality.' -ForegroundColor Green
