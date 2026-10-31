[CmdletBinding()]
param(
    [ValidateSet('Global','Project','All')]
    [string]$Scope = 'Global',
    [string]$ProjectPath = '',
    [string]$ServerUrl = 'http://127.0.0.1:3100/mcp'
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()

function Test-Target([string]$Name, [string]$Path, [string]$ExpectedUrl) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Host "FAIL  $Name config missing: $Path" -ForegroundColor Red
        $script:failures.Add("$Name config missing")
        return
    }

    try {
        $config = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    } catch {
        Write-Host "FAIL  $Name config is invalid JSON: $Path" -ForegroundColor Red
        $script:failures.Add("$Name config invalid JSON")
        return
    }

    $entry = $null
    if ($null -ne $config.mcpServers) {
        $entry = $config.mcpServers.PSObject.Properties['flowplan']
    }
    if ($null -eq $entry) {
        Write-Host "FAIL  $Name FlowPlan entry missing" -ForegroundColor Red
        $script:failures.Add("$Name FlowPlan entry missing")
        return
    }

    $urlProperty = $entry.Value.PSObject.Properties['serverUrl']
    if ($null -eq $urlProperty -or [string]$urlProperty.Value -ne $ExpectedUrl) {
        Write-Host "FAIL  $Name FlowPlan serverUrl mismatch" -ForegroundColor Red
        $script:failures.Add("$Name FlowPlan serverUrl mismatch")
        return
    }

    Write-Host "PASS  $Name FlowPlan MCP config" -ForegroundColor Green
}

if ($Scope -in @('Global','All')) {
    Test-Target 'Global' (Join-Path $HOME '.gemini/config/mcp_config.json') $ServerUrl
}
if ($Scope -in @('Project','All')) {
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        throw 'ProjectPath is required for Project or All scope.'
    }
    $resolved = (Resolve-Path -LiteralPath $ProjectPath).Path
    Test-Target 'Project' (Join-Path $resolved '.agents/mcp_config.json') $ServerUrl
}

$uri = [Uri]$ServerUrl
$healthUrl = '{0}://{1}:{2}/health' -f $uri.Scheme, $uri.Host, $uri.Port
try {
    $health = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 5
    if ($health.ok -eq $true) {
        Write-Host "PASS  FlowPlan local health endpoint: $healthUrl" -ForegroundColor Green
    } else {
        Write-Host 'FAIL  FlowPlan health response did not report ok=true' -ForegroundColor Red
        $failures.Add('FlowPlan health response not ok')
    }
} catch {
    Write-Host "FAIL  FlowPlan local health endpoint unreachable: $healthUrl" -ForegroundColor Red
    $failures.Add('FlowPlan health endpoint unreachable')
}

if ($failures.Count -gt 0) {
    Write-Host "Failures: $($failures.Count)" -ForegroundColor Red
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}

Write-Host 'Local config and HTTP health checks passed.' -ForegroundColor Green
Write-Host 'Final verification still requires Antigravity to load the server and successfully call list_plans/tools.' -ForegroundColor Yellow
