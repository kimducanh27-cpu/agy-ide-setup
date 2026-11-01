---
name: apes-project-bootstrap
description: "Bootstraps a new software project by gathering requirements, researching technology, designing architecture and creating approval artifacts before implementation."
---

# APES Project Bootstrap

## Trigger

Dùng khi bắt đầu dự án mới, mở workspace chưa rõ cấu trúc hoặc chuẩn bị một feature lớn.

## Procedure

1. Inventory workspace và git status; không sửa file ở bước này.
2. Ghi mục tiêu, người dùng, use cases, constraints và out-of-scope.
3. Chuyển yêu cầu thành acceptance criteria có thể kiểm thử.
4. Kích hoạt các role skill phù hợp: BA, Product, CTO, Architect và Researcher.
5. Nghiên cứu stack theo bằng chứng, không mặc định framework.
6. Tạo architecture/ADR, quality plan, milestone plan và risk register.
7. Chạy pre-code validation và trình bày báo cáo tiếng Việt.
8. Chờ user approval trong chat trước khi code sản phẩm.

## Outputs

Tạo bộ hồ sơ bootstrap từ `docs/engineering/apes/bootstrap/00-project-brief.md` đến `docs/engineering/apes/bootstrap/06-approval.md`.

## Stop conditions

Dừng và hỏi người dùng khi có quyết định làm thay đổi scope, bảo mật, chi phí, dịch vụ bên ngoài, quyền truy cập dữ liệu, quyền thực thi hoặc deployment.
