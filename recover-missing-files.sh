#!/usr/bin/env bash
#
# PHOENIX PHASE 1.5 — FILE RECOVERY SCRIPT
# Recovers missing files from /mnt/c/dev/phoenix migration
# Usage: sudo ./recover-missing-files.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[RECOVERY]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)"
    exit 1
fi

SOURCE="/mnt/c/dev/phoenix"
DEST="/opt/phoenix"

log "Starting file recovery from $SOURCE to $DEST..."
echo ""

# 1. Documentation
log "Recovering documentation..."
cp "$SOURCE/CLAUDE.md" "$DEST/share/docs/CLAUDE_ROOT.md" 2>/dev/null || log "CLAUDE.md not found (may already be migrated)"
cp "$SOURCE/TIER0_OPTIMIZATION_REPORT.md" "$DEST/share/docs/" 2>/dev/null || log "TIER0_OPTIMIZATION_REPORT.md not found"
success "Documentation recovered"

# 2. tree.md snapshot (compress)
log "Archiving tree.md snapshot..."
mkdir -p "$DEST/.archive/snapshots"
if [[ -f "$SOURCE/tree.md" ]]; then
    gzip -c "$SOURCE/tree.md" > "$DEST/.archive/snapshots/tree-$(date +%Y%m%d).md.gz"
    success "tree.md archived ($(du -h $DEST/.archive/snapshots/tree-*.md.gz | cut -f1))"
else
    log "tree.md not found (skip)"
fi

# 3. Claude Code config
log "Recovering Claude Code configuration..."
if [[ -d "$SOURCE/.claude" ]]; then
    cp -r "$SOURCE/.claude" "$DEST/.claude"
    success ".claude/ directory recovered ($(ls $DEST/.claude | wc -l) files)"
else
    log ".claude/ not found (may already be migrated)"
fi

# 4. Deployment scripts
log "Recovering tier deployment scripts..."
mkdir -p "$DEST/sbin/legacy"
cp "$SOURCE/scripts/tier"*.sh "$DEST/sbin/legacy/" 2>/dev/null || true
cp "$SOURCE/scripts/phoenix.sh" "$DEST/sbin/legacy/" 2>/dev/null || true
SCRIPT_COUNT=$(ls "$DEST/sbin/legacy/"*.sh 2>/dev/null | wc -l)
if [[ $SCRIPT_COUNT -gt 0 ]]; then
    chmod +x "$DEST/sbin/legacy/"*.sh
    success "$SCRIPT_COUNT deployment scripts recovered"
else
    log "No tier scripts found"
fi

# 5. Strategic docs
log "Archiving strategic planning docs..."
mkdir -p "$DEST/.archive/strategic"
if [[ -d "$SOURCE/phoenix-architect-council.agent" ]]; then
    cp -r "$SOURCE/phoenix-architect-council.agent" "$DEST/.archive/strategic/"
    success "Strategic docs archived ($(ls $DEST/.archive/strategic/phoenix-architect-council.agent | wc -l) files)"
else
    log "phoenix-architect-council.agent not found"
fi

# 6. Auxiliary configs
log "Recovering auxiliary configs..."
mkdir -p "$DEST/etc/n8n" "$DEST/etc/vpn"
cp "$SOURCE/configs/n8n-ollama-workflow.json" "$DEST/etc/n8n/" 2>/dev/null && success "n8n workflow recovered" || log "n8n workflow not found"
cp "$SOURCE/configs/proton/proton-wireguard.conf" "$DEST/etc/vpn/" 2>/dev/null && success "VPN config recovered" || log "VPN config not found"

# 7. Optional tools
log "Archiving optional tools..."
mkdir -p "$DEST/.archive/tools"
if [[ -d "$SOURCE/grok" ]]; then
    cp -r "$SOURCE/grok" "$DEST/.archive/tools/"
    success "Grok tools archived"
else
    log "grok/ not found"
fi

# 8. Fix ownership
log "Fixing ownership..."
chown -R phoenix:phoenix "$DEST"
success "All files owned by phoenix:phoenix"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  FILE RECOVERY COMPLETE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Recovered files summary:"
echo "  - Documentation: CLAUDE.md, TIER0_OPTIMIZATION_REPORT.md"
echo "  - Claude Code config: .claude/ directory"
echo "  - Deployment scripts: $SCRIPT_COUNT tier scripts"
echo "  - Strategic docs: phoenix-architect-council.agent/"
echo "  - Snapshots: tree.md (compressed)"
echo "  - Auxiliary: n8n workflows, VPN configs, grok tools"
echo ""
echo "Next steps:"
echo "  1. Review recovered files in /opt/phoenix"
echo "  2. Commit to git: cd /opt/phoenix && git add . && git commit"
echo "  3. Create tar backup of /mnt/c/dev/phoenix"
echo "  4. Verify backup integrity"
echo "  5. Safe to remove /mnt/c/dev/phoenix"
echo ""
echo "═══════════════════════════════════════════════════════════"
