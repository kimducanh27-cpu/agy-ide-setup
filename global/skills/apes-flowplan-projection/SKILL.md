---
name: apes-flowplan-projection
description: "Publish and reconcile a simplified, non-technical FlowPlan view from the canonical APES Project Brief, Master Plan and Task Graph. Use when the user wants a visual project board."
---

# APES FlowPlan Projection — Human-Friendly Board Workflow

## Mission

Turn the canonical APES project plan into a simple visual board that helps a non-technical user understand:
- What the project is trying to achieve.
- Which phase is underway.
- What work is planned, active, completed or blocked.
- What happens next.
- Which decisions require the user's attention.

**FlowPlan is a projection, not the master plan.** It must remain possible to rebuild the board from canonical project files.

## Inputs and source priority

Required canonical inputs:
- PROJECT_BRIEF.md
- MASTER_PLAN.md
- task-graph.json

Optional:
- APPROVALS.md
- RISKS.md
- FLOWPLAN-MAPPING.json
- verified execution evidence

Authority:
1. User-approved scope and decisions recorded in the canonical project files.
2. Actual workspace/Git/runtime/test evidence for execution status.
3. FlowPlan for visual presentation and user feedback.

FlowPlan must not silently change the approved scope, technical architecture or dependencies. Incoming feedback that changes these requires updating the canonical plan and obtaining approval where appropriate.

## Phase A — Preflight (read-only)

1. Confirm FlowPlan MCP tools are actually present in the current runtime.
2. Call list_plans.
3. Read matching plans with get_plan and get_cards.
4. Read pending feedback with get_all_feedback.
5. Confirm the board/project identity before writing.
6. If tools are missing or calls fail, report MCP_DISCONNECTED and stop board writes.

Never use remove_card or clear_plan as a connection test.

## Phase B — Validate the canonical plan

Before publishing:
- Confirm the Brief and Master Plan paths.
- Parse task-graph.json as JSON and validate it against templates/project-management/task-graph.schema.json in the APES source repository, or docs/engineering/apes/templates/project-management/task-graph.schema.json after installation, when available.
- Check unique IDs, valid references, no self-dependency and no dependency cycles.
- Check all visible tasks have a Vietnamese title, one accountable owner and a user-readable outcome.
- Confirm the Master Plan declares whether it is DRAFT, READY_FOR_REVIEW, APPROVED or BLOCKED.
- Identify which tasks are suitable for the board. Do not publish trivial subtasks or internal thought processes.
- Do not include secrets, raw prompts, private chain-of-thought, raw tool arguments, terminal dumps or sensitive user data.

If the canonical plan is incomplete or invalid, return findings to Project Manager. Do not publish a misleading board.

## Phase C — Build the human-readable projection

### Board language

Use Vietnamese, plain language and outcome-oriented titles.

Prefer:
- "Chuẩn bị dữ liệu để văn phòng hiển thị trạng thái AI"
- "Thiết kế khu vực quan sát các AI Agent"
- "Kiểm tra xem trạng thái hiển thị có đúng thực tế"

Avoid exposing internal implementation jargon in card titles. Put necessary technical details in the description under a clearly labeled "Chi tiết kỹ thuật" section.

### Card selection

- One card per meaningful deliverable or independently trackable task.
- Do not create a card for every file, shell command, prompt or tiny edit.
- Group related technical subtasks under one user-understandable card when they share one deliverable and one owner.
- Split cards at real ownership, dependency, integration or verification boundaries.
- Keep the canonical task ID in every projected card description.
- Preserve real dependencies from the Task Graph.
- Use only supported FlowPlan card types: research, planning, create, edit, test.

### Card description format

Keep the visible top section concise:

- **Mục tiêu:** what this work achieves.
- **Vì sao cần:** user/business reason.
- **Kết quả mong đợi:** concrete deliverable.
- **Phụ trách:** planned owner role/agent.
- **Điều kiện trước:** prerequisite in plain Vietnamese.
- **Cách kiểm tra:** short verification summary.
- **Trạng thái bằng chứng:** NOT_STARTED / RUNNING / VERIFIED / BLOCKED / NEEDS_REVIEW.

Add a compact "Chi tiết kỹ thuật" section only when useful:
- Canonical task ID.
- Relevant files/modules.
- Acceptance criteria.
- Verification commands (only commands discovered from project config).
- Risks and evidence references.

Do not claim an agent is running merely because an owner is assigned.

## Phase D — Publish the draft board

1. Call list_plans before creating a plan.
2. Reuse an existing plan only after confirming it is the intended project/revision.
3. If no matching plan exists, call create_plan using the supported schema.
4. Add projected cards with real types, descriptions and dependency edges.
5. Respect FlowPlan's current dependency behavior: use a genuine root/foundation task; every subsequent card in the same add operation must have valid prerequisite references if required by the connector.
6. Use $0, $1, etc. only for references to cards created in the same add_cards call, exactly as supported by the connector.
7. Store plan_id and each canonical task ID ↔ FlowPlan card ID mapping in FLOWPLAN-MAPPING.json.
8. Since user approval is pending, publish draft cards with [REVIEW] prefixes. Do not make the board look execution-ready.
9. Call get_plan and get_cards after writes.
10. Compare returned card count, titles, types and dependencies with the intended projection. Record discrepancies; do not claim success if readback fails.

Never delete or clear a user's existing plan. If a matching board exists but its identity/revision is ambiguous, stop and ask before writing.

## Phase E — Approval transition

After the user explicitly approves the exact Master Plan revision:
1. Record approval in APPROVALS.md.
2. Re-read the canonical plan and check the approved revision/hash or revision label.
3. Change draft [REVIEW] cards to [TODO] only through supported update_card calls.
4. Read back with get_cards.
5. Do not set [DOING] during approval.
6. Do not start implementation; hand off to APES Workflow Engine / FlowPlan Operations.

A board card being visible or feedback being posted is not by itself an approval unless the user clearly states approval.

## Phase F — Progress projection

Only publish state transitions supported by actual evidence.

Use existing title prefixes because the current FlowPlan MCP card schema has no dedicated status property:
- [TODO]: approved and not started.
- [DOING]: execution genuinely started; identify the active run/task in the description when available.
- [PASS]: acceptance criteria verified with actual evidence.
- [BLOCKED]: a real dependency, test, environment or scope blocker prevents safe progress.
- [REVIEW]: human decision or verification is required.

Important:
- ASSIGNED is metadata, not an execution status.
- INVOKED is true only with a real native worker session and returned result.
- FlowPlan does not automatically observe terminal commands, source changes or native subagent lifecycle.
- Do not claim real-time synchronization. Publish updates at explicit checkpoints: task start, verified completion, blocker, milestone boundary, user request and recovery.
- Do not mark [PASS] because code was merely written.
- A successful MCP write is not proof the card persisted; always read back.

## Phase G — Feedback and reconciliation

Before starting the next card and at milestone boundaries:
1. Read get_all_feedback.
2. Classify each item as question, in-scope directive, issue, or scope/architecture/security/production-impact change.
3. Answer questions using the supported feedback tool.
4. Handle in-scope directives only within approved scope.
5. Investigate issues before acknowledging them.
6. For scope or risk changes, update the canonical plan and obtain approval before changing execution.
7. Do not acknowledge unresolved feedback merely to clear the inbox.

When board and canonical files disagree:
- Canonical plan wins for scope, architecture, milestone/task definitions and dependencies.
- Actual evidence wins for execution status.
- FlowPlan is updated to match those sources after the discrepancy is understood.
- Preserve user feedback; do not silently discard it.

## Phase H — Recovery

After a new chat, app restart or MCP reconnect:
1. Call list_plans.
2. Find the matching project plan using FLOWPLAN-MAPPING.json.
3. Read get_plan, get_cards and get_all_feedback.
4. Compare board state with canonical plan, Git diff, run state and test evidence.
5. Do not assume an old [DOING] means a worker is still running.
6. Reconcile unverifiable [PASS] to [REVIEW] or [BLOCKED] after investigating.
7. Rebuild missing board cards from canonical task IDs only after checking for duplicates.
8. Never remove/clear cards without explicit user authorization.

## Final report

Report in Vietnamese:
- Board connection state.
- Canonical plan revision/path.
- FlowPlan plan ID.
- Number of cards intended, written and read back.
- Mapping file path.
- Any discrepancies.
- User decisions still required.
- Explicitly state that FlowPlan is a visual projection and is not live runtime telemetry.
