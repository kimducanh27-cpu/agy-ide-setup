# APES Repository Instructions

- This repository is APES 2.0, an Antigravity-native configuration and bootstrap toolkit.
- Preserve the Vietnamese-first user experience and Windows Desktop IDE as the primary install target.
- Prefer official Antigravity filesystem conventions over custom/non-native configuration formats.
- Rules in `.agents/rules/` must have valid YAML frontmatter (`trigger` is one of `always_on`, `model_decision`, `glob`, `manual`).
- Skills in `.agents/skills/<skill>/SKILL.md` must have `name` and `description` frontmatter.
- Keep role skills focused. A role skill is a perspective and workflow, not proof of a separate agent process.
- Never claim subagents are available unless the running Antigravity surface exposes them.
- Do not add placeholder tests or print fake PASS messages. Validators must perform deterministic checks and return non-zero on failure.
- Keep scripts idempotent, Windows PowerShell 5.1 compatible, non-destructive, and free of external runtime dependencies.
- Before changing installer behavior, test a clean install, a repeated install, a conflicting APES-managed file, and an existing non-APES customization.
- Do not vendor or copy code/skills from GPL repositories into this MIT project. Link and attribute upstream references in NOTICE.md.
- All user-facing documentation should be in Vietnamese; identifiers and code may be English.
