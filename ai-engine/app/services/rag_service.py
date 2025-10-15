import os
import json
from typing import Tuple, List
import math
import httpx
import PyPDF2
from io import BytesIO

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://127.0.0.1:11434")
EMBED_MODEL = os.getenv("EMBED_MODEL", "nomic-embed-text")
RAG_STORE_DIR = os.getenv("RAG_STORE_DIR", "rag_store")

os.makedirs(RAG_STORE_DIR, exist_ok=True)

async def _embed_texts(texts: List[str]) -> List[List[float]]:
    url = f"{OLLAMA_HOST}/api/embeddings"
    out: List[List[float]] = []
    async with httpx.AsyncClient(timeout=120) as client:
        for t in texts:
            r = await client.post(url, json={"model": EMBED_MODEL, "prompt": t})
            r.raise_for_status()
            data = r.json()
            out.append(data.get("embedding", []))
    return out

def _ns_path(namespace: str) -> str:
    safe = "".join(c for c in namespace if c.isalnum() or c in ("-","_"))
    return os.path.join(RAG_STORE_DIR, f"{safe}.json")

def _load_ns(namespace: str) -> dict:
    p = _ns_path(namespace)
    if os.path.exists(p):
        with open(p, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"texts": [], "embeddings": []}

def _save_ns(namespace: str, data: dict) -> None:
    p = _ns_path(namespace)
    with open(p, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False)

def _cosine(a: List[float], b: List[float]) -> float:
    if not a or not b or len(a) != len(b):
        return -1.0
    dot = sum(x*y for x,y in zip(a,b))
    na = math.sqrt(sum(x*x for x in a))
    nb = math.sqrt(sum(y*y for y in b))
    if na == 0 or nb == 0:
        return -1.0
    return dot / (na*nb)

def _extract_text_from_pdf(file_content: bytes) -> List[str]:
    """從 PDF 檔案中提取文本，按頁面分割"""
    try:
        pdf_reader = PyPDF2.PdfReader(BytesIO(file_content))
        texts = []
        
        for page_num, page in enumerate(pdf_reader.pages):
            text = page.extract_text()
            if text.strip():  # 只添加非空頁面
                # 清理文本：移除多餘的空白和換行
                cleaned_text = ' '.join(text.split())
                if len(cleaned_text) > 50:  # 只保留有意義的文本片段
                    texts.append(f"[頁面 {page_num + 1}] {cleaned_text}")
        
        return texts
    except Exception as e:
        raise ValueError(f"PDF 文本提取失敗: {str(e)}")

def _chunk_text(text: str, chunk_size: int = 1000, overlap: int = 200) -> List[str]:
    """將長文本分割成較小的片段，保持重疊以維持上下文"""
    if len(text) <= chunk_size:
        return [text]
    
    chunks = []
    start = 0
    
    while start < len(text):
        end = start + chunk_size
        if end < len(text):
            # 尋找最近的句號或換行作為分割點
            for i in range(end, max(start + chunk_size - 100, start), -1):
                if text[i] in '.。\n':
                    end = i + 1
                    break
        
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)
        
        start = end - overlap if end < len(text) else end
    
    return chunks

async def ingest_pdf(namespace: str, file_content: bytes, filename: str = "") -> int:
    """處理 PDF 檔案並將內容匯入到 RAG 系統"""
    # 提取 PDF 文本
    pdf_texts = _extract_text_from_pdf(file_content)
    
    # 將長文本分割成適當大小的片段
    all_chunks = []
    for page_text in pdf_texts:
        chunks = _chunk_text(page_text, chunk_size=800, overlap=150)
        all_chunks.extend(chunks)
    
    # 添加檔案資訊到每個片段
    if filename:
        all_chunks = [f"[來源: {filename}] {chunk}" for chunk in all_chunks]
    
    # 使用現有的文本匯入功能
    return await ingest_texts(namespace, all_chunks)

async def ingest_texts(namespace: str, texts: List[str]) -> int:
    store = _load_ns(namespace)
    embs = await _embed_texts(texts)
    store["texts"].extend(texts)
    store["embeddings"].extend(embs)
    _save_ns(namespace, store)
    return len(texts)

async def rag_query(namespace: str, question: str, top_k: int | None = 3) -> Tuple[str, List[str]]:
    top_k = top_k or 3
    store = _load_ns(namespace)
    if not store["texts"]:
        return "未找到相關內容", []

    q_emb = (await _embed_texts([question]))[0]
    scores = [(_cosine(q_emb, e), i) for i, e in enumerate(store["embeddings"])]
    scores.sort(key=lambda x: x[0], reverse=True)
    idxs = [i for _, i in scores[:top_k]]
    ctx_docs = [store["texts"][i] for i in idxs]

    # 串 context + 問題呼叫 LLM 生成回答
    context_block = "\n\n".join(f"[片段{i+1}]\n{t}" for i, t in enumerate(ctx_docs))
    prompt = (
        "你是中文助理，請使用提供的內容片段回答使用者問題。\n"
        "若片段不足以回答，請坦承說明並提出可能需要的資訊。\n"
        "請使用繁體中文，適度條列重點，並在文末引用使用到的片段編號。\n\n"
        f"內容片段：\n{context_block}\n\n"
        f"使用者問題：{question}"
    )

    # 延用 chat_completion 以統一管道
    from .ollama_client import chat_completion
    answer = await chat_completion(prompt=prompt, system=(
        "你是一個專業、簡潔且樂於助人的中文助理。請一律使用繁體中文回答。"
        "若內容涉及敏感或非法，請拒絕並提供合規替代。"
    ))
    return answer, ctx_docs