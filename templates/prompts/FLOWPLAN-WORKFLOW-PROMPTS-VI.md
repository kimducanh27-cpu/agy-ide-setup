# APES × FlowPlan — Prompt Pack (Vietnamese)

Dùng các prompt theo đúng thứ tự. FlowPlan phải đang mở và MCP phải được Antigravity nạp thành công. Không prompt nào được phép giả vờ đã gọi tool.

## 0. Preflight — kiểm tra kết nối, không sửa dữ liệu

~~~text
Kiểm tra FlowPlan MCP ở chế độ READ-ONLY.

1. Kiểm tra FlowPlan tools có thực sự khả dụng.
2. Gọi list_plans.
3. Đọc kết quả thật và liệt kê các plan hiện có.
4. Xác nhận các công cụ đọc được: list_plans, get_plan, get_cards, get_all_feedback.
5. Không gọi create_plan, add_cards, update_card, remove_card hoặc clear_plan.
6. Không thay đổi file dự án.

Báo rõ:
- MCP_CONNECTED: YES/NO
- list_plans: kết quả thực tế
- Các tool đọc được
- Lỗi gặp phải
- Hướng xử lý nếu chưa kết nối

Không được coi việc nhìn thấy cấu hình JSON là bằng chứng MCP đã kết nối.
~~~

## 1. Plan — nghiên cứu và tạo bảng, chưa code

~~~text
# APES FLOWPLAN — PLANNING MODE

Dự án/yêu cầu:
[ĐIỀN YÊU CẦU]

Mục tiêu: nghiên cứu, phân rã công việc và tạo task graph trên FlowPlan. Tuyệt đối chưa chỉnh sửa code sản phẩm.

A. Khảo sát
- Kiểm tra workspace root, Git status, branch và thay đổi chưa commit.
- Đọc README, manifests, cấu hình và hướng dẫn hiện có.
- Xác định stack, kiến trúc và test commands thực tế.
- Nghiên cứu GitHub và tài liệu chính thức cho quyết định kỹ thuật quan trọng.
- Gọi specialist subagents cho phần độc lập nếu native runtime thực sự có thể khởi chạy chúng. Nếu không, ghi rõ chưa có independent subagent.

B. Phân rã
Mỗi card phải có:
- Prefix [TODO], title, card_type.
- Objective và expected output.
- Acceptance criteria có thể kiểm chứng.
- Files/modules liên quan.
- Agent/skill/MCP cần thiết nếu có.
- Dependency có lý do rõ ràng.
- Cách kiểm tra và rủi ro.

Chia task đủ nhỏ để một card có thể được implement và verify độc lập. Đừng gộp cả feature lớn thành một card.

C. FlowPlan
- Gọi list_plans trước, tránh tạo plan trùng.
- Nếu có plan đang hoạt động đúng dự án, báo plan đó và hỏi có tiếp tục dùng không; không xóa hoặc clear.
- Nếu cần plan mới, gọi create_plan.
- Gọi add_cards theo graph hợp lệ. FlowPlan yêu cầu card sau card đầu tiên phải có dependency. Dùng $0, $1... đúng theo card tạo cùng lần gọi; tạo root/foundation rõ ràng rồi mới tạo nhánh.
- Không tạo dependency vòng hoặc dependency giả.
- Lưu plan_id và map card_id.
- Gọi get_plan/get_cards để đọc lại và xác minh card count, title, type, files và dependencies.

D. Dừng
Trình bày kiến trúc, các phase, task graph, số card, rủi ro, criteria và plan_id.
DỪNG SAU KHI TẠO BẢNG.
Không code, cài package, migration, deploy, publish hoặc xóa dữ liệu.
Chỉ tiếp tục khi tôi gửi: DUYỆT KẾ HOẠCH.
Không được nói đã tạo bảng nếu MCP tool call không thành công.
~~~

## 2. Approve — bắt đầu kế hoạch đã duyệt

~~~text
DUYỆT KẾ HOẠCH. Hãy bắt đầu kế hoạch FlowPlan hiện tại.

1. Gọi list_plans, xác định đúng plan đã duyệt.
2. Gọi get_plan/get_cards và đọc lại dependencies.
3. Kiểm tra get_all_feedback.
4. Đối chiếu Git status và workspace thực tế.
5. Chỉ chọn card có tất cả dependency [PASS].
6. Không thay đổi phạm vi đã duyệt.

Dùng APES FlowPlan Operations skill và thực hiện theo vòng lặp:
[TODO] → [DOING] → IMPLEMENT → VERIFY → REVIEW → [PASS].

Sau mỗi card, bắt buộc kiểm thử, đọc diff, review độc lập khi khả dụng, cập nhật mô tả bằng bằng chứng và đọc lại card để xác nhận.
Mặc định tự chuyển sang card tiếp theo chỉ khi card trước đã [PASS] được xác minh.
Nếu BLOCKED, lỗi nghiêm trọng, scope thay đổi hoặc không thể xác minh thì dừng và báo tôi.
Không tự commit/push/deploy/publish.
~~~

## 3. Execute — thực thi từng card và kiểm tra bắt buộc

~~~text
# APES FLOWPLAN — ONE-CARD EXECUTION LOOP

Chỉ thực hiện một card tại một thời điểm.

PRE-CHECK:
1. Gọi get_plan/get_cards và get_all_feedback.
2. Kiểm tra dependencies; mọi prerequisite bắt buộc phải [PASS].
3. Chọn card [TODO] đầu tiên đủ điều kiện.
4. Gọi update_card để đổi prefix thành [DOING], ghi thời điểm/mục tiêu.
5. Gọi get_cards để xác nhận đã lưu [DOING].
6. Nếu update/readback lỗi, dừng trước khi sửa code.

IMPLEMENT:
- Chỉ sửa phạm vi card.
- Ghi nhận file thay đổi và quyết định kỹ thuật.
- Dùng subagent chỉ khi runtime thực sự khởi chạy được.
- Không ghi nội dung file_changes giả làm bằng chứng code đã tồn tại.

VERIFY AFTER IMPLEMENTATION:
1. So acceptance criteria với kết quả thật.
2. Kiểm tra git diff và danh sách file.
3. Đọc manifest/config để tìm đúng lệnh lint/typecheck/test/build.
4. Chạy các test phù hợp và ghi exit code/output.
5. Kiểm tra lỗi logic, edge cases và regression.
6. Yêu cầu QA/reviewer read-only review nếu agent phù hợp khả dụng.
7. Phân biệt rõ independent review với self-review.
8. Nếu FAIL: sửa trong phạm vi rồi chạy lại test liên quan. Tối đa 3 vòng remediation cho cùng defect; quá giới hạn chuyển [BLOCKED].

FINISH:
- Nếu tất cả criteria đạt: update_card title [PASS] và ghi summary, files, test commands/results, review, known issues, NOT_RUN.
- Nếu chưa đạt: update_card [BLOCKED] hoặc [REVIEW] với nguyên nhân/bằng chứng.
- Gọi get_cards/get_plan đọc lại và xác nhận title + description đã được lưu.
- Chỉ card có trạng thái [PASS] và evidence mới được xem là hoàn thành.
- Báo cáo card, files, tests, review và FlowPlan readback.
- Chỉ sau readback thành công mới tiếp tục card đủ dependency.

Không tuyên bố PASS khi test chưa chạy, không tự tạo kết quả, không chuyển task phụ thuộc qua card BLOCKED.
~~~

## 4. Verify — kiểm tra lại card hiện tại, không chuyển bước

~~~text
DỪNG task tiếp theo. Chỉ audit card vừa làm.

1. Đọc card và acceptance criteria từ FlowPlan.
2. Đối chiếu với code/files thực tế và Git diff.
3. Chạy lại test commands phù hợp, đọc exit code và output.
4. Kiểm tra edge cases, regression và các tiêu chí chưa được bao phủ.
5. Nếu QA subagent được runtime khởi chạy thật, lấy review read-only; nếu không, đánh dấu self-review.
6. Nếu lỗi: không PASS, ghi [BLOCKED] hoặc sửa trong phạm vi rồi retest.
7. Nếu đạt: ghi [PASS] cùng đầy đủ evidence.
8. Gọi update_card rồi get_cards để xác minh lưu thành công.

Không thay đổi card khác. Không bắt đầu card tiếp theo.
Báo kết luận PASS / BLOCKED / REVIEW và các bằng chứng.
~~~

## 5. Manual checkpoint — dừng sau mỗi card để tôi duyệt

~~~text
BẬT MANUAL CHECKPOINT MODE.

Sau mỗi card:
- Thực hiện đầy đủ implementation, test, review và FlowPlan readback.
- Nếu đạt, cập nhật [PASS].
- Báo cáo file thay đổi, lệnh test, output và vấn đề còn lại.
- DỪNG ngay sau card đó.

Không tự bắt đầu card tiếp theo.
Chỉ tiếp tục khi tôi gửi: TIẾP TỤC.
Nếu card BLOCKED thì không được tiếp tục dù tôi chưa trả lời.
~~~

## 6. Resume — tiếp tục sau khi mở chat hoặc app lại

~~~text
# APES FLOWPLAN — SAFE RESUME

Không tạo plan mới ngay.

1. Xác nhận FlowPlan đang chạy và MCP tools khả dụng.
2. Gọi list_plans; tìm plan khớp project hiện tại.
3. Gọi get_plan/get_cards và get_all_feedback.
4. Kiểm tra Git status, diff, các file thật và test evidence.
5. Đối chiếu card [DOING] cũ với workspace; không giả định agent trước vẫn đang chạy.
6. Card nào không thể xác minh thì đổi [REVIEW], không tự đổi [PASS].
7. Kiểm tra mọi dependency trước khi chọn task.
8. Tiếp tục card [TODO] đầu tiên đủ điều kiện.

Không tạo duplicate plan, không clear plan, không xóa card và không lặp lại các thay đổi đã có.
Báo plan_id, card đang tiếp tục, trạng thái và các điểm chưa chắc chắn.
~~~

## 7. Feedback — đọc và xử lý phản hồi trên bảng

~~~text
Kiểm tra FlowPlan feedback bằng get_all_feedback.

- Question: điều tra rồi trả lời bằng answer_feedback.
- Directive: xác định có nằm trong scope đã duyệt không; xử lý xong mới acknowledge_feedback.
- Issue: điều tra, ghi evidence, sửa nếu được duyệt; chỉ acknowledge sau khi xử lý.
- Yêu cầu đổi kiến trúc, phạm vi, bảo mật, dữ liệu, chi phí hoặc production: dừng và trình người dùng duyệt.

Sau khi xử lý, đọc lại feedback và xác nhận kết quả.
Không acknowledge chỉ để xóa thông báo.
~~~

## 8. Final audit — nghiệm thu toàn dự án

~~~text
# APES FLOWPLAN — FINAL PROJECT AUDIT

1. Đọc get_plan/get_cards, kiểm tra mọi card và dependencies.
2. Liệt kê mọi card chưa [PASS], [BLOCKED] hoặc [REVIEW].
3. Đọc toàn bộ Git diff và kiểm tra file ngoài scope.
4. Chạy lint, typecheck, unit/integration tests và production build phù hợp dự án.
5. Kiểm tra UI/responsive/accessibility và runtime khi có frontend.
6. Yêu cầu security/QA/reviewer độc lập khi phù hợp; không giả vờ subagent chạy.
7. Ghi rõ PASS/FAIL/NOT_RUN, exit code, output và known issues.
8. Cập nhật FlowPlan summary và xác minh readback.
9. Chỉ tuyên bố hoàn thành nếu các acceptance criteria bắt buộc đạt.

Không tự commit, push, release, deploy hoặc xóa bảng/kế hoạch.
~~~

## Các lệnh ngắn để dùng hằng ngày

- DUYỆT KẾ HOẠCH — bắt đầu kế hoạch đã duyệt.
- TIẾP TỤC — cho phép card tiếp theo khi bật Manual Checkpoint Mode.
- VERIFY CARD HIỆN TẠI — kiểm tra lại card mới nhất.
- CHECK FLOWPLAN — kiểm tra kết nối và trạng thái board.
- TẠM DỪNG — dừng trước khi nhận card mới, giữ nguyên dữ liệu.
- FINAL AUDIT — nghiệm thu toàn dự án.
