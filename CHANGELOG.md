# Changelog

## Unreleased — CI supply chain
- Pin `actions/checkout` to commit `11d5960` (v4.4.0) in both workflows instead of the moving `@v4` tag. A tag can be repointed; a commit cannot.
- Note: `actions/checkout` is at v7. Moving off v4 is a separate change with its own behaviour differences and is not bundled here.

## Unreleased — Restore from backup
- Add `scripts/Restore-APES.ps1`, which reads the `backup-manifest.json` written by the installer and restores overwritten files. It previews by default and only writes with `-Force`.
- Preflight checks every backup file before touching anything: one missing file aborts the whole run with no changes.
- Before overwriting, the current state is copied to `restore-safety-<timestamp>` with its own manifest, so a restore can itself be undone by pointing the same script at that directory.
- Support `-Only` to restore a subset, and `-BackupPath` to target a specific backup set instead of the newest one.
- Abort paths use `exit 1` rather than `throw`, because a throw leaves `$LASTEXITCODE` untouched and an automated caller would read the failure as success.
- Add restore coverage to CI: a second install must produce a manifest, dry-run must succeed, and a missing backup file must abort without writing.

## Unreleased — Validator hardening
- Compare the installed workspace version against the repository `VERSION` using `.agents/apes-install.json`, so a stale install fails with a reinstall instruction instead of drifting silently.
- Validate rule metadata for installed global rules when `-CheckGlobal` is used; previously only workspace rules were checked.
- Add a global/workspace sync check that requires byte-identical copies except for the five files whose global variants intentionally point back at the workspace.
- Compare FlowPlan MCP endpoints by parsed scheme, host, port and path, so `localhost` and `127.0.0.1` are no longer reported as conflicting entries.
- Write `backup-manifest.json` beside each backup set, mapping the original path to the flattened backup file; stop printing a backup location when nothing was overwritten.
- Document that the 17 `role-*` skills install to the workspace only, and run engine CI when `templates/prompts/**` changes.

## Unreleased — Documentation reference integrity and real pre-code gate
- Fix nine copy-paste-broken commands in `docs/PROMPT-WORKFLOW-ENGINE-V3.md` and `templates/prompts/APES-3.0-EXAMPLE-VI.md` where `.\scripts\` had lost its backslash and rendered as `.scripts`.
- Install every top-level `docs/*.md` into the workspace instead of a hardcoded pair, so `PROMPT-WORKFLOW-ENGINE-V3.md` is present where the Orchestrator and workflow-engine skill tell the agent to read it.
- Point `apes-harness-evaluator` at the schema that actually ships (`docs/engineering/apes/scorecard.schema.json`) instead of the non-existent `templates/evaluation-scorecard.schema.json`.
- Add the missing `bootstrap/` segment to the `apes-project-bootstrap` document paths.
- Add a documentation reference-integrity check to the validator: broken command paths, doubled backslashes and unresolvable file references now fail CI, and post-install checks verify that every `docs/<name>.md` referenced by an installed agent or skill exists in the workspace.
- Make `-Stage PreCode` verify document content, not file existence. The installer ships empty bootstrap templates to the exact paths the gate inspected, so the gate previously passed on a fresh install with no plan written.
- Extend the Windows CI smoke test to assert both directions of the pre-code gate: empty templates are rejected, a filled brief is accepted.
- Replace `\s*` with `[ \t]*\r?` in frontmatter and document-field patterns. `\s` also matches CRLF, which let a pattern capture the following line and accept malformed metadata.
- Print the real version in the installer banner instead of the stale `APES 2.1` string; add `.apes/` to `.gitignore`.
- Clarify in README that all nine agents declare `subagent: true` and only the Orchestrator declares `mainAgent: true`.

## Unreleased — Project Manager + FlowPlan Projection
- Add Project Manager planning skill to create canonical Project Brief, Master Plan and machine-readable Task Graph in the workspace.
- Add human-friendly FlowPlan Projection skill; keep FlowPlan as a visual board rather than the canonical project plan or live runtime telemetry.
- Add Project Brief, Master Plan, task graph schema/example, FlowPlan mapping, decisions, risks and approval templates.
- Add Vietnamese Project Manager prompt pack and update FlowPlan prompt pack to draft [REVIEW] cards, require revision-bound human approval and publish [TODO] only after approval.
- Separate planning intelligence, board projection and FlowPlan MCP operations into focused Skills.
- Extend APES installer and deterministic validator for the new skills, docs, templates and installed workspace references.
- Preserve the five existing APES workflows; FlowPlan projection is an auxiliary publishing/reconciliation process, not a sixth project workflow.

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
