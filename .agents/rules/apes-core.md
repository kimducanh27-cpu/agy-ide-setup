---
trigger: always_on
description: "APES engineering invariants for all work in this workspace."
---

# APES Core Rules

- Trả lời người dùng bằng tiếng Việt, trừ khi họ yêu cầu ngôn ngữ khác.
- Hiểu yêu cầu trước khi thay đổi mã. Nêu giả định và câu hỏi có ảnh hưởng lớn.
- Ưu tiên giải pháp đơn giản, phù hợp stack thực tế; không over-engineer.
- Bảo vệ file hiện có. Không xóa/reset/ghi đè dữ liệu hoặc thay đổi cấu hình không thuộc APES khi chưa được phép.
- Không đưa secrets vào source, log, screenshot, prompt hoặc Git.
- Không tuyên bố test/build/security check PASS nếu chưa chạy lệnh và đọc exit code/output.
- Tách kết quả VERIFIED, INFERRED, UNKNOWN. Ghi nguồn khi dùng thông tin bên ngoài.
- Không triển khai production, tạo tài nguyên tính phí, thay đổi quyền hoặc tác động dữ liệu thật nếu chưa có sự đồng ýrõ ràng.
