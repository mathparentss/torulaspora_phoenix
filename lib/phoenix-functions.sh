# Phoenix Shell Functions - Quick Access Commands
# Source this file in .bashrc for instant access

# Quick navigation
alias phoenix='cd /opt/phoenix && source phoenix.venv/bin/activate 2>/dev/null || true'
alias phlogs='cd /opt/phoenix/var/logs'
alias phscripts='cd /opt/phoenix/bin'

# Docker shortcuts
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dstats='docker stats'

# Phoenix management
alias phmenu='/opt/phoenix/bin/phoenix-menu.sh'
alias phstatus='/opt/phoenix/bin/phoenix-status.sh'
alias phboot='/opt/phoenix/sbin/phoenix-boot.sh'

# Tier management
alias tier1-up='docker compose --env-file /opt/phoenix/etc/compose/.env -f /opt/phoenix/etc/compose/docker-compose.tier1.yml up -d'
alias tier1-down='docker compose -f /opt/phoenix/etc/compose/docker-compose.tier1.yml down'
alias tier2-up='docker compose --env-file /opt/phoenix/etc/compose/.env -f /opt/phoenix/etc/compose/docker-compose.tier2.yml up -d'
alias tier2-down='docker compose -f /opt/phoenix/etc/compose/docker-compose.tier2.yml down'
alias tier3-up='docker compose --env-file /opt/phoenix/etc/compose/.env -f /opt/phoenix/etc/compose/docker-compose.tier3.yml up -d'
alias tier3-down='docker compose -f /opt/phoenix/etc/compose/docker-compose.tier3.yml down'

# Quick AI commands
phask() {
    docker exec -it phoenix_ollama ollama run llama3.2:3b "$@"
}

phmodels() {
    docker exec -it phoenix_ollama ollama list
}

phgpu() {
    nvidia-smi
}

# Quick database access
phdb() {
    docker exec -it phoenix_postgres psql -U phoenix -d phoenix_core
}

phredis() {
    # Password loaded from .env file - set REDIS_PASSWORD env var
    local redis_pass=$(grep REDIS_PASSWORD /opt/phoenix/etc/compose/.env 2>/dev/null | cut -d'=' -f2)
    docker exec -it phoenix_redis redis-cli -a "${redis_pass:-PhoenixRedis_2025_Secure!}"
}

# Open UIs in browser
phportainer() {
    cmd.exe /c start http://localhost:9000
}

phgrafana() {
    cmd.exe /c start http://localhost:3000
}

phadminer() {
    cmd.exe /c start http://localhost:8080
}

# Tier 4 management
alias tier4-up='docker compose --env-file /opt/phoenix/etc/compose/.env -f /opt/phoenix/etc/compose/docker-compose.tier4.yml up -d'
alias tier4-down='docker compose -f /opt/phoenix/etc/compose/docker-compose.tier4.yml down'
