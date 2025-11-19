#!/bin/bash
# Phoenix Status Display - Professional Stack Overview
# Created: 2025-11-17 | Author: Phoenix Architect Council

# Colors for greyhat aesthetic
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Get container counts
TOTAL=$(docker ps -q | wc -l)
TIER1=$(docker ps --filter "label=phoenix.tier=1" -q | wc -l)
TIER2=$(docker ps --filter "label=phoenix.tier=2" -q | wc -l)
TIER3=$(docker ps --filter "label=phoenix.tier=3" -q | wc -l)
HEALTHY=$(docker ps --filter "health=healthy" -q | wc -l)

# GPU info
GPU_INFO=$(nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
GPU_NAME=$(echo "$GPU_INFO" | awk -F',' '{print $1}' | xargs)
GPU_TEMP=$(echo "$GPU_INFO" | awk -F',' '{print $2}' | xargs)
GPU_UTIL=$(echo "$GPU_INFO" | awk -F',' '{print $3}' | xargs)
GPU_MEM=$(echo "$GPU_INFO" | awk -F',' '{print $4}' | xargs)
GPU_TOTAL=$(echo "$GPU_INFO" | awk -F',' '{print $5}' | xargs)

# System info
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                   ${GREEN}PHOENIX BATTLESTACK STATUS${NC}                   ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ${YELLOW}System:${NC}  WSL2 Ubuntu 24.04  │  ${YELLOW}Uptime:${NC} $UPTIME          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ${YELLOW}Load:${NC}    $LOAD                                      ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ${MAGENTA}GPU:${NC}     $GPU_NAME                                ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}          ${GREEN}Temp:${NC} ${GPU_TEMP}°C  ${GREEN}Util:${NC} ${GPU_UTIL}%  ${GREEN}VRAM:${NC} ${GPU_MEM}/${GPU_TOTAL}MB    ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ${BLUE}CONTAINERS:${NC} ${GREEN}$TOTAL/9${NC} Running  │  ${GREEN}$HEALTHY${NC} Healthy               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Tier 1 (Data):${NC}       $TIER1/2                                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Tier 2 (AI):${NC}         $TIER2/2                                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Tier 3 (Ops):${NC}        $TIER3/5                                  ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ${YELLOW}ENDPOINTS:${NC}                                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}AI:${NC}        http://localhost:11434  ${GREEN}[Ollama]${NC}              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Vectors:${NC}   http://localhost:6333   ${GREEN}[Qdrant]${NC}              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Database:${NC}  http://localhost:8080   ${GREEN}[Adminer]${NC}             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Metrics:${NC}   http://localhost:9090   ${GREEN}[Prometheus]${NC}          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Dashboard:${NC} http://localhost:3000   ${GREEN}[Grafana]${NC}             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Docker UI:${NC} http://localhost:9000   ${GREEN}[Portainer]${NC}           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${GRAY}Workflows:${NC} http://localhost:5678   ${GREEN}[n8n]${NC}                 ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
