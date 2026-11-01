[CmdletBinding()]
param(
    [ValidateSet('Global','Project','All')][string]$Scope = 'All',
    [string]$ProjectPath = (Get-Location).Path
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$apesVersion = (Get-Content (Join-Path $repoRoot 'VERSION') -Raw).Trim()
$backupRoot = Join-Path $env:LOCALAPPDATA (Join-Path 'APES\backups' (Get-Date -Format 'yyyyMMdd-HHmmss'))

function Backup-IfExists([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        $relative = $Path -replace '^[A-Za-z]:\\','' -replace '[:\\/]','_'
        $dest = Join-Path $backupRoot $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -LiteralPath $Path -Destination $dest -Recurse -Force
        Write-Host "BACKUP: $Path -> $dest" -ForegroundColor Yellow
    }
}
function Copy-NamespaceFile([string]$Source,[string]$Destination) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    if (Test-Path -LiteralPath $Destination) { Backup-IfExists $Destination }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "INSTALLED: $Destination" -ForegroundColor Green
}
function Install-MarkdownAgents([string]$SourceDirectory,[string]$DestinationDirectory) {
    New-Item -ItemType Directory -Force -Path $DestinationDirectory | Out-Null
    foreach ($file in Get-ChildItem $SourceDirectory -Filter '*.md' -File) {
        Copy-NamespaceFile $file.FullName (Join-Path $DestinationDirectory $file.Name)
    }
}
function Install-Global {
    $globalRoot = Join-Path $HOME '.gemini\config'
    Copy-NamespaceFile (Join-Path $repoRoot 'global\AGENTS.md') (Join-Path $globalRoot 'AGENTS.md')
    foreach ($file in Get-ChildItem (Join-Path $repoRoot 'global\rules') -Filter '*.md' -File) {
        Copy-NamespaceFile $file.FullName (Join-Path $globalRoot ('rules\' + $file.Name))
    }
    foreach ($skill in Get-ChildItem (Join-Path $repoRoot 'global\skills') -Directory) {
        $target = Join-Path $globalRoot ('skills\' + $skill.Name)
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Get-ChildItem $skill.FullName -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($skill.FullName.Length).TrimStart([char]'\')
            Copy-NamespaceFile $_.FullName (Join-Path $target $rel)
        }
    }
    Install-MarkdownAgents (Join-Path $repoRoot '.agents\agents') (Join-Path $globalRoot 'agents')
}
function Install-Project {
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "Không tìm thấy thư mục dự án: $ProjectPath" }
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    $agentRoot = Join-Path $project '.agents'
    Copy-NamespaceFile (Join-Path $repoRoot '.agents\AGENTS.md') (Join-Path $agentRoot 'AGENTS.md')
    foreach ($file in Get-ChildItem (Join-Path $repoRoot '.agents\rules') -Filter '*.md' -File) {
        Copy-NamespaceFile $file.FullName (Join-Path $agentRoot ('rules\' + $file.Name))
    }
    foreach ($skill in Get-ChildItem (Join-Path $repoRoot '.agents\skills') -Directory) {
        $target = Join-Path $agentRoot ('skills\' + $skill.Name)
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Get-ChildItem $skill.FullName -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($skill.FullName.Length).TrimStart([char]'\')
            Copy-NamespaceFile $_.FullName (Join-Path $target $rel)
        }
    }
    Install-MarkdownAgents (Join-Path $repoRoot '.agents\agents') (Join-Path $agentRoot 'agents')
    $docRoot = Join-Path $project 'docs\engineering\apes'
    $templateRoot = Join-Path $repoRoot 'templates\engineering'
    Get-ChildItem $templateRoot -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($templateRoot.Length).TrimStart([char]'\')
        Copy-NamespaceFile $_.FullName (Join-Path $docRoot $rel)
    }
    $projectManagementTemplateRoot = Join-Path $repoRoot 'templates\project-management'
    $projectManagementDestination = Join-Path $docRoot 'templates\project-management'
    Get-ChildItem $projectManagementTemplateRoot -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($projectManagementTemplateRoot.Length).TrimStart([char]'\')
        Copy-NamespaceFile $_.FullName (Join-Path $projectManagementDestination $rel)
    }
    $workflowConfigDestination = Join-Path $docRoot 'config\workflows.json'
    Copy-NamespaceFile (Join-Path $repoRoot 'config\workflows.json') $workflowConfigDestination
    # Copy every top-level doc so that any guide an agent or skill tells the agent to read
    # is present in the workspace. A hardcoded list silently drifts behind new documentation.
    foreach ($docFile in Get-ChildItem (Join-Path $repoRoot 'docs') -Filter '*.md' -File) {
        Copy-NamespaceFile $docFile.FullName (Join-Path $docRoot $docFile.Name)
    }
    $promptRoot = Join-Path $repoRoot 'templates\prompts'
    $promptDestination = Join-Path $docRoot 'prompts'
    foreach ($promptName in @('APES-PROJECT-MANAGER-WORKFLOW-VI.md','FLOWPLAN-WORKFLOW-PROMPTS-VI.md')) {
        Copy-NamespaceFile (Join-Path $promptRoot $promptName) (Join-Path $promptDestination $promptName)
    }
    $marker = Join-Path $agentRoot 'apes-install.json'
    $markerContent = [ordered]@{
        version = $apesVersion
        installedAt = (Get-Date).ToString('o')
        source = 'https://github.com/kimducanh27-cpu/agy-ide-setup'
        scope = 'Project'
        customAgents = 9
    } | ConvertTo-Json
    $temp = Join-Path $env:TEMP ('apes-marker-' + [guid]::NewGuid().ToString('N') + '.json')
    Set-Content -LiteralPath $temp -Value $markerContent -Encoding UTF8
    Copy-NamespaceFile $temp $marker
    Remove-Item -LiteralPath $temp -Force
}
Write-Host "APES $apesVersion installer — Scope: $Scope" -ForegroundColor Cyan
if ($Scope -in @('Global','All')) { Install-Global }
if ($Scope -in @('Project','All')) { Install-Project }
Write-Host "Hoàn tất. Backup (nếu có): $backupRoot" -ForegroundColor Green
Write-Host 'Tiếp theo: reload Antigravity, kiểm tra Rules/Skills/Agents trong Customizations, rồi yêu cầu apes-orchestrator bootstrap dự án.'
