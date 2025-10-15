@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM AI Engine Restart Script
REM ===================================================================
REM 功能：重新啟動 AI 引擎的前端和後端服務
REM 作者：自動生成
REM 日期：2025-10-14
REM 
REM 使用方式：
REM   直接執行此腳本即可重啟所有服務
REM   
REM 操作流程：
REM   1. 呼叫 stop-all.bat 停止所有服務
REM   2. 等待 5 秒讓服務完全關閉
REM   3. 呼叫 start-all.bat 重新啟動服務
REM   4. 自動開啟瀏覽器
REM ===================================================================

echo [INFO] 🔄 Restarting AI Engine (Frontend/Backend)
echo [INFO] ================================

REM === Step 1: Stop all services ===
echo [INFO] Step 1/2: Stopping all services...
call "%~dp0stop-all.bat"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to stop services properly.
    echo [WARN] Continuing with restart anyway...
)

echo.
echo [INFO] Waiting 5 seconds before restart...
timeout /t 5 >nul

REM === Step 2: Start all services ===
echo [INFO] Step 2/2: Starting all services...
echo [INFO] ================================
call "%~dp0start-all.bat"

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] ✅ AI Engine restart completed successfully!
    echo [INFO] 🌐 Backend: http://127.0.0.1:8000
    echo [INFO] 🖥️  Frontend: http://127.0.0.1:8080
) else (
    echo.
    echo [ERROR] ❌ Failed to start services properly.
    echo [INFO] Please check the error messages above.
    echo [INFO] You can try running start-all.bat manually.
)

echo.
echo [INFO] Restart operation completed.
endlocal
exit /b %ERRORLEVEL%