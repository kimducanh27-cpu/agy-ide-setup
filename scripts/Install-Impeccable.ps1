[CmdletBinding()]
param(
    [ValidateSet('Project','Global','All')][string]$Scope = 'Project',
    [string]$ProjectPath = (Get-Location).Path,
    [ValidatePattern('^skill-v[0-9]+\.[0-9]+\.[0-9]+$')][string]$Version = 'skill-v4.8.0'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$releaseVersion = $Version -replace '^skill-v', ''
$tempRoot = Join-Path $env:TEMP ('apes-impeccable-' + [guid]::NewGuid().ToString('N'))
$zipPath = Join-Path $tempRoot 'impeccable-upstream.zip'
$extractRoot = Join-Path $tempRoot 'extract'
$backupBase = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA 'APES\backups'
} else {
    Join-Path $env:TEMP 'APES\backups'
}
$backupRoot = Join-Path $backupBase ('impeccable-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$downloadUrl = 'https://codeload.github.com/pbakaus/impeccable/zip/refs/tags/' + $Version

function Install-ImpeccableTarget([string]$SourceSkill,[string]$Destination,[string]$Label) {
    $parent = Split-Path -Parent $Destination

    if (Test-Path -LiteralPath $Destination) {
        if (-not (Test-Path -LiteralPath $Destination -PathType Container)) {
            throw "Đích đã tồn tại nhưng không phải thư mục; từ chối ghi đè: $Destination"
        }

        $existingManifest = Join-Path $Destination 'SKILL.md'
        if (-not (Test-Path -LiteralPath $existingManifest -PathType Leaf)) {
            throw "Đích đã tồn tại nhưng không phải Impeccable; từ chối ghi đè: $Destination"
        }
        $existingText = Get-Content -LiteralPath $existingManifest -Raw
        if ($existingText -notmatch '(?m)^name:\s*impeccable\s*$') {
            throw "Tên skill tại đích không phải impeccable; từ chối ghi đè: $Destination"
        }

        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        $safeLabel = $Label -replace '[^a-zA-Z0-9_-]', '_'
        $backupDestination = Join-Path $backupRoot $safeLabel
        Copy-Item -LiteralPath $Destination -Destination $backupDestination -Recurse -Force
        Write-Host "BACKUP: $Destination -> $backupDestination" -ForegroundColor Yellow
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Copy-Item -LiteralPath $SourceSkill -Destination $parent -Recurse -Force
    Write-Host "INSTALLED: $Destination" -ForegroundColor Green
}

$oldProtocol = [Net.ServicePointManager]::SecurityProtocol
try {
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container) -and $Scope -in @('Project','All')) {
        throw "Không tìm thấy workspace: $ProjectPath"
    }

    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null

    # Windows PowerShell 5.1: use TLS 1.2 for this HTTPS download in this process only.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "Downloading Impeccable upstream tag $Version ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force

    $manifest = Get-ChildItem -LiteralPath $extractRoot -Filter 'SKILL.md' -File -Recurse |
        Where-Object { $_.FullName -match '[\\/]\.agent[\\/]skills[\\/]impeccable[\\/]SKILL\.md$' } |
        Select-Object -First 1

    if ($null -eq $manifest) {
        throw 'Không tìm thấy build Antigravity .agent/skills/impeccable/SKILL.md trong archive upstream.'
    }

    $sourceSkill = $manifest.Directory.FullName
    $skillText = Get-Content -LiteralPath $manifest.FullName -Raw
    if ($skillText -notmatch '(?m)^name:\s*impeccable\s*$') {
        throw 'Skill upstream không có name: impeccable; hủy cài đặt.'
    }
    if ($skillText -notmatch ('(?m)^version:\s*' + [regex]::Escape($releaseVersion) + '\s*$')) {
        throw "Version trong SKILL.md không khớp tag $Version; hủy cài đặt."
    }

    foreach ($relative in @('scripts\impeccable.cmd','scripts\engine-checksums.txt','reference\craft-floor.md','reference\critique.md','reference\audit.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $sourceSkill $relative) -PathType Leaf)) {
            throw "Thiếu file upstream bắt buộc: $relative"
        }
    }

    # Preserve the upstream Apache-2.0 license alongside the skill payload.
    $upstreamRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $sourceSkill))
    $licenseSource = Join-Path $upstreamRoot 'LICENSE'
    if (-not (Test-Path -LiteralPath $licenseSource -PathType Leaf)) {
        throw 'Không tìm thấy LICENSE upstream; hủy cài đặt.'
    }
    Copy-Item -LiteralPath $licenseSource -Destination (Join-Path $sourceSkill 'LICENSE') -Force

    if ($Scope -in @('Project','All')) {
        $project = (Resolve-Path -LiteralPath $ProjectPath).Path
        $destination = Join-Path $project '.agent\skills\impeccable'
        Install-ImpeccableTarget $sourceSkill $destination 'workspace-impeccable'
    }
    if ($Scope -in @('Global','All')) {
        $destination = Join-Path $HOME '.gemini\config\skills\impeccable'
        Install-ImpeccableTarget $sourceSkill $destination 'global-impeccable'
    }

    Write-Host "Impeccable $releaseVersion installed from $Version." -ForegroundColor Green
    Write-Host 'Reload Antigravity before using /impeccable commands.'
    Write-Host 'This installs the skill payload only. It does not install a lifecycle hook, MCP server, or subagent.'
    if (Test-Path -LiteralPath $backupRoot) {
        Write-Host "Backup location: $backupRoot" -ForegroundColor Yellow
    }
}
finally {
    [Net.ServicePointManager]::SecurityProtocol = $oldProtocol
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
