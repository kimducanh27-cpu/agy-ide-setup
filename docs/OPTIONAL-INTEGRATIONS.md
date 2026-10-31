# Optional Antigravity integrations

APES installs Rules, Skills and Custom Agents by default. It does not preconfigure arbitrary MCP servers or lifecycle hooks.

## Impeccable (optional UI/UX skill)

Impeccable is an independent upstream design workflow for frontend/UI work. APES routes relevant tasks to it only when the skill is present; the APES UI/UX Custom Agent remains a separate read-only reviewer.

- Install instructions and safety model: docs/IMPECCABLE-INTEGRATION.md.
- Workspace build: .agent/skills/impeccable/ (singular .agent).
- Global build: ~/.gemini/config/skills/impeccable/.
- APES uses .agents/ (plural); these directories are intentionally separate.
- The APES installer for Impeccable copies the Antigravity skill build from a pinned upstream tag. It does not use an unverified --providers=antigravity flag and does not install hooks.
- The integration is optional and is not invoked for backend-only work.

## MCP

MCP is project/provider-specific and may require OAuth/API keys. Configure through Antigravity Customizations or .agents/mcp_config.json only after verifying server source, permissions, authentication, environment variables and data access. Never commit credentials.

## Hooks

Standalone Antigravity IDE supports global ~/.gemini/config/hooks.json and workspace .agents/hooks.json. Hooks execute shell commands during agent lifecycle. Before enabling:
- inspect the command and script;
- understand whether it can block or modify actions;
- test on a disposable workspace;
- back up and merge existing JSON instead of replacing it;
- use least privilege and short timeouts.

APES does not overwrite existing hook configurations. The Impeccable Antigravity skill install described here does not enable a lifecycle hook.
