@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM AI Engine Docker 重啟腳本
REM ===================================================================
REM 功能：重啟所有 Docker 服務
REM ===================================================================

echo [INFO] 🔄 Restarting AI Engine Docker Services...
echo [INFO] ========================================

REM === 檢查 Docker 是否可用 ===
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Docker is not available
    pause
    exit /b 1
)

echo [INFO] Step 1/2: Stopping services...
docker-compose down

echo [INFO] Step 2/2: Starting services...
docker-compose up -d

if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Failed to restart services
    pause
    exit /b 1
)

echo [INFO] ⏳ Waiting for services to be ready...
timeout /t 10 >nul

echo [INFO] 📊 Service Status:
docker-compose ps

echo.
echo [SUCCESS] ✅ AI Engine restarted successfully!
echo [INFO] 🌐 Frontend: http://localhost:8080
echo [INFO] 🔧 Backend:  http://localhost:8000
echo [INFO] 🤖 Ollama:   http://localhost:11434

echo.
echo [INFO] 🌐 Opening frontend in browser...
start http://localhost:8080

endlocal
pause