#!/bin/bash
echo "╔════════════════════════════════════════════════╗"
echo "║     PHOENIX ALPHA DEVICE - FULL VALIDATION     ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Host Tools
echo "=== HOST TOOLS ==="
node --version | sed 's/^/✓ Node.js: /'
npm --version | sed 's/^/✓ NPM: /'
ollama version | sed 's/^/✓ Ollama CLI: /'
gcloud --version | head -1 | sed 's/^/✓ /'

# Ollama Service Check
echo ""
echo "=== OLLAMA CONFIGURATION ==="
systemctl is-active ollama > /dev/null 2>&1 && echo "⚠️  Host Ollama: ACTIVE (conflict)" || echo "✓ Host Ollama: DISABLED"
curl -s http://localhost:11434/api/tags | jq -r '.models | length' | sed 's/^/✓ Container Ollama: /' | sed 's/$/ models loaded/'

# Container Health
echo ""
echo "=== CONTAINER HEALTH ==="
docker ps --format "{{.Names}}" | grep phoenix | while read container; do
    health=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null || echo "no healthcheck")
    status=$(docker inspect --format='{{.State.Status}}' $container)
    if [ "$health" = "healthy" ] || [ "$health" = "no healthcheck" ]; then
        echo "✓ $container: $status ($health)"
    else
        echo "⚠️  $container: $status ($health)"
    fi
done

# API Endpoints
echo ""
echo "=== API ENDPOINT TESTS ==="
curl -s http://localhost:11434/api/version > /dev/null && echo "✓ Ollama: RESPONDING" || echo "✗ Ollama: OFFLINE"
curl -s http://localhost:6333/health > /dev/null && echo "✓ Qdrant: RESPONDING" || echo "✗ Qdrant: OFFLINE"
curl -s http://localhost:5678/healthz > /dev/null && echo "✓ n8n: RESPONDING" || echo "✗ n8n: OFFLINE"
curl -s http://localhost:9090/-/healthy > /dev/null && echo "✓ Prometheus: RESPONDING" || echo "✗ Prometheus: OFFLINE"
curl -s http://localhost:3000/api/health > /dev/null && echo "✓ Grafana: RESPONDING" || echo "✗ Grafana: OFFLINE"

# Database Connectivity
echo ""
echo "=== DATABASE CONNECTIVITY ==="
docker exec phoenix_postgres pg_isready -q && echo "✓ PostgreSQL: READY" || echo "✗ PostgreSQL: NOT READY"
docker exec phoenix_redis redis-cli ping > /dev/null && echo "✓ Redis: READY" || echo "✗ Redis: NOT READY"

# GPU Status
echo ""
echo "=== GPU STATUS ==="
nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader | while IFS=',' read name temp util mem_used mem_total; do
    echo "✓ $name"
    echo "  Temperature: $temp"
    echo "  Utilization: $util"
    echo "  VRAM: $mem_used / $mem_total"
done

# Security
echo ""
echo "=== SECURITY STATUS ==="
sudo ufw status | grep -q "Status: active" && echo "✓ Firewall: ACTIVE" || echo "⚠️  Firewall: INACTIVE"
systemctl is-active fail2ban > /dev/null && echo "✓ Fail2Ban: ACTIVE" || echo "⚠️  Fail2Ban: NOT INSTALLED"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            VALIDATION COMPLETE                 ║"
echo "╚════════════════════════════════════════════════╝"
