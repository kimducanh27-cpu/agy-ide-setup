# APES 2.1 — Antigravity Project Engineering System

**Bộ thiết lập Antigravity IDE cho Windows 11 · Tiếng Việt · Native Rules + Skills + Custom Agents**

APES có ba lớp:

1. **Project Bootstrap:** phân tích yêu cầu, nghiên cứu GitHub/tài liệu chính thức, đề xuất stack, kiến trúc, kế hoạch kiểm thử và sinh cấu hình riêng.
2. **Engineering Harness:** phân vai chuyên môn, thực thi theo milestone, review độc lập, đánh giá bằng bằng chứng, sửa lỗi có giới hạn và lưu bài học.
3. **Native Custom Agents:** một Orchestrator có thể chọn làm agent chính và tám worker có thể được gọi như subagents bằng cơ chế native Antigravity.

## Dùng nhanh — giao Agent tự cài

1. Mở Antigravity tại thư mục dự án.
2. Dán prompt sau vào Agent Chat:

> Hãy tự cài APES 2.1 từ `https://github.com/kimducanh27-cpu/agy-ide-setup`. Đọc `START_HERE_FOR_AI_VI.md`, kiểm tra installer trước khi chạy, cài Global + Workspace Rules, Skills và cả 9 Custom Agents theo đường dẫn native. Không ghi đè cấu hình cá nhân; backup file APES trùng tên. Chạy validator và smoke test, xác minh Antigravity đã phát hiện `apes-orchestrator` cùng 8 subagents. Dùng Orchestrator bootstrap dự án bằng tiếng Việt, nghiên cứu GitHub/tài liệu chính thức, tạo brief/architecture/test plan/milestones rồi dừng chờ tôi duyệt trước khi code. Không giả vờ đã gọi subagent nếu IDE không thực sự tạo subagent. Không tự deploy, mua dịch vụ, tạo cloud resource hoặc thay đổi dữ liệu quan trọng.

Bạn không cần tự gõ lệnh PowerShell nếu Agent có terminal/file tools.

## Cài thủ công (Windows PowerShell)

```powershell
git clone https://github.com/kimducanh27-cpu/agy-ide-setup.git "$env:LOCALAPPDATA\APES\agy-ide-setup"
Set-ExecutionPolicy -Scope Process Bypass
$apes = "$env:LOCALAPPDATA\APES\agy-ide-setup"
$project = "D:\Projects\MyApp"
& "$apes\scripts\Install-APES.ps1" -Scope All -ProjectPath $project
& "$apes\scripts\Test-APES.ps1" -ProjectPath $project -CheckGlobal
```

## Những gì được cài

| Hạng mục | Global | Workspace |
|---|---|---|
| Base instructions | `~/.gemini/config/AGENTS.md` | `.agents/AGENTS.md` |
| Rules | `~/.gemini/config/rules/` | `.agents/rules/` |
| Skills | `~/.gemini/config/skills/` | `.agents/skills/` |
| Custom Agents | `~/.gemini/config/agents/*.md` | `.agents/agents/*.md` |
| Engineering docs | — | `docs/engineering/apes/` |

## Custom Agents

- `apes-orchestrator`: agent chính, điều phối lifecycle.
- `apes-project-analyst`: yêu cầu và scope.
- `apes-github-researcher`: GitHub, docs, license, compatibility.
- `apes-solution-architect`: architecture, API/data flow, ADR.
- `apes-implementation-engineer`: code sau approval.
- `apes-qa-engineer`: test và triage lỗi.
- `apes-ui-ux-reviewer`: review UI/UX độc lập.
- `apes-security-reviewer`: security/privacy review.
- `apes-harness-evaluator`: verdict độc lập dựa trên evidence.

Chỉ Orchestrator có `mainAgent: true`; tám worker có `subagent: true`.

## Quy trình

```text
DISCOVERY → RESEARCH → ARCHITECTURE → QUALITY PLAN → HUMAN APPROVAL
                                                         ↓
MILESTONE EXECUTION → TESTS → INDEPENDENT REVIEW → EVALUATION
                          ↑              ↓                 ↓
                          └──── FIX (tối đa 3 vòng) ← REJECT
                                                         ↓
                                               MEMORY + REPORT
```

Không code sản phẩm trước khi người dùng duyệt brief, kiến trúc và kế hoạch. Sau duyệt, từng milestone phải có acceptance criteria, lệnh kiểm tra thật và bằng chứng.

## Validator

```powershell
.\scripts\Test-APES.ps1
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -CheckGlobal
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Stage PreCode
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Stage Approved
```

GitHub Actions chạy validator và smoke test cài đặt vào workspace tạm trên Windows. PASS chỉ xác nhận metadata/đường dẫn/copy, không chứng nhận chất lượng ứng dụng.

## Kiểm tra trong Antigravity Desktop
1. Mở workspace, mở Agent side panel → `...` → Customizations/Agents.
2. Xác minh có chín APES agents.
3. Chọn `apes-orchestrator` làm agent chính nếu muốn.
4. Yêu cầu Orchestrator giao tác vụ đọc-only cho `apes-project-analyst`.
5. Xác minh subagent thật sự xuất hiện và trả kết quả. Nếu IDE chưa hỗ trợ, báo rõ và chuyển sang Skills tuần tự.

## MCP và Hooks
APES không tự cài MCP server hoặc hooks tuỳ tiện. MCP có thể cần OAuth/API keys; hooks thực thi shell commands. Xem `docs/OPTIONAL-INTEGRATIONS.md` và không ghi đè cấu hình hiện có.

## An toàn
- Không cần quyền Administrator.
- Installer không tải/chạy mã ngoài.
- Không xóa file hiện có; file APES cùng tên được backup tại `%LOCALAPPDATA%\APES\backups\`.
- Không commit secrets hoặc dữ liệu cá nhân.
- Không tự deploy production, chi tiêu, tạo cloud resource hoặc thay đổi dữ liệu thật.

Tài liệu: [START_HERE_FOR_AI_VI.md](START_HERE_FOR_AI_VI.md) · [Custom Agents](docs/HARNESS-AGENTS.md) · [Compatibility](docs/ANTIGRAVITY-COMPATIBILITY.md) · [MCP/Hooks](docs/OPTIONAL-INTEGRATIONS.md) · [Official subagents docs](https://antigravity.google/docs/subagents)
