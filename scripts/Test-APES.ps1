[CmdletBinding()]
param(
    [string]$ProjectPath = '',
    [switch]$CheckGlobal,
    [ValidateSet('None','PreCode','Approved')][string]$Stage = 'None'
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$checks = 0
$expectedAgentCount = 9
$knownTools = @('view_file','grep_search','find_by_name','code_search','run_command')

function Test-RequiredPath([string]$Path, [string]$Label) {
    $script:checks++
    if (Test-Path -LiteralPath $Path) { Write-Host "PASS  $Label" -ForegroundColor Green }
    else { Write-Host "FAIL  $Label" -ForegroundColor Red; $script:failures.Add($Label) }
}
function Get-Frontmatter([string]$Path) {
    $raw = Get-Content -LiteralPath $Path -Raw
    $header = [regex]::Match($raw, '(?s)\A---\r?\n(?<frontmatter>.*?)\r?\n---(?:\r?\n|\z)')
    if (-not $header.Success) { return $null }
    return $header.Groups['frontmatter'].Value
}
function Test-RuleFile([string]$Path) {
    $script:checks++
    $frontmatter = Get-Frontmatter $Path
    $valid = ($null -ne $frontmatter) -and ($frontmatter -match '(?m)^trigger:\s*(always_on|model_decision|glob|manual)\s*$')
    if ($valid) { Write-Host "PASS  Rule metadata: $Path" -ForegroundColor Green }
    else { Write-Host "FAIL  Rule metadata: $Path" -ForegroundColor Red; $script:failures.Add("Invalid rule: $Path") }
}
function Test-SkillFile([string]$Path) {
    $script:checks++
    $frontmatter = Get-Frontmatter $Path
    $hasName = ($null -ne $frontmatter) -and ($frontmatter -match '(?m)^name:\s*[a-z0-9-]+\s*$')
    $hasDescription = ($null -ne $frontmatter) -and ($frontmatter -match '(?m)^description:\s*.+$')
    if ($hasName -and $hasDescription) { Write-Host "PASS  Skill metadata: $Path" -ForegroundColor Green }
    else { Write-Host "FAIL  Skill metadata: $Path" -ForegroundColor Red; $script:failures.Add("Invalid skill: $Path") }
}
function Test-AgentFile([string]$Path) {
    $script:checks++
    $frontmatter = Get-Frontmatter $Path
    if ($null -eq $frontmatter) { $script:failures.Add("Missing agent frontmatter: $Path"); return }
    $expectedName = [IO.Path]::GetFileNameWithoutExtension($Path)
    $validName = $frontmatter -match ("(?m)^name:\s*" + [regex]::Escape($expectedName) + "\s*$")
    $validDescription = $frontmatter -match '(?m)^description:\s*.+$'
    $validSubagent = $frontmatter -match '(?m)^subagent:\s*true\s*$'
    $validMainAgent = $frontmatter -match '(?m)^mainAgent:\s*(true|false)\s*$'
    $validModel = $frontmatter -match '(?m)^model:\s*(inherit|flash|pro)\s*$'
    $validPolicy = $frontmatter -match '(?m)^commandExecutionPolicy:\s*(off|auto|eager|sandbox)\s*$'
    $validTools = $true
    $toolSection = [regex]::Match($frontmatter, '(?ms)^tools:\s*\r?\n(?<items>(?:[ \t]+-[^\r\n]*\r?\n?)*)')
    if ($toolSection.Success) {
        foreach ($tool in [regex]::Matches($toolSection.Groups['items'].Value, '(?m)^\s*-\s*([a-zA-Z0-9_]+)\s*$')) {
            if ($knownTools -notcontains $tool.Groups[1].Value) {
                $validTools = $false
                $script:failures.Add("Unknown tool '$($tool.Groups[1].Value)' in $Path")
            }
        }
    }
    if ($validName -and $validDescription -and $validSubagent -and $validMainAgent -and $validModel -and $validPolicy -and $validTools) {
        Write-Host "PASS  Custom Agent metadata: $Path" -ForegroundColor Green
    } else {
        Write-Host "FAIL  Custom Agent metadata: $Path" -ForegroundColor Red
        $script:failures.Add("Invalid custom agent: $Path")
    }
}

Write-Host 'APES 3.0 deterministic validation' -ForegroundColor Cyan
foreach ($item in @(
    @('README.md','README'),
    @('config/workflows.json','Workflow catalog'),
    @('templates/engine/BASE-PROMPT-VI.md','Workflow base prompt'),
    @('scripts/Build-APESPrompt.ps1','Prompt Builder'),
    @('scripts/Manage-APESRun.ps1','Run State Manager'),
    @('docs/PROMPT-WORKFLOW-ENGINE-V3.md','Workflow Engine documentation'),
    @('templates/prompts/APES-3.0-QUICKSTART-VI.md','Workflow quickstart'),
    @('templates/prompts/APES-3.0-EXAMPLE-VI.md','Workflow example'),
    @('.agents/skills/apes-workflow-engine/SKILL.md','Workspace workflow skill'),
    @('global/skills/apes-workflow-engine/SKILL.md','Global workflow skill'),
    @('.agents/rules/apes-workflow-engine.md','Workspace workflow rule'),
    @('global/rules/apes-workflow-engine.md','Global workflow rule'),
    @('START_HERE_FOR_AI_VI.md','AI setup guide'),
    @('NOTICE.md','Attribution notice'),
    @('scripts/Install-APES.ps1','APES installer'),
    @('scripts/Install-Impeccable.ps1','Optional Impeccable installer'),
    @('scripts/Test-Impeccable.ps1','Optional Impeccable validator'),
    @('docs/IMPECCABLE-INTEGRATION.md','Impeccable integration guide'),
    @('docs/FLOWPLAN-WINDOWS-INTEGRATION.md','FlowPlan Windows integration guide'),
    @('templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md','FlowPlan Vietnamese prompt pack'),
    @('scripts/Install-FlowPlan-MCP.ps1','Optional FlowPlan MCP config helper'),
    @('scripts/Test-FlowPlan-MCP.ps1','Optional FlowPlan MCP validator'),
    @('.agents/skills/apes-flowplan-operations/SKILL.md','FlowPlan operations skill'),
    @('global/skills/apes-flowplan-operations/SKILL.md','Global FlowPlan operations skill'),
    @('.agents/rules/apes-flowplan-progress.md','Workspace FlowPlan progress rule'),
    @('global/rules/apes-flowplan-progress.md','Global FlowPlan progress rule'),
    @('global/AGENTS.md','Global instructions'),
    @('.agents/AGENTS.md','Workspace instructions')
)) { Test-RequiredPath (Join-Path $repoRoot $item[0]) $item[1] }

# Parse every PowerShell script without executing it. CI therefore validates syntax
# without downloading the optional Impeccable package or changing a developer machine.
foreach ($scriptFile in Get-ChildItem (Join-Path $repoRoot 'scripts') -Filter '*.ps1' -File) {
    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($scriptFile.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
    $checks++
    if ($parseErrors.Count -eq 0) {
        Write-Host "PASS  PowerShell syntax: $($scriptFile.Name)" -ForegroundColor Green
    } else {
        Write-Host "FAIL  PowerShell syntax: $($scriptFile.Name)" -ForegroundColor Red
        foreach ($parseError in $parseErrors) { $failures.Add("$($scriptFile.Name): $($parseError.Message)") }
    }
}

# Validate the workflow catalog and execute a temporary Prompt Builder + state-ledger smoke test.
try {
    $catalog = Get-Content -LiteralPath (Join-Path $repoRoot 'config/workflows.json') -Raw | ConvertFrom-Json
    $workflowIds = @($catalog.workflows | ForEach-Object { $_.id })
    $expectedWorkflows = @('quick-fix','standard-feature','full-project','deep-research','hard-review')
    $missingWorkflows = @($expectedWorkflows | Where-Object { $workflowIds -notcontains $_ })
    $checks++
    if ($missingWorkflows.Count -eq 0 -and $catalog.schemaVersion -eq 1) { Write-Host 'PASS  Workflow catalog schema and five workflows' -ForegroundColor Green }
    else { throw "Workflow catalog invalid; missing: $($missingWorkflows -join ', ')" }

    $smokeRoot = Join-Path ([IO.Path]::GetTempPath()) ('apes-engine-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $smokeRoot -Force | Out-Null
    $promptPath = Join-Path $smokeRoot 'generated-prompt.md'
    & (Join-Path $repoRoot 'scripts/Build-APESPrompt.ps1') -Workflow standard-feature -ProjectPath $smokeRoot -Goal 'Validator smoke test' -Mode ManualCheckpoint -OutputPath $promptPath
    $checks++
    if ((Test-Path -LiteralPath $promptPath) -and ((Get-Content -LiteralPath $promptPath -Raw) -match 'Validator smoke test')) { Write-Host 'PASS  Prompt Builder smoke test' -ForegroundColor Green }
    else { throw 'Prompt Builder did not create the expected prompt.' }

    $initOutput = & (Join-Path $repoRoot 'scripts/Manage-APESRun.ps1') -Action Initialize -Workflow standard-feature -ProjectPath $smokeRoot
    $runLine = @($initOutput | Where-Object { $_ -like 'RUN_ID=*' }) | Select-Object -First 1
    if (-not $runLine) { throw 'State Manager did not return RUN_ID.' }
    $runId = $runLine.Substring(7)
    & (Join-Path $repoRoot 'scripts/Manage-APESRun.ps1') -Action Advance -ProjectPath $smokeRoot -RunId $runId -Stage DISCOVERY -Evidence 'Smoke test evidence'
    $statePath = Join-Path $smokeRoot ('.apes/runs/' + $runId + '/state.json')
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    $checks++
    if ($state.currentStage -eq 'RESEARCH' -and $state.completedStages -contains 'DISCOVERY') { Write-Host 'PASS  Run State transition and evidence checkpoint' -ForegroundColor Green }
    else { throw 'Run State did not advance to RESEARCH as expected.' }
    & (Join-Path $repoRoot 'scripts/Manage-APESRun.ps1') -Action Advance -ProjectPath $smokeRoot -RunId $runId -Stage RESEARCH -Evidence 'Research checkpoint smoke test'
    & (Join-Path $repoRoot 'scripts/Manage-APESRun.ps1') -Action Advance -ProjectPath $smokeRoot -RunId $runId -Stage PLANNING -Evidence 'Planning checkpoint smoke test'
    $approvalRejected = $false
    try { & (Join-Path $repoRoot 'scripts/Manage-APESRun.ps1') -Action Advance -ProjectPath $smokeRoot -RunId $runId -Stage APPROVAL -Evidence 'Approval guard test' | Out-Null }
    catch { $approvalRejected = $true }
    $checks++
    if ($approvalRejected) { Write-Host 'PASS  Approval gate rejects missing confirmation' -ForegroundColor Green }
    else { throw 'Approval gate accepted a transition without explicit confirmation.' }
    & (Join-Path $repoRoot 'scripts/Manage-APESRun.ps1') -Action Advance -ProjectPath $smokeRoot -RunId $runId -Stage APPROVAL -Evidence 'Explicit confirmation guard smoke test' -ApprovalConfirmed
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    $checks++
    if ($state.currentStage -eq 'IMPLEMENTATION') { Write-Host 'PASS  Approval confirmation advances to next stage' -ForegroundColor Green }
    else { throw 'Approval confirmation did not advance to IMPLEMENTATION.' }
} catch {
    $failures.Add("Workflow Engine smoke test: $($_.Exception.Message)")
    Write-Host "FAIL  Workflow Engine smoke test: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($smokeRoot -and (Test-Path -LiteralPath $smokeRoot)) { Remove-Item -LiteralPath $smokeRoot -Recurse -Force }
}

$repoRules = @(Get-ChildItem (Join-Path $repoRoot '.agents/rules') -Filter '*.md' -File)
foreach ($file in $repoRules) { Test-RuleFile $file.FullName }
$repoSkills = @(Get-ChildItem (Join-Path $repoRoot '.agents/skills') -Filter 'SKILL.md' -Recurse -File)
foreach ($file in $repoSkills) { Test-SkillFile $file.FullName }
if ($repoSkills.Count -lt 20) { $failures.Add("Expected at least 20 skills; found $($repoSkills.Count).") }

$repoAgents = @(Get-ChildItem (Join-Path $repoRoot '.agents/agents') -Filter '*.md' -File)
if ($repoAgents.Count -ne $expectedAgentCount) { $failures.Add("Expected $expectedAgentCount workspace agents; found $($repoAgents.Count).") }
foreach ($file in $repoAgents) { Test-AgentFile $file.FullName }
$primaryAgents = @($repoAgents | Where-Object { (Get-Frontmatter $_.FullName) -match '(?m)^mainAgent:\s*true\s*$' })
if ($primaryAgents.Count -ne 1 -or $primaryAgents[0].BaseName -ne 'apes-orchestrator') {
    $failures.Add('Exactly one primary agent named apes-orchestrator is required.')
}

if ($CheckGlobal) {
    $globalRoot = Join-Path $HOME '.gemini/config'
    Test-RequiredPath (Join-Path $globalRoot 'AGENTS.md') 'Installed global AGENTS.md'
    foreach ($file in Get-ChildItem (Join-Path $repoRoot 'global/rules') -Filter '*.md' -File) {
        Test-RequiredPath (Join-Path $globalRoot ('rules/' + $file.Name)) "Global rule $($file.Name)"
    }
    foreach ($folder in Get-ChildItem (Join-Path $repoRoot 'global/skills') -Directory) {
        Test-RequiredPath (Join-Path $globalRoot ('skills/' + $folder.Name + '/SKILL.md')) "Global skill $($folder.Name)"
    }
    foreach ($file in $repoAgents) {
        Test-RequiredPath (Join-Path $globalRoot ('agents/' + $file.Name)) "Global agent $($file.BaseName)"
    }
}
if ($ProjectPath) {
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    Test-RequiredPath (Join-Path $project '.agents/AGENTS.md') 'Installed workspace AGENTS.md'
    foreach ($file in $repoRules) { Test-RequiredPath (Join-Path $project ('.agents/rules/' + $file.Name)) "Workspace rule $($file.Name)" }
    foreach ($file in $repoSkills) {
        $relative = $file.FullName.Substring((Join-Path $repoRoot '.agents/skills').Length).TrimStart('\','/')
        Test-RequiredPath (Join-Path $project ('.agents/skills/' + $relative)) "Workspace skill $relative"
    }
    foreach ($file in $repoAgents) {
        Test-RequiredPath (Join-Path $project ('.agents/agents/' + $file.Name)) "Workspace agent $($file.BaseName)"
    }
    if ($Stage -ne 'None') {
        $bootstrap = Join-Path $project 'docs/engineering/apes/bootstrap'
        foreach ($name in @('00-project-brief.md','01-technology-research.md','02-architecture.md','03-quality-plan.md','04-milestones.md','05-risk-register.md','06-approval.md')) {
            Test-RequiredPath (Join-Path $bootstrap $name) "Bootstrap document $name"
        }
        Test-RequiredPath (Join-Path $project 'docs/engineering/apes/agent-routing.md') 'Agent routing guide'
        if ($Stage -eq 'Approved') {
            $approval = Join-Path $bootstrap '06-approval.md'
            $script:checks++
            if ((Test-Path -LiteralPath $approval) -and ((Get-Content -LiteralPath $approval -Raw) -match '(?m)^- Decision:\s*APPROVED\s*$')) {
                Write-Host 'PASS  Human approval recorded' -ForegroundColor Green
            } else { Write-Host 'FAIL  Human approval missing' -ForegroundColor Red; $failures.Add('Human approval missing') }
        }
    }
}
Write-Host "Checks: $checks | Failures: $($failures.Count)" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}
Write-Host 'All deterministic checks passed. This validates metadata, syntax and installation paths, not application quality.' -ForegroundColor Green
