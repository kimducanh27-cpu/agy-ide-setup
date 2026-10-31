# START HERE — Hướng dẫn cho Antigravity Agent (APES 2.1)

Người dùng không rành kỹ thuật. Tự thực hiện các bước an toàn bằng terminal/file tools khi có thể; giải thích bằng tiếng Việt, không yêu cầu người dùng tự gõ lệnh nếu không cần.

Repository: https://github.com/kimducanh27-cpu/agy-ide-setup

## 1. Khảo sát và bảo vệ dữ liệu
- Xác định OS, shell, workspace root, trạng thái Git, working tree và Antigravity Desktop/CLI surface.
- Không reset, clean, checkout, clone đè hoặc xóa file có sẵn.
- Clone APES vào thư mục công cụ riêng: Windows `$env:LOCALAPPDATA\APES\agy-ide-setup`.
- Nếu repo APES đã tồn tại, kiểm tra remote và working tree. Chỉ cập nhật fast-forward khi working tree sạch; nếu không thì dừng và báo.

## 2. Đọc và kiểm tra trước khi chạy
Đọc README, LICENSE, NOTICE, compatibility docs, Custom Agents docs, optional integrations, installer và validator. Xác nhận script không xóa dữ liệu, không cần Administrator, không truy cập secrets và không tải/chạy mã ngoài. Nếu có bất thường, không chạy.

## 3. Cài trên Windows 11
Chỉ chạy PowerShell trên Windows. Không đổi ExecutionPolicy vĩnh viễn:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
$apes = Join-Path $env:LOCALAPPDATA 'APES\agy-ide-setup'
& (Join-Path $apes 'scripts\Install-APES.ps1') -Scope All -ProjectPath (Get-Location).Path
& (Join-Path $apes 'scripts\Test-APES.ps1') -ProjectPath (Get-Location).Path -CheckGlobal
```

`-Scope All` cài Global + Workspace; `-Scope Global` chỉ global; `-Scope Project` chỉ workspace. Không chạy PowerShell trên macOS/Linux.

Installer cài Global AGENTS.md, Rules, Skills, Agents vào `~/.gemini/config/`; cài Workspace instructions, Rules, Skills, Agents vào `<workspace>/.agents/`; tạo engineering docs tại `docs/engineering/apes/`. File APES trùng tên được backup; file khác giữ nguyên.

## 4. Xác minh Custom Agents trong Antigravity Desktop
- Mở Agent side panel → `...` → Customizations/Agents.
- Xác minh Orchestrator và 8 worker hiển thị; reload/restart IDE hoặc conversation mới nếu cần.
- Chọn `apes-orchestrator` làm primary agent nếu muốn.
- Thử giao task đọc-only cho `apes-project-analyst`; xác minh subagent thực sự xuất hiện và trả kết quả.
- Không dùng lệnh CLI-only `/agents` làm điều kiện bắt buộc cho Desktop IDE.
- Không tuyên bố subagent đã chạy nếu chỉ mô phỏng role trong cùng context.

## 5. Project Bootstrap — chưa code sản phẩm
Kích hoạt `apes-orchestrator`, giao Custom Agents phù hợp. Nếu native `invoke_subagent` có sẵn, có thể chạy song song task độc lập. Nếu không, chạy Skills tuần tự và công bố giới hạn.
1. Analyst làm rõ mục tiêu, target users, use cases, scope, constraints, acceptance criteria.
2. Researcher kiểm tra docs chính thức và GitHub; ghi URL/ngày, releases, maintenance, issues, security, license, compatibility.
3. Architect đề xuất kiến trúc vừa đủ, stack options, data/API boundaries, ADR, threat boundaries và rollback.
4. Orchestrator tạo brief, technology research, architecture, quality plan, milestones, risk register và approval record.
5. Chạy validator `-Stage PreCode`; validator không thay thế việc đọc hồ sơ.
6. Trình bày tiếng Việt và chờ người dùng duyệt rõ trong chat.

Không code trước approval. Không mua dịch vụ, deploy, tạo cloud resource, thay đổi dữ liệu thật hoặc quyền truy cập nếu chưa được xác nhận.

## 6. Sau approval — Harness delivery
1. Người dùng duyệt phạm vi và hồ sơ.
2. Implementation Engineer chỉ nhận milestone đã duyệt.
3. QA Engineer chạy test thật, ghi log/exit code.
4. UI/UX Reviewer và Security Reviewer đánh giá độc lập khi phù hợp.
5. Evaluator trả PASS/REJECT/NEEDS_HUMAN_REVIEW theo diff và evidence; không tự sửa hoặc tự approve.
6. Tối đa 3 vòng remediation cho cùng vấn đề; sau đó dừng và báo.
7. Chỉ lưu bài học kỹ thuật đã xác minh; không lưu secrets, credentials hoặc dữ liệu cá nhân.

## 7. MCP và Hooks
Không tự cài MCP server/hooks hàng loạt. Đọc `docs/OPTIONAL-INTEGRATIONS.md`, xác minh nguồn/quyền/auth/event; merge cấu hình thay vì ghi đè. Hỏi người dùng trước khi bật hook có thể chặn/sửa thao tác.

## Báo cáo
Tóm tắt files installed, paths, backups, validator output, số agent Antigravity phát hiện, kết quả thử delegation, bootstrap status, evidence và quyết định đang chờ.
