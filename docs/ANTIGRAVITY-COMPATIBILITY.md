# Antigravity compatibility notes

Last reviewed: 2026-10-31. Target: standalone Antigravity IDE on Windows 11.

## Rules
- Workspace: `<workspace>/.agents/rules/*.md`, plus `AGENTS.md`, `GEMINI.md`, `.agents/AGENTS.md`, `.agents/GEMINI.md`.
- Global: `~/.gemini/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/.gemini/config/AGENTS.md`, `~/.gemini/config/GEMINI.md`, and `~/.gemini/config/rules/*.md`.
- Every file in a `rules/` directory needs valid frontmatter trigger: `always_on`, `model_decision`, `glob`, or `manual`.
- Rule scanning is shallow; put rule files directly inside `rules/`.

## Skills
- Workspace: `<workspace>/.agents/skills/<skill-folder>/SKILL.md`.
- Global IDE: `~/.gemini/config/skills/<skill-folder>/SKILL.md`.

## Custom Agents
- Workspace: `<workspace>/.agents/agents/<name>.md` or `<name>/agent.md`.
- Global IDE: `~/.gemini/config/agents/<name>.md` or `<name>/agent.md`.
- Required frontmatter: `name`, `description`; APES also sets `mainAgent`, `subagent`, `model`, `commandExecutionPolicy`.
- `mainAgent: true` allows primary selection; `subagent: true` allows native invocation.
- Model tiers used by APES: `inherit`, `flash`, `pro`.
- APES has one primary Orchestrator and eight subagents.

## Hooks and MCP
- Workspace hooks: `.agents/hooks.json`; global hooks: `~/.gemini/config/hooks.json`.
- Workspace MCP: `.agents/mcp_config.json`; global MCP: `~/.gemini/config/mcp_config.json`.
- They require project-specific security review; APES does not install them automatically.

## Discovery
In standalone IDE, inspect Agent side panel → `...` → Customizations/Agents. Start a new conversation or reload the IDE if needed. CLI-only slash commands are not prerequisites for Desktop IDE.

References:
- https://antigravity.google/docs/rules/
- https://antigravity.google/docs/skills
- https://antigravity.google/docs/subagents
- https://antigravity.google/docs/hooks
- https://antigravity.google/docs/customization-discovery
