[CmdletBinding()]
param(
    # 3.2 changed the default from All to Project. Running the installer with no
    # arguments used to write into the current directory AND ~/.gemini/config, which is
    # how a machine-wide config was overwritten by accident. A fresh install now touches
    # one project; going machine-wide has to be asked for.
    [ValidateSet('Global','Project','All')][string]$Scope = 'Project',
    [string]$ProjectPath = (Get-Location).Path
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\APESManifest.ps1')

$repoRoot = Split-Path -Parent $PSScriptRoot
$apesVersion = (Get-Content (Join-Path $repoRoot 'VERSION') -Raw).Trim()
$backupRoot = Join-Path $env:LOCALAPPDATA (Join-Path 'APES\backups' (Get-Date -Format 'yyyyMMdd-HHmmss'))

$backupRecords = [System.Collections.Generic.List[object]]::new()
$written = [ordered]@{}
$script:installRoot = $null

function Backup-IfExists([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }

    # Flattening a path to a file name is lossy: `C:\a\b.md` and `C:\a_b.md` both become
    # `a_b.md`, and the second backup overwrites the first. Append a short hash of the
    # original path so two distinct files can never share one backup slot.
    $flat = $Path -replace '^[A-Za-z]:\\', '' -replace '[:\\/]', '_'
    $suffix = (Get-APESFileHash -Path $Path).Substring(0, 8)
    $dest = Join-Path $backupRoot ($flat + '-' + $suffix)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
    Copy-Item -LiteralPath $Path -Destination $dest -Recurse -Force
    $script:backupRecords.Add([ordered]@{
        original   = $Path
        backup     = $dest
        backedUpAt = (Get-Date).ToString('o')
    })
    Write-Host "BACKUP: $Path -> $dest" -ForegroundColor Yellow
}

function Install-File([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null

    $existed = Test-Path -LiteralPath $Destination
    if ($existed) { Backup-IfExists $Destination }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force

    $relative = $Destination.Substring($script:installRoot.Length).TrimStart([char]'\', [char]'/')
    $script:written[$relative] = Get-APESFileHash -Path $Destination

    if ($existed) { Write-Host "OVERWROTE: $Destination" -ForegroundColor DarkYellow }
    else { Write-Host "INSTALLED: $Destination" -ForegroundColor Green }
}

function Install-Tree([string]$SourceRoot, [string]$DestinationRoot) {
    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) { return }
    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($SourceRoot.Length).TrimStart([char]'\', [char]'/')
        Install-File $_.FullName (Join-Path $DestinationRoot $relative)
    }
}

function Write-Manifest([string]$ManifestPath, [string]$Root, [string]$ScopeName) {
    $files = @()
    foreach ($key in $script:written.Keys) {
        $files += [ordered]@{ path = $key; hash = $script:written[$key] }
    }
    $manifest = [ordered]@{
        schemaVersion = 2
        version       = $apesVersion
        installedAt   = (Get-Date).ToString('o')
        source        = 'https://github.com/kimducanh27-cpu/agy-ide-setup'
        scope         = $ScopeName
        root          = $Root
        customAgents  = 9
        files         = $files
    }
    Write-APESInstallManifest -Path $ManifestPath -Manifest $manifest
    Write-Host "MANIFEST: $ManifestPath ($($files.Count) file)" -ForegroundColor Cyan
}

function Install-Global {
    $globalRoot = Join-Path $HOME '.gemini\config'
    $script:installRoot = $globalRoot
    Write-Host "Đích: $globalRoot" -ForegroundColor Cyan

    Install-File (Join-Path $repoRoot 'global\AGENTS.md') (Join-Path $globalRoot 'AGENTS.md')
    Install-Tree (Join-Path $repoRoot 'global\rules') (Join-Path $globalRoot 'rules')
    Install-Tree (Join-Path $repoRoot 'global\skills') (Join-Path $globalRoot 'skills')
    Install-Tree (Join-Path $repoRoot '.agents\agents') (Join-Path $globalRoot 'agents')

    Write-Manifest (Join-Path $globalRoot 'apes-install.json') $globalRoot 'Global'
}

function Install-Project {
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "Không tìm thấy thư mục dự án: $ProjectPath" }
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    $agentRoot = Join-Path $project '.agents'
    $script:installRoot = $project
    Write-Host "Đích: $project" -ForegroundColor Cyan

    Install-File (Join-Path $repoRoot '.agents\AGENTS.md') (Join-Path $agentRoot 'AGENTS.md')
    Install-Tree (Join-Path $repoRoot '.agents\rules') (Join-Path $agentRoot 'rules')
    Install-Tree (Join-Path $repoRoot '.agents\skills') (Join-Path $agentRoot 'skills')
    Install-Tree (Join-Path $repoRoot '.agents\agents') (Join-Path $agentRoot 'agents')

    $docRoot = Join-Path $project 'docs\engineering\apes'
    Install-Tree (Join-Path $repoRoot 'templates\engineering') $docRoot
    Install-Tree (Join-Path $repoRoot 'templates\project-management') (Join-Path $docRoot 'templates\project-management')
    Install-File (Join-Path $repoRoot 'config\workflows.json') (Join-Path $docRoot 'config\workflows.json')

    # Every top-level doc, not a hardcoded list: a hardcoded list silently drifts behind
    # new documentation, and an agent told to read a missing file has no recovery.
    Get-ChildItem (Join-Path $repoRoot 'docs') -Filter '*.md' -File | ForEach-Object {
        Install-File $_.FullName (Join-Path $docRoot $_.Name)
    }
    foreach ($promptName in @('APES-PROJECT-MANAGER-WORKFLOW-VI.md', 'FLOWPLAN-WORKFLOW-PROMPTS-VI.md')) {
        $promptSource = Join-Path (Join-Path $repoRoot 'templates\prompts') $promptName
        if (Test-Path -LiteralPath $promptSource) {
            Install-File $promptSource (Join-Path (Join-Path $docRoot 'prompts') $promptName)
        }
    }

    Write-Manifest (Join-Path $agentRoot 'apes-install.json') $project 'Project'
}

Write-Host "APES $apesVersion installer - Scope: $Scope" -ForegroundColor Cyan
if ($Scope -in @('Global','All')) { Install-Global }
if ($Scope -in @('Project','All')) { Install-Project }
Write-Host 'Hoàn tất.' -ForegroundColor Green

if ($backupRecords.Count -gt 0) {
    $manifestPath = Join-Path $backupRoot 'backup-manifest.json'
    $manifest = [ordered]@{
        apesVersion = $apesVersion
        createdAt   = (Get-Date).ToString('o')
        scope       = $Scope
        entries     = $backupRecords
    } | ConvertTo-Json -Depth 5
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($manifestPath, $manifest, $encoding)
    Write-Host "Đã backup $($backupRecords.Count) file. Khôi phục: $backupRoot" -ForegroundColor Yellow
} else {
    Write-Host 'Không có file nào bị ghi đè, nên không tạo backup.' -ForegroundColor Green
}
Write-Host 'Tiếp theo: reload Antigravity, kiểm tra Rules/Skills/Agents trong Customizations, rồi yêu cầu apes-orchestrator bootstrap dự án.'
