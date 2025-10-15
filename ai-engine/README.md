# Personal AI Engine (Local)

一個可在 Windows 本機執行的「個人 AI 引擎」範例：
- 推薦使用 [Ollama](https://ollama.com) 下載開源 LLM（如 `llama3.1:8b`）
- 提供 FastAPI 介面：`/healthz`、`/chat`、`/rag/*`
- 可選 RAG：使用 Ollama Embeddings + 本地 JSON 向量庫（無需 C++ 編譯）

## 1) 先決條件
- Windows 10/11
- Python 3.10+（建議 3.11）
- 網卡可用（本機 HTTP 服務）

## 2) 安裝步驟（PowerShell）

```powershell
# 2.1 建立虛擬環境
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# 2.2 安裝相依（基礎）
pip install --upgrade pip
pip install -r requirements.txt

# 2.3 安裝與啟動 Ollama（若尚未安裝）
# 造訪 https://ollama.com/download 下載 Windows 安裝程式並安裝
# 安裝後，啟動 Ollama 服務（預設會在背景執行 http://localhost:11434）

# 2.4 下載模型（以 llama3.1:8b 為例）
ollama pull llama3.1:8b

# 2.5 啟動 API 伺服器
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

> 若 PowerShell 禁止執行腳本，請以系統管理員權限執行：
> `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 3) 使用方式
- 健康檢查
  - GET http://localhost:8000/healthz
- 對話
  - POST http://localhost:8000/chat
  - JSON Body:
    ```json
    {"prompt":"你好，幫我總結這段話","model":"llama3.1:8b"}
    ```
- RAG（可選）
  - 啟用：不需安裝額外套件，確保 Ollama 可用並提供 embeddings 模型（預設 `nomic-embed-text`）。
  - `.env` 可設定：
    ```
    OLLAMA_HOST=http://127.0.0.1:11434
    OLLAMA_MODEL=qwen2.5:3b
    EMBED_MODEL=nomic-embed-text
    RAG_STORE_DIR=rag_store
    ```
  - 請先拉 embeddings 模型：
    ```powershell
    & "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" pull nomic-embed-text
    ```
  - Ingest: POST http://localhost:8000/rag/ingest
    ```json
    {"namespace":"notes","texts":["第一段...","第二段..."]}
    ```
  - Query（會把檢索 context 串進 LLM 回覆）: POST http://localhost:8000/rag/query
    ```json
    {"namespace":"notes","question":"重點是?","top_k":3}
    ```

## 4) 設定
- OLLAMA_HOST（預設 http://localhost:11434）
- OLLAMA_MODEL（預設 llama3.1:8b）
- USE_CHROMA（設 1 啟用 RAG）
- CHROMA_PATH（預設 `chroma`）
- EMBED_MODEL（預設 `all-MiniLM-L6-v2`）

可以建立 `.env` 檔放於專案根目錄，內容例如：
```
OLLAMA_MODEL=llama3.1:8b
USE_CHROMA=1
```

## 5) 附註
- `chat` 端點會直接呼叫本機 Ollama Chat API，請先確保 Ollama 正在執行且已下載模型。
- 若要支援 GPU，請依 GPU 與驅動狀態參考 Ollama 官方說明，或改用支援 CUDA 的模型變體。
 - 預設會使用繁體中文系統提示；你可在請求 body 的 `system` 欄位覆寫。

## 5.1) 測試（可選）
```powershell
pip install pytest
pytest -q
```

## 6) 後續可加值功能
- Web 前端（例如 React/Vue）
- 多模型切換、系統提示模板
- 記憶（會話歷史）與檔案上傳
- 角色/權限、API Key 保護
- Docker 化與遠端部署
