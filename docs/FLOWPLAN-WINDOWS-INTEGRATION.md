# FlowPlan Windows — APES integration and operator guide

## Purpose

FlowPlan is an optional visual observation board for APES, especially for users who do not want to inspect technical project files. APES remains the planner and executor; FlowPlan presents a simplified view of meaningful tasks and user feedback.

The canonical Project Brief, Master Plan and Task Graph live in the workspace under docs/engineering/apes/projects/<project-slug>/. FlowPlan is a projection of those artifacts, not the source of truth for scope, architecture or verified execution. See docs/PROJECT-PLANNING-AND-FLOWPLAN.md.

This integration targets Antigravity Desktop on Windows 10/11 x64. APES does not download, install, auto-start or update the FlowPlan application.

- Windows community build: https://github.com/kimducanh27-cpu/flowplan-windows
- Latest portable release: https://github.com/kimducanh27-cpu/flowplan-windows/releases/latest
- Upstream project and MIT license: https://github.com/Bariskau/flowplan
- Upstream tool implementation: https://github.com/Bariskau/flowplan/blob/master/src-tauri/src/tools.rs
- Antigravity MCP documentation: https://antigravity.google/docs/mcp

The Windows build is a community build, not an upstream official release. The published v1.3.2 portable archive is unsigned. Its published SHA256 is:

~~~text
6b2b7f5a493e028289699da6efe63b9abe61578aee6767259bd15ef00df0d981
~~~

A matching checksum confirms that the downloaded archive matches the published digest; it does not independently prove the binary is benign or reproducible.

## 1. Install and start FlowPlan Windows

1. Download the portable ZIP from the Windows repository Releases page.
2. Verify the archive SHA256 using PowerShell:

~~~powershell
Get-FileHash ".\FlowPlan-1.3.2-windows-x64.zip" -Algorithm SHA256
~~~

3. Extract the ZIP to a folder you control.
4. Keep FlowPlan.exe and WebView2Loader.dll in the same folder.
5. Start FlowPlan.exe. Windows SmartScreen may warn because the community build is unsigned; a matching checksum is not a code-signature verification.
6. Confirm the local health endpoint responds:

~~~powershell
Invoke-RestMethod http://127.0.0.1:3100/health
~~~

Expected result includes ok = true. The server is intended to listen on loopback. Do not expose port 3100 to the LAN or public internet.

FlowPlan data is stored under %USERPROFILE%\.plan-visual-planner\. Back up that folder before replacing app versions.

## 2. Connect Antigravity Desktop

Current Antigravity documentation describes:

- Global config: %USERPROFILE%\.gemini\config\mcp_config.json
- Workspace config: <workspace>\.agents\mcp_config.json
- Remote Streamable HTTP connections use serverUrl.

### Recommended: use the APES helper

Start FlowPlan first, then run from the APES repository:

~~~powershell
.\scripts\Install-FlowPlan-MCP.ps1 -Scope Global
~~~

For only the current project:

~~~powershell
.\scripts\Install-FlowPlan-MCP.ps1 -Scope Project -ProjectPath (Get-Location).Path
~~~

For both scopes:

~~~powershell
.\scripts\Install-FlowPlan-MCP.ps1 -Scope All -ProjectPath (Get-Location).Path
~~~

The helper:
- Requires the local FlowPlan health endpoint to return ok = true before writing.
- Only accepts HTTP on localhost/127.0.0.1 port 3100 and the /mcp endpoint.
- Merges only the flowplan entry, preserving other MCP servers and root settings.
- Backs up an existing config before writing.
- Refuses to replace an existing conflicting flowplan entry unless -ReplaceExisting is explicitly supplied.
- Does not write credentials, install FlowPlan, start the app, or alter other server entries.

To validate:

~~~powershell
.\scripts\Test-FlowPlan-MCP.ps1 -Scope Global
.\scripts\Test-FlowPlan-MCP.ps1 -Scope Project -ProjectPath (Get-Location).Path
~~~

These scripts check config shape and the local HTTP health endpoint. They do not prove that Antigravity has loaded the connector or discovered its tools.

### Reload and verify in Antigravity

1. Open Agent side panel → ... → MCP Servers → Manage MCP Servers.
2. Reload/restart the FlowPlan MCP server if necessary.
3. Start a new chat.
4. Ask the agent to call FlowPlan list_plans.
5. Require the actual tool result. A written claim without a tool call is not verification.

Expected endpoint: http://127.0.0.1:3100/mcp (Streamable HTTP).

## 3. What FlowPlan can and cannot do

FlowPlan exposes 12 MCP tools:

- create_plan, add_cards, update_card, remove_card
- get_cards, get_plan, list_plans, clear_plan, reorder_cards
- get_all_feedback, answer_feedback, acknowledge_feedback

It is a board and feedback surface, not the coding agent:
- It does not edit project files on behalf of Antigravity.
- It does not run tests or inspect the actual workspace diff.
- It does not automatically capture every terminal command, agent thought, tool call or subagent lifecycle event.
- It does not expose a dedicated card status field through update_card.
- APES must explicitly publish task changes through MCP.
- The FlowPlan UI has its own history timeline; do not claim that history is available through a dedicated MCP tool.

APES and the workspace remain the source of truth for actual code and test results. FlowPlan is the visible task board.

## 4. Status convention

Because the current MCP card schema has no dedicated status property, APES uses title prefixes:

| Prefix | Meaning | Allowed transition |
|---|---|---|
| [TODO] | Not started | [DOING] |
| [DOING] | In progress | [PASS] or [BLOCKED] |
| [PASS] | Acceptance criteria passed with evidence | Remains PASS unless regression |
| [BLOCKED] | Cannot proceed safely or a dependency failed | Re-plan or explicitly resume |
| [REVIEW] | Needs human decision/review | User decision required |

Never mark PASS merely because code was written. PASS requires actual verification evidence.

Every completed card description should contain:
- Summary of delivered behavior.
- Files changed.
- Acceptance criteria and their outcomes.
- Exact tests/commands actually run and result/exit code.
- Review findings and whether an independent reviewer was actually launched.
- Known issues and checks not run.

## 5. Dependency graph rules

FlowPlan add_cards requires a dependency on every card after the first card in an existing plan. Use a real dependency graph and never create cycles.

A safe pattern is:
- First card: project discovery / foundation (root).
- Parallel research branches: depend on the root card.
- Implementation cards: depend on the relevant research/architecture cards.
- Test cards: depend on the implementation cards they verify.
- Final audit: depends on required test cards.

When adding several cards in one call, $0, $1, etc. refer to cards in that same add_cards call. For example, after a root card exists, two parallel research cards can each depend on the root card ID. Do not add fake dependencies merely to make the API accept the payload; describe the reason for each dependency.

If a true independent root is needed, create a separate plan rather than creating a misleading edge.

## 6. Required APES operating loop

For every card:

1. Read the plan and card list; check dependencies and pending feedback.
2. Confirm the card can run: all prerequisite cards are [PASS].
3. Update the card to [DOING] and read it back to verify the write.
4. Implement only the card's approved scope.
5. Inspect Git diff and changed files.
6. Run the project's actual tests, lint, typecheck or build commands discovered from its manifests/configuration.
7. Require read-only QA/reviewer review when relevant. Only claim independent review if a native subagent was actually launched and returned.
8. Fix and retest failures. APES caps remediation at three rounds for a repeated defect; after that mark [BLOCKED] and escalate.
9. If all acceptance criteria pass, update the card to [PASS] and record evidence in the description.
10. Call get_cards/get_plan to verify the saved title and description.
11. Only then move to the next eligible card.

If a test fails, a dependency is incomplete, an acceptance criterion is unverifiable, or MCP update/readback fails, do not proceed as though the card passed.

Default behavior after a card passes: automatically continue to the next dependency-eligible card. Use Manual Checkpoint Mode when the user explicitly asks to stop after every card.

## 7. Feedback handling

Poll get_all_feedback before starting the next card and at milestone boundaries.

- Question: answer with answer_feedback after investigating.
- Directive: apply if it is within approved scope; then acknowledge_feedback.
- Issue: investigate, fix if in scope, verify, then acknowledge_feedback.
- Scope/architecture/security/financial/production-impact change: stop and request approval before acting.

Do not acknowledge a directive or issue merely to clear the inbox. Never call clear_plan or remove_card without explicit user authorization.

## 8. Recovery after chat or app restart

1. Ensure FlowPlan is running and health returns ok = true.
2. Call list_plans and locate the matching project plan. Do not create a duplicate by default.
3. Call get_plan/get_cards.
4. Compare board labels with actual workspace files, Git status and test evidence.
5. Reconcile uncertain cards as [REVIEW] or [BLOCKED]; do not assume old [DOING] means work is still running.
6. Resume only the next eligible card after dependencies and feedback are checked.

## 9. Prompt pack

Copy-ready Vietnamese prompts are in:
templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md

The pack includes connection preflight, plan/research, approval, card-by-card execution, per-card verification, manual checkpoint, safe resume, feedback handling and final audit.

## 10. Troubleshooting

| Symptom | Action |
|---|---|
| Health endpoint unreachable | Open FlowPlan.exe, wait for startup, retry /health |
| MCP not visible in Antigravity | Reload MCP servers and open a new chat |
| Tool call returns connection error | Check that FlowPlan is still running and port 3100 is listening on loopback |
| Duplicate plan appears | Use list_plans/get_plan; reuse matching active plan rather than creating another |
| Card update not visible | Call get_cards; retry only after checking tool error |
| Agent claims PASS without evidence | Run the verification prompt; change status to [REVIEW] or [BLOCKED] until proven |
| Existing config has a conflicting flowplan entry | Inspect it and use -ReplaceExisting only after deciding to replace it |
