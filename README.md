# APES 2.0 — Antigravity Project Engineering System

**Bộ thiết lập Antigravity IDE cho Windows 11 · Tài liệu tiếng Việt · Native-first**

APES kết hợp hai lớp:

1. **Project Bootstrap:** phân tích yêu cầu, nghiên cứu GitHub/tài liệu chính thức, đề xuất stack, kiến trúc, kế hoạch kiểm thử và sinh cấu hình riêng cho dự án.
2. **Engineering Harness:** phân vai chuyên môn, thực thi theo milestone, review độc lập, đánh giá bằng bằng chứng, sửa lỗi có giới hạn và lưu bài học.

APES dùng cơ chế **Rules + Agent Skills** có sẵn của Antigravity. Các vai trò chuyên môn là skill-based roles; Antigravity chỉ được yêu cầu chạy subagents khi tính năng đó thực sự có trong phiên bản IDE đang dùng. Không giả định có 17 agent độc lập chạy nền.

## Dùng nhanh — không cần tự cài thủ công

1. Mở Antigravity tại thư mục dự án bạn muốn làm.
2. Gửi nguyên câu sau vào Agent Chat:

> **Hãy tự cài và thiết lập APES 2.0 cho workspace này từ `https://github.com/kimducanh27-cpu/agy-ide-setup`. Tôi không rành kỹ thuật. Hãy làm theo `START_HERE_FOR_AI_VI.md`: tự clone repo vào thư mục công cụ riêng, đọc và kiểm tra script trước khi chạy, cài APES global + workspace theo cách an toàn, chạy validator, tạo hồ sơ bootstrap dự án bằng tiếng Việt, nghiên cứu stack/GitHub và dừng ở cổng duyệt trước khi viết code sản phẩm. Không ghi đè cấu hình đang có, không xóa file, không tự chọn dịch vụ trả phí, và báo lại bằng ngôn ngữ dễ hiểu.**

Agent sẽ đọc tài liệu trong repo và thực hiện các bước. Bạn không cần tự gõ lệnh PowerShell.

## Cài thủ công (Windows PowerShell)

Clone repo:

```powershell
git clone https://github.com/kimducanh27-cpu/agy-ide-setup.git "$env:LOCALAPPDATA\APES\agy-ide-setup"
```

Cài global một lần và cài vào thư mục dự án thực tế (thay đường dẫn ví dụ bằng dự án của bạn):

```powershell
Set-ExecutionPolicy -Scope Process Bypass
$apes = "$env:LOCALAPPDATA\APES\agy-ide-setup"
$project = "D:\Projects\MyApp"
& "$apes\scripts\Install-APES.ps1" -Scope All -ProjectPath $project
& "$apes\scripts\Test-APES.ps1" -ProjectPath $project -CheckGlobal
```

## APES cài những gì?

| Scope | Vị trí Antigravity native | Nội dung |
|---|---|---|
| Global Rules | `%USERPROFILE%\.gemini\config\rules\` | Quy tắc dùng chung, có YAML trigger hợp lệ |
| Global Skills | `%USERPROFILE%\.gemini\config\skills\` | Bootstrap, GitHub research, delivery, review |
| Workspace Rules | `<project>\.agents\rules\` | Quy tắc riêng cho dự án |
| Workspace Skills | `<project>\.agents\skills\` | 17 vai trò + các quy trình APES |
| Engineering docs | `<project>\docs\engineering\apes\` | Brief, research, architecture, milestones, risks, approval |

Các file đều được namespace `apes-`. Script tạo bản sao lưu trước khi thay thế file APES cùng tên. File/cấu hình khác được giữ nguyên.

## Quy trình làm việc

```text
DISCOVERY → RESEARCH → ARCHITECTURE → QUALITY PLAN → HUMAN APPROVAL
                                                        ↓
MILESTONE EXECUTION → TESTS → INDEPENDENT REVIEW → EVALUATION
                         ↑              ↓                 ↓
                         └──── FIX (tối đa 3 vòng) ← REJECT
                                                        ↓
                                              MEMORY + REPORT
```

**Mặc định không viết code sản phẩm trước khi người dùng duyệt brief, kiến trúc và kế hoạch.** Sau khi được duyệt, agent làm theo milestone; mỗi milestone phải có lệnh kiểm thử thật và bằng chứng thật.

## 17 vai trò chuyên môn

CTO · Business Analyst · Product Manager · Solution Architect · Frontend · Backend · Mobile · Desktop · AI Engineer · Data Engineer · DevOps · SRE · DevSecOps · QA · Test Automation · Performance Engineer · Harness Evaluator.

Các vai trò là các skill có thể được gọi độc lập hoặc được agent chính áp dụng tuần tự. Việc gọi subagent song song là tùy khả năng native của IDE và phải xác nhận bằng tính năng thực tế, không giả lập.

## Các lệnh validator

```powershell
# Kiểm tra cấu trúc repo và Antigravity metadata
.\scripts\Test-APES.ps1

# Kiểm tra cài đặt global và workspace
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -CheckGlobal

# Kiểm tra hồ sơ trước khi code
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Stage PreCode

# Kiểm tra trạng thái đã duyệt
.\scripts\Test-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Stage Approved
```

Validator chỉ kiểm tra điều có thể xác định bằng máy như file bắt buộc, frontmatter, trạng thái duyệt. Nó **không khẳng định** chất lượng kiến trúc, UI, bảo mật hay test nếu chưa chạy công cụ thực tế.

## Lưu ý an toàn

- Chỉ cài trong tài khoản Windows hiện tại; không cần quyền Administrator.
- Script không tải/chạy mã bên ngoài trong lúc cài.
- Không xóa file hiện có. File APES trùng tên được backup vào `%LOCALAPPDATA%\APES\backups\`.
- Agent phải đọc script và giải thích tác động trước khi thực thi.
- Không đưa API keys, passwords, tokens hoặc dữ liệu riêng tư vào repo.
- Không để evaluator tự phê duyệt yêu cầu thay đổi dữ liệu thật, triển khai production, chi tiêu, hoặc quyền truy cập.

## Nguồn tham khảo

- [Antigravity Rules](https://antigravity.google/docs/rules/)
- [Antigravity Agent Skills](https://antigravity.google/docs/skills)
- [Antigravity Customization Discovery](https://antigravity.google/docs/customization-discovery)
- [vietanhdo/harness-skeleton](https://github.com/vietanhdo/harness-skeleton) — tham khảo mô hình role-based harness; APES không vendoring/copy mã nguồn hoặc skills của repo này.

Xem [START_HERE_FOR_AI_VI.md](START_HERE_FOR_AI_VI.md) để giao toàn bộ việc cài đặt cho agent.
