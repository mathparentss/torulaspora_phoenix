# Phoenix AI Model Guide

## Installed Models (After Download)

### 1. qwen2.5-coder:7b (BEST FOR CODE)
```bash
phask "write a python function to reverse a string"
# Or specific:
docker exec -it phoenix_ollama ollama run qwen2.5-coder:7b "explain this code: def foo():"
```

### 2. llama3.1:8b (BEST FOR CHAT)
```bash
docker exec -it phoenix_ollama ollama run llama3.1:8b "explain quantum computing"
```

### 3. nomic-embed-text (EMBEDDINGS FOR RAG)
```bash
# Use in n8n or Python for vector search
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "search query here"
}'
```

### 4. llava:13b (VISION - IMAGE UNDERSTANDING)
```bash
docker exec -it phoenix_ollama ollama run llava:13b "what's in this image?" /path/to/image.jpg
```

### 5. gemma2:9b (GOOGLE'S BEST REASONING)
```bash
docker exec -it phoenix_ollama ollama run gemma2:9b "solve this logic puzzle:"
```

### 6. dolphin-phi (UNCENSORED)
```bash
docker exec -it phoenix_ollama ollama run dolphin-phi "your query"
```

## Quick Model Switch Function
Add to .bashrc-phoenix:
```bash
phai() {
    local model=${1:-qwen2.5-coder:7b}
    shift
    docker exec -it phoenix_ollama ollama run "$model" "$@"
}
```

Usage: `phai llama3.1:8b "hello"`
