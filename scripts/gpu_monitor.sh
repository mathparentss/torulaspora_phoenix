#!/bin/bash
# Phoenix GPU Monitor - Real-time RTX 5080 utilization tracking
# Usage: bash /mnt/c/dev/phoenix/scripts/gpu_monitor.sh

while true; do
  clear
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║           PHOENIX GPU MONITOR - RTX 5080 TRACKING            ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  date
  echo ""
  echo "GPU METRICS:"
  nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu,power.draw,power.limit --format=csv
  echo ""
  echo "OLLAMA CONTAINER STATS:"
  docker stats --no-stream phoenix_ollama --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" 2>/dev/null || echo "Ollama container not running"
  echo ""
  echo "ACTIVE INFERENCE CHECK:"
  docker exec phoenix_ollama pgrep -a ollama 2>/dev/null | grep -q "runner" && echo "✓ Inference active" || echo "○ Idle (no active inference)"
  echo ""
  echo "VRAM UTILIZATION: $(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits) MB / $(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits) MB"
  echo ""
  echo "Press Ctrl+C to exit | Refreshing every 3 seconds..."
  sleep 3
done
