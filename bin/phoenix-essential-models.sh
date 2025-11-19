#!/bin/bash
echo "🔥 ESSENTIAL PHOENIX MODELS"
echo ""
echo "[1/6] Qwen 2.5 Coder 7B"
docker exec phoenix_ollama ollama pull qwen2.5-coder:7b
echo "[2/6] Llama 3.1 8B"
docker exec phoenix_ollama ollama pull llama3.1:8b
echo "[3/6] Nomic Embed"
docker exec phoenix_ollama ollama pull nomic-embed-text
echo "[4/6] LLaVA 13B"
docker exec phoenix_ollama ollama pull llava:13b
echo "[5/6] Gemma 2 9B"
docker exec phoenix_ollama ollama pull gemma2:9b
echo "[6/6] Dolphin Phi"
docker exec phoenix_ollama ollama pull dolphin-phi
echo ""
docker exec phoenix_ollama ollama list
