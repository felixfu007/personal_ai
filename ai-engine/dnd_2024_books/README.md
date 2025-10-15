# 📁 D&D 2024 PDF 檔案目錄

這個目錄用於存放您合法擁有的 D&D 2024 版本 PDF 檔案。

## ⚠️ 重要提醒

**僅放置您合法購買的 PDF 檔案！**

- ✅ 從官方管道購買的電子版本
- ✅ 您擁有使用權的檔案
- ❌ 任何盜版或非法複製的檔案

## 📚 建議的檔案命名

為了讓系統正確識別檔案類型，建議使用包含關鍵詞的檔案名：

### 玩家手冊 (Player's Handbook)
- `Players_Handbook_2024.pdf`
- `DnD_PHB_2024.pdf`
- `Player_Handbook_2024.pdf`

### 城主指南 (Dungeon Master's Guide)
- `Dungeon_Masters_Guide_2024.pdf`
- `DnD_DMG_2024.pdf`
- `DM_Guide_2024.pdf`

### 怪物書 (Monster Manual)
- `Monster_Manual_2024.pdf`
- `DnD_MM_2024.pdf`
- `Monsters_2024.pdf`

## 🔍 自動識別規則

管理工具會根據檔案名中的關鍵詞自動分類到適當的命名空間：

| 關鍵詞 | 命名空間 | 用途 |
|--------|----------|------|
| player, handbook, phb | `dnd_phb_2024` | 玩家手冊內容 |
| dungeon, master, guide, dmg | `dnd_dmg_2024` | 城主指南內容 |
| monster, manual, mm | `dnd_mm_2024` | 怪物書內容 |

## 📖 使用步驟

1. **放置檔案**: 將您的 PDF 檔案複製到此目錄
2. **執行工具**: 運行 `python dnd_2024_manager.py`
3. **選擇批量匯入**: 選項 3，輸入此目錄路徑
4. **開始查詢**: 匯入完成後即可查詢內容

## 🚀 快速開始

```bash
# 啟動虛擬環境
& ./.venv/Scripts/Activate.ps1

# 執行管理工具  
python dnd_2024_manager.py

# 選擇批量匯入 (選項 3)
# 輸入路徑: C:/practise/GAME/ai-engine/dnd_2024_books
```

準備好您的檔案後，就可以享受智能 D&D 查詢體驗了！ 🎲