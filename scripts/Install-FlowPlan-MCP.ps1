[CmdletBinding()]
param(
    [ValidateSet('Global','Project','All')]
    [string]$Scope = 'Global',
    [string]$ProjectPath = '',
    [string]$ServerUrl = 'http://127.0.0.1:3100/mcp',
    [switch]$ReplaceExisting
)

$ErrorActionPreference = 'Stop'

function Get-ConfigTargets {
    $targets = [System.Collections.Generic.List[object]]::new()
    if ($Scope -in @('Global','All')) {
        $targets.Add([pscustomobject]@{
            Name = 'Global'
            Path = Join-Path $HOME '.gemini/config/mcp_config.json'
        })
    }
    if ($Scope -in @('Project','All')) {
        if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
            throw 'ProjectPath is required for Project or All scope.'
        }
        $resolved = (Resolve-Path -LiteralPath $ProjectPath).Path
        $targets.Add([pscustomobject]@{
            Name = 'Project'
            Path = Join-Path $resolved '.agents/mcp_config.json'
        })
    }
    return $targets
}

function Read-McpConfig([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return [pscustomobject]@{ mcpServers = [pscustomobject]@{} }
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return [pscustomobject]@{ mcpServers = [pscustomobject]@{} }
    }

    try {
        $config = ConvertFrom-Json -InputObject $raw
    } catch {
        throw "Invalid JSON in '$Path'. No changes were made. Details: $($_.Exception.Message)"
    }

    if ($null -eq $config -or $config -isnot [System.Management.Automation.PSCustomObject]) {
        throw "The root of '$Path' must be a JSON object. No changes were made."
    }

    $serversProperty = $config.PSObject.Properties['mcpServers']
    if ($null -eq $serversProperty) {
        $config | Add-Member -MemberType NoteProperty -Name 'mcpServers' -Value ([pscustomobject]@{})
        $serversProperty = $config.PSObject.Properties['mcpServers']
    }

    if ($serversProperty.Value -isnot [System.Management.Automation.PSCustomObject]) {
        throw "mcpServers in '$Path' must be a JSON object. No changes were made."
    }

    return $config
}

function Write-McpConfig([string]$Path, [object]$Config, [string]$ScopeName) {
    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
        $backupRoot = Join-Path $env:LOCALAPPDATA 'APES/backups/FlowPlan-MCP'
        New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
        $backupPath = Join-Path $backupRoot "$stamp-$ScopeName-mcp_config.json"
        Copy-Item -LiteralPath $Path -Destination $backupPath
        Write-Host "BACKUP  $backupPath" -ForegroundColor Yellow
    }

    $json = ConvertTo-Json -InputObject $Config -Depth 100
    $temporaryPath = "$Path.$PID.tmp"
    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($temporaryPath, $json + [Environment]::NewLine, $encoding)
    Move-Item -LiteralPath $temporaryPath -Destination $Path -Force
    Write-Host "UPDATED $Path" -ForegroundColor Green
}

$parsedUri = $null
if (-not [Uri]::TryCreate($ServerUrl, [UriKind]::Absolute, [ref]$parsedUri)) {
    throw 'ServerUrl must be an absolute URL.'
}
if ($parsedUri.Scheme -ne 'http' -or $parsedUri.Host -notin @('127.0.0.1','localhost') -or $parsedUri.Port -ne 3100 -or $parsedUri.AbsolutePath.TrimEnd('/') -ne '/mcp') {
    throw 'This APES bridge only accepts the local FlowPlan endpoint http://127.0.0.1:3100/mcp (or localhost). Do not expose FlowPlan to a LAN or public network.'
}

$healthUrl = '{0}://{1}:{2}/health' -f $parsedUri.Scheme, $parsedUri.Host, $parsedUri.Port
try {
    $health = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 5
} catch {
    throw "FlowPlan is not responding at $healthUrl. Open FlowPlan Windows first. No MCP config was changed. Details: $($_.Exception.Message)"
}
if ($health.ok -ne $true) {
    throw 'FlowPlan health check did not return ok=true. No MCP config was changed.'
}

$targets = @(Get-ConfigTargets)
$prepared = [System.Collections.Generic.List[object]]::new()

foreach ($target in $targets) {
    $config = Read-McpConfig $target.Path
    $servers = $config.mcpServers
    $existing = $servers.PSObject.Properties['flowplan']
    $needsWrite = $true

    if ($null -ne $existing) {
        $existingUrlProperty = $existing.Value.PSObject.Properties['serverUrl']
        $existingUrl = if ($null -ne $existingUrlProperty) { [string]$existingUrlProperty.Value } else { '' }

        if ($existingUrl -eq $ServerUrl) {
            $needsWrite = $false
            Write-Host "UNCHANGED $($target.Name): FlowPlan entry already matches." -ForegroundColor Green
        } elseif (-not $ReplaceExisting) {
            throw "A different 'flowplan' entry already exists in '$($target.Path)'. Review it first, or rerun with -ReplaceExisting. No files were changed by this run."
        } else {
            $servers | Add-Member -MemberType NoteProperty -Name 'flowplan' -Value ([pscustomobject]@{ serverUrl = $ServerUrl }) -Force
        }
    } else {
        $servers | Add-Member -MemberType NoteProperty -Name 'flowplan' -Value ([pscustomobject]@{ serverUrl = $ServerUrl })
    }

    $prepared.Add([pscustomobject]@{
        Name = $target.Name
        Path = $target.Path
        Config = $config
        NeedsWrite = $needsWrite
    })
}

foreach ($item in $prepared) {
    if ($item.NeedsWrite) {
        Write-McpConfig $item.Path $item.Config $item.Name
    }
}

Write-Host ''
Write-Host 'FlowPlan MCP configuration prepared.' -ForegroundColor Cyan
Write-Host 'Next: reload MCP Servers in Antigravity and open a new chat.' -ForegroundColor Cyan
Write-Host 'Then ask the agent to call list_plans. This script checks local HTTP health; it does not prove Antigravity has loaded the MCP tools.' -ForegroundColor Yellow
