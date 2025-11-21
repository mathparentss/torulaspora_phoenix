#!/bin/bash
set -euo pipefail

MODELS=(
  "qwen2.5-coder:7b"
  "llama3.1:8b"
  "nomic-embed-text"
  "llava:13b"
  "gemma2:9b"
  "dolphin-phi"
)

echo "================================================"
echo "PHOENIX ESSENTIAL MODELS — PULL + VERIFICATION"
echo "================================================"

FAILED_MODELS=()

for model in "${MODELS[@]}"; do
  echo ""
  echo "📥 Pulling $model..."

  if docker exec phoenix_ollama ollama pull "$model" 2>&1 | tee /tmp/ollama_pull.log; then
    # Verify model exists in list
    if docker exec phoenix_ollama ollama list | grep -q "^${model%%:*}"; then
      echo "  ✅ $model verified and ready"
    else
      echo "  ❌ $model pull succeeded but not found in list"
      FAILED_MODELS+=("$model")
    fi
  else
    echo "  ❌ $model pull FAILED"
    FAILED_MODELS+=("$model")
  fi
done

echo ""
echo "================================================"
echo "SUMMARY"
echo "================================================"
echo "Total models: ${#MODELS[@]}"
echo "Failed: ${#FAILED_MODELS[@]}"

if [ ${#FAILED_MODELS[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  FAILED MODELS:"
  for model in "${FAILED_MODELS[@]}"; do
    echo "  - $model"
  done
  exit 1
else
  echo "✅ All models verified successfully"
fi
