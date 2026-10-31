# Antigravity compatibility notes

Last reviewed: 2026-10-31

APES targets the standalone Antigravity IDE on Windows 11.

## Native Rules paths

- Workspace: `<workspace>/.agents/rules/*.md`, plus `AGENTS.md`, `GEMINI.md`, `.agents/AGENTS.md`, `.agents/GEMINI.md`.
- Global: `~/.gemini/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/.gemini/config/AGENTS.md`, `~/.gemini/config/GEMINI.md`, and `~/.gemini/config/rules/*.md`.
- Every file placed under a `rules/` directory must start with frontmatter declaring a valid `trigger`.
- Supported trigger values documented by Google: `always_on`, `model_decision`, `glob`, `manual`.
- Rule scanning is shallow; put rule `.md` files directly inside `rules/`, not in nested subdirectories.

## Native Skills paths

- Workspace: `<workspace>/.agents/skills/<skill-folder>/SKILL.md`.
- Global IDE: `~/.gemini/config/skills/<skill-folder>/SKILL.md`.
- Each skill must be a directory and contain `SKILL.md` with YAML frontmatter. `description` is required; APES also supplies `name`.

## Discovery / reload

Inspect Antigravity's Customizations panel (agent side panel → `...` → Customizations). Restart or start a new conversation if the IDE does not immediately discover newly written customizations. Do not assume CLI slash-command behavior applies to the standalone IDE.

## Scope boundaries

Antigravity Rules and Skills are file-based customizations. They do not guarantee that every skill is invoked, that 17 distinct processes are running, or that arbitrary native subagent APIs exist in every version. APES uses skills as specialist role playbooks and requires the parent agent to be honest about whether it delegated to actual subagents.

References:

- https://antigravity.google/docs/rules/
- https://antigravity.google/docs/skills
- https://antigravity.google/docs/customization-discovery
