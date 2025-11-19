#!/bin/bash
# Phoenix Interactive Menu - Greyhat Stack Management
# Created: 2025-11-17 | Author: Phoenix Architect Council

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PHOENIX_ROOT="/opt/phoenix"

show_menu() {
    clear
    cat $PHOENIX_ROOT/configs/motd/phoenix-banner.txt
    echo ""
    $PHOENIX_ROOT/scripts/monitoring/phoenix-status.sh
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                      ${YELLOW}PHOENIX COMMAND CENTER${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[1]${NC} Start All Tiers       ${GREEN}[7]${NC} View Container Logs            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[2]${NC} Stop All Tiers        ${GREEN}[8]${NC} GPU Status (nvidia-smi)        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[3]${NC} Restart All Tiers     ${GREEN}[9]${NC} Container Stats (live)         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[4]${NC} Start Specific Tier   ${GREEN}[10]${NC} Open Portainer (browser)      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[5]${NC} Stop Specific Tier    ${GREEN}[11]${NC} Open Grafana (browser)        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[6]${NC} View All Containers   ${GREEN}[12]${NC} Pull New Models (Ollama)      ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}[13]${NC} Git Status & Push     ${YELLOW}[15]${NC} Run Health Checks             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}[14]${NC} Backup Volumes        ${YELLOW}[16]${NC} System Resource Monitor       ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${RED}[0]${NC} Exit Menu                                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "${YELLOW}Enter choice [0-16]:${NC} "
}

while true; do
    show_menu
    read choice
    
    case $choice in
        1) 
            echo -e "${GREEN}Starting all tiers...${NC}"
            cd $PHOENIX_ROOT
            docker compose -f configs/docker/docker-compose.tier1.yml up -d
            docker compose -f configs/docker/docker-compose.tier2.yml up -d
            docker compose -f configs/docker/docker-compose.tier3.yml up -d
            sleep 3
            ;;
        2)
            echo -e "${YELLOW}Stopping all tiers...${NC}"
            cd $PHOENIX_ROOT
            docker compose -f configs/docker/docker-compose.tier3.yml down
            docker compose -f configs/docker/docker-compose.tier2.yml down
            docker compose -f configs/docker/docker-compose.tier1.yml down
            sleep 2
            ;;
        3)
            echo -e "${BLUE}Restarting all tiers...${NC}"
            cd $PHOENIX_ROOT
            docker compose -f configs/docker/docker-compose.tier3.yml restart
            docker compose -f configs/docker/docker-compose.tier2.yml restart
            docker compose -f configs/docker/docker-compose.tier1.yml restart
            sleep 3
            ;;
        6)
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            read -p "Press enter to continue..."
            ;;
        7)
            echo -e "${CYAN}Available containers:${NC}"
            docker ps --format "{{.Names}}"
            echo ""
            read -p "Enter container name: " container
            docker logs -f $container
            ;;
        8)
            nvidia-smi
            read -p "Press enter to continue..."
            ;;
        9)
            docker stats
            ;;
        10)
            cmd.exe /c start http://localhost:9000
            ;;
        11)
            cmd.exe /c start http://localhost:3000
            ;;
        12)
            docker exec -it phoenix_ollama ollama list
            echo ""
            read -p "Enter model name to pull (e.g., qwen2.5-coder:7b): " model
            docker exec -it phoenix_ollama ollama pull $model
            read -p "Press enter to continue..."
            ;;
        13)
            cd $PHOENIX_ROOT
            git status
            echo ""
            read -p "Commit message (or Enter to skip): " msg
            if [ ! -z "$msg" ]; then
                git add -A
                git commit -m "$msg"
                git push
            fi
            read -p "Press enter to continue..."
            ;;
        15)
            cd $PHOENIX_ROOT
            bash scripts/monitoring/phoenix-health-check.sh
            read -p "Press enter to continue..."
            ;;
        16)
            htop
            ;;
        0)
            echo -e "${GREEN}Phoenix systems remain operational. Exiting menu.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Press enter to continue...${NC}"
            read
            ;;
    esac
done
