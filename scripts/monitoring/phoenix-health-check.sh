#!/bin/bash
# Phoenix Health Check - Comprehensive Service Validation
# Created: 2025-11-17 | Author: Phoenix Architect Council

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                   ${YELLOW}PHOENIX HEALTH CHECK${NC}                          ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Test all endpoints
test_endpoint() {
    local name=$1
    local url=$2
    local expected=$3
    
    if curl -s "$url" | grep -q "$expected" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name: ${GREEN}HEALTHY${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} $name: ${RED}FAILED${NC}"
        return 1
    fi
}

echo -e "${CYAN}Testing Tier 1 Services:${NC}"
test_endpoint "PostgreSQL" "http://localhost:5432" "" || echo "  (Connection-based, check with: docker exec phoenix_postgres pg_isready)"
docker exec phoenix_postgres pg_isready -U phoenix > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} PostgreSQL: ${GREEN}HEALTHY${NC}" || echo -e "${RED}✗${NC} PostgreSQL: ${RED}FAILED${NC}"
test_endpoint "Redis" "http://localhost:6379" ""
docker exec phoenix_redis redis-cli -a PhoenixRedis_2025_Secure! PING 2>/dev/null | grep -q PONG && echo -e "${GREEN}✓${NC} Redis: ${GREEN}HEALTHY${NC}" || echo -e "${RED}✗${NC} Redis: ${RED}FAILED${NC}"

echo ""
echo -e "${CYAN}Testing Tier 2 Services:${NC}"
test_endpoint "Ollama" "http://localhost:11434" "Ollama"
test_endpoint "Qdrant" "http://localhost:6333/health" "ok"

echo ""
echo -e "${CYAN}Testing Tier 3 Services:${NC}"
test_endpoint "n8n" "http://localhost:5678/healthz" "ok"
test_endpoint "Prometheus" "http://localhost:9090/-/healthy" "Prometheus"
test_endpoint "Grafana" "http://localhost:3000/api/health" "ok"
test_endpoint "Portainer" "http://localhost:9000/api/system/status" "version"
test_endpoint "Adminer" "http://localhost:8080" "Adminer"

echo ""
echo -e "${CYAN}Testing GPU:${NC}"
if nvidia-smi > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} NVIDIA GPU: ${GREEN}DETECTED${NC}"
    nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu --format=csv,noheader
else
    echo -e "${RED}✗${NC} NVIDIA GPU: ${RED}NOT DETECTED${NC}"
fi

echo ""
echo -e "${CYAN}Container Status:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep phoenix

echo ""
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
