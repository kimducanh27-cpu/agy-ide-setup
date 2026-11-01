# APES 3.0 — Antigravity Project Engineering System

**Bộ thiết lập Google Antigravity 2.0 Desktop App và Antigravity IDE trên Windows 11 · Tiếng Việt · Native Rules + Skills + Custom Agents · Prompt & Workflow Engine · UI/UX + FlowPlan Windows bridge tùy chọn**

APES hỗ trợ hai desktop surface riêng biệt: **Antigravity 2.0 Desktop App** (standalone agent command center) và **Antigravity IDE**. Hai surface có thư mục dữ liệu runtime khác nhau; không được nhầm với Antigravity CLI. Xem [bảng tương thích](docs/ANTIGRAVITY-COMPATIBILITY.md).

APES có bốn lớp:

1. **Project Bootstrap:** phân tích yêu cầu, nghiên cứu GitHub/tài liệu chính thức, đề xuất stack, kiến trúc, kế hoạch kiểm thử và sinh cấu hình riêng.
2. **Engineering Harness:** phân vai chuyên môn, thực thi theo milestone, review độc lập, đánh giá bằng bằng chứng, sửa lỗi có giới hạn và lưu bài học.
3. **Native Custom Agents:** một Orchestrator có thể chọn làm agent chính và tám worker có thể được gọi như subagents bằng cơ chế native Antigravity.
4. **Prompt & Workflow Engine:** chọn workflow, dựng prompt theo ngữ cảnh và ghi checkpoint có bằng chứng.

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

## Project Manager và FlowPlan — kế hoạch chính + bảng quan sát

APES dùng `apes-project-manager` để tạo ba artifact chuẩn trong workspace: `PROJECT_BRIEF.md`, `MASTER_PLAN.md` và `task-graph.json` dưới `docs/engineering/apes/projects/<slug>/`. Master Plan giữ phạm vi, kiến trúc, milestone, task, dependency, owner, acceptance criteria, rủi ro và approval.

FlowPlan chỉ là bản chiếu trực quan tiếng Việt để người không chuyên theo dõi dự án. `apes-flowplan-projection` chuyển các deliverable có ý nghĩa thành card dễ hiểu; `apes-flowplan-operations` thực hiện MCP, cập nhật trạng thái, feedback và recovery. Board draft dùng `[REVIEW]` cho đến khi người dùng duyệt đúng revision. Khi FlowPlan mất kết nối, Master Plan trong workspace vẫn còn nguyên và tiếp tục là nguồn chuẩn.

Tài liệu: [kiến trúc Project Planning + FlowPlan](docs/PROJECT-PLANNING-AND-FLOWPLAN.md) · [Project Manager prompt pack](templates/prompts/APES-PROJECT-MANAGER-WORKFLOW-VI.md) · [FlowPlan prompt pack](templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md).

APES tập trung điều phối vòng đời dự án. Các công cụ chuyên môn bên ngoài như Impeccable được tích hợp theo kiểu tùy chọn, không bị sao chép hoặc khóa phiên bản bên trong APES.

## Dùng nhanh — giao Agent tự cài

1. Mở Antigravity tại thư mục dự án.
2. Dán prompt sau vào Agent Chat:

> Hãy tự cài APES 3.0 từ https://github.com/kimducanh27-cpu/agy-ide-setup. Đọc START_HERE_FOR_AI_VI.md, kiểm tra installer trước khi chạy, cài Global + Workspace Rules, Skills và cả 9 Custom Agents theo đường dẫn native. Không ghi đè cấu hình cá nhân; backup file APES trùng tên. Chạy validator và smoke test, xác minh Antigravity đã phát hiện apes-orchestrator cùng 8 subagents. Dùng Orchestrator bootstrap dự án bằng tiếng Việt, nghiên cứu GitHub/tài liệu chính thức, tạo brief/architecture/test plan/milestones rồi dừng chờ tôi duyệt trước khi code. Không giả vờ đã gọi subagent nếu runtime surface đang dùng không thực sự tạo/invoke worker riêng. Không tự deploy, mua dịch vụ, tạo cloud resource hoặc thay đổi dữ liệu quan trọng.

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
| Rules | ~/.gemini/config/rules/ (7) | .agents/rules/ (7) |
| Skills | ~/.gemini/config/skills/ (10 APES skills) | .agents/skills/ (10 APES + 17 role skills) |
| Custom Agents | ~/.gemini/config/agents/*.md | .agents/agents/*.md |
| Engineering docs | — | docs/engineering/apes/ (toàn bộ docs/*.md) |

17 `role-*` skill chỉ cài ở workspace. Chúng là tài liệu tham chiếu theo vai trò cho từng dự án, không phải nguyên tắc chung toàn máy; `Scope Global` cố ý không đưa chúng lên `~/.gemini/config/skills/`.

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

Chỉ Orchestrator có mainAgent: true. Cả chín agent đều khai báo subagent: true để Orchestrator có thể được gọi lồng khi cần; tám worker còn lại không thể chọn làm agent chính.

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

**Quy trình dùng đúng:** Project Brief → Master Plan + Task Graph (nguồn chuẩn trong workspace) → Plan Quality Audit → FlowPlan draft [REVIEW] → người dùng duyệt đúng revision → FlowPlan [TODO] → khi thực thi thật mới [DOING] → test/review + evidence → [PASS]/[BLOCKED] và readback. FlowPlan là bảng quan sát dễ hiểu, không thay thế Master Plan và không tự theo dõi terminal/subagent theo thời gian thực. FlowPlan hiện không có status field riêng; APES dùng prefix trong title. Xem docs/PROJECT-PLANNING-AND-FLOWPLAN.md, docs/FLOWPLAN-WINDOWS-INTEGRATION.md, templates/prompts/APES-PROJECT-MANAGER-WORKFLOW-VI.md và templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md.

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

`-Stage PreCode` không chỉ kiểm tra file tồn tại: nó yêu cầu `00-project-brief.md` đã điền `Problem / opportunity`, `Project name`, `Target users`, `Acceptance criteria` và `02-architecture.md` đã có `Proposed stack`. Installer copy template rỗng vào đúng các đường dẫn đó, nên nếu chỉ kiểm tra sự tồn tại thì gate sẽ PASS ngay sau khi cài mà chưa có kế hoạch thật.

Khi truyền `-ProjectPath`, validator còn đối chiếu `version` trong `.agents/apes-install.json` với `VERSION` của repo. Cài lệch bản sẽ FAIL kèm hướng dẫn cài lại, thay vì để workspace cũ chạy âm thầm với rule/skill đã đổi.

GitHub Actions chạy validator và smoke test cài đặt vào workspace tạm trên Windows, gồm cả hai chiều của gate: template rỗng phải bị từ chối, brief đã điền phải được chấp nhận. PASS chỉ xác nhận metadata/đường dẫn/copy và cú pháp PowerShell, không chứng nhận chất lượng ứng dụng hoặc khả năng thực thi subagent trên máy thật.

## Kiểm tra trong Antigravity 2.0 Desktop App / Antigravity IDE

1. Mở Agent side panel → ... → Customizations/Agents.
2. Xác minh có chín APES agents.
3. Chọn apes-orchestrator làm agent chính nếu muốn.
4. Yêu cầu Orchestrator giao tác vụ đọc-only cho apes-project-analyst.
5. Xác minh subagent thật sự xuất hiện và trả kết quả. Nếu surface đang dùng chưa hỗ trợ, báo rõ và chuyển sang Skills tuần tự.

## MCP và Hooks

APES không tự cài MCP server hoặc hooks tuỳ tiện. MCP có thể cần OAuth/API keys; hooks thực thi shell commands. Xem docs/OPTIONAL-INTEGRATIONS.md và không ghi đè cấu hình hiện có.

## An toàn

- Không cần quyền Administrator.
- Installer APES cơ bản không tải/chạy mã ngoài.
- Installer Impeccable là opt-in riêng: tải archive của tag upstream đã chọn, chỉ sao chép skill Antigravity và backup thư mục Impeccable cũ trước khi thay thế; không thực thi script trong lúc cài.
- Không xóa file hiện có; file APES cùng tên được backup tại %LOCALAPPDATA%\APES\backups\ kèm `backup-manifest.json` ánh xạ đường dẫn gốc sang file backup.

## Khôi phục sau khi cài đè

Mỗi lần cài ghi đè file đã tồn tại, installer ghi thêm `backup-manifest.json` vào thư mục backup. Script restore đọc manifest đó và **mặc định chỉ xem trước**:

~~~powershell
# Xem trước, không ghi gì (dùng backup mới nhất)
.\scripts\Restore-APES.ps1 -DryRun

# Khôi phục thật từ một thư mục backup cụ thể
.\scripts\Restore-APES.ps1 -BackupPath "$env:LOCALAPPDATA\APES\backups\20261101-143828" -Force

# Chỉ khôi phục các file khớp chuỗi
.\scripts\Restore-APES.ps1 -BackupPath "<dir>" -Force -Only 'apes-core','AGENTS.md'
~~~

Trước khi ghi, script kiểm tra **tất cả** file backup có mặt; thiếu một file là hủy toàn bộ, không ghi gì. Trạng thái hiện tại được giữ lại ở `restore-safety-<timestamp>` trước khi bị ghi đè, nên có thể hoàn tác bằng cách chạy lại chính script với `-BackupPath` trỏ vào thư mục đó.

Backup tạo trước APES 3.0 không có manifest nên không khôi phục tự động được; script báo rõ thay vì đoán.
- Không commit secrets hoặc dữ liệu cá nhân.
- Không tự deploy production, chi tiêu, tạo cloud resource hoặc thay đổi dữ liệu thật.

Tài liệu: START_HERE_FOR_AI_VI.md · Antigravity 2.0/IDE compatibility: docs/ANTIGRAVITY-COMPATIBILITY.md · Custom Agents: docs/HARNESS-AGENTS.md · Compatibility: docs/ANTIGRAVITY-COMPATIBILITY.md · Impeccable: docs/IMPECCABLE-INTEGRATION.md · MCP/Hooks: docs/OPTIONAL-INTEGRATIONS.md · Official subagents docs: https://antigravity.google/docs/subagents
