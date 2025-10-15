@echo off
chcp 65001 >nul
title 快速 Docker 測試腳本

echo ==================================================
echo            快速 Docker 部署測試
echo ==================================================

echo.
echo [1/6] 檢查 Docker 是否已安裝...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker 未安裝或未啟動
    echo.
    echo 請先安裝 Docker Desktop：
    echo - 下載地址：https://www.docker.com/products/docker-desktop/
    echo - 安裝後重啟電腦
    echo - 確保 Docker Desktop 正在運行
    echo.
    echo 安裝完成後再次運行此腳本
    pause
    exit /b 1
)
echo ✅ Docker 已安裝

echo.
echo [2/6] 檢查 Docker Compose 配置...
if not exist "docker-compose.yml" (
    echo ❌ 找不到 docker-compose.yml 文件
    pause
    exit /b 1
)
echo ✅ Docker Compose 配置文件存在

echo.
echo [3/6] 檢查必要的 Dockerfile...
if not exist "ai-engine\Dockerfile" (
    echo ❌ 找不到 ai-engine/Dockerfile
    pause
    exit /b 1
)

if not exist "ai-engine-frontend\Dockerfile" (
    echo ❌ 找不到 ai-engine-frontend/Dockerfile
    pause
    exit /b 1
)
echo ✅ 所有 Dockerfile 都存在

echo.
echo [4/6] 停止可能存在的舊容器...
docker-compose down --remove-orphans >nul 2>&1

echo.
echo [5/6] 構建並啟動服務...
echo 這可能需要幾分鐘時間，請耐心等待...
echo.

docker-compose up --build -d

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 啟動失敗，請檢查錯誤信息
    pause
    exit /b 1
)

echo.
echo [6/6] 檢查服務狀態...
timeout /t 5 >nul
docker-compose ps

echo.
echo ==================================================
echo              服務狀態檢查
echo ==================================================

echo.
echo 正在等待服務啟動...（約需 30 秒）
timeout /t 30 >nul

echo.
echo 檢查 AI Engine 後端健康狀態...
curl -f http://localhost:8000/healthz --connect-timeout 5 --max-time 10 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ AI Engine 後端運行正常
) else (
    echo ⚠️  AI Engine 後端可能還在啟動中
)

echo.
echo 檢查前端服務...
curl -f http://localhost:8080/actuator/health --connect-timeout 5 --max-time 10 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ 前端服務運行正常
) else (
    echo ⚠️  前端服務可能還在啟動中
)

echo.
echo ==================================================
echo              部署完成
echo ==================================================
echo.
echo 📱 前端界面：http://localhost:8080
echo 🔧 後端 API：http://localhost:8000
echo 📊 後端文檔：http://localhost:8000/docs
echo 🏥 健康檢查：http://localhost:8000/healthz
echo 🤖 Ollama API：http://localhost:11434
echo.
echo 💡 提示：
echo - 首次啟動可能需要下載 Ollama 模型，請耐心等待
echo - 如果服務沒有正常啟動，請運行 'docker-compose logs' 查看日誌
echo - 要停止服務，請運行 'docker-compose down'
echo.

set /p choice="是否要在瀏覽器中打開前端界面？(Y/N): "
if /i "%choice%"=="Y" (
    start http://localhost:8080
)

echo.
echo 部署測試完成！
pause