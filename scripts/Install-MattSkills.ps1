[CmdletBinding()]
param(
    [ValidateSet('Project','Global','All')][string]$Scope = 'Project',
    [string]$ProjectPath = (Get-Location).Path,
    [ValidateSet('Stable','All')][string]$Set = 'Stable'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Pinned commit, not a branch. A branch moves; this cannot.
$Ref = '4ae2317ddb22b046e26455e4f9c9b3aaaf62212d'
$downloadUrl = 'https://codeload.github.com/mattpocock/skills/zip/' + $Ref

$tempRoot = Join-Path $env:TEMP ('apes-mattskills-' + [guid]::NewGuid().ToString('N'))
$zipPath = Join-Path $tempRoot 'skills.zip'
$extractRoot = Join-Path $tempRoot 'extract'

$backupBase = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA 'APES\backups'
} else {
    Join-Path $env:TEMP 'APES\backups'
}
$backupRoot = Join-Path $backupBase ('matt-skills-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))

# Stable = the two groups upstream maintains. All adds the frozen misc/ and the
# unfinished in-progress/ buckets; upstream's own SCOPE.md calls misc/ unmaintained.
$groups = if ($Set -eq 'All') {
    @('engineering', 'productivity', 'in-progress', 'misc')
} else {
    @('engineering', 'productivity')
}

function Install-SkillFolder([string]$Source,[string]$Target,[string]$Name) {
    $parent = Split-Path -Parent $Target

    if (Test-Path -LiteralPath $Target) {
        if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
            throw "Destination exists and is not a directory; refusing to overwrite: $Target"
        }
        $manifest = Join-Path $Target 'SKILL.md'
        if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
            throw "Destination exists but has no SKILL.md; refusing to overwrite: $Target"
        }
        # Only replace a folder that is actually this skill, never a stranger's directory.
        $existing = Get-Content -LiteralPath $manifest -Raw
        if ($existing -notmatch ('(?m)^name:\s*["'']?' + [regex]::Escape($Name) + '["'']?\s*$')) {
            throw "Destination holds a different skill; refusing to overwrite: $Target"
        }

        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        $safe = $Name -replace '[^a-zA-Z0-9_-]', '_'
        Copy-Item -LiteralPath $Target -Destination (Join-Path $backupRoot $safe) -Recurse -Force
        Write-Host "BACKUP: $Target -> $(Join-Path $backupRoot $safe)" -ForegroundColor Yellow
        Remove-Item -LiteralPath $Target -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Copy-Item -LiteralPath $Source -Destination $parent -Recurse -Force
    Write-Host "INSTALLED: $Name" -ForegroundColor Green
}

$oldProtocol = [Net.ServicePointManager]::SecurityProtocol
try {
    if ($Scope -in @('Project', 'All')) {
        if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
            throw "Workspace not found: $ProjectPath"
        }
    }

    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null

    # Windows PowerShell 5.1 needs TLS 1.2 set explicitly for this download.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "Downloading mattpocock/skills at $($Ref.Substring(0, 7)) ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force

    $skillsRoot = Get-ChildItem -LiteralPath $extractRoot -Directory |
        ForEach-Object { Join-Path $_.FullName 'skills' } |
        Where-Object { Test-Path -LiteralPath $_ -PathType Container } |
        Select-Object -First 1

    if (-not $skillsRoot) { throw 'skills/ directory not found in the downloaded archive.' }

    $found = @()
    foreach ($group in $groups) {
        $groupPath = Join-Path $skillsRoot $group
        if (-not (Test-Path -LiteralPath $groupPath -PathType Container)) { continue }
        foreach ($dir in Get-ChildItem -LiteralPath $groupPath -Directory) {
            $manifest = Join-Path $dir.FullName 'SKILL.md'
            if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) { continue }

            $text = Get-Content -LiteralPath $manifest -Raw
            $hasName = $text -match '(?m)^name:\s*["'']?[a-z0-9-]+["'']?\s*$'
            $hasDescription = $text -match '(?m)^description:\s*\S'
            if (-not ($hasName -and $hasDescription)) {
                Write-Host "SKIPPED (invalid frontmatter): $($dir.Name)" -ForegroundColor Yellow
                continue
            }
            $found += [pscustomobject]@{ Name = $dir.Name; Path = $dir.FullName; Group = $group }
        }
    }

    if ($found.Count -eq 0) { throw 'No installable skills found in the archive.' }

    $installed = 0
    $markerContent = [ordered]@{
        source      = 'https://github.com/mattpocock/skills'
        ref         = $Ref
        set         = $Set
        installedAt = (Get-Date).ToString('o')
        skills      = @($found | ForEach-Object { $_.Name })
    } | ConvertTo-Json -Depth 4

    if ($Scope -in @('Project', 'All')) {
        $project = (Resolve-Path -LiteralPath $ProjectPath).Path
        $target = Join-Path $project '.agents\skills'
        foreach ($skill in $found) {
            Install-SkillFolder $skill.Path (Join-Path $target $skill.Name) $skill.Name
            $installed++
        }
        $markerPath = Join-Path $project '.agents\matt-skills.json'
        Set-Content -LiteralPath $markerPath -Value $markerContent -Encoding UTF8
        Write-Host "MARKER: $markerPath"
    }
    if ($Scope -in @('Global', 'All')) {
        $target = Join-Path $HOME '.gemini\config\skills'
        foreach ($skill in $found) {
            Install-SkillFolder $skill.Path (Join-Path $target $skill.Name) $skill.Name
            $installed++
        }
        $markerPath = Join-Path $HOME '.gemini\config\matt-skills.json'
        Set-Content -LiteralPath $markerPath -Value $markerContent -Encoding UTF8
        Write-Host "MARKER: $markerPath"
    }

    Write-Host ''
    Write-Host "Installed $installed skill folder(s) from mattpocock/skills ($Set)." -ForegroundColor Green
    Write-Host 'These are third-party skills, installed separately and not vendored into APES.'
    Write-Host 'Some of them expect subagent delegation (code-review, implement-spec, research);'
    Write-Host 'they degrade to sequential passes on a runtime without native subagents.'
    if (Test-Path -LiteralPath $backupRoot) {
        Write-Host "Backup: $backupRoot" -ForegroundColor Yellow
    }
    Write-Host 'Next: reload Antigravity, then run /setup-matt-pocock-skills once per repo if you use the tracker-dependent skills.'
}
finally {
    [Net.ServicePointManager]::SecurityProtocol = $oldProtocol
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
