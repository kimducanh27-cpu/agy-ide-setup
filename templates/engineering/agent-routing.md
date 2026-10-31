# APES Custom Agent Routing

APES 2.2 cung cấp 1 Orchestrator có thể chọn làm agent chính và 8 worker chuyên biệt. Impeccable là UI/UX skill upstream tùy chọn, không phải Custom Agent.

| Agent / Skill | Khi giao việc | Quyền |
|---|---|---|
| apes-project-analyst | Yêu cầu, user stories, scope | Đọc |
| apes-github-researcher | GitHub, docs, dependency, compatibility | Nghiên cứu |
| apes-solution-architect | Architecture, APIs, data flows, ADR | Đọc/thiết kế |
| apes-implementation-engineer | Code milestone đã duyệt | Thực thi |
| apes-qa-engineer | Test plan, run tests, regression | Đọc + chạy lệnh |
| apes-ui-ux-reviewer | Review UI/UX độc lập | Đọc |
| Impeccable (nếu cài) | Primary-agent design workflow, critique, audit, polish | Theo quyền runtime/skill |
| apes-security-reviewer | Security/privacy độc lập | Đọc |
| apes-harness-evaluator | Verdict theo evidence | Đọc |
| apes-orchestrator | Điều phối lifecycle | Điều phối |

## Quy trình
1. Orchestrator giao task độc lập cho analyst/researcher/architect; chạy song song khi không phụ thuộc đầu ra.
2. Với frontend/UI, primary agent kiểm tra Impeccable ở .agent/skills/impeccable/; nếu có thì đọc skill và dùng lệnh phù hợp. Nếu không có, tiếp tục APES UI/UX workflow.
3. Tổng hợp bootstrap docs và chờ người dùng duyệt.
4. Sau duyệt, giao từng milestone cho implementation engineer.
5. QA chạy test thật; UI/UX và security review độc lập khi phù hợp.
6. Evaluator nhận diff + logs + acceptance criteria và trả PASS/REJECT/NEEDS_HUMAN_REVIEW.
7. Nếu native subagent không khả dụng, dùng Skills tuần tự và công bố giới hạn.

Reviewer không được sửa file đang review. Evaluator không được tự sửa hoặc tự approve. Người dùng giữ quyền duyệt phạm vi, release, deploy, chi tiêu và thay đổi dữ liệu thật.
