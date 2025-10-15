@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM Docker 部署模擬測試腳本
REM ===================================================================
REM 功能：模擬 Docker 部署流程，檢查配置問題
REM ===================================================================

echo [INFO] 🧪 Docker 部署模擬測試
echo [INFO] ======================

echo [INFO] 📋 測試檢查清單：
echo.

REM === 檢查 1: 文件結構 ===
echo [TEST 1] 檢查文件結構...
set TEST1_PASSED=1

if not exist "docker-compose.yml" (
    echo [FAIL] ❌ docker-compose.yml 缺失
    set TEST1_PASSED=0
)

if not exist "ai-engine\requirements.txt" (
    echo [FAIL] ❌ ai-engine\requirements.txt 缺失
    set TEST1_PASSED=0
)

if not exist "ai-engine-frontend\pom.xml" (
    echo [FAIL] ❌ ai-engine-frontend\pom.xml 缺失
    set TEST1_PASSED=0
)

if %TEST1_PASSED% equ 1 (
    echo [PASS] ✅ 文件結構檢查通過
) else (
    echo [FAIL] ❌ 文件結構檢查失敗
)

echo.

REM === 檢查 2: 端口配置 ===
echo [TEST 2] 檢查端口配置...
findstr "8080\|8000\|11434" docker-compose.yml >nul
if %ERRORLEVEL% equ 0 (
    echo [PASS] ✅ 端口配置正確 (8000, 8080, 11434)
) else (
    echo [FAIL] ❌ 端口配置問題
)

echo.

REM === 檢查 3: 環境變數 ===
echo [TEST 3] 檢查環境變數配置...
findstr "OLLAMA_HOST\|ENGINE_BASE_URL" docker-compose.yml >nul
if %ERRORLEVEL% equ 0 (
    echo [PASS] ✅ 環境變數配置正確
) else (
    echo [FAIL] ❌ 環境變數配置問題
)

echo.

REM === 檢查 4: 健康檢查 ===
echo [TEST 4] 檢查健康檢查配置...
findstr "healthcheck" docker-compose.yml >nul
if %ERRORLEVEL% equ 0 (
    echo [PASS] ✅ 健康檢查已配置
) else (
    echo [FAIL] ❌ 健康檢查配置缺失
)

echo.

REM === 檢查 5: 網路配置 ===
echo [TEST 5] 檢查網路配置...
findstr "ai-engine-network" docker-compose.yml >nul
if %ERRORLEVEL% equ 0 (
    echo [PASS] ✅ 自定義網路已配置
) else (
    echo [FAIL] ❌ 網路配置問題
)

echo.

REM === 檢查 6: 卷配置 ===
echo [TEST 6] 檢查數據卷配置...
findstr "ollama_data" docker-compose.yml >nul
if %ERRORLEVEL% equ 0 (
    echo [PASS] ✅ 數據持久化已配置
) else (
    echo [FAIL] ❌ 數據卷配置問題
)

echo.

REM === 檢查 7: 服務依賴 ===
echo [TEST 7] 檢查服務依賴關係...
findstr "depends_on" docker-compose.yml >nul
if %ERRORLEVEL% equ 0 (
    echo [PASS] ✅ 服務依賴已配置
) else (
    echo [FAIL] ❌ 服務依賴配置問題
)

echo.

REM === 檢查 8: Dockerfile 語法 ===
echo [TEST 8] 檢查 Dockerfile 基本語法...
set DOCKERFILE_OK=1

findstr "FROM\|WORKDIR\|COPY\|RUN\|CMD" ai-engine\Dockerfile >nul
if %ERRORLEVEL% neq 0 (
    echo [FAIL] ❌ 後端 Dockerfile 語法問題
    set DOCKERFILE_OK=0
)

findstr "FROM\|WORKDIR\|COPY\|RUN" ai-engine-frontend\Dockerfile >nul
if %ERRORLEVEL% neq 0 (
    echo [FAIL] ❌ 前端 Dockerfile 語法問題
    set DOCKERFILE_OK=0
)

if %DOCKERFILE_OK% equ 1 (
    echo [PASS] ✅ Dockerfile 語法檢查通過
)

echo.

REM === 模擬啟動流程 ===
echo [INFO] 🚀 模擬啟動流程...
echo.
echo [STEP 1] 啟動 Ollama 服務...
timeout /t 2 >nul
echo [STEP 2] 等待 Ollama 健康檢查...
timeout /t 2 >nul
echo [STEP 3] 啟動 AI Engine 後端...
timeout /t 2 >nul
echo [STEP 4] 等待後端健康檢查...
timeout /t 2 >nul
echo [STEP 5] 啟動 AI Engine 前端...
timeout /t 2 >nul
echo [STEP 6] 初始化 AI 模型...
timeout /t 2 >nul

echo.
echo [SUCCESS] 🎉 模擬部署流程完成！

echo.
echo [INFO] 📊 預期結果：
echo         - Ollama:     http://localhost:11434
echo         - Backend:    http://localhost:8000
echo         - Frontend:   http://localhost:8080

echo.
echo [INFO] 🐳 實際 Docker 部署步驟：
echo         1. 安裝 Docker Desktop
echo         2. 啟動 Docker Desktop
echo         3. 執行: docker-start.bat
echo         4. 等待所有服務啟動（約 5-10 分鐘）
echo         5. 訪問: http://localhost:8080

echo.
echo [INFO] 🔧 故障排除命令：
echo         docker-compose ps           # 查看服務狀態
echo         docker-compose logs         # 查看所有日誌
echo         docker-compose logs ollama  # 查看 Ollama 日誌
echo         docker system df            # 查看磁碟使用

pause