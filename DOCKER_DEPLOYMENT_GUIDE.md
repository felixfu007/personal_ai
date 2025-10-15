# 🐳 AI Engine Docker 容器化指南

## 📋 概述

本專案現已支援完整的 Docker 容器化部署，提供一鍵啟動的 AI 引擎環境。包含：
- **Ollama** - AI 模型服務
- **AI Engine Backend** - Python FastAPI 後端
- **AI Engine Frontend** - Spring Boot 前端

## 🛠️ 前置需求

### 1. 安裝 Docker Desktop
- **下載**: [Docker Desktop](https://www.docker.com/products/docker-desktop)
- **系統需求**: Windows 10/11 Pro/Enterprise 或 Windows 10/11 Home (需啟用 WSL2)
- **記憶體**: 建議至少 8GB RAM
- **磁碟空間**: 至少 10GB 可用空間

### 2. 驗證安裝
```powershell
# 檢查 Docker 版本
docker --version

# 檢查 Docker Compose 版本  
docker-compose --version

# 測試 Docker 是否正常運行
docker run hello-world
```

## 🚀 快速開始

### 方式一：使用腳本（推薦）
```batch
# 啟動所有服務
.\docker-start.bat

# 停止所有服務
.\docker-stop.bat

# 重啟所有服務
.\docker-restart.bat
```

### 方式二：使用 Docker Compose 命令
```powershell
# 啟動服務
docker-compose up -d

# 查看服務狀態
docker-compose ps

# 查看日誌
docker-compose logs -f

# 停止服務
docker-compose down
```

## 🎯 服務端點

| 服務 | 端口 | 用途 |
|------|------|------|
| Frontend | 8080 | 🖥️ 主要使用界面 |
| Backend API | 8000 | 🔧 後端 API 服務 |
| Ollama | 11434 | 🤖 AI 模型服務 |

- **主要入口**: http://localhost:8080
- **API 文檔**: http://localhost:8000/docs
- **健康檢查**: http://localhost:8080/actuator/health

## 📁 檔案結構

```
AI-ENGINE/
├── docker-compose.yml          # Docker Compose 主配置
├── docker-start.bat           # 啟動腳本
├── docker-stop.bat            # 停止腳本  
├── docker-restart.bat         # 重啟腳本
├── scripts/
│   └── init-models.sh          # 模型初始化腳本
├── ai-engine/
│   ├── Dockerfile              # 後端容器配置
│   └── .dockerignore           # Docker 忽略文件
├── ai-engine-frontend/
│   ├── Dockerfile              # 前端容器配置
│   └── .dockerignore           # Docker 忽略文件
└── models/                     # 模型檔案目錄（自動創建）
```

## ⚙️ 配置說明

### Docker Compose 配置
- **網路**: 自定義橋接網路 (172.20.0.0/16)
- **數據卷**: 模型數據持久化儲存
- **健康檢查**: 自動監控服務狀態
- **依賴管理**: 服務啟動順序控制

### 環境變數
```yaml
# Ollama 配置
OLLAMA_HOST: http://ollama:11434
OLLAMA_MAX_LOADED_MODELS: 2
OLLAMA_NUM_PARALLEL: 4

# 後端配置  
OLLAMA_MODEL: qwen2.5:3b

# 前端配置
ENGINE_BASE_URL: http://ai-engine-backend:8000
JAVA_OPTS: -Xmx1g -Xms512m
```

## 🔧 進階操作

### 查看容器狀態
```powershell
# 查看所有容器
docker-compose ps

# 查看資源使用
docker stats

# 查看特定服務日誌
docker-compose logs ai-engine-backend
docker-compose logs ai-engine-frontend
docker-compose logs ollama
```

### 重建映像
```powershell
# 重建所有映像
docker-compose build

# 重建特定服務
docker-compose build ai-engine-backend

# 強制重建（忽略快取）
docker-compose build --no-cache
```

### 模型管理
```powershell
# 查看已下載的模型
docker exec -it ai-engine-ollama ollama list

# 下載新模型
docker exec -it ai-engine-ollama ollama pull llama3.1:8b

# 測試模型
docker exec -it ai-engine-ollama ollama run qwen2.5:3b "你好"
```

## 📊 效能優化

### 記憶體配置
- **Ollama**: 自動根據可用記憶體調整
- **Spring Boot**: 預設 1GB 堆疊記憶體
- **總需求**: 建議至少 6GB 可用記憶體

### 磁碟空間
- **基礎映像**: ~2GB
- **AI 模型**: 2-8GB（依模型大小）
- **建議**: 至少 15GB 可用空間

### CPU 最佳化
- **多核心支援**: 自動偵測並使用所有可用核心
- **背景處理**: Docker 自動負載平衡

## 🛠️ 故障排除

### 常見問題

1. **Docker 未啟動**
   ```
   解決: 確保 Docker Desktop 正在運行
   檢查: Windows 系統托盤中的 Docker 圖示
   ```

2. **端口被佔用**
   ```powershell
   # 檢查端口使用狀況
   netstat -ano | findstr "8080\|8000\|11434"
   
   # 停止衝突的服務
   .\stop-all.bat  # 停止本地版本
   ```

3. **記憶體不足**
   ```yaml
   # 調整 docker-compose.yml 中的記憶體限制
   environment:
     - JAVA_OPTS=-Xmx512m -Xms256m  # 減少記憶體使用
   ```

4. **模型下載失敗**
   ```powershell
   # 手動下載模型
   docker exec -it ai-engine-ollama ollama pull qwen2.5:3b
   
   # 檢查網路連接
   docker exec -it ai-engine-ollama curl -I http://ollama.ai
   ```

### 日誌檢查
```powershell
# 查看所有服務日誌
docker-compose logs

# 實時監控日誌
docker-compose logs -f

# 查看最近50行日誌
docker-compose logs --tail=50

# 檢查特定服務
docker-compose logs ai-engine-backend
```

### 完整重置
```powershell
# 停止並移除所有容器、網路
docker-compose down

# 移除所有相關映像
docker image rm $(docker images "ai-engine*" -q)

# 清理系統
docker system prune -f

# 重新開始
.\docker-start.bat
```

## 🆚 Docker vs 傳統部署對比

| 特性 | Docker 版本 | 傳統版本 |
|------|-------------|----------|
| 🚀 **部署速度** | 一鍵啟動 | 需多步驟配置 |
| 🔧 **環境依賴** | 容器內包含 | 需本地安裝 |
| 📦 **可移植性** | 極高 | 中等 |
| 🛠️ **維護成本** | 低 | 中等 |
| 💾 **資源使用** | 較高 | 較低 |
| 🐛 **除錯容易度** | 中等 | 高 |

## 💡 最佳實踐

### 開發環境
```powershell
# 使用 Docker 進行開發
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

### 生產環境
```powershell
# 使用優化的生產配置
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 備份與恢復
```powershell
# 備份模型數據
docker run --rm -v ai-engine_ollama_data:/data -v $(pwd):/backup alpine tar czf /backup/models-backup.tar.gz -C /data .

# 恢復模型數據
docker run --rm -v ai-engine_ollama_data:/data -v $(pwd):/backup alpine tar xzf /backup/models-backup.tar.gz -C /data
```

## 🎉 總結

Docker 容器化版本提供了：
- ✅ **簡化部署** - 一鍵啟動完整環境
- ✅ **環境隔離** - 避免依賴衝突
- ✅ **可擴展性** - 易於水平擴展
- ✅ **一致性** - 開發/測試/生產環境一致
- ✅ **可移植性** - 可在任何支援 Docker 的系統運行

現在您可以選擇最適合的部署方式：
- **Docker 版本**: 適合快速部署和生產環境
- **傳統版本**: 適合開發和偵錯

---

**🚀 開始使用**: `.\docker-start.bat`  
**📚 更多幫助**: 查看項目根目錄下的其他文檔