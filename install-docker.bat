@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ===================================================================
REM Docker Desktop 安裝輔助腳本
REM ===================================================================
REM 功能：協助用戶安裝和配置 Docker Desktop
REM ===================================================================

echo [INFO] 🐳 Docker Desktop 安裝輔助程式
echo [INFO] ================================

REM === 檢查是否已安裝 Docker ===
docker --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] ✅ Docker 已經安裝！
    docker --version
    docker-compose --version 2>nul
    if %ERRORLEVEL% equ 0 (
        echo [SUCCESS] ✅ Docker Compose 也已安裝！
        echo [INFO] 您可以直接使用 docker-start.bat 啟動 AI Engine
        pause
        exit /b 0
    )
)

echo [INFO] ❌ Docker 未安裝或未正確配置

REM === 檢查系統版本 ===
echo [INFO] 🔍 檢查系統需求...

for /f "tokens=4-5 delims=. " %%i in ('ver') do (
    set VERSION=%%i.%%j
)

echo [INFO] Windows 版本: %VERSION%

REM === 檢查 WSL2 (Windows 10/11 Home 需要) ===
wsl --status >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] ✅ WSL2 已安裝
) else (
    echo [INFO] ⚠️ WSL2 未檢測到，某些 Windows 版本需要 WSL2
)

REM === 檢查 Hyper-V (Windows Pro/Enterprise) ===
dism /online /get-featureinfo /featurename:Microsoft-Hyper-V-All >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [INFO] ✅ Hyper-V 功能可用
) else (
    echo [INFO] ℹ️ 未檢測到 Hyper-V（Windows Home 版本正常）
)

echo.
echo [INFO] 📋 Docker Desktop 安裝步驟：
echo.
echo        1. 前往 Docker 官方網站
echo        2. 下載 Docker Desktop for Windows
echo        3. 執行安裝程式
echo        4. 重啟電腦（如需要）
echo        5. 啟動 Docker Desktop
echo        6. 完成初始設定

echo.
set /p OPEN_BROWSER="🌐 是否要開啟 Docker 下載頁面？ (Y/n): "
if /i not "%OPEN_BROWSER%"=="n" (
    echo [INFO] 🌐 正在開啟 Docker 下載頁面...
    start https://www.docker.com/products/docker-desktop/
)

echo.
echo [INFO] 📋 安裝後驗證步驟：
echo.
echo        在命令提示字元中執行：
echo        docker --version
echo        docker run hello-world
echo.
echo        如果看到歡迎訊息，表示安裝成功！

echo.
echo [INFO] 🛠️ 常見問題解決：
echo.
echo        問題：Docker Desktop 啟動失敗
echo        解決：啟用虛擬化功能（BIOS 設定）
echo.
echo        問題：WSL2 錯誤
echo        解決：執行 "wsl --install" 安裝 WSL2
echo.
echo        問題：權限不足
echo        解決：確保使用管理員帳戶執行

echo.
echo [INFO] 🎯 安裝完成後：
echo        執行 .\docker-start.bat 啟動 AI Engine
echo.

pause