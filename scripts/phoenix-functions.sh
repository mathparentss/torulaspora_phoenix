# Phoenix Shell Functions - Quick Access Commands
# Source this file in .bashrc for instant access

# Quick navigation
alias phoenix='cd /mnt/c/dev/phoenix && source phoenix.venv/bin/activate'
alias phlogs='cd /mnt/c/dev/phoenix/logs'
alias phscripts='cd /mnt/c/dev/phoenix/scripts'

# Docker shortcuts
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dstats='docker stats'

# Phoenix management
alias phmenu='/mnt/c/dev/phoenix/scripts/management/phoenix-menu.sh'
alias phstatus='/mnt/c/dev/phoenix/scripts/monitoring/phoenix-status.sh'
alias phboot='/mnt/c/dev/phoenix/scripts/startup/phoenix-boot.sh'

# Tier management
alias tier1-up='cd /mnt/c/dev/phoenix && docker compose -f configs/docker/docker-compose.tier1.yml up -d'
alias tier1-down='cd /mnt/c/dev/phoenix && docker compose -f configs/docker/docker-compose.tier1.yml down'
alias tier2-up='cd /mnt/c/dev/phoenix && docker compose -f configs/docker/docker-compose.tier2.yml up -d'
alias tier2-down='cd /mnt/c/dev/phoenix && docker compose -f configs/docker/docker-compose.tier2.yml down'
alias tier3-up='cd /mnt/c/dev/phoenix && docker compose -f configs/docker/docker-compose.tier3.yml up -d'
alias tier3-down='cd /mnt/c/dev/phoenix && docker compose -f configs/docker/docker-compose.tier3.yml down'

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
    docker exec -it phoenix_redis redis-cli -a PhoenixRedis_2025_Secure!
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
