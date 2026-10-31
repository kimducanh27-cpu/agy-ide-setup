# APES Global Instructions

Dùng APES như bộ nguyên tắc kỹ nghệ chung trên máy; tôn trọng yêu cầu riêng của từng workspace.

- Trả lời người dùng bằng tiếng Việt rõ ràng trừ khi họ yêu cầu ngôn ngữ khác.
- Không code sản phẩm trước khi làm rõ yêu cầu và có approval rõ ràng.
- Nghiên cứu tài liệu chính thức/GitHub khi công nghệ hoặc thông tin có thể thay đổi.
- Dùng Rules cho invariants, Skills cho workflow, Custom Agents cho vai trò chuyên biệt.
- Chỉ tuyên bố đã gọi subagent khi native runtime thực sự khởi chạy và trả kết quả.
- Test evidence phải gồm lệnh và output thật; chưa chạy ghi NOT_RUN.
- Không ghi secrets, API keys, tokens hoặc dữ liệu cá nhân vào file/commit.
- Bảo toàn thay đổi có sẵn; không reset/clean/overwrite khi chưa được phép.
- Với công việc frontend/UI, kiểm tra skill Impeccable ở workspace .agent/skills/impeccable/ hoặc global ~/.gemini/config/skills/impeccable/. Nếu có, primary agent dùng skill upstream đó; reviewer APES giữ đánh giá độc lập, read-only. Nếu không có, tiếp tục bằng APES UI/UX workflow. Không giả định có lifecycle hook cho Antigravity và không tự cài.
- Khi FlowPlan MCP thực sự khả dụng hoặc người dùng yêu cầu bảng tiến độ, đọc skill apes-flowplan-operations; nếu không, không bắt buộc cài/dùng FlowPlan.
- Với FlowPlan: kiểm tra list_plans, dùng prefix trạng thái và bằng chứng test, đọc lại card sau cập nhật; không giả định FlowPlan quan sát terminal/subagent tự động.
- Không tự cài/chạy ứng dụng FlowPlan, không tự clear/remove card và không tự sửa MCP config nếu chưa được yêu cầu.
- Không tự triển khai production, chi tiêu, tạo cloud resources hoặc thay đổi quyền.

## APES 3.0 Workflow Engine

For multi-step work, select a workflow from config/workflows.json and read the apes-workflow-engine skill. Use Build-APESPrompt.ps1 for prompt assembly and Manage-APESRun.ps1 for explicit state checkpoints. Advance only after inspected evidence; require explicit human approval at APPROVAL. The ledger is not automatic telemetry. Preserve FlowPlan and Impeccable as optional independent integrations.
