#!/bin/bash
# Phoenix Auto-Start Script
# Automatically starts Phoenix Battlestack on WSL boot

PHOENIX_ROOT="/mnt/c/dev/phoenix"
LOG_FILE="$PHOENIX_ROOT/logs/phoenix-boot.log"

echo "=========================================" >> $LOG_FILE
echo "Phoenix Boot - $(date)" >> $LOG_FILE
echo "=========================================" >> $LOG_FILE

cd $PHOENIX_ROOT

# Start Tier 1 (Data Layer)
echo "[$(date '+%H:%M:%S')] Starting Tier 1..." >> $LOG_FILE
docker compose -f configs/docker/docker-compose.tier1.yml up -d >> $LOG_FILE 2>&1
sleep 5

# Start Tier 2 (AI Layer)  
echo "[$(date '+%H:%M:%S')] Starting Tier 2..." >> $LOG_FILE
docker compose -f configs/docker/docker-compose.tier2.yml up -d >> $LOG_FILE 2>&1
sleep 5

# Start Tier 3 (Orchestration)
echo "[$(date '+%H:%M:%S')] Starting Tier 3..." >> $LOG_FILE
docker compose -f configs/docker/docker-compose.tier3.yml up -d >> $LOG_FILE 2>&1
sleep 3

echo "[$(date '+%H:%M:%S')] Boot complete - All tiers started" >> $LOG_FILE
echo "" >> $LOG_FILE
