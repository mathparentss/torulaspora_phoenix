#!/bin/bash
# Phoenix Auto-Start Script
# Automatically starts Phoenix Battlestack on system boot

# Detect Phoenix root dynamically
PHOENIX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PHOENIX_ROOT/var/logs/phoenix-boot.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

echo "=========================================" >> $LOG_FILE
echo "Phoenix Boot - $(date)" >> $LOG_FILE
echo "=========================================" >> $LOG_FILE

cd "$PHOENIX_ROOT/etc/compose"

# Start Tier 1 (Data Layer)
echo "[$(date '+%H:%M:%S')] Starting Tier 1..." >> $LOG_FILE
docker compose -f docker-compose.tier1.yml up -d >> $LOG_FILE 2>&1
sleep 5

# Start Tier 2 (AI Layer)
echo "[$(date '+%H:%M:%S')] Starting Tier 2..." >> $LOG_FILE
docker compose -f docker-compose.tier2.yml up -d >> $LOG_FILE 2>&1
sleep 5

# Start Tier 3 (Orchestration)
echo "[$(date '+%H:%M:%S')] Starting Tier 3..." >> $LOG_FILE
docker compose -f docker-compose.tier3.yml up -d >> $LOG_FILE 2>&1
sleep 3

# Start Tier 4 (Exporters)
echo "[$(date '+%H:%M:%S')] Starting Tier 4..." >> $LOG_FILE
docker compose -f docker-compose.tier4.yml up -d >> $LOG_FILE 2>&1
sleep 2

echo "[$(date '+%H:%M:%S')] Boot complete - All tiers started" >> $LOG_FILE
echo "" >> $LOG_FILE
