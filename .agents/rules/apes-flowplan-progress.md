---
trigger: model_decision
description: "Use when FlowPlan is connected or when a user requests visual task planning and progress tracking."
---

# APES FlowPlan Progress Rule

- FlowPlan is optional; use it only when connected and useful or explicitly requested.
- Confirm MCP availability with an actual read tool call; a config file is not connection proof.
- Read existing plans before creating a new one; do not duplicate or clear a board by default.
- Use [TODO], [DOING], [PASS], [BLOCKED] and [REVIEW] title prefixes because the current MCP card schema has no dedicated status field.
- Set [DOING] and verify readback before implementation; after verification, write [PASS] plus test evidence and read back again.
- Only [PASS] cards with evidence satisfy dependencies.
- Discover actual project test commands; record exact commands, exit codes, results and NOT_RUN checks.
- Distinguish a real native subagent review from a self-review.
- Poll and process FlowPlan feedback; never acknowledge unresolved directives/issues.
- Never use remove_card or clear_plan without explicit user authorization.
- If MCP update/readback fails, report board sync failure; do not claim the board is current.
