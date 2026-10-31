# APES × Impeccable — Optional UI/UX Integration

Last reviewed: 2026-10-31. Target: standalone Google Antigravity IDE on Windows 11.

## Responsibility boundary

| Layer | Owns | Does not replace |
|---|---|---|
| APES | Project bootstrap, research, architecture, native subagents, approvals, milestones, QA, independent evaluation | A specialist design playbook |
| Impeccable | Frontend/UI design direction, design-system context, UX critique, deterministic UI checks and refinement commands | APES lifecycle orchestration or its reviewer/evaluator |

This is an optional bridge. APES does not copy Impeccable source into this repository and does not pin users to APES release cadence. The installed Impeccable skill remains upstream-owned and Apache-2.0 licensed.

## Verified upstream build

The integration is based on Impeccable skill tag skill-v4.8.0 (2026-10-26), upstream commit 414603bf14c7a344edb466bb1f85690c77ce8b7d.

- Repository: https://github.com/pbakaus/impeccable
- Release: https://github.com/pbakaus/impeccable/releases/tag/skill-v4.8.0
- Antigravity build: .agent/skills/impeccable/
- Required Windows launcher: scripts/impeccable.cmd
- Upstream license: Apache-2.0; the installer copies the upstream LICENSE into the installed skill folder.

The upstream README documents a manual Antigravity build under .agent/. Its scriptable --providers examples do not list Antigravity, so APES does not assume --providers=antigravity works. Instead, its installer copies the published Antigravity skill build from the pinned upstream tag.

## Install

Run from an elevated terminal only if your organization requires it; APES itself does not require Administrator:

~~~powershell
$apes = Join-Path $env:LOCALAPPDATA 'APES\agy-ide-setup'
& (Join-Path $apes 'scripts\Install-Impeccable.ps1') -Scope Project -ProjectPath (Get-Location).Path
& (Join-Path $apes 'scripts\Test-Impeccable.ps1') -Scope Project -ProjectPath (Get-Location).Path
~~~

Scopes:
- Project: <workspace>/.agent/skills/impeccable/.
- Global: ~/.gemini/config/skills/impeccable/.
- All: install to both locations.

The default tag is skill-v4.8.0. To install a later reviewed upstream tag, pass its exact skill-vX.Y.Z tag to -Version. Review the release notes and tag before changing the pin.

### Installer safety

- Downloads a ZIP archive from GitHub's codeload endpoint for the selected upstream tag.
- Locates only the official Antigravity skill directory; verifies the skill name, version, Windows launcher, and key reference files.
- Copies the Apache-2.0 license into the installed skill folder.
- Does not execute the downloaded launcher or install hooks/MCP servers.
- If an existing target contains an Impeccable skill, backs up that folder under %LOCALAPPDATA%\APES\backups\ before replacing it.
- If the target path exists but does not contain an Impeccable skill, the script stops rather than overwriting unrelated content.
- Other skills inside .agent/skills/ and ~/.gemini/config/skills/ are left untouched.

The first time the skill's launcher is invoked, upstream's own runtime may download its engine into the user cache. That runtime behavior is separate from APES installation.

## Use inside Antigravity

1. Reload Antigravity after installation.
2. For a new product context, ask the agent to run /impeccable init once in that project.
3. For an existing interface, /impeccable document can capture the existing design system into DESIGN.md.
4. Choose a task-specific command:
   - /impeccable shape: plan UX/UI before implementing a surface.
   - /impeccable critique: structured design/UX critique.
   - /impeccable audit: accessibility, performance and responsive checks.
   - /impeccable polish: final refinement.
   - /impeccable harden: error states, localization and edge cases.
   - /impeccable adapt: responsive/device adaptation.
   - /impeccable animate: purposeful motion.

The installed skill itself specifies its one-per-session context-loading step and the references required for each command. On Windows without a POSIX shell, it instructs the agent to use impeccable.cmd; keep the working directory at the project root.

Do not run init or document repeatedly without a reason. They create/update durable project context files; preserve existing project decisions and review diffs.

## Antigravity limitations

- This APES integration installs the skill files only.
- Do not claim Antigravity has an Impeccable lifecycle hook that scans every direct UI edit. Upstream's documented provider-native hook support names other providers; APES does not add a custom Antigravity hook.
- Do not claim Impeccable is a native subagent. It is a skill/command workflow.
- APES continues to use apes-ui-ux-reviewer for a separate read-only review and apes-harness-evaluator for evidence-based milestone evaluation.
- Backend-only, infrastructure-only and data-only work should not route through Impeccable.

## Update and rollback

To update, rerun Install-Impeccable.ps1 with the newly reviewed -Version. The previous target is backed up before replacement. To roll back, restore the corresponding backup folder to the matching impeccable destination after closing Antigravity. Do not restore a backup over a newer install without first preserving that install too.
