# Antigravity compatibility notes

Last reviewed: 2026-10-31. Target: standalone Antigravity IDE on Windows 11.

## Rules
- Workspace: <workspace>/.agents/rules/*.md, plus AGENTS.md, GEMINI.md, .agents/AGENTS.md, .agents/GEMINI.md.
- Global: ~/.gemini/AGENTS.md, ~/.gemini/GEMINI.md, ~/.gemini/config/AGENTS.md, ~/.gemini/config/GEMINI.md, and ~/.gemini/config/rules/*.md.
- Every file in a rules/ directory needs valid frontmatter trigger: always_on, model_decision, glob, or manual.
- Rule scanning is shallow; put rule files directly inside rules/.

## Skills
- Workspace APES: <workspace>/.agents/skills/<skill-folder>/SKILL.md.
- Global IDE: ~/.gemini/config/skills/<skill-folder>/SKILL.md.
- Optional Impeccable workspace: <workspace>/.agent/skills/impeccable/SKILL.md (singular .agent).
- Optional Impeccable global: ~/.gemini/config/skills/impeccable/SKILL.md.
- APES and Impeccable paths intentionally differ; do not rename or merge them.

## Custom Agents
- Workspace: .agents/agents/<name>.md or .agents/agents/<name>/agent.md.
- Global IDE: ~/.gemini/config/agents/<name>.md or ~/.gemini/config/agents/<name>/agent.md.
- Required frontmatter: name, description; APES also sets mainAgent, subagent, model, commandExecutionPolicy.
- mainAgent: true allows primary selection; subagent: true allows native invocation.
- Model tiers used by APES: inherit, flash, pro.
- APES has one primary Orchestrator and eight subagents.

## Impeccable integration
- Install using scripts/Install-Impeccable.ps1; validate with scripts/Test-Impeccable.ps1.
- Upstream version is an independent optional skill; default APES pin is skill-v4.8.0.
- This integration copies skill files only. It does not configure a native Antigravity lifecycle hook or create an Impeccable subagent.
- The skill itself documents use of impeccable.cmd on Windows when no POSIX shell is available.

## Hooks and MCP
- Workspace hooks: .agents/hooks.json; global hooks: ~/.gemini/config/hooks.json.
- Workspace MCP: .agents/mcp_config.json; global MCP: ~/.gemini/config/mcp_config.json.
- They require project-specific security review; APES does not install them automatically.

## Discovery
In standalone IDE, inspect Agent side panel → ... → Customizations/Agents. Start a new conversation or reload the IDE if needed. CLI-only slash commands are not prerequisites for Desktop IDE.

References:
- https://antigravity.google/docs/rules/
- https://antigravity.google/docs/skills
- https://antigravity.google/docs/subagents
- https://antigravity.google/docs/hooks
- https://antigravity.google/docs/customization-discovery
- https://github.com/pbakaus/impeccable/blob/skill-v4.8.0/README.md
