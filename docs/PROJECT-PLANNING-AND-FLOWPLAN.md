# APES Project Planning and FlowPlan Projection

## Purpose

APES maintains a canonical project plan independently of FlowPlan. FlowPlan exists to give the user, especially a non-technical user, a simple visual view of the work.

## Architecture

1. Project Brief: what the user wants and why.
2. Master Plan: approved project scope, architecture, milestones, deliverables, ownership, dependencies, quality strategy and approval state.
3. Task Graph: machine-readable tasks and dependency edges.
4. Execution Evidence: actual workspace changes, Git diff, runtime results, tests and reviews.
5. FlowPlan: human-friendly board projection and feedback surface.

FlowPlan is not the only plan store and is not a runtime telemetry system.

## Canonical project folder

Create plans under:

docs/engineering/apes/projects/<project-slug>/

Recommended files:
- PROJECT_BRIEF.md
- MASTER_PLAN.md
- task-graph.json
- DECISIONS.md when material design decisions exist
- RISKS.md when meaningful risks exist
- APPROVALS.md
- FLOWPLAN-MAPPING.json when a FlowPlan board is published
- evidence/ for relevant, non-sensitive verification artifacts

Templates live under templates/project-management/.

## Planning and publishing lifecycle

1. Select an existing APES workflow from config/workflows.json.
2. Inspect the workspace and existing Git changes.
3. Create/update the Project Brief.
4. Create/update the Master Plan and Task Graph.
5. Audit task completeness, granularity, owners, dependencies, critical path, acceptance criteria and verification.
6. If FlowPlan is connected/requested, publish a draft board with [REVIEW] prefixes.
7. Verify the board through get_plan/get_cards readback.
8. Obtain explicit user approval for the exact plan revision.
9. Record approval in APPROVALS.md; transition cards to [TODO] through MCP and read back.
10. Execute only within the approved scope using APES Workflow Engine and FlowPlan Operations.

A board can be used to review a draft; a draft board never authorizes implementation.

## Status and truth model

| FlowPlan prefix | Meaning |
|---|---|
| [REVIEW] | Draft waiting for user decision or a verification decision |
| [TODO] | Approved, not started |
| [DOING] | Execution actually started |
| [PASS] | Acceptance criteria verified with evidence |
| [BLOCKED] | A real dependency, environment, test or scope blocker |

Owner assignment does not mean a worker has started. Native invocation requires a real worker session. FlowPlan does not automatically observe terminal commands, code changes or subagent lifecycle.

Update the board only at explicit checkpoints such as task start, verified completion, blocker, milestone boundary, user request or recovery. Never claim live synchronization.

## Reconciliation

- Master Plan is authoritative for user-approved scope, architecture, milestones and dependencies.
- Actual evidence is authoritative for execution status.
- FlowPlan is a visual projection and feedback surface.
- When feedback changes scope, architecture or a risk-sensitive decision, update the canonical files and obtain approval before execution changes.
- When the board is missing or stale, reconstruct it from canonical files after checking for duplicates.
- Never clear or delete user cards without explicit authorization.

## User experience requirements

- Use Vietnamese, clear verbs and outcome-oriented titles.
- Show what the work achieves and why it matters.
- Put technical detail in a secondary section, not the card title.
- Do not publish every file edit or terminal command as a separate card.
- Keep project counts and progress tied to actual canonical tasks and verified states.
- Distinguish planned, assigned, invoked, active and verified work.
