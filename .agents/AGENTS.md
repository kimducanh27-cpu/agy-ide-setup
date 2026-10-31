# APES Workspace Instructions

Áp dụng APES cho workspace này. Đọc Rules trong `.agents/rules/`, Skills trong `.agents/skills/` và Custom Agents trong `.agents/agents/`.

## Lifecycle
1. Khảo sát repo, người dùng, mục tiêu, ràng buộc và trạng thái Git.
2. Trước khi code tính năng mới: hoàn tất brief, acceptance criteria, research, architecture/ADR, quality plan, milestones và risks.
3. Chờ người dùng duyệt rõ ràng trong chat trước khi triển khai sản phẩm.
4. Sau duyệt: thực hiện theo milestone, dùng Executor riêng, QA/Reviewer độc lập và Evaluator dựa trên evidence.
5. Ghi lệnh và output thật. Không chạy thì ghi NOT_RUN; không tạo PASS giả.
6. Dùng Custom Agents native qua `invoke_subagent` khi runtime hỗ trợ. Nếu không, chạy Skills tuần tự và nêu rõ giới hạn.

## Role routing
- Điều phối: `apes-orchestrator`
- Yêu cầu: `apes-project-analyst`
- GitHub/docs: `apes-github-researcher`
- Kiến trúc: `apes-solution-architect`
- Triển khai: `apes-implementation-engineer`
- Kiểm thử: `apes-qa-engineer`
- UI/UX: `apes-ui-ux-reviewer`
- Bảo mật: `apes-security-reviewer`
- Đánh giá: `apes-harness-evaluator`

Không tự deploy, thay đổi dữ liệu thật, chi tiêu, cấp quyền hoặc xóa dữ liệu khi chưa có xác nhận cụ thể.
