# APES 2.1 — Native Custom Agents

Last reviewed: 2026-10-31.

APES includes actual Antigravity Custom Agent Markdown files, not only role Skills.

## Native locations
- Workspace: `.agents/agents/<name>.md` (or `.agents/agents/<name>/agent.md`).
- Global IDE: `~/.gemini/config/agents/<name>.md`.

Installer copies workspace agent definitions to both scopes. Existing APES-named collisions are backed up; unrelated agents remain untouched.

## Composition
- `apes-orchestrator`: the only APES agent with `mainAgent: true`.
- Eight specialist workers: `mainAgent: false`, `subagent: true`.
- Role Skills remain the reusable knowledge/workflow layer.

## Frontmatter
APES uses documented fields: `name`, `description`, `mainAgent`, `subagent`, `model`, `commandExecutionPolicy`, and `tools` where an explicit allowlist is appropriate.

Reviewers use documented read-only tools. QA additionally receives `run_command` to execute checks. Implementation/Orchestrator omit `tools` to use runtime defaults and retain the sandbox command policy.

## Verify in Desktop IDE
1. Open the project workspace.
2. Open Agent side panel → `...` → Customizations/Agents.
3. Confirm nine APES agents appear.
4. Select `apes-orchestrator` if desired.
5. Ask it to delegate one read-only task to `apes-project-analyst`; confirm the subagent is actually visible and returns a result.
6. If the installed IDE does not expose this UI/API, report that limitation; do not simulate a subagent.

CLI-only `/agents` is not required for standalone Desktop IDE.

## MCP and Hooks
APES does not silently install MCP servers or hooks. MCP may require OAuth/API credentials; hooks execute shell commands and must be merged/tested, never blindly overwritten. See `docs/OPTIONAL-INTEGRATIONS.md`.
