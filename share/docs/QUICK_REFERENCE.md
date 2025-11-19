# Phoenix Battlestack - Quick Reference Guide

**Created:** 2025-11-17  
**Machine:** Ryzen HX370 + RTX 5080 Laptop  
**Status:** Production-Ready

---

## 🚀 Quick Commands

### Essential Commands
```bashphmenu          # Open interactive menu (recommended)
phstatus        # Show system status
phoenix         # Navigate to Phoenix directory + activate venv
dps             # List all containers
phask "query"   # Quick AI query via Ollama

### Tier Management
```bashtier1-up        # Start Tier 1 (PostgreSQL, Redis)
tier1-down      # Stop Tier 1
tier2-up        # Start Tier 2 (Ollama, Qdrant)
tier2-down      # Stop Tier 2
tier3-up        # Start Tier 3 (n8n, Prometheus, Grafana, Portainer, Adminer)
tier3-down      # Stop Tier 3

### Quick Access
```bashphdb            # PostgreSQL CLI
phredis         # Redis CLI
phgpu           # GPU status (nvidia-smi)
phmodels        # List Ollama models
phportainer     # Open Portainer in browser
phgrafana       # Open Grafana in browser
phadminer       # Open Adminer in browser

---

## 🌐 Service Endpoints

| Service | URL | Credentials |
|---------|-----|-------------|
| **Ollama API** | http://localhost:11434 | None |
| **Qdrant API** | http://localhost:6333 | API Key: PhoenixQdrant_2025_Secure! |
| **PostgreSQL** | localhost:5432 | phoenix / PhoenixDB_2025_Secure! |
| **Redis** | localhost:6379 | Password: PhoenixRedis_2025_Secure! |
| **n8n** | http://localhost:5678 | phoenix / PhoenixN8N_2025_Secure! |
| **Prometheus** | http://localhost:9090 | None |
| **Grafana** | http://localhost:3000 | admin / PhoenixGrafana_2025_Secure! |
| **Portainer** | http://localhost:9000 | (Set on first login) |
| **Adminer** | http://localhost:8080 | phoenix / PhoenixDB_2025_Secure! |

---

## 📁 Directory Structure/mnt/c/dev/phoenix/
├── configs/
│   ├── docker/           # Docker Compose files (tier1, tier2, tier3)
│   ├── prometheus/       # Prometheus configuration
│   ├── grafana/          # Grafana datasources
│   ├── qdrant/           # Qdrant configuration
│   └── motd/             # Banner and MOTD files
├── scripts/
│   ├── startup/          # Boot and auto-start scripts
│   ├── management/       # Interactive menu system
│   └── monitoring/       # Status and health checks
├── logs/                 # System logs
├── docs/                 # Documentation
└── phoenix.venv/         # Python virtual environment

---

## 🔧 Troubleshooting

### Containers not starting?
```bashphstatus               # Check which services are down
docker logs phoenix_X  # Replace X with container name
phboot                 # Restart all tiers

### GPU not working?
```bashnvidia-smi             # Verify GPU is visible
docker exec phoenix_ollama nvidia-smi  # Check GPU in container

### Database connection issues?
```bashphdb                   # Test PostgreSQL connection
phredis                # Test Redis connection

---

## 📊 Monitoring

- **Real-time metrics:** http://localhost:9090 (Prometheus)
- **Visual dashboards:** http://localhost:3000 (Grafana)
- **Docker management:** http://localhost:9000 (Portainer)
- **Container stats:** Run `dstats` or `docker stats`
- **GPU monitoring:** Run `phgpu` or `watch -n 1 nvidia-smi`

---

## 🎯 Common Tasks

### Pull a new AI model
```bashdocker exec -it phoenix_ollama ollama pull qwen2.5-coder:7b

### Query database
```bashphdb
SELECT * FROM summaries LIMIT 5;

### Create n8n workflow
1. Open http://localhost:5678
2. Login with phoenix / PhoenixN8N_2025_Secure!
3. Click "Add workflow"

### Check health of all services
```bashbash scripts/monitoring/phoenix-health-check.sh

---

## 🔐 Security Notes

- All services bound to **127.0.0.1** (localhost only)
- Passwords stored in `.env` file (git-ignored)
- PostgreSQL network access controlled via `pg_hba.conf`
- Qdrant API key required for vector operations
- Docker socket read-only for Portainer

---

## 🚨 Emergency Commands
```bashStop everything immediately
docker stop $(docker ps -q)Start everything
phbootView boot logs
cat logs/phoenix-boot.logReset to clean state (CAUTION: Removes all containers)
docker compose -f configs/docker/docker-compose.tier3.yml down
docker compose -f configs/docker/docker-compose.tier2.yml down
docker compose -f configs/docker/docker-compose.tier1.yml down

---

**For detailed architecture, see:** `FULL_ARCHITECTURE_12_MONTHS.md`  
**For database schemas, see:** `DATABASE_INTELLIGENCE_NEEDS.md`
