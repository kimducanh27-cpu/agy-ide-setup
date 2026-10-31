# APES 3.0 — Prompt & Workflow Engine

APES 3.0 chuyển từ prompt library sang lớp chọn workflow, lắp prompt và ghi nhận checkpoint. Nó vẫn chạy trong Antigravity native agent; không thay thế agent runtime, không tự quan sát terminal và không tạo telemetry giả.

## Thành phần

- `config/workflows.json`: catalog Quick Fix, Standard Feature, Full Project, Deep Research, Hard Review.
- `scripts/Build-APESPrompt.ps1`: dựng prompt tiếng Việt theo workflow, mode, project path và mục tiêu.
- `scripts/Manage-APESRun.ps1`: tạo và quản lý state JSON cục bộ dưới `.apes/runs/<run-id>/state.json`.
- `templates/engine/BASE-PROMPT-VI.md`: contract dùng chung, stage gates và output contract.

## Dùng trên Windows PowerShell

Tạo prompt:
```powershell
.scriptsBuild-APESPrompt.ps1 -Workflow standard-feature -ProjectPath (Get-Location).Path -Goal "Mô tả tính năng cần làm" -Mode Auto -OutputPath ".apes\generated\task-prompt.md"
```
Mở file prompt được tạo, đưa nội dung vào Antigravity Agent Chat. Với Full Project, Deep Research hoặc Hard Review, thay workflow tương ứng.

Tạo run state:
```powershell
$result = .scriptsManage-APESRun.ps1 -Action Initialize -Workflow standard-feature -ProjectPath (Get-Location).Path
$result
```
Dùng RUN_ID được in ra để ghi checkpoint:
```powershell
.scriptsManage-APESRun.ps1 -Action Advance -ProjectPath (Get-Location).Path -RunId "<RUN_ID>" -Stage DISCOVERY -Evidence "Đã đọc src/...; acceptance criteria lưu tại ..."
.scriptsManage-APESRun.ps1 -Action Show -ProjectPath (Get-Location).Path -RunId "<RUN_ID>"
```
Chặn hoặc hoàn tất:
```powershell
.scriptsManage-APESRun.ps1 -Action Block -ProjectPath (Get-Location).Path -RunId "<RUN_ID>" -Reason "Test môi trường không chạy được"
.scriptsManage-APESRun.ps1 -Action Complete -ProjectPath (Get-Location).Path -RunId "<RUN_ID>" -Evidence "Audit report: ...; tests: ..."
```

## Quy tắc

- Prompt Builder chỉ lắp prompt; không tự thực thi workflow.
- State Manager ghi checkpoint do người dùng/agent gọi tường minh; không tự phát hiện stage đã hoàn tất.
- `Advance` yêu cầu stage khớp currentStage và evidence không rỗng. Script không tự xác nhận evidence là đúng; reviewer/agent phải kiểm tra.
- `NEXT_STAGE_PENDING` là trạng thái chờ điều phối viên cập nhật stage tiếp theo; không giả định script tự suy ra thứ tự stage từ mọi workflow.
- Với FlowPlan, MCP tool calls phải thực sự có sẵn và được readback. Không coi JSON state là đồng bộ tự động với FlowPlan.
- Approval là human gate: không chuyển qua APPROVAL nếu chưa có xác nhận rõ ràng.
- Auto mode chỉ tự tiếp tục trong phạm vi đã được duyệt; ManualCheckpoint dừng sau mỗi stage.

## Giới hạn v3.0

Đây là prompt assembly + explicit state ledger, chưa phải autonomous runtime scheduler. Không có event hooks để bắt mọi terminal command, không có bảo đảm subagent invocation, và không có dashboard real-time. Những phần đó cần API/runtime được Antigravity hỗ trợ và kiểm thử trên desktop thật.
