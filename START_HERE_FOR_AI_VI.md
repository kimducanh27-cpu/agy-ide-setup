# START HERE — Hướng dẫn cho Antigravity Agent

Người dùng muốn bạn tự cài APES 2.0 cho workspace hiện tại. Họ không rành kỹ thuật. Hãy tự làm các thao tác an toàn, nói bằng tiếng Việt dễ hiểu và không yêu cầu họ gõ lệnh nếu bạn có terminal/file tools.

Nguồn: https://github.com/kimducanh27-cpu/agy-ide-setup

## 1. Khảo sát và bảo vệ workspace

- Xác định OS, shell, đường dẫn workspace, trạng thái Git và cấu hình Antigravity đang có.
- Không xóa, reset, checkout, clean hoặc clone đè workspace.
- Trên Windows, clone APES vào thư mục công cụ riêng: `$env:LOCALAPPDATA\APES\agy-ide-setup`.
- Nếu thư mục APES đã tồn tại, kiểm tra remote và working tree. Chỉ `git pull --ff-only` khi working tree sạch; nếu không, dừng và báo người dùng.

## 2. Kiểm tra trước khi chạy

Đọc `README.md`, `NOTICE.md`, `LICENSE`, `docs/ANTIGRAVITY-COMPATIBILITY.md`, `scripts/Install-APES.ps1` và `scripts/Test-APES.ps1`. Xác nhận installer không xóa dữ liệu, không cần Administrator, không đọc secrets và không tải rồi thực thi mã ngoài. Nếu có hành vi đáng ngờ, không chạy.

## 3. Cài đặt Windows 11

Chỉ chạy PowerShell script trên Windows PowerShell. Không thay đổi ExecutionPolicy vĩnh viễn:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
$apes = Join-Path $env:LOCALAPPDATA 'APES\agy-ide-setup'
& (Join-Path $apes 'scripts\Install-APES.ps1') -Scope All -ProjectPath (Get-Location).Path
& (Join-Path $apes 'scripts\Test-APES.ps1') -ProjectPath (Get-Location).Path -CheckGlobal
```

Nếu repo được clone ở vị trí khác, dùng đường dẫn thực tế cho `$apes`. `-Scope All` cài cả Global và Workspace; `-Scope Global` chỉ cài global; `-Scope Project` chỉ cài workspace. Không chạy script Windows trên macOS/Linux; hãy báo installer native cho hệ điều hành đó chưa được cung cấp.

Installer cài Rules/Skills theo đường dẫn Antigravity native và thêm hồ sơ trong `docs/engineering/apes/bootstrap/`. File APES trùng tên được backup trước khi thay thế; file khác được giữ nguyên.

## 4. Xác minh

- Chạy validator và đọc exit code/output thật.
- Báo số Rules/Skills, đường dẫn cài và vị trí backup.
- Nếu validator lỗi, dừng và sửa lỗi; không tuyên bố cài thành công.
- Nếu IDE chưa nhận cấu hình, mở Agent Panel → `...` → Customizations; reload/restart IDE hoặc mở conversation mới khi cần.

## 5. Bootstrap dự án — chưa code sản phẩm

Kích hoạt Skills `apes-project-bootstrap`, `apes-github-research` và specialist roles phù hợp. Sau đó:

1. Khảo sát yêu cầu, file hiện có, nền tảng và ràng buộc.
2. Phân loại dự án: Web, Android, iOS, Desktop, Backend, AI, Data, Game hoặc loại khác. Không áp đặt một stack chung.
3. Nghiên cứu tài liệu chính thức và GitHub; kiểm tra maintenance, releases, issues, license, bảo mật và compatibility. Ghi URL và ngày tra cứu.
4. Tạo brief, acceptance criteria, technology research, architecture/ADR, quality plan, milestones và risk register bằng tiếng Việt.
5. Sinh hoặc tinh chỉnh rules/skills riêng nếu cần, tránh trùng lặp.
6. Đánh dấu dữ kiện VERIFIED, INFERRED hoặc UNKNOWN; không bịa benchmark hay kết quả kiểm thử.
7. Chạy validator `-Stage PreCode` khi hồ sơ đã đủ.

## 6. Chờ người dùng duyệt

Trình bày mục tiêu, stack đề xuất, kiến trúc, rủi ro, milestones, cách kiểm thử và chi phí/dịch vụ bên ngoài. Chờ người dùng xác nhận rõ ràng trong chat.

Trước khi được duyệt, không viết code sản phẩm, mua dịch vụ, tạo cloud resources, deploy production hoặc thay đổi dữ liệu thật. Chỉ sau khi được duyệt mới cập nhật `06-approval.md` thành `APPROVED` và chạy validator `-Stage Approved`.

## 7. Harness sau duyệt

- Chia việc thành milestone nhỏ có exit criteria.
- Tách Executor và Reviewer; người viết code không làm reviewer duy nhất cho thay đổi rủi ro cao.
- Chỉ gọi subagents khi Antigravity IDE hiện tại thật sự hỗ trợ. Nếu không, chạy role passes tuần tự và nói rõ đây không phải subagent độc lập.
- Chạy test/lint/build/security checks phù hợp; ghi lệnh và output. Chưa chạy thì ghi `NOT_RUN`, không in PASS giả.
- Tối đa 3 vòng tự sửa cho cùng lỗi, sau đó dừng và báo người dùng.
- Evaluator trả `PASS`, `REJECT` hoặc `NEEDS_HUMAN_REVIEW` dựa trên diff và evidence, không đánh giá private chain-of-thought.
- Chỉ lưu bài học kỹ thuật đã xác minh vào `.agents/.memory/`; không lưu passwords, API keys, tokens hay dữ liệu cá nhân.

## Báo cáo hoàn tất

Tóm tắt bằng tiếng Việt: đã cài gì, đường dẫn, kết quả validator, backup, trạng thái Antigravity discovery, trạng thái bootstrap và việc còn cần người dùng quyết định.

**Nguyên tắc:** bảo toàn dữ liệu, không vượt quyền, không code trước approval gate và không giả vờ thao tác đã thành công.
