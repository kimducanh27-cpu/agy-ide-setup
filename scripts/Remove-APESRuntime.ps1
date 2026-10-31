[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$hooksPath = Join-Path (Join-Path $HOME '.gemini\config') 'hooks.json'
if (-not (Test-Path -LiteralPath $hooksPath)) {
    Write-Host 'Không có hooks.json; không cần gỡ APES Runtime.' -ForegroundColor Yellow
    exit 0
}
$config = Get-Content -LiteralPath $hooksPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ($null -eq $config.PSObject.Properties['apes-runtime-capture']) {
    Write-Host 'Không tìm thấy apes-runtime-capture; không thay đổi cấu hình.' -ForegroundColor Yellow
    exit 0
}
$backup = $hooksPath + '.before-apes-remove-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.bak'
Copy-Item -LiteralPath $hooksPath -Destination $backup
$config.PSObject.Properties.Remove('apes-runtime-capture')
$temp = Join-Path $env:TEMP ('apes-hooks-remove-' + [guid]::NewGuid().ToString('N') + '.json')
$config | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $temp -Encoding UTF8
Move-Item -LiteralPath $temp -Destination $hooksPath -Force
Write-Host "Đã gỡ hook APES. Backup: $backup" -ForegroundColor Green
Write-Host 'Log cũ vẫn được giữ tại %LOCALAPPDATA%\APES\runtime; hãy tự xóa nếu không còn cần.'
