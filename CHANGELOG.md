# Changelog

## 2.2.0 — 2026-10-31
- Add optional Impeccable bridge for UI/frontend workflows without vendoring the upstream project.
- Add a Windows installer that copies the Antigravity skill from a pinned upstream tag into the correct singular .agent/ workspace path or global Gemini skills directory; backup same-name Impeccable installs before replacement.
- Add Impeccable installation validator and PowerShell syntax checks to APES validation.
- Route UI/UX tasks to Impeccable when installed; preserve APES UI/UX reviewer as an independent read-only reviewer.
- Document the absence of an Antigravity lifecycle-hook setup in this integration; do not claim automatic post-edit scanning.

## 2.1.0 — 2026-10-31
- Add nine native Antigravity Custom Agents: one selectable Orchestrator and eight specialist subagents.
- Add global and workspace AGENTS.md instructions and agent routing.
- Extend Windows installer to install/backup global and workspace Custom Agents.
- Extend validator to verify agent metadata, tool allowlists, install paths and the single primary Orchestrator.
- Add Windows CI smoke test that installs APES into a temporary workspace and validates the result.
- Document why MCP servers and lifecycle hooks remain opt-in.

## 2.0.0 — 2026-10-31
- Add Project Bootstrap and role-based Engineering Harness.
- Add Windows PowerShell installer and deterministic validator.
- Add 17 specialist role skills, evidence-based scorecard, milestones and approval templates.
- Use native Rules/Skills paths; do not vendor upstream GPL role skills.
