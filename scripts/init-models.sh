#!/bin/bash

# AI Engine 模型初始化腳本
# 此腳本會自動下載並配置所需的 AI 模型

echo "🚀 開始初始化 AI 模型..."

# 等待 Ollama 服務就緒
echo "⏳ 等待 Ollama 服務啟動..."
until ollama list > /dev/null 2>&1; do
    echo "等待 Ollama 服務..."
    sleep 5
done

echo "✅ Ollama 服務已就緒"

# 設定 Ollama 主機
export OLLAMA_HOST=http://ollama:11434

# 下載並配置模型
echo "📥 下載 qwen2.5:3b 模型 (快速模型)..."
ollama pull qwen2.5:3b

echo "📥 下載 gemma2:2b 模型 (輕量模型)..."
ollama pull gemma2:2b

echo "📥 下載 nomic-embed-text 模型 (嵌入模型)..."
ollama pull nomic-embed-text

# 驗證模型下載
echo "📋 檢查已安裝的模型..."
ollama list

echo "🎉 模型初始化完成！"
echo "可用模型："
echo "  - qwen2.5:3b (預設，中文優化)"
echo "  - gemma2:2b (極速模型)"
echo "  - nomic-embed-text (RAG 嵌入)"

# 預熱模型
echo "🔥 預熱 qwen2.5:3b 模型..."
ollama run qwen2.5:3b "你好" || echo "⚠️ 預熱失敗，但這是正常的"

echo "✨ 初始化程序完成！"