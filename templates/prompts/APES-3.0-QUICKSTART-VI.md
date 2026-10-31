# APES 3.0 — Prompt nhanh

## Chọn workflow

- `quick-fix`: sửa lỗi nhỏ.
- `standard-feature`: tính năng thông thường.
- `full-project`: dự án mới end-to-end.
- `deep-research`: nghiên cứu chuyên sâu.
- `hard-review`: phản biện nghiêm khắc, không sửa code.

## Prompt sau khi đã tạo bằng Build-APESPrompt

Hãy đọc toàn bộ prompt này và tuân thủ đúng stage/gate. Trước tiên kiểm tra workspace instructions, git status và cấu trúc dự án. Nếu workflow yêu cầu approval, chỉ lập kế hoạch và dừng. Không được tự chuyển gate bằng cách tự xác nhận approval.

## Kết thúc mỗi stage

Ghi checkpoint qua Manage-APESRun.ps1 với evidence có thể kiểm tra. Nếu không có bằng chứng, không Advance. Nếu bị chặn, ghi Block và nêu chính xác điều kiện cần để tiếp tục.

## Lưu ý

APES 3.0 không thay thế Native Custom Agents, Impeccable hay FlowPlan. Các tích hợp vẫn độc lập và tùy chọn.
