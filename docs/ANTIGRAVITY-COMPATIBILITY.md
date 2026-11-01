# Antigravity compatibility notes

Last reviewed: 2026-10-31. APES supports the standalone Antigravity 2.0 Desktop App and the standalone Antigravity IDE. These are separate product surfaces; the CLI is a third surface.

## Supported surfaces

| Surface | Product shape | App data directory |
|---|---|---|
| Antigravity 2.0 | Standalone desktop agent command center | ~/.gemini/antigravity |
| Antigravity IDE | Standalone IDE | ~/.gemini/antigravity-ide |
| Antigravity CLI | Terminal interface | ~/.gemini/antigravity-cli |

Do not mix transcript paths, runtime fixtures, or compatibility claims between these surfaces. A project may use the shared workspace customization locations below, but runtime data roots remain surface-specific.

## Rules

- Workspace: <workspace>/.agents/rules/*.md, plus AGENTS.md, GEMINI.md, .agents/AGENTS.md, .agents/GEMINI.md.
- Global: ~/.gemini/AGENTS.md, ~/.gemini/GEMINI.md, ~/.gemini/config/AGENTS.md, ~/.gemini/config/GEMINI.md, and ~/.gemini/config/rules/*.md.
- Every file in a rules/ directory needs valid frontmatter trigger: always_on, model_decision, glob, or manual.
- Rule scanning is shallow; put rule files directly inside rules/.

## Skills

- Workspace APES: <workspace>/.agents/skills/<skill-folder>/SKILL.md.
- Global: ~/.gemini/config/skills/<skill-folder>/SKILL.md.
- Optional Impeccable workspace: <workspace>/.agent/skills/impeccable/SKILL.md (singular .agent).
- Optional Impeccable global: ~/.gemini/config/skills/impeccable/SKILL.md.
- APES and Impeccable paths intentionally differ; do not rename or merge them.

## Custom Agents

- Workspace: .agents/agents/<name>.md or .agents/agents/<name>/agent.md.
- Global: ~/.gemini/config/agents/<name>.md or ~/.gemini/config/agents/<name>/agent.md.
- Antigravity 2.0 Desktop App supports workspace and global Custom Agents using Markdown files with YAML frontmatter.
- Required frontmatter: name, description; APES also sets mainAgent, subagent, model, commandExecutionPolicy.
- mainAgent: true allows primary selection; subagent: true allows native invocation.
- Model tiers used by APES: inherit, flash, pro.
- APES has one primary Orchestrator and eight specialist workers.
- File presence is not proof of runtime discovery or successful invocation. Smoke-test the target surface and report evidence.

## Metadata validation APES enforces

`scripts/Test-APES.ps1` rejects metadata that Antigravity would silently mishandle. Both checks below exist because the failure mode is invisible at runtime.

- **Tool names in `tools:` must be real, and the docs are not the whole list.** Google warns: *"Specifying an unmapped or misspelled tool name in the `tools` list may cause the subagent process to hang during execution."* The public docs only ever show `view_file`, `replace_file_content`, `grep_search` and `run_command`, but the installed binary contains many more valid names — `find_by_name`, `write_to_file`, `list_dir`, `read_file`, `search_in_file`, `multi_replace_file_content`, the `browser_*` family, and others. Before treating a name as invalid, grep `resources/bin/language_server.exe` for `allowed_tools:`; that set is authoritative. Treating "not in the docs" as "invalid" once caused a valid tool to be removed from six agents.
- **An invalid tool name kills the executor; it does not hang it.** Observed on Antigravity IDE 2.28.2: declaring `call_mcp_tool`, `list_resources` and `read_resource` produced `failed to construct executor: failed to resolve components: unknown component: tool "list_resources" not found in registry`, and the agent never started. Google documents a hang, so treat that as one possible symptom rather than the only one. The error names every unknown component in a single pass, so pruning a candidate list costs one round trip: read `~/.gemini/antigravity/log/cli-*.log` for `not found in registry`.
- **`tools:` replaces the default baseline; it does not extend it.** A custom agent with no `tools:` block receives exactly six tools — `send_message`, `view_file`, `read_url_content`, `search_web`, `schedule`, `generate_image` — and no `invoke_subagent`. Declaring a list both grants and withholds capabilities.
- **`executor_metadata` is the ground truth for what an agent received.** Every conversation stores the constructed component list in `~/.gemini/antigravity/conversations/<cascade>.db` (table `executor_metadata`). Prefer it over asking the model to enumerate its own tools: a self-report mixes the runtime tool namespace with the registry, and the two are not the same list.
- **`trigger: model_decision` requires `description`.** Antigravity injects only the rule's path and `description` into the prompt index for `model_decision` rules and reads the full file on demand. A rule without a description has nothing to index, so it never activates. `trigger: glob` likewise requires `globs`.
- **`trigger` spelling is exact.** Values are `always_on`, `model_decision`, `glob`, `manual`. Camel-case variants such as `alwaysOn` are discarded silently.
- **Agents and rules are snapshotted when a chat session opens.** A custom agent or rule file created mid-session is not picked up by that session; invoking it returns `not found or not allowed to be invoked`. Close and reopen the session before testing newly added files.

## Hooks

- Workspace hooks: .agents/hooks.json.
- Global hooks: ~/.gemini/config/hooks.json.
- In Antigravity 2.0, active hooks can be viewed/toggled in Settings > Customizations > Hooks.
- Hook events documented by Google include SessionStart, PreToolUse, PostToolUse, PreInvocation, PostInvocation, and Stop.
- PostToolUse fires after a tool completes and includes toolCall.name, toolCall.args, stepIdx, optional error, and common session metadata.
- toolCall.args and error text may contain sensitive data. Observers should allowlist only required metadata (for example toolCall.name and stepIdx), reduce errors to a boolean, and must not log/store raw payloads or arguments.
- PreToolUse is a gating hook: its decision can allow/auto-approve, deny, or ask before a tool runs. Do not use it for a passive observer unless changing the permission flow is explicitly intended and approved.
- PostToolUse is a completion event, not a tool-start event. Do not animate a tool as currently running based on PostToolUse alone.
- For passive observation, prefer non-gating lifecycle events such as SessionStart, PreInvocation, PostToolUse, PostInvocation, and Stop. Test the exact output contract against the current official docs before enabling.
- Stop handlers must not keep an agent running unintentionally. Do not emit a continue decision unless the desired behavior and its effects are explicitly understood and approved.
- APES does not install hooks automatically. Back up and merge existing JSON; never replace a user's complete hook configuration.

## MCP

- Workspace MCP: .agents/mcp_config.json.
- Global MCP: ~/.gemini/config/mcp_config.json.
- MCP configuration is provider-specific and may require OAuth/API keys. Review server source, permissions, authentication, environment variables, and data access before enabling.
- Never commit credentials or tokens.

## Impeccable integration

- Install using scripts/Install-Impeccable.ps1; validate with scripts/Test-Impeccable.ps1.
- Upstream version is an independent optional skill; default APES pin is skill-v4.8.0.
- This integration copies skill files only. It does not configure a native Antigravity lifecycle hook or create an Impeccable subagent.
- The skill itself documents use of impeccable.cmd on Windows when no POSIX shell is available.

## Discovery and verification

- In Antigravity 2.0 Desktop App, verify workspace/global Custom Agents through the App's agent customization surface and a real delegated task.
- In Antigravity IDE, inspect Agent side panel > ... > Customizations/Agents.
- Start/reload the exact surface being tested.
- CLI-only commands are not prerequisites for Desktop App/IDE.
- Do not claim an agent or subagent ran unless a separate runtime invocation/result is observed.

## Official references

- https://antigravity.google/docs/rules/
- https://antigravity.google/docs/skills
- https://antigravity.google/docs/subagents
- https://antigravity.google/docs/hooks
- https://antigravity.google/blog/introducing-custom-agents
- https://antigravity.google/blog/introducing-google-antigravity-2
- https://antigravity.google/docs/customization-discovery
- https://github.com/pbakaus/impeccable/blob/skill-v4.8.0/README.md
