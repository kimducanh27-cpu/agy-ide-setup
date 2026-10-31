[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('SessionStart','PreToolUse','PostToolUse','PreInvocation','PostInvocation','Stop')]
    [string]$Event
)
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$payload = $null
try {
    if (-not [string]::IsNullOrWhiteSpace($raw)) { $payload = $raw | ConvertFrom-Json -ErrorAction Stop }
} catch {
    if ($Event -eq 'PreToolUse') { [Console]::Out.Write('{"decision":"allow"}') }
    else { [Console]::Out.Write('{}') }
    exit 0
}
$toolName = $null
if ($null -ne $payload -and $null -ne $payload.toolCall) { $toolName = [string]$payload.toolCall.name }
$errorPresent = $false
if ($null -ne $payload -and $payload.PSObject.Properties.Name -contains 'error') {
    $errorPresent = -not [string]::IsNullOrWhiteSpace([string]$payload.error)
}
$eventRecord = [ordered]@{
    schemaVersion = 1
    timestampUtc = [DateTime]::UtcNow.ToString('o')
    event = $Event
    conversationId = if ($null -ne $payload) { [string]$payload.conversationId } else { $null }
    workspacePaths = if ($null -ne $payload) { @($payload.workspacePaths) } else { @() }
    modelName = if ($null -ne $payload) { [string]$payload.modelName } else { $null }
    stepIdx = if ($null -ne $payload -and $payload.PSObject.Properties.Name -contains 'stepIdx') { $payload.stepIdx } else { $null }
    invocationNum = if ($null -ne $payload -and $payload.PSObject.Properties.Name -contains 'invocationNum') { $payload.invocationNum } else { $null }
    toolName = $toolName
    toolError = $errorPresent
}
$root = Join-Path $env:LOCALAPPDATA 'APES\runtime'
if (-not (Test-Path -LiteralPath $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
$logPath = Join-Path $root ('events-' + [DateTime]::UtcNow.ToString('yyyyMMdd') + '.jsonl')
$line = ($eventRecord | ConvertTo-Json -Depth 8 -Compress) + "`n"
$bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($line)
for ($attempt = 0; $attempt -lt 5; $attempt++) {
    $stream = $null
    try {
        $stream = [System.IO.File]::Open($logPath,[System.IO.FileMode]::Append,[System.IO.FileAccess]::Write,[System.IO.FileShare]::ReadWrite)
        $stream.Write($bytes,0,$bytes.Length)
        $stream.Flush()
        break
    } catch {
        if ($attempt -lt 4) { Start-Sleep -Milliseconds 80 }
    } finally {
        if ($null -ne $stream) { $stream.Dispose() }
    }
}
if ($Event -eq 'PreToolUse') { [Console]::Out.Write('{"decision":"allow"}') }
else { [Console]::Out.Write('{}') }
