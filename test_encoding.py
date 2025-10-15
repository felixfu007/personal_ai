import json
import requests

# 測試中文編碼
response = requests.post(
    "http://localhost:8000/chat",
    json={
        "model": "qwen2.5:3b",
        "prompt": "你好，請用繁體中文簡單介紹一下你自己"
    },
    headers={"Content-Type": "application/json; charset=utf-8"}
)

print("Response status:", response.status_code)
print("Response headers:", dict(response.headers))
print("Response encoding:", response.encoding)

# 檢查原始回應
print("\nRaw response bytes:")
print(response.content)

# 檢查 JSON 解析
try:
    data = response.json()
    print("\nParsed JSON:")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    
    print("\nReply content:")
    print(data.get("reply", "No reply found"))
except Exception as e:
    print(f"JSON parsing error: {e}")