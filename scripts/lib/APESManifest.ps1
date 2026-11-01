# Shared helpers for the APES installer, updater and restorer.
# Dot-source this file; it defines functions only and executes nothing on its own.

function Get-APESFileHash {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Cannot hash a file that does not exist: $Path"
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)

    # Normalise CRLF to LF before hashing. Git rewrites line endings on checkout on
    # Windows, so hashing raw bytes would report every file as user-modified after a
    # clone even though the content is identical. Compare content, not bytes.
    $normalised = New-Object System.Collections.Generic.List[byte] ($bytes.Length)
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -eq 13 -and ($i + 1) -lt $bytes.Length -and $bytes[$i + 1] -eq 10) { continue }
        $normalised.Add($bytes[$i])
    }

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $digest = $sha.ComputeHash($normalised.ToArray())
    } finally {
        $sha.Dispose()
    }
    return ([System.BitConverter]::ToString($digest) -replace '-', '').ToLowerInvariant()
}

function Test-APESPathInside {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Root
    )

    # A restore must never write outside the tree it is restoring into. Comparing
    # resolved absolute paths stops a manifest entry of `..\..\Windows\System32` or an
    # absolute path elsewhere on disk from being honoured.
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullRoot = [System.IO.Path]::GetFullPath($Root)
    $separator = [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullRoot.EndsWith($separator)) { $fullRoot += $separator }
    return $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-APESInstallPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$RepoRoot,
        [Parameter(Mandatory=$true)][ValidateSet('Global','Project')][string]$Target
    )

    # One enumeration, used by both the installer and the updater. Two copies of this
    # list is how an update silently installs a different set of files than a fresh
    # install would, and nobody notices until a machine behaves differently from a
    # colleague's.
    $plan = [System.Collections.Generic.List[object]]::new()

    function Add-Tree([string]$SourceRoot, [string]$RelativeRoot) {
        if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) { return }
        Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($SourceRoot.Length).TrimStart([char]'\', [char]'/')
            $plan.Add([pscustomobject]@{
                Source   = $_.FullName
                Relative = if ($RelativeRoot) { Join-Path $RelativeRoot $rel } else { $rel }
            })
        }
    }

    function Add-File([string]$Source, [string]$Relative) {
        if (Test-Path -LiteralPath $Source -PathType Leaf) {
            $plan.Add([pscustomobject]@{ Source = $Source; Relative = $Relative })
        }
    }

    if ($Target -eq 'Global') {
        Add-File (Join-Path $RepoRoot 'global\AGENTS.md') 'AGENTS.md'
        Add-Tree (Join-Path $RepoRoot 'global\rules') 'rules'
        Add-Tree (Join-Path $RepoRoot 'global\skills') 'skills'
        Add-Tree (Join-Path $RepoRoot '.agents\agents') 'agents'
    } else {
        Add-File (Join-Path $RepoRoot '.agents\AGENTS.md') '.agents\AGENTS.md'
        Add-Tree (Join-Path $RepoRoot '.agents\rules') '.agents\rules'
        Add-Tree (Join-Path $RepoRoot '.agents\skills') '.agents\skills'
        Add-Tree (Join-Path $RepoRoot '.agents\agents') '.agents\agents'

        $docRelative = 'docs\engineering\apes'
        Add-Tree (Join-Path $RepoRoot 'templates\engineering') $docRelative
        Add-Tree (Join-Path $RepoRoot 'templates\project-management') (Join-Path $docRelative 'templates\project-management')
        Add-File (Join-Path $RepoRoot 'config\workflows.json') (Join-Path $docRelative 'config\workflows.json')

        Get-ChildItem (Join-Path $RepoRoot 'docs') -Filter '*.md' -File | ForEach-Object {
            Add-File $_.FullName (Join-Path $docRelative $_.Name)
        }
        foreach ($promptName in @('APES-PROJECT-MANAGER-WORKFLOW-VI.md', 'FLOWPLAN-WORKFLOW-PROMPTS-VI.md')) {
            Add-File (Join-Path (Join-Path $RepoRoot 'templates\prompts') $promptName) (Join-Path $docRelative ('prompts\' + $promptName))
        }
    }

    return $plan
}

function Read-APESInstallManifest {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    try {
        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    } catch {
        Write-Host "WARNING: cannot parse manifest, treating it as absent: $Path" -ForegroundColor Yellow
        return $null
    }
}

function Write-APESInstallManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)]$Manifest
    )

    $json = $Manifest | ConvertTo-Json -Depth 8
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    # Write without a BOM. A BOM in JSON breaks strict readers, and this manifest is
    # meant to be readable by anything, not just PowerShell.
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $json, $encoding)
}

function Get-APESManifestFiles {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)]$Manifest)

    # Older manifests have no files array. Returning an empty map lets callers treat
    # a pre-3.2 install as "no recorded state" rather than crashing on a missing property.
    $map = @{}
    if ($null -eq $Manifest) { return $map }
    if (-not ($Manifest.PSObject.Properties.Name -contains 'files')) { return $map }
    foreach ($entry in @($Manifest.files)) {
        if ($null -eq $entry) { continue }
        if (-not $entry.path) { continue }
        $map[[string]$entry.path] = [string]$entry.hash
    }
    return $map
}
