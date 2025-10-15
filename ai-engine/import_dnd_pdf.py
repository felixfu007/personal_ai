#!/usr/bin/env python3
"""
直接處理 PDF 檔案並匯入到 RAG 系統的腳本
"""

import sys
import os
import asyncio

# 添加 app 目錄到 Python 路徑
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from app.services.rag_service import ingest_pdf

async def process_pdf():
    """處理 SRD_CC_v5.2.1.pdf 檔案"""
    pdf_path = r"C:\practise\GAME\ai-engine\rag_store\dnd_pdf\SRD_CC_v5.2.1.pdf"
    namespace = "dnd_srd"
    
    if not os.path.exists(pdf_path):
        print(f"❌ 找不到 PDF 檔案: {pdf_path}")
        return
    
    print(f"📄 開始處理 PDF 檔案: {os.path.basename(pdf_path)}")
    print(f"🏷️ 命名空間: {namespace}")
    
    try:
        # 讀取 PDF 檔案
        with open(pdf_path, 'rb') as f:
            file_content = f.read()
        
        print(f"📦 檔案大小: {len(file_content) / 1024 / 1024:.2f} MB")
        
        # 處理並匯入 PDF
        chunks_count = await ingest_pdf(namespace, file_content, os.path.basename(pdf_path))
        
        print(f"✅ PDF 處理完成！")
        print(f"📊 共匯入 {chunks_count} 個文本片段")
        print(f"🔍 您現在可以在 RAG 查詢中使用命名空間 '{namespace}' 來搜尋相關內容")
        
    except Exception as e:
        print(f"❌ 處理失敗: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    # 設置環境變數
    os.environ.setdefault("OLLAMA_HOST", "http://localhost:11434")
    os.environ.setdefault("RAG_STORE_DIR", "rag_store")
    
    print("🚀 D&D SRD PDF 匯入工具")
    print("=" * 50)
    
    asyncio.run(process_pdf())