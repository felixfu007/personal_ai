import json

# 檢查 dnd_srd.json 的結構
try:
    with open('rag_store/dnd_srd.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"📊 總項目數: {len(data)}")
    
    if data:
        first_item = data[0]
        print(f"🔍 第一個項目的鍵: {list(first_item.keys())}")
        
        # 檢查是否有文本字段
        if 'text' in first_item:
            print(f"📝 樣本文本: {first_item['text'][:100]}...")
        else:
            print("❌ 沒有找到 'text' 字段")
            print(f"📋 第一個項目內容: {first_item}")
            
except Exception as e:
    print(f"❌ 錯誤: {e}")