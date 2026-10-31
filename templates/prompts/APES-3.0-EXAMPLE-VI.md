# Ví dụ: khởi chạy workflow Standard Feature

Mục tiêu ví dụ: thêm chức năng tìm kiếm trong ứng dụng.

PowerShell:
```powershell
$project = (Get-Location).Path
.scriptsBuild-APESPrompt.ps1 -Workflow standard-feature -ProjectPath $project -Goal "Thêm chức năng tìm kiếm theo tên, có debounce và trạng thái empty/loading/error." -Mode ManualCheckpoint -OutputPath ".apes\generated\search-feature-prompt.md"
.scriptsManage-APESRun.ps1 -Action Initialize -Workflow standard-feature -ProjectPath $project
```

Đưa prompt đã tạo vào Antigravity. Ở mỗi stage, kiểm tra kết quả và chỉ ghi checkpoint sau khi có evidence. Tại APPROVAL, trình kế hoạch cho người dùng. Chỉ sau khi người dùng duyệt rõ mới chạy:
```powershell
.scriptsManage-APESRun.ps1 -Action Advance -ProjectPath $project -RunId "<RUN_ID>" -Stage APPROVAL -Evidence "Người dùng xác nhận duyệt kế hoạch trong chat" -ApprovalConfirmed
```

Không dùng chuỗi ví dụ này như bằng chứng thật cho dự án khác.
