[CmdletBinding()]
param(
    [ValidateSet('Global','Project','All')][string]$Scope = 'Project',
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$DryRun,
    [switch]$Prune,
    [switch]$Force
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\APESManifest.ps1')

$repoRoot = Split-Path -Parent $PSScriptRoot
$apesVersion = (Get-Content (Join-Path $repoRoot 'VERSION') -Raw).Trim()
$backupRoot = Join-Path $env:LOCALAPPDATA (Join-Path 'APES\backups' ('update-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
$backupRecords = [System.Collections.Generic.List[object]]::new()

function Backup-File([string]$Path) {
    if ($DryRun) { return }
    $flat = $Path -replace '^[A-Za-z]:\\', '' -replace '[:\\/]', '_'
    $suffix = (Get-APESFileHash -Path $Path).Substring(0, 8)
    $dest = Join-Path $backupRoot ($flat + '-' + $suffix)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
    Copy-Item -LiteralPath $Path -Destination $dest -Force
    $script:backupRecords.Add([ordered]@{ original = $Path; backup = $dest })
}

function Invoke-Target([string]$TargetName, [string]$Root, [string]$ManifestPath) {
    Write-Host ''
    Write-Host "=== $TargetName : $Root" -ForegroundColor Cyan

    $plan = Get-APESInstallPlan -RepoRoot $repoRoot -Target $TargetName
    $desired = @{}
    foreach ($item in $plan) {
        $desired[$item.Relative] = [pscustomobject]@{
            Source = $item.Source
            Hash   = Get-APESFileHash -Path $item.Source
        }
    }

    $manifest = Read-APESInstallManifest -Path $ManifestPath
    $recorded = Get-APESManifestFiles -Manifest $manifest
    $adopted = ($null -eq $manifest)

    if ($adopted) {
        # A pre-3.2 install has no record of which files APES wrote. Adopting the current
        # content of every file that also exists in this release is the only way the first
        # 3.2 update can ever upgrade anything: without it, every file looks user-modified
        # and is preserved forever.
        foreach ($relative in $desired.Keys) {
            $absolute = Join-Path $Root $relative
            if (Test-Path -LiteralPath $absolute -PathType Leaf) {
                $recorded[$relative] = Get-APESFileHash -Path $absolute
            }
        }
        Write-Host '  Chưa có manifest (bản cài cũ) — nhận quyền sở hữu các file trùng đường dẫn.' -ForegroundColor Yellow
    }

    $added = @(); $updated = @(); $kept = @(); $stale = @(); $pruned = @(); $removedUnchanged = 0

    # The manifest records the hash of the content APES last installed, NOT the hash of
    # whatever is on disk now. Recording the disk hash after a user edit would bless that
    # edit as ours, and the next update would treat it as unmodified and overwrite it.
    $finalHashes = @{}

    foreach ($relative in ($desired.Keys | Sort-Object)) {
        $absolute = Join-Path $Root $relative
        $newHash = $desired[$relative].Hash
        $source = $desired[$relative].Source

        if (-not (Test-Path -LiteralPath $absolute -PathType Leaf)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $absolute) | Out-Null
                Copy-Item -LiteralPath $source -Destination $absolute -Force
            }
            $added += $relative
            $finalHashes[$relative] = $newHash
            continue
        }

        $diskHash = Get-APESFileHash -Path $absolute
        $known = $null
        if ($recorded.ContainsKey($relative)) { $known = $recorded[$relative] }

        if ($known -and $diskHash -ne $known) {
            # The file changed since APES wrote it: this is the user's edit, not ours to undo.
            if ($Force) {
                Backup-File $absolute
                if (-not $DryRun) { Copy-Item -LiteralPath $source -Destination $absolute -Force }
                $updated += $relative
                $finalHashes[$relative] = $newHash
            } else {
                $kept += $relative
                # Keep the hash of what APES installed, so the next run still sees this as
                # a user edit instead of adopting it and overwriting it later.
                $finalHashes[$relative] = $known
            }
            continue
        }

        if ($diskHash -eq $newHash) { $removedUnchanged++; $finalHashes[$relative] = $newHash; continue }

        Backup-File $absolute
        if (-not $DryRun) { Copy-Item -LiteralPath $source -Destination $absolute -Force }
        $updated += $relative
        $finalHashes[$relative] = $newHash
    }

    foreach ($relative in ($recorded.Keys | Sort-Object)) {
        if ($desired.ContainsKey($relative)) { continue }
        $absolute = Join-Path $Root $relative
        if (-not (Test-Path -LiteralPath $absolute -PathType Leaf)) { continue }
        $stale += $relative
        if (-not $Prune) { continue }
        if ((Get-APESFileHash -Path $absolute) -ne $recorded[$relative] -and -not $Force) {
            Write-Host "  BỎ QUA khi prune (file đã bị sửa): $relative" -ForegroundColor Yellow
            continue
        }
        Backup-File $absolute
        if (-not $DryRun) { Remove-Item -LiteralPath $absolute -Force }
        $pruned += $relative
    }

    if (-not $DryRun) {
        $files = @()
        foreach ($relative in ($finalHashes.Keys | Sort-Object)) {
            $files += [ordered]@{ path = $relative; hash = $finalHashes[$relative] }
        }
        # Keep unpruned orphans on the record. Dropping them here would make the next run
        # report zero orphans, so a later -Prune would find nothing to do and the stale
        # rule would stay active forever — the exact defect this release exists to remove.
        foreach ($relative in $stale) {
            if ($pruned -contains $relative) { continue }
            if ($files | Where-Object { $_['path'] -eq $relative }) { continue }
            $files += [ordered]@{ path = $relative; hash = $recorded[$relative] }
        }
        $newManifest = [ordered]@{
            schemaVersion = 2
            version       = $apesVersion
            installedAt   = (Get-Date).ToString('o')
            source        = 'https://github.com/kimducanh27-cpu/agy-ide-setup'
            scope         = $TargetName
            root          = $Root
            customAgents  = 9
            files         = $files
        }
        Write-APESInstallManifest -Path $ManifestPath -Manifest $newManifest
    }

    Write-Host "  Thêm mới      : $($added.Count)" -ForegroundColor Green
    Write-Host "  Cập nhật      : $($updated.Count)" -ForegroundColor Green
    Write-Host "  Giữ nguyên    : $($kept.Count) (bạn đã sửa tay)" -ForegroundColor $(if ($kept.Count) { 'Yellow' } else { 'Gray' })
    Write-Host "  Đã là bản mới : $removedUnchanged" -ForegroundColor Gray
    Write-Host "  File mồ côi   : $($stale.Count)" -ForegroundColor $(if ($stale.Count) { 'Yellow' } else { 'Gray' })
    if ($Prune) { Write-Host "  Đã xoá        : $($pruned.Count)" -ForegroundColor Green }

    foreach ($item in $kept) { Write-Host "    giữ: $item" -ForegroundColor DarkYellow }
    foreach ($item in $stale) {
        if ($Prune -and ($pruned -contains $item)) { Write-Host "    xoá: $item" -ForegroundColor DarkGray }
        else { Write-Host "    mồ côi (chưa xoá, cần -Prune): $item" -ForegroundColor DarkYellow }
    }
}

Write-Host "APES $apesVersion update - Scope: $Scope$(if ($DryRun) { ' [DRY RUN]' })" -ForegroundColor Cyan

if ($Scope -in @('Global','All')) {
    $globalRoot = Join-Path $HOME '.gemini\config'
    Invoke-Target 'Global' $globalRoot (Join-Path $globalRoot 'apes-install.json')
}
if ($Scope -in @('Project','All')) {
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "Không tìm thấy thư mục dự án: $ProjectPath" }
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    Invoke-Target 'Project' $project (Join-Path (Join-Path $project '.agents') 'apes-install.json')
}

if ($DryRun) {
    Write-Host ''
    Write-Host 'DRY RUN: không ghi gì cả. Bỏ -DryRun để áp dụng.' -ForegroundColor Yellow
    exit 0
}

if ($backupRecords.Count -gt 0) {
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    $entries = $backupRecords | ForEach-Object {
        [ordered]@{ original = $_.original; backup = $_.backup; backedUpAt = (Get-Date).ToString('o') }
    }
    $manifest = [ordered]@{
        apesVersion = $apesVersion
        createdAt   = (Get-Date).ToString('o')
        scope       = $Scope
        entries     = @($entries)
    } | ConvertTo-Json -Depth 5
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $backupRoot 'backup-manifest.json'), $manifest, $encoding)
    Write-Host ''
    Write-Host "Đã backup $($backupRecords.Count) file: $backupRoot" -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Xong. Reload Antigravity để nạp thay đổi.' -ForegroundColor Green
