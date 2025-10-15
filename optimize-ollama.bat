@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM Ollama 性能優化設定腳本
REM ===================================================================
REM 功能：設定 Ollama 環境變數以優化性能
REM 建議：在啟動 start-all.bat 之前執行此腳本
REM ===================================================================

echo [INFO] 🚀 設定 Ollama 性能優化參數...

REM === 設定環境變數 ===
set OLLAMA_HOST=http://localhost:11434
set OLLAMA_MAX_LOADED_MODELS=2
set OLLAMA_NUM_PARALLEL=4
set OLLAMA_FLASH_ATTENTION=1

REM === 檢查 GPU 記憶體 ===
set OLLAMA_MAX_VRAM=6

echo [INFO] ✅ 環境變數設定完成：
echo         - OLLAMA_HOST: %OLLAMA_HOST%
echo         - OLLAMA_MAX_LOADED_MODELS: %OLLAMA_MAX_LOADED_MODELS%
echo         - OLLAMA_NUM_PARALLEL: %OLLAMA_NUM_PARALLEL%
echo         - OLLAMA_MAX_VRAM: %OLLAMA_MAX_VRAM%GB
echo         - OLLAMA_FLASH_ATTENTION: %OLLAMA_FLASH_ATTENTION%

echo.
echo [INFO] 🎯 建議使用的模型（依速度排序）：
echo         1. qwen2.5:3b     - 最快，適合日常對話
echo         2. gemma3:4b      - 平衡速度與品質
echo         3. llama3.1:8b    - 最準確，但較慢

echo.
echo [INFO] 💡 優化提示：
echo         - 保持模型預載入（避免重複載入）
echo         - 使用較短的提示詞
echo         - 限制最大回覆長度
echo         - 關閉不必要的背景程式

echo.
echo [INFO] 🚀 現在您可以執行 start-all.bat 來啟動優化後的服務！

pause
endlocal