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

## Optional FlowPlan task board

When FlowPlan MCP is available or explicitly requested for a multi-step task, read .agents/skills/apes-flowplan-operations/SKILL.md. Use list_plans before creating a board, require user approval before implementation, and update one card at a time by default. Because the current MCP schema has no status field, use [TODO]/[DOING]/[PASS]/[BLOCKED]/[REVIEW] title prefixes. Attach actual tests/diff evidence and verify updates with get_cards. Do not claim FlowPlan observes terminal calls or native subagent lifecycle automatically. Never clear/delete cards without explicit approval. Setup is opt-in; see docs/FLOWPLAN-WINDOWS-INTEGRATION.md.

## Optional UI/UX tooling
For frontend, web, mobile-screen or design-system work, check whether Impeccable is installed at workspace .agent/skills/impeccable/SKILL.md or global ~/.gemini/config/skills/impeccable/SKILL.md. If present, the primary agent should load and follow that upstream skill for design work. APES's .agents/skills/apes-ui-ux-review and apes-ui-ux-reviewer remain the independent review layer. If Impeccable is absent, use APES's existing UI/UX workflow; do not claim Impeccable commands or hooks ran. Do not auto-install it during a task.

Không tự deploy, thay đổi dữ liệu thật, chi tiêu, cấp quyền hoặc xóa dữ liệu khi chưa có xác nhận cụ thể.
