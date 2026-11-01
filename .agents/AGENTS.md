# APES Workspace Instructions

Áp dụng APES cho workspace này. Đọc Rules trong .agents/rules/, Skills trong .agents/skills/ và Custom Agents trong .agents/agents/.

## Lifecycle
1. Khảo sát repo, người dùng, mục tiêu, ràng buộc và trạng thái Git.
2. Trước khi code tính năng mới: hoàn tất brief, acceptance criteria, research, architecture/ADR, quality plan, milestones và risks.
3. Chờ người dùng duyệt rõ ràng trong chat trước khi triển khai sản phẩm.
4. Sau approval: thực hiện theo milestone, dùng Executor riêng, QA/Reviewer độc lập và Evaluator dựa trên evidence.
5. Ghi lệnh và output thật. Không chạy thì ghi NOT_RUN; không tạo PASS giả.
6. Dùng Custom Agents native qua invoke_subagent khi runtime hỗ trợ. Nếu không, chạy Skills tuần tự và nêu rõ giới hạn.

## Role routing
- Điều phối: apes-orchestrator
- Yêu cầu: apes-project-analyst
- GitHub/docs: apes-github-researcher
- Kiến trúc: apes-solution-architect
- Triển khai: apes-implementation-engineer
- Kiểm thử: apes-qa-engineer
- UI/UX độc lập: apes-ui-ux-reviewer
- Bảo mật: apes-security-reviewer
- Đánh giá: apes-harness-evaluator

## Project planning and canonical plan

For new projects, substantial features or multi-step goals, read .agents/skills/apes-project-manager/SKILL.md. Create the canonical Project Brief, Master Plan and task-graph.json under docs/engineering/apes/projects/<slug>/. Keep project scope, architecture, milestones and dependencies in these files; keep actual execution status grounded in workspace/Git/runtime/test evidence. Select only an existing workflow from config/workflows.json or docs/engineering/apes/config/workflows.json after APES installation.

## Optional FlowPlan task board

FlowPlan is a human-friendly visual projection for the user, not the canonical plan. After the Project Manager has created and audited the canonical plan, read .agents/skills/apes-flowplan-projection/SKILL.md to publish/reconcile the board. Use .agents/skills/apes-flowplan-operations/SKILL.md for MCP operations and card-by-card execution. Use list_plans before creating a board, publish draft cards as [REVIEW], and require explicit user approval before implementation. After approval use [TODO]. Because the current MCP schema has no status field, use [TODO]/[DOING]/[PASS]/[BLOCKED]/[REVIEW] title prefixes. Attach actual evidence and verify updates with get_cards. Do not claim FlowPlan observes terminal calls or native subagent lifecycle automatically. Never clear/delete cards without explicit approval. Setup is opt-in; see docs/FLOWPLAN-WINDOWS-INTEGRATION.md.

## Optional UI/UX tooling
For frontend, web, mobile-screen or design-system work, check whether Impeccable is installed at workspace .agent/skills/impeccable/SKILL.md or global ~/.gemini/config/skills/impeccable/SKILL.md. If present, the primary agent should load and follow that upstream skill for design work. APES's .agents/skills/apes-ui-ux-review and apes-ui-ux-reviewer remain the independent review layer. If Impeccable is absent, use APES's existing UI/UX workflow; do not claim Impeccable commands or hooks ran. Do not auto-install it during a task.

Không tự deploy, thay đổi dữ liệu thật, chi tiêu, cấp quyền hoặc xóa dữ liệu khi chưa có xác nhận cụ thể.

## APES 3.0 Workflow Engine

For multi-step work, select a workflow from config/workflows.json and read .agents/skills/apes-workflow-engine/SKILL.md. Use Build-APESPrompt.ps1 for prompt assembly and Manage-APESRun.ps1 for explicit state checkpoints. Advance only after inspected evidence; require explicit human approval at APPROVAL. The ledger is not automatic telemetry. Preserve FlowPlan and Impeccable as optional independent integrations.
