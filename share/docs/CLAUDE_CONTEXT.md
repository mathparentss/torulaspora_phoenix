# PHOENIX BATTLESTACK — CLAUDE CODE CONTEXT

**Project**: Distributed AI infrastructure + B2B lead generation (food ingredients)  
**Stack**: Docker Swarm, PostgreSQL, Redis, Ollama (GPU), Qdrant, n8n, Grafana  
**Hardware**: Ryzen 9 HX370 + RTX 5080 16GB (WSL2 Ubuntu 24.04)  
**Location**: `/mnt/c/dev/phoenix`

---

## CRITICAL RULES

### Code Style
- **Shell scripts**: Bash with strict mode (`set -euo pipefail`)
- **Python**: Type hints, docstrings, f-strings
- **SQL**: PostgreSQL 17 syntax, explicit schemas
- **Docker**: Compose v3.8+, health checks, resource limits

### Development Approach
- **MVP first**: Ship working code, optimize later
- **No frameworks** unless absolutely necessary
- **Hardcode reasonable defaults** (this is a solo/small team project)
- **Single-file implementations** when feasible
- **Copy-paste over abstraction** until proven needed

### Git Workflow
- **Commit after every working change**
- **Use descriptive messages**: `feat: add GPU passthrough` not `fix stuff`
- **Branch naming**: `feature/`, `fix/`, `hotfix/`
- **Never commit secrets** (all in `.env` files, gitignored)

### File Organization
```
/mnt/c/dev/phoenix/
├── docker/              # Docker Compose files
├── scripts/             # Bash automation
├── configs/             # App configs (n8n, Grafana, etc.)
│   └── database/        # SQL schemas
├── dotfiles/            # Shell configs (.bashrc-phoenix)
├── logs/                # Service logs
└── data/                # Persistent volumes (gitignored)
```

### Token Optimization
- **Read before writing**: Use `@filename` to reference files, don't explore
- **Batch edits**: Group related changes in single operations
- **Clear context aggressively**: Use `/clear` after completing tasks
- **No unnecessary logging**: Skip verbose command outputs in responses
- **Lean responses**: Get to the point, no fluff

### Phoenix-Specific Commands
```bash
ph-status        # Show all container health
ph-gpu           # Check GPU utilization
ph-logs <service> # Tail logs for service
ph-db            # Connect to PostgreSQL
ph-restart <service> # Restart specific service
ph-backup        # Backup databases
```

---

## ARCHITECTURE NOTES

### Database: Phoenix Shadow Intelligence
- **Purpose**: Neuroscience-driven CRM shadow DB
- **Schemas**: core, events, intelligence, agents, neuroscience, enrichment, products
- **Pattern**: Event sourcing + CQRS + graph relationships
- **User**: `phoenix` (not `specter_app`)
- **Port**: 5432 (localhost only)

### GPU Acceleration
- **NVIDIA Container Toolkit** required for Ollama GPU access
- **Models loaded**: llama3.2:3b, llama3.1:8b, qwen2.5-coder:7b, gemma2:9b, llava:13b
- **Target performance**: 150+ tokens/sec (GPU) vs 25 tokens/sec (CPU)
- **VRAM target**: 8-12GB active during inference

### Agent Orchestration
- **Seekers**: Detect signals (web, LinkedIn, email)
- **Oracles**: Enrich data (contacts, companies, pain points)
- **Guardians**: Validate quality, approve/reject
- **Priority**: Fibonacci(urgency) × impact × (1/difficulty)
- **Dopamine tracking**: Gamification for agent performance

### Network Security
- **All services localhost-bound**: 127.0.0.1 only
- **Strong passwords**: 25+ chars, in `.env`
- **API keys**: Qdrant, Redis, n8n all authenticated
- **Zero external exposure**: No public ports

---

## FORBIDDEN ACTIONS

- ❌ **Don't install new packages** without confirming
- ❌ **Don't modify docker-compose.yml** without backup
- ❌ **Don't delete data volumes** (phoenix_postgres_data, etc.)
- ❌ **Don't expose services publicly** (security risk)
- ❌ **Don't write enterprise-grade abstractions** (keep it lean)

---

## WHEN STUCK

1. **Check logs first**: `ph-logs <service>` or `docker logs phoenix_<service>`
2. **Verify health**: `ph-status` shows all container states
3. **GPU issues**: `ph-gpu` checks NVIDIA driver + container access
4. **Database issues**: `ph-db` connects to PostgreSQL, verify schemas exist
5. **Network issues**: `sudo iptables -L` shows firewall rules

---

## QUICK REFERENCE

### Docker Services
- **postgres**: 5432 (phoenix/PhoenixDB_2025_Secure!)
- **redis**: 6379 (PhoenixRedis_2025_Secure!)
- **ollama**: 11434 (GPU inference)
- **qdrant**: 6333-6334 (PhoenixQdrant_2025_Secure!)
- **n8n**: 5678 (phoenix/PhoenixN8N_2025_Secure!)
- **grafana**: 3000 (admin/PhoenixGrafana_2025_Secure!)
- **prometheus**: 9090 (metrics)
- **portainer**: 9000, 9443 (phoenix/Phoenix_portainer_2025_Secure!)

### Environment
- **Timezone**: America/New_York
- **Project name**: phoenix (all containers prefixed `phoenix_`)
- **Python venv**: `phoenix.venv` (activate with `. phoenix.venv/bin/activate`)

---

**Token Budget**: Keep responses <500 tokens unless complexity demands more.  
**Philosophy**: Working code > perfect code. Ship fast, iterate based on reality.
