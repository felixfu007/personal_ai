#!/usr/bin/env python3
"""
D&D 2024 三聖書 RAG 管理工具
支援合法擁有的 PDF 檔案批量匯入和管理
"""
import os
import sys
import json
import asyncio
from pathlib import Path
from typing import List, Dict, Optional

# 添加應用路徑
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from services.rag_service import ingest_pdf, rag_query

class DnD2024Manager:
    def __init__(self):
        self.dnd_books = {
            'phb2024': {
                'name': '玩家手冊 2024',
                'namespace': 'dnd_phb_2024',
                'description': 'Player\'s Handbook 2024 - 角色創建、職業、法術'
            },
            'dmg2024': {
                'name': '城主指南 2024', 
                'namespace': 'dnd_dmg_2024',
                'description': 'Dungeon Master\'s Guide 2024 - 遊戲主持、世界建構'
            },
            'mm2024': {
                'name': '怪物書 2024',
                'namespace': 'dnd_mm_2024', 
                'description': 'Monster Manual 2024 - 怪物統計、遭遇設計'
            }
        }
        
    def list_available_pdfs(self, pdf_directory: str) -> List[Dict]:
        """掃描指定目錄中的 PDF 檔案"""
        pdf_dir = Path(pdf_directory)
        if not pdf_dir.exists():
            print(f"❌ 目錄不存在: {pdf_directory}")
            return []
            
        pdf_files = []
        for pdf_file in pdf_dir.glob("*.pdf"):
            pdf_files.append({
                'path': str(pdf_file),
                'name': pdf_file.name,
                'size': f"{pdf_file.stat().st_size / (1024*1024):.1f} MB"
            })
            
        return pdf_files
    
    def suggest_namespace(self, filename: str) -> str:
        """根據檔案名建議命名空間"""
        filename_lower = filename.lower()
        
        # 玩家手冊關鍵詞
        if any(keyword in filename_lower for keyword in ['player', 'handbook', 'phb', '玩家', '手冊']):
            return 'dnd_phb_2024'
        # 城主指南關鍵詞    
        elif any(keyword in filename_lower for keyword in ['dungeon', 'master', 'guide', 'dmg', '城主', '指南']):
            return 'dnd_dmg_2024'
        # 怪物書關鍵詞
        elif any(keyword in filename_lower for keyword in ['monster', 'manual', 'mm', '怪物', '圖鑑']):
            return 'dnd_mm_2024'
        else:
            return 'dnd_misc_2024'
    
    def import_pdf(self, pdf_path: str, namespace: Optional[str] = None) -> bool:
        """匯入單個 PDF 檔案"""
        pdf_file = Path(pdf_path)
        if not pdf_file.exists():
            print(f"❌ 檔案不存在: {pdf_path}")
            return False
            
        if not namespace:
            namespace = self.suggest_namespace(pdf_file.name)
            
        print(f"📄 正在匯入: {pdf_file.name}")
        print(f"🏷️ 命名空間: {namespace}")
        
        try:
            with open(pdf_path, 'rb') as f:
                pdf_content = f.read()
                
            # 使用異步函數
            chunks_count = asyncio.run(ingest_pdf(
                namespace=namespace,
                file_content=pdf_content,
                filename=pdf_file.name
            ))
            
            print(f"✅ 成功匯入 {chunks_count} 個文本片段")
            return True
            
        except Exception as e:
            print(f"❌ 匯入失敗: {str(e)}")
            return False
    
    def batch_import(self, pdf_directory: str) -> Dict[str, int]:
        """批量匯入目錄中的所有 PDF"""
        results = {}
        pdf_files = self.list_available_pdfs(pdf_directory)
        
        if not pdf_files:
            print("❌ 未找到 PDF 檔案")
            return results
            
        print(f"📚 找到 {len(pdf_files)} 個 PDF 檔案:")
        for pdf in pdf_files:
            print(f"  - {pdf['name']} ({pdf['size']})")
            
        print("\n🚀 開始批量匯入...")
        
        for pdf in pdf_files:
            namespace = self.suggest_namespace(pdf['name'])
            success = self.import_pdf(pdf['path'], namespace)
            
            if success:
                # 獲取匯入的片段數量 - 重新計算而不是重複匯入
                rag_store_path = Path("rag_store") / f"{namespace}.json"
                if rag_store_path.exists():
                    try:
                        with open(rag_store_path, 'r', encoding='utf-8') as f:
                            data = json.load(f)
                        results[pdf['name']] = len(data)
                    except:
                        results[pdf['name']] = 0
                else:
                    results[pdf['name']] = 0
            else:
                results[pdf['name']] = -1
                
        return results
    
    def list_namespaces(self) -> List[str]:
        """列出所有可用的命名空間"""
        rag_store_path = Path("rag_store")
        if not rag_store_path.exists():
            return []
            
        namespaces = []
        for json_file in rag_store_path.glob("*.json"):
            namespace = json_file.stem
            namespaces.append(namespace)
                    
        return sorted(namespaces)
    
    def get_namespace_stats(self) -> Dict[str, int]:
        """獲取每個命名空間的統計資訊"""
        rag_store_path = Path("rag_store")
        if not rag_store_path.exists():
            return {}
            
        stats = {}
        for json_file in rag_store_path.glob("*.json"):
            namespace = json_file.stem
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                # 檢查資料結構
                if isinstance(data, dict) and 'texts' in data:
                    # 新格式: {'texts': [...], 'embeddings': [...]}
                    stats[namespace] = len(data['texts'])
                elif isinstance(data, list):
                    # 舊格式: [{'text': ..., 'embedding': ...}, ...]
                    stats[namespace] = len(data)
                else:
                    stats[namespace] = 0
            except:
                stats[namespace] = 0
                
        return stats
    
    def query_all_books(self, question: str, top_k: int = 5) -> Dict[str, str]:
        """同時查詢所有三聖書"""
        results = {}
        
        for book_key, book_info in self.dnd_books.items():
            namespace = book_info['namespace']
            try:
                answer, sources = asyncio.run(rag_query(
                    question=question,
                    namespace=namespace,
                    top_k=top_k
                ))
                results[book_info['name']] = answer
            except Exception as e:
                results[book_info['name']] = f"查詢失敗: {str(e)}"
                
        return results

def main():
    print("🎲 D&D 2024 三聖書 RAG 管理工具")
    print("=" * 50)
    
    manager = DnD2024Manager()
    
    # 顯示使用說明
    print("""
📖 使用說明:
1. 將您合法擁有的 D&D 2024 PDF 檔案放在指定目錄
2. 使用此工具批量匯入到 RAG 系統
3. 透過命名空間分類管理不同書籍

⚠️  重要提醒:
- 僅支援您合法購買的 PDF 檔案
- 請勿分享或傳播版權內容
- 僅供個人學習和遊戲使用

📂 建議的目錄結構:
C:/practise/GAME/ai-engine/dnd_2024_books/
  ├── Players_Handbook_2024.pdf
  ├── Dungeon_Masters_Guide_2024.pdf
  └── Monster_Manual_2024.pdf
""")
    
    # 檢查現有命名空間
    namespaces = manager.list_namespaces()
    if namespaces:
        print(f"\n📊 現有命名空間: {', '.join(namespaces)}")
        
        stats = manager.get_namespace_stats()
        for ns, count in stats.items():
            print(f"  - {ns}: {count} 個文本片段")
    
    # 互動式選單
    while True:
        print(f"\n🎯 請選擇操作:")
        print("1. 掃描指定目錄的 PDF 檔案")
        print("2. 匯入單個 PDF 檔案") 
        print("3. 批量匯入目錄中的所有 PDF")
        print("4. 查詢所有三聖書")
        print("5. 顯示命名空間統計")
        print("0. 退出")
        
        choice = input("\n請輸入選項 (0-5): ").strip()
        
        if choice == "0":
            print("👋 再見！")
            break
        elif choice == "1":
            directory = input("請輸入 PDF 目錄路徑: ").strip()
            pdfs = manager.list_available_pdfs(directory)
            if pdfs:
                for pdf in pdfs:
                    suggested_ns = manager.suggest_namespace(pdf['name'])
                    print(f"  - {pdf['name']} ({pdf['size']}) -> {suggested_ns}")
        elif choice == "2":
            pdf_path = input("請輸入 PDF 檔案完整路徑: ").strip()
            namespace = input("請輸入命名空間 (留空自動判斷): ").strip() or None
            manager.import_pdf(pdf_path, namespace)
        elif choice == "3":
            directory = input("請輸入 PDF 目錄路徑: ").strip()
            results = manager.batch_import(directory)
            print(f"\n📊 批量匯入結果:")
            for filename, count in results.items():
                if count > 0:
                    print(f"  ✅ {filename}: {count} 個片段")
                elif count == 0:
                    print(f"  ⚠️ {filename}: 已存在或無內容")
                else:
                    print(f"  ❌ {filename}: 匯入失敗")
        elif choice == "4":
            question = input("請輸入您的問題: ").strip()
            if question:
                print("\n🔍 查詢所有三聖書...")
                results = manager.query_all_books(question)
                for book_name, answer in results.items():
                    print(f"\n📚 {book_name}:")
                    print(f"   {answer[:200]}..." if len(answer) > 200 else f"   {answer}")
        elif choice == "5":
            stats = manager.get_namespace_stats()
            print(f"\n📊 命名空間統計:")
            for ns, count in stats.items():
                print(f"  - {ns}: {count} 個文本片段")

if __name__ == "__main__":
    main()