@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM AI Engine Docker 停止腳本
REM ===================================================================
REM 功能：停止所有 Docker 容器和清理資源
REM ===================================================================

echo [INFO] 🐳 Stopping AI Engine Docker Services...
echo [INFO] =======================================

REM === 檢查 Docker 是否可用 ===
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Docker is not available
    pause
    exit /b 1
)

REM === 顯示當前運行的服務 ===
echo [INFO] 📊 Current services status:
docker-compose ps

echo.
echo [INFO] 🛑 Stopping all services...

REM === 優雅停止服務 ===
docker-compose stop

if %ERRORLEVEL% neq 0 (
    echo [WARN] ⚠️ Some services may not have stopped gracefully
)

echo [INFO] ⏳ Removing containers...

REM === 移除容器 ===
docker-compose down

if %ERRORLEVEL% neq 0 (
    echo [ERROR] ❌ Failed to remove containers
    echo [INFO] You may need to remove them manually:
    echo         docker-compose down --remove-orphans
    pause
    exit /b 1
)

echo [SUCCESS] ✅ All containers stopped and removed

REM === 詢問是否清理映像和卷 ===
echo.
set /p CLEANUP="🗑️ Do you want to clean up Docker images and volumes? (y/N): "
if /i "%CLEANUP%"=="y" (
    echo [INFO] 🧹 Cleaning up Docker resources...
    
    REM 移除未使用的映像
    docker image prune -f
    
    REM 詢問是否移除卷（包含模型數據）
    echo.
    set /p CLEANUP_VOLUMES="⚠️ Remove model data volumes? This will delete downloaded AI models (y/N): "
    if /i "%CLEANUP_VOLUMES%"=="y" (
        docker-compose down -v
        echo [INFO] 🗑️ Volumes removed (models will be re-downloaded on next start)
    ) else (
        echo [INFO] 💾 Volumes preserved (models will be available on next start)
    )
    
    echo [SUCCESS] ✅ Cleanup completed
) else (
    echo [INFO] 💾 Keeping Docker images and volumes
)

echo.
echo [INFO] 📋 Resource usage after cleanup:
docker system df

echo.
echo [SUCCESS] 🎉 AI Engine Docker environment stopped!
echo [INFO] ========================================
echo [INFO] 🚀 To start again: docker-start.bat
echo [INFO] 🔍 To check status: docker-compose ps
echo [INFO] 📝 To view logs: docker-compose logs

endlocal
pause