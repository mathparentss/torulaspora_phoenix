#!/bin/bash
# Phoenix Complete System Snapshot for AI Memory
# Captures everything: files, permissions, sizes, Docker, system state

OUTPUT="phoenix_snapshot_$(date +%Y%m%d_%H%M%S).md"
echo "Generating complete Phoenix snapshot..."

{
echo "# PHOENIX COMPLETE SYSTEM SNAPSHOT"
echo "Generated: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo ""
echo "---"
echo ""

# ============ SYSTEM INFORMATION ============
echo "## 1. SYSTEM INFORMATION"
echo ""
echo "### Kernel & OS"
echo '```'
uname -a
echo ""
cat /etc/os-release 2>/dev/null || lsb_release -a 2>/dev/null
echo '```'
echo ""

echo "### CPU Info"
echo '```'
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|MHz"
echo '```'
echo ""

echo "### Memory"
echo '```'
free -h
echo '```'
echo ""

echo "### Disk Usage"
echo '```'
df -h
echo '```'
echo ""

echo "### Network Interfaces"
echo '```'
ip -brief addr show
echo '```'
echo ""

# ============ DOCKER STATUS ============
echo "## 2. DOCKER STATUS"
echo ""
echo "### Docker Version"
echo '```'
docker --version 2>/dev/null || echo "Docker not installed"
echo '```'
echo ""

echo "### Running Containers"
echo '```'
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}" 2>/dev/null || echo "No containers running"
echo '```'
echo ""

echo "### All Containers (including stopped)"
echo '```'
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}" 2>/dev/null || echo "No containers"
echo '```'
echo ""

echo "### Docker Images"
echo '```'
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "No images"
echo '```'
echo ""

echo "### Docker Volumes"
echo '```'
docker volume ls 2>/dev/null || echo "No volumes"
echo '```'
echo ""

echo "### Docker Networks"
echo '```'
docker network ls 2>/dev/null || echo "No networks"
echo '```'
echo ""

echo "### Docker Disk Usage"
echo '```'
docker system df 2>/dev/null || echo "Docker system info unavailable"
echo '```'
echo ""

# ============ RUNNING SERVICES ============
echo "## 3. RUNNING SERVICES"
echo '```'
systemctl list-units --type=service --state=running --no-pager 2>/dev/null | head -30
echo '```'
echo ""

# ============ FILE TREE WITH PERMISSIONS ============
echo "## 4. COMPLETE FILE TREE (Permissions + Sizes)"
echo ""
echo "### Tree with Full Details"
echo '```'
if command -v tree &> /dev/null; then
    tree -afpughD -L 4 --charset ascii \
        -I 'node_modules|.git|__pycache__|*.pyc|.cache|overlay2' 2>/dev/null || \
        echo "Tree command failed, using fallback..."
else
    echo "Tree not installed, using find..."
fi
echo '```'
echo ""

# ============ DETAILED FILE LISTING ============
echo "## 5. ALL FILES (Permissions, Size, Path)"
echo ""
echo '```'
find . -type f \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*' \
    ! -path '*/__pycache__/*' \
    ! -path '*/overlay2/*' \
    ! -path '*/.cache/*' \
    -exec ls -lh {} \; 2>/dev/null | \
    awk '{printf "%-10s %-8s %s\n", $1, $5, $9}' | \
    sort -k3
echo '```'
echo ""

# ============ LARGEST FILES ============
echo "## 6. LARGEST FILES (Top 50)"
echo '```'
find . -type f \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*' \
    ! -path '*/overlay2/*' \
    -exec du -h {} \; 2>/dev/null | \
    sort -rh | head -50
echo '```'
echo ""

# ============ CONFIGURATION FILES ============
echo "## 7. KEY CONFIGURATION FILES"
echo ""
echo "### Docker Compose Files"
echo '```'
find . -name "docker-compose*.yml" -o -name "compose.*.yml" 2>/dev/null
echo '```'
echo ""

echo "### Environment Files"
echo '```'
find . -name ".env*" -type f 2>/dev/null
echo '```'
echo ""

echo "### Shell Scripts"
echo '```'
find . -name "*.sh" -type f 2>/dev/null
echo '```'
echo ""

# ============ NETWORK PORTS ============
echo "## 8. LISTENING PORTS"
echo '```'
ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || echo "Port info unavailable"
echo '```'
echo ""

# ============ PROCESS LIST ============
echo "## 9. TOP PROCESSES (CPU/Memory)"
echo '```'
ps aux --sort=-%mem | head -20
echo '```'
echo ""

# ============ STORAGE BREAKDOWN ============
echo "## 10. DIRECTORY SIZES (Top 30)"
echo '```'
du -h --max-depth=2 . 2>/dev/null | sort -rh | head -30
echo '```'
echo ""

# ============ DOCKER CONTAINER DETAILS ============
echo "## 11. DOCKER CONTAINER DETAILS"
for container in $(docker ps -aq 2>/dev/null); do
    echo ""
    echo "### Container: $(docker inspect --format='{{.Name}}' $container 2>/dev/null)"
    echo '```'
    docker inspect $container 2>/dev/null | grep -A5 "Mounts\|Env\|Cmd\|Image"
    echo '```'
done
echo ""

# ============ SUMMARY STATISTICS ============
echo "## 12. SUMMARY STATISTICS"
echo '```'
echo "Total Files: $(find . -type f 2>/dev/null | wc -l)"
echo "Total Directories: $(find . -type d 2>/dev/null | wc -l)"
echo "Total Size: $(du -sh . 2>/dev/null | cut -f1)"
echo "Docker Containers: $(docker ps -a 2>/dev/null | wc -l)"
echo "Docker Images: $(docker images 2>/dev/null | wc -l)"
echo "Docker Volumes: $(docker volume ls 2>/dev/null | wc -l)"
echo '```'
echo ""

echo "---"
echo "Snapshot completed: $(date)"
echo "Generated by: phoenix_snapshot.sh"

} > "$OUTPUT" 2>&1

# Compress for AI context window efficiency
gzip -k "$OUTPUT"

echo ""
echo "✅ Snapshot complete!"
echo "📄 Markdown: $OUTPUT"
echo "📦 Compressed: ${OUTPUT}.gz"
echo "📊 Size: $(du -h $OUTPUT | cut -f1)"
echo ""