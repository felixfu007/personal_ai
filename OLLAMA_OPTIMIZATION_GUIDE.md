# 🚀 Ollama 速度優化完全指南

## 📊 當前系統配置
- **CPU**: AMD Ryzen 7 PRO 5850U (8核心)
- **記憶體**: ~14GB RAM  
- **GPU**: 整合顯卡 (無獨立 GPU)
- **已安裝模型**: qwen2.5:3b (1.9GB), gemma3:4b (3.3GB), llama3.1:8b (4.9GB)

## ⚡ 已實施的優化

### 1. **模型選擇優化** ✅
- **變更前**: 預設使用 `llama3.1:8b` (4.9GB)
- **變更後**: 預設使用 `qwen2.5:3b` (1.9GB)
- **預期提升**: 速度提升 2-3 倍

### 2. **參數調優** ✅
```python
"options": {
    "num_ctx": 2048,        # 減少 context window
    "top_k": 20,           # 限制候選詞數量  
    "top_p": 0.9,          # nucleus sampling
    "repeat_penalty": 1.1,  # 避免重複
    "num_thread": 8        # 使用全部 CPU 核心
}
```

### 3. **前端界面更新** ✅
- 更新模型選擇提示，推薦使用快速模型
- 新增速度標示：🚀 快速 | ⚖️ 平衡 | 🎯 精確

## 🎯 額外優化建議

### A. **環境變數優化**
在啟動服務前設定以下環境變數：
```batch
# 執行 optimize-ollama.bat 自動設定
set OLLAMA_MAX_LOADED_MODELS=2
set OLLAMA_NUM_PARALLEL=4  
set OLLAMA_FLASH_ATTENTION=1
set OLLAMA_MAX_VRAM=6
```

### B. **硬體建議**
1. **記憶體**: 
   - 確保有足夠 RAM (建議 16GB+)
   - 關閉不必要的背景程式
   
2. **儲存裝置**:
   - 使用 SSD 儲存模型檔案
   - 定期清理暫存檔案

3. **CPU 優化**:
   - 設定高效能電源模式
   - 確保 CPU 散熱良好

### C. **模型管理策略**

#### 🚀 **高速模型** (建議日常使用)
- `qwen2.5:3b` - 中文優化，最快
- `gemma3:4b` - Google 開發，品質佳

#### ⚖️ **平衡模型** (品質與速度兼顧)  
- `llama3.1:8b` - 使用場景：複雜問題、長文本生成

#### 📝 **使用建議**
```
簡單對話/問答     → qwen2.5:3b  (預估 3-8 秒)
複雜分析/創作     → gemma3:4b   (預估 8-15 秒)  
專業工作/翻譯     → llama3.1:8b (預估 15-30 秒)
```

### D. **提示詞優化**
1. **簡潔明確** - 避免冗長描述
2. **分段處理** - 長問題拆分成多個短問題
3. **限制長度** - 設定適當的 max_tokens

### E. **系統級優化**

#### Windows 效能調整:
```batch
# 設定高效能模式
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# 優化記憶體管理  
bcdedit /set increaseuserva 3072
```

#### 關閉不必要服務:
- Windows 搜尋索引
- 自動更新 (暫時)
- 防毒軟體即時掃描 (調整為低優先級)

## 📈 效能監控

### 測試命令:
```powershell
# 測試當前模型速度
$start = Get-Date
# ... API 呼叫 ...
$duration = (Get-Date - $start).TotalSeconds
Write-Host "回應時間: $duration 秒"
```

### 預期改善:
- **優化前**: 15-30 秒 (llama3.1:8b)
- **優化後**: 3-8 秒 (qwen2.5:3b)
- **提升幅度**: 60-80% 速度提升

## 🛠️ 故障排除

### 如果速度仍然慢:
1. **檢查模型載入**:
   ```bash
   ollama ps  # 查看當前載入的模型
   ```

2. **重新載入模型**:
   ```bash
   ollama stop <model_name>
   ollama run <model_name>
   ```

3. **清理快取**:
   ```bash
   # 重啟 Ollama 服務
   taskkill /f /im ollama.exe
   # 重新啟動
   ```

## 🎉 使用方式

1. **執行優化**: `.\optimize-ollama.bat`
2. **重啟服務**: `.\restart-all.bat`  
3. **測試速度**: 在前端選擇 `qwen2.5:3b` 模型
4. **監控效能**: 觀察回應時間變化

---

**💡 提醒**: 速度與品質往往需要平衡，根據實際需求選擇合適的模型！