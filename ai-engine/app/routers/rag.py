from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from ..services.rag_service import ingest_texts, rag_query, ingest_pdf

router = APIRouter()

class IngestRequest(BaseModel):
    namespace: str
    texts: list[str]

class QueryRequest(BaseModel):
    namespace: str
    question: str
    top_k: int | None = 3

class QueryResponse(BaseModel):
    answer: str
    context: list[str]

@router.post("/ingest")
async def ingest(req: IngestRequest):
    try:
        count = await ingest_texts(req.namespace, req.texts)
        return {"status": "ok", "ingested": count}
    except NotImplementedError as e:
        raise HTTPException(status_code=501, detail=str(e))

@router.post("/ingest/pdf")
async def ingest_pdf_file(
    namespace: str = Form(...),
    file: UploadFile = File(...)
):
    """上傳 PDF 檔案並匯入到 RAG 系統"""
    try:
        # 檢查檔案類型
        if not file.filename.lower().endswith('.pdf'):
            raise HTTPException(status_code=400, detail="只支援 PDF 檔案")
        
        # 讀取檔案內容
        file_content = await file.read()
        
        # 處理 PDF 並匯入
        count = await ingest_pdf(namespace, file_content, file.filename)
        
        return {
            "status": "ok", 
            "filename": file.filename,
            "namespace": namespace,
            "chunks_ingested": count
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"PDF 處理失敗: {str(e)}")

@router.post("/query", response_model=QueryResponse)
async def query(req: QueryRequest):
    try:
        answer, context = await rag_query(req.namespace, req.question, req.top_k)
        return QueryResponse(answer=answer, context=context)
    except NotImplementedError as e:
        raise HTTPException(status_code=501, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))