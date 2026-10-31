---
trigger: model_decision
description: "Use when completing a milestone, reviewing code, evaluating test results, or preparing a release."
---

# APES Quality Gate

- Reviewer phải so acceptance criteria với diff và test evidence.
- Tác giả thay đổi không được là reviewer duy nhất cho thay đổi bảo mật, dữ liệu, kiến trúc hoặc release.
- Ghi rõ lệnh đã chạy, kết quả và những kiểm tra chưa chạy.
- Tối đa ba vòng tự sửa cho cùng lỗi; nếu vẫn lỗi, dừng và escalation.
- Evaluator phải độc lập, đưa ra verdict PASS, REJECT hoặc NEEDS_HUMAN_REVIEW dựa trên acceptance criteria và evidence. Không tự sửa hoặc tự approve.
- Kiểm tra chưa chạy phải ghi NOT_RUN; không suy diễn thành PASS.
