# APES 3.2 — nâng cấp an toàn

3.2 không thêm tính năng mới. Nó sửa đúng một thứ: **nâng cấp APES không được phá việc anh đã làm.**

Trước 3.2, installer ghi đè mọi thứ và không biết file nào là của mình. Hệ quả: sửa tay một rule thì mất khi cài lại; một rule bị đổi tên vẫn nằm lại **và vẫn có hiệu lực**; không có cách nào biết bản cài đang lệch gì so với repo.

## Manifest

`Install-APES.ps1` giờ ghi `.agents/apes-install.json` với **hash của từng file nó đã cài** (75 file với một bản cài dự án).

~~~json
{
  "schemaVersion": 2,
  "version": "3.2.0",
  "root": "D:\\Projects\\MyApp",
  "files": [ { "path": ".agents\\rules\\apes-core.md", "hash": "2d3c9eb6..." } ]
}
~~~

Hai chi tiết quan trọng:

- **Hash chuẩn hoá CRLF → LF trước khi tính.** Git trên Windows đổi kiểu xuống dòng khi checkout; hash thô sẽ báo mọi file là "đã bị sửa" sau mỗi lần clone.
- **Manifest ghi hash của nội dung APES đã cài, không phải hash trên đĩa.** Nếu ghi hash sau khi anh sửa, lần nâng cấp sau nó coi bản sửa đó là của mình rồi ghi đè.

## Lệnh

~~~powershell
# Xem trước, không ghi gì
.\scripts\Update-APES.ps1 -ProjectPath "D:\Projects\MyApp" -DryRun

# Áp dụng
.\scripts\Update-APES.ps1 -ProjectPath "D:\Projects\MyApp"

# Xoá luôn file mồ côi
.\scripts\Update-APES.ps1 -ProjectPath "D:\Projects\MyApp" -Prune
~~~

`-Scope` mặc định là `Project`. Muốn toàn máy phải nói `-Scope Global`.

## Ba loại file, ba cách xử lý

| Tình huống | Hành vi |
|---|---|
| File APES cài, anh không sửa, bản mới khác | Cập nhật (backup trước) |
| File APES cài, **anh đã sửa** | **Giữ nguyên**, in ra danh sách. `-Force` mới ghi đè |
| File APES từng cài, bản mới không còn | Báo là mồ côi. `-Prune` mới xoá |

File mồ côi **vẫn được ghi vào manifest** cho tới khi bị prune — nếu không, lần chạy sau sẽ không thấy nó nữa và `-Prune` chẳng có gì để xoá.

## Migration từ 3.0

Bản 3.0 không có manifest. Lần đầu chạy `Update-APES.ps1` trên một bản cài cũ:

1. Không thấy manifest → **nhận quyền sở hữu** những file có đường dẫn trùng với bản mới, ghi nhận nội dung hiện tại của chúng.
2. Từ đó mới so sánh được. Không làm bước này thì mọi file đều bị coi là "anh sửa" và **không bao giờ nâng cấp được gì**.

## Kiểm chứng

`scripts/Test-APESUpgrade.ps1` dựng tình huống thật rồi khẳng định:

- cài sạch → manifest có đủ file và hash
- sửa tay một file → nâng cấp → **file sửa còn nguyên**
- tạo file mồ côi → nâng cấp → **bị báo, không bị xoá**
- nâng cấp lần nữa → **bản ghi mồ côi vẫn còn**
- `-Prune` → xoá đúng file mồ côi, **không đụng file anh sửa**
- `-DryRun` → **không ghi gì**

13 khẳng định, chạy trong ~20 giây, tự dọn thư mục tạm.

## Thay đổi hành vi phải biết

- `Install-APES.ps1` mặc định `-Scope Project` (trước là `All`). Chạy không tham số giờ chỉ cài vào một dự án.
- `Restore-APES.ps1` **từ chối** khôi phục ra ngoài phạm vi cho phép (thư mục dự án và `~/.gemini/config`). Một manifest lạ không ghi được vào `C:\Windows`.
- `Install-Impeccable.ps1` ghim theo **commit** `414603b` thay vì tag `skill-v4.8.0` — tag là nhãn có thể bị di chuyển.
