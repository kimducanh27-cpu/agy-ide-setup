---
name: apes-workflow-engine
description: Select and operate APES workflows, build context-aware prompts, and maintain evidence-backed run state.
---

# APES Workflow Engine

## When to use
Use this skill for multi-step work, new features, project bootstrap, deep research, or hard review. For a trivial question, do not create a run.

## Workflow selection
- quick-fix: small, localized bug.
- standard-feature: ordinary feature with approval, implementation, QA and review.
- full-project: new project bootstrap and milestone delivery.
- deep-research: sourced investigation and cross-check.
- hard-review: read-only critical review; do not edit files.

Read `config/workflows.json` (installed at `docs/engineering/apes/config/workflows.json`) and `docs/PROMPT-WORKFLOW-ENGINE-V3.md` (installed at `docs/engineering/apes/PROMPT-WORKFLOW-ENGINE-V3.md`) before operating the engine.

## Operation
1. Inspect git status and workspace instructions. Never overwrite user changes.
2. Select workflow and explain why; ask one clarifying question only if a missing detail blocks selection.
3. On Windows PowerShell, use `scripts/Build-APESPrompt.ps1` to assemble the prompt. The script does not execute it; pass the result into Antigravity Agent Chat.
4. Initialize explicit run state with `scripts/Manage-APESRun.ps1 -Action Initialize`. Keep the returned RUN_ID.
5. Follow stages in order. Record each completed stage with `-Action Advance -Stage <current> -Evidence <verifiable evidence>`.
6. At APPROVAL, only use `-ApprovalConfirmed` after the user explicitly approves. Never self-approve.
7. On blocker, use Block; resume only after the blocker is genuinely resolved and explain it in Resume -Reason.
8. Complete only after all catalog stages are advanced and final audit evidence exists.

## Tool integrations
- Native subagents: only report delegation when Antigravity actually launches a subagent and returns its result. Otherwise perform sequential specialist passes.
- FlowPlan: optional; use only when MCP tools are connected. Read back card updates.
- Impeccable: optional UI design skill; retain APES independent UI/UX review.

## State integrity
The state script records explicit checkpoints. It cannot observe terminal activity, infer completion, validate evidence truth, or sync FlowPlan automatically. A non-empty evidence string is not proof by itself; inspect the referenced artifact/output before advancing.
