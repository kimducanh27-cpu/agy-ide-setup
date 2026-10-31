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

Antigravity 2.0 Desktop App and Antigravity IDE support global ~/.gemini/config/hooks.json and workspace .agents/hooks.json. In Antigravity 2.0, active hooks can be viewed/toggled in Settings > Customizations > Hooks. The CLI is a separate surface with its own app-data directory.

Google documents these lifecycle events: SessionStart, PreToolUse, PostToolUse, PreInvocation, PostInvocation, and Stop. PostToolUse runs after a tool completes and carries toolCall.name, toolCall.args, stepIdx, optional error, and common session metadata.

Before enabling any hook:
- inspect the command and script;
- understand whether it can gate, allow, deny, ask, inject, or modify actions;
- test on a disposable workspace;
- back up and merge existing JSON instead of replacing it;
- use least privilege and short timeouts;
- never log/store raw hook payloads, tool arguments, prompts, file contents, terminal output, or raw errors unless a separate reviewed requirement explicitly demands them.

For a passive observer, do not use PreToolUse by default: its decision can change permission behavior. Prefer non-gating lifecycle hooks; remember PostToolUse is a completion signal, not a tool-start signal. Reduce error text to a boolean and allowlist only required metadata. Do not keep the agent alive from Stop unless that behavior is intentional and approved.

APES does not install hooks automatically. Any observer integration must be workspace-scoped by default, include backup/merge/rollback, and require explicit approval before writing .agents/hooks.json. The Impeccable Antigravity skill install described here does not enable a lifecycle hook.
