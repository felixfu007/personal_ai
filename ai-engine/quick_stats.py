#!/usr/bin/env python3
"""
快速檢查 RAG 資料統計
"""
import os
import json
from pathlib import Path

def quick_stats():
    """快速統計 RAG 資料"""
    rag_store_path = Path("rag_store")
    
    if not rag_store_path.exists():
        print("❌ rag_store 目錄不存在")
        return
        
    print("📊 RAG 資料統計")
    print("=" * 40)
    
    total_chunks = 0
    
    for json_file in rag_store_path.glob("*.json"):
        namespace = json_file.stem
        file_size = json_file.stat().st_size / (1024 * 1024)  # MB
        
        try:
            # 嘗試讀取 JSON 內容
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                
            # 檢查資料結構
            if isinstance(data, dict) and 'texts' in data:
                # 新格式: {'texts': [...], 'embeddings': [...]}
                chunk_count = len(data['texts'])
            elif isinstance(data, list):
                # 舊格式: [{'text': ..., 'embedding': ...}, ...]
                chunk_count = len(data)
            else:
                chunk_count = 0
            
            print(f"📁 {namespace}")
            print(f"   📄 檔案大小: {file_size:.1f} MB")
            print(f"   📝 文本片段: {chunk_count:,} 個")
            print(f"   📍 檔案路徑: {json_file}")
            print()
            
            total_chunks += chunk_count
            
        except Exception as e:
            print(f"❌ 讀取 {namespace} 失敗: {str(e)}")
    
    print(f"🎯 總計: {total_chunks:,} 個文本片段")

if __name__ == "__main__":
    quick_stats()