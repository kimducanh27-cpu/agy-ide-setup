---
trigger: model_decision
description: "Use when FlowPlan is connected or when a user requests visual task planning and progress tracking."
---

# APES FlowPlan Progress Rule

- FlowPlan is optional; use it only when connected and useful or explicitly requested.
- Project Brief, Master Plan and task-graph.json are canonical project planning artifacts. FlowPlan is a simplified human-friendly projection, never the only plan store.
- Use apes-project-manager to create and audit the canonical plan before publishing a board.
- Use apes-flowplan-projection to map meaningful deliverables into concise Vietnamese cards. Do not create one card per file edit or terminal command.
- Confirm MCP availability with an actual read tool call; a config file is not connection proof.
- Read existing plans before creating a new one; do not duplicate or clear a board by default.
- Publish draft cards as [REVIEW] while approval is pending. After explicit approval of the exact plan revision, transition eligible cards to [TODO].
- Use [TODO], [DOING], [PASS], [BLOCKED] and [REVIEW] title prefixes because the current MCP schema has no dedicated status field.
- [DOING] requires actual execution evidence; owner assignment alone is not execution. Native invocation requires a real worker session.
- [PASS] requires acceptance criteria verified against actual workspace/Git/runtime/test evidence. A FlowPlan write is not proof; read back after every update.
- Only [PASS] cards with evidence satisfy dependencies.
- FlowPlan does not automatically observe terminal calls, source changes or native subagent lifecycle. Never claim live synchronization.
- Discover actual project test commands; record exact commands, exit codes, results and NOT_RUN checks.
- Distinguish a real native subagent review from a self-review.
- Poll and process FlowPlan feedback; update canonical plans and request approval for material scope/architecture/security changes. Never acknowledge unresolved directives/issues.
- Never use remove_card or clear_plan without explicit user authorization.
- If MCP update/readback fails, report board sync failure and continue to preserve the canonical plan; do not claim the board is current.
