from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from ..services.ollama_client import chat_completion

router = APIRouter()

class ChatRequest(BaseModel):
    prompt: str
    model: str | None = None  # e.g., "llama3.1:8b"
    system: str | None = None
    temperature: float | None = 0.3
    max_tokens: int | None = 256

class ChatResponse(BaseModel):
    reply: str

@router.post("/", response_model=ChatResponse)
async def chat(req: ChatRequest):
    try:
        # default Traditional Chinese system prompt when not provided
        default_system = (
            "你是一個專業、簡潔且樂於助人的中文助理。請一律使用繁體中文回答。"
            "若題目含糊，先澄清需求；若涉及敏感或非法內容，請拒絕並提供合規替代建議。"
        )
        reply = await chat_completion(
            prompt=req.prompt,
            model=req.model,
            system=req.system or default_system,
            temperature=req.temperature,
            max_tokens=req.max_tokens,
        )
        return ChatResponse(reply=reply)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))