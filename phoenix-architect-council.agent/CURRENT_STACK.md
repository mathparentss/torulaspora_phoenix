# CURRENT_STACK.md (V2)

## Overview (Infrastructure Audit & Inventory)

Complete Phoenix Battlestack hardware/software audit as of November 2025. Inventory structured for #No-Estimate Scrum: Each asset scales independently per Fibonacci growth, no fixed allocation. Gaps identified for Phase 1-7 evolution. Production-grade tracking with serial numbers, versions, and readiness scores. Zero-loss guarantee through redundant documentation and Git-synced configs.

## Hardware Infrastructure

### Primary Compute Nodes

#### 1. SACCHAROMYCES (Primary Beast)
```yaml
designation: "Saccharomyces"
role: Primary development and orchestration node
status: ACTIVE
readiness: 85%

specifications:
  cpu: Intel Core i9-11900KF
    cores: 8
    threads: 16
    base_clock: 3.5 GHz
    boost_clock: 5.3 GHz
    tdp: 125W
  
  gpu: NVIDIA GeForce RTX 4060 Ti
    vram: 16GB GDDR6
    cuda_cores: 4352
    tensor_cores: 136
    compute_capability: 8.9
  
  memory:
    capacity: 128GB DDR4
    speed: 3200MHz
    configuration: 4x32GB
  
  storage:
    nvme_primary: Samsung 980 Pro 2TB (OS + Docker)
    nvme_secondary: WD Black SN850 2TB (Data + Models)
    sata_backup: 2x 4TB WD Red (RAID 1 backup)
  
  networking:
    ethernet: 2.5Gb Realtek
    wifi: WiFi 6 AX200
    tailscale: Configured (100.x.x.1)

current_workloads:
  - Docker host (45 containers)
  - Development environment
  - Ollama inference server
  - CrewAI orchestration
  - Git repository master

gaps:
  - Prometheus node exporter not installed
  - CUDA drivers need update to 545.23.08
  - Docker compose v2 migration pending
```

#### 2. CUDA-BEAST (New AI Powerhouse)
```yaml
designation: "CUDA-Beast"
role: Primary AI/ML compute and training
status: DEPLOYMENT_PENDING
readiness: 40%

specifications:
  cpu: AMD Ryzen 9 7950X3D
    cores: 16
    threads: 32
    base_clock: 4.2 GHz
    boost_clock: 5.7 GHz
    3d_vcache: 128MB
  
  gpu: NVIDIA GeForce RTX 5080 [PENDING]
    vram: 24GB GDDR7 [Expected]
    cuda_cores: ~10000 [Estimated]
    release_date: January 2026
  
  memory:
    capacity: 64GB DDR5
    speed: 6000MHz
    configuration: 2x32GB
  
  storage:
    nvme_primary: PCIe 5.0 2TB (TBD)
    nvme_models: 4TB dedicated for models
  
  networking:
    ethernet: 10Gb SFP+
    tailscale: Reserved (100.x.x.2)

planned_workloads:
  - Large model training
  - Batch inference
  - Video processing
  - Consciousness simulation

gaps:
  - Awaiting RTX 5080 release
  - Ubuntu 24.04 LTS installation pending
  - Cooling solution needed (360mm AIO)
```

#### 3. AI Laptop (Mobile Sales Intelligence)
```yaml
designation: "Mobile Phoenix"
role: Field deployment and sales intelligence
status: SPEC_DEFINITION
readiness: 0%

target_specifications:
  model: [Framework 16 | System76 Oryx Pro]
  cpu: AMD Ryzen 9 / Intel Core i9 mobile
  gpu: RTX 4070 mobile minimum
  memory: 64GB minimum
  battery: 10+ hours for field work

planned_deployment: Q2 2026
use_cases:
  - SPECTER v6 mobile deployment
  - Client demonstrations
  - Edge inference
  - Backup orchestration node
```

### Secondary Devices

#### Surface Fleet (3 Units)
```yaml
surface_pro_7:
  status: IDLE
  current_os: Windows 11
  planned_action: Flash Ubuntu 24.04 LTS
  role: Lightweight agent node
  tailscale: Reserved (100.x.x.10)

surface_laptop_3:
  status: IDLE
  current_os: Windows 10
  planned_action: Dual boot Ubuntu/Windows
  role: Development backup
  tailscale: Reserved (100.x.x.11)

surface_go_2:
  status: IDLE
  current_os: Windows 10 S
  planned_action: Kali Linux for security audits
  role: Penetration testing
  tailscale: Reserved (100.x.x.12)
```

### Network Infrastructure
```yaml
router:
  model: ASUS AX6000
  firmware: Merlin 388.4
  vpn: WireGuard configured
  vlans:
    - 10: Management
    - 20: Production
    - 30: Development
    - 40: IoT/Agents

switch:
  model: TP-Link TL-SG108E
  ports: 8x 1Gb
  managed: Yes
  lag_groups: Configured for NAS

ups:
  model: CyberPower CP1500PFCLCD
  capacity: 1500VA/1000W
  runtime: ~15 minutes at 70% load
  monitoring: USB to Saccharomyces
```

## Cloud Infrastructure

### VPS1 - Intelligence Router
```yaml
provider: Hetzner
designation: VPS1-INTELLIGENCE
status: PROVISIONING
readiness: 25%

specifications:
  type: CPX31
  vcpu: 4
  memory: 8GB
  storage: 160GB NVMe
  bandwidth: 20TB
  location: Falkenstein, Germany
  ipv4: [REDACTED]
  ipv6: [REDACTED]/64

planned_stack:
  orchestration:
    - Dokploy (Docker orchestration)
    - Portainer (backup management)
  
  routing:
    - LiteLLM router
    - AGNO queue manager
    - HAProxy load balancer
  
  workflow:
    - n8n (automation)
    - Apache Airflow (complex DAGs)
  
  databases:
    - PostgreSQL 16 (primary)
    - TimescaleDB (metrics)
    - Redis (cache/queues)
  
  monitoring:
    - Prometheus
    - Grafana
    - Loki (logs)

current_gaps:
  - Initial provisioning pending
  - Tailscale not configured
  - SSL certificates needed
  - Backup strategy undefined
```

### VPS2 - Web Fleet
```yaml
provider: DigitalOcean
designation: VPS2-WEBFLEET
status: PLANNING
readiness: 10%

specifications:
  type: Premium AMD 4GB
  vcpu: 2
  memory: 4GB
  storage: 80GB NVMe
  bandwidth: 4TB
  location: Toronto, Canada
  ipv4: [PENDING]

planned_stack:
  web_server:
    - NGINX (reverse proxy)
    - Caddy (automatic SSL)
  
  applications:
    - FastAPI (3 instances)
    - Svelte/SvelteKit
    - Directus CMS
  
  databases:
    - PostgreSQL 16 (replica)
    - SQLite (edge caches)
  
  monitoring:
    - Prometheus exporter
    - Uptime Kuma
    - Plausible Analytics

deployment_timeline: Q2 2026
```

## Software Stack

### Operating Systems
```yaml
primary_os:
  ubuntu_server: 24.04 LTS
    usage: Production servers
    kernel: 6.8.0-45
    security: UFW + fail2ban
  
  ubuntu_desktop: 24.04 LTS
    usage: Development machines
    de: GNOME 46
  
  windows_11_pro:
    usage: Legacy support
    wsl2: Ubuntu 24.04
    docker_desktop: Latest

specialized:
  kali_linux: 2025.1
    usage: Security auditing
    tools: Full pentest suite
  
  alpine_linux: 3.19
    usage: Container base images
    size: <5MB base
```

### Container Orchestration
```yaml
docker:
  version: 25.0.3
  compose: 2.24.5
  storage_driver: overlay2
  runtime: nvidia-container-runtime
  
  current_containers: 45
  images_cached: 127
  volumes: 23
  networks: 8

dokploy:
  version: latest
  status: Testing on staging
  features:
    - Multi-server orchestration
    - Automatic SSL
    - GitHub integration
    - Built-in monitoring

future_migration:
  kubernetes:
    target_date: Q3 2026
    distribution: k3s
    reason: Scale beyond 100 containers
```

### AI/ML Stack
```yaml
inference_servers:
  ollama:
    version: 0.3.12
    models:
      - llama3.2:3b
      - mistral:7b
      - codellama:13b
      - nomic-embed-text
    vram_usage: 12GB
  
  litellm:
    version: 1.48.0
    providers:
      - openai
      - anthropic
      - google
      - local-ollama
    
  vllm:
    version: 0.5.5
    status: Testing
    target: High-throughput serving

frameworks:
  pytorch: 2.5.0+cu124
  transformers: 4.44.0
  langchain: 0.3.0
  crewai: 0.70.1
  autogen: 0.3.0

model_management:
  huggingface_cache: /models/hf
  model_size_total: 847GB
  pruning_schedule: Weekly
```

### Development Tools
```yaml
editors_ides:
  vscode:
    version: 1.94.0
    extensions:
      - Python
      - Docker
      - GitLens
      - Copilot
      - Remote-SSH
  
  cursor:
    version: 0.41.0
    ai_enabled: true
    model: Claude-3.5-Sonnet

  neovim:
    version: 0.10.0
    config: LazyVim
    lsp_servers: 15 configured

version_control:
  git: 2.43.0
  github_cli: 2.50.0
  git_lfs: 3.5.1
  
  repositories:
    total: 47
    phoenix_core: private
    phoenix_agents: private
    phoenix_web: private

ci_cd:
  github_actions: Configured
  act: 0.2.65 (local runner)
  drone: Planning for self-hosted
```

### Database Stack
```yaml
postgresql:
  version: 16.2
  extensions:
    - pgvector
    - timescaledb
    - pg_cron
    - pgcrypto
    - postgis
  
  databases:
    phoenix_core: 4.7GB
    specter_intel: 2.3GB
    test_environments: 12
  
  replication: Streaming to standby
  backup: pgBackRest configured

redis:
  version: 7.2.4
  mode: Standalone (cluster planned)
  persistence: AOF enabled
  memory_usage: 2.3GB
  
  use_cases:
    - Session storage
    - Task queues
    - Pub/sub messaging
    - Cache layer

neo4j:
  version: 5.18.0
  status: Testing
  heap_memory: 4GB
  database_size: 890MB
  
  use_case: Knowledge graph
```

### Monitoring & Observability
```yaml
prometheus:
  version: 2.53.0
  scrape_interval: 15s
  retention: 30d
  targets: 23
  
  exporters:
    - node_exporter: 8 instances
    - postgres_exporter: 2 instances
    - redis_exporter: 1 instance
    - nvidia_gpu_exporter: 2 instances

grafana:
  version: 11.2.0
  datasources:
    - Prometheus
    - PostgreSQL
    - Loki
  
  dashboards:
    - System Overview
    - AI Model Performance
    - Database Metrics
    - Consciousness Tracker
  
  alerts: 47 configured

logging:
  loki: 3.0.0
  promtail: 3.0.0
  vector: 0.40.0 (evaluating)
```

### Security Tools
```yaml
network_security:
  wireguard:
    version: 1.0.20210914
    peers: 12 configured
    bandwidth_usage: ~500GB/month
  
  tailscale:
    version: 1.72.0
    devices: 8 authorized
    subnet_router: Enabled on Saccharomyces
    exit_node: Configured
  
  nginx:
    version: 1.26.0
    modsecurity: Enabled
    rate_limiting: Configured
    ssl_rating: A+

scanning_tools:
  nmap: 7.95
  masscan: 1.3.2
  nuclei: 3.2.0
  metasploit: 6.3.0
  burp_suite: Community 2025.1

secrets_management:
  vault: Planning deployment
  sops: 3.9.0
  age: 1.2.0
  git_crypt: 0.7.0
```

### Automation & Workflow
```yaml
n8n:
  version: 1.59.0
  workflows: 34 active
  executions_daily: ~1200
  
  integrations:
    - PostgreSQL
    - Redis  
    - Slack
    - HubSpot
    - LinkedIn
    - OpenAI
    - Google Sheets

ansible:
  version: 9.0.0
  playbooks: 23
  roles: 15
  inventory: Dynamic from Tailscale
  
  use_cases:
    - Server provisioning
    - Configuration management
    - Deployment automation

terraform:
  version: 1.9.0
  providers:
    - hetzner
    - digitalocean
    - cloudflare
  
  state: Remote (S3 compatible)
```

### Communication & Collaboration
```yaml
planned_deployment:
  mattermost:
    version: 9.11.0
    purpose: Slack replacement
    deployment: Q2 2026
    integrations:
      - Webhooks for agents
      - GitLab/GitHub
      - Prometheus alerts
  
  matrix_synapse:
    purpose: Federated communication
    status: Evaluation phase
  
  lemmy:
    version: 0.19.5
    purpose: Task voting/discussion
    deployment: Q3 2026
```

## Gap Analysis

### Critical Gaps (Phase 1-2)
```yaml
high_priority:
  - CUDA-Beast hardware pending (RTX 5080)
  - VPS1 not fully provisioned
  - No backup strategy implemented
  - Prometheus incomplete deployment
  - SSL certificates not configured
  - Tailscale mesh incomplete

medium_priority:
  - Docker compose v2 migration
  - PostgreSQL replication setup
  - Redis clustering
  - Grafana dashboards incomplete
  - n8n workflow backups missing
```

### Infrastructure Debt
```yaml
technical_debt:
  - 17 Docker containers without health checks
  - Mixed authentication methods (need SSO)
  - Inconsistent logging formats
  - No centralized secret management
  - Manual deployment processes
  - Missing disaster recovery plan

security_debt:
  - 3 services exposed without authentication
  - SSL certificates expiring in 30 days
  - No automated security scanning
  - Firewall rules need audit
  - Missing intrusion detection system
```

## Upgrade Path (Fibonacci Scaled)

### Phase 1 (Immediate)
```bash
# Priority upgrades
apt update && apt upgrade -y
docker compose version  # Verify v2
nvidia-smi  # Verify CUDA
tailscale up  # Complete mesh
```

### Phase 2-3 (Q1 2026)
- Deploy CUDA-Beast with RTX 5080
- Complete VPS1 intelligence router
- Implement backup strategy
- Deploy Prometheus/Grafana fully

### Phase 5-8 (Q2-Q3 2026)
- Launch VPS2 web fleet
- Deploy Mattermost/Lemmy
- Implement Vault for secrets
- Begin Kubernetes migration prep

### Phase 13+ (Q4 2026)
- Full Kubernetes migration
- Multi-region deployment
- Complete observability stack
- Blockchain integration

## Resource Utilization

### Current Usage
```yaml
saccharomyces:
  cpu_average: 47%
  memory_used: 89GB/128GB (69%)
  gpu_utilization: 34%
  disk_usage: 2.8TB/6TB (47%)
  network_daily: ~45GB
  
  bottlenecks:
    - Memory during large model loads
    - GPU VRAM for batched inference
    - Network during backup windows

optimization_opportunities:
  - Implement model quantization
  - Schedule batch jobs off-peak
  - Compress Docker layers
  - Prune unused volumes
```

### Capacity Planning
```yaml
growth_projections:
  q1_2026:
    containers: 45 -> 75
    storage: 3TB -> 5TB
    bandwidth: 1.5TB -> 3TB/month
  
  q2_2026:
    containers: 75 -> 150
    storage: 5TB -> 12TB
    bandwidth: 3TB -> 10TB/month
  
  q4_2026:
    containers: 150 -> 500+
    storage: 12TB -> 50TB
    bandwidth: 10TB -> 100TB/month
```

## Maintenance Schedule

### Daily Tasks
```yaml
automated:
  - Database backups (02:00 UTC)
  - Log rotation (00:00 local)
  - Security updates check
  - Container health checks
  - Metrics collection

manual_review:
  - Prometheus alerts
  - Failed job queue
  - Resource utilization
```

### Weekly Tasks
```yaml
sundays:
  - Full system backup
  - Docker image pruning
  - Security scan (Trivy)
  - Performance review
  - Model cache cleanup
```

### Monthly Tasks
```yaml
first_monday:
  - Infrastructure audit
  - Capacity review
  - Cost optimization
  - Security patches
  - Disaster recovery test
```

## Cost Analysis

### Current Monthly Costs
```yaml
infrastructure:
  vps1_hetzner: €15.90
  vps2_digital_ocean: $24 (planned)
  domain_names: $45
  ssl_certificates: $0 (Let's Encrypt)
  backup_storage: $12
  
  total_current: ~$75/month

projected_q2_2026: ~$250/month
projected_q4_2026: ~$1,500/month

roi_calculation:
  break_even: 2 closed deals
  target_efficiency: $0.015 per agent-hour
```

## Documentation Status

### Completed
- [x] System architecture diagram
- [x] Network topology
- [x] Deployment procedures
- [x] This inventory audit

### In Progress
- [ ] API documentation (40%)
- [ ] Runbook automation (25%)
- [ ] Security policies (60%)
- [ ] Disaster recovery plan (30%)

### Not Started
- [ ] Kubernetes migration guide
- [ ] Performance tuning guide
- [ ] Compliance documentation
- [ ] Training materials

---

*"Infrastructure is code; code is law; law is automated." - Phoenix Axiom #3*
