# APES Project Manager — Prompt Pack (Vietnamese)

Dùng Project Manager để tạo kế hoạch chuẩn. Dùng FlowPlan Projection để hiển thị kế hoạch cho người dùng. FlowPlan không phải nơi lưu Master Plan duy nhất.

## 1. Lập kế hoạch dự án và chuẩn bị bảng quan sát

~~~text
# APES PROJECT MANAGER — PLAN FIRST

Mục tiêu dự án:
[ĐIỀN YÊU CẦU]

1. Đọc APES Rules, Skills, Custom Agents và workflow catalog tại config/workflows.json hoặc docs/engineering/apes/config/workflows.json sau khi cài APES.
2. Chọn một workflow có sẵn; giải thích lựa chọn.
3. Kiểm tra workspace, Git status, tài liệu, manifest và tính năng hiện tại.
4. Phân biệt VERIFIED, USER-PROVIDED, ASSUMPTION và UNKNOWN.
5. Tạo/cập nhật:
   - docs/engineering/apes/projects/<slug>/PROJECT_BRIEF.md
   - docs/engineering/apes/projects/<slug>/MASTER_PLAN.md
   - docs/engineering/apes/projects/<slug>/task-graph.json
   - docs/engineering/apes/projects/<slug>/DECISIONS.md khi có quyết định kiến trúc
   - docs/engineering/apes/projects/<slug>/RISKS.md khi dự án có rủi ro đáng kể
   - docs/engineering/apes/projects/<slug>/APPROVALS.md
6. Kiểm tra task ID, milestone ID, owner, acceptance criteria, dependency DAG và critical path.
7. Chạy Plan Quality Audit. Không bỏ qua finding nghiêm trọng.
8. Nếu FlowPlan MCP có sẵn, đọc apes-flowplan-projection skill:
   - list_plans trước khi tạo.
   - tạo bản chiếu dễ hiểu bằng tiếng Việt.
   - tất cả card đang chờ duyệt dùng [REVIEW].
   - lưu plan_id/card_id mapping.
   - get_plan/get_cards readback.
9. Nếu FlowPlan không kết nối, báo MCP_DISCONNECTED và vẫn giữ Master Plan.
10. Trình bày mục tiêu, milestone, tiến độ dự kiến (không bịa %), công việc chính, rủi ro và quyết định cần duyệt.

CHỈ LẬP KẾ HOẠCH VÀ XUẤT BẢN CHIẾU. KHÔNG IMPLEMENT, CÀI PACKAGE, MIGRATE, DEPLOY, COMMIT HAY PUSH.
Dừng chờ tôi duyệt rõ ràng: DUYỆT KẾ HOẠCH.
Không được tuyên bố FlowPlan đã cập nhật nếu tool call và readback chưa thành công.
~~~

## 2. Duyệt kế hoạch

~~~text
DUYỆT KẾ HOẠCH phiên bản/revision đang được trình bày.

1. Đọc lại PROJECT_BRIEF.md, MASTER_PLAN.md và task-graph.json.
2. Xác nhận revision đúng với bản đã trình bày.
3. Ghi rõ approval vào APPROVALS.md.
4. Cập nhật planState thành APPROVED sau khi đã ghi nhận phê duyệt.
5. Cập nhật FlowPlan card từ [REVIEW] thành [TODO] bằng MCP nếu đang kết nối.
6. get_cards readback để xác minh.
7. Chuyển giao cho APES Workflow Engine / FlowPlan Operations.

Không tự bắt đầu hành động ngoài phạm vi được duyệt.
Không commit, push, deploy, publish hoặc xóa dữ liệu.
~~~

## 3. Đồng bộ tiến độ lên FlowPlan

~~~text
# FLOWPLAN — EVIDENCE-BASED PROJECTION SYNC

1. Đọc Master Plan, task-graph.json, FLOWPLAN-MAPPING.json.
2. Gọi list_plans/get_plan/get_cards và get_all_feedback.
3. Đối chiếu trạng thái từng task với Git diff, run state, worker session và test output thực tế.
4. Chỉ cập nhật các thay đổi có evidence.
5. Dùng status prefix [TODO], [DOING], [PASS], [BLOCKED], [REVIEW].
6. Tiêu đề và phần tóm tắt phải bằng tiếng Việt dễ hiểu.
7. Lưu mapping task ID ↔ FlowPlan card ID.
8. get_cards readback sau mỗi batch update.

Không tuyên bố live sync. FlowPlan chỉ được cập nhật tại các checkpoint thực tế.
Không dùng remove_card/clear_plan.
~~~

## 4. Khôi phục khi mất kết nối hoặc mở chat mới

~~~text
# APES — RECONCILE MASTER PLAN AND FLOWPLAN

1. Đọc canonical Project Brief, Master Plan, Task Graph và Mapping.
2. Kiểm tra Git status/diff, run state, test evidence.
3. Gọi list_plans/get_plan/get_cards/get_all_feedback nếu MCP đang khả dụng.
4. So sánh từng task theo canonical ID.
5. Master Plan quyết định scope/dependencies; evidence quyết định execution state.
6. FlowPlan chỉ là bản hiển thị. Không tin [DOING]/[PASS] cũ nếu không xác minh được.
7. Cập nhật sai lệch theo hướng an toàn; card không đủ evidence chuyển [REVIEW] hoặc [BLOCKED].
8. Không tạo duplicate board và không xóa card.
Báo cáo sai lệch, thay đổi đã đồng bộ và điều cần người dùng quyết định.
~~~
