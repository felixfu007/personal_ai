#!/usr/bin/env python3
"""
測試 D&D SRD RAG 查詢功能
"""

import sys
import os
import asyncio

# 添加 app 目錄到 Python 路徑
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from app.services.rag_service import rag_query

async def test_dnd_query():
    """測試 D&D SRD 查詢"""
    namespace = "dnd_srd"
    questions = [
        "什麼是戰士職業？",
        "法師可以學會哪些咒語？",
        "龍的種類有哪些？",
        "如何計算傷害擲骰？"
    ]
    
    print("🎲 D&D SRD RAG 查詢測試")
    print("=" * 50)
    
    for i, question in enumerate(questions, 1):
        print(f"\n📝 問題 {i}: {question}")
        print("-" * 30)
        
        try:
            answer, context = await rag_query(namespace, question, top_k=3)
            print(f"🤖 回答:\n{answer}")
            print(f"\n📚 參考片段數量: {len(context)}")
            
            # 顯示第一個參考片段的開頭
            if context:
                preview = context[0][:200] + "..." if len(context[0]) > 200 else context[0]
                print(f"📖 範例片段: {preview}")
            
        except Exception as e:
            print(f"❌ 查詢失敗: {str(e)}")
        
        print("\n" + "="*50)

if __name__ == "__main__":
    # 設置環境變數
    os.environ.setdefault("OLLAMA_HOST", "http://localhost:11434")
    os.environ.setdefault("RAG_STORE_DIR", "rag_store")
    
    asyncio.run(test_dnd_query())