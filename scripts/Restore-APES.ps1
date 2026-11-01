[CmdletBinding()]
param(
    [string]$BackupPath = '',
    [switch]$Force,
    [switch]$DryRun,
    [string[]]$Only = @(),
    # A restore writes to whatever path the manifest names. Without a boundary, a manifest
    # from anywhere — an old backup, a colleague's machine, a tampered file — can write to
    # any absolute path on disk. Every entry must land inside one of the allowed roots.
    [string]$ProjectPath = (Get-Location).Path
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\APESManifest.ps1')

$allowedRoots = @()
if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
    $resolvedProject = try { (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path } catch { $null }
    if ($resolvedProject) { $allowedRoots += $resolvedProject }
}
$allowedRoots += (Join-Path $HOME '.gemini\config')

function Test-RestorePathAllowed([string]$Path) {
    foreach ($root in $script:allowedRoots) {
        if (Test-APESPathInside -Path $Path -Root $root) { return $true }
    }
    return $false
}

$backupBase = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA 'APES\backups'
} else {
    Join-Path $env:TEMP 'APES\backups'
}

function Resolve-ManifestPath([string]$Candidate) {
    if ([string]::IsNullOrWhiteSpace($Candidate)) {
        if (-not (Test-Path -LiteralPath $backupBase -PathType Container)) {
            Write-Host "FAIL  Không tìm thấy thư mục backup: $backupBase. Chưa có bản backup nào." -ForegroundColor Red
            return $null
        }
        $latest = Get-ChildItem -LiteralPath $backupBase -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'backup-manifest.json') -PathType Leaf } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($null -eq $latest) {
            Write-Host "FAIL  Không có backup-manifest.json trong $backupBase. Backup tạo trước APES 3.0 không có manifest nên không khôi phục tự động được." -ForegroundColor Red
            return $null
        }
        return (Join-Path $latest.FullName 'backup-manifest.json')
    }

    if (Test-Path -LiteralPath $Candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $Candidate).Path }
    if (Test-Path -LiteralPath $Candidate -PathType Container) {
        $inDir = Join-Path $Candidate 'backup-manifest.json'
        if (-not (Test-Path -LiteralPath $inDir -PathType Leaf)) {
            Write-Host "FAIL  Thư mục không có backup-manifest.json: $Candidate" -ForegroundColor Red
            return $null
        }
        return (Resolve-Path -LiteralPath $inDir).Path
    }
    Write-Host "FAIL  Không tìm thấy backup hoặc manifest: $Candidate" -ForegroundColor Red
    return $null
}

# Every abort below uses exit 1 rather than throw: a throw leaves $LASTEXITCODE untouched,
# so an automated caller would read the failure as success.
$manifestPath = Resolve-ManifestPath $BackupPath
if (-not $manifestPath) { exit 1 }

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$entries = @($manifest.entries)

if ($entries.Count -eq 0) {
    Write-Host "FAIL  Manifest không có entry nào: $manifestPath" -ForegroundColor Red
    exit 1
}

if ($Only.Count -gt 0) {
    $entries = @($entries | Where-Object {
        $original = [string]$_.original
        $matched = $false
        foreach ($needle in $Only) { if ($original -like ('*' + $needle + '*')) { $matched = $true } }
        $matched
    })
    if ($entries.Count -eq 0) {
        Write-Host "FAIL  Không entry nào khớp -Only: $($Only -join ', ')" -ForegroundColor Red
        exit 1
    }
}

Write-Host "APES restore — manifest: $manifestPath" -ForegroundColor Cyan
Write-Host "Phiên bản đã backup: $($manifest.apesVersion) | phạm vi: $($manifest.scope) | thời điểm: $($manifest.createdAt)"
Write-Host "Số entry sẽ xử lý: $($entries.Count)"
Write-Host ''

# Preflight: never start writing unless every backup file is present.
$missing = @()
foreach ($entry in $entries) {
    if (-not (Test-Path -LiteralPath ([string]$entry.backup) -PathType Leaf)) {
        $missing += [string]$entry.backup
    }
}
if ($missing.Count -gt 0) {
    Write-Host 'FAIL  Thiếu file backup, không khôi phục gì cả:' -ForegroundColor Red
    foreach ($item in $missing) { Write-Host "  - $item" -ForegroundColor Red }
    Write-Host "Preflight thất bại: $($missing.Count) file backup không tồn tại. Không có thay đổi nào được thực hiện." -ForegroundColor Red
    exit 1
}

$writeMode = $Force -and -not $DryRun
if (-not $writeMode) {
    Write-Host 'CHẾ ĐỘ XEM TRƯỚC — không ghi gì. Thêm -Force để khôi phục thật.' -ForegroundColor Yellow
    Write-Host ''
    foreach ($entry in $entries) {
        $original = [string]$entry.original
        $state = if (Test-Path -LiteralPath $original -PathType Leaf) { 'sẽ ghi đè' } else { 'sẽ tạo mới' }
        Write-Host ("  {0,-12} {1}" -f $state, $original)
    }
    Write-Host ''
    Write-Host 'Không có thay đổi nào được thực hiện.' -ForegroundColor Green
    exit 0
}

# The restore itself must be reversible: keep a copy of what is being replaced.
$safetyRoot = Join-Path $backupBase ('restore-safety-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$safetyRecords = [System.Collections.Generic.List[object]]::new()
$restored = 0
$failures = [System.Collections.Generic.List[string]]::new()

foreach ($entry in $entries) {
    $original = [string]$entry.original
    $backupFile = [string]$entry.backup
    try {
        if (-not (Test-RestorePathAllowed $original)) {
            $failures.Add("$original -> ngoài phạm vi cho phép, đã bỏ qua")
            Write-Host "BLOCKED: $original — ngoài phạm vi cho phép" -ForegroundColor Red
            Write-Host "         Cho phép: $($allowedRoots -join ' | ')" -ForegroundColor DarkGray
            continue
        }
        $parent = Split-Path -Parent $original
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        if (Test-Path -LiteralPath $original -PathType Leaf) {
            New-Item -ItemType Directory -Force -Path $safetyRoot | Out-Null
            $safeName = $original -replace '^[A-Za-z]:\\','' -replace '[:\\/]','_'
            $safeCopy = Join-Path $safetyRoot $safeName
            Copy-Item -LiteralPath $original -Destination $safeCopy -Force
            $safetyRecords.Add([ordered]@{ original = $original; backup = $safeCopy })
        }
        Copy-Item -LiteralPath $backupFile -Destination $original -Force
        $restored++
        Write-Host "RESTORED: $original" -ForegroundColor Green
    } catch {
        $failures.Add("$original -> $($_.Exception.Message)")
        Write-Host "FAIL: $original — $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($safetyRecords.Count -gt 0) {
    $safetyManifest = [ordered]@{
        restoredFrom = $manifestPath
        createdAt    = (Get-Date).ToString('o')
        entries      = $safetyRecords
    } | ConvertTo-Json -Depth 5
    Set-Content -LiteralPath (Join-Path $safetyRoot 'backup-manifest.json') -Value $safetyManifest -Encoding UTF8
    Write-Host ''
    Write-Host "Trạng thái trước khi khôi phục được giữ tại: $safetyRoot" -ForegroundColor Yellow
    Write-Host 'Có thể chạy lại chính script này với -BackupPath trỏ vào đó để hoàn tác.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host "Đã khôi phục: $restored | Lỗi: $($failures.Count)" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}
Write-Host 'Khôi phục hoàn tất. Reload Antigravity để nạp lại Rules/Skills/Agents.' -ForegroundColor Green
