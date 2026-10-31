# APES Repository Instructions

- This repository is APES 3.0 for standalone Antigravity IDE on Windows 11.
- Prefer native Antigravity Rules, Skills and Custom Agents.
- Keep exactly one APES primary agent (apes-orchestrator) and eight worker subagents.
- Never claim a subagent ran unless the runtime launched it and returned a result.
- Keep reviewers/evaluator read-only; evaluate evidence, not hidden reasoning.
- Validators must return non-zero on deterministic failures; never print fake PASS.
- Installer must be non-destructive, PowerShell 5.1 compatible and back up APES-owned collisions.
- CI must smoke-test a clean workspace installation on Windows.
- Do not vendor code/skills from GPL or third-party repositories into this MIT-licensed project. Optional upstream skills remain separately licensed and independently installed.
- Do not install arbitrary MCP servers or hooks by default; require project-specific review and opt-in.
- APES 3.0 includes a workflow catalog, PowerShell prompt builder and explicit run-state ledger; never describe them as autonomous runtime telemetry.
- Workflow stage transitions require inspected evidence; approval gates require explicit human confirmation.
- FlowPlan is an optional board. Use its operations skill only when MCP is connected or requested; verify card updates by readback and never invent a status property.
- APES may provide a loopback-only FlowPlan MCP config helper, but must not launch or install the third-party app.
- User-facing docs are Vietnamese; identifiers/code may be English.
