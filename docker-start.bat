@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM AI Engine Docker 啟動腳本
REM ===================================================================
REM 功能：使用 Docker Compose 啟動完整的 AI 引擎環境
REM 包含：Ollama、AI Engine 後端、AI Engine 前端
REM ===================================================================

echo [INFO] 🐳 Starting AI Engine with Docker Compose...
echo [INFO] ============================================

REM === 檢查 Docker 是否安裝 ===
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Docker is not installed or not running.
    echo         Please install Docker Desktop and make sure it's running.
    echo         Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Docker Compose is not installed.
    echo         Please install Docker Compose.
    pause
    exit /b 1
)

echo [INFO] ✅ Docker and Docker Compose are available

REM === 檢查 Docker 服務狀態 ===
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Docker daemon is not running.
    echo         Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo [INFO] ✅ Docker daemon is running

REM === 設定執行權限（Linux/Mac 腳本） ===
if exist "scripts\init-models.sh" (
    echo [INFO] 🔧 Setting execute permissions for init script...
    docker run --rm -v "%~dp0scripts:/scripts" alpine chmod +x /scripts/init-models.sh
)

REM === 啟動服務 ===
echo [INFO] 🚀 Starting all services...
echo [INFO] This may take a few minutes on first run to download images and models...

docker-compose up -d

if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Failed to start services
    echo [INFO] Checking logs...
    docker-compose logs --tail=50
    pause
    exit /b 1
)

echo [INFO] ⏳ Waiting for services to be healthy...

REM === 等待健康檢查 ===
set /a RETRY_COUNT=0
set /a MAX_RETRIES=60

:wait_loop
docker-compose ps | findstr "healthy" >nul
if %ERRORLEVEL% equ 0 (
    set /a HEALTHY_COUNT=0
    for /f %%i in ('docker-compose ps ^| findstr "healthy" ^| find /c /v ""') do set HEALTHY_COUNT=%%i
    if !HEALTHY_COUNT! geq 3 (
        goto :services_ready
    )
)

set /a RETRY_COUNT+=1
if !RETRY_COUNT! gtr !MAX_RETRIES! (
    echo [WARN] ⚠️ Services are taking longer than expected to start
    echo [INFO] You can check the status manually with: docker-compose ps
    echo [INFO] View logs with: docker-compose logs
    goto :show_status
)

timeout /t 5 >nul
echo [INFO] Still waiting... (!RETRY_COUNT!/!MAX_RETRIES!)
goto :wait_loop

:services_ready
echo [SUCCESS] ✅ All services are healthy and ready!

:show_status
echo.
echo [INFO] 📊 Service Status:
docker-compose ps

echo.
echo [SUCCESS] 🎉 AI Engine is now running!
echo [INFO] ============================================
echo [INFO] 🌐 Frontend:  http://localhost:8080
echo [INFO] 🔧 Backend:   http://localhost:8000  
echo [INFO] 🤖 Ollama:    http://localhost:11434
echo [INFO] ============================================
echo.
echo [INFO] 💡 Useful commands:
echo         docker-compose logs         - View all logs
echo         docker-compose logs -f      - Follow logs in real-time
echo         docker-compose down         - Stop all services
echo         docker-compose restart      - Restart all services
echo.

REM === 自動開啟瀏覽器 ===
echo [INFO] 🌐 Opening frontend in browser...
timeout /t 3 >nul
start http://localhost:8080

echo [INFO] 🎯 Setup complete! Enjoy your AI Engine!

endlocal
pause