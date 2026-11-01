# APES 2.2 — Native Custom Agents

Last reviewed: 2026-10-31.

APES includes actual Antigravity Custom Agent Markdown files, not only role Skills.

## Native locations

- Workspace: .agents/agents/<name>.md (or .agents/agents/<name>/agent.md).
- Global (Antigravity 2.0 App / IDE): ~/.gemini/config/agents/<name>.md or ~/.gemini/config/agents/<name>/agent.md.

Antigravity 2.0 Desktop App supports workspace and global Custom Agents through Markdown definitions with YAML frontmatter. Installer copies workspace agent definitions to both scopes. Existing APES-named collisions are backed up; unrelated agents remain untouched.

## Composition

- apes-orchestrator: the only APES agent with mainAgent: true.
- Eight specialist workers: mainAgent: false, subagent: true.
- Role Skills remain the reusable knowledge/workflow layer.
- Optional Impeccable remains an upstream skill, not an APES agent or subagent.

## Frontmatter

APES uses documented fields: name, description, mainAgent, subagent, model, commandExecutionPolicy, and tools where an explicit allowlist is appropriate.

Every agent declares an explicit `tools:` block. Omitting it is never neutral: a custom agent without `tools:` receives a fixed six-tool baseline (`send_message`, `view_file`, `read_url_content`, `search_web`, `schedule`, `generate_image`) that contains no write tool, no `run_command` and no `invoke_subagent`. An earlier revision left `apes-implementation-engineer` and `apes-github-researcher` without `tools:` — the agent whose job is to write code could not write a file, and the researcher could not search the local codebase.

| Agent | Tools |
|---|---|
| `apes-orchestrator` | 17, including `invoke_subagent` |
| `apes-implementation-engineer` | read set + `write_file`, `edit_file`, `run_command` |
| `apes-github-researcher` | read set + `search_web`, `read_url_content` |
| `apes-qa-engineer` | read set + `run_command` |
| `apes-ui-ux-reviewer` | read set + `read_url_content` |
| `apes-project-analyst`, `apes-solution-architect`, `apes-security-reviewer`, `apes-harness-evaluator` | read set |

Read set = `view_file`, `read_file`, `grep_search`, `find_by_name`. Reviewers and the evaluator stay read-only on purpose: a reviewer that can write is not an independent reviewer.

The Orchestrator also cannot omit `tools:` and inherit delegation: a custom agent with no `tools:` block excludes `invoke_subagent`, so the Orchestrator silently loses the ability to delegate. `tools:` replaces the baseline rather than extending it — declaring a list both grants and withholds capabilities.

## Verify in Antigravity 2.0 Desktop App / IDE

1. Open the exact target surface and project workspace.
2. Confirm nine APES agent definitions exist under .agents/agents/ and frontmatter parses.
3. In Antigravity 2.0 Desktop App, verify workspace/global agents using the App's agent customization surface; in Antigravity IDE, inspect Agent side panel → ... → Customizations/Agents.
4. Select apes-orchestrator if desired.
5. Ask it to delegate one read-only task to apes-project-analyst; confirm a distinct native subagent execution and result.
6. If the target surface does not expose/discover the agents, report that limitation; do not simulate a subagent.

CLI-only /agents is not required for the Desktop App or Desktop IDE.

## Optional design workflow

For UI/frontend work, APES can route the primary agent to the separately installed Impeccable skill. The APES UI/UX reviewer remains independent and read-only. The integration does not add an automatic Antigravity hook.

## MCP and Hooks

APES does not silently install MCP servers or hooks. MCP may require OAuth/API credentials; hooks execute shell commands and must be merged/tested, never blindly overwritten. See docs/OPTIONAL-INTEGRATIONS.md.
