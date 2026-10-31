# Optional Antigravity integrations

APES installs Rules, Skills and Custom Agents by default. It does not preconfigure arbitrary MCP servers or lifecycle hooks.

## MCP
MCP is project/provider-specific and may require OAuth/API keys. Configure through Antigravity Customizations or `.agents/mcp_config.json` only after verifying server source, permissions, authentication, environment variables and data access. Never commit credentials.

## Hooks
Standalone Antigravity IDE supports global `~/.gemini/config/hooks.json` and workspace `.agents/hooks.json`. Hooks execute shell commands during agent lifecycle. Before enabling:
- inspect the command and script;
- understand whether it can block or modify actions;
- test on a disposable workspace;
- back up and merge existing JSON instead of replacing it;
- use least privilege and short timeouts.

APES does not overwrite existing hook configurations.
