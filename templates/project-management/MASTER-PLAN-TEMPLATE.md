# Master Plan — {{PROJECT_NAME}}

> Project ID: {{PROJECT_SLUG}}  
> Revision: 0.1  
> State: DRAFT  
> Source Brief: {{BRIEF_PATH}}  
> Workflow: {{WORKFLOW_ID}}  
> Last reviewed: {{DATE}}

## 1. Executive Summary

Giải thích mục tiêu và chiến lược thực hiện bằng ngôn ngữ dễ hiểu. Nêu rõ đây là bản nháp hay kế hoạch đã được duyệt.

## 2. Source of Truth

| Artifact | Path | Purpose |
|---|---|---|
| Project Brief | {{BRIEF_PATH}} | Ý định, người dùng, phạm vi |
| Master Plan | This file | Chiến lược, milestone, approval |
| Task Graph | {{TASK_GRAPH_PATH}} | Task ID và dependency có cấu trúc |
| FlowPlan Mapping | {{FLOWPLAN_MAPPING_PATH}} | Ánh xạ card hiển thị |
| Evidence | {{EVIDENCE_PATH}} | Kết quả thực thi đã kiểm chứng |

FlowPlan là bản chiếu quan sát, không thay thế các artifact trên.

## 3. Goals and Non-goals

### Goals
- {{GOAL}}

### Non-goals
- {{NON_GOAL}}

## 4. Approved Scope

### In scope
- {{SCOPE_ITEM}}

### Out of scope
- {{OUT_OF_SCOPE_ITEM}}

## 5. Constraints and Assumptions

| ID | Type | Description | Verification / Impact |
|---|---|---|---|
| CON-01 | CONSTRAINT / ASSUMPTION | {{DESCRIPTION}} | {{IMPACT}} |

## 6. Current State and Discovery

- Workspace / repository:
- Git branch and status:
- Existing capabilities to reuse:
- Technology stack:
- Available test commands:
- Relevant documentation and sources:
- Known limitations:

## 7. Architecture and Decisions

### Proposed architecture
{{ARCHITECTURE_SUMMARY}}

### Key decisions and trade-offs
| Decision ID | Decision | Alternatives | Reason | Approval |
|---|---|---|---|---|
| ADR-01 | {{DECISION}} | {{ALTERNATIVES}} | {{RATIONALE}} | REQUIRED / APPROVED / NOT_REQUIRED |

Link detailed ADRs or diagrams where appropriate. Do not invent architecture details before research.

## 8. Milestones

| Milestone ID | Outcome | Deliverables | Entry conditions | Exit conditions | Risk |
|---|---|---|---|---|---|
| M1 | {{OUTCOME}} | {{DELIVERABLES}} | {{ENTRY}} | {{EXIT}} | LOW / MEDIUM / HIGH |

Milestones represent meaningful outcomes, not arbitrary time periods.

## 9. Task Ownership and Delivery

Reference task IDs in task-graph.json.

| Task ID | User-readable title | Milestone | Owner | Reviewer | Deliverable |
|---|---|---|---|---|---|
| T001 | {{TITLE}} | M1 | {{AGENT_ID}} | {{REVIEWER_ID}} | {{DELIVERABLE}} |

One accountable owner per task. An owner assignment does not mean the worker has been invoked or started.

## 10. Critical Path and Parallel Work

### Critical path
{{CRITICAL_PATH}}

### Independent / parallel branches
{{PARALLEL_BRANCHES}}

Explain the shared prerequisites and confirm there are no file-ownership conflicts.

## 11. Acceptance and Verification Strategy

| Criterion ID | Acceptance criterion | Verification method | Evidence location |
|---|---|---|---|
| AC-01 | {{CRITERION}} | {{METHOD}} | {{EVIDENCE_PATH}} |

Only use commands discovered from the actual project manifests/configuration. Mark unrun checks NOT_RUN.

## 12. Quality Plan

- Unit and integration tests:
- End-to-end / UI checks:
- Build, lint and type checks:
- Security and privacy review:
- Accessibility / responsive checks:
- Regression strategy:
- Independent review:

Include only relevant checks; explain justified exclusions.

## 13. Risks and Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation | Trigger |
|---|---|---|---|---|---|
| R-01 | {{RISK}} | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH | {{MITIGATION}} | {{TRIGGER}} |

## 14. Approval Gates

| Gate | What is being approved | Required approver | State |
|---|---|---|---|
| G1 | Brief, scope and success criteria | User | PENDING |
| G2 | Architecture and technical trade-offs, if material | User | PENDING / NOT_REQUIRED |
| G3 | Milestones and task graph | User | PENDING |

No implementation before the required approval gates are explicitly approved.

## 15. Execution Status

Do not infer this section from planned or published cards. Update only from actual execution evidence.

| Task ID | State | Evidence | Last verified |
|---|---|---|---|
| T001 | NOT_STARTED | NOT_RUN | {{DATE}} |

Allowed states: NOT_STARTED, RUNNING, VERIFIED, BLOCKED, NEEDS_REVIEW.

## 16. Open Questions

| ID | Question | Impact | Owner | State |
|---|---|---|---|---|
| Q-01 | {{QUESTION}} | {{IMPACT}} | User / Agent | OPEN |

## 17. Revision History

| Revision | Date | Change | Approval reference |
|---|---|---|---|
| 0.1 | {{DATE}} | Initial draft | NONE |
