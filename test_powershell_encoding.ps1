# PowerShell 中文編碼測試腳本

Write-Host "=== PowerShell 中文編碼測試 ===" -ForegroundColor Yellow
Write-Host ""

# 測試基本中文顯示
Write-Host "1. 基本中文顯示測試：" -ForegroundColor Green
Write-Host "   繁體中文：你好世界！" -ForegroundColor White
Write-Host "   簡體中文：你好世界！" -ForegroundColor White
Write-Host ""

# 測試編碼設置
Write-Host "2. 當前編碼設置：" -ForegroundColor Green
Write-Host "   輸出編碼：$([Console]::OutputEncoding.EncodingName)" -ForegroundColor White
Write-Host "   代碼頁：$(Get-Host | Select-Object -ExpandProperty CurrentCulture | Select-Object -ExpandProperty TextInfo | Select-Object -ExpandProperty ANSICodePage)" -ForegroundColor White
Write-Host ""

# 測試 API 調用（使用 Python 腳本）
Write-Host "3. API 中文響應測試（透過 Python）：" -ForegroundColor Green
if (Test-Path "test_encoding.py") {
    C:/practise/GAME/ai-engine/.venv/Scripts/python.exe test_encoding.py | Select-Object -Last 3
} else {
    Write-Host "   test_encoding.py 檔案不存在" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== 測試完成 ===" -ForegroundColor Yellow
Write-Host "✅ 如果您能看到正確的中文字符，編碼修復已成功！" -ForegroundColor Green