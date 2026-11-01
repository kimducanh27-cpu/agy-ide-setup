[CmdletBinding()]
param(
    [string]$WorkRoot = (Join-Path $env:TEMP ('apes-upgrade-test-' + [guid]::NewGuid().ToString('N')))
)
$ErrorActionPreference = 'Stop'

$scriptRoot = $PSScriptRoot
$repoRoot = Split-Path -Parent $scriptRoot
$installer = Join-Path $scriptRoot 'Install-APES.ps1'
$updater = Join-Path $scriptRoot 'Update-APES.ps1'

# Use the same hash the installer and updater use. Get-FileHash hashes raw bytes, which
# would disagree with the CRLF-normalised hash recorded in the manifest and make the
# orphan look user-modified.
. (Join-Path $scriptRoot 'lib\APESManifest.ps1')

$checks = 0
$failures = [System.Collections.Generic.List[string]]::new()

function Assert([bool]$Condition, [string]$Message) {
    $script:checks++
    if ($Condition) { Write-Host "PASS  $Message" -ForegroundColor Green }
    else { Write-Host "FAIL  $Message" -ForegroundColor Red; $script:failures.Add($Message) }
}

function Invoke-Step([string]$Script, [string[]]$Arguments) {
    # Each step runs in its own process: the scripts call `exit`, which would terminate
    # this session if invoked in-process, and process isolation is what a real user has.
    $output = & pwsh -NoProfile -File $Script @Arguments 2>&1
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output -join "`n") }
}

$marker = 'apes-upgrade-test-marker'
try {
    Write-Host "APES upgrade test - workspace: $WorkRoot" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $WorkRoot | Out-Null

    # 1. Fresh install writes a manifest that records every file it wrote.
    $result = Invoke-Step $installer @('-Scope','Project','-ProjectPath',$WorkRoot)
    $manifestPath = Join-Path $WorkRoot '.agents\apes-install.json'
    Assert ($result.ExitCode -eq 0) 'installer exits 0'
    Assert (Test-Path -LiteralPath $manifestPath -PathType Leaf) 'installer writes apes-install.json'

    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    Assert ($manifest.PSObject.Properties.Name -contains 'files') 'manifest has a files array'
    Assert (@($manifest.files).Count -gt 50) "manifest records every installed file (got $(@($manifest.files).Count))"
    Assert (@($manifest.files | Where-Object { -not $_.hash }).Count -eq 0) 'every manifest entry carries a hash'

    # 2. A hand edit survives an update. This is the whole point of the release: the
    #    installer must not silently discard the user's own work.
    $edited = Join-Path $WorkRoot '.agents\rules\apes-core.md'
    Add-Content -LiteralPath $edited -Value "`n<!-- $marker -->" -Encoding UTF8
    $result = Invoke-Step $updater @('-Scope','Project','-ProjectPath',$WorkRoot)
    Assert ($result.ExitCode -eq 0) 'update exits 0'
    Assert ((Get-Content -LiteralPath $edited -Raw) -match $marker) 'a hand-edited file survives an update'

    # 3. A file APES wrote that this release no longer ships must be reported, and must
    #    survive until it is explicitly pruned.
    $orphan = Join-Path $WorkRoot '.agents\rules\apes-removed-in-3.2.md'
    Set-Content -LiteralPath $orphan -Value '# rule removed upstream' -Encoding UTF8
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $orphanHash = Get-APESFileHash -Path $orphan
    $manifest.files = @($manifest.files) + [pscustomobject]@{
        path = '.agents\rules\apes-removed-in-3.2.md'; hash = $orphanHash
    }
    $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

    $result = Invoke-Step $updater @('-Scope','Project','-ProjectPath',$WorkRoot)
    Assert (Test-Path -LiteralPath $orphan) 'an orphan is reported but not deleted without -Prune'
    Assert ($result.Output -match 'apes-removed-in-3\.2\.md') 'the orphan is named in the update output'

    # 4. The orphan record must survive an update that does not prune it, otherwise a
    #    later -Prune has nothing to act on and the stale rule stays live forever.
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $stillRecorded = @($manifest.files | Where-Object { $_.path -like '*apes-removed-in-3.2.md' }).Count -gt 0
    Assert $stillRecorded 'the orphan stays on the record until pruned'

    $result = Invoke-Step $updater @('-Scope','Project','-ProjectPath',$WorkRoot,'-Prune')
    Assert (-not (Test-Path -LiteralPath $orphan)) '-Prune removes the orphan'
    Assert ((Get-Content -LiteralPath $edited -Raw) -match $marker) 'pruning leaves the hand-edited file alone'

    # 5. Dry run must not touch the disk.
    $before = (Get-Item -LiteralPath $edited).LastWriteTimeUtc
    $result = Invoke-Step $updater @('-Scope','Project','-ProjectPath',$WorkRoot,'-DryRun')
    $after = (Get-Item -LiteralPath $edited).LastWriteTimeUtc
    Assert ($before -eq $after) '-DryRun writes nothing'
}
finally {
    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ''
Write-Host "Checks: $checks | Failures: $($failures.Count)" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}
Write-Host 'Upgrade path behaves: hand edits survive, orphans are visible, prune is explicit, dry run is inert.' -ForegroundColor Green
