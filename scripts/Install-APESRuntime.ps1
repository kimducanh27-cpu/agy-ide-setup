[CmdletBinding()]
param(
    [switch]$ReplaceExisting
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$configRoot = Join-Path $HOME '.gemini\config'
$hooksPath = Join-Path $configRoot 'hooks.json'
$runtimeRoot = Join-Path $configRoot 'apes-runtime'
$collectorSource = Join-Path $PSScriptRoot 'runtime\Write-APESRuntimeEvent.ps1'
if (-not (Test-Path -LiteralPath $collectorSource -PathType Leaf)) {
    throw "Không tìm thấy runtime collector: $collectorSource"
}
New-Item -ItemType Directory -Path $configRoot -Force | Out-Null
New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null

$backupRoot = Join-Path $env:LOCALAPPDATA ('APES\backups\runtime-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
Copy-Item -LiteralPath $collectorSource -Destination (Join-Path $runtimeRoot 'Write-APESRuntimeEvent.ps1') -Force

$config = [ordered]@{}
if (Test-Path -LiteralPath $hooksPath) {
    try {
        $existing = Get-Content -LiteralPath $hooksPath -Raw | ConvertFrom-Json -ErrorAction Stop
        foreach ($property in $existing.PSObject.Properties) {
            $config[$property.Name] = $property.Value
        }
    } catch {
        throw "hooks.json hiện tại không phải JSON hợp lệ. APES chưa thay đổi file này. Hãy sửa/backup thủ công: $hooksPath"
    }
}
if ($config.Contains('apes-runtime-capture') -and -not $ReplaceExisting) {
    throw "Đã có cấu hình apes-runtime-capture. Dùng -ReplaceExisting nếu muốn thay thế cấu hình APES này."
}
if ($config.Contains('apes-runtime-capture')) {
    $config.Remove('apes-runtime-capture')
}
$collector = Join-Path $runtimeRoot 'Write-APESRuntimeEvent.ps1'
$escapedCollector = $collector.Replace('"','\"')
$events = [ordered]@{}
foreach ($eventName in @('SessionStart','PreToolUse','PostToolUse','PreInvocation','PostInvocation','Stop')) {
    $handler = [ordered]@{
        type = 'command'
        command = ('powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + $escapedCollector + '" -Event ' + $eventName)
        timeout = 5
    }
    if ($eventName -in @('PreToolUse','PostToolUse')) {
        $events[$eventName] = @([ordered]@{
            matcher = '*'
            hooks = @($handler)
        })
    } else {
        $events[$eventName] = @($handler)
    }
}
$config['apes-runtime-capture'] = $events

if (Test-Path -LiteralPath $hooksPath) {
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Copy-Item -LiteralPath $hooksPath -Destination (Join-Path $backupRoot 'hooks.json')
    Write-Host "BACKUP: $hooksPath -> $backupRoot\hooks.json" -ForegroundColor Yellow
}
$tempPath = Join-Path $env:TEMP ('apes-hooks-' + [guid]::NewGuid().ToString('N') + '.json')
$config | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $tempPath -Encoding UTF8
Move-Item -LiteralPath $tempPath -Destination $hooksPath -Force
Write-Host 'Đã cài APES Runtime Capture (opt-in).' -ForegroundColor Green
Write-Host "Hooks: $hooksPath"
Write-Host "Collector: $collector"
Write-Host "Log: $env:LOCALAPPDATA\APES\runtime\events-YYYYMMDD.jsonl"
Write-Host 'Tiếp theo: mở Antigravity > Settings > Customizations > Hooks và kiểm tra apes-runtime-capture đang bật.'
