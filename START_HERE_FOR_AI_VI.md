# START HERE — Hướng dẫn cho Antigravity Agent (APES 3.0)

Người dùng không rành kỹ thuật. Tự thực hiện các bước an toàn bằng terminal/file tools khi có thể; giải thích bằng tiếng Việt, không yêu cầu người dùng tự gõ lệnh nếu không cần.

Repository: https://github.com/kimducanh27-cpu/agy-ide-setup

## 1. Khảo sát và bảo vệ dữ liệu
- Xác định OS, shell, workspace root, trạng thái Git, working tree và Antigravity Desktop/CLI surface.
- Không reset, clean, checkout, clone đè hoặc xóa file có sẵn.
- Clone APES vào thư mục công cụ riêng: Windows $env:LOCALAPPDATA\APES\agy-ide-setup.
- Nếu repo APES đã tồn tại, kiểm tra remote và working tree. Chỉ cập nhật fast-forward khi working tree sạch; nếu không thì dừng và báo.

## 2. Đọc và kiểm tra trước khi chạy
Đọc README, LICENSE, NOTICE, compatibility docs, Custom Agents docs, optional integrations, Impeccable/FlowPlan integration docs, prompt pack, installers và validators. Xác nhận script không xóa dữ liệu, không cần Administrator, không truy cập secrets và không tải/chạy mã ngoài. Nếu có bất thường, không chạy.

## 3. Cài APES trên Windows 11
Chỉ chạy PowerShell trên Windows. Không đổi ExecutionPolicy vĩnh viễn:

~~~powershell
Set-ExecutionPolicy -Scope Process Bypass
$apes = Join-Path $env:LOCALAPPDATA 'APES\agy-ide-setup'
& (Join-Path $apes 'scripts\Install-APES.ps1') -Scope All -ProjectPath (Get-Location).Path
& (Join-Path $apes 'scripts\Test-APES.ps1') -ProjectPath (Get-Location).Path -CheckGlobal
~~~

Scope All cài Global + Workspace; Scope Global chỉ global; Scope Project chỉ workspace. Không chạy PowerShell trên macOS/Linux.

Installer APES cài Global AGENTS.md, Rules, Skills, Agents vào ~/.gemini/config/; cài Workspace instructions, Rules, Skills, Agents vào <workspace>/.agents/; tạo engineering docs tại docs/engineering/apes/. File APES trùng tên được backup; file khác giữ nguyên.

## 4. Impeccable (tùy chọn, chỉ khi dự án có UI/frontend)

APES không tự tải Impeccable khi cài cơ bản. Nếu người dùng muốn thêm bộ công cụ thiết kế UI, đọc docs/IMPECCABLE-INTEGRATION.md, sau đó chạy script chuyên biệt:

~~~powershell
& (Join-Path $apes 'scripts\Install-Impeccable.ps1') -Scope Project -ProjectPath (Get-Location).Path
& (Join-Path $apes 'scripts\Test-Impeccable.ps1') -Scope Project -ProjectPath (Get-Location).Path
~~~

- Chỉ workspace: Scope Project; toàn IDE: Scope Global; cả hai: Scope All.
- Mặc định ghim upstream tag skill-v4.8.0; không dùng tham số --providers=antigravity chưa được xác nhận. Script lấy đúng build .agent/skills/impeccable cho Antigravity.
- Script tải archive rồi chỉ sao chép skill, không chạy mã trong lúc cài. Có backup nếu thư mục Impeccable cùng tên đã tồn tại.
- Không bật hook tự động; Antigravity không có provider hook được cấu hình trong workflow cài thủ công này.
- Reload IDE. Dùng /impeccable init cho product context, /impeccable document cho design system hiện hữu, và /impeccable critique / audit / polish theo tác vụ.

Nếu không cài Impeccable, APES tiếp tục dùng apes-ui-ux-review skill và Custom Agent apes-ui-ux-reviewer; không được coi Impeccable là thành phần bắt buộc.

## 4B. FlowPlan Windows (tùy chọn, hữu ích cho task nhiều bước)

FlowPlan là bảng tiến độ và feedback, không phải agent thực thi. APES không tự tải/cài/chạy ứng dụng.

1. Tải bản portable Windows từ https://github.com/kimducanh27-cpu/flowplan-windows/releases/latest; đây là community build unsigned, không phải upstream official release. Verify checksum theo docs/FLOWPLAN-WINDOWS-INTEGRATION.md.
2. Mở FlowPlan.exe, giữ WebView2Loader.dll cùng thư mục.
3. Khi FlowPlan health tại http://127.0.0.1:3100/health trả ok=true, cấu hình MCP bằng helper:

~~~powershell
& (Join-Path $apes 'scripts\Install-FlowPlan-MCP.ps1') -Scope Global
# hoặc chỉ workspace:
& (Join-Path $apes 'scripts\Install-FlowPlan-MCP.ps1') -Scope Project -ProjectPath (Get-Location).Path
~~~

4. Kiểm tra config/health:

~~~powershell
& (Join-Path $apes 'scripts\Test-FlowPlan-MCP.ps1') -Scope Global
~~~

5. Reload MCP Servers trong Antigravity, mở chat mới, yêu cầu agent gọi list_plans. Chỉ coi là connected sau khi có tool result thật.
6. Dùng skill apes-flowplan-operations và prompt pack templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md:
   - Preflight, không ghi dữ liệu.
   - Plan/research rồi tạo board, dừng chờ DUYỆT KẾ HOẠCH.
   - Sau approval, làm từng card: [TODO] → [DOING] → implement → test → review → [PASS]/[BLOCKED].
   - Sau mỗi card cập nhật evidence rồi get_cards đọc lại xác minh.
   - Chỉ chuyển bước khi card [PASS] và dependencies hợp lệ.

FlowPlan hiện chưa có status property riêng trong MCP card schema; APES dùng title prefixes [TODO], [DOING], [PASS], [BLOCKED], [REVIEW]. Không dùng remove_card/clear_plan nếu chưa được người dùng cho phép. Nếu MCP sync/readback lỗi, dừng và báo lỗi thay vì tuyên bố board đã cập nhật.

Tài liệu đầy đủ: docs/FLOWPLAN-WINDOWS-INTEGRATION.md. Không thêm config MCP tự động khi cài APES.

## 4C. APES 3.0 Prompt & Workflow Engine

Đọc docs/PROMPT-WORKFLOW-ENGINE-V3.md và .agents/skills/apes-workflow-engine/SKILL.md. Chọn workflow phù hợp; không ép task nhỏ vào full-project.

~~~powershell
$project = (Get-Location).Path
& (Join-Path $apes 'scripts\\Build-APESPrompt.ps1') -Workflow standard-feature -ProjectPath $project -Goal "Mô tả mục tiêu" -Mode ManualCheckpoint -OutputPath (Join-Path $project '.apes\\generated\\prompt.md')
& (Join-Path $apes 'scripts\\Manage-APESRun.ps1') -Action Initialize -Workflow standard-feature -ProjectPath $project
~~~

Mở prompt được tạo và đưa vào Agent Chat. Giữ RUN_ID để ghi checkpoint. Chỉ Advance khi stage khớp và evidence đã được kiểm tra; tại APPROVAL, phải có xác nhận rõ của người dùng và dùng -ApprovalConfirmed. Dùng Block/Resume khi có blocker. Complete chỉ sau khi đi hết stage list và có audit evidence.

Giới hạn: đây là prompt assembly + explicit state ledger, chưa phải runtime scheduler. Không tự thu thập terminal telemetry, không tự phát hiện tiến độ, không tự đồng bộ FlowPlan và không đảm bảo Antigravity gọi subagents.

## 5. Xác minh Custom Agents trong Antigravity Desktop
- Mở Agent side panel → ... → Customizations/Agents.
- Xác minh Orchestrator và 8 worker hiển thị; reload/restart IDE hoặc conversation mới nếu cần.
- Chọn apes-orchestrator làm primary agent nếu muốn.
- Thử giao task đọc-only cho apes-project-analyst; xác minh subagent thực sự xuất hiện và trả kết quả.
- Không dùng lệnh CLI-only /agents làm điều kiện bắt buộc cho Desktop IDE.
- Không tuyên bố subagent đã chạy nếu chỉ mô phỏng role trong cùng context.

## 6. Project Bootstrap — chưa code sản phẩm
Kích hoạt apes-orchestrator, giao Custom Agents phù hợp. Nếu native invoke_subagent có sẵn, có thể chạy song song task độc lập. Nếu không, chạy Skills tuần tự và công bố giới hạn.
1. Analyst làm rõ mục tiêu, target users, use cases, scope, constraints, acceptance criteria.
2. Researcher kiểm tra docs chính thức và GitHub; ghi URL/ngày, releases, maintenance, issues, security, license, compatibility.
3. Architect đề xuất kiến trúc vừa đủ, stack options, data/API boundaries, ADR, threat boundaries và rollback.
4. Orchestrator tạo brief, technology research, architecture, quality plan, milestones, risk register và approval record.
5. Chạy validator -Stage PreCode; validator không thay thế việc đọc hồ sơ.
6. Trình bày tiếng Việt và chờ người dùng duyệt rõ trong chat.

Không code trước approval. Không mua dịch vụ, deploy, tạo cloud resource, thay đổi dữ liệu thật hoặc quyền truy cập nếu chưa được xác nhận.

## 7. Sau approval — Harness delivery
1. Người dùng duyệt phạm vi và hồ sơ.
2. Implementation Engineer chỉ nhận milestone đã duyệt.
3. QA Engineer chạy test thật, ghi log/exit code.
4. UI/UX Reviewer và Security Reviewer đánh giá độc lập khi phù hợp. Nếu Impeccable có mặt, Orchestrator dùng skill đó cho công việc giao diện; reviewer APES vẫn giữ vai trò độc lập, read-only.
5. Evaluator trả PASS/REJECT/NEEDS_HUMAN_REVIEW theo diff và evidence; không tự sửa hoặc tự approve.
6. Tối đa 3 vòng remediation cho cùng lỗi; sau đó dừng và báo.
7. Chỉ lưu bài học kỹ thuật đã xác minh; không lưu secrets, credentials hoặc dữ liệu cá nhân.

## 8. MCP và Hooks
Không tự cài MCP server/hooks hàng loạt. Đọc docs/OPTIONAL-INTEGRATIONS.md, xác minh nguồn/quyền/auth/event; merge cấu hình thay vì ghi đè. Hỏi người dùng trước khi bật hook có thể chặn/sửa thao tác.

## Báo cáo
Tóm tắt files installed, paths, backups, validator output, số agent Antigravity phát hiện, kết quả thử delegation, trạng thái Impeccable (nếu chọn), bootstrap status, evidence và quyết định đang chờ.
