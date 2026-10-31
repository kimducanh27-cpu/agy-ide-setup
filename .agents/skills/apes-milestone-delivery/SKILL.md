---
name: apes-milestone-delivery
description: "Executes approved work in verifiable milestones with tests, independent review, capped remediation and evidence-based reporting."
---

# APES Milestone Delivery

## Trigger
Khi thực hiện feature, bug fix, refactor hoặc release đã được duyệt.

1. Chọn milestone nhỏ; xác định scope và exit criteria.
2. Đọc relevant code, tests, rules và memory trước khi sửa.
3. Nếu native subagents có sẵn, delegate các nhiệm vụ hẹp (research, implementation, review). Nếu không, thực hiện role passes tuần thựvà công khai giới hạn.
4. Thực hiện thay đổi nhỏ; viết/revise tests phù hợp.
5. Chạy lint/type/build/test/security phù hợp stack và ghi output thực tế.
6. Tạo diff summary; yêu cầu review độc lập.
7. Đưa scorecard cho evaluator.
8. Nếu reject: sửa tối đa 3 vòng cùng lỗi; quá giới hạn thì dừng và báo trỺ.
9. Cập nhật milestone và memory bằng bài học có thể xác minh.
