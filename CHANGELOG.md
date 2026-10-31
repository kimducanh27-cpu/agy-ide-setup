# Changelog

## 3.1.0 — 2026-10-31
- Add opt-in Windows Antigravity Hooks runtime capture for session, model invocation, tool lifecycle and stop events.
- Add privacy-conscious JSONL telemetry that omits prompts, tool arguments, transcripts and error text.
- Add backup-preserving global Hooks installer, safe removal script and collector smoke test.
- Document runtime capture limits: event capture is not a live dashboard and subagent identity is not inferred without evidence.

## 3.0.0 — 2026-10-31
- Add a workflow catalog for Quick Fix, Standard Feature, Full Project, Deep Research and Hard Review.
- Add a PowerShell Prompt Builder that assembles Vietnamese prompts from workflow, project, goal and execution mode.
- Add an explicit JSON run-state ledger with ordered stage transitions, evidence checkpoints, blocking/resume and approval confirmation.
- Add native workspace/global workflow-engine skill and rules while preserving the existing nine native agents, Impeccable and optional FlowPlan integrations.
- Document runtime limits: prompt assembly is not execution, state updates are explicit, and no automatic terminal/subagent telemetry is claimed.

## 2.3.0 — 2026-10-31
- Add optional FlowPlan Windows operations bridge for Antigravity Desktop over local Streamable HTTP MCP.
- Add safe Windows MCP config merge helper with loopback-only validation, health preflight, conflict protection and backup.
- Add FlowPlan config/health validator; extend APES validation to require integration assets and parse the new scripts.
- Add APES FlowPlan operations skill, progress rule, Windows integration guide and Vietnamese prompt pack for planning, approval, card-by-card execution, QA, readback, recovery and final audit.
- Formalize card status prefixes because the current FlowPlan MCP schema does not expose a dedicated status field; require evidence-backed PASS and verified readback after each card.

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
