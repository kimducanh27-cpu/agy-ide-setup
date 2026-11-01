# Tích hợp tùy chọn: mattpocock/skills

[github.com/mattpocock/skills](https://github.com/mattpocock/skills) là thư mục `.agents` thật của Matt Pocock — 39 skill đang dùng hằng ngày, không phải sinh hàng loạt.

APES **không vendor** bộ này. Nó được cài riêng, giữ license riêng (MIT), và cập nhật độc lập — cùng nguyên tắc với Impeccable.

## Vì sao không vendor

`AGENTS.md` của repo APES ghi rõ: skill bên ngoài phải *"separately licensed and independently installed"*. Vendor vào repo nghĩa là APES phải bảo trì nội dung của người khác, và không bao giờ nhận được bản sửa upstream.

## Cài

~~~powershell
# 27 skill ổn định (engineering + productivity)
.\scripts\Install-MattSkills.ps1 -Scope Project -ProjectPath "D:\Projects\MyApp"

# Cả 39, gồm cả nhóm chưa xong và nhóm đã đóng băng
.\scripts\Install-MattSkills.ps1 -Scope Project -ProjectPath "D:\Projects\MyApp" -Set All

# Kiểm tra
.\scripts\Test-MattSkills.ps1 -Scope Project -ProjectPath "D:\Projects\MyApp"
~~~

Mặc định `-Set Stable` = 27 skill. `-Set All` = 39.

## Hai nhóm không nên lấy

| Nhóm | Số | Vì sao |
|---|---:|---|
| `in-progress/` | 8 | Chưa xong. Có `software-factory`, `chief-of-staff` — đang thử nghiệm |
| `misc/` | 4 | `SCOPE.md` của upstream gọi là *"frozen and unmaintained"* |

`-Set Stable` bỏ cả hai nhóm này.

## Ràng buộc: cần subagent thật

Ba skill chỉ đúng khi runtime có giao việc thật:

- `code-review` — chạy **hai subagent song song** (trục Standards và trục Spec), mỗi cái một context riêng, rồi tổng hợp.
- `implement-spec` — giao việc cho nhiều implementer trên "ready frontier".
- `research` — chạy như background agent.

Trên runtime không có `invoke_subagent`, chúng thoái hoá thành "tự làm hai lượt rồi tự tổng hợp" — mất đúng lý do tồn tại. APES trên Antigravity App/CLI có delegation thật, nên chạy đúng; trên IDE cần kiểm tra trước.

## Skill phụ thuộc issue tracker

`triage`, `to-spec`, `to-tickets`, `wayfinder` cần biết issue tracker của dự án. Chạy `/setup-matt-pocock-skills` một lần cho mỗi repo. Không có tracker thì `code-review` vẫn chạy nhưng trục Spec sẽ báo "no spec available".

## Xung đột tên

Không có. APES dùng tiền tố `apes-` và `role-`; bộ này dùng tên trần (`code-review`, `tdd`, `handoff`). Cài chung một thư mục `.agents/skills/` không ghi đè nhau.

## Cập nhật

Installer ghim theo **commit** `4ae2317`, không theo branch — branch di chuyển, commit thì không. Muốn lên bản mới thì sửa `$Ref` trong `Install-MattSkills.ps1` và chạy lại. Skill cũ được backup vào `%LOCALAPPDATA%\APES\backups\matt-skills-<timestamp>\` trước khi thay.

## Kiểm chứng

`Test-MattSkills.ps1` đọc marker `.agents/matt-skills.json` (do installer ghi) và xác nhận từng skill trong danh sách có mặt, có `SKILL.md`, và `name:` trong frontmatter khớp tên thư mục. Không khớp thì Antigravity đăng ký skill dưới một tên còn marker theo dõi tên khác.
