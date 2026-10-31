# START HERE — Hướng dẫn cho Antigravity Agent

Người dùng yêu cầu bạn tự cài APES 2.0 cho workspace hiện tại. Họ không rành kỹ thuật, vì vậy hãy thực hiện các thao tác an toàn, giải thích dễ hiểu và không yêu cầu họ tự gõ lệnh nếu bạn có terminal/file tools.

## Nguồn

`https://github.com/kimducanh27-cpu/agy-ide-setup`

## Quy trình bắt buộc

### 1. Khảo sát trước khi thay đổi

- Xác định OS, shell, workspace root, trạng thái Git và các cấu hình Antigravity hiện có.
- Không xóa, reset, checkout, clean hoặc clone đè workspace.
- Trên Windows, clone APES vào thư mục công cụ riêng: `$env:LOCALAPPDATA\APES\agy-ide-setup`.
- Nếu thư mục đó đã có repo APES, kiểm tra remote và working tree; chỉ cập nhật bằng `git pull --ff-only` khi working tree sạch. Nếu không sạch, dừng và báo người dùng.

### 2. Kiểm toán trước khi chạy

Đọc `README.md`, `NOTICE.md`, `LICENSE`, `docs/ANTIGRAVITY-COMPATIBILITY.md`, `scripts/Install-APES.ps1` và `scripts/Test-APES.ps1`. Xác nhận script không xóa dữ liệu, không yêu cầu quyền Administrator, không lấy secrets và không thực thi mã tải từ nguồn ngoài. Nếu phát hiện nội dung đáng ngờ, không chạy.

### 3. Cài trên Windows 11

Chỉ chạy PowerShell script nếu OS là Windows và shell là PowerShell. Không thay đổi ExecutionPolicy vĩnh viễn; chỉ áp dụng trong tiến trình hiện tại:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
$apes = Join-Path $env:LOCALAPPDATA 'APES\agy-ide-setup'
& (Join-Path $apes 'scripts\Install-APES.ps1') -Scope All -ProjectPath (Get-Location).Path
& (Join-Path $apes 'scripts\Test-APES.ps1') -ProjectPath (Get-Location).Path -CheckGlobal
```

Nếu repo được clone ở vị trí khác, thay `$apes` bằng đường dẫn thực tế. Nếu người dùng ch� thay cài global, dùng `-Scope Global`; chỉ workspace, dùng `-Scope Project`. Không tự cài trên OS khác bằng script Windows; hãy báo chưa có installer native cho OS đó.

Installer cài Rules/Skills theo đường dẫn Antigravity native và thêm tài liệu trong `docs/engineering/apes/bootstrap/`. File APES cùng tên được backup trước khi thay; file không thuộc APES được giữ nguyên.

### 4. Xác minh

- Chạy `Test-APES.ps1` và đọc exit code/output.
- Báo số lượng Rules/Skills tìm thấy, file đã cài và nơi lưu backup.
- Nếu validator lỗi, dừng và sửa nguyên nhân; không được tuyên bố cài thành công.
- Nếu IDE chưa nhận customizations, hướng dẫn người dùng mở Agent Panel → `...` → Customizations; sau đó reload/restart hoặc mở conversation mới nếu cần.

### 5. Bootstrap dự án — tuyệt đối chưa code sản phẩm

Kích hoạt các Skills `apes-project-bootstrap`, `apes-github-research` và các specialist roles thật sự phù hợp. Sau đó:

1. Kiểm tra cấu trúc dự án và yêu cầu đã có trong workspace/hội thoại.
2. Phân loại nền tảng: Web, Android, iOS, Desktop, Backend, AI, Data, Game hoặc loại khác. Không mặc định một stack chung.
3. Nghiên cứu tài liệu chính thức và GitHub repositories; kiểm tra hoạt động, releases, issues, license, bảo mật và khả năng tương thích. Ghi URL và ngày kiểm tra.
4. Viết brief, acceptance criteria, technology research, architecture/ADR, quality plan, milestones và risk register bằng tiếng Việt.
5. Tạo hoặc tinh chỉnh rules/skills riêng nếu cần; tránh trùng lặp.
6. Phân biệt thông tin VERIFIED, INFERRED và UNKNOWN. Không bịa benchmark, test results hoặc compatibility.
7. Chạy validator `-Stage PreCode` khi đã đủ hồ sơ.

### 6. Cổng duyệt của người dùng

Trình bày mục tiêu, stack đề xuất, kiến trúc, rủi ro, milestone, cách kiểm thử, chi phí/dịch vụ ngoài và các giả định. Chờ câu xác nhận rõ ràng trong chat. Không viết code sản phẩm, mua dịch vụ, tạo cloud resources, deploy production hoặc thay đổi dữ liệu thật trước khi người dùng duyệt.

Chỉ sau khi được duyệt mới cập nhật `docs/engineering/apes/bootstrap/06-approval.md` thành `APPROVED` và chạy validator `-Stage Approved`.

### 7. Harness sau duyệt

- Chia việc thành milestone nhỏ với exit criteria kiểm chứng được.
- Tách Executor và Reviewer; người viết code không phải reviewer duy nhất cho thay đổi rủi ro cao.
- Chỉ gọi subagents khi Antigravity IDE hiện tại thực sự hỗ trợ. Nếu không, chạy các role passes tuần tự và nói rõ đó không phải subagent độc lập.
- Chạy test/lint/build/security checks phù hợp stack; ghi lệnh và output. Chưa chạy thì ghi `NOT_RUN`, không in PASS giả.
- Giới hạn tối đa 3 vòng sửa tự động cho cùng lỗi; sau đó dừng và báo người dùng.
- Evaluator trả `PASS`, `REJECT` hoặc `NEEDS_HUMAN_REVIEW` dựa trên diff và bằng chứng, không đánh giá private chain-of-thought.
- Lưu bài học kỹ thuật đã xác minh trong `.agents/.memory/`; không lưu passwords, API keys, tokens hay dữ liệu cá nhân.

## Báo cáo hoàn tất

Tóm tắt bằng tiếng Việt: những gì đã cài, đường dẫn, kết quả validator, backup, trạng thái Antigravity discovery, trạng thái bootstrap và quyết định còn cần người dùng. Minh bạch mọi bước chưa thực hiện.

**Nguyên tắc:** bảo toàn dữ liệu, không vượt quyền, không code trước approval gate, không giả vờ thao tác đã thành công.
