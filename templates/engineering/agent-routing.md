# APES Custom Agent Routing

APES 2.1 cung cấp 1 Orchestrator có thể chọn làm agent chính và 8 worker chuyên biệt.

| Agent | Khi giao việc | Quyền |
|---|---|---|
| apes-project-analyst | Yêu cầu, user stories, scope | Đọc |
| apes-github-researcher | GitHub, docs, dependency, compatibility | Nghiên cứu |
| apes-solution-architect | Architecture, APIs, data flows, ADR | Đọc/thiết kế |
| apes-implementation-engineer | Code milestone đã duyệt | Thực thi |
| apes-qa-engineer | Test plan, run tests, regression | Đọc + chạy lệnh |
| apes-ui-ux-reviewer | Review UI/UX độc lập | Đọc |
| apes-security-reviewer | Security/privacy độc lập | Đọc |
| apes-harness-evaluator | Verdict theo evidence | Đọc |
| apes-orchestrator | Điều phối lifecycle | Điều phối |

## Quy trình
1. Orchestrator giao task độc lập cho analyst/researcher/architect; chạy song song khi không phụ thuộc đầu ra.
2. Tổng hợp bootstrap docs và chờ người dùng duyệt.
3. Sau duyệt, giao từng milestone cho implementation engineer.
4. QA chạy test thật; UI/UX và security review độc lập khi phù hợp.
5. Evaluator nhận diff + logs + acceptance criteria và trả PASS/REJECT/NEEDS_HUMAN_REVIEW.
6. Nếu native subagent không khả dụng, dùng Skills tuần tự và công bố giới hạn.

Reviewer không được sửa file đang review. Evaluator không được tự sửa hoặc tự approve. Người dùng giữ quyền duyệt phạm vi, release, deploy, chi tiêu và thay đổi dữ liệu thật.
