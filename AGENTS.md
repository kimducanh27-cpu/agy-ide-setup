# APES Repository Instructions

- This repository is APES 2.2 for standalone Antigravity IDE on Windows 11.
- Prefer native Antigravity Rules, Skills and Custom Agents.
- Keep exactly one APES primary agent (apes-orchestrator) and eight worker subagents.
- Never claim a subagent ran unless the runtime launched it and returned a result.
- Keep reviewers/evaluator read-only; evaluate evidence, not hidden reasoning.
- Validators must return non-zero on deterministic failures; never print fake PASS.
- Installer must be non-destructive, PowerShell 5.1 compatible and back up APES-owned collisions.
- CI must smoke-test a clean workspace installation on Windows.
- Do not vendor code/skills from GPL or third-party repositories into this MIT-licensed project. Optional upstream skills remain separately licensed and independently installed.
- Do not install arbitrary MCP servers or hooks by default; require project-specific review and opt-in.
- User-facing docs are Vietnamese; identifiers/code may be English.
