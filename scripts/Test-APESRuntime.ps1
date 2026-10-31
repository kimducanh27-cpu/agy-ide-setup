[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$collector = Join-Path $PSScriptRoot 'runtime\Write-APESRuntimeEvent.ps1'
if (-not (Test-Path -LiteralPath $collector)) { throw 'FAIL: runtime collector missing' }
$sample = '{"conversationId":"test-session","workspacePaths":["C:\\Demo"],"modelName":"test-model","toolCall":{"name":"run_command","args":{"secret":"must-not-be-logged"}},"stepIdx":7}'
$output = $sample | powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $collector -Event PreToolUse
if ($LASTEXITCODE -ne 0) { throw 'FAIL: collector process returned non-zero' }
$decision = $output | ConvertFrom-Json
if ($decision.decision -ne 'allow') { throw 'FAIL: PreToolUse must return allow to preserve normal Antigravity policy flow' }
$logRoot = Join-Path $env:LOCALAPPDATA 'APES\runtime'
$log = Get-ChildItem -LiteralPath $logRoot -Filter 'events-*.jsonl' -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
if ($null -eq $log) { throw 'FAIL: no runtime event log created' }
$last = Get-Content -LiteralPath $log.FullName -Tail 1 | ConvertFrom-Json
if ($last.event -ne 'PreToolUse' -or $last.toolName -ne 'run_command' -or $last.stepIdx -ne 7) {
    throw 'FAIL: event fields were not recorded correctly'
}
if ((Get-Content -LiteralPath $log.FullName -Raw) -match 'must-not-be-logged') {
    throw 'FAIL: tool arguments leaked into telemetry log'
}
Write-Host 'PASS: runtime collector contract and secret-omission smoke test' -ForegroundColor Green
