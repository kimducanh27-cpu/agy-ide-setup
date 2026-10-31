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

function Test-RequiredPath([string]$Path, [string]$Label) {
    $script:checks++
    if (Test-Path -LiteralPath $Path) {
        Write-Host "PASS  $Label" -ForegroundColor Green
    } else {
        Write-Host "FAIL  $Label" -ForegroundColor Red
        $script:failures.Add($Label)
    }
}

function Test-RuleFile([string]$Path) {
    $script:checks++
    $raw = Get-Content -LiteralPath $Path -Raw
    $header = [regex]::Match($raw, '(?s)\A---\r?\n(?<frontmatter>.*?)\r?\n---(?:\r?\n|\z)')
    $frontmatter = $header.Groups['frontmatter'].Value
    $valid = $header.Success -and ($frontmatter -match '(?m)^trigger:\s*(always_on|model_decision|glob|manual)\s*$')
    if ($valid) {
        Write-Host "PASS  Rule metadata: $Path" -ForegroundColor Green
    } else {
        Write-Host "FAIL  Rule metadata: $Path" -ForegroundColor Red
        $script:failures.Add("Invalid rule: $Path")
    }
}

function Test-SkillFile([string]$Path) {
    $script:checks++
    $raw = Get-Content -LiteralPath $Path -Raw
    $header = [regex]::Match($raw, '(?s)\A---\r?\n(?<frontmatter>.*?)\r?\n---(?:\r?\n|\z)')
    $frontmatter = $header.Groups['frontmatter'].Value
    $hasName = $frontmatter -match '(?m)^name:\s*[a-z0-9-]+\s*$'
    $hasDescription = $frontmatter -match '(?m)^description:\s*.+$'
    $valid = $header.Success -and $hasName -and $hasDescription
    if ($valid) {
        Write-Host "PASS  Skill metadata: $Path" -ForegroundColor Green
    } else {
        Write-Host "FAIL  Skill metadata: $Path" -ForegroundColor Red
        $script:failures.Add("Invalid skill: $Path")
    }
}

Write-Host 'APES 2.0 deterministic validation' -ForegroundColor Cyan

foreach ($item in @(
    @('README.md','README'),
    @('START_HERE_FOR_AI_VI.md','AI setup guide'),
    @('NOTICE.md','Attribution notice'),
    @('scripts/Install-APES.ps1','Installer')
)) {
    Test-RequiredPath (Join-Path $repoRoot $item[0]) $item[1]
}

$repoRules = @(Get-ChildItem (Join-Path $repoRoot '.agents/rules') -Filter '*.md' -File)
foreach ($file in $repoRules) {
    Test-RuleFile $file.FullName
}

$repoSkills = @(Get-ChildItem (Join-Path $repoRoot '.agents/skills') -Filter 'SKILL.md' -Recurse -File)
foreach ($file in $repoSkills) {
    Test-SkillFile $file.FullName
}
if ($repoSkills.Count -lt 20) {
    $failures.Add("Expected at least 20 skills; found $($repoSkills.Count).")
}

if ($CheckGlobal) {
    $globalRoot = Join-Path $HOME '.gemini/config'
    foreach ($file in Get-ChildItem (Join-Path $repoRoot 'global/rules') -Filter '*.md' -File) {
        Test-RequiredPath (Join-Path $globalRoot ('rules/' + $file.Name)) "Global rule $($file.Name)"
    }
    foreach ($folder in Get-ChildItem (Join-Path $repoRoot 'global/skills') -Directory) {
        Test-RequiredPath (Join-Path $globalRoot ('skills/' + $folder.Name + '/SKILL.md')) "Global skill $($folder.Name)"
    }
}

if ($ProjectPath) {
    $project = (Resolve-Path -LiteralPath $ProjectPath).Path
    foreach ($file in $repoRules) {
        Test-RequiredPath (Join-Path $project ('.agents/rules/' + $file.Name)) "Workspace rule $($file.Name)"
    }
    foreach ($file in $repoSkills) {
        $relative = $file.FullName.Substring((Join-Path $repoRoot '.agents/skills').Length).TrimStart('\','/')
        Test-RequiredPath (Join-Path $project ('.agents/skills/' + $relative)) "Workspace skill $relative"
    }
    if ($Stage -ne 'None') {
        $bootstrap = Join-Path $project 'docs/engineering/apes/bootstrap'
        $required = @(
            '00-project-brief.md',
            '01-technology-research.md',
            '02-architecture.md',
            '03-quality-plan.md',
            '04-milestones.md',
            '05-risk-register.md',
            '06-approval.md'
        )
        foreach ($name in $required) {
            Test-RequiredPath (Join-Path $bootstrap $name) "Bootstrap document $name"
        }
        if ($Stage -eq 'Approved') {
            $approval = Join-Path $bootstrap '06-approval.md'
            $script:checks++
            if ((Test-Path -LiteralPath $approval) -and ((Get-Content -LiteralPath $approval -Raw) -match '(?m)^- Decision:\s*APPROVED\s*$')) {
                Write-Host 'PASS  Human approval recorded' -ForegroundColor Green
            } else {
                Write-Host 'FAIL  Human approval missing' -ForegroundColor Red
                $failures.Add('Human approval missing')
            }
        }
    }
}

Write-Host "Checks: $checks | Failures: $($failures.Count)" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'All deterministic checks passed. This does not certify application quality; run the project test plan.' -ForegroundColor Green
