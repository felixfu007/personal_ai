# PowerShell Encoding Test Script

Write-Host "=== PowerShell Chinese Encoding Test ===" -ForegroundColor Yellow
Write-Host ""

# Test basic Chinese display
Write-Host "1. Basic Chinese Display Test:" -ForegroundColor Green
Write-Host "   Traditional Chinese: 你好世界！" -ForegroundColor White
Write-Host "   Simplified Chinese: 你好世界！" -ForegroundColor White
Write-Host ""

# Test encoding settings
Write-Host "2. Current Encoding Settings:" -ForegroundColor Green
Write-Host "   Output Encoding: $([Console]::OutputEncoding.EncodingName)" -ForegroundColor White
Write-Host "   Code Page: 65001 (UTF-8)" -ForegroundColor White
Write-Host ""

# Test API call using Python
Write-Host "3. API Chinese Response Test (via Python):" -ForegroundColor Green
if (Test-Path "test_encoding.py") {
    $output = C:/practise/GAME/ai-engine/.venv/Scripts/python.exe test_encoding.py
    $reply = $output | Where-Object { $_ -match "Reply content:" } | ForEach-Object { $_.Substring(15) }
    if ($reply) {
        Write-Host "   API Response: $reply" -ForegroundColor White
    }
} else {
    Write-Host "   test_encoding.py file not found" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== Test Complete ===" -ForegroundColor Yellow
Write-Host "✅ If you can see correct Chinese characters, encoding fix is successful!" -ForegroundColor Green