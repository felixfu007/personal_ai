from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from .routers import health, chat, rag
from dotenv import load_dotenv
import json

# Load .env variables early
load_dotenv()

app = FastAPI(title="Personal AI Engine", version="0.1.0")

# 自定義 JSON 響應以確保 UTF-8 編碼
class UTF8JSONResponse(JSONResponse):
    def render(self, content) -> bytes:
        return json.dumps(
            content,
            ensure_ascii=False,
            allow_nan=False,
            indent=None,
            separators=(",", ":"),
        ).encode("utf-8")

# 設置預設響應類別
app.default_response_class = UTF8JSONResponse

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="/healthz", tags=["health"])
app.include_router(chat.router, prefix="/chat", tags=["chat"])
app.include_router(rag.router, prefix="/rag", tags=["rag"])