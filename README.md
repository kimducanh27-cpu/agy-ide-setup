# APES 3.0 — Antigravity Project Engineering System

**Bộ thiết lập Antigravity IDE cho Windows 11 · Tiếng Việt · Native Rules + Skills + Custom Agents · Prompt & Workflow Engine · UI/UX + FlowPlan Windows bridge tùy chọn**

APES có ba lớp:

1. **Project Bootstrap:** phân tích yêu cầu, nghiên cứu GitHub/tài liệu chính thức, đề xuất stack, kiến trúc, kế hoạch kiểm thử và sinh cấu hình riêng.
2. **Engineering Harness:** phân vai chuyên môn, thực thi theo milestone, review độc lập, đánh giá bằng bằng chứng, sửa lỗi có giới hạn và lưu bài học.
3. **Native Custom Agents:** một Orchestrator có thể chọn làm agent chính và tám worker có thể được gọi như subagents bằng cơ chế native Antigravity.

## APES 3.0 — Prompt & Workflow Engine

APES 3.0 thêm lớp vận hành workflow vào bộ APES hiện có:

- **Workflow Catalog:** Quick Fix, Standard Feature, Full Project, Deep Research, Hard Review.
- **Prompt Builder:** tạo prompt tiếng Việt theo loại việc, mục tiêu, thư mục dự án và chế độ Auto/ManualCheckpoint.
- **Run State Ledger:** lưu stage/checkpoint/evidence dưới .apes/runs/; hỗ trợ Advance, Block, Resume, Complete.
- **Quality gates:** yêu cầu evidence và approval rõ ràng trước khi chuyển gate tương ứng.

Khởi chạy trên Windows PowerShell từ thư mục repo APES:

~~~powershell
$project = "D:\Projects\MyApp"
.\scripts\Build-APESPrompt.ps1 -Workflow standard-feature -ProjectPath $project -Goal "Mô tả tính năng" -Mode ManualCheckpoint -OutputPath "$project\.apes\generated\prompt.md"
.\scripts\Manage-APESRun.ps1 -Action Initialize -Workflow standard-feature -ProjectPath $project
~~~

Đọc [hướng dẫn engine](docs/PROMPT-WORKFLOW-ENGINE-V3.md) và [prompt nhanh](templates/prompts/APES-3.0-QUICKSTART-VI.md). Prompt Builder chỉ tạo nội dung; người dùng/agent đưa prompt vào Agent Chat. Run State chỉ ghi nhận checkpoint khi được gọi tường minh; không tự quan sát terminal, tự kiểm chứng evidence hoặc điều khiển native subagents.

APES tập trung điều phối vòng đời dự án. Các công cụ chuyên môn bên ngoài như Impeccable được tích hợp theo kiểu tùy chọn, không bị sao chép hoặc khóa phiên bản bên trong APES.

## Dùng nhanh — giao Agent tự cài

1. Mở Antigravity tại thư mục dự án.
2. Dán prompt sau vào Agent Chat:

> Hãy tự cài APES 3.0 từ https://github.com/kimducanh27-cpu/agy-ide-setup. Đọc START_HERE_FOR_AI_VI.md, kiểm tra installer trước khi chạy, cài Global + Workspace Rules, Skills và cả 9 Custom Agents theo đường dẫn native. Không ghi đè cấu hình cá nhân; backup file APES trùng tên. Chạy validator và smoke test, xác minh Antigravity đã phát hiện apes-orchestrator cùng 8 subagents. Dùng Orchestrator bootstrap dự án bằng tiếng Việt, nghiên cứu GitHub/tài liệu chính thức, tạo brief/architecture/test plan/milestones rồi dừng chờ tôi duyệt trước khi code. Không giả vờ đã gọi subagent nếu IDE không thực sự tạo subagent. Không tự deploy, mua dịch vụ, tạo cloud resource hoặc thay đổi dữ liệu quan trọng.

Bạn không cần tự gõ lệnh PowerShell nếu Agent có terminal/file tools.

## Cài thủ công (Windows PowerShell)

~~~powershell
git clone https://github.com/kimducanh27-cpu/agy-ide-setup.git "$env:LOCALAPPDATA\APES\agy-ide-setup"
Set-ExecutionPolicy -Scope Process Bypass
$apes = "$env:LOCALAPPDATA\APES\agy-ide-setup"
$project = "D:\Projects\MyApp"
& "$apes\scripts\Install-APES.ps1" -Scope All -ProjectPath $project
& "$apes\scripts\Test-APES.ps1" -ProjectPath $project -CheckGlobal
~~~

## Những gì được cài

| Hạng mục | Global | Workspace |
|---|---|---|
| Base instructions | ~/.gemini/config/AGENTS.md | .agents/AGENTS.md |
| Rules | ~/.gemini/config/rules/ | .agents/rules/ |
| Skills | ~/.gemini/config/skills/ | .agents/skills/ |
| Custom Agents | ~/.gemini/config/agents/*.md | .agents/agents/*.md |
| Engineering docs | — | docs/engineering/apes/ |

## Custom Agents

- apes-orchestrator: agent chính, điều phối lifecycle.
- apes-project-analyst: yêu cầu và scope.
- apes-github-researcher: GitHub, docs, license, compatibility.
- apes-solution-architect: architecture, API/data flow, ADR.
- apes-implementation-engineer: code sau approval.
- apes-qa-engineer: test và triage lỗi.
- apes-ui-ux-reviewer: review UI/UX độc lập.
- apes-security-reviewer: security/privacy review.
- apes-harness-evaluator: verdict độc lập dựa trên evidence.

Chỉ Orchestrator có mainAgent: true; tám worker có subagent: true.

## Tích hợp tùy chọn: Impeccable cho UI/UX

APES và https://github.com/pbakaus/impeccable có nhiệm vụ riêng:

- **APES:** bootstrap, kiến trúc, phân công agent, approval gate, QA và đánh giá milestone.
- **Impeccable:** design workflow cho frontend/UI, critique, accessibility, responsive, polish và các lệnh thiết kế chuyên biệt.

Impeccable không được vendor vào repo APES và không cài cùng APES mặc định. Để cài bản skill riêng cho Google Antigravity vào workspace hiện tại:

~~~powershell
& "$apes\scripts\Install-Impeccable.ps1" -Scope Project -ProjectPath (Get-Location).Path
& "$apes\scripts\Test-Impeccable.ps1" -Scope Project -ProjectPath (Get-Location).Path
~~~

Tuỳ chọn:
- Scope Project: chỉ workspace hiện tại.
- Scope Global: áp dụng cho các workspace Antigravity trên máy.
- Scope All: cả global và workspace.
- Mặc định script ghim upstream tag skill-v4.8.0; có thể chọn tag khác sau khi đã review release tương ứng bằng tham số Version.

**Đường dẫn có chủ ý khác nhau:** APES dùng .agents/ (số nhiều); build Antigravity của Impeccable dùng .agent/ (số ít). Không đổi tên hoặc gộp hai thư mục.

Sau khi cài, reload Antigravity rồi dùng /impeccable init cho product context mới; với giao diện hiện hữu, có thể dùng /impeccable document, /impeccable critique, /impeccable audit, /impeccable polish hoặc các lệnh phù hợp. APES tự định tuyến tác vụ UI sang Impeccable khi skill đã được cài; backend-only không cần gọi nó.

**Giới hạn:** bản Antigravity được cài bằng skill payload. Không bật lifecycle hook tự động cho Antigravity; không tuyên bố detector tự chạy sau mỗi lần sửa file. Chi tiết: docs/IMPECCABLE-INTEGRATION.md.

## Tích hợp tùy chọn: FlowPlan Windows

Dùng [FlowPlan Windows](https://github.com/kimducanh27-cpu/flowplan-windows) làm bảng task trực quan cho APES. Đây là community build portable, không phải upstream official release; APES không tự tải/cài/chạy ứng dụng.

Khi FlowPlan đang mở, có thể cấu hình MCP an toàn (chỉ loopback, backup và giữ các server khác):

~~~powershell
.\scripts\Install-FlowPlan-MCP.ps1 -Scope Global
# hoặc chỉ workspace:
.\scripts\Install-FlowPlan-MCP.ps1 -Scope Project -ProjectPath (Get-Location).Path
~~~

Kiểm tra config và local health:

~~~powershell
.\scripts\Test-FlowPlan-MCP.ps1 -Scope Global
~~~

Sau đó reload MCP trong Antigravity, mở chat mới và yêu cầu agent gọi list_plans để xác minh kết nối thật.

**Quy trình dùng đúng:** Research → tạo task graph → duyệt → [DOING] → implement → test/review → [PASS] kèm evidence → đọc lại card để xác minh → task tiếp theo. Nếu lỗi hoặc không xác minh được thì [BLOCKED]/[REVIEW] và dừng. FlowPlan hiện không có status field riêng; APES dùng prefix trong title. Xem docs/FLOWPLAN-WINDOWS-INTEGRATION.md và templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md để lấy prompt đầy đủ.

## Quy trình

~~~text
DISCOVERY → RESEARCH → ARCHITECTURE → QUALITY PLAN → HUMAN APPROVAL
                                                         ↓
MILESTONE EXECUTION → TESTS → INDEPENDENT REVIEW → EVALUATION
                          ↑              ↓                 ↓
                          └──── FIX (tối đa 3 vòng) ← REJECT
                                                         ↓
                                               MEMORY + REPORT
~~~

Không code sản phẩm trước khi người dùng duyệt brief, kiến trúc và kế hoạch. Sau duyệt, từng milestone phải có acceptance criteria, lệnh kiểm tra thật và bằng chứng.

## Validator

~~~powershell
.\scripts\Test-APES.ps1
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -CheckGlobal
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Stage PreCode
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Stage Approved
~~~

GitHub Actions chạy validator và smoke test cài đặt vào workspace tạm trên Windows. PASS chỉ xác nhận metadata/đường dẫn/copy và cú pháp PowerShell, không chứng nhận chất lượng ứng dụng hoặc khả năng thực thi subagent trên máy thật.

## Kiểm tra trong Antigravity Desktop

1. Mở Agent side panel → ... → Customizations/Agents.
2. Xác minh có chín APES agents.
3. Chọn apes-orchestrator làm agent chính nếu muốn.
4. Yêu cầu Orchestrator giao tác vụ đọc-only cho apes-project-analyst.
5. Xác minh subagent thật sự xuất hiện và trả kết quả. Nếu IDE chưa hỗ trợ, báo rõ và chuyển sang Skills tuần tự.

## MCP và Hooks

APES không tự cài MCP server hoặc hooks tuỳ tiện. MCP có thể cần OAuth/API keys; hooks thực thi shell commands. Xem docs/OPTIONAL-INTEGRATIONS.md và không ghi đè cấu hình hiện có.

## An toàn

- Không cần quyền Administrator.
- Installer APES cơ bản không tải/chạy mã ngoài.
- Installer Impeccable là opt-in riêng: tải archive của tag upstream đã chọn, chỉ sao chép skill Antigravity và backup thư mục Impeccable cũ trước khi thay thế; không thực thi script trong lúc cài.
- Không xóa file hiện có; file APES cùng tên được backup tại %LOCALAPPDATA%\APES\backups\.
- Không commit secrets hoặc dữ liệu cá nhân.
- Không tự deploy production, chi tiêu, tạo cloud resource hoặc thay đổi dữ liệu thật.

Tài liệu: START_HERE_FOR_AI_VI.md · Custom Agents: docs/HARNESS-AGENTS.md · Compatibility: docs/ANTIGRAVITY-COMPATIBILITY.md · Impeccable: docs/IMPECCABLE-INTEGRATION.md · MCP/Hooks: docs/OPTIONAL-INTEGRATIONS.md · Official subagents docs: https://antigravity.google/docs/subagents
