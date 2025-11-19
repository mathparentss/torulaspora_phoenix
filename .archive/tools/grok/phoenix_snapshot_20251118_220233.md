# PHOENIX COMPLETE SYSTEM SNAPSHOT
Generated: Tue Nov 18 22:02:33 EST 2025
Hostname: Torulaspora
User: phoenix

---

## 1. SYSTEM INFORMATION

### Kernel & OS
```
Linux Torulaspora 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux

PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

### CPU Info
```
CPU(s):                               24
On-line CPU(s) list:                  0-23
Model name:                           AMD Ryzen AI 9 HX 370 w/ Radeon 890M
Thread(s) per core:                   2
Core(s) per socket:                   12
NUMA node0 CPU(s):                    0-23
```

### Memory
```
               total        used        free      shared  buff/cache   available
Mem:            30Gi       2.9Gi        27Gi       204Mi       1.5Gi        27Gi
Swap:          8.0Gi          0B       8.0Gi
```

### Disk Usage
```
df: /mnt/4tb: No such device
Filesystem      Size  Used Avail Use% Mounted on
none             16G     0   16G   0% /usr/lib/modules/6.6.87.2-microsoft-standard-WSL2
none             16G  4.0K   16G   1% /mnt/wsl
drivers         1.9T  1.7T  214G  89% /usr/lib/wsl/drivers
/dev/sdd       1007G  167G  790G  18% /
none             16G  240K   16G   1% /mnt/wslg
none             16G     0   16G   0% /usr/lib/wsl/lib
rootfs           16G  2.7M   16G   1% /init
none             16G  1.9M   16G   1% /run
none             16G     0   16G   0% /run/lock
none             16G     0   16G   0% /run/shm
none             16G   76K   16G   1% /mnt/wslg/versions.txt
none             16G   76K   16G   1% /mnt/wslg/doc
C:\             1.9T  1.7T  214G  89% /mnt/c
tmpfs           3.1G   20K  3.1G   1% /run/user/1000
```

### Network Interfaces
```
lo               UNKNOWN        127.0.0.1/8 10.255.255.254/32 ::1/128 
eth0             UP             172.19.174.195/20 fe80::215:5dff:fe33:3934/64 
docker0          DOWN           172.17.0.1/16 fe80::1807:6aff:fe28:bbca/64 
br-c70663476c20  UP             172.18.0.1/16 fe80::cc3c:28ff:fedb:1ccc/64 
vethff6694c@if2  UP             fe80::4447:56ff:fe3f:c8a1/64 
br-261be00f42b0  UP             172.20.0.1/16 fe80::60b5:bcff:fe59:3bca/64 
br-96c53b5e54f4  UP             172.21.0.1/16 fe80::dc85:dfff:fe56:88b7/64 
veth7dab0c0@if2  UP             fe80::f8c9:e2ff:fe45:7ebc/64 
veth803939e@if2  UP             fe80::dc3c:29ff:fe60:ac8c/64 
veth01f6d1b@if2  UP             fe80::1c2b:8ff:fe4b:7adb/64 
vethd1e79dd@if3  UP             fe80::b871:dcff:fe83:1d0c/64 
veth2fe1b24@if3  UP             fe80::3cf1:7bff:fe32:606e/64 
veth5b81126@if4  UP             fe80::60cc:47ff:fe05:9430/64 
veth1730ec3@if2  UP             fe80::e44e:58ff:fe26:c318/64 
veth0ac9bb0@if3  UP             fe80::c8ef:38ff:fe7e:1b53/64 
veth4561da7@if4  UP             fe80::403e:baff:febf:8e92/64 
vethd067e41@if2  UP             fe80::c8a4:c4ff:fec3:e69a/64 
veth2657bc7@if3  UP             fe80::b059:46ff:fef4:cb76/64 
veth3a48e2c@if4  UP             fe80::bc1a:33ff:fe14:514a/64 
veth80e24c4@if2  UP             fe80::9ce1:a0ff:fe0a:f06c/64 
veth5b9e837@if2  UP             fe80::e0de:66ff:fed4:a35f/64 
vethe38f3da@if2  UP             fe80::4d9:92ff:fec1:b1fb/64 
vethb9501dd@if3  UP             fe80::e827:f0ff:fed7:5ee/64 
vethfc09e3c@if2  UP             fe80::a05a:43ff:fe42:eed5/64 
veth842b0d7@if3  UP             fe80::3468:eaff:fe27:267d/64 
veth9537c65@if2  UP             fe80::1812:88ff:fe48:e892/64 
veth4f52f3a@if3  UP             fe80::854:92ff:fe38:dcdb/64 
veth6af38a7@if2  UP             fe80::38f4:68ff:fe1f:cc14/64 
veth1b3c0d9@if3  UP             fe80::24a8:3dff:fefc:6a28/64 
vetheb6555a@if2  UP             fe80::1c6b:43ff:fe25:d353/64 
```

## 2. DOCKER STATUS

### Docker Version
```
Docker version 28.2.2, build 28.2.2-0ubuntu1~24.04.1
```

### Running Containers
```
NAMES                       IMAGE                                          STATUS                    PORTS                                                          SIZE
phoenix_qdrant              qdrant/qdrant:latest                           Up 24 hours               127.0.0.1:6333-6334->6333-6334/tcp                             0B (virtual 178MB)
phoenix_ollama              ollama/ollama:latest                           Up 24 hours (unhealthy)   127.0.0.1:11434->11434/tcp                                     16.3kB (virtual 3.75GB)
phoenix_postgres_exporter   prometheuscommunity/postgres-exporter:latest   Up 47 hours               127.0.0.1:9187->9187/tcp                                       0B (virtual 22.7MB)
phoenix_redis_exporter      oliver006/redis_exporter:latest                Up 47 hours               127.0.0.1:9121->9121/tcp                                       0B (virtual 9.98MB)
phoenix_node_exporter       prom/node-exporter:latest                      Up 47 hours               127.0.0.1:9100->9100/tcp                                       0B (virtual 25.7MB)
phoenix_cadvisor            gcr.io/cadvisor/cadvisor:latest                Up 47 hours (healthy)     127.0.0.1:8081->8080/tcp                                       0B (virtual 80.8MB)
phoenix_grafana             grafana/grafana:latest                         Up 2 days                 127.0.0.1:3000->3000/tcp                                       0B (virtual 730MB)
phoenix_adminer             adminer:latest                                 Up 2 days                 127.0.0.1:8080->8080/tcp                                       89.8kB (virtual 118MB)
phoenix_n8n                 n8nio/n8n:latest                               Up 2 days                 127.0.0.1:5678->5678/tcp                                       45.7MB (virtual 1.02GB)
phoenix_portainer           portainer/portainer-ce:latest                  Up 2 days                 127.0.0.1:9000->9000/tcp, 8000/tcp, 127.0.0.1:9443->9443/tcp   0B (virtual 186MB)
phoenix_prometheus          prom/prometheus:latest                         Up 47 hours               127.0.0.1:9090->9090/tcp                                       0B (virtual 370MB)
phoenix_redis               redis:7.2-alpine                               Up 2 days (healthy)       127.0.0.1:6379->6379/tcp                                       0B (virtual 40.9MB)
phoenix_postgres            pgvector/pgvector:pg16                         Up 23 hours (healthy)     127.0.0.1:5432->5432/tcp                                       23.9MB (virtual 530MB)
```

### All Containers (including stopped)
```
NAMES                       IMAGE                                          STATUS                    SIZE
phoenix_qdrant              qdrant/qdrant:latest                           Up 24 hours               0B (virtual 178MB)
phoenix_ollama              ollama/ollama:latest                           Up 24 hours (unhealthy)   16.3kB (virtual 3.75GB)
phoenix_postgres_exporter   prometheuscommunity/postgres-exporter:latest   Up 47 hours               0B (virtual 22.7MB)
phoenix_redis_exporter      oliver006/redis_exporter:latest                Up 47 hours               0B (virtual 9.98MB)
phoenix_node_exporter       prom/node-exporter:latest                      Up 47 hours               0B (virtual 25.7MB)
phoenix_cadvisor            gcr.io/cadvisor/cadvisor:latest                Up 47 hours (healthy)     0B (virtual 80.8MB)
phoenix_grafana             grafana/grafana:latest                         Up 2 days                 0B (virtual 730MB)
phoenix_adminer             adminer:latest                                 Up 2 days                 89.8kB (virtual 118MB)
phoenix_n8n                 n8nio/n8n:latest                               Up 2 days                 45.7MB (virtual 1.02GB)
phoenix_portainer           portainer/portainer-ce:latest                  Up 2 days                 0B (virtual 186MB)
phoenix_prometheus          prom/prometheus:latest                         Up 47 hours               0B (virtual 370MB)
phoenix_redis               redis:7.2-alpine                               Up 2 days (healthy)       0B (virtual 40.9MB)
phoenix_postgres            pgvector/pgvector:pg16                         Up 23 hours (healthy)     23.9MB (virtual 530MB)
```

### Docker Images
```
REPOSITORY:TAG                                 SIZE      CREATED AT
n8nio/n8n:latest                               978MB     2025-11-14 11:54:04 -0500 EST
pgvector/pgvector:pg16                         507MB     2025-11-13 18:06:04 -0500 EST
ollama/ollama:latest                           3.75GB    2025-11-13 17:17:08 -0500 EST
redis:7.2-alpine                               40.9MB    2025-11-03 12:40:34 -0500 EST
oliver006/redis_exporter:latest                9.98MB    2025-11-02 21:17:36 -0500 EST
prom/prometheus:latest                         370MB     2025-10-30 03:57:14 -0400 EDT
portainer/portainer-ce:latest                  186MB     2025-10-29 19:45:02 -0400 EDT
prom/node-exporter:latest                      25.7MB    2025-10-25 16:11:06 -0400 EDT
grafana/grafana:latest                         730MB     2025-10-20 11:02:25 -0400 EDT
adminer:latest                                 118MB     2025-10-15 13:23:32 -0400 EDT
qdrant/qdrant:latest                           178MB     2025-09-30 06:22:27 -0400 EDT
prometheuscommunity/postgres-exporter:latest   22.7MB    2025-09-29 13:19:25 -0400 EDT
gcr.io/cadvisor/cadvisor:latest                80.8MB    2024-03-02 15:59:01 -0500 EST
nvidia/cuda:12.0.0-base-ubuntu22.04            237MB     2023-11-10 01:31:52 -0500 EST
nvidia/cuda:12.2.0-base-ubuntu22.04            239MB     2023-11-09 23:56:33 -0500 EST
```

### Docker Volumes
```
DRIVER    VOLUME NAME
local     phoenix_grafana_data
local     phoenix_n8n_data
local     phoenix_ollama_data
local     phoenix_portainer_data
local     phoenix_postgres_data
local     phoenix_prometheus_data
local     phoenix_qdrant_data
local     phoenix_redis_data
```

### Docker Networks
```
NETWORK ID     NAME            DRIVER    SCOPE
67bfba537217   bridge          bridge    local
7fe83a642950   host            host      local
54a60e20a9dd   none            null      local
c70663476c20   phoenix_tier1   bridge    local
261be00f42b0   phoenix_tier2   bridge    local
96c53b5e54f4   phoenix_tier3   bridge    local
```

### Docker Disk Usage
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        13        7.37GB    409.1MB (5%)
Containers      13        13        69.68MB   0B (0%)
Local Volumes   8         8         162.2GB   0B (0%)
Build Cache     0         0         0B        0B
```

## 3. RUNNING SERVICES
```
  UNIT                        LOAD   ACTIVE SUB     DESCRIPTION
  console-getty.service       loaded active running Console Getty
  containerd.service          loaded active running containerd container runtime
  cron.service                loaded active running Regular background program processing daemon
  dbus.service                loaded active running D-Bus System Message Bus
  docker.service              loaded active running Docker Application Container Engine
  fail2ban.service            loaded active running Fail2Ban Service
  getty@tty1.service          loaded active running Getty on tty1
  polkit.service              loaded active running Authorization Manager
  rsyslog.service             loaded active running System Logging Service
  systemd-journald.service    loaded active running Journal Service
  systemd-logind.service      loaded active running User Login Management
  systemd-resolved.service    loaded active running Network Name Resolution
  systemd-timesyncd.service   loaded active running Network Time Synchronization
  systemd-udevd.service       loaded active running Rule-based Manager for Device Events and Files
  unattended-upgrades.service loaded active running Unattended Upgrades Shutdown
  user@1000.service           loaded active running User Manager for UID 1000

Legend: LOAD   → Reflects whether the unit definition was properly loaded.
        ACTIVE → The high-level unit activation state, i.e. generalization of SUB.
        SUB    → The low-level unit activation state, values depend on unit type.

16 loaded units listed.
```

## 4. COMPLETE FILE TREE (Permissions + Sizes)

### Tree with Full Details
```
[drwxrwxrwx phoenix  phoenix  4.0K Nov 18 22:02]  .
|-- [-rwxrwxrwx phoenix  phoenix  3.3K Nov 18 21:47]  ./phoenix_builder_grok_council_bible.yaml
|-- [-rwxrwxrwx phoenix  phoenix  2.4K Nov 18 21:44]  ./phoenix_builder_grok_sysprompt.yaml
|-- [-rwxrwxrwx phoenix  phoenix  5.3K Nov 18 22:02]  ./phoenix_snapshot.sh
`-- [-rwxrwxrwx phoenix  phoenix   12K Nov 18  2025]  ./phoenix_snapshot_20251118_220233.md

1 directory, 4 files
```

## 5. ALL FILES (Permissions, Size, Path)

```
-rwxrwxrwx 13K      ./phoenix_snapshot_20251118_220233.md
-rwxrwxrwx 3.3K     ./phoenix_builder_grok_council_bible.yaml
-rwxrwxrwx 2.5K     ./phoenix_builder_grok_sysprompt.yaml
-rwxrwxrwx 5.3K     ./phoenix_snapshot.sh
```

## 6. LARGEST FILES (Top 50)
```
16K	./phoenix_snapshot_20251118_220233.md
8.0K	./phoenix_snapshot.sh
4.0K	./phoenix_builder_grok_sysprompt.yaml
4.0K	./phoenix_builder_grok_council_bible.yaml
```

## 7. KEY CONFIGURATION FILES

### Docker Compose Files
```
```

### Environment Files
```
```

### Shell Scripts
```
./phoenix_snapshot.sh
```

## 8. LISTENING PORTS
```
Netid State  Recv-Q Send-Q  Local Address:Port  Peer Address:PortProcess
udp   UNCONN 0      0          127.0.0.54:53         0.0.0.0:*          
udp   UNCONN 0      0       127.0.0.53%lo:53         0.0.0.0:*          
udp   UNCONN 0      0      10.255.255.254:53         0.0.0.0:*          
udp   UNCONN 0      0           127.0.0.1:323        0.0.0.0:*          
udp   UNCONN 0      0               [::1]:323           [::]:*          
tcp   LISTEN 0      4096        127.0.0.1:11434      0.0.0.0:*          
tcp   LISTEN 0      4096       127.0.0.54:53         0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:9000       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:9187       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:9121       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:9090       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:9100       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:9443       0.0.0.0:*          
tcp   LISTEN 0      4096          0.0.0.0:22         0.0.0.0:*          
tcp   LISTEN 0      1000   10.255.255.254:53         0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:3000       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:6379       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:6333       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:6334       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:8080       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:8081       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:5432       0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:5678       0.0.0.0:*          
tcp   LISTEN 0      4096    127.0.0.53%lo:53         0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:38657      0.0.0.0:*          
tcp   LISTEN 0      4096             [::]:22            [::]:*          
```

## 9. TOP PROCESSES (CPU/Memory)
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
phoenix   582797  0.5  1.2 33006868 396172 pts/5 Sl+  04:49   5:15 claude
phoenix   910574  2.0  0.8 32892772 283632 pts/2 Sl+  18:09   4:41 claude
phoenix    52918  0.0  0.8 22408548 272636 ?     Sl   Nov17   1:06 node /usr/local/bin/n8n
472        52901  0.4  0.8 1770516 262184 ?      Ssl  Nov17   6:46 grafana server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini --packaging=docker cfg:default.log.mode=console cfg:default.paths.data=/var/lib/grafana cfg:default.paths.logs=/var/log/grafana cfg:default.paths.plugins=/var/lib/grafana/plugins cfg:default.paths.provisioning=/etc/grafana/provisioning
nobody    124940  0.2  0.7 1919988 256268 ?      Ssl  Nov17   3:19 /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --storage.tsdb.retention.time=30d --web.console.libraries=/etc/prometheus/console_libraries --web.console.templates=/etc/prometheus/consoles --web.enable-lifecycle
root      629955  6.9  0.6 3850940 216660 ?      Ssl  05:57  67:21 /bin/ollama serve
dnsmasq   671643  0.0  0.6 8685148 209088 ?      Ss   06:55   0:09 postgres
root       18897  0.5  0.3 4403692 98052 ?       Ssl  Nov17   8:11 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
root      126465  2.6  0.2 1275352 85220 ?       Ssl  Nov17  36:55 /usr/bin/cadvisor -logtostderr
dnsmasq   671766  0.0  0.2 8685412 75712 ?       Ss   06:55   0:01 postgres: checkpointer 
root       52579  0.0  0.2 1321884 74136 ?       Ssl  Nov17   0:18 /portainer
dnsmasq   671767  0.0  0.2 8685356 73024 ?       Ss   06:55   0:00 postgres: background writer 
root         223  0.3  0.1 3060304 60632 ?       Ssl  Nov17   5:26 /usr/bin/containerd
root      648440  0.0  0.1 4863340 57396 ?       Sl   06:17   0:40 ./qdrant
root      361290  0.0  0.1 598268 35604 ?        Ssl  02:13   0:56 /usr/bin/python3 /usr/bin/fail2ban-server -xf start
dnsmasq   672031  0.0  0.0 8689244 28608 ?       Ss   06:55   0:12 postgres: phoenix phoenix_core 172.18.0.10(56734) idle
dhcpcd     52562  0.0  0.0 176276 26756 ?        Ss   Nov17   0:03 php -S [::]:8080 -t /var/www/html
nobody    126464  0.1  0.0 1244184 23564 ?       Ssl  Nov17   2:03 /bin/node_exporter --path.procfs=/host/proc --path.sysfs=/host/sys --path.rootfs=/host --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)
dnsmasq   671769  0.0  0.0 8685148 22528 ?       Ss   06:55   0:00 postgres: walwriter 
```

## 10. DIRECTORY SIZES (Top 30)
```
48K	.
```

## 11. DOCKER CONTAINER DETAILS

### Container: /phoenix_qdrant
```
        "Image": "sha256:0ad2e23181e5646b286253c04cea23f07040ca313cc377d9fa7b21db184b6406",
        "ResolvConfPath": "/var/lib/docker/containers/6fe5fd76d9f40824d7bb450450822fb7715a8cee41263759101987efb56b66f8/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/6fe5fd76d9f40824d7bb450450822fb7715a8cee41263759101987efb56b66f8/hostname",
        "HostsPath": "/var/lib/docker/containers/6fe5fd76d9f40824d7bb450450822fb7715a8cee41263759101987efb56b66f8/hosts",
        "LogPath": "/var/lib/docker/containers/6fe5fd76d9f40824d7bb450450822fb7715a8cee41263759101987efb56b66f8/6fe5fd76d9f40824d7bb450450822fb7715a8cee41263759101987efb56b66f8-json.log",
        "Name": "/phoenix_qdrant",
--
        "Mounts": [
            {
                "Type": "volume",
                "Name": "phoenix_qdrant_data",
                "Source": "/var/lib/docker/volumes/phoenix_qdrant_data/_data",
                "Destination": "/qdrant/storage",
--
            "Env": [
                "QDRANT__SERVICE__API_KEY=PhoenixQdrant_2025_Secure!",
                "QDRANT__LOG_LEVEL=INFO",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "DIR=",
                "TZ=Etc/UTC",
--
            "Cmd": [
                "./entrypoint.sh"
            ],
            "Image": "qdrant/qdrant:latest",
            "Volumes": null,
            "WorkingDir": "/qdrant",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
```

### Container: /phoenix_ollama
```
        "Image": "sha256:9a71b71d0c8b8f9978b0372d6184df40c60ae7f292c8790835970cf00a4fe675",
        "ResolvConfPath": "/var/lib/docker/containers/8f8d7f241ba8223e848c72414e3d2d0f5691345c36e9c10fe741d7a76a133a17/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/8f8d7f241ba8223e848c72414e3d2d0f5691345c36e9c10fe741d7a76a133a17/hostname",
        "HostsPath": "/var/lib/docker/containers/8f8d7f241ba8223e848c72414e3d2d0f5691345c36e9c10fe741d7a76a133a17/hosts",
        "LogPath": "/var/lib/docker/containers/8f8d7f241ba8223e848c72414e3d2d0f5691345c36e9c10fe741d7a76a133a17/8f8d7f241ba8223e848c72414e3d2d0f5691345c36e9c10fe741d7a76a133a17-json.log",
        "Name": "/phoenix_ollama",
--
        "Mounts": [
            {
                "Type": "volume",
                "Name": "phoenix_ollama_data",
                "Source": "/var/lib/docker/volumes/phoenix_ollama_data/_data",
                "Destination": "/root/.ollama",
--
            "Env": [
                "OLLAMA_HOST=0.0.0.0",
                "NVIDIA_VISIBLE_DEVICES=all",
                "CUDA_VISIBLE_DEVICES=0",
                "OLLAMA_NUM_PARALLEL=2",
                "OLLAMA_MAX_LOADED_MODELS=2",
--
            "Cmd": [
                "serve"
            ],
            "Healthcheck": {
                "Test": [
                    "CMD-SHELL",
--
            "Image": "ollama/ollama:latest",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/bin/ollama"
            ],
```

### Container: /phoenix_postgres_exporter
```
        "Image": "sha256:519a5596d17c97cbdbe55bdabd93a0bde051be384540fe696ebb26650688f869",
        "ResolvConfPath": "/var/lib/docker/containers/950b8221bb08e282e94db5b98be3de6f824eb5bfdef95969b222ff54a9d9db25/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/950b8221bb08e282e94db5b98be3de6f824eb5bfdef95969b222ff54a9d9db25/hostname",
        "HostsPath": "/var/lib/docker/containers/950b8221bb08e282e94db5b98be3de6f824eb5bfdef95969b222ff54a9d9db25/hosts",
        "LogPath": "/var/lib/docker/containers/950b8221bb08e282e94db5b98be3de6f824eb5bfdef95969b222ff54a9d9db25/950b8221bb08e282e94db5b98be3de6f824eb5bfdef95969b222ff54a9d9db25-json.log",
        "Name": "/phoenix_postgres_exporter",
--
        "Mounts": [],
        "Config": {
            "Hostname": "950b8221bb08",
            "Domainname": "",
            "User": "nobody",
            "AttachStdin": false,
--
            "Env": [
                "DATA_SOURCE_NAME=postgresql://phoenix:PhoenixDB_2025_Secure!@phoenix_postgres:5432/phoenix_core?sslmode=disable",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": null,
            "Image": "prometheuscommunity/postgres-exporter:latest",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/bin/postgres_exporter"
            ],
```

### Container: /phoenix_redis_exporter
```
        "Image": "sha256:5aa77ccf50dab209e52cffbc47c5c02429ce6ab643496837a72fb000b182494a",
        "ResolvConfPath": "/var/lib/docker/containers/016490d39d7fadcf2850caf31e0bcfb494ae562410a49b3964c7321936a71f1c/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/016490d39d7fadcf2850caf31e0bcfb494ae562410a49b3964c7321936a71f1c/hostname",
        "HostsPath": "/var/lib/docker/containers/016490d39d7fadcf2850caf31e0bcfb494ae562410a49b3964c7321936a71f1c/hosts",
        "LogPath": "/var/lib/docker/containers/016490d39d7fadcf2850caf31e0bcfb494ae562410a49b3964c7321936a71f1c/016490d39d7fadcf2850caf31e0bcfb494ae562410a49b3964c7321936a71f1c-json.log",
        "Name": "/phoenix_redis_exporter",
--
        "Mounts": [],
        "Config": {
            "Hostname": "016490d39d7f",
            "Domainname": "",
            "User": "59000:59000",
            "AttachStdin": false,
--
            "Env": [
                "REDIS_ADDR=phoenix_redis:6379",
                "REDIS_PASSWORD=PhoenixRedis_2025_Secure!",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": null,
            "Image": "oliver006/redis_exporter:latest",
            "Volumes": null,
            "WorkingDir": "/",
            "Entrypoint": [
                "/redis_exporter"
            ],
```

### Container: /phoenix_node_exporter
```
        "Image": "sha256:696e69e899e068f4df3ebafc08a3fd025eed498271ce6160dad97097311fa574",
        "ResolvConfPath": "/var/lib/docker/containers/e11e82cf13fc38a76bb56e5c48f7dcc58a24886ef5779d9d3307dac8adac4808/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/e11e82cf13fc38a76bb56e5c48f7dcc58a24886ef5779d9d3307dac8adac4808/hostname",
        "HostsPath": "/var/lib/docker/containers/e11e82cf13fc38a76bb56e5c48f7dcc58a24886ef5779d9d3307dac8adac4808/hosts",
        "LogPath": "/var/lib/docker/containers/e11e82cf13fc38a76bb56e5c48f7dcc58a24886ef5779d9d3307dac8adac4808/e11e82cf13fc38a76bb56e5c48f7dcc58a24886ef5779d9d3307dac8adac4808-json.log",
        "Name": "/phoenix_node_exporter",
--
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/proc",
                "Destination": "/host/proc",
                "Mode": "ro",
--
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "--path.procfs=/host/proc",
                "--path.sysfs=/host/sys",
                "--path.rootfs=/host",
                "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)"
            ],
            "Image": "prom/node-exporter:latest",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/bin/node_exporter"
            ],
```

### Container: /phoenix_cadvisor
```
        "Image": "sha256:c02cf39d3dba9fcf5531f23358e33377e50fcc6065d97a27e68a4242229c67a0",
        "ResolvConfPath": "/var/lib/docker/containers/176596505c7bdd385817acca145e0c37b37d54077aee32b55cbadd728de242b8/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/176596505c7bdd385817acca145e0c37b37d54077aee32b55cbadd728de242b8/hostname",
        "HostsPath": "/var/lib/docker/containers/176596505c7bdd385817acca145e0c37b37d54077aee32b55cbadd728de242b8/hosts",
        "LogPath": "/var/lib/docker/containers/176596505c7bdd385817acca145e0c37b37d54077aee32b55cbadd728de242b8/176596505c7bdd385817acca145e0c37b37d54077aee32b55cbadd728de242b8-json.log",
        "Name": "/phoenix_cadvisor",
--
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/",
                "Destination": "/rootfs",
                "Mode": "ro",
--
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "CADVISOR_HEALTHCHECK_URL=http://localhost:8080/healthz"
            ],
            "Cmd": null,
            "Healthcheck": {
                "Test": [
                    "CMD-SHELL",
                    "wget --quiet --tries=1 --spider $CADVISOR_HEALTHCHECK_URL || exit 1"
                ],
--
            "Image": "gcr.io/cadvisor/cadvisor:latest",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/usr/bin/cadvisor",
                "-logtostderr"
```

### Container: /phoenix_grafana
```
        "Image": "sha256:bac4f177a0d5a5f8539398abee9c956472c55d98a4438e1c3d03247c3a302b19",
        "ResolvConfPath": "/var/lib/docker/containers/199ea67e993ec2a1b4a32c2ccf1e9944ff212c6292b47c89fe66d6b14783a357/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/199ea67e993ec2a1b4a32c2ccf1e9944ff212c6292b47c89fe66d6b14783a357/hostname",
        "HostsPath": "/var/lib/docker/containers/199ea67e993ec2a1b4a32c2ccf1e9944ff212c6292b47c89fe66d6b14783a357/hosts",
        "LogPath": "/var/lib/docker/containers/199ea67e993ec2a1b4a32c2ccf1e9944ff212c6292b47c89fe66d6b14783a357/199ea67e993ec2a1b4a32c2ccf1e9944ff212c6292b47c89fe66d6b14783a357-json.log",
        "Name": "/phoenix_grafana",
--
            "Mounts": [
                {
                    "Type": "volume",
                    "Source": "phoenix_grafana_data",
                    "Target": "/var/lib/grafana",
                    "VolumeOptions": {}
--
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/mnt/c/dev/phoenix/configs/grafana/provisioning",
                "Destination": "/etc/grafana/provisioning",
                "Mode": "ro",
--
            "Env": [
                "GF_USERS_ALLOW_SIGN_UP=false",
                "GF_SERVER_ROOT_URL=http://localhost:3000",
                "GF_INSTALL_PLUGINS=",
                "GF_SECURITY_ADMIN_USER=admin",
                "GF_SECURITY_ADMIN_PASSWORD=PhoenixGrafana_2025_Secure!",
--
            "Cmd": null,
            "Image": "grafana/grafana:latest",
            "Volumes": null,
            "WorkingDir": "/usr/share/grafana",
            "Entrypoint": [
                "/run.sh"
            ],
```

### Container: /phoenix_adminer
```
        "Image": "sha256:bda254a71aeb2bd0ca65103a92fc64378161241dd9eb70561fef45601a600627",
        "ResolvConfPath": "/var/lib/docker/containers/0c00d847ccc2225b9088fd336618f13d0896a419813c27364615db723ab7cffe/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/0c00d847ccc2225b9088fd336618f13d0896a419813c27364615db723ab7cffe/hostname",
        "HostsPath": "/var/lib/docker/containers/0c00d847ccc2225b9088fd336618f13d0896a419813c27364615db723ab7cffe/hosts",
        "LogPath": "/var/lib/docker/containers/0c00d847ccc2225b9088fd336618f13d0896a419813c27364615db723ab7cffe/0c00d847ccc2225b9088fd336618f13d0896a419813c27364615db723ab7cffe-json.log",
        "Name": "/phoenix_adminer",
--
        "Mounts": [],
        "Config": {
            "Hostname": "0c00d847ccc2",
            "Domainname": "",
            "User": "adminer",
            "AttachStdin": false,
--
            "Env": [
                "ADMINER_DEFAULT_SERVER=phoenix_postgres",
                "ADMINER_DESIGN=nette",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "PHPIZE_DEPS=autoconf \t\tdpkg-dev dpkg \t\tfile \t\tg++ \t\tgcc \t\tlibc-dev \t\tmake \t\tpkgconf \t\tre2c",
                "PHP_INI_DIR=/usr/local/etc/php",
--
            "Cmd": [
                "php",
                "-S",
                "[::]:8080",
                "-t",
                "/var/www/html"
--
            "Image": "adminer:latest",
            "Volumes": null,
            "WorkingDir": "/var/www/html",
            "Entrypoint": [
                "entrypoint.sh",
                "docker-php-entrypoint"
```

### Container: /phoenix_n8n
```
        "Image": "sha256:b4261fdea41664ca902b9fe1ed40dbcaabf171c9bd60ca417db9eafdbcf08274",
        "ResolvConfPath": "/var/lib/docker/containers/0ed6200fde6d68c37a6fd435b0341c679e51815cfa382b3742c04aaebe2cf5c1/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/0ed6200fde6d68c37a6fd435b0341c679e51815cfa382b3742c04aaebe2cf5c1/hostname",
        "HostsPath": "/var/lib/docker/containers/0ed6200fde6d68c37a6fd435b0341c679e51815cfa382b3742c04aaebe2cf5c1/hosts",
        "LogPath": "/var/lib/docker/containers/0ed6200fde6d68c37a6fd435b0341c679e51815cfa382b3742c04aaebe2cf5c1/0ed6200fde6d68c37a6fd435b0341c679e51815cfa382b3742c04aaebe2cf5c1-json.log",
        "Name": "/phoenix_n8n",
--
            "Mounts": [
                {
                    "Type": "volume",
                    "Source": "phoenix_n8n_data",
                    "Target": "/home/node/.n8n",
                    "VolumeOptions": {}
--
        "Mounts": [
            {
                "Type": "volume",
                "Name": "phoenix_n8n_data",
                "Source": "/var/lib/docker/volumes/phoenix_n8n_data/_data",
                "Destination": "/home/node/.n8n",
--
            "Env": [
                "TZ=America/New_York",
                "N8N_BASIC_AUTH_PASSWORD=PhoenixN8N_2025_Secure!",
                "N8N_PROTOCOL=http",
                "GENERIC_TIMEZONE=America/New_York",
                "N8N_BASIC_AUTH_ACTIVE=true",
--
            "Cmd": null,
            "Image": "n8nio/n8n:latest",
            "Volumes": null,
            "WorkingDir": "/home/node",
            "Entrypoint": [
                "tini",
                "--",
```

### Container: /phoenix_portainer
```
        "Image": "sha256:aa2ac1fdb557a4d8ef187dbfa076297c3997f5a9d8b3e060835acbfcbcd28e7d",
        "ResolvConfPath": "/var/lib/docker/containers/c06f44d5d2e0c5b41de16af0d101aed80c411296f1771f0860071a463688ccad/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/c06f44d5d2e0c5b41de16af0d101aed80c411296f1771f0860071a463688ccad/hostname",
        "HostsPath": "/var/lib/docker/containers/c06f44d5d2e0c5b41de16af0d101aed80c411296f1771f0860071a463688ccad/hosts",
        "LogPath": "/var/lib/docker/containers/c06f44d5d2e0c5b41de16af0d101aed80c411296f1771f0860071a463688ccad/c06f44d5d2e0c5b41de16af0d101aed80c411296f1771f0860071a463688ccad-json.log",
        "Name": "/phoenix_portainer",
--
            "Mounts": [
                {
                    "Type": "volume",
                    "Source": "phoenix_portainer_data",
                    "Target": "/data",
                    "VolumeOptions": {}
--
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/var/run/docker.sock",
                "Destination": "/var/run/docker.sock",
                "Mode": "ro",
--
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": null,
            "Image": "portainer/portainer-ce:latest",
            "Volumes": {
                "/data": {}
            },
            "WorkingDir": "/",
            "Entrypoint": [
```

### Container: /phoenix_prometheus
```
        "Image": "sha256:a683da7699127231b140f7dbd7d60e9741d51543ba91c656bf3287860a39428f",
        "ResolvConfPath": "/var/lib/docker/containers/c5870c8b4b6df4accf9f4adc4d6a38518ba84dfb27ea3ae0e5c4cbcc9ffc33d0/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/c5870c8b4b6df4accf9f4adc4d6a38518ba84dfb27ea3ae0e5c4cbcc9ffc33d0/hostname",
        "HostsPath": "/var/lib/docker/containers/c5870c8b4b6df4accf9f4adc4d6a38518ba84dfb27ea3ae0e5c4cbcc9ffc33d0/hosts",
        "LogPath": "/var/lib/docker/containers/c5870c8b4b6df4accf9f4adc4d6a38518ba84dfb27ea3ae0e5c4cbcc9ffc33d0/c5870c8b4b6df4accf9f4adc4d6a38518ba84dfb27ea3ae0e5c4cbcc9ffc33d0-json.log",
        "Name": "/phoenix_prometheus",
--
            "Mounts": [
                {
                    "Type": "volume",
                    "Source": "phoenix_prometheus_data",
                    "Target": "/prometheus",
                    "VolumeOptions": {}
--
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/mnt/c/dev/phoenix/configs/prometheus/prometheus.yml",
                "Destination": "/etc/prometheus/prometheus.yml",
                "Mode": "ro",
--
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "--config.file=/etc/prometheus/prometheus.yml",
                "--storage.tsdb.path=/prometheus",
                "--storage.tsdb.retention.time=30d",
                "--web.console.libraries=/etc/prometheus/console_libraries",
                "--web.console.templates=/etc/prometheus/consoles",
--
            "Image": "prom/prometheus:latest",
            "Volumes": {
                "/prometheus": {}
            },
            "WorkingDir": "/prometheus",
            "Entrypoint": [
```

### Container: /phoenix_redis
```
        "Image": "sha256:38ce1020959855cd9e9e7e4d57154db87e2e1205e03477ab2896a84c90d144a9",
        "ResolvConfPath": "/var/lib/docker/containers/cccdc0e8598d86fa1f85128219a397f336b4fe09de1fe28ebe81a65e01587531/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/cccdc0e8598d86fa1f85128219a397f336b4fe09de1fe28ebe81a65e01587531/hostname",
        "HostsPath": "/var/lib/docker/containers/cccdc0e8598d86fa1f85128219a397f336b4fe09de1fe28ebe81a65e01587531/hosts",
        "LogPath": "/var/lib/docker/containers/cccdc0e8598d86fa1f85128219a397f336b4fe09de1fe28ebe81a65e01587531/cccdc0e8598d86fa1f85128219a397f336b4fe09de1fe28ebe81a65e01587531-json.log",
        "Name": "/phoenix_redis",
--
            "Mounts": [
                {
                    "Type": "volume",
                    "Source": "phoenix_redis_data",
                    "Target": "/data",
                    "VolumeOptions": {}
--
        "Mounts": [
            {
                "Type": "volume",
                "Name": "phoenix_redis_data",
                "Source": "/var/lib/docker/volumes/phoenix_redis_data/_data",
                "Destination": "/data",
--
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "GOSU_VERSION=1.17",
                "REDIS_VERSION=7.2.12",
                "REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-7.2.12.tar.gz",
                "REDIS_DOWNLOAD_SHA=97c60478a7c777ac914ca9d87a7e88ba265926456107e758c62d8f971d0196bc"
--
            "Cmd": [
                "redis-server",
                "--requirepass",
                "PhoenixRedis_2025_Secure!",
                "--appendonly",
                "yes",
--
            "Image": "redis:7.2-alpine",
            "Volumes": {
                "/data": {}
            },
            "WorkingDir": "/data",
            "Entrypoint": [
```

### Container: /phoenix_postgres
```
        "Image": "sha256:68f823d56bc9172e799a8b4ed7ef4a407b39328f5359dd7e90f3319a38b6a19b",
        "ResolvConfPath": "/var/lib/docker/containers/180e694f442541d1dd87aeac7c39b6769d09bb8340c493771512e227a8098b82/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/180e694f442541d1dd87aeac7c39b6769d09bb8340c493771512e227a8098b82/hostname",
        "HostsPath": "/var/lib/docker/containers/180e694f442541d1dd87aeac7c39b6769d09bb8340c493771512e227a8098b82/hosts",
        "LogPath": "/var/lib/docker/containers/180e694f442541d1dd87aeac7c39b6769d09bb8340c493771512e227a8098b82/180e694f442541d1dd87aeac7c39b6769d09bb8340c493771512e227a8098b82-json.log",
        "Name": "/phoenix_postgres",
--
            "Mounts": [
                {
                    "Type": "volume",
                    "Source": "phoenix_postgres_data",
                    "Target": "/var/lib/postgresql/data",
                    "VolumeOptions": {}
--
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/mnt/c/dev/phoenix/configs/postgres/init.sql",
                "Destination": "/docker-entrypoint-initdb.d/init.sql",
                "Mode": "ro",
--
            "Env": [
                "POSTGRES_MAX_CONNECTIONS=200",
                "POSTGRES_SHARED_BUFFERS=256MB",
                "POSTGRES_USER=phoenix",
                "POSTGRES_PASSWORD=PhoenixDB_2025_Secure!",
                "POSTGRES_DB=phoenix_core",
--
            "Cmd": [
                "postgres"
            ],
            "Healthcheck": {
                "Test": [
                    "CMD-SHELL",
--
            "Image": "pgvector/pgvector:pg16",
            "Volumes": {
                "/var/lib/postgresql/data": {}
            },
            "WorkingDir": "",
            "Entrypoint": [
```

## 12. SUMMARY STATISTICS
```
Total Files: 4
Total Directories: 1
Total Size: 80K
Docker Containers: 14
Docker Images: 16
Docker Volumes: 9
```

---
Snapshot completed: Tue Nov 18 22:02:34 EST 2025
Generated by: phoenix_snapshot.sh
