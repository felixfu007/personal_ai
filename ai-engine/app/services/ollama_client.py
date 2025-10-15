import os
import json
import httpx

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
# 改用更快的 3B 模型作為預設，速度比 8B 快約 2-3 倍
DEFAULT_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5:3b")

async def chat_completion(prompt: str, model: str | None = None, system: str | None = None,
                          temperature: float | None = 0.3, max_tokens: int | None = 256) -> str:
    """
    Calls local Ollama server's chat API using httpx.
    Optimized for faster response times.
    """
    mdl = model or DEFAULT_MODEL
    url = f"{OLLAMA_HOST}/api/chat"

    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})

    payload = {
        "model": mdl,
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": temperature,
            "num_predict": max_tokens,
            # 優化參數以提升速度
            "num_ctx": 2048,  # 減少 context window 以提升速度
            "top_k": 20,      # 限制候選詞數量
            "top_p": 0.9,     # 使用 nucleus sampling
            "repeat_penalty": 1.1,  # 避免重複
            "num_thread": 8   # 使用 8 線程（匹配您的 Ryzen 7）
        }
    }

    async with httpx.AsyncClient(timeout=120) as client:
        r = await client.post(url, json=payload)
        r.raise_for_status()
        data = r.json()
        # data structure: { 'message': {'role': 'assistant', 'content': '...'}, ... }
        return data.get("message", {}).get("content", "")