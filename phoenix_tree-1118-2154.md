[     480537]  [01;34m.[0m
|-- [      19845]  [01;34mbin[0m
|   |-- [       1499]  [01;32mgpu_monitor.sh[0m
|   |-- [        570]  [01;32mphoenix-essential-models.sh[0m
|   |-- [       3001]  [01;32mphoenix-health-check.sh[0m
|   |-- [       5966]  [01;32mphoenix-menu.sh[0m
|   `-- [       4713]  [01;32mphoenix-status.sh[0m
|-- [     237284]  [01;34metc[0m
|   |-- [      17954]  [01;34mcompose[0m
|   |   |-- [       4589]  docker-compose.tier1.yml
|   |   |-- [       2532]  docker-compose.tier2.yml
|   |   |-- [       4360]  docker-compose.tier3.yml
|   |   `-- [       2377]  docker-compose.tier4.yml
|   |-- [       4351]  [01;34mmodels[0m
|   |   |-- [         89]  balanced.txt
|   |   |-- [         64]  essential.txt
|   |   `-- [        102]  power.txt
|   |-- [      22065]  [01;34mobservability[0m
|   |   |-- [      12964]  [01;34mgrafana[0m
|   |   |   |-- [       4096]  [01;34mdashboards[0m
|   |   |   `-- [       4772]  [01;34mdatasources[0m
|   |   |       `-- [        676]  datasources.yml
|   |   |-- [       4623]  [01;34mprometheus[0m
|   |   |   `-- [        527]  prometheus.yml
|   |   `-- [        382]  production.yaml
|   |-- [     180626]  [01;34mschemas[0m
|   |   |-- [     172015]  [01;34mshadow_specter_db[0m
|   |   |   |-- [      22535]  DEPLOYMENT_GUIDE.md
|   |   |   |-- [      25657]  PHOENIX_SHADOW_DB_MASTER_ARCHITECTURE.md
|   |   |   |-- [      16375]  SCHEMA_01_CORE.sql
|   |   |   |-- [      16375]  SCHEMA_01_CORE_FIXED.sql
|   |   |   |-- [      23752]  SCHEMA_02_EVENTS.sql
|   |   |   |-- [      11351]  SCHEMA_03_INTELLIGENCE.sql
|   |   |   |-- [      17549]  SCHEMA_04_AGENTS.sql
|   |   |   |-- [      19236]  SCHEMA_05_NEUROSCIENCE.sql
|   |   |   `-- [      15089]  SCHEMA_06_ENRICHMENT_PRODUCTS.sql
|   |   |-- [       3443]  00_agent_federation.sql
|   |   `-- [       1072]  init.sql
|   |-- [       4096]  [01;34msecrets[0m
|   `-- [       4096]  [01;34mtailscale[0m
|-- [      11359]  [01;34mlib[0m
|   |-- [       4924]  [01;34mpython[0m
|   |   `-- [        828]  requirements.txt
|   `-- [       2339]  phoenix-functions.sh
|-- [      11049]  [01;34msbin[0m
|   |-- [       1177]  [01;32mphoenix-boot.sh[0m
|   |-- [       2389]  [01;32mphoenix-resurrect[0m
|   `-- [       3387]  [01;32mvalidate-alpha-status.sh[0m
|-- [      66765]  [01;34mshare[0m
|   |-- [      16999]  [01;34mdocs[0m
|   |   |-- [       1505]  CLAUDE.md
|   |   |-- [       4883]  CLAUDE_CONTEXT.md
|   |   |-- [        751]  GRAFANA_DASHBOARDS.md
|   |   |-- [       1244]  MODEL_GUIDE.md
|   |   |-- [       4520]  QUICK_REFERENCE.md
|   |   `-- [          0]  README.md
|   |-- [      33850]  [01;34mdotfiles[0m
|   |   |-- [      26777]  bashrc-phoenix
|   |   |-- [          0]  gitconfig
|   |   |-- [       2977]  oh-my-posh-theme.json
|   |   |-- [          0]  tmux.conf
|   |   `-- [          0]  vimrc
|   |-- [       7724]  [01;34mmotd[0m
|   |   |-- [       1798]  phoenix-banner.txt
|   |   `-- [       1830]  phoenix-commands.txt
|   `-- [       4096]  [01;34mtemplates[0m
|-- [      64583]  [01;34msrv[0m
|   |-- [      23624]  [01;34magents[0m
|   |   |-- [       4096]  [01;34mguardians[0m
|   |   |-- [       4096]  [01;34moracles[0m
|   |   |-- [       4096]  [01;34mseekers[0m
|   |   `-- [       7240]  task_board_api.py
|   |-- [      28671]  [01;34mcrewai[0m
|   |   |-- [       5920]  [01;34magents[0m
|   |   |   `-- [       1824]  alpha_1_data_miner.py
|   |   |-- [       4096]  [01;34mcrews[0m
|   |   |-- [       5060]  [01;34mtasks[0m
|   |   |   `-- [        964]  data_extraction.py
|   |   |-- [       4096]  [01;34mtools[0m
|   |   `-- [       5403]  test_alpha1_flow.py
|   `-- [       8192]  [01;34mworkflows[0m
|       `-- [       4096]  [01;34mproduction[0m
|-- [      65536]  [01;34mvar[0m
|   |-- [      12288]  [01;34mbackups[0m
|   |   |-- [       4096]  [01;34mpostgres[0m
|   |   `-- [       4096]  [01;34mredis[0m
|   |-- [      36864]  [01;34mdata[0m
|   |   |-- [       4096]  [01;34mgrafana[0m
|   |   |-- [       4096]  [01;34mn8n[0m
|   |   |-- [       4096]  [01;34mollama[0m
|   |   |-- [       4096]  [01;34mportainer[0m
|   |   |-- [       4096]  [01;34mpostgres[0m
|   |   |-- [       4096]  [01;34mprometheus[0m
|   |   |-- [       4096]  [01;34mqdrant[0m
|   |   `-- [       4096]  [01;34mredis[0m
|   |-- [       8192]  [01;34mlogs[0m
|   |   `-- [       4096]  [01;34mservices[0m
|   `-- [       4096]  [01;34mstate[0m
|-- [         20]  [01;36mREADME.md[0m -> share/docs/README.md
`-- [          0]  phoenix_tree-1118-2154.md

     1453948 bytes used in 50 directories, 50 files
