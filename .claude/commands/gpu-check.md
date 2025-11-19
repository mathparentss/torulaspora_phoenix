# GPU Status Check
```bash
echo "=== HOST GPU ==="
nvidia-smi --query-gpu=name,memory.total,utilization.gpu --format=csv

echo -e "\n=== CONTAINER GPU ==="
docker exec phoenix_ollama nvidia-smi 2>/dev/null || echo "❌ GPU not visible"

echo -e "\n=== INFERENCE TEST ==="
time docker exec phoenix_ollama ollama run llama3.2:3b "2+2=" 2>&1 | grep "eval rate"
```

Expected: 150+ tokens/sec with GPU, 25 tok/s CPU-only
