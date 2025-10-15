# 匯入與查詢 RAG 快速腳本
$ingest = @{ namespace="notes"; texts=@(
    "這是一段產品規格：處理器為 8 核心，記憶體 16GB，儲存 512GB。",
    "使用須知：避免高溫環境，定期備份資料。",
    "保固條款：一年內非人為損壞免費維修。"
) } | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8000/rag/ingest -ContentType "application/json" -Body $ingest | ConvertTo-Json

$query = @{ namespace="notes"; question="這台產品的主要規格與注意事項是什麼？"; top_k=3 } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8000/rag/query -ContentType "application/json" -Body $query | ConvertTo-Json
