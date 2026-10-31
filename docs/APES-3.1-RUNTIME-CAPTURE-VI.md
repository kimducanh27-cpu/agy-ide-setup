# APES 3.1 — Runtime Capture (Windows)

## Mục tiêu

Ghi lại những sự kiện Antigravity IDE thực sự phát ra qua Hooks: bắt đầu phiên, trước/sau tool, trước/sau lượt gọi model và khi agent dừng. Đây là lớp thu thập dữ liệu đầu tiên, chưa phải dashboard và không đọc suy nghĩ nội bộ của model.

Tài liệu Antigravity: https://antigravity.google/docs/hooks

## Dữ liệu được ghi

Mỗi dòng JSONL gồm: thời gian UTC, loại event, conversation ID, workspace paths, model name, step index, invocation number, tên tool và cờ báo lỗi.

**Không ghi** nội dung prompt, tool arguments, transcript, API keys hoặc nội dung file. Đây là lựa chọn mặc định để giảm rủi ro lộ dữ liệu.

Log nằm tại:

`%LOCALAPPDATA%\APES\runtime\events-YYYYMMDD.jsonl`

## Cài đặt

Mở PowerShell trong thư mục repo APES đã tải về, sau đó chạy:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Install-APESRuntime.ps1
```

Lệnh chỉ thêm mục `apes-runtime-capture` vào cấu hình Hooks toàn máy. Nó giữ nguyên các hook khác và tạo bản sao lưu nếu `hooks.json` đã tồn tại. Nếu mục APES đã tồn tại, installer dừng; chỉ dùng `-ReplaceExisting` khi muốn thay cấu hình APES cũ.

Sau đó:
1. Mở Antigravity.
2. Vào Settings → Customizations → Hooks.
3. Kiểm tra `apes-runtime-capture` xuất hiện và đang bật.
4. Mở một cuộc trò chuyện thử nghiệm, yêu cầu agent xem một file hoặc chạy một thao tác không phá hủy.
5. Mở thư mục log ở trên. Phải thấy các dòng JSON mới.

## Kiểm tra

Từ thư mục repo APES:

```powershell
.\scripts\Test-APESRuntime.ps1
```

Smoke test xác nhận collector ghi event, trả đúng JSON cho PreToolUse và không lưu tool arguments. Nó **không** chứng minh Antigravity đã nạp hook thành công. Việc đó phải xác minh trong giao diện Hooks và log sau một phiên thực tế.

## Gỡ cài đặt

```powershell
.\scripts\Remove-APESRuntime.ps1
```

Script chỉ xóa mục `apes-runtime-capture`, giữ nguyên các hook khác và tạo backup trước khi ghi lại cấu hình. Log cũ không bị xóa.

## Giới hạn hiện tại

- Đây là runtime event capture, chưa phải live dashboard.
- Sự kiện chỉ cho biết lifecycle/tool metadata được Hooks cung cấp; không có chain-of-thought.
- Việc gán hoạt động cho từng subagent cần kiểm tra xem Antigravity có đưa định danh subagent vào payload/transcript ở phiên bản IDE đang dùng hay không. Không tự suy đoán.
- Hook có thể chạy nhiều lần; dashboard sau này phải đọc JSONL theo kiểu append-only và chịu được duplicate/retry.
- Runtime capture không tự phê duyệt tool. PreToolUse trả `allow` để tiếp tục luồng policy mặc định của Antigravity; không dùng `auto_approve`.

## Quyền riêng tư

Log có đường dẫn workspace và conversation ID. Không chia sẻ log công khai nếu đường dẫn chứa tên người dùng hoặc tên dự án riêng. Có thể xóa log trong `%LOCALAPPDATA%\APES\runtime` khi không cần nữa.
