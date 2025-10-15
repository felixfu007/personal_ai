@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM Docker 配置驗證腳本
REM ===================================================================
REM 功能：在不實際運行 Docker 的情況下驗證配置文件
REM ===================================================================

echo [INFO] 🔍 Docker 配置驗證程序
echo [INFO] ========================

echo [INFO] 檢查 Docker 配置文件...

REM === 檢查必要文件 ===
set MISSING_FILES=0

if not exist "docker-compose.yml" (
    echo [ERROR] ❌ docker-compose.yml 不存在
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ docker-compose.yml 存在
)

if not exist "ai-engine\Dockerfile" (
    echo [ERROR] ❌ ai-engine\Dockerfile 不存在
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ ai-engine\Dockerfile 存在
)

if not exist "ai-engine-frontend\Dockerfile" (
    echo [ERROR] ❌ ai-engine-frontend\Dockerfile 不存在  
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ ai-engine-frontend\Dockerfile 存在
)

if not exist "scripts\init-models.sh" (
    echo [ERROR] ❌ scripts\init-models.sh 不存在
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ scripts\init-models.sh 存在
)

REM === 檢查啟動腳本 ===
if not exist "docker-start.bat" (
    echo [ERROR] ❌ docker-start.bat 不存在
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ docker-start.bat 存在
)

if not exist "docker-stop.bat" (
    echo [ERROR] ❌ docker-stop.bat 不存在
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ docker-stop.bat 存在
)

if not exist "docker-restart.bat" (
    echo [ERROR] ❌ docker-restart.bat 不存在
    set MISSING_FILES=1
) else (
    echo [SUCCESS] ✅ docker-restart.bat 存在
)

echo.
if %MISSING_FILES% equ 0 (
    echo [SUCCESS] 🎉 所有 Docker 配置文件都存在！
) else (
    echo [ERROR] ❌ 缺少一些必要的配置文件
    echo [INFO] 請確保所有文件都已正確創建
    pause
    exit /b 1
)

echo.
echo [INFO] 📋 配置檢查摘要：
echo         - Docker Compose: docker-compose.yml
echo         - 後端容器: ai-engine/Dockerfile  
echo         - 前端容器: ai-engine-frontend/Dockerfile
echo         - 模型初始化: scripts/init-models.sh
echo         - 管理腳本: docker-*.bat

echo.
echo [INFO] 🎯 下一步：
echo         1. 安裝 Docker Desktop
echo         2. 啟動 Docker Desktop 
echo         3. 執行 docker-start.bat
echo         4. 訪問 http://localhost:8080

echo.
echo [INFO] 💡 驗證命令（安裝 Docker 後執行）：
echo         docker-compose config --quiet
echo         docker-compose build --dry-run

pause