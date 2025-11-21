[497K]  [01;34m.[0m/
|-- [8.1K]  [01;34m.archive[0m/
|   `-- [4.1K]  [01;34mmigration-from-mnt-c-dev[0m/
|       |-- [  16]  MIGRATION_DATE.txt
|       `-- [  60]  README.txt
|-- [ 19K]  [01;34mbin[0m/
|   |-- [1.5K]  [01;32mgpu_monitor.sh[0m*
|   |-- [ 570]  [01;32mphoenix-essential-models.sh[0m*
|   |-- [2.9K]  [01;32mphoenix-health-check.sh[0m*
|   |-- [5.8K]  [01;32mphoenix-menu.sh[0m*
|   `-- [4.6K]  [01;32mphoenix-status.sh[0m*
|-- [232K]  [01;34metc[0m/
|   |-- [ 18K]  [01;34mcompose[0m/
|   |   |-- [ 507]  .env
|   |   |-- [4.5K]  docker-compose.tier1.yml
|   |   |-- [2.5K]  docker-compose.tier2.yml
|   |   |-- [4.3K]  docker-compose.tier3.yml
|   |   `-- [2.3K]  docker-compose.tier4.yml
|   |-- [4.2K]  [01;34mmodels[0m/
|   |   |-- [  89]  balanced.txt
|   |   |-- [  64]  essential.txt
|   |   `-- [ 102]  power.txt
|   |-- [ 22K]  [01;34mobservability[0m/
|   |   |-- [ 13K]  [01;34mgrafana[0m/
|   |   |   |-- [4.0K]  [01;34mdashboards[0m/
|   |   |   `-- [4.7K]  [01;34mdatasources[0m/
|   |   |       `-- [ 676]  datasources.yml
|   |   |-- [4.5K]  [01;34mprometheus[0m/
|   |   |   `-- [ 527]  prometheus.yml
|   |   `-- [ 382]  production.yaml
|   |-- [176K]  [01;34mschemas[0m/
|   |   |-- [168K]  [01;34mshadow_specter_db[0m/
|   |   |   |-- [ 22K]  DEPLOYMENT_GUIDE.md
|   |   |   |-- [ 25K]  PHOENIX_SHADOW_DB_MASTER_ARCHITECTURE.md
|   |   |   |-- [ 16K]  SCHEMA_01_CORE.sql
|   |   |   |-- [ 16K]  SCHEMA_01_CORE_FIXED.sql
|   |   |   |-- [ 23K]  SCHEMA_02_EVENTS.sql
|   |   |   |-- [ 11K]  SCHEMA_03_INTELLIGENCE.sql
|   |   |   |-- [ 17K]  SCHEMA_04_AGENTS.sql
|   |   |   |-- [ 19K]  SCHEMA_05_NEUROSCIENCE.sql
|   |   |   `-- [ 15K]  SCHEMA_06_ENRICHMENT_PRODUCTS.sql
|   |   |-- [3.4K]  00_agent_federation.sql
|   |   `-- [1.0K]  init.sql
|   |-- [4.0K]  [01;34msecrets[0m/
|   `-- [4.0K]  [01;34mtailscale[0m/
|-- [ 11K]  [01;34mlib[0m/
|   |-- [4.8K]  [01;34mpython[0m/
|   |   `-- [ 828]  requirements.txt
|   `-- [2.3K]  phoenix-functions.sh
|-- [ 11K]  [01;34msbin[0m/
|   |-- [1.1K]  [01;32mphoenix-boot.sh[0m*
|   |-- [2.3K]  [01;32mphoenix-resurrect[0m*
|   `-- [3.3K]  [01;32mvalidate-alpha-status.sh[0m*
|-- [ 70K]  [01;34mshare[0m/
|   |-- [ 17K]  [01;34mdocs[0m/
|   |   |-- [1.5K]  CLAUDE.md
|   |   |-- [4.8K]  CLAUDE_CONTEXT.md
|   |   |-- [ 751]  GRAFANA_DASHBOARDS.md
|   |   |-- [1.2K]  MODEL_GUIDE.md
|   |   |-- [4.4K]  QUICK_REFERENCE.md
|   |   `-- [   0]  README.md
|   |-- [ 33K]  [01;34mdotfiles[0m/
|   |   |-- [ 26K]  bashrc-phoenix
|   |   |-- [   0]  gitconfig
|   |   |-- [2.9K]  oh-my-posh-theme.json
|   |   |-- [   0]  tmux.conf
|   |   `-- [   0]  vimrc
|   |-- [7.5K]  [01;34mmotd[0m/
|   |   |-- [1.8K]  phoenix-banner.txt
|   |   `-- [1.8K]  phoenix-commands.txt
|   `-- [9.1K]  [01;34mtemplates[0m/
|       `-- [5.1K]  .env.template
|-- [ 63K]  [01;34msrv[0m/
|   |-- [ 23K]  [01;34magents[0m/
|   |   |-- [4.0K]  [01;34mguardians[0m/
|   |   |-- [4.0K]  [01;34moracles[0m/
|   |   |-- [4.0K]  [01;34mseekers[0m/
|   |   `-- [7.1K]  task_board_api.py
|   |-- [ 28K]  [01;34mcrewai[0m/
|   |   |-- [5.8K]  [01;34magents[0m/
|   |   |   `-- [1.8K]  alpha_1_data_miner.py
|   |   |-- [4.0K]  [01;34mcrews[0m/
|   |   |-- [4.9K]  [01;34mtasks[0m/
|   |   |   `-- [ 964]  data_extraction.py
|   |   |-- [4.0K]  [01;34mtools[0m/
|   |   `-- [5.3K]  test_alpha1_flow.py
|   `-- [8.0K]  [01;34mworkflows[0m/
|       `-- [4.0K]  [01;34mproduction[0m/
|-- [ 64K]  [01;34mvar[0m/
|   |-- [ 12K]  [01;34mbackups[0m/
|   |   |-- [4.0K]  [01;34mpostgres[0m/
|   |   `-- [4.0K]  [01;34mredis[0m/
|   |-- [ 36K]  [01;34mdata[0m/
|   |   |-- [4.0K]  [01;34mgrafana[0m/
|   |   |-- [4.0K]  [01;34mn8n[0m/
|   |   |-- [4.0K]  [01;34mollama[0m/
|   |   |-- [4.0K]  [01;34mportainer[0m/
|   |   |-- [4.0K]  [01;34mpostgres[0m/
|   |   |-- [4.0K]  [01;34mprometheus[0m/
|   |   |-- [4.0K]  [01;34mqdrant[0m/
|   |   `-- [4.0K]  [01;34mredis[0m/
|   |-- [8.0K]  [01;34mlogs[0m/
|   |   `-- [4.0K]  [01;34mservices[0m/
|   `-- [4.0K]  [01;34mstate[0m/
|-- [5.1K]  .env.example
|-- [4.3K]  .gitignore
|-- [  20]  [01;36mREADME.md[0m -> share/docs/README.md
|-- [4.6K]  phoenix_tree-1118-2154.md
`-- [   0]  system_memory.md

 1.4M used in 52 directories, 57 files

=== SUMMARY ===
Total Size: 2.7M
File Count: 53
Dir Count: 53
